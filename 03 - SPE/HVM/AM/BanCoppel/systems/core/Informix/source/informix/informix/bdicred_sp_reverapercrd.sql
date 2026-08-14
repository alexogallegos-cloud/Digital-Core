CREATE PROCEDURE "informix".sp_reverapercrd(P_EMPRESA   CHAR(3),
                                            P_SOLICITUD CHAR(20))
RETURNING VARCHAR(8),    --CodRet
          VARCHAR(80);   --Mensaje

                             --Variables

  DEFINE P_ERROR       VARCHAR(8);
  DEFINE P_MENSAJE     VARCHAR(80);
  DEFINE V_FOLIO       VARCHAR(16);
  DEFINE v_folio_old   VARCHAR(16);
  DEFINE v_credito_old VARCHAR(20);
  DEFINE vnum_credito  CHAR(20);
  DEFINE vlongcred     SMALLINT;
  DEFINE vusuario      CHAR(8);
  DEFINE vsucursal     CHAR(4);





BEGIN

      --Set debug file to '/tmp/rever.out';
      --trace on;

      LET P_ERROR      = '00000';
      LET P_MENSAJE    = 'PROCESO EXITOSO';
      LET vnum_credito = P_SOLICITUD;

      SELECT UNIQUE FOLIO_SUC,usuario,sucursal
      INTO V_FOLIO,vusuario,vsucursal
      FROM sd_movdia
      WHERE empresa = P_EMPRESA
      AND num_credito = P_SOLICITUD
      AND codigo_fun = "001";

                           --** Reversion De Cheques

      EXECUTE PROCEDURE BDICHEQ:REVERSION(P_EMPRESA, "001", vusuario, V_FOLIO,"B")
      INTO P_ERROR;

      IF P_ERROR <> "000" THEN
	LET P_MENSAJE = "REVERSION DE AHORROS";
	RETURN P_ERROR, P_MENSAJE;
      END IF

                      --** Reversion De Credito Liquidacion



      EXECUTE PROCEDURE reversioncrd(P_EMPRESA,vsucursal,vusuario,v_FOLIO,'B')
      INTO P_ERROR;

      IF P_ERROR <> "000" THEN
	LET P_MENSAJE = "REVERSION DE CREDITO";
	RETURN P_ERROR, P_MENSAJE;
      END IF



      LET P_ERROR   = '00000';


      DELETE FROM SD_AMORTIZA_CREDITOCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MAESDOSCRD
       where empresa     = P_EMPRESA
         and num_credito = vnum_credito;

      DELETE FROM SD_MAECREDCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MAECREDANEXOCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MOVDIA
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      UPDATE BDISOLIC:SS_SOLICITUDES
             SET status_solicitud = 'CF'
      WHERE num_solicitud =  vnum_credito
      AND empresa  = P_EMPRESA;

      UPDATE BDISOLIC:SS_SOLICITUDES
             SET status_solicitud = 'CC'
      WHERE num_solicitud =  vnum_credito
      AND empresa  = P_EMPRESA;

   RETURN P_ERROR,P_MENSAJE;

   BEGIN
     ON EXCEPTION
         ROLLBACK WORK;
         RETURN P_ERROR,P_MENSAJE;
     END EXCEPTION;
   END;
END;
END PROCEDURE;