CREATE PROCEDURE "informix".img_sol_rec(pempresa char(3))
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cliente char(9);
   DEFINE v_cod_docto char(4);
   DEFINE v_secuencia smallint;
   DEFINE sql_err,isam_err int; 
   define v_cuenta char(20);



-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cliente     = "";
   LET v_cod_docto    = "";
   LET v_secuencia = 0;
   let v_cuenta = "";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

--------------------RGH

        SELECT numcte
        FROM bdisolic:ss_solicitudes 
        WHERE empresa = pempresa
        group by numcte
        having count(*) = 1
        into temp clientes_sol with no log;

        SELECT a.num_solicitud, a.numcte 
          FROM bdisolic:ss_solicitudes a, 
               clientes_sol b 
         WHERE empresa = pempresa
           AND status_solicitud= 'CN' 
           and fecha_insert <= mdy('04','04','2011') 
           and a.numcte = b.numcte and num_producto = '6001'
          into temp cuenta_cliente with no log;

        FOREACH WITH HOLD
            SELECT cliente,cod_docto,secuencia, cuenta
            INTO v_cliente, v_cod_docto, v_secuencia, v_cuenta
            FROM bdidigital@coppelimg_tcp:dg_expediente a,
                 cuenta_cliente b
            WHERE empresa = pempresa
            AND a.cuenta = b.num_solicitud
            and a.cliente = b.numcte
            AND producto = '6001'

            BEGIN WORK;

                DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img
                WHERE empresa = pempresa
                AND cliente = v_cliente
                AND cod_docto = v_cod_docto
                AND secuencia = v_secuencia;

                DELETE FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE empresa = pempresa
                AND cliente = v_cliente
                AND cod_docto = v_cod_docto
                and cuenta = v_cuenta
                AND producto = '6001'
                AND secuencia = v_secuencia;

            COMMIT WORK;
        
        END FOREACH;


-------------------------RGH


-------------------------RGH

END;    

RETURN v_codret;

END PROCEDURE;