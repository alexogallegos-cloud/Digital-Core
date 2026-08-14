CREATE PROCEDURE "informix".sp_cnsif_consnumcte_soc(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cTCONSULTA char(1),cTDOMICILIO char(1),cTBUSQUEDA CHAR(1),cNUMCTE char(20),cNUMCUENTA CHAR(20),cNUMTARJETA CHAR(20), cNUMTELEFONO CHAR(10), cNUMCUENTACLABE CHAR(18))
       returning 	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(26) AS Nombre_1,
					CHAR(26) AS Nombre_2,
					CHAR(26) AS Apellido_Paterno,
					CHAR(26) AS Apellido_Materno,
					CHAR(60) AS Razon_Social,
					CHAR(13) AS RFC,
					CHAR(1)  AS Tipo_Cliente,
					CHAR(40) AS Desc_Tipo_Cliente,
					DATE     AS Fecha_Nacimiento,
					CHAR(1)  AS Cve_Sexo,
					CHAR(2)  AS Cve_Tipo_Persona,
					CHAR(20) AS Desc_Tipo_Persona,
					DATE     AS Fecha_Alta,
					CHAR(4)  AS Sucursal,
					CHAR(3)  AS Plaza,
					CHAR(5)  AS Cve_Situacion,
					CHAR(75) AS Desc_Situacion,
					INTEGER  AS Secuencia,
					CHAR(40) AS Calle,
					CHAR(10) AS Numero_Exterior_Calle,
					CHAR(10) AS Numero_Interior_Calle,
					CHAR(6)  AS Departamento,
					CHAR(60) AS Colonia,
					CHAR(60) AS Municipio,
					CHAR(60) AS Ciudad,
					CHAR(30) AS Estado,
					CHAR(20) AS Pais,
					CHAR(5)  AS Codigo_Postal,
					CHAR(13) AS Telefono_1,
					CHAR(13) AS Telefono_2,
					CHAR(13) AS Telefono_3,
					CHAR (5) AS Extension,
					INTEGER  AS Nivel_Consulta,
					CHAR(60) AS Desc_Nivel_Consulta;


DEFINE vcodret 				CHAR(5);
DEFINE vciclo 				SMALLINT;
DEFINE vsqlerr 				INTEGER;
DEFINE iexiste_situacion 	INTEGER;



DEFINE cNumcliente 			CHAR(20);
DEFINE cNombre1 			CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApell_paterno 		CHAR(26);
DEFINE cApell_materno 		CHAR(26);
DEFINE cRazon_social		CHAR(60);
DEFINE cRfc 				CHAR(13);
DEFINE cTipo_cliente		CHAR(1);
DEFINE cDtipoCliente		CHAR(40);
DEFINE dfecha_nac			DATE;
DEFINE cSexo 				CHAR(1);
DEFINE ctpo_persona 		CHAR(2);
DEFINE cDtipo_persona		CHAR(20);
DEFINE dfecha_alta			DATE;
DEFINE csucursal			CHAR(4);
DEFINE dPlaza_cte			CHAR(3);
DEFINE cClave_situ			CHAR(5);
DEFINE cD_situacion			CHAR(75);
DEFINE cNivel_consulta		INTEGER;
DEFINE cDesc_Nivel_consulta	CHAR(60);

DEFINE vtipo_dir 			CHAR(1);
DEFINE vsecuencia 			INTEGER;
DEFINE vcalle 				CHAR(40);
DEFINE vnumeroextcalle  	CHAR(10);
DEFINE vnumerointcalle  	CHAR(10);
DEFINE vdepartamento  		CHAR(6);
DEFINE vcolonia 			CHAR(60);
DEFINE vmunicipio 			CHAR(60);
DEFINE vciudad 				CHAR(60);
DEFINE vestado 				CHAR(30);
DEFINE vpais 				CHAR(20);
DEFINE vcod_postal 			CHAR(5);
DEFINE vtelefono1 			CHAR(13);
DEFINE vtelefono2  			CHAR(13);
DEFINE vtelefono3  			CHAR(13);
DEFINE vextension 			CHAR(5);
DEFINE vpuntocardinal  		CHAR(1);
DEFINE vunidadhabitac  		CHAR(1);
DEFINE vmanzana 			CHAR(30);
DEFINE votros  				CHAR(30);
DEFINE vandador 			CHAR(30);
DEFINE vetapa 				CHAR(30);
DEFINE vlote  				CHAR(30);
DEFINE ventrada  			CHAR(30);
DEFINE vedificio  			CHAR(30);
DEFINE ventre_calles 		CHAR(80);
DEFINE vobservaciones 		CHAR(40);
DEFINE cNumcliente2			CHAR(20);
DEFINE errorSQL				CHAR(5);
DEFINE cCSitua_esp			CHAR(5);
DEFINE cSituacion_esp		CHAR(75);
DEFINE cSubcta          	CHAR(1);
DEFINE cTipo_Dom        	CHAR(15);
DEFINE dfecha_insert 		DATE;
DEFINE iKiosko				INT;

