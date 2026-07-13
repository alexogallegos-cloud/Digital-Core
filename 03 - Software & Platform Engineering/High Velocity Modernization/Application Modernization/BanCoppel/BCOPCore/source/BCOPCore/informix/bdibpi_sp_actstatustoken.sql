CREATE PROCEDURE "informix".sp_actstatustoken(rangoIni CHAR(9), rangoFin CHAR(9))

	RETURNING  CHAR(5), SMALLINT;
	--************************************
	--Objetivo:Actualiza el estatus de los token en inventario.
	--Autor: Ismael Hernandez
	--Fecha: 16/02/2011
	--****************************************
	
	--DEFINICION DE VARIABLES
	DEFINE vSqlErr          INTEGER;		--variable usada par obtener el numero de error de informix en caso de que ocurra un error interno de informix.
	DEFINE vsCodRet        	CHAR(5);		--variable para el codigo de retorno
	DEFINE v_nsToken 		CHAR(9);
    DEFINE v_staToken       SMALLINT;
    DEFINE v_fStatus       DATETIME YEAR TO SECOND;
    DEFINE v_registro       SMALLINT;
	
	--ASIGNACION DE VALORES A LAS VARIABLES
	LET vSqlErr =0;
	LET vsCodRet ="00000";
	LET v_nsToken="";	
    LET v_staToken=0;
    LET v_fStatus =  CURRENT;
    LET v_registro = 0;
    
	
	BEGIN
		ON EXCEPTION
			SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET vsCodRet = vSqlErr;
				RETURN vsCodRet,v_registro;
			END IF;
		END EXCEPTION;

		FOREACH

            SELECT ns_token,id_status_token,f_status
            INTO v_nsToken, v_staToken, v_fStatus
            FROM bdinteg:si_bpitoken
            WHERE ns_token BETWEEN rangoIni AND rangoFin
			
            UPDATE bdibpi:tkn_nseries
            SET id_status = v_staToken, f_status = v_fStatus
            WHERE ns_token = v_nsToken;
            
            LET v_registro = v_registro + 1;

        END FOREACH;
		
		IF v_registro = 0 THEN
            LET vsCodRet = '00100';
		END IF;
		
		RETURN vsCodRet,v_registro;
	END;
END PROCEDURE;