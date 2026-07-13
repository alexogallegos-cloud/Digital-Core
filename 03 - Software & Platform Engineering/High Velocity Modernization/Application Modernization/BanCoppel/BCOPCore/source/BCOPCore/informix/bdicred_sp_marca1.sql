CREATE PROCEDURE "informix".sp_marca1()
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cuenta char(20);
   DEFINE sql_err,isam_err int; 

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cuenta    = "";



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

        FOREACH WITH HOLD
            SELECT num_credito
            INTO v_cuenta
            FROM paso_cred_marca1

            BEGIN WORK;

            update bdicred:sd_encabezado_edocta set insertos = '100000000000000' where fecha_emision = today - 3 and num_credito = v_cuenta;

            COMMIT WORK;

        END FOREACH;
END;    

RETURN v_codret;

END PROCEDURE;