CREATE PROCEDURE "informix".cons_inv_pagare( pempresa CHAR(3),
                                        pnum_cte CHAR(20),
                                        pRegistro SMALLINT )
   RETURNING CHAR(5),CHAR(4), CHAR(20), DATE;

--Autor: Walber Castro
--Fecha: 18/10/2010
--Solicito: Diana Castellanos
--Descripcion: Se crea para consultar las cuentas de inversión pagaré activas del cliente

--Autor:Francisco Rodríguez Ibarra
--Fecha:11-04-2011
--Solicito:Mauricio León
--Descripción: Se modifico sp para retornar el id del producto
-- ***************************************************************************
-- Define variables
-- ***************************************************************************

   DEFINE cod_ret       CHAR(5);
   DEFINE v_cuenta      CHAR(20);   
   DEFINE v_producto    CHAR(4);
   DEFINE sql_err       INTEGER;
   DEFINE vRegistros    INTEGER;
   DEFINE  iCont        INTEGER;
   DEFINE v_fecha_venc date;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET v_cuenta      = " ";   
   LET v_producto    = " ";
   LET iCont    	 = 0;
   LET vRegistros    = 0;
   LET v_fecha_venc  = "          ";

--set debug file to "cons_inv_pagare.out";
--trace on;

BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, v_producto,v_cuenta, v_fecha_venc;
        END IF
    END EXCEPTION;

    IF ( pempresa = '' OR pempresa IS NULL OR pnum_cte = '' OR
         pnum_cte IS NULL OR pRegistro = '' OR pRegistro IS NULL ) THEN

        LET cod_ret = 100; --Parametros no validos.
        RETURN cod_ret,v_producto, v_cuenta, v_fecha_venc;
    END IF

    SET ISOLATION DIRTY READ;

    FOREACH

        SELECT SKIP pRegistro FIRST 10 cuenta,fecha_venc,cod_instrum
        INTO v_cuenta, v_fecha_venc,v_producto
        FROM Bdinvers:sv_maeinv
        WHERE num_cte = pnum_cte AND status_cta IN ('1','3')

        LET iCont = iCont + 1;
        RETURN cod_ret,v_producto, v_cuenta, v_fecha_venc WITH RESUME;

    END FOREACH;

    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET cod_ret = 101; --Cliente No tiene cuentas
        RETURN cod_ret,v_producto,v_cuenta, v_fecha_venc;
    END IF
END
END PROCEDURE
;