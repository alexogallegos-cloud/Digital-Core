create procedure "informix".llenareport(pempresa char(3), pciudad char(3),
                             psucursal char(4), pcve_reporte char(10),
                             pfecha_hoy date)
returning char(5);
define cod_ret           char(5);
define sempresa          char(3);
define scve_reporte      char(10);
define snum_renglon      smallint;
define snum_columna      smallint;
define sren_totaliza     smallint;
define scol_totaliza     smallint;
define sfiltro           char(3);
define soperador         char(1);
define stexto            char(60);
define sgrupo            smallint;
define sacumula          char(1);
define tempresa          char(3);
define tcve_reporte      char(10);
define tfiltro           char(3);
define tccmayor          char(10);
define tccsub            char(10);
define tccsubsub         char(10);
define tccssubsub        char(10);
define tccsssubsub       char(10);
define tsector           char(10);
define tmoneda           char(2);
define tciudad           char(3);
define tsucursal         char(4);
define tmes_dia          date;
define trubro1           char(9);
define trubro2           char(9);
define trubro3           char(9);
define toperador         char(1);
define tmonvaloriza      char(2);
define tcargos_dia       char(60);
define tabonos_dia       char(60);
define tsaldo_inicio_dia char(60);
define tsaldo_fin_de_dia char(60);

define ncargos_dia       money(18,2);
define nabonos_dia       money(18,2);
define nsaldo_inicio_dia money(18,2);
define nsaldo_fin_de_dia money(18,2);

define v_fecha           date;
define v_num_dias        smallint;
define lv_fec_fin        date;
define v_numfin          money(18,2);
define vsaldo_fin        money(18,2);
define vsaldo_fin2       money(18,2);
define v_mn              char(2);
define v_tpc             decimal(14,6);
define v_fecha_tc        date;


if psucursal is null or psucursal = " " then
   let psucursal = "999";
end if

let cod_ret = "00000";

--create temp table edosfin
--(
-- empresa              char(3),
-- cve_reporte          char(10),
-- num_renglon          smallint,
-- num_columna          smallint,
-- ciudad               char(3),
-- sucursal             char(3),
-- moneda               char(2),
-- fecha                date,
-- saldo_inicio         char(60),
-- cargos               char(60),
-- abonos               char(60),
-- saldo_fin            integer);

delete from co_edosfin;

let cod_ret = "000";
delete from co_repsdos;

select moneda_nacional
into   v_mn
from   co_param
where  empresa = pempresa;

