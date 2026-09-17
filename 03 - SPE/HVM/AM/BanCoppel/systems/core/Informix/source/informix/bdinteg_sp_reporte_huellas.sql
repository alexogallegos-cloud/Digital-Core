CREATE PROCEDURE "informix".sp_reporte_huellas(pFechaIni DATE,pFechaFin DATE)
	RETURNING
	CHAR(6) 	AS 	COD_RET,
	CHAR(80) 	AS MENSAJE_RET;

	--DECLARACION DE VARIABLES
	DEFINE cCodret 		 	CHAR(6);
	DEFINE iSqlErr        	INTEGER;
	DEFINE cMensaje       	CHAR(80);
	DEFINE cNumCte1			CHAR(20);
	DEFINE cApellPat1		CHAR(26);
	DEFINE cApellMat1		CHAR(26);
	DEFINE cNom1			CHAR(26);
	DEFINE cNom2			CHAR(26);
	DEFINE cRFC1			CHAR(13);
	DEFINE dtFechaNac1		DATE;
	DEFINE cNumCte2			VARCHAR(9);
	DEFINE cApellPat2		CHAR(26);
	DEFINE cApellMat2		CHAR(26);
	DEFINE cNom1_2			CHAR(26);
	DEFINE cNom2_2			CHAR(26);
	DEFINE cRFC2			CHAR(13);
	DEFINE dtFechaNac2		DATE;
	DEFINE cTicket			CHAR(20);
	DEFINE dtFechaCons		DATE;
	
--{+OPTIMIZACION STK202310-12}
	DEFINE pRegsxTransaccion		INTEGER;
	DEFINE dtFechaInsert			DATETIME YEAR TO FRACTION(3);
	DEFINE iCont					INTEGER;
--{+OPTIMIZACION STK202310-12}

	--INICIALIZACION DE VARIABLES
	LET cCodret			= '00000';
	LET iSqlErr 		= 0;
	LET cMensaje		= 'PROCESO EXITOSO';
	LET cNumCte1		= '';
	LET cApellPat1		= '';
	LET cApellMat1		= '';
	LET cNom1			= '';
	LET cNom2			= '';
	LET cRFC1			= '';
	LET dtFechaNac1		= DATE(1);
	LET cNumCte2		= '';
	LET cApellPat2		= '';
	LET cApellMat2		= '';
	LET cNom1_2			= '';
	LET cNom2_2			= '';
	LET cRFC2			= '';
	LET dtFechaNac2		= DATE(1);
	LET cTicket			= '';
	LET dtFechaCons		= DATE(1);
	LET dtFechaInsert	= DATE(1);

--{+OPTIMIZACION STK202310-12}
	LET pRegsxTransaccion	  = 2000;  --valor en codigo duro para el control de la transaccion, sugerido por el area de BD de BanCoppel
	LET iCont				  = 0;
--{+OPTIMIZACION STK202310-12}

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET cMensaje = "ERROR NO CONTROLADO";
			RETURN cCodret, cMensaje;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--{+OPTIMIZACION STK202310-12}

	SELECT 
		lpad(TRIM(cliente::CHAR(9)), 9,'0') cliente, ticket ticket, fecha fecha, num_mensaje num_mensaje, empresa empresa
	FROM si_huella_linea_resultado
	WHERE fecha >= pFechaIni and fecha <= pFechaFin
	AND num_mensaje = '602' AND empresa = '5'
	INTO TEMP temp_si_huella_linea_resultado WITH NO LOG;

	CREATE INDEX "informix".idx_temp_si_huella_linea_resultado
		ON "informix".temp_si_huella_linea_resultado(cliente) ONLINE;

	SELECT 
		DISTINCT a.cliente numcte2, a.ticket, a.fecha,
					cte1.apell_paterno apell_pat_2,cte1.apell_materno apell_mat_2, cte1.nombre1 nom1_2, cte1.nombre2 nom2_2,
					cte1.rfc rfc_2,
					pf.fecha_nac fecha_nac2
	FROM temp_si_huella_linea_resultado a, si_cliente cte1, si_ctepf pf
	WHERE a.cliente = cte1.numcte
	AND a.cliente = pf.numcte and pf.fecha_nac <= '01-01-1995'
	AND a.cliente = cte1.numcte
	INTO TEMP clientes_bcpl_dupl_2 WITH NO LOG;

	CREATE INDEX "informix".idx_clientes_bcpl_dupl_2
		ON "informix".clientes_bcpl_dupl_2(ticket, fecha) ONLINE;

	SET ISOLATION TO DIRTY READ;
	SELECT 
		a.numcte numcte1, a.ticket, a.fecha_consulta, cte1.apell_paterno apell_pat_1, cte1.apell_materno apell_mat_1,
		cte1.nombre1 nom1_1, cte1.nombre2 nom2_1, cte1.rfc rfc_1, pf.fecha_nac fecha_nac1
	FROM si_huella_linea a, si_cliente cte1, si_ctepf pf
	WHERE a.fecha_consulta >= pFechaIni and a.fecha_consulta <= pFechaFin
	AND a.ticket IN (SELECT ticket FROM clientes_bcpl_dupl_2)
	AND a.numcte = cte1.numcte
	AND a.numcte = pf.numcte
	INTO TEMP clientes_bcpl_dupl_1 WITH NO LOG;

	CREATE INDEX "informix".idx_clientes_bcpl_dupl_1
		ON "informix".clientes_bcpl_dupl_1(ticket, fecha_consulta) ONLINE;

	BEGIN WORK;
	LET iCont = 0;
	FOREACH WITH HOLD
		SELECT 
				a.numcte1, a.apell_pat_1, a.apell_mat_1, a.nom1_1, a.nom2_1, a.rfc_1, a.fecha_nac1, b.numcte2,
				b.apell_pat_2, b.apell_mat_2, b.nom1_2, b.nom2_2, b.rfc_2, b.fecha_nac2, a.ticket, a.fecha_consulta, CURRENT AS fecha_insert
			INTO cNumCte1, cApellPat1, cApellMat1, cNom1, cNom2, cRFC1, dtFechaNac1, cNumCte2,
					cApellPat2, cApellMat2, cNom1_2, cNom2_2, cRFC2, dtFechaNac2, cTicket, dtFechaCons, dtFechaInsert
			FROM clientes_bcpl_dupl_1 a, clientes_bcpl_dupl_2 b
			WHERE a.ticket = b.ticket
			AND a.fecha_consulta = b.fecha

		INSERT INTO "informix".si_clientes_huellas_dupl(numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1, rfc_1, fecha_nac1, numcte2,
									apell_pat_2, apell_mat_2, nom1_2, nom2_2, rfc_2, fecha_nac2, ticket, fecha_consulta, fecha_insert)
		VALUES(cNumCte1, cApellPat1, cApellMat1, cNom1, cNom2, cRFC1, dtFechaNac1, cNumCte2,
				cApellPat2, cApellMat2, cNom1_2, cNom2_2, cRFC2, dtFechaNac2, cTicket, dtFechaCons, dtFechaInsert);

		LET iCont = iCont + 1;
		IF iCont = pRegsxTransaccion THEN
			COMMIT WORK;
			LET iCont = 0;
			BEGIN WORK;
		END IF;
	END FOREACH;
	COMMIT WORK;

	--{+OPTIMIZACION STK202310-12}

	EXECUTE PROCEDURE "informix".sp_compara_nombres()
	INTO cCodret;

	RETURN cCodret, cMensaje;
END;
END PROCEDURE;