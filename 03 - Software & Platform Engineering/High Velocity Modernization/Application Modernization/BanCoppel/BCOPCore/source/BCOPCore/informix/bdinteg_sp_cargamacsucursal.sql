create procedure "informix".sp_cargamacsucursal(pUser char(8))
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Inserta registros de la si_maclistadosucursal a la si_sucursalesmaquina
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  16/03/2007
       
       define vcodret	char(5);
       define sql_err	integer;
       define vSucursal         char(4);
       define vIpMaquina                  char(16);
       define vMac                  char(12);
       define vArea         char(2);

Let vcodret = '000';
Let vSucursal = "";
Let vIpMaquina = "";
Let vMac = "";
Let vArea = "";

Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;
	
        Foreach
                Select m.sucursal, m.ipmaquina, m.mac, m.area
                into vSucursal,vIpMaquina,vMac,vArea
                from si_maclistadosucursal m
                inner join si_sucursales s
                on m.sucursal = s.sucursal
                
                if (nvl(vSucursal,0) <> 0 or nvl(vSucursal,'') <> '')   then
                    Execute Procedure sp_manejasucursalesmaquina('1','001',vSucursal,'000', vIpMaquina,vMac,vArea,pUser,Current) into vcodret;
                end if
         End Foreach;

        Return vcodret; 

end;
End procedure
;