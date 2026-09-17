CREATE PROCEDURE "informix".sp_cons_bts_aud(pTipo INTEGER,
											pFechaIni CHAR(10),
											pFechaFin CHAR(10),
											pEmpresa CHAR(3),
											pSucursal CHAR(4),
											pCodigo CHAR(4),
											pUsuario CHAR(8),
											pSkip INTEGER,
											pLimite INTEGER)  
RETURNING 
		  CHAR(5)  AS CodRet,
		  CHAR(10) AS Fecha,
		  CHAR(12) AS Hora,
		  CHAR(16) AS Folio,
		  CHAR(8) AS Usuario,
		  CHAR(4) AS Sucursal,
		  CHAR(17) AS Importe,
		  CHAR(4) AS Transaccion,
		  CHAR(20) AS Clave_de_Confirmacion,
		  CHAR(104) AS Beneficiario,
		  CHAR(25) AS Identificacion,
		  CHAR(25) AS Folio_Identificacion,
		  CHAR(45) AS Forma_de_Pago,
		  CHAR(20) AS Cuenta,
		  CHAR(4) AS Trans_Suc,
		  INTEGER  AS TotRows;
			
--Definicion de Variables
DEFINE cCodRet				CHAR(5);
DEFINE cHora				CHAR(12);
DEFINE cFolio				CHAR(16);
DEFINE cUsuario				CHAR(8);
DEFINE cSucursal			CHAR(4);
DEFINE cImporte				CHAR(17);
DEFINE cTransaccion			CHAR(4);
DEFINE cCveConfirm			CHAR(20);
DEFINE cBeneficiario 		CHAR(104);
DEFINE cIdentificacion 		CHAR(25);
DEFINE cFolioIdentificacion	CHAR(25);
DEFINE cFormaPago			CHAR(45);
DEFINE cCuenta				CHAR(20);
DEFINE cTransacSuc			CHAR(4);
DEFINE dFecha				DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iFechAnio 			INTEGER;
DEFINE iLinea				INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE iSqlErr 				INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFechaActual			DATE;


LET cCodRet 				= "";
LET dFecha 					= DATE(1);
LET cHora 					= "";
LET cFolio 					= "";
LET cUsuario 				= "";
LET cSucursal 				= "";
LET cImporte 				= "";
LET cTransaccion 			= "";
LET cCveConfirm 			= "";
LET cBeneficiario 			= "";
LET cIdentificacion 		= "";
LET cFolioIdentificacion 	= "";
LET cFormaPago 				= "";
LET cCuenta 				= "";
LET cTransacSuc 			= "";
LET dFechaIni 				= DATE(1);
LET dFechaFin 				= DATE(1);
LET dFechaHoy 				= DATE(1);
LET dFechaParaMovhisOld 	= DATE(1);
LET dFechaParaMovhisOld2 	= DATE(1);
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
/ del reporte de "Remesas BTS" desde la tabla si_rptcaja_aud                                       /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 26/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*-------------------------------------------------------------------------------------------------*/

--SET DEBUG FILE TO '/tmp/sp_cons_bts_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND usuario = pUsuario
			AND cod_transacc = pCodigo;
			--AND fecha_inicio = dFechaIni 
			--AND fecha_fin = dFechaFin;
			
			LET dFecha 					= "";
			LET cHora 					= "";
			LET cFolio 					= "";
			LET cUsuario 				= "";
			LET cSucursal 				= "";
			LET cImporte 				= "";
			LET cTransaccion 			= "";
			LET cCveConfirm 			= "";
			LET cBeneficiario 			= "";
			LET cIdentificacion 		= "";
			LET cFolioIdentificacion 	= "";
			LET cFormaPago 				= "";
			LET cCuenta 				= "";
			LET cTransacSuc 			= "";
			LET iTotalRows 				= 0;
			
			RETURN cCodRet,dFecha,cHora,cFolio,cUsuario,cSucursal, cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc,iTotalRows;
			
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
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S';
				FOREACH
				
					SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,transaccion,clave_confir, beneficiario, identificacion, folio_identif, trim(referencia),cuenta,transacc_suc
					INTO dFecha,cHora,cFolio,cUsuario, cSucursal,cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc
					FROM bdinteg:"informix".si_rptcaja_aud
					WHERE empresa = pEmpresa
					AND sucursal = pSucursal
					AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
					AND fecha BETWEEN dFechaIni AND dFechaFin
					AND reversado <> 'S'
					ORDER BY fecha,hora ASC
					
					LET cCodRet = '00000'; --Sin Errores
					
					RETURN cCodRet,dFecha,cHora,cFolio,cUsuario,cSucursal, cImporte,cTransaccion,cCveConfirm,cBeneficiario,cIdentificacion,cFolioIdentificacion,cFormaPago,cCuenta,cTransacSuc, iTotalRows WITH RESUME;
					
				END FOREACH;
			
			LET pSkip = pSkip + pLimite ;
			
END
END PROCEDURE;