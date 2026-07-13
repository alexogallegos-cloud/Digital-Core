CREATE PROCEDURE "informix".sp_bts_obtieneinfoidentificacion(pTipoEjec CHAR(1), pCodTipoIdent CHAR(3))
RETURNING
	CHAR(6)  		AS  COD_RET,
	VARCHAR(80) 	AS  MENS_RET,
	CHAR(3)  		AS  COD_IDENTIFICACION,
	CHAR(3) 		AS  DESC_IDENTIFICACION;

--DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE vMensajeRet      VARCHAR(80);
DEFINE cCodTipoIdentificacion          CHAR(3);
DEFINE cDescTipoIdentificacion     CHAR(3);

--INICIALIZACIONES
LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET vMensajeRet        = "SE REALIZO LA CONSULTA CORRECTAMENTE";
LET cCodTipoIdentificacion            = "";
LET cDescTipoIdentificacion       = "";

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensajeRet = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(vMensajeRet),'','';
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/tmp/sp_bts_obtieneinfoidentificacion.out';
		--TRACE ON;

	IF pTipoEjec = "1" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH
			SELECT DISTINCT id_issuer_cd
			INTO  cDescTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;
		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;
		
	ELIF pTipoEjec = "2" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH
			SELECT id_type_cd
			INTO  cCodTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1
			AND id_issuer_cd = pCodTipoIdent

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;
		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;

	ELIF pTipoEjec = "3" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH

			SELECT id_type_cd, id_issuer_cd
			INTO  cCodTipoIdentificacion, cDescTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;

		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;
	END IF
		
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION : Se realiza procedimiento para Obtener el listado de Sucursales',
'AUTOR : Jesus Aguilar',
'FECHA : 05/septiembre/2012',
'BD    : BDISAC',
'DESCRIPCION MODIFICACION: Se modifica para que se ejecute en 3 tipos de consulta para el codigo y tipo de identificacion',
'MODIFICO : Mohamed Carreon',
'VERSION:20121011.1207';

CREATE PROCEDURE "informix".sp_bts_recuperacdep(pcUsuario CHAR(8), piRegs_recup INTEGER, pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6))
	RETURNING CHAR(5),CHAR(11),CHAR(4),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cConfirmation_nm CHAR(11);
DEFINE cOpcode_cdep 	CHAR(4);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cCadena_ent		CHAR(100);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cCod_retorno		CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cValor			CHAR(100);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cConfirmation_nm = '';
LET cOpcode_cdep = '0000';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cNombre_preceso = 'sp_bts_recuperacdep';
LET cCadena_ent = 	NVL(piRegs_recup,0) || '|' || TRIM(NVL(pcFecha_peticion,'NULL')) || '|' || TRIM(NVL(pcHora_peticion,'NULL'));
LET cOpcode 		= '';
LET cDescr_mensaje 	= '';
LET cCod_retorno 	= '';
LET cValor	 		= '';

LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;

--SET DEBUG FILE TO '/tmp/RMBTS/sp_bts_recuperacdep.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
			RETURN cCod_err,cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);
	
	IF piRegs_recup > 0 THEN

		SELECT NVL(valor,'0')
			INTO cValor
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87013';	
			
			FOREACH
				SELECT LIMIT piRegs_recup num_confirmacion
					INTO cConfirmation_nm
					FROM bdisac:"informix".sac_bts_sdep 
					WHERE estatus_sdep = '01'					
--					WHERE estatus_sdep = 'XX'										
						AND intentos_envio <= cValor
				
				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH;
			
			 IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '9984';

					--Se obtienen los mensajes de error asi como el codigo del mensaje
				SELECT NVL(opcode, ''),NVL(opcode_sd, '')
					INTO cOpcode,cDescr_mensaje 
					FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
					
				--En caso de que no exista el codigo del mensaje se les asigna otros valores
				IF cOpcode IS NULL THEN			
					LET cDescr_mensaje = 'Código no registrado en catálogo.';			
				END IF;

				-- En caso de que existan registros que fueron bloqueados temporalmente estatus_sdep='08', se regresan a '01'
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET estatus_sdep = '01'
				WHERE estatus_sdep = '08';							
					
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
					INTO cCod_retorno;

				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
			INTO cCod_retorno;
			
/*		ELSE
			LET cCod_err = '9986';
		END IF;*/
	ELSE
		LET cCod_err = '9001';
	END IF;
	
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, '')
		INTO cOpcode,cDescr_mensaje 
		FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN			
			LET cDescr_mensaje = 'Código no registrado en catálogo.';			
		END IF;
		
		--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
		INTO cCod_retorno;		
		
		RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
	END IF;		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa un numero determinado de registros guadado0s de forma exitosa',
