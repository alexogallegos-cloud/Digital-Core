create procedure "informix".canc_cta_pba(pempresa char(3),
                              psucursal char (4),
                              pusuario char(8),
                              pfolio_suc char(16),
                              pcuenta char(20),
                              ptotint money(14,2),
                              pimpisr money(14,2),
                              ptotcanc money(14,2),
                              ptasa_bruta decimal(9,6),
                              pdivisa char(2),
                              pcodcanc char(2),
                              pcomcancta money(14,2))
        returning char(5);

 -- ********************************************************************
    -- Nombre:              canc_cta
    -- Version:             1.0.0
    -- Objetivo:            cancelacion de una cuenta de cheques 
    -- Supuestos:           Ninguno
    -- Creado por:
    -- Modificado por:      Alejandro Rueda Sanchez
    -- Ultima Modificacion: Febrero - 2010
    --                      Reingenieria de SPL
    -- ********************************************************************

--//DEFINICION DE VARIABLES
   define vcodret char(5);
   define band,status_w char (1);
   define sdoc_w money (14,2);
   define sdoa_w money (14,2);
   define vsdo_t1 money (14,2);
   define vfechoy,fecha_w date;
   define v_ctaeje char(20);
   define v_secolat smallint;
   define hora_w datetime hour to fraction(3);
   define sdo_cta_w money (14,2);
   define com_pen_w money (14,2);
   define sdo_ret_w,vsdodisp,vmontoret money (14,2);
   define w_totinv smallint;
   define w_totcre smallint;
   define vtranret char(4);
   define vtrancomcan,vtrancancta char(4);
   define producto_w char(4);
   define sucta_w char(4);
   define sql_err integer;
   define v_usuario char(8);
   define v_tasa_aplicada decimal(9,6);
   define v_referencia char(40);
   define vtraint, vtraisr char(4);
   define vpagintcancta char(1);
   define vtranrevprov char(4);
   define vint_acum money(14,2);
   define vnum_tarjeta char(16);
   define vmaxsec smallint;
   define val_cheque char(1);

   let vcodret ="000";
   let band = "";
   let status_w ="";
   let sdoc_w  =0;
   let sdoa_w  =0;
   let vsdo_t1  =0;
   let vfechoy = "";
   let fecha_w ="";
   let v_ctaeje ="";
   let v_secolat =0;
   let hora_w = current hour to fraction(3);
   let sdo_cta_w =0;
   let com_pen_w =0;
   let sdo_ret_w =0;
   let vsdodisp = 0;
   let vmontoret =0;
   let w_totinv =0;
   let w_totcre =0;
   let vtranret ="";
   let vtrancomcan = "";
   let vtrancancta ="";
   let producto_w ="";
   let sucta_w ="";
   let sql_err =0;
   let v_usuario ="";
   let v_tasa_aplicada ="";
   let v_referencia ="";
   let vtraint = "";
   let vtraisr ="";
   let vpagintcancta ="";
   let vtranrevprov ="";
   let vint_acum =0;
   let vnum_tarjeta ="";
   let vmaxsec =0;


