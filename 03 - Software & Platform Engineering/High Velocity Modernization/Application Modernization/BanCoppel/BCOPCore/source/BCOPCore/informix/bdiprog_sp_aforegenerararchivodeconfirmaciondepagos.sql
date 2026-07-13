CREATE PROCEDURE "informix".sp_aforegenerararchivodeconfirmaciondepagos(pNombreArchivo CHAR(30),pUser_Insert CHAR(8))
	RETURNING CHAR(5);
/*------------------------------------GENERALES -----------------------------------------------*/
DEFINE cTipoRegistro CHAR(1);
DEFINE cFinLinea CHAR(2);
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE dFecha_Hoy DATE;
Define cSQL CHAR(250);
DEFINE cProceso CHAR(10);
DEFINE cProceso1 CHAR(20);
DEFINE cNombreArchivoSalida CHAR(30);
DEFINE cRenglon CHAR(276);
DEFINE cCuenta CHAR(11);
/*-----------------------------------------ENCABEZADO-------------------------------------------*/
DEFINE cNoContratoEmpresa CHAR(8);
DEFINE cFechaGeneracionInformacion CHAR(8);
DEFINE cFechaInicialInformacion CHAR(8);
DEFINE cFechaFinalInformacion CHAR(8);
DEFINE cNoMovimientosContenidos CHAR(9);
DEFINE cFillerEncabezado CHAR(232);
/*-----------------------------------------DETALLE---------------------------------------------------*/
DEFINE cNSS CHAR(11);
DEFINE cNombreBeneficiario CHAR(40);
DEFINE cApellidoPaternoBeneficiario CHAR(40);
DEFINE cApellidoMaternoBeneficiario CHAR(40);
DEFINE cFormasPago CHAR(1);
DEFINE cCLABE CHAR(18);
DEFINE cFechaCaptura CHAR(8);
DEFINE mImporteDocumentoNetoPagar INTEGER;
DEFINE mImporteDocumentoAntesImpuesto INTEGER;
DEFINE mImpuestoRetenido INTEGER;
DEFINE cNumeroFolioServicio CHAR(8);
DEFINE cNumeroTienda CHAR(4);
DEFINE cTipoRetiro CHAR(3);
DEFINE cConsecutivoRetiro CHAR(10);
DEFINE cRFC CHAR(10);
DEFINE cFillerDetalle CHAR(3);
DEFINE iConsecutivo INTEGER;
DEFINE dHora  datetime HOUR TO SECond;
DEFINE cCurp CHAR(18);
DEFINE cStatus CHAR(2);
DEFINE cFolio_suc CHAR(16);
/*----------------------------------------SUMARIO----------------------------------------------------*/
DEFINE cNumeroTotalMovimientosContenidos CHAR(9);
DEFINE mImporteTotalNeto BIGINT;
DEFINE mImporteTotalAntesImpuesto BIGINT;
DEFINE mImporteRetenido BIGINT;
DEFINE mImporteTotalRetirosPagadosEfectivo BIGINT;
DEFINE mImporteTotalRetirosPagadosDeposito BIGINT;
DEFINE cFillerSumario CHAR(179);
DEFINE cRuta CHAR(20);
DEFINE cRellen CHAR(15);
DEFINE cRellen1 CHAR(15);
DEFINE cRellen2 CHAR(11);

DEFINE cRelleno CHAR(17);
DEFINE cRelleno1 CHAR(17);
DEFINE cRelleno2 CHAR(17);
DEFINE cRelleno3 CHAR(17);
DEFINE cRelleno4 CHAR(17);
DEFINE cCodRetInterno CHAR(5);
DEFINE cMensaje CHAR(200);
DEFINE cError CHAR(1);

/*---------------------------ECRIPTACION---------------------------*/
DEFINE cRetEncripcion				CHAR(6);
DEFINE cMsgEncripcion				CHAR(100);
DEFINE cLlave						CHAR(200);
DEFINE cNombreArchivo				CHAR(50);
DEFINE cRutaArchivoOrigen			CHAR(100);
DEFINE cRutaArchivoDestino			CHAR(100);
DEFINE cRutaRespaldo				CHAR(100);
DEFINE cUsuario						CHAR(20);


