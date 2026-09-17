CREATE PROCEDURE "informix".sp_reversa_tokenasociados_bei(pNumSolicitud char(10), pNumCliente char(9),pUserAtendio char(9),pCanal char(2))
   returning char(5);   
   --*************************************************************
	--Objetivo:elimina los tokens ala solicitud y se les cambia el estatus a disponibles.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--*************************************************************      
   -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vNstoken  char(9);
	DEFINE vStatusT char(3);
	DEFINE cod_ret_stausTkn char(5);	
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET cod_ret_stausTkn= '00000';
	LET vStatusT='000';
	
	--SET DEBUG FILE TO '/tmp/sp_reversa_tokenasociados_bei.out';
	--TRACE ON;
		
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
		  END IF ;
		END EXCEPTION ;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pNumSolicitud <> "" AND pNumCliente <> "" AND pUserAtendio<>""AND pCanal<>""  THEN  
			FOREACH
					SELECT ns_token,id_status
					INTO vNstoken,vStatusT
					FROM "informix".bei_tokensolicitud
					WHERE solicitud=pNumSolicitud 
					AND numcte=pNumCliente 
					AND id_status='120'
					
					IF NVL(vNstoken,'')<>'' THEN
							EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(vNstoken,vStatusT,'105',pUserAtendio,pCanal)
							INTO cod_ret_stausTkn;
						IF cod_ret_stausTkn <>'000'THEN
							-- ROLLBACK WORK;
							 LET cod_ret='00002'; --ERROR EN EL SP sp_set_statustoken_admtoken 
							 RETURN cod_ret;						
						END IF;
					ELSE
						LET cod_ret='00003' ;
						RETURN cod_ret;
					END IF;	
				DELETE "informix".bei_tokensolicitud WHERE ns_token=vNsToken AND solicitud=pNumSolicitud AND numcte=pNumCliente;
			END FOREACH;
		ELSE
			LET cod_ret='00001';
		END IF;
		
		RETURN cod_ret;
	END;	
END PROCEDURE;