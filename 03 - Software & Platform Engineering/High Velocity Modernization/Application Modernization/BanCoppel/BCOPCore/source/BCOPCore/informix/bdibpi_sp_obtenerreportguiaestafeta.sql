CREATE PROCEDURE "informix".sp_obtenerreportguiaestafeta(pFechaIni char(10), pFechaFin char(10), pRegistros int)
		           returning char(5) as cod_ret, char(10) as vFechaEnvio, char(30) as vNumGuia, char(10) as vNumSolicitud, char(9) as vNumcliente, char(5) as vTotal

	   --Elaboró: Nubia Janeth Montoya Medina
	   --Actividad: Genera Reporte de Guía por Estafeta
	   --Solicito: Mauricio León
	   --Fecha: 03-02-2010
	
	
	-- DECLARA
		DEFINE sql_err integer;
		DEFINE cod_ret char(5);
		DEFINE vFechaEnvio char(10);
		DEFINE vNumGuia char(30);
		DEFINE vNumSolicitud char(10);
		DEFINE vNumCliente char(9);
		DEFINE vTotal integer;
		
	-- INICIALIZA
		LET cod_ret = '00000';
		LET vFechaEnvio = '';
		LET vNumGuia = '';
		LET vNumSolicitud = '';
		LET vNumCliente = '';
		LET vTotal = 0;
		
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret, vFechaEnvio, vNumGuia, vNumSolicitud, vNumCliente, vTotal;
			END IF;
		END EXCEPTION;
		
		IF (pFechaIni <> '' and pFechaIni IS NOT NULL) THEN
			IF (pFechaFin <> ''and pFechaFin IS NOT NULL) THEN
				
				FOREACH 
					SELECT SKIP pRegistros FIRST 10 f_envio::date as f_envio, num_guia, solicitud, numcte 
					INTO vFechaEnvio, vNumGuia, vNumSolicitud, vNumCliente
					FROM bdibpi:tkn_envios 
					WHERE date(f_envio) BETWEEN pFechaIni::date and pFechaFin::date
					
					LET vTotal = vTotal + 1;
					
					LET vTotal = vTotal::char(5);
					
					RETURN cod_ret, vFechaEnvio, NVL(vNumGuia,''), vNumSolicitud, vNumCliente, vTotal WITH RESUME;
					
				END FOREACH;	
			
				IF (vNumSolicitud = '') THEN 
					LET cod_ret = "00001";
					RETURN cod_ret, vFechaEnvio, NVL(vNumGuia,''), vNumSolicitud, vNumCliente, vTotal;
				END IF;
			
			END IF;
		ELSE 
			LET cod_ret = "00013";
			RETURN cod_ret, vFechaEnvio, vNumGuia, vNumSolicitud, vNumCliente, vTotal;
		END IF;
	
	END;
END PROCEDURE;