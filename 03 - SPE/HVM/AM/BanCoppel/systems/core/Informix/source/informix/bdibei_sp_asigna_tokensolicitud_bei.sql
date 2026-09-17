CREATE PROCEDURE "informix".sp_asigna_tokensolicitud_bei(pNseries char(90), pNumSolicitud char(10), pNumCliente char(9),  pStatus char(6))
   RETURNING char(5);   
	--*************************************************************
	--Objetivo: Asigna tokens ala solicitud.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--*************************************************************
   -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vNstoken  char(9);
	DEFINE vLength    smallint;
	DEFINE vContador smallint;
	DEFINE vVar	smallint;
	DEFINE i INTEGER;
	DEFINE vTrama char(90);
	
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vNsToken = '';
	LET vLength = 0;
	LET vContador=0;
	LET vVar=0;
	LET i=1;
	LET vLength = LENGTH(pNseries);
	LET vContador = vLength/9;
	LET vTrama = pNseries;
	
	-- SET DEBUG FILE TO '/tmp/sp_asigna_tokensolicitud_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pNseries <> "" AND pNumSolicitud <> "" AND pNumCliente <> "" AND pStatus <> "" THEN  
			WHILE(vVar < vContador)
				
				LET vNsToken = SUBSTRING(TRIM(vTrama) FROM i FOR 9);
				LET i = i + 9;
				LET vVar= vVAr + 1;
				INSERT INTO "informix".bei_tokensolicitud (ns_token,solicitud,numcte,id_status) VALUES (vNsToken,pNumSolicitud,pNumCliente,pStatus);

			END WHILE;
		ELSE
			LET cod_ret='00001';
		END IF;
		RETURN cod_ret;
	END;	
END PROCEDURE;