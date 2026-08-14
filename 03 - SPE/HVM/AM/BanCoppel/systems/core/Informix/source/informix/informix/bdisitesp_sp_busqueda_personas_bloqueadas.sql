CREATE PROCEDURE "informix".sp_busqueda_personas_bloqueadas(pNom1 CHAR(26),	
															pNom2 CHAR(26),	
															pApellpaterno CHAR(26),
															pApellmaterno CHAR(26),
															pFechanac DATE) 	
	RETURNING 	CHAR(6);	
	
	--Definicion de las variables
	DEFINE CodRet      CHAR(6);
	DEFINE iExiste	   SMALLINT;
	DEFINE iSql_err    INT;
	DEFINE cValorCausa CHAR(100);
	DEFINE cNumCte     CHAR(20);
	
	--Asignacion de las variables
	LET CodRet = '000000';
	LET iExiste	= 0;
	LET iSql_err = 0;
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET CodRet = iSql_err;
                RETURN CodRet;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;


		--SET DEBUG FILE TO '/INFORMIXDUMP/sp_busqueda_personas_bloqueadas.out';    
		--TRACE ON;
		
		IF NVL(pNom1,"") <> ""  AND NVL(pApellpaterno,"") <> "" THEN 
			
			SELECT pf.numcte INTO cNumCte
      	    FROM bdinteg:"informix".si_ctepf pf, bdinteg:"informix".si_cliente cl
      	    WHERE cl.numcte = pf.numcte
            AND cl.nombre1 = pNom1
            AND cl.nombre2 = pNom2
            AND cl.apell_paterno = pApellpaterno
            AND cl.apell_materno = pApellmaterno
            AND pf.fecha_nac = pFechanac;
		
			SELECT valor INTO cValorCausa 
			FROM bdinteg:"informix".si_param 
			WHERE cod_param = '999';
		
			SELECT COUNT(causa) INTO iExiste 
			FROM bdisitesp:"informix".se_ctessitespcte 
			WHERE causa = cValorCausa 
			AND situacion = 'U' 
			AND numcte = cNumCte;
							
			IF (iExiste > 0) THEN
				LET CodRet = '000002';
			ELSE 
				LET CodRet = '000000'; --NO EXISTE EL CLIENTE EN LA LISTA BLOQUEADA
			END IF 

		ELSE 		
			LET CodRet = '000001'; --NO RECIBE LOS PARAMETROS CORRECTOS	
		END IF 	
		
		RETURN  CodRet;
			
	END;
END PROCEDURE
