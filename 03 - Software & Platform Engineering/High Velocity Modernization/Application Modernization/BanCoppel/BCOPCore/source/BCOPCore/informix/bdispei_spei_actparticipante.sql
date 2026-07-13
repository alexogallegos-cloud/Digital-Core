CREATE PROCEDURE "informix".spei_actparticipante(pclavebco     INTEGER,  -- clave de la institución
                                                 pnombreinstit CHAR(50), -- nombre de la institución
                                                 pcveestado    CHAR(10)) -- clave de estado

RETURNING CHAR(5); -- codigo de retorno

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;
    DEFINE vexiste_tblbanco integer;
    DEFINE vexiste_sibanco  CHAR(1);
    DEFINE wintindice       INTEGER;
    DEFINE vbanco           CHAR(5);
    
    LET vCodRet1         = "00000";
    LET vCodRet2         = "00000";
    LET vSqlErr          = 0;
    LET vIsamErr         = 0;
    LET vexiste_tblbanco = 0;
    LET vexiste_sibanco  = '';
    LET wintindice       = 0;
    LET vbanco           = '';
    
    --SET DEBUG FILE TO "/informix/lflores/spei_actparticipante.out";
    --TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_actparticipante.out";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF (pclavebco IS NULL OR pclavebco = '') OR
       ---(pnombreinstit IS NULL OR pnombreinstit = '') OR 
       (pcveestado IS NULL OR pcveestado = '') THEN
        LET vCodRet1 = '00110';
    END IF;
    
	IF pcveestado = 'A' THEN
	   SELECT count(*)
         INTO vexiste_tblbanco
         FROM bdispei:"informix".tblbanco
        WHERE cvecesif = pclavebco;
     
       IF vexiste_tblbanco > 0 THEN
          UPDATE bdispei:"informix".tblbanco
             SET chredobco = pcveestado
           WHERE cvecesif = pclavebco;
       ELSE
          SELECT MAX(intindice) + 1
            INTO wintindice
            FROM bdispei:"informix".tblbanco;
          
          INSERT INTO bdispei:"informix".tblbanco VALUES
                 (pclavebco, SUBSTR(pnombreinstit,1,20), wintindice, pnombreinstit, pcveestado, 'R', ' ', '1');
          END IF;
    END IF;
	
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;