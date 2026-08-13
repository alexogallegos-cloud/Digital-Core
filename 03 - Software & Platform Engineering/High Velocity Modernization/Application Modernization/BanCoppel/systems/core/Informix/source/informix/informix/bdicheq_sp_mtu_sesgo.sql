CREATE PROCEDURE "informix".sp_mtu_sesgo(pNumRegistros CHAR(20))
	        RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	--Variables--
    DEFINE vcodret1             CHAR(5);
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr     		INTEGER;
	DEFINE idescerr             CHAR(50);
	DEFINE ven_transacc         INTEGER;    
	DEFINE cMsjError      		CHAR(500);
	DEFINE cCodRet      		CHAR(5);
	DEFINE iContador            INTEGER;
	DEFINE cnumcte              CHAR(20);
	DEFINE cregistroctemtu      CHAR(20);
	DEFINE cregistromontomtu    INTEGER;
	DEFINE cMtuDefault          CHAR(20);
	DEFINE vfechainicio         DATE;
	DEFINE vfechafin            DATE;

	LET vcodret1            = '00000';
	LET cCodRet      	    = '00000';
	LET iContador           = 0;
	LET iSqlErr      	    = 0;
	LET iIsamErr     	    = 0;
	LET cMsjError           = '';
	LET idescerr            = '';
	LET ven_transacc        = 0;
	LET cregistroctemtu     = '';
	LET cregistromontomtu = 0;
	let cMtuDefault         = '';
	LET vfechainicio        = '';
    LET vfechafin           = '';

--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
  
    ON EXCEPTION SET iSqlErr, iIsamErr, iDescErr
        SET DEBUG FILE TO "/resplogifx/hipotecario_bancoppel/sp_mtu_sesgo.err";
            TRACE ON;
        IF iSqlErr <> 0 THEN
            LET vcodret1 = '00001';
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/resplogifx/hipotecario_bancoppel/sp_mtu_sesgo.out';
    --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
		LET cMtuDefault = (SELECT valor FROM bdicheq:sc_param WHERE codparam = 'mtudefault');
		LET vfechainicio = MDY(11,15,2025);
		LET vfechafin = TODAY;
        
        IF pNumRegistros IS NULL OR pNumRegistros == '' THEN
	        LET pNumRegistros = '5000';
	    END IF;
	
		BEGIN WORK;
		
            FOREACH WITH HOLD
             
                SELECT DISTINCT cli.numcte
                INTO cnumcte
                FROM bdinteg:si_cliente cli
                INNER JOIN bdicheq:sc_maechq mae ON mae.num_cte = cli.numcte
                LEFT JOIN bdicheq:sc_ctemtu mtu ON mtu.numcliente = cli.numcte
                WHERE mae.producto IN (SELECT numproducto FROM bdicheq:sc_productos_mtu)
                AND cli.fecha_alta >= vfechainicio AND cli.fecha_alta <= vfechafin
                AND mtu.numcliente IS NULL
                LIMIT pNumRegistros
              
                SELECT FIRST 1 numcliente, montotransaccional
                INTO cregistroctemtu, cregistromontomtu
                FROM bdicheq:sc_ctemtu WHERE numcliente = cnumcte;
                
                IF cregistroctemtu IS NULL OR cregistroctemtu = '' THEN
            
                    INSERT INTO bdicheq:sc_ctemtu (numcliente, montotransaccional) VALUES (cnumcte, cMtuDefault);
                    LET iContador = iContador + 1;
                    
                ELSE
                    IF cregistromontomtu = 500000 THEN
                
                        UPDATE bdicheq:sc_ctemtu SET montotransaccional = cMtuDefault WHERE numcliente = cnumcte;         
                        LET iContador = iContador + 1;
                        
                    END IF;    
                END IF;
    
                IF iContador = 1000 THEN
                    COMMIT WORK;
                    LET iContador = 0;
                    BEGIN WORK;
                END IF; 
    
            END FOREACH;
        COMMIT WORK;
		RETURN cCodRet;
    END;
END PROCEDURE;