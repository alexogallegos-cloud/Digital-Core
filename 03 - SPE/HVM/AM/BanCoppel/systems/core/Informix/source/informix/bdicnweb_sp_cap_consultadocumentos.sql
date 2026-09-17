CREATE PROCEDURE "informix".sp_cap_consultadocumentos(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(3) AS id_documento,
		CHAR(35) AS desc_documento;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdDocumento CHAR(3);
	DEFINE cDescDocuemnto CHAR(35);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdDocumento = '';
	LET cDescDocuemnto = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDocumento,  cDescDocuemnto; 
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultadocumentos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDocumento,  cDescDocuemnto; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDocumento, cDescDocuemnto; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT id_documento, desc_documento
			INTO cIdDocumento, cDescDocuemnto
			FROM "informix".sw_cap_tipodocumento
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdDocumento,  cDescDocuemnto WITH RESUME;
		END FOREACH;
				
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdDocumento, cDescDocuemnto; 
		END IF;		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 19/08/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: REIMPRESION DOCUMENTOS',
'DESCRIPCION: SPL que realiza llena el catalogo para los tipos de documentos para realizar la reimpresión',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultareimpresiondoc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCuenta CHAR(20), pNumCte CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR(20) AS num_cuenta,
                DATE     AS fecha_apertura,
                CHAR(20) AS num_cte,
                CHAR(100) AS nombre_corto;              
                
	DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
	DEFINE cCodRetSp                CHAR(5);
	DEFINE iCodRetSp                INTEGER;
	DEFINE cNumCuenta               CHAR(20);
	DEFINE cNumCuentaExtras CHAR(20);
	DEFINE cFechaApertura   DATE;
	DEFINE cFechaAperturaExtra      DATE;
	DEFINE cNumCte                  CHAR(20);
	DEFINE cRazonSocial                     CHAR(100);
	DEFINE iNoRegistros     INTEGER;
	DEFINE iRegistros               INTEGER;
	DEFINE iRecuperacion    INTEGER;
	--
	DEFINE cProducto                                CHAR(1);
	DEFINE cSistemaCuenta                   CHAR(2);
	DEFINE cNumeroCuenta                    CHAR(20);
	DEFINE cCveProducto                     CHAR(4);
	DEFINE cNombreProducto                  CHAR(40);
	DEFINE dFechaApertura                   DATE;
	DEFINE cStatusCuenta                    CHAR(60);
	DEFINE dFechaStatus                     DATE;
	DEFINE cClaveSucursal                   CHAR(4);
	DEFINE cEjecutivo                               CHAR(8);
	DEFINE mSaldoActual                     MONEY(14,2);
	DEFINE cNumeroTarjeta                   CHAR(20);
	DEFINE cStatusTarjeta                   CHAR(15);
	DEFINE cCuentaClabe                     CHAR(18);
	DEFINE dFechaAperturaInversion  DATE;
	DEFINE sDiaCorte                                SMALLINT;
	DEFINE dFechacancelacion                DATE;
	DEFINE ccodstatus                               CHAR(2);
	--
	DEFINE cNumeroCliente                           CHAR(20);
	DEFINE cNombre1                    CHAR(26);
	DEFINE cNombre2                    CHAR(26);
	DEFINE cApellidoPaterno            CHAR(26);
	DEFINE cApellidoMaterno            CHAR(26);
	DEFINE cRFC                         CHAR(13);
	DEFINE cTipoCliente                CHAR(1); 
	DEFINE cDescTipoCliente           CHAR(40);
	DEFINE dFechaNacimiento            DATE;
	DEFINE cCveSexo                    CHAR(1);
	DEFINE cCveTipoPersona            CHAR(2);
	DEFINE cDescTipoPersona           CHAR(20);
	DEFINE dFechaAlta                  DATE;
	DEFINE cSucursal                    CHAR(4);
	DEFINE cPlaza                       CHAR(3); 
	DEFINE cCveSituacion               CHAR(5); 
	DEFINE cDescSituacion              CHAR(75);
	DEFINE iSecuencia                   INTEGER;
	DEFINE cCalle                       CHAR(40);
	DEFINE cNumeroExteriorCalle       CHAR(10);
	DEFINE cNumeroInteriorCalle       CHAR(10);
	DEFINE cDepartamento                CHAR(6);
	DEFINE cColonia                     CHAR(60);
	DEFINE cMunicipio                   CHAR(60);
	DEFINE cCiudad                      CHAR(60);
	DEFINE cEstado                      CHAR(30);
	DEFINE cPais                        CHAR(20);
	DEFINE cCodigoPostal               CHAR(5);
	DEFINE cTelefono1                  CHAR(13);
	DEFINE cTelefono2                  CHAR(13);
	DEFINE cTelefono3                  CHAR(13);
	DEFINE cExtension                   CHAR (5);
	DEFINE iNivelConsulta              INTEGER;
	DEFINE cDescNivelConsulta         CHAR(60);
	DEFINE cNombreCorto				  CHAR(30);
	
	LET cCodRet             = '00000';
	LET iSqlErr             = 0;
	LET cCodRetSp           = '00000';
	LET iCodRetSp           = 0;
	LET cNumCuenta          = '';
	LET cNumCuentaExtras = '';
	LET cFechaApertura      = '';
	LET cFechaAperturaExtra = '';
	LET cNumCte                     = '';
	LET cRazonSocial                        = '';
	LET iNoRegistros        = 0;
	LET iRegistros          = 0;
	LET iRecuperacion       = 0;
	--
	LET cProducto                           = '';
	LET cSistemaCuenta                      = '';
	LET cNumeroCuenta                       = '';
	LET cCveProducto                        = '';
	LET cNombreProducto                     = '';
	LET dFechaApertura                      = '';
	LET cStatusCuenta                       = '';
	LET dFechaStatus                        = '';
	LET cClaveSucursal                      = '';
	LET cEjecutivo                          = '';
	LET mSaldoActual                        =0.00;
	LET cNumeroTarjeta                      = '';
	LET cStatusTarjeta                      = '';
	LET cCuentaClabe                        = '';
	LET dFechaAperturaInversion     = '';
	LET sDiaCorte                           = '';
	LET dFechacancelacion           = '';
	LET ccodstatus                          = '';
	--
	LET cNumeroCliente                      = '';
	LET cNombre1               = '';
	LET cNombre2               = '';
	LET cApellidoPaterno       = '';
	LET cApellidoMaterno       = '';
	LET cRFC                    = '';
	LET cTipoCliente           = '';
	LET cDescTipoCliente      = '';
	LET dFechaNacimiento       = '';
	LET cCveSexo               = '';
	LET cCveTipoPersona       = '';
	LET cDescTipoPersona      = '';
	LET dFechaAlta             = '';
	LET cSucursal               = '';
	LET cPlaza                  = '';
	LET cCveSituacion          = '';
	LET cDescSituacion         = '';
	LET iSecuencia              = 0;
	LET cCalle                  = '';
	LET cNumeroExteriorCalle  = '';
	LET cNumeroInteriorCalle  = '';
	LET cDepartamento           = '';
	LET cColonia                = '';
	LET cMunicipio              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cPais                   = '';
	LET cCodigoPostal          = '';
	LET cTelefono1             = '';
	LET cTelefono2             = '';
	LET cTelefono3             = '';
	LET cExtension              = '';
	LET iNivelConsulta         = 0;
	LET cDescNivelConsulta    = '';
	LET cNombreCorto		='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultareimpresiondoc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pNumCte <> '' THEN
		
			FOREACH 
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consnumcte(pUsuario, pIdFuncion ,'1','1','1', pNumCte, '', '', '')
				INTO cCodRetSp, cNumCte,cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno,cRazonSocial,cRFC,cTipoCliente,cDescTipoCliente,dFechaNacimiento,cCveSexo,cCveTipoPersona,cDescTipoPersona,dFechaAlta,cSucursal,cPlaza,cCveSituacion,cDescSituacion,iSecuencia,cCalle,cNumeroExteriorCalle,cNumeroInteriorCalle,cDepartamento,cColonia,cMunicipio,cCiudad,cEstado,cPais,cCodigoPostal,cTelefono1,cTelefono2,cTelefono3,cExtension,iNivelConsulta,cDescNivelConsulta

				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consnumcte";
				END IF;
			END FOREACH
				
			SELECT nombre_corto INTO cNombreCorto FROM bdinteg:si_ctepm where numcte = pNumCte;
			
			FOREACH
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, pNumCte,'01',pRegistros, pRecuperacion)
				INTO cCodRetSp, cProducto, cSistemaCuenta, cNumCuenta, cCveProducto, cNombreProducto, cFechaApertura, cStatusCuenta, dFechaStatus, cClaveSucursal, cEjecutivo, mSaldoActual, cNumeroTarjeta, cStatusTarjeta, cCuentaClabe, dFechaAperturaInversion, sDiaCorte, dFechacancelacion, ccodstatus
				
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consprodcte";
				END IF;
		
				IF  cCveProducto not IN('9900','9901') THEN--ggl
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, NVL(cNumCuenta,''), NVL(cFechaApertura,''), NVL(cNumCte,''), UPPER(NVL(cNombreCorto,'')) WITH RESUME;
				ELSE
				END IF;
			END FOREACH;

		ELIF pNumCuenta <> '' THEN 
		
			FOREACH 
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consnumcte(pUsuario, pIdFuncion ,'2','1','0', '', pNumCuenta, '', '')
				INTO cCodRetSp, cNumCte,cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno,cRazonSocial,cRFC,cTipoCliente,cDescTipoCliente,dFechaNacimiento,cCveSexo,cCveTipoPersona,cDescTipoPersona,dFechaAlta,cSucursal,cPlaza,cCveSituacion,cDescSituacion,iSecuencia,cCalle,cNumeroExteriorCalle,cNumeroInteriorCalle,cDepartamento,cColonia,cMunicipio,cCiudad,cEstado,cPais,cCodigoPostal,cTelefono1,cTelefono2,cTelefono3,cExtension,iNivelConsulta,cDescNivelConsulta
				
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consnumcte";
				END IF;
			END FOREACH;
			
			SELECT nombre_corto INTO cNombreCorto FROM bdinteg:si_ctepm where numcte = cNumCte;
							
			FOREACH
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, cNumCte,'01',pRegistros, pRecuperacion)
				INTO cCodRetSp, cProducto, cSistemaCuenta, cNumCuenta, cCveProducto, cNombreProducto, cFechaApertura, cStatusCuenta, dFechaStatus, cClaveSucursal, cEjecutivo, mSaldoActual, cNumeroTarjeta, cStatusTarjeta, cCuentaClabe, dFechaAperturaInversion, sDiaCorte, dFechacancelacion, ccodstatus
				
				IF cNumCuenta = pNumCuenta THEN 
						LET cNumCuentaExtras = cNumCuenta;
						LET cFechaAperturaExtra = cFechaApertura;
				END IF;

				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consprodcte";
				END IF;
				
				IF  cCveProducto not IN('9900','9901') THEN
				LET iNoRegistros = iNoRegistros + 1;
				ELSE
				END IF;
			END FOREACH;
			RETURN cCodRet, NVL(cNumCuentaExtras,''), NVL(cFechaAperturaExtra,''), NVL(cNumCte,''), UPPER(NVL(cNombreCorto,''));
		END IF;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCuenta, cFechaApertura, cNumCte, cNombreCorto;
		END IF;         
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 30/08/2016',
'MODULO: DÃBITO ',
'FUNCIONALIDAD:REIMPRESION DOCUMENTOS',
'DESCRIPCION:SPL que realiza la consulta del detalle de clientes por medio de num_cliente o num_cuenta.',
'MODIFICACION: Martha Salgado Mendoza',
'FECHA: 20/09/2016',
'DESCRIPCION: Cambio de retorno Razon Social por NombreCorto, Se agrega variable cNombreCorto para retornar el campo nombre_corto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultareimpresiondoc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCuenta CHAR(20), pNumCte CHAR(20))
		RETURNING CHAR(5) AS codret,
		INTEGER AS totales;		
		
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSp 		CHAR(5);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cNumCuenta 		CHAR(20);
	DEFINE cNumCuentaExtras	CHAR(20);
	DEFINE cFechaApertura	DATE;
	DEFINE cFechaAperturaExtra	DATE;
	DEFINE cNumCte			CHAR(20);
	DEFINE cRazonSocial			CHAR(100);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iTotalRegitros	INTEGER;
	DEFINE iRegistros 		INTEGER;
	DEFINE iRecuperacion 	INTEGER;
	--
	DEFINE cProducto				CHAR(1);
	DEFINE cSistemaCuenta			CHAR(2);
	DEFINE cNumeroCuenta			CHAR(20);
	DEFINE cCveProducto			CHAR(4);
	DEFINE cNombreProducto			CHAR(40);
	DEFINE dFechaApertura			DATE;
	DEFINE cStatusCuenta			CHAR(60);
	DEFINE dFechaStatus			DATE;
	DEFINE cClaveSucursal			CHAR(4);
	DEFINE cEjecutivo				CHAR(8);
	DEFINE mSaldoActual			MONEY(14,2);
	DEFINE cNumeroTarjeta			CHAR(20);
	DEFINE cStatusTarjeta			CHAR(15);
	DEFINE cCuentaClabe			CHAR(18);
	DEFINE dFechaAperturaInversion	DATE;
	DEFINE sDiaCorte				SMALLINT;
	DEFINE dFechacancelacion		DATE;
	DEFINE ccodstatus				CHAR(2);
	--
	DEFINE cNumeroCliente				CHAR(20);
	DEFINE cNombre1                    CHAR(26);
	DEFINE cNombre2                    CHAR(26);
	DEFINE cApellidoPaterno            CHAR(26);
	DEFINE cApellidoMaterno            CHAR(26);
	DEFINE cRFC                         CHAR(13);
	DEFINE cTipoCliente                CHAR(1); 
	DEFINE cDescTipoCliente           CHAR(40);
	DEFINE dFechaNacimiento            DATE;
	DEFINE cCveSexo                    CHAR(1);
	DEFINE cCveTipoPersona            CHAR(2);
	DEFINE cDescTipoPersona           CHAR(20);
	DEFINE dFechaAlta                  DATE;
	DEFINE cSucursal                    CHAR(4);
	DEFINE cPlaza                       CHAR(3); 
	DEFINE cCveSituacion               CHAR(5); 
	DEFINE cDescSituacion              CHAR(75);
	DEFINE iSecuencia                   INTEGER;
	DEFINE cCalle                       CHAR(40);
	DEFINE cNumeroExteriorCalle       CHAR(10);
	DEFINE cNumeroInteriorCalle       CHAR(10);
	DEFINE cDepartamento                CHAR(6);
	DEFINE cColonia                     CHAR(60);
	DEFINE cMunicipio                   CHAR(60);
	DEFINE cCiudad                      CHAR(60);
	DEFINE cEstado                      CHAR(30);
	DEFINE cPais                        CHAR(20);
	DEFINE cCodigoPostal               CHAR(5);
	DEFINE cTelefono1                  CHAR(13);
	DEFINE cTelefono2                  CHAR(13);
	DEFINE cTelefono3                  CHAR(13);
	DEFINE cExtension                   CHAR (5);
	DEFINE iNivelConsulta              INTEGER;
	DEFINE cDescNivelConsulta         CHAR(60);
	
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '00000';
	LET iCodRetSp		= 0;
	LET cNumCuenta 		= '';
	LET cNumCuentaExtras = '';
	LET cFechaApertura	= '';
	LET cFechaAperturaExtra = '';
	LET cNumCte			= '';
	LET cRazonSocial			= '';
	LET iNoRegistros 	= 0;
	LET iTotalRegitros = 0;
	LET iRegistros 		= 0;
	LET iRecuperacion 	= 0;
	--
	LET cProducto				= '';
	LET cSistemaCuenta			= '';
	LET cNumeroCuenta			= '';
	LET cCveProducto			= '';
	LET cNombreProducto			= '';
	LET dFechaApertura			= '';
	LET cStatusCuenta			= '';
	LET dFechaStatus			= '';
	LET cClaveSucursal			= '';
	LET cEjecutivo				= '';
	LET mSaldoActual			=0.00;
	LET cNumeroTarjeta			= '';
	LET cStatusTarjeta			= '';
	LET cCuentaClabe			= '';
	LET dFechaAperturaInversion	= '';
	LET sDiaCorte				= '';
	LET dFechacancelacion		= '';
	LET ccodstatus				= '';
	--
	LET cNumeroCliente			= '';
	LET cNombre1               = '';
	LET cNombre2               = '';
	LET cApellidoPaterno       = '';
	LET cApellidoMaterno       = '';
	LET cRFC                    = '';
	LET cTipoCliente           = '';
	LET cDescTipoCliente      = '';
	LET dFechaNacimiento       = '';
	LET cCveSexo               = '';
	LET cCveTipoPersona       = '';
	LET cDescTipoPersona      = '';
	LET dFechaAlta             = '';
	LET cSucursal               = '';
	LET cPlaza                  = '';
	LET cCveSituacion          = '';
	LET cDescSituacion         = '';
	LET iSecuencia              = 0;
	LET cCalle                  = '';
	LET cNumeroExteriorCalle  = '';
	LET cNumeroInteriorCalle  = '';
	LET cDepartamento           = '';
	LET cColonia                = '';
	LET cMunicipio              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cPais                   = '';
	LET cCodigoPostal          = '';
	LET cTelefono1             = '';
	LET cTelefono2             = '';
	LET cTelefono3             = '';
	LET cExtension              = '';
	LET iNivelConsulta         = 0;
	LET cDescNivelConsulta    = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultareimpresiondoc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pNumCte <> '' THEN
		
			FOREACH 
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consnumcte(pUsuario, pIdFuncion ,'1','1','1', pNumCte, '', '', '')
				INTO cCodRetSp, cNumCte,cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno,cRazonSocial,cRFC,cTipoCliente,cDescTipoCliente,dFechaNacimiento,cCveSexo,cCveTipoPersona,cDescTipoPersona,dFechaAlta,cSucursal,cPlaza,cCveSituacion,cDescSituacion,iSecuencia,cCalle,cNumeroExteriorCalle,cNumeroInteriorCalle,cDepartamento,cColonia,cMunicipio,cCiudad,cEstado,cPais,cCodigoPostal,cTelefono1,cTelefono2,cTelefono3,cExtension,iNivelConsulta,cDescNivelConsulta

				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consnumcte";
				END IF;
			END FOREACH
	
			FOREACH
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, pNumCte,'01','0', '68')
				INTO cCodRetSp, cProducto, cSistemaCuenta, cNumCuenta, cCveProducto, cNombreProducto, cFechaApertura, cStatusCuenta, dFechaStatus, cClaveSucursal, cEjecutivo, mSaldoActual, cNumeroTarjeta, cStatusTarjeta, cCuentaClabe, dFechaAperturaInversion, sDiaCorte, dFechacancelacion, ccodstatus
				
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consprodcte";
				END IF;
			
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
		ELIF pNumCuenta <> '' THEN 
		
			FOREACH 
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consnumcte(pUsuario, pIdFuncion ,'2','1','0', '', pNumCuenta, '', '')
				INTO cCodRetSp, cNumCte,cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno,cRazonSocial,cRFC,cTipoCliente,cDescTipoCliente,dFechaNacimiento,cCveSexo,cCveTipoPersona,cDescTipoPersona,dFechaAlta,cSucursal,cPlaza,cCveSituacion,cDescSituacion,iSecuencia,cCalle,cNumeroExteriorCalle,cNumeroInteriorCalle,cDepartamento,cColonia,cMunicipio,cCiudad,cEstado,cPais,cCodigoPostal,cTelefono1,cTelefono2,cTelefono3,cExtension,iNivelConsulta,cDescNivelConsulta
				
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consnumcte";
				END IF;
			END FOREACH;
				
			FOREACH
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, cNumCte,'01','0', '1')
				INTO cCodRetSp, cProducto, cSistemaCuenta, cNumCuenta, cCveProducto, cNombreProducto, cFechaApertura, cStatusCuenta, dFechaStatus, cClaveSucursal, cEjecutivo, mSaldoActual, cNumeroTarjeta, cStatusTarjeta, cCuentaClabe, dFechaAperturaInversion, sDiaCorte, dFechacancelacion, ccodstatus
				
				IF cNumCuenta = pNumCuenta THEN 
					LET cNumCuentaExtras = cNumCuenta;
					LET cFechaAperturaExtra = cFechaApertura;
				END IF;

				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consprodcte";
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
		END IF;
		
		IF iNoRegistros = 0  THEN
			LET cCodRet = '00017';
        END IF;         
		
		RETURN cCodRet, iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 30/08/2016',
