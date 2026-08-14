CREATE PROCEDURE "informix".sp_procesocierresac(cEmpresa CHAR(3))
RETURNING CHAR(5);  --Codigo de retorno

    DEFINE cCodRet          CHAR(3);
    DEFINE cCodRetSP        CHAR(5);
    DEFINE cInfoErr         CHAR(100);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE iFlagIniCierre   INTEGER;
    DEFINE iFlagActHis      INTEGER;
    DEFINE iFlagIniDiario   INTEGER;
    DEFINE iFlagGenFiles    INTEGER;
    DEFINE iFlagProrrateo   INTEGER;
    DEFINE iFlagRptEspec    INTEGER;
    DEFINE iFlagActFechas   INTEGER;
    DEFINE iFlagFinCierre   INTEGER;
    DEFINE dFecha_Hoy       DATE;

---    SET DEBUG FILE TO "/RESPALDOS/erfr/sp_procesocierresac.out" ;
----    TRACE ON;





    LET cCodRet = '000';

    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_ProcesoCierreSAC");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;

        SELECT {+AVOID_FULL("informix".sac_fechas)}  fecha_hoy
        INTO dFEcha_Hoy
        FROM bdisac:sac_fechas;
--	2013.11.01 FRG i
		UPDATE {+AVOID_FULL("informix".sac_fechas)} bdisac:sac_fechas set ind_cierre = '0';
