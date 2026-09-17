CREATE PROCEDURE "informix".sp_depura_estado_cuentatc(pfecha_insert DATE)
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

    FOREACH  WITH HOLD
        SELECT num_credito
          into VlNumCredito
        from bdicred:sd_encabezado_edocta
        where fecha_emision =pfecha_insert  --mdy('04','20','2012')
        group by num_credito
        having count(*) > 1

       BEGIN WORK;
        DELETE FROM bdicred:sd_encabezado_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
        DELETE FROM bdicred:sd_encabezado2_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
        DELETE FROM bdicred:sd_detalle_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
        DELETE FROM bdicred:sd_mensajes_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
        DELETE FROM bdicred:sd_pie_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
        DELETE FROM bdicred:sd_aclaraciones_edocta WHERE fecha_emision = pfecha_insert and  num_credito = VlNumCredito;
       COMMIT WORK;
     END FOREACH;
       RETURN cCod_ret;
	END;
END PROCEDURE;