'MODULO: DÉBITO ',
'FUNCIONALIDAD:REIMPRESION DOCUMENTOS',
'DESCRIPCION:SPL que realiza la consulta del detalle de clientes por medio de num_cliente o num_cuenta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generahojafirmasctamec(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
                RETURNING CHAR(5) AS codret,
                                CHAR(40) AS desc_producto,      -- Descripcion del producto
                                CHAR(20) AS num_cte,            -- Numero de cliente
                                CHAR(104) AS nombre_cte,        -- Nombre de cliente
                                CHAR(4) AS cod_sucursal,        -- Codigo de sucursal
                                CHAR(30) AS desc_moneda,        -- Descripcion de la moneda
                                DATE AS fecha_alta,             -- Fecha de alta de la cuenta
                                DATE AS fecha_modific,          -- Fecha de modificacion de firmantes
                                CHAR(20) AS regimen,            -- Regimen de firma relacionado a la cuenta
                                CHAR(20) AS especif_manejo,     -- Especificaciones de manejo del regimen de la firma
                                CHAR(104) AS nombre_firmante1,  -- Nombre del firmante    
                                CHAR(20) AS firmante1,
                                CHAR(104) AS nombre_firmante2,  -- Nombre del firmante    
                                CHAR(20) AS firmante2,
                                CHAR(104) AS nombre_firmante3,  -- Nombre del firmante    
                                CHAR(20) AS firmante3,
                                CHAR(104) AS nombre_firmante4,  -- Nombre del firmante    
                                CHAR(20) AS firmante4;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cMensajeEjec CHAR(60);
        DEFINE cDescProducto CHAR(40);
        DEFINE cNumCliente CHAR(20);
        DEFINE cNombreCte CHAR(104);
        DEFINE cCodSucursal CHAR(4);
        DEFINE cDescMoneda CHAR(30);
        DEFINE dFechaAlta DATE;
        DEFINE dFechaModific DATE;
        DEFINE cRegimen CHAR(20);
        DEFINE cEspecifManejo CHAR(20);
        DEFINE cNombreFirmante1 CHAR(104);
        DEFINE cFirmante1 CHAR(20);
        DEFINE cNombreFirmante2 CHAR(104);
        DEFINE cFirmante2 CHAR(20);
        DEFINE cNombreFirmante3 CHAR(104);
        DEFINE cFirmante3 CHAR(20);
        DEFINE cNombreFirmante4 CHAR(104);
        DEFINE cFirmante4 CHAR(20);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cMensajeEjec = '';
        LET cDescProducto = '';
        LET cNumCliente = '';
        LET cNombreCte = '';
        LET cCodSucursal = '';
        LET cDescMoneda = '';
        LET dFechaAlta = NULL;
        LET dFechaModific = NULL;
        LET cRegimen = '';
        LET cEspecifManejo = '';
        LET cNombreFirmante1 = '';
        LET cFirmante1 = '';
        LET cNombreFirmante2 = '';
        LET cFirmante2 = '';
        LET cNombreFirmante3 = '';
        LET cFirmante3 = '';
        LET cNombreFirmante4 = '';
        LET cFirmante4 = '';
                
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                        cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                        cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                        cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_generahojafirmasctamec.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                        cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                        cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                        cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '01', '1') INTO cCodRet;
                --EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                        cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                        cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                        cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4;
                END IF;
                
                FOREACH EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_generarrpthojadefirmas2(cEmpresa, pCuenta)
                                INTO cCodRetSp, cMensajeEjec, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                                        cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                                        cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                                        cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4
                
                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_ctamec_generarrpthojadefirmas';
                        ELIF iCodRetSp = 100 THEN
                                LET cCodRet = '00003';
                        ELIF iCodRetSp = 200 THEN -- LA CUENTA NO EXISTE
                                LET cCodRet = '00009';
                        ELIF iCodRetSp = 210 THEN -- EL PRODUCTO NO EXISTE
                                LET cCodRet = '00016';
                        ELIF iCodRetSp = 220 THEN -- NO EXISTE EL REGIMEN DE FIRMAS
                                LET cCodRet = '00332';
                        ELIF iCodRetSp = 230 THEN -- LA MONEDA O DIVISA SON ERROREAS
                                LET cCodRet = '00127';
                        ELIF iCodRetSp = 333 THEN -- LA CUENTA NO TIENE FIRMANTES RELACIONADOS
                                LET cCodRet = '00127';
                        END IF;
                        
                        RETURN cCodRet, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                                cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                                cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                                cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4 WITH RESUME;
                END FOREACH;
                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cDescProducto, cNumCliente, cNombreCte, cCodSucursal, 
                                                cDescMoneda, dFechaAlta, dFechaModific, cRegimen, cEspecifManejo, 
                                                cNombreFirmante1, cFirmante1, cNombreFirmante2, cFirmante2, 
                                                cNombreFirmante3, cFirmante3, cNombreFirmante4, cFirmante4;
                END IF;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 03/07/2014',
