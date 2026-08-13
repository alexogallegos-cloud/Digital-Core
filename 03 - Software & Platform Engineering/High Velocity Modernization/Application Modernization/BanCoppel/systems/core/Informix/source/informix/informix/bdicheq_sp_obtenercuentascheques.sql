CREATE PROCEDURE "informix".sp_obtenercuentascheques(pempresa CHAR(3),pnum_cte CHAR(9),pProducto CHAR(4),pmoneda CHAR(2),pRegistro SMALLINT)
RETURNING CHAR(5),CHAR(20),money(14,2);
    
    --*******************************************
    --sp_obtenerCuentasCheques
    --Objetivo: obtener las cuentas efectiva cheques, de un cliente especifico
    --Autor: Francisco Rodriguez Ibarra
    --Fecha: 30 marzo 2010
    --*********************************************
    
    --Declaracion de variables
    DEFINE vSqlErr 		INTEGER;
    DEFINE cod_ret  	CHAR(5);
    DEFINE v_cuenta		CHAR(20);
    DEFINE vSdoCta      money(14,2);
    DEFINE vRegistros    INTEGER;
    DEFINE iCont		INTEGER;
    
    --Asignacion de Valores a Variables
    LET cod_ret='00000';
    LET vSqlErr = 0;
    LET v_cuenta ='';
    LET vSdoCta = 0;
    LET iCont=0;
    LET vRegistros=0;

    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cod_ret = vSqlErr;
            --ROLLBACK WORK;
            RETURN cod_ret, v_cuenta, vSdoCta;
        END IF;
    END EXCEPTION;

    IF ( pempresa = '' OR pempresa IS NULL OR pnum_cte = '' OR
         pnum_cte IS NULL OR pmoneda = '' OR pmoneda IS NULL OR
         pRegistro = '' OR pRegistro IS NULL) THEN
        LET cod_ret = 100; --Parametros no validos.
        RETURN cod_ret, v_cuenta, vSdoCta;
    END IF

    SET ISOLATION DIRTY READ;

    FOREACH
        SELECT SKIP pRegistro FIRST 10 cuenta,sdo_actual
          INTO v_cuenta ,vSdoCta
          FROM bdicheq:sc_maechq  
         WHERE empresa = TRIM(pempresa)
           AND producto = TRIM(pProducto) 
           AND num_cte = TRIM(pnum_cte)
           AND status_cta NOT IN('2','6','7','8')

        LET iCont = iCont + 1;
        RETURN cod_ret, v_cuenta, vSdoCta WITH RESUME;
    END FOREACH

    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET cod_ret = 101; -- Cliente No tiene cuentas
        RETURN cod_ret, v_cuenta, vSdoCta;
    END IF

    END;
    
END PROCEDURE;