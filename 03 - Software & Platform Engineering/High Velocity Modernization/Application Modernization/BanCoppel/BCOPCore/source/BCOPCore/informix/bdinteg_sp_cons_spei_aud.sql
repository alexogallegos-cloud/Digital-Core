CREATE PROCEDURE "informix".sp_cons_spei_aud(pTipo INTEGER,
														pFechaIni CHAR(10),
														pFechaFin CHAR(10),
														pEmpresa CHAR(3),
														pSucursal CHAR(4),
														pCodigo CHAR(4),
														pUsuario CHAR(8),
														pSkip INTEGER,
														pLimite INTEGER) 
	RETURNING CHAR(5)  AS CodRet,
			  CHAR(20) AS Cliente,
			  CHAR(16) AS Folio,
			  CHAR(10) AS Fecha,
			  CHAR(20) AS Cuenta,
			  CHAR(17) AS Monto,
			  CHAR(12) AS Hora,
			  CHAR(4)  AS Sucursal,
			  CHAR(17) AS Saldo,
			  CHAR(4)  AS Transaccion,
			  CHAR(40)  AS Referencia,
			  CHAR(4) AS Trans_Suc,
			  INTEGER  AS TotRows;
			  
			
--Definicion de Variables
DEFINE cCodRet				CHAR(5);
DEFINE cCliente				CHAR(20);
DEFINE cFolio				CHAR(16);
DEFINE cHora				CHAR(12);
DEFINE cCuenta				CHAR(20);
DEFINE cUsuario				CHAR(8);
DEFINE cMonto				CHAR(17);
DEFINE cTransaccion			CHAR(4);
DEFINE cSaldo				CHAR(17);
DEFINE cSucursal			CHAR(4);
DEFINE cTransacSuc			CHAR(4);
DEFINE cReferencia			CHAR(40);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE dFecha				DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iSqlErr 				INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE iFechAnio 			INTEGER;
DEFINE iLinea				INTEGER;
DEFINE dFechaActual			DATE;


LET cCodRet 				= "00000";
LET cCliente 				= "";
LET cFolio 					= "";
LET cHora 					= "";
LET cCuenta 				= "";
LET cUsuario 				= "";
LET cMonto 					= "";
LET cTransaccion 			= "";
LET cSaldo 					= "";
LET cSucursal 				= "";
LET cTransacSuc 			= "";
LET cReferencia 			= "";
LET dFechaIni 				= DATE(1);
LET dFechaFin 				= DATE(1);
LET dFechaHoy 				= DATE(1);
LET dFechaParaMovhisOld		= DATE(1);
LET dFechaParaMovhisOld2 	= DATE(1);
LET dFecha					= DATE(1);
LET iFechAnio 				= 0;
LET iLinea 					= 0;
LET cFechaParaMovhisOld 	= "";
LET cFechaParaMovhisOld2 	= "";
LET cFechaIni 				= "";
LET cFechaFin 				= "";
LET cDia 					= "";
LET cMes 					= "";
LET cAnio 					= "";
LET iTotalRows 				= 0;
LET dFechaActual            = DATE(1);

 
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Movimientos SPEI" desde la tabla si_rptcaja_aud                                  /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 27/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

--SET DEBUG FILE TO '/informix/sp_cons_spei_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			
			LET cCliente 				= "";
			LET cFolio 					= "";
			LET cHora 					= "";
			LET cCuenta 				= "";
			LET cUsuario 				= "";
			LET cMonto 					= "";
			LET cTransaccion 			= "";
			LET cSaldo 					= "";
			LET cSucursal 				= "";
			LET cTransacSuc 			= "";
			LET cReferencia 			= "";
			LET dFecha					= "";
			LET iTotalRows 				= 0;
			RETURN cCodRet,cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
			
		END IF;
	END EXCEPTION;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
			LET cFechaIni = pFechaIni;
			LET cDia = SUBSTRING(cFechaIni FROM 1 FOR 2);
			LET cMes =  SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
			LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
			LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

			LET cFechaFin = pFechaFin;
			LET cDia = SUBSTRING(cFechaFin FROM 1 FOR 2);
			LET cMes =  SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
			LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
			LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
			
			SELECT DISTINCT(COUNT(folio))
			INTO iTotalRows
			FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND cod_transacc  IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
			AND fecha BETWEEN dFechaIni AND dFechaFin
			AND reversado <> 'S';
		
			FOREACH
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT  cliente,folio,fecha,cuenta,monto,hora,transaccion,saldo, sucursal, transacc_suc, referencia
				INTO cCliente,cFolio,dFecha,cCuenta,cMonto,cHora, cTransaccion,cSaldo, cSucursal, cTransacSuc, cReferencia
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000'; --Sin Errores
				
				RETURN cCodRet,cCliente, cFolio, dFecha,cCuenta, cMonto, cHora, cSucursal,cSaldo,cTransaccion,cReferencia, cTransacSuc, iTotalRows WITH RESUME;
			END FOREACH;	
			
				LET pSkip = pSkip + pLimite ;
			
END
END PROCEDURE;