LET cCodRetInterno = '00000';
/*--estas son variables para rellenar con  ceros a la izquierda*/
LET cRellen ='';
LET cRellen1 ='';
LET cRellen2 ='';
LET cRelleno ='';
LET cRelleno1 ='';
LET cRelleno2 ='';
LET cRelleno3 ='';
LET cRelleno4 ='';
/*-----------------------------------------ENCABEZADO-------------------------------------------*/
LET cNoContratoEmpresa 			= '';
LET cFechaGeneracionInformacion 	= '';
LET cFechaInicialInformacion 	= '';
LET cFechaFinalInformacion 		= '';
LET cNoMovimientosContenidos 	= '';
LET cFillerEncabezado 			= '';
LET cCuenta 			= '';
/*-----------------------------------------DETALLE---------------------------------------------------*/
LET cNSS = '';
LET cNombreBeneficiario = '';
LET cApellidoPaternoBeneficiario = '';
LET cApellidoMaternoBeneficiario = '';
LET cFormasPago = '';
LET cCLABE = '';
LET cFechaCaptura = '';
LET mImporteDocumentoNetoPagar = 0.00;
LET mImporteDocumentoAntesImpuesto = 0.00;
LET mImpuestoRetenido = 0.00;
LET cNumeroFolioServicio = '';
LET cNumeroTienda = '';
LET cTipoRetiro = '';
LET cConsecutivoRetiro = '';
LET cRFC = '';
LET cFillerDetalle = '';
LET iConsecutivo = '';
LET dHora = '';
LET cCurp = '';
LET cStatus = '';
LET cFolio_suc = '';
LET cRuta = '';
/*-----------------------------SUMARIO----------------------------*/
LET cNumeroTotalMovimientosContenidos		= '';
LET mImporteTotalNeto						= 0.00;
LET mImporteTotalAntesImpuesto				= 0.00;
LET mImporteRetenido						= 0.00;
LET mImporteTotalRetirosPagadosEfectivo     = 0.00;
LET mImporteTotalRetirosPagadosDeposito		= 0.00;
LET cFillerSumario = '';
/*---------------------------ECRIPTACION---------------------------*/
LET cRetEncripcion = '';
LET cMsgEncripcion = '';
LET cLlave = '';
LET cNombreArchivo = '';
LET cRutaArchivoOrigen = '';
LET cRutaArchivoDestino = '';
LET cRutaRespaldo = '';
LET cUsuario = '';

LET cFinLinea	= 'LF';
LET iSqlErr    	= '';
LET cCodRet    	= '';
LET dFecha_Hoy 	= '';
LET cSQL   		= '';
LET cProceso	= '';
LET cProceso1	= '';
LET cError		= '0';
LET cNombreArchivoSalida 	= '';
LET cRenglon	= '';
LET dhora = CURRENT HOUR TO SECOND;
LET cSQL 		= '';
LET dFecha_Hoy 	= '';
LET cCodRet 	= "00000";
LET cProceso = 'AforeGAC';

	--set debug file to "/informix/yuri/sp_AforeGenerarArchivoDeConfirmacionDePagos.out";
	--Trace on;