--	2013.11.01 FRG f		
        SELECT SUM(CAST(FlagIniCier AS INTEGER)), SUM(CAST(FlagPror AS INTEGER)), SUM(CAST(FlagActHis AS INTEGER)), SUM(CAST(FlagIniDiario AS INTEGER)),
               SUM(CAST(FlagGenFiles AS INTEGER)), SUM(CAST(FlagRptEspec AS INTEGER)), SUM(CAST(FlagActFechas AS INTEGER)),SUM(CAST(FlagFinCier AS INTEGER))
        INTO iFlagIniCierre, iFlagProrrateo, iFlagActHis, iFlagIniDiario, iFlagGenFiles, iFlagRptEspec, iFlagActFechas,iFlagFinCierre
        FROM TABLE(MULTISET(
        SELECT
        CASE WHEN proceso = 'INI_CIERRE' THEN status END AS FlagIniCier,
        CASE WHEN proceso = 'CALC_PRORR' THEN status END AS FlagPror,
        CASE WHEN proceso = 'ACT_HISTOR' THEN status END AS FlagActHis,
        CASE WHEN proceso = 'INI_DIARIO' THEN status END AS FlagIniDiario,
        CASE WHEN proceso = 'GEN_ARCHIV' THEN status END AS FlagGenFiles,
        CASE WHEN proceso = 'RPTS_ESPEC' THEN status END AS FlagRptEspec,
        CASE WHEN proceso = 'ACT_FECHAS' THEN status END AS FlagActFechas,
        CASE WHEN proceso = 'FIN_CIERRE' THEN status END AS FlagFinCier
        FROM bdisac:sac_procesos
        WHERE fecha_proceso = dFEcha_Hoy));

        IF  iFlagIniCierre = 1 AND iFlagProrrateo = 1 AND  iFlagActHis = 1 AND iFlagIniDiario = 1 AND iFlagGenFiles = 1 AND iFlagRptEspec = 1 AND iFlagActFechas = 1 AND iFlagFinCierre = 1 THEN
            LET cCodRet = '999';
			LET iSqlErr = 0;
			LET iIsamErr = 0;
			LET cInfoErr = 'Proceso Cierre SAC ya fue ejecutado el día de hoy.';
            EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_ProcesoCierreSAC");
			RETURN cCodRet;
        ELSE
            LET iFlagIniCierre = 0;
            LET iFlagProrrateo = 0;
            LET iFlagActHis    = 0;
            LET iFlagIniDiario = 0;
            LET iFlagGenFiles  = 0;
            LET iFlagRptEspec  = 0;
            LET iFlagActFechas = 0;
            LET iFlagFinCierre = 0;

            IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                        FROM bdisac:sac_procesos
                        WHERE TRIM(proceso) = 'INI_CIERRE'
                        AND  fecha_proceso = dFecha_Hoy) THEN

                INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                VALUES('INI_CIERRE', dFecha_hoy, '1', 'informix',CURRENT);
            END IF;

            IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                        FROM bdisac:sac_procesos
                        WHERE TRIM(proceso) = 'INI_CIERRE'
                        AND fecha_proceso = dFecha_Hoy
                        AND status = '1') THEN

                LET iFlagIniCierre = 1;

            END IF;
            IF iFlagIniCierre = 1 THEN   --VALIDA SI EL PROCESO DE CIERRE DIARIO INICIO

                IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                            FROM bdisac:sac_procesos
                            WHERE TRIM(proceso) = 'CALC_PRORR'
                            AND  fecha_proceso = dFecha_Hoy) THEN

                    INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                    VALUES('CALC_PRORR', dFecha_hoy, '0', 'informix',CURRENT);
                END IF;

                IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                            FROM bdisac:sac_procesos
                            WHERE TRIM(proceso) = 'CALC_PRORR'
                            AND  fecha_proceso = dFecha_Hoy
                            AND status = '0') THEN

                    EXECUTE PROCEDURE  sp_CalculaProrrateoDeComisiones(dFecha_hoy) INTO cCodRetSP;

                    IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                        UPDATE bdisac:sac_procesos
                        SET status = '1'
                        WHERE TRIM(proceso) = 'CALC_PRORR'
                        AND  fecha_proceso = dFecha_Hoy;
                    ELSE
                        RETURN cCodRetSP;
                    END IF;
                END IF;

                IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                        FROM bdisac:sac_procesos
                        WHERE TRIM(proceso) = 'CALC_PRORR'
                        AND  fecha_proceso = dFecha_Hoy
                        AND status = '1') THEN

                        LET iFlagProrrateo = 1;
                END IF;

                IF iFlagProrrateo = 1 THEN   --VALIDA SI EL PRORRATEO DE COMISIONES SEL LLEVO A CABO
                    IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                FROM bdisac:sac_procesos
                                WHERE TRIM(proceso) = 'ACT_HISTOR'
                                AND  fecha_proceso = dFecha_Hoy) THEN

                        INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                        VALUES('ACT_HISTOR', dFecha_hoy, '0', 'informix',CURRENT);
                    END IF;
                    IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                FROM bdisac:sac_procesos
                                WHERE TRIM(proceso) = 'ACT_HISTOR'
                                AND  fecha_proceso = dFecha_Hoy
                                AND status = '0') THEN

                        EXECUTE PROCEDURE  sp_ActualizaHistoricodeTransacciones(dFecha_hoy) INTO cCodRetSP;

                        IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                            UPDATE bdisac:sac_procesos
                            SET status = '1'
                            WHERE TRIM(proceso) = 'ACT_HISTOR'
                            AND  fecha_proceso = dFecha_Hoy;
                        ELSE
                            RETURN cCodRetSP;
                        END IF;
                    END IF;

                    IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                FROM bdisac:sac_procesos
                                WHERE TRIM(proceso) = 'ACT_HISTOR'
                                AND  fecha_proceso = dFecha_Hoy
                                AND status = '1') THEN

                        LET iFlagActHis = 1;
                    END IF;

                    IF iFlagActHis = 1 THEN        --VALIDA SI ACTULIZACION DEL HISORICO SE LLEVO A CABO

                        IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                    FROM bdisac:sac_procesos
                                    WHERE TRIM(proceso) = 'INI_DIARIO'
                                    AND  fecha_proceso = dFecha_Hoy) THEN

                            INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                            VALUES('INI_DIARIO', dFecha_hoy, '0', 'informix',CURRENT);
                        END IF;

                        IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                    FROM bdisac:sac_procesos
                                    WHERE TRIM(proceso) = 'INI_DIARIO'
                                    AND  fecha_proceso = dFecha_Hoy
                                    AND status = '0') THEN

                            EXECUTE PROCEDURE   sp_InicializaTablasMovimientosDiarios() INTO cCodRetSP;

                            IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                                UPDATE bdisac:sac_procesos
                                SET status = '1'
                                WHERE TRIM(proceso) = 'INI_DIARIO'
                                AND  fecha_proceso = dFecha_Hoy;
                            ELSE
                                RETURN cCodRetSP;
                            END IF;
                        END IF;
                        IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                    FROM bdisac:sac_procesos
                                    WHERE TRIM(proceso) = 'INI_DIARIO'
                                    AND  fecha_proceso = dFecha_Hoy
                                    AND status = '1') THEN

                            LET iFlagIniDiario = 1;
                        END IF;


                        IF  iFlagIniDiario = 1 THEN   --VALIDA SI LA INICIALIZACIO DE LA TABLAS DIARIAS SE LLEVO A CABO

                            IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                        FROM bdisac:sac_procesos
                                        WHERE TRIM(proceso) = 'GEN_ARCHIV'
                                        AND  fecha_proceso = dFecha_Hoy) THEN

                                INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                                VALUES('GEN_ARCHIV', dFecha_hoy, '0', 'informix',CURRENT);
                            END IF;

                            IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                        FROM bdisac:sac_procesos
                                        WHERE TRIM(proceso) = 'GEN_ARCHIV'
                                        AND  fecha_proceso = dFecha_Hoy
                                        AND status =  '0' ) THEN

                                EXECUTE PROCEDURE  sp_GeneraArchivosCobranzaCentral(dFecha_Hoy) INTO cCodRetSP;

                                IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                                    UPDATE bdisac:sac_procesos
                                    SET status = '1'
                                    WHERE TRIM(proceso) = 'GEN_ARCHIV'
                                    AND  fecha_proceso = dFecha_Hoy;
                                ELSE
                                    RETURN cCodRetSP;
                                END IF;
                            END IF;

                            IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                    FROM bdisac:sac_procesos
                                    WHERE TRIM(proceso) = 'GEN_ARCHIV'
                                    AND  fecha_proceso = dFecha_Hoy
                                    AND status = '1') THEN

                                LET iFlagGenFiles = 1;
                            END IF;

                            IF iFlagGenFiles = 1 THEN    --VALIDA SI LA GENERACION DE ARCHIVOS DE COBRANZA SE LLEVO A CABO

                                IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                            FROM bdisac:sac_procesos
                                            WHERE TRIM(proceso) = 'RPTS_ESPEC'
                                            AND  fecha_proceso = dFecha_Hoy) THEN

                                    INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                                    VALUES('RPTS_ESPEC', dFecha_hoy, '0', 'informix',CURRENT);
                                END IF;

                                IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                            FROM bdisac:sac_procesos
                                            WHERE TRIM(proceso) = 'RPTS_ESPEC'
                                            AND  fecha_proceso = dFecha_Hoy
                                            AND status = '0') THEN

                                    EXECUTE PROCEDURE sp_GeneraInformacionReportesEspeciales(dFecha_Hoy) INTO cCodRetSP;

                                    IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                                        UPDATE bdisac:sac_procesos
                                        SET status = '1'
                                        WHERE TRIM(proceso) = 'RPTS_ESPEC'
                                        AND  fecha_proceso = dFecha_Hoy;
                                    ELSE
                                        RETURN cCodRetSP;
                                    END IF;
                                END IF;

                                IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                        FROM bdisac:sac_procesos
                                        WHERE TRIM(proceso) = 'RPTS_ESPEC'
                                        AND  fecha_proceso = dFecha_Hoy
                                        AND status = '1') THEN

                                    LET iFlagRptEspec = 1;
                                END IF;

                                IF iFlagRptEspec = 1 THEN   --VALIDA SI LA GENERACION DE REPORTES ESPECIALES SE LLEVO A CABO
                                    IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                                FROM bdisac:sac_procesos
                                                WHERE TRIM(proceso) = 'ACT_FECHAS'
                                                AND  fecha_proceso = dFecha_Hoy) THEN

                                            INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                                            VALUES('ACT_FECHAS', dFecha_hoy, '0', 'informix',CURRENT);
                                    END IF;

                                    IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                                FROM bdisac:sac_procesos
                                                WHERE TRIM(proceso) = 'ACT_FECHAS'
                                                AND  fecha_proceso = dFecha_Hoy
                                                AND status = '0') THEN

                                        EXECUTE PROCEDURE sp_ActualizaFechasSAC() INTO cCodRetSP;

                                        IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
                                            UPDATE bdisac:sac_procesos
                                            SET status = '1'
                                            WHERE TRIM(proceso) = 'ACT_FECHAS'
                                            AND  fecha_proceso = dFecha_Hoy;
                                        ELSE
                                            RETURN cCodRetSP;
                                        END IF;
                                    END IF;

                                    IF EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                            FROM bdisac:sac_procesos
                                            WHERE TRIM(proceso) = 'ACT_FECHAS'
                                            AND  fecha_proceso = dFecha_Hoy
                                            AND status = '1') THEN

                                        LET iFlagActFechas = 1;
                                    END IF;

                                    IF iFlagActFechas = 1 THEN   --Valida si la actualizacion de la tabla bdisac:sac_fechas se llevo a cabo

                                        IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
                                                    FROM bdisac:sac_procesos
                                                    WHERE TRIM(proceso) = 'FIN_CIERRE'
                                                    AND  fecha_proceso = dFecha_Hoy) THEN

                                            INSERT INTO bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
                                            VALUES('FIN_CIERRE', dFecha_hoy, '1', 'informix',CURRENT);
                                        ELSE
                                            UPDATE bdisac:sac_procesos SET status = '1'
                                            WHERE TRIM(proceso) = 'FIN_CIERRE'
                                            AND  fecha_proceso = dFecha_Hoy;
                                        END IF;
                                    END IF;  --iFlagActFechas
                                END IF;  --iFlagRptEspec
                            END IF;  --iFlagGenFiles
                        END IF;  --iFlagIniDiario
                    END IF;  --iFlagActHis
                END IF;  --iFlagProrrateo
            END IF;  --iFlagIniCierre
        END IF; --Ya se ejecuto el proceso.
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Se encarga de realizar el cierre diario del Sistema de administraciòn de convenios(SAC)',
'EJECUTADO O LLAMADO POR:',
'Ejecutor de Procesos de Central',
'FECHA : Octubre de 2008',
'VERSION: 20081005',
'AUTOR : FRG',
'DESCRIPCION: Se agrega actualización de campo ind_cierre en sac_fechas por Proy. Indep. Sistemas',
'EJECUTADO O LLAMADO POR:',
'Ejecutor de Procesos de Central',
'FECHA : Nov. 2013',
'VERSION: 20131101',
'BD    : bdisac',
'MODIFICO: Uriel Amador Islas',
'DESCRIPCION DE LA MODIFICACIÓN: Se agrega AVOID_FULL en la consulta de la tabla sac_fechas',
'FECHA MODIFICACION: 29/08/2023',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_ws_consultacta(pcAgent_trans_type_code CHAR(10),pcAgent_cd CHAR(3),pcUsuario CHAR(8),
											  pcPassword CHAR(8),pcIp_origen CHAR(15),pcSession_id CHAR(30),pcNum_cta CHAR(20),
											  pcTipo_cuenta CHAR(2),pcCod_pais CHAR(3),pcCod_estado CHAR(3),pcCod_agente_emi CHAR(15),
											  pcUsuario_agnc CHAR(20),pcTerminal CHAR(15),pcFecha_peticion CHAR(8),pcHora_peticion CHAR(6))
											  
	RETURNING CHAR(5),CHAR(4),CHAR(50),CHAR(2),CHAR(20),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(4),CHAR(4),CHAR(2),CHAR(2),CHAR(20),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje          CHAR(200);
DEFINE cCod_err 		CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cCod_cuenta 		CHAR(2);
DEFINE cCta_banco 		CHAR(20);
DEFINE cApell_paterno 	CHAR(26);
DEFINE cApell_materno 	CHAR(26);
DEFINE cNombre1 		CHAR(26);
DEFINE cNombre2 		CHAR(26);
DEFINE cSucursal 		CHAR(4);
DEFINE cProducto 		CHAR(4);
DEFINE cEstatus_cta 	CHAR(2);
DEFINE cMotivo 			CHAR(2);
DEFINE cCta_clabe 		CHAR(20);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);

DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE cBlokeo_abono	CHAR(1);
DEFINE cBlokeo_cargo	CHAR(1);
DEFINE cCod_retorno		CHAR(5);
DEFINE cCod_retorno2	CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cNum_cte		 	CHAR(20);

 
DEFINE cNumero_cliente  CHAR(20);  
DEFINE cNombre_producto CHAR(40); 
DEFINE cNumero_tarjeta  CHAR(20);
DEFINE cNombre_cliente  CHAR(150);


DEFINE cCodigo_retorno  CHAR(6);
DEFINE cMensaje_retorno   CHAR(80);
DEFINE cNumero_credito CHAR(20);  
DEFINE cCodigo_tipcred    CHAR(2);
DEFINE dtFecha_origen DATE;    
DEFINE dtFecha_prox_pago DATE;
DEFINE dPago_minimo DECIMAL(18,2);
DEFINE dtFecha_ult_pago DATE;  
DEFINE iPlazo INTEGER;  
DEFINE iPagos_realizados INTEGER;  
DEFINE dLinea_otorgada DECIMAL(18,2);
DEFINE dTasa_interes DECIMAL(9,6);
DEFINE dTasa_moratorios DECIMAL(9,6); 
DEFINE dMonto_sbc DECIMAL(14,2); 
DEFINE dCap_vig DECIMAL(18,2);
DEFINE dCap_trans DECIMAL(18,2);
DEFINE dCap_vdo_exig DECIMAL(18,2); 
DEFINE dCap_vdo_no_exig DECIMAL(18,2);
DEFINE dSdo_act_total_cap DECIMAL(18,2);
DEFINE dInt_vig DECIMAL(18,2); 
DEFINE dInt_vdo DECIMAL(18,2); 
DEFINE dInt_moratorios DECIMAL(18,2);
DEFINE dInt_mes DECIMAL(18,2);
DEFINE dSdo_act_total_int DECIMAL(18,2);
DEFINE dIva_int_vig DECIMAL(18,2); 
DEFINE dIva_int_vdo DECIMAL(18,2); 
DEFINE dIva_int_moratorios DECIMAL(18,2); 
DEFINE dIva_int_mes DECIMAL(18,2); 
DEFINE dSdo_act_total_iva DECIMAL(18,2); 
DEFINE dCom_pend DECIMAL(18,2); 
DEFINE dIva_com DECIMAL(18,2);
DEFINE dSdo_retenido DECIMAL(18,2);
DEFINE dTotal_liquidacion DECIMAL(18,2); 
DEFINE dInt_devengado DECIMAL(18,2);
DEFINE dIva_int_devengado DECIMAL(18,2);
DEFINE dLinea_disponible DECIMAL(18,2); 
DEFINE dPagos_vdos DECIMAL(18,2); 
DEFINE cDesc_status_cred CHAR(60);   
DEFINE iId_bloqueo_cred INTEGER ;  
DEFINE cBloqueo_cta CHAR(60);    
DEFINE cId_causa_bloqueo_cred CHAR(3); 
DEFINE cCausa_bloqueo_cta CHAR(50);  
DEFINE cId_sit_esp_cte CHAR(1);  
DEFINE iId_causa_esp_cte INTEGER ;    
DEFINE cSit_esp_cte CHAR(75); 
DEFINE cId_sit_esp_cred CHAR(1); 
DEFINE iId_causa_esp_cred INTEGER;   
DEFINE cSit_esp_cred CHAR(75); 

DEFINE cNumero_cta CHAR(20);
DEFINE cPrefijo_CtaBenef CHAR(10);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cOpcode = '';
LET cDescr_mensaje = '';
LET cDescr_completa_mensaje = '';
LET cCod_cuenta = '';
LET cCta_banco = '';
LET cApell_paterno = '';
LET cApell_materno = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET cSucursal = '';
LET cProducto = '';
LET cEstatus_cta = '';
LET cMotivo = '';
LET cCta_clabe = '';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_preceso = 'sp_ws_consultacta';
LET cBlokeo_abono = 'S';
LET cBlokeo_cargo = 'S';
LET cCod_retorno = '';
LET cCod_retorno2 = '';
LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;
LET cNum_cte = '';
LET vsMensaje = '';

LET cNumero_cliente   = '';
LET cNombre_producto  = '';
LET cNumero_tarjeta   = '';
LET cNombre_cliente  = '';


LET cCodigo_retorno = '';
LET cMensaje_retorno = '';
LET cNumero_credito = '';
LET cCodigo_tipcred = '';
LET dtFecha_origen  = DATE(1);
LET dtFecha_prox_pago = DATE(1);
LET dPago_minimo = 0;
LET dtFecha_ult_pago  = DATE(1);
LET iPlazo = 0;
LET iPagos_realizados = 0;
LET dLinea_otorgada = 0;
LET dTasa_interes = 0;
LET dTasa_moratorios = 0;
LET dMonto_sbc = 0;
LET dCap_vig = 0;
LET dCap_trans = 0;
LET dCap_vdo_exig = 0;
LET dCap_vdo_no_exig = 0;
LET dSdo_act_total_cap = 0;
LET dInt_vig = 0;
LET dInt_vdo = 0;
LET dInt_moratorios = 0;
LET dInt_mes = 0;
LET dSdo_act_total_int = 0;
LET dIva_int_vig = 0;
LET dIva_int_vdo = 0;
LET dIva_int_moratorios = 0;
LET dIva_int_mes = 0;
LET dSdo_act_total_iva = 0;
LET dCom_pend = 0;
LET dIva_com = 0;
LET dSdo_retenido = 0;
LET dTotal_liquidacion = 0;
LET dInt_devengado = 0;
LET dIva_int_devengado= 0;
LET dLinea_disponible = 0;
LET dPagos_vdos = 0;
LET cDesc_status_cred = '';
LET iId_bloqueo_cred = 0;
LET cBloqueo_cta = '';
LET cId_causa_bloqueo_cred = '';
LET cCausa_bloqueo_cta = '';
LET cId_sit_esp_cte = '';
LET iId_causa_esp_cte = 0;
LET cSit_esp_cte = '';
LET cId_sit_esp_cred = '';
LET iId_causa_esp_cred = 0;
LET cSit_esp_cred = '';

