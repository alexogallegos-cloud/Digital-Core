CREATE PROCEDURE "informix".sp_quita_marcaje_adirecta(p_empresa CHAR(3))
RETURNING CHAR(6);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);

DEFINE v_fechahoy			DATE;
DEFINE v_numsol				CHAR(20);



-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje 				= "";

LET v_fechahoy				= DATE(1);
LET v_numsol				= "";



-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET v_cod_ret=vsqlerr;
      RETURN v_cod_ret;
   END IF;
END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/sp_quita_marcaje_osdirecta.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	SELECT {+INDEX(bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy
	INTO v_fechahoy
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = p_empresa;


	FOREACH WITH HOLD
						
		SELECT a.num_solicitud  INTO v_numsol
        FROM "informix".ss_nuevo_parametrico a
        JOIN "informix".ss_solicitud_os b on (b.num_solicitud = a.num_solicitud)
		JOIN "informix".ss_solicitudes c on (c.num_solicitud = a.num_solicitud)
        WHERE a.empresa = p_empresa    
            and a.status_solicitud = 'A'
            and a.flag_altadirecta_asupervisar = 1
            and c.num_producto= '6500'
            and c.fecha_insert = v_fechahoy
            and c.status_solicitud = 'AT'
            and b.status = 'T'   

			UPDATE {+INDEX("informix".ss_solicitud_os idx_ss_solicitud_os)} "informix".ss_solicitud_os
			SET status = 'S', observacion1 = ""
			WHERE num_solicitud = v_numsol;		

			UPDATE "informix".ss_os_solautdirecta
			SET situacionespecial = "", causa = ""
			WHERE num_solicitud = v_numsol;
			
			UPDATE "informix".ss_nuevo_parametrico 
			SET situacion_especial = '', causa_sitesp = '' 
			WHERE num_solicitud = v_numsol;
				
	END FOREACH;
	
  RETURN v_cod_ret;
END; 

END PROCEDURE;