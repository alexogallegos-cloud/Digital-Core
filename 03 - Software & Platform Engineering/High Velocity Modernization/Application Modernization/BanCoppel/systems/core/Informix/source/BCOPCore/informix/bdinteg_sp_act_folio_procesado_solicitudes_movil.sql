CREATE PROCEDURE "informix".sp_act_folio_procesado_solicitudes_movil() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;
DEFINE nfecha			DATE;


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;
LET nfecha				= '';


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/sp_act_folio_procesado_solicitudes_movil.out";
		--TRACE ON;
	
		Select fecha_hoy into nfecha from si_fechas;
	
			UPDATE si_solicitud_movil set folio_procesado=2
			where fecha_insert = nfecha 
			and status_valua is not null 
			and (num_prestamo is null or num_prestamo='') and (num_tdc_bcoppel is null or num_tdc_bcoppel='') and (num_tdc_coppel is null or num_tdc_coppel='')
			and folio_procesado=0
			and status_valua=1;
	
	LET vCodRet ='00000';
	
	
	
		
	
	return vCodRet;
END;
END PROCEDURE ;