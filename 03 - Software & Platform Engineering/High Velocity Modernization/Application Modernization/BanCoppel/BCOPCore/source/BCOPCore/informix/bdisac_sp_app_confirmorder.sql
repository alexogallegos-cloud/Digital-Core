CREATE PROCEDURE "informix".sp_app_confirmorder (pcUsuario CHAR(15),pRegs_recup INTEGER,pFecha_peticion CHAR(8),pHora_peticion CHAR(6))
RETURNING 	CHAR (5) AS codret,
			CHAR(12) AS numremesa,
			CHAR(4) AS codigo,
			CHAR(8) AS fec_proceso,
			CHAR(6) AS hora_proceso

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_confirmorder';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET cChannelId = SUBSTR (pcUsuario,9,3);
		LET pcUsuario  = SUBSTR (pcUsuario,1,7);
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio
				INTO cRemesa,cCodigo,iIntentosenvio
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '01' or estatus_getorder = '07')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '11' WHERE UniqueReferenceNumber = cRemesa 
				and (estatus_getorder = '01' or estatus_getorder = '07')
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN lpad(cCod_err,5,'0'),cRemesa,cCodigo,cFecha_proceso,cHora_proceso;	
		END IF
	END
END PROCEDURE
DOCUMENT
'AUTOR: 95358919 - MARIO GAMALIEL OLIVO URIAS',
'CENTRO: 230142',
'FOLIO: 150',
'RQM: RQM 10 809 ? Pago de Remesas Appriza con abono automático en cuentas de captación.doc',
'FECHA: 04/NOVIEMBRE/2016',
'SOLICITA: EDUARDO PINEDA',
'VERSION: 20161104.1904',
'DESCRIPCION: CONFIRMACION DE REMESAS REGISTRADAS PARA ABONO AUTOMATICO A CUENTAS DE CAPTACION.',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_registrardatosarchivo ( psNumEmpleado CHAR (10))

RETURNING CHAR (8) AS CodRespuesta,  CHAR (120) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Obtener y registrar en el catÃ¡logo las transacciones para conformar el archivo de pagos a E-Global.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 19/03/2010
-- BD: BdiSac
-- SISTEMA : PAGO INTERBANCARIO DE TARJETAS DE CREDITO (PITDC)
--Modificado:  07/04/2010 --Casanova Edeza Hector Juan --Se modifica el formato de la fecha juliana para el encabezado del archivo de formato ADDD por AADDD.
--Modificado:  29/04/2010 --Casanova Edeza Hector Juan --Se modifica el uso de los parametros de las transacciones de PITDC para que se identifiquen los 4 tipos de transacciones identificadas.
--Modificado:  10/05/2010 --Casanova Edeza Hector Juan --Se modifica el manejo de la variable de numero de tarjeta para que en el caso de contener menos de 16 numero agrege 0 a la izq. del numero de la tarjeta.
--Modificado:  12/05/2010 -- Se le agrega la condicion para que cambie a status '2' todos los registros de fechas anteriores que no tengan status de enviados ('0'), para que no puedan cambiar el status a enviado en un dia posterior.
--Modificado:  05/07/2010 --Se modifica el calculo del digito verificador modulo 10 para que en lugar de utilizar el numero de la tarjeta para el calculo utilice el numero de la referencia de la transaccion.
--****************************************************************************************************


DEFINE vsCodRetorno CHAR (8);
DEFINE vsMensajeRet CHAR (120);
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE vdtFechaActual DATE;
DEFINE viStatus INTEGER;
DEFINE vsFechaUltimoArchivo DATE;
DEFINE vsParamNomArch CHAR (10);
DEFINE vsNombreArchivo CHAR (20);
DEFINE vsRutaArchivo CHAR (100);

DEFINE vsCancelado CHAR(1);
DEFINE vsTransacc_Suc CHAR(4);
DEFINE vsFechaJuliana CHAR (5);
DEFINE vdtFechaAux DATE;
DEFINE vsFolioSuccAux CHAR (8);
DEFINE viContador INTEGER;
DEFINE vsBin_Adquiriente CHAR (6);
DEFINE vsFillerE CHAR (177);
DEFINE vsFillerS CHAR (146);
DEFINE viIdBanco INTEGER;


DEFINE vsFlagAlternar CHAR(1);
DEFINE viAcumulado INTEGER;
DEFINE viValorAux INTEGER;
DEFINE viTotalRegistros INTEGER;
DEFINE viTotalPagos INTEGER;
DEFINE viTotalImportePagos INT8;
DEFINE viTotalRechazados INTEGER;
DEFINE viTotalImporteRechazados INTEGER;

DEFINE vsTransacc CHAR(4);
DEFINE vsParam_TranSacc_Efectivo CHAR(4);
DEFINE vsParam_TranSacc_Otro CHAR(4);
DEFINE vsParam_PagoEfectivo CHAR(4);
DEFINE vsParam_PagoCheqMBanco CHAR(4);
DEFINE vsParam_PagoCheqOBanco CHAR(4);
DEFINE vsParam_PagoInternet CHAR(4);


--DATOS ARCHIVO DETALLE
DEFINE vsNombre_Archivo  CHAR(20) ; 
DEFINE vdtFecha_Archivo DATE;
DEFINE vsCod_Txn CHAR(2) ; 
DEFINE vsCalificado_R_Codigo CHAR(1) ; 
DEFINE vsCodigo_Registro CHAR(1) ; 
DEFINE vsNumero_Tarjeta CHAR(16) ; 
DEFINE vsExtension_Tarjeta CHAR(3);
DEFINE vsInd_Limite_Piso CHAR(1);
DEFINE vsInd_Cwb_Crb CHAR(1);
DEFINE vsInd_Servicio CHAR(1) ; 
DEFINE vsNum_Referencia CHAR(23) ; 
DEFINE vsNum_Negocio CHAR(8) ; 
DEFINE vsFecha_Txn CHAR(4) ; 
DEFINE vsImporte_Txn CHAR(12) ; 
DEFINE vsCod_Actual_Destino CHAR(3) ; 
DEFINE vsImporte_Tasa CHAR(12) ; 
DEFINE vsCod_Actual_Origen CHAR(3) ; 
DEFINE vsNombre_Negocio CHAR(25) ; 
DEFINE vsPoblacion_Negocio CHAR(13); 
DEFINE vsCod_Pais CHAR(3) ; 
DEFINE vsCod_Categoria CHAR(4) ; 
DEFINE vsCod_Postal CHAR(5);
DEFINE vsCod_Estado CHAR(3);
DEFINE vsReservado CHAR(1) ; 
DEFINE vsInd_Com_Elec CHAR(1);
DEFINE vsCod_Uso CHAR(1) ; 
DEFINE vsCod_Razon CHAR(2) ; 
DEFINE vsInd_Liquidacion CHAR(1) ; 
DEFINE vsInd_Servicio2 CHAR(1);
DEFINE vsNum_Autorizaciones CHAR(6) ; 
DEFINE vsCap_Term_Pos CHAR(1);
DEFINE vsFiller1 CHAR(1);
DEFINE vsMet_Identificacion CHAR(1);
DEFINE vsBan_Coleccion CHAR(1);
DEFINE vsMod_Pos CHAR(2) ; 
DEFINE vsFecha_Proceso CHAR(4) ; 
DEFINE vsTipo_Captura CHAR(1) ; 

