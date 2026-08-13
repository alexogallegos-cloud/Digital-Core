CREATE PROCEDURE "informix".sp_migraciondedatosaltacliente()
	RETURNING CHAR(6) AS codigo_retorno;
	
	DEFINE v_empresa			CHAR(3);
	DEFINE v_num_cte			CHAR(20);
	DEFINE v_puesto				CHAR(3);
	DEFINE v_puesto_esp			CHAR(3);
	DEFINE v_codigo_retorno		CHAR(3);
	DEFINE v_secuencia			INTEGER;
	DEFINE vsqlerr				INTEGER;
	
	--*********************************************************--
	-- Creado por J. Rodolfo Uriarte R.		
	--25/Noviembre/2008 
	--Migración de puestos de clientes
	--*********************************************************--
	
	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
	
	--SET DEBUG FILE TO "/tmp/sp_migracionDeDatosAltaCliente.out";
	--TARCE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				
				RETURN v_codigo_retorno;
			END IF;
		END EXCEPTION;
		
		FOREACH
			SELECT empresa, numcte, sec_ingreso, puesto, puesto_esp INTO v_empresa, v_num_cte, v_secuencia, v_puesto, v_puesto_esp FROM bdinteg:si_ingresos
			
			UPDATE bdinteg:si_ingresos SET clavepuesto = NULL, claveopcionpuesto = NULL, clavesubopcionpuesto = NULL WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
			
			IF v_puesto = "001" OR v_puesto = "002" THEN
				UPDATE bdinteg:si_ingresos SET clavepuesto = 1 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
			ELIF  v_puesto = "003" THEN
				IF v_puesto_esp = "01" OR v_puesto_esp = "02" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 3, claveopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "03" OR v_puesto_esp = "04" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 5, claveopcionpuesto = 12 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "05" OR v_puesto_esp = "07" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 4, claveopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "06" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 3, claveopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "08" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 9 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				END IF;
			ELIF  v_puesto = "004" THEN
				UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 5 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
			ELIF  v_puesto = "005" THEN
				IF v_puesto_esp = "01" OR v_puesto_esp = "02" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 10 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "03" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 10 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "04" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 3, clavesubopcionpuesto = 27 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "05" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 4, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "06" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "07" OR v_puesto_esp = "08" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 7, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "09" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "10" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 1, clavesubopcionpuesto = 1 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "11" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 1, clavesubopcionpuesto = 1 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "12" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 1, clavesubopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "13" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 1, clavesubopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "14" OR v_puesto_esp = "15" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 5, clavesubopcionpuesto = 11 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "16" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "17" OR v_puesto_esp = "18" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 2, clavesubopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				END IF;
			ELIF  v_puesto = "006" THEN
				IF v_puesto_esp = "01" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "02" OR v_puesto_esp = "05" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 19 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "03" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 2, clavesubopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "04" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 5, clavesubopcionpuesto = 13 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "06" OR v_puesto_esp = "07" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 5 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "08" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 24 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "09" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 8 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "10" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 18 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "11" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 6 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "12" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 23 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "13" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 6, clavesubopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "14" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 11 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "15" OR v_puesto_esp = "18" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "16" OR v_puesto_esp = "20" OR v_puesto_esp = "22" OR v_puesto_esp = "25" OR v_puesto_esp = "27" OR v_puesto_esp = "28" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 2, clavesubopcionpuesto = 1 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "17" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 2, clavesubopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "19" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 5, clavesubopcionpuesto = 11 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "21" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 25 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "23" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 1, claveopcionpuesto = 5 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "24" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 6, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "26" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3, clavesubopcionpuesto = 17 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "29" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "30" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 6 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "31" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 8, clavesubopcionpuesto = 1 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "32" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 7, clavesubopcionpuesto = 4 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				ELIF v_puesto_esp = "33" THEN
					UPDATE bdinteg:si_ingresos SET clavepuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
				END IF;
			ELIF  v_puesto = "007" THEN
				UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 5, clavesubopcionpuesto = 2 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
			ELIF  v_puesto = "008" THEN
				UPDATE bdinteg:si_ingresos SET clavepuesto = 2, claveopcionpuesto = 3 WHERE numcte = v_num_cte AND sec_ingreso = v_secuencia;
			END IF;
		END FOREACH;
		
		RETURN v_codigo_retorno;
		
	END;
END PROCEDURE;