CREATE PROCEDURE "informix".sp_consultacterfc(pNumCte CHAR(20))
RETURNING CHAR(6),CHAR(20),CHAR(100),CHAR(1),CHAR(1),CHAR(13),INTEGER;
    
    -- DEFINICIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE isql_err         INTEGER;
    DEFINE cMensaje			CHAR(100);
    DEFINE cExentoIDE       CHAR(1);
    DEFINE cEstado          CHAR(1);
    DEFINE cRfc             CHAR(13);
    DEFINE cRfc_alterno     CHAR(13);
    DEFINE cRfc_final       CHAR(13);
    DEFINE cCuenta          CHAR(20);
    DEFINE iExentos         INTEGER;

    ON EXCEPTION SET isql_err
        LET cCodRet = isql_err;
        RETURN cCodRet,'','','','','',0;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- INICIALIZACIONES
    LET cEstado			= '';
    LET cCodRet         = '000';
    LET isql_err        = 0;
    LET cMensaje    	= "Valores Retorno";
    LET cExentoIDE      = "";
    LET cRfc            = "";
    LET cRfc_alterno    = "";
    LET cRfc_final      = "";
    LET cCuenta         = "";
    LET iExentos        = 1;

    --SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultacterfc.out";
    --TRACE ON;

    BEGIN

    IF TRIM(pNumCte) = '' OR pNumCte IS NULL THEN	
        LET cCodRet = '001';
        LET cMensaje = 'Debe escribir número de cliente';
        RETURN cCodRet,cCuenta,TRIM(cMensaje),NVL(cEstado,'N'),NVL(cExentoIDE,'N'),cRfc,iExentos;
    END IF;

    SELECT FIRST 1 mae.cuenta
      INTO cCuenta
      FROM bdicheq:"informix".sc_maechq mae
     INNER JOIN bdinteg:"informix".si_cliente sc ON sc.numcte = mae.num_cte 
     INNER JOIN bdilide:"informix".sl_productoexen sp ON sp.producto = mae.producto
     WHERE mae.num_cte = pNumCte;

    SELECT rfc,status 
      INTO cRfc, cExentoIDE 
      FROM bdilide:"informix".sl_exentos 
     WHERE num_cte = pNumCte;

    --Devuelve el mensaje dependiendo del estatus del cliente.
    IF TRIM(cExentoIDE) <> '' OR cExentoIDE IS NOT NULL THEN
        IF cExentoIDE = '5' THEN
            LET cMensaje = 'Contribuyente Exento';
        ELIF cExentoIDE = '6' THEN
            LET cMensaje = 'Contribuyente No Exento';
        ELIF cExentoIDE = '3' THEN
            LET cMensaje = 'Clave de RFC no existe es el padrón.';
        ELIF cExentoIDE = '7' THEN
            LET cMensaje = 'Contribuyente que dejo de ser Exento de IDE';
        END IF;
    END IF;

    --Si no se encuentra el RFC consulta el rfc_alterno.
    IF TRIM(cRfc) = '' OR cRfc IS NULL THEN
        LET iExentos = 0;

        SELECT rfc, rfc_alterno 
          INTO cRfc, cRfc_alterno 
          FROM bdinteg:"informix".si_cliente 
         WHERE numcte = pNumCte;

        IF cRfc_alterno IS NULL OR cRfc_alterno = '' THEN
            LET cRfc_final = cRfc;
        ELSE
            LET cRfc_final = cRfc_alterno;
        END IF;

        SELECT Estado 
          INTO cEstado 
          FROM bdilide:"informix".sl_consat 
         WHERE rfc = cRfc_final
           AND fecha_sol is not null;

        --Devuelve el mensaje dependiendo del estado del cliente.
        IF cEstado = 'P' THEN
            LET cMensaje = 'Pendiente de Envio';
        ELIF cEstado = 'E' THEN
            LET cMensaje = 'Solicitud Enviada';
        ELIF cEstado = 'C' THEN
            LET cMensaje = 'Reportar al Área de Sistemas';
        END IF;       
    END IF;

    IF cEstado IS NULL THEN
        LET cEstado = 'N';
    END IF;

    IF cExentoIDE IS NULL THEN
        LET cExentoIDE = 'N';
    END IF;

    RETURN cCodRet,cCuenta,TRIM(cMensaje),NVL(cEstado,'N'),NVL(cExentoIDE,'N'),cRfc_final,iExentos;
    
    END;
    
END PROCEDURE
