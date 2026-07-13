CREATE PROCEDURE "informix".sp_validarprestamosotorgadoscoppel (pEmpresa CHAR(03), pNumCteCoppel CHAR(20))
    RETURNING CHAR(5),  -- Codigo de retorno          
              CHAR(1)   -- Prestamo activo

    --DEFINICION DE VARIABLES
    DEFINE cCodret          CHAR(6);
    DEFINE iSqlerr          INTEGER;
    DEFINE cPrestamoActivo  CHAR(1);
    DEFINE cRespuesta		CHAR(1);
    DEFINE dFecha			DATE;

    LET cCodret             = '00001';
    LET iSqlerr             = 0;    
    LET cPrestamoActivo     = '0';
    LET cRespuesta    		= '';
    LET dFecha				= TODAY;

    --SET DEBUG FILE TO '/INFORMIXDUMP/sp_validarprestamosotorgadoscoppel.out';    
    --TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                LET cPrestamoActivo = '0';
                RETURN cCodRet, cPrestamoActivo;
            END IF;
        END EXCEPTION;

        IF NVL(pEmpresa, '') <> "" AND NVL(pNumCteCoppel, '') <> "" THEN
            SELECT fecha_hoy INTO dFecha
              FROM bdinteg:si_fechas;

            SELECT count(*) as prestamos INTO cRespuesta FROM ss_prestamoscoppel 
             WHERE numcte_ref=TRIM(pNumCteCoppel) AND fecha_contratacion=DATE(dFecha)
               AND (status_solicitud='A' OR status_solicitud='P');

            IF cRespuesta > 0 THEN
                LET cPrestamoActivo = '1';
            END IF;
        
            LET cCodret = '00000';
        END IF;

        RETURN cCodRet, cPrestamoActivo;

    END;
END PROCEDURE
