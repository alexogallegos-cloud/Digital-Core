CREATE PROCEDURE "informix".sp_compara_tel_ref_pros( pEmpresa CHAR(3), 
                                                     pNumCteTitular CHAR(20),
                                                     pNumSolicitud CHAR(20), 
                                                     pSecuencia CHAR(20), 
                                                     pTelefonoCasa CHAR(13), 
                                                     pTelefonoCel CHAR(13),
                                                     pTelefonoOfi CHAR(13), 
                                                     pEjecucion CHAR(1) )
RETURNING CHAR(5);

    DEFINE cCodret            CHAR(5);
    DEFINE iRegistros         INTEGER;
    DEFINE cNumSolicitud      CHAR(20);
    DEFINE cProducto          CHAR(4);
    DEFINE cSecuencia         CHAR(20);
    DEFINE cNumCte            CHAR(20);
    DEFINE iSql_err           INTEGER;
    DEFINE cTelefonoRef1      CHAR(13);
    DEFINE cTelefonoRef2      CHAR(13);
    DEFINE cTelefonoRef3      CHAR(13);
    DEFINE iFlag              INTEGER;
    DEFINE iBandConyuge       INTEGER;
    DEFINE cParentesco        CHAR(2);
    DEFINE iExistsReg         INTEGER;
    DEFINE iValidar           INTEGER;
    
    LET cCodret          = '00000';
    LET iRegistros       = 0;
    LET cNumSolicitud    = '';
    LET cProducto        = '';
    LET cSecuencia       = '';
    LET cNumCte          = '';
    LET iSql_err         = 0;
    LET cTelefonoRef1    = '';
    LET cTelefonoRef2    = '';
    LET cTelefonoRef3    = '';
    LET iFlag            = 0;
    LET iBandConyuge     = 0;
    LET cParentesco      = '';
    LET iExistsReg       = 0;
    LET iValidar         = 0;
    
    --- SET DEBUG FILE TO '/tmp/sp_compara_tel_ref_pros.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_err
        LET cCodret = CAST(iSql_err AS CHAR);    
        RETURN cCodret;
    END EXCEPTION;	

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteTitular,'')) <> '' AND TRIM(NVL(pNumSolicitud,'')) <> '' AND TRIM(NVL(pEjecucion,'')) <> '' THEN 
        LET cNumSolicitud = pNumSolicitud;

        SELECT COUNT (a.secuencia) 
          INTO iRegistros
          FROM "informix".pr_refclientes AS a, 
               "informix".pr_refdirecciones AS b 
         WHERE a.numcte_pros = b.numcte_pros 
           AND a.secuencia = b.secuencia 
           AND a.numcte_banco = b.numcte_banco 
           AND a.empresa = pEmpresa 
           AND a.numcte_pros = pNumCteTitular
           AND a.num_solicitud = cNumSolicitud;

        IF iRegistros <> 0 THEN
            IF TRIM(NVL(pSecuencia,'')) <> '' AND CAST(TRIM(NVL(pSecuencia,'0')) AS INTEGER) > 0 THEN
                LET iValidar = 1;

                IF EXISTS( SELECT a.numcte_pros FROM "informix".pr_refclientes AS a, "informix".pr_refdirecciones AS b 
                           WHERE a.numcte_pros = b.numcte_pros AND a.secuencia = b.secuencia AND a.numcte_banco = b.numcte_banco AND a.empresa = pEmpresa 
                           AND a.numcte_pros = pNumCteTitular AND a.num_solicitud = cNumSolicitud	AND a.secuencia = CAST(pSecuencia AS INTEGER)) THEN
                    LET iExistsReg = 1;
                END IF;

                IF iRegistros = 1 AND iExistsReg= 1 THEN
                    LET iValidar = 0;
                ELIF iExistsReg = 0 THEN
                    LET pSecuencia = '';
                    LET iValidar = 2;
                END IF;
            ELSE	
                LET iValidar = 2;
            END IF;

            IF iValidar = 1 THEN
                SELECT a.numcte_banco, b.telefono1, b.telefono2, b.telefono3, a.parentesco
                  INTO cNumCte, cTelefonoRef1, cTelefonoRef2, cTelefonoRef3, cParentesco
                  FROM "informix".pr_refclientes AS a, 
                       "informix".pr_refdirecciones AS b
                 WHERE a.numcte_pros = b.numcte_pros
                   AND a.secuencia = b.secuencia 
                   AND a.numcte_banco = b.numcte_banco
                   AND a.empresa = pEmpresa
                   AND a.numcte_pros = pNumCteTitular 
                   AND a.num_solicitud = cNumSolicitud
                   AND a.secuencia <> pSecuencia;
            ELIF iValidar = 2 THEN
                IF CAST(TRIM(NVL(pEjecucion,'0')) AS INTEGER) = 1 THEN
                    SELECT a.secuencia
                      INTO cSecuencia
                      FROM "informix".pr_refclientes a
                      LEFT OUTER JOIN "informix".pr_refdirecciones b ON (a.numcte_pros = b.numcte_pros AND a.secuencia = b.secuencia AND a.numcte_banco = b.numcte_banco)
                     WHERE a.empresa = pEmpresa
                       AND a.numcte_pros = pNumCteTitular 
                       AND a.num_solicitud = cNumSolicitud
                       AND a.parentesco <> 'E';
                ELIF CAST(TRIM(NVL(pEjecucion,'0')) AS INTEGER) = 2 THEN
                    IF iRegistros = 1  THEN
                        SELECT a.secuencia
                          INTO cSecuencia
                          FROM "informix".pr_refclientes a
                          LEFT OUTER JOIN "informix".pr_refdirecciones b ON (a.numcte_pros = b.numcte_pros AND a.secuencia = b.secuencia AND a.numcte_banco = b.numcte_banco)
                         WHERE a.empresa = pEmpresa
                           AND a.numcte_pros = pNumCteTitular 
                           AND a.num_solicitud = cNumSolicitud;
                    ELSE
                        LET iValidar = 0;
                        LET cCodret = '00003';
                    END IF;
                END IF;

                IF TRIM(NVL(cSecuencia,'')) <> ''  AND CAST(TRIM(NVL(cSecuencia,'0')) AS INTEGER) > 0 THEN
                    SELECT a.numcte_banco, b.telefono1, b.telefono2, b.telefono3, a.parentesco
                      INTO cNumCte, cTelefonoRef1, cTelefonoRef2, cTelefonoRef3, cParentesco
                      FROM "informix".pr_refclientes AS a, 
                           "informix".pr_refdirecciones AS b
                     WHERE a.numcte_pros = b.numcte_pros
                       AND a.secuencia = b.secuencia 
                       AND a.numcte_banco = b.numcte_banco
                       AND a.empresa = pEmpresa
                       AND a.numcte_pros = pNumCteTitular 
                       AND a.num_solicitud = cNumSolicitud
                       AND a.secuencia = cSecuencia;
                ELSE
                    IF CAST(TRIM(NVL(pEjecucion,'0')) AS INTEGER) = 1 THEN
                        LET iValidar= 0;

                        IF iRegistros = 2 THEN 
                            LET cCodret = '00003';
                        END IF;
                    END IF;
                END IF;
            END IF;

            IF iValidar <>  0 THEN
                IF TRIM(NVL(cParentesco,'')) = 'E'  THEN
                    IF TRIM(NVL(cNumCte,'')) <> '' THEN 
                        FOREACH
                            SELECT telefono
                              INTO cTelefonoRef1
                              FROM "informix".pr_telefonos
                             WHERE empresa = pEmpresa 
                               AND numcte_pros = cNumCte 
                               AND status_tel = 'A'  

                            IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoCasa,'')) AND TRIM(NVL(pTelefonoCasa,'')) <> '' THEN 
                                LET cCodret = '00001';
                            END IF;
                            
                            IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoCel,'')) AND TRIM(NVL(pTelefonoCel,'')) <> '' THEN 
                                LET cCodret = '00001';
                            END IF;
                            
                            IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoOfi,'')) AND TRIM(NVL(pTelefonoOfi,'')) <> '' THEN 
                                LET cCodret = '00001';
                            END IF;
                        END FOREACH;
                    ELSE
                        LET cCodret = '00002';
                    END IF;
                ELSE
                    IF TRIM(NVL(cTelefonoRef1,'')) <> '' OR TRIM(NVL(cTelefonoRef2,'')) <> '' OR TRIM(NVL(cTelefonoRef3,'')) <> '' THEN
                        LET iFlag = 1;
                    END IF;

                    IF iFlag = 1 THEN
                        IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoCasa,'')) AND TRIM(NVL(cTelefonoRef1,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef2,'')) = TRIM(NVL(pTelefonoCasa,'')) AND TRIM(NVL(cTelefonoRef2,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef3,'')) = TRIM(NVL(pTelefonoCasa,'')) AND TRIM(NVL(cTelefonoRef3,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoCel,'')) AND TRIM(NVL(cTelefonoRef1,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef2,'')) = TRIM(NVL(pTelefonoCel,'')) AND TRIM(NVL(cTelefonoRef2,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef3,'')) = TRIM(NVL(pTelefonoCel,'')) AND TRIM(NVL(cTelefonoRef3,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef1,'')) = TRIM(NVL(pTelefonoOfi,'')) AND TRIM(NVL(cTelefonoRef1,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef2,'')) = TRIM(NVL(pTelefonoOfi,'')) AND TRIM(NVL(cTelefonoRef2,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                        
                        IF TRIM(NVL(cTelefonoRef3,'')) = TRIM(NVL(pTelefonoOfi,'')) AND TRIM(NVL(cTelefonoRef3,'')) <> '' THEN
                            LET cCodret = '00001';
                        END IF;
                    END IF;
                END IF;	
            END IF;		
        END IF;			
    ELSE
        LET cCodret = '00002';
    END IF;
    
    RETURN cCodret;	

    END;

END PROCEDURE;