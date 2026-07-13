CREATE PROCEDURE "informix".sp_verifica_gerentes( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER; 
    
    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viTrxAbierta SMALLINT;
    DEFINE viContador1  INTEGER;
    DEFINE viContador2  INTEGER;
    DEFINE vdFechaHoy   DATE;
    DEFINE vcSucursal   CHAR(4);
    DEFINE vcNombreGte  CHAR(45);
    DEFINE vcPasswd     CHAR(40);
    DEFINE vdVigencia   DATE;
    DEFINE vcNuevoGte   CHAR(45);
    DEFINE vdFechaIns   DATE;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO REALIZADO CORRECTAMENTE';
    LET viSqlErr	 = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viTrxAbierta = 0;
    LET viContador1  = 0;
    LET viContador2  = 0;    
    LET vdFechaHoy   = '';
    LET vcSucursal   = '';
    LET vcNombreGte  = '';
    LET vcPasswd     = '';
    LET vdVigencia   = '';
    LET vcNuevoGte   = '';
    LET vdFechaIns   = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_verifica_gerentes.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_verifica_gerentes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM si_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT sucursal, gerente
          INTO vcSucursal, vcNombreGte
          FROM si_sucursales 
         WHERE sucursal > '0000'
           AND empresa = pEmpresa
           AND tpo_sucursal = 'S'
           
        BEGIN WORK;
        LET viTrxAbierta = 1;
        
        SELECT password, vigencia
          INTO vcPasswd, vdVigencia
          FROM si_ejecut
         WHERE sucursal = vcSucursal
           AND nombre = vcNombreGte;
        
        IF ( vcPasswd IN('BAJA','baja') OR vdVigencia <= vdFechaHoy ) THEN
            FOREACH
                SELECT nombre, fecha_insert
                  INTO vcNuevoGte, vdFechaIns
                  FROM si_ejecut
                 WHERE sucursal = vcSucursal
                   AND puesto = '001'
                   AND ejecutivo LIKE '9%'
                   AND vigencia > vdFechaHoy
                   AND password NOT IN('BAJA', 'baja')
                 ORDER BY fecha_insert
                 
                IF vcNuevoGte is not null OR vcNuevoGte <> '' THEN
                    UPDATE si_sucursales
                       SET gerente = vcNuevoGte
                     WHERE sucursal = vcSucursal;
                     
                    LET viContador2 = viContador2 + 1;   
                    
                    EXIT FOREACH;
                END IF;
            END FOREACH;
        END IF
        
        LET viContador1 = viContador1 + 1;        
        
        COMMIT WORK;
        LET viTrxAbierta = 0;
        
        LET vcSucursal   = '';
        LET vcNombreGte  = '';
        LET vcPasswd     = '';
        LET vdVigencia   = '';
        LET vcNuevoGte   = '';
        LET vdFechaIns   = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;
    
END PROCEDURE;