LET cNumero_cta = '';
let cPrefijo_CtaBenef = '';

    --SET DEBUG FILE TO '/informix/noe/sp_ws_consultacta.out';
    --TRACE ON;


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		
		
		IF iSqlErr <> 0 THEN
		
			SET DEBUG FILE TO '/tmp/sp_ws_consultacta.out';
			TRACE ON;												  
			LET cCod_err = iSqlErr;
			LET cOpcode = cCod_err;
			
			LET cDescr_mensaje = '';
			LET cDescr_completa_mensaje = '';
			
			--Se inserta el registro con el estado de la conexion hecha, con los dato0s generado0s en el proceso0 en curso, en caso de error de informix.
			INSERT INTO bdisac:"informix".sac_ws_ccta(cnxn_status,agent_trans_type_code,agent_cd,session_id,num_cta,tipo_cuenta,cod_pais,cod_estado,cod_agente_emi,usuario,terminal,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,cod_cuenta,fecha_proceso,hora_proceso,cta_banco,apell_paterno,apell_materno,nombre1,nombre2,sucursal,producto,estatus_cta,motivo,cta_clabe,user_insert,fecha_insert)
			VALUES('C',pcAgent_trans_type_code,pcAgent_cd,pcSession_id,pcNum_cta,pcTipo_cuenta,pcCod_pais,pcCod_estado,pcCod_agente_emi,pcUsuario_agnc,pcTerminal,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cCod_cuenta,cFecha_proceso,cHora_proceso,cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe,pcUsuario,CURRENT::DATE);
			
			--EPG
			--Se inserta el registro del proceso en curso con el numero de error generado por ON EXCEPTION
			INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,	fecha_proceso,	hora_proceso,	estatus,	cod_ret,	user_insert,	fecha_insert,	hora_insert)
			VALUES(cNombre_preceso,	pcFecha_peticion,	pcHora_peticion,	'0', 	LPAD(cCod_err,5,'0'),	pcUsuario,	current::date,	cHora_proceso);
			
			--VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0', LPAD(cCod_err,5,'0'),pcUsuario,current::date,cHora_proceso);
			--EPG
			
			--Se genera Alerta de SMS
			EXECUTE PROCEDURE  bdimnsj:"informix".sp_registra_evento_prod('1','PRO_ALERS','GRUPO_MANTO4_01','1','1','1','ERROR BD 10.36.197.','51 sp_registra_even','to_prod '|| iSqlErr  ||' '||iIsamError ,vsMensaje,'','','','','','','','','','1','1','1','1',date(current),date(current)) INTO cCod_retorno2;
			
			RETURN cCod_err,cOpcode,cDescr_mensaje,cCod_cuenta,cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe,cFecha_proceso,cHora_proceso;
		END IF;
			
		
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se valida que alguno de los parametros de entrada no venga nulo
	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' 
	OR NVL(pcSession_id, '') = '' OR NVL(pcNum_cta, '') = '' OR NVL(pcTipo_cuenta, '') = '' OR NVL(pcCod_pais, '') = ''
	OR NVL(pcCod_estado, '') = '' OR NVL(pcCod_agente_emi, '') = '' OR NVL(pcUsuario_agnc, '') = '' OR NVL(pcTerminal, '') = ''
	OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' THEN
		LET cCod_err = '9996';
	ELSE
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes		
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND activa = 'S') THEN
			
			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen,id_sesion_act::CHAR(30)
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd;
			
			LET cNumero_cta = SUBSTR(pcNum_cta, 1,6); 
			--IF cNumero_cta = '426807' OR cNumero_cta = '554948' OR cNumero_cta = '510148' THEN --se agrega BINES 510148 05oct17 NMR
			--	LET pcTipo_cuenta = '04';			
			--END IF;
			
			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
								IF LENGTH(TRIM(pcNum_cta)) = (CASE WHEN pcTipo_cuenta = '01' THEN 11 ELSE 
															  CASE WHEN pcTipo_cuenta = '03' THEN 16 ELSE
															 -- CASE WHEN pcTipo_cuenta = '04' THEN 16 ELSE
															 -- CASE WHEN pcTipo_cuenta = '06' THEN 12 ELSE
															  CASE WHEN pcTipo_cuenta = '40' THEN 18 END END END) THEN
															
									--Se saca la fecha del dia
									/*SELECT fecha_hoy
									INTO dtFecha_dia
									FROM bdisac:"informix".sac_fechas;*/
									
									LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');
									
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
										--	2013.01.21 I.
										--IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd) THEN
										IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND 
										fecha_insert = dtFecha_dia ) THEN										
										--	2013.01.21 F.
											IF EXISTS (SELECT tipo_cta FROM bdisac:"informix".sac_ws_ctasperm WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND tipo_cta = pcTipo_cuenta AND activa = 'S') THEN
												--Se consultan los dato0s personales del cliente
												IF pcTipo_cuenta = '01' THEN
													SELECT NVL(cheq.cuenta,''),NVL(clientes.apell_paterno,''),NVL(clientes.apell_materno,''),NVL(clientes.nombre1,''),NVL(clientes.nombre2,''),cheq.sucursal,cheq.producto,cheq.status_cta,NVL(cheq.motivo,''),cheq.cuenta_clabe
													INTO cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe
													FROM bdicheq:"informix".sc_maechq cheq, bdinteg:"informix".si_cliente clientes WHERE cuenta = pcNum_cta AND cheq.num_cte = clientes.numcte;													
												ELIF pcTipo_cuenta = '03' THEN
													SELECT NVL(cheq.cuenta,''),NVL(clientes.apell_paterno,''),NVL(clientes.apell_materno,''),NVL(clientes.nombre1,''),NVL(clientes.nombre2,''),cheq.sucursal,cheq.producto,cheq.status_cta,NVL(cheq.motivo,''),cheq.cuenta_clabe
													INTO cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe
													FROM bdicheq:"informix".sc_tarjeta tarj,bdicheq:"informix".sc_maechq cheq,bdinteg:"informix".si_cliente clientes
													WHERE tarj.num_tarjeta = pcNum_cta AND tarj.cuenta = cheq.cuenta AND cheq.num_cte = clientes.numcte;
												ELIF pcTipo_cuenta = '04' THEN
													 LET cNumero_cta = SUBSTR(pcNum_cta, 1,6); --VPR 09/03/16
													
														IF cNumero_cta = '426807' OR cNumero_cta = '554948' OR cNumero_cta = '510148'  THEN --se agrega BINES 510148 05oct17 NMR
																											
															EXECUTE PROCEDURE bdicred: "informix".sp_consulta_datos_general('001','','',pcNum_cta,'','','')
															INTO  cCodigo_retorno,cMensaje_retorno,cNumero_credito,cNumero_cliente ,cNombre_producto,cNumero_tarjeta,cNombre_cliente;
														END IF;		
														
														IF cCodigo_retorno = '000000' THEN
															SELECT NVL(cred.num_credito,''),NVL(clientes.apell_paterno,''),NVL(clientes.apell_materno,''),NVL(clientes.nombre1,''),NVL(clientes.nombre2,''),cred.sucursal,cred.num_producto
															INTO cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto
															FROM bdicred:"informix".sd_maecred cred,bdinteg:"informix".si_cliente clientes
															WHERE cred.num_credito = cNumero_credito AND cred.numcte = clientes.numcte;
																																							
															EXECUTE PROCEDURE bdicred: "informix".sp_consulta_saldos_general('001',cNumero_credito)
															INTO  cCodigo_retorno,cMensaje_retorno,cNumero_credito,cCodigo_tipcred,dtFecha_origen,dtFecha_prox_pago,dPago_minimo,
															dtFecha_ult_pago,iPlazo,iPagos_realizados,dLinea_otorgada,dTasa_interes,dTasa_moratorios,dMonto_sbc, dCap_vig,dCap_trans,
															dCap_vdo_exig,dCap_vdo_no_exig,dSdo_act_total_cap,dInt_vig,dInt_vdo,dInt_moratorios,dInt_mes,dSdo_act_total_int,
															dIva_int_vig,dIva_int_vdo,dIva_int_moratorios,dIva_int_mes,dSdo_act_total_iva,dCom_pend,dIva_com,dSdo_retenido,
															dTotal_liquidacion,dInt_devengado,dIva_int_devengado,dLinea_disponible,dPagos_vdos,cDesc_status_cred,iId_bloqueo_cred,
															cBloqueo_cta,cId_causa_bloqueo_cred,cCausa_bloqueo_cta,cId_sit_esp_cte,iId_causa_esp_cte,cSit_esp_cte,cId_sit_esp_cred,
															iId_causa_esp_cred,cSit_esp_cred;
															
															IF cCodigo_retorno = '000000' THEN
																--SELECT {+INDEX(sd_tipocartera,idx01_descripcion)} status_cred INTO cEstatus_cta
																SELECT status_cred INTO cEstatus_cta --se elimina directiva a peticion de DB CC45605
																FROM bdicred:"informix".sd_tipocartera
																WHERE descripcion = cDesc_status_cred;
															END IF;
														END IF
											
													ELIF pcTipo_cuenta = '06' THEN
														LET cPrefijo_CtaBenef = SUBSTR(pcNum_cta, 1,2); --VPR 09/03/16
															
														IF  cPrefijo_CtaBenef = '60' OR cPrefijo_CtaBenef = '61' OR cPrefijo_CtaBenef = '66' OR cPrefijo_CtaBenef = '70' OR cPrefijo_CtaBenef = '63' OR cPrefijo_CtaBenef = '64' OR cPrefijo_CtaBenef = '76' OR cPrefijo_CtaBenef = '77' OR cPrefijo_CtaBenef = '81' THEN --se agrega Prefijo 81 05oct17 NMR
															IF cPrefijo_CtaBenef = '61' OR cPrefijo_CtaBenef = '63' OR cPrefijo_CtaBenef = '64' OR cPrefijo_CtaBenef = '76' OR cPrefijo_CtaBenef = '77' THEN
																SELECT NVL(crd.num_credito,''),NVL(clientes.apell_paterno,''),NVL(clientes.apell_materno,''),NVL(clientes.nombre1,''),NVL(clientes.nombre2,''),crd.sucursal,crd.num_producto
																INTO cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto
																FROM bdicred:"informix".sd_maecredcrd crd,bdinteg:"informix".si_cliente clientes
																WHERE crd.num_credito = pcNum_cta AND crd.numcte = clientes.numcte;
															 ELSE
																SELECT NVL(cred.num_credito,''),NVL(clientes.apell_paterno,''),NVL(clientes.apell_materno,''),NVL(clientes.nombre1,''),NVL(clientes.nombre2,''),cred.sucursal,cred.num_producto
																INTO cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto
																FROM bdicred:"informix".sd_maecred cred,bdinteg:"informix".si_cliente clientes
																WHERE cred.num_credito = pcNum_cta AND cred.numcte = clientes.numcte;
															END IF;
														
															EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001',pcNum_cta)
															INTO  cCodigo_retorno,cMensaje_retorno,cNumero_credito,cCodigo_tipcred,dtFecha_origen,dtFecha_prox_pago,dPago_minimo,
															dtFecha_ult_pago,iPlazo,iPagos_realizados,dLinea_otorgada,dTasa_interes,dTasa_moratorios,dMonto_sbc, dCap_vig,dCap_trans,
															dCap_vdo_exig,dCap_vdo_no_exig,dSdo_act_total_cap,dInt_vig,dInt_vdo,dInt_moratorios,dInt_mes,dSdo_act_total_int,
															dIva_int_vig,dIva_int_vdo,dIva_int_moratorios,dIva_int_mes,dSdo_act_total_iva,dCom_pend,dIva_com,dSdo_retenido,
															dTotal_liquidacion,dInt_devengado,dIva_int_devengado,dLinea_disponible,dPagos_vdos,cDesc_status_cred,iId_bloqueo_cred,
															cBloqueo_cta,cId_causa_bloqueo_cred,cCausa_bloqueo_cta,cId_sit_esp_cte,iId_causa_esp_cte,cSit_esp_cte,cId_sit_esp_cred,
															iId_causa_esp_cred,cSit_esp_cred;  															
														END IF;
														
														IF cCodigo_retorno = '000000' THEN
															--SELECT {+INDEX(sd_tipocartera,idx01_descripcion)} status_cred INTO cEstatus_cta
															SELECT status_cred INTO cEstatus_cta --se elimina directiva a peticion de DB CC45605
															FROM bdicred:"informix".sd_tipocartera
															WHERE descripcion = cDesc_status_cred;
														END IF;
													
												ELIF pcTipo_cuenta = '40' THEN
													SELECT NVL(cuenta,''),sucursal,producto,NVL(num_cte,''),status_cta,NVL(motivo,''),cuenta_clabe
													INTO cCta_banco,cSucursal,cProducto,cNum_cte,cEstatus_cta,cMotivo,cCta_clabe
													FROM bdicheq:"informix".sc_maechq
													WHERE empresa = '001' AND cuenta_clabe = pcNum_cta;
													
													SELECT NVL(apell_paterno,''),NVL(apell_materno,''),NVL(nombre1,''),NVL(nombre2,'')													
													INTO cApell_paterno,cApell_materno,cNombre1,cNombre2
													FROM bdinteg:"informix".si_cliente
													WHERE empresa = '001' AND numcte = cNum_cte;
												END IF;
												
												--cta cruz roja mexicana
												IF cCta_banco = '12000002648' THEN
													SELECT NVL(SUBSTR(clientes.razon_social,1,10),''),NVL(SUBSTR(clientes.razon_social,11,8),'')
													INTO cNombre1,cApell_paterno
													FROM bdicheq:"informix".sc_maechq cheq, bdinteg:"informix".si_cliente clientes WHERE cuenta = '12000002648' AND cheq.num_cte = clientes.numcte;																								
												END IF;
												

												IF pcTipo_cuenta IN('01','03','40') THEN
													IF EXISTS(SELECT codigo FROM bdicheq:"informix".sc_bloqueo WHERE codigo = cMotivo) THEN
														SELECT abono, cargo
														INTO cBlokeo_abono,cBlokeo_cargo ----------------------------------VARIABLES INICIALIZADAS EN 'S'
														FROM bdicheq:"informix".sc_bloqueo WHERE codigo = cMotivo;
													END IF;
														
													IF cEstatus_cta in('1','3','4') AND cBlokeo_abono = 'S' THEN
														LET cCod_cuenta = 'CR';
													ELIF cCta_banco IS NULL OR cCta_banco = '' THEN
														LET cCod_cuenta = 'CI';
													ELIF cEstatus_cta in('2', '5', '6', '7', '8') THEN --motivos 05, 08, 10, 13 y 14
														LET cCod_cuenta = 'CC';
													ELIF cEstatus_cta = '3' AND cBlokeo_abono = 'N' THEN --04 y 09
														LET cCod_cuenta = 'NA';
													ELIF cEstatus_cta = '3' AND cBlokeo_cargo = 'N' THEN --los motivos 01, 02, 03, 06, 07, no llegara a esta validacion
														LET cCod_cuenta = 'NC';													
													END IF;
													--  2013.02.25 I. Se agrega validaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n para no enviar como CR las cuentas de inversiÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n.
													--  2013.02.25 F.
													IF cProducto = '1100' THEN
														LET cCod_cuenta = 'CI';
													END IF;
													
												ELSE
													IF  cEstatus_cta = 'AA' OR cEstatus_cta ='BT' OR cEstatus_cta ='BA' OR cEstatus_cta	= 'VP' OR cEstatus_cta = 'E1' OR cEstatus_cta = 'E2' OR cEstatus_cta = 'E3' THEN --VPR 10/03/2016		--IFRS 
														LET cCod_cuenta = 'CR';
													ELIF cEstatus_cta = 'FF' OR cEstatus_cta ='FC' OR cEstatus_cta ='FI' OR  cEstatus_cta= 'CV' THEN
														LET cCod_cuenta = 'CC';
													ELIF cEstatus_cta IS NULL OR cEstatus_cta = '' THEN
														LET cCod_cuenta = 'CI';														
													END IF;	
													
													IF iId_bloqueo_cred = '2' OR iId_bloqueo_cred = '4' THEN
														LET cCod_cuenta = 'CB';
													END IF;
												END IF;
												
												--Se obtienen los mensajes de error asi como el codigo del mensaje
												SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
												INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje 
												FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCod_err;
												IF cOpcode IS NULL THEN
													LET cOpcode = cCod_err;
													LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
													LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
												END IF;
                                                
												--se agrega para los productos que no deben recibir remesas BTS
                                                IF cProducto in ('8500') and trim(pcAgent_cd) in('BTS','APR') THEN 
                                                    LET cCod_cuenta = 'CI';
                                                END IF;

												IF cCod_cuenta <> 'CR' THEN												
													LET cCta_banco = '';
													LET cApell_paterno = '';
													LET cApell_materno = '';
													LET cNombre1 = '';
													LET cNombre2 = '';
													LET cSucursal = '';
													LET cProducto = '';
													LET cEstatus_cta = '';
													LET cMotivo = '';
													LET cCta_clabe = '';
												END IF;
												
												--Se inserta el registro con el estado de la conexion hecha, con los dato0s generado0s en el proceso0
												INSERT INTO bdisac:"informix".sac_ws_ccta(cnxn_status,agent_trans_type_code,agent_cd,session_id,num_cta,tipo_cuenta,cod_pais,cod_estado,cod_agente_emi,usuario,terminal,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,cod_cuenta,fecha_proceso,hora_proceso,cta_banco,apell_paterno,apell_materno,nombre1,nombre2,sucursal,producto,estatus_cta,motivo,cta_clabe,user_insert,fecha_insert)
												VALUES('A',pcAgent_trans_type_code,pcAgent_cd,pcSession_id,pcNum_cta,pcTipo_cuenta,pcCod_pais,pcCod_estado,pcCod_agente_emi,pcUsuario_agnc,pcTerminal,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cCod_cuenta,cFecha_proceso,cHora_proceso,cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe,pcUsuario,CURRENT::DATE);
												
											ELSE
												LET cCod_err = '9994';
											END IF;											
										ELSE
											LET cCod_err = '9975';
										END IF;
									ELSE
										LET cCod_err = '9977';
									END IF;
								ELSE
									LET cCod_err = '9995';
								END IF;
							ELSE
								LET cCod_err = '9975';
							END IF;
						ELSE
							LET cCod_err = '9976';
						END IF;
					ELSE
						LET cCod_err = '9978';
					END IF;
				ELSE
					LET cCod_err = '9979';
				END IF;
			ELSE
				LET cCod_err = '9998';
			END IF;
		ELSE
			LET cCod_err = '9999';
		END IF;
	END IF;
	
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje 
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCod_err;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		
		--Se inserta el registro con el estado de la conexion hecha, con los dato0s del erro0r generado0 en el proceso0
		INSERT INTO bdisac:"informix".sac_ws_ccta(cnxn_status,agent_trans_type_code,agent_cd,session_id,num_cta,tipo_cuenta,cod_pais,cod_estado,cod_agente_emi,usuario,terminal,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,cod_cuenta,fecha_proceso,hora_proceso,cta_banco,apell_paterno,apell_materno,nombre1,nombre2,sucursal,producto,estatus_cta,motivo,cta_clabe,user_insert,fecha_insert)
		VALUES('C',pcAgent_trans_type_code,pcAgent_cd,pcSession_id,pcNum_cta,pcTipo_cuenta,pcCod_pais,pcCod_estado,pcCod_agente_emi,pcUsuario_agnc,pcTerminal,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cCod_cuenta,cFecha_proceso,cHora_proceso,cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe,pcUsuario,CURRENT::DATE);
		
		--EPG
		--Se inserta el registro del proceso en curso con el numero de error generado controlado
		INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'2', LPAD(cCod_err,5,'0'),pcUsuario,current::date,cHora_proceso);
		--EPG

	END IF;
	
	RETURN LPAD(cCod_err,5,'0'),cOpcode,cDescr_mensaje,cCod_cuenta,cCta_banco,cApell_paterno,cApell_materno,cNombre1,cNombre2,cSucursal,cProducto,cEstatus_cta,cMotivo,cCta_clabe,cFecha_proceso,cHora_proceso;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para consultar los datos de las cuentas de los clientes ya sea por cuenta,tarjeta,numero de credito o cuenta clave',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 31 de Octubre 2012',
