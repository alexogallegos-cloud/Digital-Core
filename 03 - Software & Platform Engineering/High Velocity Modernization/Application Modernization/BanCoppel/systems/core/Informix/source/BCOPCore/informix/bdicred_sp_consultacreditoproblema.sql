CREATE PROCEDURE "informix".sp_consultacreditoproblema(pEmpresa CHAR(3), pNumCredito CHAR(20))

    --DATOS A REGRESAR---
	RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(4),   -- Sucursal
    CHAR(8),   -- Ejecutivo
    DATE,      -- Fecha Alta
    CHAR(1),   -- Status_Marca
    CHAR(100), -- Motivo_Origen
    CHAR(1),   -- SitEsp
    SMALLINT;  -- Causa

    --DEFINICION DE VARIABLES--
    DEFINE vCodRet         CHAR(5);
    DEFINE vSucursal       CHAR(4);
    DEFINE vEjecutivo      CHAR(8);
    DEFINE vFechaAlta      DATE;
    DEFINE vStatus_Marca   CHAR(1);
    DEFINE vMotivo_Origen  CHAR(100);
    DEFINE vSitEsp         CHAR(1);
    DEFINE vCausa          SMALLINT;

    --INICIALIZACION DE VARIABLES--
    LET vCodRet        = "000";
    LET vSucursal      = "";
    LET vEjecutivo     = "";
    LET vFechaAlta     = "01-01-1900";
    LET vStatus_Marca  = "";
    LET vMotivo_Origen = "";
    LET vSitEsp        = "";
    LET vCausa         = "";

    IF EXISTS(SELECT num_credito FROM bdicred:sd_marcpro WHERE num_credito = pNumCredito) THEN
        SELECT
            sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, sitesp, causa
        INTO
            vSucursal, vEjecutivo, vFechaAlta, vStatus_Marca, vMotivo_Origen, vSitEsp, vCausa
        FROM
            bdicred:sd_marcpro
        WHERE
            num_credito = pNumCredito;
    ELSE
        LET vCodRet = "100";
    END IF

    RETURN vCodRet, vSucursal, vEjecutivo, vFechaAlta, vStatus_Marca, vMotivo_Origen, vSitEsp, vCausa;
END PROCEDURE
;