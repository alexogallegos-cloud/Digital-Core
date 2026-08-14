CREATE PROCEDURE "informix".sp_dinyaobtienemovconciliacionsac(pUsuario CHAR(8), pIdFuncion CHAR(10) )
	RETURNING CHAR(5) AS CodigiRetoro, 
	CHAR(10)  AS FechaHoy,
	MONEY(16,2) AS ImporteEnviosNoCobrados, 
	MONEY(16,2) AS ImporteCuentaContable,
	CHAR(20) AS CuentaContable, 
	MONEY(16,2) AS ImporteCuentaCheques, 
	CHAR(20) AS CuentaCheques;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaHoy DATE;
	DEFINE mImporteEnviosNoCobrados MONEY(16,2);
	DEFINE mImporteCuentaContable MONEY(16,2);
	DEFINE cCuentaContable CHAR(20);
	DEFINE mImporteCuentaCheques MONEY(16,2);
	DEFINE cCuentaCheques CHAR(20);

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cFechaHoy = NULL;
	LET mImporteEnviosNoCobrados = 0;
	LET mImporteCuentaContable = 0;
	LET cCuentaContable = '';
	LET mImporteCuentaCheques = 0;
	LET cCuentaCheques = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFechaHoy,	mImporteEnviosNoCobrados, mImporteCuentaContable, cCuentaContable, mImporteCuentaCheques, cCuentaCheques;
		END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_dinyaobtienemovconciliacionsac.out';
		--TRACE ON;
		
		IF 	pUsuario = '' OR pIdFuncion = ''   THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFechaHoy,	mImporteEnviosNoCobrados, mImporteCuentaContable, cCuentaContable, mImporteCuentaCheques, cCuentaCheques;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF	cCodRet <> '00000' THEN
			RETURN cCodRet, cFechaHoy,	mImporteEnviosNoCobrados, mImporteCuentaContable, cCuentaContable, mImporteCuentaCheques, cCuentaCheques;
			END IF;
			
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdisac:sp_dinya_obtienemovconciliacion() 
			INTO cCodRetSp, cFechaHoy, mImporteEnviosNoCobrados, mImporteCuentaContable, cCuentaContable, mImporteCuentaCheques, cCuentaCheques 
			RETURN cCodRet, cFechaHoy,	mImporteEnviosNoCobrados, mImporteCuentaContable, cCuentaContable, mImporteCuentaCheques, cCuentaCheques WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin';

CREATE FUNCTION "informix".sp_esapellido_valido(pApellido CHAR(26))
	RETURNING BOOLEAN AS es_apellido_valido;
	
	DEFINE bEsApellidoValido BOOLEAN;
	DEFINE cApellido CHAR(26);
	
	LET bEsApellidoValido = 't';
	LET pApellido = UPPER(pApellido);
	LET cApellido = '';
	
	BEGIN
		
		SELECT apellido_novalido
		INTO cApellido
		FROM bdicnweb:"informix".apellidos_novalidos
		WHERE apellido_novalido = pApellido;
		
		IF cApellido IS NOT NULL THEN
			LET bEsApellidoValido = 'f';
		END IF;
		
		RETURN bEsApellidoValido;
		
	END;
	
END FUNCTION
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 04/12/2013",
"DESCRIPCION: Funcion que revisa si el parametro de entrada es un apellido valido, deveulve un booleano";

CREATE PROCEDURE "informix".sp_grabazonacallexasignar(pIdFuncion CHAR(10), pTipo SMALLINT, pCiudad SMALLINT, 
	pClave INTEGER,pDesc CHAR(30), pRumbo CHAR(40), pCodigoP INTEGER, pMunicipio CHAR(27), pPoblacionZona CHAR(30), pUsuario CHAR(8), pConfirma CHAR(1))
