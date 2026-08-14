CREATE PROCEDURE "informix".sp_compara_tel( pEmpresa CHAR(3), 
                                            pNumCteTitular CHAR(20), 
                                            pTelefono CHAR(13), 
                                            pTipoTel INTEGER, 
                                            pNumCteCompara CHAR(20), 
                                            pFuncion CHAR(1) )
RETURNING CHAR(5);

    DEFINE cCodret            CHAR(5);
    DEFINE iTipo_tel          INTEGER;
    DEFINE cTelefono          CHAR(13);
    DEFINE cTelefonoCompara   CHAR(13);
    DEFINE iTipo_telCompara   INTEGER;
    DEFINE iBand              INTEGER;
    DEFINE iSql_err           INTEGER;
    DEFINE cSecuencia         CHAR(20);
    
    LET cCodret          = '00000';
    LET cTelefono        = '';
    LET cTelefonoCompara = '';
    LET iTipo_tel        = 0;
    LET iTipo_telCompara = 0;
    LET iBand            = 0;
    LET iSql_err         = 0;
    LET cSecuencia       = '';
    
    --- SET DEBUG FILE TO '/tmp/sp_compara_tel.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET iSql_err
        LET cCodret = CAST(iSql_err AS CHAR);    
        RETURN cCodret;
    END EXCEPTION;	

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteTitular,'')) <> '' AND TRIM(NVL(pFuncion,'')) <> '' THEN
        IF pFuncion = '1' THEN -- // validacion del telefono a guardar comparandolo los telefonos guardados previamente 
            IF NVL(pTipoTel,0) = 1 OR NVL(pTipoTel,0) = 2 OR NVL(pTipoTel,0) = 3 OR NVL(pTipoTel,0) = 4 THEN
                FOREACH
                    SELECT telefono, tipo_tel 
                      INTO cTelefono, iTipo_tel
                      FROM "informix".pr_telefonos
                     WHERE empresa = pEmpresa 
                       AND numcte_pros  = pNumCteTitular 
                       AND status_tel = 'A'  

                    IF TRIM(pTelefono) = TRIM(cTelefono) AND iTipo_tel <> pTipoTel THEN 
                        LET iBand = 1;
                    END IF;
                END FOREACH;
            ELSE
                LET iBand = 3;
            END IF;
        ELIF pFuncion = '2' THEN -- // elimina telefono de la si_telefonos_actual y cansela los de la si_telefonos   
            IF NVL(pTipoTel,0) = 1 OR NVL(pTipoTel,0) = 2 OR NVL(pTipoTel,0) = 3 OR NVL(pTipoTel,0) = 4 THEN
                IF EXISTS( SELECT telefono FROM "informix".pr_telefonos WHERE empresa = pEmpresa AND numcte_pros = pNumCteTitular AND status_tel = 'A' AND tipo_tel = pTipoTel ) THEN
                    UPDATE "informix".pr_telefonos 
                       SET status_tel = 'C' 
                     WHERE empresa = pEmpresa 
                       AND numcte_pros = pNumCteTitular 
                       AND tipo_tel = pTipoTel;
                END IF;
            ELSE
                LET iBand = 3;	
            END IF;
        ELIF pFuncion = '3' THEN -- verifica si el cliente tiene un telefono de trabajo
            IF NOT EXISTS( SELECT telefono FROM "informix".pr_telefonos WHERE empresa = pEmpresa AND numcte_pros  = pNumCteTitular AND status_tel = 'A' AND tipo_tel = 3 ) THEN
                LET iBand = 1;
            END IF;
        ELIF pFuncion = '4' THEN  --se uso para compara el numero de una referencia con los numeros del cliente titular
            IF TRIM(NVL(pNumCteCompara,'')) <> '' THEN 
                FOREACH
                    SELECT telefono
                      INTO cTelefonoCompara
                      FROM "informix".pr_telefonos
                     WHERE empresa = pEmpresa 
                       AND numcte_pros  = pNumCteCompara 
                       AND status_tel = 'A'  

                    IF TRIM(pTelefono) = TRIM(cTelefonoCompara) THEN
                        LET iBand = 1;
                    END IF;
                END FOREACH; 
            ELSE
                LET iBand = 3;
            END IF;
        END IF;	
    ELSE
        IF pFuncion = '4' THEN  --se uso para compara el numero de una referencia con los numeros del cliente titular
            IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteCompara,'')) <> '' THEN 	
                FOREACH
                    SELECT telefono
                      INTO cTelefonoCompara
                      FROM "informix".pr_telefonos
                     WHERE empresa = pEmpresa 
                       AND numcte_pros  = pNumCteCompara 
                       AND status_tel = 'A'  

                    IF TRIM(pTelefono) = TRIM(cTelefonoCompara) THEN
                        LET iBand = 1;
                    END IF;
                END FOREACH; 
            ELSE
                LET iBand = 3;
            END IF;
        ELSE
            LET iBand = 2;
        END IF;
    END IF;
    
    LET cCodret = '000' || pFuncion || CAST(iBand AS CHAR);
    
    RETURN cCodret;	
    
    END;
    
END PROCEDURE;