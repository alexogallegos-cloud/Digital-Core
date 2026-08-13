create procedure "informix".sp_actualizamacejecutivo()
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Actualiza la Tabla si_macejecutivo 
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
       define vArea         char(2);
       define vAreaTmp         char(2);

Let vcodret = '000';
Let vEjecutivo = "";
Let vSucursal = "";
Let vDepartamento = "";
Let vPuesto = "";
Let vPerfil = 0;
Let vMac = "";
Let vStatus = "";
Let vUser = "";
Let vArea = "";
Let vAreaTmp = "";

Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;
	

        Foreach
                              
                Select mac, sucursal, area 
                into vMac, vSucursal, vArea
                from si_sucursalesmaquina 
                where sucursal <> '0000'
                and mac Not in (Select mac From si_macejecutivo)

                Foreach
                        Select distinct mac.ejecutivo, eje.puesto, mac.status
                        into vEjecutivo, vPuesto, vStatus
                        from si_ejecut eje
                        inner join si_macejecutivo mac
                        on eje.ejecutivo = mac.ejecutivo
                        and eje.sucursal = vSucursal

                        Select area 
                        into vAreaTmp
                        From si_macarea 
                        where sucursal = vSucursal
                        and puesto = vPuesto;

                        if nvl(vAreaTmp,'0') <> '0' then
                            if vAreaTmp = vArea then
                                Insert into si_macejecutivo (empresa, mac, ejecutivo, status, user_insert, fecha_insert)
                                values('001',vMac, vEjecutivo, vStatus, 'Informix',current);
                            else
                                Let vcodret = '002';
                            end if;
                        else
                            Let vcodret = '001';
                        end if;
                        
                        
                end Foreach;


        End Foreach;

        Return vcodret; 

end;
End procedure
;