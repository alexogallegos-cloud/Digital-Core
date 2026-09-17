CREATE PROCEDURE "informix".sp_consultarse_bpi(psEmpresa CHAR(3),psNumCte CHAR(20))
    RETURNING CHAR(5);

--Declaracion de variables

DEFINE vsCodRet  CHAR(5);
DEFINE viSqlErr  INTEGER;

--SET DEBUG FILE TO "/tmp/sp_ConsultarSE_BPI.out";
--TRACE ON;


--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;

IF NVL(psNumCte, '') = ''  OR  NVL(psEmpresa, '') = '' THEN --Valida parámetros
    LET vsCodRet = '00002';
    RETURN vsCodRet;
END IF;

--Inicio del procedimiento

BEGIN

	ON EXCEPTION SET viSqlErr --Manejador de Errores
		IF viSqlErr <> 0 then
			LET vsCodRet = viSqlErr;
            RETURN vsCodRet;

		END IF;
	END EXCEPTION;

     IF (SELECT count(situacion) FROM bdisitesp:se_ctessitespcte
         WHERE empresa = psEmpresa AND numcte = psNumCte
         AND (situacion = 'L' OR situacion = 'M')) = 1 THEN

        LET vsCodRet = '00001';
    END IF;

    RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
"Consulta si el cliente esta en situación 'L' o 'M' para la activación de servicio avanzado de BPI",
"Autor : Dulce Ramirez",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_replicamensajesbpi (iRegistros SMALLINT)
RETURNING CHAR(3) AS Retorno, INTEGER AS CodigoMensaje, CHAR(250) AS Mensaje

DEFINE cCod_Ret         CHAR(3);
DEFINE iCodigoMensaje   INTEGER;
DEFINE cMensaje         CHAR(250);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE vDesErr          CHAR(60);

LET cCod_Ret = '000';
LET iCodigoMensaje = 0;
LET cMensaje = '';


BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret, 0, '';
    END EXCEPTION;

    FOREACH
        SELECT SKIP iRegistros FIRST 31 codigo, mensaje
        INTO iCodigoMensaje, cMensaje
        FROM bdibpi : bpi_catmensajes

        RETURN cCod_Ret, iCodigoMensaje, cMensaje
        WITH RESUME;
    END FOREACH
END
END PROCEDURE
DOCUMENT
"Obtiene los mensajes que serán mostrados durante el proceso de preactivación de",
"Servicio de Banca Por Internet",
"Autor : Raúl Ruiz",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

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