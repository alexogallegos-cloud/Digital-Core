CREATE PROCEDURE "informix".sp_actualiza_statusmttobcycc(pempresa CHAR(3),pnum_solicitud CHAR(20), popcion CHAR(1)) 
RETURNING CHAR(6), CHAR(50);
  
DEFINE cStatus_Actual   CHAR(2);
DEFINE cDescripcion     CHAR(50);
DEFINE cCodRet          CHAR(6);
DEFINE iSql_err         INTEGER;
DEFINE cEstatusIniBita  CHAR(2); 

--INICIALIZACION DE VARIABLES--
LET cCodRet                  = '000000';
LET iSql_err                 = 0 ;  
LET cDescripcion             = 'PROCESO EXITOSO';
LET cStatus_Actual           = '';
LET cEstatusIniBita          = '';

BEGIN
    ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			LET cDescripcion = 'ERROR NO CONTROLADO';
			RETURN cCodRet, TRIM(NVL(cDescripcion,''));
		END IF;
	END EXCEPTION;
    
	--SET DEBUG FILE TO '/dbexportb/carlos/buro/sp_actualiza_statusMttoBCyCC.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ; 
	SET LOCK MODE TO WAIT 3;
       
	IF NVL(pnum_solicitud,'') = '' THEN
		LET cCodRet = '000001';
		LET cDescripcion = 'EL NUMERO DE SOLICITUD NO ES VALIDO';
		RETURN cCodRet, TRIM(NVL(cDescripcion,''));
	END IF;
		
	--SE LEE EN QUE ESTATUS SE ENVIO LA SOLICITUD
	SELECT estatus
	INTO cEstatusIniBita
	FROM bdisolic:"informix".ss_mon_buro_rep
	WHERE numsolicitud = pnum_solicitud
	AND  secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_mon_buro_rep WHERE numsolicitud = pnum_solicitud);
	
	IF cEstatusIniBita IS NOT NULL THEN 
		IF   (popcion = "1")  THEN
				-- 1370-MttoBCyCC, RQM  09 308, Obtener el estatus actual de la solicitud
				SELECT status_solicitud 
				  INTO cStatus_Actual 
				  FROM "informix".ss_solicitudes 
				 WHERE empresa = pempresa 
				   AND num_solicitud = pnum_solicitud;
				   

				IF NVL(cStatus_Actual,'') = '' THEN
					LET cCodRet = '000002';
					LET cDescripcion = 'ESTATUS NO VALIDO PARA LA SOLICITUD';
					RETURN cCodRet, TRIM(NVL(cDescripcion,''));
				ELSE
						UPDATE "informix".ss_mon_buro_rep
						   SET estatus_fin = cStatus_Actual
						 WHERE empresa = pempresa
						   AND secuencia = (SELECT MAX(secuencia) FROM "informix".ss_mon_buro_rep
											 WHERE numsolicitud = pnum_solicitud )
						   AND numsolicitud = pnum_solicitud;
				END IF;	
		ELIF (popcion = "2")  THEN	
				-- 1370-MttoBCyCC, RQM  09 308, Obtener el estatus actual de la solicitud
				SELECT status
				  INTO cStatus_Actual
				  FROM bdicred:"informix".sd_bitacora_aumlincred
				 WHERE num_solicitud=pnum_solicitud
				   AND fecha_insert=(SELECT MAX(fecha_insert) FROM bdicred:"informix".sd_bitacora_aumlincred
									  WHERE empresa=pEmpresa AND num_solicitud=pnum_solicitud);
				
				IF NVL(cStatus_Actual,'') = '' THEN
					LET cCodRet = '000003';
					LET cDescripcion = 'ESTATUS NO VALIDO PARA LA SOLICITUD';
					RETURN cCodRet, TRIM(NVL(cDescripcion,''));
				ELSE
						UPDATE "informix".ss_mon_buro_rep
						   SET estatus_fin = cStatus_Actual
						 WHERE empresa = pempresa
						   AND secuencia = (SELECT MAX(secuencia) FROM "informix".ss_mon_buro_rep
											 WHERE numsolicitud = pnum_solicitud )
						   AND numsolicitud = pnum_solicitud;

				END IF;
		ELSE
			LET cCodRet = '000004';
			LET cDescripcion = 'PARAMETRO OPCION INVALIDO';
			RETURN cCodRet, TRIM(NVL(cDescripcion,''));
		END IF;
		
		--SI EL ESTATUS NUEVO ES DIFERENTE AL QUE SE MANDO, Y DIFERENTE A BC ACTUALIZA ENVIO EXITOSO A 1
		IF  cStatus_Actual NOT IN ('BC','CC') THEN
			UPDATE "informix".ss_mon_buro_rep
			SET reenvio_exit = '1'
			WHERE empresa = pempresa
			AND secuencia = (SELECT MAX(secuencia) FROM "informix".ss_mon_buro_rep
						 WHERE numsolicitud = pnum_solicitud )
			AND numsolicitud = pnum_solicitud;
		ELIF cStatus_Actual IN ('BC','CC') THEN --SI REGRESA EN EL MISMO ESTATUS EN QUE SE ENVIO
			UPDATE "informix".ss_mon_buro_rep
			SET reenvio_exit = '0'
			WHERE empresa = pempresa
			AND secuencia = (SELECT MAX(secuencia) FROM "informix".ss_mon_buro_rep
						 WHERE numsolicitud = pnum_solicitud )
			AND numsolicitud = pnum_solicitud;
		END IF;
	
	END IF;
	
    RETURN cCodRet, TRIM(NVL(cDescripcion,''));
END;
END PROCEDURE
