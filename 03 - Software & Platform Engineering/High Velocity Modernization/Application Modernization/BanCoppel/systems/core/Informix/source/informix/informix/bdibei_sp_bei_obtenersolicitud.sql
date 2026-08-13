CREATE PROCEDURE "informix".sp_bei_obtenersolicitud (pSolicitud char(10), pToken char(10), pCliente char(9), pRegistros int)
				 returning char(5) as codRet, char(4) as Sucursal, char(10) as FechaSolicitud, char(10) as Solicitud, char(10) as Token, char(9) as Cliente, char(3) as Estatus, char(8) as solicito, char(8) as Envio;


    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vSucursal char(4);
	DEFINE vFechaSolicitud char(10);
	DEFINE vToken char(10);
	DEFINE vCliente char(9);
	DEFINE vEstatus char(3);
	DEFINE vSolicitud char(10);
	DEFINE vSolicito char(8);
	DEFINE vEnvio char(8);

	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vSucursal = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vToken = '';
	LET vCliente = '';
	LET vEstatus = '';
	LET vSolicitud = '';
	LET vSolicito = '';
	LET vEnvio = '';
	
	--SET DEBUG FILE TO "/home/sysifx/ilse/admToken/sp_bei_obtenerreportinventario.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vSolicito,''), NVL(vEnvio,'');
		  END IF ;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 10;
		SET ISOLATION TO DIRTY READ;

		IF (pSolicitud IS NOT NULL AND pSolicitud <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 a.sucursal, date(a.f_solicitud)::char(10) as f_solicitud, a.solicitud, c.ns_token, a.numcte, a.id_status, a.usr_solicita, a.usr_atiende
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vSolicito, vEnvio
				FROM "informix".bei_solicitudtoken a left join "informix".bei_tokensolicitud c 
                on a.solicitud = c.solicitud and a.numcte=c.numcte
				WHERE a.solicitud = pSolicitud
				

				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vSolicito,''), NVL(vEnvio,'') WITH RESUME;

			END FOREACH;

			IF (vSolicitud = '') THEN
					LET cod_ret = "00003";
			END IF;
			
		ELIF (pToken IS NOT NULL AND pToken <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 b.sucursal, date(b.f_solicitud)::char(10) as f_solicitud, b.solicitud, c.ns_token, b.numcte, b.id_status, b.usr_solicita, b.usr_atiende
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vSolicito, vEnvio
				FROM "informix".bei_solicitudtoken b left join "informix".bei_tokensolicitud c
				on b.solicitud = c.solicitud and b.numcte = c.numcte
				WHERE c.ns_token = pToken

				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vSolicito,''), NVL(vEnvio,'') WITH RESUME;

			END FOREACH;

			IF (vToken = '') THEN
				LET cod_ret = "00004";
			END IF;

		ELIF (pCliente IS NOT NULL AND pCliente <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 b.sucursal, date(b.f_solicitud)::char(10) as f_solicitud, b.solicitud, c.ns_token, b.numcte, b.id_status, b.usr_solicita, b.usr_atiende
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vSolicito, vEnvio
				FROM "informix".bei_solicitudtoken b left join "informix".bei_tokensolicitud c
				on b.numcte = c.numcte and b.solicitud = c.solicitud
				WHERE b.numcte = pCliente
				 

				RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vSolicito,''), NVL(vEnvio,'') WITH RESUME;

			END FOREACH;

			IF (vCliente = '') THEN
					LET cod_ret = "00008";
			END IF;
			
		ELSE
			LET cod_ret = '00009';	
		END IF;
		
		IF (cod_ret <> '00000') THEN
			RETURN cod_ret, NVL(vSucursal,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vSolicito,''), NVL(vEnvio,'');
		END IF;
	END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_elimina_tokenasociados_bei(pNseries char(90), pNumSolicitud char(10), pNumCliente char(9))
RETURNING char(5);   
  --*************************************************************
	--Objetivo:Elimina los tokens asociados al cliente.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--*************************************************************   
	
   -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer;
	DEFINE vNstoken  char(9);
	DEFINE vLength    smallint;
	DEFINE vContador smallint;
	DEFINE vVar	smallint;
	DEFINE i INTEGER;
	DEFINE vTrama char(90);
	
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vNsToken = '';
	LET vLength = 0;
	LET vContador=0;
	LET vVar=0;
	LET i=1;
	LET vLength = LENGTH(pNseries);
	LET vContador = vLength/9;
	LET vTrama = pNseries;

	--SET DEBUG FILE TO '/tmp/sp_elimina_tokenasociados_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pNseries <> "" AND pNumSolicitud <> "" AND pNumCliente <> ""  THEN  
			WHILE(vVar < vContador)
				
				LET vNsToken = SUBSTRING(TRIM(vTrama) FROM i FOR 9);
				LET i = i + 9;
				LET vVar= vVAr + 1;
				DELETE "informix".bei_tokensolicitud WHERE ns_token=vNsToken AND solicitud=pNumSolicitud AND numcte=pNumCliente;
			END WHILE;
		ELSE
			LET cod_ret='00001';
		END IF;
		RETURN cod_ret;
	END;	
END PROCEDURE;