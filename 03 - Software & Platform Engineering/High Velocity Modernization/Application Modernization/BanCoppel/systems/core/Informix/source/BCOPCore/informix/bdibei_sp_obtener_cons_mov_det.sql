CREATE PROCEDURE "informix".sp_obtener_cons_mov_det(pFolio CHAR(25)) 
    RETURNING CHAR(5) AS cod_ret, CHAR(25) AS folio, CHAR(20) AS cuenta, CHAR(10) AS f_inicial,
    CHAR(10) AS f_final, CHAR(20) AS total_registros, CHAR(30) AS nombre;
--****************************************************************************************************
-- DESCRIPCION: Obtener el Detalle de Movimientos de la cuenta del cliente
-- AUTOR : Jose Leon Arellano 
-- FECHA : 14/Julio/2016
-- BD: bdibei
-- FECHA DE LIBERACIÓN: 
--****************************************************************************************************
    -- Definicion de variables
    DEFINE vFolio CHAR(25);
    DEFINE vCuenta CHAR(20);
    DEFINE vFinicial CHAR(10);
    DEFINE vFfinal CHAR(10);
    DEFINE vTotalReg CHAR(20);
    DEFINE vNombre CHAR(30);
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    LET cod_ret = '00000';
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret ,'','','','','','';
      END IF;
	END EXCEPTION;

    -- Validar que se recibe el folio
    IF NVL(pFolio,'')=='' THEN
        LET cod_ret = '00001';
        RETURN cod_ret ,'','','','','','';
    END IF;

    -- Validar que existe detalle de la consulta
    IF EXISTS (SELECT folio,cuenta,TO_CHAR(f_inicial,'%d/%m/%Y'),TO_CHAR(f_final,'%d/%m/%Y'),total_registros,nombre
                FROM informix.bei_consulta_mov
            WHERE folio = pFolio
            AND status_arch != '07') THEN
            -- Obtener el detalle existente
            SELECT folio,cuenta,TO_CHAR(f_inicial,'%d/%m/%Y'),TO_CHAR(f_final,'%d/%m/%Y'),total_registros,nombre
            INTO vFolio, vCuenta, vFinicial, vFfinal, vTotalReg, vNombre
            FROM informix.bei_consulta_mov
            WHERE folio = pFolio
            AND status_arch != '07';

            RETURN cod_ret, vFolio, vCuenta, vFinicial, vFfinal, vTotalReg, vNombre;
    ELSE
        LET cod_ret = '00002';
        RETURN cod_ret ,'','','','','','';
    END IF;

END
END PROCEDURE;