'AUTOR : José Luís Polanco B.',
'FECHA : 05 de Noviembre de 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_conciliaciontotalporconvenio_pba(cConvenio CHAR(5), dFechaIni DATE, dFechaFin DATE)
    RETURNING
    CHAR(5)         AS retorno,
    CHAR(40)        AS nomconvenio,
    DATE            AS fecha_pago,
    DECIMAL(16,2)   AS importe_archivo,
    CHAR(30)        AS cuenta_cheques,
    DECIMAL(16,2)   AS importe_cheq,
    CHAR(30)        AS cuenta_contable,
    DECIMAL(16,2)   AS importe_conta;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE cConveniosNoConciliables  CHAR(100);
    DEFINE cCodRet              CHAR(5);
    DEFINE cNomConvenio         CHAR(40);
    DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	  CHAR(2);
    DEFINE dFecha_pago          DATE;
    DEFINE deImporte_archivo    DECIMAL(16,2);
    DEFINE cCuenta_cheques      CHAR(30);
    DEFINE deImporte_cheq       DECIMAL(16,2);
    DEFINE cCuenta_contable     CHAR(30);
    DEFINE deImporte_conta      DECIMAL(16,2);
    DEFINE iTransCargoCuenta    INTEGER;
    DEFINE mCargoCuenta         MONEY(16,2);
    DEFINE mCargoEfectivo       MONEY(16,2);
    DEFINE cNumTransaccEfec     CHAR(4);
    DEFINE dFechaHoy            DATE;
    DEFINE iProceso_automatico  INTEGER;
    DEFINE vconsmovhis      CHAR(10);
    DEFINE vconsmovhisold   CHAR(10);

    	SET DEBUG FILE TO  'sp_conciliaciontotalporconvenio.trc';
    	TRACE ON;
    
	LET cCodRet  =   "00000";
    LET cNomConvenio  = "";
    LET cConv  = "";
    LET cCateg  = "";
    LET dFecha_pago  = "01-01-1990";
    LET deImporte_archivo  = 0;
    LET cCuenta_cheques   = "";
    LET deImporte_cheq  = 0;
    LET cCuenta_contable  = "";
    LET deImporte_conta =  0;
    LET dFecha_pago  = dFechaIni;
    LET iTransCargoCuenta = 0;
    LET mCargoCuenta = 0;
    LET mCargoEfectivo = 0;
    LET cNumTransaccEfec = '';
    LET cConveniosNoConciliables = '';
    LET dFechaHoy = '01-01-1900';
    LET iProceso_automatico = 0;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_ConciliacionTotalPorConvenio");
                RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
        IF cConvenio = "" OR LENGTH(cConvenio) <> 5 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
        ELSE
		SET ISOLATION TO DIRTY READ;
            SELECT fecha_hoy
            INTO dFechaHoy
            FROM bdisac:"informix".sac_fechas;

			SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
			INTO cConveniosNoConciliables
			FROM bdisac:"informix".sac_param
			WHERE cod_param = 79;

			SET ISOLATION TO DIRTY READ;
            SELECT valor
              INTO vconsmovhis
              FROM bdicheq:"informix".sc_param
             WHERE codparam = 'fechcon_movhis'
               AND  empresa = '001';

			SET ISOLATION TO DIRTY READ;
            SELECT valor
              INTO vconsmovhisold
              FROM bdicheq:"informix".sc_param
             WHERE codparam = 'FechIniCon_movhis_ol'
               AND empresa = '001';	

			SET ISOLATION TO DIRTY READ;
			
			IF EXISTS(SELECT *  FROM sysmaster:"informix".systabnames  Where tabname = 'tmpcontable') THEN
                ---DROP TABLE tmpcontable;
            END IF;
			
            IF cConvenio = "00000" THEN      -- Todos los convenios
			SET ISOLATION TO DIRTY READ;

--	2013.02.01 I. Se optimiza consulta para obtener las cuentas contables de la tabla bdisac:sac_convenios y no usar la bdisac:sac_param
/* 
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT {+INDEX (bdisac:sac_convenios 103_4)} numcategoria || numconvenio
                                                                                                                FROM bdisac:"informix".sac_convenios
																												WHERE NOT cConveniosNoConciliables   LIKE
																												'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%' AND proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
			                                                    SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
			                                                    SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
			                                                    SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
			                                                    SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
			                                                    FROM bdisac:"informix".sac_convenios WHERE proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                      SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                      SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                      SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                      SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                      SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                      SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                      FROM bdisac:"informix".sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                      AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT {+INDEX (bdisac:"informix".sac_convenios 103_4)} numcategoria || numconvenio
                                                                                                                  FROM bdisac:"informix".sac_convenios
																												  WHERE NOT cConveniosNoConciliables   LIKE
																												'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%' AND proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				UNION ALL
				 SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
			                                                    SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
			                                                    SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
			                                                    SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
			                                                    SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
			                                                    FROM bdisac:"informix".sac_convenios WHERE proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
*/
			SET ISOLATION TO DIRTY READ;
                SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT  numcategoria || numconvenio AS convenio,
														SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
                                                        SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
                                                        SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
                                                        SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
                                                        SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
                                                        SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
                                                        FROM bdisac:sac_convenios WHERE trans_suc_efectivo NOT IN ('8701', '8702', '8703'))) cc
                WHERE a.empresa = '001' and a.ccmayor in ('2101', '2402') and a.ccsub='01' and a.ccsubsub in ('03', '90')
				AND a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.ciudad IS NOT NULL
				AND a.sucursal IS NOT NULL
                AND a.moneda IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT  numcategoria || numconvenio AS convenio,
															SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
                                                            SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
                                                            SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
                                                            SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
                                                            SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
                                                            SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
                                                            FROM bdisac:sac_convenios WHERE trans_suc_efectivo NOT IN ('8701', '8702', '8703'))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
