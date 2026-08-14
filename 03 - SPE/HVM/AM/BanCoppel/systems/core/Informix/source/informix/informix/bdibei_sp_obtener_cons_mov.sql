CREATE PROCEDURE "informix".sp_obtener_cons_mov(pEmpresa CHAR(3), pNum_cliente CHAR(9)) 
    RETURNING CHAR(5) AS cod_ret, CHAR(25) AS folio, CHAR(30) AS f_solicitud_arch, CHAR(10) AS f_inicial,
    CHAR(10) AS f_final, CHAR(5) AS status_arch;
--****************************************************************************************************
-- DESCRIPCION: Obtener la Consulta de Movimientos de la cuenta del cliente
-- AUTOR : Jose Leon Arellano 
-- FECHA : 14/Julio/2016
-- BD: bdibei
-- FECHA DE LIBERACIÓN: 
--****************************************************************************************************
    -- Definicion de variables
    DEFINE vFolio CHAR(25);
    DEFINE vFsolicitud CHAR(30);
    DEFINE vFinicial CHAR(10);
    DEFINE vFfinal CHAR(10);
    DEFINE vStatus CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    LET cod_ret = '00000';
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret ,'','','','','';
      END IF;
	END EXCEPTION;
    -- Validar que los parametros de entrada no vengan vacios
    IF NVL(pEmpresa,'') = '' THEN
        LET cod_ret = '00001';
        RETURN cod_ret ,'','','','','';
    ELIF NVL(pNum_cliente,'') = '' THEN
        LET cod_ret = '00002';
        RETURN cod_ret ,'','','','','';
    END IF;
    -- Obtener registros de bei_consulta_mov
    IF EXISTS (SELECT folio,f_solicitud_arch,TO_CHAR(f_inicial,'%d/%m/%Y'),TO_CHAR(f_final,'%d/%m/%Y'),status_arch
                FROM informix.bei_consulta_mov
        WHERE empresa = pEmpresa 
        AND num_cliente = pNum_cliente
        AND status_arch != '07') THEN
        FOREACH
            SELECT folio,f_solicitud_arch,TO_CHAR(f_inicial,'%d/%m/%Y'),TO_CHAR(f_final,'%d/%m/%Y'),status_arch
            INTO vFolio, vFsolicitud, vFinicial, vFfinal, vStatus
            FROM informix.bei_consulta_mov
            WHERE empresa = pEmpresa 
            AND num_cliente = pNum_cliente
            AND status_arch != '07'
            ORDER BY folio DESC

            RETURN cod_ret, vFolio, vFsolicitud, vFinicial, vFfinal, vStatus WITH RESUME;
        END FOREACH;
    ELSE
        LET cod_ret = '00003';
        RETURN cod_ret ,'','','','','';
    END IF;
END
END PROCEDURE;