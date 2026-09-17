CREATE PROCEDURE "informix".sp_obtienelimitecreditosolicitud (
	pEmpresa CHAR(3),
	pNumCte CHAR(20),
	pNumSol CHAR(20),
	pSucursal CHAR(4))
RETURNING 
	CHAR(5) AS cCodRet,
	CHAR(100) AS cMensaje,
	CHAR(10) AS cLimitecreditopesos;

------------------------------------------------------
	-- 00000 = Consulta Exitosa
	-- 00001 = No existe el dato de la solicitud
------------------------------------------------------

DEFINE cCodRet CHAR(5);
DEFINE cMensaje CHAR(100);
DEFINE cLimitecreditopesos CHAR(10);

LET cCodRet = '00001';
LET cMensaje = "No existe el dato de la solicitud";
LET cLimitecreditopesos = NULL;

	BEGIN
		SELECT p.limitecreditopesos
			INTO cLimitecreditopesos
		FROM
			bdisolic:"informix".ss_nuevo_parametrico AS p
		INNER JOIN bdisolic:"informix".ss_solicitudes AS s 
			ON p.num_solicitud = s.num_solicitud
		WHERE
			--s.status_solicitud = 'PA'
		--AND
			s.empresa = TRIM(pEmpresa)
		AND
			s.numcte = TRIM(pNumCte)
		AND 
			s.num_solicitud = TRIM(pNumSol)
		AND
			s.sucursal = TRIM(pSucursal);
		
		IF cLimitecreditopesos IS NOT NULL THEN
			LET cCodRet = '00000';
			LET cMensaje = 'Consulta Exitosa';
		END IF;

		RETURN cCodRet, cMensaje, cLimitecreditopesos;
	END;
END PROCEDURE
