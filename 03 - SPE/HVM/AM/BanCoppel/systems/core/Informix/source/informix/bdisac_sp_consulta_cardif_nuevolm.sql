CREATE PROCEDURE "informix".sp_consulta_cardif_nuevolm(pNumcte CHAR(20), pAsegurado_Nombre1 CHAR(26), pAsegurado_Nombre2 CHAR(26), pAsegurado_Apell_Pat CHAR(26), pAsegurado_Apell_Mat CHAR(26), pAsegurado_FechaNac DATE)

RETURNING
CHAR(5)	    AS  cCodRet,
CHAR(20)    AS  cNumcte,
CHAR(26)    AS  cNombre1,
CHAR(26)    AS  cNombre2,
CHAR(26)    AS  cApell_paterno,
CHAR(26)    AS  cApell_materno,
CHAR(13)    AS  cRfc,
CHAR(2)	    AS	cEstado,
CHAR(3)	    AS  cCiudad,
CHAR(11)    AS  cColonia,
CHAR(11)    AS  cCalle,
CHAR(10)    AS  cNumExt,
CHAR(10)    AS  cNumInt,
CHAR(5)	    AS  cCP,
CHAR(13)    AS  cCelular,
CHAR(100)   AS  cCorreo, 
CHAR(1)	    AS  cFlagSeguro,
CHAR(50)    AS  cNumPoliza,
CHAR(1024)	AS  cTramaMigrantesBD,
DATE 		AS  cFechaNacimiento

--Variables de retorno
DEFINE cCodRet			 CHAR(5);
DEFINE cNumcte           CHAR(20);
DEFINE cNombre1          CHAR(26);
DEFINE cNombre2          CHAR(26);
DEFINE cApell_paterno    CHAR(26);
DEFINE cApell_materno    CHAR(26);
DEFINE cRfc              CHAR(13);
DEFINE cEstado           CHAR(2);  
DEFINE cCiudad           CHAR(3);  
DEFINE cColonia          CHAR(11);
DEFINE cCalle            CHAR(11);
DEFINE cNumExt           CHAR(10);
DEFINE cNumInt           CHAR(10);
DEFINE cCP               CHAR(5);  
DEFINE cCelular          CHAR(13);
DEFINE cCorreo           CHAR(100);
DEFINE cFlagSeguro       CHAR(1);  
DEFINE cNumPoliza        CHAR(50);
DEFINE cTramaMigrantesBD CHAR(1024);
DEFINE cFechaNacimiento  DATE ;

--Variables internas
DEFINE iExisteCte 	 INTEGER;
DEFINE iExisteCteRem INTEGER;
DEFINE iSqlErr       INTEGER; 
DEFINE iIsamErr    	 INTEGER; 
DEFINE cInfoErr 	 CHAR(10); 
DEFINE cCodRetRfc	 CHAR(5);
DEFINE cTramaMigrantesAux CHAR(1024);
DEFINE iSecDireccion INTEGER;
DEFINE cStatuConv	 CHAR(1);
DEFINE cNombresAseg	 CHAR(70);
DEFINE iSegActivos   INTEGER;
DEFINE cEstatusMig	 CHAR(2);

DEFINE v_Conteo		INTEGER;

--SET DEBUG FILE TO "/informix/HMLG/sp_consulta_cardif.out";
--TRACE ON;	

--Asignacion de valores default
LET cCodRet			  = "00000";
LET cNumcte           = "";
LET cNombre1          = "";
LET cNombre2          = "";
LET cApell_paterno    = "";
LET cApell_materno    = "";
LET cRfc              = "";
LET cEstado           = "";
LET cCiudad           = "";
LET cColonia          = "";
LET cCalle            = "";
LET cNumExt           = "";
LET cNumInt           = "";
LET cCP               = "";
LET cCelular          = "";
LET cCorreo           = ""; 
LET cFlagSeguro       = "0";
LET cNumPoliza        = "";
LET cTramaMigrantesBD = "";
LET cNombresAseg	  = "";
LET iSegActivos		  = 0;

LET iExisteCte		  = 0;
LET iExisteCteRem	  = 0;
LET cTramaMigrantesAux= "";
LET cFechaNacimiento  ="";

LET v_Conteo		  = 0;


