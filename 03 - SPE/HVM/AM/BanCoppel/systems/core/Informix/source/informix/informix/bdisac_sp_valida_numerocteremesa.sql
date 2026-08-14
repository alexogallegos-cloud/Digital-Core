CREATE PROCEDURE "informix".sp_valida_numerocteremesa(pNumCte CHAR(20))
RETURNING 
CHAR(5)  AS  cCodRet,
CHAR(20) AS  cNumcte,
CHAR(1)  AS  iTipoCliente,
CHAR(5)  AS	 cValIne,
CHAR(5)  AS	 cListaNegra,
CHAR(5)	 AS	 cSespecial;
		  
	  
DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(20);
DEFINE iTipoCliente	CHAR(1);
DEFINE cValIne		CHAR(5);
DEFINE cResultINE	CHAR(50);
DEFINE cListaNegra	CHAR(5);
DEFINE cSespecial	CHAR(5);
DEFINE cStatuscte	CHAR(1);

DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 
DEFINE icontEsp 	INTEGER;
DEFINE iContList	INTEGER;

--EPG
DEFINE cSituacion   CHAR(5);
DEFINE cCausa       CHAR(5);
DEFINE cRfc			CHAR(13);
DEFINE iContListRfc	INTEGER;

LET cCodRet		 = "00000";
LET cNumcte 	 = "0";
LET iTipoCliente = "0";
LET cValIne 	 = "False";
LET cListaNegra  = "False";
LET cSespecial 	 = "False";
LET cStatuscte 	 = "";
LET icontEsp 	 = 0;
LET iContList 	 = 0;

--EPG
LET cSituacion  = '';
LET cCausa      = '';
LET cRfc 		= '';
LET iContListRfc = 0;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = 00002;
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/EPG/sp_valida_numerocteremesa.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	SELECT cterem.numcte, "1", cterem.status_cte, cte.rfc
	INTO cNumcte, iTipoCliente, cStatuscte, cRfc
	FROM bdinteg:"informix".si_cliente cte INNER JOIN
	bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte INNER JOIN
	bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
	WHERE cte.numcte = pNumCte;
			
	IF NVL(cNumcte,"") = "" THEN
		SELECT cte.numcte, "2", cte.rfc
		INTO cNumcte, iTipoCliente, cRfc
		FROM bdinteg:"informix".si_cliente cte INNER JOIN
		bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
		WHERE cte.numcte = pNumCte AND cte.tipo_cliente in("1","2");
		
		IF NVL(cNumcte,"") = "" THEN
			LET cNumcte = "000000000";
			LET iTipoCliente = "3";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	ELSE
		IF TRIM(cStatuscte) <> "A" THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END IF;
	
	SELECT resultado 
	INTO cResultINE
	FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte AND fecha = (SELECT MAX(fecha) FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte);
	
	IF (TRIM(NVL(cResultINE,"")) = "") OR (UPPER(TRIM(cResultINE)) = "VERDADERO") OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN
		LET cValIne = "True";
	ELIF (UPPER(TRIM(cResultINE)) = "FALSO") OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN
		LET cValIne = "False";
	END IF;
		
	--IF EXISTS(SELECT * FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = pNumCte) THEN
	SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna  WHERE numcte = pNumCte;
	SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
	LET iContList = iContList + iContListRfc;
	IF iContList > 0 THEN
		LET cListaNegra = "True";
	ELSE
		LET cListaNegra = "False";
	END IF;
		
	--IF EXISTS(SELECT * FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte) THEN
	--SELECT COUNT(*) INTO icontEsp FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte;
	--IF icontEsp > 0 THEN
	SELECT situacion, causa INTO cSituacion, cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte;
	LET cSituacion = TRIM(cSituacion)||TRIM(cCausa);
    IF 	cSituacion IN ('F42','P72','P108','U60') THEN
		LET cSespecial = "True";
	ELSE
		LET cSespecial = "False";
	END IF;
	
	RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
