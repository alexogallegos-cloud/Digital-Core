CREATE PROCEDURE "informix".sp_confechaultmovimiento(cID_USUARIOC CHAR(8),
                                                     cID_FUNCIONC CHAR(10),
                                                     cNUMCUENTA CHAR(20),
                                                     cSISTEMACUENTA CHAR(2))
       RETURNING CHAR(5) AS codRet,
                 DATE    AS Fchultmov;
--
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

DEFINE pEmpresa     		CHAR(3);
DEFINE dFecha			DATE;
DEFINE cCuenta			CHAR(20);

--inicializando variables
LET cCodRet 		= "00000";
LET iSql_err 		= 0 ;

LET pEmpresa   		= '001';
LET dFecha		= '';
LET cCuenta		= '';

SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/mfinis/sp_confechaultmovimiento.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	OR
		cSISTEMACUENTA = ''	THEN
		LET cCodRet = "00036";
		RETURN cCodRet,dFecha;
	END IF;
	IF cSISTEMACUENTA <> '01' AND
	   cSISTEMACUENTA <> '03'  AND
	   cSISTEMACUENTA <> '06' THEN
		LET cCodRet = "00037";
		RETURN cCodRet,dFecha;
	END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,
                                                                       cID_FUNCIONC)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, dFecha;
        END IF;

	IF cSISTEMACUENTA = '01' THEN
        	-- OBTIENE LOS DATOS Y VALIDA LA CUENTA DE CHEQUES
        	LET cCuenta = "";
        	SELECT mc.cuenta, mc.fec_ult_mov
        	INTO cCuenta, dFecha
        	FROM bdicheq:"informix".sc_maechq mc
        	WHERE mc.cuenta = cNUMCUENTA;
        	IF NVL(cCuenta,"") = "" THEN
                	-- "La Cuenta no existe"
                	LET cCodRet = "00009";
                	RETURN cCodRet,dFecha;
        	END IF;
	ELSE
                -- "Parametros sin programacione"
                LET cCodRet = "00141";
                RETURN cCodRet,dFecha;
	END IF;

	RETURN cCodRet, dFecha;
END;

END PROCEDURE;