DEFINE iexiste 				INTEGER;
DEFINE  cNumero_cliente 	CHAR(20);
DEFINE cNumCtePrincipal 	CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cQuery 				CHAR(1500);
DEFINE cStatus 				CHAR(50);
DEFINE cProdDebito 			CHAR(200);
DEFINE cProdCredito 		CHAR(200);
DEFINE iCuentalong			INT;

LET vciclo 					= 0;
LET vcodret 				= "00000";
LET vsqlerr 				= 0;
LET iexiste 				= 0;
LET iexiste_situacion 		= 0;
LET cNumero_cliente 		= "";

LET vtipo_dir 				= "";
LET vsecuencia 				= 0 ;
LET vcalle 					= "";
LET vnumeroextcalle  		= "";
LET vnumerointcalle  		= "";
LET vdepartamento  			= "";
LET vcolonia 				= "";
LET vmunicipio 				= "";
LET vciudad 				= "";
LET vestado 				= "";
LET vpais 					= "";
LET vcod_postal  			= "";
LET vtelefono1  			= "";
LET vtelefono2   			= "";
LET vtelefono3   			= "";
LET vextension  			= "";
LET vpuntocardinal   		= "";
LET vunidadhabitac   		= "";
LET vmanzana 				= "";
LET votros  				= "";
LET vandador 				= "";
LET vetapa 					= "";
LET vlote  					= "";
LET ventrada  				= "";
LET vedificio  				= "";
LET ventre_calles 			= "";
LET vobservaciones 			= "";
LET cNumcliente 			= "";
LET cNombre1 				= "";
LET cNombre2 				= "";
LET cApell_paterno 			= "";
LET cApell_materno 			= "";
LET cRazon_social  			= "";
LET cRfc 					= "";
LET cTipo_cliente			= "";
LET cDtipoCliente			= "";
LET dfecha_nac				= "";
LET cSexo 					= "";
LET ctpo_persona 			= "";
LET cDtipo_persona			= "";
LET dfecha_alta				= "";
LET csucursal				= "";
LET dPlaza_cte				= "";
LET cClave_situ				= "";
LET cD_situacion			= "";
LET cNivel_consulta			= "";
LET cDesc_Nivel_consulta	= "";
LET cNumcliente2 			= "";
LET cCSitua_esp	 			= "";
LET cSituacion_esp 			= "";
LET cSubcta         		= "";
LET cTipo_Dom 				= "";
LET dfecha_insert 			= TODAY;
LET iTpo_cliente 			= 0;
LET cNumCtePrincipal 		= "";
LET iKiosko 				= 0;
LET cQuery 					= '';
LET cStatus 				= "";
LET cProdDebito 			= "";
LET cProdCredito 			= "";
LET iCuentalong				= 0;


BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			let vcodret = vsqlerr;
			RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consnumcte.out";
	--TRACE ON;

	IF 	cID_USUARIOC = ''	OR
		cID_FUNCIONC = ''	OR
		cTCONSULTA   = '' 	OR
		cTDOMICILIO  = ''	OR
		cTBUSQUEDA   = ''	THEN
		LET vcodret  = "00054";
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;
	
    IF cTCONSULTA NOT IN ('1','2','3','4','5') THEN
			LET vcodret = "00052";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
    END IF

	--VALIDACION
	IF cNUMCUENTA != '' THEN
        LET cSubcta=SUBSTR(TRIM(cNUMCUENTA),1,1);
		LET iCuentalong=LENGTH(cNUMCUENTA);
        IF iCuentalong=12 THEN
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'06','1')
            INTO
            vcodret;
		ELSE	
			IF cSubcta='3' THEN
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'03','1')
				INTO
				vcodret;
			ELIF cSubcta='8' THEN
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'01','1')
				INTO
				vcodret;
			ELSE
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'11','1')
				INTO
				vcodret;
			END IF;
		END IF;	
	END IF;

	IF cNUMCTE != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCTE,'11','2')
		INTO
		vcodret;
	END IF;

	IF cNUMTARJETA != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMTARJETA,'11','3')
		INTO
		vcodret;
	END IF;
	
	IF cNUMCUENTACLABE != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTACLABE,'00','7')
		INTO
		vcodret;
	END IF;
	
	IF (vcodret != '00000') THEN
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			   cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,
			   vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;
	
	-- TERMINA VALIDACION

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO vcodret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	 END IF;


	SELECT valor
	INTO cStatus
	FROM si_param
	WHERE cod_param = 338;

	SELECT valor
	INTO cProdDebito
	FROM si_param
	WHERE cod_param = 339;

	SELECT valor
	INTO cProdCredito
	FROM si_param
	WHERE cod_param = 340;


	IF cTCONSULTA  = '1' THEN
		IF cNUMCTE = '' OR  cNUMCTE IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF  cNUMCTE <> '' OR NOT cNUMCTE IS NULL THEN
			LET cNumero_cliente  = cNUMCTE;
		END IF
	ELIF cTCONSULTA  = '2' THEN
		IF cNUMCUENTA = '' OR  cNUMCUENTA IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMCUENTA  <> '' OR  NOT cNUMCUENTA IS NULL THEN
            IF LENGTH(TRIM(cNUMCUENTA))>11 THEN
				IF cID_FUNCIONC = 'SKI002' THEN
					LET cQuery = "SELECT LIMIT 1 numcte FROM bdicred:sd_maecred WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND num_producto IN ("||TRIM(cProdCredito)||")";
					LET cQuery = TRIM(cQuery)||" AND empresa = '001' UNION SELECT numcte FROM bdicred:sd_maecredcrd WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND";
					LET cQuery = TRIM(cQuery)||" num_producto IN ("||TRIM(cProdCredito)||") AND empresa = '001'";
					PREPARE stmtId FROM TRIM(cQuery);
					DECLARE custCur CURSOR FOR stmtId;
					OPEN custCur;
					FETCH custCur INTO cNumero_cliente;
					CLOSE custCur;
					FREE custCur;
					FREE stmtId;
					IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
						LET vcodret = "00361";
						RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
						cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
						vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
					END IF;
				ELSE
					FOREACH
						SELECT LIMIT 1 numcte INTO cNumero_cliente
						FROM bdicred:sd_maecred
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT numcte
						FROM bdicred:sd_maecredcrd
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
				   END FOREACH;
				END IF;
            ELSE
                IF cSubcta='3' THEN
                    SELECT LIMIT 1 num_cte INTO cNumero_cliente
                    FROM bdinvers:sv_maeinv
                    WHERE cuenta = cNUMCUENTA AND empresa = '001';
                ELSE
					IF cID_FUNCIONC = 'SKI002' THEN
						LET cQuery = "SELECT LIMIT 1 num_cte FROM bdicheq:sc_maechq WHERE cuenta = '"||TRIM(cNUMCUENTA)||"' AND producto IN ("||TRIM(cProdDebito)||")";
						LET cQuery = TRIM(cQuery)||" AND status_cta NOT IN ("||TRIM(cStatus)||") AND empresa = '001'";
						PREPARE stmtId FROM TRIM(cQuery);
						DECLARE custCur CURSOR FOR stmtId;
						OPEN custCur;
						FETCH custCur INTO cNumero_cliente;
						CLOSE custCur;
						FREE custCur;
						FREE stmtId;
						IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
							LET vcodret = "00361";
							RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
							cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
							vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
						END IF;
					ELSE
						FOREACH
						SELECT num_cte INTO  cNumero_cliente
						FROM bdicheq:sc_maechq
						WHERE cuenta = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT CASE WHEN iTpo_cliente = 2 THEN numcte_tf ELSE numcte END
						FROM bditransfer:tf_maecte
						WHERE cuenta_tf = cNUMCUENTA AND empresa = '001'
						END FOREACH;
					END IF;
                END IF;
			end if;
		END IF
	ELIF cTCONSULTA = '3' THEN
		IF cNUMTARJETA = '' OR  cNUMTARJETA IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMTARJETA <> '' OR  NOT cNUMTARJETA IS NULL  THEN
			IF cID_FUNCIONC = 'SKI002' THEN
				FOREACH
				SELECT NVL(numcte,0) INTO  cNumero_cliente
                FROM bdicred:sd_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				UNION
				SELECT NVL(numcte,0)
                FROM bdicheq:sc_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				END FOREACH;
				IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
					LET vcodret = "00362";
					RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
				END IF;
			ELSE
		        SELECT NVL(numcte,0) INTO  cNumero_cliente
                FROM bdicred:sd_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;

                IF cNumero_cliente='0' OR cNumero_cliente IS NULL THEN
                    SELECT NVL(numcte,0) INTO  cNumero_cliente
                    FROM bdicheq:sc_tarjeta
                    WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;
                END IF;
			END IF;
		END IF
	ELIF cTCONSULTA = '4' THEN  -- Consulta por numero de telefono
		IF cNUMTELEFONO = '' OR  cNUMTELEFONO IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF  cNUMTELEFONO <> '' OR NOT cNUMTELEFONO IS NULL THEN
			SELECT num_cte
			INTO cNumero_cliente
			FROM bdicheq:'informix'.sc_cuenta_telefono
			WHERE telefono = cNUMTELEFONO;
			
			IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
				LET vcodret = "00318";
				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
			END IF;
		END IF
	ELIF cTCONSULTA  = '5' THEN
		IF cNUMCUENTACLABE = '' OR  cNUMCUENTACLABE IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMCUENTACLABE  <> '' OR  NOT cNUMCUENTACLABE IS NULL THEN
            
			FOREACH
				SELECT num_cte INTO  cNumero_cliente
				FROM bdicheq:sc_maechq
				WHERE cuenta_clabe = cNUMCUENTACLABE AND empresa = '001'
				UNION
				SELECT CASE WHEN iTpo_cliente = 2 THEN numcte_tf ELSE numcte END
				FROM bditransfer:tf_maecte
				WHERE cta_clabe = cNUMCUENTACLABE AND empresa = '001'
				UNION
				SELECT numcte 
				FROM bdicred:sd_maecred
				WHERE cuenta_clabe = cNUMCUENTACLABE AND empresa = '001'
				UNION
				SELECT numcte 
				FROM bdicred:sd_maecredcrd
				WHERE cuenta_clabe = cNUMCUENTACLABE AND empresa = '001'
			END FOREACH;
		END IF
	ELIF cNUMCTE = '' OR  cNUMCTE IS NULL AND cNUMTARJETA  = '' OR cNUMTARJETA IS NULL AND cNUMTARJETA = ''  OR cNUMTARJETA IS NULL AND cNUMTELEFONO = ''  OR cNUMTELEFONO IS NULL THEN
		LET vcodret = "00054";
		RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF

	FOREACH
		SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001'
		UNION
		SELECT NVL(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE numcte_tf = cNumero_cliente
		ORDER BY 1 DESC
	END FOREACH;
	IF iexiste = 0 THEN
		IF cID_FUNCIONC = 'CLI352' THEN
			SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente;

			IF iexiste_situacion >= 1 THEN
				SELECT SC.situacion||SC.causa,CS.descripcion
				INTO cCSitua_esp, cSituacion_esp
				FROM bdinteg:si_fusctessitespcte SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente);

			ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN

				SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
				SC.situacion||SC.causa,CS.descripcion
				INTO cCSitua_esp, cSituacion_esp
				FROM bdisitesp:se_ctessitespcred SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmvto=(select--+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
				max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
			END IF;
			FOREACH
				SELECT  CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno, CL.tipo_cliente,
				TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_alta,CL.sucursal,SU.plaza, cCSitua_esp,
				cSituacion_esp
				INTO cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
				FROM si_fuscliente CL
				LEFT JOIN si_tipocte TP
				ON TP.tipo_cliente = CL.tipo_cliente
				LEFT JOIN si_fusctepf PF
				ON PF.numcte = CL.numcte
				LEFT JOIN bdinteg:si_fusctessitespcte SC
				ON SC.numcte = CL.numcte
				LEFT JOIN si_sucursales SU
				ON SU.sucursal = CL.sucursal
				LEFT JOIN si_tipper TE
				ON TE.tpo_persona = CL.tpo_persona
				WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'

				SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
				WHERE numcte=cNumero_cliente;

				IF cNivel_consulta IS NULL THEN
					LET cNivel_consulta=9;
				END IF;

				LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;

				IF cRfc='' OR cRfc IS NULL THEN
					SELECT rfc INTO cRfc FROM si_fuscliente WHERE numcte = cNumero_cliente AND empresa = '001';
				END IF;

				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;

			/*FOREACH
				EXECUTE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1)
				INTO errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana,
					votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert

				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;*/
		ELSE
			IF cTCONSULTA  = '5' THEN
				LET vcodret = "99999";
			ELSE
				LET vcodret = "00055";
			END IF;
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		END IF;
	END IF;
	SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente;


	IF iexiste_situacion >= 1 THEN
		SELECT SC.situacion||SC.causa,CS.descripcion
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcte SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente);

	ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
	NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN

		SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		SC.situacion||SC.causa,CS.descripcion
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcred SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmvto=(select --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
	END IF

	FOREACH
	SELECT FIRST 1 CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno, CL.tipo_cliente,
	TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_alta,CL.sucursal,SU.plaza, cCSitua_esp,
	cSituacion_esp
	INTO
	cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
	FROM si_cliente CL
	LEFT JOIN si_tipocte TP
	ON TP.tipo_cliente = CL.tipo_cliente
	LEFT JOIN si_ctepf PF
	ON PF.numcte = CL.numcte
	LEFT JOIN bdisitesp:se_ctessitespcte SC
	ON SC.numcte = CL.numcte
	LEFT JOIN si_sucursales SU
	ON SU.sucursal = CL.sucursal
	LEFT JOIN si_tipper TE
	ON TE.tpo_persona = CL.tpo_persona
	WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'
	UNION
	SELECT TF.numcte_tf, TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc,'1',
	'CLIENTE', TF.fecha_nac,'','01','FISICA',TF.fec_alta,'','',cCSitua_esp,
	cSituacion_esp
	FROM bditransfer:tf_maecte TF
	WHERE TF.numcte_tf = cNumero_cliente AND TF.empresa = '001'
	END FOREACH;

    SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
    WHERE numcte=cNumero_cliente;

    IF cNivel_consulta IS NULL THEN
        LET cNivel_consulta=9;
    END IF;

    LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;

    IF cRfc='' OR cRfc IS NULL THEN
        SELECT rfc INTO cRfc FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
    END IF;

	SET ISOLATION TO DIRTY READ;
	FOREACH
	EXECUTE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1)
	INTO
	errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana,
	votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert


	RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
	END FOREACH;
