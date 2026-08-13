CREATE PROCEDURE "informix".sp_puntoscompromiso(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING
VARCHAR(3) AS Status,
VARCHAR(13) AS NumCliente,
VARCHAR(5) AS Sucursal,
VARCHAR(16) AS NumTarjeta,
VARCHAR(40) AS InfReceptor,
DATETIME YEAR TO FRACTION AS FechaHoraInAuth,
MONEY (19,4) AS Monto,
VARCHAR(16) AS IdTerminal,
VARCHAR(4) AS IdReceptor,
VARCHAR(2) AS MetodoCaptura,
VARCHAR(2) AS CodigoIso,
VARCHAR(70) AS Motivo,
INTEGER AS LoteTarjeta,
VARCHAR(7) AS Secuencia,
VARCHAR(12) AS Referencia

--****************************************************************************************************
-- DESCRIPCION:  REPORTES DE PUNTOS DE COMPROMISO POS Y ATM
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/11/2010
-- BD: INTERCARD
-- SISTEMA : FRAUDES
-- MODIFICADO :
---- NOMBRE                        FECHA                    DESCRIPCION
--   Juan Daniel Lazalde        03-10-2013      Se agrego consulta en las tablas tarjeta y lote y se cambio el orden de las variables retorno
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
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


DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);


DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);
--
DEFINE vsStatusTarjeta VARCHAR(3);
DEFINE vsNumCliente VARCHAR(13);
DEFINE vsSucursal VARCHAR(5);
DEFINE viNumeroLote INTEGER;


/* INICIALIZACION DE VARIABLES */
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

BEGIN
	ON EXCEPTION

		SET viSqlErr, viSamErr

		RETURN NULL,NULL,NULL,viSqlErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,viSqlErr,NULL;

	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/pruebasconciliacion/sp_PuntosCompromiso.sql";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	IF (NVL(psProdInd,'00') <> '01') AND (NVL(psProdInd,'00') <> '02') THEN --ERROR
		
		RETURN NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00001',NULL;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN

		
		RETURN NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00002',NULL;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR

		
		RETURN NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00003',NULL;

	ELSE

		LET vdtFechaIni = pdtFechaIni;
		LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';

		LET vdtFechaFin = pdtFechaFin;
		LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';

		LET vdtFechaAux = CURRENT;

		--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
		SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
		INTO vdtFechaAux
		FROM intercard:"informix".movimiento;			

		IF (psProdInd = '01') THEN --ATM		
				IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) 
				OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
					FOREACH SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)}
						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia
						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia
						FROM intercard:"informix".movimiento m
						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
						WHERE FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
						AND ProdInd = psProdInd
						AND IdTerminal = psIdPOSATM
						ORDER BY FechaHoraInAuth DESC
						
						RETURN vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia WITH RESUME;

					END FOREACH;
				END IF;

				IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
				OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
					FOREACH SELECT 
						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia, SecuenciaExtendida
						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia, vsSecuenciaExtendida
						FROM intercard:"informix".movimientohistorico m
						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
						WHERE FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
						AND ProdInd = psProdInd
						AND IdTerminal = psIdPOSATM
						ORDER BY FechaHoraInAuth DESC
						
						RETURN vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia WITH RESUME;

					END FOREACH;
				END IF;

		ELIF (psProdInd = '02') THEN  --POS
		
			IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) 
			OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
				FOREACH SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew5a)}
					t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia
					INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia
					FROM intercard:"informix".movimiento m
					LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
					LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
					WHERE FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
					AND ProdInd = psProdInd
					AND IdRetailer = psIdPOSATM
					ORDER BY FechaHoraInAuth DESC

					RETURN vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia WITH RESUME;

				END FOREACH;
			END IF;

			IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
			OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
				FOREACH SELECT 
					t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia
					INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia
					FROM intercard:"informix".movimientohistorico m
					LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
					LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
					WHERE FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
					AND ProdInd = psProdInd
					AND IdRetailer = psIdPOSATM
					ORDER BY FechaHoraInAuth DESC

					RETURN vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia WITH RESUME;

				END FOREACH;
			END IF;
			

		END IF;

	END IF;


END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: FRAUDES',
'Solicito: Luis Antonio Gómez Santiago',
'Descripcion: GENERA REPORTE DE PUNTOS DE COMPROMISO.',
'Fecha: 2010/11/26',
'Version: 20101126.1600',
'BD: INTERCARD';

