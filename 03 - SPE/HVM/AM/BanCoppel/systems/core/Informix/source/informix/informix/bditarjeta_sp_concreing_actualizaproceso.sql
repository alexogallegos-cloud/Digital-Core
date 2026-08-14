CREATE PROCEDURE "informix".sp_concreing_actualizaproceso (p_Proceso CHAR(1), p_Nombre CHAR(30), psUsuario CHAR(10) )
RETURNING CHAR(5);

--************************************************************
-- Creado por Adilene Lara Armenta.
--18/ 10/2011
-- Funcion para actualizar proceso de los archivos de conciliacion
-----------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	
	DEFINE vsCodRet2 CHAR(5);
	DEFINE viElemento INTEGER;
	DEFINE vsMensaje_Respuesta VARCHAR (250);
	DEFINE p_Proceso_Ant CHAR(1);
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";
	
	LET vsCodRet2 = '';
	LET viElemento = 44;
	LET vsMensaje_Respuesta = '';
	LET p_Proceso_Ant = '';

BEGIN

--Control de Errores

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
		
		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || sql_err || ') PROGRAMAR CONCILIACION ARCHIVO [' || p_Nombre || ']. ';
		EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;
	
		RETURN 	cod_ret;
	END EXCEPTION;

    -- SET DEBUG FILE TO '/home/sysifx/soporte/concreing/actualizaproceso.sql';
    --TRACE ON;
	SELECT proceso INTO p_Proceso_Ant FROM bditarjeta:"informix".td_archivos_conciliacion
	WHERE nombrearchivo = p_Nombre;
	
	IF ( p_Proceso_Ant != p_Proceso) THEN
	
	SET LOCK MODE TO WAIT 10;
	--ACTUALIZA PROCESO DEL ARCHIVO DE CONCILIACION SEGUN EL NOMBRE  DE ARCHIVO
	UPDATE  bditarjeta:"informix".td_archivos_conciliacion
	SET proceso = p_Proceso
	WHERE nombrearchivo = p_Nombre;

	--GUARDA REGISTRO EN BITACORA
	LET vsMensaje_Respuesta = 'SE MODIFICA EL PROCESO DEL ARCHIVO [' || p_Nombre || ']  DE : '||p_Proceso_Ant|| ' A '||p_Proceso ;
	EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;
	
	END IF;
	
RETURN 	cod_ret;

END;
END PROCEDURE;