END;
END PROCEDURE
DOCUMENT
'DescripciÃ?Â³n: Se crea sp para utilizar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac',
'FOLIO		: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-------------------------------------------------------------------------------------------------',
'DescripciÃ?Â³n: se modifica sp para buscar por tipo de cliente (remesa o banco)',
'Autor      : Marco Antonio Rivera Zazueta',
'Fecha      : 17/08/2018',
'BD         : bdisac',
'FOLIO		: 433 REQ. Base de datos para el alta de usuarios de remesas',
'-------------------------------------------------------------------------------------------------',
'DescripciÃ?Â³n: se agrega validacion para la consulta de si_bitacora_ife',
'Autor      : Marco Antonio Rivera Zazueta',
'Fecha      : 20/10/2018',
'BD         : bdisac',
'FOLIO		: Homologacion del proyecto RQM 10 784-2 - Base de datos para el alta de usuarios de remesas / Nueva estructura INE',
'-------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_valida_dv_contigo
(
	  pNumRef CHAR (13)
)
RETURNING CHAR(5) AS cod_ret;

DEFINE cCod_ret         CHAR(5);
DEFINE vCadena          CHAR(100);
DEFINE iSqlErr          INTEGER;
DEFINE vPosicion		INTEGER;
DEFINE vMultip 			INTEGER;
DEFINE vSuma 			INTEGER;
DEFINE vResultado 		INTEGER;

LET cCod_ret    = '00000';
LET iSqlErr     = 0;
LET vMultip		= 2;
LET vResultado	= 0;
LET vCadena 	= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
				RETURN cCod_ret;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		IF LEN(pNumRef) < 13 THEN
			LET cCod_ret = '00002';
			RETURN cCod_ret;	
		END IF;
		
			--SET DEBUG FILE TO '/informix/Jcbenitez/sp_valida_dv_contigo.out';
			--TRACE ON;
			
			FOR vPosicion=12 TO 1 LOOP
				
				LET vSuma= (cast(substr(pNumRef, vPosicion,1) AS INTEGER) * vMultip);
				
				IF vSuma > 9 then
					LET vSuma = substr(vSuma,1,1) + substr(vSuma,2,1);
				END IF;
				
				LET vResultado= vResultado + vSuma;
				
				IF vMultip = 2 THEN
					LET vMultip = 1;
				ELIF vMultip = 1 THEN
					LET vMultip = 2;
				END IF;
				
			END LOOP;
			
			IF MOD(vResultado,10) = 0 THEN
				LET vResultado = 0;
			ELSE
				LET vResultado = 10 - MOD(vResultado,10) ;
			END IF;
			
			
			IF vResultado <> CAST(SUBSTR(pNumRef, 13,1) AS INTEGER) THEN
				LET cCod_ret = '00109';
			END IF;

			RETURN cCod_ret;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Juan Carlos Benitez Tarin',
