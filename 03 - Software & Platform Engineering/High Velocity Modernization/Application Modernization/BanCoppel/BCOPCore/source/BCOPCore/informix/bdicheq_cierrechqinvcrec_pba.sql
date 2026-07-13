CREATE PROCEDURE "informix".cierrechqinvcrec_pba(pempresa CHAR(3))
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
    ---SET PDQPRIORITY 10;
    
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
    
    -- // ################################################## //
    -- // #  VALIDA HAYA FINALIZADO CIERRE DE INVERSIONES  # // 
    -- // ################################################## //
    SELECT status_proc
      INTO vstatuscierreinv
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'CierreInv'
       AND fecha   = vgfecha_hoy
       AND sistema = '03';
        
    IF vstatuscierreinv is null OR vstatuscierreinv <> 'F' THEN
        LET vcodret = "959";
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
    
    -- // ################################################## //
    -- // #  VALIDA HAYA FINALIZADO COBRO DE REESTRUCTURA  # //
    -- // ################################################## //
    SELECT status_proc
      INTO vstatuscobroreestruc
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'CobroAutRe'
       AND fecha   = vgfecha_hoy
       AND sistema = '06';
    
    IF vstatuscobroreestruc is null OR vstatuscobroreestruc <> 'F' THEN
        LET vcodret = "954";
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

    -- // ######################################################## //
    -- // # REVERSA DESGLOSE DE MOVIMIENTOS CUANDO NO HAY MOVDIA # //
    -- // ######################################################## //
    FOREACH
        SELECT {+INDEX(sc_docret idx_sc_docret4)} cuenta, folio_suc
          INTO vcuenta, vfolio_suc
          FROM sc_docret
         WHERE siglas = "SC"
           AND fecha_alta = vgfecha_hoy
           AND cancelado <> "S"
         GROUP BY 1,2

        LET vexiste2 = 0;

        SELECT count(*)
          INTO vexiste2
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND folio_suc = vfolio_suc
           AND cancelad <> "S";

        IF vexiste2 is null OR vexiste2 = 0 THEN
            -- // Verifica que se haya procesado esta cuenta
            SELECT fecha_proceso
              INTO vtfechaxxx
              FROM sc_maechq
             WHERE empresa = pempresa
               AND cuenta = vcuenta;

            IF vtfechaxxx = vgfecha_hoy THEN
                UPDATE sc_docret
                   SET cancelado = "S"
                 WHERE cuenta = vcuenta
                   AND folio_suc = vfolio_suc
                   AND fecha_alta = vgfecha_hoy;
            END IF
        END IF
        
        LET vcuenta    = '';
        LET vfolio_suc = '';
        LET vtfechaxxx = '';
    END FOREACH;
    
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
       
    -- // ######################################### //
    -- // #  OBTIENE RANGO DE CUENTAS A PROCESAR  # //
    -- // ######################################### //
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCieInvCreComp1'; 
       
    -- // ####################################### //
    -- // # ACTUALIZA BANDERA PARA COMPLEMENTOS # //
    -- // ####################################### //
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierreinvcrec';
       
    /* ##################################################################################################################
    -- // #################################################################################### //
    -- // #  FOREACH INVERSIONES CRECIENTES QUE VENCEN Y TIENEN MAS DE 2 AÑOS DE ANTIGUEDAD  # //
    -- // #################################################################################### //
    FOREACH WITH HOLD 
        SELECT mae.cuenta, mae.num_cte, mae.fecultdep, noc.fecha_alta, noc.fecha_mod
          INTO vfcuenta, vnum_cte, vfecultdep, vfecha_alta, vgfecha_mod
          FROM sc_maechq mae,
               sc_maenoc noc
         WHERE mae.producto = vgProdCreciente
           AND mae.status_cta NOT IN("2","6","7","8")
           AND ( mae.fecha_proceso is null OR mae.fecha_proceso = "" OR mae.fecha_proceso = vgfecha_hoy )
           AND mae.cuenta < vcuentafin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           
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
                -- // Obtiene instrucciones de la inversión creciente
                SELECT LIMIT 1 cuentadep
                  INTO vgcuentadep
                  FROM sc_maeinstrucc
                 WHERE empresa = pempresa
                   AND cuenta = vfcuenta
                   AND capint = "R";   
                
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
                       AND producto <> vgProdCreciente
                       AND num_cte = vnum_cte;
                END IF;
                
                IF vgcuentadep is not null OR vgcuentadep <> '' THEN
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
    ################################################################################################################## */
    
    -- // ################################################################### //
    -- // #  FOREACH INVERSIONES CRECIENTES CON INSTRUCCIONES DE TRASPASOS  # //
    -- // ################################################################### //
    FOREACH WITH HOLD 
        SELECT mae.cuenta, mae.fecha_proceso, mae.producto, mae.sdo_actual, mae.status_cta, mae.sucursal, noc.fecha_alta
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal, vfecha_alta
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE mae.producto = vgProdCreciente
           AND mae.status_cta NOT IN("2","6","7","8")
           AND mae.fecha_proceso = vgfecha_hoy
           AND mae.cuenta < vcuentafin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.instrucc IN('02','03','04')
           AND ins.capint = "R"
           
        LET vdia = DAY(vfecha_alta);
        
        CALL calcula_fechapago(vgfecha_hoy, 0, vdia)
        RETURNING vcodret, vfecha_pago, vnumdias;
        
        IF vdia = 1 THEN
            CALL monthadd(vfecha_pago, 1) 
            RETURNING vfecha_pago;
        ELIF vdia = 2 AND vgfecha_hoy = '12'||'31'||YEAR(vgfecha_hoy) THEN
            CALL monthadd(vfecha_pago, 1)
            RETURNING vfecha_pago;
        ELSE
            LET vfecha_pago = vgfecha_hoy + vnumdias;
        END IF;

        IF NOT(vdia > DAY(vgult_dia_mes) OR vdia < 1) THEN
            LET vfecha_pago = vfecha_pago - 1;
        END IF
        
        IF ( ( vfecha_pago >= vgfecha_hoy AND vfecha_pago < vgprox_fecha ) AND ( vfecha_alta <> vgfecha_hoy ) ) THEN
            -- // Obtiene instrucciones de la inversión creciente
            SELECT instrucc, cuentadep
              INTO vginstrucc, vgcuentadep
              FROM sc_maeinstrucc
             WHERE empresa = pempresa
               AND cuenta = vfcuenta
               AND capint = "R";     
            
            -- // Verifica Fecha de Vencimiento para cuentas crecientes
            SELECT nvl(fecha_mod, vgfecha_hoy), nvl(fecha_alta, vgfecha_hoy)
              INTO vgfecha_mod, vgfecha_alta
              FROM sc_maenoc
             WHERE empresa = pempresa
               AND cuenta = vfcuenta;

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
        LET vfecha_alta  = '';
        LET vdia         = '';
        LET vfecha_pago  = '';
        LET vnumdias     = 0;
    END FOREACH;  
    
    
    -- // ######################################################################### //
    -- // #  FOREACH PRINCIPAL DEL CIERRE DE CAPTACION DE INVERSIONES CRECIENTES  # //
    -- // ######################################################################### //
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = vgProdCreciente
           AND status_cta not in( "2", "6", "7", "8" )
           AND ( fecha_proceso is null OR fecha_proceso = "" OR fecha_proceso = vgfecha_hoy )
           AND cuenta < vcuentafin
           
        -- // Obtiene instrucciones de la inversión creciente
        SELECT instrucc, cuentadep
          INTO vginstrucc, vgcuentadep
          FROM sc_maeinstrucc
         WHERE empresa = pempresa
           AND cuenta = vfcuenta
           AND capint = "R";

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

        -- // Verifica Fecha de Vencimiento para cuentas crecientes
        SELECT nvl(fecha_mod, vgfecha_hoy), nvl(fecha_alta, vgfecha_hoy)
          INTO vgfecha_mod, vgfecha_alta
          FROM sc_maenoc
         WHERE empresa = pempresa
           AND cuenta = vfcuenta;

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
    
    
    -- // ####################################################### //
    -- // #  Actualiza Cuentas Crecientes Canceladas en el Dia  # //
    -- // ####################################################### //
    FOREACH
        SELECT a.cuenta, b.fecha_alta
          INTO vfcuenta, FechaProc
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = "2"
           AND a.producto = vgProdCreciente
           AND (a.fecha_proceso = vgfecha_hoy OR a.fecha_proceso IS NULL)
           ---AND b.empresa = a.empresa
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
    
    
    -- // ########################################################### //
    -- // #  Desprovisiona Cuentas Crecientes Canceladas en el Dia  # //
    -- // ########################################################### //   
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vfolio_suc = 'informix'||vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vaniomes = YEAR(vgfecha_hoy)||LPAD(MONTH(vgfecha_hoy),2,'0');
    
    FOREACH
        SELECT {+INDEX(sc_maenoc noc1)} a.cuenta, a.sucursal, a.producto, a.status_cta, b.int_acum
          INTO vcuenta, vSucursal, vProducto, vgstatus_cta, vint_acum
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = '2'
           AND a.producto = vgProdCreciente
           AND a.fecha_proceso = vgfecha_hoy
           ---AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta
           
        IF vint_acum > 0 THEN
            INSERT INTO sc_movdia VALUES
            ( 0, vfolio_suc, vSucursal, 'informix', vgfecha_hoy, vgfecha_hoy, vhora, vgtranrevprov, vSucursal, vProducto, 
              pempresa, vcuenta, '', 0, vint_acum, vint_acum, 0, 0, 0, '', vgstatus_cta, 0, '0000', ' ', 0, ' ', '' );
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
'Base de Datos: bdicheq';

