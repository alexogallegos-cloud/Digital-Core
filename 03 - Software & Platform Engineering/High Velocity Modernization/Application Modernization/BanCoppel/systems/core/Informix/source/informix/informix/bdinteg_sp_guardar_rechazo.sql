CREATE PROCEDURE "informix".sp_guardar_rechazo(pEmpresa CHAR(3), pSucursal CHAR(4), Causa CHAR(1), Descripcion CHAR(40), ip CHAR(15), pFecha_insert DATETIME YEAR TO SECOND,ejecutivo_modificacion CHAR(8),num_cte CHAR(20))
RETURNING CHAR(5) AS CodigoRetorno;
		
-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00001';
	
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO '/home/JA/CoppelFace/sp_guardar_rechazo.out';
--	TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
	--VALIDAR PARÃMETROS VACÃOS O NULOS
	IF NVL(TRIM(pEmpresa),'') = '' OR NVL(TRIM(pSucursal),'') = '' OR NVL(TRIM(Causa),'') = '' OR NVL(TRIM(Descripcion),'') = '' OR NVL(ip,'') = ''
		OR NVL(pFecha_insert,'') = '' OR NVL(ejecutivo_modificacion,'') = '' THEN
		LET cCodRet = '00002';
	ELSE

		INSERT INTO bdinteg:"informix".si_biometria_rechazo(empresa, sucursal, causa, Descripcion, ip, fecha_insert, ejecutivo_modificacion,numcte)
		VALUES(pEmpresa, pSucursal, Causa, Descripcion, ip, pFecha_insert, ejecutivo_modificacion,num_cte);
	
		LET cCodRet = '00000';
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE;