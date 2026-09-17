CREATE PROCEDURE "informix".sp_concreing_consultamttoparam ( psCve_usuario CHAR(10) )
	RETURNING CHAR (5) AS Retorno, 
	VARCHAR(90) AS HistoricoConciliacion,
	VARCHAR(90) AS BitacoraConciliacion,
	VARCHAR(90) AS MovimientosConciliacion,
	VARCHAR(90) AS ArchivosAix;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE PARAMETROS DE REPOSITORIOS Y DEPURACION  -------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 16/11/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE vsCodigoRetorno CHAR(5);
	DEFINE vsHistoricoConciliacion VARCHAR(90);
	DEFINE vsbBitacoraConciliacion VARCHAR(90);
	DEFINE vsMovimientosConciliacion VARCHAR(90);
	DEFINE vsArchivosAix VARCHAR(90);

	/* INICIALIZACION DE VARIABLES */

	LET vsErrorActividad = '';
	LET vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 45;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET vsCodigoRetorno = '00000';
	LET vsHistoricoConciliacion = '';
	LET vsbBitacoraConciliacion = '';
	LET vsMovimientosConciliacion = '';
	LET vsArchivosAix = '';
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_consultaMttoParam';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsHistoricoConciliacion,''),
				NVL(vsbBitacoraConciliacion,''),
				NVL(vsMovimientosConciliacion,''),
				NVL(vsArchivosAix,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceConsultaMttoParam.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONSULTAREPOSITORIOS.txt';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		SELECT FIRST 1 VALOR
		INTO vsHistoricoConciliacion
		FROM bditarjeta:"informix".td_param_conciliacion_concreing
		WHERE CODIGO = 401;

		IF (vsHistoricoConciliacion IS NULL) THEN
			LET viErrores = viErrores + 1;
		END IF;

		SELECT FIRST 1 VALOR
		INTO vsbBitacoraConciliacion
		FROM bditarjeta:"informix".td_param_conciliacion_concreing
		WHERE CODIGO = 402;

		IF (vsbBitacoraConciliacion IS NULL) THEN
			LET viErrores = viErrores + 1;
		END IF;

		SELECT FIRST 1 VALOR
		INTO vsMovimientosConciliacion
		FROM bditarjeta:"informix".td_param_conciliacion_concreing
		WHERE CODIGO = 403;

		IF (vsMovimientosConciliacion IS NULL) THEN
			LET viErrores = viErrores + 1;
		END IF;
		
		SELECT FIRST 1 VALOR
		INTO vsArchivosAix
		FROM bditarjeta:"informix".td_param_conciliacion_concreing
		WHERE CODIGO = 404;

		IF (vsArchivosAix IS NULL) THEN
			LET viErrores = viErrores + 1;
		END IF;
		
		IF (viErrores >0) THEN 
			LET vssqlerr = '00100';
			LET error_info = ' AL EJECUTAR sp_concreing_consultaMttoParam';
			LET vsActividad = 'ERROR ' || vssqlerr ||' INFORMIX '||error_info;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		END IF;
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsHistoricoConciliacion,''),
				NVL(vsbBitacoraConciliacion,''),
				NVL(vsMovimientosConciliacion,''),
				NVL(vsArchivosAix,'');
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA DE PARAMETROS DE REPOSITORIOS Y DEPURACION.',
'Fecha: 2011/11/16',
'Version: 20111116.1545',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 45.',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultaproghorarios ( psCve_usuario CHAR(10) )
	RETURNING CHAR (5) AS Retorno, 
	CHAR(3) AS ArchivoOrigen,
	INTEGER AS Orden_Proceso,
	CHAR(1) AS Horario_Ejecucion_Hoy,
	CHAR(1) AS Horario_Ejecucion_Ext;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA PROGRAMACION DE HORARIOS  -------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 17/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE vsCodigoRetorno CHAR(5);
	DEFINE vsArchivoOrigen CHAR(3);
	DEFINE vsOrden_Proceso INTEGER;
	DEFINE vsHorario_Ejecucion_Hoy CHAR(1);
	DEFINE vsHorario_Ejecucion_Ext CHAR(1);
	

	/* INICIALIZACION DE VARIABLES */

	LET vsErrorActividad = '';
	LET vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 42;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET vsCodigoRetorno = '00000';
	LET vsArchivoOrigen ='';
	LET vsOrden_Proceso = 0;
	LET vsHorario_Ejecucion_Hoy = '';
	LET vsHorario_Ejecucion_Ext = '';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_consultaProgHorarios';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsArchivoOrigen,''),
				NVL(vsOrden_Proceso,0),
				NVL(vsHorario_Ejecucion_Hoy,''),
				NVL(vsHorario_Ejecucion_Ext,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceCONSULTAPROGHORARIOS.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONSULTAPROGHORARIOS.txt';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
		FOREACH 
			SELECT archivo_origen, orden_proceso, horario_ejecucion_hoy, horario_ejecucion_ext
			INTO vsArchivoOrigen, vsOrden_Proceso, vsHorario_Ejecucion_Hoy, vsHorario_Ejecucion_Ext
			FROM bditarjeta:"informix".td_archivo_origentmp
			WHERE tipo_layout != 5 
			GROUP BY horario_ejecucion_hoy, orden_proceso, horario_ejecucion_ext,archivo_origen
			ORDER BY horario_ejecucion_hoy, orden_proceso, horario_ejecucion_ext
			
			IF ((vsArchivoOrigen IS NULL)OR(TRIM(vsArchivoOrigen) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
			RETURN 	NVL(vssqlerr,''),
				NVL(vsArchivoOrigen,''),
				NVL(vsOrden_Proceso,0),
				NVL(vsHorario_Ejecucion_Hoy,''),
				NVL(vsHorario_Ejecucion_Ext,'')
			WITH RESUME;
			
		END FOREACH;
		
		IF ((viErrores >0)OR((vsArchivoOrigen IS NULL)OR(TRIM(vsArchivoOrigen) = '' ) ) ) THEN 
			LET vssqlerr = '00100';
			LET error_info = ' AL EJECUTAR SP_CONCREING_CONSULTAPROGHORARIOS';
			LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		END IF;

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA PROGRAMACION DE HORARIOS.',
'Fecha: 2011/10/17',
'Version: 20111017.1720',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 42.',
'Fecha: 2012/08/03',
'Version: 20120803.1605',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultarepositorios ( psCve_usuario CHAR(10) )
	RETURNING CHAR (5) AS Retorno, 
	CHAR(3) AS ArchivoOrigen,
	CHAR(50) AS Descripcion,
	VARCHAR(80) AS Rep_Win,
	VARCHAR(80) AS Rep_Aix;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE REPOSITORIOS  ----------------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 04/11/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE vsCodigoRetorno CHAR(5);
	DEFINE vsArchivoOrigen CHAR(3);
	DEFINE vsDescripcion VARCHAR(50);
	DEFINE vsRep_Aix VARCHAR(80);
	DEFINE vsRep_Win VARCHAR(80);

	/* INICIALIZACION DE VARIABLES */

	LET vsErrorActividad = '';
	LET vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 45;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET vsCodigoRetorno = '00000';
	LET vsArchivoOrigen ='';
	LET vsDescripcion = '';
	LET vsRep_Aix = '';
	LET vsRep_Win = '';
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_consultaProgHorarios';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsArchivoOrigen,''),
				NVL(vsDescripcion,''),
				NVL(vsRep_Aix,''),
				NVL(vsRep_Win,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceCONSULTAREPOSITORIOS.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONSULTAREPOSITORIOS.txt';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
		FOREACH 
			SELECT archivo_origen, descripcion, rep_aix, rep_win
			INTO vsArchivoOrigen, vsDescripcion, vsRep_Aix, vsRep_Win
			FROM bditarjeta:"informix".td_archivo_origen
			ORDER BY archivo_origen
			
			
			IF ((vsArchivoOrigen IS NULL)OR(TRIM(vsArchivoOrigen) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN 	NVL(vssqlerr,''),
				NVL(vsArchivoOrigen,''),
				NVL(vsDescripcion,''),
				NVL(vsRep_Aix,''),
				NVL(vsRep_Win,'')
			WITH RESUME;
			
		END FOREACH;
		
		IF ((viErrores >0)OR((vsArchivoOrigen IS NULL)OR(TRIM(vsArchivoOrigen) = '' ) ) ) THEN 
			LET vssqlerr = '00100';
			LET error_info = ' AL EJECUTAR sp_concreing_consultaRepositorios';
			LET vsActividad = 'ERROR ' || vssqlerr ||' INFORMIX '||error_info;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		END IF;
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA DE REPOSITORIOS.',
'Fecha: 2011/11/04',
'Version: 20111104.1448',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 45.',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultausuariosconciliacion ( )
RETURNING CHAR(5), CHAR(1), CHAR(10), CHAR(30), CHAR(1), CHAR(1), 
CHAR(1), DATETIME YEAR TO FRACTION(5);

--************************************************************
-- Creado por Adilene Lara Armenta.
--23/ 11/2011
-- Procedimiento almacenado que consulta los usuarios 
-----------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret              CHAR(5);
	DEFINE sql_err               SMALLINT;
 
	DEFINE v_activo              CHAR(1);
        DEFINE v_clave               CHAR(10);
        DEFINE v_nombre          CHAR(30);
        DEFINE v_operacion      CHAR(1);
        DEFINE v_monitoreo      CHAR(1);
        DEFINE v_admon            CHAR(1);
        DEFINE v_fecha               DATETIME YEAR TO FRACTION(5);
		
--Inicializacion de Variables

	LET cod_ret          = "000";
	LET sql_err           = "";

        LET v_activo          = "";
        LET v_clave           = "";
        LET v_nombre      = "";
        LET v_operacion  = "";
        LET v_monitoreo  = "";
        LET v_admon        = "";
        LET  v_fecha          = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
        
BEGIN

--Control de Errores 

   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN 	cod_ret, "", "", "", "", "", "", CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
   END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/consultausuarios.sql';
	--TRACE ON;

  SET LOCK MODE TO WAIT 10;

        FOREACH

            SELECT activo, cve_usuario, nombre, operacion, monitoreo, administracion,fecha_modificacion
            INTO v_activo, v_clave, v_nombre, v_operacion, v_monitoreo, v_admon, v_fecha
            FROM bditarjeta:"informix".td_usuarios_conciliacion
            ORDER BY 1 DESC

            RETURN 	cod_ret, NVL(v_activo, ""), NVL(v_clave, ""), NVL(v_nombre, ""), NVL(v_operacion, ""),
                                  NVL(v_monitoreo, ""), NVL (v_admon, ""),  NVL(v_fecha, CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))) 
                                  WITH RESUME;

	END FOREACH;
	
END;
END PROCEDURE;