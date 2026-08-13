CREATE PROCEDURE "informix".sp_depura_direcciones_ctes_sin_prod()
				RETURNING CHAR(5) AS cCodRet;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
--VARIABLES
DEFINE bCteValido		BOOLEAN;
DEFINE iTipoCte			SMALLINT;
DEFINE iTipoCtePros		SMALLINT;
DEFINE iCountReg		INTEGER;
DEFINE iCont			INTEGER;
DEFINE iMaxCommit		SMALLINT;
DEFINE cNumCte			CHAR(20);
DEFINE iSecuencia		INTEGER;
DEFINE iExisteCte		SMALLINT;
DEFINE iExisteTabla		SMALLINT;
DEFINE bContinuaProc	BOOLEAN;
DEFINE iCountRegTab		INTEGER;
DEFINE dHoraInicio		DATETIME HOUR TO MINUTE;
DEFINE dCurrentTime		DATETIME HOUR TO MINUTE;
DEFINE dMaxTime			INTEGER;
DEFINE intervalo 		INTERVAL minute(9) TO MINUTE;
DEFINE cadena 			VARCHAR(12);
DEFINE entero 			INTEGER;


--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET iTipoCte			= 1;
LET iTipoCtePros		= 2;
LET iCountReg 			= 0 ;	
LET iMaxCommit			= 5000;
LET cNumCte				= '';
LET bContinuaProc		= 't';
LET dHoraInicio			= CURRENT hour to minute;
LET dCurrentTime		= NULL;
LET dMaxTime			= 105;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_depura_direcciones_ctes_sin_prod.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_depura_direcciones_ctes_sin_prod.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones_actual), AVOID_FULL ("informix".si_cliente)}
		DISTINCT(d.numcte)
		INTO cNumCte
		FROM "informix".si_direcciones_actual d
		INNER JOIN "informix".si_cliente cte ON cte.numcte = d.numcte
		WHERE 
		d.fecha_insert = TODAY-1
		AND cte.tipo_cliente = iTipoCte
		
		--Se valida que se puedan depurar las direcciones del cliente, es decir, que dicho cliente no cuente con productos activos.
		EXECUTE PROCEDURE "informix".sp_valida_depura_direcciones_cte(cNumCte) INTO cCodRet, bCteValido;
		IF (cCodRet <> '00000') OR (bCteValido = 'f') THEN
			CONTINUE FOREACH;
		END IF;			
		
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones_actual)}
		COUNT(*)
		INTO iCountReg 
		FROM "informix".si_direcciones_actual
		WHERE numcte = cNumCte
		;
		
		IF iCountReg > 0 THEN
			--Se depuran las direcciones actuales del prospecto
			DELETE "informix".si_direcciones_actual 
			WHERE numcte = cNumCte;
			
			LET iCont = iCont + iCountReg;
		END IF;
			
		SELECT 
		{+AVOID_FULL ("informix".si_direcciones)}
		COUNT(*)
		INTO iCountReg 
		FROM "informix".si_direcciones
		WHERE numcte = cNumCte
		;
		
		IF iCountReg > 0 THEN
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones_his)}
			MAX(secuencia) 
			INTO iSecuencia
			FROM "informix".si_direcciones_his
			WHERE numcte = cNumCte;
			
			IF iSecuencia IS NULL OR iSecuencia = 0 THEN
				LET iSecuencia = 0;
			END IF;
			
			--Se respaldan los registros de la tabla si_direcciones a depurar
			INSERT INTO "informix".si_direcciones_his (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3)
			SELECT 
			{+AVOID_FULL ("informix".si_direcciones)}
			numcte, (secuencia + iSecuencia) as secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
			FROM "informix".si_direcciones
			WHERE numcte = cNumCte
			ORDER BY secuencia asc
			;
			
			--Se depuran las direcciones del prospecto
			DELETE "informix".si_direcciones
			WHERE numcte = cNumCte;
			
			SELECT
			COUNT(*)
			INTO iExisteCte
			FROM "informix".si_ctes_cambio_tpo_cliente_dep_dir
			WHERE numcte = cNumCte
			;
			
			--Se guarda el registro del cliente al cual se actualizo su tipo de cliente
			IF iExisteCte = 0 THEN
				INSERT INTO "informix".si_ctes_cambio_tpo_cliente_dep_dir (numcte, fecha_insert)
				VALUES (cNumCte, TODAY);
				
				LET iCont = iCont + 1;
			END IF;
			
			--Se modifica el tipo de cliente como prospecto
			UPDATE "informix".si_cliente
			SET tipo_cliente = iTipoCtePros
			WHERE numcte = cNumCte;
			
			LET iCont = iCont + (iCountReg * 2) + 1;
		END IF;
		
		IF iCont >= iMaxCommit THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	SELECT COUNT(*)
	INTO iExisteTabla
	FROM systables
	WHERE tabname = 'si_depura_drecciones_ctes_sin_prod'
	;
	
	IF iExisteTabla > 0 then
		LET iCont = 0;
		BEGIN WORK;
			WHILE (bContinuaProc) LOOP
				FOREACH WITH HOLD
					SELECT 
					{+AVOID_FULL ("informix".si_depura_drecciones_ctes_sin_prod)}
					numcte
					INTO cNumCte
					FROM "informix".si_depura_drecciones_ctes_sin_prod
					LIMIT 5000
					
					--Se valida que se puedan depurar las direcciones del cliente, es decir, que dicho cliente no cuente con productos activos.
					EXECUTE PROCEDURE "informix".sp_valida_depura_direcciones_cte(cNumCte) INTO cCodRet, bCteValido;
					IF (cCodRet <> '00000') OR (bCteValido = 'f') THEN
						DELETE "informix".si_depura_drecciones_ctes_sin_prod
						WHERE numcte = cNumCte;
						CONTINUE FOREACH;
					END IF;
					
					SELECT 
					{+AVOID_FULL ("informix".si_direcciones_actual)}
					COUNT(*)
					INTO iCountReg 
					FROM "informix".si_direcciones_actual
					WHERE numcte = cNumCte
					;
					
					IF iCountReg > 0 THEN
						--Se depuran las direcciones actuales del prospecto
						DELETE "informix".si_direcciones_actual 
						WHERE numcte = cNumCte;
						
						LET iCont = iCont + iCountReg;
					END IF;
						
					SELECT 
					{+AVOID_FULL ("informix".si_direcciones)}
					COUNT(*)
					INTO iCountReg 
					FROM "informix".si_direcciones
					WHERE numcte = cNumCte
					;
					
					IF iCountReg > 0 THEN
						SELECT 
						{+AVOID_FULL ("informix".si_direcciones_his)}
						MAX(secuencia) 
						INTO iSecuencia
						FROM "informix".si_direcciones_his
						WHERE numcte = cNumCte;
						
						IF iSecuencia IS NULL OR iSecuencia = 0 THEN
							LET iSecuencia = 0;
						END IF;
						
						--Se respaldan los registros de la tabla si_direcciones a depurar
						INSERT INTO "informix".si_direcciones_his (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3)
						SELECT 
						{+AVOID_FULL ("informix".si_direcciones)}
						numcte, (secuencia + iSecuencia) as secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
						FROM "informix".si_direcciones
						WHERE numcte = cNumCte
						ORDER BY secuencia asc
						;
						
						--Se depuran las direcciones del prospecto
						DELETE "informix".si_direcciones
						WHERE numcte = cNumCte;
						
						SELECT
						COUNT(*)
						INTO iExisteCte
						FROM "informix".si_ctes_cambio_tpo_cliente_dep_dir
						WHERE numcte = cNumCte
						;
						
						--Se guarda el registro del cliente al cual se actualizo su tipo de cliente
						IF iExisteCte = 0 THEN
							INSERT INTO "informix".si_ctes_cambio_tpo_cliente_dep_dir (numcte, fecha_insert)
							VALUES (cNumCte, TODAY);
							
							LET iCont = iCont + 1;
						END IF;
						
						--Se modifica el tipo de cliente como prospecto
						UPDATE "informix".si_cliente
						SET tipo_cliente = iTipoCtePros
						WHERE numcte = cNumCte;
						
						LET iCont = iCont + (iCountReg * 2) + 1;
					END IF;
					
					DELETE "informix".si_depura_drecciones_ctes_sin_prod
					WHERE numcte = cNumCte;
					
					LET iCont = iCont + 1;
					
					IF iCont >= iMaxCommit THEN
						LET iCont = 0;
						COMMIT WORK;
						BEGIN WORK;
					END IF;
				END FOREACH;
				
				--Se consulta si aun hay registros en la tabla si_depura_drecciones_ctes_sin_prod
				SELECT COUNT(*)
				INTO iCountRegTab
				FROM "informix".si_depura_drecciones_ctes_sin_prod
				;
				
				IF iCountRegTab = 0 THEN
					DROP TABLE IF EXISTS "informix".si_depura_drecciones_ctes_sin_prod;
					LET bContinuaProc = 'f';
				END IF;
				
				--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en caso de que haya llegado al limite establecido
				select 
				DBINFO('utc_to_datetime', sh_curtime) 
				into dCurrentTime
				from sysmaster:"informix".sysshmvals;
				
				LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
				LET cadena=intervalo::VARCHAR(12);
				LET entero=cadena::INTEGER;
				IF (entero >= dMaxTime) THEN
					LET bContinuaProc = 'f';
				END IF;
			END LOOP;
		COMMIT WORK;
	END IF;
	
	RETURN cCodRet;	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 22/03/2021',
