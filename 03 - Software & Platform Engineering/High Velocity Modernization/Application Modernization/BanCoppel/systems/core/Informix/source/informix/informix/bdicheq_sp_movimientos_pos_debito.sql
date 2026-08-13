CREATE PROCEDURE "informix".sp_movimientos_pos_debito()
RETURNING CHAR(5)   AS cod_ret,
		  CHAR(100) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE SQL_ERR	INTEGER;
DEFINE ISAM_ERR	INTEGER;
DEFINE DATA_ERR	CHAR(95);
DEFINE ROWS_NUM INTEGER;

DEFINE dFechaIni	DATE;
DEFINE dFechaFin 	DATE;
DEFINE cCuenta 		CHAR(20);
DEFINE mMonto 		MONEY;
DEFINE mSaldo		MONEY;
DEFINE cSucursal	CHAR(4);
DEFINE cEmpresa1	CHAR(3);
DEFINE dFechaAlta	DATE;
DEFINE cFolioSuc	CHAR(16);
DEFINE dtFechaHora	DATETIME HOUR TO FRACTION (3);
DEFINE iNumSerial	INTEGER;
DEFINE cTransaccion	CHAR(4);
DEFINE cReferencia	CHAR(40);
DEFINE cCancelado	CHAR(1);
DEFINE cEmpresa2	CHAR(3);
DEFINE cDescripcion	CHAR(50);
DEFINE cEdoCuenta	CHAR(1);
DEFINE cNaturaleza	CHAR(1);
DEFINE cNumero		CHAR(4);
DEFINE cNomComercio	CHAR(30);
DEFINE dtFechaTx  	DATETIME YEAR to FRACTION(5);
DEFINE cRfc			CHAR(15);

LET ROWS_NUM = 0;

LET cCuenta 	 = '';
LET mMonto 		 = 0;
LET mSaldo		 = 0;
LET cSucursal	 = '';
LET cEmpresa1	 = '';
LET dFechaAlta	 = TODAY;
LET cFolioSuc	 = '';
LET dtFechaHora	 = CURRENT;
LET iNumSerial	 = 0;
LET cTransaccion = '';
LET cReferencia	 = '';
LET cCancelado	 = '';
LET cEmpresa2	 = '';
LET cDescripcion = '';
LET cEdoCuenta	 = '';
LET cNaturaleza	 = '';
LET cNumero		 = '';
LET cNomComercio = '';
LET dtFechaTx  	 = CURRENT;
LET cRfc		 = '';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DATA_ERR
        IF ROWS_NUM <> 0 THEN
			COMMIT WORK;
		END IF
		
		IF SQL_ERR <> 0 OR ISAM_ERR <> 0 THEN
			RETURN SQL_ERR, ISAM_ERR||DATA_ERR;
		END IF
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/jepolanco/sp_movimientos_pos_debito.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy INTO dFechaFin FROM bdinteg:si_fechas;
	LET dFechaIni = dFechaFin - 15;
    
	BEGIN WORK;
		TRUNCATE TABLE bdicheq:"informix".sc_movdescpos;
	COMMIT WORK;			
	
	FOREACH WITH HOLD
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movhis_old)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad
		INTO cCuenta, mMonto, mSaldo, cSucursal, cEmpresa1, dFechaAlta, cFolioSuc, dtFechaHora, iNumSerial, cTransaccion, cReferencia, cCancelado
		FROM bdicheq:"informix".sc_movhis_old
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		UNION
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movhis)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad	
		FROM bdicheq:"informix".sc_movhis
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		UNION
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movdia)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad
		FROM bdicheq:"informix".sc_movdia
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		
		LET cReferencia = TRIM(cReferencia);
		IF cReferencia IS NULL OR cReferencia = '' THEN
			LET cReferencia = cTransaccion;
		END IF
		
		SELECT empresa, descripcion, se_emite_edocta, naturaleza, numero
		INTO cEmpresa2, cDescripcion, cEdoCuenta, cNaturaleza, cNumero
		FROM bdinteg:"informix".si_transacc
		WHERE empresa = '001' AND se_emite_edocta = 'S' AND numero = cTransaccion;
		
		IF cTransaccion = '0830' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion, rfc325 
			INTO cNomComercio, dtFechaTx, cRfc
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cCuenta AND folio_mov = cFolioSuc AND tipotransaccion325 = '01';
		ELIF cTransaccion = '0813' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion, rfc325 
			INTO cNomComercio, dtFechaTx, cRfc
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cCuenta AND folio_mov = cFolioSuc AND tipotransaccion325 = '21';			
		END IF
		
		IF ROWS_NUM = 0 THEN
			BEGIN WORK;
		END IF
		
		IF iNumSerial IS NULL THEN
			LET iNumSerial = '';
		END IF
		
		IF cNumero IS NULL THEN
			LET cNumero = '';
		END IF
		
		INSERT INTO bdicheq:"informix".sc_movdescpos (cuenta, monto_tot, sdo_cuenta, sucursal, empresa, fech_alt, folio_suc, fech_hor, num_serial, transacc, referencia, cancelad, empresa1, descripcion, se_emite_edocta, naturaleza, numero, payment, nomcomercio325, fechatransaccion, rfc325)
		VALUES (cCuenta, mMonto, mSaldo, cSucursal, cEmpresa1, dFechaAlta, cFolioSuc, dtFechaHora, iNumSerial, cTransaccion, cReferencia, cCancelado, cEmpresa2, cDescripcion, cEdoCuenta, cNaturaleza, cNumero, '', cNomComercio, dtFechaTx, cRfc);
		
		LET ROWS_NUM = ROWS_NUM + 1;
		IF ROWS_NUM = 1000 THEN
			COMMIT WORK;
			LET ROWS_NUM = 0;			
		END IF
	END FOREACH
	
	IF 	ROWS_NUM <> 0 THEN
		COMMIT WORK;
		LET ROWS_NUM = 0;
	END IF
	
	RETURN '00000', 'TERMINÃ CORRECTAMENTE';
	
END;
END PROCEDURE;