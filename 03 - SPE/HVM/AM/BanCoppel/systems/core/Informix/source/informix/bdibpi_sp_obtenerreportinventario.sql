CREATE PROCEDURE "informix".sp_obtenerreportinventario(pToken char(10), pEstatus char(3), pFechaIni char(10), pFechaFin char(10), pCanal char(2), pRegistros int)
				 returning char(5) as CodRet, char(10) as Token, char(3) as Estatus, char(10) as FechaCambio, char(9) as Cliente, char(10) as Solicitud,
				 char(30) as NumGuia, char(10) as FechaIngreso,	char(2)as Canal, char(5) as Total
				
	
	--Elaboro: Nubia Janeth Montoya Medina
    --Actividad: Genera Reporte de Inventario Tokens
    --Solicito: Mauricio Leon
    --Fecha: 26-02-2010
			
	------------------------------------------------------------
	--Elaboro:Francisco Rodriguez Ibarra.
	--Actividad:Se agrego la consulta por canal.
	--Solicito:Jorge Nunez
	--Fecha:01/10/2010
	------------------------------------------------------------
				
	-- DECLARA
	DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vToken char(10);
	DEFINE vEstatus char(3);
	DEFINE vFechaCambio char(10);
	DEFINE vCliente char(9);
	DEFINE vSolicitud char(10);
	DEFINE vNumGuia char(30);
	DEFINE vFechaIngreso char(10);
	DEFINE vTotal integer;
	DEFINE vCanal char(2);
	
	-- INICIALIZA
	LET cod_ret = '00000';
	LET vToken = '';
	LET vFechaCambio = '01-01-1900';
	LET vEstatus = '';
	LET vFechaIngreso = '01-01-1900';
	LET vCliente = '';
	LET vSolicitud = '';
	LET vNumGuia = '';
	LET vTotal = 0;
	LET vCanal = '';
	
	--SET DEBUG FILE TO "/home/nubia/sp_inventario.out";
    --TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso,vCanal, vTotal;
			ELSE 	
				
		  END IF ;
		END EXCEPTION ;

		SET ISOLATION DIRTY READ; 
		SET LOCK MODE TO WAIT 3;

		-- TRUNCATE TABLE bdibpi:tkn_nseries_paso;
		-- DROP IF EXISTS TABLE bdibpi:tkn_nseries_paso;
		-- BEGIN
			-- SELECT LIMIT 1 * FROM bdibpi:tkn_nseries_paso;
			-- ON EXCEPTION IN (-206)
			-- DROP TABLE bdibpi:tkn_nseries_paso;
			-- END EXCEPTION WITH RESUME;
		-- END;
		-- IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tkn_nseries_paso') THEN
			-- DROP TABLE tkn_nseries_paso;
		-- END IF;

		
		--Busqueda realizada por  numero de serie del token
		IF (pToken IS NOT NULL AND pToken <> '') THEN
	
		
			IF EXISTS (SELECT ns_token FROM bdibpi:tkn_nseries WHERE ns_token = pToken) THEN
			
					SELECT ns.ns_token, ns.id_status, date(ns.f_status)::char(10) as f_status, date(st.f_cambio_status)::char(10) as f_cambio_status
					INTO vToken, vEstatus, vFechaIngreso, vFechaCambio
					FROM bdibpi:tkn_nseries ns, bdibpi:tkn_status_token st
					WHERE ns.ns_token = st.ns_token and ns.ns_token = pToken and f_cambio_status = (SELECT MAX(f_cambio_status)  FROM tkn_status_token WHERE ns_token = pToken);

					SELECT s.numcte, s.solicitud
					INTO vCliente, vSolicitud
					FROM bdibpi:bpi_tokensolicitud s
					WHERE s.ns_token = pToken;
					
					SELECT g.num_guia
					INTO vNumGuia
					FROM bdibpi:tkn_envios e, bdibpi:tkn_guias g
					WHERE e.solicitud = vSolicitud and e.num_guia = g.num_guia;
					

				IF ((vToken = '' OR vToken IS NULL) AND (vCliente = '' OR vCliente IS NULL)) THEN
					LET cod_ret = '00001';
				END IF;
				
				RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, NVL(vNumGuia, ''), vFechaIngreso, vCanal,vTotal;
				
			ELSE
				LET cod_ret = '00002';
				RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
			END IF;
		--Busqueda realizada por canal.	
		ELIF (pCanal IS NOT NULL AND pCanal<>'') THEN
			CREATE TEMP TABLE bdibpi:tkn_nseries_paso
			(
				ns_token char(9) NOT NULL,
				id_status smallint NOT NULL,
				f_status datetime year to second NOT NULL,
				canal char(2),
				f_cambio_status datetime year to second NOT NULL
			)
			WITH NO LOG;

			IF (pCanal<>'00') THEN--Signifca que la busqueda sera por un canal.
			
				IF 	(pEstatus IS NOT NULL AND pEstatus <> '') THEN
			
					IF (pEstatus<>'000') THEN--Se realiaza la busqueda por canal, ademas de que se filtra tambien por un status.
						IF EXISTS (SELECT id_status FROM bdibpi:tkn_nseries WHERE id_status = pEstatus) THEN
				
							
							  
							  -- Se realiza de esta manera para evitar el alto costo de usar un table multiset sabiendo las consideraciones de BD
							  -- Se estima un aproximado de 20 mil regstros como maximo que es el parametro de fecha maximo a 3 meses y el normal de 15 dias. 
							  -- una vez q se termima de ejecutar el proceso se elimina la informacion de la tabla de paso. 
							  -- Este proceso se evaluo con el equipo de BD para su consideracion ya que se ponen los puntos de justificacion del porque se utiliza el insert select
                          	 
							  INSERT INTO bdibpi:"informix".tkn_nseries_paso (ns_token, id_status, f_status, canal, f_cambio_status)	
						      SELECT ns.ns_token, ns.id_status, (ns.f_status) AS f_status, ns.canal, max(fe.f_cambio_status) AS f_max
							  FROM bdibpi:tkn_status_token fe, bdibpi:tkn_nseries ns
							  WHERE DATE(ns.f_status)  BETWEEN pFechaIni::DATE AND pFechaFin::DATE 
							  AND fe.ns_token = ns.ns_token  
							  AND ns.id_status = pEstatus
							  AND ns.canal = pCanal
							  GROUP BY 1,2,3,4;
							
							FOREACH
							    
								
								SELECT  {+AVOID_STMT_CACHE

          						        +index (bdibpi:"informix".tkn_envios "idx_tkn_envios_sol")}
							    SKIP pRegistros FIRST 10 ns.id_status, ns.ns_token, date(ns.f_status)::CHAR(10) AS f_status, ns.f_cambio_status::DATE, s.numcte, s.solicitud, g.num_guia  -- modifcado 56
								INTO vEstatus, vToken, vFechaIngreso, vFechaCambio, vCliente, vSolicitud, vNumGuia
                                FROM informix.tkn_nseries_paso ns 
                                LEFT JOIN bdibpi:bpi_tokensolicitud s ON  ns.ns_token = s.ns_token
                                LEFT JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud
                                LEFT JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia
								ORDER BY ns.ns_token
								
								
								LET vTotal = vTotal + 1;
								
								LET vTotal = vTotal::char(5);
								
								LET vCanal=pCanal;
								
								RETURN cod_ret, vToken, vEstatus, vFechaCambio, NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso, ''), vCanal,vTotal WITH RESUME;
							
							END FOREACH;
							DROP TABLE bdibpi:tkn_nseries_paso;
							IF (vEstatus = '' OR vEstatus IS NULL) THEN
								LET cod_ret = '00006';								RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso,vCanal, vTotal;
							END IF;
					
						ELSE
							LET cod_ret = '00004';							RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
						END IF;
						
					--Se realiaza la busqueda por canal y se tran todos los token con estatus 152,190,160
					ELSE
							
							
							   
							    INSERT INTO informix.tkn_nseries_paso (ns_token, id_status, f_status, canal, f_cambio_status)
								SELECT ns.ns_token, ns.id_status, (ns.f_status) AS f_status, ns.canal, max(fe.f_cambio_status) AS f_max
								FROM bdibpi:tkn_nseries ns,bdibpi:tkn_status_token fe
								WHERE DATE(ns.f_status)  BETWEEN  pFechaIni::DATE AND pFechaFin::DATE
								AND fe.ns_token = ns.ns_token 
								AND ns.canal = pCanal
								AND ns.id_status IN ('152','199','160') 
								GROUP BY 1,2,3,4;
                            
							
							FOREACH
							
								
								SELECT  {+AVOID_STMT_CACHE

          						        +index (bdibpi:"informix".tkn_envios "idx_tkn_envios_sol")}
								SKIP pRegistros FIRST 10 ns.id_status, ns.ns_token, date(ns.f_status)::CHAR(10) AS f_status, ns.f_cambio_status::DATE, s.numcte, s.solicitud, g.num_guia  -- modifcado 94
								INTO vEstatus, vToken, vFechaIngreso, vFechaCambio, vCliente, vSolicitud, vNumGuia	
								FROM informix.tkn_nseries_paso ns
								LEFT JOIN bdibpi:bpi_tokensolicitud s ON  ns.ns_token = s.ns_token
								LEFT JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud
								LEFT JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia
								ORDER BY ns.ns_token
								
								
								LET vTotal = vTotal + 1;
								
								LET vTotal = vTotal::char(5);
								
								LET vCanal=pCanal;
								
								RETURN cod_ret, vToken, vEstatus, vFechaCambio, NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso, ''), vCanal,vTotal WITH RESUME;
							
							END FOREACH;
							DROP TABLE bdibpi:tkn_nseries_paso;
							IF (vEstatus = '' OR vEstatus IS NULL) THEN
								LET cod_ret = '00006';								RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso,vCanal, vTotal;
							END IF;
					
						
					END IF
				ELSE
					LET cod_ret = '00005';			
					RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
				END IF;
				
			--Busqueda de todos los canales	
			ELSE
				IF 	(pEstatus IS NOT NULL AND pEstatus <> '') THEN
			
					IF (pEstatus<>'000') THEN--Se realiaza de todos los token por un estatus y de todos los canales
						IF EXISTS (SELECT id_status FROM bdibpi:tkn_nseries WHERE id_status = pEstatus) THEN
					
							
							   
							   INSERT INTO informix.tkn_nseries_paso (ns_token, id_status, f_status, canal, f_cambio_status)
							   SELECT ns.ns_token, ns.id_status, (ns.f_status) AS f_status, ns.canal, max(fe.f_cambio_status) AS f_max
							   FROM bdibpi:tkn_nseries ns,bdibpi:tkn_status_token fe
							   WHERE DATE(ns.f_status)  BETWEEN pFechaIni::DATE AND pFechaFin::DATE
							   AND fe.ns_token = ns.ns_token 
							   AND ns.id_status = pEstatus
							   GROUP BY 1,2,3,4;
								
							
							FOREACH
							    

								SELECT  {+AVOID_STMT_CACHE

          						        +index (bdibpi:"informix".tkn_envios "idx_tkn_envios_sol")}
								SKIP pRegistros FIRST 10 ns.id_status, ns.ns_token, date(ns.f_status)::CHAR(10) AS f_status, ns.f_cambio_status::DATE, s.numcte, s.solicitud, g.num_guia, ns.canal  -- modifcado 135
								INTO vEstatus, vToken, vFechaIngreso, vFechaCambio, vCliente, vSolicitud, vNumGuia, vCanal	
								FROM informix.tkn_nseries_paso ns
								LEFT JOIN bdibpi:bpi_tokensolicitud s ON  ns.ns_token = s.ns_token
								LEFT JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud
								LEFT JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia
								ORDER BY ns.ns_token
								
								

								LET vTotal = vTotal + 1;
								
								LET vTotal = vTotal::char(5);
								
								RETURN cod_ret, vToken, vEstatus, vFechaCambio, NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso, ''), vCanal,vTotal WITH RESUME;
							
							END FOREACH;
							DROP TABLE bdibpi:tkn_nseries_paso;
							IF (vEstatus = '' OR vEstatus IS NULL) THEN
								LET cod_ret = '00006';								RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso,vCanal, vTotal;
							END IF;
						ELSE
							
							LET cod_ret = '00004';							RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
						
						END IF;
					--Se realiaza de todos los token con estatus 152,190,160 y de todos los canales
					ELSE
						
						  
						   INSERT INTO informix.tkn_nseries_paso (ns_token, id_status, f_status, canal, f_cambio_status)
						   SELECT ns.ns_token, ns.id_status, (ns.f_status) AS f_status, ns.canal, max(fe.f_cambio_status) AS f_max
						   FROM bdibpi:tkn_nseries ns,bdibpi:tkn_status_token fe
						   WHERE DATE(ns.f_status)  BETWEEN pFechaIni::DATE AND pFechaFin::DATE  
						   AND fe.ns_token = ns.ns_token 
						   AND ns.id_status IN ('152','199','160') 
						   GROUP BY 1,2,3,4;
							
						
						FOREACH
						
							
							SELECT  {+AVOID_STMT_CACHE

          						    +index (bdibpi:"informix".tkn_envios "idx_tkn_envios_sol")}
							SKIP pRegistros FIRST 10 ns.id_status, ns.ns_token, date(ns.f_status)::CHAR(10) AS f_status, ns.f_cambio_status::DATE, s.numcte, s.solicitud, g.num_guia, ns.canal  -- modifcado 172
							INTO vEstatus, vToken, vFechaIngreso, vFechaCambio, vCliente, vSolicitud, vNumGuia, vCanal	
							FROM informix.tkn_nseries_paso ns
							LEFT JOIN bdibpi:bpi_tokensolicitud s ON  ns.ns_token = s.ns_token
							LEFT JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud
							LEFT JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia
							ORDER BY ns.ns_token
							

							LET vTotal = vTotal + 1;
							
							LET vTotal = vTotal::char(5);
							
							RETURN cod_ret, vToken, vEstatus, vFechaCambio, NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso, ''), vCanal,vTotal WITH RESUME;
							
						END FOREACH;
						DROP TABLE bdibpi:tkn_nseries_paso;
						IF (vEstatus = '' OR vEstatus IS NULL) THEN
							LET cod_ret = '00006';							RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso,vCanal, vTotal;
						END IF;
										
					END IF;
				ELSE
					LET cod_ret = '00005';					RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
				END IF;
				
			END IF;
			
		--Busqueda realizada por estatus
		ELIF (pEstatus IS NOT NULL AND pEstatus <> '') THEN
			CREATE TEMP TABLE bdibpi:tkn_nseries_paso
			(
				ns_token char(9) NOT NULL,
				id_status smallint NOT NULL,
				f_status datetime year to second NOT NULL,
				canal char(2),
				f_cambio_status datetime year to second NOT NULL
			)
		WITH NO LOG;

			IF EXISTS (SELECT id_status FROM bdibpi:tkn_nseries WHERE id_status = pEstatus) THEN
			
				
				  
				   INSERT INTO informix.tkn_nseries_paso (ns_token, id_status, f_status, canal, f_cambio_status)
				   SELECT ns.ns_token, ns.id_status, (ns.f_status) AS f_status, ns.canal, max(fe.f_cambio_status) AS f_max
				   FROM bdibpi:tkn_nseries ns,bdibpi:tkn_status_token fe
				   WHERE DATE(ns.f_status)  BETWEEN pFechaIni::DATE AND pFechaFin::DATE  
				   AND fe.ns_token = ns.ns_token  
				   AND ns.id_status = pEstatus
				   GROUP BY 1,2,3,4;
				 
				
				FOREACH
				
					
					SELECT  {+AVOID_STMT_CACHE

          					+index (bdibpi:"informix".tkn_envios "idx_tkn_envios_sol")}
					SKIP pRegistros FIRST 10 ns.id_status, ns.ns_token, date(ns.f_status)::CHAR(10) AS f_status, ns.f_cambio_status::DATE, s.numcte, s.solicitud, g.num_guia  -- modifcado 211
					INTO vEstatus, vToken, vFechaIngreso, vFechaCambio, vCliente, vSolicitud, vNumGuia	
					FROM informix.tkn_nseries_paso ns
					LEFT JOIN bdibpi:bpi_tokensolicitud s ON  ns.ns_token = s.ns_token
					LEFT JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud
					LEFT JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia
					ORDER BY ns.ns_token
					
					
					LET vTotal = vTotal + 1;
					
					LET vTotal = vTotal::char(5);
					
					RETURN cod_ret, vToken, vEstatus, vFechaCambio, NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso, ''), vCanal,vTotal WITH RESUME;
				
				END FOREACH;
				DROP TABLE bdibpi:tkn_nseries_paso;
				IF (vEstatus = '' OR vEstatus IS NULL) THEN
					LET cod_ret = '00003';
					RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal; 
				END IF;
				
			ELSE 
				LET cod_ret = '00004';
				RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
			END IF;
				
		
		ELSE 
			LET cod_ret = '00005';
			RETURN cod_ret, vToken, vEstatus, vFechaCambio, vCliente, vSolicitud, vNumGuia, vFechaIngreso, vCanal,vTotal;
		END IF;
		
		
		
		
	END;
	-- DROP TABLE bdibpi:tkn_nseries_paso;
END PROCEDURE;