CREATE PROCEDURE "informix".sp_depura_telefonos(pfecha_insert DATE, porigen SMALLINT)
       RETURNING char(6), char(150);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;

    --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_carga_telefonos.out";
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
            RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

           
    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    FOREACH cursor_borra WITH HOLD FOR
                SELECT {+INDEX(cb_telefonos idx_cons_telefono2)} rowid 
                  INTO vrowid  
                  FROM bdicobranza:cb_telefonos
                 WHERE origen = porigen
                 AND fecha_insert < pfecha_insert  

                BEGIN WORK;
                   DELETE  FROM 
                     bdicobranza:cb_telefonos WHERE 
                    CURRENT OF cursor_borra;                                                                             
               COMMIT WORK;
             END FOREACH;  

        RETURN cCod_ret, cMensaje;
	END;
END PROCEDURE;