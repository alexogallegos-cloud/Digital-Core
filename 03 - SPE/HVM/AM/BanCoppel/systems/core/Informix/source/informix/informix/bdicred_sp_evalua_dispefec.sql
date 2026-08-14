CREATE PROCEDURE "informix".sp_evalua_dispefec()
    RETURNING CHAR(6),CHAR(150);

   -- Definicion de Variables  
   DEFINE CodRet               CHAR(6);
   DEFINE sql_err              SMALLINT;
   DEFINE isam_err             SMALLINT;
   DEFINE error_info           CHAR(40);
   DEFINE vMensaje             VARCHAR(150);
   DEFINE dFechaReporteCtesClean DATE;
   DEFINE cNumCredito			CHAR(20);
   DEFINE cIndDispAct			CHAR(1);
   DEFINE cIndDispIni			CHAR(1);
   DEFINE cGrupo				CHAR(1);
   DEFINE cEvaluaccSol			CHAR(1);
   DEFINE dFechaStatus			DATE;
   DEFINE cNumProducto			CHAR(4);
   DEFINE iPeriodoPorEvaluar	INTEGER;
   DEFINE sMesesBuenCompDisp	SMALLINT;
   DEFINE sClienteClean			SMALLINT;
   DEFINE dFechaHoy				DATE;
   DEFINE cEmpresa				CHAR(3);
   DEFINE dFechaAEvaluar		DATE;
   DEFINE iTotalCuentasProcesadas	INTEGER;
   DEFINE iTotalCuentasIndicador1	INTEGER;
   DEFINE iTotalCuentasIndicador2	INTEGER;
   DEFINE iTotalCuentasNoEvaluadas	INTEGER;
   DEFINE iTotalCuentasOtros		INTEGER;
   DEFINE iTotalCuentasYaProcesadas	INTEGER;
   DEFINE sExiste					SMALLINT;
   DEFINE cProceso				CHAR(04);
   DEFINE cMensaje     			CHAR(100);
   DEFINE P_COD_RET    			VARCHAR(6);
   DEFINE P_MENSAJE    VARCHAR(80);
   
   --- Declaracion de Variables
   LET vMensaje			= 'PROCESO EXITOSO.';
   LET CodRet			= '000000';
   LET dFechaReporteCtesClean = DATE(1);
   LET cNumCredito		= '';
   LET cIndDispAct		= '';
   LET cIndDispIni		= '';
   LET cGrupo			= '';
   LET cEvaluaccSol		= '';
   LET dFechaStatus		= DATE(1);
   LET cNumProducto		= '';
   LET iPeriodoPorEvaluar	= 0;
   LET sMesesBuenCompDisp	= 0;
   LET sClienteClean	= 0;
   LET dFechaHoy		= DATE(1);
   LET cEmpresa			= '001';
   LET dFechaAEvaluar	= DATE(1);
   LET iTotalCuentasProcesadas = 0;
   LET iTotalCuentasIndicador1 = 0;
   LET iTotalCuentasIndicador2 = 0;
   LET iTotalCuentasNoEvaluadas = 0;
   LET iTotalCuentasOtros		= 0;
   LET sExiste					= 0;
   LET iTotalCuentasYaProcesadas = 0;
   LET cProceso		= '0006';
   LET cMensaje    = '';
   LET P_COD_RET   = '000000';
   LET P_MENSAJE   = '';
  
BEGIN   
   ON EXCEPTION SET sql_err, isam_err, error_info
	IF sql_err != 0 THEN
      LET CodRet=sql_err;
	  LET vMensaje  = error_info||' ' ||trim(cNumCredito);
	  CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, CodRet, trim(vMensaje), '02') RETURNING P_COD_RET;
	  RETURN CodRet, vMensaje;
	  ROLLBACK WORK;
    END IF;   
   END EXCEPTION;	 

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, CodRet, cMensaje, '01') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
	END IF;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
--   SET DEBUG FILE TO "/RESPALDOSNEW/Ricardo/sp_evalua_dispefec.out";
--   TRACE ON;

   --Fecha Actual calculada a un aÃ±o
   SELECT fecha_hoy INTO dFechaHoy
   FROM bdicred:sd_fechas;
 	
	--Clientes Clean
	SELECT MAX(fecha_reporte) INTO dFechaReporteCtesClean 
	FROM bdicred:sd_clientes_clean_behavior
	WHERE status_bit IS NULL;

	SELECT a.num_credito, a.ind_disp_act, a.fecha_status, b.diferimiento_int, a.ind_disp_ini
	  FROM bdicred:sd_bitacora_dispefec a
	  INNER JOIN bdicred:sd_maecred b ON b.empresa=a.empresa and b.num_credito=a.num_credito and b.diferimiento_int > 0
	  INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c on c.grupo = a.grupo AND c.evalua_cc = a.evalua_cc AND c.num_producto = b.num_producto
	WHERE a.empresa = '001'
	AND a.num_credito > ''
