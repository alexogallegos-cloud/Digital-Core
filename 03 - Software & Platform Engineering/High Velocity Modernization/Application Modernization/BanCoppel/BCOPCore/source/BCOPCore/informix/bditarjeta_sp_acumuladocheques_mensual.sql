CREATE PROCEDURE "informix".sp_acumuladocheques_mensual (vFechaInicio DATE,vFechaFin DATE)
RETURNING CHAR(5), CHAR(100)

	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	CHAR(100);
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensajeRetorno		CHAR(100);

	DEFINE  vSQL				CHAR(1200);

	DEFINE vDiaActual			CHAR(2);
	DEFINE vMesActual			CHAR(2);
	DEFINE vMesAnterior			CHAR(2);
	DEFINE vAnioActual			CHAR(4);
	--DEFINE vFechaInicio		DATE;
	--DEFINE vFechaFin			DATE;
	DEFINE vFechaNombreArchivo	CHAR(8);

	DEFINE vContador			INTEGER;
	DEFINE vCommit				INTEGER;

	DEFINE vProducto			CHAR(4);
	DEFINE vTransacc			CHAR(4);
	DEFINE vMonto				MONEY;
	DEFINE vCantidad			INTEGER;
	DEFINE vDescripcion			CHAR(50);
	DEFINE vPeriodo				CHAR(6);

	LET sql_err				= 0;          
	LET isam_err			= 0;        
	LET error_info			= '';
	LET vCodigoRetorno		= '0000';
	LET vMensajeRetorno 	= 'Proceso Exitoso';

	LET vDiaActual			= '';
	LET vMesActual			= '';
	LET vMesAnterior		= '';
	LET vAnioActual			= '';

	--LET vFechaInicio		= TODAY;
	--LET vFechaFin			= TODAY;
	LET vFechaNombreArchivo = '';

	LET vContador		= 0;
	LET vCommit			= 1000;

	LET vProducto		= '';
	LET vTransacc		= '';
	LET vMonto			= 0;
	LET vCantidad		= 0;
	LET vDescripcion	= '';
	LET vPeriodo		= '';

