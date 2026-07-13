CREATE PROCEDURE "informix".sp_obt_reporte_manifiesto(pFechaIni char(10),pFechaFin char(10), pRegistros smallint)
	returning char(5), char(30), char(10), char(9), char(26), char(26), char(26), char(26), char(10);

---------------------------------------------------------------------------------------------
--Modifico: Ilse Jazmín Gómez Pérez
--Actividad: Obtiene los datos para generar el reporte de manifiesto.
--Fecha: 30-09-2014
--Solilcitó: José de Jesus Nevarez Peinado
---------------------------------------------------------------------------------------------
--Modifico: José de Jesus Nevarez Peinado
--Actividad: Se modifica consulta en sp para que tomen en cuenta la tabla tkn_envios en lugar de la tabla tkn_guias.
--Fecha: 07-11-2014
--Solilcitó: Gabriela Aguilar (BanCoppel)
---------------------------------------------------------------------------------------------

	DEFINE cod_ret char(5);
	DEFINE sql_err integer;
	
	DEFINE vCliente   char(9);
	DEFINE vToken     char(10);
	DEFINE vCodRast   char(10);
	DEFINE vNumGuia   char(30);
	DEFINE vNombre1   char(26);
	DEFINE vNombre2   char(26);
	DEFINE vApellM    char(26);
	DEFINE vApellP    char(26);
	
	LET cod_ret       = '00000';
	LET vCliente      = '';
	LET vToken        = '';
	LET vCodRast      = '';
	LET vNumGuia      = '';
	LET vNombre1       = '';
	LET vNombre2       = '';
	LET vApellM       = '';
	LET vApellP      = '';
	
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vNumGuia, vCodRast, vCliente, vNombre1,  vNombre2, vApellP, vApellM, vToken;
			END IF ;
		END EXCEPTION ;
	   
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO '/home/sysifx/ilse/1482-AdmToken/sp_obt_solicitud_guia.out';
		--TRACE ON ;
				
		FOREACH
		
			SELECT SKIP pRegistros FIRST 40 tkng.num_guia, tkng.cod_rastreo, tkns.numcte, scte.nombre1, scte.nombre2, scte.apell_paterno, scte.apell_materno, tkns.ns_token
			INTO vNumGuia, vCodRast, vCliente, vNombre1, vNombre2, vApellP, vApellM, vToken
			FROM bdinteg:"informix".si_cliente scte, bdibpi:"informix".bpi_tokensolicitud tkns, bdibpi:"informix".tkn_envios tkng
			WHERE date(tkns.f_atencion) BETWEEN pFechaIni::date AND pFechaFin::date
			AND tkns.numcte = scte.numcte
			AND tkns.solicitud = tkng.solicitud
			AND tkns.id_status = '120'
			
			RETURN cod_ret, vNumGuia, vCodRast, vCliente, vNombre1,  vNombre2, vApellP, vApellM, vToken WITH RESUME;
			
		END FOREACH;
		
		IF(vToken = '') THEN
				LET cod_ret = '00001';		
				RETURN cod_ret, vNumGuia, vCodRast, vCliente, vNombre1,  vNombre2, vApellP, vApellM, vToken;
		END IF;
		
				  
	END;

END PROCEDURE;