'DESCRIPCION: Procedimiento que llena el reporte de hoja de firmas',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 10/10/2016',
'DESCRIPCION: SPL clonado para ordenar los registros de firmantes de acuerdo al tipo al que pertenezcan',
'ID MANTIS: 0006773',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_monitorsucursales2(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Tp_Busqueda CHAR(1), Id_Plaza CHAR(3), 
pNumRegistro INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS Cod_Retorno;

	DEFINE cCodRet          CHAR(5);
	DEFINE iSql_err 		INT;	

	LET cCodRet 	    = "00000";
	LET iSql_err 	    = 0;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_monitorsucursales2.out";
		--TRACE ON;

		IF cID_USUARIOC = '' OR cID_FUNCIONC = '' OR Tp_Busqueda  = '' OR pNumRegistro IS NULL OR pRecuperacion IS NULL THEN 
			LET cCodRet = "00054";
			RETURN cCodRet;
		END IF;	

		IF Tp_Busqueda NOT IN ('1', '2', '3') THEN
			LET cCodRet = "00049";
			RETURN cCodRet;
		END IF;

		IF pNumRegistro < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet;
		ELSE
			IF pRecuperacion <= 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet;
			END IF;
		END IF;    
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;	
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/10/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Consulta detalle de Sucursales de acuerdo a criterios (Consulta por Plaza).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_pasesucursal2(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Num_Sucursal CHAR(4))
	RETURNING CHAR(5) AS Cod_Retorno;
	
	DEFINE cCodRet          CHAR(5);
	DEFINE iSql_err 		INT;	

	LET cCodRet 	    = "00000";
	LET iSql_err 	    =  0;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_pasesucursal2.out";
		--TRACE ON;

		IF 	cID_USUARIOC = '' OR cID_FUNCIONC = '' OR Num_Sucursal = '' THEN 
			LET cCodRet = "00054";
			RETURN cCodRet;
		END IF;	

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/10/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Consulta detalle de Sucursales de acuerdo a criterios (Numero de Sucursal).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tf_cattransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdTransaccion CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS transaccion,
			CHAR(50) AS descripcion;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
	DEFINE cEmpresa CHAR(3);
	DEFINE cTransaccion CHAR(5);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNaturaleza CHAR(1);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cTransaccion = '';
	LET cDescripcion = '';
	LET cNaturaleza = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTransaccion,cDescripcion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tf_cattransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdTransaccion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTransaccion,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTransaccion,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH
			EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_transacciones(pIdTransaccion)
			INTO cCodRetSp, cDescCodRetSp, cTransaccion, cDescripcion, cNaturaleza
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditransfer:sp_transfer_transacciones';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00411'; --LA SOLICITUD NO EXISTE O ES INCORRECTA, FAVOR DE VERIFICAR E INTENTAR NUEVAMENTE
				RETURN cCodRet,cTransaccion,cDescripcion;
			END IF;
			
			LET iNumRegistros = iNumRegistros + 1;
			RETURN cCodRet,TRIM(cTransaccion),TRIM(UPPER(cDescripcion)) WITH RESUME;
		END FOREACH;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTransaccion,cDescripcion;
		END IF;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 10/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONCILIACIÓN ADMINISTRATIVA TRANSFER', 
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de las transacciones que se monitorean.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tf_conciliacionadmin_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
pTransaccion CHAR(5), pNaturaleza CHAR(1))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tf_conciliacionadmin_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_mconadmin_success2_totales(pFechaInicio, pFechaFin, pTransaccion, pNaturaleza)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditransfer:sp_transfer_mconadmin_success2_totales';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 10/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONCILIACIÓN ADMINISTRATIVA TRANSFER', 
'DESCRIPCION: SPL encargado de consultar el número total de las conciliaciones administrativas transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tf_transaccionesexitosas(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS nombre_archivo,
			CHAR(1) AS aplicacion,
			INTEGER AS cantidad,
			MONEY(16,2) AS monto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(50);
	DEFINE cAplicacion CHAR(1);
	DEFINE cCantidad INTEGER;
	DEFINE mMonto MONEY(16,2);
	DEFINE iRecuperacion INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cAplicacion = '';
	LET cCantidad = 0;
	LET mMonto = 0.00;
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tf_transaccionesexitosas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH
			EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_msuccess2(pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp,cDescCodRetSp,cNombreArchivo,cAplicacion,cCantidad,mMonto

			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditransfer:sp_transfer_msuccess2';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
				RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombreArchivo,cAplicacion,cCantidad,mMonto;
		END IF;	

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 12/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: TRANSACCIONES EXITOSAS TRANSFER', 
'DESCRIPCION: SPL encargado de consultar el detalle de las transacciones exitosas transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tf_transaccionesexitosas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tf_transaccionesexitosas_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		EXECUTE PROCEDURE bditransfer:"informix".sp_transfer_msuccess2_totales(pFechaInicio, pFechaFin)
		INTO cCodRetSp,iNumRegistros;

		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditransfer:sp_transfer_msuccess2_totales';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 12/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: TRANSACCIONES EXITOSAS TRANSFER', 
'DESCRIPCION: SPL encargado de consultar el número total de las transacciones exitosas transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturaeactulizagat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pFecha DATE, pProducto CHAR(4), pTasa DECIMAL(9,6), pGatNominal DECIMAL(9,6), pGatReal DECIMAL(9,6), pPlazaInicio INTEGER, pPlazaFin INTEGER)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dTasa DECIMAL(9,6);
	DEFINE dFechaMax DATE;
	DEFINE iRowID INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET dTasa = 0.00;
	LET dFechaMax = '';
	LET iRowID = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_cap_capturaeactulizagat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		-- actualiza e inserta inversion creciente
		IF pBandera = '1' THEN -- inv creciente
			
		SELECT  MAX(fecha_publicacion), MAX(ROWID)
			INTO dFechaMax, iRowID
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto
			  AND tasa = pTasa;
		
			SELECT tasa
			INTO dTasa
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto
			AND fecha_publicacion = dFechaMax
			AND ROWID = iRowID;
			
			IF dFechaMax <> pFecha THEN 
				LET cCodRet = '00133';
			END IF;
			
			IF dTasa = pTasa THEN 
			
				UPDATE bdicheq:"informix".sc_gat
				SET tasa = pTasa ,gat_nominal = pGatNominal, gat_real = pGatReal
				WHERE producto = pProducto
				AND fecha_publicacion = dFechaMax
				AND ROWID = iRowID;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
			ELSE 
				INSERT INTO bdicheq:"informix".sc_gat (producto, tasa, gat_nominal, gat_real, fecha_publicacion)
				VALUES (pProducto, pTasa, pGatNominal, pGatReal, CURRENT);
				RETURN cCodRet;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00282';
					RETURN cCodRet;
				END IF;
				
			END IF;
					

		ELIF pBandera = '2' THEN  -- cta ejecutiva jovenes
			
			UPDATE bdicheq:"informix".sc_gat
			SET gat_nominal = pGatNominal, gat_real = pGatReal, tasa = pTasa
			WHERE producto = pProducto
			AND fecha_publicacion = pFecha;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		
		ELIF pBandera = '3' THEN -- producto pagare
		
			UPDATE bdinvers:"informix".sv_gat
			SET gat_nomina = pGatNominal, gat_real = pGatReal, tasa = pTasa
			WHERE fecha_publicacion = pFecha
			AND plazo_inicio = pPlazaInicio
			AND plazo_fin = pPlazaFin;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;

		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hérnandez Pérez',
'FECHA: 09/08/2016',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la actualizacion e inserción de los registros de inversion creciente, cuenta jovenes y producto pagare ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultastatusprocesomonitor(pUsuario CHAR(8), pIdFuncion CHAR(10))
			RETURNING CHAR(5) AS codret,
			CHAR(1) AS id_status,
			CHAR(30) AS desc_status;        
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultastatusprocesomonitor.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		SELECT id_status, desc_status
		INTO cIdStatus, cDescStatus
		FROM "informix".sw_cg_validaestatus
		WHERE usuario_inserta = pUsuario;
	
		IF cIdStatus  = '' THEN
			RETURN cCodRet, 'I', 'INICIA_PROCESO';
		ELSE 
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
	
	END;   
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 27/10/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: CAJA GENERAL',
'DESCRIPCION: SPL que realiza la consulta de los estatus para monitorear el proceso del spl de bdicnweb:sp_consultainfmonitoroperacionescaja',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_concentracionrecibida_cg_masivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pTramaFolios CHAR(500), pOrigen CHAR(1))
			RETURNING CHAR(5) AS codret,
			CHAR(30) AS descripcion,
			INTEGER AS regactualizados;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(30);
	DEFINE cFolioOperacion CHAR(8);
	DEFINE iRegActualizados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET cFolioOperacion = '';
	LET iRegActualizados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion,iRegActualizados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_concentracionrecibida_cg_masivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTramaFolios = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDescripcion, iRegActualizados;
		END IF;
		
		IF pOrigen NOT IN ('S', 'C') THEN
			LET cCodRet = '00102';
			RETURN cCodRet,cDescripcion,iRegActualizados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDescripcion,iRegActualizados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;        
		
		FOREACH 
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaFolios, '|')
			INTO cFolioOperacion
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_concentracionrecibida_cg(pUsuario, pIdFuncion, cFolioOperacion, pOrigen)
			INTO cCodRet, cDescripcion;
			
			IF cCodRet = '00000' THEN
				LET iRegActualizados =	iRegActualizados + 1;
			END IF;
		 END FOREACH;
		
		RETURN cCodRet,cDescripcion,iRegActualizados;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 23/11/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de operaciones',
