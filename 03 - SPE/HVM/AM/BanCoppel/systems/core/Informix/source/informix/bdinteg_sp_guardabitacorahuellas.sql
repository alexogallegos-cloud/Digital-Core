CREATE PROCEDURE "informix".sp_guardabitacorahuellas(p_sSucursal CHAR(4), p_sNumCte CHAR(20), p_sNumTran CHAR(4), p_bValida_Nip BOOLEAN, p_sEstatus_Val_Nip CHAR(2), p_sUser_Insert CHAR(8), p_Fecha DATE)

RETURNING 	VARCHAR(6) --Codigo de Retorno

DEFINE CodRet			  VARCHAR(6);
DEFINE iSqlErr, iIsamErr  INTEGER;
DEFINE cInfoErr 		  CHAR(200);

LET CodRet = '000000';


	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
			INSERT INTO bdinteg: "informix".si_mensajeerror (sql_error, isam_error, descripcion, origen_error) 
			VALUES (iSqlErr, iIsamErr, cInfoErr, 'sp_guardabitacorahuellas');							  
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

		--- SET DEBUG FILE TO "/respaldosbd/Bruno/286/SP_GUARDABITACORAHUELLAS:out;
    	--- TRACE ON;

    	  SET ISOLATION TO DIRTY READ;
   		  SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg: "informix".si_bitacora_autenticacion_huella VALUES (p_sSucursal, p_sNumCte, p_sNumTran, p_bValida_Nip, p_sEstatus_Val_Nip, p_sUser_Insert, p_Fecha, current);

		RETURN CodRet;
	END
END PROCEDURE;