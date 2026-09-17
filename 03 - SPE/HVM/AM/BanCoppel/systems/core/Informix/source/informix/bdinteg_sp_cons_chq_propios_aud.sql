CREATE PROCEDURE "informix".sp_cons_chq_propios_aud(pTipo     INTEGER,
													pFechaIni CHAR(10),
													pFechaFin CHAR(10),
													pEmpresa  CHAR(3),
													pSucursal CHAR(4),
													pCodigo   CHAR(4),
													pUsuario  CHAR(8),
													pSkip     INTEGER,
													pLimite   INTEGER)
	
RETURNING CHAR(5)   AS  CodRet,
		  CHAR(20)  AS  Cliente,
		  CHAR(16)  AS	Folio,
		  CHAR(10)	AS	Fecha,
		  CHAR(20)	AS	Cuenta,
		  CHAR(17)  AS 	Monto,
		  CHAR(12)  AS 	Hora,
		  CHAR(8)	AS	Usuario,
		  CHAR(4)	AS	Transaccion,
		  CHAR(17)  AS	Saldo,
		  CHAR(4)   AS	Sucursal,
		  CHAR(11)  AS	Cheque,
		  CHAR(4)   AS	Trans_Suc,
		  CHAR(16)  AS	Tarjeta,
		  INTEGER   AS  TotRows;
			 

DEFINE cCodRet				CHAR(5);
DEFINE cCliente             CHAR(20);
DEFINE cFolio               CHAR(16);
DEFINE cFecha               CHAR(10);
DEFINE cCuenta              CHAR(20);
DEFINE cMonto               CHAR(17);
DEFINE cHora                CHAR(12);
DEFINE cUsuario             CHAR(8);
DEFINE cTransaccion         CHAR(4);
DEFINE cSaldo               CHAR(17);
DEFINE cSucursal            CHAR (4);
DEFINE cCheque              CHAR(11);
DEFINE cTrans_Suc           CHAR(4);
DEFINE cTarjeta             CHAR(16); 
DEFINE iSqlErr              INTEGER;
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iRango    			INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iLinea 	            INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFecha               DATE;
DEFINE dFechaActual			DATE;


LET cCodRet 			 = '';
LET cCliente             = ''; 
LET cFolio               = '';
LET cFecha               = '';
LET cCuenta              = '';
LET cMonto               = '';
LET cHora                = '';
LET cUsuario             = '';
LET cTransaccion         = '';
LET cSaldo               = '';
LET cSucursal            = '';
LET cCheque              = '';
LET cTrans_Suc           = '';
LET cTarjeta             = '';
LET dFechaIni 			 = DATE(1);
LET dFechaFin 			 = DATE(1);
LET dFechaHoy 			 = DATE(1);
LET dFechaParaMovhisOld	 = DATE(1);
LET dFechaParaMovhisOld2 = DATE(1);
LET iRango 		         = 0;
LET cFechaParaMovhisOld  = '';
LET cFechaParaMovhisOld2 = '';
LET cFechaIni 			 = '';
LET cFechaFin 			 = '';
LET cDia 				 = '';
LET cMes 				 = '';
LET cAnio 				 = '';
LET iLinea               = 0;
LET iTotalRows 			 = 0;
LET dFecha               = DATE(1);
LET dFechaActual         = DATE(1);

/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Cheques propios" desde la tabla si_rptcaja_aud                                   /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 24/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/
	

--SET DEBUG FILE TO '/informix/sp_cons_chq_propios_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
				LET cCodRet  = iSqlErr;
				LET cCliente      = ''; 
				LET cFolio        = '';
				LET cFecha        = '';
				LET cCuenta       = '';
				LET cMonto        = '';
				LET cHora         = '';
				LET cUsuario      = '';
				LET cTransaccion  = '';
				LET cSaldo        = '';
				LET cSucursal     = '';
				LET cCheque       = '';
				LET cTrans_Suc    = '';
				LET cTarjeta      = '';
				LET dFecha        = '';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta,iTotalRows;
			
		END IF;
	END EXCEPTION;
	    		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

				LET cFechaIni = pFechaIni;
				LET cDia  = SUBSTRING(cFechaIni FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
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
				AND sucursal  = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S';			
		
			FOREACH
				SELECT SKIP pSkip LIMIT pLimite DISTINCT cliente,folio,fecha,cuenta,monto,hora,usuario,transaccion,saldo,sucursal,cheque,transacc_suc,tarjeta
				INTO cCliente,cFolio,cFecha,cCuenta,cMonto,cHora,cUsuario,cTransaccion,cSaldo,cSucursal,cCheque, cTrans_Suc, cTarjeta
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal  = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000'; --sin errores
				RETURN cCodRet, cCliente,cFolio,cFecha,cCuenta,cMonto,cHora,cUsuario,cTransaccion,cSaldo,cSucursal,cCheque,cTrans_Suc,cTarjeta,iTotalRows WITH RESUME;

			END FOREACH;	
			
			LET pSkip = pSkip + pLimite ;
			
END
END PROCEDURE;