CREATE PROCEDURE "informix".reversion(psucursal CHAR(4), -- Numero de sucursal
			   pusuario CHAR(8),  -- Codigo de usuario
			   pfolvent CHAR(16), -- Folio de Ventanilla
			   pfolprom CHAR(16), -- Folio de promocion
			   porimov  CHAR(1),  -- Origen del movimiento
                           ptipo    CHAR(1))  -- Tipo de reversion
			   RETURNING CHAR(5); -- Codigo de retorno 
{
CREADO POR : Arturo Salinas
FECHA CREACION : 24 de Septiembre del 2003
FUNCIONALIDAD : Reversar pagos de SPEI realizados 
   ya sea por ventanilla o por promocion
MODIFICACION: Daniel Chirinos Lopez
              L-18/sep/2006
              - Se modifico la sucursal de char(3) a char(4)

}
   DEFINE v_row           INTEGER;
   DEFINE v_statusenv     CHAR(1);
   DEFINE v_cveaut        CHAR(16);
   DEFINE v_codret        CHAR(5);
   DEFINE sql_err         INTEGER;
   DEFINE vchrParametro   VARCHAR(255);
   DEFINE vchrFechaHoy    VARCHAR(10);

   SET lock mode to wait 15;

--set debug file to "/tmp/reversion.out";
--trace on;

   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
	    LET v_codret = sql_err;
	    RETURN v_codret;
         END IF
      END EXCEPTION;
     SET isolation to dirty read;
     
     LET v_codret = '000';
     
     --Obtiene la fecha de operacion
     SELECT vchrvalor INTO vchrParametro FROM tblparametros 
        WHERE vchrcveparametro = 'FECHA_OPERACION';
        
     LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) || '/' || 
        SUBSTR(vchrParametro,0,2) || '/' || SUBSTR(vchrParametro,7,4);
     
 
      let v_codret = "000";
      IF ptipo = "A" THEN
            -- Obtiene informacion del pago
            SELECT  chrestatusenvio, vchrclaverastreo
            INTO  v_statusenv, v_cveaut
            FROM tblpago
            WHERE chrfolioprom = pfolprom
                  AND dtfechacaptura = vchrFechaHoy;
                  
            IF v_cveaut IS NULL OR v_cveaut = "" THEN
               LET v_codret = "999";
               RETURN v_codret;
            END IF

            IF porimov = "P" THEN              	--Si el origen de la reversion es Promocion
               IF v_statusenv = "P" THEN       	-- Si el pago esta como Pendiente de Liquidar
                  DELETE FROM tblpago
                    WHERE chrfolioprom = pfolprom
                    AND dtfechacaptura = vchrFechaHoy;
                  LET v_codret = "000";
               ELSE
                  LET v_codret = "145";
               END IF;
            ELSE					-- Si la reversion es desde Ventanilla
               IF v_statusenv = "P" THEN           	-- Pendiente de Liquidar
                  LET v_codret = "000";
               ELIF v_statusenv = "N" THEN  -- Si el pago ya fué liquidado Liquidado
                  LET v_codret      = "000";
                  UPDATE tblpago SET chrestatusenvio = "P",chrfolioliqu = ""
                    WHERE chrfolioprom = pfolprom
                    AND dtfechacaptura = vchrFechaHoy;
               ELSE
                  LET v_codret = "145";			
               END IF ;
            END IF;
            RETURN v_codret;
      ELSE
         LET v_codret = "000";
         --Obtiene datos del pago
         SELECT intpkpago, chrestatusenvio INTO v_row, v_statusenv FROM tblpago
           WHERE chrfolioprom =  pfolprom AND dtfechacaptura = vchrFechaHoy;            

         IF v_row IS NULL OR v_row = "" OR v_row = 0 THEN
            LET v_codret = "999";
            RETURN v_codret;
         END IF;

         IF porimov = "P" THEN          -- Si la reversion es desde Promocion
             IF v_statusenv = "C" THEN  -- Si el pago ya fué Cancelado por Central
                LET v_codret = "000";
             ELSE
                LET v_codret = "145";
             END IF;
          ELSE				-- Si la reversion es desde Ventanilla
            -- Si ya fué autorizada la reversion por AuditoriaAutorizado por Auditoria
            IF v_statusenv = "Z" THEN      	
               LET v_codret = "000";
               UPDATE tblpago SET chrestatusenvio = "C",chrfolioliqu = ""
                 WHERE chrfolioliqu = pfolvent
                   AND dtfechacaptura = vchrFechaHoy;
            ELSE
               LET v_codret = "145";
            END IF ;
         END IF;
         RETURN v_codret;
      END IF;
   END
RETURN v_codret;
END PROCEDURE;