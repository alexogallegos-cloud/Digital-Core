CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_cred(pCuenta char(20))
        RETURNING char(5), date;

	-- Modificó: Javier Calderón
	-- Actividad: Obtener los últimos 3 periodos de estado de cuenta activos
	-- Solicitó: Mauricio León
	-- Fecha:  06/01/2010

	-- Definición de variables
       DEFINE vcodret       char(5);
       DEFINE vFechaEmision date;
       DEFINE sql_err       integer;
       DEFINE ffin          DATE;
	   DEFINE fini          DATE;
	   DEFINE fechaParam    char(7);
	   DEFINE indicador     char(1);
	   DEFINE fechaActual	DATE;
	   DEFINE iDiaActual	int;
	   DEFINE iMesActual	int;
	   DEFINE iAnioActual   int;
	   DEFINE iMesBloq		int;
	   DEFINE fecha1		DATE;
	   DEFINE fecha2		DATE;
	   DEFINE fecha3		DATE;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vFechaEmision;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vFechaEmision = '01/01/1900';
let ffin = " ";
LET fini = " ";
LET fechaParam = " ";
LET indicador = " ";

BEGIN

set isolation to dirty read;

	LET iDiaActual = DAY(current);
	LET iMesActual = MONTH(current);
	LET iAnioActual = YEAR(current);

	IF iDiaActual < 21 THEN
		if iMesActual == 1 THEN
			LET iMesActual = 12;
			LET iAnioActual = iAnioActual - 1;
		ELSE 
			LET iMesActual = iMesActual - 1;
		END IF;
		
	END IF;

	LET fechaActual = iMesActual || "/20/" || iAnioActual;

	SELECT valor INTO fechaParam FROM bdicred@pld_tcp:sd_param WHERE empresa = '001' AND cod_param = '80';
	LET indicador = SUBSTR(fechaParam,1,1);

	IF indicador = "1" THEN
		LET iMesBloq = SUBSTR(fechaParam,6,2):: int;
		LET fecha1 = fechaActual;
		LET fecha2 = fechaActual - 1 UNITS MONTH;
		LET fecha3 = fechaActual - 2 UNITS MONTH;

		IF MONTH(fecha1) = iMesBloq THEN
			LET fecha1 = fecha1 - 1 UNITS MONTH;
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
		ELIF MONTH(fecha2) = iMesBloq THEN
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
		ELIF MONTH(fecha3) = iMesBloq THEN
			LET fecha3 = fecha3 - 1 UNITS MONTH;
		END IF;

		FOREACH
			SELECT fecha_emision
			INTO vFechaEmision
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3)
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC

			RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;

	ELSE
--		LET fini =  fechaActual - 2 UNITS MONTH;
		LET fecha1 = fechaActual;
		LET fecha2 = fechaActual - 1 UNITS MONTH;
		LET fecha3 = fechaActual - 2 UNITS MONTH;        

		FOREACH
			SELECT fecha_emision
			INTO vFechaEmision
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3)
	--		WHERE fecha_emision >= fini and  fecha_emision <= fechaActual
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC

			RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;
	END IF;
END;

END PROCEDURE;