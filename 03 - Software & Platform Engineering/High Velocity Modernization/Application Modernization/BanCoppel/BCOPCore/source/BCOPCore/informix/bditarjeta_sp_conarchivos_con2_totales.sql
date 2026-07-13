CREATE PROCEDURE "informix".sp_conarchivos_con2_totales(cparam1 char(1),cTipo char(3),dfecha_ini date,dfecha_fin date,cUsuario char(10),cNumEmpl varchar(9))
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
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('130','Error en sp_conarchivos_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
      RETURN P_COD_RET, vNoRegistros;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Archivos de conciliaciÃ³n por fecha
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   IF (cparam1 == 1) THEN --Consulta por Todos los archivos 
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_archivos_conciliacion
		WHERE fecha_proceso BETWEEN dfecha_ini AND dfecha_fin;
		
		RETURN P_COD_RET, vNoRegistros;	

	ELIF (cparam1 == 2) THEN --Consulta un Archivo en especifico
			
		SELECT COUNT(*)					
		INTO vNoRegistros		
		FROM bditarjeta:"informix".td_archivos_conciliacion
		WHERE 	archivo_origen = trim(cTipo)  
				and fecha_proceso BETWEEN dfecha_ini AND dfecha_fin; 
			
		RETURN P_COD_RET, vNoRegistros;	
   
	END IF;
  
END;
END PROCEDURE;