begin
   on exception set sql_err
      if sql_err <> 0 then
         let vcodret = sql_err;
         return vcodret;
      end if
   end exception;

   --- Verifica recepcion completa de datos
   if psucursal = "" or
      pusuario = "" or
      pfolio_suc = " " or
      pcuenta = "" or
      pdivisa = " " then
         let vcodret = "110";
         return vcodret;
   end if;
   
   select ejecutivo into v_usuario
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;
   if v_usuario <> pusuario or v_usuario is null then
      let vcodret = "106";
      return vcodret;
   end if
   
   select valor into vtrancomcan
      from sc_param
      where empresa = pempresa and codparam = "trancomcan";
   
   select valor into vtrancancta
      from sc_param
      where empresa = pempresa and codparam = "trancancta";
   
   select valor into vtraint
      from sc_param
      where empresa = pempresa and codparam = "tranpagint";
   
   select valor into vtraisr
      from sc_param
      where empresa = pempresa and codparam = "tranisr";
   
   select status_cta,sdo_retenido, sdo_cong, saldo_sbc,
          sdo_actual, producto,sucursal
      into status_w,sdo_ret_w,sdoc_w,vsdo_t1,
          sdoa_w, producto_w,sucta_w
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   
   select sum(monto_com-pago_com) into com_pen_w
      from sc_detcomis
      where empresa = pempresa and cuenta = pcuenta;
   if com_pen_w is null then
      let com_pen_w = 0;
   end if
   
      if status_w is null then
         let vcodret = "100";
         return vcodret;
      elif status_w = "2" then
         let vcodret = "200";
         return vcodret;
      elif status_w = "3" then
            let vcodret = "303";
            return vcodret;
      elif sdoc_w != 0 or sdo_ret_w != 0 then
            let vcodret = "305";
            return vcodret;
       if vsdo_t1 <> 0 and vsdo_t1 is not null then
         let vcodret = "305";
         return vcodret;
      end if;
   
   --- Verifica que la cuenta no tenga adeudos pendientes
   --- o saldo actual menor a cero
      elif  sdoa_w < 0 then
             let vcodret = "306";
             return vcodret;
      end if;
   
   --- Verifica que la cuenta no este relacionada en Inversiones
      let w_totinv = 0;
      let band = "0";
      select "1" into band from bdinteg:si_sistema
         where siglas = "SV";
      if band = "1" then
         select count(*) into w_totinv
            from bdinvers:sv_maeinstrucc mi,bdinvers:sv_maeinv ma
            where mi.empresa = pempresa and mi.cta_cheques = pcuenta and
                  sistema = "01" and
                  ma.empresa = mi.empresa and ma.cuenta = mi.cuenta and
                  status_cta in("1", "3");
         if w_totinv > 0 then
            let vcodret = 160;
            return vcodret;
         end if
      end if
   
   --- Verifica que la cuenta no este relacionada en Credito
      let w_totcre = 0;
      let band = "0";
      select "1" into band from bdinteg:si_sistema
         where siglas = "SD";
      if band = "1" then
         select count(*) into w_totcre
            from bdicred:sd_ctascarg cc, bdicred:sd_maecred mc
            where cc.empresa = pempresa and num_cta = pcuenta and
                  tipo_cta = "2" and
                  cc.empresa = mc.empresa and mc.num_credito = cc.num_credito and
                  status_cred <> "5";
         if w_totcre > 0 then
            let vcodret = 161;
            return vcodret;
         end if;
      end if;
      select fecha_hoy into fecha_w
         from sc_fechas where empresa = pempresa;
      let hora_w = current hour to fraction;
      let v_referencia = ptasa_bruta;
      let v_tasa_aplicada = 0;
      select valor into vpagintcancta
         from sc_param
         where empresa = pempresa and codparam = "pagintcancta";
      if vpagintcancta = "N" then
         select int_acum into vint_acum
            from sc_maenoc
            where empresa = pempresa and cuenta = pcuenta;
         select valor into vtranrevprov
            from sc_param
            where empresa = pempresa and codparam = "tranrevprov";
         if vint_acum > 0 and vtranrevprov is not null then
            insert into sc_movdia
               values (0,pfolio_suc,psucursal,pusuario,fecha_w,
                       fecha_w,hora_w,vtranrevprov,sucta_w,producto_w,
                       pempresa,pcuenta, "",0,vint_acum,vint_acum,0,0,0,"","1",
                       sdoa_w,"0000"," ",0,vnum_tarjeta,"");
         end if
      end if
   
      select max(secuencia) into vmaxsec
         from sc_tarjeta
         where empresa = pempresa and cuenta = pcuenta and
               tipo_tarjeta = "T";
   
      select num_tarjeta into vnum_tarjeta
         from sc_tarjeta
         where empresa = pempresa and cuenta = pcuenta and
               secuencia = vmaxsec;
   
   --- Abono de Intereses
   if ptotint > 0 then
      call abono_ref(pempresa,psucursal,pusuario,vtraint,"0000",pfolio_suc,
                     pcuenta,0,ptotint,ptotint,0,0,0,pdivisa,v_referencia,
                     vnum_tarjeta,"")
           returning vcodret;
      if vcodret <> "000" then
         return vcodret;
      end if
   end if
   
   --- Cargo de ISR
   if pimpisr > 0 then
      call cargo_ref(pempresa,psucursal,pusuario,vtraisr,"0000",pfolio_suc,
                     pcuenta,0,pimpisr,pdivisa,v_referencia,vnum_tarjeta,"")
           returning vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
      if vcodret <> "000" then
         return vcodret;
      end if
   end if
   
   --- Cobro de comision x cancelacion anticipada
   if pcomcancta > 0 then
      call cargo_ref(pempresa,psucursal,pusuario,vtrancomcan,"0000",pfolio_suc,
                     pcuenta,0,pcomcancta,pdivisa,v_referencia,vnum_tarjeta,"")
           returning vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
      if vcodret <> "000" then
         return vcodret;
      end if
   end if
   
   --- Cargo por el Total de la Cancelacion
   if ptotcanc > 0 then
      call cargo_ref(pempresa,psucursal,pusuario,vtrancancta,"0000",pfolio_suc,
                     pcuenta,0,ptotcanc,pdivisa,v_referencia,vnum_tarjeta,"")
           returning vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
      if vcodret <> "000" then
         return vcodret;
      end if
   end if
    
   -- Verifica si el producto tiene chequeras
      SELECT val_chequeras
        INTO val_cheque
        FROM sc_producto
       WHERE empresa = pempresa
         AND producto = producto_w
         AND val_chequeras = "S"; 
   
   --- Actualiza la Tabla Maestro de Cheques
   update sc_maechq
      set status_cta = "2",
          fec_cancelac = fecha_w,
          motivo = pcodcanc
      where empresa = pempresa and cuenta = pcuenta;

-- //Realiza la cancelacion de todas las chequeras/cheques activos 
    IF val_cheque = "S" THEN
       CALL  bdicntchq:sp_actcanchequera (pempresa,pcuenta,3,0,0,pusuario)
       returning  vcodret;
    END IF
   
   select cuenta, secuencia into v_ctaeje, v_secolat
     from sc_colateral where empresa = pempresa and cta_col = pcuenta;

   if v_secolat is null or v_secolat=0 then
      delete from sc_colateral where empresa = pempresa and cuenta = pcuenta;
   else
      delete from sc_colateral where empresa = pempresa and cta_col = pcuenta;
      update sc_colateral
         set secuencia = secuencia - 1
         where empresa = pempresa and cuenta = v_ctaeje
               and secuencia > v_secolat;
   end if;
   let vcodret = "000";

return vcodret;
end
end procedure;