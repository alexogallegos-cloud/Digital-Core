CREATE PROCEDURE "informix".sp_credisol_envia_sms_invitacionpf(pEmpresa CHAR(3))
RETURNING CHAR(5);       -- Codigo de Retorno


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
	DEFINE cCod_retIB			CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE cProceso             CHAR(4);
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumCredito          CHAR(20);
	DEFINE iRowID				INTEGER;	
	DEFINE cFolioCompra			CHAR(16);
	DEFINE cNumCel				CHAR(20);
	DEFINE sStatus_sms			SMALLINT;
	DEFINE dMonto_compra		DECIMAL(18,2);
	


	-------------------
	---INICIALIZACIONES
	
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cCod_retIB			= '';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cProceso			= '0094';	
	LET dtFechaHoy			= DATE(1);
	LET cNumCredito			= '';
	LET iRowID				= 0;
	LET cFolioCompra		= '';
	LET cNumCel				= '';
	LET sStatus_sms			= 0;
	LET	dMonto_compra		= 0;
	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||iIsamErr::CHAR||cNumCredito, '02') Returning cCod_retIB;
			RETURN cCodRet;
       END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/tmp/sp_credisol_envia_sms_invitacionpf.out';
	--TRACE ON;
	
	--Se obtiene la fecha de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = pEmpresa;
	
	--=====================================================================================================================
	-- Identifica registros de compras para procesar y enviar invitacion para contratar Pagos Fijos SMS.
		
	FOREACH WITH HOLD
		SELECT {+INDEX (sd_promocion_credito_sms inx_smspftpsms)}
		 ROWID,  num_credito, folio_compra_sms, mnto_compra, 	 tipo_sms
		  INTO iRowID, cNumCredito, cFolioCompra, 	  dMonto_compra, sStatus_sms
		  FROM bdicred:sd_promocion_credito_sms
		 WHERE tipo_sms = '0'
		 ORDER BY fecha_insert ASC
		 
							
		EXECUTE PROCEDURE "informix".sp_credisol_contrata_x_sms(pEmpresa, 1, cNumCredito, cFolioCompra, dMonto_compra) INTO cCod_retIB;
		
	  
	END FOREACH;

	LET cCodRet = '00000';
	LET cMensajeRet = '';

	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Martha A Hdz 																																	',
'DESCRIPCION: SP que identifica las compras realizadas por el cliente, las cuales son candidatas para enviar invitacion para contratar Pagos Fijos SMS	',
'			  tipo_sms = 0, registros con invitacion pendiente proyectar y de enviar																	',
'FECHA DE CREACION:  Agosto 2018 																														',
'BD: bdicred																																			';

CREATE PROCEDURE "informix".sp_calculo_tiir( 
	montoDisposicion 	DECIMAL(18,2),
	pago_mensual 		DECIMAL(18,2),
	numeroPeriodos 		INTEGER,
	numeroPagosPeriodos INTEGER,
	comision  			DECIMAL(18,2),
	comision_gc  		DECIMAL(18,2),
	anualidad  			DECIMAL(18,2),
	tasa_prom_pond  	DECIMAL(18,2)
)

RETURNING CHAR(6)  		AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,	
		  DECIMAL(18,2) AS cat; 
		   
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);

DEFINE vCATMin          DECIMAL(18,2);
DEFINE vCAT            	DECIMAL(21,10);
DEFINE vCATFin			DECIMAL(21,10);
DEFINE vCATMax          DECIMAL(21,10);
DEFINE vPrecision       DECIMAL(18,2);
DEFINE vPrecisionAux    DECIMAL(18,2);
DEFINE vPrecisionAux2   DECIMAL(18,2);
DEFINE vCiclado         INTEGER;
--DEFINE iNumPago         INTEGER;

