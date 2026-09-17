CREATE PROCEDURE "informix".sp_validactehuella(pempresa CHAR(3),
                                               pnumcte CHAR(20))
RETURNING CHAR(5),CHAR(20),CHAR(11),CHAR(1);

	--DECLARACION DE VARIABLES;
	DEFINE vsqlerr 		INTEGER;
	DEFINE visamerr 	INTEGER;
	DEFINE vcodret 		CHAR(5);
	DEFINE vctehuella  	CHAR(20);
	DEFINE vctectaN2  	CHAR(11);
	DEFINE vcteRostro  	CHAR(1);

	--INICIALIZACIÃN DE VARIABLES
	LET vcodret 	= "00000";
	LET vctehuella 	= "000000000";
	LET vctectaN2 	= "00000000000";
	LET vcteRostro 	= "0";

	--SET DEBUG FILE TO '/tmp/sp_validactehuella.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr,visamerr
		   IF vsqlerr != 0 THEN
			  LET vcodret=vsqlerr;
			  RETURN vcodret, vctehuella, vctectaN2, vcteRostro;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--- Verifica recepcion correcta de datos
		IF pnumcte IS NULL OR TRIM(pnumcte) = "" THEN
		   LET vcodret = "00110";		--Variable pnumcte vacia
		   RETURN vcodret, vctehuella, vctectaN2, vcteRostro;
		END IF;

		SELECT LIMIT 1 NVL(numcte, '')
		INTO vctehuella
		FROM bdinteg:"informix".si_cte_huella
		WHERE numcte = pnumcte 
		AND estado = "A";
		
		SELECT LIMIT 1 NVL(tpo_biometria, '0')
		INTO vcteRostro
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pnumcte;

		SELECT LIMIT 1 NVL(a.cuenta, '')
		INTO vctectaN2
		FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_producto b 
		WHERE a.empresa = pempresa
		AND a.producto = b.producto
		AND a.producto = '2900'
		AND a.status_cta = '1'
		AND a.num_cte = pnumcte;
		
		IF vctehuella IS NULL OR TRIM(vctehuella) = "" THEN
			LET vctehuella = "00002";		--Cliente sin huella
			
			IF vctectaN2 IS NULL OR TRIM(vctectaN2) = "" THEN
				LET vctectaN2 = "00002"; 	
				RETURN vcodret, vctehuella, vctectaN2, vcteRostro; --Cliente sin huella, sin cuenta nivel 2, NO se pide biometria facial
			ELSE
				RETURN vcodret, vctehuella, vctectaN2, vcteRostro; --Cliente sin huella, con cuenta nivel 2, SI se pide biometria facial
			END IF
		ELSE
			LET vctehuella = "00001";		--Cliente con huella
			
			IF vctectaN2 IS NULL OR TRIM(vctectaN2) = "" THEN
				LET vctectaN2 = "00002";		
				RETURN vcodret, vctehuella, vctectaN2, vcteRostro; --Cliente con huella, sin cuenta nivel 2, NO se pide biometria facial
			ELSE
				RETURN vcodret, vctehuella, vctectaN2, vcteRostro; --Cliente con huella, con cuenta nivel 2, SE PIDE biometria dactilar (Flujo Normal)
			END IF
		END IF
		
		RETURN vcodret, vctehuella, vctectaN2, vcteRostro;
	END;

END PROCEDURE
DOCUMENT
"Consulta Existencia Huella y Rostro de Cliente",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_estatusrostrolineaenvio(
											       pNumCte 			CHAR(20),											   
												   pSecuencia 		SMALLINT,
												   pOrigenTicket 	SMALLINT
												   )
--DATOS A REGRESAR---
RETURNING
	CHAR(5)   	AS CodRet;
	
/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_generarostroslinea"
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 05/02/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
*/

--DEFINICION DE VARIABLES--
DEFINE iSql_err	  		INTEGER;
DEFINE cCodRet	  		CHAR(5);

--INICIALIZACION DE VARIABLES--
LET iSql_err 	= 0;
LET cCodRet		= '00000';

-- SET DEBUG FILE TO "/home/sysifx/sp_generarostroslinea.out";
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
	UPDATE "informix".si_rostro_linea 
	SET
	origen_ticket = pOrigenTicket,
	fecha_env = CURRENT
	WHERE secuencia = pSecuencia AND numcte = pNumCte;
	
	RETURN cCodRet;
END;
END PROCEDURE;