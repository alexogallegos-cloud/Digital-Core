CREATE PROCEDURE "informix".sp_movimientos_pos_credito_5()
RETURNING CHAR(5)   AS cod_ret,
		  CHAR(100) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE SQL_ERR	  INTEGER;
DEFINE ISAM_ERR	  INTEGER;
DEFINE DATA_ERR	  CHAR(95);
DEFINE FLAG_ERR   INTEGER;
DEFINE cRuta 	  CHAR(14);
DEFINE cArchivo   CHAR(41);
DEFINE cConsulta  CHAR(220);
DEFINE cCmd		  CHAR(500);

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

LET cRuta = '/RESPALDOSNEW/';
LET cArchivo = '';

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
LET FLAG_ERR	  = 0;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DATA_ERR	
		IF SQL_ERR <> 0 OR ISAM_ERR <> 0 THEN
			DROP TABLE IF EXISTS bdicred:"informix".temp_sd_movdescpos;
			RETURN SQL_ERR, ISAM_ERR||' '||DATA_ERR||' EN PASO '||FLAG_ERR;
		END IF
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/jepolanco/sp_movimientos_pos_credito.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	CREATE TEMP TABLE IF NOT EXISTS temp_sd_movdescpos(
		secuencia       	SERIAL NOT NULL,
		fecha_mov       	DATE NOT NULL,
		referencia      	VARCHAR(40),
		transacc        	CHAR(4) NOT NULL,
		descripcion     	CHAR(50),
		naturaleza      	CHAR(1),
		monto           	DECIMAL(18,2) NOT NULL,
		referencia23    	VARCHAR(23),
		rfc_comer       	VARCHAR(20),
		numero          	CHAR(4) NOT NULL,
		num_credito     	CHAR(20) NOT NULL,
		nomcomercio325  	CHAR(30),
		fechatransaccion	DATETIME YEAR to FRACTION(5),
		folio_suc       	CHAR(16) DEFAULT '' 		
	);
	
	--SELECT fecha_hoy INTO dFechaFin FROM bdinteg:si_fechas;
	Let dFechaFin = '20211019';
	LET dFechaIni = dFechaFin - 15;
	
	--BEGIN WORK;
	--	TRUNCATE TABLE bdicred:"informix".sd_movdescpos;
	--COMMIT WORK;

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
		
		INSERT INTO bdicred:"informix".temp_sd_movdescpos (secuencia, fecha_mov, referencia, transacc, descripcion, naturaleza, monto, referencia23, rfc_comer, numero, num_credito, nomcomercio325, fechatransaccion, folio_suc)
		VALUES (iSecuencia, dFechaMov, vcReferencia1, cTransaccion, cDescripcion, cNaturaleza, dMonto, vcReferencia2, vcRfc, cNumero, cNumCredito, cNomComercio, dtFechaTx, cFolioSuc);

	END FOREACH
	
	LET cArchivo = TRIM(cRuta)||'movimientos_pos_credito.unl';
	LET cConsulta = '';
	LET cConsulta = 'SELECT secuencia, fecha_mov, referencia, transacc, descripcion, naturaleza, monto, referencia23, rfc_comer, numero, num_credito, nomcomercio325, fechatransaccion, folio_suc FROM bdicred:"informix".temp_sd_movdescpos;';
	
	LET FLAG_ERR = 1;
	LET cCmd= '';
	LET cCmd= 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchivo)||" DELIMITER '|' "||TRIM(cConsulta)||' " >> '||TRIM(cRuta)||'unload_movimientos_pos_credito.sql';
	SYSTEM cCmd;
	
	LET FLAG_ERR = 1;
	LET cCmd= '';	
	LET cCmd = 'chmod 777 '||TRIM(cRuta)||'unload_movimientos_pos_credito.sql';
	
	LET FLAG_ERR = 2;
	LET cCmd = '';
	LET cCmd = 'dbaccess bdicred '||TRIM(cRuta)||'unload_movimientos_pos_credito.sql';
	SYSTEM cCmd;
	
	LET FLAG_ERR = 3;
	LET cCmd = '';
	LET cCmd = 'rm -f '||TRIM(cRuta)||'unload_movimientos_pos_credito.sql';
	SYSTEM cCmd;
	
	DROP TABLE IF EXISTS bdicred:"informix".temp_sd_movdescpos;
	
	RETURN '00000', 'TERMINÃ CORRECTAMENTE';
	
END;
END PROCEDURE;