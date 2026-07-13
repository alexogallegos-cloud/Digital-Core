CREATE PROCEDURE "informix".sp_aforevalidacargaarchivo(pNombreArchivo CHAR(30),pUser_Insert CHAR(8),pTipoarchivo CHAR(1))
	RETURNING CHAR(5),CHAR(200);
-------------------------------------------------------------------------------------------------
----------------------Variables Generales-------------------
DEFINE cTipoRegistro CHAR(1);
DEFINE cFinLinea CHAR(2);
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
Define cRenglon CHAR(276);
DEFINE dFecha_Hoy DATE;
DEFINE iCont Integer;
Define cSQL CHAR(150);
DEFINE cProceso CHAR(10);
DEFINE dFechProceso DATE;
DEFINE cMensaje CHAR(200);
DEFINE mPasoMoney MONEY(19,2);

Define mSumaImporteNetoPagar MONEY (15,2);
Define iSumaAntesImpuesto INTEGER;
Define iSumaImporteRetenido INTEGER;
Define mSumaEfectivo MONEY (17,2);
Define mSumaDeposito MONEY(17,2);
DEFINE cNombreTipoArch CHAR(11);      --DSB 11/03/2014
DEFINE mImporteNetoPagar MONEY(17,2); --DSB 11/03/2014
DEFINE mSaldoCtaCargo MONEY(17,2);    --DSB 11/03/2014
DEFINE cNumCuentaAfore CHAR(20);      --DSB 11/03/2014
----------------------Variables Encabezado-----------------

DEFINE cNoContratoEmpresa INTEGER;
DEFINE cFechaGeneracionInformacion 	DATE;
DEFINE cFechaInicialInformacion DATE;
DEFINE cFechaFinalInformacion DATE;
DEFINE cNoMovimientosContenidos INTEGER;
DEFINE cFillerEncabezado CHAR(232);

----------------------Variables Detalles-------------------------
DEFINE cNSS CHAR(11);
DEFINE cNombreBeneficiario CHAR(40); 
DEFINE cApellidoPaternoBeneficiario CHAR(40);
DEFINE cApellidoMaternoBeneficiario CHAR(40);
DEFINE cFormasPago CHAR(1);
DEFINE cCLABE CHAR(18);
DEFINE cFechaCaptura DATE;
DEFINE mImporteDocumentoNetoPagar MONEY(15,2);
DEFINE mImporteDocumentoAntesImpuesto MONEY(15,2);
DEFINE mImpuestoRetenido MONEY(11,2);
DEFINE cNumeroFolioServicio CHAR(8);
DEFINE cNumeroTienda CHAR(4);
DEFINE cTipoRetiro CHAR(3);
DEFINE cConsecutivoRetiro CHAR(10);
DEFINE cRFC CHAR(10);
DEFINE cFillerDetalle CHAR(3);
DEFINE iConsecutivo INTEGER;
DEFINE cCurp CHAR(18);
DEFINE cStatus CHAR(2);
DEFINE cFolio_suc CHAR(16);
DEFINE cRuta CHAR(20);
DEFINE cCLABEVAL CHAR(18);


----------------------Variables Sumario-------------------------
DEFINE cNumeroTotalMovimientosContenidos CHAR(9);
DEFINE mImporteTotalNeto MONEY (17,2);
DEFINE mImporteTotalAntesImpuesto MONEY(17,2);
DEFINE mImporteRetenido MONEY(17,2);
DEFINE mImporteTotalRetirosPagadosEfectivo MONEY(17,2);
DEFINE mImporteTotalRetirosPagadosDeposito MONEY(17,2);
DEFINE cFillerSumario CHAR(179);
DEFINE dHora  datetime HOUR TO SECond;
DEFINE iContEncabezado INTEGER;
DEFINE iContDetalle INTEGER;
DEFINE iContSumario INTEGER;
DEFINE c  CHAR(50);
DEFINE cCodRetInterno CHAR(5);


LET cCodRetInterno = '00000';
LET c = '';
LET cMensaje = 'Aplicado exitosamente';
LET iContEncabezado = 0;
LET iContDetalle = 0;
LET iContSumario = 0;

LET dhora = CURRENT HOUR TO SECOND;
LET cSQL 		= '';
LET dFecha_Hoy 	= '';
LET cCodRet 	= "00000";
LET iCont 		= "0";
LET cRenglon	= '';
LET iConsecutivo	= 1; 
Let cStatus = '1';
LET cProceso = '';        --DSB 11/03/2014 
LET cNombreTipoArch = ''; --DSB 11/03/2014
LET mImporteNetoPagar = 0.00; --DSB 11/03/2014
LET mSaldoCtaCargo = 0.00;    --DSB 11/03/2014
LET cNumCuentaAfore = '';     --DSB 11/03/2014
LET mPasoMoney = 0.00;
LET mSumaImporteNetoPagar = 0.00;
LET iSumaAntesImpuesto = 0;
LET iSumaImporteRetenido = 0;
LET mSumaEfectivo = 0.00;
LET mSumaDeposito = 0.00;

