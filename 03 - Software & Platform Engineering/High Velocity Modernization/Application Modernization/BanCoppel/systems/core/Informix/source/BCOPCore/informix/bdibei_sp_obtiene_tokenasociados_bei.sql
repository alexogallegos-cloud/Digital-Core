CREATE PROCEDURE "informix".sp_obtiene_tokenasociados_bei(pNumSolicitud char(10), pNumCliente char(9))
   returning char(5),char(9);
   
	--*************************************************************
	--Objetivo:Obtiene los tokens asociados ala solicitud.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--*************************************************************   
      

   -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vNstoken  char(9);
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vNsToken = '';
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_tokenasociados_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret,vNstoken;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pNumSolicitud <> "" AND pNumCliente <> ""  THEN  
			FOREACH
				SELECT ns_token 
				INTO vNstoken
				FROM "informix".bei_tokensolicitud
				WHERE solicitud=pNumSolicitud AND numcte=pNumCliente
				RETURN cod_ret,vNstoken WITH RESUME;
			END FOREACH;
			
			IF vNstoken=''THEN
				LET cod_ret='00002';
				RETURN cod_ret,vNstoken;
			END IF;
		ELSE
			LET cod_ret='00001';
			RETURN cod_ret,vNstoken;
		END IF;
	END;	
END PROCEDURE;