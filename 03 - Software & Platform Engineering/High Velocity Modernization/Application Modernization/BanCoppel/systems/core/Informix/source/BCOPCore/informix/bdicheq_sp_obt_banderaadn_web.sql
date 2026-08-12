CREATE PROCEDURE "informix".sp_obt_banderaadn_web()
RETURNING CHAR(5) AS CodigoRetrono, CHAR(2)    AS  Activo;

    DEFINE cCodRet    CHAR(5);
    DEFINE cCodRet2   CHAR(5); 
    DEFINE cActivo    CHAR(2);
    
    LET cCodRet	  = '00000';
    LET cCodRet2  = '00000';
    LET cActivo   ='0';

    BEGIN    
        --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
        --- TRACE ON; 
		
		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT valor 
        INTO cActivo
        FROM  bdicred:"informix".sd_param
        WHERE empresa='001' and cod_param='090';

        RETURN cCodRet,NVL(cActivo,"0");
    END
END PROCEDURE;