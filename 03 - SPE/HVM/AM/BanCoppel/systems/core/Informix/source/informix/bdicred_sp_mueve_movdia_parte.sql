CREATE PROCEDURE "informix".sp_mueve_movdia_parte(pEmpresa char(3), pEjecucion smallint)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE pfecha       date;    
    DEFINE vrowid       integer;
    DEFINE vnumcredito  CHAR(20);
    DEFINE vhora_mov    DATETIME HOUR to FRACTION(3);
    DEFINE vsucursal    CHAR(4);
    DEFINE cred_ini     CHAR(20);
    DEFINE cred_fin     CHAR(20);

    LET credcontproc    = "";
    LET intecontproc    = "";
    LET pfecha          = DATE(1);
    LET vrowid          = 0;   
    LET vhora_mov       = "";
    LET vnumcredito     = "";
    LET vsucursal       = "";
    LET cred_ini        = ''; 
    LET cred_fin        = ''; 

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid  = 0;
-- SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_mueve_movdia.out";
-- TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    SELECT valor::date
     INTO pfecha
     FROM bdicred:sd_param 
    where empresa = pEmpresa
      and cod_param = '961';

    SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) 
     INTO cred_ini, cred_fin
     FROM bdicred:sd_param 
    WHERE cod_param = (950 + pEjecucion)::CHAR(3);         

-- Cuentas a procesar
    IF day(pfecha) = '20' then 
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
           and num_credito >= cred_ini
           and num_credito  < cred_fin
         GROUP BY num_credito
          INTO temp paso_mov WITH NO LOG;
      ELSE
        SELECT num_credito
          FROM bdicred:sd_movdia
         WHERE empresa = pEmpresa
           AND fecha_mov = pfecha
           and num_credito >= cred_ini
           and num_credito  < cred_fin
         GROUP BY num_credito
          INTO temp paso_mov WITH NO LOG;
      END IF;

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

   DROP TABLE paso_mov;

  END;
  
 RETURN cCodRet,cMensaje;

END PROCEDURE;