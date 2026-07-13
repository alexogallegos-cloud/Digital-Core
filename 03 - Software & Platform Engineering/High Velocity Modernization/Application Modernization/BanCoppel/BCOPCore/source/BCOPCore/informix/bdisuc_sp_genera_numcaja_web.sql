CREATE PROCEDURE "informix".sp_genera_numcaja_web(pEmpresa CHAR(3),pSucursal CHAR(4))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(10) AS cNuevaCaja,
			CHAR(10) AS cCajaAnt;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSuc			CHAR(4);
DEFINE  cNuevaCaja		CHAR(10);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  cFechaHoy		CHAR(10);
DEFINE  cMes			CHAR(2);
DEFINE  cAno			CHAR(2);
DEFINE  cSecuencia		CHAR(2);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSuc			= '';
LET cNuevaCaja		= '';
LET cCajaAnt		= '';
LET cFechaHoy		= '';
LET cMes			= '';
LET cAno			= '';
LET cSecuencia		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cNuevaCaja,cCajaAnt;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_genera_numcaja.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF NVL(cSuc,'') = '' THEN
			LET cCodret = '01309';
		ELSE
			SELECT fecha_hoy INTO cFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '01309';
			ELSE
				LET cAno = SUBSTR(cFechaHoy,9,2);
				LET cMes = SUBSTR(cFechaHoy,1,2);

				SELECT MAX(numerocaja) INTO cCajaAnt
				FROM bdisuc:"informix".ss_numcajas
				WHERE numsucursal = pSucursal
				AND SUBSTR(numerocaja,7,2) = cAno
				AND SUBSTR(numerocaja,5,2) = cMes;

				IF NVL(cCajaAnt,'') = '' THEN
					LET cCajaAnt = '';
					LET cSecuencia = '01';
					LET cNuevaCaja = pSucursal || cMes || cAno || cSecuencia;
				ELSE
					LET cSecuencia = SUBSTR(cCajaAnt,9,2);
					LET cSecuencia = LPAD(TRIM(cSecuencia),2,'0');

					IF NVL(cSecuencia,'') = '99' THEN
						LET cCodRet ='01316';
					ELSE
						LET cSecuencia = cSecuencia + 1;
						LET cSecuencia = LPAD(TRIM(cSecuencia),2,'0');
						LET cNuevaCaja = pSucursal || cMes || cAno || cSecuencia;
					END IF;
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF

	RETURN cCodRet,cNuevaCaja,cCajaAnt;
END;
END PROCEDURE
;