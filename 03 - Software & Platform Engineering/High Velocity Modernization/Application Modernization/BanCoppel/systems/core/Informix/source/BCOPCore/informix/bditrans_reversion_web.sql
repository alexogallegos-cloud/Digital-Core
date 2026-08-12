CREATE PROCEDURE  "informix".reversion_web(pempresa char(3),
               psucursal char(3),
			   pusuario  char(8),
			   pfolio    char(16),
                           ptipo_rev char(1))
      returning char(5);

--####################################################################
--Se definen variables
--####################################################################
define v_status_ok,
       v_status_liq    char(1);
define v_codret        char(5);
define v_rowid,
       v_rowid2        integer;
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
let v_codret     = "00000";
let v_status_ok  = "";
let v_status_liq = "";
let v_rowid      = "";
let v_rowid2     = "";

--####################################################################
-- Rutina Principal
--####################################################################


BEGIN
   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

   select cve_en_transito,cve_liquidado into v_status_ok,v_status_liq
      from st_param
      where empresa = pempresa;

	let pempresa = pempresa;
	let pfolio = pfolio;

   foreach
      select md.rowid, mt.rowid, mt.status_docto, md.num_transacc,
             mt.moneda, mt.tipo_docto, s.plaza
	 into v_rowid, v_rowid2, v_status_docto, v_numtran,
              v_moneda, v_tipdocto, v_plaza
         from st_movdia md, st_maetrans mt, bdinteg:si_sucursales s
         where md.sucursal = s.sucursal
			   and md.tipo_docto = mt.tipo_docto
               and md.num_docto  = mt.num_docto
               and md.folio_suc  = pfolio
               and md.empresa    = mt.empresa
               and md.empresa    = s.empresa
			   and md.empresa    = pempresa

      if v_rowid is null then
	 let v_codret = "00988";
         return v_codret;
      end if;

      select tran_pago into v_tranpago
         from st_producto
         where empresa = empresa and moneda = v_moneda
               and tipo_docto = v_tipdocto;

      if v_status_docto = v_status_liq and v_numtran <> v_tranpago then
         let v_codret="00988";
         return v_codret;
      end if;

      begin
	 update st_movdia
            set cancelad = "S"
            where empresa = pempresa and folio_suc = pfolio_suc;
      end;

      if v_status_docto = v_status_ok then
         begin
	    delete from st_maetrans
	       where rowid = v_rowid2;
         end;
      end if;

      if v_status_docto = v_status_liq then
         begin
	    update st_maetrans set(status_docto)=(v_status_ok)
	       where rowid = v_rowid2;
         end;
      end if;
      continue foreach;
   end foreach;

   if pfolio is not null then
      foreach
         execute procedure bdicheq:reversion_web(pempresa,psucursal,
	                   pusuario,pfolio,ptipo_rev) into v_codret

      end foreach;
   end if;

   return v_codret;
end;     -- fin del on exception
end procedure;