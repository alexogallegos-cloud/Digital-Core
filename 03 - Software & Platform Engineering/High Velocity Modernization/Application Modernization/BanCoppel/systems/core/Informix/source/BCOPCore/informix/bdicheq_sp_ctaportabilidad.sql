CREATE PROCEDURE "informix".sp_ctaportabilidad( pCuenta CHAR(11))
RETURNING CHAR(2)    AS  ESTATUS_PORTABILIDAD;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5); 
    DEFINE cEstatusPorta    CHAR(2);
    

    LET cCodRet			= '00000';
    LET cCodRet2		= '00000';
    LET cEstatusPorta   ='';

    BEGIN
    
    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
    --- TRACE ON;
    
    SELECT estatus_portabilidad   
    INTO cEstatusPorta
    FROM  bdicheq:"informix".sc_portacec_solicitud 
    WHERE estatus_portabilidad='2' and ((substring(cta_ordenante from 7 for 11)=pCuenta)
               OR (substring(cta_receptora from 7 for 11)=pCuenta));
    
    RETURN NVL(cEstatusPorta,"0");
   END
END PROCEDURE

;