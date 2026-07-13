CREATE PROCEDURE "informix".del_co_historico (pempresa CHAR(4),pfecha_hoy date)
RETURNING VARCHAR(5);
define p_rowid 	       int;
define pcontador       int;

   let pcontador = 0;
     foreach with hold
     select rowid into p_rowid from bdicont:co_historico 
     where usuario is not null
	   and control_poliza is not null
       and fecha_captura >= pfecha_hoy
	   and secuencia > 0
       and empresa = pempresa 

    if pcontador = 0 then
      Begin work;
    end if 
     
     delete from bdicont:co_historico
     where rowid = p_rowid;

    let pcontador = pcontador + 1;
    if pcontador = 10000 then
       commit work;
       let pcontador = 0;
    end if
     end foreach;
    if pcontador > 0 then
       commit work;
    end if

return '000';
end procedure;