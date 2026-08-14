CREATE PROCEDURE "informix".sp_obtenerreportestatus (pEstatus char(30), pFechaIni char(10), pFechaFin char(10), pRegistros int)
				 returning char(5) as CodRet, char(3) as Estatus, char(10) as FechaSolicitud, char(4) as Sucursal, char(10) as NumToken,
						   char(9) as Numcliente, char(10) as Solicitud, char(3) as Tipo, char(8) as Solicita, char(8) as Atiende, 
						   char(200) as Comentarios , char(5) as Total
	
   --Elaboró: Nubia Janeth Montoya Medina
   --Actividad: Genera Reporte de Guia por estatus
   --Solicito: Mauricio León
   --Fecha: 06-01-2010
   
    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vEstatus char(3);
	DEFINE vFechaSolicitud char(10);
	DEFINE vSucursal char(4);
	DEFINE vToken char(10);
	DEFINE vCliente char(9);
	DEFINE vSolicitud char(10);
	DEFINE vTipo char(3);
	DEFINE vSolicita char(8);
	DEFINE vAtiende char(8);
	DEFINE vComentarios char(200);
	DEFINE vTotal integer;
	
			
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vEstatus = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vSucursal = '';
	LET vToken = '';
	LET vCliente = '';
	LET vSolicitud = '';
	LET vTipo = '';
	LET vSolicita = '';
	LET vAtiende = '';
	LET vComentarios = '';
	LET vTotal = 0;
	

	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vEstatus, vFechaSolicitud, vSucursal, vToken, vCliente, vSolicitud, vTipo, vSolicita, vAtiende, vComentarios, vTotal;
		  END IF ;
		END EXCEPTION ;
		
		IF (pEstatus IS NOT NULL AND pEstatus <> '') THEN
			
			IF EXISTS (SELECT id_status FROM bdibpi:tkn_envios e WHERE id_status = pEstatus) THEN
			
				FOREACH
					SELECT SKIP pRegistros FIRST 10 e.id_status, date(s.f_solicitud), s.sucursal, s.ns_token, e.numcte, s.solicitud, s.tipo, s.usr_solicita, s.usr_atiende, e.comentarios
					INTO vEstatus, vFechaSolicitud, vSucursal, vToken, vCliente, vSolicitud, vTipo, vSolicita, vAtiende, vComentarios
					FROM bdibpi:bpi_tokensolicitud s
					INNER JOIN bdibpi:tkn_envios e ON e.solicitud = s.solicitud and e.id_status = pEstatus and date(e.f_envio) between pFechaIni::date and pFechaFin::date

					LET vTotal = vTotal + 1;
					
					LET vTotal = vTotal::char(5);
					
					RETURN cod_ret, vEstatus, vFechaSolicitud, vSucursal, NVL(vToken,''), NVL(vCliente,''), vSolicitud, NVL(vTipo,''), NVL(vSolicita,''), NVL(vAtiende,''), NVL(vComentarios,''), vTotal WITH RESUME;
					
				END FOREACH;
					
				IF (vEstatus = '') THEN
					LET cod_ret = "00001";
					RETURN cod_ret, vEstatus, vFechaSolicitud, vSucursal, NVL(vToken,''), NVL(vCliente,''), vSolicitud, NVL(vTipo,''), NVL(vSolicita,''), NVL(vAtiende,''), NVL(vComentarios,''), vTotal;
				END IF;
			
			ELSE 
				LET cod_ret = "00009";
				RETURN cod_ret, vEstatus, vFechaSolicitud, vSucursal, NVL(vToken,''), NVL(vCliente,''), vSolicitud, NVL(vTipo,''), NVL(vSolicita,''), NVL(vAtiende,''), NVL(vComentarios,''), vTotal;
			END IF;
			
		ELSE 
			LET cod_ret = '00010'; 
			RETURN cod_ret, vEstatus, vFechaSolicitud, vSucursal, NVL(vToken,''), NVL(vCliente,''), vSolicitud, NVL(vTipo,''), NVL(vSolicita,''), NVL(vAtiende,''), NVL(vComentarios,''), vTotal;
		END IF;
	
	END;
	
END PROCEDURE;