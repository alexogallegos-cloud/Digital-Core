CREATE PROCEDURE "informix".sp_sd_ri_cb ( pfInicio date )
RETURNING CHAR(5);

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--PeticiÃÂ³n: RQI 28 194 - Proceso de automatizaciÃÂ³n de RI a demanda
	--Modificado por: 98769022 Miguel Alejandro SÃÂ¡nchez Mojica
	--Fecha modificaciÃÂ³n: 18/07/2019
	--ModificaciÃÂ³n: Se agregan validaciones para la nueva recompensa a demanda y se modifica la generaciÃÂ³n del Folio SUC.
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--PeticiÃÂ³n: RQM 10 1287 - AplicaciÃÂ³n de monto variable de CashBack
	--Modificado por: 98769022 Miguel Alejandro SÃÂ¡nchez Mojica
	--Fecha modificaciÃÂ³n: 13/12/2019
	--ModificaciÃÂ³n: Se agrega el campo monto_variable y una validaciÃÂ³n cuando el #transacciÃÂ³n es 0, aplicar la recompensa por monto variable ingresado en el layout ri_c_altaarchivos_DDMMAAAA.txt.
	--BD: bdicred
	-------------------------------------------------------------------------------------
------------------------------------------------------------------------------>
--// Inicializa de Variables
------------------------------------------------------------------------------>

	DEFINE cCodRet					CHAR(5); --> Variables de codigos de retorno  
	DEFINE sql_err					INTEGER;
	DEFINE isam_err					INTEGER;
	DEFINE CMensaje					CHAR(80);
	DEFINE wBegin					CHAR (1);
	DEFINE v_pky_id_altarecompensa	INTEGER;	DEFINE v_activo					SMALLINT;
	DEFINE v_fecha_inicio			DATE;
	DEFINE v_fecha_final			DATE;
	DEFINE v_fky_id_tipo_recompensa	INTEGER;	
	DEFINE v_carga_archivo			INTEGER;
	DEFINE v_fky_id_archivo			INTEGER;
	DEFINE v_fky_id_campana_inicio	INTEGER;
	DEFINE v_fky_id_campana_fin		INTEGER;
	DEFINE v_id_tipo_transacc		CHAR (2);
	DEFINE v_pky_id_rangorecompensa	INTEGER;	DEFINE v_fky_id_rangorecompensa	INTEGER;
	DEFINE v_monto_op_inicial		MONEY;
	DEFINE v_monto_op_final			MONEY;
	DEFINE v_total_recompensas		INTEGER;
	DEFINE v_total_redenciones		INTEGER;
	DEFINE v_numero_op_inicial		CHAR(2);
	DEFINE v_numero_op_final		CHAR(2);
	DEFINE v_id_periodo				INTEGER;
	DEFINE v_monto_recompensa		CHAR(10);
	DEFINE v_fecha_ejecucion		DATE;
	DEFINE v_num_credito			CHAR(20);	DEFINE v_num_credito_redencion	CHAR(20);	DEFINE v_tot_transacc			INTEGER;	DEFINE v_monto_transacc			DECIMAL (18,2);	DEFINE v_fecha_mov				DATE;
	DEFINE v_transacc_suc			CHAR (4);
	DEFINE v_monto_variable			INTEGER;	-- RQM 10 1287
	DEFINE v_status_cred			CHAR (2);	DEFINE vlFechaHoy				DATE;
	DEFINE vlFecha					DATE;
	DEFINE v_cuenta					CHAR(20);
-- ************************************************************************ 
	DEFINE v_Display 				CHAR(50);
	DEFINE v_producto				CHAR(4);
	DEFINE v_transaccion			CHAR(4);
	DEFINE v_numcte					CHAR(20);
	DEFINE vFechaCorte				DATE;
	DEFINE v_prod_activo			INTEGER;
	DEFINE v_tipo_prod				INTEGER;
	DEFINE v_inactivos				INTEGER;
	DEFINE v_ri_a_demanda			INTEGER;
-- ************************************************************************ 

-- ***************************************************************** Temporales	
	DEFINE v_tot_op					INTEGER;	DEFINE v_ctrl_transacc			INTEGER;
	DEFINE v_FolioSUC				CHAR(16);
	DEFINE v_fecha_folio			CHAR(16);
	DEFINE v_cont_periodo			SMALLINT;
	DEFINE v_tot_op_periodo			SMALLINT;
-- ************************************************************* principalrefer
	DEFINE CodRet					CHAR (5); 
	DEFINE g_Remanente				MONEY(14,2);
	DEFINE g_IntMoraCob				MONEY(14,2);
	DEFINE g_IntVencCob				MONEY(14,2);
	DEFINE g_CapVencCob				MONEY(14,2);
	DEFINE g_IntVigCob				MONEY(14,2);
	DEFINE g_CapVigCob				MONEY(14,2);
	DEFINE g_Impuesto				MONEY(14,2);
	DEFINE g_Comision				MONEY(14,2);	
	DEFINE g_Seguro					MONEY(14,2);
	DEFINE vlidTable				CHAR(40);
	DEFINE ddate					DATE;
	DEFINE cMtoVen					DECIMAL(18,2);
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
	LET cMtoVen					=0;
	LET ddate = DATE(1);
	LET cCodRet = ''; --> Variables de codigos de retorno  
	LET sql_err = 0 ; 
	LET isam_err = 0 ; 
	LET CMensaje = ''; 
	LET wBegin = ''; 
	LET v_pky_id_altarecompensa = 0 ; --> sd_ri_altarecompensa
	LET v_activo = 0 ; 
	LET v_fecha_inicio = ''; 
	LET v_fecha_final = ''; 
	LET v_fky_id_tipo_recompensa = 0 ; 
	LET v_carga_archivo = 0 ; 
	LET v_fky_id_archivo = 0 ;
	LET v_fky_id_campana_inicio = 0 ;
	LET v_fky_id_campana_fin = 0 ;
	LET v_id_tipo_transacc = '';
	LET v_pky_id_rangorecompensa = 0 ; --> sd_ri_rangorecompensa
	LET v_fky_id_rangorecompensa = 0 ;
	LET v_monto_op_inicial = ''; 
	LET v_monto_op_final = ''; 
	LET v_total_recompensas = 0; 
	LET v_total_redenciones = 0; 
	LET v_numero_op_inicial = ''; 
	LET v_numero_op_final = ''; 
	LET v_id_periodo = 0 ; 
	LET v_monto_recompensa = '';
	LET v_fecha_ejecucion = ''; 
	LET v_num_credito = ''; --> sd_ri_archivos 
	LET v_tot_transacc = 0 ; --> bdicred:sd_movhis
	LET v_fecha_mov = '';
	LET v_transacc_suc = '';
	LET v_status_cred = ''; --> sd_maecred
