CREATE PROCEDURE "informix".sp_consultactecoincidencia(pNumCte CHAR(20),pEmpresa CHAR (3),pTpDireccion INTEGER)
	RETURNING CHAR(5)  AS CodRetorno,
			  CHAR(40) AS Nombre1,
			  CHAR(40) AS Nombre2,
			  CHAR(40) AS ApPaterno,
			  CHAR(40) AS ApMaterno,
			  CHAR(13) AS RFC,
			  CHAR(10) AS FechaNaci,
			  CHAR(1)  AS Sexo,
			  CHAR(20) AS TipoPersona,
			  CHAR(10) AS FechaAlta,
			  CHAR(4)  AS Sucursal,
			  CHAR(30) AS NomCalle,
			  CHAR(10) AS NumExt,
			  CHAR(10) AS NumInt,
			  CHAR(6)  AS Depto,
			  CHAR(30) AS NomColonia,
			  CHAR(30) AS NomMunicipio,
			  CHAR(30) AS NomCiudad,
			  CHAR(30) AS NomEstado,
			  CHAR(10) AS TelParticular,
			  CHAR(10) AS TelCelular,
			  CHAR(10) AS TelTrabajo,
			  CHAR(5)  AS Extencion;	   
	
--Definicion de Variables
DEFINE iSqlErr 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cNombre1 			CHAR(40);
DEFINE cNombre2 			CHAR(40);
DEFINE cApPaterno 			CHAR(40);
DEFINE cApMaterno 			CHAR(40);
DEFINE cRFC 				CHAR(13);
DEFINE cFechNacimiento 		CHAR(10);
DEFINE cSexo 				CHAR(1);
DEFINE cTipoPersona 		CHAR(2);
DEFINE cDescripcionPersona 	CHAR(20);
DEFINE cFechaAlta 			CHAR(10);
DEFINE cSucursal 			CHAR(4);
DEFINE iCalle 				INTEGER;
DEFINE cNumeroExt 			CHAR(10);
DEFINE cNumeroInt 			CHAR(10);
DEFINE cDepto 				CHAR(6);
DEFINE iColonia 			INTEGER;
DEFINE cNomColonia 			CHAR(30);
DEFINE cMunicipio 			CHAR(6);
DEFINE cNomMunicipio 		CHAR(30);
DEFINE cEstado 				CHAR(6);
DEFINE cNomEstado 			CHAR(30);
DEFINE cCiudad 				CHAR(6);
DEFINE cNomCiudad 			CHAR(30);
DEFINE cTelParticular 		CHAR(10);
DEFINE cTelCelular 			CHAR(10);
DEFINE cTelTrabajo 			CHAR(10);
DEFINE cTelTipoParticular 	CHAR(1);
DEFINE cTelTipoCelular 		CHAR(1);
DEFINE cTelTipoTrabajo 		CHAR(1);
DEFINE cExtencion 			CHAR(5);
DEFINE cEsFisica 			CHAR(1);
DEFINE cNomCalle 			CHAR(30);
DEFINE cDescTpPersona 		CHAR(20);
DEFINE cCiudadCoppel		CHAR(6);

--Inicializacion de Variables
LET iSqlErr 			= 0;
LET cCodRet 			= '000000';
LET cNombre1 			=	'';
LET cNombre2 			= '';
LET cApPaterno 			= '';
LET cApMaterno 			= '';
LET cRFC 				= '';
LET cFechNacimiento 	= '';
LET cSexo 				= '';
LET cTipoPersona 		= '';
LET cDescripcionPersona = '';
LET cFechaAlta 			= '';
LET cSucursal 			= '';
LET iCalle 				= 0;
LET cNumeroExt 			= '';
LET cNumeroInt 			= '';
LET cDepto 				= '';
LET iColonia 			= 0;
LET cNomColonia 		= '';
LET cMunicipio 			= '';
LET cNomMunicipio 		= '';
LET cEstado 			= '';
LET cNomEstado 			= '';
LET cCiudad 			= '';
LET cNomCiudad 			= '';
LET cTelParticular 		= '';
LET cTelCelular 		= '';
LET cTelTrabajo 		= '';
LET cTelTipoParticular 	= '';
LET cTelTipoCelular 	= '';
LET cTelTipoTrabajo 	= '';
LET cExtencion 			= '';
LET cEsFisica 			= '';
LET cNomCalle 			= '';
LET cDescTpPersona 		= '';
LET cCiudadCoppel 		= '';

