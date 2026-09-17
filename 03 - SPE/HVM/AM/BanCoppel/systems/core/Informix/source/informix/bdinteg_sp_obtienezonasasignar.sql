create procedure "informix".sp_obtienezonasasignar()

       returning 	char(5),smallint,smallint, char(32),smallint, char(40), smallint, date;

define vCodRet char(5);
define vsqlerr integer;

define vNumeroCiudad smallint;
define vNumeroColonia smallint;
define vNombreZona char(32);
define vNumeroCalle smallint;
define vNombreCalle char(40);
define vNumeroCobranzas smallint;
define vFechaActualizacion	date;

let vCodRet = "000";
let  vsqlerr = 0;

let vNumeroCiudad = 0;
let vNumeroColonia = 0;
let vNombreZona = "";
let vNumeroCalle = 0;
let vNombreCalle = "";
let vNumeroCobranzas = 0;
let vFechaActualizacion = "";

--08/Agosto/2007
--Alfredo Gpe. Avena Rocha
--Obtiene registros de la tabla si_replicazonasasignar

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vCodRet = vsqlerr;
         return vCodRet, vNumeroCiudad, vNumeroColonia,vNombreZona, vNumeroCalle, vNombreCalle, 	 vNumeroCobranzas, vFechaActualizacion;

      end if;
   end exception;

   foreach
      SELECT   nvl(numerociudad,0), nvl(numerocolonia,0), nvl(nombrezona,' '), nvl(numerocalle,0), nvl(nombrecalle,' '), nvl(numerocobranzas,0), nvl(fechaactualizacion,'01/01/1900'::date)
      INTO      vNumeroCiudad, vNumeroColonia,vNombreZona, vNumeroCalle, vNombreCalle, 	 vNumeroCobranzas, vFechaActualizacion
      FROM si_replicazonasasignar


      return    vCodRet, vNumeroCiudad, vNumeroColonia,vNombreZona, vNumeroCalle, vNombreCalle, 	 vNumeroCobranzas, vFechaActualizacion with resume;

   end foreach;

end
end procedure
;