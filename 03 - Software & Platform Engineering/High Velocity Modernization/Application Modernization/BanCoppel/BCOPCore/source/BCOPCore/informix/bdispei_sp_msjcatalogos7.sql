CREATE procedure "informix".sp_msjcatalogos7(pcvecausadev integer,
                                         pdescripcion varchar(100),pvalort char(4))

returning char(5),integer;
--// ***************************************************************************
--// sp_msjcatalogos7
--// Version              1.0.0
--// Obejtivo:            Procesa Ensesion
--// Parametros de Entrada:
--//          pcvecesif  : Clave del Banco 
--//          pnomcorto  : Nombre corto banco
--//          pintindice : Indice del Banco
--//          pedobco    : Estado Actual del Banco
--//          pbcoreceptivo : Receptivo
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
	   return vcodret,0;
	end if
   end exception;

  --//FLAG DEBUG
  --SET DEBUG FILE TO "/tmp/sp_msjcatalogos7.out";
  --TRACE ON;

   LET vstatus = 0;
   LET vcodret = "000";
   IF NOT EXISTS (SELECT * 
                   FROM tblcausadev 
                  WHERE intcvecausadev = pcvecausadev) THEN
      INSERT INTO tblcausadev(intcvecausadev,vchrdescripcion,chrvigente)
           VALUES (pcvecausadev,pdescripcion,pvalort); 
      LET vstatus = 1;
   ELSE
      UPDATE tblcausadev
         SET vchrdescripcion = pdescripcion,
             chrvigente = pvalort
         WHERE intcvecausadev = pcvecausadev;	
   END IF;
	
return vcodret, vstatus;

end procedure;