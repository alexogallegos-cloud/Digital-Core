CREATE PROCEDURE "informix".sp_depura_detalle_modelo()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE VlNumSolicitud               CHAR(20);


 -- SET DEBUG FILE TO "/informix/c92962301/img/sp_depura_ss_solicitudes_detalle_scoring.out";
 -- TRACE ON; 

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
	select a.num_solicitud into VlNumSolicitud
	from "informix".ss_detalle_modelo a 
	where  a.empresa = '001' and fecha_insert <= mdy('12','31','2014') 
	group by 1

	BEGIN;

		DELETE FROM "informix".ss_detalle_modelo
		WHERE num_solicitud = VlNumSolicitud;
		
	COMMIT;
	   
     END FOREACH;  
     RETURN cCod_ret;
	END;
END PROCEDURE;