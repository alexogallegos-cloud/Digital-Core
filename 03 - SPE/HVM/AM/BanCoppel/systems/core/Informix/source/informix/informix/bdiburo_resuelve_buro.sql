create procedure "informix".resuelve_buro(pempresa char(03), pnum_solicitud char(20) )
returning char(05),char(30);
define sql_err int;
define mensaje char(30);
define cod_ret char(05);
define vnumcte char(9);
define existe smallint;
let cod_ret = "000";
let mensaje = "";
BEGIN
ON EXCEPTION SET sql_err
   if sql_err <> 0 then
          RETURN cod_ret,mensaje;
   end if
END EXCEPTION;


select comentario,numcte
into  mensaje,vnumcte
from bdisolicitud:ss_captrescom
where num_solicitud = pnum_solicitud;
let existe = 0;
select count(*) into existe
 from bdiburo:br_tl
 where num_cliente = vnumcte;
if mensaje != "DIRECCION NO CORRESPONDE A BURO" and
                          mensaje != "RFC NO CORRESPONDE A BURO" then
   let mensaje = "";
   if existe = 0 then
      let mensaje="PROBLEMAS DE COMUNICACION ";
   end if
   if existe > 2 then
      let mensaje="LLEVA MAS DE DOS INTENTOS";
   end if
end if
return  cod_ret,mensaje;
end

end procedure
;