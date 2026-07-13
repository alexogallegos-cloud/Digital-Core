CREATE PROCEDURE "informix".sp_ope_cons_ticketabonovent(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(3) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoVent.out';
		--TRACE ON;

		--SET DEBUG FILE TO '/informix/ENP/TicketDigital/Febrero/out/sp_ope_cons_ticketabonovent.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
		
		SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END , TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, c.cuenta, c.num_tarjeta, f.numcte
		INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNumcliente
		FROM bdisac:"informix".sac_movimientoshistorial AS a
		INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio 
		INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc
		INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta
		LEFT JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
		WHERE b.numcategoria = '07' AND a.forma_pago = '4' AND c.sucursal NOT IN ('9250','9764') 
		AND d.num_cte = pNumCliente AND a.referencia1 = pReferencia;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		ELSE
		
		SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
		TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
		INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
		FROM bdisac:"informix".sac_pld_remesas
		WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			
		SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND estado = 'A';

		SELECT dmapa 
			INTO cCadenaTran
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND secuencia = cSecuenciaMax;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCadenaTran = '';
		END IF;

		SELECT nombre, plaza 
		INTO cNomSucursal, cPlaza 
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = cSucursal;
		
		SELECT nombre 
		INTO cNomPlaza 
		FROM bdinteg:"informix".si_plazas
		WHERE plaza = cPlaza;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cNomPlaza = '';
		END IF;
			
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			
			EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
			INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
			cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
				
			LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
						
		END IF;
			
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Abono por Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_generareptxtremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pRuta CHAR(100),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClaveId CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS archivo_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreArchivo CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	--LET cRutaInformix = '/informix/bin/';
	LET cRutaInformix  = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iRecuperacion = 0;
	LET cNombreArchivo = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				RETURN cCodRet,cNombreArchivo;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generareptxtremesasnopagadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pRuta = '' OR 
		pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pClaveId IS NULL THEN
			LET cCodRet = '00003';
			
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE
		LET pRuta = TRIM(pRuta) || '/';
		
		IF pIdLimite = 1 THEN
			LET cReporte = 'REMESASNOPAGADAS_ESTADO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 2 THEN
			LET cReporte = 'REMESASNOPAGADAS_SUCURSAL';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 3 THEN
			LET cReporte = 'REMESASNOPAGADAS_TRANSACCIONES';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 4 THEN
			LET cReporte = 'REMESASNOPAGADAS_MDIARIO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 5 THEN
			LET cReporte = 'REMESASNOPAGADAS_MMENSUAL';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 6 THEN
			LET cReporte = 'REMESASNOPAGADAS_ACUMULADO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 7 THEN
			LET cReporte = 'REMESASNOPAGADAS_LISTAS';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 8 THEN
			LET cReporte = 'REMESASNOPAGADAS_TODOS';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		END IF;
		
		LET cNombreArchivo = TRIM(cReporte)||'.txt';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			IF pIdLimite IN (1,2,3,4,5,6,7) THEN
				
				LET cCmd1 ="";
				LET cCmd1 = "SELECT 'TIPO LÍMITE','FECHA ENVÍO','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','PAÍS',";	
				LET cCmd1 =""||TRIM(cCmd1)||"'TIPO','NÚMERO','CIUDAD','PAÍS','MONEDA ORDENANTE','MONTO ORIGEN','MONTO EN PESOS','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO',";
				LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','TELÉFONO','TIPO ID','NÚMERO ID','SUCURSAL'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM (SELECT limite,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,";
				LET cCmd1 =""||TRIM(cCmd1)||"tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,SUBSTR(monto_origen, 1, CHARINDEX('.', monto_origen) + 2),SUBSTR(monto_pesos, 1, CHARINDEX('.', monto_pesos) + 2),nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,";	
				LET cCmd1 =""||TRIM(cCmd1)||"SUBSTR(fechanacimiento_ben,7,2)||'/'||SUBSTR(fechanacimiento_ben,5,2)||'/'||SUBSTR(fechanacimiento_ben,1,4),direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detalleremesasnopagadas";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_limite = (CASE WHEN "||pIdLimite||" IS NULL THEN id_limite ELSE "||pIdLimite||" END)";
				LET cCmd1 =""||TRIM(cCmd1)||" AND fecha_env BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND usuario_insert = '"||pUsuario||"' AND clave_id = '"||TRIM(pClaveId)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY 1,2 ASC)";
				
			ELIF pIdLimite = 8 THEN
			
				LET cCmd1 ="";
				LET cCmd1 = "SELECT 'TIPO LÍMITE','FECHA ENVÍO','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','PAÍS',";	
				LET cCmd1 =""||TRIM(cCmd1)||"'TIPO','NÚMERO','CIUDAD','PAÍS','MONEDA ORDENANTE','MONTO ORIGEN','MONTO EN PESOS','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO',";
				LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','TELÉFONO','TIPO ID','NÚMERO ID','SUCURSAL'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM (SELECT limite,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,";
				LET cCmd1 =""||TRIM(cCmd1)||"tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,SUBSTR(monto_origen, 1, CHARINDEX('.', monto_origen) + 2),SUBSTR(monto_pesos, 1, CHARINDEX('.', monto_pesos) + 2),nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,";	
				LET cCmd1 =""||TRIM(cCmd1)||"SUBSTR(fechanacimiento_ben,7,2)||'/'||SUBSTR(fechanacimiento_ben,5,2)||'/'||SUBSTR(fechanacimiento_ben,1,4),direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detalleremesasnopagadas";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_env BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND usuario_insert = '"||pUsuario||"' AND clave_id = '"||TRIM(pClaveId)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY 1,2 ASC)";
				
			END IF;
			
			LET cSql = '';
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = 'rm -rf '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			--LET cSql = '';
			--LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			--SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador '\t'.
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Se renombra el archivo temporal por el nombre original
			LET cSql = '';
			LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/01/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de generar los reportes txt de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketefectivovent(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(20) AS cuenta,
				CHAR(16) AS tarjeta,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	DEFINE cRetorno3 CHAR(150);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cCuenta VARCHAR(20);
	DEFINE cTarjeta VARCHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketEfectivoVent.out';
		--TRACE ON;
		--SET DEBUG FILE TO '/informix/ENP/TicketDigital/Febrero/out/sp_ope_cons_ticketefectivovent.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
			END IF;
		
		
			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
			WHERE b.numcategoria = '07' 
			--AND forma_pago='1'
			AND a.referencia1 = pReferencia;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet= '00017';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;

					ELSE
						IF
					--/////////WESTERN UNION/////////--
							cNumConvenio = '006' OR cNumConvenio = '007' OR cNumConvenio = '008'  THEN

							SELECT
								wu.benef_nombre1,
								wu.benef_nombre2,
								wu.benef_appaterno,
								wu.benef_apmaterno,
								wu.benef_id_number,
								wu.numcte,
								TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
								TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  
							FROM
								bdisac:"informix".sac_wu_pay AS wu 
									INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
									ON wu.mtcn = pld.num_confirmacion AND
									wu.foreign_rs_refnum_rp= pld.folio_sucursal 
							WHERE
								wu.mtcn= cReferencia AND
								wu.foreign_rs_refnum_rp =cFolioSuc;

							--/////////si los datos vienen vacios se consulta los datos en las tablas QRY--
							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
								TRIM(cRetorno3) 	IS NULL THEN
									
								SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									wu.numcte,
									TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
									TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

								FROM
									bdisac:"informix".sac_wu_pay AS wu 
										INNER JOIN bdisac:"informix".sac_wu_search AS s 
										ON wu.mtcn = s.mtcn --num remesa
										
								WHERE
									s.mtcn = cReferencia AND
									s.foreign_rs_refnum_rp = cFolioSuc;
							END IF;


							--/////////BTS/////////--
							ELIF cNumConvenio = '004' THEN

								SELECT
									bts.r_first_name,
									bts.r_middle_name,
									bts.r_last_name,
									bts.r_mother_m_name,
									bts.r_identif_nm,
									bts.numcte,
									TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
									TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3

								FROM
									bdisac:"informix".sac_bts_payi AS bts 
										INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
										ON bts.confirmation_nm = pld.num_confirmacion AND
										bts.bank_ref_nm = pld.folio_sucursal 
								WHERE
									bts.confirmation_nm= cReferencia AND
									bts.bank_ref_nm= cFolioSuc;

								-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
									TRIM(cRetorno3) 	IS NULL THEN
									
									SELECT
										bts.r_first_name,
										bts.r_middle_name,
										bts.r_last_name,
										bts.r_mother_m_name,
										bts.r_identif_nm,
										bts.numcte,
										TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
										TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)

									INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

									FROM
										bdisac:"informix".sac_bts_payi AS bts 
											INNER JOIN bdisac:"informix".sac_bts_qryi AS s 
											ON bts.confirmation_nm = s.confirmation_nm --num remesa
											
									WHERE
										bts.confirmation_nm = cReferencia AND
										bts.bank_ref_nm= cFolioSuc;
								END IF;

									--/////////APPRIZA/////////--
									ELIF cNumConvenio = '009' THEN
										SELECT
											app.firstname,
											app.middlename,
											app.lastname,
											app.mommaidenname,
											app.numberci,
											app.numcte,
											TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
											TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 

										INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3

										FROM
											bdisac:"informix".sac_app_payi AS app 
												INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
												ON app.unirefnum = pld.num_confirmacion AND
												app.refnum = pld.folio_sucursal 
										WHERE
											app.unirefnum = cReferencia AND
											app.refnum=cFolioSuc;
							
										-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
										IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
											TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
											TRIM(cRetorno3) 	IS NULL THEN
											
											SELECT
												app.firstname,
												app.middlename,
												app.lastname,
												app.mommaidenname,
												app.numberci,
												app.numcte,
												TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
												TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)

											INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

											FROM
												bdisac:"informix".sac_app_payi AS app 
													INNER JOIN bdisac:"informix".sac_app_qryi AS s 
													ON app.unirefnum = s.unirefnum 
													
											WHERE
												s.unirefnum = cReferencia AND
												app.refnum = cFolioSuc;
										END IF;

					END IF;
					/*SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, numero_de_cliente_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; */
				
					SELECT MAX(secuencia) 
						INTO cSecuenciaMax 
					FROM bdinteg:"informix".si_cte_huella 
					WHERE numcte = cNumcliente
					AND estado = 'A';

					SELECT dmapa 
					INTO cCadenaTran
					FROM bdinteg:"informix".si_cte_huella 
					WHERE numcte = cNumcliente
					AND secuencia = cSecuenciaMax;
							
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCadenaTran = '';
						END IF;

							SELECT nombre, plaza 
								INTO cNomSucursal, cPlaza 
							FROM bdinteg:"informix".si_sucursales
							WHERE sucursal = cSucursal;
								
							SELECT nombre 
								INTO cNomPlaza 
							FROM bdinteg:"informix".si_plazas
							WHERE plaza = cPlaza;
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cNomPlaza = '';
							END IF;
						
								IF DBINFO('sqlca.sqlerrd2') > 0 THEN
									EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
									INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
									cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;	
									LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
										
								END IF;
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, 
								cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal,cNombre1Ben, cNombre2Ben, cApPaternoBen,
								cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, 
								cTarjeta, cRetorno3;
				END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Efevtico Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_actualizactas(pUsuario CHAR(8), pIdFuncion CHAR(10), pId INTEGER)
                RETURNING CHAR(5) AS codret;          
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;  
		DEFINE cNombre CHAR(45);

        LET cCodRet = '00000';
        LET iSqlErr = 0; 
		LET cNombre = '';

        BEGIN   
                ON EXCEPTION SET iSqlErr
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ac_actualizactas.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pId = '' THEN
                    LET cCodRet = '00003';
					RETURN cCodRet;
                END IF;
				
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
					IF cCodRet <> '00000' THEN
					RETURN cCodRet;
				END IF;
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;

				UPDATE bdicheq:"informix".sc_cuentas_retiro SET estatus = 'R',no_empleado =pUsuario WHERE rowid = pId;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
				LET cCodRet = '-0001';
				END IF;

		RETURN cCodRet;
		
        END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de actualizar la tabla sc_cuentas_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_busquedacuentas(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATE,pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
						  CHAR(20) AS cuenta,
						  MONEY(18,2) AS sdo_calculado,
						  MONEY(18,2) AS sdo_actual,
						  INTEGER AS id,
						  MONEY(18,2) AS sdo_incial, 
						  MONEY(18,2) AS retiro, 
						  MONEY(18,2) AS deposito,
						  CHAR(10) AS tipoReporte;
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;   
		DEFINE cCuenta CHAR(20);
		DEFINE mSdoCalc MONEY(18,2);
		DEFINE mSdoAct MONEY(18,2);
		DEFINE iRecuperacion INTEGER;
		DEFINE iId INTEGER;
		DEFINE mRetiro MONEY(18,2);
		DEFINE mDeposito MONEY(18,2);
		DEFINE cTipoReporte CHAR(10);
		DEFINE mSdoInicial MONEY(18,2);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;  
		LET cCuenta = '';
		LET mSdoCalc = '';
		LET mSdoAct = 0;
		LET iRecuperacion = 0;
		LET iId = 0;
		LET mRetiro = 0;
		LET mDeposito = 0;
		LET cTipoReporte = '';
		LET mSdoInicial = 0;

    BEGIN   
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END EXCEPTION;
			
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ac_busquedacuentas.out';
		-- TRACE ON;
			
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha ='' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;
			
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			a.cuenta, a.saldo_calculado, a.saldo_actual, a.rowid, b.sdo_dia_ant
			INTO cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial
			FROM bdicheq:"informix".sc_cuentas_retiro AS a
			INNER JOIN bdicheq:"informix".sc_maechq AS b ON b.cuenta = a.cuenta 
			WHERE a.fecha = pFecha AND a.estatus ='A'
			ORDER BY cuenta
			
			SELECT NVL(SUM(monto_tot), 0) 
			INTO mRetiro 
			FROM bdicheq:"informix".sc_movdia, bdinteg:"informix".si_transacc
			WHERE cuenta = cCuenta
			AND naturaleza = 'C'
			AND se_contabiliza = 'S'
			AND transacc = numero
			AND sistema = '01'
			AND fech_alt = pFecha
			AND cancelad <> 'S'
			AND transacc <> '0232';
			
			SELECT NVL(SUM(monto_tot), 0) 
			INTO mDeposito 
			FROM bdicheq:"informix".sc_movdia, bdinteg:"informix".si_transacc
			WHERE cuenta = cCuenta
			AND naturaleza = 'A'
			AND se_contabiliza = 'S'
			AND transacc = numero
			AND sistema = '01'
			AND fech_alt = pFecha
			AND cancelad <> 'S'; 
   
			LET cTipoReporte = 'RETIRO';
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte WITH RESUME;
			
		END FOREACH;
		
		LET cTipoReporte = '';
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01279'; 
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;	


    END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de consultar datos de la tabla sc_cuentas_retiro',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Se modifica SP para agregar los siguientes retornos, saldo inicial, retiros, depositos, tipo reporte',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_busquedacuentas_total(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
                RETURNING CHAR(5) AS codret,
						  INTEGER AS total;
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;   
		DEFINE iTotal INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;  
		LET iTotal = 0;
		
        BEGIN   
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotal;
		END EXCEPTION;
			
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ac_busquedacuentas_total.out';
		-- TRACE ON;
			
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotal;
		END IF;
			
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		
		SELECT COUNT(*) INTO iTotal			
		FROM bdicheq:"informix".sc_cuentas_retiro AS a
		INNER JOIN bdicheq:"informix".sc_maechq AS b ON b.cuenta = a.cuenta 
		WHERE a.fecha = pFecha AND a.estatus ='A';

		IF iTotal = 0 THEN 
			LET cCodRet ='01279';
		END IF;
	
		RETURN cCodRet,iTotal;
		
        END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de consultar datos de la tabla sc_cuentas_retiro',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Se modifica SP para agrega la relaciÃ³n a la tabla sc_maechq',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_desbloquoctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaDesb DATE)
                RETURNING CHAR(5) AS codret,
						  char(5) AS clave;          
						  
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;  
	DEFINE cCodRetSp CHAR(3);
	DEFINE cNombre CHAR(45);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(5);

    LET cCodRet = '00000';
    LET iSqlErr = 0; 
	LET cCodRetSp = '';
	LET cNombre = '';
	LET cEmpresa = '001';
	LET cClave = '';

    BEGIN   
        ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cClave;
        END EXCEPTION;
                
        --SET DEBUG FILE TO '/tmp/mfinis/sp_ac_desbloquoctas.out';
        --TRACE ON;
                
        IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, cClave;
        END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave;
		END IF;
               
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(cEmpresa, pCuenta, '0', '00', 0, pFechaDesb, pUsuario, '', '', '', '', '')
		INTO cCodRetSp, cClave;
		
		IF cCodRetSp <> '000' THEN
            LET cCodRet = '99999';
        END IF;
		
		RETURN cCodRet, cClave;
		
    END;
END PROCEDURE
DOCUMENT 
'AUTOR: VerÃ³nica SÃ¡nchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Sp encargado de realizar el desbloqueo de cuentas revisadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pFechaIni DATE,pFechaFin DATE, pProducto CHAR(4))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS total;

	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cCodRetSP CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
	DEFINE cNumCredito CHAR(20);
    DEFINE cCodTipCred CHAR(2);
	DEFINE cDescStatusCred CHAR(60);     
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPlazoAux INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);        
	DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
	DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cCodFun CHAR(3);
	DEFINE cDescripcion CHAR(100);
	DEFINE cInfReceptor CHAR(40);
	DEFINE cReferencia CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE cStatus CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumPago CHAR(5);
	DEFINE cPlazo CHAR(5);
    DEFINE dMontoAux DECIMAL(18,2);	
	DEFINE cStat CHAR(2);
	DEFINE cNumSol CHAR(20);
    DEFINE cCab CHAR(1);
    DEFINE cNumCred CHAR(20);
	DEFINE iProd INTEGER;
	DEFINE cTipoConsulta CHAR(4);
    DEFINE cSol CHAR(20);
    DEFINE iAuxCab INTEGER;
	DEFINE cTarjetaAux CHAR(16);
	DEFINE iCancelado INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP ='';
    LET cMensajeRet ='';
	LET cNumCredito ='';
    LET cCodTipCred ='';
	LET cDescStatusCred ='';   
    LET iIdUnidadProd =0;
    LET cCodCaract2 ='';
    LET dtFechaOrigen ='';
    LET dtFechaProxPago ='';
    LET dPagoMinimo =0;
    LET dtFechaUltPago ='';
    LET iPlazo =0;
    LET iPlazoAux = 0;
    LET iPagosRealizados =0;
    LET dLineaOtorgada =0;
    LET dTasaInteres =0;
    LET dTasaMoratorios =0;
    LET dMontoSBC =0;
    LET dCapVig  =0;
    LET dCapTrans  =0;
    LET dCapVdoExig  =0;
    LET dCapVdoNoExig  =0;
    LET dSdoActCap  =0;        
	LET dIntVdo  =0;
    LET dIntMoratorio  =0;
    LET dIntMes  =0;
    LET dSdoActInt  =0;    
	LET dIntVig  =0;
    LET dIvaIntVig  =0;
    LET dIvaIntVdo  =0;
    LET dIvaIntMoratorio  =0;
    LET dIvaIntMes  =0;
    LET dSdoActIvaInt  =0;    
    LET dComPend  =0;
    LET dIvaCom  =0;
    LET dSdoRetenido  =0;
    LET dSdoTotalLiq  =0;    
    LET dIntDevengado  =0;
    LET dIvaIntDevengado  =0;
    LET dLineaDisponible  =0;
    LET dPagosVdos  =0;
    LET cDescBloqueoCta ='';
    LET cDescCausaBloqueoCta ='';
    LET cSitCte ='';
    LET cCausaCte =0;
    LET cDescSitEspCte ='';
    LET cSitCred ='';
    LET cCausaCred =0;
    LET cDescSitEspCred ='';
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cHora ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cCodFun ='';
	LET cDescripcion ='';
	LET cInfReceptor ='';
	LET cReferencia ='';
	LET dMontoOtorgado  =0;
	LET cStatus ='';
	LET iNoRegistros =0;
	LET cNumPago='';
	LET cPlazo ='';
    LET dMontoAux = 0;
	LET cStat ='';
	LET cNumSol ='';
    LET cCab='';
    LET cNumCred='';
	LET iProd = 0;
	LET cTipoConsulta ='';
    LET cSol = '';
    LET iAuxCab =0;
	LET cTarjetaAux = '';
	LET iCancelado = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				UPDATE "informix".sw_verificastatusconsmsi
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
				RETURN cCodRet, iNoRegistros;
				
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Daniel/sp_msi_consultamsi_totales.out';
		--TRACE ON;

 
		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pFechaIni = '' OR pFechaFin='' THEN
				LET cCodRet = '00003';
				UPDATE "informix".sw_verificastatusconsmsi
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusconsmsi
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			     
			 RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		 -- SE LIMPIA TABLA POR USUARIO
         
        DELETE FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario;
		DELETE FROM "informix".sw_verificastatusconsmsi
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusconsmsi(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error,total) 
		VALUES(pUsuario,'','I','','LECTURA','',0);
		
		SELECT COUNT(*) INTO iProd FROM bdicred:"informix".sd_definicion WHERE edocta_param= 'tdc' and num_producto=pProducto;
		
		LET  cTipoConsulta = SUBSTR(pNumCred,1,4);
		
		IF  iProd = 0 AND cTipoConsulta='8900' THEN --Busca por promo msi 
		
		
		SELECT /*{+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)}*/ fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = pNumCred INTO TEMP sd_movdiacrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}*/  num_tarjeta,num_sol_prestamo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE empresa = '001' AND num_sol_prestamo= pNumCred and num_pro_prestamo = '8900'  INTO TEMP sd_promocion_credito_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}*/  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= pNumCred INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maecredcrd idx_maecrd)}*/ status_cred,num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_credito= pNumCred INTO TEMP sd_maecredcrd_temp with no log;

		SELECT /*{+INDEX(bdicred:sd_movhiscrd idx_movhiscrd2)}*/  fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = pNumCred INTO TEMP sd_movhiscrd_temp with no log;

		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
				b.num_tarjeta  		from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				UNION 
				select b.num_tarjeta  		from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
			)
				group by num_tarjeta


			FOREACH WITH HOLD 
					SELECT 
				 * 
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cStatus,cStat,cNumSol,cNumCred
				FROM
				(select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
		
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
				b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

				UNION 
				select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
                b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred 

				)
				
				IF cStat = 'FF' THEN 
				
				select count(*) INTO iCancelado from bdicred:"informix".sd_msi_cancela_credito_msi where num_credito = cSol;
				
					IF iCancelado > 0 THEN 
						LET cStatus ='CANCELADO';
					ELSE 
						LET cStatus ='LIQUIDADO';
					END IF;
				END IF;		

				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cNumSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select  capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito = cNumSol AND fecha_cuota = cFecha ORDER BY fecha_cuota);

				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
                IF iAuxCab =0 THEN --Se asigna el primer registro encontrado como encabezado  
                    LET cCab ='C';
                    LET iNoRegistros = iNoRegistros + 1;
                    LET iAuxCab = iAuxCab+1;
                ELSE
                    LET cCab ='D';
                END IF;

                LET cPlazo = TRIM(cNumPago) ||'/'|| TRIM(iPlazoAux::CHAR(5));

				INSERT INTO "informix".sw_msi_consultagrid(usuario, fecha, hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave,id) 
				VALUES(pUsuario,cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iNoRegistros,cCab);

			END FOREACH;
		END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_maecredcrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		
		ELIF iProd = 1 THEN --Busca por num_credito todas las promociones de msi asociadas

        FOREACH 
        select num_sol_prestamo INTO cSol FROM bdicred:"informix".sd_promocion_credito 
        WHERE num_credito =pNumCred AND num_pro_prestamo = '8900'
		
		SELECT /*{+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)}*/ fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE  reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = cSol INTO TEMP sd_movdiacrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}*/  num_tarjeta,num_sol_prestamo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= cSol INTO TEMP sd_promocion_credito_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}*/  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= cSol INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maecredcrd idx_maecrd)}*/ status_cred,num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_credito= cSol INTO TEMP sd_maecredcrd_temp with no log;

		SELECT /*{+INDEX(bdicred:sd_movhiscrd idx_movhiscrd2)}*/  fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = cSol INTO TEMP sd_movhiscrd_temp with no log;	
		
        LET iAuxCab =0;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
					
				b.num_tarjeta  		from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				UNION 
				select b.num_tarjeta  		from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta
		
		
		FOREACH WITH HOLD 
				SELECT 
				 * 
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cStatus,cStat,cNumSol,cNumCred
				FROM
				(select  
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
				b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select /*{+INDEX(intercard:movimiento idx_movimientonew1a)}*/  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

				UNION 
				select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
                b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select /*{+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}*/   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

			)
				
				IF cStat = 'FF' THEN 
				
				select count(*) INTO iCancelado from bdicred:"informix".sd_msi_cancela_credito_msi where num_credito = cSol;
				
					IF iCancelado > 0 THEN 
						LET cStatus ='CANCELADO';
					ELSE 
						LET cStatus ='LIQUIDADO';
					END IF;
				END IF;		


				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select  capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito = cSol AND fecha_cuota = cFecha ORDER BY fecha_cuota);

				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;

                IF iAuxCab =0 THEN --Se asigna el primer registro como encabezado  
                    LET cCab ='C';
                    LET iNoRegistros = iNoRegistros + 1;
                    LET iAuxCab = iAuxCab+1;
                ELSE
                    LET cCab ='D';
                END IF;

                LET cPlazo = TRIM(cNumPago) ||'/'|| TRIM(iPlazoAux::CHAR(5));

				INSERT INTO "informix".sw_msi_consultagrid(usuario, fecha, hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave,id) 
				VALUES(pUsuario,cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iNoRegistros,cCab);
				
				
		END FOREACH;
    
        END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_maecredcrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
	
		END FOREACH;
		
		ELSE  
			LET cCodRet ='01276';	
			UPDATE "informix".sw_verificastatusconsmsi
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';		
			RETURN cCodRet, iNoRegistros;
		
		END IF;
	
		SELECT COUNT(*) INTO iNoRegistros FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario and id='C';
		
		IF iNoRegistros = 0 THEN			
			LET cCodRet ='01276';	
			UPDATE "informix".sw_verificastatusconsmsi
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';		
			RETURN cCodRet, iNoRegistros;
		END IF;
		
	    UPDATE "informix".sw_verificastatusconsmsi 
		SET  status = 'T', error_proceso = 'N', total = iNoRegistros
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsicancel_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pProducto CHAR(4))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS total;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSP CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
	DEFINE cNumCredito CHAR(20);
    DEFINE cCodTipCred CHAR(2);
	DEFINE cDescStatusCred CHAR(60);     
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);        
	DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
	DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cPlazo CHAR(5);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cInfReceptor CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE iPromo INTEGER;
	DEFINE cCanal CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumPago CHAR(5);
	DEFINE cNumSol CHAR(20);
	DEFINE iProd INTEGER;
	DEFINE cTipoConsulta CHAR(4);
	DEFINE cSol CHAR(20);
	DEFINE cTarjetaAux CHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP ='';
    LET cMensajeRet ='';
	LET cNumCredito ='';
    LET cCodTipCred ='';
	LET cDescStatusCred ='';   
    LET iIdUnidadProd =0;
    LET cCodCaract2 ='';
    LET dtFechaOrigen ='';
    LET dtFechaProxPago ='';
    LET dPagoMinimo =0;
    LET dtFechaUltPago ='';
    LET iPlazo =0;
    LET iPagosRealizados =0;
    LET dLineaOtorgada =0;
    LET dTasaInteres =0;
    LET dTasaMoratorios =0;
    LET dMontoSBC =0;
    LET dCapVig  =0;
    LET dCapTrans  =0;
    LET dCapVdoExig  =0;
    LET dCapVdoNoExig  =0;
    LET dSdoActCap  =0;        
	LET dIntVdo  =0;
    LET dIntMoratorio  =0;
    LET dIntMes  =0;
    LET dSdoActInt  =0;    
	LET dIntVig  =0;
    LET dIvaIntVig  =0;
    LET dIvaIntVdo  =0;
    LET dIvaIntMoratorio  =0;
    LET dIvaIntMes  =0;
    LET dSdoActIvaInt  =0;    
    LET dComPend  =0;
    LET dIvaCom  =0;
    LET dSdoRetenido  =0;
    LET dSdoTotalLiq  =0;    
    LET dIntDevengado  =0;
    LET dIvaIntDevengado  =0;
    LET dLineaDisponible  =0;
    LET dPagosVdos  =0;
    LET cDescBloqueoCta ='';
    LET cDescCausaBloqueoCta ='';
    LET cSitCte ='';
    LET cCausaCte =0;
    LET cDescSitEspCte ='';
    LET cSitCred ='';
    LET cCausaCred =0;
    LET cDescSitEspCred ='';
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cPlazo ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cInfReceptor ='';
	LET dMontoOtorgado  =0;
	LET iPromo =0;
	LET cCanal ='';
	LET cSucursal ='';
	LET iNoRegistros =0;
	LET cNumPago ='';
	LET cNumSol ='';
	LET iProd =0;
	LET cTipoConsulta = '';
	LET cSol ='';
	LET cTarjetaAux = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Daniel/sp_msi_consultamsicancel_totales.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        DELETE FROM "informix".sw_msi_consultagridcancel WHERE usuario = pUsuario;
		
		SELECT COUNT(*) INTO iProd FROM bdicred:"informix".sd_definicion WHERE edocta_param= 'tdc' and num_producto=pProducto;
		
		LET  cTipoConsulta = SUBSTR(pNumCred,1,4);
		
		IF  iProd = 0 AND cTipoConsulta='8900' THEN --Busca por promo msi 
				
		SELECT {+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)} sucursal,fecha_mov,codigo_fun,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE codigo_fun ='001' AND reversado= 'N' and num_credito = pNumCred INTO TEMP sd_movdiacrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}  num_tarjeta,num_sol_prestamo,folio_movto,num_promo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= pNumCred INTO TEMP sd_promocion_credito_temp with no log;
		SELECT {+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= pNumCred INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_movhiscrd movhistocrd)}  sucursal,fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND codigo_fun ='001' AND reversado= 'N' and num_credito = pNumCred INTO TEMP sd_movhiscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_msi_cancela_credito_msi idx_can_msi1)}  num_credito FROM bdicred:"informix".sd_msi_cancela_credito_msi WHERE num_credito = pNumCred INTO TEMP sd_msi_cancela_credito_msi_temp with no log;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
				
				b.num_tarjeta from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
		
				UNION 

				select b.num_tarjeta from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta

		FOREACH WITH HOLD 		
				SELECT * 
				INTO cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,cNumSol
				FROM
				(select 
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null
				UNION 
				select  
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null)
				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cNumSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito =cNumSol  AND capital_fecha_pago IS NOT NULL ORDER BY fecha_cuota DESC);
				
				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
				LET cPlazo =TRIM(iPlazo::CHAR(5))  ||'/'|| TRIM(cNumPago);
				
				INSERT INTO "informix".sw_msi_consultagridcancel(usuario,fecha,infreceptor,folio,montootorgado,plazo,tarjeta,promo,canal,sucursal,saldoliq,saldopag,numcredito)
				VALUES (pUsuario,cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSdoTotalLiq,dSaldo_pagar,cNumSol);
				
		END FOREACH;
		END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		DROP TABLE IF EXISTS sd_msi_cancela_credito_msi_temp;
		
		ELIF iProd = 1 THEN --Busca por num_credito todas las promociones de msi asociadas

        FOREACH 
        select num_sol_prestamo INTO cSol FROM bdicred:"informix".sd_promocion_credito 
        WHERE num_credito =pNumCred AND num_pro_prestamo = '8900'
		
		SELECT {+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)} sucursal,fecha_mov,codigo_fun,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE codigo_fun ='001' AND reversado= 'N' and num_credito = cSol INTO TEMP sd_movdiacrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}  num_tarjeta,num_sol_prestamo,folio_movto,num_promo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= cSol INTO TEMP sd_promocion_credito_temp with no log;
		SELECT {+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= cSol INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_movhiscrd movhistocrd)}  sucursal,fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND codigo_fun ='001' AND reversado= 'N' and num_credito = cSol INTO TEMP sd_movhiscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_msi_cancela_credito_msi idx_can_msi1)}  num_credito FROM bdicred:"informix".sd_msi_cancela_credito_msi WHERE num_credito = cSol INTO TEMP sd_msi_cancela_credito_msi_temp with no log;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
					
				b.num_tarjeta from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo

				UNION 
					
				select b.num_tarjeta from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta
     
			FOREACH WITH HOLD 		
				SELECT * 
				INTO cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,cNumSol
				FROM
				(select
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo				
				WHERE g.num_credito is null
				UNION 
				select  
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}

				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null)
				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota, num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito =cSol  AND capital_fecha_pago IS NOT NULL ORDER BY fecha_cuota DESC);
				
				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
				LET cPlazo =   TRIM(iPlazo::CHAR(5))||'/'||TRIM(cNumPago);
				
				INSERT INTO "informix".sw_msi_consultagridcancel(usuario,fecha,infreceptor,folio,montootorgado,plazo,tarjeta,promo,canal,sucursal,saldoliq,saldopag,numcredito)
				VALUES (pUsuario,cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSdoTotalLiq,dSaldo_pagar,cNumSol);
				
			END FOREACH;
    
        END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		DROP TABLE IF EXISTS sd_msi_cancela_credito_msi_temp;
		
		END FOREACH;
		
		ELSE  
			LET cCodRet ='01278';				
			RETURN cCodRet, iNoRegistros;
		
		END IF;
		
		SELECT COUNT(*) INTO iNoRegistros FROM "informix".sw_msi_consultagridcancel WHERE usuario = pUsuario;
		
		IF iNoRegistros = 0 THEN 
			LET cCodRet = '01278';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
 
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/04/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bloqueoctacap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pImporte MONEY(14,2), pFechaProceso DATE, pClaveBloq CHAR(2), pOpcBloque INTEGER, pAreaSolic CHAR(2), pMotivoBloq CHAR(2))
	RETURNING CHAR(5) AS codret,
                CHAR(5) as clave;
                
        DEFINE cEmpresa CHAR(3);
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(3);
        DEFINE iSqlErr INTEGER;
        DEFINE cClaveAreaSolic CHAR(1);
        DEFINE cTipoBloqueo CHAR(1);
        DEFINE cClave CHAR(5);
        
        LET cEmpresa = '001';
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cClaveAreaSolic = '';
        LET cTipoBloqueo = '';
        LET cClave = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cClave;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_bloqueoctacap.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso = '' OR pCuenta = '' OR pImporte = '' OR pOpcBloque = '' OR pClaveBloq = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cClave;
                END IF;
                
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cClave;
                END IF;
                

                -- Obtenemos el codigo de area solicitante
                IF pAreaSolic = '' or pAreaSolic  is null THEN 
                        SELECT cod_area
                        INTO cClaveAreaSolic
                        FROM bdicheq:"informix".sc_ctabloqueo
                        WHERE cuenta = pCuenta;
                ELSE
                        SELECT codigo
                        INTO cClaveAreaSolic
                        FROM bdicheq:"informix".sc_areabloqueo
                        WHERE TRIM(clave) = TRIM(pAreaSolic);
                END IF;
                
                -- Obtenemos la opcion de motivo de bloqueo
                
                SELECT codigo
                INTO cTipoBloqueo
                FROM bdicheq:"informix".sc_tipobloqueo
                WHERE TRIM(clave) = TRIM(pMotivoBloq);
                
                -- Se ejecuta el bloqueo
                EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(cEmpresa, pCuenta, pImporte, pClaveBloq, pOpcBloque, 
                                                      pFechaProceso, pUsuario, ' ', pAreaSolic, cClaveAreaSolic, pMotivoBloq, cTipoBloqueo)
                INTO cCodRetSp, cClave;

                IF cCodRetSp = '110' THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp = '162' THEN -- Verifica el saldo a congelar
                        LET cCodRet = '00101';
                ELIF cCodRetSp = '163' THEN -- Verifica el saldo a desbloquear de la cuenta
                        LET cCodRet = '00102';
                ELIF cCodRetSp = '100' THEN -- Verifica que la cuenta existe
                        LET cCodRet = '00009';
                ELIF cCodRetSp = '302' THEN -- Cuenta activa y no bloqueada
                        LET cCodRet = '00103';
                ELIF cCodRetSp = '200' THEN -- Cuenta no cancelada
                        LET cCodRet = '00104';
                ELIF cCodRetSp = '303' THEN -- pmonto >  sdoa_w - sdoc_w
                        LET cCodRet = '00105';
                END IF;
				
                --ACTUALIZACION DE ESTATUS 
				IF cCodRet = '00000' AND pIdFuncion = 'DBD304' THEN 
					UPDATE bdicheq:"informix".sc_cuentas_retiro SET estatus = 'R', no_empleado = pUsuario 
					WHERE cuenta = pCuenta;
				END IF;
				
                RETURN cCodRet, cClave;
                
        END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 21/08/2013",
