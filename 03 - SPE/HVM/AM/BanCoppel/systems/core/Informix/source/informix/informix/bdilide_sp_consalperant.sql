CREATE PROCEDURE "informix".sp_consalperant(pNumCte CHAR(20), pPeriodo1 CHAR(6), pPeriodo2 CHAR(6))
    -- DATOS A REGRESAR
	RETURNING CHAR(5), MONEY;

    -- DEFINICION DE VARIABLES
    DEFINE vCodRet CHAR(5);
    DEFINE vcPeriodosAnt MONEY;
    DEFINE vsqlerr  integer;
    DEFINE vcIniciaTran CHAR(1);

	--INICIALIZACION DE VARIABLES
    LET vCodRet = "00000";
    LET vcPeriodosAnt = 0.00;
    LET vsqlerr = 0;
    LET vcIniciaTran = 'N';

     BEGIN

        ON EXCEPTION  SET vsqlerr
                IF vsqlerr <> 0  THEN                  
                     LET  vCodRet  = vsqlerr;
                     RETURN vCodRet, vcPeriodosAnt;
                END IF;
         END  EXCEPTION;

       -- SET DEBUG FILE TO "/tmp/sp_ConSalPerAnt.out";
        --TRACE ON;

        -- SE OBTIENE EL IMPUESTO RECAUDADO DE LOS MESES ANTERIORES EN EL MES ACTUAL.
         SELECT nvl(SUM(imp_recaudado), 0.00)
          INTO vcPeriodosAnt
          FROM bdilide:sl_detlide
          WHERE CAST(TO_CHAR(fecha_ret, '%Y%m') as char(6))  <  pPeriodo2  AND aniomes =  pPeriodo1 AND num_cte = pNumCte; 
     
            RETURN vCodRet, vcPeriodosAnt;
    END;
END PROCEDURE
;