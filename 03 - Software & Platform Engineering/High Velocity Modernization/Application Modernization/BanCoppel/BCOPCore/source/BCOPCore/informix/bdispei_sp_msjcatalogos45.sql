create procedure "informix".sp_msjcatalogos45(pcvetipocuenta integer,
                                              pdescripcion varchar(100),
                                              pvalort smallint,
                                              cadena char(1000))

returning char(5), integer;

--// ***************************************************************************
--// sp_msjcatalogos45
--// Version              1.0.0
--// Obejtivo:            Procesa Catalogos
--// Parametros de Entrada:
--//          pcvetipocuenta : Clave Tipo de cuenta
--//          pdescripcion   : Descripcion
--//          pvalort        : Aceptacion del banco y vigente
--//          cadena         : Detalle tipo cuenta-ctavostro
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

define vcodret		char(5);
define vsqlerr		integer;
define vstatus		integer;

--//Variables para el FOR
define var1    varchar(50);
define var2    varchar(100);
define var3    varchar(50);
define i       integer;
define vposini integer;
define vposfin integer;
define v_caracter char(1);

     on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret,0;
	end if
     end exception;

     --set debug file to "/tmp/sp_msjcatalogos45.out";
     --trace on;


     let vcodret = "000";
     let vstatus = 0;

     IF NOT EXISTS (SELECT *
                      FROM tbltipocuenta
                     WHERE intcvetipocuenta = pcvetipocuenta) THEN
	insert into tbltipocuenta(intcvetipocuenta,vchrdescripcion,
                                  chraceptacionbco,chrvigente)
	     values (pcvetipocuenta, pdescripcion, pvalort, pvalort);
        LET vstatus = 1;
     ELSE
	update tbltipocuenta
           set vchrdescripcion = pdescripcion,
               chrvigente = pvalort
         where intcvetipocuenta = pcvetipocuenta;
     END IF;

--//Inicializa Variables para el FOR
   let vposini = 1; 
   let vposfin = 0;
   let var1    = "";
   let var2    = "";
   let var3    = "";

       --//Realiza la separacion de la cadena, para realizar el INSERT
       FOR i = 1 to LENGTH(cadena)
	   let v_caracter = substr(cadena, i,i);
           let v_caracter = v_caracter;
     	    if v_caracter = "|" OR v_caracter = "#" then
               let vposfin = i - vposini;
               IF var1 = "" THEN
                   let var1 = substr(cadena, vposini,vposfin); 
               ELIF  var2 = "" THEN
                   let var2 = substr(cadena, vposini,vposfin); 
               ELIF var3 = "" THEN
                   let var3 = substr(cadena, vposini,vposfin); 
               END IF
               Let vposini = i +1;
               IF v_caracter = "#" then
                  --//Inserta el Registro
                  INSERT INTO tbltctavostro (intcvetipocuenta, intcvetctavostro, vchrDescripcion, chrVigente)
                       VALUES (pcvetipocuenta, var1, var2, var3);
                  LET var1= ""; 
                  LET var2= ""; 
                  LET var3= ""; 
               end if
            end if
       END FOR


return vcodret, vstatus;

end procedure;