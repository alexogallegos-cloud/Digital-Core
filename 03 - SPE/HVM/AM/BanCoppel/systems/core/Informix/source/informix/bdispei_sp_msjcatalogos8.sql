CREATE procedure "informix".sp_msjcatalogos8(pcvetipotraspaso integer,
                                         pdescripcion varchar(100),ptipofuncion integer,pvalort smallint)

returning char(5), int;
--// ***************************************************************************
--// sp_msjcatalogos8
--// Version              1.0.0
--// Obejtivo:            Procesa Ensesion
--// Parametros de Entrada:
--//          pcvetipotraspaso  : Clave del Traspaso
--//          pdescripcion      : Descripcion 
--//          ptipofuncion      : Tipo de Funcion
--//          pvalort           : Vigente
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
define vstatus	int;


   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret, 0;
	end if
   end exception;

  --//FLAG DEBUG
  --SET DEBUG FILE TO "/tmp/sp_msjcatalogos8.out";
  --TRACE ON;

   LET vstatus = 0;
   LET vcodret = "000";
   IF NOT EXISTS (SELECT * 
                   FROM tbltipotraspaso
                  WHERE intcvetipotrasp = pcvetipotraspaso) THEN
      INSERT INTO tbltipotraspaso(intcvetipotrasp,vchrdescripcion,inttipofuncion,chrvigente)
             VALUES (pcvetipotraspaso,pdescripcion,ptipofuncion,pvalort); 
      LET vstatus = 1;
   ELSE
      UPDATE tbltipotraspaso
         SET vchrdescripcion = pdescripcion,
             chrvigente = pvalort,
             inttipofuncion = ptipofuncion
         WHERE intcvetipotrasp = pcvetipotraspaso;	
   END IF;
	
return vcodret, vstatus;

end procedure;