DEFINE vsCategoria_Tasa CHAR(2) ; 
DEFINE vsInd_Medio_Acceso CHAR(2) ; 
DEFINE vsTrack2 CHAR(1);
DEFINE vsInd_Cavv CHAR(1);
DEFINE vsInd_Ucaf CHAR(1); 
DEFINE vsDiferimiento CHAR(2) ; 
DEFINE vsParcializacion CHAR(2) ; 
DEFINE vsTipo_Plan CHAR(2) ; 
DEFINE vsInd_Deposito_Efectivo CHAR(1) ; 
DEFINE vsFiller CHAR(8);
DEFINE vsFolio_Suc CHAR(16) ; 
DEFINE vsConciliado CHAR(1) ; 
DEFINE vsUser_Insert CHAR(10) ; 
DEFINE vdtFecha_Insert DATE;

DEFINE visqlerr INTEGER;
DEFINE vsFolio_SucAUX2 CHAR(16) ; 
DEFINE vsAuxNum CHAR(1) ; 
DEFINE vsParam_Pagotransfer CHAR(4); 
DEFINE vsParam_PagoCheqCorresp CHAR(4);
DEFINE vsParam_PagoEfeccorresp CHAR(4);

DEFINE cDescripcionSPJ	 CHAR(100);

LET vsCodRetorno = '';
LET vsMensajeRet = '';
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

LET vdtFechaActual = CURRENT::DATE;
LET viStatus = 0;
LET vsFechaUltimoArchivo = CURRENT::DATE;
LET vsParamNomArch = '';
LET vsNombreArchivo = '';
LET vsRutaArchivo = '';


LET vsCancelado = '';
LET vsTransacc_Suc = '';
LET vsFechaJuliana = '';
LET vdtFechaAux = CURRENT::DATE;
LET vsFolioSuccAux = '';
LET viContador = 0;
LET vsBin_Adquiriente = '';
LET vsFillerE = '';
LET vsFillerS = '';
LET vsNombre_Archivo = '';
LET vdtFecha_Archivo = CURRENT::DATE;
LET viIdBanco = 0;

LET vsFlagAlternar = '';
LET viAcumulado = 0;
LET viValorAux = 0;
LET viTotalRegistros = 0;
LET viTotalPagos = 0;
LET viTotalImportePagos = 0;
LET viTotalRechazados = 0;
LET viTotalImporteRechazados = 0;

LET vsTransacc = '';
LET vsParam_TranSacc_Efectivo = '';
LET vsParam_TranSacc_Otro = '';
LET vsParam_PagoEfectivo = '';
LET vsParam_PagoCheqMBanco = '';
LET vsParam_PagoInternet = '';
LET vsParam_PagoCheqOBanco = '';



LET vsCod_Txn = '08'; --01
LET vsCalificado_R_Codigo = '0'; --02
LET vsCodigo_Registro = ''; --03 ---PENDIENTE
LET vsNumero_Tarjeta = '';  --04 ---PENDIENTE
LET vsExtension_Tarjeta = '000'; --05
LET vsInd_Limite_Piso = ' '; --06
LET vsInd_Cwb_Crb = ' '; --07
LET vsInd_Servicio = ' '; --08
LET vsNum_Referencia = ''; --09 --MODULO VERIFICADOR
LET vsNum_Negocio = ''; --10 ---SUCURSAL
LET vsFecha_Txn = ''; --11   --FECHA DE REGISTRO SUC
LET vsImporte_Txn = ''; --12 MONTO_TOT
LET vsCod_Actual_Destino = '484'; --13 -- TIPO MONEDA
LET vsImporte_Tasa = '000000000000'; --14
LET vsCod_Actual_Origen = 'MX'; --15
LET vsNombre_Negocio = 'PAGO EN BANCOPPEL'; --16
LET vsPoblacion_Negocio = '             '; --17
LET vsCod_Pais = 'MX'; --18
LET vsCod_Categoria = '6010'; --19 --TIPO GIRO
LET vsCod_Postal = '00000'; --20
LET vsCod_Estado = '   '; --21
LET vsReservado = '1'; --22
LET vsInd_Com_Elec = ' '; --23
LET vsCod_Uso = '1'; --24
LET vsCod_Razon = ''; --25 --TRANSACC_SUC
LET vsInd_Liquidacion = '0'; --26
LET vsInd_Servicio2 = ' '; --27
LET vsNum_Autorizaciones = '000000'; --28
LET vsCap_Term_Pos = ' '; --29
LET vsFiller1 = ' '; --30
LET vsMet_Identificacion = ' '; --31
LET vsBan_Coleccion = ' '; --32
LET vsMod_Pos = '01'; --33
LET vsFecha_Proceso = '0000'; --34
LET vsTipo_Captura = '0'; --35
LET vsCategoria_Tasa = '00'; --36
LET vsInd_Medio_Acceso = '00'; --37
LET vsTrack2 = ' '; --38
LET vsInd_Cavv = ' '; --39
LET vsInd_Ucaf = ' '; --40
LET vsDiferimiento = '00'; --41
LET vsParcializacion = '00'; --42
LET vsTipo_Plan = '00'; --43
LET vsInd_Deposito_Efectivo = ''; --44 ---PENDIENTE
LET vsFiller = '        '; --45

LET vsFolio_Suc = '';
LET vsConciliado = '';
LET vsUser_Insert = '';
LET vdtFecha_Insert = CURRENT::DATE;

LET vsFolio_SucAUX2 = '';
LET vsAuxNum = '';
LET visqlerr = 0;
LET vsParam_Pagotransfer = ''; 
LET vsParam_PagoCheqCorresp = '';
LET vsParam_PagoEfeccorresp = '';

LET cDescripcionSPJ	 = 'Ejecucion de pagos interbancarios';


	--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_registradatosarchivo.out";
	--TRACE ON;


