CREATE PROCEDURE "informix".consnomtitcred_web(pEmpresa CHAR(3), pTarjeta CHAR(20))

--DATOS A REGRESAR---
RETURNING
CHAR(5), --Codigo de Retorno
CHAR(20), --Numero Cliente
CHAR(20), --Numero Cuenta
CHAR(26), --Apellido Paterno
CHAR(26), --Apellido Materno
CHAR(26), --Nombre1
CHAR(26), --Nombre2
CHAR(13),  --RFC
DECIMAL(18, 2) --Monto Linea de Credito

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         CHAR(5);
DEFINE Vnumcte          CHAR(20);
DEFINE Vnumcta          CHAR(20);
DEFINE VaPaterno        CHAR(26);
DEFINE vaMaterno        CHAR(26);
DEFINE vNombre1         CHAR(26);
DEFINE VNombre2         CHAR(26);
DEFINE Vrfc             CHAR(13);
DEFINE VmtoLineaCred DECIMAL(18, 2);
DEFINE vCantReg SMALLINT;
DEFINE vNumProd CHAR(4);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00000";
LET Vnumcte= "";
LET Vnumcta= "";
LET VaPaterno = "";
LET vaMaterno = "";
LET vNombre1= "";
LET VNombre2 = "";
LET Vrfc = "";
LET VmtoLineaCred = "";
LET vCantReg = 0;
LET vNumProd = "";

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

        SELECT
                b.num_producto,b.numcte, c.num_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, d.monto_otorgado
        INTO
                vNumProd,Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred
        FROM
                bdinteg:si_cliente a, bdicred:sd_maecred b, bdicred:sd_tarjeta c, bdicred:sd_maesdos d
        WHERE
                a.empresa = pEmpresa AND c.num_credito = b.num_credito and b.numcte = a.numcte and c.num_tarjeta=pTarjeta and c.num_credito = d.num_credito;


        if vNumProd = "6600" then
            LET Vcod_Ret = "00135";
            LET Vnumcte = "";
            LET Vnumcta = "";
            LET VaPaterno = "";
            LET vaMaterno  = "";
            LET vNombre1  = "";
            LET VNombre2 = "";
            LET vNombre2 = "";
            LET Vrfc     = "";
            LET VmtoLineaCred = "";
            RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;
        end if;


        if Vnumcte <> "" and Vnumcta <> ""  and Vrfc <> "" then
                let vCantReg = vCantReg +1;
                RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;
        end if


        IF vCantReg = 0 THEN
                LET Vcod_Ret = "00224";
                LET Vnumcte = "";
                LET Vnumcta = "";
                LET VaPaterno = "";
                LET vaMaterno  = "";
                LET vNombre1  = "";
                LET VNombre2 = "";
                LET vNombre2 = "";
                LET Vrfc     = "";
                LET VmtoLineaCred = "";
                RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;
        END IF
END PROCEDURE;