"DESCRIPCION: Realiza el bloqueo o desbloqueo de una cuenta de captacion para la aplicacion CNSIFWEB",
"AUTOR: Veronica Sanchez Tlacomulco",
"FECHA: 25/03/2023",
"DESCRIPCION: Se realizo ajuste a SP para realizar el cambio de estatus en la tabla sc_cuentas_retiro cuando se reaiza un desbloqueo";

CREATE PROCEDURE "informix".sp_consultatotalreportedetallesolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret, 
        INTEGER AS total_registros;
                        
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumSolicitud CHAR(20);     
	DEFINE cSucursal CHAR(4);      
	DEFINE vNombreCte VARCHAR(100); 
	DEFINE dFechaSol DATE;         
	DEFINE dFechaCambio     DATE;         
	DEFINE cRevaluada CHAR(2);      
	DEFINE cReferenciaCoppel CHAR(20);     
	DEFINE dcEficienciaCoppel DECIMAL(18,2);
	DEFINE sMesesCoppel     SMALLINT;        
	DEFINE dcVencidoCoppel DECIMAL(18,2);
	DEFINE iVencidoCoppeludis INTEGER;      
	DEFINE cPuntualidad CHAR(2);      
	DEFINE iScoring1        INTEGER;      
	DEFINE iScoring2 INTEGER;      
	DEFINE cDescStatus CHAR(40);     
	DEFINE cCausaSolic CHAR(3);      
	DEFINE vComentario VARCHAR(100); 
	DEFINE cAnalista CHAR(45);     
	DEFINE cTipoMovto CHAR(10);     
	DEFINE cNombreProducto CHAR(50);     
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dHoraInicio DATETIME HOUR TO SECOND;
	DEFINE dHoraFin DATETIME HOUR TO SECOND;
	DEFINE iSolicitudesProcesadas	INTEGER;
	DEFINE cBeginWork	CHAR(01);
	DEFINE bandera CHAR(2);
	
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		ROLLBACK WORK;
		IF (bandera = "S") THEN
			BEGIN WORK;
		END IF;
		UPDATE "informix".status_repsolicitudmc
		SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iRegistros;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET bandera = "S";
		ROLLBACK WORK;
        BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    LET bandera = "N";

   BEGIN WORK;
   
   
		LET cCodRet = '00000';
		LET cCodRetSp = '';
		LET iCodRet = 0;
		LET iSqlErr = 0;
		LET cNumSolicitud = '';     
		LET cSucursal = '';      
		LET vNombreCte = ''; 
		LET dFechaSol = DATE(1);
		LET dFechaCambio = DATE(1);         
		LET cRevaluada = '';      
		LET cReferenciaCoppel = '';     
		LET dcEficienciaCoppel = NULL;
		LET sMesesCoppel = 0;    
		LET dcVencidoCoppel = NULL;
		LET iVencidoCoppeludis = 0;      
		LET cPuntualidad = '';      
		LET iScoring1 = 0;      
		LET iScoring2 = 0;     
		LET cDescStatus = '';     
		LET cCausaSolic = '';      
		LET vComentario = '';
		LET cAnalista = '';     
		LET cTipoMovto = '';    
		LET cNombreProducto = '';    
		LET iRegistros = 0;
		LET iRecuperacion = 0;
		LET dHoraInicio = NULL;
		LET dHoraFin = NULL;
		LET iSolicitudesProcesadas = 0;
		LET cBeginWork	= '0';
		LET bandera = 'N';
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotalreportedetallesolicitudmc.out';
		--SET DEBUG FILE TO '/informix/c90235391/sp_consultatotalreportedetallesolicitudmc.out';
		--TRACE ON;

		
		-- SE LIMPIA TABLA POR USUARIO
		--BEGIN;
			DELETE FROM "informix".status_repsolicitudmc WHERE usuario_insert = TRIM(pUsuario);
			INSERT INTO "informix".status_repsolicitudmc(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		--COMMIT;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			--BEGIN;
			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iRegistros;
		END IF;
			
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iRegistros;
		END IF;         
		
		--BEGIN ;
			DELETE FROM bdicnweb:"informix".sw_reportesolicitudmc WHERE usuario = pUsuario;
		--COMMIT;
		
		FOREACH
			
			EXECUTE PROCEDURE bdicred:"informix".sp_consultadetallesolicitudmc(pFechaInicio, pFechaFin, pProducto)
			INTO cCodRetSp, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadetallesolicitudmc';
			ELIF iCodRet = 3 THEN
				LET cCodRet = '00017';
				UPDATE "informix".status_repsolicitudmc
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet, iRegistros;
			END IF;
			
			
			INSERT INTO bdicnweb:"informix".sw_reportesolicitudmc 
			VALUES(cCodRetSp, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin, pUsuario);

			COMMIT;
			BEGIN;

		END FOREACH;
		
		SELECT COUNT(*) INTO iRegistros FROM bdicnweb:"informix".sw_reportesolicitudmc WHERE usuario = pUsuario;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';

			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet,iRegistros;
		END IF;

		--BEGIN ;
			UPDATE "informix".status_repsolicitudmc
			SET status = 'T', error_proceso = 'N', num_registros = iRegistros WHERE usuario_insert = pUsuario;
		--COMMIT ;
		
		IF bandera = "S" THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iRegistros;
			
--END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/03/2014',
'DESCRIPCION: Genera un conteo del detalle de todas las solicitudes de credito que fueron analizadas por Mesa de Control Estatus = MC',
'AUTOR: Oscar Flores Conde',
'FECHA: 11/01/2016',
'DESCRIPCION: Se agrega la hora de inicio de atenciÃ³n de la solicitud y la hora de finalizaciÃ³n',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 07/09/2018',
'DESCRIPCION: Se implementa tratado de volumetrÃ­a.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/09/2018',
'DESCRIPCION: Se implementa tratado de codigo de error 00003 del spl sp_consultadetallesolicitudmc.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 03/10/2018',
'DESCRIPCION: Se actualiza ejecuciÃ³n de spl productivo sp_consultadetallesolicitudmc (se eliminan los retornos dHoraInicio y dHoraFin).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacdetallado_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
			
	DEFINE cDescripcion CHAR(80);
	DEFINE cFecha_autorizacion CHAR(10);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_sucursal CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNombre_cte CHAR(104);
	DEFINE cComp_ingreso_valido CHAR(2);
	DEFINE cGrupo_cte CHAR(1);
	DEFINE dIngreso_declarado DECIMAL(20,2);
	DEFINE dCompromisos_sic DECIMAL(20,2);
	DEFINE dCompromisos_bco DECIMAL(20,2);
	DEFINE dCompromisos_cop DECIMAL(20,2);
	DEFINE dLinea_coppel DECIMAL(20,2);
	DEFINE dLinea_sug DECIMAL(20,2);
	DEFINE dIngreso_valido_mc DECIMAL(20,2);
	DEFINE dLinea_sug_mc DECIMAL(20,2);
	DEFINE cStatus_final CHAR(20);
	DEFINE cAnalista_cac_atend CHAR(45);
	DEFINE cObservaciones CHAR(300);
	DEFINE iSolicitudesProcesadas INTEGER;
	DEFINE cBeginWork	CHAR(01);
	DEFINE bandera CHAR(2);
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			IF bandera = 'S' THEN
				BEGIN WORK;
			END IF;
			
			UPDATE "informix".status_rep_detallado SET status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario_insert = pUsuario;
			--COMMIT WORK;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET bandera = "S";
		ROLLBACK WORK;
        BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	LET bandera = "N";
	
    BEGIN WORK;
		
	LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cDescripcion = '';
	LET cFecha_autorizacion = '';
	LET cNum_solicitud = '';
	LET cNum_sucursal = '';
	LET cNum_cliente = '';
	LET cNombre_cte = '';
	LET cComp_ingreso_valido = '';
	LET cGrupo_cte = '';
	LET dIngreso_declarado = 0.00;
	LET dCompromisos_sic = 0.00;
	LET dCompromisos_bco = 0.00;
	LET dCompromisos_cop = 0.00;
	LET dLinea_coppel = 0.00;
	LET dLinea_sug = 0.00;
	LET dIngreso_valido_mc = 0.00;
	LET dLinea_sug_mc = 0.00;
	LET cStatus_final = '';
	LET cAnalista_cac_atend = '';
	LET cObservaciones = '';
	LET iSolicitudesProcesadas = 0;
	LET cBeginWork	= '0';	
	LET bandera = 'N';
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacdetallado_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_detallado WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_detallado(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			--BEGIN WORK;
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				COMMIT;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".status_rep_detallado
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				COMMIT;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		--BEGIN WORK;
			DELETE FROM "informix".sw_mc_rep_cac_detallado WHERE usuario = pUsuario;
		--COMMIT WORK;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_detallado(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_reporte_cac_detallado';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;		
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154'; 
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÃN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			END IF;
		
			INSERT INTO "informix".sw_mc_rep_cac_detallado VALUES(cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones, pUsuario);

			COMMIT;
			BEGIN;
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_detallado WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÃN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			
			UPDATE "informix".status_rep_detallado
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_rep_detallado
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;  
		
		IF bandera = "S" THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
    --END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 28/08/2018',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'Descripcion: SPL encargado de consultar el nÃºmero total de registros del reporte detallado de las solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_capturactecreditocoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pNumCte CHAR(20), pNombre CHAR(104), pSucursal CHAR(4), pFechaSolicitud  CHAR(20), pNumAut1 CHAR(8), pNumAut2 CHAR(8), pStatus CHAR(1))
		RETURNING CHAR(5) AS codret;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE vNomAut1 CHAR(80);
	DEFINE vNomAut2 CHAR(80);
	DEFINE iNoRegistros INTEGER;
	DEFINE DfechaSol DATE; 	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vNomAut1  = '';
	LET vNomAut2  = '';
	LET iNoRegistros = 0;
	LET DfechaSol = DATE(1);
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268)
			LET cCodRet = '00284';
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/roman/ambientacion/TDC_INFINITE/Spl/sp_cre_capturactecreditocoppel.out';
		--TRACE ON;
		
		--IF pUsuario = '' OR pIdFuncion = '' OR  pNumSolicitud = '' OR  pNumCte = '' OR  pNombre = '' OR  pSucursal = '' OR pFechaSolicitud IS NULL OR  pNumAut1 = '' OR  pNumAut1 = '' OR  pNumAut2 = '' OR  pNumAut2 = '' OR  pStatus= ''  THEN
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNombre = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		


		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pNumSolicitud <> '' THEN 
		
			--Extraer la fecha de la solicitud de credito--
		 
			select fecha_insert 
			INTO DfechaSol 
			from bdisolic:"informix".ss_solicitudes 
			where empresa ='001' 
			AND num_solicitud = pNumSolicitud;
		END IF;
		
		IF pNumAut1 <> '' THEN
			SELECT nombre
			INTO  vNomAut1
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pNumAut1;		
		END IF;
		
		IF pNumAut2 <> '' THEN
			SELECT nombre
			INTO  vNomAut2
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pNumAut2;		
		END IF;
		
		INSERT INTO bdisolic:"informix".ss_clientes_exentos_rgc(fecha_insert, num_solicitud, numcte, nombre_cte, sucursal, fecha_sol, num_autorizador1, nombre_autorizador1, num_autorizador2, nombre_autorizador2, activo)
		VALUES (CURRENT, pNumSolicitud, pNumCte, pNombre, pSucursal, DfechaSol, pNumAut1, vNomAut1, pNumAut2, vNomAut2, pStatus);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '00282';
            RETURN cCodRet;
        END IF;         
        RETURN cCodRet;
    END;    
END PROCEDURE           
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la captura de los clientes que aceptados o rechazados en el crÃÂ©dito de grupo coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_repctasinactivasart61(pUsuario CHAR(8), pIdFuncion CHAR(10), pReporte CHAR(2), pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60), pIdReporte CHAR(20))
RETURNING CHAR(5) AS codret;		

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCmd1 CHAR(3000);
	DEFINE cSql CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iCont INTEGER;
    DEFINE sCommit SMALLINT;
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE dFechaConsulta DATE;
	DEFINE dFechaMax DATE;
	DEFINE dFechaMin DATE;
	DEFINE cReporte CHAR(100);
	DEFINE cRutaGral CHAR(100);
	DEFINE iNumRegistros INTEGER;
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	
	DEFINE cEstatus CHAR(1);
	DEFINE cDescEstatus CHAR(30);
	DEFINE cNum_cuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFech_ult_dep DATE;
	DEFINE dFech_ult_ret DATE;
	DEFINE dFecha_inf DATE;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cDescProducto CHAR(30);
	DEFINE dFechaAlta DATE;
	DEFINE dFecha_ult_mov DATE;
	
	DEFINE cDescProducto_con CHAR(40);
	DEFINE cNom_cliente CHAR(107);
	DEFINE dFecha_con DATE;
	DEFINE cImporte_con CHAR(20);
	DEFINE cInteres_gen CHAR(16);
	
	DEFINE dFecha_des DATE;
	DEFINE cInteres_gen_des DECIMAL(14,2);
	DEFINE cPago_sdo_concentra DECIMAL(18,2);
	
	DEFINE dFecha_tra DATE;
	DEFINE cInteres_gen_can DECIMAL(14,2);
	DEFINE cSdo_trasp_beneficiencia DECIMAL(18,2);
	
	DEFINE v_producto CHAR(4);
	DEFINE v_nombre   CHAR(40);
	
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(60);
	DEFINE cStr10 CHAR(60);
	DEFINE cStr11 CHAR(60);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCmd1 = '';
	LET cSql = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iCont = 0;
    LET sCommit = 0;
	LET cRutaInformix = '/ifxsif01/bin/';
	--LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET dFechaConsulta = '';
	LET dFechaMax = '';
	LET dFechaMin = '';
	LET cReporte = '';
	LET cRutaGral = '';
	LET iNumRegistros = 0;
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	
	LET cEstatus = '';
	LET cDescEstatus = '';
	LET cNum_cuenta = '';
	LET cProducto = '';
	LET cNum_cliente = '';
	LET dFech_ult_dep = '';
	LET dFech_ult_ret = '';
	LET dFecha_inf = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET cEstado = '';
	LET cDescEstado = '';
	LET cDescProducto = '';
	LET dFechaAlta = '';
	LET dFecha_ult_mov = '';
	
	LET cDescProducto_con = '';
	LET cNom_cliente = '';
	LET dFecha_con = '';
	LET cImporte_con = '';
	LET cInteres_gen = '';
	
	LET dFecha_des = '';
	LET cInteres_gen_des = 0.00;
	LET cPago_sdo_concentra = 0.00;
	
	LET dFecha_tra = '';
	LET cInteres_gen_can = 0.00;
	LET cSdo_trasp_beneficiencia = 0.00;
	
	LET dHoy = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET cStr9 = '';
	LET cStr10 = '';
	LET cStr11 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
		
	BEGIN

		ON EXCEPTION SET iSqlErr
		
			SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repctasinactivasart61.out';
			TRACE ON;
			
			LET cCodRet = iSqlErr;
						
			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			TRACE OFF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_repctasinactivasart61.out';
		--SET DEBUG FILE TO '/informix/rsv/ART61/TASF/bdicnweb/sp_repctasinactivasart61.out';

		IF pUsuario = '' OR pIdFuncion = '' OR pReporte = '' OR pRutaDescarga = ''  OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';			
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		LET cNombreReporte = TRIM(pIdReporte)||'_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y')||'.csv';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- OBTIENE LA FECHA HOY Y DEFINE PERIODO DE CONSULTA
		SELECT fecha_hoy INTO dFechaConsulta FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa;		
		
		LET dFechaMax = LAST_DAY(dFechaConsulta - 1 UNITS MONTH);
		LET dFechaMin = TO_DATE(1||'/'||MONTH(dFechaMax)||'/'||YEAR(dFechaMax),'%d/%m/%Y');
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CUENTAS INFORMADAS
		IF pReporte = '1' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasinformadas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasinformadas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'INFORMADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '5';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			SELECT  inf.cuenta,inf.producto,inf.num_cte,inf.fech_ult_dep,inf.fech_ult_ret,inf.fecha_marc
			FROM    bdicheq:sc_ctasinformadas AS inf 
			WHERE   inf.fecha_marc BETWEEN dFechaMin AND dFechaMax
			INTO    TEMP tmp_infdas WITH NO LOG;
				
			CREATE INDEX idx_tmp_infdas 
            ON tmp_infdas (cuenta,fecha_marc);

			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD

			    SELECT a.cuenta,   a.producto, a.num_cte,    a.fech_ult_dep, a.fech_ult_ret, a.fecha_marc
				INTO   cNum_cuenta,cProducto,  cNum_cliente, dFech_ult_dep,  dFech_ult_ret,  dFecha_inf
				FROM   tmp_infdas as a, 
				       bdicheq:sc_ctasinformadas as b
                where  a.cuenta     = b.cuenta 
                and    a.fecha_marc = b.fecha_marc				
				AND    a.fecha_marc = (SELECT MIN(b.fecha_marc) 
				                          FROM   bdicheq:sc_ctasinformadas b 
			  	                          WHERE  b.cuenta = a.cuenta)
				
				SELECT nombre1,nombre2,apell_paterno,apell_materno
				INTO   cNombre1,cNombre2,cApell_paterno,cApell_materno
				FROM   bdinteg:"informix".si_cliente WHERE numcte = cNum_cliente;
				
				SELECT sucursal INTO cSucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNum_cuenta AND producto = cProducto;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasinformadas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto),cNum_cliente,TRIM(TRIM(cNombre1)||' '||TRIM(cNombre2))||' '||TRIM(cApell_paterno)||' '||TRIM(cApell_materno),
				TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				
			END FOREACH;
			COMMIT WORK;			

			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf::CHAR(10),estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasinformadas "||
			"WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
							
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS CONCENTRADAS
		ELIF pReporte = '2' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '6';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
								
	       --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION  - RSV 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH

			SELECT  b.cuenta,b.producto as nom_producto,b.num_cte,b.cliente,b.fech_ult_dep,
                    b.fech_ult_ret,b.fecha_concentra,b.sdo_concentrado,a.sucursal,
					a.producto,b.ints_prov_acum
            FROM    bdicheq:sc_maechq AS a,
                    bdicheq:sc_cuentas_concentradas as b
            WHERE   a.cuenta     = b.cuenta
            AND     a.status_cta = "6"
            and     a.sdo_actual = b.sdo_concentrado
            and     b.fecha_concentra BETWEEN dFechaMin AND dFechaMax
            and     b.fecha_pago_concentra IS NULL
            INTO    TEMP tmp_ctas_concentra WITH NO LOG;
			
			
			CREATE INDEX idx_tmp_ctas_concentra 
			ON tmp_ctas_concentra(cuenta);
			
		    SELECT  a.cuenta,a.nom_producto,a.num_cte,a.cliente,a.fech_ult_dep,a.fech_ult_ret,
				    a.fecha_concentra,a.sdo_concentrado,a.sucursal,a.producto,a.ints_prov_acum,c.fecha_marc	
			FROM    tmp_ctas_concentra AS a, 
					bdicheq:sc_ctasinformadas  AS c
			WHERE   a.cuenta = c.cuenta
			AND     c.fecha_marc = (SELECT MIN(d.fecha_marc) 
				                    FROM   bdicheq:sc_ctasinformadas d 
			  	                    WHERE  d.cuenta = a.cuenta)
			INTO TEMP tmp_ctas_concentra_fin WITH NO LOG;
						
			FOREACH WITH HOLD
					    
				SELECT cuenta,nom_producto,num_cte,cliente,fech_ult_dep,fech_ult_ret,fecha_concentra,sdo_concentrado,
				       sucursal,producto,ints_prov_acum,fecha_marc
				INTO   cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,
				       dFecha_con,cImporte_con,cSucursal,cProducto,cInteres_gen,dFecha_inf
				FROM   tmp_ctas_concentra_fin
			
							
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta 
				INTO dFechaAlta
				FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
					
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;				
			
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),
				TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,NVL(cInteres_gen,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasconcentradas as c where c.num_cuenta = b.cuenta) "||
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS DESCONCENTRADAS/ACTIVAS
		ELIF pReporte = '3' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasdesconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasdesconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'DESCONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '1';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_sdo_concentra,con.fecha_pago_concentra,con.pago_sdo_concentra,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_des,dFecha_des,cPago_sdo_concentra,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				     bdicheq:"informix".sc_maechq AS mae,
					 bdicheq:"informix".sc_ctasinformadas as inf
			    WHERE con.cuenta = mae.cuenta
				AND   con.cuenta = inf.cuenta
                 --  AND con.num_cte = inf.num_cte
				AND   con.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
			---	AND mae.status_cta = cEstatus
				---ORDER BY con.fecha_pago_concentra ASC
				
			--	FOREACH
			---		SELECT FIRST 1 fecha_marc 
			---		INTO dFecha_inf
			---		FROM bdicheq:"informix".sc_ctasinformadas 
			---		WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
			--	END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasdesconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_des,importe_des,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto_con),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_des,TO_CHAR(dFecha_des, '%d/%m/%Y'),TRUNC(NVL(cInteres_gen_des,0) + NVL(cImporte_con,0),2),UPPER(cDescEstatus),CURRENT,pUsuario);
				 
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA DESCONCENTRACION/ACTIVA','IMPORTE DESCONCENTRADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta, a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_des,a.importe_des,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasdesconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasdesconcentradas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		-- CUENTAS CANCELADAS
		ELIF pReporte = '4' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctascanceladas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctascanceladas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CANCELADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '2';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			
		  --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
					
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				 SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_trasp_beneficiencia,con.fecha_trasp_benefic,con.sdo_trasp_beneficiencia,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_can,dFecha_tra,cSdo_trasp_beneficiencia,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				                   bdicheq:"informix".sc_maechq AS mae,
								   bdicheq:"informix".sc_ctasinformadas as inf
				WHERE con.cuenta  = mae.cuenta
				AND   con.cuenta  = inf.cuenta
                AND   con.num_cte = inf.num_cte			   
				AND   con.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax
				AND   mae.motivo = '14'
				AND   mae.status_cta = cEstatus
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
				-- ORDER BY con.fecha_trasp_benefic ASC
				
				--FOREACH
				--	SELECT FIRST 1 fecha_marc 
				--	INTO dFecha_inf
				--	FROM bdicheq:"informix".sc_ctasinformadas 
				--	WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
				--END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctascanceladas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_tras,importe_envben,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_can,TO_CHAR(dFecha_tra, '%d/%m/%Y'),NVL(cInteres_gen_can,0) + NVL(cSdo_trasp_beneficiencia,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				LET dFecha_tra = '';
				LET cInteres_gen_can = 0.00;
				LET cSdo_trasp_beneficiencia = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA TRASPASO','IMPORTE ENVIADO A LA BENEFICENCIA PUBLICA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_tras,a.importe_envben,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctascanceladas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctascanceladas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		END IF;
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
		FOREACH
		
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesart61 
			WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
			AND fecha_reporte < dFechaHoy
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cNombreReporteHist);
			
		END FOREACH;
		
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cReporte);
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesart61(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		
		-- NOTIFICACION VIA CORREO ELECTRONICO
		LET cStr7 = 'GENERACION DEL ARCHIVO TXT';
		LET cStr8 = 'SOLICITUD DE CUENTAS INACTIVAS ART. 61';
		LET cStr9 = '000000000';
		LET cStr10 = 'MAIL_ART61';
		LET cStr11 = 'operaciones_art61@bancoppel.com';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		'WEB_PLAGEN',
		TRIM(cStr10), 
		TRIM(cStr9),
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		TRIM(cStr8),
		'',		
		'',
		TRIM(cStr11),
		'',
		'1',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		''
		) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCION DEL SP bdimnsj:"informix".sp_registra_evento, 
		END IF; 
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 23/05/2017',
'MODULO: DEBITO',
'FUNCIONALIDAD: REPORTE CUENTAS INACTIVAS (ART 61)',
'DESCRIPCION: SPL que genera reporte txt de las Cuentas Inactivas (Art 61)',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/06/2017',
'DESCRIPCION: Se actualiza para obtener campo saldo de la tabla bdicheq:sc_cuentas_concentradas.sdo_concentrado',
'en lugar de bdicheq:sc_maechq.imp_cgos_mes cuando las cuentas tienen estatus CANCELADO',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/07/2017',
'DESCRIPCION: Se modifica spl para la reasignacion de tablas utilizadas en la recuperacion del detalle de las fechas,',
'se reemplaza el NUMERO del estatus por su descripcion.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 21/01/2019',
'DESCRIPCION: Se modifica spl para establecer nuevas reglas de negocio solicitadas por el cliente.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/07/2019',
'DESCRIPCION: Se modifica spl para control de tiemeout en SOC.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 05/08/2019',
'DESCRIPCION:  Se modifica spl para activar y desactivar trace cuando ocurre un error no controlado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actualizatransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdActualiza CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pOperacion CHAR(4), pMonto MONEY(16,2))
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoOperacion CHAR(25);
	DEFINE cDescActualiza CHAR(20);
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTipoOperacion = '';
	LET cDescActualiza = '';
	LET iRecuperacion = 0;	
	LET cStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_actualizatransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdActualiza = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR pOperacion = '' OR pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--REVERSO
		IF pIdActualiza = '1' THEN
			
			UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08' 
			WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' 
			WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			LET cDescActualiza = 'REVERSO';
			
		END IF;
		
		--CAMBIO ESTATUS
		IF pIdActualiza = '2' THEN
			
			SELECT status 
			INTO cStatus 
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF cStatus = '08' THEN
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '01' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
				UPDATE bdisuc:"informix".ss_operaciones SET reversado = '0' 
				WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
			ELSE
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '11' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			END IF;
			
			LET cDescActualiza = 'CAMBIO ESTATUS';
			
		END IF;
		
		IF pOperacion IN ('0001','0010','0036') THEN
			LET cTipoOperacion = 'DOTACION';
		ELIF pOperacion IN ('0002','0041') THEN
			LET cTipoOperacion = 'CONCENTRACION';
		ELIF pOperacion = '0026' THEN
			LET cTipoOperacion = 'RECOLECCION';
		END IF;
		
		--SE REGISTRA EN BITÁCORA
		INSERT INTO bdisuc:"informix".ss_bitacora_reversoscg (fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio)
		VALUES(CURRENT,pSucursal,pFolio,cTipoOperacion,pMonto,pUsuario,cDescActualiza);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de actualizar los campos correspondientes al reverso y cambio de estatus de las Operaciones de Caja General.',