DEFINE vPagoSum         DECIMAL(18,2);
DEFINE vDispSum         DECIMAL(18,2);
DEFINE vPlazo           DECIMAL(18,2); 
DEFINE vCATx            DECIMAL(21,10);
DEFINE vCATy            DECIMAL(32,10);
DEFINE vCATz            DECIMAL(21,10);

DEFINE vCatFinal		DECIMAL(21,1);
DEFINE vDispCosto       DECIMAL(18,2);
DEFINE vPagoCosto       DECIMAL(18,2);
DEFINE pago_mensualAux	DECIMAL(18,2);
DEFINE disp_mensualAux	DECIMAL(18,2);
DEFINE int_mensualAux	DECIMAL(18,6);
DEFINE tasa_mensual		DECIMAL(18,6);

DEFINE iContador      	INTEGER;
DEFINE iNumPagos      	INTEGER;
DEFINE iBanPrecision	INTEGER;

DEFINE SaldoInicio		DECIMAL(18,2);
DEFINE SaldoFin			DECIMAL(18,2);

---INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";
LET cMensajeRet     = "Se realizó el cálculo correctamente";

LET vCATMin 		= 0;	
LET vCAT 			= 10;
LET vCATFin 		= 1;
LET vCATMax 		= 100;
LET vPrecision 		= 1;
LET vPrecisionAux 	= 1;
LET vPrecisionAux2 	= 1;
LET vCiclado 		= 1;
--LET iNumPago 		= 0;

LET vPagoSum 		= 0;
LET vPlazo 			= 0;
LET vCATx 			= 0;
LET vCATy 			= 0;
LET vCATz 			= 0;
LET vDispCosto		= 0;
LET vPagoCosto 		= 0;
LET pago_mensualAux	= 0;
LET disp_mensualAux	= 0;
LET int_mensualAux	= 0;
LET tasa_mensual 	= ((tasa_prom_pond / 36000) * 30);


--LET iContador 		= 1;
--LET iNumPagos 		= 1;
LET iContador 		= 0;
LET iNumPagos 		= 0;
LET vCatFinal 		= 0;
LET iBanPrecision 	= 0;

