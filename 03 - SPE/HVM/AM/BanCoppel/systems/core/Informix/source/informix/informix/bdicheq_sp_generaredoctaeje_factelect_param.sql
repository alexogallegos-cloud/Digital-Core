CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_param( pEmpresa CHAR(3), pFecha DATE, pFechaUltEjec DATE )
RETURNING CHAR(5);
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vctamin          CHAR(20);
    DEFINE vcuenta1         CHAR(20);
    DEFINE vcuenta2         CHAR(20);
	DEFINE vcuenta3         CHAR(20);
	DEFINE vcuenta4         CHAR(20);
	DEFINE vcuenta5         CHAR(20);
    DEFINE vno_ctas         INTEGER;
    
	
	
    LET vcodret    = "000";
    LET vcodret2   = "";
    LET vcodret3   = "";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = ''; 
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vctamin    = '';
    LET vcuenta1   = '';
    LET vcuenta2   = '';
	LET vcuenta3   = '';
	LET vcuenta4   = '';
	LET vcuenta5   = '';
    LET vno_ctas   = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_param.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_param.out";
    ---	TRACE ON;
	
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;    
    
 	SELECT mae.cuenta
    FROM   sc_maehis_cfdi_cap AS mae
    WHERE  mae.fechafin BETWEEN pFechaUltEjec AND pFecha
    INTO   TEMP tmp_ctasmaehis WITH NO LOG;
    CREATE INDEX idxtmp_ctasmaehis_cta ON tmp_ctasmaehis(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasmaehis;
	
  
    SELECT {+INDEX(sc_maehis maehis1)}
           ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM tmp_ctasmaehis;
      
    SELECT MIN(cuenta)
      INTO vctamin
      FROM tmp_ctasmaehis;
      
    UPDATE sc_param
       SET valor = vno_ctas
     WHERE empresa = pempresa
       AND codparam = 'RegIniGenEdoCta';
       
    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta1
                  FROM tmp_ctasmaehis
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta1
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniGenEdoCtaComp1';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM tmp_ctasmaehis
                 WHERE cuenta >= vctamin
                   AND cuenta < vcuenta1;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniGenEdoCtaComp1';
            END FOREACH;
       ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta2
                  FROM tmp_ctasmaehis
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta2
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniGenEdoCtaComp2';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM tmp_ctasmaehis
                 WHERE cuenta >= vctamin
                   AND cuenta < vcuenta2;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniGenEdoCtaComp2';
            END FOREACH;
	   ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta3
                  FROM tmp_ctasmaehis
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta3
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniGenEdoCtaComp3';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM tmp_ctasmaehis
                 WHERE cuenta >= vctamin
                   AND cuenta < vcuenta3;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniGenEdoCtaComp3';
            END FOREACH;
	   ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta4
                  FROM tmp_ctasmaehis
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta4
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniGenEdoCtaComp4';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM tmp_ctasmaehis
                 WHERE cuenta >= vctamin
                   AND cuenta < vcuenta4;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniGenEdoCtaComp4';
            END FOREACH;
	   ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta5
                  FROM tmp_ctasmaehis
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta5
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniGenEdoCtaComp5';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM tmp_ctasmaehis
                 WHERE cuenta >= vctamin
                   AND cuenta < vcuenta5;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniGenEdoCtaComp5';
            END FOREACH;
	
       END IF;
        
    LET vcont = vcont + 1;
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;