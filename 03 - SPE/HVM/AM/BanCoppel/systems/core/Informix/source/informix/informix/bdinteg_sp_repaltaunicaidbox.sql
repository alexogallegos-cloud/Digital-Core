CREATE PROCEDURE "informix".sp_repaltaunicaidbox() 
	Returning char(7);

	/*DEFINICION DE VARIABLES*/
	--Variables de retorno
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	
	--Variable para ejecucion de comandos
	DEFINE vsql	        		char(3000);
	
	--Variables de elementos requeridos
	DEFINE v_sucursal						CHAR(5);	--Plastico correspondiente a la cuenta afectada
	DEFINE v_ejecutivo						CHAR(8);	--Fecha de cargo que se reclama
	DEFINE v_numcte							CHAR(9);	--Variable correspondente al numero del cliente
	DEFINE v_codidentifi					CHAR(2);	--Variable correspondente al codigo para la identificacion del documento utilizado
	DEFINE iContador   						INTEGER;
	DEFINE v_nombre_sucursal				CHAR(40);	--Variable correspondente al nombre de la sucursal
	DEFINE v_nombre_ejecut					CHAR(45);	--Variable correspondente al nombre del ejecutivo						
	DEFINE v_nombramiento					CHAR(20);	--Variable correspondente al cargo del ejecutivo
	DEFINE v_total_clientes					INTEGER;	--Variable correspondente al total de clientes atendidos por el ejecutivo
	DEFINE v_nom_sucursal		    		CHAR(40);   --sacar el nombre de la sucursal de la tabla temporal
	DEFINE v_nom_ejecut						CHAR(45); 	--nombre de la ejecutivo de la tabla temporal
	DEFINE v_total_altas					INTEGER;  	--guarda el total de altas 
	DEFINE v_altasxidbox					INTEGER;	--Variable correspondente al total de altas con  uso del idbox
	DEFINE v_altasxine						INTEGER;	--Variable correspondente al total de altas con uso de idbox e ine/ife
	DEFINE v_altassnine						INTEGER;	--Variable correspondente al total de sin ine/ife
	DEFINE v_porc_ine_vs_idbox				NUMERIC;	--Variable correspondente al porcentaje del total de uso de idbox y total de ine/ife 
	DEFINE v_porc_doc_vs_idbox				NUMERIC;	--Variable correspondente al porcentaje del total de uso de idbox y altas con otros documentos
	DEFINE v_altassidbox					INTEGER;	--Variable correspondente al total de altas sin el uso del idbox
	DEFINE v_porc_idbox_vs_taltas			NUMERIC;	--Variable correspondente al porcentaje del total de uso de idbox vs total de altas
	DEFINE v_porc_snidbox_vs_taltas			NUMERIC;	--Variable correspondente al porcentaje del  total de altas vs total altas sin el uso del idbox
	DEFINE v_total_mmtos					NUMERIC;	--Variable correspondente al total de mantenimientos
	DEFINE v_total_mmtosidbox				NUMERIC;	--Variable correspondente al total de mantenimientos con idbox
	DEFINE v_total_mmtosine					NUMERIC;	--Variable correspondente al total de mantenimientos con idbox e ine/ife
	DEFINE v_total_mmtosdoc					NUMERIC;	--Variable correspondente al total de mantenimientos con otros documentos
	DEFINE v_porcmtto_ine_idbox				NUMERIC;	--Variable correspondente al porcentaje de mantenimientos con idbox e ine/ife
	DEFINE v_porcmtto_doc_idbox				NUMERIC;	--Variable correspondente al porcentaje de mantenimientos con otros documentos
	DEFINE v_porcmtto_idbox					NUMERIC; 	--Variable correspondente al porcentaje de mantenimientos con idbox e ine/ife
	DEFINE v_porcmtto_snidbox				NUMERIC;	--Variable correspondente al porcentaje de mantenimientos con idbox
	DEFINE v_total_mmtos_snidbox	 		NUMERIC;	--Variable correspondente al porcentaje de mantenimientos sin el uso del idbox 
	DEFINE v_fecha_inicio					DATE;		--Variable para la obtencion de la fecha actual
	DEFINE v_fecha_fin						DATE;
	DEFINE v_fecha_inicio_mes				DATE;		
	DEFINE v_fecha_fin_mes					DATE;
	DEFINE v_ejecutivo_mmto					CHAR(8);
	--DEFINE vsql 							CHAR(3000);
	DEFINE v_tiempo							DATETIME YEAR TO FRACTION;
	DEFINE v_sucursal_cliente				CHAR(5);
	DEFINE v_fecha_alta						DATE;
	DEFINE v_fecha_insert					DATE;
	DEFINE v_fecha_insert_2					DATE;
	DEFINE v_bita_fecha						DATETIME YEAR TO FRACTION;
	DEFINE v_tipo_consulta					CHAR(2);
	DEFINE v_ejecutivo_idbox				CHAR(8);
	DEFINE v_contador				 		NUMERIC;
	DEFINE v_numreg					 		NUMERIC;
	DEFINE v_limitecontador				 	NUMERIC;
	DEFINE v_limitefecha					NUMERIC;
	
	---Inicializacion de variables
	let vcodret = "00000";
	let vsqlerr = 0;
	let v_sucursal = '';	--Intento
	let v_ejecutivo = '';		--Finalizada
	let v_numcte = '';
	let v_codidentifi = 0;
	let iContador = 0;
	let v_nombre_sucursal = '';
	let v_nombre_ejecut	= '';
	let v_nombramiento	= '';
	let v_total_clientes = 0;
	let v_nom_sucursal = '';
	let v_nom_ejecut = '';
	let v_total_altas = 0;
	let v_altasxidbox = 0;
	let v_altasxine = 0;
	let v_altassnine = 0;
	let v_porc_ine_vs_idbox = 0.00;
	let v_porc_doc_vs_idbox = 0.00;
	let	v_altassidbox = 0;
	let v_porc_idbox_vs_taltas = 0;
	let v_porc_snidbox_vs_taltas = 0;
	let v_total_mmtos = 0;
	let v_total_mmtosidbox = 0;
	let v_total_mmtosine =0;
	let v_total_mmtosdoc = 0;
	let v_porcmtto_ine_idbox = 0.00;
	let v_porcmtto_doc_idbox = 0.00;
	let v_porcmtto_idbox = 0.00;
	let v_porcmtto_snidbox = 0.00;
	let v_total_mmtos_snidbox = 0.00;
	let v_fecha_inicio = '';
	let v_fecha_fin = '';
	let v_fecha_inicio_mes = '';
	let v_fecha_fin_mes = '';
	let v_ejecutivo_mmto = '';
	Let vsql='';
	LET v_sucursal_cliente = '';
	LET v_contador=0;
	LET v_numreg=0;
	LET v_limitecontador=1000;
	LET v_limitefecha=45;

	--SET DEBUG FILE TO "/ifxsif01/uai/scripts/sp_repaltaunicaidbox.out";
	--TRACE ON;
	LET v_tiempo = CURRENT;
	begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				COMMIT WORK;
				return vcodret;
			end if;
		end exception;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
		DROP table IF EXISTS cliente_tmp1;
		DROP table IF EXISTS cliente_tmp2;
		
		let v_fecha_inicio = today-1;

		SELECT  {+AVOID_FULL (bdinteg:si_fechas)}
		((last_day(add_months((v_fecha_inicio),-1)))+1) as fecha_inicio, 
		((last_day(add_months((v_fecha_inicio),0)))+0) as fecha_fien		
		INTO  v_fecha_inicio_mes, v_fecha_fin_mes
		FROM bdinteg:"informix".si_fechas;
		
        BEGIN WORK;		    
			FOREACH WITH HOLD
				
				SELECT DISTINCT ejecutivo
				INTO v_ejecutivo  
				from  "informix".si_tmp1_rpt_idbox where fecha_proceso = v_fecha_inicio
				
				SELECT COUNT(1)
				INTO v_numreg
				from "informix".si_tmp1_rpt_idbox WHERE ejecutivo = v_ejecutivo and fecha_proceso = v_fecha_inicio;
				
				DELETE FROM "informix".si_tmp1_rpt_idbox WHERE ejecutivo = v_ejecutivo and fecha_proceso = v_fecha_inicio;

				LET v_contador = v_contador + v_numreg;
				
				IF v_contador >= v_limitecontador THEN
					COMMIT WORK;
					LET v_contador = 0;
					BEGIN WORK;
				END IF;
			END FOREACH; 
		COMMIT WORK;

		LET v_contador = 0;
		LET v_numreg = 0;
		
		if(v_fecha_inicio = v_fecha_inicio_mes) then
			BEGIN WORK;		    
				FOREACH WITH HOLD
					
					SELECT DISTINCT ejecutivo
					INTO v_ejecutivo  
					from  "informix".si_tmp1_rpt_idbox where fecha_proceso < v_fecha_inicio_mes -v_limitefecha
				
					SELECT COUNT(1)
					INTO v_numreg
					from "informix".si_tmp1_rpt_idbox WHERE ejecutivo = v_ejecutivo and fecha_proceso < v_fecha_inicio_mes -v_limitefecha;
				
					DELETE FROM "informix".si_tmp1_rpt_idbox WHERE ejecutivo = v_ejecutivo and fecha_proceso < v_fecha_inicio_mes -v_limitefecha;

					LET v_contador = v_contador + v_numreg;
					
					IF v_contador = v_limitecontador THEN
						COMMIT WORK;
						LET v_contador = 0;
						BEGIN WORK;
					END IF;
				END FOREACH; 
			COMMIT WORK;
		end if;
		
		LET v_ejecutivo='';
		---------::::::::::::::::::::::::::Reporte del uso del IDBox en el periodo de un mes::::::::::::::::::::-------
		Select {+AVOID_FULL (bdinteg:"informix".si_cte_huella)} *
        from bdinteg:"informix".si_cte_huella  
		where secuencia=1 AND fecha_alta = v_fecha_inicio
		into temp cliente_tmp1 with no log;
		--crear index y el update stadistinc
		
		CREATE INDEX "informix".idx_cliente_tmp1
		ON "informix".cliente_tmp1(numcte) in datos02_idx ONLINE;
		
		update statistics medium for table "informix".cliente_tmp1;
		
		BEGIN WORK;

			FOREACH WITH HOLD
			----Consulta que nos trae el la sucursal, ejecutivo, numero del cliente, el codigo para ver si es con ine/ife, y si se hizo con idbox
		
				SELECT {+AVOID_FULL (bdinteg:si_cliente)} b.sucursal, a.numcte, a.ejecutivo, a.fecha_alta, b.fecha_alta
				INTO v_sucursal_cliente,v_numcte,v_ejecutivo,v_fecha_alta, v_fecha_insert
				FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".cliente_tmp1 b
				WHERE a.numcte=b.numcte 
				AND a.tipo_cliente='1' 
										
				IF v_numcte is not null then
					SELECT  {+AVOID_FULL (bdinteg:si_ctepf)} codidentifi
					INTO  v_codidentifi
					FROM si_ctepf WHERE numcte = v_numcte;					
				end if;
				--FOREACH
				SELECT limit 1  flag_idbox, fecha, sucursal, ejecutivo
				INTO v_altasxidbox, v_bita_fecha, v_sucursal, v_ejecutivo_idbox
				FROM "informix".si_bitacora_ife WHERE numcte = v_numcte and date(fecha) = v_fecha_insert;						
						
				IF v_ejecutivo_idbox IS NULL OR v_ejecutivo_idbox = '' THEN
					LET v_ejecutivo = v_ejecutivo;
				ELSE
					LET v_ejecutivo = v_ejecutivo_idbox;
				END IF;
						
				IF v_altasxidbox is not null then
					LET v_altasxidbox = 1;
				ELSE
					LET v_altasxidbox = NULL;
				END IF;
				
				IF v_sucursal IS NULL THEN
					SELECT {+AVOID_FULL (bdinteg:si_ejecut)} sucursal
					INTO v_sucursal 
					from "informix".si_ejecut where ejecutivo = v_ejecutivo;
					
					IF v_sucursal IS NULL THEN
						SELECT limit 1 sucursal
						INTO v_sucursal
						FROM bdinteg:si_usuario_movil 
						WHERE ejecutivo = v_ejecutivo;
					end if;
				END IF;
						
				LET v_tipo_consulta = 1; --Consulta para altas
				INSERT INTO "informix".si_tmp1_rpt_idbox (sucursal, ejecutivo, numcte, codidentifi, flag_idbox, fecha_alta, fecha_insert, fecha_bita, tipo_consulta, fecha_proceso)
				VALUES (v_sucursal, v_ejecutivo, v_numcte, v_codidentifi, v_altasxidbox, v_fecha_alta, v_fecha_insert, v_bita_fecha, v_tipo_consulta, v_fecha_inicio);
				--END FOREACH;
				LET iContador = iContador + 1;
	          
				IF iContador = v_limitecontador THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF;
			END FOREACH; 
		COMMIT WORK;
		
		select {+AVOID_FULL (bdinteg:si_cliente), AVOID_FULL (bdinteg:cliente_tmp2) } *
		FROM "informix".si_cliente si_cliente 
		where si_cliente.fecha_insert < si_cliente.fecha_alta 
		and si_cliente.fecha_alta = v_fecha_inicio
		and si_cliente.tipo_cliente='1'
		into temp cliente_tmp2 with no log;
				 
		CREATE INDEX "informix".idx_cliente_tmp2
		ON "informix".cliente_tmp2(fecha_alta) in datos02_idx ONLINE;
				
		CREATE INDEX "informix".idx_cliente_tmp3
		ON "informix".cliente_tmp2(tipo_cliente) in datos02_idx ONLINE;
				
		CREATE INDEX "informix".idx_cliente_tmp4
		ON "informix".cliente_tmp2(fecha_insert) in datos02_idx ONLINE;
				
		update statistics medium for table "informix".cliente_tmp2;
		
		BEGIN WORK;
          
			FOREACH WITH HOLD
			----Consulta que nos trae el la sucursal, ejecutivo, numero del cliente, el codigo para ver si es con ine/ife, y si se hizo con idbox
				select {+ AVOID_FULL(bdinteg:"informix".cliente_tmp2)} si_cliente.numcte, /*si_ctepf.codidentifi,*/ si_cliente.sucursal, si_cliente.fecha_alta, si_cliente.fecha_insert, si_cliente.ejecutivo
				into v_numcte /*,v_codidentifi*/, v_sucursal_cliente, v_fecha_alta, v_fecha_insert, v_ejecutivo
				FROM "informix".cliente_tmp2 si_cliente 
					
				SELECT  {+AVOID_FULL (bdinteg:si_ctepf)} codidentifi
				INTO  v_codidentifi
				FROM si_ctepf WHERE numcte = v_numcte;					
				--FOREACH
				SELECT limit 1  flag_idbox, fecha, sucursal, ejecutivo
				INTO v_altasxidbox, v_bita_fecha, v_sucursal, v_ejecutivo_idbox
				FROM "informix".si_bitacora_ife WHERE numcte = v_numcte and ejecutivo = v_ejecutivo;
						
				IF v_ejecutivo_idbox IS NULL OR v_ejecutivo_idbox = '' THEN
					LET v_ejecutivo = v_ejecutivo;
				ELSE
					LET v_ejecutivo = v_ejecutivo_idbox;
				END IF;
						
				IF date(v_bita_fecha) >= v_fecha_inicio THEN
					LET v_altasxidbox = 1;
				ELSE
					LET v_altasxidbox = NULL;
				END IF;
				 
				IF v_sucursal IS NULL THEN
					SELECT  sucursal
					INTO v_sucursal 
					from "informix".si_ejecut where ejecutivo = v_ejecutivo;
							
					IF v_sucursal IS NULL THEN
						SELECT limit 1 sucursal
						INTO v_sucursal
						FROM bdinteg:si_usuario_movil 
						WHERE ejecutivo = v_ejecutivo;
					end if;
				END IF;
				 	
				LET v_tipo_consulta = 2; --Consulta para mantenimientos
				INSERT INTO "informix".si_tmp1_rpt_idbox (sucursal, ejecutivo, numcte, codidentifi, flag_idbox, fecha_alta, fecha_insert, fecha_bita, tipo_consulta, fecha_proceso)
				VALUES (v_sucursal, v_ejecutivo, v_numcte, v_codidentifi, v_altasxidbox, v_fecha_alta, v_fecha_insert, v_bita_fecha, v_tipo_consulta, v_fecha_inicio);
				--END FOREACH;
				LET iContador = iContador + 1;

				IF iContador = v_limitecontador THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF;
			END FOREACH; 
		COMMIT WORK;
		
		let v_fecha_fin = v_fecha_fin_mes;
		
		if(v_fecha_inicio = v_fecha_fin) then
			
			TRUNCATE "informix".si_detalle_rpt_idbox;
			let v_fecha_inicio = v_fecha_inicio_mes;
			
			BEGIN WORK;
				FOREACH WITH HOLD
					--Selecciona el ejecutivo y sucursal de la tabla temporal
					SELECT {+AVOID_FULL (bdinteg:si_tmp1_rpt_idbox) } DISTINCT ejecutivo, sucursal 
					INTO v_ejecutivo, v_sucursal  
					from  "informix".si_tmp1_rpt_idbox where ejecutivo is not null and fecha_proceso >= v_fecha_inicio
					
					--selecciona nombre de la sucursal con el numero de sucursal de la tabla temporal
					SELECT {+AVOID_FULL (bdinteg:si_sucursales) } nombre INTO v_nom_sucursal 
					from "informix".si_sucursales 
					where sucursal = v_sucursal;
					
					--Selecciona el nombramiento del ejecutivo con el numero de empleado obtenido en la tabla temporal.
					SELECT {+AVOID_FULL (bdinteg:si_ejecut) } nombre, nombramiento INTO v_nom_ejecut, v_nombramiento 
					from "informix".si_ejecut where ejecutivo = v_ejecutivo;
					
					IF v_nom_ejecut IS NULL OR v_nom_ejecut = '' THEN
						SELECT limit 1 nombre, 'COBRANZA'
						INTO v_nom_ejecut, v_nombramiento
						FROM bdinteg:si_usuario_movil 
						WHERE ejecutivo = v_ejecutivo;
					END IF;
						
					--total de clientes que atendio el ejecutivo en el mes.
					SELECT {+ AVOID_FULL(bdinteg:si_cliente)} count (*) 
					INTO v_total_clientes 
					from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and sucursal = v_sucursal 
					and fecha_proceso >= v_fecha_inicio; 
			
					--Total de altas que realizo el ejecutivo en el mes.
					SELECT count (*) INTO v_total_altas 
					from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo  and sucursal = v_sucursal
					and tipo_consulta = '1'
					and fecha_proceso >= v_fecha_inicio;

					--Total de atlas por idbox que realizo el ejecutivo en el mes 
					SELECT count (*) INTO v_altasxidbox from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and flag_idbox = 1 and tipo_consulta = '1' and sucursal = v_sucursal
					and fecha_proceso >= v_fecha_inicio;
					
					--Total de altas con ine/ife que realizo el ejecutivo
					SELECT count (*) INTO v_altasxine from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and codidentifi = 'A' and tipo_consulta = '1'  and sucursal = v_sucursal
					and fecha_proceso >= v_fecha_inicio;
					
					--Toral de altas sin ine/ife que realizo el ejecutivo
					SELECT count (*) INTO v_altassnine from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and codidentifi <> 'A' and tipo_consulta = '1'  and sucursal = v_sucursal
					and fecha_proceso >= v_fecha_inicio;
					
					--Porcentaje de altas con ine/ife vs total de altas con idbox
					if v_altasxine = 0 or v_altasxidbox = 0 then 
						LET v_porc_ine_vs_idbox = 0;
					else 
						LET v_porc_ine_vs_idbox = ( v_altasxine / v_altasxidbox) * 100;
					end if;
					
					--Porcentaje de altas con otros documentos vs total de altas con idbox
					if v_altassnine = 0 or v_altasxidbox = 0 then 			
						LET v_porc_doc_vs_idbox = 0;		
					else 
						LET v_porc_doc_vs_idbox = (  v_altassnine/ v_altasxidbox) * 100;
					end if;
					
					--total de altas sin el uso del idbox
					SELECT count (*) INTO v_altassidbox from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and  flag_idbox is null and tipo_consulta = '1'  and sucursal = v_sucursal
					and fecha_proceso >= v_fecha_inicio;
					
					--Porcentaje de altas con idbox vs total de altas
					if v_altasxidbox = 0 or v_total_altas = 0 then
						LET v_porc_idbox_vs_taltas = 0;
					else
						LET v_porc_idbox_vs_taltas = (v_altasxidbox / v_total_altas ) * 100;
					end if;
					
					--Porcentaje de altas sin idbox vs total de altas
					if v_altassidbox = 0  or v_total_altas = 0 then
						LET v_porc_snidbox_vs_taltas = 0;
					else
						LET v_porc_snidbox_vs_taltas = (v_altassidbox / v_total_altas) * 100;
					end if;
					
					--Total de mantenimientos realizados por el ejecutivo en el mes
					SELECT count (*) 
					INTO v_total_mmtos 
					from "informix".si_tmp1_rpt_idbox 
					where ejecutivo = v_ejecutivo and sucursal = v_sucursal
					and tipo_consulta = '2' and fecha_proceso >= v_fecha_inicio;
		
					--Total de mantenimientos con idbox realizados por el ejecutivo en el mes
					select count(numcte) 
					into v_total_mmtosidbox
					from si_tmp1_rpt_idbox 
					where  tipo_consulta = '2' 
					and ejecutivo = v_ejecutivo and sucursal = v_sucursal
					and flag_idbox = 1 and fecha_proceso >= v_fecha_inicio;

					--Total de mantenimientos realizados con el ine/ife
					select count(numcte) into v_total_mmtosine
					from si_tmp1_rpt_idbox
					where  tipo_consulta = '2' 
					and ejecutivo = v_ejecutivo and sucursal = v_sucursal
					and codidentifi = 'A' and fecha_proceso >= v_fecha_inicio;

					--Total de mantenimientos realizados con otros documentos
					select count(numcte) into v_total_mmtosdoc
					from si_tmp1_rpt_idbox 
					where tipo_consulta = '2' 
					and ejecutivo = v_ejecutivo and sucursal = v_sucursal
					and codidentifi != 'A' and fecha_proceso >= v_fecha_inicio;

					--Porcentaje de total de mantenimientos vs total de mantenimientos realizados con idbox
					if v_total_mmtosine = 0 or v_total_mmtosidbox = 0 then
						LET v_porcmtto_ine_idbox =0;
					else
						LET v_porcmtto_ine_idbox = (v_total_mmtosine / v_total_mmtosidbox) * 100;
					end if;
					
					--Porcentaje de total de mantenimientos realizados con otros documentos vs total de mantenimientos realizados con idbox
					if v_total_mmtosdoc = 0 or v_total_mmtosidbox = 0 then
						LET v_porcmtto_doc_idbox = 0;
					else
						LET v_porcmtto_doc_idbox = (v_total_mmtosdoc / v_total_mmtosidbox) * 100;
					end if;
					
					--Total de mantenimientos realizados sin el idbox
					select count(numcte) 
					into v_total_mmtos_snidbox
					from si_tmp1_rpt_idbox 
					where tipo_consulta = '2' 
					and ejecutivo = v_ejecutivo and sucursal = v_sucursal
					and  flag_idbox is null and fecha_proceso >= v_fecha_inicio;
				
					--Porcentaje de total de mantenimientos vs total de mantenimientos con idbox
					if v_total_mmtos = 0 or v_total_mmtosidbox = 0 then
						LET v_porcmtto_idbox = 0;
					else
						LET v_porcmtto_idbox = ( v_total_mmtosidbox/v_total_mmtos ) * 100;
					end if;
					
					--Porcentaje de total de mantenimientos vs total de mantenimientos sin idbox
					if v_total_mmtos = 0 or v_total_mmtos_snidbox = 0 then
						LET v_porcmtto_snidbox = 0;
					else
						LET v_porcmtto_snidbox = ( v_total_mmtos_snidbox/v_total_mmtos ) * 100;
					end if;
	
					--Inserta los registros obtenidos en la tabla si_detalle_rpt_idbox
					INSERT INTO "informix".si_detalle_rpt_idbox(nombre_sucursal, sucursal, nombre_ejecut, ejecutivo, nombramiento, total_clientes , total_altas, altasxidbox, altascnine, altassnine, porc_ine_idbox, porc_doc_vs_idbox, altassidbox, porc_idbox_vs_taltas,  porc_snidbox_vs_taltas, total_mmtos, total_mmtosidbox, total_mmtosine, total_mmtosdoc, porcmtto_ine_idbox, porcmtto_doc_idbox, total_mmtos_snidbox, porcmtto_idbox, porcmtto_snidbox)
					VALUES (v_nom_sucursal, v_sucursal, v_nom_ejecut, v_ejecutivo, v_nombramiento, v_total_clientes, v_total_altas, v_altasxidbox, v_altasxine, v_altassnine, v_porc_ine_vs_idbox, v_porc_doc_vs_idbox, v_altassidbox, v_porc_idbox_vs_taltas, v_porc_snidbox_vs_taltas, v_total_mmtos, v_total_mmtosidbox, v_total_mmtosine, v_total_mmtosdoc, v_porcmtto_ine_idbox, v_porcmtto_doc_idbox, v_total_mmtos_snidbox, v_porcmtto_idbox, v_porcmtto_snidbox);
	
					LET iContador = iContador + 1;
					IF iContador = v_limitecontador THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF;
				END FOREACH;

				COMMIT WORK;	
				BEGIN WORK;
				--generacion de reporte 
				let vsql = ' echo "Nombre_sucursal|No_Sucursal|Nombre_ejecutivo|No.ejecutivo|Nombramiento|Total_de_clientes|Total_altas|Altas_con_IDBox|Altas_con INE/IFE|Altas_otro_doc|%Altas_INE/IFE_vs_Altas_IDBox|%Altas_otro_Doc_vs_Altas_IDBox|Altas_sn_IDBox|%Altas_IDBox_vs_Total_Altas|%Altas_sn_IDBox_vs_Total_Altas|Total_Mmtos|Mmtos_IDBox|Mmtos_INE/IFE|Mmtos_otro_Doc|%Mmtos_INE/IFE_vs_Mmtos_IDBox|%Mmtos_otro_Doc_vs_Mmtos_IDBox|Mmtos_sin_IDBox|%Mmtos_con_IDBox_vs_Total_Mmtos|%Mmtos_sin_IDBox_vs_Total_Mmtos">/RESPALDOSNEW/aclaraciones/RPT_IDBOX_'||LPAD (MONTH(v_fecha_fin),2,"0")||year(v_fecha_fin)||'.txt';
				system vsql;
				let vsql=  'echo "UNLOAD TO /RESPALDOSNEW/aclaraciones/TmpIDBox.txt '||
				'SELECT nombre_sucursal, sucursal, nombre_ejecut, ejecutivo, nombramiento, total_clientes, total_altas, altasxidbox, altascnine, altassnine, porc_ine_idbox, porc_doc_vs_idbox, altassidbox, porc_idbox_vs_taltas, porc_snidbox_vs_taltas, total_mmtos, total_mmtosidbox, total_mmtosine, total_mmtosdoc, porcmtto_ine_idbox, porcmtto_doc_idbox, total_mmtos_snidbox, porcmtto_idbox, porcmtto_snidbox'|| 
				' FROM informix.si_detalle_rpt_idbox;">/RESPALDOSNEW/aclaraciones/rpt_idbox.sql';
				system vsql;
				let vsql= 'dbaccess bdinteg /RESPALDOSNEW/aclaraciones/rpt_idbox.sql';
				system vsql;
				let vsql ='rm  /RESPALDOSNEW/aclaraciones/rpt_idbox.sql';
				system vsql;
				let vsql = "sed 's/|$//g' /RESPALDOSNEW/aclaraciones/TmpIDBox.txt >>/RESPALDOSNEW/aclaraciones/RPT_IDBOX_"||LPAD (MONTH(v_fecha_fin),2,"0")||year(v_fecha_fin)||".txt";
				system vsql;
				let vsql ='rm  /RESPALDOSNEW/aclaraciones/TmpIDBox.txt';
				system vsql; 
				let vcodret = '00000';					
			COMMIT WORK;		
		end if;
		return vcodret;	
	end;
