create procedure "informix".clave(pempresa char(3),
                       pnumcte char(20),
		       pcapital	money(14,2),
		       pplazo	smallint,
		       pinstrumento char(4),
		       ptasa        decimal(9,6),
		       psobretasa   decimal(9,6))
returning char(5), integer;

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err, isam_err integer; 
   define v_sucursal char(4);
   define v_usuario char(8);
   define v_contrato char(9);
   define v_clave char(13);
   define v_numaut, v_hay, longitud smallint;
   define v_numero  integer;
   define v_current char(12);
   define v_fecha   date;
   define v_inversiones smallint;
   define v_long_cte char(2);



-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret = "000";
   let v_clave = " ";

-- ***************************************************************************
-- Evalua lo parametros de entrada
-- ***************************************************************************
   if ptasa      is null or
      ptasa      < 0    or
      psobretasa is null or
      psobretasa < 0     or
      pnumcte  is null or
      pplazo     is null then
      let cod_ret = "110";
      return cod_ret, v_clave;
   end if

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_clave;
         end if;
      end exception;
-- ***************************************************************************
-- Valida que la tasa sea correcta
-- ***************************************************************************
   if ptasa < 0 then
      let cod_ret = "902";
      return cod_ret, v_clave;
   end if

-- ***************************************************************************
-- Valida que la sobretasa sea correcta
-- ***************************************************************************
   if psobretasa < 0 then
      let cod_ret = "903";
      return cod_ret, v_clave;
   end if

-- ***************************************************************************
-- Extrae el id del usuario de la tabla de ejecutivos
-- ***************************************************************************
   select ejecutivo into v_usuario from bdinteg:si_ejecut
   where ejecutivo = USER;
   if v_usuario is null then
      let cod_ret = "127";
      return cod_ret, v_clave;
   end if


-- ***************************************************************************
-- Determina el numero de autorizacion
-- ***************************************************************************
   let v_current = current hour to fraction;
   let v_current = v_current[1,2]||v_current[4,5]||v_current[7,8]||
                   v_current[10,11];
   let v_numero = v_current;     

   select count(*) into v_hay
	from sv_autorizacion
	where empresa = pempresa and clave = v_numero and
	      instrumento = pinstrumento;
   if  v_hay != 0 then
	  let v_numero = v_numero + 1;
   end if
-- ***************************************************************************
-- Asigna la hora fecha de autorizacion
-- ***************************************************************************
select fecha_hoy into v_fecha
	from sv_fechas
        where empresa = pempresa;

-- ***************************************************************************
-- Determina la clave
-- ***************************************************************************
   let v_clave=v_numero;

-- ***************************************************************************
-- Graba en la tabla de autorizaciones
-- ***************************************************************************
   insert into sv_autorizacion
   values(pempresa,v_clave, pinstrumento, pcapital, pplazo, ptasa, psobretasa,
	  pnumcte,v_usuario, v_fecha, "N"); 
	  

end;    -- fin del on exception
return cod_ret, v_clave;
end procedure;