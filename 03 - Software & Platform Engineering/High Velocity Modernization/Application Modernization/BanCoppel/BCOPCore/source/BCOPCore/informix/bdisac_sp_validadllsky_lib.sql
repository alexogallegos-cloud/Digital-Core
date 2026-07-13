CREATE PROCEDURE "informix".sp_validadllsky_lib()
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodRet,
	CHAR(1) AS Bandera;
	
	--Definicion de Variables
	DEFINE cCodRet  CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cBandera CHAR(1);
	
	--Inicializacion de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cBandera = '0';
	
	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN  TRIM(NVL(cCodRet,"")),NVL(cBandera,"0");
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		SELECT ws INTO cBandera FROM 'informix'.sac_controlconvenios WHERE cod_consulta_1 = '0002'; 
		LET cBandera = '1';
		
		 IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00001';
		 END IF;
		
		RETURN  TRIM(NVL(cCodRet,"")),NVL(cBandera,"0");
		
	END;
END PROCEDURE;