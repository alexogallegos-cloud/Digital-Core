CREATE PROCEDURE "informix".sp_ctaportabilidad_web( pCuenta CHAR(11))
RETURNING CHAR(5)    AS  codigo_retorno,
		  CHAR(2)    AS  ESTATUS_PORTABILIDAD;

    DEFINE cCodRet          CHAR(5);
    DEFINE cEstatusPorta    CHAR(2);
    
    LET cCodRet			= '00000';
    LET cEstatusPorta   ='';

    BEGIN
    
    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
    --- TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   
    
    SELECT estatus_portabilidad   
    INTO cEstatusPorta
    FROM  bdicheq:"informix".sc_portacec_solicitud 
    WHERE estatus_portabilidad='2' and (substring(cta_ordenante from 7 for 11)=pCuenta)
               OR (substring(cta_receptora from 7 for 11)=pCuenta);
    
    RETURN cCodRet,NVL(cEstatusPorta,"0");
   END
END PROCEDURE;