--	2013.02.01 F. 
				SET ISOLATION TO DIRTY READ;
                FOREACH
                    -- Obtiene Nombre de Convenio
                    SELECT {+INDEX (bdisac:sac_convenios 103_4)} nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''), 
					      NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,'')
                    INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, 
					     cCuenta_cheques, iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec
                    FROM bdisac:"informix".sac_convenios
					WHERE NOT cConveniosNoConciliables   LIKE
					'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%'

                    -- Obtiene Cuenta Contable
                    IF iProceso_automatico = 0 THEN
					SET ISOLATION TO DIRTY READ;
                    SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
                    INTO cCuenta_contable
                    FROM bdisac:"informix".sac_param
                    WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio;
					END IF;	

                    WHILE dFecha_pago <= dFechaFin
							SET ISOLATION TO DIRTY READ;
                            -- Obtiene el Monto Total de los Movimientos
                            SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} NVL(SUM(importe_pago), 0)
                            INTO deImporte_archivo
                            FROM bdisac:"informix".sac_movimientoshistorial
                            WHERE numcategoria = cCateg AND numconvenio = cConv
                            AND fecha_pago = dFecha_pago
                            AND status_cancelado = 'N'
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1;
						IF iProceso_automatico = 0 THEN
							SET ISOLATION TO DIRTY READ;
                            SELECT NVL(SUM(CAST(transCargoCuenta AS INTEGER)), 0) AS transCargoCuenta, NVL(SUM(CAST(transEfec AS INTEGER)), 0) AS transEfec
                            INTO iTransCargoCuenta, cNumTransaccEfec
                            FROM TABLE(MULTISET(SELECT CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '5' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transCargoCuenta,
                                        CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '9' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transEfec
                                        FROM bdisac:"informix".sac_param));

                            -- Obtiene Numero de Cuenta de Cheques
                            SET ISOLATION TO DIRTY READ;
							SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                            INTO cCuenta_cheques
                            FROM bdisac:"informix".sac_param
                            WHERE cod_param = SUBSTRING(cConvenio FROM 2 FOR 4);
                       END IF;							

                            -- Obtiene el Monto Total de la Cuenta Contable
                            IF MONTH(dFecha_pago) = MONTH(dFechaHoy) AND YEAR(dFecha_pago) = YEAR(dFechaHoy)  THEN
                                SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto),0)
                                INTO deImporte_conta
                                FROM tmpcontable
                                WHERE convenio = cConvenio
                                AND mes_dia = dFecha_pago
                                AND tabla = 1;
                            ELSE
                                SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto),0)
                                INTO deImporte_conta
                                FROM tmpcontable
                                WHERE convenio = cConvenio
                                AND mes_dia = dFecha_pago
                                AND tabla = 2;
                            END IF;
                            if dFechaIni >= vconsmovhis then
				IF(cConvenio = "07004")THEN
				   LET mCargoEfectivo = 0;
   				   SET LOCK MODE TO WAIT 3;
				   SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(monto_tot), 0)
					INTO mCargoCuenta
					FROM bdicheq:"informix".sc_movhis
					WHERE cuenta = cCuenta_cheques
					AND fech_val = dFecha_pago
					AND transacc IN ('1140', '1110')
					AND NVL(cancelad, '') <> 'S';
				ELSE
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
 				    SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                                    INTO mCargoCuenta, mCargoEfectivo
                                    FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                         CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4))  THEN monto_tot END AS totEfectivo
                                                    FROM bdicheq:"informix".sc_movhis
                                                    WHERE cuenta = cCuenta_cheques
                                                    AND fech_val = dFecha_pago
                                                    AND NVL(cancelad, '') <> 'S'));
				END IF;
                            else
				IF(cConvenio = "07004")THEN
				LET mCargoEfectivo = 0;
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(monto_tot), 0)
 				        INTO mCargoCuenta
					FROM bdicheq:"informix".sc_movhis_old
					WHERE cuenta = cCuenta_cheques
					AND fech_val = dFecha_pago
					AND transacc IN ('1140', '1110')
					AND NVL(cancelad, '') <> 'S';
				ELSE
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                                INTO mCargoCuenta, mCargoEfectivo
                                FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                     CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4))  THEN monto_tot END AS totEfectivo
                                     FROM bdicheq:"informix".sc_movhis_old
                                     WHERE cuenta = cCuenta_cheques
                                     AND fech_val = dFecha_pago
    		                     AND NVL(cancelad, '') <> 'S'));
								END IF;
                            end if;
                            RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta + mCargoEfectivo, cCuenta_contable, deImporte_conta
                            WITH RESUME;
                        LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
                    END WHILE;
                    LET dFecha_pago = dFechaIni;
                END FOREACH;
            ELSE-- Un Solo Convenio
				SET ISOLATION TO DIRTY READ;
                SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio
																	AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT numcategoria || numconvenio
                                                                                                                FROM bdisac:sac_convenios 
																												WHERE proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
                                                                SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
																SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
																SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
																SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
																SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
																SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
																FROM bdisac:sac_convenios 
																WHERE TRIM(numcategoria) || TRIM(numconvenio) = cConvenio
																AND proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio
																	AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT numcategoria || numconvenio
                                                                                                                FROM bdisac:sac_convenios 
																												WHERE proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT  2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
																SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
																SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
																SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
																SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
																SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
																SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
																FROM bdisac:"informix".sac_convenios 
																WHERE TRIM(numcategoria) || TRIM(numconvenio) = cConvenio
																AND proceso_automatico = 1)) cc
               WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
								
				SET ISOLATION TO DIRTY READ;
				
				SELECT {+INDEX (bdisac:sac_convenios 103_4)} nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''), 
				     NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,'')
                INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, 
				     cCuenta_cheques, iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec
                FROM bdisac:"informix".sac_convenios
				WHERE numcategoria || numconvenio =  cConvenio
				AND NOT cConveniosNoConciliables   LIKE
				     '%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%';
				
			IF iProceso_automatico = 0 THEN
                -- Obtiene Cuenta Contable
				SET ISOLATION TO DIRTY READ;
                SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                INTO cCuenta_contable
                FROM bdisac:"informix".sac_param
                WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio;
			END IF;	

                WHILE dFecha_pago <= dFechaFin
                    -- Obtiene Monto Total de los Movimientos
                    SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe)} NVL(SUM(importe_pago), 0)
                    INTO deImporte_archivo
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = cCateg AND numconvenio = cConv
                    AND fecha_pago = dFecha_pago
					AND flag_confirmacion_central = 1
					AND flag_confirmacion_sucursal = 1
                    AND status_cancelado = 'N';

				IF iProceso_automatico = 0 THEN
                    SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(CAST(transCargoCuenta AS INTEGER)), 0) AS transCargoCuenta, NVL(SUM(CAST(transEfec AS INTEGER)), 0) AS transEfec
                    INTO iTransCargoCuenta, cNumTransaccEfec
                    FROM TABLE(MULTISET(SELECT CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '5' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transCargoCuenta,
                                               CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '9' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transEfec
                                        FROM bdisac:"informix".sac_param));
                    -- Obtiene Numero de Cuenta de Cheques
                    SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                    INTO cCuenta_cheques
                    FROM bdisac:"informix".sac_param
                    WHERE cod_param = SUBSTRING(cConvenio FROM 2 FOR 4);
				END IF;
                    -- Obtiene el Monto Total de la Cuenta Contable
                    IF MONTH(dFecha_pago) = MONTH(dFechaHoy) AND YEAR(dFecha_pago) = YEAR(dFechaHoy)  THEN
                            SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto),0)
                            INTO deImporte_conta
                            FROM tmpcontable
                            WHERE mes_dia = dFecha_pago
                            AND tabla = 1;
                    ELSE
                            SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto),0)
                            INTO deImporte_conta
                            FROM tmpcontable
                            WHERE mes_dia = dFecha_pago
                            AND tabla = 2;
                    END IF;
                    if dFechaIni >= vconsmovhis then
						--BTS
						IF(cConvenio = "07004")THEN
						LET mCargoEfectivo = 0;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto_tot), 0)
							INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE cuenta = cCuenta_cheques
							AND fech_val = dFecha_pago
							AND transacc IN ('1140', '1110')
							AND NVL(cancelad, '') <> 'S';
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
                        SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                        INTO mCargoCuenta, mCargoEfectivo
                        FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                                   CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4)) THEN monto_tot END AS totEfectivo
                                            FROM bdicheq:"informix".sc_movhis
                                            WHERE cuenta = cCuenta_cheques
                                            AND fech_val = dFecha_pago
                                            AND NVL(cancelad, '') <> 'S'));
						END IF;
                    else
						--BTS
						IF(cConvenio = "07004")THEN
				LET mCargoEfectivo = 0;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto_tot), 0)
							INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis_old
							WHERE cuenta = cCuenta_cheques
							AND fech_val = dFecha_pago
							AND transacc IN ('1140', '1110')
							AND NVL(cancelad, '') <> 'S';
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                        INTO mCargoCuenta, mCargoEfectivo
                        FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                                   CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4)) THEN monto_tot END AS totEfectivo
                                            FROM bdicheq:"informix".sc_movhis_old
                                            WHERE cuenta = cCuenta_cheques
                                            AND fech_val = dFecha_pago
                                            AND NVL(cancelad, '') <> 'S'));
						END IF;                        
                    end if;
                    RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta + mCargoEfectivo, cCuenta_contable, deImporte_conta
                    WITH RESUME;
                    LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
                END WHILE;
            END IF;
			SET ISOLATION TO DIRTY READ;
            IF EXISTS(SELECT *  FROM sysmaster:"informix".systabnames  Where tabname = 'tmpcontable') THEN
                ---DROP TABLE tmpcontable;
            END IF;
        END IF;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jesus Alberto Moreno',