CREATE PROCEDURE "informix".sp_puntoscompromiso(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), 
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING
INTEGER AS Contador,
VARCHAR(3) AS Status,
VARCHAR(13) AS NumCliente,
VARCHAR(5) AS Sucursal,
VARCHAR(16) AS NumTarjeta,
VARCHAR(40) AS InfReceptor,
DATETIME YEAR TO FRACTION AS FechaHoraInAuth,
MONEY (19,4) AS Monto,
VARCHAR(16) AS IdTerminal,
VARCHAR(4) AS IdReceptor,
VARCHAR(2) AS MetodoCaptura,
VARCHAR(2) AS CodigoIso,
VARCHAR(70) AS Motivo,
INTEGER AS LoteTarjeta,
VARCHAR(7) AS Secuencia,
VARCHAR(12) AS Referencia,

VARCHAR(13) AS NumCuenta,
VARCHAR(50) AS CiudadComercio,
VARCHAR(4) AS GiroComercio,
VARCHAR(19) AS IdRetailer,
DATE AS FechaOperacion,
DATETIME HOUR TO FRACTION(3) As HoraOperacion


--****************************************************************************************************
-- DESCRIPCION:  REPORTES DE PUNTOS DE COMPROMISO POS Y ATM
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
--
DEFINE vsStatusTarjeta VARCHAR(3);
DEFINE vsNumCliente VARCHAR(13);
DEFINE vsSucursal VARCHAR(5);
DEFINE viNumeroLote INTEGER;
DEFINE viPaso INTEGER;
DEFINE vLongitud INTEGER;
DEFINE vAprobadaRechazada CHAR(1); --T:Todas, A:Aprobadas, R:Rechazadas
DEFINE vTarjetas CHAR(1); --T:Todas, A:Una o más
DEFINE vGiro CHAR(1); --T:Todas, A:Solo un giro
DEFINE vModoCaptura CHAR(1); --T:Todas, A:Solo un método de entrada
DEFINE vTerminalRetailer CHAR(1); --T:IDTerminal de ATM, R:IDRetailer de POS
DEFINE vIDTerminalRetailer CHAR(1); --T:Todos, A:Solo un ID

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

