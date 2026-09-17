CREATE PROCEDURE "informix".sp_gen_rep_corte_quitacondonaciones()
RETURNING CHAR(6) AS cod_ret

--DECLARACION Y DEFINICION DE VARIABLES
	DEFINE vDia 		CHAR(2);
	DEFINE vMes 		CHAR(2);
	DEFINE vAnio		CHAR(4);
	DEFINE vFechaHoy	DATE;
	DEFINE vFechaSemanaAnterior	DATE;
	DEFINE vEmpresa 	CHAR(3);
	DEFINE vExiste 		INTEGER;
	DEFINE vRutaArchivo CHAR(100);
	DEFINE vNombreArchivo CHAR(26);
	DEFINE vCommand CHAR(2000);

	LET vCommand = '';
	LET vDia = '';
	LET vMes = '';
	LET vAnio = '';
	LET vFechaHoy = '';
	LET vEmpresa = '001';
	LET vExiste = 0;
	LET vRutaArchivo = ''; --PARAMETRO PRUEBA /informix/roman/reportes/
	LET vNombreArchivo = 'Corte_QuitasCondonaciones_';

	BEGIN
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/informix/sp_gen_rep_corte_quitacondonaciones.out";
		--TRACE ON;
		SELECT TRIM(valor) INTO vRutaArchivo FROM bdicred:"informix".sd_param WHERE cod_param = 994;

		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy) 
		INTO vFechaHoy, vDia, vMes, vAnio
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = vEmpresa;

		IF MONTH(vFechaHoy) < 10 THEN
			LET vMes = '0' || TRIM(vMes);
		END IF;

		IF DAY(vFechaHoy) < 10 THEN
			LET vDia = '0' || TRIM(vDia);
		END IF;
		
		LET vFechaSemanaAnterior = vFechaHoy - 7 UNITS DAY;

		
		--Proceso de Generacion de Reporte
		SELECT COUNT (b.num_credito)
		INTO vExiste
		FROM bdicred:"informix".sd_bitacora_quitacondonacion b
		WHERE b.estatus_proceso IN ('PR','MA','FI') AND b.fecha_insert >= vFechaSemanaAnterior;

		IF vExiste > 0 THEN--EXISTEN REGISTROS PARA HACER EL REPORTE
			LET vCommand  = 'echo "UNLOAD TO ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_corte_quitascondonacion.sql;';
			system vCommand;
			
			LET vCommand = '';
			LET vCommand = 'echo "SELECT b.numcte, b.num_credito, b.pago_realizado, CASE WHEN (b.pago_realizado = 0 AND b.mto_quita > 0) or (b.pago_realizado= 0 AND b.mto_quita = 0) THEN'|| '''NO REALIZO PAGO ''' ||'WHEN (b.pago_realizado > 0 AND b.pago_realizado < b.mto_quita) THEN ' || '''PAGO INCOMPLETO '''|| ' END FROM bdicred:sd_bitacora_quitacondonacion b WHERE b.fecha_insert >=mdy(' || MONTH(vFechaSemanaAnterior) || ',' || DAY(vFechaSemanaAnterior) ||',' || YEAR(vFechaSemanaAnterior) || ') and b.estatus_proceso = ''PR'' and b.indicador_proceso = ''Q'' UNION SELECT b.numcte, b.num_credito, b.pago_realizado, CASE WHEN (b.pago_realizado = 0 AND b.monto_condonado > 0) or (b.pago_realizado= 0 AND b.monto_condonado = 0) THEN'|| '''NO REALIZO PAGO ''' ||'WHEN (b.pago_realizado > 0 AND b.pago_realizado < b.monto_condonado) THEN' || '''PAGO INCOMPLETO '''|| 'END FROM bdicred:sd_bitacora_quitacondonacion b WHERE b.fecha_insert >=mdy(' || MONTH(vFechaSemanaAnterior) || ',' || DAY(vFechaSemanaAnterior) ||',' || YEAR(vFechaSemanaAnterior) || ') and b.estatus_proceso = ''PR'' and b.indicador_proceso = ''C'' UNION SELECT b.numcte, b.num_credito, b.pago_realizado, ''PAGO COMPLETO'' FROM bdicred:sd_bitacora_quitacondonacion b WHERE b.fecha_insert >=mdy(' || MONTH(vFechaSemanaAnterior) || ',' || DAY(vFechaSemanaAnterior) ||',' || YEAR(vFechaSemanaAnterior) || ') and b.estatus_proceso = ''FI''; " >> '|| TRIM(vRutaArchivo) || 'ejecuta_reporte_corte_quitascondonacion.sql;';		

			
			system vCommand;
			
			LET vCommand = 'chmod 777 '  || TRIM(vRutaArchivo) || 'ejecuta_reporte_corte_quitascondonacion.sql;';
			system vCommand;
			
			LET vCommand = 'dbaccess bdicred ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_corte_quitascondonacion.sql;';
			system vCommand;

			system "sed 's/|$//g' " || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || vDia || vMes || vAnio || ".txt";
			system 'rm ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || vDia || vMes || vAnio || "_1.txt";
			--system 'rm ' || TRIM(vRutaArchivo) || 'ejecuta_reporte_corte_quitascondonacion.sql;';

			RETURN '00000';
		ELSE 
			system "touch " || TRIM(vRutaArchivo) ||  TRIM(vNombreArchivo) || vDia || vMes || vAnio || ".txt";

			RETURN '00005';
		END IF;
	END;
END PROCEDURE;