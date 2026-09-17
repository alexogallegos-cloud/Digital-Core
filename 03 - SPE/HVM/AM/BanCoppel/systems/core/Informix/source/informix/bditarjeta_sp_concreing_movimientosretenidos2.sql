CREATE PROCEDURE "informix".sp_concreing_movimientosretenidos2 ( pTipo CHAR(1), pdtFechaIni DATE, pdtFechaFin DATE, pregistros INTEGER, precuperacion INTEGER)
RETURNING CHAR(5), CHAR(15),	DATETIME YEAR TO FRACTION(5), CHAR(20), MONEY(14,2), INTEGER;

--************************************************************
-- Creado por Adilene Lara Armenta.
--12/ 10/2011
-- Funcion de Consulta de movimientos retenidos pendientes por liberar de cheques & credito.
-- Hector Juan Casanova Edeza -- 22/05/2012 -SE MODIFICO LA LOGICA DEL PROCEDIMIENTO PARA QUE HACEPTE LOS PARAMETROS DE FECHA INICIAL Y FINAL PARA ACOTAR EL ESPACIO DE BUSQUEDA DE LA CONSULTA.
-----------------------------------------------------------------------------

--DefiniciÃ³n de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
 
	DEFINE v_cuenta_credito           CHAR(15);
        DEFINE v_fecha_retencion         DATETIME YEAR TO FRACTION(5);
        DEFINE v_folio_retencion           CHAR(20);
        DEFINE v_monto_retenido          MONEY(14, 2);
        DEFINE v_dias_restantes_lib     INTEGER;
		
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";

	LET v_cuenta_credito        = "";
	LET  v_fecha_retencion     = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET v_folio_retencion        = "";
	LET v_monto_retenido      = 0.00;
	LET v_dias_restantes_lib = 0;
        
BEGIN

--Control de Errores 

ON EXCEPTION SET sql_err
  LET cod_ret = sql_err;
  RETURN 	cod_ret,	"", CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5)), "", 0.00, 0;
END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/Tracemovimientosretenidos.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--CONSULTA DE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR

	FOREACH
		SELECT SKIP pregistros FIRST precuperacion cuenta_credito, fecha_retencion, folio_retencion, monto_retenido, dias_restantes_lib 
		INTO   v_cuenta_credito, v_fecha_retencion, v_folio_retencion, v_monto_retenido, v_dias_restantes_lib
		FROM bditarjeta:"informix".td_retenidos
		WHERE tipo = NVL(pTipo,'')
		AND fecha_retencion BETWEEN NVL(pdtFechaIni, '01/01/1900') AND NVL(pdtFechaFin, '01/01/1900')
		ORDER BY fecha_retencion
		
		 RETURN 	cod_ret, NVL(v_cuenta_credito, ""), NVL(v_fecha_retencion, CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), NVL(v_folio_retencion, ""), 
											NVL (v_monto_retenido, 0.00), NVL(v_dias_restantes_lib, 0) WITH RESUME;


	END FOREACH;
	
END;
END PROCEDURE;