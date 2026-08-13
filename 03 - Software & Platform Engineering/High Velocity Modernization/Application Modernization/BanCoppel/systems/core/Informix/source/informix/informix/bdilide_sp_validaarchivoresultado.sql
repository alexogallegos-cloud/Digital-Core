CREATE PROCEDURE "informix".sp_validaarchivoresultado(pNombreArchivo CHAR(20))
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
    DEFINE cDiaUltimo      CHAR(10);

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensajeRet = '';
        IF cCodRet = '-268' THEN
            LET cCodRet = '004';
            LET cMensajeRet = 'Ya se encuentran los registros en la tabla';
        END IF;
        DROP TABLE sl_exentostemp;
        RETURN cCodRet,cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // INICIALIZACIONES
    LET cCodRet         = '000';
    LET cCodRet2        = '000';
    LET cMensajeRet     = '';		
    LET cRfc            = '';
    LET cNumCte         = '';
    LET cEstado         = '';
    LET iNumRegsRes     = NULL;
    LET iNumRegsCtrl    = NULL;
    LET cRetornoSPdias  = '000000';
    LET dDiaPrimero     = '01-01-2000';
    LET cDiaUltimo      = '01-01-2000';
    LET iSql_Err        = 0;
    LET dFechaHoy       = '01-01-2000';
    LET cFecha          = '01-01-2000';

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_validaarchivoresultado.out";
    --- TRACE ON;

    BEGIN

    SELECT fecha_hoy  
      INTO dFechaHoy  
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = '001';

    IF EXISTS(SELECT tabname FROM systables WHERE tabname = 'sl_exentostemp') THEN
        DROP TABLE sl_exentostemp;
    END IF;

    -- // Se crea una tabla temporal que contendra los registros que seran caragdos en la tabla sl_exentos
    CREATE TEMP TABLE sl_exentostemp
      ( 
        num_cte CHAR(20) NOT NULL, 
        rfc CHAR(13) NOT NULL, 
        status CHAR(1) NOT NULL, 
        fech_cambio DATE NOT NULL, 
        user_insert CHAR(8) NOT NULL, 
        fecha_insert DATE 
      );

    SELECT COUNT(rfc) 
      INTO iNumRegsRes
      FROM bdilide:"informix".sl_archivoconsulta;

    -- // Guarda los valores del archivo de control de consulta.
    SELECT FECHA,  Num_Reg
      INTO cFecha, iNumRegsCtrl
      FROM bdilide:"informix".sl_archivocontrol;

    EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(SUBSTRING(cFecha FROM 5 FOR 2), SUBSTRING(cFecha FROM 1 FOR 4))
    INTO cRetornoSPdias, dDiaPrimero, cDiaUltimo;  

    LET cDiaUltimo = SUBSTRING(cDiaUltimo FROM 4 FOR 2);

    FOREACH
        SELECT rfc,estado 
          INTO cRfc, cEstado 
          FROM bdilide:"informix".sl_archivoconsulta

        -- // Inicializamos la variable por cada rfc que se este validando.
        LET cCodRet = '000';

        -- // Verifica si existe el cliente del RFC a validar.
        SELECT num_cte, rfc 
          INTO cNumCte, cRfc 
          FROM bdilide:"informix".sl_consat 
         WHERE rfc = cRfc
           AND fecha_cons is not null;

        -- // Si no existe se va por el siguiente registro.
        IF cRfc IS NOT NULL OR cRfc <> '' OR cNumCte IS NOT NULL OR cNumCte <> '' THEN
            -- // Se valida si el registros cumple con la indicaciones con los criterios indicados.
            IF LENGTH(TRIM(cRfc)) <> 13 OR LENGTH(TRIM(cEstado)) <> 1 OR TRIM(cEstado) NOT IN(5,6,3) OR iNumRegsRes <> iNumRegsCtrl OR SUBSTRING(cFecha FROM 1 FOR 4) < '2000' OR SUBSTRING(cFecha FROM 5 FOR 2) >= '12' OR SUBSTRING(cFecha FROM 7 FOR 2) > cDiaUltimo THEN
                LET cCodRet = '001';
                LET cMensajeRet = 'El registro no cumple con los criterios indicados';

                -- // Se guarda un control de los registros que no cumplan con la validacion.
                INSERT INTO bdilide:"informix".sl_ctrlerror(Fecha_Hoy,Nombre_Archivo,Error  ,idRegistro) 
                VALUES(dFechaHoy,pNombreArchivo,cCodRet,cRfc);
            END IF;

            -- // Si el registro cumple con los criterios indicados sem guarda en la tabla temporal.
            IF cCodRet = '000' THEN
                INSERT INTO sl_exentostemp(num_cte,rfc,status,fech_cambio,user_insert,fecha_insert)
                VALUES(cNumCte,cRfc,cEstado,dFechaHoy,'Informix',dFechaHoy);
            END IF;
        END IF;
    END FOREACH;

    LET cCodRet = '000';
    LET cMensajeRet = 'Validacion Terminada';

    CREATE INDEX idx_exentostemp ON sl_exentostemp(fech_cambio) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE sl_exentostemp;

    FOREACH
        SELECT rfc 
          INTO cRfc 
          FROM sl_exentostemp 
         WHERE fech_cambio = dFechaHoy

        -- // Se actualizan todos los registros que fueron validados correctamente.
        EXECUTE PROCEDURE bdilide:"informix".sp_actualizaresultadosat(cRfc)
        INTO cCodRet2,cMensajeRet;
    END FOREACH;

    -- // Se eliminia la tabla temporal
    DROP TABLE sl_exentostemp;

    RETURN cCodRet,cMensajeRet;

    END;
    
END PROCEDURE