'DESCRIPCION: Realiza la concentración recibida, para multiples folios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfmonitoroperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2), pIdSucursal CHAR(4), 
pIdMostrar CHAR(4), pFechaInic DATE, pFechaFin DATE, pOperacion CHAR(1), pIdProvCaja CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS desc_sucursal,
		DATE AS fecha_operacion,
		CHAR(50) AS desc_status,
		CHAR(8) AS folio_operacion,
		MONEY(14,2) AS importe,
		CHAR(50) AS operacion,
		CHAR(4) AS cod_proveedor,
		CHAR(50) AS terceros, 
		CHAR(16) AS papeleta,
		CHAR(40) AS usuario,
		CHAR(2) AS status_concentrar,
		CHAR(6) AS id_atm,
		INTEGER AS billete1000,
		INTEGER AS billete500, 
		INTEGER AS billete200, 
		INTEGER AS billete100, 
		INTEGER AS billete50,  
		INTEGER AS billete20,  
		INTEGER AS billete10,  
		INTEGER AS billete5,   
		INTEGER AS billete2,   
		INTEGER AS billete1,   
		INTEGER AS billete_c50, 
		CHAR(40) AS desc_caja,
		INTEGER AS posicion_rep,
		MONEY(18,2) AS saldo_caja,
		CHAR(4) AS cc_atm,
		SMALLINT AS duplicado,
		INTEGER AS total_duplicados,
		INTEGER AS total_concentrar;
	 
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(45);
	DEFINE dFechaOperacion DATE;
	DEFINE cDescStatus CHAR(50);
	DEFINE cFolioOperacion CHAR(8);
	DEFINE mImporte MONEY(14,2);
	DEFINE cOperacion CHAR(50);
	DEFINE cCodProveedor CHAR(4);
	DEFINE cTerceros CHAR(50);
	DEFINE cPapeleta CHAR(16);
	DEFINE cUsuario CHAR(40);
	DEFINE cCodStatus CHAR(2);    
	DEFINE iIdATM CHAR(6);
	DEFINE iBillete1000 INTEGER;      
	DEFINE iBillete500  INTEGER;      
	DEFINE iBillete200  INTEGER;      
	DEFINE iBillete100  INTEGER;      
	DEFINE iBillete50   INTEGER;      
	DEFINE iBillete20   INTEGER;      
	DEFINE iBillete10   INTEGER;      
	DEFINE iBillete5    INTEGER;      
	DEFINE iBillete2    INTEGER;      
	DEFINE iBillete1    INTEGER;      
	DEFINE iBillete_c50  INTEGER;
	DEFINE cDescCaja CHAR(40);
	DEFINE iPosicionRep INTEGER;    
	DEFINE mSaldoCaja   MONEY(18,2); 
	DEFINE cCcATM CHAR(4);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER; 
	DEFINE iRecuperacion INTEGER;
	DEFINE iRegistros INTEGER;
	
	DEFINE iStatusConcentrar SMALLINT;
	DEFINE iTotalConcentrar INTEGER;
	DEFINE iDuplicado SMALLINT; 
	DEFINE iTotalDuplicados INTEGER;		
	DEFINE dFechaHoy DATE;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET dFechaOperacion = NULL;
	LET cDescStatus = '';
	LET cFolioOperacion = '';
	LET mImporte = NULL;
	LET cOperacion = '';
	LET cCodProveedor = '';
	LET cTerceros = '';
	LET cPapeleta = '';
	LET cUsuario = '';
	LET cCodStatus = '';   
	LET iIdATM = 0; 
	LET iBillete1000 = 0;      
	LET iBillete500  = 0;      
	LET iBillete200  = 0;      
	LET iBillete100  = 0;      
	LET iBillete50   = 0;      
	LET iBillete20   = 0;      
	LET iBillete10   = 0;      
	LET iBillete5    = 0;      
	LET iBillete2    = 0;      
	LET iBillete1    = 0;      
	LET iBillete_c50  = 0; 
	LET cDescCaja = '';
	LET iPosicionRep = 0;    
	LET mSaldoCaja   = NULL; 
	LET cCcATM = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0; 
	LET iRecuperacion = 0;
	LET iRegistros = 0;
	
	LET iStatusConcentrar = 0;
	LET iTotalConcentrar = 0;
	LET iDuplicado = 0; 
	LET iTotalDuplicados = 0;		
	LET dFechaHoy = DATE(CURRENT);
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE bdicnweb:"informix".sw_cg_validaestatus
			SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
			WHERE usuario_inserta = pUsuario;
		
			RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
			iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
			cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfmonitoroperacionescaja.out';
		--TRACE ON;
		
		DELETE FROM bdicnweb:"informix".sw_cg_validaestatus WHERE usuario_inserta = pUsuario;
	
		INSERT INTO bdicnweb:"informix".sw_cg_validaestatus(id_status, desc_status, usuario_inserta, fecha)
		VALUES ('I', 'INICIA_PROCESO', pUsuario, CURRENT);
	
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pFechaInic IS NULL OR pFechaFin IS NULL OR pIdProvCaja = '' OR pOperacion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			
				UPDATE bdicnweb:"informix".sw_cg_validaestatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
	
			RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
			iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
			cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
		END IF;
		
		-- VALIDACION DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			
			UPDATE bdicnweb:"informix".sw_cg_validaestatus
			SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
			WHERE usuario_inserta = pUsuario;
	
			RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
			iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
			cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
			iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
			cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
		END IF;
		
		--Se limpia tabla por usuario
		DELETE FROM bdicnweb:"informix".sw_cg_monitoroperacioness WHERE us_insert = TRIM(pUsuario);
		
		IF pIdSucursal = '0000' AND pIdMostrar = '0000' THEN
			LET pIdSucursal = '';  
			LET pIdMostrar = '';
		END IF;
		
		--REPORTE DETALLE EXCEL
		IF pOperacion = '1' THEN
			
			IF pRegistros = 0 THEN
			
				--Se limpia tabla por usuario
				--DELETE FROM bdicnweb:"informix".sw_cg_monitoroperacioness WHERE us_insert = TRIM(pUsuario);
			
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				FOREACH	
				
					EXECUTE PROCEDURE bdisuc:"informix".sp_monitor_operaciones2_2(cEmpresa, pTipoSucursal, pIdSucursal, pIdMostrar, pFechaInic, pFechaFin, pIdProvCaja)
					INTO cCodRetSp, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM
						
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_monitor_operaciones2_2';
					ELIF cCodRetSp::INTEGER = 1 THEN
						IF pRegistros = 0 THEN
							LET cCodRet = '00017';			
						ELSE 
							LET cCodRet = '1001';
						END IF;
						
						UPDATE bdicnweb:"informix".sw_cg_validaestatus
						SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
						WHERE usuario_inserta = pUsuario;
						
						RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
					ELSE
					
						IF (pIdMostrar = '0002' AND cCodStatus = '06') OR (pIdMostrar = '0041' AND cCodStatus = '14') THEN
							LET iStatusConcentrar = 1;
						ELSE 
							LET iStatusConcentrar = 0;
						END IF;
						
						LET iRecuperacion = iRecuperacion + 1;
						INSERT INTO bdicnweb:"informix".sw_cg_monitoroperacioness
						VALUES (iRecuperacion, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, 
						cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, 
						iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, 
						iDuplicado, iStatusConcentrar, 0, 0, pUsuario, dFechaHoy);
					
					END IF;
				
				END FOREACH;
			
			END IF;
				
			LET iRecuperacion = 0;
			
			--Actualiza Duplicado (misma suc, misma papeleta)
			MERGE INTO bdicnweb:"informix".sw_cg_monitoroperacioness a
			USING (SELECT DISTINCT(cg.sucursal),LTRIM(cg.papeleta,'0') AS papeleta_repetida, COUNT(cg.sucursal) AS total_registros
			FROM  ((SELECT sucursal,LTRIM(papeleta,'0') as papeleta
				  FROM bdicnweb:"informix".sw_cg_monitoroperacioness 
				  WHERE us_insert = TRIM(pUsuario)) cg)
			GROUP BY cg.sucursal,cg.papeleta
			HAVING COUNT(cg.sucursal) > 1)b ON a.sucursal = b.sucursal AND LTRIM(a.papeleta,'0') = b.papeleta_repetida AND a.us_insert = TRIM(pUsuario)
			WHEN MATCHED THEN
			UPDATE SET a.duplicado = 1;

			--Actualiza Duplicado (misma suc, mismo importe)
			MERGE INTO bdicnweb:"informix".sw_cg_monitoroperacioness a
			USING (SELECT DISTINCT(cg.sucursal),cg.importe AS importe_repetido, COUNT(cg.sucursal) AS total_registros
			FROM  bdicnweb:"informix".sw_cg_monitoroperacioness cg WHERE cg.us_insert = TRIM(pUsuario)
			GROUP BY cg.sucursal,cg.importe
			HAVING COUNT(cg.sucursal) > 1)b ON a.sucursal = b.sucursal AND a.importe = b.importe_repetido AND a.us_insert = TRIM(pUsuario)
			WHEN MATCHED THEN
			UPDATE SET a.duplicado = 1;

			--Total duplicados
			SELECT COUNT(duplicado) INTO iTotalDuplicados
			FROM bdicnweb:"informix".sw_cg_monitoroperacioness
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy AND duplicado = 1 AND posicion_rep = 1;
			
			--Total status
			SELECT COUNT(status_concentrar) INTO iTotalConcentrar
			FROM bdicnweb:"informix".sw_cg_monitoroperacioness
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy AND status_concentrar = 1 AND duplicado = 0;
			
			--UPDATE
			UPDATE bdicnweb:"informix".sw_cg_monitoroperacioness 
			SET total_duplicado = iTotalDuplicados, total_status_concentrar = iTotalConcentrar
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
				
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion sucursal, desc_sucursal, fecha_operacion, desc_status, folio_operacion,
				importe, operacion, cod_proveedor, terceros, papeleta, usuario, cod_tatus, id_atm, billete_1000, billete_500,
				billete_200, billete_100, billete_50, billete_20, billete_10, billete_5, billete_2, billete_1, billete_c50,
				desc_caja, posicion_rep, saldo_caja, cc_atm, duplicado
				INTO cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, 
				cPapeleta, cUsuario, cCodStatus, iIdATM, iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, 
				iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado
				FROM bdicnweb:"informix".sw_cg_monitoroperacioness
				WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy
				ORDER BY desc_sucursal, duplicado DESC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cSucursal||' '||UPPER(cDescSucursal), dFechaOperacion, UPPER(cDescStatus), cFolioOperacion, mImporte, UPPER(cOperacion), 
				cCodProveedor, UPPER(cTerceros), cPapeleta, UPPER(cUsuario), cCodStatus, iIdATM, iBillete1000, iBillete500, iBillete200, 
				iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, UPPER(cDescCaja), 
				iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar WITH RESUME;
			END FOREACH;

			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00151';
				
				UPDATE bdicnweb:"informix".sw_cg_validaestatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				
				RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				
				UPDATE bdicnweb:"informix".sw_cg_validaestatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				
				RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
			END IF;
		
		--CONSULTA GRID
		ELIF pOperacion = '2' THEN
			
			IF pRegistros = 0 THEN
	
				--Se limpia tabla por usuario
				--DELETE FROM bdicnweb:"informix".sw_cg_monitoroperacioness WHERE us_insert = TRIM(pUsuario);
	
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				FOREACH	
				
					EXECUTE PROCEDURE bdisuc:"informix".sp_monitor_operaciones3_2(cEmpresa, pTipoSucursal, pIdSucursal, pIdMostrar, pFechaInic, pFechaFin, pIdProvCaja)
					INTO cCodRetSp, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM
						
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_monitor_operaciones3_2';
					ELIF cCodRetSp::INTEGER = 1 THEN
						IF pRegistros = 0 THEN
							LET cCodRet = '00017';
						ELSE 
							LET cCodRet = '1001';
						END IF;
						
						UPDATE bdicnweb:"informix".sw_cg_validaestatus
						SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
						WHERE usuario_inserta = pUsuario;
						
						RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
						cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
					ELSE
					
						IF (pIdMostrar = '0002' AND cCodStatus = '06') OR (pIdMostrar = '0041' AND cCodStatus = '14') THEN
							LET iStatusConcentrar = 1;
						ELSE 
							LET iStatusConcentrar = 0;
						END IF;
					
						LET iRecuperacion = iRecuperacion + 1;
						INSERT INTO bdicnweb:"informix".sw_cg_monitoroperacioness						
						VALUES (iRecuperacion, cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, 
						cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, 
						iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, 
						iDuplicado, iStatusConcentrar, 0, 0, pUsuario, dFechaHoy);
					
					END IF;
					
				END FOREACH;
				
			END IF;
				
			LET iRecuperacion = 0;
			
			--Actualiza Duplicado (misma suc, misma papeleta)
			MERGE INTO bdicnweb:"informix".sw_cg_monitoroperacioness a
			USING (SELECT DISTINCT(cg.sucursal),LTRIM(cg.papeleta,'0') AS papeleta_repetida, COUNT(cg.sucursal) AS total_registros
			FROM  ((SELECT sucursal,LTRIM(papeleta,'0') as papeleta
				  FROM bdicnweb:"informix".sw_cg_monitoroperacioness 
				  WHERE us_insert = TRIM(pUsuario)) cg)
			GROUP BY cg.sucursal,cg.papeleta
			HAVING COUNT(cg.sucursal) > 1)b ON a.sucursal = b.sucursal AND LTRIM(a.papeleta,'0') = b.papeleta_repetida AND a.us_insert = TRIM(pUsuario)
			WHEN MATCHED THEN
			UPDATE SET a.duplicado = 1;

			--Actualiza Duplicado (misma suc, mismo importe)
			MERGE INTO bdicnweb:"informix".sw_cg_monitoroperacioness a
			USING (SELECT DISTINCT(cg.sucursal),cg.importe AS importe_repetido, COUNT(cg.sucursal) AS total_registros
			FROM  bdicnweb:"informix".sw_cg_monitoroperacioness cg WHERE cg.us_insert = TRIM(pUsuario)
			GROUP BY cg.sucursal,cg.importe
			HAVING COUNT(cg.sucursal) > 1)b ON a.sucursal = b.sucursal AND a.importe = b.importe_repetido AND a.us_insert = TRIM(pUsuario)
			WHEN MATCHED THEN
			UPDATE SET a.duplicado = 1;

			--Total duplicados
			SELECT COUNT(duplicado) INTO iTotalDuplicados
			FROM bdicnweb:"informix".sw_cg_monitoroperacioness
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy AND duplicado = 1 AND posicion_rep = 1;
			
			--Total status
			SELECT COUNT(status_concentrar) INTO iTotalConcentrar
			FROM bdicnweb:"informix".sw_cg_monitoroperacioness
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy AND status_concentrar = 1 AND duplicado = 0;
			
			--UPDATE
			UPDATE bdicnweb:"informix".sw_cg_monitoroperacioness 
			SET total_duplicado = iTotalDuplicados, total_status_concentrar = iTotalConcentrar
			WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
				
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion sucursal, desc_sucursal, fecha_operacion, desc_status, folio_operacion,
				importe, operacion, cod_proveedor, terceros, papeleta, usuario, cod_tatus, id_atm, billete_1000, billete_500,
				billete_200, billete_100, billete_50, billete_20, billete_10, billete_5, billete_2, billete_1, billete_c50,
				desc_caja, posicion_rep, saldo_caja, cc_atm, duplicado
				INTO cSucursal, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, 
				cPapeleta, cUsuario, cCodStatus, iIdATM, iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, 
				iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado
				FROM bdicnweb:"informix".sw_cg_monitoroperacioness
				WHERE us_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy
				ORDER BY desc_sucursal, duplicado DESC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cSucursal||' '||UPPER(cDescSucursal), dFechaOperacion, UPPER(cDescStatus), cFolioOperacion, mImporte, UPPER(cOperacion), 
				cCodProveedor, UPPER(cTerceros), cPapeleta, UPPER(cUsuario), cCodStatus, iIdATM, iBillete1000, iBillete500, iBillete200, 
				iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, UPPER(cDescCaja), 
				iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar WITH RESUME;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00151';
				
				UPDATE bdicnweb:"informix".sw_cg_validaestatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				
				RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				
				UPDATE bdicnweb:"informix".sw_cg_validaestatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				
				RETURN cCodRet, cSucursal||' '||cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, 
				cDescCaja, iPosicionRep, mSaldoCaja, cCcATM, iDuplicado, iTotalDuplicados, iTotalConcentrar;
			END IF;
			
		END IF;
		
		UPDATE bdicnweb:"informix".sw_cg_validaestatus
		SET id_status = 'F', desc_status = 'FINALIZA_PROCESO'
		WHERE usuario_inserta = pUsuario;
		
	END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 12/01/2015',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR DE OPERACIONES',
