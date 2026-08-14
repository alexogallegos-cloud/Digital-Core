CREATE PROCEDURE "informix".sp_obtenernumtrans(pIdOpe CHAR(4))
RETURNING CHAR(5),CHAR(8)

	------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se utiliza para obtener el id de transacción, debido a la migración de BD de postgres a informix
	--Solicito:Diana Castellanos
	--Fecha:21/10/2010
	------------------------------------------------------------------------------------------------------------------------
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vIdTran CHAR(8);
		
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vIdTran='';
	
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vIdTran;
		  END IF ;
		END EXCEPTION ;

		
		SELECT id_tran INTO vIdTran FROM bdibpi:bpi_cat_operaciones WHERE id_oper = TRIM(pIdOpe);
		
		IF(vIdTran='' OR  vIdTran IS NULL) THEN
			LET vCod_Ret='00001'; ---Error no existe  datos para esa operación
		END IF;
		
		RETURN vCod_Ret,vIdTran;
		
	END;

	END PROCEDURE;