BEGIN
--GEN_APITDC
--FI_GAPITDC
--0123456789

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		LET vsCodRetorno = '00199'; --ERROR DE INFORMIX
		
		--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
		SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
		
		LET vsMensajeRet = TRIM(vsMensajeRet) || ' ERROR (' || visqlerr || ').' ;
		
		--ACTUALIZA EL REGISTRO DE LA TABLA DE PROCESOS Y LO DEJA COMO NO PROCESADO
		UPDATE BdiSac:Sac_Procesos SET Status = 0, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 3;
		
		RETURN vsCodRetorno, vsMensajeRet ;
		
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	
	
	/*
	IF ( psNumEmpleado = '3' )	THEN
		--SET DEBUG FILE TO '/tmp/PITDC/CONFORMAR_ARCH_TIPDC.sql';
		SET DEBUG FILE TO '/home/sysifx/PITDC/CONFORMAR_ARCH_TIPDC.sql';
		
		TRACE ON ;
	END IF ;
	*/
	
	
	--OBTIENE LA FECHA ACTUAL DEL SISTEMA
	SELECT FIRST 1 NVL(Fecha_Hoy, CURRENT::DATE) INTO vdtFechaActual FROM BdiCheq:Sc_Fechas;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_API_TDC', vdtFechaActual, '0', 'informix', 'sp_sac_registrardatosarchivo', cDescripcionSPJ);
	
	--OBTIENE EL DIA HABIL
	EXECUTE PROCEDURE BdInteg:Sp_ValFecha_Banca ('001', vdtFechaActual, 0) INTO vsCodRetorno, vdtFechaActual;
	
	IF (TRIM(NVL(psNumEmpleado, '')) = '')THEN --VALIDA QUE EL NUMERODE EMPLEADO CONTENGA INFO
		--EL NUMERO DE EMPLEADO DEBE DE CONTENER INFORMACION
		LET vsCodRetorno = '00101';
	ELIF (NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas WHERE Fecha_Hoy::DATE = vdtFechaActual::DATE)) THEN -- VALIDA QUE EL DIA SEA UN DIA HABIL
		--DIA NO HABIL
		LET vsCodRetorno = '00102';
	ELIF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 1/*PROCESADO*/)) THEN -- SI YA SE GENERO EL ARCHIVO CORRECTAMENTE
		--PROCESO EJECUTADO PREVIAMENTE CON EXITO
		LET vsCodRetorno = '00103';
	ELIF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 3/*PROCESANDO*/)) THEN -- SE ESTA PROCESANDO EL ARCHIVO
		--SE ESTA PROCESANDO EL ARCHIVO
		LET vsCodRetorno = '00104';
	--ELIF (NOT EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC')) THEN -- VALIDA KE EXISTA ALMENOS UIN REGISTRO (REG BASE)
	ELIF (NOT EXISTS (SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Ultimo_Archivo < vdtFechaActual)) THEN -- VALIDA KE EXISTA ALMENOS UIN REGISTRO (REG BASE)
		--NO EXISTEN REGISTROS DEL PROCESO
		LET vsCodRetorno = '00105';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33000') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE NOMBRE DE ARCHIVO
		--NO EXISTE EL PARAMETRO DEL NOMBRE DEL ARCHIVO
		LET vsCodRetorno = '00106';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		--NO EXISTE EL PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		LET vsCodRetorno = '00107';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33002') ) THEN --VALIDA KE EXISTA EN PARAMETRO DEL BIN ADQUIRIENTE
		--NO EXISTE EL BIN ADQUIRIENTE EN LA TABLA DE PARAMETROS
		LET vsCodRetorno = '00108';
	--ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION 
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE LA TRANSACCION 
		--LET vsCodRetorno = '00109';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN EFECTIVO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN EFECTIVO
		LET vsCodRetorno = '00110';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE MISMO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE MISMO BANCO
		LET vsCodRetorno = '00111';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE OTRO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE OTRO BANCO
		LET vsCodRetorno = '00112';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN INTERNET
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN INTERNET
		LET vsCodRetorno = '00113';
		
	ELSE -- PARAMETROS OK
		
		--OBTIENE LA PARTE PARAMETRIZADA DEL NOMBRE DEL ARCHIVO
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParamNomArch FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33000';
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsRutaArchivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001';
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsBin_Adquiriente FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33002'; 
		
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfectivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqMBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqOBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoInternet FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_Pagotransfer FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33011'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqCorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33012'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfeccorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33013'; 


		--PAGO EFECTIVO
		--SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_TranSacc_Efectivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003'; 
		--PAGO OTRO MEDIO
		--SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_TranSacc_Otro FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33008'; 
		
		
		
		--SE FORMA EL NOMBRE DEL ARCHIVO
		LET vsNombreArchivo = TRIM(vsParamNomArch) || SUBSTRING (vdtFechaActual::DATE FROM 4 FOR 2) || SUBSTRING (vdtFechaActual::DATE FROM 1 FOR 2) || SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2) || '2.txt';
		
		
		IF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE)) OR ((EXISTS (SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual))) THEN --EXISTE 
			
			--SE ACTUALIZA EL REGISTRO
			UPDATE BdiSac:Sac_Procesos SET Status = 3/*PROCESANDO*/, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 0/*NO PROCESADO*/;
			
			DELETE FROM BdiSac:Sac_EGlobal_Detalle WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_NoConcil WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Sumario WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Encabezado WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
		ELSE
			--NUEVO REG   --PROCESANDO
			-- 0 --> NO PROCESADO  / ERROR
			-- 1 --> PROCESADO / OK
			-- 3 --> PROCESNDO / EN CURSO
			INSERT INTO BdiSac:Sac_Procesos (Proceso, Fecha_Proceso, Status, User_Insert, Fecha_Insert) VALUES ('GEN_APITDC', vdtFechaActual::DATE, 3 /*PROCESANDO*/, TRIM(psNumEmpleado), CURRENT::DATE);
		END IF;
		
		--OBTIENE EL ULTIMO REGISTRO DE LA GENERACION DEL ARCHIVO
		SELECT MAX(Fecha_Archivo) INTO vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo <> '' AND Fecha_Archivo < vdtFechaActual AND Estatus = 1;
		--SELECT MAX(Fecha_Archivo) INTO vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo <> '' AND Fecha_Archivo < vdtFechaActual ;
		
		
		LET vsNombre_Archivo = TRIM(vsNombreArchivo); 
		LET vdtFecha_Archivo = vdtFechaActual::DATE; 
		
		
		LET vsFolio_Suc = ''; 
		LET vsConciliado = '0'; 
		LET vsUser_Insert = TRIM(psNumEmpleado); 
		LET vdtFecha_Insert = CURRENT::DATE;
		
		--LET vsFechaJuliana = SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2) || LPAD((( vdtFechaAux::DATE - vdtFechaActual::DATE) + 1), 4, '0');
		
		LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
		LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2), 2, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 5, '0');
		
		LET vsFillerE = LPAD (vsFillerE, 177, ' ');
		LET vsFillerS = LPAD (vsFillerS, 146, ' ');
		
		--GUARDA REGISTRO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Archivos (Nombre_Archivo, Fecha_Archivo, Fecha_Ultimo_Archivo, Estatus, Conciliado, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, vsFechaUltimoArchivo, '0'/*Estatus*/, '0'/*Conciliado*/, vsUser_Insert, vdtFecha_Insert);
		
		--GUARDA REGISTRO DEL ENCABEZADO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Encabezado (Nombre_Archivo, Fecha_Archivo, Cod_Txn, Bin_Adquiriente, Fecha_Intercambio, Filler, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, '90'/*Cod_Txn*/, vsBin_Adquiriente, vsFechaJuliana, vsFillerE, vsUser_Insert, vdtFecha_Insert);
		
		--INCREMENTA LA FECHA EN UN DIA A LA ULTIMA GENERACION 
		LET vsFechaUltimoArchivo = vsFechaUltimoArchivo + INTERVAL(1) DAY TO DAY;
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		--OBTIENE LOS REGISTROS DE LA TABLA  MOVDIA
		FOREACH WITH HOLD
			SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia), 16, '0'), LPAD(TRIM(Transacc), 4, '0' )
			INTO vsCancelado, vsNum_Negocio, vsFolio_Suc, vsFecha_Txn, vsImporte_Txn, vsTransacc_Suc, vsNumero_Tarjeta, vsTransacc
			FROM BdiCheq:Sc_MovDia
			WHERE Empresa = '001' AND Cuenta <> ''
			AND Fech_val = vdtFechaActual::DATE
			AND Cancelad <> 'S'
			AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
			UNION ALL 
			SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia), 16, '0'), LPAD(TRIM(Transacc), 4, '0' )
			FROM BdiCheq:Sc_Movhis
			WHERE Empresa = '001' AND Cuenta <> ''
			AND Fech_val = vdtFechaActual::DATE
			AND Cancelad <> 'S'
			AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET viIdBanco = 0;
			SELECT FIRST 1 NVL(Id_Bco, 0) INTO viIdBanco FROM BdiCheq:Sc_Bines WHERE Bin = SUBSTRING (vsNumero_Tarjeta FROM 1 FOR 6);
			
			IF (NVL(viIdBanco, 0) > 0) THEN --SE ENCONTRO BIN COMPATIBLE
				
				IF (EXISTS (SELECT Cod_Reg FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco) )THEN --EXISTE EL CODICO COMPATIBLE
					SELECT FIRST 1 NVL(Cod_Reg, '3') INTO vsCodigo_Registro FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco;
				ELSE --NO ESTA REGISTRADO
					LET vsCodigo_Registro = '3'; 
				END IF;
				
			ELSE --NO SE ENCONTRO BANCO CON EL MISMO BIN
				LET vsCodigo_Registro = '3'; --03 --PENDIENTE NO SE SABE DONDEESTA CONTENIDO
			END IF;
			
			
			LET vsFechaJuliana = '';
			LET vdtFechaAux = CURRENT::DATE;
			LET vsFolioSuccAux = '';
			LET viContador = 0;
			
			
			LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
			LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 10 FOR 1), 1, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 4, '0');
			
			--//validar folio suc 
			LET viContador = 0;
			LET vsFolioSuccAux = '';
			LET vsFolio_SucAUX2 = SUBSTRING (LPAD(TRIM(vsFolio_Suc), 16, '0') FROM 9 FOR 8);
			WHILE (viContador < 8) 
				
				LET vsAuxNum = '';
				LET vsAuxNum = SUBSTRING (vsFolio_SucAUX2 FROM (1 + viContador) FOR 1);
				IF (( vsAuxNum >= '0') AND ( vsAuxNum <= '9')) THEN
					--ES NUMERICO 
					LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || vsAuxNum;
				ELSE
					--ES LETRA SE CAMBIA POR 0
					LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || '0';
				END IF;
				LET viContador = viContador +1;
			END WHILE; 
			
			
