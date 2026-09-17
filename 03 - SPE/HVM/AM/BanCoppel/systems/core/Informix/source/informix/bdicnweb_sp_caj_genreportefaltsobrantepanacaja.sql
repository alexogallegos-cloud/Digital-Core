CREATE PROCEDURE "informix".sp_caj_genreportefaltsobrantepanacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pTransaccion CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5) AS codret,
		CHAR(4) AS sucursal,
		CHAR(16) AS no_papeleta, 
		MONEY (16,2) AS importe, 
		MONEY (16,2) AS importe_sucursal,
		MONEY (16,2) AS importe_diferencia,
		DATE AS fecha;
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE cSucursal 	CHAR(4);
	DEFINE cNumPapeleta CHAR(16);
	DEFINE mMonto 		MONEY (16,2);
	DEFINE mMontoCSuc   MONEY (16,2);
	DEFINE mMontoDiferencia MONEY (16,2);
	DEFINE dFechaDeferencia DATE;
	DEFINE cMensaje     CHAR(50);	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cSucursal = '0000';
	LET cNumPapeleta = '0';
	LET mMonto 		= 0;
	LET mMontoCSuc   = 0;
	LET mMontoDiferencia = 0;
	LET dFechaDeferencia = NULL;
	LET cMensaje ='';	
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_genreportefaltsobrantepanacaja.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pTransaccion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH		
			EXECUTE PROCEDURE bdisuc:"informix".sp_rep_faltsob_pana2(pFechaInicio, pFechaFin, pTransaccion,pRegistros, pRecuperacion)
			INTO  cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia,cCodRetSp,cMensaje
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisuc:sp_rep_faltsob_pana2";
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
            RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia WITH RESUME;
		END FOREACH;

		-- colocar cod d error 17 y 1001
	    IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
			RETURN cCodRet,cSucursal,cNumPapeleta, mMonto, mMontoCSuc, mMontoDiferencia, dFechaDeferencia;
	    END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SOLICITUD DOTACION SUCURSAL',
'DESCRIPCION: SPL que genera el reporte de los faltantes y sobrantes de panamericana',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caj_validasucursalcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(30) AS nombreSucursal;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(6);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE vmensaje 	CHAR(50);
	DEFINE cNombreSucursal   CHAR(30);
	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;
	LET cCodRetSp	= '';
	LET iCodRetSp 	= 0;
	LET vmensaje	= '';
	LET cNombreSucursal='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreSucursal;
		END EXCEPTION;
		
		 -- SET DEBUG FILE TO '/tmp/mfinis/sp_caj_validasucursalcaja.out';
		 -- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisuc:"informix".sp_valida_suc2(pSucursal)
		INTO cCodRetSp ,vmensaje,cNombreSucursal;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisuc:sp_valida_suc2";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00833';
		END IF;		
		RETURN cCodRet,cNombreSucursal;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SOLICITUD DOTACION SUCURSAL',
'DESCRIPCION: SPL que validad si existe la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadomicilioactualcte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pTipoDir CHAR(1))
RETURNING CHAR(5) AS codRetorno, -- Codigo de Retorno
	CHAR(20) AS numCliente, --Número de Cliente
	CHAR(20) AS numCredito, --Numero de Credito
	CHAR(104) AS nomCliente, --Nombre del Cliente
	CHAR(2) AS estado, --Estado
	CHAR(30) AS nomEstado, --Nombre del Estado
	CHAR(3) AS ciudad, --Ciudad
	SMALLINT AS numCiudad, --Numero de Ciudad
	CHAR(60) AS nomCiudad, --Nombre de Ciudad
	SMALLINT AS ciudadCoppel, --Ciudad Coppel
	INTEGER AS numColonia, --Numero de Colonia
	CHAR(32) AS nomColonia, --Nombre de Colonia
	CHAR(27) AS municipio, --Municipio
	INTEGER AS numCalle, --Numero de Calle
	CHAR(30) AS nomCalle, --Nombre de Calle
	SMALLINT AS edificio, --Edificio
	CHAR(6) AS departamento, --Departamento
	CHAR(5) AS codPostal, --Codigo Postal
	CHAR(80) AS observaciones, --Observaciones
	CHAR(10) AS numExterior, --Numero Exterior
	CHAR(10) AS numInterior, --Numero Interior
	CHAR(30) AS nomEdificio; -- Nombre de Edificio
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNomCliente CHAR(104);
	DEFINE cEstado CHAR(2);
	DEFINE cNomEstado CHAR(30);
	DEFINE cCiudad CHAR(3);
	DEFINE sNumCiudad SMALLINT;
	DEFINE cNomCiudad CHAR(60);
	DEFINE sCiudadCoppel SMALLINT;
	DEFINE iNumColonia INTEGER;
	DEFINE cNomColonia CHAR(32);
	DEFINE cMunicipio CHAR(27);
	DEFINE iNumCalle INTEGER;
	DEFINE cNomCalle CHAR(30);
	DEFINE sEdificio SMALLINT;
	DEFINE cDepartamento CHAR(6);
	DEFINE cCodPostal CHAR(5);
	DEFINE cObservaciones CHAR(80);
	DEFINE cNumExterior CHAR(10);
	DEFINE cNumInterior CHAR(10);
	DEFINE cNomEdificio  CHAR(30);
	DEFINE cEmpresa CHAR(3);

	LET     cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente = '';
	LET cNumCredito = '';
	LET cNomCliente = '';
	LET cEstado = '';
	LET cNomEstado = '';
	LET cCiudad = '';
	LET sNumCiudad = 0;
	LET cNomCiudad = '';
	LET sCiudadCoppel = 0;
	LET iNumColonia = 0;
	LET cNomColonia = '';
	LET cMunicipio = '';
	LET iNumCalle = 0;
	LET cNomCalle = '';
	LET sEdificio = 0;
	LET cDepartamento = '';
	LET cCodPostal = '';
	LET cObservaciones = '';
	LET cNumExterior = '';
	LET cNumInterior = '';
	LET cNomEdificio  = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadomicilioactualcte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pNumCte = '' AND pNumCredito = '') OR pTipoDir = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END IF;
		
		IF pTipoDir NOT IN ('1', '2', '3') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel, 
			iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
			cNumInterior, cNomEdificio;
		END IF;
		
		 -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel,
				iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, 
				cNumExterior, cNumInterior, cNomEdificio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerdomiciliocliente(cEmpresa, pNumCte, pNumCredito, pTipoDir) INTO cCodRetSp, 
		cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, sCiudadCoppel,
		iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, cObservaciones, cNumExterior,
		cNumInterior, cNomEdificio     
		
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'Error en la ejeución del SP prodcutivo sp_obtenerdomiciliocliente ('||cCodRetSp::INTEGER||')';
			END IF;
			 
			IF cCodRetSp = '000' THEN
				LET cCodRet = '00000';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;                                       
			END IF; 
			IF cCodRetSp = '001' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad,
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			IF cCodRetSp = '002' THEN
				LET cCodRet = '00022';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad,
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			IF cCodRetSp = '003' THEN
				LET cCodRet = '00046';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			END IF;
			
			IF pTipoDir = '1' AND cCodRetSp = '004' THEN
				LET cCodRet = '00066';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;
			ELIF pTipoDir = '2' AND cCodRetSp = '004' THEN
				LET cCodRet = '00080';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;   
			ELIF pTipoDir = '3' AND cCodRetSp = '004' THEN
				LET cCodRet = '00841';
				RETURN cCodRet, cNumCliente, cNumCredito, cNomCliente, cEstado, cNomEstado, cCiudad, sNumCiudad, cNomCiudad, 
				sCiudadCoppel, iNumColonia, cNomColonia, cMunicipio, iNumCalle, cNomCalle, sEdificio, cDepartamento, cCodPostal, 
				cObservaciones, cNumExterior, cNumInterior, cNomEdificio;     													
			END IF;

		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: M.D.S Sandra Cano',
'FECHA: 09/08/2016',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MANTENIMIENTO DOMICILIOS CLIENTE',
'DESCRIPCION: SPL que consulta los domicilios del cliente. Se modifica para agregar tipo domicilio 3, envio de token',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_actualizanombrexmlfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pNomXml CHAR(40))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomXml CHAR(40);	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomXml = '';
	LET iNoRegistros =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_actualizanombrexmlfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNomXml = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		-- ACTUALIZACION DEL NOMBRE DE ARCHIVO
		UPDATE  bdilide:sl_ftc_prm
		SET valor = pNomXml
		WHERE cve_param = 5
		AND valor_param = 3;
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');		
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		RETURN cCodRet,iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio ',
'FECHA: 09/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza actualizacion de nombre de xml creado en la funcionalidad de Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_bitacoreogenreportesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_bitacoreogenreportesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pBandera = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pBandera = '1' THEN 		
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'GENERACION DE REPORTE');
			RETURN cCodRet;
		ELIF pBandera = '2' THEN
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'GENERACION DE XML');
			RETURN cCodRet;
		ELIF pBandera = '3' THEN
			INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, '', '', '', '', pUsuario, 'VALIDACION DE XSD');
			RETURN cCodRet;		
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
	END;	
