CREATE PROCEDURE "informix".sp_mueve_movdiacrd_pase_pba(pEmpresa char(3),pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE vrowid       integer;   
    DEFINE vnumcredito  CHAR(20);
    DEFINE vfolio_suc   CHAR(16);
    DEFINE vfecha_mov   DATE;
    DEFINE vhora_mov    DATETIME HOUR to FRACTION(3);
    DEFINE vsucursal    CHAR(4);


    LET vnumcredito  = "";
    LET vrowid       = 0;   
    LET vnumcredito  = "";
    LET vfolio_suc   = "";
    LET vfecha_mov   = DATE(1);
    LET vhora_mov    = "";
    LET vsucursal    = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';

SET DEBUG FILE TO "sp_mueve_movdiacrd_pase.trc";
TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

    set isolation to dirty read;
    SELECT {+INDEX(sd_movdiacrd idx_sd_movdiacrd)} * FROM sd_movdiacrd
    WHERE empresa = pEmpresa 
      AND fecha_mov = pfecha
     INTO temp movdiacrd1 WITH NO LOG;


    CREATE INDEX idxmovdiacrd1 on movdiacrd1(empresa, secuencia, fecha_mov, hora_mov, sucursal, num_credito);
    CREATE INDEX idxmovdiacrd2 on movdiacrd1(num_credito,secuencia);

   FOREACH WITH HOLD
        SELECT secuencia, fecha_mov, hora_mov, sucursal, num_credito
          INTO vrowid ,vfecha_mov,vhora_mov,vsucursal,vnumcredito
          FROM movdiacrd1

           BEGIN WORK;
              INSERT INTO bdicred:sd_movhiscrd
              SELECT * FROM bdicred:movdiacrd1 where num_credito = vnumcredito and  secuencia = vrowid;

              DELETE FROM bdicred:sd_movdiacrd WHERE secuencia = vrowid
                                                AND  fecha_mov = vfecha_mov
                                                AND  hora_mov = vhora_mov
                                                AND  sucursal = vsucursal
                                                AND  num_credito = vnumcredito;
           COMMIT WORK;

        LET vrowid     = 0;
        LET vfecha_mov = "";
        LET vhora_mov  = "";
        LET vsucursal  = "";
        LET vnumcredito = "";
        
   END FOREACH;
   
  END;

 RETURN cCodRet,cMensaje;

END PROCEDURE;