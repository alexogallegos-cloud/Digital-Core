CREATE PROCEDURE "informix".sp_reportediarioremesasac(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING  CHAR(5) AS codigoretorno,
	DATE AS Dia, 
	CHAR(16) AS Num_confirmacion, 
	MONEY(16,2) AS Importe, 
	CHAR (20) AS Forma_pago, 
	CHAR (16) AS Folio_op, 
	CHAR (5) AS Sucursal, 
	CHAR (8) AS Cajero, 
	CHAR (120) AS Nom_benef;

/*  DEFINICION DE VARIABLES */
	DEFINE cCodRet CHAR(5);
	DEFINE dDia DATE;
	DEFINE cNum_confirmacion CHAR(16);
	DEFINE mImporte MONEY(16,2);
	DEFINE cForma_pago CHAR (20);
	DEFINE cFolio_op CHAR (16);
	DEFINE cSucursal CHAR (5);
	DEFINE cCajero CHAR (8);
	DEFINE cNom_benef CHAR (120);
	DEFINE iSqlerr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRows INTEGER;

/* INICIALIZACION DE VARIABLES */
	LET cCodRet = '00000';
	LET dDia = NULL;
	LET cNum_confirmacion = '';
	LET mImporte = 0.0;
	LET cForma_pago = '';
	LET cFolio_op = '';
	LET cSucursal = '';
	LET cCajero = '';
	LET cNom_benef = '';
	LET iSqlerr = 0 ;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	LET iNumRows = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportediarioremesasac.out';
		--TRACE ON;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		IF pUsuario = '' OR pIdFuncion = '' OR pPeriodo = '' OR pConvenio = '' OR pRegistros = '' OR pRecuperacion = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
			END IF;
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_movimientoshistorial
		WHERE  Fecha_Pago = pPeriodo
		AND status_cancelado = 'N';
		
		IF iNumRows <> 0 THEN
			IF pConvenio = '07004' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_diario(pPeriodo)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_diario(pPeriodo,pConvenio)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			ELIF pConvenio = '07009' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reporteapp_diario(pPeriodo)
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;				
							RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		END IF;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, 0, '', 0, '', '', '', '', '';
		END IF;
	END;
END PROCEDURE;