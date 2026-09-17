CREATE PROCEDURE "informix".sp_cancelactasinactivas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
       
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vFechaAnt        DATE;
    DEFINE vCuenta          CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vFechaUltimoDep  DATE;
    DEFINE vFechaUltimoRet  DATE;
    DEFINE vFechaAlta       DATE;
    DEFINE vNomProducto     CHAR(40);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vNumTarjeta      CHAR(16);
    DEFINE vNombreCliente   CHAR(104);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha           CHAR(8);
    DEFINE vTarjeta         CHAR(16);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    
    LET vFechaHoy       = '';
    LET vFechaAnt       = '';
    LET vCuenta         = '';   
    LET vStatusCta      = '';
    LET vSdoActual      = 0.00;
    LET vFechaUltimoDep = '';
    LET vFechaUltimoRet = '';
    LET vFechaAlta      = '';
    LET vNomProducto    = '';
    LET vNumCliente     = '';
    LET vNumTarjeta     = '';
    LET vNombreCliente  = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vfecha          = '';
    LET vTarjeta        = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactasinactivas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactasinactivas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy, fecha_ant
      INTO vFechaHoy, vFechaAnt
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT mae.cuenta
          INTO vCuenta
          FROM bdicheq:"informix".sc_maechq mae 
         WHERE mae.status_cta = '5'
		   AND mae.producto <> '1100'
           AND mae.sdo_actual = 0.00
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        /* ###########################################################################################################################################
        INSERT INTO bdicheq:"informix".sc_ctasinactinforcanc 
        ( num_cte, cliente, producto, cuenta, status_cta, sdo_actual, num_tarjeta, fech_ult_dep, fech_ult_ret, fecha_canc )
        VALUES
        ( vNumCliente, vNombreCliente, vNomProducto, vCuenta, vStatusCta, vSdoActual, vNumTarjeta, vFechaUltimoDep, vFechaUltimoRet, vFechaHoy );
           
        UPDATE bdicheq:"informix".sc_maechq
           SET status_cta = '2',
               fec_cancelac = vFechaHoy,
               motivo = '13'
         WHERE empresa = pEmpresa
           AND cuenta = vCuenta;
           
        FOREACH
            SELECT num_tarjeta
              INTO vTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND secuencia > 0
               AND status_tar = 'A'
        
            UPDATE bdicheq:"informix".sc_tarjeta
               SET status_tar = 'C'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND num_tarjeta = vTarjeta;
               
            UPDATE intercard:"informix".tarjeta
               SET codstatustarjeta = 'CAN'
             WHERE numtarjeta = vTarjeta;
        END FOREACH;
        ########################################################################################################################################### */
        
        UPDATE bdicheq:"informix".sc_maechq
           SET status_cta = '4',
               fecha_proceso = vFechaAnt
         WHERE cuenta = vCuenta;
           
        /*
        INSERT INTO bdicheq:"informix".sc_ctasinactinforcanc 
        ( num_cte, cliente, producto, cuenta, status_cta, sdo_actual, num_tarjeta, fech_ult_dep, fech_ult_ret, fecha_canc )
        VALUES
        ( vNumCliente, vNombreCliente, vNomProducto, vCuenta, vStatusCta, vSdoActual, vNumTarjeta, vFechaUltimoDep, vFechaUltimoRet, vFechaHoy );
        */
           
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
    END FOREACH;
    
    /*
    LET vfecha = TO_CHAR(vFechaHoy, '%d%m%Y');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/CtasInactivas3aniosCanceladas_'||vfecha||'.txt '||
               ' SELECT * FROM sc_ctasinactinforcanc WHERE fecha_canc = '''||vFechaHoy||''' " > /resplogifx/conciliachq/ctasinactcanc.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasinactcanc.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    */
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;