CREATE PROCEDURE "informix".totcomp_web(pempresa char(3),
                                    pusuario char(8),
                                    psucursal char(4),
                                    pnum_total smallint)

	RETURNING CHAR(5),CHAR(2),MONEY(16,2),MONEY(16,2),
	MONEY(16,2),MONEY(16,2),CHAR(40),INTEGER,INTEGER,INTEGER,INTEGER;


   DEFINE v_monto_cargo,v_monto_cero,v_monto_firme,v_monto_sbc MONEY(16,2);
   DEFINE v_movto_cargo,v_movto_rem, v_movto_firme,v_movto_sbc INTEGER;
   DEFINE v_descripcion CHAR(40);
   DEFINE v_contador    SMALLINT;
   DEFINE v_fecha       DATE;
   DEFINE v_row INTEGER;
   DEFINE w_sucursal CHAR(4);
   DEFINE w_plaza CHAR(3);
   DEFINE v_codret CHAR(5);
   DEFINE sql_err,isam_err INTEGER;
   DEFINE v_producto CHAR(4);
   DEFINE v_ciclo SMALLINT;
   DEFINE v_moneda CHAR(2);
   
   LET v_contador    = 0;
   LET v_ciclo       = 0;
   LET v_moneda      = 0;
   LET v_monto_cero  = 0;
   LET v_monto_cargo = 0;
   LET v_monto_firme = 0;
   LET v_monto_sbc   = 0;
   LET v_movto_cargo = 0;
   LET v_movto_firme = 0;
   LET v_movto_sbc   = 0;
   LET v_movto_rem   = 0;
   LET v_descripcion = " ";


	BEGIN
		ON EXCEPTION SET sql_err,isam_err
			if sql_err <> 0 or isam_err <> 0 then
				let v_codret = sql_err;
				return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
					   v_monto_sbc,v_monto_cero,v_descripcion,v_movto_cargo,
				v_movto_firme,v_movto_sbc,v_movto_rem;
			end if;
		END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/totcomp_web.out';
	--TRACE ON;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    select {+ INDEX (sv_fechas idx_fechas)} fecha_hoy into v_fecha
      from sv_fechas
      where empresa = pempresa;
    delete from sv_totcomp
      where empresa = pempresa and usuario=pusuario;
   
	FOREACH
		select {+ INDEX (sv_instrum ix470_1)} count(*),sum(monto_tot),moneda into
		 v_movto_cargo,v_monto_cargo,v_moneda
		from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
		where md.empresa = pempresa and  md.usuario = pusuario and 
		   cancelad <> "S" and
		   tr.empresa = md.empresa and tr.numero = md.transacc and
		   tr.naturaleza = "C" and tr.realizada_por = "1" and tr.sistema = "03" and 
		   pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and
		   md.sucursal = psucursal
		group by moneda

		insert into sv_totcomp values(pempresa,pusuario,v_moneda,v_monto_cargo,0,0,v_movto_cargo,0,0);
	END FOREACH;

    FOREACH
		select {+ INDEX (sv_instrum ix470_1)} count(*),sum(monto_tot - en_sbc),moneda
		 into v_movto_firme,v_monto_firme,v_moneda
		 from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
		where md.empresa = pempresa and md.usuario = pusuario and
			   cancelad <> "S" and monto_tot <> en_sbc and
			   tr.empresa = md.empresa and tr.numero = md.transacc and
			   tr.naturaleza = "A" and tr.realizada_por = "1" and tr.sistema = "03" and
			   pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and 
			   md.sucursal = psucursal
		group by moneda
		
		select rowid into v_row
		 from sv_totcomp
		 where empresa = pempresa and usuario = pusuario and moneda = v_moneda;
		
		if v_row is not null then
			update sv_totcomp
			set(monto_firme,movto_firme) = (v_monto_firme,v_movto_firme)
			where rowid=v_row;
		else
			insert into sv_totcomp
			values(pempresa,pusuario,v_moneda,0,v_monto_firme,0,
			   0,v_movto_firme,0);
		end if;
    END FOREACH;

   FOREACH
		select {+ INDEX (sv_instrum ix470_1)} count(*),sum(en_sbc),moneda
         into v_movto_sbc,v_monto_sbc,v_moneda
         from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
		where md.empresa = pempresa and  md.usuario = pusuario and     
               cancelad <> "S" and en_sbc > 0 and
               tr.empresa = md.empresa and tr.numero = md.transacc and
               tr.naturaleza = "A" and tr.realizada_por = "1" and tr.sistema = "03" and
               pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and
               md.sucursal = psucursal
		group by moneda
      
	    select rowid into v_row
         from sv_totcomp
         where empresa = pempresa and usuario = pusuario and moneda = v_moneda;
      
		if v_row is not null then
			update sv_totcomp
            set(monto_sbc,movto_sbc) = (v_monto_sbc,v_movto_sbc)
			where rowid=v_row;
        else
			insert into sv_totcomp
			values(pempresa,pusuario,v_moneda,0,0,v_monto_sbc,
	           0,0,v_movto_sbc,0);
      end if;
   END FOREACH;

   LET v_monto_cargo=0;
   LET v_monto_firme=0;
   LET v_monto_sbc=0;
   LET v_movto_cargo=0;
   LET v_movto_firme=0;
   LET v_movto_sbc=0;
   LET v_moneda="00";
   LET v_codret="00000";
   -- Extrae sucursal y plaza
   select sucursal into w_sucursal from bdinteg:si_ejecut
   where ejecutivo = pusuario;

   select plaza into w_plaza from bdinteg:si_sucursales
      where empresa = pempresa and sucursal = w_sucursal;
   
    IF(select count(*) from sv_totcomp tc,bdinteg:si_divisas di where tc.empresa = pempresa and usuario = pusuario and di.empresa = tc.empresa and di.divisa = moneda) > 0 THEN
	    FOREACH
		    select moneda,monto_cargo,monto_firme,monto_sbc,descripcion,
				 movto_cargo,movto_firme,movto_sbc
			 into v_moneda,v_monto_cargo,v_monto_firme,v_monto_sbc,
				  v_descripcion,v_movto_cargo,v_movto_firme,v_movto_sbc
			 from sv_totcomp tc,bdinteg:si_divisas di
			 where tc.empresa = pempresa and usuario = pusuario and
				   di.empresa = tc.empresa and di.divisa = moneda
			 order by moneda
		  LET v_ciclo=v_ciclo+1;
		  if v_ciclo<=pnum_total then
			 continue foreach;
		  end if
		  return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
		  v_monto_sbc,v_monto_cero,v_descripcion,v_movto_cargo,v_movto_firme,
		  v_movto_sbc,v_movto_rem  with resume;
		  LET v_contador=v_contador+1;
	   END FOREACH;
	ELSE
		LET v_codret = '00001';
		RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
		  v_monto_sbc,v_monto_cero,v_descripcion,v_movto_cargo,v_movto_firme,
		  v_movto_sbc,v_movto_rem;	
	END IF;	
   END;    --FIN DEL ON EXCEPTION
END PROCEDURE
