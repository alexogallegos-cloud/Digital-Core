CREATE PROCEDURE "informix".sp_bithuellasfusion (pCteCorrecto CHAR(9), pCteIncorrecto CHAR(9), pMensaje CHAR(2), pEjecutivo CHAR(8))
    RETURNING CHAR(5);

  DEFINE iSqlErr        INTEGER;
  DEFINE cCodret 		CHAR(5);
  DEFINE cMensaje 		CHAR(100);

  LET cCodret   = "00000";
  LET cMensaje  = "";
	
  --SET DEBUG FILE TO '/tmp/sp_bithuellasfusion.out';
  --TRACE ON;

BEGIN
  --MANDAR EL ERROR AL MENSAJE  
  ON EXCEPTION SET iSqlErr
            LET cMensaje = iSqlErr;
  END EXCEPTION;
    
  IF pMensaje=1 THEN
    LET cMensaje  = "Huellas Correctas.";
  ELIF pMensaje=2 THEN
    LET cMensaje  = "Las Huellas De Los Clientes No Coinciden";
  ELIF pMensaje=-1 THEN
    LET cMensaje  = "Las Huellas De Los Clientes Están Incompletas";
  ELIF pMensaje=-2 THEN
    LET cMensaje  = "Las Huellas De Los Clientes Son Invalidas";
  END IF

  INSERT INTO "informix".si_bitacora_comctes(cte_correcto, cte_incorrecto, ejecutivo, mensaje, fecha) 
    VALUES(pCteCorrecto, pCteIncorrecto, pEjecutivo, cMensaje, CURRENT);
  
 RETURN cCodret;

END;
END PROCEDURE;