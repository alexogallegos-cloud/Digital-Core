create  procedure "informix".bloqueo_cta(pempresa char(3),
                              pcuenta char(20),
                              pmonto money(14,2),
                              pcodbloq char(2),
                              pfechabloq date,
                              pusuario char(8),
                              pclave char(5))
   returning char(5),char(5);
   define vcodret char(3);
   define vsucursal char(4);
   define vplaza char (3);
   define vproducto char (4);
   define vtipo_mov,vstatus_cta char (1);
   define vstatus_aux char (1);
   define vsdo_cong money (14,2);
   define vcapital money (14,2);
   define vfecha_hoy date;
   define vhora char(15);
   define vfolio char (16);
   define vtransacc,vclave char(4);
   define vmesdia char(4);
   define vsdo_retenido,vmonto_cong money(14,2);
   define vsdoxdesbloq,vimporte money(14,2);
   define vrowid integer;
   define vfecha date;
   define vsecuencia smallint;



let vcodret = "000";
let vclave = "0000";

--- Verifica recepcion completa de datos
if pfechabloq = "" or
   pcuenta = "" or
   pmonto = "" or
   pcodbloq = "" or pusuario = "" then
   let vcodret = 110;
   return vcodret,vclave;
end if;

   select sucursal,cod_instrum,status_cta,sdo_cong,capital,secuencia,
          sdo_retenido,plaza
      into vsucursal,vproducto,vstatus_cta,vsdo_cong,vcapital,vsecuencia,
          vsdo_retenido,vplaza
      from sv_maeinv
      where empresa = pempresa and cuenta = pcuenta and status_cta <> "4";

-- Verifica si la Cuenta Ya esta Bloqueada si el Monto es 0 es Inversion
   IF vstatus_cta = "3" AND pcodbloq <> "00" THEN
      let vcodret = 303;
      return vcodret,vclave;
   END IF

--- Verifica el Saldo a Congelar de la Cuenta
   if  pmonto > vcapital - vsdo_retenido - vsdo_cong and
       pcodbloq <> "00" then
       let vcodret = "162";
       return vcodret,vclave;
   end if

--- Verifica el Saldo a desbloquear de la Cuenta
   LET pmonto = pmonto;
   LET pcodbloq = pcodbloq;
   if  pmonto > vsdo_cong and pcodbloq = "00" then
       let vcodret = "163";
       return vcodret,vclave;
   end if

--- Verifica existencia de la Cuenta
   if vsucursal is null then
      let vcodret = 100;
      return vcodret,vclave;
   end if

   if vstatus_cta = "1" then
      if pcodbloq = "00" then
         let vcodret = "302";
         return vcodret,vclave;
      end if
   end if

--- Verifica que la cuenta no este cancelada
   if vstatus_cta = "2" then
      let vcodret = 200;
      return vcodret,vclave;
   end if

--- Verifica que la cuenta no haya sido bloqueada previamente
   if vstatus_cta = "3" then
      if pcodbloq != "00" then
         if pmonto >  vcapital - vsdo_retenido - vsdo_cong then
           let vcodret = 303;
           return vcodret,vclave;
         end if
      end if
   end if

   select fecha_hoy into vfecha_hoy
      from sv_fechas
      where empresa = pempresa;

   let vhora = current hour to fraction;

   let vfolio = trim(pusuario) || vhora[1,2] || vhora[4,5] || vhora[7,8] ||
                vhora[10,11];

--- Asigna el Status con el que quedara la Cuenta,de acuerdo al cod. recibido
if pcodbloq = "00" then
   let vstatus_aux = "1";
   let vtipo_mov = "D";
   let vmonto_cong = pmonto * -1;
   let vtransacc = "3354";
   if pmonto = vsdo_cong then
      let vstatus_aux = "1";
   else
      let vstatus_aux = "3";
   end if
else
   let vstatus_aux = "3";
   let vtipo_mov = "B";
   let vmonto_cong = pmonto;
   let vtransacc = "3353";
end if

let vmesdia = month(vfecha_hoy) || day(vfecha_hoy);
let vhora = vhora[4,5] || vhora[7,8];
if pcodbloq = "00" then
   let vclave = pclave;
else
   let vclave = vmesdia + vhora;
end if

insert into sv_histbloq
   values (pempresa,pcuenta,vtipo_mov,pcodbloq,pmonto,pusuario,vfecha_hoy,
           current hour to fraction,vclave,vtipo_mov,vfolio," ");
insert into sv_movdia
   values(pempresa,0,vfolio,vplaza,vsucursal,pusuario,vfecha_hoy,
          current hour to fraction,vtransacc,vsucursal,pcuenta,vsecuencia,
          vproducto,0,pmonto,pmonto,0,0," ",vcapital,"0000");
update sv_maeinv
   set (fec_cancelac,status_cta,motivo,sdo_cong) =
       (vfecha_hoy,vstatus_aux,pcodbloq,sdo_cong + vmonto_cong)
   where empresa = pempresa and cuenta = pcuenta and secuencia = vsecuencia;
if pcodbloq = "00" then
   if pclave <>  "" and pclave <> " " then
      update sv_histbloq
         set status_blo = vtipo_mov
         where empresa = pempresa and cuenta = pcuenta
               and clave = pclave and tipo_mov = "B";
   else
      let vsdoxdesbloq = pmonto;
      foreach
         select rowid,importe,fecha
            into vrowid,vimporte,vfecha
            from sv_histbloq
            where empresa = pempresa and cuenta = pcuenta and
                  tipo_mov = "B" and status_blo = "B"
            order by fecha
         if vimporte > vsdoxdesbloq then
            let vimporte = vimporte - vsdoxdesbloq;
         else
            let vimporte = vimporte;
         end if
         update sv_histbloq
            set status_blo = vtipo_mov,
                importe = vimporte
            where rowid = vrowid;
         let vsdoxdesbloq = vsdoxdesbloq - vimporte;
         if vsdoxdesbloq = 0 then
            exit foreach;
         end if
      end foreach
   end if
end if

let vcodret = "000";
return vcodret,vclave;
end procedure;