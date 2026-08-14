CREATE PROCEDURE "informix".sp_acumuladocheques_semanal(vFechaInicio DATE,vFechaFin DATE)
RETURNING CHAR(5), CHAR(100)

	DEFINE sql_err				INTEGER;
	DEFINE isam_err				INTEGER;
	DEFINE error_info			CHAR(100);
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensajeRetorno		CHAR(100);

	DEFINE  vSQL				CHAR(1200);
	DEFINE vFechaNombreArchivo	CHAR(8);
	DEFINE vFechaInicioAux		CHAR(10);
	DEFINE vFechaFinAux			CHAR(10);			

	DEFINE vEsDomingo			INTEGER;
	DEFINE vEsLunes				INTEGER;
	DEFINE vResDiaIni			INTEGER;
	DEFINE vResDiaFin			INTEGER;

	LET sql_err				= 0;          
	LET isam_err			= 0;        
	LET error_info			= '';
	LET vCodigoRetorno		= '0000';
	LET vMensajeRetorno 	= 'Proceso Exitoso';

	LET vSQL				= '';


	LET vFechaNombreArchivo = '';
	LET vFechaInicioAux		= '';
	LET vFechaFinAux		= '';

	LET vEsDomingo			= -1;
	LET vEsLunes			= -1;
	LET vResDiaIni			= 7;
	LET vResDiaFin			= 1;

BEGIN

	-- MANEJO DEL ERROR
	ON EXCEPTION SET sql_err, isam_err, error_info

		--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
		--TRACE ON;

		RETURN sql_err, isam_err || ' ' || error_info;

	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;  
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_semanal_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
	--TRACE ON;

/*original
	WHILE (vEsLunes <> 1 AND vEsDomingo <> 0)

		SELECT fecha_hoy - vResDiaIni UNITS DAY, fecha_hoy - vResDiaFin UNITS DAY
		INTO vFechaInicio, vFechaFin
		FROM bdinteg:si_fechas 
		WHERE empresa = '001';

		SELECT weekday(vFechaInicio), weekday(vFechaFin)
		INTO vEsLunes, vEsDomingo
		FROM bdinteg:si_fechas 
		WHERE empresa = '001';

		LET vResDiaIni = vResDiaIni + 1;
		LET vResDiaFin = vResDiaFin + 1;

	END WHILE;
	*/--original
	--LET vFechaNombreArchivo = LPAD(MONTH(vFechaFin),2,'0') || LPAD(DAY(vFechaFin),2,'0') || YEAR(vFechaFin);  
	LET vFechaNombreArchivo = LPAD(MONTH(CURRENT),2,'0') || LPAD(DAY(CURRENT),2,'0') || YEAR(CURRENT);  
	
	LET vFechaInicioAux = LPAD(MONTH(vFechaInicio),2,'0') || '-' || LPAD(DAY(vFechaInicio),2,'0') || '-' || YEAR(vFechaInicio);
	LET vFechaFinAux = LPAD(MONTH(vFechaFin),2,'0') || '-' || LPAD(DAY(vFechaFin),2,'0') || '-' || YEAR(vFechaFin);
	
	LET vSQL = ''; 	
	LET vSQL = 'echo "SET ISOLATION TO DIRTY READ;\n' || 
		'SELECT fech_alt, TRIM(cuenta) AS cuenta, sucursal, transacc, monto_tot, cancelad\n' ||
		'FROM bdicheq:sc_movhis\n' ||
		'WHERE fech_alt >= ''"' || vFechaInicioAux || '"''\n' ||
		'AND fech_alt <= ''"' || vFechaFinAux || '"''\n' ||
		'INTO TEMP tmp_sc_movhis WITH NO LOG;\n\n' ||

		'UNLOAD TO /resplogifx/trancheq' || vFechaNombreArchivo || '.txt\n' ||
		'SELECT fech_alt, cuenta, sucursal, transacc, monto_tot\n'||
		'FROM tmp_sc_movhis\n' ||
		'WHERE transacc NOT IN (SELECT transacc FROM bditarjeta:td_catalogcheques)\n'||						  
		'AND cancelad <> ''"' || 'S' || '"''\n' ||
		'ORDER BY fech_alt;" > /resplogifx/sql_trancheq.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'chmod 777 /resplogifx/sql_trancheq.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'dbaccess bditarjeta /resplogifx/sql_trancheq.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL ='rm /resplogifx/sql_trancheq.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'chmod 777 /resplogifx/trancheq' || vFechaNombreArchivo || '.txt';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'gzip -9 /resplogifx/trancheq' || vFechaNombreArchivo || '.txt';
	SYSTEM vSQL;

	RETURN vCodigoRetorno, vMensajeRetorno;
END;

END PROCEDURE;