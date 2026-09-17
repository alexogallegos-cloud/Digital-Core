create procedure "informix".calc_isr(pempresa char(3),
                          pcapital     money(14,2),
			  pdias        integer,
			  pnumdias_int integer)
returning char(5), money(14,2);

define cod_ret char(5);
define v_imp_isr money(14,2);
define v_fecha_rec date;
define v_tasa_isr decimal(9,6);
define sql_err, isam_err integer;
define vanio integer;
define vresiduo integer;
define vaniobase integer;
define vfecha_hoy date;
on exception set sql_err, isam_err

if sql_err <> 0 or isam_err <> 0 then
   let cod_ret = sql_err;
end if
end exception;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
let v_tasa_isr     = 0;
let v_imp_isr       = 0;
let vaniobase      = 365;

-- ****************************************************************************
-- Obtiene fecha de hoy
-- ****************************************************************************
select fecha_hoy
  into vfecha_hoy
  from sv_fechas
 where empresa = pempresa;

let vanio = year(vfecha_hoy);
let vresiduo = mod(vanio, 4);
if vresiduo = 0 then
   let vaniobase = 366;
end if

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
if pcapital is null then
   let cod_ret = "110";
   return cod_ret, v_imp_isr;
end if

-- ****************************************************************************
-- Extrae los valores de ISR de la Tabla de Parametros
-- ****************************************************************************
   -- Obtiene la fecha maxima de la tasa de I.S.R.
   select max(fecha) into v_fecha_rec
      from bdinteg:si_fechavalor
      where empresa = pempresa and tasa ="I.S.R.";

   select valor into v_tasa_isr
      from bdinteg:si_fechavalor
      where empresa = pempresa and tasa = "I.S.R." and fecha = v_fecha_rec;

    -- Calcula la Retencion del ISR
       let v_imp_isr = pcapital * v_tasa_isr/100/vaniobase*pdias;
       let cod_ret = "000";
       if v_imp_isr is null then
	  let v_imp_isr = 0;
       end if
   return cod_ret, v_imp_isr;
end procedure;