create procedure "informix".totcomp1(pusuario char(8), pnum_total smallint)
   returning char(5), char(2), money(16,2), money(16,2), char(40),
             integer, integer;

-- Definicion de Variables
define v_monto_cargo,
       v_monto_abono money(14,2);
define v_movto_cargo, v_movto_abono integer;
define v_descripcion char(40);
define v_contador    smallint;
define v_fecha       date;
define v_fechacomp   char(19);
define v_rowid       integer;
define v_codret      char(5);
define w_sucursal,
       w_plaza       char(3);
define v_producto    char(4);
define v_ciclo       smallint;
define v_moneda      char(2);
define sql_err,
       isam_err      integer;

let v_contador = 0;
let v_ciclo    = 0;
let v_moneda   = 0;
let v_monto_cargo = 0;
let v_monto_abono = 0;
let v_movto_cargo = 0;
let v_movto_abono = 0;
let v_codret      = "000";
let v_descripcion = " ";


   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret, v_moneda, v_monto_cargo, v_monto_abono,
            v_descripcion, v_movto_cargo, v_movto_abono;
         end if;
      end exception;

select fecha_hoy into v_fecha from bdicent:si_fechas;
delete from st_totcomp where usuario=pusuario;
LET v_fechacomp = v_fecha;
LET v_fechacomp = v_fechacomp[7,10]||"-"||v_fechacomp[1,2]||"-"||
                  v_fechacomp[4,5]||" 00:00:00";
-- Obtiene la inf. por el total de la Operacion sin incluir com. e iva.
foreach
   select count(*), sum(monto), moneda into
      v_movto_cargo, v_monto_cargo, v_moneda
      from bdicent:si_transacc, st_movdia, st_maetrans
      where num_transacc                   = bdicent:si_transacc.numero and
            bdicent:si_transacc.naturaleza = "C" and
            bdicent:si_transacc.realizada_por="1" and
            usuario                        = pusuario and
            st_movdia.tipo_docto           = st_maetrans.tipo_docto and
            st_movdia.num_docto            = st_maetrans.num_docto and
            st_movdia.num_cargo_cta        = st_maetrans.num_cargo_cta and
            st_movdia.fecha_hora           >= v_fechacomp
      group by moneda
   insert into st_totcomp values(pusuario, v_moneda, v_monto_cargo, 0,
          v_movto_cargo, 0);
end foreach;
foreach
   select count(*), sum(monto), moneda into
      v_movto_abono, v_monto_abono, v_moneda
      from bdicent:si_transacc, st_movdia, st_maetrans
      where num_transacc                   = bdicent:si_transacc.numero and
            bdicent:si_transacc.naturaleza = "A" and
            bdicent:si_transacc.realizada_por="1" and
            usuario                        = pusuario and
            (st_movdia.tipo_docto           = st_maetrans.tipo_docto or
            st_movdia.tipo_docto          <> "03") and
            st_movdia.num_docto            = st_maetrans.num_docto and
            st_movdia.fecha_hora           >= v_fechacomp
      group by moneda
      select rowid into v_rowid from st_totcomp
         where usuario = pusuario and
               moneda  = v_moneda;
      if v_rowid is not null then
         update st_totcomp
            set (monto_abono, movto_abono) = (v_monto_abono, v_movto_abono)
            where rowid = v_rowid;
      else
         insert into st_totcomp
            values(pusuario, v_moneda, 0, v_monto_abono, 0, v_movto_abono);
      end if
end foreach;
let v_monto_cargo = 0;
let v_monto_abono = 0;
let v_movto_cargo = 0;
let v_movto_abono = 0;
let v_moneda      = "00";
let v_codret      = "000";
let v_descripcion = " ";
-- Extrae sucursal y plaza
select sucursal into w_sucursal from bdicent:si_ejecut
where ejecutivo = pusuario;
select plaza into w_plaza from bdicent:si_sucursales
where sucursal = w_sucursal;
foreach
   select moneda, monto_cargo, monto_abono, descripcion,
   movto_cargo, movto_abono
   into v_moneda, v_monto_cargo, v_monto_abono, v_descripcion,
   v_movto_cargo, v_movto_abono
   from st_totcomp, bdicent:si_divisas
   where usuario = pusuario
   and bdicent:si_divisas.divisa = moneda
   order by moneda
   let v_ciclo = v_ciclo + 1;
   if v_ciclo <= pnum_total then
      continue foreach;
   end if
   return v_codret, v_moneda, v_monto_cargo, v_monto_abono, v_descripcion,
      v_movto_cargo, v_movto_abono with resume;
   let v_contador=v_contador+1;
end foreach;
end;          -- fin del on exception
end procedure;