create procedure "informix".carga_diaria(pempresa char(3),pfecha_hoy date)
returning char(5);
--#***************************************************************************#
--#                                                                           #
--#   ESTA FUNCION CARGA LA TABLA DE MOVIMIENTOS DIARIOS DE DETERMINADA       #
--#   FECHA Y COMPANIA, POSTERIORMENTE DEBE REALIZAR EL PROCESO VALIDACION    #
--#   DE MOVIMIENTOS DEL DIA                                                  #
--#   co_movdia        --> Tabla primaria de lectura                          #
--#                                                                           #
--#***************************************************************************#

define cod_ret     char(5);
define w_dd        char(2);
define w_dd2       char(2);
define w_mm2       char(2);
define w_mm        char(2);
define w_year      char(4);
define w_a         char(1);
define fecha_movto date;
define w_proceso   char(20);
define v_dia_mes   char(4);
define v_nomtabla  char(70);
define v_sql       char(200);
define vmovtos     char(200);
define v_moneda      char(3);
define v_moneda2     char(3);
define v_tipmov      char(1);
define v_cargo_abono char(1);
define v_ccsub       char(2);
define v_ccsubsub    char(2);
define v_ccssubsub   char(2);
define v_ccsssubsub  char(2);
define v_sector      char(2);
define v2_sector     char(2);
define v_division    char(2);
define v_dd          char(2);
define v_mm          char(2);
define vw_moneda     char(2);
define v_ccmayor     char(4);
define v_ccaa        char(4);
define v_num_poliza3 char(5);
define w_sig_numpoliza char(5);
define w_sig_numpoliza2 char(5);
define v_usuario2    char(8);
define v_descripcion char(50);
define v_fecha       date;
define w_fecha       char(8);
define v_cis         char(9);
define v_secuencia   integer;
define num_reg       integer;
define i             integer;
define v_cuantos     integer;
define v_tipcamxp    money(15,5);
define v_tipcamb     money(15,5);
define v_importe     money(18,2);
define v_impmonloc   money(18,2);
define v_cliente     char(7);
define v_sectoriza_cta char(1);
define resp          char(1);
define v_auxiliar    char(1);
define v_nro_auxiliar char(9);
define v_usuario char (8);
define vruta_respaldo char(40);

begin work;
lock table co_detpol in exclusive mode;
delete from co_detpol
where empresa = pempresa
and   fecha_captura = pfecha_hoy;
commit work;

begin work;
lock table co_poliza in exclusive mode;
delete from bdicont:co_poliza
where empresa = pempresa
and   fecha_captura = pfecha_hoy;
commit work;

let cod_ret = "000";
begin work;
lock table co_tabmovdia in exclusive mode;
delete from co_tabmovdia;
commit work;

select fecha
into fecha_movto
from co_contproc
where proceso = "movtosdia"
and empresa = pempresa;

delete
from co_contproc
where fecha_movto = pfecha_hoy
and empresa = pempresa;

let w_dd = day(pfecha_hoy);
let w_mm = month(pfecha_hoy);
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

let v_dia_mes = trim(w_dd)||w_mm;

select ruta_respaldo
into vruta_respaldo
from co_param
where empresa = pempresa;

let v_nomtabla = trim(vruta_respaldo)||
                 "/importadatos/mup"||v_dia_mes||w_a||".txt";
begin work;
lock table co_movdia in exclusive mode;
delete from co_movdia;
commit work;
let v_sql = "echo "||'"'|| "file '"||TRIM(v_nomtabla)||"' delimiter '|' 1"
            || "; insert into co_movdia;"||'"'||' > carga';
SYSTEM v_sql;

let v_sql = "dbload -d bdicont -c carga -l er -n 100";
SYSTEM v_sql;

select count(*)
into v_cuantos
from co_movdia
where registro[26,27] = w_dd
and   registro[24,25] = w_mm
and   registro[20,23] = w_year;

if v_cuantos = 0 then
   let cod_ret = "999";
   return cod_ret;
end if

select count(*)
into num_reg
from co_movdia
where registro[62,64] not in (select num_lote from co_mapeo_lotes
                              where empresa = pempresa)
and   registro[5,7] = pempresa;

let i = 0;
select max(control_poliza) into w_sig_numpoliza
from co_detpol
where usuario = "informix"
and fecha_captura = pfecha_hoy
and empresa = pempresa;