END PROCEDURE		
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que bitacorea las actividades de la funcionalidad de generacion de reporte Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturaclientesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pNumCliente CHAR(20), pCuenta CHAR(20), pTipoReporte CHAR(1))
                RETURNING CHAR(5) AS codret;            
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cRazonSocial CHAR(60);
        DEFINE cApellPaterno CHAR(26);
        DEFINE cApellMaterno CHAR(26);
        DEFINE cNombre1 CHAR(26);
        DEFINE cNombre2 CHAR(26);
        DEFINE cCalle CHAR(40);
        DEFINE cNumIntCalle CHAR(10);
        DEFINE cNumExtCalle CHAR(10);
        DEFINE cColonia CHAR(32);
        DEFINE cDelegacion CHAR(27);
        DEFINE cCodPostal CHAR(5);
        DEFINE cPais CHAR(3);
        DEFINE cCiudad CHAR(30);
        DEFINE cRfc CHAR(13);
        DEFINE dFechaNac CHAR(10);  
        DEFINE cCuenta  CHAR(20);
        DEFINE  mMonto MONEY(18,2);
        DEFINE cSumaProm MONEY (18,2);
        DEFINE cMesesActivo INTEGER;
        DEFINE mInteresPagado MONEY(16,2);
        DEFINE cEjercicio CHAR(4);
        DEFINE cTipoPersona CHAR(2);
        DEFINE cCRazonSocial CHAR(60);
        DEFINE cCApellPaterno CHAR(26);
        DEFINE cCApellMaterno CHAR(26);
        DEFINE cCNombre1 CHAR(26);
        DEFINE cCNombre2 CHAR(26);
        DEFINE cCCalle CHAR(40);
        DEFINE cCNumIntCalle CHAR(10);
        DEFINE cCNumExtCalle CHAR(10);
        DEFINE cCColonia CHAR(32);
        DEFINE cCDelegacion CHAR(27);
        DEFINE cCCodPostal CHAR(5);
        DEFINE cCPais CHAR(3);
        DEFINE cCCiudad CHAR(30);
        DEFINE cCRfc CHAR(13);
        DEFINE dCFechaNac CHAR(10); 
        DEFINE cCCuenta  CHAR(20);
        DEFINE mCMonto MONEY(18,2);
        DEFINE mCInteresPagado MONEY(18,2);
        DEFINE iExiste INTEGER;
        DEFINE iComplementaria INTEGER;
        DEFINE sConsecutivo SMALLINT;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cRazonSocial = '';
        LET cApellPaterno = '';
        LET cApellMaterno = '';
        LET cNombre1 = '';
        LET cNombre2 = '';
        LET cCalle = '';
        LET cNumIntCalle = '';
        LET cNumExtCalle = '';
        LET cColonia = '';
        LET cDelegacion = '';
        LET cCodPostal = '';
        LET cPais = ''; 
        LET cCiudad = '';
        LET cRfc = '';
        LET dFechaNac = '';
        LET cCuenta = '';
        LET mMonto = 0.00;
        LET cSumaProm = 0.00;
        LET cMesesActivo = 0;
        LET mInteresPagado = 0.00;
        LET cEjercicio  = '';
        LET cTipoPersona = '';
        LET cCRazonSocial = '';
        LET cCApellPaterno = '';
        LET cCApellMaterno = '';
        LET cCNombre1 = '';
        LET cCNombre2 = '';
        LET cCCalle = '';
        LET cCNumIntCalle = '';
        LET cCNumExtCalle = '';
        LET cCColonia = '';
        LET cCDelegacion = '';
        LET cCCodPostal = '';
        LET cCPais = '';
        LET cCCiudad = '';
        LET cCRfc = '';
        LET dCFechaNac = '';    
        LET cCCuenta  = '';
        LET mCMonto = 0.00;
        LET mCInteresPagado = 0.00;
        LET iExiste = 0;
        LET iComplementaria = 0;
                LET sConsecutivo = 0;
        
        BEGIN
				ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                ON EXCEPTION IN (-268)
                        LET cCodRet = '00284';
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_cap_capturaclientesfatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = ''   THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                SELECT TRIM(razon_social),  TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno) , TRIM(apell_materno), TRIM(tpo_persona)
                INTO cRazonSocial,  cNombre1, cNombre2, cApellPaterno, cApellMaterno, cTipoPersona
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = pNumCliente;
                
                SELECT TRIM(numerointcalle), TRIM(numeroextcalle)
                INTO cNumIntCalle, cNumExtCalle
                FROM bdinteg:"informix".si_direcciones_actual
                WHERE numcte = pNumCliente
                AND tipo_dir  = 1;  

				SELECT TRIM(c.nombrecalle)
                INTO cCalle
                FROM bdinteg:"informix".si_direcciones_actual d 
				INNER JOIN bdinteg:"informix".si_catcalles AS c
				ON d.numerocalle = c.numerocalle
                WHERE numcte = pNumCliente  
                AND tipo_dir  = 1; 
				               		
				SELECT  TRIM(d.nombrezona), TRIM(e.nombreciudad)
				INTO cColonia, cDelegacion
				FROM bdinteg:si_direcciones_actual AS a, bdinteg:si_catzonas AS d, bdinteg:si_catciudades AS e
				WHERE a.numerociudad = d.numerociudad
				AND a.numerocolonia = d.numerocolonia
				AND d.numerociudad = e.numerociudad
				AND a.tipo_dir = 1
				and a.numcte = pNumCliente;
				
                SELECT TRIM(cod_postal)
                INTO cCodPostal
                FROM bdinteg:"informix".si_direcciones_actual
                WHERE numcte = pNumCliente
                AND tipo_dir  = 1;              
                
                SELECT TRIM(p.nombre)
                INTO cPais
                FROM bdinteg:"informix".si_paises p
                INNER JOIN  bdinteg:"informix".si_direcciones_actual a ON p.pais = a.pais
                WHERE  a.numcte =  pNumCliente
                AND a.tipo_dir = 1;
                
                SELECT  TRIM(g.nombre)as estado
				INTO cCiudad
				FROM bdinteg:si_direcciones_actual AS a, 
				bdinteg:si_estados AS g
				WHERE a.tipo_dir = 1
				AND a.estado = g.estado
				and a.numcte = pNumCliente;

				IF cTipoPersona = '01' THEN
                        SELECT TRIM(rfc), fecha_nac
                        INTO  cRfc, dFechaNac
                        FROM bdinteg:"informix".si_cliente sc 
                        INNER JOIN bdinteg:"informix".si_ctepf cpf ON sc.numcte = cpf.numcte    
                        WHERE sc.numcte = pNumCliente;
                ELIF cTipoPersona = '02' THEN
                        SELECT TRIM(rfc), fecha_constitct
                        INTO  cRfc, dFechaNac
                        FROM bdinteg:"informix".si_cliente sc 
                        INNER JOIN bdinteg:"informix".si_ctepm cpm ON sc.numcte = cpm.numcte    
                        WHERE sc.numcte = pNumCliente;
                END IF;
                                
                SELECT (sdo_prom1 + sdo_prom2 + sdo_prom3 + sdo_prom4 + sdo_prom5 + sdo_prom6 + sdo_prom7 + sdo_prom8 + sdo_prom9 + sdo_prom10 + sdo_prom11 + sdo_prom12)
                INTO cSumaProm
                FROM bdicheq:"informix".sc_retenisr 
                WHERE num_cte = pNumCliente AND ejercicio = pEjercicio AND cuenta =  pCuenta;
                
                SELECT COUNT(*) AS cMesesActivo
                INTO cMesesActivo
                        FROM (
                        SELECT sdo_prom1 as meses, 'sdo_prom1' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union 
                        SELECT sdo_prom2, 'sdo_prom2' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom3, 'sdo_prom3' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom4, 'sdo_prom4' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom5, 'sdo_prom5' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom6, 'sdo_prom6' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom7, 'sdo_prom7' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom8, 'sdo_prom8' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom9, 'sdo_prom9' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom10, 'sdo_prom10' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom11, 'sdo_prom11' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta
                        union
                        SELECT sdo_prom12, 'sdo_prom12' as num_saldo
                        FROM bdicheq:"informix".sc_retenisr
                        WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta)
                        WHERE meses <> 0;
                        
                        LET mMonto = cSumaProm / cMesesActivo;
                                
                        SELECT  interes_pagado
                        INTO mInteresPagado
                        FROM bdicheq:"informix".sc_retenisr 
						WHERE num_cte = pNumCliente
                        AND ejercicio = pEjercicio
                        AND cuenta =  pCuenta;
                                
                        SELECT consecutivo
                        INTO sConsecutivo
                        FROM bdilide:"informix".sl_ftc_cns                              
                        WHERE ejercicio = pEjercicio
                        AND tipo_rpt = pTipoReporte;
                        IF sConsecutivo IS NULL THEN 
                            LET sConsecutivo = 1;
                        END IF; 
                                
				IF (SELECT COUNT(num_cliente) FROM bdilide:"informix".sl_ftc_cte WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio)>0 THEN
                        LET iExiste = 1;
                END IF;
                
                IF (SELECT COUNT(num_cliente) FROM bdilide:"informix".sl_ftc_det WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio)>0 THEN
                        LET iExiste = 1;
                        SELECT razon_soc, nombre1, nombre2, apell_paterno, apell_materno, nom_calle, num_int, num_ext, colonia, delegacion, cod_postal, pais,ciudad, rfc, fecha_nac, cuenta, monto_cta, interes_pagado
                        INTO cCRazonSocial, cCNombre1,cCNombre2,cCApellPaterno,cCApellMaterno,cCCalle,cCNumIntCalle,cCNumExtCalle,cCColonia,cCDelegacion,cCCodPostal,cCPais,cCCiudad,cCRfc,dCFechaNac,cCCuenta, mCMonto, mCInteresPagado
                        FROM bdilide:"informix".sl_ftc_det
                        WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                        
                        IF (TRIM(cRazonSocial) <> TRIM(cCRazonSocial) OR TRIM(cApellPaterno) <> TRIM (cCApellPaterno) OR TRIM(cApellMaterno) <> TRIM(cCApellMaterno) OR  TRIM(cNombre1) <> TRIM(cCNombre1) OR TRIM(cNombre2) <> TRIM(cCNombre2) OR TRIM(cCalle) <> TRIM(cCCalle) OR TRIM(cNumIntCalle) <> TRIM(cCNumIntCalle) OR  TRIM(cNumExtCalle) <> TRIM(cCNumExtCalle) OR TRIM(cColonia) <> TRIM(cCColonia) OR TRIM(cDelegacion) <> TRIM(cCDelegacion) OR TRIM(cCodPostal) <> TRIM(cCCodPostal) OR TRIM(cPais) <> TRIM(cCPais) OR TRIM(cCiudad) <> TRIM(cCCiudad) OR TRIM(cRfc) <> TRIM(cCRfc) OR dFechaNac<> dCFechaNac OR mMonto <> mCMonto OR mInteresPagado <> mCInteresPagado OR TRIM(cCCuenta) <> TRIM(pCuenta)) THEN
                                LET iComplementaria = 1;                        
                        END IF;                        
                        IF (iComplementaria = 1 AND pTipoReporte = 'C') THEN
                                UPDATE bdilide:"informix".sl_ftc_cte
                                SET cuenta = pCuenta, tipo_rep = 'C', cns_rep = sConsecutivo
                                WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                                
                                UPDATE bdilide:"informix".sl_ftc_det
                                SET razon_soc = cRazonSocial, nombre1 = cNombre1, nombre2 = cNombre2, apell_paterno = cApellPaterno, apell_materno = cApellMaterno, nom_calle = cCalle, num_int = cNumIntCalle, num_ext = cNumExtCalle, colonia = cColonia, delegacion = cDelegacion, cod_postal = cCodPostal, pais = cPais, ciudad = cCiudad, rfc = cRfc, fecha_nac = dCFechaNac, cuenta = pCuenta, monto_cta = mMonto, interes_pagado = mInteresPagado
                                WHERE num_cliente = pNumCliente AND ejercicio = pEjercicio;
                        ELSE
                                LET cCodRet = '00293';
                                RETURN cCodRet;
                        END IF;                                
                END IF;
                                        
                IF iExiste = 0  THEN 
                        IF pTipoReporte = 'N' THEN
							INSERT INTO bdilide:"informix".sl_ftc_cte(ejercicio, num_cliente, cuenta, tipo_rep, cns_rep, fecha_cap, usuario)
							VALUES (pEjercicio, pNumCliente, pCuenta, pTipoReporte, 0, CURRENT, pUsuario);
                        ELIF pTipoReporte = 'C' THEN 
                            INSERT INTO bdilide:"informix".sl_ftc_cte(ejercicio, num_cliente, cuenta, tipo_rep, cns_rep, fecha_cap, usuario)
							VALUES (pEjercicio, pNumCliente, pCuenta, pTipoReporte, sConsecutivo, CURRENT, pUsuario);
                        END IF;
                        INSERT INTO bdilide:"informix".sl_ftc_det(num_cliente, razon_soc, nombre1, nombre2, apell_paterno, apell_materno, nom_calle, num_int, num_ext,colonia, delegacion, cod_postal, pais, ciudad, rfc, fecha_nac, cuenta, monto_cta, interes_pagado, ejercicio, usuario, fecha_insert)               
                        VALUES (pNumCliente, cRazonSocial, cNombre1, cNombre2, cApellPaterno, cApellMaterno, cCalle, cNumIntCalle, cNumExtCalle, cColonia, cDelegacion, cCodPostal, cPais, cCiudad,  cRfc, dFechaNac, pCuenta, mMonto, mInteresPagado, pEjercicio, pUsuario, CURRENT);
                END IF;
                                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00282';
                        RETURN cCodRet;
                END IF;         
                RETURN cCodRet;
        END;    