-- **************************************************************************** Generales
	LET v_ctrl_transacc = 0 ;
	LET v_FolioSUC = '';
	LET v_fecha_folio = '';
	LET v_cont_periodo = 0 ;
	LET v_tot_op_periodo = 0 ;
	LET v_ri_a_demanda = 0;
	LET vlidTable = '' ;
	LET vlFechaHoy = DATE(1);	
	LET vlFecha = DATE(1);
	
	BEGIN
		ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET cCodRet = sql_err;
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN cCodRet;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		-- ROLLBACK WORK;
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

	LET cCodRet	= '';
	LET CodRet	= '';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
	
	-- SET DEBUG FILE TO "/informix/SD/RI/sp_sd_ri_cb.out";
    -- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN WORK;
   
--  ******************************************************** ActualizaciÃÂ³n de CampaÃÂ±as SIN VIGENCIA
	
	SELECT	fecha_hoy 
	INTO	vlFechaHoy 
	FROM	"informix".sd_fechas
	WHERE	empresa = '001';	

	FOREACH WITH HOLD
		
		SELECT	pky_id_altarecompensa, 
				fecha_final,
				fecha_ejecucion
		INTO	v_pky_id_altarecompensa, 
				v_fecha_final,
				v_fecha_ejecucion
		FROM	bdicred:sd_ri_altarecompensa 
		WHERE 	activo = 1
		
		IF (v_fecha_final < TODAY) and (pfInicio = TODAY) and (v_fecha_ejecucion IS NOT NULL) THEN
				
			UPDATE	bdicred:"informix".sd_ri_altarecompensa 
			SET		activo = 0, fecha_ejecucion = vlFechaHoy 
			WHERE	pky_id_altarecompensa = v_pky_id_altarecompensa;		

		END IF;

	END FOREACH;
	
--  ***************************************************************** ValidaciÃÂ³n de CampaÃÂ±as ACTIVAS
	
	SELECT 	COUNT (*)
	INTO	v_activo
	FROM	bdicred:sd_ri_altarecompensa 
	WHERE	activo = 1
	AND 	fecha_ejecucion IS NULL;	-- RQI 28 194				  

	LET v_activo = v_activo;
	
	IF vlFechaHoy <> pFInicio THEN 
		LET vlFechaHoy = pfInicio;
	END IF;
	
--  ******************************************************** ObtenciÃÂ³n de CampaÃÂ±as CASH BACK ACTIVAS
	FOREACH WITH HOLD
	--> MR
		SELECT 	pky_id_altarecompensa,   
				fecha_inicio,   
				fecha_final,   
				fky_id_tipo_recompensa,   
				carga_archivo,   
				fky_id_archivo,   
				fky_id_campana_inicio,   
				fky_id_campana_fin,   
				id_tipo_transacc
		INTO 	v_pky_id_altarecompensa, 
				v_fecha_inicio, 
				v_fecha_final, 
				v_fky_id_tipo_recompensa, 
				v_carga_archivo, 
				v_fky_id_archivo, 
				v_fky_id_campana_inicio, 
				v_fky_id_campana_fin, 
				v_id_tipo_transacc
		FROM 	bdicred:sd_ri_altarecompensa 
		WHERE 	activo = 1 -- CampaÃÂ±a activa 
		AND 	fecha_ejecucion IS NULL			-- RQI 28 194
		
		IF v_carga_archivo = 1 THEN --> ValidaciÃÂ³n por carga de Archivo
-- 	***************************************** FOREACH por rango de recompensa por Carga de Archivo
			FOREACH WITH HOLD 
			--> PR			
				 SELECT	pky_id_rangorecompensa,   
						monto_op_inicial,   
						monto_op_final,   
						total_recompensas,   
						total_redenciones,   
						numero_op_inicial,   
						numero_op_final,   
						id_periodo,  
						monto_recompensa
				   INTO	v_pky_id_rangorecompensa, 
						v_monto_op_inicial, 
						v_monto_op_final, 
						v_total_recompensas, 
						v_total_redenciones, 
						v_numero_op_inicial, 
						v_numero_op_final, 
						v_id_periodo, 
						v_monto_recompensa
				   FROM	bdicred:sd_ri_rangorecompensa 
				  WHERE	activo = 1 
				    AND	fky_id_altarecompensa = v_pky_id_altarecompensa
				   
				call monthadd (vlFechaHoy, - v_id_periodo) returning ddate;
				LET vlFecha = vlFechaHoy;
					
				IF day(vlFecha) <= 20 then
					call monthadd (vlFechaHoy, - 1) returning vlFecha;
				END IF;
				
				-- RQI 28 194 Inicio
				IF 	v_id_periodo = 0 and v_monto_op_inicial = 0 and v_monto_op_final = 0 and v_numero_op_inicial = 0 and v_numero_op_final = 0 THEN
					
					-- Contar las recompensas a demanda
					LET v_ri_a_demanda = v_ri_a_demanda + 1;
														
					FOREACH WITH HOLD
					
						-- Consulta CrÃÂ©dito Participante
						SELECT 	num_credito, monto_variable							-- RQM 10 1287
						INTO 	v_num_credito, v_monto_variable						-- RQM 10 1287
						FROM 	bdicred:sd_ri_archivos 
						WHERE 	pky_id_archivo = v_fky_id_archivo
						AND 	fky_id_altarecompensa = v_pky_id_altarecompensa
						AND 	recompensado <> 1
							 
						-- Consulta para validar STATUS del producto   
						SELECT 	NVL(a.status_cred,''), a.num_producto,NVL(maes.monto_vencido + maes.mto_venc_trasp,0)
						INTO 	v_status_cred, v_producto,cMtoVen
						FROM 	bdicred:sd_maecred a
						INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito) 
						WHERE 	a.empresa = '001'
						AND 	a.num_credito = v_num_credito;
						
						-- se agrega condicion para buscar si el producto es participante
						LET v_tipo_prod = 0;
						LET v_prod_activo = 0;
						LET v_transaccion = '';
						let v_producto = v_producto;
						SELECT	pky_id_tipo_producto, 
								activo, 
								transaccion
						INTO 	v_tipo_prod, -- para validar si el produto es TC o PP
								v_prod_activo, -- para validar si el producto esta activo para participar
								v_transaccion -- para validar la transacciÃÂ³n correspondiente
						FROM 	bdicred:sd_ri_cat_productos
						WHERE 	producto = v_producto; 
						
						IF v_status_cred IN ('AA','E1') AND cMtoVen = 0 AND v_prod_activo = 1 THEN
																		
							IF v_total_redenciones < v_total_recompensas THEN	
							
								--LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);									
								--LET v_FolioSUC = trim(v_fecha_folio)||v_pky_id_altarecompensa||v_pky_id_rangorecompensa||v_fky_id_tipo_recompensa;
								LET v_FolioSUC = trim(v_num_credito)||substr((current year TO day),9,2)||substr((current year TO day),6,2);	-- RQI 28 194
								LET v_fky_id_tipo_recompensa = v_fky_id_tipo_recompensa;
								
								IF v_fky_id_tipo_recompensa = 1 THEN 

									-- RQM 10 1287 Inicio
									-- Valida si la transacciÃÂ³n es de CARGO DIRECTO, el monto de la recompensa es el ingresado en el archivo
									IF v_id_tipo_transacc = 0 THEN 
										LET v_monto_recompensa = v_monto_variable;
									END IF;
									-- RQM 10 1287 Fin

									IF v_tipo_prod = 1 THEN --- Bloque para CREDITO
									
										--let v_Display = 'Entra en OPERACION SI MONETARIA';
										--let v_Display = 'Entra en "principalrefer" para CREDITO';
										CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, v_transaccion, 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
										RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
										
									END IF;
								ELSE
									--let v_Display = 'Entra en OPERACION NO MONETARIA';
									LET CodRet = '000';
									
								END IF;	
								
								IF CodRet ='000' THEN 
								
									UPDATE 	bdicred:"informix".sd_ri_archivos 
									SET 	recompensado = 1, total_op = 0, fecha_redencion = vlFechaHoy 
									WHERE 	num_credito = v_num_credito 
									AND 	pky_id_archivo = v_fky_id_archivo 
									AND 	fky_id_altarecompensa = v_pky_id_altarecompensa; -- Actualizar crÃÂ©dito recompensado.
										
									INSERT INTO bdicred:"informix".sd_ri_redencion VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, 0, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n abonada
									
									LET v_total_redenciones = v_total_redenciones + 1;
									
								END IF;
							ELSE 		
								--let v_Display = 'Entra en REDENCIÃ?N AGOTADA';									
								INSERT INTO bdicred:"informix".sd_ri_redencionagotada 
								VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, 0, v_num_credito, 0, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas									
								
							END IF;
							
							UPDATE 	bdicred:"informix".sd_ri_rangorecompensa 
							SET 	total_redenciones = v_total_redenciones, fecha_ejecucion = vlFechaHoy 
							WHERE 	fky_id_altarecompensa = v_pky_id_altarecompensa 
							AND 	pky_id_rangorecompensa = v_pky_id_rangorecompensa;
							
						ELSE			
							IF v_prod_activo = 0 THEN 
							
								LET v_inactivos = v_inactivos +1;	
								
							END IF; 
							
							CONTINUE FOREACH;
							
						END IF;
						
					END FOREACH;
					
					-- Inactiva la Recompensa inmediata
					UPDATE bdicred:"informix".sd_ri_altarecompensa SET activo = 0 
					WHERE pky_id_altarecompensa = v_pky_id_altarecompensa;
					
				-- RQI 28 194 Fin	
				ELIF v_id_periodo = 1 and v_ri_a_demanda = 0 AND ((day(vlFechaHoy) = 26 and month(vlFechaHoy) <> 12) OR (day(vlFechaHoy) = 27 and month(vlFechaHoy) = 12))	THEN -->> ValidaciÃÂ³n con un sÃÂ³lo periodo por Carga de Archivo -- RQI 28 194, RQM 10 1287						
					FOREACH WITH HOLD
						-- Consulta CrÃÂ©dito Participante
						SELECT 	num_credito
						INTO 	v_num_credito
						FROM 	bdicred:sd_ri_archivos 
						WHERE 	pky_id_archivo = v_fky_id_archivo
						AND 	fky_id_altarecompensa = v_pky_id_altarecompensa
						AND 	recompensado <> 1
							 
						-- Consulta para validar STATUS del producto   
						SELECT 	a.status_cred, a.num_producto, NVL(maes.monto_vencido + maes.mto_venc_trasp,0)
						INTO 	v_status_cred, v_producto,cMtoVen
						FROM 	bdicred:sd_maecred  a
						INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
						WHERE 	a.empresa = '001'
						AND 	a.num_credito = v_num_credito;

						-- Condicion para considerar Prestamos Personales
						IF nvl(v_status_cred,'') = '' THEN
							SELECT	NVL(a.status_cred,''), a.num_producto, a.numcte, a.fecha_apertura, NVL(maes.monto_vencido + maes.mto_venc_trasp,0)
							INTO	v_status_cred, v_producto, v_numcte, vFechaCorte, cMtoVen
							FROM	bdicred:sd_maecredcrd a
							INNER JOIN bdicred:sd_maesdoscrd maes ON (maes.num_credito = a.num_credito)
							WHERE	a.empresa = '001' 
							AND		a.num_credito = v_num_credito; 
						END IF;
							
						-- se agrega condicion para buscar si el producto es participante
						LET v_tipo_prod = 0;
						LET v_prod_activo = 0;
						LET v_transaccion = '';
						let v_producto = v_producto;
						SELECT	pky_id_tipo_producto, 
								activo, 
								transaccion
						INTO 	v_tipo_prod, -- para validar si el produto es TC o PP
								v_prod_activo, -- para validar si el producto esta activo para participar
								v_transaccion -- para validar la transaccion correspondiente
						FROM 	bdicred:sd_ri_cat_productos
						WHERE 	producto = v_producto; 

						IF v_status_cred IN ('AA','E1') AND cMtoVen = 0 and v_prod_activo = 1 THEN --> Se valida que el producto este activo
							IF v_tipo_prod = 1 THEN  -- Valida transacciones de TC o PP
								--let v_Display = 'Busca operaciones de TC';
								-- PAGO VENTANILLA
								IF ( v_id_tipo_transacc = '7' ) THEN 
									--let v_Display = 'Busca operaciones 7 = PAGO VENTANILLA';
									SELECT 	 num_pagos, monto_pagos	
									INTO 	 v_tot_transacc, v_monto_transacc
									FROM 	 bdicred:sd_indicador_cred_hist
									WHERE 	 empresa = '001' 
									AND 	 fecha = mdy(month(vlFecha), 20 , year(vlFecha))
									AND 	 num_credito = v_num_credito
									AND 	 monto_pagos >= v_monto_op_inicial
									AND 	 monto_pagos <= v_monto_op_final
									AND 	 num_pagos >= v_numero_op_inicial
									AND 	 num_pagos <= v_numero_op_final
									GROUP BY num_pagos, monto_pagos, fecha;
								END IF
								
								-- CARGO VENTANILLA 
								IF ( v_id_tipo_transacc = '8' ) THEN
									--let v_Display = 'Busca operaciones de TC 8 = CARGO VENTANILLA';
									SELECT 	 num_vtn, monto_vtn
									INTO 	 v_tot_transacc, v_monto_transacc
									FROM 	 bdicred:sd_indicador_cred_hist
									WHERE 	 empresa = '001' 
									AND 	 fecha = mdy(month(vlFecha), 20 , year(vlFecha))
									AND      num_credito = v_num_credito
									AND  	 monto_vtn >= v_monto_op_inicial
									AND 	 monto_vtn <= v_monto_op_final
									AND 	 num_vtn >= v_numero_op_inicial
									AND 	 num_vtn <= v_numero_op_final
									GROUP BY num_vtn, monto_vtn, fecha;
								END IF
								
								-- CARGO POS 
								IF ( v_id_tipo_transacc = '9' ) THEN 
									--let v_Display = 'Busca operaciones de TC 9 = CARGO POS';
									SELECT	 num_pos, monto_pos
									INTO	 v_tot_transacc, v_monto_transacc
									FROM	 bdicred:sd_indicador_cred_hist
									WHERE	 empresa = '001' 
									AND		 fecha = mdy(month(vlFecha), 20 , year(vlFecha))
									AND		 num_credito = v_num_credito
									AND 	 monto_pos >= v_monto_op_inicial
									AND 	 monto_pos <= v_monto_op_final
									AND 	 num_pos >= v_numero_op_inicial
									AND 	 num_pos <= v_numero_op_final
									GROUP BY num_pos, monto_pos, fecha;	
								END IF			
	
								-- CARGO ATM 							
								IF ( v_id_tipo_transacc = '10' ) THEN 
									--let v_Display = 'Busca operaciones de TC 10 = CARGO ATM';
									SELECT 	 num_atm, monto_atm
									INTO 	 v_tot_transacc, v_monto_transacc
									FROM 	 bdicred:sd_indicador_cred_hist
									WHERE 	 empresa = '001' 
									AND 	 fecha = mdy(month(vlFecha), 20 , year(vlFecha))
									AND 	 num_credito = v_num_credito
									AND 	 monto_atm >= v_monto_op_inicial
									AND 	 monto_atm <= v_monto_op_final
									AND 	 num_atm >= v_numero_op_inicial
									AND 	 num_atm <= v_numero_op_final
									GROUP BY num_atm, monto_atm, fecha;
								END IF;		
							ELSE
								--let v_Display = 'Busca operaciones de PP';
											IF ((select count (*) 								
												from bdicheq:sc_maechq where empresa = '001' 
												and num_cte = v_numcte
												and producto = '2000' and status_cta = '1') >= 1) THEN
												
												select  cuenta	
												INTO v_cuenta
												from bdicheq:sc_maechq where empresa = '001' 
												and num_cte= v_numcte
												and producto = '2000' and status_cta = '1';
																						
												SELECT cumplio_convenio
												INTO v_tot_transacc
												FROM bdicred:sd_indicador_cred_crd_hist
												WHERE empresa = '001' 
												AND fecha_insert = mdy(month(vlFecha), DAY(vFechaCorte) , year(vlFecha))
												AND num_credito = v_num_credito
												GROUP BY cumplio_convenio,fecha_insert;	
											END IF;
								---LET v_tot_transacc = v_tot_transacc;
							END IF

							IF v_tot_transacc > 0 THEN 								
									IF v_total_redenciones < v_total_recompensas THEN	
											--LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);									
											--LET v_FolioSUC = trim(v_fecha_folio)||v_pky_id_altarecompensa||v_pky_id_rangorecompensa||v_fky_id_tipo_recompensa;
											LET v_FolioSUC = trim(v_num_credito)||substr((current year TO day),9,2)||substr((current year TO day),6,2);	-- RQI 28 194
											LET v_fky_id_tipo_recompensa = v_fky_id_tipo_recompensa ;
											IF v_fky_id_tipo_recompensa = 1 THEN 
												IF v_tipo_prod = 1 THEN --- Bloque para CREDITO
													--let v_Display = 'Entra en OPERACION SI MONETARIA';
													--let v_Display = 'Entra en "principalrefer" para CREDITO';
													CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, v_transaccion, 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
													RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
												ELSE -- Se agrega proceso para realizar abono de recompensa a cuenta efectiva de prestamos
													--let v_Display = 'Entra en "abono_ref" para PRESTAMO PERSONAL';
													CALL bdicheq:"informix".abono_ref('001','9050',user,v_transaccion,'0000',v_FolioSUC,v_cuenta,0,v_monto_recompensa,v_monto_recompensa,0,0,0,'01','Abono por recompensa inmediata','','')
													RETURNING CodRet;
												END IF;
											ELSE
												--let v_Display = 'Entra en OPERACION NO MONETARIA';
												LET CodRet = '000';
											END IF;	
											IF CodRet ='000' then 
												UPDATE 	bdicred:"informix".sd_ri_archivos 
												SET 	recompensado = 1, total_op = v_tot_transacc, fecha_redencion = vlFechaHoy 
												WHERE 	num_credito = v_num_credito 
												AND 	pky_id_archivo = v_fky_id_archivo 
												AND 	fky_id_altarecompensa = v_pky_id_altarecompensa; -- Actualizar crÃÂ©dito recompensado.
												
												INSERT INTO bdicred:"informix".sd_ri_redencion VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_transacc, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n abonada
												LET v_total_redenciones = v_total_redenciones + 1;
											END IF;
									ELSE 									
										INSERT INTO bdicred:"informix".sd_ri_redencionagotada 
										VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_transacc, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas									
									END IF;
							ELSE 						
								CONTINUE FOREACH;
								LET v_tot_transacc = 0;						
							END IF;		

							--> B +
							UPDATE 	bdicred:"informix".sd_ri_rangorecompensa 
							SET 	total_redenciones = v_total_redenciones, fecha_ejecucion = vlFechaHoy 
							WHERE 	fky_id_altarecompensa = v_pky_id_altarecompensa 
							AND 	pky_id_rangorecompensa = v_pky_id_rangorecompensa;
							
						ELSE			
							IF v_prod_activo = 0 THEN 
								--let v_Display = 'Valida PRODUCTOS INACTIVOS ';
								LET v_inactivos = v_inactivos +1;
								--INSERT INTO bdicred:"informix".sd_ri_redencionagotada 
								--VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, 0, v_num_credito, 0, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas									
							END IF; 
							CONTINUE FOREACH;
						END IF;					
					END FOREACH;
					
				ELIF v_id_periodo > 1 and v_ri_a_demanda = 0 OR ((day(vlFechaHoy) = 26 and month(vlFechaHoy) <> 12) OR (day(vlFechaHoy) = 27 and month(vlFechaHoy) = 12)) THEN -->> ValidaciÃÂ³n con varios periodos por Carga de Archivo -- RQI 28 194, RQM 10 1287
				--let v_Display = 'Varios periodos por Carga de Archivo';
				FOREACH WITH HOLD -->> B ++					

					SELECT num_credito
					  INTO v_num_credito
					  FROM bdicred:sd_ri_archivos 
					 WHERE pky_id_archivo = v_fky_id_archivo
					   AND fky_id_altarecompensa = v_pky_id_altarecompensa
					   AND recompensado <> 1 --> Identificador de crÃÂ©ditos premiados.
					
						SELECT a.status_cred, a.num_producto, NVL(maes.monto_vencido + maes.mto_venc_trasp,0) --> Se agrega campo para el producto
						  INTO v_status_cred, v_producto,cMtoVen
						  FROM bdicred:sd_maecred a
						  INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
						 WHERE a.empresa = '001'
						   AND a.num_credito = v_num_credito;

						   LET v_status_cred = v_status_cred;
						   LET v_producto = v_producto;
						   
						-- Se agrega condicion para contemplar prestamos para recompensa  
						IF nvl(v_status_cred,'') = '' THEN
							 SELECT nvl(a.status_cred,''),a.num_producto,a.numcte,a.fecha_apertura,NVL(maes.monto_vencido + maes.mto_venc_trasp,0)
							   INTO v_status_cred,v_producto,v_numcte,vFechaCorte,cMtoVen
							   FROM	bdicred:sd_maecredcrd a
							   INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
							  WHERE	a.empresa = '001' 
							    AND a.num_credito = v_num_credito; 
						END IF;
							
						-- se agrega condicion para buscar si el producto es participante
						LET v_tipo_prod = 0;
						LET v_prod_activo = 0;
						LET v_transaccion = '';
						let v_producto = v_producto;
						 SELECT	pky_id_tipo_producto, 
								activo, 
								transaccion
						   INTO v_tipo_prod, -- para validar si el produto es TC o PP
								v_prod_activo, -- para validar si el producto esta activo para participar
								v_transaccion -- para validar la transaccion correspondiente
						   FROM bdicred:sd_ri_cat_productos
						  WHERE producto = v_producto; 
							
					IF v_status_cred IN ('AA','E1') AND cMtoVen = 0 and v_prod_activo = 1 THEN --- Validacion para saber si el producto esta activo
					  IF v_tipo_prod = 1 THEN  -- para validar si deben buscarse transacciones de TC o PP		
						-- PAGO VENTANILLA
						IF ( v_id_tipo_transacc = '7'  ) THEN 	
							let v_Display = 'Validacion "7-PAGO VENTANILLA"';
							SELECT num_pagos as tot_op, fecha
							  FROM bdicred:sd_indicador_cred_hist
							 WHERE empresa = '001' 
							   AND fecha > mdy(month(ddate), 20 , year(ddate))
							   AND fecha <= vlFechaHoy 
							   AND day(fecha) = 20 
							   AND num_credito = v_num_credito
							   AND monto_pagos >= v_monto_op_inicial
							   AND monto_pagos <= v_monto_op_final
							   AND num_pagos >= v_numero_op_inicial
							   AND num_pagos <= v_numero_op_final
						  GROUP BY num_pagos, fecha
							  INTO TEMP mov_tot_periodos WITH NO LOG;
						
						-- CARGO VENTANILLA 
						ELIF ( v_id_tipo_transacc = '8'  ) THEN 	
							let v_Display = 'Validacion "8-CARGO VENTANILLA"';
						
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
												
							SELECT num_vtn as tot_op, fecha
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha > mdy(month(ddate), 20 , year(ddate))
								   AND fecha <= vlFechaHoy 
								   AND day(fecha) = 20
								   AND num_credito = v_num_credito
								   AND monto_vtn >= v_monto_op_inicial
								   AND monto_vtn <= v_monto_op_final
								   AND num_vtn >= v_numero_op_inicial
								   AND num_vtn <= v_numero_op_final
							  GROUP BY num_vtn, fecha
							 	  INTO TEMP mov_tot_periodos WITH NO LOG;
						
						-- CARGO VENTANILLA 
						ELIF ( v_id_tipo_transacc = '9'  ) THEN -- CARGO POS 	
							let v_Display = 'Validacion "9-CARGO POS"';
											
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
												
							SELECT num_pos as tot_op, fecha
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha > mdy(month(ddate), 20 , year(ddate))
								   AND fecha <= vlFechaHoy 
								   AND day(fecha) = 20
								   AND num_credito = v_num_credito
								   AND monto_pos >= v_monto_op_inicial
								   AND monto_pos <= v_monto_op_final
								   AND num_pos >= v_numero_op_inicial
								   AND num_pos <= v_numero_op_final
							  GROUP BY num_pos, fecha
							  
							 INTO TEMP mov_tot_periodos WITH NO LOG;
						
						-- CARGO ATM
						ELIF ( v_id_tipo_transacc = '10' ) THEN  	
							let v_Display = 'Validacion "10-CARGO ATM"';
						
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
						
							SELECT num_atm as tot_op, fecha
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha > mdy(month(ddate), 20 , year(ddate))
								   AND fecha <= vlFechaHoy 
								   AND day(fecha) = 20
								   AND num_credito = v_num_credito
								   AND monto_atm >= v_monto_op_inicial
								   AND monto_atm <= v_monto_op_final
								   AND num_atm >= v_numero_op_inicial
								   AND num_atm <= v_numero_op_final
							  GROUP BY num_atm, fecha
							  
							 INTO TEMP mov_tot_periodos WITH NO LOG;
						END IF;
						ELSE 
							--let v_Display = 'Busca operaciones de PP'; 
							IF ((select count (*) 								
								from bdicheq:sc_maechq where empresa = '001' 
								and num_cte = v_numcte
								and producto = '2000' and status_cta = '1') >= 1) THEN
								
								select  cuenta	
								INTO v_cuenta
								from bdicheq:sc_maechq where empresa = '001' 
								and num_cte= v_numcte
								and producto = '2000' and status_cta = '1';
																		
								SELECT cumplio_convenio, fecha_insert
								FROM bdicred:sd_indicador_cred_crd_hist
								WHERE empresa = '001' 
								AND fecha_insert > mdy(month(ddate), DAY(vFechaCorte) , year(ddate))
								AND fecha_insert <= mdy(month(ddate), DAY(ddate) , year(ddate))
								AND num_credito = v_num_credito
								GROUP BY cumplio_convenio,fecha_insert
								
								INTO TEMP mov_tot_periodos WITH NO LOG;	
							END IF;						
					  END IF
						SELECT COUNT (*), SUM (tot_op)
						INTO v_cont_periodo, v_tot_transacc
						FROM mov_tot_periodos where fecha IS NOT NULL;
					  
						IF v_cont_periodo = 0 THEN 
							DROP TABLE mov_tot_periodos; 
						ELSE
							LET v_cont_periodo = v_cont_periodo;
							IF v_cont_periodo >= v_id_periodo THEN -- -C
					
								IF v_total_redenciones < v_total_recompensas THEN
									--LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
									--LET v_FolioSUC = trim(v_fecha_folio)||v_pky_id_altarecompensa||v_pky_id_rangorecompensa||v_fky_id_tipo_recompensa;
									LET v_FolioSUC = trim(v_num_credito)||substr((current year TO day),9,2)||substr((current year TO day),6,2);	-- RQI 28 194
									IF v_fky_id_tipo_recompensa = 1 THEN 
										IF v_tipo_prod = 1 THEN --- Bloque para CREDITO
											--let v_Display = 'Entra en OPERACION SI MONETARIA';
											--let v_Display = 'Entra en "principalrefer" para CREDITO';
											CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, v_transaccion, 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
											RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
										  ELSE -- Se agrega proceso para realizar abono de recompensa a cuenta efectiva de prestamos
											--LET v_Display = 'Entra en "abono_ref" para PRESTAMO PERSONAL';
											CALL bdicheq:"informix".abono_ref('001','9050',user,v_transaccion,'0000',v_FolioSUC,v_cuenta,0,v_monto_recompensa,v_monto_recompensa,0,0,0,'01','Abono por recompensa inmediata','','')
											RETURNING CodRet;
											
										END IF;
									  ELSE
										--let v_Display = 'Entra en OPERACION NO MONETARIA';
										LET CodRet = '000';
									END IF;	
									IF CodRet ='000' then 									
									  UPDATE bdicred:"informix".sd_ri_archivos 
									  SET recompensado = 1, total_op = v_tot_transacc, fecha_redencion = today 
									  WHERE num_credito = v_num_credito 
									  AND pky_id_archivo = v_fky_id_archivo 
									  AND fky_id_altarecompensa = v_pky_id_altarecompensa; -- Actualizar crÃÂ©dito recompensado.
									  
									  INSERT INTO bdicred:"informix".sd_ri_redencion VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_transacc, v_fecha_inicio, v_fecha_final, today); -- Insert de TransacciÃÂ³n abonada
									  LET v_total_redenciones = v_total_redenciones + 1;
									END IF;
									
								ELSE 								
									INSERT INTO bdicred:"informix".sd_ri_redencionagotada 
									VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_transacc, v_fecha_inicio, v_fecha_final, today); -- Insert de TransacciÃÂ³n con recompensas agotadas								
								END IF;
							   
							ELSE -- -C					
		
								CONTINUE FOREACH;							
							END IF; -- -C
							
						END IF;
					
							--> B ++
							UPDATE bdicred:"informix".sd_ri_rangorecompensa 
							SET total_redenciones = v_total_redenciones, fecha_ejecucion = today 
							WHERE fky_id_altarecompensa = v_pky_id_altarecompensa 
							AND pky_id_rangorecompensa = v_pky_id_rangorecompensa;
					
						ELSE
							IF v_prod_activo = 0 THEN
								--let v_Display = 'Entra en (v_inactivos) varios periodos';
								LET v_inactivos = v_inactivos +1;  --- contador para saber que producto no esta activo y no debe participar
								--INSERT INTO bdicred:"informix".sd_ri_redencionagotada 
								--VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, 0, v_num_credito, 0, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas									
							END IF;
							--DROP TABLE mov_tot_periodos;							
							CONTINUE FOREACH;
							
						END IF;
					
					END FOREACH;
				
				END IF;
				
			--> PR
			LET v_fky_id_rangorecompensa = v_fky_id_rangorecompensa + 1; --> Inicializar Variable 
					
			END FOREACH;
		
		ELSE  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Ciclo de Recompensa Cash Back por consulta a tabla sd_camp_primer_uso
		
			SELECT max (fecha_ejecucion) --> Fecha de campaÃÂ±a
			INTO v_fecha_ejecucion
			FROM bdicred:sd_camp_primer_uso
			WHERE num_campania = 5;
		
			FOREACH WITH HOLD 
			--> PR
			
				SELECT   pky_id_rangorecompensa,   monto_op_inicial,   monto_op_final,   total_recompensas,   total_redenciones,   numero_op_inicial,   numero_op_final,   id_periodo,  monto_recompensa
				  INTO v_pky_id_rangorecompensa, v_monto_op_inicial, v_monto_op_final, v_total_recompensas, v_total_redenciones, v_numero_op_inicial, v_numero_op_final, v_id_periodo, v_monto_recompensa
				  FROM bdicred:sd_ri_rangorecompensa 
				 WHERE activo = 1 
				   AND fky_id_altarecompensa = v_pky_id_altarecompensa

				IF v_id_periodo = 1 THEN -->> ValidaciÃÂ³n con un sÃÂ³lo periodo por Carga de Archivo
					
					FOREACH WITH HOLD
					--> B +
					
						SELECT num_credito 
						  INTO v_num_credito
						  FROM bdicred:sd_camp_primer_uso
						 WHERE fecha_ejecucion = v_fecha_ejecucion
						   AND num_campania = 5 -- Recompensa Inmediata
						   AND recompensa = 0
						   
						SELECT NVL(a.status_cred,''),NVL(maes.monto_vencido + maes.mto_venc_trasp,0) 
						  INTO v_status_cred,cMtoVen
						  FROM bdicred:sd_maecred a
						  INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
						 WHERE a.empresa = '001'
						   AND a.num_credito = v_num_credito;
							
						IF v_status_cred IN ('AA','E1') and cMtoVen = 0  THEN
						   
							IF ( v_id_tipo_transacc = '7' ) THEN -- PAGO VENTANILLA 
							
								SELECT num_pagos	
								  INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha = mdy(month(vlFechaHoy), 20 , year(vlFechaHoy)) --> Eliminar el -1 para considerar la fecha del mes actual
								   AND num_credito = v_num_credito
								   AND monto_pagos >= v_monto_op_inicial
								   AND monto_pagos <= v_monto_op_final
								   AND num_pagos >= v_numero_op_inicial
								   AND num_pagos <= v_numero_op_final
							  GROUP BY num_pagos, fecha;
							
							ELIF ( v_id_tipo_transacc = '8' ) THEN -- CARGO VENTANILLA 

								SELECT num_vtn
								  INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha = mdy(month(vlFechaHoy), 20 , year(vlFechaHoy)) --> Eliminar el -1 para considerar la fecha del mes actual
								   AND num_credito = v_num_credito
								   AND monto_vtn >= v_monto_op_inicial
								   AND monto_vtn <= v_monto_op_final
								   AND num_vtn >= v_numero_op_inicial
								   AND num_vtn <= v_numero_op_final
							  GROUP BY num_vtn, fecha;
							
							ELIF ( v_id_tipo_transacc = '9' ) THEN -- CARGO POS 

								SELECT num_pos
								  INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha = mdy(month(vlFechaHoy), 20 , year(vlFechaHoy)) --> Eliminar el -1 para considerar la fecha del mes actual
								   AND num_credito = v_num_credito
								   AND monto_pos >= v_monto_op_inicial
								   AND monto_pos <= v_monto_op_final
								   AND num_pos >= v_numero_op_inicial
								   AND num_pos <= v_numero_op_final
							  GROUP BY num_pos, fecha;
							  
							ELIF ( v_id_tipo_transacc = '10' ) THEN -- CARGO ATM 
							
								SELECT num_atm
								  INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha = mdy(month(vlFechaHoy), 20 , year(vlFechaHoy)) --> Eliminar el -1 para considerar la fecha del mes actual
								   AND num_credito = v_num_credito
								   AND monto_atm >= v_monto_op_inicial
								   AND monto_atm <= v_monto_op_final
								   AND num_atm >= v_numero_op_inicial
								   AND num_atm <= v_numero_op_final
							  GROUP BY num_atm, fecha;
							
							END IF;
											   
								IF v_tot_transacc > 0 THEN 
								
									IF v_total_redenciones < v_total_recompensas THEN
								
										--LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
										--LET v_FolioSUC = trim(v_fecha_folio)||v_pky_id_altarecompensa||v_pky_id_rangorecompensa||v_fky_id_tipo_recompensa;
										LET v_FolioSUC = trim(v_num_credito)||substr((current year TO day),9,2)||substr((current year TO day),6,2);	-- RQI 28 194
										
										{
										CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, '8800', 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
										RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
										}
										if CodRet ='000' then 
										  UPDATE bdicred:"informix".sd_ri_archivos SET recompensado = 1, total_op = v_tot_transacc, fecha_redencion = vlFechaHoy WHERE num_credito = v_num_credito AND pky_id_archivo = v_fky_id_archivo AND fky_id_altarecompensa = v_pky_id_altarecompensa; -- Actualizar crÃÂ©dito recompensado.
										  INSERT INTO bdicred:"informix".sd_ri_redencion VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_recompensa, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n abonada
										end if;								
										LET v_total_redenciones = v_total_redenciones + 1;
								
									ELSE 									
										INSERT INTO bdicred:"informix".sd_ri_redencionagotada VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_recompensa, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas
									
									END IF;								
								ELSE 						
									CONTINUE FOREACH;
									LET v_tot_transacc = 0;
						
								END IF;		

							--> B +
							UPDATE bdicred:"informix".sd_ri_rangorecompensa SET total_redenciones = v_total_redenciones, fecha_ejecucion = vlFechaHoy WHERE fky_id_altarecompensa = v_pky_id_altarecompensa AND pky_id_rangorecompensa = v_pky_id_rangorecompensa;
							
						ELSE
							
							CONTINUE FOREACH;
							
						END IF;
					
					END FOREACH;
				
				ELSE -->> ValidaciÃÂ³n con varios periodos por Carga de Archivo
				
				FOREACH WITH HOLD -->> B ++
					
					SELECT num_credito 
					  INTO v_num_credito
					  FROM bdicred:sd_camp_primer_uso
					 WHERE fecha_ejecucion = v_fecha_ejecucion
					   AND num_campania = 5 -- Recompensa Inmediata
					   AND recompensa = 0

					SELECT NVL(a.status_cred,'') ,NVL(maes.monto_vencido + maes.mto_venc_trasp,0) 
					  INTO v_status_cred, cMtoVen
					  FROM bdicred:sd_maecred a
					  INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
					 WHERE a.empresa = '001'
					   AND a.num_credito = v_num_credito;
							
					IF v_status_cred IN ('AA','E1') and cMtoVen = 0 THEN
					   
						IF   ( v_id_tipo_transacc = '7'  ) THEN -- PAGO VENTANILLA 
												
						
							SELECT num_pagos as tot_op, CASE WHEN DAY(fecha) <> 20 THEN to_char ( MDY (MONTH (fecha), decode(DAY(fecha),'31', 20, '30', 20, '28', 20, DAY(fecha)), YEAR(fecha)),'%m%Y') END
							   fecha
							  --INTO v_tot_transacc
							  FROM bdicred:sd_indicador_cred_hist
							 WHERE empresa = '001' 
							   AND fecha >= mdy(month(ddate), 20 , year(ddate))--mdy(month(today)-v_id_periodo, 20 , year(today))
							   AND num_credito = v_num_credito
							   AND monto_pagos >= v_monto_op_inicial
							   AND monto_pagos <= v_monto_op_final
							   AND num_pagos >= v_numero_op_inicial
							   AND num_pagos <= v_numero_op_final
						  GROUP BY num_pagos, fecha
						  
						 INTO TEMP mov_tot_periodos WITH NO LOG;
						
						ELIF ( v_id_tipo_transacc = '8'  ) THEN -- CARGO VENTANILLA 
						
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
						
												
							SELECT num_vtn as tot_op, CASE WHEN DAY(fecha) <> 20 THEN to_char ( MDY (MONTH (fecha), decode(DAY(fecha),'31', 20, '30', 20, '28', 20, DAY(fecha)), YEAR(fecha)),'%m%Y') END
								   fecha
								  --INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha >= mdy(month(ddate), 20 , year(ddate))--mdy(month(today)-v_id_periodo, 20 , year(today))
								   AND num_credito = v_num_credito
								   AND monto_vtn >= v_monto_op_inicial
								   AND monto_vtn <= v_monto_op_final
								   AND num_vtn >= v_numero_op_inicial
								   AND num_vtn <= v_numero_op_final
							  GROUP BY num_vtn, fecha
							  
							 INTO TEMP mov_tot_periodos WITH NO LOG;
						
						ELIF ( v_id_tipo_transacc = '9'  ) THEN -- CARGO POS
											
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
						
												
							SELECT num_pos as tot_op, CASE WHEN DAY(fecha) <> 20 THEN to_char ( MDY (MONTH (fecha), decode(DAY(fecha),'31', 20, '30', 20, '28', 20, DAY(fecha)), YEAR(fecha)),'%m%Y') END
								   fecha
								  --INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha >= mdy(month(ddate), 20 , year(ddate))--mdy(month(today)-v_id_periodo, 20 , year(today))
								   AND num_credito = v_num_credito
								   AND monto_pos >= v_monto_op_inicial
								   AND monto_pos <= v_monto_op_final
								   AND num_pos >= v_numero_op_inicial
								   AND num_pos <= v_numero_op_final
							  GROUP BY num_pos, fecha
							  
							 INTO TEMP mov_tot_periodos WITH NO LOG;
						
						ELIF ( v_id_tipo_transacc = '10' ) THEN -- CARGO ATM 	
						
							IF v_cont_periodo > 0 THEN
								DROP TABLE mov_tot_periodos; 
							END IF;
						
												
							SELECT num_atm as tot_op, CASE WHEN DAY(fecha) <> 20 THEN to_char ( MDY (MONTH (fecha), decode(DAY(fecha),'31', 20, '30', 20, '28', 20, DAY(fecha)), YEAR(fecha)),'%m%Y') END
								   fecha
								  --INTO v_tot_transacc
								  FROM bdicred:sd_indicador_cred_hist
								 WHERE empresa = '001' 
								   AND fecha >= mdy(month(ddate), 20 , year(ddate))--mdy(month(today)-v_id_periodo, 20 , year(today))
								   AND num_credito = v_num_credito
								   AND monto_atm >= v_monto_op_inicial
								   AND monto_atm <= v_monto_op_final
								   AND num_atm >= v_numero_op_inicial
								   AND num_atm <= v_numero_op_final
							  GROUP BY num_atm, fecha
							  
							 INTO TEMP mov_tot_periodos WITH NO LOG;
						
						END IF;
						
						SELECT COUNT (*), SUM (tot_op)
						INTO v_cont_periodo, v_tot_transacc
						FROM mov_tot_periodos where fecha IS NOT NULL;
					  
						IF v_cont_periodo = 0 THEN 
							DROP TABLE mov_tot_periodos; 
						ELSE
					 
							IF v_cont_periodo >= v_id_periodo THEN -- -C
					
								IF v_total_redenciones < v_total_recompensas THEN
							
									--LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
									--LET v_FolioSUC = trim(v_fecha_folio)||v_pky_id_altarecompensa||v_pky_id_rangorecompensa||v_fky_id_tipo_recompensa;
									LET v_FolioSUC = trim(v_num_credito)||substr((current year TO day),9,2)||substr((current year TO day),6,2);	-- RQI 28 194
									
									{
									CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, '8800', 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
									RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
									}
									IF CodRet ='000' then 
									  UPDATE bdicred:"informix".sd_ri_archivos SET recompensado = 1, total_op = v_tot_transacc, fecha_redencion = vlFechaHoy WHERE num_credito = v_num_credito AND pky_id_archivo = v_fky_id_archivo AND fky_id_altarecompensa = v_pky_id_altarecompensa; -- Actualizar crÃÂ©dito recompensado.
									  INSERT INTO bdicred:"informix".sd_ri_redencion VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_recompensa, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n abonada
									end if;
									LET v_total_redenciones = v_total_redenciones + 1;
							
								ELSE 
								
									INSERT INTO bdicred:"informix".sd_ri_redencionagotada VALUES (v_pky_id_altarecompensa, v_fky_id_tipo_recompensa, v_pky_id_rangorecompensa, v_tot_transacc, v_num_credito, v_monto_recompensa, v_fecha_inicio, v_fecha_final, vlFechaHoy); -- Insert de TransacciÃÂ³n con recompensas agotadas
								
							END IF;
							   
							ELSE -- -C
							
								CONTINUE FOREACH;
							
							END IF; -- -C
							
						END IF;
					
							--> B ++
							UPDATE bdicred:"informix".sd_ri_rangorecompensa SET total_redenciones = v_total_redenciones, fecha_ejecucion = vlFechaHoy 
							WHERE fky_id_altarecompensa = v_pky_id_altarecompensa AND pky_id_rangorecompensa = v_pky_id_rangorecompensa;
					
					ELSE
							
						CONTINUE FOREACH;
						DROP TABLE IF EXISTS mov_tot_periodos;
					END IF;
					
					END FOREACH;
				
				END IF;
				
			--> PR
			LET v_fky_id_rangorecompensa = v_fky_id_rangorecompensa + 1; --> Inicializar Variable 
					
			END FOREACH;
			
		
		END IF;
	-- RQI 28 194 Inicio
	IF v_total_redenciones > 0 THEN
		--> MR
		UPDATE bdicred:"informix".sd_ri_altarecompensa SET fecha_ejecucion = vlFechaHoy 
		WHERE pky_id_altarecompensa = v_pky_id_altarecompensa;
	END IF;
	-- RQI 28 194 Fin
	
	LET v_pky_id_altarecompensa		= 0 ;
	LET v_fecha_inicio				= '';
	LET v_fecha_final 				= '';
	LET v_fky_id_tipo_recompensa 	= 0;
	LET v_carga_archivo 			= '';
	LET v_fky_id_archivo			= 0;

	LET CodRet = '00000'; --> Proceso concluyo exitosamente
	
	END FOREACH;
	
    COMMIT WORK;
    
	END;
	-- RQI 28 194 Inicio
	IF	v_activo = 0	THEN
	
		LET CodRet = '00000'; --> Proceso concluyo exitosamente
		
	END IF;
	-- RQI 28 194 Fin				 
	
	LET cCodRet = CodRet;
		
	RETURN cCodRet;

END PROCEDURE;