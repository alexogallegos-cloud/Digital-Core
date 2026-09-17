create procedure "informix".sp_msjcatalogos23(pcvetipopago integer,pdescripcion varchar(100),
                                              paceptacionbca char, pvalorf smallint,
                                              ptipofuncion integer,
				              pvalort smallint,cadena char(1000))

returning char(5), integer;

--// ***************************************************************************
--// sp_msjcatalogos23 
--// Version              1.0.0
--// Obejtivo:            Procesa Catalogos
--// Parametros de Entrada:
--//          pcvetipopago  : Clave Tipo de Pago
--//          pdescripcion  : Descripcion
--//          paceptacionbca: Obligatorio por Banxico
--//          ptipofuncion  : tipo de funcion
--//          pvalort       : si es vigente
--//          pvalorf       : aceptacion del banco
--//          cadena        : detalle tipo pago-banco
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
define i       integer;
define vposini integer;
define vposfin integer;
define v_caracter char(1);
define bInserto  varchar(3);

     on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
	   return vcodret,0;
	end if
     end exception;

     --set debug file to "/tmp/sp_msjcatalogos23.out";
     --trace on;


     let vcodret = "000";
     let vstatus = 0;

     IF NOT EXISTS (SELECT *
                      FROM tbltipopago
                     WHERE intcvetipopago = pcvetipopago) THEN
	insert into tbltipopago(intcvetipopago,vchrdescripcion,chraceptacionbca,chraceptacionbco,
        		        inttipofuncion,dtmultactualizacio,chrvigente)
             values (pcvetipopago,pdescripcion,paceptacionbca,pvalorf,ptipofuncion,current,pvalort);
        LET vstatus = 1;
     ELSE
	update tbltipopago
           set vchrdescripcion = pdescripcion,
               chraceptacionbca = paceptacionbca,
               inttipofuncion = ptipofuncion,
               dtmultactualizacio = current,
               chrvigente = pvalort
         where intcvetipopago = pcvetipopago;
     END IF;

--//Inicializa Variables para el FOR
   let vcodret = "000";
   let vposini = 1; 
   let vposfin = 0;
   let var1    = "";

       --//Realiza la separacion de la cadena, para realizar el INSERT
       FOR i = 1 to LENGTH(cadena)
	   let v_caracter = substr(cadena, i,i);
           let v_caracter = v_caracter;
     	    if v_caracter = "|" OR v_caracter = "#" then
               let vposfin = i - vposini;
               IF var1 = "" THEN
                   let var1 = substr(cadena, vposini,vposfin); 
               END IF
               Let vposini = i +1;
               IF v_caracter = "#" then
                  --//Inserta el Registro
                  IF NOT EXISTS (SELECT * FROM tblTipopago_bco
                                  WHERE intcvetipopago = pcvetipopago
                                    AND cvecesif = var1) THEN
                     INSERT INTO tblTipopago_bco(intcvetipopago,cvecesif)
                          VALUES (pcvetipopago,var1);
                     LET pcvetipopago = pcvetipopago;
                     LET var1 = var1;
                     LET bInserto = "OK";
                  ELSE
                     LET pcvetipopago = pcvetipopago;
                     LET var1 = var1;
                     LET bInserto = "NOK";
                     EXIT FOR;
                  END IF
                  LET var1= ""; 
               end if
            end if
       END FOR


return vcodret,vstatus;

end procedure;