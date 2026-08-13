CREATE PROCEDURE "informix".sp_consultabanca(cparam1 char(1),cparam2 char(5),cparam3 char(1),cparam4 char(1),dparam5 date,dparam6 date,dparam7 date,cUsuario char(10),sparam9 integer)

RETURNING VARCHAR(6),VARCHAR(80);



DEFINE  SQL_ERR          INTEGER;

DEFINE  ISAM_ERR         INTEGER;

DEFINE  ERROR_INFO       VARCHAR(80);

DEFINE  P_COD_RET        VARCHAR(6);

DEFINE  P_MENSAJE        VARCHAR(80);

DEFINE cNombre            VARCHAR(40);

BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO

      LET P_COD_RET    = SQL_ERR;

      LET P_MENSAJE  = ERROR_INFO;

      RETURN P_COD_RET, P_MENSAJE;

   END EXCEPTION;



   --SET DEBUG FILE TO "/tmp/consultabanca.out";

   --TRACE ON;

--************************************************************

-- Creado por Manuel Osuna Valencia

-- Funcion de Consulta de Clientes registrado en la Banca

-- Proyecto  Mis

--Modifico: Jorge Nuñez Sanchez

--Fecha: 2008-11-12

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



	--Consulta por Status

	DELETE FROM bdmis:tmp_solbanint WHERE usuario =cUsuario;

	IF sparam9 = -1 THEN --Consulta por Todos los sTatus

		insert into  bdmis:tmp_solbanint(id_status,desc_status,usuario)

		select id_status,desc_status,cUsuario  from  bdmis:mi_statusbanint;

	ELSE

		insert into  bdmis:tmp_solbanint(id_status,desc_status,usuario)

		select id_status,desc_status,cUsuario from bdmis:mi_statusbanint where id_status = sparam9;

	END IF; 	



    --Fecha o Rango de fechas de la busqueda

    DELETE FROM bdmis:mi_rptsolbanint where usuario = cUsuario;

    IF cparam3 = "1" THEN --Es por Dia

        IF dparam5 < dparam7 THEN --Si la fecha es igual a la del ultimo Corte

            --Consulta en la mi_solbaninthist   

			INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)        

			SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

            FROM bdmis:mi_solbaninthist sol

                        left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

			WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

                        and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

                        and sol.fecha_registro = dparam5;

			

		ELSE

			--Consulta en la mi_solbanint

			INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)        

			SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

            FROM bdmis:mi_solbanint sol

                        left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

			WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

                        and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

                        and sol.fecha_registro = dparam5;

		END IF;



    ELIF cparam3="2" THEN --Es Acumulado

			IF cparam4 = "1" THEN --Acumulado por Mes

				IF  month(dparam7) = month(dparam5) AND year(dparam7) = year(dparam5) THEN -- Si es el Mismo Mes que la fecha del Ultimo Corte

					--Saco La Informacion							

						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbanint sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and month(sol.fecha_registro) = month(dparam5);
					--Y tambien del historial
						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbaninthist sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and month(sol.fecha_registro) = month(dparam5);

	  					

				ELSE 

						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbaninthist sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and month(sol.fecha_registro) = month(dparam5);

				END IF;

			ELIF cparam4 = "2" THEN --Acumulado por Rango

			    IF dparam6 = dparam7 THEN --Es igual ala Fecha del Corte

					--Saco la Informacion de la tabla diaria

						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbanint sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and sol.fecha_registro = dparam6;
					--Y tambien la del historial
						
						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbaninthist sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and sol.fecha_registro between dparam5 and dparam6;
                             

				ELSE

						INSERT INTO bdmis:mi_rptsolbanint(sucursal,nombresucursal,id_status,desc_status,totalclientesreg,fecha_registro,clientesreg,usuario)

						SELECT sol.sucursal,'',sol.id_status,status.desc_status,sol.totalclientesreg,sol.fecha_registro,sol.clientesreg,cUsuario

						FROM bdmis:mi_solbaninthist sol

							left outer join bdmis:mi_statusbanint status on sol.id_status = status.id_status

						WHERE sol.sucursal  in (select num_sucursal from bdmis:mi_tmpsucursales where usuario = cUsuario) 

							and sol.id_status in (select id_status  from tmp_solbanint where usuario = cUsuario)

							and sol.fecha_registro between dparam5 and dparam6;

				END IF;

			END IF;

    END IF;
	
	DELETE FROM bdmis:mi_rptsolbanint2 WHERE usuario = cUsuario;
	
	IF cparam1 = "1" THEN --Zona
	
			SELECT nombre INTO cNombre FROM mi_plaza WHERE num_plaza = cparam2;
			IF sparam9 = -1 THEN -- Por Zona y por  todos los estatus
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT cparam2,cNombre,desc_status,sum(clientesreg),sum(totalclientesreg),cUsuario
				FROM bdmis:mi_rptsolbanint
				WHERE usuario = cUsuario
				GROUP BY desc_status;
			ELSE
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT cparam2,cNombre,desc_status,sum(clientesreg),sum(totalclientesreg),cUsuario
				FROM bdmis:mi_rptsolbanint
				WHERE id_status = sparam9 AND usuario = cUsuario
				GROUP BY desc_status;
			END IF
		
    ELIF cparam1 = "2" THEN --Por Region
	
	        SELECT nombre INTO cNombre from mi_regional WHERE num_region = cparam2;
			IF sparam9 = -1 THEN --Por region y todos los estatus
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT cparam2,cNombre,desc_status,sum(clientesreg),sum(totalclientesreg),cUsuario
				FROM bdmis:mi_rptsolbanint 
				WHERE usuario = cUsuario
				GROUP BY desc_status;
			ELSE
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT cparam2,cNombre,desc_status,sum(clientesreg),sum(totalclientesreg),cUsuario
				FROM bdmis:mi_rptsolbanint 
				WHERE id_status = sparam9 AND usuario = cUsuario
				GROUP BY desc_status;
			END IF

    ELIF cparam1 = "3" OR cparam1 = "4" THEN --Sucursal

			IF sparam9 = -1 THEN
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT suc.sucursal,nom.nombre,suc.desc_status,sum(clientesreg),sum(totalclientesreg), cUsuario
				FROM bdmis:mi_rptsolbanint suc,bdmis:mi_sucursalesinfo nom
				WHERE suc.sucursal = nom.num_sucursal	
				GROUP BY suc.sucursal,nom.nombre,suc.desc_status;
			ELSE
				INSERT INTO bdmis:mi_rptsolbanint2(sucursal,nombresucursal,desc_status,clientesreg,totalclientesreg,usuario)
				SELECT suc.sucursal,nom.nombre,suc.desc_status,sum(clientesreg),sum(totalclientesreg), cUsuario
				FROM bdmis:mi_rptsolbanint suc,bdmis:mi_sucursalesinfo nom
				WHERE suc.sucursal = nom.num_sucursal	
				AND suc.id_status = sparam9
				GROUP BY suc.sucursal,nom.nombre,suc.desc_status;
			END IF;

    END IF;
	
   RETURN P_COD_RET,P_MENSAJE;

END;

END PROCEDURE;