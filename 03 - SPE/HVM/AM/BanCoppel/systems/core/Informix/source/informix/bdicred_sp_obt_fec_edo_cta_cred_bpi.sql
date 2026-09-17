CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_cred_bpi(pCuenta char(20), pDiasTimbrado integer)
        RETURNING char(5), date;

	-- Realizp: Hector Ramon Moreno Moreno
	-- Actividad: Obtener los ÃÂÃÂºltimos 3 periodos de estado de cuenta activos
	-- Fecha:  16/12/2016

	-- DefiniciÃÂÃÂ³n de variables
       DEFINE vcodret       char(5);
       DEFINE vFechaEmision date;
	   
	   DEFINE vFechaEmision_Hist DATE;
	   DEFINE vFechaTimbrado_Hist DATE;
	   DEFINE iContador_Hist	int;
	   DEFINE vProducto_Hist char(4);
       
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
	   DEFINE fecha4		DATE;
	   DEFINE vFechaTimbrado DATE;
	   DEFINE fechaServidor	DATE;
	   DEFINE iContador		int;
	   DEFINE vProducto	   char(4);
	   DEFINE vEsQuince	char(4);

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
LET iContador = 0;
LET vProducto = "";

LET vEsQuince = 'false';
LET iContador_Hist = 1;
LET vFechaEmision_Hist = '01/01/1900';
LET vProducto_Hist = "";

BEGIN

--SET DEBUG FILE TO "/home/sysifx/hector/sp_obt_fec_edo_cta_cred_bpi.out";
--TRACE ON;

--SET DEBUG FILE TO "/ifxsif01/phlc/incidencia_edo_cta_app/sp_obt_fec_edo_cta_cred_bpi.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;

	LET iDiaActual = DAY(current);
	LET iMesActual = MONTH(current);
	LET iAnioActual = YEAR(current);
	
	-------------------------------------
	LET fechaServidor = iMesActual || "/" || iDiaActual || "/" || iAnioActual;
	
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
		LET fecha4 = fechaActual - 3 UNITS MONTH;

		IF MONTH(fecha1) = iMesBloq THEN
			LET fecha1 = fecha1 - 1 UNITS MONTH;
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha2) = iMesBloq THEN
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha3) = iMesBloq THEN
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha4) = iMesBloq THEN
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		END IF;
		
		IF iDiaActual >= 15 OR iDiaActual = 22 THEN
			LET vEsQuince = 'true';
		END IF;

		FOREACH
			SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
			INTO vFechaEmision, vFechaTimbrado, vProducto
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC
			
			IF (YEAR(vFechaTimbrado) >= YEAR(vFechaEmision)) AND(MONTH(vFechaTimbrado) >= MONTH(vFechaEmision)) THEN
				IF fechaServidor >= vFechaTimbrado THEN
				
					IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
					ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
					END IF;
					
					IF iContador < 3 THEN
						LET iContador = iContador + 1;
						RETURN vcodret, vFechaEmision WITH RESUME;
					END IF;
				END IF;
			ELSE
				IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
					LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
				ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
				END IF;
				IF iContador < 3 THEN
					LET iContador = iContador + 1;
					RETURN vcodret, vFechaEmision WITH RESUME;
				END IF;
			END IF;
			
			--------------------LO NUEVO-------------------
			IF vEsQuince = 'true' AND iContador_Hist = 1 AND iContador = 2 THEN
			
				FOREACH			
					SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
					INTO vFechaEmision_Hist, vFechaTimbrado_Hist, vProducto_Hist
					FROM bdicred@pld_tcp:sd_encabezado_edocta_hist
					WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
					AND num_credito = pCuenta
					ORDER BY fecha_emision DESC
					
					--IF iContador_Hist = 1 THEN
						IF (YEAR(vFechaTimbrado_Hist) >= YEAR(vFechaEmision_Hist)) AND(MONTH(vFechaTimbrado_Hist) >= MONTH(vFechaEmision_Hist)) THEN
							IF fechaServidor >= vFechaTimbrado_Hist THEN
							
								IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
									LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
								ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
								END IF;
								
								IF iContador_Hist = 1 THEN
									LET iContador_Hist = iContador_Hist + 1;
									LET vEsQuince = 'false';
									RETURN vcodret, vFechaEmision_Hist WITH RESUME;
								END IF;
							END IF;
						ELSE
							IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
								LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
							ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
								LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
							END IF;
							IF iContador_Hist = 1 THEN
								LET iContador_Hist = iContador_Hist + 1;
								LET vEsQuince = 'false';
								RETURN vcodret, vFechaEmision_Hist WITH RESUME;
							END IF;
						END IF;
					--END IF;
				END FOREACH;
			END IF;
			--------------------------
			
        --IF vAnioMes IS NULL THEN
        --  LET vcodret = '100';
          --RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
        --END IF;

			--RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;

	ELSE
--		LET fini =  fechaActual - 2 UNITS MONTH;
		LET fecha1 = fechaActual;
		LET fecha2 = fechaActual - 1 UNITS MONTH;
		LET fecha3 = fechaActual - 2 UNITS MONTH;      
		LET fecha4 = fechaActual - 3 UNITS MONTH;
		
		IF iDiaActual >= 15 OR iDiaActual = 22 THEN
			LET vEsQuince = 'true';
		END IF;

		FOREACH
			SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
			INTO vFechaEmision, vFechaTimbrado, vProducto
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
	--		WHERE fecha_emision >= fini and  fecha_emision <= fechaActual
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC
			
			IF (YEAR(vFechaTimbrado) >= YEAR(vFechaEmision)) AND(MONTH(vFechaTimbrado) >= MONTH(vFechaEmision)) THEN
				IF fechaServidor >= vFechaTimbrado THEN
					IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
					ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
					END IF;
					IF iContador < 3 THEN
						LET iContador = iContador + 1;
						RETURN vcodret, vFechaEmision WITH RESUME;
					END IF;
				END IF;
			ELSE
				IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
				ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
				END IF;
				IF iContador < 3 THEN
					LET iContador = iContador + 1;
					RETURN vcodret, vFechaEmision WITH RESUME;
				END IF;
			END IF; 

			--------------------LO NUEVO-------------------
			IF vEsQuince = 'true' AND iContador_Hist = 1 AND iContador = 2 THEN
				FOREACH			
					SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
					INTO vFechaEmision_Hist, vFechaTimbrado_Hist, vProducto_Hist
					FROM bdicred@pld_tcp:sd_encabezado_edocta_hist
					WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
					AND num_credito = pCuenta
					ORDER BY fecha_emision DESC
					
						IF (YEAR(vFechaTimbrado_Hist) >= YEAR(vFechaEmision_Hist)) AND(MONTH(vFechaTimbrado_Hist) >= MONTH(vFechaEmision_Hist)) THEN
							IF fechaServidor >= vFechaTimbrado_Hist THEN
							
								IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
									LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
								ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
								END IF;
								
								IF iContador_Hist = 1 THEN
									LET iContador_Hist = iContador_Hist + 1;
									LET vEsQuince = 'false';
									RETURN vcodret, vFechaEmision_Hist WITH RESUME;
								END IF;
							END IF;
						ELSE
							IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
								LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
							ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
							END IF;
							IF iContador_Hist = 1 THEN
								LET iContador_Hist = iContador_Hist + 1;
								LET vEsQuince = 'false';
								RETURN vcodret, vFechaEmision_Hist WITH RESUME;
							END IF;
						END IF;
				END FOREACH;
			END IF;
			--------------------------
			
			
			--RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;
	END IF;
END;

END PROCEDURE;