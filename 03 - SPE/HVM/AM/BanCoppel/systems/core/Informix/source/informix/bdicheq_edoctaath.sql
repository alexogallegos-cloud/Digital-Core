create procedure "informix".edoctaath( 	pempresa char(3),
				pcuenta   char(20) )
returning	char(4) ,
		char(40) ,
		char(20) ,
		varchar(123,0) ,
		char(60) ,
		money(14,2) ,
		money(14,2) ,
		money(14,2) ,
		char(4) ,
		char(1) ,
		char(40) ,
		integer ,
		char(16) ,
		integer ,
		date ,
		money(14,2) ,
		char(40) ,
		char(1) ;


define r_sucursal char(4);
define r_sucursal_nombre char(40);
define r_cuenta_num_cte char(20);
define r_cuenta_nombre varchar(123,0);
define r_cuenta_colonia char(60);
define r_cuenta_sdo_actual money(14,2);
define r_cuenta_sdo_cong money(14,2);
define r_cuenta_sdo_mes_ant money(14,2);
define r_mov_transacc char(4);
define r_mov_transacc_naturaleza char(1);
define r_mov_transacc_descripcion char(40);
define r_mov_num_serial integer;
define r_mov_folio char(16);
define r_mov_num_cheq integer;
define r_mov_fech_val date;
define r_mov_monto_tot money(14,2);
define r_mov_referencia char(40);
define r_mov_cancelad char(1);

define v_cuenta integer;

select a.sucursal, b.nombre,
       a.num_cte,
       a.sdo_actual, a.sdo_cong, c.sdo_mes_ant
into r_sucursal, r_sucursal_nombre,
     r_cuenta_num_cte,
     r_cuenta_sdo_actual, r_cuenta_sdo_cong, r_cuenta_sdo_mes_ant
from ((sc_maechq a inner join si_sucursales b on a.empresa = b.empresa and a.sucursal = b.sucursal)
      inner join sc_maenoc c on a.empresa = c.empresa and a.cuenta = c.cuenta)
where a.empresa = pempresa
and a.cuenta = pcuenta;

select TRIM(b.nombre1) || ' ' ||  TRIM(b.apell_paterno) || ' ' ||  TRIM(b.apell_materno)
into r_cuenta_nombre
from sc_maechq a inner join bdinteg:si_cliente b on a.empresa = b.empresa and a.num_cte = b.numcte
where a.empresa = pempresa
and a.cuenta = pcuenta;

select TRIM(b.colonia) || ' ' || TRIM(b.municipio) || '-' || TRIM(b.cod_postal)
into r_cuenta_colonia
from sc_maechq a inner join bdinteg:si_direcciones b on a.num_cte = b.numcte
where a.empresa = pempresa
and a.cuenta = pcuenta;

select count(*)
into v_cuenta
from sc_movmes
where empresa = pempresa
and cuenta = pcuenta;

if v_cuenta = 0 then
 	let r_mov_transacc = '0000';
	let r_mov_transacc_naturaleza = '0';
	let r_mov_transacc_descripcion = '';
	let r_mov_num_serial = 0;
	let r_mov_folio = '0000000000000000';
	let r_mov_num_cheq = 00000000;
	let r_mov_fech_val = null;
	let r_mov_monto_tot = 0;
	let r_mov_referencia = 'No Hay Movimiento';
	let r_mov_cancelad = '';
	return r_sucursal, r_sucursal_nombre,
	       r_cuenta_num_cte, r_cuenta_nombre, r_cuenta_colonia,
	       r_cuenta_sdo_actual, r_cuenta_sdo_cong, r_cuenta_sdo_mes_ant,
	       r_mov_transacc, r_mov_transacc_naturaleza, r_mov_transacc_descripcion,
	       r_mov_num_serial, r_mov_folio, r_mov_num_cheq, r_mov_fech_val, r_mov_monto_tot, r_mov_referencia, r_mov_cancelad;
end if;

foreach
select a.transacc, b.naturaleza, b.descripcion,
       a.num_serial, a.folio_suc, a.num_cheq, a.fech_val, a.monto_tot, a.referencia, a.cancelad
into r_mov_transacc, r_mov_transacc_naturaleza, r_mov_transacc_descripcion,
     r_mov_num_serial, r_mov_folio, r_mov_num_cheq, r_mov_fech_val, r_mov_monto_tot, r_mov_referencia, r_mov_cancelad
from (sc_movmes a inner join si_transacc b on a.empresa = b.empresa and a.transacc = b.numero)
where a.empresa = pempresa
and a.cuenta = pcuenta
order by a.fech_val asc, a.num_serial
	return r_sucursal, r_sucursal_nombre,
	       r_cuenta_num_cte, r_cuenta_nombre, r_cuenta_colonia,
	       r_cuenta_sdo_actual, r_cuenta_sdo_cong, r_cuenta_sdo_mes_ant,
	       r_mov_transacc, r_mov_transacc_naturaleza, r_mov_transacc_descripcion,
	       r_mov_num_serial, r_mov_folio, r_mov_num_cheq, r_mov_fech_val, r_mov_monto_tot, r_mov_referencia, r_mov_cancelad with resume;
end foreach;
end procedure;