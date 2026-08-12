CREATE PROCEDURE "informix".sp_reporte_incrementos_linea(p_empresa CHAR(3))
RETURNING CHAR(6);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret						CHAR(6);
DEFINE vsqlerr							INTEGER;
DEFINE p_fecha							DATE;
DEFINE v_fecha_integ					DATE;
DEFINE v_fecha_sistema					DATE;

DEFINE cRuta                            CHAR(100);
DEFINE v_sepa							CHAR(2);
DEFINE v_num_cte						CHAR(20);
DEFINE v_num_prestamo					CHAR(20);
DEFINE v_telefono						CHAR(10);
DEFINE v_contador						INTEGER;
DEFINE v_canal_notifi_invitacion		CHAR(10);
DEFINE v_id_atm							CHAR(10);
DEFINE v_monto_linea_ant				DECIMAL (18,2);
DEFINE v_monto_linea_act				DECIMAL (18,2);
DEFINE v_respuesta_incremento			CHAR(9);
DEFINE v_Fecha_autorizacion_rechazo		CHAR(50);
DEFINE sFechaArch						CHAR(8);
DEFINE sMes							CHAR(2);
DEFINE sDia							CHAR(2);
DEFINE sYear						CHAR(4);
DEFINE v_sql						CHAR(1000);
DEFINE vTable1                                          CHAR(50);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET v_cod_ret								= "000000";
LET vsqlerr									= 0;

LET cRuta									= "/RESPALDOSNEW/";
LET p_fecha									= '';
LET v_fecha_integ							= '';
LET v_fecha_sistema							= '';
LET v_sepa									= '\|';	
LET v_num_cte 								= '';
LET v_num_prestamo 							= '';
LET v_telefono 								= '';
LET v_contador 								= 0;
LET v_canal_notifi_invitacion 				= '';
LET v_id_atm 								= '';
LET v_monto_linea_ant 						= 0;
LET v_monto_linea_act 						= 0;
LET v_respuesta_incremento 					= '';
LET v_Fecha_autorizacion_rechazo 			= "";
LET sFechaArch							='';
LET sDia						= "";
LET sMes						= "";
LET sYear						= "";
LET v_sql						= "";
LET vTable1                                             = "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET v_cod_ret=vsqlerr;
		  RETURN v_cod_ret;
	   END IF;
	END EXCEPTION;
	
 	--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_reporte_incrementos_linea.out";
