CREATE PROCEDURE "informix".sp_ideconsultamovofi(pNumeroCliente CHAR(20), pFecha CHAR(6), pSigRegistro SMALLINT)
	RETURNING
		CHAR(5),    -- Codigo de Retorno
		DATE,       -- Fecha_mov Movimientos
		CHAR(20),   -- Num_cta Movimientos
		CHAR(4),    -- Sucursal Movimientos
		MONEY(16,2);
	--*******************************************************************************************************
			-- Modifico  : Clemente Angulo
			-- Actividad : Se valido el hecho que si el cliente presenta mas de 500 movimientos durante el mes, se manden subtotales diarios.
			-- Fecha        : 26 de Febrero de 2009
	--*******************************************************************************************************
			-- DEFINICION DE VARIABLES
			--MDY(1,1,1900);
		DEFINE vCantReg			SMALLINT;
		DEFINE vCodRet      	CHAR(5);
		DEFINE vCodRet2      	CHAR(5);
		DEFINE vCodRet3      	CHAR(50);
		DEFINE vFechamovM   	DATE;
		DEFINE vNumctaM     	CHAR(20);
		DEFINE vSucursalM   	CHAR(4);
		DEFINE vImpdepM     	MONEY(16,2);
		DEFINE vNumreg      	SMALLINT;
		DEFINE vContMovtos  	INTEGER;
		DEFINE vDiasMes			SMALLINT;
		DEFINE vCont			CHAR(2);
		DEFINE vTotDepDiarioM 	MONEY(16,2);
		DEFINE iSQL_ERR     	INTEGER;
		DEFINE isam_ERR     	INTEGER;
		define desc_err 		CHAR(50);
		DEFINE vMaxMovtos		CHAR(8);

		--INICIALIZACION DE VARIABLES--
		LET vCantReg = 0;
		LET vCodRet = "000";
		LET vNumctaM = "";
		LET vSucursalM = "";
		LET vImpdepM = 0;
		LET vTotDepDiarioM = 0;
		LET vNumreg = 0;
		LET vContMovtos = 0;
		LET vDiasMes = 0;
		LET vCont = "";
		LET vMaxMovtos = '';
		LET iSQL_ERR = 100;
		LET vFechamovM = MDY(1,1,1900);
		/*
		Se incializa variable vFechamovM...
		04/06/2010
		*/

	BEGIN
		ON EXCEPTION SET iSQL_ERR, isam_err, desc_err
			SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ideconsultamovofi.err';
			TRACE ON;
			LET vCodRet = iSQL_ERR;
			LET vCodRet2 = isam_ERR;
			LET vCodRet3 = desc_ERR;
			DROP TABLE tmp_movtos_lide;
			RETURN vCodRet, vFechamovM, vNumctaM, vSucursalM, vImpdepM;
		END EXCEPTION;

		--- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ideconsultamovofi.out';
		--- TRACE ON;

		IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp_movtos_lide') THEN
			DROP TABLE tmp_movtos_lide;
		END IF;

		SELECT valor
		INTO vMaxMovtos
		FROM bdilide:sl_parametros
		WHERE cve_param = '26';

		IF vMaxMovtos IS NULL THEN
			LET vCodRet = "200";
			LET vFechamovM = MDY(1,1,1900);
			RETURN vCodRet, vFechamovM, vNumctaM, vSucursalM, vImpdepM;
		END IF;

		SELECT COUNT(num_cta)
		INTO vContMovtos
		FROM bdilide:sl_movefec_his
		WHERE num_cte = pNumeroCliente
		AND aniomes = pFecha;

		IF vContMovtos IS NULL THEN
			LET vContMovtos = 0;
		END IF;

		IF vContMovtos <= (vMaxMovtos)::INT THEN

			FOREACH
				--SELECT a.fecha_mov, a.num_cta, a.sucursal, a.imp_tot_dep
				SELECT a.fecha_mov, a.num_cta, a.sucursal, a.imp_ide
				INTO vFechamovM, vNumctaM, vSucursalM, vImpdepM
				FROM bdilide:sl_movefec_his a
				WHERE a.num_cte = pNumeroCliente AND a.aniomes = pFecha
				ORDER BY a.fecha_mov

				LET vNumreg = vNumreg + 1;
				IF vNumreg <= pSigRegistro THEN
					CONTINUE FOREACH;
				END IF
				IF vFechamovM IS NULL THEN
					LET vFechamovM = MDY(1,1,1900);
				END IF;
				IF vNumctaM IS NULL THEN
					LET vNumctaM = "";
				END IF;
				IF vSucursalM IS NULL THEN
					LET vSucursalM = "";
				END IF;
				IF vImpdepM IS NULL THEN
					LET vImpdepM = 0;
				END IF;

				LET vCantReg = vCantReg + 1;
				RETURN vCodRet, vFechamovM, vNumctaM, vSucursalM, vImpdepM WITH RESUME;
			END FOREACH;
			IF vCantReg = 0 THEN
				LET vCodRet = "100";
				LET vFechamovM = MDY(1,1,1900);	
				LET vNumctaM = "";
				LET vSucursalM = "";
				LET vImpdepM = 0;
				RETURN vCodRet, vFechamovM, vNumctaM, vSucursalM, vImpdepM;
			END IF
		ELSE
			CREATE TEMP TABLE tmp_movtos_lide
			  ( 
			    num_cta CHAR(20), 
			    fecha_mov DATE, 
				totdepdia MONEY
		      ) WITH NO LOG;
			
			INSERT INTO tmp_movtos_lide (num_cta, fecha_mov, totdepdia)
			--SELECT num_cta, fecha_mov, SUM(imp_tot_dep)
			SELECT num_cta, fecha_mov, SUM(imp_ide)
			FROM bdilide:sl_movefec_his
			WHERE num_cte = pNumeroCliente
			AND aniomes = pFecha
			GROUP BY fecha_mov, num_cta;
			
			--- CREATE INDEX idx_tmpmovtoslide ON tmp_movtos_lide(fecha_mov, num_cta) USING BTREE FILLFACTOR 99;
			update statistics medium for table tmp_movtos_lide;

			FOREACH
				SELECT num_cta, fecha_mov, totdepdia
				INTO vNumctaM, vfechaMovM, vTotDepDiarioM
				FROM tmp_movtos_lide
				ORDER BY fecha_mov, num_cta

				IF vFechamovM IS NULL THEN
					LET vFechamovM = MDY(1,1,1900);
				END IF;
				IF vNumctaM IS NULL THEN
					LET vNumctaM = "";
				END IF;
				IF vTotDepDiarioM IS NULL THEN
					LET vTotDepDiarioM = 0;
				END IF;

				RETURN vCodRet, vFechamovM, vNumctaM, vSucursalM, vTotDepDiarioM WITH RESUME;
			END FOREACH;
			
			DROP TABLE tmp_movtos_lide;
		END IF;
	END;
	END PROCEDURE
	