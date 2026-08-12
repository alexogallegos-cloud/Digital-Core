CREATE PROCEDURE "informix".sp_obtenerreportguia (pSucursal char(4), pNumEnvio char(3), pFechaEnvio char(10), pCliente char(9), pFechaIni char(10), pFechaFin char(10), pRegistros int)
				 returning char(5) as CodRet, char(4) as sucursal, char(10) as FechaSolicitud, char(10) as Solicitud, char(9) as Cliente,
				 char(30) as NumGuia, char(3) as NumEnvio, char(10) as FechaEnvio, char(3) as Estatus, char(8) as PersonaEnvio,
				 char(200) as Comentarios, char(5) as Total
	
   --**********************************************************************************************************************************
   --Elaboró: Nubia Janeth Montoya Medina
   --Actividad: Genera Reporte de Guias
   --Solicito: Mauricio León
   --Fecha: 08-01-2010
   --Modificó: Nubia Janeth Montoya Medina
   --Modificación: Se cambia la fecha contra la que se compará el rango de fechas por filtro de sucursal.
   --Fecha: 09-04-2010
   --**********************************************************************************************************************************
   
    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vSucursal char(4);
	DEFINE vFechaSolicitud char(10);
	DEFINE vSolicitud char(10);
	DEFINE vCliente char(9);
	DEFINE vNumGuia char(30);
	DEFINE vNumEnvio char(3);
	DEFINE vFechaEnvio char(10);
	DEFINE vEstatusEnvio char(3);
	DEFINE vPerEnvio char(8);
	DEFINE vComentarios char(200);
	DEFINE vTotal integer;
		
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vSucursal = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vSolicitud = '';
	LET vCliente = '';
	LET vNumGuia = '';
	LET vNumEnvio = '';
	LET vFechaEnvio = '';
	LET vEstatusEnvio = '';
	LET vPerEnvio = '';
	LET vComentarios = '';
	LET vTotal = 0;
	
	--SET DEBUG FILE TO "/tmp/nubia/nubia2.out";
    --TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
		  END IF ;
		END EXCEPTION ;
		
		IF (pSucursal IS NOT NULL AND pSucursal <> '') THEN
			
			IF EXISTS (SELECT sucursal FROM bdibpi:bpi_tokensolicitud WHERE sucursal = pSucursal) THEN
				
				FOREACH
					SELECT SKIP pRegistros FIRST 10 s.sucursal, date(s.f_solicitud)::char(10), s.solicitud, e.numcte, g.num_guia, e.num_envio, date(e.f_envio)::char(10), e.id_status, s.usr_atiende, e.comentarios
					INTO vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios
					FROM bdibpi:bpi_tokensolicitud s
					INNER JOIN bdibpi:tkn_envios e ON s.solicitud = e.solicitud 
					INNER JOIN bdibpi:tkn_guias g ON e.num_guia = g.num_guia and date(g.f_registro) BETWEEN pFechaIni::date and pFechaFin::date
					WHERE s.sucursal = pSucursal
					
					LET vTotal = vTotal + 1;
					
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), vEstatusEnvio, NVL(vPerEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;
				
				END FOREACH;
				
				IF (vSucursal = '') THEN
						LET cod_ret = "00001";
						RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
				END IF;
			ELSE 
				LET cod_ret = "00002";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
			END IF;
			
		ELIF (pNumEnvio IS NOT NULL AND pNumEnvio <> '') THEN
		
			IF EXISTS (SELECT num_envio FROM bdibpi:tkn_envios WHERE num_envio = pNumEnvio) THEN
				
				FOREACH
					SELECT SKIP pRegistros FIRST 10 s.sucursal, date(s.f_solicitud)::char(10), s.solicitud, e.numcte, g.num_guia, e.num_envio, date(e.f_envio)::char(10), e.id_status, s.usr_atiende, e.comentarios
					INTO vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios
					FROM bdibpi:tkn_guias g
					INNER JOIN bdibpi:tkn_envios e ON e.num_guia = g.num_guia 
					INNER JOIN bdibpi:bpi_tokensolicitud s ON s.solicitud = e.solicitud 
					WHERE e.num_envio = pNumEnvio and date(e.f_envio) BETWEEN pFechaIni::date and pFechaFin::date
					
					LET vTotal = vTotal + 1;
					
					LET vTotal = vTotal::char(5);
					
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;
				
				END FOREACH;
				
				IF (vNumEnvio = '') THEN
						LET cod_ret = "00001";
						RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
				END IF;
				
			ELSE 
				LET cod_ret = "00004";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
			END IF;
			
		ELIF (pFechaEnvio IS NOT NULL AND pFechaEnvio <> '') THEN
			
			FOREACH
				SELECT SKIP pRegistros FIRST 10 s.sucursal, date(s.f_solicitud)::char(10), s.solicitud, e.numcte, g.num_guia, e.num_envio, date(e.f_envio)::char(10), e.id_status, s.usr_atiende, e.comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios
				FROM bdibpi:tkn_guias g
				INNER JOIN bdibpi:tkn_envios e ON e.num_guia = g.num_guia and date(e.f_envio) between pFechaIni::date and pFechaFin::date
				INNER JOIN bdibpi:bpi_tokensolicitud s ON s.solicitud = e.solicitud

				LET vTotal = vTotal + 1;
				
				LET vTotal = vTotal::char(5);

				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;
			
			END FOREACH;
			
			IF (vSucursal = '') THEN
					LET cod_ret = "00001";
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
			END IF;
			
		ELIF (pCliente IS NOT NULL AND pCliente <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 s.sucursal, date(s.f_solicitud)::char(10), s.solicitud, e.numcte, g.num_guia, e.num_envio, date(e.f_envio)::char(10), e.id_status, s.usr_atiende, e.comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios
				FROM bdibpi:tkn_guias g
				INNER JOIN bdibpi:tkn_envios e ON e.num_guia = g.num_guia 
				INNER JOIN bdibpi:bpi_tokensolicitud s ON s.solicitud = e.solicitud and s.numcte = pCliente
				
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;
			
			END FOREACH;
			
			IF (vCliente = '') THEN
					LET cod_ret = "00006";
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
			END IF;
		ELSE 
			LET cod_ret = '00007'; 
			RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio, vComentarios, vTotal;
		END IF;
	
	END;
	
END PROCEDURE;