--	TRACE ON; 
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
--cambiaras a sd_fechas
	SELECT fecha_hoy INTO v_fecha_integ FROM bdicred:"informix".sd_fechas WHERE empresa = p_empresa;
		LET v_fecha_sistema= CURRENT::DATE;

	LET v_fecha_sistema= CURRENT::DATE;	
	
	IF  v_fecha_integ = v_fecha_sistema THEN
		
		LET sDia= DAY(v_fecha_integ);
		LET sMes= MONTH(v_fecha_integ);
		LET sYear= YEAR(v_fecha_integ);
		
		IF LENGTH(sMes)<2 THEN
			LET sMes="0"||sMes;
		END IF;	
		
		IF LENGTH(sDia)<2 THEN
			LET sDia="0"||sDia;
		END IF;
		
		DROP TABLE IF EXISTS bdicred:"informix".sd_incrementos_prestamos_digitales_temp;
		
		LET sFechaArch = sDia||sMes||sYear;
		--Genera Encabezado para el Reporte
		LET v_sql =
			'echo '||'Numero de cliente'||v_sepa||'Numero de prestamo'||v_sepa||'Telefono celular'||v_sepa||'Contador'||v_sepa||'Canal de notificacion o invitacion ATM, SMS, App'||v_sepa
				   ||'Id de ATM'||v_sepa||'Monto de linea anterior'||v_sepa||'Monto de linea nueva'||v_sepa||'Respuesta al incremento de linea Acepta y No Acepta'||v_sepa||'Fecha de autorizacion/rechazo'
				   ||' >>'||TRIM(cRuta)||'Reporte_Incremento_de_Linea_'||TRIM(sFechaArch)||'.txt';
			SYSTEM v_sql;
		
			SELECT {+INDEX(bdicred:"informix".sd_incrementos_prestamos_digitales idx_incrmto_pd)} numcte,
			num_credito,telefono,secuencia,canal_notificacion_invitacion,id_atm,linea_prestamo_anterior,
			linea_prestamo_actual,respuesta_incremento,fecha_autorizo_o_rechazo
			FROM bdicred:"informix".sd_incrementos_prestamos_digitales
			INTO TEMP sd_incrementos_prestamos_digitales_temp WITH NO LOG;
			
			
			
			FOREACH
			--- consulta para obtener informacion de reporte
				SELECT 
					numcte,
					num_credito,
                    NVL(telefono,''),               
					secuencia,     
					NVL(canal_notificacion_invitacion,''),     
					NVL(id_atm,''),     
					linea_prestamo_anterior,     
					linea_prestamo_actual,     
					NVL(respuesta_incremento,''),     
					NVL(fecha_autorizo_o_rechazo,'') 			
				INTO v_num_cte
					,v_num_prestamo
					,v_telefono
					,v_contador
					,v_canal_notifi_invitacion
					,v_id_atm
					,v_monto_linea_ant			
					,v_monto_linea_act
					,v_respuesta_incremento
					,v_Fecha_autorizacion_rechazo
				    FROM bdicred:"informix".sd_incrementos_prestamos_digitales_temp 
					
				 IF (v_Fecha_autorizacion_rechazo != '') THEN
				 
		             LET v_Fecha_autorizacion_rechazo = TO_CHAR(TO_DATE(v_Fecha_autorizacion_rechazo),'%d/%m/%Y %H:%M:%S');
			    
				END IF;	
				
					LET v_sql = 'echo '||TRIM(v_num_cte)||v_sepa||v_num_prestamo||v_sepa||TRIM(v_telefono)||v_sepa||v_contador||v_sepa||v_canal_notifi_invitacion||v_sepa
								   ||v_id_atm||v_sepa||v_monto_linea_ant||v_sepa||v_monto_linea_act||v_sepa||v_respuesta_incremento||v_sepa||v_Fecha_autorizacion_rechazo||' >>'
								   ||TRIM(cRuta)||'Reporte_Incremento_de_Linea_'||sFechaArch||'.txt';   
								   
				SYSTEM v_sql;	
				
											
			END FOREACH;
			
		DROP TABLE IF EXISTS bdicred:"informix".sd_incrementos_prestamos_digitales_temp;

	ELSE
		LET v_cod_ret= '000001';
	END IF;
	
END
RETURN v_cod_ret;

END PROCEDURE	
DOCUMENT
'****************************************************************************************************************',
'Procedimiento para generar reporte de clientes que aceptan o no aceptan incremento en linea de credito',
'AUTOR : Arturo Acosta',
'FECHA : 18/ENERO/2024',
'BD: BDICRED',
'****************************************************************************************************************';

CREATE PROCEDURE "informix".sp_vigencia_oferta_incremento_pd()

--DATOS A REGRESAR---												 
RETURNING CHAR(6) AS rCodRet;
	  
--DECLARACIONES.
DEFINE cCodRet       CHAR(6);
DEFINE tFechaCurrent DATE;
DEFINE tFechaHoy     DATE;
DEFINE vDiasVigencia INTEGER;
DEFINE vOfertaVencio CHAR(100);
DEFINE iSqlErr       INTEGER;
DEFINE iContador     INTEGER;
DEFINE vNumCliente   CHAR(20);
DEFINE iSecuencia    SMALLINT;

---INICIALIZACIONES
LET iSqlErr       = 0;
LET cCodRet       = "000000";
LET tFechaCurrent = TODAY;
LET vDiasVigencia = 0;
LET vOfertaVencio = '';
LET iContador     = 1;
LET vNumCliente   = '';
LET iSecuencia    = 0;

