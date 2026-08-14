CREATE PROCEDURE "informix".borra_hitorico_credito(pempresa CHAR(3))
RETURNING CHAR(100);

DEFINE cod_ret     CHAR(100);
DEFINE sql_err     INTEGER;

DEFINE v_sql        CHAR(5000);
DEFINE v_sql1       CHAR(1000);
DEFINE v_sql2       CHAR(1000);
DEFINE v_sql3       CHAR(1000);
DEFINE v_sql4       CHAR(800);
DEFINE v_sql5       CHAR(800);
DEFINE vrowid       integer;
define vcontador    integer;

let vrowid       = 0;
let vcontador    = 0;



-- SET DEBUG FILE TO "/pisa/borra_hitorico_credito.out";
-- TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 09/09/2009
--Autor: Roque Enrique Solis Campaña
-- Nodificacion: Se modifico la forma de armar la tabla temporal  sd_paso_cred
--                     Separando los querys.
 
BEGIN

   ON EXCEPTION SET sql_err
          
          LET cod_ret = sql_err;
          rollback work;

          RETURN cod_ret;
   END EXCEPTION;

   FOREACH cursor_borra WITH HOLD FOR
        select rowid 
         into vrowid  
         from bdicred:sd_movhis
        where empresa = '001'
        and fecha_mov < mdy('11','01','2009') 
