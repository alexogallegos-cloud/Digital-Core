CREATE PROCEDURE "informix".sp_mueve_movdia20mar(pEmpresa char(3))
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

    LET credcontproc    = "";
    LET intecontproc    = "";
    LET pfecha          = DATE(1);
    LET vsSQL1	        = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid       = 0;
-- SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_mueve_movdia.out";
-- TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

        SELECT fecha_hoy  
        INTO pfecha
        FROM bdicred:sd_fechas;
        LET pfecha="03202012"; 	
        SELECT proceso  
        INTO intecontproc
        FROM bdinteg:sx_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Dia';

        SELECT proceso  
        INTO credcontproc
        FROM bdicred:sd_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Dia';

    IF (intecontproc = ' ' OR intecontproc  IS NULL)  AND (credcontproc = ' ' OR credcontproc  IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001','Trasl_Dia',pfecha,'06','I','informix',CURRENT,CURRENT,'000');

      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','Trasl_Dia',pfecha,'I','informix',CURRENT,CURRENT,'000',cMensaje);
    END IF;


---LHM SE PARAMETRIZA PARA EL DIA 20 LA EJECUCION DE mueve20.sh
   IF day(pfecha) = '20' then 

       LET vsSQL1 =  "chmod 777 /resplogifx/archivoscartera/mueve20.sh";
       SYSTEM vsSQL1;
       LET vsSQL1 = '' ;
       LET vsSQL1 =  "/resplogifx/archivoscartera/mueve20.sh";
       SYSTEM vsSQL1;

   END IF;

   FOREACH cursor_borra WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
          and fecha_mov=pfecha
          and secuencia <= (select MIN(SECUENCIA) from bdicred:sd_movdia where empresa = pEmpresa and fecha_mov=pfecha and hora_mov >= '22:30:00')

           BEGIN WORK;
              insert into bdicred:sd_movhis
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra;
           COMMIT WORK;

   END FOREACH;

   FOREACH cursor_borra2 WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
          and fecha_mov=pfecha

           BEGIN WORK;
              insert into bdicred:sd_movhis
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra2;
           COMMIT WORK;

   END FOREACH;



    IF cCodRet <> '000' THEN
            LET cMensaje = "Fallo proceso";
            LET cCodRet =  cCodRet;
            UPDATE sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Dia'
               AND fecha       = pfecha;

            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = cCodRet
             WHERE empresa = pEmpresa
               AND proceso  = 'Trasl_Dia'
               AND fecha    = pfecha;

    ELSE
          LET cMensaje = "Proceso Concluido";
            UPDATE sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Dia'
               AND fecha       = pfecha;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'Trasl_Dia'
            AND fecha    = pfecha;
    END IF 

  END;

 RETURN cCodRet,cMensaje;

END PROCEDURE;