--SET DEBUG FILE TO '/tmp/masv/sp_consultactecoincidencia.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,
					cDescTpPersona,cFechaAlta,cSucursal,NVL(cNomCalle,''),NVL(cNumeroExt,''),NVL(cNumeroInt,''),NVL(cDepto,''),
					NVL(cNomColonia,''),NVL(cNomMunicipio,''),NVL(cNomCiudad,''),NVL(cNomEstado,''),
					NVL(cTelParticular,''),NVL(cTelCelular,''),NVL(cTelTrabajo,''),NVL(cExtencion,'');
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (NVL(pNumCte,'') <> '' OR  pNumCte IS NOT NULL ) OR (NVL(pEmpresa,'') <> '' OR  pEmpresa IS NOT NULL ) OR (NVL(pTpDireccion,'') <> '' OR pTpDireccion IS NOT NULL)THEN 
		--Obtenemos los datos del cliente 
		SELECT c.nombre1,c.nombre2,c.apell_paterno ,c.apell_materno ,c.rfc ,c.fecha_alta,
		       f.fecha_nac,f.sexo,c.sucursal ,c.tpo_persona
		INTO cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechaAlta,
		     cFechNacimiento,cSexo,cSucursal,cTipoPersona
		FROM  bdinteg:"informix".si_cliente c,
		      bdinteg:"informix".si_ctepf f
		WHERE c.numcte =  pNumCte
		AND c.empresa =  pEmpresa
		AND c.numcte = f.numcte;
		
		--Obtenemos la direccion del cliete 
		
		IF cTipoPersona = '' OR cTipoPersona IS NULL THEN 
			LET cCodRet = '00002'; --Tipo de persona es vacio
			RETURN cCodRet, '','','','','','','',
					'','','',cNomCalle,cNumeroExt,cNumeroInt,cDepto,
					cNomColonia,cNomMunicipio,cNomCiudad,cNomEstado,cTelParticular,cTelCelular,
					cTelTrabajo,cExtencion; 
		ELSE 
		
			SELECT es_fisica,descripcion 
			INTO cEsFisica, cDescTpPersona
			FROM bdinteg:"informix".si_tipper
			WHERE tpo_persona = cTipoPersona;

			IF cEsFisica <> "S" THEN
				LET cNombre1 = " ";
				LET cNombre2 = " ";
				LET cApPaterno = " ";
				LET cApMaterno = " ";
			END IF;	
		
			SELECT FIRST 1 {+INDEX(bdinteg:"informix".si_direcciones_actual idx_diract_ctetpo)} dir.numerocalle, dir.numeroextcalle,dir.numerointcalle,dir.departamento,
			       dir.numerocolonia,dir.municipio, dir.ciudad, dir.estado,tel1.tipo_tel, tel1.telefono,
			       tel2.tipo_tel, tel2.telefono,tel3.tipo_tel, tel3.telefono,tel3.extension
			INTO iCalle,cNumeroExt,cNumeroInt,cDepto,iColonia,cMunicipio,cCiudad,cEstado,
			     cTelTipoParticular,cTelParticular,cTelTipoCelular,cTelCelular,cTelTipoTrabajo,cTelTrabajo,cExtencion
			FROM bdinteg:"informix".si_direcciones_actual dir			
			LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
			LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
			LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
			WHERE dir.numcte = pNumCte
			AND dir.tipo_dir = pTpDireccion 
			AND dir.secuencia = (SELECT MAX(dir.secuencia) FROM bdinteg:"informix".si_direcciones_actual dir 
			WHERE dir.numcte = pNumCte
			AND dir.tipo_dir = pTpDireccion);
			
			SELECT TRIM(nombre) 
            INTO cNomEstado
			FROM bdinteg:"informix".si_estados
			WHERE estado = cEstado ;
			
			IF cNomEstado IS NULL THEN 
				LET cNomEstado = '';
			END IF;
			
			SELECT TRIM(nombre),ciudad_coppel
			INTO cNomCiudad,cCiudadCoppel
			FROM bdinteg:"informix".si_ciudades
			WHERE estado = cEstado 
			AND ciudad = cCiudad;
			
			IF cNomCiudad IS NULL THEN 
				LET cNomCiudad = '';
			END IF;

			SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} TRIM(nombrezona) 
			INTO cNomColonia 
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = cCiudadCoppel 
			AND numerocolonia = iColonia LIMIT 1;
			
			IF cNomColonia IS NULL THEN 
				LET cNomColonia = '';
			END IF;
			IF cTelCelular IS NULL THEN 
				LET cTelCelular = '';
			END IF;
			IF cTelParticular IS NULL THEN 
				LET cTelParticular = '';
			END IF;
			IF cTelTrabajo IS NULL THEN 
				LET cTelTrabajo = '';
			END IF;			
			IF cExtencion IS NULL THEN 
				LET cExtencion = '';
			END IF;
			
			SELECT TRIM(nombrecalle) 
			INTO cNomCalle 
			FROM bdinteg:"informix".si_catcalles
			WHERE numerocalle = iCalle;		

			IF TRIM(cMunicipio) ='00000' THEN     
				LET cMunicipio  = "";     

				SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} TRIM(municipiozona) 
				INTO cNomMunicipio 
				FROM bdinteg:"informix".si_catzonas
				WHERE numerociudad = cCiudadCoppel 
				AND numerocolonia  = iColonia LIMIT 1;
				
				IF cNomMunicipio IS NULL THEN 
					LET cNomMunicipio = '';
				END IF;
			ELSE
				LET cNomMunicipio = cNomCiudad;     
			END IF; 
		END IF;		
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,
		   cDescTpPersona,cFechaAlta,cSucursal,NVL(cNomCalle,''),NVL(cNumeroExt,''),NVL(cNumeroInt,''),NVL(cDepto,''),
		   cNomColonia,cNomMunicipio,cNomCiudad,cNomEstado,cTelParticular,cTelCelular,
		   cTelTrabajo,cExtencion;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los datos generales y direcciones del cte coincidencia ',
