CREATE PROCEDURE "informix".sp_registrarbitacora_ofi_web(pEmpresa CHAR (3), pNumCredito CHAR(20),pSucursal CHAR (4))
RETURNING CHAR(5)  AS codigo_retorno,
		  CHAR(80) AS mensaje_retorno; 
		  
---DECLARACIONES         
DEFINE cCodRet               CHAR(5); 
DEFINE cMensajeRet           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cNumCte              CHAR(20);
DEFINE cRiesgo      	   	CHAR(2);
DEFINE dMontoOtor          	DECIMAL(18,2);
DEFINE cNumprod        	    CHAR(4);   
DEFINE cUser        	    CHAR(20);
---INICIALIZACIONES
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "00000";
LET cMensajeRet          = "PROCESO EXITOSO";
LET cNumCte 			 = "";
LET cRiesgo      	 	 = "";
LET dMontoOtor        	 = 0;
LET cNumprod        	 = "";  
LET cUser                = USER;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet;
   END IF;	
END EXCEPTION;

--SET DEBUG FILE TO 'sp_registrarbitacora_ofi.out';
--TRACE ON;

--se validan los parametros de entrada.
	IF NVL(pEmpresa,"") = "" THEN
		LET cCodRet = "00001";
		LET cMensajeRet = "Falta parÃ¡metro de empresa";
	ELIF NVL(pNumCredito,"") = "" THEN
		LET cCodRet = "00002";
		LET cMensajeRet = "Falta parÃ¡metro requerido de numero de credito para realizar la consulta";
	ELSE 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT a.numcte, b.monto_otorgado, a.num_producto
	      INTO  cNumCte, dMontoOtor, cNumprod
		  FROM bdicred:"informix".sd_maecred a 
		  INNER JOIN bdicred:"informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
		  WHERE a.empresa     = pEmpresa
	       AND a.num_credito = pNumCredito;
			
	        INSERT INTO bdicred:"informix".sd_bitacora_aumlincred
			(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status, hora_status, sucursal,lincred_actual,origen, user_insert, fecha_insert) 
	        VALUES(pEmpresa, pNumCredito, cNumCte, cNumprod, "AN",'',CURRENT, CURRENT,pSucursal, dMontoOtor,"S", cUser, CURRENT);
	        
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred
			(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
	        VALUES(pEmpresa, pNumCredito, "AN", '', cUser, CURRENT, CURRENT, 0);		

	END IF;
	RETURN cCodRet, cMensajeRet; 		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para realizar registro de anulacion de la solicitud en bitacora.',
'AUTOR : Maria Elena Angulo Aispuro,JesÃºs Manuel Aguilar Heredia',
'FECHA : 10/Oct/2011',
'BD    : BDICRED',
'Version: 20111010.1051';

CREATE PROCEDURE "informix".sp_reverapercrd_web(P_EMPRESA   CHAR(3),
                                            P_SOLICITUD CHAR(20))
RETURNING VARCHAR(5),    --CodRet
          VARCHAR(80);   --Mensaje

                             --Variables

  DEFINE P_ERROR       VARCHAR(5);
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

      IF P_ERROR="000" THEN
          LET P_ERROR="00000";
      ELSE
         LET P_ERROR="00001";
      END IF

      IF P_ERROR <> "00000" THEN
	LET P_MENSAJE = "REVERSION DE AHORROS";
	RETURN P_ERROR, P_MENSAJE;
      END IF

                      --** Reversion De Credito Liquidacion



      EXECUTE PROCEDURE reversioncrd(P_EMPRESA,vsucursal,vusuario,v_FOLIO,'B')
      INTO P_ERROR;

      IF P_ERROR="000" THEN
          LET P_ERROR="00000";
      ELSE 
         LET P_ERROR="00001";
      END IF

      IF P_ERROR <> "00000" THEN
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