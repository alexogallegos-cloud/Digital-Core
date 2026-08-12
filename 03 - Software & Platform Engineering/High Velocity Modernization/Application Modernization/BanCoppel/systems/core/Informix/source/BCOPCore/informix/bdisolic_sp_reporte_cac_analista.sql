CREATE PROCEDURE "informix".sp_reporte_cac_analista
(
pFechaInicial CHAR(10),
pFechaFinal CHAR(10)
)
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(80) 	AS descripcion,
	CHAR(8) 		AS num_empleado,
    VARCHAR(45) 	AS nom_empleado,
    INTEGER 		AS num_atendidas,
    DECIMAL(5,2) 	AS porc_atendidas,
    INTEGER 		AS num_compingval,
    DECIMAL(5,2) 	AS porc_compingval,
    INTEGER 		AS num_compingnoval,
    DECIMAL(5,2) 	AS porc_compingnoval,
    DECIMAL(18,2) 	AS lincredprom;


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			VARCHAR(80);
    DEFINE cCodRet				CHAR(6);
    DEFINE cMensajeRet			VARCHAR(80);
	DEFINE cNumEmpleado 		CHAR(8);
    DEFINE vcNomEmpleado		VARCHAR(45);
    DEFINE iNumAtendidas		INTEGER;
    DEFINE dPorcAtendidas		DECIMAL(5,2);
    DEFINE iNumCompIngVal		INTEGER;
    DEFINE dPorcCompIngVal		DECIMAL(5,2);
    DEFINE iNumCompIngNoVal 	INTEGER;
    DEFINE dPorcCompIngNoVal 	DECIMAL(5,2);
    DEFINE dLinCredProm 		DECIMAL(18,2);
	DEFINE cBandExitosa			CHAR(1);


	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cNumEmpleado 		= '';
    LET vcNomEmpleado		= '';
    LET iNumAtendidas		= 0;
    LET dPorcAtendidas		= 0.0;
    LET iNumCompIngVal		= 0;
    LET dPorcCompIngVal		= 0.0;
    LET iNumCompIngNoVal 	= 0;
    LET dPorcCompIngNoVal 	= 0.0;
    LET dLinCredProm 		= 0.0;
	LET cBandExitosa		= 'N';



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN TRIM(cCodRet), cMensajeRet, NVL(cNumEmpleado,''), NVL(vcNomEmpleado,''), NVL(iNumAtendidas,0), NVL(dPorcAtendidas,0.0), NVL(iNumCompIngVal,0), NVL(dPorcCompIngVal,0.0), NVL(iNumCompIngNoVal,0), NVL(dPorcCompIngNoVal,0.0), NVL(dLinCredProm,0.0) WITH RESUME;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/has/sp_reporte_cac_analista.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE
		IF pFechaInicial > pFechaFinal THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
		ELSE
			-- INICIALIZA LA TABLA DEL REPORTE
			DELETE "informix".tmp_rlc_reporteanalista;

			INSERT INTO "informix".tmp_rlc_reporteanalista (num_empleado, nom_empleado, num_atendidas, porc_atendidas, num_compingval, porc_compingval, num_compingnoval, porc_compingnoval, lincredprom)
			SELECT a.ejecutivo_autoriza, b.nombre,
			COUNT(a.empresa) AS atendidas, 0.0 AS porc_atendidas,
			SUM(CASE WHEN NVL(a.comprobante_valido_cac,'') = 'S' THEN 1 ELSE 0 END) AS comp_ing_val, 0.0 AS porc_compingval,
			SUM(CASE WHEN NVL(a.comprobante_valido_cac,'') = 'N' THEN 1 ELSE 0 END) AS comp_ing_no_val, 0.0 AS porc_compingnoval,
			(SUM(c.monto_solicitado)/COUNT(a.empresa)) AS linea_prom
			FROM "informix".ss_solicitudes_cac a, bdinteg:"informix".si_ejecut b, "informix".ss_solicitudes c
			WHERE a.ejecutivo_autoriza = b.ejecutivo
			AND a.fecha_insert::DATE >= pFechaInicial AND a.fecha_insert::DATE <= pFechaFinal
			AND c.empresa = '001' and c.num_solicitud = a.num_solicitud
			GROUP BY a.ejecutivo_autoriza,b.nombre;
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'NO HAY DATOS PARA ESTE REPORTE, VERIFICAR FECHAS';
			ELSE
				-- OBTIENE EL NUMERO TOTAL DE ATENDIDAS
				SELECT SUM(num_atendidas)
				INTO iNumAtendidas
				FROM "informix".tmp_rlc_reporteanalista;
				-- ACTUALIZA LOS PORCENTAJES
				--dsb-30-11-2012
				/*UPDATE "informix".tmp_rlc_reporteanalista
				SET porc_atendidas = (num_atendidas/iNumAtendidas)*100, porc_compingval = (num_compingval/iNumAtendidas)*100, porc_compingnoval = (num_compingnoval/iNumAtendidas)*100;
				
				-- AGREGA LA FILA DEL TOTAL
				INSERT INTO "informix".tmp_rlc_reporteanalista (num_empleado, nom_empleado, num_atendidas, porc_atendidas, num_compingval, porc_compingval, num_compingnoval, porc_compingnoval, lincredprom)
				SELECT 'Total','',SUM(num_atendidas), SUM(porc_atendidas), SUM(num_compingval), SUM(porc_compingval), SUM(num_compingnoval), SUM(porc_compingnoval), SUM(lincredprom)
				FROM "informix".tmp_rlc_reporteanalista;*/
				
				-- ACTUALIZA LOS PORCENTAJES
				UPDATE "informix".tmp_rlc_reporteanalista
				SET porc_atendidas = (num_atendidas/iNumAtendidas)*100, porc_compingval = (num_compingval/num_atendidas)*100, porc_compingnoval = (num_compingnoval/num_atendidas)*100;
				
				-- AGREGA LA FILA DEL TOTAL
				INSERT INTO "informix".tmp_rlc_reporteanalista (num_empleado, nom_empleado, num_atendidas, porc_atendidas, num_compingval, porc_compingval, num_compingnoval, porc_compingnoval, lincredprom)
				SELECT 'Total','',SUM(num_atendidas), SUM(porc_atendidas), SUM(num_compingval),(SUM(num_compingval)/SUM(num_atendidas)*100)  , SUM(num_compingnoval), (SUM(num_compingnoval)/SUM(num_atendidas))*100, SUM(lincredprom)
				FROM "informix".tmp_rlc_reporteanalista;

				-- OBTIENE EL REPORTE
				FOREACH
					SELECT num_empleado, nom_empleado, num_atendidas, porc_atendidas, num_compingval, porc_compingval, num_compingnoval, porc_compingnoval, lincredprom
					INTO cNumEmpleado, vcNomEmpleado, iNumAtendidas, dPorcAtendidas, iNumCompIngVal, dPorcCompIngVal, iNumCompIngNoVal, dPorcCompIngNoVal, dLinCredProm
					FROM "informix".tmp_rlc_reporteanalista

					LET cBandExitosa = 'S';

					IF cNumEmpleado = 'Total' THEN
						LET dPorcAtendidas = ROUND(dPorcAtendidas);
					END IF

					RETURN TRIM(cCodRet), cMensajeRet, NVL(cNumEmpleado,''), NVL(vcNomEmpleado,''), NVL(iNumAtendidas,0), NVL(dPorcAtendidas,0.0), NVL(iNumCompIngVal,0), NVL(dPorcCompIngVal,0.0), NVL(iNumCompIngNoVal,0), NVL(dPorcCompIngNoVal,0.0), NVL(dLinCredProm,0.0) WITH RESUME;
				END FOREACH
		    END IF
		END IF
	END IF

	IF cBandExitosa = 'N' THEN
		RETURN TRIM(cCodRet), cMensajeRet, NVL(cNumEmpleado,''), NVL(vcNomEmpleado,''), NVL(iNumAtendidas,0), NVL(dPorcAtendidas,0.0), NVL(iNumCompIngVal,0), NVL(dPorcCompIngVal,0.0), NVL(iNumCompIngNoVal,0), NVL(dPorcCompIngNoVal,0.0), NVL(dLinCredProm,0.0) WITH RESUME;
	END IF
END;
END PROCEDURE
