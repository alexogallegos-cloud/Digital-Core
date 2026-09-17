CREATE PROCEDURE "informix".sp_valida_confirmacion_movil_web(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(5) As cCodRet;

--Definicion de Variables 
DEFINE cCodRet			CHAR (5);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--Inicializacion de Variables

LET cCodRet      = '00000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '01289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '01386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '00000';
			END IF;
	ELSE
		LET cCodRet = '00001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;