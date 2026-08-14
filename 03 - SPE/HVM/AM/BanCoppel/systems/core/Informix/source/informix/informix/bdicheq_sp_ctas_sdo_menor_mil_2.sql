CREATE PROCEDURE "informix".sp_ctas_sdo_menor_mil_2()
RETURNING CHAR(5);
    
    DEFINE cCodret      CHAR(5);
    DEFINE cCodret2     CHAR(5);
    DEFINE cCodret3     CHAR(50);
    DEFINE iSqlErr      INTEGER;  
    DEFINE iSamErr      INTEGER;  
    DEFINE iDesErr      CHAR(50);
    DEFINE cSQL         CHAR(600);
    DEFINE dFecha       DATE; 
    DEFINE cAnioMes     CHAR(6);
	DEFINE cDia         CHAR(2);
	DEFINE dFechaIni    DATE;
    DEFINE cCuenta      CHAR(20);
    DEFINE cSucursal    CHAR(4);
    DEFINE mCapital     DECIMAL(14,2);
    DEFINE iComienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador    INTEGER;
    DEFINE cProducto    CHAR(4);
    DEFINE cGenero      CHAR(1);
	
	LET cCodret   = "00000";
    LET cCodret2  = '';
    LET cCodret3  = '';
    LET iSqlErr   = 0;
    LET cSQL      = '';
    LET dFecha    = '';
    LET cAnioMes  = '';
	LET cDia      = '';
	LET dFechaIni = '';
    LET cCuenta   = '';
    LET cSucursal = '';
    LET mCapital  = 0.00;
    LET iComienza = -1;
    LET iTransacc = 0;
    LET iContador = 0;
    LET cProducto = '';
    LET cGenero   = '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctas_sdo_menor_mil.err";
        TRACE ON;  
        IF iSqlErr <> 0 THEN
            LET cCodret = iSqlErr;
            LET cCodret2 = iSamErr;
            LET cCodret3 = iDesErr;
            RETURN cCodret;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq//sp_ctas_sdo_menor_mil.out";
    --- TRACE ON;  

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    LET cSQL = '';
    LET cSQL = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/cuentas_saldo_menor_mil_'||cAnioMes||' '||
               'SELECT * FROM sc_ctasdomenormil;" > /resplogifx/conciliachq/ctasdomenormil.sql';
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasdomenormil.sql"; 
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = '/usr/bin/split -1000000 /resplogifx/conciliachq/cuentas_saldo_menor_mil_'||cAnioMes||' /resplogifx/conciliachq/cuentas_saldo_menor_mil_'||cAnioMes||'_ ';
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = '/usr/bin/bzip2 -9 /resplogifx/conciliachq/cuentas_saldo_menor_mil_* ';
    SYSTEM cSQL;
    
    -- // ARCHIVOS CONTABILIDAD - R2421 
    LET cSQL = '';
    LET cSQL = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/cuentas_saldo_menor_mil_R2421_'||cAnioMes||' '||
               'SELECT sucursal, producto, genero, COUNT(*), SUM(saldo) FROM sc_ctasdomenormil WHERE saldo >= 0 GROUP BY 1, 2, 3;" > /resplogifx/conciliachq/ctasdomenormil.sql';
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasdomenormil.sql"; 
    SYSTEM cSQL;
    
    END;
    
    RETURN cCodret;
    
END PROCEDURE;