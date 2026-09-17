create procedure "informix".traspaso(pempresa char(3),
                          pfecha_hoy date,pcambio decimal(14,7))
returning char(5);

define v_cuantos         integer;
define trempresa         char(3);
define trsecuencia       integer;
define trccmayor         char(4);
define trccsub           char(2);
define trccsubsub        char(2);
define trccssubsub       char(2);
define trccsssubsub      char(2);
define trccmayor_c       char(4);
define trccsub_c         char(2);
define trccsubsub_c      char(2);
define trccssubsub_c     char(2);
define trccsssubsub_c    char(2);
define trccmayor_t       char(4);
define trccsub_t         char(2);
define trccsubsub_t      char(2);
define trccssubsub_t     char(2);
define trccsssubsub_t    char(2);
define detusuario          char(8);
define detcontrol_poliza   smallint;
define detfecha_captura    date;
define detsecuencia        integer;
define detempresa          char(3);
define detccmayor          char(4);
define detccsub            char(2);
define detccsubsub         char(2);
define detccssubsub        char(2);
define detccsssubsub       char(2);
define detsector           char(2);
define detciudad           char(3);
define detsucursal         char(4);
define detnro_auxiliar     char(9);
define detnaturaleza       char(1);
define detmonto            money(18,2);
define detdescripcion_det  char(30);
define detfecha_valida     date;
define detmoneda           char(2);
define detvalor_cambio     money(12,7);
define detvalor_div_camb money(12,7);
define detmca_aplic        char(1);
define detpoliza_usuario   char(8);
define dettipo_mov         char(1);
define wnat              char(1);
define wsec              integer;
define dolares           money(18,2);
define wsec2             integer;
define maxpol            integer;
define maxdetpol         integer;
define wcontpol2         integer;
define wcontpol          integer;
define lv_contpol        integer;
define rr                char(1);
define cod_ret           char(5);


let cod_ret = "000";

select count(*)
into v_cuantos
from co_contproc
where proceso = "traspasos"
and fecha = pfecha_hoy
and empresa = pempresa;

if v_cuantos > 0 then
   foreach
      select control_poliza
      into lv_contpol
      from co_poliza
      where usuario = "informix"
      and fecha_captura = pfecha_hoy
      and descripcion = "TRASPASO DE CUENTAS DDL A MN"

      delete from co_poliza
      where empresa = pempresa
      and usuario = "informix"
      and control_poliza = lv_contpol
      and fecha_captura = pfecha_hoy;

      delete from co_detpol
      where usuario = "informix"
      and control_poliza = lv_contpol
      and fecha_captura = pfecha_hoy
      and empresa = pempresa;
   end foreach
end if

select max(control_poliza)
into maxdetpol
from co_detpol
where usuario = "informix"
and fecha_captura = pfecha_hoy
and empresa = pempresa;

if (maxdetpol is null) then
   let maxdetpol = 0;
end if

select max(control_poliza)
into maxpol
from co_poliza
where usuario = "informix"
and fecha_captura = pfecha_hoy;

if (maxpol is null) then
   let maxpol = 0;
end if

if (maxpol > maxdetpol) then
   let wcontpol = maxpol;
else
   let wcontpol = maxdetpol;
end if

let wcontpol = wcontpol + 1;
let wcontpol2 = wcontpol + 1;

insert into co_poliza
values (pempresa,"informix", wcontpol, pfecha_hoy, 0, 0, 0, "02",
        "TRASPASO DE CUENTAS DDL A MN");

insert into co_poliza
values (pempresa,"informix", wcontpol2, pfecha_hoy, 0, 0, 0, "01",
	"TRASPASO DE CUENTAS DDL A MN");

