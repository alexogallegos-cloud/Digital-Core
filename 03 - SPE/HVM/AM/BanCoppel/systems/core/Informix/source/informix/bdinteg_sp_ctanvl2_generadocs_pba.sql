CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_pba( pEmpresa CHAR(3) ) 
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
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
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
    LET cCuenta    = '';
    LET cNumCte    = '';
    LET cCodRetPDF = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cCuenta    = cCuenta;
            LET cNumCte    = cNumCte;
            LET cCodRetPDF = cCodRetPDF;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
                LET iAbierto = 0;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.out";
    TRACE ON;
    
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte
          INTO cCuenta, cNumCte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.cuenta = noc.cuenta
           AND mae.producto = '2900'
           --- AND noc.fecha_alta = dtFechaHoy
           AND mae.cuenta IN('29000000004','29004742417')
        
        BEGIN WORK;
        LET iAbierto = 1;
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cCuenta, cNumCte)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET iAbierto = 0;
        
        LET cCuenta    = '';
        LET cNumCte    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;