LET SaldoInicio		= 0;
LET SaldoFin		= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCAT,0);
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO '/informix/jesus/sp_calculo_tiir.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--LET pago_mensualAux = pago_mensual;

	WHILE (ABS(vPrecision) * 1000) > 1
		LET vPagoSum = 0;
		LET vDispSum = 0;
		--LET vPlazo = 1;

		--LET pago_mensualAux = pago_mensual *12 ;
		WHILE iContador <= numeroPeriodos
		
			IF iContador = 0 THEN
				LET SaldoInicio = 0;
				LET int_mensualAux = 0;
				LET SaldoFin = 0;
				LET pago_mensualAux = 0;
				LET disp_mensualAux = montoDisposicion;
				
			ELIF iContador = 1 AND (anualidad + comision_gc + comision) > 0 THEN
		  
				LET SaldoInicio = SaldoFin - pago_mensualAux + disp_mensualAux;
				LET int_mensualAux = SaldoInicio * tasa_mensual;
				LET SaldoFin = SaldoInicio + int_mensualAux + comision_gc + anualidad + comision;
				LET pago_mensualAux = SaldoFin * (pago_mensual / 100);
				-- disp_mensualAux = IIf(montoDisposicion < (SaldoFin - pago_mensualAux), 0, (montoDisposicion - SaldoFin + pago_mensualAux))
				IF montoDisposicion < (SaldoFin - pago_mensualAux) THEN
					LET disp_mensualAux = 0;
				ELSE 
					LET disp_mensualAux = (montoDisposicion - SaldoFin + pago_mensualAux);
				END IF;
			ELIF (iContador = 13 OR iContador = 25) AND anualidad > 0 THEN
				LET SaldoInicio = SaldoFin - pago_mensualAux + disp_mensualAux;
				LET int_mensualAux = SaldoInicio * tasa_mensual;
				LET SaldoFin = SaldoInicio + int_mensualAux + anualidad;
				LET pago_mensualAux = SaldoFin * (pago_mensual / 100);
				--disp_mensualAux = IIf(montoDisposicion < (SaldoFin - pago_mensualAux), 0, (montoDisposicion - SaldoFin + pago_mensualAux))
				IF montoDisposicion < (SaldoFin - pago_mensualAux) THEN
					LET disp_mensualAux = 0;
				ELSE
					LET disp_mensualAux = (montoDisposicion - SaldoFin + pago_mensualAux);
				END IF;
			ELSE 
				LET SaldoInicio = SaldoFin - pago_mensualAux + disp_mensualAux;
				LET int_mensualAux = SaldoInicio * tasa_mensual;
				--Saldo del Período + Intereses + Comisiones
				LET SaldoFin = SaldoInicio + int_mensualAux;
				IF iContador = numeroPeriodos THEN
					LET pago_mensualAux = montoDisposicion + int_mensualAux;
					LET disp_mensualAux = 0;
				ELSE 
					--Pago Mes
					LET pago_mensualAux = SaldoFin * (pago_mensual / 100);
					--disp_mensualAux = IIf(montoDisposicion < (SaldoFin - pago_mensualAux), 0, (montoDisposicion - SaldoFin + pago_mensualAux))
					IF montoDisposicion < (SaldoFin - pago_mensualAux) THEN
						LET disp_mensualAux = 0;
					ELSE
						LET disp_mensualAux = (montoDisposicion - SaldoFin + pago_mensualAux);
					END IF;
				END IF;
			END IF;
			--'Debug.Print iContador, SaldoInicio, int_mensualAux, SaldoFin, pago_mensualAux, disp_mensualAux
			LET vCATx = (1 + (vCAT / 100));
			LET vCATy = iNumPagos;
			--vCATz = vCATx ^ (vCATy / 12)
			LET vCATz = pow(vCATx, (vCATy / 12));
			
			LET vDispCosto = disp_mensualAux / vCATz;
			LET vPagoCosto = pago_mensualAux / vCATz;
			--'Debug.Print vDispCosto, vPagoCosto
			LET vPagoSum = vPagoSum + vPagoCosto;
			LET vDispSum = vDispSum + vDispCosto;			
				
			LET iContador = iContador + 1;
			LET iNumPagos = iNumPagos + 1;

		END WHILE;
		
		--LET vPrecision = (montoDisposicion - comision) - vPagoSum;
		LET vPrecision = vDispSum - vPagoSum;
		
		IF vPrecision < 0 THEN
			LET vCATMin = vCAT;
			LET vCAT = (vCATMax + vCAT) / 2;
		ELIF vPrecision > 0 THEN
			LET vCATMax = vCAT;
			LET vCAT = (vCATMin + vCAT) / 2;
		END IF;

		IF vCiclado > 300 THEN
			LET vPrecisionAux2 = vPrecision;	
			LET vPrecision = 0;	
			LET iBanPrecision = 1;
		ELSE 
			LET vPrecisionAux = vPrecision;
		END IF;
			 		
		LET iContador = 0;
		LET iNumPagos = 0;
		LET vCiclado = vCiclado + 1;
	
	END WHILE;

	IF (vPrecisionAux2 <> vPrecisionAux) AND iBanPrecision = 1 THEN
		LET vCAT = 0;
	END IF

	LET vCATFin = vCAT; 
	--vCATFinal = (((1 + (vCAT / 10)) ^ 12) - 1) * 100
	--LET vCatFinal = ( pow(1 + (vCAT/10),12) - 1 ) * 100;
	LET vCatFinal =  ((pow((1 + (vCAT/10)),12)) - 1) * 100;
	
	
	--RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(vCatFinal,0);
	RETURN NVL(cCodRet,''), NVL(cMensajeRet,''), NVL(round(vCAT,2),0);

END
END PROCEDURE;