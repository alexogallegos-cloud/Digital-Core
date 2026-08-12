CREATE PROCEDURE "informix".sp_actualizatelref_cjunk_pros(
                             pempresa char(3),
                             pnumcte char(20),
                             psecuencia integer,
                             ptipotel1 char(1),
                             ptelefono1 char(13),
                             ptipotel2 char(1),
                             ptelefono2 char(13),
                             ptipotel3 char(1),
                             ptelefono3 char(13),
                             pextension char(5))
 RETURNing char(5);

-- Se definen variables
DEFINE cCodRet          CHAR(5);
DEFINE iSqlErr          INTEGER;
DEFINE cResulFijoMovil  CHAR(5);
DEFINE cDescFijoMovil   CHAR(5);
DEFINE iFijoMovil1      INTEGER;
DEFINE iFijoMovil2      INTEGER;
DEFINE iFijoMovil3      INTEGER;

LET cCodRet         = '00000';
LET iSqlErr         = 0;
LET cResulFijoMovil = '';
LET cDescFijoMovil  = '';
LET iFijoMovil1     = 0;
LET iFijoMovil2     = 0;
LET iFijoMovil3     = 0;

   --SET DEBUG FILE TO "/tmp/sp_actualizatelref_cjunk_pros";
    --TRACE ON;
	
BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    IF ptelefono1 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pempresa, ptelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
        LET ptipotel1 = 'P';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil1 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil1 = 1;
        ELSE
            LET iFijoMovil1 = 0;
        END IF;
    END IF;
    
    IF ptelefono2 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pempresa, ptelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
        LET ptipotel2 = 'C';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil2 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil2 = 1;
        ELSE
            LET iFijoMovil2 = 0;
        END IF;
    END IF;
    
    IF ptelefono3 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pempresa, ptelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
        LET ptipotel3 = 'O';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil3 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil3 = 1;
        ELSE
            LET iFijoMovil3 = 0;
        END IF;
    END IF;
    
    UPDATE "informix".pr_refdirecciones 
            SET (tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, movil_fijo1, movil_fijo2, movil_fijo3) =
                (ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, iFijoMovil1, iFijoMovil2, iFijoMovil3)
    WHERE numcte_pros = pnumcte  AND secuencia = psecuencia;
    
    RETURN cCodRet;

END;
END PROCEDURE;