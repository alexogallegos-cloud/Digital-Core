CREATE PROCEDURE "informix".cierrechqinvcrec_esp( pempresa CHAR(3), pFecha DATE )
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
    DEFINE vProdPROAC                   CHAR(4);
	DEFINE vfecha_operacion             DATE;
    
    DEFINE vresiduo 		            integer;

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
    LET vproceso             = "cierrechqinvcrec_esp";
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
    LET vProdPROAC           = '';
	LET vfecha_operacion     = TODAY;
    LET vresiduo             = 0;

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrec_esp.err";
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

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrec_esp.out";
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
     
    LET vgfecha_hoy = pFecha;
    LET vgpri_dia_mes = LPAD(MONTH(pFecha),2,'0')||'/01/'||YEAR(pFecha);
    
    IF LPAD(MONTH(pFecha),2,'0') = '01' THEN
        LET vgpri_hab_mes = LPAD(MONTH(pFecha),2,'0')||'/02/'||YEAR(pFecha);
    ELSE
        LET vgpri_hab_mes = LPAD(MONTH(pFecha),2,'0')||'/01/'||YEAR(pFecha);
    END IF;
    
    IF ( LPAD(MONTH(pFecha),2,'0') IN('01','03','05','07','08','10','12') ) THEN
        LET vgult_dia_mes = LPAD(MONTH(pFecha),2,'0')||'/31/'||YEAR(pFecha);
    ELIF ( LPAD(MONTH(pFecha),2,'0') IN('04','06','09','11') ) THEN
        LET vgult_dia_mes = LPAD(MONTH(pFecha),2,'0')||'/30/'||YEAR(pFecha);
    ELIF ( LPAD(MONTH(pFecha),2,'0') = '02' ) THEN
        LET vresiduo = MOD(YEAR(pFecha), 4);
   
        IF vresiduo <> 0 THEN
            LET vgult_dia_mes = LPAD(MONTH(pFecha),2,'0')||'/28/'||YEAR(pFecha);
        ELSE
            LET vgult_dia_mes = LPAD(MONTH(pFecha),2,'0')||'/29/'||YEAR(pFecha);
        END IF;
    END IF;
    
    LET vgult_hab_mes = vgult_dia_mes;
    LET vgprox_fecha = pFecha + 2 UNITS DAY;
    

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
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R'
           AND mae.cuenta IN( SELECT cuenta FROM tmp_invs_crec )
           
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
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R'
           AND ins.instrucc IN('02','03','04')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND mae.cuenta IN( SELECT cuenta FROM tmp_invs_crec )
           
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
    
    
    -- // ######################################################################### //
    -- // #  FOREACH PRINCIPAL DEL CIERRE DE CAPTACION DE INVERSIONES CRECIENTES  # //
    -- // ######################################################################### //
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
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.capint = 'R'
           AND ins.instrucc = '01'
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND mae.cuenta IN( SELECT cuenta FROM tmp_invs_crec )
           
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec1.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
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

