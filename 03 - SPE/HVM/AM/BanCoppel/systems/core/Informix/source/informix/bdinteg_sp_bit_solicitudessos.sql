CREATE PROCEDURE "informix".sp_bit_solicitudessos (pNumCte CHAR(20), 
														   pTipoSol CHAR(20), 
														   pNombreInc CHAR (104), 
														   pFechaNacInc DATE, 
														   pNombreCorr CHAR(104),
														   pFechaNacCorr DATE, 
														   pSucursal CHAR(4), 
														   pNumEmp CHAR(8), 
														   pOrigen CHAR(1)) 
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cFechaNacInc DATE;


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cFechaNacInc = DATE(1);

--SET DEBUG FILE TO '/informix/cristo/sp_bit_solicitudessos.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (pNumCte IS NULL OR pNumCte  = '') OR (pTipoSol IS NULL OR pTipoSol = '')
		OR (pNombreInc  IS NULL OR pNombreInc  = '') 
		OR (pFechaNacInc IS NULL OR pFechaNacInc = '') 
		OR (pNombreCorr IS NULL OR pNombreCorr = '')  
		OR (pFechaNacCorr IS NULL OR pFechaNacCorr = '') 
		OR (pSucursal IS NULL OR pSucursal = '') 
		OR (pNumEmp IS NULL OR pNumEmp = '') 
		OR (pOrigen IS NULL OR pOrigen = '') THEN
		LET cCodRet = '00001';
	ELSE
		
		SELECT first 1 {+AVOID("informix".si_ctepf)}fecha_nac INTO cFechaNacInc FROM "informix".si_ctepf WHERE numcte=pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
			LET pFechaNacInc = cFechaNacInc;			
		END IF;
		
		INSERT INTO bdinteg:"informix".si_bitacora_solicitudessos
		(numcte, tipo_sol, nombre_inc, fecha_nac_inc, nombre_corr, fecha_nac_corr, sucursal, numemp, origen, fecha_insert)
		VALUES( pNumCte, pTipoSol  , pNombreInc, pFechaNacInc  , pNombreCorr, pFechaNacCorr, pSucursal, pNumEmp, pOrigen,CURRENT);
	END IF	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea procedimiento almacenado para llamar sp_bit_solicitudessos el cual guardara  una bitacora de las coincidencias para su posterior procesamiento. ',
'AUTOR : Leonardo Alfonso Plata Garcia',
'FECHA : 06/09/2013',
'MODIFICACION: Se obtiene fecha de nacimiento del cliente para evitar errores en la convercion de fechas antes del llamado de este procedimiento',
'FECHA: 25/03/2015',
'VERSION: ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualizactebiometria(pTipo CHAR(1), pNumCte CHAR(20))
    RETURNING CHAR(5) AS CodRet;

    --Definicion de Variables
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);

    --Inicializacion de Variables
    LET iSqlErr = 0;
    LET cCodRet = '000';

    --SET DEBUG FILE TO '/informix/IrisA/sp_actualizactebiometria.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			UPDATE "informix".si_cliente SET tpo_biometria = '2' WHERE numcte = pNumCte;
		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;