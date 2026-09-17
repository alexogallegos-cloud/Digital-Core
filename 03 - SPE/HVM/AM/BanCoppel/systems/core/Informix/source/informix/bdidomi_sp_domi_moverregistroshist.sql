CREATE PROCEDURE "informix".sp_domi_moverregistroshist(pNombreArchivo CHAR(20),pFecha char(8), pTipo CHAR(1))
	RETURNING CHAR(5);


	--'Modifico :Alejandro Osuna Iza',
	--'DESCRIPCION: Se divio el proceso para que borrara y copiara por separado',
	--'           : y se realizo por bloques para su mejor manejo de informacion',
	--'FECHA : Julio de 2009',
--	--	'BD    : BDIDOMI',
	--'VERSION: 200907';
---Agregar un nombre de archivo 11
---- VARIABLES  GENERALES---
DEFINE  cSqlerr		INTEGER;
DEFINE  cCodret     CHAR(5);
DEFINE  cMensaje    CHAR(200);
DEFINE cTipo 		CHAR(1);
DEFINE v_FechaPre	CHAR(8);


---- VARIABLES ENCABEZADO -----
DEFINE cNombre_archE CHAR(20);
DEFINE cFecha_presentacionE CHAR(8);
DEFINE cTpo_registro CHAR(2);
DEFINE cNum_secuenciaE CHAR(7);
DEFINE cCod_operacionE CHAR(2);
DEFINE cCve_banco CHAR(3);
DEFINE cSentido CHAR(1);
DEFINE cServicio CHAR(1);
DEFINE cNum_bloque CHAR(7);
DEFINE cCod_divisaE CHAR(2);
DEFINE cCve_rechazo_bl CHAR(2);
DEFINE cModalidad CHAR(1);
DEFINE cUso_futuro_ccenE CHAR(41);
DEFINE cUso_futuro_bancoE CHAR(345);
DEFINE cUser_insertE CHAR(8);
DEFINE dFecha_insertE date;

---- VARIABLES DETALLE -----
DEFINE cNombre_archD CHAR(20);
DEFINE cFecha_presentacionD CHAR(8);
DEFINE cTipo_registro CHAR(2);
DEFINE cNum_secuenciaD CHAR(7);
DEFINE cCod_operacionD CHAR(2);
DEFINE cCod_divisaD CHAR(2);
DEFINE cFecha_trans CHAR(8);
DEFINE cBanco_presentador CHAR(3);
DEFINE cBanco_receptor CHAR(3);
DEFINE cImporte CHAR(15);
DEFINE cUso_futuro_ccenD CHAR(16);
DEFINE cTipo_operacion CHAR(2);
DEFINE cFecha_aplica CHAR(8);
DEFINE cTipo_cta_ord CHAR(2);
DEFINE cNum_cta_ord CHAR(20);
DEFINE cNombre_ord CHAR(40);
DEFINE cRfc_ord CHAR(18);
DEFINE cTipo_cta_rec CHAR(2);
DEFINE cNum_cta_rec CHAR(20);
DEFINE cNombre_rec CHAR(40);
DEFINE cRfc_rec CHAR(18);
DEFINE cRef_servicio CHAR(40);
DEFINE cNombre_titular_serv CHAR(40);
DEFINE cImporte_iva CHAR(15);
DEFINE cRef_numerica CHAR(7);
DEFINE cRef_leyenda CHAR(40);
DEFINE cClave_rastreo CHAR(30);
DEFINE cMotivo_dev CHAR(2);
DEFINE cFecha_pres_ini CHAR(8);
DEFINE cUsu_futuro_bancoD CHAR(12);
DEFINE cCve_estatus CHAR(2);
DEFINE cFolio_suc CHAR(16);
DEFINE cUser_insertD CHAR(8);
DEFINE dFecha_insertD DATE;

---- VARIABLES SUMARIO -----
DEFINE cNombre_archS CHAR(20);
DEFINE cFecha_presentacionS CHAR(8);
DEFINE cTipo_registroS CHAR(2);
DEFINE cNum_secuenciaS CHAR(7);
DEFINE cCod_operacionS CHAR(2);
DEFINE cNum_bloqueS CHAR(7);
DEFINE cNum_operaciones CHAR(7);
DEFINE cImp_operaciones CHAR(18);
DEFINE cUso_futuro_ccenS CHAR(40);
DEFINE cUso_futuro_bancoS CHAR(339);
DEFINE cUser_insertS CHAR(8);
DEFINE dFecha_insertS DATE;
DEFINE cCve_status CHAR(2);
DEFINE iTot_registros INTEGER;
DEFINE iContadorfilas INTEGER;
DEFINE cCiclo CHAR(1);
--DEFINE cContaDele Integer;
DEFINE cDeleMax integer;
DEFINE cDeleMin integer;
DEFINE iInicio	integer;
DEFINE iFin	integer;
DEFINE dFechaSis DATE;
DEFINE iRangoFin integer;
DEFINE iFilas integer;
DEFINE cCicloDele CHAR(1);
DEFINE cNivel char(1);
DEFINE cErrorNiv	CHAR(1);
DEFINE vtransaccion				integer;

