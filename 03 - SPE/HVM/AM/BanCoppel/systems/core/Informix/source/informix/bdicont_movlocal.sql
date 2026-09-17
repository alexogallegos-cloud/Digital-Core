create procedure "informix".movlocal(pempresa char(3), pfecha_hoy date)
returning char(5);

define v_dia_mes char(4);
define w_dd      char(2);
define w_dd2     char(2);
define w_mm2     char(2);
define w_mm      char(2);
define vw_moneda char(2);
define w_year    char(4);
define w_a       char(1);
define fecha_movto date;
define w_proceso char(20);
define v_nomtabla char(100);
define gmregistro char(200);
define v_moneda  char(3);
define v_moneda2 char(3);
define v_tipmov  char(1);
define v_cargo_abono char(1);
define v_ccsub   char(2);
define v_ccsubsub char(2);
define v_ccssubsub char(2);
define v_ccsssubsub char(2);
define v_sector     char(2);
define v2_sector    char(2);
define v_division   char(2);
define v_dd         char(2);
define v_mm         char(2);
define v_valdd      char(2);
define v_valmm      char(2);
define v_ccmayor    char(4);
define v_ccaa       char(4);
define v_valccaa    char(4);
define w_sig_numpoliza2 char(5);
define v_usuario2 char(8);
define v_descripcion char(50);
define v_fecha date;
define w_fecha char(8);
define v_fecha_valida date;
define w_fecha_valida char(8);
define v_cis char(9);
define v_secuencia integer;
define num_reg     integer;
define i           integer;
define v_tipcamb   money(15,5);
define v_cliente   char(7);
define v_sectoriza_cta char(1);
define resp char(1);
define v_auxiliar char(1);
define v_nro_auxiliar char(12);
define v_usuario char (8);
define v_num_poliza3 char(5);
define w_sig_numpoliza char(5);
define v_tipcamxp   money(15,5);
define v_importe    money(18,2);
define v_impmonloc  money(18,2);
define vruta_respaldo char(100);
define v_sql        char(200);
define cod_ret      char(5);
define v_empresa    char(3);
define v_sucursal   char(4);


let cod_ret = "000";

let w_dd   = day(pfecha_hoy);
let w_mm   = month(pfecha_hoy);
let w_year = year(pfecha_hoy);
let w_a    = w_year[4,4];

if w_dd <= 9 then
   let w_dd2 = w_dd;
   let w_dd = "0"||w_dd2;
end if

if w_mm <= 9 then
   let w_mm2 = w_mm;
   let w_mm = "0"||w_mm2;
end if

let v_dia_mes = w_dd||w_mm;

let v_nomtabla = "mlo"||v_dia_mes||w_a||".txt";

delete from co_movdia;
delete from co_tabmovdia;

select ruta_respaldo
into vruta_respaldo
from co_param
where empresa = pempresa;

let v_nomtabla = trim(vruta_respaldo)||"/importadatos/"||v_nomtabla;

delete from co_movdia;
let v_sql = "echo "||'"'|| "file '"||TRIM(v_nomtabla)||"' delimiter '|' 1"
            || "; insert into co_movdia;"||'"'||' > carga';
SYSTEM v_sql;

let v_sql = "dbload -d bdicont -c carga -l er ";
SYSTEM v_sql;


let i = 0;

select max(control_poliza)
into   w_sig_numpoliza
from co_detpol
where usuario = "informix"
and   fecha_captura = pfecha_hoy
and   empresa = pempresa;

if w_sig_numpoliza is null or w_sig_numpoliza = " " then
   let w_sig_numpoliza = "0";
end if

select max(control_poliza)
into w_sig_numpoliza2
from co_poliza
where
usuario = "informix"
and fecha_captura = pfecha_hoy;

if w_sig_numpoliza2 is null or w_sig_numpoliza2 = " " then
   let w_sig_numpoliza2 = "0";
end if

if w_sig_numpoliza >= w_sig_numpoliza2 then
   let w_sig_numpoliza = w_sig_numpoliza;
   let v_num_poliza3 = w_sig_numpoliza;
