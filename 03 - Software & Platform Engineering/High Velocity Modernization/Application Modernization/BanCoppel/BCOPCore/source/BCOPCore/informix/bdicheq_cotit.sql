create procedure "informix".cotit(pempresa    char(3),
                                  pcuenta     char(20),
                                  preg_firmas char(1),
                                  pnombre     char(40))
returning char(3);
define cod_ret char(3);
define v_long_cta char(2);
define longitud smallint;
define sql_err integer;

begin
   on exception set sql_err
      if sql_err <> 0 then
        let cod_ret = sql_err;
        return cod_ret;
      end if;
   end exception;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret = "000";


-- ***************************************************************************
-- Valida la informacion de entrada
-- ***************************************************************************
   if pcuenta = "" or
      preg_firmas = "" or
      pnombre = "" then
      let cod_ret = "110";
      return cod_ret;
   end if;

-- ***************************************************************************
-- Valida el Regimen de Firmas 1 = Individual, 2 = Indistinta, 3 = Mancomunada
-- ***************************************************************************
if preg_firmas != "2" and
   preg_firmas != "3" then
   let cod_ret = "112";
   return cod_ret;
end if;

-- ***************************************************************************
-- Inserta en Tabla de Cotitulares
-- ***************************************************************************
   begin 
      insert into sc_cotitular
      values(pempresa,pcuenta, pnombre);
   end
   return cod_ret;
end
end procedure;