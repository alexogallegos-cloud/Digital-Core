CREATE PROCEDURE "informix".sp_actualiza_gerentes( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER; 
    
    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viTrxAbierta SMALLINT;
    DEFINE viContador   INTEGER;
    DEFINE vdFechaHoy   DATE;
    DEFINE vcSucAnt     CHAR(4);
    DEFINE vcSucursal   CHAR(4);
    DEFINE vcEjecutivo  CHAR(8);
    DEFINE vcNombreGte  CHAR(45);
    DEFINE vdFechaIns   DATE;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO REALIZADO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viTrxAbierta = 0;
    LET viContador   = 0;    
    LET vdFechaHoy   = '';
    LET vcSucAnt     = '';
    LET vcSucursal   = '';
    LET vcEjecutivo  = '';
    LET vcNombreGte  = '';
    LET vdFechaIns   = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM si_fechas
     WHERE empresa = pEmpresa;
     
    LET vcSucAnt = '0000';
    
    FOREACH WITH HOLD
        SELECT sucursal, ejecutivo, nombre, fecha_insert
          INTO vcSucursal, vcEjecutivo, vcNombreGte, vdFechaIns
          FROM si_ejecut 
         WHERE sucursal IN ( SELECT sucursal FROM si_sucursales WHERE tpo_sucursal = 'S' )
           AND ejecutivo LIKE '9%'
           AND password NOT IN('BAJA', 'baja')
           AND vigencia > vdFechaHoy
           AND puesto = '001'
         ORDER BY sucursal, fecha_insert
           
        BEGIN WORK;
        LET viTrxAbierta = 1;
        
        IF vcSucursal <> vcSucAnt THEN
            UPDATE si_sucursales
               SET gerente = vcNombreGte
             WHERE sucursal = vcSucursal;
        END IF;
        
        LET vcSucAnt = vcSucursal;
        
        LET viContador = viContador + 1;        
        
        COMMIT WORK;
        LET viTrxAbierta = 0;
        
        LET vcSucursal  = '';
        LET vcEjecutivo = '';
        LET vcNombreGte = '';
        LET vdFechaIns  = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
    
END PROCEDURE;