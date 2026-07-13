create procedure "informix".sp_asignamacsucursal(pTipo char(1),pUser char(8),pRuta char(100))
        returning char(5)
       
define vcodret	char(5);
define sql_err	integer;
define vsql char(100);

Let vcodret = '000';
Let vsql = '';

Begin
	
	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;

    delete from si_maclistadosucursal;

      let vsql = 'echo "LOAD FROM ' || TRIM(pRuta) ||
                 ' INSERT INTO si_maclistadosucursal" > /tmp/cargasm.sql';
      SYSTEM vsql;

     let vsql = '';

     let vsql = 'dbaccess bdinteg  /tmp/cargasm.sql';
     SYSTEM vsql;

     Execute Procedure sp_cargamacsucursal(pUser) into vcodret;

    Return vcodret; 

end;
End procedure;