--AND a.num_credito in
--('600566571284','600568364910','600565638597','600567477069')	
	AND a.fecha_insert < today - c.meses_buen_comp_disp units month
	AND a.fecha_status IS NULL
	INTO TEMP cuentas_aprocesar WITH NO LOG;
	
	INSERT INTO cuentas_aprocesar
	SELECT a.num_credito, a.ind_disp_act, a.fecha_status, b.diferimiento_int, a.ind_disp_ini
	  FROM bdicred:sd_bitacora_dispefec a
	  INNER JOIN bdicred:sd_maecred b ON b.empresa=a.empresa and b.num_credito=a.num_credito and b.diferimiento_int > 0
	  INNER JOIN bdicred:sd_tasas_disposiciones_diferenciadas c on c.grupo = a.grupo AND c.evalua_cc = a.evalua_cc AND c.num_producto = b.num_producto
	WHERE a.empresa = '001'
	AND a.num_credito > ''
--AND a.num_credito in
--('600566571284','600568364910','600565638597','600567477069')
	AND a.fecha_insert < today - c.meses_buen_comp_disp units month
	AND a.fecha_status < today - c.meses_buen_comp_disp units month;

	CREATE INDEX numcredito_tmp	ON cuentas_aprocesar(num_credito);

	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_aprocesar;
	
   --Para casos de indicadores de disposicion en efectivo 0% y 100%
	FOREACH WITH HOLD 	
		SELECT num_credito, ind_disp_act, fecha_status, ind_disp_ini
		INTO cNumCredito, cIndDispAct, dFechaStatus, cIndDispIni
		FROM cuentas_aprocesar
		
		IF cIndDispAct IS NULL OR cIndDispAct = '' THEN LET cIndDispAct = cIndDispIni; END IF;
		
		LET iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;

			BEGIN WORK;

			IF cIndDispAct = '1' THEN	-- Cliente clean
				SELECT COUNT(*)
				  INTO sClienteClean
				  FROM bdicred:sd_clientes_clean_behavior
				 WHERE fecha_reporte = dFechaReporteCtesClean
				   AND num_credito = cNumCredito
				   AND status_bit IS NULL;

				IF sClienteClean > 0 THEN
					UPDATE bdicred:sd_bitacora_dispefec 
					   SET	ind_disp_act = '2',
							fecha_status = today		   
					WHERE empresa = cEmpresa AND num_credito  = cNumCredito;

					UPDATE bdicred:"informix".sd_maecred 
					   SET diferimiento_int = 2
					 WHERE empresa = cEmpresa AND num_credito = cNumCredito;
				ELSE
					UPDATE bdicred:sd_bitacora_dispefec 
					   SET	ind_disp_act = '1',
							fecha_status = today		   
					WHERE empresa = cEmpresa AND num_credito  = cNumCredito;
				END IF
				
				UPDATE bdicred:"informix".sd_maesdos 
				   SET sdo_acum_vencido = 0
				WHERE empresa = cEmpresa AND num_credito = cNumCredito;

				LET iTotalCuentasIndicador1 = iTotalCuentasIndicador1 + 1;
 			ELIF cIndDispAct = 2 THEN	-- Sin restricciÃ³n
				UPDATE bdicred:sd_bitacora_dispefec 
				   SET	ind_disp_act = NULL,
						fecha_status = today		   
				WHERE empresa = cEmpresa AND num_credito  = cNumCredito;

				UPDATE bdicred:"informix".sd_maecred 
				   SET diferimiento_int = 0
				 WHERE empresa = cEmpresa AND num_credito = cNumCredito;

   				UPDATE bdicred:"informix".sd_maesdos 
				 SET sdo_acum_vencido = 0
				 WHERE empresa = cEmpresa AND num_credito = cNumCredito;

				LET iTotalCuentasIndicador2 = iTotalCuentasIndicador2 + 1;
			END IF;
			
			COMMIT WORK;
	   LET cNumCredito		= '';
	   LET cIndDispAct		= '';
	   LET cIndDispIni		= '';
	   LET dFechaStatus		= DATE(1);
	   LET cNumProducto		= '';
	   LET iPeriodoPorEvaluar	= 0;
	   LET sClienteClean	= 0;
	   LET dFechaAEvaluar	= DATE(1);
	   LET sExiste			= 0;
	END FOREACH

    let cMensaje = 'TOTAL cuentas procesadas: ' ||iTotalCuentasProcesadas;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, CodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    let cMensaje = 'Cuentas con indicador 1: ' ||iTotalCuentasIndicador1;
    let cMensaje = trim(cMensaje) ||'    Cuentas con indicador 2:  ' ||iTotalCuentasIndicador2;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, CodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, CodRet, cMensaje, '03') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN CodRet, vMensaje;
END 
END PROCEDURE;