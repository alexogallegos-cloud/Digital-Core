CREATE PROCEDURE "informix".sp_puntoscompro_generaarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10),psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), 
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE,pRuta CHAR(100),pTipoReporte SMALLINT)
        RETURNING CHAR(5) AS codret,
			  CHAR(80) AS ruta_archivo,
			  CHAR(30) AS nombre_archivo;

	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	
	BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_puntoscompro_generaarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR psProdInd ='' OR pdtFechaIni IS NULL OR pdtFechaFin IS NULL OR pRuta = '' OR pTipoReporte IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		--SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE intercard:"informix".sp_puntoscompromiso3(psProdInd , psIdPOSATM , 
									psGiro , psTarjetas , psModoCaptura , psCodigoIso ,   pdtFechaIni , pdtFechaFin ,pUsuario,pRuta,pTipoReporte)  
        INTO cCodRetSp, cRutaArchivo, cNombreArchivo;
	
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;

		IF cCodRet::INT > 0 THEN
			IF bInTransaction THEN
				BEGIN WORK;
			END IF;
		END IF;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
	
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP intercard:'informix'.sp_puntoscompromiso3";
		END IF;

		RETURN cCodRet, cRutaArchivo, cNombreArchivo;
    
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 13/02/2016',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL Intermedio que genera archivo',
'BD: intercard';

CREATE PROCEDURE "informix".sp_puntoscompromiso2_totales(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), 
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING
CHAR(5) 	AS CodRet,
INTEGER AS total;


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
DEFINE cCodRet  CHAR(5);
DEFINE iNoRegistros INTEGER;
DEFINE iNoRegistros1 INTEGER;
DEFINE iNoRegistros2 INTEGER;

DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
--

DEFINE viPaso INTEGER;
DEFINE vLongitud INTEGER;
DEFINE vAprobadaRechazada CHAR(1); --T:Todas, A:Aprobadas, R:Rechazadas
DEFINE vTarjetas CHAR(1); --T:Todas, A:Una o más
DEFINE vGiro CHAR(1); --T:Todas, A:Solo un giro
DEFINE vModoCaptura CHAR(1); --T:Todas, A:Solo un método de entrada
DEFINE vTerminalRetailer CHAR(1); --T:IDTerminal de ATM, R:IDRetailer de POS
DEFINE vIDTerminalRetailer CHAR(1); --T:Todos, A:Solo un ID

/* INICIALIZACION DE VARIABLES */
LET cCodRet='00000';
LET iNoRegistros=0;
LET iNoRegistros1=0;
LET iNoRegistros2=0;

LET viSqlErr = 0;
LET viSamErr = 0;

LET vdtFechaIni = CURRENT;
LET vdtFechaFin = CURRENT;

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

		RETURN viSqlErr,iNoRegistros;

	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_puntoscompromiso2_totales.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	DROP TABLE IF EXISTS tempTarjetas; 
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
		
		RETURN '00001', iNoRegistros;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN

		
		RETURN '00002',iNoRegistros;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR

		
		RETURN '00003',iNoRegistros;

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
					 SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)}
						COUNT(*) 	
						INTO iNoRegistros1
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
							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'));
				
				END IF;

				IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
				OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
				    LET viPaso = 2;
					 SELECT 
						COUNT (*) INTO iNoRegistros2
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
							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'));
					
				END IF;
				
				LET iNoRegistros=iNoRegistros1+iNoRegistros2;
				IF iNoRegistros = 0 THEN
					LET cCodRet = '00017';
				END IF;
						
				RETURN cCodRet,iNoRegistros;				
			
	END IF;	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 13/02/2016',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:Clon de sp para obtener el total de registros',
'BD: intercard';

CREATE PROCEDURE "informix".sp_transferencia_movhis_stat06()
returning
char (5),
char(150);

--#####################################################################################################
--### Creado por: Ana Lidia Rubio Salazar														     ##
--##  Fecha: 21/02/2017																			     ##
--##  Descripcion: Realiza transferencia de registros de la tabla conciliacion_atm_stat06 a          ##
--##  conciliacion_atm_stat06_his por blokes y un update statistics medium a la tabla cada 100,000.	 ##
--#####################################################################################################


DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);

DEFINE vsFlagEnTransaccion	CHAR(5);
DEFINE viContadorRegistros	INTEGER;
DEFINE viContadorRegistros2	INTEGER;

--Variables para paso de tabla
DEFINE vautorizacion varchar(7);
DEFINE vnumtarjeta varchar(16);
DEFINE vfechaconciliacion datetime year to fraction(5);

--Variables para fecha
DEFINE vfecha_hoy DATE;
DEFINE vparam CHAR(3);
DEFINE vfechaparam DATETIME YEAR TO FRACTION(5);



	ON EXCEPTION SET iSqlErr
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
		END IF;
		
        LET cCodret = iSqlErr;
		LET cVarDataErr = 'ERROR NO CONTROLADO: '||vfechaconciliacion||'-'||vnumtarjeta||'-'||vautorizacion;
        RETURN cCodret, cVarDataErr;
  
	END EXCEPTION;

	--Set debug file to "/informix/analy/sp_trans_his_movimientos_diario.sql";
	--trace on;

	/*----------CALCULA LA FECHA----------------*/

	SET ISOLATION TO DIRTY READ;
	SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:"informix".si_fechas; 
	
	select valor into vparam from bditarjeta:td_param_conciliacion_concreing WHERE codigo='408';
	
	let vfechaparam = vfecha_hoy;
	let vfechaparam = vfecha_hoy - vparam units DAY;
    let vfechaparam= SUBSTRING(vfechaparam FROM  1 FOR 10) || ' 00:00:00';	
	
	----------------------------------------------------
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	LET viContadorRegistros2 = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	FOREACH WITH HOLD 
			
		SELECT autorizacion,numtarjeta,fechaconciliacion
		INTO vautorizacion,vnumtarjeta,vfechaconciliacion
		FROM intercard:conciliacion_atm_stat06 
		WHERE fechaconciliacion <= vfechaparam
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		INSERT INTO intercard:conciliacion_atm_stat06_his (
		keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
		secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
		pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify)
		SELECT 
		keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
		secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
		pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify
		FROM intercard:conciliacion_atm_stat06 where fechaconciliacion = vfechaconciliacion and numtarjeta = vnumtarjeta and autorizacion = vautorizacion ;
		
		DELETE FROM intercard:conciliacion_atm_stat06 where fechaconciliacion = vfechaconciliacion and numtarjeta = vnumtarjeta and autorizacion = vautorizacion ;

		LET viContadorRegistros = viContadorRegistros + 1;
		LET viContadorRegistros2 = viContadorRegistros2 + 1;
		
		--SE APLICA update statistics medium A LA TABLA.
		IF (viContadorRegistros = 100000) THEN --VERIFICA SI EL BLOKE 2 ALCANSO LA CONDICION PARA REALIZAR EL update statistics
			update statistics medium for table intercard:"informix".conciliacion_atm_stat06;
			LET viContadorRegistros2 = 0;
			CONTINUE FOREACH;
		END IF;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;

	END FOREACH ;

		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
	
	LET cCodret = '00000';
	LET cVarDataErr = 'PROCESO DE TRANSFERENCIA EXITOSO' ;
		
RETURN cCodret,cVarDataErr;
END PROCEDURE;