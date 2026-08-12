create procedure "informix".ext_tasa(pempresa char(3),
                           ptasa    char(8),
                           ptip_per char(2),
                           ano_hoy smallint,
                           mes_hoy smallint,
                           pmonto   money(14,2))
returning char(5), decimal(9,6);

define valor_pond decimal(9,6); 
define sql_err integer;
define vcodigo, vtasareferen char(8);
define vrangofecha char(1);
define cod_ret char(5);
define vfecha_rec, vfecha_refer date;
define valor_tasa, vvalor, porcentaje, puntos decimal(9,6);
define vrangomin, vrangomax decimal(14,2);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
let cod_ret    = "000";
let valor_pond = 0;
let porcentaje = 0;
let puntos     = 0;




begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret, valor_pond; 
      end if
   end exception;       

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
if ptasa    = "" or
   (ptip_per <> "F" and 
   ptip_per <> "M") or
   pmonto   is null then
   let cod_ret = "110";
   return cod_ret, valor_pond; 
end if

-- ****************************************************************************
-- Define el tipo de tasa asi como la tasa referencial 
-- ****************************************************************************
select tasa, rangofecha, tasareferen
       into vcodigo, vrangofecha, vtasareferen
from bdinteg:si_tiptasa
where empresa = pempresa and tasa = ptasa;
if vcodigo is null then
   let cod_ret = "901";
   return cod_ret, valor_pond;
end if

if vrangofecha = "F" then
   select max(fecha) into vfecha_rec
   from bdinteg:si_fechavalor
   where empresa = pempresa and tasa = vcodigo;

if vfecha_rec is null then
   let cod_ret = "901";
   return cod_ret, valor_pond;
end if

   select valor into valor_tasa
   from bdinteg:si_fechavalor 
   where empresa = pempresa and tasa = vcodigo and
         fecha = vfecha_rec;
   let valor_pond = valor_tasa;

elif vrangofecha = "R" then
   if vtasareferen is null then
      let cod_ret = "904";
      return cod_ret, valor_pond;
   end if
   select max(fecha) into vfecha_refer 
   from bdinteg:si_fechavalor
   where empresa = pempresa and tasa = vtasareferen;

   select valor into vvalor
   from bdinteg:si_fechavalor
   where empresa = pempresa and tasa = vtasareferen and
         fecha  = vfecha_refer;

   if ptip_per = "F" then
      select rangomin, rangomax, valorperfis, sobretasafis 
             into vrangomin, vrangomax, porcentaje, puntos
      from bdinteg:si_tasavlor
      where empresa = pempresa and tasa = ptasa and
            rangomin <= pmonto and
            rangomax >= pmonto;
   else
      select rangomin, rangomax, valorpermor, sobretasamor
             into vrangomin, vrangomax, porcentaje, puntos
      from bdinteg:si_tasavlor
      where empresa = pempresa and tasa = ptasa and
            rangomin <= pmonto and
            rangomax >= pmonto; 
   end if
   let valor_pond = ((vvalor * porcentaje) / 100 ) + puntos; 
end if

if valor_pond is null then
   let valor_pond = 0;
end if
return cod_ret, valor_pond;
end
end procedure;