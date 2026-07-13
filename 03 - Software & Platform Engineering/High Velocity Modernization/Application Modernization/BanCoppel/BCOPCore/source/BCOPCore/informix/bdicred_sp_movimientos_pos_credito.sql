CREATE PROCEDURE "informix".sp_movimientos_pos_credito()
RETURNING CHAR(5)   AS cod_ret,
		  CHAR(100) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE SQL_ERR	INTEGER;
DEFINE ISAM_ERR	INTEGER;
DEFINE DATA_ERR	CHAR(95);
DEFINE ROWS_NUM INTEGER;

DEFINE dFechaIni	 DATE;
DEFINE dFechaFin 	 DATE;
DEFINE iSecuencia	 INTEGER;
DEFINE dFechaMov	 DATE;
DEFINE vcReferencia1 VARCHAR(40);
DEFINE cTransaccion	 CHAR(4);
DEFINE cDescripcion	 CHAR(50);
DEFINE cNaturaleza	 CHAR(1);
DEFINE dMonto		 DECIMAL(18,2);
DEFINE vcReferencia2 VARCHAR(23);
DEFINE vcRfc		 VARCHAR(20);
DEFINE cNumero		 CHAR(4);
DEFINE cNumCredito	 CHAR(20);
DEFINE cNomComercio	 CHAR(30);
DEFINE dtFechaTx	 DATETIME YEAR to FRACTION(5);
DEFINE cFolioSuc 	 CHAR(16);
DEFINE cEmpresa1	 CHAR(3);
DEFINE cEmpresa2	 CHAR(3);
DEFINE cCodFun		 CHAR(3);
DEFINE iCodRef		 INTEGER;
DEFINE cTransacSuc	 CHAR(4);

LET ROWS_NUM = 0;

LET iSecuencia	  = 0;
LET dFechaMov	  = TODAY;
LET vcReferencia1 = '';
LET cTransaccion  = '';
LET cDescripcion  = '';
LET cNaturaleza	  = '';
LET dMonto		  = 0;
LET vcReferencia2 = '';
LET vcRfc		  = '';
LET cNumero		  = '';
LET cNumCredito	  = '';
LET cNomComercio  = '';
LET dtFechaTx	  = CURRENT;
LET cFolioSuc 	  = '';
LET cEmpresa1	  = '';
LET cEmpresa2	  = '';
LET cCodFun		  = '';
LET iCodRef		  = 0;
LET cTransacSuc	  = '';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DATA_ERR
        IF ROWS_NUM <> 0 THEN
			COMMIT WORK;
		END IF
		
		IF SQL_ERR <> 0 OR ISAM_ERR <> 0 THEN
			RETURN SQL_ERR, ISAM_ERR||DATA_ERR;
		END IF
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/jepolanco/sp_movimientos_pos_credito.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy INTO dFechaFin FROM bdinteg:si_fechas;
	LET dFechaIni = dFechaFin - 15;
	
	BEGIN WORK;
		TRUNCATE TABLE bdicred:"informix".sd_movdescpos;
	COMMIT WORK;			
	
	FOREACH WITH HOLD
		SELECT {+AVOID_FULL(bdicred:"informix".sd_movhis)} secuencia, fecha_mov, referencia, monto, referencia23, rfc_comer, num_credito, folio_suc, empresa, codigo_fun, codigo_ref, transacc_suc
		INTO iSecuencia, dFechaMov, vcReferencia1, dMonto, vcReferencia2, vcRfc, cNumCredito, cFolioSuc, cEmpresa1, cCodFun, iCodRef, cTransacSuc
		FROM bdicred:"informix".sd_movhis
		WHERE transacc_suc IN ('6813','6830') AND fecha_mov BETWEEN dFechaIni AND dFechaFin
		UNION
		SELECT {+AVOID_FULL(bdicred:"informix".sd_movdia)} secuencia, fecha_mov, referencia, monto, referencia23, rfc_comer, num_credito, folio_suc, empresa, codigo_fun, codigo_ref, transacc_suc
		FROM bdicred:"informix".sd_movdia
		WHERE transacc_suc IN ('6813','6830') AND fecha_mov BETWEEN dFechaIni AND dFechaFin
		
		LET cCodFun = TRIM(cCodFun);

		SELECT {+INDEX(bdicred:"informix".sd_transfun inx_transfun)} transacc, empresa
		INTO cTransaccion, cEmpresa2
		FROM bdicred:"informix".sd_transfun
		WHERE empresa = cEmpresa1 AND TRIM(codigo_fun)||codigo_ref = cCodFun||iCodRef;
		
		SELECT descripcion, naturaleza, numero
		INTO cDescripcion, cNaturaleza, cNumero
		FROM bdinteg:"informix".si_transacc
		WHERE empresa = cEmpresa2 AND numero = cTransaccion;
		
		IF cTransacSuc = '6830' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion INTO cNomComercio, dtFechaTx
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cNumCredito AND folio_mov = cFolioSuc AND tipotransaccion325 = '01';
		ELIF cTransacSuc = '6813' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion INTO cNomComercio, dtFechaTx
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cNumCredito AND folio_mov = cFolioSuc AND tipotransaccion325 = '21';			
		END IF
		
		IF ROWS_NUM = 0 THEN
			BEGIN WORK;
		END IF
		
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 0;
		END IF
		
		IF dFechaMov IS NULL THEN
			LET dFechaMov = dFechaFin;
		END IF
		
		IF cTransaccion IS NULL THEN
			LET cTransaccion = '';
		END IF
		
		IF dMonto IS NULL THEN
			LET dMonto = 0;
		END IF
		
		IF cNumero IS NULL THEN
			LET cNumero = '';
		END IF
		
		IF cNumCredito IS NULL THEN
			LET cNumCredito = '';
		END IF
		
		INSERT INTO bdicred:"informix".sd_movdescpos (secuencia, fecha_mov, referencia, transacc, descripcion, naturaleza, monto, referencia23, rfc_comer, numero, num_credito, nomcomercio325, fechatransaccion, folio_suc)
		VALUES (iSecuencia, dFechaMov, vcReferencia1, cTransaccion, cDescripcion, cNaturaleza, dMonto, vcReferencia2, vcRfc, cNumero, cNumCredito, cNomComercio, dtFechaTx, cFolioSuc);
		
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