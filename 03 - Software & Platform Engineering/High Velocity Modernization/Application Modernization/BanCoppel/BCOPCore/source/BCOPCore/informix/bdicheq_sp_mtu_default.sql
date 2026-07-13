CREATE PROCEDURE "informix".sp_mtu_default(pNumRegistros CHAR(20))
	        RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	--Variables--
    DEFINE vcodret1             CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr     		INTEGER;
	DEFINE idescerr             CHAR(50);  
	DEFINE cCodRet      		CHAR(5);
	DEFINE iContador            INTEGER;
	DEFINE cnumcliente			CHAR(20);
	DEFINE vcontador1           INTEGER;

	LET vcodret1            = '000';
    LET vcodret2            = '000';
    LET vcodret3            = 'PROCESO FINALIZADO';
	LET cCodRet      	    = '00000';
	LET iContador           = 0;
	LET iSqlErr      	    = 0;
	LET iIsamErr     	    = 0;
	LET idescerr            = '';
	LET vcontador1          = 0;

--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
  
    ON EXCEPTION SET iSqlErr, iIsamErr, iDescErr
        SET DEBUG FILE TO "/resplogifx/hipotecario_bancoppel/sp_mtu_default.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET vcodret1 = iSqlErr;
            LET vcodret2 = iIsamErr;
            LET vcodret3 = iDescErr;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/resplogifx/hipotecario_bancoppel/sp_mtu_default.out';
    --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
	
	IF pNumRegistros IS NULL OR pNumRegistros == '' THEN
	    LET pNumRegistros = '16000000';
	END IF;
		BEGIN WORK;
            FOREACH WITH HOLD
            
                SELECT numcliente
                INTO cnumcliente
                FROM bdicheq:sc_ctemtu
                WHERE montotransaccional = 500000
                LIMIT pNumRegistros
                
                UPDATE bdicheq:sc_ctemtu SET montotransaccional = 30000 WHERE numcliente = cnumcliente;
                
                LET vcontador1 = vcontador1 + 1;
                
                LET iContador = iContador + 1;
    
                IF iContador = 1000 THEN
                    COMMIT WORK;
                    LET iContador = 0;
                    BEGIN WORK;
                END IF; 
    
            END FOREACH;
        COMMIT WORK;
		RETURN cCodRet, vcodret2, vcodret3, vcontador1;
	END;
END PROCEDURE;