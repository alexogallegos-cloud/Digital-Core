CREATE PROCEDURE "informix".prov_diames( pempresa CHAR(3) )
RETURNING CHAR(5);
    
    -- **********************************************************
    -- *    v1.1 ago 08                                         *
    -- *    se cambio la busqueda de la provision a sv_movhis   *
    -- *    se ajustaron algunas validaciones del nvl           *
    -- *    v1 version inicial                                  *
    -- **********************************************************
    
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE vcomienza        smallint;
    DEFINE vcontador        integer;
    DEFINE ven_transacc     smallint;
    
    DEFINE vfechahoy        date;
    DEFINE vfechainimes     date;
    DEFINE vfechafinmes     date;
    DEFINE vdiames          smallint;
    DEFINE vaniomes         char(6);  
    
    DEFINE vcuenta          char(20);
    DEFINE vsecuencia       smallint;
    DEFINE vsucursal        char(4);
    DEFINE vcapital         money(14,2);
    DEFINE vfecha_alta      date;
    DEFINE vfechavenc       date;
    DEFINE vtranprov        char(4);
    DEFINE vtranint         char(4);
    DEFINE vintprovdia      money(14,2);  
    DEFINE vintprovant      money(14,2);  
    DEFINE vtotprovmes      money(14,2);  
    DEFINE vintpagados      money(14,2);  
    DEFINE vexistedia       integer;
    DEFINE vexistemes       integer;
    
    DEFINE vtrandesprov     char(4);
    DEFINE vmonto_prov      money(14,2);
    DEFINE vmonto_desprov   money(14,2);
    
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vcomienza    = -1;
    LET vcontador    = 0;
    LET ven_transacc = 0;
    
    LET vfechahoy    = '';
    LET vfechainimes = '';
    LET vfechafinmes = '';
    LET vdiames      = '';
    LET vaniomes     = '';
    
    LET vcuenta     = '';
    LET vsecuencia  = 0;
    LET vsucursal   = '';
    LET vcapital    = 0.00;
    LET vfecha_alta = '';
    LET vfechavenc  = '';
    LET vtranprov   = '';
    LET vtranint    = '';
    LET vexistedia  = 0;
    LET vexistemes  = 0;
    LET vintprovdia = 0.00;
    LET vintprovant = 0.00;
    LET vtotprovmes = 0.00;
    LET vintpagados = 0.00;
    
    LET vtrandesprov = '';
    LET vmonto_prov  = 0.00;
    LET vmonto_desprov = 0.00;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/prov_diames.err";
        TRACE ON;
        IF sql_err <> 0 OR isam_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/prov_diames.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA LA INFORMACION DE ENTRADA
    IF pempresa IS NULL OR pempresa = '' THEN
        LET vcodret1 = '110';
        RETURN vcodret1;
    END IF;
    
    SELECT valor
      INTO vtrandesprov
      FROM sv_param
     WHERE codparam = 'tranrevprov'
       AND empresa = pempresa;

    -- // OBTIENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
      INTO vfechahoy, vfechainimes, vfechafinmes
      FROM sv_fechas
     WHERE empresa = pempresa;

    LET vdiames  = to_char(vfechahoy, "%d");   
    LET vaniomes = to_char(vfechahoy, "%Y%m"); 
    
    -- // OBTIENE LAS INVERSIONES ACTIVAS Y LAS QUE VENCIERON HOY 
    FOREACH 
        SELECT mae.cuenta, mae.secuencia, mae.sucursal, mae.capital, mae.fecha_alta, mae.fecha_venc, ins.trans_prov, ins.trans_int
          INTO vcuenta, vsecuencia, vsucursal, vcapital, vfecha_alta, vfechavenc, vtranprov, vtranint
          FROM sv_maeinv mae, 
               sv_instrum ins
         WHERE ( mae.status_cta = "1" OR mae.fecha_venc = vfechahoy )
           AND ins.empresa = mae.empresa
           AND ins.cod_instrum = mae.cod_instrum
         ORDER BY mae.cuenta, mae.secuencia

        -- // SI NO EXISTE INSERTAR REGISTRO EN LA TABLA DE SALDOS DIARIOS Y PROVISIONES
        SELECT COUNT(*)
          INTO vexistedia
          FROM sv_provdia
         WHERE empresa   = pempresa
           AND cuenta    = vcuenta
           AND secuencia = vsecuencia
           AND sucursal  = vsucursal
           AND aniomes   = vaniomes;

        IF vexistedia = 0 THEN 
            INSERT INTO sv_provdia(empresa, cuenta, secuencia, sucursal, aniomes, totprovmes)
            VALUES(pempresa, vcuenta, vsecuencia, vsucursal, vaniomes, 0);
        END IF;
        
        -- // PROVISION DE INTERESES
        IF ( vfechahoy <> vfechafinmes AND vfechahoy <> vfechavenc ) THEN
            
            -- // PROVISONES
            SELECT SUM(monto_tot)
              INTO vmonto_prov
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtranprov
               AND cancelad <> 'S';
               
            IF vmonto_prov is null THEN
                LET vmonto_prov = 0.00;
            END IF;
            
            -- // DESPROVISONES
            SELECT SUM(monto_tot)
              INTO vmonto_desprov
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtrandesprov
               AND cancelad <> 'S';
               
            IF vmonto_desprov is null THEN
                LET vmonto_desprov = 0.00;
            END IF;
               
            LET vintprovdia = vmonto_prov - vmonto_desprov;
            LET vintprovdia = vintprovdia;
            
        ELIF ( vfechahoy = vfechafinmes AND vfechahoy <> vfechavenc ) THEN
        
            -- // PROVISONES
            SELECT SUM(monto_tot)
              INTO vmonto_prov
              FROM sv_movhis
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia       
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtranprov
               AND cancelad <> 'S';
               
            IF vmonto_prov is null THEN
                LET vmonto_prov = 0.00;
            END IF;
            
            -- // DESPROVISONES
            SELECT SUM(monto_tot)
              INTO vmonto_desprov
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtrandesprov
               AND cancelad <> 'S';
               
            IF vmonto_desprov is null THEN
                LET vmonto_desprov = 0.00;
            END IF;
               
            LET vintprovdia = vmonto_prov - vmonto_desprov;
            LET vintprovdia = vintprovdia;
            LET vtotprovmes = vintprovdia;
               
            -- // INSERTAR EN TABLA DE SALDOS MENSUALES
            SELECT COUNT(*)
              INTO vexistemes
              FROM sv_provmes
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND sucursal  = vsucursal
               AND aniomes   = vaniomes;

            IF vexistemes = 0 THEN 
                INSERT INTO sv_provmes VALUES 
                (pempresa,vcuenta,vsecuencia,vsucursal,vaniomes,vcapital,vtotprovmes,vcapital,vtotprovmes,0.00);
            END IF; 
        END IF;            
        
        -- // PAGO DE INTERESES (VENCIMIENTO)
        IF ( vfechahoy = vfechavenc ) THEN
        
            -- // PROVISIONES
            SELECT SUM(monto_tot)
              INTO vmonto_prov
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtranprov
               AND cancelad <> 'S';
               
            IF vmonto_prov is null THEN
                LET vmonto_prov = 0.00;
            END IF;
            
            -- // DESPROVISONES
            SELECT SUM(monto_tot)
              INTO vmonto_desprov
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  >= vfecha_alta 
               AND fech_alt  <= vfechahoy
               AND transacc  = vtrandesprov
               AND cancelad <> 'S';
               
            IF vmonto_desprov is null THEN
                LET vmonto_desprov = 0.00;
            END IF;
            
            -- // PAGO DE INTERESES DEL DIA
            SELECT SUM(monto_tot)
              INTO vintpagados
              FROM sv_movhis  
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND fech_alt  = vfechahoy
               AND transacc  = vtranint
               AND cancelad <> 'S';
               
            IF vintpagados is null THEN
                LET vintpagados = 0.00;
            END IF;
            
            LET vintprovdia = vmonto_prov - vmonto_desprov;
            LET vintprovdia = vintprovdia;
            LET vtotprovmes = vintprovdia;
            LET vintpagados = vintpagados;
            LET vintprovdia = vintprovdia - vintpagados;
                
            -- // INSERTAR EN TABLA DE SALDOS MENSUALES
            SELECT COUNT(*)
              INTO vexistemes
              FROM sv_provmes
             WHERE empresa   = pempresa
               AND cuenta    = vcuenta
               AND secuencia = vsecuencia
               AND sucursal  = vsucursal
               AND aniomes   = vaniomes;
            
            IF vexistemes = 0 THEN 
                INSERT INTO sv_provmes VALUES 
                (pempresa, vcuenta, vsecuencia, vsucursal, vaniomes, 0.00, 0.00, vcapital, 0.00, vintpagados);
            END IF;
            
        END IF; 
        
        IF vfechahoy = vfechavenc THEN
            LET vcapital = 0.00;
        END IF;
        
        -- // ACTUALIZA TABLA DE SALDOS DIARIOS Y PROVISIONES
        IF vdiames = 1 THEN
            UPDATE sv_provdia 
               SET cv_dia1     = vcapital, 
                   ipa_dia1    = vintprovdia, 
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa 
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 2 THEN
            UPDATE sv_provdia 
               SET cv_dia2     = vcapital,
                   ipa_dia2    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 3 THEN
            UPDATE sv_provdia 
               SET cv_dia3     = vcapital,
                   ipa_dia3    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 4 THEN
            UPDATE sv_provdia 
               SET cv_dia4     = vcapital,
                   ipa_dia4    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 5 THEN
            UPDATE sv_provdia 
               SET cv_dia5     = vcapital,
                   ipa_dia5    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 6 THEN
            UPDATE sv_provdia 
               SET cv_dia6     = vcapital,
                   ipa_dia6    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 7 THEN
            UPDATE sv_provdia 
               SET cv_dia7     = vcapital,
                   ipa_dia7    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 8 THEN
            UPDATE sv_provdia 
               SET cv_dia8     = vcapital,
                   ipa_dia8    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 9 THEN
            UPDATE sv_provdia 
               SET cv_dia9     = vcapital,
                   ipa_dia9    = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 10 THEN
            UPDATE sv_provdia 
               SET cv_dia10    = vcapital,
                   ipa_dia10   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 11 THEN
            UPDATE sv_provdia 
               SET cv_dia11    = vcapital,
                   ipa_dia11   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 12 THEN
            UPDATE sv_provdia 
               SET cv_dia12    = vcapital,
                   ipa_dia12   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 13 THEN
            UPDATE sv_provdia 
               SET cv_dia13    = vcapital,
                   ipa_dia13   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 14 THEN
            UPDATE sv_provdia 
               SET cv_dia14    = vcapital,
                   ipa_dia14   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 15 THEN
            UPDATE sv_provdia 
               SET cv_dia15    = vcapital,
                   ipa_dia15   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 16 THEN
            UPDATE sv_provdia 
               SET cv_dia16    = vcapital,
                   ipa_dia16   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 17 THEN
            UPDATE sv_provdia 
               SET cv_dia17    = vcapital,
                   ipa_dia17   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 18 THEN
            UPDATE sv_provdia 
               SET cv_dia18    = vcapital,
                   ipa_dia18   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 19 THEN
            UPDATE sv_provdia 
               SET cv_dia19    = vcapital,
                   ipa_dia19   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 20 THEN
            UPDATE sv_provdia 
               SET cv_dia20    = vcapital,
                   ipa_dia20   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 21 THEN
            UPDATE sv_provdia 
               SET cv_dia21    = vcapital,
                   ipa_dia21   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 22 THEN
            UPDATE sv_provdia 
               SET cv_dia22    = vcapital,
                   ipa_dia22   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 23 THEN
            UPDATE sv_provdia 
               SET cv_dia23    = vcapital,
                   ipa_dia23   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 24 THEN
            UPDATE sv_provdia 
               SET cv_dia24    = vcapital,
                   ipa_dia24   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 25 THEN
            UPDATE sv_provdia 
               SET cv_dia25    = vcapital,
                   ipa_dia25   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 26 THEN
            UPDATE sv_provdia 
               SET cv_dia26    = vcapital,
                   ipa_dia26   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 27 THEN
            UPDATE sv_provdia 
               SET cv_dia27    = vcapital,
                   ipa_dia27   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 28 THEN
            UPDATE sv_provdia 
               SET cv_dia28    = vcapital,
                   ipa_dia28   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 29 THEN
            UPDATE sv_provdia 
               SET cv_dia29    = vcapital,
                   ipa_dia29   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 30 THEN
            UPDATE sv_provdia 
               SET cv_dia30    = vcapital,
                   ipa_dia30   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        ELIF vdiames = 31 THEN
            UPDATE sv_provdia 
               SET cv_dia31    = vcapital,
                   ipa_dia31   = vintprovdia,
                   totprovmes  = vtotprovmes
             WHERE empresa     = pempresa
               AND cuenta      = vcuenta
               AND secuencia   = vsecuencia
               AND sucursal    = vsucursal
               AND aniomes     = vaniomes;        
        END IF;
        
        LET vcontador = vcontador + 1;
        
        LET vcuenta     = '';
        LET vsecuencia  = 0;
        LET vsucursal   = '';
        LET vcapital    = 0.00;
        LET vfecha_alta = '';
        LET vfechavenc  = '';
        LET vtranprov   = '';
        LET vtranint    = '';
        LET vexistedia  = 0;
        LET vexistemes  = 0;
        LET vintprovdia = 0.00;
        LET vtotprovmes = 0.00;
        LET vintprovant = 0.00;
        LET vintpagados = 0.00;

    END FOREACH;
        
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;