CREATE PROCEDURE "informix".sp_consulta_catdenominacion_bym_web(pOpcion CHAR(1), pDato CHAR(1))
RETURNING   CHAR(5)  AS CodRet,
			INTEGER  AS IdDenominacion,
			CHAR(1)  AS CvePieza,
			CHAR(7)  AS TipoPieza,
			CHAR(10) AS Denominacion;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE iIdDenominacion      INTEGER;
DEFINE cCvePieza        	CHAR(1);
DEFINE cTipoPieza           CHAR(7);
DEFINE cDenominacion        CHAR(10);
DEFINE iBandera             INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '00000';
LET iIdDenominacion		= 0;
LET cCvePieza           = '';
LET cTipoPieza          = '';
LET cDenominacion       = '';
LET iBandera            = 0;


 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_catdenominacion_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
		END IF;
	END EXCEPTION;

	SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pOpcion,''))= '1' OR TRIM(NVL(pOpcion,''))= '2' THEN
	
		IF TRIM(pOpcion) = '2' AND  TRIM(NVL(pDato,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			FOREACH
				SELECT id_denominacion, clave_pieza, tipo_pieza, denominacion
				INTO  iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion  
				FROM bdisuc:"informix".ss_denominacion_bym_falsos
				WHERE empresa = '001'
				AND	clave_pieza = CASE WHEN TRIM(pOpcion) = '2' THEN NVL(pDato,'') ELSE clave_pieza END
				
				LET iBandera =  1;
			
				RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
			END FOREACH;
			
			IF iBandera = 0 THEN
				LET cCodRet = '00002';
			END IF;
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	IF cCodRet <>  '00000' THEN
		RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
	END IF;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION: Consulta el catálogo de la tabla ss_denominacion_bym_falsos.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultarautoguardadopaquete_web(pEmpresa CHAR(3),pTipoPaquete CHAR(1))

	RETURNING CHAR(5) AS Cod_Retorno,
			  INTEGER AS TotalRegAutoguardado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCod_Ret CHAR(5);
	DEFINE iNumReg	INTEGER;
	DEFINE iSqlErr	INTEGER;
	
--INICIALIZACION DE VARIABLES
	LET cCod_Ret = '';
	LET iNumReg	 = 0;
	
	
BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN NVL(cCod_Ret,''),iNumReg;
        END IF;
    END  EXCEPTION;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarautoguardadopaquete.out";
	--TRACE ON;
	-----------------------------------------------------------------------


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		IF NVL(pEmpresa,'') = '' OR NVL(pTipoPaquete,'') = '' THEN
		
			LET  cCod_Ret  = '00001';
			
		ELSE
	
			SELECT NVL(num_registros_autoguardado,0) INTO iNumReg 
			FROM "informix".ss_cattipopaquetes
			WHERE empresa = pEmpresa AND tipopaquete = pTipoPaquete;
		
		
			LET  cCod_Ret  = '00000';
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = '00002';
				
			END IF;
			
		END IF;	
		
		RETURN NVL(cCod_Ret,''),NVL(iNumReg,0);
		
END
END PROCEDURE
DOCUMENT 
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA CONSULTAR EL NUMERO DE REGISTROS QUE PERMITE DEL AUTOGUARDADO DEPENDIENDO DEL TIPO DE PAQUETE',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_soldocta_web(
	pEmpresa  CHAR(3),
	pSucursal CHAR(4), 
	pcajeroprincipal CHAR(8),
	pFolioSuc CHAR(16),
	pTransacc CHAR(4),
	pDivisa   CHAR(2),
	pMonto 	  MONEY(14,2),
	pFecha 	  DATE,
	pDenom1   CHAR(18),
	pDenom2   CHAR(18),
	pDenom3   CHAR(18),
	pDenom4   CHAR(18),
	pDenom5   CHAR(18),
	pDenom6   CHAR(18),
	pDenom7   CHAR(18),
	pDenom8   CHAR(18),
	pDenom9   CHAR(18),
	pDenom10  CHAR(18),
	pDenom11  CHAR(18),
	pDenom12  CHAR(18),
	pDenom13  CHAR(18),
	pDenom14  CHAR(18),
	pDenom15  CHAR(18),
	pCant1 	  FLOAT(8),
	pCant2 	  FLOAT(8),
	pCant3 	  FLOAT(8),
	pCant4 	  FLOAT(8),
	pCant5 	  FLOAT(8),
	pCant6 	  FLOAT(8),
	pCant7 	  FLOAT(8),
	pCant8 	  FLOAT(8),
	pCant9 	  FLOAT(8),
	pCant10   FLOAT(8),
	pCant11   FLOAT(8),
	pCant12   FLOAT(8),
	pCant13   FLOAT(8),
	pCant14   FLOAT(8),
	pCant15   FLOAT(8))
	
	RETURNING CHAR(5), CHAR(8);

	DEFINE cCodRet 	  CHAR(5);
	DEFINE cFolio 	  CHAR(8);
	DEFINE iSqlErr 	  INTEGER; 
	DEFINE iIsamErr   INTEGER;
	DEFINE cHora 	  CHAR(5);
	DEFINE cProveedor CHAR(4);
	DEFINE cPlaza 	  CHAR(3);
	DEFINE iValor 	  INTEGER;
	DEFINE iDenom1    INTEGER;
	DEFINE iDenom2    INTEGER;
	DEFINE iDenom3    INTEGER;
	DEFINE iDenom4    INTEGER;
	DEFINE iDenom5    INTEGER;
	DEFINE iDenom6    INTEGER;
	DEFINE iDenom7    INTEGER;
	DEFINE iDenom8    INTEGER;
	DEFINE iDenom9    INTEGER;
	DEFINE iDenom10   INTEGER;
	DEFINE iDenom11   INTEGER;
	DEFINE iDenom12   INTEGER;
	DEFINE iDenom13   INTEGER;
	DEFINE iDenom14   INTEGER;
	DEFINE iDenom15   INTEGER;	
	DEFINE iTotal1    INTEGER;
	DEFINE iTotal2    INTEGER;
	DEFINE iTotal3    INTEGER;
	DEFINE iTotal4    INTEGER;
	DEFINE iTotal5    INTEGER;
	DEFINE iTotal6    INTEGER;
	DEFINE iTotal7    INTEGER;
	DEFINE iTotal8    INTEGER;
	DEFINE iTotal9    INTEGER;
	DEFINE iTotal10   INTEGER;
	DEFINE iTotal11   INTEGER;
	DEFINE iTotal12   INTEGER;
	DEFINE iTotal13   INTEGER;
	DEFINE iTotal14   INTEGER;
	DEFINE iTotal15   INTEGER;
	DEFINE iSumTotal  INTEGER;
	DEFINE bTransacInterAct	CHAR(1);
	DEFINE bEnTransac CHAR(1);
	
	LET cHora 	   = SUBSTR(CURRENT, 12, 5);
	LET cCodRet    = '00000';
	LET cProveedor = '';
	LEt cPlaza 	   = '';
	LET cFolio     = '';
	LET iValor 	   = 0;
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET iDenom1    = pDenom1;
	LET iDenom2    = pDenom2;
	LET iDenom3    = pDenom3;
	LET iDenom4    = pDenom4;
	LET iDenom5    = pDenom5;
	LET iDenom6    = pDenom6;
	LET iDenom7    = pDenom7;
	LET iDenom8    = pDenom8;
	LET iDenom9    = pDenom9;
	LET iDenom10   = pDenom10;
	LET iDenom11   = pDenom11;
	LET iDenom12   = pDenom12;
	LET iDenom13   = pDenom13;
	LET iDenom14   = pDenom14;
	LET iDenom15   = pDenom15;
	LET iTotal1    = 0;
	LET iTotal2    = 0;
	LET iTotal3    = 0;
	LET iTotal4    = 0;
	LET iTotal5    = 0;
	LET iTotal6    = 0;
	LET iTotal7    = 0;
	LET iTotal8    = 0;
	LET iTotal9    = 0;
	LET iTotal10   = 0;
	LET iTotal11   = 0;
	LET iTotal12   = 0;
	LET iTotal13   = 0;
	LET iTotal14   = 0;
	LET iTotal15   = 0;
	LET iSumTotal  = 0;
	LET bTransacInterAct = 'F';
	LET bEnTransac = 'F';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				IF bTransacInterAct = 'T' THEN		--DSB20150429 {
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						BEGIN WORK;
					END IF;
				ELSE
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
					END IF;							
				END IF;	
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet, cFolio;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		COMMIT WORK;
		BEGIN WORK;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/Ricardo/log_soldocta.out';
		--TRACE ON;
		
		BEGIN WORK;
	
		--VALIDA LA RECEPCION DE LOS DATOS
		IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
			pSucursal = '0' OR pSucursal = '' OR
			pDivisa   = '0' OR pDivisa   = '' OR 
			pcajeroprincipal = '0' OR pcajeroprincipal = '' OR 
			pFolioSuc = '0' OR pFolioSuc = '' OR 
			pTransacc = '0' OR pTransacc = '' OR 
			pMonto    = 0                     THEN 
			LET cCodRet = '00110';
		
		ELSE
			
			IF iDenom1 IS NULL OR iDenom1 = '' THEN
				LET iDenom1 = 0;
			END IF;
			IF iDenom2 IS NULL OR iDenom2 = '' THEN
				LET iDenom2 = 0;
			END IF;
			IF iDenom3 IS NULL OR iDenom3 = '' THEN
				LET iDenom3 = 0;
			END IF;
			IF iDenom4 IS NULL OR iDenom4 = '' THEN
				LET iDenom4 = 0;
			END IF;
			IF iDenom5 IS NULL OR iDenom5 = '' THEN
				LET iDenom5 = 0;
			END IF;
			IF iDenom6 IS NULL OR iDenom6 = '' THEN
				LET iDenom6 = 0;
			END IF;
			IF iDenom7 IS NULL OR iDenom7 = '' THEN
				LET iDenom7 = 0;
			END IF;
			IF iDenom8 IS NULL OR iDenom8 = '' THEN
				LET iDenom8 = 0;
			END IF;
			IF iDenom9 IS NULL OR iDenom9 = '' THEN
				LET iDenom9 = 0;
			END IF;
			IF iDenom10 IS NULL OR iDenom10 = '' THEN
				LET iDenom10 = 0;
			END IF;
			IF iDenom11 IS NULL OR iDenom11 = '' THEN
				LET iDenom11 = 0;
			END IF;
			IF iDenom12 IS NULL OR iDenom12 = '' THEN
				LET iDenom12 = 0;
			END IF;
			IF iDenom13 IS NULL OR iDenom13 = '' THEN
				LET iDenom13 = 0;
			END IF;
			IF iDenom14 IS NULL OR iDenom14 = '' THEN
				LET iDenom14 = 0;
			END IF;
			IF iDenom15 IS NULL OR iDenom15 = '' THEN
				LET iDenom15 = 0;
			END IF;
			
			LET iTotal1	   = iDenom1  * pCant1;
			LET iTotal2	   = iDenom2  * pCant2;
			LET iTotal3	   = iDenom3  * pCant3;
			LET iTotal4	   = iDenom4  * pCant4;
			LET iTotal5	   = iDenom5  * pCant5;
			LET iTotal6	   = iDenom6  * pCant6;
			LET iTotal7	   = iDenom7  * pCant7;
			LET iTotal8	   = iDenom8  * pCant8;
			LET iTotal9	   = iDenom9  * pCant9;
			LET iTotal10   = iDenom10 * pCant10;
			LET iTotal11   = iDenom11 * pCant11;
			LET iTotal12   = iDenom12 * pCant12;
			LET iTotal13   = iDenom13 * pCant13;
			LET iTotal14   = iDenom14 * pCant14;
			LET iTotal15   = iDenom15 * pCant15;
			LET iSumTotal  = iTotal1  + iTotal2  +
							 iTotal3  + iTotal4  +
							 iTotal5  + iTotal6  +
							 iTotal7  + iTotal8  +
							 iTotal9  + iTotal10 +
							 iTotal11 + iTotal12 +
							 iTotal13 + iTotal14 +
							 iTotal15;
							 
			--VALIDA MONTO VS DESGLOSE DENOMINACIONES
			IF pMonto <> iSumTotal THEN
				LET cCodRet = '00115';
				RETURN cCodRet, cFolio;
			END IF;
			
			SELECT plaza_cajagen INTO cPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;

			SELECT cod_proveedor INTO cProveedor FROM bdisuc:"informix".ss_proveedores WHERE plaza = cPlaza;
		
			IF cProveedor IS NOT NULL THEN
				
				SELECT valor INTO iValor FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0005';
				
				LET cFolio = LPAD(iValor, 8, '0');
				
				INSERT INTO bdisuc:"informix".ss_operaciones (empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto,
				denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15, 
				cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14, cantidad_15)
				VALUES (pEmpresa, pTransacc, pFecha, pSucursal, pFolioSuc, cFolio, '0', pcajeroprincipal, pDivisa, pMonto,
				pDenom1, pDenom2, pDenom3, pDenom4, pDenom5, pDenom6, pDenom7, pDenom8, pDenom9, pDenom10, pDenom11, pDenom12, pDenom13, pDenom14, pDenom15, 
				pCant1, pCant2, pCant3, pCant4, pCant5, pCant6, pCant7, pCant8, pCant9, pCant10, pCant11, pCant12, pCant13, pCant14, pCant15);
				
				INSERT INTO bdisuc:"informix".ss_mae_entradasalida (empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, status, monto)
				VALUES (pEmpresa, cProveedor, cFolio, pSucursal, pFolioSuc, pFecha, cHora, pcajeroprincipal, '01', pMonto);
				
			ELSE
				LET cCodRet = '00105';
				RETURN cCodRet, cFolio;
			END IF;
		END IF;
		
		COMMIT WORK;
		IF bTransacInterAct = 'T' THEN
			BEGIN WORK;
		END IF;
	
		RETURN cCodRet, cFolio;
	END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:DotaCG.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-20',
'DESCRIPCION: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_valfolio_web(
	pEmpresa  CHAR(3),
	pSucursal CHAR(4),
	pcajeroprincipal  CHAR(8),   --- se respeta el nombre de la varible porque se revisa el servicio y tiene el mismo nombre
								 --- el nombre que tiene el SP original es "pEmpleado"
	pFolioOpe CHAR(8),
	pDivisa   CHAR(2),
	pMonto    MONEY(14,2))
	
RETURNING CHAR(5);

DEFINE iSqlErr   INTEGER;
DEFINE iIsamErr  INTEGER;
DEFINE cCodRet   CHAR(5);
DEFINE cSucursal CHAR(4);
DEFINE cStatus   CHAR(2);
DEFINE mMonto    MONEY(14,2);

LET cCodRet   = '00000';
LET cSucursal = '';
LET cStatus   = '';
LET mMonto    = 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/JEPI/sp_valfolio.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
		pSucursal = '0' OR pSucursal = '' OR
		pDivisa   = '0' OR pDivisa   = '' OR 
		pcajeroprincipal = '0' OR pcajeroprincipal = '' OR 
		pMonto    = 0 OR pFolioOpe   = '' THEN
			LET cCodRet = '00110';
	ELSE
		SELECT sucursal, status, monto INTO cSucursal, cStatus, mMonto FROM bdisuc:"informix".ss_mae_entradasalida WHERE folio_oper = pFolioOpe;
		
		IF cSucursal IS NULL THEN
			LET cCodRet = '00100';
			RETURN cCodRet;
		ELSE		
			IF cSucursal <> pSucursal THEN
				LET cCodRet = '00560';
				RETURN cCodRet;
			END IF;
			
			IF mMonto <> pMonto THEN
				LET cCodRet = '00102';
				RETURN cCodRet;
			END IF;

			IF cStatus <> '11' THEN
				IF cStatus = '08' THEN
					LET cCodRet = '00103';
					RETURN cCodRet;
				ELSE
					LET cCodRet = '00104';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
	END IF;
	
	RETURN cCodRet;
END;
END PROCEDURE;