if w_sig_numpoliza is null or w_sig_numpoliza = " " then
   let w_sig_numpoliza = "0";
end if
select max(control_poliza) into w_sig_numpoliza2
from co_poliza
where usuario = "informix"
and fecha_captura = pfecha_hoy;
if w_sig_numpoliza2 is null or w_sig_numpoliza2 = " " then
   let w_sig_numpoliza2 = "0";
end if

if w_sig_numpoliza >= w_sig_numpoliza2 then
   let w_sig_numpoliza = w_sig_numpoliza ;
   let v_num_poliza3 = w_sig_numpoliza;
else
   let w_sig_numpoliza2 = w_sig_numpoliza2 ;
   let v_num_poliza3 = w_sig_numpoliza2;
end if
let v_moneda2 = " ";


   select * from co_movdia into temp tx with no log;

foreach
   select registro
   into  vmovtos
   from tx
   where registro[62,64] not in (select num_lote from co_mapeo_lotes
                                 where empresa = pempresa)
   and   registro[5,7] = pempresa
   order by
   registro[38,40]

   let i             = i + 1;
   let v_moneda      = "  ";
   let v_usuario     = vmovtos[100,106];
   let v_secuencia   =  i;
   let v_dd          = vmovtos[26,27];
   let v_mm          = vmovtos[24,25];
   let v_ccaa        = vmovtos[20,23];
   let v_descripcion = vmovtos[62,91];
   let v_cis         = vmovtos[9,17];
   let v_importe     = vmovtos[42,56];
   let v_moneda      = vmovtos[38,40];
   let v_tipcamxp    = 0;
   let v_impmonloc   = 0;
   let v_tipmov      = vmovtos[59,60];
   let v_tipcamb     = 0;
   let v_cliente     = vmovtos[100,106];
   let v_importe     = v_importe / 100;

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
   select moneda into vw_moneda
   from co_mapeo_divisas
   where divisa_ext = v_moneda;

   let v_moneda = null;
   let v_ccmayor = " ";
   let v_nro_auxiliar = " ";

   -- Extrae equivalencia de la cuenta nacional
   select ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
   into   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector
   from co_mapeo_nuevo
   where cuenta_ext = v_cis
   and empresa = pempresa
   and moneda = vw_moneda;

   --Valida si la Cuenta sectoriza o NO
   let v_sectoriza_cta = " ";
   let v_auxiliar = " ";
   select sectoriza_cta,auxiliar into v_sectoriza_cta,v_auxiliar
   from bdinteg:si_catalog
   where  bdinteg:si_catalog.empresa = pempresa and
          bdinteg:si_catalog.ccmayor = v_ccmayor and
          bdinteg:si_catalog.ccsub   = v_ccsub and
          bdinteg:si_catalog.ccsubsub = v_ccsubsub and
          bdinteg:si_catalog.ccssubsub = v_ccssubsub and
          bdinteg:si_catalog.ccsssubsub = v_ccsssubsub and
          bdinteg:si_catalog.sector = v_sector;

   if v_sectoriza_cta = "S" then
       -- Extrae el sector de Acuerdo al Nuevo Catalogo
       let v2_sector = " ";
       select sector
       into v2_sector
       from co_mapeo_cte
       where numero = v_cliente
       and empresa = pempresa;

       if v2_sector is null then
 	    let v_sector = null;
       end if
       if v2_sector != v_sector then
          let v_sector = v2_sector;
       end if
   end if

   if v_auxiliar = "S" then
      let v_nro_auxiliar = v_cliente;
   else
      let v_nro_auxiliar = "    ";
   end if

    if v_tipmov = "D" then
	 let v_cargo_abono = "D";
    else
       if v_tipmov = "C" then
	    let v_cargo_abono = "C";
       end if
    end if

   let w_fecha = v_mm||v_dd||v_ccaa;
   let v_fecha = w_fecha;

   insert into co_tabmovdia
   values(pempresa, v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub,
          v_ccsssubsub , v_sector, "001", "001", v_cargo_abono, v_importe,
          v_descripcion, v_fecha,"informix", v_fecha, v_num_poliza3,
          vw_moneda, v_cis, v_secuencia, v_cliente, v_tipmov,v_moneda);
end foreach
return cod_ret;
end procedure;