create procedure "informix".cons_tasa(pempresa char(3),
                                      pcod_instrum char(4),
                                      psucursal char(4),
			              pnumreg integer)

returning 	char(5),
		char(8),
		decimal(14,2),
		decimal(14,2),
		decimal(9,6),
		decimal(9,6);
define 	cod_ret char(5);
define 	w_rangomin,w_rangomax decimal(14,2);
define	w_valorperfis,w_valorpermor decimal(9,6);
define counter integer;
define v_ciclo integer;
define sql_err integer;
define v_plaza char(3);
define w_plazomin, w_plazomax smallint;
define w_tasa_int,w_codigo char(8);
   begin
      on exception set sql_err
	 if sql_err <> 0 then
	    let w_codigo = sql_err;
   return cod_ret,w_codigo,w_rangomin,w_rangomax,w_valorperfis,w_valorpermor
          with resume;
         end if
      end exception;



let counter=0;
let v_ciclo=0;
let cod_ret="000";
let w_codigo = " ";
let w_valorpermor = 0;
let w_valorperfis = 0;
let w_rangomax = 0;
let w_rangomin = 0;
let w_tasa_int = " ";
let w_plazomin = 0;
let w_plazomax = 0;

select plaza into v_plaza from bdinteg:si_sucursales
where empresa = pempresa and sucursal = psucursal;
if v_plaza is null then
	let cod_ret = "102";
   return cod_ret,w_codigo,w_rangomin,w_rangomax,w_valorperfis,
          w_valorpermor;
end if

foreach alfa_cursor with hold for
   select sv_plazotasa.tasa,plazo_min,plazo_max,rangomin,rangomax,
      valorperfis,valorpermor
      into w_codigo,w_plazomin,w_plazomax,w_rangomin,w_rangomax,
      w_valorperfis,w_valorpermor
      from sv_plazotasa, bdinteg:si_tasavlor
      where sv_plazotasa.empresa = pempresa and
            sv_plazotasa.cod_instrum = pcod_instrum and
            sv_plazotasa.plaza = v_plaza and
            bdinteg:si_tasavlor.empresa = sv_plazotasa.empresa and
            bdinteg:si_tasavlor.tasa = sv_plazotasa.tasa
      order by plazo_min,sv_plazotasa.tasa,rangomin
	if w_valorperfis<0 then
		let w_valorperfis=0;
	end if
        let v_ciclo=v_ciclo+1;
        if v_ciclo<=pnumreg then
	   continue foreach;
        end if
	if w_valorpermor<0 then
		let w_valorpermor=0;
	end if
   return cod_ret,w_codigo,w_rangomin,w_rangomax,w_valorperfis,w_valorpermor
          with resume;
   let counter=counter+1;
end foreach;
end
end procedure;