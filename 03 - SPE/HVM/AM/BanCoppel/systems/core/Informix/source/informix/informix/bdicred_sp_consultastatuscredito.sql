CREATE PROCEDURE "informix".sp_consultastatuscredito(pEmpresa char(3), pTipo char(1), pTarjeta char(20))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),  -- Codigo de Retorno
    CHAR(20), -- Numero de Crédito
    CHAR(4),  -- Numero de Producto
    CHAR(2),  -- Status Crédito
    CHAR(20), -- Numero Cliente
    CHAR(26), -- Apellido Paterno
    CHAR(26), -- Apellido Materno
    CHAR(26), -- Nombre1
    CHAR(26), -- Nombre2
    CHAR(13), -- RFC
    CHAR(60); -- Descripcion Status

    --DEFINICION DE VARIABLES--
    DEFINE vCod_Ret     CHAR(5);
    DEFINE vNumCred     CHAR(20);
    DEFINE vNumProducto CHAR(4);
    DEFINE vStatusCred  CHAR(2);
    DEFINE vNumCte      CHAR(20);
    DEFINE vPaterno     CHAR(26);
    DEFINE vMaterno     CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vRfc         CHAR(13);
    DEFINE vDescStatus  CHAR(60);
    DEFINE vCantReg     SMALLINT;

    --INICIALIZACION DE VARIABLES--
    LET vCod_Ret     ="000";
    LET vNumCred     = "";
    LET vNumProducto = "";
    LET vStatusCred  = "";
    LET vNumCte      = "";
    LET vPaterno     = "";
    LET vMaterno     = "";
    LET vNombre1     = "";
    LET vNombre2     = "";
    LET vRfc         = "";
    LET vDescStatus  = "";
    LET vCantReg     = 0;

    IF pTipo = '1' THEN
        SELECT
            b.num_credito, b.num_producto, b.status_cred, b.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, d.descripcion
        INTO
            vNumCred, vNumProducto, vStatusCred, vNumCte, vPaterno, vMaterno, vNombre1, vNombre2, vRfc, vDescStatus
        FROM
            bdinteg:si_cliente a, bdicred:sd_maecred b, bdicred:sd_tipocartera d
        WHERE
            a.empresa = pEmpresa AND b.num_credito = pTarjeta  AND b.numcte = a.numcte AND b.status_cred = d.status_cred;
    ELSE
        SELECT
            c.num_credito, b.num_producto, b.status_cred, b.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, d.descripcion
        INTO
            vNumCred, vNumProducto, vStatusCred, vNumCte, vPaterno, vMaterno, vNombre1, vNombre2, vRfc, vDescStatus
        FROM
            bdinteg:si_cliente a, bdicred:sd_maecred b, bdicred:sd_tarjeta c, bdicred:sd_tipocartera d
        WHERE
            a.empresa = pEmpresa AND c.num_credito = b.num_credito and b.numcte = a.numcte and c.num_tarjeta = pTarjeta AND c.tipo_tarjeta = 'T' AND b.status_cred = d.status_cred;
    END IF

    IF vNumCte <> "" AND vNumCred <> "" then
        LET vCantReg = vCantReg +1;
        RETURN vCod_Ret, vNumCred, vNumProducto, vStatusCred, vNumCte, vPaterno, vMaterno, vNombre1, vNombre2, vRfc, vDescStatus;
    END IF

	IF vCantReg = 0 THEN
        IF pTipo = '1' THEN
            LET vCod_Ret     = "224";
        ELSE
            LET vCod_Ret     = "431";
        END IF
        LET vNumCred     = "";
        LET vNumProducto = "";
        LET vStatusCred  = "";
        LET vNumCte      = "";
        LET vPaterno     = "";
        LET vMaterno     = "";
        LET vNombre1     = "";
        LET vNombre2     = "";
        LET vRfc         = "";
        LET vCantReg     = 0;
        RETURN vCod_Ret, vNumCred, vNumProducto, vStatusCred, vNumCte, vPaterno, vMaterno, vNombre1, vNombre2, vRfc, vDescStatus;
    END IF

END PROCEDURE;