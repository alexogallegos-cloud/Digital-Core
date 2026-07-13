CREATE PROCEDURE "informix".sp_consultacomplementodatos(cNumCteContratante CHAR(20))
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

CREATE PROCEDURE "informix".sp_alta_cardif(pEmpresa CHAR(3),pNumCte CHAR(20),pSucursal CHAR(4),pEjecutivo CHAR(8),pTramaAseguradoContratante CHAR(10240), pTramaAseguradoMigrantes CHAR(10240))	
	RETURNING CHAR(5);

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cCelular	CHAR(13);
	DEFINE cCorreo	CHAR(100);
	
	--Variables Para el Array
	DEFINE cNombre1		CHAR(26);
	DEFINE cNombre2 	CHAR(26);
	DEFINE cApPat 		CHAR(26);
	DEFINE cApMat		CHAR(26);
	DEFINE cTipoPlan 	CHAR(1);
	DEFINE cFechaAlta 	CHAR(23);
	DEFINE cFechaVenc	CHAR(23);
	DEFINE cFechaNac	CHAR(23);
	DEFINE cParentesco	CHAR(2);
	DEFINE cPolizaPrima CHAR(20);
	DEFINE cTramaCont 	CHAR(10240);
	DEFINE cTramaMig	CHAR(10240);
	DEFINE cTramaMigaux	CHAR(10240);
	DEFINE iInicio		INTEGER;
	DEFINE iFin			INTEGER;
	DEFINE iSecuencia	INTEGER;
	DEFINE cContador	INTEGER;
	DEFINE iIniContra	INTEGER;
		
	LET cCelular		='';
	LET cCorreo			='';
	LET cNombre1		='';
	LET cNombre2 		='';
	LET cApPat 			='';
	LET cApMat			='';
	LET cTipoPlan 		='';
	LET cFechaAlta 		='';
	LET cFechaVenc		='';
	LET cFechaNac		='';
	LET cParentesco		='';
	LET cPolizaPrima    ='';
	LET cTramaCont		=pTramaAseguradoContratante;
	LET cTramaMig		=pTramaAseguradoMigrantes;
	LET iInicio			=1;
	LET iFin			=length(cTramaCont);
	LET iSecuencia		= 0;
	LET cContador		=0;
	LET iSqlErr = 0;
	LET cCodRet ='00000';
	LET iIniContra = 0;
	
	--SET DEBUG FILE TO '/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_alta_cardif.out';
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
	
	IF NVL(pEmpresa,'')='' OR pEmpresa IS NULL 
	OR NVL(pNumCte,'')= '' OR pNumCte IS NULL 
	OR NVL(pSucursal,'')= '' OR pSucursal IS NULL 
	OR NVL(pEjecutivo,'')='' OR pEjecutivo IS NULL  
	OR NVL(pTramaAseguradoContratante,'')= '' OR pTramaAseguradoContratante IS NULL 
	OR NVL(pTramaAseguradoMigrantes,'')= '' OR pTramaAseguradoMigrantes IS NULL THEN
		LET cCodRet= '00001';
		RETURN cCodRet;
	END IF;
	
	SELECT fecha_hoy INTO dFechaHoy FROM bdisac:"informix".sac_fechas WHERE empresa=pEmpresa;
	
	LET iInicio = 1;
	WHILE iInicio < 17
		LET iIniContra = iIniContra + charindex ('|', substring(cTramaCont from iIniContra for iFin));
		LET iInicio = iInicio + 1;
	END WHILE;
	
	LET cCelular = substring(cTramaCont from iIniContra for charindex ('|', substring(cTramaCont from iIniContra for iFin))-1);
	LET iIniContra = iIniContra + charindex ('|', substring(cTramaCont from iIniContra for iFin));
		
	LET cCorreo = substring(cTramaCont from iIniContra for iFin);

	SELECT COUNT(numcte)
	INTO cContador
	FROM bdisac:"informix".sac_cardif_contratante 
	WHERE numcte=pNumcte;
	
	--Insertar o actualizar CONTRATANTE
	IF cContador = 0 THEN --Si no existe registro de cliente contratante
		INSERT INTO bdisac:"informix".sac_cardif_contratante(empresa, sucursal, numcte,num_certificado, num_poliza, ejecutivo, celular, correo, fecha_insert)
		VALUES(pEmpresa, pSucursal, pNumcte, '', '', pEjecutivo, cCelular, cCorreo, TO_CHAR(dFechaHoy, '%Y-%m-%d') || " " || current HOUR TO SECOND);
	ELSE 
		UPDATE bdisac:"informix".sac_cardif_contratante
		SET celular = cCelular, correo = cCorreo
		WHERE numcte = pNumcte;
	END IF;
	
	--Ciclo para insertar MIGRANTES
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
		
		LET cFechaAlta = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cFechaVenc = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
		
		LET cTipoPlan = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cParentesco = substring(cTramaMig from iInicio for charindex ('|', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('|', substring(cTramaMig from iInicio for iFin));
			
		LET cPolizaPrima = substring(cTramaMig from iInicio for charindex ('>>', substring(cTramaMig from iInicio for iFin))-1);
		LET iInicio = iInicio + charindex ('>>', substring(cTramaMig from iInicio for iFin));
		
		LET cTramaMig = substring(cTramaMig from (charindex('>>', cTramaMig) + 2) for iFin);
		
		LET iSecuencia = (SELECT MAX(secuencia) + 1 FROM bdisac:"informix".sac_cardif_migrante WHERE numcte = pNumcte);
		
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 1;
		END IF;
		
		INSERT INTO bdisac:"informix".sac_cardif_migrante(empresa, sucursal, numcte, secuencia, num_certificado, num_poliza, estatus, ejecutivo, nombre1, nombre2, apell_paterno, apell_materno, tipo_plan, fecha_alta, fecha_vencimiento, parentesco, fecha_insert)
		VALUES(pEmpresa, pSucursal, pNumcte, iSecuencia, '','','1', pEjecutivo, cNombre1, cNombre2, cApPat, cApMat, cTipoPlan, cFechaAlta, cFechaVenc, cParentesco, TO_CHAR(dFechaHoy, '%Y-%m-%d') || " " || current HOUR TO SECOND);
			
	END WHILE;
	RETURN cCodRet;

END;
END PROCEDURE;