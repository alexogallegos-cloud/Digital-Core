CREATE PROCEDURE "informix".sp_validaarchivoinforme(pNombreArchivo CHAR(20))
RETURNING CHAR(6), CHAR(60);

    -- // DEFINICIONES
    DEFINE cCodRet         CHAR(6);
    DEFINE cCodRet2        CHAR(6);
    DEFINE iSql_Err        INTEGER;
    DEFINE cMensajeRet     CHAR(60);
    DEFINE dFechaHoy       DATE;
    DEFINE cEstado         CHAR(1);
    DEFINE cNumCte         CHAR(20);
    DEFINE cRfc            CHAR(13);
    DEFINE iNumRegsRes     INT8;
    DEFINE iNumRegsCtrl    INT8;
    DEFINE cRetornoSPdias  CHAR(6);
    DEFINE cFecha          CHAR(8);
    DEFINE dDiaPrimero     DATE;
    DEFINE dDiaUltimo      CHAR(10);


    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensajeRet = '';
        IF cCodRet = '-268' THEN
            LET cCodRet = '004';
            LET cMensajeRet = 'Ya se encuentran los registros en la tabla';
        END IF;
        RETURN cCodRet,cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIONES
    LET cCodRet         = '000';
    LET cCodRet2        = '000';
    LET cMensajeRet     = 'Validacion Terminada';
    LET cRfc            = '';
    LET cNumCte         = '';
    LET cEstado         = '';
    LET iNumRegsRes     = NULL;
    LET iNumRegsCtrl    = NULL;
    LET cRetornoSPdias  = '000000';
    LET dDiaPrimero     = '01-01-2000';
    LET dDiaUltimo      = '01-01-2000';
    LET iSql_Err        = 0;
    LET dFechaHoy       = '01-01-2000';
    LET cFecha          = '01-01-2000';

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_validaarchivoinforme.out";
    --- TRACE ON;

    BEGIN

    SELECT fecha_hoy  
      INTO dFechaHoy  
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = '001';

    SELECT COUNT(rfc) 
      INTO iNumRegsRes
      FROM bdilide:"informix".sl_archivoconsulta;

    -- // Se guardan el registro del archivo de control.
    SELECT FECHA,  Num_Reg
      INTO cFecha, iNumRegsCtrl
      FROM bdilide:"informix".sl_archivocontrol;

    EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(SUBSTRING(cFecha FROM 5 FOR 2), SUBSTRING(cFecha FROM 1 FOR 4))
    INTO cRetornoSPdias, dDiaPrimero, dDiaUltimo;  

    LET dDiaUltimo = SUBSTRING(dDiaUltimo FROM 4 FOR 2);

    FOREACH
        SELECT rfc,estado 
          INTO cRfc, cEstado 
          FROM bdilide:"informix".sl_archivoconsulta

        -- // Inicializamos la variable por cada rfc que se este validando.
        LET cCodRet = '000';

        -- // Se verifica si existen los clientes con su RFC.
        SELECT num_cte, rfc 
          INTO cNumCte, cRfc 
          FROM bdilide:"informix".sl_exentos 
         WHERE num_cte IS NOT NULL
           AND rfc = cRfc; 

        IF cRfc IS NOT NULL OR cRfc <> '' OR cNumCte IS NOT NULL OR cNumCte <> '' THEN
            -- // Se validan los registros con los criterios indicados
            IF LENGTH(TRIM(cRfc)) <> 13 OR LENGTH(TRIM(cEstado)) <> 1 OR TRIM(cEstado) <> '7' OR iNumRegsRes <> iNumRegsCtrl OR SUBSTRING(cFecha FROM 1 FOR 4) < '2000' OR SUBSTRING(cFecha FROM 5 FOR 2) >= '12' OR SUBSTRING(cFecha FROM 7 FOR 2) > dDiaUltimo THEN
                LET cCodRet = '001';
                LET cMensajeRet = 'El Registro no cumple con los criterios indicados';

                -- // Si el registro no cumple con la validacion se guarda en esta tabla de contro de errores.
                INSERT INTO bdilide:"informix".sl_ctrlerror(Fecha_Hoy,Nombre_Archivo,Error  ,idRegistro) 
                VALUES(dFechaHoy,pNombreArchivo,cCodRet,cRfc);
            END IF;

            IF cCodRet = '000' THEN
                -- // Se actualizan los registros validados correctamente.
                EXECUTE PROCEDURE bdilide:"informix".sp_actualizainformesat(cRfc)
                INTO cCodRet2,cMensajeRet;
            END IF;

        ELSE
            LET cCodRet = '002';
            LET cMensajeRet = 'No se encuentra el registro';
        END IF;
    END FOREACH;

    RETURN cCodRet,cMensajeRet;

    END;
    
END PROCEDURE
