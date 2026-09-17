CREATE PROCEDURE "informix".sp_totalesmovimientoscoppel(cEmpresa CHAR(3), cTipoMov CHAR(2), dFechaAct DATE)
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

--SET DEBUG FILE TO '/tmp/sp_totalesmovimientoscoppel.out';
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
		Set debug file to '/RESPALDOS/sp_totalesmovimientoscoppel.out';
		trace on;
            	LET iSecuencia	= iSecuencia;
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE tipomovto = 'A'

		SELECT count(tipomovto), tipomovto, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE sucursal = CSucursal
		  AND tipomovto = 'A'
		GROUP BY 2, 3;

		LET iTipoMov = 8;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);						
	
		LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');

		INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001', iSecuencia,CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH
	/*dsb-17/09/2012	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE tipomovto IN ('C')

		SELECT count(tipomovto),fecha_insert, fecha_insert
		INTO iCantidad, dFecha, dFechaMov
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE sucursal = CSucursal
		  AND tipomovto IN ('C')
		GROUP BY fecha_insert, fecha_insert;

		LET iTipoMov = 9;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
		
		INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH*/

	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE tipomovto IN ('R','C')

		SELECT count(tipomovto),fecha_insert, fecha_insert
		INTO iCantidad, dFecha, dFechaMov
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE sucursal = CSucursal
		  AND tipomovto IN ('R','C')
		GROUP BY fecha_insert, fecha_insert;

		LET iTipoMov = 10;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
		
		INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH

	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE tipomovto = ''

		SELECT count(tipomovto), tipomovto, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE sucursal = CSucursal
		  AND tipomovto = ''
		GROUP BY 2, 3;

		LET iTipoMov = 13;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
		
		INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia,  sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001', iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH
	
	FOREACH

		SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE tipomovto = 'M'

		SELECT count(tipomovto), tipomovto, fecha_insert, fecha_insert
		INTO iCantidad, cTipoMov, dFecha, dFechaMov
		FROM bdinteg:"informix".si_archivoscoppeldiario
		WHERE sucursal = CSucursal
		  AND tipomovto = 'M'
		GROUP BY 2, 3;

		LET iTipoMov = 14;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFecha)||"/"||LPAD(MONTH(dFecha),2,0)||"/"||LPAD(DAY(dFecha),2,0);	
		
		LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
		
		INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa, secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iTipoMov ||"|"|| 0 ||"|"|| iCantidad ||"|"|| CSucursal ||"|"|| cFecha ||"|"|| cFechaMov, 'TO', dfecha);

	END FOREACH

RETURN cCodRet;

END;

--*************************************************************************
--| Procedimiento   : "informix".sp_totalesmovimientoscoppel
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Guarda el total de movimientos realizados
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Agosto de 2011
--| Descripción     : Se modifica los formatos de las fechas y se agrega la hora.
--*************************************************************************
--| Modificado por  : Victor Hugo Nuñez
--| Fecha Modifica  : 19 de Julio de 2012
--| Descripción     : Se modifica foreach R,C a C,C y se modifica para el caso de que no obtenga una sucursal
--*************************************************************************
--| Modificado por  : Victor Hugo Nuñez
--| Fecha Modifica  : 17 de Septiembre de 2012
--| Descripción     : Se elimina la totalizacion de los movimientos tipo C como 9 
--*************************************************************************
END PROCEDURE;