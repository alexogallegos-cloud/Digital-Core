CREATE PROCEDURE "informix".sp_notifica_modcorreo( pNumCte CHAR(20) )	
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr     	INTEGER;
    DEFINE iDesErr      CHAR(50);
    DEFINE vcTipoMns  	CHAR(1);
    DEFINE vcPlanMns    CHAR(10);
    DEFINE vcProcMns    CHAR(1);
    DEFINE vcNombre     CHAR(30);
    DEFINE vcApellPat   CHAR(30);
    DEFINE vcCodRetEven CHAR(5);
    
	LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET iSqlErr	     = 0;
    LET iSamErr    	 = 0;
    LET vcTipoMns 	 = '';
    LET vcPlanMns 	 = '';
    LET vcProcMns 	 = '';
    LET vcNombre     = '';
    LET vcApellPat   = '';
    LET vcCodRetEven = '';
	
	--- SET DEBUG FILE TO "/tmp/sp_notifica_modcorreo.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/tmp/sp_notifica_modcorreo.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
        END IF;
    END EXCEPTION;  

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE PARAMETROS 
    SELECT valor
      INTO vcTipoMns
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 88;
    
    SELECT valor
      INTO vcPlanMns
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 89;
       
    SELECT valor
      INTO vcProcMns
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 90;
     
    -- // OBTIENE NOMBRE DEL CLIENTE
    SELECT TRIM(nombre1), TRIM(apell_paterno)
      INTO vcNombre, vcApellPat
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;
       
    -- // INVOCA AL SP sp_registra_evento PARA MENSAJE DE LATINIA
    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento( vcTipoMns, vcPlanMns, pNumCte, '', '', vcProcMns, vcNombre, vcApellPat, '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, CURRENT, '' )
    INTO vcCodRetEven; 
    
    END;
    
END PROCEDURE;