CREATE PROCEDURE "informix".sp_puntoscompromiso3_2(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19),
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE,pUsuario CHAR(8),pRuta CHAR(100),pTipoReporte SMALLINT,pFeHrInsert CHAR(6))
	 RETURNING CHAR(5) AS codret,
        CHAR(100) AS ruta,
		CHAR(30)  AS nombreArchivo;

--****************************************************************************************************
-- DESCRIPCION:  REPORTES DE PUNTOS DE COMPROMISO POS Y ATM  --TEST
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/11/2010
-- BD: INTERCARD
-- SISTEMA : FRAUDES
-- MODIFICADO :
---- NOMBRE                        FECHA                    DESCRIPCION
--   Juan Daniel Lazalde        03-10-2013      Se agrego consulta en las tablas tarjeta y lote y se cambio el orden de las variables retorno
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viContador INTEGER;
DEFINE vsSecuencia VARCHAR(7);
DEFINE vsCodigoIso VARCHAR(2);
DEFINE vsNumTarjeta VARCHAR(16);
DEFINE vsReferencia VARCHAR(12);
DEFINE vmMonto MONEY (19,4);
DEFINE vsInfReceptor VARCHAR(40);
DEFINE vsIdReceptor VARCHAR(4);
DEFINE vsIdTerminal VARCHAR(16);
DEFINE vsMetodoCaptura VARCHAR(2);
DEFINE vsMotivo VARCHAR(70);
DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION(5);
DEFINE vsSecuenciaExtendida VARCHAR(16);
DEFINE vsNumCuenta VARCHAR(13);
DEFINE vsCiudadComercio VARCHAR(50);
DEFINE vsGiroComercio VARCHAR(4);
DEFINE vsIdRetailer VARCHAR(19);
DEFINE dtFechaOperacion DATE;
DEFINE dtHoraOperacion DATETIME HOUR TO FRACTION(5);

DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);

DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);

DEFINE cNombreArchivo CHAR(30);

--
DEFINE vsStatusTarjeta VARCHAR(3);
DEFINE vsNumCliente VARCHAR(13);
DEFINE vsSucursal VARCHAR(5);
DEFINE viNumeroLote INTEGER;
DEFINE viPaso INTEGER;
DEFINE vLongitud INTEGER;
DEFINE vAprobadaRechazada CHAR(1); --T:Todas, A:Aprobadas, R:Rechazadas
DEFINE vTarjetas CHAR(1); --T:Todas, A:Una o mï¿½s
DEFINE vGiro CHAR(1); --T:Todas, A:Solo un giro
DEFINE vModoCaptura CHAR(1); --T:Todas, A:Solo un mï¿½todo de entrada
DEFINE vTerminalRetailer CHAR(1); --T:IDTerminal de ATM, R:IDRetailer de POS
DEFINE vIDTerminalRetailer CHAR(1); --T:Todos, A:Solo un ID
DEFINE cCmd1 CHAR(3500);
DEFINE cSql    CHAR(3500);
DEFINE cCmd2 CHAR(3500);
DEFINE cSq2    CHAR(3500);
DEFINE pRutaGra CHAR(100);
DEFINE vfecha_ini CHAR(10);
DEFINE vfecha_fin CHAR(10);
DEFINE cDelFile CHAR(200);
DEFINE bInTransaction BOOLEAN;
DEFINE ven_transacc SMALLINT;
DEFINE dFechaHrInsert CHAR(6);

/* INICIALIZACION DE VARIABLES */
LET viContador = 0;
LET vsSecuencia = '';
LET vsCodigoIso = '';
LET vsNumTarjeta = '';
LET vsReferencia = '';
LET vmMonto = 0.0;
LET vsInfReceptor = '';
LET vsIdReceptor = '';
LET vsIdTerminal = '';
LET vsMetodoCaptura = '';
LET vsMotivo = '';
LET vdtFechaHoraInAuth = CURRENT;
LET vsSecuenciaExtendida = '';

LET vdtFechaIni = CURRENT;
LET vdtFechaFin = CURRENT;

LET viSqlErr = 0;
LET viSamErr = 0;

LET vsStatusTarjeta = '';
LET vsNumCliente = '';
LET vsSucursal = '';
LET viNumeroLote = 0;

LET vsNumCuenta = '';
LET vsCiudadComercio = '';
LET vsGiroComercio = '';
LET vsIdRetailer = '';
LET dtFechaOperacion = TODAY;
LET dtHoraOperacion = TODAY;

