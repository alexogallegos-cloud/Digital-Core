CREATE PROCEDURE "informix".sp_replicasolicitudes_rep(p_dfechareproceso DATE) 
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha1          Char(8);
DEFINE  dFecha           Date;  
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_idia CHAR(2);
DEFINE v_iMesc CHAR(2);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

--SET DEBUG FILE TO "/home/informix/jydg/sp_replicasolicitudes.out";
--TRACE ON;

	--fecha del sistema  
	set isolation to dirty read;
        LET v_iAnio = 0;
        LET v_iMes = 0;
        LET v_idia = 0;
        LET v_iMesc = '01';

        LET v_iAnio = YEAR(p_dfechareproceso);
        LET v_iMes = LPAD(MONTH(p_dfechareproceso),2,0);
        LET v_idia = LPAD(DAY(p_dfechareproceso),2,0);

    
        if v_iMes < 10 then 
            LET v_iMesc= 0||v_iMes;
        else 
            LET v_iMesc= v_iMes;
        end if;

--        LET dFecha1 = v_iMesc||'/'||v_idia||'/'||v_iAnio;
        LET dFecha1 = v_iMesc||v_idia||v_iAnio;
        LET dFecha = (dFecha1)::date;
        LET dFecha = dFecha;

   	
    	--Borrado de Tabla Temporal
   		delete from bdmis:mi_solicitudestmp;
   	
   	 	--Clientes Nuevos
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo)
        select  s.sucursal,s.status_solicitud,count(status_solicitud)
		from  bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa  
                      AND s.num_solicitud = f.num_solicitud
		      AND s.empresa='001'  and   f.situacion_pago  = 0
                      AND trim(s.status_solicitud) not in ('AN','PC')
                      --s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')
                      AND fecha_insert <= dFecha
		group by s.sucursal,s.status_solicitud;

        --Clientes Coppel
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctecoppel)
        select  s.sucursal,s.status_solicitud,count(status_solicitud)
		from bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa 
                      AND s.num_solicitud = f.num_solicitud
 		      AND s.empresa='001'  
                      AND f.situacion_pago >0 
                      AND trim(s.status_solicitud) not in ('AN','PC')
                      --AND s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')
                      AND fecha_insert <= dFecha
		group by s.sucursal,s.status_solicitud;
        --order by sol.sucursal
        
        --Clientes Nuevos (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctenuevo)
        SELECT s.sucursalss, s.status_solicitudss, count(s.status_solicitudss) 
        FROM TABLE (MULTISET (
                    select max(x0.num_solicitud ) as num_solicitudss ,x0.numcte as numctess ,x0.status_solicitud as status_solicitudss ,x0.sucursal as sucursalss
                    from bdisolic:"informix".ss_solicitudes x0 
                    where (x0.status_solicitud IN ('AN' ,'PC' )) 
                       AND x0.fecha_insert <= dFecha
                    group by x0.numcte ,x0.status_solicitud ,x0.sucursal)) as s, bdisolic:ss_resum_scor_fin f
		WHERE s.num_solicitudss = f.num_solicitud
	            AND f.situacion_pago  = 0  and  s.status_solicitudss in ('AN','PC')
		group by s.sucursalss,s.status_solicitudss;

            
        --Clientes Coppel (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,ctecoppel)
        SELECT s.sucursalss, s.status_solicitudss, count(s.status_solicitudss) 
        FROM TABLE (MULTISET (
                    select max(x0.num_solicitud ) as num_solicitudss ,x0.numcte as numctess ,x0.status_solicitud as status_solicitudss ,x0.sucursal as sucursalss
                    from bdisolic:"informix".ss_solicitudes x0 where (x0.status_solicitud IN ('AN' ,'PC' )) 
                    and x0.fecha_insert <= dFecha
                    group by x0.numcte ,x0.status_solicitud ,x0.sucursal)) as s, bdisolic:ss_resum_scor_fin f
		WHERE s.num_solicitudss = f.num_solicitud
	    and   f.situacion_pago > 0  and  s.status_solicitudss in ('AN','PC')
		group by s.sucursalss,s.status_solicitudss;

		 --Total Coppel (Anuladas y Rechazadas)
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,totalstatus)
        SELECT s.sucursalss, s.status_solicitudss, count(s.status_solicitudss) 
        FROM TABLE (MULTISET (
                    select max(x0.num_solicitud ) as num_solicitudss ,x0.numcte as numctess ,x0.status_solicitud as status_solicitudss ,x0.sucursal as sucursalss
                    from bdisolic:"informix".ss_solicitudes x0 where (x0.status_solicitud IN ('AN' ,'PC' )) 
                    and x0.fecha_insert <= dFecha
                    group by x0.numcte ,x0.status_solicitud ,x0.sucursal)) as s, bdisolic:ss_resum_scor_fin f
		WHERE s.num_solicitudss = f.num_solicitud
	    and  s.status_solicitudss in ('AN','PC')
		group by s.sucursalss,s.status_solicitudss;

        --Clientes Rechazados por Precalificaciòn
		insert into bdmis:mi_solicitudestmp(totalstatus,num_sucursal,status)        
        select  count(*),sucursalss,'PR' 
        FROM TABLE (MULTISET (
                    select distinct x0.nombre as nombress ,x0.sucursal as sucursalss
                    from bdisolic:"informix".ss_bitacora_precal x0
                    where x0.fecha <= dFecha)) as s
		group by sucursalss;

        --Todos Los Clientes
        insert into bdmis:mi_solicitudestmp(num_sucursal,status,totalstatus)
        select  s.sucursal,s.status_solicitud,count(status_solicitud)
    	from bdisolic:ss_solicitudes s,bdisolic:ss_resum_scor_fin f
		WHERE s.empresa = f.empresa AND s.num_solicitud = f.num_solicitud
		AND s.empresa='001' 
                AND s.status_solicitud not in ('AN','PC')
                --AND s.status_solicitud in ('AP','AT','CC','EE','OA','OS','RT')  
                AND fecha_insert <= dFecha
		group by s.sucursal,s.status_solicitud;
        --order by sol.sucursal

        --Almacenar Informacion en tabla de Historial
        insert into bdmis:mi_solicitudeshis(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
		select num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha
		from bdmis:mi_solicitudes;
		
		--Borrado de Tabla para nueva informacion del ultimo cierre
		Delete from bdmis:mi_solicitudes;
        
		--Tabla Totalizada
		insert into bdmis:mi_solicitudes(num_sucursal,status,ctenuevo,ctecoppel,totalstatus,fecha)
        select num_sucursal,status,sum(ctenuevo),sum(ctecoppel),sum(totalstatus),dFecha
        from bdmis:mi_solicitudestmp
        group by num_sucursal,status;
        --order by num_sucursal;
 	
   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;