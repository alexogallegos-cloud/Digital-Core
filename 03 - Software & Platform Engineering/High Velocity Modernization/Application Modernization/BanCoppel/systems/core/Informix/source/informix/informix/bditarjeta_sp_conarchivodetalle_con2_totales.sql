CREATE PROCEDURE "informix".sp_conarchivodetalle_con2_totales(
														cTipo char(1),
														cTipoCon varchar(3),
														cNombreArchivo varchar(23),
														cNumEmpl varchar(9)
													)
RETURNING VARCHAR(6) as Cod_ret, INTEGER AS no_registros;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE vNoRegistros INTEGER;
	
	LET vNoRegistros = 0;	

	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('9','Error en sp_conarchivodetalle_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;

     RETURN P_COD_RET, vNoRegistros;	
								
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Detalle de Archivos de ConciliaciÃ³n
--************************************************************
-- Modificado: Juan Fco. Ponce Damian 
-- fecha : 06/09/2013
-- DescripciÃ³n: Se modificaron todos las consultas para retornar el Monto de Cash Back.
--************************************************************
-- Modificado: L.I.A. Ricardo Resendiz Martinez
-- fecha : 18/09/2015
-- DescripciÃ³n: Se modifica consulta para que busque por la clave del tipo de conciliaciÃ³n. Se redujeron de 60 a 3 el cTipoCon
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   IF (cTipo == 'A') THEN --Todos los Registros
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion 	
		WHERE nombrearchivo = trim(cNombreArchivo);
													
		RETURN P_COD_RET, vNoRegistros;	
		
	ELIF (cTipo == 'B') THEN --Error de Integridad
		
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion 	
		WHERE nombrearchivo = trim(cNombreArchivo) AND integridad = 'F';
													
		RETURN P_COD_RET, vNoRegistros;	
		
	ELIF (cTipo == 'C') THEN --Error de Integridad

		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND 
			  --tipo_conciliacion = (select tipo_conciliacion from bditarjeta:td_tipo_conciliacion  where desc_conciliacion =trim (cTipoCon))			
			  tipo_conciliacion = cTipoCon;
			  
		RETURN P_COD_RET, vNoRegistros;	

	ELIF (cTipo == 'D') THEN --Error de Integridad
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'F' AND integridad = 'V' AND conciliacion = 'V';
							
		RETURN P_COD_RET, vNoRegistros;	
			
	ELIF (cTipo == 'E') THEN --Error de Integridad
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'V'; 
							
		RETURN P_COD_RET, vNoRegistros;	
			
	END IF;

      
END;
END PROCEDURE;