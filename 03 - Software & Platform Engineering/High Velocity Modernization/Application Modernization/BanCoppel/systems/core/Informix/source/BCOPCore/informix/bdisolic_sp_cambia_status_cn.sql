CREATE PROCEDURE "informix".sp_cambia_status_cn(pempresa CHAR(3))
RETURNING  CHAR(6),CHAR(80);

DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cMensaje 		                CHAR(80); 
DEFINE cCod_ret                         CHAR(6);
DEFINE cSql                             CHAR(12000);
DEFINE v_num_sol                        CHAR(20);
DEFINE v_status_sol                     CHAR(2);
DEFINE contador_commit                  INTEGER;
DEFINE sCommit                          SMALLINT;


LET cCod_ret        = '00000';
LET cMensaje        = 'PROCESO EXITOSO';
LET sql_err         = 0;
LET v_num_sol       = "";
LET v_status_sol    = "";
LET contador_commit = 0;
LET sCommit         = 0;


      BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        IF (sCommit = -1) THEN
            rollback work;
        END IF;
        RETURN cCod_ret, cMensaje;
	  END EXCEPTION;

--SET DEBUG FILE TO "/pisa/leo/sp_cambia_status_cn.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


     FOREACH WITH HOLD

        SELECT a.num_solicitud,b.status_solicitud 
          INTO v_num_sol, v_status_sol  
          FROM bdisolic:ss_solicitudes a, 
               bdisolic:ss_autorizacion b
        WHERE a.empresa = b.empresa 
          AND a.empresa = pempresa  
          AND a.num_solicitud = b.num_solicitud 
          AND a.status_solicitud = b.status_solicitud
          AND a.status_solicitud IN ('CV','CR')


          BEGIN WORK;

          IF trim(v_status_sol) = 'CV' THEN

                  UPDATE bdisolic:ss_solicitudes
                     SET status_solicitud = 'CN'
                   WHERE empresa = pempresa 
                     AND num_solicitud = v_num_sol
                     AND status_solicitud = v_status_sol;

                  UPDATE bdisolic:ss_autorizacion
                     SET status_solicitud = 'CN', causa_solicitud = 'CV'
                   WHERE empresa = pempresa 
                     AND num_solicitud = v_num_sol
                     AND status_solicitud = v_status_sol;

                   LET contador_commit = contador_commit + 1;

          ELSE

                  UPDATE bdisolic:ss_solicitudes
                     SET status_solicitud = 'CN'
                   WHERE empresa = pempresa 
                     AND num_solicitud = v_num_sol
                     AND status_solicitud = v_status_sol;

                  UPDATE bdisolic:ss_autorizacion
                     SET status_solicitud = 'CN', causa_solicitud = 'CR'
                   WHERE empresa = pempresa 
                     AND num_solicitud = v_num_sol
                     AND status_solicitud = v_status_sol;

                    LET contador_commit = contador_commit + 1;     

          END IF;
          
          COMMIT WORK;


     END FOREACH;


   UPDATE STATISTICS MEDIUM FOR TABLE bdisolic:"informix".ss_solicitudes;
   UPDATE STATISTICS MEDIUM FOR TABLE bdisolic:"informix".ss_autorizacion;

RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;