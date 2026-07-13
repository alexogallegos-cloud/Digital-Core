CREATE PROCEDURE "informix".sp_idegeneraconstanciamensual_esp( pFechaIni DATE, pFechaFin DATE )
RETURNING CHAR(5), INTEGER;

    DEFINE vCodRet          CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdescerr         CHAR(50);
    DEFINE vAniomes         CHAR(6);
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes     DATE;
    DEFINE vConstancias     INTEGER;
    DEFINE vcNumCte         CHAR(20);
    DEFINE vcRfc            CHAR(13);
    DEFINE vComienza        SMALLINT;
    DEFINE viTransacc       SMALLINT;  
    DEFINE viContCommit     INTEGER;
    DEFINE vmin_aniomes     CHAR(6);
    DEFINE vmax_aniomes     CHAR(6);
    DEFINE vmin_cuenta      CHAR(20);
    DEFINE vmax_cuenta      CHAR(20);
    DEFINE vNumcliente      CHAR(20);
    DEFINE vRfc             CHAR(13);
    DEFINE vImpacumulado    MONEY(16,2);
    DEFINE vImparecaudar    MONEY(16,2);
    DEFINE vImprecaudado    MONEY(16,2);
    DEFINE vImppendiente    MONEY(16,2);
    DEFINE vImpanterior     MONEY(16,2);
    DEFINE vmImpGrabado     MONEY(16,2);
    DEFINE vTipocambio      MONEY(16,2);
    DEFINE vcIniciaTran     CHAR(1);
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    
    LET vCodRet = "000";
    LET vCodRet2 = "";
    LET vCodRet3 = "";
    LET vsqlerr = 0;
    LET visamerr = 0;
    LET vdescerr = 0;
    LET vAniomes = "";
    LET vpri_dia_mes = '';
    LET vult_dia_mes = '';
    LET vConstancias = 0;
    LET vcNumCte = '';
    LET vcRfc = '';
    LET vComienza = -1;
    LET viTransacc = 0;
    LET viContCommit = 0;
    LET vmin_aniomes = '';
    LET vmax_aniomes = '';
    LET vmin_cuenta = '';
    LET vmax_cuenta = '';
    LET vNumcliente = "";
    LET vRfc = "";
    LET vImpacumulado = 0;
    LET vImparecaudar = 0;
    LET vImprecaudado = 0;
    LET vImppendiente = 0;
    LET vImpanterior = 0;
    LET vmImpGrabado = 0.00;
    LET vTipocambio = 0;
    LET vcIniciaTran = 'N';
    LET vcontador = -1;
    LET vcuantos = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_idegeneraconstanciamensual_esp.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vCodRet = vsqlerr;
            LET vCodRet2 = visamerr;
            LET vCodRet3 = vdescerr;
            IF vcIniciaTran = 'S' OR viTransacc = 1 THEN
                ROLLBACK WORK; 
            END IF;
            RETURN vCodRet, vcuantos;
        END IF;
    END  EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_idegeneraconstanciamensual_esp.out";
    --- TRACE ON;
    
    -- // SE TOMA EL AÑO Y MES CON BASE EN LA FECHA DE PARÁMETRO
    LET vAniomes = CAST(TO_CHAR(pFechaFin, '%Y%m') AS CHAR(6));
    
    -- // FECHA INICIAL Y FINAL DEL PERIODO
    LET vpri_dia_mes = pFechaIni;
    LET vult_dia_mes = pFechaFin;
          
    -- // ELIMINA CONSTACIAS DEL PERIODO A GENERAR
    SELECT COUNT(*)
      INTO vConstancias
      FROM bdilide:sl_constancias 
     WHERE aniomes = vAnioMes
       AND tipo_cons = 'M';
    
    IF vConstancias > 0 THEN
        FOREACH WITH HOLD
            SELECT num_cte, rfc
              INTO vcNumCte, vcRfc
              FROM bdilide:sl_constancias
             WHERE aniomes = vAnioMes
               AND num_cte is not null
               AND tipo_cons = 'M'
               AND rfc is not null
               
            IF vComienza = -1 THEN
                LET vComienza = 0;
                BEGIN WORK;
                LET viTransacc = 1;
            END IF;
            
            DELETE FROM bdilide:sl_constancias
             WHERE aniomes = vAnioMes
               AND num_cte = vcNumCte
               AND tipo_cons = 'M'
               AND rfc = vcRfc;
               
            LET viContCommit = viContCommit + 1;
            
            IF viContCommit >= 1000 THEN
                COMMIT WORK;
                BEGIN WORK;
                LET viContCommit = 0;
            END IF;
            
            LET vcNumCte  = '';
            LET vcRfc     = '';
        END FOREACH;
        
        IF viTransacc = 1 THEN
            LET viTransacc = 0;
            COMMIT WORK;
        END IF;
    END IF;
    
    -- // GENERACION DE CONSTANCIAS MENSUALES
    SELECT MIN(aniomes), MAX(aniomes), MIN(cuenta_ret), MAX(cuenta_ret)
      INTO vmin_aniomes, vmax_aniomes, vmin_cuenta, vmax_cuenta
      FROM bdilide:sl_detlide;
      
    FOREACH WITH HOLD
        SELECT DISTINCT num_cte
          INTO vNumcliente
          FROM bdilide:sl_detlide
         WHERE cuenta_ret BETWEEN vmin_cuenta AND vmax_cuenta
           AND aniomes BETWEEN vmin_aniomes AND vmax_aniomes
           AND fecha_ret BETWEEN vpri_dia_mes AND vult_dia_mes
           
        IF vcontador = -1 THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET vcIniciaTran = 'S';
        END IF;

        SELECT rfc
          INTO vRfc 
          FROM bdinteg:si_cliente 
         WHERE numcte = vNumcliente;
         
        IF vRfc is null THEN
            LET vRfc = ' ';
        END IF;

        -- // SE OBTIENE EL IMPUESTO RECAUDADO DE LOS MESES ANTERIORES
        SELECT SUM(imp_recaudado)
          INTO vImpanterior
          FROM bdilide:sl_detlide
         WHERE cuenta_ret BETWEEN vmin_cuenta AND vmax_cuenta
           AND aniomes < vAnioMes
           AND fecha_ret BETWEEN vpri_dia_mes AND vult_dia_mes
           AND num_cte = vNumcliente;
           
        IF vImpanterior is null THEN
            LET vImpanterior = 0.00;
        END IF;

        SELECT imp_acumulado, imp_gravado, imp_arecaudar, imp_recaudado
          INTO vImpacumulado, vmImpGrabado, vImparecaudar, vImprecaudado   
          FROM bdilide:sl_retlide
         WHERE aniomes = vAniomes 
           AND num_cte = vNumcliente; 
           
        IF vImpacumulado is null THEN
            LET vImpacumulado = 0.00;
        END IF;
        
        IF vmImpGrabado is null THEN
            LET vmImpGrabado = 0.00;
        END IF;
        
        IF vImparecaudar is null THEN
            LET vImparecaudar = 0.00;
        END IF;
        
        IF vImprecaudado is null THEN
            LET vImprecaudado = 0.00;
        END IF;
        
        LET vImppendiente = vImparecaudar - vImprecaudado;

        -- // SE INSERTA EN LA TABLA bdilide:sl_constancias CON LOS DATOS OBTENIDOS ANTERIORMENTE.
        INSERT INTO bdilide:sl_constancias 
        (aniomes,num_cte,tipo_cons,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert)
        VALUES
        (vAnioMes,vNumcliente,'M',vRfc,vmImpGrabado,vImparecaudar,vImprecaudado,vImppendiente,vImpanterior,vTipocambio,'informix',CURRENT::DATE);
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vcontador > 0 OR vcIniciaTran = 'S' THEN
        LET vcuantos = vcuantos + vcontador;
        LET vcIniciaTran = 'N';
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet, vcuantos;
    
END PROCEDURE;