'VERSION: 1.0',
'DESCRIPCION: Se modifica SP para validar que el Id de sesion sea del dia.',
'AUTOR : FRG',
'FECHA : 21 de Enero 2013',
'VERSION: 1.1',
'DESCRIPCION: Se modifica SP para no dar como CR cuentas de inversion (1100).',
'AUTOR : FRG',
'FECHA : 25 de Febrero 2013',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios',
'DESCRIPCION: Se modifica sp para consultar los datos del cliente dependiendo si son de tipo 4 o 6 ',
			  'y obtener el estatus del cte',
'FOLIO: 32-PagoBTSAbnoAutCtasCred ',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 10/03/2016',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_reporteremesascomision()

	RETURNING
		CHAR	(25) as archivo,
		CHAR	(5) as codret,
		CHAR	(100) as mensaje;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE sCommit			SMALLINT;
	DEFINE cProceso			CHAR(100);
	DEFINE dFechaIni		DATE;
	DEFINE dFechaFin		DATE;
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);
	DEFINE cRuta			CHAR(50);
	DEFINE cNombreArchivo	CHAR(50);
	DEFINE cSQL 			CHAR(1200);
	DEFINE v_nombre_sucursal1 CHAR(100);
	DEFINE v_id_sucursal1	CHAR (5);
	DEFINE contador1	INTEGER;
	DEFINE contador2	INTEGER;
	
	-- DECLARACION DE VARIABLES PARA EL REPORTE
	DEFINE cFechaIni		DATE;
	DEFINE cFechaFin		DATE;
	DEFINE cid_suc			CHAR(4);
	DEFINE vId_suc			CHAR(4);
	DEFINE cnum_BTS 		INTEGER;
	DEFINE cmto_BTS 		MONEY(16,2);
	DEFINE ccomis_BTS 		MONEY(16,2);
	DEFINE cpago_efec_BTS 	INTEGER;
	DEFINE cpago_abono_BTS 	INTEGER;
	DEFINE cnum_WU 			INTEGER;
	DEFINE cmto_WU 			MONEY(16,2);
	DEFINE ccomis_WU 		MONEY(16,2);
	DEFINE cpago_efec_WU 	INTEGER;
	DEFINE cpago_abono_WU 	INTEGER;
	DEFINE cnum_OV 			INTEGER;
	DEFINE cmto_OV 			MONEY(16,2);
	DEFINE ccomis_OV 		MONEY(16,2);
	DEFINE cpago_efec_OV 	INTEGER;
	DEFINE cpago_abono_OV 	INTEGER;
	DEFINE cnum_VG 			INTEGER;
	DEFINE cmto_VG 			MONEY(16,2);
	DEFINE ccomis_VG 		MONEY(16,2);
	DEFINE cpago_efec_VG 	INTEGER;
	DEFINE cpago_abono_VG 	INTEGER;
	DEFINE cnum_APP 		INTEGER;
	DEFINE cmto_APP 		MONEY(16,2);
	DEFINE ccomis_APP 		MONEY(16,2);
	DEFINE cpago_efec_APP 	INTEGER;
	DEFINE cpago_abono_APP INTEGER;
	DEFINE cnum_TOT 		INTEGER;
	DEFINE cmto_TOT 		MONEY(16,2);
	DEFINE ccomis_TOT 		MONEY(16,2);
	DEFINE cpago_efec_TOT 		INTEGER;
	DEFINE cpago_abono_TOT 		INTEGER;
	DEFINE cAnioMesAct		CHAR(6);
	

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'Genera Reporte Remesas Comision';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'repremesascom_';
	LET cSQL = '';
	LET sCommit = 0;
    LET v_nombre_sucursal1='';
    LET v_id_sucursal1='';
	LET contador1=0;
	LET contador2=0;

	-- INICIALIZAN LAS VARIABLES DE REPORTE
	LET cFechaIni = '';
	LET cFechaFin = '';
	LET cid_suc	= '';
	LET vId_suc	= '';
	LET cnum_BTS = 0; 	
	LET cmto_BTS = 0;
	LET ccomis_BTS = 0;
	LET cpago_efec_BTS = 0;
	LET cpago_abono_BTS = 0;
	LET cnum_WU = 0;		
	LET cmto_WU = 0;		
	LET ccomis_WU = 0;	
	LET cpago_efec_WU = 0;
	LET cpago_abono_WU = 0;
	LET cnum_OV = 0;		
	LET cmto_OV = 0;		
	LET ccomis_OV = 0;	
	LET cpago_efec_OV = 0;
	LET cpago_abono_OV = 0;
	LET cnum_VG = 0;		
	LET cmto_VG = 0;		
	LET ccomis_VG = 0;	
	LET cpago_efec_VG = 0;
	LET cpago_abono_VG = 0;
	LET cnum_APP = 0;	
	LET cmto_APP = 0;	
	LET ccomis_APP = 0;	
	LET cpago_efec_APP = 0;
	LET cpago_abono_APP = 0;
	LET cnum_TOT = 0;	
	LET cmto_TOT = 0;	
	LET ccomis_TOT = 0;	
	LET cpago_efec_TOT = 0;
	LET cpago_abono_TOT = 0;
	LET cAnioMesAct ='';
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';
			INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
			VALUES (cProceso, CURRENT, CURRENT, cCodRet, cVarError);

			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/nmr/remesas/repremesascom_.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- BORRAMOS TABLAS PARA GENERAR UN NUEVO REPORTE
	DROP TABLE IF EXISTS tmp_folio_suc;
	DROP TABLE IF EXISTS tmp_movimientos;
	DROP TABLE IF EXISTS tmp_cheques;
	
	
