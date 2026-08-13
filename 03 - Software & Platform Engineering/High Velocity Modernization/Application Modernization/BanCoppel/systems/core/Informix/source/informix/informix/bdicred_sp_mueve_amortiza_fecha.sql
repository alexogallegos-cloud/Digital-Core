CREATE PROCEDURE "informix".sp_mueve_amortiza_fecha(pEmpresa char(3), pfecha date)
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

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;

   FOREACH cursor_borra WITH HOLD FOR
        select rowid
         into vrowid
        from bdicred:Sd_amortiza_credito
        where empresa = pEmpresa
        and capital_status = '5' 
        and (capital_fecha_pago is null or capital_fecha_pago <= pfecha)
        and fecha_cuota <= pfecha

           BEGIN WORK;
              DELETE FROM bdicred:Sd_amortiza_credito WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
           let ccontador = ccontador + 1;


   END FOREACH;
   
   let cMensaje = 'Proceso terminado, registros borrados : '|| ccontador;
  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;