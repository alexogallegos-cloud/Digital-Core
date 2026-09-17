CREATE PROCEDURE "informix".sp_replicacomportamiento()
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
DEFINE  iVal             INTEGER; 
DEFINE  iVal2             INTEGER; 
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- Creado por Manuel Osuna                                   --*
-- Modificado por Fabiola Corrales 31/Ago/2007               --*
-- Debug del Procedure                                       --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                      --*
 --TRACE ON;                                                 --*
--**************************************************************

LET iVal = 0;
LET P_COD_RET = '00000';
LET P_MENSAJE = 'PROCESO EXITOSO';
   
set isolation to dirty read;
set lock mode to wait 3;

select {+INDEX(mi_fechas idx_mi_fechas)} fecha_ant into dFecha from bdmis:mi_fechas where empresa = '001';

Select count (*) into iVal from bdmis:mi_comportamientohis where fecha = dFecha;
--	Select {+INDEX(mi_comportamiento idx_mi_comportamiento)} sum(apertura_cap)into iVal2 from bdmis:mi_comportamiento where fecha = dFecha;

IF iVal = 0   then		

--    truncate table mi_tmpcomportamiento;
			--tarjetas de Debito Aperturadas
			/*
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
	        select {+INDEX(bdicheq:sc_maenoc noc1)} chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant)
	        from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
	        where noc.fecha_alta = dFecha and chq.cuenta = noc.cuenta   
	        and chq.producto  in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '01')
	        group by chq.sucursal,chq.producto;
			
			operacion se realiza por medio de SP_RCDA_APERTURAS
*/
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)	
	select  {+INDEX(bdicheq:sc_maechq bdicheq)} chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant)  
	from bdicheq:sc_maechq chq, bdicheq:sc_producto prod
	where chq.status_cta <> "2" and chq.producto not in ('1300','1800') 
	and prod.producto = chq.producto   
	group by chq.empresa,chq.sucursal,chq.producto; 

	        --inversion pagare por dia
	   /*     insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
			select {+INDEX(bdinvers:sv_maeinv mai7)} inv.sucursal,inv.cod_instrum,count(*),sum (inv.capital)
	        from bdinvers:sv_maeinv inv,bdmis:mi_producto prod
	        where inv.fecha_alta = dFecha or inv.fec_reinversion = dFecha
			and inv.cod_instrum = prod.num_producto  and prod.num_sistema = '03'
	        group by inv.sucursal,inv.cod_instrum;
			
			operacion se realiza por medio de SP_RCDA_APERTURAS
			*/  
	--inversion pagare totales
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
	select sucursal,cod_instrum,count(*)as conteo,sum(capital)as capital
	from bdinvers:sv_maeinv
	where  status_cta = '1' 
	--and empresa = '001' 
	group by sucursal,cod_instrum;
	
	--Tarjetas de Credito Aperturadas
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_col,saldo_col)
	select {+INDEX(bdicred:sd_maecred idx_idx_maecredb), +INDEX(bdicred:sd_maesdos idx_sd_maesdos),+INDEX(mi_producto idx_mi_producto)} 
	cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
	from bdicred:sd_maecred cred, bdicred:sd_maesdos dos,mi_producto prod
	where cred.fecha_apertura = dFecha
	and dos.num_credito = cred.num_credito 
	and (cred.cod_caract_2 not in('BC1','BC2') or cred.cod_caract_2 is null)
	and cred.num_producto = prod.num_producto 
	and prod.num_sistema = '06'
	group by cred.sucursal,cred.num_producto;
		
	--Tarjetas de Credito Totales
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_col,totsaldo_col)
	select {+INDEX(bdicred:sd_maecred idx_idx_maecredb), +INDEX(bdicred:sd_maesdos idx_sd_maesdos),+INDEX(mi_producto idx_mi_producto)} cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
	from bdicred:sd_maecred cred, bdicred:sd_maesdos dos,mi_producto prod
	where dos.num_credito = cred.num_credito 
	and (cred.cod_caract_2 not in('BC1','BC2') or cred.cod_caract_2 is null) 
	and cred.status_cred <> "CV"
	and cred.num_producto = prod.num_producto 
	and prod.num_sistema = '06'
	group by cred.sucursal,cred.num_producto;
						
	--Solicitudes Recibidas en el Dia
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,recibidas_sol,producto)
	select  {+INDEX(bdisolic:ss_solicitudes empsol), +INDEX(bdisolic:ss_anexosol idx_ss_anexosol1)} sol.sucursal,count(*),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where ane.fecha_sol =dFecha and ane.num_solicitud = sol.num_solicitud
	group by sol.sucursal;

	--Autorizadas y Entregadas de Inmediato
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,autyent_sol,monto_autyent_sol,producto)
	select  {+INDEX(bdisolic:ss_solicitudes idx_solicitudes1), +INDEX(bdisolic:ss_anexosol idx_ss_anexosol1)} sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where ane.fecha_sol =dFecha and sol.status_solicitud = 'AP'  
	and ane.num_solicitud = sol.num_solicitud  
	group by sol.sucursal;

	--Autorizadas no Entregadas
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto)
	select {+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes1), +INDEX(bdisolic:ss_anexosol idx_ss_anexosol1)} sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where ane.fecha_sol =dFecha and sol.status_solicitud = 'AT'
	and ane.num_solicitud = sol.num_solicitud   
	group by sol.sucursal;

	--Respaldar la informacion ala tabla historial
	insert into bdmis:mi_comportamientohis (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
	apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
	select {+FULL} num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
	apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha
	from bdmis:mi_comportamiento;

	truncate table mi_comportamiento;

	--Pasar la informacion de la tmpcomportamiento ala mi_comportamiento
	insert into bdmis:mi_comportamiento (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
	apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
	select {+FULL} num_sucursal,producto,sum(apertura_cap),sum(saldo_cap),sum(totaper_cap),sum(totsaldo_cap),sum(apertura_col),sum(saldo_col),sum(totaper_col),sum(totsaldo_col),
	sum(recibidas_sol),sum(autyent_sol),
	sum(monto_autyent_sol),sum(autnoent_sol),sum(monto_autnoent_sol),dFecha
	from bdmis:mi_tmpcomportamiento
	group by num_sucursal,producto;
	
else
	LET P_COD_RET = '00050';
	LET P_MENSAJE = 'ERROR: ESTE DIA YA SE PROCESO';
end if;

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;