CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_comp2( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE iDesErr      CHAR(50);
    DEFINE iAbierto     SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE dtFechaAnt   DATE;
    DEFINE cCuentaIni   CHAR(20);
    DEFINE cCuentaFin   CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET iDesErr    = '';
    LET iAbierto   = 0;    
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET dtFechaHoy = ''; 
    LET dtFechaAnt = '';
    LET cCuentaIni = '';
    LET cCuentaFin = '';
    LET cNumCte    = '';
    LET cCuenta    = '';
    LET cCodRetPDF = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs_comp2.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iSamErr;
            LET cCodRet3   = iDesErr;
            LET cNumCte    = cNumCte;
            LET cCuenta    = cCuenta;
            LET cCodRetPDF = cCodRetPDF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs_comp2.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO dtFechaHoy, dtFechaAnt
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
    
    SELECT valor
      INTO cCuentaIni
      FROM bdicheq:sc_param
     WHERE codparam = 'CtaIniCgaDocsCtaN2_2';
     
    SELECT valor
      INTO cCuentaFin
      FROM bdicheq:sc_param
     WHERE codparam = 'CtaIniCgaDocsCtaN2_3';
       
    FOREACH WITH HOLD
        SELECT mae.num_cte, mae.cuenta
          INTO cNumCte, cCuenta
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.cuenta = noc.cuenta
           AND mae.producto = '2900'
           AND noc.fecha_alta >= dtFechaAnt
           AND mae.cuenta > cCuentaIni
           AND mae.cuenta <= cCuentaFin
         ORDER BY mae.cuenta
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cNumCte, cCuenta)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
        ELSE
            INSERT INTO bdinteg:si_ctanvl2_faltadocs
            ( numcte, cuenta, fecha, procesado )
            VALUES
            ( cNumCte, cCuenta, dtFechaHoy, 0 );
        END IF;
        
        LET cNumCte    = '';
        LET cCuenta    = '';
        LET cCodRetPDF = '';
    END FOREACH;
           
    END;

    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;

END PROCEDURE;