END PROCEDURE           
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 08/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA',
'DESCRIPCION:SPL que inserta los clientes fatca.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 25/05/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue del domicilio de los Clientes Persona Fisica.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 14/06/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue de la Colonia y Municipio de los Clientes Persona Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturactparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2),pTipoParam INTEGER, pValorAsociado INTEGER, pValorParam CHAR(5), pValor CHAR(200), pDesValor CHAR(200))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp 		CHAR(5);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cUltimoValor INTEGER;
	DEFINE cNewValor   CHAR(20);
	DEFINE sCveParam    SMALLINT;               
	DEFINE cValorParam  CHAR(5);
	DEFINE cValor       CHAR(200);
	DEFINE cDescValor   CHAR(200);
	DEFINE cUsuarioAct  CHAR(8);
	DEFINE dFechaAct    DATETIME YEAR TO SECOND;
	DEFINE cValorAsociadoPadre CHAR(5);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cUltimoValor  = 0;
	LET cNewValor     = 0;
	LET sCveParam    = 0;               
	LET cValorParam  = '';
	LET cValor       = '';
	LET cDescValor   = '';
	LET cUsuarioAct  = '';
	LET dFechaAct    = '';
	LET cValorAsociadoPadre = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_capturactparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = ''  OR pTipoParam IS NULL OR pValor = '' OR pDesValor = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE "informix".sp_cap_clasificadorparametrosfatca(pUsuario, pIdFuncion, pTipoParam, pValorAsociado)
		INTO cCodRetSp,cUltimoValor, cNewValor;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cap_clasificadorparametrosfatca';
			END IF;
		
			
		--REALIZA ALTA
		IF pBandera = '1'  THEN 		
			IF pTipoParam  = 1 OR pTipoParam = 5 THEN 
				SELECT COUNT (*)
				INTO iNoRegistros
				FROM bdilide:"informix".sl_ftc_prm
				WHERE cve_param = pTipoParam
				AND UPPER(TRIM(valor)) = UPPER(TRIM(pValor))
				AND UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor));
				
				IF iNoRegistros > 0 THEN 
					LET cCodRet = '00004';
					RETURN cCodRet;
				END IF;
				
				IF(SELECT COUNT(*) FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)) OR UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor))) = 0 THEN				
					INSERT INTO bdilide:"informix".sl_ftc_prm(cve_param, valor_param, valor, desc_valor, usuario_act, fecha_act)
					VALUES (pTipoParam, cNewValor, pValor, pDesValor,pUsuario, CURRENT);			
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cNewValor, '', '', pUsuario, 'INSERCION DE REGISTRO');				
				ELSE
					LET cCodRet = '00520';
					RETURN cCodRet;		
				END IF;				
			ELSE 				
				IF(SELECT COUNT(*) FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)) OR UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor))) = 0 THEN				
					INSERT INTO bdilide:"informix".sl_ftc_prm(cve_param, valor_param, valor, desc_valor, usuario_act, fecha_act)
					VALUES (pTipoParam, cNewValor, pValor, pDesValor,pUsuario, CURRENT);			
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cNewValor, '', '', pUsuario, 'INSERCION DE REGISTRO');
				ELSE 				
					LET cCodRet = '00520'; 
					RETURN cCodRet;		
				END IF;			
			END IF;		
			
		--REALIZA  MODIFICACION
		ELIF pBandera = '2' THEN 		
			IF pTipoParam >= 2 AND pTipoParam <= 4 THEN 			
		
				SELECT valor, desc_valor
				INTO cValor, cDescValor
				FROM bdilide:"informix".sl_ftc_prm
				WHERE cve_param = pTipoParam 	
				AND  valor_param  = pValorParam;
				
				SELECT valor_param, ((LEFT(valor_param,LENGTH(valor_param) -  CHARINDEX(".",valor_param))))
				INTO  cValorParam, cValorAsociadoPadre
				FROM bdilide:"informix".sl_ftc_prm 
				WHERE cve_param = pTipoParam
				AND valor_param = pValorParam;
				
				IF( pValor <> cValor) THEN 
					IF NOT EXISTS(SELECT valor FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(valor)) = UPPER(TRIM(pValor)))  THEN 
					
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   valor = pValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');	
						
					ELSE 
						LET cCodRet = '00520';			
						RETURN cCodRet;
					END IF;
				END IF;	

				IF( pDesValor <> cDescValor) THEN 
					IF NOT EXISTS(SELECT desc_valor FROM bdilide:"informix".sl_ftc_prm WHERE UPPER(TRIM(desc_valor)) = UPPER(TRIM(pDesValor)))  THEN 
					
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   desc_valor = pDesValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');	
			
					ELSE 
						LET cCodRet = '00520';			
						RETURN cCodRet;
					END IF;
				END IF;

				IF (pValorAsociado <> cValorAsociadoPadre )  THEN 					
				
						UPDATE bdilide:"informix".sl_ftc_prm 
						SET   valor_param  = cNewValor, usuario_act = pUsuario, fecha_act = CURRENT
						WHERE cve_param = pTipoParam
						AND  valor_param  = pValorParam;
						
					INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
					VALUES (CURRENT, pTipoParam, cValorParam, cValorParam, 'valor_param', pUsuario, 'ACTUALIZACION DE REGISTRO');	
				
				END IF;
			ELIF pTipoParam =  5 THEN 
				UPDATE bdilide:"informix".sl_ftc_prm 
					SET    valor = pValor,  desc_valor = pDesValor
					WHERE cve_param = pTipoParam
					AND  valor_param  = pValorParam;
				INSERT INTO  bdilide:"informix".sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
				VALUES (CURRENT, pTipoParam, cValorParam, cValorParam, 'valor_param', pUsuario, 'ACTUALIZACION DE REGISTRO');				
				
			END IF;	
		END IF;			

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 26/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que inserta  de nuevos parametros y actualizacion de parametros existentes para la generacion de reporte fatca.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 13/06/2016',
'DESCRIPCION:Se realiza la modificación de la actualizacion de campos en tabla de fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogocanalfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                SMALLINT  AS valor_param,
                CHAR(200)   AS valor;
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE sValorParam SMALLINT;
        DEFINE cValor CHAR(200);
        DEFINE iNoRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET sValorParam = 0;
        LET cValor  = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sValorParam,cValor;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogocanalfatca.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sValorParam,cValor;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, sValorParam,cValor;
			END IF;
			
			FOREACH 
				SELECT p.valor_param, UPPER(valor)
					INTO  sValorParam,cValor
				FROM bdilide:"informix".sl_ftc_prm p
					WHERE p.cve_param=1
					ORDER BY 1 ASC
					
			LET  iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, sValorParam,cValor WITH RESUME;            
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sValorParam,cValor;
			END IF;
	END;		
