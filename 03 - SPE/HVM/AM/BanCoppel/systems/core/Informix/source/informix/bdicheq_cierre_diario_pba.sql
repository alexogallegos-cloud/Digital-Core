create procedure "informix".cierre_diario_pba(pempresa char(3), pdias integer, pcuenta char(20))
returning char(5);
    
    -- ***********************************************************************
    -- * cierre_diario                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Calcula saldos acumulados para cierre diario   *
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creación de SPL                                 *
    -- ***********************************************************************
    
    DEFINE global vgcuenta          char(20)        default " ";
    DEFINE global vgsucursal        char(4)         default " ";
    DEFINE global vgsdo_actual      money(14,2)     default 0;
    DEFINE global vgacum_sdo_pos    money(14,2)     default 0;
    DEFINE global vgdia_sdo_pos     smallint        default 0;
    DEFINE global vgproducto        char(4)         default " ";
    DEFINE global vgstatus_cta      char(1)         default " ";
    DEFINE global vgpaga_interes    char(1)         default " ";
    DEFINE global vgmto_pag_int     money(14,2)     default 0;
    DEFINE global vgtasa            char(8)         default " ";
    DEFINE global vgsobretasa       decimal(9,6)    default 0;
    DEFINE global vgtp_moneda       char(2)         default " ";
    DEFINE global vges_fisica       char(1)         default " ";
    DEFINE global vgexento_isr      char(1)         default " ";
    DEFINE global vgtipo_dias_calc  char(1)         default " ";
    DEFINE global vgpago_interes    char(1)         default " ";
    DEFINE global vgtipo_anio_calc  char(1)         default " ";
    DEFINE global vgfecha_hoy       date            default " ";
    DEFINE global vgfecha_pago      date            default " ";
    DEFINE global vgnum_cte         char(20)        default " ";
    DEFINE global vgdias_acum_int   integer         default 0;
    DEFINE global vgacum_sdo_int    money(14,2)     default 0;
    DEFINE global vgfecha_alta      date            default "";
    DEFINE GLOBAL vgTasaVar         CHAR(1)         DEFAULT "";
    DEFINE GLOBAL vgFechaProc       DATE	        DEFAULT "";
    DEFINE GLOBAL vgProdCreciente   CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgint_acum        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_disp        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgpri_hab_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod       DATE            DEFAULT " ";
    DEFINE GLOBAL vgsdo_retenido    DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_cong        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vginstrucc        CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep       CHAR(20)        DEFAULT " ";

    DEFINE vsdo_prom     money(14,2);
    DEFINE vcodret       char(5);
    DEFINE vcodret2      char(5);
    DEFINE vcodret3      char(40);
    DEFINE vsqlerr       integer;
    DEFINE vcobraisr     char(1);
    DEFINE vfecpagoint   datetime month to day;
    DEFINE vultpagoint   date;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    CHAR(40);
    DEFINE vmotivo       CHAR(2);
    DEFINE vfechahora    CHAR(40);

    let vcodret  = "000";
    let vcodret2 = "000";
    let vcodret3 = "000";
    LET vfechahora = " ";

    begin

    on exception 
        set vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierrediario.err";
        TRACE ON;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = isam_err;
            let vcodret3 = error_info;
            LET vfechahora = CURRENT;
            return vcodret;
        end if;
    end exception;

    set isolation to dirty read;

    select mae.cuenta, mae.num_cte, mae.sucursal, mae.status_cta, mae.motivo, mae.producto, mae.fecha_proceso, 
           mae.sdo_actual, mae.sdo_cong, mae.sdo_retenido, mae.ultpagoint, mae.cobraisr, 
           noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int, noc.dias_acum_int,
           pro.paga_interes, pro.tasa, pro.sobretasa, pro.divisa, pro.tipo_dias_calc, pro.pago_interes, 
           pro.tipo_anio_calc, pro.mto_pag_int, pro.fecpagoint, pro.paga_dividendo,
           tip.es_fisica, tip.exento_isr
      into vgcuenta, vgnum_cte, vgsucursal, vgstatus_cta, vmotivo, vgproducto, vgFechaProc,
           vgsdo_actual, vgsdo_cong, vgsdo_retenido, vultpagoint, vcobraisr, 
           vgfecha_alta, vgacum_sdo_pos, vgdia_sdo_pos, vgint_acum, vgacum_sdo_int, vgdias_acum_int, 
           vgpaga_interes, vgtasa, vgsobretasa, vgtp_moneda, vgtipo_dias_calc, vgpago_interes, 
           vgtipo_anio_calc, vgmto_pag_int, vfecpagoint, vgTasaVar, 
           vges_fisica, vgexento_isr
      from sc_maechq mae,
           sc_maenoc noc,
           sc_producto pro,
           bdinteg:si_cliente cte,
           bdinteg:si_tipper tip
     where mae.empresa = pempresa 
	   and mae.cuenta = pcuenta
       and mae.status_cta not in("0","2","6","7","8")
       and noc.empresa = mae.empresa
       and noc.cuenta = mae.cuenta
       and pro.empresa = mae.empresa
       and pro.producto = mae.producto
       and cte.numcte = mae.num_cte
       and tip.tpo_persona = cte.tpo_persona;

    if vcobraisr <> "" then
        if vcobraisr = "S" then
            let vgexento_isr = "N";
        else
            let vgexento_isr = "S";
        end if
    end if

    if vgpaga_interes is null then
        let vgpaga_interes = "N";
    end if

    if vgmto_pag_int is null then
        let vgmto_pag_int = 0;
    end if

    /* VERIFICA SI ES EL PRIMER DIA DEL MES, INICIALIZA SALDO INTERES ACUMULADO */
    IF DAY(vgpri_hab_mes) = DAY(vgfecha_hoy) THEN
        LET vgdias_acum_int = pdias;
        LET vgint_acum = vgacum_sdo_int;
        LET vgacum_sdo_int = 0;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    /* DIAS DEL ACUMULADO DE INTERESES */
    ELSE 
        LET vgdias_acum_int = vgdias_acum_int + pdias;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    END IF

    /* SI LA CUENTA ES EMPRESARIAL ESPECIAL, TOMA EL SALDO DISPONIBLE COMPLETO */
    IF vmotivo = '99' THEN
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido;
    ELSE
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - vgsdo_cong ;
    END IF
    
    LET vsdo_prom = vgacum_sdo_pos/vgdia_sdo_pos;
    
    /* SI EL PROMEDIO CERO LE PASO EL SALDO ACTUAL SI SON CEROS ESTA BIEN MEL */
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgsdo_actual;
    END IF;
    
    if vgpaga_interes = "S" then
        call calcula_int(pempresa,pdias,vsdo_prom) 
        returning vcodret;
        
        if vcodret <> "000" then
            return vcodret;
        end if
    end if
    
    SET LOCK MODE TO WAIT 2;
    
    update sc_maenoc
       set dia_sdo_pos   = vgdia_sdo_pos,
           acum_sdo_pos  = vgacum_sdo_pos,
           dias_acum_int = vgdias_acum_int,
           acum_sdo_int  = vgacum_sdo_int,
           int_acum      = vgint_acum
     where empresa = pempresa
       and cuenta = vgcuenta;
    
    SET LOCK MODE TO NOT WAIT;
    
    return vcodret;
    
    end
    
end procedure;