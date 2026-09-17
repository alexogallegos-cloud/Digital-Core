CREATE PROCEDURE "informix".sp_tef_generararchivo60 (psNombre_Archivo CHAR(20),psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  GENERA LAS INSTRUCCIONES DE CARGOS PARA FORMAR EL ARCHIVOS 60 Y PREPARA LAS TABLAS PARA QUE LOS VALIDE CCE.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 16/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vdFecha_hoy				DATE;
DEFINE vdFecha_Manana   		DATE;
DEFINE vdFechaEnvioProveedor	DATE;
DEFINE iSQLerr					INTEGER;
DEFINE iExiste					INTEGER;

DEFINE viImporteAux INTEGER;
DEFINE viIva_Tef_Aux INTEGER;

DEFINE vdtFecha_Trans DATETIME YEAR TO FRACTION (5);
DEFINE vsFolio_Suc CHAR(16);
DEFINE vsNum_Serial CHAR(12);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vdFecha_Programacion DATE;
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsNombre_Cte_Ord CHAR(30);
DEFINE vsRfc_Cte_Ord CHAR(15);
DEFINE vsImporte_Tef CHAR(10);
DEFINE vsComision_Tef CHAR(5);
DEFINE vsIva_Tef CHAR(5);
DEFINE vsImporte_Tot_Tef CHAR(10);
DEFINE vsTipo_Cta_Ben CHAR(2);
DEFINE vsNombre_Ben CHAR(30);
DEFINE vsNum_Cuenta_Tarj_Ben CHAR(20);
DEFINE vsCve_Banco_Rec CHAR(3);
DEFINE vsRfc_Ben CHAR(15);
DEFINE vsConcepto_Pago CHAR(50);
DEFINE vsRef_Num CHAR(7);
DEFINE vsReferencia CHAR(40);
DEFINE vsCve_Canal CHAR(2);
DEFINE vsCve_Status CHAR(2);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsFecha_Programacion CHAR(8);

DEFINE vsCodRet CHAR(5) ;
DEFINE vsCodRet2 CHAR(5) ;
DEFINE vsCodRet3 CHAR(5) ;
DEFINE vsFecha_Presentacion_Gen CHAR (8);
DEFINE vsFechaManana CHAR (8);
DEFINE vsBancoPresentador CHAR (3);
DEFINE vsCuenta_Clabe_Ord CHAR (20);
DEFINE viContadorSecuencia INTEGER;
DEFINE viImporteTotal INTEGER;

--DEFINE vsBancoPresentador2 CHAR();
DEFINE vsFecha_Programacion2 CHAR(8);
DEFINE vsFecha_Presentacion2 CHAR(8);
DEFINE vsImporte_Tef2 CHAR(10);
DEFINE Num_Cta_Rec2 CHAR(20);
DEFINE vsRfc_Ord2 CHAR(15);
DEFINE vsNum_Cta_Ord2 CHAR(20);
DEFINE vsReferencia2 CHAR(40);
DEFINE vsClave_Rastreo2 CHAR(30);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;



--INICIALIZACION DE VARIABLES.

LET viImporteAux = 0;
LET viIva_Tef_Aux = 0;

LET vdtFecha_Trans = CURRENT;
LET vsFolio_Suc = '';
LET vsNum_Serial = '';
LET vsNum_Cta_Ord = '';
LET vsTipo_Cta_Ord = '';
LET vdFecha_Programacion = '';
LET vsTipo_Operacion = '';
LET vsClave_Rastreo = '';
LET vsNombre_Cte_Ord = '';
LET vsRfc_Cte_Ord = '';
LET vsImporte_Tef = '';
LET vsComision_Tef = '';
LET vsIva_Tef = '';
LET vsImporte_Tot_Tef = '';
LET vsTipo_Cta_Ben = '';
LET vsNombre_Ben = '';
LET vsNum_Cuenta_Tarj_Ben = '';
LET vsCve_Banco_Rec = '';
LET vsRfc_Ben = '';
LET vsConcepto_Pago = '';
LET vsRef_Num = '';
LET vsReferencia = '';
LET vsCve_Canal = '';
LET vsCve_Status = '';
LET vsMotivo_Dev = '';
LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsFecha_Programacion = '';


LET vsCodRet = '00000';
LET vsCodRet2 = '00000';
LET vsCodRet3 = '00000';
LET vsFecha_Presentacion_Gen = '';
LET vsFechaManana = '';
LET vsBancoPresentador = '';
LET vsCuenta_Clabe_Ord = '';
LET viContadorSecuencia = 0;
LET viImporteTotal = 0;


LET vsFecha_Programacion2 = '';
LET vsFecha_Presentacion2 = '';
LET vsImporte_Tef2 = '';
LET Num_Cta_Rec2 = '';
LET vsRfc_Ord2 = '';
LET vsNum_Cta_Ord2 = '';
LET vsReferencia2 = '';
LET vsClave_Rastreo2 = '';


--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--SET DEBUG FILE TO "/tmp/TEF/respuesta/sp_tef_generararchivo60.out";
--TRACE ON;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--REVERSAR LOS ESTATUS DE LA TABLA DE TEF_OPERACIONES
		FOREACH WITH HOLD SELECT Folio_Suc INTO vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
		WHERE Nombre_Arch = psNombre_Archivo
		AND Fecha_Presentacion = vsFecha_Presentacion_Gen

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			--ACTUALIZA EL REGISTRO ORIGINAL DE TEF_OPERACIONES Y LO MARCA COMO ENVIADO
			--UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = 'PE'
			UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = 'PE'
			WHERE Fecha_Programacion = vdFecha_Manana
			AND Cve_Status = '00'
			AND Folio_Suc = vsFolio_Suc;

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;


		--BORRA LA TABLA DE PASO PARA EL ARCHIVO 60
		EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(psNombre_Archivo, vsFecha_Presentacion_Gen, 'B', '') INTO vsCodRet;

		LET vsCodRet = iSQLerr;
		RETURN vsCodRet;
	END IF;
END EXCEPTION;


	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--EXTRAE LA FECHA HOY EN EL SISTEMA
	SELECT FIRST 1 Fecha_hoy INTO vdFecha_hoy FROM BdiCheq:"informix".sc_fechas;

	--AUMENTA UN DIA LA FECHA ACTUAL (PRESENTACION) PARA SER LA FECHA CARGO/PROGRAMACION
	LET vdFecha_Manana = vdFecha_hoy + 1;

	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET vsFecha_Presentacion_Gen = YEAR(vdFecha_hoy)|| LPAD(MONTH (vdFecha_hoy),2,'0') || LPAD(DAY (vdFecha_hoy),2,'0');


	--VALIDA/PROPORCIONA LA FECHA T+1
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', vdFecha_Manana, 0 ) INTO vsCodRet2,vdFecha_Manana;
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFecha_Presentacion_Gen) INTO vsCodRet3;

	--ASIGNA UN FORMATO DE FECHA
	LET vsFechaManana = YEAR(vdFecha_Manana )|| LPAD(MONTH (vdFecha_Manana ),2,'0') || LPAD(DAY (vdFecha_Manana ),2,'0');

	--VALIDA LA FECHA MANANA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFechaManana) INTO vsCodRet;

	LET psUsuario = DECODE(TRIM(psUsuario),'', 'informix', TRIM(psUsuario));

	IF (LENGTH(TRIM(psUsuario)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
		LET vsCodRet = '01800';
	ELIF (LENGTH(TRIM(psNombre_Archivo)) < 16 ) THEN --NOMBRE DE ARCHIVO NO POSEE LA LONGITUD REQUERIDA   E01bbbA2.A60ddcc
		LET vsCodRet = '01801';
	ELIF (NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75')) THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
		LET vsCodRet = '01802';
	ELIF (NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76')) THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
		LET vsCodRet = '01803';
	ELIF (vsCodRet <> '00000') THEN -- VALIDA KE LA FECHA MANANA SEA VALIDA
		LET vsCodRet = '01804';
	ELIF (vsCodRet2 <> '000') THEN -- VALIDA KE LA FECHA MANANA SEA UN DIA HABIL
		LET vsCodRet = '01805';
	ELIF (vsCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET vsCodRet = '01806';
	ELIF (NOT EXISTS (SELECT Fecha_Programacion FROM BdiTef:"informix".Tef_Operaciones WHERE Fecha_Programacion = vdFecha_Manana AND Cve_Status = 'PE')) THEN --VALIDA QUE EXISTAN INSTRUCCIONES DE ABONO A CUENTAS DE OTROS BANCOS PENDIENTES PARA EL DIA T+1
		LET vsCodRet = '01807';
	ELSE --OK

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--OBTIENE LA CLAVE DEL BANCO PRESENTADOR
		SELECT FIRST 1 Valor INTO vsBancoPresentador FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75';

		--INICIALIZA EL CONTADOR DE LA SECUENCIA EN 1 PARA EL ENCABEZADO
		LET viContadorSecuencia = 1;

		LET viImporteTotal = 0;

		--ENCABEZADO
		INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tpo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Cve_Banco,
			Sentido,
			Servicio,
			Num_Bloque,
			Cod_Divisa,
			Cve_Rechazo_bl,
			Modalidad,
			Uso_Futuro_Ccen,
			Uso_Futuro_Banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			NVL(psNombre_Archivo,''),
			NVL(vsFecha_Presentacion_Gen,''),
			'01', --TIPO REGISTRO
			LPAD(viContadorSecuencia,7,'0'), --'0000001', --SECUENCIA
			'60', --ARCHIVO
			NVL(vsBancoPresentador,''), --BANCOPEL 137
			'E', --SENTIDO
			'2', --SERVICIO
			NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombre_Archivo,(LENGTH(TRIM(psNombre_Archivo)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			'01', --DIVISA
			'00',--CVE_RECHAZO_BL
			'2',--MODALIDAD
			LPAD('',41,' '),--USO_FUTURO_CCEN
			LPAD('',370,' '),--USO_FUTURO_BANCO
			psUsuario,
			CURRENT::DATE
		);

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LAS INSTRUCCIONES DE ABONO A CUENTAS DE OTROS BANCOS PENDIENTES.
		FOREACH WITH HOLD
		SELECT Fecha_Trans, Folio_Suc, Num_Serial, Num_Cta_Ord, Tipo_Cta_Ord,
		(YEAR(Fecha_Programacion )|| LPAD(MONTH (Fecha_Programacion ),2,'0') || LPAD(DAY (Fecha_Programacion ),2,'0')) AS Fecha_Programacion,
		Tipo_Operacion, Clave_Rastreo,
		Nombre_Cte_Ord, Rfc_Cte_Ord, NVL(Importe_Tef, '0'), Comision_Tef, Iva_Tef, Importe_Tot_Tef, Tipo_Cta_Ben, Nombre_Ben,
		Num_CUenta_Tarj_Ben, Cve_Banco_Rec, Rfc_Ben, Concepto_Pago, Ref_Num, Referencia, Cve_Canal, Cve_Status,
		Motivo_Dev, Nombre_Arch, NVL(Fecha_Presentacion, vsFecha_Presentacion_Gen)
		INTO vdtFecha_Trans, vsFolio_Suc, vsNum_Serial, vsNum_Cta_Ord, vsTipo_Cta_Ord, vsFecha_Programacion, vsTipo_Operacion, vsClave_Rastreo,
		vsNombre_Cte_Ord, vsRfc_Cte_Ord, vsImporte_Tef, vsComision_Tef, vsIva_Tef, vsImporte_Tot_Tef, vsTipo_Cta_Ben, vsNombre_Ben,
		vsNum_Cuenta_Tarj_Ben, vsCve_Banco_Rec, vsRfc_Ben, vsConcepto_Pago, vsRef_Num, vsReferencia, vsCve_Canal, vsCve_Status,
		vsMotivo_Dev, vsNombre_Arch, vsFecha_Presentacion
		FROM BdiTef:"informix".Tef_Operaciones
		WHERE Fecha_Programacion = vdFecha_Manana
		AND Cve_Status = 'PE'
		ORDER BY vsNum_CUenta_Tarj_Ben, Importe_Tef ASC

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;


			IF (NOT (vsFecha_Programacion2 = vsFecha_Programacion
				AND vsFecha_Presentacion2 = vsFecha_Presentacion
				AND vsImporte_Tef2 = vsImporte_Tef
				AND Num_Cta_Rec2 = vsNum_Cuenta_Tarj_Ben
				AND vsRfc_Ord2 = vsRfc_Cte_Ord
				AND vsNum_Cta_Ord2 = vsNum_Cta_Ord
				AND vsReferencia2 = vsReferencia
				AND vsClave_Rastreo2 = vsClave_Rastreo
			)) THEN --VALIDA SI ES DISTINTO DEL REGISTRO ANTERIOR -- DISTINTO CONTINUA   IGUAL LO OMITE

				--ACTUALIZA LOS VALORES PARA LA COMPARACION DEL SIGUIENTE REGISTRO
				LET vsFecha_Programacion2 = vsFecha_Programacion;
				LET vsFecha_Presentacion2 = vsFecha_Presentacion;
				LET vsImporte_Tef2 = vsImporte_Tef;
				LET Num_Cta_Rec2 = vsNum_Cuenta_Tarj_Ben;
				LET vsRfc_Ord2 = vsRfc_Cte_Ord;
				LET vsNum_Cta_Ord2 = vsNum_Cta_Ord;
				LET vsReferencia2 = vsReferencia;
				LET vsClave_Rastreo2 = vsClave_Rastreo;


				--AUMENTA EL CONTADOR DE LA SECUENCIA
				LET viContadorSecuencia = viContadorSecuencia + 1;


				--ACUMULA LOS IMPORTES DE TODAS LAS TRANSACCIONES
				LET viImporteAux = NVL(vsImporte_Tef, '0') * 100;
				LET viIva_Tef_Aux = NVL(vSIva_Tef, '0') * 100;
				LET viImporteTotal = viImporteTotal + viImporteAux;



				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LA CUENTA CLABE
				SELECT NVL(Cuenta_Clabe, '000') INTO vsCuenta_Clabe_Ord
				FROM BdiCheq:"informix".Sc_Maechq
				WHERE Empresa = '001' AND Cuenta = TRIM(vsNum_Cta_Ord); --SUBSTR(vsNum_Cta_Ord,9,11) ;

				--GUARDA EL REGISTRO DE LA INTRUCCION DE CARGO EN LA TABLA DE PASO
				INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
				(
					Nombre_Arch,
					Fecha_Presentacion,
					Tipo_Registro,
					Num_Secuencia,
					Cod_Operacion,
					Cod_Divisa,
					Fecha_Trans,
					Banco_Presentador,
					Banco_Receptor,
					Importe,
					Uso_Futuro_Ccen,
					Tipo_Operacion,
					Fecha_Aplica,
					Tipo_Cta_Ord,
					Num_Cta_Ord,
					Nombre_Ord,
					Rfc_Ord,
					Tipo_Cta_Rec,
					Num_Cta_Rec,
					Nombre_Rec,
					Rfc_Rec,
					Ref_Servicio,
					Nombre_Titular_Serv,
					Importe_Iva,
					Ref_Numerica,
					Ref_Leyenda,
					Clave_Rastreo,
					Motivo_Dev,
					Fecha_Pres_Ini,
					Solicitud_Confirmacion,
					Uso_Futuro_Banco,
					Ref_Confirmacion,
					Uso_Futuro_Cce,
					Tasa_Tiie_Prom,
					Dias_Retraso,
					Imp_Tot_Int,
					Cve_Status,
					Folio_Suc,
					User_Insert,
					Fecha_Insert
				)
				VALUES
				(
					NVL(psNombre_Archivo,''),
					NVL(vsFecha_Presentacion_Gen,''),
					'02', --TIPO REGISTRO
					NVL(LPAD(viContadorSecuencia,7,'0'),''),--NUM_SECUENCIA
					'60', --TIPO ARCHIVO
					'01', --DIVISA
					NVL(vsFechaManana,''), --FECHA_TRANS
					NVL(vsBancoPresentador,''), --BANCO_PRESENTADOR
					NVL(vsCve_Banco_Rec,''), --BANCO_RECEPTOR
					NVL(LPAD ((viImporteAux), 15, '0'),''), -- IMPORTE
					LPAD('',16,' '), -- USO_FUTURO_CCE
					NVL(vsTipo_Operacion,''), --'60', --TIPO OPERACION
					NVL(vsFecha_Programacion,''), --vsFecha_Presentacion_Gen, --FECHA APLICACION
					NVL(vsTipo_Cta_Ord,''),			--'40',  --TIPO CUENTA ORDENANTE ----??????
					NVL(LPAD(TRIM(vsCuenta_Clabe_Ord),20,'0'),''), --NUM_CTA_ORD
					NVL(vsNombre_Cte_Ord,''), --NOMBRE CLIENTE ORD
					NVL(vsRfc_Cte_Ord,''), --RFC ORDENANTE
					NVL(vsTipo_Cta_Ben,''), --TIPO_CTA_REC
					NVL(LPAD(TRIM(vsNum_Cuenta_Tarj_Ben),20,'0'),''), -- NUM_CTA_REC
					NVL(vsNombre_Ben,''), --NOMBRE_REC
					NVL(vsRfc_Ben,''), -- RFC_REC
					LPAD('',40,' '), --REF_SERVICIO
					LPAD('',40,' '), --NOMBRE_TITULAR
					NVL(LPAD(viIva_Tef_Aux, 15, '0'),''), --IMPORTE IVA
					NVL(vsRef_Num,''), --REF_NUMERICA
					NVL(vsConcepto_Pago,''), --REF_LEYENDA
					NVL(vsClave_Rastreo,''),--CLAVE_RASTREO
					NVL(vsMotivo_Dev,''), --MOTIVO_DEVOLUCION
					NVL(vsFecha_Presentacion,''), --FECHA_PRESENTACION
					'1', --SOLICITUD CONFIRMACION (1)
					LPAD('',11,' '), --USO FUTURO  BANCO
					LPAD('',30,' '), --CONFIRMACION
					LPAD('',1,' '), --USO_FUTURO_CCE
					LPAD('',7,' '), --TASA TIIE PROM
					LPAD('',3,' '), --DIAS_RETRASO
					LPAD('',15,' '), --IMP_TOT_INT
					'00', --CVE_STATUS
					NVL(vsFolio_Suc,''), -- FOLIO_SUC
					NVL(psUsuario,''), --USUARIO_INSERT
					CURRENT::DATE --FECHA_INSERT
				);

				--ACTUALIZA EL REGISTRO ORIGINAL DE TEF_OPERACIONES Y LO MARCA COMO ENVIADO
				UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = '00', Fecha_Presentacion = vsFecha_Presentacion, nombre_arch = psNombre_Archivo
				--WHERE Fecha_Programacion = vdFecha_Manana
				where Cve_Status = 'PE'
				AND Fecha_Trans = vdtFecha_Trans
				AND Folio_Suc = vsFolio_Suc
				AND Num_Serial = vsNum_Serial
				AND Num_Cta_Ord = vsNum_Cta_Ord;

			END IF;

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		--INCREMENTA EL CONTADOR DE LA SECUENCIA PARA EL SUMARIO
		LET viContadorSecuencia = viContadorSecuencia + 1;

		--SUMARIO
		INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tipo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Num_Bloque,
			Num_Operaciones,
			Imp_Operaciones,
			Uso_Futuro_ccen,
			Uso_Futuro_banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			NVL(psNombre_Archivo,''), --NOMBRE_ARCH
			NVL(vsFecha_Presentacion_Gen,''), --FECHA_PRESENTACION
			'09', --TIPO_REGISTRO
			NVL(LPAD(viContadorSecuencia,7,'0'),''),--NUM_SECUENCIA
			'60', --COD_OPERACION
			NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombre_Archivo,(LENGTH(TRIM(psNombre_Archivo)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			NVL(LPAD((viContadorSecuencia-2),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
			NVL(LPAD(viImporteTotal,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
			LPAD('',40,' '),--USO_FUTURO_CCEN
			LPAD('',364,' '),--USO_FUTURO_BANCO
			psUsuario, --USUARIO_INSERT
			CURRENT::DATE --FECHA_INSERT
		);

		LET vsCodRet = '00000'; --OK

	END IF;

	RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: GENERA LAS INSTRUCCIONES DE CARGOS PARA FORMAR EL ARCHIVOS 60 Y PREPARA LAS TABLAS PARA QUE LOS VALIDE CCE.',
'Fecha: 2011/03/16',
'Version: 20110316.1220',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_validaimagencheque(pCveBanco CHAR(3), pCuenta CHAR(20),pNumCheque CHAR(7)) 
RETURNING  CHAR(5) ,CHAR(50), CHAR(3);

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE cMensaje         CHAR(50);
DEFINE cImagen	        BLOB;
DEFINE iTamImg          INTEGER;
DEFINE cImgFormato 			CHAR(3);


LET cCodRet 			= '00000';
LET cMensaje            = 'Ejecucion Exitosa';
LET iTamImg			    = 0;
LET cImgFormato 		= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,cMensaje,cImgFormato;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/respaldosbd/VLV/sp_ValidaImagenCheque.out";
	--TRACE ON;	 
	
	IF pCuenta = '' OR pNumCheque = '' OR pCveBanco = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'Faltan Parametros para su ejecucion';
		LET cImgFormato 		= '';
		RETURN cCodRet,cMensaje,cImgFormato;
	END IF;
	
	SELECT FIRST 1 Imagen, imagen_tam, imagen_formato
	INTO cImagen, iTamImg, cImgFormato
	FROM  bditef:cce_cheques_img	
	WHERE numcuenta = pCuenta	
	AND cvebanco= pCveBanco
	AND numcheque = pNumCheque
	AND empresa='001';
	
	IF cImagen IS NULL THEN
		LET cCodRet = '00002';
		LET cMensaje = 'No existe la imagen del cheque';
		LET cImgFormato 		= '';
	   RETURN cCodRet,cMensaje,cImgFormato;
	END IF;
	
	RETURN cCodRet,cMensaje,cImgFormato;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Verifica si existe la imagen del cheque en la tabla cce_cheques_img', 
'AUTOR: Valentin Lopez',
'FECHA: 15 de Febrero del 2011',
'VERSION: 20110215.1745',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_validaimagencheque_dev(pCveBanco CHAR(3), pCuenta CHAR(20), pNumCheque CHAR(7), pLadoFt CHAR(1), dFechaPresenta DATE) 
	RETURNING
		CHAR(5)	  AS COD_RET,
		CHAR(50)  AS MENSAJE_EJECUCION,
		CHAR(3)   AS FORMATO_IMG;

	--DECLARACION DE VARIABLES.
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cMensaje         CHAR(50);
	DEFINE bImagen	        BLOB;
	DEFINE cImgFormato 		CHAR(3);
	DEFINE cCveBanco 		CHAR(3);
	DEFINE cNumCheque 		CHAR(7);
	
	--INICIALIZACION DE VARIABLES.
	LET cCodRet 			= '00000';
	LET iSqlErr          	= 0;
	LET cMensaje            = 'EJECUCION EXITOSA';
	LET bImagen  			= NULL;
	LET cImgFormato 		= '';
	LET cCveBanco			= '';
	LET cNumCheque			= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'ERROR NO CONTROLADO';
				RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cImgFormato);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		-- SET DEBUG FILE TO "/tmp/sp_validaimagencheque_dev.out";
		-- TRACE ON;	 
		
		IF NVL(pCuenta, '') = '' OR NVL(pNumCheque, '') = '' OR NVL(pCveBanco, '') = '' OR NVL(pLadoFt, '') = '' OR
		   NVL(dFechaPresenta, '') = '' THEN
			LET cCodRet = '00001';
			LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';			
			RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);
		END IF;
		
		--SE OBTIENE EL FORMATO DE LA IMAGEN.
		SELECT cvebanco, imagen, imagen_formato
		INTO cCveBanco, bImagen, cImgFormato
		FROM bditef:"informix".cce_cheques_img	
		WHERE cvebanco = pCveBanco AND numcuenta = pCuenta
		  AND numcheque = pNumCheque AND lado_ft = pLadoFt
		  AND fechapresenta = dFechaPresenta;
				
		--SE VALIDA QUE EXISTA EL REGISTRO DE LA IMAGEN.
		IF NVL(cCveBanco, '') = '' THEN	
			
			LET cCodRet = '00002';
			LET cMensaje = 'NO EXISTE EL REGISTRO DEL CHEQUE';
			LET cImgFormato = '';
			RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);				
			
		END IF;
				
		--SE VALIDA SI EXISTE LA IMAGEN.		
		IF bImagen IS NULL Then 		
			--SE DETERMINA QUE LA IMAGEN NO EXISTE.				  			
			LET cCodRet = '00003';
			LET cMensaje = 'NO EXISTE IMAGEN DEL CHEQUE';
			LET cImgFormato = '';
			
		End If 
													
		RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Verifica si existe la imagen del cheque en la tabla cce_cheques_img', 
'AUTOR: Valentin Lopez',
'FECHA DE CREACION: 15 de Febrero del 2011',
'VERSION: 20110215.1745',
'MODIFICACION: Se incluyo validacion para saber si el cheque tiene detalle', 
'MODIFICO: Guadalupe Payan',
'FECHA DE MODIFICACION: 04 de Noviembre del 2011',
'VERSION: 20111104.1306',
'MODIFICACION: Se quito la validacion para saber si el cheque tiene detalle ya que se determino que no era necesario por logica del procedimiento', 
'MODIFICO: Guadalupe Payan',
'FECHA DE MODIFICACION: 08 de Noviembre del 2011',
'VERSION: 20111108.1700',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_obtbines_sif(pTarjeta CHAR(20))
RETURNING CHAR(5) AS COD_RET,
		  CHAR(100)AS COD_MENS,
		  CHAR(3)AS CVE_BCO;

--DECLARACION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE cCodRet1 CHAR(5);
DEFINE cMensaje CHAR(100);
DEFINE iSqlErr INTEGER ;
DEFINE cBanco CHAR(3);
DEFINE cTipo CHAR(1);

--INICIALIZAR VALORES A VARIABLES;
LET cCodRet='00000';
LET cCodRet1='00000';
LET cMensaje='PROCESO EXITOSO';
LET iSqlErr=0;
LET cBanco='';
LET cTipo='';

BEGIN
	ON EXCEPTION SET iSqlErr
	  IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet,cMensaje,cBanco;
	  END IF ;
	END EXCEPTION ;
	
	IF NVL(pTarjeta,"") = "" THEN
		LET cCodRet='00001';
		LET cMensaje ="Faltan parámetros de entrada, verifique...";		
	ELSE
		LET pTarjeta = SUBSTR(pTarjeta,1,6);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT creditodebito,cve_banco INTO cTipo,cBanco FROM  bdicheq:"informix".sc_bines WHERE bin= TRIM(pTarjeta);
		IF(cTipo<>'')THEN
			IF(cTipo='d')THEN
				LET cCodRet='00000';			
				LET cMensaje ="PROCESO EXITOSO";
			END IF;
			IF(cTipo='c')THEN
				LET cCodRet='00002';
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","574")
								INTO cCodRet1,cMensaje;		
			END IF;
		ELSE
				LET cCodRet='00003'; --No existe el bin
				LET cMensaje ="Tarjeta invalida, verifique.";
		END IF
	  -- Valida que la tarjeta no sea Bancoppel
		IF TRIM(cBanco) = "137" THEN
			LET cCodRet='00004';
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","572")
								INTO cCodRet1,cMensaje;						
		END IF
	END IF
	
	RETURN cCodRet,cMensaje,cBanco;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jesús Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que valida el bin de la tarjeta y obtiene la clave del banco.',
'FECHA: Julio 2012',
'BASE DE DATOS: BDITEF',
'VERSION: 20120730.1105';

CREATE PROCEDURE "informix".sp_tef_buscaoperacion(pfecha DATE,
												  pSucursal CHAR(4),
												  pEjecutivo CHAR(8),
												  pFolioSuc VARCHAR(16))  
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
VARCHAR(16) 	AS folio_suc,
VARCHAR(20)		AS num_cta_ord, 
VARCHAR(40)		AS referencia,
CHAR(10)		AS importe_tef, 
CHAR(2)		    AS reversado;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);

DEFINE cFolioSuc			VARCHAR(16);
DEFINE cNumCtaOrd			VARCHAR(20);
DEFINE cReferencia			VARCHAR(40);
DEFINE cImporte			    CHAR(10);
DEFINE cReversado			CHAR(2);
	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';

LET cFolioSuc			= '';
LET cNumCtaOrd			= '';
LET cReferencia			= '';
LET cImporte			= '';
LET cReversado			= '';


	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet),'','','','','';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_buscaoperacion.out';
	--TRACE ON;


	-- VALIDA QUE LOS parámetros NO VENGAN VACIOS
    IF NVL(pfecha,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pFolioSuc,"") = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta uno o mas parámetros';
	ELSE
		IF pfecha::DATE <> (SELECT fecha_hoy FROM  bdicheq:"informix".sc_fechas) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Fecha invalida, verifique...';
		ELSE
			IF EXISTS (SELECT folio_suc FROM bditef:"informix".tef_operaciones
					   WHERE fecha_trans = pfecha AND folio_suc = pFolioSuc
						AND sucursal = pSucursal AND user_insert = pEjecutivo) THEN
						
				SELECT folio_suc, num_cta_ord, referencia, importe_tef, DECODE(cve_status,"PE","N","05","S","")
					INTO cFolioSuc,cNumCtaOrd,cReferencia,cImporte,cReversado
				FROM bditef:"informix".tef_operaciones
				WHERE fecha_trans = pfecha
				AND folio_suc = pFolioSuc
				AND sucursal = pSucursal
				AND user_insert = pEjecutivo;
			ELSE
				LET cCodRet = '000003';
				LET cMensajeRet = 'No se encuentran registros en base a los datos indicados. Favor de validar.';
			END IF			
		END IF
    END IF;	

	RETURN cCodRet, TRIM(cMensajeRet),TRIM(cFolioSuc),TRIM(cNumCtaOrd),TRIM(cReferencia),TRIM(cImporte),cReversado;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la informacion de alta operaciones TEF en central, para ser reversados', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120626.1021';

CREATE PROCEDURE "informix".sp_tef_grabaoperacion(  pTipo CHAR(1), 
													pEmpresa CHAR(3),
													pFecha_Trans DATE,
													pFolio_Suc CHAR(16),
													pSucursal CHAR(4), 
													pNum_Cta_Ord CHAR(20),
													pTipo_Cta_Ord CHAR(2),
													pFecha_Prog DATE,
													pTipo_Oper CHAR(2),
													pCve_Rastreo CHAR(30),
													pNombre_Cte_Ord CHAR(30),
													pRfc_Cte_Ord CHAR(15),
													pImp_Tef CHAR(10),
													pComision_Tef CHAR(5),
													pIva_Tef CHAR(5),
													pImp_Tot_Tef CHAR(10),
													pTipo_Cta_Ben CHAR(2),
													pNombre_Ben CHAR(30),
													pNum_Cta_Tarj_Ben CHAR(20),
													pCve_Banco_Rec CHAR(3),
													pRfc_Ben CHAR(15),
													pConcep_Pago CHAR(50),
													pRef_Num CHAR(7),
													pReferencia CHAR(40),
													pCve_Canal CHAR(2),
													pMotivo_Dev CHAR(2), 
													pDivisa CHAR(2),
													pTransacSuc CHAR(4),
													pNumTarjeta  CHAR(16),
													pUsuario CHAR (8))				
 RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(100) 	AS desc_ret;

--DEFINICION DE VARIABLES
DEFINE iSqlErr       INTEGER;
DEFINE cCodRet1      CHAR (6); --Código Retorno
DEFINE cCodRet2      CHAR (6); --Código Retorno controlado para arma envios
DEFINE cCodRet3      CHAR (6); --Código Retorno 1 para sp de parámetros
DEFINE cNumSerial    CHAR (12);

DEFINE cTrans        CHAR(4);
DEFINE dtFecha        DATE;
DEFINE mSaldo        MONEY(14,2);
DEFINE mMonto        MONEY(14,2);
DEFINE iTransaccion  INTEGER;
DEFINE cTranscargo   CHAR(4);
DEFINE cComis        CHAR(4);
DEFINE cIvaComis     CHAR(4);
DEFINE cNumTran      CHAR(4);
DEFINE cMensaje      CHAR(100);
DEFINE cMensajeRet	 VARCHAR(100);

DEFINE cCodretVal   CHAR(5);
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);

--INICIALIZACION DE VARIABLES
LET iSqlErr      = 0;
LET cCodRet1     = "00000";
LET cCodRet2     = "00000";
LET cCodRet3     = "000000";

LET cNumSerial   = "";

LET iTransaccion = 0;
LET cTrans       = "";
LET dtFecha       = '01/01/1900';
LET mSaldo       = 0.00;
LET mMonto       = 0.00;
LET cTranscargo  = "";
LET cComis       = "";
LET cIvaComis    = "";
LET cNumTran     = "";
LET cMensaje     = "";
LET cMensajeRet	 = 'PROCESO EXITOSO';
    
LET cCodretVal   = "";
LET cTpo_Proc    = "";
LET cFech_Proc   = "";
LET cCve_Proc    = "";
LET cDescripcion = "";
LET cEstatus     = "";
	
--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_grabaoperacion.out';
--TRACE ON;
 BEGIN
	
	ON EXCEPTION SET iSqlErr --Manejador de Errores
        IF iSqlErr <> 0 then
            LET cCodRet1 = iSqlErr;
            IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cCodRet1, "Error de informix";
        END IF;
    END EXCEPTION;
	
	
	
    ON EXCEPTION IN (-535)
        LET iTransaccion = 1;
    END EXCEPTION WITH RESUME;

    IF iTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pFecha_Trans,"") = "" OR NVL(pFolio_Suc,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pNum_Cta_Ord,"") = "" OR
	   NVL(pTipo_Cta_Ord,"") = "" OR NVL(pFecha_Prog,"") = "" OR  NVL(pTipo_Oper,"") = "" OR NVL(pCve_Rastreo,"") = "" OR
	   NVL(pNombre_Cte_Ord,"") = "" OR NVL(pRfc_Cte_Ord,"") = "" OR  NVL(pImp_Tef,"") = "" OR NVL(pComision_Tef,"") = "" OR
	   NVL(pIva_Tef,"") = "" OR NVL(pImp_Tot_Tef,"") = "" OR NVL(pTipo_Cta_Ben,"") = "" OR NVL(pNombre_Ben,"") = "" OR
	   NVL( pNum_Cta_Tarj_Ben,"") = "" OR NVL(pConcep_Pago,"") = "" OR  NVL(pRef_Num,"") = ""  OR NVL(pCve_Canal,"") = "" OR
	   NVL(pMotivo_Dev ,"")= "" OR NVL(pUsuario,"") = "" OR NVL(pReferencia,"") = "" THEN
		   LET cCodRet1 = "000004";
		   LET cMensajeRet = "Parámetros invalidos, verifique...";
		   RETURN cCodRet1, TRIM(cMensajeRet);			
	END IF;
	
	
	SELECT TRIM(valor) 
	INTO cTranscargo  --transacción cargo
	FROM bditef:"informix".tef_parametros
	WHERE cod_param = '06';	
	SELECT fecha_hoy INTO dtFecha FROM  bdicheq:"informix".sc_fechas;
	
	IF cTranscargo IS NULL OR cTranscargo = '' THEN
		LET cCodRet1 = '000001'; --Falta parámetros de transacción cargo.
		LET cMensajeRet = "Falta parámetros de transacción cargo, verifique...";
		RETURN cCodRet1, TRIM(cMensajeRet);
	END IF;	
	
	EXECUTE PROCEDURE  bditef:"informix".sp_tef_validahorario(CURRENT HOUR TO SECOND)
		INTO cCodRet3, cMensaje;
	IF CAST(cCodRet3 AS INTEGER) <> 0 THEN
		LET cCodRet1 = "000002";
		LET cMensajeRet = cMensaje;	
	ELSE	
	    EXECUTE PROCEDURE sp_tef_validarchcod60('', "GENARCH_60.01") 
		INTO cCodretVal, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;		
		
		IF cCodretVal::integer <> 0 THEN					
			LET cCodRet1 = '000003';
			LET cMensajeRet = 'No es posible registrar la operación TEF. El proceso de generación de archivo ya ha iniciado.';							
		ELSE	
				
			IF pTipo = 1 THEN --Aplicar cargo			
				
					--validar si se va a cobrar comisión
				
					SELECT TRIM(valor)  
					INTO cComis --transacción cargo comisión
					FROM bditef:"informix".tef_parametros
					WHERE cod_param = '07';
				
					IF cComis IS NULL OR cComis = '' THEN
						LET cCodRet1 = '000005'; --Falta parámetros de transacción comisión.
						LET cMensajeRet = "Falta parámetros de transacción comisión, verifique...";
						RETURN cCodRet1, TRIM(cMensajeRet);
					END IF;
						
					SELECT TRIM(valor)  
					INTO cIvaComis --transacción cargo iva
					FROM bditef:"informix".tef_parametros
					WHERE cod_param = '08';
					
					IF cIvaComis IS NULL OR cIvaComis = '' THEN
						LET cCodRet1 = '000006'; --Falta parámetros de transacción iva.
						LET cMensajeRet = "Falta parámetros de transacción iva, verifique...";
						RETURN cCodRet1, TRIM(cMensajeRet);
					END IF;
					
					---Se aplica cargo por importe operación TEF
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cTranscargo, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0,  pImp_Tef,  pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
					INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
					IF CAST(cCodRet2 AS INT) <> 0 THEN
						IF iTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
						INTO cCodRet1,cMensajeRet;
					ELSE
						---Se aplica cargo por comisión en caso de que la comisión sea mayor que 0
						
						
						IF CAST(pComision_Tef AS MONEY(14,2)) > 0 THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pComision_Tef, pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
							INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
							IF CAST(cCodRet2 AS INT) <> 0 THEN
								IF iTransaccion = 1 THEN
									ROLLBACK WORK;
									BEGIN WORK;
								ELSE
									ROLLBACK WORK;
								END IF;
								EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
								INTO cCodRet1,cMensajeRet;
							ELSE
								---Se aplica cargo por iva comisión
								EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cIvaComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pIva_Tef,  pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
								INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
								IF CAST(cCodRet2 AS INT) <> 0 THEN
									IF iTransaccion = 1 THEN
										ROLLBACK WORK;
										BEGIN WORK;
									ELSE
										ROLLBACK WORK;
									END IF;			
								EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
								INTO cCodRet1,cMensajeRet;
								END IF;
							END IF;
						END IF;
					END IF;
			ELIF pTipo = 2 THEN --Grabar en TEF
										
					SELECT num_serial 
					INTO cNumSerial 
					FROM bdicheq:"informix".sc_movdia
					WHERE folio_suc = pFolio_Suc
					AND empresa = pEmpresa
					AND transacc = cTranscargo;
					
					IF cNumSerial IS NULL OR cNumSerial = "" THEN
						 LET cCodRet1 = "000011"; --NO EXISTE FOLIO SUCURSAL
						 LET cMensajeRet = "No existe folio sucursal, verifique...";
						 RETURN cCodRet1, TRIM(cMensajeRet);		 
					ELSE										
							  
						INSERT INTO bditef:"informix".tef_operaciones(fecha_trans,folio_suc,num_serial, sucursal, num_cta_ord,tipo_cta_ord,fecha_programacion,
							tipo_operacion,clave_rastreo,nombre_cte_ord,rfc_cte_ord,importe_tef,comision_tef,iva_tef,importe_tot_tef,
							tipo_cta_ben,nombre_ben,num_cuenta_tarj_ben,cve_banco_rec,rfc_ben,concepto_pago,ref_num,referencia,cve_canal,
							cve_status, motivo_dev, hora_insert, user_insert,fecha_insert)
							
						VALUES(pFecha_Trans,pFolio_Suc, cNumSerial, pSucursal, pNum_Cta_Ord, pTipo_Cta_Ord, pFecha_Prog,
							pTipo_Oper, pCve_Rastreo, pNombre_Cte_Ord, pRfc_Cte_Ord, pImp_Tef, pComision_Tef, pIva_Tef,	pImp_Tot_Tef,
							pTipo_Cta_Ben, pNombre_Ben, pNum_Cta_Tarj_Ben, pCve_Banco_Rec, pRfc_Ben, pConcep_Pago, pRef_Num, pReferencia, pCve_Canal,
							'PE', pMotivo_Dev, SUBSTR(CURRENT HOUR TO SECOND,1,2)||SUBSTR(CURRENT HOUR TO SECOND,4,2)||SUBSTR(CURRENT HOUR TO SECOND,7,2), pUsuario, CURRENT);
						
						
					END IF;			ELSE --validacion de tipo de operación
				LET cCodRet1 = "000013";
				LET cMensajeRet = "Tipo de operación invalida, verifique...";
			END IF; 
		END IF--VALIDACION DE ARCHIVO
	END IF;	IF cCodRet1::INTEGER = 0 THEN
		COMMIT WORK;	
	END IF
RETURN cCodRet1, TRIM(cMensajeRet);
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para dar de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_obtcodbanco(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
CHAR(3)		    AS Codigo_banco, 
VARCHAR(40)		AS Descripcion;	  
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cBanco			CHAR(3);
DEFINE cDescripcion			VARCHAR(40);	
DEFINE iContador			INTEGER;	

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cBanco			= '';
LET cDescripcion		= '';
LET iContador		= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtcodbanco.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(ptipo,0) NOT IN (1,2,3) OR (NVL(pCuenta,"") = "" AND  NVL(ptipo,0) IN (0,2,3)) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametro Invalido, Verifique...';
    END IF;
	
	IF ptipo = 1 THEN --créditos hipotecarios crédito automotriz, hipotecario ó personal		
		FOREACH 
			SELECT banco,descripcion
				INTO cBanco , cDescripcion
			FROM bdinteg:"informix".si_bancos
			WHERE banco <> '137'			
			AND flg_tef_r = '1'
			
			LET iContador= iContador+1;
			
			RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion) WITH RESUME;
		END FOREACH;
		
	ELIF ptipo = 2 THEN --Tarjeta de débito
		--Selección de Num. Tarjeta de Débito
		SELECT cve_banco,banco_prosa
			INTO cBanco , cDescripcion
		FROM bdicheq:"informix".sc_bines
		WHERE bin = SUBSTR(pCuenta, 1,6);		
		
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco,descripcion
			INTO cBanco , cDescripcion
		FROM bdinteg:"informix".si_bancos
		WHERE banco = SUBSTR(pCuenta,1,3)
		AND flg_tef_r = '1';				
	END IF;				
	
	IF iContador = 0 AND ptipo = 1  THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE...';
		RETURN cCodRet, cMensajeRet, cBanco, cDescripcion;
	ELIF iContador = 0 AND ptipo <> 1  THEN
		RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion);
	END IF;
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso obtiene los codigos de banco para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'DESCRIPCION: Se modifica procedimiento ya que regresaba dos veces el banco "021-HSBC MEXICO, S.A."', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120710.1021';

CREATE PROCEDURE "informix".sp_tef_obtinforpt(pClaveRastreo CHAR(30))
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
DATE 			AS fecha_trans,
CHAR(30)		AS clave_rastreo,
CHAR(10) 		AS importe_tef,
DATE 			AS fecha_programacion,
CHAR(45)		AS nombre_usuario,
CHAR(16)		AS folio_suc,
CHAR(30)		AS nombre_cte_ord,
CHAR(20)		AS numcte_ord,
CHAR(20)		AS num_cta_ord,
CHAR(30)		AS tipo_cta_ord_desc,
CHAR(5)			AS comision_tef,
CHAR(5)			AS iva_tef ,
CHAR(30)		AS nombre_ben,
CHAR(30)		AS tipo_cta_ben,
CHAR(20)		AS num_cuenta_tarj_ben,
CHAR(15)		AS rfc_ben,
CHAR(50)		AS concepto_pago,
CHAR(7)			AS ref_num,
CHAR(8)			AS hora_trans;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);	
	
DEFINE dtFecha_trans		DATE;
DEFINE cClave_rastreo 		CHAR(30);
DEFINE cImporte_tef 		CHAR(10) ;
DEFINE dtFecha_programacion DATE;
DEFINE cNombre_usuario 		CHAR(45);
DEFINE cFolio_suc 			CHAR(16);
DEFINE cNombre_cte_ord		CHAR(30);
DEFINE cNumcte_ord 			CHAR(20);
DEFINE cNum_cta_ord 		CHAR(20);
DEFINE cTipo_cta_ord 		CHAR(2);
DEFINE cTipo_cta_ord_desc	CHAR(30);
DEFINE cComision_tef 		CHAR(5);
DEFINE cIva_tef 			CHAR(5)	;
DEFINE cNombre_ben 			CHAR(30);
DEFINE cTipo_cta_ben 		CHAR(2);
DEFINE cTipo_cta_ben_des 	CHAR(30);
DEFINE cNum_cuenta_tarj_ben CHAR(20);
DEFINE cRfc_ben 			CHAR(15);
DEFINE cConcepto_pago 		CHAR(50);
DEFINE cRef_num 			CHAR(7)	;  
DEFINE cUsuario 			CHAR(8)	;  
DEFINE cHoraTrans 			CHAR(8)	;  
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
	
LET dtFecha_trans		 = "";
LET cClave_rastreo 		 = "";
LET cImporte_tef 		 = "";
LET dtFecha_programacion = "";
LET cNombre_usuario 	 = "";
LET cFolio_suc 			 = "";
LET cNombre_cte_ord		 = "";
LET cNumcte_ord 		 = "";
LET cNum_cta_ord 		 = "";
LET cTipo_cta_ord 		 = "";
LET cTipo_cta_ord_desc 	 = "";
LET cComision_tef 		 = "";
LET cIva_tef 			 = "";
LET cNombre_ben 		 = "";
LET cTipo_cta_ben 		 = "";
LET cTipo_cta_ben_des 	 = "";
LET cNum_cuenta_tarj_ben = "";
LET cRfc_ben 			 = "";
LET cConcepto_pago 		 = "";
LET cRef_num 			 = "";
LET cUsuario 			 = "";
LET cHoraTrans 			 = "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, ''	,'' ,'','','' ,'','','','' ,'','','','','','','','','','';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtinforpt.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pClaveRastreo,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE	
		
		IF EXISTS (SELECT  clave_rastreo FROM bditef:"informix".tef_operaciones	WHERE clave_rastreo = pClaveRastreo) THEN
			SELECT  fecha_trans, clave_rastreo, importe_tef,fecha_programacion,  folio_suc,nombre_cte_ord,
			num_cta_ord, tipo_cta_ord, comision_tef,iva_tef , nombre_ben,tipo_cta_ben, num_cuenta_tarj_ben,rfc_ben,
			concepto_pago, ref_num, user_insert,SUBSTR(hora_insert,1,2)||":"||SUBSTR(hora_insert,3,2)||":"||SUBSTR(hora_insert,5,2)
			INTO dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cFolio_suc,cNombre_cte_ord,
			cNum_cta_ord ,cTipo_cta_ord,cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben,cNum_cuenta_tarj_ben,cRfc_ben,
			cConcepto_pago,cRef_num,cUsuario,cHoraTrans
			FROM bditef:"informix".tef_operaciones
			WHERE clave_rastreo = pClaveRastreo;
			
			
			SELECT num_cte
				INTO cNumcte_ord
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = '001'
			AND cuenta = cNum_cta_ord;
			
			SELECT descripcion
				INTO cTipo_cta_ben_des
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ben;
			
			SELECT descripcion
				INTO cTipo_cta_ord_desc
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ord;
			
			SELECT nombre
			INTO cNombre_usuario
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cUsuario;
			
		ELSE
			LET cCodRet = '000002';
			LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE';
		END IF;		
    END IF;
	IF NVL(cRfc_ben,"") = "" THEN
		LET cRfc_ben ="NO DISPONIBLE";
	END IF;	
	
	RETURN cCodRet, cMensajeRet, dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cNombre_usuario ,cFolio_suc,cNombre_cte_ord,cNumcte_ord 	,cNum_cta_ord ,cTipo_cta_ord_desc,
		cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben_des,cNum_cuenta_tarj_ben,cRfc_ben,cConcepto_pago,cRef_num,cHoraTrans;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la informacion para visualizar el reporte de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120625.1021';

CREATE PROCEDURE "informix".sp_tef_obttipocta()
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
VARCHAR(2)		AS tipo_cuenta, 
VARCHAR(20)		AS descripcion_cuenta;
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cTipo_cta			CHAR(2);
DEFINE cDescripcion			VARCHAR(20);
	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cTipo_cta			= '';
LET cDescripcion		= '';
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet), '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obttipocta.out';
	--TRACE ON;

	FOREACH 
		 SELECT tipo_cta, descripcion
		 INTO cTipo_cta, cDescripcion
		 FROM bditef:"informix".tef_tipo_cta
		 ORDER BY tipo_cta
		 
		 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) WITH RESUME;
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2")= 0 THEN
	 LET cCodRet = '000001';
	 LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
	 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) ;
	END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que obtiene los tipos de cuentas para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_reversoperacion(pfecha DATE,
												  pSucursal CHAR(4),
												  pEjecutivo CHAR(8),
												  pFolioSuc VARCHAR(16))  
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(100) 	AS desc_ret;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodretRev			CHAR(5);
DEFINE cMensajeRet			VARCHAR(100);

