CREATE PROCEDURE "informix".sp_bei_obtenerreportcodrast(pCodRast char(10), pRegistros int)
				 returning char(5) as CodRet, char(10) as CodRast, char(30) as NumGuia, char(10) as FechaSolicitud, 
				 char(10) as Solicitud, char(9) as Numcliente, char(4) as Sucursal, char(3) as NumEnvio, char(10) as FechaRegistro, char(3) as Estatus, char(8) as Envio;

    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vCodRast char(10);
	DEFINE vNumGuia char(30);
	DEFINE vFechaSolicitud char(10);
	DEFINE vSolicitud char(10);
	DEFINE vCliente char(9);
	DEFINE vSucursal char(4);
	DEFINE vNumEnvio char(3);
	DEFINE vFechaRegistro char(10);
	DEFINE vEstatus char(3);
	DEFINE vEnvio char(8);
			
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vCodRast = '';
	LET vNumGuia = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vSolicitud = '';
	LET vCliente = '';
	LET vSucursal = '';
	LET vNumEnvio = '';
	LET vFechaRegistro = '01-01-1900';
	LET vEstatus = '';
	LET vEnvio = '';

	--SET DEBUG FILE TO 'sp_bei_obtenerreportguia/sp_bei_obtenerreportcodrast.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, NVL(vCodRast,''), NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pCodRast IS NOT NULL AND pCodRast <> '') THEN
				FOREACH
					SELECT SKIP pRegistros FIRST 10 DISTINCT e.cod_rastreo, e.num_guia, date(s.f_solicitud) as f_solicitud, s.solicitud, s.numcte, s.sucursal, e.num_envio, date(e.f_registro) as f_registro, e.id_status, s.usr_atiende
					INTO vCodRast, vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vEnvio
					FROM "informix".bei_envios e, "informix".bei_solicitudtoken s
					WHERE s.solicitud = e.solicitud 
					AND s.numcte = e.numcte
					AND s.id_status = e.id_status
					AND e.cod_rastreo = pCodRast
					
					RETURN cod_ret, NVL(vCodRast,''), NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'') WITH RESUME;
				
				END FOREACH;
				
				IF (vCodRast = '') THEN
					LET cod_ret = "00004";
				END IF;
		ELSE 
			LET cod_ret = '00004'; 
		END IF;
		
		IF (cod_ret <> '00000') THEN
			RETURN cod_ret, NVL(vCodRast,''), NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		END IF;
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei',
'MODIFICO: Paul Alonzo Quintero Ramirez',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro VÃ¡zquez FernÃ¡ndez',
'DESCRIPCION: Se modifica parametro de retorno NumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_bei_obtenerreportguia (pCliente char(9), pRegistros int)
				 returning char(5) as CodRet, char(4) as sucursal, char(10) as FechaSolicitud, char(10) as Solicitud, char(9) as Cliente,
				 char(30) as NumGuia, char(3) as NumEnvio, char(10) as FechaEnvio, char(3) as Estatus, char(8) as PersonaEnvio;

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
	
	 --SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_bei_obtenerreportguia.out';
	 --TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,'01-01-1900'), NVL(vSolicitud,''), NVL(vCliente,'' ),NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,'');
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pCliente IS NOT NULL AND pCliente <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 DISTINCT s.sucursal, date(s.f_solicitud)::char(10), s.solicitud, e.numcte, e.num_guia, e.num_envio, date(e.f_envio)::char(10), e.id_status, s.usr_atiende
				INTO vSucursal, vFechaSolicitud, vSolicitud, vCliente, vNumGuia, vNumEnvio, vFechaEnvio, vEstatusEnvio, vPerEnvio
				FROM "informix".bei_envios e
				INNER JOIN "informix".bei_solicitudtoken s ON s.solicitud = e.solicitud and e.numcte = pCliente
				WHERE e.id_status = s.id_status
				
				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,'01-01-1900'), NVL(vSolicitud,''), NVL(vCliente,'' ),NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,'') WITH RESUME;
			
			END FOREACH;
			
			IF (vCliente = '') THEN
					LET cod_ret = '00006';
			END IF;
		ELSE 
			LET cod_ret = '00007'; 
			
		END IF;
		
		IF (cod_ret <> '00000') THEN
		
			RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,'01-01-1900'), NVL(vSolicitud,''), NVL(vCliente,'' ),NVL(vNumGuia,''), NVL(vNumEnvio,''), NVL(vFechaEnvio,''), NVL(vEstatusEnvio,''), NVL(vPerEnvio,'');
	
		END IF;
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei',
'MODIFICO: Paul Alonzo Quintero Ramirez',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro VÃ¡zquez FernÃ¡ndez',
'DESCRIPCION: Se modifica parametro de retorno NumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_bei_obtenerreportinventario(pToken CHAR(9), pEstatus CHAR(3), pRegistros INT)
				 returning CHAR(5) AS CodRet, CHAR(9) AS Token, CHAR(3) AS Estatus, CHAR(10) AS FechaCambio, CHAR(9) AS Cliente, CHAR(10) as Solicitud,
				 CHAR(30) AS NumGuia, CHAR(10) AS FechaIngreso;

	-- DECLARA
	DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;
	DEFINE vToken CHAR(9);
	DEFINE vEstatus CHAR(3);
	DEFINE vFechaCambio CHAR(10);
	DEFINE vCliente CHAR(9);
	DEFINE vSolicitud CHAR(10);
	DEFINE vNumGuia CHAR(30);
	DEFINE vFechaIngreso CHAR(10);
	DEFINE vNs_token  CHAR(9);
	DEFINE vId_status CHAR(3);
	
	-- INICIALIZA
	LET cod_ret = '00000';
	LET vToken = '';
	LET vFechaCambio = DATE (1);
	LET vEstatus = '';
	LET vFechaIngreso = DATE (1);
	LET vCliente = '';
	LET vSolicitud = '';
	LET vNumGuia = '';
	LET vNs_token = '';
	LET vId_status = '';
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_bei_obtenerreportinventario.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret,NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,''), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'');
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Busqueda realizada por  numero de serie del token
		IF (pToken IS NOT NULL AND pToken <> '') THEN
			
			--IF EXISTS (SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pToken) THEN
			
			SELECT ns_token into vNs_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pToken;
			
				IF (vNs_token <> '') THEN
					SELECT DISTINCT ns.ns_token, ns.id_status, DATE(ns.f_status):: CHAR(10) AS f_status, DATE(st.f_cambio_status):: CHAR(10) AS f_cambio_status
					INTO vToken, vEstatus, vFechaIngreso, vFechaCambio
					FROM bdibpi:"informix".tkn_nseries ns,	bdibpi:"informix".tkn_status_token st 
					WHERE ns.ns_token = st.ns_token	
					AND ns.ns_token = pToken 
					AND ns.id_status = st.actual
					AND st.actual = (SELECT MAX (actual) FROM bdibpi:"informix".tkn_status_token WHERE ns_token = pToken);

					SELECT DISTINCT s.numcte, s.solicitud
					INTO vCliente, vSolicitud			
					FROM "informix".bei_solicitudtoken s, "informix".bei_tokensolicitud ts 
					WHERE ts.ns_token = pToken 
					AND ts.numcte = s.numcte
					AND s.solicitud = ts.solicitud;
					
					SELECT DISTINCT e.num_guia
					INTO vNumGuia
					FROM "informix".bei_envios e, "informix".bei_tokensolicitud ts 
					WHERE e.solicitud = ts.solicitud 
					AND e.numcte = ts.numcte
					AND ts.ns_token = pToken;

				IF ((vToken = '' OR vToken IS NULL) AND (vCliente = '' OR vCliente IS NULL))THEN
					LET cod_ret = '00001';
				END IF;
				
				RETURN cod_ret, NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900');
				
			ELSE
				LET cod_ret = '00002';
				RETURN cod_ret,NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900');
			END IF;
			
			
		--Busqueda realizada por estatus
		ELIF NVL(pEstatus,'') <> '' THEN
		
			--IF EXISTS (SELECT id_status FROM bdibpi:"informix".tkn_nseries WHERE id_status = pEstatus) THEN
	
			SELECT count(*) into vId_status FROM bdibpi:"informix".tkn_nseries WHERE id_status = pEstatus;	
			IF nvl(vId_status,0) > 0 THEN	
			
				SET ISOLATION DIRTY READ; 
				
				FOREACH  WITH HOLD
					SELECT SKIP pRegistros FIRST 10 DISTINCT ns.id_status, ns.ns_token, DATE(ns.f_status):: CHAR(10) AS f_status, DATE(st.f_cambio_status):: CHAR(10) AS f_cambio_status
					INTO vEstatus, vToken, vFechaIngreso, vFechaCambio	
					FROM bdibpi:"informix".tkn_nseries ns, bdibpi:"informix".tkn_status_token st
					WHERE st.ns_token = ns.ns_token  
					AND ns.id_status = pEstatus
					AND ns.id_status = st.actual
					GROUP BY ns.ns_token, ns.id_status,ns.f_status,st.f_cambio_status
					ORDER BY ns.ns_token
					FOREACH
						SELECT DISTINCT s.numcte, s.solicitud
						INTO vCliente, vSolicitud			
						FROM "informix".bei_solicitudtoken s, 
							 "informix".bei_tokensolicitud ts,
							 bdibpi: tkn_nseries c
						WHERE s.solicitud = ts.solicitud 
						AND s.numcte = ts.numcte
						AND s.id_status = pEstatus
						AND s.id_status = ts.id_status
						AND ts.id_status = c.id_status
						AND ts.ns_token = c.ns_token
						FOREACH
							SELECT NVL( e.num_guia,'')
							INTO vNumGuia
							FROM "informix".bei_envios e, 
								 bdibpi:"informix".tkn_nseries ns,
								 "informix".bei_tokensolicitud bei
							WHERE e.numcte = bei.numcte
							and e.solicitud = bei.solicitud
							AND e.id_status = pEstatus
							AND e.id_status = bei.id_status
							AND e.id_status = ns.id_status
							and bei.ns_token = ns.ns_token
							
						END FOREACH
							
					END FOREACH
					
					RETURN cod_ret, NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900') WITH RESUME;
					
				END FOREACH;
			
				
				IF (vEstatus = '' OR vEstatus IS NULL) THEN
					LET cod_ret = '00003';
					RETURN cod_ret,NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900');
				END IF;
				
			ELSE 
				LET cod_ret = '00004';
				RETURN cod_ret,NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900');
			END IF;
		
		ELSE 
			LET cod_ret = '00005';
			RETURN cod_ret,NVL(vToken,''), NVL(vEstatus,''), NVL(vFechaCambio,'01-01-1900'), NVL(vCliente,''), NVL(vSolicitud,''), NVL(vNumGuia, ''), NVL(vFechaIngreso,'01-01-1900');
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei',
'MODIFICO: Paul Alonzo Quintero Ramirez',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro VÃ¡zquez FernÃ¡ndez',
'DESCRIPCION: Se modifica parametro de retorno NumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_bei_obtenerreportnumguia(pNumGuia char(30), pRegistros int)
				 returning char(5) as CodRet, char(30) as NumGuia, char(10) as FechaSolicitud, char(10) as Solicitud, char(9) as Numcliente,
				 char(4) as Sucursal, char(3) as NumEnvio, char(10) as FechaRegistro, char(3) as Estatus, char(8) as Envio;

   
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
	DEFINE vEnvio char(8);
			
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
	LET vEnvio = '';
	