CREATE PROCEDURE "informix".actchequessbc( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
	DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
	DEFINE vcontador3   INTEGER;
    DEFINE vmonto       MONEY(14,2);
    DEFINE vreferencia  CHAR(40);
    DEFINE vdocto       INTEGER;
    DEFINE vcuenta      CHAR(20);
    DEFINE vfecha_alta  DATE;
    DEFINE vcvebconew   CHAR(3);
    DEFINE vrefnew      CHAR(20);
    DEFINE vcvebanco    CHAR(3);
    DEFINE vnumcuenta   CHAR(20);
    DEFINE vdctabco     DECIMAL(20,0);
    DEFINE vcctabco     CHAR(20);
    
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
	LET vcodret1   = '';
    LET vcodret2   = '';
    LET vcodret3   = '';
    LET vabierto   = '0';
    LET vcomienza  = -1;
    LET vcontador1 = 0;
    LET vcontador2 = 0;
	LET vcontador3 = 0;
    LET vmonto       = 0.00;
    LET vreferencia  = '';
    LET vdocto       = 0;
    LET vcuenta      = '';
    LET vfecha_alta  = '';
    LET vcvebconew   = '';
    LET vrefnew      = '';
    LET vcvebanco    = '';
    LET vnumcuenta   = '';
    LET vdctabco = 0;
    LET vcctabco = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/actchequessbc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/actchequessbc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE EL NUMERO TOTAL DE REGISTROS A DEPURAR
    SELECT COUNT(empresa)
      INTO vcontador1
      FROM sc_docret_sbc 
     WHERE siglas IN('SC','SD')  
       AND transacc IN('0250','6250')
       AND cancelado <> "T"
       AND NVL(banco,"") = ""
       AND NVL(numcuenta,"") = "";
    
    -- // DEPURA REGISTROS DE LA sc_docret_sbc
    FOREACH WITH HOLD 
        SELECT monto_ori, referencia, num_chq, cuenta, fecha_alta
          INTO vmonto, vreferencia, vdocto, vcuenta, vfecha_alta
          FROM sc_docret_sbc 
         WHERE siglas IN('SC','SD')  
           AND transacc IN('0250','6250')
           AND cancelado <> "T"
		   AND NVL(banco,"") = ""
           AND NVL(numcuenta,"") = ""
           
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
        
        LET vcvebconew = vreferencia[1,3]; 
        LET vcvebconew = vcvebconew;
        
        LET vrefnew = vreferencia[6,25]; 
        LET vdctabco = vrefnew::decimal(20,0);
        let vcctabco = vdctabco;
        let vcctabco = trim(vcctabco);
        
        /*
        SELECT cvebanco, numcuenta
          INTO vcvebanco, vnumcuenta
          FROM bditef:cce_cheques_det
         WHERE fecha_alta = '10/11/2012'
           AND cvebanco = vcvebconew
           AND lpad(trim(numcuenta),20,"0") = vrefnew
           AND numcheque = vdocto
           AND monto = vmonto;
        */
           
        UPDATE sc_docret_sbc
           SET banco = vcvebconew,
               numcuenta = vcctabco
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fecha_alta = vfecha_alta
           AND referencia = vreferencia
           AND num_chq = vdocto
           AND monto_ori = vmonto;
        
        LET vcontador2 = vcontador2 + 1;

		LET vcontador3 = vcontador3 + 1;
        
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
        
        LET vmonto       = 0.00;
        LET vreferencia  = '';
        LET vdocto       = 0;
        LET vcuenta      = '';
        LET vfecha_alta  = '';
        LET vcvebconew   = '';
        LET vrefnew      = '';
        LET vcvebanco    = '';
        LET vnumcuenta   = '';
        LET vdctabco = 0;
        LET vcctabco = '';
    END FOREACH;
    
	IF vabierto = '1' THEN
		COMMIT WORK;
	END IF
	
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;