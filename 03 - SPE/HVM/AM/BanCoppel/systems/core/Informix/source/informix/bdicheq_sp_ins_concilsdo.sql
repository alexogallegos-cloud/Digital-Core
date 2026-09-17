CREATE PROCEDURE "informix".sp_ins_concilsdo(pempresa   CHAR(3), pfecha DATE)
RETURNING CHAR(5);

	DEFINE iSqlErr       INTEGER;
	DEFINE vCodRet       CHAR(5);
    DEFINE v_dias_resp   INTEGER;
    DEFINE vfecha_depura DATE;
	DEFINE vcontador     INTEGER;
	DEFINE vrowid         INTEGER;
	DEFINE vNum_producto	VARCHAR(4);
	DEFINE iConta_productos	INTEGER;
	DEFINE iNum_renglon		INTEGER;
	DEFINE vcomienza1    	SMALLINT;
	DEFINE ven_transacc1 	SMALLINT;
	DEFINE vconta        	INTEGER;
	DEFINE dFecha DATE;
	DEFINE vProducto VARCHAR(4);
	DEFINE vCuenta VARCHAR(20);
	DEFINE dCapital_Anterior DECIMAL(18,2);
	DEFINE dMovs_Cargo DECIMAL(18,2);
	DEFINE dMovs_Abono DECIMAL(18,2);
	DEFINE dCapital_Calculado DECIMAL(18,2);
	DEFINE dCapital_Actual DECIMAL(18,2);
	DEFINE dDiferencia_Capital DECIMAL(18,2);
	DEFINE dInteres_Anterior DECIMAL(18,2);
	DEFINE dMovs_Cargo_Interes DECIMAL(18,2);
	DEFINE dMovs_Abono_Interes DECIMAL(18,2);
	DEFINE dInteres_Calculado DECIMAL(18,2);
	DEFINE dInteres_Actual DECIMAL(18,2);
	DEFINE dDiferencia_Interes DECIMAL(18,2);
	
	
	--Manejo del error
	ON EXCEPTION SET iSqlErr
		   IF iSqlErr <> 0 THEN
	          LET vCodret = iSqlErr;
			  SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ins_concilsdo.err";
              TRACE ON;
		      RETURN vCodRet;
		   END IF;
	END EXCEPTION;
	
	LET iSqlErr = 0;
	LET v_dias_resp = 0;
	LET vcontador = 1;
	LET vrowid = 0;
	LET vcodret = "000";
	LET dFecha = '';
	LET vProducto = '';
	LET vCuenta = '';
	LET dCapital_Anterior = 0.0;
	LET dMovs_Cargo = 0.0;
	LET dMovs_Abono = 0.0;
	LET dCapital_Calculado = 0.0;
	LET dCapital_Actual = 0.0;
	LET dDiferencia_Capital = 0.0;
	LET dInteres_Anterior = 0.0;
	LET dMovs_Cargo_Interes = 0.0;
	LET dMovs_Abono_Interes = 0.0;
	LET dInteres_Calculado = 0.0;
	LET dInteres_Actual = 0.0;
	LET dDiferencia_Interes = 0.0;
	LET vNum_producto	  ='';
	LET iConta_productos  = 0;
	LET iNum_renglon	  = 0;
	LET vcomienza1 	  	  = -1;
	LET ven_transacc1     = 0;
	LET vconta            = 0;

   
      SET ISOLATION TO DIRTY READ;
      SET LOCK MODE TO WAIT 3;
	  
   --SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_ins_concilsdo.out";
   --TRACE ON;

	SELECT COUNT (DISTINCT fecha) INTO v_dias_resp FROM bdicheq:sc_concilsdo_difacum;

	--LET v_dias_resp = 7; --para pruebas.
    IF v_dias_resp >= 7 THEN

		
		LET vfecha_depura = pfecha - 7 UNITS DAY;
		--DELETE FROM bdicheq:sc_concilsdo_difacum WHERE producto <> '' AND fecha <= vfecha_depura;
		DELETE FROM bdicheq:sc_concilsdo_difacum WHERE  fecha <= vfecha_depura AND producto <> '' ;

        FOREACH WITH HOLD
		 SELECT rowid INTO vrowid
           FROM bdicheq:sc_concilsdo_difdet
          WHERE fecha <= vfecha_depura
            
            IF vcontador = 1 THEN
				BEGIN WORK;
            END IF;

			DELETE FROM bdicheq:sc_concilsdo_difdet WHERE rowid = vrowid;

            IF vcontador >= 3500 THEN
				COMMIT WORK;
                LET vcontador = 1;
            ELSE
				LET vcontador = vcontador + 1 ;
            END IF;

            CONTINUE FOREACH;
        END FOREACH;

            IF vcontador > 1 THEN
                COMMIT WORK;
                LET vcontador = 1;
            END IF;

    END IF;

	/*IF NOT EXISTS (SELECT DISTINCT fecha FROM bdicheq:sc_concilsdo_difacum WHERE producto <> '' AND fecha = pfecha ) THEN*/
	/*             
		INSERT INTO bdicheq:sc_concilsdo_difacum
		SELECT  fecha
		       ,producto 
		       ,sum(capital_anterior)     
		       ,sum(movs_cargo)     
		       ,sum(movs_abono)     
		       ,sum(capital_calculado)
		       ,sum(capital_actual)     
		       ,sum(diferencia_capital)     
		       ,sum(interes_anterior)     
		       ,sum(movs_cargo_interes)     
		       ,sum(movs_abono_interes) 
		       ,sum(interes_calculado)
		       ,sum(interes_actual)
		       ,sum(diferencia_interes)
	       FROM bdicheq:conciliachq
	   GROUP BY 1,2;

		INSERT INTO bdicheq:sc_concilsdo_difdet
		SELECT  fecha
		       ,producto
		       ,cuenta
		       ,capital_anterior    
		       ,movs_cargo     
		       ,movs_abono     
		       ,capital_calculado
		       ,capital_actual     
		       ,diferencia_capital     
		       ,interes_anterior     
		       ,movs_cargo_interes     
		       ,movs_abono_interes 
		       ,interes_calculado
		       ,interes_actual
		       ,diferencia_interes
		   FROM bdicheq:conciliachq
	      WHERE diferencia_capital <> 0 OR diferencia_interes <> 0;

    END IF*/
	
	IF NOT EXISTS (SELECT DISTINCT fecha FROM bdicheq:sc_concilsdo_difacum WHERE fecha = pfecha AND producto <> '') THEN
				
			
			--ELIMINAMOS LA TABLA TEMPORAL DE PRODUCTOS
			DROP TABLE IF EXISTS tmp_producto_concilia;

			--TABLA TEMPORAL PARA OBTENER TODOS LOS PRODUCTOS DE LA 'bdicheq:conciliachq'
			   SELECT producto FROM bdicheq:conciliachq
			   group by producto
			   INTO TEMP tmp_producto_concilia WITH NO LOG;

			LET iConta_productos = 0;
			LET iNum_renglon = 0;
		   
		   --Contamos el nÃºmero de productos
			SELECT COUNT(*) 
			INTO iConta_productos
			FROM tmp_producto_concilia;

			--Ciclo_1 para trabajar el 'Select' producto x producto, bajando el costeo.
			WHILE ( iNum_renglon <=iConta_productos - 1) LOOP
				
				
				--SELECCIONA UN NÃMERO DE PRODUCTO A LA VEZ
				SELECT SKIP iNum_renglon FIRST 1 producto
				INTO vNum_producto
				FROM tmp_producto_concilia;
				
				--Se reduce costeo de bÃºsqueda en un 98%
				INSERT INTO bdicheq:sc_concilsdo_difacum
				SELECT  fecha
					   ,producto 
					   ,sum(capital_anterior)     
					   ,sum(movs_cargo)     
					   ,sum(movs_abono)     
					   ,sum(capital_calculado)
					   ,sum(capital_actual)     
					   ,sum(diferencia_capital)     
					   ,sum(interes_anterior)     
					   ,sum(movs_cargo_interes)     
					   ,sum(movs_abono_interes) 
					   ,sum(interes_calculado)
					   ,sum(interes_actual)
					   ,sum(diferencia_interes)
				   FROM bdicheq:conciliachq
				   WHERE producto = vNum_producto
				   GROUP BY 1,2;
			

				  --Buscamos el sig producto de la tabla de productos.
				  LET iNum_renglon = iNum_renglon + 1;

			END LOOP;