'FOLIO: ',
'DESCRIPCION: Valida el digito verificador de Pagos Contigo',
'FECHA: 15/02/2019',
'VERSION: 1.0000',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_consulta_cte_remesa(pnumcte CHAR(20))

	--DATOS DE SALIDA
	RETURNING   CHAR(5)   AS CodigoRetorno,  
				CHAR(26)  AS Nombre1,
				CHAR(26)  AS Nombre2,
				CHAR(26)  AS ApellPat,
				CHAR(26)  AS ApelliMat,
				DATE	  AS FechaNac,
				CHAR(2)   AS CodIdentificacion,
				CHAR(30)  AS NumIdentificacion,
				CHAR(3)   AS PaisEmision,
				DATE	  AS FechaVencimiento,
				CHAR(3)   AS Nacionalidad,
				CHAR(3)   AS PaisNac,
				CHAR(2)   AS EdoNac,
				CHAR(5)	  AS LugarNac,
				CHAR(1)   AS Sexo,
				CHAR(2)	  AS Estado,
				CHAR(3)	  AS Ciudad,
				CHAR(5)	  AS Municipio,
				CHAR(11)  AS Colonia,
				CHAR(11)  AS Calle,
				CHAR(10)  AS NroExterior,
				CHAR(10)  AS NroInterior,
				CHAR(5)	  AS CodPostal,
				CHAR(13)  AS TelCasa,
				CHAR(13)  AS TelCelular;

	--DECLARACION DE VARIABLES
	DEFINE iSqlErr        		INTEGER;
	DEFINE iIsamErr         	INTEGER;
	DEFINE cCodRet        		CHAR(5);
	DEFINE cNumCliente			CHAR(20);
	DEFINE cNombre1				CHAR(26);
	DEFINE cNombre2				CHAR(26);
	DEFINE cApellPat			CHAR(26);
	DEFINE cApellMat			CHAR(26);
	DEFINE dFechaNac			DATE;
	DEFINE cCodIdentificacion	CHAR(2);
	DEFINE cNumIdentificacion 	CHAR(30);
	DEFINE cPais_emision    	CHAR(3);
	DEFINE dFecha_vencimiento   DATE;
	DEFINE cNacionalidad		CHAR(3);
	DEFINE cPaisNac				CHAR(3);
	DEFINE cEdoNac				CHAR(2);
	DEFINE cLugarNac			CHAR(5);
	DEFINE cSexo				CHAR(1);
	DEFINE cEdo					CHAR(2);
	DEFINE cCiudad				CHAR(3);
	DEFINE cMunicipio			CHAR(5);
	DEFINE cNroColonia			CHAR(11);
	DEFINE cNroCalle			CHAR(11);
	DEFINE cNroExt				CHAR(10);
	DEFINE cNroInt				CHAR(10);
	DEFINE cCodPostal			CHAR(5);
	DEFINE cTelCasa				CHAR(13);
	DEFINE cTelCelular			CHAR(13);
	DEFINE iTipoDir				INTEGER;
	

	--INICIALIZACION DE VARIABLES
	LET iSqlErr       	   = 0;
	LET iIsamErr           = 0 ;
	LET cCodRet	           = "00000";
	LET cNumCliente		   = "";
	LET cNombre1		   = "";
	LET cNombre2		   = "";
	LET cApellPat		   = "";
	LET cApellMat		   = "";
	LET dFechaNac		   = "";
	LET cCodIdentificacion = "";
	LET cNumIdentificacion = "";
	LET cPais_emision      = "";
	LET dFecha_vencimiento = "";
	LET cNacionalidad	   = "";
	LET cPaisNac		   = "";
	LET cEdoNac			   = "";
	LET cLugarNac		   = "";
	LET cSexo			   = "";
	LET cEdo			   = "";
	LET cCiudad			   = "";
	LET cMunicipio		   = "";
	LET cNroColonia		   = "";
	LET cNroCalle		   = "";
	LET cNroExt			   = "";
	LET cNroInt			   = "";
	LET cCodPostal		   = "";
	LET cTelCasa		   = "";
	LET cTelCelular		   = "";
	LET iTipoDir		   =0;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/EPG/sp_consulta_cte_remesa.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						RETURN cCodRet, cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
						cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular;
				END IF;
		END EXCEPTION;
	
		--VALIDACIÃ?N DEL PARAMETRO DE ENTRADA.
		IF pnumcte = "" THEN
			LET cCodRet = "00002"; --PARAMETRO VACIO
			RETURN cCodRet, cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
			cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular;
		END IF;
		
		--Se verifica si el cliente tiene tipo de direcciÃ³n 1, si no busca el tipo 2.
		SELECT tipo_dir INTO iTipoDir 
		FROM bdinteg:"informix".si_direcciones_actual 
		WHERE numcte = pnumcte AND tipo_dir = 1;
		
		IF NVL(iTipoDir,0) = 0 THEN
		   LET iTipoDir = 0;
           SELECT cte.numcte,cte.nombre1,cte.nombre2,cte.apell_paterno,cte.apell_materno,ctepf.fecha_nac,
                  CASE WHEN (ctepf.codidentifi IN("B","A")) THEN ctepf.codidentifi ELSE "" END AS codidentifi,ctepf.numidentifi,
                  NVL(cterem.pais_emision,"") AS pais_emision,NVL(cterem.fecha_vencimiento,"") AS fecha_vencimiento,ctepf.nacionalidad,NVL(ctepf.id_pais,"") AS PaisNac,ctepf.lugar_nac AS EdoNac, 
                  CASE WHEN cterem.ciudadnacimiento IS NOT NULL THEN cterem.ciudadnacimiento ELSE "" END AS LugarNac,ctepf.sexo,
                  NVL(tel1.telefono,"") AS TelCasa,NVL(tel2.telefono,"") AS Celular
                  INTO cNumCliente,cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,cPaisNac,cEdoNac,cLugarNac,cSexo,cTelCasa,cTelCelular
             FROM bdinteg:"informix".si_cliente cte INNER JOIN
                  bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte LEFT JOIN
                  bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte LEFT JOIN
                  bdinteg:"informix".si_telefonos_actual tel1 ON cte.numcte = tel1.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = "A" LEFT JOIN
                  bdinteg:"informix".si_telefonos_actual tel2 ON cte.numcte = tel2.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = "A"
            WHERE cte.numcte = pnumcte;
            
		END IF;
	
        IF NVL(iTipoDir,0) = 1 THEN
            SELECT cte.numcte,cte.nombre1,cte.nombre2,cte.apell_paterno,cte.apell_materno,ctepf.fecha_nac,CASE WHEN (ctepf.codidentifi IN("B","A")) THEN ctepf.codidentifi ELSE "" END AS codidentifi,ctepf.numidentifi,
                NVL(cterem.pais_emision,"") AS pais_emision,NVL(cterem.fecha_vencimiento,"") AS fecha_vencimiento,ctepf.nacionalidad,NVL(ctepf.id_pais,"") AS PaisNac,ctepf.lugar_nac AS EdoNac, 
                CASE WHEN cterem.ciudadnacimiento IS NOT NULL THEN cterem.ciudadnacimiento ELSE "" END AS LugarNac,ctepf.sexo,dir.estado,dir.ciudad,dir.municipio,dir.numerocolonia,dir.numerocalle,
                dir.numeroextcalle,dir.numerointcalle,dir.cod_postal,NVL(tel1.telefono,"") AS TelCasa,NVL(tel2.telefono,"") AS Celular
                INTO cNumCliente,cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,
                cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular
            FROM bdinteg:"informix".si_cliente cte INNER JOIN
                bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte LEFT JOIN
                bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte INNER JOIN
                bdinteg:"informix".si_direcciones_actual dir ON cte.numcte = dir.numcte and dir.fecha_insert = (SELECT MAX(fecha_insert) FROM bdinteg:"informix".si_direcciones_actual dir WHERE numcte = cte.numcte AND tipo_dir = iTipoDir) 
                AND dir.tipo_dir = iTipoDir LEFT JOIN
                bdinteg:"informix".si_telefonos_actual tel1 ON cte.numcte = tel1.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = "A" LEFT JOIN
                bdinteg:"informix".si_telefonos_actual tel2 ON cte.numcte = tel2.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = "A"
            WHERE cte.numcte = pnumcte;
        END IF;

		IF NVL(cNumCliente,"") = "" THEN --Cliente no existe
			LET cCodRet = "00001";
		END IF;
		
	RETURN cCodRet, cNombre1,cNombre2,cApellPat,cApellMat,dFechaNac,cCodIdentificacion,cNumIdentificacion,cpais_emision,dFecha_vencimiento,cNacionalidad,
	cPaisNac,cEdoNac,cLugarNac,cSexo,cEdo,cCiudad,cMunicipio,cNroColonia,cNroCalle,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular;
