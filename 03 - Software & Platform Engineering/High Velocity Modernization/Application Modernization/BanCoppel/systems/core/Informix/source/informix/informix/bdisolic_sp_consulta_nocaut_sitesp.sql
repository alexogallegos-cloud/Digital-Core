CREATE PROCEDURE "informix".sp_consulta_nocaut_sitesp(pEmpresa CHAR(3),pNumcte CHAR(20))
    RETURNING 
    CHAR(6) as sCodRet, 
    CHAR(1) as sBanderaCoppel, 
    CHAR(1) as sBanderaBanco;

-- DEFINICION DE VARIABLES.
    DEFINE cCodRet          CHAR(6);
    DEFINE cBandCoppel      CHAR(1);
    DEFINE cBandBanco       CHAR(1);
    DEFINE iSqlErr          INTEGER;
    DEFINE cSituacion       CHAR(1);
    DEFINE cCausa           SMALLINT;    
    
 --SET DEBUG FILE TO '/home/sysifx/sp_consulta_nocaut_sitesp.out'; 
 --TRACE ON;

-- INICIALIZACION DE VARIABLE.
    LET cCodRet             = '000000';
    LET cBandCoppel         = '0';
    LET cBandBanco          = '0';
    LET iSqlErr             = 0;
    LET cSituacion          = "";
    LET cCausa              = "";    

    BEGIN    
        ON EXCEPTION SET iSqlErr
            IF(iSqlErr != 0) THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cBandCoppel, cBandBanco;
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF NVL(pNumcte, '') = '' THEN
            LET cCodRet = '000001';
            RETURN cCodRet, cBandCoppel, cBandBanco;
        END IF;
                
        --OBTENER LA CAUSA Y SITUACIÃN DEL CLIENTE
        SELECT LIMIT 1 situacion, causa INTO cSituacion, cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumcte;
        
         --VALIDAR VALORES VACÃOS Y NULOS
        IF NVL(cSituacion, '') = '' OR NVL(cCausa, '') = '' THEN
        --CLIENTE NO TIENE SITUCION ESPECIAL, NO APLICA NOCAUT
            LET cCodRet = '000000';                       
            LET cBandCoppel = '0';
            LET cBandBanco = '0';
            RETURN cCodRet, cBandCoppel, cBandBanco;
        END IF;
        
        --SE OBTIENEN LOS VALORES DE NOCAOUT
        IF cSituacion = 'P' THEN
            CASE cCausa
                WHEN '109' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 544;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 545;
                WHEN '110' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 546;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 547;
                WHEN '111' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 548;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 549;
                WHEN '112' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 550;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 551;
                WHEN '113' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 552;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 553;
                WHEN '114' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 554;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 555;
                WHEN '115' THEN
                    SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 556;
                    SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 557;
                ELSE 
                    LET cBandCoppel = '0';
                    LET cBandBanco = '0';					 					 
            END CASE;
        ELSE
            IF cSituacion = 'C' AND cCausa = '2' THEN
                SELECT Valor INTO cBandCoppel FROM bdinteg:"informix".si_param WHERE cod_param = 558;
                SELECT Valor INTO cBandBanco FROM bdinteg:"informix".si_param WHERE cod_param = 559;
            END IF;
        END IF;
        --SE REGRESA LAS BANDERAS CON EXITO
        RETURN cCodRet, cBandCoppel, cBandBanco;
    END;
END PROCEDURE
