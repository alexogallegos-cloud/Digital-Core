CREATE PROCEDURE "informix".sp_obt_reporte_manifiesto_pm(pFechaIni char(10),pFechaFin char(10), pRegistros smallint)
	returning char(5), char(30), char(10), char(9), char(60), char(4), char(150);

---------------------------------------------------------------------------------------------
--Realizó: Roberto Castro
--Actividad: Obtiene los datos para generar el reporte de manifiesto en persona morales.
--Fecha: 25-05-2015
--Solilcitó: Gabriela Aguilar (BanCoppel)
---------------------------------------------------------------------------------------------
	DEFINE cCod_ret char(5);
	DEFINE iSql_err integer;

	DEFINE vNumGuia   		char(30);
	DEFINE vCodRast   		char(10);
	DEFINE vDestinatario	char(9);
	DEFINE vRazonSocial		char(60);
	DEFINE vDestino			char(4);
	DEFINE vRefToken		char(10);
	DEFINE vRefTokenAux		char(150);
	DEFINE vSolicTkn		char(10);
		
	LET cCod_ret		= '00000';
	LET vNumGuia		= '';
	LET vCodRast		= '';
	LET vDestinatario	='';
	LET vRazonSocial	='';
	LET vDestino		='';
	LET vRefToken		='';
	LET vRefTokenAux	='';
	LET vSolicTkn		='';
	
	--SET DEBUG FILE TO '/home/sysifx/roberto/admToken/sp_obt_reporte_manifiesto_pm.out';
	--TRACE ON ;	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				let cCod_ret = iSql_err;
				RETURN cCod_ret, vNumGuia, vCodRast, vDestinatario, vRazonSocial, vDestino, vRefTokenAux;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		IF NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pRegistros,'')= '' THEN
			LET cCod_ret = '00002';
			LET vNumGuia = 'Faltan Parametros';
			RETURN cCod_ret, vNumGuia, vCodRast, vDestinatario, vRazonSocial, vDestino, vRefTokenAux;
		ELSE
			FOREACH
				SELECT SKIP pRegistros FIRST 40 benv.num_guia, benv.cod_rastreo, bsol.numcte, scte.razon_social, benv.estado, bsol.solicitud
				INTO vNumGuia, vCodRast, vDestinatario, vRazonSocial, vDestino, vSolicTkn
				FROM bdibei:"informix".bei_envios benv, bdibei:"informix".bei_solicitudtoken bsol, bdinteg:"informix".si_cliente scte 
				WHERE DATE(bsol.f_atencion) BETWEEN pFechaIni::DATE AND pFechaFin::DATE 
				AND bsol.numcte = scte.numcte AND bsol.solicitud = benv.solicitud AND bsol.id_status = '120'
				FOREACH
					SELECT ns_token INTO vRefToken
					FROM bdibei:"informix".bei_tokensolicitud
					WHERE solicitud = vSolicTkn
					LET vRefTokenAux = trim(vRefTokenAux)||'|'||trim(vRefToken);
				END FOREACH;
				LET vRefTokenAux = SUBSTR(vRefTokenAux,2);
				RETURN cCod_ret, vNumGuia, vCodRast, vDestinatario, vRazonSocial, vDestino, vRefTokenAux WITH RESUME;
				LET vRefTokenAux ='';
			END FOREACH;
			IF NVL(vRefToken,'')='' THEN
					LET cCod_ret = '00001';
					LET vNumGuia = 'No existe informacion';
					RETURN cCod_ret, vNumGuia, vCodRast, vDestinatario, vRazonSocial, vDestino, vRefToken;
			END IF;		  
		END IF;
	END;
END PROCEDURE;