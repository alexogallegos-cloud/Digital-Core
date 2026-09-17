create procedure "informix".sp_dispersionprogramada_bpi(pidempresa char(3),pnumcte char(9),pnombrearchivo char(20))
returning char(5);

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
	DEFINE cFolio 			CHAR(16);
	DEFINE cMensaje 		CHAR(50);

	LET vsqlerr = 0;
    LET vcodret = "000";
	LET cFolio = '';
	LET cMensaje = " ";

	--SET debug FILE TO "/home/informix/ivonne/sp_dispersionprogramada_bpi.out";
	--Trace ON;

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
			insert into bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)values(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);
            return vcodret;
        end if;
    end exception;

    call sp_cargadividearchivonomina_bpi(pnombrearchivo)
		returning vcodret, cFolio, cMensaje;

    IF 	vcodret <> "00000" THEN
		LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION';
	ELSE
		LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE';
	END IF;

	insert into bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)values(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);

    return vcodret;

    END;

end procedure;