BEGIN
	 
		/*---------------------ERRORES
			LET cCodRet = '10011';-- El Archivo ya fue procesado
			LET cCodRet = '10013';	--No existe el archivo
			LET cCodRet = '10023';--Error por si algun dato se obtiene en nulo, Ã³ el numero de CLABE no existe
			LET cCodRet = '10024';-- Error ya que no se Ejecuto el proceso de Anterior
		*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-------Crea el control de errores
			ON EXCEPTION SET iSqlErr
				IF iSqlErr != 0 THEN
					LET cCodRet = iSqlErr;
					CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
					INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				    VALUES (cProceso,pNombreArchivo,cCodRet,cCodRet,pUser_Insert,dFecha_Hoy,dhora);
					RETURN cCodRet;
				END IF;
			END EXCEPTION;
			ON EXCEPTION IN (-668)
				Let cCodRet = '10010';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				LET cProceso1 = cProceso || '-' || cError;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso1,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet;
		    END EXCEPTION WITH resume;			
		
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		LET dhora = CURRENT;
		---se valida si se recivio el parametro          pUser_Insert
		IF TRIM(pUser_Insert) = '' THEN
			LET pUser_Insert = 'informix';
		END IF;
		
		------------- Se  obtiene la fecha del sistema   
		SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;

		---------Se crea el nombre del proceso con el consecutivo 01------------------
		LET cProceso = 'AforeGAC' || '01';
		--Crear el nombre del archivo con el consecutivo 01 		 
		LET cNombreArchivoSalida = 'CONF' || LPAD(DAY(dFecha_Hoy),2,'0') || LPAD(MONTH(dFecha_Hoy),2,'0') || YEAR(dFecha_Hoy)  || '.BCOPPEL.01';
		--por si no  me envian el nombre del archivo
		IF TRIM(pNombreArchivo) <> '' THEN-- Hay que tomar el consecutivo del nombre del archivo
			LET cProceso = 'AforeGAC' || SUBSTR(pNombreArchivo,23,2);
			LET cNombreArchivoSalida = 'CONF' || LPAD(DAY(dFecha_Hoy),2,'0') || LPAD(MONTH(dFecha_Hoy),2,'0') || YEAR(dFecha_Hoy)  || '.BCOPPEL.'||SUBSTR(pNombreArchivo,23,2);
		END IF;
			------------- Validar que ya este Ejecutado el proceso de EjecuciÃ³n de Pagos Pendientes y concluido satisfactoriamente.
		IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = ('AforeEPP'|| SUBSTR(pNombreArchivo,23,2)) AND pp_Procesos.fech_proceso = dFecha_Hoy AND  pp_Procesos.status = '2') THEN
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------Validar si ya se ejecuto el proceso de Generar Archivo De Confirmacion De Pagos
			IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy) THEN
				SELECT status INTO cStatus FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy;
				IF cStatus != '1' THEN
					LET cCodRet = '10011';
					CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
					INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
					VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);		
					RETURN cCodRet;
				END IF;
			ELSE
				--- guardar el inicio del proceso y se ejecuta
				INSERT INTO bdiprog:pp_Procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
				VALUES (cProceso,dFecha_hoy,'1',pUser_Insert,dFecha_Hoy);		
			END IF;
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ELSE
			--- mensaje de error ya que se devio haber Ejecutado el proceso de EjecuciÃ³n de Pagos Pendientes 
				LET cCodRet = '10024';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);		
				RETURN cCodRet;
		END IF;
		--------
		DELETE FROM pp_archtemp;
		
		--o	Se leerÃ¡ de la tabla de parÃ¡metros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, nÃºmero de contrato, etc.).
		SELECT valor INTO cRuta FROM  bdiprog:pp_Parametros WHERE cve_param = '100';		

		--datos del encabezado
		SELECT 
			nombre_arch,tipo_reg,LPAD(contrato,8,'0'), SUBSTR(fecha_gen,1,2) ||  SUBSTR(fecha_gen,4,2) ||  SUBSTR(fecha_gen,7,4), SUBSTR(fecha_ini,1,2) ||  SUBSTR(fecha_ini,4,2) ||  SUBSTR(fecha_ini,7,4) , SUBSTR(fecha_fin,1,2) ||  SUBSTR(fecha_fin,4,2) ||  SUBSTR(fecha_fin,7,4) , LPAD(no_mov,9,'0') , filler,fin_linea
		INTO 
			pNombreArchivo, cTipoRegistro,cNoContratoEmpresa, cFechaGeneracionInformacion, cFechaInicialInformacion, cFechaFinalInformacion, cNoMovimientosContenidos, cFillerEncabezado, cFinLinea
		FROM bdiprog:pp_Encabezado
		WHERE bdiprog:pp_Encabezado.nombre_arch = pNombreArchivo; 

		LET cRenglon = 	cTipoRegistro || cNoContratoEmpresa || cFechaGeneracionInformacion || cFechaInicialInformacion || cFechaFinalInformacion||  cNoMovimientosContenidos || cFillerEncabezado || cFinLinea;
		
		INSERT INTO bdiprog:pp_archtemp (columna)
		VALUES (cRenglon);		
		
		--datos de Detalle
		FOREACH
			--se obtienen los datos que van a guardarse en el registro de encabezado del archivo de salida
			SELECT 
				nombre_arch,consecutivo,tipo_reg,nss,forma_pago,LPAD(clabe,18,'0'),
				SUBSTR(fecha_captura,1,2) ||  SUBSTR(fecha_captura,4,2) ||  SUBSTR(fecha_captura,7,4) ,
				imp_netopagar * 100,imp_antimpuesto * 100,imp_retenido * 100,LPAD(num_folioservicio,8,'0'),lPAD(num_tienda,4,'0'),LPAD(tipo_retiro,3,'0'),
				LPAD(consecutivo_ret,10,'0'),curp,rfc,LPAD(status,2,'0'),LPAD (NVL(TRIM(folio_suc),'0'),16,'0'),filler,fin_linea
			INTO 
				pNombreArchivo,iConsecutivo,cTipoRegistro,cNSS,cFormasPago,cCLABE,cFechaCaptura,mImporteDocumentoNetoPagar,
				mImporteDocumentoAntesImpuesto ,mImpuestoRetenido ,cNumeroFolioServicio,cNumeroTienda,cTipoRetiro,cConsecutivoRetiro,
				cCURP,cRFC,cStatus,cFolio_suc,cFillerDetalle,cFinLinea
				FROM bdiprog:pp_Detalle 
			WHERE bdiprog:pp_Detalle.nombre_arch = pNombreArchivo
			ORDER BY consecutivo ASC 
			
			LET cCuenta = SUBSTR(cCLABE,7,11);
			--- es esta seleccion se obtiene el nombre del beneficiario completo en base a la CLABE para obtener los datos reales de la cuenta  nvl(h.sdo_actual, 0),
			SELECT TRIM(NVL(cte.nombre1, '')) || ' ' || TRIM(NVL(cte.nombre2, '')), TRIM(NVL(cte.apell_paterno, '')), TRIM(NVL(cte.apell_materno, ''))
			INTO cNombreBeneficiario,cApellidoPaternoBeneficiario,cApellidoMaternoBeneficiario
			FROM bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
			WHERE mae.empresa = '001' AND mae.cuenta = cCuenta;
			---si la CLABE no es valida retorna puros valores nulos en el nombre del beneficiario!!
			IF ( cNombreBeneficiario IS NULL) OR  ( cApellidoPaternoBeneficiario IS NULL) OR ( cApellidoMaternoBeneficiario IS NULL)THEN
				LET cNombreBeneficiario = '  ';
				LET cApellidoPaternoBeneficiario = '  ';
				LET cApellidoMaternoBeneficiario = '  ';
			END IF;
			--sele quitaran el signo y los decimales a las variables money ademas de llenarlo con 0 al la izquierda   --lpad(Day(dFecha_Hoy),2,'0')
			LET cRellen = LPAD(mImporteDocumentoNetoPagar,15,'0');
			LET cRellen1 = LPAD(mImporteDocumentoAntesImpuesto,15,'0');
			LET cRellen2 = LPAD(mImpuestoRetenido,11,'0');

			---se concatenan en una variable para mandar los a guardar
			LET cRenglon = 	cTipoRegistro || cNSS || cNombreBeneficiario || cApellidoPaternoBeneficiario || cApellidoMaternoBeneficiario || 
							cFormasPago || cCLABE ||cFechaCaptura|| cRellen  ||  cRellen1  || 
							 cRellen2 || cNumeroFolioServicio || cNumeroTienda || cTipoRetiro || cConsecutivoRetiro || 
							cCURP || cRFC || cStatus ||cFolio_suc || cFillerDetalle || cFinLinea;
			INSERT INTO bdiprog:pp_archtemp (columna)
			VALUES (cRenglon);			
			
			-- se obtienen los detalles que van en el archivo de salidoa---
		END FOREACH;
		
		--Datos de Sumario
		SELECT 
			LPAD(total_mov,9,'0'),tipo_reg,total_imp_neto * 100,total_imp_antimp * 100,total_imp_retenido * 100,imp_tot_efectivo * 100,imp_tot_deposito * 100,filler,fin_linea
		INTO 
			cNumeroTotalMovimientosContenidos, cTipoRegistro,mImporteTotalNeto, mImporteTotalAntesImpuesto, mImporteRetenido , mImporteTotalRetirosPagadosEfectivo, mImporteTotalRetirosPagadosDeposito, cFillerSumario, cFinLinea
		FROM bdiprog:pp_Sumario
		WHERE bdiprog:pp_Sumario.nombre_arch = pNombreArchivo;  
		
		--sele quitaran el signo y los decimales a las variables money ademas de llenarlo con 0 al la izquierda   --lpad(Day(dFecha_Hoy),2,'0')
		LET cRelleno = LPAD(mImporteTotalNeto,17,'0');
		LET cRelleno1 = LPAD(mImporteTotalAntesImpuesto,17,'0');
		LET cRelleno2 = LPAD(mImporteRetenido,17,'0');
		LET cRelleno3 = LPAD(mImporteTotalRetirosPagadosEfectivo,17,'0');
		LET cRelleno4 = LPAD(mImporteTotalRetirosPagadosDeposito,17,'0');

		LET cRenglon = 	cTipoRegistro || cNumeroTotalMovimientosContenidos || cRelleno || cRelleno1 || cRelleno2 || cRelleno3 || cRelleno4 || cFillerSumario || cFinLinea;

		INSERT INTO bdiprog:pp_archtemp (columna)
		VALUES (cRenglon);
		LET cError='1'; -- Termina carga de datos
		
	    /* _  */	---------Se Almacena toda la informacion en un archivo implementando un (UNLOAD)---------
		LET cSQL = ''; -- Genero archivo con Unload
		LET  cSQL = 'echo "UNLOAD TO '||TRIM(cRuta)||'temporal.unl ' ||
					' select columna from bdiprog:pp_archtemp order by num_serial;" > '||TRIM(cRuta)||'query2.sql';
		SYSTEM cSQL;
		LET cError='2'; -- Genero el archivo de comandos
		
		--LET cSQL = 'chmod 777 '||TRIM(cRuta)||'query2.sql';
		--SYSTEM cSQL;
		
		--LET cSQL = 'dbaccess bdiprog '||TRIM(cRuta)||'query2.sql'; --SE ACTIVA PARA DESARROLLO
		Let cSQL = '/ifxsif01/bin/dbaccess bdiprog '||TRIM(cRuta)||'query2.sql';
		System cSQL;
		LET cError='3'; -- Genero archivo con datos
		
		-- Le quita el ultimo | al archivo .txt y se renombra con estandar del nombre		
		LET cSQL = "sed 's/|$//g' "||TRIM(cRuta)||"temporal.unl > " ||
				TRIM(cRuta) || cNombreArchivoSalida;
		SYSTEM cSQL;
		LET cError='4'; -- Renombro archivo con datos
		
		--Se borra archivo temp una vez generado
		LET cSQL = 'rm -rf '||TRIM(cRuta)||'temporal.unl';
		SYSTEM cSQL;
		
		LET cSQL = 'rm -f '||TRIM(cRuta)||'query2.sql';
		SYSTEM cSQL;

		LET cError='5'; -- Termina Proceso
		
        -- Se dan permisos al archivo generado
	   
		LET cSQL = 'chmod 777 ' || TRIM(cRuta) || TRIM (cNombreArchivoSalida);
		SYSTEM cSQL ;
		LET cError='6'; -- Se dan permisos de acceso
		
		--Registrar el final del proceso en la tabla pp_proceso
		UPDATE bdiprog:pp_Procesos SET status = '2'
		WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy ;		
		
		--Obtiene parametros de encriptacion
		SELECT llave, ruta_origen, ruta_destino, ruta_originales, usuario
		INTO cLlave, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cUsuario
		FROM bdinteg:si_configura_pgp
		WHERE codigo = 'AFORE_01';
		
		LET cNombreArchivo = cNombreArchivoSalida;
		--Se encripta el archivo
		EXECUTE PROCEDURE bdiprog:"informix".sp_encriptaarchivo(cUsuario, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cNombreArchivo, cLlave)
		INTO cRetEncripcion, cMsgEncripcion;
		
		LET cError='7';
		
		IF cRetEncripcion <> '000000' THEN			
			LET cProceso1 = cProceso || '-' || cError;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso1,cNombreArchivo,cRetEncripcion,cMsgEncripcion,pUser_Insert,dFecha_Hoy,dhora);
		END IF;

		CALL sp_AforeGenerarArchivoCifrasControl(pNombreArchivo,pUser_Insert) Returning cCodRet;
		
		IF cCodRet = '00000' THEN
			-- al macenar en pp_arch_afore (status .01., y tipo de archivo .C.), 
			INSERT INTO bdiprog:pp_arch_afore (nombre_arch   ,tipo,fecha_generado,fecha_procesado,status,user_insert,fecha_insert)
			VALUES (cNombreArchivoSalida ,'C' ,dFecha_Hoy  ,dFecha_Hoy   ,'01'  ,pUser_Insert,dFecha_Hoy);		
			
		ELSE
			--Registrar el final del proceso en la tabla pp_proceso
			UPDATE bdiprog:pp_Procesos SET status = '1'
			WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy ;	
		END IF;
		
		RETURN cCodRet;
		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: El Objetivo de esta Sp es el de Generar un archivo con la confirmacion de los pagos que fueron aplicados y rechazados.', 
