CREATE PROCEDURE "informix".sp_concreing_actualizarepositoriosparam ( 
psCve_usuario CHAR(10) ,
psArchivoOrigen CHAR(3),
psRep_Win VARCHAR(50),
psRep_Aix VARCHAR(50),
psHistorico VARCHAR(90),
psDiasBitacora VARCHAR(90),
psDiasMovimientos VARCHAR(90),
psDiasArchivosAIX VARCHAR(90),
piFicha INTEGER
)
	RETURNING CHAR (5) AS Retorno;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  ACTUALIZA REPOSITORIOS Y DIAS DE DEPURACION  ---------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/11/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	
	DEFINE vsCodigoRetorno CHAR(5);

	/* INICIALIZACION DE VARIABLES */

	LET vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 45;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	
	LET vsCodigoRetorno = '00000';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_ActualizaRepositoriosParam';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN 	NVL(vssqlerr,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceActualizaRepositoriosParam.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONSULTAREPOSITORIOS.txt';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		IF (piFicha == 1) THEN 
			UPDATE bditarjeta:"informix".td_archivo_origenTMP
			SET     rep_aix = TRIM(psRep_Aix), 
                    rep_win = TRIM(psRep_Win)
			WHERE archivo_origen = psArchivoOrigen;

            UPDATE bditarjeta:"informix".td_archivo_origen
			SET     rep_aix = TRIM(psRep_Aix), 
                    rep_win = TRIM(psRep_Win)
			WHERE archivo_origen = psArchivoOrigen;

			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = TRIM(psHistorico)
			WHERE codigo = '401';
			
			LET vsActividad = 'SE ACTUALIZAN LAS RUTAS DE LOS REPOSITORIOS PARA EL ARCHIVO [' || psArchivoOrigen || ']';
			
		ELIF (piFicha == 2) THEN 
		
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasBitacora
			WHERE codigo = '402';
			
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasMovimientos
			WHERE codigo = '403';
			
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasArchivosAIX
			WHERE codigo = '404';
			
			LET vsActividad = 'SE ACTUALIZAN LOS DÍAS DE DEPURACIÓN DE LAS TABLAS DEL PROCESO DE CONCILIACIÓN';
			
		END IF;
		
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN vsCodigoRetorno;
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: ACTUALIZA REPOSITORIOS Y DIAS DE DEPURACION.',
'Fecha: 2011/11/24',
'Version: 20111124.1102',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 45.',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Migracion de SIF a SOC ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega opcion de actualizar tambien la tabla de Catalogo principal ademas de la temporal',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_conarchivodetalle_con(
														cTipo char(1),
														cTipoCon varchar(3),
														cNombreArchivo varchar(23),
														cNumEmpl varchar(9)
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
-- Funcion: Consulta de Detalle de Archivos de Conciliación
--************************************************************
-- Modificado: Juan Fco. Ponce Damian 
-- fecha : 06/09/2013
-- Descripción: Se modificaron todos las consultas para retornar el Monto de Cash Back.
--************************************************************
-- Modificado: L.I.A. Ricardo Resendiz Martinez
-- fecha : 18/09/2015
-- Descripción: Se modifica consulta para que busque por la clave del tipo de conciliación. Se redujeron de 60 a 3 el cTipoCon
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   IF (cTipo == 'A') THEN --Todos los Registros
		FOREACH			
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
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
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
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
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
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
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
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
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
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