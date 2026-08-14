create procedure "informix".sp_asignamacejecutivo(pTipo char(1),pUser char(8),pRuta char(100))
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

    delete from si_maclistadoejecutivo;

      let vsql = 'echo "LOAD FROM ' || TRIM(pRuta) ||
                 ' INSERT INTO si_maclistadoejecutivo" > /tmp/cargaem.sql';
      SYSTEM vsql;

     let vsql = '';

     let vsql = 'dbaccess bdinteg /tmp/cargaem.sql';
     SYSTEM vsql;

     Execute Procedure sp_cargamacejecutivo() into vcodret;

    Return vcodret;

end;
End procedure;