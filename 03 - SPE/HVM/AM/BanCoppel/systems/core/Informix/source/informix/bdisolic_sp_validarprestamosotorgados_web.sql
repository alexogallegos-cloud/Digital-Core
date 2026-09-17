CREATE PROCEDURE "informix".sp_validarprestamosotorgados_web(pEmpresa CHAR(3), 
															 pNumCte CHAR(20))
RETURNING CHAR(5),  -- CÃ³digo de retorno          
          CHAR(1)   -- PrÃ©stamo vigente

    --DEFINICION DE VARIABLES
    DEFINE cCodret          CHAR(5);
	DEFINE iSqlerr          INTEGER;
    DEFINE cPrestamoVigente CHAR(1);
	DEFINE cRespuesta		CHAR(1);
    DEFINE dFecha			DATE;

    LET cCodret             = '00001';
	LET iSqlerr             = 0;    
	LET cPrestamoVigente    = '0';
	LET cRespuesta    		= '';
    LET dFecha				= TODAY;

BEGIN
    ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            LET cPrestamoVigente = '0';
			RETURN cCodRet, cPrestamoVigente;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/INFORMIXDUMP/sp_validarprestamosotorgados_web.trc';    
    --TRACE ON;

    IF NVL(pEmpresa, '') <> "" AND NVL(pNumCte, '') <> "" THEN
        SELECT {+INDEX(bdinteg: "informix".si_fechas idx_si_fechas)} fecha_hoy 
			INTO dFecha
        FROM bdinteg: si_fechas;

        SELECT '1' INTO cRespuesta FROM ss_solicitudes AS sol
        INNER JOIN ss_autorizacion AS aut 
            ON sol.num_solicitud = aut.num_solicitud AND sol.status_solicitud = aut.status_solicitud
        WHERE sol.numcte = pNumCte 
		AND sol.num_producto IN (6300,6400,6800,7600,7700,9100,9300) 
		AND (sol.status_solicitud IN ('PA','AT') OR (sol.status_solicitud = 'AP'
		AND DATE(aut.fecha_hora) = DATE(dFecha)));

        IF dbinfo("sqlca.sqlerrd2") > 0 THEN
            LET cPrestamoVigente = '1';
        END IF;
        
        LET cCodret = '00000';
    END IF;

    RETURN cCodRet, cPrestamoVigente;
END;
END PROCEDURE