DEFINE cFolioSuc			VARCHAR(16);
DEFINE cNumCtaOrd			VARCHAR(20);
DEFINE cReferencia			VARCHAR(40);
DEFINE cImporte			    CHAR(10);
DEFINE cReversado			CHAR(2);

DEFINE cCodretVal   CHAR(5);
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cCodretRev			= '00000';
LET cMensajeRet			= 'PROCESO EXITOSO';

LET cFolioSuc			= '';
LET cNumCtaOrd			= '';
LET cReferencia			= '';
LET cImporte			= '';
LET cReversado			= '';

LET cCodretVal   = "";
LET cTpo_Proc    = "";
LET cFech_Proc   = "";
LET cCve_Proc    = "";
LET cDescripcion = "";
LET cEstatus     = "";

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_reversoperacion.out';
	--TRACE ON;

	-- VALIDA QUE LOS parámetros NO VENGAN VACIOS
    IF NVL(pfecha,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pFolioSuc,"") = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta uno o mas parámetros';
	ELSE
		IF pfecha::DATE <> (SELECT fecha_hoy FROM  bdicheq:"informix".sc_fechas) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Fecha invalida, verifique...';
		ELSE
			IF EXISTS (SELECT folio_suc FROM bditef:"informix".tef_operaciones
					   WHERE fecha_trans = pfecha AND folio_suc = pFolioSuc
						AND sucursal = pSucursal AND user_insert = pEjecutivo ) THEN
						
				SELECT  DECODE(cve_status,"PE","N","05","S","")	
					INTO cReversado
				FROM bditef:"informix".tef_operaciones
				WHERE fecha_trans = pfecha
				AND folio_suc = pFolioSuc
				AND sucursal = pSucursal
				AND user_insert = pEjecutivo;
				
				IF cReversado = "S" THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'Folio proporcionado ya fue reversado, verifique...';
				ELIF cReversado = "" THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'Folio se encuentra en estatus invalido, verifique...';
				ELSE
					EXECUTE PROCEDURE  bditef:"informix".sp_tef_validahorario(CURRENT HOUR TO SECOND)
						INTO cCodRet, cMensajeRet;
					IF CAST(cCodRet AS INTEGER) <> 0 THEN --SE VALIDA QUE EL HORARIO SE ENCUENTRE EN EL RANGO PERMITIDO
						LET cCodRet = "000002";
						LET cMensajeRet = cMensajeRet;	
					ELSE										
						EXECUTE PROCEDURE bditef:"informix".sp_tef_validarchcod60('', "GENARCH_60.01") 
						INTO cCodretVal, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;		
						
						IF cCodretVal::integer <> 0 THEN					
							LET cCodRet = '000003';
							LET cMensajeRet = 'No es posible registrar la operación TEF. El proceso de generación de archivo ya ha iniciado.';							
						ELSE							
							EXECUTE PROCEDURE bdicheq:"informix".reversion_sif('001',pSucursal,pEjecutivo,pFolioSuc,'A') INTO cCodretRev;
							
							IF cCodretRev::INTEGER <> 0 THEN
								LET cCodRet = '000006';
								LET cMensajeRet = 'Ocurrio un error al realizar la reversion, verifique...';							
							END IF
						END IF
					END IF
				END IF
				
			ELSE
				LET cCodRet = '000007';
				LET cMensajeRet = 'no se encontro informacion, verifique...';
			END IF			
		END IF
    END IF;	

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para reversar la informacion de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120626.1021',
'DESCRIPCION: Se cambia el nombre al llamado del procedimiento "reversion" por "reversion_sif"', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Julio 2012',
'VERSION: 20120717.0921';

