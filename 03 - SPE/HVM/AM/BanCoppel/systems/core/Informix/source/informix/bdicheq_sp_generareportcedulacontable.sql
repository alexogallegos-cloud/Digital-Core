CREATE PROCEDURE  "informix".sp_generareportcedulacontable(pCodOper INTEGER, p_clv_archivo CHAR(8), pModalidad INTEGER,pFecha CHAR(10))
--Variables que se retornan.
	RETURNING
		CHAR(6) AS cCodRet,
		CHAR(14)  AS NumeroArchivo,
		CHAR(14) AS CodigoOperacion,
		INTEGER AS NumeroRegistros,
		MONEY(16,2) AS Importe,
		MONEY(16,2) AS Import_CheqPre,
		MONEY(16,2) AS Import_CheqRec,
		MONEY(16,2) AS Import_CheqPSald,
		MONEY(16,2) AS Import_DomPres,
		MONEY(16,2) AS Import_DomRec,
		MONEY(16,2) AS Import_DomSald,
		MONEY(16,2) AS Import_TefPre,
		MONEY(16,2) AS Import_TefRec,
		MONEY(16,2) AS Import_TefSald,
		MONEY(16,2) AS Import_TotalPres,
		MONEY(16,2) AS Import_TotalRec,
		MONEY(16,2) AS Import_TotalSald,
		INTEGER AS NetoPresentadoRegs,
		MONEY(16,2) AS NetoPresentadoMonto,
		INTEGER AS NetoRecibidoRegistros,
		MoNEY(16,2) AS NetoRecibidoImporte,
		INTEGER AS NetoPresentCod30Regst,
		MONEY(16,2) AS NetoPresentCod30Import,
		INTEGER AS NetoPresentCod60Regst,
		MONEY(16,2) AS NetoPresentCod60Import,
		INTEGER AS NetoRecCod30Regst,
		MONEY(16,2) AS NetoRecCod30Import,
		INTEGER AS NetoRecCod60Regst,
		MONEY(16,2) AS NetoRecCod60Import,
		CHAR(50) AS Narrativa,
		MONEY(16,2) AS ImporteNarrativa,
		MONEY(16,2) AS SaldoCTA1102,
		MONEY(16,2) AS SALDOT1,
		MONEY(16,2) AS SaldoFinCod30,
		MONEY(16,2) AS SaldoFinCod60,
		Money(16,2) AS SALDOFIN,
		DATE AS FechaHabil,
		DATE AS FechaParam;
	
	--Variables necesarias, declaramos.

	DEFINE cCodRet 	CHAR(6);
	DEFINE iSqlErr 	INTEGER;
	DEFINE intNumArchivo INTEGER;
	DEFINE intCodOperacion INTEGER;
	DEFINE intNumRegistros INTEGER;
	DEFINE monImport MONEY(16,2);
	DEFINE mImportCheqPre	MONEY(16,2);
	DEFINE mImportCheqRec	MONEY(16,2);
	DEFINE mImportCheqSald	MONEY(16,2);
	DEFINE mImportDomPres 	MONEY(16,2);
	DEFINE mImportDomRec	MONEY(16,2);
	DEFINE mImportDomSald	MONEY(16,2);
	DEFINE mImportTefPres	MONEY(16,2); 
	DEFINE mImportTefRec	MONEY(16,2);
	DEFINE mImportTefSald	MONEY(16,2);
	DEFINE mImportTotalPres MONEY(16,2);
	DEFINE mImportTotalRec 	MONEY(16,2);
	DEFINE mImportTotalSald MONEY(16,2);
	DEFINE intSumRegistros INTEGER;
	DEFINE monSumaImporte MONEY(16,2);
	DEFINE iTotalRegsRecCod40 INTEGER;
	DEFINE mTotalImportRecCod40 MONEY(16,2);
	DEFINE iTotalPreCod40 INTEGER;
	DEFINE mSumaTotalPreCod40 MONEY(16,2);
	DEFINE mNetoRecImport 	MONEY(16,2);
	DEFINE iNetoRecRegs		INTEGER;
	DEFINE mTotalNarrativa 	MONEY(16,2);
	DEFINE iSumCod30PreRegs		INTEGER;
	DEFINE mSumCod30preImport 	MONEY(16,2);
	DEFINE iSumCod31PreRegs     INTEGER;
	DEFINE mSumCod31PreImprt		MONEY(16,2);
	DEFINE iNetoPreCod60Regs		INTEGER;
	DEFINE mNetoPreCod60Import		MONEY(16,2);
	DEFINE mNetoPreCod30Import	MONEY(16,2);
	DEFINE iNetoPreCod30Regs	INTEGER;
	DEFINE iSumCod60PreRegs  INTEGER;
	DEFINE mSumCod60preImport MONEY(16,2);
	DEFINE iSumCod61PreRegs  INTEGER;
	DEFINE mSumCod61PreImprt MONEY(16,2);
	DEFINE iSumCod30RecRegs  INTEGER;
	DEFINE mSumCod30RecImprt MONEY(16,2);
	DEFINE iSumCod31RecRegs  INTEGER;
	DEFINE mSumCod31RecImprt MONEY(16,2);
	DEFINE mNetoRecCod30Import	MONEY(16,2);
	DEFINE iNetoRecCod30Regs	INTEGER;
	DEFINE iSumCod60RecRegs		INTEGER;
	DEFINE mSumCod60RecImport   MONEY(16,2);
	DEFINE iSumCod61RecRegs		INTEGER;
	DEFINE mSumCod61RecImport   MONEY(16,2);	
	DEFINE mNetoRecCod61Import	MONEY(16,2);
	DEFINE iNetoRecCod61Regs	INTEGER;
	DEFINE mTotalSaldoSicam		MONEY(16,2);
	DEFINE mT2Cod41				MONEY(16,2)	;
	DEFINE mImporteCod41Rec		MONEY(16,2);
	DEFINE iRegstCod41Rec		INTEGER;
	DEFINE iSumRegsCod40Pre       	INTEGER;
	DEFINE mSumImportCod40Pre      MONEY(16,2);
	DEFINE iSumRegsCod41		INTEGER;
	DEFINE mImporteCod40Pre		MONEY(16,2);
	DEFINE iRegstCod40Pre		INTEGER;
	DEFINE iNumRegstLib			INTEGER;
	DEFINE mSumMontoLib			MONEY(16,2);
	DEFINE intNumRegistros2101 INTEGER;
	DEFINE mImporte2101      MONEY(16,2);
	DEFINE intNumRegistrosTDC INTEGER;
	DEFINE mImporteTDC   		MONEY(16,2);
	DEFINE mSaldoCta1102		MONEY(16,2);
	DEFINE mSaldoT1				MONEY(16,2);
	DEFINE iNetoPre				INTEGER;
	DEFINE mNetoPre				MONEY(16,2);
	DEFINE mSaldoFinCod30 		MONEY(16,2); 
	DEFINE mSaldoFinCod60		MONEY(16,2) ;
	DEFINE mSaldoFin			MONEY(16,2) ;
	DEFINE cNarrativa			CHAR(50);
	DEFINE mImporNarra			MONEY(16,2);
	DEFINE mNetoPresCod60Import  MONEY(16,2);
	DEFINE iNetoRecCod60Regs    INTEGER;
	DEFINE mNetoRecCod60Import	MONEY(16,2);
	DEFINE iTotalDevoPreCod41	INTEGER;	
	DEFINE mTotalDevoPreCod41	MONEY(16,2);
	DEFINE iTotalDevoRecCod41  INTEGER;
	DEFINE mTotalDevoRecCod41   MONEY(16,2);
	
	DEFINE i                SMALLINT;
    DEFINE j                SMALLINT;
    DEFINE cCodRetDevuelto  CHAR(6);
    DEFINE dtFechaDevuelta 	DATE;
    DEFINE dtFechaHabilAnt  DATE;
	DEFINE dtFechaAux		DATE;
	DEFINE dtFechaParam		DATE;
	DEFINE cFechaPres		CHAR(8);
	DEFINE cFechaPresHabAnt  CHAR(8);
	
	
	DEFINE chrFecha	char(8);

	DEFINE mMonImport41 MONEY(16,2);
	
	--inicializaar variables
	LET  cCodRet =	'000000';
	LET iSqlErr =	0;
	LET intNumArchivo = 0;
	LET intCodOperacion = 0;
	LET intNumRegistros = 0;
	LET monImport = 0;

	LET intSumRegistros = 0;
	LET monSumaImporte = 0;
	LET mImportCheqPre = 0.00;
	LET mImportCheqRec = 0.00;
	LET mImportCheqSald = 0.00;
	LET mImportDomPres = 0.00;
	LET mImportDomRec  = 0.00;
	LET mImportDomSald = 0.00;
	LET mImportTefPres = 0.00;
	LET mImportTefRec  = 0.00;
	LET mImportTefSald = 0.00;
	LET mImportTotalPres = 0.00;
	LET mImportTotalRec = 0.00;
	LET mImportTotalSald = 0.00;
	LET iNetoRecRegs	= 0	 ;
	LET iTotalRegsRecCod40 =0;
	LET mTotalImportRecCod40 = 0.00;
	LET iTotalPreCod40 =0;
	LET mSumaTotalPreCod40 = 0.00;
	LET mNetoRecImport  = 0.00;
	LET mTotalNarrativa = 0.00;
	LET	iSumCod30PreRegs	= 0;	
	LET mSumCod30preImport    = 0.00;
	LET	iSumCod31PreRegs   	= 0;
	LET	mSumCod31PreImprt	= 0.00;
	LET	iNetoPreCod30Regs	= 0;
	LET mNetoPreCod30Import = 0.00;	
	LET iNetoPreCod60Regs   = 0;
	LET mNetoPresCod60Import =0.00;
	LET iSumCod61PreRegs   = 0;
	LET	mSumCod61PreImprt = 0.00;
	LET iSumCod60PreRegs   = 0;
	LET mSumCod60preImport = 0.00;
	--LET	mSumCod60PreImprt = 0.00; No se usa Fabiola
	LET iSumCod30RecRegs   = 0;
	LET	mSumCod30RecImprt = 0.00;
	LET iSumCod31RecRegs   = 0;
	LET	mSumCod31RecImprt = 0.00;
	LET mNetoRecCod30Import	=0.00;
	LET iNetoRecCod30Regs	=0;
	LET iSumCod60RecRegs	=0;
	LET mSumCod60RecImport  =0.00;
	LET iSumCod61RecRegs	=0;
	LET mSumCod61RecImport  =0.00;	
	LET mNetoRecCod61Import	=0.00;
	LET iNetoRecCod61Regs	=0;
	LET mTotalSaldoSicam  = 0.00;
	LET mT2Cod41			= 0.00;
	LET mImporteCod41Rec		=0.00;
	LET iRegstCod41Rec			=0;
	LET iSumRegsCod40Pre   = 0;
	LET mSumImportCod40Pre = 0.00;
	LET iSumRegsCod41 = 0;
	LET mImporteCod40Pre = 0.00;
	LET iRegstCod40Pre	=0;
	LET iNumRegstLib    =0;
	LET mSumMontoLib	= 0;
	LET intNumRegistros2101 =0;
	LET mImporte2101     =0.00;
	LET intNumRegistrosTDC  = 0;
	LET mImporteTDC   	=0.00;	
	LET mSaldoCta1102	=0.00;
	LET mSaldoT1 =0.00;
	LET iNetoPre =0;
	LET mNetoPre =0.00;
	LET mSaldoFinCod30 	=0.00;
	LET mSaldoFinCod60	=0.00;
	LEt mSaldoFin	    =0.00;
	LET mImporNarra    = 0;
	LET cNarrativa = "";
	LET iNetoRecCod60Regs    =0;
	LET mNetoRecCod60Import	=0.00;
	LET iTotalDevoPreCod41 = 0;
	LET mTotalDevoPreCod41 = 0.00;
	LET	iTotalDevoRecCod41 = 0;
	LET mTotalDevoRecCod41 = 0;
	LET i = 2;
    LET j = 6;	
    LET cCodRetDevuelto = '';
    LET dtFechaDevuelta = DATE(1);
    LET dtFechaHabilAnt = DATE(1);
	LET dtFechaAux = DATE(1);
	LET dtFechaParam = pFecha::DATE;
	LET cFechaPres = "";	 
	LET cFechaPresHabAnt ="";
	
	
	LET chrFecha = '';
	
	LET mMonImport41 = 0.00;

	--SET DEBUG FILE TO "/respaldosbd/bdicheq/sp_generareportcedulacontable.out";
	--TRACE ON;
	
