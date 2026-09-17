create procedure "informix".arr_sdoant_insta()

define v_saldo money(14,2);
define v_credito char(20);


	foreach select num_credito, sdo_capital 
	          INTO v_credito, v_saldo from sd_maesdosm
		 where substr(num_credito,10,3)= "410"
		   


		UPDATE sd_maesdos set sdo_mes_ant_cap = v_saldo
		 where num_credito = v_credito;
		


	end foreach



end procedure ;