END;
END PROCEDURE
DOCUMENT
'FOLIO: 197',
'DESCRIPCION: REALIZA LA CONSULTA DE LOS DATOS DE USUARIOS DE REMESAS EN LA TABLA SAC_CTE_REMESAS.',
'AUTOR: ANAYELI CAMACHO GUTIERRÃ?Z',
'SUSTENTO: RQI 63 266 ALTA DE USUARIOS DE REMESA OFI',
'FECHA DE CREACION: 17/03/2017',
'SOLICITA: JAIME GONZALEZ',
'VERSION: 1.0 20170317',
'BD: BDISAC',
'----------------------------------------------------------------------------------------------------------------------',
'FOLIO: 433',
'DESCRIPCION: SE MODIFICA PARA QUE RETORNE LOS DATOS DEL CLIENTE.',
'AUTOR: MARCO RIVERA',
'SUSTENTO: 433 REQ. BASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'FECHA DE CREACION: 14/08/2018',
'SOLICITA: LEORNARDO HERNANDEZ',
'BD: BDISAC',
'----------------------------------------------------------------------------------------------------------------------',
'FOLIO: 496',
'DESCRIPCION: Se modifica sp ya que no encontraba algunos clientes por el tipo de direccion 1.',
'AUTOR: MARCO RIVERA',
'SUSTENTO: Homologacion del proyecto RQM 10 784-2 - Base de datos para el alta de usuarios de remesas / Nueva estructura INE',
'FECHA DE MODIFICACION: 20/10/2018',
'SOLICITA: LEORNARDO HERNANDEZ',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_app_submitpayment
(
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	pterminalid			CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pcustomernumber		CHAR(20),
	pfirstname			CHAR(40),
	pmiddlename			CHAR(40),
	plastname			CHAR(40),
	pmommaidenname	 	CHAR(40),
	padress				CHAR(80),
	pcity				CHAR(40),
	pcountrycodeadr		CHAR(3),
	pstatecodeadr		CHAR(3),
	pzipcode			CHAR(10),
	pemail				CHAR(100),
	phomephonenum		CHAR(15),
	pnumbercel			CHAR(15),
	preceiveemail		CHAR(3),
	preceivesms			CHAR(3),
	ptypecodeci			CHAR(3),
	pnumberci			CHAR(20),
	pexpirationdate		CHAR(8),
	pissuercc			CHAR(3),
	pdateofbirth		CHAR(8),
	pcontrycode			CHAR(5),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_rule				CHAR(3),
	pr_value			CHAR(3),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_codesalecom		CHAR(3),
	pr_countrycode		CHAR(3),
	pr_statecodesale	CHAR(3),
	pr_saledate			CHAR(8),
	pr_saletime			CHAR(6),
	pr_countrycode_o	CHAR(3),
	pr_currencycode		CHAR(3),
	pr_servicecode		CHAR(3),
	pr_countrycode_d	CHAR(3),
	pr_currencycod_d	CHAR(3),
	pr_delimethodcod	CHAR(3),
	pr_playnwcode		CHAR(3),
	pr_paysubnwcode		CHAR(15),
	pr_branchnumber		CHAR(15),
	pr_accounttcod		CHAR(3),
	pr_accountnumber	CHAR(30),
	pr_originamount		CHAR(20),
	pr_destinamount		CHAR(20),
	pr_rexchangerate	CHAR(21),
	pr_wholesalerate	CHAR(21),
	pr_deexhangerate	CHAR(21),
	pr_servfeeamount	CHAR(20),
	pr_discountamoun	CHAR(20),
	pr_typecode			CHAR(3),
	pr_accountnum		CHAR(30),
	pr_biccode			CHAR(11),
	pr_refnumber		CHAR(30),
	pr_customernum		CHAR(20),
	pr_firstname		CHAR(40),
	pr_middlename		CHAR(40),
	pr_lastname			CHAR(40),
	pr_mommaidenname 	CHAR(40),
	pr_address			CHAR(80),
	pr_city				CHAR(40),
	pr_countrycode_a	CHAR(3),
	pr_statecode		CHAR(3),
	pr_zipcode			CHAR(10),
	pr_typecode_i		CHAR(3),
	pr_number			CHAR(20),
	pr_expirdate		CHAR(8),
	pr_isscontrycode	CHAR(3),
	pr_issstatecode		CHAR(3),
	pr_dateofbirth		CHAR(8),
	pr_customernum_b 	CHAR(20),
	pr_firstname_b		CHAR(40),
	pr_middlename_b		CHAR(40),
	pr_lastname_b		CHAR(40),
	pr_mommaidenna_b 	CHAR(40),
	pr_firstname_f		CHAR(40),
	pr_middlename_f		CHAR(40),
	pr_lastname_f		CHAR(40),
	pr_mommaidenna_f 	CHAR(40),
	pr_address_b		CHAR(80),
	pr_city_b			CHAR(40),
	pr_countrycode_b	CHAR(3),
	pr_statecode_b		CHAR(3),
	pr_zipcode_b		CHAR(10),
	pr_email			CHAR(100),
	pr_homephonenum 	CHAR(15),
	pr_workphonenum		CHAR(15),
	pr_number_cl		CHAR(15),
	pr_receiveemail		CHAR(3),
	pr_receivesms		CHAR(3),
	pr_typecode_ib		CHAR(3),
	pr_number_ib		CHAR(20),
	pr_expirdate_ib		CHAR(8),
	pr_issconcode_ib	CHAR(3),
	pr_issstacode_ib	CHAR(3),
	pr_reastypecode		CHAR(3),
	pr_refortransfer	CHAR(40),
	pr_sourceoffunds	CHAR(40),
	pr_securphrase		CHAR(40),
	pr_feemessage		CHAR(255),
	puser_insert		CHAR(8),
	pfecha				DATE,
	pNumCte			    CHAR(20)
)
RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (255) AS cr_Message, --1.2
		  CHAR (255) AS cr_Message_Detail; --1.3.2
		  
	  