--        and num_credito = vnum_credito
        and reversado = 'N'
        and ((codigo_fun = '340' and codigo_ref = 22)
        or (codigo_fun = '601' and codigo_ref = 1)
        or (codigo_fun = '601' and codigo_ref = 2)
        or (codigo_fun = '606' and codigo_ref = 1)
        or (codigo_fun = '606' and codigo_ref = 10)
        or (codigo_fun = '606' and codigo_ref = 11)
        or (codigo_fun = '604' and codigo_ref = 2)
        or (codigo_fun = '600' and codigo_ref = 1)
        or (codigo_fun = '602' and codigo_ref = 1)
        or (codigo_fun = '661' and codigo_ref = 50)
        or (codigo_fun = '661' and codigo_ref = 51)
        or (codigo_fun = '665' and codigo_ref = 0)
        or (codigo_fun = '665' and codigo_ref = 1)
        or (codigo_fun = '665' and codigo_ref = 2)
        or (codigo_fun = '665' and codigo_ref = 3)
        or (codigo_fun = '665' and codigo_ref = 4)
        or (codigo_fun = '665' and codigo_ref = 5)
        or (codigo_fun = '665' and codigo_ref = 6)
        or (codigo_fun = '665' and codigo_ref = 7)
        or (codigo_fun = '665' and codigo_ref = 8)
        or (codigo_fun = '665' and codigo_ref = 9)
        or (codigo_fun = '666' and codigo_ref = 0)
        or (codigo_fun = '666' and codigo_ref = 1)
        or (codigo_fun = '666' and codigo_ref = 2)
        or (codigo_fun = '666' and codigo_ref = 3)
        or (codigo_fun = '666' and codigo_ref = 4)
        or (codigo_fun = '666' and codigo_ref = 5)
        or (codigo_fun = '666' and codigo_ref = 6)
        or (codigo_fun = '666' and codigo_ref = 7)
        or (codigo_fun = '666' and codigo_ref = 8)
        or (codigo_fun = '666' and codigo_ref = 9)
        or (codigo_fun = '663' and codigo_ref = 50)
        or (codigo_fun = '663' and codigo_ref = 51)
        or (codigo_fun = '667' and codigo_ref = 0)
        or (codigo_fun = '667' and codigo_ref = 1)
        or (codigo_fun = '667' and codigo_ref = 2)
        or (codigo_fun = '667' and codigo_ref = 3)
        or (codigo_fun = '667' and codigo_ref = 4)
        or (codigo_fun = '667' and codigo_ref = 5)
        or (codigo_fun = '667' and codigo_ref = 6)
        or (codigo_fun = '667' and codigo_ref = 7)
        or (codigo_fun = '667' and codigo_ref = 8)
        or (codigo_fun = '667' and codigo_ref = 9)
        or (codigo_fun = '668' and codigo_ref = 0)
        or (codigo_fun = '668' and codigo_ref = 1)
        or (codigo_fun = '668' and codigo_ref = 2)
        or (codigo_fun = '668' and codigo_ref = 3)
        or (codigo_fun = '668' and codigo_ref = 4)
        or (codigo_fun = '668' and codigo_ref = 5)
        or (codigo_fun = '668' and codigo_ref = 6)
        or (codigo_fun = '668' and codigo_ref = 7)
        or (codigo_fun = '668' and codigo_ref = 8)
        or (codigo_fun = '668' and codigo_ref = 9)
        or (codigo_fun = '070' and codigo_ref = 0)
        or (codigo_fun = '070' and codigo_ref = 1)
        or (codigo_fun = '070' and codigo_ref = 2)
        or (codigo_fun = '070' and codigo_ref = 3)
        or (codigo_fun = '070' and codigo_ref = 4)
        or (codigo_fun = '070' and codigo_ref = 5)
        or (codigo_fun = '071' and codigo_ref = 0)
        or (codigo_fun = '071' and codigo_ref = 1)
        or (codigo_fun = '071' and codigo_ref = 2)
        or (codigo_fun = '071' and codigo_ref = 3)
        or (codigo_fun = '071' and codigo_ref = 4)
        or (codigo_fun = '071' and codigo_ref = 5)
        or (codigo_fun = '660' and codigo_ref = 0)
        or (codigo_fun = '660' and codigo_ref = 1)
        or (codigo_fun = '660' and codigo_ref = 2)
        or (codigo_fun = '660' and codigo_ref = 3)
        or (codigo_fun = '660' and codigo_ref = 4)
        or (codigo_fun = '661' and codigo_ref = 0)
        or (codigo_fun = '661' and codigo_ref = 1)
        or (codigo_fun = '661' and codigo_ref = 2)
        or (codigo_fun = '661' and codigo_ref = 3)
        or (codigo_fun = '661' and codigo_ref = 4)
        or (codigo_fun = '661' and codigo_ref = 5)
        or (codigo_fun = '661' and codigo_ref = 6)
        or (codigo_fun = '661' and codigo_ref = 7)
        or (codigo_fun = '661' and codigo_ref = 8)
        or (codigo_fun = '661' and codigo_ref = 9)
        or (codigo_fun = '663' and codigo_ref = 0)
        or (codigo_fun = '663' and codigo_ref = 1)
        or (codigo_fun = '663' and codigo_ref = 2)
        or (codigo_fun = '663' and codigo_ref = 3)
        or (codigo_fun = '663' and codigo_ref = 4)
        or (codigo_fun = '664' and codigo_ref = 0)
        or (codigo_fun = '664' and codigo_ref = 1)
        or (codigo_fun = '664' and codigo_ref = 2)
        or (codigo_fun = '664' and codigo_ref = 3)
        or (codigo_fun = '664' and codigo_ref = 4)
        or (codigo_fun = '664' and codigo_ref = 5)
        or (codigo_fun = '664' and codigo_ref = 6)
        or (codigo_fun = '664' and codigo_ref = 7)
        or (codigo_fun = '664' and codigo_ref = 8)
        or (codigo_fun = '664' and codigo_ref = 9))

           BEGIN WORK;
              DELETE FROM bdicred:sd_movhis WHERE CURRENT OF cursor_borra;
              let vcontador = vcontador + 1;
              if mod(vcontador,1000) = 0 THEN
                  update bdicred:sd_param 
                     set valor = vcontador
                   where empresa = pempresa
                     and cod_param = 'M06'; 
              END IF;
           COMMIT WORK;

  END FOREACH;

   LET cod_ret = "000 Reg. Procesados: " || vcontador;

	
  END;
  RETURN cod_ret;

END PROCEDURE;