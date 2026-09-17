CREATE PROCEDURE "informix".sp_actvalidacioncofetel_pros ( cEmpresa CHAR(3),
                                                           cNumCte CHAR(9), 
                                                           cFlagTelefonoCasa CHAR(1), 
                                                           cFlagTelefonoCelular CHAR(1),
                                                           cflagTelefonoOficina CHAR(1), 
                                                           cTipoDireccion CHAR(1), 
                                                           cTipo CHAR(1) )
RETURNING CHAR(5);
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;
    DEFINE iMaxSecuencia_actual INT;
	
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET iMaxSecuencia = 0;
    LET iMaxSecuencia_actual = 0;

    --- SET DEBUG FILE TO "/tmp/sp_actvalidacioncofetel_pros.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
    
    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    IF ctipo = "1" THEN
    
        SELECT max(secuencia) 
          INTO iMaxSecuencia  
          from "informix".pr_direcciones  
         WHERE numcte_pros = cNumCte 
          and tipo_dir = cTipoDireccion;

         IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
            UPDATE "informix".pr_direcciones 
               SET ind_COFETELtel1 = "V" 
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
            
        END IF;

        IF cFlagTelefonoCelular = "1" and cTipoDireccion = "1" THEN
            UPDATE "informix".pr_direcciones 
               SET ind_COFETELtel2 = "V" 
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
        END IF;

        IF cFlagTelefonoOficina = "1" and cTipoDireccion = "2" THEN
            UPDATE "informix".pr_direcciones 
               SET ind_COFETELtel3 = "V" 
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
        END IF;
        
    ELIF ctipo = "0" THEN
    
        LET iMaxSecuencia = 0;
        
        SELECT max(secuencia) 
          INTO iMaxSecuencia  
          from "informix".pr_refdirecciones  
         WHERE numcte_pros = cNumCte 
           and tipo_dir = cTipoDireccion;
           
        IF cFlagTelefonoCasa = "1" and cTipoDireccion = "1" THEN
            UPDATE "informix".pr_refdirecciones 
               SET ind_COFETELtel1 = "V"
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
        END IF;

        IF cFlagTelefonoCelular = "1"and cTipoDireccion = "1" THEN
            UPDATE "informix".pr_refdirecciones 
               SET ind_COFETELtel2 = "V" 
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
        END IF;

        IF cFlagTelefonoOficina = "1" and cTipoDireccion = "1" THEN
            UPDATE "informix".pr_refdirecciones 
               SET ind_COFETELtel3 = "V" 
             WHERE numcte_pros = cNumCte 
               and tipo_dir = cTipoDireccion 
               and secuencia = iMaxSecuencia;
        END IF;
        
    END IF;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;