end procedure
DOCUMENT
'Sp para generacion de Reporte Mensual IDBox',
'AUTOR : Rey David Zavala Garcia.',
'Area: Banca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona',
'FECHA : 21/Abril/2020',
'VERSION: 1.0.0',
'BD    :  bdinteg',
'Se realiza optimizaciones a las consultas asi como el ajuste para que se ejecute este sp todos los dias y los dias primero de cada mes genere el reporte correspondiente',
'AUTOR : Uriel Amador Islas - Zahide Tellez Ramirez.',
'Area: Banca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Jorge Alberto Garcia Lopez',
'FECHA : 02/Febrero/2022',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_desblcta_por_activ_subact(cEmpresa CHAR(3),pNumCliente CHAR(20))
RETURNING CHAR(5) AS codRet ;
/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_desblcta_por_activ_subact"
Folio.........: RQM 11 175 ActualizaciÃ³n del dato Actividad del cliente en Sucursal
Autor.........: 99804992 - Alejandro Rodriguez Martinez
Fecha.........: 14/06/2022
Solicita......: 
BD............: BDINTEG
*/

--Variables para el manejo de errores
DEFINE iSqlErr 	  					INTEGER;  
DEFINE iIsamErr   					INTEGER;

--Definicion de Variables de retorno
DEFINE codRet CHAR(5);

