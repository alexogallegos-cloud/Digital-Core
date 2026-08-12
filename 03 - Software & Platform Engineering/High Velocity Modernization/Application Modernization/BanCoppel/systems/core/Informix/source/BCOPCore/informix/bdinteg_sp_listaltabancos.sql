CREATE PROCEDURE "informix".sp_listaltabancos(pSkip		INTEGER,ptipoconsulta CHAR(1))

	RETURNING  CHAR(5), CHAR(20);   -- codigo retorno

	DEFINE vCodRet  		CHAR(5);
	DEFINE vCodRet2			CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vIsamErr			INTEGER;
	DEFINE vclave			CHAR(5);
	DEFINE vbanco			CHAR(20);
	
	LET vCodRet='00000';
	LET vSqlErr=0;
	LET vIsamErr=0;
	LET vclave='';
	LET vbanco='';
	
--	SET DEBUG FILE TO "/informix/Jess/sp_listaltabancos.out";
--  TRACE ON;

    BEGIN
		
		ON EXCEPTION SET vSqlErr, vIsamErr
--			SET DEBUG FILE TO "/informix/Jess/sp_listaltabancos.out";
--			TRACE ON;
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				LET vCodRet2 = vIsamErr;
            RETURN vCodRet, vbanco; 
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF ptipoconsulta = '1' THEN   -- CONSUTA TODOS
		
			FOREACH
			
				SELECT   SKIP pSkip LIMIT 10  cvecesif, vchrnombrecorto 
				INTO vclave, vbanco
				FROM si_bancos
				WHERE cvecesif is not null and cvecesif !=0
				ORDER BY vchrnombrecorto
			
				RETURN vclave, vbanco with resume;
			
			END FOREACH;
			
		ELIF ptipoconsulta = '2' THEN  -- CONSULTA SOLO ACTUALIZADOS
		
		    FOREACH
			
				SELECT  SKIP pSkip LIMIT 10 cvecesif, vchrnombrecorto 
				INTO vclave, vbanco
				FROM si_bancos
				WHERE cvecesif is not null and cvecesif !=0 and flg_spei='1' and fecha_opera = TODAY
				
				RETURN vclave, vbanco with resume;
			
			END FOREACH;
			
		ELIF ptipoconsulta = '3' THEN  -- CONSULTA SOLO BAJAS SPEI
		
		    FOREACH
			
				SELECT   SKIP pSkip LIMIT 10  cvecesif, vchrnombrecorto 
				INTO vclave, vbanco
				FROM si_bancos
				WHERE cvecesif is not null and cvecesif !=0 and flg_spei='0' and fecha_opera = TODAY
				ORDER BY vchrnombrecorto
			
				RETURN vclave, vbanco with resume;
			
			END FOREACH;
			
		ELSE
		   LET vCodRet='001';  -- TIPO DE CONSULTA INCORRECTA
		   LET vbanco='Operacion incorrecta';
		   RETURN vCodRet, vbanco;
		END IF;
	END;
END PROCEDURE;