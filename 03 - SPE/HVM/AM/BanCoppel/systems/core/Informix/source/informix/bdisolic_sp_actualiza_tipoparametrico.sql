CREATE PROCEDURE "informix".sp_actualiza_tipoparametrico(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet          char(6);
    DEFINE cMensaje         char(80);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE cnumsolicitud    char(20);
    DEFINE intecontproc     char(10);
    DEFINE pfecha           date;    
    DEFINE vrowid           integer;

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid       = 0;
-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

   FOREACH with hold
        select num_solicitud
          into cnumsolicitud
          from bdisolic:ss_solicitudes 
         where status_solicitud<>'AN'
           and tipo_calculo is null

           BEGIN WORK;
            UPDATE bdisolic:ss_solicitudes  SET tipo_calculo='1' WHERE empresa=pEmpresa and num_solicitud=cnumsolicitud;
           COMMIT WORK;
        
   END FOREACH;
  END;
  RETURN cCodRet,cMensaje;

END PROCEDURE;