'FECHA  : Febrero del 2009',
'VERSION: 20090203.1308',
'BD     : bdisac',
'MODIFICACION: 12/Febrero/2009',
'AUTOR: Raúl René Ruiz',
'MODIFICACION: 20/Abril/2009',
'AUTOR: Raúl René Ruiz',
'Se modifica para que utilize los indices existentes en produccion',
'de las tablas co_historico y co_mensual de la bdicont',
'MODIFICACION: 27/Mayo/2009',
'AUTOR: José Angel López Adams',
'Se modifica para que se contemplen los movimientos con Naturaleza C',
'Se implemento el uso de una tabla temporal, para que la consulta de los movimientos',
'se haga de esta tabla, que previamente se cargo con informacion exclusiva de movimientos de servicios',
'de las tablas co_mensual y co_historico de la BD bdicont',
'MODIFICACION: Jesús Antonio Bastidas López',
'Se modifica para que no tome en cuenta en la conciliación los convenios de DineroYa',
'Se cambia la consulta al sysmaster debido a que si la tabla no tiene registro pero existe truena el proceso',
'Fecha:29/03/2010',
'VERSION: 20100329.0907',
'FECHA: 18/11/2010',
'AUTOR: Manuel Ramos Figueroa',
'MODIFICACION: Se modifica para que consulte las tablas co_sdodias y co_histsdodias en lugar de las co_mensual y co_historico',
'AUTOR: Dulce Ramirez',
'MODIFICACION: Se modifica para que se tome los parametros de la tabla sac_convenios',
'Fecha: 14/09/2010',
'VERSION: 20100914.1721',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que se sumen los montos para la cuenta concentradora de BTS unicamente, filtrado por transacc',
'Fecha: 26/05/2011',
'VERSION: 20110526.1747',
'AUTOR: FRG',
'MODIFICACION: Se optimiza consulta para obtener las cuentas contables de la tabla bdisac:sac_convenios y no usar la bdisac:sac_param',
'Fecha: 01/02/2013';

