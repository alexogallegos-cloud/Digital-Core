CREATE PROCEDURE "informix".spei_depuratblstsprocodi( pfecha_hoy DATE ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    
	DEFINE vnum_serial          INTEGER;
	DEFINE vvstatenv            CHAR(1);
	DEFINE vvchridtpa           CHAR(2);
	DEFINE vvchrcode            CHAR(2);
	DEFINE vvchridmjc           CHAR(20);
	DEFINE vvchrfchmjc          CHAR(20);
	DEFINE vvchrconcepto        CHAR(50);
	DEFINE vmnyimporte          DECIMAL(12,2);
	DEFINE vvchrfchfinpro       CHAR(23);
	DEFINE vvchrcveras          CHAR(30);
	DEFINE vvchrrefnum          CHAR(7);
	DEFINE vvchrcelord          CHAR(10);
	DEFINE vvchrdiveord         CHAR(3);
	DEFINE vvchrbancoord        CHAR(5);
	DEFINE vvchrtpoctaord       CHAR(2);
	DEFINE vvchrctaord          CHAR(20);
	DEFINE vvchrnomord          CHAR(40);
	DEFINE vvchrcelbenf         CHAR(20);
	DEFINE vvchrdivebenf        CHAR(3);
	DEFINE vvchrbancobenf       CHAR(5);
	DEFINE vvchrtpoctabenf      CHAR(2);
	DEFINE vvchrctabef          CHAR(20);
	DEFINE vvchrnombenf         CHAR(40);
	DEFINE vvchrnumseriecert    CHAR(20);
	DEFINE vfcha_oper           DATETIME YEAR to FRACTION(3); 
	
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '';
    LET vCodRet3            = '';  
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vComienza           = -1;
    LET vAbierto            = '0';
    
	LET vnum_serial  = 0;
	LET vvstatenv = '';
	LET vvchridtpa = '';
	LET vvchrcode = '';
	LET vvchridmjc = '';
	LET vvchrfchmjc = '';
	LET vvchrconcepto = '';
	LET vmnyimporte = 0.00;
	LET vvchrfchfinpro = '';
	LET vvchrcveras = '';
	LET vvchrrefnum = '';
	LET vvchrcelord = '';
	LET vvchrdiveord = '';
	LET vvchrbancoord = '';
	LET vvchrtpoctaord = '';
	LET vvchrctaord = '';
	LET vvchrnomord = '';
	LET vvchrcelbenf = '';
	LET vvchrdivebenf = '';
	LET vvchrbancobenf = '';
	LET vvchrtpoctabenf = '';
	LET vvchrctabef = '';
	LET vvchrnombenf = '';
	LET vvchrnumseriecert = '';
	LET vfcha_oper = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratblstsprocodi.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratblstsprocodi.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    

    COMMIT WORK;
    
    FOREACH borra_cursor FOR
				 
		SELECT {+INDEX(bdispei:"informix".tbl_stsprocodi idxtbl_stsprocodi)}
			   num_serial,vstatenv,vchridtpa,vchrcode,vchridmjc,vchrfchmjc,vchrconcepto,mnyimporte,
			   vchrfchfinpro,vchrcveras,vchrrefnum,vchrcelord,vchrdiveord,vchrbancoord,vchrtpoctaord,
			   vchrctaord,vchrnomord,vchrcelbenf,vchrdivebenf,vchrbancobenf,vchrtpoctabenf,vchrctabef,
			   vchrnombenf,vchrnumseriecert,fcha_oper
		  INTO vnum_serial,vvstatenv,vvchridtpa,vvchrcode,vvchridmjc,vvchrfchmjc,vvchrconcepto,
			   vmnyimporte,vvchrfchfinpro,vvchrcveras,vvchrrefnum,vvchrcelord,vvchrdiveord,vvchrbancoord,
			   vvchrtpoctaord,vvchrctaord,vvchrnomord,vvchrcelbenf,vvchrdivebenf,vvchrbancobenf,vvchrtpoctabenf,
			   vvchrctabef,vvchrnombenf,vvchrnumseriecert,vfcha_oper
		FROM bdispei:"informix".tbl_stsprocodi
		WHERE date(fcha_oper) <= pfecha_hoy AND vstatenv = 'E' 
		

        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        	 
		INSERT INTO bdispei:"informix".tbl_histstsprocodi
		(num_serial,vstatenv,vchridtpa,vchrcode,vchridmjc,vchrfchmjc,vchrconcepto,mnyimporte,
		vchrfchfinpro,vchrcveras,vchrrefnum,vchrcelord,vchrdiveord,vchrbancoord,vchrtpoctaord,
		vchrctaord,vchrnomord,vchrcelbenf,vchrdivebenf,vchrbancobenf,vchrtpoctabenf,vchrctabef,
		vchrnombenf,vchrnumseriecert,fcha_oper)
		VALUES
		(vnum_serial,vvstatenv,vvchridtpa,vvchrcode,vvchridmjc,vvchrfchmjc,vvchrconcepto,
		vmnyimporte,vvchrfchfinpro,vvchrcveras,vvchrrefnum,vvchrcelord,vvchrdiveord,vvchrbancoord,
		vvchrtpoctaord,vvchrctaord,vvchrnomord,vvchrcelbenf,vvchrdivebenf,vvchrbancobenf,vvchrtpoctabenf,
		vvchrctabef,vvchrnombenf,vvchrnumseriecert,vfcha_oper);
		 
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            DELETE FROM bdispei:"informix".tbl_stsprocodi
            WHERE date(fcha_oper) <= pfecha_hoy AND vstatenv = 'E'         			 
               AND num_serial = vnum_serial;
        END IF; 
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnum_serial = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        BEGIN WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;