BEGIN
	ON EXCEPTION SET iSqlErr    -- por si ocurre un error en el transcurso del SP de informix
	   IF iSqlErr != 0 THEN 
		  LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	   END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pModalidad,0) NOT IN(1,2,3,4,5,6,7,8,9,10,11,12) THEN 
		LET cCodRet = '000001';
		RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	END IF;

		LET dtFechaHabilAnt = pFecha::DATE;
		
		EXECUTE PROCEDURE bditef:"informix".cal_habil_ant(dtFechaHabilAnt)
		INTO cCodRetDevuelto, dtFechaDevuelta;
		LET dtFechaHabilAnt = dtFechaDevuelta;

		If dtFechaDevuelta >= pFecha::DATE or i > j THEN
			LET cCodRet = '000003'; --No se pudo calcular fecha Habila Anterior
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		END IF;

	
	IF pModalidad = 1 THEN --CODIGO 40 Presentados CLAVE CPPC40 cce_archivos_camara
		IF NVL(p_clv_archivo ,'') = '' OR NVL(pCodOper,0) NOT IN (41,40) THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		END IF;
		
		IF NVL(pCodOper,0) = 40 THEN 
				LET chrFecha = (SUBSTRING(dtFechaHabilAnt from 4 for 2) || '' ||
								SUBSTRING(dtFechaHabilAnt from 1for 2) || '' ||
								SUBSTRING(dtFechaHabilAnt from 7 for 4) );
				FOREACH
					SELECT folio, cod_operacion, num_operaciones, NVL(importe_total,0)
					INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport	
					FROM  bditef:"informix".cce_gransumario 
					where cod_operacion = 40 AND nombrearchivo LIKE 'PRE_' || chrFecha ||'%'
					ORDER BY folio::integer
					RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
					LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);
					LET monSumaImporte = monSumaImporte + NVL(monImport,0);
				END FOREACH;
				
		ELSE
				FOREACH
				    SELECT  {+INDEX(bditef:cce_archivos_camara idx_cce_archivos_camara2)} numero_archivo , codigo_operacion , numero_registros , NVL(importe,0)
					INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport
					FROM bditef:"informix".cce_archivos_camara
					WHERE clave_archivo= p_clv_archivo AND codigo_operacion = pCodOper 
					AND fecha::DATE = dtFechaHabilAnt
					ORDER BY numero_archivo::integer
					
					RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
					
					LET intSumRegistros = intSumRegistros + intNumRegistros;
					LET monSumaImporte = monSumaImporte + monImport;
					
				END FOREACH;
		END IF;
		
		RETURN TRIM(cCodRet),'CCTI', 'CCTI',NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	END IF;
	IF pModalidad = 2 THEN-- codigo 41 clave CDDPC41
		IF NVL(p_clv_archivo ,'') = '' OR NVL(pCodOper,0) NOT IN (41,40)THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		END IF;
		
		
		IF NVL(pCodOper,0) = 41 THEN 
				LET chrFecha = (SUBSTRING(pFecha::DATE from 4 for 2) || '' ||
								SUBSTRING(pFecha::DATE from 1for 2) || '' ||
								SUBSTRING(pFecha::DATE from 7 for 4) );
				FOREACH
					SELECT folio, cod_operacion, num_operaciones, NVL(importe_total,0)
					INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport	
					FROM  bditef:"informix".cce_gransumario 
					where cod_operacion = 41 AND nombrearchivo LIKE 'DEV_' || chrFecha ||'%'
					ORDER BY folio::integer DESC
					RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
					LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);
					LET monSumaImporte = monSumaImporte + NVL(monImport,0);
				END FOREACH;
				
		ELSE
				FOREACH
					SELECT {+INDEX(bditef:cce_archivos_camara idx_cce_archivos_camara2)} numero_archivo , codigo_operacion , numero_registros , NVL(importe,0)
					INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport
					FROM bditef:"informix".cce_archivos_camara
					WHERE clave_archivo= p_clv_archivo AND codigo_operacion = pCodOper 
					AND fecha::DATE = pFecha::DATE
					ORDER BY numero_archivo::integer DESC
					
					RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
				
					LET intSumRegistros = intSumRegistros + intNumRegistros;
					LET monSumaImporte = monSumaImporte + monImport;
				END FOREACH;
		END IF;
		
		RETURN TRIM(cCodRet),'CCTI','CCTI',NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	END IF;
	IF pModalidad = 3 THEN  -- CODIGO 40 Propios cce_propios_det
		FOREACH
			SELECT (SUBSTRING(nombrearchivo FROM  (length(nombrearchivo)-1))::integer),COD_OPERACION,COUNT(nombrearchivo), NVL(SUM(c_importe),0)
			INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport
			FROM bditef:"informix".cce_propios_det
			WHERE  fecha_entrada = dtFechaHabilAnt
			GROUP  BY  1,2
			ORDER  BY  1 DESC
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME; 
			
			LET intSumRegistros = intSumRegistros + intNumRegistros;
			LET monSumaImporte = monSumaImporte + monImport;
		END FOREACH;
		
			RETURN TRIM(cCodRet),'CCTI','CCTI',NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		
	END IF;
	IF pModalidad = 4 THEN -- codigo 41 clave CDDRC41
		IF NVL(p_clv_archivo ,'') = '' OR NVL(pCodOper,0) NOT IN (41)THEN
			LET cCodRet = '000001';
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		END IF;
		FOREACH
			SELECT {+INDEX(bditef:cce_archivos_camara idx_cce_archivos_camara2)} numero_archivo , codigo_operacion , NVL(numero_registros,0) , NVL(importe,0)
			INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport
			FROM bditef:"informix".cce_archivos_camara
			WHERE clave_archivo LIKE 'CDDRC41%' AND codigo_operacion = pCodOper 
			AND fecha::DATE = pFecha::DATE
			ORDER BY numero_archivo::INTEGER DESC
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intNumRegistros,0),NVL(monImport,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(iSumRegsCod40Pre,0),NVL(mSumImportCod40Pre,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME; 
			
			LET intSumRegistros = intSumRegistros + intNumRegistros;
			LET monSumaImporte = monSumaImporte + monImport;
		END FOREACH;
			RETURN TRIM(cCodRet),'CCTI','CCTI',NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;  
		
	END IF;
	IF pModalidad = 5 THEN ----Resive como parametros (30,E),(30,S),(31,E),(31,S)
			IF pCodOper = 31 THEN
				LET dtFechaAux = dtFechaHabilAnt;
			ELSE
				LET dtFechaAux = dtFechaHabilAnt;
			END IF;
			
			IF pCodOper = 31 THEN			
				IF p_clv_archivo = 'E' THEN			
					SELECT {+INDEX(bdidomi:dom_cce_detalle "informix".idx_dom_cce_detalle2)} det.cod_operacion --, COUNT(det.cod_operacion) --, NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
					INTO intCodOperacion --, intSumRegistros --, monSumaImporte
					FROM bdidomi:"informix".dom_cce_detalle det
					INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
					WHERE cod_operacion = pCodOper 
					AND det.fecha_insert = dtFechaAux
					AND SUBSTR(det.nombre_arch,1,1) = p_clv_archivo GROUP BY 1;
				
					--230142 - 40 - MejoraCedulaContChqs :: Antonio Cebreros. Se obtiene la cantidad de registros por separado ya que también se moverán junto con el importe.
					--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros. Se agrega sumatoria de importe a la misma consulta que obtiene la cantidad de registros debido a que usan el mismo filtro (mejora).
						SELECT {+INDEX(bdidomi:dom_cce_detalle "informix".idx_dom_cce_detalle2)}  COUNT(det.cod_operacion), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
						INTO intSumRegistros, monSumaImporte
						FROM bdidomi:"informix".dom_cce_detalle det
						INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
						INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
						INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
						WHERE cod_operacion = pCodOper 
						AND det.fecha_insert = dtFechaAux
						AND SUBSTR(det.nombre_arch,1,1) = 'S';					
				END IF;    
				
				IF p_clv_archivo = 'S' THEN				
					SELECT {+INDEX(bdidomi:dom_cce_detalle "informix".idx_dom_cce_detalle2)} det.cod_operacion --, COUNT(det.cod_operacion) --, NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
					INTO intCodOperacion --, intSumRegistros --, monSumaImporte
					FROM bdidomi:"informix".dom_cce_detalle det
					INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
					WHERE cod_operacion = pCodOper 
					AND det.fecha_insert = dtFechaAux
					AND SUBSTR(det.nombre_arch,1,1) = p_clv_archivo  GROUP BY 1;
				
				--230142 - 40 - MejoraCedulaContChqs :: Antonio Cebreros. Se obtiene la cantidad de registros por separado ya que también se moverán junto con el importe.
				--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros. Se agrega sumatoria de importe a la misma consulta que obtiene la cantidad de registros debido a que usan el mismo filtro (mejora).					
					SELECT {+INDEX(bdidomi:dom_cce_detalle "informix".idx_dom_cce_detalle2)} COUNT(det.cod_operacion), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
					INTO intSumRegistros, monSumaImporte
					FROM bdidomi:"informix".dom_cce_detalle det
					INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
					WHERE cod_operacion = pCodOper 
					AND det.fecha_insert = dtFechaAux
					AND SUBSTR(det.nombre_arch,1,1) = 'E';					
				END IF;  
			ELSE
				SELECT {+INDEX(bdidomi:dom_cce_detalle "informix".idx_dom_cce_detalle2)} det.cod_operacion, COUNT(det.cod_operacion), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
				INTO intCodOperacion, intSumRegistros, monSumaImporte
				FROM bdidomi:"informix".dom_cce_detalle det
				INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
				INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = pCodOper 
				AND det.fecha_insert = dtFechaAux
				AND SUBSTR(det.nombre_arch,1,1) = p_clv_archivo GROUP BY 1;		
	
			END IF;	       

		RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		
	END IF;         
	
	IF pModalidad = 6 THEN --Resive como parametro (60,E),(60,S)
		 LET cFechaPresHabAnt = SUBSTRING (dtFechaHabilAnt FROM 7 FOR 4)||SUBSTRING (dtFechaHabilAnt FROM 1 FOR 2)|| SUBSTRING(dtFechaHabilAnt FROM 4 FOR 2) ;
		SELECT a.cod_operacion, COUNT(a.nombre_arch),NVL(SUM(a.importe::DECIMAL(16,2)/100),0)
		INTO intCodOperacion, intSumRegistros, monSumaImporte
		FROM bditef:"informix".tef_cce_detalle AS a, 
		bditef:"informix".tef_tipo_cta AS b, 
		bdinteg:"informix".si_bancos AS c, 
		bditef:"informix".tef_status_pago AS d,
		bditef:"informix".tef_tipo_oper AS e, 
		bditef:"informix".tef_cat_devoluciones AS f
		
		WHERE  substr(a.nombre_arch,1,1) = p_clv_archivo
		
		AND a.cod_operacion = pCodOper
		
		AND a.fecha_presentacion = cFechaPresHabAnt
		AND a.tipo_cta_rec = b.tipo_cta 
		AND a.banco_receptor = c.banco 
		AND a.cve_status = d.cve_status 
		AND a.tipo_operacion = e.codigo 
		AND a.motivo_dev = f.motivo_dev
		group by a.cod_operacion;
		
		RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),60,NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam; 
		
	END IF; 
	
	IF pModalidad = 7 THEN		--Codigo 61 E y S
	
	 LET cFechaPres = SUBSTRING (pFecha FROM 7 FOR 4)||SUBSTRING (pFecha FROM 1 FOR 2)|| SUBSTRING(pFecha FROM 4 FOR 2) ;
	 LET cFechaPresHabAnt = SUBSTRING (dtFechaHabilAnt FROM 7 FOR 4)||SUBSTRING (dtFechaHabilAnt FROM 1 FOR 2)|| SUBSTRING(dtFechaHabilAnt FROM 4 FOR 2) ;
		SELECT cod_operacion, COUNT(cod_operacion), NVL(SUM(importe::decimal(16,2)/100),0) 
		INTO intCodOperacion, intSumRegistros, monSumaImporte
		FROM bditef:"informix".tef_cce_detalle  
		WHERE cod_operacion =  60
		AND substr(nombre_arch,1,1) = p_clv_archivo 
		AND cve_status = '02'
		AND fecha_presentacion = cFechaPresHabAnt
		GROUP BY 1;
		
		RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),61,NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		
	END IF;
	IF pModalidad = 8 THEN -- Liberacion SIf 
	
		FOREACH
			SELECT COUNT(fech_alt), NVL(SUM(monto_tot),0)
			INTO intNumRegistros2101, mImporte2101
			FROM bdicheq:"informix".sc_movdia
			WHERE transacc = 3246 AND fech_alt = pFecha::DATE
			
			RETURN TRIM(cCodRet),'Liberación 2101',NVL(intCodOperacion,0),NVL(intNumRegistros2101,0),NVL(mImporte2101,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
			
			LET intSumRegistros = intSumRegistros + intNumRegistros2101;
			LET monSumaImporte = monSumaImporte + mImporte2101;
		END FOREACH;
		FOREACH
			SELECT COUNT(monto), NVL(SUM(monto),0)
			INTO intNumRegistrosTDC, mImporteTDC
			FROM bdicred:"informix".sd_movdia
			WHERE fecha_mov = pFecha::DATE AND transacc_suc = 6246 AND codigo_fun = 336 AND codigo_ref = 1
			
		RETURN TRIM(cCodRet),'Liberació TDC ',NVL(intCodOperacion,0),NVL(intNumRegistrosTDC,0),NVL(mImporteTDC,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
			
			LET intSumRegistros = intSumRegistros + intNumRegistrosTDC;
			LET monSumaImporte = monSumaImporte + mImporteTDC;
		END FOREACH;
		
		RETURN TRIM(cCodRet),'Total Liberado',NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	END IF;
	IF pModalidad = 9 THEN--Consulta sicam
		SELECT FIRST 1 importechequespresentado,importechequesrecibidos,importechequessaldo,importedomipresentado,importedomirecibido,importedomisaldo,importetefpresentado,
		importetefrecibido,importetefsaldo,total_presentado,total_recibido,total_saldo
		INTO mImportCheqPre,mImportCheqRec,mImportCheqSald,mImportDomPres,mImportDomRec,mImportDomSald,mImportTefPres,mImportTefRec,mImportTefSald,mImportTotalPres,mImportTotalRec,mImportTotalSald
		FROM bditef:"informix".cce_cedulacontable_sicam 
		WHERE CAST(fecha AS DATE)  = pFecha::DATE;
	
		RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
		
	END IF;
	IF pModalidad = 10 THEN--Consulta cedula contable
		IF EXISTS(SELECT fecha_elaboracion FROM bditef:"informix".cce_cedulacontable WHERE  CAST(NVL(fecha_elaboracion,DATE(1)) AS DATE)  = pFecha::DATE) THEN
			LET cCodRet ='000002';
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
			
		ELSE
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
			
		END IF;
	END IF;
	IF pModalidad = 11 THEN
		FOREACH
			SELECT narrativa_dcta11020101,narrativa_importe 
			INTO cNarrativa,mImporNarra
			FROM  bditef:"informix".cce_cedulacontable
			WHERE fecha_elaboracion::DATE = pFecha::DATE
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam WITH RESUME;
		END FOREACH;
	END IF;
	
	IF pModalidad = 12 THEN
	
	 LET cFechaPres = SUBSTRING (pFecha FROM 7 FOR 4)||SUBSTRING (pFecha FROM 1 FOR 2)|| SUBSTRING(pFecha FROM 4 FOR 2) ;
	 LET cFechaPresHabAnt = SUBSTRING (dtFechaHabilAnt FROM 7 FOR 4)||SUBSTRING (dtFechaHabilAnt FROM 1 FOR 2)|| SUBSTRING(dtFechaHabilAnt FROM 4 FOR 2) ;
	 
	 	 --isumcod60recregs
	
			---
			LET chrFecha = (SUBSTRING(dtFechaHabilAnt from 4 for 2) || '' ||
								SUBSTRING(dtFechaHabilAnt from 1for 2) || '' ||
								SUBSTRING(dtFechaHabilAnt from 7 for 4) );
			
		FOREACH--Total Codigo 40 Presentacion
			SELECT NVL(num_operaciones,0), NVL(importe_total,0)
					INTO  intNumRegistros, monImport
					FROM  bditef:"informix".cce_gransumario 
					where cod_operacion = 40 AND nombrearchivo LIKE 'PRE_' || chrFecha ||'%'
					ORDER BY folio::integer
			
			LET iTotalPreCod40 = iTotalPreCod40 + intNumRegistros;
			LET mSumaTotalPreCod40 = mSumaTotalPreCod40 + monImport;
		END FOREACH;
		
		FOREACH--Total Codigo 40 Recepcion
			SELECT NVL(COUNT(nombrearchivo),0), NVL(SUM(c_importe),0)
			INTO intNumRegistros,monImport
			FROM bditef:"informix".cce_propios_det
			WHERE  fecha_entrada = dtFechaHabilAnt
			ORDER  BY  1 DESC
			
			LET iTotalRegsRecCod40 = iTotalRegsRecCod40 + intNumRegistros;
			LET mTotalImportRecCod40 = mTotalImportRecCod40  + monImport;
			
		END FOREACH;
					
		LET chrFecha = (SUBSTRING(pFecha from 4 for 2) || '' ||
								SUBSTRING(pFecha from 1for 2) || '' ||
								SUBSTRING(pFecha from 7 for 4) );
					
		FOREACH--Codigo 41 Devoluciones presentadas
			SELECT NVL(num_operaciones,0), NVL(importe_total,0)
			INTO  intNumRegistros, monImport
			FROM  bditef:"informix".cce_gransumario 
			where cod_operacion = 41 AND nombrearchivo LIKE 'DEV_' || chrFecha ||'%'
			ORDER BY folio::integer DESC
			
			LET iTotalDevoPreCod41 = iTotalDevoPreCod41 + intNumRegistros;
			LET mTotalDevoPreCod41 = mTotalDevoPreCod41 + monImport;
		END FOREACH;
		FOREACH--Total Codigo 41 recepcion
		--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros. Se agrega order by a consulta para tomar en la variable monImport el valor de importe del último 
		--archivo de la cámara definitiva fase devoluciones recibidas 41.
			SELECT {+INDEX(bditef:cce_archivos_camara idx_cce_archivos_camara2)} NVL(numero_registros,0), NVL(importe,0)
			INTO  intNumRegistros, mMonImport41--monImport
			FROM bditef:"informix".cce_archivos_camara
			WHERE clave_archivo LIKE 'CDDRC41%' AND codigo_operacion =  41
			AND fecha::DATE = pFecha::DATE
			ORDER BY numero_archivo::INTEGER DESC
			
			--Se neto total recibidas
			LET intSumRegistros = intSumRegistros + intNumRegistros;
			LET monSumaImporte = monSumaImporte + mMonImport41;
						
		END FOREACH;
			--Se neto total recibidas
			LET iNetoRecRegs =  iTotalRegsRecCod40 - iTotalDevoPreCod41;
			LET mNetoRecImport	= 	mTotalImportRecCod40 - mTotalDevoPreCod41;
		
		--Suma total de codigo 30 presentados	
		SELECT  NVL(COUNT(det.cod_operacion),0),NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
		INTO 	iSumCod30PreRegs, mSumCod30preImport
		FROM bdidomi:"informix".dom_cce_detalle det
		INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
		INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
		INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
		WHERE cod_operacion = 30 AND det.fecha_insert = dtFechaHabilAnt
		AND SUBSTR(det.nombre_arch,1,1) = 'E';     
		
		--Suma total de codigo 31 presentados		
		--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros.
		--Se cambia condición en where para obtener correctamente el número de registros; ahora usa la condición: SUBSTR(det.nombre_arch,1,1) = 'S' tal como en la modalidad 5.
		SELECT  NVL(COUNT(det.cod_operacion),0), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
		INTO 	iSumCod31PreRegs,mSumCod31PreImprt
		FROM bdidomi:"informix".dom_cce_detalle det
		INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
		INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
		INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
		WHERE cod_operacion = 31 AND det.fecha_insert =  dtFechaHabilAnt --pFecha::DATE
		AND SUBSTR(det.nombre_arch,1,1) = 'S';   
		
		
		
		
		--Neto presentado codigo 30
		--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros.		
		LET mNetoPreCod30Import	= mSumCod30preImport - mSumCod31PreImprt;
		LET iNetoPreCod30Regs = iSumCod30PreRegs - iSumCod31PreRegs;
		
		
		
		--Se saca total de presentado codigo 60---------------------
		SELECT NVl(COUNT(a.nombre_arch),0), NVL(SUM(a.importe::DECIMAL(16,2)/100),0)
		INTO iSumCod60PreRegs, mSumCod60preImport
		FROM bditef:"informix".tef_cce_detalle AS a, 
		bditef:"informix".tef_tipo_cta AS b, 
		bdinteg:"informix".si_bancos AS c, 
		bditef:"informix".tef_status_pago AS d,
		bditef:"informix".tef_tipo_oper AS e, 
		bditef:"informix".tef_cat_devoluciones AS f
		WHERE  substr(a.nombre_arch,1,1) = 'E'
			AND a.cod_operacion = 60
			AND a.fecha_presentacion = cFechaPresHabAnt
			AND a.tipo_cta_rec = b.tipo_cta 
			AND a.banco_receptor = c.banco 
			AND a.cve_status = d.cve_status 
			AND a.tipo_operacion = e.codigo 
			AND a.motivo_dev = f.motivo_dev;
		--Se obtiene presentacion codigo 61 faltan variables
		SELECT NVL(COUNT(cod_operacion),0), NVL(SUM(importe::DECIMAL(16,2)/100),0) 
		INTO  iSumCod61PreRegs,mSumCod61PreImprt
		FROM bditef:"informix".tef_cce_detalle 
		WHERE cod_operacion =  60
			AND substr(nombre_arch,1,1) = 'E' 
			AND cve_status = '02'
			AND fecha_presentacion = cFechaPresHabAnt;
		--Se calcula el neto presentado de codigo 60
		LET iNetoPreCod60Regs   = iSumCod60PreRegs - iSumCod61PreRegs;
		LET mNetoPresCod60Import = mSumCod60preImport - mSumCod61PreImprt;
		
		--Se saca total de recibido codigo 30
		SELECT  NVL(COUNT(det.cod_operacion),0), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
		INTO 	iSumCod30RecRegs, mSumCod30RecImprt
		FROM bdidomi:"informix".dom_cce_detalle det
		INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
		INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
		INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
		WHERE cod_operacion = 30 AND det.fecha_insert = dtFechaHabilAnt
		AND SUBSTR(det.nombre_arch,1,1) = 'S'; 
		
		--Se saca el total de recibido codigo 31
		--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros.
		--Se cambia condición en where para obtener correctamente el número de registros; ahora usa la condición: SUBSTR(det.nombre_arch,1,1) = 'E' tal como en la modalidad 5.
		SELECT  NVL(COUNT(det.cod_operacion),0), NVL(SUM(det.importe::DECIMAL(16,2)/100),0)
		INTO 	iSumCod31RecRegs, mSumCod31RecImprt
		FROM bdidomi:"informix".dom_cce_detalle det
		INNER JOIN bdidomi:"informix".dom_cat_servicios ser ON det.rfc_ord = ser.rfc
		INNER JOIN bdidomi:"informix".dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
		INNER JOIN bdidomi:"informix".dom_status_pago stap ON det.cve_estatus = stap.cve_status
		WHERE cod_operacion = 31 
		AND det.fecha_insert =  dtFechaHabilAnt --pFecha::DATE 
		AND SUBSTR(det.nombre_arch,1,1) = 'E'; 
		
		
		--Se calcula neto recibido codigo 30
		--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros.
		LET mNetoRecCod30Import	= mSumCod30RecImprt - mSumCod31RecImprt;
		LET iNetoRecCod30Regs	= iSumCod30RecRegs - iSumCod31RecRegs;
		
		
		--Se saca total recibido codigo 60
		SELECT  NVL(COUNT(a.nombre_arch),0), NVL(SUM(a.importe::DECIMAL(16,2)/100),0)
		INTO iSumCod60RecRegs, mSumCod60RecImport
		FROM bditef:"informix".tef_cce_detalle AS a, 
		bditef:"informix".tef_tipo_cta AS b, 
		bdinteg:"informix".si_bancos AS c, 
		bditef:"informix".tef_status_pago AS d,
		bditef:"informix".tef_tipo_oper AS e, 
		bditef:"informix".tef_cat_devoluciones AS f
		WHERE  substr(a.nombre_arch,1,1) = 'S'
			AND a.cod_operacion = 60
			AND a.fecha_presentacion = cFechaPresHabAnt
			AND a.tipo_cta_rec = b.tipo_cta 
			AND a.banco_receptor = c.banco 
			AND a.cve_status = d.cve_status 
			AND a.tipo_operacion = e.codigo 
			AND a.motivo_dev = f.motivo_dev;
		--Se saca total recibido codigo 61	
		SELECT NVL(COUNT(cod_operacion),0), NVL(SUM(importe::DECIMAL(16,2)/100),0) 
		INTO  iSumCod61RecRegs,mSumCod61RecImport
		FROM bditef:"informix".tef_cce_detalle 
		WHERE cod_operacion =  60
			AND substr(nombre_arch,1,1) = 'S' 
			AND cve_status = '02'
			AND fecha_presentacion = cFechaPresHabAnt;
	
		LET mNetoRecCod60Import	= mSumCod60RecImport - mSumCod61RecImport;
		LET iNetoRecCod60Regs	= iSumCod60RecRegs - iSumCod61RecRegs;
		
		SELECT NVL(total_saldo,0) 
		INTO   mTotalSaldoSicam
		FROM  bditef:"informix".cce_cedulacontable_sicam
		WHERE fecha::DATE = pFecha::DATE;
		
		FOREACH
			SELECT  NVL(numero_registros,0),NVL(importe,0)
			INTO  iRegstCod41Rec,mImporteCod41Rec
			FROM bditef:"informix".cce_archivos_camara
			WHERE clave_archivo LIKE 'CDDRC41%' AND codigo_operacion = 41 
			AND fecha::DATE = pFecha::DATE
			ORDER BY numero_archivo
			
			LET iSumRegsCod41 = iSumRegsCod41 + iRegstCod41Rec;
			IF NVL(mImporteCod41Rec,0) <> 0 THEN
				LET mT2Cod41 = mImporteCod41Rec;
			END IF;
		END FOREACH;
		--Se optiene el T+2
		LET mT2Cod41 = mT2Cod41 + mT2Cod41;
	
			SELECT NVL(COUNT(fech_alt),0), NVL(SUM(monto_tot),0)
			INTO intNumRegistros2101,mImporte2101
			FROM bdicheq:"informix".sc_movdia
			WHERE transacc = 3246 AND fech_alt = pFecha::DATE;
		
			SELECT NVL(COUNT(monto),0), NVL(SUM(monto),0)
			INTO intNumRegistrosTDC,mImporteTDC
			FROM bdicred:"informix".sd_movdia 
			WHERE fecha_mov = pFecha::DATE 
			AND transacc_suc = 6246 
			AND codigo_fun = 336 
			AND codigo_ref = 1;
			--Saldo Cuenta 1102
			LET iNumRegstLib  = iNumRegstLib + intNumRegistros2101 + intNumRegistrosTDC; 
			LET mSumMontoLib = mSumMontoLib + mImporteTDC  + mImporte2101;
			
			LET mSaldoCta1102 = mSumMontoLib + mTotalDevoPreCod41 - mTotalImportRecCod40 - mTotalSaldoSicam;
			
			---Neto presentacion
			--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros. Se valida que se obtenga correctamente el valor del campo neto presentado.
			LET	iNetoPre = iTotalPreCod40 - iSumRegsCod41;
			
			--230142 - 40 - MejoraCedulaContChqs :: Antonio Cebreros.
            --Se modifica el cálculo del "importe neto presentado" a petición del cliente.
            --VNP = ICP - 2 (ICD)			
			LET mNetoPre = mSumaTotalPreCod40 - (mMonImport41*2);			
			--saldo Fin codigo 30 y 60 
			--230142 - 67 - MejoraCedulaContChqsAdendum :: Antonio Cebreros.
			--Con las correcciones aplicadas a la obtención de neto presentado y recibido (cod 30) la fórmula sig. ya es funcional.
			LET mSaldoFinCod30 	= mNetoPreCod30Import - mNetoRecCod30Import;
			
			LET mSaldoFinCod60	= mNetoRecCod60Import - mNetoPresCod60Import;
			--Saldo T+1
			LET mSaldoT1 = mNetoPre - mNetoRecImport;
		FOREACH--
			SELECT NVL(narrativa_importe,0) 
			INTO 	mImporNarra
			FROM  bditef:"informix".cce_cedulacontable
			WHERE fecha_elaboracion::DATE = pFecha::DATE
				
			LET mTotalNarrativa = mTotalNarrativa + mImporNarra;
		END FOREACH;
			LET mSaldoFin = mTotalNarrativa + mSaldoCta1102;
			
			RETURN TRIM(cCodRet),NVL(intNumArchivo ,0),NVL(intCodOperacion,0),NVL(intSumRegistros,0),NVL(monSumaImporte,0),NVL(mImportCheqPre,0),NVL(mImportCheqRec,0),NVL(mImportCheqSald,0),NVL(mImportDomPres,0),NVL(mImportDomRec,0),NVL(mImportDomSald,0),NVL(mImportTefPres,0),NVL(mImportTefRec,0),NVL(mImportTefSald,0),NVL(mImportTotalPres,0),NVL(mImportTotalRec,0),NVL(mImportTotalSald,0),NVL(iNetoPre,0),NVL(mNetoPre,0),NVL(iNetoRecRegs,0),NVL(mNetoRecImport,0),NVL(iNetoPreCod30Regs,0),NVL(mNetoPreCod30Import,0),NVL(iNetoPreCod60Regs,0),NVL(mNetoPresCod60Import,0),NVL(iNetoRecCod30Regs,0),NVL(mNetoRecCod30Import,0),NVL(iNetoRecCod60Regs,0),NVL(mNetoRecCod60Import,0),NVL(cNarrativa,''),NVL(mImporNarra,0),NVL(mSaldoCta1102,0),NVL(mSaldoT1,0),NVL(mSaldoFinCod30,0),NVL(mSaldoFinCod60,0),NVL(mSaldoFin,0),dtFechaHabilAnt,dtFechaParam;
	END IF;
END   --BEGIN
END PROCEDURE  -- Create procedure
DOCUMENT
'DESCRIPCION:Regresa los registros e importes de codigo 40,41 los cuales se mostraran en el reporte ',
'AUTOR : Jose Raul Pacheco Ortiz',
'FECHA : 26/03/2015',
'Ver.  : 20150326.1155',
'BD    : BDICHEQ',
'MODIFICACIÓN: Se modifica fórmula (en modalidad 12) para calcular el valor neto presentado (VPN = ICP  2(ICD)) a petición del cliente en folio 230142 - 40 - MejoraCedulaContChqs, se modifica consulta para obtener el Total Codigo 41 recepcion y se invierten los valores (cambian de posicion) de la fase de presentación DOMI y fase recepción DOMI',
'AUTOR: Antonio Cebreros Perez',
'VERSION: 20160428.1100',
'BD: BDICHEQ',
'MODIFICACIÓN: Se modifican los cálculos para los campos Neto Presentado Cod 30, Neto Recibido Cod 30, Saldo Final Cod 30 y Neto Presentado a petición del cliente.',
'AUTOR: Antonio Cebreros Perez',
'VERSION: 20160602.1100',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consultadettasacomi_pm(pNumcte CHAR(20),pCuenta CHAR(20), pProducto CHAR(4), pTpoconsulta SMALLINT)
		RETURNING 	CHAR(6)			AS 	cCodRet,
					CHAR(20) 		AS 	cNum_cte,
					CHAR(20) 		AS 	cCuenta,
					DECIMAL(11,6) 	AS 	dcTasa_rend,
					MONEY(14,2) 	AS 	mSdo_prom_mm,
					MONEY(14,2) 	AS 	mMon_min_aper,
					MONEY(14,2) 	AS 	mCom_cgo_no_smm,
					MONEY(14,2) 	AS 	mCom_cbo_acla_np,
					MONEY(14,2) 	AS 	mCom_chq_gir_cob,
					MONEY(14,2) 	AS 	mCom_ina_cta,
					MONEY(14,2) 	AS 	mServ_tran_spei,
					MONEY(14,2) 	AS 	mServ_tran_tef,
					MONEY(14,2) 	AS 	mServ_anualidad,
					MONEY(14,2) 	AS 	mServ_reenv_token,
					MONEY(14,2) 	AS 	mServ_reep_token,
					MONEY(14,2) 	AS 	mDisp_cta_bcoppel,
					MONEY(14,2) 	AS 	mDisp_cta_otrobco,
					MONEY(14,2) 	AS 	mDisp_linea,
					CHAR(10)		AS 	dFech_alta_cmspm,
					CHAR(10)		AS 	dFec_ult_mov_cmspm;

--DECLARACIONES DE VARIABLES Y SU TIPO DE DATO
	DEFINE cCodRet    			CHAR(6);
	DEFINE iSqlErr    			INTEGER;	
	DEFINE cNum_cte         	CHAR(20);
	DEFINE cCuenta         		CHAR(20);
	DEFINE dcTasa_rend       	DECIMAL(11,6);
	DEFINE mSdo_prom_mm      	MONEY(14,2);
	DEFINE mMon_min_aper        MONEY(14,2);
	DEFINE mCom_cgo_no_smm      MONEY(14,2);
	DEFINE mCom_cbo_acla_np     MONEY(14,2);
	DEFINE mCom_chq_gir_cob     MONEY(14,2);
	DEFINE mCom_ina_cta         MONEY(14,2);
	DEFINE mServ_tran_spei      MONEY(14,2);
	DEFINE mServ_tran_tef   	MONEY(14,2);
	DEFINE mServ_anualidad      MONEY(14,2);
	DEFINE mServ_reenv_token    MONEY(14,2);
	DEFINE mServ_reep_token     MONEY(14,2);
	DEFINE mDisp_cta_bcoppel    MONEY(14,2);
	DEFINE mDisp_cta_otrobco    MONEY(14,2);
	DEFINE mDisp_linea          MONEY(14,2);
	DEFINE dFech_alta_cmspm     CHAR(10);
	DEFINE dFec_ult_mov_cmspm   CHAR(10);
	DEFINE cProd				CHAR(4);
	DEFINE cTasa				CHAR(8);
	DEFINE dfecha				CHAR(10);
	DEFINE iBand				INTEGER;		

--INICIALIZACIONES DEVALORES DEFAULT DE VARIABLES
	LET cCodRet            = '000000';
	LET iSqlErr            = 0;	
	LET cNum_cte         	 = "";
	LET cCuenta         	 = "";
	LET dcTasa_rend       	 = NULL;
	LET mSdo_prom_mm      	 = NULL;
	LET mMon_min_aper        = NULL;
	LET mCom_cgo_no_smm      = NULL;
	LET mCom_cbo_acla_np     = NULL;
	LET mCom_chq_gir_cob     = NULL;
	LET mCom_ina_cta         = NULL;
	LET mServ_tran_spei      = NULL;
	LET mServ_tran_tef   	 = NULL;
	LET mServ_anualidad      = NULL;
	LET mServ_reenv_token    = NULL;
	LET mServ_reep_token     = NULL;
	LET mDisp_cta_bcoppel    = NULL;
	LET mDisp_cta_otrobco    = NULL;
	LET mDisp_linea          = NULL;
	LET dFech_alta_cmspm     = "";
	LET dFec_ult_mov_cmspm   = "";
	LET cProd				 = "";
	LET cTasa				 = "";
	LET dfecha				 = "";
	LET iBand				 = 0;
	
	--SET DEBUG FILE TO '/respaldosbd/josue/sp_consultadettasacomi_pm.out';
	--TRACE ON;	
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNum_cte,cCuenta,dcTasa_rend,mSdo_prom_mm,mMon_min_aper,mCom_cgo_no_smm,mCom_cbo_acla_np,mCom_chq_gir_cob,
				mCom_ina_cta,mServ_tran_spei,mServ_tran_tef,mServ_anualidad,mServ_reenv_token,mServ_reep_token,mDisp_cta_bcoppel,
				mDisp_cta_otrobco,mDisp_linea,NVL(dFech_alta_cmspm,''),NVL(dFec_ult_mov_cmspm,'');
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF ( NVL(pNumcte,'') = '' ) OR ( NVL(pCuenta,'') = '' AND NVL(pProducto, "") = "" ) THEN
			LET cCodRet = '000001';		ELSE
		   -- SI LOS CAMBIOS VIENEN DESDE CTAMORAL.EXE
			IF (pTpoconsulta = 1) OR (pTpoconsulta = 0) THEN	
				IF pProducto <> "" THEN
					LET cProd = pProducto;
				END IF;
					SELECT tasa_rend,sdo_prom_mm,mon_min_aper,com_cgo_no_smm,com_cbo_acla_np,com_chq_gir_cob,com_ina_cta,fech_alta_cmspm,fec_ult_mov_cmspm			
					INTO dcTasa_rend,mSdo_prom_mm,mMon_min_aper,mCom_cgo_no_smm,mCom_cbo_acla_np,mCom_chq_gir_cob,mCom_ina_cta,dFech_alta_cmspm,dFec_ult_mov_cmspm
					FROM "informix".sc_maecomtasserv_pm 
					WHERE num_cte = pNumCte
					AND cuenta = pCuenta;
					
					-- PARAMETRO PARA TASA DE RENDIMIENTO,SE TOMA EL VALOR DE SALDO PROMEDIO MINIMO MENSUAL REQUERIDO,
					--SE TOMA EL VALOR DE MONTO MINIMO DE APERTURA.
					
					IF (cProd = "") THEN
						SELECT producto INTO cProd
						FROM "informix".sc_maechq 
						WHERE num_cte = pNumCte
						AND cuenta = pCuenta;
					END IF;
					
					IF dcTasa_rend IS NULL  THEN						
						SELECT tasa INTO cTasa
						FROM "informix".sc_producto 
						WHERE  producto = cProd;
						
						-- SE TOMA EL VALOR DE LA TASA DE RENDIMIENTO
						SELECT MAX(fecha), valor 
						INTO dfecha,dcTasa_rend
						FROM bdinteg:"informix".si_fechavalor 
						WHERE tasa = cTasa
						GROUP BY valor;
					END IF;
					
					IF  mSdo_prom_mm IS NULL THEN
						SELECT sdoprommen INTO mSdo_prom_mm
						FROM "informix".sc_producto 
						WHERE  producto = cProd;
					END IF
					
					IF  mMon_min_aper IS NULL THEN
						SELECT mtominape INTO mMon_min_aper
						FROM "informix".sc_producto 
						WHERE  producto = cProd;
					END IF						
					
					IF  mCom_cgo_no_smm IS NULL  THEN
						-- COMISION POR NO TENER SALDO MINIMO.
						SELECT monto_aplica INTO mCom_cgo_no_smm
						FROM "informix".sc_comisiones 
						WHERE empresa = '001'
						AND comision = '3290';
					END IF;
					
					IF  mCom_chq_gir_cob IS NULL THEN
						-- CHEQUES GIRADOS Y COBRADOS.
						SELECT monto_aplica INTO mCom_chq_gir_cob
						FROM "informix".sc_comisiones 
						WHERE empresa = '001'
						AND comision = '3228';
					END IF;
					
					IF  mCom_ina_cta IS NULL  THEN
						-- CARGO POR INACTIVIDAD DE LA CUENTA DURANTE UN AÑO.
						SELECT monto_aplica INTO mCom_ina_cta
						FROM "informix".sc_comisiones 
						WHERE empresa = '001'
						AND comision = '3232';
					END IF;
			 END IF;
			
			-- SI LOS CAMBIOS SON DE LA PANTALLA DE EMPRESANET.EXE
			IF (pTpoconsulta = 2) OR (pTpoconsulta = 0) THEN
				SELECT serv_tran_spei,serv_tran_tef,serv_anualidad,serv_reenv_token,serv_reep_token,fech_alta_cmspm,fec_ult_mov_cmspm
				INTO mServ_tran_spei,mServ_tran_tef,mServ_anualidad,mServ_reenv_token,mServ_reep_token,dFech_alta_cmspm,dFec_ult_mov_cmspm
				FROM "informix".sc_maecomtasserv_pm 
				WHERE num_cte = pNumCte
				AND cuenta = pCuenta;
				
				IF (mServ_tran_spei) IS NOT NULL  OR (mServ_tran_tef) IS NOT NULL OR (mServ_anualidad) IS NOT NULL 
					OR (mServ_reenv_token) IS NOT NULL OR (mServ_reep_token) IS NOT NULL  AND (pTpoconsulta = 0) THEN
					LET cCodRet = '000002';				END IF;
			
				IF mServ_tran_spei  IS NULL  THEN
					-- TRANSFERENCIA SPEI.
					SELECT mnycomision INTO mServ_tran_spei
					FROM bdispei:"informix".tblcomision
					WHERE mnycomision = 5;
				END IF;
				
				--TRANSFERENCIA TEF
				IF mServ_tran_tef IS NULL  THEN 
					-- SE TOMA EL PRODUCTO DE ACUERDO A LA CUENTA
					SELECT producto INTO cProd
					FROM "informix".sc_maechq 
					WHERE num_cte = pNumCte
					AND cuenta = pCuenta;
					
					SELECT importe_comision
					INTO mServ_tran_tef
					FROM bditef:"informix".tef_prod_permitidos
					WHERE cve_producto = cProd
					AND permitido = 'S'
					AND cobra_comision = 'S';
				END IF;
				
				IF mServ_anualidad IS NULL  THEN 
					--ANUALIDAD DEL SERVICIO.
					SELECT monto_aplica INTO mServ_anualidad
					FROM "informix".sc_comisiones
					WHERE comision = '3270';
				END IF;
				
				IF mServ_reenv_token IS NULL  THEN 
					-- REENVIO DE TOKEN.
					SELECT valor INTO mServ_reenv_token
					FROM bdibpi:"informix".tkn_parametros 
					WHERE id_param = '08';
				END IF;
				
				IF mServ_reep_token IS NULL  THEN 
					-- REPOSICIÓN DE TOKEN.
					SELECT valor INTO mServ_reep_token
					FROM bdibpi:"informix".bpi_param
					WHERE  id_param = '01';
				END IF;
							
			 END IF;
			-- SI LOS CAMBIOS VIENEN DESDE ALTANOMINAPM.EXE 
			IF (pTpoconsulta = 3) OR (pTpoconsulta = 0) THEN
				SELECT disp_cta_bcoppel,disp_cta_otrobco,disp_linea,fech_alta_cmspm,fec_ult_mov_cmspm
				INTO mDisp_cta_bcoppel,mDisp_cta_otrobco,mDisp_linea,dFech_alta_cmspm,dFec_ult_mov_cmspm
				FROM "informix".sc_maecomtasserv_pm 
				WHERE num_cte = pNumCte
				AND cuenta = pCuenta;
				
				-- COMISION POR DISPERSION DE REGISTRO EN CUENTA BANCOPPEL.
				IF mDisp_cta_bcoppel IS NULL  THEN 
					SELECT monto_fijo INTO mDisp_cta_bcoppel
					FROM bdinteg:"informix".si_transacc
					WHERE numero = '3256';			
				END IF;
				
				-- COMISION POR DISPERSION DE REGISTRO EN CUENTA DE OTRO BANCO.
				IF mDisp_cta_otrobco IS NULL  THEN 
					SELECT monto_fijo INTO mDisp_cta_otrobco
					FROM bdinteg:"informix".si_transacc
					WHERE numero = '3257';			
				END IF;
				
				-- COMISION POR DISPERSION EN LINEA.
				IF mDisp_linea IS NULL  THEN 
					SELECT monto_fijo INTO mDisp_linea
					FROM bdinteg:"informix".si_transacc
					WHERE numero = '3255';			
				END IF;
				
			END IF;
		END IF;
	
		RETURN cCodRet,pNumcte,pCuenta,dcTasa_rend,mSdo_prom_mm,mMon_min_aper,mCom_cgo_no_smm,mCom_cbo_acla_np,mCom_chq_gir_cob,
	    mCom_ina_cta,mServ_tran_spei,mServ_tran_tef,mServ_anualidad,mServ_reenv_token,mServ_reep_token,mDisp_cta_bcoppel,
	    mDisp_cta_otrobco,mDisp_linea,NVL(dFech_alta_cmspm,''),NVL(dFec_ult_mov_cmspm,'');
				
	END;
END PROCEDURE
DOCUMENT
'Folio: 1409',
'Autor: 94912599 ',
'Fecha: 27/02/2014',
'Descripción: Se crea procedimiento para la consulta de las tasas y comisiones que actualmente se 	encuentran dadas de',
'alta o las ya definidas o determinadas para cada cuentas',
'Sustento: RQM10-360 Param de Comi Emp_firma_color.pdf',
'Solicita: Daniel Mayén Rivas',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_portabprocesaalta( pOrigenAlta CHAR(20), 
                                                  pSucAlta CHAR(4), 
                                                  pNumCte CHAR(20), 
                                                  pNumCtaOrigen CHAR(20),
                                                  pBancoDest CHAR(3), 
                                                  pClabeDest CHAR(20), 
                                                  pTarjDest CHAR(20), 
                                                  pDiasDep CHAR(60),
                                                  pUsuario CHAR(8) )
RETURNING CHAR (5) AS CodigoRetorno,
		  CHAR (110) AS MensajeEjecucion;

    -- // DESCRIPCION DE LOS PARAMETROS DE ENTRADA
    /*  pOrigenAlta:   Origen de la alta. Valores esperados SIF(central), OFI(sucursal) y WEB(internet)
    pSucAlta:      Sucursal donde se realizo la alta del servicio de portabilidad
    pNumCte:       Numero del cliente que realizo la alta del servicio de portabilidad
    pNumCtaOrigen: Numero de la cuenta a la que se le activo el servicio de portabilidad
    pBancoDest:    Codigo del banco al que se le va a realizar la transferencia (deposito)
    pClabeDest:    Cuenta CLABE a la que se le realizara la transferencia (deposito)
    pTarjDest:     Numero de tarjeta de debito a la que se le realizara la transferencia (deposito)
    pDiasDep:      Dias que el cliente declaro sus ingresos
    pUsuario:	   Numero del usuario que realiza la alta 
    */

    -- // DECLARACION DE VARIABLES
    DEFINE iSqlErr INTEGER;				-- ERROR DE INFORMIX
    DEFINE cCodRet CHAR(5);				-- CODIGO DEL ERROR

    DEFINE cMensajeEjec  CHAR(110);		-- MENSAJE DE LA EJECUCION DEL PROCEDIMIENTO
    DEFINE cEstCta 	       CHAR(1);		-- ESTATUS DE LA CUENTA DE CAPTACION
    DEFINE cProdCta        CHAR(4);		-- PRODUCTO DE LA CUENTA DE CAPTACION
    DEFINE iSecuencia      INTEGER;		-- NUMERO DE SECUENCIA
    DEFINE cEstPortab      CHAR(2);		-- ESTATUS DEL SERVICIO DE PORTABILIDAD DE LA CUENTA
    DEFINE dfechahoy          DATE;		-- FECHA EN QUE SE DA DE ALTA LA CUENTA CON EL SERVICIO DE PORTABILIDAD
    DEFINE cNombreCte	 CHAR(110);		-- NOMBRE DEL CLIENTE BANCOPPEL
    DEFINE cRFC	          CHAR(20);		-- RFC DEL CLIENTE BANCOPPEL
    DEFINE cCorreo	     CHAR(100);		-- CORREO ELECTRONICO DEL CLIENTE BANCOPPEL
    DEFINE cCel		      CHAR(13);		-- TELEFONO CELULAR DEL CLIENTE BANCOPPEL
    DEFINE cCveCuenta	   CHAR(2);		-- CLAVE DE LA CUENTA
    DEFINE cCuenta	      CHAR(20);		-- CUENTA A INSERTAR EN LA TABLA PP_CTASTERCEROS
    DEFINE cDescripCta	  CHAR(20);		-- DESCRIPCION DE LA CUENTA A INSERTAR EN LA TABLA PP_CTASTERCEROS
    DEFINE cConsecutivo	   CHAR(2);		-- CONSECUTIVO CADENA
    DEFINE iConsec	       INTEGER;		-- CONSECUTIVO ENTERO
    DEFINE iCodRetdv1	   INTEGER;	    -- CODIGO DE RETORNO 1 DE LA EJECUCION DEL PROCEDIMIENTO sp_validadv
    DEFINE iCodRetdv2	   INTEGER;	    -- CODIGO DE RETORNO 2 DE LA EJECUCION DEL PROCEDIMIENTO sp_validadv
	DEFINE cNumerico	   CHAR(2);     -- VALIDA SI ES NUMERICO.
	
	
	
	
    -- // INICIALIZACION DE VARIABLES
    LET iSqlErr = 0;
    LET cCodRet = '00000';

    LET cMensajeEjec = 'LA ALTA DEL SERVICIO DE PORTABILIDAD SE HA REALIZADO EXITOSAMENTE';
    LET cEstCta      = '';
    LET cProdCta     = '';
    LET iSecuencia   =  0;
    LET cEstPortab   = '';
    LET dfechahoy    = '';
    LET cNombreCte   = '';
    LET cRFC		 = '';
    LET cCorreo		 = '';
    LET cCel		 = '';
    LET cCveCuenta   = '';
    LET cCuenta	     = '';
    LET cDescripCta  = 'PORTABILIDAD';
    LET cConsecutivo = '';
    LET iConsec      = 0;
    LET iCodRetdv1   = 0;
    LET iCodRetdv2   = 0;
	LET cNumerico	 = '';
	
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeEjec = 'ERROR INESPERADO EN LA EJECUCION DEL PROCEDIMIENTO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
    END EXCEPTION;

       --SET DEBUG FILE TO "/informix/VILLELA/sp_portabprocesaalta.out";
	   --TRACE ON;
	

    SET ISOLATION TO DIRTY READ;

    -- se valida que los parametros traigan datos
    IF pOrigenAlta = '' OR pOrigenAlta IS NULL OR pSucAlta = '' OR pSucAlta IS NULL OR pNumCte = '' OR pNumCte IS NULL OR
       pNumCtaOrigen = '' OR pNumCtaOrigen IS NULL OR pBancoDest = '' OR pBancoDest IS NULL OR pDiasDep = '' OR pDiasDep IS NULL OR
       pUsuario = '' OR pUsuario IS NULL THEN
        LET cCodRet = '00001';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; TODOS LOS PARAMETROS SON OBLIGATORIOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que la CLABE y el numero de tarjeta no vengan vacios al mismo tiempo
    IF (pClabeDest = '' OR pClabeDest IS NULL) AND (pTarjDest = '' OR pTarjDest IS NULL) THEN
        LET cCodRet = '00002';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; NO PUEDEN RECIBIRSE CUENTA CLABE Y NUMERO DE TARJETA VACIOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;	
    END IF;

    -- se valida que la CLABE y el numero de tarjeta no vengan llenos al mismo tiempo
    IF (pClabeDest <> '') AND (pTarjDest <> '') THEN
        LET cCodRet = '00003';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; NO PUEDEN RECIBIRSE CUENTA CLABE Y NUMERO DE TARJETA LLENOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;	
    END IF;

    -- se valida que exista la sucursal de la alta
    IF NOT EXISTS (SELECT sucursal FROM bdinteg:si_sucursales WHERE empresa = '001' and sucursal = pSucAlta) THEN	
        LET cCodRet = '00004';
        LET cMensajeEjec = 'CODIGO DE SUCURSAL NO VALIDO; NO EXISTE EN EL CATALOGO DE SUCURSALES';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el cliente bancoppel
    IF NOT EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE empresa = '001' and numcte = pNumCte) THEN
        LET cCodRet = '00005';
        LET cMensajeEjec = 'NUMERO DE CLIENTE NO VALIDO; NO EXISTE EN EL MAESTRO DE CLIENTES BANCOPPEL';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se obtiene el estatus y el producto de la cuenta de cheques
    SELECT status_cta, producto
      INTO cEstCta, cProdCta
      FROM bdicheq:sc_maechq
     WHERE empresa = '001'
       AND cuenta = pNumCtaOrigen;

    -- se valida que exista la cuenta de cheques
    IF cProdCta IS NULL OR cProdCta = '' THEN
        LET cCodRet = '00006';
        LET cMensajeEjec = 'NUMERO DE CUENTA NO VALIDO; NO EXISTE EN EL MAESTRO DE CUENTAS DE CHEQUES';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el codigo del banco
    IF NOT EXISTS (SELECT banco FROM bdinteg:si_bancos WHERE banco = pBancoDest) THEN
        LET cCodRet = '00007';
        LET cMensajeEjec = 'CODIGO DEL BANCO DESTINO NO VALIDO; NO EXISTE EN EL CATALOGO DE BANCOS';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el usuario
    IF NOT EXISTS (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE empresa = '001' and ejecutivo = pUsuario) THEN
        LET cCodRet = '00008';
        LET cMensajeEjec = 'CODIGO DEL USUARIO NO VALIDO; NO EXISTE EN EL CATALOGO DE EJECUTIVOS';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que venga la cuenta clabe y no el numero de tarjeta
    IF pClabeDest <> '' AND pTarjDest = '' THEN
        -- se valida que la longitud de la cuenta clabe sea de 18 caracteres
        IF LENGTH(pClabeDest) <> 18 THEN
            LET cCodRet = '00011';
            LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; EL NUMERO DE CARACTERES DE LA CUENTA CLABE ES INCORRECTO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
        
        -- se valida que la cuenta clabe sea correcta al comparar los primeros 3 digitos con el codigo del banco
        IF pBancoDest = SUBSTR(pClabeDest, 1, 3) THEN
            -- se ejecuta un procedimiento para validar si el digito verificador de la cuenta clabe es valido
            EXECUTE PROCEDURE bdispei:sp_validadv(pClabeDest) 
            INTO iCodRetdv1, iCodRetdv2;
            
            -- se valida que el digito verificador es valido
            IF iCodRetdv1 = 0 AND iCodRetdv2 = 1 THEN
                LET cCveCuenta = '02';
                LET cCuenta = TRIM(pClabeDest);
            ELSE
                -- se valida que el digito verificador es invalido
                LET cCodRet = '00012';
                LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; ULTIMO NUMERO (DIGITO VERIFICADOR) INVALIDO';
                RETURN cCodRet, cMensajeEjec;			
            END IF;			
        ELSE
            LET cCodRet = '00009';
            LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; LOS PRIMEROS 3 DIGITOS NO SON IGUALES AL CODIGO DEL BANCO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
    -- se valida que venga el numero de tarjeta y no la cuenta clabe
    ELIF pTarjDest <> '' AND pClabeDest = '' THEN
        LET cCveCuenta = '03';
        LET cCuenta = TRIM(pTarjDest);
    END IF;

    -- se valida que el estatus no este cancelada
    IF cEstCta IN('2','6','7','8') THEN
        LET cCodRet = '10000';
        LET cMensajeEjec = 'LA CUENTA BANCOPPEL SE ENCUENTRA CANCELADA';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se valida que el producto de la cuenta de captacion aplica para la activacion del servicio de portabilidad	
    IF NOT EXISTS(SELECT valor 
                    FROM bdicheq:sc_param 
                   WHERE empresa = '001'
                     AND codparam = 'PORTAPRODPERM'
                     AND valor LIKE '%'||cProdCta||'%') THEN
        LET cCodRet = '00010';
        LET cMensajeEjec = 'EL PRODUCTO DE LA CUENTA NO ES SUSCEPTIBLE PARA LA ACTIVACION DEL SERVICIO DE PORTABILIDAD';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se obtiene la maxima secuencia del registro para la cuenta de cheques con el servicio de portabilidad
    SELECT MAX(secuencia)
      INTO iSecuencia
      FROM bdicheq:sc_portabilidadnomina 
     WHERE empresa = '001'
       AND cliente = pNumCte
       AND cuenta_abono = pNumCtaOrigen;

    -- se obtiene el estatus del registro de la maxima secuencia para la cuenta de cheques con el servicio de portabilidad
    SELECT estatus
      INTO cEstPortab
      FROM bdicheq:sc_portabilidadnomina
     WHERE empresa = '001'
       AND cliente = pNumCte
       AND cuenta_abono = pNumCtaOrigen
       AND secuencia = iSecuencia;

    -- se valida que el estatus no este activo
    IF cEstPortab = '01' THEN
        LET cCodRet = '20000';
        LET cMensajeEjec = 'LA CUENTA BANCOPPEL YA CUENTA CON EL SERVICIO DE PORTABILIDAD ACTIVO';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se obtiene la fecha de la alta del servicio de portabilidad
    SELECT fecha_hoy
      INTO dfechahoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    -- se obtiene el nombre, el rfc, el email y el celular del cliente bancoppel
    SELECT TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno),
           TRIM(cte.rfc), TRIM(core.correo_elec), TRIM(tel2.telefono)
      INTO cNombreCte,cRFC, cCorreo, cCel
      FROM bdinteg:si_cliente cte
      left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
      left outer join bdinteg:si_correos core on (core.numcte = cte.numcte and core.tipo_correo = 1 and core.status_correo ='A')
     WHERE cte.numcte = pNumCte;
    --- AND c.secuencia = (SELECT MAX(secuencia) 
    --- FROM bdinteg:si_direcciones 
    --- WHERE numcte = pNumCte
    --- AND tipo_dir = 1
    --- AND (c.tipo_telef2 = 'C' OR c.tipo_telef2 = ''))

    -- se valida que la cuenta de cheques es la primera vez que se le activa el servicio de portabilidad
    IF iSecuencia IS NULL THEN
        LET iSecuencia = 1;
    ELSE
        -- se valida que la cuenta de cheques ya tuvo el servicio de portabilidad
        LET iSecuencia = iSecuencia + 1;		
    END IF;

    -- se registra la activacion del servicio de portabilidad en la tabla de cheques
    INSERT INTO bdicheq:sc_portabilidadnomina 
    (empresa, cliente, cuenta_abono, secuencia, banco_ref,
     cuenta_ref, tarjeta_ref, fecha_deposito, estatus, user_cancel, fecha_cancel,
     origen_alta, sucursal_alta, origen_cancel, sucursal_cancel, user_insert, fecha_insert)
    VALUES 
    ('001', TRIM(pNumCte), TRIM(pNumCtaOrigen), iSecuencia, TRIM(pBancoDest),
     TRIM(pClabeDest), TRIM(pTarjDest), TRIM(UPPER(pDiasDep)), '01', NULL, NULL,
     UPPER(pOrigenAlta), TRIM(pSucAlta), NULL, NULL, TRIM(pUsuario), dfechahoy);

    -- se valida que si el celular viene con lada se borre la lada por el tamaño del campo en la tabla bdiprog:pp_ctasterceros
    IF LENGTH(cCel) > 10 THEN
        LET cCel = SUBSTR(cCel, 4, 13);	
    END iF;

	
    -- se valida que el registro para el cliente, la cuenta destino y la clave del banco destino sea diferente a las existentes
    IF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco <> pBancoDest) THEN
        -- se valida que el registro para el cliente, la cuenta destino y la clave del banco destino existan
        IF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN
            -- se actualiza el registro correspondiente a la activacion del servicio segun el cliente, cuenta y banco recibido
            UPDATE bdiprog:pp_ctasterceros
               SET cve_cuenta = cCveCuenta,
                   nombre = cNombreCte,
                   cve_compania = '00',
                   cve_estado = '01',
                   no_celular = TRIM(cCel),
                   canal_baja = NULL,
                   fecha_estado = dfechahoy,
                   user_insert = pUsuario, 
                   fecha_insert = dfechahoy, 
                   hora_insert = CURRENT HOUR TO SECOND
             WHERE num_cte = pNumCte
               AND cuenta = cCuenta
               AND cve_banco = pBancoDest;

            RETURN cCodRet, cMensajeEjec;
        END IF;		

		
		
		   -- se obtiene el maximo valor del numero diferenciador
          SELECT (SUBSTR(descrip_cta, 16, 2))
          INTO cNumerico
          FROM bdiprog:pp_ctasterceros
          WHERE num_cte = pNumCte
          AND cuenta = cCuenta;
		
		
		IF  bdiprog:isnumeric(cNumerico ) = '1'  THEN
		
				-- se obtiene el maximo valor del numero diferenciador
				SELECT (MAX(SUBSTR(descrip_cta, 16, 2)) + 1)::INTEGER
				  INTO iConsec
				  FROM bdiprog:pp_ctasterceros
				 WHERE num_cte = pNumCte
				   AND cuenta = cCuenta;

		ELSE  
		   
		LET iConsec = '01';    
		   
		END IF   
		   
        -- se le anexa un '0' a la izquierda al valor obtenido en caso de que sea un valor de un solo digito
        LET cConsecutivo = LPAD(iConsec, 2, '0');

        -- se concantena la descripcion del proceso (PORTABILIDAD) mas un '-' con el consecutivo armado
        LET cDescripCta = TRIM(cDescripCta) || ' - ' || cConsecutivo;

        -- se inserta en la tabla para cuando no sea el primero registro para la cuenta y cliente, y para un diferente banco
        INSERT INTO bdiprog:pp_ctasterceros 
        (num_cte, cuenta, cve_banco, descrip_cta, cve_cuenta,
         nombre, rfc, direc_correo, cve_compania, cve_estado, no_celular, canal_alta, canal_baja,
         fecha_estado, user_insert, fecha_insert, hora_insert)
        VALUES 
        (TRIM(pNumCte), TRIM(cCuenta), TRIM(pBancoDest), TRIM(cDescripCta), cCveCuenta,
         TRIM(cNombreCte), TRIM(cRFC), TRIM(cCorreo), '00', '01', TRIM(cCel), '01', NULL,
         dfechahoy, TRIM(pUsuario), dfechahoy, CURRENT HOUR TO SECOND);

    -- se valida que no exista el registro para el cliente, cuenta y banco recibido
    ELIF NOT EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN

        -- se concantena la descripcion del proceso (PORTABILIDAD) mas un '-' con el consecutivo inicial
        LET cDescripCta = TRIM(cDescripCta) || ' - ' || '01';

        -- se inserta en la tabla para cuando sea el primer registro para la cuenta, cliente y banco
        INSERT INTO bdiprog:pp_ctasterceros 
        (num_cte, cuenta, cve_banco, descrip_cta, cve_cuenta,
         nombre, rfc, direc_correo, cve_compania, cve_estado, no_celular, canal_alta, canal_baja,
         fecha_estado, user_insert, fecha_insert, hora_insert)
        VALUES 
        (TRIM(pNumCte), TRIM(cCuenta), TRIM(pBancoDest), TRIM(cDescripCta), cCveCuenta,
         TRIM(cNombreCte), TRIM(cRFC), TRIM(cCorreo), '00', '01', TRIM(cCel), '01', NULL,
         dfechahoy, TRIM(pUsuario), dfechahoy, CURRENT HOUR TO SECOND);

    -- se valida que exista el registro para el cliente, cuenta y banco recibido
    ELIF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN

        -- se actualiza el registro correspondiente a la activacion del servicio segun el cliente, cuenta y banco recibido
        UPDATE bdiprog:pp_ctasterceros
           SET cve_cuenta = cCveCuenta,
               nombre = cNombreCte,
               cve_compania = '00',
               cve_estado = '01',
               no_celular = TRIM(cCel),
               canal_baja = NULL,
               fecha_estado = dfechahoy,
               user_insert = pUsuario, 
               fecha_insert = dfechahoy, 
               hora_insert = CURRENT HOUR TO SECOND
         WHERE num_cte = pNumCte 
           AND cuenta = cCuenta 
           AND cve_banco = pBancoDest;
    END IF;

    RETURN cCodRet, cMensajeEjec;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Genera la alta del servicio de portabilidad de una cuenta',
