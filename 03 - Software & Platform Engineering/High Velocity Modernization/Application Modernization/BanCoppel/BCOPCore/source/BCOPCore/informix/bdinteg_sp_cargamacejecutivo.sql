create procedure "informix".sp_cargamacejecutivo()
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Inserta registros de la si_maclistadoejecutivo a la si_macejecutivo
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  16/03/2007
       
       define vcodret	char(5);
       define sql_err	integer;
        define vEjecutivo         char(8);
       define vPuesto         char(3);
       define vUser         char(8);
       define vSucursal         char(4);
       define vDepartamento         char(3);

Let vcodret = '000';
Let vEjecutivo = "";
Let vPuesto = "";
Let vUser = "";
Let vSucursal = "";
Let vDepartamento = "";

Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;
	
        Foreach
                Select distinct m.ejecutivo, e.puesto, e.sucursal, e.departamento, e.user_insert 
                into vEjecutivo, vPuesto, vSucursal,vDepartamento,vUser                
                from si_maclistadoejecutivo m
                inner join si_ejecut e 
                on m.ejecutivo=e.ejecutivo
                
                if (nvl(vSucursal,0) <> 0 or nvl(vSucursal,'') <> '') and nvl(vDepartamento,0)  = 0  then
                    Execute Procedure sp_manejamacejecutivo('001',1,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','A',vUser)  into vcodret;
                end if
         End Foreach;

        Return vcodret; 

end;
End procedure
;