'DESCRIPCION: SPL que realiza la consulta para el llenado del grid Transacciones, Monitor de Operaciones Caja General',
'AUTOR: L. Montserrat León Amador',
'FECHA: 20/06/2016',
'DESCRIPCION: Se agrega un parametro tipo operacion para determinar si es consulta a grid(1) o reporte detalle excel(2)',
'AUTOR: L. Montserrat León Amador',
'FECHA: 14/10/2016',
'DESCRIPCION: Se agrega filtro para marcar los archivos que se encuentran duplicados.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 24/11/2016',
'DESCRIPCION: Se agrega LTRIM al Actualizar Duplicado (misma suc, misma papeleta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_blqconcentractainactivascap(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codRet;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCuenta CHAR(20);
	DEFINE cSpCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolio CHAR(16);
	DEFINE iNumArchivo INTEGER; --int;
	DEFINE dFechaHoy DATE;
	DEFINE iEnTransaccion SMALLINT;
	DEFINE iTotalCuentasTraspasar INT;
	DEFINE mTotalMontoTraspasar DECIMAL(18,2);
	DEFINE iTotalCuentasExlcuir INT;
	DEFINE mTotalMontoExcluir DECIMAL(18,2);
	DEFINE dHoy DATETIME YEAR TO SECOND;
	DEFINE bInTransaccion BOOLEAN;	

	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCuenta = '';
	LET cSpCodRet = '';
	LET cEmpresa = '001';
	LET iNumArchivo = 0;
	LET cFolio = '';
	LET iEnTransaccion = 0;	
	LET bInTransaccion = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_deb_statusregistraevento
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pIdUsuario);

			RETURN cCodRet;
		END EXCEPTION;

		ON EXCEPTION IN (-535,-255)
			LET iEnTransaccion = 1;												
			COMMIT WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_blqconcentractainactivascap.out';
		--TRACE ON;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_deb_statusregistraevento
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pIdUsuario);

			RETURN cCodRet;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_deb_statusregistraevento WHERE usuario = TRIM(pIdUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_deb_statusregistraevento(usuario,status,error_proceso,error)
		VALUES(pIdUsuario,'I','','');  			
			
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdicheq:sc_fechas
		WHERE empresa = cEmpresa;

		BEGIN WORK; -- Para saber si es por interact
		IF iEnTransaccion = 0 THEN
			COMMIT WORK;
		END IF;
		
		-- Obtenemos el total de cuentas a concentrar y el monto
		EXECUTE FUNCTION bdicnweb:sp_constotalctasmontoctasconcentradas (pIdUsuario, pIdFuncion)
		INTO cSpCodRet, iTotalCuentasTraspasar, mTotalMontoTraspasar;

		-- Obtenemos el total de la exlcusión
		SELECT {+INDEX(bdicheq:sc_ctasinactinfor3anios3meses idx_ctainform33_cta)} COUNT(cuenta), NVL(SUM(sdo_actual), 0)
		INTO iTotalCuentasExlcuir, mTotalMontoExcluir
		FROM bdicheq:sc_ctasinactinfor3anios3meses 
		WHERE cuenta IN (SELECT {+INDEX(bdicnweb:sc_cuentas_concentradas_excluidas idx_ctaconcentradaex)} cuenta FROM bdicnweb:sc_cuentas_concentradas_excluidas);

		SET ISOLATION TO DIRTY READ;

		FOREACH WITH HOLD

			SELECT {+INDEX(bdicheq:sc_ctasinactinfor3anios3meses idx_ctainform33_cta)} {+INDEX(bdicheq:sc_maechq idx_maechq1)} cc.cuenta, nvl(NULL, 1)
			INTO cCuenta, iNumArchivo
			FROM bdicheq:sc_ctasinactinfor3anios3meses cc, bdicheq:sc_maechq mc
			WHERE cc.fecha_rep = (select max(fecha_rep) from bdicheq:sc_ctasinactinfor3anios3meses)
				AND cc.cuenta NOT IN(select {+INDEX(bdicnweb:sc_cuentas_concentradas_excluidas idx_ctaconcentradaex)} cuenta from bdicnweb:sc_cuentas_concentradas_excluidas)
				AND mc.cuenta = cc.cuenta
				AND mc.status_cta = '5'
				AND mc.empresa = '001'
				
			EXECUTE PROCEDURE bdicheq:sp_blqconcentractainactivas(cEmpresa, cCuenta, iNumArchivo) 
			INTO cSpCodRet, cFolio, iNumArchivo;

			BEGIN WORK;
				INSERT INTO bdicnweb:sc_cuentas_concentradas_procesadas(usuario, cuenta, fecha_proceso, status_proceso, hora_proceso)
				VALUES(pIdUsuario, cCuenta, dFechaHoy, cSpCodRet, current);
			COMMIT WORK;

			CONTINUE FOREACH;

		END FOREACH;

		-- Se eliminan las cuentas de la tabla de cuentas excluidas
		EXECUTE PROCEDURE bdicnweb:sp_blqcancelactaexcluidacap(pIdUsuario, pIdFuncion) into cCodRet;

		-- Se llama al procedimiento del registro del event
		LET dHoy = current;

		EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
				'1', 
				TRIM(pIdPlantilla), 
				TRIM(pIdPlantilla),                     
				pIdUsuario, 
				'',
				'', 
				'1', 
				(iTotalCuentasTraspasar - iTotalCuentasExlcuir),
				TRIM(TO_CHAR((mTotalMontoTraspasar - mTotalMontoExcluir), "#,###,###,###,###.##")),
				'',
				'',
				'',
				'',
				'',
				'',
				'',
				TRIM(pTituloPlantilla),
				'',
				'',
				'0',
				'0',
				'0',
				'0',
				'0',
				dHoy,
				dHoy) INTO cSpCodRet;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdicnweb:"informix".sw_deb_statusregistraevento
		SET status = 'T', error_proceso = 'N' WHERE usuario = TRIM(pIdUsuario);	
		
		IF iEnTransaccion = 1 THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 28/06/2013",
