CREATE PROCEDURE "informix".consasigcred(pEmpresa char(3), pNumeroCredito char(20), pNumeroCliente char(20))
--Datos a Regresar--
RETURNING
char(5), --Codigo de Retorno
char(20); --Numero de Tarjeta

--Definicion de Variables
DEFINE vCodRet char(5);
DEFINE vNumeroTarjeta char(20);
DEFINE vCantReg smallint ;
DEFINE vNumCte char(20);

--Inicialización de Variables

LET vCodRet = "00000";
LET vNumeroTarjeta = "";
LET vCantReg = 0;

IF EXISTS (SELECT numcte FROM bdicred:sd_tarjeta where numcte = pNumeroCliente AND num_credito = pNumeroCredito) THEN


        SELECT DISTINCT
                num_tarjeta

        INTO
                vNumeroTarjeta
        FROM
                bdicred:sd_tarjeta AS sd_tar
        WHERE
                sd_tar.empresa = pEmpresa AND
                sd_tar.num_credito = pNumeroCredito AND
                sd_tar.numcte = pNumeroCliente AND
                sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) FROM bdicred:sd_tarjeta AS sd_tar WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCredito AND sd_tar.numcte = pNumeroCliente);

ELSE
        LET vCodRet = "262";
        LET vNumeroTarjeta = "";


END IF;
        RETURN vCodRet, vNumeroTarjeta;
END PROCEDURE
;