CREATE PROCEDURE "informix".sp_status_ctas_ina_pbas3(vfechacarga DATE)
	 RETURNING CHAR(5), CHAR(60);
	    
		/*Definicion de variables del proceso y manejo de errores*/
		DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(5);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		DEFINE vpaso      		DECIMAL(17,0);
		DEFINE sumtotal   		DECIMAL(17,0);
		DEFINE grantotal 		DECIMAL(17,0);
		DEFINE vsArchTemporal 	CHAR (15);
		DEFINE vsNomArchivo 	CHAR (40);
		DEFINE vsSQL 			CHAR (2100);
		DEFINE vsSQL1 			CHAR (200);
		DEFINE vsSQL2 			CHAR (700);
		DEFINE vsSQL3 			CHAR (200);
		DEFINE vfechames        DATE;
		DEFINE vaniomes			CHAR(6);
		DEFINE count1           DECIMAL(17,0);
		DEFINE count2           DECIMAL(17,0);
		DEFINE count3           DECIMAL(17,0);
		DEFINE feculmesant		DATE;
		DEFINE vcampo           VARCHAR(8);
		DEFINE vcamp0           VARCHAR(8);
		DEFINE vcamp1           VARCHAR(8);
		DEFINE vcamp2           VARCHAR(8);
		DEFINE vcamp3           VARCHAR(8);

		/*Inicializando variables de manejo de errores*/

		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		LET vpaso 		  	= 0;
		LET sumtotal      	= 0;
		LET grantotal 		= 0;
		LET vsArchTemporal 	= '';
		LET vsNomArchivo 	= '';
		LET vsSQL 			= '';
		LET vsSQL1 			= '';
		LET vsSQL2 			= '';
		LET vsSQL3 			= '';
		LET count1 			= 0;
		LET count2 			= 0;
		LET count3 			= 0;
		LET vfechames 		= (EXTEND(vfechacarga, YEAR TO MONTH) -1 UNITS MONTH)::DATE;
		LET vaniomes 		= SUBSTRING (vfechames FROM 7 FOR 4)||SUBSTRING (vfechames FROM 1 FOR 2);
		LET feculmesant		= LAST_DAY((EXTEND(vfechacarga, YEAR TO MONTH) -1 UNITS MONTH)::DATE);
		LET vcampo 			= 'capvig'||SUBSTRING (feculmesant FROM 4 FOR 2);
		LET vcamp0 			= 'capvig28';
		LET vcamp1 			= 'capvig29';
		LET vcamp2 			= 'capvig30';
		LET vcamp3 			= 'capvig31';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		/*Incia SP*/
		BEGIN
			/*Excepciones*/
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret, error_info;
				END IF;
			END EXCEPTION;
			
			/*Inicia proceso*/
			--//se valida si existe la tabla para eliminarla
			--IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'sc_ctas_pro_ina')
			--THEN 	
		--				DROP TABLE "informix".sc_ctas_pro_ina;
		--				LET error_info = 'Se borro tabla sc_ctas_pro_ina';
		--	END IF;
		--	
		--	CREATE TABLE "informix".sc_ctas_pro_ina(
		--											aniomes     CHAR(6),
		--											producto    CHAR(12),
		--											prod_rel    CHAR(12),
		--											status_cta  CHAR(5),
		--											total decimal(17,0)
		--											)
		--											EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
		--	LET error_info = 'Se creo tabla sc_ctas_pro_ina';
			
			/*SE INICIA CON EL PRODUCTO 2000*/
			/*Se crea tabla temporal condicionada al ultimo dÃ­a del mes anterior*/
			IF (vcampo = vcamp0) THEN
			SELECT {+MULTI_INDEX(sc_maechq)}  A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2000' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2000;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT {+MULTI_INDEX(sc_maechq)} A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2000' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2000;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT  {+MULTI_INDEX(sc_maechq)} A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2000' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2000;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT {+MULTI_INDEX(sc_maechq)} A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2000' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2000;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp2000';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp2000 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp2000 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2000 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2000 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaci?n descartando 2000 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp2000 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('2000', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2000 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp2000 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2000', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2000 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2000', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2000 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp2000 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2000', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2000 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2000', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2000 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp2000 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2000', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2000 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2000', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 2000*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '2000';
			/*Se inserta el total del producto 2000*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2000', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 2000';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp2000;
			LET error_info = 'se elimino tabla tbltmp2000';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 2000';
			/*SE INICIA CON EL PRODUCTO 1900*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1900' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1900;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1900' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1900;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1900' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1900;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1900' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1900;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp1900';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1900 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1900 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1900 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1900 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1900 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1900 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('1900', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1900 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1900 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1900', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1900 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1900', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1900 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1900 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1900', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1900 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1900', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1900 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1900 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1900', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1900 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1900', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1900*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1900';
			/*Se inserta el total del producto 1900*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1900', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1900';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1900;
			LET error_info = 'se elimino tabla tbltmp1900';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1900';
			/*SE INICIA CON EL PRODUCTO 1800*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1800' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1800;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1800' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1800;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1800' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1800;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1800' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1800;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp1800';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1800 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1800 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1800 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1800 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1800 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1800 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('1800', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1800 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1800 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1800', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1800 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1800', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1800 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1800 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1800', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1800 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1800', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1800 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1800 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1800', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1800 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1800', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1800*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1800';
			/*Se inserta el total del producto 1800*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1800', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1800';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1800;
			LET error_info = 'se elimino tabla tbltmp1800';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1800';
			/*SE INICIA CON EL PRODUCTO 2400*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2400;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2400;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2400;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2400;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp2400';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp2400 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp2400 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2400 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2400 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 2400 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp2400 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('2400', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2400 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp2400 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2400', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2400 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp2400 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2400', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2400 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp2400 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2400', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 2400*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '2400';
			/*Se inserta el total del producto 2400*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2400', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 2400';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp2400;
			LET error_info = 'se elimino tabla tbltmp2400';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 2400';
			/*SE INICIA CON EL PRODUCTO 1500*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1500;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1500;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1500;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1500;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp1500';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1500 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1500 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1500 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1500 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1500 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1500 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('1500', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1500 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1500 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1500', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1500 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1500 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1500', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1500 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1500 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1500', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1500*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1500';
			/*Se inserta el total del producto 1500*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1500', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1500';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1500;
			LET error_info = 'se elimino tabla tbltmp1500';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1500';
			/*SE INICIA CON EL PRODUCTO 2500*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2500;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2500;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2500;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '2500' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp2500;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp2500';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp2500 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp2500 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2500 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp2500 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 2500 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp2500 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						   AND B.producto NOT IN ('2500', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2500 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp2500 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2500', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2500 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp2500 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2500', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 2500 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp2500 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('2500', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 2500 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2500', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 2500*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '2500';
			/*Se inserta el total del producto 2500*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '2500', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 2500';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp2500;
			LET error_info = 'se elimino tabla tbltmp2500';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 2500';
			/*SE INICIA CON EL PRODUCTO 1400*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1400;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1400;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1400;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1400' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1400;
			END IF
			LET error_info = 'se creo tabla temporal tbltmp1400';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1400 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1400 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1400 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1400 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1400 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1400 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						  AND B.producto NOT IN ('1400', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1400 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1400 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1400', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1400 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1400 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1400', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1400 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1400 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1400', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1400 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1400', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1400*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1400';
			/*Se inserta el total del producto 1400*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1400', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1400';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1400;
			LET error_info = 'se elimino tabla tbltmp1400';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1400';
			/*SE INICIA CON EL PRODUCTO 1700*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1700' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1700;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1700' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1700;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1700' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1700;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1700' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1700;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp1700';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1700 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1700 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1700 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1700 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1700 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1700 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						  AND B.producto NOT IN ('1700', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1700 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1700 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1700', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1700 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1700', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1700 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1700 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1700', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1700 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1700', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1700 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1700 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1700', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1700 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1700', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1700*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1700';
			/*Se inserta el total del producto 1700*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1700', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1700';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1700;
			LET error_info = 'se elimino tabla tbltmp1700';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1700';
			/*SE INICIA CON EL PRODUCTO 1300*/
			/*Se crea tabla temporal*/
			IF (vcampo = vcamp0) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig28 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1300' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1300;
			END IF;
			IF (vcampo = vcamp1) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig29 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1300' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1300;
			END IF;
			IF (vcampo = vcamp2) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig30 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1300' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1300;
			END IF;
			IF (vcampo = vcamp3) THEN
			SELECT A.producto, A.num_cte, A.cuenta, capvig31 AS saldo
				 FROM sc_maechq A, sc_sdodiarioc B
					WHERE A.empresa = '001' AND A.producto = '1300' AND A.status_cta = 4
                      AND A.cuenta = B.cuenta
                      AND B.aniomes = vaniomes
			INTO TEMP tbltmp1300;
			END IF;
			LET error_info = 'se creo tabla temporal tbltmp1300';
			/*se insertan las inversiones crecientes a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.producto, B.status_cta AS status, COUNT(*)
						FROM tbltmp1300 A, sc_maechq B 
							 WHERE A.num_cte = B.num_cte
							   AND B.producto = '1100'
						GROUP BY A.producto, B.producto, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 1100 en sc_ctas_pro_ina';
			/*se insertan los pagares a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.cod_instrum, B.status_cta AS status, COUNT(*)
						FROM tbltmp1300 A, bdinvers:sv_maeinv B 
							WHERE A.num_cte = B.num_cte
							  AND B.cod_instrum = '3000'
						GROUP BY A.producto, B.cod_instrum, B.status_cta ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 3000 en sc_ctas_pro_ina';
			/*se insertan los prestamos personales a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1300 A, bdicred:sd_maecredcrd B 
							 WHERE A.num_cte = B.numcte
							   AND B.num_producto = '6011'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6011 en sc_ctas_pro_ina';
			/*se insertan las tajetas de crÃ©dito a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT vaniomes, A.producto, B.num_producto, B.status_cred AS status, COUNT(*)
						FROM tbltmp1300 A, bdicred:sd_maecred B 
							 WHERE A.num_cte = B.numcte
								   AND B.num_producto = '6001'
							GROUP BY A.producto, B.num_producto, B.status_cred ORDER BY 2, 3, 4;
			LET error_info = 'se inserto 6001 en sc_ctas_pro_ina';
			/*se inserta sumatoria de otros productos de captaciÃ³n descartando 1300 y 1100 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
					SELECT  vaniomes, A.producto, 'otro' AS producto, '' AS status, COUNT(*)
						FROM tbltmp1300 A, sc_maechq B 
								WHERE A.num_cte = B.num_cte
    						  AND B.producto NOT IN ('1300', '1100')
							GROUP BY A.producto ORDER BY 2, 3, 4;
			LET error_info = 'se inserto otros en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1300 <= 0*/
			SELECT COUNT(*) INTO count1
					FROM tbltmp1300 WHERE saldo <=0
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1300', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1300 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1300', '<=0', '',  count1 ); 
			LET error_info = 'se inserto sin otros <=0 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1300 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count2
					FROM tbltmp1300 WHERE saldo BETWEEN 0.01 AND 999.99
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1300', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1300 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1300', '0.01 A -MIL', '',  count2 ); 
			LET error_info = 'se inserto sin otros 0.01 a 999.99 en sc_ctas_pro_ina';
			/*Se carga variabla con total sin otros productos de cuentas 1300 ENTRE 0.01 Y 999.99*/
			SELECT COUNT(*) INTO count3
					FROM tbltmp1300 WHERE saldo >=1000
						AND num_cte NOT IN (SELECT num_cte FROM sc_maechq WHERE empresa = '001' AND  producto NOT IN ('1300', '1100')) 
						AND num_cte NOT IN (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa = '001') 
						AND num_cte NOT IN (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = '001');
			/*se inserta total sin otros productos de cuentas 1300 <= 0 a la tabla*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1300', 'MAYOR MIL', '',  count3 );
			LET error_info = 'se inserto sin otros >1000 en sc_ctas_pro_ina';
			/*se hace sumatoria del producto 1300*/
			SELECT SUM(total)  INTO sumtotal FROM sc_ctas_pro_ina WHERE producto = '1300';
			/*Se inserta el total del producto 1300*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, '1300', '', 'Total',  sumtotal);
			LET error_info = 'se inserto total producto 1300';
			/*se elimina tabla temporal*/
			DROP TABLE tbltmp1300;
			LET error_info = 'se elimino tabla tbltmp1300';
			/*se limpian variables*/
			LET count1 = 0;
			LET count2 = 0;
			LET count3 = 0;
			LET sumtotal = 0;
			LET error_info = 'se limpian variables con datos 1300';
			/*Se hace la sumatoria para la parte de totales*/
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO 1100*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '1100'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado 1100';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO 3000*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '3000'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado 3000';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO 6011*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '6011'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado 6011';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO 6001*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '6001'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado 6001';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO otro*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = 'otro'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado otro';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO <=0*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '<=0'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado <=0';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO 0.01 A -MIL*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = '0.01 A -MIL'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado 0.01 A -MIL';
			/*SE INSERTA SUMATORIA DE PRODUCTO RELACIONADO MAYOR MIL*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
			SELECT vaniomes, 'TOTAL', prod_rel, status_cta, SUM(total)
				FROM "informix".sc_ctas_pro_ina
					WHERE prod_rel = 'MAYOR MIL'
			GROUP BY prod_rel, status_cta ORDER BY 3, 4;
			LET error_info = 'se inserto total producto relacionado MAYOR MIL';
			/*SE HACE SUMATORIA TOTAL FINAL */
			SELECT SUM(total) INTO grantotal
				FROM "informix".sc_ctas_pro_ina
					WHERE producto = 'TOTAL';
			LET error_info = 'Se obtiene sumatoria para el total final';
			/*SE INSERTA TOTAL  FINAL*/
			INSERT INTO "informix".sc_ctas_pro_ina(aniomes, producto, prod_rel, status_cta, total)
				VALUES (vaniomes, 'TOTAL', '', '',  grantotal);
			LET error_info = 'Se inserta total final';
			LET error_info = 'Termina proceso de carga ok';
			/*MANEJO DE ARCHIVOS*/
			LET vsArchTemporal = 'temporal3.txt';
			LET vsNomArchivo = 'ctas_sta_ina' || TRIM(vaniomes) || '.txt' ;

			/*GENERA EL ARCHIVO DE INTERCAMBIO*/
			LET vsSQL1 = 'echo "UNLOAD TO /resplogifx/conciliachq/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''|''';

			LET vsSQL2 = " SELECT producto, prod_rel AS relacionadasconotroproducto, status_cta, total FROM sc_ctas_pro_ina;";

			LET vsSQL3 = '" > /resplogifx/conciliachq/control_reporte3.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL2 = TRIM(vsSQL2);
			LET vsSQL3 = TRIM(vsSQL3);
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			
			SYSTEM vsSQL;
			/*Permiso para la creacion de archivo.*/
			LET vsSQL = '' ;
			LET vsSQL = 'chmod 666 /resplogifx/conciliachq/control_reporte3.sql' ;
			SYSTEM vsSQL;
			LET vsSQL = '' ;
			LET vsSQL = 'dbaccess bdicheq /resplogifx/conciliachq/control_reporte3.sql';
			SYSTEM vsSQL;
			/*Borra el archivo de control.*/
			LET vsSQL = '' ;
			LET vsSQL = 'rm /resplogifx/conciliachq/control_reporte3.sql';
			SYSTEM vsSQL ;
			/*Se pasa la informaciÃ³n al archivo final quitando el Ãºlimo pipe*/
			LET vsSQL = '' ;
			LET vsSQL =  "sed 's/|$//g' /resplogifx/conciliachq/" || TRIM (vsArchTemporal) || " >  /resplogifx/conciliachq/" ||TRIM (vsNomArchivo);
			SYSTEM vsSQL;
			/*Borra el archivo de control.*/
			LET vsSQL = '' ;
			LET vsSQL = 'rm /resplogifx/conciliachq/' || TRIM (vsArchTemporal);
			SYSTEM vsSQL ;
			
			LET vcodret = '00000';
			LET error_info = 'PROCESO EXITOSO';
			RETURN vcodret, error_info;
		END;
