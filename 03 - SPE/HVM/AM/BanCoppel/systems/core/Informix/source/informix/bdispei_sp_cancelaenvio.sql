CREATE PROCEDURE "informix".sp_cancelaenvio(pClaveRastreo VARCHAR(30))
  RETURNING CHAR(5);
{
CREADO POR : Arturo Salinas
FECHA CREACION : 11/Mar/2004
FUNCIONALIDAD : Cancelar pagos de SPEI realizados desde Conciliacion
}

   DEFINE v_row           INTEGER;
   DEFINE v_statusenv     CHAR(1);
   DEFINE v_codret        CHAR(5);
   DEFINE sql_err         INTEGER;
   DEFINE vchrParametro   VARCHAR(255);
   DEFINE vchrFechaHoy    VARCHAR(10);

   SET LOCK MODE TO WAIT 15;

   LET v_row          = 0;
   LET v_codret       = "000";
   LET sql_err        = 0;
   LET v_statusenv    = "";

   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
	    LET v_codret = sql_err;
	    RETURN v_codret;
         END IF
      END EXCEPTION;
      
      --Obtiene la fecha de operacion
      SELECT vchrvalor INTO vchrParametro FROM tblparametros 
        WHERE vchrcveparametro = 'FECHA_OPERACION';
        
      LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) || '/' || 
        SUBSTR(vchrParametro,0,2) || '/' || SUBSTR(vchrParametro,7,4);
      
      --Obtiene datos del pago
      SELECT intpkpago, chrestatusenvio INTO v_row, v_statusenv FROM tblpago
        WHERE vchrClaveRastreo = pClaveRastreo AND dtfechacaptura = vchrFechaHoy;

      IF v_statusenv IS NULL OR v_statusenv = "" THEN
 	 LET v_codret="999";  -- No Existe Usuario Autorizado
	 RETURN v_codret;
      ELSE
         IF v_statusenv = "N" or v_statusenv = "P" THEN  --Si no ha sido enviado
            BEGIN
	       UPDATE tblpago SET chrestatusenvio = "C" WHERE intpkpago = v_row;
            END;
         ELIF v_statusenv = "C" THEN
 	   LET v_codret="000";          -- Movimineto Cancelado
	   RETURN v_codret;
         ELSE
 	   LET v_codret="145";          -- Usuario Autorizado no existe
	   RETURN v_codret;
         END IF;
      END IF;
      RETURN v_codret;
   END
END PROCEDURE;