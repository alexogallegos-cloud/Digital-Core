CREATE PROCEDURE "informix".sp_actualizainformesat(pRFC CHAR(13))
RETURNING CHAR(6), CHAR(60);

    -- // DEFINICIONES
    DEFINE cCodRet         	CHAR(6);
    DEFINE iSql_Err         INTEGER;
    DEFINE cMensaje  		CHAR(60);
    DEFINE dFechaHoy       	DATE;

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        RETURN cCodRet,'';
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIONES
    LET iSql_Err 	= 0;
    LET cCodRet 	= '000';
    LET cMensaje 	= '';
    LET dFechaHoy 	= '';
    LET pRFC 		= TRIM(pRFC);

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_actualizainformesat.out";
    --- TRACE ON;

    BEGIN

    IF TRIM(pRFC) <> '' AND pRFC IS NOT NULL THEN
        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM bdicheq:"informix".sc_fechas
         WHERE empresa = '001';

        -- // Actualiza el registros por medio de su RFC.
        UPDATE bdilide:"informix".sl_exentos 
           SET status = '7' , fech_cambio = dFechaHoy 
         WHERE num_cte is not null
           AND rfc = pRFC;

        LET cCodRet = '000';
        LET cMensaje = 'Actualizacion Exitosa';
        RETURN cCodRet,cMensaje;
    ELSE
        LET cCodRet = '002';
        LET cMensaje = 'Debe mandar el RFC';
        RETURN cCodRet,cMensaje;
    END IF;

    END;
    
END PROCEDURE