'AUTOR: Clemente Angulo Ballardo',
'FECHA: 08 de Junio de 2010',
'VERSION: 20100608.1800',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_archivo_indicadores
(
)
RETURNING
	CHAR(6),
	CHAR(80)
---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE cRuta			CHAR(100);
	DEFINE v_sql        	CHAR(1000);
	DEFINE cArchivo			CHAR(27);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE cAnioMesAnte		CHAR(6);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET cRuta				= "";
	LET v_sql  				= "";
	LET cArchivo			= "";
	LET cFechaHoy			= "";
	LET cAnioMesAnte		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/vamilan/sp_archivo_indicadores.out';
	--TRACE ON;
	
	LET cRuta = "/resplogifx/indicadores/";
	
	SELECT fecha_hoy, YEAR(fecha_hoy - 1 units MONTH) || LPAD(MONTH(fecha_hoy - 1 units MONTH),2,"0")
	INTO cFechaHoy, cAnioMesAnte
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_internet_indicadores";

	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON INTERNET
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
		' SELECT t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, num_depositos_vent, imp_acum_depositos_vent, ' ||
		' num_depositos_entrecta, imp_acum_depositos_entrecta, num_depositos_terc, imp_acum_depositos_terc, ' ||
		' num_depositos_corresp, imp_acum_depositos_corresp, num_deposito_spei, imp_acum_deposito_spei, ' ||
		' num_retiros_vent, imp_acum_retiros_vent, num_retiros_entrecta, imp_acum_retiros_entrecta, ' ||
		' num_retiros_terc, imp_acum_retiros_terc, num_retiros_atm, imp_acum_retiros_atm, ' ||
		' num_retiros_cashback, imp_acum_retiros_cashback, num_compra_pos, imp_acum_compra_pos, ' ||
		' num_compra_interred, imp_acum_compra_interred, num_retiro_spei, imp_acum_retiro_spei ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte AND t1.internet = 1; "'||
		' > query_descarga_archivo_internet_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_internet_indicadores.sql";
	SYSTEM v_sql;
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_sdoprom_indicadores";
	LET v_sql = "";
	
	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON SU SALDO PROMEDIO Y SALDO MAXIMO EN EL MES
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
	    ' SELECT {+ MULTI_INDEX(informix.sc_indicadores)} t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, t1.saldo_maximo_mes, t1.saldo_promedio ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte; "'||
		' > query_descarga_archivo_sdoprom_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_sdoprom_indicadores.sql";
	SYSTEM v_sql;
	
	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para ',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_generarchivoportab(pfecha_reg date,pnombrearchivo CHAR(30))