CREATE PROCEDURE "informix".sp_tef_validahorario(pHorario DATETIME HOUR TO MINUTE)
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(100) 	AS desc_ret;  
	
---DECLARACIONES
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(100);
DEFINE cCodRet      CHAR(6);
DEFINE cMensajeRet  VARCHAR(100);
DEFINE dtHorarioMax DATETIME HOUR TO MINUTE;

---INICIALIZACIONES
LET iSqlErr			= 0;
LET iIsamErr		= 0;
LET cErrorInfo		= '';
LET cCodRet			= '000000';
LET cMensajeRet		= 'PROCESO EXITOSO';
LET dtHorarioMax	= '';

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_validahorario.out';
	--TRACE ON;	
	--se obtiene la hora maxima permitida
	 IF NVL(pHorario,"") = ""  THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'PARAMETRO INVALIDO, VERIFIQUE...';
     END IF;
	 
	SELECT valor INTO  dtHorarioMax FROM  bditef:"informix".tef_parametros
	WHERE cod_param = '11';	
	
	IF pHorario >= dtHorarioMax THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'No es posible registrar la operación TEF. El horario excede del tiempo máximo establecido.';
	END IF;

	RETURN cCodRet, TRIM(cMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la validación del horario permitido para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_validarchcod60(pTpo_Proc CHAR(1), pCve_Proceso CHAR(20))

RETURNING CHAR(5), CHAR(1), CHAR(10), CHAR(20), CHAR(60), CHAR(1);

---Declaración de Variables
DEFINE cCodret   CHAR(5);
DEFINE sql_err   INTEGER;
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);
DEFINE cFecha_hoy CHAR(10);

