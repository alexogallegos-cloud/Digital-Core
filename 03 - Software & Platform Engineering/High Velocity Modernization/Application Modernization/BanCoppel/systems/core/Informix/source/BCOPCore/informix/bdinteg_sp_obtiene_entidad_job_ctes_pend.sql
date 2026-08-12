CREATE PROCEDURE "informix".sp_obtiene_entidad_job_ctes_pend()
							
				RETURNING CHAR(5)     AS Cod_Retorno;
				
										
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumCte 			CHAR(10);	
DEFINE cCad_Anv 		CHAR(2200);
DEFINE iCad_Anv 		INT;
DEFINE cCad_Entidad		CHAR(20);
DEFINE iCont			SMALLINT;
DEFINE iActualizados	INTEGER;
DEFINE iLugNacAct		INTEGER;
--VARIABLES
DEFINE dFechaBitIfe		datetime year to fraction(3);
DEFINE iExistePf		SMALLINT;
DEFINE iMaxCommit		INTEGER;



--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET cNumCte 			= '';	
LET cCad_Anv 	 		= '';
LET iCad_Anv 			= 0;
LET cCad_Entidad		= '';
LET iCont 				= 0;
LET iActualizados 		= 0;
LET iLugNacAct 			= 0;
LET dFechaBitIfe		= NULL;
LET iExistePf			= 0;
LET iMaxCommit			= 500;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_obtiene_entidad_job_ctes_pend.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_obtiene_entidad_job_ctes_pend.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".tmp_ctes_act_curp)}
		a.numcte
		INTO cNumCte
		FROM "informix".tmp_ctes_act_curp a
		
		SELECT 
		{+AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		count(1)
		INTO iExistePf
		FROM "informix".si_ctepf pf
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=pf.numcte
		WHERE pf.numcte = cNumCte
		AND (pf.curp IS NULL OR pf.curp = '' OR LENGTH(pf.curp) <> 18)
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND btf.cadena_anverso LIKE '%CURP: %'
		AND INSTR(SUBSTRING (btf.cadena_anverso FROM (CHARINDEX('CURP: ',btf.cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
		;
		
		IF (iExistePf IS NULL OR iExistePf=0 ) THEN
			CONTINUE FOREACH;
		END IF;

		
		FOREACH WITH HOLD
			--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL CURP
			SELECT	
			{+AVOID_FULL ("informix".si_bitacora_ife)}
			cadena_anverso, fecha
			INTO cCad_Anv, dFechaBitIfe
			FROM "informix".si_bitacora_ife
			WHERE numcte = cNumCte
			AND cadena_anverso IS NOT NULL
			AND cadena_anverso <> ''
			AND cadena_anverso LIKE '%CURP: %'
			AND INSTR(SUBSTRING (cadena_anverso FROM (CHARINDEX('CURP: ',cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
			ORDER BY fecha DESC
					
			--SE EXTRAE EL CURP: Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
			LET cCad_Anv = TRIM(cCad_Anv);
			LET iCad_Anv = CHARINDEX('CURP: ',cCad_Anv);
			LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 6 FOR 18);
			LET cCad_Entidad = TRIM(cCad_Entidad);
			
			IF LENGTH(cCad_Entidad) <> 18 THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;
			
			--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
			IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;
			
			--Se fuerza la terminaciÃ³n del segundo for each
			EXIT FOREACH;
		END FOREACH;
		
		IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
			UPDATE "informix".si_ctepf 
			SET curp = cCad_Entidad
			WHERE numcte = cNumCte;
				
			UPDATE "informix".si_bitacora_ife 
			SET actualizado = '2'
			WHERE numcte = cNumCte
			AND fecha = dFechaBitIfe;
			
			LET cCad_Entidad='';

			LET iCont=iCont+2;
				
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
			LET iActualizados=iActualizados+1;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	--Se actualiza el campo lugar de nacimiento
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".tmp_ctes_act_curp)}
		a.numcte
		INTO cNumCte
		FROM "informix".tmp_ctes_act_curp a
		
		SELECT 
		{+AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		count(1)
		INTO iExistePf
		FROM "informix".si_ctepf pf
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=pf.numcte
		WHERE pf.numcte = cNumCte
		AND (pf.lugar_nac IS NULL OR pf.lugar_nac = '' OR pf.lugar_nac = '00')
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND (btf.cadena_anverso LIKE '%ID_NUMBER: %' OR btf.cadena_anverso LIKE '%ELECTOR_ID: %')
		;
		
		IF (iExistePf IS NULL OR iExistePf=0 ) THEN
			CONTINUE FOREACH;
		END IF;

		
		--Se actualiza el campo lugar de nacimiento
		FOREACH WITH HOLD
			--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL ID_NUMBER
			SELECT	
			{+AVOID_FULL ("informix".si_bitacora_ife)}
			cadena_anverso, fecha
			INTO cCad_Anv, dFechaBitIfe
			FROM "informix".si_bitacora_ife
			WHERE numcte = cNumCte
			AND cadena_anverso IS NOT NULL
			AND cadena_anverso <> ''
			AND (cadena_anverso LIKE '%ID_NUMBER: %' OR cadena_anverso LIKE '%ELECTOR_ID: %')
			ORDER BY fecha DESC
					
			--SE EXTRAE EL ID_NUMBER Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
			LET cCad_Anv = TRIM(cCad_Anv);
			LET iCad_Anv = CHARINDEX('ID_NUMBER: ',cCad_Anv);
			LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 11 FOR 14);
			
			--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
			IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
			
				LET iCad_Anv = CHARINDEX('ELECTOR_ID: ',cCad_Anv);
				LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 12 FOR 14);
				
				--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO	
				IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
					LET cCad_Entidad='';
					CONTINUE FOREACH;
				END IF;
			END IF;
			LET cCad_Entidad = SUBSTRING (cCad_Entidad FROM 13 FOR 2);
			--Se valida que el valor del lugar de nacimiento se encuentre enntre los valores 01,02,03.... 33
			IF cCad_Entidad NOT IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33')  THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;			
			--Se fuerza la terminaciÃ³n del segundo for each
			EXIT FOREACH;
		END FOREACH;
		
		IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
			UPDATE "informix".si_ctepf 
			SET lugar_nac = cCad_Entidad
			WHERE numcte = cNumCte;
				
			UPDATE "informix".si_bitacora_ife 
			SET actualizado = '1'
			WHERE numcte = cNumCte
			AND fecha = dFechaBitIfe;
			
			LET cCad_Entidad='';

			LET iCont=iCont+2;
				
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
			LET iLugNacAct=iLugNacAct+1;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	
	RETURN cCodRet;
	
END;

END PROCEDURE;