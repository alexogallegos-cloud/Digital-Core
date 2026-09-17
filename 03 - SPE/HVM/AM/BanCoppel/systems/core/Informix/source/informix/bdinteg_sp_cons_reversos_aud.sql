CREATE PROCEDURE "informix".sp_cons_reversos_aud(pTipo INTEGER, pFechInicial CHAR(10), pFechFinal CHAR(10), pEmpresa CHAR(3),pSucursal CHAR(4), pCodigo CHAR(4), pUsuario CHAR(8), pSkip INTEGER, pLimite INTEGER)

	RETURNING CHAR(5) AS CodError,
			  CHAR(20) AS No_Cliente,
			  CHAR(16) AS Folio,
			  CHAR(8) AS Usuario,			  
			  CHAR(10) AS Fecha,
			  CHAR(12) AS Hora,
			  CHAR(20) AS Cuenta,
			  CHAR(18) AS Monto,
			  CHAR(4) AS Transaccion,
			  CHAR(18) AS Saldo,
			  CHAR(4) AS Sucursal,
			  CHAR(4) AS Trans_Suc,			  
			  CHAR(40) AS Referencia,
			  CHAR(20) AS Tarjeta,
			  INTEGER  AS TotRows;
			   
			  
--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodError CHAR(5);
DEFINE cCliente CHAR(20);
DEFINE cFolio CHAR(16);
DEFINE cUsuario CHAR(8);
DEFINE cFecha CHAR(10);
DEFINE cHora CHAR(12);
DEFINE cCuenta CHAR(20);
DEFINE cMonto CHAR(18);
DEFINE cTransaccion CHAR(4);
DEFINE cSaldo CHAR(18);
DEFINE cSucursal CHAR(4);
DEFINE cTrans_Suc CHAR(4);
DEFINE cReferencia CHAR(40);
DEFINE cTarjeta CHAR(20);
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
DEFINE dFechaActual	DATE;

DEFINE iLinea INTEGER;

DEFINE VJMP CHAR(4);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodError = "00000";
LET cCliente = "";
LET cFolio = "";
LET cUsuario = "";
LET cFecha = "";
LET cHora = "";
LET cCuenta = "";
LET cMonto = "";
LET cTransaccion = "";
LET cSaldo = "";
LET cSucursal = "";
LET cTrans_Suc = "";
LET cReferencia = "";
LET cTarjeta = "";
LET iTotalRows = 0;

--Para "Fechas"
LET dFechaIni = DATE(1);
LET dFechaFin = DATE(1);
LET dFechaHoy = DATE(1);
LET dFechaMovhisOld = DATE(1);
LET dFechaMovhisOld2 = DATE(1);
LET cFechaIni = "";
LET cFechaFin = "";
LET iTotalDias = 0;
LET cFechaMovhisOld = "";
LET cFechaMovhisOld2 = "";
LET cDia = "";
LET cMes = "";
LET cAnio = "";
LET dFecha = DATE(1);
LET dFechaActual = DATE(1);

LET iLinea = 0;
LET VJMP = "";

/*----------------*----------------*----------------*----------------*----------------*--------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación          /
/ del reporte de "Reversos débito, reversos crédito y pagos reversados" desde la tabla si_rptcaja_aud/                                       /
/ Elaborado por: Adilene Lara                                                                        /
/ Fecha: 26/11/2014                                                                                  /
/ Solicitado por: Norberto Corona                                                                    /
*---------------------------------------------------------------------------------------------------*/

--SET DEBUG FILE TO '/tmp/sp_cons_reversos_aud.out';
--TRACE ON;

--SET DEBUG FILE TO "/informix/VJMP/sp_reversos"||"_"||""||TRIM(pSucursal)||""||".out"; --> TRACE DESDE APP217
 --  TRACE ON;



BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodError = iSqlErr;
			LET cCliente = '';
			LET cFolio = '';
			LET cUsuario = '';
			LET cCuenta = '';
			LET cFecha = '';
			LET cHora = '';
			LET cCuenta = '';
			LET cMonto = '';
			LET cTransaccion = '';
			LET cSaldo = '';
			LET cSucursal = '';
			LET cTrans_Suc = '';
			LET cReferencia = '';
			LET cTarjeta = ''; 
			RETURN cCodError,cCliente,cFolio,cUsuario,cFecha,cHora,cCuenta,cMonto,cTransaccion,cSaldo,cSucursal,cTrans_Suc,cReferencia,cTarjeta,iTotalRows;

		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
		
		IF pCodigo = '0009' THEN --SE AGREGA CONDICIÓN PARA QUE REVERSOS DÉBITO MANEJE EN SU FILTRO EL CAMPO DE FOLIO_OPER
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
			
			LET VJMP = pCodigo;
			
			SELECT DISTINCT(COUNT(folio))
			INTO iTotalRows
			FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND folio_oper IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
			AND fecha BETWEEN dFechaIni AND dFechaFin
			AND reversado = 'S';
			
			FOREACH			
				SELECT SKIP pSkip LIMIT  pLimite DISTINCT cliente,folio,usuario,fecha,hora,cuenta,monto,transaccion,saldo,sucursal,transacc_suc,referencia,tarjeta
				INTO cCliente,cFolio,cUsuario,cFecha,cHora,cCuenta,cMonto,cTransaccion,cSaldo,cSucursal,cTrans_Suc,cReferencia,cTarjeta
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND folio_oper IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado = 'S'	
				ORDER BY fecha, hora ASC
							
				RETURN cCodError,cCliente,cFolio,cUsuario,cFecha,cHora,cCuenta,cMonto,cTransaccion,cSaldo,cSucursal,cTrans_Suc,cReferencia,cTarjeta,iTotalRows WITH RESUME;				
			END FOREACH;	
			
			LET pSkip = pSkip + pLimite ;
		ELSE
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
			
			LET VJMP = pCodigo;
			
			SELECT DISTINCT(COUNT(folio))
			INTO iTotalRows
			FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
			AND fecha BETWEEN dFechaIni AND dFechaFin
			AND reversado = 'S';
			
			FOREACH			
				SELECT SKIP pSkip LIMIT  pLimite DISTINCT cliente,folio,usuario,fecha,hora,cuenta,monto,transaccion,saldo,sucursal,transacc_suc,referencia,tarjeta
				INTO cCliente,cFolio,cUsuario,cFecha,cHora,cCuenta,cMonto,cTransaccion,cSaldo,cSucursal,cTrans_Suc,cReferencia,cTarjeta
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado = 'S'	
				ORDER BY fecha, hora ASC
							
				RETURN cCodError,cCliente,cFolio,cUsuario,cFecha,cHora,cCuenta,cMonto,cTransaccion,cSaldo,cSucursal,cTrans_Suc,cReferencia,cTarjeta,iTotalRows WITH RESUME;				
			END FOREACH;	
			
			LET pSkip = pSkip + pLimite ;
		END IF
	
END
END PROCEDURE;