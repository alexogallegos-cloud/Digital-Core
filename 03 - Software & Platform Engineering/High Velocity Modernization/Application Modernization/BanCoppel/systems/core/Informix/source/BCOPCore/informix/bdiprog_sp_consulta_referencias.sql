CREATE PROCEDURE "informix".sp_consulta_referencias(pNumCte CHAR(20), pTipoCta CHAR(2), pCveBanco CHAR(3),pReg SMALLINT)
	RETURNING CHAR(5) as codret,CHAR(20) as  alias,CHAR(20) as referencia,CHAR(1) as inhabil;

	-- *************************************************
	-- Realizo: Javier Calderon               --*
	-- Actividad: Obtener las cuentas frecuentes de SKY, DISH o MasTV  --*
	-- Solicito: Mauricio Leon                      --*
	--Fecha: 27/Agosto/2010                        --*
	--Modifica: Walber Castro
	--Actividad: Se agrega parametro de salida inhabil para indicar cuando una referencia esta disponible de acuerdo a los 30 min de tolerancia.
	--Fecha: 30/09/2010
	-- *************************************************

--Declaración de Variables
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

--Asiganación de valores a las variables
LET v_CodRet	 ='00000';
LET v_Alias		 ='';
LET v_Referencia ='';
LET v_Cont		 =0;
LET v_Canal		 ="";
LET v_Inhabil	 ="";

BEGIN

	ON EXCEPTION SET v_SqlErr
		LET v_CodRet = v_SqlErr;
		RETURN v_CodRet,'','','';
	END EXCEPTION;

	FOREACH
		SELECT SKIP pReg FIRST 10 descrip_cta,cuenta, canal_alta, fecha_insert, hora_insert 
		INTO v_Alias,v_Referencia, v_Canal, v_FechaInsert, v_HoraInsert
		FROM bdiprog:pp_ctasterceros
		WHERE TRIM(num_cte)=TRIM(pNumCte)
		AND cve_cuenta=pTipoCta
		AND cve_banco=pCveBanco
		AND cve_estado='01'
		--ORDER BY fecha_insert DESC, hora_insert DESC, descrip_cta ASC
		ORDER BY CASE WHEN current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION  > '0 00:30:00' THEN '1'  
                      WHEN current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION  < '0 00:30:00' THEN '0'  END,descrip_cta
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
			RETURN v_CodRet,v_Alias,v_Referencia,v_Inhabil WITH RESUME;

	END FOREACH;

	IF( v_Cont = 0 ) THEN
		RETURN '00002','','','';
	END IF

END
END PROCEDURE
;