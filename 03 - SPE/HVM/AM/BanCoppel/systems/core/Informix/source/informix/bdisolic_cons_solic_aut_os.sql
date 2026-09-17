create procedure "informix".cons_solic_aut_os(pempresa char(3),
 						          psucursal char(4),
							    pfecha date,
			                            pnumreg integer)
returning 	char(5),
		char(20),
		date,
		date,
		char(1),
		char(8),
		char(110),
		char(255),
		char(255),
		char(255),
            char(120);

define cod_ret char(5);
define counter integer;
define v_ciclo integer;
define sql_err integer;
define w_codigo char(20);

define vsolicitud        char(20);
define vfecha_solicitud  date;
define vfecha_respuesta  date;
define vstatus           char(1);
define vusuario_solicita char(8);
define vusuario_gestor   char(110);
define vobs1             char(255);
define vobs2             char(255);
define vobs3             char(255);
define vnombrecliente    char(120);

   begin
      on exception set sql_err
	 if sql_err <> 0 then
	    let w_codigo = sql_err;
   return cod_ret,vsolicitud, vfecha_solicitud, vfecha_respuesta, vstatus, 
          vusuario_solicita, vusuario_gestor, vobs1, vobs2, vobs3, vnombrecliente with resume;
         end if
      end exception;


let counter=0;
let v_ciclo=0;
let cod_ret="000";
let w_codigo = " ";

foreach alfa_cursor with hold for
    select a.num_solicitud, a.fecha_solicitud, a.fecha_respuesta, a.status, a.usuario_solicita,
           a.usuario_gestor, nvl(a.observacion1, " "), nvl(a.observacion2," "), nvl(a.observacion3," "), 
           trim(c.nombre1) || " " || trim(c.nombre2) || " " || trim(c.apell_paterno) || 
           " " || trim(c.apell_materno) || " " || c.razon_social as nombrecliente
      into vsolicitud, vfecha_solicitud, vfecha_respuesta, vstatus, vusuario_solicita, 
           vusuario_gestor, vobs1, vobs2, vobs3, vnombrecliente
      from bdisolic:ss_solicitud_os a, ss_solicitudes b, bdinteg:si_cliente c
     where a.empresa = pempresa and b.num_solicitud = a.num_solicitud and b.sucursal = psucursal and
           fecha_respuesta = pfecha and b.empresa = a.empresa and b.num_solicitud = a.num_solicitud and
	     c.numcte = b.numcte
      order by num_solicitud

        let v_ciclo=v_ciclo+1;
        if v_ciclo<=pnumreg then
	   continue foreach;
        end if
   return cod_ret, vsolicitud, vfecha_solicitud, vfecha_respuesta, vstatus, vusuario_solicita, 
          vusuario_gestor, vobs1, vobs2, vobs3, vnombrecliente with resume;
   let counter=counter+1;
end foreach;
end
end procedure;