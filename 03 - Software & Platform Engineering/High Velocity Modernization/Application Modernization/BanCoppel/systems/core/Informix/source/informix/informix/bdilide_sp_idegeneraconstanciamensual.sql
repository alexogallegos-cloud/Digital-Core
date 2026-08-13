CREATE PROCEDURE "informix".sp_idegeneraconstanciamensual()
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
    DEFINE pEmpresa         CHAR(3);
    DEFINE pFecha           DATE;
    DEFINE vdUltimoDiaMes   DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes     DATE;
    DEFINE vfecha_hoy       DATE;
    DEFINE vdia             CHAR(2);
    DEFINE vfecha_valida    DATE;
    DEFINE vfecha_validada  DATE;
    DEFINE vAniomes         CHAR(6);
    DEFINE vexiste          CHAR(25);
    DEFINE vcStatus         CHAR(1);
    DEFINE vmin_numcte      CHAR(20);
    DEFINE vmax_numcte      CHAR(20);
    DEFINE vNumcliente      CHAR(20);
    DEFINE vRfc             CHAR(13);
    DEFINE vImpanterior     MONEY(16,2);
    DEFINE vImpacumulado    MONEY(16,2);
    DEFINE vmImpGrabado     MONEY(16,2);
    DEFINE vImparecaudar    MONEY(16,2);
    DEFINE vImprecaudado    MONEY(16,2);
    DEFINE vImppendiente    MONEY(16,2);
    DEFINE vTipocambio      MONEY(16,2);
    DEFINE pUsuario         CHAR(8);
    
    LET vCodRet         = "000";
    LET vCodRet2        = "";
    LET vCodRet3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vcomienza       = -1;
    LET vcontador       = 0;
    LET vcIniciaTran    = 'N';
    LET pEmpresa        = '001';
    LET pFecha          = '';
    LET vdUltimoDiaMes  = '';
    LET vpri_dia_mes    = '';
    LET vult_dia_mes    = '';
    LET vfecha_hoy      = '';
    LET vdia            = '';
    LET vfecha_valida   = '';
    LET vfecha_validada = '';
    LET vAniomes        = "";
    LET vexiste         = '';
    LET vcStatus        = '';
    LET vmin_numcte     = '';
    LET vmax_numcte     = '';
    LET vNumcliente     = "";
    LET vRfc            = "";
    LET vImpanterior    = 0;
    LET vImpacumulado   = 0;
    LET vmImpGrabado    = 0.00;
    LET vImparecaudar   = 0;
    LET vImprecaudado   = 0;
    LET vImppendiente   = 0;
    LET vTipocambio     = 0;
    LET pUsuario        = 'informix';  
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_idegeneraconstanciamensual.err";
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
    
    --- SET DEBUG FILE TO "/tmp/sp_idegeneraconstanciamensual.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_ant, fecha_ant, fecha_hoy - 1 UNITS MONTH, fecha_ant, fecha_hoy, fecha_hoy
      INTO pFecha, vdUltimoDiaMes, vpri_dia_mes, vult_dia_mes, vfecha_hoy, vfecha_valida
      FROM bdinteg:si_fechas
     WHERE empresa = pempresa;
     
    LET vdia = SUBSTR(vfecha_valida,4,2);
    LET vdia = vdia;
    
    IF LPAD(vdia,2,'0') <> "01" THEN
        IF LPAD(vdia,2,'0') = "02" THEN
            LET vfecha_validada = vfecha_valida - 1;
            
            EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_validada,"") 
            INTO vCodRet, vfecha_validada;
            
            IF vfecha_validada <> vfecha_valida THEN
                RETURN vCodRet, vcontador;
            ELSE
                LET vpri_dia_mes = vpri_dia_mes - 1;
            END IF
        ELSE
            RETURN vCodRet, vcontador;
        END IF
    END IF
    
    -- // SE TOMA EL ANO Y MES CON BASE EN LA FECHA DE PARÁMETRO
    LET vAniomes = CAST(TO_CHAR(pFecha, '%Y%m') AS char(6));
    
    SELECT MIN(num_cte), MAX(num_cte) 
      INTO vmin_numcte, vmax_numcte 
      FROM sl_detlide;
    
    -- // SE VERIFICA QUE SE HAYAN EJECUTADO LOS PROCESOS PREVIOS
    SELECT {+INDEX(bdilide:sl_procesos idx_procesos)} proceso 
      INTO vexiste
      FROM sl_procesos 
     WHERE proceso = 'ret_dialde' 
       AND fech_proceso = vdUltimoDiaMes 
       AND status = 1;
       
    IF vexiste is not null OR vexiste <> '' THEN
        -- // SE OBTIENE EL ESTADO DEL PROCESO CONSTANCIA MENSUAL
        SELECT status  
          INTO vcStatus 
          FROM sl_procesos  
         WHERE proceso = "conmensual" 
           AND fech_proceso = pFecha;
           
        -- // SI ES NÚLO EL PROCESO NO EXISTE Y ENTONCES SE REGISTRA
        IF vcStatus IS NULL THEN
            INSERT INTO sl_procesos
            ( proceso, fech_proceso, status, user_insert, fecha_insert )
            VALUES
            ( "conmensual", pFecha, '0', pUsuario, vfecha_hoy );
        ELIF vcStatus = '0' or  vcStatus = '' THEN
            DELETE FROM sl_constancias 
             WHERE aniomes = vAnioMes
               AND num_cte BETWEEN vmin_numcte AND vmax_numcte
               AND tipo_cons = 'M';
        ELIF vcStatus = '1' THEN
            LET vCodRet = '002';
            RETURN vCodRet, vcontador;
        END IF;
          
        FOREACH WITH HOLD
            SELECT DISTINCT num_cte
              INTO vNumcliente
              FROM sl_detlide
             WHERE num_cte BETWEEN vmin_numcte AND vmax_numcte
               AND fecha_ret BETWEEN vpri_dia_mes AND vult_dia_mes
               
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET vcIniciaTran = 'S';
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
            LET vRfc          = '';
            LET vImpanterior  = 0.00;
            LET vImpacumulado = 0.00;
            LET vmImpGrabado  = 0.00;
            LET vImparecaudar = 0.00;
            LET vImprecaudado = 0.00;
            LET vImppendiente = 0.00;
        END FOREACH;
    
        -- // SE ACTUALIZA ÉSTE PROCESO PARA INDICAR QUE SE EJECUTÓ CORRECTAMENTE. (PROCESO DE CONSTANCIAS MENSUAL).
        UPDATE sl_procesos 
           set status = '1' 
         WHERE proceso = 'conmensual' 
           AND fech_proceso = pFecha;
           
        IF vcontador > 0 OR vcIniciaTran = 'S' THEN
            LET vcIniciaTran = 'N';
            COMMIT WORK;
        END IF;
        
        -- // Controlde Procesos
        INSERT INTO bdinteg:sx_contproc
        ( empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret )
        VALUES
        ( pEmpresa, 'Gecmlide', pFecha, '23', 'F', pUsuario, current hour to fraction(3), current hour to fraction(3), vCodRet );
    ELSE
        LET vCodRet = "001";
        RETURN vCodRet, vcontador;
    END IF;
    
    END;
    
    RETURN vCodRet, vcontador;
    
END PROCEDURE;