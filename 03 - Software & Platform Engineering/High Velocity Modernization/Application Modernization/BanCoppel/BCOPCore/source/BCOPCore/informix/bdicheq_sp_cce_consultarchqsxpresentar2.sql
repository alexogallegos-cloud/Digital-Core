CREATE PROCEDURE "informix".sp_cce_consultarchqsxpresentar2(pEmpresa CHAR(3),pRegistros INTEGER, pRecuperacion INTEGER)
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
      DROP TABLE IF EXISTS cce_consultarchqsxpresentar2_table_tmp;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchqsxpresentar.out';
	--TRACE ON;
 
  		--OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO cFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = pEmpresa;
 
	FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion doc.sucursal, suc.nombre, cce.fechapresenta, doc.cuenta AS CTA_DEPOSITO, ba.banco, ba.descripcion, doc.numcuenta AS CTA_CHEQUE, doc.num_chq, doc.monto_ori
		INTO cSucursal, cDescSucursal, cFechaPres, cCtaDeposito, cBanco, cDescBanco, cCtaDelCheque, iNumCheque, mImporte
		FROM bdicheq:"informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba, bdinteg:"informix".si_sucursales suc
		WHERE doc.empresa = pEmpresa
		AND doc.banco = ba.banco
		AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
		AND doc.cancelado = "T"
		AND doc.banco = cce.cvebanco
		AND doc.numcuenta = cce.numcuenta
		AND doc.num_chq = cce.numcheque
		AND cce.fechapresenta < cFechaHoy
		AND cce.presentado = "0"
		AND doc.sucursal = suc.sucursal

		RETURN cCodRet,cDescRet,NVL(cSucursal,""),NVL(cDescSucursal,""),
			SUBSTR(cFechaPres,7,4) || "/" || SUBSTR(cFechaPres,1,2) || "/" || SUBSTR(cFechaPres,4,2),
			NVL(cCtaDeposito,""),NVL(cBanco,""),NVL(cDescBanco,""),NVL(cCtaDelCheque,""),NVL(iNumCheque,0),NVL(mImporte,0.0)
			,NVL(SUBSTR(cFechaHoy,7,4) || "/" || SUBSTR(cFechaHoy,1,2) || "/" || SUBSTR(cFechaHoy,4,2),"") 
		WITH RESUME;

	END FOREACH

 			

	IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
	ELSE
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
        END IF
	END IF
 
END;

END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN CHEQUES SBC', 
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cce_consultarchqsxpresentar2_totales
(
	pEmpresa            CHAR(3)
)
RETURNING
	CHAR(6)         AS cod_ret,
	INTEGER 		AS no_registros
	
	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE cFechaHoy		CHAR(10);
	DEFINE iNoRegistros		INTEGER;
	DEFINE cCmd1 CHAR(3500);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";
	
	LET cFechaHoy			= "";
	LET iNoRegistros 		= 0;
	LET cCmd1 				= "";
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,iNoRegistros;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchqsxpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,iNoRegistros;
	ELSE
		--OBTIENE LA FECHA DEL SISTEMA
		SELECT fecha_hoy
		INTO cFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
        --FOREACH	WITH HOLD
		LET cCmd1 = "";
        LET cCmd1 = ""||TRIM(cCmd1)||"SELECT COUNT(*) FROM bdicheq:""informix"".sc_docret_sbc doc, bditef:""informix"".cce_cheques_det cce, bdinteg:""informix"".si_bancos ba, bdinteg:""informix"".si_sucursales suc ";
        LET cCmd1 = ""||TRIM(cCmd1)||" WHERE doc.empresa = '"||pEmpresa||"' AND doc.banco = ba.banco AND doc.transacc IN (SELECT transacc FROM bditef:""informix"".cce_mapeo_cecoban where empresa = '"||pEmpresa||"' and transacc = transacc and tipo_cta_dep = tipo_cta_dep) ";
        LET cCmd1 = ""||TRIM(cCmd1)||" AND doc.cancelado = ""T"" AND doc.banco = cce.cvebanco AND doc.numcuenta::INT8 = cce.numcuenta::INT8 AND doc.num_chq = cce.numcheque::INTEGER AND cce.fechapresenta < '"||cFechaHoy||"' ";
        LET cCmd1 = ""||TRIM(cCmd1)||" AND cce.presentado = ""0"" AND doc.sucursal = suc.sucursal ";
 
        PREPARE registrosQry FROM TRIM(cCmd1);
        DECLARE registrosCur CURSOR FOR registrosQry;
        OPEN registrosCur;
 
        FETCH registrosCur INTO iNoRegistros;
        
        CLOSE registrosCur;
        FREE registrosCur;
        FREE registrosQry;     
			
        RETURN cCodRet,iNoRegistros;
        --END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,iNoRegistros;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN CHEQUES SBC', 
'DESCRIPCION: Proceso para obtener el numero total de cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicheq';

CREATE PROCEDURE "informix".call_abono_ref( pempresa     CHAR(3),
                                       psucursal    CHAR(4),
                                       pusuario     CHAR(8),
                                       ptransacc    CHAR(4),
                                       ptransuc     CHAR(4),
                                       pfolio_suc   CHAR(16),
                                       pcuenta      CHAR(20),
                                       pdocto       INTEGER,
                                       pmto_tot     MONEY(14,2),
                                       pmto_firme   MONEY(14,2),
                                       pmto_sbc     MONEY(14,2),
                                       pmto_rem     MONEY(14,2),
                                       pdias_ret    SMALLINT,
                                       pdivisa      CHAR(2),
                                       preferencia  CHAR(40),
                                       pnum_tarjeta CHAR(16),
                                       pusuautoriza CHAR(8) )
RETURNING CHAR(5) as vcodret;
    
    DEFINE vcodret              CHAR(5); 
    
    
    LET vcodret         = "000";
    
BEGIN
    
    EXECUTE PROCEDURE "informix".abono_ref( pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolio_suc, 
    	pcuenta, pdocto, pmto_tot, pmto_firme,pmto_sbc, pmto_rem, pdias_ret, pdivisa, preferencia, pnum_tarjeta, pusuautoriza) 
        into vcodret;
    
    RETURN vcodret;
end;
END PROCEDURE;