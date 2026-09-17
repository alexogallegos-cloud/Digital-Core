CREATE PROCEDURE "informix".sp_suspenso(pempresa     CHAR(3),
										psistema     CHAR(2),
                                        pmonto_tot   MONEY(14,2),
										psecuencia   INTEGER,
                                        psucope      CHAR(4),
										psuccta      CHAR(4),
										pcancelad    CHAR(1),
                                        pproducto    CHAR(4),
                                        pmoneda      CHAR(2),
                                        ptransacc    CHAR(4),
										psector      CHAR(2),
                                        pdescripcion CHAR(30),
										pfecha_valida DATE)

RETURNING CHAR(5),CHAR(4),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(4),CHAR(2),CHAR(2),CHAR(2),CHAR(2),CHAR(2) ;
    
    DEFINE vcodret           CHAR(5); 
    DEFINE vsqlerr           INTEGER;

    DEFINE vc_ccmayor        CHAR(4);
    DEFINE vc_ccsub          CHAR(2);
    DEFINE vc_ccsubsub       CHAR(2);
    DEFINE vc_ccsssub        CHAR(2);
    DEFINE vc_ccssssub       CHAR(2);
    DEFINE vc_sector         CHAR(2);
    DEFINE va_ccmayor        CHAR(4);
    DEFINE va_ccsub          CHAR(2);
    DEFINE va_ccsubsub       CHAR(2);
    DEFINE va_ccsssub        CHAR(2);
    DEFINE va_ccssssub       CHAR(2);
    DEFINE va_sector         CHAR(2);
	DEFINE vidsc_suspenso	 INTEGER;

    BEGIN 
	
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,'','','','','','','','','','','','';
        END IF;
    END EXCEPTION;

	--set debug file to "sp_suspenso.out";
    --trace on;

    LET vcodret           = '000';
    LET vsqlerr           = 0;

    LET vc_ccmayor        = ' ';
    LET vc_ccsub          = ' ';
    LET vc_ccsubsub       = ' ';
    LET vc_ccsssub        = ' ';
    LET vc_ccssssub       = ' ';
    LET vc_sector         = ' ';
    LET va_ccmayor        = ' ';
    LET va_ccsub          = ' ';
    LET va_ccsubsub       = ' ';
    LET va_ccsssub        = ' ';
    LET va_ccssssub       = ' ';
    LET va_sector         = ' ';

	IF psistema = '01' THEN
	
	    LET vc_ccmayor        = '9801';
		LET vc_ccsub          = '01';
		LET vc_ccsubsub       = '02';
		LET vc_ccsssub        = '01';
		LET vc_ccssssub       = '00';
		LET vc_sector         = '00';
		LET va_ccmayor        = '9801';
		LET va_ccsub          = '02';
		LET va_ccsubsub       = '02';
		LET va_ccsssub        = '01';
		LET va_ccssssub       = '00';
		LET va_sector         = '00';

		SELECT MAX(idsc_suspenso) + 1  INTO vidsc_suspenso FROM bdicheq:sc_suspenso;
		
		IF vidsc_suspenso IS NULL THEN
			LET vidsc_suspenso = 1;
		END IF

		INSERT INTO bdicheq:sc_suspenso (idsc_suspenso,empresa,secuencia,sucursal,succta,cancelad,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar,producto,transacc,sectorca,tot_cargo,tot_abono,moneda,descripcion,fecha_valida)
		VALUES (vidsc_suspenso,pempresa,psecuencia,psucope,psuccta,pcancelad,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,'',pproducto,ptransacc,psector,pmonto_tot,0,pmoneda,pdescripcion,pfecha_valida);

		INSERT INTO bdicheq:sc_suspenso (idsc_suspenso,empresa,secuencia,sucursal,succta,cancelad,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar,producto,transacc,sectorca,tot_cargo,tot_abono,moneda,descripcion,fecha_valida)
		VALUES (vidsc_suspenso,pempresa,psecuencia,psucope,psuccta,pcancelad,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,'',pproducto,ptransacc,psector,0,pmonto_tot,pmoneda,pdescripcion,pfecha_valida);

	END IF

	END

	RETURN vcodret,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector, 
			       va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector;  

END PROCEDURE;