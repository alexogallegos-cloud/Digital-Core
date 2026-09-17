CREATE PROCEDURE "informix".sp_batch_totalmovtoscoppel(cEmpresa CHAR(3), cTipoMov CHAR(2), dFechaAct DATE)
RETURNING CHAR(6); ---cod_ret

DEFINE cCodRet			CHAR(6);
DEFINE iSqlErr			INTEGER;

DEFINE cTipoMov			CHAR(5);
DEFINE iTipoMov			INTEGER;
DEFINE iImporte			INTEGER;
DEFINE iCantidad		INTEGER;
DEFINE CSucursal		CHAR(4);
DEFINE dFecha			DATE;
DEFINE dFechaMov		DATE;
DEFINE iSecuencia		INTEGER;
DEFINE cFecha			CHAR(10);
DEFINE cFechaMov		CHAR(19);
DEFINE vHora DATETIME HOUR TO FRACTION(3);

LET cCodRet		= '000000';
LET iSqlErr		= 0;
LET iTipoMov	= 0;
LET iImporte	= 0;
LET iCantidad	= 0;
LET CSucursal	= '';
LET dFecha		= DATE(1);
LET dFechaMov	= DATE(1);
LET iSecuencia	= 0;
LET cFecha		= '1900/01/01';
LET cFechaMov	= '1900/01/01 12:00:00';
LET vHora		= '';

--SET DEBUG FILE TO '/tmp/sp_totalesmovimientoscoppelbatch.out';
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
		Set debug file to '/RESPALDOSNEW/sp_totalesmovimientoscoppelbatch.out';
		trace on;
            	LET iSecuencia	= iSecuencia;
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT secuencia_max INTO iSecuencia
	FROM "informix".si_archivosecuenciamax;
	
	LET iSecuencia = iSecuencia + 1;
	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_tramasbatch
		WHERE clave = 'A'
		AND fecha_insert = dFechaAct

		SELECT count(clave), clave, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM  "informix".si_tramasbatch
		WHERE sucursal = CSucursal
		  AND clave = 'A'
		  AND fecha_insert = dFechaAct
		GROUP BY 2, 3;

		LET iTipoMov = 8;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);						
		
		LET iSecuencia = iSecuencia + 1;

		INSERT INTO  "informix".si_archivoscopdiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001', iSecuencia,CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH
	/*dsb-17/09/2012	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_archivoscopdiario
		WHERE tipomovto IN ('C')

		SELECT count(tipomovto),fecha_insert, fecha_insert
		INTO iCantidad, dFecha, dFechaMov
		FROM  "informix".si_archivoscopdiario
		WHERE sucursal = CSucursal
		  AND tipomovto IN ('C')
		GROUP BY fecha_insert, fecha_insert;

		LET iTipoMov = 9;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = iSecuencia + 1;
		
		INSERT INTO  "informix".si_archivoscopdiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH*/

	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_tramasbatch
		WHERE clave IN ('R','C')
		AND fecha_insert = dFechaAct

		SELECT count(clave),fecha_insert, fecha_insert
		INTO iCantidad, dFecha, dFechaMov
		FROM  "informix".si_tramasbatch
		WHERE sucursal = CSucursal
		  AND clave IN ('R','C')
		  AND fecha_insert = dFechaAct
		GROUP BY fecha_insert, fecha_insert;

		LET iTipoMov = 10;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = iSecuencia + 1;
		
		INSERT INTO  "informix".si_archivoscopdiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH

	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_tramasbatch
		WHERE clave = ''
		AND fecha_insert = dFechaAct

		SELECT count(clave), clave, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM  "informix".si_tramasbatch
		WHERE sucursal = CSucursal
		  AND clave = ''
		  AND fecha_insert = dFechaAct
		GROUP BY 2, 3;

		LET iTipoMov = 13;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = iSecuencia + 1;
		
		INSERT INTO  "informix".si_archivoscopdiario(empresa,secuencia,  sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001', iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH
	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_tramasbatch
		WHERE clave = 'M'
		AND fecha_insert = dFechaAct

		SELECT count(clave), clave, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM  "informix".si_tramasbatch
		WHERE sucursal = CSucursal
		  AND clave = 'M'
		  AND fecha_insert = dFechaAct
		GROUP BY 2, 3;

		LET iTipoMov = 14;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = iSecuencia + 1;
		
		INSERT INTO "informix".si_archivoscopdiario(empresa, secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH
	
	IF iSecuencia > 0 THEN
		UPDATE "informix".si_archivosecuenciamax SET secuencia_max=iSecuencia;
	END IF;

RETURN cCodRet;

END;

--*************************************************************************
--| Procedimiento   : "informix".sp_totalesmovimientoscoppelbatch
--| Versión         : 1.0
--| Creado por      : Maria Elena
--| Fecha creacion  : Mayo de 2013
--| Descripción     : Espejo del procedimiento sp_totalesmovimientoscoppel que Guarda el total de movimientos realizados, 
--| anexo con adecuaciones para los nuevos procesos de generacion de archivos batch
--*************************************************************************
END PROCEDURE;