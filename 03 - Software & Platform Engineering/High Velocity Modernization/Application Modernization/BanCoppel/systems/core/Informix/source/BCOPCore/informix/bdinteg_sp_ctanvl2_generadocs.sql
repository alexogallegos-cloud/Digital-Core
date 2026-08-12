CREATE PROCEDURE "informix".sp_ctanvl2_generadocs( pEmpresa CHAR(3) ) 
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
    DEFINE cCuentaIni   CHAR(20);
    DEFINE cCuentaFin   CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    DEFINE cCtaCtrlN2   CHAR(20);
    
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
    LET cCuentaIni = '';
    LET cCuentaFin = '';
    LET cNumCte    = '';
    LET cCuenta    = '';
    LET cCodRetPDF = '';
    LET cCtaCtrlN2 = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cNumCte    = cNumCte;
            LET cCuenta    = cCuenta;
            LET cCodRetPDF = cCodRetPDF;
            --- IF iAbierto = 1 THEN
            ---     ROLLBACK WORK;
            ---     LET iAbierto = 0;
            --- END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generadocs.out";
    --- TRACE ON;
    
    SELECT fecha_hoy, fecha_ant
      INTO dtFechaHoy, dtFechaAnt
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
    
    SELECT valor
      INTO cCuentaIni
      FROM bdicheq:sc_param
     WHERE codparam = 'CtaCtrlGeneraDocsN2';
     
    SELECT MAX(mae.cuenta)
      INTO cCuentaFin
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.cuenta = noc.cuenta
       AND mae.producto = '2900'
       AND noc.fecha_alta >= dtFechaAnt
       AND mae.cuenta > cCuentaIni;
       
    LET cCtaCtrlN2 = cCuentaIni;
     
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
        
        --- BEGIN WORK;
        --- LET iAbierto = 1;
        
        LET cCtaCtrlN2 = cCuenta;
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
        
        --- COMMIT WORK;
        --- LET iAbierto = 0;
        
        LET cNumCte    = '';
        LET cCuenta    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    IF cCtaCtrlN2 <> cCuentaIni THEN
        UPDATE bdicheq:sc_param
           SET valor = cCtaCtrlN2
         WHERE codparam = 'CtaCtrlGeneraDocsN2';
    END IF;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;