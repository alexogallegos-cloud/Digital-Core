CREATE procedure "informix".sp_ensesion3(pcvecesif integer,pnomcorto varchar(20),
                                         pintindice integer,pedobco char,
                                         pbcoreceptivo char)

returning char(5);
--// ***************************************************************************
--// sp_ensesion3
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


   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret;
	end if
   end exception;

  --//FLAG DEBUG
  --SET DEBUG FILE TO "/tmp/sp_ensesion3.out";
  --TRACE ON;

   LET vcodret = "000";
   IF NOT EXISTS (SELECT * 
                   FROM tblbanco 
                  WHERE cvecesif = pcvecesif) THEN
      INSERT INTO tblbanco(cvecesif,vchrnombrecorto,intindice,vchrnombre,chredobco,chrbcoreceptivo)
           VALUES (pcvecesif,pnomcorto,pintindice,"",pedobco,pbcoreceptivo); 
   ELSE
      UPDATE tblbanco 
         SET vchrnombrecorto = pnomcorto,
             intindice = pintindice,
             chredobco = pedobco,
             chrbcoreceptivo = pbcoreceptivo
       WHERE cvecesif = pcvecesif;	
   END IF;
	
return vcodret;

end procedure;