--			LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			LET vsNum_Referencia = '7' || vsBin_Adquiriente  || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			
			--MODULO 10
			LET vsFlagAlternar = '';
			LET viAcumulado = 0;
			LET viValorAux = 0;
			
			LET viContador = 0;
			LET vsFlagAlternar = 'F';
			
			
			LET viContador = LENGTH(TRIM(vsNum_Referencia));
			
			WHILE (viContador > 0 )
				
				--LET vsDetalle = '';
				
				LET viValorAux = SUBSTRING (vsNum_Referencia FROM (viContador) FOR 1);
				
				--LET vsDetalle = '['|| viValorAux || ']';
				
				IF (vsFlagAlternar = 'F') THEN 
					
					LET viValorAux = viValorAux * 2;
					
					IF (viValorAux > 9) THEN
						LET viValorAux = viValorAux - 9;
					END IF;
				
				END IF;
				
				LET viAcumulado = viAcumulado + viValorAux;
				
				--LET vsDetalle = TRIM (vsDetalle) || ' ['|| viValorAux || ']' || '  ['||  viAcumulado|| ']' ;
				
				--RETURN '0', vsDetalle WITH RESUME;
				
				IF (vsFlagAlternar = 'F') THEN
					LET vsFlagAlternar = 'V';
				ELSE
					LET vsFlagAlternar = 'F';
				END IF;
				
				LET viContador = viContador - 1;
			END WHILE;

			IF (MOD(viAcumulado, 10) > 0) THEN 
				LET viValorAux = 10 - MOD(viAcumulado, 10);
			ELSE
				LET viValorAux = 0;
			END IF;
			--MODULO 10
			
			
			--LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux) || viValorAux; --09 --MODULO VERIFICADOR
			LET vsNum_Referencia = TRIM (vsNum_Referencia) || viValorAux; --09 --MODULO VERIFICADOR
			
			
			
			
			IF (vsTransacc = vsParam_PagoEfectivo) THEN
-- 20100707-I ------> Se cambia el Cod. razon a "00" por ordenes de Eglobal:
				--     LET vsCod_Razon = '91'; --25  ---PAGO EN EFECTIVO
				LET vsCod_Razon = '00'; --25  ---PAGO EN EFECTIVO
				LET vsInd_Deposito_Efectivo = '1'; --44
			ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
				--     LET vsCod_Razon = '92'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsCod_Razon = '00'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
-- 20100707-F
			ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
				LET vsCod_Razon = '00'; --25 ---PAGO CHEQUE OTRO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoInternet) THEN
				LET vsCod_Razon = '00'; --25 --PAGO INTERNET
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_Pagotransfer) THEN -- PAGO TRANSFER
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN -- PAGO CARGO CORRESP
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN -- PAGO EFECTIVO CORRESP
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '1'; --44
			END IF;

				
			INSERT INTO BdiSac:Sac_EGlobal_Detalle 
			(Nombre_Archivo, Fecha_Archivo, Cod_Txn, Calificado_R_Codigo, Codigo_Registro, Numero_Tarjeta, Extension_Tarjeta, Ind_Limite_Piso, Ind_Cwb_Crb, Ind_Servicio,
			num_Referencia, num_Negocio, Fecha_Txn, Importe_Txn, Cod_Actual_Destino, Importe_Tasa, Cod_Actual_Origen, Nombre_Negocio, Poblacion_Negocio, Cod_Pais, Cod_Categoria, 
			Cod_Postal, Cod_Estado, Reservado, Ind_Com_Elec, Cod_Uso, Cod_Razon, Ind_Liquidacion, Ind_Servicio2, Num_Autorizaciones, Cap_Term_Pos, Filler1, Met_Identificacion, Ban_Coleccion, 
			Mod_Pos, Fecha_Proceso, Tipo_Captura, Categoria_Tasa, Ind_Medio_Acceso, Track2, Ind_Cavv, Ind_Ucaf, Diferimiento, Parcializacion, Tipo_Plan, Ind_Deposito_Efectivo, 
			Filler, Folio_Suc, Conciliado, User_Insert, Fecha_Insert)
			VALUES
			(vsNombre_Archivo, vdtFecha_Archivo, vsCod_Txn, vsCalificado_R_Codigo, vsCodigo_Registro, vsNumero_Tarjeta, vsExtension_Tarjeta, vsInd_Limite_Piso, vsInd_Cwb_Crb, vsInd_Servicio, 
			vsnum_Referencia, vsnum_Negocio, vsFecha_Txn, vsImporte_Txn, vsCod_Actual_Destino, vsImporte_Tasa, vsCod_Actual_Origen, vsNombre_Negocio, vsPoblacion_Negocio, vsCod_Pais, vsCod_Categoria, 
			vsCod_Postal, vsCod_Estado, vsReservado, vsInd_Com_Elec, vsCod_Uso, vsCod_Razon, vsInd_Liquidacion, vsInd_Servicio2, vsNum_Autorizaciones, vsCap_Term_Pos, vsFiller1, vsMet_Identificacion, vsBan_Coleccion, 
			vsMod_Pos, vsFecha_Proceso, vsTipo_Captura, vsCategoria_Tasa, vsInd_Medio_Acceso, vsTrack2, vsInd_Cavv, vsInd_Ucaf, vsDiferimiento, vsParcializacion, vsTipo_Plan, vsInd_Deposito_Efectivo, 
			vsFiller, vsFolio_Suc, vsConciliado, vsUser_Insert, vdtFecha_Insert );
			
			
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
			LET viContadorRegistros = 0;
		END IF;
		
		
		IF ( (vdtFechaActual::DATE - vsFechaUltimoArchivo::DATE) > 0) THEN --VALIDA SI SE TIENE KE CONSULTAR LA MOVHIS
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			--OBTIENE LOS REGISTROS DE LA TABLA  MOVHIS
			FOREACH WITH HOLD
				SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia),16,'0'), LPAD(TRIM(Transacc), 4, '0' )
				INTO vsCancelado, vsNum_Negocio, vsFolio_Suc, vsFecha_Txn, vsImporte_Txn, vsTransacc_Suc, vsNumero_Tarjeta, vsTransacc
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001' AND Cuenta <> ''
				AND Fech_val BETWEEN vsFechaUltimoArchivo::DATE AND vdtFechaActual::DATE
				AND Cancelad <> 'S'
				AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
				--AND (Transacc = vsParam_TranSacc_Efectivo OR Transacc = vsParam_TranSacc_Otro)
				
				--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (vsFlagEnTransaccion = 'F') THEN 
					 BEGIN WORK;
					 LET vsFlagEnTransaccion = 'V';
				END IF;
				
				LET viIdBanco = 0;
				SELECT FIRST 1 NVL(Id_Bco, 0) INTO viIdBanco FROM BdiCheq:Sc_Bines WHERE Bin = SUBSTRING (vsNumero_Tarjeta FROM 1 FOR 6);
				
				IF (NVL(viIdBanco, 0) > 0) THEN --SE ENCONTRO BIN COMPATIBLE
					
					IF (EXISTS (SELECT Cod_Reg FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco) )THEN --EXISTE EL CODICO COMPATIBLE
						SELECT FIRST 1 NVL(Cod_Reg, '3') INTO vsCodigo_Registro FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco;
					ELSE --NO ESTA REGISTRADO
						LET vsCodigo_Registro = '3'; 
					END IF;
					
				ELSE --NO SE ENCONTRO BANCO CON EL MISMO BIN
					LET vsCodigo_Registro = '3'; --03 --PENDIENTE NO SE SABE DONDEESTA CONTENIDO
				END IF;
				
				
				LET vsFechaJuliana = '';
				LET vdtFechaAux = CURRENT::DATE;
				LET vsFolioSuccAux = '';
				LET viContador = 0;
				
				
				LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
				LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 10 FOR 1), 1, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 4, '0');
				
				--//validar folio suc 
				LET viContador = 0;
				LET vsFolioSuccAux = '';
				LET vsFolio_SucAUX2 = SUBSTRING (LPAD(TRIM(vsFolio_Suc), 16, '0') FROM 9 FOR 8);
				WHILE (viContador < 8) 
					
					LET vsAuxNum = '';
					LET vsAuxNum = SUBSTRING (vsFolio_SucAUX2 FROM (1 + viContador) FOR 1);
					IF (( vsAuxNum >= '0') AND ( vsAuxNum <= '9')) THEN
						--ES NUMERICO 
						LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || vsAuxNum;
					ELSE
						--ES LETRA SE CAMBIA POR 0
						LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || '0';
					END IF;
					LET viContador = viContador +1;
				END WHILE; 
				
				