foreach
   select *
   into   sempresa,
          scve_reporte,
          snum_renglon,
          snum_columna,
          sfiltro,
          soperador,
          stexto,
          sgrupo,
          sacumula,
          sren_totaliza,
          scol_totaliza
   from co_celdas
   where empresa     = pempresa
   and   cve_reporte = pcve_reporte
   order by num_renglon,num_columna

   foreach
      select *
      into   tempresa,
             tcve_reporte,
             tfiltro,
             tmoneda,
             tccmayor,
             tccsub,
             tccsubsub,
             tccssubsub,
             tccsssubsub,
             tsector,
             trubro1,
             trubro2,
             trubro3,
             tmonvaloriza,
             toperador
      from co_filtros
      where  empresa = sempresa
      and    cve_reporte = pcve_reporte
      and    filtro  = sfiltro

      if tccmayor is null or tccmayor = " " then
         if trubro1 != "000" or trubro2 != "000"
            or trubro3 != "000"  then
            if trubro1 != "000" then
               if psucursal != "999" then
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                  co_saldos
                  where empresa  = pempresa
                  and   ciudad   = pciudad
                  and   sucursal = psucursal
                  and   rubro1   = trubro1
                  and   moneda   = tmoneda
                  and   mes_dia  = pfecha_hoy;
               else
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                         co_saldos
                  where empresa = pempresa
                  and   ciudad  = pciudad
                  and   rubro1  = trubro1
                  and   moneda  = tmoneda
                  and   mes_dia = pfecha_hoy;
               end if

                  let tciudad = pciudad;
                  let tsucursal = psucursal;

                  if nsaldo_inicio_dia is null then
                     let nsaldo_inicio_dia = 0;
                  end if
                  if ncargos_dia is null then
                     let ncargos_dia = 0;
                  end if
                  if nabonos_dia is null then
                     let nabonos_dia = 0;
                  end if
                  if nsaldo_fin_de_dia is null then
                     let nsaldo_fin_de_dia = 0;
                  end if

                  if length(tmonvaloriza) > 0 and tmoneda <> v_mn then
                     SELECT precio_venta
                     INTO v_tpc
                     FROM bdinteg:si_histdiv
                     WHERE empresa = pempresa
                     AND divisa = tmonvaloriza
                     AND clase_tpcambio = "O"
                     AND fecha_tc = pfecha_hoy;

                     if v_tpc = 0 or v_tpc is null then
                        SELECT max(fecha_tc)
                        INTO v_fecha_tc
                        FROM bdinteg:si_histdiv
                        WHERE empresa = pempresa
                        AND divisa = tmonvaloriza
                        AND clase_tpcambio = "O";

                        if v_fecha_tc is null or v_fecha_tc = " " then
                           let v_tpc = 0;
                        else
                           SELECT precio_venta
                           INTO v_tpc
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pempresa
                           AND divisa = tmonvaloriza
                           AND clase_tpcambio = "O"
                           AND fecha_tc = v_fecha_tc;
                        end if
                     end if

                     let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;
                     let ncargos_dia = ncargos_dia * v_tpc;
                     let nabonos_dia = nabonos_dia * v_tpc;
                     let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;
                     let tmoneda = v_mn;
                 end if
                 let tcargos_dia       = ncargos_dia;
                 let tabonos_dia       = nabonos_dia;
                 let tsaldo_inicio_dia = nsaldo_inicio_dia;
                 let tsaldo_fin_de_dia = nsaldo_fin_de_dia;

                 execute procedure inserta_actualiza(sempresa,scve_reporte,
                                                   snum_renglon,snum_columna,
                                                   tciudad,tsucursal,tmoneda,
                                                  pfecha_hoy,tsaldo_inicio_dia,
                                                   tcargos_dia,tabonos_dia,
                                                   tsaldo_fin_de_dia,
                                                   toperador,sgrupo);
            end if
            if trubro2 != "000" then
               if psucursal != "999" then
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                  co_saldos
                  where empresa  = pempresa
                  and   ciudad   = pciudad
                  and   sucursal = psucursal
                  and   rubro2   = trubro2
                  and   moneda   = tmoneda
                  and   mes_dia  = pfecha_hoy;
               else
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                         co_saldos
                  where empresa = pempresa
                  and   ciudad  = pciudad
                  and   rubro2  = trubro2
                  and   moneda  = tmoneda
                  and   mes_dia = pfecha_hoy;
               end if

               let tciudad = pciudad;
               let tsucursal = psucursal;

                  if nsaldo_inicio_dia is null then
                     let nsaldo_inicio_dia = 0;
                  end if
                  if ncargos_dia is null then
                     let ncargos_dia = 0;
                  end if
                  if nabonos_dia is null then
                     let nabonos_dia = 0;
                  end if
                  if nsaldo_fin_de_dia is null then
                     let nsaldo_fin_de_dia = 0;
                  end if

                  if length(tmonvaloriza) > 0 and tmoneda <> v_mn then
                     SELECT precio_venta
                     INTO v_tpc
                     FROM bdinteg:si_histdiv
                     WHERE empresa = pempresa
                     AND divisa = tmonvaloriza
                     AND clase_tpcambio = "O"
                     AND fecha_tc = pfecha_hoy;

                     if v_tpc = 0 or v_tpc is null then
                        SELECT max(fecha_tc)
                        INTO v_fecha_tc
                        FROM bdinteg:si_histdiv
                        WHERE empresa = pempresa
                        AND divisa = tmonvaloriza
                        AND clase_tpcambio = "O";

                        if v_fecha_tc is null or v_fecha_tc = " " then
                           let v_tpc = 0;
                        else
                           SELECT precio_venta
                           INTO v_tpc
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pempresa
                           AND divisa = tmonvaloriza
                           AND clase_tpcambio = "O"
                           AND fecha_tc = v_fecha_tc;
                        end if
                     end if

                     let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;
                     let ncargos_dia = ncargos_dia * v_tpc;
                     let nabonos_dia = nabonos_dia * v_tpc;
                     let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;
                  end if
                  let tcargos_dia       = ncargos_dia;
                  let tabonos_dia       = nabonos_dia;
                  let tsaldo_inicio_dia = nsaldo_inicio_dia;
                  let tsaldo_fin_de_dia = nsaldo_fin_de_dia;
                  let tmoneda           = v_mn;
                  execute procedure inserta_actualiza(sempresa,scve_reporte,
                                                   snum_renglon,snum_columna,
                                                   tciudad,tsucursal,tmoneda,
                                                  pfecha_hoy,tsaldo_inicio_dia,
                                                   tcargos_dia,tabonos_dia,
                                                   tsaldo_fin_de_dia,
                                                   toperador,sgrupo);
               --end foreach
            end if
            if trubro3 != "000" then

               if psucursal != "999" then
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                  co_saldos
                  where empresa  = pempresa
                  and   ciudad   = pciudad
                  and   sucursal = psucursal
                  and   rubro3   = trubro3
                  and   moneda   = tmoneda
                  and   mes_dia  = pfecha_hoy;
               else
                  select sum(saldo_inicio_dia),
                         sum(cargos_dia),
                         sum(abonos_dia),
                         sum(saldo_fin_de_dia)
                  into
                     nsaldo_inicio_dia,
                     ncargos_dia,
                     nabonos_dia,
                     nsaldo_fin_de_dia
                  from
                         co_saldos
                  where empresa = pempresa
                  and   ciudad  = pciudad
                  and   rubro3  = trubro3
                  and   moneda  = tmoneda
                  and   mes_dia = pfecha_hoy;
               end if

               let tciudad = pciudad;
               let tsucursal = psucursal;

                  if nsaldo_inicio_dia is null then
                     let nsaldo_inicio_dia = 0;
                  end if
                  if ncargos_dia is null then
                     let ncargos_dia = 0;
                  end if
                  if nabonos_dia is null then
                     let nabonos_dia = 0;
                  end if
                  if nsaldo_fin_de_dia is null then
                     let nsaldo_fin_de_dia = 0;
                  end if

                  if length(tmonvaloriza) > 0 and tmoneda <> v_mn then
                     SELECT precio_venta
                     INTO v_tpc
                     FROM bdinteg:si_histdiv
                     WHERE empresa = pempresa
                     AND divisa = tmonvaloriza
                     AND clase_tpcambio = "O"
                     AND fecha_tc = pfecha_hoy;

                     if v_tpc = 0 or v_tpc is null then
                        SELECT max(fecha_tc)
                        INTO v_fecha_tc
                        FROM bdinteg:si_histdiv
                        WHERE empresa = pempresa
                        AND divisa = tmonvaloriza
                        AND clase_tpcambio = "O";

                        if v_fecha_tc is null or v_fecha_tc = " " then
                           let v_tpc = 0;
                        else
                           SELECT precio_venta
                           INTO v_tpc
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pempresa
                           AND divisa = tmonvaloriza
                           AND clase_tpcambio = "O"
                           AND fecha_tc = v_fecha_tc;
                        end if
                     end if

                     let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;
                     let ncargos_dia = ncargos_dia * v_tpc;
                     let nabonos_dia = nabonos_dia * v_tpc;
                     let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;
                     let tmoneda = v_mn;
                  end if
                  let tcargos_dia       = ncargos_dia;
                  let tabonos_dia       = nabonos_dia;
                  let tsaldo_inicio_dia = nsaldo_inicio_dia;
                  let tsaldo_fin_de_dia = nsaldo_fin_de_dia;
                  execute procedure inserta_actualiza(sempresa,scve_reporte,
                                                   snum_renglon,snum_columna,
                                                   tciudad,tsucursal,tmoneda,
                                                  pfecha_hoy,tsaldo_inicio_dia,
                                                   tcargos_dia,tabonos_dia,
                                                   tsaldo_fin_de_dia,
                                                   toperador,sgrupo);

            end if
         else
            LET tciudad = " ";
            LET tsucursal = " ";
            LET tmoneda = " ";
            LET tsaldo_inicio_dia = sgrupo;
            LET tcargos_dia = sacumula;
            LET tabonos_dia = " ";
            LET tsaldo_fin_de_dia = stexto;

            INSERT INTO co_repsdos VALUES(sempresa,scve_reporte,
                                          snum_renglon,snum_columna,
                                          tciudad,tsucursal,tmoneda,
                                          pfecha_hoy,tsaldo_inicio_dia,
                                          tcargos_dia,tabonos_dia,
                                          tsaldo_fin_de_dia);

         end if
      else
         if psucursal != "999" then
            select sum(saldo_inicio_dia),
                   sum(cargos_dia),
                   sum(abonos_dia),
                   sum(saldo_fin_de_dia)
            into
               nsaldo_inicio_dia,
               ncargos_dia,
               nabonos_dia,
               nsaldo_fin_de_dia
            from
            co_saldos
            where empresa    = pempresa
            and   ccmayor    = tccmayor
            and   ccsub      = tccsub
            and   ccsubsub   = tccsubsub
            and   ccssubsub  = tccssubsub
            and   ccsssubsub = tccsssubsub
            and   sector     = tsector
            and   moneda     = tmoneda
            and   mes_dia    = pfecha_hoy;
         else
            select sum(saldo_inicio_dia),
                   sum(cargos_dia),
                   sum(abonos_dia),
                   sum(saldo_fin_de_dia)
            into
               nsaldo_inicio_dia,
               ncargos_dia,
               nabonos_dia,
               nsaldo_fin_de_dia
            from
                   co_saldos
            where empresa    = pempresa
            and   ccmayor    = tccmayor
            and   ccsub      = tccsub
            and   ccsubsub   = tccsubsub
            and   ccssubsub  = tccssubsub
            and   ccsssubsub = tccsssubsub
            and   sector     = tsector
            and   ciudad     = pciudad
            and   moneda     = tmoneda
            and   mes_dia    = pfecha_hoy;
         end if

         let tciudad = pciudad;
         let tsucursal = psucursal;

            if nsaldo_inicio_dia is null then
               let nsaldo_inicio_dia = 0;
            end if
            if ncargos_dia is null then
               let ncargos_dia = 0;
            end if
            if nabonos_dia is null then
               let nabonos_dia = 0;
            end if
            if nsaldo_fin_de_dia is null then
               let nsaldo_fin_de_dia = 0;
            end if

            if length(tmonvaloriza) > 0 and tmoneda <> v_mn then
               SELECT precio_venta
               INTO v_tpc
               FROM bdinteg:si_histdiv
               WHERE empresa = pempresa
               AND divisa = tmonvaloriza
               AND clase_tpcambio = "O"
               AND fecha_tc = pfecha_hoy;

               if v_tpc = 0 or v_tpc is null then
                  SELECT max(fecha_tc)
                  INTO v_fecha_tc
                  FROM bdinteg:si_histdiv
                  WHERE empresa = pempresa
                  AND divisa = tmonvaloriza
                  AND clase_tpcambio = "O";

                  if v_fecha_tc is null or v_fecha_tc = " " then
                     let v_tpc = 0;
                  else
                     SELECT precio_venta
                     INTO v_tpc
                     FROM bdinteg:si_histdiv
                     WHERE empresa = pempresa
                     AND divisa = tmonvaloriza
                     AND clase_tpcambio = "O"
                     AND fecha_tc = v_fecha_tc;
                  end if
               end if

               let nsaldo_inicio_dia = nsaldo_inicio_dia * v_tpc;
               let ncargos_dia = ncargos_dia * v_tpc;
               let nabonos_dia = nabonos_dia * v_tpc;
               let nsaldo_fin_de_dia = nsaldo_fin_de_dia * v_tpc;
               let tmoneda = v_mn;
            end if

            let tcargos_dia       = ncargos_dia;
            let tabonos_dia       = nabonos_dia;
            let tsaldo_inicio_dia = nsaldo_inicio_dia;
            let tsaldo_fin_de_dia = nsaldo_fin_de_dia;

            execute procedure inserta_actualiza(tempresa,tcve_reporte,
                                             snum_renglon,snum_columna,
                                             tciudad,tsucursal,tmoneda,
                                             pfecha_hoy,tsaldo_inicio_dia,
                                             tcargos_dia,tabonos_dia,
                                             tsaldo_fin_de_dia,
                                             toperador,sgrupo);

         --end foreach
      end if
   end foreach
