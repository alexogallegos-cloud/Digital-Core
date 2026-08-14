CREATE PROCEDURE "informix".sp_notifica_solic_oa_exp1 ()
-- execute procedure bdisolic:"informix".sp_notifica_solic_oa();
returning
char (06),
VARCHAR(80);

------------------------------------------------------------------------------------

---- DECLARACION DE VARIABLES
DEFINE vEmpresa 		CHAR(3);
DEFINE vNumCte 			CHAR(20);
DEFINE vNumSolicitud 	CHAR(20);
DEFINE vApellPaterno 	CHAR(26);
DEFINE vCelular			CHAR(13);
DEFINE vFecha 			DATE;
DEFINE vFechaProxima 	DATE;
DEFINE vFechaH 			DATE;
DEFINE vFechaU			DATE;
DEFINE vNumProducto		CHAR(4);
DEFINE vEnvios			smallint;
DEFINE vFechaA			DATE;
DEFINE vTotalEnv		INTEGER;
DEFINE vStatus			CHAR(2);
DEFINE vStatusol		CHAR(2);
DEFINE vGrupo			CHAR(1);
DEFINE totregs			INTEGER;


DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR			INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE P_COD_RET		VARCHAR(6);
DEFINE COD_RET			VARCHAR(6);
DEFINE SCOD_RET		    VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE vproceso			CHAR(4);
DEFINE cMensaje			CHAR(80);
DEFINE cSql				CHAR(2000);

DEFINE v_empresa        CHAR(4);
DEFINE vNumEnvio        SMALLINT;
DEFINE vfechaCambioStatus DATE;
DEFINE vfechaCambioStatusOA DATETIME YEAR TO SECOND;


---INICIALIZACIONES DE VARIABLES
LET vEmpresa			= '001';
LET vNumCte				= '';
LET vNumSolicitud		= '';
LET vApellPaterno		= '';
LET vCelular			= '';
LET vFecha				= '';
LET vFechaProxima		= '';
LET vFechaH				= '';
LET vFechaU				= '';
LET vNumProducto		= '';
LET vEnvios				= 0;
LET vFechaA				= 0;
LET vTotalEnv			= 0;
LET vStatus				= '';
LET vStatusol			= '';
LET vGrupo				= '';
LET vfechaCambioStatus = '';
LET vfechaCambioStatusOA = '';


LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '000000';
LET COD_RET				= '00000';
LET SCOD_RET            = '';
LET P_MENSAJE			= 'Proceso de actualizacion de estatus OA-AT correcto';
LET vproceso			= '0098';
LET cMensaje			= '';
LET cSql				= '';
LET v_empresa           = '001';
LET vNumEnvio           = 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '|| NVL(vNumSolicitud,0);
		CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '02') RETURNING SCOD_RET;
		RETURN P_COD_RET,P_MENSAJE;
	END EXCEPTION;

  SET debug FILE TO "/tmp/sp_notif_solic_oa.out";
  TRACE ON;
  
    LET cMensaje = 'PROCESO AUTOMATICO INICIALIZADO SOLICITUDES OA';
    CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING SCOD_RET;
    
  	IF SCOD_RET != '000000' THEN
		let P_COD_RET = COD_RET;
		let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	ELSE 
	    LET COD_RET = '00000';
	END IF;

	SELECT fecha_hoy, fecha_ant, ult_dia_mes INTO vFechaH, vFechaA, vFechaU FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;

	SET LOCK MODE TO wait 3;
    SET ISOLATION TO dirty READ;
        DROP TABLE IF EXISTS notisolcred; 
		SELECT MAX(sol.num_solicitud) numsol, sol.numcte ncte, NVL(cte.apell_paterno,'') apaterno, NVL(telact.telefono,'') tel, 
		       scor.grupo gpo, os.fecha_entrada fent, MAX(os.fecha_hora) fhora, sol.status_solicitud stsol, sol.num_producto numprod
		FROM bdisolic:"informix".ss_solicitudes sol
		JOIN bdisolic:"informix".ss_autorizacion os ON (sol.empresa = os.empresa AND sol.num_solicitud = os.num_solicitud AND sol.status_solicitud = os.status_solicitud)
		JOIN bdinteg:"informix".si_cliente cte ON sol.numcte = cte.numcte
		LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual telact ON ( sol.numcte = telact.numcte AND telact.tipo_tel = 2)
		JOIN bdisolic:"informix".ss_resum_scor_fin scor ON (sol.num_solicitud = scor.num_solicitud)
		WHERE sol.num_producto IN ('6001','6300','7600','7700')
		AND sol.status_solicitud IN ('OA') 
		AND os.fecha_hora::DATE <= vFechaH
		AND scor.tipo_movimiento = 'U' --solicitud Bancoppel
		AND (telact.telefono IS NOT NULL)
	    AND telact.telefono IN (SELECT telefono FROM bdinteg:"informix".si_telefonos tel WHERE telact.telefono = tel.telefono 
	                         AND telact.numcte = tel.numcte AND sol.numcte = tel.numcte AND tel.verificado = 'V' AND tel.tipo_tel = 2)
        GROUP BY sol.num_solicitud , sol.numcte, cte.apell_paterno, telact.telefono, 
				 scor.grupo, os.fecha_entrada, os.fecha_hora, sol.status_solicitud, sol.num_producto							 
		INTO temp notisolcred WITH NO LOG;

		UPDATE STATISTICS HIGH FOR TABLE notisolcred;
		
		SELECT count(*)  INTO totregs FROM notisolcred;
	
	IF NVL(totregs,0) > 0 THEN
		FOREACH WITH HOLD

	---------- EnvÃ­o de SMS
			
			--Se busca algÃºn registro almacenado en la tabla del proceso masivo
			SELECT a.numsol,     a.ncte,   a.apaterno,    a.tel,   a.gpo,       a.fent,         a.fhora,             a.stsol, a.numprod
			INTO  vNumSolicitud, vNumCte, vApellPaterno, vCelular, vGrupo, vfechaCambioStatus, vfechaCambioStatusOA, vStatus, vNumProducto
			FROM notisolcred a
			
			SELECT NVL(num_msj_envio,0) INTO vNumEnvio 
			FROM bdisolic:"informix".ss_solicitudes_envio_oa 
			WHERE num_solicitud = vNumSolicitud;  
				
				IF vNumEnvio IS NULL THEN
						
					INSERT INTO bdisolic:"informix".ss_solicitudes_envio_oa (empresa, num_solicitud, fecha_envio_msj1,fecha_envio_msj2,fecha_envio_msj3,fecha_cambio_status,num_msj_envio,fecha_alta,numcte,grupo,status_solicitud,fecha_cambio_status_oa,num_producto)
						   VALUES (vEmpresa, vNumSolicitud, vFechaH, NULL,NULL,vfechaCambioStatus,1, current, vNumCte, vGrupo, vStatus,vfechaCambioStatusOA,vNumProducto);
								
					--Actualiza contador
					LET vTotalEnv = vTotalEnv + 1;
								
				END IF;
				
			SELECT status_solicitud, fecha_entrada INTO vStatusol, vFechaCambioStatus
			FROM bdisolic:"informix".ss_autorizacion 
			WHERE num_solicitud = vNumSolicitud AND status_solicitud in ('AT','RT','CN');
				
				IF NVL(vNumEnvio,0) = 1 THEN
					
					--Actualiza el ultimo estatus de la solicitud, con el fin de extraer el dato para la generaciÃ³n del reporte
					IF (SELECT COUNT(nvl(status_solicitud,0)) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = vNumSolicitud 
							AND status_solicitud in ('AT','RT','CN')) > 0 THEN 
					
						UPDATE bdisolic:"informix".ss_solicitudes_envio_oa
						SET status_solicitud = vStatusol, fecha_cambio_status = vFechaCambioStatus 
						WHERE num_solicitud = vNumSolicitud;
						
					END IF;					
					
					IF vStatusol = 'AT' THEN

						--Actualiza ultimo estatus de la solicitud
						UPDATE bdisolic:"informix".ss_solicitudes_envio_oa
						SET  num_msj_envio = num_msj_envio + 1,fecha_envio_msj2 = vFechaH 
						WHERE num_solicitud = vNumSolicitud;					
					    
					  	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CRED_SMS','SOL_OA_AT','000000000','','','2',trim(vApellPaterno),'','','','','','','','','','',vCelular,0,0,0,0,0,current,current) INTO SCOD_RET;				
						IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
						
					END IF;					
						
					--Actualiza contador
					LET vTotalEnv = vTotalEnv + 1;		
					 
				ELIF NVL(vNumEnvio,0) = 2 THEN
								
					IF (SELECT COUNT(NVL(status_solicitud,0)) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = vNumSolicitud 
							AND status_solicitud in ('AT','RT','CN')) > 0 THEN 
									
						UPDATE bdisolic:"informix".ss_solicitudes_envio_oa
						SET status_solicitud = vStatusol, fecha_cambio_status = vFechaCambioStatus 
						WHERE num_solicitud = vNumSolicitud;
						
					END IF; 
									
					IF vStatusol = 'AT' THEN
						
						--Actualiza ultimo estatus de la solicitud
						UPDATE bdisolic:"informix".ss_solicitudes_envio_oa
						SET num_msj_envio = num_msj_envio + 1,fecha_envio_msj3 = vFechaH 
						WHERE num_solicitud = vNumSolicitud;
					    
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CRED_SMS','SOL_OA_AT','000000000','','','2',trim(vApellPaterno),'','','','','','','','','','',vCelular,0,0,0,0,0,current,current) INTO SCOD_RET;				
						IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
						
					END IF;					
					
					--Actualiza contador
					LET vTotalEnv = vTotalEnv + 1;

				END IF;
							
		END FOREACH
	ELSE
	    LET P_COD_RET = '000001';
		LET P_MENSAJE  = 'No se encuentran registros de solicitudes con estatus OA.';
	END IF;

	--Muestra en bitacora el total de registros procesados
	LET cMensaje = '   Total de envÃ­os realizados: ' || vTotalEnv;
	CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;

	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = COD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	ELSE
		LET COD_RET = '00000';
	END IF;


    LET cMensaje = 'ROCESO AUTOMATICO FINALIZADO SOLICITUDES OA';
	CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING SCOD_RET;
	IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;

	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = COD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	ELSE
		LET COD_RET = '00000';
	END IF;

    RETURN COD_RET,P_MENSAJE;

END;
END PROCEDURE;