--Definicion de Variables de proceso
DEFINE countCuentas			INTEGER;
DEFINE vNumCte 				CHAR(20);
DEFINE ctesCount 		INTEGER;

--Asignacion
LET codRet = '00000';
LET iSqlErr = 0;

LET countCuentas       = 0;
LET vNumCte 		   = null;

BEGIN 	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			  LET codRet = iSqlErr;
		RETURN codRet;
		END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO '/home/sysifx/Bryan/255/sp_registracitatramite.out'; --- MODIFICAR RUTA DEL ARCHIVO
		--TRACE ON;
		
		--Validacion de datos de entrada no nulos o vacios
		IF NVL(cEmpresa,'') = '' OR NVL(pNumCliente,'')		= ''  THEN
			--En caso de que algun parametro validado se encuentre vacio retorna un codigo 00001
			LET codRet = '00001';
		ELSE
			--###########Empieza la logica del sp##################--
			------###########Desbloquea Captacion##################--
			--Buscamos si existen cuentas de captacion bloqueadas
			select a.num_cte into vNumCte  
				from bdicheq:sc_maechq a, bdicheq:sc_ctabloqueo b 
				where status_cta='3'
				and a.cuenta=b.cuenta  
				and  a.num_cte = pNumCliente 
				and b.cve_tipobloq= '14'
				and b.clave = '16' LIMIT 1;
				LET ctesCount = dbinfo("sqlca.sqlerrd2");
				if ctesCount > 0 then 
			------cambiamos los datos de la maechq para que no este bloqueada
					update bdicheq:sc_maechq a
					set a.status_cta = '1', a.motivo = '00'
					where a.status_cta = '3' and a.num_cte =pNumCliente 
					 and a.cuenta in ( select b.cuenta from bdicheq:sc_ctabloqueo b  where b.cuenta=a.cuenta and b.cve_tipobloq='14' and b.clave='16');
			------eliminamos los registros de la tabla sc_ctabloqueo
					delete from bdicheq:sc_ctabloqueo 
					where cve_tipobloq='14' and clave='16' and cuenta in (select cuenta from bdicheq:sc_maechq where num_cte =pNumCliente);
				end if;
				
			------###########Desbloquea Creditos##################--
			--Buscamos si existen creditos bloqueados
			select numcte into vNumCte from bdicred:sd_maecred
				WHERE empresa = cEmpresa
				AND numcte = pNumCliente and id_unidad_prod = '3'  and Cod_caract_2 ='11' LIMIT 1;
				LET ctesCount = dbinfo("sqlca.sqlerrd2");
				if ctesCount > 0 then 
				--Si es asi se realiza un update a todos ellos 
					UPDATE bdicred:sd_maecred
					SET id_unidad_prod = null, Cod_caract_2 = null
					WHERE empresa = cEmpresa
					AND numcte = pNumCliente and id_unidad_prod = '3'  and Cod_caract_2 ='11';
				end if;
	
			--###########Termina la logica del sp##################--
		END IF;	
		RETURN codRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez', 
'DESCRIPCION: Actualizacion de activisÂ¿das y sub actividad en si_ingresos en caso de ser correcto se retorna un codigo 00000',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalidos',
'FECHA : 14/Junio/2022',
'BD    : BDINTEG',
'FOLIO: RQM 11 175 ActualizaciÃ³n del dato Actividad del cliente en Sucursal';

CREATE PROCEDURE "informix".sp_verifica_mantenimiento_cte(pNumcte CHAR(9))
    RETURNING CHAR(5);
	-- VARIABLES --
	DEFINE vCodRet	CHAR(5);
	DEFINE cveOpcionPuesto integer;
	DEFINE cveSubOpcionPuesto integer;
	DEFINE iSqlErr 	  INTEGER; 
    DEFINE iIsamErr   INTEGER;
    DEFINE numCuenta CHAR(20);
    DEFINE cuentaCount INTEGER;
    DEFINE numCredito CHAR(20);
    DEFINE dicriminante CHAR(2);
	DEFINE esExiste         INTEGER;
	
	LET vCodRet = '00000';
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET cveOpcionPuesto = 0;
	LET cveSubOpcionPuesto = 0;
	LET numCuenta = '';
	LET numCredito = '';
        --SET DEBUG FILE TO '/sp_verificamantenimiento.out';
	--TRACE ON;
	
	-- MANEJO DE EXCEPCIONES --
    BEGIN
	
        ON EXCEPTION SET iSqlErr, iIsamErr
            IF iSqlErr <> 0 THEN 
                LET vCodRet = iSqlErr;
                RETURN vCodRet;
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --valida parametro de entrada
        IF NVL(pNumcte,'') = '' THEN
            LET vCodRet = '00005'; --ALGUNO DE LOS PARAMETROS ESTA VACIO O NULO
            RETURN vCodRet;
        END IF;
		--Se valida que el cliente exista en la tabla si_ingresos
		 select claveopcionpuesto into dicriminante from bdinteg:si_ingresos where numcte = pNumcte limit 1;
	            LET esExiste = dbinfo("sqlca.sqlerrd2");
	     if esExiste = 0 then
			LET vCodRet = '00006';
				RETURN vCodRet; 
		else
			
		
			--VERIFICO QUE EL CLIENTE TENGA LOS CAMPOS ACTIVIDAD Y SUBACTIVIDAD CARGADOS EN EL SISTEMA
			SELECT NVL(claveopcionpuesto, 0), NVL(clavesubopcionpuesto, 0)
			INTO cveOpcionPuesto, cveSubOpcionPuesto
			from bdinteg:si_ingresos where sec_ingreso in(
				select max(sec_ingreso) from  bdinteg:si_ingresos
				where numcte = pNumcte)
			and numcte = pNumcte;
			
			IF (cveOpcionPuesto = 0) OR (cveSubOpcionPuesto = 0) THEN
				LET vCodRet = '00001';
				RETURN vCodRet;
			ELSE
				--VALIDO SI EL CLIENTE TIENE CUENTAS BLOQUEADAS POR CAPTACION
				select a.cuenta 
				into numCuenta 
				from bdicheq:sc_maechq a, bdicheq:sc_ctabloqueo b 
				where a.status_cta=3
				and a.cuenta=b.cuenta  
				and  a.num_cte = pNumcte 
				and b.cve_tipobloq= '14'
				and b.clave = '16' LIMIT 1;
				
				LET cuentaCount = dbinfo("sqlca.sqlerrd2");
				if cuentaCount = 0 then 
					--VALIDO SI LA CUENTA BLOQUEADA en creditos
					SELECT num_credito 
					INTO numCredito
					FROM bdicred:SD_MAECRED
					WHERE EMPRESA = '001'
					AND numcte = pNumcte
					and id_unidad_prod = 3
					and cod_caract_2 = '11' LIMIT 1;
					LET cuentaCount = dbinfo("sqlca.sqlerrd2");
					 if cuentaCount = 0 then
						return vCodRet;
					 else
						let vCodRet = '00003';
						return vCodRet;
					 end if;
				ELSE
					let vCodRet ='00002';
					RETURN vCodRet ;
				end if;
			END IF;
		End If;
        RETURN vCodRet ;
    END;
END PROCEDURE
DOCUMENT
'AUTOR: Luis GermÃ¡n Viveros Andrade', 
'DESCRIPCION: Verifica si un cliente es candidato a dar mantenimiento por causa de bloqueo por falta de datos en campos actividad y subactividad',
'Codigo de retorno 00000 indica que cliente no requeire mantenimiento',
'Codigo de retorno 00001 indica que cliente no tiene datos en los campos actividad y subactividad',
'Codigo de retorno 00002 indica que con cuentas de captaciÃ³n bloqueadas por actividad y subactividad',
'Codigo de retorno 00003 indica que con cuentas de crÃ©dito bloqueadas por actividad y subactividad',
'Codigo de retorno 00005 indica que errores en las consultas SQL',
'Codigo de Retorno 00006 indica que no existen datos para el cliente en la tabla si_ingresos',
'FECHA : 21/julio/2022',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_consulta_ctebancplcpl_club(pEmpresa CHAR(3), pCliente CHAR(20), pTipoCliente CHAR(1))
RETURNING CHAR(6) AS codRet, CHAR(1) AS CteRelacionado, CHAR(20) AS CteBancoppel, CHAR(20) AS CteCoppel, CHAR(1) AS CteCpelProspecto;

--DEFINICION DE VARIABLES
DEFINE cCodret			 CHAR(6);
DEFINE cCodret2			CHAR(6);
DEFINE cDescripcion		CHAR(80);
DEFINE cCteRelacionado  CHAR(1);
DEFINE cCteCplProspecto CHAR(1);
DEFINE cCteCoppel CHAR(20);
DEFINE cCteBancoppel  CHAR(20);
DEFINE iSqlErr INTEGER;

--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cCodret2="000000";
LET cDescripcion='';
LET iSqlErr = 0;
LET cCteRelacionado ='';
LET cCteCplProspecto='';
LET cCteCoppel ='';
LET cCteBancoppel='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consulta_ctebancplcpl_club.out';
-- TRACE ON;
	
BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cCteRelacionado, cCteBancoppel, cCteCoppel, cCteCplProspecto;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,'')) ='' OR TRIM(NVL(pTipoCliente,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
		IF TRIM(pTipoCliente)='1' THEN
			SELECT numcte_banco
			INTO cCteBancoppel
			FROM "informix".si_relacion_ctebcplcpl
			WHERE empresa = pEmpresa AND numcte_banco = pCliente;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				EXECUTE PROCEDURE "informix".sp_relacion_generarelacion (TRIM(NVL(pCliente,'')),'','','0','0')
				INTO cCodret2, cDescripcion;
				IF cCodret2<>"000000" THEN
					LET cCodret="000002";
					RETURN cCodret, cCteRelacionado, cCteBancoppel, cCteCoppel, cCteCplProspecto;
				END IF
			END IF
			SELECT cliente, cliente_prosp,numcte_banco
			INTO cCteCoppel, cCteCplProspecto,cCteBancoppel
			FROM "informix".si_relacion_ctebcplcpl
			WHERE empresa = pEmpresa AND numcte_banco = pCliente;
			
		ELSE
			SELECT cliente, cliente_prosp,numcte_banco
			INTO cCteCoppel, cCteCplProspecto,cCteBancoppel
			FROM "informix".si_relacion_ctebcplcpl
			WHERE empresa = pEmpresa AND cliente = pCliente;
		END IF
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000002'; --Cliente Bancoppel No encontrado
				LET cCteRelacionado ='';
				LET cCteBancoppel ='';
				LET cCteCoppel = '';
				LET cCteCplProspecto ='';
			ELSE --Si se encontro el cliente
				IF TRIM(NVL(cCteCoppel,''))<>'' THEN
					LET cCteRelacionado ='1';
					IF TRIM(NVL(cCteCplProspecto,''))='' THEN
						LET cCteCplProspecto='2'; --Cliente no definido como prospecto o titular
					END IF
				ELSE
					LET cCteRelacionado ='0';
				END IF
			END IF
		
		END IF
		RETURN cCodret, cCteRelacionado, cCteBancoppel, cCteCoppel, cCteCplProspecto;
END
END PROCEDURE
DOCUMENT
"Descripción: Retorna si un Cliente Bancoppel está relacionado con un cliente Coppel y si es titular o prospecto",
"Autor : Leslie Rendón",
"FECHA : 02/07/2014",
"Modifica: Leslie Rendón",
"Descripción: Se modifica para agregar llamado al sp_relacion_generarelacion", 
"para hacer insert en la tabla si_relacion_ctebcplcpl cuando el registro no exista",
"Sustento: Se solicito corrección en correo de incidencia Club de Protección Coppel - Error 13",
"Solicita: Iris Arias",
"Fecha: 20/10/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consflagretarj(pProducto CHAR(5))
	RETURNING 	CHAR(5) AS retorno,
				CHAR(1) AS flag;
	
	-- DEFINICION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE cValRetorno		CHAR(5);
	DEFINE cFlag			INTEGER;
	
	--INICIALIZACION DE VARIABLES
	LET cValRetorno     = '00001';
	LET cFlag			= "";
	
	--SET DEBUG FILE TO "sp_consflagretarj.out"; 
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;
		
		
		IF NVL(pProducto,'') = '' THEN
			LET cValRetorno = '00001';
		ELSE
	
			SELECT flagretirostar
			INTO cFlag
			From bdinteg:"informix".si_catvalidaprod 
			Where empresa = '001' AND producto = pProducto;
			
			
			LET cValRetorno = '00000';
			
		END IF;

        IF cFlag IS NULL THEN
        
        LET cFlag = 0;
       
        END IF;

 RETURN cValRetorno,cFlag;
	END
END PROCEDURE             
DOCUMENT
'Creado: Martin Miranda',
'Fecha: 05/04/2011',
'Descripcion: Se crea para obtener flag para realizar cualquier transacciÃ³n que requiera autorizaciÃ³n.';

CREATE PROCEDURE "informix".sp_actualiza_info_cliente(cNumCte CHAR(9),cNumSolicitud CHAR(50), cActSexo CHAR(1), cActEdoCiv CHAR(1),cActHabDom CHAR (1))

RETURNING CHAR(5) AS codret;

DEFINE vCodret CHAR (5);
DEFINE vSql_err INTEGER;  
DEFINE iTipoGen INTEGER;
DEFINE cSexo CHAR(2);
DEFINE cEdocivil CHAR (50);
DEFINE cDescEdoCovil CHAR(5);
DEFINE cHabDom CHAR(10);

LET vCodret  = '00000';
LET vSql_err = 0;

LET iTipoGen = 0;
LET cSexo = "";
LET cEdocivil = "";
LET cDescEdoCovil = "";
LET cHabDom = "";

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_actualiza_info_cliente.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF cNumCte is null or cNumCte ="" OR cNumSolicitud is null or cNumSolicitud ="" THEN 
        LET vCodret = '00002'; -- Falta parametro de entrada
        RETURN vCodret;
     END IF;
	 
	IF cActSexo = "1" THEN
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_ctepf WHERE numcte = cNumCte) THEN
			SELECT elemento --Trae el Sexo que se ingreso en el parametrico
			INTO iTipoGen
			FROM bdisolic:"informix".ss_scoring_element
			WHERE activa =1 AND grupo = 2 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 2 AND num_solicitud = cNumSolicitud);
		
			IF iTipoGen = 3 THEN 
				LET cSexo = "F";
			ELSE
				LET cSexo = "M";
			END IF;
		
			UPDATE bdinteg:"informix".si_ctepf 
			SET sexo = cSexo
			WHERE numcte = cNumCte;
		END IF;
	END IF;
	
	IF cActEdoCiv = "1" THEN
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_ctepf WHERE numcte = cNumCte) THEN
			SELECT descripcion
			INTO cEdocivil
			FROM bdisolic:"informix".ss_scoring_element
			WHERE activa = 1 AND grupo = 3 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 3 AND num_solicitud = cNumSolicitud);

			LET cDescEdoCovil = SUBSTR(cEdocivil,1,1);
			
			UPDATE bdinteg:"informix".si_ctepf 
			SET estado_civil = cDescEdoCovil
			WHERE numcte = cNumCte;
		END IF;
	END IF;
	
	IF cActHabDom = "1" THEN
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = cNumCte) THEN
			SELECT descripcion
			INTO cHabDom
			FROM bdisolic:"informix".ss_scoring_element
			WHERE activa =1 and grupo = 22 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 22 AND num_solicitud = cNumSolicitud);
			
			UPDATE bdinteg:"informix".si_cliente 
			SET string2 = cHabDom
			WHERE numcte = cNumCte;
		END IF;
	END IF;

     RETURN vCodret;
 END;
