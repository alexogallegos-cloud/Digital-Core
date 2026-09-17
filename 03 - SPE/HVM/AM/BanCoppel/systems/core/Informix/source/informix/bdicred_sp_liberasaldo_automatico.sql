CREATE PROCEDURE "informix".sp_liberasaldo_automatico()
RETURNING CHAR(5) AS CodRet,
CHAR(64) AS MensRet;

	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(200);
	DEFINE vCodRet				CHAR(5);
	DEFINE vMensajeRet			CHAR(64);
	DEFINE cRuta				CHAR(80);
	DEFINE vSql					CHAR(1024);
	DEFINE vSql2				CHAR(1024);
	DEFINE vArchivo				CHAR(200);
	DEFINE vCodRet2				CHAR(5);
	DEFINE vNomQuery			CHAR(50);
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_existe				INTEGER;
	DEFINE i					INTEGER;
	DEFINE vTotalRegistros		INTEGER;
	DEFINE vfecha				CHAR(8);

	LET iSqlErr 				= 0;
	LET iIsamErr				= 0;
	LET cErrorInfo				= '';
	LET vCodRet 				= '00000';
	LET vMensajeRet				= 'Liberacion de saldos exitoso';
	LET cRuta 					='/resplogifx/archivoscredito/';
	LET vSql					='';
	LET vSql					='';
	LET vArchivo				="ventanaCreditoRetenido"; 
	LET vCodRet2				= '';
	LET vNomQuery				='cargaRetenido.sql';
	LET vTotalRegistros			= 0;
	LET vfecha					= '';
	
BEGIN

	/* EXCEPTION */
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr <> 0 THEN 
			LET vMensajeRet = 'Ocurrio un error en el proceso de liberar saldos automatico';
			RETURN iSqlErr,vMensajeRet; 
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/ciaguilar/Saldo_Retenido/automatizacion_liberasaldo.out";
	--TRACE ON;
	
	SELECT lpad(day(fecha_hoy),2,0)||lpad(month(fecha_hoy),2,0)||year(fecha_hoy)
	INTO vfecha
	FROM bdicred:sd_fechas;
	  
	/*Paso de validaciones para el archivo */
	DROP TABLE IF EXISTS "informix".tmp_sdo_retenido;
	
	CREATE TABLE "informix".tmp_sdo_retenido 
	(
	 num_tarjeta	CHAR(20) NOT NULL,
	 num_credito	CHAR(20) NOT NULL,
	 monto      	DECIMAL(18,2) NOT NULL,
	 folio_suc  	CHAR(16) NOT NULL,
	 fecha_hora 	DATETIME YEAR to SECOND DEFAULT CURRENT YEAR to SECOND,
	 existe 		INTEGER DEFAULT 1,
	 observaciones	CHAR(40)
	);

	CREATE INDEX "informix".idx_tmp_sdoretenido01 on "informix".tmp_sdo_retenido(num_credito);
	CREATE INDEX "informix".idx_tmp_sdoretenido02 on "informix".tmp_sdo_retenido(existe);
	
	LET vSql = 'echo "load from '||TRIM(cRuta)||TRIM(vArchivo)||vfecha||'.unl'||' insert into "informix".tmp_sdo_retenido(num_tarjeta,num_credito,monto,folio_suc,fecha_hora);" > ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	
	
	/* Comienzan validaciones */
	SELECT COUNT(*) INTO vTotalRegistros FROM "informix".tmp_sdo_retenido;
	
	IF vTotalRegistros = 0 THEN
		LET vMensajeRet = 'Archivo Vacio';
		RETURN vCodRet, vMensajeRet;	
	END IF;
	
	--Valida la existencia del credito
	FOREACH WITH HOLD
		SELECT num_credito into v_num_credito from bdicred:tmp_sdo_retenido 
			
			SELECT count(*) INTO i FROM sd_maecred WHERE num_credito = v_num_credito;
	
			IF i IS NULL OR i = 0 THEN
				BEGIN WORK;
					UPDATE "informix".tmp_sdo_retenido SET existe = 0 where num_credito = v_num_credito;
				COMMIT WORK;
			END IF;
			
	END FOREACH;
	
	/*PASO 1*/
	/* TRUNCATE */
	TRUNCATE TABLE "informix".sd_retenidolibera;
	
	/*PASO 2*/
	/* LOAD */
	INSERT INTO bdicred:"informix".sd_retenidolibera (num_tarjeta, num_credito, monto, folio_suc, fecha_hora)
	SELECT tmpsdo.num_tarjeta, tmpsdo.num_credito, tmpsdo.monto,tmpsdo.folio_suc,tmpsdo.fecha_hora
	FROM "informix".tmp_sdo_retenido tmpsdo 
	WHERE existe = 1 ;

	/*PASO 3*/
	/* STORED PRODECURED */
	EXECUTE PROCEDURE "informix".libera_retenido_forzado() into vCodRet2;
	
	SELECT COUNT(*) into i FROM tmp_sdo_retenido where existe = 0;
	
	IF  i > 0  THEN
		LET vSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'ObservacionesSaldoRetenido'||vfecha||'.unl'||
		' SELECT num_credito,folio_suc,DECODE(existe,0,''Credito no existe'') FROM "informix".tmp_sdo_retenido where existe = 0 " > '||TRIM(cRuta)|| TRIM(vNomQuery) ;
		SYSTEM vSql;
		LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
		SYSTEM vSql;
	END IF;
	
	LET vSql = 'rm -f ' || TRIM(cRuta) || TRIM(vNomQuery);
	SYSTEM vSql;
	
	IF vCodRet2 <> "000" THEN
		LET vMensajeRet = 'Error en ejecucion del stored libera_retenido_forzado';
		RETURN vCodRet2,vMensajeRet ;
	END IF;
	
	RETURN vCodRet,vMensajeRet;
END;
END PROCEDURE;