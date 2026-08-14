CREATE PROCEDURE "informix".sp_mueve_movdiarees(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    define pmovtos      integer;
    DEFINE vrowid       integer;
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   let vrowid       = 0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000';
   let pmovtos = 0;

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;

   FOREACH cursor_borra WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
        and num_credito matches '610*'
	and fecha_mov<>today

           BEGIN WORK;
              insert into bdicred:sd_movhiscrd
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
   END FOREACH;


   FOREACH cursor_borra WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
        and num_credito matches '610*'
	and fecha_mov=today

           BEGIN WORK;
              insert into bdicred:sd_movdiacrd
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
   END FOREACH;

  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;