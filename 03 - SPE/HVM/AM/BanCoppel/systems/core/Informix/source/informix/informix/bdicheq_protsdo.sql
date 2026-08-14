create procedure "informix".protsdo(pempresa char(3),
                                    suc char(4),
                                    usuariox char(8),
                                    transaccion char(4),
                                    transacc_suc char(4),
                                    folsuc char(16),
                                    cta char(20),
                                    docto integer,
                                    pmonto_concilia money(14,2),
                                    divisa char(2),
                                    clave integer)

returning char(5),char(4);

    --##############################################################################
    --## Procedimiento       : protsdo
    --## Version             : 1.0.0
    --## Objetivo            : Conciliacion de movimientos intercar
    --## Supuestos           :
    --## Modificado por      : Alejandro Rueda Sanchez
    --## Fecha modificacion  : Agosto 2009 PISA
    --## Fecha modificacion  : 01/03/2010 JYDG
    --##############################################################################

    -- // Variables Globales conciliacion 
    DEFINE GLOBAL vg_estatus    VARCHAR(5)  DEFAULT " ";
    DEFINE GLOBAL vgrfc_comer   VARCHAR(20) DEFAULT " ";
    DEFINE GLOBAL vgreferencia  VARCHAR(40) DEFAULT " ";

    -- // Definicion de Variables
    define sql_err,isam_err int;
    define cod_ret char(5);
    define v_tiptran, v_tpcheque, v_moneda, motiv char(2);
    define ctar char(20);
    define v_valdoc,nat char(1);
    define valdoc char(1);
    define suc_cta char(4);
    define v_plaza char(3);
    define prod char(8);
    define horax char(12);
    define fechax date;
    define vfechacalendario date;
    define v_status,cargox char(1);
    define saldo,reten money(16,2);
    define monto_docret, v_montolib money(16,2);
    define v_long_cta,longitud smallint;
    define v_cal_int_chq char(1);
    define tranret char(4);
    define v_clave integer;
    define v_usuario char(8);
    define v_referencia char(40);
    define vnum_tarjeta char(16);
    define vmaxsec smallint;

    -- // Variables para conciliacion
    DEFINE vtamanio      SMALLINT;
    DEFINE vt_indicador  CHAR(1);
    DEFINE vt_newfolio   CHAR(16);
    DEFINE vt_folsucorig CHAR(16);

    DEFINE vstatus_cta CHAR(1);
    DEFINE vexiste CHAR(1);
    define vaceptab char(1);
    define vacepcargo char(1);

    LET sql_err = 0;
    LET isam_err = 0;
    LET v_tiptran = "";
    LET v_tpcheque= "";
    LET v_moneda ="";
    LET motiv = "";
    LET ctar = "";
    LET v_valdoc = "";
    LET nat = "";
    LET valdoc = "";
    LET suc_cta = "";
    LET v_plaza = "";
    LET prod = "";
    LET cod_ret = "000";
    LET horax = "";
    LET fechax = " ";
    LET vfechacalendario = "";
    LET v_status = "";
    LET cargox = "";
    LET saldo = 0;
    LET reten = 0;
    LET monto_docret= 0;
    LET v_montolib = 0;
    LET v_long_cta= 0;
    LET longitud = 0;
    LET v_cal_int_chq = "";
    LET tranret = "";
    LET v_clave = 0;
    LET v_usuario = "";
    LET v_referencia = "";
    LET vnum_tarjeta = "";
    LET vmaxsec = 0;

    LET vtamanio      = 0;
    LET vt_indicador  = "";
    LET vt_newfolio   ="";
    LET vt_folsucorig ="";

    let tranret = transaccion;

    begin

    on exception set sql_err
        if sql_err <> 0  then
            LET vg_estatus = vg_estatus::smallint + 5;
            let cod_ret = sql_err;
            return cod_ret,tranret;
        end if;
    end exception;

    --- SET DEBUG FILE TO "/home/informix/jydg/protsdo.out";
    --- TRACE ON;
    
    ---***********************************************************
    ---* Validacion de datos transmitidos a este Store Procedure *
    ---***********************************************************
    let saldo   = 0;
    let reten   = 0;
    let sql_err = 0;

    set isolation to dirty read;
    set lock mode to wait 3;

    if suc is null or usuariox is null or transaccion is null or
       cta is null or folsuc is null or docto is null or
       suc = "   " or usuariox = "   " or transaccion = "    " or
       cta = " " or folsuc = " " then
            let cod_ret = "110";
            let tranret = transaccion;
            return cod_ret,tranret;
    end if;

    select ejecutivo 
      into v_usuario 
      from bdinteg:si_ejecut
     where empresa = pempresa 
       and ejecutivo = usuariox;

    if v_usuario <> usuariox or v_usuario is null then
        let cod_ret = "106";
        let tranret = transaccion;
        return cod_ret,tranret;
    end if;

    if pmonto_concilia = 0 or pmonto_concilia is null then
        let cod_ret = "110";
        return cod_ret,tranret;
    end if;
    
    ---***************************************
    ---* Validacion del numero de Transaccion*
    ---***************************************
    select numero,naturaleza,valida_docto,tpcheque,tipo_tran
      into tranret,nat,v_valdoc,v_tpcheque,v_tiptran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = transaccion;
     
    if tranret is null then
        let tranret = "XXXX";
    end if;

    if transaccion != tranret then
        let cod_ret = "550";
        let tranret = transaccion;
        return cod_ret,tranret;
    end if;

    if nat != "C" then
        let cod_ret = "560";
        return cod_ret,tranret;
    end if;

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfechacalendario 
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta
      into fechax, vstatus_cta
      from sc_maechq
     where empresa = pempresa
       and cuenta = cta;

    if ( fechax is null or vstatus_cta = '4' or vstatus_cta = '5' ) then
        let fechax = vfechacalendario;
    end if

    if ( fechax < vfechacalendario ) then
        let cod_ret = "549";
        return cod_ret,tranret;
    end if
    
    if ( vstatus_cta in('2','6','7','8') ) then
        let cod_ret = "200";
        return cod_ret,tranret;
    end if
    
    -- // Busca el folio en docret
    select monto, referencia 
      INTO monto_docret, v_referencia
      FROM sc_docret
     WHERE empresa = pempresa
       AND cuenta = cta
       AND folio_suc = folsuc
       AND cancelado = "P";

    LET vtamanio = length(folsuc);
    LET folsuc = trim(folsuc);
    LET vt_folsucorig = trim(folsuc);
    LET vt_indicador = substr(folsuc,(vtamanio -6),1);

    -- // No encontro el folio en docret
    IF monto_docret = 0 OR monto_docret IS NULL THEN
        -- // Cambio el indicador por 1
        IF vt_indicador = '2' AND folsuc[1,8] = "intercar" THEN 
            LET vt_newfolio = substr(folsuc,1,vtamanio -7);
            LET vt_newfolio = trim(vt_newfolio)||"1"||substr(folsuc,vtamanio -5,vtamanio);
            LET folsuc = trim(vt_newfolio);
            
            -- // Realiza la busqueda con el nuevo folio
            SELECT monto,referencia 
              into monto_docret, v_referencia
              FROM sc_docret
             WHERE empresa = pempresa
               AND cuenta = cta
               AND folio_suc = folsuc
               AND cancelado = "P";
            
            -- // Forzada no encontrada como 2 ni 1...
            IF monto_docret = 0 OR monto_docret IS NULL THEN 
                LET vg_estatus = "3";
                LET folsuc = vt_folsucorig;
            -- // Forzada encontrada como 1..
            ELSE 
                LET vg_estatus = "2";
            END IF
        -- // Normal no encontrada....
        ELSE 
            LET vg_estatus = "1";
        END IF  
    -- // Si encontro el folio en docret...
    ELSE 
        -- // Normal encontrada como Normal
        IF vt_indicador = '1' THEN   
            LET vg_estatus = "0";    
        -- // Mismo folio que transaccion en linea..
        ELIF vt_indicador = '2' THEN
            LET vg_estatus = "4";
        ELSE
            LET vg_estatus = "99";
        END IF
    END IF  

    LET saldo    = 0;
    LET v_status = " ";
    LET ctar     = " ";
    LET v_montolib = 0;

    IF monto_docret IS NULL THEN
        LET monto_docret = 0;
    END IF;

    foreach cargo_cursor for
        select cuenta,sucursal,plaza,producto,status_cta,sdo_actual,sdo_retenido,motivo
          into ctar,suc_cta,v_plaza,prod,v_status,saldo,reten,motiv
          from sc_maechq
         where empresa = pempresa 
           and cuenta = cta

        select divisa 
          into v_moneda
          from sc_producto
         where empresa = pempresa 
           and producto = prod;
           
        if v_moneda != divisa then
            let cod_ret = "951";
            let tranret = transaccion;
            return cod_ret,tranret;
        end if;

        -- ******************************************
        -- Inicio de validaciones MAECHQ y BLOQUEO
        -- ******************************************
        if ctar is null then
            let ctar = "X";
        end if;

        if ctar = cta then
            let cod_ret = "000";
        else
            let cod_ret = "100";
            return cod_ret,tranret;
        end if;

        if v_status in ("2","6","7") then
            let cod_ret = "200";
            return cod_ret,tranret;
        elif v_status = "3" then
            IF transaccion <> '0830' AND transaccion <> '0887' THEN
                SELECT "1" 
                  INTO vexiste
                  FROM sc_ctabloqueo 
                 WHERE cuenta = ctar;

                IF vexiste = "1" THEN      
                    SELECT opcion 
                      INTO vaceptab
                      FROM sc_ctabloqueo 
                     WHERE cuenta = ctar;

                    IF vaceptab = 4 THEN
                        LET cod_ret = "300";
                        RETURN cod_ret,tranret;
                    END IF;

                    IF vaceptab = 3 THEN
                        LET cod_ret = "300";
                        RETURN cod_ret,tranret;
                    END IF;
                ELSE
                    select cargo 
                      into cargox 
                      from sc_bloqueo
                     where codigo = motiv;

                    if cargox = "N" then
                        let cod_ret = "300";
                        return cod_ret,tranret;
                    end if;
                END IF;
            END IF;
        end if;

        select max(secuencia) 
          into vmaxsec
          from sc_tarjeta
         where empresa = pempresa 
           and cuenta = cta 
           and tipo_tarjeta = "T";
           
        select num_tarjeta 
          into vnum_tarjeta
          from sc_tarjeta
         where empresa = pempresa 
           and cuenta = cta 
           and secuencia = vmaxsec;

        -- // Libera proteccion de saldo
        begin
        
        if monto_docret > 0 then
            -- // Monto en linea menor que conciliacion
            IF monto_docret < pmonto_concilia then
                LET vg_estatus = vg_estatus::smallint + 10;
            -- // Monto linea igual que la conciliacion
            ELIF monto_docret = pmonto_concilia THEN 
                LET vg_estatus = vg_estatus::smallint + 0;
            -- // Monto linea mayor  que la conciliacion
            ELSE 
                LET vg_estatus = vg_estatus::smallint + 20;
            END IF
            
            LET v_montolib = pmonto_concilia;
            let horax = current hour to fraction(3);
        end if
        
        end;
        
        if cod_ret = "000" then
            -- // Actualizacion del Maestro (se cambiar para que se libere el monto retenido)
            UPDATE sc_maechq
               SET (sdo_retenido) = (sdo_retenido - monto_docret)
             WHERE empresa = pempresa 
               AND cuenta = cta;

            if v_tpcheque = "01" then
                -- // Libera documento, para efectuar el cargo
                update {+INDEX(sc_histch idx_histch1)} sc_histch
                   set estado = " ",
                       importe = 0
                 where empresa = pempresa 
                   and cuenta = cta 
                   and numero = docto;
            end if
            
            -- // Marca documento retenido
            update sc_docret
               set cancelado = "S",
                   monto = monto - v_montolib
             where empresa = pempresa
               and cuenta = cta
               and folio_suc = folsuc
               and cancelado = "P";
               
            LET v_referencia = vgrfc_comer || vgreferencia;
            
            -- // Registra movimiento de retiro
            call cargon_ref(pempresa, suc, usuariox, transaccion, transacc_suc, folsuc, cta, 
                            docto, pmonto_concilia, v_moneda, v_referencia, vnum_tarjeta, "")
            returning cod_ret, tranret;
        end if
            
        return cod_ret, tranret;
    
    end foreach;

    end

end procedure;