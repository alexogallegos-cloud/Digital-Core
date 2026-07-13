CREATE PROCEDURE "informix".sp_idegeneraconstanciamensual_1011()

	RETURNING CHAR(5), INTEGER;

    DEFINE vCodRet          CHAR(5);
    DEFINE vNumcliente      CHAR(20);
    DEFINE vRfc             CHAR(13);
    DEFINE vImpacumulado    MONEY(16,2);
    DEFINE vImparecaudar    MONEY(16,2);
    DEFINE vImprecaudado    MONEY(16,2);
    DEFINE vImppendiente    MONEY(16,2);
    DEFINE vImpanterior     MONEY(16,2);
    DEFINE vTipocambio      MONEY(16,2);
    DEFINE vAniomes         CHAR(6);
    DEFINE vProceso         CHAR(10);
    DEFINE vcStatus         CHAR(1);
    DEFINE vmImpGrabado     MONEY(16,2);
    DEFINE vdUltimoDiaMes   DATE;
    DEFINE vsqlerr          INTEGER;
    DEFINE vcIniciaTran     CHAR(1);
    DEFINE vexiste          CHAR(25);
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes     DATE;
    DEFINE vmax_aniomes     CHAR(6);
    DEFINE vmin_aniomes     CHAR(6);
    DEFINE vmin_cuenta      CHAR(20);
    DEFINE vmax_cuenta      CHAR(20);
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vfecha_hoy       DATE;
    DEFINE vmin_numcte      CHAR(20);
    DEFINE vmax_numcte      CHAR(20);
    DEFINE pEmpresa         CHAR(3);
    DEFINE pFecha           DATE;
    DEFINE vfecha_valida    DATE;
    DEFINE vdia             CHAR(2);
    DEFINE vfecha_validada  DATE;
    DEFINE pUsuario         CHAR(8);

    LET pEmpresa = '001';
    LET pUsuario = 'informix';
    LET pFecha = '';
    LET vCodRet = "000";
    LET vNumcliente = "";
    LET vRfc = "";
    LET vImpacumulado = 0;
    LET vImparecaudar = 0;
    LET vImprecaudado = 0;
    LET vImppendiente = 0;
    LET vImpanterior = 0;
    LET vTipocambio = 0;
    LET vAniomes = "";
    LET vProceso = '';
    LET vcStatus = '';
    LET vmImpGrabado = 0.00;
    LET vsqlerr = 0;
    LET vdUltimoDiaMes = '';
    LET vpri_dia_mes = '';
    LET vult_dia_mes = '';
    LET vfecha_hoy = '';
    LET vcIniciaTran = 'N';
    LET vcontador = -1;
    LET vcuantos = 0;
    LET vmin_numcte = '';
    LET vmax_numcte = '';
    LET vfecha_valida = '';
    LET vdia = '';
    LET vfecha_validada = '';

    BEGIN

    ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_idegeneraconstanciamensual.err";
        TRACE ON;
        IF vsqlerr <> 0  THEN
            IF  vcIniciaTran = 'S' THEN
                ROLLBACK WORK; 
            END IF;
            LET vCodRet = vsqlerr;
            RETURN vCodRet, vcuantos;
        END IF;
    END  EXCEPTION;

    -- SET DEBUG FILE TO "/tmp/sp_idegeneraconstanciamensual.out";
    -- TRACE ON;

    {
	SELECT fecha_ant, fecha_ant, fecha_hoy - 1 UNITS MONTH, fecha_ant, fecha_hoy, fecha_hoy
      INTO pFecha, vdUltimoDiaMes, vpri_dia_mes, vult_dia_mes, vfecha_hoy, vfecha_valida
      FROM bdinteg:si_fechas
     WHERE empresa = pempresa;
    }
	
    LET pFecha          = '04302018';    LET vdUltimoDiaMes  = '04302018';    LET vpri_dia_mes    = '04012018';    LET vult_dia_mes    = '04302018';    LET vfecha_hoy      = '05012018';    LET vfecha_valida   = '05012018';      
    LET vdia = SUBSTR(vfecha_valida,4,2);
    LET vdia = vdia;

    IF LPAD(vdia,2,'0') <> "01" THEN
        IF LPAD(vdia,2,'0') = "02" THEN
            LET vfecha_validada = vfecha_valida - 1;
            
            EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_validada,"") 
            INTO vCodRet, vfecha_validada;
            
            IF vfecha_validada <> vfecha_valida THEN
                RETURN vCodRet, vcuantos;
            END IF
        ELSE
            RETURN vCodRet, vcuantos;
        END IF
    END IF
    
    { ********************************************************************
    -- // SE OBTIENE FECHAS DEL SISTEMA
    SELECT ult_dia_mes, pri_dia_mes, ult_dia_mes, fecha_hoy
      INTO vdUltimoDiaMes, vpri_dia_mes, vult_dia_mes, vfecha_hoy
      FROM bdinteg:si_fechas;
      
    -- // SI NO ES FIN DE MES ENTONCES EL PROCEDIMIENTO SALE
    IF pFecha <> vdUltimoDiaMes THEN
        LET vCodRet  = '111';
        RETURN vCodRet, vcuantos;
    END IF;
    ******************************************************************** }
    
    -- // SE TOMA EL ANO Y MES CON BASE EN LA FECHA DE PARÁMETRO
    LET vAniomes = CAST(TO_CHAR(pFecha, '%Y%m') AS char(6));
    
    SELECT MIN(num_cte), MAX(num_cte) 
      INTO vmin_numcte, vmax_numcte 
      FROM sl_detlide;

    -- // SE VERIFICA QUE SE HAYA EJECUTADO EL PROCESO DE DECLARACIÓN MENSUAL
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
            INSERT INTO sl_procesos VALUES
            ("conmensual", pFecha, '0', pUsuario, vfecha_hoy);
        ELIF vcStatus = '0' or  vcStatus = '' THEN
            DELETE FROM sl_constancias 
             WHERE aniomes = vAnioMes
               AND num_cte BETWEEN vmin_numcte AND vmax_numcte
               AND tipo_cons = 'M';
        ELIF vcStatus = '1' THEN
            LET vCodRet = '002';
            RETURN vCodRet, vcuantos;
        END IF;
          
        FOREACH WITH HOLD
            SELECT DISTINCT num_cte
              INTO vNumcliente
              FROM sl_detlide
             WHERE num_cte BETWEEN vmin_numcte AND vmax_numcte
               AND fecha_ret BETWEEN vpri_dia_mes AND vult_dia_mes
               
            IF (vcontador = -1) THEN
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
                (aniomes,num_cte,tipo_cons,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert)
            VALUES
                (vAnioMes,vNumcliente,'M',vRfc,vmImpGrabado,vImparecaudar,vImprecaudado,vImppendiente,vImpanterior,vTipocambio,pUsuario,vfecha_hoy);
            
            LET vcontador = vcontador + 1;
            COMMIT WORK;
            BEGIN WORK;
            
            LET vNumcliente = '';
            LET vRfc = '';
            LET vImpanterior = 0.00;
            LET vImpacumulado = 0.00;
            LET vmImpGrabado = 0.00;
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
            LET vcuantos = vcuantos + vcontador;
            LET vcIniciaTran = 'N';
            COMMIT WORK;
        END IF;
        
        -- // Controlde Procesos
        INSERT INTO bdinteg:sx_contproc
            (empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
        VALUES
            (pEmpresa,'Gecmlide',pFecha,'23','F',pUsuario,current hour to fraction(3),current hour to fraction(3),vCodRet);

    ELSE
    
        LET vCodRet = "001";
        RETURN vCodRet, vcuantos;
        
    END IF;

    END;

    RETURN vCodRet, vcuantos;
    
END PROCEDURE;