END
END PROCEDURE
DOCUMENT
"Autor : Antonio Flores",
"FECHA : 2/enero/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda los datos del cliente",
"haciendo un llamado el SP sp_cnsif_consdirec traera los datos de domicilio de dicho cliente",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"Autor : Oscar Flores Conde",
"FECHA : 26/noviembre/2015",
"FUNCIONAMIENTO: Se agrega busqueda por numero movil",
"Ver.  : 1.2",
"BD    : bdinteg",
"VER   : 1.2",
"Autor : Johnattan Esquivel SÃ¡nchez",
"FECHA : 03/Marzo/2020",
"FUNCIONAMIENTO: Se agrega busqueda por cuenta CLABE",
"Ver.  : 1.3",
"BD    : bdinteg",
"VER   : 1.3";

CREATE PROCEDURE "informix".sp_ws_afore_ctes(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pNumCte CHAR(20))

RETURNING CHAR(5) AS cCodRet,CHAR(4) AS cOpcode,CHAR(100) AS cDescr_completa_mensaje,CHAR(8) AS cFecha_proceso,CHAR(6) AS cHora_proceso
,CHAR(18) AS cCurp,CHAR(26) AS cApellPaterno,CHAR(26) AS cApellMaterno,CHAR(52) AS cNombres,CHAR(13) AS cRfc,DATE AS dFechaNac
,CHAR(2) AS cEntidadNac,CHAR(1) AS cSexo,CHAR(3) AS cNacionalidad,CHAR(2) AS cEdoCivil,CHAR(20) AS cNumCte,CHAR(2) AS cEscolaridad
,CHAR(4) AS cProfesion,CHAR(30) AS cActividad,CHAR(10) AS cTel1,CHAR(10) AS cTel2,CHAR(100) AS cEmail,CHAR(30) AS cCalle1,CHAR(10) AS cNumExt1
,CHAR(10) AS cNumInt1,CHAR(5) AS cCodPostal1,CHAR(32) AS cColonia1,CHAR(11) AS iCiudad1,CHAR(5) AS cMunicipio1,CHAR(2) AS cEstado1,CHAR(3) AS cPais1
,CHAR(30) AS cCalle2,CHAR(10) AS cNumExt2,CHAR(10) AS cNumInt2,CHAR(5) AS cCodPostal2,CHAR(32) AS cColonia2,CHAR(11) AS iCiudad2,CHAR(5) AS cMunicipio2
,CHAR(2) AS cEstado2,CHAR(3) AS cPais2,CHAR(26) AS cApellPaternoRef1,CHAR(26) AS cApellMaternoRef1,CHAR(52) AS cNombresRef1,CHAR(26) AS cApellPaternoRef2
,CHAR(26) AS cApellMaternoRef2,CHAR(52) AS cNombresRef2,CHAR(4) AS cCodDoctoAnv,CHAR(4) AS iSecuenciaAnv,CHAR(4) AS cCodDoctoRev,CHAR(4) AS iSecuenciaRev;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje        CHAR(200);
DEFINE cCodRet 			CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(255);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_proceso	CHAR(17);
DEFINE cCod_retorno		CHAR(5);
DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;

