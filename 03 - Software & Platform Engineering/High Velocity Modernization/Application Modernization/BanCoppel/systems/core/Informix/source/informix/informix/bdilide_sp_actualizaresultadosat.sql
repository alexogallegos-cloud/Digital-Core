CREATE PROCEDURE "informix".sp_actualizaresultadosat(pRFC CHAR(13))
RETURNING CHAR(6), CHAR(60);

    -- // DEFINICIONES
    DEFINE cCodRet        	CHAR(6);
    DEFINE iSql_Err       	INTEGER;
    DEFINE cMensaje  		CHAR(60);
    DEFINE dFechaHoy       	DATE;
    DEFINE cNumCte         	CHAR(20);
    DEFINE cStatus         	CHAR(1);
    DEFINE vexiste          INTEGER;

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        RETURN cCodRet,'';
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIONES
    LET iSql_Err       	= 0;
    LET cCodRet        	= '000';
    LET cMensaje 		= '';
    LET dFechaHoy      	= '';
    LET pRFC           	= TRIM(pRFC);
    LET cNumCte        	= '';
    LET cStatus        	= '0';
    LET vexiste         = 0;

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_actualizaresultadosat.out";
    --- TRACE ON;

    BEGIN

    IF TRIM(pRFC) <> '' AND pRFC IS NOT NULL THEN		
        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM bdicheq:"informix".sc_fechas
         WHERE empresa = '001';
         
        SELECT num_cte   
          INTO cNumCte   
          FROM bdilide:"informix".sl_consat 
         WHERE estado = 'E' 
           AND rfc = pRFC;

        IF cNumCte <> '' OR cNumCte IS NOT NULL THEN
            -- // Actualiza el registros por medio de su RFC.
            UPDATE bdilide:"informix".sl_consat 
               SET estado = 'C' , 
                   fecha_res = dFechaHoy 
             WHERE estado = 'E'  
               AND rfc = pRFC;
               
            SELECT COUNT(*)
              INTO vexiste
              FROM bdilide:"informix".sl_exentos 
             WHERE num_cte = cNumCte;

            IF vexiste > 0 THEN
            --- IF EXISTS(SELECT num_cte FROM bdilide:"informix".sl_exentos WHERE num_cte = cNumCte) THEN
                SELECT status 
                  INTO cStatus 
                  FROM sl_exentostemp 
                 WHERE num_cte = cNumCte;

                UPDATE bdilide:"informix".sl_exentos 
                   SET rfc = pRFC, 
                       fech_cambio = dFechaHoy, 
                       status = cStatus 
                 WHERE num_cte = cNumCte;
            ELSE
                -- // Se insertan los registros validados en la tabla sl_exentos.
                INSERT INTO bdilide:"informix".sl_exentos(num_cte,rfc,status,fech_cambio,user_insert,fecha_insert)
                SELECT num_cte,rfc,status,fech_cambio,user_insert,fecha_insert 
                  FROM sl_exentostemp 
                 WHERE rfc = pRFC;
            END IF;

            LET cCodRet = '000';
            LET cMensaje = 'Actualizacion Terminada';
            RETURN cCodRet,cMensaje;
        ELSE
            LET cCodRet = '001';
            LET cMensaje = 'No existe el RFC en estado E';
            RETURN cCodRet,cMensaje;				
        END IF;			
    ELSE
        LET cCodRet = '002';
        LET cMensaje = 'Debe mandar el RFC';
        RETURN cCodRet,cMensaje;
    END IF;  
    
    END;

END PROCEDURE