foreach
   select *
   into trempresa,
        trsecuencia,
        trccmayor,
        trccsub,
        trccsubsub,
        trccssubsub,
        trccsssubsub,
        trccmayor_c,
        trccsub_c,
        trccsubsub_c,
        trccssubsub_c,
        trccsssubsub_c,
        trccmayor_t,
        trccsub_t,
        trccsubsub_t,
        trccssubsub_t,
        trccsssubsub_t
   from co_mapeo_compra
   where empresa = pempresa

   select max(secuencia)
   into wsec
   from co_detpol
   where usuario = "informix"
   and control_poliza = wcontpol
   and fecha_captura = pfecha_hoy
   and moneda = "02"
   and empresa = pempresa;

   if (wsec is null) then
      let wsec = 0;
   end if

   select max(secuencia)
   into wsec2
   from co_detpol
   where usuario = "informix"
   and control_poliza = wcontpol2
   and fecha_captura = pfecha_hoy
   and moneda = "01"
   and empresa = pempresa;

   if (wsec2 is null) then
      let wsec2 = 0;
   end if

   -- obtiene informacion de la poliza para dolares
   foreach
      select *
      into  detusuario,
            detcontrol_poliza,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detccmayor,
            detccsub,
            detccsubsub,
            detccssubsub,
            detccsssubsub,
            detsector,
            detciudad,
            detsucursal,
            detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
            detvalor_cambio,
            detvalor_div_camb,
            detmca_aplic,
            detpoliza_usuario,
            rr
      from co_detpol
      where usuario = "informix"
      and fecha_captura =  pfecha_hoy
      and ccmayor = trccmayor
      and moneda = "02"
      and empresa = pempresa
      order by secuencia

      if (detnaturaleza = "D") then
    	    let wnat = "C";
      else
         let wnat = "D";
      end if
      let wsec = wsec + 1;

      insert into co_detpol
      values ("informix", wcontpol, pfecha_hoy, wsec, pempresa,
       trccmayor_c, trccsub_c, trccsubsub_c,
       trccssubsub_c, trccsssubsub_c,
       "00", detciudad, detsucursal, " ",
       detnaturaleza, detmonto, detdescripcion_det,
       pfecha_hoy, "02", pcambio, pcambio, "N", "099",
       detnaturaleza);
      let detnaturaleza = wnat;
      let wsec = wsec + 1;
      let detsecuencia = wsec;
      let detfecha_captura = pfecha_hoy;
      let detcontrol_poliza = wcontpol;
      insert into co_detpol values (detusuario,
                                    detcontrol_poliza,
                                    detfecha_captura,
                                    detsecuencia,
                                    detempresa,
                                    detccmayor,
                                    detccsub,
                                    detccsubsub,
                                    detccssubsub,
                                    detccsssubsub,
                                    detsector,
                                    detciudad,
                                    detsucursal,
                                    detnro_auxiliar,
                                    detnaturaleza,
                                    detmonto,
                                    detdescripcion_det,
                                    detfecha_valida,
                                    detmoneda,
                                    detvalor_cambio,
                                    detvalor_div_camb,
                                    detmca_aplic,
                                    "099",rr);
      let wsec = wsec + 1;

      if (detnaturaleza = "D") then
         let wnat = "C";
      else
         let wnat = "D";
      end if

      let dolares = detmonto;
      let detmonto = detmonto * pcambio;
      insert into co_detpol
      values
      ("informix", wcontpol2, pfecha_hoy,wsec , pempresa ,
       trccmayor_t, trccsub_t, trccsubsub_t,
       trccssubsub_t, trccsssubsub_t,
       "00", detciudad, detsucursal, " ",
       detnaturaleza, detmonto, detdescripcion_det,
       pfecha_hoy, "01", pcambio, pcambio, "N", "099",
       detnaturaleza);

      let detnaturaleza = wnat;
      let wsec = wsec + 1;
      let detsecuencia = wsec;
      let detmoneda = "01";
      let detcontrol_poliza = wcontpol2;
      insert into co_detpol values (detusuario,
                                    detcontrol_poliza,
                                    detfecha_captura,
                                    detsecuencia,
                                    detempresa,
                                    detccmayor,
                                    detccsub,
                                    detccsubsub,
                                    detccssubsub,
                                    detccsssubsub,
                                    detsector,
                                    detciudad,
                                    detsucursal,
                                    detnro_auxiliar,
                                    detnaturaleza,
                                    detmonto,
                                    detdescripcion_det,
                                    detfecha_valida,
                                    detmoneda,
                                    detvalor_cambio,
                                    detvalor_div_camb,
                                    detmca_aplic,
                                    "099",rr);
   end foreach
   select sum(monto)
   into detmonto
   from co_detpol
   where usuario = "informix"
   and fecha_captura = pfecha_hoy
   and control_poliza = wcontpol
   and moneda = "02"
   and naturaleza = "C"
   and empresa = pempresa;

   if detmonto is null then
      let detmonto = 0;
   end if

   update co_poliza
   set cifra_control = detmonto,
       capturado_cargo = detmonto,
       capturado_abono = detmonto
   where empresa = pempresa
   and usuario = "informix"
   and fecha_captura = pfecha_hoy
   and control_poliza = wcontpol
   and moneda = "02";

   select sum(monto)
   into detmonto
   from co_detpol
   where empresa = pempresa
   and usuario = "informix"
   and fecha_captura = pfecha_hoy
   and control_poliza = wcontpol2
  and moneda = "01"
and naturaleza = "C";

if detmonto is null then
   let detmonto = 0;
end if

update co_poliza
set cifra_control = detmonto,
    capturado_cargo = detmonto,
    capturado_abono = detmonto
where empresa = pempresa
and usuario = "informix"
and fecha_captura = pfecha_hoy
and control_poliza = wcontpol2
and moneda = "01";
end foreach
return cod_ret;
end procedure;