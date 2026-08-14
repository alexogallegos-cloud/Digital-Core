CREATE PROCEDURE "informix".gen_totaliz(pempresa char(3))
--****************************************************************************
define bpempresa         char(3);
define bpccmayor         char(10);
define bpccsub           char(10);
define bpccsubsub        char(10);
define bpccssubsub       char(10);
define bpccsssubsub      char(10);
define bpsector          char(10);
define bpciudad          char(3);
define bpsucursal        char(3);
define bpmoneda          char(2);
define bpmes_dia         char(10);
define bpsaldo_anterior  money(18,2);
define bpcargos_dia      money(18,2);
define bpabonos_dia      money(18,2);
define bpsaldo_actual    money(18,2);
define bptipo_cta        char(1);

define baccmayor         char(10);
define baccsub           char(10);
define baccsubsub        char(10);
define baccssubsub       char(10);
define baccsssubsub      char(10);
define basector          char(10);

define v_mayor           char(10);
define v_mayor1          char(1);
define v_mayor2          char(10);
define w_cuantos         integer;
define fecha_movto       DATE;

define v_len_may         smallint;
define v_len_s           smallint;
define v_len_ss          smallint;
define v_len_sss         smallint;
define v_len_ssss        smallint;
define v_len_sect        smallint;
define i                 smallint;

define v_cero_may        char(10);
define v_cero_s          char(10);
define v_cero_ss         char(10);
define v_cero_sss        char(10);
define v_cero_ssss       char(10);
define v_cero_sect       char(10);
define v_cero_may_1      char(10);
define v_cero_may_2      char(10);


select len_may  ,len_s  ,len_ss  ,len_sss  ,len_ssss  ,len_sect
into   v_len_may,v_len_s,v_len_ss,v_len_sss,v_len_ssss,v_len_sect
from   co_param
where  empresa = pempresa;

let v_cero_may   = "";
let v_cero_s     = "";
let v_cero_ss    = "";
let v_cero_sss   = "";
let v_cero_ssss  = "";
let v_cero_sect  = "";
let v_cero_may_1 = "";
let v_cero_may_2 = "";

for i = 1 to v_len_may
   let v_cero_may   = TRIM(v_cero_may) || "0";
end for;

let v_cero_may = v_cero_may;

for i = 1 to v_len_s
   let v_cero_s     = TRIM(v_cero_s) || "0";
end for;
for i = 1 to v_len_ss
   let v_cero_ss    = TRIM(v_cero_ss) || "0";
end for;
for i = 1 to v_len_sss
   let v_cero_sss   = TRIM(v_cero_sss) || "0";
end for;
for i = 1 to v_len_ssss
   let v_cero_ssss  = TRIM(v_cero_ssss) || "0";
end for;
for i = 1 to v_len_sect
   let v_cero_sect  = TRIM(v_cero_sect) || "0";
end for;
for i = 2 to v_len_may
   let v_cero_may_1 = TRIM(v_cero_may_1) || "0";
end for;
for i = 3 to v_len_may
   let v_cero_may_2 = TRIM(v_cero_may_2) || "0";
end for;