END PROCEDURE
DOCUMENT 'AUTOR:Martha Salgado Mendoza ',
'FECHA: 27/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA',
'DESCRIPCION: SPL que obtiene los valores para el tipo de parametro CANAL',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogoclasificacionfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS c_vparam,
			CHAR(200) AS c_desc_vparam;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cCvParam CHAR(5);
	DEFINE cDescVParam CHAR(200);
	DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCvParam = '';
	LET cDescVParam = '';
	LET iNoRegistros = 0;	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCvParam, cDescVParam ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogoclasificacionfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCvParam, cDescVParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCvParam, cDescVParam;
		END IF;
		
		FOREACH SELECT c_vparam, c_desc_vparam
			INTO cCvParam, cDescVParam
			FROM bdilide:sl_ftc_clas_cat
			ORDER BY 1
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cCvParam, cDescVParam WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet,  cCvParam, cDescVParam; 
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 10/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de catalogos clasificacion Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_catalogotipoparamfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			      INTEGER AS cve_param,
				  CHAR(100) AS desc_param;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCveParam INTEGER;
	DEFINE cDescParam CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCveParam =0; 
	LET cDescParam ='';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveParam, cDescParam ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_catalogotipoparamfatca.out';
		--TRACE ON;
		
		-- VALIDACION DE USUARIOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iCveParam, cDescParam ;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iCveParam, cDescParam ;
		END IF;

		FOREACH SELECT cve_param, desc_param
			INTO iCveParam, cDescParam
			FROM bdilide:sl_ftc_cat
			ORDER BY 1
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iCveParam, cDescParam WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCveParam, cDescParam; 
		END IF;		
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de catalogos tipo parametro Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_clasificadorparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParam INTEGER, pValorAsociado INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER AS ultimo_valor,
		CHAR(20) AS new_valor;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUltimoValor INTEGER;
	DEFINE cNewValor   CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cUltimoValor  = 0;
	LET cNewValor     = 0;
		
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUltimoValor, cNewValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_clasificadorparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		IF pTipoParam >= 2 AND pTipoParam <= 4 THEN 
		
			SELECT ultimo_val, LEFT(ultimo_val,CHARINDEX(".",ultimo_val)) || (SUBSTRING(ultimo_val FROM CHARINDEX(".",ultimo_val)+1 FOR ( LENGTH(ultimo_val)-CHARINDEX(".",ultimo_val))) + 1)::DECIMAL(9,0) AS nuevo_valor
			INTO cUltimoValor, cNewValor			
			FROM
				(SELECT MAX(valor_param) AS ultimo_val
				FROM bdilide:'informix'.sl_ftc_prm
				WHERE cve_param = pTipoParam AND valor_param >= pValorAsociado  AND valor_param < pValorAsociado + 1);
						
			IF cUltimoValor IS NULL THEN 
				LET cNewValor = pValorAsociado;
			ELIF cUltimoValor::INTEGER > 0  AND cNewValor IS NULL THEN
				LET cNewValor = cUltimoValor + .1;
			END IF;
			
			RETURN cCodRet, cUltimoValor, cNewValor;
		
		ELIF pTipoParam = 1 OR pTipoParam = 5 THEN
		
			SELECT ultimo_val, (ultimo_val + 1) AS nuevo_valor 
			INTO cUltimoValor, cNewValor
			FROM 
				(SELECT MAX(valor_param::INTEGER) AS ultimo_val
				FROM bdilide:'informix'.sl_ftc_prm
				WHERE  cve_param = pTipoParam);
			
			IF cUltimoValor IS NULL  THEN 
				LET cNewValor =  1;
				RETURN cCodRet, cUltimoValor, cNewValor;
			END IF;			
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cUltimoValor, cNewValor;
		END IF;
		
		RETURN cCodRet, cUltimoValor, cNewValor;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 025/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que obtiene la clasificacion dependiendo el tipo de parametro requerido.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consconsecutivonormalfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),  pEjercicio SMALLINT)
		RETURNING CHAR(5) AS codret,
		SMALLINT AS consecutivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sConsecutivo SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sConsecutivo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sConsecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consconsecutivonormalfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		SELECT consecutivo 
		INTO sConsecutivo 
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio
		AND tipo_rpt = 'N';
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		RETURN cCodRet, sConsecutivo;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que consulta el numero consecutivo del tipo de reporte normal para el archivo xml de Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consdtalleclientefatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cliente,
		CHAR(150)       AS nombre,
		CHAR(20)        AS num_cuenta,
		DECIMAL(16,2)   AS saldo,
		CHAR (1)        AS tipo_repeporte;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCte  CHAR(20);
	DEFINE cNombre      CHAR(150);
	DEFINE cNumCuenta   CHAR(20);
	DEFINE dSaldo   DECIMAL(16,2);
	DEFINE cTipoReporte     CHAR(1);
	DEFINE sConsecutivoRpt  SMALLINT;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cActividad CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCte= '';
	LET cNombre     = '';
	LET cNumCuenta  = '';
	LET dSaldo              =0.00;
	LET cTipoReporte = '';
	LET sConsecutivoRpt = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cActividad = 'CONSULTA FATCA';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consdtalleclientefatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT MAX(cns_rep)
		INTO sConsecutivoRpt
		FROM bdilide:"informix".sl_ftc_cte
		WHERE ejercicio = pEjercicio
		AND tipo_rep = pTipoReporte;	
			
		IF (pTipoReporte = '' ) THEN                 
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
					CASE WHEN (NVL(apell_paterno,"") || NVL(apell_materno,"") || NVL(nombre1,"") || NVL(nombre2,"")) != "" THEN TRIM(NVL(apell_paterno,"")) || " "|| TRIM(NVL(apell_materno,"")) || " " || TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,""))
                    ELSE TRIM(razon_soc)  END AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
					INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
					FROM bdilide:"informix".sl_ftc_cte a
						INNER JOIN  bdilide:"informix".sl_ftc_det b     ON a.num_cliente = b.num_cliente
					WHERE a.ejercicio = b.ejercicio
						AND a.ejercicio = pEjercicio                            
					ORDER BY a.num_cliente ASC, a.cuenta ASC
			
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
			END FOREACH;
						
		ELSE 
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
					CASE WHEN (NVL(apell_paterno,"") || NVL(apell_materno,"") || NVL(nombre1,"") || NVL(nombre2,"")) != "" THEN TRIM(NVL(apell_paterno,"")) || " "|| TRIM(NVL(apell_materno,"")) || " " || TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,""))
                    ELSE TRIM(razon_soc)  END AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
					INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
					FROM bdilide:"informix".sl_ftc_cte a
						INNER JOIN  bdilide:"informix".sl_ftc_det b     ON a.num_cliente = b.num_cliente
					WHERE a.ejercicio = b.ejercicio
						AND a.ejercicio = pEjercicio
						AND a.tipo_rep = pTipoReporte
						AND a.cns_rep = sConsecutivoRpt
					ORDER BY a.num_cliente ASC, a.cuenta ASC                
			
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
			END FOREACH;
		END IF;
												   
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
		END IF;         
	
	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca.',