CREATE PROCEDURE "informix".sp_dinya_obtieneparam_pba (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2),CHAR(5),CHAR(5);

--Declaracion de variables		  
DEFINE cSqlerr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cLongitudCliente     CHAR(2);
DEFINE cCodMonNac           CHAR(2);
DEFINE cPathRep             CHAR(100);
DEFINE cNombreUsuario       CHAR(45);
DEFINE cNombreEmpresa       CHAR(30);
DEFINE dFecha_Hoy           DATE;
DEFINE cSistema             CHAR(2);
DEFINE cLongitudNoControl	CHAR(5);
DEFINE cLongitudCuenta 		CHAR(5);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);


--SET DEBUG FILE TO "/tmp/sp_dinya_obtieneParam.out";
--TRACE ON;

--inicializacion de  variables
LET cCodRet= '00000';
LET cLongitudCliente= '';
LET cCodMonNac= '';
LET cPathRep= '';                                             
LET cNombreUsuario= '';
LET cNombreEmpresa = '';
LET dFecha_Hoy = '';
LET cSistema = '';
LET cLongitudNoControl = '';
LET cLongitudCuenta = '';
LET isam_err	= '';
LET cMensaje	= '';


BEGIN
--Crea el control de errores
	ON EXCEPTION SET cSqlerr, isam_err, cMensaje
		IF cSqlerr != 0 THEN
			LET cCodRet= cSqlerr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_obtieneParam',dFecha_Hoy,CURRENT );
			RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
		END IF;
	END EXCEPTION;

	-- Obtengo Fecha del sistemal para la Captura de Parametros
	SELECT fecha_hoy 
	INTO dFecha_Hoy
	FROM bdisac:sac_fechas
    WHERE empresa = pEmpresa;
	
	--Obtengo el valor longitud del numero de cliente		
    SELECT Trim(valor)
	INTO cLongitudCliente 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('7'); 

	--Obtengo el valor codigo de la moneda nacional
	SELECT Trim(valor)
	INTO cCodMonNac 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('15'); 

	 --Obtengo el valor path de reportes
	SELECT Trim(valor)
	INTO cPathRep
	FROM bdisac:sac_param 
	WHERE empresa = pEmpresa AND cod_param = ('74');

	--Obtengo el nombre del usuario o ejecutivo
	SELECT nombre 
	INTO cNombreUsuario
	FROM bdinteg:si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	 
	-- Obtengo el nombre de la empresa
	SELECT razon_social
	INTO cNombreEmpresa
	FROM bdinteg:si_empresas 
	WHERE empresa = pEmpresa;
	 
	--Obtengo codigo del sistema
	SELECT sistema
	INTO cSistema
	FROM bdinteg:si_sistema 
	WHERE siglas = 'SI';	
	
    -- se obtiene la longitud de la cuenta cLongitudCuenta
    SELECT valor
	INTO cLongitudCuenta
    FROM bdicheq:sc_param 
    WHERE empresa = pEmpresa AND codparam = 'longcta';

    --se obtiene el la longitud del numero de control
	SELECT valor 
	INTO cLongitudNoControl
    FROM bdisac:sac_param 
    WHERE empresa = pEmpresa AND cod_param = '77';
	
	RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema', 
