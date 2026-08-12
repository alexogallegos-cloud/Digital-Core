CREATE PROCEDURE "informix".sp_sorteo_hilos() 
							RETURNING char(5);


DEFINE  vsqlerr 						INTEGER;
DEFINE 	vcodret 						CHAR(5);
DEFINE  v_cantidad_universo				CHAR(10);
DEFINE  cantidad_registros				INT8;
DEFINE  v_valor_inicial					CHAR(20);
DEFINE  v_valor_final                   INT8;
DEFINE  i              					INTEGER;
DEFINE v_fecha_ejecucion				DATE;
DEFINE  v_cantidad_universo_min			CHAR(10) ;
DEFINE v_cantidad						INT8 ;
DEFINE cliente_fin						CHAR(20);
DEFINE pprocesos     SMALLINT;
DEFINE pcontador     SMALLINT;
DEFINE v_valor_inicial_con					INT8;
   
   ------
	--DEFINE  cantidad_registros				INT8  ;
	DEFINE  v_valor_inicial_in					CHAR(10) ;
	DEFINE  v_valor_final_in                   	CHAR(10)  ;
   ---
   

LET vsqlerr								= 0;
LET vcodret								= '00000';
LET v_cantidad_universo					= '0';
LET v_cantidad_universo_min					= 0;
LET i                  					= 1;
LET v_fecha_ejecucion					= NULL;
LET cliente_fin							= NULL;
LET pprocesos 							= 4;
LET pcontador							= 0;
LET v_valor_inicial_in					= '';
LET v_valor_final_in                   	= '';
LET v_valor_inicial_con					= 0;

	BEGIN
	  ON EXCEPTION SET vsqlerr
		--COMMIT WORK;
	  IF vsqlerr <>0 THEN
		LET vcodret = vsqlerr;
		RETURN vcodret;
	  END IF;
	END EXCEPTION;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	TRUNCATE TABLE "informix".si_sorteo_hilos;
	
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_maechq)} min(num_cte)
			INTO v_cantidad_universo_min
		FROM bdicheq:"informix".sc_maechq
		WHERE --cuenta is not null 		and	
		producto in('2000','2900','1100')
		AND status_cta in('1','3');		
		
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_maechq)} max(num_cte)
			INTO v_cantidad_universo
		FROM bdicheq:"informix".sc_maechq
		WHERE --cuenta is not null		and	
		producto in('2000','2900','1100')
		AND status_cta in('1','3'); --and fecha_proceso is not null;
		
				
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_maechq)} count(*)
			INTO v_cantidad
		FROM bdicheq:"informix".sc_maechq
		WHERE --cuenta is not null 		and	
		producto in('2000','2900','1100')
		AND status_cta in('1','3');		
		LET v_valor_inicial = 0;
		
	
		
		--CREAR VARIABLE
		LET cantidad_registros = ROUND(v_cantidad / 5);
		LET v_valor_final = '';
		LET v_valor_inicial = v_cantidad_universo_min ;
		
			
			FOR pcontador = 1 TO  pprocesos
				
					FOREACH
						SELECT  SKIP cantidad_registros FIRST 1 num_cte
							INTO cliente_fin
						FROM bdicheq:"informix".sc_maechq
						WHERE --cuenta is not null AND 
						producto in('2000','2900','1100')
							AND status_cta in('1','3') --AND fecha_proceso is not null
							and num_cte >= v_valor_inicial
							ORDER BY num_cte
					
					end FOREACH;
				
				IF pcontador = 1 THEN
						LET v_valor_inicial_con = v_cantidad_universo_min;
					    LET v_valor_final = cliente_fin ;
                       
                 ELSE
                       -- IF pcontador = pprocesos THEN
                           -- LET v_valor_inicial_con = v_valor_final + 1;
							--LET v_valor_final = v_cantidad_universo;
							
                       -- ELSE    
								LET v_valor_inicial_con	= v_valor_final + 1;
								--LET v_valor_inicial = v_valor_final + 1;
								LET v_valor_final = cliente_fin ;
						
                    
                       -- END IF;

             
                 END IF;
				
						--LET v_valor_inicial_in = v_valor_inicial;
						--LET v_valor_final_in	= v_valor_final;
						LET v_valor_inicial_in = LPAD(v_valor_inicial_con,'9','0');
						LET v_valor_final_in = LPAD(v_valor_final,'9','0');
			--CREAR TABLA
				INSERT INTO "informix".si_sorteo_hilos(numero_proceso, cliente_inicial, cliente_final, cte_cuenta, cte_exclucion, cte_info_cte, mes_ejecucion, cheques, pagare)	
				VALUES (i, v_valor_inicial_in, v_valor_final_in,'0', '0','0','0', '0','0');
				
				LET v_valor_inicial_con = v_valor_final + 1;
				LET v_valor_inicial = LPAD(v_valor_inicial_con,'9','0');
				LET i = i + 1;
			
		 END FOR;
	
				INSERT INTO "informix".si_sorteo_hilos(numero_proceso, cliente_inicial, cliente_final, cte_cuenta, cte_exclucion, cte_info_cte, mes_ejecucion, cheques, pagare)	
				VALUES (5, v_valor_inicial, v_cantidad_universo,'0', '0','0','0', '0','0');
		
		
	--COMMIT WORK;
	
RETURN vcodret;
END;
END PROCEDURE;