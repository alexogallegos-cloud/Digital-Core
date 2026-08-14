CREATE PROCEDURE "informix".sp_validabeneficiarios( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vFechaAnt        DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_fin       DATE;
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vProducto        CHAR(4);
    DEFINE vFechaAlta       DATE;
    DEFINE vNoBeneficiarios SMALLINT;
    DEFINE vPorcentaje      DECIMAL(12,2);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(6);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    
    LET vFechaHoy         = '';
    LET vFechaAnt         = '';
    LET vpri_dia_mes      = '';
    LET vfecha_ini        = '';
    LET vfecha_fin        = '';
    LET vCuenta           = '';   
    LET vNumCliente       = '';
    LET vStatusCta        = '';
    LET vProducto         = '';
    LET vFechaAlta        = '';
    LET vNoBeneficiarios  = 0;
    LET vPorcentaje       = 0.00;
    LET vsql              = '';
    LET vstmt             = '';
    LET vfecha            = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validabeneficiarios.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validabeneficiarios.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vFechaHoy, vFechaAnt, vpri_dia_mes
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
     
    -- // OBTIENE LAS CUENTAS APERTURADAS EL DIA ANTERIOR
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.producto, noc.fecha_alta 
          INTO vCuenta, vNumCliente, vStatusCta, vProducto, vFechaAlta 
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = noc.cuenta
           AND mae.status_cta NOT IN('2','7')
           AND mae.producto NOT IN('1200','1600','2200','2300','9900','9901')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta 
           AND noc.fecha_alta BETWEEN vfecha_ini AND vfecha_fin
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
            LET vEnTransacc = 1;
            BEGIN WORK;
        END IF;    
        
        SELECT COUNT(*), SUM(porcentaje)
          INTO vNoBeneficiarios, vPorcentaje
          FROM bdicheq:"informix".sc_beneficiario
         WHERE cuenta = vCuenta;
         
        IF vNoBeneficiarios < 1 OR vNoBeneficiarios > 4 OR vPorcentaje <> 100.00 THEN
            INSERT INTO sc_ctasbeneficiarios (numcte, producto, cuenta, status_cta, no_beneficiarios, porcentaje, fecha_alta)
            VALUES(vNumCliente, vProducto, vCuenta, vStatusCta, vNoBeneficiarios, vPorcentaje, vFechaAlta);
            
            LET vContador2 = vContador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        LET vEnTransacc = 0;
        COMMIT WORK;
    END IF;
    
    IF vContador2 > 0 THEN
        LET vfecha = TO_CHAR(vfecha_fin, '%Y%m');
        
        -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/BeneficiariosCaptacion_'||vfecha||'.txt '||
                   'SELECT numcte, producto, cuenta, status_cta, no_beneficiarios, porcentaje, fecha_alta '||
                   'FROM sc_ctasbeneficiarios WHERE fecha_alta BETWEEN '''||vfecha_ini||''' AND '''||vfecha_fin||''' " > /resplogifx/conciliachq/beneficiarios.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/beneficiarios.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
    END IF;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
    
END PROCEDURE;