'..........................................................',
'Solicito : Armando Mercado',	
'AUTOR: CÃ©sar ValdÃ©z Figueroa',
'FECHA: 12 Mayo 2009',
'VERSION: 20090512',
'BD: BDIPROG',
'CAMBIOS: Este Sp se modifico para que guarde los errores no controlados en bitacora, ademas de que se aplica una multiplicacion * 100',
'         esto con el fin de obtener lo decimales solo que los redondeaba, por lo que la multiplicacion se realizo antes en un select',
'		  con el fin de eliminar ese detalle ',
'MODIFICO: CÃ©sar ValdÃ©z Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616', 
'CAMBIOS: Se agrego un order by consecutivo para generar el el archivo de confirmacion en el mismo orden que se recibio el archivo de pagos',
'FECHA: 15/Julio/2009',
'MODIFICO: Abigail Vasavilbazo CaÃ±edo',
'VERSION: 20090715';

CREATE PROCEDURE "informix".sp_aforegenerararchivocifrascontrol(pNombreArchivo CHAR(30),pUser_Insert CHAR(8))
	RETURNING CHAR(5);
-------------------------------------------------------------------------------------------------
------------------------------------GENERALES -----------------------------------------------
DEFINE cTipoRegistro 				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE iSqlErr              		INTEGER;
DEFINE cCodRet              		CHAR(5);
DEFINE dFecha_Hoy           		DATE;
Define cSQL                 		CHAR(200);
DEFINE cProceso						CHAR(10);
DEFINE cNombreArchivoSalida 		CHAR(30);
DEFINE cRenglon						CHAR(30);
DEFINE cStatus						CHAR(1);
-----------------------------------------------------
--Encabezado		
DEFINE cFechaGeneracion	CHAR(8);  
DEFINE cFechaMovimientos CHAR(8); 
--detalle
DEFINE cEstatus	CHAR(2);
DEFINE cNumeroMovimientos INTEGER;
DEFINE cMonto BIGINT;
--sumario
DEFINE cNumeroRegistrosDetalle INTEGER;
DEFINE cMontoGlobal BIGINT;
DEFINE iSuma BIGINT;
DEFINE iSuma2 INTEGER;
DEFINE iContRegDet INTEGER;
DEFINE dHora  datetime HOUR TO SECond;
DEFINE cRuta CHAR(20);
DEFINE cRelleno CHAR(10);
DEFINE cRelleno1 CHAR(12);
DEFINE cRelleno2 CHAR(2);
DEFINE cRelleno3 CHAR(4);
---------------------------ECRIPTACION---------------------------
DEFINE cRetEncripcion		CHAR(6);
DEFINE cMsgEncripcion		CHAR(100);
DEFINE cLlave				CHAR(200);
DEFINE cNombreArchivo		CHAR(50);
DEFINE cRutaArchivoOrigen	CHAR(100);
DEFINE cRutaArchivoDestino	CHAR(100);
DEFINE cRutaRespaldo		CHAR(100);
DEFINE cUsuario				CHAR(20);

