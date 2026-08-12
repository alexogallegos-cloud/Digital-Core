CREATE PROCEDURE "informix".cierrechqinvcrec(pempresa CHAR(3))
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgusuario             CHAR(8)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE        DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod           DATE        DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta          DATE        DEFAULT " ";
    DEFINE GLOBAL vginstrucc            CHAR(2)     DEFAULT " ";
    DEFINE GLOBAL vgcuentadep           CHAR(20)    DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vsql                         CHAR(600);
    DEFINE vstmt                        CHAR(250);
    DEFINE vsistema                     CHAR(2);
    DEFINE vproceso                     CHAR(20);
    DEFINE vstatuscierreinv             CHAR(1);
    DEFINE vstatuscobroreestruc         CHAR(1);
    DEFINE vProdChequeras               CHAR(4);
    DEFINE vexiste                      CHAR(1);
    DEFINE vexiste2                     INTEGER;
    DEFINE vexistefin                   INTEGER;
    DEFINE vdias                        INTEGER;
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vregistros                   INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vProdChequerasPM             CHAR(4);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vexiste_cta                  SMALLINT;
    DEFINE vhora            		    DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc       		    CHAR(16);
    DEFINE vint_acum                    MONEY(14,2);
    DEFINE vfecultdep                   DATE;
    DEFINE vdiasinact                   INTEGER;
    DEFINE vabierto                     CHAR(1);
    DEFINE vaniomes                     CHAR(6);
    DEFINE vexiste_proy                 SMALLINT;
    DEFINE vtotsuc                      INTEGER;
    DEFINE vcontproc                    INTEGER;
    DEFINE vtfechaxxx                   DATE;
    DEFINE vnum_cte                     CHAR(20);
    DEFINE vfecha_alta                  DATE;
    DEFINE vhoraw           		    CHAR(15);
    DEFINE vfecha_mod                   DATE;
    DEFINE vProdPROAC                   CHAR(4);
	DEFINE vfecha_operacion             DATE;
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vcuentafin                   CHAR(20);

    LET vgusuario       = USER;
    LET vgfecha_hoy     = ' ';
    LET vgpri_dia_mes   = ' ';
    LET vgpri_hab_mes   = ' ';
    LET vgult_dia_mes   = ' ';
    LET vgult_hab_mes   = ' ';
    LET vgprox_fecha    = ' ';

    LET vgtrans_pag_int = ' ';
    LET vgtransisr      = ' ';
    LET vgtranprov      = ' ';
    LET vgtranrevprov   = ' ';
    LET vgtranabotrasp  = ' ';
    LET vgtranrecrece   = ' ';
    LET vgProdCreciente = ' ';
    LET vgstatus_cta    = ' ';
    LET vgfecha_mod     = ' ';
    LET vgfecha_alta    = ' ';

    LET vcodret              = "000";
    LET vcodret2             = "000";
    LET vcodret3             = "000";
    LET vsqlerr              = 0;
    LET isam_err             = 0;
    LET error_info           = '';
    LET vfechahora           = " ";
    LET vsql                 = '';
    LET vstmt                = '';
    LET vsistema             = "01";
    LET vproceso             = "cierrechqinvcrec";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras       = '';
    LET vexiste              = '';
    LET vexiste2             = 0;
    LET vexistefin           = 0;
    LEt vdias                = 0;
    LET vregproc             = 0;
    LET vporcentajerror      = 0;
    LET vfcuenta             = '';
    LET FechaProc            = '';
    LET vProducto            = '';
    LET vSdoActual           = 0.00;
    LET vSucursal            = '';
    LET vcontvalcie          = 0;
    LET vregistros           = 0;
    LET vcuenta              = '';
    LET vProdChequerasPM     = '';
    LET vdia                 = '';
    LET vfecha_pago          = '';
    LET vnumdias             = 0;
    LET vexiste_cta          = 0;
    LET vhora                = '';
    LET vfolio_suc           = '';
    LET vint_acum            = 0.00;
    LET vfecultdep           = '';
    LET vdiasinact           = 0;
    LET vabierto             = '0';
    LET vaniomes             = '';
    LET vexiste_proy         = 0;
    LET vtotsuc              = 0;
    LET vcontproc            = 0;
    LET vtfechaxxx           = '';
    LET vnum_cte             = '';
    LET vfecha_alta          = '';
    LET vhoraw               = '';
    LET vfecha_mod           = '';
    LET vProdPROAC           = '';
	LET vfecha_operacion     = TODAY;
    LET vcuentaini           = '';
    LET vcuentafin           = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrec.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
            SYSTEM vstmt;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrec.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --- SET PDQPRIORITY 10;
    
    -- // ##################################### //
    -- // #  FECHAS DEL SISTEMA DE CAPTACION  # //
    -- // ##################################### //
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // ###################################### //
    -- // #  TRANSACCION DE PAGO DE INTERESES  # //
    -- // ###################################### //
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    -- // ################################# //
    -- // #  TRANSACCION DE COBRO DE ISR  # //
    -- // ################################# //
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";

    -- // ########################################### //
    -- // #  TRANSACCION DE PROVISION DE INTERESES  # //
    -- // ########################################### //
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";

    -- // ############################################## //
    -- // #  TRANSACCION DE DESPROVISION DE INTERESES  * //
    -- // ############################################## //
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";

    -- // ######################################## //
    -- // #  TRANSACCION DE ABONO PARA TRASPASO  # //
    -- // ######################################## //
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";

    -- // ############################################# //
    -- // #  TRANSACCION DE REINVERSION DE INVS CREC  # //
    -- // ############################################# //
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";

    -- // ################################## //
    -- // #  Producto Inversion Creciente  # //
    -- // ################################## //
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";

    -- // ########################### //
    -- // #  Producto de Chequeras  # //
    -- // ########################### //
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // ####################################### //
    -- // #  Producto de Chequeras Empresarial  # //
    -- // ####################################### //
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // ######################################## //
    -- // #  Producto Programa Ahorre su Cambio  # //
    -- // ######################################## //
    SELECT valor
      INTO vProdPROAC
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PROACPRODUCTO";   
    
    -- // ############################################################## //
    -- // #  VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL  # //
    -- // ############################################################## //
    SELECT count(*)
      INTO vexiste2
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vgfecha_hoy
       AND sistema = vsistema;

    IF vexiste2 = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vgfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vgusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierrecrec.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vgfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec.sql';
            SYSTEM vsql; 
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = 'cierreinvcrec'
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF            
        END IF
    END IF;

    -- // ############################################################### //
    -- // #  VALIDA SE HAYA REALIZADO EL RESPALDO DE TABLAS DE CHEQUES  # //
    -- // ############################################################### //
    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "respacie"
       AND fecha = vgfecha_hoy;

    IF vexiste is null THEN
        LET vcodret = "965";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
        SYSTEM vstmt;
        RETURN vcodret;
    END IF
    
    -- // ########################################################### //
    -- // # VALIDA SE HAYA EFECTUADO EL PASE CONTABLE EN SUCURSALES # //
    -- // ########################################################### //
    SELECT count(*) 
      INTO vtotsuc
      FROM bdinteg:si_sucursales su
     WHERE empresa = pempresa
       AND tpo_sucursal = "01"
       AND not exists (SELECT fecha 
                         FROM bdinteg:si_feriadsuc fs
                        WHERE fs.empresa = pempresa
                          AND fecha = vgfecha_hoy
                          AND su.sucursal = fs.sucursal);
    
    SELECT count(*)
      INTO vcontproc
      FROM bdisuc:ss_contproc
     WHERE fecha = vgfecha_hoy
       AND proceso = "pase";
    
    -- // ######################################################### //
    -- // #  GUARDA HISTORIAL DE VALCIERRE E INICIALIZA LA TABLA  # //
    -- // ######################################################### //
    SELECT count(*)
      INTO vcontvalcie
      FROM sc_valcierre
     WHERE empresa = pempresa
       AND cuenta <> '';

    IF vcontvalcie <> 0 THEN
        INSERT INTO sc_valcierre_his
        SELECT a.*, b.fecha_ant
          FROM sc_valcierre a,
               sc_fechas b
         WHERE a.empresa = pempresa
           AND a.cuenta <> ''
           AND b.empresa = a.empresa;

        DELETE FROM sc_valcierre
         WHERE empresa = pempresa
           AND cuenta <> '';
    END IF

    -- // ####################################### //
    -- // #  OBTIENE NUMERO DE DIAS A PROCESAR  # //
    -- // ####################################### //
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF

    -- // ############################################ //
    -- // #  OBTIENE NUMERO DE REGISTROS A PROCESAR  # //
    -- // ############################################ //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto = vgProdCreciente
       AND status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);

    -- // ########################################################### //
    -- // #  Obtiene parametro de porcentajes de error por proceso  # //
    -- // ########################################################### //
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vcuentaini, vcuentafin
      FROM sc_maechq
     WHERE producto = '1100'
       AND cuenta LIKE '11%';
    
    -- // ################################################################################################### //
    -- // #  FOREACH INVERSIONES CRECIENTES CON INSTRUCCIONES DE TRASPASOS CON MAS DE 2 AÑOS DE ANTIGUEDAD  # //
    -- // ################################################################################################### //
    FOREACH WITH HOLD 
        SELECT mae.cuenta, mae.num_cte, mae.fecultdep, noc.fecha_alta, noc.fecha_mod, ins.cuentadep
          INTO vfcuenta, vnum_cte, vfecultdep, vfecha_alta, vgfecha_mod, vgcuentadep
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE mae.producto = vgProdCreciente
           AND mae.status_cta <> '2'
           AND ( mae.fecha_proceso is null OR mae.fecha_proceso = "" OR mae.fecha_proceso = vgfecha_hoy )
           AND mae.cuenta >= vcuentaini
           AND mae.cuenta <= vcuentafin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R'
           
        BEGIN WORK;
        LET vabierto = '1';
        
        IF vfecultdep is null OR vfecultdep = '' THEN
            LET vfecultdep = vfecha_alta;
        END IF;
        
        LET vdiasinact = vgfecha_hoy - vfecultdep;
        
        IF vdiasinact >= 1060 THEN  
            LET vfecha_mod = vgfecha_mod;
            LET vfecha_mod = vfecha_mod - 1 UNITS DAY;
                    
            EXECUTE PROCEDURE "informix".sp_valfechabil(vfecha_mod, '-') 
            INTO vcodret, vfecha_mod;
            
            IF (vfecha_mod = vgfecha_hoy) THEN            
                SELECT COUNT(*)
                  INTO vexiste_cta
                  FROM sc_maechq
                 WHERE cuenta = vgcuentadep
                   AND status_cta IN('1','4','5')
                   AND ( fecha_proceso is null OR fecha_proceso = "" OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy );
                
                IF vexiste_cta = 0 THEN
                    SELECT LIMIT 1 cuenta
                      INTO vgcuentadep
                      FROM sc_maechq
                     WHERE status_cta IN('1','4','5')
                       AND ( fecha_proceso is null OR fecha_proceso = "" OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy )
                       AND producto NOT IN(vgProdCreciente, vProdPROAC)
                       AND num_cte = vnum_cte;
                END IF;
                
                IF vgcuentadep is not null AND vgcuentadep <> '' THEN
                    UPDATE sc_maeinstrucc
                       SET instrucc = '02',
                           cuentadep = vgcuentadep
                     WHERE empresa = pempresa
                       AND cuenta = vfcuenta; 
                END IF;
            END IF;
        END IF;
        
        COMMIT WORK;
        LET vabierto = '0';
        
        LET vfcuenta    = '';
        LET vnum_cte    = '';
        LET vfecultdep  = '';
        LET vfecha_alta = '';
        LET vgfecha_mod = '';
        LET vdiasinact  = 0;
        LET vfecha_mod  = '';
        LET vgcuentadep = '';
        LET vexiste_cta = 0;
    END FOREACH;  
    
    -- // ####################################### //
    -- // # ACTUALIZA BANDERA PARA COMPLEMENTOS # //
    -- // ####################################### //
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierreinvcrec';
    
    -- // ######################################################################################################## //
    -- // #  FOREACH PRINCIPAL DEL CIERRE DE CAPTACION DE INVERSIONES CRECIENTES CON INSTRUCCIONES DE TRASPASOS  # //
    -- // ######################################################################################################## //
    FOREACH principal WITH HOLD FOR
        SELECT mae.cuenta, mae.fecha_proceso, mae.producto, mae.sdo_actual, mae.status_cta, mae.sucursal,
               ins.instrucc, ins.cuentadep, nvl(noc.fecha_mod, vgfecha_hoy), nvl(noc.fecha_alta, vgfecha_hoy)
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal,
               vginstrucc, vgcuentadep, vgfecha_mod, vgfecha_alta
          FROM sc_maechq mae,
               sc_maeinstrucc ins,
               sc_maenoc noc
         WHERE mae.producto = vgProdCreciente
           AND mae.status_cta <> '2'
           AND ( mae.fecha_proceso is null OR mae.fecha_proceso = "" OR mae.fecha_proceso = vgfecha_hoy )
           AND mae.cuenta >= vcuentaini
           AND mae.cuenta <= vcuentafin
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R'
           AND ins.instrucc IN('02','03','04')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           
        IF FechaProc IS NULL THEN
            IF vSdoActual = 0 THEN
                UPDATE sc_maechq
                   SET status_cta = "2",
                       fecha_proceso = vgfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = vfcuenta;

                LET vcodret = "000";
                CONTINUE FOREACH;
            ELSE
                CALL creciente_proy_cierre(pempresa, vfcuenta, vProducto, vSdoActual, vginstrucc)
                RETURNING vcodret;

                IF vcodret <> "000" THEN
                    CONTINUE FOREACH;
                END IF
            END IF
        END IF

        -- // Actualiza la fecha como ya procesado si vencio su plazo
        IF vgfecha_mod < vgfecha_hoy THEN
            UPDATE sc_maechq
               SET fecha_proceso = vgprox_fecha
             WHERE empresa = pempresa
               AND cuenta = vfcuenta;

            CONTINUE FOREACH;
        END IF
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            -- // Conteo de Errores generados por el cierre
            SELECT COUNT(*)
              INTO vcontvalcie
              FROM sc_valcierre
             WHERE empresa = pempresa
               AND cuenta <> '';

            LET vregistros = ROUND(vregproc * vporcentajerror / 100);

            IF vcontvalcie <= vregistros THEN
                CONTINUE FOREACH;
            ELSE
                LET vcodret = "997";
                LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                           'SET ejecutivo = '''||vgusuario||''','||
                           'status_proc   = '''||'C'||''','||
                           'codret        = '''||vcodret||''','||
                           'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                           'WHERE empresa = '''||pempresa||''' '||
                           'AND proceso   = '''||vproceso||''' '||
                           'AND fecha     = '''||vgfecha_hoy||''' '||
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
                SYSTEM vstmt;
                RETURN vcodret;
            END IF;
        END IF;

        LET vfcuenta     = '';
        LET FechaProc    = '';
        LET vProducto    = '';
        LET vSdoActual   = 0.00;
        LET vgstatus_cta = ' ';
        LET vSucursal    = '';
        LET vgfecha_mod  = ' ';
        LET vgfecha_alta = ' ';
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
        LET vginstrucc   = '';
        LET vgcuentadep  = '';
    END FOREACH;
    
    /* ######################################################################################################################################
    -- // #  Actualiza Cuentas Crecientes Canceladas en el Dia  # //
    FOREACH
        SELECT a.cuenta, b.fecha_alta
          INTO vfcuenta, FechaProc
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = "2"
           AND a.producto = vgProdCreciente
           AND (a.fecha_proceso = vgfecha_hoy OR a.fecha_proceso IS NULL)
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta

        IF FechaProc IS NULL THEN
           UPDATE sc_maechq
              SET fecha_proceso = vgfecha_hoy
            WHERE empresa = pempresa
              AND cuenta = vfcuenta;
	    END IF;

        LET vfcuenta   = '';
        LET FechaProc  = '';
    END FOREACH;
    ###################################################################################################################################### */
    
    /* ######################################################################################################################################
    -- // #  Desprovisiona Cuentas Crecientes Canceladas en el Dia  # // 
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vfolio_suc = 'informix'||vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vaniomes = YEAR(vgfecha_hoy)||LPAD(MONTH(vgfecha_hoy),2,'0');
    
    FOREACH
        SELECT a.cuenta, a.sucursal, a.producto, a.status_cta, b.int_acum
          INTO vcuenta, vSucursal, vProducto, vgstatus_cta, vint_acum
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = '2'
           AND a.producto = vgProdCreciente
           AND a.fecha_proceso = vgfecha_hoy
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta
           
        IF vint_acum > 0 THEN
            INSERT INTO sc_movdia VALUES
            ( 0, vfolio_suc, vSucursal, 'informix', vgfecha_hoy, vgfecha_hoy, vhora, vgtranrevprov, vSucursal, vProducto, 
              pempresa, vcuenta, '', 0, vint_acum, vint_acum, 0, 0, 0, '', vgstatus_cta, 0, '0000', ' ', 0, ' ', '', '', vfecha_operacion);
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste_proy
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tasa IN('M','P');
           
        IF vexiste_proy > 0 THEN
            INSERT INTO sc_tasa_var_hist 
            SELECT vaniomes, var.*
              FROM sc_tasa_variable var
             WHERE var.empresa = pempresa
               AND var.cuenta = vcuenta
               AND var.tipo_tasa IN('M','P');
               
            DELETE FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tasa IN('M','P');
        END IF;
	    
        LET vcuenta      = '';
        LET vSucursal    = '';
        LET vProducto    = '';
        LET vgstatus_cta = '';
        LET vint_acum    = 0.00;
        LET vexiste_proy = 0;
    END FOREACH;
    ###################################################################################################################################### */
    
    -- // ############################ //
    -- // #  Registra fin de cierre  # //
    -- // ############################ //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierreinvcrec";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END;

END PROCEDURE

DOCUMENT
'DESCRIPCION:   Cierre Diario del Producto de Inversion Creciente de Captacion ',
'EJECUTADO POR: Control-M',
'AUTOR:         JICS',
'FECHA:         20/Febrero/2013',
'VERSION:       1.00.0000',
'FECHA MODIF:   04/Noviembre/2025',
'VERSION:       1.0.0001',
'Base de Datos: bdicheq';

CREATE PROCEDURE "informix".sp_notif_cub_vent_cons(pNumreg INTEGER, pOp1 VARCHAR(50), pOp2 VARCHAR(50), pOp3 VARCHAR(50))
	RETURNING VARCHAR(5) AS iCodRet,
		      VARCHAR(50) as iMensaje,
		      VARCHAR(4) AS cSucursal,
		      VARCHAR(4) AS cTransacc,
		      VARCHAR(4) AS cTransacc_suc,
		      VARCHAR(20) AS cNumcte,
		      VARCHAR(20) AS cCuenta,
	      	  VARCHAR(16) AS cNum_tarjeta,
		      MONEY(14,2) AS cMonto_tot,
		      VARCHAR(16) AS cFolio_suc,
		      INTEGER AS cEstatus,
		      VARCHAR(50) AS cOp1,
		      VARCHAR(50) AS cOp2,
		      VARCHAR(50) AS cOp3;
	
	DEFINE iCodRet 		   VARCHAR(5);
	DEFINE iMensaje		   VARCHAR(50);
	DEFINE iSqlErr 		   INTEGER;	
	DEFINE cSucursal	   VARCHAR(4);
	DEFINE cTransacc       VARCHAR(4);
	DEFINE cTransacc_suc   VARCHAR(4);
	DEFINE cNumcte         VARCHAR(20);
    DEFINE cCuenta         VARCHAR(20);
    DEFINE cNum_tarjeta    VARCHAR(16);
	DEFINE cMonto_tot	   MONEY(14,2);
	DEFINE cFolio_suc      VARCHAR(16);
	DEFINE cEstatus		   INTEGER;
	DEFINE cNumreg		   INTEGER;
	DEFINE dFecha_Hoy      DATE;
	DEFINE cOp1			   VARCHAR(50);
	DEFINE cOp2			   VARCHAR(50);
	DEFINE cOp3			   VARCHAR(50);
    DEFINE lv_dFec_Hoy_Ini DATETIME YEAR TO SECOND; 
    DEFINE lv_dFec_Hoy_Fin DATETIME YEAR TO SECOND;  
    --
	LET iCodRet           = "00000";
	LET iMensaje          = "";
	LET iSqlErr           = 0;
	LET cSucursal         = '';
	LET cTransacc         = '';
	LET cTransacc_suc     = '';
	LET cNumcte           = '';
	LET cCuenta           = '';
	LET cNum_tarjeta      = '';
	LET cMonto_tot        = '';
	LET cFolio_suc        = '';
	LET cEstatus          = 0;
	LET cNumreg           = 0;
	LET cOp1              = '';
	LET cOp2              = '';
	LET cOp3              = '';
	LET dFecha_Hoy        = MDY('01','01','1900');
    LET lv_dFec_Hoy_Ini   = null;
    LET lv_dFec_Hoy_Fin   = null; 
	/* 'AUTOR:	      Concepcion Alvarez Carrillo',
       'FECHA:	      enero/2016',
       'DESCRIPCION: Se consulta los limites de deposito de la transaccion 204 y 209',
       'VERSION:     1.0',
       'BD: BDICHEQ';	
        No. ticket:          2198250
        Motivo modificaciÃ³n: Optimizar el SPL 
        â¢	Cambiar char por Varchar
        â¢	Uso del exists debido a que solo se valida que exista el registro
        â¢	Se eliminan variables que no aportan valor o que pueden ser reemplazadas por expresiones directas.
        ModificaciÃ³n por: Accenture
        Fecha: Julio/2025
               Oct/2025: Por observacion del Owner(Ivan LÃ³pez Escorza) se obtendran registros solo del dÃ­a fecha_insert = lv_dFecha_Hoy, se quita > */	


BEGIN
	ON EXCEPTION SET iSqlErr
       --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_notif_cub_vent_cons.out';
       --TRACE ON; 
	   IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD";
			
			RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3;
		END IF;
	 END EXCEPTION;	
	 
      -- Bloque de inicializaciÃ³n
     SET ISOLATION TO DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
	 --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_notif_cub_vent_cons.out';
     --TRACE ON; 

      LET iCodRet = '00000';

      IF (pNumreg IS NULL OR pNumreg = 0) THEN
			LET iMensaje = 'Parametro de Entrada Invalido';	
			LET iCodRet = '00001';
	  ELSE 
			LET cNumreg = pNumreg;
	  END IF;
		
	  IF iCodRet = '00000' THEN 
			
			IF EXISTS(SELECT 1
	                    FROM sc_notif_cub_vent
				       WHERE estatus = 0 ) THEN
			
				SELECT fecha_hoy 
				INTO dFecha_Hoy
				FROM sc_fechas
				WHERE empresa = '001';

                -- Inicio del dÃ­a: 00:00:00
                LET lv_dFec_Hoy_Ini = EXTEND(dFecha_Hoy, YEAR to SECOND) + 00 UNITS HOUR + 00 UNITS MINUTE + 00 UNITS SECOND;

                -- Fin del dÃ­a: 23:59:59
                LET lv_dFec_Hoy_Fin = EXTEND(dFecha_Hoy, YEAR TO SECOND) + 23 UNITS HOUR + 59 UNITS MINUTE + 59 UNITS SECOND;

				FOREACH curIni FOR
                   SELECT FIRST cNumreg sucursal,transacc,transacc_suc,numcte,cuenta,num_tarjeta,monto_tot,folio_suc,estatus 
				     INTO cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus
				     FROM sc_notif_cub_vent
	                WHERE fecha_insert BETWEEN lv_dFec_Hoy_Ini AND lv_dFec_Hoy_Fin	
				      AND estatus = 0

				   LET cNumcte = TRIM(cNumcte);
					
				   IF (cNumcte = '' OR cNumcte is null OR cNumcte = '000000000') THEN
						SELECT FIRST 1 num_cte
						INTO cNumcte
						FROM sc_maechq 
						WHERE cuenta = cCuenta;
						
						LET cNumcte = NVL(cNumcte,'000000000');
						
					END IF;
					
					LET iMensaje = 'Consulta Exitosa';	
					LET iCodRet = '00000';
					RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3 WITH RESUME;
				END FOREACH;
			ELSE
					LET iMensaje = 'Sin Registros Disponibles';
					LET iCodRet = '11111';
					RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3;
			END IF;
			
	  END IF;
	END;
END PROCEDURE;