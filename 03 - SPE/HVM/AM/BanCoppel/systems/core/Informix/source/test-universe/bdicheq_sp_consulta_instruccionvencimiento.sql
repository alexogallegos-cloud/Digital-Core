CREATE PROCEDURE "informix".sp_consulta_instruccionvencimiento(pNumCta CHAR(20))
--// DATOS A REGRESAR //
RETURNING CHAR(5),  -- Código de Retorno
          CHAR(40); -- Descripción
          
    --------------------------------------------------------------------
    -- DOCUMENTACIÓN
    -- Consulta Instrucciones al Vencimiento
    -- (Instrucciones actuales de la cuenta)
    -- Realizó: Nancy Sevilla Camacho
    -- Fecha: 27/05/2011                    
    --------------------------------------------------------------------

    -- // DEFINICION DE VARIABLES //
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);	
    ---------------------------	
    DEFINE cDescripcion CHAR(40);

    -- // INICIALIZACION DE VARIABLES //
    LET iSqlErr = 0;
    LET cCodRet = '00000';
    LET cDescripcion = '';

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_instruccionvencimiento.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN -- // INICIO DEL PROCEDIMIENTO //
    
    ON EXCEPTION SET iSqlErr -- // MANEJADOR DE ERRORES //
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cDescripcion;
        END IF;
    END EXCEPTION;	

    IF pNumCta IS NULL OR pNumCta = '' THEN
        LET cCodRet = "102"; -- Parámetro de entrada vacío
    ELSE
        FOREACH -- // Se obtiene la descripción de las instrucciones actuales de la cuenta //
            SELECT a.descripcion
              INTO cDescripcion
              FROM bdicheq:"informix".sc_instrucc a,
                   bdicheq:"informix".sc_maeinstrucc b
             WHERE a.empresa = "001"
               AND a.instrucc = b.instrucc
               AND b.empresa = a.empresa
               AND b.cuenta = pNumCta
               AND b.instrucc = a.instrucc

            RETURN cCodRet, cDescripcion WITH RESUME;			   
        END FOREACH;	

        IF cDescripcion IS NULL OR cDescripcion = '' THEN
            LET cCodRet = "101"; -- No se encontró información
        END IF;
    END IF;		 

    RETURN cCodRet, cDescripcion WITH RESUME;		 

    END
    
END PROCEDURE;