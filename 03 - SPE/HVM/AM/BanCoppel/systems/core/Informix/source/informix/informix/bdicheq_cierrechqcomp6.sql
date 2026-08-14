CREATE PROCEDURE "informix".cierrechqcomp6(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp6                                       ##
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
    DEFINE vinicio_cierre               SMALLINT;
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
    DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vProdCtaEfec                 CHAR(4);
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
    LET vproceso   = "cierrechqcomp6";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = 0;
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
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vcuentaini      = '';
    LET vProdCtaEfec    = '2000';
    LET vcuentafin      = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp6.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre6.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre6.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp6.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ################################### //
    -- // # FECHAS DEL SISTEMA DE CAPTACION # //
    -- // ################################### //
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
    
-- // ##################################### //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ##################################### //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";  
  	   
    -- // ##################################### //
    -- // # Producto de Cuenta efectiva Chequeras PLATINO # //
    -- // ##################################### //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla"; 	   
       
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre6.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre6.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre6.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre6.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierrecomp6"
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
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
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
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vprodefepla )
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
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp5';
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp6'; 
    
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = vProdCtaEfec
           AND cuenta >= vcuentaini
           AND cuenta < vcuentafin
           AND status_cta not in("2","7","8") 
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre6.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre6.sql';
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre6.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre6.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp6";

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 04/Junio/2018',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqcomp7(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp7                                       ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Junio 2018                                           ##
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
    DEFINE vinicio_cierre               SMALLINT;
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
    DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vProdCtaEfec                 CHAR(4);
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
    LET vproceso   = "cierrechqcomp7";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = 0;
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
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vcuentaini      = '';
    LET vProdCtaEfec    = '2000';
    LET vcuentafin      = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp7.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre7.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre7.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp7.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ################################### //
    -- // # FECHAS DEL SISTEMA DE CAPTACION # //
    -- // ################################### //
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
    
-- // ##################################### //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ##################################### //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";  
  	   
    -- // ##################################### //
    -- // # Producto de Cuenta efectiva Chequeras PLATINO # //
    -- // ##################################### //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla"; 	   
       
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre7.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre7.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre7.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre7.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierrecomp7"
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
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
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
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vprodefepla )
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
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp6';
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp7'; 
    
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = vProdCtaEfec
           AND cuenta >= vcuentaini
           AND cuenta < vcuentafin
           AND status_cta not in("2","7","8") 
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre7.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre7.sql';
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre7.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre7.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp7";

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 04/Junio/2018',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqcomp8(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp8                                       ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Junio 2018                                           ##
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
    DEFINE vinicio_cierre               SMALLINT;
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
    DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vProdCtaEfec                 CHAR(4);
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
    LET vproceso   = "cierrechqcomp8";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = 0;
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
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vcuentaini      = '';
    LET vProdCtaEfec    = '2000';
    LET vcuentafin      = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp8.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre8.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre8.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp8.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ################################### //
    -- // # FECHAS DEL SISTEMA DE CAPTACION # //
    -- // ################################### //
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
    
-- // ##################################### //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ##################################### //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";  
  	   
    -- // ##################################### //
    -- // # Producto de Cuenta efectiva Chequeras PLATINO # //
    -- // ##################################### //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla"; 	   
       
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre8.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre8.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre8.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre8.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierrecomp8"
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
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
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
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vprodefepla )
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
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp7';
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp8'; 
    
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = vProdCtaEfec
           AND cuenta >= vcuentaini
           AND cuenta < vcuentafin
           AND status_cta not in("2","7","8") 
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre8.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre8.sql';
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre8.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre8.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp8";

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 04/Junio/2018',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cierrechqcomp9(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp9                                       ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Junio 2018                                           ##
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
    DEFINE vinicio_cierre               SMALLINT;
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
    DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vProdCtaEfec                 CHAR(4);
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
    LET vproceso   = "cierrechqcomp9";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = 0;
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
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vcuentaini      = '';
    LET vProdCtaEfec    = '2000';
    LET vcuentafin      = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp9.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre9.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre9.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp9.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ################################### //
    -- // # FECHAS DEL SISTEMA DE CAPTACION # //
    -- // ################################### //
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
    
