CREATE PROCEDURE "informix".sp_cce_consultarchequesmovs
(
pEmpresa    CHAR(3),
pFecha      CHAR(10)
)
RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(3) 		AS banco,
	CHAR(40) 		AS desc_banco,
	CHAR(40) 		AS referencia,
	INTEGER 		AS num_cheque,
	DECIMAL(14,2) 	AS monto_orig,
	DATE 			AS fecha_alta,
	DATETIME HOUR TO FRACTION(3) AS hora,
	CHAR(44) 		AS sucursal,
	SMALLINT 		AS dias_ret,
	CHAR(16) 		AS folio_suc,
	CHAR(4) 		AS transcc,
	CHAR(4) 		AS cve_suc

	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
	
	DEFINE cBanco			CHAR(3);
	DEFINE cDescBanco		CHAR(40);
	DEFINE cReferencia		CHAR(40);
	DEFINE iNumcheque		INTEGER;
	DEFINE dMontoOrig		DECIMAL(14,2);
	DEFINE cFechaAlta		DATE;
	DEFINE cHora			DATETIME HOUR TO FRACTION(3);	
	DEFINE cSucursal		CHAR(44);
	DEFINE sDiasRet			SMALLINT;
	DEFINE cFolioSuc		CHAR(16);
	DEFINE cTransacc		CHAR(4);
	DEFINE cCveSucursal		CHAR(4);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cReferencia			= "";
	LET iNumcheque			= 0;
	LET dMontoOrig			= 0.0;
	LET cFechaAlta			= DATE(1);
	LET cHora				= CURRENT HOUR TO FRACTION(3);
	LET cSucursal			= "";
	LET sDiasRet			= 0;
	LET cFolioSuc			= "";
	LET cTransacc			= "";
	LET cCveSucursal		= "";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumcheque, dMontoOrig, cFechaAlta, cHora,
				cSucursal, sDiasRet, cFolioSuc, cTransacc, cCveSucursal;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchequesmovs.out';
--	TRACE ON;


	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" THEN
        -- FALTA EMPRESA O FECHA
        LET cCodRet = "000001";
        RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumcheque, dMontoOrig, cFechaAlta, cHora,
			cSucursal, sDiasRet, cFolioSuc, cTransacc, cCveSucursal;
	ELSE
        FOREACH WITH HOLD
			SELECT UNIQUE ba.banco, ba.descripcion, doc.referencia, doc.num_chq, doc.monto_ori, doc.fecha_alta, doc.fech_hor,
			suc.sucursal || " " || suc.nombre, doc.dias_ret, doc.folio_suc, doc.transacc, suc.sucursal
			INTO cBanco, cDescBanco, cReferencia, iNumcheque, dMontoOrig, cFechaAlta, cHora,
			cSucursal, sDiasRet, cFolioSuc, cTransacc, cCveSucursal
			FROM bdicheq:sc_docret_sbc doc, bdinteg:si_bancos ba, bdinteg:si_sucursales suc 
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco 
			AND doc.sucursal = suc.sucursal 
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban) 
			AND doc.cancelado = "T"
			AND doc.fecha_alta = pFecha
			ORDER BY doc.fecha_alta, doc.fech_hor

			RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumcheque, dMontoOrig, cFechaAlta, cHora,
				cSucursal, sDiasRet, cFolioSuc, cTransacc, cCveSucursal WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta los datos de los cheques del catalogo de documentos de cheques',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_borrar_sc_docret
( 
)
RETURNING 
	CHAR(5), 
	CHAR(5), 
	CHAR(50), 
	INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vempieza         SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vCuenta CHAR(20);
    DEFINE vmin_serial      INTEGER;
    DEFINE vmax_serial      INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vempieza     = -1;
    LET ven_transacc = 0; 
    
    LET vCuenta = "";
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borrar_sc_docret.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_borrar_sc_docret.out";
    --- TRACE ON;
    
    set optimization high;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH cursor_borra WITH HOLD FOR
		SELECT UNIQUE cuenta
		INTO vCuenta
		FROM sc_docret
		WHERE siglas IN ('SC','SD')
		AND transacc IN ('0250','6250')
           
        IF vempieza = -1 THEN
            LET vempieza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_docret 
        WHERE cuenta = vCuenta
		AND siglas IN ('SC','SD')
		AND transacc IN ('0250','6250');
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 5000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador2 = 0;
        LET ven_transacc = 0;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;