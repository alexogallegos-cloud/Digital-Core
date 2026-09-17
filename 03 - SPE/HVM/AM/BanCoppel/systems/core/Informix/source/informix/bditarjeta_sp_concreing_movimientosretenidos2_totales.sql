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