BEGIN
	ON EXCEPTION

		SET viSqlErr, viSamErr

		RETURN 0,NULL,NULL,NULL,viSqlErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,viSqlErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	END EXCEPTION;

	/*SET DEBUG FILE TO "/informix/sp_PuntosCompromiso.txt";
	TRACE ON;*/

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	create temp table tempTarjetas(
		   tt_numtarjeta CHAR(16)) with no log;
			   
	LET psProdInd = trim(psProdInd);
	LET psIdPOSATM = trim(psIdPOSATM);
    LET psGiro = trim(psGiro);
	LET psTarjetas = trim(psTarjetas);
	LET psModoCaptura = trim(psModoCaptura);
 	LET psCodigoIso = trim(psCodigoIso);
	
	 IF(psProdInd = '01') THEN	    
		LET vTerminalRetailer = 'T'; --ATM
	 ELSE
        LET vTerminalRetailer = 'R'; --POS
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
		       insert into tempTarjetas (tt_numtarjeta) values(substring(psTarjetas from viPaso for (viPaso + 16)));
			   LET viPaso = viPaso + 17;
		  END WHILE;		  
     END IF;
	
	IF (NVL(psProdInd,'00') <> '01') AND (NVL(psProdInd,'00') <> '02') THEN --ERROR
		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00001',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN

		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00002',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR

		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00003',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	ELSE

		LET vdtFechaIni = pdtFechaIni;
		LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';

		LET vdtFechaFin = pdtFechaFin;
		LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';

		LET vdtFechaAux = CURRENT;

		--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
		SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
		INTO vdtFechaAux
		FROM intercard:"informix".movimiento;			

				IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) 
				OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
				    LET viPaso = 1;
					FOREACH SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)}
						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
						r.numcuenta, '', m.codgironeg, m.idretailer, m.fechahorainauth::date, substr(m.fechahorainauth,12,8) 	
						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
						     vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion
						FROM intercard:"informix".movimiento m
						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
						LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
						WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
						AND m.ProdInd = psProdInd
						AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
						    (vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
						    (vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
							(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
						AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
						    (vModoCaptura = 'T' AND 1 = 1))
						AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
						    (vGiro = 'T' AND 1 = 1))
						AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from tempTarjetas)) OR
						     (vTarjetas = 'T' AND 1=1 ))
						AND((vAprobadaRechazada = 'T' AND 1=1) OR
						    (vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
						ORDER BY m.FechaHoraInAuth DESC
						
						LET viContador = viContador + 1;						
						RETURN viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
                               vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion WITH RESUME;

					END FOREACH;
				END IF;

				IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
				OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
				    LET viPaso = 2;
					FOREACH SELECT 
						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia, SecuenciaExtendida,
						r.numcuenta, '', m.codgironeg, m.idretailer, m.fechahorainauth::date, substr(m.fechahorainauth,12,8) 	
						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia, vsSecuenciaExtendida,
						vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion
						FROM intercard:"informix".movimientohistorico m
						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
						LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
						WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
						AND m.ProdInd = psProdInd
  					    AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
						    (vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
						    (vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
							(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
						AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
						    (vModoCaptura = 'T' AND 1 = 1))
						AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
						    (vGiro = 'T' AND 1 = 1))
						AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from tempTarjetas)) OR
						     (vTarjetas = 'T' AND 1=1 ))
						AND((vAprobadaRechazada = 'T' AND 1=1) OR
						    (vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
						ORDER BY m.FechaHoraInAuth DESC
						
						LET viContador = viContador + 1;
						RETURN viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
                               vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion WITH RESUME;
					END FOREACH;
				END IF;					   
	END IF;	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: FRAUDES',
'Solicito: Luis Antonio Gómez Santiago',
'Descripcion: GENERA REPORTE DE PUNTOS DE COMPROMISO.',
'Fecha: 2010/11/26',
'Version: 20101126.1600',
'BD: INTERCARD';

CREATE PROCEDURE "informix".sp_tarj_det_vcas_mx2()
RETURNING VARCHAR(10), VARCHAR(255);

	DEFINE vfecha			DATETIME YEAR TO FRACTION(5);
	DEFINE vstatus_proc		CHAR(1);
	
	DEFINE vcod_ret         VARCHAR(10); 
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE error_info       CHAR(40);
	
	DEFINE v_dia        	CHAR(2);
    DEFINE v_mes        	CHAR(2);
    DEFINE v_ano        	CHAR(4); 
	DEFINE v_hora			DATETIME HOUR TO SECOND;
    DEFINE v_hora2			CHAR(8);
    DEFINE v_sql        	CHAR(250);
    DEFINE cEncabezado  	CHAR(250);
	
	DEFINE cRuta			CHAR(250);
    DEFINE cRuta2			CHAR(250);
	DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
	DEFINE var_numtarjeta   VARCHAR(16);
	DEFINE var_telefono     CHAR(13);
	DEFINE var_correo_elec 	CHAR(100);
	DEFINE var_fecha        DATETIME YEAR to SECOND;
	
	DEFINE iContador_pay    SMALLINT;
    
	DEFINE vreg_ins 		INTEGER;

	--MANEJO DEL ERROR.
       ON EXCEPTION
		SET sql_err, isam_err, error_info
			
			UPDATE intercard:ctrl_info_ctes_vcas
			  SET status_proc = '0';

           IF sql_err <> 0 THEN
              LET vcod_ret=sql_err;
			  UPDATE intercard:ctrl_info_ctes_vcas 
					SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
              RETURN vcod_ret, isam_err||' ' ||error_info;
           END IF;
       END EXCEPTION;
	
	/*set debug file to "/tmp/sp_tarj_det_vcas.out";
	TRACE ON;*/	
				
	LET vfecha = TODAY;	
	LET vstatus_proc = '';
	
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	LET iContador_pay = 0;
	
	LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
	LET v_hora			= CURRENT;
    LET v_hora2			= "";
    LET v_sql           = "";
	
    LET cEncabezado     = "";
	
	LET cRuta	= "/tmp/";
    LET cRuta2	= "/RESPALDOSNEW/VCAS_resultados/";
	LET cNombreArchivo	= "";
    LET cNombreArchivo1	= "";
    LET cNombreArchivo2	= "";

    LET var_action 			= "";
	LET var_numtarjeta      = "";
	LET var_telefono       	= "";
	LET var_correo_elec 	= "";
	LET var_fecha          	= CURRENT;
		
	LET vreg_ins = 0;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
	SELECT status_proc 
	INTO vstatus_proc
	FROM intercard:ctrl_info_ctes_vcas;

	IF(vstatus_proc = '1') THEN
		UPDATE intercard:ctrl_info_ctes_vcas 
			SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
		RETURN vcod_ret, 'DESCARGA EN PROCESO';
	END IF;
    
    UPDATE intercard:ctrl_info_ctes_vcas
	SET status_proc = '1';  
	  
	SELECT fecha
	INTO vfecha	
    FROM intercard:ctrl_info_ctes_vcas;			 	
	
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
     TRUNCATE TABLE intercard:ctas_vcas;

	SELECT numtarjeta,numcliente,fechaultmodif,fechaasignacion
	FROM intercard:tarjeta
	WHERE LEFT(numtarjeta,6) IN (SELECT bin FROM intercard:bines WHERE marca ='VS')
                AND codstatusasignada = 'SIA'
                AND codstatustarjeta = 'ACT'
	INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas
    ON "informix".tmptarjeta(numtarjeta);

    CREATE INDEX "informix".tmp_numclient_vcas
    ON "informix".tmptarjeta(numcliente);

    CREATE INDEX "informix".tmp_fechmod_vcas
    ON "informix".tmptarjeta(fechaultmodif);

    CREATE INDEX "informix".tmp_fechasig_vcas
    ON "informix".tmptarjeta(fechaasignacion);
					
		-- INFORMACIÓN QUE SE EJECUTARÁ CADA DETERMINADO TIEMPO.
		BEGIN WORK;
		FOREACH WITH HOLD
            SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
				A.numtarjeta, 
				B.telefono AS telefono, 
				C.correo_elec AS correo_elec, 
				CURRENT AS fecha
            INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
            LEFT JOIN bdinteg:si_telefonos_actual B ON A.numcliente=B.numcte AND B.tipo_tel=2 AND B.status_tel = 'A' 
            LEFT JOIN bdinteg:si_correos C ON A.numcliente=C.numcte AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido=1 AND C.secuencia =(SELECT MAX(secuencia) FROM bdinteg: si_correos f WHERE C.numcte=f.numcte AND f.tipo_correo = 1 AND f.status_correo = 'A' AND f.valido=1)
            WHERE ((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))
              AND ((A.fechaultmodif>=vfecha)OR(B.fecha_hora>=vfecha)OR(C.fecha_hora>=vfecha))
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action
			
			LET iContador_pay = iContador_pay + 1;
			
			INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha) 
                    VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
        
          IF iContador_pay = 1000 THEN
		  COMMIT;
		  LET	iContador_pay = 0;
		  BEGIN WORK;
		  END IF;
	END FOREACH;	
	COMMIT; 
		
	-- DESCARGAR ARCHIVO.
		   LET v_dia = LPAD(DAY(CURRENT),2,'0');  
		   LET v_mes = LPAD(MONTH(CURRENT),2,'0');
		   LET v_ano = year(CURRENT);
           LET v_hora2 = v_hora::CHAR(8);
		   LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
           LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
           LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
		          
		   -- DESCARGA DEL ARCHIVO .CSV.
			LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
            System cEncabezado;

			LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
			System v_sql;

            LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';						
			System v_sql;
						
			LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
			System v_sql;

			LET v_sql="";
			
		   --SE AÑADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAÍDOS AL ARCHIVO AUXILIAR.
			LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            LET v_sql="";

			LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            --SE PASA LA INFORMACIÓN DESCARGADA AL ARCHIVO FINAL.
            LET v_sql = "";
            LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
            SYSTEM v_sql;

			--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo1);	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo2);	
            SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha) 
	  INTO vfecha 	
	  FROM intercard:ctas_vcas;
	  
	-- CONTEO DE REGISTROS.
	SELECT COUNT(*) 
	  INTO vreg_ins
	  FROM intercard:ctas_vcas;
				
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
     TRUNCATE TABLE intercard:ctas_vcas;
	 DROP TABLE tmptarjeta;
	 		
	-- ACTUALIZAR TABLA CONTROL.
	  UPDATE intercard:ctrl_info_ctes_vcas
	    SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);		
				  
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;