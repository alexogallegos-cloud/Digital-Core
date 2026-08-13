CREATE PROCEDURE "informix".sp_validaemp_reversoquebranto(p_Numemp char(8), p_Valida int)  

	RETURNING CHAR(5) AS CodigoRetorno;

	DEFINE iSqlErr                                                  INTEGER;
	DEFINE v_sCodRet                                                CHAR(5);
		
	--SET DEBUG FILE TO  "spgenerarpolizareasignacion.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;				
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;

		--VALIDA PARÁMETROS DE ENTRADA
		IF NVL(p_Numemp, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF;
		
		if p_Valida=1 then --Valida si es un analista, gerente, coordinador de banca comercial
			if exists(select * from bdinteg:si_ejecut where sucursal in ('9500','9503','9504','9505','9502','9750') and ejecutivo=p_Numemp) THEN
				LET v_sCodRet = '00000';
				RETURN v_sCodRet;
			else
				LET v_sCodRet = '00002'; --No existe el empleado para estas sucursales
				RETURN v_sCodRet;
			End if
		else --Valida si el usuario esta asignado al area de contabilidad
			if exists(select * from bdinteg:si_ejecut where sucursal in ('9101') and ejecutivo=p_Numemp) THEN
				LET v_sCodRet = '00000';
				RETURN v_sCodRet;
			else
				LET v_sCodRet = '00002'; --No existe el empleado para estas sucursales
				RETURN v_sCodRet;
			End if			
		End if

	END
END PROCEDURE
;