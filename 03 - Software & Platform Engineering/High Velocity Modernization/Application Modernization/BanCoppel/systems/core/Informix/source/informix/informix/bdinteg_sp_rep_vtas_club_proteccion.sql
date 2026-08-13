CREATE PROCEDURE "informix".sp_rep_vtas_club_proteccion()   
RETURNING CHAR(06) AS resultado;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1197 - Inf Ventas Diarias Club de ProtecciÃ³n
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 02/04/2020
	--ModificaciÃ³n: Se crea el sp para generar el reporte Ventas_Club_Proteccion_DDMMAAAA.txt
	--BD: bdinteg
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet      		     		CHAR(6);
	DEFINE v_dia_sem_hoy					DATE;
	DEFINE v_fecha_inicio_sem_pasada		DATE;
	DEFINE v_fecha_fin_sem_pasada			DATE;
	DEFINE v_cuenta_registros				INTEGER;
	DEFINE v_suma_registros					INTEGER;
	DEFINE v_numcte           				CHAR(20);
	DEFINE v_numcte_coppel                  CHAR(20);
	DEFINE v_num_poliza                     CHAR(20);
	DEFINE v_tipo_plan                      CHAR(1);
	DEFINE v_suc_alta                       CHAR(4);
	DEFINE v_ejecutivo                      CHAR(8);
	DEFINE v_tipo_pago                      CHAR(1);
	DEFINE v_num_tarjeta                    CHAR(20);
	DEFINE v_num_cta                        CHAR(20);
	DEFINE v_meses_pagar                    INTEGER;
	DEFINE v_monto_pagar                    DECIMAL(16);
	DEFINE v_monto_mes                      DECIMAL(16);
	DEFINE v_monto_total                    DECIMAL(16);
	DEFINE v_aceptada                       CHAR(1);
	DEFINE v_motivo_rechazo                 CHAR(50);
	DEFINE v_tipo_mov                       CHAR(1);
	DEFINE v_pago_mov                       CHAR(1);
	DEFINE v_folio_operacion                CHAR(16);
	DEFINE v_fecha_alta                     DATE;
	DEFINE v_fecha_cambio                   DATE;
	DEFINE v_suc_cambio                     CHAR(4);
	DEFINE v_fecha_vencimiento              DATE;
	DEFINE v_tipoplan_ant                   CHAR(1);
	DEFINE v_poliza_pagada	                CHAR(2);
	DEFINE v_fecha_pago_poliza              DATE;
	DEFINE v_comienza_commit				INTEGER;
	DEFINE vsql                         	CHAR(2000);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet      			= '00000';
	LET v_cuenta_registros		= 0;
	LET v_suma_registros		= 0;
	LET v_comienza_commit		= 0;
	LET v_cuenta_registros		= 0;

	--SET DEBUG FILE TO '/RESPALDOSNEW/Vtas_ClubProteccion/sp_rep_vtas_club_proteccion.out';
	--TRACE ON; 
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
	
	BEGIN
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		-- DÃA DE LA SEMANA ACTUAL
		LET	v_dia_sem_hoy = weekday(today);
		-- FECHA DEL FIN DE LA SEMANA PASADA
		LET v_fecha_fin_sem_pasada = today - v_dia_sem_hoy;
		-- FECHA DEL INICIO DE LA SEMANA PASADA
		LET v_fecha_inicio_sem_pasada = today - (6+v_dia_sem_hoy);
		
		-- Se eliminan tablas temporales si es qaue existen
		DROP TABLE IF EXISTS "informix".si_club_proteccion_temp;
		DROP TABLE IF EXISTS "informix".si_club_proteccion_virtual;
		DROP TABLE IF EXISTS "informix".sac_movimientoshistorial_virtual;
		DROP TABLE IF EXISTS "informix".sc_movhis_virtual;
		
		CREATE TABLE "informix".si_club_proteccion_temp  ( 
			numcte           	CHAR(20) NOT NULL,
			numcte_coppel    	CHAR(20) NOT NULL,
			num_poliza       	CHAR(20) NOT NULL,
			tipo_plan        	CHAR(1) NOT NULL,
			suc_alta         	CHAR(4) NOT NULL,
			ejecutivo        	CHAR(8) NOT NULL,
			tipo_pago        	CHAR(1) NOT NULL,
			num_tarjeta      	CHAR(20),
			num_cta          	CHAR(20),
			meses_pagar      	INTEGER NOT NULL,
			monto_pagar      	DECIMAL(16) NOT NULL,
			monto_mes        	DECIMAL(16) NOT NULL,
			monto_total      	DECIMAL(16) NOT NULL,
			aceptada         	CHAR(1) NOT NULL,
			motivo_rechazo   	CHAR(50),
			tipo_mov         	CHAR(1) NOT NULL,
			pago_mov         	CHAR(1) NOT NULL,
			folio_operacion   	CHAR(16),
			fecha_alta       	DATE NOT NULL,
			fecha_cambio     	DATE NOT NULL,
			suc_cambio       	CHAR(4),
			fecha_vencimiento	DATE,
			tipoplan_ant     	CHAR(1),
			poliza_pagada		CHAR(2),
			fecha_pago_poliza	DATE
		);
		
		SELECT  numcte, numcte_coppel, num_poliza, tipo_plan, suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,
				meses_pagar, monto_pagar, monto_mes, monto_total, aceptada, motivo_rechazo, tipo_mov, pago_mov, foliooperacion,
				fecha_alta, fecha_cambio, suc_cambio, fecha_vencimiento, tipoplan_ant
		FROM    bdinteg:si_club_proteccion
		WHERE   fecha_alta BETWEEN v_fecha_inicio_sem_pasada AND v_fecha_fin_sem_pasada
		INTO 	temp si_club_proteccion_virtual WITH NO LOG;
		
		SELECT	referencia1, folio_suc, importe_pago, fecha_pago
		FROM	bdisac:sac_movimientoshistorial
		WHERE 	fecha_pago BETWEEN v_fecha_inicio_sem_pasada AND v_fecha_fin_sem_pasada
		AND 	status_cancelado = 'N'
		AND     TRIM(referencia1) IN(SELECT TRIM(numcte_coppel) FROM si_club_proteccion_virtual)																				  
		INTO 	temp sac_movimientoshistorial_virtual WITH NO LOG;
		
		SELECT	fech_alt, folio_suc
		FROM	bdicheq:sc_movhis
		WHERE 	empresa = '001' 
		AND 	fech_alt BETWEEN v_fecha_inicio_sem_pasada AND v_fecha_fin_sem_pasada
		AND 	cancelad = ''
		AND 	transacc in ('1303','1363')
		AND		folio_suc IN(SELECT folio_suc FROM sac_movimientoshistorial_virtual)
		INTO 	temp sc_movhis_virtual WITH NO LOG;
		
		FOREACH WITH HOLD
		
			SELECT      A.numcte, A.numcte_coppel, A.num_poliza, A.tipo_plan, A.suc_alta, A.ejecutivo, A.tipo_pago, A.num_tarjeta, A.num_cta,
						A.meses_pagar, A.monto_pagar, A.monto_mes, A.monto_total, A.aceptada, A.motivo_rechazo, A.tipo_mov, A.pago_mov, A.foliooperacion,
						A.fecha_alta, A.fecha_cambio, A.suc_cambio, A.fecha_vencimiento, A.tipoplan_ant, MAX(B.fecha_pago)
			INTO 		v_numcte, v_numcte_coppel, v_num_poliza, v_tipo_plan, v_suc_alta,
						v_ejecutivo, v_tipo_pago, v_num_tarjeta, v_num_cta, v_meses_pagar,
						v_monto_pagar, v_monto_mes, v_monto_total, v_aceptada, v_motivo_rechazo,
						v_tipo_mov, v_pago_mov, v_folio_operacion, v_fecha_alta, v_fecha_cambio,
						v_suc_cambio, v_fecha_vencimiento, v_tipoplan_ant, v_fecha_pago_poliza 
			FROM        si_club_proteccion_virtual A 
			LEFT JOIN   sac_movimientoshistorial_virtual B ON TRIM(A.numcte_coppel) = TRIM(B.referencia1) AND A.monto_pagar = B.importe_pago 
			LEFT JOIN   sc_movhis_virtual C ON B.fecha_pago = C.fech_alt AND B.folio_suc = C.folio_suc  
			GROUP BY    A.numcte, A.numcte_coppel, A.num_poliza, A.tipo_plan, A.suc_alta, A.ejecutivo, A.tipo_pago, A.num_tarjeta, A.num_cta,
						A.meses_pagar, A.monto_pagar, A.monto_mes, A.monto_total, A.aceptada, A.motivo_rechazo, A.tipo_mov, A.pago_mov, A.foliooperacion,
						A.fecha_alta, A.fecha_cambio, A.suc_cambio, A.fecha_vencimiento, A.tipoplan_ant
		
			IF(v_fecha_pago_poliza IS NULL OR v_fecha_pago_poliza = '') THEN
				LET v_poliza_pagada = 'NO';
			ELSE 	
				LET v_poliza_pagada = 'SI';
			END IF;
			
			-- ABRE COMMIT'S PARCIALES
			IF (v_comienza_commit = 0) THEN
                LET v_comienza_commit = 1;
                BEGIN WORK;
            END IF;

            INSERT INTO bdinteg:si_club_proteccion_temp VALUES(	v_numcte, v_numcte_coppel, v_num_poliza, v_tipo_plan, v_suc_alta,
																v_ejecutivo, v_tipo_pago, v_num_tarjeta, v_num_cta, v_meses_pagar,
																v_monto_pagar, v_monto_mes, v_monto_total, v_aceptada, v_motivo_rechazo,
																v_tipo_mov, v_pago_mov, v_folio_operacion, v_fecha_alta, v_fecha_cambio,
																v_suc_cambio, v_fecha_vencimiento, v_tipoplan_ant, v_poliza_pagada, v_fecha_pago_poliza );

            LET v_suma_registros = v_suma_registros + 1;
			
			--REALIZA COMMIT CADA 1,000 REGISTROS
            IF (v_suma_registros >= 1000) THEN
                LET v_suma_registros = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
			
		END FOREACH;
		
		IF (v_suma_registros > 0) THEN
			COMMIT WORK;
		END IF;
		
		SELECT 	COUNT(numcte)
		INTO	v_cuenta_registros
		FROM 	si_club_proteccion_temp;
		
		
		IF (v_cuenta_registros > 0) THEN
		
			-- Generacion del Reporte (Ventas_Club_Proteccion_DDMMAAAA.txt)
			let vsql = '';
			let vsql = 'echo "numcte|numcte_coppel|num_poliza|tipo_plan|suc_alta|ejecutivo|tipo_pago|num_tarjeta|num_cta|meses_pagar|monto_pagar|monto_mes|monto_total|aceptada|motivo_rechazo|tipo_mov|pago_mov|folio_operacion|fecha_alta|fecha_cambio|suc_cambio|fecha_vencimiento|tipoplan_ant|poliza_pagada|fecha_pago_poliza">/RESPALDOSNEW/Vtas_ClubProteccion/Ventas_Club_Proteccion_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||YEAR(today)||'.txt';
			system vsql;  
			
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /RESPALDOSNEW/Vtas_ClubProteccion/QA_archivo.unl select numcte, numcte_coppel, num_poliza, tipo_plan, suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta, meses_pagar, monto_pagar, monto_mes, monto_total, aceptada, motivo_rechazo, tipo_mov, pago_mov, folio_operacion, fecha_alta, fecha_cambio, suc_cambio, fecha_vencimiento, tipoplan_ant, poliza_pagada, fecha_pago_poliza from si_club_proteccion_temp order by numcte, numcte_coppel;">/RESPALDOSNEW/Vtas_ClubProteccion/QA_Script.sql';      
			system vsql;
			
			let vsql='chmod a+rwx /RESPALDOSNEW/Vtas_ClubProteccion/QA_Script.sql';
			System vsql;
			
			let vsql = '';
			let vsql= 'dbaccess bdinteg /RESPALDOSNEW/Vtas_ClubProteccion/QA_Script.sql';
			system vsql;
			
			let vsql = vsql;
			let vsql ='rm /RESPALDOSNEW/Vtas_ClubProteccion/QA_Script.sql';
			
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /RESPALDOSNEW/Vtas_ClubProteccion/QA_archivo.unl >> /RESPALDOSNEW/Vtas_ClubProteccion/Ventas_Club_Proteccion_"||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||YEAR(today)||'.txt';
			system vsql;
			let vsql ='rm /RESPALDOSNEW/Vtas_ClubProteccion/QA_archivo.unl';
			system vsql; 
			
		ELSE
					
			--GeneraciÃ³n de Reporte Ventas_Club_Proteccion_DDMMAAAA.txt sin informaciÃ³n a reportar
			let vsql = '';
			let vsql = 'echo "<<< No hay informaciÃ³n a reportar >>>"> /RESPALDOSNEW/Vtas_ClubProteccion/Ventas_Club_Proteccion_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||YEAR(today)||'.txt';
			system vsql;
			
		END IF;
		
		-- Se eliminan tablas temporales si es que existen
		DROP TABLE IF EXISTS "informix".si_club_proteccion_temp;
		DROP TABLE IF EXISTS "informix".si_club_proteccion_virtual;
		DROP TABLE IF EXISTS "informix".sac_movimientoshistorial_virtual;
		DROP TABLE IF EXISTS "informix".sc_movhis_virtual;
		
		RETURN cCodRet;
	END
END PROCEDURE;