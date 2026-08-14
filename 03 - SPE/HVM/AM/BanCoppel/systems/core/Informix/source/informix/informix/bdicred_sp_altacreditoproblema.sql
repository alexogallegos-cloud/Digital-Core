CREATE PROCEDURE "informix".sp_altacreditoproblema(pEmpresa CHAR(3), pTipo CHAR(1), pNumCredito CHAR(20), pSucursal CHAR(4), pEjecutivo CHAR(8), pMotivo_Origen CHAR(100), pSitEsp CHAR(1), pCausa SMALLINT)

    --DATOS A REGRESAR---
	RETURNING
    CHAR(5);   -- Codigo de Retorno

    --DEFINICION DE VARIABLES--
    DEFINE vCodRet CHAR(5);

    --INICIALIZACION DE VARIABLES--
    LET vCodRet = "000";

    IF pTipo = 'A' THEN
        IF EXISTS (SELECT num_credito FROM bdicred:sd_marcpro WHERE num_credito = pNumCredito) THEN
            INSERT INTO bdicred:sd_marcprohist (empresa, num_credito, sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, cod_status_mora, sitesp, causa, fechamov)
            SELECT empresa, num_credito, sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, cod_status_mora, sitesp, causa, CURRENT FROM bdicred:sd_marcpro WHERE num_credito = pNumCredito;

            DELETE FROM bdicred:sd_marcpro
            WHERE num_credito = pNumCredito;
        END IF

        INSERT INTO bdicred:sd_marcpro (empresa, num_credito, sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, cod_status_mora, sitesp, causa)
        VALUES (pEmpresa, pNumCredito, pSucursal, pEjecutivo, CURRENT, 'P', pMotivo_Origen, '', pSitEsp, pCausa);
    END IF

    IF pTipo = 'B' THEN
        INSERT INTO bdicred:sd_marcprohist (empresa, num_credito, sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, cod_status_mora, sitesp, causa, fechamov)
        SELECT empresa, num_credito, sucursal, ejecutivo, fecha_alta, status_marca, motivo_origen, cod_status_mora, sitesp, causa, CURRENT FROM bdicred:sd_marcpro WHERE num_credito = pNumCredito;

        DELETE FROM bdicred:sd_marcpro
        WHERE num_credito = pNumCredito;
    END IF

    RETURN vCodRet;
END PROCEDURE
;