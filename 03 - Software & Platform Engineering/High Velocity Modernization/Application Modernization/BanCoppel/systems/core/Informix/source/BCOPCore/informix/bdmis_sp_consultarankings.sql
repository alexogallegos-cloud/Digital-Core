CREATE PROCEDURE "informix".sp_consultarankings(cparam1 char(1),cparam2 char(5),cparam3 char(1),
cparam4 char(4),cparam5 char(1),cparam6 char(1),dparam7 date,dparam8 date,dparam9 date,cUsuario char(10))
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

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

   --SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/manuel.out";
   --TRACE ON;

   --Obteniendo las sucursales de acuerdo a su tipo de busqueda
   DELETE FROM bdmis:mi_tmpsucursales WHERE usuario = cUsuario;

    IF cparam1 = "1" THEN -- Por Zona
        insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select num_sucursal,cUsuario from bdmis:mi_sucursalesinfo where num_plaza = cparam2 and tamanio = cparam3;
    ELIF cparam1 = "2" THEN --Por Region
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select sc.num_sucursal,cUsuario
		from bdmis:mi_sucursalesinfo sc,bdmis:mi_plaza pla,bdmis:mi_regional reg
		where reg.num_region = cparam2 and reg.num_region =pla.num_region and pla.num_plaza = sc.num_plaza and sc.tamanio =cparam3;
	ELIF cparam1 = "3" THEN --Todas las Sucursales
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select num_sucursal,cUsuario
		from bdmis:mi_sucursalesinfo
		where tamanio = cparam3;
    END IF;

    --Fecha o Rango de fechas de la busqueda
    DELETE FROM bdmis:mi_rptcomportamiento where usuario = cUsuario;
   IF cparam5 = "1" THEN --Es por Dia
        IF dparam7 < dparam9 THEN
            insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
            apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
            select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                     com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
			         com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
					 com.monto_autnoent_sol,com.fecha,cUsuario
			from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
			where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
			and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam7 and producto =cparam4;

		ELSE
            insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
            apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
            select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                     com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
			         com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
					 com.monto_autnoent_sol,com.fecha,cUsuario
			from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
			where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
			and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam7 and producto =cparam4;
		END IF;

    ELIF cparam5="2" THEN
			IF cparam6 = "1" THEN
				IF  month(dparam7) = month(dparam9) AND year(dparam7) = year(dparam9) THEN
					--Saco La Informacion del Historial
				    insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
                    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
                    select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                    com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
						     com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
							 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam7) AND year(com.fecha) = year(dparam7));
					--Saco la informacion de la fecha actual
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
                    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
                    select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                    com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
						     com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
							 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam7) AND year(com.fecha) = year(dparam7));

				ELSE
                    insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
                    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
                    select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                    com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
						     com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
							 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam7) AND year(com.fecha) = year(dparam7));
				END IF;
			ELIF cparam5 = "2" THEN
			    IF dparam8 = dparam9 or dparam8 > dparam9  THEN
					--Saco la Informacion del Historial
                   insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
                    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
                    select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                             com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
							 com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
							 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND (com.fecha >= dparam7 AND com.fecha <= dparam8);
					---Saco la Informacion de la fecha actual
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
					 apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
					 select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                     com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
			         com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
					 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam8;


				ELSE
                    insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
                    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
					monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
                    select   com.num_sucursal,suc.nombre,com.apertura_cap,com.saldo_cap,com.totaper_cap,com.totsaldo_cap,
                             com.apertura_col,com.saldo_col,com.totaper_col,com.totsaldo_col,
							 com.recibidas_sol,com.autyent_sol,com.monto_autyent_sol,com.autnoent_sol,
							 com.monto_autnoent_sol,com.fecha,cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and  com.producto =cparam4
					and com.num_sucursal = suc.num_sucursal AND (com.fecha >= dparam7 AND com.fecha <= dparam8);
				END IF;
			END IF;

    END IF;


   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;