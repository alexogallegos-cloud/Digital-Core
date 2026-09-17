CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_comp( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iAbierto     SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE dtFechaAnt   DATE;
    DEFINE cNumCte      CHAR(20);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '000';
    LET cCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iAbierto   = 0;    
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET dtFechaHoy = '';
    LET dtFechaAnt = '';
    LET cNumCte    = '';
    LET cCuenta    = '';
    LET cCodRetPDF = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs_comp.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cNumCte    = cNumCte;
            LET cCuenta    = cCuenta;
            LET cCodRetPDF = cCodRetPDF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs_comp.out";
    --- TRACE ON;
    
    SELECT fecha_hoy, fecha_ant
      INTO dtFechaHoy, dtFechaAnt
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT numcte, cuenta
          INTO cNumCte, cCuenta
          FROM bdinteg:si_ctanvl2_faltadocs
         WHERE fecha = dtFechaHoy
           AND procesado = 0
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cNumCte, cCuenta)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
            
            UPDATE bdinteg:si_ctanvl2_faltadocs
               SET procesado = 1
             WHERE numcte = cNumCte
               AND cuenta = cCuenta;
        END IF;
        
        LET cNumCte    = '';
        LET cCuenta    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;