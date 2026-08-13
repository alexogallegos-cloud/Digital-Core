CREATE PROCEDURE "informix".sp_actualiza_estatus_solrenovtkn(pNumCte CHAR(9), pStatus CHAR(1))
	RETURNING CHAR(5);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizo: Solser
-- Descripcion: Actualiza el campo id_status_solicitud por numero de cliente
-- Fecha de Construccion: 29/08/2018 
-----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER;
	DEFINE vid_usuario INTEGER;
	DEFINE vid_tipo_usuario SMALLINT;
	DEFINE vns_token CHAR(10);
	DEFINE vid_status_solicitud  CHAR(1);
	DEFINE vExisteTkn CHAR(10);
	DEFINE vCantidad INTEGER;
	
	LET vCodRet = '00000';
	LET vid_usuario='';
	LET vid_tipo_usuario='';
	LET vns_token='';
	LET vid_status_solicitud='';
	LET vExisteTkn='';
	LET vCantidad=0;
	
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_actualiza_estatus_solrenovtkn.out";
	--TRACE ON;
	 SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;

	
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;

	

		IF(NVL(pNumCte, '') == '' OR NVL(pStatus, '') = '') THEN
				LET vCodRet = '00001'; -- Algun parametro requerido es nulo
				RETURN vCodRet;
		END IF;
	   
			
			FOREACH SELECT  id_usuario,  id_tipo_usuario, ns_token, id_status_solicitud
			into vid_usuario, vid_tipo_usuario, vns_token, vid_status_solicitud
					FROM BDIBEI:"informix".bei_tokenexpira WHERE num_cte = pNumCte
									
					IF(vid_tipo_usuario = 1) THEN -- Si el usuario es admin
							
							SELECT ns_token  INTO vExisteTkn FROM bdibei:"informix".bei_token 
							WHERE id_usuario = vid_usuario 	AND num_cliente = pNumCte;
							
								 IF (vExisteTkn is not null and vExisteTkn==vns_token) then
                                												
								--IF(vExisteTkn==vns_token) then
									UPDATE bdibei:"informix".bei_tokenexpira 
									SET id_status_solicitud = vid_status_solicitud
									WHERE id_usuario = vid_usuario AND num_cte = pNumCte;
								End if;			
					END IF;	

					IF(vid_tipo_usuario = 2) THEN
					   
						UPDATE bdibei:"informix".bei_tokenexpira
						SET id_status_solicitud = pStatus
						WHERE id_usuario = vid_usuario AND num_cte = pNumCte;

					END IF;
				END FOREACH;
				
	--	Else		
				
		--	LET vCodRet = '00001'; 
		
	--	END IF;
		RETURN vCodRet;

	END
END PROCEDURE;