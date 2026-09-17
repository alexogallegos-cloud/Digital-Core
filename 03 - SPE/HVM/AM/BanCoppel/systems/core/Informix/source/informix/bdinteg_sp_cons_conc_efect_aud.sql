CREATE PROCEDURE "informix".sp_cons_conc_efect_aud( pTipo     INTEGER,
													pFechaIni CHAR(10),
													pFechaFin CHAR(10),
													pEmpresa  CHAR(3),
													pSucursal CHAR(4),
													pCodigo   CHAR(4),
													pUsuario  CHAR(8),
													pSkip     INTEGER,
													pLimite   INTEGER)
RETURNING CHAR(5)   AS  CodRet,
		  CHAR(10)	AS	Fecha,
		  CHAR(12)  AS 	Hora,
		  CHAR(16)  AS  Folio,
		  CHAR(8)	AS	Usuario,
		  CHAR(4)   AS	Sucursal,
		  CHAR(17)  AS  Importe,
		  CHAR(4)	AS	Transaccion,
		  CHAR(17)  AS	Folio_Papeleta,
		  INTEGER   AS  TotRows;
			  			  
DEFINE cCodRet				CHAR(5);
DEFINE cFecha               CHAR(10);
DEFINE cHora                CHAR(12);
DEFINE cFolio               CHAR(16);
DEFINE cUsuario             CHAR(8);
DEFINE cSucursal            CHAR(4);
DEFINE cImporte             CHAR(17);
DEFINE cTransaccion         CHAR(4);
DEFINE cFolio_Pap           CHAR(10);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iRango 		     	INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iSqlErr              INTEGER;
DEFINE iLinea               INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFecha               DATE;
DEFINE dFechaActual			DATE;


LET cCodRet              = '';
LET cFecha               = '';
LET cHora                = '';
LET cFolio               = '';
LET cUsuario             = '';
LET cSucursal            = '';
LET cImporte             = '';
LET cTransaccion         = '';
LET cFolio_Pap           = '';
LET dFechaIni 			 = '';
LET dFechaFin 			 = '';
LET dFechaHoy 			 = '';
LET dFechaParaMovhisOld  = '';
LET dFechaParaMovhisOld2 = '';
LET cFechaParaMovhisOld  = '';
LET cFechaParaMovhisOld2 = '';
LET iRango  			 = 0;
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
/ del reporte de "Concentracion de Efectivo" desde la tabla si_rptcaja_aud                         /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 25/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

--SET DEBUG FILE TO '/informix/sp_cons_conc_efect_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cFecha        = '';
			LET cHora         = '';
			LET cFolio        = '';
			LET cUsuario      = '';
			LET cSucursal     = '';
			LET cImporte      = '';
			LET cTransaccion  = '';
			LET cFolio_Pap    = '';
			LET dFecha        = '';
			LET iTotalRows    = 0;
				
			RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows;
			
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
				LET cDia  = SUBSTRING(cFechaFin FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
				LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
				
				SELECT DISTINCT(COUNT(folio))
				INTO iTotalRows
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND  fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0';
				
			FOREACH
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,cod_transacc,folio_oper
				INTO cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000';
				
				RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows WITH RESUME;         
			END FOREACH;
			
			LET pSkip = pSkip + pLimite ;

END

END PROCEDURE;