CREATE PROCEDURE "informix".sp_spei_consnumcte_web(pEmpresa CHAR(3),pNumCte CHAR(9),pNumCta CHAR(12),pNumTarjeta CHAR(16),pTipoBusqueda CHAR(1))

--RETORNO--
RETURNING	CHAR(5),	-- Codigo de Retorno
			CHAR(9),	-- Numero de Cliente
			CHAR(107),	-- Nombre del Cliente
			CHAR(10),	-- Fecha de Nac.
			CHAR(13);	-- RFC.

--DEFINICION DE VARIABLES
DEFINE	iSqlErr 		INTEGER;
DEFINE	cCodRet 		CHAR(5);
DEFINE	cNombreCompleto	CHAR(107);
DEFINE	cFechaNac		CHAR(10);
DEFINE	cBin			CHAR(6);
DEFINE	cTipoTarj		CHAR(1);
DEFINE	cStatusTarj		CHAR(1);
DEFINE	cNombre1		CHAR(26);
DEFINE	cNombre2		CHAR(26);
DEFINE	cApellPat		CHAR(26);
DEFINE	cApellMat		CHAR(26);
DEFINE	cRfc			CHAR(13);

--INICIALIZACION DE VARIABLES
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET	cNombreCompleto	= "";
LET	cFechaNac		= "";
LET	cBin			= "";
LET	cTipoTarj		= "";
LET	cStatusTarj		= "";
LET	cNombre1		= "";
LET	cNombre2		= "";
LET	cApellPat		= "";
LET	cApellMat		= "";
LET	cRfc			= "";

	--SET DEBUG FILE TO '/respaldosdb/Benitez/sp_spei_consnumcte.out';
	--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cFechaNac, cRfc;
		END IF
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
			
	IF (NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'')<> '') OR (NVL(pNumTarjeta,'') <> '' AND NVL(pTipoBusqueda,'')<> '')  OR (NVL(pNumCta,'') <> '' AND NVL(pTipoBusqueda,'')<> '') THEN

		LET pTipoBusqueda =  UPPER(pTipoBusqueda);
		IF NVL(pTipoBusqueda,'') <> "C" AND NVL(pTipoBusqueda,'') <> "D" THEN
			LET cCodRet = '00006';
		ELSE	
			IF NVL(pNumTarjeta,'') <> '' THEN
				LET cBin = SUBSTR(pNumTarjeta,1,6);
				SELECT bin INTO cBin FROM intercard:"informix".bines
				WHERE bin = cBin AND creditodebito = pTipoBusqueda;

				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					IF NVL(pTipoBusqueda,'') = "C" THEN
						LET cCodRet = '00202';
					ELIF NVL(pTipoBusqueda,'') = "D" THEN
						LET cCodRet = '00245';
					END IF
				ELSE
					IF NVL(pTipoBusqueda,'') = "C" THEN
						SELECT numcte,tipo_tarjeta,status_tar INTO pNumCte,cTipoTarj,cStatusTarj
						FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumTarjeta;

						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00003';
						ELSE
							IF NVL(cStatusTarj,'') <> "A" THEN
								LET cCodRet = '00398';
							END IF
						END IF
					ELIF NVL(pTipoBusqueda,'') = "D" THEN
						SELECT numcte,tipo_tarjeta,status_tar INTO pNumCte,cTipoTarj,cStatusTarj
						FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = pNumTarjeta;

						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00003';
						ELSE
							IF NVL(cStatusTarj,'') <> "A" THEN
								LET cCodRet = '00005';
							END IF
						END IF
					END IF
					IF NVL(cTipoTarj,'') <> "T" AND NVL(cTipoTarj,'') <> '' THEN
						LET cCodRet = '00186';
					END IF
				END IF
			ELIF NVL(pNumCta,'') <> '' THEN

				IF NVL(pTipoBusqueda,'') = "C" THEN
					SELECT numcte INTO pNumCte
					FROM bdicred:"informix".sd_maecred
					WHERE num_credito = pNumCta;

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
					END IF

				ELIF NVL(pTipoBusqueda,'') = "D" THEN
					SELECT num_cte INTO pNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta = pNumCta;

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
					END IF
				END IF
			END IF
		END IF

		IF NVL(pNumCte,'') <> '' THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO cNombre1, cNombre2, cApellPat, cApellMat, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00004';
			ELSE
				SELECT LIMIT 1 fecha_nac
				INTO cFechaNac
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = pNumCte;

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00004';
				END IF
			END IF
		END IF
	ELSE
		LET cCodRet = '00001';
	END IF

RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cFechaNac, cRfc;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene nombre completo y fecha de nacimiento, buscando por NumCte,Cuenta o Tarjeta',
'REALIZO: Francisco Eduardo Benitez Baez',
'FOLIO: 1463',
'FECHA: 30/10/2014',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_validaproducto_web(pEmpresa CHAR(3), pNumCuenta CHAR(20), pTipo CHAR(1))

RETURNING CHAR(5), CHAR(1), CHAR(1), SMALLINT;

--28/11/2008
--Rodolfo Tortolero Varela
--Valida que el numero de cuenta se le pueda asignar una tarjeta adicional

--02/12/2008
--Rodolfo Tortolero Varela
--Se modifico para tambien recibir tarjetas de crÃÂ©dito.

--14/10/2009
--Rodolfo Tortolero Varela
--Se agrega validaciÃÂ³n para cuando la consulta de producto se haga por nÃÂºmero de tarjeta

--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vProducto CHAR(4);
	DEFINE vFlagAdic CHAR(1);
	DEFINE vFlagTar CHAR(1);
	DEFINE vTotAdic SMALLINT;
	DEFINE vProd CHAR(4);

--Set debug file to '/tmp/sp_consultacuentas.out';
--trace on;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
			END IF;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet = '00000';	--Si Existe el tipo de producto
	LET vProducto = "";
	LEt vFlagAdic = "";
	LET vFlagTar = "";
	LEt vTotAdic = 0;
	LEt vProd = "";
		
	IF pNumCuenta = "" THEN
		LET vCodRet = '99999'; --Falta el parametro nÃÂ¹mero de cuenta
			LET vFlagAdic = NULL;
			LET vFlagTar = NULL;
			LET vTotAdic = NULL;
		RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
	END IF;
	
	--Se selecciona el producto de la cuenta
	IF pTipo = "1" THEN --Productos de DÃÂ©bito
		IF LENGTH(pNumCuenta) = 11 THEN
			SELECT producto INTO vProd FROM bdicheq:sc_maechq 
			 WHERE cuenta = pNumCuenta;
		ELSE
			SELECT b.producto INTO vProd FROM bdicheq:sc_tarjeta a, bdicheq:sc_maechq b
			WHERE a.empresa = pEmpresa 
			  AND a.num_tarjeta = pNumCuenta 
			  AND a.cuenta = b.cuenta;
		END IF;
	ELIF pTipo = "2" THEN --Productos de InversiÃÂ³n
		SELECT cod_instrum INTO vProd FROM bdinvers:sv_maeinv WHERE cuenta = pNumCuenta;
	ELIF pTipo = "3" THEN --Productos de CrÃÂ©dito Bancoppel
		SELECT b.num_producto INTO vProd FROM bdicred:sd_tarjeta a, bdicred:sd_maecred b
		WHERE a.empresa = pEmpresa 
		  AND a.num_tarjeta = pNumCuenta 
		  AND a.empresa = b.empresa
		  AND a.num_credito = b.num_credito;
	ELIF pTipo = "4" THEN --Producto de CrÃÂ©dito Coppel
		LET vProd = "6500";
	END IF;
	
	SELECT producto, flagadicional, flagtarjeta, totadicional
	INTO vProducto, vFlagAdic, vFlagTar, vTotAdic
	FROM si_catvalidaprod
	WHERE empresa = pEmpresa
	AND producto = vProd;
        
	IF vFlagAdic = '0'  THEN
		LET vFlagTar = '0';
		LET vTotAdic = '0';
	END IF;        
        
	IF vProducto IS NULL THEN
		LET  vCodRet = '00001'; --No Existe el producto en la tabla si_catvalidaprod
	END IF;
		
	RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;

	END;
END PROCEDURE;