RETURNING 	CHAR(3),   --COT_RET
			INTEGER,   --TOTAL SOLICITUDES
			CHAR(80);  -- RUTA ARCHIVO


DEFINE sql_err		INTEGER;
DEFINE vcodret1     CHAR(5);

DEFINE vtotalSol	INTEGER;
DEFINE vruta		CHAR(80);
DEFINE vsSQL 		CHAR(1400);
DEFINE vsSQL1 		CHAR(400);
DEFINE vsSQL2 		CHAR(1500);
DEFINE vsSQL3 		CHAR(350);
DEFINE vsSQL4 		CHAR(350);
DEFINE vsumario		CHAR(360);
DEFINE vfiltra		CHAR(200);
DEFINE vencabezado	CHAR(100);
DEFINE vsumFuturo	CHAR(255);
DEFINE vRegistros	CHAR(7);
DEFINE vfecha_reg	CHAR(8);
DEFINE vsecuencia	CHAR(7);
DEFINE vRegisTot	SMALLINT;

LET vcodret1 = "001";
LET sql_err  = 0;

LET vtotalSol 	= "";
LET vruta 		= "";
LET vsSQL 		= "";
LET vsSQL1 		= "";
LET vsSQL2 		= "";
LET vsSQL3 		= "";
LET vsSQL4 		= "";
LET vsumario	= "";
LET vfiltra	    = "";
LET vencabezado	= "";
LET vRegistros	= "";
LET vfecha_reg	= "";
LET vsecuencia  = "";
LET vRegisTot   = 0;
LET vsumFuturo  = LPAD('',255);


BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vtotalSol, vruta;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivoportab.out";
		--TRACE ON;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 THEN
			LET vcodret1='001';
			RETURN vcodret1, vtotalSol, vruta;
		END IF;

        LET vfecha_reg = TRIM(YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0));

        SELECT valor
		INTO vruta 
		FROM BDICHEQ:sc_param 
		WHERE empresa = "001" 
		AND codparam = 'rta_ptsol';

        SELECT count(*)
        INTO vRegistros
		FROM sc_portacec_archivotemp;


        -- PROCESO DE GENERACION DE ARCHIVO
            LET vsecuencia= vRegistros + 2;
       
        IF vRegistros < 10 THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(1)),7,'0');						
       
	    ELIF  vRegistros >= 10  AND  vRegistros < 100  THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(2)),7,'0');			
       
	    ELSE		
		    LET vRegistros= LPAD(cast(vRegistros as CHAR(3)),7,'0');

        END IF;
        
	   	   
        IF vsecuencia < 10 THEN
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(1)),7,'0');
			
		ELIF  vsecuencia >= 10  AND vsecuencia < 100   THEN 
             LET vsecuencia= LPAD(cast(vsecuencia as CHAR(2)),7,'0');		
        ELSE
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(3)),7,'0');

        END IF;

   
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vruta) ||  'Solicitudes.txt';
LET vsSQL2 = "SELECT '0100000012040137E" || vfecha_reg || "'||LPAD('',248) FROM sc_portacec_archivotemp UNION " ||
"SELECT  '02'||CASE WHEN secuencia+1 <= 9 THEN LPAD(cast(secuencia+1 as char(1)),7,'0') WHEN  secuencia+1 >= 10 AND  secuencia+1 < 100 THEN  TRIM(LPAD(cast(secuencia+1 as char(2)),7,'0'))ELSE TRIM(LPAD(cast(secuencia+1 as char(3)),7,'0')) END||'20'||folio_solicitud||fecha_solicitud||nombre_cte||" ||
"CASE WHEN rfc_cte is null or rfc_cte = '' or (length(rfc_cte) < 13) then 'ND' ||LPAD('',11) else rfc_cte end||cta_receptora||" ||
"tipo_cta_receptora||bco_receptor||CASE WHEN (length(cta_ordenante)<18) then '00'||TRIM(cta_ordenante) else cta_ordenante end||" ||
 "CASE WHEN (length(tipo_cta_ordenante)<2) then '0'||TRIM(tipo_cta_ordenante) else tipo_cta_ordenante end||bco_ordenante||fecha_nacimiento||" ||
