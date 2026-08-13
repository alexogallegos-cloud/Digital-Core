CREATE PROCEDURE "informix".sp_archivo_log(pArchivoOrigen char(3), pTipoConc integer)
        returning CHAR(6);

--Definicion de variables
    DEFINE chrcodret        CHAR(6);
    DEFINE intcodret          INT;
    DEFINE vsql                  char(710);

--Inicializacion de variables
    LET chrcodret  = '000';
    LET vsql = '';

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret;
        END IF;
    END EXCEPTION;

    let vsql = '';

    IF pTipoConc = 1 THEN
        Let vsql = 'echo "UNLOAD TO  ''/tmp/conciliacion/LOG_A' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt'' DELIMITER ''|'' SELECT * FROM log_atm WHERE ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivolog.sql';
        Let chrcodret  = '001';
    ELIF pTipoConc = 2 THEN
        Let vsql = 'echo "UNLOAD TO  ''/tmp/conciliacion/LOG_POS_' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt'' DELIMITER ''|'' SELECT * FROM log_pos WHERE ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivolog.sql';             
        Let chrcodret  = '002';
    END IF ;

    SYSTEM vsql;

     let vsql = '';
     let vsql = 'dbaccess intercard /tmp/conciliacion/cargaarchivolog.sql';
     SYSTEM vsql;

    Return chrcodret;

end;
END PROCEDURE;