'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
'Solicito : Armando Mercado',	
'AUTOR: César Valdéz Figueroa',
'FECHA: Octubre 2009',
'VERSION: 20091023.0700',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_altascambioscentral_pba(cNumcategoria CHAR(2), cNumconvenio CHAR(3), cNomconvenio CHAR(40), dFechaapertura DATE, dFechaclausura DATE,
                    cStatusconvenio CHAR(1), cTipo_Referencia CHAR(1), cNomlegalempresa CHAR(40), cRfcempresa CHAR(13), cNomcomercialempresa CHAR(40),
                    cDireccionempresa CHAR(80), cEstado CHAR(2), cCiudad CHAR(3), cCodpostal CHAR(5), cNumtelcorporativo CHAR(10), cNumfaxcorporativo CHAR(10),
                    cNomcontacto1 CHAR(40), cNumtelcontacto1 CHAR(10), cNumextcontacto1 CHAR(7), cEmailcontacto1 CHAR(40), cNomcontacto2 CHAR(40),
                    cNumtelcontacto2 CHAR(10), cNumextcontacto2 CHAR(7), cEmailcontacto2 CHAR(40), cNomcontacto3 CHAR(40), cNumtelcontacto3 CHAR(10),
                    cNumextcontacto3 CHAR(7), cEmailcontacto3 CHAR(40), cNumcuentaclabe CHAR(18), cTipopago CHAR(1), iFrecuenciapago INT, cFlgarchnotificacion CHAR(1),
                    iFrecnotificacion INT, cFlgporccomtrans_conv CHAR(1), dePorc_com_trans_conv DECIMAL, cFlgporccomtotal_conv CHAR(1),
                    dePorc_com_total_conv DECIMAL, cFlgimpcomtrans_conv CHAR(1), mImp_com_trans_conv MONEY(16,2), cFlgimpcomtotal_conv CHAR(1),
                    deImp_com_total_conv MONEY(16,2), cFlgivaincluido_conv CHAR(1), deIva_Convenio INT, cFlgPorcComTrans_Cte CHAR(1), dePorc_com_trans_cte DECIMAL,
                    cFlgImpComTrans_Cte CHAR(1), mImp_com_trans_cte MONEY(16,2), cFlg_Ref1 CHAR(1), iLongitudRef1  INT, cFlgcalculodv_ref1 CHAR(1), cNomrutinadv_ref1  CHAR(30),
                    cFlg_Ref2 CHAR(1), iLongitudRef2 INT, cFlgcalculodv_ref2 CHAR(1), cNomrutinadv_ref2 CHAR(30), cFlgreporte CHAR(1), cNomreporte CHAR(30), cUsuario CHAR(8))
    -- DATOS A REGRESAR
    RETURNING CHAR(5), CHAR(2), CHAR(3);  -- Codigo de Retorno
    -- DEFINICION DE VARIABLES
    DEFINE cCodRet              CHAR(5);
    DEFINE cFechaHoy            DATE;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(200);
    DEFINE fecha_ultimo_pago    DATE;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET fecha_ultimo_pago = '01-01-1900';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        ROLLBACK WORK;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_AltasCambiosCentral");
                        RETURN cCodRet, '', '';
                END IF;
        END EXCEPTION;

        BEGIN WORK;
            SELECT fecha_hoy INTO cFechaHoy FROM bdisac:sac_fechas;

            IF EXISTS (SELECT {+INDEX (bdisac:sac_convenios 103_4)} * FROM sac_convenios WHERE  numcategoria = cNumcategoria AND numconvenio = cNumconvenio) THEN
                UPDATE {+INDEX (bdisac:sac_convenios 103_4)} sac_convenios
                SET nomconvenio = cNomconvenio, fechaapertura = dFechaapertura, fechaclausura = dFechaclausura, statusconvenio = cStatusconvenio,
                    tipo_referencia = cTipo_Referencia, nomlegalempresa = cNomlegalempresa, rfcempresa = cRfcempresa, nomcomercialempresa = cNomcomercialempresa,
                    direccionempresa = cDireccionempresa, ciudad = cCiudad, estado = cEstado, codpostal = cCodpostal, numtelcorporativo = cNumtelcorporativo,
                    numfaxcorporativo = cNumfaxcorporativo, nomcontacto1 = cNomcontacto1, numtelcontacto1 = cNumtelcontacto1, numextcontacto1 = cNumextcontacto1,
                    emailcontacto1 = cEmailcontacto1, nomcontacto2 = cNomcontacto2, numtelcontacto2 = cNumtelcontacto2, numextcontacto2 = cNumextcontacto2,
                    emailcontacto2 = cEmailcontacto2, nomcontacto3 = cNomcontacto3, numtelcontacto3 = cNumtelcontacto3, numextcontacto3 = cNumextcontacto3,
                    emailcontacto3 = cEmailcontacto3, numcuentaclabe = cNumcuentaclabe, tipopago = cTipopago, frecuenciapago = iFrecuenciapago, flgarchnotificacion = cFlgarchnotificacion,
                    frecnotificacion = iFrecnotificacion, flgporccomtrans_conv =cFlgporccomtrans_conv, porc_com_trans_conv = dePorc_com_trans_conv,
                    flgporccomtotal_conv = cFlgporccomtotal_conv, porc_com_total_conv = dePorc_com_total_conv, flgimpcomtrans_conv = cFlgimpcomtrans_conv,
                    imp_com_trans_conv = mImp_com_trans_conv, flgimpcomtotal_conv = cFlgimpcomtotal_conv, imp_com_total_conv = deImp_com_total_conv,
                    flgivaincluido_conv = cFlgivaincluido_conv, iva_convenio = deIva_Convenio, flgporccomtrans_cte = cFlgPorcComTrans_cte, porc_com_trans_cte = dePorc_com_trans_cte,
                    flgimpcomtrans_cte = cFlgImpComTrans_cte, imp_com_trans_cte = mImp_com_trans_cte, flg_ref1 = cFlg_Ref1, longitud_ref1 = iLongitudRef1,
                    flgcalculodv_ref1 = cFlgcalculodv_ref1, nomrutinadv_ref1 = cNomrutinadv_ref1, flg_ref2 = cFlg_Ref2, longitud_ref2  = iLongitudRef2,
                    flgcalculodv_ref2 = cFlgcalculodv_ref2, nomrutinadv_ref2 = cNomrutinadv_ref2, flgreporte = cFlgreporte, nomreporte  = cNomreporte,
                    fecha_ultimo_pago = fecha_ultimo_pago, usuario_actualiza = cUsuario, fechaactualizacion = cFechaHoy
                WHERE numcategoria = cNumcategoria
                AND numconvenio = cNumconvenio;
            ELSE

                SELECT {+INDEX (bdisac:sac_convenios 103_7)} MAX(numconvenio)
                INTO cNumconvenio
                FROM bdisac:sac_convenios
                WHERE numcategoria = cNumcategoria;

                IF cNumConvenio IS NULL THEN
                    LET cNumConvenio = '001';
                ELSE
                    LET cNumconvenio  = LPAD(CAST(cNumconvenio AS INTEGER) + 1, 3, '0');
                END IF;

                INSERT INTO sac_convenios (numcategoria, numconvenio, nomconvenio, fechaapertura, fechaclausura, fechaalta, statusconvenio,	tipo_referencia,
	                        nomlegalempresa, rfcempresa,nomcomercialempresa, direccionempresa, ciudad, estado, codpostal, numtelcorporativo, numfaxcorporativo, nomcontacto1, 
							numtelcontacto1, numextcontacto1, emailcontacto1, nomcontacto2, numtelcontacto2, numextcontacto2, emailcontacto2, nomcontacto3, 
							numtelcontacto3, numextcontacto3, emailcontacto3, numcuentaclabe, tipopago, frecuenciapago, flgarchnotificacion, frecnotificacion, 
							flgporccomtrans_conv, porc_com_trans_conv, flgporccomtotal_conv, porc_com_total_conv, flgimpcomtrans_conv, imp_com_trans_conv,	
							flgimpcomtotal_conv, imp_com_total_conv, flgivaincluido_conv, iva_convenio, flgporccomtrans_cte, porc_com_trans_cte, 
							flgimpcomtrans_cte, imp_com_trans_cte, flg_ref1, longitud_ref1, flgcalculodv_ref1, nomrutinadv_ref1, flg_ref2, longitud_ref2, 
							flgcalculodv_ref2, nomrutinadv_ref2, flgreporte, nomreporte, fecha_ultimo_pago, usuario_alta, usuario_actualiza, fechaactualizacion) 
                    VALUES( cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, cFechaHoy, cStatusconvenio, cTipo_Referencia, 
					    	cNomlegalempresa, cRfcempresa, cNomcomercialempresa, cDireccionempresa, cCiudad, cEstado, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1,
                            cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2, cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3,
                            cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago, cFlgarchnotificacion, iFrecnotificacion,
                            cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                            cFlgimpcomtotal_conv, deImp_com_total_conv, cFlgivaincluido_conv, deIva_Convenio, cFlgPorcComTrans_cte, dePorc_com_trans_cte,
                            cFlgImpComTrans_cte, mImp_com_trans_cte, cFlg_Ref1, iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2,
                            cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte, fecha_ultimo_pago, cUsuario, cUsuario, cFechaHoy);

                INSERT INTO sac_controlarchivoscobranza (numcategoria, numconvenio, nom_rutina, fecha_ultimo_archivo)
                VALUES (cNumcategoria, cNumconvenio,'', fecha_ultimo_pago);

            END IF;
        COMMIT WORK;
        RETURN cCodret, cNumcategoria, cNumconvenio;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Hector Bojorquez',