'BD: bdicnweb','AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0002, 0026, 0041 y se agrega transaccion 0041 para indicar el tipo de operacion - Concentracion',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0001 y 0010';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_solicitud,
			CHAR(8) AS folio_oper,
			MONEY(16,2) AS monto,
			CHAR(4) AS sucursal,
			CHAR(4) AS cod_proveedor,
			CHAR(16) AS folio_servicio,
			CHAR(2) AS status,
			CHAR(4) AS operacion,
			CHAR(35) AS desc_operacion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha_solicitud DATE;
	DEFINE cFolio_oper CHAR(8);
	DEFINE mMonto MONEY(16,2);
	DEFINE cSucursal CHAR(4);
	DEFINE cCod_proveedor CHAR(4);
	DEFINE cFolio_servicio CHAR(16);
	DEFINE cStatus CHAR(2);
	DEFINE cOperacion CHAR(4);
	DEFINE cDescOperacion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha_solicitud = '';
	LET cFolio_oper = '';
	LET mMonto = 0.00;
	LET cSucursal = '';
	LET cCod_proveedor = '';
	LET cFolio_servicio = '';
	LET cStatus = '';
	LET cOperacion = '';
	LET cDescOperacion = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			a.fecha_solicitud,a.folio_oper,a.monto,a.sucursal,a.cod_proveedor,a.folio_servicio,a.status,b.cod_trans,c.descripcion
			INTO dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
				END IF;
			END IF;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8))
		RETURNING CHAR(5) AS codret,
			INTEGER AS no_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolio_oper CHAR(8);
	DEFINE cOperacion CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFolio_oper = '';
	LET cOperacion = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT a.folio_oper,b.cod_trans
			INTO cFolio_oper,cOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO 
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el número total de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_consultas_cac_central_total2(pEmpresa CHAR(3),pSucursal CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pNumSol CHAR(20), pBanCac CHAR(1), pCac_Opt1_1 DECIMAL(5,2), pCac_Opt3_1 INTEGER, pArea CHAR(2), pStatus CHAR(2), pCausa CHAR(3), pProducto CHAR(4), pUsuario CHAR(10))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);

DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);
DEFINE iNumRegistros    	   INTEGER;


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa					   = '';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iNumRegistros         	   = 0;

-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

--AUTOR: L. Montserrat LeÃ³n Amador
--FECHA: 19/09/2019
--DESCRIPCION: Se modifica SPL para implementar la eliminaciÃ³n de registros de la tabla paso1 (que ahora es fÃ­sica) a partir del indice id_registro.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, iNumRegistros;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizÃ³ la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

--IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

  --  SELECT valor1,valor2
    --  INTO dECValor1,dECValor2
      --FROM bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    --SELECT valor1,valor2
    --  INTO dMACValor1,dMACValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
  --  SELECT valor1,valor2
      --INTO dPSValor1,dPSValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "03";
--END IF;
	
	-- SE LIMPIA TABLA POR USUARIO Y PROCESO
	SET LOCK MODE TO WAIT 3;
	DELETE FROM bdicnweb:"informix".paso1
	WHERE usuario = TRIM(pUsuario);

IF NVL(pNumSol,"")  <> "" THEN 
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto
															  AND aut.revision_cac = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
															  AND aut.status_solicitud = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
															  AND aut.causa_solicitud = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  ---Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  pNumSol
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
--		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
				AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)
--			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND sol.num_producto = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
--			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)			
--			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;
				  
				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
				  
					IF NVL(iInfoBuro,0) = 0 THEN
						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;

				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					--  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN
						  --IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
								   --(iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
			--IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   --END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;

ELSE
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  --Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  sol.num_solicitud 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= pFechaInicial AND  sol.fecha_insert <= pFechaFinal )
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
					
					IF NVL(iInfoBuro,0) = 0 THEN

						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;
				
				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					 -- IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN

						--  IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
							--	   (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
		--	IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   ---END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
	
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;
END IF

	SELECT COUNT (*) 
	INTO iNumRegistros
	FROM bdicnweb:"informix".paso1 
	WHERE usuario = pUsuario;

	RETURN NVL(cCodRet,''), NVL(iNumRegistros,0);

END
END PROCEDURE;