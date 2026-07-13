CREATE PROCEDURE "informix".sp_mueve_movdiacrd(pEmpresa char(3))
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

    LET pfecha       = DATE(1);
    LET vrowid       = 0;   
    LET vnumcredito  = "";
    LET vhora_mov    = "";
    LET vsucursal    = "";
	LET credcontproc = "";
    LET intecontproc = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciando Traslado Movtos_crd";
   LET cCodRet='000';
 --SET DEBUG FILE TO "/tmp/sp_mueve_movdia.out";
 --TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

        SELECT fecha_hoy  
        INTO pfecha
        FROM bdicred:sd_fechas;


        SELECT proceso  
        INTO intecontproc
        FROM bdinteg:sx_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Diacrd';

        SELECT proceso  
        INTO credcontproc
        FROM bdicred:sd_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Diacrd';

    IF (intecontproc = ' ' OR intecontproc  IS NULL)  AND (credcontproc = ' ' OR credcontproc  IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001','Trasl_Diacrd',pfecha,'06','I','informix',CURRENT,CURRENT,'000');

      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','Trasl_Diacrd',pfecha,'I','informix',CURRENT,CURRENT,'000',cMensaje);
    else
   	LET cMensaje="YA EJECUTADO ANTERIORMENTE";
    LET cCodRet ='009';  --FMV 12ago13: Ya se ejecuto traslado diario
 	RETURN cCodRet,cMensaje;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SELECT * FROM bdicred:sd_movdiacrd
     WHERE empresa = pEmpresa 
	   AND fecha_mov = pfecha
      INTO temp movdiacrd1 WITH NO LOG;


    CREATE INDEX idxmovdiacrd1 on movdiacrd1(empresa, secuencia, fecha_mov, hora_mov, sucursal, num_credito);
    CREATE INDEX idxmovdiacrd2 on movdiacrd1(num_credito,secuencia);

   FOREACH WITH HOLD
        SELECT secuencia, hora_mov, sucursal, num_credito
          INTO vrowid ,vhora_mov,vsucursal,vnumcredito
          FROM movdiacrd1


           BEGIN WORK;
              INSERT INTO bdicred:sd_movhiscrd
              SELECT * FROM movdiacrd1 WHERE num_credito = vnumcredito AND secuencia = vrowid;

              DELETE FROM bdicred:sd_movdiacrd WHERE secuencia = vrowid
                                                AND  fecha_mov = pfecha
                                                AND  hora_mov = vhora_mov
                                                AND  sucursal = vsucursal
                                                AND  num_credito = vnumcredito;
           COMMIT WORK;

        LET vrowid     = 0;
        LET vhora_mov  = "";
        LET vsucursal  = "";
        LET vnumcredito = "";
        
   END FOREACH;
   
    IF cCodRet <> '000' THEN
            LET cMensaje = "Fallo proceso, validar bitacoras";
            LET cCodRet =  cCodRet;
            UPDATE sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Diacrd'
               AND fecha       = pfecha;

            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = cCodRet
             WHERE empresa = pEmpresa
               AND proceso  = 'Trasl_Diacrd'
               AND fecha    = pfecha;
            RETURN cCodRet,cMensaje;
    ELSE
          LET cMensaje = "Proceso Concluido Correctamente";
            UPDATE sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Diacrd'
               AND fecha       = pfecha;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'Trasl_Diacrd'
            AND fecha    = pfecha;
    END IF 

  END; 

  DROP TABLE movdiacrd1;

 RETURN cCodRet,cMensaje;

END PROCEDURE;