--Declaracion de variables 
		DEFINE cCodRet 		    	CHAR(5);
		DEFINE iSqlErr				INTEGER;
		DEFINE imenscode			INTEGER;
		DEFINE cr_Message			CHAR (255);
		DEFINE cr_Message_Detail	CHAR (255);
		
		DEFINE crsp_CodRet			CHAR(5);
		DEFINE crsp_Message			CHAR (255);
		DEFINE crsp_Message_Detail	CHAR (255);
		DEFINE c_Mess_D				CHAR (255);
		DEFINE vfec_nac				DATE;
		
		DEFINE vCodRet				CHAR(5);
		DEFINE vcuenta				INTEGER;
		DEFINE vCategoria			CHAR(2);
		DEFINE vConvenio			CHAR(5);
		
		
-----------------------------------------------------------------------------------------------------------------------------------
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				= 0;
		LET imenscode			= 0;
        LET cr_Message			= pr_message;
		LET cr_Message_Detail	= pr_message_d;
		
		LET crsp_CodRet			= '';
		LET crsp_Message		= '';
		LET crsp_Message_Detail	= '';
		LET c_Mess_D			= pr_message_d;
		
		LET vcuenta				= 0;
		LET vCodRet				= '00000';
		LET vCategoria			= '07';
		LET vConvenio			= '009';
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cr_Message, cr_Message_Detail;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_app_submitpayment.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(puser_insert, '') = '' OR NVL(pfecha, '') = '' OR NVL(prefnum, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '');

		ELSE
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espaÃ?ÃÂ±ol 
			EXECUTE PROCEDURE BDISAC: "informix".sp_app_mensajes ('PAYI', pr_code, pr_code_d)
			INTO crsp_CodRet, crsp_Message, crsp_Message_Detail;	
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				-- no trajo resultados del llamado al sp
				LET cCodRet = '00001';
			ELSE
				IF crsp_CodRet = '00000' THEN
					LET cr_Message = crsp_Message;
					LET imenscode = 1;
				ELSE
					IF crsp_CodRet = '00001' THEN
						LET cr_Message = crsp_Message;
					ELSE
						IF crsp_CodRet = '00002' THEN
							LET imenscode = 1;
						END IF;
					END IF;
				END IF;
			END IF;
			IF imenscode = 1 then
				IF pr_code_d = "D001" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D002" THEN
					LET imenscode = 28;
				ELIF  pr_code_d = "D003" THEN
					LET imenscode = 19;
				ELIF  pr_code_d = "D004" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D005" THEN
					LET imenscode = 20;
				END IF;
				-- corta parametro en mensaje ingles "Required Parameter: {0} Parameter Key"
				LET c_Mess_D = SUBSTR(c_Mess_D, imenscode);
				LET c_Mess_D = REPLACE(c_Mess_D, " Parameter Key","");
				-- concatenar parametro con el mensaje en espaÃ?ÃÂ±ol "El parÃ?ÃÂ¡metro requerido: {0} parÃ?ÃÂ¡metro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			--Inserta registro
			IF (cCodRet = '00000')THEN
								
				INSERT INTO bdisac: "informix".sac_app_payi (txn_status,unirefnum,refnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,customernumber,firstname,middlename,lastname,mommaidenname,adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms,typecodeci,numberci,expirationdate,issuercc,dateofbirth,contrycode,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha,numcte) 
				VALUES (ptxn_status, punirefnum, prefnum, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, pterminalid, pprocessdate, pprocesstime, pcustomernumber, pfirstname, pmiddlename, plastname, pmommaidenname, padress, pcity, pcountrycodeadr, pstatecodeadr, pzipcode, pemail, phomephonenum, pnumbercel, preceiveemail, preceivesms, ptypecodeci, pnumberci, pexpirationdate, pissuercc, pdateofbirth, pcontrycode, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail,  pr_processdate, pr_processtime, pr_rule, pr_value, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, pr_uniquerefnum, pr_codesalecom, pr_countrycode, pr_statecodesale, pr_saledate, pr_saletime, pr_countrycode_o, pr_currencycode, pr_servicecode, pr_countrycode_d, pr_currencycod_d, pr_delimethodcod, pr_playnwcode, pr_paysubnwcode, pr_branchnumber, pr_accounttcod, pr_accountnumber, pr_originamount, pr_destinamount, pr_rexchangerate, pr_wholesalerate, pr_deexhangerate, pr_servfeeamount, pr_discountamoun, pr_typecode, pr_accountnum, pr_biccode, pr_refnumber, pr_customernum, pr_firstname, pr_middlename, pr_lastname, pr_mommaidenname, pr_address, pr_city, pr_countrycode_a, pr_statecode, pr_zipcode, pr_typecode_i, pr_number, pr_expirdate, pr_isscontrycode, pr_issstatecode, pr_dateofbirth, pr_customernum_b, pr_firstname_b, pr_middlename_b, pr_lastname_b, pr_mommaidenna_b, pr_firstname_f, pr_middlename_f, pr_lastname_f, pr_mommaidenna_f, pr_address_b, pr_city_b, pr_countrycode_b, pr_statecode_b, pr_zipcode_b, pr_email, pr_homephonenum, pr_workphonenum, pr_number_cl, pr_receiveemail, pr_receivesms, pr_typecode_ib, pr_number_ib, pr_expirdate_ib, pr_issconcode_ib, pr_issstacode_ib, pr_reastypecode, pr_refortransfer, pr_sourceoffunds, pr_securphrase, pr_feemessage, puser_insert, CURRENT,pNumCte);
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				ELSE
					LET vfec_nac = MDY(SUBSTRING(pdateofbirth FROM 5 FOR 2), SUBSTRING(pdateofbirth FROM 7 FOR 2), SUBSTRING(pdateofbirth FROM 1 FOR 4));
					EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, punirefnum, pfirstname, pmiddlename, plastname, pmommaidenname, vfec_nac, pr_currencycode, pr_originamount)
					INTO vCodRet, vcuenta;
				END IF;
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;

		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: ServirÃ?ÃÂ¡ para insertar en la tabla sac_app_payi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'DescripciÃÂ³n: Se insertan campo numcte para Trabajar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac ',
