CREATE PROCEDURE "informix".sp_paramscargadocsctasnvl2( pEmpresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE iDescErr     CHAR(50);
    DEFINE iPromedio    INTEGER;
    DEFINE iCont        SMALLINT;
    DEFINE iBrinca      INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE dtFechaAnt   DATE;
    DEFINE cCuentaIni   CHAR(20);
    DEFINE cCuentaFin   CHAR(20);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCtaParam    CHAR(20);
    DEFINE iValida      SMALLINT;
    
    LET cCodRet    = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr    = 0;
    LET iIsamErr   = 0;
    LET iDescErr   = '';
    LET iPromedio  = 0;
    LET iCont      = 0;
    LET iBrinca    = 0;
    LET dtFechaHoy = '';
    LET dtFechaAnt = '';
    LET cCuentaIni = '';
    LET cCuentaFin = '';
    LET cCuenta    = 0;
    LET cCtaParam  = '';
    LET iValida    = 0;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, iDescErr
        SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_paramscargadocsctasnvl2.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = iDescErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/RESPALDOSNEW/DoctosCtaNvl2/sp_paramscargadocsctasnvl2.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
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
        
    SELECT ROUND( COUNT(*) / 5)
      INTO iPromedio
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.cuenta = noc.cuenta
       AND mae.producto = '2900'
       AND noc.fecha_alta >= dtFechaAnt
       AND mae.cuenta > cCuentaIni
       AND mae.cuenta <= cCuentaFin;
       
    LET iCont = 1;
    
    WHILE iCont <= 6  
    
        IF iCont = 1 THEN
        
            LET cCtaParam = cCuentaIni;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
            
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_1';
             
        ELIF iCont = 2 THEN
            
            LET iValida = 0;
            LET iBrinca = iPromedio;
            
            FOREACH
                SELECT SKIP iBrinca FIRST 1 mae.cuenta
                  INTO cCuenta
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc
                 WHERE mae.cuenta = noc.cuenta
                   AND mae.producto = '2900'
                   AND noc.fecha_alta >= dtFechaAnt
                   AND mae.cuenta > cCuentaIni
                   AND mae.cuenta <= cCuentaFin
                 ORDER BY mae.cuenta
                 
                LET cCuenta = cCuenta;
                LET iValida = 1;
            END FOREACH;
                
            IF iValida = 1 THEN
                LET cCtaParam = cCuenta;
            ELSE
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
                
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_2';
            
        ELIF iCont = 3 THEN
            
            LET iValida = 0;
            LET iBrinca = iPromedio * 2;
            
            FOREACH
                SELECT SKIP iBrinca FIRST 1 mae.cuenta
                  INTO cCuenta
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc
                 WHERE mae.cuenta = noc.cuenta
                   AND mae.producto = '2900'
                   AND noc.fecha_alta >= dtFechaAnt
                   AND mae.cuenta > cCuentaIni
                   AND mae.cuenta <= cCuentaFin
                 ORDER BY mae.cuenta
                 
                LET cCuenta = cCuenta;
                LET iValida = 1;
            END FOREACH;
                 
            IF iValida = 1 THEN
                LET cCtaParam = cCuenta;
            ELSE
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
             
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_3';
            
        ELIF iCont = 4 THEN
            
            LET iValida = 0;
            LET iBrinca = iPromedio * 3;
            
            FOREACH
                SELECT SKIP iBrinca FIRST 1 mae.cuenta
                  INTO cCuenta
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc
                 WHERE mae.cuenta = noc.cuenta
                   AND mae.producto = '2900'
                   AND noc.fecha_alta >= dtFechaAnt
                   AND mae.cuenta > cCuentaIni
                   AND mae.cuenta <= cCuentaFin
                 ORDER BY mae.cuenta
                 
                LET cCuenta = cCuenta;
                LET iValida = 1;
            END FOREACH;
            
            IF iValida = 1 THEN
                LET cCtaParam = cCuenta;
            ELSE
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
             
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_4';
            
        ELIF iCont = 5 THEN
            
            LET iValida = 0;
            LET iBrinca = iPromedio * 4;
            
            FOREACH
                SELECT SKIP iBrinca FIRST 1 mae.cuenta
                  INTO cCuenta
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc
                 WHERE mae.cuenta = noc.cuenta
                   AND mae.producto = '2900'
                   AND noc.fecha_alta >= dtFechaAnt
                   AND mae.cuenta > cCuentaIni
                   AND mae.cuenta <= cCuentaFin
                 ORDER BY mae.cuenta
                 
                LET cCuenta = cCuenta;
                LET iValida = 1;
            END FOREACH;
            
            IF iValida = 1 THEN
                LET cCtaParam = cCuenta;
            ELSE
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
             
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_5';
            
        ELIF iCont = 6 THEN
            
            LET cCtaParam = cCuentaFin;
                
            IF cCtaParam is null OR cCtaParam = '' THEN
                LET cCtaParam = 'XXXXXXXXXXX';
            END IF;
            
            UPDATE bdicheq:sc_param
               SET valor = cCtaParam
             WHERE codparam = 'CtaIniCgaDocsCtaN2_6';
            
        END IF;
        
        LET iCont = iCont + 1;
        
        LET cCuenta = 0;
        LET cCtaParam = '';
        
    END WHILE;
    
    UPDATE bdicheq:sc_param
       SET valor = cCuentaFin
     WHERE codparam = 'CtaCtrlGeneraDocsN2';
        
    RETURN cCodRet;

    END;

END PROCEDURE;