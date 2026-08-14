CREATE PROCEDURE "informix".sp_reprecesoreportes(dFecha date)
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFechaini           Date;

BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
      
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
         
	delete from bdmis:mi_tmpcomportamiento;
	--->> REPORTE DE COMPORTAMIENTO <<-- ############################################################################################	
	
    --Aperturas Captación	
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
	select cont.sucursal,cont.producto,count(*),sum(cont.sdo_actual)
	from bdicheq:sc_maehiscont cont,bdicheq:sc_maenoc noc
	where cont.aniomes = trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer
	and cont.empresa = '001'
	and noc.cuenta = cont.cuenta
	and noc.empresa = cont.empresa
	and month(noc.fecha_alta) = month( dFecha)  and year(noc.fecha_alta) = year(dFecha)
	group by cont.sucursal,cont.producto;

	--Aperturas y saldos  de pagares
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)	
	select inv.sucursal,inv.cod_instrum,count(*),sum(inv.capital) as saldo
	from bdinvers:sv_maeinv inv
	where inv.cod_instrum = '3000'
		  and ((month(inv.fecha_alta) = month(dFecha ) and year(inv.fecha_alta) = year(dFecha )) or
               (month(inv.fec_reinversion) = month(dFecha) and month(inv.fec_reinversion) = month(dFecha) ))
			and inv.empresa = '001'            
	group by inv.sucursal,inv.cod_instrum;
	
	--Aperturas y saldos de Crédito
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_col,saldo_col)
	select sucursal,'6001',count(*) as tot_apert,sum(sdo_cap_insoluto) as tot_saldo
	from bdicred:sd_maesdoscont cont,bdicred:sd_maecred cred
	where cont.num_credito = cred.num_credito
	and month(cred.fecha_apertura) = month( dFecha) and year(cred.fecha_apertura) = year(dFecha)
	and cont.empresa = '001'
	and cont.empresa = cred.empresa
	and cont.fecha = dFecha
	group by 1;
	
	--Aperturas Acumuladas Captación
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
	select cont.sucursal,cont.producto,count(*),sum(cont.sdo_actual)
	from bdicheq:sc_maehiscont cont,bdicheq:sc_maenoc noc
	where cont.aniomes = trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer
	and cont.empresa = '001'
	and noc.cuenta = cont.cuenta
	and noc.empresa = cont.empresa
	and noc.fecha_alta <= dFecha
	group by cont.sucursal,cont.producto;
    
	--Aperturas y saldos Acumulados de Inversion
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
	select inv.sucursal,inv.cod_instrum,count(*),sum(inv.capital)
	from bdinvers:sv_maeinv inv
	where inv.cod_instrum = '3000'
	          and inv.fecha_alta <= dFecha or inv.fec_reinversion <= dFecha
	            and inv.empresa = '001'	            
	group by inv.sucursal,inv.cod_instrum;
	
	--Aperturas y saldos Acumulados de Crédito
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_col,totsaldo_col)
	select sucursal,'6001',count(*) as tot_apert,sum(sdo_cap_insoluto) as tot_saldo
	from bdicred:sd_maesdoscont cont,bdicred:sd_maecred cred
	where cont.num_credito = cred.num_credito
	and cred.fecha_apertura <= dFecha
	and cont.empresa = '001'
	and cont.empresa = cred.empresa
	and cont.fecha = dFecha
	group by 1;
	
	--Total de Solicitudes Recibidas en el Mes
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,recibidas_sol,producto)
	select  sol.sucursal,count(*),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where ane.num_solicitud = sol.num_solicitud 
	and month( ane.fecha_sol) = month(dFecha) and year( ane.fecha_sol) = year(dFecha)
	group by sol.sucursal;
		
	--Autorizadas y Entregadas de Inmediato
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,autyent_sol,monto_autyent_sol,producto)
	select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where sol.status_solicitud = 'AP'
	and ane.num_solicitud = sol.num_solicitud 
	and month( ane.fecha_sol) = month(dFecha) and year( ane.fecha_sol) = year(dFecha)
	group by sol.sucursal;
	
	--Autorizadas no Entregadas
	insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto)
	select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
	from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	where sol.status_solicitud = 'AT'
	and ane.num_solicitud = sol.num_solicitud 
	and month( ane.fecha_sol) = month(dFecha) and year( ane.fecha_sol) = year(dFecha)
	group by sol.sucursal;
		
	--Guardar en Historial
	insert into bdmis:mi_comportamiento_rep (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
	apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
	select num_sucursal,producto,sum(apertura_cap),sum(saldo_cap),sum(totaper_cap),sum(totsaldo_cap),sum(apertura_col),sum(saldo_col),sum(totaper_col),sum(totsaldo_col),
	sum(recibidas_sol),sum(autyent_sol),
	sum(monto_autyent_sol),sum(autnoent_sol),sum(monto_autnoent_sol),dFecha
	from bdmis:mi_tmpcomportamiento
	group by num_sucursal,producto;
	
    --->> REPORTE DE BANCA POR INTERNET <<-- ############################################################################################	
	INSERT INTO bdmis:mi_solbanint_rep(sucursal,id_status,fecha_registro,clientesreg,totalclientesreg)        
	select suc_registro,nvl(status,0),dFecha,
	    sum(case when tipo = 1 then num else 0 end) cte_reg,
	    sum(case when tipo = 2 then num else 0 end) tot_reg
	 from table (multiset(
	        select 1 as tipo,suc_registro,status,count(*) as num
	        from table( multiset (
	            select suc_registro,numcte,
	            case when f_status is not null and  id_status <> '10'  and date(f_registro) >= '04-02-2009'  then 
	            (select nvl(id_statusactual,0)  from table (multiset(
	                select limit 1  id_statusactual  FROM bdinteg:si_cambiostcte  where month(fecha_cambio) = month(dFecha) 
	                and year(fecha_cambio) = year(dFecha)  and numcliente =numcte order by  fecha_cambio desc)))
	            else id_status end  status
	            FROM bdinteg:si_bpiusuarios  si
	            where month(f_registro) = month(dFecha)  and year(f_registro) = year(dFecha)  ))
	        group by suc_registro,status
	        union all
	        select 2 as tipo,suc_registro,nvl(status,0),count(*) as num
	        from table( multiset (
	            select suc_registro,numcte,
	            case when f_status is not null and  id_status <> '10'  and date(f_registro) >= '04-02-2009'  then 
	            (select nvl(id_statusactual,0)  from table (multiset(
	                select limit 1  id_statusactual  FROM bdinteg:si_cambiostcte  where month(fecha_cambio) <= month(dFecha) 
	                and year(fecha_cambio) <= year(dFecha)  and numcliente =numcte order by  fecha_cambio desc)))
	            else id_status end  status
	            FROM bdinteg:si_bpiusuarios  si
	            where f_registro <= dFecha))
	        group by suc_registro,status))
	group by suc_registro,status;
	
	--->> REPORTE DE CARTERA VENCIDA<<-- ############################################################################################	
	INSERT INTO mi_carteravencidatotal_rep(ident,numpagos, numcreditos, capitalvigente, capitaltransitorio,
	capitalvdoexigible, capitalvdonoexigible,interesdelperiodo,interesvencido,interesmoratorios,fecha)
	select
	case when sdo_cap_insoluto < 0 then '<0'
	                        when sdo_cap_insoluto = 0 then '=0'
	                        when sdo_cap_insoluto > 0 then '>0'
	end ident ,num_periodos,
	count(*) as num_creditos,
	sum(dos.sdo_capital) as capitalvigente,
	sum(dos.monto_vencido) as capitaltransitorio,
	sum(dos.mto_venc_trasp) as capitalvdoexigible,
	sum(dos.cap_tras_no_venci) as capitalvdonoexigible,
	sum(dos.sdo_no_exig) as interesdelperiodo,
	sum(dos.int_tra_no_exig) as interesvencido,
	sum(dos.sdo_moratorio  + dos.sdo_contab_mora) as moratorios,dFecha
	from bdicred:sd_maecred mae
	inner join bdicred:sd_maesdoscont dos on mae.num_credito = dos.num_credito and mae.empresa = dos.empresa and dos.fecha = dFecha
	left outer  join  bdicred:sd_histvalcon con on  con.num_credito = dos.num_credito   and con.fecha_alta = dos.fecha and con.empresa = dos.empresa
	where  mae.empresa = '001'
	and status_cred <>  'CV'
	and (cod_caract_2 is null or cod_caract_2 NOT IN ('BC1','BC2'))
	group by 1,num_periodos;
	
	--->> REPORTE DE SOLICITUDES<<-- ############################################################################################	
	insert into bdmis:mi_solicitudes_rep(num_sucursal,status,totalstatus,ctenuevo,ctecoppel,fecha)
	select sucursal,
		 case  when tipo =1  then 'PC'  when tipo = 2 then 'BC'  when tipo = 3  then 'CC'
				   when tipo =  4 then 'EE'   when tipo =  5 then 'RT' when tipo =  6 then 'AT'
				   when tipo =  7 then 'AP'
		end tipo2,
	count(*) as total,
	 sum(case when fuente = 'B'   THEN 1 end) ctenuevo,
	  sum(case when fuente = 'T'    THEN 1 end) ctecoppel,dFecha
	from table (multiset(
						select ss.sucursal,aut. num_solicitud,max(aut.tipo) as tipo,fuente
						from table ( multiset (
												select num_solicitud,
												case  when status_solicitud = 'PC' then 1 when status_solicitud = 'BC' then 2
														   when status_solicitud = 'CC' then 3 when status_solicitud = 'EE' then 4
														   when status_solicitud = 'RT' then 5  when status_solicitud = 'AT' then 6
														   when status_solicitud = 'AP' then 7
												end tipo
												 from bdisolic:ss_autorizacion aut  
												where status_solicitud not in  ('AN','PC')
												and aut.fecha_entrada <= dFecha  )) aut ,
								  bdisolic:ss_solicitudes ss,
								  bdisolic:ss_resum_scor_fin scr
										where ss.num_solicitud = aut.num_solicitud
										and scr.num_solicitud = aut.num_solicitud
										and ss.empresa ='001'
										 and scr.empresa = ss.empresa
						group by ss.sucursal,aut.num_solicitud,fuente))
	group by sucursal,2;
	
	insert into bdmis:mi_solicitudes_rep(num_sucursal,status,totalstatus,ctenuevo,ctecoppel,fecha)
	select  sucursal,status_solicitud,sum(num) as total,
	SUM(case when fuente = 'B' THEN num  else 0 end) ctenuevo,
	SUM(case when fuente = 'T' THEN num else 0 end) ctecoppel,dFecha
	 from table ( multiset (
	select  max(aut.num_solicitud ),ss.numcte ,aut.status_solicitud ,ss.sucursal ,fuente,1 as num
	from bdisolic:ss_solicitudes ss,bdisolic:ss_autorizacion aut, bdisolic:ss_resum_scor_fin scr
	where ss.num_solicitud = aut.num_solicitud
	and scr.num_solicitud = aut.num_solicitud
	and ss.empresa ='001'
	and aut.empresa = ss.empresa
	and scr.empresa = ss.empresa
	and aut.status_solicitud in ('AN','PC')
	 AND aut.fecha_entrada <= dFecha
	group by 2,3,4,5
	order by numcte ))
	group by 1,2;

	insert into bdmis:mi_solicitudes_rep(totalstatus,num_sucursal,status,fecha)        
	select count(*),sucursal,'PR',dFecha  from table ( multiset (
	select distinct (nombre),sucursal  from bdisolic:ss_bitacora_precal  
	where  fecha <= dFecha
	and empresa  = '001'
	and consecutivo <> 0))
	group by sucursal;

		
	RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;