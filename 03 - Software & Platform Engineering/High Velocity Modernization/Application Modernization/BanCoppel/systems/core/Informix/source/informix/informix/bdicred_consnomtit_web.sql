CREATE PROCEDURE "informix".consnomtit_web(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13), -- RFC
	CHAR(16); -- NÃÂºmero de Tarjeta

	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC		CHAR(13);
	DEFINE vNumTarjeta	CHAR(16);
    DEFINE vNumProducto CHAR(4);

    --SET DEBUG FILE TO "/respaldosbd/Sonia/consnomtit_web.out"; 
	--TRACE ON;
		
	--INICIALIZACION DE VARIABLES--

	LET vCodRet		= "00000";
	LET vNumCliente 	= "";
	LET vApePat		= "";
	LET vApeMat		= "";
	LET vNombre1		= "";
	LET vNombre2		= "";
	LET vRFC		= "";
	LET vNumTarjeta		= "";
    LET vNumProducto = "";
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

	SELECT
		dbc_sdmacre.num_producto,bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc, dbc_sdtarj.num_tarjeta
	INTO
		vNumProducto,vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarjeta
	FROM
		bdicred:"informix".sd_maecred dbc_sdmacre,
		bdicred:"informix".sd_tarjeta dbc_sdtarj,
		bdinteg:"informix".si_cliente bdi_sicte
	WHERE
        dbc_sdmacre.empresa = pEmpresa AND
		dbc_sdmacre.num_credito = pNumeroCuenta AND
        dbc_sdmacre.empresa = dbc_sdtarj.empresa AND
		dbc_sdmacre.num_credito = dbc_sdtarj.num_credito AND
		bdi_sicte.numcte = dbc_sdmacre.numcte AND
        dbc_sdtarj.tipo_tarjeta = "T"  AND
        dbc_sdtarj.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where dbc_sdmacre.empresa = empresa and dbc_sdmacre.num_credito = num_credito and tipo_tarjeta = "T");

	IF vApePat IS NULL AND vNombre1 IS NULL THEN
		LET vCodRet = "00100";
	END IF

	IF vNumProducto IS NULL OR vNumProducto = "6600" THEN
		LET vCodRet = "00135";
	END IF

	RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarjeta;
END PROCEDURE

DOCUMENT 
'MODIFICADO: Sonia Guzman Rodriguez',
'FECHA: 30/08/2011',
'MODIFICACION: Se modifico para que se consulten los clientes con tarjeta cancelada';

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