BEGIN
	-- MANEJO DEL ERROR
	ON EXCEPTION SET sql_err, isam_err, error_info

		--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
		--TRACE ON;

		RETURN sql_err, isam_err || ' ' || error_info;

	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;  
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/RESPALDOSNEW/ReporteCATIT/JOB408/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
	--TRACE ON;

	LET vDiaActual			= '01';
	LET vMesActual			= LPAD(MONTH(CURRENT),2,'0');
	LET vMesAnterior		= LPAD(MONTH(CURRENT - 1 UNITS MONTH),2,'0');
	LET vMesAnterior		= LPAD(MONTH(vFechaFin),2,'0');
	LET vAnioActual			= LPAD(YEAR (vFechaInicio),4,'0');

	--LET vFechaInicio		= TO_DATE( vAnioActual || '-' || vMesAnterior || '-' || vDiaActual, '%Y-%m-%d');
	--LET vFechaFin			= TO_DATE( vAnioActual || '-' || vMesActual || '-' || vDiaActual, '%Y-%m-%d') - 1 UNITS DAY;
	--LET vFechaNombreArchivo = LPAD(MONTH(vFechaFin),2,'0') || LPAD(DAY(vFechaFin),2,'0') || YEAR(vFechaFin);
	LET vFechaNombreArchivo = LPAD(MONTH(CURRENT),2,'0') || LPAD(DAY(CURRENT),2,'0') || YEAR(CURRENT);

	SELECT producto, transacc, cancelad, monto_tot as monto 
	FROM bdicheq:sc_movhis 
	WHERE fech_alt >= vFechaInicio
	AND fech_alt <= vFechaFin
	INTO TEMP tmp_sc_movhis WITH NO LOG;

	BEGIN;
		LET vContador = 0;

		FOREACH WITH HOLD
			SELECT producto, transacc, monto
			INTO vProducto, vTransacc, vMonto
			FROM tmp_sc_movhis
			WHERE transacc NOT IN (SELECT transacc FROM bditarjeta:td_catalogcheques) 								  
			AND cancelad <> 'S'

			INSERT INTO acumuladocheques_paso(producto, transacc, monto)
			VALUES (vProducto, vTransacc, vMonto);

			IF vContador = vCommit THEN
				COMMIT;
				LET vContador = 0;
				UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:acumuladocheques_paso;
				BEGIN WORK;
			ELSE 
				LET vContador = vContador + 1;
			END IF;
		END FOREACH;
	COMMIT;

	BEGIN;
		LET vContador = 0;

		FOREACH WITH HOLD
			SELECT producto, transacc, count(*) as cantidad, sum(monto) as monto
			INTO vProducto, vTransacc, vCantidad, vMonto
			FROM bditarjeta:acumuladocheques_paso
			GROUP BY producto, transacc

			INSERT INTO bditarjeta:acumuladocheques_paso1(periodo, producto, transacc, cantidad, monto)
			VALUES ( vAnioActual || vMesAnterior, vProducto, vTransacc, vCantidad, vMonto);

			IF vContador = vCommit THEN
				COMMIT;
				LET vContador = 0;
				UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:acumuladocheques_paso1;
				BEGIN WORK;
			ELSE 
				LET vContador = vContador + 1;
			END IF;
		END FOREACH;
	COMMIT;

	BEGIN;
		LET vContador = 0;

		FOREACH WITH HOLD
			SELECT a.periodo, a.producto, a.transacc, TRIM(b.descripcion) AS descripcion, a.cantidad, a.monto 
			INTO vPeriodo, vProducto, vTransacc, vDescripcion, vCantidad, vMonto
			FROM bditarjeta:acumuladocheques_paso1 a
			JOIN bdinteg:si_transacc b 
			ON b.numero = a.transacc

			INSERT INTO bditarjeta:acumuladocheques(periodo, producto, transacc, descripcion, cantidad,monto)
			VALUES (vPeriodo, vProducto, vTransacc, vDescripcion, vCantidad, vMonto);

			IF vContador = vCommit THEN
				COMMIT;
				LET vContador = 0;
				BEGIN WORK;
			ELSE 
				LET vContador = vContador + 1;
			END IF;
		END FOREACH;
	COMMIT;

	LET vSQL = ''; 	
  LET vSQL = 'echo "SET ISOLATION TO DIRTY READ;\n' || 
			'UNLOAD TO /resplogifx/finan_tdd' || vFechaNombreArchivo || '.txt\n' ||
			'SELECT periodo, producto, transacc, descripcion, sum(cantidad) AS cantidad, sum(monto) AS monto\n' ||
			'FROM bditarjeta:acumuladocheques\n' ||
			'GROUP BY periodo, producto, transacc, descripcion\n' ||
			'ORDER BY producto;" > /resplogifx/sql_acumuladocheques.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'chmod 777 /resplogifx/sql_acumuladocheques.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'dbaccess bditarjeta /resplogifx/sql_acumuladocheques.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL ='rm /resplogifx/sql_acumuladocheques.sql';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'chmod 777 /resplogifx/finan_tdd' || vFechaNombreArchivo || '.txt';
	SYSTEM vSQL;

	LET vSQL = '';
	LET vSQL = 'gzip -9 /resplogifx/finan_tdd' || vFechaNombreArchivo || '.txt';
	SYSTEM vSQL;

	DROP TABLE tmp_sc_movhis;
	
	TRUNCATE TABLE bditarjeta:acumuladocheques_paso;
	TRUNCATE TABLE bditarjeta:acumuladocheques_paso1;
	TRUNCATE TABLE bditarjeta:acumuladocheques;

	RETURN vCodigoRetorno, vMensajeRetorno;
END;

END PROCEDURE;