-- // ##################################### //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ##################################### //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";  
  	   
    -- // ##################################### //
    -- // # Producto de Cuenta efectiva Chequeras PLATINO # //
    -- // ##################################### //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla"; 	   
       
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre9.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre9.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre9.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre9.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierrecomp9"
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
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
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
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vprodefepla )
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
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp8';
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniCierreCapComp9'; 
    
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto = vProdCtaEfec
           AND cuenta >= vcuentaini
           AND cuenta < vcuentafin
           AND status_cta not in("2","7","8") 
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre9.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre9.sql';
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
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre9.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre9.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp9";

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 04/Junio/2018',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".inicio_mes(pempresa char(3))
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret1             CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(80);
    DEFINE vsql_err             INTEGER;
    DEFINE visam_err            INTEGER;
    DEFINE vdesc_err            CHAR(80);
    DEFINE vcontador            INTEGER;
    DEFINE vcuantos             INTEGER;
    DEFINE vcomienza            INTEGER;
    DEFINE vfecha_prox          DATE;
    DEFINE vfecha_hoy           DATE;
    DEFINE vfechaini            DATE;
    DEFINE vfechafin            DATE;
    DEFINE vfecha_valida        DATE;
    DEFINE vfecha_validada      DATE;
    DEFINE vdia                 CHAR(2);
    DEFINE vdias                SMALLINT;
    DEFINE vaniomes             CHAR(6);
    DEFINE v_cuantos            SMALLINT;
    DEFINE vtraninteres         CHAR(4);
    DEFINE vtranisr             CHAR(4);
    DEFINE vfechainimovhis      CHAR(10);
    DEFINE vfechainimovhisold   CHAR(10);
    DEFINE vtrandepotrobco      CHAR(4);
    DEFINE vtrandevotrobco      CHAR(4);
    DEFINE vcuenta              CHAR(20);
    DEFINE vsucursal            CHAR(4);
    DEFINE vproducto            CHAR(4);
    DEFINE vnum_cte             CHAR(20);
    DEFINE vstatus_cta          CHAR(1);
    DEFINE vmotivo              CHAR(1);
    DEFINE vfec_cancelac        DATE;
    DEFINE vcuenta_clabe        CHAR(20);
    DEFINE vdirecc_envio        SMALLINT;
    DEFINE vsdo_actual          MONEY(18,2);
    DEFINE vsdo_retenido        MONEY(18,2);
    DEFINE vsdo_cong            MONEY(18,2);
    DEFINE vimp_chq_sbg         MONEY(18,2);
    DEFINE vsaldo_sbc           MONEY(18,2);
    DEFINE vlim_sbg_ccc         MONEY(18,2);
    DEFINE vimp_sbg_ccc         MONEY(18,2);
    DEFINE vacum_sdo_pos        MONEY(18,2);
    DEFINE vdia_sdo_pos         SMALLINT;
    DEFINE vint_acum            MONEY(18,2);
    DEFINE vacum_sdo_int        MONEY(18,2);
    DEFINE vdias_acum_int       SMALLINT;
    DEFINE visr_acum            MONEY(18,2);
    DEFINE vsdo_mes_ant         MONEY(18,2);
    DEFINE vret_mes_ant         MONEY(18,2);
    DEFINE vcong_mes_ant        MONEY(18,2);
    DEFINE venvio_direcc        CHAR(1);
    DEFINE vpago_interes        CHAR(1);
    DEFINE vmaxsecuencia        SMALLINT;
    DEFINE vnum_tarjeta         CHAR(16);
    DEFINE vt_monto_tot         MONEY(18,2);
    DEFINE vt_transacc          CHAR(4);
    DEFINE vt_naturaleza        CHAR(1);
    DEFINE vt_tipo_tran         CHAR(2);
    DEFINE vtran_efec           CHAR(4);
    DEFINE vtotdepositos        MONEY(18,2);
    DEFINE vtotcombonif         MONEY(18,2);
    DEFINE vtotivabonif         MONEY(18,2);
    DEFINE vtotretiros          MONEY(18,2);
    DEFINE vtototroscargos      DECIMAL(18,2);
    DEFINE vtotretirosefec      DECIMAL(18,2);
    DEFINE vtotcomcobrada       MONEY(18,2);
    DEFINE vtotivacobrado       MONEY(18,2);
    DEFINE vtotintpag           MONEY(18,2);
    DEFINE vtotisrcobrado       MONEY(18,2);
    DEFINE vtasa_bruta          DECIMAL(9,6);
    DEFINE vbandcorte           CHAR(1);
    DEFINE vsdo_prom_mesant     MONEY(18,2);
    DEFINE vgat                 DECIMAL(9,6);
    DEFINE vgat_real            DECIMAL(9,6); 
    
    LET vcodret1           = "000";
    LET vcodret2           = "000";
    LET vcodret3           = "";
    LET vsql_err           = 0;
    LET visam_err          = 0;
    LET vdesc_err          = "";
    LET vcontador          = 0;
    LET vcuantos           = 0;
    LET vcomienza          = -1;
    LET vfecha_prox        = "";
    LET vfecha_hoy         = "";
    LET vfechaini          = "";
    LET vfechafin          = "";
    LET vfecha_valida      = "";
    LET vfecha_validada    = "";
    LET vdia               = "";
    LET vdias              = 0;
    LET vaniomes           = "";
    LET v_cuantos          = 0;
    LET vtraninteres       = "";
    LET vtranisr           = "";
    LET vfechainimovhis    = "";
    LET vfechainimovhisold = "";
    LET vtrandepotrobco    = "";
    LET vtrandevotrobco    = "";
    LET vcuenta            = "";
    LET vsucursal          = "";
    LET vproducto          = "";
    LET vnum_cte           = "";
    LET vstatus_cta        = "";
    LET vmotivo            = "";
    LET vfec_cancelac      = "";
    LET vcuenta_clabe      = "";
    LET vdirecc_envio      = 0;
    LET vsdo_actual        = 0.00;
    LET vsdo_retenido      = 0.00;
    LET vsdo_cong          = 0.00;
    LET vimp_chq_sbg       = 0.00;
    LET vsaldo_sbc         = 0.00;
    LET vlim_sbg_ccc       = 0.00;
    LET vimp_sbg_ccc       = 0.00;
    LET vacum_sdo_pos      = 0.00;
    LET vdia_sdo_pos       = 0;
    LET vint_acum          = 0.00;
    LET vacum_sdo_int      = 0.00;
    LET vdias_acum_int     = 0;
    LET visr_acum          = 0.00;
    LET vsdo_mes_ant       = 0.00;
    LET vret_mes_ant       = 0.00;
    LET vcong_mes_ant      = 0.00;
    LET venvio_direcc      = "";
    LET vpago_interes      = "";
    LET vmaxsecuencia      = 0;
    LET vnum_tarjeta       = "";
    LET vt_monto_tot       = 0.00;
    LET vt_transacc        = "";
    LET vt_naturaleza      = "";
    LET vt_tipo_tran       = "";
    LET vtran_efec         = '';
    LET vtotdepositos      = 0.00;
    LET vtotcombonif       = 0.00;
    LET vtotivabonif       = 0.00;
    LET vtotretiros        = 0.00;
    LET vtototroscargos    = 0.00;
    LET vtotretirosefec    = 0.00;
    LET vtotcomcobrada     = 0.00;
    LET vtotivacobrado     = 0.00;
    LET vtotintpag         = 0.00;
    LET vtotisrcobrado     = 0.00;
    LET vtasa_bruta        = 0.000000;
    LET vbandcorte         = '';
    LET vsdo_prom_mesant   = 0.00;
    LET vgat               = 0.000000;
    LET vgat_real          = 0.000000;
    
    BEGIN
    
    ON EXCEPTION SET vsql_err, visam_err, vdesc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/inicio_mes.err";
        TRACE ON;
        IF vsql_err <> 0 THEN
            LET vcodret1 = vsql_err;
            LET vcodret2 = visam_err;
            LET vcodret3 = vdesc_err;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/inicio_mes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, fecha_hoy - 1 UNITS MONTH, fecha_ant , fecha_hoy
      INTO vfecha_prox, vfecha_hoy, vfechaini, vfechafin, vfecha_valida
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vdia = SUBSTR(vfecha_valida,4,2);
    LET vdia = vdia;
    
    IF LPAD(vdia,2,'0') <> "01" THEN
        IF LPAD(vdia,2,'0') = "02" THEN
            LET vfecha_validada = vfecha_valida - 1;
            
            EXECUTE PROCEDURE sp_valfechabil(vfecha_validada,"") 
            INTO vcodret1, vfecha_validada;
            
            IF vfecha_validada <> vfecha_valida THEN
                LET vcodret1 = '908';
                LET vcodret2 = '908';
                RETURN vcodret1, vcodret2, vcuantos;
            END IF
            
            LET vfechaini = vfechaini - 1;
        ELSE
            LET vcodret1 = '908';
            RETURN vcodret1, vcodret2, vcuantos;
        END IF
    END IF
    
    EXECUTE PROCEDURE sp_valfechabil(vfecha_prox,"") 
    INTO vcodret1, vfecha_prox;
    
    EXECUTE PROCEDURE sp_valfechabil(vfecha_hoy,"") 
    INTO vcodret1, vfecha_hoy;
    
    EXECUTE PROCEDURE sp_valfechabil(vfechaini,"") 
    INTO vcodret1, vfechaini;
    
    EXECUTE PROCEDURE sp_valfechabil(vfechafin,"") 
    INTO vcodret1, vfechafin;
    
    LET vdias = day(vfecha_prox) - 1;
    LET vaniomes = year(vfecha_hoy) || lpad(month(vfecha_hoy),2,"0");
    
    -- // VERIFICA QUE NO SE HAYA REALIZADO EL INICIO DE MES
    SELECT COUNT(*)
      INTO v_cuantos
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "inicio_mes"
       AND fecha = vfecha_valida;
    
    IF v_cuantos > 0 THEN 
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        RETURN vcodret1, vcodret2, vcuantos;
    END IF;
    
    -- // OBTIENE PARAMETROS DE TRANSACCIONES Y FECHAS
    SELECT valor
      INTO vtraninteres
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    SELECT valor
      INTO vtranisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
       
    SELECT valor
      INTO vfechainimovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechainimovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor
      INTO vtrandepotrobco
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'trandepobco';
       
    SELECT valor
      INTO vtrandevotrobco
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'trandevobco';
       
    -- // FOREACH PRINCIPAL      
    FOREACH WITH HOLD
        --- SELECT {+INDEX(sc_producto idxscproductopba), +INDEX(sc_maechq idxscmaechqpba), +INDEX(sc_maenoc noc1)}
        SELECT {+INDEX(sc_producto), +INDEX(sc_maechq), +INDEX(sc_maenoc)}
               mae.cuenta, mae.sucursal, mae.producto, mae.num_cte, mae.status_cta, mae.motivo, mae.fec_cancelac, mae.cuenta_clabe, mae.direcc_envio, 
               mae.sdo_dia_ant, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, mae.lim_sbg_ccc, mae.imp_sbg_ccc, 
               noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int, noc.dias_acum_int, 
               noc.isr_acum, noc.sdo_mes_ant, noc.ret_mes_ant, noc.cong_mes_ant, noc.envio_direcc, 
               pro.pago_interes
          INTO vcuenta, vsucursal, vproducto, vnum_cte, vstatus_cta, vmotivo, vfec_cancelac, vcuenta_clabe, vdirecc_envio,
               vsdo_actual, vsdo_retenido, vsdo_cong, vimp_chq_sbg, vsaldo_sbc, vlim_sbg_ccc, vimp_sbg_ccc,
               vacum_sdo_pos, vdia_sdo_pos, vint_acum, vacum_sdo_int, vdias_acum_int, 
               visr_acum, vsdo_mes_ant, vret_mes_ant, vcong_mes_ant, venvio_direcc,
               vpago_interes
          FROM sc_producto pro, 
               sc_maechq mae, 
               sc_maenoc noc 
         WHERE pro.producto = mae.producto
           AND pro.pago_interes = 'M'
           AND mae.status_cta != '2'
           AND noc.cuenta = mae.cuenta 
           AND mae.cuenta NOT IN(SELECT cuenta FROM sc_maehis WHERE aniomes = vaniomes AND cuenta = mae.cuenta)
           AND mae.producto <> '5000'
           
        IF (vcomienza = -1)THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        -- // INICIALIZA VARIABLES DE SALDOS
        LET vtotdepositos   = 0;
        LET vtotretiros     = 0;
        LET vtotintpag      = 0;
        LET vtasa_bruta     = 0;
        LET vtotcomcobrada  = 0;
        LET vtotcombonif    = 0;
        LET vtotivacobrado  = 0;
        LET vtotivabonif    = 0;
        LET vtotisrcobrado  = 0;
        LET vtotretirosefec = 0;
        LET vtototroscargos = 0;
        LET vgat            = 0;
        LET vgat_real       = 0;
        LET vnum_tarjeta    = "";
        
        FOREACH
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              INTO vt_monto_tot, vt_transacc, vt_naturaleza, vt_tipo_tran, vtran_efec
              FROM sc_movhis mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pempresa
               AND mv.cuenta = vcuenta   
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc > '0000'
            UNION ALL 
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              FROM sc_movhis_old mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pempresa
               AND mv.cuenta = vcuenta   
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhisold
               AND mv.fech_alt < vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc > '0000'
            
            -- // ABONOS
            IF vt_naturaleza = "A" THEN -- // TOTAL DEPOSITOS
                IF (vt_transacc <> vtraninteres AND vt_transacc <> vtrandepotrobco) THEN
                    LET vtotdepositos = vtotdepositos + vt_monto_tot;
                END IF
                
                IF vt_tipo_tran in("01","05","09") THEN -- // TOTAL COMISIONES BONIFICADAS
                    LET vtotcombonif = vtotcombonif + vt_monto_tot;
                END IF
                
                IF vt_tipo_tran in("02","04","06","08","10") THEN -- // TOTAL IVAS BONIFICADOS
                    LET vtotivabonif = vtotivabonif + vt_monto_tot;
                END IF
            -- // CARGOS
            ELIF vt_naturaleza = "C" THEN -- // TOTAL CARGOS
                IF (vt_tipo_tran in('00','30') AND vt_transacc <> vtranisr AND vt_transacc <> vtrandevotrobco) THEN
                    LET vtotretiros = vtotretiros + vt_monto_tot;
                    LET vtototroscargos = vtototroscargos + vt_monto_tot;
                END IF;
                
                IF vtran_efec = vt_transacc THEN
                    LET vtotretirosefec = vtotretirosefec + vt_monto_tot;
                END IF;
                
                IF vt_tipo_tran in("01","05") THEN -- // TOTAL COMISIONES COBRADAS
                    LET vtotcomcobrada = vtotcomcobrada + vt_monto_tot;
                END IF
                
                IF vt_tipo_tran in("02","04","06","08") THEN -- // TOTAL IVA COBRADO
                    LET vtotivacobrado = vtotivacobrado + vt_monto_tot;
                END IF
            END IF
            
            IF vt_transacc = vtraninteres THEN -- // TOTAL PAGO DE INTERESES
                LET vtotintpag = vtotintpag + vt_monto_tot;
            END IF
            
            IF vt_transacc = vtranisr THEN -- // TOTAL ISR COBRADO
                LET vtotisrcobrado = vtotisrcobrado + vt_monto_tot;
            END IF
        END FOREACH
        
        IF vtotretirosefec is null OR vtotretirosefec < 0 THEN
            LET vtotretirosefec = 0;
        END IF;
        
        LET vtototroscargos = vtototroscargos - vtotretirosefec;
        
        IF vtototroscargos is null OR vtototroscargos < 0 THEN
            LET vtototroscargos = 0;
        END IF;
        
        IF vtotdepositos is null OR vtotdepositos < 0.00 THEN
            LET vtotdepositos = 0.00;
        END IF;
        
        IF vtotintpag is null OR vtotintpag < 0.00 THEN
            LET vtotintpag = 0.00;
        END IF;
        
        IF vtotcombonif is null OR vtotcombonif < 0.00 THEN
            LET vtotcombonif = 0.00;
        END IF;
        
        LET vtotcomcobrada = vtotcomcobrada - vtotcombonif;
        
        IF vtotcomcobrada is null OR vtotcomcobrada < 0.00 THEN
            LET vtotcomcobrada = 0.00;
        END IF;
        
        IF vtotivabonif is null OR vtotivabonif < 0.00 THEN
            LET vtotivabonif = 0.00;
        END IF;
        
        LET vtotivacobrado = vtotivacobrado - vtotivabonif;
        
        IF vtotivacobrado is null OR vtotivacobrado < 0.00 THEN
            LET vtotivacobrado = 0.00;
        END IF;
        
        IF vtotisrcobrado is null OR vtotisrcobrado < 0.00 THEN
            LET vtotisrcobrado = 0.00;
        END IF;
        
        --- LET vtotretiros = vtotretiros - vtotcomcobrada - vtotivacobrado - vtotisrcobrado;
        
        IF vtotretiros is null OR vtotretiros < 0.00 THEN
            LET vtotretiros = 0.00;
        END IF;
        
        SELECT FIRST 1 mov.tasa_aplicada
          INTO vtasa_bruta
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfechafin
           AND mov.cancelad <> 'S'
           AND mov.transacc = vtraninteres;
           
        IF vtasa_bruta is null OR vtasa_bruta = '' THEN
            LET vtasa_bruta = 0;
        END IF;
        
        IF vpago_interes = "D" OR  -- // DIARIO
           vpago_interes = "M" OR  -- // MENSUAL
          (vpago_interes = "T" AND (month(vfecha_prox) = "4" OR month(vfecha_prox) = "7" OR month(vfecha_prox) = "10" OR month(vfecha_prox) = "1")) OR -- // TRIMESTRAL
          (vpago_interes = "S" AND (month(vfecha_prox) = "7" OR month(vfecha_prox) = "1")) OR -- // SEMESTRAL
          (vpago_interes = "A" AND month(vfecha_prox) = "1") THEN -- // ANUAL
            LET vbandcorte = "S";
        ELSE
            LET vbandcorte = "N";
        END IF
        
        IF vbandcorte = "S" THEN
            LET vaniomes = vaniomes;
            LET vcuenta = vcuenta;
            
            INSERT INTO sc_maehis VALUES
            ( pempresa, vaniomes, vcuenta, vfechaini, vfechafin, vcuenta_clabe, vnum_tarjeta, vsucursal, vproducto, vnum_cte, vstatus_cta, vmotivo,
              vfec_cancelac, vsdo_retenido, vsdo_cong, vsdo_actual, venvio_direcc, vdirecc_envio, vsdo_mes_ant, vacum_sdo_pos, vdia_sdo_pos, vacum_sdo_int,
              vdias_acum_int, vtasa_bruta, vret_mes_ant, vcong_mes_ant, vlim_sbg_ccc, vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum,
              vtotdepositos, vtotretiros, vtotintpag, vtotcomcobrada, vtotivacobrado, vtotisrcobrado, vtotretirosefec, vtototroscargos, vgat, vgat_real );
        END IF
        
        -- // INICIALIZA MAESTRO DE CHEQUES Y ACUMULADOS
        LET vsdo_mes_ant = vsdo_actual;
        
        IF vdia_sdo_pos > 0 THEN
            LET vsdo_prom_mesant = vacum_sdo_pos / vdia_sdo_pos;
        ELSE
            LET vsdo_prom_mesant = 0;
        END IF
        
        IF vdias > 0 THEN
            LET vacum_sdo_pos = vsdo_actual * vdias;
            LET vdia_sdo_pos = vdias;
            LET vacum_sdo_int = ((((vacum_sdo_pos / vdias) * vtasa_bruta) / 360) * vdias);
        ELSE
            LET vacum_sdo_pos = 0;
            LET vdia_sdo_pos = 0;
            LET vacum_sdo_int = 0;
        END IF
        
        IF vpago_interes IS NULL or vpago_interes = " " THEN
            LET vpago_interes = "M";
        END IF
        
        IF vbandcorte = "S" THEN
            UPDATE sc_maenoc
               SET acum_sbc        = 0,
                   acum_rem        = 0,
                   dia_sdo_pos     = vdia_sdo_pos,
                   acum_sdo_pos    = vacum_sdo_pos,
                   dias_acum_int   = vdia_sdo_pos,
                   acum_sdo_int    = vacum_sdo_int,
                   sdo_mes_ant     = vsdo_mes_ant,
                   sdo_prom_mesant = vsdo_prom_mesant,
                   int_acum        = 0,
                   isr_acum        = 0,
                   ret_mes_ant     = vsdo_retenido,
                   cong_mes_ant    = vsdo_cong
             WHERE cuenta = vcuenta;

            UPDATE sc_maechq
               SET chq_exp_mes    = 0,
                   chq_dev        = 0,
                   monto_dev      = 0,
                   sdo_dia_ant    = vsdo_mes_ant,
                   num_cgos_mes   = 0,
                   imp_cgos_mes   = 0,  
                   num_abonos_mes = 0,
                   imp_abonos_mes = 0
             WHERE cuenta = vcuenta;
        ELSE
            UPDATE sc_maenoc
               SET acum_sbc        = 0,
                   acum_rem        = 0,
                   sdo_mes_ant     = vsdo_mes_ant,
                   sdo_prom_mesant = vsdo_prom_mesant,
                   ret_mes_ant     = vsdo_retenido,
                   cong_mes_ant    = vsdo_cong
             WHERE cuenta = vcuenta;
        END IF
        
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF (vcontador > 0) THEN
        LET vcuantos = vcuantos + vcontador;
        COMMIT WORK;
    END IF;
    
    UPDATE sc_contproc
       SET fecha = vfecha_valida
     WHERE empresa = pempresa
       AND proceso = "inicio_mes";
    
    RETURN vcodret1, vcodret2, vcuantos;
    
    END;
    
END PROCEDURE;