--				LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
				LET vsNum_Referencia = '7' || vsBin_Adquiriente || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			
				
				--MODULO 10
				LET vsFlagAlternar = '';
				LET viAcumulado = 0;
				LET viValorAux = 0;
				
				LET viContador = 0;
				LET vsFlagAlternar = 'F';
				
				
				LET viContador = LENGTH(TRIM(vsNum_Referencia));
				
				WHILE (viContador > 0 )
					
					--LET vsDetalle = '';
					
					LET viValorAux = SUBSTRING (vsNum_Referencia FROM (viContador) FOR 1);
					
					--LET vsDetalle = '['|| viValorAux || ']';
					
					IF (vsFlagAlternar = 'F') THEN 
						
						LET viValorAux = viValorAux * 2;
						
						IF (viValorAux > 9) THEN
							LET viValorAux = viValorAux - 9;
						END IF;
					
					END IF;
					
					LET viAcumulado = viAcumulado + viValorAux;
					
					--LET vsDetalle = TRIM (vsDetalle) || ' ['|| viValorAux || ']' || '  ['||  viAcumulado|| ']' ;
					
					--RETURN '0', vsDetalle WITH RESUME;
					
					IF (vsFlagAlternar = 'F') THEN
						LET vsFlagAlternar = 'V';
					ELSE
						LET vsFlagAlternar = 'F';
					END IF;
					
					LET viContador = viContador - 1;
				END WHILE;

				IF (MOD(viAcumulado, 10) > 0) THEN 
					LET viValorAux = 10 - MOD(viAcumulado, 10);
				ELSE
					LET viValorAux = 0;
				END IF;
				--MODULO 10
				
				
				
				--LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux) || viValorAux; --09 --MODULO VERIFICADOR
				LET vsNum_Referencia = TRIM (vsNum_Referencia) || viValorAux; --09 --MODULO VERIFICADOR
				
				
			IF (vsTransacc = vsParam_PagoEfectivo) THEN
				LET vsCod_Razon = '00'; --25  ---PAGO EN EFECTIVO
				LET vsInd_Deposito_Efectivo = '1'; --44
			ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
				LET vsCod_Razon = '00'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
				LET vsCod_Razon = '00'; --25 ---PAGO CHEQUE OTRO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoInternet) THEN
				LET vsCod_Razon = '00'; --25 --PAGO INTERNET
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_Pagotransfer) THEN 
				LET vsCod_Razon = '00'; --PAGO TRANSFER
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN 
				LET vsCod_Razon = '00'; --PAGO CARGO CORRESP
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN 
				LET vsCod_Razon = '00'; --PAGO EFEC CORRESP
				LET vsInd_Deposito_Efectivo = '1'; --44
			END IF;
				
				
				
				--INCERTA EN LA TABLA DE DETALLE
				INSERT INTO BdiSac:Sac_EGlobal_Detalle 
				(Nombre_Archivo, Fecha_Archivo, Cod_Txn, Calificado_R_Codigo, Codigo_Registro, Numero_Tarjeta, Extension_Tarjeta, Ind_Limite_Piso, Ind_Cwb_Crb, Ind_Servicio,
				num_Referencia, num_Negocio, Fecha_Txn, Importe_Txn, Cod_Actual_Destino, Importe_Tasa, Cod_Actual_Origen, Nombre_Negocio, Poblacion_Negocio, Cod_Pais, Cod_Categoria, 
				Cod_Postal, Cod_Estado, Reservado, Ind_Com_Elec, Cod_Uso, Cod_Razon, Ind_Liquidacion, Ind_Servicio2, Num_Autorizaciones, Cap_Term_Pos, Filler1, Met_Identificacion, Ban_Coleccion, 
				Mod_Pos, Fecha_Proceso, Tipo_Captura, Categoria_Tasa, Ind_Medio_Acceso, Track2, Ind_Cavv, Ind_Ucaf, Diferimiento, Parcializacion, Tipo_Plan, Ind_Deposito_Efectivo, 
				Filler, Folio_Suc, Conciliado, User_Insert, Fecha_Insert)
				VALUES
				(vsNombre_Archivo, vdtFecha_Archivo, vsCod_Txn, vsCalificado_R_Codigo, vsCodigo_Registro, vsNumero_Tarjeta, vsExtension_Tarjeta, vsInd_Limite_Piso, vsInd_Cwb_Crb, vsInd_Servicio, 
				vsnum_Referencia, vsnum_Negocio, vsFecha_Txn, vsImporte_Txn, vsCod_Actual_Destino, vsImporte_Tasa, vsCod_Actual_Origen, vsNombre_Negocio, vsPoblacion_Negocio, vsCod_Pais, vsCod_Categoria, 
				vsCod_Postal, vsCod_Estado, vsReservado, vsInd_Com_Elec, vsCod_Uso, vsCod_Razon, vsInd_Liquidacion, vsInd_Servicio2, vsNum_Autorizaciones, vsCap_Term_Pos, vsFiller1, vsMet_Identificacion, vsBan_Coleccion, 
				vsMod_Pos, vsFecha_Proceso, vsTipo_Captura, vsCategoria_Tasa, vsInd_Medio_Acceso, vsTrack2, vsInd_Cavv, vsInd_Ucaf, vsDiferimiento, vsParcializacion, vsTipo_Plan, vsInd_Deposito_Efectivo, 
				vsFiller, vsFolio_Suc, vsConciliado, vsUser_Insert, vdtFecha_Insert );
				
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
				LET viContadorRegistros = 0;
			END IF;
			
		END IF;
		
		LET viTotalRegistros = 0;
		LET viTotalPagos = 0;
		LET viTotalImportePagos = 0;
		LET viTotalRechazados = 0;
		LET viTotalImporteRechazados = 0;
		
		--TOTALES
		SELECT COUNT (Nombre_Archivo) INTO viTotalRegistros
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo;
		
		--TOTALES PAGOS
		SELECT SUM(DECODE(Cod_Txn, '08', 1, 0)), SUM(NVL(Importe_Txn, '0')::INTEGER) INTO viTotalPagos, viTotalImportePagos 
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo AND Cod_Txn = '08';
		
		--TOTALES RECHAZADOS
		SELECT SUM(DECODE(Cod_Txn, '08', 0, 1)), SUM(NVL(Importe_Txn, '0')::INTEGER) INTO viTotalRechazados, viTotalImporteRechazados 
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo AND Cod_Txn <> '08';
		
		
		--GUARDA REGISTRO DEL SUMARIO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Sumario (Nombre_Archivo, Fecha_Archivo, Cod_Txn, Total_Registros, Total_Pagos, Importe_Pagos, Total_Rechazos, Importe_Rechazos, Filler, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, '92'/*Cod_Txn*/, LPAD(NVL(viTotalRegistros, 0), 6, '0'), LPAD(NVL(viTotalPagos, 0), 6, '0'), LPAD(NVL(viTotalImportePagos, 0), 12, '0'), LPAD(NVL(viTotalRechazados, 0), 6, '0'), LPAD(NVL(viTotalImporteRechazados, 0), 12, '0') , vsFillerS, vsUser_Insert, vdtFecha_Insert);
		
		--GENERAR ARCHIVO.
		EXECUTE PROCEDURE BdiSac:sp_Sac_GeneraArchivoPTC (psNumEmpleado, vsNombre_Archivo) INTO vsCodRetorno, vsMensajeRet;
		
		IF (vsCodRetorno = '00000') THEN 
			--ACTUALIZA EL REGISTRO DE PROCESO A TERMINADO CORRECTAMENTE
			UPDATE BdiSac:Sac_Procesos SET Status = 1, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 3;
			--ACTUALIZA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_API_TDC', vdtFechaActual, '1', 'informix', 'sp_sac_registrardatosarchivo', cDescripcionSPJ);
			LET vsCodRetorno = '00000'; -- OK

