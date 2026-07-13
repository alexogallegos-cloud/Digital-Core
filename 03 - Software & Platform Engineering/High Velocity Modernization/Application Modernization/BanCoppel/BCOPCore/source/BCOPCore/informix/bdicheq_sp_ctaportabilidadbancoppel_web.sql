CREATE PROCEDURE "informix".sp_ctaportabilidadbancoppel_web( pCuenta CHAR(11))
RETURNING CHAR(5)    AS  cCodRet,
CHAR(2)    AS  ESTATUS_PORTABILIDAD;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5); 
    DEFINE cEstatusPorta    CHAR(2);

    LET cCodRet			= '00000';
    LET cCodRet2		= '00000';
    LET cEstatusPorta   ='';

    BEGIN
    
    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
    --- TRACE ON;    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 
    
    SELECT  ESTATUS
    INTO cEstatusPorta
    FROM  bdicheq:"informix".sc_portabilidadnomina 
    WHERE cuenta_abono = pCuenta 
    AND SECUENCIA=(SELECT MAX(SECUENCIA) 
                    FROM bdicheq:"informix".sc_portabilidadnomina 
                     WHERE cuenta_abono = pCuenta);
    
    RETURN cCodRet,NVL(cEstatusPorta,'00');
   END
END PROCEDURE;