--definicion de Variables de consulta de informacion
DEFINE cNombre CHAR(40);
DEFINE iBan INTEGER;
DEFINE cMultiImg CHAR(1);
DEFINE cCurp CHAR(18);
DEFINE cApellPaterno CHAR(26);
DEFINE cApellMaterno CHAR(26);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cNombres	CHAR(52);
DEFINE cRfc CHAR(13);
DEFINE dFechaNac DATE;
DEFINE cEntidadNac CHAR(2);
DEFINE cSexo CHAR(1);
DEFINE cNacionalidad CHAR(3);
DEFINE cEdoCivil CHAR(2);
DEFINE cNumCte CHAR(20);
DEFINE cEscolaridad CHAR(2);
DEFINE cProfesion CHAR(4);
DEFINE cActividad CHAR(30);
DEFINE cTel1 CHAR(10);
DEFINE cTel2 CHAR(10);
DEFINE cEmail CHAR(100);
DEFINE cCalle1 CHAR(30);
DEFINE cNumExt1 CHAR(10);
DEFINE cNumInt1 CHAR(10);
DEFINE cCodPostal1 CHAR(5);
DEFINE cColonia1 CHAR(32);
DEFINE cMunicipio1 CHAR(5);
DEFINE iCiudad1	SMALLINT;
DEFINE cEstado1 CHAR(2);
DEFINE cPais1 CHAR(3);
DEFINE cCalle2 CHAR(30);
DEFINE cNumExt2 CHAR(10);
DEFINE cNumInt2 CHAR(10);
DEFINE cCodPostal2 CHAR(5);
DEFINE cColonia2 CHAR(32);
DEFINE cMunicipio2 CHAR(5);
DEFINE iCiudad2	SMALLINT;
DEFINE cEstado2 CHAR(2);
DEFINE cPais2 CHAR(3);
DEFINE cApellPaternoRef1 CHAR(26);
DEFINE cApellMaternoRef1 CHAR(26);
DEFINE cNombresRef1 CHAR(52);
DEFINE cNombre1Ref1 CHAR(26);
DEFINE cNombre2Ref1 CHAR(26);
DEFINE cApellPaternoRef2 CHAR(26);
DEFINE cApellMaternoRef2 CHAR(26);
DEFINE cNombre1Ref2 CHAR(26);
DEFINE cNombre2Ref2 CHAR(26);
DEFINE cNombresRef2 CHAR(52);
DEFINE cNomBene1 CHAR(40);
DEFINE cNomBene2 CHAR(40);
DEFINE cCodDoctoAnv CHAR(4);
DEFINE iSecuenciaAnv CHAR(4);
DEFINE cCodDoctoRev CHAR(4);
DEFINE iSecuenciaRev CHAR(4);
DEFINE cPuesto INTEGER;
DEFINE cSubPuesto INTEGER;
DEFINE cCodDocto CHAR(4);
DEFINE iSecuencia SMALLINT;
DEFINE cDescrip2 CHAR(30);
DEFINE sFlag INTEGER;