END PROCEDURE
DOCUMENT
'Folio:			868',
'Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4',
'Autor: 		98440021 - Veronica Rodriguez',
'Fecha: 		29/11/2022',
'Solicita:		Fernando Rojas',
'Descripcion:   Se crea sp para actualizar los datos que se seleccionan en el parametrico y no tiene registrados en la tabla.',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_cons_aut_envio_edocta(pNumCte CHAR (10))
RETURNING CHAR (5), CHAR (1);
    --**************************************************************************************
    --*                            DEFINICION DE VARIABLES
    --**************************************************************************************

    DEFINE cod_ret          CHAR(5); --- codigo de retorno
    DEFINE vsqlerr          INTEGER; -- error de sql
    DEFINE rstatus          CHAR(1); -- retorno de status

    --**************************************************************************************
    --*                            ASIGNACION DE VARIABLES
    --**************************************************************************************

    LET cod_ret             = "00000";
    LET vsqlerr             = 0;
    LET rstatus             = "0";

    --**************************************************************************************
    --*                           CONTROL DE ERRORES
    --**************************************************************************************

    BEGIN
        ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            LET cod_ret = vsqlerr;
            LET rstatus = "0";
            RETURN vsqlerr, rstatus;
        END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/sp_cons_aut_envio_edocta.out";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
		
        --**********************************************************************************
        --*                       PROGRAMA PRINCIPAL
        --**********************************************************************************

        	
			SELECT status_autorizacion INTO rstatus 
			FROM bdinteg:"informix".si_autorizacion_envio_edocta 
			WHERE numcte = TRIM(pNumCte);
				
			IF NVL(rstatus, '') = "" THEN
				LET rstatus = "0";
			END IF;
		
		RETURN cod_ret, rstatus;

    END;
END PROCEDURE
DOCUMENT
'-- --------------------------------------------------------------------------',
'--Autor: 90225188 Jose Natanael Ortiz Rodriguez',
'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
'--Fecha: 26/09/2022.',
'--Solicita:', 
'--Descripcion: Se crea procedimiento almacenado para obtener la informaciÃ³n de la autorizacion del cliente.',
'--BD: bdinteg.',
'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_leyendas_hcbopt()
RETURNING	CHAR(6)	AS cCod_ret,
			CHAR(100) AS cEncabezado,
			CHAR(700) AS cDescripcion,
			CHAR(1) AS iObligatorio;
  	
    -- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************

    DEFINE cCod_ret	CHAR(6);
	DEFINE iSqlErr	INTEGER;	
	
	DEFINE cEncabezado	CHAR(100);
	DEFINE cDescripcion	CHAR(700);
	DEFINE iObligatorio	CHAR(1);
	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

    LET iSqlErr				= 0;
    LET cCod_ret     	  	= '000000';	
	LET cEncabezado			= "";
	LET cDescripcion		= "";
	LET iObligatorio		= '0';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				RETURN NVL(cCod_ret,''),NVL(cEncabezado,''),NVL(cDescripcion,''),NVL(iObligatorio,'0');
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/sp_consulta_leyendas_hcbopt.out";
		--TRACE ON;
	
	    SET LOCK MODE TO WAIT 3;
	    SET ISOLATION TO DIRTY READ;
	    
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************
		FOREACH  
			
				SELECT encabezado, descripcion, obligatorio
				INTO cEncabezado, cDescripcion, iObligatorio
				FROM bdinteg:"informix".si_leyendas_hcbopt
				WHERE status = 'A'
				ORDER BY secuencia
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCod_ret	= '000001';	
			    RETURN NVL(cCod_ret,''),NVL(cEncabezado,''),NVL(cDescripcion,''),NVL(iObligatorio,'0');
			END IF;
			
			RETURN NVL(cCod_ret,''),NVL(cEncabezado,''),NVL(cDescripcion,''),NVL(iObligatorio,'0') WITH RESUME;
	
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT
'----------------------------------------------------------------------------',
'--Autor: 97523641 Alberto Sanchez',
'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
'--Fecha: 26/09/2022.',
'--Solicita:', 
'--Descripcion: Se crea procedimiento almacenado para las consultas ',
'--de los mensajes de privacidad',
'--BD: bdinteg.',
'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".ctefisico_opt(
	pEmpresa			CHAR(3),
	pFuncion			CHAR(1),
	pNumcte				CHAR(20),
	pSucursal			CHAR(4),
	pEjecutivo			CHAR(8),
	pTp_persona			CHAR (2),
	pTp_cliente			CHAR(1),
	pPaterno			CHAR (26),
	pMaterno			CHAR (26),
	pNombre1			CHAR (26),
	pNombre2			CHAR (26),
	pRfc				CHAR (13),
	pSector				CHAR (2),
	pSegmento			CHAR (3),
	pActividad_princ	CHAR (3),
	pGrupo				CHAR(3),
	pSubgrupo			CHAR(3),
	pResidencia			CHAR(1),
	pApell_casada		CHAR(20),
	pNumcte_ref			CHAR(20),
	pDistrito			CHAR(2),
	pPuesto_ppes		CHAR(1),
	pFamiliar_ppes		CHAR(1),
	pActividad_esp		CHAR(11),
	pFecha_nac			DATE,
	pLugar_nac			CHAR (2),
	pNacionalidad		CHAR(3),
	pFm3				CHAR(18),
	pEstado_civil		CHAR(1),
	pRegimen_mat		CHAR(1),
	pProfesion			CHAR (3),
	pSexo				CHAR(1),
	pCurp				CHAR(20),
	pCodidentif			CHAR(2),
	pNumidentif			CHAR(30),
	pNo_imss			CHAR(12),
	pDependientes		SMALLINT,
	pTutor				CHAR(60),
	pEmail				CHAR(60),
	pNom_conyuge		CHAR(60),
	pSeguro_defunc		CHAR(1),
	pEscolaridad		CHAR(2),
	pHabita_en			CHAR(20),
	pAnios_habita		SMALLINT,
	pNombre_prop		CHAR(60),
	pImphiporenta 		MONEY(14,2),
	pNumeroife			CHAR(20),
	pNumerotutor		CHAR(20),
	pNumeroconyuge		CHAR(20),
	pEjecut_autoriza	CHAR(8),
	pPromocion			CHAR(2),
	pNumhabitantes		CHAR (60),
	pIdPais				CHAR(3) 
)

RETURNING CHAR(5),CHAR(20);

DEFINE cCodret 			CHAR(5);
DEFINE cCodret2 			CHAR(5);
DEFINE dFecha 				DATE;
DEFINE iSignumcte 			INT;
DEFINE cExiste 			CHAR(1);
DEFINE cEmpresa 			CHAR(3);
DEFINE cNumcte 			CHAR(20);
DEFINE cSucursal 			CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE cEjecut_autoriza 	CHAR(8);
DEFINE cTp_persona 		CHAR (2);
DEFINE cTp_cliente 		CHAR(1);
DEFINE cPaterno 			CHAR(26);
DEFINE cMaterno 			CHAR(26);
DEFINE cNombre1 			CHAR(26);
DEFINE cNombre2 			CHAR(26);
DEFINE cRfc 				CHAR(13);
DEFINE cSector 			CHAR(2);
DEFINE cSegmento 			CHAR(3);
DEFINE cAtividad_princ 	CHAR(3);
DEFINE cGrupo 				CHAR(3);
DEFINE cSubgrupo 			CHAR(3);
DEFINE cResidencia 		CHAR(1);
DEFINE cApell_casada 		CHAR(20);
DEFINE cNumcte_referencia	CHAR(20);
DEFINE cDistrito 			CHAR(2);
DEFINE cPuesto_ppes 		CHAR(1);
DEFINE cFamiliar_ppes 		CHAR(1);
DEFINE cActividad_esp 		CHAR(11);
DEFINE dFecha_nac 			DATE;
DEFINE cLugar_nac 			CHAR(2);
DEFINE cNacionalidad 		CHAR(3);
DEFINE cFm3 				CHAR(18);
DEFINE cEstado_civil 		CHAR(1);
DEFINE cRegimen_mat 		CHAR(1);
DEFINE cProfesion 			CHAR (3);
DEFINE cSexo 				CHAR(1);
DEFINE cCurp 				CHAR(20);
DEFINE cCodidentif 		CHAR(2);
DEFINE cNumidentif 		CHAR(20);
DEFINE cNo_imss 			CHAR(12);
DEFINE sDependientes 		SMALLINT;
DEFINE cTutor 				CHAR(60);
DEFINE cEmail 				CHAR(60);
DEFINE cNom_conyuge 		CHAR(60);
DEFINE cSeguro_defunc 		CHAR(1);
DEFINE cEscolaridad 		CHAR(2);
DEFINE cHabita_en 			CHAR(20);
DEFINE sAnios_habita 		SMALLINT;
DEFINE cNombre_prop 		CHAR(60);
DEFINE mImphiporenta 		MONEY(14,2);
DEFINE cNumeroife 			CHAR(20);
DEFINE cNumerotutor 		CHAR(20);
DEFINE cNumeroconyuge 		CHAR(20);
DEFINE cTppersona 			CHAR(2);
DEFINE sCont 				SMALLINT;
DEFINE cEsfisica 			CHAR(1);
DEFINE sLongitud		    SMALLINT;
DEFINE sLong_cte 			SMALLINT;
DEFINE iSqlerr				INTEGER;
DEFINE iIsamerr 			INTEGER;
DEFINE cStatus_cte 		CHAR(2);
DEFINE dFecha_alta 		DATE;
DEFINE cRazon_soc 			CHAR(40);
DEFINE sDiferencia			SMALLINT;
DEFINE sI 					SMALLINT;
DEFINE cNumcte_ref 		CHAR(20);
DEFINE cNumhabitantes 		CHAR(60);
DEFINE cSucursalCajaUnica 	CHAR(1);
DEFINE iOrigen 			INTEGER;
DEFINE cTipoRel 			CHAR(1);
DEFINE cCodRet3            CHAR(6);
DEFINE cMensajeRet         CHAR(80);

-- Valida referencia Coppel
DEFINE v_codret_cc         CHAR(5);
DEFINE v_result_cc			CHAR(1);
-- Valida referencia Coppel
--variable para guardar resultado de consulta
DEFINE nRes					INTEGER;
DEFINE nRes2				INTEGER;

DEFINE mCURP                CHAR(30);
DEFINE mCORREO              CHAR(30);
DEFINE mIDENTIF             CHAR(30);

LET mCURP='';
LET mCORREO='';
LET mIDENTIF='';


LET nRes 				=0;
LET nRes2 				=0;
LET cCodret 			= "000";
LET cCodret2 			= '000';
LET cEmpresa 			= pEmpresa;
LET cNumcte 			= " ";
LET cSucursal 			= pSucursal;
LET cTppersona 			= pTp_persona;
LET cNumcte_ref 		= " ";
LET cEjecut_autoriza 	= pEjecut_autoriza;
LET iOrigen 			= 0;
LET cTipoRel			='0';
LET cCodRet3            = "00000";
LET cMensajeRet         = "Se realizÃ³ la consulta correctamente";


LET v_codret_cc      = "00000";
LET v_result_cc		= '';