---Inicialización de Variables
LET cCodret = '00000';
LET sql_err = 0;
LET cTpo_Proc = "";
LET cFech_Proc = DATE(1);
LET cCve_Proc = "";
LET cDescripcion = "";
LET cEstatus = "";
LET cFecha_hoy = DATE(1);
	   

    -- SET DEBUG FILE TO "/respaldosbd/hectorb/sp_tef_validarchcod60.out";
    -- TRACE ON;	   
	   


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodret = sql_err;
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		END IF;
	END EXCEPTION;
	
	IF pTpo_Proc <> "" OR pCve_Proceso <> "" THEN
		IF pTpo_Proc <> "" AND pCve_Proceso <> "" THEN
			LET cCodret = "00001";
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		ELSE
			SELECT fecha_hoy
			INTO cFecha_hoy
			FROM bdicheq:"informix".sc_fechas;
			
			
			IF pTpo_Proc <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE tipo_proceso = pTpo_Proc
					
					LET cCodret = "00003";	
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH
			ELIF pCve_Proceso <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE  fecha_proceso = cFecha_hoy
					AND cve_proceso = pCve_Proceso
					
					LET cCodret = "00002";
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH

			END IF;
		END IF;	
	END IF;
	
     
	RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;

END;

END PROCEDURE
DOCUMENT
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION: Validar si incio o no la generación del Archivo Código 60',
'FECHA : 28/06/2012',
'BD    : bditef';

