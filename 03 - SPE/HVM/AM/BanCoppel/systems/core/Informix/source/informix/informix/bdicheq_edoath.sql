create procedure "informix".edoath( pempresa char(3) )
returning	char(20) ,
		char(4) ,
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


define r_cuenta char(20);
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


foreach
select distinct cuenta
into r_cuenta
from sc_tarjeta
where empresa = pempresa
order by cuenta
    foreach execute procedure edoctaath( pempresa, r_cuenta )
    into r_sucursal, r_sucursal_nombre,
    r_cuenta_num_cte, r_cuenta_nombre, r_cuenta_colonia,
    r_cuenta_sdo_actual, r_cuenta_sdo_cong, r_cuenta_sdo_mes_ant,
    r_mov_transacc, r_mov_transacc_naturaleza, r_mov_transacc_descripcion,
    r_mov_num_serial, r_mov_folio, r_mov_num_cheq, r_mov_fech_val, r_mov_monto_tot, r_mov_referencia, r_mov_cancelad
    if TRIM(r_cuenta_nombre) = '' or r_cuenta_nombre is null then
	continue foreach;
    end if;
    return r_cuenta, r_sucursal, r_sucursal_nombre,
	   r_cuenta_num_cte, r_cuenta_nombre, r_cuenta_colonia,
	   r_cuenta_sdo_actual, r_cuenta_sdo_cong, r_cuenta_sdo_mes_ant,
	   r_mov_transacc, r_mov_transacc_naturaleza, r_mov_transacc_descripcion,
	   r_mov_num_serial, r_mov_folio, r_mov_num_cheq, r_mov_fech_val, r_mov_monto_tot, r_mov_referencia, r_mov_cancelad with resume;
    end foreach;
end foreach;
end procedure;