CREATE PROCEDURE "informix".sp_mueve_movdia(pEmpresa char(3))
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
    DEFINE pprocesos    smallint;
    DEFINE pcuenta      INTEGER;
    DEFINE pcuenta_aux3 INTEGER;
    DEFINE pcontador     SMALLINT;
    DEFINE cred_ini      CHAR(20);
    DEFINE cred_fin      CHAR(20);
    DEFINE prango        CHAR(50);
    DEFINE pparametro    CHAR(3);
    DEFINE cSql          CHAR(200);
    DEFINE vconrador  integer;

    LET credcontproc    = "";
    LET intecontproc    = "";
    LET pfecha          = DATE(1);
    LET vrowid          = 0;   
    LET vhora_mov       = "";
    LET vnumcredito     = "";
    LET vsucursal       = "";
    LET pprocesos       = 0;
    LET pcuenta         = 0;
    LET pcuenta_aux3    = 0;
    LET pcontador    = 0;
    LET cred_ini     = ''; 
    LET cred_fin     = '';
    LET prango       = '';
    LET pparametro   = '';
    LET vconrador    = 1;

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
   let vrowid       = 0;

   --SET DEBUG FILE TO "/resplogifx/archivoscartera/cierre/sp_mueve_movdia.out";
   --TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    SELECT fecha_hoy  
    INTO pfecha
    FROM bdicred:sd_fechas;

    UPDATE bdicred:sd_param
       SET valor = pfecha
     WHERE empresa = pEmpresa
       AND cod_param = '961';

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
         GROUP BY num_credito
          INTO temp paso_mov WITH NO LOG;
      ELSE
        SELECT num_credito
          FROM bdicred:sd_movdia
         WHERE empresa = pEmpresa
           AND fecha_mov = pfecha
         GROUP BY num_credito
          INTO temp paso_mov WITH NO LOG;
      END IF;

      CREATE UNIQUE INDEX inx_paso_mov ON paso_mov(num_credito);
      UPDATE STATISTICS MEDIUM FOR TABLE paso_mov;


     IF (SELECT COUNT(*) FROM paso_mov) > 0 THEN

        -- INI    REALIZA SEGMENTACION DE CREDITOS
           SELECT nvl(valor::integer,0)
             INTO pprocesos
             FROM bdicred:sd_param
            WHERE cod_param = '970';

            SELECT ROUND(COUNT(*) / pprocesos,0)
              INTO pcuenta
              FROM paso_mov;

               LET pcuenta_aux3 = pcuenta;

              FOR pcontador = 1 TO  pprocesos
                   FOREACH
                       SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_credito,'')
                         INTO cred_fin
                         FROM paso_mov
                     ORDER BY num_credito
                   END FOREACH

                    IF pcontador = 1 THEN
                        LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
                        LET cred_ini = cred_fin;
                        LET pparametro = '951';
                    ELSE
                        IF pcontador = pprocesos THEN
                            LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
                            LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            LET cred_ini = cred_fin;
                        END IF;

                        LET pparametro = (pparametro::integer + 1)::varchar(3); 
                    END IF;

                        LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;

                       UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro;
               END FOR;              
        -- FIN    REALIZA SEGMENTACION DE CREDITOS

             DROP TABLE paso_mov;

             LET cSql = '';
        --executa procesos en segundo plano
             --TRACE ON;
             LET cSQL = '/resplogifx/archivoscartera/cierre/eje_movdia_parte.sh';
             SYSTEM cSql;

             --TRACE OFF;

           WHILE vconrador > 0

               -- TRACE ON;

                IF day(pfecha) = '20' THEN
                    SELECT count(*)
                      INTO vconrador
                      FROM bdicred:sd_movdia 
                     WHERE empresa = pEmpresa
                       AND fecha_mov = pfecha
                       AND NOT((codigo_fun = '605' and codigo_ref in (2,3,125,126,127,128))
                        OR  (codigo_fun = '606' and codigo_ref in (1,7018,10,11)) 
                        OR  (codigo_fun = '601' and codigo_ref in (2,1,1100,1101,1102,1103,1104,1105))
                        OR  (codigo_fun = '340' and codigo_ref in (20,22)) 
                        OR  (codigo_fun = '604' and codigo_ref in (2,7001))
                        OR  (codigo_fun = '600' and codigo_ref in (1,7111))
                        OR  (codigo_fun = '602' and codigo_ref in (1,7087,7088,7089,7093,7094,7095,7710)));
                 ELSE
                    SELECT count(*)
                      INTO vconrador
                      FROM bdicred:sd_movdia 
                     WHERE empresa = pEmpresa
                       AND fecha_mov = pfecha;
                 END IF

                --TRACE OFF;

                IF vconrador > 0 THEN
                    LET cSql = '';
            --se espera 10 minutos
                    LET cSQL = 'sleep 180';
                    SYSTEM cSql;
                END IF;

           END WHILE;

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
     ELSE

       UPDATE bdicred:sd_param 
          SET valor = 'No hay registros a procesar ' || pfecha
        WHERE empresa = pEmpresa
          AND cod_param = '951';

           LET cMensaje = "Proceso Concluido";
           LET cCodRet='000';
           let vrowid = 0;

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

     END IF;
  END;
  
 RETURN cCodRet,cMensaje;

END PROCEDURE;