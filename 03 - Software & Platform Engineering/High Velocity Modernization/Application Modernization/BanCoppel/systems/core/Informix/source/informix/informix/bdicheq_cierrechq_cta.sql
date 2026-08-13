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