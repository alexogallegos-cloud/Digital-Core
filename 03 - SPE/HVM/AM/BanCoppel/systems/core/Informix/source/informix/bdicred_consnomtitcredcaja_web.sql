CREATE PROCEDURE "informix".consnomtitcredcaja_web(pEmpresa CHAR(3), pTarjeta CHAR(20))

--DATOS A REGRESAR---
RETURNING
CHAR(5), --Codigo de Retorno
CHAR(20), --Numero Cliente
CHAR(20);
--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         CHAR(5);
DEFINE Vnumcte          CHAR(20);
DEFINE Vnumcta          CHAR(20);
DEFINE vNumProd 		CHAR(4);
DEFINE vCantReg 		INTEGER;

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00000";
LET Vnumcte= "";
LET Vnumcta= "";
LET vNumProd = "";
LET vCantReg = "0";

--SET DEBUG FILE TO "/tmp/consnomtitcredcaja.out"; 
--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

  
		SELECT
                num_producto, numcte, num_credito
        INTO
                vNumProd,Vnumcte, Vnumcta
        FROM
               bdicred:"informix".sd_maecred
        WHERE
                empresa = pEmpresa AND num_credito = pTarjeta;


        if vNumProd = "6600" then
            LET Vcod_Ret = "00135";
            LET Vnumcte = "0";
            LET Vnumcta = "0";
            RETURN Vcod_Ret, Vnumcte, Vnumcta;
        end if;


        if Vnumcte <> "" and Vnumcta <> "" then
                let vCantReg = vCantReg +1;
                RETURN Vcod_Ret, Vnumcte, Vnumcta;

        end if


        IF vCantReg = 0 THEN
                LET Vcod_Ret = "00224";
                LET Vnumcte = "0";
                LET Vnumcta = "0";
                RETURN Vcod_Ret, Vnumcte, Vnumcta;
        END IF

END PROCEDURE
DOCUMENT
'Creado: Martin Miranda',
'Fecha: 04/05/2011',
'Descripcion: Se crea para obtener consultar el titular de crÃ©dito.';

CREATE PROCEDURE "informix".miomio_web()
RETURNING  VARCHAR(5), DATE, DATETIME YEAR TO MONTH;

define fecha    DATETIME YEAR TO MONTH;
define fechahoy DATE;
define cCodRet  VARCHAR(5);

LET cCodRet = '00000';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO fechahoy
   FROM sd_fechas;
   
LET fecha = fechahoy;

RETURN
 cCodRet, fechahoy, fecha;
END PROCEDURE;