-------------------------//////////////////////////---------------------------------------------			
			--Se hace Foreach para Insert
			--Se agrega Directiva porque presenta Sequential Scan pero se aumenta costeo, validar con BD si esto se aprueba.
				/*INSERT INTO bdicheq:sc_concilsdo_difdet
				SELECT {+INDEX(conciliachq idx_conciliachq_prod )}
				fecha
		       ,producto
		       ,cuenta
		       ,capital_anterior    
		       ,movs_cargo     
		       ,movs_abono     
		       ,capital_calculado
		       ,capital_actual     
		       ,diferencia_capital     
		       ,interes_anterior     
		       ,movs_cargo_interes     
		       ,movs_abono_interes 
		       ,interes_calculado
		       ,interes_actual
		       ,diferencia_interes
				FROM bdicheq:conciliachq
				WHERE diferencia_capital <> 0.00 OR diferencia_interes <> 0.00;*/
				
					--Cursor Foreach para obtener el cliente y clasificar si es crÃ©dito o dÃ©bito
			FOREACH cursor_1 WITH HOLD FOR

				SELECT {+INDEX(conciliachq idx_conciliachq_prod )}
					fecha,producto,cuenta,capital_anterior,movs_cargo,movs_abono,
					capital_calculado,capital_actual,diferencia_capital,interes_anterior,
					movs_cargo_interes,movs_abono_interes,interes_calculado,interes_actual,diferencia_interes
				   INTO dFecha,vProducto,vCuenta,dCapital_Anterior,dMovs_Cargo,dMovs_Abono,
						dCapital_Calculado,dCapital_Actual,dDiferencia_Capital,dInteres_Anterior,
						dMovs_Cargo_Interes,dMovs_Abono_Interes,dInteres_Calculado,dInteres_Actual,dDiferencia_Interes
					FROM bdicheq:conciliachq
					WHERE diferencia_capital <> 0.00 OR diferencia_interes <> 0.00
			
					-- Abre la transaccion para commits
					   IF (vcomienza1 = -1) THEN
						  LET vcomienza1 = 0;
						  LET ven_transacc1 = 1;
						  BEGIN WORK;
					   END IF;
						   

				INSERT INTO bdicheq:sc_concilsdo_difdet(fecha,producto,cuenta,capital_anterior,movs_cargo,movs_abono,
														capital_calculado,capital_actual,diferencia_capital,interes_anterior     
														,movs_cargo_interes,movs_abono_interes,interes_calculado,interes_actual,diferencia_interes)
				VALUES(dFecha,vProducto,vCuenta,dCapital_Anterior,dMovs_Cargo,dMovs_Abono,
					   dCapital_Calculado,dCapital_Actual,dDiferencia_Capital,dInteres_Anterior,
					   dMovs_Cargo_Interes,dMovs_Abono_Interes,dInteres_Calculado,dInteres_Actual,dDiferencia_Interes);

				LET vconta = vconta + 1;
				--Commit cada 10000 registros
				IF (vconta >= 10000) THEN
				  LET vconta = 0;
				  COMMIT WORK;
				  BEGIN WORK;
				END IF;
	
			END FOREACH; --Fin de cursor_1

				IF (ven_transacc1 = 1) THEN
				  LET ven_transacc1 = 0;
				  COMMIT WORK;
				END IF;
		
	END IF;
	
	
		DROP TABLE IF EXISTS tmp_producto_concilia;

	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_concilsdo_difacum;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_concilsdo_difdet;

	RETURN vcodret;

END PROCEDURE;