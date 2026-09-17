CREATE PROCEDURE "informix".sp_obtenerreportnumguia (pNumGuia char(30), pRegistros int)
				 returning char(5) as CodRet, char(30) as NumGuia, char(10) as FechaSolicitud, char(10) as Solicitud, char(9) as Numcliente,
				 char(4) as Sucursal, char(3) as NumEnvio, char(10) as FechaRegistro, char(3) as Estatus, char(8) as Atiende, char(200) as Comentarios

   --Elaboró: Nubia Janeth Montoya Medina
   --Actividad: Genera Reporte de Número de Guia 
   --Solicito: Mauricio León
   --Fecha: 06-01-2010
   
    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vNumGuia char(30);
	DEFINE vFechaSolicitud char(10);
	DEFINE vSolicitud char(10);
	DEFINE vCliente char(9);
	DEFINE vSucursal char(4);
	DEFINE vNumEnvio char(3);
	DEFINE vFechaRegistro char(10);
	DEFINE vEstatus char(3);
	DEFINE vAtiende char(8);
	DEFINE vComentarios char(200);
			
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vNumGuia = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vSolicitud = '';
	LET vCliente = '';
	LET vSucursal = '';
	LET vNumEnvio = '';
	LET vFechaRegistro = '01-01-1900';
	LET vEstatus = '';
	LET vAtiende = '';
	LET vComentarios = '';
	
	--SET DEBUG FILE TO "/tmp/nubia/nubia2.out";
    --TRACE ON;
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vAtiende, vComentarios;
		  END IF ;
		END EXCEPTION ;
		
		IF (pNumGuia IS NOT NULL AND pNumGuia <> '') THEN
				FOREACH
					SELECT SKIP pRegistros FIRST 10 g.num_guia, date(s.f_solicitud) as f_solicitud, s.solicitud, e.numcte, s.sucursal, e.num_envio, date(g.f_registro) as f_registro, e.id_status, s.usr_atiende, e.comentarios
					INTO vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vAtiende, vComentarios
					FROM bdibpi:tkn_guias g
					INNER JOIN bdibpi:tkn_envios e ON e.num_guia = g.num_guia 
					INNER JOIN bdibpi:bpi_tokensolicitud s ON s.solicitud = e.solicitud 
					WHERE g.num_guia = pNumGuia
					
					RETURN cod_ret, vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vAtiende,''), NVL(vComentarios,'') WITH RESUME;
				
				END FOREACH;
				
				IF (vNumGuia = '') THEN
					LET cod_ret = "00011";
					RETURN cod_ret,vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vAtiende, vComentarios;
				END IF;
		ELSE 
			LET cod_ret = '00011'; 
			RETURN cod_ret, vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vAtiende, vComentarios;
		END IF;
	
	END;
	
END PROCEDURE;