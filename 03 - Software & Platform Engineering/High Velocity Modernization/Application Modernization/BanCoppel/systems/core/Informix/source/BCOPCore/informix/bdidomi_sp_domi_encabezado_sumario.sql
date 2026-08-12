CREATE PROCEDURE "informix".sp_domi_encabezado_sumario()
	RETURNING CHAR(5) AS Codigo_Respuesta,CHAR (100) AS Mensaje_Respuesta;  


	DEFINE pNom_Arch31 CHAR(20);
	DEFINE pNom_Arch32 CHAR(20);
	DEFINE sql_err      INTEGER;
	DEFINE v_cod_ret   CHAR(5);
	DEFINE vsFlagArch31 CHAR(1);
    DEFINE vsFlagArch32 CHAR(1);
	DEFINE vsFecha_Presentacion CHAR (8);
    DEFINE vsFecha_Presentacion1 CHAR (8);
    DEFINE vsFecha_Presentacion2 CHAR (8);
	DEFINE vsCodRetorno CHAR (5);
    DEFINE vsCodRetorno2 CHAR (5);
	DEFINE vsNomArchivo31 CHAR (20);
	DEFINE vsNomArchivo32 CHAR (20);
	DEFINE vsFlagTipoProceso CHAR (1);
	DEFINE vsNomProceso CHAR (20);
	DEFINE vsDescripcionProceso CHAR (60);
	DEFINE sERROR CHAR(1);
	DEFINE psNumEmpleado CHAR(8);
	DEFINE vsNomArchivo CHAR (20);
	DEFINE viTipoArchivo SMALLINT;
	DEFINE vsFlagArch11 CHAR(1);
	DEFINE vsNomArchivo11 CHAR (20);
	DEFINE sFINALIZADO CHAR(1);
	DEFINE pNom_Arch   CHAR(20);
	DEFINE cFechaFormat	CHAR(10);
	DEFINE dFecha_hoy DATE;
	DEFINE dFechaManana	DATE;
	DEFINE cFecha_trans	CHAR(8);
	DEFINE cCodRet CHAR(5);
	DEFINE d_Fech_prox DATE;
	DEFINE pUsuario CHAR(8);
	DEFINE vsMensaje_Respuesta CHAR (100);
	DEFINE vNumsecArch31 INTEGER;
	DEFINE vNumsecArch32 INTEGER;
	DEFINE cSecuencia CHAR(7);
	DEFINE vSecInvalida CHAR(7);
	DEFINE vParam1 INTEGER;
	DEFINE vParam2 INTEGER;
	DEFINE vParam3 INTEGER;
	DEFINE vParam4 INTEGER;
	DEFINE vParam5 INTEGER;
	DEFINE vParam6 INTEGER;
	DEFINE vParam7 INTEGER;
	DEFINE vParam8 INTEGER;
	DEFINE vtransaccion INTEGER;
	DEFINE iExisteProc	INTEGER;
	DEFINE vEstatus_cve	CHAR(2);
	DEFINE vCuenta	    INTEGER;
	DEFINE vNom_Archv   CHAR(20);
	DEFINE vTipo_reg    CHAR(2);
	DEFINE vCve_estatus CHAR(2);
	DEFINE cursor9      CHAR(50);
	DEFINE cursor10     CHAR(50);
	DEFINE vCod_oper    CHAR(2);
	DEFINE vImporte     CHAR(15);
	DEFINE vClave_rastreo CHAR(30);
	DEFINE vFolio_suc   CHAR(16);
	
	LET pNom_Arch31 = "";
	LET pNom_Arch32 = "";
	LET sql_err = 0;
	LET vsFlagArch31 = 'F';
	LET vsFlagArch32 = 'F';
	LET vsFecha_Presentacion = '';
    LET vsFecha_Presentacion1 = '';
	LET vsFecha_Presentacion2 = '';
	LET vsCodRetorno = '00000';
    LET vsCodRetorno2 = '';
	LET vsNomArchivo31 = '';
    LET vsNomArchivo32 = '';
	LET vsFlagTipoProceso = '';
	LET vsNomProceso = '';
	LET vsDescripcionProceso = '';
	LET sERROR = '3';
	LET psNumEmpleado = '92599192';
	LET vsNomArchivo = '';
	LET viTipoArchivo = 0;
	LET vsFlagArch11 = 'F';
	LET vsNomArchivo11 = '';
	LET sFINALIZADO = '1';
	LET pNom_Arch   = "";
	LET dFecha_hoy  = "";
	LET cFecha_trans = "";
	LET cCodRet	= "00000";
	LET pUsuario = '';
	LET v_cod_ret = '';
	LET vsMensaje_Respuesta = '';
	LET vNumsecArch31 = 1;
	LET vNumsecArch32 = 1;
	LET cSecuencia    = '';
	LET vSecInvalida   = '';
	LET vParam1 = 0;
	LET vParam2 = 0;
	LET vParam3 = 0;
	LET vParam4 = 0;
	LET vParam5 = 0;
	LET vParam6 = 0;
	LET vParam7 = 0;
	LET vParam8 = 0;
	LET vtransaccion = 0;
	LET iExisteProc  = 0;
	LET vEstatus_cve = '';
	LET vNom_Archv = '';
	LET vTipo_reg = '';
	LET vCve_estatus = '';
	LET cursor9  = '';
	LET cursor10 = '';
	LET vCod_oper = '';
	LET vFolio_suc = '';
	
	BEGIN
		
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vsCodRetorno = sql_err;
				  EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', vsCodRetorno, pUsuario, vsDescripcionProceso, TRIM(pNom_Arch) , 
				  YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			 RETURN vsCodRetorno,vsDescripcionProceso;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535, -255,-243,-211, -242, -244, -311)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO wait 3;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_domi_encabezado_sumario.out";
        --TRACE ON;	
		
		SELECT FIRST 1 nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,user_insert INTO pNom_Arch,vsFecha_Presentacion,pNom_Arch31,pNom_Arch32,pUsuario FROM bdidomi:dom_cce_control_hilos 
		WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_1');
		
		--	Consulta  fecha de la tabla de control de hilos, esto por si se ejecuta en cualquier momento, tome la fecha en que se ejecuta el proceso y no cambie la fecha en el cierre de cheques.
		SELECT FIRST 1 fecha_insert INTO dFecha_hoy FROM bdidomi:dom_cce_control_hilos;
		--      Saca la fecha de presentacion

		LET dFechaManana = dFecha_hoy + 1;


		LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');

		CALL bdidomi: "informix".sp_valida_fecha(cFechaFormat) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			EXECUTE FUNCTION bdinteg: "informix".splvalfecha('001', dFechaManana, 0 ) INTO cCodRet,dFechaManana;

			SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
			IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
				LET dFechaManana = dFechaManana;
			ELSE
				LET dFechaManana = d_Fech_prox;
			END IF;
			LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
			IF cCodRet <>0 THEN
				LET vsMensaje_Respuesta = 'ERROR';
				RETURN cCodRet,vsMensaje_Respuesta;
			END IF;
			LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
			--LET cFecha_aplica = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		END IF;

		SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
		IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
			LET dFechaManana = dFechaManana;
		ELSE
			LET dFechaManana = d_Fech_prox;

		END IF;
		LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
		LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		
		--***********************************************************************************************************************************************
		--***************************************************** INSERTA REGISTROS DE LAS TABLAS DE CADA HILO A DETALLE PASO ********************************************
		
		LET vsNomProceso = 'INSERT_DET_HILOS';
		LET vsDescripcionProceso = 'INSERT_HILOS_TABLE DETALLE_A_PASO';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN  
		
			DROP TABLE IF EXISTS dom_cce_detalle_paso_arch32;
			DROP TABLE IF EXISTS dom_cce_detalle_paso_arch31;
			
			SELECT * FROM bdidomi:dom_cce_detalle_paso_1 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_2 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_3 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_4 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			INTO TEMP dom_cce_detalle_paso_arch31 WITH NO LOG;
			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso SELECT * FROM dom_cce_detalle_paso_arch31 WHERE nombre_arch = pNom_Arch31 AND cod_operacion = '31' AND tipo_registro='02' AND cve_estatus = '02';
			
			SELECT * FROM bdidomi:dom_cce_detalle_paso_1 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_2 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_3 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_4 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			INTO TEMP dom_cce_detalle_paso_arch32 WITH NO LOG;
			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso SELECT * FROM dom_cce_detalle_paso_arch32 WHERE nombre_arch = pNom_Arch32 AND cod_operacion = '32' AND tipo_registro='02' AND cve_estatus = '01';
			
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;		
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA INSERTA REGISTROS DE LAS TABLAS DE CADA HILO A DETALLE PASO ********************************************
		
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 32 ********************************************
		
		LET vsNomProceso = 'GEN_SEC_ARCH32';
		LET vsDescripcionProceso = 'GENERA_SEC_ENCAB_SUM32';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN 
		
			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32) THEN
				LET vCuenta = 0;
				FOREACH cursor9 WITH HOLD FOR 
					SELECT nombre_arch,tipo_registro,num_secuencia,cve_estatus,cod_operacion,importe,clave_rastreo
					INTO vNom_Archv,vTipo_reg,vSecInvalida,vCve_estatus,vCod_oper,vImporte,vClave_rastreo FROM bdidomi:"informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cve_estatus='01' AND cod_operacion='32'
					
					LET vNumsecArch32 = vNumsecArch32 + 1;
					
					LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumsecArch32)),7,'0');
					
					UPDATE bdidomi:"informix".dom_cce_detalle_paso SET num_secuencia = cSecuencia WHERE CURRENT OF cursor9;
					
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
			
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch32) THEN

					INSERT INTO bdidomi: "informix".dom_cce_encabezado_paso
					(nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
					num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT pNom_Arch32,cFechaFormat,'01','0000001' ,'32',cve_banco,'E',servicio,
							LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch32,16,2),5,'0'),cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,pUsuario,CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch;
				END IF;	
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch32) THEN
					--SUMARIO
					INSERT INTO bdidomi: "informix".dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,
					cod_operacion,num_bloque,num_operaciones,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT
					pNom_Arch32,
					cFechaFormat,
					'09',
					(SELECT LPAD(NVL(MAX (num_secuencia)::INTEGER + 1,0),7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Secuencia maxima
					'32',
					LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch32,16,2),5,'0'),
					(SELECT LPAD(COUNT (num_secuencia)::INTEGER,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Numero de registros
					(SELECT LPAD(SUM(importe::BIGINT),18,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Importe de operaciones.
					uso_futuro_ccen,
					uso_futuro_banco,
					pUsuario,
					CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

			END IF;
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1','00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 32 ********************************************
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 31 ********************************************
		
		LET vsNomProceso = 'GEN_SEC_ARCH31';
		LET vsDescripcionProceso = 'GENERA_SEC_ENCAB_SUM31';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN
			LET vSecInvalida = '';
			LET cSecuencia = '';
			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31) THEN
				LET vCuenta = 0;
				BEGIN WORK;
				FOREACH cursor10 WITH HOLD FOR 
					SELECT nombre_arch,tipo_registro,num_secuencia,cve_estatus,cod_operacion,importe,clave_rastreo 
					INTO vNom_Archv,vTipo_reg,vSecInvalida,vCve_estatus,vCod_oper,vImporte,vClave_rastreo FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cve_estatus='02' AND cod_operacion='31'
					
					LET vNumsecArch31 = vNumsecArch31 + 1;
					
					LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumsecArch31)),7,'0');
					
					UPDATE bdidomi: "informix".dom_cce_detalle_paso SET num_secuencia = cSecuencia WHERE CURRENT OF cursor10;
					
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
			
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch31) THEN
				
					--ENCABEZADO
					INSERT INTO bdidomi: "informix".dom_cce_encabezado_paso
					(nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
					num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					SELECT pNom_Arch31,cFechaFormat,'01','0000001','31',cve_banco,'E',servicio,
							LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch31,16,2),5,'0'),cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,pUsuario,CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch31) THEN
					--SUMARIO
					INSERT INTO bdidomi: "informix".dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,
					cod_operacion,num_bloque,num_operaciones,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT
					pNom_Arch31,
					cFechaFormat,
					'09',
					(SELECT LPAD(NVL(MAX (num_secuencia),0)::INTEGER + 1,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Secuencia maxima
					'31',
					LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch31,16,2),5,'0'),
					(SELECT LPAD(COUNT (num_secuencia)::INTEGER,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Numero de registros
					(SELECT LPAD(SUM(importe::BIGINT),18,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Importe de operaciones.
					uso_futuro_ccen,
					uso_futuro_banco,
					pUsuario,
					CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

			END IF;	
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1','00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 31 ********************************************
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERA ARCHIVOS CODIGO 31 Y 32  ********************************************
		
		LET vsNomProceso = 'GENERA_ARCH_COD_31_32';
		LET vsDescripcionProceso = 'GENERA ARCHIVOS COD 31 Y 32';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN 
		
			IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
						LET vsFlagArch31 = 'V';
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(pNom_Arch31);
						EXECUTE PROCEDURE BdiDomi:sp_domi_generaarchivo(TRIM(pNom_Arch31), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
					END IF;
				END IF;
			END IF;
			IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
						LET vsFlagArch32 = 'V';
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(pNom_Arch32) ;
						--Se genera sp sp_domi_generaarchivo32 por problema de ejecucion con el usuario sysdomi el original es sp_domi_generaarchivo
						EXECUTE PROCEDURE BdiDomi:sp_domi_generaarchivo(TRIM (pNom_Arch32), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
					END IF;
				END IF;
			END IF;
			
			IF vsCodRetorno = '00000' THEN
				EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', vsCodRetorno, pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			    YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
				LET vsCodRetorno = '00000';
			ELSE
				RETURN vsCodRetorno, vsDescripcionProceso;
			END IF;
		ELSE
			LET iExisteProc = 0;
		END IF;
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERA ARCHIVOS CODIGO 31 Y 32  ********************************************
		

	    --***********************************************************************************************************************************************
		--***************************************************** ACTUALIZA ESTATUS ARCH COD 30 ********************************************
		LET vsNomProceso = 'ACT_EST_ARCH_30';
		LET vsDescripcionProceso = 'ACTUALIZA_ESTATUS_ARCH_COD_30';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN
			DROP TABLE IF EXISTS act_det_paso_estatus;
			
			SELECT FIRST 1 rango1,rango2 INTO vParam1,vParam2 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_1');
			SELECT FIRST 1 rango1,rango2 INTO vParam3,vParam4 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_2');
			SELECT FIRST 1 rango1,rango2 INTO vParam5,vParam6 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_3');
			SELECT FIRST 1 rango1,rango2 INTO vParam7,vParam8 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_4');
			
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_1 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam1 AND num_secuencia::int <= vParam2 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_2 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam3 AND num_secuencia::int <= vParam4 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_3 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam5 AND num_secuencia::int <= vParam6 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_4 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam7 AND num_secuencia::int <= vParam8 AND cve_estatus IN ('01','02')
			INTO TEMP act_det_paso_estatus WITH NO LOG;
			

			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch) THEN
				LET vCuenta = 0;
				BEGIN WORK;
				FOREACH WITH HOLD 
					SELECT num_secuencia,cve_estatus,folio_suc INTO cSecuencia,vEstatus_cve,vFolio_suc FROM bdidomi:"informix".act_det_paso_estatus WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND cve_estatus <> '00'
						
						UPDATE bdidomi:dom_cce_detalle_paso SET cve_estatus = vEstatus_cve,folio_suc = vFolio_suc WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia = cSecuencia;
						
						--Hago commit y vuelvo a iniciar
						LET vCuenta = vCuenta + 1;
						IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
			END IF;
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;	
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA ACTUALIZA ESTATUS ARCH COD 30 ********************************************
		
		IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE GENERRO CORRECTAMENTE

			EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch), vsFecha_Presentacion, '01') INTO vsCodRetorno;

			LET vsDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
			--ARCHIVO ORIGINAL
			EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch), vsFecha_Presentacion, 'T') INTO vsCodRetorno;

			IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

				IF (vsFlagArch31 = 'V') THEN
					EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch31), vsFecha_Presentacion2, '01') INTO vsCodRetorno;
				END IF;

				IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO

					IF (vsFlagArch31 = 'V') THEN
						EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch31), vsFecha_Presentacion2, 'T') INTO vsCodRetorno;
					END IF;

					IF (vsCodRetorno = '00000') THEN --VALIDA KE LOS DATOS DEL ARCHIVO 31 SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

						IF (vsFlagArch32 = 'V') THEN
							EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch32), vsFecha_Presentacion2, '01') INTO vsCodRetorno;

							IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
								EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch32), vsFecha_Presentacion2, 'T') INTO vsCodRetorno;
							ELSE --ERROR

							END IF;
						END IF;

					ELSE -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 31 AL HITORICO
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						sERROR, vsCodRetorno, pUsuario, 'sp_Domi_MoverRegistrosHist', TRIM(pNom_Arch31) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno = '00127';
					END IF;
				END IF;
			END IF;

			IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO DE RESPUESTA SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

				LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '03' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;

				IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
					--GUARDA BITACORA EXITO
					LET vsDescripcionProceso = 'Domiciliacion Finalizada Exitosamente.';
					LET vsCodRetorno = '00000';
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sFINALIZADO, vsCodRetorno, pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , vsFecha_Presentacion, '02'/*EXITO*/) INTO vsCodRetorno2;
					
					--ACTUALIZA LOS ESTATUS DEL CCE_ACHIVO PARA KE LOS AMRQUE COMO TERMINADO
				
					IF (vsFlagArch31 = 'V') THEN
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado WHERE Nombre_Arch = TRIM(pNom_Arch31) ;
						EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch31), vsFecha_Presentacion2, '02'/*EXITO*/) INTO vsCodRetorno2;
						LET vsCodRetorno = '00000';
					END IF;

					IF (vsFlagArch32 = 'V') THEN
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado WHERE Nombre_Arch = TRIM(pNom_Arch32) ;
						EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch32), vsFecha_Presentacion2, '02'/*EXITO*/) INTO vsCodRetorno;
						LET vsCodRetorno = '00000';
					END IF;
				ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
					--GUARDAR BITACORA
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sERROR, vsCodRetorno, pUsuario, 'Sp_Domi_MoverArchivos', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					LET vsCodRetorno = '00130';
				END IF;
				
			ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HISTORICO
				--GUARDAR BITACORA
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;

				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
				LET vsCodRetorno = '00126';
			END IF;

		ELSE --ERROR AL GENERAR EL ARCHIVO DE RESPUESTA
			--GUARDAR BITACORA
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;

			EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
			sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_GeneraArchivo', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
			LET vsCodRetorno = '00125';
		END IF;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
		
		IF (vsCodRetorno = '00000') THEN
			LET vsMensaje_Respuesta = 'GENERAL PROCESO EXITOSO';
		ELSE
			LET vsMensaje_Respuesta = 'ERROR EN PROCESO';
		END IF;
		
	RETURN vsCodRetorno,vsMensaje_Respuesta;
END;
END PROCEDURE;