BEGIN
ON EXCEPTION SET iSqlerr,iIsamerr
	IF iSqlerr != 0 THEN
		LET cCodret=iSqlerr;
		RETURN cCodret,cNumcte;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/ctefisico_opt.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy
  INTO dFecha
  FROM bdinteg:"informix".si_fechas
 WHERE empresa = pEmpresa;

    IF pFuncion = "B" THEN
        LET cNumcte = pNumcte;
        SELECT tpo_persona INTO cTppersona
          FROM bdinteg:"informix".si_cliente
         WHERE numero = pnumero;
        IF cTppersona IS NULL THEN
            LET cNumcte = pNumcte;
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT es_fisica
              INTO cEsfisica
              FROM bdinteg:"informix".si_tipper
             WHERE tpo_persona = cTppersona;

            IF UPPER(cEsfisica) != "S" THEN
                LET cCodret = "120";
                RETURN cCodret,cNumcte;
            END IF;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicheq:"informix".sc_maechq
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdisolic:"informix".ss_solicitudes
         WHERE empresa="001"
           AND numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdinvers:"informix".sv_maeinv
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        BEGIN

        DELETE FROM bdinteg:"informix".si_direcciones WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refcomer WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refbancarias WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refper WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cterelacionado WHERE empresa = "001" AND numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cteppes WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;

        END;

        RETURN cCodret,cNumcte;
    END IF

    IF pFuncion = "C" THEN
        LET cNumcte = pNumcte;

       /*
         OBTENEMOS CURP Y NUMERO DE IDENTIFICACION Y CORREO PARA NO ACTUALIZARLOS
       */
        SELECT LIMIT 1 CURP, NUMIDENTIFI INTO mCURP, mIDENTIF FROM SI_CTEPF WHERE NUMCTE=cNumcte;
        SELECT limit 1 CORREO_ELEC INTO mCORREO FROM SI_CORREOS WHERE NUMCTE=cNumcte AND STATUS_CORREO='A';


        SELECT empresa,     numcte,       status_cte,     sucursal,     ejecutivo,
               tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
               nombre1,     nombre2,      razon_social,   rfc,
               sectOR,      segmento,     actividad_princ,grupo,
               subgrupo,    residencia,   fecha_alta,     apell_casada,
               distrito,    numcte_ref,   puesto_ppes,    familiar_ppes,
               actividad_princ,ejecut_autoriza, string2
          INTO cEmpresa,   cNumcte,      cStatus_cte,    cSucursal,   cEjecutivo,
               cTppersona,  cTp_cliente,  cPaterno,       cMaterno,
               cNombre1,    cNombre2,     cRazon_soc,     cRfc,
               cSector,     cSegmento,    cAtividad_princ,cGrupo,
               cSubgrupo,   cResidencia,  dFecha_alta,    cApell_casada,
               cDistrito,   cNumcte_ref,  cPuesto_ppes,   cFamiliar_ppes,
               cActividad_esp,cEjecut_autoriza, cNumhabitantes
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pNumcte;


        IF cNumcte IS NULL THEN
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF

        IF pEmpresa IS NULL OR pEmpresa = " " THEN
            LET pEmpresa = cEmpresa;
        END IF

        IF pSucursal IS NULL OR pSucursal = " " THEN
            LET pSucursal=cSucursal;
        END IF;

        IF pEjecutivo IS NULL OR pEjecutivo = " " THEN
            LET pEjecutivo=cEjecutivo;
        END IF;

        IF pTp_persona IS NULL OR pTp_persona = " " THEN
            LET pTp_persona=cTppersona;
        END IF;

        IF pTp_cliente IS NULL OR pTp_cliente = " " THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pTp_cliente = '2' AND cTp_cliente = '1' THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pPaterno IS NULL OR pPaterno = " " THEN
            LET pPaterno=cPaterno;
        END IF;

        IF pMaterno IS NULL OR pMaterno = " " THEN
            LET pMaterno=cMaterno;
        END IF;

        IF pNombre1 IS NULL OR pNombre1 = " " THEN
            LET pNombre1=cNombre1;
        END IF;

        IF pNombre2 IS NULL OR pNombre2 = " " THEN
            LET pNombre2=cNombre2;
        END IF;

        IF pRfc IS NULL OR pRfc = " " THEN
            LET pRfc=cRfc;
        END IF;

        IF pSector IS NULL OR pSector = " " THEN
            LET pSector=cSector;
        END IF;

        IF pSegmento IS NULL OR pSegmento = " " THEN
            LET pSegmento=cSegmento;
        END IF;

        IF pActividad_princ IS NULL OR pActividad_princ = " " THEN
            LET pActividad_princ=cAtividad_princ;
        END IF;

        IF pGrupo IS NULL OR pGrupo = " " THEN
            LET pGrupo=cGrupo;
        END IF;

        IF pSubgrupo IS NULL OR pSubgrupo = " " THEN
            LET pSubgrupo=cSubgrupo;
        END IF;

        IF pResidencia IS NULL OR pResidencia = " " THEN
            LET pResidencia=cResidencia;
        END IF;

        IF pApell_casada IS NULL OR pApell_casada = " " THEN
            LET pApell_casada = cApell_casada;
        END IF;

        IF pDistrito IS NULL OR pDistrito = " " THEN
            LET pDistrito=cDistrito;
        END IF;

        IF pNumcte_ref IS NULL OR pNumcte_ref = " " THEN
            LET pNumcte_ref=cNumcte_ref;
        END IF;

        IF pPuesto_ppes IS NULL OR pPuesto_ppes = " " THEN
            LET pPuesto_ppes=cPuesto_ppes;
        END IF;

        IF pFamiliar_ppes IS NULL OR pFamiliar_ppes = " " THEN
            LET pFamiliar_ppes=cFamiliar_ppes;
        END IF;

        IF pActividad_esp IS NULL OR pActividad_esp = " " THEN
            LET pActividad_esp=cActividad_esp;
        END IF;

        IF pEjecut_autoriza IS NULL OR pEjecut_autoriza = " " THEN
            LET pEjecut_autoriza=cEjecut_autoriza;
        END IF;

        IF pCurp IS NULL OR pCurp = "" THEN
            LET pCurp=mCURP;
        END IF;

        IF pNumidentif IS NULL OR pNumidentif = "" THEN
            LET pNumidentif=mIDENTIF;
        END IF;

        IF pEmail IS NULL OR pEmail = "" THEN
            LET pEmail=mCORREO;
        END IF;



        SELECT numcte,         fecha_nac,       lugar_nac,        nacionalidad,
               no_fm3,         estado_civil,    regim_matrimonio, profesion,
               sexo,           curp,            codidentifi,      numidentifi,
               no_imss,        dependientes,    tutor,
               nom_conyuge,    seguro_defunc,   escolaridad,      habita_en,
               anios_habita,   nombre_prop,     imp_hipo_renta,   numeroife,
               numerotutor,    numeroconyuge
          INTO cNumcte,        dFecha_nac,      cLugar_nac,       cNacionalidad,
               cFm3,           cEstado_civil,   cRegimen_mat,     cProfesion,
               cSexo,          cCurp,           cCodidentif,      cNumidentif,
               cNo_imss,       sDependientes,   cTutor,
               cNom_conyuge,   cSeguro_defunc,  cEscolaridad,     cHabita_en,
               sAnios_habita,  cNombre_prop,    mImphiporenta,    cNumeroife,
               cNumerotutor,   cNumeroconyuge
          FROM bdinteg:"informix".si_ctepf
         WHERE numcte = pNumcte;

        SELECT correo_elec
          INTO cEmail
          FROM "informix".si_correos
         WHERE numcte = pNumcte
           AND tipo_correo = 1
           AND status_correo = 'A'
		   and secuencia = (
			select max(secuencia)
			from "informix".si_correos
			where numcte = pNumcte AND status_correo = 'A' AND tipo_correo = 1);

        IF pFecha_nac IS NULL OR pFecha_nac = " " THEN
            LET pFecha_nac=dFecha_nac;
        END IF;

        IF pLugar_nac IS NULL OR pLugar_nac = " " THEN
            LET pLugar_nac=cLugar_nac;
        END IF;

        IF pNacionalidad IS NULL OR pNacionalidad = " " THEN
            LET pNacionalidad=cNacionalidad;
        END IF;

        IF pEstado_civil IS NULL OR pEstado_civil = " " THEN
            LET pEstado_civil=cEstado_civil;
        END IF;

        IF pRegimen_mat IS NULL OR pRegimen_mat = " " THEN
            LET pRegimen_mat=cRegimen_mat;
        END IF;

        IF pProfesion IS NULL OR pProfesion = " " THEN
            LET pProfesion = cProfesion;
        END IF;

        IF pSexo IS NULL OR pSexo = " " THEN
            LET pSexo=cSexo;
        END IF;

		IF(pCurp <> '') THEN
		
			IF SUBSTRING(cRfc FROM 1 FOR 10) <> SUBSTRING(pCurp FROM 1 FOR 10) THEN
					INSERT INTO bdinteg:"informix".si_bitacora_cambio_curp
					( numcte, rfc, curp, resultado, fecha )
					VALUES
					( pNumcte, cRfc, pCurp, '03', CURRENT );

			END IF;
		
		END IF;

        IF pCodidentif IS NULL OR pCodidentif = " " THEN
            LET pCodidentif = cCodidentif;
        END IF

        IF pNumidentif IS NULL OR pNumidentif = " " THEN
            LET pNumidentif = cNumidentif;
        END IF

        IF pNo_imss IS NULL OR pNo_imss = " " THEN
            LET pNo_imss = cNo_imss;
        END IF

        IF pDependientes IS NULL OR pDependientes = " " THEN
            LET pDependientes = sDependientes;
        END IF

        IF pTutor IS NULL OR pTutor = " " THEN
            LET pTutor = cTutor;
        END IF

        IF pEmail IS NULL OR pEmail = " " THEN
            LET pEmail = cEmail;
        END IF

        IF pNom_conyuge IS NULL OR pNom_conyuge = " " THEN
            LET pNom_conyuge = cNom_conyuge;
        END IF

        IF pEscolaridad IS NULL OR pEscolaridad = " " THEN
            LET pEscolaridad = cEscolaridad;
        END IF

        IF pHabita_en IS NULL OR pHabita_en = " " THEN
            LET pHabita_en = cHabita_en;
        END IF

        IF pAnios_habita IS NULL THEN
            LET pAnios_habita = sAnios_habita;
        END IF

        IF pNombre_prop IS NULL OR pNombre_prop = " " THEN
            LET pNombre_prop = cNombre_prop;
        END IF

        IF pImphiporenta IS NULL THEN
            LET pImphiporenta = mImphiporenta;
        END IF

        IF pNumeroife IS NULL OR pNumeroife = " " THEN
            LET pNumeroife = cNumeroife;
        END IF

        IF pNumerotutor IS NULL OR pNumerotutor = " " THEN
            LET pNumerotutor = cNumerotutor;
        END IF

        IF pNumeroconyuge IS NULL OR pNumeroconyuge = " " THEN
            LET pNumeroconyuge = cNumeroconyuge;
        END IF
    END IF

	IF NVL(pFuncion,'') = "S" THEN
		IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pEscolaridad,'') = '' THEN
				LET cCodret = "200";
				RETURN cCodret,cNumcte;
		ELSE
			SELECT 1 INTO cExiste
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa AND numcte = pNumcte;

		   IF NVL(cExiste,'') = '1' THEN
				SELECT 1 INTO cExiste
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa AND numcte = pNumcte;

				IF NVL(cExiste,'') = '1' THEN
					UPDATE bdinteg:"informix".si_ctepf
					SET escolaridad = pEscolaridad
					WHERE empresa = pEmpresa AND numcte = pNumcte;
					RETURN cCodret,cNumcte;
				ELSE
					LET cCodret = "220";
					RETURN cCodret,cNumcte;
			   END IF
			ELSE
				LET cCodret = "210";
				RETURN cCodret,cNumcte;
		   END IF
		END IF;
	END IF

    --- Verifica recepcion correcta de datos
    IF pSucursal IS NULL OR pEjecutivo IS NULL OR
       pTp_persona IS NULL OR pTp_cliente IS NULL OR
       pPaterno IS NULL OR pNombre1 IS NULL OR pRfc IS NULL OR
       pSector IS NULL OR pSegmento IS NULL OR
       pActividad_princ IS NULL OR pGrupo IS NULL OR
       pSubgrupo IS NULL OR pResidencia IS NULL OR
       pPuesto_ppes IS NULL OR pFamiliar_ppes IS NULL OR
       pFecha_nac IS NULL OR pLugar_nac IS NULL OR
       pNacionalidad IS NULL OR pEstado_civil IS NULL OR
       pProfesion IS NULL OR pSexo IS NULL OR
       pCodidentif IS NULL OR pNumidentif IS NULL OR
       pDependientes IS NULL OR pEscolaridad IS NULL OR
       pHabita_en IS NULL THEN
        LET cCodret = "110";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT es_fisica
      INTO cEsfisica
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = pTp_persona;

    IF UPPER(cEsfisica) != "S" THEN
        LET cCodret = "120";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal=pSucursal;

    IF cExiste IS NULL THEN
        LET cCodret = "111";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_ejecut
     WHERE ejecutivo=pEjecutivo;

    IF cExiste IS NULL THEN
        FOREACH
            SELECT limit 1 1
                INTO cExiste
            FROM bdinteg:"informix".si_usuario_movil
            WHERE ejecutivo=pEjecutivo
        END FOREACH;

        IF cExiste IS NULL THEN
            LET cCodret = "112";
            RETURN cCodret,cNumcte;
        END IF;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector=pSector;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_segment
     WHERE segmento=pSegmento;

    IF cExiste IS NULL THEN
        LET cCodret = "114";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_grupos
     WHERE grupo=pGrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "115";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_subgpos
     WHERE subgrupo=pSubgrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "116";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_nacion
     WHERE nacion=pNacionalidad;

    LET pRfc = TRIM(pRfc);

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_cliente
     WHERE rfc = pRfc;

    IF NOT cExiste IS NULL AND pFuncion = "A" THEN
        LET cCodret = "106";
        RETURN cCodret,cNumcte;
    END IF

    IF TRIM(pCodidentif) <> "" THEN
        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_tipoidentif
         WHERE codidentif = pCodidentif;

        IF cExiste IS NULL THEN
            LET cCodret = "133";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    IF pTp_cliente = "M" THEN ---MenOR de edad
        IF pTutor IS NULL OR pTutor = "" THEN
            LET cCodret = "144";
            RETURN cCodret,cNumcte;
        END IF

        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pTutor;

        IF cExiste IS NULL THEN
            LET cCodret = "145";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    IF pNumcte IS NULL OR pNumcte = " " THEN
        SELECT valor
          INTO sLong_cte
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 7
           AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte=iSignumcte;
            LET iSignumcte=iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            LET sDiferencia = sLong_cte - LENGTH(cNumcte);

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;
    ELSE
        LET cNumcte = pNumcte;
    END IF;

    -- ****************** Actualizacion de Parametros *****************
    IF pFuncion = "A" THEN
        SELECT 1 INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste = "1" THEN
            LET cCodret = "118";
            RETURN cCodret, cNumcte;
        END IF;

        IF NVL(pNumcte_ref,'') <> '' THEN
-- Valida referencia Coppel 
            EXECUTE PROCEDURE bdinteg:"informix".sp_cons_ref_cop(pEmpresa, pSucursal, pEjecutivo, cNumcte, pNumcte_ref, pPaterno, pMaterno, pNombre1 ,pNombre2, pRfc)
                         INTO v_codret_cc, v_result_cc;

            IF ( v_result_cc = '1' ) THEN
                LET pNumcte_ref = '';
            END IF;
         END IF;
-- Valida referencia Coppel

		SELECT 1
			INTO cExiste
		FROM bdinteg:"informix".si_cliente
		WHERE rfc = pRfc;

		IF NOT cExiste IS NULL AND pFuncion = "A" THEN
			LET cCodret = "106";
			RETURN cCodret,cNumcte;
		END IF

        BEGIN

        INSERT INTO bdinteg:"informix".si_cliente
        ( empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
          rfc, sectOR, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2,
          numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, user_insert, fecha_insert) --, id_pais ) -- DSB230162JERV1694 id_pais
        VALUES
        ( pEmpresa, cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
          pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
          0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, pEjecutivo, dFecha); --, pIdPais); -- DSB230162JERV1694 pIdPais

        INSERT INTO bdinteg:"informix".si_ctepf
        ( numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
          dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel, id_pais ) -- DSB230162JERV1694 id_pais
        VALUES
        ( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
          pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0', pIdPais); -- DSB230162JERV1694 pIdPais

        SELECT NVL(cajaunica, '')
          INTO cSucursalCajaUnica
          FROM bditarjcop:"informix".sucursalescajaunica
         WHERE cvesucursal = pSucursal;

        IF cSucursalCajaUnica = 'V' THEN
            UPDATE bdinteg:"informix".si_cliente
               SET string1 = '1'
             WHERE numcte = cNumcte;
        END IF;

        IF NVL(pNumcte_ref,"") <> "" THEN ---Se realiza validacion para relacionar al cliente Bancoppel con un Cliente Coppel
			LET iOrigen = 2; 
			LET cTipoRel ='1';
		END IF;		--Se agrega llamado para crear relacion de clientes bancoppel-coppel.

		EXECUTE PROCEDURE bdinteg:"informix".sp_relacion_generarelacion (cNumcte,pNumcte_ref,'',cTipoRel,iOrigen)
        INTO cCodRet3,cMensajeRet;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;

        RETURN cCodret, cNumcte;
    ELSE
        SELECT 1
          INTO cExiste
          FROM "informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste IS NULL THEN
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF;

        BEGIN
		
		SELECT COUNT(*) INTO nRes FROM si_usuario_movil WHERE ejecutivo=pEjecutivo;
        
		IF (nRes > 0) THEN
            
			SELECT  COUNT(*) INTO nRes2 FROM si_solicitud_movil WHERE numcte=cNumcte AND folio_procesado=0 AND status_valua=1;
			
            IF (nRes2 > 0) THEN
			
                SELECT first 1 escolaridad, tipo_residencia, pers_domicilio 
                    INTO pEscolaridad, pHabita_en, pNumhabitantes
                    FROM si_solicitud_movil
					WHERE numcte=cNumcte
					AND folio_procesado=0
					AND escolaridad <>'' AND escolaridad IS NOT NULL
					AND tipo_residencia <>'' AND tipo_residencia IS NOT NULL
					AND pers_domicilio <>'' AND pers_domicilio IS NOT NULL;
					
				
				LET pEscolaridad="0"||pEscolaridad;
				
            END IF;
        END IF;

        UPDATE bdinteg:"informix".si_cliente
           SET ( ejecutivo, tpo_persona, tipo_cliente,
                 sectOR, segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2) = 
               ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
                 pSector, pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes)
        WHERE numcte = cNumcte;
		
		UPDATE bdinteg:"informix".si_ctepf
		   SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
				 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
				 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, sms_cel, id_pais) = 
			   ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
				 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
				 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, '0', pIdPais)
		WHERE numcte = cNumcte;
		

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;
    END IF;

    RETURN cCodret, cNumcte;

    END;

