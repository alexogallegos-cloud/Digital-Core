CREATE PROCEDURE "informix".sp_depurar_historico(pfecha date ) 
RETURNING
CHAR(5) as cod_ret,
CHAR(100) as msj; 

DEFINE    mensaje           char (100);
DEFINE	  iSqlErr           INTEGER;

BEGIN
	ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					RETURN iSqlErr,'';
				END IF;
	END EXCEPTION;	

	let mensaje       = '';
	let iSqlErr       = 000 ;

	INSERT INTO bdmis:mi_rptcierresuchis2 (empresa, sucursal, ejecutivo, nombre, producto, fecha_cierre, num_ctasdia, meta_ctasdia, 
		p_cumpmetactas, monto_ctasdia, monto_incrementodia, meta_incremento, p_cumpsaldo, num_abonosctascap, monto_abonosctascap, 
		num_abonosctascred, monto_abonosctascred, p_rec_vs_pagomin, p_rec_vs_vencido, num_clientel_act, num_compago, num_acuerdopago, 
		num_cons_edocta, num_retirocapta, monto_retirocapta, num_retirocoloca, monto_retirocoloca) 
	select {+INDEX(bdmis:mi_rptcierresuchis idx_fecha_cierre)} 
	* from bdmis:mi_rptcierresuchis
	where fecha_cierre < today - 62;
						
						
	IF (DBINFO('sqlca.sqlerrd2') > 0)  THEN	
	
		delete {+INDEX(bdmis:mi_rptcierresuchis idx_fecha_cierre)} 
		from bdmis:mi_rptcierresuchis
		where fecha_cierre <  today - 62;

		let mensaje = 'EL PROCESO PUEDE CONTINUAR';
		return iSqlErr, mensaje;
		
	end if;
end;
end procedure;