LET viPaso = 0;
LET vLongitud = 0;
LET vAprobadaRechazada = '';
LET vTarjetas = '';
LET vGiro = '';
LET vModoCaptura = '';
LET vTerminalRetailer = '';
LET vIDTerminalRetailer = '';
LET cNombreArchivo = '';
LET cCmd1='';
LET cSql='';
LET cCmd2='';
LET cSq2='';
LET pRutaGra='';
LET vfecha_ini='';
LET vfecha_fin='';
LET cDelFile='';
LET bInTransaction = 'f';
LET ven_transacc = 0;
LET dFechaHrInsert = TRIM(pFeHrInsert);

BEGIN
	 ON EXCEPTION

		SET viSqlErr, viSamErr
		
		IF ven_transacc = 1 THEN
			ROLLBACK WORK; --		
		END IF;
		RETURN viSqlErr,NULL,NULL;

	END EXCEPTION;

	ON EXCEPTION IN (-668, -535, -255)
		LET bInTransaction = 't';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_puntoscompromiso3_2.out";
	--TRACE ON;

	----SET LOCK MODE TO WAIT 3;
	----SET ISOLATION TO DIRTY READ;


	--DROP TABLE IF EXISTS intercard:"informix".temp_Tarjetas4;
	----DELETE FROM bdicnweb:"informix".sw_con_puntoscompromisos_genrep WHERE us_insert = pUsuario AND fechahora_insert = dFechaHrInsert;
	----DELETE FROM bdicnweb:"informix".sw_con_pcompromisostarjetas_genrep WHERE us_insert = pUsuario AND fechahora_insert = dFechaHrInsert;
	--create temp table temp_Tarjetas4(
	--	     tt_numtarjeta CHAR(16)) with no log;


	LET psProdInd = trim(psProdInd);
	LET psIdPOSATM = trim(psIdPOSATM);
    LET psGiro = trim(psGiro);
	LET psTarjetas = trim(psTarjetas);
	LET psModoCaptura = trim(psModoCaptura);
 	LET psCodigoIso = trim(psCodigoIso);
	--// PONE EN VARIABLES LA FECHA SOLICITADA (DDMMYYYY)
	LET vfecha_ini = LPAD(DAY(pdtFechaIni),2,0)||LPAD(MONTH(pdtFechaIni),2,0)||YEAR(pdtFechaIni);
	LET vfecha_fin = LPAD(DAY(pdtFechaFin),2,0)||LPAD(MONTH(pdtFechaFin),2,0)||YEAR(pdtFechaFin);

	 IF(psProdInd = '01') THEN
		LET vTerminalRetailer = 'T'; --ATM
		LET cNombreArchivo = REPLACE(('ATM_'||vfecha_ini||'_'||vfecha_fin||'.txt'),' ','');
	 ELSE
        LET vTerminalRetailer = 'R'; --POS
		LET cNombreArchivo = REPLACE(('POS_'||vfecha_ini||'_'||vfecha_fin||'.txt'),' ','');
     END IF;

	 IF(psIdPOSATM = '') THEN
		LET vIDTerminalRetailer = 'T'; --ATM
	 ELSE
        LET vIDTerminalRetailer = 'A'; --POS
     END IF;

	 IF(psGiro = '') THEN
		LET vGiro = 'T';
	 ELSE
        LET vGiro = 'A';
     END IF;

	 IF(psModoCaptura = '') THEN
		LET vModoCaptura = 'T';
	 ELSE
	 	LET vModoCaptura = 'A';
     END IF;

	 IF(psCodigoIso = '') THEN
			 LET vAprobadaRechazada = 'T'; --Todas
		 ELIF(psCodigoIso = '99') THEN
		     LET vAprobadaRechazada = 'R'; --Solo Rechazadas
		 ELIF(psCodigoIso = '00') THEN
		     LET vAprobadaRechazada = 'A'; --Solo Aprobadas
     END IF;

	IF(psTarjetas = '') THEN
		LET vTarjetas = 'T';
	ELSE
		LET vTarjetas = 'A';
		LET viPaso = 1;
		LET vLongitud = length(psTarjetas);
		WHILE viPaso < vLongitud
			insert into bdicnweb:"informix".sw_con_pcompromisostarjetas_genrep (tt_numtarjeta,us_insert,fecha_insert,fechahora_insert) values(substring(psTarjetas from viPaso for (viPaso + 16)), pUsuario, current, dFechaHrInsert);
			LET viPaso = viPaso + 17;
		END WHILE;
    END IF;

	IF (NVL(psProdInd,'00') <> '01') AND (NVL(psProdInd,'00') <> '02') THEN --ERROR

		RETURN '00001',NULL,NULL;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN


		RETURN '00002',NULL,NULL;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR


		RETURN '00003',NULL,NULL;

	END IF;

	LET vdtFechaIni = pdtFechaIni;
	LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';

	LET vdtFechaFin = pdtFechaFin;
	LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';

	LET vdtFechaAux = CURRENT;

	--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
	SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
	INTO vdtFechaAux
	FROM intercard:"informix".movimiento;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF (SELECT en_proceso FROM bdicnweb:"informix".sw_ctrlarmadorep) = 't' THEN
		SET LOCK MODE TO WAIT 6;
	--ELSE
	--	INSERT INTO bdicnweb:"informix".sw_ctrlarmadorep(en_proceso) VALUES ('t');
	END IF;
	
	IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE)
			OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
			LET viPaso = 1;
			--INSERT INTO bdicnweb:"informix".sw_con_puntoscompromisos_genrep (codstatustarjeta,numcliente,clave_sucursal,numtarjeta,infreceptor,fechahora,monto,
			--idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia,numcuenta,cdcomercio,
			--codgironeg,idretailer,fecha,hora,us_insert,fecha_insert,fechahora_insert)
			--SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)} 
			--	t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth AS fechahora, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
			--	r.numcuenta, '' AS cdcomercio, m.codgironeg AS giro, m.idretailer as idcomercio, m.fechahorainauth::date as fceha, substr(m.fechahorainauth,12,8) as hora, pUsuario, CURRENT, dFechaHrInsert
			--	FROM intercard:"informix".movimiento m
			--	LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta
			--	LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
			--	LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
			--	WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
			--	AND m.ProdInd = psProdInd
			--	AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
			--		(vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
			--		(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
			--		(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
			--	AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
			--		(vModoCaptura = 'T' AND 1 = 1))
			--	AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
			--		(vGiro = 'T' AND 1 = 1))
			--	AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:"informix".sw_con_pcompromisostarjetas_genrep WHERE us_insert=pUsuario AND fechahora_insert = dFechaHrInsert)) OR
			--		 (vTarjetas = 'T' AND 1=1 ))
			--	AND((vAprobadaRechazada = 'T' AND 1=1) OR
			--		(vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
			--		(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
			--	;--ORDER BY m.FechaHoraInAuth DESC;
				
			IF(pTipoReporte=1) THEN --FORMATO CORTO
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
				
				LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal,m.numtarjeta, ";
				LET cCmd1 =""||TRIM(cCmd1)||"m.infreceptor,TO_CHAR(m.FechaHoraInAuth, '%d/%m/%Y %I:%M:%S %p'),m.monto,m.idterminal,m.idreceptor,m.metodocaptura,m.codigoiso,m.motivo,t.numerolote,m.secuencia,m.referencia ";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM intercard:""informix"".movimiento m ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".tarjeta t on t.numtarjeta = m.NumTarjeta ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".lote l on l.numerolote = t.numerolote ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".tarjetacuenta r on r.numtarjeta = m.Numtarjeta ";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE m.FechaHoraInAuth BETWEEN '"||vdtFechaIni||"' AND '"||vdtFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND m.ProdInd = '"||psProdInd||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdTerminal = '"||psIdPOSATM||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdRetailer = '"||psIdPOSATM||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vModoCaptura||"' = 'A' AND m.metodocaptura = '"||psModoCaptura||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vModoCaptura||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vGiro||"' = 'A' AND m.codgironeg = '"||psGiro||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vGiro||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vTarjetas||"' = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:""informix"".sw_con_pcompromisostarjetas_genrep WHERE us_insert='"||pUsuario||"' AND fechahora_insert = '"||dFechaHrInsert||"')) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTarjetas||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vAprobadaRechazada||"' = 'T' AND 1=1) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vAprobadaRechazada||"' = 'A' AND m.codigoiso = '00') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vAprobadaRechazada||"' = 'R' AND m.codigoiso <> '00')) ";
				
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
			ELSE
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
				
				LET cCmd2 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal, ";
				LET cCmd2 =""||TRIM(cCmd2)||"m.numtarjeta,m.infreceptor,TO_CHAR(m.FechaHoraInAuth, '%d/%m/%Y %I:%M:%S %p'),m.monto,m.idterminal,m.idreceptor,m.metodocaptura,m.codigoiso,m.motivo,t.numerolote,m.secuencia, ";
				LET cCmd2 =""||TRIM(cCmd2)||"NVL(m.referencia,'') AS referencia,NVL(r.numcuenta,'') AS numcuenta,'' AS cdcomercio,NVL(m.codgironeg,'') AS codgironeg,NVL(m.idretailer,'') AS idretailer,m.FechaHoraInAuth::date,substr(m.FechaHoraInAuth,12,8)";
				LET cCmd2 =""||TRIM(cCmd2)||" FROM intercard:""informix"".movimiento m ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".tarjeta t on t.numtarjeta = m.NumTarjeta ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".lote l on l.numerolote = t.numerolote ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".tarjetacuenta r on r.numtarjeta = m.Numtarjeta ";
				LET cCmd2 =""||TRIM(cCmd2)||" WHERE m.FechaHoraInAuth BETWEEN '"||vdtFechaIni||"' AND '"||vdtFechaFin||"'";
				LET cCmd2 =""||TRIM(cCmd2)||" AND m.ProdInd = '"||psProdInd||"'";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdTerminal = '"||psIdPOSATM||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdRetailer = '"||psIdPOSATM||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vModoCaptura||"' = 'A' AND m.metodocaptura = '"||psModoCaptura||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vModoCaptura||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vGiro||"' = 'A' AND m.codgironeg = '"||psGiro||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vGiro||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vTarjetas||"' = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:""informix"".sw_con_pcompromisostarjetas_genrep WHERE us_insert='"||pUsuario||"' AND fechahora_insert = '"||dFechaHrInsert||"')) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTarjetas||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vAprobadaRechazada||"' = 'T' AND 1=1) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vAprobadaRechazada||"' = 'A' AND m.codigoiso = '00') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vAprobadaRechazada||"' = 'R' AND m.codigoiso <> '00')) ";
				
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
			END IF;	
	
	END IF;

	/* 
	LET vdtFechaAux = CURRENT;
	SELECT {+INDEX(intercard:movimientohistorico idx_fechahorainauth)} MIN(FechaHoraInAuth)
	INTO vdtFechaAux
	FROM intercard:movimientohistorico; */
	
	IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
		OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
			LET viPaso = 2;

			--INSERT INTO bdicnweb:"informix".sw_con_puntoscompromisos_genrep (codstatustarjeta,numcliente,clave_sucursal,numtarjeta,infreceptor,fechahora,monto,
			--			idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia,numcuenta,cdcomercio,
			--			codgironeg,idretailer,fecha,hora,us_insert,fecha_insert,fechahora_insert)
			--SELECT t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth AS fechahora, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
			--	r.numcuenta, '' AS cdcomercio, m.codgironeg AS giro, m.idretailer AS idcomercio, m.fechahorainauth::date AS fecha, substr(m.fechahorainauth,12,8) AS hora, pUsuario, CURRENT, dFechaHrInsert
			--	FROM intercard:"informix".movimientohistorico m
			--	LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta
			--	LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
			--	LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
			--	WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
			--	AND m.ProdInd = psProdInd
			--	AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
			--		(vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
			--		(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
			--		(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
			--	AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
			--		(vModoCaptura = 'T' AND 1 = 1))
			--	AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
			--		(vGiro = 'T' AND 1 = 1))
			--	AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:"informix".sw_con_pcompromisostarjetas_genrep WHERE us_insert=pUsuario AND fechahora_insert = dFechaHrInsert)) OR
			--		(vTarjetas = 'T' AND 1=1 ))
			--	AND((vAprobadaRechazada = 'T' AND 1=1) OR
			--		(vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
			--		(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
			--	;--ORDER BY m.FechaHoraInAuth DESC;
				
			IF(pTipoReporte=1) THEN --FORMATO CORTO
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
				
				IF NVL(cCmd1,'') <> '' THEN 
					LET cCmd1 =""||TRIM(cCmd1)|| "UNION ALL SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal,m.numtarjeta, ";
				
				ELSE
					LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal,m.numtarjeta, ";
					
				END IF;
				
				--LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal,m.numtarjeta, ";
				LET cCmd1 =""||TRIM(cCmd1)||"m.infreceptor,TO_CHAR(m.FechaHoraInAuth, '%d/%m/%Y %I:%M:%S %p'),m.monto,m.idterminal,m.idreceptor,m.metodocaptura,m.codigoiso,m.motivo,t.numerolote,m.secuencia,m.referencia ";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM intercard:""informix"".movimientohistorico m ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".tarjeta t on t.numtarjeta = m.NumTarjeta ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".lote l on l.numerolote = t.numerolote ";
				LET cCmd1 =""||TRIM(cCmd1)||" LEFT JOIN intercard:""informix"".tarjetacuenta r on r.numtarjeta = m.Numtarjeta ";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE m.FechaHoraInAuth BETWEEN '"||vdtFechaIni||"' AND '"||vdtFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND m.ProdInd = '"||psProdInd||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdTerminal = '"||psIdPOSATM||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdRetailer = '"||psIdPOSATM||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vModoCaptura||"' = 'A' AND m.metodocaptura = '"||psModoCaptura||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vModoCaptura||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vGiro||"' = 'A' AND m.codgironeg = '"||psGiro||"') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vGiro||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vTarjetas||"' = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:""informix"".sw_con_pcompromisostarjetas_genrep WHERE us_insert='"||pUsuario||"' AND fechahora_insert = '"||dFechaHrInsert||"')) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vTarjetas||"' = 'T' AND 1=1)) ";
				LET cCmd1 =""||TRIM(cCmd1)||" AND(('"||vAprobadaRechazada||"' = 'T' AND 1=1) OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vAprobadaRechazada||"' = 'A' AND m.codigoiso = '00') OR ";
				LET cCmd1 =""||TRIM(cCmd1)||" ('"||vAprobadaRechazada||"' = 'R' AND m.codigoiso <> '00')) ";
				
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
			ELSE
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
				
				IF NVL(cCmd2,'') <> '' THEN 
					LET cCmd2 ="  "||TRIM(cCmd2)||"UNION ALL SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal, ";
				
				ELSE
					LET cCmd2 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal, ";
				
				END IF;
				
				--LET cCmd2 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY m.FechaHoraInAuth DESC) AS consecutivo,t.codstatustarjeta,t.numcliente,l.clave_sucursal, ";
				LET cCmd2 =""||TRIM(cCmd2)||"m.numtarjeta,m.infreceptor,TO_CHAR(m.FechaHoraInAuth, '%d/%m/%Y %I:%M:%S %p'),m.monto,m.idterminal,m.idreceptor,m.metodocaptura,m.codigoiso,m.motivo,t.numerolote,m.secuencia, ";
				LET cCmd2 =""||TRIM(cCmd2)||"NVL(m.referencia,'') AS referencia,NVL(r.numcuenta,'') AS numcuenta,'' AS cdcomercio,NVL(m.codgironeg,'') AS codgironeg,NVL(m.idretailer,'') AS idretailer,m.FechaHoraInAuth::date,substr(m.FechaHoraInAuth,12,8)";
				LET cCmd2 =""||TRIM(cCmd2)||" FROM intercard:""informix"".movimientohistorico m ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".tarjeta t on t.numtarjeta = m.NumTarjeta ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".lote l on l.numerolote = t.numerolote ";
				LET cCmd2 =""||TRIM(cCmd2)||" LEFT JOIN intercard:""informix"".tarjetacuenta r on r.numtarjeta = m.Numtarjeta ";
				LET cCmd2 =""||TRIM(cCmd2)||" WHERE m.FechaHoraInAuth BETWEEN '"||vdtFechaIni||"' AND '"||vdtFechaFin||"'";
				LET cCmd2 =""||TRIM(cCmd2)||" AND m.ProdInd = '"||psProdInd||"'";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdTerminal = '"||psIdPOSATM||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'T' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'A' AND m.IdRetailer = '"||psIdPOSATM||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTerminalRetailer||"' = 'R' AND '"||vIDTerminalRetailer||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vModoCaptura||"' = 'A' AND m.metodocaptura = '"||psModoCaptura||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vModoCaptura||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vGiro||"' = 'A' AND m.codgironeg = '"||psGiro||"') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vGiro||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vTarjetas||"' = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:""informix"".sw_con_pcompromisostarjetas_genrep WHERE us_insert='"||pUsuario||"' AND fechahora_insert = '"||dFechaHrInsert||"')) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vTarjetas||"' = 'T' AND 1=1)) ";
				LET cCmd2 =""||TRIM(cCmd2)||" AND(('"||vAprobadaRechazada||"' = 'T' AND 1=1) OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vAprobadaRechazada||"' = 'A' AND m.codigoiso = '00') OR ";
				LET cCmd2 =""||TRIM(cCmd2)||" ('"||vAprobadaRechazada||"' = 'R' AND m.codigoiso <> '00')) ";
				
				--UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
			END IF;	
		
	END IF;

	--LET cSql='rm -f '||TRIM(pRuta)||'ATM_*.txt';
	--SYSTEM TRIM(cSql);
	--LET cSql='rm -f '||TRIM(pRuta)||'POS_*.txt';
	--SYSTEM TRIM(cSql);
	
	--SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 6;
	
	LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
	/*
	IF (SELECT en_proceso FROM bdicnweb:"informix".sw_ctrlarmadorep) = 't' THEN
		SET LOCK MODE TO WAIT 6;
	--ELSE
	--	INSERT INTO bdicnweb:"informix".sw_ctrlarmadorep(en_proceso) VALUES ('t');
	END IF;
	*/
	IF(pTipoReporte=1) THEN --FORMATO CORTO
		
		UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
		
		--LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY fechahora DESC) AS consecutivo,codstatustarjeta,numcliente,clave_sucursal,numtarjeta, ";
		--LET cCmd1 =""||TRIM(cCmd1)||"infreceptor,TO_CHAR(fechahora, '%d/%m/%Y %I:%M:%S %p'),monto,idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia ";
		--LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:sw_con_puntoscompromisos_genrep WHERE us_insert="||pUsuario||" AND fechahora_insert="||dFechaHrInsert;
		
		BEGIN WORK;
		LET ven_transacc = 1;
		
		--LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
		
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql';
		--LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql';
		--COMMIT WORK;
		SYSTEM TRIM(cSql);
		--BEGIN WORK;
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql'; -- desarrollo
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql'; --produccion
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRuta)||'query01'||TRIM(dFechaHrInsert)||'.sql';
		SYSTEM TRIM(cSql);
		
		COMMIT WORK;

		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;	
		
		UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
		
	ELSE 					--FORMATO LARGO
		
		UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 't';
		
		--LET cCmd2 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY fechahora DESC) AS consecutivo,codstatustarjeta,numcliente,clave_sucursal, ";
		--LET cCmd2 =""||TRIM(cCmd2)||"numtarjeta,infreceptor,TO_CHAR(fechahora, '%d/%m/%Y %I:%M:%S %p'),monto,idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia, ";
		--LET cCmd2 =""||TRIM(cCmd2)||"NVL(referencia,'') AS referencia,NVL(numcuenta,'') AS numcuenta,NVL(cdcomercio,'') AS cdcomercio,NVL(codgironeg,'') AS codgironeg,NVL(idretailer,'') AS idretailer,fecha, hora";
		--LET cCmd2 =""||TRIM(cCmd2)||" FROM bdicnweb:sw_con_puntoscompromisos_genrep WHERE us_insert="||pUsuario||" AND fechahora_insert="||dFechaHrInsert;
		
		BEGIN WORK;
		LET ven_transacc = 1;
		
		--LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
		
		LET cSq2 = '';
		LET cSq2 = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd2)||' " > '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql';
		--LET cSq2 = '/usr/bin/echo "UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd2)||' " > '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql';
		--COMMIT WORK;
		SYSTEM TRIM(cSq2);
		--BEGIN WORK;
		
		LET cSq2 = '';
		LET cSq2 = '/usr/bin/chmod 777 '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql';
		SYSTEM TRIM(cSq2);

		LET cSq2 = '';
		--LET cSq2 = '/informix/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql'; -- desarrollo
		LET cSq2 = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql'; --produccion
		SYSTEM TRIM(cSq2);

		LET cSq2 = '';
		LET cSq2 = '/usr/bin/rm -rf '||TRIM(pRuta)||'query02'||TRIM(dFechaHrInsert)||'.sql';
		SYSTEM TRIM(cSq2);
		
		COMMIT WORK;

		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;	
		
		UPDATE bdicnweb:"informix".sw_ctrlarmadorep SET en_proceso = 'f';
		
	END IF;
	
	RETURN  '00000', pRuta, cNombreArchivo;

