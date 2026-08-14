CREATE PROCEDURE "informix".sp_liberaretinterpza_pba( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
     
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vContador1   INTEGER;
    DEFINE vContador2   INTEGER;
    DEFINE vAbierto     CHAR(1);
    DEFINE vFechaAnt    DATE;
    DEFINE vFechaHoy    DATE;
    DEFINE vNumCte      CHAR(20);
    DEFINE vCuenta      CHAR(20);
    DEFINE vMontoRet    MONEY(14,2);
    DEFINE vSdoRetenido MONEY(14,2);
    DEFINE vFecha       CHAR(8);
    DEFINE vstmt        CHAR(600);
    DEFINE vsql         CHAR(200);
    DEFINE vFechaIni    DATE;
    DEFINE vFechaFin    DATE;
    DEFINE vFecha1      CHAR(8);
    DEFINE vFecha2      CHAR(8);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '';
    LET vCodRet2     = '';
    LET vCodRet3     = '';  
    LET vContador1   = 0;
    LET vContador2   = 0;
    LET vAbierto     = '0';
    LET vFechaAnt    = '';
    LET vFechaHoy    = '';
    LET vNumCte      = '';
    LET vCuenta      = '';
    LET vMontoRet    = 0.00;
    LET vSdoRetenido = 0.00;
    LET vFecha       = '';
    LET vstmt        = '';
    LET vsql         = '';
    LET vFechaIni    = '';
    LET vFechaFin    = '';
    LET vFecha1      = '';
    LET vFecha2      = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretinterpza.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretinterpza.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES
    SELECT fecha_ant, fecha_hoy
      INTO vFechaAnt, vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_depinterpza idx_depintpza_fech)} dep.num_cte, dep.cuenta, dep.monto_ret, mae.sdo_retenido
          INTO vNumCte, vCuenta, vMontoRet, vSdoRetenido
          FROM sc_depinterpza dep,
               sc_maechq mae
         WHERE dep.fecha = vFechaAnt
           AND dep.monto_ret > 0
           AND dep.liberado = '0'
           AND mae.cuenta = dep.cuenta
           AND mae.num_cte = dep.num_cte
           
        BEGIN WORK;
        LET vAbierto = '1';
           
        IF vSdoRetenido >= vMontoRet THEN
            UPDATE sc_maechq
               SET sdo_retenido = sdo_retenido - vMontoRet
             WHERE cuenta = vCuenta;
             
            UPDATE sc_depinterpza
               SET liberado = '1'
             WHERE fecha = vFechaAnt
               AND num_cte = vNumCte
               AND cuenta = vCuenta;
               
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET vAbierto = '0';
        
        LET vNumCte = '';
        LET vCuenta = '';
        LET vMontoRet = 0;
        LET vSdoRetenido = 0;
    END FOREACH;
    
    -- // PASA REGISTROS A TABLA HISTORICA
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vCuenta
          FROM sc_depinterpza
         WHERE fecha < vFechaHoy
         
        BEGIN WORK;
        LET vAbierto = '1';
         
        INSERT INTO sc_depinterpzahist
        SELECT {+INDEX(sc_depinterpza idx_sc_depinterpza3)} *
          FROM sc_depinterpza
         WHERE cuenta = vCuenta
           AND fecha < vFechaHoy;
         
        DELETE {+INDEX(sc_depinterpza idx_sc_depinterpza3)} FROM sc_depinterpza
         WHERE cuenta = vCuenta
           AND fecha < vFechaHoy;
         
        COMMIT WORK;
        LET vAbierto = '0';
    
        LET vCuenta = '';
    END FOREACH;
    
    -- // GENERA REPORTE SEMANAL 
    IF WEEKDAY (vFechaHoy) = 2 THEN
        LET vFechaIni = vFechaAnt - 7 UNITS DAY;
        LET vFechaFin = vFechaAnt - 1 UNITS DAY;
        
        LET vFecha1 = TO_CHAR(vFechaIni, '%d%m%Y');
        LET vFecha2 = TO_CHAR(vFechaFin, '%d%m%Y');
    
        LET vstmt = '';
        LET vstmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/MovsInterEstado_'||vFecha1||'_'||vFecha2||'.txt '||
                   'SELECT mae.num_cte, mov.cuenta, mov.monto_tot, mov.sucursal, mov.usuario, mov.fech_alt, mov.fech_hor, mae.sucursal, mov.sdo_cuenta + mov.monto_tot '||
                   'FROM bdicheq:sc_movhis mov, bdicheq:sc_maechq mae '||
                   'WHERE mov.fech_alt BETWEEN '''||vFechaIni||''' AND '''||vFechaFin||''' '||
                   'AND mov.transacc = ''0325'' '||
                   'AND mov.cancelad <> ''S'' '||
                   'AND mae.empresa = mov.empresa '||
                   'AND mae.cuenta = mov.cuenta; " > /resplogifx/conciliachq/movsinterpza.sql';
        SYSTEM vstmt;
        LET vstmt = '';
        
        LET vsql = '';
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movsinterpza.sql"; 
        SYSTEM vsql;
        LET vsql = '';
    END IF; 
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;