END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para la generacion del numero de cliente banco.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".ctefisico_val_cor_opt(pEmpresa CHAR(3),pFuncion CHAR(1),pNumcte CHAR(20),pSucursal CHAR(4),pEjecutivo CHAR(8),pTp_persona CHAR(2),pTp_cliente CHAR(1),pPaterno CHAR(26),pMaterno CHAR(26),pNombre1 CHAR(26),pNombre2 CHAR(26),pRfc CHAR(13),pSector CHAR(2),pSegmento CHAR(3),pActividad_princ CHAR(3),pGrupo CHAR(3),pSubgrupo CHAR(3),pResidencia CHAR(1),pApell_casada CHAR(20),pNumcte_ref CHAR(20),pDistrito CHAR(2),pPuesto_ppes CHAR(1),pFamiliar_ppes CHAR(1),pActividad_esp CHAR(11),pFecha_nac DATE, pLugar_nac CHAR(2),pNacionalidad CHAR(3),pFm3 CHAR(18),pEstado_civil CHAR(1),pRegimen_mat CHAR(1),pProfesion CHAR(3),pSexo CHAR(1),pCurp CHAR(20),pCodidentif CHAR(2),pNumidentif CHAR(30),pNo_imss CHAR(12),pDependientes SMALLINT,pTutor CHAR(60),pEmail CHAR(60),pNom_conyuge CHAR(60),pSeguro_defunc CHAR(1),pEscolaridad CHAR(2),pHabita_en CHAR(20),pAnios_habita SMALLINT,pNombre_prop CHAR(60),pImphiporenta MONEY(14,2),pNumeroife CHAR(20),pNumerotutor CHAR(20),pNumeroconyuge CHAR(20),pEjecut_autoriza CHAR(8),pPromocion CHAR(2),pNumhabitantes CHAR(60),pStatusCode CHAR(3), pIdPais CHAR(3))
RETURNING  CHAR(5) AS Codret,  CHAR(20) AS Numcte;

DEFINE cCodret CHAR(5);
DEFINE cCodret2 CHAR(5);
DEFINE cNumcte CHAR(20);
DEFINE iSqlerr INTEGER;
DEFINE iIsamerr INTEGER;

LET cCodret = "000";
LET cCodret2 = '000';
LET cNumcte = " ";

BEGIN
	ON EXCEPTION SET iSqlerr,iIsamerr
		IF iSqlerr != 0 THEN
			LET cCodret=iSqlerr;
			RETURN cCodret,cNumcte;
		END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO '/tmp/ctefisico_val_cor_opt.out';
	 --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

	--Se le agrega parametro id_pais para invocar el SP pIdPais
	EXECUTE PROCEDURE bdinteg:"informix".ctefisico_opt (pEmpresa,pFuncion,pNumcte,pSucursal,pEjecutivo,pTp_persona,pTp_cliente,pPaterno,pMaterno,pNombre1,pNombre2 ,pRfc ,pSector,pSegmento,pActividad_princ,pGrupo,pSubgrupo,pResidencia,pApell_casada,pNumcte_ref,pDistrito,pPuesto_ppes,pFamiliar_ppes,pActividad_esp,pFecha_nac, pLugar_nac ,pNacionalidad,pFm3,pEstado_civil,pRegimen_mat,pProfesion,pSexo,pCurp,pCodidentif,pNumidentif,pNo_imss,pDependientes,pTutor,'',pNom_conyuge ,pSeguro_defunc ,pEscolaridad,pHabita_en,pAnios_habita,pNombre_prop,pImphiporenta,pNumeroife,pNumerotutor,pNumeroconyuge,pEjecut_autoriza,pPromocion,pNumhabitantes, pIdPais)
	INTO cCodret,cNumcte;
	
	IF pEmail IS NOT NULL OR pEmail <> '' THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos_valcor (pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo,pStatusCode)
		INTO cCodret2;
	END IF
		
	RETURN cCodret, cNumcte;
END;    
END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para la generacion del numero de cliente banco.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".sp_obtiene_ctecurp( pRfc CHAR(13))

RETURNING CHAR(5) AS codret , 
	      CHAR(9) AS numcte,
		  CHAR (18) AS curp,
		  CHAR (1) AS validacurp;

DEFINE vCodret CHAR (5);
DEFINE vNumcte CHAR (20);
DEFINE vCurp 	CHAR (18);
DEFINE vValidaCurp CHAR(1);
DEFINE vSql_err INTEGER;  

LET vCodret  = '00000';
LET vNumcte  = '';
LET vCurp		= '';
LET vValidaCurp = '';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret, vNumcte, vCurp, vValidaCurp;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_obtiene_ctecurp.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF pRfc is null or pRfc ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret, vNumcte, vCurp, vValidaCurp;
     END IF;
	 
	SELECT numcte, curp, validacurp INTO vNumcte, vCurp, vValidaCurp
	FROM bdinteg:"informix".si_ctepf 
	WHERE numcte = (SELECT numcte 
    FROM bdinteg:"informix".si_cliente 
    WHERE rfc = pRfc);
 
    LET vNumcte = NVL(vNumcte,'');
	LET vCurp = NVL(vCurp,'');
	LET vValidaCurp = NVL (vValidaCurp,'');

     RETURN vCodret, TRIM(vNumcte), TRIM(vCurp), TRIM(vValidaCurp);
 END;
END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para obtener la curp del cliente cuando ya exista en BD.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".sp_recuperarcurp(
    cEmpresa    CHAR(3),
    cNumCte     CHAR(20))

RETURNING   CHAR(5) AS cCodRet,
			CHAR(20) AS cCurp;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vCurp CHAR(20);

    LET vCodRet	= '00000';
    LET iSqlErr = 0;
    LET vCurp	= '';


    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN  vCodRet, vCurp;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarCurp.err";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vCurp;
        END IF;
        
        --EL JOIN ES PARA VALIDAR QUE EL CLIENTE EXISTA
        SELECT
            Nvl(curp, '')
        INTO vCurp
        FROM bdinteg:"informix".si_ctepf pf
        INNER JOIN si_cliente c ON c.numcte = pf.numcte
        WHERE pf.numcte = cNumCte AND pf.empresa = cEmpresa;
    
        RETURN vCodRet, vCurp;
        
    END;
        
END PROCEDURE

DOCUMENT
'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de curp con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperardatoscontacto(
	cEmpresa     CHAR(3),
	cNumCte      CHAR(20))
	
RETURNING   CHAR(5)   AS cCodRet,
            CHAR(100) AS cCorreoElectronico,
            CHAR(10)  AS cTelefonoCasa,
            CHAR(10)  AS cTelefonoCelular;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vCorreoElectronico CHAR(100);
    DEFINE vTelefonoCasa CHAR(10);
    DEFINE vTelefonoCelular CHAR(10);
    DEFINE vNumCteProspecto	CHAR(20);
    
    LET iSqlErr = 0;
    LET vCodRet	= '00000';
    LET vCorreoElectronico = '';
    LET vTelefonoCasa = '';
    LET vTelefonoCelular = '';
    LET vNumCteProspecto = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vCorreoElectronico, vTelefonoCasa, vTelefonoCelular;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarDatosContacto.err";
        --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vCorreoElectronico, vTelefonoCasa, vTelefonoCelular;
        END IF; 

        SELECT
            NVL(correo_elec, '')
        INTO vCorreoElectronico
        FROM bdinteg:"informix".si_correos
        WHERE numcte = cNumCte
            AND status_correo = 'A'
            AND empresa = cEmpresa;

        SELECT
            NVL(telefono,'')
        INTO vTelefonoCasa
        FROM bdinteg:"informix".si_telefonos_actual
        WHERE numcte = cNumCte
            AND tipo_tel = 1 --telefono_tipo_casa
            AND status_tel = 'A'
            AND empresa = cEmpresa;

        SELECT
            NVL(telefono, '')
        INTO vTelefonoCelular
        FROM bdinteg:"informix".si_telefonos_actual
        WHERE numcte = cNumCte
            AND tipo_tel = 2 --telefono_tipo_casa
            AND status_tel = 'A'
            AND empresa = cEmpresa;

        --Antes de este punto consulta datos del cliente por si tiene guardados
        IF
            (vTelefonoCasa IS NULL OR len(vTelefonoCasa) = 0)
            and (vTelefonoCelular IS NULL OR len(vTelefonoCelular) = 0)
        THEN
		
            --si los telefonos son vacios no has capturado informaciÃ³n, reviso si capturaste datos como prospecto
            SELECT numcte_pros
            INTO vNumCteProspecto
            FROM bdiprospectos: "informix".pr_cliente
            WHERE numcte = cNumCte
                AND empresa = cEmpresa;
    
            --consulta datos del prospecto
            IF vNumCteProspecto IS NULL OR vNumCteProspecto = '' THEN
                --nada, regresamos datos vacios porque es cliente nuevo
            ELSE
                --consultalos y traemelos
                SELECT NVL(telefono,'')
                INTO vTelefonoCasa
                FROM bdiprospectos:"informix".pr_telefonos
                WHERE numcte_pros = vNumCteProspecto
                    AND tipo_tel = 1
                    AND status_tel = 'A'
                    AND secuencia = (
                        SELECT
                        MAX(secuencia)
                        FROM bdiprospectos:"informix".pr_telefonos
                        WHERE numcte_pros = vNumCteProspecto
                            AND tipo_tel = 1);
    
                SELECT NVL(telefono,'')
                INTO vTelefonoCelular
                FROM bdiprospectos:"informix".pr_telefonos
                WHERE numcte_pros = vNumCteProspecto
                AND tipo_tel = 2
                AND status_tel = 'A'
                AND secuencia = (
                    SELECT
                    MAX(secuencia)
                    FROM bdiprospectos:"informix".pr_telefonos
                    WHERE numcte_pros = vNumCteProspecto
                        AND tipo_tel = 2);
    
                SELECT
                    NVL(correo_elec, '')
                INTO vCorreoElectronico 
                FROM bdiprospectos:"informix".pr_correos
                WHERE numcte_pros = vNumCteProspecto;
            END IF
        END IF
	
	    RETURN vCodRet, NVL(vCorreoElectronico,''), NVL(vTelefonoCasa,''), NVL(vTelefonoCelular,'');
	
	END;
    
END PROCEDURE
	DOCUMENT
	'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
	'Descripcion: CreaciÃ³n de procedure para obtener datos del cliente',
	'AUTOR: 98021080 - Hiram Ramirez',
	'Fecha: 17/10/2022',
	'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperardatosgenerales(
    cEmpresa CHAR(3),
    cNumcte CHAR(20))

RETURNING   CHAR(5)   AS cCodRet,
            SMALLINT  AS iSubActividad,
            SMALLINT  AS iActividad,
            CHAR(120) AS cDescripcionActividad,
            CHAR(1)   AS cTipoHabitacion;

    DEFINE vCodret                  CHAR(5);
    DEFINE iSqlerr                  INTEGER;
    DEFINE vSecuencia               SMALLINT;
    DEFINE vSubActividad            SMALLINT;
    DEFINE vActividad               SMALLINT;
    DEFINE vDescripcionActividad    CHAR(120);
    DEFINE vTipoHabitacion          CHAR(1);
    DEFINE vNumCteProspecto         CHAR(20);

    LET vCodRet = '00000';
    LET iSqlerr = 0;
    LET vSecuencia = 0;
    LET vSubActividad = 0;
    LET vActividad = 0;
    LET vDescripcionActividad = '';
    LET vTipoHabitacion = '';
    LET vNumCteProspecto = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vSubActividad, vActividad, vDescripcionActividad, vTipoHabitacion;
            END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/anj/recuperarDatosGenerales.sql";
		--TRACE ON;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
        
        SELECT MAX(sec_ingreso)
        INTO vSecuencia
        FROM bdinteg:"informix".si_ingresos
        WHERE empresa = cEmpresa
            AND numcte = cNumcte;

        SELECT
            ing.claveopcionpuesto, ing.clavesubopcionpuesto, act.descrip
        INTO
            vActividad, vSubActividad, vDescripcionActividad
        FROM bdinteg:"informix".si_ingresos ing
        LEFT JOIN bdinteg:"informix".si_actsubact act ON act.id_act = ing.claveopcionpuesto AND act.id_subact = ing.clavesubopcionpuesto
        WHERE ing.empresa = cEmpresa
            AND ing.numcte = cNumcte
            AND ing.sec_ingreso = vSecuencia;
    
        SELECT
            habita_en
        INTO vTipoHabitacion
        FROM bdinteg:informix.si_ctepf
        WHERE empresa = cEmpresa
            AND numcte = cNumcte;
    
        --Antes de este punto consulta datos del cliente por si tiene guardados
        IF vTipoHabitacion IS NULL OR len(vTipoHabitacion) = 0 THEN
            
            SELECT numcte_pros
            INTO vNumCteProspecto
            FROM bdiprospectos:"informix".pr_cliente
            WHERE numcte = cNumcte
                AND empresa = cEmpresa;
    
            --consulta datos del prospecto
            IF vNumCteProspecto IS NULL OR vNumCteProspecto = '' THEN
                --nada, regresamos datos vacios porque es cliente nuevo
            ELSE
                --consultalos y traemelos
                SELECT
                    claveopcionpuesto, clavesubopcionpuesto
                INTO vActividad, vSubActividad
                FROM bdiprospectos:"informix".pr_ingresos
                WHERE numcte_pros = vNumCteProspecto
                    AND empresa = cEmpresa;
    
                IF vActividad IS NOT NULL AND vSubActividad IS NOT NULL THEN
                    SELECT act.descrip
                    INTO vDescripcionActividad
                    FROM bdinteg:"informix".si_actsubact act
                    WHERE act.id_act = vActividad
                        AND act.id_subact = vSubActividad;
                END IF
    
                --tipo_habitacion
                SELECT
                    habita_en
                INTO vTipoHabitacion
                FROM bdiprospectos:"informix".pr_ctepf
                WHERE numcte_pros = vNumCteProspecto
                    AND empresa = cEmpresa;
                
            END IF
            
        END IF;
    
        RETURN vCodRet, NVL(vSubActividad,''), NVL(vActividad,''), NVL(vDescripcionActividad,''), NVL(vTipoHabitacion,'');
    
    END;

