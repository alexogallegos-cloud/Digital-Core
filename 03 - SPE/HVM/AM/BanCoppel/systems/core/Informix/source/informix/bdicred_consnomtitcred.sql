CREATE PROCEDURE "informix".consnomtitcred(pEmpresa char(3), pTarjeta char(20))

--DATOS A REGRESAR---

RETURNING

char(5), --Codigo de Retorno
char(20), --Numero Cliente
char(20), --Numero Cuenta
char(26), --Apellido Paterno
char(26), --Apellido Materno
char(26), --Nombre1
char(26), --Nombre2
char(13),  --RFC
decimal(18, 2) --Monto Linea de Credito

--DEFINICION DE VARIABLES--

DEFINE Vcod_Ret         char(5);
DEFINE Vnumcte          char(20);
DEFINE Vnumcta          char(20);
DEFINE VaPaterno        char(26);
DEFINE vaMaterno        char(26);
DEFINE vNombre1         char(26);
DEFINE VNombre2         char(26);
DEFINE Vrfc             char(13);
DEFINE VmtoLineaCred decimal(18, 2);
DEFINE vCantReg smallint;
DEFINE vNumProd char(4);

--INICIALIZACION DE VARIABLES--

LET Vcod_Ret ="000";
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

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;

        SELECT
                b.num_producto,b.numcte, c.num_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, d.monto_otorgado
        INTO
                vNumProd,Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred
        FROM
                bdinteg:si_cliente a, bdicred:sd_maecred b, bdicred:sd_tarjeta c, bdicred:sd_maesdos d
        WHERE
                a.empresa = pEmpresa AND c.num_credito = b.num_credito and b.numcte = a.numcte and c.num_tarjeta=pTarjeta and c.num_credito = d.num_credito;



        if vNumProd = "6600" then
            LET Vcod_Ret = "135";
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
                LET Vcod_Ret = "224";
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
        end if

END PROCEDURE


;