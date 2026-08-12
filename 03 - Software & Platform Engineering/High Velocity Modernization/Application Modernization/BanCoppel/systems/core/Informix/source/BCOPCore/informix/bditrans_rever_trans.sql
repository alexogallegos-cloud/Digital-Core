create procedure "informix".rever_trans(psucursal char(3), 
			     pusuario char(8), 
			     pfolio char(16)) returning char(5);

define v_status_ok, v_status_liq char(1);
define v_codret, v_codret2 char(5);
define v_rowid, v_rowid2 integer;
define v_counter, v_contador smallint;
define sql_err, isam_err integer; 
define v_status_docto char(1);

let v_codret="000";
let v_contador=0;


begin
      	on exception set sql_err,isam_err
         	if sql_err <> 0 or isam_err <> 0 then
            		let v_codret = sql_err;
	    		return v_codret;
         	end if;
      	end exception;


	select st_movdia.rowid, st_maetrans.rowid, status_docto 
		into v_rowid, v_rowid2, v_status_docto
		from st_movdia, st_maetrans 
		where folio_suc = pfolio;

	if v_rowid is null then
         ---*************************************************************
         ---* No existen movimientos en el diario o ya estan reversados *
         ---*************************************************************
		let v_codret="988";
        	return v_codret;
	end if;


	select cve_en_transito, cve_liquidado into v_status_ok, v_status_liq
		from st_param; 
begin
	delete from st_movdia where rowid=v_rowid;
end;

if v_status_docto = v_status_ok then
begin
	update st_maetrans
		set(status_docto)=("S")
		where rowid=v_rowid2;
end;
end if;
		
if v_status_docto=v_status_liq then
begin
	update st_maetrans
		set(status_docto)=(v_status_ok)
		where rowid=v_rowid2;
end;
end if;

if pfolio is not null then
		foreach
			execute procedure bdicheq:reversion(psucursal,
						   pusuario,
						   pfolio) into v_codret2
		end foreach;
end if;

return v_codret;
end;     -- fin del on exception
end procedure;