CREATE PROCEDURE "informix".sp_gen_rep_acumulado_quitacondonaciones()
RETURNING CHAR(6) AS cod_ret
--DECLARACION Y DEFINICION DE VARIABLES
	DEFINE vExiste 		INTEGER;
	DEFINE vExiste2		INTEGER;
	DEFINE vRutaArchivo CHAR(100);
	DEFINE vNombreArchivoCondonacion CHAR(26);
	DEFINE vNombreArchivoQuita	CHAR(20);
	DEFINE vFechaHoy DATE;
	DEFINE vFechaMesAnterior DATE;
	DEFINE vEmpresa CHAR(3);
	DEFINE vCommand CHAR(4000);
	DEFINE vDia 		CHAR(2);
	DEFINE vMes 		CHAR(2);
	DEFINE vAnio		CHAR(4);

	LET vDia = '';
	LET vMes = '';
	LET vAnio = '';
	LET vExiste = 0;
	LET vExiste2 = 0;
	LET vRutaArchivo = ''; --PARAMETRO PRUEBA  /informix/roman/reportes/
	LET vNombreArchivoCondonacion = 'Credito_CondonacionCierre_';
	LET vNombreArchivoQuita = 'Credito_QuitaCierre_';
	LET vEmpresa = '001';
	LET vCommand = '';

	BEGIN
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/informix/sp_gen_rep_acumulado_quitacondonaciones.out";
		--TRACE ON;
		SELECT TRIM(valor) INTO vRutaArchivo FROM bdicred:"informix".sd_param WHERE cod_param = 994;

		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy) 
		INTO vFechaHoy, vDia, vMes, vAnio
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = vEmpresa;
		
		/*LET vFechaHoy = to_date('01/10/2020', "%d/%m/%Y");
		LET vAnio = YEAR(vFechaHoy);
		LET vMes = MONTH(vFechaHoy);
		LET vDia = DAY(vFechaHoy);*/
		
		IF MONTH(vFechaHoy) < 10 THEN
			LET vMes = '0' || TRIM(vMes);
		END IF;

		IF DAY(vFechaHoy) < 10 THEN
			LET vDia = '0' || TRIM(vDia);
		END IF;

		LET vFechaMesAnterior = vFechaHoy - 1 UNITS MONTH;

		--IF pReporte = '1' THEN
			SELECT COUNT(*) 
			INTO vExiste
			FROM bdicred:sd_bitacora_quitacondonacion 
			WHERE fecha_insert >= vFechaMesAnterior AND indicador_proceso = 'C';
		
			IF (vExiste > 0) THEN 
				LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);

				LET vCommand = '';
				LET vCommand = 'echo "SELECT CAST(ROW_NUMBER() OVER (ORDER BY A.num_credito) AS INT) num, A.* FROM (' ||
				               'SELECT  b.num_credito, b.numcte,c.sucursal, b.meses_vencidos,c.fecha_apertura,' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) ' ||
							   'ELSE MONTH(c.fecha_apertura) || ''' || '''' || 'END mes, b.meses_historia, d.monto_otorgado,c.num_producto,g.grupo, ' ||							   
							   'b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente, b.int_vencido,b.int_moratorio,b.iva_int_vigente,b.iva_int_vencido,' ||
							   'b.iva_int_mora,b.monto_condonado,b.pago_realizado,b.cap_vigente_cq, b.cap_vencido_cq,b.int_vigente_cq,b.int_vencido_cq,b.int_moratorio_cq, ' ||   
							   'b.iva_int_vigente_cq,b.iva_int_vencido_cq,b.iva_int_mora_cq,b.fecha_pago,g.evalua_cc,c.num_producto producto, g.score_prop score_originacion_interno,g.bs_score score_buro,' ||
							   'today fecha_reporte,c.tasa_interes tasa_contrato ' ||							   
							   'FROM bdicred:sd_bitacora_quitacondonacion b  ' ||
							   'INNER JOIN bdicred:sd_maecred c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdos d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito  ' ||						   
							   'WHERE b.indicador_proceso = ''C''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||
							   'UNION ' ||							   
							   'SELECT b.num_credito, b.numcte,c.sucursal, b.meses_vencidos,c.fecha_apertura,' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) ' ||
							   'ELSE MONTH(c.fecha_apertura) || ''' || '''' || 'END mes, b.meses_historia, d.monto_otorgado,c.num_producto,g.grupo, ' ||
							   'b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente, b.int_vencido,b.int_moratorio,b.iva_int_vigente,b.iva_int_vencido, ' ||
							   'b.iva_int_mora,b.monto_condonado,b.pago_realizado,b.cap_vigente_cq, b.cap_vencido_cq,b.int_vigente_cq,b.int_vencido_cq,b.int_moratorio_cq, ' ||
							   'b.iva_int_vigente_cq,b.iva_int_vencido_cq,b.iva_int_mora_cq,b.fecha_pago,g.evalua_cc,i.producto, g.score_prop score_originacion_interno,g.bs_score score_buro,' ||
							   'today fecha_reporte,c.tasa_interes tasa_contrato ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdoscrd d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito ' ||
							   'LEFT JOIN bdicheq:sc_maechq i ON i.num_cte = b.numcte AND i.status_cta= 1 AND i.cuenta= b.num_cuenta_chq ' ||
							   'WHERE b.indicador_proceso = ''C''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') )A' ||						   
							   '; " >> ' ||  TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
					
				system TRIM(vCommand);
				
				LET vCommand = 'chmod 777 '  || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);
								
				LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				system TRIM(vCommand);
								
				system "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || ".txt";
				system 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || "_1.txt";
				--system 'rm ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_condonacion.sql;';
				
			ELSE 
				system "touch " || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivoCondonacion) || vDia || vMes || vAnio || ".txt";	
			END IF;
		--END IF;
		
		/*LET vFechaHoy = to_date('01/09/2020', "%d/%m/%Y");
		LET vAnio = YEAR(vFechaHoy);
		LET vMes = MONTH(vFechaHoy);
		LET vDia = DAY(vFechaHoy);
		
		IF MONTH(vFechaHoy) < 10 THEN
			LET vMes = '0' || TRIM(vMes);
		END IF;

		IF DAY(vFechaHoy) < 10 THEN
			LET vDia = '0' || TRIM(vDia);
		END IF;
		
		LET vFechaMesAnterior = vFechaHoy - 1 UNITS MONTH;*/
		
		--IF pReporte = '2' THEN
			SELECT COUNT(*) 
			INTO vExiste2
			FROM bdicred:sd_bitacora_quitacondonacion 
			WHERE fecha_insert >= vFechaMesAnterior AND indicador_proceso = 'Q';
		

			IF (vExiste2 > 0) THEN 
				LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);

				LET vCommand = '';
				LET vCommand = 'echo "SELECT CAST(ROW_NUMBER() OVER (ORDER BY A.num_credito) AS INT) num, A.* FROM (' ||
				               'SELECT b.num_credito, b.numcte,b.fecha_ult_disp_com,c.sucursal,b.monto_ult_disp_comp, ' ||
							   'b.abono_mensual_al_quita,d.fecha_ult_mov,b.tipo_ult_mov, b.meses_vencidos,j.num_tarjeta,c.fecha_apertura, '||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) '||
							   'ELSE MONTH(c.fecha_apertura)||''' || ''''||' END mes, b.meses_historia, d.monto_otorgado, ' ||
							   'c.num_producto,g.grupo, b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente,b.int_vencido,b.int_moratorio, ' ||
							   'b.iva_int_vigente,b.iva_int_vencido,b.iva_int_mora,b.mto_quita,b.cap_vigente_cq,b.cap_vencido_cq, ' ||
							   'b.int_vigente_cq,b.int_vencido_cq, b.int_moratorio_cq, b.iva_int_vigente_cq ,b.iva_int_vencido_cq, ' ||
							   'b.iva_int_mora_cq,b.sdo_remanente_dq,b.cap_vigente_dq,b.cap_vencido_dq,b.int_vigente_dq,b.int_vencido_dq, ' ||
							   'b.int_moratorio_dq,b.iva_int_vigente_dq,b.iva_int_vencido_dq,b.iva_int_mora_dq,b.fecha_liquidacion, ' ||
							   'b.fecha_negociacion,b.porc_quita,b.porc_recuperado,d.mto_capitalizado monto_recuperado,g.evalua_cc,c.num_producto, ' ||
							   'g.score_prop score_originacion_interno,g.bs_score score_buro,today fecha_reporte,c.tasa_interes tasa_contrato ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecred c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdos d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito ' ||
							   'LEFT JOIN bdicred:sd_tarjeta j ON j.num_credito = b.num_credito ' || 							   
							   'WHERE b.indicador_proceso = ''Q''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||
							   'AND j.status_tar = ''A'' AND j.secuencia = (' ||
							   'SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = b.num_credito)' ||
							   'UNION ' ||
							   'SELECT b.num_credito, b.numcte,b.fecha_ult_disp_com,c.sucursal,b.monto_ult_disp_comp, ' ||
							   'b.abono_mensual_al_quita,d.fecha_ult_mov,b.tipo_ult_mov, b.meses_vencidos,j.num_tarjeta,c.fecha_apertura, ' ||
							   'YEAR(c.fecha_apertura) anio, CASE WHEN MONTH(c.fecha_apertura) < 10 THEN ' || '''0''' || ' || MONTH(c.fecha_apertura) '||
							   'ELSE MONTH(c.fecha_apertura)||''' || ''''||' END mes, b.meses_historia, d.monto_otorgado, ' ||
							   'c.num_producto,g.grupo, b.sdo_credito,b.cap_vigente,b.cap_vencido,b.int_vigente,b.int_vencido,b.int_moratorio, ' ||
							   'b.iva_int_vigente,b.iva_int_vencido,b.iva_int_mora,b.mto_quita,b.cap_vigente_cq,b.cap_vencido_cq, ' ||
							   'b.int_vigente_cq,b.int_vencido_cq, b.int_moratorio_cq, b.iva_int_vigente_cq ,b.iva_int_vencido_cq, ' ||
							   'b.iva_int_mora_cq,b.sdo_remanente_dq,b.cap_vigente_dq,b.cap_vencido_dq,b.int_vigente_dq,b.int_vencido_dq, ' ||
							   'b.int_moratorio_dq,b.iva_int_vigente_dq,b.iva_int_vencido_dq,b.iva_int_mora_dq,b.fecha_liquidacion, ' ||
							   'b.fecha_negociacion,b.porc_quita,b.porc_recuperado,d.mto_capitalizado monto_recuperado,g.evalua_cc,i.producto,  ' ||
							   'g.score_prop score_originacion_interno,g.bs_score score_buro,today fecha_reporte,c.tasa_interes tasa_contrato  ' ||
							   'FROM bdicred:sd_bitacora_quitacondonacion b ' ||
							   'INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = b.num_credito ' ||
							   'INNER JOIN bdicred:sd_maesdoscrd d ON d.num_credito = b.num_credito ' ||
							   'LEFT JOIN bdisolic:ss_revision_determinacion g ON g.empresa=''001'' AND g.num_solicitud = b.num_credito  ' ||
							   'LEFT JOIN bdicheq:sc_maechq i ON i.num_cte = b.numcte AND i.status_cta= 1 AND i.cuenta= b.num_cuenta_chq ' ||
							   'LEFT JOIN bdicred:sd_tarjeta j ON j.num_credito = b.num_credito ' ||
							   'WHERE b.indicador_proceso = ''Q''' || ' AND b.fecha_insert >= mdy(' || MONTH(vFechaMesAnterior) || ',' || DAY(vFechaMesAnterior) ||',' || YEAR(vFechaMesAnterior) || ') ' ||						   
							   'AND j.status_tar = ''A'' AND j.secuencia = (' ||
							   'SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE num_credito = b.num_credito) )A' ||
							   '; " >> ' ||  TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
							   
				system TRIM(vCommand);
				
				LET vCommand = 'chmod 777 '  || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);
								
				LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
				system TRIM(vCommand);
								
				system "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || ".txt";
				system 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || "_1.txt";
				--system 'rm ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_cierre_quita.sql;';
			ELSE 
				system "touch " || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivoQuita) || vDia || vMes || vAnio || ".txt";	
			END IF;
		--END IF;

			RETURN "000000";
	END
END PROCEDURE;