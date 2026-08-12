CREATE PROCEDURE "informix".cierrechq2(pempresa CHAR(3))
RETURNING CHAR(5);

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
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
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
	DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vProdCtaEfec                 CHAR(4);
    DEFINE vProdNomGC                   CHAR(4);
    DEFINE vProdBasNom                  CHAR(4);
    DEFINE vinicio_cierre               SMALLINT;
    DEFINE vProdCtaNvl2                 CHAR(4);
     
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
    LET vproceso   = "cierrechq2";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
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
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vProdCtaEfec    = '2000';
    LET vProdNomGC      = '1300';
    LET vProdBasNom     = '1700';
    LET vinicio_cierre  = 0;
    LET vProdCtaNvl2    = '2900';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq2.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre2.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre2.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq2.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ##################################### //
    -- // #  FECHAS DEL SISTEMA DE CAPTACION  # //
    -- // ##################################### //
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // #################################### // 
    -- // # TRANSACCION DE PAGO DE INTERESES # //
    -- // #################################### // 
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    -- // ############################### //
    -- // # TRANSACCION DE COBRO DE ISR # //
    -- // ############################### //
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    -- // ######################################### //
    -- // # TRANSACCION DE PROVISION DE INTERESES # //
    -- // ######################################### //
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    -- // ############################################ //
    -- // # TRANSACCION DE DESPROVISION DE INTERESES # //
    -- // ############################################ //
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    -- // ###################################### //
    -- // # TRANSACCION DE ABONO PARA TRASPASO # //
    -- // ###################################### //
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    -- // ########################################### //
    -- // # TRANSACCION DE REINVERSION DE INVS CREC # //
    -- // ########################################### //
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // ################################ //
    -- // # Producto Inversion Creciente # //
    -- // ################################ //
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // ######################### //
    -- // # Producto de Chequeras # //
    -- // ######################### //
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // ##################################### //
    -- // # Producto de Chequeras Empresarial # //
    -- // ##################################### //
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // ################################ //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ################################ //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
      
    -- // ############################## //
    -- // # Producto Chequeras PLATINO # //
    -- // ############################## //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla";

    -- // ####################### //
    -- // # Productos de Nomina # //
    -- // ####################### //
    SELECT valor
      INTO vProdNomGC
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMI";
       
    SELECT valor
      INTO vProdBasNom
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMBA";
       
    -- // ########################### //
    -- // # Producto Cuenta Nivel 2 # //
    -- // ########################### //
    SELECT valor
      INTO vProdCtaNvl2
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODCTANIVEL2";
    
    -- // ############################################################ //
    -- // # VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL # //
    -- // ############################################################ //
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre2.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre2.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre2.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre2.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierre2"
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF
        END IF
    END IF;
    
    -- // ##################################### //
    -- // # OBTIENE NUMERO DE DIAS A PROCESAR # //
    -- // ##################################### //
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // ########################################## //
    -- // #                                        # //
    -- // ########################################## //
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
    
    -- // ########################################## //
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
       AND status_cta not in("2","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);
    
    -- // ######################################################### //
    -- // # Obtiene parametro de porcentajes de error por proceso # //
    -- // ######################################################### //
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
       
    -- // #################################################################### //
    -- // # VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS # //
    -- // #################################################################### //
    WHILE vinicio_cierre = 0 
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto IN( vProdNomGC, vProdBasNom, vProdCtaNvl2 )
           AND status_cta not in("2","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            -- // ############################################# //
            -- // # Conteo de Errores generados por el cierre # //
            -- // ############################################# //
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre2.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre2.sql';
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
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
    END FOREACH;
    
    /* #####################################################################################################################
    -- // ########################################### //
    -- // # ACTUALIZA EL SALDO DE CUENTAS INACTIVAS # //
    -- // ########################################### //
    FOREACH
        SELECT {+INDEX(sc_maechq)}
               cuenta, producto
          INTO vcuenta, vproducto
          FROM sc_maechq
         WHERE status_cta in('4', '5')
           AND fecha_proceso < vgfecha_hoy
           --AND producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
           AND sdo_actual <> sdo_dia_ant
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE cuenta = vcuenta;

        LET vcuenta   = '';
        LET vproducto = '';
    END FOREACH
    
    -- // ############################################################ //
    -- // # ACTUALIZA EL SALDO DE CUENTAS DESCONCENTRADAS ART 61 LIC # //
    -- // ############################################################ //
    FOREACH
        SELECT {+INDEX(sc_maechq)}
               cuenta, producto
          INTO vcuenta, vproducto
          FROM sc_maechq
         WHERE status_cta = '8'
           --AND producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM,vProdefechqnostro, vProdEfePla )
           AND sdo_actual <> sdo_dia_ant
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE cuenta = vcuenta;

        LET vcuenta   = '';
        LET vproducto = '';
    END FOREACH
    ##################################################################################################################### */
    
    -- // ########################## //
    -- // # Registra fin de cierre # //
    -- // ########################## //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre2.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre2.sql';
    SYSTEM vstmt;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre2";
    
    RETURN vcodret;
    
    END
    
END PROCEDURE;