"DESCRIPCION: Procedimiento que realiza el traspaso de las cuentas a la cuenta global",
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Debito',
'FUNCIONALIDAD: Traspaso Cuenta Global',
'DESCRIPCION: Se agrega validacion para verificar el estatus en que se encuentra',
'la ejecucion del proceso de Traspaso a Cuenta Global',
'AUTOR: L. Montserrat León Amador',
'FECHA: 20/12/2016',
'DESCRIPCION: Se ajusta la variable iNumArchivo a INTEGER y se prepara el spl para el tratado de transacciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusregistraevt(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
	    CHAR(1) AS status,                          
	    CHAR(1) AS error_proceso,
	    CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER; 
	DEFINE cStatus CHAR(1);        
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;        
	LET cStatus = '';        
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
        
		ON EXCEPTION SET iSqlErr                        
				LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
				RETURN cCodRet,cStatus,cErrorProceso,cError;    
		END EXCEPTION;
 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusregistraevt.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError;    
		END IF;         
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT status,error_proceso,error
		INTO cStatus,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_deb_statusregistraevento WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError;                    
		ELSE                    
			RETURN cCodRet,cStatus,cErrorProceso,cError;            
		END IF; 
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Miguel Huitzil Cuachayo',
'FECHA: 17/11/2016',
'MODULO: Debito',
'FUNCIONALIDAD: Traspaso Cuenta Global', 
'DESCRIPCION: SPL que consulta el Estatus del proceso de Traspaso a Cuenta Global',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_genreportectesnofusionados(pUsuario CHAR(8), pIdFuncion CHAR(10), 
        pFechaInicio DATE, pFechaFin DATE, pIdEmpleado CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
        
                RETURNING CHAR(5) AS codret,
                        CHAR(8) AS num_analista,
                        CHAR(45) AS nombre_analista,
                        DATE AS fecha_validacion,
                        CHAR(1) AS id_cliente1,
                        CHAR(20) AS num_cliente1,
                        CHAR(26) AS primer_nombre_cte1,
                        CHAR(26) AS segundo_nombre_cte1,
                        CHAR(26) AS apell_paterno_cte1,
                        CHAR(26) AS apell_materno_cte1,
                        DATE AS fecha_nac_cte1,
                        CHAR(1) AS genero_cte1,
                        CHAR(100) AS observacion_cte1,
                        CHAR(1) AS id_cliente2,
                        CHAR(20) AS num_cliente2,
                        CHAR(26) AS primer_nombre_cte2,
                        CHAR(26) AS segundo_nombre_cte2,
                        CHAR(26) AS apell_paterno_cte2,
                        CHAR(26) AS apell_materno_cte2,
                        DATE AS fecha_nac_cte2,
                        CHAR(1) AS genero_cte2,
                        CHAR(100) AS observacion_cte2,
						CHAR(4) AS sucursal_cte1,
						CHAR(40) AS nombre_sucursal_cte1,
						CHAR(4) AS sucursal_cte2,
						CHAR(40) AS nombre_sucursal_cte2;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumAnalista CHAR(8);
        DEFINE cNombreAnalista CHAR(45);
        DEFINE dFechaValidacion DATETIME YEAR TO FRACTION(3);
        DEFINE cNumCte1 CHAR(20);
        DEFINE cNumCte2 CHAR(20);
        DEFINE cCteCorrecto CHAR(1);
        DEFINE cFlagFusion CHAR(1);
        DEFINE cIdCliente1 CHAR(1);
        DEFINE cIdCliente2 CHAR(1);
		DEFINE cIdRegistro INTEGER;
        
        DEFINE cNumCliente1 CHAR(20);
        DEFINE cPrimerNombreCte1 CHAR(26);
        DEFINE cSegundoNombreCte1 CHAR(26);
        DEFINE cApellPaternoCte1 CHAR(26);
        DEFINE cApellMaternoCte1 CHAR(26);
        DEFINE dFechaNacCte1 DATE;
        DEFINE cGeneroCte1 CHAR(1);
        DEFINE cObservacionCte1 CHAR(100);
        DEFINE cNumCliente2 CHAR(20);
        DEFINE cPrimerNombreCte2 CHAR(26);
        DEFINE cSegundoNombreCte2 CHAR(26);
        DEFINE cApellPaternoCte2 CHAR(26);
        DEFINE cApellMaternoCte2 CHAR(26);
        DEFINE dFechaNacCte2 DATE;
        DEFINE cGeneroCte2 CHAR(1);
        DEFINE cObservacionCte2 CHAR(100);
        DEFINE iIdMotivo INTEGER;
        DEFINE cDescMotivoOtro CHAR(100);
        DEFINE cDescMotivoPendiente CHAR(100);
        DEFINE iRecuperacion INTEGER;
		DEFINE cIdReporte INTEGER;
		DEFINE cSucursalCte1 CHAR(4);
		DEFINE cNombreSucursalCte1 CHAR(40);
		DEFINE cSucursalCte2 CHAR(4);
		DEFINE cNombreSucursalCte2 CHAR(40);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cNumAnalista = '';
        LET cNombreAnalista = '';
        LET dFechaValidacion = '';
        LET cNumCte1 = '';
        LET cNumCte2 = '';
        LET cCteCorrecto = '';
        LET cFlagFusion = '';
        LET cIdCliente1 = '1';
        LET cIdCliente2 = '2';
        
        LET cNumCliente1 = '';
        LET cPrimerNombreCte1 = '';
        LET cSegundoNombreCte1 = '';
        LET cApellPaternoCte1 = '';
        LET cApellMaternoCte1 = '';
        LET dFechaNacCte1 = '';
        LET cGeneroCte1 = '';
        LET cObservacionCte1 = '';
        LET cNumCliente2 = '';
        LET cPrimerNombreCte2 = '';
        LET cSegundoNombreCte2 = '';
        LET cApellPaternoCte2 = '';
        LET cApellMaternoCte2 = '';
        LET dFechaNacCte2 = '';
        LET cGeneroCte2 = '';
        LET cObservacionCte2 = '';
        LET iIdMotivo = 0;
        LET cDescMotivoOtro = '';
        LET cDescMotivoPendiente = '';
        LET iRecuperacion = 0;
		LET cIdReporte = 0;
		LET cSucursalCte1 = '';
		LET cNombreSucursalCte1 = '';
		LET cSucursalCte2 = '';
		LET cNombreSucursalCte2 = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_tr_genreportectesnofusionados.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL 
                OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                END IF;
                
                -- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
                IF pRegistros < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                FOREACH 
                
                        -- Detalle registros a fusionar
                        SELECT SKIP pRegistros FIRST pRecuperacion a.user_asig, NVL(b.nombre, '') AS nombre_analista, a.fecha_dict, a.numcte_1, a.numcte_2, a.cte_correcto, a.flag_fusion, a.id_registro
                        INTO cNumAnalista,cNombreAnalista,dFechaValidacion,cNumCte1,cNumCte2,cCteCorrecto,cFlagFusion, cIdReporte
                        FROM (bdicnweb:"informix".sw_tr_clientesduplicados a LEFT JOIN 
                                  bdinteg:"informix".si_ejecut b ON b.ejecutivo = a.user_asig)
                        WHERE flag_fusion IN ('0','3')
                        AND fecha_dict::DATE BETWEEN pFechaInicio AND pFechaFin
                        AND a.user_asig = CASE WHEN pIdEmpleado = '' THEN a.user_asig ELSE pIdEmpleado END

                        SELECT cNumCte1, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, d.fecha_nac, d.sexo, c.sucursal
                        INTO cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1, cSucursalCte1
                        FROM bdinteg:"informix".si_cliente c, bdinteg:"informix".si_ctepf d
                        WHERE c.numcte = d.numcte 
                        AND c.numcte = cNumCte1; 
						
                        SELECT s.nombre 
						INTO cNombreSucursalCte1
						FROM bdinteg:"informix".si_cliente c
						INNER JOIN bdinteg:"informix".si_sucursales s ON c.sucursal = s.sucursal
						WHERE c.numcte = cNumCte1;
			
                        SELECT cNumCte2, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, d.fecha_nac, d.sexo, c.sucursal
                        INTO cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2, cSucursalCte2
                        FROM bdinteg:"informix".si_cliente c, bdinteg:"informix".si_ctepf d
                        WHERE c.numcte = d.numcte 
                        AND c.numcte = cNumCte2;
						
						SELECT s.nombre 
						INTO cNombreSucursalCte2
						FROM bdinteg:"informix".si_cliente c
						INNER JOIN bdinteg:"informix".si_sucursales s ON c.sucursal = s.sucursal
						WHERE c.numcte = cNumCte2;
                        
                        -- Consulta Motivo Pendiente
                        SELECT FIRST 1 id_motivo_pendiente, desc_motivo_otro
                        INTO iIdMotivo, cDescMotivoOtro
                        FROM bdicnweb:"informix".sw_tr_fusion_motivos_pendiente
                        WHERE id_registro = cIdReporte;
                        
                        LET cObservacionCte1 = '';
                        
                        IF iIdMotivo = 5 THEN
                                LET cObservacionCte1 = cDescMotivoOtro;
                        ELIF iIdMotivo IN (1,2,3,4) THEN
                                SELECT desc_motivo_pendiente
                                INTO cDescMotivoPendiente
                                FROM bdicnweb:"informix".sw_tr_fusioncat_motivos_pendiente
                                WHERE id_motivo_pendiente = iIdMotivo;
                        
                                LET cObservacionCte1 = REPLACE(SUBSTRING(cDescMotivoPendiente FROM 6), '.','');
                        END IF;
                        
                        LET iRecuperacion = iRecuperacion + 1;
                        
                        LET cNumCliente1 = cNumCte1;
                        LET cNumCliente2 = cNumCte2;
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2 WITH RESUME;
                                
                END FOREACH;
                
                IF iRecuperacion = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet,cNumAnalista,cNombreAnalista,dFechaValidacion,cIdCliente1,cNumCliente1,cPrimerNombreCte1,cSegundoNombreCte1,cApellPaternoCte1,cApellMaternoCte1,dFechaNacCte1,cGeneroCte1,cObservacionCte1,
                        cIdCliente2,cNumCliente2,cPrimerNombreCte2,cSegundoNombreCte2,cApellPaternoCte2,cApellMaternoCte2,dFechaNacCte2,cGeneroCte2,cObservacionCte2,cSucursalCte1,cNombreSucursalCte1,cSucursalCte2,cNombreSucursalCte2;
                END IF;         
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 22/12/2015',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Reportes de Fusión de Clientes',
'DESCRIPCION: Consulta el detalle de los registros de fusion semiautomatizada no fusionados.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 23/02/2016',
'DESCRIPCION: Se realizo la modificacion edel parametro de num_cliente a id_registro de la tabla correspondiente.',
'Modificó: Johnattan Esquivel Sánchez',
'Fecha de modificación: 20/12/2016',
'Modificación: Se modifica para agregar la sucursal y el nombre de la Sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cli_consultadocumentos_especificos(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pTiposDocumentos CHAR(255), pDireccionMAC CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS cod_docto,
				CHAR(35) AS desc_docto,
				CHAR(3) AS cod_grupo,
				CHAR(30) AS desc_grupo,
				CHAR(1) AS multi_img,
				INTEGER AS img_tam_max,
				CHAR(3) AS img_formato,
				SMALLINT AS img_compresion,
				DECIMAL AS img_largo,
				DECIMAL AS img_ancho,
				SMALLINT AS img_dpi,
				CHAR(1) AS img_colores,
				CHAR(1) AS generico,
				CHAR(1) AS ligar;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cCodigoDocto CHAR(4);
	DEFINE cCodDocto CHAR(4);
	DEFINE cDescDocto CHAR(35);
	DEFINE cCodGrupo CHAR(3);
	DEFINE cDescGrupo CHAR(30);
	DEFINE cMultiImg CHAR(1);
	DEFINE iImgTamMax INTEGER;
	DEFINE cImgFormato CHAR(3);
	DEFINE iImgCompresion SMALLINT;
	DEFINE dImgLargo DECIMAL;
	DEFINE dImgAncho DECIMAL;
	DEFINE iImgDPI SMALLINT;
	DEFINE cImgColores CHAR(1);
	DEFINE cGenerico CHAR(1);
	DEFINE cLigar CHAR(1);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cEmpresa = '001';
	LET cCodigoDocto = '';
	LET cCodDocto = '';
	LET cDescDocto = '';
	LET cCodGrupo = '';
	LET cDescGrupo = '';
	LET cMultiImg = '';
	LET iImgTamMax = 0;
	LET cImgFormato = '';
	LET iImgCompresion = 0;
	LET dImgLargo = NULL;
	LET dImgAncho = NULL;
	LET iImgDPI = 0;
	LET cImgColores = '';
	LET cGenerico = '';
	LET cLigar = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_consultadocumentos_especificos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pDireccionMAC = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2) THEN	
			LET cCodRet = '00440';
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion = 1 THEN
			IF pTiposDocumentos = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		END IF;
		
		IF pTipoOperacion = 2 THEN
			IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion = 1 THEN
		
			DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
		
			FOREACH EXECUTE PROCEDURE "informix".sp_split_cadena(pTiposDocumentos, '|') INTO cCodigoDocto
				FOREACH EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultadocumentoespecifico(cEmpresa, cCodigoDocto)
					INTO cCodRetSp, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar
					
					INSERT INTO bdicnweb:"informix".sw_cli_tmp_docespecificos(usuario, mac, cod_documento, desc_documento, cod_grupo, desc_grupo, multi_img, img_tam_max, img_formato, 
														img_compresion, img_largo, img_ancho, img_dpi, img_colores, generico, ligar)
					VALUES(pUsuario, pDireccionMAC, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar);
					
				END FOREACH;
			END FOREACH;
			
			RETURN cCodRet, "", "", "", "", "", 0, "", 
					0, NULL, NULL, 0, "", "", "";
		END IF;
		
		IF pTipoOperacion = 2 THEN
			SET ISOLATION TO DIRTY READ;
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion cod_documento, desc_documento, cod_grupo, desc_grupo, multi_img, img_tam_max, img_formato, 
					img_compresion, img_largo, img_ancho, img_dpi, img_colores, generico, ligar
				INTO cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar
				FROM bdicnweb:"informix".sw_cli_tmp_docespecificos
				WHERE usuario = pUsuario AND mac = pDireccionMAC
				
				RETURN cCodRet, cCodDocto, UPPER(cDescDocto), cCodGrupo, UPPER(cDescGrupo), cMultiImg, iImgTamMax, UPPER(cImgFormato), 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;
				
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017';
				ELIF pRegistros > 0 THEN
					DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
					LET cCodRet = '1001';
				END IF;
				
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
			
			IF iNoRegistros > 0 AND iNoRegistros < pRecuperacion THEN
				DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
			END IF;
			
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 11/11/2015',
'MODULO: Clientes',
'FUNCIONALIDAD: Mantenimiento a expediten digital',
'DESCRIPCION: Consulta las definiciones de los codigos de documentos enviados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_catalogoproductoscat(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(4)  AS id_producto,
		CHAR(40) AS desc_producto;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cIdProducto = '';
	LET cDescProducto = '';
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProducto, cDescProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_catalogoproductoscat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		FOREACH
		SELECT num_producto, nombre_prod
		INTO cIdProducto, cDescProducto
		FROM bdicred:"informix".sd_definicion
		WHERE num_producto IN(6001, 6011, 6300, 6400, 7600,7700)
		
		RETURN cCodRet, cIdProducto, UPPER(TRIM(cDescProducto)) WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta los productos del Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultadivisionescat(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
        INTEGER  AS id_division,
        CHAR(10) AS desc_divicion;
                
                
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
    DEFINE iCodRetSp INTEGER;
    DEFINE cEmpresa CHAR(3);
    DEFINE cMensajeRet CHAR(80);
    DEFINE cIdDivision INTEGER;
    DEFINE cDescDivision CHAR(10);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '00000';
    LET iCodRetSp = 0;
    LET cEmpresa = '001';
    LET cMensajeRet = '';
    LET cIdDivision = 0;
    LET cDescDivision = '';
    LET iRecuperacion = 0;
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDivision, cDescDivision;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_x.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
            EXECUTE PROCEDURE bdicobranza:"informix".sp_consultardivisiones(cEmpresa)  
            INTO cCodRetSp, cMensajeRet, cIdDivision, cDescDivision
            
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                    RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultardivisiones';
            ELIF cCodRetSp::INTEGER = 1 THEN
                    LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
                    LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, cIdDivision,  UPPER(TRIM(cDescDivision)) WITH RESUME;           
        END FOREACH;
                
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta las divisiones que se encuentran dadas de alta en el Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultafechacorteproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER AS dia_corte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iDiaCorte INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iDiaCorte = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDiaCorte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultafechacorteproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pProducto ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iDiaCorte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iDiaCorte;
		END IF;
		
			SET ISOLATION TO DIRTY READ;
			FOREACH		
				
				SELECT a.dia_corte
				INTO iDiaCorte
				FROM sw_cr_productodiacorte a
				WHERE a.num_producto=pProducto
				ORDER BY 1 ASC
				
				LET iNoRegistros = iNoRegistros +1;
				
				RETURN cCodRet,iDiaCorte  WITH RESUME;
			END FOREACH;
		
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        
		IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iDiaCorte;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 28/10/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta los dias de corte del producto',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 11/11/2016',
'MODIFICACION: Cambio de tabla de consulta de dia de corte por producto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaobtcanalorigencat(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumParam INTEGER)
    RETURNING CHAR(5) AS codret,
    DECIMAL(18,2) AS id_valor_alfabetico,
    CHAR(100) AS des_valor_alfabetico;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(85);
	DEFINE dIdValorAlfabetico DECIMAL(18,2);
	DEFINE cDesValorAlfabetico  CHAR(100);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET dIdValorAlfabetico = 0.00;
	LET cDesValorAlfabetico = '';
	LET iNoRegistros = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
        END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaobtcanalorigencat.out';
        --TRACE ON;

        IF pUsuario = '' OR pIdFuncion = ''  OR pNumParam IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
        END IF;


        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
			RETURN cCodRet,dIdValorAlfabetico,cDesValorAlfabetico;
        END IF;

        SET ISOLATION TO DIRTY READ;
        FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_obtcanalorigen(pNumParam)
			INTO cCodRetSp, cMensajeRet, dIdValorAlfabetico,cDesValorAlfabetico
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicobranza:sp_obtcanalorigen ";
			ELIF cCodRetSp::INTEGER = 2  THEN
					LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
		END IF;

    END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza ',
'FECHA: 21/03/2015',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION:SPL que realiza la consulta del canar  de origen para la consulta de administracion de campañas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaregionescat(pUsuario CHAR(8), pIdFuncion CHAR(10), pDivicion SMALLINT)
	RETURNING CHAR(5) AS codret,                
	SMALLINT As id_region,
	CHAR (30) As desc_Region; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdRegion SMALLINT;
	DEFINE cDescREgistros CHAR(30);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';   
	LET cIdRegion = 0;
	LET cDescREgistros = '';
	LET iRecuperacion = 0;
	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaregionescat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDivicion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;    
		FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_consultarregiones(pDivicion, cEmpresa)
			INTO cCodRetSp, cIdRegion, cDescREgistros
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultarregiones';
			ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
		
			RETURN cCodRet, cIdRegion, UPPER(TRIM(cDescREgistros)) WITH RESUME;             
		END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdRegion, cDescREgistros;
		END IF;
	END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta las regiones que se encuentran dadas de alta en el Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultastatusproceso(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS id_status,
		CHAR(30) AS desc_status;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultastatusproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		SELECT id_status, desc_status
		INTO cIdStatus, cDescStatus
		FROM "informix".sw_cr_tipostatus
		WHERE usuario_inserta = pUsuario;
			
		IF cIdStatus  = '' THEN
			RETURN cCodRet, 'I', 'INICIA_PROCESO';
		ELSE 
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 25/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta de los estatus para monitorear el proceso del spl de sp_cre_consultarcompromisosacuerdoscat y sp_cre_consultarcompromisosacuerdoscat_totales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultasucursalescat(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegion SMALLINT ,pSucursal CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,            
        CHAR(4) AS id_sucursal,
        CHAR(40) AS desc_sucursal;              
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cIdSucursal CHAR(4);
        DEFINE cDescSucursal CHAR(40);
        DEFINE iNoRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cIdSucursal = '';
        LET cDescSucursal = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultasucursalescat.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pRegion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH
					EXECUTE PROCEDURE bdicobranza:"informix".sp_consultarsucursales2(cEmpresa, pRegion, pSucursal, pRegistros, pRecuperacion)
					INTO cCodRetSp, cIdSucursal, cDescSucursal
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultarsucursales2';
					ELIF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00105';
					ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00017';
					END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			
							RETURN cCodRet, cIdSucursal,  UPPER(TRIM(cDescSucursal)) WITH RESUME;           
			END FOREACH;
  
            IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '000002';
				RETURN cCodRet, cIdSucursal, cDescSucursal;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '001001';
				RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;		
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta la informacion de las Sucursales de una Determinada Division',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultatiporeporte(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,                    
		INTEGER AS id_archivo,
		CHAR(80) AS desc_archivo;               
    
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cDescArchivo CHAR(80);
	DEFINE iIdArchivo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iIdArchivo = 0;
	LET cDescArchivo = '';
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdArchivo, cDescArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
        END EXCEPTION WITH RESUME;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultatiporeporte.out';
		--TRACE ON;
                
		IF pUsuario = '' OR pIdFuncion = ''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdArchivo,  cDescArchivo;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdArchivo,  cDescArchivo;
		END IF;
        
		-- CREACION DE TABLA TEMPORAL
		CREATE TEMP TABLE sw_compac_tipo_reporte_tmp(usuario_tmp CHAR(20), cMensajeRet_tmp CHAR(80),iIdArchivo_tmp INTEGER, cDescArchivo_tmp CHAR(80)) WITH NO LOG;
		DELETE FROM sw_compac_tipo_reporte_tmp WHERE usuario_tmp = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_compac_tipo_reporte()
			INTO cCodRetSp, cMensajeRet, iIdArchivo,  cDescArchivo
					
			LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_compac_tipo_reporte';
			END IF;
			
			INSERT INTO sw_compac_tipo_reporte_tmp (usuario_tmp, cMensajeRet_tmp, iIdArchivo_tmp, cDescArchivo_tmp)
			VALUES (pUsuario, cMensajeRet, iIdArchivo,  cDescArchivo);
		END FOREACH;
		
		FOREACH 
			SELECT iIdArchivo_tmp, cDescArchivo_tmp 
			INTO iIdArchivo,  cDescArchivo
			FROM sw_compac_tipo_reporte_tmp
			WHERE usuario_tmp = pUsuario
			AND iIdArchivo_tmp IN (1,2,3, 5)
			ORDER BY iIdArchivo_tmp
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdArchivo,  cDescArchivo WITH RESUME;
		
		END FOREACH;
		 
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdArchivo, cDescArchivo;
		END IF;
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta la informacion de las Sucursales de una Determinada Division',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 11/08/2016',
'DESCRIPCION:Se modifica el spl para q solo muestre los tipos de reportes especificados en la consulta de las Sucursales de una Determinada Division',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_genreporteconveniosifcat(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(80) AS Nombre_archivo,
		CHAR(80) AS ruta;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNombreArchivo CHAR(80);
	DEFINE cMensajeRet CHAR(80);
	DEFINE cRuta CHAR(80);
	DEFINE bTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET cNombreArchivo = '';
	LET cMensajeRet = '';
	LET cRuta = '';
	LET bTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreArchivo, cRuta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bTransaccion = 't';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreporteconveniosifcat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechaFin IS NULL OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		BEGIN WORK;
		IF bTransaccion = 'f' THEN
			COMMIT;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicred:"informix".sp_rep_convenios_sif2_tmp(cEmpresa, pFechaInicio, pFechaFin, pUsuario, pProducto)
		INTO cCodRetSp, cMensajeRet, cNombreArchivo, cRuta;
		
		IF bTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultardivisiones';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			END IF;
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		RETURN cCodRet, cNombreArchivo, cRuta;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE ESTADÍSTICA DE CONVENIOS EN SUCURSAL',
'DESCRIPCION:SPL que genera los reportes de estadistica convenio sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_conscambiostatustarjetas(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaBusqueda DATE, pNoTarjeta CHAR(16), pEstatus CHAR(20), pTramaTarjeta CHAR(250), pOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)							
		RETURNING CHAR(5) AS codret,
			CHAR(19) AS numero_inicial,
			CHAR(19) AS numero_final,
			CHAR(20) AS estatus,
			CHAR(5) AS periodo_exp,
			DATE AS fecha_solicitud,
			CHAR(60) AS comentario,
			CHAR(8) as usuario;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDisponibles INTEGER;
	DEFINE cNumeroInicial CHAR(19);
	DEFINE cNumeroFinal CHAR(19);
	DEFINE cStatus CHAR(20);
	DEFINE cPeriodoExp CHAR(5);
	DEFINE dFechaSolicitud DATE;
	DEFINE cComentario CHAR(60);
	DEFINE cBin CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cSerialFinal CHAR(19);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iTotalDisponibles = 0;
	LET cNumeroInicial = '';
	LET cNumeroFinal = '';
	LET cStatus = '';
	LET cPeriodoExp = '';
	LET dFechaSolicitud = '';
	LET cComentario = '';
	LET cBin = '';
	LET cUsuario = '';
	LET cSerialFinal = '';

	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud,  cComentario, cUsuario;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_conscambiostatustarjetas.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;					
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;				
		
		--REALIZO SOLO LA CONSULTA A atm_tarjeta_admin
		IF pOperacion = 1  THEN
			
			IF pFechaBusqueda <> '' OR pFechaBusqueda IS NOT NULL THEN
			
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud) AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE DATE(fechaSolicitud) = pFechaBusqueda
                          FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE DATE(fechaSolicitud) = pFechaBusqueda						
						ORDER BY numtarjetadmin										
			
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario WITH RESUME;
				END FOREACH;	
			
			ELIF pNoTarjeta <> '' THEN	
			
				--OBTENER VALOR DE CODIGO BIN
				SELECT valor
				INTO cBin
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1;
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1;
				
				LET cSerialFinal = (trim(cBin) || trim(pNoTarjeta));
				LET cSerialFinal = SUBSTRING(cSerialFinal FROM 1 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 5 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 9 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 13 FOR 4);
				
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud) AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE numtarjetadmin = cSerialFinal
						FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE numtarjetadmin = cSerialFinal
						ORDER BY numtarjetadmin										
				
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario,cUsuario WITH RESUME;
				END FOREACH;
			
			ELIF pEstatus <> '' THEN
			
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud)AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE estatus = pEstatus
						FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus = pEstatus
						ORDER BY numtarjetadmin										
				
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario WITH RESUME;
				END FOREACH;
			
			END IF;		
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
			END IF;	
			
		END IF;
	
		IF pOperacion = 2  THEN
		
			FOREACH 
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaTarjeta, '|')
				INTO cNumeroInicial
			
				SELECT estatus 
				INTO pEstatus
				--FROM bdiatmist:"informix".atm_tarjeta_admin
				FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
				WHERE numtarjetadmin = cNumeroInicial;
				
				IF pEstatus = 'SOL' THEN
					LET pEstatus = 'ENT';
				ELIF pEstatus = 'ENT' THEN
					LET pEstatus = 'ACT';
				END IF

				--UPDATE bdiatmist:"informix".atm_tarjeta_admin
                UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 				
				SET estatus = pEstatus
				WHERE numtarjetadmin = cNumeroInicial;
			END FOREACH;	
		
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que realiza Consulta y Actualizacion de Estatus de Tarjetas Administrativas',	
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consestatustarjeta(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    INTEGER AS id_tipo, 
			CHAR(60) AS desc_reposicion,
			CHAR(4) AS des_corta;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE cDesCorta CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET cDesCorta = '';
	LET iNoRegistros = 0;
	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consestatustarjeta.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END IF;					
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT id_tipo, descripcion, des_corta
			INTO iTipo, cDescripcion, cDesCorta
			--FROM bdiatmist:atm_tipo_estatus
			FROM bdiatmist@stag_ids1170:"informix".atm_tipo_estatus
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iTipo, UPPER(TRIM(cDescripcion)), UPPER(TRIM(cDesCorta)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 10/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta para llenado de combo de Estatus Tarjetas Administrativas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consparamsolicitartarjeta(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumTarjSolicitar CHAR(4), pFechaSolicitud DATE, pPeriodoExpTarjeta CHAR(3), pOperacion CHAR(1))							
		RETURNING CHAR(5) AS codret,
			CHAR(10) AS valor_bin, 
			CHAR(19) AS serial_final;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cBin CHAR(10);			
	DEFINE cSerialFinal CHAR(100);
	DEFINE iLote INTEGER;
	DEFINE iSerialFinal INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE index_var INTEGER;
	DEFINE iInicio INTEGER;
	DEFINE dFechaCancelada DATE;
	DEFINE cTarjetaSustituta CHAR(16);
	DEFINE cStatus CHAR(3);
	DEFINE cDescripComent CHAR(60);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cBin = '';
	LET iLote = '';
	LET cSerialFinal = '';
	LET iSerialFinal = 0;
	LET iNoRegistros = 0;
	LET index_var = 0;
	LET iInicio = 0;
	LET dFechaCancelada = '';
	LET cTarjetaSustituta = '';
	LET cStatus = 'SOL';
	LET cDescripComent = '';	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBin, cSerialFinal;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consparamsolicitartarjeta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cBin, cSerialFinal;
		END IF;	
		
		IF pOperacion = 2 THEN
			IF pNumTarjSolicitar = '' OR pFechaSolicitud = '' OR pPeriodoExpTarjeta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBin, cSerialFinal;
			END IF;
		END IF;		
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cBin, cSerialFinal;
		END IF;
		
		--OBTENER NUMERO INICIO-NUMERO FINAL
		IF pOperacion = '1' THEN
		
			--OBTENER VALOR DE CODIGO BIN
			FOREACH 
				SELECT valor
					INTO cBin
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1
				
				--OBTENER VALOR DE SERIALFINAL
				SELECT valor
					INTO cSerialFinal
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 2;
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 2;
				
				LET iNoRegistros = iNoRegistros + 1;
				
				IF iNoRegistros > 0 THEN
					LET cCodRet = '00000';
				END IF;
				
				RETURN cCodRet, TRIM(cBin), (TRIM(cBin) || TRIM(cSerialFinal)) WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cBin, cSerialFinal;
			END IF;						
		
		END IF;
		
		IF pOperacion = '2' THEN	
		
			--OBTENER VALOR DE CODIGO BIN
			SELECT valor
				   INTO cBin
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1;
			FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1;
			
			--OBTENER VALOR DE SERIALFINAL
			SELECT valor
				   INTO cSerialFinal
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 2;
			FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 2;
			
			--OBTENER VALOR DE LOTE
			SELECT valor
				   INTO iLote
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 3;
            FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 3;			
			
			LET iSerialFinal = cSerialFinal - 1;																
			
			WHILE(iInicio < pNumTarjSolicitar) LOOP
				LET iInicio = iInicio + 1;
				LET iSerialFinal = iSerialFinal + 1;
				LET cSerialFinal = TRIM(cBin) || LPAD(iSerialFinal, 10, '0');
				LET cSerialFinal = SUBSTRING(cSerialFinal FROM 1 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 5 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 9 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 13 FOR 4);
				
				--INSERT INTO bdiatmist:"informix".atm_tarjeta_admin VALUES(iLote, cSerialFinal, CURRENT, dFechaCancelada, cTarjetaSustituta, cStatus, pPeriodoExpTarjeta, cDescripComent, pUsuario, '');	
                INSERT  INTO bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin VALUES(iLote, cSerialFinal, CURRENT, dFechaCancelada, cTarjetaSustituta, cStatus, pPeriodoExpTarjeta, cDescripComent, pUsuario, '');					
				
				IF iInicio = pNumTarjSolicitar THEN
				
					LET iSerialFinal = iSerialFinal + 1;
					LET iLote = iLote + 1;
					
					--ACTUALIZA SERIAL FINAL
					--UPDATE bdiatmist:"informix".atm_param SET valor = LPAD(iSerialFinal, 10, '0') WHERE cod_param = 2;
					UPDATE bdiatmist@stag_ids1170:"informix".atm_param SET valor = LPAD(iSerialFinal, 10, '0') WHERE cod_param = 2;
					--ACTUALIZA NUMERO DE LOTE
					--UPDATE bdiatmist:"informix".atm_param SET valor = iLote WHERE cod_param = 3;
					UPDATE bdiatmist@stag_ids1170:"informix".atm_param SET valor = iLote WHERE cod_param = 3;
				
				END IF			
				
				EXIT WHEN iInicio = pNumTarjSolicitar;
			END LOOP;	
			
			RETURN cCodRet, cBin, cSerialFinal;
			
		END IF;			
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta parametros para Opcion Solicitar Tarjeta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp para insertar la fecha de cancelacion vacia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constarjetasmotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    INTEGER AS id_tipo, 
			CHAR(60) AS desc_reposicion;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipo, cDescripcion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constarjetasmotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;					
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT id_tipo, descripcion
			INTO iTipo, cDescripcion
			--FROM bdiatmist:"informix".atm_tipo_reposicion
			FROM bdiatmist@stag_ids1170:"informix".atm_tipo_reposicion
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iTipo, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTipo, cDescripcion;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Tipo de Reposicion para llenado de combo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)							
		RETURNING CHAR(5) AS codret,
			CHAR(19) AS tarjeta_sustituir,
			CHAR(19) AS tarjeta_sustituta,
			CHAR(5) AS fecha_expira;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDisponibles INTEGER;
	DEFINE cTarjetaSustituir CHAR(19);
	DEFINE cTarjetaSutituta CHAR(19);
	DEFINE cBin CHAR(10);	
	DEFINE cTotalRango CHAR(4);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	DEFINE cFechaExp CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iTotalDisponibles = 0;
	LET cTarjetaSustituir = '';
	LET cTarjetaSutituta = '';
	LET cBin = '';		
	LET cTotalRango = pTotalRango;
	LET cDe = ''; 
	LET cHasta = '';	
	LET cFechaExp = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;					
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;		
		
		--OBTENER VALOR DE CODIGO BIN
		SELECT valor
	        INTO cBin
		--FROM  bdiatmist:"informix".atm_param 
		FROM  bdiatmist@stag_ids1170:"informix".atm_param 
		WHERE cod_param = 1;
		
		LET pRangoDe = TRIM(cBin) || pRangoDe;
		LET pRangoHasta = TRIM(cBin) || pRangoHasta;
		
		LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
		LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
		
		-- VALIDACION QUE EXISTAN TARJETAS PARA REALIZAR REPOSICION	
		SELECT COUNT(*) 
			INTO iTotalDisponibles
		---FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE estatus = 'ENT';
		
		SELECT COUNT(*) 
			INTO cTotalRango
		--FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE numtarjetadmin 
		BETWEEN cDe AND cHasta	
		AND numtarjetasustituta = ''
		AND estatus <> 'ENT';
		
		IF iTotalDisponibles <  cTotalRango THEN 
			LET cCodRet = '00891';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
		
		--REALIZO SOLO LA CONSULTA A atm_tarjeta_admin
		IF pOperacion = 1  THEN
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
						INTO cTarjetaSustituir, cFechaExp
					--FROM  bdiatmist:"informix".atm_tarjeta_admin  
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND estatus IN ('SOL','ACT')
					AND numtarjetasustituta = ''
					ORDER BY numtarjetadmin											
				FOREACH cTarjetaSustituir FOR			
					SELECT numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT' 						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC														
				END FOREACH; 
			
				LET iNoRegistros = iNoRegistros + 1;
			
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;
			END FOREACH;				
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			END IF;	
		END IF;
	
		--Realiza actualizacion de Estatus 
		IF pOperacion = 2 THEN			
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
					INTO cTarjetaSustituir, cFechaExp
				--FROM  bdiatmist:"informix".atm_tarjeta_admin
                  FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin  				
				WHERE numtarjetadmin 
				BETWEEN cDe AND cHasta 
				AND estatus IN ('SOL','ACT')
				AND numtarjetasustituta = ''
				ORDER BY numtarjetadmin									
				
				FOREACH cTarjetaSustituir FOR					
					SELECT  numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT'						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC
					
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin  
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					SET fechacancelacion = CURRENT,
						numtarjetasustituta = cTarjetaSutituta,
						estatus = 'CAN',							
						descripcion_coment = pComentario
					WHERE numtarjetadmin =	cTarjetaSustituir;																	
				END FOREACH; 
				
				FOREACH 
					SELECT  numtarjetasustituta	
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin
                    FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 					
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND numtarjetasustituta IS NOT NULL
					AND numtarjetasustituta <> ''
					AND estatus = 'CAN'   
				
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
					SET  estatus = 'ACT'
					WHERE numtarjetadmin = cTarjetaSutituta
					AND numtarjetasustituta = ''
					AND estatus = 'ENT';	
				END FOREACH;									
	
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;				
			
			END FOREACH;	
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que realiza Consulta para Reposicion de Tarjetas',	
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp para realizar sustitucion de tarjetas con tarjetas con estatus ENT',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1))							
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS num_porasignar;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegPorAsignar INTEGER;
	DEFINE cStatus CHAR(3);
    DEFINE cNumeroTarjeta CHAR(3);	
	DEFINE dFecha DATE;
	DEFINE cBin CHAR(10);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegPorAsignar = 0;
	LET cBin = '';		
	LET cDe = ''; 
	LET cHasta = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion_totales.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pOperacion = 1 THEN	
		
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
           -- FROM bdiatmist:"informix".atm_tarjeta_admin;  
		     FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin;  
		
		ELIF pOperacion = 2 THEN 
		
			--OBTENER VALOR DE CODIGO BIN
			SELECT valor
			INTO cBin
			--FROM bdiatmist:"informix".atm_param 
			FROM bdiatmist@stag_ids1170:"informix".atm_param 
			WHERE cod_param = 1;
		
			LET pRangoDe = TRIM(cBin) || pRangoDe;
			LET pRangoHasta = TRIM(cBin) || pRangoHasta;
			LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
			LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
			
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			INTO iNoRegistros, iNoRegPorAsignar
			--FROM bdiatmist:"informix".atm_tarjeta_admin
			FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE numtarjetasustituta = '' AND numtarjetadmin 
			BETWEEN cDe AND cHasta; 
			
		END IF;			 				
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00000';
			LET iNoRegistros = 0;
			LET iNoRegPorAsignar = 0;
		END IF;	
		
		RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Totales de Tarjetas Administrativas',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_portanom_obtieneruta(pUsuario CHAR(8), pIdFuncion CHAR(10), pOperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(50) AS ruta_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRutaArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_obtieneruta.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		IF pOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_obtrutasportabilidad(pOperacion)
		INTO cCodRetSp, cRutaArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP ";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00044';
		END IF;
		
		RETURN cCodRet, cRutaArchivo;
	
	END;
	
END PROCEDURE;