CREATE PROCEDURE "informix".sp_mueve_factura(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE pfecha       date;    
    DEFINE vrowid       integer;
    DEFINE vsSQL1		CHAR(100);
    DEFINE wBandera     CHAR(01);
    DEFINE cSql         CHAR(200);
	DEFINE vnumcredito  CHAR(20);
    LET credcontproc    = "";
    LET intecontproc    = "";
    LET pfecha          = DATE(1);
    LET vsSQL1	        = "";
    LET wBandera        = "";
    LET cSql = '';
	LET vnumcredito    = "";
  

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid       = 0;
--  SET DEBUG FILE TO "/pisa/leo/sp_mueve_factura.out";
--  TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

    SELECT fecha_hoy  
    INTO pfecha
    FROM bdicred:sd_fechas;

    SELECT NVL(status_proc,'')
      INTO wBandera
      FROM bdinteg:sx_contproc
     WHERE fecha= pfecha 
       AND proceso ='Trasl_Dia';

       IF wBandera = '' OR wBandera is NULL THEN
          LET wBandera = '';
       END IF;

    WHILE wBandera <> 'F'

        LET cSql = '';
        LET wBandera = '';
        LET cSQL = 'sleep 180';
        SYSTEM cSql;

        SELECT NVL(status_proc,'')
          INTO wBandera
          FROM bdinteg:sx_contproc
         WHERE fecha= pfecha 
           AND proceso = 'Trasl_Dia';

           IF wBandera = '' OR wBandera is NULL THEN
              LET wBandera = '';
           END IF;

    END WHILE;


            SELECT num_credito
              FROM bdicred:sd_movdia
             WHERE empresa = pEmpresa
               AND fecha_mov = pfecha
             GROUP BY num_credito
              INTO temp paso_factura WITH NO LOG;

              CREATE UNIQUE INDEX inx_paso_factura ON paso_factura(num_credito);
              UPDATE STATISTICS MEDIUM FOR TABLE paso_factura;

           FOREACH WITH HOLD 
                SELECT num_credito
                 INTO vnumcredito
                 FROM paso_factura

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