-----------------------------------------------------
/*	01 Por aplicar
	02 Aplicado exitosamente
	03 Fondos insuficientes en la cuenta de Afore
	04 El nÃÂº de cuenta no existe en el sistema
	05 Cuenta bloqueada por mandato judicial
	06 Cuenta cancelada o bloqueada por peticiÃÂ³el cliente
	07 RFC incorrecto                             
*/

DEFINE cCodRetInterno CHAR(5);
DEFINE cMensaje CHAR(200);


LET cCodRetInterno = '00000';
LET cRelleno = '';
LET cRelleno1 = '';
LET cRelleno2 = '';
LET cRelleno3 = '';
LET cTipoRegistro = '';
LET cFinLinea = '';
LET iSqlErr = '';
LET cCodRet = '';
LET dFecha_Hoy = '';
LET cSQL = '';
LET cProceso = '';
LET cStatus = '';
LET cNombreArchivoSalida = '';
LET cRenglon = '';
------------------------------------------------------------------------
LET cFechaGeneracion	= '';  
LET cFechaMovimientos = ''; 
LET cEstatus	= '';
LET cNumeroMovimientos = '';
LET cMonto = '';
LET cNumeroRegistrosDetalle = '';
LET cMontoGlobal = '';
LET iSuma = '0';
LET iSuma2= '0';
LET iContRegDet = 0;
---------------------------ECRIPTACION---------------------------
LET cRetEncripcion = '';
LET cMsgEncripcion = '';
LET cLlave = '';
LET cNombreArchivo = '';
LET cRutaArchivoOrigen = '';
LET cRutaArchivoDestino = '';
LET cRutaRespaldo = '';
LET cUsuario = '';
------------------------------------------------------------------------
LET cRuta = '';
LET cSQL 		= '';
LET dFecha_Hoy 	= '';
LET cCodRet 	= "00000";
LET cProceso = 'AforGACC';
LET cStatus  = '1';
LET dhora = CURRENT HOUR TO SECOND;

	--set debug file to "/informix/josea/sp_AforeGenerarArchivoCifrasControl2.out";
	--Trace on;