END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/01/2020',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE PUNTOS COMPROMISO',
'DESCRIPCION: Se crea SPL CLON de sp_puntoscompromiso3, para cancelar la eliminaciï¿½n de archivos (rm -f).',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 28/01/2020',
'DESCRIPCION: Se modifica SPL para consumir nuevas tablas que controlan generaciï¿½n de reporte.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/02/2020',
'DESCRIPCION: Se modifica SPL para implementar el armado de la nomenclatura de los archivos .sql a partir del parï¿½metro pFeHrInsert, adicional a esto,',
'se creï¿½ la tabla sw_ctrlarmadorep con la finalidad de banderear si algï¿½n reporte se encuentra en ejecuciï¿½n y adicionar entonces un tiempo de espera.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 05/03/2020',
'DESCRIPCION: Se modifica SPL para reducir tiempos de ejecuciï¿½n.',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 21/02/2025',
'DESCRIPCION: Se modifica SPL aplicar sentenci UNION ALL cuando se obtiene informaciï¿½n en tabla movimientos e historias ademï¿½s .',
'se agrega consulta de la tabla historica para recuperar fecha minina para validar la existencia de informaciï¿½n.',
'BD: intercard';

CREATE PROCEDURE "informix".sp_clientes_tokenizacion()

RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************
DEFINE iSql_err                                         INT;
DEFINE cCodRet                                          CHAR(5);
DEFINE vNumtarjeta                      VARCHAR(19);
DEFINE vCliente                                         VARCHAR(20);
DEFINE vCodStatus                                       VARCHAR(4);
DEFINE vCCredito                                        VARCHAR(20);
DEFINE vStatusCred                                      VARCHAR(3);
DEFINE vCDebito                                         VARCHAR(20);
DEFINE vStatusDeb                                       VARCHAR(1);
DEFINE vFecha                                           DATETIME YEAR TO FRACTION(5);
DEFINE banderaDeb                                       INTEGER;
DEFINE banderaCred                                      INTEGER;
DEFINE contador                     INTEGER;
DEFINE nombreArchivo                VARCHAR(60);
DEFINE pArchDeclarga1                   CHAR(1000);
DEFINE cCmd1                            CHAR(1500);
DEFINE cQuery1                          CHAR(3000);
DEFINE primerDiaMes                     CHAR(2);
DEFINE mes                              CHAR(2);
DEFINE anio                             CHAR(4);
DEFINE anioAnt                      CHAR(4);
DEFINE horaInicio                       CHAR(11);
DEFINE cardID                                           CHAR(100);
DEFINE fechaExp                     CHAR(4);
DEFINE mesAnt                           CHAR(2);

