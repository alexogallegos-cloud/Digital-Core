CREATE PROCEDURE "informix".sp_borrarever(pEmpresa char(3))

    RETURNING CHAR(3),VARCHAR(200,1);


  DEFINE CodRet         CHAR(3);
  DEFINE sql_err        SMALLINT;
  DEFINE scod_ret       CHAR(3);
  DEFINE vMensaje       VARCHAR(200,1);
  DEFINE Mensaje        VARCHAR(200,1);
  DEFINE FechaHoy       DATE ;
  DEFINE isam_err       INTEGER;
  DEFINE Valcontproc   	CHAR(10);
  DEFINE Valsdcontproc	CHAR (10);

-- ASIGNACION DE VARIABLES
  LET CodRet     	= '000';
  LET sql_err    	= 0;
  LET scod_ret   	= '000';
  LET vMensaje   	= " ";
  LET Mensaje   	= " ";
  LET FechaHoy   	= " ";
  LET isam_err    	= 0;
  LET Valcontproc   = ' ';
  LET Valsdcontproc = ' ';

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,vMensaje
      LET scod_ret = sql_err;
      RETURN scod_ret,vMensaje;
   END EXCEPTION;
  
SELECT fecha_hoy
          INTO FechaHoy
          FROM "informix".sd_fechas
          WHERE empresa = pEmpresa;

SELECT proceso  
        INTO Valcontproc
        FROM bdinteg:"informix".sx_contproc
        WHERE fecha= FechaHoy and proceso ='BorraRever';


SELECT proceso  
        INTO Valsdcontproc
        FROM bdicred:"informix".sd_contproc
        WHERE fecha= FechaHoy and proceso ='BorraRever';

IF (Valcontproc = ' ' OR Valcontproc  IS NULL)   AND (Valsdcontproc = ' ' OR Valsdcontproc  IS NULL) THEN

                  INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
                  VALUES (pEmpresa,'BorraRever',FechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
                  INSERT INTO  "informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
                  VALUES (pEmpresa,'BorraRever',FechaHoy,'I','informix',CURRENT,CURRENT,'000',vMensaje);

END IF;

-- Se agregan las tablas de reversion. 27/02/2012 --
TRUNCATE table "informix".sd_maecredrevcrd;
TRUNCATE table "informix".sd_maesdosrevcrd;
TRUNCATE table "informix".sd_maecredanexorevcrd;
TRUNCATE table "informix".sd_amortiza_creditorevcrd;
TRUNCATE table "informix".sd_linea_prestamorev; --CAX 2025
----------------------------------------------------
TRUNCATE table "informix".sd_maecredrev;    
TRUNCATE table "informix".sd_maesdosrev;  
TRUNCATE table "informix".sd_detmorarev;     
TRUNCATE table "informix".sd_detcomirev;
TRUNCATE table "informix".sd_maecredanexorev;     
TRUNCATE table "informix".sd_amortiza_creditorev;     
TRUNCATE table "informix".sd_secpago;  

 IF scod_ret <> "000" THEN
            LET vMensaje = "Fallo proceso";
            LET scod_ret =  scod_ret;
            UPDATE "informix".sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = CodRet,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'BorraRever'
               AND fecha       = FechaHoy;

            UPDATE bdinteg:"informix".sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = scod_ret
             WHERE empresa = pEmpresa
               AND proceso  = 'BorraRever'
               AND fecha    = FechaHoy;

    ELSE
          LET vMensaje = "Proceso Concluido";
            UPDATE "informix".sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = scod_ret,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'BorraRever'
               AND fecha       = FechaHoy;

          UPDATE bdinteg:"informix".sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = scod_ret
           WHERE empresa = pEmpresa
            AND proceso  = 'BorraRever'
            AND fecha    = FechaHoy;
    END IF
	
    END;
    RETURN scod_ret,vMensaje;
END PROCEDURE;