'FOLIO: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-----------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_confpago_remesa 
(
	cReferencia1 		CHAR (20),
	cCategoria 			CHAR (2), 
	cConvenio 			CHAR(5),
	cFolio_suc 			CHAR (16),
	pNewMtcn 			CHAR(16), 
	pMtcn 				CHAR(10), 
	pBenefCiudad 		CHAR(24), 
	pBenefEdo 			CHAR(40),
	pRetCode 			CHAR(5), 	
	pDesError 			CHAR(250), 
	pFechaHoraRp 		DATETIME YEAR TO SECOND, 
	pFechaInsert 		DATETIME YEAR TO SECOND,
	pFechaNac 			CHAR(8),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pMoneyTransferKey	CHAR(10),  
	pForeignRefNumRq	CHAR(16), 
	pForeingRefNumRp	CHAR(16), 
	pUserInsert			CHAR(8),
	pConfPago           CHAR(1),
	pNumClienteRemesa   CHAR(20)
)
RETURNING
CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE cConf_pago CHAR(1);
	DEFINE cTxn_status CHAR(1);
	DEFINE dMaxFexha DATETIME YEAR TO SECOND;
	DEFINE cod_errPayWU CHAR(5);
	DEFINE error_descPayWU CHAR(30);
	DEFINE cMarca CHAR(2);
	
	
	LET cCodRet = '00000';
	LET iSql_err = 0;
	LET iIsamErr = 0;
	LET cDescripcion = '';
	LET cConf_pago = '';
	LET cTxn_status = '';
	LET dMaxFexha = '1900-01-01 00:00:00';
	LET cod_errPayWU= '';
	LET error_descPayWU = '';
	
	-- SET DEBUG FILE TO '/tmp/isaac/trace.sql';
	-- TRACE ON;
	 

    BEGIN
		ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
		   IF iSql_err <> 0 THEN
			  LET cCodRet = iSql_err;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		


		IF  NVL(cReferencia1,'') <> ''THEN		
		
				
				IF cCategoria = '07' AND ( cConvenio = '006') THEN LET cMarca = 'WU'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '007') THEN LET cMarca = 'OV'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '008') THEN LET cMarca = 'VI'; END IF;								
				
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_pay(pUsuario,pBenefNameType,pBenefNombreUno,pBenefNombreDos,pBenefApaterno,pBenefAmaterno,pFechaNac,pMoneyTransferKey,pNewMtcn,pMtcn,pForeignRefNumRq,pRetCode,pForeingRefNumRp,pDesError,pUserInsert,pConfPago,pNumClienteRemesa)
			    INTO cod_errPayWU, error_descPayWU;
				
				SELECT MAX(fecha_insert)
				INTO dMaxFexha
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE mtcn = cReferencia1
				AND TO_CHAR(fecha_insert::DATE) = TODAY;									
									
				SELECT conf_pago, txn_status 
				INTO cConf_pago, cTxn_status 
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE  mtcn = cReferencia1 
				AND fecha_insert = dMaxFexha;	

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00002';
				ELSE
					IF NVL(cConf_pago,'') <> '' AND NVL(cTxn_status,'') <> '' THEN
						IF TRIM(cConf_pago) <> 'P' AND TRIM(cTxn_status) <>'A' THEN
							LET cCodRet = '00004';
						END IF;
					ELSE
						LET cCodRet = '00003';
					END IF;
				END IF;

		ELSE
			LET cCodRet = '00001';
		END IF;	

		RETURN cCodRet;
    END;
END PROCEDURE;