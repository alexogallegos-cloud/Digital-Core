CREATE PROCEDURE "informix".sp_concreing_monarchcr2_totales(psFlag CHAR(1), psUsuario CHAR(8), pdFecha DATE)
	RETURNING CHAR(5), INTEGER;

--***********************************************************************************************************
-- DESCRIPCION: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar
--              un paro de emergencia en caso de necesitarse.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/10/24
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE dtfecha_hoy_integral             DATE;
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vNoRegistros INTEGER;

LET dtfecha_hoy_integral = CURRENT::DATE;
LET vsCodRet = "00000";
LET viSqlErr = 0;
LET vNoRegistros = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_monarchcr.sql";
--TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
                RETURN viSqlErr, vNoRegistros;
        END IF;
	END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy INTO dtfecha_hoy_integral FROM bdinteg:"informix".Si_Fechas;

        --Obtiene registros de tabla con proceso diferente a V.
        IF(psFlag = "1")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

				SELECT COUNT(*)
				INTO
				vNoRegistros
				FROM bditarjeta:"informix".td_archivos_conciliacion 
				WHERE Proceso <> 'T' 
				OR Fecha_Proceso = dtfecha_hoy_integral;

				RETURN vsCodRet, vNoRegistros;
        --Obtiene registros con proceso igual a P.
        ELIF (psFlag = "2")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				SELECT COUNT(*)
				INTO vNoRegistros
				FROM bditarjeta:"informix".td_archivos_conciliacion AS archcon LEFT JOIN BdiTarjeta:"informix".td_archivo_origentmp AS archori
				ON archcon.archivo_origen = archori.archivo_origen
				WHERE proceso = 'P';
								
				RETURN vsCodRet, vNoRegistros;
        END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Descripcion: Conteo de numero de registros a devolver por las consultas',
'Fecha: 2015/09/07',
'Version: 20150907.1152',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_monarchcr2(psFlag CHAR(1), psUsuario CHAR(8), pdFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5), CHAR(23), CHAR(3), CHAR(20), CHAR(10), CHAR(16), CHAR(10), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25),
		CHAR(1), CHAR(1), CHAR(1), CHAR(20), CHAR(16), CHAR(20), CHAR(16), CHAR(1), INTEGER, INTEGER;

--***********************************************************************************************************
-- DESCRIPCION: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar
--              un paro de emergencia en caso de necesitarse.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/10/24
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE vsnombrearchivo                  CHAR(23);
DEFINE vsarchivo_origen                 CHAR(3);
DEFINE vsnum_registros325                       CHAR(20);
DEFINE vsfecha_archivo                  CHAR(10);
DEFINE vsmonto325                                       CHAR(16);
DEFINE vsfecha_proceso                  CHAR(10);
DEFINE vsfecha_hora_transferencia       CHAR(25);
DEFINE vsfecha_hora_ini_proceso CHAR(25);
DEFINE vsfecha_hora_carga_archivo       CHAR(25);
DEFINE vsfecha_hora_carga_tabla CHAR(25);
DEFINE vsfecha_hora_ini_concilia_reg    CHAR(25);
DEFINE vsfecha_hora_fin_concilia_reg    CHAR(25);
DEFINE vsfecha_hora_fin_proceso CHAR(25);
DEFINE vsfecha_hora_gen_conadmin        CHAR(25);
DEFINE vstransferencia                  CHAR(1);
DEFINE vscarga                                  CHAR(1);
DEFINE vsconadmin                                       CHAR(1);
DEFINE vsnum_cargo                              CHAR(20);
DEFINE vsmonto_cargo                            CHAR(16);
DEFINE vsnum_abono                              CHAR(20);
DEFINE vsmonto_abono                            CHAR(16);
DEFINE vsproceso                                        CHAR(1);
DEFINE dtfecha_hoy_integral             DATE;
DEFINE viordenproceso                   INTEGER;
DEFINE vicron                                   INTEGER;

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;

LET vsnombrearchivo = "";
LET vsarchivo_origen = "";
LET vsnum_registros325 = "";
LET vsfecha_archivo = "";
LET vsmonto325 = "";
LET vsfecha_proceso = "";
LET vsfecha_hora_transferencia = "";
LET vsfecha_hora_ini_proceso = "";
LET vsfecha_hora_carga_archivo = "";
LET vsfecha_hora_carga_tabla = "";
LET vsfecha_hora_ini_concilia_reg = "";
LET vsfecha_hora_fin_concilia_reg = "";
LET vsfecha_hora_fin_proceso = "";
LET vsfecha_hora_gen_conadmin = "";
LET vstransferencia = "";
LET vscarga = "";
LET vsconadmin = "";
LET vsnum_cargo = "";
LET vsmonto_cargo = "";
LET vsnum_abono = "";
LET vsmonto_abono = "";
LET vsproceso = "";
LET dtfecha_hoy_integral = CURRENT::DATE;
LET viordenproceso = 0;
LET vicron = 0;

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_monarchcr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
                RETURN viSqlErr, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                           vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                           vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                           vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
        END IF;