--OBTIENE LOS DIAS INICIO Y FIN DEL MES ANTERIOR
		SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -2)) + 1) inicio, date(LAST_DAY(ADD_MONTHS(today, -1))) fin, TO_CHAR(TODAY-1 UNITS MONTH, '%m%Y') mesanio
		INTO cFechaIni, cFechaFin, cAnioMesAct
		FROM systables WHERE tabid = 1;

		--LET cFechaIni=mdy(1,1,2024);
		--LET cFechaFin=mdy(1,10,2024);


--BORRA TABLA FISICA
		DROP INDEX IF EXISTS "informix".idx_reportcomision_id_suc;
		TRUNCATE TABLE "informix".sac_reportcom_rem;

		
-- IDENTIFICAMOS LOS NUMEROS DE FOLIO_SUC DE TODAS LAS REMESAS
	SELECT  DISTINCT (folio_suc) 
		FROM  sac_movimientoshistorial
		WHERE ((numcategoria = '07' and numconvenio='004') 
		or (numcategoria = '07' and numconvenio='006')
		or (numcategoria = '07' and numconvenio='007')
		or (numcategoria = '07' and numconvenio='008')
		or (numcategoria = '07' and numconvenio='009'))
		AND flag_confirmacion_central= 1
		AND flag_confirmacion_sucursal= 1
		AND fecha_pago >= cFechaIni
		AND fecha_pago <= cFechaFin
		AND status_cancelado <> 'S'
		INTO TEMP tmp_folio_suc WITH NO LOG;

	
