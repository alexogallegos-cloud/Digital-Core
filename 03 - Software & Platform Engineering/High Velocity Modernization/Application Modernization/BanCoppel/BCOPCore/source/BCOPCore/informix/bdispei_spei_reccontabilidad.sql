CREATE PROCEDURE "informix".spei_reccontabilidad(pctacontable CHAR(14),
                                                 pccorigen    CHAR(4),
                                                 pccdestino   CHAR(4),
                                                 pimporte     DECIMAL(17,2),
                                                 pnaturaleza  CHAR(1)) 
RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    
    DEFINE wfecha_hoy       DATE;
    DEFINE wchrempresa      CHAR(3);
    DEFINE wpendientes      INTEGER;
    DEFINE wintpkpasecont   INTEGER;
    DEFINE wchrsucursal     CHAR(4);
    DEFINE wccmayor         CHAR(4);
    DEFINE wccsub           CHAR(2);
    DEFINE wccsubsub        CHAR(2);
    DEFINE wccssubsub       CHAR(2);
    DEFINE wccsssubsub      CHAR(2);
    DEFINE wccsector        CHAR(2);
    DEFINE wccauxiliar      CHAR(2);
    DEFINE wchrtransaccion  CHAR(2);
    DEFINE wchrdivisa       CHAR(2);
    DEFINE vexiste          CHAR(4);
    DEFINE wfech_habil      DATE;
    DEFINE wfecha_habil     CHAR(10);
    DEFINE wmovimientos INTEGER;
    
    DEFINE vcodretrpt1      CHAR(5);
    DEFINE vcodretrpt2      CHAR(5);
    DEFINE vcodretrpt3      CHAR(50);
    DEFINE vcodretrpt4      CHAR(5);
    DEFINE vcodretrpt5      CHAR(5);
    DEFINE vcodretrpt6      CHAR(50);
    
    DEFINE vtransaccion     SMALLINT;
    DEFINE iExiste1         INTEGER;
    DEFINE iExiste2         INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE desc_err         CHAR(80);
    DEFINE vcodret3         CHAR(80);
    DEFINE cHora            CHAR(15);
    DEFINE iExiste          SMALLINT;
    DEFINE iExisteFin       SMALLINT;
    
    DEFINE vcodret4         CHAR(5);
    DEFINE vcodret5         CHAR(5);

    LET sql_err        = 0;
    LET isam_err       = 0;
    LET vcodret1       = "00000";
    LET vcodret2       = "00000";
    
    LET wfecha_hoy      = '';
    LET wchrempresa     = '001';
    LET wpendientes     = 0;
    LET wintpkpasecont  = 0;
    LET wchrsucursal    = '9201';
    LET wccmayor        = '';
    LET wccsub          = '';
    LET wccsubsub       = '';
    LET wccssubsub      = '';
    LET wccsssubsub     = '';
    LET wccsector       = '';
    LET wccauxiliar     = ' ';
    LET wchrtransaccion = ' ';
    LET wchrdivisa      = '01';
    LET vexiste         = '';
    LET wfech_habil     = '';
    LET wfecha_habil    = '';
    LET wmovimientos	= 0;
    
    LET vcodretrpt1 = '000';
    LET vcodretrpt2 = '000';
    LET vcodretrpt3 = '';
    LET vcodretrpt4 = '000';
    LET vcodretrpt5 = '000';
    LET vcodretrpt6 = '';
    
    LET vtransaccion = 0;
    LET iExiste1 = 0;
    LET iExiste2 = 0;
    LET ven_transacc = 0;
    LET desc_err = '';
    LET vcodret3 = '';
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cHora = TRIM(cHora);
    LET cHora = cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,12];
    LET iExiste = 0;
    LET iExisteFin = 0;
    
    LET vcodret4 = '';
    LET vcodret5 = '';

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_reccontabilidad_"||TRIM(cHora)||".err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_reccontabilidad_"||TRIM(cHora)||".out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF SUBSTR(pctacontable,  1, 4) <> '9999' THEN
        IF ( LENGTH( TRIM(pctacontable) ) <> 14 ) OR
           ( LENGTH( TRIM(pccdestino) ) <> 4 ) OR
           ( LENGTH( TRIM(pccorigen) ) <> 4 ) OR
           ( pnaturaleza NOT IN('D','C') ) OR
           ( pimporte <= 0.00 ) THEN 
            LET vcodret1 = '00110';
            RETURN vcodret1;
        END IF;
    END IF;
    
    SELECT fecha_hoy
      INTO wfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = wchrempresa;
     
    SELECT COUNT(*)
      INTO iExiste
      FROM tblctrlproceso
     WHERE dtfecha = wfecha_hoy
       AND intcveproceso = 9;
     
    IF iExiste = 0 THEN
        INSERT INTO tblctrlproceso VALUES( 9, wfecha_hoy, current, 'informix', '0' );

        -- // CALCULA LA PROXIMA FECHA DE OPERACION
        CALL bdispei:"informix".sp_validafecha(wchrempresa, wfecha_hoy)
        RETURNING vcodret1, wfech_habil;
        
        LET wfecha_habil = to_char(wfech_habil, '%d/%m/%Y');
         
        UPDATE "informix".tblparametros 
           SET vchrvalor = wfecha_habil
         WHERE vchrcveparametro = 'FECHA_OPERACION'; 

    ELSE
        SELECT COUNT(*)
          INTO iExisteFin
          FROM tblctrlproceso
         WHERE dtfecha = wfecha_hoy
           AND intcveproceso = 9
           AND chrstatus IN('1','2','3');
           
        IF iExisteFin > 0 THEN
            LET vcodret1 = '00000';
            RETURN vcodret1;
        END IF;    
    END IF;
     
    LET wccmayor    = SUBSTR(pctacontable,  1, 4);
    LET wccsub      = SUBSTR(pctacontable,  5, 2);
    LET wccsubsub   = SUBSTR(pctacontable,  7, 2);
    LET wccssubsub  = SUBSTR(pctacontable,  9, 2);
    LET wccsssubsub = SUBSTR(pctacontable, 11, 2);
    LET wccsector   = SUBSTR(pctacontable, 13, 2);
    
    IF wccmayor <> '9999' THEN
        
        SELECT ccmayor
          INTO vexiste
          FROM bdinteg:"informix".si_catalog
         WHERE naturaleza_cta IN('A','D')
           AND ccmayor    = wccmayor
           AND ccsub      = wccsub
           AND ccsubsub   = wccsubsub
           AND ccssubsub  = wccssubsub
           AND ccsssubsub = wccsssubsub
           AND sector     = wccsector;
         
        IF vexiste is null OR vexiste = '' THEN
            LET vcodret1 = '00050';
            RETURN vcodret1;
        END IF;
        
        SELECT NVL(MAX(intpkpasecont), 0)
          INTO wintpkpasecont
          FROM tblpasecont;
          
        LET wintpkpasecont = wintpkpasecont + 1;
        
        SELECT COUNT(*) 
          INTO iExiste1
          FROM bdispei:"informix".tblpasecont 
         WHERE mnymonto = pimporte 
           AND chrcargoabono = pnaturaleza;
           
        SELECT COUNT(*) 
          INTO iExiste2
          FROM bdispei:"informix".tblpaseconthist 
         WHERE dtfechacont = wfecha_hoy 
           AND mnymonto = pimporte 
           AND chrcargoabono = pnaturaleza;
           
        IF iExiste1 = 0 AND iExiste2 = 0 THEN
            INSERT INTO bdispei:"informix".tblpasecont
            (intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, 
            ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig)
            VALUES
            (wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, 
            wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte, pnaturaleza, pccorigen);
        END IF;
		
    ELSE
        
        UPDATE tblctrlproceso
           SET chrstatus = '1'
         WHERE dtfecha = wfecha_hoy
           AND intcveproceso = 9;  

        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        LET ven_transacc = 1;
        
        -- // ACTUALIZA PARAMETROS
        UPDATE tblctrlproceso
           SET chrstatus = '2'
         WHERE dtfecha = wfecha_hoy
           AND intcveproceso = 9;
        
        -- // CIERRA TRANSACCION
        COMMIT WORK;
        LET ven_transacc = 0;
        
        -- // GENERA EL PASE CONTABLE DEL SISTEMA SPEI
        SELECT COUNT(*)
          INTO wmovimientos
          FROM bdispei:"informix".tblpaseconthist
         WHERE dtfechacont = today;
		
        IF wmovimientos = 0 THEN
            INSERT INTO bdispei:"informix".tblpaseconthist
            SELECT wfecha_hoy, cont.* 
              FROM bdispei:"informix".tblpasecont cont;
            
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                DELETE FROM bdispei:"informix".tblpasecont
                WHERE intpkpasecont > 0;
            END IF;

            UPDATE STATISTICS MEDIUM FOR TABLE bdispei:"informix".tblpasecont;

            -- // Ejecuta Pase Contable del SPEI
            EXECUTE PROCEDURE bdispei:"informix".sp_pasecontab(wchrempresa, wfecha_hoy) 
            INTO vcodret1;
        END IF;
        
        UPDATE tblctrlproceso
           SET chrstatus = '3'
         WHERE dtfecha = wfecha_hoy
           AND intcveproceso = 9;
        
        EXECUTE PROCEDURE "informix".spei_desbloqbandera('001')
        INTO vcodret1;
        
        IF vcodret1 = '000' THEN
            LET vcodret1 = "00000";
        END IF;
        
        IF vtransaccion = 1 THEN
            BEGIN WORK;
        END IF;
        
    END IF;
    
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;