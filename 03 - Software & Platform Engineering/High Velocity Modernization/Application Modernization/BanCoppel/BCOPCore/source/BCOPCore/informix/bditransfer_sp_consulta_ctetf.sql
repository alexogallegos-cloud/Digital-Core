CREATE PROCEDURE "informix".sp_consulta_ctetf(pEmpresa CHAR(3), pNumTelefono CHAR(20), pNumCta CHAR(20), pNumTarjeta CHAR(16), pNumCte CHAR(20))

	--DATOS A REGRESAR
	RETURNING
	CHAR(6)	  AS  CodRet,
	CHAR(60)  AS  Mensaje,
	CHAR(104) AS  NombreCte,
	CHAR(20)  AS  NumCteTf,
	CHAR(20)  AS  NumCteBco,
	CHAR(20)  AS  NumCtaTf,
	CHAR(16)  AS  NumTarjeta,
	CHAR(13)  AS  NumTelefono,
	CHAR(50)  AS  Identificacion,
	CHAR(20)  AS  NumIdentificacion,
	CHAR(100) AS  Correo,
	DATE	  AS  FechaNac, 
	DATE	  AS  FechaAlta, 
	CHAR(13)  AS  Rfc,
	CHAR(100) AS  Estado,
	CHAR(50)  AS  Municipio,
	CHAR(100) AS  Colonia,
	CHAR(100) AS  Calle,
	CHAR(15)  AS  NumExt,
	CHAR(15)  AS  NumInt,
	CHAR(15)  AS  NumDepto,
	CHAR(5)   AS  CodPostal,
	CHAR(5)   AS  MunicipioSi,
	CHAR(40)  AS  EntreCalles,
	CHAR(1)	  AS  StatusCta;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	DEFINE cNombreCte			CHAR(104);
	DEFINE cNumCteTf			CHAR(20);
	DEFINE cNumCteBco			CHAR(20);
	DEFINE cNumCtaTf			CHAR(20);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE cNumTelefono			CHAR(13);
	DEFINE cIdentificacion		CHAR(50);
	DEFINE cNumIdentificacion	CHAR(20);
	DEFINE cCorreo				CHAR(100);
	DEFINE dFechaNac			DATE;
	DEFINE dFechaAlta			DATE;
	DEFINE cRfc					CHAR(13);
	DEFINE cEstado				CHAR(100);
	DEFINE cMunicipio			CHAR(50);
	DEFINE cColonia				CHAR(100);
	DEFINE cCalle				CHAR(100);
	DEFINE cNumExt				CHAR(15);
	DEFINE cNumInt				CHAR(15);
	DEFINE cNumDepto			CHAR(15);
	DEFINE cCodPostal			CHAR(5);
	DEFINE cMunicipioSi			CHAR(5);
	DEFINE cEntreCalles			CHAR(40);
	DEFINE cStatusCta			CHAR(1);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'PROCESO EJECUTADO EXITOSAMENTE';
	LET cNombreCte			= '';
	LET cNumCteTf			= '';
	LET cNumCteBco			= '';
	LET cNumCtaTf			= '';
	LET cNumTarjeta			= '';
	LET cNumTelefono		= '';
	LET cIdentificacion		= '';
	LET cNumIdentificacion	= '';
	LET cCorreo				= '';
	LET dFechaNac			= DATE(1);
	LET dFechaAlta			= DATE(1);
	LET cRfc				= '';
	LET cEstado				= '';
	LET cMunicipio			= '';
	LET cColonia			= '';
	LET cCalle				= '';
	LET cNumExt				= '';
	LET cNumInt				= '';
	LET cNumDepto			= '';
	LET cCodPostal			= '';
	LET cMunicipioSi		= '';
	LET cEntreCalles		= '';
	LET cStatusCta			= '';
	
	--SET DEBUG FILE TO '/respaldosbd/CarlosAguirre/sp_consulta_ctetf.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
				RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
					cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
					cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR  pEmpresa <> '' AND NVL(pNumTelefono,'') = '' AND NVL(pNumCta,'') = '' AND NVL(pNumTarjeta,'') = '' 
			AND NVL(pNumCte,'') = '' THEN 
		
			LET cCodRet = '000001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
				cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
				cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta;
		END IF;
		
		--SE VALIDA CUAL PARAMETRO TRAE DATO PARA EJECUTAR EL SELECT CORRESPONDIENTE.
		IF pEmpresa <> '' AND pNumTelefono <>'' AND  NVL(pNumCta,'') = '' AND  NVL(pNumTarjeta,'') = '' AND  NVL(pNumCte,'') = '' THEN 
		
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, 
				--dir.municipio,
				sid.municipio,
				sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.telefono = TRIM(pNumTelefono)
				AND mae.status_cta=1;
	
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') ='' AND pNumCta <> '' AND  NVL(pNumTarjeta,'') = '' AND  NVL(pNumCte,'') = '' THEN 
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.cuenta_tf = TRIM(pNumCta)
				AND mae.status_cta=1;
		
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') ='' AND  NVL(pNumCta,'') = '' AND pNumTarjeta <> '' AND  NVL(pNumCte,'') = '' THEN 
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
				LEFT OUTER JOIN bdicheq:'informix'.sc_tarjeta tar on(mae.numcte=tar.numcte)
			WHERE mae.empresa = pEmpresa 
				AND tar.num_tarjeta = TRIM(pNumTarjeta)
				AND mae.status_cta=1;
			
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') = '' AND  NVL(pNumCta,'') = '' AND  NVL(pNumTarjeta,'') = '' AND pNumCte <> '' THEN
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.numcte_tf = TRIM(pNumCte)
				AND mae.status_cta=1;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
			cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
			cNumInt,cNumDepto,LPAD(TRIM(cCodPostal),5,'0'),cMunicipioSi,cEntreCalles,cStatusCta;
		
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Realiza una consulta para obtener datos generales del cliente',
'FECHA: 10/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER',
'-----------------------------------------------------------------------------',
'AUTOR: 95337997 - Carlos Aguirre Vega',
'FOLIO: 1440',
'DESCRIPCION: Se le agrega a las consultas "status_cta" para obtener el status de la cuenta transfer.',
'FECHA: 06/08/2014',
'SUSTENTO: Se atienden las peticiones del archivo Evidencias y defectos_v1.xlsx',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_registra_transadmin(pTipo CHAR(1),pNumCteTf CHAR(20),pFolio CHAR(12),pMpsTransactionId CHAR(12),pEjecutivo CHAR(8))
	RETURNING CHAR(5)  AS CodRet;

DEFINE cCodRet  	 CHAR(5);
DEFINE iSqlErr  	 INTEGER;

LET cCodRet  	  = '00000';
LET iSqlErr  	  = 0;
			  
--SET DEBUG FILE TO '/informix/cristo/sp_bit_actualizacte.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF NVL(pNumCteTf ,'') <> '' THEN
	
		INSERT INTO "informix".tf_bitacora_transadmin(numcte_tf,folio,mpstransactionid,tipo,fecha_insert,ejecutivo) 
		VALUES (pNumCteTf,pFolio,pMpsTransactionId,pTipo,CURRENT,pEjecutivo);

	END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE;