CREATE PROCEDURE "informix".constipydircliente(pEmpresa CHAR(3), pRFC CHAR(13), pOpcion INTEGER, cNumCliente CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
    CHAR(20); --Numero de Cliente

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet		CHAR(5);
    DEFINE cTipCte      CHAR(1);
    DEFINE cDirExi      CHAR(1);
    DEFINE cNumCte      CHAR(20);
    DEFINE iSqlErr		INTEGER;
    
    LET iSqlErr         = 0;
    LET cNumCte         = "";
BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNumCte;
        END IF;
	END EXCEPTION;
    --Valida Direccion de los Beneficiarios
    IF pOpcion = 1 THEN
        IF cNumCliente = "" THEN
            SELECT numcte, tipo_cliente INTO cNumCte, cTipCte FROM bdinteg:si_cliente WHERE rfc = pRFC;
        ELSE
            SELECT tipo_cliente INTO cTipCte FROM bdinteg:si_cliente WHERE numcte = cNumCliente;
            LET cNumCte = cNumCliente;
        END IF
        SELECT NVL(COUNT(*),"0") INTO cDirExi FROM bdinteg:si_direcciones WHERE numcte = cNumCte;
        
        IF (cTipCte = "1") AND (cDirExi <> "0") OR (cTipCte = "2") AND (cDirExi <> "0") THEN 
            LET cCodRet = "000";
            RETURN cCodRet, cNumCte;
        ELSE
            IF cTipCte = 1 THEN
                LET cCodRet = "001";
                RETURN cCodRet, cNumCte;
            ELSE
                LET cCodRet = "002";
                RETURN cCodRet, cNumCte;
            END IF; 
        END IF;
    ELSE --Obiene Numero del Cliente
        SELECT numcte INTO cNumCte FROM bdinteg:si_cliente WHERE rfc = pRFC;
        LET cCodRet = "003";
        RETURN cCodRet, cNumCte;
    END IF
END
END PROCEDURE
DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: BeneficiariosCONDUSEF',
'Solicito: Frank Gaxiola',
'Descripcion: Se crea procedimiento que valida si los clientes tipo 1 o 2 tiene direccion registrada',
'Fecha: 18/08/2010',
'Version: 20100824.1815',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacatciudades(pDesde INTEGER, pHasta INTEGER)
RETURNING CHAR(6), CHAR(80), CHAR(2), CHAR(3), CHAR(200);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);

DEFINE v_estado         CHAR(2);
DEFINE v_ciudad         CHAR(3);
DEFINE v_nombre       CHAR(200);


------------------------------------------------------------

-- Creado: Walber Castro
-- Fecha: 28 de mayo de 2010
-- Crear en BDINTEG
-- Se crea con el objetivo de consultar el catalogo de ciudades por medio de paginación.
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';

LET v_estado = '';
LET v_ciudad = '';
LET v_nombre = '';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_nombre;
	    END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_consultacatciudades.out";
--TRACE ON;

foreach
    SELECT SKIP pDesde FIRST pHasta NVL(estado,''), NVL(ciudad,''), TRIM(NVL(nombre,'')) 
    INTO v_estado, v_ciudad, v_nombre
    FROM bdinteg:si_ciudades
    ORDER BY estado,ciudad

    RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_nombre WITH RESUME;
    LET cCod_ret = '';
    LET cMensaje = '';
END foreach;

END;
END PROCEDURE;