CREATE PROCEDURE "informix".sp_cons_fechaexp(p_sEmpresa CHAR(3), p_sNumTar CHAR(20))

RETURNING CHAR(5), CHAR(20);

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE v_sFechaExp CHAR(4);

--****************************************************************************************************
-- DESCRIPCION: Consulta Fecha de Expiracion de Tarjeta.
-- AUTOR : RGH
-- FECHA : 01/12/2011
-- SISTEMA : OFI
--****************************************************************************************************

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET v_sFechaExp = '';

--set debug file to "/tmp/sp_cons_fechaexp.out";
--Trace on;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;

	BEGIN
	
		ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF viSqlErr <> 0 THEN
				RETURN viSqlErr,'';
			END IF;
		END EXCEPTION;
		
		--Valida que la tarjeta exista, si existe consulta su fecha de expiración sino manda el codigo de retorno 1
		IF EXISTS (SELECT 1 FROM tarjeta WHERE numtarjeta = p_sNumTar) THEN
			SELECT fechaexp
			INTO v_sFechaExp
			FROM tarjeta
			WHERE numtarjeta = p_sNumTar;
		ELSE 
			LET vsCodRet = '00001';
		END IF;
		
		RETURN vsCodRet,v_sFechaExp;
	
	END
END PROCEDURE;