CREATE PROCEDURE "informix".sp_consultasolicitudes(cparam1 char(1),cparam2 char(5),cparam3 char(1),
cparam4 char(1),dparam5 date,dparam6 date,dparam7 date,cUsuario char(10))
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia (02-10-2007)
-- Funcion de Consulta de Solicitudes de Credito
-- Proyecto  Mis
--************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';


   --Obteniendo las sucursales de acuerdo a su tipo de busqueda
   DELETE FROM bdmis:mi_tmpsucursales WHERE usuario = cUsuario;
    IF cparam1 = "1" THEN -- Por Zona

        insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select num_sucursal,cUsuario from bdmis:mi_sucursalesinfo where num_plaza = cparam2;
    ELIF cparam1 = "2" THEN --Por Region
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select sc.num_sucursal,cUsuario
		from bdmis:mi_sucursalesinfo sc,bdmis:mi_plaza pla,bdmis:mi_regional reg
		where reg.num_region = cparam2 and reg.num_region =pla.num_region and pla.num_plaza = sc.num_plaza;
    ELIF cparam1 = "3" THEN --Sucursal
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario) values (cparam2,cUsuario);
	ELIF cparam1 = "4" THEN --Todas las Sucursales
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select num_sucursal,cUsuario
		from bdmis:mi_sucursalesinfo;
    END IF;

    --Fecha o Rango de fechas de la busqueda
    DELETE FROM bdmis:mi_rptsolicitudes where usuario = cUsuario;
    IF cparam3 = "1" THEN --Es por Dia
        IF dparam5 < dparam7 THEN --Si la fecha es menor que el ultimo Corte
            --Consulta en la mi_solicitudeshis    
            insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)
			select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario
			from bdmis:mi_solicitudeshis sol,bdmis:mi_statussol est
			where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
            and sol.fecha = dparam5   
			group by status,est.estatus_des,est.orden;
			
		ELSE
			--Consulta en la mi_solicitudes
			insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)
			select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario 
			from bdmis:mi_solicitudes sol,bdmis:mi_statussol est
			where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
            and sol.fecha = dparam5   
			group by status,est.estatus_des,est.orden;
            
		END IF;

    ELIF cparam3="2" THEN --Es Acumulado
			IF cparam4 = "1" THEN --Acumulado por Mes
				IF  month(dparam7) = month(dparam5) AND year(dparam7) = year(dparam5) THEN -- Si es el Mismo Mes que la fecha del Ultimo Corte
					--Saco La Informacion del Historial							
						insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)
						select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario
						from bdmis:mi_solicitudes sol,bdmis:mi_statussol est
						where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
						and sol.fecha = (select max(soli.fecha) from  bdmis:mi_solicitudes soli where  month(soli.fecha) = month(dparam5))
						group by status,est.estatus_des,est.orden;
	  					
				ELSE
						insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)
						select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario
						from bdmis:mi_solicitudeshis sol,bdmis:mi_statussol est
						where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
						and sol.fecha = (select max(soli.fecha) from  bdmis:mi_solicitudeshis soli where  month(soli.fecha) = month(dparam5))
						group by status,est.estatus_des,est.orden;
				END IF;
			ELIF cparam4 = "2" THEN --Acumulado por Rango
			    IF dparam6 = dparam7 or dparam6 > dparam7  THEN --Es igual ala Fecha del Corte
					--Saco la Informacion del Historial
					insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)
					select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario 
					from bdmis:mi_solicitudes sol,bdmis:mi_statussol est
					where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
					and sol.fecha = dparam6
					group by status,est.estatus_des,est.orden;
                             
				ELSE
				
					insert into bdmis:mi_rptsolicitudes(estatus,estatus_des,orden,cte_nuevos,cte_coppel,total,usuario)					
					select sol.status,est.estatus_des,est.orden,sum(sol.ctenuevo),sum(sol.ctecoppel),sum(sol.totalstatus),cUsuario
					from bdmis:mi_solicitudeshis sol,bdmis:mi_statussol est
					where sol.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) and sol.status = est.estatus
					and sol.fecha = (select max(soli.fecha) from  bdmis:mi_solicitudeshis soli where  soli.fecha >= dparam5 and soli.fecha <= dparam6)
					group by status,est.estatus_des,est.orden;
                 
				END IF;
			END IF;

    END IF;
	
   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;