"CASE WHEN rfc_empresa is null or rfc_empresa = '' or (length(rfc_empresa) < 13) or valrfcemp_cecoban(rfc_empresa) = '1' then 'ND' ||LPAD('',11) else rfc_empresa end||estatus_respuesta||" || 

"fecha_respuesta||CASE WHEN (curp_cte is null or curp_cte = '') or (length(curp_cte) < 18) then 'ND' ||LPAD('',16) else curp_cte end||" ||
"LPAD('',13) FROM sc_portacec_archivotemp";
	
			 
		LET vsSQL3 = '" >' || TRIM(vruta) || 'queryTem.sql';
		LET vsSQL = TRIM(vsSQL1) || ' ' || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
  
        LET vfiltra= "sed 's/|$//g;/^$/d' " ||  TRIM(vruta) ||  "Solicitudes.txt " || " > " || TRIM(vruta) || TRIM(pnombrearchivo)||'.txt';
        LET vsumario = "echo '09"|| vsecuencia || "20" || vRegistros || vsumFuturo || "' >> " || TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
        
        
			IF LENGTH(NVL(vsSQL,'')) > 0 THEN
				SYSTEM vsSQL;
				LET vsSQL4 = '';
				LET vsSQL4 = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
                --LET vsSQL4 = 'dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
				SYSTEM vsSQL4;
                LET vcodret1='000';
            END IF
        
        
        SYSTEM vfiltra;
        SYSTEM vsumario;
       
       -- PROCESO DE ACTUALIZACION DE SOLICITUDES

           IF vcodret1='000' THEN
                           
				UPDATE {+ INDEX(sc_portacec_solicitud idx_sc_portacec_solicitud2)} sc_portacec_solicitud SET fecha_presentacion=vfecha_reg, estatus_cecoban='', fecha_estatus_cecoban='' 
				WHERE folio_solicitud IN(SELECT {+ INDEX(sc_portacec_archivotemp idx_sc_portacec_archivotemp)} folio_solicitud FROM sc_portacec_archivotemp);

				LET vcodret1='000';
				LET vtotalSol=vRegistros;
				LET vruta=TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
           END IF;

        RETURN vcodret1, vtotalSol, vruta;
END
END PROCEDURE
;