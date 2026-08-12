CREATE PROCEDURE "informix".sp_co_erro_integra(p_usuario CHAR(8), p_fecha_captura DATE)
    RETURNING INTEGER, INTEGER , CHAR(10) ,CHAR(10) ,CHAR(10), CHAR(10), CHAR(10), CHAR(10) ,CHAR(12) ,CHAR(3)                                                 
	
    DEFINE vcontrol_poliza  INTEGER;
    DEFINE vsecuencia       INTEGER;
    DEFINE vccmayor         CHAR(10);
    DEFINE vccsub           CHAR(10);
    DEFINE vccsubsub        CHAR(10);
    DEFINE vccssubsub       CHAR(10);
    DEFINE vccsssubsub      CHAR(10);
    DEFINE vsector          CHAR(10);
    DEFINE vauxiliar        CHAR(12);
    DEFINE vcod_ret         CHAR(3);

	SET ISOLATION TO DIRTY READ;

	FOREACH
		SELECT control_poliza,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
			   sector,auxiliar,cod_ret
		  INTO vcontrol_poliza,vsecuencia,vccmayor,vccsub,vccsubsub,vccssubsub,
			   vccsssubsub,vsector,vauxiliar,vcod_ret
	      FROM bdicont:co_auditerr 
		 WHERE fecha_captura = p_fecha_captura AND usuario = p_usuario

		RETURN vcontrol_poliza,vsecuencia,vccmayor,vccsub,vccsubsub,vccssubsub,
			   vccsssubsub,vsector,vauxiliar,vcod_ret WITH RESUME;
	
	END FOREACH;

END PROCEDURE;