CREATE PROCEDURE "informix".sp_cons_orden_pago_aud(pTipo INTEGER, pFechInicial CHAR(10), pFechFinal CHAR(10), pEmpresa CHAR(3), pSucursal CHAR(4),pCodigo CHAR(4), pUsuario CHAR(8), pSkip INTEGER, pLimite INTEGER)											  

	RETURNING CHAR(5) AS CodError,
			  CHAR(10) AS Fecha,
			  CHAR(12) AS Hora,
			  CHAR(16) AS Folio,
			  CHAR(8) AS Usuario,			  
			  CHAR(4) AS Sucursal,
			  CHAR(14) AS Importe,
			  CHAR(4) AS Transaccion,
			  CHAR(20) AS No_de_Orden,			  
			  CHAR(105) AS Beneficiario,
			  CHAR(2) AS Identificacion,
			  CHAR(25) AS Folio_Identificacion,  
			  CHAR(15) AS Forma_de_Pago,
			  CHAR(12) AS Cuenta, 
			  CHAR(4) AS Trans_Suc,
			  INTEGER  AS TotRows;
			   
			  
--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodError CHAR(5);
DEFINE cFecha CHAR(10);
DEFINE cHora CHAR(12);
DEFINE cFolio CHAR(16);
DEFINE cUsuario CHAR(8);
DEFINE cSucursal CHAR(4);
DEFINE cImporte CHAR(14);
DEFINE cTransaccion CHAR(4);
DEFINE cNumOrden CHAR(20);
DEFINE cBeneficiario CHAR(105);
DEFINE cIdentificacion CHAR(2);
DEFINE cFolioIdent CHAR(25);
DEFINE cFormaPago CHAR(15);
DEFINE cCuenta CHAR(12); 
DEFINE cTransacSuc CHAR(4);
DEFINE iTotalRows INTEGER;

--Para "Fechas"
DEFINE dFechaIni DATE;
DEFINE dFechaFin DATE;
DEFINE dFechaHoy DATE;
DEFINE dFechaMovhisOld DATE;
DEFINE dFechaMovhisOld2 DATE;
DEFINE cFechaIni CHAR(10);
DEFINE cFechaFin CHAR(10);
DEFINE cFechaMovhisOld CHAR(10);
DEFINE cFechaMovhisOld2 CHAR(10);
DEFINE iTotalDias INTEGER;
DEFINE cDia	CHAR(2);
DEFINE cMes	CHAR(2);
DEFINE cAnio CHAR(4);
DEFINE dFecha DATE;

DEFINE iLinea INTEGER;
DEFINE dFechaActual			DATE;

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodError = "00000";
LET cFecha = "";
LET cHora = "";
LET cFolio = "";
LET cUsuario = "";
LET cSucursal = "";
LET cImporte = "";
LET cTransaccion = "";
LET cNumOrden = "";
LET cBeneficiario = "";
LET cIdentificacion = "";
LET cFolioIdent = "";
LET cFormaPago = "";
LET cCuenta = ""; 
LET cTransacSuc = "";
LET iTotalRows = 0;

--Para "Fechas"
LET dFechaIni = DATE(1);
LET dFechaFin = DATE(1);
LET dFechaHoy = DATE(1);
LET dFechaMovhisOld = DATE(1);
LET dFechaMovhisOld2 = DATE(1);
LET cFechaIni = "";
LET cFechaFin = "";
LET cFechaMovhisOld = "";
LET cFechaMovhisOld2 = "";
LET iTotalDias = 0;
LET cDia = "";
LET cMes = "";
LET cAnio = "";
LET dFecha = DATE(1);

LET iLinea = 0;
LET dFechaActual = DATE(1);
 
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Orden de pago" desde la tabla si_rptcaja_aud                                     /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 26/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

--SET DEBUG FILE TO '/tmp/sp_cons_orden_pago_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodError = iSqlErr;
			LET cFecha = '';
			LET cHora = '';
			LET cFolio = '';
			LET cUsuario = '';
			LET cSucursal = '';
			LET cImporte = '';
			LET cTransaccion = '';
			LET cNumOrden = '';
			LET cBeneficiario = '';
			LET cIdentificacion = '';
			LET cFolioIdent = '';
			LET cFormaPago = '';
			LET cCuenta = '';
			LET cTransacSuc = ''; 
			RETURN cCodError,cFecha,cHora,cFolio,cUsuario,cSucursal,cImporte,cTransaccion,cNumOrden,cBeneficiario,cIdentificacion,cFolioIdent,cFormaPago,cCuenta,cTransacSuc,iTotalRows;
			
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
			LET cFechaIni = pFechInicial;
			LET cDia = SUBSTRING(cFechaIni FROM 1 FOR 2);
			LET cMes =  SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
			LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
			LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

			LET cFechaFin = pFechFinal;
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
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,transaccion,num_orden,beneficiario,identificacion,folio_identif,referencia,cuenta,transacc_suc
				INTO cFecha,cHora,cFolio,cUsuario,cSucursal,cImporte,cTransaccion,cNumOrden,cBeneficiario,cIdentificacion,cFolioIdent,cFormaPago,cCuenta,cTransacSuc
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc  IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S'
				ORDER BY fecha, hora ASC
				
				LET cCodError = '00000';
				
				RETURN cCodError,cFecha,cHora,cFolio,cUsuario,cSucursal,cImporte,cTransaccion,cNumOrden,cBeneficiario,cIdentificacion,cFolioIdent,cFormaPago,cCuenta,cTransacSuc,iTotalRows WITH RESUME;
			END FOREACH;
			
			LET pSkip = pSkip + pLimite ;
		
END
END PROCEDURE;