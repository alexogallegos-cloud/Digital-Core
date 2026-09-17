CREATE PROCEDURE "informix".sp_cce_consultar_chequespresentados_pba
(
pEmpresa    CHAR(3),
pFecha      CHAR(8),
pNomArchivo CHAR(22)
)
RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(3) 		AS banco,
	CHAR(40) 		AS nom_banco,
	CHAR(40) 		AS referencia,
	INTEGER 		AS num_cheque,
	DECIMAL(14,2) 	AS monto_orig,
	CHAR(20) 		AS cuenta,
	CHAR(44) 		AS sucursal,
	CHAR(4) 		AS transacc
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	
	DEFINE cBanco			CHAR(3);
	DEFINE cNomBanco		CHAR(40);
	DEFINE cReferencia		CHAR(40);
	DEFINE iNumCheque		INTEGER;
	DEFINE dMontoOrig		DECIMAL(14,2);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(44);
	DEFINE cTransacc		CHAR(4);



	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo			= "";
	LET cCodRet             = "000000";
	
	LET cBanco				= "";
	LET cNomBanco			= "";
	LET cReferencia			= "";
	LET iNumCheque			= 0;
	LET dMontoOrig			= 0.0;
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET cTransacc			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequespresentados.out';
--	TRACE ON;



	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR NVL(pNomArchivo,"") = "" THEN
        -- FALTAN UNO O MAS PARAMETROS
        LET cCodRet = "000001";
		RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
	ELSE
        FOREACH WITH HOLD
			SELECT ba.banco, ba.descripcion, doc.referencia, doc.num_chq, doc.monto_ori, doc.cuenta, suc.sucursal || " " || suc.nombre,doc.transacc  
			INTO cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc
			FROM bdicheq:sc_docret_sbc doc, 
                 bdinteg:si_bancos ba, 
                 bdinteg:si_sucursales suc, 
                 bditef:cce_detalle cce
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco  
			AND doc.sucursal = suc.sucursal  
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban)  
			AND doc.cancelado = "T"
			AND doc.banco = cce.bco_receptor
			AND doc.numcuenta::INT8 = cce.num_cuenta::INT8
			AND doc.num_chq = cce.num_cheque::INTEGER
            AND doc.cuenta = cce.cuenta_dep
			AND cce.fecha_transfer = pFecha  
			AND cce.cod_operacion = "40"
			AND cce.nombrearchivo= pNomArchivo
		
            RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta los cheques presentados a la cámara de compensación eletrónica',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".reverso_atm( psucursal CHAR(4),   --- Sucursal
                                         pfolio    CHAR(16) ) --- Folio Operacion
RETURNING CHAR(5); --- Codigo de Retorno

    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE viDescErr    CHAR(50);
    DEFINE viEnTransac  SMALLINT;
    DEFINE viReversado  SMALLINT;
    DEFINE vcCodRetRev  CHAR(5);
    
    LET vcCodRet1   = '00000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET viDescErr   = 0;
    LET viEnTransac = 0;
    LET viReversado = 0;
    LET vcCodRetRev = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/reverso_atm.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, viDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/reverso_atm.err';
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = viDescErr;
            IF viEnTransac = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            LET vcCodRet1 = '00999';
            RETURN vcCodRet1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET viEnTransac = 1;
    END EXCEPTION WITH resume;

    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
    
    IF ( psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00110';
        RETURN vcCodRet1;
    END IF;
    
    SELECT COUNT(*)
      INTO viReversado
      FROM bdicheq:"informix".sc_movdia
     WHERE cancelad = 'S'
       AND folio_suc = pfolio;
       
    IF viReversado > 0 THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00005';
        RETURN vcCodRet1;
    END IF;
    
    EXECUTE PROCEDURE bdicheq:reversion('001', psucursal, 'informix', pfolio, 'A')
    INTO vcCodRetRev;
    
    IF vcCodRetRev <> '000' THEN
        IF vcCodRetRev = '413' THEN
            LET vcCodRet1 = '00413';
        END IF;
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcCodRet1;
    END IF;
    
    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    END;
    
    RETURN vcCodRet1;

END PROCEDURE;