'DESCRIPCION: Se encarga de insertar o actualizar el registro de un convenio en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: alcsac.exe, cacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'AUTOR MODIFICACION: Dulce Ramirez',
'DESCRIPCION MODIFICACION: Se especifican los campos de la tabla sac_convenios en el insert,',
'FECHA : Septiembre de 2010',
'VERSION: 20100920',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_actualizastatusconvenio_pba(cStatus CHAR(1), cNumConvenio CHAR(3), cNumCategoria CHAR(2))

    RETURNING
    CHAR(5);

    --Definicion de Variables
    DEFINE cCodRet      CHAR(5);
    DEFINE dFecha_hoy   DATE;
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cInfoErr     CHAR(200);

    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET dFecha_hoy = '01-01-1900';

    --debug flag
    --SET DEBUG FILE TO "/tmp/sc_consdatosctacentral.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizastatusconvenio");
                        RETURN cCodRet;
                END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_hoy FROM bdisac:sac_fechas;

            UPDATE sac_convenios
            SET statusconvenio = cStatus,  fechaactualizacion = dFecha_hoy, fecha_ultimo_pago = dFecha_hoy
            WHERE numcategoria = cNumCategoria
            AND numconvenio = cNumConvenio;

            IF cStatus = 'A' THEN
                UPDATE sac_controlarchivoscobranza
                SET fecha_ultimo_archivo = dFecha_hoy
                WHERE numcategoria = cNumCategoria
                AND numconvenio = cNumConvenio;
            END IF;

        RETURN cCodRet;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jose Angel Lopez Adams',
'DESCRIPCION: Se encarga de actualizar el status de un convenio previamente dado de alta en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: bacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_calcula_comisiones_pba(pcategoria CHAR(2),pconvenio CHAR(3),ppago MONEY(16,2))
returning CHAR(5),MONEY(14,2), MONEY(14,2), MONEY(14,2),MONEY(14,2);
	--************************************************************--
		--**	Elaboró: Ramon Octavio Romero Mascareño		**--
		--**	Actividad: Calcula Comisiones				**--
		--**	Solicito: Mauricio León						**--
		--**	Fecha: 10/07/09								**--
	--************************************************************--
		--**	Modificó: Manuel Osuna Valencia                 				**--
		--**	Actividad: Se modifica el tipo de dato de las variables de salida	**--
		--**	Solicito: Mauricio León								**--
		--**	Fecha: 05/08/09									**--
	--************************************************************--
