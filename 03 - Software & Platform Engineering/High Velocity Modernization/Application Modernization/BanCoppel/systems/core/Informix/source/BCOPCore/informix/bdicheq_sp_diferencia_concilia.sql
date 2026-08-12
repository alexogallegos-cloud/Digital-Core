CREATE PROCEDURE "informix".sp_diferencia_concilia(pempresa char (3))
	RETURNING char (5);
	
	--Definir variables 
	DEFINE vcodret1  CHAR(5);
	DEFINE sql_err INTEGER;
    DEFINE vfecha_ant date;
   
	--Inicializar variables 
	LET vcodret1 = "00000";		
	LET sql_err  = 0;		
	LET vfecha_ant  = '';	

	
BEGIN
 
----Control de Errores no Controlados
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
           Let vcodret1 = sql_err;    
           RETURN vcodret1;
       END IF;
	END EXCEPTION;
	
	
	--SET DEBUG FILE TO "/informix/vamilan/sp_diferencia_concilia.out";
	--TRACE ON;
		
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	-- // Obtener la fecha de ayer sc_fechas
    SELECT fecha_ant 
		INTO vfecha_ant
		FROM sc_fechas
    WHERE empresa = pempresa;
	
	
SELECT a.folio_suc, a.fech_alt, b.num_cte, a.cuenta, a.transacc, c.descripcion,
		trim(c_ccmayor)||
		trim(c_ccsub)||
		trim(c_ccsubsub)||
		trim(c_ccsssub)||
		trim(c_ccssssub)||
		trim(c_sector) cuenta_cargo,
		trim(a_ccmayor)||
		trim(a_ccsub)||
		trim(a_ccsubsub)||
		trim(a_ccsssub)||
		trim(a_ccssssub)||
		trim(a_sector) cuenta_abono,
		a.monto_tot
	FROM sc_movhis a, sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d
	WHERE fech_alt = vfecha_ant
		and transacc = "0251"
		and cancelad <> "S"
		and a.cuenta = b.cuenta
		and a.transacc = c.numero
		and c.sistema = "01"
		and a.transacc = d.transaccion
		and b.producto = d.producto
		and d.sistema = "01"
		UNION ALL
			SELECT a.folio_suc, a.fech_alt, b.num_cte, a.cuenta, a.transacc, c.descripcion,
			trim(c_ccmayor)||
			trim(c_ccsub)||
			trim(c_ccsubsub)||
			trim(c_ccsssub)||
			trim(c_ccssssub)||
			trim(c_sector) cuenta_cargo,
			trim(a_ccmayor)||
			trim(a_ccsub)||
			trim(a_ccsubsub)||
			trim(a_ccsssub)||
			trim(a_ccssssub)||
			trim(a_sector) cuenta_abono,
			a.monto_tot
		FROM sc_movhis_old a, sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d
		WHERE fech_alt = vfecha_ant
			and transacc = "0251"
			and cancelad <> "S"
			and a.cuenta = b.cuenta
			and a.transacc = c.numero
			and c.sistema = "01"
			and a.transacc = d.transaccion
			and b.producto = d.producto
			and d.sistema = "01" 
		INTO temp tmp_tabla1  WITH NO LOG;
		
	SELECT
		a.folio_suc, a.fech_alt, b.num_cte, a.cuenta, a.transacc, c.descripcion,
		trim(c_ccmayor)||
		trim(c_ccsub)||
		trim(c_ccsubsub)||
		trim(c_ccsssub)||
		trim(c_ccssssub)||
		trim(c_sector) cuenta_cargo,
		trim(a_ccmayor)||
		trim(a_ccsub)||
		trim(a_ccsubsub)||
		trim(a_ccsssub)||
		trim(a_ccssssub)||
		trim(a_sector) cuenta_abono,
		a.monto_tot
	FROM sc_movhis a, sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d
	WHERE fech_alt = vfecha_ant
		and transacc = "0419"
		and a.producto = "1100"
		and cancelad <> "S"
		and a.cuenta = b.cuenta
		and a.transacc = c.numero
		and c.sistema = "01"
		and a.transacc = d.transaccion
		and b.producto = d.producto
		and d.sistema = "01"
		UNION ALL
		SELECT
			folio_suc, a.fech_alt, b.num_cte, a.cuenta, a.transacc, c.descripcion,
			trim(c_ccmayor)||
			trim(c_ccsub)||
			trim(c_ccsubsub)||
			trim(c_ccsssub)||
			trim(c_ccssssub)||
			trim(c_sector) cuenta_cargo,
			trim(a_ccmayor)||
			trim(a_ccsub)||
			trim(a_ccsubsub)||
			trim(a_ccsssub)||
			trim(a_ccssssub)||
			trim(a_sector) cuenta_abono,
			a.monto_tot
		FROM sc_movhis_old a, sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d
		WHERE fech_alt = vfecha_ant 
			and transacc = "0419"
			and a.producto = "1100"
			and cancelad <> "S"
			and a.cuenta = b.cuenta
			and a.transacc = c.numero
			and c.sistema = "01"
			and a.transacc = d.transaccion
			and b.producto = d.producto
			and d.sistema = "01"
		INTO temp tmp_tabla2 WITH NO LOG;
	
insert into sc_diferencia_concilia (fecha_alt, num_cte, cuenta_eje, transacc_cta_eje, descripcion_cta_eje, cta_cargo_cta_eje,
cta_abono_cta_eje, importe_cta_eje, invers_crecte, transacc_invers_crecte, descripcion_invers_crecte, cta_cargo_invers_crecte,
monto_cargo,cta_abono_invers_crecte,monto_abono, importe_invers_crecte, diferencia)
select
    fech_alt,
	num_cte,
	cuenta,
	transacc,
	descripcion,
	cuenta_cargo,
	cuenta_abono,
	monto_tot,
	' ',
	' ',
	' ',
	' ',
    monto_tot,
	' ',
    0,
	0,
	monto_tot
	from
	(	 
		select
		fech_alt,
		num_cte,
		cuenta,
		transacc,
		descripcion,
		cuenta_cargo,
		cuenta_abono,
		monto_tot,
		' ',
		' ',
		' ',
		' ',
		' ',
		0
		from tmp_tabla1 a  
		where a.folio_suc not in(select b.folio_suc from tmp_tabla2 b
		                          where a.folio_suc = b.folio_suc
								    and a.fech_alt = b.fech_alt
									and a.monto_tot = b.monto_tot)
		UNION ALL
			select
			fech_alt,
			num_cte,
			cuenta,
			transacc,
			descripcion,
			cuenta_cargo,
			cuenta_abono,
			monto_tot,
			' ',
			' ',
			' ',
			' ',
			' ',
			0
		from tmp_tabla2 b
		where b.folio_suc not in(select a.folio_suc from tmp_tabla1 a
		                          where a.folio_suc = b.folio_suc
								    and a.fech_alt = b.fech_alt
									and a.monto_tot = b.monto_tot)
									
) diferenciaFolio_tmp_tabla1_tmp_tabla2;

		RETURN vcodret1;
	
END
END PROCEDURE;