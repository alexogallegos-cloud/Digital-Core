CREATE PROCEDURE "informix".sp_previo_clientes_clean(p_fecha DATE,p_opcion INTEGER)
RETURNING CHAR(6),CHAR (100);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vcod_ret				CHAR(10);
DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);

DEFINE v_num_credito		CHAR(20);
DEFINE v_score				CHAR(4);


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET vcod_ret				= "000";
LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje 				= "";

LET v_num_credito			= "";
LET v_score					= 0;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


	BEGIN
		ON EXCEPTION SET vsqlerr
		IF vsqlerr != 0 THEN
			LET v_cod_ret=vsqlerr;
			LET v_Mensaje = "";	
			RETURN v_cod_ret,v_Mensaje;	
		END IF;
		END EXCEPTION;   
		
--	SET DEBUG FILE TO "/informix/Israel/sp_previo_clientes_clean.out";
--	TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
		IF p_opcion = 1 THEN
			FOREACH WITH HOLD 
			
				SELECT num_credito,score
				INTO v_num_credito,v_score
					FROM sd_clientes_clean_behavior WHERE fecha_reporte = p_fecha
				
				begin work;
				
					UPDATE bdicred:"informix".sd_clientes_clean_behavior 
					SET  score = substr(v_score,1,3)
					where fecha_reporte =  p_fecha
						AND num_credito = v_num_credito;
						
				COMMIT WORK;				
				
			END FOREACH;
				  

		ELIF p_opcion = 2 THEN
		
			FOREACH WITH HOLD 
		
				SELECT num_credito
				INTO v_num_credito
					FROM sd_clientes_clean_behavior WHERE fecha_reporte = p_fecha
				
				begin work;
				
				Delete  from sd_clientes_clean_behavior 
					where fecha_reporte =  p_fecha 
						AND num_credito = v_num_credito;
						
				COMMIT WORK;				
			
			END FOREACH;
	
		
		END IF;
		
		LET v_Mensaje = "Proceso exitoso";
			
		RETURN v_cod_ret,v_Mensaje;
	END;
				
END PROCEDURE;