end foreach

foreach
   select distinct num_renglon,
                   num_columna,
                   operador,
                   grupo,
                   acumula
   into   snum_renglon,
          snum_columna,
          soperador,
          sgrupo,
          sacumula
   from co_celdas
   where empresa     = pempresa
   and   cve_reporte = pcve_reporte

   update co_edosfin
   set saldo_inicio  = sgrupo,
       cargos        = sacumula
   where empresa     = pempresa
   and   cve_reporte = pcve_reporte
   and   num_renglon = snum_renglon
   and   num_columna = snum_columna;
end foreach

foreach
   select saldo_inicio, sum(saldo_fin)
   into sgrupo,vsaldo_fin
   from co_edosfin
   group by 1
   order by 1

   update co_repsdos
   set saldo_fin = vsaldo_fin
   where saldo_inicio = sgrupo
   and   cargos = "S";
end foreach

foreach
   select num_renglon,
          num_columna,
          operador,
          renglon_totaliza,
          columna_totaliza
   into   snum_renglon,
          snum_columna,
          soperador,
          sren_totaliza,
          scol_totaliza
   from co_celdas
   where empresa = pempresa
   and cve_reporte = pcve_reporte
--   and acumula = "S"

   if sren_totaliza is null or sren_totaliza = " " then
   else
      let vsaldo_fin = 0;

      select saldo_fin
      into   vsaldo_fin
      from   co_repsdos
      where  num_renglon = snum_renglon
      and    num_columna = snum_columna;

      if vsaldo_fin is null or vsaldo_fin = " " then
         let vsaldo_fin = 0;
      end if

      if soperador = "-" then
         let vsaldo_fin = vsaldo_fin * -1;
      end if

      select saldo_fin
      into   vsaldo_fin2
      from   co_repsdos
      where num_renglon = sren_totaliza
      and   num_columna = scol_totaliza;

      if vsaldo_fin2 is null or vsaldo_fin2 = " " then
         let vsaldo_fin2 = 0;
      end if

      let vsaldo_fin = vsaldo_fin + vsaldo_fin2;

      update co_repsdos
      set saldo_fin = vsaldo_fin
      where num_renglon = sren_totaliza
      and   num_columna = scol_totaliza;
   end if
end foreach
return cod_ret;
end procedure;