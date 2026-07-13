create procedure "informix".get_numcheque(importe decimal(14,2))
returning 	char(5),
		integer,
		decimal(14,2),
		decimal(14,2),
                decimal(14,2);

--- Inicializa las variables de Salida
	define w_cod_ret	char(5);
	define w_numcheque	integer;
        define w_comision	decimal(14,2);
	define w_iva		decimal(14,2);
	define w_total		decimal(14,2);
        define sql_err		integer;

	let w_cod_ret="000";
	let w_numcheque=1;
	let w_comision=0.0;

	let w_iva=0.15;
        let w_total=0.0;

   begin
      on exception set sql_err
         if sql_err <> 0 then
	   let w_cod_ret = sql_err;
	   let w_numcheque=-1;
	   let w_comision=-1.0;
	   let w_iva=0.0;
           let w_total=0.0;
    end if
      end exception;

      let w_numcheque=sp_random();
      let w_comision=5.2;
      let w_iva=0.15;
      let w_total=(importe*w_iva) + w_comision + importe;
      return w_cod_ret, w_numcheque,w_comision,w_iva,w_total;
    end
end procedure;