CREATE PROCEDURE "informix".sp_depura_movhis_vendida(pfecha_insert DATE)
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

    --SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_depura_estado_cuentaTC.out";
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
        select num_credito
          into VlNumCredito  
        --from bdicred:sd_maecred_vendida
		from bdicred:sd_maecred_vend_total
        where --empresa = '001' and
         fecha <= mdy('12','31','2010')

       BEGIN WORK;
        DELETE FROM bdicred:sd_movhis WHERE empresa = '001' and  num_credito = VlNumCredito;
       COMMIT WORK;

     END FOREACH;  
     RETURN cCod_ret;
	END;

END PROCEDURE;