-- Se actualiza estatus del archivo a 1, si termino correctamente la generaciÃ³n del mismo. JGP.
          		UPDATE bdisac:sac_eglobal_archivos SET estatus = '1' 
          			WHERE estatus = '0' 
                			and Nombre_Archivo = vsNombre_Archivo       
                			and fecha_archivo = vdtFecha_Archivo::DATE;


--                    Se le agrega la condicion para que cambie a status '2' todos los registros de fechas anteriores que no tengan status de enviados ('0')
--                    para que no puedan cambiar el status a enviado en un dia posterior:

            		UPDATE bdisac:sac_eglobal_archivos SET estatus = '2' 
            			WHERE 
                			estatus = '0' 
                			and Nombre_Archivo <> vsNombre_Archivo       
                			and fecha_archivo BETWEEN vsFechaUltimoArchivo::DATE AND vdtFechaActual::DATE;
                			


		ELSE --ERROR AL GENERAR EL ARCHIVO
			--ACTUALIZA EL REGISTRO DE PROCESO A SIN PROCESAR 7 ERROR -- REPROCESAR
			UPDATE BdiSac:Sac_Procesos SET Status = 0, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 3;				
		END IF;
		
	END IF;
	
	
	--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
	SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
	
	
	RETURN vsCodRetorno, vsMensajeRet ;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Concentra las transacciones de paga de PITDC en una tabla con la finalidad de generar el archivo que se envia a EGlobal.',
'Fecha: 2010/03/19',
'Version: 20100319.0953',
'BD: BdiSac',
'',
'Modifico: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el formato de la fecha juliana para el encabezado del archivo de formato ADDD por AADDD.',
'Fecha: 2010/04/07',
'Version: 20100407.1155',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el uso de los parametros de las transacciones de PITDC para que se identifiquen los 4 tipos de transacciones identificadas.',
'Fecha: 2010/04/29',
'Version: 20100429.0947',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el manejo de la variable de numero de tarjeta para que en el caso de contener menos de 16 numero agrege 0 a la izq. del numero de la tarjeta.',
'Fecha: 2010/05/10',
'Version: 20100510.0902',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: ',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el calculo del digito verificador modulo 10 para que en lugar de utilizar el numero de la tarjeta para el calculo utilice el numero de la referencia de la transaccion.',
'Fecha: 2010/07/05',
'Version: 20100705.1455',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_consultacomplementodatos_web(cNumCteContratante CHAR(20))
RETURNING
CHAR(5)	    AS  cCodRet

--Variables de retorno
DEFINE cCodRet			 CHAR(5);
DEFINE cNumcte           CHAR(20);
DEFINE iExisContr        INTEGER;

--Variables internas
DEFINE iSqlErr       INTEGER; 
DEFINE iIsamErr    	 INTEGER; 
DEFINE cInfoErr 	 CHAR(10); 

--Asignacion de valores default
LET cCodRet			  = "00000";
LET cNumcte           = "";
LET iExisContr = 0;

--SET DEBUG FILE TO "/tmp/JesusR/577/sp_consultacomplementodatos.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF (TRIM(cNumCteContratante) = "") THEN
		LET cCodRet= "00001";
		RETURN cCodRet;
	ELSE
	
		SELECT LIMIT 1 1
		INTO iExisContr
		FROM bdisac:"informix".sac_cardif_migrante 
		WHERE (TRIM(sexo) = '' OR TRIM(ciudad) = '' OR TRIM(nacionalidad) = '' OR TRIM(sexo) IS NULL OR TRIM(ciudad) IS NULL OR TRIM(nacionalidad) IS NULL)
		AND numcte = TRIM(cNumCteContratante)
		AND estatus IN(1,2);
				
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "00000";
		ELSE
			LET cCodRet = "00003";
		END IF;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
"Folio: ",
"Autor: 97877352 - Jesus Alberto Rubio",
"Fecha: 21/05/2019",
"Descripcion: Consulta la Informacion del cliente Migrante CARDIF.",
"Solicita: Leonardo Hernandez",
"BD: bdisac";

CREATE PROCEDURE "informix".sp_guardaresptelmex(idConsulta CHAR(20), idPago CHAR(20), numTel CHAR(10), usuario CHAR(8), sucursal CHAR(4), fecha CHAR(8), hora CHAR(6), folioSuc CHAR(16), formaPago CHAR(1), importe CHAR(18), numTc CHAR(20), gen1 CHAR(20), gen2 CHAR(20), gen3 CHAR(20))

