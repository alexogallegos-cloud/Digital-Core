CREATE PROCEDURE "informix".consfircred(pEmpresa char(3), pNumeroCredito char(20), pNumeroCte char(20))
--DATOS A REGRESAR
RETURNING

CHAR(5),    -- Codigo de retorno
CHAR(20),   -- # Cliente
CHAR(26),   -- Apellido paterno
CHAR(26),   -- Apellido materno
CHAR(26),   -- Nombre 1
CHAR(26),   -- Nombre 2
CHAR(13),   -- RFC
CHAR(20),   -- # Tarjeta
DATE,    -- Expiración
MONEY(14,2), -- Limite de retiro maximo por mes
CHAR(1),    -- Status tarjeta
CHAR(1),    -- Tipo de cliente
CHAR(10),   -- Fecha de Nacimiento
CHAR(4);    --Producto de Credito

--DECLARACION DE VARIABLES

DEFINE vCodRet          char(5);
DEFINE vNumCte          char(20);
DEFINE vApell_Paterno   char(26);
DEFINE vApell_Materno   char(26);
DEFINE vNombre1         char(26);
DEFINE vNombre2         char(26);
DEFINE vRfc             char(13);
DEFINE vNumTarjeta      char(20);
DEFINE vExpiracion      DATE;
DEFINE vLimRetXmes      money(14, 2);
DEFINE vStatusTarj      char(1);
DEFINE vTipoCte         char(1);
DEFINE vFechaNacimiento char(10);
DEFINE vProductoCredito char(4);
DEFINE vCantReg         smallint;

--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET vNumCte = "";
LET vApell_Paterno = "";
LET vApell_Materno = "";
LET vNombre1 = "";
LET vNombre2 = "";
LET vRfc = "";
LET vNumTarjeta = "";
LET vExpiracion = "";
LET vLimRetXmes = "";
LET vStatusTarj = "";
LET vTipoCte = "";
LET vFechaNacimiento = "";
LET vProductoCredito = "";
LET vCantReg = 0;





-- OBTENER LOS DATOS DEL FIRMANTE
FOREACH

        SELECT DISTINCT
                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc,  si_pf.fecha_nac, sd_mae.num_producto
        INTO
                vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento, vProductoCredito
        FROM
                bdicred:sd_tarjeta AS sd_tar,
                bdinteg:si_cliente AS si_cte,
                bdinteg:si_ctepf AS si_pf,
                bdicred:sd_maecred as sd_mae

        WHERE
                sd_tar.empresa =  pEmpresa AND
                sd_tar.num_credito =  pNumeroCredito AND
                sd_tar.numcte != pNumeroCte AND
                sd_tar.numcte = si_cte.numcte AND
                sd_tar.status_tar != 'C' AND
                si_cte.empresa = pEmpresa AND
                sd_tar.numcte = si_pf.numcte AND
                sd_mae.num_credito = pNumeroCredito


                -- OBTENER LA TARJETA DEL FIRMANTE --
        SELECT
                sd_tar.tipo_tarjeta, sd_tar.num_tarjeta, sd_tar.expiracion, sd_tar.limite_aut, sd_tar.status_tar
        INTO
                vTipoCte, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj
        FROM
                bdicred:sd_tarjeta AS sd_tar
        WHERE
                sd_tar.empresa = pEmpresa AND
                sd_tar.num_credito = pNumeroCredito AND
                sd_tar.numcte = vNumCte AND
                sd_tar.status_tar != 'C' AND
                sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) FROM bdicred:sd_tarjeta AS sd_tar WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCredito AND sd_tar.numcte = vNumCte);

        --IF vStatusTarj = 'C' THEN
                --LET vNumTarjeta = "Sin tarjeta";
                --LET vLimRetXmes  = 0;
                --LET vStatusTarj = "";
                --LET vExpiracion = " ";
        --END IF

LET vCantReg = vCantReg + 1;

        RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito WITH RESUME;
END FOREACH;

        IF vCantReg = 0 THEN
                LET vCodRet  = "154";
                LET vNumCte  = "";
                LET vApell_Paterno  = "";
                LET vApell_Materno  = "";
                LET vNombre1 = "";
                LET vNombre2 = "";
                LET vRfc     = "";
                LET vNumTarjeta = "";
                LET vExpiracion = "";
                LET vLimRetXmes  = 0;
                LET vStatusTarj = "";
                LET vTipoCte = "";
                LET vFechaNacimiento = "";
                LET vProductoCredito = "";

                RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito;
        END IF
END PROCEDURE



;