END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy INTO dtfecha_hoy_integral FROM bdinteg:"informix".Si_Fechas;

        --Obtiene registros de tabla con proceso diferente a V.
        IF(psFlag = "1")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion
                        nombrearchivo, archivo_origen, num_registros325, fecha_archivo, monto325, fecha_proceso,
                        fecha_hora_transferencia, fecha_hora_carga_tabla /*fecha_hora_ini_proceso*/, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
                        fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin,
                        transferencia, carga, conadmin, num_cargo, monto_cargo, num_abono, monto_abono, proceso
                        INTO
                        vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                        vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                        vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                        vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso
                        FROM bditarjeta:"informix".td_archivos_conciliacion 
                        WHERE Proceso <> 'T' 
                        OR Fecha_Proceso = dtfecha_hoy_integral
                        ORDER BY proceso

                        RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                                   vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                                   vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                                   vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0 WITH RESUME;
                END FOREACH
        --Obtiene registros con proceso igual a P.
        ELIF (psFlag = "2")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion
                        archori.orden_proceso, 
                        (CASE WHEN archcon.fecha_archivo = (dtfecha_hoy_integral::DATE - archori.dias_desfase)::DATE THEN archori.horario_ejecucion_hoy ELSE archori.horario_ejecucion_ext END) AS cron,
                        archcon.nombrearchivo, archcon.archivo_origen, archcon.fecha_hora_carga_tabla /*archcon.fecha_hora_ini_proceso*/, archcon.fecha_hora_carga_archivo, archcon.fecha_hora_carga_tabla, archcon.fecha_hora_ini_concilia_reg,
                        archcon.fecha_hora_fin_concilia_reg, archcon.fecha_hora_fin_proceso, archcon.fecha_hora_gen_conadmin, archcon.carga, archcon.conadmin, archcon.proceso
                        INTO
                        viordenproceso, vicron, vsnombrearchivo, vsarchivo_origen, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, 
                        vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin, vscarga, vsconadmin, vsproceso
                        FROM bditarjeta:"informix".td_archivos_conciliacion AS archcon LEFT JOIN BdiTarjeta:"informix".td_archivo_origentmp AS archori
                        ON archcon.archivo_origen = archori.archivo_origen
                        WHERE proceso = 'P'
                        ORDER BY cron, archori.orden_proceso
                                        
                        RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, '', '', '', '', '', vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, 
                                        vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, 
                                        vsfecha_hora_gen_conadmin, '', vscarga, vsconadmin, '', '', '', '', vsproceso, viordenproceso, vicron WITH RESUME;
                END FOREACH
                
        --Actualiza en F la conciliacion automatica en caso de paro de emergencia e inserta en bitacora hora, actividad, usuario.
        ELIF (psFlag = "3")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = 'F' WHERE codigo = '002';
                EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (8, 'PARO DE EMERGENCIA EN CONCILIACION AUTOMATICA', psUsuario) INTO vsCodRet;
                RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                           vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                           vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                           vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
        END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar un paro de emergencia en caso de necesitarse.',
'Fecha: 2011/10/24',
'Version: 20111024.1800',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Se quito el campo fecha de los criterios de busqueda y se dejo solamente el campo proceso.',
'Fecha: 2012/03/17',
'Version: 20120317.1557',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: SE MODIFICO EL CRITERIO DEL FILTRO PARA LA CONSULTA DE LOS ARCHIVOS PENDIENTES QUE CORRESPONDAN CON EL DIA ACTUAL, ADEMAS SE CAMBIA LA FECHA INI_PROCESO POR LA DE CARGA_ARCHIVO, PARA INDICAR EL INICIO DE TRABAJO DE CADA ARCHIVO.',
'Fecha: 2012/06/27',
'Version: 20120627.1637',
'BD: bditarjeta',
'',
'MODIFICADO: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Descripcion: Se agregan parametros para el manejo de paginado en la consulta',
'Fecha: 2015/09/07',
'Version: 20150907.1152',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_movimientosretenidos2_totales ( pTipo CHAR(1), pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING CHAR(5), INTEGER;

--************************************************************
-- Creado por Adilene Lara Armenta.
--12/ 10/2011
-- Funcion de Consulta de movimientos retenidos pendientes por liberar de cheques & credito.
-- Hector Juan Casanova Edeza -- 22/05/2012 -SE MODIFICO LA LOGICA DEL PROCEDIMIENTO PARA QUE HACEPTE LOS PARAMETROS DE FECHA INICIAL Y FINAL PARA ACOTAR EL ESPACIO DE BUSQUEDA DE LA CONSULTA.
-----------------------------------------------------------------------------

--DefiniciÃ³n de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	DEFINE vNoRegistros INTEGER;
	
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";
    LET vNoRegistros = 0;
	
BEGIN

--Control de Errores 

ON EXCEPTION SET sql_err
  LET cod_ret = sql_err;
  RETURN cod_ret, vNoRegistros;
END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/Tracemovimientosretenidos.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--CONSULTA DE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR

	SELECT COUNT(*)					
	INTO vNoRegistros
	FROM bditarjeta:"informix".td_retenidos
	WHERE tipo = NVL(pTipo,'')
	AND fecha_retencion BETWEEN NVL(pdtFechaIni, '01/01/1900') AND NVL(pdtFechaFin, '01/01/1900');
	
	RETURN 	cod_ret, vNoRegistros;
	
END;
END PROCEDURE;