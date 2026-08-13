create procedure "informix".conavales(pempresa char(3),
                                      pnum_credito char(20))
       returning char(5),char(60),char(40),char(40),char(40),
                 char(20),char(5),char(13),char(13);

define vcalle char(40);
define vcolonia char(40);
define vdeleg_munic char(20);
define ventre_calles char(40);
define vcod_postal char(5);
define vtelefono1 char(13);
define vtelefono2 char(13);
define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;
define vtipo_dir char(20);
define vnumaval char(20);
define vaval char(60);

let vciclo = 0;
let vcodret = "000";
let vcalle = " ";
let vcolonia = " ";
let vdeleg_munic = " ";
let ventre_calles = " ";
let vcod_postal = " ";
let vtelefono1 = " ";
let vtelefono2 = " ";
let vaval = " ";
let vnumaval = "xx";



begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vaval,vcalle,vcolonia,ventre_calles,
                vdeleg_munic,vcod_postal,vtelefono1,vtelefono2;
      end if;
   end exception;

foreach
   select nvl(trim(nombre1),"")||" "||nvl(trim(nombre2),"")||
          " "||nvl(trim(apellido_p),"")||" "|| nvl(trim(apellido_m),""),
          calle,colonia,trim(ciudad)||" "||trim(estado),
             trim(municipio),cod_postal,num_int,num_ext
         INTO vaval,vcalle,vcolonia,vdeleg_munic,
             ventre_calles,vcod_postal,vtelefono1,vtelefono2
      from bdigaran:sg_aval
      where num_credito = pnum_credito[1,8]

      if trim(vaval) = "" or vaval is null then
	 let vcodret = "000";
         return vcodret,vaval,vcalle,vcolonia,ventre_calles,
             vdeleg_munic,vcod_postal,vtelefono1,vtelefono2;
      else
         return vcodret,vaval,vcalle,vcolonia,ventre_calles,
             vdeleg_munic,vcod_postal,vtelefono1,vtelefono2 with resume;
      end if   
	
end foreach
      if trim(vaval) = "" or vaval is null then
	 let vcodret = "000";
         return vcodret,vaval,vcalle,vcolonia,ventre_calles,
             vdeleg_munic,vcod_postal,vtelefono1,vtelefono2;
      end if   

end
end procedure
