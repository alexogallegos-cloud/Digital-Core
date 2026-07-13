CREATE PROCEDURE "informix".sp_consulta_referenciasfrec_bex(pNumCte CHAR(20), pTipoCta CHAR(2), pCveBanco CHAR(3),pReg SMALLINT)
	RETURNING CHAR(5) as codret,CHAR(20) as  alias,CHAR(20) as referencia,CHAR(1) as inhabil, MONEY(16,2) as monto, CHAR(1) as caducidad;

	-- *************************************************
	-- Consulta las referencias frecuentes de pagos de servicios y tiene parametro de salida para la clave de caducidad
	-- Bibiana Gaxiola Verdugo.
	-- 19/12/2012
	-- *************************************************


--Declaracion de Variables
DEFINE v_CodRet 	CHAR(5);
DEFINE v_SqlErr 	INTEGER;
DEFINE v_Alias  	CHAR(20);
DEFINE v_Referencia CHAR(20);
DEFINE v_Cont		SMALLINT;
DEFINE v_Canal		CHAR(2);
DEFINE v_Inhabil	CHAR(1);
DEFINE v_FechaInsert		DATE;
DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
DEFINE v_MontoMaximo		MONEY(16,2);
DEFINE v_CveCaducidad		INTEGER;  -- Tipo de caducidad de la cuenta frec.
DEFINE l_registro	INTEGER;

--Asiganacion de valores a las variables
LET v_CodRet	 ='00000';
LET v_Alias		 ='';
LET v_Referencia ='';
LET v_Cont		 =0;
LET v_Canal		 ="";
LET v_Inhabil	 ="";
LET v_MontoMaximo			= 0.00;
LET v_CveCaducidad			= '';


SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ ;

--SET DEBUG FILE TO "/informix/pdrh/sp_consulta_referenciasfrec_bpi.out";
--TRACE ON;


BEGIN

	ON EXCEPTION SET v_SqlErr
		LET v_CodRet = v_SqlErr;
		RETURN v_CodRet,'','','','','';
	END EXCEPTION;

	FOREACH
		SELECT SKIP pReg FIRST 10 descrip_cta,cuenta, canal_alta, fecha_insert, hora_insert , NVL(monto_maximo,0), cve_caducidad
		INTO v_Alias,v_Referencia, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
		FROM bdiprog:"informix".pp_ctasterceros_bex
		WHERE num_cte = pNumCte
		AND cve_banco=pCveBanco
		AND cve_cuenta=pTipoCta
		AND cve_estado='01'
		ORDER BY fecha_insert DESC, hora_insert DESC, descrip_cta ASC
		
			IF(v_Alias='' OR v_Alias IS NULL) OR (v_Referencia='' OR v_Referencia IS NULL) THEN
				LET v_CodRet='00001'; --Datos Incorrectos, o no tiene datos el cliente.
			END IF;

		LET v_Cont = 1;
		RETURN v_CodRet,v_Alias,v_Referencia,v_Inhabil,v_MontoMaximo, v_CveCaducidad WITH RESUME;

	END FOREACH;


	IF v_Cont = 0 THEN
		RETURN '00002','','','','',''; 	---2018/12/18 GM3-PDRHDEZ: Se respeta el codigo de retorno.
	END IF
	

END
END PROCEDURE

DOCUMENT
'MODIFICADO POR: GM3-PATRICIA DEL RAZO HERNANDEZ',
'VoBo POR: GM3-PATRICIA DEL RAZO HERNANDEZ',
'FECHA DE MODIFICACION: 19 DE DICIEMBRE DE 2018',
'OBJETIVO: OPTIMIZACION DE LOGICA',
'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_consulta_referenciasfrec_bpi(pNumCte CHAR(20), pTipoCta CHAR(2), pCveBanco CHAR(3),pReg SMALLINT)
	RETURNING CHAR(5) as codret,CHAR(20) as  alias,CHAR(20) as referencia,CHAR(1) as inhabil, MONEY(16,2) as monto, CHAR(1) as caducidad;

	-- *************************************************
	-- Consulta las referencias frecuentes de pagos de servicios y tiene parametro de salida para la clave de caducidad
	-- Bibiana Gaxiola Verdugo.
	-- 19/12/2012
	-- Se agrega validacion de registros antes del FOREACH
	-- 19/12/2018
	-- *************************************************


--Declaracion de Variables
DEFINE v_CodRet 	CHAR(5);
DEFINE v_SqlErr 	INTEGER;
DEFINE v_Alias  	CHAR(20);
DEFINE v_Referencia CHAR(20);
DEFINE v_Cont		SMALLINT;
DEFINE v_Canal		CHAR(2);
DEFINE v_Inhabil	CHAR(1);
DEFINE v_order		CHAR(1);
DEFINE v_FechaInsert		DATE;
DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
DEFINE v_MontoMaximo		MONEY(16,2);
DEFINE v_CveCaducidad		INTEGER;  -- Tipo de caducidad de la cuenta frec.


--Asiganacion de valores a las variables
LET v_CodRet	 ='00000';
LET v_Alias		 ='';
LET v_Referencia ='';
LET v_Cont		 =0;
LET v_Canal		 ="";
LET v_Inhabil	 ="";
LET v_MontoMaximo			= 0.00;
LET v_CveCaducidad			= '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_referenciasfrec_bpi.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET v_SqlErr
		LET v_CodRet = v_SqlErr;
		RETURN v_CodRet,'','','',0,'';
	END EXCEPTION;

	SELECT LIMIT 1 cuenta
	INTO v_Referencia
	FROM bdiprog:"informix".pp_ctasterceros
	WHERE num_cte=pNumCte
	AND cve_cuenta=pTipoCta
	AND cve_banco=pCveBanco
	AND cve_estado='01';

	IF NVL(v_Referencia,'') <> '' THEN
		FOREACH
			SELECT SKIP pReg FIRST 10 descrip_cta,cuenta, canal_alta, fecha_insert, hora_insert , NVL(monto_maximo,0), cve_caducidad
			INTO v_Alias, v_Referencia, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
			FROM bdiprog:"informix".pp_ctasterceros
			WHERE num_cte=pNumCte
			AND cve_cuenta=pTipoCta
			AND cve_banco=pCveBanco
			AND cve_estado='01'
			ORDER BY fecha_insert ASC, hora_insert DESC, descrip_cta ASC
			--ORDER BY 8, 1
			--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00'

				LET v_Inhabil = '';
				-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
				IF v_Canal = '03' THEN
					LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
					IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
						LET v_Inhabil = '1';
					END IF;
				END IF;

				IF(v_Alias='' OR v_Alias IS NULL) OR (v_Referencia='' OR v_Referencia IS NULL) THEN
					LET v_CodRet='00001'; --Datos Incorrectos, o no tiene datos el cliente.
				END IF;

				LET v_Cont = 1;
				RETURN v_CodRet,v_Alias,v_Referencia,v_Inhabil,v_MontoMaximo, v_CveCaducidad WITH RESUME;
		END FOREACH;
	END IF;
	
	IF( v_Cont = 0 ) THEN
		RETURN '00002','','','',0,'';
	END IF;
		
	
END
END PROCEDURE;