--	SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_bei_obtenerreportnumguia.out";
--	TRACE ON;

	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pNumGuia IS NOT NULL AND pNumGuia <> '') THEN
				FOREACH
					SELECT SKIP pRegistros FIRST 10 DISTINCT e.num_guia, date(s.f_solicitud) as f_solicitud, s.solicitud, e.numcte, s.sucursal, e.num_envio, date(e.f_registro) as f_registro, e.id_status, s.usr_atiende
					INTO vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vEnvio
					FROM "informix".bei_envios e, "informix".bei_solicitudtoken s 
					WHERE s.solicitud = e.solicitud 
					AND s.numcte = e.numcte
					AND e.num_guia = pNumGuia
					
					
					RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'') WITH RESUME;
				
				END FOREACH;
				
				IF (vNumGuia = '') THEN
					LET cod_ret = "00011";
				END IF;
		ELSE 
			LET cod_ret = '00011'; 
		END IF;
		
		IF (cod_ret <> '00000') THEN
			RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		END IF;
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei',
'MODIFICO: Paul Alonzo Quintero Ramirez',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro VÃ¡zquez FernÃ¡ndez',
'DESCRIPCION: Se modifica parametro entrada y de retorno NumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_depura_bitacora_bei()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE Vid_oper		CHAR(4);
DEFINE Vid_usuario  INTEGER;
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
		

	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_depura_bitacora_bei.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	
	LET vcontador = -1;
	LET vcuantos = 0;
	LET vcomienza   = -1;	
	LET vregistros = 1000;
	
	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from bdibpi:"informix".bpi_param
	where id_param = '20';

	select date(fecha_hoy - 1 units day) into dFecha 
	from bdicheq:"informix".sc_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdibei:"informix".temp_bei_bitacora_depurar;

	if iCont > 0 and cValor = '1' then

		update bdibpi:"informix".bpi_param set valor = '2'
		where id_param = '20';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select id_cat_oper 
		into Vid_oper  
		from bdibei:"informix".temp_bei_bitacora_depurar

		FOREACH WITH HOLD

			select distinct(id_usuario)
			into Vid_usuario
			from bdibei:"informix".bei_bitacora
			where id_operacion = Vid_oper 
			 AND EXTEND(fecha_oper,YEAR to day) <= dFecha
	
				IF vcomienza = -1 THEN
							BEGIN WORK;
							LET vcontador = 1;
							LET vcomienza = 0;
				END IF;		
						
				DELETE FROM bdibei:"informix".bei_bitacora
				WHERE id_operacion = Vid_oper 
					and id_usuario = Vid_usuario
					and EXTEND(fecha_oper,YEAR to day) <= dFecha;
			
				IF (vcontador = vregistros) THEN
						COMMIT WORK;
						LET vcontador = 0;							
						LET vcomienza = -1;
				ELSE
						LET vcontador = vcontador + 1 ;						
				END IF;		
				
		END FOREACH;

	END FOREACH;

			IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		

	update bdibpi:"informix".bpi_param set valor = '0'
	where id_param = '20';

	delete bdibei:"informix".temp_bei_bitacora_depurar;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;