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