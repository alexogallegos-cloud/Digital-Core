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