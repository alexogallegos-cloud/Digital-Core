CREATE PROCEDURE "informix".sp_numero_hilos_ics( pfecha date) 
							RETURNING char(7);


DEFINE  vsqlerr 						INTEGER;
DEFINE 	vcodret 						CHAR(7);
DEFINE  v_cantidad_universo				INT8  ;
DEFINE  cantidad_registros				INT8  ;
DEFINE  v_valor_inicial					INT8  ;
DEFINE  v_valor_final                   INT8  ;
DEFINE  i              					INTEGER;
DEFINE v_cantidad_minima_cdr			INT8  ;
DEFINE v_cantidad_maxima_cdr			INT8  ;
DEFINE v_cantidad_universo_crd			INT8  ;
DEFINE v_fecha_ejecucion					DATE;
DEFINE  v_cantidad_universo_min				INT8  ;
DEFINE v_cantidad						INT8  ;
DEFINE cred_fin							CHAR(20);
   DEFINE pprocesos     SMALLINT;
   DEFINE pcontador     SMALLINT;

LET vsqlerr								= 0;
LET vcodret								= '00000';
LET v_cantidad_universo					= 0;
LET v_cantidad_universo_min					= 0;
LET i                  					= 1;
LET v_fecha_ejecucion					= NULL;
LET cred_fin							= NULL;
LET pprocesos 							= 10;
LET pcontador							= 0;

	BEGIN
	  ON EXCEPTION SET vsqlerr
		COMMIT WORK;
	  IF vsqlerr <>0 THEN
		LET vcodret = vsqlerr;
		RETURN vcodret;
	  END IF;
	END EXCEPTION;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	TRUNCATE TABLE ics_numero_proceso;
	---ALTER TABLE ics_clientes_cred_crd MODIFY (ics_consecutivo serial (1));

	--BEGIN WORK;
	
		--SELECT fecha_hoy 
		--	INTO v_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		LET v_fecha_ejecucion = pfecha;
		
		SELECT min(num_credito)
			INTO v_cantidad_universo_min
		FROM ics_clientes WHERE tipo_cred='1';
		
		SELECT MAX(num_credito)
			INTO v_cantidad_universo 
		FROM ics_clientes WHERE tipo_cred='1';
		
		SELECT count(*)
			INTO v_cantidad 
		FROM ics_clientes WHERE tipo_cred='1';
		LET v_valor_inicial = 0;
		
		--LET v_cantidad = v_cantidad_universo - v_cantidad_universo_min;
		
		--CREAR VARIABLE
		LET cantidad_registros = ROUND(v_cantidad / pprocesos);
		LET v_valor_final = '000000000000';
		LET v_valor_inicial = v_cantidad_universo_min ;
		--Declarar i
		--WHILE i <= 10 
			
			FOR pcontador = 1 TO  pprocesos
				
				FOREACH
					SELECT SKIP cantidad_registros FIRST 1 nvl(num_credito,'')
								INTO cred_fin
					FROM bdicred:ics_clientes
					WHERE tipo_cred = '1' and num_credito >= v_valor_inicial
					ORDER BY num_credito
				end FOREACH;
				
				
				IF pcontador = 1 THEN
						LET v_valor_inicial = v_cantidad_universo_min;
					 --  LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
                        LET v_valor_final = cred_fin ;
                       -- LET pparametro = '951';
						--LET pparametro2 = '981';
                 ELSE
                        IF pcontador = pprocesos THEN
                            LET v_valor_inicial = v_valor_final + 1;
							LET v_valor_final = v_cantidad_universo;
							--LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
						
								LET v_valor_inicial = v_valor_final + 1;
								
					 --  LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
								LET v_valor_final = cred_fin ;
						
                            --LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            --LET cred_ini = cred_fin;
                        END IF;

                     --   LET pparametro = (pparametro::integer + 1)::varchar(3); 
						--LET pparametro2 = (pparametro2::integer + 1)::varchar(3);  
                 END IF;
				
				
				
				/*IF i = 10 THEN
					LET v_valor_final = cred_fin;
				ELSE
					LET v_valor_final = cred_fin;
				END IF;*/
				
				/*IF v_valor_inicial = 0 THEN
					LET v_valor_inicial = v_cantidad_universo_min;
				ELSE
					LET v_valor_inicial = v_valor_final + 1;
				END IF;
					
				IF i = 10 THEN
					LET v_valor_final = v_cantidad_maxima_cdr;
				ELSE
					LET v_valor_final = cred_fin;
				END IF;*/
				
			--CREAR TABLA
				INSERT INTO "informix".ics_numero_proceso(numero_hilo, valor_inicial, valor_final, tipo_cred, fecha_ejecucion)	
				VALUES (i, v_valor_inicial, v_valor_final,'1', v_fecha_ejecucion);
				
				--UPDATE ics_clientes_2 SET proceso = i where ics_consecutivo between v_valor_inicial and v_valor_final and tipo_cred='1';
				LET v_valor_inicial = v_valor_final + 1;
				
				LET i = i + 1;
			--END WHILE;
		 END FOR;
		
		--Totalk de registros para crd
		SELECT MIN(num_credito)
			INTO v_cantidad_minima_cdr 
		FROM ics_clientes WHERE tipo_cred='2';
		--CREAR VARIABLE
		--LET cantidad_registros = ROUND(v_cantidad_universo / 10);
		
		SELECT MAX(num_credito)
			INTO v_cantidad_maxima_cdr 
		FROM ics_clientes WHERE tipo_cred='2';
		--CREAR VARIABLE
		
		
		
		--LET cantidad_registros = 
		
		SELECT count(*)
			INTO v_cantidad 
		FROM ics_clientes WHERE tipo_cred='2';
		
		LET v_cantidad_universo_crd = ROUND(v_cantidad / 10); --(v_cantidad_maxima_cdr - v_cantidad_minima_cdr);
		--LET cantidad_registros = ROUND(v_cantidad_universo_crd / 10);
		LET i = 1;
		LET v_valor_final = 0;
		LET v_valor_inicial = v_cantidad_minima_cdr;
		--Declarar i
		
		FOR pcontador = 1 TO  pprocesos
		--WHILE i <= 10 
			
			
			FOREACH
				SELECT SKIP v_cantidad_universo_crd FIRST 1 nvl(num_credito,'')
							INTO cred_fin
				FROM bdicred:ics_clientes
				WHERE tipo_cred = '2'
				AND num_credito >= v_valor_inicial
				ORDER BY num_credito
			end FOREACH;
			
			IF i = 1 THEN
				LET v_valor_inicial = v_cantidad_minima_cdr;
			ELSE
				LET v_valor_inicial = v_valor_final + 1;
			END IF;
				
			IF i = 10 THEN
				LET v_valor_final = v_cantidad_maxima_cdr;
			ELSE
				LET v_valor_final = cred_fin;
			END IF;
			
			
			
		--CREAR TABLA
			INSERT INTO "informix".ics_numero_proceso(numero_hilo, valor_inicial, valor_final, tipo_cred, fecha_ejecucion)	
			VALUES (i, v_valor_inicial, v_valor_final,'2', v_fecha_ejecucion);
			
			--UPDATE ics_clientes_2 SET proceso = i where ics_consecutivo between v_valor_inicial and v_valor_final and tipo_cred='2';
			
			LET v_valor_inicial = v_valor_final + 1;
			
			LET i = i + 1;
		--END WHILE;
		END FOR;
		
		
		
	--COMMIT WORK;
	
RETURN vcodret;
END;
END PROCEDURE;