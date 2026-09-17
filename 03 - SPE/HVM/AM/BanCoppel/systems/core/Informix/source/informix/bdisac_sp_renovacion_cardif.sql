CREATE PROCEDURE "informix".sp_renovacion_cardif(pEmpresa CHAR(3),pNumcte CHAR(20),pSucursal CHAR(4),pEjecutivo CHAR(8),
				pTramaAseguradoContratante CHAR(10240), pTramaAseguradoMigrantes CHAR(10240))
	RETURNING CHAR(5);


	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE dFechaHoy 		DATE;
	
	DEFINE cNumCertificado	CHAR(30);
	DEFINE cNombre1			CHAR(26);
	DEFINE cNombre2 		CHAR(26);
	DEFINE cApPat 			CHAR(26);
	DEFINE cApMat			CHAR(26);
	DEFINE cTipoPlan 		CHAR(1);
	DEFINE cFechaAlta 		CHAR(23);
	DEFINE cFechaVenc		CHAR(23);
	DEFINE cFechaNac		CHAR(23);
	DEFINE cParentesco		CHAR(2);
	DEFINE cTramaCont 		CHAR(10240);
	DEFINE cTramaMig		CHAR(10240);
	DEFINE cNumPoliza		CHAR(50);
	DEFINE cSexo			CHAR(1);
	DEFINE cNacionalidad	CHAR(3);
	DEFINE cCiudad			CHAR(100);
	DEFINE cCelular			CHAR(13);
	DEFINE cCorreo			CHAR(100);
	
	DEFINE iInicio			INTEGER;
	DEFINE iFin				INTEGER;
	DEFINE iSecuencia		INTEGER;
	
	LET cNumCertificado	= '';
	LET cNombre1		= '';
	LET cNombre2 		= '';
	LET cApPat 			= '';
	LET cApMat			= '';
	LET cTipoPlan 		= '';
	LET cFechaAlta 		= '';
	LET cFechaVenc		= '';
	LET cFechaNac		= '';
	LET cParentesco		= '';
	LET cTramaCont		= pTramaAseguradoContratante;
	LET cTramaMig		= pTramaAseguradoMigrantes;
	LET cNumPoliza 		= '';
	LET cParentesco		= '';
	LET cSexo			= '';
	LET cNacionalidad	= '';
	LET cCiudad			= '';
	LET cCelular		= '';
	LET cCorreo			= '';
	LET iInicio			= 1;
	LET iFin			= length(cTramaCont);
	LET iSecuencia		= 0;
	
	LET iSqlErr			= 0;
	LET cCodRet			= '00000';
	LET dFechaHoy 		= '';
	
	--SET DEBUG FILE TO '/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_renovacion_cardif.out';
	--TRACE ON;
	
BEGIN
		
	ON EXCEPTION
	SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	IF 	NVL(pEmpresa,'')='' OR pEmpresa IS NULL 
		OR NVL(pNumcte,'')='' OR pNumcte IS NULL 
		OR NVL(pSucursal,'')='' OR pSucursal IS NULL 
		OR NVL(pEjecutivo,'')='' OR pEjecutivo IS NULL 
		OR NVL(pTramaAseguradoContratante,'')='' OR pTramaAseguradoContratante IS NULL 
		OR NVL(pTramaAseguradoMigrantes,'')='' OR pTramaAseguradoMigrantes IS NULL 
		THEN
		LET cCodRet= '00001';
		RETURN cCodRet;
	END IF
		
		SELECT fecha_hoy INTO dFechaHoy
		FROM bdisac:"informix".sac_fechas 
		WHERE empresa = pEmpresa;
		
	--Actualiza correo y numero de telefono del CONTRATANTE	
	--LET cCelular = substring(cTramaCont from 1 for charindex ('|', substring(cTramaCont from 1 for iFin))-1);
	--LET iInicio = iInicio + charindex ('|', substring(cTramaCont from iInicio for iFin));
		
	--LET cCorreo = substring(cTramaCont from iInicio for iFin);

	--UPDATE bdisac:"informix".sac_cardif_contratante
	--SET celular = cCelular, correo = cCorreo
	--WHERE numcte = pNumcte;
	
	--Ciclo para insertar y actualizar MIGRANTES
	LET iFin = length(cTramaMig);
	LET iInicio	= 1;
	
	WHILE iInicio < iFin
		LET iInicio	= 1;
		LET iFin = length(cTramaMig);
		
		LET cNombre1 = substring(cTramaMig from (iInicio)for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));

		LET cNombre2 = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cApPat = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cApMat = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
		
		LET cFechaNac = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));	
		
		LET cNumCertificado = substring(cTramaMig from (iInicio)for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cFechaAlta = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cFechaVenc = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
		
		LET cTipoPlan = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
		
		LET iInicio = iInicio + charindex ('>>', substring(cTramaMig from iInicio for iFin));
		LET cTramaMig = substring(cTramaMig from (charindex('>>', cTramaMig) + 2) for iFin);

		LET iSecuencia = (SELECT MAX(secuencia) + 1 FROM bdisac:"informix".sac_cardif_migrante WHERE numcte = pNumcte);
		
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 1;
		END IF;

		SELECT num_poliza,parentesco,fechaNac,sexo,nacionalidad,ciudad
		INTO cNumPoliza,cParentesco,cFechaNac,cSexo,cNacionalidad,cCiudad
		FROM bdisac:"informix".sac_cardif_migrante
		WHERE empresa= pEmpresa AND
			  numcte = pNumcte AND
			  nombre1 = cNombre1 AND
			  nombre2 = cNombre2 AND
			  apell_paterno = cApPat AND 
			  apell_materno = cApMat AND 
			  num_certificado = cNumCertificado AND
			  estatus='2';
		--Actualiza estatus de 2(Candidato) a 3(Renovado)
		IF NVL(cNumPoliza,'') <> '' THEN
			UPDATE bdisac:"informix".sac_cardif_migrante
			SET estatus = '3'
			WHERE numcte = pNumcte AND 
				  nombre1 = cNombre1 AND
				  nombre2 = cNombre2 AND
				  apell_paterno = cApPat AND 
				  apell_materno = cApMat AND 
				  num_certificado = cNumCertificado 
				  AND estatus = '2';
			--Inserta nuevo registro con estatus 1(Activo)
			INSERT INTO bdisac:"informix".sac_cardif_migrante(empresa,sucursal,numcte,secuencia,num_certificado,num_poliza,estatus,ejecutivo,nombre1,nombre2,apell_paterno,apell_materno,tipo_plan,fecha_alta,fecha_vencimiento,parentesco,fecha_insert,fechaNac,sexo,nacionalidad,ciudad)
			VALUES(pEmpresa,pSucursal,pNumcte,iSecuencia,'','','1',pEjecutivo,cNombre1,cNombre2,cApPat,cApMat,cTipoPlan,cFechaAlta,cFechaVenc, cParentesco,dFechaHoy,cFechaNac,cSexo,cNacionalidad,cCiudad);
		END IF;
	END WHILE;
	RETURN cCodRet;

END;
END PROCEDURE;