--INDICE PARA TABLE TEMPORAL DE FOLIO_SUC
	EXECUTE IMMEDIATE 'CREATE INDEX idx_temp_folio_id_suc ON tmp_folio_suc(folio_suc)';
	
-- OBTENEMOS LOS DATOS DE LA TABLA SAC_MOVIMIENTOSHISTORIAL
	SELECT  sac.id_sucursal,sac.folio_suc,sac.numcategoria,sac.numconvenio,sac.forma_pago,sac.importe_pago,sac.importe_comision_convenio,sac.fecha_pago
		FROM sac_movimientoshistorial sac,tmp_folio_suc tempsac
		WHERE tempsac.folio_suc = sac.folio_suc
		and ((numcategoria = '07' and numconvenio='004') 
		or (numcategoria = '07' and numconvenio='006')
		or (numcategoria = '07' and numconvenio='007')
		or (numcategoria = '07' and numconvenio='008')
		or (numcategoria = '07' and numconvenio='009'))
		AND flag_confirmacion_central= 1
		AND flag_confirmacion_sucursal= 1
		AND fecha_pago >= cFechaIni
		AND fecha_pago <= cFechaFin
		AND status_cancelado <> 'S'
		INTO TEMP tmp_movimientos WITH NO LOG;

--INDICE PARA TABLE TEMPORAL DE MOVIMIENTOS
	EXECUTE IMMEDIATE 'CREATE INDEX idx_temp_movtos_id_suc ON tmp_movimientos(folio_suc, id_sucursal)';
	

-- OBTENEMOS LOS DATOS DE LA TABLA SC_MOVHIS_OLD
	SELECT  tempsac.folio_suc 
		FROM bdicheq:"informix".sc_movhis_old mvold,tmp_folio_suc tempsac
		WHERE tempsac.folio_suc = mvold.folio_suc
		AND fech_alt >= cFechaIni
		AND fech_alt <= cFechaFin
		AND transacc IN ('1110','1140','1121','1151','1122','1152','1123','1153','1325','1355')
		AND empresa = '001'
		AND cancelad <> 'S'
	INTO temp tmp_cheques WITH NO LOG;
	

---COMPLEMENTO DE SC_MOVHIS
	INSERT INTO tmp_cheques
    SELECT tempsac.folio_suc
        FROM bdicheq:sc_movhis mv,tmp_folio_suc tempsac
        WHERE  tempsac.folio_suc = mv.folio_suc
        AND fech_alt >= cFechaIni
        AND fech_alt <= cFechaFin
        AND transacc IN ('1110','1140','1121','1151','1122','1152','1123','1153','1325','1355')
        AND empresa = '001'
        AND cancelad <> 'S';

--INDICE PARA TABLE TEMPORAL DE CHEQUES
	EXECUTE IMMEDIATE  'CREATE INDEX idx_tmp_cheques_folio_suc ON tmp_cheques(folio_suc)';

	
--SE LLENAN LOS DATOS DE SUCURSALES EN LA TABLA DEL REPORTE
BEGIN;
FOREACH insertcursor2 WITH HOLD FOR
		SELECT {+INDEX(bdinteg:"informix".si_sucursales idx_sucursal)+INDEX(bdisac:"informix".tmp_cheques idx_tmp_cheques_folio_suc)} DISTINCT REPLACE(REPLACE(REPLACE(REPLACE(S.nombre,"\","-"),"."," "),","," "),"/","-") AS nombre_sucursal,M.id_sucursal 
		INTO v_nombre_sucursal1, v_id_sucursal1	
		FROM tmp_movimientos M, bdinteg:si_sucursales S, tmp_cheques C
		WHERE M.folio_suc= C.folio_suc
		AND M.id_sucursal=S.sucursal
	ORDER BY 2 ASC

	INSERT INTO "informix".sac_reportcom_rem (nombre_sucursal,id_sucursal)
	VALUES (v_nombre_sucursal1, v_id_sucursal1);
	LET contador1=contador1+1;
	IF contador1 >= 1000 THEN 
		COMMIT WORK;
		BEGIN WORK;
		LET contador1=0;
	END IF;

END FOREACH;

COMMIT WORK;

--INDICE PARA TABLA FISICA FINAL
	BEGIN;
	CREATE INDEX "informix".idx_reportcomision_id_suc
	    ON "informix".sac_reportcom_rem(id_sucursal) ONLINE;
	COMMIT;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_reportcom_rem;
	
	
	BEGIN WORK;
	FOREACH vCursor WITH HOLD FOR SELECT {+INDEX(bdisac:"informix".sac_reportcom_rem idx_reportcomision_id_suc)}id_sucursal INTO vId_suc FROM "informix".sac_reportcom_rem 
		
		SELECT  {+INDEX(bdisac:"informix".tmp_movimientos idx_temp_movtos_id_suc)}a.id_sucursal, 
				sum(case when numconvenio='004' then 1 else 0 end) as num_trans_BTS,
			    sum(case when numconvenio='004' then importe_pago else 0 end) as mto_trans_BTS,
			    sum(case when numconvenio='004' then 0 else 0 end) as comision_BTS, -- se elimina importe_comision_convenio para enviar comision CERO
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='004' THEN 1 ELSE 0 END) efe_bts, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='004' THEN 1 ELSE 0 END) abo_bts,

			    sum(case when numconvenio='006' then 1 else 0 end) as num_trans_WU,
			    sum(case when numconvenio='006' then importe_pago else 0 end) as mto_trans_WU,
			    sum(case when numconvenio='006' then 0 else 0 end) as comision_WU, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='006' THEN 1 ELSE 0 END) efe_WU, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='006' THEN 1 ELSE 0 END) abo_WU,

			    sum(case when numconvenio='007' then 1 else 0 end) as num_trans_OV,
			    sum(case when numconvenio='007' then importe_pago else 0 end) as mto_trans_OV,
			    sum(case when numconvenio='007' then 0 else 0 end) as comision_OV, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='007' THEN 1 ELSE 0 END) efe_OV, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='007' THEN 1 ELSE 0 END) abo_OV,

			    sum(case when numconvenio='008' then 1 else 0 end) as num_trans_VG,
			    sum(case when numconvenio='008' then importe_pago else 0 end) as mto_trans_VG,
			    sum(case when numconvenio='008' then 0 else 0 end) as comision_VG, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='008' THEN 1 ELSE 0 END) efe_VG, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='008' THEN 1 ELSE 0 END) abo_VG,

			    sum(case when numconvenio='009' then 1 else 0 end) as num_trans_APP,
			    sum(case when numconvenio='009' then importe_pago else 0 end) as mto_trans_APP,
			    sum(case when numconvenio='009' then 0 else 0 end) as comision_APP, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='009' THEN 1 ELSE 0 END) efe_APP, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='009' THEN 1 ELSE 0 END) abo_APP
	     INTO cid_suc, cnum_BTS, cmto_BTS, ccomis_BTS, cpago_efec_BTS, cpago_abono_BTS, --REMESA BTS
	     			cnum_WU, cmto_WU, ccomis_WU, cpago_efec_WU, cpago_abono_WU, --REMESA WESTERN UNION (WU)	
	     			cnum_OV, cmto_OV, ccomis_OV, cpago_efec_OV, cpago_abono_OV, --REMESA ORLANDI VALUTA (OV)
	     			cnum_VG, cmto_VG, ccomis_VG, cpago_efec_VG, cpago_abono_VG, --REMESA VIGO (VG)
	     			cnum_APP, cmto_APP, ccomis_APP, cpago_efec_APP, cpago_abono_APP --REMESA APPRIZA (APP)	
		 FROM tmp_movimientos a, tmp_cheques b 
	        WHERE a.folio_suc= b.folio_suc 
			and a.id_sucursal= vId_suc
	        group by 1;
	    

	    LET cnum_BTS=nvl(cnum_BTS,0);
		LET cmto_BTS=nvl(cmto_BTS,0);
		LET ccomis_BTS=nvl(ccomis_BTS,0);
		LET cpago_efec_BTS=nvl(cpago_efec_BTS,0);
		LET cpago_abono_BTS=nvl(cpago_abono_BTS,0);
				
	    LET cnum_WU=nvl(cnum_WU,0);
		LET cmto_WU=nvl(cmto_WU,0);
		LET ccomis_WU=nvl(ccomis_WU,0);
		LET cpago_efec_WU=nvl(cpago_efec_WU,0);
		LET cpago_abono_WU=nvl(cpago_abono_WU,0);

	    LET cnum_OV=nvl(cnum_OV,0);
		LET cmto_OV=nvl(cmto_OV,0);
		LET ccomis_OV=nvl(ccomis_OV,0);
		LET cpago_efec_OV=nvl(cpago_efec_OV,0);
		LET cpago_abono_OV=nvl(cpago_abono_OV,0);
					
	    LET cnum_VG=nvl(cnum_VG,0);
		LET cmto_VG=nvl(cmto_VG,0);
		LET ccomis_VG=nvl(ccomis_VG,0);
		LET cpago_efec_VG=nvl(cpago_efec_VG,0);
		LET cpago_abono_VG=nvl(cpago_abono_VG,0);
				
	    LET cnum_APP=nvl(cnum_APP,0);
		LET cmto_APP=nvl(cmto_APP,0);
		LET ccomis_APP=nvl(ccomis_APP,0);
		LET cpago_efec_APP=nvl(cpago_efec_APP,0);
		LET cpago_abono_APP=nvl(cpago_abono_APP,0);
				
		
--SUMA DE NUMERO DE PAGOS EN TRANSACCION	
		LET cnum_TOT = nvl(cnum_BTS,0) + nvl(cnum_WU,0) + nvl(cnum_OV,0) + nvl(cnum_VG,0) + nvl(cnum_APP,0);
		LET cmto_TOT =  nvl(cmto_BTS,0) + nvl(cmto_WU,0) + nvl(cmto_OV,0) + nvl(cmto_VG,0) + nvl(cmto_APP,0);
		LET ccomis_TOT = nvl(ccomis_BTS,0) + nvl(ccomis_WU,0) + nvl(ccomis_OV,0) + nvl(ccomis_VG,0) + nvl(ccomis_APP,0);

		
--SUMA DE NUMERO DE PAGOS EN EFECTIVO Y ABONO
		LET cpago_efec_TOT = nvl(cpago_efec_BTS,0) + nvl(cpago_efec_WU,0) + nvl(cpago_efec_OV,0) + nvl(cpago_efec_VG,0) + nvl(cpago_efec_APP,0);
		LET cpago_abono_TOT = nvl(cpago_abono_BTS,0) + nvl(cpago_abono_WU,0) + nvl(cpago_abono_OV,0) + nvl(cpago_abono_VG,0) + nvl(cpago_abono_APP,0);
		
--		BEGIN WORK;

		UPDATE "informix".sac_reportcom_rem SET num_trans_BTS = cnum_BTS, mto_trans_BTS = cmto_BTS, comision_BTS = ccomis_BTS, pago_efec_BTS = cpago_efec_BTS, pago_abono_BTS = cpago_abono_BTS,
									num_trans_WU=cnum_WU, mto_trans_WU=cmto_WU, comision_WU= ccomis_WU, pago_efec_WU=cpago_efec_WU, pago_abono_WU=cpago_abono_WU,
									num_trans_OV = cnum_OV,mto_trans_OV = cmto_OV, comision_OV =  ccomis_OV, pago_efec_OV = cpago_efec_OV, pago_abono_OV = cpago_abono_OV,
									num_trans_VG = cnum_VG, mto_trans_VG = cmto_VG, comision_VG =  ccomis_VG, pago_efec_VG = cpago_efec_VG, pago_abono_VG = cpago_abono_VG,
									num_trans_APP = cnum_APP,mto_trans_APP = cmto_APP, comision_APP =  ccomis_APP, pago_efec_APP = cpago_efec_APP, pago_abono_APP = cpago_abono_APP,
									num_trans_remtot = cnum_TOT, mto_trans_remtot = cmto_TOT, comision_remtot =  ccomis_TOT, pago_efectivo_TOT = cpago_efec_TOT, pago_abono_TOT = cpago_abono_TOT
								WHERE CURRENT OF vCursor;
		LET contador2 =contador2+1;
		IF contador2>= 1000 THEN 
			COMMIT WORK;
			BEGIN WORK;
			LET contador2=0;
		END IF;
		

	END FOREACH;
	
	COMMIT WORK;
	
	
--NOMBRE DEL ARCHIVO
	LET cRuta = "/RESPALDOSNEW/"; 
	LET cNombreArchivo = 'repremesascom_' || cAnioMesAct || '.csv';
	
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' DELIMITER ' || ''',''' || ' SELECT * FROM "informix".sac_reportcom_rem union select '' IDsuc'' id_sucursal,'' nombre_sucursal'','' num_trans_bts'','' mto_trans_bts'','' comision_bts'','' pago_efec_bts'','' pago_abono_bts'','' num_trans_wu'','' mto_trans_wu'','' comision_wu'','' pago_efec_wu'','' pago_abono_wu'','' num_trans_ov'','' mto_trans_ov'','' comision_ov'','' pago_efec_ov'','' pago_abono_ov'','' num_trans_vg'','' mto_trans_vg'','' comision_vg'','' pago_efec_vg'','' pago_abono_vg'','' num_trans_app'','' mto_trans_app'','' comision_app'','' pago_efec_app'','' pago_abono_app'','' num_trans_remtot'','' mto_trans_remtot'','' comision_remtot'','' pago_efectivo_tot'','' pago_abono_tot'' FROM sac_fechas order by id_sucursal asc;" >' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;

--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'remesas_comision.sql' ;

	LET cSQL='dbaccess bdisac ' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;

--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	
--BORRAMOS TABLAS PARA GENERAR UN NUEVO REPORTE
	DROP TABLE IF EXISTS tmp_folio_suc;
	DROP TABLE IF EXISTS tmp_movimientos;
	DROP TABLE IF EXISTS tmp_cheques;


--INSERTAMOS EL REGISTRO DE LA EJECUCION DEL PROCESO
	INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
	VALUES (cNombreArchivo, cFechaIni, cFechaFin, cCodRet, cVarError);


	RETURN cNombreArchivo, cCodRet, cVarError;

END;
END PROCEDURE;