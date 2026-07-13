CREATE PROCEDURE "informix".sp_reprocesoreplicacompor(dFecha Date)
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
--DEFINE  dFecha           Date;
DEFINE  iVal             INTEGER; 
DEFINE  iVal2             INTEGER; 
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET iVal = 0;
   LET iVal2 = 0 ;
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
  -- let dFecha ='10/20/2012'
   
set isolation to dirty read;
set lock mode to wait 3;

    --    select {+INDEX(mi_fechas idx_mi_fechas)} fecha_ant into dFecha  from bdmis:mi_fechas where empresa = '001';
		let P_MENSAJE ='paso 1';
	    Select {+INDEX(mi_comportamientohis idx_mi_comportamientohis)} sum(apertura_cap)into iVal from bdmis:mi_comportamientohis where fecha = dFecha;
		Select {+INDEX(mi_comportamiento idx_mi_comportamiento)} sum(apertura_cap)into iVal2 from bdmis:mi_comportamiento where fecha = dFecha;
		
		IF iVal is Null  and iVal2 is Null  then		
			select * from bdmis:mi_tmpcomportamiento
			into temp tmp_mi_tmpcomportamiento;
		
	        truncate table mi_tmpcomportamiento;
			--tarjetas de Debito Aperturadas
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
	        select {+INDEX(bdicheq:sc_maenoc noc1)} chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant)
	        from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
	        where chq.cuenta = noc.cuenta and noc.fecha_alta = dFecha
	        and chq.producto  in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '01')
	        group by chq.sucursal,chq.producto;

			--Tarjetas de Debito Totales
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
	        select {+INDEX(bdicheq:sc_maechq bdicheq)} chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant)
	        from bdicheq:sc_maechq chq
            	where chq.status_cta <> 2 
	        and chq.producto in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '01')
	        group by chq.sucursal,chq.producto;
	      let P_MENSAJE ='paso 2';  
	        --Productos de Inversion Por Dia
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
			select {+INDEX(bdinvers:sv_maeinv mai2)} inv.sucursal,inv.cod_instrum,count(*),sum (inv.capital)
	        from bdinvers:sv_maeinv inv
	        where inv.cod_instrum in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '03')
			and inv.fecha_alta = dFecha or inv.fec_reinversion = dFecha
	        group by inv.sucursal,inv.cod_instrum;
	        
	        --Productos de Inversion Totales Por Dia
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
	        select {+INDEX(bdinvers:sv_maeinv mai2)}  inv.sucursal,inv.cod_instrum,count(*),sum (inv.capital)
	        from bdinvers:sv_maeinv inv
	        where inv.cod_instrum in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '03')
	        and inv.status_cta = '1'
	        group by inv.sucursal,inv.cod_instrum;
	        
	        
			--Tarjetas de Credito Aperturadas
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_col,saldo_col)
	        select {+INDEX(bdicred:sd_maecred idx_idx_maecredb), +INDEX(bdicred:sd_maesdos idx_sd_maesdos)} cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
	        from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
	        where cred.num_producto in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '06')
	               and cred.fecha_apertura = dFecha
	        and dos.num_credito = cred.num_credito 
                and (cred.cod_caract_2 not like "BC%" or cred.cod_caract_2 is null)
	        group by cred.sucursal,cred.num_producto;
let P_MENSAJE ='paso 3';
			--Tarjetas de Credito Totales
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_col,totsaldo_col)
	        select {+INDEX(bdicred:sd_maecred idx_idx_maecredb), +INDEX(bdicred:sd_maesdos idx_sd_maesdos)} cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
	        from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
	              where cred.num_producto in (select {+INDEX(mi_producto idx_mi_producto)} num_producto from bdmis:mi_producto where num_sistema = '06')
	        and dos.num_credito = cred.num_credito 
                and (cred.cod_caract_2 not like "BC%" or cred.cod_caract_2 is null)
                and cred.status_cred <> "CV"
	        group by cred.sucursal,cred.num_producto;

	        --Solicitudes Recibidas en el Dia
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,recibidas_sol,producto)
	        select  {+INDEX(bdisolic:ss_solicitudes empsol), +INDEX(bdisolic:ss_anexosol)} sol.sucursal,count(*),'6001'
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
	        group by sol.sucursal;


	        --Autorizadas y Entregadas de Inmediato
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,autyent_sol,monto_autyent_sol,producto)
	        select  {+INDEX(bdisolic:ss_solicitudes empsol), +INDEX(bdisolic:ss_anexosol)} sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where sol.status_solicitud = 'AP'
	        and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
	        group by sol.sucursal;
let P_MENSAJE ='paso 4';
	        --Autorizadas no Entregadas
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto)
	        select sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where sol.status_solicitud = 'AT'
	        and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
	        group by sol.sucursal;
	    
     	--truncate table mi_comportamiento;

			--Pasar la informacion de la tmpcomportamiento ala mi_comportamiento
		--	insert into bdmis:mi_comportamiento (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
			--apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
			select {+FULL} num_sucursal,producto,sum(apertura_cap) as apertura_cap,sum(saldo_cap) as saldo_cap,sum(totaper_cap)as totaper_cap,sum(totsaldo_cap) as totsaldo_cap,sum(apertura_col) as apertura_col,sum(saldo_col) as saldo_col,sum(totaper_col) as totaper_col,sum(totsaldo_col) as totsaldo_col,
			sum(recibidas_sol) as recibidas_sol ,sum(autyent_sol) as autyent_sol,
			sum(monto_autyent_sol) as monto_autyent_sol,sum(autnoent_sol) as autnoent_sol,sum(monto_autnoent_sol) as monto_autnoent_sol,dFecha as fecha
			from bdmis:mi_tmpcomportamiento
			group by num_sucursal,producto
			into temp mi_comportamiento_temp;
			
				--Respaldar la informacion ala tabla historial
			insert into bdmis:mi_comportamientohis (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
			apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
			select {+FULL} num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
			apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha
			from mi_comportamiento_temp;
		let P_MENSAJE ='Proceso Exitoso';	
		
		insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto)
		select num_sucursal,autnoent_sol,monto_autnoent_sol,producto from tmp_mi_tmpcomportamiento;
       else
			LET P_COD_RET = '00050';
			LET P_MENSAJE = 'ERROR: ESTE DIA YA SE PROCESO';
       end if;
		
		
		
   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;