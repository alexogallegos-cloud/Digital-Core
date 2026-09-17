CREATE PROCEDURE "informix".sp_consulta_parametros_cuenta_nomina(pEmpresa CHAR(3), pSucursal CHAR(4), pID CHAR(20))
RETURNING CHAR(5), CHAR(255),  CHAR(255);

DEFINE cCodRet          CHAR(5);
DEFINE cValor           CHAR(255);
DEFINE cDescripcion     CHAR(255);
DEFINE sql_err          INTEGER;

LET cCodRet         = '00001';
LET cValor          = '';
LET cDescripcion    = '';
LET sql_err         = 0;

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET cCodRet = sql_err;
	     RETURN cCodRet, cValor, cDescripcion;
	  END IF
	END EXCEPTION;

	-- SET DEBUG FILE TO "/INFORMIXDUMP/sp_consulta_parametros_cuenta_nomina.trc";
    -- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF TRIM(pEmpresa) <> '' AND TRIM(pSucursal) <> '' AND TRIM(pID) <> '' THEN
	
		IF TRIM(pID) ='CTA_NOMINA' THEN
			SELECT valor, descripcion INTO cValor, cDescripcion
			FROM "informix".sn_parametros
			WHERE empresa = TRIM(pEmpresa) AND Sucursal=pSucursal
			AND id = TRIM(pID);
		ELSE
			SELECT FIRST 1 valor, descripcion INTO cValor, cDescripcion
			FROM "informix".sn_parametros
			WHERE empresa = TRIM(pEmpresa)
			AND id = TRIM(pID);
		END IF;

        IF dbinfo('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '00002';
        ELSE
            LET cCodRet = '00000';
        END IF;

    END IF;
		
	RETURN cCodRet, cValor, cDescripcion;
	
END

END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimiento almacenado consulta los parametros de cuenta de nomina.',
'PETICION: Iniciativa cuenta Nomina',
'AUTOR: Jorge Arturo Astorga',
'FECHA DE CREACION: 2022/08/19',
'BD: bdiadminnomina';