Let dHora =  CURRENT hour to fraction;
LET cTipoRegistro 						= '';
LET cNoContratoEmpresa 					= '';
LET cFechaGeneracionInformacion			= '';
LET cFechaInicialInformacion 			= '';
LET cFechaFinalInformacion 				= '';
LET cNoMovimientosContenidos 			= '';
LET cFillerEncabezado 					= '';
LET cFinLinea 							= '';
LET cNSS 								= '';
LET cNombreBeneficiario					= '';
LET cApellidoPaternoBeneficiario 		= '';
LET cApellidoMaternoBeneficiario		= '';
LET cFormasPago 						= '';
LET cCLABE								= '';
LET cFechaCaptura						= '';
LET mImporteDocumentoNetoPagar 			= 0.00;
LET mImporteDocumentoAntesImpuesto		= 0.00;
LET mImpuestoRetenido					= '';
LET cNumeroFolioServicio				= '';
LET cNumeroTienda						= '';
LET cTipoRetiro							= '';
LET cConsecutivoRetiro					= '';
LET cRFC								= '';
LET cFillerDetalle						= '';
LET cNumeroTotalMovimientosContenidos	= '';
LET mImporteTotalNeto					= 0.00;
LET mImporteTotalAntesImpuesto			= 0.00;
LET mImporteRetenido					= 0.00;
LET mImporteTotalRetirosPagadosEfectivo = 0.00;
LET mImporteTotalRetirosPagadosDeposito	= 0.00;
LET cFillerSumario						= '';
LET cRuta 								= '';
LET cCLABEVAL							= '';


  --SET DEBUG FILE TO "/tmp/sp_AforeValidaCargaArchivo.out";
  --TRACE ON;

  

