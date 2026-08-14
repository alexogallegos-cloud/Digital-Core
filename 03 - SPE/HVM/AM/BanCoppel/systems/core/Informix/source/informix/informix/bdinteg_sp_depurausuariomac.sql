create procedure "informix".sp_depurausuariomac()
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Depura la Tabla si_macejecutivo, donde los registros tengan status T y la vigencia vencida
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  09/03/2007
       
       define vcodret	char(5);
       define sql_err	integer;
       define vEjecutivo         char(8);
       define vSucursal         char(4);
       define vDepartamento         char(3);
       define vPuesto         char(3);
       define vPerfil             int;
       define vMac                  char(12);
       define vStatus                 char(1);
       define vUser         char(8);

Let vcodret = '000';
Let vEjecutivo = "";
Let vSucursal = "";
Let vDepartamento = "";
Let vPuesto = "";
Let vPerfil = 0;
Let vMac = "";
Let vStatus = "";
Let vUser = "";


Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;
	

        Foreach
                              
                Select mac.ejecutivo, eje.sucursal, eje.departamento, eje.puesto, eje.perfil, mac.mac, mac.status, mac.user_insert  
                Into vEjecutivo ,vSucursal ,vDepartamento,vPuesto,vPerfil,vMac,vStatus,vUser 
                from si_macejecutivo mac
                inner join si_ejecut eje
                on mac.ejecutivo = eje.ejecutivo
                where mac.status = 'T' or eje.vigencia < current

                Execute Procedure sp_manejamacejecutivo('001','2',vEjecutivo ,vSucursal ,vDepartamento,vPuesto,vPerfil,vMac,vStatus,vUser) into vcodret;

        End Foreach;

        Return vcodret; 

end;
End procedure
;