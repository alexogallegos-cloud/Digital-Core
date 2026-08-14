CREATE PROCEDURE "informix".sp_conarchivodetalle_con2(
														cTipo char(1),
														cTipoCon varchar(3),
														cNombreArchivo varchar(23),
														cNumEmpl varchar(9),
														pregistros INTEGER, precuperacion INTEGER
													)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
    char(23) as nombrearchivo,
    char(3) as archivo_origen,       
    datetime year to fraction(3) as  fechacarga,
    char(1) as integridad,
    char(16) as numtarjeta,    
    char(6) as secuencia325,     
    char(13) as monto325,     
    char(13) as montocashback325,
    char(20) as numcuenta,     
    char(9) as idcomercio325,     
    char(30) as nomcomercio325,     
    char(15) as tipotransaccion325 


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	
	
	DEFINE vNombrearchivo char(23);
    DEFINE vArchivo_origen char(3);    
    DEFINE vFechacarga datetime year to fraction(3);    
    DEFINE vIntegridad char(1);
    DEFINE vNumtarjeta char(16);    
    DEFINE vSecuencia325 char(6);    
    DEFINE vMonto325 char(13);    
    DEFINE vmontocashback325 char(13);    
    DEFINE vNumcuenta char(20);    
    DEFINE vIdcomercio325 char(9);    
    DEFINE vNomcomercio325 char(30);    
    DEFINE vTipotransaccion325 char(15);
	
	
	LET vNombrearchivo = '';
    LET vArchivo_origen = '';
    LET vFechacarga  = '1900-01-01 00:00:00';    
    LET vIntegridad = '';
    LET vNumtarjeta = '';
    LET vSecuencia325 = '';
    LET vMonto325 = '';
    LET vmontocashback325 = '';
    LET vNumcuenta = '';
    LET vIdcomercio325 = '';
    LET vNomcomercio325 = '';
    LET vTipotransaccion325 = '';
		

	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('9','Error en sp_conarchivodetalle_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;

     RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
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
		FOREACH			
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion 	
			WHERE nombrearchivo = trim(cNombreArchivo)
														
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;
	ELIF (cTipo == 'B') THEN --Error de Integridad
		FOREACH		
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion 	
			WHERE nombrearchivo = trim(cNombreArchivo) AND integridad = 'F'
														
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;		
	ELIF (cTipo == 'C') THEN --Error de Integridad
		FOREACH		
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND 
				  --tipo_conciliacion = (select tipo_conciliacion from bditarjeta:td_tipo_conciliacion  where desc_conciliacion =trim (cTipoCon))			
				  tipo_conciliacion = cTipoCon
				  
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;
	ELIF (cTipo == 'D') THEN --Error de Integridad
		FOREACH		
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'F' AND integridad = 'V' AND conciliacion = 'V'
								
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;		
	ELIF (cTipo == 'E') THEN --Error de Integridad
		FOREACH		
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'V' 
								
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;			
	END IF;

      
END;
END PROCEDURE;