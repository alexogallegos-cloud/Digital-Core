CREATE PROCEDURE "informix".cons_cuentas_web(pempresa char(3), pnum_cte char(20))
   returning char(5),char(11),char(4),char(4),char(18);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE v_numcte char(9);
   DEFINE v_cuenta char(11);
   DEFINE v_producto char(4);
   DEFINE v_sucursal char(4);
   DEFINE v_cuenta_clabe char(18);
   DEFINE v_valor integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "00000";
   LET v_cuenta      = "";
   LET v_numcte      = "";
   LET v_cuenta      = "";
   LET v_producto    = "";
   LET v_sucursal    ="";
   LET v_cuenta_clabe ="";
   LET v_valor = 0;
BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
      end if
   end exception;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   select numcte into v_numcte from bdinteg:si_cliente
      where numcte = pnum_cte;
   if v_numcte is null then
      let cod_ret = "00104";
      return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
   end if

   select count(1)
         into v_valor
         from sc_maechq
        where empresa = pempresa and
               num_cte = pnum_cte and
               status_cta not in('2','6','7');
   
   IF v_valor > 0 THEN
   
   FOREACH
      select cuenta, producto, sucursal, cuenta_clabe
      into v_cuenta, v_producto, v_sucursal, v_cuenta_clabe
         from sc_maechq
         where empresa = pempresa and
               num_cte = pnum_cte and
               status_cta not in('2','6','7')
               order by cuenta
  
  			return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe WITH RESUME;
		
    END FOREACH
	ELSE
	let cod_ret       = "00001";
			return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe WITH RESUME;
	END IF
END
END PROCEDURE;