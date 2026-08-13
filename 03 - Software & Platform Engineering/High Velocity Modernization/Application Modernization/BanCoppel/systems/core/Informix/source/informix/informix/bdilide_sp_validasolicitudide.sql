CREATE PROCEDURE "informix".sp_validasolicitudide(pRFC CHAR(13), pfecha CHAR(10))
RETURNING CHAR(6), CHAR(60);

    -- // DEFINICIONES
    DEFINE cCodRet     CHAR(6);
    DEFINE isql_err    INTEGER;
    DEFINE cMensaje    CHAR(60);
    DEFINE vFechaSolic VARCHAR(10);
    DEFINE vexiste     INTEGER;

    ON EXCEPTION SET isql_err
        LET cCodRet = isql_err;
        RETURN cCodRet,'';
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIONES
    LET cCodRet     = '000';
    LET isql_err    = 0;
    LET cMensaje    = '';
    LET vFechaSolic = '';
    LET pRFC        = TRIM(pRFC);
    LET pfecha      = TRIM(pfecha);
    LET vexiste     = 0;

	--SET DEBUG FILE TO "/home/sysifx/Josue/sp_validasolicitudide.out";
	--TRACE ON;

    BEGIN

    -- // Valida si se enviaron bien los parametros.
    IF TRIM(pRFC) <> "" AND pRFC IS NOT NULL AND TRIM(pfecha) <> "" AND pfecha IS NOT NULL THEN
        
		--LET pfecha = SUBSTRING (pfecha FROM 7 FOR 4) || SUBSTRING (pfecha FROM 1 FOR 2);

        -- // Verifica si existe el RFC en la sl_consat
        SELECT COUNT(*)
          INTO vexiste
          FROM bdilide:"informix".sl_consat 
         WHERE rfc = pRFC
           AND fecha_sol IS NOT NULL; 

        IF vexiste > 0 THEN
		
			LET cCodRet = '001';
			LET cMensaje = 'EXISTE REGISTRO EN LA TABLA...';
			RETURN cCodRet,cMensaje;
		/*
        --- IF EXISTS(SELECT rfc FROM bdilide:"informix".sl_consat WHERE rfc = pRFC) THEN
            -- // Obtiene la fecha maxima.
            SELECT MAX(SUBSTRING(fecha_sol FROM 7 FOR 4) || SUBSTRING (fecha_sol FROM 1 FOR 2))
              INTO vFechaSolic
              FROM bdilide:"informix".sl_consat 
             WHERE rfc = pRFC
               AND fecha_sol is not null;

            IF vFechaSolic IS NULL OR vFechaSolic = '' THEN
                LET cCodRet = '004';
                LET cMensaje = 'No existe registro en la tabla.';
                RETURN cCodRet,cMensaje;
            END IF;

            IF vFechaSolic IS NULL THEN
                LET vFechaSolic = '';
            END IF;

            IF TRIM(vFechaSolic) = TRIM(pfecha) THEN
                LET cCodRet = '001';
                LET cMensaje = 'La fecha de solicitud no deve ser del mismo mes.';
                RETURN cCodRet,cMensaje;
            ELSE
                LET cCodRet = '000';
                LET cMensaje = 'Ejecucion Exitosa.';
                RETURN cCodRet,cMensaje;
            END IF;
        END IF;
		*/
		ELSE
			LET cCodRet = '000';
			LET cMensaje = 'NO EXIXTE REGISTRO EN LA TABLA...';
			RETURN cCodRet,cMensaje;
		END IF;
    ELSE
        LET cCodRet = '002';
        LET cMensaje = 'DEBE ESCRIBIR RFC O FECHA.';
        RETURN cCodRet,cMensaje;
    END IF;

    RETURN cCodRet,cMensaje;     
END;
END PROCEDURE