FOREACH
   select *
   into
      bpempresa,
      bpccmayor,
      bpccsub,
      bpccsubsub,
      bpccssubsub,
      bpccsssubsub,
      bpsector,
      bpciudad,
      bpsucursal,
      bpmoneda,
      bpmes_dia,
      bpsaldo_anterior,
      bpcargos_dia,
      bpabonos_dia,
      bpsaldo_actual,
      bptipo_cta
   from co_balprev
   where
      (saldo_dia_anterior <> 0 or cargos_dia <> 0 or abonos_dia <> 0 or
       saldo_actual <> 0)
   order by ccmayor desc, ccsub desc, ccsubsub desc,
       ccssubsub desc, ccsssubsub desc, sector desc, moneda desc,
       mes_dia


   let baccmayor = bpccmayor;
   let baccsub = bpccsub;
   let baccsubsub = bpccsubsub;
   let baccssubsub = bpccssubsub;
   let baccsssubsub = bpccsssubsub;
   let basector = bpsector;


   -- ENCABEZADO PRIMER NIVEL
   let v_mayor = bpccmayor[1,1]||TRIM(v_cero_may_1);
   let v_mayor1 = bpccmayor[1,1];
   select count(*) into w_cuantos from co_balprev
   where empresa    = bpempresa and
         ccmayor    = v_mayor and
         ccsub      = v_cero_s and
         ccsubsub   = v_cero_ss and
         ccssubsub  = v_cero_sss and
         ccsssubsub = v_cero_ssss and
         sector     = v_cero_sect and
         ciudad     = bpciudad and
         sucursal   = bpsucursal and
         moneda     = bpmoneda and
         mes_dia    = bpmes_dia;

   if w_cuantos = 0 then
      -- acumula saldos de totalizadoras
      select sum(saldo_dia_anterior),sum(cargos_dia),
      sum(abonos_dia), sum(saldo_actual)
      into bpsaldo_anterior,bpcargos_dia,
           bpabonos_dia,bpsaldo_actual
      from co_balprev
      where
            ccmayor[1,1] = v_mayor1
      and   ciudad       = bpciudad
      and   sucursal     = bpsucursal
      and   moneda       = bpmoneda
      and   tipo_cta     = "D"
      and   mes_dia      = bpmes_dia;

      let bpccmayor = v_mayor;
      let bpccsub = v_cero_s;
      let bpccsubsub = v_cero_ss;
      let bpccssubsub = v_cero_sss;
      let bpccsssubsub = v_cero_ssss;
      let bpsector = v_cero_sect;
      let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
      insert into co_balprev
      values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
             bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
             bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);

      -- regresa valores originales
      let bpccmayor  = baccmayor;
      let bpccsub  = baccsub;
      let bpccsubsub  = baccsubsub;
      let bpccssubsub  = baccssubsub;
      let bpccsssubsub  = baccsssubsub;
      let bpsector  = basector;
   end if

   -- ENCABEZADO SEGUNDO NIVEL
   let v_mayor = bpccmayor[1,2]||TRIM(v_cero_may_2);
   let v_mayor2 = bpccmayor[1,2];
   select count(*) into w_cuantos from co_balprev
   where empresa    = bpempresa and
         ccmayor    = v_mayor and
         ccsub      = v_cero_s and
         ccsubsub   = v_cero_ss and
         ccssubsub  = v_cero_sss and
         ccsssubsub = v_cero_ssss and
         sector     = v_cero_sect and
         ciudad     = bpciudad and
         sucursal   = bpsucursal and
         moneda     = bpmoneda  and
         mes_dia    = bpmes_dia;

   if w_cuantos = 0 then
      select sum(saldo_dia_anterior),sum(cargos_dia),
             sum(abonos_dia), sum(saldo_actual)
      into bpsaldo_anterior,bpcargos_dia,
           bpabonos_dia,bpsaldo_actual
      from co_balprev
      where empresa      = bpempresa
      and   ccmayor[1,2] = v_mayor2
      and   ciudad       = bpciudad
      and   sucursal     = bpsucursal
      and   moneda       = bpmoneda
      and   tipo_cta     = "D"
      and   mes_dia      = bpmes_dia;

      let bpccmayor = v_mayor;
      let bpccsub = v_cero_s;
      let bpccsubsub = v_cero_ss;
      let bpccssubsub = v_cero_sss;
      let bpccsssubsub = v_cero_ssss;
      let bpsector = v_cero_sect;
      let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
      insert into co_balprev
      values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
             bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
             bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);

      -- regresa valores originales
      let bpccmayor  = baccmayor;
      let bpccsub  = baccsub;
      let bpccsubsub  = baccsubsub;
      let bpccssubsub  = baccssubsub;
      let bpccsssubsub  = baccsssubsub;
      let bpsector  = basector;
  end if

  -- Determina si se trata de una cuenta totalizadora
  -- cuarto nivel
  IF bpccmayor > v_cero_may and bpccsub > v_cero_s and
     bpccsubsub > v_cero_ss and bpccssubsub > v_cero_sss and
     bpccsssubsub > v_cero_ssss THEN

     -- sector cero cuarto nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = bpccssubsub and
           ccsssubsub = bpccsssubsub and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda  and
           mes_dia    = bpmes_dia;

     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa     = bpempresa and
              ccmayor     = bpccmayor and
              ccsub       = bpccsub and
              ccsubsub    = bpccsubsub and
              ccssubsub   = bpccssubsub and
              ccsssubsub  = bpccsssubsub and
              ciudad      = bpciudad and
              sucursal    = bpsucursal and
              moneda      = bpmoneda and
              mes_dia     = bpmes_dia and
              tipo_cta    = "D";

        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);

        -- regresa valores originales
        let bpsector  = basector;
     end if

     -- sector cero tercer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = bpccssubsub and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;

     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa   = bpempresa and
              ccmayor   = bpccmayor and
              ccsub     = bpccsub and
              ccsubsub  = bpccsubsub and
              ccssubsub = bpccssubsub and
              ciudad    = bpciudad and
              sucursal  = bpsucursal and
              moneda    = bpmoneda and
              mes_dia   = bpmes_dia and
              tipo_cta  = "D";

        let bpccsssubsub  = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
             bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
             bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero segundo nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ccsubsub = bpccsubsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub = baccsssubsub;
        let bpsector     = basector;
     end if

     -- sector cero primer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero nivel mayor
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = v_cero_s and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
        bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsub = v_cero_s;
        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsub  = baccsub;
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if
  END IF
  -- tercer nivel
  IF bpccmayor > v_cero_may and bpccsub > v_cero_s and
     bpccsubsub > v_cero_ss and bpccssubsub > v_cero_sss and
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero tercer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = bpccssubsub and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa   = bpempresa and
              ccmayor   = bpccmayor and
              ccsub     = bpccsub and
              ccsubsub  = bpccsubsub and
              ccssubsub = bpccssubsub and
              ciudad    = bpciudad and
              sucursal  = bpsucursal and
              moneda    = bpmoneda  and
              mes_dia   = bpmes_dia and
              tipo_cta  = "D";

        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero segundo nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ccsubsub = bpccsubsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
              bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
              bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub = baccsssubsub;
        let bpsector     = basector;
     end if

     -- sector cero primer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;

     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
        bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_sss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero nivel mayor
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = v_cero_s and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa = bpempresa and
              ccmayor  = bpccmayor and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsub = v_cero_s;
        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsub  = baccsub;
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if
  END IF
  -- segundo nivel
  IF bpccmayor > v_cero_may and bpccsub   > v_cero_s and
     bpccsubsub > v_cero_ss and bpccssubsub = v_cero_sss and
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero segundo nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = bpccsubsub and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ccsubsub = bpccsubsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub = baccsssubsub;
        let bpsector     = basector;
     end if

     -- sector cero primer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa = bpempresa and
              ccmayor       = bpccmayor and
              ccsub         = bpccsub and
              ciudad        = bpciudad and
              sucursal      = bpsucursal and
              moneda        = bpmoneda  and
              mes_dia       = bpmes_dia and
              tipo_cta = "D";

        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero nivel mayor
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = v_cero_s and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;

     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsub = v_cero_s;
        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsub  = baccsub;
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if
  END IF

  -- primer nivel
  IF bpccmayor > v_cero_may and bpccsub  > v_cero_s and
     bpccsubsub = v_cero_ss and bpccssubsub = v_cero_sss and
     bpccsssubsub = v_cero_ssss THEN

     -- sector cero primer nivel
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = bpccsub and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;

     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ccsub    = bpccsub and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if

     -- sector cero nivel mayor
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = v_cero_s and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsub = v_cero_s;
        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsub  = baccsub;
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if
  END IF
  -- mayor nivel
  IF bpccmayor > v_cero_may and bpccsub = v_cero_s and
     bpccsubsub = v_cero_ss and bpccssubsub = v_cero_sss and
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero nivel mayor
     select count(*) into w_cuantos from co_balprev
     where empresa    = bpempresa and
           ccmayor    = bpccmayor and
           ccsub      = v_cero_s and
           ccsubsub   = v_cero_ss and
           ccssubsub  = v_cero_sss and
           ccsssubsub = v_cero_ssss and
           sector     = v_cero_sect and
           ciudad     = bpciudad and
           sucursal   = bpsucursal and
           moneda     = bpmoneda and
           mes_dia    = bpmes_dia;
     if w_cuantos = 0 then
        select sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual)
        into   bpsaldo_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual
        from co_balprev
        where empresa  = bpempresa and
              ccmayor  = bpccmayor and
              ciudad   = bpciudad and
              sucursal = bpsucursal and
              moneda   = bpmoneda  and
              mes_dia  = bpmes_dia and
              tipo_cta = "D";

        let bpccsub = v_cero_s;
        let bpccsubsub = v_cero_ss;
        let bpccssubsub = v_cero_sss;
        let bpccsssubsub = v_cero_ssss;
        let bpsector = v_cero_sect;
        let bptipo_cta = "T";

      let bpempresa   = bpempresa;
      let bpccmayor   = bpccmayor;
      let bpccsub     = bpccsub;
      let bpccsubsub  = bpccsubsub;
      let bpccssubsub = bpccssubsub;
      let bpccsssubsub = bpccsssubsub;
      let bpsector    = bpsector;
      let bpciudad    = bpciudad;
      let bpsucursal  = bpsucursal;
      let bpmoneda    = bpmoneda;
      let bpmes_dia   = bpmes_dia;
      let bpsaldo_anterior = bpsaldo_anterior;
      let bpcargos_dia	   = bpcargos_dia;
      let bpabonos_dia	   = bpabonos_dia;
      let bpsaldo_actual   = bpsaldo_actual;
      let bptipo_cta	   = bptipo_cta;
        insert into co_balprev
        values(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta);
        -- regresa valores originales
        let bpccsub  = baccsub;
        let bpccsubsub  = baccsubsub;
        let bpccssubsub  = baccssubsub;
        let bpccsssubsub  = baccsssubsub;
        let bpsector      = basector;
     end if
   END IF
END FOREACH
end procedure;