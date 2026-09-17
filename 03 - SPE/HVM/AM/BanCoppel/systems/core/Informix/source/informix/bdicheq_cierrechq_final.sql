CREATE PROCEDURE "informix".cierrechq_final(pempresa CHAR(3))
RETURNING CHAR(5);
    
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

    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE info_err             CHAR(40);
    DEFINE vfechahora           CHAR(40);
    DEFINE vcomienza            SMALLINT;
    DEFINE vsql                 CHAR(600);
    DEFINE vstmt                CHAR(250);
    DEFINE vsistema             CHAR(2);
    DEFINE vproceso             CHAR(20);
    DEFINE vexiste1             SMALLINT;
    DEFINE vexiste2             SMALLINT;
    DEFINE vexiste3             SMALLINT;
    DEFINE vdias                INTEGER;
    DEFINE vfcuenta             CHAR(20);
    DEFINE FechaProc            DATE;
    DEFINE vProducto            CHAR(4);
    DEFINE vSdoActual           DECIMAL(14,2);
    DEFINE vSucursal            CHAR(4);
    DEFINE vProdChequeras       CHAR(4);
    DEFINE vProdChequerasPM     CHAR(4);
	DEFINE vProdefechqnostro    CHAR(4);
	DEFINE vProdEfePla          CHAR(4);
    DEFINE vcodretreg           CHAR(5);
    DEFINE cCuenta              CHAR(20);
    DEFINE iComienza            SMALLINT;
    DEFINE iTransacc            SMALLINT;
    DEFINE iContador            INTEGER;
     
    LET vgusuario         = USER;
    LET vgfecha_hoy       = '';
    LET vgpri_dia_mes     = '';
    LET vgpri_hab_mes     = '';
    LET vgult_dia_mes     = '';
    LET vgult_hab_mes     = '';
    LET vgprox_fecha      = '';
    LET vgtrans_pag_int   = '';
    LET vgtransisr        = '';
    LET vgtranprov        = '';
    LET vgtranrevprov     = '';
    LET vgtranabotrasp    = '';
    LET vgtranrecrece     = '';
    LET vgProdCreciente   = '';
    LET vgstatus_cta      = ' ';
    LET vcodret           = "000";
    LET vcodret2          = "";
    LET vcodret3          = "";
    LET sql_err           = 0;
    LET isam_err          = 0;
    LET info_err          = '';
    LET vfechahora        = " ";
    LET vcomienza         = -1;
    LET vsql              = '';
    LET vstmt             = '';
    LET vsistema          = "01";
    LET vproceso          = "cierrechq_final";
    LET vexiste1          = 0;
    LET vexiste2          = 0;
    LET vexiste3          = 0;
    LET vdias             = 0;
    LET vfcuenta          = '';
    LET FechaProc         = '';
    LET vProducto         = '';
    LET vSdoActual        = 0.00;
    LET vSucursal         = '';
    LET vProdChequeras    = '';
    LET vProdChequerasPM  = '';
    LET vProdefechqnostro = '';
	LET vProdEfePla       = '';
    LET vcodretreg        = "";
    LET cCuenta           = '';
    LET iComienza         = -1;
    LET iTransacc         = 0;
    LET iContador         = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, info_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_final.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret  = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = info_err;
            LET vfechahora = CURRENT;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''', '||
                       'status_proc   = '''||'E'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE proceso = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrefin.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrefin.sql';
            SYSTEM vstmt;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq_final.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
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
       
    -- // Producto de Chequeras NOSTRO 
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
      
    -- // Producto Chequeras PLATINO 
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla";    
        
    -- // VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL 
    SELECT COUNT(*)
      INTO vexiste1
      FROM bdinteg:sx_contproc
     WHERE proceso = vproceso
       AND fecha   = vgfecha_hoy
       AND sistema = vsistema;

    IF vexiste1 = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vgfecha_hoy||''', '||
                   ' '''||vsistema||''', '''||'I'||''', '''||vgusuario||''', '||
                   ' (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierrefin.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrefin.sql';
        SYSTEM vstmt;
    ELSE
        SELECT COUNT(*)
          INTO vexiste2
          FROM bdinteg:sx_contproc
         WHERE proceso = vproceso
           AND fecha   = vgfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";

        IF vexiste2 = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''', '||
                       'status_proc   = '''||'I'||''', '||
                       'codret        = '''||' '||''', '||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE proceso = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrefin.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrefin.sql';
            SYSTEM vstmt;
        ELSE
            SELECT COUNT(*)
              INTO vexiste3
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierre_final"
               AND fecha = vgfecha_hoy;

            IF vexiste3 > 0 THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF
        END IF
    END IF;
    
    -- // OBTIENE NUMERO DE DIAS A PROCESAR 
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ( (vgprox_fecha - 1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // FOREACH PRINCIPAL 
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto NOT IN(vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla)
           AND status_cta not in("2","7","8") 
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        CALL cierrechq_reg(pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodretreg;

        LET vfcuenta     = '';
        LET FechaProc    = '';
        LET vProducto    = '';
        LET vSdoActual   = 0.00;
        LET vgstatus_cta = ' ';
        LET vSucursal    = '';
    END FOREACH;
    
    -- // ACTUALIZA EL SALDO DE CUENTAS INACTIVAS 
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta
          INTO cCuenta
          FROM sc_maechq 
         WHERE status_cta in('4','5')
           AND fecha_proceso < vgfecha_hoy
           AND sdo_actual <> sdo_dia_ant
        
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE cuenta = cCuenta;
        
        LET iContador = iContador + 1;
        
        IF iContador >= 1000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

        LET cCuenta = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    LET iComienza = -1;
    
    -- // ACTUALIZA EL SALDO DE CUENTAS DESCONCENTRADAS ART 61 LIC 
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta
          INTO cCuenta
          FROM sc_maechq
         WHERE status_cta = '8'
           AND sdo_actual <> sdo_dia_ant
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE cuenta = cCuenta;
         
        LET iContador = iContador + 1;
        
        IF iContador >= 1000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

        LET cCuenta   = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    -- // Registra fin de cierre 
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc = '''||'F'||''', '||
               'codret          = '''||vcodret||''', '||
               'hora_fin        = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE proceso   = '''||vproceso||''' '||
               'AND fecha       = '''||vgfecha_hoy||''' '||
               'AND sistema     = '''||vsistema||''';" > /tmp/horacierrefin.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrefin.sql';
    SYSTEM vstmt;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre_final";
       
    RETURN vcodret;
    
    END;
    
END PROCEDURE;