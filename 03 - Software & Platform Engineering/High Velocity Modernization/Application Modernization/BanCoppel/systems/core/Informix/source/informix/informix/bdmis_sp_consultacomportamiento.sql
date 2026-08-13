CREATE PROCEDURE "informix".sp_consultacomportamiento(cparam1 char(1),cparam2 char(5),cparam3 char(1),
cparam4 char(1),dparam5 date,dparam6 date,dparam7 date,cUsuario char(10),cParam8 char(1))
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
-- Creado por Manuel Osuna                                 --*
-- Modificado por Fabiola Corrales 31/Ago/2007             --*
-- Debug del Procedure                                     --*
--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/manuel.out"; --*
--TRACE ON;                                                 --*
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
	ELIF cparam1 = "4" or cparam1 = "5" or cparam1 = "6" THEN --Todas las Sucursales
		insert into bdmis:mi_tmpsucursales(num_sucursal,usuario)
		select num_sucursal,cUsuario
		from bdmis:mi_sucursalesinfo;
    END IF;


    delete from bdmis:mi_tmpproductos where usuario = cUsuario;

    IF cParam8 = "1" THEN -- Por Producto 2000
        insert into bdmis:mi_tmpproductos(producto,usuario) values('2000',cUsuario);
        insert into bdmis:mi_tmpproductos(producto,usuario) values('6001',cUsuario);
    ELIF cParam8 = "2" THEN --Por Producto 1100
		insert into bdmis:mi_tmpproductos(producto,usuario) values('1100',cUsuario);
		insert into bdmis:mi_tmpproductos(producto,usuario) values('6001',cUsuario);
    ELIF cParam8 = "3" THEN --Por Todos
		insert into bdmis:mi_tmpproductos(producto,usuario)
		select num_producto,cUsuario
		from bdmis:mi_producto;
    END IF;

    --Fecha o Rango de fechas de la busqueda
    DELETE FROM bdmis:mi_rptcomportamiento where usuario = cUsuario;
    IF cparam3 = "1" THEN --Es por Dia
        IF dparam5 < dparam7 THEN
            insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
            apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
            select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
                     sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
	                 sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
					 sum(com.monto_autnoent_sol),cUsuario
			from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
			where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
			and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam5
			and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
			group by com.num_sucursal,suc.nombre,com.fecha;

		ELSE

            insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
            apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
            select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
                     sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
	                 sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
					 sum(com.monto_autnoent_sol),cUsuario
			from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
			where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
			and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam5
			and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
			group by com.num_sucursal,suc.nombre,com.fecha;

		END IF;

    ELIF cparam3="2" THEN
			IF cparam4 = "1" THEN
				IF  month(dparam7) = month(dparam5) AND year(dparam7) = year(dparam5) THEN
					--Saco La Informacion del Historial
				    insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam5) AND year(com.fecha) = year(dparam5))
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;

					--Saco la informacion de la fecha actual
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
				    from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam5) AND year(com.fecha) = year(dparam5))
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;


				ELSE
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND (month(com.fecha) = month(dparam5) AND year(com.fecha) = year(dparam5))
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;
				END IF;
			ELIF cparam4 = "2" THEN
			    IF dparam6 = dparam7 or dparam6 > dparam7  THEN
					--Saco la Informacion del Historial
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND (com.fecha >= dparam5 AND com.fecha <= dparam6)
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;

					---Saco la Informacion de la fecha actual
					insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
					from bdmis:mi_comportamiento com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND com.fecha = dparam6
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;

				ELSE
                   	insert into bdmis:mi_rptcomportamiento(num_sucursal,nombre_sucursal,fecha,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
				    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			        monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
					select   com.num_sucursal,suc.nombre,com.fecha,sum(com.apertura_cap),sum(com.saldo_cap),sum(com.totaper_cap),sum(com.totsaldo_cap),
						sum(com.apertura_col),sum(com.saldo_col),sum(com.totaper_col),sum(com.totsaldo_col),
						sum(com.recibidas_sol),sum(com.autyent_sol),sum(com.monto_autyent_sol),sum(com.autnoent_sol),
						sum(com.monto_autnoent_sol),cUsuario
					from bdmis:mi_comportamientohis com,bdmis:mi_sucursalesinfo suc
					where com.num_sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario)
					and com.num_sucursal = suc.num_sucursal AND (com.fecha >= dparam5 AND com.fecha <= dparam6)
					and com.producto in (select producto from mi_tmpproductos where usuario = cUsuario)
					group by com.num_sucursal,suc.nombre,com.fecha;


				END IF;
			END IF;

    END IF;

	--consulta la ciudad que pertenece la tienda
    delete from bdmis:mi_rptcomportamiento2 where usuario = cUsuario;
    delete from bdmis:mi_tmpcomportamiento1 where usuario = cUsuario;
    delete from bdmis:mi_tmpcomportamiento2 where usuario = cUsuario;

    IF cparam1 != "5"  and cparam1 != "6"  THEN -- Por Todas las Sucursales

        IF cparam3="2" THEN
           --Prueba          
            insert into bdmis:mi_tmpcomportamiento1(ciudad,num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,apertura_col,
			saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,usuario)
          	select ciu.nombre,num_sucursal,nombre_sucursal,sum(apertura_cap),sum(saldo_cap),sum(apertura_col),
			sum(saldo_col),sum(recibidas_sol),sum(autyent_sol),sum(monto_autyent_sol),sum(autnoent_sol),
			sum(monto_autnoent_sol),rpt.usuario
			from bdmis:mi_rptcomportamiento rpt,bdinteg:si_ciudades ciu,bdinteg:si_sucursales suc
			where rpt.num_sucursal = suc.sucursal and suc.estado = ciu.estado and suc.ciudad = ciu.ciudad and usuario = cUsuario
			group by ciu.nombre,num_sucursal,nombre_sucursal,rpt.usuario;
			
			insert into bdmis:mi_tmpcomportamiento2(num_sucursal,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col,usuario)
			SELECT num_sucursal,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col,usuario
			FROM bdmis:mi_rptcomportamiento
			WHERE usuario = cUsuario and
			fecha = (select max(fecha) from bdmis:mi_rptcomportamiento where  usuario = cUsuario );			
			
			insert into bdmis:mi_rptcomportamiento2(ciudad,num_sucursal,nombre_sucursal,
			apertura_cap,saldo_cap,apertura_col,saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,
			usuario,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col)
			SELECT tmp1.ciudad,tmp1.num_sucursal,tmp1.nombre_sucursal,tmp1.apertura_cap,tmp1.saldo_cap,tmp1.apertura_col,
			tmp1.saldo_col,tmp1.recibidas_sol,tmp1.autyent_sol,tmp1.monto_autyent_sol,tmp1.autnoent_sol,tmp1.monto_autnoent_sol,tmp1.usuario,
			tmp2.totaper_cap,tmp2.totsaldo_cap,tmp2.totaper_col,tmp2.totsaldo_col
			from bdmis:mi_tmpcomportamiento1  tmp1,bdmis:mi_tmpcomportamiento2 tmp2
			where tmp1.usuario = cUsuario and tmp1.usuario = tmp2.usuario and tmp1.num_sucursal = tmp2.num_sucursal;
			

        ELSE
			insert into bdmis:mi_rptcomportamiento2(ciudad,num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
			apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,
			monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
			select ciu.nombre,num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,apertura_col,
					saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,
					autnoent_sol,monto_autnoent_sol,fecha,rpt.usuario
			from bdmis:mi_rptcomportamiento rpt,bdinteg:si_ciudades ciu,bdinteg:si_sucursales suc
			where rpt.num_sucursal = suc.sucursal and suc.estado = ciu.estado and suc.ciudad = ciu.ciudad
			and usuario = cUsuario;
		END IF;

		--Fecha de Aperturas de las Sucurales
		update  bdmis:mi_rptcomportamiento2
		set fecha_apertura = (select info.fecha_apertura from bdmis:mi_sucursalesinfo info
		where  bdmis:mi_rptcomportamiento2.num_sucursal = info.num_sucursal);

    ELIF cparam1 = "5" THEN --Por Todas las Sucursales Agrupados por Zona        
		
		insert into bdmis:mi_tmpcomportamiento1(ciudad,num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,apertura_col,
			saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
		select  'ZONA' as ciudad,suc.num_plaza,pla.nombre,sum(com.apertura_cap),sum(com.saldo_cap),
                 sum(com.apertura_col),sum(com.saldo_col) ,sum(com.recibidas_sol) ,sum(com.autyent_sol) ,
	             sum(com.monto_autyent_sol),sum(com.autnoent_sol),sum(com.monto_autnoent_sol),dparam7,cUsuario 
		from bdmis:mi_rptcomportamiento com,bdmis:mi_sucursalesinfo suc,bdmis:mi_plaza pla
		where com.num_sucursal = suc.num_sucursal and pla.num_plaza = suc.num_plaza and com.usuario = cUsuario
		group by suc.num_plaza,pla.nombre;
		
		insert into bdmis:mi_tmpcomportamiento2(num_sucursal,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col,usuario)	
		select  suc.num_plaza,sum(com.totaper_cap),sum(com.totsaldo_cap),sum(com.totaper_col),sum(com.totsaldo_col),cUsuario 
		from bdmis:mi_rptcomportamiento com,bdmis:mi_sucursalesinfo suc,bdmis:mi_plaza pla
		where com.num_sucursal = suc.num_sucursal and pla.num_plaza = suc.num_plaza and com.usuario = cUsuario
		and  com.fecha = (select max(fecha) from bdmis:mi_rptcomportamiento where  usuario = cUsuario )
		group by suc.num_plaza,pla.nombre;
			
		insert into bdmis:mi_rptcomportamiento2(ciudad,num_sucursal,nombre_sucursal,
		apertura_cap,saldo_cap,apertura_col,saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,
		usuario,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col)
		SELECT tmp1.ciudad,tmp1.num_sucursal,tmp1.nombre_sucursal,tmp1.apertura_cap,tmp1.saldo_cap,tmp1.apertura_col,
		tmp1.saldo_col,tmp1.recibidas_sol,tmp1.autyent_sol,tmp1.monto_autyent_sol,tmp1.autnoent_sol,tmp1.monto_autnoent_sol,tmp1.usuario,
		tmp2.totaper_cap,tmp2.totsaldo_cap,tmp2.totaper_col,tmp2.totsaldo_col
		from bdmis:mi_tmpcomportamiento1  tmp1,bdmis:mi_tmpcomportamiento2 tmp2
		where tmp1.usuario = cUsuario and tmp1.usuario = tmp2.usuario and tmp1.num_sucursal = tmp2.num_sucursal;
				
    ELIF cparam1 = "6" THEN --por Todas las Sucursales Agrupadòs por Region		
		
		insert into bdmis:mi_tmpcomportamiento1(ciudad,num_sucursal,nombre_sucursal,apertura_cap,saldo_cap,apertura_col,
		saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha,usuario)
		select  'ZONA',pla.num_region,reg.nombre,sum(com.apertura_cap),sum(com.saldo_cap),
		sum(com.apertura_col),sum(com.saldo_col),sum(com.recibidas_sol),sum(com.autyent_sol),
		sum(com.monto_autyent_sol),sum(com.autnoent_sol),sum(com.monto_autnoent_sol),dparam7,cUsuario
		from bdmis:mi_rptcomportamiento com,bdmis:mi_sucursalesinfo suc,bdmis:mi_plaza pla,bdmis:mi_regional reg
		where com.num_sucursal = suc.num_sucursal and pla.num_plaza = suc.num_plaza
		and  reg.num_region = pla.num_region and com.usuario = cUsuario
		group by pla.num_region,reg.nombre;
		
		insert into bdmis:mi_tmpcomportamiento2(num_sucursal,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col,usuario)	
		select  pla.num_region,sum(com.totaper_cap),sum(com.totsaldo_cap),sum(com.totaper_col),sum(com.totsaldo_col),cUsuario
		from bdmis:mi_rptcomportamiento com,bdmis:mi_sucursalesinfo suc,bdmis:mi_plaza pla,bdmis:mi_regional reg
		where com.num_sucursal = suc.num_sucursal and pla.num_plaza = suc.num_plaza
		and  reg.num_region = pla.num_region and com.usuario = cUsuario and
		com.fecha = (select max(fecha) from bdmis:mi_rptcomportamiento where  usuario = cUsuario )
		group by pla.num_region;
		
		
		insert into bdmis:mi_rptcomportamiento2(ciudad,num_sucursal,nombre_sucursal,
		apertura_cap,saldo_cap,apertura_col,saldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,
		usuario,totaper_cap,totsaldo_cap,totaper_col,totsaldo_col)
		SELECT tmp1.ciudad,tmp1.num_sucursal,tmp1.nombre_sucursal,tmp1.apertura_cap,tmp1.saldo_cap,tmp1.apertura_col,
		tmp1.saldo_col,tmp1.recibidas_sol,tmp1.autyent_sol,tmp1.monto_autyent_sol,tmp1.autnoent_sol,tmp1.monto_autnoent_sol,tmp1.usuario,
		tmp2.totaper_cap,tmp2.totsaldo_cap,tmp2.totaper_col,tmp2.totsaldo_col
		from bdmis:mi_tmpcomportamiento1  tmp1,bdmis:mi_tmpcomportamiento2 tmp2
		where tmp1.usuario = cUsuario and tmp1.usuario = tmp2.usuario and tmp1.num_sucursal = tmp2.num_sucursal;	
	
	END IF;


   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;