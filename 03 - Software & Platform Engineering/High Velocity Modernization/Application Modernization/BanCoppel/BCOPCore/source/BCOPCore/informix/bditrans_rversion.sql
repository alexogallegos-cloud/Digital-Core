create procedure  "informix".rversion(psucursal char(3),
			   pusuario  char(8),
			   pfolio    char(16)) returning char(5);

--####################################################################
--Se definen variables
--####################################################################
define v_status_ok,
       v_status_liq    char(1);
define v_codret,
       v_codret2       char(5);
define v_rowid,
       v_rowid2        integer;
define v_counter,
       v_contador      smallint;
define sql_err,
       isam_err        integer;
define v_status_docto  char(1);
define v_numtran,
       v_tranpago      char(4);
define v_moneda        char(2);
define v_plaza         char(3);
define v_tipdocto      char(2);

--####################################################################
-- Se inicializan variables
--####################################################################
let v_codret     = "000";
let v_contador   = 0;
let v_status_ok  = "";
let v_status_liq = "";
let v_rowid      = "";
let v_rowid2     = "";

--####################################################################
-- Rutina Principal
--####################################################################


begin
   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;


   select cve_en_transito, cve_liquidado into v_status_ok, v_status_liq
      from st_param;

   foreach
      select md.rowid, mt.rowid, mt.status_docto, md.num_transacc,
             mt.moneda, mt.tipo_docto, s.plaza
	 into v_rowid, v_rowid2, v_status_docto, v_numtran,
              v_moneda, v_tipdocto, v_plaza
         from st_movdia md, st_maetrans mt, bdicent:si_sucursales s
         where md.tipo_docto = mt.tipo_docto
           and md.num_docto  = mt.num_docto
           and md.sucursal   = s.sucursal
           and md.folio_suc  = pfolio
           and md.sucursal   = psucursal

      if v_rowid is null then
         --***************************************
         --* No existen movimientos en el diario *
         --***************************************
	 let v_codret = "988";
         return v_codret;
      end if;

      select tran_pago into v_tranpago from st_producto
         where plaza  = v_plaza
           and moneda = v_moneda
           and tipo_docto_rel = v_tipdocto;

      if v_status_docto = v_status_liq and v_numtran <> v_tranpago then
         let v_codret="988";
         return v_codret;
      end if;

      begin
	 delete from st_movdia where rowid = v_rowid;
      end;

      --AQUI ENTRA EN FOREACH ?

      if v_status_docto = v_status_ok then
         begin
	    update st_maetrans set(status_docto)=("S")
	       where rowid = v_rowid2;
         end;
      end if;

      if v_status_docto = v_status_liq then
         begin
	    update st_maetrans set(status_docto)=(v_status_ok)
	       where rowid = v_rowid2;
         end;
      end if;

      if pfolio is not null then
	 foreach
            execute procedure bdicheq:reversion(psucursal,
	                                        pusuario,
					        pfolio) into v_codret2
         end foreach;
         let v_codret = v_codret2;
      end if;

      return v_codret;
   end foreach
end;     -- fin del on exception
end procedure;