'MODULO: Integral',
'BD: bdinteg',
'DESCRIPCION: Depura las direcciones de los clientes, tales que no cuentan con un producto activo de BanCoppel. Posteriormente a la depuraciÃ³n, cambia el tipo del cliente a 2 (prospecto).'
;

CREATE PROCEDURE "informix".sp_ws_obtiene_prod(
	cAgentTransTypeCode CHAR(10),
	cAgentCd CHAR(3),
	cUsuario CHAR(8),
	cPassword CHAR(8),
	cIpOrigen CHAR(15),
	cIdSession CHAR(30),
	cNumCte CHAR(20)
)
RETURNING 
  CHAR(4) AS cCodRet,
  CHAR(120) AS cMensajeResp,
  CHAR(4) AS cCodProd,
  CHAR(120) AS cDescProd,
  CHAR(255) AS cCausaRechazoBcpl,
  CHAR(255) AS cCausaRechazoCpl;
  
   
DEFINE sql_err INTEGER;
DEFINE vcodret1 CHAR(4);
DEFINE vdesc_msj CHAR(120);
DEFINE vcod_prod CHAR(4);
DEFINE vdesc_prod CHAR(120);
DEFINE vcausa_rechazo_bcpl CHAR(255);
DEFINE vcausa_rechazo_cpl CHAR(255);
DEFINE cSucursal CHAR(100);
DEFINE cEjecutivo CHAR(100);
DEFINE cPuesto CHAR(3);
	
