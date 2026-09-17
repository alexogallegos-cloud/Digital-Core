CREATE PROCEDURE "informix".sp_cons_cta_captacion (pEmpresa CHAR(3),pNumCte CHAR(20),pNumCta CHAR(20))
	--DATOS A REGRESAR
	RETURNING 
	CHAR(6) AS cod_ret;
--============= DEFINIR VARIABLES =============
	DEFINE cod_ret CHAR(6);
	DEFINE sql_err SMALLINT;
	DEFINE isam_err SMALLINT;
	DEFINE error_info CHAR(40);
	DEFINE cCuenta CHAR(20);
--============= INICIALIZAR VARIABLES ===========
	LET cod_ret = '000000';
	LET cCuenta = '';
--==================================================
BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cod_ret = sql_err;
		RETURN  cod_ret;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	-- SET DEBUG FILE TO "/respaldosbd/Judith/sp_cons_cta_captacion.out";
	-- TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumCta,'') = '' THEN
		LET cod_ret = '000001';
	END IF;

	If cod_ret = '000000' THEN
		-- Validar que el producto exista
		SELECT cuenta 
		into cCuenta
		FROM bdicheq:"informix".sc_maechq 
		WHERE empresa = pEmpresa AND num_cte = pNumCte and cuenta = pNumCta AND status_cta = '1';
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cod_ret = '000002';
		END IF;
		
	END IF;

	RETURN  cod_ret;
END;
END PROCEDURE
DOCUMENT 
'Folio: 180',
'Autor: 97893323 Judith Moreno Zazueta',
'Fecha: 28/06/2017',
'Modificación: Crear procedimiento el cual consulte si el producto de captacion existe.',
'Sustento: basado en el requerimiento RQM 06 425-2 Búsqueda de Cuenta y RQM 06 531 Implementar Búsqueda de Clientes',
'Solicita: Abrham Narvaez',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_valida_status(pEmpresa CHAR(3),pCuenta  CHAR(20),pNumCte CHAR(20))
	RETURNING
	CHAR(5) AS CodRet,
	CHAR(5) AS CodRet2,
	CHAR(1) AS Estatus,
	CHAR(2) AS Motivo,
	CHAR(40) AS Descripcion;

	-- VARIABLES --
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRet2 CHAR(5);
	DEFINE cMotivo CHAR(2);
	DEFINE cDescripcion CHAR(40);
	DEFINE cDescripcionAux CHAR(40);
	DEFINE iSql_err INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cStatus_cta CHAR(1);
	DEFINE cSecuencia CHAR(6);
	DEFINE cProducto CHAR(4);
	
	-- INICIALIZACION DE VARIABLES --
	LET cCodRet ='00000';
	LET cCodRet2 ='00000';
	LET cMotivo='';
	LET cDescripcion ='';
	LET cDescripcionAux ='';
	LET iSql_err =0;
	LET iIsamErr =0;
	LET cProducto='';
	LET cStatus_cta ='';
	LET cSecuencia ='';
	
