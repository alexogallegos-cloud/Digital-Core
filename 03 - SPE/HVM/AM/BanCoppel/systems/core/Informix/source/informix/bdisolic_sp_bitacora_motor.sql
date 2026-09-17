CREATE PROCEDURE "informix".sp_bitacora_motor(
    pEmpresa		CHAR(3),
	pSucursal		CHAR(4),
	pNumCliente	    CHAR(20),
	pNumcteCoppel	CHAR(20),
	numSolicitud	CHAR(20),
	secuencia	    CHAR(1),
	trama			CHAR(9000),
	trama1			CHAR(9000),
	trama2			CHAR(9000),
	tipoProceso		CHAR(1),
	tipoDato 		CHAR(7),
	pParte SMALLINT
)

RETURNING CHAR(5) AS Retorno;
-------------------------------- DEFINICION DE VARIABLES ---------------------------

		  
	DEFINE iSqlErr              INTEGER; --retorno
	DEFINE cCodRet              CHAR(5); --codigo Error
	DEFINE iSecuencia			INTEGER; --SECUENCIA
	DEFINE dFechahoy			DATE; --FECHA
	DEFINE dTime 				DATETIME HOUR TO SECOND;
	DEFINE fechaHoy				DATE;
	DEFINE dFecha				CHAR(40);
	DEFINE cAux1                CHAR(10);
    DEFINE fNumCliente          CHAR(20);
	DEFINE cDate				CHAR(30);
---------------------------	ASIGNACION DE VARIABLES ---------------------------
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET iSecuencia 		= 0;
	LET dFechahoy 		= '';
	LET dFecha	 		= '';
	LET fechaHoy		= DATE(1);
	LET dTime           = CURRENT HOUR TO SECOND;
	LET cAux1           ='';
    LET fNumCliente     ='';
	LET cDate = TO_CHAR(CURRENT YEAR TO FRACTION(5), '%Y-%m-%d %H:%M:%S.%F');
---------------------------	CONTROL DE ERRORES ---------------------------
BEGIN
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/Jorgegonzalez/sp_bitacora_motor.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg: "informix".si_fechas
		WHERE empresa = pEmpresa;
		
	IF dbinfo('sqlca.sqlerrd2') = 0 THEN 		
		LET cCodRet = '00003';				
	END IF;

	LET cAux1 = dFechaHoy ::CHAR(10);
	LET dFecha = SUBSTR(TRIM(cAux1), 7, 4)||'-'|| SUBSTR(TRIM(cAux1), 1, 2)||'-'||SUBSTR(TRIM(cAux1), 4, 2)||' '||dTime;
	LET fNumCliente = LPAD(TRIM(pNumCliente), 9, '0');

	SELECT MAX(secuencia)  
	INTO iSecuencia
	FROM bdisolic:"informix".ss_bitacora_motor 
	WHERE empresa = pEmpresa 
	AND numcte = fNumCliente;
	
	IF NVL(iSecuencia,0) = 0 THEN
		LET iSecuencia = 1;
	END IF;
	LET iSecuencia = secuencia;
	IF NVL(pParte,0) = 1 THEN 
		INSERT INTO bdisolic:"informix".ss_bitacora_motor(empresa, sucursal, numcte, numcte_coppel, num_solicitud, secuencia, trama, trama1, trama2, tipo_proceso, tipo_dato, fecha_insert, fecha)
		VALUES(pEmpresa, pSucursal, fNumCliente, pNumcteCoppel, numSolicitud, secuencia, trama, trama1, trama2, tipoProceso, tipoDato, cDate, dFechaHoy);
		LET cCodRet = '00000';
		
		ELIF NVL(pParte,0) = 2 THEN 
			UPDATE bdisolic:"informix".ss_bitacora_motor
			SET trama1 = trama1
			WHERE empresa = pEmpresa 
				AND numcte = fNumCliente
				AND fecha = dFechaHoy;
		LET cCodRet = '00000';
		ELIF NVL(pParte,0) = 3 THEN 
			UPDATE bdisolic:"informix".ss_bitacora_motor
			SET trama2 = trama2
			WHERE empresa = pEmpresa 
			  AND numcte = fNumCliente
			  AND fecha = dFechaHoy;
		LET cCodRet = '00000';
		ELIF NVL(pParte,0) = 4 THEN 
			LET secuencia = iSecuencia;
			INSERT INTO bdisolic:"informix".ss_bitacora_motor(empresa, sucursal, numcte, numcte_coppel, num_solicitud, secuencia, trama, trama1, trama2, tipo_proceso, tipo_dato, fecha_insert, fecha)
			VALUES(pEmpresa, pSucursal, fNumCliente, pNumcteCoppel, numSolicitud, secuencia, trama, trama1, trama2, tipoProceso, tipoDato, cDate, dFechaHoy);
		ELIF NVL(pParte,0) = 5 THEN 
			UPDATE bdisolic:"informix".ss_bitacora_motor
			SET trama1 = trama1
			WHERE empresa = pEmpresa
			  AND secuencia = iSecuencia 
			  AND numcte = fNumCliente
			  AND fecha = dFechaHoy;
		LET cCodRet = '00000';
		ELIF NVL(pParte,0) = 6 THEN 
			UPDATE bdisolic:"informix".ss_bitacora_motor
			SET trama2 = trama2
			WHERE empresa = pEmpresa
			  AND secuencia = iSecuencia 
			  AND numcte = fNumCliente
			  AND fecha = dFechaHoy;	
		LET cCodRet = '00000';
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
