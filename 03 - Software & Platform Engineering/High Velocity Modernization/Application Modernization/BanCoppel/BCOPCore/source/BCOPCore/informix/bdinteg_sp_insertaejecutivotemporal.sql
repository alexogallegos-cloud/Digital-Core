create procedure "informix".sp_insertaejecutivotemporal()
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Actualiza la tabla si_macejecutivo
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  06/03/2007
       
       define vcodret	char(5);
       define sql_err	integer;
        define vEjecutivo         char(8);
       define vPuesto         char(3);
       define vUser         char(8);

Let vcodret = '000';
Let vEjecutivo = "";
Let vPuesto = "";
Let vUser = "";



Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;
	
        Foreach
                Select distinct m.ejecutivo, e.puesto, e.user_insert 
                into vEjecutivo, vPuesto, vUser                
                from si_macejecutivo m
                inner join si_ejecut e 
                on m.ejecutivo=e.ejecutivo
                and m.ejecutivo <> '91443041'
                and m.ejecutivo <> '91307341'

                Execute Procedure sp_manejamacejecutivo('001',1,vEjecutivo,'0004','000', vPuesto,0,'','T',vUser)  into vcodret;
         End Foreach;

        Return vcodret; 

end;
End procedure
;