END PROCEDURE
DOCUMENT
'AUTOR: Israel Flores GonzÃ¡lez',
'FECHA DE CREACION: 6 MARZO 2017',
'OBJETIVO: Generar un archivo con la',
'	       informacion de las cuentas',
'		   de captacion inactivas indicando',
'	       su relacion con otros productos';

CREATE PROCEDURE "informix".sdos_diarios_trfn()
RETURNING CHAR(5);

    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;  
    DEFINE visamerr     INTEGER;  
    DEFINE vdescerr     CHAR(50);
    DEFINE vsql         CHAR(600);
    DEFINE vfecha       DATE; 
    DEFINE vaniomes     CHAR(6);
    DEFINE vdia         CHAR(2);
    DEFINE vfecha_hoy   DATE;
    DEFINE vfecha_desc  CHAR(8);

    LET vcodret     = "000";
    LET vcodret2    = "";
    LET vcodret3    = "";
    LET vsqlerr     = 0;
    LET visamerr    = 0;
    LET vdescerr    = '';
    LET vsql        = '';
    LET vfecha      = '';
    LET vaniomes    = '';
    LET vdia        = '';
    LET vfecha_hoy  = '';
    LET vfecha_desc = '';

    --- SET DEBUG FILE TO "sdos_diarios_trfn.out";
    --- TRACE ON;  

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "sdos_diarios_trfn.err";
        TRACE ON; 
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;

    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha
      FROM sc_fechas
     WHERE empresa = "001";

    LET vdia = SUBSTR(vfecha,4,2);
    LET vdia = vdia;
    
    LET vaniomes = SUBSTR(vfecha,7,4) || SUBSTR(vfecha,1,2);
    LET vaniomes = vaniomes;
    
    LET vfecha_desc = LPAD(SUBSTR(vfecha,4,2),2,'0')||LPAD(SUBSTR(vfecha,1,2),2,'0')||(SUBSTR(vfecha,7,4));
    
    IF LPAD(vdia,2,'0') = '01' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig1, sdo.intprovnp1, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ELIF LPAD(vdia,2,'0') = '02' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig2, sdo.intprovnp2, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '03' THEN
      
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig3, sdo.intprovnp3, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '04' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig4, sdo.intprovnp4, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '05' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig5, sdo.intprovnp5, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '06' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig6, sdo.intprovnp6, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '07' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig7, sdo.intprovnp7, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '08' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig8, sdo.intprovnp8, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '09' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig9, sdo.intprovnp9, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '10' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig10, sdo.intprovnp10, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '11' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig11, sdo.intprovnp11, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '12' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig12, sdo.intprovnp12, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '13' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig13, sdo.intprovnp13, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '14' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig14, sdo.intprovnp14, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '15' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig15, sdo.intprovnp15, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '16' THEN
         
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig16, sdo.intprovnp16, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '17' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig17, sdo.intprovnp17, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '18' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig18, sdo.intprovnp18, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '19' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig19, sdo.intprovnp19, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '20' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig20, sdo.intprovnp20, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '21' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig21, sdo.intprovnp21, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '22' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig22, sdo.intprovnp22, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '23' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig23, sdo.intprovnp23, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '24' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig24, sdo.intprovnp24, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '25' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig25, sdo.intprovnp25, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '26' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig26, sdo.intprovnp26, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '27' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig27, sdo.intprovnp27, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '28' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig28, sdo.intprovnp28, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '29' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig29, sdo.intprovnp29, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '30' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig30, sdo.intprovnp30, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '31' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig31, sdo.intprovnp31, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ELSE

        LET vcodret = '200';  -- // FECHA INVALIDA

    END IF;

    END;

    RETURN vcodret;

END PROCEDURE;