RETURNING CHAR (5) AS cCodRet, CHAR (50) AS vMensaje;
   
	DEFINE cCodRet		CHAR (5);
	DEFINE vMensaje		CHAR (50);
	DEFINE iSqlErr		INTEGER;
	DEFINE iIsamError	INTEGER;
	DEFINE cCod_retorno	CHAR(5);
	
	LET cCodRet		= '00000';
	LET iSqlErr		= 0;
	LET iIsamError	= 0;
	LET vMensaje	='PROCESO EXITOSO';
	LET cCod_retorno = '';
	
   
   BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensaje ='ERROR ' || cCodRet || ', al grabar el registro ';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
			INTO cCod_retorno;

			RETURN cCodRet, 'ERROR AL GRABAR REGISTRO';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/noe/sp_guardaresptelmex.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	if idPago::integer <= 0 then
		LET cCodRet = 01010;
		LET vMensaje ='ERROR ' || cCodRet || ', idPago Invalido (' || idPago || ')';

		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
		INTO cCod_retorno;

		RETURN cCodRet, vMensaje;
	end if;


	INSERT INTO "informix".sac_pagos_telmex(idconsulta, idpago, numtel, usuario, sucursal, fecha, hora, foliosuc, formapago, importe, numtc, gen1, gen2, gen3, fecha_insert) 
    VALUES(idConsulta, idPago, numTel, usuario, sucursal, fecha, hora, folioSuc, formaPago, importe, numTc, gen1, gen2, gen3, CURRENT);
			
	  
	RETURN cCodRet, vMensaje;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 93440138 - Noe Medina R.',
'DESCRIPCION: Graba la respuesta de Pagos Telmex (BUS)',
'FOLIO: ',
'FECHA : 19-08-2021',
'VERSION: 20210819.1252',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_paymentrejection(pCompanyCode CHAR (3),
													pChannelId CHAR (3),
													pTokenId CHAR (80),
													pLanguage CHAR (5),
													pApiVersion CHAR (6),
													pClientSoftwareVersion CHAR (6),
													pUniqueReferenceNumber CHAR (16),
													pReferenceNumber CHAR (30),
													pProcessReasonTypeCode CHAR (4),
													pCodeRequest CHAR (3),
													pChannelIdRequest CHAR (3),
													pTaxIdentificationNumber CHAR (20),
													pLocationUnit CHAR (15),
													pNumberRequest CHAR (15),
													pTypeCode CHAR (3),
													pCountryCode CHAR (3),
													pStateCode CHAR (3),
													pUserId CHAR (20),
													pSupervisorId CHAR (20),
													pTerminalId CHAR (15),
													pProcessDateRequest CHAR (8),
													pProcessTimeRequest CHAR (6),
													pCode CHAR (4),
													pMessageResponse CHAR (255),
													pCodeDetail CHAR (4),
													pMessageDetail CHAR (255),
													pProcessDateResponse CHAR (8),
													pProcessTimeResponse CHAR (6),
													puniquereferencenumberrequest CHAR (16),
													pGlobalTrackingNumber CHAR (20),
													pOrderStatusCode CHAR (3),
													pOrderStatusDate CHAR (8),
													pOrderStatusTime CHAR (6))
												   
--DATOS A REGRESAR---
RETURNING CHAR(5)  AS cCodRetorno,
		  CHAR(80) AS cDesc_Error,
		  CHAR(16) As cRemesa,
		  CHAR(1)  AS cFlg_confirm_ctral,
		  CHAR(8)  AS cfecha_proceso,
		  CHAR(6)  AS cHora_proceso;

--DEFINICION DE VARIABLES--
DEFINE cCodRetorno 		  CHAR(5);
DEFINE cDesc_Error		  CHAR(80);
DEFINE cRemesa 			  CHAR(16);
DEFINE cFlg_confirm_ctral CHAR(1);
DEFINE cfecha_proceso     CHAR(8);
DEFINE cHora_proceso 	  CHAR(6);	
DEFINE cCnxn_status  		CHAR(1);
DEFINE cValor 				CHAR(200);
DEFINE iSqlErr 				INTEGER;
DEFINE cValCode 			CHAR(100);
DEFINE cValChannell			CHAR(100);
DEFINE cTermi 				CHAR(100);
DEFINE cValUsu 				CHAR(100);
DEFINE cVaLTer 				CHAR(200);
DEFINE cValocUni 			CHAR(100);
DEFINE cValTypCode 			CHAR(100);
DEFINE cValCouCode 			CHAR(100);
DEFINE cIdentNum 			CHAR(100);
define cStateCode 			CHAR(100);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cCadena_ent          CHAR(100);
DEFINE iFlg_insertaerrorws	INTEGER;
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cCodRet2             CHAR(5);
DEFINE cDescError			CHAR(80);
define iIsamErr 			INTEGER;
DEFINE cFechaInsert    		CHAR(8);
DEFINE iCod_param     		INTEGER;



--INICIALIZACION DE VARIABLES--		
LET cCodRetorno = '00000';	
LET cDesc_Error = '';
LET cRemesa  = '';			 
LET cfecha_proceso = '';
LET cHora_proceso = '';	 
LET cCnxn_status = 'C';
LET cValor = '';
LET iSqlErr = 0;
LET cValCode = '';
LET cValChannell ='';
LET cTermi = '';
LET cValUsu= '';
LET cVaLTer='';
LET cValocUni  = '';
LET cValTypCode ='';
LET cValCouCode  ='';
LET cIdentNum ='';
let cStateCode = '';
let cNombreSPL = 'sp_app_paymentRejection';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	iFlg_insertaerrorws	 = 1;
LET	cFlg_confirm_ctral	 = '0';
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCodRet2	 		 = '00000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET iIsamErr			 = 0;
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET iCod_param  = 0;


   --SET DEBUG FILE TO '/informix/EPG/sp_app_paymentRejection.out';
   --TRACE ON;