END PROCEDURE
DOCUMENT
'FOLIO: RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de datos generales con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperartipocliente(
	cEmpresa     CHAR(3),
	cNumCte      CHAR(20))
	
RETURNING 	CHAR(5) AS cCodRet,
			CHAR(1) AS cTipoCliente;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vTipoCliente CHAR(1);
    
    LET iSqlErr = 0;
    LET vCodRet	= '00000';
    LET vTipoCliente = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vTipoCliente;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarTipoCliente.err";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vTipoCliente;
        END IF; 
        
        SELECT
            tipo_cliente
        INTO vTipoCliente
        FROM bdinteg:"informix".si_cliente
        WHERE numcte = cNumCte
            AND empresa = cEmpresa;    
    
        RETURN vCodRet, NVL(vTipoCliente,'');
	
	END;
    
END PROCEDURE
DOCUMENT
'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de tipo de cliente con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_autorizaciones_hcbopt
		(pEmpresa       CHAR (3),
		 pCliente       CHAR (10), 
		 pSucursal      CHAR (4),
		 pOperador      CHAR (10),
		 pMensajeAviso  VARCHAR (200),
		 pSic           CHAR (1),
		 pAviso         CHAR (1),
		 pINE           CHAR(1), 
		 pGrupoCoppel   CHAR (1),
		 pEdoCta        CHAR (1))

		RETURNING       CHAR (5);
		--***************************************************************************************************************
		--*                                    DEFINICION DE VARIABLES                                                  *
		--***************************************************************************************************************

		DEFINE Cod_ret                CHAR(5);
		DEFINE iSqlErr                INTEGER;
		DEFINE aviso_Aut              CHAR(3);
		DEFINE aut_Coppel             CHAR(3);
		DEFINE aut_Sic                CHAR(5);
		DEFINE secuencia              SMALLINT;
		DEFINE aut_EdoCta             CHAR(5);
		DEFINE stat_edoCta            CHAR(1);
		DEFINE existeAutorizadoAviso INTEGER;

		--***************************************************************************************************************
		--*                                    ASIGNACION DE VARIABLES                                                  *
		--***************************************************************************************************************

		LET Cod_ret                   = "00000";
		LET iSqlErr                   = 0;

		LET aviso_Aut                 = '0';
		LET aut_Coppel                = '0';
		LET aut_Sic                   = '0';
		LET secuencia                 = '0';
		LET aut_EdoCta                = '0';
		LET stat_edoCta               = '0';
		LET existeAutorizadoAviso     = 0;

		--***************************************************************************************************************
		--*                                    CONTROL DE ERRORES                                                       *
		--***************************************************************************************************************

		BEGIN
			ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET Cod_ret = iSqlErr;
				RETURN Cod_ret;
			END IF ;
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/sysifx/sp_registra_autorizaciones_hcbopt.out";
			--TRACE ON;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			--***********************************************************************************************************
			--*                                PROGRAMA PRINCIPAL                                                       *
			--***********************************************************************************************************

			IF NVL(pCliente, '') <> "" THEN
				
				--** aviso de privacidad
				IF pAviso = '1' THEN
					
						SELECT count(numcte) into existeAutorizadoAviso 
						FROM bdinteg:"informix".si_autorizacion_privacidad 
						WHERE empresa = pEmpresa AND numcte = pCliente AND respuesta = '1';
					
					IF existeAutorizadoAviso = 0 then
						
						CALL bdinteg:"informix".sp_insert_autor_privacidad(pEmpresa, pCliente,pSucursal,pAviso,pMensajeAviso) RETURNING aviso_Aut;

						IF NVL(aviso_Aut, '') <> "000" THEN
							LET Cod_ret = "00001";
							RETURN  Cod_ret;
						END IF;
					 ELSE
						   LET Cod_ret = "00000";
					 END IF;

				END IF;

				--** Compartir datos con coppel
				IF pGrupoCoppel = '1' THEN
					CALL bdinteg:"informix".sp_autoriza_datos_contacto(pCliente, pOperador, pSucursal, '1', '1', pGrupoCoppel, 2) RETURNING aut_Coppel;
					
					IF NVL(aut_Coppel, '') <> "000" THEN
						LET Cod_ret = "00001";
						RETURN Cod_ret;
					END IF;
				END IF;

				--** autorizacion envio de cuenta por medios electronicos
				IF pEdoCta = '1' THEN
					CALL bdinteg:"informix".sp_registro_aut_envio_edocta(pCliente, pSucursal, pOperador, pEdoCta,"","") RETURNING  aut_EdoCta, stat_edoCta;
				END IF;

			END IF;
			RETURN Cod_ret;
		END;
	END PROCEDURE
	DOCUMENT
	'----------------------------------------------------------------------------',
	'--Autor: Alberto Sanchez',
	'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
	'--Fecha: 26/09/2022.',
	'--Solicita:', 
	'--Descripcion: Se crea procedimiento almacenado para registrar diferentes tablas',
	'--las autorizaciones que selecciono el cliente',
	'--BD: bdinteg.',
	'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cons_datos_contacto(pcliente CHAR(9))
   RETURNING CHAR(3);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE sExiste CHAR(9);

LET iSqlErr = 0;
LET cCodRet = '';
LET sExiste='';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;
        --let pcliente=pcliente;
        select count(numcte) INTO sExiste  from si_autoriza_datos_contacto where numcte=pcliente and flag='1';
  
        IF sExiste='0' THEN
           LET cCodRet = '000'; --Muestra la pregunta en OFI
        ELSE
           LET cCodRet = '001'; --Cte ya respondiÃ³, no muestra la pregunta
        END IF          

RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Folio:			868',
'Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4',
'Autor: 		98440021 - Veronica Rodriguez',
'Fecha: 		29/11/2022',
'Solicita:		Fernando Rojas',
'Descripcion:   Consulta autorizaciones de contacto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_generareplica_catdomssuc()

 returning char(5);

define v_codret        	char(5);
define v_sqlerr        	integer;
define v_isamerr       	integer;
define vdia            	date;
define vhora           	char(8);
define cMensaje        	char(80);
define pUsuario        	char(8);
define pEmpresa        	char(3);
define vtexto_select    char(1000);
define vPath           	char(50);
define cCadena         	char(2500); 
define cCadenadb2       char(2500); 
define vNomarch        	char(80);
define vNomarchdb2     	char(30);
define vfecha_hoy      	char(8);
define vLargoCadena    	integer;
--define vConteo         	smallint;
define vConteo         	integer;
define vfecha_hoy2     	date;
define vf_ultinsercion 	date;
define vf_ultactualiza 	date;
define vCatalogo      	char(20);
define vEjecutarProceso char(1);
define cUPD           	char(1);
define cINS           	char(1);

define i_numerociudad		integer;
define i_numerocolonia		integer;
define c_nombrezona		    char(32);
define c_poblacionzona		char(27);
define c_municipiozona		char(27);
define i_codigopostalzona	integer;
define c_planozona		    char(7);
define c_rumbozona		    char(42);
define i_supervisorzona		integer;
define i_choferzona		    integer; 
define i_jefegrupozona		integer;
define i_gerentezona		integer;
define i_abogadozona		integer;
define c_marcaencuesta30dias char(3);
define i_numerocalle		integer;
define i_numerocasa		    integer;
define c_marcaunidadhabitacional char(3);
define i_numerodivisioncobranzas integer;
define i_claveabogado		integer;
define i_ciudadcobranzas	integer;
define i_numerocobranzas	integer;
define c_clavearagon		char(3);
define i_centro		        integer;
define i_pais               integer;
define i_estado             integer;
define i_ciudad             integer;
define c_nombreciudad       char(50);
define i_numerociudad_2     integer;
define c_localidad          char(8);
define i_tipociudad         integer;
define dFecha_hoy           date;
define cUsr_modifica        char(10);
define iExiste_col          integer;
define iExiste_cd           integer;
define vEjecuta_omnicanal   char(1);
define vPath_ominicanal     char(50);
define vSeparador           char(1);
define cCadena_omni    	char(3500); 

let v_codret            = "00000";
let v_sqlerr            = 0;
let v_isamerr           = 0; 
let vdia                = '01-01-1900';
let vhora               = "";
let cMensaje            = 'PROCESO EXITOSO';
let pUsuario            = user;
let pEmpresa            = '001';
let vtexto_select       = "";
let vPath               = ""; 
let cCadena             = "";
let cCadenadb2          = "";
let vNomarch            = "";
let vNomarchdb2         = "";
let vfecha_hoy          = "";
let vLargoCadena        = 0;
let vConteo             = 0;
let vfecha_hoy2         = '01-01-1900';
let vf_ultinsercion     = '01-01-1900';
let vCatalogo           = "";
let vf_ultactualiza     = '01-01-1900';
let vEjecutarProceso    = '';
let cUPD                = 'U';
let cINS                = 'I';

let i_numerociudad		= 0;
let i_numerocolonia		= 0;
let c_nombrezona		= '';
let c_poblacionzona		= '';
let c_municipiozona		= '';
let i_codigopostalzona	= 0;
let c_planozona		    = '';
let c_rumbozona		    = '';
let i_supervisorzona	= 0;
let i_choferzona		= 0;
let i_jefegrupozona		= 0;
let i_gerentezona		= 0;
let i_abogadozona		= 0;
let c_marcaencuesta30dias = '';
let i_numerocalle		= 0;
let i_numerocasa		= 0;
let c_marcaunidadhabitacional = '';
let i_numerodivisioncobranzas = 0;
let i_claveabogado		= 0;
let i_ciudadcobranzas	= 0;
let i_numerocobranzas	= 0;
let c_clavearagon		= '';
let i_centro		    = 0;
 