BEGIN
    ON EXCEPTION SET iSqlErr	
		IF 	iSqlErr <> 0 THEN
			LET cCodRet =  iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/home/sysversiones/coppel-bancoppel/Richard/Domicilio_localizacion/sp_inserta_callespendientes.out";
    --TRACE ON;
	
	--OBTENGO FECHA DE TABLA SI_FECHAS
    SELECT fecha_hoy INTO tFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa='001';
    
	IF tFechaCurrent <> tFechaHoy THEN 
		LET cCodRet = '000001';
		RETURN cCodRet;
    ELSE
    
    --OBTENGO DESCRIPCION DE LA OBSERVACIÃN DE LA OFERTA
    SELECT TRIM(valor) INTO vOfertaVencio FROM bdicred:"informix".sd_param WHERE cod_param = '206';
      
     --INICIA PROCESO PARA PONER A INACTIVA LA OFERTA 
    FOREACH WITH HOLD
		SELECT {+INDEX(bdicred:"informix".sd_incrementos_prestamos_digitales idx_incrmto_pd)} numcte, secuencia
		INTO vNumCliente, iSecuencia
		FROM bdicred:"informix".sd_incrementos_prestamos_digitales
		WHERE oferta_incremento_linea = 'Activa' 
		AND fecha_fin_vigencia_oferta <= TODAY 
		
            
		IF iContador = 1 THEN       
		  BEGIN WORK;
		END IF;
            
		UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales 
		SET oferta_incremento_linea = 'Inactiva', observacion_oferta = vOfertaVencio
		WHERE oferta_incremento_linea = 'Activa' 
		AND fecha_fin_vigencia_oferta <= TODAY 
		AND numcte = vNumCliente
		AND secuencia = iSecuencia; 
            
		IF iContador = 1000 THEN               
		   COMMIT WORK;
		   LET iContador = 1;           
		ELSE
		  LET iContador = iContador + 1;
		END IF;      
            
	END FOREACH
     
	IF iContador > 1 THEN
		COMMIT WORK;
	END IF; 
END IF;
  
RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'Autor: Richard Rojas',
'Folio: RQM 10 1543 - 65670 - Incremento en la lÃ­nea de credito Prestamo Digital',
'Fecha: 02-05-2023',
'ModificaciÃ³n:  Se crea un SP para monitorear cada dÃ­a las vigencias por expirar con respecto a las ofertas que tengan los clientes para un incremento de linea.',
'Base de datos: bdicred,bdinteg',
'Solicito: ';

CREATE PROCEDURE "informix".sp_rep_segmentos_trim_mens(pEmpresa CHAR(3))
RETURNING CHAR(6);

--Creado por:Guadalupe Espinoza 08/10/2013
--Proceso para generar Reporte trimestral y mensual de uso de linea 
--Modificado Softtek 20/10/2023
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE vcCodRet 			CHAR(6);
DEFINE cErrorInfo			CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario				CHAR(8);
DEFINE cruta				CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE ntrimestre 			CHAR(30);
DEFINE cnomarchivo			CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte				CHAR(20);
DEFINE cnumcred				CHAR(20);
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE dFecha 				DATE;
DEFINE dFechatrim 			DATE;
DEFINE dFecha2 				DATE;
DEFINE dFecha3 				DATE;
DEFINE dFechaprim 			DATE;
DEFINE dDiaprimero  		DATE;
DEFINE dDiaUltimo   		DATE;
DEFINE canio        		CHAR(4);
DEFINE vsegmentos 			CHAR(12);
DEFINE vtotaltrimestre 		DECIMAL(18,2);
DEFINE totalint 			DECIMAL(18,2);
DEFINE sPaso				SMALLINT;
DEFINE sPaso2				SMALLINT;
DEFINE creotabla			CHAR(1);
DEFINE creotabla2			CHAR(1);


DEFINE v_fecha          DATE;
DEFINE v_num_credito    CHAR(12);
DEFINE v_NumTrans       CHAR(2);
DEFINE v_E_0            DECIMAL(18,2);
DEFINE v_E0             DECIMAL(18,2);
DEFINE v_E25            DECIMAL(18,2);
DEFINE v_E50            DECIMAL(18,2);
DEFINE v_E75            DECIMAL(18,2);
DEFINE v_E100           DECIMAL(18,2);
DEFINE v1_E_100         DECIMAL(18,2);
DEFINE v_sdo_intereses  DECIMAL(18,2);
DEFINE v_monto_compra   DECIMAL(18,2);
DEFINE v_monto_disp     DECIMAL(18,2);
DEFINE v_camp1          CHAR(12);
DEFINE v_camp2          INTEGER;
DEFINE contador_commit   INTEGER;
DEFINE val_trans_Commit   SMALLINT;