BEGIN

    ON EXCEPTION SET iSql_err,iIsamErr
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet,cCodRet2,cStatus_cta,cMotivo,cDescripcion;
        END IF;
    END EXCEPTION;  
	
	--SET DEBUG FILE TO "/respaldosbd/mario/sp_valida_status.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	IF NVL(pEmpresa,'') <> '' AND NVL(pCuenta,'') <> '' AND NVL(pNumCte,'') <> '' THEN
	
		
			SELECT status_cta, motivo,producto INTO cStatus_cta,cMotivo,cProducto FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta = pCuenta;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet2 = '00100';
			ELSE
				IF cProducto <> '1100' THEN
					SELECT max(secuencia)  INTO cSecuencia FROM bdicheq:"informix".sc_firmantes WHERE empresa = pEmpresa AND  numcte = pNumCte AND cuenta = pCuenta;
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN					
						SELECT a.secuencia INTO cSecuencia FROM  bdicheq:"informix".sc_firmantes a, bdicheq:"informix".sc_maeinstrucc b 
						WHERE b.cuentadep = pCuenta AND a.cuenta = b.cuenta AND a.numcte = pNumCte;
						IF cSecuencia = '1' OR cSecuencia = '2' OR cSecuencia = '3' THEN
							LET cCodRet2 = '00002';
						ELSE
							LET cCodRet2 = '00003';
						END IF;
					END IF;
					
					IF cCodRet2 = '00000' OR cCodRet2 = '00002' THEN
						IF cStatus_cta = '1' AND (cSecuencia = '1' OR cSecuencia = '2' OR cSecuencia = '3') THEN							
						ELIF cStatus_cta = '2' THEN
							SELECT descripcion INTO cDescripcion FROM bdicheq:"informix".sc_motivocancel WHERE clave = CAST(cMotivo AS INTEGER);
							IF cMotivo = '13' OR cMotivo = '02' OR NVL(cMotivo,'') = '' THEN
									LET cCodRet2 ='00004';
									IF cMotivo = '13'  THEN
										LET cDescripcionAux ='CANCELADA ' || cDescripcion;
						ELIF cStatus_cta = '2' and cMotivo = '' then
                          LET cCodRet2 ='00004';						---
						LET cDescripcionAux ='CANCELADA '; ---
									ELSE
										LET cDescripcionAux ='CANCELADA POR ' || cDescripcion;
									END IF;
									LET cDescripcion = cDescripcionAux;
							ELSE
									LET cCodRet2 ='00005';
									LET cDescripcion ='CANCELADA por oficina central';
							END IF;
						ELIF cStatus_cta = '3' THEN
							SELECT descripcion INTO cDescripcion FROM bdicheq:"informix".sc_bloqueo WHERE codigo = CAST(cMotivo AS INTEGER);
							IF cMotivo = '02' OR cMotivo = '51' OR cMotivo = '52'  THEN
									LET cCodRet2 ='00006';
									IF cMotivo = '51' THEN
										LET cDescripcionAux ='BLOQUEADA ' || cDescripcion;
									ELSE
										LET cDescripcionAux ='BLOQUEADA POR ' || cDescripcion;
									END IF;
									LET cDescripcion = cDescripcionAux;
							ELSE
									LET cCodRet2 ='00007';
									LET cDescripcion ='BLOQUEADA por oficina central';
							END IF;
						ELIF CAST(cStatus_cta AS INTEGER) >= 4 AND CAST(cStatus_cta AS INTEGER) <= 8 THEN
							SELECT descripcion INTO cDescripcion FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cStatus_cta;
							LET cCodRet2 ='00008';
						END IF;
					END IF;
					
				ELSE
					LET cCodRet2 ='00001';
				END IF;
			END IF;
	ELSE
		LET cCodRet2 = '00086';
	END IF;
	
	RETURN cCodRet,cCodRet2,cStatus_cta,cMotivo,cDescripcion;
	
END;
END PROCEDURE
DOCUMENT
"Folio: 1691",
"Autor:951421354 Mario Gallardo",
"Fecha: 17/02/2015",
"Modificación: Se creo procedimiento para validar el estatus de las cuentas de inversion ",
"Sustento: RQM 06 255 Liquidación de Inversion Creciente PDF.pdf",
"Solicita: Christ Alonso Armenta",
"BD: bdicheq ",
"---------------------------------------------------------------------------------------------",
"Folio: 180",
"Autor:97247642 Alexis Ibarra",
"Fecha: 29/06/2017",
"Modificación: Se modifico la validacion cStatus_cta para que se compare si es mayor o igual a 4 y menor o igual a 8",
"Sustento: RQM 06 425-2 Búsqueda de Cuenta y RQM 06 531 Implementar Búsqueda de Clientes",
"Solicita: Abraham Narvaez",
"BD: bdicheq ";

CREATE PROCEDURE "informix".consnomtitbeneficiario(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de Cuenta
	CHAR(20), -- Numero de Cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13); -- RFC


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCuenta	CHAR(20);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13);
	DEFINE vtpopersona  CHAR(2);
    DEFINE vrazonsocial CHAR(26);
    DEFINE vesfisica    CHAR(1);
	DEFINE vRFC_alterno	CHAR(13);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "000";
	LET vNumCuenta = pNumeroCuenta;
	LET vtpopersona   = "";
	LET vrazonsocial  = "";
	LET vesfisica     = "";
	LET vRFC_alterno  = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    

	SELECT
		bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc, bdi_sicte.rfc_alterno, bdi_sicte.razon_social, bdi_sicte.tpo_persona
	INTO
		vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vrazonsocial, vtpopersona
	FROM
		bdinteg:si_cliente bdi_sicte,
		bdicheq:sc_maechq dbc_sdmachq
	WHERE
		dbc_sdmachq.cuenta = pNumeroCuenta AND
		dbc_sdmachq.num_cte = bdi_sicte.numcte;
        -- AND	bdi_sicte.empresa = pEmpresa;
		--AND	bdi_sicte.tpo_persona = "01";

	IF vApePat IS NULL AND vNombre1 IS NULL AND vrazonsocial IS NULL THEN
		LET vCodRet		= "131";
		LET vNumCliente = "";
		LET vApePat		= "";
		LET vApeMat		= "";
		LET vNombre1	= "";
		LET vNombre2	= "";
		LET vRFC		= "";
	END IF

    SELECT es_fisica 
      INTO vesfisica
      FROM bdinteg:si_tipper
     WHERE tpo_persona = vtpopersona;

    IF vesfisica = "N" THEN
       LET vApePat = TRIM(vrazonsocial);
    END IF	   

	RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;

END PROCEDURE;