CREATE PROCEDURE "informix".sp_obtenertiposolicitud (pTipo char(2), pFechaIni char(10), pFechaFin char(10), pRegistros int)
				 returning char(5) as codigoRetorno, char(3) as Tipo, char(10) as Solicitud, char(10) as FechaSolicitud, char(4) as Sucursal, char(10) as NumToken,
						   char(9) as NumCliente,  char(3) as Status, char(8) as Solicita, char(8) as PerAtiende, char(200) as Comentarios, char(16) as Folio,
						   char(5) as Total
	
   --Elaboró: Nubia Janeth Montoya Medina
   --Actividad: Genera Reporte de Solicitud por Tipo
   --Solicito: Mauricio León
   --Fecha: 06-01-2010
   
   --Modificó: Walber Castro
   --Actividad: Se quito la validación sin sentido del tipo
   --Solicitó: Diana Castellanos
   --Fecha: 19-08-2011
   
    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vSucursal char(4);
	DEFINE vFechaSolicitud char(10);
	DEFINE vToken char(10);
	DEFINE vCliente char(9);
	DEFINE vEstatus char(3); -- smallint
	DEFINE vSolicitud char(10); 
	DEFINE vTipo char(3); -- smallint
	DEFINE vSolicita char(8);
	DEFINE vAtiende char(8);
	DEFINE vComentarios char(200);
	DEFINE vTotal integer;
	DEFINE vFolio char(16);
		
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vSucursal = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vToken = '';
	LET vCliente = '';
	LET vEstatus = '';
	LET vSolicitud = '';
	LET vTipo = '';
	LET vSolicita = '';
	LET vAtiende = '';
	LET vComentarios = '';
	LET vTotal = '';
	LET vFolio = 0;
	
	--SET DEBUG FILE TO "/tmp/nubia/nubia2.out";
    --TRACE ON;
	
	SET LOCK MODE TO WAIT 10;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vTipo, vSolicitud, vFechaSolicitud, vSucursal, vToken, vCliente, vEstatus, vSolicita, vAtiende, vComentarios, vFolio, vTotal;
		  END IF ;
		END EXCEPTION ;
		
		IF (pTipo IS NOT NULL AND pTipo <> '') THEN			

			IF EXISTS (SELECT sucursal FROM bdibpi:'informix'.bpi_tokensolicitud WHERE tipo = pTipo and date(f_solicitud) between pFechaIni::date and pFechaFin::date) THEN
				FOREACH
					SELECT SKIP pRegistros FIRST 10 tipo, solicitud, date(f_solicitud)::char(10) as f_solicitud, sucursal, ns_token, numcte, id_status, usr_solicita, usr_atiende, comentarios, folio_suc
					INTO vTipo, vSolicitud, vFechaSolicitud, vSucursal, vToken, vCliente, vEstatus, vSolicita, vAtiende, vComentarios, vFolio
					FROM bdibpi:'informix'.bpi_tokensolicitud
					WHERE tipo = pTipo and date(f_solicitud) between pFechaIni::date and pFechaFin::date
						
					LET vTotal = vTotal + 1;
						
					LET vTotal = vTotal::char(5);
						
					RETURN cod_ret, vTipo, vSolicitud, vFechaSolicitud, vSucursal, NVL(vToken,''), vCliente, vEstatus, NVL(vSolicita,''), NVL(vAtiende,''), NVL(vComentarios,''), vFolio, vTotal WITH RESUME;
					
				END FOREACH;
				
				IF (vTipo = '') THEN
					LET cod_ret = '00001';
					RETURN cod_ret,vTipo, vSolicitud, vFechaSolicitud, vSucursal, vToken, vCliente, vEstatus, vSolicita, vAtiende, vComentarios, vFolio, vTotal;
				END IF;
			ELSE 
				LET cod_ret = '00011';
				RETURN cod_ret,vTipo, vSolicitud, vFechaSolicitud, vSucursal, vToken, vCliente, vEstatus, vSolicita, vAtiende, vComentarios, vFolio, vTotal;
			END IF;
			
		ELSE 
			LET cod_ret = '00014'; 
			RETURN cod_ret,vTipo, vSolicitud, vFechaSolicitud, vSucursal, vToken, vCliente, vEstatus, vSolicita, vAtiende, vComentarios, vFolio, vTotal;
		END IF;
	
	END;
	
END PROCEDURE;