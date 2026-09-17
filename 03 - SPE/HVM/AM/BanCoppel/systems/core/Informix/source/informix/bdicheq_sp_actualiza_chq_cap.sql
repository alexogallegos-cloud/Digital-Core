CREATE PROCEDURE "informix".sp_actualiza_chq_cap(pTipoProc CHAR(3), pFechaInicio DATE, pFechaFin DATE)

    RETURNING
    CHAR(100),CHAR(5), CHAR (100);

    --DEFINICION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE iSamErr INTEGER;
    DEFINE cCodret  CHAR (5);
	Define cProceso CHAR(100);
	DEFINE cNumCte  CHAR(20);
	DEFINE cCuenta  CHAR(20);
	DEFINE cNumProd CHAR(4);
	DEFINE cStatus  CHAR(1);
	DEFINE iContador INTEGER;
	DEFINE sCommit   SMALLINT;
	DEFINE iNumTarjetasAdi INTEGER;
	DEFINE dFechaApertura DATE;
	DEFINE cProcedApertura CHAR(2);
	DEFINE cProcedMantenerCta CHAR(2);
	DEFINE cVarError  CHAR(100);
	DEFINE dSaldoMaxMes DECIMAL(14,2);
	DEFINE dSaldoPromedio DECIMAL(14,2);
	DEFINE dFechaUltimoPagoCap DATE;
	DEFINE cFechaIni CHAR(8);
	DEFINE cFechaFin CHAR(8);
	DEFINE cFolioSolicitud CHAR(30);
	DEFINE cSucursal CHAR(5);
	DEFINE cBancoOrdenante CHAR(5);
	DEFINE cCuentaOrdenante CHAR(20);
	DEFINE cBancoReceptor CHAR(5);
	DEFINE cCuentaReceptora CHAR(20);
	DEFINE cRfcEmpresa CHAR(12);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cStatusPorta CHAR(2);
	DEFINE cClaveOrigen CHAR(1);
	DEFINE cClaveSentido CHAR(1);
	DEFINE cFechaDeposito CHAR(60);
	DEFINE cFechaSol CHAR(8);
	DEFINE cStatus_ejecucion CHAR(1);
	DEFINE dFechaIni DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin DATETIME YEAR TO FRACTION(5);
	DEFINE cVarDataErr		CHAR(100);
	DEFINE iEstatus			INTEGER;
	DEFINE cEstatus_Descripcion CHAR(120);
	DEFINE cIngreso_Mensual MONEY;
	DEFINE cFecha_Cancel CHAR(8);
	DEFINE cCta_Clabe_Ceceptora CHAR(20);
	DEFINE cCta_Clabe_Ordenante CHAR(20);
	DEFINE cNum_Tarjeta_Receptora CHAR(20);
	DEFINE cNum_Tarjeta_Ordenante CHAR(20);
	DEFINE cEstatus_Respuesta CHAR(2);
	DEFINE cEstatus_Desc_Respuesta CHAR(60);
	DEFINE cStmt CHAR (500);
	DEFINE cRutaOltp CHAR(50);
	
    --INICIALIZACION DE VARIABLES
    LET cCodret  = "00000";
	LET cProceso ="sp_actualiza_chq_cap";
	LET cNumCte = "";
	LET cCuenta = "";
	LET cNumProd = "";
	LET cStatus= "";
	LET iContador = 0;
	LET sCommit = 0;
	LET iNumTarjetasAdi = 0;
	LET cProcedApertura ="";
	LET cProcedMantenerCta ="";
	LET dFechaApertura = '';
	LET dFechaIni = '';
	LET dFechaFin = '';
	LET cVarError= "";
	LET dSaldoMaxMes = 0.00;
	LET dSaldoPromedio = 0.00;
	LET dFechaUltimoPagoCap = '';
	LET cFechaIni = '20100101';
	LET cFechaFin = '20100101';
	LET cFolioSolicitud = '';
	LET cSucursal ='';
	LET cBancoOrdenante = '';
	LET cCuentaOrdenante = '';
	LET cBancoReceptor ='';
	LET cCuentaReceptora = '';
	LET cRfcEmpresa ='';
	LET cCodOperacion ='';
	LET cStatusPorta ='';
	LET cClaveOrigen ='';
	LET cClaveSentido = '';
	LET cFechaDeposito ='';
	LET cFechaSol ='';
	LET cStatus_ejecucion ='';
	LET cVarDataErr 	= '';
	LET iEstatus        = 1;
	LET cEstatus_Descripcion = '';
	LET cIngreso_Mensual = '';
	LET cFecha_Cancel = '';
	LET cCta_Clabe_Ceceptora = '';
	LET cCta_Clabe_Ordenante = '';
	LET cNum_Tarjeta_Receptora = '';
	LET cNum_Tarjeta_Ordenante = '';
	LET cEstatus_Respuesta = '';
	LET cEstatus_Desc_Respuesta = '';
	LET cStmt = '';
	LET cRutaOltp = '/RESPALDOSNEW/depuraremesas/';

	--SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_actualiza_chq_cap.out";
	--TRACE ON;
	
    BEGIN
	
		--CONTROLAMOS ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarError
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
				LET cVarError = 'ERROR NO CONTROLADO';
				
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cCodRet , cVarError, pTipoProc);
					
				RETURN cProceso,cCodRet,cVarError;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR LOS PARAMETROS DE ENTRADA
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		TRUNCATE TABLE bdicheq:"informix".tmp_unica_paso;
		TRUNCATE TABLE bdicheq:"informix".tmp_varport_nom;
		
		IF pTipoProc IN ('CAP','VPN') THEN
			IF NVL(pFechaInicio,'')= '' OR NVL(pFechaFin,'') = '' THEN
				
				LET cCodRet =   '00001'; 
				LET cStatus_ejecucion=0;
				LET cVarError="FALTAN PARAMETROS DE ENTRADA";
				
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProc);
						
				RETURN cProceso,cCodRet, cVarError;
			END IF;
			
			IF pFechaFin > CURRENT::DATE THEN
				LET cCodRet =   '00002'; 
				LET cStatus_ejecucion=0;
				LET cVarError="FECHA FINAL ES MAYOR A LA FECHA DE HOY";
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProc);
						
				RETURN cProceso,cCodRet, cVarError;
			END IF;
			
			IF pFechaInicio > pFechaFin THEN
				LET cCodRet =   '00003'; 
				LET cStatus_ejecucion=0;
				LET cVarError="FECHA INICIO ES MAYOR A LA FECHA FIN";
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProc);
				RETURN cProceso,cCodRet, cVarError;
			END IF;		
		ELIF  NVL(pTipoProc,"") not in('CAP','VPN') THEN 
				LET cCodRet =   '00001'; 
				LET cStatus_ejecucion=0;
				LET cVarError="FALTAN PARAMETROS DE ENTRADA";

				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProc);
						
				RETURN cProceso, cCodRet, cVarError;
		END IF;	--TERMINA DE VALIDAR LOS PARAMETROS DE ENTRADA
		
	IF (UPPER(pTipoProc) = 'CAP') THEN --UNI_CAPTACION
		
		--/** OBTENEMOS LOS REGISTROS DE LA FECHA DESEADA PARA CAPTACION **/
		INSERT	INTO bdicheq:"informix".tmp_unica_paso (numcte, cuenta, producto, folio_sol)	
		SELECT   	mch.num_cte,
					mch.cuenta,
					mch.producto, '' 
		FROM     	bdicheq:"informix".sc_maechq mch
		WHERE    	mch.status_cta = '1'
		AND      	mch.ultpagocap >   pFechaInicio
		AND      	mch.ultpagocap <=  pFechaFin
		GROUP BY    mch.num_cte, mch.cuenta, mch.producto;
		
		DROP TABLE IF EXISTS tmp_captacion_cap;
		SELECT      mch.num_cte,
					mch.cuenta,
					mch.producto,
					mch.status_cta,
					mch.proced_aperturacta,
					mch.proced_mantenercta,
					mch.ultpagocap
		--INTO        cNumCte, cCuenta, cNumProd, cStatus, cProcedApertura, cProcedMantenerCta, dFechaApertura
		FROM        bdicheq:"informix".sc_maechq mch
		INNER JOIN  bdicheq:"informix".tmp_unica_paso tp ON (tp.numcte = mch.num_cte AND tp.cuenta = mch.cuenta AND tp.producto = mch.producto)
		WHERE       mch.status_cta = '1'
		AND         mch.ultpagocap >   pFechaInicio
		AND         mch.ultpagocap <=  pFechaFin
		INTO tmp_captacion_cap;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'captacion_cap.unl SELECT * FROM tmp_captacion_cap;">' || TRIM(cRutaOltp) || 'u_captacion_cap.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_captacion_cap.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdicheq ' || TRIM(cRutaOltp) || 'u_captacion_cap.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_captacion_cap.sql';
		SYSTEM cStmt;


		TRUNCATE TABLE tmp_unica_paso;
		DROP TABLE IF EXISTS tmp_captacion_cap;

		LET cVarDataErr = 'EJECUCION EXITOSA CAP';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProc);

	END IF;
		
		
	IF (UPPER(pTipoProc) = 'VPN') THEN -- UNI_VAR_PORT_MOMINA

	--LET cFechaIni = TO_CHAR(cFechaIni, "%Y%m%d");
	
		-- INSERTAMOS DATOS PRINCIPALES DE PORTABILIDAD DE NOMINA 
		INSERT INTO bdicheq:"informix".tmp_varport_nom(empresa,num_cte,folio_solicitud,sucursal,bco_ordenante,cta_ordenante,bco_receptor,cta_receptora,rfc_empresa,cod_operacion,estatus_portabilidad,clave_origen,clave_sentido,fecha_deposito,fecha_solicitud,fecha_cancel,estatus_respuesta)
		SELECT      ps.empresa,
					ps.num_cte,
					ps.folio_solicitud,
					ps.sucursal,
					ps.bco_ordenante,
					ps.cta_ordenante,
					ps.bco_receptor,
					ps.cta_receptora,
					ps.rfc_empresa,
					ps.cod_operacion,
					ps.estatus_portabilidad,
					ps.clave_origen,
					ps.clave_sentido,
					ps.comentario,
					ps.fecha_solicitud,
					ps.fecha_solca_portabilidad,
					ps.estatus_respuesta
		FROM        bdicheq:"informix".sc_portacec_solicitud ps
		WHERE		ps.empresa = '001'
		AND			ps.fecha_solicitud >= '20100101';
		
		-- AGREGAMOS LA RELACION ESTATUS DE ACUERDO A LAS CLAVES
		MERGE INTO  bdicheq:"informix".tmp_varport_nom d 
			 USING  bdicheq:"informix".sc_relacion_estatus e
				ON  d.estatus_portabilidad = e.estatus_portabilidad AND d.clave_origen = e.clave_origen AND d.clave_sentido = e.clave_sentido
		WHEN MATCHED THEN
			UPDATE SET d.estatus_descripcion = e.descripcion;

		-- AGREGAMOS LOS QUE NO TIENE ESTATUS DE RELACION
		UPDATE  bdicheq:"informix".tmp_varport_nom a
		   SET  a.estatus_descripcion = 'La relacion del estatus de portabilidad y las claves no existen en el catalogo'
		 WHERE  (a.estatus_descripcion IS NULL OR a.estatus_descripcion = "");

		-- AGREGAMOS LA DESCRIPCION DEL ESTATUS DE RESPUESTA
		MERGE INTO  bdicheq:"informix".tmp_varport_nom j
			 USING  bdicheq:"informix".sc_portacec_estatus_respuesta h
				ON  j.estatus_respuesta  = h.estatus_respuesta 
		WHEN MATCHED THEN
			UPDATE SET j.estatus_desc_respuesta = h.descripcion;

		-- AGREGAMOS LOS QUE NO TIENE ESTATUS DE RESPUESTA
		UPDATE  bdicheq:"informix".tmp_varport_nom j
		   SET  j.estatus_desc_respuesta = 'No tiene asignado el estatus de respuesta o no existe en el catalogo'
		 WHERE  (j.estatus_desc_respuesta IS NULL OR j.estatus_desc_respuesta = "");

		-- OBTENEMOS LA MAXIMA SECUENCIA DEL INGRESO DEL CLIENTE
		UPDATE  bdicheq:"informix".tmp_varport_nom a
		   SET  a.sec_ingreso = (SELECT  MAX( NVL(i.sec_ingreso, 0))
								 FROM    bdinteg:"informix".si_ingresos i
								 WHERE   i.empresa = a.empresa
								 AND     i.numcte = a.num_cte);

		-- ACTUALIZAMOS EL INGRESO MENSUAL
		MERGE INTO  bdicheq:"informix".tmp_varport_nom n
			 USING  bdinteg:"informix".si_ingresos i
				ON  n.empresa = i.empresa AND n.num_cte = i.numcte AND n.sec_ingreso = i.sec_ingreso
		WHEN MATCHED THEN
			UPDATE SET n.ingreso_mensual = i.ingreso_mensual;

		-- LOS QUE NO TIENEN INGRESO LOS SE DEJA EN 0
		UPDATE  bdicheq:"informix".tmp_varport_nom n
		   SET  n.ingreso_mensual = 0
		 WHERE  (n.ingreso_mensual IS NULL OR n.ingreso_mensual = "");

		-- ACTUALIZAMOS LA CUENTA CLABLE RECEPTORA
		UPDATE  bdicheq:"informix".tmp_varport_nom n
		   SET  n.cta_clabe_receptora = (SELECT  DISTINCT p.cuenta_ref
										 FROM    bdicheq:"informix".sc_portabilidadnomina p
										 WHERE   p.empresa = n.empresa
										 AND     p.cliente = n.num_cte
										 AND     p.cuenta_ref = n.cta_receptora);

		-- ACTUALIZAMOS LA CUENTA CLABLE RECEPTORA
		UPDATE  bdicheq:"informix".tmp_varport_nom n
		   SET  n.num_tarjeta_receptora = (SELECT  DISTINCT p.tarjeta_ref
										   FROM    bdicheq:"informix".sc_portabilidadnomina p
										   WHERE   p.empresa = n.empresa
										   AND     p.cliente = n.num_cte
										   AND     p.tarjeta_ref = n.cta_receptora);

		-- ACTUALIZAMOS LA CUENTA CLABLE ORDENANTE
		UPDATE  bdicheq:"informix".tmp_varport_nom n
		   SET  n.cta_clabe_ordenante = (SELECT  DISTINCT p.cuenta_ref
										 FROM    bdicheq:"informix".sc_portabilidadnomina p
										 WHERE   p.empresa = n.empresa
										 AND     p.cliente = n.num_cte
										 AND     p.cuenta_ref = n.cta_ordenante);

		-- ACTUALIZAMOS LA CUENTA CLABLE ORDENANTE
		UPDATE  bdicheq:"informix".tmp_varport_nom n
		   SET  n.num_tarjeta_ordenante = (SELECT  DISTINCT p.tarjeta_ref
										   FROM    bdicheq:"informix".sc_portabilidadnomina p
										   WHERE   p.empresa = n.empresa
										   AND     p.cliente = n.num_cte
										   AND     p.tarjeta_ref = n.cta_ordenante);		

										   
										   
		-- ACTUALIZAMOS EN EL STAGIN DE UNICA uni_var_port_nomina
		DROP TABLE IF EXISTS tmp_captacion_vpn;
		SELECT tvp.num_cte, tvp.folio_solicitud, tvp.sucursal, tvp.bco_ordenante, tvp.cta_ordenante, tvp.bco_receptor, tvp.cta_receptora, tvp.rfc_empresa, tvp.cod_operacion, tvp.estatus_portabilidad, tvp.clave_origen, tvp.clave_sentido, tvp.fecha_deposito, tvp.fecha_solicitud, tvp.estatus_descripcion, tvp.ingreso_mensual, tvp.fecha_cancel, tvp.cta_clabe_receptora, tvp.cta_clabe_ordenante, tvp.num_tarjeta_receptora, tvp.num_tarjeta_ordenante, tvp.estatus_respuesta, tvp.estatus_desc_respuesta
		FROM   bdicheq:"informix".tmp_varport_nom tvp
		INTO tmp_captacion_vpn;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'captacion_vpn.unl SELECT * FROM tmp_captacion_vpn;">' || TRIM(cRutaOltp) || 'u_captacion_vpn.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_captacion_vpn.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdicheq ' || TRIM(cRutaOltp) || 'u_captacion_vpn.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_captacion_vpn.sql';
		SYSTEM cStmt;
		
		LET cVarDataErr = 'EJECUCION EXITOSA VPN';

		TRUNCATE TABLE bdicheq:"informix".tmp_varport_nom;
		DROP TABLE IF EXISTS tmp_captacion_vpn;
		
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProc);

	END IF;
	
        RETURN cProceso,cCodRet, cVarDataErr;
    END;

END PROCEDURE;