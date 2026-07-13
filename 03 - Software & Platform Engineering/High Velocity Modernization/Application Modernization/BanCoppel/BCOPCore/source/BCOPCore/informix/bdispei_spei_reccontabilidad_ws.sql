CREATE PROCEDURE "informix".spei_reccontabilidad_ws( pctacontable  CHAR(14),
                                                  pccorigen     CHAR(4),
                                                  pccdestino    CHAR(4),
                                                  pimporte      DECIMAL(17,2),
                                                  pnaturaleza   CHAR(1),
                                                  pctacontable1 CHAR(14),
                                                  pccorigen1    CHAR(4),
                                                  pccdestino1   CHAR(4),
                                                  pimporte1     DECIMAL(17,2),
                                                  pnaturaleza1  CHAR(1),
                                                  pctacontable2 CHAR(14),
                                                  pccorigen2    CHAR(4),
                                                  pccdestino2   CHAR(4),
                                                  pimporte2     DECIMAL(17,2),
                                                  pnaturaleza2  CHAR(1),
                                                  pctacontable3 CHAR(14),
                                                  pccorigen3    CHAR(4),
                                                  pccdestino3   CHAR(4),
                                                  pimporte3     DECIMAL(17,2),
                                                  pnaturaleza3  CHAR(1),
                                                  pctacontable4 CHAR(14),
                                                  pccorigen4    CHAR(4),
                                                  pccdestino4   CHAR(4),
                                                  pimporte4     DECIMAL(17,2),
                                                  pnaturaleza4  CHAR(1),
                                                  pctacontable5 CHAR(14),
                                                  pccorigen5    CHAR(4),
                                                  pccdestino5   CHAR(4),
                                                  pimporte5     DECIMAL(17,2),
                                                  pnaturaleza5  CHAR(1),
                                                  pctacontable6 CHAR(14),
                                                  pccorigen6    CHAR(4),
                                                  pccdestino6   CHAR(4),
                                                  pimporte6     DECIMAL(17,2),
                                                  pnaturaleza6  CHAR(1),
                                                  pctacontable7 CHAR(14),
                                                  pccorigen7    CHAR(4),
                                                  pccdestino7   CHAR(4),
                                                  pimporte7     DECIMAL(17,2),
                                                  pnaturaleza7  CHAR(1),
												  pinstancia	CHAR(1)) 
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_reccontabilidad_ws_"||TRIM(cHora)||".err";
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
    
    --SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_reccontabilidad_ws.out";				  
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF pinstancia IN("A", " ") THEN
    
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

		IF ( LENGTH( TRIM(pctacontable)  ) <> 14 OR pctacontable  is null ) OR ( LENGTH( TRIM(pccdestino)  ) <> 4 OR pccdestino  is null ) OR ( LENGTH( TRIM(pccorigen)  ) <> 4 OR pccorigen is null  ) OR ( pnaturaleza  NOT IN('D','C') OR pnaturaleza  is null ) OR ( pimporte  <= 0.00 OR pimporte  is null ) OR
		   ( LENGTH( TRIM(pctacontable1) ) <> 14 OR pctacontable1 is null ) OR ( LENGTH( TRIM(pccdestino1) ) <> 4 OR pccdestino1 is null ) OR ( LENGTH( TRIM(pccorigen1) ) <> 4 OR pccorigen1 is null ) OR ( pnaturaleza1 NOT IN('D','C') OR pnaturaleza1 is null ) OR ( pimporte1 <= 0.00 OR pimporte1 is null ) OR
		   ( LENGTH( TRIM(pctacontable2) ) <> 14 OR pctacontable2 is null ) OR ( LENGTH( TRIM(pccdestino2) ) <> 4 OR pccdestino2 is null ) OR ( LENGTH( TRIM(pccorigen2) ) <> 4 OR pccorigen2 is null ) OR ( pnaturaleza2 NOT IN('D','C') OR pnaturaleza2 is null ) OR ( pimporte2 <= 0.00 OR pimporte2 is null ) OR
		   ( LENGTH( TRIM(pctacontable3) ) <> 14 OR pctacontable3 is null ) OR ( LENGTH( TRIM(pccdestino3) ) <> 4 OR pccdestino3 is null ) OR ( LENGTH( TRIM(pccorigen3) ) <> 4 OR pccorigen3 is null ) OR ( pnaturaleza3 NOT IN('D','C') OR pnaturaleza3 is null ) OR ( pimporte3 <= 0.00 OR pimporte3 is null ) OR
		   ( LENGTH( TRIM(pctacontable4) ) <> 14 OR pctacontable4 is null ) OR ( LENGTH( TRIM(pccdestino4) ) <> 4 OR pccdestino4 is null ) OR ( LENGTH( TRIM(pccorigen4) ) <> 4 OR pccorigen4 is null ) OR ( pnaturaleza4 NOT IN('D','C') OR pnaturaleza4 is null ) OR ( pimporte4 <= 0.00 OR pimporte4 is null ) OR
		   ( LENGTH( TRIM(pctacontable5) ) <> 14 OR pctacontable5 is null ) OR ( LENGTH( TRIM(pccdestino5) ) <> 4 OR pccdestino5 is null ) OR ( LENGTH( TRIM(pccorigen5) ) <> 4 OR pccorigen5 is null ) OR ( pnaturaleza5 NOT IN('D','C') OR pnaturaleza5 is null ) OR ( pimporte5 <= 0.00 OR pimporte5 is null ) OR
		   ( LENGTH( TRIM(pctacontable6) ) <> 14 OR pctacontable6 is null ) OR ( LENGTH( TRIM(pccdestino6) ) <> 4 OR pccdestino6 is null ) OR ( LENGTH( TRIM(pccorigen6) ) <> 4 OR pccorigen6 is null ) OR ( pnaturaleza6 NOT IN('D','C') OR pnaturaleza6 is null ) OR ( pimporte6 <= 0.00 OR pimporte6 is null ) OR
		   ( LENGTH( TRIM(pctacontable7) ) <> 14 OR pctacontable7 is null ) OR ( LENGTH( TRIM(pccdestino7) ) <> 4 OR pccdestino7 is null ) OR ( LENGTH( TRIM(pccorigen7) ) <> 4 OR pccorigen7 is null ) OR ( pnaturaleza7 NOT IN('D','C') OR pnaturaleza7 is null ) OR ( pimporte7 <= 0.00 OR pimporte7 is null ) THEN
			LET vcodret1 = '00110';
			RETURN vcodret1;
		END IF;
		
		-- // PRIMER CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable,  1, 4);
		LET wccsub      = SUBSTR(pctacontable,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable, 11, 2);
		LET wccsector   = SUBSTR(pctacontable, 13, 2);
		   
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
		   AND chrcargoabono = pnaturaleza
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte 
		   AND chrcargoabono = pnaturaleza
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte, pnaturaleza, pccorigen, pinstancia);
		END IF;
		
		-- // SEGUNDA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable1,  1, 4);
		LET wccsub      = SUBSTR(pctacontable1,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable1,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable1,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable1, 11, 2);
		LET wccsector   = SUBSTR(pctacontable1, 13, 2);
		   
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte1 
		   AND chrcargoabono = pnaturaleza1
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte1 
		   AND chrcargoabono = pnaturaleza1
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte1, pnaturaleza1, pccorigen1, pinstancia);
		END IF;
		
		-- // TERCER CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable2,  1, 4);
		LET wccsub      = SUBSTR(pctacontable2,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable2,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable2,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable2, 11, 2);
		LET wccsector   = SUBSTR(pctacontable2, 13, 2);
		 
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
			
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte2 
		   AND chrcargoabono = pnaturaleza2
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte2 
		   AND chrcargoabono = pnaturaleza2
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte2, pnaturaleza2, pccorigen2, pinstancia);
		END IF;
		
		-- // CUARTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable3,  1, 4);
		LET wccsub      = SUBSTR(pctacontable3,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable3,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable3,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable3, 11, 2);
		LET wccsector   = SUBSTR(pctacontable3, 13, 2);
		
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte3 
		   AND chrcargoabono = pnaturaleza3
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte3 
		   AND chrcargoabono = pnaturaleza3
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte3, pnaturaleza3, pccorigen3, pinstancia);
		END IF;
		
		-- // QUINTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable4,  1, 4);
		LET wccsub      = SUBSTR(pctacontable4,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable4,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable4,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable4, 11, 2);
		LET wccsector   = SUBSTR(pctacontable4, 13, 2);
		 
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte4 
		   AND chrcargoabono = pnaturaleza4
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte4 
		   AND chrcargoabono = pnaturaleza4
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte4, pnaturaleza4, pccorigen4, pinstancia);
		END IF;
		
		-- // SEXTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable5,  1, 4);
		LET wccsub      = SUBSTR(pctacontable5,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable5,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable5,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable5, 11, 2);
		LET wccsector   = SUBSTR(pctacontable5, 13, 2);
			
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
		  
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte5 
		   AND chrcargoabono = pnaturaleza5
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte5 
		   AND chrcargoabono = pnaturaleza5
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte5, pnaturaleza5, pccorigen5, pinstancia);
		END IF;
		
		-- // SEPTIMA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable6,  1, 4);
		LET wccsub      = SUBSTR(pctacontable6,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable6,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable6,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable6, 11, 2);
		LET wccsector   = SUBSTR(pctacontable6, 13, 2);
		
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte6 
		   AND chrcargoabono = pnaturaleza6
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte6 
		   AND chrcargoabono = pnaturaleza6
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte6, pnaturaleza6, pccorigen6, pinstancia);
		END IF;
		
		-- // OCTAVA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable7,  1, 4);
		LET wccsub      = SUBSTR(pctacontable7,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable7,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable7,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable7, 11, 2);
		LET wccsector   = SUBSTR(pctacontable7, 13, 2);
		
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte7 
		   AND chrcargoabono = pnaturaleza7
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte7 
		   AND chrcargoabono = pnaturaleza7
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte7, pnaturaleza7, pccorigen7, pinstancia);
		END IF;
		   
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
		 WHERE dtfechacont = today
		   AND instancia = "A";
		
		IF wmovimientos = 0 THEN
			INSERT INTO bdispei:"informix".tblpaseconthist
			SELECT wfecha_hoy, cont.* 
			  FROM bdispei:"informix".tblpasecont cont
			  WHERE instancia in("A", " ");
			
			IF dbinfo('sqlca.sqlerrd2') > 0 THEN
				DELETE FROM bdispei:"informix".tblpasecont
				WHERE intpkpasecont > 0;
			END IF;

			UPDATE STATISTICS MEDIUM FOR TABLE bdispei:"informix".tblpasecont;

			-- // Ejecuta Pase Contable del SPEI
			EXECUTE PROCEDURE bdispei:"informix".sp_pasecontab(wchrempresa, wfecha_hoy, pinstancia) 
			INTO vcodret1;
		END IF;
		
		UPDATE tblctrlproceso
		   SET chrstatus = '3'
		 WHERE dtfecha = wfecha_hoy
		   AND intcveproceso = 9;
		
		--EXECUTE PROCEDURE "informix".spei_desbloqbandera('001')
		--INTO vcodret1;
		
	--INSTANCIA B	
	
	ELSE 	
	
		IF ( LENGTH( TRIM(pctacontable)  ) = '' ) OR ( LENGTH( TRIM(pccdestino)  ) = '' ) OR ( LENGTH( TRIM(pccorigen)  ) = '' ) OR ( pnaturaleza  = '' ) OR ( pimporte  = 0.00 ) OR
		   ( LENGTH( TRIM(pctacontable1) ) = '' ) OR ( LENGTH( TRIM(pccdestino1) ) = '' ) OR ( LENGTH( TRIM(pccorigen1) ) = '' ) OR ( pnaturaleza1 = '' ) OR ( pimporte1 = 0.00 ) OR
		   ( LENGTH( TRIM(pctacontable2) ) = '' ) OR ( LENGTH( TRIM(pccdestino2) ) = '' ) OR ( LENGTH( TRIM(pccorigen2) ) = '' ) OR ( pnaturaleza2 = '' ) OR ( pimporte2 = 0.00 ) OR
		   ( LENGTH( TRIM(pctacontable3) ) = '' ) OR ( LENGTH( TRIM(pccdestino3) ) = '' ) OR ( LENGTH( TRIM(pccorigen3) ) = '' ) OR ( pnaturaleza3 = '' ) OR ( pimporte3 = 0.00 ) THEN
			LET vcodret1 = '00000';
			RETURN vcodret1;
		/*IF ( LENGTH( TRIM(pctacontable)  ) <> 14 OR pctacontable  is null ) OR ( LENGTH( TRIM(pccdestino)  ) <> 4 OR pccdestino  is null ) OR ( LENGTH( TRIM(pccorigen)  ) <> 4 OR pccorigen is null  ) OR ( pnaturaleza  NOT IN('D','C') OR pnaturaleza  is null ) OR ( pimporte  <= 0.00 OR pimporte  is null ) OR
		   ( LENGTH( TRIM(pctacontable1) ) <> 14 OR pctacontable1 is null ) OR ( LENGTH( TRIM(pccdestino1) ) <> 4 OR pccdestino1 is null ) OR ( LENGTH( TRIM(pccorigen1) ) <> 4 OR pccorigen1 is null ) OR ( pnaturaleza1 NOT IN('D','C') OR pnaturaleza1 is null ) OR ( pimporte1 <= 0.00 OR pimporte1 is null ) OR
		   ( LENGTH( TRIM(pctacontable2) ) <> 14 OR pctacontable2 is null ) OR ( LENGTH( TRIM(pccdestino2) ) <> 4 OR pccdestino2 is null ) OR ( LENGTH( TRIM(pccorigen2) ) <> 4 OR pccorigen2 is null ) OR ( pnaturaleza2 NOT IN('D','C') OR pnaturaleza2 is null ) OR ( pimporte2 <= 0.00 OR pimporte2 is null ) OR
		   ( LENGTH( TRIM(pctacontable3) ) <> 14 OR pctacontable3 is null ) OR ( LENGTH( TRIM(pccdestino3) ) <> 4 OR pccdestino3 is null ) OR ( LENGTH( TRIM(pccorigen3) ) <> 4 OR pccorigen3 is null ) OR ( pnaturaleza3 NOT IN('D','C') OR pnaturaleza3 is null ) OR ( pimporte3 <= 0.00 OR pimporte3 is null ) THEN
			LET vcodret1 = '00110';
			RETURN vcodret1;*/
		END IF;

		-- // PRIMER CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable,  1, 4);
		LET wccsub      = SUBSTR(pctacontable,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable, 11, 2);
		LET wccsector   = SUBSTR(pctacontable, 13, 2);
		   
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
		   AND chrcargoabono = pnaturaleza
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte 
		   AND chrcargoabono = pnaturaleza
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte, pnaturaleza, pccorigen, pinstancia);
		END IF;
		
		-- // SEGUNDA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable1,  1, 4);
		LET wccsub      = SUBSTR(pctacontable1,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable1,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable1,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable1, 11, 2);
		LET wccsector   = SUBSTR(pctacontable1, 13, 2);
		
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte1 
		   AND chrcargoabono = pnaturaleza1
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte1 
		   AND chrcargoabono = pnaturaleza1
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte1, pnaturaleza1, pccorigen1, pinstancia);
		END IF;
		
		-- // TERCER CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable2,  1, 4);
		LET wccsub      = SUBSTR(pctacontable2,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable2,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable2,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable2, 11, 2);
		LET wccsector   = SUBSTR(pctacontable2, 13, 2);
		
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
			
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte2 
		   AND chrcargoabono = pnaturaleza2
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte2 
		   AND chrcargoabono = pnaturaleza2
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte2, pnaturaleza2, pccorigen2, pinstancia);
		END IF;
		
		-- // CUARTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable3,  1, 4);
		LET wccsub      = SUBSTR(pctacontable3,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable3,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable3,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable3, 11, 2);
		LET wccsector   = SUBSTR(pctacontable3, 13, 2);
		
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
		
		LET wintpkpasecont = wintpkpasecont + 1;
		
		SELECT COUNT(*) 
		  INTO iExiste1
		  FROM bdispei:"informix".tblpasecont 
		 WHERE mnymonto = pimporte3 
		   AND chrcargoabono = pnaturaleza3
		   AND instancia = pinstancia;
		   
		SELECT COUNT(*) 
		  INTO iExiste2
		  FROM bdispei:"informix".tblpaseconthist 
		 WHERE dtfechacont = wfecha_hoy 
		   AND mnymonto = pimporte3 
		   AND chrcargoabono = pnaturaleza3
		   AND instancia = pinstancia;
		   
		IF iExiste1 = 0 AND iExiste2 = 0 THEN
			INSERT INTO bdispei:"informix".tblpasecont
			(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
			VALUES
			(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte3, pnaturaleza3, pccorigen3, pinstancia);
		END IF;
		
		-- // QUINTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable4,  1, 4);
		LET wccsub      = SUBSTR(pctacontable4,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable4,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable4,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable4, 11, 2);
		LET wccsector   = SUBSTR(pctacontable4, 13, 2);
		
		IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN
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
		
			LET wintpkpasecont = wintpkpasecont + 1;
		
			SELECT COUNT(*) 
			  INTO iExiste1
			  FROM bdispei:"informix".tblpasecont 
			 WHERE mnymonto = pimporte4 
			   AND chrcargoabono = pnaturaleza4
			   AND instancia = pinstancia;
			   
			SELECT COUNT(*) 
			  INTO iExiste2
			  FROM bdispei:"informix".tblpaseconthist 
			 WHERE dtfechacont = wfecha_hoy 
			   AND mnymonto = pimporte4 
			   AND chrcargoabono = pnaturaleza4
			   AND instancia = pinstancia;
			   
			IF iExiste1 = 0 AND iExiste2 = 0 THEN
				INSERT INTO bdispei:"informix".tblpasecont
				(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
				VALUES
				(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte4, pnaturaleza4, pccorigen4, pinstancia);
			END IF;
		END IF;
		
		-- // SEXTA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable5,  1, 4);
		LET wccsub      = SUBSTR(pctacontable5,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable5,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable5,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable5, 11, 2);
		LET wccsector   = SUBSTR(pctacontable5, 13, 2);

		IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN				
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
		  
			LET wintpkpasecont = wintpkpasecont + 1;
			
			SELECT COUNT(*) 
			  INTO iExiste1
			  FROM bdispei:"informix".tblpasecont 
			 WHERE mnymonto = pimporte5 
			   AND chrcargoabono = pnaturaleza5
			   AND instancia = pinstancia;
			   
			SELECT COUNT(*) 
			  INTO iExiste2
			  FROM bdispei:"informix".tblpaseconthist 
			 WHERE dtfechacont = wfecha_hoy 
			   AND mnymonto = pimporte5 
			   AND chrcargoabono = pnaturaleza5
			   AND instancia = pinstancia;
			   
			IF iExiste1 = 0 AND iExiste2 = 0 THEN
				INSERT INTO bdispei:"informix".tblpasecont
				(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
				VALUES
				(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte5, pnaturaleza5, pccorigen5, pinstancia);
			END IF;
		END IF;
		
		-- // SEPTIMA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable6,  1, 4);
		LET wccsub      = SUBSTR(pctacontable6,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable6,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable6,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable6, 11, 2);
		LET wccsector   = SUBSTR(pctacontable6, 13, 2);

		IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN		  
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
		
			LET wintpkpasecont = wintpkpasecont + 1;
		
			SELECT COUNT(*) 
			  INTO iExiste1
			  FROM bdispei:"informix".tblpasecont 
			 WHERE mnymonto = pimporte6 
			   AND chrcargoabono = pnaturaleza6
			   AND instancia = pinstancia;
			   
			SELECT COUNT(*) 
			  INTO iExiste2
			  FROM bdispei:"informix".tblpaseconthist 
			 WHERE dtfechacont = wfecha_hoy 
			   AND mnymonto = pimporte6 
			   AND chrcargoabono = pnaturaleza6
			   AND instancia = pinstancia;
			   
			IF iExiste1 = 0 AND iExiste2 = 0 THEN
				INSERT INTO bdispei:"informix".tblpasecont
				(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
				VALUES
				(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte6, pnaturaleza6, pccorigen6, pinstancia);
			END IF;
		END IF;
		
		-- // OCTAVA CUENTA CONTABLE
		LET wccmayor    = SUBSTR(pctacontable7,  1, 4);
		LET wccsub      = SUBSTR(pctacontable7,  5, 2);
		LET wccsubsub   = SUBSTR(pctacontable7,  7, 2);
		LET wccssubsub  = SUBSTR(pctacontable7,  9, 2);
		LET wccsssubsub = SUBSTR(pctacontable7, 11, 2);
		LET wccsector   = SUBSTR(pctacontable7, 13, 2);
		
		IF wccmayor IS NULL or wccmayor = " " OR wccmayor = "0000" THEN			
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
		
			LET wintpkpasecont = wintpkpasecont + 1;
		
			SELECT COUNT(*) 
			  INTO iExiste1
			  FROM bdispei:"informix".tblpasecont 
			 WHERE mnymonto = pimporte7 
			   AND chrcargoabono = pnaturaleza7
			   AND instancia = pinstancia;
			   
			SELECT COUNT(*) 
			  INTO iExiste2
			  FROM bdispei:"informix".tblpaseconthist 
			 WHERE dtfechacont = wfecha_hoy 
			   AND mnymonto = pimporte7 
			   AND chrcargoabono = pnaturaleza7
			   AND instancia = pinstancia;
			   
			IF iExiste1 = 0 AND iExiste2 = 0 THEN
				INSERT INTO bdispei:"informix".tblpasecont
				(intpkpasecont, chrsucursal, ccmayor, chrempresa, ccsub, ccsubsub, ccsssubsub, ccsector, ccssubsub, ccauxiliar, chrtransaccion, chrdivisa, mnymonto, chrcargoabono, costo_orig, instancia)
				VALUES
				(wintpkpasecont, wchrsucursal, wccmayor, wchrempresa, wccsub, wccsubsub, wccsssubsub, wccsector, wccssubsub, wccauxiliar, wchrtransaccion, wchrdivisa, pimporte7, pnaturaleza7, pccorigen7, pinstancia);
			END IF;
		END IF;
		
		-- // CIERRA TRANSACCION
		COMMIT WORK;
		LET ven_transacc = 0;
		  
		-- // GENERA EL PASE CONTABLE DEL SISTEMA SPEI (B)
		SELECT COUNT(*)
		  INTO wmovimientos
		  FROM bdispei:"informix".tblpaseconthist
		 WHERE dtfechacont = today;
		
		IF wmovimientos = 0 THEN
			INSERT INTO bdispei:"informix".tblpaseconthist
			SELECT wfecha_hoy, cont.* 
			  FROM bdispei:"informix".tblpasecont cont
			 WHERE instancia = pinstancia;
			
			IF dbinfo('sqlca.sqlerrd2') > 0 THEN
				DELETE FROM bdispei:"informix".tblpasecont
				WHERE intpkpasecont > 0;
			END IF;

			UPDATE STATISTICS MEDIUM FOR TABLE bdispei:"informix".tblpasecont;

			-- // Ejecuta Pase Contable del SPEI
			EXECUTE PROCEDURE bdispei:"informix".sp_pasecontab(wchrempresa, wfecha_hoy, pinstancia) 
			INTO vcodret1;
		END IF;
		
		UPDATE tblctrlproceso
		   SET chrstatus = '3'
		 WHERE dtfecha = wfecha_hoy
		   AND intcveproceso = 9;
		
	END IF;
	
    IF vcodret1 = '000' THEN
        LET vcodret1 = "00000";
    END IF;
	
		
    IF vtransaccion = 1 THEN
        BEGIN WORK;
    END IF;
    
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;