CREATE PROCEDURE "informix".sp_rep_result_ctes_largos()   
RETURNING CHAR(06) AS resultado;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1194 - Reporte Resultado Clientes Largos
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 13/04/2020
	--ModificaciÃ³n: Se crea el sp para generar el reporte Resultados_ClientesLargos_MM_AAAA.csv
	--BD: bdisolic
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet      		     		CHAR(6);
	DEFINE v_fecha_inicio_mes_pasado		DATE;
	DEFINE v_fecha_fin_mes_pasado			DATE;
	DEFINE v_cuenta_registros				INTEGER;
	DEFINE v_suma_registros					INTEGER;
	DEFINE v_fecha_solicitud				DATE;
	DEFINE v_fecha_autorizacion             DATE;
	DEFINE v_num_solicitud              	CHAR(20);
	DEFINE v_num_cliente              		CHAR(20);
	DEFINE v_nombre_cliente					CHAR(150);
	DEFINE v_correo              			CHAR(100);
	DEFINE v_num_movil              		CHAR(13);
	DEFINE v_num_producto              		CHAR(7);
	DEFINE v_status_solicitud              	CHAR(2);
	DEFINE v_desc_status_sol              	CHAR(40);
	DEFINE v_monto_solicitado              	DECIMAL(18,2);
	DEFINE v_monto_autorizado              	DECIMAL(18,2);
	DEFINE v_monto_otorgado_sdos           	DECIMAL(18,2);
	DEFINE v_monto_otorgado_sdoscrd        	DECIMAL(18,2);
	DEFINE v_monto_otorgado              	DECIMAL(18,2);
	DEFINE v_comienza_commit				INTEGER;
	DEFINE vsql                         	CHAR(2000);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet      			= '00000';
	LET v_cuenta_registros		= 0;
	LET v_suma_registros		= 0;
	LET v_comienza_commit		= 0;

	--SET DEBUG FILE TO '/RESPALDOSNEW/Ctes_Largos/sp_rep_result_ctes_largos.out';
	--TRACE ON; 
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
	
	BEGIN
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		-- FECHA DEL FIN DEL MES PASADO
		LET v_fecha_fin_mes_pasado = today - DAY(today);
		-- FECHA DEL INICIO DEL MES PASADO
		LET v_fecha_inicio_mes_pasado = MDY(MONTH(v_fecha_fin_mes_pasado),01,YEAR(v_fecha_fin_mes_pasado));
		
		-- Se eliminan tablas temporales si es qaue existen
		DROP TABLE IF EXISTS "informix".ss_clientes_largos_temp;
		DROP TABLE IF EXISTS "informix".ss_solicitudes_virtual;
		DROP TABLE IF EXISTS "informix".ss_clienteslargos_virtual;
		DROP TABLE IF EXISTS "informix".ss_autorizacion_virtual;
		DROP TABLE IF EXISTS "informix".si_correos_virtual;
		DROP TABLE IF EXISTS "informix".si_telefonos_actual_virtual;
		DROP TABLE IF EXISTS "informix".sd_maesdoshist_virtual;
		DROP TABLE IF EXISTS "informix".sd_maesdoshistcrd_virtual;
		
		CREATE TABLE "informix".ss_clientes_largos_temp  ( 
			fecha_solicitud				DATE NOT NULL,
			fecha_autorizacion          DATE,
			num_solicitud              	CHAR(20) NOT NULL,
			num_cliente              	CHAR(20) NOT NULL,
			nombre_cliente				CHAR(150),
			correo              		CHAR(100),
			num_movil              		CHAR(13),
			num_producto              	CHAR(7) NOT NULL,
			status_solicitud            CHAR(2) NOT NULL,
			desc_status_sol				CHAR(40) NOT NULL,
			monto_solicitado            DECIMAL(18,2),
			monto_autorizado            DECIMAL(18,2),
			monto_otorgado             	DECIMAL(18,2)
		);
			
		SELECT		fecha_insert, numcte, num_solicitud, num_producto, status_solicitud, monto_solicitado, monto_autorizado
		FROM    	bdisolic:ss_solicitudes
		WHERE 		numcte in(SELECT numcte from bdisolic:ss_clienteslargos)
		AND			empresa = '001'
		AND			fecha_insert BETWEEN v_fecha_inicio_mes_pasado AND v_fecha_fin_mes_pasado
		AND 		num_producto IN('6001','6011','6300','6500','6600','7800','7900','7600','7700','6400','6800')
		INTO		TEMP ss_solicitudes_virtual WITH NO LOG;

		SELECT		numcte, TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre_cliente
		FROM		bdinteg:si_cliente
		WHERE		numcte IN(SELECT DISTINCT numcte FROM ss_solicitudes_virtual)
		INTO		TEMP ss_clienteslargos_virtual WITH NO LOG;
				
		SELECT		fecha_salida, num_solicitud
		FROM		bdisolic:ss_autorizacion
		WHERE		num_solicitud IN(SELECT num_solicitud FROM ss_solicitudes_virtual)
		AND			empresa = '001'
		AND			status_solicitud = 'AT'
		INTO		TEMP ss_autorizacion_virtual WITH NO LOG;
		
		SELECT		numcte, MAX(correo_elec) AS correo_elec
		FROM		bdinteg:si_correos
		WHERE		numcte IN(SELECT numcte FROM ss_clienteslargos_virtual)
		AND			status_correo = 'A'
		AND			valida_correo IN(200,210,220)
		GROUP BY	numcte
		INTO		TEMP si_correos_virtual WITH NO LOG;
		
		SELECT		numcte, telefono
		FROM		bdinteg:si_telefonos_actual
		WHERE		numcte IN(SELECT numcte FROM ss_clienteslargos_virtual)
		AND			tipo_tel = 2
		AND			status_tel = 'A'
		INTO		TEMP si_telefonos_actual_virtual WITH NO LOG;
		
		SELECT		num_credito, SUM(monto_otorgado) AS monto_otorgado
		FROM		bdicred:sd_maesdoshist
		WHERE		fecha BETWEEN v_fecha_inicio_mes_pasado AND v_fecha_fin_mes_pasado
		AND			empresa = '001'
		AND         num_credito IN(SELECT num_solicitud FROM ss_solicitudes_virtual WHERE num_producto IN('6001','6600','7800'))
		GROUP BY	num_credito
		INTO		TEMP sd_maesdoshist_virtual WITH NO LOG;
		
		SELECT		num_credito, SUM(monto_otorgado) AS monto_otorgado
		FROM		bdicred:sd_maesdoshistcrd
		WHERE		fecha BETWEEN v_fecha_inicio_mes_pasado AND v_fecha_fin_mes_pasado
		AND			empresa = '001'
		AND         num_credito IN(SELECT num_solicitud FROM ss_solicitudes_virtual WHERE num_producto IN('6011','6300','6400','6800','7600','7700'))
		GROUP BY	num_credito
		INTO		TEMP sd_maesdoshistcrd_virtual WITH NO LOG;
		
		FOREACH WITH HOLD
			
			SELECT		SOL.fecha_insert, A.fecha_salida, SOL.num_solicitud, SOL.numcte, 
						CL.nombre_cliente, C.correo_elec, T.telefono, SOL.num_producto, SOL.status_solicitud,
						SS.descripcion, SOL.monto_solicitado, SOL.monto_autorizado, SDO.monto_otorgado, SDOCRD.monto_otorgado 
			INTO 		v_fecha_solicitud, v_fecha_autorizacion, v_num_solicitud, v_num_cliente,
						v_nombre_cliente, v_correo, v_num_movil, v_num_producto, v_status_solicitud, 
						v_desc_status_sol, v_monto_solicitado,v_monto_autorizado, v_monto_otorgado_sdos, v_monto_otorgado_sdoscrd    
			FROM    	ss_solicitudes_virtual SOL
			INNER JOIN	bdisolic:ss_status_sol SS ON SOL.status_solicitud = SS.status_solicitud
			INNER JOIN  ss_clienteslargos_virtual CL ON SOL.numcte = CL.numcte
			LEFT JOIN   ss_autorizacion_virtual A ON SOL.num_solicitud = A.num_solicitud
			LEFT JOIN   si_correos_virtual C ON SOL.numcte = C.numcte
			LEFT JOIN   si_telefonos_actual_virtual T ON CL.numcte = T.numcte
			LEFT JOIN	sd_maesdoshist_virtual SDO ON SOL.num_solicitud = SDO.num_credito
			LEFT JOIN	sd_maesdoshist_virtual SDOCRD ON SOL.num_solicitud = SDOCRD.num_credito
			
			IF(v_monto_otorgado_sdos IS NULL) THEN
				LET v_monto_otorgado = v_monto_otorgado_sdoscrd;
			ELSE 
				LET v_monto_otorgado = v_monto_otorgado_sdos;
			END IF;
			
			-- ABRE COMMIT'S PARCIALES
			IF (v_comienza_commit = 0) THEN
                LET v_comienza_commit = 1;
                BEGIN WORK;
            END IF;

            INSERT INTO bdisolic:ss_clientes_largos_temp VALUES(v_fecha_solicitud, v_fecha_autorizacion, v_num_solicitud, v_num_cliente,
																v_nombre_cliente, v_correo, v_num_movil, v_num_producto, v_status_solicitud, 
																v_desc_status_sol, v_monto_solicitado,v_monto_autorizado, v_monto_otorgado);

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
		
		SELECT 	COUNT(num_solicitud)
		INTO	v_cuenta_registros
		FROM 	ss_clientes_largos_temp;
		
		
		IF (v_cuenta_registros > 0) THEN
		
			-- Generacion del Reporte (Resultados_ClientesLargos_DDMMAAAA.txt)
			let vsql = '';
			let vsql = 'echo "fecha_insert|fecha_aut|num_solicitud|numcte|Nombre Cliente|Mail|Cel|num_producto|status_solicitud|status_solicitud_nombre|monto_solicitado|monto_autorizado|monto_otorgado">/RESPALDOSNEW/Ctes_Largos/Resultados_ClientesLargos_'||LPAD (MONTH(today),2,"0")||'_'||YEAR(today)||'.csv';
			system vsql;  
			
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /RESPALDOSNEW/Ctes_Largos/QA_archivo.unl select fecha_solicitud, fecha_autorizacion, num_solicitud, num_cliente, nombre_cliente, correo, num_movil, num_producto, status_solicitud, desc_status_sol, monto_solicitado, monto_autorizado, monto_otorgado from ss_clientes_largos_temp order by fecha_solicitud, num_solicitud;">/RESPALDOSNEW/Ctes_Largos/QA_Script.sql';      
			system vsql;
			
			let vsql='chmod a+rwx /RESPALDOSNEW/Ctes_Largos/QA_Script.sql';
			System vsql;
			
			let vsql = '';
			let vsql= 'dbaccess bdisolic /RESPALDOSNEW/Ctes_Largos/QA_Script.sql';
			system vsql;
			
			let vsql = vsql;
			let vsql ='rm /RESPALDOSNEW/Ctes_Largos/QA_Script.sql';
			
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /RESPALDOSNEW/Ctes_Largos/QA_archivo.unl >> /RESPALDOSNEW/Ctes_Largos/Resultados_ClientesLargos_"||LPAD (MONTH(today),2,"0")||'_'||YEAR(today)||'.csv';
			system vsql;
			let vsql ='rm /RESPALDOSNEW/Ctes_Largos/QA_archivo.unl';
			system vsql; 
			
		ELSE
					
			--GeneraciÃ³n de Reporte Resultados_ClientesLargos_DDMMAAAA.txt sin informaciÃ³n a reportar
			let vsql = '';
			let vsql = 'echo "<<< No hay informaciÃ³n a reportar >>>"> /RESPALDOSNEW/Ctes_Largos/Resultados_ClientesLargos_'||LPAD (MONTH(today),2,"0")||'_'||YEAR(today)||'.csv';
			system vsql;
			
		END IF;
		
		-- Se eliminan tablas temporales si es que existen
		DROP TABLE IF EXISTS "informix".ss_clientes_largos_temp;
		DROP TABLE IF EXISTS "informix".ss_solicitudes_virtual;
		DROP TABLE IF EXISTS "informix".ss_clienteslargos_virtual;
		DROP TABLE IF EXISTS "informix".ss_autorizacion_virtual;
		DROP TABLE IF EXISTS "informix".si_correos_virtual;
		DROP TABLE IF EXISTS "informix".si_telefonos_actual_virtual;
		DROP TABLE IF EXISTS "informix".sd_maesdoshist_virtual;
		DROP TABLE IF EXISTS "informix".sd_maesdoshistcrd_virtual;
		
		RETURN cCodRet;
	END
END PROCEDURE;