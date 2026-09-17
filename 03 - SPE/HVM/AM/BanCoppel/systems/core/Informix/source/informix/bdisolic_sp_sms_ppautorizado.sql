CREATE PROCEDURE "informix".sp_sms_ppautorizado() 
RETURNING CHAR(6),VARCHAR(80);

DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR     	INTEGER;
DEFINE ERROR_INFO   	VARCHAR(80);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(80);

DEFINE cProceso     	CHAR(4);
DEFINE cCod_ret			CHAR(6);
DEFINE cMensaje			VARCHAR(50);
DEFINE pempresa 		CHAR (3);
DEFINE v_solicitud 		CHAR (20);
DEFINE v_numcte 		CHAR (20);
DEFINE v_nombre1 		CHAR (20);
DEFINE v_nombre2 		CHAR (20);
DEFINE v_nombre 		CHAR (10);
DEFINE v_nombre_sms 	CHAR (20);
DEFINE v_telefono 		CHAR (10);
DEFINE v_fecha_ent 		DATETIME YEAR TO SECOND;
DEFINE v_fecha_lim 		DATETIME YEAR TO SECOND;
DEFINE dtCampAct 		DATETIME YEAR TO SECOND;
DEFINE v_fecha 			CHAR(6);
DEFINE vcontador 		INTEGER;
DEFINE fecha_ini		DATE;
DEFINE fecha_fin		DATE;

LET P_COD_RET   		= '000000';
LET P_MENSAJE   		='ENVIO SMS PP_AUTORIZADO SIN DISPONER FINALIZADO.';
LET cCod_ret    		= '000000';
LET cMensaje    		= '';
LET cproceso    		= '0041';
LET SQL_ERR				=0;
LET ISAM_ERR			=0;
LET ERROR_INFO			= '';

LET v_solicitud	 		='';
LET v_numcte 			='';
LET v_nombre1			= '';
LET v_nombre2	 		='';
LET v_nombre 			='';
LET v_nombre_sms 		='';
LET v_telefono			= '';
LET v_fecha_ent 		='';
LET v_fecha_lim			='';
LET v_fecha				='';
LET vcontador 			=0;
LET pEmpresa 			= '001';
LET fecha_ini			= '';
LET fecha_fin			= '';


BEGIN
	ON EXCEPTION 
		SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET = SQL_ERR;
		LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, P_COD_RET, P_MENSAJE, '02')
			 RETURNING P_COD_RET;
		LET P_COD_RET = SQL_ERR;
		RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso , cCod_ret, cMensaje, '01') RETURNING P_COD_RET;

     IF P_COD_RET != '000000' then
        let P_MENSAJE  = 'ERROR sp_inserta_bitacora_cob';
        RETURN P_COD_RET,P_MENSAJE;
     END IF;	
   	
	SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO '/respaldos/sp_carga_datos_pp_sms.out';
--	TRACE ON;

	SELECT fecha_hoy-7, fecha_hoy
	INTO fecha_ini,fecha_fin
	FROM bdicred:sd_fechas;
	
    FOREACH WITH HOLD
		SELECT a.num_solicitud, a.numcte, e.nombre1, e.nombre2, d.telefono, b.fecha_entrada 
		          INTO v_solicitud, v_numcte, v_nombre1, v_nombre2, v_telefono, v_fecha_ent
			  FROM bdisolic:ss_solicitudes a  
		INNER JOIN bdisolic:ss_autorizacion b
			ON b.empresa ='001' 
			AND a.num_solicitud=b.num_solicitud 
			AND a.status_solicitud=b.status_solicitud 
			AND fecha_entrada between fecha_ini and fecha_fin
		INNER JOIN bdinteg:si_telefonos d
			ON a.numcte=d.numcte 
			AND tipo_tel=2  
			AND d.verificado='V' 
			AND d.status_tel='A'
		INNER JOIN bdinteg:si_cliente e
			ON a.numcte=e.numcte
		WHERE num_producto in(6300, 7600, 7700) 
		AND a.status_solicitud='AT'                

		IF LENGTH(v_nombre1) <= 3 THEN
			LET v_nombre_sms=(TRIM(v_nombre1)||' '||TRIM(v_nombre2));
			LET v_nombre= SUBSTRING(v_nombre_sms FROM 1 FOR 12);
		ELSE
			LET v_nombre=SUBSTRING(v_nombre1 FROM 1 FOR 12);
		END IF;

		LET v_fecha_lim = DATE(v_fecha_ent) + 30 ;
		
		IF MONTH(v_fecha_lim)='01' THEN 
			LET v_fecha= DAY(v_fecha_lim)||'-'||'ENE';
		ELIF MONTH(v_fecha_lim)='02' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'FEB';
		ELIF MONTH(v_fecha_lim)='03' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'MAR';
		ELIF MONTH(v_fecha_lim)='04' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'ABR';
		ELIF MONTH(v_fecha_lim)='05' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'MAY';
		ELIF MONTH(v_fecha_lim)='06' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'JUN';
		ELIF MONTH(v_fecha_lim)='07' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'JUL';
		ELIF MONTH(v_fecha_lim)='08' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'AGO';
		ELIF MONTH(v_fecha_lim)='09' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'SEP';
		ELIF MONTH(v_fecha_lim)='10' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'OCT';
		ELIF MONTH(v_fecha_lim)='11' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'NOV';
		ELIF MONTH(v_fecha_lim)='12' THEN   
			LET v_fecha= DAY(v_fecha_lim)||'-'||'DIC';
		END IF;

		CALL bdimnsj:"informix".sp_registra_evento (2,'PROD_SMS','PREST_PERS','000000000', v_solicitud,'', 2,    
													   v_nombre,v_fecha, '','','','','','','','',
														'',v_telefono,
														0, 0, 0, 0, 0,'','')RETURNING P_COD_RET;
		IF P_COD_RET = '00000' THEN												
			LET vcontador = vcontador +1;	
		END IF;	
	END FOREACH 

--Genera cifras de control
	IF vcontador > 0 THEN
       LET cMensaje = 'SMS ENVIADOS PP_AUTORIZADOS SIN DISPONER: ' ||vcontador;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	END IF;

   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cproceso, cCod_ret, cMensaje, '03')
   RETURNING P_COD_RET;
   
   IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	RETURN P_COD_RET,P_MENSAJE;
END
END PROCEDURE