else
   let w_sig_numpoliza2 = w_sig_numpoliza2;
   let v_num_poliza3 = w_sig_numpoliza2;
end if

let v_moneda2 = " ";

foreach
   select registro
   into   gmregistro
   from co_movdia

   let i = i + 1;
   let v_moneda = "  ";
   let v_ccmayor     = gmregistro[1,4];
   let v_ccsub       = gmregistro[6,7];
   let v_ccsubsub    = gmregistro[9,10];
   let v_ccssubsub   = gmregistro[12,13];
   let v_ccsssubsub  = gmregistro[15,16];
   let v_sector      = gmregistro[18,19];
   let v_cliente     = gmregistro[21,27];
   let v_moneda      = gmregistro[29,31];
   let v_tipmov      = gmregistro[33,33];
   let v_importe     = gmregistro[35,52];
   let v_secuencia   =  i;
   let v_mm          = gmregistro[54,55];
   let v_dd          = gmregistro[57,58];
   let v_ccaa        = gmregistro[60,63];
   let v_valmm       = gmregistro[65,66];
   let v_valdd       = gmregistro[68,69];
   let v_valccaa     = gmregistro[71,74];
   let v_descripcion = gmregistro[76,125];
   let v_empresa     = gmregistro[127,129];
   let v_sucursal    = gmregistro[131,133];

   -- incrementa el numero de poliza si la moneda cambia --
   if v_num_poliza3 is null or v_num_poliza3 = " " then
      let v_usuario2 = "informix";
      let v_num_poliza3 = "1";
      let v_moneda2 = v_moneda;
   else
      if v_moneda != v_moneda2 then
         let v_num_poliza3 = v_num_poliza3 + 1;
         let v_moneda2 = v_moneda;
      end if
   end if



 -- Valida la moneda

  let vw_moneda = " ";
  select moneda into vw_moneda
   from
      co_mapeo_divisas
   where
      divisa_ext = v_moneda;


  let v_nro_auxiliar = "    ";

  --Valida si la Cuenta sectoriza o NO

   select sectoriza_cta,auxiliar
   into v_sectoriza_cta,v_auxiliar
   from bdinteg:si_catalog
   where bdinteg:si_catalog.empresa = pempresa and
         bdinteg:si_catalog.ccmayor = v_ccmayor and
         bdinteg:si_catalog.ccsub   = v_ccsub and
         bdinteg:si_catalog.ccsubsub = v_ccsubsub and
         bdinteg:si_catalog.ccssubsub = v_ccssubsub and
         bdinteg:si_catalog.ccsssubsub = v_ccsssubsub and
         bdinteg:si_catalog.sector = v_sector;

--   if v_sectoriza_cta = "S" then
--       -- Extrae el sector de Acuerdo al Nuevo Catalogo
--      let v2_sector = " ";
--      select sector
--      into   v2_sector
--      from co_mapeo_cte
--      where numero = v_cliente
--      and empresa = pempresa;

--      if v2_sector is null or v2_sector = "  "  then
--         let v2_sector = v_sector;
--         let v_sector = null;
--      end if

--      if v2_sector != v_sector then
--         let v_sector = v2_sector;
--      end if
--   end if

--   if v_auxiliar = "S" then
--      let v_nro_auxiliar = v_cliente;
--   else
      let v_nro_auxiliar = " ";
--   end if

   if v_tipmov = "D" then
      let v_cargo_abono = "D";
   else
      if v_tipmov = "C" then
	 let v_cargo_abono = "C";
      end if
   end if

   let w_fecha = v_mm||v_dd||v_ccaa;
   let v_fecha = w_fecha;
   let w_fecha_valida = v_valmm||v_valdd||v_valccaa;
   let v_fecha_valida = w_fecha_valida;

   insert into co_tabmovdia
   values(v_empresa, v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub,
          v_ccsssubsub , v_sector, "001", v_sucursal, v_cargo_abono, v_importe,
          v_descripcion, v_fecha,"informix", v_fecha_valida, v_num_poliza3,
         vw_moneda, v_nro_auxiliar, v_secuencia, "informix", v_tipmov,v_moneda);
end foreach
return cod_ret;
end procedure;