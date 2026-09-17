CREATE PROCEDURE "informix".sp_obtdeserrorsky (	pIdRespuesta char(3) )
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet,
	char(30) AS cDesError,
	char(1) As cBanReverso;
				
	--Definicion de Variables
	DEFINE cCodigoRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDesError CHAR(30);
	DEFINE cBanReverso CHAR(1);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cDesError = '';
	LET cBanReverso = '';
	
	
	--SET DEBUG FILE TO '/home/sysifx/Geovani'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM( NVL(cCodigoRet,"")),TRIM( NVL( cDesError,"")),TRIM( NVL( cBanReverso,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		IF NVL(pIdRespuesta, '') = '' THEN
			 LET cCodigoRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN  TRIM( NVL(cCodigoRet,"")),TRIM( NVL( cDesError,"")),TRIM( NVL( cBanReverso,""));
			 
		ELSE
		
			select sac_cod_desc, sac_reverso
			into cDesError, cBanReverso
			from "informix".sac_sky_cat_errores
			where sac_id_codigo = pIdRespuesta;
				
				IF NVL(cDesError,"") = '' AND NVL(cBanReverso,"") = '' THEN
					LET cCodigoRet = '00000';
					LET cDesError = 'Error de conexiÃ³n';
					LET cBanReverso = '0';
				END IF;
		END IF;		
			
		
		 RETURN  TRIM( NVL(cCodigoRet,"")),TRIM( NVL( cDesError,"")),TRIM( NVL( cBanReverso,""));
		
		
		
		
	END;
END PROCEDURE;