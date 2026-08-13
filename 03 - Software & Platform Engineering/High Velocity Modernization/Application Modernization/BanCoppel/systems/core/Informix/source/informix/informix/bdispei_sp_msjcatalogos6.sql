CREATE procedure "informix".sp_msjcatalogos6(pcvetipoperacion integer,
                                         pdescripcion varchar(100),pvalort char(1))

returning char(5), integer;
--// ***************************************************************************
--// sp_msjcatalogos6
--// Version              1.0.0
--// Obejtivo:            Procesa Ensesion
--// Parametros de Entrada:
--//          pcvetipoperacion  : Clave Tipo Operacion
--//          pdescripcion      : Descripcion
--//          pvalort           : Valor
--// Parametros de Salida:
--//    Codigo de Retorno      : '000' - Si el proceso fue existoso.
--//                            <> '000' - Indica el error ocurrido en el proceso.
--//    Descripcion            : Descripcion del error.
--// Creado por:          Alejandro Rueda Sanchez
--// ModIFicado por:
--// Ultima Modificacion: Noviembre - 2007
--//                      Creación de SPL
--// ***************************************************************************

--//Definicion de variables
define vcodret	char(5);
define vsqlerr	int;
define vstatus	integer;


   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret, 0;
	end if
   end exception;

  --//FLAG DEBUG
  --SET DEBUG FILE TO "/tmp/sp_msjcatalogos6.out";
  --TRACE ON;

   LET vstatus = 0;
   LET vcodret = "000";
   IF NOT EXISTS (SELECT * 
                   FROM tbltipooperacion 
                  WHERE intcvetpooperacion = pcvetipoperacion) THEN
      INSERT INTO tbltipooperacion(intcvetpooperacion,vchrdescripcion,chraceptacionbco,chrvigente)
           VALUES (lpad(pcvetipoperacion,2,"0"),pdescripcion,pvalort,pvalort); 
      LET vstatus = 1;
   ELSE
      UPDATE tbltipooperacion 
         SET vchrdescripcion = pdescripcion,
             chrvigente = pvalort
         WHERE intcvetpooperacion = pcvetipoperacion;	
   END IF;
	
return vcodret, vstatus;

end procedure;