BEGIN

		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
			-------Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			    VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		on exception in (-668)
			Let cCodRet = '10010';
			CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);
			RETURN cCodRet;
	    END exception with resume;	
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 	---se valida si se recivio el parametro          pUser_Insert
		IF TRIM(pUser_Insert) = '' THEN
			LET pUser_Insert = 'informix';
		END IF;
		LET dhora = CURRENT;
		/*---------------------ERRORES
			
			LET cCodRet = '10011';-- El Archivo ya fue procesado
			LET cCodRet = '10013';--No existe el archivo
			LET cCodRet = '10024';--mensaje de error ya que no se Ejecuto el proceso Anterior
		*/
		------------- Se  obtiene la fecha del sistema   
		SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;
		
		---------Se crea el nombre del proceso con el consecutivo 01------------------
		LET cProceso = 'AforGACC' || '01';
		--Crear el nombre del archivo con el consecutivo 01 		    
		LET cNombreArchivoSalida = 'CONT' || lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy)  || '.BCOPPEL.01';
		--por si no  me envian el nombre del archivo
		IF TRIM(pNombreArchivo) <> '' THEN-- Hay que tomar el consecutivo del nombre del archivo
			LET cProceso = 'AforGACC' || SUBSTR(pNombreArchivo,23,2);
			LET cNombreArchivoSalida = 'CONT' || lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy)  || '.BCOPPEL.'||SUBSTR(pNombreArchivo,23,2);
		END IF;
			------------- Validar  que ya este Ejecutado el proceso de Generacionde Archivo de Confirmacion y concluido satisfactoriamente.
		IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = ('AforeGAC'|| SUBSTR(pNombreArchivo,23,2)) AND pp_Procesos.fech_proceso = dFecha_Hoy and  pp_Procesos.status = '2') THEN
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------Validar si ya se ejecuto el proceso de Generar Archivo De Cifras De Control
			IF EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy) THEN
				SELECT status INTO cStatus FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy;
				IF cStatus != '1' THEN--El Archivo ya fue procesado
					--- el estatus es  02
					LET cCodRet = '10011';
					CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
					INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
					VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);		
					RETURN cCodRet;
				END IF;
			ELSE
				--- guardar el inicio del proceso y se ejecuta
				INSERT INTO bdiprog:pp_Procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
				VALUES (cProceso,dFecha_hoy,cStatus,pUser_Insert,dFecha_Hoy);		
			END IF;
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ELSE
			--- mensaje de error ya que se devio haber Ejecutado el proceso de Generacion de archivos de control
				LET cCodRet = '10024';
				CALL sp_Afore_MensajeRetorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUser_Insert,dFecha_Hoy,dhora);	
				RETURN cCodRet;
		END IF;

		--------
		DELETE FROM pp_archcifras;
		--o	Se leerÃÂ¡e la tabla de parÃÂ¡tros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, nÃÂº de contrato, etc.).
		select valor into cRuta from  bdiprog:pp_Parametros where cve_param = '100';
		
		--datos del encabezado
		LET cTipoRegistro = 'E';
		LET cFechaGeneracion = lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy);
		LET cFechaMovimientos = lpad(Day(dFecha_Hoy),2,'0') || lpad(Month(dFecha_Hoy),2,'0') || Year(dFecha_Hoy);
		
		LET cRenglon = cTipoRegistro || cFechaGeneracion || cFechaMovimientos;
		
		INSERT INTO bdiprog:pp_archcifras (columna)
		VALUES (cRenglon);			
		
		--se obtienen los datos de Detalle
		IF EXISTS (SELECT status FROM pp_detalle WHERE pp_detalle.nombre_arch  = pNombreArchivo) THEN
			FOREACH
				Select distinct(status), count(status), sum(imp_netopagar * 100)
				Into cEstatus,cNumeroMovimientos,cMonto
				From bdiprog:pp_detalle
				Where bdiprog:pp_detalle.nombre_arch  = pNombreArchivo
				Group by status		
				
				LET cTipoRegistro = 'D';
				LET cRelleno = lpad(cMonto,10,'0');
				LET cRelleno3 =  lpad(cNumeroMovimientos,4,'0');
				LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cRelleno3 || cRelleno;
				
				INSERT INTO bdiprog:pp_archcifras (columna)
				VALUES (cRenglon);		
			
				LET iSuma = iSuma + cMonto;
				LET iSuma2 = iSuma2 + cNumeroMovimientos;
				LET iContRegDet = iContRegDet + 1;
			END FOREACH;
		ELSE
				LET cTipoRegistro = 'D';
				LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cNumeroMovimientos || cMonto;
				
				INSERT INTO bdiprog:pp_archcifras (columna)
				VALUES (cRenglon);	
		END IF
		-- se obtienen lo datos del sumario
		LET cTipoRegistro = 'S';
		LET cMontoGlobal = iSuma;
		LET cRelleno1 = lpad(cMontoGlobal,12,'0');
		LET cNumeroRegistrosDetalle = iContRegDet;
		LET cRelleno2 = LPAD(cNumeroRegistrosDetalle,2,'0');
		LET cRenglon = cTipoRegistro || cRelleno2 || cRelleno1;
			
		INSERT INTO bdiprog:pp_archcifras (columna)
		VALUES (cRenglon);		
		
	    /* _  */	---------Se Almacena toda la informacion en un archivo implementando un (UNLOAD)---------
				
		LET cSQL = ''; -- Genero archivo con Unload
		LET  cSQL = 'echo "UNLOAD TO '||TRIM(cRuta)||'temporal.unl ' ||
					'select columna from pp_archcifras; " > '||TRIM(cRuta)||'query3.sql';						
		SYSTEM cSQL;
		
		--LET cSQL = 'chmod 777 '||TRIM(cRuta)||'query3.sql';
		--SYSTEM cSQL;
		
		-- Ejecuto el unload
		--LET cSQL = 'dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; --Se activa para desarrollo   
		LET cSQL = '/ifxsif01/bin/dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; --Se activa para Produccion 
		SYSTEM cSQL;

		-- Le quita el ultimo | al archivo .txt y se renombra con estandar del nombre
		LET cSQL = "sed 's/|$//g' "||TRIM(cRuta)||"temporal.unl > " 
			 || TRIM(cRuta) || cNombreArchivoSalida;
		SYSTEM cSQL;

		--Se borra archivo temp una vez generado
		LET cSQL = 'rm -rf '||TRIM(cRuta)||'temporal.unl';
		SYSTEM cSQL;
		
		LET cSQL = 'rm -f '||TRIM(cRuta)||'query3.sql';
		SYSTEM cSQL;

        -- Se dan permisos al archivo generado
		LET cSQL = 'chmod 777 ' || TRIM(cRuta) || TRIM (cNombreArchivoSalida);
		SYSTEM cSQL ;
			
		-- Almacenar en pp_arch_afore (status .01., y tipo de archivo .T.), 
		INSERT INTO bdiprog:pp_arch_afore (nombre_arch   ,tipo,fecha_generado,fecha_procesado,status,user_insert,fecha_insert)
		VALUES (cNombreArchivoSalida ,'T' ,dFecha_Hoy,dFecha_Hoy,'01'  ,pUser_Insert,dFecha_Hoy);		
		--Registrar el final del proceso en la tabla pp_proceso
		UPDATE bdiprog:pp_Procesos SET status = '2'
		WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFecha_Hoy ;
		
		--Obtiene parametros de encriptacion
		SELECT llave, ruta_origen, ruta_destino, ruta_originales, usuario
		INTO cLlave, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cUsuario
		FROM bdinteg:si_configura_pgp
		WHERE codigo = 'AFORE_02';
		
		LET cNombreArchivo = cNombreArchivoSalida;
		--Se encripta el archivo		
		EXECUTE PROCEDURE bdiprog:"informix".sp_encriptaarchivo(cUsuario, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cNombreArchivo, cLlave)
		INTO cRetEncripcion, cMsgEncripcion;
		
		IF cRetEncripcion <> '000000' THEN
			INSERT INTO bdiprog:pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,cNombreArchivo,cRetEncripcion,cMsgEncripcion,pUser_Insert,dFecha_Hoy,dhora);
		END IF;
		
		RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: el objetivo de este Sp es el de Generar un archivo del total de pagos procesados.', 
