create procedure "informix".migra_tarjeta_cap();
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   --##### Define variables de Trabajo #####
   define v_numcte char(20);
   define v_cuenta char(20);
   define v_credito char(20);

   --###### Inicializa Variables ###########

   foreach select trim(numcte)
           into   v_numcte
           from   sc_tarjeta

      --###### Obtiene datos del cuenta ###########
      select cuenta
      into v_cuenta
      from sc_maechq
      where num_cte = v_numcte
      and (producto = '300' or producto = '301');

      if v_cuenta is null then
      else
         update sc_tarjeta set cuenta = v_cuenta
	 where numcte = v_numcte;
      end if;
      --###### Obtiene datos del credito ###########
      select num_credito
      into v_credito
      from bdicred:sd_maecred
      where numcte = v_numcte
      and num_producto = '410';

      if v_credito is null then
      else
         update sc_tarjeta set num_credito = v_credito
	 where numcte = v_numcte;
      end if;
   end foreach;
end procedure;