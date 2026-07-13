CREATE PROCEDURE "informix".apertura( pempresa 	     char(3),
                                      pnumcte         char(20),
                                      psecuencia      smallint,
                                      pinstrumento    char(4),
                                      ppromotor       char(8),
                                      ptipo_banca     char(3),
                                      psucursal       char(4),
                                      pplaza          char(3),
                                      preg_firmas     char(1),
                                      penvio          char(1),
                                      popcion_ret     char(2),
                                      pespecial       char(1),
                                      pnum_autorizac  char(13),
                                      pdias           smallint,
                                      pfecha_venc     date,
                                      pcapital        money(14,2),
                                      pper_acred      char(1),
                                      ptasa_instrum   char(8),
                                      pusuario        char(8),
                                      pdeposito       char(1),
                                      pcta_cheques    char(20),
                                      i_num_invers    char(20),
                                      pptos_adicional decimal(6,4),
                                      pdirecc_envio   smallint,
                                      pcobraisr       char(1) )
returning char(5),char(20),char(5),date,money(14,2),money(14,2),
          decimal(9,6),decimal(9,6),decimal (9,6);
    
    -- Define variables
    define vcodret 				char(5);
    define v_puntos_isr 				char(1);
    define v_ajustar,band,dig,vw_es_fisica,
          w_inserta,sw2,v_per_acred_int,
          ve_aplicado,b_grabar,vc_reg_firmas,
          vc_envio,v_exento_isr 		char(1);
    define ve_capital 				money(14,2);
    define v_cod_instrum  			char(4);
    define v_tp_persona,v_vcodretiro,v_fecha1,
          v_fecha2,v_plazo 			char(2);
    define v_cod_banca,v_codigo,v_plaza,cod,cod_tasaprom,
          vc_tipo_banca 			char(3);
    define v_sucursal,vc_sucursal 		char(4);
    define vw_dias 				char(5);
    define vwdias,vplazomin,vplazomax 		smallint;
    define vtrans_vtopas1,v_transacc 		char(4);
    define v_userapl,v_usuario 			char(8);
    define v_ult,vcve_autorizac 			integer;
    define vc_promotor 				char(8);
    define v_num_cte,vc_num_cte 			char(20);
    define v_rowx 				integer;
    define v_num_invers,v_cuenta,x_cuenta 	char(20);
    define v_folio 				char(16);
    define i,v_dia1,v_dia2 			smallint;
    define v_apell_paterno,v_apell_materno,
          v_nombre1,v_nombre2 			char(12);
    define v_nomeje 				char(45);
    define temp2 				int;
    define v_nombre_eje 				char(40);
    define v_rend_neto,v_imp_isr,v_mto_minimo,
          vw_tot_int,vw_isr 			money(14,2);
    define temp,ve_rowid,v_id_prom 			integer;
    define v_de_dia,v_a_dia,cant_dias 		smallint;
    define v_tasa_bruta,v_tasa_isr,v_tasa_isr2,
          v_tasa_neta,valor_tasa,val,
          ve_tasa,ve_sobretasa,val_tasa_esp,
          vtasa_base 				decimal(9,6);
    define v_fecha_venc,vw_fecha,v_fecha_hoy,
          v_prox_fecha,v_fecha_rec,
          vw_fecha_hoy,vw_fecha_hoy2 		date;
    define v_fech_hor 				datetime hour to fraction(3);
    define sql_err 				integer;
    define isam_err 				integer;
    define vlongcta,vdiferencia,vconsec 		smallint;
    define v_ptos_adicional 			decimal(4,2);
    define v_vigencia 				smallint;
    define v_porclinea 				decimal(5,2);
    define v_genlinea 				char(1);
    define v_stasasbg 				decimal(9,6);
    define v_tasasbg  				char(8);
    define v_tipolinea 				char(2);
    define v_monto_linea 			money(16,2);
    define v_fecvig 				date;
    define wdias 				smallint;
    define wrevisa_tasa 				char(1);
    define wplazo   				smallint;
    define pnum_dias_int 			smallint;
    define vtipocte1,vtipocte2,vtipocte3,
          vtipocte4,vtipocte5 			char(1);
    define vtpper_valida,vtipo_cliente 		char(1);
    define vtpcte_valido 			char(5);
    define vsignumcta 				integer;
    define vdigverif 				char(1);
    define vanio 				integer;
    define vresiduo 				integer;
    define vaniobase 				integer;
    
    define vind_dispon      char(1);
    
    set lock mode to wait 3;
    set isolation to dirty read;
    
    begin
    
    on exception set sql_err
     let vcodret = sql_err;
         return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,
         v_rend_neto,val,v_tasa_isr,v_tasa_neta;
    end exception;
    
    --- set debug file to "/home/e97802948/apertura.out";
    --- trace on;
        
    -- Inicializa variables
    let vcodret      = "000";
    let v_num_invers = "0";
    let v_imp_isr    = 0;
    let v_rend_neto  = 0;
    let v_tasa_bruta = 0;
    let v_tasa_isr   = 0;
    let v_tasa_neta  = 0;
    let v_plazo      = 0;
    let vw_dias      = 0;
    let vwdias       = 0;
    let vw_tot_int   = 0;
    let vw_isr       = 0;
    let val          = 0;
    let valor_tasa   = 0;
    let ve_sobretasa = 0;
    let band         = " ";
    let sql_err      = 0;
    let isam_err     = 0;
    let wrevisa_tasa = " ";
    let vaniobase    = 365;
    let vind_dispon  = '0';
    
    select ind_disponible
      into vind_dispon
      from bdicheq:sc_fechas
     where empresa = pempresa;
     
    if vind_dispon = '0' then
        let vcodret = "027";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if;
   
    if pfecha_venc is null then
        let pfecha_venc  = " ";
    end if;
    
    -- Verifica parametros de entrada
    if pnumcte        is null or
       psecuencia        is null or
       pinstrumento     is null or
       ppromotor        is null or
       ptipo_banca      is null or
       psucursal        is null or
       preg_firmas      is null or
       penvio           is null or
       popcion_ret      is null or
       pespecial        is null or
       pnum_autorizac   is null or
       pcapital         is null or
       pper_acred       is null or
       pcapital = 0 or
       pusuario         is null then
        let vcodret = "110";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    select ejecutivo 
      into v_usuario 
      from bdinteg:"informix".si_ejecut
     where ejecutivo = pusuario;
     
    if v_usuario <> pusuario or v_usuario is null then
        let vcodret = "107";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    let vcve_autorizac = pnum_autorizac;

    /* ######################################################################################################
    -- // Verifica si es apertura con cargo a cuenta de cheques,el sistema no haya cerrado ya operaciones
    if pcta_cheques <> " " then
        select fecha_hoy into vw_fecha_hoy
        from bdinteg:"informix".si_fechas
        where empresa = pempresa;

        select fecha into vw_fecha_hoy2
        from bdicheq:"informix".sc_contproc
        where empresa = pempresa and proceso = "cierre";

        -- Si la fecha del calendario es igual a la fecha del cierre no procede
        if vw_fecha_hoy = vw_fecha_hoy2 then
         let vcodret = "226";
         return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,
                v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if
    end if
    ###################################################################################################### */

    select plaza 
      into pplaza 
      from bdinteg:"informix".si_sucursales
     where empresa = pempresa 
       and sucursal=psucursal;
       
    if pplaza is null then
        let vcodret="102";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if;

    -- // Verifica el instrumento de la inversion
    select cod_instrum,ajustar_vencim,per_acred_int,mto_min_recom,
           trans_cap,trans_vtopas1,ptos_adicional,genera_linea,
           vigencia_a_partir,porcentaje_linea,revisa_tasa,num_dias_int,
           plazomin,plazomax,tpper_valida,tpcte_valido
      into v_cod_instrum,v_ajustar,v_per_acred_int,v_mto_minimo,
           v_transacc,vtrans_vtopas1,v_ptos_adicional,v_genlinea,
           v_vigencia,v_porclinea,wrevisa_tasa,pnum_dias_int,vplazomin,
           vplazomax,vtpper_valida,vtpcte_valido
      from "informix".sv_instrum
     where empresa = pempresa 
       and cod_instrum = pinstrumento;

    if v_cod_instrum is null then
        let vcodret = "105";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if
    
    IF psecuencia = 1 THEN 
        if pdias between vplazomin and vplazomax then
            ------------------------------------
        else
            let vcodret = "115";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if
    END IF;

    if pper_acred <> "" then
        let v_per_acred_int = pper_acred;
    else
        let pper_acred = v_per_acred_int;
    end if

    -- // Verifica los puntos adicionales
    if v_ptos_adicional is null OR v_ptos_adicional = "" then
        let v_ptos_adicional = 0;
    end if

    if pptos_adicional > v_ptos_adicional then
        let vcodret = "250";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    if v_transacc is null then
        let vcodret = "178";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    if v_per_acred_int !="M" and pfecha_venc is null then
        let vcodret="110";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    if v_per_acred_int !="M" and pdias is null then
        let vcodret="110";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- Verifica el regimen de firmas de la inversion
    if preg_firmas != "1" and preg_firmas != "2" and preg_firmas !="3" then
        let vcodret = "108";
        return vcodret,v_num_invers,vw_dias,pfecha_venc, v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if
    
   -- Verifica la forma de envio de correspondencia de la inversion
    if penvio != "0" and penvio != "1" then
        let vcodret = "109";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- Extrae las fechas del sistema
    select fecha_hoy,prox_fecha 
      into v_fecha_hoy,v_prox_fecha
      from "informix".sv_fechas 
     where empresa = pempresa;
     
    if v_fecha_hoy is null then
        let vcodret = "129";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    let vanio = year(v_fecha_hoy);
    let vresiduo = mod(vanio, 4);
    
    if vresiduo = 0 then
        let vaniobase = 366;
    end if

    -- Verifica fecha de vencimiento no sea menor a fecha de apertura
    if pfecha_venc < v_fecha_hoy then
        let vcodret = "116";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if
    
   -- Verifica si es tasa especial y si es valida
    if pespecial = "S" then
        select rowid,tasa,sobretasa,capital,aplicado
          into ve_rowid,ve_tasa,ve_sobretasa,ve_capital,ve_aplicado
          from "informix".sv_autorizacion
         where empresa = pempresa 
           and clave = vcve_autorizac 
           and instrumento = pinstrumento;

        -- // Numero de autorizacion de tasa especial no existe
        if ve_rowid is null then
            let vcodret = "130";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        else
            -- // Numero de autorizacion de tasa especial ya fue aplicado
            if ve_aplicado = "S" then
                let vcodret = "131";
                return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
            else
                -- // Capital no es igual al autorizado
                if  pcapital != ve_capital then
                    let vcodret = "136";
                    return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
                else
                    let val_tasa_esp = ve_tasa + ve_sobretasa;
                end if
            end if
        end if
   end if

    -- Verifica el numero de cliente de la inversion
    select numcte,tpo_persona,tipo_cliente
      into v_num_cte,v_tp_persona,vtipo_cliente
      from bdinteg:"informix".si_cliente
     where numcte = pnumcte;
     
    if v_num_cte is null then
        let vcodret = "106";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- // Determina el tipo de persona
    select es_fisica,exento_isr 
      into vw_es_fisica,v_exento_isr
      from bdinteg:"informix".si_tipper 
     where tpo_persona = v_tp_persona;

    -- // Valida el tipo de persona permitido
    if vw_es_fisica = "N" and vtpper_valida = "1" then
        let vcodret = "020";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,val,v_tasa_isr,v_tasa_neta;
    end if

    -- // Valida el tipo de cliente permitido
    IF psecuencia = 1 THEN 
        let vtpcte_valido = rpad(trim(vtpcte_valido),5,"X");
        let vtipocte1 = substr(vtpcte_valido,1,1);
        let vtipocte2 = substr(vtpcte_valido,2,1);
        let vtipocte3 = substr(vtpcte_valido,3,1);
        let vtipocte4 = substr(vtpcte_valido,4,1);
        let vtipocte5 = substr(vtpcte_valido,5,1);

        if vtipo_cliente <> vtipocte1 and vtipo_cliente <> vtipocte2 and
           vtipo_cliente <> vtipocte3 and vtipo_cliente <> vtipocte4 and
           vtipo_cliente <> vtipocte5 then
            let vcodret = "021";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,val,v_tasa_isr,v_tasa_neta;
        end if
    END IF

    -- Verifica el tipo de banca de la inversion
    select banca 
      into v_cod_banca
      from bdinteg:"informix".si_tpbanca
     where banca = ptipo_banca;
     
    if v_cod_banca is null then
        let vcodret = "111";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- Verifica el promotor de la inversion
    select ejecutivo,sucursal 
      into v_userapl,v_sucursal
      from bdinteg:"informix".si_ejecut
     where ejecutivo = ppromotor;
     
    if v_userapl is null then
        let vcodret = "107";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
   end if
    
    -- Verifica la sucursal de la inversion
    select sucursal,plaza 
      into v_codigo,v_plaza
      from bdinteg:"informix".si_sucursales
     where sucursal = psucursal;
     
    if v_codigo is null then
        let vcodret = "112";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- Verifica si debe tener opcion de retiro en base a si el instrumento es un Preestablecido
    if v_per_acred_int = "M" and pdias is null  then
        select vcodretiro,dia1,dia2,fecha1,fecha2
          into v_vcodretiro,v_dia1,v_dia2,v_fecha1,v_fecha2
          from "informix".sv_opcretiro
         where empresa = pempresa 
           and vcodretiro = popcion_ret;
           
        if v_vcodretiro is null then
            let vcodret = "113";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if
        let vw_dias     = " ";
   end if
    
    -- Verifica/Determina la fecha de vencimiento de la inversion
    call "informix".val_fecha(pempresa,pfecha_venc,v_ajustar) 
    returning cod,vw_fecha;
    
    let pfecha_venc = vw_fecha;
    let vwdias = pfecha_venc - v_fecha_hoy;
    let vw_dias = vwdias;
    
    -- Verifica el capital de la inversion contra parametros establecidos
    IF psecuencia = 1 THEN 
        if pcapital < v_mto_minimo then
            let vcodret = "117";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if
    END IF;
    
    -- Valida la Longitud a Considerar para el Numero de Cuenta
    select valor 
      into vlongcta
      from "informix".sv_param
     where empresa = pempresa 
       and codparam = "longcta";
       
    if vlongcta is null then
        let vcodret = "107";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if;

    if i_num_invers is null or i_num_invers = " " then
        select valor 
          into vsignumcta
          from "informix".sv_param
         where empresa = pempresa 
           and codparam = "signumcta";
           
        update "informix".sv_param
           set valor = vsignumcta + 1
         where empresa = pempresa 
           and codparam = "signumcta";
           
        let i_num_invers = vsignumcta;
        let vdiferencia = vlongcta - length(i_num_invers) - 2;
        
        if vdiferencia > 0 then
            for i = 1 to vdiferencia
                let i_num_invers = "0" || i_num_invers;
            end for;
        end if
        
        let i_num_invers = "3"||trim(i_num_invers);
        
        call "informix".digver11(i_num_invers)
        returning vcodret, vdigverif;
        
        let i_num_invers = trim(i_num_invers)||vdigverif;
    end if
    
    select cuenta 
      into x_cuenta
      from "informix".sv_maeinv
     where empresa = pempresa 
       and cuenta = i_num_invers 
       and secuencia = psecuencia;
       
    let v_num_invers = i_num_invers;
    
    if x_cuenta = i_num_invers then
        let vcodret = "148";
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        
    -- // Se quita validacion por que se le hace UPDATE al sv_maestrucc LALO 05mzo09
    /* ##################################################################################################################        
    else
        select unique cuenta 
          into x_cuenta 
          from sv_maeinstrucc
         where empresa = pempresa 
           and cuenta = i_num_invers;
           
        if x_cuenta = i_num_invers then
            let vcodret = "148";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if
    ################################################################################################################## */
    end if
    
    IF length(v_num_invers) = vlongcta and bdinteg:"informix".val_num(v_num_invers) then --*****se agraga validacion para longitud de la cuenta***
        -- Verifica si la fecha fue ajustada por dias feriados
        delete from "informix".sv_dias
         where empresa = pempresa 
           and cuenta = v_num_invers;

        insert into "informix".sv_dias values(pempresa,v_num_invers,pdias," ",0);
        
        -- Determina el calculo de intereses de acuerdo al instrumento
        select tasa 
          into ptasa_instrum
          from "informix".sv_plazotasa
         where empresa = pempresa 
           and cod_instrum = pinstrumento 
           and plaza = pplaza 
           and plazo_min <= pdias 
           and plazo_max  >= pdias;

        if ptasa_instrum is null then
            let vcodret = "105";
            return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
        end if

        if pcobraisr <> "" then
            if pcobraisr = "S" then
                let v_exento_isr = "N";
            else
                let v_exento_isr = "S";
            end if
        end if

        select valor 
          into v_tasa_isr
          from bdinteg:"informix".si_fechavalor
         where empresa = pempresa 
           and tasa = "I.S.R." 
           and fecha in ( select max(fecha) from bdinteg:si_fechavalor where empresa = pempresa and tasa = "I.S.R." );
        
        -- // Valida si es Tasa Especial
        if pespecial = "S" then
            let cod = "000";
            let val = ve_tasa + ve_sobretasa;
        else
            let ve_sobretasa = 0;
            
            if vw_es_fisica = "S" then
                let v_tp_persona = "F ";
            else
                let v_tp_persona = "M ";
            end if


            --validar tasas promocionales
            call sp_obtenertasa_prom(psucursal, pdias, pcapital, pnumcte, i_num_invers, psecuencia)
            returning cod_tasaprom, val, v_id_prom;


            IF cod_tasaprom != '000' THEN
                -- // Realiza calculo de intereses de acuerdo a la tasa del plazo
                call "informix".calc_tasa(pempresa,ptasa_instrum,v_tp_persona,pcapital)
                returning cod,val;
            END IF;
            
            let val = val + pptos_adicional;
            let ve_sobretasa = pptos_adicional;
        end if
        
        let valor_tasa = val /100;
        LET wplazo = vw_dias;
        
        IF (v_per_acred_int = "F" and wrevisa_tasa = "S") THEN
            LET vw_dias = wdias;
        END IF
        
        let vw_tot_int = pcapital * valor_tasa / pnum_dias_int * vw_dias;

        -- // Verifica si no es exento de ISR
        if v_exento_isr = "n" or v_exento_isr = "N" then
            -- // Realiza el calculo de ISR sin registrarlo en la tabla
            let w_inserta = "0";
            let vw_isr = pcapital * v_tasa_isr/100/vaniobase * vw_dias;
            
            if vw_isr is null then
                let vw_isr = 0;
            end if
            
            let v_imp_isr    = vw_isr;
            let v_tasa_neta  = val - v_tasa_isr;
            let val          = val - ve_sobretasa;
            let v_tasa_bruta = val;
        else
            let v_tasa_isr   = 0;
            let vw_isr       = 0;
            let v_imp_isr    = 0;
            let v_tasa_neta  = val;
            let v_tasa_bruta = val;
        end if
    
        -- // Determina rendimiento neto
        let v_rend_neto = vw_tot_int - vw_isr;
        
        -- Graba en el Maestro de Inversiones
        let val = val - pptos_adicional;
        let v_num_invers = v_num_invers;

        insert into "informix".sv_maeinv values(
            pempresa,                       -- Empresa
            v_num_invers,                   -- Numero inversion (docto)
            psecuencia,                     -- Secuencia de la inversion
            pinstrumento,                   -- Instrumento de la inversion
            v_num_cte,                      -- Numero de Cliente
            "0",                            -- Status Pend de deposito
            "  ",                           -- Motivo del bloqueo
            v_fecha_hoy,                    -- Fecha de ultimo movimiento
            " ",                            -- Fecha de cancelacion
            v_fecha_hoy,                    -- Fecha de reinversion
            pcapital,                       -- Capital de la inversion
            0,                              -- Saldo retenido
            0,                              -- Saldo congelado
            wplazo,                         -- Plazo para la inversion
            pfecha_venc,                    -- Fecha de vencimiento
            popcion_ret,                    -- Opcion de retiro
            vw_tot_int,                     -- Intereses calculados
            vw_isr,                         -- ISR calculado
            val,                            -- tasa para calc int
            ve_sobretasa,                   -- Valor de la sobretasa
            0,                              -- Dia Sdo Positivo
            0,                              -- Acumulado Sdo Positivo
            0,                              -- Sdo Prom mes Anterior
            0,                              -- Saldo mes anterior
            0,                              -- Saldo del dia anterior
            0,                              -- Saldo al ultimo corte
            pusuario,                       -- Usuario que adiciono
            v_fecha_hoy,                    -- Fecha de alta
            " ",                            -- Fecha valor
            " ",                            -- Usuario que modifico
            " ",                            -- Fecha de modificacion
            pcta_cheques,                   -- Cuenta eje de cheques
            psucursal,                      -- Sucursal que administra
            pplaza,                         -- Plaza de la sucursal
            ppromotor,                      -- Promotor
            ptipo_banca,                    -- Tipo de banca
            preg_firmas,                    -- Regimen de firmas
            penvio,                         -- Envio de estado de cuenta
            pdirecc_envio,                  -- Direccion de envio
            pcobraisr,                      -- Cobra ISR
            pper_acred                      -- Periodo de pago de interes
        );
    else
        LET vcodret = "100";  -- SE MANDA MENSAJE AL USUARIO PARA INDICAR QUE HAY PROBLEMAS CON EL NUMERO DE CUENTA.
        return vcodret,v_num_invers,vw_dias,pfecha_venc,v_imp_isr,v_rend_neto,v_tasa_bruta,v_tasa_isr,v_tasa_neta;
    end if

    -- Si es tasa promocional guarda en bitacora de cuentas aperturadas con promociÃ³n (Administrador de Tasas)
	if cod_tasaprom = '000' then
		call sp_logapertura_prom(v_id_prom, v_num_invers)
		returning cod;
	end if;
    
    -- Actualiza la tasa especial como ya aplicada
    if pespecial = "S" then
        update "informix".sv_autorizacion
           set aplicado = "S"
         where rowid = ve_rowid;
    end if
    
   -- Genera Linea de Credito en Cuenta de Cheques
   if v_genlinea = "S" then
        if v_porclinea is null then
            let v_porclinea = 0;
        end if
        
        if v_vigencia is null then
            let v_vigencia = 0;
        end if
        
        let v_monto_linea = pcapital * v_porclinea / 100;
        let v_tipolinea = "2";
        let v_fecvig = v_fecha_hoy + v_vigencia;
        let v_stasasbg = 0;
        let v_tasasbg = "CUPOCE";
          
        if v_monto_linea > 0 then
            call bdicheq:"informix".li_ccc(pempresa,psucursal,pusuario,pcta_cheques,pfecha_venc,v_tipolinea,v_monto_linea,v_tasasbg,v_stasasbg,v_fecvig)
            returning vcodret;
        end if
    end if

    end;

    return vcodret,v_num_invers,wplazo,pfecha_venc,v_imp_isr,v_rend_neto,val,v_tasa_isr,val;
    
end procedure;