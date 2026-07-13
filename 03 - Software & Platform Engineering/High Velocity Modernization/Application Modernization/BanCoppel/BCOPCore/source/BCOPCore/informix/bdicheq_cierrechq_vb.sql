CREATE PROCEDURE "informix".cierrechq_vb(pempresa CHAR(3))
RETURNING CHAR(5); 
 
    --- ############################################################################
    --- ##  Nombre:              cierrechq_vb                                     ##
    --- ##  Version:             1.0.1                                            ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion  ##
    --- ##  Creado por:                                                           ##
    --- ##  ModIFicado por:      JICS                                             ##
    --- ##  Ultima Modificacion: Marzo 2011                                       ##
    --- ############################################################################

    DEFINE GLOBAL vgusuario             CHAR(8)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE            DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod           DATE            DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta          DATE            DEFAULT " ";
    DEFINE GLOBAL vginstrucc            CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep           CHAR(20)        DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vcomienza                    SMALLINT;
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
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vtotsuc                      INTEGER;
    DEFINE vcontproc                    INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
    DEFINE vtfechaxxx                   DATE;
    DEFINE vsdo_cuenta                  MONEY(18,2);
    DEFINE vmto_pag_int                 MONEY(14,2);
    DEFINE vdias                        INTEGER;
    DEFINE vcontprocie                  CHAR(1);
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vregistros                   INTEGER;
    DEFINE vfecha_alta                  DATE;
    DEFINE vpago_interes                CHAR(1);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vProdChequerasPM             CHAR(4);
    DEFINE vcodretparam                 CHAR(5);
    
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
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vcomienza  = -1;
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechq";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vtotsuc         = 0;
    LET vcontproc       = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
    LET vtfechaxxx      = '';
    LET vsdo_cuenta     = 0.00;
    LET vmto_pag_int    = 0.00;
    LET vdias           = 0;
    LET vcontprocie     = '';
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentafin      = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vregistros      = 0;
    LET vfecha_alta     = '';
    LET vpago_interes   = '';
    LET vdia            = '';
    LET vfecha_pago     = '';
    LET vnumdias        = 0;
    LET vProdChequerasPM = '';
    LET vcodretparam    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_vb.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;

            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_vb.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 20; HMD-INCIDENCIA-20220224
    
    -- // FECHAS DEL SISTEMA DE CAPTACION
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // TRANSACCION DE PAGO DE INTERESES
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    -- // TRANSACCION DE COBRO DE ISR
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";

    -- // TRANSACCION DE PROVISION DE INTERESES
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";

    -- // TRANSACCION DE DESPROVISION DE INTERESES
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";

    -- // TRANSACCION DE ABONO PARA TRASPASO
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";

    -- // TRANSACCION DE REINVERSION DE INVS CREC
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // Producto Inversion Creciente
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // Producto de Chequeras
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // Producto de Chequeras Empresarial
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horascierre.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret = "966";

            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'F'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        END IF
    END IF;
    
    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "cierre"
       AND fecha = vgfecha_hoy;

    IF vexiste = "1" THEN
        LET vcodret = "966";
        RETURN vcodret;
    END IF
       
    -- // VALIDA HAYA FINALIZADO CIERRE DE INVERSIONES
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;
           
        RETURN vcodret;
    END IF
    
    -- // VALIDA HAYA FINALIZADO COBRO DE REESTRUCTURA
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;
           
        RETURN vcodret;
    END IF

    -- // VALIDA SE HAYA REALIZADO EL RESPALDO DE TABLAS DE CHEQUES
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;

        RETURN vcodret;
    END IF
    
    -- // GUARDA HISTORIAL DE VALCIERRE E INICIALIZA LA TABLA
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

    -- // VALIDA SE HAYA EFECTUADO EL PASE CONTABLE EN SUCURSALES
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

    SET LOCK MODE TO WAIT 2;

    -- // REVERSA DESGLOSE DE MOVIMIENTOS CUANDO NO HAY MOVDIA
    FOREACH
        SELECT cuenta, folio_suc
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

    -- // Verfica cuentas con status 4 (Inactivas)
    FOREACH
        SELECT mae.cuenta, mae.sdo_actual, pro.mto_pag_int, mae.producto
          INTO vcuenta, vsdo_cuenta, vmto_pag_int, vproducto
          FROM sc_maechq mae,
               sc_producto pro
         WHERE mae.empresa = pempresa
           AND mae.status_cta = '4'
           AND mae.sdo_actual >= pro.mto_pag_int
           AND mae.fecha_proceso < vgfecha_hoy
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto

        IF vproducto = vProdChequeras OR vproducto = vProdChequerasPM THEN
            CONTINUE FOREACH;
        END IF;

        IF vsdo_cuenta >= vmto_pag_int THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vgfecha_hoy
             WHERE empresa = pempresa
               AND cuenta = vcuenta;

            UPDATE sc_maenoc
               SET dia_sdo_pos = 0,
                   acum_sdo_pos = 0.00,
                   int_acum = 0.00,
                   dias_acum_int = 0,
                   acum_sdo_int = 0.00
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        LET vcuenta      = '';
        LET vsdo_cuenta  = 0.00;
        LET vmto_pag_int = 0.00;
        LET vproducto    = '';
    END FOREACH;
    
    -- // VERIFICA MESIVERSARIO CUENTAS STATUS 4 (INACTIVAS)
    TRUNCATE TABLE sc_ctasinact_cobro_comision;
    
    FOREACH
        SELECT mae.cuenta, mae.producto, noc.fecha_alta, pro.pago_interes
          INTO vcuenta, vproducto, vfecha_alta, vpago_interes
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_producto pro,
               sc_productos_inactivos prod
         WHERE mae.empresa = pempresa
           AND mae.status_cta = '4'
           AND mae.sdo_actual > 0.00
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto
           AND prod.producto = mae.producto

        IF vproducto = vProdChequeras OR vproducto = vProdChequerasPM THEN
            CONTINUE FOREACH;
        END IF;

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
        
        IF ( vpago_interes = "M" AND vgfecha_hoy = vgult_hab_mes ) OR 
           ((vpago_interes = "V" AND vfecha_pago >= vgfecha_hoy AND vfecha_pago < vgprox_fecha) AND (vfecha_alta <> vgfecha_hoy)) THEN
            INSERT INTO sc_ctasinact_cobro_comision VALUES(vcuenta);
        END IF;
        
        LET vcuenta = '';
        LET vproducto = '';
        LET vfecha_alta = '';
        LET vpago_interes = '';
        LET vdia = '';
        LET vcodret = '';
        LET vfecha_pago = '';
        LET vnumdias = 0;
    END FOREACH;

    -- // OBTIENE NUMERO DE DIAS A PROCESAR
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF

    SELECT control
      INTO vcontprocie
      FROM sc_folsuc
     WHERE empresa = pempresa
       AND control = "2";

    IF vcontprocie is null THEN
        INSERT INTO sc_folsuc values(pempresa,"2","1");
        LET vcontprocie = "1";
    END IF

    IF vcontprocie = "1" THEN
        UPDATE sc_folsuc
           SET control = "2"
         WHERE empresa = pempresa;
    END IF

    -- // OBTIENE NUMERO DE REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);

    -- // Obtiene parametro de porcentajes de error por proceso
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";

    -- // FOREACH INVERSIONES CRECIENTES CON INSTRUCCIONES DE TRASPASOS
    FOREACH WITH HOLD 
        SELECT mae.cuenta, mae.fecha_proceso, mae.producto, mae.sdo_actual, mae.status_cta, mae.sucursal, noc.fecha_alta
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal, vfecha_alta
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_maeinstrucc ins
         WHERE mae.producto = '1100'
           AND mae.status_cta NOT IN("2","6","7","8")
           AND mae.fecha_proceso = vgfecha_hoy
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.instrucc IN('02','03','04')
           
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
               AND cuenta = vfcuenta;     
            
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
                               'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
                    SYSTEM vsql;
                    
                    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
        LET vcodret      = '';
        LET vfecha_pago  = '';
        LET vnumdias     = 0;
    END FOREACH;   
    
    -- // ACTUALIZA PARAMETRO DE INICIO DE CIERRE
    EXECUTE PROCEDURE "informix".sp_actparamcierre_vb(pempresa)
    INTO vcodretparam;
    
    IF vcodretparam <> '000' THEN
        LET vcodret = "976";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;
        RETURN vcodret;
    END IF;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierre';
    
    -- // FOREACH PRINCIPAL DEL CIERRE DE CAPTACION
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaEjeCierreCheques'; 
       
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = '2000'
           AND cuenta < vcuentafin
           AND status_cta not in("2","6","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF;
        
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
                SYSTEM vsql;
                
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
    END FOREACH;
    
    -- // Actualiza Cuentas Crecientes Canceladas en el Dia
    FOREACH
        SELECT a.cuenta, a.sdo_actual, b.fecha_alta
          INTO vfcuenta, vSdoActual, FechaProc
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
        LET vSdoActual = 0.00;
        LET FechaProc  = '';
    END FOREACH

    -- // Actualiza saldo de cuentas inactivas
    FOREACH
        SELECT cuenta, producto
          INTO vcuenta, vproducto
          FROM sc_maechq
         WHERE status_cta = '4'
           AND fecha_proceso < vgfecha_hoy

        IF vproducto = vProdChequeras OR vproducto = vProdChequerasPM THEN
            CONTINUE FOREACH;
        END IF;

        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;

        LET vcuenta   = '';
        LET vproducto = '';
    END FOREACH
    
    FOREACH
        SELECT cuenta, producto
          INTO vcuenta, vproducto
          FROM sc_maechq
         WHERE status_cta = '8'

        IF vproducto = vProdChequeras OR vproducto = vProdChequerasPM THEN
            CONTINUE FOREACH;
        END IF;

        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;

        LET vcuenta   = '';
        LET vproducto = '';
    END FOREACH

    -- // Registra fin de cierre
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre";
       
    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa inicial del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: Antonio Ruiz Mtz.',
'MODIF: JICS',
'FECHA: 10/Marzo/2011',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqcomp1_vb(pempresa CHAR(3))
RETURNING CHAR(5); 
 
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp1_vb                                     ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Marzo 2011                                           ##
    --- ################################################################################

    DEFINE GLOBAL vgusuario         CHAR(8)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy       DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes     DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes     DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes     DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes     DATE        DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha      DATE        DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int   CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtransisr        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranprov        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov     CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp    CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece     CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente   CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta      CHAR(1)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod       DATE        DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta      DATE        DEFAULT " ";
    
    DEFINE vcodret                  CHAR(5);
    DEFINE vcodret2                 CHAR(5);
    DEFINE vcodret3                 CHAR(40);
    DEFINE vsqlerr                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE error_info               CHAR(40);
    DEFINE vfechahora               CHAR(40);
    DEFINE vsql                     CHAR(600);
    DEFINE vstmt                    CHAR(250);
    DEFINE vsistema                 CHAR(2);
    DEFINE vproceso                 CHAR(20);
    DEFINE vstatuscierreinv         CHAR(1);
    DEFINE vstatuscobroreestruc     CHAR(1);
    DEFINE vProdChequeras           CHAR(4);
    DEFINE vexiste                  CHAR(1);
    DEFINE vexiste2                 INTEGER;
    DEFINE vexistefin               INTEGER;
    DEFINE vinicio_cierre           DATE;
    DEFINE vdias                    INTEGER;
    DEFINE vregproc                 INTEGER;
    DEFINE vporcentajerror          INTEGER;
    DEFINE vcuentaini               CHAR(20);
    DEFINE vcuentafin              CHAR(20);
    DEFINE vfcuenta                 CHAR(20);
    DEFINE FechaProc                DATE;
    DEFINE vProducto                CHAR(4);
    DEFINE vSdoActual               DECIMAL(14,2);
    DEFINE vSucursal                CHAR(4);
    DEFINE vcontvalcie              INTEGER;
    DEFINE vregistros               INTEGER;
    
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
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechqcomp1";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = '';
    LEt vdias           = 0;
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentaini      = '';
    LET vcuentafin     = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vcontvalcie     = 0;
    LET vregistros      = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp1_vb.err";
        TRACE ON;
        
        IF vsqlerr <> 0 THEN
            LET vcodret  = vsqlerr;
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;

            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp1_vb.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 20; HMD-INCIDENCIA-20220224
    
    -- // FECHAS DEL SISTEMA DE CAPTACION
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // TRANSACCION DE PAGO DE INTERESES
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    -- // TRANSACCION DE COBRO DE ISR
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";

    -- // TRANSACCION DE PROVISION DE INTERESES
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";

    -- // TRANSACCION DE DESPROVISION DE INTERESES
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";

    -- // TRANSACCION DE ABONO PARA TRASPASO
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
       
    -- // TRANSACCION DE REINVERSION DE INVS CREC
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // Producto Inversion Creciente
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // Producto de Chequeras
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horascierre.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret = "966";

            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'F'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        END IF
    END IF;

    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "cierrecomp1"
       AND fecha = vgfecha_hoy;

    IF vexiste = "1" THEN
        LET vcodret = "966";
        RETURN vcodret;
    END IF
    
    -- // VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS
    SELECT fecha
      INTO vinicio_cierre
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierre';
       
    IF vinicio_cierre <> vgfecha_hoy OR vinicio_cierre is null THEN
        LET vcodret = "972";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;
        RETURN vcodret;
    END IF;
    
    -- // OBTIENE NUMERO DE DIAS A PROCESAR
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // OBTIENE NUMERO DE REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);

    -- // Obtiene parametro de porcentajes de error por proceso
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";

    -- // FOREACH PRINCIPAL DEL CIERRE DE CAPTACION
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaEjeCierreCheques'; 

    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = '2000'
           AND cuenta >= vcuentaini
           AND status_cta not in("2","6","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)
        
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
                SYSTEM vsql;
                
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
    END FOREACH;

    -- // Registra fin de cierre
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp1";
       
    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 10/Marzo/2011',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqcomp2_vb(pempresa CHAR(3))
RETURNING CHAR(5); 
 
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp2_vb                                       ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Marzo 2011                                           ##
    --- ################################################################################

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
    DEFINE vinicio_cierre               DATE;
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

    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechqcomp2";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = '';
    LEt vdias           = 0;
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vcontvalcie     = 0;
    LET vregistros      = 0;
    LET vcuenta         = '';
    LET vProdChequerasPM = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp2_vb.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp2_vb.out";
    ---	TRACE ON;

    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 20; HMD-INCIDENCIA-20220224

    -- // FECHAS DEL SISTEMA DE CAPTACION
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // TRANSACCION DE PAGO DE INTERESES
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    -- // TRANSACCION DE COBRO DE ISR
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";

    -- // TRANSACCION DE PROVISION DE INTERESES
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";

    -- // TRANSACCION DE DESPROVISION DE INTERESES
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";

    -- // TRANSACCION DE ABONO PARA TRASPASO
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";

    -- // TRANSACCION DE REINVERSION DE INVS CREC
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";

    -- // Producto Inversion Creciente
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";

    -- // Producto de Chequeras
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // Producto de Chequeras Empresarial
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   

    -- // VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horascierre.sql';
        SYSTEM vsql;

        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;

            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret = "966";

            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'F'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;

            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        END IF
    END IF;

    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "cierrecomp2"
       AND fecha = vgfecha_hoy;

    IF vexiste = "1" THEN
        LET vcodret = "966";
        RETURN vcodret;
    END IF

    -- // VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS
    SELECT fecha
      INTO vinicio_cierre
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierre';

    IF vinicio_cierre <> vgfecha_hoy OR vinicio_cierre is null THEN
        LET vcodret = "972";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;
        RETURN vcodret;
    END IF;

    -- // OBTIENE NUMERO DE DIAS A PROCESAR
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF

    -- // OBTIENE NUMERO DE REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);

    -- // Obtiene parametro de porcentajes de error por proceso
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";

    -- // FOREACH PRINCIPAL DEL CIERRE DE CAPTACION
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto <> '2000'
           AND status_cta not in("2","6","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        -- // Omite procesar las cuentas de chequeras - Gpo PISA Mayo 2010
        IF vproducto = vProdChequeras OR vproducto = vProdChequerasPM THEN
            CONTINUE FOREACH;
        END IF;

        IF vproducto = vgProdCreciente THEN
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
                SYSTEM vsql;

                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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

    -- // Registra fin de cierre
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp2";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 10/Marzo/2011',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqinvcreccomp1_pba(pempresa CHAR(3))
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
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vinicio_cierre               SMALLINT;

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
    LET vproceso             = "cierrechqinvcrecomp1";
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
    LET vcuentaini           = '';
    LET vcuentafin           = '';
    LET vinicio_cierre       = 0;

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp1.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
            SYSTEM vstmt;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp1.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10; HMD-INCIDENCIA-20220224
    
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierrecrec1.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec1.sql';
            SYSTEM vsql; 
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = 'cierreinvcreccomp1'
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF            
        END IF
    END IF;
    
    -- // #################################################################### //
    -- // # VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS # //
    -- // #################################################################### //
    WHILE vinicio_cierre = 0 
        SET ISOLATION TO DIRTY READ;
        
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierreinvcrec'
           AND fecha = vgfecha_hoy;
    END WHILE;

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
       
    -- // OBTIENE RANGO DE CUENTAS A PROCESAR
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCieInvCreComp1'; 
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCieInvCreComp2'; 
       
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
           AND mae.cuenta >= vcuentaini
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
           AND mae.cuenta >= vcuentaini
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
                               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec1.sql';
                    SYSTEM vsql;
                    
                    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
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
           AND cuenta >= vcuentaini
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec1.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec1.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierreinvcreccomp1";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END;

END PROCEDURE

DOCUMENT
'DESCRIPCION:   Complemento 1 Cierre Diario del Producto de Inversion Creciente de Captacion ',
'EJECUTADO POR: Control-M',
'AUTOR:         JICS',
'FECHA:         20/Febrero/2013',
'VERSION:       1.00.0000',
'Base de Datos: bdicheq';

CREATE PROCEDURE "informix".cierrechqinvcreccomp2_pba(pempresa CHAR(3))
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
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vinicio_cierre               SMALLINT;

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
    LET vproceso             = "cierrechqinvcrecomp2";
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
    LET vcuentaini           = '';
    LET vinicio_cierre       = 0;

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp2.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec2.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
            SYSTEM vstmt;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp2.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10; HMD-INCIDENCIA-20220224
    
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierrecrec2.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec2.sql';
            SYSTEM vsql; 
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = 'cierreinvcreccomp2'
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF            
        END IF
    END IF;
    
    -- // #################################################################### //
    -- // # VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS # //
    -- // #################################################################### //
    WHILE vinicio_cierre = 0 
        SET ISOLATION TO DIRTY READ;
        
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierreinvcrec'
           AND fecha = vgfecha_hoy;
    END WHILE;

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
       
    -- // OBTIENE RANGO DE CUENTAS A PROCESAR
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCieInvCreComp2'; 
       
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
           AND mae.cuenta >= vcuentaini
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
           AND mae.cuenta >= vcuentaini
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
                               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec2.sql';
                    SYSTEM vsql;
                    
                    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
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
           AND cuenta >= vcuentaini
           
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec2.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec2.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec2.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierreinvcreccomp2";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END;

END PROCEDURE

DOCUMENT
'DESCRIPCION:   Complemento 2 Cierre Diario del Producto de Inversion Creciente de Captacion ',
'EJECUTADO POR: Control-M',
'AUTOR:         JICS',
'FECHA:         20/Febrero/2013',
'VERSION:       1.00.0000',
'Base de Datos: bdicheq';

CREATE PROCEDURE "informix".sp_promueve_tarjetas_trimestral_actualiza()
    
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
    DEFINE ABREVIATURA_DEBITO CHAR(1);
    DEFINE PERMITE_SEGMENTACION_VERDADERO CHAR(1);
    DEFINE PROCESO_TRIMESTRAL CHAR(1);
    DEFINE PROCESO_MENSUAL CHAR(1);
    DEFINE MES_ENERO CHAR(2);
    DEFINE MES_ABRIL CHAR(2);
    DEFINE MES_JULIO CHAR(2);
    DEFINE MES_OCTUBRE CHAR(2);
    DEFINE FALSO CHAR(1);
    DEFINE VERDADERO CHAR(1);
    DEFINE PREFIJO_SCRIPTS CHAR(8);
    DEFINE vMaxLimiteMaximo DECIMAL(19,4);
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE vTotalRegistros INTEGER;
    
    DEFINE SQL_ERR                 INTEGER;
    DEFINE ISAM_ERR                INTEGER;
    DEFINE ERROR_INFO              VARCHAR(100);

	DEFINE vFechaHoy               DATE;
	DEFINE vAnio                   CHAR(4);
	DEFINE vCodProductoTarjeta	    VARCHAR (3);
	DEFINE vCodProductoSegmento    VARCHAR (3);
	DEFINE vAnioMes                VARCHAR(6);
	DEFINE vPeriodo                VARCHAR(6);
	DEFINE vProductoTarjeta        VARCHAR(3);
	DEFINE vNumRegistrosAfectados  INTEGER;

	DEFINE vMesEjecucion           CHAR(2);
    DEFINE vFlujoEnTransaccion  CHAR(1);	
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    
	LET vMesEjecucion  = '';
    LET CONTADOR_TRANSACCIONES = 1000;
	LET vFlujoEnTransaccion  = '';	

    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET PREFIJO_SCRIPTS = 'segtrim_';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET ABREVIATURA_DEBITO = 'D';
    LET PERMITE_SEGMENTACION_VERDADERO = 'V';
    LET PROCESO_TRIMESTRAL = 'T';
    LET PROCESO_MENSUAL = 'M';
    LET MES_ENERO = '01';
    LET MES_ABRIL = '04';
    LET MES_JULIO = '07';
    LET MES_OCTUBRE = '10';
    LET FALSO = 'F';
    LET VERDADERO ='V';    
    LET vMaxLimiteMaximo = '00.0000';
    LET vCodProductoTarjeta = '';
    LET vTotalRegistros = 0;
    LET vNumRegistrosAfectados = 0;
    LET vExecuteSQL = '';
    
    BEGIN
        
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || "sp_promueve_tarjetas_trimestral_actualiza_exception.out";           
            TRACE ON;
            
            IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion =  VERDADERO)) THEN                
                LET vFlujoEnTransaccion = FALSO;
                LET vNumRegistrosAfectados = 0;
                
                COMMIT WORK;
            END IF;           
            
            LET CODIGO_RETORNO   = SQL_ERR;
            LET MENSAJE_RETORNO  = error_info   ||   ISAM_ERR;
         
            RETURN CODIGO_RETORNO , MENSAJE_RETORNO;
        END EXCEPTION;
       
        --SET DEBUG FILE TO RUTA_ORIGEN || "sp_promueve_tarjetas_trimestral_actualiza.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        SELECT fecha_hoy 
            INTO vFechaHoy 
        FROM bdinteg:si_fechas
        --FROM intercard:si_fechas_temp
            WHERE empresa = '001';

        LET vAnio = SUBSTR(vFechaHoy,7,10);
        LET vMesEjecucion = LPAD(MONTH(vFechaHoy), 2, '0');
        LET vAnioMes = vAnio||vMesEjecucion;
        
        --Reporte trimestral considerado su ejecucion en los siguientes meses.
        
        IF ( (vMesEjecucion  <> MES_ENERO) AND (vMesEjecucion  <> MES_ABRIL) AND (vMesEjecucion  <> MES_JULIO) AND (vMesEjecucion  <> MES_OCTUBRE) ) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RETORNO = 'En el mes '||vMesEjecucion||' no puede ser ejecutado este reporte' ;
            RETURN CODIGO_RETORNO , MENSAJE_RETORNO;
        END IF;
        
        --Con el cambio de anyo debe considerarse el anyo anterior para los saldos trimestrales.
        --Para el uso de anyomes del periodo se consideran los datos obtenidos de la fecha integral.
        IF ( vMesEjecucion = MES_ENERO ) THEN
            LET vAnio = YEAR(today) - 1;
        END IF;
        
        SELECT             
            FIRST 1 periodo
                INTO vPeriodo 
        FROM intercard:sc_promtarjmensual 
        WHERE proceso = PROCESO_TRIMESTRAL
            AND periodo = vAnioMes;

        --dbinfo("sqlca.sqlerrd2") Returns a single integer that provides the number of rows SELECT, INSERT, DELETE, UPDATE...
        LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2");
        
        --Si existen registros almacenados en la tabla se procede con la ejecucion de segmentacion
        --Esta informacion fue cargada por el sp_promueve_tarjetas_trimestral
        IF(vNumRegistrosAfectados = 0) THEN
            LET CODIGO_RETORNO = '00002';
            LET MENSAJE_RETORNO  = 'Sin informacion por procesar en el periodo '||vAnioMes||'';
            RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
        END IF;
        
        DROP TABLE IF EXISTS "informix".tmp_segmentoproducto;
        
        SELECT            
            codproductotarjeta, codproductosegmento, clasifica_producto, 
                MAX(limite_max) AS limite_maximo, MIN (limite_max) as minimo_limite_max
        FROM intercard:segmentoproducto
        WHERE tipo_producto =  ABREVIATURA_DEBITO
            AND permite_segmentacion = PERMITE_SEGMENTACION_VERDADERO
        GROUP BY codproductotarjeta, codproductosegmento, clasifica_producto
        ORDER BY limite_maximo, codproductotarjeta
            INTO TEMP tmp_segmentoproducto WITH NO LOG;
        
        LET vFlujoEnTransaccion = FALSO;
        
        IF (vFlujoEnTransaccion = FALSO) THEN
            BEGIN WORK;
            LET vFlujoEnTransaccion = VERDADERO;
        END IF;
        

        FOREACH cursorf1 WITH HOLD FOR

            SELECT codproductotarjeta, codproductosegmento, limite_maximo
                INTO vCodProductoTarjeta, vCodProductoSegmento, vMaxLimiteMaximo
            FROM tmp_segmentoproducto     
        
            LET vNumRegistrosAfectados = 0;
            
            IF (vFlujoEnTransaccion = FALSO) THEN
                BEGIN WORK;
                LET vFlujoEnTransaccion = VERDADERO;
            END IF;

            DROP TABLE IF EXISTS "informix".tmp_promtrim_vs_tarjeta;
            
            SELECT
                sc.numtarjeta, sc.codproductotarjeta 
                FROM intercard:sc_promtarjmensual sc, intercard:tarjeta tar
            WHERE sc.codproductotarjeta = vCodProductoTarjeta
                AND sc.saldopromeditrimestral >= vMaxLimiteMaximo
                AND sc.numtarjeta = tar.numtarjeta 
                AND sc.periodo = vAnioMes
                AND tar.codstatustarjeta IN ('ACT','BLO')
                AND proceso = PROCESO_TRIMESTRAL
            INTO TEMP tmp_promtrim_vs_tarjeta WITH NO LOG;
            
            --SET PDQPRIORITY 0; HMD-INCIDENCIA-20220224
            CREATE INDEX "informix".idx_tmp_promtrim_codproductotjt
                ON "informix".tmp_promtrim_vs_tarjeta(codproductotarjeta) ONLINE;

            UPDATE intercard:tarjeta
                SET codproductotarjeta = vCodProductoSegmento
            WHERE numtarjeta IN (SELECT numtarjeta FROM tmp_promtrim_vs_tarjeta WHERE codproductotarjeta = vCodProductoTarjeta);
                
            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;

            UPDATE intercard:sc_promtarjmensual
            SET codproductotarjetanuevo = vCodProductoSegmento
            WHERE numtarjeta IN (SELECT numtarjeta FROM tmp_promtrim_vs_tarjeta WHERE codproductotarjeta = vCodProductoTarjeta);
            
            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;
            
            IF (vNumRegistrosAfectados >= CONTADOR_TRANSACCIONES) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
                LET vNumRegistrosAfectados = 0;
                CONTINUE FOREACH;
            END IF;
            
        END FOREACH;

        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            LET vFlujoEnTransaccion = FALSO;
            LET vNumRegistrosAfectados = 0;
            COMMIT WORK;
        END IF;
        
        
        FOREACH cursorf2 WITH HOLD FOR

            SELECT codproductotarjeta, codproductosegmento, limite_maximo
                INTO vCodProductoTarjeta, vCodProductoSegmento, vMaxLimiteMaximo
            FROM tmp_segmentoproducto     
        
            LET vNumRegistrosAfectados = 0;
            
            IF (vFlujoEnTransaccion = FALSO) THEN
                BEGIN WORK;
                LET vFlujoEnTransaccion = VERDADERO;
            END IF;

            ---Eliminar registros que no cambiaron de producto
            DROP TABLE IF EXISTS tmp_tarjetas_sin_afectacion_producto;
            SELECT                
                sca.numtarjeta, sca.codproductotarjeta, scb.codproductotarjetanuevo
            FROM    intercard:sc_promtarjmensual sca, intercard:sc_promtarjmensual scb
            WHERE   sca.codproductotarjeta = vCodProductoTarjeta
                AND     sca.codproductotarjetanuevo = vCodProductoTarjeta
                AND     sca.numcuenta = scb.numcuenta
                AND     sca.numcliente = scb.numcliente
                AND     sca.proceso = PROCESO_TRIMESTRAL
                AND     sca.periodo = vAnioMes
            INTO TEMP tmp_tarjetas_sin_afectacion_producto WITH NO LOG;
            
            DELETE FROM intercard:sc_promtarjmensual 
                WHERE numtarjeta IN ( SELECT numtarjeta FROM tmp_tarjetas_sin_afectacion_producto);      
            
            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;
            
            IF (vNumRegistrosAfectados >= CONTADOR_TRANSACCIONES) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
                LET vNumRegistrosAfectados = 0;
                CONTINUE FOREACH;
            END IF;
            
        END FOREACH;
        
        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            LET vFlujoEnTransaccion = FALSO;
            LET vNumRegistrosAfectados = 0;
            COMMIT WORK;
        END IF;
            

        DROP TABLE IF EXISTS "informix".tmp_segmentoproducto;
  
        --Eliminar la informacion de la tabla de paso
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo TRUNCATE TABLE "informix".tbl_paso_prom_mensual >'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql';        
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';        
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql';        
        SYSTEM vExecuteSQL;
        
        --Eliminacion de archivos creados en las consultas.
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_paso_prom_mensual;        
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".sc_promtarjmensual;
        
        
        ----=> Construccion del archivo.
        SELECT COUNT(*) conteo_registros 
            INTO vTotalRegistros 
        FROM intercard:sc_promtarjmensual
            WHERE periodo = vAnioMes
                AND proceso = PROCESO_TRIMESTRAL;
        
        IF (vTotalRegistros = 0) THEN
            LET CODIGO_RETORNO = '00003';
            LET MENSAJE_RETORNO = 'No hay informacion para crear archivo. Periodo '||vAnioMes||'';
            RETURN CODIGO_RETORNO,MENSAJE_RETORNO;
        END IF;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo "UNLOAD TO '|| RUTA_ORIGEN ||'cambioproductotrimestral'||vAnioMes||'.txt '||
                   ' SELECT numtarjeta, numcuenta, numcliente, codproductotarjeta, clave_tipotarjeta, '||
                   '   saldopromeditrimestral, codproductotarjetanuevo, proceso, periodo '||
                   ' FROM intercard:sc_promtarjmensual ' ||
                   ' WHERE periodo = '||"'"||vAnioMes||"'" ||
                   '   AND  proceso = ''"'||PROCESO_TRIMESTRAL||'"'' '||
                   ' ORDER BY numtarjeta;">'||RUTA_DESTINO||PREFIJO_SCRIPTS||'script_resultados.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_resultados.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_resultados.sql';
        SYSTEM vExecuteSQL;        
        
        
        RETURN 	CODIGO_RETORNO,MENSAJE_RETORNO;  
END 
END PROCEDURE
/*
-- Autor: Armando Garcia [ agarciao@bancoppel.com ]
-- Creado: 16.octubre.2018 13:09pm
-- Base de datos: bdicheq
-- Job: 206_30_19_SEG_PROD_TRIM_ACTUALIZA_COD_PRO | Job dependiente: 206_30_19_SEG_PROD_TRIM_CARGA_PRO
-- Descripcion: Proceso de consulta, registro y actualizacion del codigo de producto de tarjeta
-- de acuerdo al saldo trimestral correspondiente anterior al mes de ejecucion.
*/
;

CREATE PROCEDURE "informix".cierrechq_cta(pempresa CHAR(3))
RETURNING CHAR(5);
 
    --- ############################################################################
    --- ##  Nombre:              cierrechq                                        ##
    --- ##  Version:             1.0.1                                            ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion  ##
    --- ##  Creado por:                                                           ##
    --- ##  ModIFicado por:      JICS                                             ##
    --- ##  Ultima Modificacion: Marzo 2011                                       ##
    --- ############################################################################

    DEFINE GLOBAL vgusuario             CHAR(8)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE            DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod           DATE            DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta          DATE            DEFAULT " ";
    DEFINE GLOBAL vginstrucc            CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep           CHAR(20)        DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vcomienza                    SMALLINT;
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
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vtotsuc                      INTEGER;
    DEFINE vcontproc                    INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
    DEFINE vtfechaxxx                   DATE;
    DEFINE vsdo_cuenta                  MONEY(18,2);
    DEFINE vmto_pag_int                 MONEY(14,2);
    DEFINE vdias                        INTEGER;
    DEFINE vcontprocie                  CHAR(1);
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vregistros                   INTEGER;
    DEFINE vfecha_alta                  DATE;
    DEFINE vpago_interes                CHAR(1);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vProdChequerasPM             CHAR(4);
    
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
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vcomienza  = -1;
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechq";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vtotsuc         = 0;
    LET vcontproc       = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
    LET vtfechaxxx      = '';
    LET vsdo_cuenta     = 0.00;
    LET vmto_pag_int    = 0.00;
    LET vdias           = 0;
    LET vcontprocie     = '';
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentafin      = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vregistros      = 0;
    LET vfecha_alta     = '';
    LET vpago_interes   = '';
    LET vdia            = '';
    LET vfecha_pago     = '';
    LET vnumdias        = 0;
    LET vProdChequerasPM = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_cta.err";
        TRACE ON;
            
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;

            RETURN vcodret;
        END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_cta.out";
   -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10;   HMD-INCIDENCIA-20220224
    
    -- // FECHAS DEL SISTEMA DE CAPTACION
    SELECT fecha_ant, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, fecha_hoy
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // TRANSACCION DE PAGO DE INTERESES
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";

    -- // TRANSACCION DE COBRO DE ISR
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";

    -- // TRANSACCION DE PROVISION DE INTERESES
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";

    -- // TRANSACCION DE DESPROVISION DE INTERESES
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";

    -- // TRANSACCION DE ABONO PARA TRASPASO
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";

    -- // TRANSACCION DE REINVERSION DE INVS CREC
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // Producto Inversion Creciente
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // Producto de Chequeras
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // Producto de Chequeras Empresarial
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
              
     SET LOCK MODE TO WAIT 2;

    -- // OBTIENE NUMERO DE DIAS A PROCESAR
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF

    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = '2000'
           AND cuenta = '10071305738'
           AND status_cta not in("2","6","7")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF;
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;
     
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
    END FOREACH;
    
    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END

END PROCEDURE
;