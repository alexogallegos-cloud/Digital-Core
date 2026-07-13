CREATE PROCEDURE "informix".sp_obt_solicitud_guia(pSolicitud varchar(10),pNumcte varchar(9), pFecha char(20), pRegistros smallint)
	returning char(5), char(5), char(10), char(9), char(10), char(10), char(30), char(30);

---------------------------------------------------------------------------------------------
--Modifico: Ilse Jazmín Gómez Pérez
--Actividad: Obtiene los datos para modulo de reimpresión de guía.
--Fecha: 03-09-2014
--Solilcitó: José de Jesus Nevarez Peinado
---------------------------------------------------------------------------------------------

	DEFINE cod_ret char(5);
	DEFINE sql_err integer;
	
	DEFINE vSolicitud char(10);
	DEFINE vCliente   char(9);
	DEFINE vToken     char(10);
	DEFINE vCodRast   char(10);
	DEFINE vFechaAten char(30);
	DEFINE vNumGuia   char(30);
	DEFINE vNumReg    char(5);
	
	LET cod_ret       = '00000';
	LET vSolicitud    = '';
	LET vCliente      = '';
	LET vToken        = '';
	LET vCodRast      = '';
	LET vFechaAten    = '01-01-1900';
	LET vNumGuia      = '';
	LET vNumReg       = '';
	
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vNumReg, vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia;
			END IF ;
		END EXCEPTION ;
	   
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO '/home/sysifx/ilse/1482-AdmToken/sp_obt_solicitud_guia.out';
		--TRACE ON ;
		
		
		IF ( pFecha <> '' AND pFecha IS NOT NULL ) THEN
		
				SELECT count(*)
				INTO vNumReg
				FROM bdibpi:"informix".bpi_tokensolicitud s, bdibpi:"informix".tkn_envios e
				WHERE s.solicitud MATCHES ('*'|| pSolicitud)
				AND s.numcte MATCHES ('*'|| pNumcte)
				AND date(s.f_atencion) = pFecha::date
				AND s.solicitud = e.solicitud
				AND s.guia = 'T'
				AND s.id_status = '120';
		
			FOREACH
				
				SELECT SKIP pRegistros FIRST 10 s.solicitud, s.numcte, s.ns_token, e.cod_rastreo, s.f_atencion, e.num_guia
				INTO vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia
				FROM bdibpi:"informix".bpi_tokensolicitud s, bdibpi:"informix".tkn_envios e
				WHERE s.solicitud MATCHES ('*'|| pSolicitud)
				AND s.numcte MATCHES ('*'|| pNumcte)
				AND date(s.f_atencion) = pFecha::date
				AND s.solicitud = e.solicitud
				AND s.guia = 'T'
				AND s.id_status = '120'
				
				RETURN cod_ret, vNumReg, vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia  WITH RESUME;
				
			END FOREACH;
			
			IF(vSolicitud = '') THEN
				LET cod_ret = '00001';
				RETURN cod_ret, vNumReg, vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia;
			END IF;			
			
		ELSE
		
			SELECT count(*)
			INTO vNumReg
			FROM bdibpi:"informix".bpi_tokensolicitud s, bdibpi:"informix".tkn_envios e
			WHERE s.solicitud MATCHES ('*'|| pSolicitud)
			AND s.numcte MATCHES ('*'|| pNumcte)
			AND s.solicitud = e.solicitud
			AND s.guia = 'T'
			AND s.id_status = '120';
			
			FOREACH
				
				SELECT SKIP pRegistros FIRST 10 s.solicitud, s.numcte, s.ns_token, e.cod_rastreo, s.f_atencion, e.num_guia
				INTO vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia
				FROM bdibpi:"informix".bpi_tokensolicitud s, bdibpi:"informix".tkn_envios e
				WHERE s.solicitud MATCHES ('*'|| pSolicitud)
				AND s.numcte MATCHES ('*'|| pNumcte)
				AND s.solicitud = e.solicitud
				AND s.guia = 'T'
				AND s.id_status = '120'
				
				RETURN cod_ret, vNumReg, vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia  WITH RESUME;
				
			END FOREACH;	
			
			IF(vSolicitud = '') THEN
				LET cod_ret = '00001';		
				RETURN cod_ret, vNumReg, vSolicitud, vCliente, vToken, vCodRast, vFechaAten, vNumGuia;
			END IF;
			
		END IF;
			  
	END;

END PROCEDURE;