LET vcodret1 = '0000';
LET vdesc_msj = '';
LET vcod_prod = '';
LET vdesc_prod = '';
LET vcausa_rechazo_bcpl = '';
LET vcausa_rechazo_cpl = '';
LET cSucursal = '';
LET cEjecutivo = '';
LET cPuesto = '';

	
    BEGIN
	
    ON EXCEPTION SET sql_err

		RETURN sql_err,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl, vcausa_rechazo_cpl;

    END EXCEPTION;

	 --SET DEBUG FILE TO '/informix/LIP/logs/sp_ws_obtiene_prod.out';
	 --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(cAgentTransTypeCode,'')) <> '' AND TRIM(NVL(cAgentCd, '')) <> '' AND TRIM(NVL(cUsuario,'')) <> '' AND TRIM(NVL(cPassword,'')) <> '' AND TRIM(NVL(cIpOrigen,'')) <> '' AND TRIM(NVL(cIdSession,'')) <> '' AND TRIM(NVL(cNumCte, '')) <> '' THEN
	
		--VALIDAR SESIÃ?Â?Ã?Â?N
		EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(cAgentTransTypeCode), TRIM(cAgentCd), TRIM(cUsuario), TRIM(cPassword), TRIM(cIpOrigen), TRIM(cIdSession) ) INTO vcodret1, vdesc_msj;

			IF TRIM(vcodret1) = '0000' THEN
				
				--CONSULTAR SUCURSAL
				SELECT valor INTO cSucursal FROM si_param WHERE cod_param = 480;
				
				--CONSULTAR EJECUTIVO
				SELECT valor INTO cEjecutivo FROM si_param WHERE cod_param = 481;
				
				--OBTENER PRODUCTOS
				EXECUTE PROCEDURE bdisolic:"informix".sp_determina_productos(cNumCte, cSucursal, cEjecutivo, 'E', '0', '0', '1', '1') INTO vcodret1, vcod_prod, vdesc_prod, vcausa_rechazo_bcpl;
				
				-- En el caso de tener un problema en la oferta, no se ofertará ningún producto.
				IF (vcod_prod is NULL or vcod_prod = '') THEN 
					LET vcod_prod = '0000';
					LET vdesc_prod = 'NINGUN PRODUCTO';
					LET vcausa_rechazo_bcpl = '';
				END IF;
				
				-- A PETICION DE OMNICANAL SIEMPRE SE REGRESA '0000'
				LET vcodret1 = '0000';
				
			END IF;
			
	ELSE
	
		LET vcodret1= "9996";
		LET vdesc_msj = "Uno de los parÃ?Â?Ã?Â¡metros de seguridad viene vacÃ?Â?Ã?Â­o";
		
	END IF;
	
	RETURN vcodret1,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl, vcausa_rechazo_cpl;
END;
END PROCEDURE;