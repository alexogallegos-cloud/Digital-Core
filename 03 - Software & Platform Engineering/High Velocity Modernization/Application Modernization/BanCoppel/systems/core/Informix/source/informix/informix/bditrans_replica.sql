create procedure "informix".replica(pcuenta char(10), psdo_actual decimal(14,2), 
		plim_credito decimal(14,2))
define v_sucursal char(3);
foreach
select sucursal into v_sucursal	
	from bdicheq:sc_replica
	where cuenta=pcuenta


system "cs2hrq " || v_sucursal || " " || "01" || " " || pcuenta || " " || psdo_actual || " " || plim_credito;
end foreach;
end procedure;