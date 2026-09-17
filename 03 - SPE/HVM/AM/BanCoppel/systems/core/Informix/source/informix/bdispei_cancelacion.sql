CREATE PROCEDURE "informix".cancelacion(psucursal CHAR(4), --Numero de sucursal
			     pusuario  CHAR(8),  -- Codigo de usuario
			     pfolprom  CHAR(16), -- Folio de promocion
			     pfolliq   CHAR(16), -- Folio de Liquidacion
			     porimov   CHAR(1))  -- Origen de la cancelacion
			     RETURNING CHAR(5);  -- Codigo de retorno
{
CREADO POR : Arturo Salinas
FECHA CREACION : 24 de Septiembre del 2003
FUNCIONALIDAD : Cancelar pagos de SPEI realizados 
   ya sea por ventanilla o por promocion
MODIFICACION: Daniel Chirinos Lopez
              L-18/sep/2006
              - Se modifico la sucursal de char(3) a char(4)
}

   DEFINE v_row           INTEGER;
   DEFINE v_statusenv     CHAR(1);
   DEFINE v_codret        CHAR(5);
   DEFINE v_ejecutivo     CHAR(8);
   DEFINE sql_err         INTEGER;
   DEFINE vchrParametro   VARCHAR(255);
   DEFINE vchrFechaHoy    VARCHAR(10);

   SET LOCK MODE TO WAIT 15;

   LET v_row          = 0;
   LET v_codret       = "000";
   LET v_ejecutivo    = "";
   LET sql_err        = 0;
   LET v_statusenv    = "";

--   SET DEBUG FILE TO "/tmp/cancelacion.out";
--   TRACE ON;

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
      
      IF porimov = "V" THEN -- Si la cancelacion viene desde Ventanilla
        --Obtiene datos del pago
        SELECT intpkpago, chrestatusenvio INTO v_row, v_statusenv FROM tblpago
          WHERE chrfolioliqu = pfolliq AND dtfechacaptura = vchrFechaHoy;
      ELSE  --Si la reversion es de promocion
        --Obtiene datos del pago
        SELECT intpkpago, chrestatusenvio INTO v_row, v_statusenv FROM tblpago
          WHERE chrfolioprom = pfolprom AND dtfechacaptura = vchrFechaHoy;
      END IF;
      IF v_statusenv IS NULL OR v_statusenv = "" THEN
 	 LET v_codret="999";  -- No Existe Usuario Autorizado
	 RETURN v_codret;
      ELSE
         IF v_statusenv = "Z" THEN  --Si la cancelacion ya fué autorizada
            BEGIN
	       UPDATE tblpago SET chrestatusenvio = "C",chrfoliolique = ""
	       WHERE intpkpago = v_row;
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