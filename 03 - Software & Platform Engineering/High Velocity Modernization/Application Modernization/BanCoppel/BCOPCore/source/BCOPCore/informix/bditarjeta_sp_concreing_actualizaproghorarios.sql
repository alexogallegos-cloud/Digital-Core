CREATE PROCEDURE "informix".sp_concreing_actualizaproghorarios ( 
	psCve_usuario CHAR(10),
	psArchivo_origen CHAR (3), 
	psOrden_Proceso INTEGER,
	psHorario_Ejecucion_Hoy CHAR(1), 
	psHorario_Ejecucion_Ext CHAR(1)
)
	RETURNING CHAR (5) AS Retorno, CHAR(250) AS ErrorActividad;
	/*
	*****************************************************************************************************
	-----------------------------------------------------------------------------------------------------
	-- DESCRIPCION:  ACTUALIZA LA PROGRAMACION DE HORARIOS  ---------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 17/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica   -------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE v_orden_proceso INTEGER;
	DEFINE v_horario_ejecucion_hoy CHAR(1);
	DEFINE v_horario_ejecucion_ext CHAR(1);
	
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE viElemento INTEGER;
	DEFINE vsActividad VARCHAR(150);


	DEFINE viCodigo INTEGER;
	DEFINE isam_err INTEGER ;
	DEFINE error_info CHAR(70) ;
	
	DEFINE vssqlerr CHAR(5) ;

	/* INICIALIZACION DE VARIABLES */
	LET v_orden_proceso = 0;
	LET v_horario_ejecucion_hoy = '';
	LET v_horario_ejecucion_ext = '';
	
	LET vsRetBitacora = '';
	
	LET vsErrorActividad = '';
	LET viElemento = 42;
	LET vsActividad = '';
	
	LET viCodigo = 0;
	LET isam_err =0;
	LET error_info = '';
	LET vssqlerr = '00000';


	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado

		LET vssqlerr = viCodigo;
		
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_CompAplicacion';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		LET vsErrorActividad = vsActividad;
		
		RETURN NVL(vssqlerr,''), 
		NVL(vsErrorActividad,'');
			
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/pruebasconciliacion/TraceactualizaProgHorarios.sql';
	--SET DEBUG FILE TO '/informix/pruebasconciliacion/TraceactualizaProgHorarios.txt';
	--TRACE ON;

	-----------------------------------------------------
	--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--------2011/10/17-ING-ALFONSO-CRUZ------------------
	-----------------------------------------------------
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		SELECT orden_proceso, horario_ejecucion_hoy, horario_ejecucion_ext INTO v_orden_proceso, v_horario_ejecucion_hoy, v_horario_ejecucion_ext
		FROM bditarjeta:"informix".td_archivo_origentmp WHERE archivo_origen = psArchivo_origen;
		
		/*ACTUALIZAR VARIABLES DE RETORNO*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF ( (v_orden_proceso != psOrden_Proceso) or (v_horario_ejecucion_hoy != psHorario_Ejecucion_Hoy) or 
			 (v_horario_ejecucion_ext != psHorario_Ejecucion_Ext) ) THEN
		
			UPDATE bditarjeta:"informix".td_archivo_origentmp
			SET orden_proceso = psOrden_Proceso, horario_ejecucion_hoy = psHorario_Ejecucion_Hoy, horario_ejecucion_ext = psHorario_Ejecucion_Ext 
			WHERE archivo_origen = psArchivo_origen;
		
		--REGISTRO EN BITACORA DE ACTIVIDAD SI HAY CAMBIOS
		LET vsActividad = 'SE MODIFICARON LOS HORARIO DE EJECUCION PARA LOS ARCHIVOS '||psArchivo_origen ;
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento, vsActividad, psCve_usuario) INTO vsRetBitacora;
		
		ELIF (NOT EXISTS (SELECT archivo_origen FROM bditarjeta:"informix".td_archivo_origentmp WHERE archivo_origen = psArchivo_origen) ) THEN
		
			
			LET vssqlerr = '00100';
			LET vsActividad = 'ERROR DE SP_CONCREING_ACTUALIZAPROGHORARIOS PARA EL ARCHIVO_ORIGEN ' || psArchivo_origen;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento, vsActividad, psCve_usuario) 
			INTO vsRetBitacora;
			
		END IF;
		
		RETURN NVL(vssqlerr,''), 
			NVL(vsErrorActividad,'');
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: ACTUALIZA PROGRAMACION DE HORARIOS.',
'Fecha: 2011/10/17',
'Version: 20111017.1912',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 42.',
'Fecha: 2012/08/03',
'Version: 20120803.1605',
'BD: BdiTarjeta',
'',
'MODIFICACION: Juan Fco. Ponce Damian',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gómez',
'Descripcion: SE CAMBIO EL MENSAJE QUE PRESENTA LA BITACORA Y SE AÑADIÓ FILTRO PARA REGISTRAR SÓLO SI HAY CAMBIOS.',
'Fecha: 2012/08/03',
'Version: 20120803.1605',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_altausuarios (pActivo CHAR(1), pClave CHAR(10),  pNombre CHAR(30),
                                         pOperacion CHAR(1), pMonitoreo CHAR(1), pAdmon CHAR(1), pFecha DATE, psUsuario CHAR(10))
RETURNING CHAR(5);

--**************************************************************************************--
--  Creado por:  Adilene Lara Armenta.         
-- 23/ 11/2011                                                    
-- Procedimiento almacenado para dar de alta a los usuarios de la conciliación
--**************************************************************************************--

--Definición de Variables
	DEFINE cod_ret              CHAR(5);
	DEFINE vsCodRet2 CHAR(5);
	DEFINE viElemento INTEGER;
	DEFINE vsMensaje_Respuesta VARCHAR (250);

	DEFINE sql_err               SMALLINT;

--Inicializacion de Variables
	LET cod_ret          = "000";
	LET vsCodRet2 = '';
	LET viElemento = 43;
	LET vsMensaje_Respuesta = '';
	LET sql_err           = "";

BEGIN
--Control de Errores 
	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
	  
		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || sql_err || ') ALTA DEL USUARIO  [' || pClave || ']. ';
		EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;
	  
		RETURN 	cod_ret;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/altausuarios.sql';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;

	IF NOT EXISTS (SELECT nombre FROM bditarjeta:"informix".td_usuarios_conciliacion WHERE cve_usuario = pClave) THEN

		INSERT INTO bditarjeta:"informix".td_usuarios_conciliacion	
		( 
			activo,
			cve_usuario,
			nombre,
			operacion,
			monitoreo,
			administracion,
			fecha_modificacion
		)
		VALUES ( 
			pActivo,
			pClave,
			pNombre,
			pOperacion,
			pMonitoreo,
			pAdmon,
			pFecha
		);
		
		--GUARDA REGISTRO EN BITACORA
		LET vsMensaje_Respuesta = 'SE REGISTRA LA ALTA DEL USUARIO [' || pClave || '].';
		EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;
		
	ELSE
		LET cod_ret          = "002"; --Ya existe registro
	END IF;

RETURN cod_ret;

END;

END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL REGISTRO DE LA OPERACION EN BITACORA.',
'Fecha: 2012/08/03',
'Version: 20120803.1149',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_bajausuarios (pClave CHAR(10), psUsuario CHAR(10) )
RETURNING CHAR(5);

--*****************************************************************************************************************************
-- Creado por Adilene Lara Armenta.
--24/ 11/2011
-- Procedimiento almacenado que cambia a F estatus del usuario negandole el acceso al sistema de conciliación
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret              CHAR(5);
	DEFINE sql_err               SMALLINT;
	DEFINE vsCodRet2 CHAR(5);
	DEFINE viElemento INTEGER;
	DEFINE vsMensaje_Respuesta VARCHAR (250);
		
--Inicializacion de Variables

	LET cod_ret          = "000";
	LET sql_err           = "";
	
	LET vsCodRet2 = '';
	LET viElemento = 43;
	LET vsMensaje_Respuesta = '';
        
BEGIN

--Control de Errores 

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;

		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || sql_err || ') BAJA DE USUARIO [' || pClave || ']. ';
		EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;

		RETURN 	cod_ret;
		
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/bajausuarios.sql';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;

	UPDATE bditarjeta:"informix".td_usuarios_conciliacion
	SET activo = 'F'
	WHERE cve_usuario = pClave;
	
	--GUARDA REGISTRO EN BITACORA
	LET vsMensaje_Respuesta = 'SE REGISTRA LA BAJA DEL USUARIO [' || pClave || '].';
	EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;

	
	RETURN 	cod_ret;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL REGISTRO DE LA OPERACION EN BITACORA.',
'Fecha: 2012/08/03',
'Version: 20120803.1149',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultaarchivosconciliacion ( pFecha DATE)
RETURNING CHAR(5), CHAR(30), CHAR(5),  CHAR(1), DATE;

--************************************************************
-- Creado por Adilene Lara Armenta.
--18/ 10/2011
-- Funcion de Consulta de Archivos de conciliacion 
-----------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
 
	DEFINE v_nombre_archivo         CHAR(30);
        DEFINE v_archivo_origen            CHAR(5);
        DEFINE v_proceso                        CHAR(1);
        DEFINE v_fecha_archivo            DATE;
		
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";

	LET v_nombre_archivo        = "";
        LET v_archivo_origen        = "";
        LET v_proceso      = "";
        LET  v_fecha_archivo     = '01-01-1900';
        
BEGIN

--Control de Errores 

   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN 	cod_ret, "", "", "", '01-01-1900';
   END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/archivosConciliacion.sql';
	--TRACE ON;

  SET LOCK MODE TO WAIT 10;

--CONSULTA DE ARCHIVOS DE CONCILIACION CORRESPONDIENTES A LA FECHA

        FOREACH
            SELECT nombrearchivo, archivo_origen, proceso, fecha_archivo
            INTO   v_nombre_archivo, v_archivo_origen, v_proceso, v_fecha_archivo 
            FROM bditarjeta:'informix'.td_archivos_conciliacion 
			WHERE proceso <> 'T'
            --WHERE fecha_proceso = pFecha
           --AND proceso IN ('P', 'F')


		RETURN 	cod_ret, NVL(v_nombre_archivo, ""), NVL(v_archivo_origen, ""), NVL(v_proceso, ""), 
                                  NVL(v_fecha_archivo, '01-01-1900')  WITH RESUME;


	END FOREACH;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Adilene Lara Armenta',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Funcion de Consulta de Archivos de conciliacion.',
'Fecha: 2011/10/12',
'Version: 20110622.1125',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> V.',
'Fecha: 2012/03/13',
'Version: 20120313.1000',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> T.',
'Fecha: 2012/03/14',
'Version: 20120325.1110',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultacompconciliacion(
	psCve_usuario char (10), 		--USUARIO DEL SISTEMA
	psArchivo_origen CHAR (3), 		--TD_ARCHIVO_ORIGEN
	psConciliacion CHAR(1),   		-- bditarjeta:td_movimientos_conciliacion
	piConsecutivo INTEGER, 		--TD_MOVIMIENTOS_CONCILIACION	CONSECUTIVO
	psNumtarjeta CHAR (16), 	--TD_MOVIMIENTOS_CONCILIACION   NUMTARJETA
	psSecuencia325 CHAR(6),  	--TD_MOVIMIENTOS_CONCILIACION
	psMonto325 CHAR(13),
	psTipotransaccion325 CHAR(15),

	psIntegridad CHAR(1)         --PARAMETRO INICIAL
)

	RETURNING CHAR(5) AS Retorno,
				CHAR(1) AS Conciliacion ,
				CHAR(7) AS Secuencia,
				CHAR(15) AS Secuencia_extendida,
				MONEY AS Montointercard,
				DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
				CHAR(40) AS Infreceptor,
				CHAR(16) AS Idterminal,
				CHAR(2) AS Metodocaptura,
				CHAR(1) AS Movconciliado,
				CHAR(1) AS Movreversado,
				CHAR(1) AS Tipo_mov,
				CHAR(16) AS Folio_mov,
				DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
				INTEGER AS Tipo_conciliacion,
				CHAR(60) AS Desc_conciliacion,
				CHAR(250) AS ErrorActividad,
				INTEGER AS Elemento;
	/*
	*****************************************************************************************************
	-----------------------------------------------------------------------------------------------------
	-- DESCRIPCION:  COMPLEMENTA LA INTEGRIDAD DE LOS CAMPOS NECESARIOS PARA LA CONCILIACION  -----------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Complemento de Integridad  -----------------
	*****************************************************************************************************
	*/
	--VARIABLES DE ERRORES
	DEFINE vsRetBitacora CHAR(5);
	DEFINE vsActividad VARCHAR(150);

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INTEGER ;
	DEFINE error_info CHAR(70) ;

	--VARIABLES DE DATOS DEL SP
	DEFINE vsRetorno CHAR(5);
	DEFINE viRetorno INTEGER;
	DEFINE vsConciliacion CHAR(1);
	DEFINE vsConciliacionArchivo CHAR(1);
	DEFINE vsSecuencia CHAR(7);
	DEFINE vsSecuencia_extendida CHAR(15);
	DEFINE vmMontointercard MONEY;
	DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
	DEFINE vsInfreceptor CHAR(40);
	DEFINE vsIdterminal CHAR(16);
	DEFINE vsMetodocaptura CHAR(2);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsMovreversado CHAR(1);
	DEFINE vsTipo_mov CHAR(1);
	DEFINE vsFolio_mov CHAR(16);
	DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION(5);
	DEFINE viTipo_conciliacion INTEGER;
	DEFINE vsDesc_conciliacion CHAR(60);
	DEFINE vsErrorActividad CHAR (250) ;
	DEFINE viElemento INTEGER;
	
	
	--INICIALIZACION DE ERRORES
	LET vsRetBitacora = '';
	LET vsActividad ='';

	LET viCodigo = 0;
	LET vssqlerr = '';
	LET isam_err = 0;
	LET error_info = '';

	--VARIABLES DE DATOS DEL SP
	LET vsRetorno = '';
	LET viRetorno = 0;
	LET vsConciliacion = '';
	LET vsConciliacionArchivo = '';
	LET vsSecuencia = '';
	LET vsSecuencia_extendida = '';
	LET vmMontointercard = 0;
	LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET vsInfreceptor = '';
	LET vsIdterminal ='';
	LET vsMetodocaptura ='';
	LET vsMovconciliado ='';
	LET vsMovreversado ='';
	LET vsTipo_mov ='';
	LET vsFolio_mov ='';
	LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET viTipo_conciliacion =0;
	LET vsDesc_conciliacion = '';
	LET vsErrorActividad = '';
	LET viElemento = 40;
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		
		LET vsActividad = 'ERROR ' || TRIM(NVL(vssqlerr,'')) ||' ISAM '|| NVL(isam_err,0) ||' INFORMIX '||TRIM(NVL(error_info,'')) || ' EN sp_concreing_consultaCompConciliacion CONSECUTIVO ' || piConsecutivo;
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
			

		RETURN	vsRetorno,
				NVL(vsConciliacion,''),
				NVL(vsSecuencia,''),
				NVL(vsSecuencia_extendida,''),
				NVL(vmMontointercard,0),
				NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
				NVL(vsInfreceptor,''),
				NVL(vsIdterminal,''),
				NVL(vsMetodocaptura,''),
				NVL(vsMovconciliado,''),
				NVL(vsMovreversado,''),
				NVL(vsTipo_mov,''),
				NVL(vsFolio_mov,''),
				NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
				NVL(viTipo_conciliacion,0),
				NVL(vsDesc_conciliacion,''),
				NVL(vsErrorActividad,''),
				NVL(viElemento,40);

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceCONSULTACOMPCONCILIACION.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONCILIACION.txt';
	--TRACE ON;

	--REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--2011/10/24-ING-ALFONSO-CRUZ------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		--EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		
		UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET conciliacion = psConciliacion,
			secuencia = '',
			secuencia_extendida = '', 
			montointercard = 0.0,
			fechatransaccion = '1900-01-01 00:00:00',
			idterminal = '',
			infreceptor = '',
			metodocaptura = '',
			movconciliado = 'F',
			movreversado = 'F',
			tipo_mov = '',
			folio_mov = '',
			fechaconcilia = '1900-01-01 00:00:00',
			tipo_conciliacion = 0,
			--desc_conciliacion = vsDesc_conciliacion,
			--integridad = 'P',
			--conciliacion = 'P',
			aplicacion = 'P',
			finalizado = 'F',
			cod_retorno = ''
		WHERE consecutivo = piConsecutivo;
		
		--ACTUALIZA EL ESTATUS DE TRABAJO DEL ARCHIVO PARA SER REPROCESADO
		UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion
		SET Proceso = 'P'
		WHERE nombrearchivo IN (SELECT nombrearchivo FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE consecutivo = piConsecutivo);
		
		LET vsRetorno = '00000';
		LET vsActividad = 'SE COMPLEMENTA CONCILIACION INTERCARD DEL REGISTRO CON CONSECUTIVO '|| piConsecutivo ;
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
			
		RETURN	vsRetorno,
			NVL(psConciliacion,''),
			NVL(vsSecuencia,''),
			NVL(vsSecuencia_extendida,''),
			NVL(vmMontointercard,0),
			NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(vsInfreceptor,''),
			NVL(vsIdterminal,''),
			NVL(vsMetodocaptura,''),
			NVL(vsMovconciliado,''),
			NVL(vsMovreversado,''),
			NVL(vsTipo_mov,''),
			NVL(vsFolio_mov,''),
			NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(viTipo_conciliacion,0),
			NVL(vsDesc_conciliacion,''),
			NVL(vsErrorActividad,''),
			NVL(viElemento,40);
				
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA DE COMPLEMENTO DE CONCILIACION.',
'Fecha: 2011/10/24',
'Version: 20111024.1712',
'BD: bditarjeta',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CORRIGIO ERROR DE EJECUCION DE CONCILIACION INTERCARD.',
'Fecha: 2011/11/24',
'Version: 20111124.0952',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL STATUS DE finalizado = "F", ANTERIORMENTE P.',
'Fecha: 2012/08/01',
'Version: 20120801.1647',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE ACTUALIZA EL ESTATUS DE TRABAJO DEL ARCHIVO PARA SER REPROCESADO.',
'Fecha: 2012/08/13',
'Version: 20120813.1722',
'BD: BdiTarjeta';

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