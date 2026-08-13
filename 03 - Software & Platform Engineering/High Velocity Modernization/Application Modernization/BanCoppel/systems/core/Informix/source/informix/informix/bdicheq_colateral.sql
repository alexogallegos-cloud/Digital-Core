create procedure "informix".colateral(pempresa char(3),
                           pusuario    char(8),
                           pfuncion    char(1),
                           pcuenta     char(20),
                           pcta_col1   char(20),
                           pcta_col2   char(20),
                           pcta_col3   char(20),
                           pcta_col4   char(20),
                           pcta_col5   char(20))

   returning char(5);

   define cod_ret char(5);
   define madicionado, vadicionado, vmodificado char(5);
   define vstatus_cta char(1);
   define v_cal_int_chq char(1);
   define col char(20);
   define v_long_cta char(2);
   define longitud smallint;
   define vcuenta, mcuenta, mcta_col char(20);
   define msecuencia, num_sec, i , longiud smallint;
   define mfecha_alta, vfecha_alta, vfecha_mod, fecha date;
   define sql_err integer;
   define v_usuario char(8);
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
let cod_ret = "000";

begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

-- ****************************************************************************
-- Valida el tipo de funcion a realizar A = alta, C = cambio
-- ****************************************************************************
if pfuncion = "A" or pfuncion = "C" then
else
   let cod_ret = "116";
   return cod_ret;
end if

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
if pusuario   = "" or
   pcuenta    = "" or
   pcta_col1   = "" then
   let cod_ret = "110";
   return cod_ret;
end if
select ejecutivo into v_usuario from bdinteg:si_ejecut
   where ejecutivo = pusuario;
if v_usuario <> pusuario then
   let cod_ret = "106";
   return cod_ret;
end if
if (pcta_col2 = "" and pcta_col3 <> "") or
   (pcta_col3 = "" and pcta_col4 <> "") or
   (pcta_col4 = "" and pcta_col5 <> "") then
   let cod_ret = "117";
   return cod_ret;
end if

-- ****************************************************************************
-- Validar de acuerdo a la funcion si debe o no existir en la tabla sc_colateral
-- ****************************************************************************
let col = "";
for i = 1 to 5
    if i = 1 then
       let col = pcta_col1;
    elif i = 2 then
       let col = pcta_col2;
    elif i = 3 then
       let col = pcta_col3;
    elif i = 4 then
       let col = pcta_col4;
    elif i = 5 then
       let col = pcta_col5;
    end if;
    if col = "0" or col is null or col = " " then
    else
       select cuenta, cta_col, adicionado, fecha_alta
              into mcuenta, mcta_col, madicionado, mfecha_alta
       from sc_colateral
       where empresa = pempresa and cuenta  = pcuenta and
             cta_col = col;
       if pfuncion = "A" then
          if mcuenta is null and mcta_col is null then
             select count(*) into msecuencia from sc_colateral
                where empresa = pempresa and cuenta = pcuenta;
             let num_sec = msecuencia;
             let num_sec = num_sec + i;
             if num_sec > 5 then
                let cod_ret = "119";
                return cod_ret;
             end if
          else
             let cod_ret = "108";
             return cod_ret;
          end if
       else
          if mcuenta = pcuenta and mcta_col = col then
             let msecuencia = 0;
          else
             let cod_ret = "109";
             return cod_ret;
          end if
       end if
    end if
end for;

-- ****************************************************************************
-- Validar que exista la cuenta eje en la tabla sc_maechq
-- ****************************************************************************
if pfuncion = "A" then
   select cuenta, status_cta
          into vcuenta, vstatus_cta
   from sc_maechq
   where empresa = pempresa and cuenta = pcuenta;
   if vcuenta = pcuenta then
   else
      let cod_ret = "100";
      return cod_ret;
   end if
   if vstatus_cta in("2","6","7") then
      let cod_ret = "200";
      return cod_ret;
   elif vstatus_cta = "3" then
      let cod_ret = "307";
      return cod_ret;
   end if
end if

-- ****************************************************************************
-- Validar que exista la cuenta colateral en la tabla sc_maechq
-- ****************************************************************************
let col = "";
for i = 1 to 5
    if i = 1 then
       let col = pcta_col1;
    elif i = 2 then
       let col = pcta_col2;
    elif i = 3 then
       let col = pcta_col3;
    elif i = 4 then
       let col = pcta_col4;
    elif i = 5 then
       let col = pcta_col5;
    end if;
    if col = "" or col = "0" or
       col is null then
    else
       let vcuenta = "";
       let vstatus_cta = "";
       select cuenta, status_cta
              into vcuenta, vstatus_cta
       from sc_maechq
       where empresa = pempresa and cuenta = col;
       if vcuenta = col then
       else
          let cod_ret = "107";
          return cod_ret;
       end if
       if vstatus_cta in("2","6","7") then
          let cod_ret = "200";
          return cod_ret;
       elif vstatus_cta = "3" then
          let cod_ret = "307";
          return cod_ret;
       end if
    end if
end for

 select fecha_hoy into fecha from sc_fechas where empresa = pempresa;

if pfuncion = "A" then
   let vadicionado = pusuario;
   let vfecha_alta = fecha;
   let vmodificado = "";
   let vfecha_mod  = "";
end if;
-- begin work;
if pfuncion = "C" then
   let vadicionado = madicionado;
   let vfecha_alta = mfecha_alta;
   let vmodificado = pusuario;
   let vfecha_mod  = fecha;
   delete from sc_colateral where empresa = pempresa and cuenta = pcuenta;
end if
let col = "";
for i = 1 to 5
    if i = 1 then
       let col = pcta_col1;
    elif i = 2 then
       let col = pcta_col2;
    elif i = 3 then
       let col = pcta_col3;
    elif i = 4 then
       let col = pcta_col4;
    elif i = 5 then
       let col = pcta_col5;
    end if;
    if col = "" or
       col is null then
    else
       if msecuencia is null then
          let msecuencia = 0;
       end if
       let msecuencia = msecuencia + 1;
       insert into sc_colateral
       values (pempresa,pcuenta, col, msecuencia, vadicionado, vfecha_alta,
               vmodificado, vfecha_mod);
    end if;
end for;
-- commit work;

-- ****************************************************************************
-- Graba la cuenta eje con cuentas colaterales en el Maestro de Cheques
-- ****************************************************************************
update sc_maechq
   set (colateral) = ("S")
   where empresa = pempresa and cuenta = pcuenta;
return cod_ret;
end
end procedure;