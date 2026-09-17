CREATE PROCEDURE "informix".sp_carga_pre_aprobados()
	RETURNING CHAR(5)   AS codRet,
              CHAR(500) AS mensaje,
              CHAR(2)   AS idProceso;


	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
    DEFINE vMensaje CHAR (500);
    DEFINE vSql CHAR(500);
    DEFINE vIdProceso CHAR(2);
    DEFINE vConsecutivoCte INTEGER;
    DEFINE vtransaccion SMALLINT;
    DEFINE cRutaCarga CHAR(500);
    DEFINE cRutaDescarga CHAR(500);
    DEFINE cArchivoRespaldo CHAR(500);
    DEFINE cArchivoPreAp CHAR(500);
    DEFINE cRutaIfx CHAR(500);
    --DEFINE vCuentaTrx INTEGER;
	DEFINE vCuentaTrx CHAR(10);
	DEFINE cProductosOC CHAR(80);

	--SET DEBUG FILE TO "/informix/mc/Fernandorb/carga_unificada.out";
	--TRACE ON;

    LET iSqlErr ='0';
    LET vCodRet ='00000';
    LET vMensaje ='CARGA EXITOSA';
    LET vSql ='';
    LET vIdProceso ='00';
    LET vConsecutivoCte = 0;
    LET vtransaccion = 0;
    LET cRutaCarga = '';
    LET cRutaDescarga = '';
    LET cArchivoRespaldo = 'resp_migra_preaprob.unl';
    LET cArchivoPreAp = '';
    LET cRutaIfx = '';
    --LET vCuentaTrx = 0;
	LET vCuentaTrx = '';
	LET cProductosOC = '';

	SELECT TRIM(valor) INTO cRutaCarga    FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
	SELECT TRIM(valor) INTO cRutaIfx      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
    SELECT TRIM(valor) INTO cRutaDescarga FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 8;
    SELECT TRIM(valor) || LPAD(MONTH(TODAY),2,0) || '-' || SUBSTR(YEAR(TODAY),3,2)|| '.txt' INTO cArchivoPreAp
	                                      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 6;
	SELECT TRIM(valor) INTO cProductosOC  FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 16;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = '10000';
				LET vMensaje = 'ERROR AL CARGAR ARCHIVO: ' || iSqlErr;

				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
				END IF;

				IF iSqlErr ='-668' THEN
					IF vIdProceso = '07' THEN
						LET vCodRet = '66802';
					END IF;

					IF vIdProceso = '00' THEN
						LET vSql = '';
						LET vSql = 'rm -rf ' || TRIM(cRutaCarga) ||'_'||TRIM(cArchivoPreAp);
						SYSTEM vSql;

						LET vMensaje = 'Archivo no localizado: ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp);
						LET vCodRet = '66800';
					END IF;
				END IF;

				RETURN vCodRet, vMensaje, vIdProceso;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA EXISTENCIA DEL ARCHIVO ANTES DE INICIAR CON EL PROCESO DE CARGA
		 --SYSTEM "sed 's/.$//' " || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || " > " || TRIM(cRutaCarga) ||'_'|| TRIM(cArchivoPreAp);

		--SI EL ARCHIVO YA ESTA CARGADO BORRA TODO EL CONTENIDO DE TRX SIN MIGRAR A HISTORICO

		--MIGRA DATOS HISTORICOS
		LET vIdProceso = '001';
		--LET vCuentaTrx = (SELECT COUNT(*) FROM bdicred:sd_pre_aprobados_trx);
		LET vCuentaTrx = (SELECT LIMIT 1 numcte FROM bdicred:sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN ('-'));

		IF vCuentaTrx <> '' THEN
			--DESCARGA EL RESPALDO
			LET vIdProceso = '011';
			LET vSql = '';
			LET vSql = 'echo "UNLOAD TO ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) ||' DELIMITER ' || '''|''' || ' SELECT * FROM "informix".sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN (' || '''-''' || ')"  >> ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '012';
			LET vSql = '';
			LET vSql = 'dbaccess bdicred ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '013';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '014';
			--CARGA RESPALDO EN TABLA HISTORICA
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo);
			SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_his;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "dbload -d bdicred -c '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.log' ||' -e 1000  -n 1000 -r'||
			TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			system ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			LET vIdProceso = '015';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.cmd';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '016';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.sh';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '017';
			LET vIdProceso = '02';
		END IF;

		TRUNCATE TABLE  "informix".sd_pre_aprobados_trx DROP STORAGE;
		SET ISOLATION TO DIRTY READ;

		LET vIdProceso = '03';

		--CARGA ARCHIVO LAYOUT
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoPreAp);
		SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoPreAp)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoPreAp)||'.cmd';
		SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_trx;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		--SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM ' chmod 777 '  || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';

		LET vIdProceso = '04';

		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN  WORK;
		END IF;

		--BORRA ARCHIVOS TEMPORALES
		LET vIdProceso = '05';

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || '_' || TRIM(cArchivoPreAp);
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sql';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.out';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.cmd';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.log';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sh';
		SYSTEM vSql;

		LET vIdProceso = '06';

		RETURN vCodRet, vMensaje, vIdProceso;
    END;
END PROCEDURE;