--SET DEBUG FILE TO "/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_consulta_cardif.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento; 
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Valida que algunos de los dos tipo de busqueda cumpla con los campos minimos
	IF (TRIM(pNumcte) = "") THEN
		IF (TRIM(pAsegurado_Nombre1) = "" OR TRIM(pAsegurado_Apell_Pat) = "" OR pAsegurado_FechaNac IS NULL) THEN
			LET cCodRet= "00001"; --alguno de los dos metodos de busqueda le faltan datos.
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
		END IF;
	END IF;
	
	--Se valida que el servicio este activo
	SELECT statusconvenio 
	INTO cStatuConv
	FROM bdisac:"informix".sac_convenios
	WHERE numcategoria = "09" and numconvenio = "023";
	
	IF TRIM(cStatuConv) = "I" THEN
		LET cFlagSeguro = "9";
		LET cCodRet = "128";
		RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
	END IF;
	
	IF TRIM(pNumcte) = "" THEN
		
		LET cNombresAseg = TRIM(pAsegurado_Nombre1)||' '||TRIM(pAsegurado_Nombre2);
		LET pAsegurado_Apell_Pat = TRIM(pAsegurado_Apell_Pat);
		LET pAsegurado_Apell_Mat = TRIM(pAsegurado_Apell_Mat);
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_calcularrfc(pAsegurado_Apell_Pat,pAsegurado_Apell_Mat,cNombresAseg,pAsegurado_FechaNac) INTO cCodRetRfc, cRfc;
		
		IF NVL(cCodRetRfc,"") <> "00000" THEN
			LET cCodRet = cCodRetRfc;
		ELSE
			SELECT cte.numcte, count(cte.numcte), count(rem.numcte)
			INTO pNumcte, iExisteCte, iExisteCteRem
			FROM bdinteg:"informix".si_cliente cte LEFT JOIN
			bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
			WHERE cte.rfc = cRfc
			GROUP BY cte.numcte;
		END IF;
	END IF;
	
	LET cNumcte = pNumcte;
	
	SELECT COUNT(cte.numcte), COUNT(rem.numcte)
	INTO iExisteCte, iExisteCteRem
	FROM bdinteg:"informix".si_cliente cte LEFT JOIN
	bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
	WHERE cte.numcte = pNumcte;
	
	IF iExisteCte = 0 THEN
		LET cCodRet = "00002";
	ELIF iExisteCteRem = 0 THEN
		LET cCodRet = "00003";
	END IF;
	
	IF TRIM(cCodRet) = "00000" THEN
		
		/*Se aÃÂ±ade UPDATE para no mostrar operaciones inconclusas por time out de proveredor para cliente especifico */
			
			LET iExisteCte = 0;
			
			SELECT COUNT(*) 
			INTO iExisteCte
			FROM bdisac:"informix".sac_cardif_migrante
			WHERE numcte = pNumcte
			AND estatus = 1
			AND folio_suc IS NULL
			AND num_certificado = ''
			AND num_poliza = '';
			
			IF iExisteCte <> 0 THEN
				UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 Operacion Inconclusa Oper'
				WHERE numcte = pNumcte
				AND estatus = 1
				AND folio_suc IS NULL
				AND num_certificado = ''
				AND num_poliza = '';
			END IF;	
			
		/*-------*/
		
	
		SELECT MAX(secuencia) INTO iSecDireccion 
		FROM bdinteg:"informix".si_direcciones_actual WHERE numcte= pNumcte AND tipo_dir = 1;
		
		SELECT cte.nombre1,cte.nombre2,cte.apell_paterno,cte.apell_materno,cte.rfc,dir.estado,dir.ciudad,dir.numerocolonia,dir.numerocalle,dir.numeroextcalle,dir.numerointcalle,dir.cod_postal
		INTO cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP
		FROM bdinteg:"informix".si_cliente cte
		INNER JOIN bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte 
		INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON dir.numcte = cte.numcte AND dir.tipo_dir = 1 AND dir.secuencia = iSecDireccion
		WHERE numcte = pNumcte;
		
		IF NVL(cEstado,"") = "" OR NVL(cCiudad,"") = "" OR NVL(cColonia,"") = "" OR NVL(cCalle,"") = "" OR NVL(cNumExt,"") = "" OR NVL(cCP,"") = "" THEN
			LET cCodRet = "00005";
		ELSE
			SELECT telefono INTO cCelular FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND tel.tipo_tel = 2 AND tel.status_tel = "A";
			SELECT fecha_nac INTO cFechaNacimiento FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
		
		END IF;
	
		SELECT COUNT(numcte), trim(num_certificado) || "|" || trim(num_poliza)
		INTO cFlagSeguro, cNumPoliza
		FROM bdisac:"informix".sac_cardif_contratante
		WHERE numcte = pNumcte
		GROUP BY num_certificado,num_poliza;
		
		IF cFlagSeguro <> "0" THEN
			SELECT celular, correo
			INTO cCelular, cCorreo
			FROM bdisac:"informix".sac_cardif_contratante
			WHERE numcte = pNumcte;
			LET cFlagSeguro = 1;
		ELSE
			SELECT correo_elec 
			INTO cCorreo
			FROM bdinteg:"informix".si_correos 
			WHERE empresa='001' AND tipo_correo=1 AND status_correo='A' AND numcte=pNumcte AND secuencia=(SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa='001' AND tipo_correo=1 AND numcte=pNumcte AND status_correo='A');
		END IF;
			
		IF cFlagSeguro <> "0" THEN
			
			FOREACH WITH HOLD
				SELECT TRIM(num_certificado) || "|" || TRIM(num_poliza) || "|" || TRIM(estatus) || "|" || TRIM(nombre1) || "|" || TRIM(nombre2) || "|" || 
				TRIM(apell_paterno) || "|" || TRIM(apell_materno) || "|" || TRIM(tipo_plan) || "|" || TRIM(TO_CHAR(fecha_alta,"%d/%m/%Y")) || "|" || 
				TRIM(TO_CHAR(fecha_vencimiento,"%d/%m/%Y")) || "|" || "" || "|" || TRIM(parentesco), TRIM(estatus)
				INTO cTramaMigrantesAux, cEstatusMig
				FROM bdisac:"informix".sac_cardif_migrante WHERE numcte = pNumcte AND estatus IN ("1","2")
				
				LET cTramaMigrantesBD = TRIM(cTramaMigrantesBD) || TRIM(cTramaMigrantesAux) || ">>";
				
				IF (TRIM(cEstatusMig) = "1") OR (TRIM(cEstatusMig) = "2") THEN
					LET iSegActivos = iSegActivos + 1;
				END IF;
				
			END FOREACH;
			
			IF iSegActivos = 0 THEN
				LET cFlagSeguro = 0;
				LET cNumPoliza = "";
			END IF;
		END IF;
	END IF;
	RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,NVL(cFlagSeguro,"0"),NVL(cNumPoliza,""),cTramaMigrantesBD,cFechaNacimiento;
END;
END PROCEDURE;