let i_pais               = 0;
let i_estado             = 0;
let i_ciudad             = 0;
let c_nombreciudad       = ''; 
let i_numerociudad_2     = 0;
let c_localidad          = ''; 
let i_tipociudad         = 0;
let dFecha_hoy           = date(1);
let cUsr_modifica        = '';
let iExiste_col          = 0;
let iExiste_cd           = 0;
let vEjecuta_omnicanal   = '';
let vPath_ominicanal     = '';
let vSeparador           = '|';
let cCadena_omni         = '';  

  --SET DEBUG FILE TO "/ifxsif01/macf/generareplica_catdomssuc.out";
  --TRACE ON;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;

	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
        VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, 'ERROR', 0, pUsuario, vdia, vhora);

         return v_codret;

	 end if;
      

      
   end exception;
   
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
   select valor into vEjecutarProceso
     from bdinteg:si_param_dom
    where empresa = pEmpresa and cod_param = 25;
   
   if vEjecutarProceso = 'S' then 
       --Generales 
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
    
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', '11111', 'PROCESO INICIALIZADO', 0, pUsuario, vdia, vhora);
    
       select valor into vPath 
         from bdinteg:si_param_dom 
        where empresa = pEmpresa and cod_param = 24;
    
        --select fecha_hoy into vfecha_hoy2 from bdinteg:si_fechas;
        --select to_char(fecha_hoy, "%Y%m%d") into vfecha_hoy 
        --  from bdinteg:si_fechas;

        SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d"), DBINFO('utc_to_datetime', sh_curtime)::DATE
		INTO vfecha_hoy, dFecha_hoy
        from sysmaster:sysshmvals;
        
		--LET dFecha_hoy = MDY('02','08','2023');  --- SOLO TEST MACF
		--LET vfecha_hoy = '20230208';  --- SOLO TEST MACF
		
        ---- INICIO INSERTS SI_CATZONAS
        let vCatalogo  	= 'si_catzonas';
        let vNomarch 	= 'ins_catzonas_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catzonas_db2_' || vfecha_hoy;

        select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
         where catalogo = vCatalogo
           and tipo_operacion = cINS;
    
        --let vtexto_catzonas = to_char(vf_ultins_catzonas) || ' - ' ||to_char(vf_ultins_ciudades) || ' - ' ||vNomarch;
        --insert into si_bitacora_dom  (mensaje, user_insert, fecha_insert) values(vf_ultins_catzonas, pUsuario, vdia);
    
        foreach with hold
          SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechains)} 'INSERT INTO public.catzonas values(' ||
                  numerociudad || "," || numerocolonia || ",'" || trim(replace(replace(nombrezona,'"',''''),"'", "")) ||  "','" || nvl(trim(replace(poblacionzona,"'", "")), '')  || "','"  || 
                  nvl(trim(replace(municipiozona,"'", "")), '')  || "'," || nvl(codigopostalzona, 0) || ",'" || nvl(planozona, '') || "','" || 
                  nvl(trim(rumbozona),'') || "'," || nvl(supervisorzona,0) || "," || nvl(choferzona,0) || "," || 
                  nvl(jefegrupozona,0) || "," || nvl(gerentezona,0) || "," || nvl(abogadozona,0) || ",'" || nvl(marcaencuesta30dias, '') 
                  || "'," || nvl(numerocalle, 0) || "," || nvl(numerocasa, 0) || ",'" || nvl(marcaunidadhabitacional, '') || 
                  "'," || nvl(numerodivisioncobranzas,0) || "," || nvl(claveabogado,0) || "," || nvl(ciudadcobranzas,0) || "," || 
                  --nvl(numerocobranzas,0) || ",'" || nvl(clavearagon, '') || "'," || nvl(centro, 0) || ');',
				  nvl(numerocobranzas,0) || ",'" || 1 || "'," || nvl(centro, 0) || ');',
                  numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para inserciÃÂ³n (23 campos)
				  nvl(trim(replace(poblacionzona,"'", '')), ''), 
				  nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				  nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				  nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				  nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				  nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				  --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
				  nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  

				  INTO vtexto_select,
				  i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				  c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				  i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				  i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica		 				  
			  
          FROM bdinteg:si_catzonas
          WHERE f_inserta >= vf_ultinsercion
            AND usr_modifica <> 'SYSCARTERA'
	        AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
     if nvl(vtexto_select, '') <> '' then
		    let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
				  System cCadena;
				  let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
				elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
				 System cCadena;
				 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				 System cCadenadb2;
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
				
				select count(*) into iExiste_col
				  from bdinteg:si_catzonas_suc
				  where numerociudad = i_numerociudad and numerocolonia = i_numerocolonia;
				  
				
				if iExiste_col <= 0 then
					begin; 
					  insert into bdinteg:si_catzonas_suc(numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, planozona, 
						rumbozona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona, marcaencuesta30dias, numerocalle, numerocasa, 
						marcaunidadhabitacional, numerodivisioncobranzas, claveabogado, ciudadcobranzas, numerocobranzas, clavearagon, centro, f_inserta,
						usr_modifica) 
					  values(i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
							 c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
							 i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
							 i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, dFecha_hoy, 
							 cUsr_modifica);
				   commit; 
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
          else
              exit foreach;
          end if;
		  
		   
		
    
        end foreach;
				
        if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
        end if;   ----  FIN INSERTS SI_CATZONAS


       ---- INICIO UPDATES SI_CATZONAS
       let vCatalogo  	= 'si_catzonas';
       let vNomarch 	= 'upd_catzonas_' || vfecha_hoy;   
	   let vNomarchdb2 	= 'upd_catzonas_db2_' || vfecha_hoy;   
       let vConteo = 0;
       let vLargoCadena = 0;  --- temporary 
       let vtexto_select = '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
       
       foreach with hold
            SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechamodif)} 'UPDATE public.catzonas SET nombrezona =''' || trim(replace(replace(nombrezona,'"',''''),"'", "")) || '''' || ', poblacionzona = ''' || 
                    nvl(trim(replace(poblacionzona,"'", "")), '') || "'" || ', municipiozona = ''' || nvl(trim(replace(municipiozona,"'", "")), '') || "'" || ', codigopostalzona = '
                    || nvl(codigopostalzona, 0) || ', planozona = ' || "'" || nvl(trim(planozona), '') || "'" || ', rumbozona = ' || "'"
                    || nvl(trim(rumbozona), '') || "'" || ', supervisorzona = ' || nvl(supervisorzona,0)  || ', choferzona = ' || nvl(choferzona,0) 
                    || ', jefegrupozona = ' || nvl(jefegrupozona,0) || ', gerentezona = ' || nvl(gerentezona,0) || ', abogadozona = ' || nvl(abogadozona,0)
                    || ', marcaencuesta30dias = ' || "'" || nvl(marcaencuesta30dias,'') || "'" || ', numerocalle = ' || nvl(numerocalle,0)
                    || ', numerocasa = ' || nvl(numerocasa,0) || ', marcaunidadhabitacional = ' || "'" || nvl(marcaunidadhabitacional,'') || "'"
                    || ', numerodivisioncobranzas = ' || nvl(numerodivisioncobranzas,0) || ', claveabogado = ' || nvl(claveabogado,0) || 
                    ', ciudadcobranzas = ' || nvl(ciudadcobranzas,0) || ', numerocobranzas = ' || nvl(numerocobranzas, 0) ||
                    --', clavearagon = ' || "'" || nvl(trim(clavearagon), '') || "'" || ', centro = ' || nvl(centro,0) ||
					', clavearagon = ' || "'" || 1 || "'" || ', centro = ' || nvl(centro,0) ||
                    ' WHERE numerociudad = ' || numerociudad || ' AND numerocolonia = ' || numerocolonia || ';', 
					 numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para actualizaciÃÂ³n (23 campos)
				    nvl(trim(replace(poblacionzona,"'", '')), ''), 
				    nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				    nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				    nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				    nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				    nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				    --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
					nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  
				
					INTO vtexto_select,
                    i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				    c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				    i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				    i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas, i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica
            FROM bdinteg:si_catzonas
            WHERE f_modifica >= vf_ultactualiza
            AND usr_modifica <> 'SYSCARTERA' 
			AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
		    if nvl(vtexto_select, '') <> '' then
				let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
				elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				-- MACF Para update  en nueva tabla
				   begin;
                       update bdinteg:si_catzonas_suc set nombrezona= c_nombrezona, poblacionzona= c_poblacionzona, municipiozona= c_municipiozona,
  					      codigopostalzona= i_codigopostalzona, planozona= c_planozona, rumbozona= c_rumbozona, supervisorzona= i_supervisorzona, 
						  choferzona= i_choferzona, jefegrupozona= i_jefegrupozona, gerentezona= i_gerentezona, abogadozona= i_abogadozona, 
						  marcaencuesta30dias= c_marcaencuesta30dias, numerocalle= i_numerocalle, numerocasa= i_numerocasa, marcaunidadhabitacional= c_marcaunidadhabitacional,
						  numerodivisioncobranzas= i_numerodivisioncobranzas, claveabogado= i_claveabogado, ciudadcobranzas= i_ciudadcobranzas,
						  numerocobranzas= i_numerocobranzas, clavearagon= c_clavearagon, centro= i_centro
                        where  numerociudad= i_numerociudad and numerocolonia= i_numerocolonia; 
                   commit;
				   
				-- MACF Para update  en nueva tabla
             else
                exit foreach;
             end if;                  
       end foreach;
       
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; 
       ---- FIN UPDATES SI_CATZONAS

  

      ----- INICIO INSERTS SI_CIUDADES   
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'ins_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
      
       foreach with hold
          select 'INSERT INTO public.iciudades values(''' || '001' || ''',''' || pais || ''',''' || estado || ''',''' || ciudad || ''',''' ||
                 --nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || nvl(tipo_ciudad,0) || ');',
				 nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || '1' || ');',
                 --pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, tipo_ciudad
				 pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1
				 
				 INTO vtexto_select,
                      i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad
          from bdinteg:si_ciudades
          where fecha_insert >= vf_ultinsercion
		    and nvl(d_ciudad,'') <> '' and nvl(elegir,'') = ''
		  
          
          if nvl(vtexto_select, '') <> '' then
              let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              end if;
          
              --let vLargoCadena = length(cCadena);
              --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
              --let vLargoCadena = 0;
			  
			  select count(*) into iExiste_cd
			    from bdinteg:si_ciudades_suc
				where empresa = '001' and codigo_pais = i_pais and codigo_estado = i_estado and codigo_ciudad = i_ciudad;
			 
             if iExiste_cd <= 0 then
				  begin;
					   insert into bdinteg:si_ciudades_suc(empresa, codigo_pais, codigo_estado, codigo_ciudad, nombre, numerociudad, localidad, tipo_ciudad)
					   values(pEmpresa, i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad);
				  commit;
			 end if;
			  
          else
              exit foreach;
          end if;
      
       end foreach;
    
       if nvl(vtexto_select, '') <> '' then 
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;  ----- FIN  INSERTS SI_CIUDADES
   

       ----  INICIO UPDATE SI_CIUDADES
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'upd_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
        
        foreach with hold
            SELECT 'UPDATE public.iciudades SET nombre = ' || "'" || nombre || "'" || ', numerociudad = ' || ciudad_coppel || 
                   --', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = ' || nvl(tipo_ciudad,0)  ||
				   ', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = 1' ||
                   ' WHERE codigo_estado = ' || estado || ' AND numerociudad = ' || ciudad_coppel || ';',
				   --nombre, ciudad_coppel, nvl(localidad_banxico,''), tipo_ciudad, estado
				   nombre, ciudad_coppel, nvl(localidad_banxico,''), 1, estado
				   INTO vtexto_select,
				   c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad, i_estado
				   
            FROM  bdinteg:si_ciudades
            WHERE f_modifica >= vf_ultactualiza
              AND ciudad_coppel <> 0
			  AND nvl(d_ciudad,'') <> '' AND nvl(elegir,'') = ''
        
             if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                    
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				
				begin;
				  update bdinteg:si_ciudades_suc 
                     set nombre= c_nombreciudad, numerociudad= i_numerociudad_2, localidad= c_localidad, tipo_ciudad= i_tipociudad
				   where codigo_estado= i_estado and numerociudad = i_numerociudad_2; 
                commit;				
				
             else
                exit foreach;
             end if;   
        
        end foreach;
    
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; ---- FIN UPDATE SI_CIUDADES

 
       ----INSERTS SI_CATCIUDADES      
        let vCatalogo  	= 'si_catciudades';
        let vConteo 	= 0;
        let vNomarch 	= 'ins_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
         
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
         
      foreach with hold      
            select 'INSERT INTO public.catciudades values(' ||
             numerociudad || ',''' || trim(nombreciudad) || ''',''' || nvl(trim(inicialciudad),'') || ''','  || nvl(tasainteres,0) || ',' || nvl(numeroestado,0) || ',''' ||
             nvl(trim(inicialestado),'') || ''',' || nvl(salariominimo,0) || ',' || nvl(gerentezona,0) || ',' || nvl(regioncobranzas,0) || ',' || nvl(ivaciudad,0) || ',''' || 
             nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || ''',' || nvl(unificaciudadesinformes,0) || ',' || nvl(unificaciudadescobranzas,0) || ',' || nvl(gerentecobranzas,0) || ',''' ||
             nvl(trim(generajobcarteratienda),'') || ''',''' || nvl(trim(inicialcredito),'') || ''',''' || nvl(regionestadodecuenta, '') || ''',' || nvl(tasainteresropa,0) || ',' ||
             nvl(tasainteresmueble12,0) || ',' || nvl(tasainteresmueble18,0) || ',' || nvl(tasainteresprestamo,0) || ',' || nvl(tasainterescelular1,0) || ',' || 
             nvl(tasainterescelular2,0) || ',''' ||  nvl(tipozona, '')  || ''',''' || nvl(fechaultimaactualizacion, '') || ''');' INTO vtexto_select
            from bdinteg:si_catciudades
            where f_inserta >= vf_ultinsercion
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;    
    
       if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ----INSERTS SI_CATCIUDADES
      
   
       ---- INICIO UPDATE SI_CATCIUDADES
        let vCatalogo  = 'si_catciudades';
        let vConteo = 0;
        let vNomarch = 'upd_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'upd_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
         
      foreach with hold     
            SELECT 'UPDATE public.catciudades set nombreciudad = ' || "'" || trim(nombreciudad) || "'" || ',inicialciudad = ' 
                   || "'" || nvl(trim(inicialciudad),'') || "'" || ', tasainteres = ' || nvl(tasainteres,0) || ',numeroestado = ' || nvl(numeroestado,0) ||
                   ',inicialestado = ' || "'" || nvl(inicialestado,'') || "'" || ',salariominimo = ' || nvl(salariominimo,0) || ',gerentezona = ' 
                   || nvl(gerentezona,0) || ',regioncobranzas = ' || nvl(regioncobranzas,0) || ',ivaciudad = ' || nvl(ivaciudad,0) || ', antiguedadciudad = '
                   || "'" || nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || "'" || ', unificaciudadesinformes = ' || nvl(unificaciudadesinformes,0) || 
                   ',unificaciudadescobranzas = ' || nvl(unificaciudadescobranzas,0) || ', gerentecobranzas = ' || nvl(gerentecobranzas,0) ||
                   ',generajobcarteratienda = ' || "'" || nvl(trim(generajobcarteratienda),'') || "'" || ',inicialcredito = ' || "'" ||
                    nvl(trim(inicialcredito),'') || "'" || ', regionestadodecuenta = ' || "'" || nvl(regionestadodecuenta, '') || "'" || ',tasainteresropa = '
                   || nvl(tasainteresropa,0) || ', tasainteresmueble12 = ' || nvl(tasainteresmueble12,0) || ',tasainteresmueble18 = ' || 
                   nvl(tasainteresmueble18,0) || ', tasainteresprestamo = ' || nvl(tasainteresprestamo,0) || ', tasainterescelular1 = ' ||
                   nvl(tasainterescelular1,0) || ', tasainterescelular2 = ' || nvl(tasainterescelular2,0) || ', tipozona = ' || "'" ||
                   nvl(tipozona, '') || "' WHERE numerociudad = " || numerociudad || ' AND numeroestado = ' || numeroestado || ';' INTO vtexto_select
             from bdinteg:si_catciudades
            where fechaultimaactualizacion >= vf_ultactualiza
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				    System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				   System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if;   ---- FIN UPDATE SI_CATCIUDADES
        
     
        ---- INICIO INSERT SI_CATCALLES 
        let vCatalogo  = 'si_catcalles';
        let vConteo = 0;
        let vNomarch = 'ins_catcalles_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catcalles_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
       
       foreach with hold     
          select {+ INDEX (bdinteg:si_catcalles idx_catcalles_fechains)} 'INSERT INTO public.catcalles values(' ||
                 numerocalle || ',''' || trim(nombrecalle) || ''');'  INTO vtexto_select
           from bdinteg:si_catcalles
          where f_inserta >= vf_ultinsercion
    
          if nvl(vtexto_select, '') <> '' then
            let vConteo = vConteo + 1;
            if  vConteo = 1 then
                let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            elif vConteo > 1 then
                let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            end if;
            --let vLargoCadena = length(cCadena);                                                         -- this temporary
            --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);  
            --let vLargoCadena = 0;                                                                       
          else
            exit foreach;
          end if;
            
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then    
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ---- FIN INSERTS SI_CATCALLES
    
 
	   ------------------------------------------  NUEVA DESCARGA CATDOMS PARA OMNICANAL 2022-11-17
	   select valor into vEjecuta_omnicanal
         from bdinteg:si_param_dom
        where empresa = pEmpresa and cod_param = 31;  
	   
	   
	   IF vEjecuta_omnicanal = 'S' THEN
	      
		  --LET vNomarch = 'catalogo_catzonas.txt';
		  LET vNomarch = 'catalogo_catzonas_' || vfecha_hoy || '.txt';

	      select valor into vPath_ominicanal
            from bdinteg:si_param_dom
           where empresa = pEmpresa and cod_param = 30;  

		 LET cCadena_omni = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT  a.numerociudad, a.numerocolonia, ' 
  || 'trim(replace(a.nomzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end, case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado '
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado '
  || 'and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and b.d_ciudad = d.d_ciudad '
  || 'and (d.ciudad_coppel > 0 AND ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'UNION '
  || 'SELECT a.numerociudad, a.numerocolonia, trim(replace(a.nomzona_spmx,chr(39),''' || ''')),' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end,case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado ' 
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado and d.estado = ''' || '09' || ''' and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and (d.ciudad_coppel > 0 and d.ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'and nvl(a.nomzona_spmx,''' || ''') <> ''' || ''' and nvl(a.pobzona_spmx, ''' || ''') <> ''' || ''' and nvl(a.mnpio_spmx, ''' || ''') <> ''''" >' || trim(vPath_ominicanal) ||'corre_si_catzonas.sql'; 

 
         SYSTEM TRIM(cCadena_omni);
         let cCadena_omni = '';
   
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	     --------------------  CIUDADES
		 LET vNomarch = 'catalogo_iciudades_' || vfecha_hoy || '.txt';
	     LET cCadena = '';  
	 
	     LET cCadena = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT ''' || '001' || ''
	     || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
         || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel > 0 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado <> ''' || '09' || ''' UNION '
	     || 'SELECT ''' || '001' || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
	     || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel <> 6564 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado = ''' || '09' || '''" >' || trim(vPath_ominicanal) ||'corre_si_ciudades.sql';
	 
	     SYSTEM TRIM(cCadena);
	     let cCadena = '';
  
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);  

	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	   END IF;
 
       ----REGISTRO EN BITACORA
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
       
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, cMensaje, 0, pUsuario, vdia, vhora);
   else
     let v_codret = '00OFF';
   end if;
   
  RETURN v_codret;
END;

END PROCEDURE;