create procedure "informix".cierre_mensual(pempresa char(3), pdias smallint, pcuenta char(20))
returning char(5);
    
    -- ***********************************************************************
    -- * cierre_mensual                                                      *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Calcula saldos acumulados para cierre mensual  *
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creacion de SPL                                 *
	-- * MODIFICO :		Ezequiel Moreno Paredes									*
	-- * FECHA : 		13-06-2025												*
	-- * MODIFICACION : Se modifica la formula de calculo de saldo disponible	*
	-- *                para considerar un nuevo campo llamado saldo_sbc	 	*
	-- * PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion	*
	-- * VERSION :      1.0.1												 	*
	-- * BD: 			bdicheq													*
	-- *                     				                                 	*
    -- ***********************************************************************
    
    DEFINE global vgfecha_hoy      date             default " ";
    DEFINE global vgfecha_pago     date             default " ";
    DEFINE global vgusuario        char(8)          default " ";
    DEFINE global vgpri_hab_mes    date             default " ";
    DEFINE global vgult_hab_mes    date             default " ";
    DEFINE global vgcuenta         char(20)         default " ";
    DEFINE global vgsucursal       char(4)          default " ";
    DEFINE global vgsdo_actual     money(14,2)      default 0;
    DEFINE global vgacum_sdo_pos   money(14,2)      default 0;
    DEFINE global vgdia_sdo_pos    smallint         default 0;
    DEFINE global vgproducto       char(4)          default " ";
    DEFINE global vgstatus_cta     char(1)          default " ";
    DEFINE global vgpaga_interes   char(1)          default " ";
    DEFINE global vgmto_pag_int    money(14,2)      default 0;
    DEFINE global vgtasa           char(8)          default " ";
    DEFINE global vgsobretasa      decimal(9,6)     default 0;
    DEFINE global vgtp_moneda      char(2)          default " ";
    DEFINE global vges_fisica      char(1)          default " ";
    DEFINE global vgexento_isr     char(1)          default " ";
    DEFINE global vgtipo_dias_calc char(1)          default " ";
    DEFINE global vgpago_interes   char(1)          default " ";
    DEFINE global vgtipo_anio_calc char(1)          default " ";
    DEFINE global vgnum_cte        char(20)         default " ";
    DEFINE global vgfecha_alta     date             default "";
    DEFINE GLOBAL vgTasaVar        CHAR(1)          DEFAULT "";
    DEFINE GLOBAL vgFechaProc      DATE             DEFAULT "";
    DEFINE GLOBAL vgacum_sdo_int   MONEY(14,2)      DEFAULT 0;
    DEFINE GLOBAL vgProdCreciente  CHAR(4)          DEFAULT " ";
    DEFINE GLOBAL vgint_acum       DECIMAL(14,2)    DEFAULT 0;
    DEFINE GLOBAL vgsdo_disp       DECIMAL(14,2)    DEFAULT 0;
    DEFINE GLOBAL vgdias_acum_int  INTEGER          DEFAULT 0;
    DEFINE GLOBAL vgfecha_mod      DATE             DEFAULT " ";
    DEFINE GLOBAL vgnum_tarjeta    CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgsdo_retenido   DECIMAL(14,2)    DEFAULT 0;
    DEFINE GLOBAL vgsdo_cong       DECIMAL(14,2)    DEFAULT 0;
    DEFINE GLOBAL vginstrucc       CHAR(2)          DEFAULT " ";
    DEFINE GLOBAL vgcuentadep      CHAR(20)         DEFAULT " ";

    DEFINE vsdo_prom       money(14,2);
    DEFINE vcodret         char(5);
    DEFINE vcodret2        char(5);
    DEFINE vcodret3        char(40);
    DEFINE vsqlerr         integer;
    DEFINE vregproc        smallint;
    DEFINE vfecha          datetime year to month;
    DEFINE vsecuencia      smallint;
    DEFINE vcobraisr,
           vexiste,
           vclase_cta      char(1);
    DEFINE viva            decimal(9,6);
    DEFINE vultpagoint     date;
    DEFINE vfolio_suc      char(16);
    DEFINE vhora           datetime hour to fraction;
    DEFINE vhoraw          char(15);
    DEFINE vcom_pendiente,
           vacum_ccc,
           vacum_rem,
           vacum_sbc,
           vmonto_dev      money(14,2);
    DEFINE vchq_exp_mes,
           vdias_ccc,
           vchq_dev        smallint;
    DEFINE vcta_en_legal   char(1);
    DEFINE vnum_cgos_mes,
           vnum_abonos_mes integer;
    DEFINE vfecpagoint     datetime month to day;
    DEFINE vcobrasegf      char(1);
    DEFINE vcuenta         char(20);
    DEFINE vstatus_cta     char(1);
    DEFINE isam_err        integer;
    DEFINE error_info      CHAR(40);
    DEFINE vmotivo         char(2);
    DEFINE vnumdias        SMALLINT;
    DEFINE vcuantos        SMALLINT;
    DEFINE vfechaux        date;
    DEFINE vimp_sbg_ccc    DECIMAL(14,2);
    DEFINE vfechahora      CHAR(40);
	--RQM 09 704. Se crea la siguiente variable . 
	DEFINE mSaldoSBC	   MONEY(14,2); 		--Obtiene el saldo_sbc de la maestra de cheques.

    let vcodret  = "000";
    let vcodret2 = "000";
    let vcodret3 = "000";
    LET vfechahora = " ";
	--RQM 09 704. Se inicializa la siguiente variable generada. 
	LET mSaldoSBC	= 0.00;
	
    begin

    on exception
        set vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierremensual.err";
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
    SET LOCK MODE TO WAIT 3;

    --Set Debug File To '/home/c90301007/Traza/cierre_mensual.out';
    --Trace On;

    let vfecha = vgfecha_hoy;
    let vsecuencia = month(vgfecha_hoy);
    let vimp_sbg_ccc = 0;

	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
    select mae.cuenta, mae.num_cte, mae.sucursal, mae.producto, mae.status_cta, mae.motivo, mae.fecha_proceso, mae.ultpagoint, mae.cobraisr, 
           mae.sdo_actual, mae.sdo_cong, mae.sdo_retenido, mae.num_cgos_mes, mae.num_abonos_mes, mae.chq_exp_mes, mae.chq_dev, mae.monto_dev, mae.imp_sbg_ccc, 
           noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int, noc.dias_acum_int, 
           noc.acum_sbc, noc.acum_rem, noc.dias_ccc, noc.acum_ccc, noc.clase_cta, noc.cta_en_legal,  
           pro.paga_interes, pro.tasa, pro.sobretasa, pro.divisa, pro.tipo_dias_calc, pro.pago_interes, 
           pro.tipo_anio_calc, pro.fecpagoint, pro.mto_pag_int, pro.paga_dividendo,
           tip.es_fisica, tip.exento_isr, mae.saldo_sbc
      into vgcuenta, vgnum_cte, vgsucursal, vgproducto, vgstatus_cta, vmotivo, vgFechaProc, vultpagoint, vcobraisr,
           vgsdo_actual, vgsdo_cong, vgsdo_retenido, vnum_cgos_mes, vnum_abonos_mes, vchq_exp_mes, vchq_dev, vmonto_dev, vimp_sbg_ccc,
           vgfecha_alta, vgacum_sdo_pos, vgdia_sdo_pos, vgint_acum, vgacum_sdo_int, vgdias_acum_int, 
           vacum_sbc, vacum_rem, vdias_ccc, vacum_ccc, vclase_cta, vcta_en_legal, 
           vgpaga_interes, vgtasa, vgsobretasa, vgtp_moneda, vgtipo_dias_calc, vgpago_interes, 
           vgtipo_anio_calc, vfecpagoint, vgmto_pag_int, vgTasaVar,
           vges_fisica, vgexento_isr, mSaldoSBC
      from sc_maechq mae,
           sc_maenoc noc,
           sc_producto pro,
           bdinteg:si_cliente cte,
           bdinteg:si_tipper tip
     where mae.empresa = pempresa
       and mae.cuenta = pcuenta
       and mae.status_cta not in("2","7","8")
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

    LET vsdo_prom = vgacum_sdo_pos / vgdia_sdo_pos;

    /* SI LA CUENTA ES EMPRESARIAL ESPECIAL, TOMA EL SALDO DISPONIBLE COMPLETO */
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
    IF vmotivo = '99' THEN
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - mSaldoSBC;
    ELSE                                                                                          	
        let vgsdo_disp = vgsdo_actual - (vgsdo_retenido + vgsdo_cong + vimp_sbg_ccc + mSaldoSBC);
    END IF

    /* SI EL PROMEDIO CERO LE PASO EL SALDO ACTUAL SI SON CEROS ESTA BIEN MEL */
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgsdo_actual;
    END IF;

    if vgpaga_interes = "S" then
        call calcula_int(pempresa,pdias,vsdo_prom)
        returning vcodret;

        IF vcodret <> "000" THEN
            return vcodret;
        END IF
    end if

    if vgsdo_disp < 0 then
        let vgsdo_disp = 0;
    end if

    /* COBRO DE COMISIONES A LAS CUENTAS QUE NO SON DE CORTESIA */
    if vclase_cta = "1" then
        select iva
          into viva
          from bdinteg:si_sucursales
         where empresa = pempresa
           and sucursal = vgsucursal;

        if viva is null then
            let viva = 0;
        end if

        let vhora = current hour to fraction;
        let vhoraw = vhora;
        let vhoraw = vhoraw[1,2] || vhoraw[4,5] || vhoraw[7,8] || vhoraw[10,11];
        let vfolio_suc = vgusuario || vhoraw[1,8];

        /* GENERA COMISIONES POR ANIVERSARIO */
        LET vcuantos = 12;

        WHILE vcuantos <= 120
            CALL sp_mes_siguiente(vgfecha_alta, vcuantos, day(vgfecha_alta))
            RETURNING vcodret, vfechaux, vnumdias;

            IF vfechaux = vgfecha_hoy THEN
                call gencomanv(pempresa,vgcuenta) returning vcodret;
                if vcodret <> "000" THEN
                    return vcodret;
                end if
                EXIT WHILE;
            ELIF vfechaux < vgfecha_hoy THEN
                LET vcuantos = vcuantos + 12;
            ELSE
                EXIT WHILE;
            END IF
        END WHILE;

        /* GENERA COMISIONES MENSUALES */
        call gencommes(pempresa,vgcuenta) returning vcodret;

        if vcodret <> "000" THEN
            return vcodret;
        end if

		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
		select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), com_pendiente
          into vgsdo_disp, vcom_pendiente
          from sc_maechq
         where empresa = pempresa
           and cuenta = vgcuenta;

        if vcom_pendiente > 0 and vgsdo_disp > 0 then
            call cobintcomsbg(pempresa,vgcuenta,vfolio_suc,vgusuario,vgsucursal)
            returning vcodret;

            if vcodret <> "000" THEN
                return vcodret;
            end if
			
			--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
			select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc)
              into vgsdo_disp
              from sc_maechq
             where empresa = pempresa
               and cuenta = vgcuenta;
        end if
    end if

    /* ACTUALIZA LOS ACUMULADOS DEL SALDO E INTERESES */
    UPDATE sc_maenoc
       SET dia_sdo_pos    = vgdia_sdo_pos,
           acum_sdo_pos   = vgacum_sdo_pos,
           dias_acum_int  = vgdias_acum_int,
           acum_sdo_int   = vgacum_sdo_int,
           capitalizacion = vgpago_interes,
           paga_interes   = vgpaga_interes
     WHERE empresa = pempresa
       AND cuenta = vgcuenta;

    update sc_tarjeta
       set disp_mes = 0
     where empresa = pempresa
       and cuenta  = vgcuenta
	   and secuencia > 0
	   and status_tar = "A";

    return vcodret;

    end

end procedure;