LET cCodret = '00000';
LET iInicio = 0;
LET iFin = 4999;
LET iRangoFin  = 4999;
LET cCicloDele = "N";
LET iFilas = 0;
LET cErrorNiv = "1";

----INICIALIZAR  VARIABLES ENCABEZADO -----
LET cNombre_archE ='';
LET cFecha_presentacionE='';
LET cTpo_registro ='';
LET cNum_secuenciaE ='';
LET cCod_operacionE ='';
LET cCve_banco ='';
LET cSentido ='';
LET cServicio ='';
LET cNum_bloque ='';
LET cCod_divisaE ='';
LET cCve_rechazo_bl ='';
LET cModalidad ='';
LET cUso_futuro_ccenE ='';
LET cUso_futuro_bancoE ='';
LET cUser_insertE ='';
LET dFecha_insertE ='';

---INICIALIZAR VARIABLES DETALLE
LET cNombre_archD ='';
LET cFecha_presentacionD ='';
LET cTipo_registro ='';
LET cNum_secuenciaD ='';
LET cCod_operacionD ='';
LET cCod_divisaD ='';
LET cFecha_trans ='';
LET cBanco_presentador ='';
LET cBanco_receptor ='';
LET cImporte ='';
LET cUso_futuro_ccenD ='';
LET cTipo_operacion ='';
LET cFecha_aplica ='';
LET cTipo_cta_ord ='';
LET cNum_cta_ord ='';
LET cNombre_ord ='';
LET cRfc_ord ='';
LET cTipo_cta_rec ='';
LET cNum_cta_rec ='';
LET cNombre_rec ='';
LET cRfc_rec ='';
LET cRef_servicio ='';
LET cNombre_titular_serv ='';
LET cImporte_iva ='';
LET cRef_numerica ='';
LET cRef_leyenda ='';
LET cClave_rastreo ='';
LET cMotivo_dev ='';
LET cFecha_pres_ini ='';
LET cUsu_futuro_bancoD ='';
LET cCve_estatus ='';
LET cFolio_suc ='';
LET cUser_insertD ='';
LET dFecha_insertD ='';

----INICIALIZAR VARIABLES SUMARIO -----
LET cNombre_archS='';
LET cFecha_presentacionS ='';
LET cTipo_registroS ='';
LET cNum_secuenciaS ='';
LET cCod_operacionS ='';
LET cNum_bloqueS ='';
LET cNum_operaciones ='';
LET cImp_operaciones ='';
LET cUso_futuro_ccenS ='';
LET cUso_futuro_bancoS ='';
LET cUser_insertS ='';
LET dFecha_insertS ='';