DEFINE sql_err					INTEGER;
DEFINE cod_err					CHAR(5);
DEFINE vimpcomconvenio			MONEY(14,2);
DEFINE vIVAimpconvenio			MONEY(14,2);
DEFINE vimpcomcte				MONEY(14,2);
DEFINE vIVAimpcomcte			MONEY(14,2);
DEFINE vFlgporccomtrans_conv	CHAR(1);
DEFINE vPorc_com_trans_conv		MONEY(16,2);
DEFINE vFlgporccomtotal_conv	CHAR(1);
DEFINE vPorc_com_total_conv		MONEY(16,2);
DEFINE vFlgimpcomtrans_conv		CHAR(1);
DEFINE vImp_com_trans_conv		MONEY(16,2);
DEFINE vFlgimpcomtotal_conv		CHAR(1);
DEFINE vImp_com_total_conv		MONEY(16,2);
DEFINE vFlgivaincluido_conv		CHAR(1);
DEFINE vIva_convenio			INTEGER;
DEFINE vFlgporccomtrans_cte		CHAR(1);
DEFINE vPorc_com_trans_cte		MONEY(16,2);
DEFINE vFlgimpcomtrans_cte		CHAR(1);
DEFINE vImp_com_trans_cte		MONEY(16,2);

LET cod_err					="000";	
LET vimpcomconvenio 		= 0;
LET vIVAimpconvenio	 		= 0;
LET vimpcomcte 				= 0;
LET vIVAimpcomcte 			= 0;
LET vFlgporccomtrans_conv	="";
LET vPorc_com_trans_conv	= 0;
LET vFlgporccomtotal_conv	="";
LET vPorc_com_total_conv	= 0;
LET vFlgimpcomtrans_conv	="";
LET vImp_com_trans_conv		= 0;
LET vFlgimpcomtotal_conv	="";
LET vImp_com_total_conv		= 0;
LET vFlgivaincluido_conv	="";
LET vIva_convenio			= 0;
LET vFlgporccomtrans_cte	="";
LET vPorc_com_trans_cte		= 0;
LET vFlgimpcomtrans_cte		="";
LET vImp_com_trans_cte		= 0;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
      END IF ;
END EXCEPTION ;


SELECT 
    flgporccomtrans_conv,porc_com_trans_conv,   
    flgporccomtotal_conv,porc_com_total_conv,   /* comisiones por % o por monto pero total por día*/
    flgimpcomtrans_conv, imp_com_trans_conv,    
    flgimpcomtotal_conv, imp_com_total_conv,    /* comisiones por % o por monto pero total por día*/
    flgivaincluido_conv, iva_convenio,  		/* = 1 incluye IVA la comision (quitar el IVA del monto de comisión)*/
												/* = 0 calcular IVA de la comision (no se altera el monto de comisión)*/
												/* y el valor para cálculo del IVA esta en el campo iva_convenio */
    flgporccomtrans_cte, porc_com_trans_cte,    /*comisión al cliente en % por transacción*/
                                                /*se toma el monto del pago y se calcula la comisión*/
    flgimpcomtrans_cte, imp_com_trans_cte       /*comisión al cliente en monto fijo por transacción*/
INTO vFlgporccomtrans_conv,vPorc_com_trans_conv,   
    vFlgporccomtotal_conv,vPorc_com_total_conv, vFlgimpcomtrans_conv, vImp_com_trans_conv,    
    vFlgimpcomtotal_conv, vImp_com_total_conv, vFlgivaincluido_conv, vIva_convenio, 
    vFlgporccomtrans_cte, vPorc_com_trans_cte, vFlgimpcomtrans_cte, vImp_com_trans_cte  	
FROM BDISAC:sac_convenios
where numcategoria = pcategoria
and numconvenio = pconvenio;

    /*comisión del convenio*/
    IF vFlgporccomtotal_conv = 1 OR vFlgimpcomtotal_conv = 1 THEN 		/* comisiones por % o por monto pero total por día*/
        LET vimpcomconvenio = 0;                                        /* no debe grabar nada en linea (ceros)*/
    ELIF vFlgporccomtrans_conv = 1 THEN                       			/*comision es % por monto de transacción*/
        LET vimpcomconvenio = ppago * (vPorc_com_trans_conv/100);
    ELIF vFlgimpcomtrans_conv = 1 THEN                        			/*comision en monto por transacción*/ 
        LET vimpcomconvenio = vImp_com_trans_conv;
    ELSE 
        LET vimpcomconvenio = 0 ;                                      	/*no debe grabar nada en linea (ceros)*/
    END IF;
          
    /*comisíón a cliente QUE SE DEBE SUMAR AL IMPORTE DE CARGO POR PAGO ADEMAS DE REGISTRARSE EN SAC_MOVIMIENTOS*/
    IF vFlgporccomtrans_cte = 1 THEN                         			/*comisión al cliente en % por transacción*/
        LET vimpcomcte = ppago * (vPorc_com_trans_cte/100);
    ELIF vFlgimpcomtrans_cte = vImp_com_trans_cte THEN     				/*comisión al cliente en monto fijo por transacción*/
        LET vimpcomcte = vImp_com_trans_cte;
    ELSE
        LET vimpcomcte = 0;
    END IF;

    /*CALCULA IVA DE COMISIONES*/
    LET vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100);    	/*calculo iva de convenio*/
    LET vIVAimpcomcte = vimpcomcte * (vIva_convenio/100);        		/*calculo iva de cliente*/

    IF vFlgivaincluido_conv = 1 THEN     /*SE EXTRAE IVA DE LA COMISION*/      
        LET vimpcomconvenio = vimpcomconvenio - vIVAimpconvenio;
        LET vimpcomcte = vimpcomcte - vIVAimpcomcte;
    END IF;

	RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
END;
END PROCEDURE;