BEGIN
--Erro informix
    ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment (cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
			VALUES(NVL(cCnxn_status,'C') ,'',pCompanyCode,pChannelId,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,pTaxIdentificationNumber,pLocationUnit,pNumberRequest,pTypeCode,pCountryCode,pStateCode,pUserId,'',pTerminalId,pProcessDateRequest,pProcessTimeRequest,pCode,pMessageResponse,pCodeDetail,pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,
			pOrderStatusDate,pOrderStatusTime,'',CURRENT);
			
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
			
			RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;
    END EXCEPTION;		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','', TRIM(pUserId), current::date, cHoraInsert);	
	
	IF TRIM(pUniqueReferenceNumber) = '' OR  TRIM(pReferenceNumber) = ''THEN
		LET cCodRetorno = '1100';		
	END IF;

	IF TRIM(pCompanyCode) = ''  THEN 
		
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pChannelId) = '' THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pCode) = '' THEN
		LET cCodRetorno = '9999';
	END IF;
	
	
	IF cCodRetorno::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
		
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87102,87103,87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87102 THEN
				LET cValCode = TRIM(cValor);
			ELIF iCod_param=87103 THEN
				LET cValChannell = TRIM(cValor);
			ELIF iCod_param= 87104 THEN
				LET cValocUni = TRIM(cValor);
			ELIF iCod_param= 87105 THEN
				LET cValTypCode = TRIM(cValor);
			ELIF iCod_param= 87106 THEN
				LET cValCouCode = TRIM(cValor);
			ELIF iCod_param= 87112 THEN
				LET cTermi= TRIM(cValor);
			ELIF iCod_param= 87113 THEN
				LET cIdentNum= TRIM(cValor);
			ELIF iCod_param= 87114 THEN
				LET cStateCode= TRIM(cValor);
				END IF
		END FOREACH

		
		LET cVaLTer = TRIM(cTermi) || TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '06'
		WHERE estatus_getorder in ('04', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF;
	END IF;
	
	IF cCodRetorno::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRetorno;


		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
				
		INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
		VALUES(cCnxn_status,'PMCO',pCompanyCode,cValChannell,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,		
		 pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,cIdentNum,cValocUni,pNumberRequest,cValTypCode,cValCouCode,cStateCode,cValUsu,pSupervisorId,cVaLTer,pProcessDateRequest,pProcessTimeRequest,cValCode,pMessageResponse,pCodeDetail,	pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,cValUsu,CURRENT);
		
		 
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
		INTO cCodRet2;

		RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;

END;
END PROCEDURE
DOCUMENT
'FOLIO: 230142-150, "RQM 10 809  Pago de Remesas Appriza con abono automático en cuentas de captación ',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 15/11/2016',
'DESCRIPCION: Se crear stored procedure para guardar registros en la tabla sac_app_confirmpayment ',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_app_confirmpayment(  pCompanyCode				 CHAR (3),	
													pChannelId                   CHAR (3),
													pTokenId                     CHAR (80),
													pLanguage                    CHAR (5),
													pApiVersion                  CHAR (6),
													pClientSoftwareVersion       CHAR (6),
													pUniqueReferenceNumber       CHAR (16),
													pReferenceNumber             CHAR (30),
													pCodeRequest                 CHAR (3),
													pChannelIdRequest            CHAR (3),
													pTaxIdentificationNumber     CHAR (20),
													pLocationUnit                CHAR (15),
													pNumberRequest               CHAR (15),
													pTypeCode                    CHAR (3),
													pCountryCode                 CHAR (3),
													pStateCode                   CHAR (3),
													pUserId                      CHAR (20),
													pSupervisorId                CHAR (20),
													pTerminalId                  CHAR (15),
													pProcessDateRequest          CHAR (8),
													pProcessTimeRequest          CHAR (6),
													pCode                        CHAR (4),
													pMessageResponse             CHAR (255),
													pCodeDetail                  CHAR (4),
													pMessageDetail               CHAR (255),
													pProcessDateResponse         CHAR (8),
													pProcessTimeResponse         CHAR (6),
													pUniqueReferenceNumberReques CHAR (16),
													pGlobalTrackingNumber        CHAR (20),
													pOrderStatusCode             CHAR (3),
													pOrderStatusDate             CHAR (8),
													pOrderStatusTime             CHAR (6)
													)

RETURNING CHAR(5)  AS CodRetorno,
		  CHAR(80) AS Desc_Error,
		  CHAR(16) As Remesa,
		  CHAR(1)  AS Flg_confirm_ctral,
		  CHAR(8)  AS fecha_proceso,
		  CHAR(6)  AS Hora_proceso;

--SE DECLARAN VARIABLES.
DEFINE iSqlErr 				INTEGER;
DEFINE iIsamErr 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCodRet2             CHAR(5);
DEFINE cOpCode				CHAR(4);
DEFINE cDescError			CHAR(80);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cFechaInsert    		CHAR(8);
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cValor       		CHAR(100);
DEFINE iCod_param     		INTEGER;
DEFINE cCadena_ent          CHAR(100);
DEFINE cCnxn_status			CHAR(1);
DEFINE cFlg_confirm_ctral	CHAR(1);
DEFINE iFlg_insertaerrorws	INTEGER;

--SET DEBUG FILE TO "/informix/EPG/sp_app_confirmpayment.out";
--TRACE ON; 
--Inicializacion de Variables
LET iSqlErr 			 = 0;
LET iIsamErr			 = 0;
LET cCodRet		 		 = '00000';
LET cCodRet2	 		 = '00000';
LET cOpCode				 = '0000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET cNombreSPL   		 = 'sp_app_confirmpayment';
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cValor       		 = '';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	cCnxn_status		 = 'C';
LET	cFlg_confirm_ctral	 = '0';
LET	iFlg_insertaerrorws	 = 1;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	

BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
			VALUES(NVL(cCnxn_status,'C'),'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
			
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
	
		RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
	END EXCEPTION;
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert) 
	--VALUES (cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','',TRIM(pUserId),current::date,cHoraInsert);
	
	IF TRIM(NVL(pUniqueReferenceNumber,'')) = '' OR TRIM(NVL(pReferenceNumber,''))='' THEN
		LET cCodRet = '1100';
		
	END IF
	IF TRIM(NVL(pCompanyCode,'')) = '' THEN
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF
	IF TRIM(NVL(pChannelId,''))=''THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF

	IF TRIM(NVL(pCode,''))=''THEN
		LET cCodRet = '9999';
	END IF
	
	IF cCodRet::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87104 THEN
				LET pLocationUnit = TRIM(cValor);
			ELIF iCod_param=87105 THEN
				LET pTypeCode = TRIM(cValor);
			ELIF iCod_param=87106 THEN
				LET pCountryCode = TRIM(cValor);
			ELIF iCod_param=87112 THEN
				LET pNumberRequest = TRIM(cValor);
			ELIF iCod_param=87113 THEN
				LET pTaxIdentificationNumber = TRIM(cValor);
			ELIF iCod_param=87114 THEN
				LET pStateCode = TRIM(cValor);
			END IF
		END FOREACH
	
		LET pTerminalId = TRIM(pNumberRequest)||TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';	
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '05'
		WHERE estatus_getorder in ('03', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF;
	ELSE 
		LET cCodRet = '1100';
	END IF;
		
	IF cCodRet::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRet;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
	
	INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
	VALUES(cCnxn_status,'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));

	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
	--INTO cCodRet2;

	RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
END
END PROCEDURE
DOCUMENT
'AUTOR: 95358919 - MARIO GAMALIEL OLIVO URIAS',
'CENTRO: 230142',
'FOLIO: 150',
'RQM: RQM 10 809 Â? Pago de Remesas Appriza con abono automÃ¡tico en cuentas de captaciÃ³n.doc',
'FECHA: 05/NOVIEMBRE/2016',
'SOLICITA: EDUARDO PINEDA',
'VERSION: 20161105.0936',
'DESCRIPCION: CONFIRMA TODAS LAS REMESAS QUE FUERON ABONADAS A LAS CUENTAS CORRECTAMENTE.',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_app_getorderstoreprocess (pcUsuario CHAR(15),
	pRegs_recup INTEGER,
	pFecha_peticion CHAR(8),
	pHora_peticion CHAR(6))

--Datos a regresar
RETURNING 	CHAR(12) AS numremesa,
            CHAR(5) AS channelId,
            CHAR(8) AS fec_proceso,
            CHAR(6) AS hora_proceso,
            CHAR (5) AS codret;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_getorderstoreprocess';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET pcUsuario  =  pcUsuario;
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio, channelid
				INTO cRemesa,cCodigo,iIntentosenvio,cChannelId
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '13')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				--AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '14' WHERE UniqueReferenceNumber = cRemesa 
				and estatus_getorder = '13'
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,lpad(cCod_err,5,'0');
		END IF
	END
END PROCEDURE;