'..........................................................',
'Solicito : Armando Mercado',	
'AUTOR: CÃÂ©r ValdÃÂ©Figueroa',
'FECHA: Mayo 2009',
'VERSION: 200905',
'BD: BDIPROG',
'CAMBIOS: Este Sp se modifico para que guarde los errores no controlados en bitacora, ademas de que se aplica una multiplicacion * 100',
'         esto con el fin de obtener lo decimales solo que los redondeaba, por lo que la multiplicacion se realizo antes en un select',
'		  con el fin de eliminar ese detalle. ',
'MODIFICO: CÃÂ©sar ValdÃÂ©z Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616';

CREATE PROCEDURE "informix".sp_obt_cant_reg_referencias_bex(pNumCliente char(20), pCveCuenta char(2),pCveBanco char(3))
        RETURNING char(5), integer;

       DEFINE vcodret   char(5);
       DEFINE vCantidad  integer;
       DEFINE sql_err       integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '00000';
LET vCantidad = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;

BEGIN
	SELECT COUNT(cuenta) AS cantidad
	INTO vCantidad
	FROM bdiprog:pp_ctasterceros_bex
	WHERE num_cte=TRIM(pNumCliente)
	AND cve_banco=TRIM(pCveBanco)
	AND cve_cuenta=TRIM(pCveCuenta)
	AND cve_estado='01';
	--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00';

    RETURN vcodret, vCantidad;
END;

END PROCEDURE;