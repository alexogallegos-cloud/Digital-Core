CREATE PROCEDURE "informix".sp_sd_amortiza_credito()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE VlNumCredito                 CHAR(20);

	--SET DEBUG FILE TO "/informix/c91691184/sp_sd_amortiza_credito.out";
    --TRACE ON; 

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
            
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret;
	    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    FOREACH WITH HOLD

		select num_solicitud
		into VlNumCredito  
		from "informix".temp_solicitudes

		BEGIN WORK;

			DELETE FROM "informix".sd_amortiza_credito WHERE empresa = '001' and  num_credito = VlNumCredito;
			delete from "informix".temp_solicitudes where num_solicitud = VlNumCredito;

		COMMIT WORK;

	END FOREACH;  
	
	drop table "informix".temp_solicitudes;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;