BEGIN   
		/*
			LET cCodRet =('10000','El nombre del archivo pasado por parametro esta mal');
			LET cCodRet =('10001','Error en una Fecha dentro del archivo');
			LET cCodRet =('10002','Error los registros traen valores nulos en campos obligatorios');
			LET cCodRet =('10003','Las fecha del encabezado no corresponden al dÃÂÃÂ­a.');
			LET CcodRet =('10004','Campos obligatorios no cuentan con su longitud correspondiente');
			LET CcodRet =('10005','La fecha de un registro del detalle no corresponden al dÃÂÃÂ­a.');
			LET cCodRet =('10006','No corresponden el nÃÂÃÂºmero de movimientos que aparece en el encabezado y en el sumario del archivo, contra los registros de detalle');
			LET cCodRet =('10007','No cuadran los totales con la suma de los registros del detalle');
			LET cCodRet =('10008','Error Un valor No Es  Numerico ');
			LET cCodRet =('10009','Error no contiene 1 encabezado, n detalles y 1 sumario');
			LET cCodRet =('10010','No encontro el archivo especificado');
			LET cCodRet =('10011','El Archivo ya fue procesado');
			LET cCodRet =('10012','Error en el archivo');
			LET cCodRet =('10029','Error La forma de pago es distinta de 3=DepÃÂÃÂ³sitio en Cuenta');
			LET cCodRet =('10030','Error El Estatus es distinto de 01');
			LET cCodRet =('10031','Error el archivo contiene montos negativos');
			LET cCodRet =('10034','Los valores en al archivo exceden los valores permitidos en la arquitectura del sistema');
			LET cCodRet =('10035','ParÃÂÃÂ¡metro tipo archivo no es valido');
			LET cCodRet =('10036','La forma de pago es distinta de 5 = Deposito en Cuenta');
		*/
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-------Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				--LET cMensaje = 'Error no controlado';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			    VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			END IF;
		END EXCEPTION;
		on exception in (-668)
		
			IF EXISTS (SELECT columna FROM bdiprog:pp_archtemp WHERE SUBSTR(columna,1,1) = 'E' AND SUBSTR(columna,10,8) = dFecha_Hoy ) THEN
				Let cCodRet = '10012';							
			ELSE					
				Let cCodRet = '10010';	
			END IF;
			
			LET cSQL = 'rm -f ' || TRIM(cRuta) || 'query.sql';
			SYSTEM cSQL;		
			
			--LET cMensaje = 'No encontro el archivo especificado';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
	    END exception with resume;	
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
		--se obtiene la hora
		LET dhora = CURRENT;
		------------- Se  obtiene la fecha del sistema
		SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;
		
		IF pTipoarchivo = 1 THEN   --DSB 11/03/2014 
			LET cProceso = 'AforeVal';
			LET cNombreTipoArch = '.ACOPPEL.';
		ELIF pTipoarchivo = 2 THEN
			LET cProceso = 'AfoValOB';
			LET cNombreTipoArch = '.OBACOPPEL.';
		ELIF NVL(pTipoarchivo,'') = '' OR pTipoarchivo NOT IN (1,2) THEN
			LET cCodRet = '10035';
			CALL "informix".sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;
		
		---se valida si se recivio el parametro pUser_Insert
		IF TRIM(pUser_Insert) = '' THEN
			LET pUser_Insert = 'informix';
		END IF;
		IF TRIM(pNombreArchivo) = ''  Or (pNombreArchivo is null) THEN -- nombre si trae algo hay q validar   
			---------Se crea el nombre del archivo con el consecutivo 01------------------
			LET pNombreArchivo = 'PAGOS' || lpad(Day(dFecha_Hoy),2,'0') || 	LPAD(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy)  || TRIM(cNombreTipoArch) || '01'; --DSB 11/03/2014 
			LET cProceso = TRIM(cProceso) || '01'; --DSB 11/03/2014 
		---------- validar el nombre del archivo recibido
		ELSE  -- Valida que el nombre enviado sea correcto
			
			IF pTipoarchivo = 1 THEN  --DSB 11/03/2014
				IF SUBSTR(TRIM(pNombreArchivo),1,22) != ('PAGOS'|| lpad(Day(dFecha_Hoy),2,'0') || 		LPAD(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy) || TRIM(cNombreTipoArch)) THEN --DSB 11/03/2014 
					LET cCodRet = "10000";
				END IF;
			ELIF pTipoarchivo = 2 THEN
				IF SUBSTR(TRIM(pNombreArchivo),1,24) != ('PAGOS'|| lpad(Day(dFecha_Hoy),2,'0') || 		LPAD(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy) || TRIM(cNombreTipoArch)) THEN --DSB 11/03/2014 
					LET cCodRet = "10000";
				END IF;
			END IF;
			IF cCodRet = "10000" THEN
				--LET cMensaje = 'El nombre del archivo pasado por parametro esta mal';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			END IF;
			
			--Asigno el IDentificador del proceso
			IF pTipoarchivo = 1 THEN
				LET cProceso = TRIM(cProceso) || SUBSTR(pNombreArchivo,23,2); --DSB 11/03/2014 
			ELIF pTipoarchivo = 2 THEN
				LET cProceso = TRIM(cProceso) || SUBSTR(pNombreArchivo,25,2); --DSB 11/03/2014 
			END IF;
			
		END IF;
		-- Almacenar el proceso
		IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso and pp_Procesos.fech_proceso = dFecha_Hoy) THEN
			SELECT status INTO cStatus FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso and pp_Procesos.fech_proceso = dFecha_Hoy;
			IF cStatus = '1' THEN  --EL proceso termino de manera incorrecta
				--se deberÃÂÃÂ¡n borrar los movimientos registrados en  las tablas , para el archivo a procesar, e iniciar el proceso nuevamente (registrÃÂÃÂ¡ndo el inicio en la tabla de procesos).
					Delete From pp_Encabezado WHERE pp_Encabezado.nombre_arch = pNombreArchivo;
					Delete From pp_Sumario WHERE pp_Sumario.nombre_arch = pNombreArchivo;
					Delete From pp_Detalle WHERE pp_Detalle.nombre_arch = pNombreArchivo;
					Delete From pp_arch_afore WHERE pp_arch_afore.nombre_arch = pNombreArchivo;
			ELSE---el estatus es  02
				LET cCodRet = '10011';
				--LET cMensaje = 'El Archivo ya fue procesado';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			END IF;
		ELSE
			--- guardar el inicion del proceso y se ejecuta
			INSERT INTO bdiprog:pp_Procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
			VALUES (cProceso,dFecha_hoy,cStatus,pUser_Insert,dFecha_Hoy);
		END IF;

		-- Limpiar Tablas Temporales antes de Empezar
		DELETE FROM pp_EncabezadoTemp;
		DELETE FROM pp_DetalleTemp;
		DELETE FROM pp_SumarioTemp;
		-- Limpiar tabla de contenido de archivo antes de cargar el archivo
		DELETE FROM pp_archtemp;
		--o	Se leerÃÂÃÂ¡ de la tabla de parÃÂÃÂ¡metros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, nÃÂÃÂºmero de contrato, etc.).
		select valor into cRuta from  bdiprog:pp_Parametros where cve_param = '100';
		
		---------Se carga archivo ( LOAD)---------
		Let cSQL = '';
		Let  cSQL = 'echo "load from '||TRIM(cRuta) || TRIM(pNombreArchivo) ||
					' insert into pp_archtemp(columna); " > '||TRIM(cRuta) ||'query.sql';
		System cSQL;
		Let cSQL = '';
		--Let cSQL = 'dbaccess bdiprog '||TRIM(cRuta) ||'query.sql';  --Se activa para desarrollo   
		Let cSQL = '/ifxsif01/bin/dbaccess bdiprog '||TRIM(cRuta) ||'query.sql ';  --Se activa para Produccion		
		System cSQL;		
		
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'query.sql';
		SYSTEM cSQL;
		----------------------------------------------
		LET iCont = 0;
		FOREACH
			SELECT columna INTO cRenglon FROM bdiprog:pp_archtemp order by(num_serial)
			LET iCont = iCont + 1;
			LET c = SUBSTR(cRenglon,1,1);
			IF SUBSTR(cRenglon,1,1) = 'E' THEN -- si este registro pertenece al Enzabezado, Se obtienen todos los datos del encabezado
				IF isnumeric(SUBSTR(cRenglon,2,8)) <> '0' AND isnumeric(SUBSTR(cRenglon,34,9)) <> '0' AND isnumeric( SUBSTR(cRenglon,12,2)) <> '0'
				   AND isnumeric(SUBSTR(cRenglon,10,2)) <> '0' AND isnumeric(SUBSTR(cRenglon,14,4)) <> '0' AND isnumeric(SUBSTR(cRenglon,20,2)) <> '0'
				   AND isnumeric(SUBSTR(cRenglon,18,2)) <> '0' AND isnumeric(SUBSTR(cRenglon,22,4)) <> '0' AND isnumeric(SUBSTR(cRenglon,28,2)) <> '0'
				   AND isnumeric(SUBSTR(cRenglon,26,2)) <> '0' AND isnumeric(SUBSTR(cRenglon,30,4)) <> '0' THEN

					Let cTipoRegistro = 'E';
					Let cNoContratoEmpresa = SUBSTR(cRenglon,2,8);
					------------------Validar Fecha
					IF (SUBSTR(cRenglon,10,2) > 0 AND  SUBSTR(cRenglon,10,2) < 13) AND ( SUBSTR(cRenglon,12,2) > 0 AND SUBSTR(cRenglon,12,2) < 32) 
						AND (SUBSTR(cRenglon,14,4) > 2000 AND SUBSTR(cRenglon,14,4) < 3000 )   THEN
						Let cFechaGeneracionInformacion = SUBSTR(cRenglon,10,2) || '/' || SUBSTR(cRenglon,12,2) || '/' || SUBSTR(cRenglon,14,4);
					ELSE
						LET cCodRet = '10001';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					IF ( SUBSTR(cRenglon,18,2) > 0 AND   SUBSTR(cRenglon,18,2) < 13) AND ( SUBSTR(cRenglon,20,2) > 0 AND SUBSTR(cRenglon,20,2) < 32)
						AND (SUBSTR(cRenglon,22,4) > 2000  AND SUBSTR(cRenglon,22,4) < 3000 )  THEN
						Let cFechaInicialInformacion  =  SUBSTR(cRenglon,18,2) || '/' ||  SUBSTR(cRenglon,20,2) || '/' || SUBSTR(cRenglon,22,4);
					ELSE
						LET cCodRet = '10001';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					IF ( SUBSTR(cRenglon,26,2) > 0 AND   SUBSTR(cRenglon,26,2) < 13) AND ( SUBSTR(cRenglon,28,2) > 0 AND SUBSTR(cRenglon,28,2) < 32)
						AND (SUBSTR(cRenglon,30,4) > 2000 AND SUBSTR(cRenglon,30,4) < 3000 )  THEN
						Let cFechaFinalInformacion 		=  SUBSTR(cRenglon,26,2) || '/' ||  SUBSTR(cRenglon,28,2) || '/' || SUBSTR(cRenglon,30,4);
					ELSE
						LET cCodRet = '10001';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					Let cNoMovimientosContenidos = SUBSTR(cRenglon,34,9);
					Let cFillerEncabezado = SUBSTR(cRenglon,43,232);
					let cFinLinea = SUBSTR(cRenglon,275,2);
					LET iContEncabezado = iContEncabezado + 1;
					INSERT INTO bdiprog:pp_EncabezadoTemp (nombre_arch,tipo_reg, contrato, fecha_gen, fecha_ini, fecha_fin, no_mov, filler,fin_linea,
								user_insert,fecha_insert)
					VALUES (pNombreArchivo,cTipoRegistro,cNoContratoEmpresa,cFechaGeneracionInformacion,cFechaInicialInformacion,cFechaFinalInformacion,
								cNoMovimientosContenidos,cFillerEncabezado,cFinLinea, pUser_Insert,dFecha_Hoy);
				Else
						LET cCodRet = '10008';
						--LET cMensaje = 'Error Un valor No Es  Numerico';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
				END IF;
			Elif SUBSTR(cRenglon,1,1) = 'D'  THEN -- si este registro pertenece al Detalles, Se obtienen todos sus datos       
				IF (isnumeric(SUBSTR(cRenglon,2,11) ) <> '0') AND (isnumeric(SUBSTR(cRenglon,133,1) ) <> '0')  AND (isnumeric(SUBSTR(cRenglon,160,15) ) <> '0' )
				    AND (isnumeric(SUBSTR(cRenglon,175,15)) <> '0') AND (isnumeric(SUBSTR(cRenglon,190,11)) <> '0') AND (isnumeric(SUBSTR(cRenglon,190,11)) <> '0')
					AND (isnumeric(SUBSTR(cRenglon,201,8))  <> '0') AND (isnumeric(SUBSTR(cRenglon,209,4))  <> '0') AND (isnumeric(SUBSTR(cRenglon,216,10)) <> '0')
					AND (isnumeric(SUBSTR(cRenglon,152,2))  <> '0') AND  isnumeric(SUBSTR(cRenglon,154,2))  <> '0'  AND  isnumeric(SUBSTR(cRenglon,156,4))  <> '0' 
					AND  isnumeric(SUBSTR(cRenglon,254,2))  <> '0'  THEN 
					Let cTipoRegistro = 'D';
					Let cNSS = SUBSTR(cRenglon,2,11);
					Let cNombreBeneficiario = SUBSTR(cRenglon,13,40);
					Let cApellidoPaternoBeneficiario = SUBSTR(cRenglon,53,40);
					Let cApellidoMaternoBeneficiario = SUBSTR(cRenglon,93,40);
					Let cFormasPago = SUBSTR(cRenglon,133,1);
					
					
					IF pTipoarchivo = '1' AND cFormasPago <> 3 THEN --DSB 11/03/2014
						LET cCodRet = '10029';
						--LET cMensaje = 'Error La forma de pago es distinta de 3=DepÃÂÃÂ³sito en Cuenta';
						CALL "informix".sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					ELIF pTipoarchivo = '2' AND (cFormasPago <> 4 AND cFormasPago <> 2) THEN
						LET cCodRet = '10036';
						--LET cMensaje = 'Forma de pago es distinta de 4 o 2 Deposito en Cuenta OB';
						CALL "informix".sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO "informix".pp_bitacora 	(proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					
					Let cCLABE = SUBSTR(cRenglon,134,18);
					
					IF pTipoarchivo = '2' THEN
						Let cCLABEVAL = REPLACE(cCLABE, ' ','' );				
					
						IF LENGTH(TRIM(cCLABEVAL)) < 18 THEN 
							LET cCodRet = '10002';
							--LET cMensaje = 'Error los registros traen valores nulos en campos obligatorios';
							CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
							INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
							VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
							RETURN cCodRet,cMensaje;							
						END IF;
					END IF;
					
					IF (SUBSTR(cRenglon,152,2) > 0 AND  SUBSTR(cRenglon,152,2) < 13) AND ( SUBSTR(cRenglon,154,2) > 0 AND 
					    SUBSTR(cRenglon,154,2) < 32)    AND ( SUBSTR(cRenglon,156,4) > 2000 AND SUBSTR(cRenglon,156,4) < 3000 )  THEN
						Let cFechaCaptura  = SUBSTR(cRenglon,152,2) || '/' || SUBSTR(cRenglon,154,2) || '/' || SUBSTR(cRenglon,156,4);
					ELSE
						LET cCodRet = '10001';
						--LET cMensaje = 'Error en una Fecha dentro del archivo';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					--- Los tipo Money se pasan a una variable grande para sacarles los  decimales y des pues a la variable q van para que no se desborden, ademas se valida q no exedan el numero maximo alcanzado para que no se desborde
					LET mPasoMoney = SUBSTR(cRenglon,160,15);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 9999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desbordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteDocumentoNetoPagar = mPasoMoney;
					LET mPasoMoney = 0.00;
					
					Let mPasoMoney = SUBSTR(cRenglon,175,15);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 9999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desbordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					Let mImporteDocumentoAntesImpuesto = mPasoMoney;
					LET mPasoMoney = 0.00;
					
					Let mPasoMoney = SUBSTR(cRenglon,190,11);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desbordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					Let mImpuestoRetenido = mPasoMoney;
					LET mPasoMoney = 0.00;					
					--Validar que los importes no sean numeron negaticos											
					IF mImporteDocumentoNetoPagar < 0 or mImporteDocumentoAntesImpuesto < 0 or mImpuestoRetenido < 0 THEN
						LET cCodRet = '10031';
						--LET cMensaje = 'Error el archivo contiene montos negativos';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					
					Let cNumeroFolioServicio = SUBSTR(cRenglon,201,8);
					Let cNumeroTienda = SUBSTR(cRenglon,209,4);
					Let cTipoRetiro = SUBSTR(cRenglon,213,3);
					Let cConsecutivoRetiro = SUBSTR(cRenglon,216,10);
					Let cCURP = SUBSTR(cRenglon,226,18);
					Let cRFC  =  SUBSTR(cRenglon,244,10);
					Let cStatus = SUBSTR(cRenglon,254,2);
					--validar que el status siempre sea 01
					IF cStatus <> '01' THEN
						LET cCodRet = '10030';
						--LET cMensaje = 'Error El Estatus es distinto de 01';							
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					Let cFillerDetalle = SUBSTR(cRenglon,272,3);
					LET cFolio_suc = SUBSTR(cRenglon,256,16);
					Let cFinLinea = SUBSTR(cRenglon,275,2);
					LET iContDetalle = iContDetalle + 1;

					INSERT INTO bdiprog:pp_DetalleTemp (nombre_arch, consecutivo, tipo_reg, nss, nom_benef, apell_pat, apell_mat, forma_pago, clabe,
								fecha_captura, imp_netopagar, imp_antimpuesto, imp_retenido, num_folioservicio, num_tienda, tipo_retiro, consecutivo_ret,
								curp, rfc, status, folio_suc, filler, fin_linea, fecha_ejec, hora_ejec, comision, iva_comision, user_insert, fecha_insert)
					VALUES (pNombreArchivo, iConsecutivo, cTipoRegistro, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario,
								cFormasPago,cCLABE,cFechaCaptura,mImporteDocumentoNetoPagar,mImporteDocumentoAntesImpuesto,mImpuestoRetenido,cNumeroFolioServicio,
								cNumeroTienda,cTipoRetiro,cConsecutivoRetiro,cCURP,cRFC,cStatus,cFolio_suc,cFillerDetalle,cFinLinea, '','', '0.00', '0.00'
								,pUser_Insert,dFecha_Hoy);

					LET iConsecutivo = iConsecutivo + 1; 

					LET mSumaImporteNetoPagar 	= mSumaImporteNetoPagar + mImporteDocumentoNetoPagar;
					IF pTipoarchivo = '1' AND (cFormasPago = 1 or cFormasPago = 2) THEN
						LET mSumaEfectivo 	= mSumaEfectivo + mImporteDocumentoNetoPagar;
					ELSE
						LET mSumaDeposito 	= mSumaDeposito + mImporteDocumentoNetoPagar;
					END IF
				Else
						LET cCodRet = '10008';
						--LET cMensaje = 'Error Un valor No Es  Numerico';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
				END IF;
			Elif SUBSTR(cRenglon,1,1) = 'S' THEN -- si este registro pertenece al Sumario, Se obtienen todos sus datos
				IF isnumeric(SUBSTR(cRenglon,2,9)) <> '0' AND isnumeric(SUBSTR(cRenglon,11,17)) <> '0' AND isnumeric(SUBSTR(cRenglon,28,17)  ) <> '0'  
				    AND isnumeric(SUBSTR(cRenglon,45,17)) <> '0' AND isnumeric(SUBSTR(cRenglon,62,17)) <> '0' AND isnumeric(SUBSTR(cRenglon,79,17)) <> '0'THEN
					Let cTipoRegistro = 'S';
					Let cNumeroTotalMovimientosContenidos 	= SUBSTR(cRenglon,2,9);
					
					--- Los tipo Money se pasan a una variable grande para sacarles los  decimales y des pues a la variable q van para que no se desborden, ademas se valida q no exedan el numero maximo alcanzado para que no se desborde
					LET mPasoMoney = SUBSTR(cRenglon,11,17);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desbordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteTotalNeto = mPasoMoney;
					LET mPasoMoney = 0.00;
					
					LET mPasoMoney = SUBSTR(cRenglon,28,17);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desvordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteTotalAntesImpuesto = mPasoMoney;
					LET mPasoMoney = 0.00;
										
					LET mPasoMoney = SUBSTR(cRenglon,45,17);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desvordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteRetenido = mPasoMoney;
					LET mPasoMoney = 0.00;
					
					LET mPasoMoney = SUBSTR(cRenglon,62,17);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desvordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteTotalRetirosPagadosEfectivo = mPasoMoney;
					LET mPasoMoney = 0.00;
										
					LET mPasoMoney = SUBSTR(cRenglon,79,17);
					LET mPasoMoney = mPasoMoney / 100;
					IF mPasoMoney > 999999999999999.99 THEN
						LET cCodRet = '10034';
						--LET cMensaje = 'Desvordamiento de variable Money';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF
					LET mImporteTotalRetirosPagadosDeposito = mPasoMoney;
					LET mPasoMoney = 0.00;
					
					--Validar que los importes no sean numeron negaticos
					IF mImporteTotalNeto < 0 or mImporteTotalAntesImpuesto < 0 or mImporteRetenido < 0 or mImporteTotalRetirosPagadosEfectivo < 0 or
           				mImporteTotalRetirosPagadosDeposito < 0 THEN
						LET cCodRet = '10031';
						--LET cMensaje = 'Error el archivo contiene montos negativos';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
					END IF;
					Let cFillerSumario = SUBSTR(cRenglon,96,179);
					Let cFinLinea = SUBSTR(cRenglon,275,2);
					LET iContSumario = iContSumario + 1;

					INSERT INTO bdiprog:pp_SumarioTemp (nombre_arch ,tipo_reg ,total_mov ,total_imp_neto ,total_imp_antimp ,total_imp_retenido,
					            imp_tot_efectivo ,imp_tot_deposito,filler,fin_linea,user_insert,fecha_insert)
					VALUES (pNombreArchivo,cTipoRegistro,cNumeroTotalMovimientosContenidos,mImporteTotalNeto,mImporteTotalAntesImpuesto,
					            mImporteRetenido,mImporteTotalRetirosPagadosEfectivo,mImporteTotalRetirosPagadosDeposito,cFillerSumario,
								cFinLinea,pUser_Insert,dFecha_Hoy);
				Else
						LET cCodRet = '10008';
						--LET cMensaje = 'Error Un valor No Es  Numerico';
						CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
						INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
						RETURN cCodRet,cMensaje;
				END IF;
			Else
				LET cCodRet = '10012';
				--LET cMensaje = 'Error en el archivo';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			End IF;
		END FOREACH;
		--verificar que por lo menos el archivo contenga 1 encabezado, n detalles y 1 sumario
		IF iContSumario != 1 or  iContDetalle = 0 or iContEncabezado != 1 THEN
			LET cCodRet = '10009';
			--LET cMensaje = 'Error no contiene 1 encabezado, n detalles y 1 sumario';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;

		------Obtener los datos de las tablas temporales para validar--- e insertarlos en las maestras
		SELECT
			nombre_arch,tipo_reg,contrato,fecha_gen, fecha_ini, fecha_fin, no_mov, filler,fin_linea
		INTO
			pNombreArchivo, cTipoRegistro,cNoContratoEmpresa, cFechaGeneracionInformacion, cFechaInicialInformacion, cFechaFinalInformacion,
			cNoMovimientosContenidos, cFillerEncabezado, cFinLinea
		FROM bdiprog:pp_EncabezadoTemp
		WHERE bdiprog:pp_EncabezadoTemp.nombre_arch = pNombreArchivo;
		----- VALIDACIONES
		IF cTipoRegistro <> 'E' OR ( cNoContratoEmpresa IS null)  OR cNoContratoEmpresa = 0 OR ( cNoMovimientosContenidos IS null) OR 
		   cNoMovimientosContenidos = 0  THEN
			LET cCodRet = '10002';
			--LET cMensaje = 'Error los registros traen valores nulos en campos obligatorios';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;
		--o	Las fechas de los registros de encabezado y detalle deben corresponder a la fecha del dÃÂÃÂ­a.
		IF cFechaGeneracionInformacion <> dFecha_Hoy THEN
			let cFechaGeneracionInformacion = dFecha_Hoy;
			let cCodRet = '10003';
			--LET cMensaje = 'Las fecha del encabezado no corresponden al dÃÂÃÂ­a.';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;

		-- al macenar en pp_arch_afore (status .01., y tipo de archivo .P.),
		INSERT INTO bdiprog:pp_arch_afore (nombre_arch   ,tipo,fecha_generado,fecha_procesado,status,user_insert,fecha_insert)
		VALUES (pNombreArchivo ,'P' ,cFechaGeneracionInformacion  ,''   ,'01'  ,pUser_Insert,dFecha_Hoy);

		--Insertar en Tabla  maestra pp_encabezado
		INSERT INTO bdiprog:pp_Encabezado (nombre_arch,tipo_reg, contrato, fecha_gen, fecha_ini, fecha_fin,
											no_mov, filler,fin_linea, user_insert,fecha_insert)
		VALUES (pNombreArchivo,cTipoRegistro,cNoContratoEmpresa,cFechaGeneracionInformacion,cFechaInicialInformacion,
		        cFechaFinalInformacion,cNoMovimientosContenidos,cFillerEncabezado,cFinLinea, pUser_Insert,dFecha_Hoy);

		---seleccion de la tabla detalle
		FOREACH
			SELECT
				nombre_arch,consecutivo,tipo_reg,nss,nom_benef,apell_pat,apell_mat,forma_pago,clabe,
				fecha_captura,imp_netopagar,imp_antimpuesto,imp_retenido,num_folioservicio,num_tienda,
				tipo_retiro,consecutivo_ret,curp,rfc,status,folio_suc,filler,fin_linea
			INTO
				pNombreArchivo,iConsecutivo,cTipoRegistro,cNSS,cNombreBeneficiario,cApellidoPaternoBeneficiario,
				cApellidoMaternoBeneficiario ,cFormasPago,cCLABE,cFechaCaptura,mImporteDocumentoNetoPagar,
				mImporteDocumentoAntesImpuesto,mImpuestoRetenido,cNumeroFolioServicio,cNumeroTienda,cTipoRetiro,
				cConsecutivoRetiro ,cCURP,cRFC,cStatus,cFolio_suc,cFillerDetalle,cFinLinea
			FROM bdiprog:pp_DetalleTemp
			WHERE bdiprog:pp_DetalleTemp.nombre_arch = pNombreArchivo
			-- VALIDACIONES
			IF cTipoRegistro <> 'D' OR (cFormasPago IS null) OR cFormasPago = 0 OR (cCLABE IS null) OR TRIM(cCLABE) = '' OR (cFechaCaptura IS null)OR
			   cFechaCaptura = '' OR (mImporteDocumentoNetoPagar IS null)OR mImporteDocumentoNetoPagar = 0 OR (cRFC IS null) OR TRIM(cRFC) = '' THEN
				LET cCodRet = '10002';
				--LET cMensaje = 'Error los registros traen valores nulos en campos obligatorios';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			END IF;
-- Se quita validaciÃÂÃÂ³n por solicitud de Afore Coppel. JGP
--			IF  cFechaCaptura <> dFecha_Hoy THEN
--				let CcodRet = '10005';
--				--LET cMensaje = 'La fecha de un registro del detalle no corresponden al dÃÂÃÂ­a.';
--				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
--				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
--				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
--				RETURN cCodRet,cMensaje;
--			END IF;
			--validar la longitud de los campos obligatorios
			IF LENGTH(TRIM(cRFC)) < 10 OR  LENGTH(TRIM(cCLABE)) < 18 THEN
				let CcodRet = '10004';
				--LET cMensaje = 'Campos obligatorios no cuentan con su longitud correspondiente';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet,cMensaje;
			END IF
			INSERT INTO bdiprog:pp_Detalle (nombre_arch,consecutivo,tipo_reg,nss,nom_benef,apell_pat,apell_mat,forma_pago,clabe ,fecha_captura,
						imp_netopagar,imp_antimpuesto,imp_retenido,num_folioservicio,num_tienda,tipo_retiro,consecutivo_ret,curp,rfc,status,
						folio_suc,filler,fin_linea,fecha_ejec,hora_ejec,comision,iva_comision,user_insert,fecha_insert)
			VALUES (pNombreArchivo,iConsecutivo,cTipoRegistro,cNSS,cNombreBeneficiario,cApellidoPaternoBeneficiario,cApellidoMaternoBeneficiario,
						cFormasPago,cCLABE,cFechaCaptura,mImporteDocumentoNetoPagar,mImporteDocumentoAntesImpuesto,mImpuestoRetenido,
						cNumeroFolioServicio,cNumeroTienda,cTipoRetiro,cConsecutivoRetiro,cCURP,cRFC,cStatus,cFolio_suc,cFillerDetalle,cFinLinea
						, '','', '0.00', '0.00',pUser_Insert ,dFecha_Hoy);
		END FOREACH;

		---seleccion de la tabla Sumariotemp
		SELECT
			total_mov,tipo_reg,total_imp_neto,total_imp_antimp,total_imp_retenido,imp_tot_efectivo,imp_tot_deposito,filler,fin_linea
		INTO
			cNumeroTotalMovimientosContenidos,cTipoRegistro,mImporteTotalNeto,mImporteTotalAntesImpuesto,mImporteRetenido,
			mImporteTotalRetirosPagadosEfectivo,mImporteTotalRetirosPagadosDeposito,cFillerSumario, cFinLinea
		FROM bdiprog:pp_SumarioTemp
		WHERE bdiprog:pp_SumarioTemp.nombre_arch = pNombreArchivo;
		-- VALIDACIONES
		IF cTipoRegistro <> 'S' OR (cNumeroTotalMovimientosContenidos IS NULL) OR cNumeroTotalMovimientosContenidos = 0  OR (mImporteTotalNeto IS NULL)
		   OR mImporteTotalNeto = 0  OR (mImporteTotalRetirosPagadosDeposito IS NULL) OR mImporteTotalRetirosPagadosDeposito = 0 THEN
			LET cCodRet = '10002';
			--LET cMensaje = 'Error los registros traen valores nulos en campos obligatorios';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;
		---validar el nÃÂÃÂºmero de movimientos que aparece en el encabezado y en el sumario del archivo, contra los registros de detalle
		IF ( cNoMovimientosContenidos <> cNumeroTotalMovimientosContenidos) OR (cNoMovimientosContenidos <> iCont - 2 ) THEN --and
			LET cCodRet = '10006';
			--LET cMensaje = 'No corresponden el numero de movimientos que aparece en el encabezado y en el sumario del archivo, contra los registros de detalle';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;
		-- validar , la suma de importes de los registros de detalle, contra los totales del registro de sumario.('$'||mSumaImporteNetoPagar||'.00')
		IF (mImporteTotalNeto <> mSumaImporteNetoPagar) OR  (mImporteTotalRetirosPagadosEfectivo <> mSumaEfectivo )  OR 
		   (mImporteTotalRetirosPagadosDeposito <> mSumaDeposito ) THEN 
			LET cCodRet = '10007';
			--LET cMensaje = 'No cuadran los totales con la suma de los registros del detalle';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet,cMensaje;
		END IF;

		 --Insertar los datos en la Tabla maestra pp_Sumario
		INSERT INTO bdiprog:pp_Sumario (nombre_arch,tipo_reg,total_mov,total_imp_neto,total_imp_antimp,total_imp_retenido,imp_tot_efectivo,
		            imp_tot_deposito,filler,fin_linea,user_insert,fecha_insert)
		VALUES (pNombreArchivo,cTipoRegistro,cNumeroTotalMovimientosContenidos,mImporteTotalNeto,mImporteTotalAntesImpuesto,mImporteRetenido,
		        mImporteTotalRetirosPagadosEfectivo,mImporteTotalRetirosPagadosDeposito,cFillerSumario,cFinLinea,pUser_Insert,dFecha_Hoy);

-- Primero se debe insertar este registro. JGP.
		-- al macenar en pp_arch_afore (status .01., y tipo de archivo .P.),
--		INSERT INTO bdiprog:pp_arch_afore (nombre_arch   ,tipo,fecha_generado,fecha_procesado,status,user_insert,fecha_insert)
--		VALUES (pNombreArchivo ,'P' ,cFechaGeneracionInformacion  ,''   ,'01'  ,pUser_Insert,dFecha_Hoy);

		--Registrar el final del proceso en la tabla pp_proceso
		UPDATE bdiprog:pp_Procesos SET status = '2'
		WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy;		
		
		-- Limpiar Tablas Temporales antes de salir
		DELETE FROM pp_EncabezadoTemp;
		DELETE FROM pp_DetalleTemp;
		DELETE FROM pp_SumarioTemp;
		
		IF cCodRet <> 0 THEN
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRet,cMensaje;
		END IF 
		
		RETURN cCodRet,cMensaje;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se recibe un archivo enviado por afore coppel y se obtiene toda la informacion contenida en el archivo',
'Se valida la informacion contenida en el archivo, y se almacena en la base de datos ',
'Solicito : Armando Mercado',
'AUTOR: CÃÂÃÂ©sar ValdÃÂÃÂ©z Figueroa ',
'FECHA: 12 de Mayo 2009',
'BD: BDIPROG',
'CAMBIOS: Se modifico para que al entrar al proceaso se eliminen las tablas temporales esto por si el SP termina mal en una',
'         ejecucion y si lo vuelven a ejecutar no duplique datos en las tablas temporales, Tambien se modifico para que ',
'         guarde los errores no controlados en bitadora, se valido que no reciba importes negativos, que en el archivo ',
'         que recive no se encuentre algun movimientos con estado distinto a 01, se agrego un mensaje de retorno para el sp ',
'         que no permita valores nulos en variables obligatorias, ',
'MODIFICO: CÃÂÃÂ©sar ValdÃÂÃÂ©z Figueroa',
'FECHA: 10/Junio/2009',
'VERSION: 20090610',
'CAMBIOS: Se agrego un contador para el consecutivo en la pp_detalle',
'MODIFICO: Abigail Vasavilbazo CaÃÂÃÂ±edo',
'FECHA: 15/Julio/2009',
'VERSION: 20090715',
'AUTOR      : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para archivo otros bancos y parametro pTipoarchivo',
'FECHA      : 11 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo HernÃÂÃÂ¡ndez Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_obtenerdatos_mismobanco_transfer(pEmpresa char(3), pCuenta char(16))
 returning char (5), char (42), char (104);


 --Creado: Javier Chavez
 --Solicitó: Mauricio León
 --Fecha:12/05/09.
 --Actividad: Retorna el nombre del cliente, el número del producto y su descripción
 --------------------------------------------------------------------------------------------------------
 --Modificó: Mauricio León
 --Fecha: 22/06/2009
 --Actividad: Se agrega búsqueda por índice empresa-producto
 ---------------------------------------------------------------------------------------------------------
 --Modificó: Mauricio León
 --Fecha: 13/09/2011
 --Actividad: Se agrega campo razon social para personas morales
 ---------------------------------------------------------------------------------------------------------
 --Modificó: Héctor Moreno
 --Fecha: 24/11/2016
 --Actividad: Se modifica para que consulte la cuenta transfer en la tabla tf_maecte

 DEFINE Cod_ret char (5);
 DEFINE sql_err Integer;
 DEFINE vNombre1 char (26);
 DEFINE vNombre2 char (26);
 DEFINE vApell_pat char (26);
 DEFINE vApell_mat char (26);
 DEFINE vProd char (4);
 DEFINE vProdNom char (40);
 DEFINE vNomCompleto char (104);
 DEFINE vProducto char (42);
 DEFINE vRazonSocial char (60);

 LET Cod_ret = "";
 LET vNombre1 = "";
 LET vNombre2 = "";
 LET vApell_pat = "";
 LET vApell_mat = "";
 LET vProd = "";
 LET vProdNom = "";
 LET vRazonSocial = "";
 
SET LOCK MODE TO WAIT 10;

 BEGIN
 ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
		LET Cod_ret = sql_err;
		return Cod_ret,vProducto,vNomCompleto;
	END IF;
 END EXCEPTION;
 
   --SET DEBUG FILE TO "/home/sysifx/hector/sp_obtenerdatos_mismobanco_transfer.out";
   --TRACE ON;
	
   IF (pCuenta <> "") THEN
		IF(LENGTH(pCuenta) = 11) THEN
				SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
		INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN  bditransfer:"informix".tf_maecte b ON b.producto = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c ON b.numcte = c.numcte
					WHERE b.empresa = pEmpresa AND b.cuenta_tf = pCuenta;
					
					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		ELIF (LENGTH(pCuenta)=16) THEN
		SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
			INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN bdicheq:"informix".sc_tarjeta b on b.prodtarjeta = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c on b.numcte = c.numcte
					INNER JOIN bditransfer:"informix".tf_maecte d ON c.numcte=d.numcte
					WHERE b.empresa = pEmpresa AND b.num_tarjeta = pCuenta;
					

					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		ELIF (LENGTH(pCuenta)=10) THEN
					SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
						INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN bditransfer:"informix".tf_maecte b ON b.producto = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c ON b.numcte = c.numcte
					INNER JOIN bdicheq:sc_cuenta_telefono ct ON ct.telefono = b.telefono and ct.num_cte = b.numcte
					WHERE b.empresa = pEmpresa AND b.telefono = pCuenta;

					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		END IF;

	ELSE
		LET Cod_ret = "001";	END IF;
	LET vProducto = vProd || " " || vProdNom;
	LET vNomCompleto = TRIM(vNombre1)|| " " ||TRIM(vNombre2) || " " || TRIM(vApell_pat)|| " " ||TRIM(vApell_mat);
    IF TRIM(NVL(vNomCompleto,'')) = '' THEN
        LET vNomCompleto = vRazonSocial;
    END IF;


 return Cod_ret,vProducto,vNomCompleto;

 END;
END PROCEDURE;