CREATE PROCEDURE "informix".sp_tef_validarecepcion(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret;

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodRet1				CHAR(6);
DEFINE vMensajeRet			VARCHAR(80);
DEFINE sBandera			    SMALLINT;
DEFINE cBanco 				CHAR(3);

---INICIALIZACIONES
LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet					= '000000';
LET cCodRet1				= '000000';
LET vMensajeRet				= 'PROCESO EXITOSO';
LET sBandera		    	= 0;
LET cBanco					= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(vMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/vlv/sp_tef_validarecepcion.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF (NVL(pCuenta,"") = "" OR NVL(ptipo,0) NOT IN (2,3)) THEN
		LET cCodRet = '000001';
		LET vMensajeRet = 'Parámetros inválidos';
    END IF;

    IF ptipo = 2 THEN --Tarjeta de débito	
			IF NOT EXISTS (SELECT banco	
							FROM bdinteg:"informix".si_bancos
							WHERE banco = (SELECT cve_banco	
							   			FROM bdicheq:"informix".sc_bines 
										WHERE bin = SUBSTR(pCuenta, 1,6) AND UPPER(creditodebito) = 'D')
 							AND flg_tef_r = '1') THEN
				LET sBandera=1;				
			END IF;	
	
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco 
		INTO cBanco 
		FROM bdinteg:"informix".si_bancos WHERE banco = SUBSTR(pCuenta,1,3)	AND flg_tef_r = '1';
		
		IF TRIM(NVL(cBanco, '')) = '' THEN		
			LET sBandera=1;
		ELIF TRIM(NVL(cBanco, '')) = '137' THEN
			LET sBandera=2;	
		END IF;	
		
	END IF;
	
	IF sBandera = 1 THEN	
		LET cCodRet = '000002';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","099")
									INTO cCodRet1,vMensajeRet;	
	ELIF sBandera = 2 THEN
		LET cCodRet = '000003';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","573")
									INTO cCodRet1,vMensajeRet;	
	END IF;			
    
	RETURN cCodRet, TRIM(vMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que valida que la cuenta sea valida para recepcion de operaciones TEF en central',
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'MODIFICO: Valentin Lopez Valenzuela.',
'DESCRIPCION: Se agrego una validación para no permitir realizar transferencia de envio de fondos a BANCOPPEL. (ptipo = 3) ',
'BASE DE DATOS: bditef',
'FECHA: Agosto 2012',
'VERSION: 20120809.1544';

create procedure "informix".stat_cheque (
                    pempresa    char(3),
                    pcuenta     char(20),
                    pnrocheque  integer)
       returning    char(5),    --codret
                    char(2);    --motdevol

    -- v1.0 validacion extra cuando el cheque no ha sido
    -- aplicado pero ya esta en la base de datos
    -- lalo jun10
                    
    -- v1.0 version inicial
    -- eduardo espinosa oct09
    -- devuelve el status de la cuenta/cheque

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmotdevol    char(2);
    define vcuenta      char(20);
    define vstatuscta   char(1);
    define vmotivo      char(2);
    define vchequestat  char(1); 
    define vcargo       char(1);
    
    let vcodret     = "000";
    let vmotdevol   = "00";
    let vcargo      = "S";

    
    
--set debug file to "/pisa/liberoltp/pisa_ftes/cecoban/stat_cheque.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmotdevol;
        end if
    end exception;

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            return vcodret,vmotdevol;
    end if



    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques 
    -- o que si la cuenta esta cancelada (status_cta="2")
    
    select  cuenta, status_cta,motivo
    into    vcuenta, vstatuscta, vmotivo
    from    bdicheq:sc_maechq
    where   cuenta = pcuenta;
    
    
    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta = "2" then
    
            let vmotdevol   = "02";
            return vcodret,vmotdevol;
            
    else
    
        -- cta bloqueada pero acepta cargos
        if  vstatuscta = "3" then
            select  cargo 
            into    vcargo
            from    bdicheq:sc_bloqueo
            where   codigo = vmotivo;

            if vcargo = "N" then
                let vmotdevol   = "09"; -- cta bloqueada
                return vcodret,vmotdevol;
            end if
        end if        


        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        
        if vcargo = "S" then
        
            select  estado
            into    vchequestat
            from    bdicheq:sc_contch
            where   empresa = pempresa
            and     cuenta  = pcuenta
            and     numero  = pnrocheque;

            -- no encontro registros
            -- La numeración del cheque no corresponde 
            
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol   = "51";       
            end if

            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                -- cta OK  
            end if

            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
            end if 
            
            -- presentado por camara
            if vchequestat = "N"  then
                let vmotdevol   = "18";
            end if             

            -- revocado
            if vchequestat = "R"  then
                let vmotdevol   = "08";
            end if                

            -- cancelado
            -- CHEQUE EXTRAVIADO
            if vchequestat = "C"  then
                let vmotdevol   = "52";
            end if 

            -- incompleto
            if vchequestat = "I"  then
                let vmotdevol   = "51";
            end if 

            -- destruido
            if vchequestat = "D"   then
                let vmotdevol   = "23";
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J"  then
                let vmotdevol   = "07";
            end if 

            -- bloqueado autoridades
            if vchequestat = "B"  then
                let vmotdevol   = "09";
            end if 
            
            
            -- validacion extra 
            
            if exists (select c_cuenta from cce_propios_det
                        where c_cuenta = pcuenta 
                        and c_cheque = pnrocheque
				and status = '01') then
                        
                let vmotdevol   = "16";
            end if 
            
            

        end if --validar los status del cheque


                
    end if    --cuenta, sdo_actual
 

    return vcodret,vmotdevol;    
    
end

END PROCEDURE;