'AUTOR: M.D.S Sandra Cano',
'FECHA: 27/05/2016',
'DESCRIPCION: Modificacion del SPL para desplegar el la razon social para los clientes Persona Moral.',
'AUTOR: M.D.S Sandra Cano',
'FECHA: 02/06/2016',
'DESCRIPCION: Modificacion del SPL para despliegue correcto del nombre de Cliente Persona Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consordenxsdfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		SMALLINT AS cve_param,
		CHAR(5) AS valor_param,
		CHAR(200) AS valor,
		CHAR(200) AS desc_valor,	
		CHAR(8) AS usuario_act,
		DATETIME YEAR TO SECOND  AS fecha_act;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sCveParam	SMALLINT;
	DEFINE  cValorParam	CHAR(5);
	DEFINE  cValor	    CHAR(200);
	DEFINE  cDescValor	CHAR(200);
	DEFINE  cUsuarioAct	CHAR(8);
	DEFINE  dFechaAct	DATETIME YEAR TO SECOND;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sCveParam	= 0;
	LET cValorParam	= '';
	LET cValor	    = '';
	LET cDescValor	= '';
	LET cUsuarioAct	= '';
	LET dFechaAct	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consordenxsdfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;
		
		FOREACH SELECT  *
			INTO sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct
			FROM bdilide:'informix'.sl_ftc_prm
			WHERE cve_param = 6
			ORDER BY 2
						
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sCveParam, cValorParam, cValor, cDescValor, cUsuarioAct, dFechaAct;
		END IF;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene el orden de XSD Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_constintercambioparamfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pBandera CHAR(1), pValorParam CHAR(5), pValor CHAR(200),pDesValor CHAR(200))
        RETURNING CHAR(5) AS codret,
            CHAR(5)    AS valor_param,
            CHAR(5)    AS valor_param1,
            CHAR(200)  AS valor,
            CHAR(200)  AS valor1,
            CHAR(200)  AS des_valor,
            CHAR(200)  AS des_valor1;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cValorParam   CHAR(5);
        DEFINE cValorParam1  CHAR(5);
        DEFINE cValor        CHAR(200);
        DEFINE cValor1       CHAR(200);
        DEFINE cDescValor    CHAR(200);
        DEFINE cDescValor1    CHAR(200);
        DEFINE iNoRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cValorParam  = '';
        LET cValorParam1  = '';
        LET cValor       = '';
        LET cValor1       = '';
        LET cDescValor   = '';
        LET cDescValor1   = '';
        LET iNoRegistros = 0;

        BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END EXCEPTION;
			
			ON EXCEPTION IN (-703)
				LET cCodRet = '00281';
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END EXCEPTION;	

			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_constintercambioparamfatca.out';
			--TRACE ON;

			IF pUsuario = '' OR pIdFuncion = '' OR pBandera = ''  OR  pValorParam = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
				RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
			END IF;

			IF pBandera = 1 THEN  -- intercambio de valor parametro
					SELECT valor, valor_param
						INTO  cValor, cValorParam
                    FROM bdilide:'informix'.sl_ftc_prm
						WHERE UPPER(valor) = UPPER(TRIM(pValor))
						AND cve_param = 1;

                    SELECT valor, valor_param
						INTO  cValor1, cValorParam1
                    FROM bdilide:'informix'.sl_ftc_prm
						WHERE valor_param = pValorParam
						AND cve_param = 1;

                    UPDATE  bdilide:'informix'.sl_ftc_prm
                        SET  valor = cValor
                        WHERE cve_param = 1
                        AND valor_param = cValorParam1;

                    UPDATE bdilide:'informix'.sl_ftc_prm
                        SET  valor = cValor1
                        WHERE cve_param = 1
                        AND valor_param = cValorParam;
							
					INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
						VALUES (CURRENT, 1, cValorParam, cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
					INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
						VALUES (CURRENT, 1, pValorParam, cValor1, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						
                ELIF pBandera = 2 THEN  -- intercambio de canal

					SELECT COUNT(*) AS buscaparam
					INTO iNoRegistros
					FROM bdilide:'informix'.sl_ftc_prm
					where desc_valor = UPPER(TRIM(pDesValor))
					AND cve_param = 1;

                    IF (iNoRegistros = 1) THEN

                        SELECT  valor_param,  desc_valor
							INTO   cValorParam, cDescValor
                        FROM bdilide:'informix'.sl_ftc_prm
							WHERE desc_valor = UPPER(TRIM(pDesValor))
							AND cve_param = 1;

                        SELECT  valor_param, desc_valor
							INTO   cValorParam1, cDescValor1
                        FROM bdilide:'informix'.sl_ftc_prm
							WHERE valor_param = pValorParam
							AND cve_param = 1;

                        UPDATE  bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor))
							WHERE cve_param = 1
							AND valor_param = cValorParam1;

                        UPDATE bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor1))
							WHERE cve_param = 1
							AND valor_param = cValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor1, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');

                ELIF (iNoRegistros = 0) THEN
						SELECT desc_valor
							INTO cDescValor
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE cve_param = 1
                            AND valor_param = pValorParam;
								
                        UPDATE bdilide:'informix'.sl_ftc_prm
                            SET  desc_valor = UPPER(TRIM(pDesValor))
                            WHERE cve_param = 1
                            AND valor_param = pValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');

                        END IF;

                ELIF pBandera = 3 THEN

					SELECT COUNT(*) AS buscaparam
						INTO iNoRegistros
					FROM bdilide:'informix'.sl_ftc_prm
						WHERE UPPER(desc_valor) = UPPER(TRIM(pDesValor))
						AND cve_param = 1;

					IF (iNoRegistros = 1) THEN
						SELECT   valor_param, valor, desc_valor
							INTO  cValorParam, cValor, cDescValor
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE  UPPER(desc_valor) = UPPER(TRIM(pDesValor))
							AND  UPPER(valor) = UPPER(TRIM(pValor))
							AND cve_param = 1;

						SELECT  valor_param, valor, desc_valor
							INTO   cValorParam1, cvalor1, cDescValor1
						FROM bdilide:'informix'.sl_ftc_prm
							WHERE valor_param = pValorParam
							AND cve_param = 1;

						UPDATE  bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor)), valor = cValor
							WHERE cve_param = 1
							AND valor_param = cValorParam1;

						UPDATE bdilide:'informix'.sl_ftc_prm
							SET  desc_valor = UPPER(TRIM(cDescValor1)), valor = cValor1
							WHERE cve_param = 1
							AND valor_param = cValorParam;
								
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, cValorParam1, cDescValor1, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						

                        ELSE IF (iNoRegistros = 0) THEN
							SELECT desc_valor
								INTO cDescValor
							FROM bdilide:'informix'.sl_ftc_prm
								WHERE cve_param = 1
								AND valor_param = pValorParam;

                            UPDATE bdilide:'informix'.sl_ftc_prm
                                SET  desc_valor = UPPER(TRIM(pDesValor))
                                WHERE cve_param = 1
                                AND valor_param = pValorParam;
								
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
							VALUES (CURRENT, 1, pValorParam, cDescValor, 'desc_valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
							

                            SELECT valor, valor_param
                                INTO  cValor, cValorParam
                            FROM bdilide:'informix'.sl_ftc_prm
                                WHERE UPPER(valor) = UPPER(TRIM(pValor))
                                AND cve_param = 1;

                            SELECT valor, valor_param
                                INTO  cValor1, cValorParam1
                            FROM bdilide:'informix'.sl_ftc_prm
                                WHERE valor_param = pValorParam
                                AND cve_param = 1;

							UPDATE  bdilide:'informix'.sl_ftc_prm
								SET  valor = pValor
								WHERE cve_param = 1
								AND valor_param = pValorParam;

							UPDATE bdilide:'informix'.sl_ftc_prm
									SET  valor = cValor1
								WHERE cve_param = 1
								AND valor_param = cValorParam;
								
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
								VALUES (CURRENT, 1,cValorParam , cValor, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
							INSERT INTO  bdilide:'informix'.sl_ftc_log(fecha_act, cve_param,valor_param,valor_ant, campo_act,usuario,actividad)
								VALUES (CURRENT, 1, pValorParam, cValor1, 'valor', pUsuario, 'ACTUALIZACION DE REGISTRO');
						END IF;
                    END IF;
					
                END IF;

                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                    LET cCodRet = '00283';
                    RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
                END IF;

                RETURN cCodRet, cValorParam, cValorParam1, cValor, cValor1, cDescValor, cDescValor1;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 26/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: PARAMETROS FATCA ',
'DESCRIPCION:SPL que realiza el intercambio de canales, des_canales de los parametros fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaclientefatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR(20) AS num_cliente,
                CHAR(150)       AS nombre,
                CHAR(20)        AS num_cuenta,
                DECIMAL(16,2)   AS saldo,
                CHAR (1)        AS tipo_repeporte;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumCte  CHAR(20);
        DEFINE cNombre      CHAR(150);
        DEFINE cNumCuenta   CHAR(20);
        DEFINE dSaldo   DECIMAL(16,2);
        DEFINE cTipoReporte     CHAR(1);
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        DEFINE cActividad CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cNumCte= '';
        LET cNombre     = '';
        LET cNumCuenta  = '';
        LET dSaldo              =0.00;
        LET cTipoReporte = '';
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        LET cActividad = 'CONSULTA FATCA';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaclientefatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                
                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;
                IF (pTipoReporte = '' ) THEN 
                
                        FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
                        TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
                                INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
                                FROM bdilide:'informix'.sl_ftc_cte a
                                INNER JOIN  bdilide:'informix'.sl_ftc_det b     ON a.num_cliente = b.num_cliente
                                WHERE a.ejercicio = b.ejercicio
                                AND a.ejercicio = pEjercicio                            
                                ORDER BY a.num_cliente ASC, a.cuenta ASC
                        
                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
                        END FOREACH;
                                
                ELSE 
                
                        FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  a.num_cliente, 
                                TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
                                INTO cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte
                                FROM bdilide:'informix'.sl_ftc_cte a
                                INNER JOIN  bdilide:'informix'.sl_ftc_det b     ON a.num_cliente = b.num_cliente
                                WHERE a.ejercicio = b.ejercicio
                                AND a.ejercicio = pEjercicio
                                AND a.tipo_rep = pTipoReporte
                                ORDER BY a.num_cliente ASC, a.cuenta ASC                
                
                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cNumCte, UPPER(TRIM(cNombre)), cNumCuenta, dSaldo, UPPER(TRIM(cTipoReporte)) WITH RESUME;               
                        END FOREACH;
                END IF;
                INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
                VALUES (CURRENT, 0, '', '', '', pUsuario, 'CONSULTA FATCA');
                                        
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cNumCte, cNombre, cNumCuenta, dSaldo, cTipoReporte;
                END IF;         
        
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaclientefatca_total(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4), pTipoReporte CHAR (1))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
		BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;		
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaclientefatca_total.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pEjercicio = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF (pTipoReporte = '' ) THEN 
		
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM 
				(SELECT a.num_cliente, TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
				FROM bdilide:'informix'.sl_ftc_cte a
				INNER JOIN  bdilide:'informix'.sl_ftc_det b	ON a.num_cliente = b.num_cliente
				WHERE a.ejercicio = b.ejercicio
				AND a.ejercicio = pEjercicio				
				ORDER BY a.num_cliente ASC, a.cuenta ASC);
		ELSE 
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM 
				(SELECT a.num_cliente, TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(nombre1) || ' ' || TRIM(nombre2) AS nombre, b.cuenta, b.monto_cta, a.tipo_rep
				FROM bdilide:'informix'.sl_ftc_cte a
				INNER JOIN  bdilide:'informix'.sl_ftc_det b	ON a.num_cliente = b.num_cliente
				WHERE a.ejercicio = b.ejercicio
				AND a.ejercicio = pEjercicio	
				AND a.tipo_rep = pTipoReporte);
		END IF;
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA FATCA',
'DESCRIPCION:SPL que consulta el total de clientes fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaconsecutivofatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio SMALLINT, pTipoRpt CHAR(1), pFolio CHAR(20))
		RETURNING CHAR(5) AS codret,
		SMALLINT AS consecutivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  sConsecutivo SMALLINT;
	DEFINE cFolio CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sConsecutivo = 0;
	LET cFolio = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sConsecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaconsecutivofatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' OR pTipoRpt = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;				
		IF NOT EXISTS (SELECT consecutivo FROM bdilide:'informix'.sl_ftc_cns WHERE ejercicio = pEjercicio AND tipo_rpt = pTipoRpt) THEN 
			
			IF pTipoRpt = 'N' THEN 
			
				INSERT INTO bdilide:'informix'.sl_ftc_cns(ejercicio, tipo_rpt, consecutivo,usuario, fecha_act)
				VALUES (pEjercicio, pTipoRpt, 1 , pUsuario, CURRENT);
				
				SELECT consecutivo 
					INTO sConsecutivo 
					FROM bdilide:'informix'.sl_ftc_cns
					WHERE ejercicio = pEjercicio
					AND tipo_rpt = pTipoRpt;

			ELSE 
				IF pEjercicio = '' OR pTipoRpt = '' OR  pFolio = '' THEN 
					LET cCodRet = '00003';
					RETURN cCodRet, sConsecutivo;
				END IF;
			
				INSERT INTO bdilide:'informix'.sl_ftc_cns(ejercicio, tipo_rpt, consecutivo, folio, usuario, fecha_act)
				VALUES (pEjercicio, pTipoRpt, 1,  pfolio , pUsuario, CURRENT);
				
					SELECT consecutivo 
					INTO sConsecutivo 
					FROM bdilide:'informix'.sl_ftc_cns
					WHERE ejercicio = pEjercicio
					AND tipo_rpt = pTipoRpt;
				
				INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
                VALUES (CURRENT, 0, '', pFolio, 'folio', pUsuario, 'INSERCION FOLIO ANTERIOR');
			END IF;
		
		ELSE				
			SELECT consecutivo, folio
			INTO sConsecutivo, cFolio
			FROM bdilide:'informix'.sl_ftc_cns 
			WHERE ejercicio = pEjercicio 
			AND tipo_rpt = pTipoRpt;
			
		
		IF (sConsecutivo IS NULL OR sConsecutivo = 0 ) THEN 
			LET sConsecutivo = 1;		
		ELSE 		
			LET sConsecutivo = sConsecutivo + 1;		
		END IF;
			IF pTipoRpt = 'N' THEN 			
				UPDATE bdilide:'informix'.sl_ftc_cns
				SET consecutivo = sConsecutivo
				WHERE ejercicio = pEjercicio
				AND tipo_rpt = pTipoRpt;
			ELSE 
				UPDATE bdilide:'informix'.sl_ftc_cns
				SET consecutivo = sConsecutivo, folio = pFolio
				WHERE ejercicio = pEjercicio
				AND tipo_rpt = pTipoRpt;				
				INSERT INTO  bdilide:sl_ftc_log(fecha_act, cve_param, valor_param, valor_ant, campo_act, usuario, actividad)
					VALUES (CURRENT, 0, '', pFolio, 'folio', pUsuario, 'INSERCION FOLIO ANTERIOR');
			END IF;
		END IF;	
		
		SELECT folio
		INTO cFolio
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio
		AND tipo_rpt = 'C';
		
		IF cFolio <> '' AND pTipoRpt = 'C' THEN 
			UPDATE bdilide:'informix'.sl_ftc_prm
			set valor = 'C'
			WHERE cve_param = 5
			AND valor_param = 7;
			
		ELSE
			UPDATE bdilide:'informix'.sl_ftc_prm
			set valor = 'N'
			WHERE cve_param = 5
			AND valor_param = 7;
		END IF;
			
		RETURN cCodRet, sConsecutivo;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sConsecutivo;
		END IF;
		
		RETURN cCodRet, sConsecutivo;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 10/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que consulta el numero consecutivo de complemento para el archivo xml de Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultacredencialesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(200) AS usuario,
		CHAR(200) AS password,
		CHAR(200) AS puerto,
		CHAR(200) AS ip,
		CHAR(200) AS pscp;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cCredenciales CHAR(200);
	DEFINE cUsuario CHAR(200);
	DEFINE cPassword CHAR(200);
	DEFINE cPuerto CHAR(200);
	DEFINE cIp CHAR(200);
	DEFINE cPscp CHAR(200);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cCredenciales = '';
	LET cUsuario = '';
	LET cPassword = '';
	LET cPuerto = '';
	LET cIp = '';
	LET cPscp = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultacredencialesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
		END IF;
		
		SELECT valor
		INTO cUsuario
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 1;

		SELECT valor
		INTO cPassword
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 2;

		SELECT valor
		INTO cPuerto
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 3;

		SELECT valor
		INTO cIp
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 4;
		
		SELECT valor
		INTO cPscp
		FROM bdilide:'informix'.sl_ftc_prm 
		WHERE cve_param = 7
		AND valor_param = 5;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cUsuario, cPassword, cPuerto, cIp, cPscp;
        END IF;
		
		RETURN cCodRet, TRIM(cUsuario), TRIM(cPassword), TRIM(cPuerto), TRIM(cIp), TRIM(cPscp);
		
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/04/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene los parametros de las credenciales para obtener la ruta productiva de fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultadtallectesfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pEjercicio CHAR(4), pTipoReporte CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(100)AS razon_soc,
		CHAR(30) AS nombre1,
		CHAR(30) AS nombre2,
		CHAR(30) AS apell_paterno,
		CHAR(30) AS apell_materno, 
		CHAR(130) AS direccion,
		CHAR(20) AS tin,
		CHAR(13) AS rfc,
		CHAR(10) AS fecha_nac,
		CHAR(20) AS cuenta,
		DECIMAL (16,2) AS monto_cta,		
		CHAR(4)  AS ejercicio,
		CHAR(2)  AS tipo_persona,
		CHAR(26) AS apellido_paterno,
		CHAR(26) AS apellido_materno,
		CHAR(26) AS nombres1,
		CHAR(26) AS nombres2,
		CHAR(13) AS rfc_pm,
		CHAR(120) AS direcciones,
		CHAR(10) AS fecha_nacimiento,
		MONEY (16,2) AS interes_pagado;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE cRazonSoc       CHAR(100);
	DEFINE cNombre1        CHAR(30);
	DEFINE cNombre2        CHAR(30); 
	DEFINE cApellPaterno   CHAR(30); 
	DEFINE cApellMaterno   CHAR(30); 
	DEFINE cNomCalle       CHAR(30); 
	DEFINE cDireccion	   CHAR(130);
	DEFINE cTin            CHAR(20); 
	DEFINE cRfc            CHAR(13); 
	DEFINE cFechaNac       CHAR(10); 
	DEFINE cCuenta         CHAR(20); 
	DEFINE dMontoCta 		DECIMAL (16,2);
	DEFINE mInteresPagado MONEY (16,2);
	DEFINE cEjercicio		CHAR(4);
	DEFINE cTipo_persona	CHAR(2);
	DEFINE cNumCte CHAR(20);
	DEFINE cApellPat	CHAR(26);
	DEFINE cApellMat  CHAR(26);
	DEFINE cNombres1         CHAR(26);
	DEFINE cNombres2         CHAR(26);
	DEFINE cRfc1          CHAR(13);
	DEFINE cDirecciones      CHAR(120);
	DEFINE cFechaNacim       CHAR(10); 
	DEFINE sConsecutivo 	SMALLINT;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente       =  '';
	LET cRazonSoc       =  '';
	LET cNombre1        =  '';
	LET cNombre2        =  '';
	LET cApellPaterno   =  '';
	LET cApellMaterno   =  '';
	LET cDireccion       =  '';
	LET cTin            =  '';
	LET cRfc            =  '';
	LET cFechaNac       =  '';
	LET cCuenta         =  '';
	LET dMontoCta 	    =  0.00;
	LET mInteresPagado = 0.0;
	LET cEjercicio	    =  '';
	LET cTipo_persona	=  '';
	LET cNumCte       =  '';
	LET cApellPat	= '';
	LET cApellMat   = '';
	LET cNombres1   = '';
	LET cNombres2   = '';
	LET cRfc1        = '';
	LET cDirecciones  = '';
	LET cFechaNacim	= '';
	LET sConsecutivo = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultadtallectesfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjercicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT MAX(cns_rep)
				INTO sConsecutivo
				FROM bdilide:"informix".sl_ftc_cte
				WHERE ejercicio = pEjercicio
				AND tipo_rep = pTipoReporte;	
				
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion fisica.num_cliente,fisica.razon_soc,  fisica.nombre1, fisica.nombre2, fisica.apell_paterno, fisica.apell_materno, fisica.direccion, fisica.tin, fisica.rfc, 
				SUBSTRING(fisica.fecha_nac FROM 7 FOR 4) || '-'|| SUBSTRING(fisica.fecha_nac FROM 1 FOR 2) || '-' ||SUBSTRING(fisica.fecha_nac FROM 4 FOR 2), fisica.cuenta, fisica.monto_cta, fisica.ejercicio, fisica.tpo_persona,apoderado.numcte,apoderado.apell_paterno, apoderado.apell_materno, apoderado.nombre1, apoderado.nombre2, apoderado.rfc,apoderado.direcciones, SUBSTRING(apoderado.fecha_nac FROM 7 FOR 4) || '-'|| SUBSTRING(apoderado.fecha_nac FROM 1 FOR 2) || '-' ||SUBSTRING(apoderado.fecha_nac FROM 4 FOR 2),fisica.interes_pagado
				INTO cNumCliente, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNumCte, cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim,mInteresPagado
				FROM
				(SELECT cte.num_cliente, det.razon_soc,  det.nombre1, det.nombre2, det.apell_paterno, det.apell_materno, 
				TRIM(CASE WHEN NVL(det.nom_calle,"") != "" THEN TRIM(det.nom_calle) || '/' ELSE TRIM(NVL(det.nom_calle,"")) END  ||
				CASE WHEN NVL(det.num_ext,"") != "" THEN TRIM(det.num_ext) || '/' ELSE TRIM(NVL(det.num_ext,"")) END  ||
				CASE WHEN NVL(det.num_int,"") != "" THEN TRIM(det.num_int) || '/' ELSE TRIM(NVL(det.num_int,"")) END  ||
				CASE WHEN NVL(det.colonia,"") != "" THEN TRIM(det.colonia) || '/' ELSE TRIM(NVL(det.colonia,"")) END  ||
				CASE WHEN NVL(det.delegacion,"") != "" THEN TRIM(det.delegacion) || '/' ELSE TRIM(NVL(det.delegacion,"")) END  ||
				CASE WHEN NVL(det.pais,"") != "" THEN TRIM(det.pais) || '/' ELSE TRIM(NVL(det.pais,"")) END  ||
				CASE WHEN NVL(det.ciudad,"") != "" THEN TRIM(det.ciudad) || '/' ELSE TRIM(NVL(det.ciudad,"")) END ||
				CASE WHEN NVL(det.cod_postal,"") != "" THEN TRIM(det.cod_postal)  ELSE TRIM(NVL(det.cod_postal,"")) END) AS direccion,  
				det.tin, det.rfc, det.fecha_nac, det.cuenta, det.monto_cta,  det.ejercicio, si_cliente.tpo_persona, det.interes_pagado
				FROM bdilide:"informix".sl_ftc_cte cte 
				INNER JOIN bdilide:"informix".sl_ftc_det det ON det.num_cliente = cte.num_cliente
				INNER JOIN bdinteg:"informix".si_cliente si_cliente ON cte.num_cliente = si_cliente.numcte
				WHERE cte.ejercicio = det.ejercicio
				AND cte.ejercicio = pEjercicio
				AND cte.cns_rep = sConsecutivo
				AND cte.tipo_rep = pTipoReporte) fisica
				LEFT JOIN 
				(
				SELECT numcte, numcteapoderado, apell_paterno, apell_materno, nombre1, nombre2, rfc,
				TRIM(CASE WHEN NVL(nombrecalle,"") != "" THEN TRIM(nombrecalle) || '/' ELSE TRIM(NVL(nombrecalle,"")) END  ||
				CASE WHEN NVL(numeroextcalle,"") != "" THEN TRIM(numeroextcalle) || '/' ELSE TRIM(NVL(numeroextcalle,"")) END  ||
				CASE WHEN NVL(numerointcalle,"") != "" THEN TRIM(numerointcalle) || '/' ELSE TRIM(NVL(numerointcalle,"")) END  ||
				CASE WHEN NVL(nombrezona,"") != "" THEN TRIM(nombrezona) || '/' ELSE TRIM(NVL(nombrezona,"")) END  ||
				CASE WHEN NVL(municipiozona,"") != "" THEN TRIM(municipiozona) || '/' ELSE TRIM(NVL(municipiozona,"")) END  ||
				CASE WHEN NVL(nombre,"") != "" THEN TRIM(nombre) || '/' ELSE TRIM(NVL(nombre,"")) END  ||
				CASE WHEN NVL(nombreciudad,"") != "" THEN TRIM(nombreciudad) || '/' ELSE TRIM(NVL(nombreciudad,"")) END ||
				CASE WHEN NVL(cod_postal,"") != "" THEN TRIM(cod_postal)  ELSE TRIM(NVL(cod_postal,"")) END) AS direcciones, 
				fecha_nac
				FROM
				((SELECT apo.numcte, apo.numcteapoderado, si.apell_paterno, si.apell_materno, si.nombre1, si.nombre2, si.rfc, dic.numerocalle, dic.numerocolonia, dic.municipio, dic.pais, dic.ciudad, dic.numeroextcalle, dic.numerointcalle,  dic.cod_postal, cpf.fecha_nac
				FROM bdinteg:"informix".si_apoderado apo
				INNER JOIN bdinteg:"informix".si_cliente si ON apo.numcteapoderado = si.numcte
				INNER JOIN bdinteg:"informix".si_direcciones_actual dic ON apo.numcteapoderado = dic.numcte
				INNER JOIN bdinteg:"informix".si_ctepf cpf ON apo.numcteapoderado = cpf.numcte
				WHERE dic.tipo_dir = 1) dic
				LEFT JOIN bdinteg:"informix".si_catcalles AS c ON dic.numerocalle = c.numerocalle 
				LEFT JOIN bdinteg:"informix".si_catzonas cz ON dic.numerocolonia = cz.numerocolonia
				AND cz.municipiozona = dic.municipio 
				LEFT JOIN bdinteg:"informix".si_paises p ON dic.pais = p.pais
				LEFT JOIN bdinteg:"informix".si_catciudades cc ON dic.ciudad = cc.numerociudad) 
				) apoderado
				ON fisica.num_cliente = apoderado.numcte
	
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cRazonSoc, UPPER(TRIM(cNombre1)), UPPER(TRIM(cNombre2)), UPPER(TRIM(cApellPaterno)), UPPER(TRIM(cApellMaterno)), UPPER(TRIM(cDireccion)), cTin, UPPER(TRIM(cRfc)), cFechaNac, cCuenta, dMontoCta, cEjercicio, cTipo_persona, UPPER(TRIM(cNombres1)), UPPER(TRIM(cNombres2)), UPPER(TRIM(cApellPat)), UPPER(TRIM(cApellMat)),UPPER(TRIM(cRfc1)),UPPER(TRIM(cDirecciones)),cFechaNacim, mInteresPagado WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
		RETURN cCodRet, cRazonSoc,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cDireccion,cTin,cRfc,cFechaNac,cCuenta,dMontoCta, cEjercicio,cTipo_persona,cNombres1,cNombres2,cApellPat,cApellMat,cRfc1,cDirecciones,cFechaNacim, mInteresPagado;
		END IF;		
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/02/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA',
'DESCRIPCION:SPL que consulta el detalle de los clientes fatca para la genracion del reporte XML.',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 26/05/2016',
'DESCRIPCION: Modificación del SPL para corregir el despliegue del domicilio de los Clientes Persona Moral y Fisica.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultafolioanteriorfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFolio CHAR(20);
	DEFINE cConsecutivo CHAR(4);
	DEFINE iNoRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFolio = '';
	LET cConsecutivo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultafolioanteriorfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio =''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT folio, consecutivo
		INTO cFolio, cConsecutivo
		FROM bdilide:'informix'.sl_ftc_cns
		WHERE ejercicio = pEjercicio AND tipo_rpt = 'C';
		
		LET iNoRegistros = iNoRegistros + 1;		
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00767';
			RETURN cCodRet;		
		END IF;		
	
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio ',
'FECHA: 09/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza consulta del folio anterior para el reporte fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultageneroisrfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCliente CHAR(20), pNumCuenta CHAR(20), pEjercicio CHAR(4), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret,
	  CHAR(20) AS num_cliente,
	  CHAR(20) AS num_cuenta,
	  CHAR(4) AS ejercicio,
	  CHAR(104) AS nom_completo;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR (20);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cEjercicio CHAR(4);
	DEFINE cNomCompleto CHAR(104);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNoCliente CHAR(20);
	DEFINE cTipoPer CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNoRegistros = 0;
	LET cNumCliente = '';
	LET cNumCuenta='';
	LET cEjercicio = '';
	LET cNomCompleto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNoCliente = '';
	LET cTipoPer = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultageneroisrfatca.out';
		--TRACE ON;
		
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pEjercicio = '' OR pBandera =''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		SELECT numcte, tpo_persona
		INTO cNoCliente, cTipoPer
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCliente;
		
		IF cTipoPer = '01' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, 
				TRIM(b.nombre1)||' '||TRIM(b.nombre2)||' '||TRIM(b.apell_paterno)||' '||TRIM( b.apell_materno)
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		ELIF cTipoPer = '02' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, razon_social
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		END IF;		
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de clientes si es que genero ISR o no',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 27/05/2016',
'DESCRIPCION: Modificacion del SPL para retornar datos del Cliente Persona Moral',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparamarchivofatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2))
                RETURNING CHAR(5) AS codret,
                        SMALLINT AS cve_param,
                        CHAR(5) AS valor_param,
                        CHAR(200) AS valor,
                        CHAR(3) AS id_identificador,
                        CHAR(50) AS des_identificador;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE sCveParam SMALLINT;
        DEFINE cValorParam CHAR(5);
        DEFINE cValor CHAR(200);  
        DEFINE cIdIdentificador     CHAR(3);
        DEFINE cDesIdentificador CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET sCveParam   = 0;
        LET cValorParam = '';
        LET cValor          = '';
        LET cIdIdentificador    = '';
        LET cDesIdentificador   = '';
        
                
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END EXCEPTION;
                
               -- SET DEBUG FILE TO '/INFORMIXDUMP/Malik/sp_cap_consultaparamarchivofatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pBandera = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                SET ISOLATION TO DIRTY READ; 
                
                IF pBandera = 1 THEN            
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm  
                        WHERE cve_param = 5 
                        AND valor_param = 14; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 2 THEN
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm 
                        WHERE cve_param = 2
                        AND valor_param = 3;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                ELIF pBandera = 3 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 4 
                        AND valor_param = 1;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 4 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 2 
                        AND valor_param = 4; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                                
                ELIF pBandera = 5 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 1;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 6 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 6;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 7 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 7;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
				
				ELIF pBandera = 8 THEN
                                      
                FOREACH
                SELECT  ID, identificador, valor
                INTO cIdIdentificador, cDesIdentificador, cValor
                FROM (
                SELECT 1 AS ID, 'VERSION' AS identificador, valor
                FROM bdilide:sl_ftc_prm
                WHERE cve_param = 5 
                AND valor_param = 5
                UNION 
                SELECT 2 AS ID, 'SENDINGCOMPANYIN' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 2
                UNION
                SELECT 3 AS ID,'TRANSMITTINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 9
                UNION
                SELECT 4 AS ID, 'RECEIVINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 10
                UNION
                SELECT 5 AS ID, 'MESSAGETYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 11
                UNION
                SELECT 6 AS ID, 'MESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 3
                UNION
                SELECT 7 AS ID, 'CORRMESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 12
                UNION
                SELECT 8 AS ID, 'REPORTINGPERIOD' as identificador, SUBSTRING(valor FROM 7 FOR 4) || '-'|| SUBSTRING(valor FROM 4 FOR 2) || '-' ||SUBSTRING(valor FROM 1 FOR 2)
				FROM bdilide:'informix'.sl_ftc_prm   
				WHERE cve_param = 5 
				AND valor_param = 6
                UNION
                SELECT 9 AS ID, 'RESCOUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 20
                UNION
                SELECT 10 AS ID, 'TINTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 1
                UNION
                SELECT 11 AS ID, 'NAME' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 14
                UNION
                SELECT 12 AS ID, 'COUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 15
                UNION
                SELECT 13 AS ID, 'ADDRRESS FREE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 16
                UNION
                SELECT 14 AS ID, 'DOCTYPEINDIC' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 18
                UNION
                SELECT 15 AS ID, 'DOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm  
                WHERE cve_param = 5 
                AND valor_param = 17
                UNION
                SELECT 16 AS ID, 'CORRDOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 19
				UNION
                SELECT 17 AS ID, 'TIPO PAGO' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 21
				UNION
                SELECT 18 AS ID, 'CODIGO MONEDA' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 22
				UNION
                SELECT 19 AS ID, 'TIN ISSUEDBY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 23
				UNION
                SELECT 20 AS ID, 'ACCT HOLDERTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 24
                ORDER BY 1)
                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador WITH RESUME;
                END FOREACH;
            END IF;         
                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
               END IF;                                
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 09/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene los parametros para el archivo XML Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
            RETURNING CHAR(5) AS codret,
                CHAR(200) AS canal,
                CHAR(5) AS valor_param,
				CHAR(200) AS valor,
                CHAR(200) AS clasificacion,
                INTEGER AS id_clasificacion;              
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCanal CHAR(200);
        DEFINE cValorParam CHAR(5);
		DEFINE cValor CHAR(200);
        DEFINE cClasificacion CHAR(200);
        DEFINE cIdClasificacion INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCanal ='';
        LET cValorParam='';
        LET cClasificacion ='';
        LET cIdClasificacion=0;
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD              
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
					FOREACH 
						SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal,  a.valor_param, a.valor, '-' as clasificacion,  valor_param as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
							WHERE a.cve_param = b.cve_param
							AND a.cve_param = pTipoParametro
							ORDER BY valor_param::INTEGER 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			ELIF pTipoParametro>=2 OR  pTipoParametro <= 4THEN
					FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal, a.valor_param, a.valor, c.c_desc_vparam as clasificacion, a.valor_param::int as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a
						INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
						LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
							WHERE  a.cve_param = pTipoParametro
							ORDER BY valor_param::DECIMAL 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			END IF; 
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion; 
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion; 
			END IF;
			
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
					WHERE a.cve_param = b.cve_param
					AND a.cve_param = pTipoParametro;							
		ELIF pTipoParametro >= 2 OR  pTipoParametro <= 4 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a
					INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
					LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
					WHERE  a.cve_param = pTipoParametro;						
		END IF;	
		
				IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de totales para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_limpiaconsultasfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistrosdet INTEGER;
	DEFINE iNoRegistroscte INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistrosdet = 0;
	LET iNoRegistroscte = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_limpiaconsultasfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistrosdet
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistrosdet > 0) THEN 			
		DELETE 
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistroscte
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistroscte > 0 ) THEN 
		DELETE 
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		END IF;
		
		IF iNoRegistroscte  = 0  OR iNoRegistrosdet = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
			
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 04/03/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que realiza la limpieza de tablas dependiendo su ejercicio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
		DATE AS fecha,
		CHAR (4) AS sucursal,
		CHAR (20) AS cuenta,
		CHAR (20) AS num_cte,
		DATE AS fech_cap,
		DECIMAL (18,2) AS capital,
		DECIMAL (18,2) AS interes,
		SMALLINT AS secuencia;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dFecha DATE;
	DEFINE cSucursal CHAR (4);
	DEFINE cCuenta CHAR (20);
	DEFINE cNumCte CHAR (20);
	DEFINE dFechCap DATE;
	DEFINE dCapital DECIMAL (18,2);
	DEFINE dInteres DECIMAL (18,2);
	DEFINE sSecuencia SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET dFecha = '';
	LET cSucursal = '';
	LET cCuenta = '';
	LET cNumCte = '';
	LET dFechCap = '';
	LET dCapital = 0.00;
	LET dInteres = 0.00;
	LET sSecuencia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, sucursal, cuenta, num_cte, fech_cap, capital, interes, secuencia
			INTO dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia 
			FROM bdinvers:"informix".sv_sdosdiarios
			WHERE fecha >= pFechaInicio 
				AND fecha <= pFechafin
			
			LET iNoRegistros = iNoRegistros + 1;
			
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe AngÃ©lica HernÃ¡ndez PÃ©rez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT COUNT(*) 
		INTO iNoRegistros 
		FROM bdinvers:"informix".sv_sdosdiarios
		WHERE fecha >= pFechaInicio
			AND fecha <= pFechaFin;
					
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de totales para los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(40) AS nombre, 
		CHAR(14) AS cta_contable, 
		DECIMAL(16,2) AS Saldo_cheques, 
		DECIMAL(16,2) AS saldo_contab, 
		DECIMAL(16,2) AS dif_saldos,  
		CHAR(255) AS observaciones, 
		CHAR(1) AS editable;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(40);
    DEFINE cCtaContable CHAR(14);
    DEFINE dSdoCheques DECIMAL(16,2);
    DEFINE dSdoContab DECIMAL(16,2);
    DEFINE dDifSaldos DECIMAL(16,2);
    DEFINE cObservaciones CHAR(255);
    DEFINE cEditable CHAR(1);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
			
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombre        = '';
    LET cCtaContable   = '';
    LET dSdoCheques    = 0.00;
    LET dSdoContab     = 0.00;
    LET dDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2(pFechaCcl, pTipo, pRegistros, pRecuperacion)
			INTO cCodRetSp, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable		
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultacedulas2 ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, UPPER(TRIM(cNombre)), cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, UPPER(TRIM(cObservaciones)), UPPER(TRIM(cEditable)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
	
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el detalle de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT)
		RETURNING CHAR(5) AS codret,		
		INTEGER AS num_registros;

	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE cDescCodRet 				CHAR(100);
	DEFINE iCodRetSp				INTEGER;
	DEFINE iSqlErr 					INTEGER;	
	DEFINE iNumRegistros 			INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2_totales(pFechaCcl, pTipo)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditarjeta:sp_consultacedulas2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;
        
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el total de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el spl productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacedulas( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255), CHAR(1);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consultacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consultacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;