CREATE PROCEDURE "informix".sp_obtiene_entidad_job()
							
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
DEFINE dHoraInicio		DATETIME HOUR TO MINUTE;
DEFINE dCurrentTime		DATETIME HOUR TO MINUTE;
DEFINE dMaxTime			INTEGER;
--VARIABLES
DEFINE intervalo 		INTERVAL minute(9) TO MINUTE;
DEFINE cadena 			VARCHAR(12);
DEFINE entero 			INTEGER;
DEFINE dFechaBitIfe		datetime year to fraction(3);
DEFINE dFechaInicio		DATE;
DEFINE dFechaFin		DATE;
DEFINE dFechIniLugNac	DATE;
DEFINE dFechFinLugNac	DATE;
DEFINE bContinuaProc	BOOLEAN;
DEFINE bContinuaProcCurp	BOOLEAN;
DEFINE iMaxActualizar	INTEGER;
DEFINE dFechaAyer		DATETIME YEAR TO SECOND;
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
LET dHoraInicio			= CURRENT hour to minute;
LET dCurrentTime		= NULL;
LET dMaxTime			= 90;
LET dFechaBitIfe		= NULL;
LET dFechaInicio		= NULL;
LET dFechaFin			= NULL;
LET dFechIniLugNac		= NULL;
LET dFechFinLugNac		= NULL;
LET bContinuaProc		= 't';
LET bContinuaProcCurp	= 't';
LET iMaxActualizar		= 200000;
LET dFechaAyer			= CAST(TODAY-2 AS DATETIME YEAR TO SECOND);
LET iExistePf			= 0;
LET iMaxCommit			= 500;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_obtiene_entidad_job.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_obtiene_entidad_job.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se actualiza el campo CURP para los clientes tales que el dÃ­a de ayer se registro un registro en si_bitacora_ife
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		DISTINCT(a.numcte)
		INTO cNumCte
		FROM "informix".si_cliente a
		INNER JOIN "informix".si_ctepf pf ON pf.numcte=a.numcte
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=a.numcte
		WHERE 
		a.tipo_cliente=1
		AND a.tpo_persona='01'
		AND a.fecha_alta < TODAY-2
		AND (pf.curp IS NULL OR pf.curp = '' OR LENGTH(pf.curp) <> 18)
		AND btf.fecha >= dFechaAyer
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND btf.cadena_anverso LIKE '%CURP: %'
		AND INSTR(SUBSTRING (btf.cadena_anverso FROM (CHARINDEX('CURP: ',btf.cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
		
		--Se actualiza el campo CURP
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
			AND cadena_anverso LIKE '%CURP: %'
			AND INSTR(SUBSTRING (cadena_anverso FROM (CHARINDEX('CURP: ',cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
			ORDER BY fecha DESC
			limit 1
					
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
	
	--Se actualiza el campo lugar de nacimiento para los clientes tales que el dÃ­a de ayer se registro un registro en si_bitacora_ife
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		DISTINCT(a.numcte)
		INTO cNumCte
		FROM "informix".si_cliente a
		INNER JOIN "informix".si_ctepf pf ON pf.numcte=a.numcte
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=a.numcte
		WHERE 
		a.tipo_cliente=1
		AND a.tpo_persona='01'
		AND a.fecha_alta < TODAY-2
		AND (pf.lugar_nac IS NULL OR pf.lugar_nac = '' OR pf.lugar_nac = '00')
		AND btf.fecha >= dFechaAyer
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND (btf.cadena_anverso LIKE '%ID_NUMBER: %' OR btf.cadena_anverso LIKE '%ELECTOR_ID: %')
		
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
	
	--Se obtiene el valor de la fecha de inicio para actualizar el campo curp
	SELECT 
	TO_DATE(valor, "%d/%m/%Y")
	INTO dFechaFin
	FROM "informix".si_param
	WHERE descripcion ='Fecha ini act curp SPL sp_obtiene_entidad_job'
	;


	LET iCont = 0;
	BEGIN WORK;
	WHILE (bContinuaProc AND bContinuaProcCurp) LOOP
	
		LET dFechaInicio = dFechaFin;
		LET dFechaFin = dFechaInicio + 30 UNITS DAY;
		
		IF (dFechaFin > TODAY) THEN
			LET dFechaFin =TODAY;
		END IF;

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente)}
			a.numcte
			INTO cNumCte
			FROM "informix".si_cliente a
			WHERE 
			a.tipo_cliente=1
			AND a.fecha_alta BETWEEN dFechaInicio AND dFechaFin
			
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

			--Se actualiza el campo CURP
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
				AND cadena_anverso LIKE '%CURP: %'
				AND INSTR(SUBSTRING (cadena_anverso FROM (CHARINDEX('CURP: ',cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
				ORDER BY fecha DESC
				limit 1
						
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
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en caso de que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF( (entero >= dMaxTime) OR (dFechaFin = TODAY) OR (iActualizados >= iMaxActualizar)) THEN
			LET bContinuaProcCurp = 'f';
			IF( entero >= dMaxTime ) THEN
				LET bContinuaProc = 'f';
			END IF;
			--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecuciÃ³n comience en dicho dÃ­a
			UPDATE 
			"informix".si_param 
			SET valor = TO_CHAR(dFechaFin, '%d/%m/%Y')
			WHERE descripcion ='Fecha ini act curp SPL sp_obtiene_entidad_job'
			;
		END IF;
	END LOOP;
	COMMIT WORK;
	

	--Se obtiene el valor de la fecha de inicio para actualizar el lugar de nacimiento
	SELECT 
	TO_DATE(valor, "%d/%m/%Y")
	INTO dFechFinLugNac
	FROM "informix".si_param
	WHERE descripcion ='Fecha ini act lug nac SPL sp_obtiene_entidad_job'
	;

	LET iCont = 0;
	BEGIN WORK;
	WHILE (bContinuaProc) LOOP
	
		LET dFechIniLugNac = dFechFinLugNac;
		LET dFechFinLugNac = dFechIniLugNac + 30 UNITS DAY;
		
		IF (dFechFinLugNac > TODAY) THEN
			LET dFechFinLugNac =TODAY;
		END IF;

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente)}
			a.numcte
			INTO cNumCte
			FROM "informix".si_cliente a
			WHERE 
			a.tipo_cliente=1
			AND a.fecha_alta BETWEEN dFechIniLugNac AND dFechFinLugNac
			
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
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en casod e que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF( (entero >= dMaxTime) OR (dFechFinLugNac = TODAY) OR (iLugNacAct >= iMaxActualizar)) THEN
			LET bContinuaProc = 'f';
			--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecuciÃ³n comience en dicho dÃ­a
			UPDATE 
			"informix".si_param 
			SET valor = TO_CHAR(dFechFinLugNac, '%d/%m/%Y')
			WHERE descripcion ='Fecha ini act lug nac SPL sp_obtiene_entidad_job'
			;
		END IF;
	END LOOP;
	COMMIT WORK;
	
	RETURN cCodRet;
	
END;

END PROCEDURE;