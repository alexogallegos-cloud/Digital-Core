create procedure "informix".cons_instvento_pba(pempresa char(3),
                                           pcuenta char(20),
                                           pnum_movto smallint)
	returning char(5), char(20), char(7), smallint, char(30), money(14,2),
		  char(35), char(20), char(1), date;
		  
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define v_cuenta char(20);
   define v_cap_int, v_aplicado char(1);
   define v_nom_cap_int char(7);
   define v_sec_capint, v_conta smallint;
   define v_inst_vento, v_sistema char(2);
   define v_nom_inst_vento,
          v_nom_sistema char(35);
   define v_importe money(14,2);
   define v_cta_traspaso char(20);
   define v_ciclo, longitud smallint;
   define v_cod_ret char(5);
   define v_env_dir char(1);
   define v_fecha_venc date;
   define v_long_param char(2);
set isolation to dirty read;

-- ***************************************************************************
-- Asigna las variables
-- ***************************************************************************
   let v_cod_ret         = "000";
   let v_cuenta          = "000000000";
   let v_nom_cap_int     = "       ";
   let v_sec_capint      = 0;
   let v_cod_ret="000";
   let v_conta           = 0;
   let v_nom_inst_vento  = "                              ";
   let v_importe         = 0;
   let v_nom_sistema     = "                                   ";
   let v_cta_traspaso    = "00000000000000000000";
   let v_aplicado        = " ";
   let v_fecha_venc      = "          ";
   let v_ciclo           = 0;

   foreach
        select cuenta, cap_int, sec_capint, inst_vento, importe, sistema,
               cta_cheques, aplicado, fecha_venc
        into
               v_cuenta, v_cap_int, v_sec_capint, v_inst_vento, v_importe,
               v_sistema, v_cta_traspaso, v_aplicado, v_fecha_venc
        from
               sv_maeinstrucc
        where
               cuenta = pcuenta

	if v_cuenta is null then
          let v_cod_ret = "142";
          return v_cod_ret, v_cuenta, v_nom_cap_int, v_inst_vento,
		 v_nom_inst_vento,
                 v_importe, v_nom_sistema, v_cta_traspaso, v_aplicado,
                 v_fecha_venc;
	end if
        -- Determina si es capital o interes
        if v_cap_int = "C" then
           let v_nom_cap_int = "CAPITAL";
        else
           let v_nom_cap_int = "INTERES";
        end if
        -- Asigna el nombre del sistema de la cuenta de traspaso, si la hay
        if v_sistema is not null or
           v_sistema != " " then
           select descripcion into v_nom_sistema from bdinteg:si_sistema
           where sistema = v_sistema;
        end if
        -- Asigna el nombre a la instruccion al vencimiento
        select descripcion into v_nom_inst_vento
          from
               sv_instrucc
          where
               codigo = v_inst_vento;

	let v_ciclo = v_ciclo+1;

	if v_ciclo <= pnum_movto then
            continue foreach;
	end if
        return v_cod_ret, v_cuenta, v_nom_cap_int, v_inst_vento,
	       v_nom_inst_vento,
               v_importe, v_nom_sistema, v_cta_traspaso, v_aplicado,
               v_fecha_venc WITH RESUME;
	let v_conta = v_conta+1;
    end foreach;
end procedure;