RETURNING CHAR(5) AS CodRetorno,
		  CHAR(1) AS Exist;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cExist CHAR(1);
	DEFINE cNumeroCalle INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cExist = '';
	LET cNumeroCalle = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cExist;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_grabazonacallexasignar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pClave = '' OR pDesc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cExist;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cExist;
				END IF;
		SET ISOLATION TO DIRTY READ;
		IF pTipo = 1 AND pConfirma = 'C' THEN
			IF pUsuario = '' OR pIdFuncion = ''  OR pCiudad = '' OR pClave = '' OR pDesc = '' OR pCodigoP = '' OR	pMunicipio = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
			ELSE
				SELECT COUNT(numerociudad) INTO  cNumeroCalle FROM bdinteg:"informix".si_catzonas WHERE 
                                numerociudad = pCiudad AND UPPER(nombrezona) = UPPER(pDesc) 
                                AND UPPER(poblacionzona) = UPPER(pPoblacionZona) AND UPPER(municipiozona) = UPPER(pMunicipio)
                                AND codigopostalzona = pCodigoP;
				IF	cNumeroCalle <> 0 THEN 
					LET cCodRet = '00107';
					LET cExist = 'S';
					RETURN cCodRet, cExist;
				ELSE
					LET cCodRet = '00000';
					LET cExist = 'N';
					RETURN cCodRet, cExist;
				END IF;
			END IF;
		END IF;
		IF pTipo = 1 AND pConfirma = 'S' THEN
			IF pUsuario = '' OR pIdFuncion = ''  OR pCiudad = '' OR pClave = '' OR pDesc = '' OR pCodigoP = '' OR	pMunicipio = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
			ELSE
				FOREACH EXECUTE PROCEDURE bdinteg:grabazonacallexasignar(pTipo, pCiudad, pClave, pDesc, pRumbo, pCodigoP, pMunicipio, 
				pPoblacionZona,	pUsuario) INTO cCodRetSp		
					LET cCodRet = DECODE(cCodRetSp, '002', '00107', '001', '00003', '000', '00000');
					IF cCodRet = '00107' OR cCodRet = '00003' OR cCodRet = '00000' then
						RETURN cCodRet, cExist;
					ELSE
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cExist;
					END IF;					
				END FOREACH;
			END IF;
		END IF;
		
		
		
		IF pTipo = 2 AND pConfirma = 'C' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pClave = '' OR pDesc = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
			ELSE
				SELECT {+INDEX (bdinteg:si_catcalles idx_catcalles)} COUNT(numerocalle)  INTO  cNumeroCalle FROM bdinteg:"informix".si_catcalles WHERE nombrecalle = pDesc;
				IF	cNumeroCalle <> 0 THEN 
					LET cCodRet = '00195';
					LET cExist = 'S';
					RETURN cCodRet, cExist;
				ELSE
					LET cCodRet = '00000';
					LET cExist = 'N';
					RETURN cCodRet, cExist;
				END IF;
			END IF;
		END IF;

		IF pTipo = 2 AND pConfirma = 'S' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pClave = '' OR pDesc = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
				ELSE
					FOREACH EXECUTE PROCEDURE bdinteg:grabazonacallexasignar(pTipo, pCiudad, pClave, pDesc, pRumbo, pCodigoP, pMunicipio, 
					pPoblacionZona,	pUsuario) INTO cCodRetSp
						LET cCodRet = DECODE(cCodRetSp, '003', '00195', '001', '00003', '000', '00000');
						IF cCodRet = '00195' OR cCodRet = '00003' OR cCodRet = '00000' THEN
							RETURN cCodRet, cExist;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet, cExist;
						END IF;					
					END FOREACH;
			END IF;
		END IF;
		
		IF pTipo = 3 AND pConfirma = 'C' THEN
			IF pUsuario = '' OR pIdFuncion = ''  OR pCiudad = '' OR pClave = '' OR pDesc = '' OR pCodigoP = '' OR	pMunicipio = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
			ELSE
				SELECT COUNT(numerociudad) INTO  cNumeroCalle FROM bdinteg:"informix".si_catzonas WHERE numerociudad = pCiudad AND
                        numerocolonia = pClave;	
				IF	cNumeroCalle <> 0 THEN 
					LET cCodRet = '00107';
					LET cExist = 'S';
					RETURN cCodRet, cExist;
				ELSE
					LET cCodRet = '00000';
					LET cExist = 'N';
					RETURN cCodRet, cExist;
				END IF;
			END IF;
		END IF;
		IF pTipo = 3 AND pConfirma = 'S' THEN
			IF pUsuario = '' OR pIdFuncion = ''  OR pCiudad = '' OR pClave = '' OR pDesc = '' OR pCodigoP = '' OR	pMunicipio = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cExist;
			ELSE
				FOREACH EXECUTE PROCEDURE bdinteg:grabazonacallexasignar(pTipo, pCiudad, pClave, pDesc, pRumbo, pCodigoP, pMunicipio, 
				pPoblacionZona,	pUsuario) INTO cCodRetSp		
					LET cCodRet = DECODE(cCodRetSp, '002', '00107', '001', '00003', '000', '00000');
					IF cCodRet = '00107' OR cCodRet = '00003' OR cCodRet = '00000' then
						RETURN cCodRet, cExist;
					ELSE
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cExist;
					END IF;					
				END FOREACH;
			END IF;
		END IF;		
	END;
END PROCEDURE;