'AUTOR : Eduardo Lopez Cuevas ',
'FECHA : 17-09-2013',
'VERSION: 20130917.1530',
'BD: bdinteg',
'DESCRIPCION: Se modifica procedimiento almacenado para retornar la DelegaciÃÂ³n/Municipio ',
'AUTOR : Felipe Urias ',
'FECHA : 09-12-2013',
'VERSION: 20131209.1530',
'BD: bdinteg',
'DESCRIPCION: Se modifica procedimiento almacenado para obtener la ultima secuencia de los domicilios ',
'AUTOR : Johnattan Esquivel SÃ¡nchez ',
'FECHA : 01-06-2020',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_buscar_asegurado_cardif(sNumcte CHAR(20), sApellPat VARCHAR(26), sApellMat VARCHAR(26), sNombre1 VARCHAR(26), sNombre2 VARCHAR(26),  dFechaNac DATE, sNumCertif VARCHAR(30), sOpcion SMALLINT, iSecuencia INTEGER)
RETURNING CHAR(5),
		CHAR(20),
		CHAR(30),
		CHAR(50),
		CHAR(26),
		CHAR(26),
		CHAR(26),
		CHAR(26),
		CHAR(10),
		CHAR(13);

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE r_sNumcte VARCHAR(20);
DEFINE r_sNumCertif VARCHAR(30);
DEFINE r_sPoliza VARCHAR(50);
DEFINE r_sNombre1 VARCHAR(26);
DEFINE r_sNombre2 VARCHAR(26);
DEFINE r_sApellPat VARCHAR(26);
DEFINE r_sApellMat VARCHAR(26);
DEFINE r_dFechaNac VARCHAR(10);
DEFINE r_sRFCCodRet VARCHAR(5);
DEFINE r_sRFCMensaje VARCHAR(100);
DEFINE r_sRFC VARCHAR(10);