--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '0000';
LET cOpcode = '0000';
LET cDescr_mensaje = 'Consulta Exitosa.';
LET cDescr_completa_mensaje = 'Consulta Exitosa.';


LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));

LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_proceso = 'sp_ws_afore_cctes';
LET cCod_retorno  = '';
LET cFecha_dia    = '';
LET dtFecha_dia   = CURRENT::DATE;
LET vsMensaje     = '';


--Inicializacion de Variables de consulta de informacion
LET cNombre = '';
LET iBan = 0;
LET cMultiImg = '';
LET cCodRet = '0000';
LET cCurp = '';
LET cApellPaterno = '';
LET cApellMaterno = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET cNombres = '';
LET cRfc = '';
LET dFechaNac = DATE(1);
LET cEntidadNac = '';
LET cSexo = '';
LET cNacionalidad = '';
LET cEdoCivil = '';
LET cNumCte = '';
LET cEscolaridad = '';
LET cProfesion = '';
LET cActividad = '';
LET cTel1 = '';
LET cTel2 = '';
LET cEmail = '';
LET cCalle1 = '';
LET cNumExt1 = '';
LET cNumInt1 = '';
LET cCodPostal1 = '';
LET cColonia1 = '';
LET cMunicipio1 = '';
LET iCiudad1 = 0;
LET cEstado1 = '';
LET cPais1 = '';
LET cCalle2 = '';
LET cNumExt2 = '';
LET cNumInt2 = '';
LET cCodPostal2 = '';
LET cColonia2 = '';
LET cMunicipio2 = '';
LET iCiudad2 = 0;
LET cEstado2 = '';
LET cPais2 = '';
LET cApellPaternoRef1 = '';
LET cApellMaternoRef1 = '';
LET cNombre1Ref1 = '';
LET cNombre2Ref1 = '';
LET cNombresRef1 = '';
LET cApellPaternoRef2 = '';
LET cApellMaternoRef2 = '';
LET cNombre1Ref2 = '';
LET cNombre2Ref2 = '';
LET cNombresRef2 = '';
LET cNomBene1 = '';
LET cNomBene2 = '';
LET cCodDoctoAnv = '';
LET iSecuenciaAnv = 0;
LET cCodDoctoRev = '';
LET iSecuenciaRev = 0;
LET cPuesto = 0;
LET cSubPuesto = 0;
LET iSecuencia = 0;
LET cCodDocto = '';
LET cDescrip2 = '';
LET sFlag = 0;


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		--SET DEBUG FILE TO '/tmp/cristo/sps/sp_ws_afore_cctes.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
		
			IF iSqlErr = '-1213' THEN --Se controla error al ingresar una palabra como numero de cliente 
				LET cCodRet = '9995';
				LET cOpcode = cCodRet;
			
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

				IF cOpcode IS NULL THEN
					LET cOpcode = cCodRet;
					LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
			
			ELSE 
				LET cCodRet = iSqlErr;
				LET cOpcode = cCodRet;

				LET cDescr_mensaje = '';
				LET cDescr_completa_mensaje = '';

			END IF;
			
			INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
			VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);


			RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cCurp , ''),NVL(cApellPaterno , ''),NVL(cApellMaterno , ''),NVL(cNombres, ''),NVL(cRfc , ''),
			NVL(dFechaNac, DATE(1)),NVL(cEntidadNac , ''),NVL(cSexo , ''),NVL(cNacionalidad , ''),NVL(cEdoCivil , ''),NVL(cNumCte , ''),NVL(cEscolaridad , ''),
			NVL(cProfesion , ''),NVL(cActividad , ''),NVL(cTel1 , ''),NVL(cTel2 , ''),NVL(cEmail , ''),NVL(cCalle1 , ''),NVL(cNumExt1 , ''),NVL(cNumInt1 , ''),
			NVL(cCodPostal1 , ''),NVL(cColonia1 , ''),NVL(iCiudad1 , 0)::CHAR(11),NVL(cMunicipio1 , ''),NVL(cEstado1 , ''),NVL(cPais1 , ''),NVL(cCalle2 , ''),NVL(cNumExt2 , ''),NVL(cNumInt2 , ''),
			NVL(cCodPostal2 , ''),NVL(cColonia2 , ''),NVL(iCiudad2 , 0)::CHAR(11),NVL(cMunicipio2 , ''),NVL(cEstado2 , ''),NVL(cPais2 , ''),NVL(cApellPaternoRef1 , ''),NVL(cApellMaternoRef1 , ''),
			NVL(cNombresRef1, ''),NVL(cApellPaternoRef2 , ''),NVL(cApellMaternoRef2 , ''),NVL(cNombresRef2, ''),NVL(cCodDoctoAnv , ''),NVL(iSecuenciaAnv,0),NVL(cCodDoctoRev , ''),NVL(iSecuenciaRev,0);


		END IF;
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/tmp/cristo/sps/sp_ws_afore_cctes.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' OR NVL(pcSession_id, '') = '' OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' OR NVL(pNumCte, '') = '' THEN
		LET cCodRet = '9996';

	ELSE
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND  usuario=trim(pcusuario) AND activa = 'S' ) THEN

			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT  agent_cd,usuario,password,ip_origen,id_sesion_act
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and usuario=trim(pcusuario);

            SELECT fecha_hoy
            INTO dtFecha_dia
            FROM bdisac:"informix".sac_fechas
			where empresa = '001';

 			LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');

			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
											IF pNumCte::integer > 0  THEN 
											
													LET cNumCte = LPAD(TRIM(pNumCte),9,'0');
													
													SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
													INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
													FROM bdisac:"informix".sac_ws_catmensajes
													WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

													IF cOpcode IS NULL THEN
														LET cOpcode = cCodRet;
														LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
														LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
													END IF;
													
													--Se obtienen datos personales del cliente
													SELECT pf.curp,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,cte.rfc,pf.fecha_nac,pf.lugar_nac,pf.sexo,pf.nacionalidad,pf.estado_civil,
													cte.numcte,pf.escolaridad,pf.actividadogiro
													INTO cCurp,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,
													cActividad
													FROM bdinteg:"informix".si_cliente cte,bdinteg:"informix".si_ctepf pf
													WHERE pf.numcte = cte.numcte
													AND cte.numcte = cNumCte;
													
													--Valida que exista el cliente
													IF NVL(cNumCte, '') <> '' THEN
													
														--Se arma el campo nombres
														LET cNombres = TRIM(TRIM(NVL(cNombre1,'')) || " " || TRIM(NVL(cNombre2,'')));
														
														--Obtiene el telefono celular del cliente
														SELECT FIRST 1 telefono
														INTO cTel1
														FROM bdinteg:"informix".si_telefonos_actual
														WHERE numcte = cNumCte
														AND tipo_tel = 2
														AND status_tel = 'A'
														AND secuencia IN(SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumCte AND status_tel = 'A' AND tipo_tel = 2);
														
														--Obtiene el telefono fijo del cliente
														SELECT FIRST 1 telefono
														INTO cTel2
														FROM bdinteg:"informix".si_telefonos_actual
														WHERE numcte = cNumCte
														AND tipo_tel = 1
														AND status_tel = 'A'
														AND secuencia IN(SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumCte AND status_tel = 'A' AND tipo_tel = 1);
														
														--Obtiene el correo del cliente
														SELECT FIRST 1 NVL(correo_elec, ' ')
														INTO cEmail
														FROM bdinteg:"informix".si_correos
														WHERE empresa = '001'
														AND numcte = cNumCte
														AND status_correo = 'A'
														AND secuencia IN (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa = '001' AND numcte = cNumCte AND status_correo = 'A');
														
														--Obtiene Ocupacion 
														SELECT FIRST 1 NVL(claveopcionpuesto,'')||NVL(clavesubopcionpuesto,'') INTO cProfesion 
														FROM bdinteg:"informix".si_ingresos 
														WHERE numcte = cNumCte 
														AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = cNumCte);
														
														--Obtiene direccion de la casa del cliente
														SELECT FIRST 1 ca.nombrecalle,dr.numeroextcalle,dr.numerointcalle,dr.cod_postal,NVL(zo.nombrezona,''),dr.numerociudad,dr.municipio,dr.estado,dr.pais
														INTO cCalle1,cNumExt1,cNumInt1,cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1
														FROM bdinteg:"informix".si_direcciones_actual AS dr 
														INNER JOIN bdinteg:"informix".si_catcalles AS ca ON dr.numerocalle = ca.numerocalle
														INNER JOIN bdinteg:"informix".si_catzonas AS zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia
														WHERE ca.numerocalle = dr.numerocalle
														AND dr.tipo_dir = 1
														AND dr.numcte = cNumCte;
														
														
														--Obtiene direccion del trabajo del cliente
														SELECT FIRST 1 ca.nombrecalle,dr.numeroextcalle,dr.numerointcalle,dr.cod_postal,NVL(zo.nombrezona,''),dr.numerociudad,dr.municipio,dr.estado,dr.pais
														INTO cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2
														FROM bdinteg:"informix".si_direcciones_actual dr
														INNER JOIN bdinteg:"informix".si_catcalles AS ca ON dr.numerocalle = ca.numerocalle
														INNER JOIN bdinteg:"informix".si_catzonas AS zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia
														WHERE ca.numerocalle = dr.numerocalle
														AND dr.tipo_dir = 2
														AND dr.numcte = cNumCte;
														
														
														--Obtiene referencia 1
														SELECT FIRST 1 apell_paterno,apell_materno,nombre1, nombre2
														INTO  cApellPaternoRef1,cApellMaternoRef1,cNombre1Ref1,cNombre2Ref1
														FROM bdinteg:"informix".si_refclientes
														WHERE numcte = cNumCte 
														AND secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = cNumCte AND parentesco = 'E') 
														AND parentesco = 'E';
														
														
														IF dbinfo("sqlca.sqlerrd2") = 1 THEN
															--Se arma el campo nombres
															LET cNombresRef1 = TRIM(TRIM(NVL(cNombre1Ref1,'')) || " " || TRIM(NVL(cNombre2Ref1,'')));
														END IF;
														
														--Obtiene referencia 2
														SELECT FIRST 1 apell_paterno,apell_materno,nombre1, nombre2
														INTO cApellPaternoRef2,cApellMaternoRef2,cNombre1Ref2,cNombre2Ref2
														FROM bdinteg:"informix".si_refclientes
														WHERE empresa = '001' 
														AND numcte = cNumCte 
														AND secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refclientes WHERE numcte = cNumCte AND parentesco <> 'E') 
														AND parentesco <> 'E';
														
														IF dbinfo("sqlca.sqlerrd2") = 1 THEN
															--Se arma el campo nombres
															LET cNombresRef2 = TRIM(TRIM(NVL(cNombre1Ref2,'')) || " " || TRIM(NVL(cNombre2Ref2,'')));
														END IF;
														
														--Valida si existen referencias
														IF NVL(cNombre1Ref1 , '') = '' AND NVL(cNombre1Ref2 , '') = '' THEN
															--Obtiene beneficiarios en caso de no contar con referencias
															/*FOREACH
																SELECT LIMIT 2 nombre INTO cNombre FROM bdicheq:"informix".sc_beneficiario where numcte = cNumCte
																IF iBan = 0 THEN
																	LET cNombresRef1 = '';
																	LET iBan = 1;
																ELSE
																	LET cNombresRef2 = '';
																END IF;
															END FOREACH;
															*/
															LET cNombresRef1 = '';
															LET cNombresRef2 = '';
															
														END IF;
														
														--Obtiene documento digitalizado  o el anverso en caso de contar con dos imagenes
														FOREACH SELECT limit 2 xp.cod_docto,xp.secuencia,xp.descrip2
															INTO cCodDocto,iSecuencia,cDescrip2
															FROM bdidigital@coppelimg_tcp:dg_expediente xp, bdidigital@coppelimg_tcp:dg_tipodocumento doc 
															WHERE xp.cliente = cNumCte    
															AND xp.cod_docto = doc.cod_docto 
															AND xp.cod_docto = '0001'
															AND doc.cod_grupo = '001' 
															AND xp.producto = '9999'
															AND xp.descrip2 IN ('','anverso','reverso')
															order by xp.secuencia DESC
															
															LET sFlag = sFlag +1;
															
															IF TRIM(NVL(cDescrip2,''))= 'anverso' or (sFlag = 2 AND TRIM(NVL(cDescrip2,''))= '') THEN 
																LET cCodDoctoAnv = cCodDocto;
																LET iSecuenciaAnv = iSecuencia;
															ELIF TRIM(NVL(cDescrip2,''))= 'reverso' or (sFlag = 1 AND TRIM(NVL(cDescrip2,''))= '') THEN
																LET cCodDoctoRev = cCodDocto;
																LET iSecuenciaRev = iSecuencia;				
															END IF
														END FOREACH;

														LET cCodRet = '0000';
														
														INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
														VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);
														
														
													ELSE
														LET cCodRet = '0007';
													END IF;
											ELSE
												LET cCodRet = '9995';
											END IF;
									ELSE
										LET cCodRet = '9977';
									END IF;
							ELSE
								LET cCodRet = '9975';
							END IF;
						ELSE
							LET cCodRet = '9976';
						END IF;
					ELSE
						LET cCodRet = '9979';
					END IF;
				ELSE
					LET cCodRet = '9980';
				END IF;
			ELSE
				LET cCodRet = '9998';
			END IF;
		ELSE
			LET cCodRet = '9999';
		END IF;
	END IF;
	
	IF cCodRet <> '0000' THEN	
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		
		INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
		VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);

	END IF;
	
	
	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cCurp , ''),NVL(cApellPaterno , ''),NVL(cApellMaterno , ''),NVL(cNombres, ''),NVL(cRfc , ''),
	NVL(dFechaNac, DATE(1)),NVL(cEntidadNac , ''),NVL(cSexo , ''),NVL(cNacionalidad , ''),NVL(cEdoCivil , ''),NVL(cNumCte , ''),NVL(cEscolaridad , ''),
	NVL(cProfesion , ''),NVL(cActividad , ''),NVL(cTel1 , ''),NVL(cTel2 , ''),NVL(cEmail , ''),NVL(cCalle1 , ''),NVL(cNumExt1 , ''),NVL(cNumInt1 , ''),
	NVL(cCodPostal1 , ''),NVL(cColonia1 , ''),NVL(iCiudad1 , 0)::CHAR(11),NVL(cMunicipio1 , ''),NVL(cEstado1 , ''),NVL(cPais1 , ''),NVL(cCalle2 , ''),NVL(cNumExt2 , ''),NVL(cNumInt2 , ''),
	NVL(cCodPostal2 , ''),NVL(cColonia2 , ''),NVL(iCiudad2 , 0)::CHAR(11),NVL(cMunicipio2 , ''),NVL(cEstado2 , ''),NVL(cPais2 , ''),NVL(cApellPaternoRef1 , ''),NVL(cApellMaternoRef1 , ''),
	NVL(cNombresRef1, ''),NVL(cApellPaternoRef2 , ''),NVL(cApellMaternoRef2 , ''),NVL(cNombresRef2, ''),NVL(cCodDoctoAnv , ''),NVL(iSecuenciaAnv,0),NVL(cCodDoctoRev , ''),NVL(iSecuenciaRev,0);

END;
END PROCEDURE;