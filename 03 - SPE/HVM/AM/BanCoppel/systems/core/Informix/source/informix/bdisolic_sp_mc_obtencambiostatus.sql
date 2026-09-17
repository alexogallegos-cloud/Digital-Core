CREATE PROCEDURE "informix".sp_mc_obtencambiostatus(pEmpresa CHAR(3),pNumCte CHAR(20),pNumSol CHAR(20),pStatusIni CHAR(2),pStatusFin CHAR(2))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(2)  AS  Status_cambio,
		  CHAR(40) AS Desc_status_cambio,
		  CHAR(1)  AS Valida_huella;	  
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cStatusFin			CHAR(2);
DEFINE cDescStatusFin	CHAR(40);
DEFINE cFlagSIC			CHAR(1);
DEFINE cFlagEdad		CHAR(1);
DEFINE cValidaHuella	CHAR(1);
DEFINE cNomcte		   CHAR(104);
DEFINE sEdadCte        SMALLINT;
DEFINE iContador       SMALLINT;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cStatusFin			= "";
LET cDescStatusFin		= "";
LET cFlagSIC			= "1";
LET cFlagEdad			= "1";
LET cValidaHuella		= "1";
LET cNomcte			    = "";
LET sEdadCte			= 0;
LET iContador			= 0;

       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cStatusFin,cDescStatusFin,cValidaHuella;  
END EXCEPTION;

--SET DEBUG FILE TO 'sp_mc_obtencambiostatus.out';
--TRACE ON;
 IF NVL(pEmpresa, '' ) = '' OR NVL(pStatusIni,'')= ''  THEN
	LET cCodret = '000001';
	LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS'; 
	RETURN cCodRet, cMensajeRet,cStatusFin,cDescStatusFin,cValidaHuella;  
 END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

 --se validad edad el cliente  Se reacomoda la consulta para no realizarla en todos los escenarios
 IF SUBSTR(pNumSol,1,2) = "65" AND pStatusIni IN ("RT","EC") THEN 	 
	IF NVL(pNumCte,"") <> "" THEN			
		IF (SELECT COUNT(num_solicitud) 
			FROM "informix".ss_solicitudes_sic
			WHERE numcte = pNumCte AND num_solicitud = pNumSol) >= 1 THEN
		LET cFlagSIC = '1';	
		ELSE
		--obtiene la edad del cliente
			LET cFlagSIC = '0';	
			EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, pNumCte)
				INTO cCodRet, cNomcte, sEdadCte;

			IF NVL(sEdadCte,"") = "" THEN
				LET cFlagEdad = '1';
			ELIF sEdadCte < 18 THEN
			   LET cFlagEdad = '0';
			   LET cFlagSIC = '1';	
			ELSE --mayor de edad	   			
				LET cFlagEdad = '1';
			END IF; 	

		END IF	 

	END IF;	 
  END IF;
  
  --se valida si consulto a buro  
  
  FOREACH WITH HOLD
	SELECT a.status_final , b.descripcion,valida_huella
	  INTO cStatusFin,cDescStatusFin,cValidaHuella
    FROM "informix".ss_cambio_status_mc as a , "informix".ss_status_sol b
    WHERE a.empresa = '001'
    AND a.empresa= b.empresa
    AND a.status_final = b.status_solicitud
	AND a.status_inicial = pStatusIni
	AND a.status_final = CASE WHEN pStatusFin = "" THEN a.status_final ELSE pStatusFin END
	AND a.adulto = cFlagEdad
	AND consulta_sic = cFlagSIC 
	
	 LET iContador =  iContador + 1;
	 RETURN cCodRet, cMensajeRet,cStatusFin,cDescStatusFin,cValidaHuella WITH RESUME;   
	 
  END FOREACH;	
  IF iContador = 0 THEN
	LET cCodRet             = "000002";
	LET cMensajeRet         = "No se encontro información, verifique...";
	RETURN cCodRet, cMensajeRet,cStatusFin,cDescStatusFin,cValidaHuella;  
  END IF;
	
END
END PROCEDURE
