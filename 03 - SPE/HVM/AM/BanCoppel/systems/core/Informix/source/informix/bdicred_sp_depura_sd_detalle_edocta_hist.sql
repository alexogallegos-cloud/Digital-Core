CREATE PROCEDURE "informix".sp_depura_sd_detalle_edocta_hist(pfecha_insert DATE)
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
DEFINE Vfechaemision				DATE;

    --SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_depura_estado_cuentaTC.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET Vfechaemision	= DATE(1);
            
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret;
	    END EXCEPTION;

           
    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    FOREACH WITH HOLD
	SELECT num_credito, fecha_emision
	INTO VlNumCredito , Vfechaemision
	FROM "informix".sd_detalle_edocta_hist
	WHERE fecha_emision >= mdy('01','20','2012')
	   OR fecha_emision <= mdy('12','20','2010')

	BEGIN WORK;

		DELETE FROM "informix".sd_detalle_edocta_hist
		WHERE num_credito = VlNumCredito AND fecha_emision = Vfechaemision ;
		
	COMMIT WORK;      


	   
     END FOREACH;  
     RETURN cCod_ret;
	END;
END PROCEDURE;