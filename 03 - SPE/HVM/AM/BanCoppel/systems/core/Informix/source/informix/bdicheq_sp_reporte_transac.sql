CREATE PROCEDURE "informix".sp_reporte_transac()

      RETURNING CHAR(5);
	  
	  DEFINE vsqlerr 	  INTEGER;
	  DEFINE vcodret      CHAR(5);
	  DEFINE v_prim_dia   DATE;
	  DEFINE v_ult_dia    DATE;
	  DEFINE v_prim_ori   INTEGER;
	  DEFINE v_num_tran   CHAR(4);
	  DEFINE v_total      INTEGER;
	  DEFINE v_tota1      INTEGER;
	  DEFINE v_tota2      INTEGER;
	  DEFINE v_mes        CHAR(4);
	  DEFINE v_mes_2      CHAR(4);
	  DEFINE suma_sub_1   INTEGER;
	  DEFINE suma_sub_2   INTEGER;
	  DEFINE total        INTEGER;
	  DEFINE vfecha_hoy   DATE; 
	  DEFINE mes_fin      VARCHAR(2); 
	  DEFINE mes_fin_1    varchar(2); 
	  DEFINE anio_fin     INTEGER; 
	  DEFINE f_fin        varchar(6);  
	  DEFINE f_fin_1      varchar(6);
	  DEFINE vsql         CHAR(500);
	  
	  LET vsqlerr = 0; 
      LET vcodret = '00000'; 
	  
	  
	  BEGIN
	  ON EXCEPTION SET vsqlerr
	     SET DEBUG FILE TO "/resplogifx/conciliachq/trasa_error.txt";
	  	   TRACE ON;
             IF vsqlerr <> 0 THEN
                LET vcodret = vsqlerr;
             RETURN vcodret;
             END IF;
      END EXCEPTION;
	  
	  ---SET DEBUG FILE TO "//informix/ids_10UC11/raul/Reporte_mensual_transacciones/SP/log_error_2.txt";
	  ---TRACE ON;
	  
	  SET ISOLATION TO DIRTY READ;
	  
	  --SE OBTIENEN LAS FECHAS CON LAS QUE SE VA A TRABAJAR 

      SELECT  DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY)   , MONTH(pri_dia_mes)
      INTO    v_prim_dia 	 					,v_ult_dia							, v_prim_ori
      FROM    sc_fechas;
	 
	 		  
	  --EL PROCESO TRABAJA CON UN MES ATRAS SI ES FEBRERO SE INICIALIZA LA TABLA  2 -1 = ENERO 
	  IF v_prim_ori = 2 THEN 
	  
	     TRUNCATE TABLE  "informix".sc_rep_transacciones;  
		 
		 --SE INSERTA ENCABEZADO DEL REPORTE
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('CLAVE','DESCRIPCION','SISTEMA','ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','Transacciones Pagos Depositos','','','','','','','','','','','','','');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0282','DEPOSITO A CUENTA CORRESP','CAP');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('6282','PAGO CORRESPONSAL COPPEL','TDC');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','1_Subtotal','','','','','','','','','','','','','');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','','','','','','','','','','','','','','');
		 COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','Nuevas Transacciones','','','','','','','','','','','','','');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0401','CONSULTA DE SALDO CORRESP','CAP');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0402','RETIRO DE EFECTIVO CORRES','CAP');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0403','CARGO POR TRASPASO CORRES','CAP');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0404','ABONO POR TRASPASO CORRES','CAP');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0405','CARGO POR PAGO DE TDC COR','CAP/TDC');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('0406','PAGO DE TDC (CARGO A CTA','CAP/TDC');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('1196','PAGO INTERBANCARIO TDC (CARGO)','CAP');
		 COMMIT;        
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('1197','PAGO INTERBANCARIO TDC (EFECT))','');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('8105','DISPOSICION EFECTIVO','TDC');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema ) VALUES ('8112','DISPOSICION EFECTIVO (A FAVOR)','TDC');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','2_Subtotal','','','','','','','','','','','','','');
         COMMIT;
		 
		 BEGIN;
		 INSERT INTO "informix".sc_rep_transacciones (clave, descripcion, sistema,Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic) VALUES ('','Total','','','','','','','','','','','','','');      
	     COMMIT;
	  END IF; 
	 
	  --TABLA TEMPORAL QUE TIENE DEFINIDAS LAS TRANSACCIONES 
	  CREATE TEMP TABLE sc_transacciones
	  (
	  num_tran CHAR(4)  
	  ); 
	  
	  -- TABLA TEMPORAL UTILIZADA PARA LAS SUMAS  	   
	  CREATE  TEMP TABLE sc_sumas
	  (
	  c1 DECIMAL(14,2) DEFAULT 0,
	  c2 DECIMAL(14,2) DEFAULT 0 
	  );
	   
	  -- SE INSERTAN LAS TRANSACCIONES CON LAS QUE SE VA A TRABAJAR
	  INSERT INTO sc_transacciones VALUES ("0282");
	  INSERT INTO sc_transacciones VALUES ("0401");
	  INSERT INTO sc_transacciones VALUES ("0402");
	  INSERT INTO sc_transacciones VALUES ("0403");
	  INSERT INTO sc_transacciones VALUES ("0404");
	  INSERT INTO sc_transacciones VALUES ("0405");
	  INSERT INTO sc_transacciones VALUES ("0406");
	  INSERT INTO sc_transacciones VALUES ("1196");
	  INSERT INTO sc_transacciones VALUES ("1197");
	  INSERT INTO sc_transacciones VALUES ("6282");
	  INSERT INTO sc_transacciones VALUES ("8105");
	  INSERT INTO sc_transacciones VALUES ("8112");
	  INSERT INTO sc_transacciones VALUES ("8104");
	    
	  --SE OBTIENE EL MES CON EL QUE SE VA A TRABAJAR	
	  LET v_mes  = MONTH(v_prim_dia);	
	 
	  -- INICIA EL CICLO PARA OBTENER TOTALES POR TRANSACION Y POR MES DEFINIDO.
	  FOREACH WITH HOLD
	  
				SELECT num_tran
				  INTO v_num_tran
				  FROM sc_transacciones
				
				IF v_num_tran IN("0282","0401","0402","0403","0404","0405","0406","1196","1197") THEN 			   

				    SELECT {+INDEX(sc_movhis idx_movhisnew4)} 
    					    COUNT(*)
				      INTO  v_tota1
                      FROM  bdicheq:sc_movhis as ch, bdinteg:si_transacc as tr
					 WHERE  ch.fech_alt >= v_prim_dia
                       AND  ch.fech_alt <= v_ult_dia
					   AND  ch.transacc = v_num_tran
					   AND  ch.empresa  = '001' 
					   AND  ch.cancelad <> "S"
					   AND  ch.transacc = tr.numero
					   AND  ch.sucursal = "5005"
                       AND  tr.sistema  = "01";
					    
						
					SELECT  COUNT(*)
				      INTO  v_tota2
                      FROM  bdicheq:sc_movhis_old as ch, bdinteg:si_transacc as tr
					 WHERE  ch.fech_alt >= v_prim_dia
                       AND  ch.fech_alt <= v_ult_dia
					   AND  ch.transacc = v_num_tran
					   AND  ch.empresa  = '001' 
					   AND  ch.cancelad <> "S"
					   AND  ch.transacc = tr.numero
					   AND  ch.sucursal = "5005"
                       AND  tr.sistema  = "01";
					   
					   
					   LET v_total = v_tota1 + v_tota2;
					
					   -- SE OBTIENE EL MES CON EL QUE SE VA A TRABAJAR
					   -- LET v_mes  = MONTH(v_prim_dia);
					   
					   IF v_mes = '1' THEN LET v_mes = 'ene'; END IF; 
					   IF v_mes = '2' THEN LET v_mes = 'feb'; END IF;
					   IF v_mes = '3' THEN LET v_mes = 'mar'; END IF; 
					   IF v_mes = '4' THEN LET v_mes = 'abr'; END IF;
					   IF v_mes = '5' THEN LET v_mes = 'may'; END IF; 
					   IF v_mes = '6' THEN LET v_mes = 'jun'; END IF; 
					   IF v_mes = '7' THEN LET v_mes = 'jul'; END IF; 
					   IF v_mes = '8' THEN LET v_mes = 'ago'; END IF; 
					   IF v_mes = '9' THEN LET v_mes = 'sep'; END IF; 
					   IF v_mes = '10' THEN LET v_mes = 'oct'; END IF; 
					   IF v_mes = '11' THEN LET v_mes = 'nov'; END IF; 
					   IF v_mes = '12' THEN LET v_mes = 'dic'; END IF; 
					   
					   IF v_mes = 'ene' THEN UPDATE sc_rep_transacciones SET ene = v_total WHERE clave = v_num_tran; END IF;  
					   IF v_mes = 'feb' THEN UPDATE sc_rep_transacciones SET feb = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'mar' THEN UPDATE sc_rep_transacciones SET mar = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'abr' THEN UPDATE sc_rep_transacciones SET abr = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'may' THEN UPDATE sc_rep_transacciones SET may = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'jun' THEN UPDATE sc_rep_transacciones SET jun = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'jul' THEN UPDATE sc_rep_transacciones SET jul = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'ago' THEN UPDATE sc_rep_transacciones SET ago = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'sep' THEN UPDATE sc_rep_transacciones SET sep = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'oct' THEN UPDATE sc_rep_transacciones SET oct = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'nov' THEN UPDATE sc_rep_transacciones SET nov = v_total WHERE clave = v_num_tran; END IF;
					   IF v_mes = 'dic' THEN UPDATE sc_rep_transacciones SET dic = v_total WHERE clave = v_num_tran; END IF;   
					   
					   
					   LET v_total = 0;

				END IF; 
	 
					   IF v_num_tran IN ("6282","8105","8112") THEN 			   

					      	SELECT COUNT(*) 
					      	  INTO v_total
					      	  FROM bdicred:sd_movhis     AS mo,
					      	       bdinteg:si_transacc   AS tr
					      	 WHERE mo.sucursal = "5005"
					      	   AND mo.transacc_suc = tr.numero
					      	   AND tr.sistema = "06"
					      	   AND mo.transacc_suc = v_num_tran
					      	   AND mo.reversado = "N"
					      	   AND ((mo.transacc_suc = '6282' AND mo.codigo_ref = 1   AND mo.codigo_fun = '700')   
					      		OR (mo.transacc_suc = '8105'  AND mo.codigo_ref = 109 AND mo.codigo_fun = '002') 
					      		OR (mo.transacc_suc = '8112'  AND mo.codigo_ref = 110 AND mo.codigo_fun = '002'))
					      	   AND mo.fecha_mov >= v_prim_dia
					      	   AND mo.fecha_mov <= v_ult_dia;
					      	   						   
					      	  --- LET v_mes  = MONTH(v_prim_dia);
					         
				              	   IF v_mes = '1' THEN LET v_mes = 'ene'; END IF; 
				              	   IF v_mes = '2' THEN LET v_mes = 'feb'; END IF;
				              	   IF v_mes = '3' THEN LET v_mes = 'mar'; END IF; 
				              	   IF v_mes = '4' THEN LET v_mes = 'abr'; END IF;
				              	   IF v_mes = '5' THEN LET v_mes = 'may'; END IF; 
				              	   IF v_mes = '6' THEN LET v_mes = 'jun'; END IF; 
				              	   IF v_mes = '7' THEN LET v_mes = 'jul'; END IF; 
				              	   IF v_mes = '8' THEN LET v_mes = 'ago'; END IF; 
				              	   IF v_mes = '9' THEN LET v_mes = 'sep'; END IF; 
				              	   IF v_mes = '10' THEN LET v_mes = 'oct'; END IF; 
				              	   IF v_mes = '11' THEN LET v_mes = 'nov'; END IF; 
				              	   IF v_mes = '12' THEN LET v_mes = 'dic'; END IF; 
				              	   
				              	   IF v_mes = 'ene' THEN UPDATE sc_rep_transacciones SET ene = v_total WHERE clave = v_num_tran; END IF;  
				              	   IF v_mes = 'feb' THEN UPDATE sc_rep_transacciones SET feb = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'mar' THEN UPDATE sc_rep_transacciones SET mar = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'abr' THEN UPDATE sc_rep_transacciones SET abr = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'may' THEN UPDATE sc_rep_transacciones SET may = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'jun' THEN UPDATE sc_rep_transacciones SET jun = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'jul' THEN UPDATE sc_rep_transacciones SET jul = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'ago' THEN UPDATE sc_rep_transacciones SET ago = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'sep' THEN UPDATE sc_rep_transacciones SET sep = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'oct' THEN UPDATE sc_rep_transacciones SET oct = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'nov' THEN UPDATE sc_rep_transacciones SET nov = v_total WHERE clave = v_num_tran; END IF;
				              	   IF v_mes = 'dic' THEN UPDATE sc_rep_transacciones SET dic = v_total WHERE clave = v_num_tran; END IF;  
								   
					    LET v_total = 0;			   
					  END IF; 				
	   END FOREACH;
			
	    
	   LET v_mes_2  = MONTH(v_prim_dia);	
	   
	   -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	   IF v_mes_2 = 1 THEN  
	   BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT ene FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT ene FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET ene = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET ene = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET ene = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;
       COMMIT WORK;		  
       END IF;
	   
	   -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	   IF v_mes_2 = 2 THEN  
	   BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT feb FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT feb FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET feb = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET feb = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET feb = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas; 
		COMMIT WORK;
        END IF;		  
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	    IF v_mes_2 = 3 THEN  
		BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT mar FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT mar FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																						'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET mar = suma_sub_1  WHERE descripcion ='1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET mar = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET mar = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	    IF v_mes_2 = 4 THEN  
		BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT abr FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT abr FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET abr = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET abr = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET abr = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	    IF v_mes_2 = 5 THEN  
		BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT may FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT may FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET may = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET may = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET may = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	   -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	   IF v_mes_2 = 6 THEN  
	   BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT jun FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT jun FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET jun = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET jun = suma_sub_2  WHERE descripcion =  '2_Subtotal'; 
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET jun = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;
        COMMIT WORK;		  
		END IF;
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	    IF v_mes_2 = 7 THEN  
		BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT jul FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT jul FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET jul = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET jul = suma_sub_2  WHERE descripcion =  '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET jul = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	     -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	     IF v_mes_2 = 8 THEN  
		 BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT ago FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT ago FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET ago = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET ago = suma_sub_2  WHERE descripcion =  '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET ago = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	     -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	     IF v_mes_2 = 9 THEN  
		 BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT sep FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT sep FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET sep = suma_sub_1  WHERE descripcion = '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET sep = suma_sub_2  WHERE descripcion =  '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET sep = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	   
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	    IF v_mes_2 = 10 THEN  
		BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT oct FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT oct FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET oct = suma_sub_1  WHERE descripcion =  '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET oct = suma_sub_2  WHERE descripcion =  '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET oct = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	    -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	   IF v_mes_2 = 11 THEN  
	   BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT nov FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT nov FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET nov = suma_sub_1  WHERE descripcion =  '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET nov = suma_sub_2  WHERE descripcion = '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET nov = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas;  
		COMMIT WORK;
		END IF;
	   
	   
	   -- SE DEFINE PROCESO A REALIZAR EN CASO DE QUE EL MES CUADRE
	   IF v_mes_2 = 12 THEN  
	   BEGIN WORK;
	      INSERT INTO sc_sumas(c1)   SELECT dic FROM sc_rep_transacciones WHERE clave  IN('0282','6282');
          INSERT INTO sc_sumas(c2)   SELECT dic FROM sc_rep_transacciones WHERE clave  IN('0401','0402','0403','0404','0405',
																					'0406','1196','1197','8105','8112');
		  SELECT SUM(c1) INTO suma_sub_1 FROM sc_sumas; 
		  SELECT SUM(c2) INTO suma_sub_2 FROM sc_sumas; 
		  UPDATE sc_rep_transacciones SET dic = suma_sub_1  WHERE descripcion =  '1_Subtotal'; 
		  UPDATE sc_rep_transacciones SET dic = suma_sub_2  WHERE descripcion =  '2_Subtotal';
		  LET total = suma_sub_1 + suma_sub_2;
		  UPDATE sc_rep_transacciones SET dic = total  WHERE descripcion = 'Total';
		  LET suma_sub_1 = 0;
		  LET suma_sub_2 = 0;
		  LET total = 0;		  
          TRUNCATE TABLE sc_sumas; 
	    COMMIT WORK;
		END IF;
		
		-- SE OBTIENE LA FECHA PARA ASIGNARSELA AL NOMBRE DEL ARCHIVO	
		   LET anio_fin = YEAR(v_prim_dia);
		   LET mes_fin  = MONTH(v_prim_dia);
		   IF  LEN (mes_fin) = 1 THEN 
		       LET  mes_fin  = 0 || mes_fin; 
	       END IF;
		
		 LET f_fin = mes_fin || anio_fin ;
		 ------------------------------------------------

		 LET vsql = '';
		 LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
					'UNLOAD TO /resplogifx/conciliachq/579_reporte_transa_pro_'||f_fin||'.txt '||
					'SELECT * FROM sc_rep_transacciones" > /resplogifx/conciliachq/reporte_transacciones.sql';
		 SYSTEM vsql; 

		 --/EJECUCION DEL ARCHIVO .SQL 
		 LET vsql = '';
		 LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/reporte_transacciones.sql";
		 SYSTEM vsql;

  
RETURN vcodret; 
END; 
END PROCEDURE;