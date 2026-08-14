CREATE PROCEDURE "informix".sp_cce_actualizarfechacheques
(
pEmpresa            CHAR(3),
pFechaPresentacion  CHAR(10),
pCtaDelCheque       CHAR(20),
pNumCheque          CHAR(7),
pMonto              DECIMAL(14,2)
)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(80) 		AS desc_ret

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cDescRet		    CHAR(80);
    DEFINE cCodRet			CHAR(6);

	DEFINE mImporte		    MONEY(14,2);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cBanco			CHAR(3);
	DEFINE cDescBanco		CHAR(40);
    DEFINE dtFechaHoy       DATE;

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
    LET dtFechaHoy          = DATE(1);


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_actualizarfechacheques.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFechaPresentacion,"") = "" OR NVL(pCtaDelCheque,"") = "" OR NVL(pNumCheque,"") = "" OR pMonto IS NULL THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
	ELSE
        SELECT fecha_hoy
        INTO dtFechaHoy
        FROM "informix".sc_fechas
        WHERE empresa = pEmpresa;
    
        UPDATE bditef:"informix".cce_cheques_det
        SET fechapresenta = dtFechaHoy
        WHERE fechapresenta = pFechaPresentacion
        AND presentado = "0"
        AND numcuenta::INT8 = pCtaDelCheque::INT8
        AND numcheque = pNumCheque
        AND monto = pMonto;

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO SE ENCUENTRA EL CHEQUE PARA ACTUALIZAR";
            RETURN cCodRet,cDescRet;
        END IF
	END IF
    
    RETURN cCodRet,cDescRet;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para actusalizar la fecha de presentacion del cheque para que sea tomado en cuenta por el proceso de la presentacion', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130226.1911';

CREATE PROCEDURE "informix".sp_cce_consultarchequexpresentar
(
pEmpresa            CHAR(3),
pCtaDeposito        CHAR(20),
pNumCheque          INTEGER,
pFechaPresentacion  CHAR(10)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	MONEY(14,2)     AS importe,
	CHAR(20)        AS cuenta_cheque,
    CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco

	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE mImporte         MONEY(14,2);
	DEFINE cNumCuenta       CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchequexpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pCtaDeposito,"") = "" OR NVL(pNumCheque,"") = ""  OR NVL(pFechaPresentacion,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
	ELSE
        FOREACH	WITH HOLD
            SELECT doc.monto, doc.numcuenta, ba.banco, ba.descripcion
            INTO mImporte, cNumCuenta, cBanco, cDescBanco
            FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba
            WHERE doc.empresa = pEmpresa
            AND doc.banco = ba.banco
            AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
            AND doc.cancelado = "T"
            AND doc.banco = cce.cvebanco
            AND doc.numcuenta::INT8 = cce.numcuenta::INT8
            AND doc.num_chq = cce.numcheque::INTEGER
            AND cce.fechapresenta = pFechaPresentacion
            AND cce.presentado = "0"
            AND doc.cuenta::INT8 = pCtaDeposito::INT8
            AND doc.num_chq = pNumCheque
			
            RETURN cCodRet,cDescRet,NVL(mImporte,0),NVL(cNumCuenta,""),NVL(cBanco,""),NVL(cDescBanco,"") WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_cce_consultarchqsxpresentar
(
pEmpresa            CHAR(3)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	CHAR(4)         AS sucursal,
	CHAR(40)        AS desc_sucursal,
	CHAR(10)        AS fecha_presentacion,
	CHAR(20)        AS cuenta_deposito,
	CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco,
	CHAR(20)        AS cuenta_cheque,
	INTEGER        	AS numero_cheque,
	MONEY(14,2)     AS importe,
	CHAR(10)		AS fecha_hoy
	
	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE cSucursal		CHAR(4);
	DEFINE cDescSucursal	CHAR(40);
	DEFINE cFechaPres		CHAR(10);
	DEFINE cCtaDeposito		CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);
	DEFINE cCtaDelCheque    CHAR(20);
	DEFINE iNumCheque    	INTEGER;
	DEFINE mImporte         MONEY(14,2);
	DEFINE cFechaHoy		CHAR(10);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";
	
	LET cSucursal			= "";
	LET cDescSucursal		= "";
	LET cFechaPres			= "";
	LET cCtaDeposito		= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cCtaDelCheque		= "";
	LET iNumCheque    		= 0;
    LET mImporte		    = 0.0;
	LET cFechaHoy			= "";
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchqsxpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
	ELSE
		--OBTIENE LA FECHA DEL SISTEMA
		SELECT fecha_hoy
		INTO cFechaHoy
		FROM "informix".sc_fechas;
		
        FOREACH	WITH HOLD
			SELECT doc.sucursal, suc.nombre, cce.fechapresenta, doc.cuenta AS CTA_DEPOSITO, ba.banco, ba.descripcion, doc.numcuenta AS CTA_CHEQUE, doc.num_chq, doc.monto
			INTO cSucursal, cDescSucursal, cFechaPres, cCtaDeposito, cBanco, cDescBanco, cCtaDelCheque, iNumCheque, mImporte
			FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba, bdinteg:"informix".si_sucursales suc
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
			AND doc.cancelado = "T"
			AND doc.banco = cce.cvebanco
			AND doc.numcuenta::INT8 = cce.numcuenta::INT8
			AND doc.num_chq = cce.numcheque::INTEGER
			AND cce.fechapresenta < cFechaHoy
			AND cce.presentado = "0"
			AND doc.sucursal = suc.sucursal
			
            RETURN cCodRet,cDescRet,NVL(cSucursal,""),NVL(cDescSucursal,""),
				SUBSTR(cFechaPres,7,4) || "/" || SUBSTR(cFechaPres,1,2) || "/" || SUBSTR(cFechaPres,4,2),
				NVL(cCtaDeposito,""),NVL(cBanco,""),NVL(cDescBanco,""),NVL(cCtaDelCheque,""),NVL(iNumCheque,0),NVL(mImporte,0.0)
				,NVL(SUBSTR(cFechaHoy,7,4) || "/" || SUBSTR(cFechaHoy,1,2) || "/" || SUBSTR(cFechaHoy,4,2),"") 
			WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_actnumcheques() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet			CHAR(5);
DEFINE vi_SqlErr			INTEGER;
DEFINE vi_iSAMErr			INTEGER;
DEFINE vi_iSAMData			CHAR(80);
DEFINE vc_Mensaje			CHAR(80);
DEFINE cCuenta			    CHAR(20);
DEFINE inumeroconteo		INTEGER;
DEFINE inumerochq			INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET cCuenta="";
LET inumeroconteo=0;
LET inumerochq=0;


    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/chequeras/sp_actnumcheques.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT cuenta,max(numero) INTO cCuenta,inumeroconteo FROM sc_contch
		WHERE cuenta IN (
		SELECT DISTINCT cuenta FROM sc_contch)
		GROUP BY cuenta
		ORDER BY cuenta

		SELECT ult_chq INTO inumerochq FROM sc_maechq WHERE empresa='001' AND cuenta=cCuenta;
		
		IF inumeroconteo<>inumerochq THEN
			UPDATE "informix".sc_maechq SET ult_chq = inumeroconteo WHERE empresa='001' AND cuenta=cCuenta;
		END IF;

	END FOREACH;  

	RETURN vc_CodRet, vc_Mensaje;
END;
END PROCEDURE;