--SET DEBUG FILE TO "/resplogifx/archivoscredito/sp_rep_segmentos_trim_mens.out";
--TRACE ON;

--InicializaciÃ³n de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET vcCodRet 				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2111';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFechaHoy				= DATE(1);
LET dFecha 					= DATE(1);
LET dFechatrim 				= DATE(1);
LET dFecha2					= DATE(1);
LET dFecha3 				= DATE(1);
LET dFechaprim 					= DATE(1);
LET dDiaprimero 			= '';
LET dDiaUltimo 				= '';
LET canio   				= '';
LET vsegmentos 				= '';
LET vtotaltrimestre 		= 0;
LET totalint 				= 0;
LET sPaso					=0;
LET sPaso2					=0;
LET creotabla 				= '';
LET creotabla2 				= '';



LET v_fecha          =DATE(1);
LET v_num_credito    ='';
LET v_NumTrans       ='';
LET v_E_0            =0;
LET v_E0             =0;
LET v_E25            =0;
LET v_E50            =0;
LET v_E75            =0;
LET v_E100           =0;
LET v1_E_100         =0;
LET v_sdo_intereses  =0;
LET v_monto_compra   =0;
LET v_monto_disp     =0;
LET v_camp1          ='';
LET v_camp2          =0;
LET contador_commit   =0;
LET val_trans_Commit  =0;
	
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET pCod_ret = sql_err;
        LET pMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
        Returning cCod_RetIB;
        IF (val_trans_Commit = -1) THEN
		    ROLLBACK WORK;
	    END IF; 
        RETURN pCod_ret;
    END EXCEPTION;
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
		
	SELECT fecha_hoy,pri_dia_mes, pri_dia_mes - 1 units DAY, pri_dia_mes - 3 units MONTH INTO dFechahoy,dFechaprim, dFecha, dFechatrim
	FROM bdicred:sd_fechas
    WHERE empresa = pempresa; -- Sftk 181023
	
	LET dFecha2 = dFechaprim - 1 units MONTH - 1 units DAY;	LET dFecha3 = dFechaprim - 2 units MONTH - 1 units DAY;	LET canio = lpad(year(dFechatrim),4,'0');
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND grupo_parametro = 'CAT_PROMOS' 
	AND num_parametro = 2;
	--let cruta = '/resplogifx/archivoscredito/'; --pruebas

	
    SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'creditostransaccion';
    IF NVL(sPaso,0) > 0 THEN
        ---DROP TABLE creditostransaccion;
        TRUNCATE TABLE creditostransaccion;
    END IF;
	
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '30-Inicia consulta principal-Mensual', '02')
        Returning cCod_RetIB; 
        --Reporte Mensual 
        --INSERT INTO bdicred:creditostransaccion
        FOREACH WITH HOLD
            SELECT  ind.fecha, ind.num_credito,  	
            CASE   
                WHEN ((sdo.mto_fin_ven_trasp) = 1) THEN 'X1'
                WHEN ((sdo.mto_fin_ven_trasp) = 2) THEN 'X2'
                WHEN ((sdo.mto_fin_ven_trasp) = 3) THEN 'X3'
                WHEN ((sdo.mto_fin_ven_trasp) = 4) THEN 'X4'
                WHEN ((sdo.mto_fin_ven_trasp) = 5) THEN 'X5'
                WHEN ((sdo.mto_fin_ven_trasp) = 6) THEN 'X6'
                WHEN ((sdo.mto_fin_ven_trasp) > 6) THEN 'X7'
                WHEN ((nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 0) AND ((sdo.mto_fin_ven_trasp) = 0) THEN 'D0'
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 1 THEN 'T1' 
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 2 THEN 'T2' 
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) >= 3 THEN 'T3'
            ELSE 'Y8' END NumTrans,  
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  <  0 THEN 1 ELSE 0 END) AS E_0,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  = 0 THEN 1 ELSE 0 END) AS E0,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 0 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <= 25 THEN 1 ELSE 0 END) AS E25,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 25 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=50 THEN 1 ELSE 0 END) AS E50,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 50 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=75 THEN 1 else 0 END) AS E75,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 75 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=100 THEN 1 else 0 END) AS E100,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 100 THEN 1 ELSE 0 END) AS E_100,
            (sdo.sdo_no_exig) sdo_intereses, 
            (nvl(monto_pos,0)) monto_compra , (nvl(monto_atm,0) + nvl(monto_vtn,0) ) monto_disp 
            INTO v_fecha,v_num_credito,v_NumTrans,v_E_0,v_E0,v_E25,v_E50,v_E75,v_E100,v1_E_100,v_sdo_intereses,v_monto_compra,v_monto_disp
            FROM bdicred:sd_indicador_cred_hist ind, bdicred:"informix".sd_maesdoscont sdo, bdicred:"informix".sd_maecredcont mcnt, bdicred:"informix".sd_maecred mcr
            WHERE ind.empresa = sdo.empresa
            AND   ind.fecha = sdo.fecha
            AND   ind.num_credito = sdo.num_credito
            AND   ind.empresa = mcnt.empresa
            AND   ind.fecha = mcnt.fecha
            AND   ind.num_credito = mcnt.num_credito
            AND   ind.empresa = mcr.empresa
            AND   ind.num_credito = mcr.num_credito
            AND   sdo.empresa = mcnt.empresa
            AND   sdo.fecha = mcnt.fecha
            AND   sdo.num_credito = mcnt.num_credito
            AND   sdo.empresa = mcr.empresa
            AND   sdo.num_credito = mcr.num_credito
            AND   mcnt.empresa = mcr.empresa
            AND   mcnt.num_credito = mcr.num_credito
            AND   mcnt.num_producto = mcr.num_producto
            AND   mcnt.numcte = mcr.numcte 
            AND   ind.fecha = dFecha 
            AND   mcnt.status_cred <> 'CV'
            AND   mcr.campo_trab3 <> 'BAJA'			            				
            
            --update statistics medium for table creditostransaccion;
            
            IF (val_trans_Commit = 0) THEN
                BEGIN WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = -1;
            END IF;
            
            INSERT INTO bdicred:creditostransaccion
            VALUES(v_fecha,v_num_credito,v_NumTrans,v_E_0,v_E0,v_E25,v_E50,v_E75,v_E100,v1_E_100,v_sdo_intereses,v_monto_compra,v_monto_disp);
            
            LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 10000) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				BEGIN WORK;
			END IF;            
            
        END FOREACH
        IF val_trans_Commit = -1 THEN
            COMMIT WORK;
        END IF;
        
        LET val_trans_Commit = 0;
        LET v_fecha          =DATE(1);
        LET v_num_credito    ='';
        LET v_NumTrans       ='';
        LET v_E_0            =0;
        LET v_E0             =0;
        LET v_E25            =0;
        LET v_E50            =0;
        LET v_E75            =0;
        LET v_E100           =0;
        LET v1_E_100         =0;
        LET v_sdo_intereses  =0;
        LET v_monto_compra   =0;
        LET v_monto_disp     =0;

        SELECT sum(sdo_intereses)		
        INTO totalint
        FROM creditostransaccion
        WHERE fecha =  dFecha;
         
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '30-Inicia descarga-Mensual', '02')
        Returning cCod_RetIB;
        LET cnomarchivo1 =  'SegmentaMes'||'.unl';
        LET cnomarchivo =  'rep_segmentos_mensual'||to_char( dFechaHoy,'%m%d%Y')||'.txt';
        --Encabezado
        let cSql='';
        let csql = 'echo "Mes|Segmento|-0%|0%|25%|50%|75%|100%|+100%|Intereses|Porcentaje|Compras|' ||
                'Disposiciones'||
                '" >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
        LET cSQL2 = ' select fecha, num_trans,sum(seg_e_0),sum(seg_e0),sum(seg_e25),sum(seg_e50),sum(seg_e75),sum(seg_e100),sum(seg_e_100),sum(sdo_intereses), ' 
                    ||'round((sum(sdo_intereses)/'|| NVL(totalint,0) ||')*100,2),sum(monto_compra), sum(monto_disp) from creditostransaccion '
                    ||' group by  1,2 order by fecha,num_trans ';
        LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;
        LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSql = cSql; 
        LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
        SYSTEM cSql;
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
        SYSTEM cSQL;
    
   

	RETURN pCod_ret;

END
END PROCEDURE;