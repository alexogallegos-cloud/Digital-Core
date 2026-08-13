CREATE PROCEDURE "informix".sp_buscactecoppel(p_sNumCteCoppel CHAR(20), p_Tipo CHAR(1))

RETURNING CHAR(5), INTEGER;

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE v_iSecuencia INTEGER;

--****************************************************************************************************
-- DESCRIPCION: Busca Clientes Coppel.
-- AUTOR : Marcos Cuevas
-- FECHA : 09/03/2009
-- SISTEMA : Caja Unica
--****************************************************************************************************

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET v_iSecuencia = 0;


--set debug file to "/tmp/sp_BuscaCteCoppel.out";
--Trace on;

SET LOCK MODE TO WAIT 3;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
	RETURN viSqlErr,0;
	END IF;
END EXCEPTION;

--Valida que el cliente exista, si existe consulta los datos requeridos sino manda el codigo de retorno 1

	IF p_Tipo = 1 THEN
		IF EXISTS ( SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = p_sNumCteCoppel AND SECUENCIA = 1) THEN
			LET v_iSecuencia = 1;
		ELSE
			LET vsCodRet = '00001';
		END IF;
	ELIF p_Tipo = 2 THEN
		IF EXISTS ( SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = p_sNumCteCoppel AND SECUENCIA > 1) THEN
			LET v_iSecuencia = 2;
		ELSE
			LET vsCodRet = '00002';
		END IF
    ELSE
		
	END IF;

RETURN vsCodRet, v_iSecuencia;

END
END PROCEDURE;