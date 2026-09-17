CREATE PROCEDURE "informix".sp_reprocesoreplicasolic(dFecha Date) 
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
--DEFINE  dFecha           Date;  
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
--   let dFecha ='10/20/2012'
	--fecha del sistema  
--	select fecha_ant into dFecha  from bdmis:mi_fechas;

set lock mode to wait 3;
	set isolation to dirty read;
		select * from bdmis:mi_solicitudestmp
		into temp tmp_mi_solicitudestmp;
    	--Borrado de Tabla Temporal
   		truncate table bdmis:mi_solicitudestmp;
   	
   	 	--1Clientes Nuevos
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo)
        select {+INDEX(bdisolic:ss_resum_scor_fin idx_ss_resum_scor_fin),(bdisolic:ss_solicitudes empsol)} 
         s.sucursal,s.status_solicitud,count(status_solicitud)
		from  bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa AND s.num_solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
		AND s.empresa='001'  and   f.situacion_pago  = 0  
        and trim(s.status_solicitud) not in ('AN','PC')
		and s.fecha_insert <= dFecha
        --and  s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')
		group by s.sucursal,s.status_solicitud;         
		--order by sol.sucursal

        --2Clientes Coppel
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctecoppel)
        select  {+INDEX(bdisolic:ss_resum_scor_fin idx_ss_resum_scor_fin),(bdisolic:ss_solicitudes empsol)} 
        s.sucursal,s.status_solicitud,count(status_solicitud)
		from bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa AND s.num_solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
		AND s.empresa='001'  and  f.situacion_pago >0 
        and trim(s.status_solicitud) not in ('AN','PC')
		and s.fecha_insert <= dFecha
        --and  s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')
		group by s.sucursal,s.status_solicitud;
        --order by sol.sucursal
        
        --3Clientes Nuevos (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo)
        select  s.sucursal,s.status,count(status)
		from bdmis:vi_anuladas s,bdisolic:ss_resum_scor_fin f
		WHERE s.solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
	    and   f.situacion_pago  = 0  and  trim(s.status) in ('AN','PC')
		and f.fecha_ultima_compra <= dFecha
		group by s.sucursal,s.status;
        -- order by sucursal
            
	   --4Clientes Coppel (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctecoppel)
        select  s.sucursal,s.status,count(status)
		from bdmis:vi_anuladas s,bdisolic:ss_resum_scor_fin f
		WHERE s.solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
	    and   f.situacion_pago > 0  and  trim(s.status) in ('AN','PC')
		and f.fecha_ultima_compra <= dFecha
		group by s.sucursal,s.status;
		
		 --5Total Coppel (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,totalstatus)
        select  s.sucursal,s.status,count(status)
		from bdmis:vi_anuladas s,bdisolic:ss_resum_scor_fin f
		WHERE s.solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
	    and  trim(s.status) in ('AN','PC')
		and f.fecha_ultima_compra <= dFecha
		group by s.sucursal,s.status;
        
        --6Clientes Rechazados por Precalificaciòn
		insert into bdmis:mi_solicitudestmp(totalstatus,num_sucursal,status)        
		select  count(*),sucursal,'PR' 
		from bdmis:vi_precalificados
		group by sucursal;

        --7Todos Los Clientes
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,totalstatus)
        select  {+INDEX(bdisolic:ss_resum_scor_fin idx_ss_resum_scor_fin),(bdisolic:ss_solicitudes empsol)} 
        s.sucursal,s.status_solicitud,count(status_solicitud)
    	from bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa AND s.num_solicitud = f.num_solicitud
        and f.meses_historia = f.meses_historia and (f.evalua_cc = f.evalua_cc OR f.evalua_cc IS NULL)
		AND s.empresa='001' and trim(s.status_solicitud) not in ('AN','PC')
		and s.fecha_insert <= dFecha
        --and  s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')  
		group by s.sucursal,s.status_solicitud;
        --order by sol.sucursal
        
	
		--9Borrado de Tabla para nueva informacion del ultimo cierre
		--truncate table bdmis:mi_solicitudes;
        
		--10Tabla Totalizada
		--insert into bdmis:mi_solicitudes(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
        select num_sucursal,status,sum(ctenuevo) as ctenuevo,sum(ctecoppel) as ctecoppel,sum(totalstatus) as totalstatus,dFecha as fecha
        from bdmis:mi_solicitudestmp
        group by num_sucursal,status
		into temp solicitudes_tmp;
        --order by num_sucursal;
		
		
		truncate table bdmis:mi_solicitudestmp;
   	
		/*
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
		select num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha
		from solicitudes_tmp;
		*/
		
		--8Almacenar Informacion en tabla de Historial
        insert into bdmis:mi_solicitudeshis(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
		select num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha
		from solicitudes_tmp;
		
		insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
		select * from tmp_mi_solicitudestmp;
		 
		
		drop table solicitudes_tmp;

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;