let cTipo = pTipo;
LET iContadorfilas = 0;
LET cCiclo = "N";
LET cDeleMax = 0;
LET cDeleMin = 0;
LET cNivel = "";
LET v_FechaPre = "";
LET vtransaccion = 0;

    --SET debug FILE TO "/RESPALDOSNEW/enrique/sp_Domi_MoverRegistrosHist.out";
    --Trace ON;
Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
			rollback work;
			-- Antes de borrar la tabla de archivos se requiere borrar la de encabezado
			--DELETE FROM dom_cce_encabezado WHERE nombre_arch = pNombreArchivo; --AND Fecha_presentacion = pFecha;
			--borrado de tablas   dom_cce_archivos
			--DELETE FROM dom_cce_archivos WHERE nombre_arch = pNombreArchivo; --AND Fecha_presentacion = pFecha;
			--commit work;
            RETURN cCodret;

        END IF;
    END EXCEPTION;
	on exception in (-535)
		let vtransaccion = 1;
	end exception with resume;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF  (cTipo = "T")  OR (cTipo = "B")   THEN
	ELSE
		LET cCodret = '00617';
		RETURN cCodret;
	END IF;
	if vtransaccion = 1 then
	   COMMIT WORK;
	END IF;

	IF cTipo = "T" THEN
		BEGIN WORK;
		LET cNivel = "1";
			--- errores  q se deben manejar en este sp 01200 - 01299
			/* hay q ver donde vorrarlos wee */
			--HAY Q OBTENER LOS DATOS Q SE BAN A OCUPAR PARA EL INSERT

			SELECT Fecha_presentacion,'01',num_operaciones,User_insert
			INTO cFecha_presentacionE,cCve_status, iTot_registros, cUser_insertE
			FROM  Dom_cce_sumario_paso WHERE nombre_arch = pNombreArchivo AND Fecha_presentacion = pFecha;

			--insertar en las dom_cce_archivos q pedo con la fecha de aplicacion y q datos me va a mandar wee q mandas en  5
			--INSERT INTO Dom_cce_archivos(nombre_arch,fecha_presentacion,fecha_aplicacion, cve_status,tot_registros ,user_insert ,fecha_insert )
			--VALUES(pNombreArchivo,cFecha_presentacionE,current,cCve_status, iTot_registros,cUser_insertE,current);

			/*INSERT INTO dom_status_archcce(cve_status ,descripcion ,user_insert ,fecha_insert )
			VALUES('01', 'nose', 'INformix', current);
			*/
			-- PASO DE LA TABLA ENCABEZADO_PASO  A LA DE ENCABEZADO MAESTRA
			SELECT   Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio, Num_bloque,
					Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
			INTO    cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
					cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE
			FROM Dom_cce_encabezado_paso WHERE nombre_arch = pNombreArchivo AND Fecha_presentacion = pFecha;

			---Insert a la tabla Encabezado maestra
			INSERT INTO Dom_cce_encabezado( Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio,
				        Num_bloque, Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
			Values( cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
					cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE);

					-- PASO DE LA TABLA DETALLE_PASO  A LA DE DETALLE MAESTRA

			FOREACH WITH HOLD
			--WHILE cCicloDele = "N"
				SELECT   Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Cod_divisa,
						Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen, Tipo_operacion, Fecha_aplica, Tipo_cta_ord,
						Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec, Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv,
						Importe_iva, Ref_numerica, Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus,
						Folio_suc, User_insert, Fecha_insert
				INTO    cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
						cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica, cTipo_cta_ord,
						cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,
						cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev, cFecha_pres_ini, cUsu_futuro_bancoD, cCve_estatus,
						cFolio_suc, cUser_insertD, dFecha_insertD
				FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Fecha_presentacion = pFecha
				IF cCiclo = "S" THEN
					BEGIN WORK;
					LET cCiclo = "N";
				END IF;
				LET cNivel = "2";
				---Insert a la tabla Detalle maestra
				INSERT INTO dom_cce_detalle(Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion,
									Cod_divisa, Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen,
									Tipo_operacion, Fecha_aplica, Tipo_cta_ord, Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec,
									Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv, Importe_iva, Ref_numerica,
									Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus, Folio_suc,
									User_insert, Fecha_insert)
				Values (cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
						cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica,
						cTipo_cta_ord,cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec,
						cRef_servicio, cNombre_titular_serv,cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev,
						cFecha_pres_ini, cUsu_futuro_bancoD, cCve_estatus, cFolio_suc, cUser_insertD, dFecha_insertD);
				LET iContadorfilas = iContadorfilas + 1;
				IF iContadorfilas = 1000 THEN
				--IF iContadorfilas = 9 THEN
					Commit work;
					LET cCiclo = "S";

					LET iContadorfilas = 0;
					CONTINUE FOREACH;
				END IF;
			END FOREACH;

			-- PASO DE LA TABLA SUMARIO_PASO  A LA DE SUMARIO MAESTRA
			SELECT Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque, Num_operaciones,
				   Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
			INTO   cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
				   cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS
			FROM Dom_cce_sumario_paso WHERE nombre_arch = pNombreArchivo AND Fecha_presentacion = pFecha;

			---Insert a la tabla sumario maestra
			INSERT INTO Dom_cce_sumario( Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque,
				        Num_operaciones, Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
			VALUES( cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
				        cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS);
			--RETURN cCodret;
			LET cTipo = "B";
			IF iContadorfilas <> 0 THEN
				Commit work;
			END IF;
			--LET pFecha = dFecha_insertS;
	END IF;
	IF cTipo = "B" THEN
		BEGIN WORK;
		WHILE cCicloDele = "N"
			--SELECT fecha_hoy INTO dFechaSis from bdinteg:si_fechas;
			DELETE FROM Dom_cce_encabezado_paso WHERE nombre_arch = pNombreArchivo ;
			--AND fecha_insert = pFecha;
			SELECT MIN(num_secuencia::INTEGER ) INTO cDeleMin FROM bdidomi:Dom_cce_detalle_paso
					WHERE nombre_arch = pNombreArchivo ;
					--AND Fecha_insert = pFecha;
			LET cDeleMin = lpad(TRIM((cDeleMin::integer)::char(7)),7,'0');
			SELECT MAX(num_secuencia::INTEGER) INTO cDeleMax  FROM bdidomi:Dom_cce_detalle_paso
					WHERE nombre_arch = pNombreArchivo;
					--AND Fecha_insert = pFecha;
			LET cDeleMax = lpad(TRIM((cDeleMax::integer)::char(7)),7,'0');


				IF cCiclo = "S" THEN
					BEGIN WORK;
					LET cCiclo = "N";
				END IF;
				LET iRangoFin = lpad(TRIM((iRangoFin::integer)::char(7)),7,'0');
				LET cDeleMin = lpad(TRIM((cDeleMin::integer)::char(7)),7,'0');

				DELETE FROM Dom_cce_detalle_paso
				WHERE nombre_arch = pNombreArchivo
				--AND Fecha_insert = pFecha
				AND num_secuencia between cDeleMin AND iRangoFin;

				LET cDeleMin = cDeleMin + 4998;
				LET iRangoFin = iRangoFin + 4998;
				--LET cDeleMin = cDeleMin + 8;
				--LET iRangoFin = iRangoFin + 8;
				LET iRangoFin = lpad(TRIM((iRangoFin::integer)::char(7)),7,'0');
				LET cDeleMin = lpad(TRIM((cDeleMin::integer)::char(7)),7,'0');
				IF (cDeleMax >= cDeleMin)  AND (iRangoFin <= cDeleMax  ) THEN

					Commit work;
					LET cCiclo = "S";
				ELSE
					LET cCicloDele = "S";
				END IF;
			END WHILE;

			DELETE FROM Dom_cce_sumario_paso WHERE nombre_arch = pNombreArchivo; --AND Fecha_insert = pFecha;

		Commit work;
	END IF;
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'AUTOR :CÃ©r ValdÃ©Figueroa',
'DESCRIPCION: Este procedimiento se encarga de pasar los datos que se encuentran en las tablas de paso',
'           : a las tablas maestras enn base al nombre de archivo y la fecha',
'FECHA : Julio de 2009',
'BD    : BDIDOMI',
'VERSION: 200907';

CREATE PROCEDURE "informix".sp_guarda_cancelaciones(
	cNumCliente           CHAR(20),
	cNumeroCuenta         CHAR(20),
	cNumeroTarjeta        CHAR(20),
	cTipoDomiciliacion    CHAR(1),
	cCuentaClabe          CHAR(20),
	cStatusCancelacion    CHAR(1),
	cRefLeyenda           CHAR(40),
	cFolioSuc    		  CHAR(17),
	cSucursal             CHAR(4),
	cTransaccion          CHAR(4),
	cMonto                CHAR(15),
	cFechaMov             CHAR(12),
	cRefCliente           CHAR(15),
	cUsuarioInsert        CHAR(10),
	cFechaInsert          DATE)
	
	RETURNING 

	CHAR(5)   AS sCodigoRetorno, 
	CHAR(100) AS sCodigoDescripcion;
	
	/*  DEFINICION DE VARIABLES */

	-- DATOS SALIDA
	DEFINE sCodigoRetorno     CHAR(5);
	DEFINE sCodigoDescripcion CHAR(100);
	DEFINE iSqlErr            INTEGER;
	DEFINE sTipoNomDomi       CHAR(50);
	DEFINE sTipoNomMovimiento CHAR(2);
	DEFINE sRfcServicio       CHAR(20);
	DEFINE refServicio        CHAR(40);
	DEFINE cNumCteCoppel      CHAR(20);
	DEFINE cRfcCoppel         CHAR(18);
	
		
		/* INICIALIZACION DE VARIABLES */
	
	LET sCodigoRetorno = '00000';
	LET sCodigoDescripcion = 'Proceso Exitoso.';
	LET sTipoNomDomi = '';
	LET sTipoNomMovimiento = '';
	LET sRfcServicio = '';
	LET refServicio = '';
	LET cNumCteCoppel = '';
	LET cRfcCoppel = '';
	
	
BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno,'', 'bdidomi:sp_guarda_cancelaciones', 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));
			
			RETURN sCodigoRetorno,sCodigoDescripcion;
		END IF;
	END EXCEPTION; 

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF cNumeroTarjeta = '' OR LENGTH(cNumeroTarjeta) <= 15 OR LENGTH(cNumeroTarjeta) >= 17 THEN
		
		LET sCodigoRetorno = '00006';
	    LET sCodigoDescripcion = 'Tarjeta Invalida.';
		RETURN sCodigoRetorno,sCodigoDescripcion;
	
	END IF;
		
		IF EXISTS(SELECT count(*) FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) OR numcte = TRIM(cNumCliente) OR num_tarjeta = TRIM(cNumeroTarjeta))THEN  --Domiciliacion bancoppel
			
			FOREACH
				SELECT a.rfc
				INTO  sRfcServicio
				FROM bdidomi:dom_autorizaciones a
				INNER JOIN bdidomi:dom_cat_servicios b ON a.rfc = b.rfc
				WHERE a.num_cte = TRIM(cNumCliente)
				
				SELECT LPAD(TRIM(cuenta_clabe),20,'0') INTO cCuentaClabe FROM bdicheq:sc_maechq WHERE cuenta = TRIM(cNumeroCuenta);
				
				SELECT TRIM(valor) INTO cNumCteCoppel FROM bdidomi:dom_parametros WHERE cod_param = '45';
				
				SELECT rfc INTO cRfcCoppel FROM bdidomi:dom_cat_servicios WHERE num_cte=TRIM(cNumCteCoppel);
				                         
				IF sRfcServicio = TRIM(cRfcCoppel) THEN
					
					LET sTipoNomMovimiento = 'BA';
					
					SELECT imp_operacion, user_insert,ref_servicio
					INTO cMonto, cUsuarioInsert, refServicio
					FROM bdidomi:dom_cte_detalle a
					WHERE a.folio_suc = TRIM(cFolioSuc)
					AND a.ref_leyenda = TRIM(cRefLeyenda)
					AND a.nombre_arch LIKE '%E%'
					AND a.estatus = '01'
					AND (a.cuenta_cargo IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) AND numcte = TRIM(cNumCliente))
					OR a.cuenta_cargo = cCuentaClabe);
					
					IF NOT refServicio IS NULL OR NOT refServicio = "" THEN
					
						IF cTipoDomiciliacion = '1' THEN
							LET sTipoNomDomi = 'Domiciliacion por tarjeta'; ---Cancelacion de domiciliaciones por tarjeta
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							
							UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02' WHERE cuenta = cNumeroCuenta AND num_cte = cNumCliente; --Inhabilita la cuenta para poder hacer domiciliaciones
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						ELIF (cTipoDomiciliacion = '2') THEN
							LET sTipoNomDomi = 'Domiciliacion en especifico'; --Cancelacion de domiciliaciones en especifico
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						END IF;		
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					ELSE 
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					END IF;		
				ELSE
				
					LET sTipoNomMovimiento = 'OB';
					
					SELECT a.importe,a.user_insert,ref_servicio
					INTO cMonto,cUsuarioInsert,refServicio
					FROM bdidomi:dom_cce_detalle a
					INNER JOIN bdidomi:dom_status_pago b ON a.cve_estatus = b.cve_status
					WHERE a.cve_estatus = '01' --Clave de Aplicado
					AND a.folio_suc = TRIM(cFolioSuc)
					AND a.rfc_ord = TRIM(sRfcServicio)
					AND (a.num_cta_rec IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) AND numcte = TRIM(cNumCliente))
					OR a.num_cta_rec =  TRIM(cCuentaClabe))
					AND a.cod_operacion = "30"
					AND a.nombre_arch LIKE "%S%";
					
					IF NOT refServicio IS NULL OR NOT refServicio = "" THEN
					
						IF cTipoDomiciliacion = '1' THEN
							LET sTipoNomDomi = 'Domiciliacion por tarjeta'; ---Cancelacion de domiciliaciones por tarjeta
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							
							UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02' WHERE cuenta = cNumeroCuenta AND num_cte = cNumCliente; --Inhabilita la cuenta para poder hacer domiciliaciones
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						ELIF (cTipoDomiciliacion = '2') THEN
							LET sTipoNomDomi = 'Domiciliacion en especifico'; --Cancelacion de domiciliaciones en especifico
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						END IF;		
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					ELSE 
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					END IF;	
				END IF;
			END FOREACH;
			LET sCodigoRetorno = '00001';
			LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
			RETURN sCodigoRetorno,sCodigoDescripcion;
		ELSE
			LET sCodigoRetorno = '00005';
			LET sCodigoDescripcion = 'Cliente Inexistente.';
			RETURN sCodigoRetorno,sCodigoDescripcion;
		END IF;

END
END PROCEDURE;