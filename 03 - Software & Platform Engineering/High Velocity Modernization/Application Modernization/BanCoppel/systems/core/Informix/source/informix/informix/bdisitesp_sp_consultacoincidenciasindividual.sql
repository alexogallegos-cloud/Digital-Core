CREATE PROCEDURE "informix".sp_consultacoincidenciasindividual(pEmpresa 	CHAR(3),
															  pNumCte 		CHAR(20),
															  pNumCredito	CHAR(20),
															  pNumTarjeta	CHAR(20),
															  pApePat		CHAR(26),
															  pApeMat		CHAR(26),
															  pNombre1		CHAR(26),
															  pnombre2		CHAR(26),
															  pFecha		DATE)

	RETURNING CHAR(6), 	 -- cod retorno
			      CHAR(20),	 -- numcte
			      CHAR(104), -- nombre
			      CHAR(13),	 -- rfc
			      CHAR(20),	 -- num_credito
			      CHAR(20);	 -- num_tarjeta

	--Definicion de variables
	DEFINE v_codret 		  CHAR(6);
	DEFINE v_sqlerr 		  INTEGER;

	DEFINE v_NumCte			  CHAR(20);
	DEFINE v_Nombre			  CHAR(104);
	DEFINE v_RFC			    CHAR(13);
	DEFINE v_NumCred		  CHAR(20);
	DEFINE v_NumTarjeta		CHAR(20);
	DEFINE v_NumRegistros	INTEGER;

	--Inicializacion de variables
	LET v_codret 		= "000";
	LET v_sqlerr 		= 0;

	LET v_NumCte		    = "";
	LET v_Nombre		    = "";
	LET v_RFC			      = "";
	LET v_NumCred		    = "";
	LET v_NumTarjeta	  = "";
	LET v_NumRegistros  = 0;

	--Preparar valores de entrada para la busqueda en el SP 
	IF pFecha IS NULL THEN
		LET pFecha = DATE(1);
	END IF;
	IF pApePat <> '' THEN
		LET pApePat = UPPER(pApePat);
	END IF;
	IF pApeMat <> '' THEN
		LET pApeMat = UPPER(pApeMat);
	END IF;
	IF pNombre1 <> '' THEN
		LET pNombre1 = UPPER(pNombre1);
	END IF;
	IF pNombre2 <> '' THEN
		LET pNombre2 = UPPER(pNombre2);
	END IF;

	--**************************************************************
	--18-02-2009
	--Realizo:
	--Abraham Ayala
	--Con este SP se realiza la busqueda del proyecto de SE individual
	--**************************************************************
	
	--**************************************************************
	--09-07-2009
	--Modifico:
	--José Luis Pulido
	--Se separo la consulta para el filtro de busqueda por apellidos y nombre de cliente para bajar el costo
	--Se agregaron mas opcion en el IF dependiendo con los parametros que se mandan para el filtro de consulta por nombre del cliente
	--**************************************************************
	
	--**************************************************************
	--14-07-2009
	--Modifico:
	--José Luis Pulido
	--Se quitaron todos los LIKE para reducir el costo de la consulta.
	--**************************************************************

	--**************************************************************
	-- Fecha Modificación : 12-05-2010
	-- Modifico : Paul Ivan Quintero Varela
	-- Observaciones : Se modifica con la finalidad de complementar el filtro de consulta al extraer el número de tarjeta,
    --                 logrando que solo extraiga el registro con el número de tarjeta del titular y que este activa.
	--**************************************************************
	
	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr <> 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultaCoincidenciasIndividual.out';
	--trace on;
	--PRUEBA DE EXPLAIN

		--Validar que el SP reciba parametros
		IF (pEmpresa = "" OR pEmpresa IS NULL) AND (pNumCte = "" OR pNumCte IS NULL) AND (pNumCredito = "" OR pNumCredito IS NULL)
			AND (pNumTarjeta = "" OR pNumTarjeta IS NULL) AND (pApePat = "" OR pApePat IS NULL) AND (pApeMat = "" OR pApeMat IS NULL)
			AND (pNombre1 = "" OR pNombre1 IS NULL) AND (pnombre2 = "" OR pnombre2 IS NULL) AND (pFecha = DATE(1) OR pFecha IS NULL) THEN

			LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta;
		ELSE
			--Seccion de codigo para la busqueda por numero de cliente
			IF pNumCte <> "" THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
				
                      SELECT (TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||TRIM(a.nombre1)||' '||TRIM(a.nombre2)),
                              NVL(a.rfc, ''), NVL(b.num_credito, ''), NVL(c.num_tarjeta, '')
                         INTO v_Nombre, v_RFC, v_NumCred, v_NumTarjeta
                         FROM bdinteg:si_cliente a
                         LEFT OUTER JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.numcte = a.numcte)
                         LEFT OUTER JOIN bdicred:sd_tarjeta c ON (c.numcte = a.numcte AND c.num_credito = b.num_credito
                                                                                      AND c.tipo_tarjeta = "T" 
                                                                                      AND c.status_tar = "A")
                        WHERE a.rfc = a.rfc
                          AND a.numcte = pNumCte
                          AND a.empresa = pEmpresa

					RETURN v_codret, pNumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;

				END FOREACH;
			--Seccion de codigo para la busqueda por numero de credito
			ELIF pNumCredito <> "" THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
				
				 SELECT a.numcte, (TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||TRIM(a.nombre1)||' '||TRIM(a.nombre2)),
						    NVL(a.rfc, ''), NVL(c.num_tarjeta, '')
					 INTO v_NumCte, v_Nombre, v_RFC, v_NumTarjeta
		       FROM bdinteg:si_cliente a
					 LEFT OUTER JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.numcte = a.numcte)
					 LEFT OUTER JOIN bdicred:sd_tarjeta c ON (c.numcte = a.numcte AND c.num_credito = b.num_credito
                                                                        AND c.tipo_tarjeta = "T" 
                                                                        AND c.status_tar = "A")
					WHERE a.numcte = a.numcte
						AND b.num_credito = pNumCredito
						AND a.empresa = pEmpresa

					RETURN v_codret, v_NumCte, v_Nombre, v_RFC, pNumCredito, v_NumTarjeta WITH RESUME;

				END FOREACH;
			--Seccion de codigo para la busqueda por numero de tarjeta
			ELIF pNumTarjeta <> "" THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
				
		     SELECT a.numcte, (TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||TRIM(a.nombre1)||' '||TRIM(a.nombre2)),
						    NVL(a.rfc, ''), NVL(b.num_credito, '')
					 INTO v_NumCte, v_Nombre, v_RFC, v_NumCred
		       FROM bdinteg:si_cliente a
					 LEFT OUTER JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.numcte = a.numcte)
					 LEFT OUTER JOIN bdicred:sd_tarjeta c ON (c.numcte = a.numcte AND c.num_credito = b.num_credito
                                                                        AND c.tipo_tarjeta = "T" 
                                                                        AND c.status_tar = "A")
					WHERE c.num_tarjeta = pNumTarjeta
						AND a.empresa = pEmpresa

					RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, pNumTarjeta WITH RESUME;

				END FOREACH;
			--Seccion de codigo para la busqueda por apellido paterno, apellido materno, primer nombre, segundo nombre y/o fecha de nacimiento
			ELIF pApePat <> "" AND pNombre1 <> "" AND pApeMat <> "" AND pNombre2 <> "" AND pFecha <> DATE(1) THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
					
					--SE SEPARO LA CONSULTA PARA BAJAR EL COSTO, PRIMERO OBTENEMOS TODOS LOS CLIENTES QUE COINCIDAN CON LOS FILTROS
					SELECT {+ index (bdinteg:si_cliente idx_si_cliente2)} (TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||
							                                                   TRIM(a.nombre1)||' '||TRIM(a.nombre2)),NVL(a.rfc, ''),
                                                                 a.numcte
					  INTO v_Nombre, v_RFC, v_NumCte
		        FROM  bdinteg:si_ctepf d
						INNER JOIN bdinteg:si_cliente a ON (d.empresa=a.empresa AND d.numcte = a.numcte)
					 WHERE d.fecha_nac = pFecha
						 AND a.apell_paterno = pApePat
						 AND a.apell_materno = pApeMat
						 AND a.nombre1 = pNombre1
						 AND a.nombre2 = pNombre2
						 AND a.empresa = pEmpresa 
						
						
					--CHECAMOS SI EL CLIENTE TIENE ALGUN CREDITO
					SELECT LIMIT 1 NVL(num_credito, '')
            INTO v_NumCred
            FROM bdicred:sd_maecred 
					 WHERE empresa = pEmpresa
             AND numcte = v_NumCte;
             
					LET v_NumRegistros=dbinfo("sqlca.sqlerrd2");
					
					IF v_NumRegistros>0 THEN
					
						FOREACH
								-- OBTENEMOS LOS CREDITOS DEL CLIENTE
								SELECT NVL(num_credito, '') 
                  INTO v_NumCred 
                  FROM bdicred:sd_maecred 
								 WHERE empresa = pEmpresa 
                   AND numcte = v_NumCte
								
                                -- OBTENEMOS EL NUMERO DE LA TARJETA
								SELECT NVL(num_tarjeta, '') 
                  INTO v_NumTarjeta 
                  FROM bdicred:sd_tarjeta 
								 WHERE numcte = v_NumCte 
                   AND num_credito = v_NumCred
                   AND tipo_tarjeta = "T" 
                   AND status_tar = "A";
								
								RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
						END FOREACH;
					ELSE
						RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
					END IF;	

				END FOREACH;
			--Seccion de codigo para la busqueda por apellido paterno, apellido materno, primer nombre y/o fecha de nacimiento
			ELIF pApePat <> "" AND pNombre1 <> "" AND pApeMat <> "" AND pNombre2 = "" AND pFecha <> DATE(1) THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
				
					--SE SEPARO LA CONSULTA PARA BAJAR EL COSTO, PRIMERO OBTENEMOS TODOS LOS CLIENTES QUE COINCIDAN CON LOS FILTROS
					SELECT {+ index (bdinteg:si_cliente idx_si_cliente2)} (TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||
							                                                   TRIM(a.nombre1)||' '||TRIM(a.nombre2)),NVL(a.rfc, ''),
                                                                 a.numcte
					  INTO v_Nombre, v_RFC, v_NumCte
		        FROM bdinteg:si_ctepf d
						INNER JOIN bdinteg:si_cliente a ON (d.empresa=a.empresa AND d.numcte = a.numcte)
					 WHERE d.fecha_nac = pFecha
						 AND a.apell_paterno = pApePat
						 AND a.apell_materno = pApeMat
						 AND a.nombre1 = pNombre1
						 AND a.empresa = pEmpresa 
						
						
					--CHECAMOS SI EL CLIENTE TIENE ALGUN CREDITO
					SELECT LIMIT 1 NVL(num_credito, '') 
            INTO v_NumCred
            FROM bdicred:sd_maecred 
					 WHERE empresa = pEmpresa
             AND numcte = v_NumCte;
             
					LET v_NumRegistros=dbinfo("sqlca.sqlerrd2");
					
					IF v_NumRegistros>0 THEN
					
						FOREACH
						
								--OBTENEMOS LOS CREDITOS DEL CLIENTE
								SELECT NVL(num_credito, '') 
                  INTO v_NumCred 
                  FROM bdicred:sd_maecred 
								 WHERE empresa = pEmpresa 
                   AND numcte = v_NumCte
								
                                -- OBTENEMOS EL NUMERO DE LA TARJETA
								SELECT NVL(num_tarjeta, '') 
                  INTO v_NumTarjeta 
                  FROM bdicred:sd_tarjeta 
								 WHERE numcte = v_NumCte
                   AND num_credito = v_NumCred
                   AND tipo_tarjeta = "T" 
                   AND status_tar = "A";
								
								RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
						END FOREACH;
					ELSE
						RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
					END IF;
				END FOREACH;
			--Seccion de codigo para la busqueda por apellido paterno, primer nombre, segundo nombre y/o fecha de nacimiento
			ELIF pApePat <> "" AND pNombre1 <> "" AND pApeMat = "" AND pNombre2 <> "" AND pFecha <> DATE(1) THEN
			
				SET ISOLATION TO DIRTY READ;
			
      	FOREACH
					
					--SE SEPARO LA CONSULTA PARA BAJAR EL COSTO, PRIMERO OBTENEMOS TODOS LOS CLIENTES QUE COINCIDAN CON LOS FILTROS
					SELECT {+ index (bdinteg:si_cliente idx_si_cliente2)} (TRIM(a.apell_paterno)|| ' ' || TRIM(a.apell_materno)|| ' ' || 
							                                                   TRIM(a.nombre1)|| ' ' || TRIM(a.nombre2)),NVL(a.rfc, ''),
                                                                 a.numcte
					  INTO v_Nombre, v_RFC, v_NumCte
		        FROM  bdinteg:si_ctepf d
						INNER JOIN bdinteg:si_cliente a ON (d.empresa=a.empresa AND d.numcte = a.numcte)
					 WHERE d.fecha_nac = pFecha
						 AND a.apell_paterno = pApePat
						 AND a.apell_materno = a.apell_materno
						 AND a.nombre1 = pNombre1
						 AND a.nombre2 = pNombre2
						 AND a.empresa = pEmpresa 
						
						
					--CHECAMOS SI EL CLIENTE TIENE ALGUN CREDITO
					SELECT LIMIT 1 NVL(num_credito, '')
            INTO v_NumCred
            FROM bdicred:sd_maecred 
					 WHERE empresa = pEmpresa
             AND numcte = v_NumCte;
             
					LET v_NumRegistros=dbinfo("sqlca.sqlerrd2");
					
					IF v_NumRegistros>0 THEN
					
						FOREACH
								-- OBTENEMOS LOS CREDITOS DEL CLIENTE
								SELECT NVL(num_credito, '') 
                  INTO v_NumCred 
                  FROM bdicred:sd_maecred 
								 WHERE empresa = pEmpresa 
                   AND numcte = v_NumCte
								
            -- OBTENEMOS EL NUMERO DE LA TARJETA
								SELECT NVL(num_tarjeta, '') 
                  INTO v_NumTarjeta 
                  FROM bdicred:sd_tarjeta 
								 WHERE numcte = v_NumCte
                   AND num_credito = v_NumCred
                   AND tipo_tarjeta = "T" 
                   AND status_tar = "A";
								
								RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
						END FOREACH;
					ELSE
						RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
					END IF;	

				END FOREACH;
			--Seccion de codigo para la busqueda por apellido paterno, apellido materno, primer nombre  y/o fecha de nacimiento
			--PRUEBA DE EXPLAIN
			ELIF pApePat <> "" AND pNombre1 <> "" AND pApeMat = "" AND pNombre2 = "" AND  pFecha <> DATE(1) THEN
			
				SET ISOLATION TO DIRTY READ;
				
				FOREACH
				
					--SE SEPARO LA CONSULTA PARA BAJAR EL COSTO, PRIMERO OBTENEMOS TODOS LOS CLIENTES QUE COINCIDAN CON LOS FILTROS
					SELECT {+ index (bdinteg:si_cliente idx_si_cliente2)} (TRIM(a.apell_paterno)|| ' ' || TRIM(a.apell_materno)|| ' ' ||	
							                                                   TRIM(a.nombre1)|| ' ' || TRIM(a.nombre2)),NVL(a.rfc, ''),
                                                                 a.numcte
					  INTO v_Nombre, v_RFC, v_NumCte
		        FROM  bdinteg:si_ctepf d
					 INNER JOIN bdinteg:si_cliente a ON (d.empresa=a.empresa AND d.numcte = a.numcte)
					 WHERE d.fecha_nac = pFecha
					   AND a.apell_paterno =pApePat
						 AND a.apell_materno = a.apell_materno
						 AND a.nombre1 =pNombre1
						 AND a.empresa = pEmpresa 
						
						
					--CHECAMOS SI EL CLIENTE TIENE ALGUN CREDITO
					SELECT LIMIT 1 NVL(num_credito, '') 
            INTO v_NumCred
            FROM bdicred:sd_maecred 
					 WHERE empresa = pEmpresa
             AND numcte = v_NumCte;
             
					LET v_NumRegistros=dbinfo("sqlca.sqlerrd2");
					
					IF v_NumRegistros>0 THEN
						FOREACH
								-- OBTENEMOS LOS CREDITOS DEL CLIENTE
								SELECT NVL(num_credito, '') 
                  INTO v_NumCred 
                  FROM bdicred:sd_maecred 
								 WHERE empresa = pEmpresa 
                   AND numcte = v_NumCte

								--OBTENEMOS EL NUMERO DE LA TARJETA
								SELECT NVL(num_tarjeta, '') 
                  INTO v_NumTarjeta 
                  FROM bdicred:sd_tarjeta 
								 WHERE numcte = v_NumCte 
                   AND num_credito = v_NumCred
                   AND tipo_tarjeta = "T" 
                   AND status_tar = "A";
								
								RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
						END FOREACH;
					ELSE
						RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta WITH RESUME;
					end if;	

				END FOREACH;
			ELSE
			--PRUEBA DE EXPLAIN
				LET v_codret = "999"; --Faltan parametros
	            RETURN v_codret, v_NumCte, v_Nombre, v_RFC, v_NumCred, v_NumTarjeta;
			END IF;
		END IF;
	END;

END PROCEDURE;