CREATE PROCEDURE "informix".sp_idegeneraconstanciamensual_201212()
RETURNING CHAR(5), INTEGER;
    
    DEFINE vCodRet          CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdescerr         CHAR(50);
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador        INTEGER;
    DEFINE vcIniciaTran     CHAR(1);
    
    DEFINE pFecha           DATE;
    DEFINE vdUltimoDiaMes   DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes     DATE;
    DEFINE vfecha_hoy       DATE;
    DEFINE vAniomes         CHAR(6);
    
    DEFINE vNumcliente      CHAR(20);
    DEFINE vexiste_cons     CHAR(25);
    DEFINE vRfc             CHAR(13);
    DEFINE vImpanterior     MONEY(16,2);
    DEFINE vImpacumulado    MONEY(16,2);
    DEFINE vmImpGrabado     MONEY(16,2);
    DEFINE vImparecaudar    MONEY(16,2);
    DEFINE vImprecaudado    MONEY(16,2);
    DEFINE vImppendiente    MONEY(16,2);
    DEFINE vTipocambio      MONEY(16,2);
    DEFINE pUsuario         CHAR(8);
    
    LET vCodRet      = "000";
    LET vCodRet2     = "";
    LET vCodRet3     = "";
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = '';
    LET vcomienza    = -1;
    LET vcontador    = 0;
    LET vcIniciaTran = 'N';
    
    LET pFecha         = '';
    LET vdUltimoDiaMes = '';
    LET vpri_dia_mes   = '';
    LET vult_dia_mes   = '';
    LET vfecha_hoy     = '';
    LET vAniomes       = "";
    
    LET vNumcliente   = "";
    LET vexiste_cons  = 0;
    LET vRfc          = "";
    LET vImpanterior  = 0;
    LET vImpacumulado = 0;
    LET vmImpGrabado  = 0.00;
    LET vImparecaudar = 0;
    LET vImprecaudado = 0;
    LET vImppendiente = 0;
    LET vTipocambio   = 0;
    LET pUsuario      = 'informix';  
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_idegeneraconstanciamensual_201212.err";
        TRACE ON;
        IF vsqlerr <> 0  THEN
            LET vCodRet = vsqlerr;
            LET vCodRet2 = visamerr;
            LET vCodRet3 = vdescerr;
            IF  vcIniciaTran = 'S' THEN
                ROLLBACK WORK; 
            END IF;
            RETURN vCodRet, vcontador;
        END IF;
    END  EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_idegeneraconstanciamensual_201212.out";
    --- TRACE ON;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET pFecha         = '12/31/2012';
    LET vdUltimoDiaMes = '12/31/2012';
    LET vpri_dia_mes   = '12/01/2012';
    LET vult_dia_mes   = '12/31/2012';
    LET vfecha_hoy     = '01/02/2013';  
    
    -- // SE TOMA EL ANO Y MES CON BASE EN LA FECHA DE PARÁMETRO
    LET vAniomes = CAST(TO_CHAR(pFecha, '%Y%m') AS char(6));
    
    FOREACH WITH HOLD
        SELECT DISTINCT num_cte
          INTO vNumcliente
          FROM sl_detlide
         WHERE num_cte is not null
           AND fecha_ret = '12/01/2012'
           
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET vcIniciaTran = 'S';
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste_cons
          FROM sl_constancias
         WHERE num_cte = vNumcliente
           AND aniomes = vAnioMes
           AND tipo_cons = 'M';
           
        IF vexiste_cons > 0 THEN
            DELETE FROM sl_constancias
             WHERE num_cte = vNumcliente
               AND aniomes = vAnioMes
               AND tipo_cons = 'M';
        END IF;
        
        SELECT rfc
          INTO vRfc 
          FROM bdinteg:si_cliente 
         WHERE numcte = vNumcliente;
         
        IF vRfc is null THEN
            LET vRfc = ' ';
        END IF;
        
        SELECT SUM(imp_recaudado)
          INTO vImpanterior
          FROM sl_detlide
         WHERE num_cte = vNumcliente
           AND fecha_ret BETWEEN vpri_dia_mes AND vult_dia_mes
           AND aniomes < vAnioMes;
           
        IF vImpanterior is null THEN
            LET vImpanterior = 0.00;
        END IF;
           
        SELECT imp_acumulado, imp_gravado, imp_arecaudar, imp_recaudado
          INTO vImpacumulado, vmImpGrabado, vImparecaudar, vImprecaudado   
          FROM sl_retlide
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
        INSERT INTO sl_constancias 
        ( aniomes, num_cte, tipo_cons, rfc, imp_excedente, imp_arecaudar, imp_recaudado, imp_pendiente, imp_anterior, tipo_cambio, user_insert, fecha_insert )
        VALUES
        ( vAnioMes, vNumcliente, 'M', vRfc, vmImpGrabado, vImparecaudar, vImprecaudado, vImppendiente, vImpanterior, vTipocambio, pUsuario, vfecha_hoy );
        
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vNumcliente   = '';
        LET vexiste_cons  = 0;
        LET vRfc          = '';
        LET vImpanterior  = 0.00;
        LET vImpacumulado = 0.00;
        LET vmImpGrabado  = 0.00;
        LET vImparecaudar = 0.00;
        LET vImprecaudado = 0.00;
        LET vImppendiente = 0.00;
    END FOREACH;
    
    IF vcIniciaTran = 'S' THEN
        LET vcIniciaTran = 'N';
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet, vcontador;
        
END PROCEDURE;