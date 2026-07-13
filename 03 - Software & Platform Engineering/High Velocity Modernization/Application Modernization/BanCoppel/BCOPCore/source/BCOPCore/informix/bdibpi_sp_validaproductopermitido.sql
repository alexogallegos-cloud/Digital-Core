CREATE PROCEDURE "informix".sp_validaproductopermitido(cEmpresa CHAR(3), cProducto CHAR(4), cOperacion CHAR(12) )
RETURNING CHAR(6)

--DEFINICION DE VARIABLES--
    DEFINE iSqlErr      INTEGER;
    DEFINE vCodRet      CHAR(6);

--Set debug file to '/tmp/sp_consultacuentas.out';
--trace on;
    BEGIN
        IF EXISTS ( SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = TRIM(cOperacion)AND producto = cProducto ) THEN
            LET vCodRet =   '00000';      --'El Producto es permitido';
        ELSE
            LET vCodRet =   '00001';      --'El Producto no es permitido';
        END IF
        RETURN vCodRet;
	END;
END PROCEDURE;