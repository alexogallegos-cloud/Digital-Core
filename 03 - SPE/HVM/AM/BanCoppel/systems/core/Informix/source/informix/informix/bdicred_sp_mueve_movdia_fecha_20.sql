CREATE PROCEDURE "informix".sp_mueve_movdia_fecha_20(pEmpresa char(3), pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE cnumcredito  char(20);
    DEFINE ccontador    integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    define pmovtos      integer;
    DEFINE vrowid       integer;
    DEFINE vnumcredito  CHAR(20);
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   let vrowid       = 0;
   LET ccontador=0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000';
   let pmovtos = 0;
   LET vnumcredito     = "";

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

    SELECT num_credito
      FROM bdicred:sd_movdia
     WHERE empresa = pEmpresa
       AND fecha_mov = pfecha
	   AND NOT((codigo_fun = '605' and codigo_ref in (2,3,125,126,127,128))
		OR  (codigo_fun = '606' and codigo_ref in (1,7018,10,11)) 
		OR  (codigo_fun = '601' and codigo_ref in (2,1,1100,1101,1102,1103,1104,1105))
		OR  (codigo_fun = '340' and codigo_ref in (20,22)) 
		OR  (codigo_fun = '604' and codigo_ref in (2,7001))
		OR  (codigo_fun = '600' and codigo_ref in (1,7111))
		OR  (codigo_fun = '602' and codigo_ref in (1,7087,7088,7089,7093,7094,7095,7710)))
     GROUP BY num_credito
      INTO temp paso_mov WITH NO LOG;

      CREATE UNIQUE INDEX inx_paso_mov ON paso_mov(num_credito);
      UPDATE STATISTICS MEDIUM FOR TABLE paso_mov;

       FOREACH WITH HOLD 
            SELECT num_credito
             INTO vnumcredito
             FROM paso_mov

               BEGIN WORK;
                  INSERT INTO bdicred:sd_movhis
                  SELECT * FROM bdicred:sd_movdia 
                   WHERE fecha_mov = pfecha
                     AND num_credito = vnumcredito;

                  DELETE FROM bdicred:sd_movdia                
                   WHERE fecha_mov = pfecha
                     AND num_credito = vnumcredito;
               COMMIT WORK;

       END FOREACH;
  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;