CREATE PROCEDURE "informix".sp_calcula_masttro(p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza      SMALLINT;
DEFINE ven_transacc       SMALLINT;
DEFINE v_c_vcontador      INTEGER;
DEFINE vsqlerr            INTEGER;
DEFINE vcodret            CHAR(5);
DEFINE vsql               CHAR(500);
DEFINE v_fecha_arch       CHAR(8);
DEFINE v_fecha_hoy        DATE; 
DEFINE v_cuenta           CHAR(20);
DEFINE v_cuenta_val_mov   CHAR(20);
DEFINE v_dia              INTEGER;
DEFINE v_ult_dia          INTEGER;
DEFINE vpri_mes_ant       DATE;
DEFINE vult_mes_ant       DATE;
DEFINE v_aniomes          CHAR(6);
DEFINE v_aniomes_ant      CHAR(6);
DEFINE v_saldo_fin        money(14,2);
DEFINE v_saldo_inicio     DECIMAL(14,2);
DEFINE v_num_serial       CHAR(20);
DEFINE v_monto_tot        money(14,2);
DEFINE v_fecha_val        DATE;
DEFINE v_fecha_val_set    CHAR(8);
DEFINE v_fecha_fin        DATE;
DEFINE v_fecha_ant        DATE;
DEFINE v_descripcion      CHAR(100);
DEFINE v_transaccion      CHAR(4);
DEFINE v_transa_codigo    CHAR(3);
DEFINE v_naturaleza       CHAR(1);
DEFINE v_tipo_tran        CHAR(2);
DEFINE v_mes_no_procesa   INTEGER;
DEFINE v_valida_tabla     INTEGER;
DEFINE p_masstro          CHAR(20);
DEFINE v_masttro          CHAR(20);
DEFINE v_valida_mov       INTEGER;


	
LET vsqlerr             = 0; 
LET vcodret             = "00000";
LET v_c_vcomienza       = -1;
LET ven_transacc        = 0;
LET v_c_vcontador       = 0;
LET vsql                = '';
LET p_masstro           = 'CTASMASTTRO';

BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/masttro.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/masttro.txt';
	 --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/masttro/masttro.txt';
	 --TRACE ON;
	
	   SET ISOLATION TO DIRTY READ;
	SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY) , fecha_hoy,     to_char (fecha_hoy,'%Y%m'), DATE(fecha_hoy - 1  UNITS DAY), fecha_ant
	  INTO vpri_mes_ant                     , vult_mes_ant                     , v_fecha_hoy,   v_aniomes                 , v_fecha_fin                   , v_fecha_ant
      FROM sc_fechas
     WHERE empresa = p_empresa;
 		
	   LET v_dia            = ((to_char(v_fecha_hoy,'%d'))::INTEGER);
	   LET v_ult_dia        = ((to_char(vult_mes_ant,'%d'))::INTEGER);
       LET v_aniomes_ant    = to_char (vpri_mes_ant,'%Y%m');
	   LET v_mes_no_procesa = MONTH(v_fecha_hoy);
	
	SELECT COUNT(*) 
	  INTO v_valida_tabla
	  FROM sysmaster:systabnames 
     WHERE partnum > 0 
	   AND tabname = 'sc_ctas_masttro_deta';
	   
	   --INICIALIZA LA TABLA 	   
	   IF v_valida_tabla > 0 THEN 
	      DELETE FROM sc_ctas_masttro_deta;
	   END IF 
	
			
	FOREACH WITH HOLD
	
	         SELECT cuenta 
			   INTO v_cuenta
               FROM sc_cuentas_masttro	
			  			  
			    -- Abre la transaccion 
		        IF (v_c_vcomienza = -1) THEN
                   LET v_c_vcomienza = 0;
                   LET ven_transacc = 1;
                   BEGIN WORK;
                END IF;
			
			    IF v_dia = 1 THEN    
			         IF v_ult_dia =  31 THEN 			   
				           SELECT a.capvig30,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes_ant
				              AND b.cuenta  = v_cuenta;
									  							  
	                 ELIF v_ult_dia = 30 THEN 
					         SELECT a.capvig29,     b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
					  		  
	                 ELIF v_ult_dia = 29  THEN 
					         SELECT a.capvig28,    b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
											
	                 ELIF v_ult_dia = 28 THEN 
					         SELECT a.capvig27,     b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
					  
		             END IF;
								
				ELIF v_dia = 2 THEN 
				    IF v_mes_no_procesa = 1 THEN 
					    SELECT a.capvig30,     b.sdo_dia_ant
				          INTO v_saldo_inicio, v_saldo_fin
					      FROM sc_sdodiarioc as a,
                               sc_maechq     as b   
					     WHERE a.cuenta  = b.cuenta 
					       AND a.aniomes = v_aniomes_ant
				           AND b.cuenta  = v_cuenta;
					ELSE 										 
				        IF v_ult_dia =  31 THEN 
					           SELECT a.capvig31,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
												   
				        ELIF v_ult_dia = 30 THEN
					           SELECT a.capvig30,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
							  				
			            ELIF v_ult_dia = 29  THEN 
					           SELECT a.capvig29,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
					    		           							
	                    ELIF v_ult_dia = 28  THEN 
					            SELECT a.capvig28,     b.sdo_dia_ant 
				                  INTO v_saldo_inicio, v_saldo_fin
					              FROM sc_sdodiarioc as a,
                                       sc_maechq     as b   
					             WHERE a.cuenta  = b.cuenta 
					               AND a.aniomes = v_aniomes_ant
				                   AND b.cuenta  = v_cuenta;
					    END IF;
					END IF;
		
			    ELIF v_dia = 3 THEN 
				     SELECT a.capvig1,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				 
				ELIF v_dia = 4 THEN 
				     SELECT a.capvig2,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 5 THEN 
				     SELECT a.capvig3,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			
						
                ELIF v_dia = 6 THEN 
				     SELECT a.capvig4,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF  v_dia = 7 THEN 
				     SELECT a.capvig5,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

			    ELIF v_dia = 8 THEN 
				     SELECT a.capvig6,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
				       FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
				      WHERE a.cuenta  = b.cuenta 
				        AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
	  
			   
			    ELIF v_dia = 9 THEN 
				     SELECT a.capvig7,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				  
				ELIF v_dia = 10 THEN 
				     SELECT a.capvig8,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
				       FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
				      WHERE a.cuenta  = b.cuenta 
				        AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

							  
				ELIF v_dia = 11 THEN 
				     SELECT a.capvig9,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

							  
				ELIF v_dia = 12 THEN 
				     SELECT a.capvig10,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 13 THEN 
				     SELECT a.capvig11,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				ELIF v_dia = 14 THEN 
				    SELECT a.capvig12,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
				      FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
				     WHERE a.cuenta  = b.cuenta 
				       AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 15 THEN 
				    SELECT a.capvig13,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
				      FROM sc_sdodiarioc as a,
                            sc_maechq    as b   
				     WHERE a.cuenta  = b.cuenta 
				       AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 16 THEN 
				    SELECT a.capvig14,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				  
				ELIF v_dia = 17 THEN 
				    SELECT a.capvig15,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 18 THEN 
				    SELECT a.capvig16,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 19 THEN 
				    SELECT a.capvig17,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 20 THEN 
				    SELECT a.capvig18,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 21 THEN 
				    SELECT a.capvig19,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 22 THEN 
				    SELECT a.capvig20,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 23 THEN 
				    SELECT a.capvig21,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
	
				 
				ELIF v_dia = 24 THEN 
				    SELECT a.capvig22,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
					   				   
					   
			    ELIF v_dia = 25 THEN 
				    SELECT a.capvig23,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
			
				ELIF v_dia = 26 THEN
				        IF v_mes_no_procesa = 12 THEN 	
				           SELECT a.capvig23,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes
				              AND b.cuenta  = v_cuenta;
					    ELSE 
			               SELECT a.capvig24,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes
				              AND b.cuenta  = v_cuenta;
					    END IF;
			
			
				ELIF v_dia = 27 THEN 
				    SELECT a.capvig25,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 28 THEN 
				    SELECT a.capvig26,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 29 THEN 
				    SELECT a.capvig27,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 30 THEN 
				    SELECT a.capvig28,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 31 THEN 
				     SELECT a.capvig29,   b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			
				END IF;

				SELECT COUNT(*)
				  INTO v_valida_mov
				  FROM sc_movhis           AS a,
	                   bdinteg:si_transacc AS b 
			     WHERE a.transacc  = b.numero 
	               AND a.empresa   = p_empresa
	               AND a.cuenta    = v_cuenta
                   AND a.fech_alt  = v_fecha_ant
	               AND a.cancelad  <> 'S'
	               AND b.sistema   = '01'
	               AND b.se_emite_edocta = 'S'
	               AND b.se_contabiliza  = 'S'; 
                    
					IF v_valida_mov > 0 THEN 
				
				        FOREACH WITH HOLD
                  
				  	      SELECT a.num_serial, a.monto_tot, a.fech_alt , TRIM(a.referencia) || '/' || TRIM(b.descripcion) AS descripcion, a.transacc    ,b.naturaleza ,b.tipo_tran 
				  	        INTO v_num_serial, v_monto_tot, v_fecha_val, v_descripcion                                                  , v_transaccion ,v_naturaleza ,v_tipo_tran
				  	        FROM           sc_movhis AS a,
				  	             bdinteg:si_transacc AS b 
	                       WHERE a.transacc  = b.numero 
				  	         AND a.empresa   = p_empresa
	                         AND a.cuenta    = v_cuenta
		                     AND a.fech_alt  = v_fecha_ant
				  	         AND a.cancelad  <> 'S'
				  	         AND b.sistema   = '01'
				  	         AND b.se_emite_edocta = 'S'
				  		     AND b.se_contabiliza = 'S'
				  		     ORDER BY num_serial ASC

							 
				  	  	      IF v_transaccion = '3276' OR v_transaccion = '0207' THEN  
				  		         LET v_transa_codigo = 'INT';
				  		   
				  		     ELIF (v_transaccion = '3277' OR v_transaccion = '3278') AND v_tipo_tran = '02' THEN
				  		          LET v_transa_codigo = 'FEE';
				  		
				  		     ELIF v_tipo_tran = '01' OR v_tipo_tran = '05' THEN   
				  		          LET v_transa_codigo = 'COM';
				  		   
				  		     ELIF v_naturaleza = 'A' THEN  
				  		          LET v_transa_codigo = 'DEP';
				  		   
				  		     ELIF v_naturaleza = 'C' THEN 
				  			      LET v_transa_codigo = 'WIT';
				  		   END IF; 
	            
                           INSERT INTO sc_ctas_masttro_deta (Initial_Balance,Final_Balance,Account_Number,Transaction_Number,Transaction_Code,Net_Amount,Trade_Date,Settle_Date,Currency,Description_Comments)
                                VALUES(v_saldo_inicio,v_saldo_fin,v_cuenta,v_num_serial,v_transa_codigo,v_monto_tot,to_char(v_fecha_val,'%d/%m/%Y'),'','MXN',v_descripcion);
  
                        END FOREACH;
					ELSE 
						INSERT INTO sc_ctas_masttro_deta (Initial_Balance, Final_Balance, Account_Number , Transaction_Number, Transaction_Code, Net_Amount ,Trade_Date ,Settle_Date ,Currency ,Description_Comments)
                             VALUES                      (v_saldo_inicio,  v_saldo_fin,   v_cuenta       , ' '               , ' '             , ' '        ,' '        ,' '         ,' '      ,' ');
				    END IF;

			LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 1000 registros 
			IF (v_c_vcontador >= 50) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
    END FOREACH;
   
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	  

	  
    LET v_fecha_arch = to_char (v_fecha_ant,'%d%m%Y');
		
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
		       'UNLOAD TO /resplogifx/conciliachq/originales/masttro_'||v_fecha_arch||'.csv  delimiter ''","''   '||
		       'SELECT * FROM sc_ctas_masttro_deta" > /resplogifx/conciliachq/eje_mas.sql';
		
	SYSTEM vsql;

    --/EJECUCION DEL ARCHIVO .SQL 
    LET vsql = '';LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/eje_mas.sql"; 
    SYSTEM vsql;			
	
	
     /*		
	 --/COMPRIME EL ARCHIVO .SQL 
     LET vsql = '';
     LET vsql = '/usr/bin/gzip -9 /RESPALDOSNEW/Porta_prod_asoc'||v_fecha_arch||'.txt'; 
     SYSTEM vsql;
    */
	--PROCESO PARA CIFRAR LOS ARCHIVOS 
	LET v_masttro = TRIM(p_masstro);
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_cifra_archivo_masttro(v_masttro) 
	INTO  vcodret;

	
						  
RETURN  vcodret;
END; 
END PROCEDURE;