-- ****************************************************************************
-- Inicializa las variables
-- ****************************************************************************
LET iSql_err                                    = 0;
LET cCodRet                                             = '00000';
LET vNumtarjeta                                 = '';
LET vCliente                                    = '';
LET vCodStatus                                  = '';
LET vCCredito                   = '';
LET vStatusCred                                 = '';
LET vCDebito                                    = '';
LET vStatusDeb                                  = '';
LET vFecha                                              = '';
LET banderaDeb                                  = 0;
LET banderaCred                                 = 0;
LET contador                    = 0;
LET nombreArchivo               = '';
LET primerDiaMes                = '';
LET mes                         = '';
LET anio                        = '';
LET horaInicio                              = ' 00:00:00.0';
LET cardID                                              = '';
LET fechaExp                    = '';
LET mesAnt                      = '';
LET anioAnt                     = '';

    BEGIN

                ON EXCEPTION SET iSql_err

                        IF iSql_err <> 0 then
                                LET cCodRet = iSql_err;
                                RETURN cCodRet;
                        END IF;
                END EXCEPTION;

                SET ISOLATION TO dirty READ;
                SET LOCK MODE TO WAIT 3;
                --SET DEBUG FILE TO "/home/syscybmdp2/prueba_sp_clientes_tokenizacion.out";
        --TRACE ON;

                TRUNCATE TABLE intercard:tbl_ciclo_vida_tokenizacion_clientes;

                --Consulta el primer dia del mes
        LET primerDiaMes = "01";


        SELECT MONTH(TODAY),MONTH(TODAY) -1,YEAR(TODAY),YEAR(TODAY) -1
            INTO mes,mesAnt,anio,anioAnt
        FROM systables
            WHERE tabid=1;

        IF mes < 10 THEN
            LET mes = 0 || mes;
        END IF

        IF mesAnt < 10 THEN
            LET mesAnt = 0 || mesAnt;
        END IF




        ----Fecha y hora inicio mes anterior----
        LET vFecha = trim(anio ||'-'|| mes || '-' || primerDiaMes || horaInicio);

                FOREACH tarjetas WITH HOLD FOR

                        SELECT DISTINCT tar.numcliente
                                INTO vCliente
                                        FROM intercard:tarjetas_tokenizadas ind
                                                INNER JOIN intercard:tarjeta tar
                                                        ON ind.numtarjeta = tar.numtarjeta
                                                                WHERE tar.fechaultmodif < vFecha
                                                                        AND ind.status = 5
                                                                                AND tar.numcliente <> ""

                        LET banderaDeb = 0;
                        LET banderaCred = 0;

                        FOREACH tarjetas WITH HOLD FOR

                                SELECT num_credito, status_cred
                                        INTO vCCredito, vStatusCred
                                                FROM bdicred:sd_maecred
                                                        WHERE numcte = vCliente

                                IF (vCCredito IS NOT NULL) THEN
                                        IF (vStatusCred NOT IN ('FI', 'FF', 'CV', 'FC', 'FM', 'CE', 'FR', 'FE', 'OE')) THEN
                                                LET banderaCred = 1;
                                        END IF
                                END IF

                        END FOREACH

                        FOREACH tarjetas WITH HOLD FOR

                                SELECT cuenta, status_cta
                                        INTO vCDebito, vStatusDeb
                                                FROM bdicheq:sc_maechq
                                                        WHERE num_cte = vCliente

                                IF (vCDebito IS NOT NULL) THEN
                                        IF (vStatusDeb NOT IN ('2' , '4', '6', '3')) THEN
                                                LET banderaDeb = 1;
                                        END IF
                                END IF

                        END FOREACH

                        IF (banderaDeb = 0 AND banderaCred = 0) THEN
                                INSERT INTO "informix".tbl_ciclo_vida_tokenizacion_clientes(numcliente, reason, reasoncode)
                                        VALUES(vCliente, 'Cancelacion de cuentas', 'ISSUER_DECISION');
                        END IF

                END FOREACH
                IF mesAnt = 0 THEN
			LET fechaExp =  SUBSTR(anioAnt,3,2) || 12;
		ELSE
			LET fechaExp =  SUBSTR(anio,3,2) || mesAnt;
		END IF

                
                --TRACE "FECHA : " || fechaExp;
                FOREACH tarjetas WITH HOLD FOR

            SELECT card_id
                INTO cardID
            FROM tarjeta tar
                INNER JOIN tokenizacion_cardid tok
                    ON tok.numtarjeta = tar.numtarjeta
            WHERE tar.fechaexp = fechaExp
            AND tar.codstatustarjeta IN ("ACT","BLO")

                        --TRACE cardID;

                         IF (cardID IS NOT NULL OR cardID <> '') THEN
                INSERT INTO  tbl_ciclo_vida_tokenizacion_clientes(numcliente, reason, reasoncode)
                VALUES(cardID, 'EXPIRADA', 'ISSUER_DECISION');
             END IF

                END FOREACH

                SELECT COUNT(*)
                        INTO contador
                                        FROM tbl_ciclo_vida_tokenizacion_clientes;

                IF (contador > 0) THEN
                        LET nombreArchivo = 'Ciclo_Vida_Tokenizacion_Clientes_';

                        LET pArchDeclarga1='"/RESPALDOSNEW/Tokenizacion/'|| nombreArchivo ||  anio || '-' || mes || '-04.csv" ';

                        LET cCmd1 = 'SELECT TRIM(numcliente), reason, reasoncode FROM tbl_ciclo_vida_tokenizacion_clientes;';
                        LET cQuery1 = "echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' > /RESPALDOSNEW/Tokenizacion/tmp_tokenizacion_clientes.sql";
                        SYSTEM TRIM(cQuery1);
                        SYSTEM 'dbaccess intercard /RESPALDOSNEW/Tokenizacion/tmp_tokenizacion_clientes.sql';
                ELSE
                        LET cCodRet = "00002";
                END IF;



        RETURN cCodRet;
        END;

END PROCEDURE;