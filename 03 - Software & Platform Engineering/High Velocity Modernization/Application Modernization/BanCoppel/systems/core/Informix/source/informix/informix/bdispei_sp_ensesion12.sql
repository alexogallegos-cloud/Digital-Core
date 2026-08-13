create procedure "informix".sp_ensesion12(pcvecesif integer)

returning char(5);
--// ***************************************************************************
--// sp_ensesion12
--// Version              1.0.0
--// Obejtivo:            Reversar pagos de SPEI realizados
--// Parametros de Entrada:
--//          pcvecesif  : Clave del Banco
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


   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret;
	end if
   end exception;

  --//FLAG DEBUG
  --SET DEBUG FILE TO "/tmp/sp_ensesion12.out";
  --TRACE ON;

   LET vcodret = "000";
	
   --//Inicializa el indice del banco a negativo
   UPDATE tblbanco SET intindice = cvecesif * -1
    WHERE cvecesif >= 0;

   --//Marca el indice de los certificado de la institucion
   UPDATE tblcertificado SET chrestatus = "P" 
    WHERE cvecesif = pcvecesif 
      AND chrestatus =  "A";

   --//Inicializa el indice de los certificados otros bancos
   UPDATE tblcertificado SET chrestatus = "Z" 
    WHERE intpkcertificado >= 0
      AND chrestatus <> "P";

return vcodret;

end procedure;