LET sql_err = 0;
LET cCodRet = "00000";
LET r_sNumcte = "";
LET r_sNumCertif = "";
LET r_sPoliza = "";
LET r_sNombre1  = "";
LET r_sNombre2  = "";
LET r_sApellPat = "";
LET r_sApellMat = "";
LET r_dFechaNac = "";
LET r_sRFCCodRet = "";
LET r_sRFCMensaje = "";
LET r_sRFC = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
		END IF;
	END EXCEPTION;
	
	
--SET DEBUG FILE TO "/tmp/respaldosbd/sp_BuscarAseguradoCardiff.out";
--TRACE ON;
	
	IF sOpcion = 1 OR sOpcion = 2 Then
		IF NVL(sNombre1, '') <> '' AND TRIM(sNombre1) <> '' AND NVL(sApellPat, '') <> '' AND TRIM(sApellPat) <> '' AND dFechaNac IS NOT NULL THEN
			LET sNombre1 = TRIM(UPPER(sNombre1)||'*');
			LET sApellPat = TRIM(UPPER(sApellPat)||'*');			
			LET sNombre2 = TRIM(UPPER(sNombre2)||'*');
			LET sApellMat = TRIM(UPPER(sApellMat)||'*');
			
			IF sOpcion = 1 Then
				IF TRIM(sNumCertif) = "" OR TRIM(sNumCertif) = "0" THEN
					FOREACH
						SELECT SKIP iSecuencia LIMIT 21
							scte.numcte, scont.num_certificado, scont.num_poliza,
							scte.nombre1, scte.nombre2,
							scte.apell_paterno, scte.apell_materno,
							sctepf.fecha_nac, scte.rfc
						  INTO
							r_sNumcte, r_sNumCertif, r_sPoliza,
							r_sNombre1, r_sNombre2,
							r_sApellPat, r_sApellMat,
							r_dFechaNac, r_sRFC
						FROM "informix".si_cliente scte
						INNER JOIN bdisac: "informix".sac_cardif_contratante scont
							ON scte.numcte = scont.numcte
						INNER JOIN "informix".si_ctepf sctepf
							ON sctepf.numcte = scte.numcte
						WHERE scte.apell_paterno MATCHES sApellPat AND
						scte.apell_materno MATCHES sApellMat AND
						scte.nombre1 MATCHES sNombre1 AND
						scte.nombre2 MATCHES sNombre2 AND
						sctepf.fecha_nac = dFechaNac
						ORDER BY apell_paterno, apell_materno, nombre1, nombre2
						
						RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
					END FOREACH;
				ELSE
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, scont.num_certificado, scont.num_poliza,
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, r_sNumCertif, r_sPoliza,
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN bdisac: "informix".sac_cardif_contratante scont
						ON scte.numcte = scont.numcte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.apell_paterno MATCHES sApellPat AND
					scte.apell_materno MATCHES sApellMat AND
					scte.nombre1 MATCHES sNombre1 AND
					scte.nombre2 MATCHES sNombre2 AND
					scont.num_certificado = sNumCertif AND
					sctepf.fecha_nac = dFechaNac;
					
					IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
						RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
					ELSE
						LET r_sNumcte = NVL(r_sNumcte, '');
						LET r_sNumCertif = NVL(r_sNumCertif, '');
						LET r_sPoliza = NVL(r_sPoliza, '');
						LET r_sNombre1 = NVL(r_sNombre1, '');
						LET r_sNombre2 = NVL(r_sNombre2, '');
						LET r_sApellPat = NVL(r_sApellPat, '');
						LET r_sApellMat = NVL(r_sApellMat, '');
						LET r_dFechaNac = NVL(r_dFechaNac, '');
						LET r_sRFC = NVL(r_sRFC, '');
						LET cCodRet = "00002";
					END IF;
					
				END IF
			ELSE
				FOREACH					
					SELECT SKIP iSecuencia LIMIT 21
						numcte, num_certificado, nombre1, num_poliza,
						nombre2, apell_paterno, apell_materno, fechanac
					  INTO 
						r_sNumcte, r_sNumCertif, r_sNombre1, r_sPoliza,
						r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac
					FROM bdisac: "informix".sac_cardif_migrante
					WHERE apell_paterno MATCHES sApellPat AND
					apell_materno MATCHES sApellMat AND
					nombre1 MATCHES sNombre1 AND
					nombre2 MATCHES sNombre2 AND
					fechanac = dFechaNac AND
					estatus IN (1,2)
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					EXECUTE PROCEDURE "informix".sp_calcularfc('001',r_sApellPat, r_sApellMat, r_sNombre1, r_sNombre2, r_dFechaNac) INTO r_sRFCCodRet, r_sRFCMensaje, r_sRFC;
			
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
			END IF;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			END IF;
		ELSE
			LET cCodRet = "00001";
		END IF;
		
	ELIF sOpcion = 3 OR sOpcion = 4 THEN
		IF TRIM(sNumcte) <> "" AND sNumcte IS NOT NULL THEN
			If sOpcion = 3 Then
				SELECT
					scte.numcte, scte.nombre1, scte.nombre2, scte.apell_paterno, scont.num_poliza,
					scte.apell_materno, sctepf.fecha_nac, scont.num_certificado,
					scte.rfc
				INTO
					r_sNumcte, r_sNombre1, r_sNombre2, r_sApellPat, r_sPoliza,
					r_sApellMat, r_dFechaNac, r_sNumCertif,
					r_sRFC
				FROM "informix".si_cliente scte
				INNER JOIN bdisac: "informix".sac_cardif_contratante scont
					ON scte.numcte = scont.numcte
				INNER JOIN "informix".si_ctepf sctepf
					ON sctepf.numcte = scte.numcte
				WHERE scte.numcte = sNumcte;
				
				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
				ELSE
					LET r_sNumcte = NVL(r_sNumcte, '');
					LET r_sNumCertif = NVL(r_sNumCertif, '');
					LET r_sPoliza = NVL(r_sPoliza, '');
					LET r_sNombre1 = NVL(r_sNombre1, '');
					LET r_sNombre2 = NVL(r_sNombre2, '');
					LET r_sApellPat = NVL(r_sApellPat, '');
					LET r_sApellMat = NVL(r_sApellMat, '');
					LET r_dFechaNac = NVL(r_dFechaNac, '');
					LET r_sRFC = NVL(r_sRFC, '');
					LET cCodRet = "00002";				
				END IF;
			ELSE
				SELECT 
					numcte, num_certificado, nombre1, num_poliza,
					nombre2, apell_paterno, apell_materno, fechanac
				  INTO 
					r_sNumcte, r_sNumCertif, r_sNombre1, r_sPoliza,
					r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac
				FROM bdisac: "informix".sac_cardif_migrante
				WHERE num_certificado = sNumcte;
				
				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
					EXECUTE PROCEDURE "informix".sp_calcularfc('001',r_sApellPat, r_sApellMat, r_sNombre1, r_sNombre2, r_dFechaNac) INTO r_sRFCCodRet, r_sRFCMensaje, r_sRFC;
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
				ELSE
					LET r_sNumcte = NVL(r_sNumcte, '');
					LET r_sNumCertif = NVL(r_sNumCertif, '');
					LET r_sPoliza = NVL(r_sPoliza, '');
					LET r_sNombre1 = NVL(r_sNombre1, '');
					LET r_sNombre2 = NVL(r_sNombre2, '');
					LET r_sApellPat = NVL(r_sApellPat, '');
					LET r_sApellMat = NVL(r_sApellMat, '');
					LET r_dFechaNac = NVL(r_dFechaNac, '');
					LET r_sRFC = NVL(r_sRFC, '');
					LET cCodRet = "00002";				
				END IF;
			END IF
		ELSE
			LET cCodRet = "00001";
		END IF;
	ELIF sOpcion = 5 Then
		IF NVL(sNombre1, '') <> '' AND TRIM(sNombre1) <> '' AND NVL(sApellPat, '') <> '' AND TRIM(sApellPat) <> '' AND dFechaNac IS NOT NULL THEN
			LET sNombre1 = TRIM(UPPER(sNombre1)||'*');
			LET sApellPat = TRIM(UPPER(sApellPat)||'*');			
			LET sNombre2 = TRIM(UPPER(sNombre2)||'*');
			LET sApellMat = TRIM(UPPER(sApellMat)||'*');
			
			IF TRIM(sNumcte) = "0" OR TRIM(sNumcte) = "" OR sNumcte IS NULL THEN
				FOREACH
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, 
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, 
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.apell_paterno MATCHES sApellPat AND
					scte.apell_materno MATCHES sApellMat AND
					scte.nombre1 MATCHES sNombre1 AND
					scte.nombre2 MATCHES sNombre2 AND
					sctepf.fecha_nac = dFechaNac
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
					
			else
				FOREACH
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, 
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, 
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.numcte = sNumcte 
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
			end if
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			END IF;
		ELSE
			LET cCodRet = "00001";
		END IF;
	ELSE
		LET cCodRet = "00003";
	END IF;
	
	IF cCodRet <> "00000" THEN
		RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 577',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdinteg',
'Fecha: 2019-05-23',
'DescripciÃ³n: Se genera Procedimiento Almacenado para realizar la bÃºsqueda de los clientes asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez',
'_______________________________________________________________________________________________________',
'Folio: 664',
'Autor: Alexi HernÃ¡ndez',
'BD: bdinteg',
'Fecha: 2020-04-27',
'DescripciÃ³n: Se genera la Procedimiento Almacenado la opcion 5 para la consulta de clientes titulares asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez';

CREATE PROCEDURE  "informix".sp_cancelaserviciobasico_bpi()
  RETURNING    CHAR(5);
	
	
------------------------------------
--Cancela el servicio de Banca por Internet para el proceso de cambio de servicio y guarda registros en la si_cambiostct los cambios de status
--Elaboro : Gabriela Aguilar
--FECHA : 13/Julio/2020
--Ver.  : 1.0
--BD    : bdinteg
------------------------------------
 	
  	
    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE cod_ret char(5);
	DEFINE pnumcte      CHAR(10);
	DEFINE pid_status  SMALLINT;
	DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
DEFINE vcuantos1 INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;  
	LET pnumcte = '';
	LET pid_status = 0;
	LET cod_ret = "00000";
LET vcontador = -1;
LET vcuantos = 0;
LET vcomienza   = -1;	
LET vregistros = 1000;
 
 --SET DEBUG FILE TO "/informix/gaby/sp_cancelaserviciobasico_bpi.out";
  --TRACE ON;


	Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

BEGIN

    

    	
	FOREACH WITH HOLD	
			
			Select numcte, id_status
			into pnumcte, pid_status
			from bdinteg:si_bpiusuarios  where  id_status not in ('30','99') and servicio='1'
			
		
			IF vcomienza = -1 THEN
				BEGIN WORK;
				LET vcontador = 1;
				LET vcomienza = 0;
			END IF;
		

       
				UPDATE 
				bdinteg:si_bpiusuarios 
				SET id_status = '99', servicio='2', f_status = current 
				WHERE numcte = pnumcte and id_status=pid_status ;
			

        
			IF (vcontador = vregistros) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;
			ELSE
				LET vcontador = vcontador + 1 ;						
			END IF;	

        CONTINUE FOREACH;			

				
	END FOREACH;

		
		IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		
	
   

    RETURN cod_ret;

END
END PROCEDURE;