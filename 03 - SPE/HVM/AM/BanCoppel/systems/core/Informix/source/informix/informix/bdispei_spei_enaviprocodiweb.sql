CREATE PROCEDURE "informix".spei_enaviprocodiweb() 
RETURNING CHAR(1500);
		  /*INTEGER,CHAR(2),CHAR(2),CHAR(20),CHAR(20), CHAR(50),DECIMAL(12,2),CHAR(23),CHAR(30),CHAR(7),CHAR(10),CHAR(3),
		  CHAR(5),CHAR(2),CHAR(20),CHAR(40),CHAR(20),CHAR(3),CHAR(5),CHAR(2),CHAR(20),CHAR(40),CHAR (512);*/
    
    DEFINE vcodret      char(5);
    DEFINE vcodret2     char(5);
    DEFINE vcodret3     char(50);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE desc_err     char(80);
    
    DEFINE wvchridtpa       CHAR(2);
    DEFINE wvchrcode        CHAR(2);
    DEFINE wvchridmjc       CHAR(20);
    DEFINE wvchrfchmjc      CHAR(20);
    DEFINE wvchrconcepto    CHAR(50);
    DEFINE wmnyimporte      DECIMAL(12,2);
    DEFINE wvchrfchfinpro   CHAR(23);
    DEFINE wvchrcveras      CHAR(30);
    DEFINE wvchrrefnum      CHAR(7);
    DEFINE wvchrcelord      CHAR(10);
    DEFINE wvchrdiveord     CHAR(3);
    DEFINE wvchrbancoord    CHAR(5);
    DEFINE wvchrtpoctaord   CHAR(2);
    DEFINE wvchrctaord      CHAR(20);
    DEFINE wvchrnomord      CHAR(40);
    DEFINE wvchrcelbenf     CHAR(20);
    DEFINE wvchrdivebenf    CHAR(3);
    DEFINE wvchrbancobenf   CHAR(5);
    DEFINE wvchrtpoctabenf  CHAR(2);
    DEFINE wvchrctabef      CHAR(20);
    DEFINE wvchrnombenf      CHAR(40);
    DEFINE wvchrcvespeienva CHAR(5);
    DEFINE wvchrfchenvpro   CHAR(23);
    DEFINE wvchrnumseriecert CHAR(20);
    DEFINE wvchrcadena1       CHAR(750);
    DEFINE wvchrcadena2       CHAR(750);
    DEFINE wvchrcadena       CHAR(1500);
    DEFINE wmnyimpo          CHAR(1);
	DEFINE wnum_serial       INTEGER;
	DEFINE wvchrfirma 		CHAR (512);
    
    LET vcodret  = '00000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET sql_err  = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET wvchrcadena1 = '';
    LET wvchrcadena2 = '';
    LET wvchrcadena = '';
    
    LET wvchridtpa       = '';
    LET wvchrcode        = '';
    LET wvchridmjc       = '';
    LET wvchrfchmjc      = '';
    LET wvchrconcepto    = '';
    LET wmnyimporte      = 0;
    LET wvchrfchfinpro   = '';
    LET wvchrcveras      = '';
    LET wvchrrefnum      = '';
    LET wvchrcelord      = '';
    LET wvchrdiveord     = '';
    LET wvchrbancoord    = '';
    LET wvchrtpoctaord   = '';
    LET wvchrctaord      = '';
    LET wvchrnomord      = '';
    LET wvchrcelbenf     = '';
    LET wvchrdivebenf    = '';
    LET wvchrbancobenf   = '';
    LET wvchrtpoctabenf  = '';
    LET wvchrctabef      = '';
    LET wvchrnombenf      = '';
    LET wvchrcvespeienva = '';
    LET wvchrfchenvpro   = '';
    LET wvchrnumseriecert = '';
    
	BEGIN
    
	ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_enaviprocodi.err";
        TRACE ON;
		IF sql_err <> 0 THEN
            LET vcodret  = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
			RETURN wvchrcadena;
			/*RETURN wnum_serial, wvchridtpa, wvchrcode, wvchridmjc, wvchrfchmjc, wvchrconcepto, wmnyimporte, wvchrfchfinpro, wvchrcveras, wvchrrefnum,
				   wvchrcelord, wvchrdiveord, wvchrbancoord, wvchrtpoctaord, wvchrctaord, wvchrnomord, wvchrcelbenf, wvchrdivebenf, wvchrbancobenf,
				   wvchrtpoctabenf, wvchrctabef, wvchrnombenf,wvchrfirma;*/
		END IF;
	END EXCEPTION;
	
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_enaviprocodi.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
		--//Se consulta los datos del aviso de procesamiento 
        SELECT FIRST 1
              num_serial, vchridtpa, vchrcode, vchridmjc, vchrfchmjc, vchrconcepto, mnyimporte, vchrfchfinpro, vchrcveras, vchrrefnum,
              vchrcelord, vchrdiveord, vchrbancoord, vchrtpoctaord, vchrctaord, vchrnomord, vchrcelbenf, vchrdivebenf, vchrbancobenf,
              vchrtpoctabenf, vchrctabef, vchrnombenf,vchrfirma
         INTO wnum_serial, wvchridtpa, wvchrcode, wvchridmjc, wvchrfchmjc, wvchrconcepto, wmnyimporte, wvchrfchfinpro, wvchrcveras, wvchrrefnum,
              wvchrcelord, wvchrdiveord, wvchrbancoord, wvchrtpoctaord, wvchrctaord, wvchrnomord, wvchrcelbenf, wvchrdivebenf, wvchrbancobenf,
              wvchrtpoctabenf, wvchrctabef, wvchrnombenf,wvchrfirma
        FROM bdispei:tbl_stsprocodi
        WHERE vstatenv = 'N';
		--//Si el aviso es diferente de un rechazo o un pospuesto y el importe es cero  se envia la cadena vacia.
		IF wvchridtpa <> '2' AND wmnyimporte = 0 THEN	
			IF( wvchridtpa <> '4') THEN 
				LET wvchridtpa = NULL;
				UPDATE bdispei:tbl_stsprocodi
					SET vstatenv = 'E'
				WHERE num_serial = wnum_serial;
			ELSE
				LET wvchridtpa = NULL;
				UPDATE bdispei:tbl_stsprocodi
					SET vstatenv = 'E'
				WHERE num_serial = wnum_serial;			
			END IF;
			
		END IF;
		
			
		IF 	wvchridtpa is not null THEN
					UPDATE bdispei:tbl_stsprocodi
					   SET vstatenv = 'E'
					 WHERE num_serial = wnum_serial;

					/*IF wvchrconcepto IS NULL OR wvchrconcepto = '' THEN
						LET wvchrconcepto = '-';
					END IF;

					IF wvchrcveras IS NULL OR wvchrcveras = '' THEN
						LET wvchrcveras = '-';
					END IF;

					IF wvchrrefnum IS NULL OR wvchrrefnum = '' OR wvchrrefnum = '-' THEN
						LET wvchrrefnum = '0';
					END IF;

					IF wvchrcelord IS NULL OR wvchrcelord = '' THEN
						LET wvchrcelord = '-';
					END IF;

					IF wvchrdiveord IS NULL OR wvchrdiveord = '' THEN
						LET wvchrdiveord = '-';
					END IF;

					IF wvchrbancoord IS NULL  THEN
						LET wvchrbancoord = 0;
					END IF;

					IF wvchrtpoctaord IS NULL OR wvchrtpoctaord = '' THEN
						LET wvchrtpoctaord = '-';
					END IF;

					IF wvchrctaord IS NULL OR wvchrctaord = '' THEN
						LET wvchrctaord = '-';
					END IF;

					 IF wvchrnomord IS NULL OR wvchrnomord = '' THEN
						LET wvchrnomord = '-';
					END IF;

					IF wvchrcelbenf IS NULL OR wvchrcelbenf = '' THEN
						LET wvchrcelbenf = '-';
					END IF;

					IF wvchrdivebenf IS NULL OR wvchrdivebenf = '' THEN
						LET wvchrdivebenf = '-';
					END IF;

					IF wvchrbancobenf IS NULL  THEN
						LET wvchrbancobenf = 0;
					END IF;

					IF wvchrtpoctabenf IS NULL OR wvchrtpoctabenf = '' THEN
						LET wvchrtpoctabenf = '-';
					END IF;

					IF wvchrctabef IS NULL OR wvchrctabef = '' THEN
						LET wvchrctabef = '-';
					END IF;

					IF wvchrnombenf IS NULL OR wvchrnombenf = '' THEN
						LET wvchrnombenf = '-';
					END IF;*/

					IF wmnyimporte = 0 THEN
						LET wmnyimpo = '-';
						LET wvchrcadena1 = TRIM(wvchridtpa)||'|'||TRIM(wvchrcode)||'|'||TRIM(wvchridmjc)||'|'||TRIM(wvchrfchmjc)||'|'||TRIM(wvchrconcepto)||'|'||wmnyimpo||'|'||TRIM(wvchrfchfinpro)||'|'||TRIM(wvchrcveras)||'|'||
										   wvchrrefnum::integer||'|'||TRIM(wvchrcelord)||'|'||TRIM(wvchrdiveord)||'|';
						LET wvchrcadena2 = TRIM(wvchrbancoord)||'|'||TRIM(wvchrtpoctaord)||'|'||TRIM(wvchrctaord)||'|'||TRIM(wvchrnomord)||'|'||TRIM(wvchrcelbenf)||'|'||
										   TRIM(wvchrdivebenf)||'|'||TRIM(wvchrbancobenf)||'|'||TRIM(wvchrtpoctabenf)||'|'||TRIM(wvchrctabef)||'|'||TRIM(wvchrnombenf)||'|'||TRIM(wvchrfirma); 
						LET wvchrcadena =  TRIM(wvchrcadena1)||TRIM(wvchrcadena2);
					ELSE
						LET wvchrcadena1 = TRIM(wvchridtpa)||'|'||TRIM(wvchrcode)||'|'||TRIM(wvchridmjc)||'|'||TRIM(wvchrfchmjc)||'|'||TRIM(wvchrconcepto)||'|'||wmnyimporte||'|'||TRIM(wvchrfchfinpro)||'|'||TRIM(wvchrcveras)||'|'||
										   wvchrrefnum::integer||'|'||TRIM(wvchrcelord)||'|'||TRIM(wvchrdiveord)||'|';
						LET wvchrcadena2 = TRIM(wvchrbancoord)||'|'||TRIM(wvchrtpoctaord)||'|'||TRIM(wvchrctaord)||'|'||TRIM(wvchrnomord)||'|'||TRIM(wvchrcelbenf)||'|'||
										   TRIM(wvchrdivebenf)||'|'||TRIM(wvchrbancobenf)||'|'||TRIM(wvchrtpoctabenf)||'|'||TRIM(wvchrctabef)||'|'||TRIM(wvchrnombenf)||'|'||TRIM(wvchrfirma);
						LET wvchrcadena =  TRIM(wvchrcadena1)||TRIM(wvchrcadena2);

					END IF;
					
					RETURN wvchrcadena
					WITH RESUME;
					/* 
					RETURN wnum_serial, wvchridtpa, wvchrcode, wvchridmjc, wvchrfchmjc, wvchrconcepto, wmnyimporte, wvchrfchfinpro, wvchrcveras, wvchrrefnum,
						   wvchrcelord, wvchrdiveord, wvchrbancoord, wvchrtpoctaord, wvchrctaord, wvchrnomord, wvchrcelbenf, wvchrdivebenf, wvchrbancobenf,
						   wvchrtpoctabenf, wvchrctabef, wvchrnombenf,wvchrfirma
					WITH RESUME;*/
					 
		
		ELSE
		    LET wvchrcadena = '';
			RETURN wvchrcadena WITH RESUME;
			/*
			RETURN wnum_serial, wvchridtpa, wvchrcode, wvchridmjc, wvchrfchmjc, wvchrconcepto, wmnyimporte, wvchrfchfinpro, wvchrcveras, wvchrrefnum,
				   wvchrcelord, wvchrdiveord, wvchrbancoord, wvchrtpoctaord, wvchrctaord, wvchrnomord, wvchrcelbenf, wvchrdivebenf, wvchrbancobenf,
				   wvchrtpoctabenf, wvchrctabef, wvchrnombenf,wvchrfirma
			WITH RESUME;*/
			
			--UPDATE bdispei:tbl_stsprocodi
			--		   SET vstatenv = 'C'--canlada por que no cumple/*ifg28062019*/
			--		 WHERE vnum_serial = wnum_serial;
        END IF;
		 
        /*RETURN wvchridtpa, wvchrcode, wvchridmjc, wvchrfchmjc, wvchrconcepto, wmnyimporte, wvchrfchfinpro, wvchrcveras, wvchrrefnum,
               wvchrcelord, wvchrdiveord, wvchrbancoord, wvchrtpoctaord, wvchrctaord, wvchrnomord, wvchrcelbenf, wvchrdivebenf, wvchrbancobenf,
               wvchrtpoctabenf, wvchrctabef, wvchrnombenf ;--WITH RESUME;*/
        --RETURN wvchrcadena;
    
    
    END;
    
END PROCEDURE
DOCUMENT
'CREADO POR: PRISCILLA BENITO',
'OBJETIVO: ENVIAR LOS AVISOS DE PROCESAMIENTO A BANCO DE MEXICO',
'BD: BDISPEI';

CREATE PROCEDURE "informix".spei_aplicaordenpago_juan( pRegistros INTEGER, pOrigen CHAR(1) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cDescErr         CHAR(50);
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE cCodRet4         CHAR(5);
    DEFINE cCodRet5         CHAR(5);
    DEFINE cCodRet6         CHAR(5);
    DEFINE cCodRet7         CHAR(5);
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE iComienza        SMALLINT;
    DEFINE iAbierto         SMALLINT;
    DEFINE cDisponible      CHAR(1);
    DEFINE cStatusProc      CHAR(1);
    DEFINE cCveRastreo      CHAR(30);
    DEFINE cCuenta          CHAR(20);
    DEFINE mMonto           DECIMAL(14,2);
    DEFINE dFechaVal        DATE;
    DEFINE cCtaBenef        CHAR(20);
    DEFINE cNumCte          CHAR(20);
    DEFINE cCtaBenefEmail   CHAR(20);
    DEFINE cTpoCtaBenefMsg  CHAR(25);
    DEFINE cTransacc        CHAR(4);
    DEFINE iSerialFolio     INTEGER;
    DEFINE cFolioSuc        CHAR(30);
    DEFINE iExiste          INTEGER;
    DEFINE cCtaBenefMsg     CHAR(20);
    DEFINE iCodRet          SMALLINT;
    DEFINE iVueltas         SMALLINT;
    
    DEFINE wchrconceptopago2  CHAR(40);
    DEFINE wintrefnumerica    DECIMAL(7,0);
    DEFINE wcvecesifbcoord    INTEGER;
    DEFINE wintcvetipoctaord  INTEGER;
    DEFINE wvchrcuentaord     CHAR(20);
    DEFINE wvchrnombreord     CHAR(40);
    DEFINE wintcvetipoctabene INTEGER;
    DEFINE wvchrnombrebenef   CHAR(40);
    DEFINE vtimestamp         LVARCHAR(20);
    DEFINE wtimestamp         CHAR(20);
    DEFINE wchrtipopago       CHAR(2); 
    DEFINE wchridmjc          CHAR(20);
    DEFINE wchrfchmjc         CHAR(20);
    DEFINE wchrnumcelord      CHAR(10);
    DEFINE wintdigidord       INTEGER;
    DEFINE wchrnumcelben      CHAR(20);
    DEFINE wintdigidben       INTEGER;
    DEFINE wchrnumseriecert   CHAR(20);
    DEFINE wvchrcodretcodi    CHAR(5);
    
    DEFINE wcadena_val      CHAR (1000);
    DEFINE wvchrrefcobranza CHAR(40);
    DEFINE wchrfechalimpago CHAR(16);
    DEFINE wintpagocomision INTEGER;
    DEFINE wvcomision 		DECIMAL(14,2);
    DEFINE vcomision        CHAR(7);
	DEFINE vcomision2       CHAR(7);
	DEFINE vcomision3       CHAR(7);
    DEFINE wchrfolioplataf CHAR(20);
    DEFINE wvchrfirma       CHAR(512);
    DEFINE codretfirma      INTEGER;
    DEFINE wcomision 		DECIMAL(14,2);
    DEFINE wchrstatus       CHAR(1);
    
    LET iSqlErr	        = 0;
    LET iIsamErr        = 0;
    LET cDescErr        = '';
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET cCodRet4        = '';
    LET cCodRet5        = '';
    LET cCodRet6        = '';
    LET cCodRet7        = '';    
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET iComienza       = -1;
    LET iAbierto        = 0;
    LET cDisponible     = '0';
    LET cStatusProc     = '';
    LET cCveRastreo     = '';
    LET cCuenta         = '';
    LET mMonto          = 0.00;
    LET dFechaVal       = '';
    LET cCtaBenef       = '';
    LET cNumCte         = '';
    LET cCtaBenefEmail  = '';
    LET cTpoCtaBenefMsg = '';
    LET cTransacc       = '';
    LET iSerialFolio    = 0;
    LET cFolioSuc       = '';
    LET iExiste         = 0;
    LET cCtaBenefMsg    = '';
    LET iCodRet         = 0;
    LET iVueltas        = 0;
    
    LET wchrconceptopago2  = '';
    LET wintrefnumerica    = 0;
    LET wcvecesifbcoord    = 0;
    LET wintcvetipoctaord  = 0;
    LET wvchrcuentaord     = '';
    LET wvchrnombreord     = '';
    LET wintcvetipoctabene = 0;
    LET wvchrnombrebenef   = '';
    LET vtimestamp         = dbinfo('utc_current') * 1000;
    LET wtimestamp         = vtimestamp;
    LET wchrtipopago       = '';
    LET wchridmjc          = '';
    LET wchrfchmjc         = '';
    LET wchrnumcelord      = '';
    LET wintdigidord       = 0;
    LET wchrnumcelben      = '';
    LET wintdigidben       = 0;
    LET wchrnumseriecert   = '';
    LET wvchrcodretcodi    = '';
    
    LET wcadena_val      = '';
    LET wvchrrefcobranza = '';
    LET wchrfechalimpago = '';
    LET wintpagocomision = '';
    LET wvcomision       = 0.00;
    LET vcomision        = '';
	LET vcomision2       = '0.00';
	LET vcomision3       = '0';
    LET wchrfolioplataf  = '';
    LET wvchrfirma       = '';
    LET codretfirma      = 0;
    LET wcomision        = 0.00;
    LET wchrstatus       = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_aplicaordenpago.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
            END IF;
            
            IF   pOrigen = 'N' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 8;
            ELIF pOrigen = 'G' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 10;
            ELIF pOrigen = 'H' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 11;
            ELIF pOrigen = 'I' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 12;
            ELIF pOrigen = 'J' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 13;
            ELIF pOrigen = 'K' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 14;
            ELIF pOrigen = 'P' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 15;
            ELIF pOrigen = 'Q' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 16;
            ELIF pOrigen = 'R' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 17;
            ELIF pOrigen = 'S' THEN
                UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 18;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_aplicaordenpago.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF   pOrigen = 'N' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 8;
    ELIF pOrigen = 'G' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 10;
    ELIF pOrigen = 'H' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 11;
    ELIF pOrigen = 'I' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 12;
    ELIF pOrigen = 'J' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 13;
    ELIF pOrigen = 'K' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 14;
    ELIF pOrigen = 'P' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 15;
    ELIF pOrigen = 'Q' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 16;
    ELIF pOrigen = 'R' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 17;
    ELIF pOrigen = 'S' THEN
        SELECT chrstatus INTO cStatusProc FROM tblctrlproceso WHERE intcveproceso = 18;
    END IF;
     
    IF cStatusProc = '0' THEN
        
        IF   pOrigen = 'N' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 8;
        ELIF pOrigen = 'G' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 10;
        ELIF pOrigen = 'H' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 11;
        ELIF pOrigen = 'I' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 12;
        ELIF pOrigen = 'J' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 13;
        ELIF pOrigen = 'K' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 14;
        ELIF pOrigen = 'P' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 15;
        ELIF pOrigen = 'Q' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 16;
        ELIF pOrigen = 'R' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 17;
        ELIF pOrigen = 'S' THEN
            UPDATE tblctrlproceso SET chrstatus = '1' WHERE intcveproceso = 18;
        END IF;
    
        SELECT ind_disponible
          INTO cDisponible
          FROM bdicheq:sc_fechas
         WHERE empresa = '001';
         
        IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN
            LET cCodRet1 = '004';
            RETURN cCodRet1, iContador1, iContador2;
        END IF;


            SELECT FIRST 200
                   vchrclaverastreo, vchrcuentachq, mnyimporte, dtfechavalor, vchrcuentabenef, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                   vchrconceptopago2, intrefnumerica, cvecesifbcoord, intcvetipoctaord, vchrcuentaord, vchrnombreord, intcvetipoctabene, vchrnombrebenef,
                   chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                   vchrrefcobranza, fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, chrestatusenvio
              FROM tblabono 
             WHERE chrestatusenvio = 'H'
             into temp paso_spei with no log;
        
        FOREACH WITH HOLD
            SELECT vchrclaverastreo, vchrcuentachq, mnyimporte, dtfechavalor, vchrcuentabenef, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                   vchrconceptopago2, intrefnumerica, cvecesifbcoord, intcvetipoctaord, vchrcuentaord, vchrnombreord, intcvetipoctabene, vchrnombrebenef,
                   chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                   vchrrefcobranza, fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, chrestatusenvio
              INTO cCveRastreo, cCuenta, mMonto, dFechaVal, cCtaBenef, cNumCte, cCtaBenefEmail, cTpoCtaBenefMsg, cTransacc, cFolioSuc,
                   wchrconceptopago2, wintrefnumerica, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wintcvetipoctabene, wvchrnombrebenef,
                   wchrtipopago, wchridmjc, wchrfchmjc, wchrnumcelord, wintdigidord, wchrnumcelben, wintdigidben, wchrnumseriecert,
                   wvchrrefcobranza, wchrfechalimpago, wintpagocomision, wvcomision, wchrfolioplataf, wvchrfirma, wchrstatus
              FROM paso_spei
             --ORDER BY intnumserial
            
            BEGIN WORK;
            LET iAbierto = 1;
            
            LET iContador1 = iContador1 + 1;
            
            -- // DETERMINA LA COMISION
            LET wcomision = wvcomision;
            
            IF wchrtipopago IN('19', '20', '21', '22') THEN
                IF wcomision = 0.00 THEN
                   LET vcomision = '0.0';
                ELSE
                   LET vcomision = wcomision;
                END IF;
            ELSE
                LET vcomision = '0.00';
            END IF;
            
            LET wchrstatus = 'L';
            
            -- // GENERA CADENA A VALIDAR
            LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                              '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                              '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                              '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';
              
            EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
            INTO codretfirma;

            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';
              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;
            
            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision2)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';

              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;

            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision3)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';

              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;	
            
            IF codretfirma = 0 THEN
            
                SELECT COUNT(*)
                  INTO iExiste
                  FROM bdicheq:sc_movdia
                 WHERE transacc IN('0273','0276','0277','0446')
                   AND fech_val = dFechaVal
                   AND cancelad <> 'S'
                   AND referencia = cCveRastreo
                   AND cuenta = cCuenta;
                   
                IF iExiste > 0 THEN
                    UPDATE tblabono
                       SET chrestatusenvio = 'M'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                    COMMIT WORK;
                    LET iAbierto = 0;
                    
                    CONTINUE FOREACH;
                END IF;
                
                IF cFolioSuc is null OR cFolioSuc = '' THEN
                    CALL sp_obtfoliosuc('tranSPEI')
                    RETURNING cCodRet4, iSerialFolio, cFolioSuc;

                    IF cCodRet4 <> '000' THEN
                        LET cFolioSuc = 'SPEI'||dFechaVal;
                    END IF;
                END IF;
                
                EXECUTE PROCEDURE bdicheq:abono_ref('001', '9201', 'tranSPEI', cTransacc, '0000', cFolioSuc, cCuenta, 0, mMonto, mMonto, 0, 0, 0, '01', cCveRastreo, '', '')
                INTO cCodRet5;
                
                LET iCodRet = cCodRet5::INT;
                
                IF cCodRet5 = '000' THEN
                    UPDATE tblabono
                       SET chrestatusenvio = 'L'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                    IF wchrtipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi('0', ' ', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2, mMonto, wtimestamp, cCveRastreo, wintrefnumerica, 
                                                 wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                                 wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                    
                    LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);
                    
                    -- // EMAIL
                     EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                     ('1', 'SPEI_TRREC', 'SPEI_TRREC', cNumCte, '', '', '1', '', cCtaBenefEmail, mMonto, cCveRastreo, cTpoCtaBenefMsg, '', '', '', '', '', '', '', 1, 0, 0, 0, 0, current, '')
                     INTO cCodRet6;

                    -- // SMS
                     EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                     ('2', 'SPEI_SMREC', 'SPEI_SMREC', cNumCte, '', '', '1', cCtaBenefMsg, mMonto, '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, current, '')
                     INTO cCodRet7;
                     
                ELIF ( cCodRet5 <> '000' AND iCodRet < 0 ) THEN
                    
                    /* #####################################
                    UPDATE tblabono
                       SET chrestatusenvio = pOrigen
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                    ##################################### */
                    
                    UPDATE tblabono
                       SET chrestatusenvio = 'S'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                ELIF ( cCodRet5 <> '000' AND iCodRet > 0 ) THEN
                    
                    UPDATE tblabono
                       SET chrestatusenvio = 'X'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                     
                    IF wchrtipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi('16', 'NO SE PUDO REALIZAR EL ABONO CODI', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2 ,mMonto, wtimestamp, cCveRastreo, wintrefnumerica,
                                                 wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                                 wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                END IF;
            ELSE
                UPDATE tblabono
                   SET chrestatusenvio = 'F'
                 WHERE vchrclaverastreo = cCveRastreo
                   AND vchrcuentabenef = cCtaBenef
                   AND mnyimporte = mMonto
                   AND vchrfoliosuc = cFolioSuc;
                 
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET iContador2 = iContador2 + 1;
                END IF;
                 
                IF wchrtipopago IN('19', '20', '21', '22') THEN
                    CALL spei_recerrorescodi('16', 'NO SE PUDO REALIZAR EL ABONO CODI', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2 ,mMonto, wtimestamp, cCveRastreo, wintrefnumerica,
                                             wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                             wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                    RETURNING wvchrcodretcodi;
                END IF;
            END IF;
                
            COMMIT WORK;
            LET iAbierto = 0;
            
            LET cCveRastreo     = '';
            LET cCuenta         = '';
            LET mMonto          = 0.00;
            LET dFechaVal       = '';
            LET cCtaBenef       = '';
            LET cNumCte         = '';
            LET cCtaBenefEmail  = '';
            LET cTpoCtaBenefMsg = '';
            LET cTransacc       = '';
            LET iSerialFolio    = 0;
            LET cFolioSuc       = '';
            LET iExiste         = 0;
            LET cCtaBenefMsg    = '';
            LET iCodRet         = 0;
            LET iVueltas        = 0;
            LET cCodRet4        = '';
            LET cCodRet5        = '';
            LET cCodRet6        = '';
            LET cCodRet7        = '';
            
            LET wchrconceptopago2  = '';
            LET wintrefnumerica    = 0;
            LET wcvecesifbcoord    = 0;
            LET wintcvetipoctaord  = 0;
            LET wvchrcuentaord     = '';
            LET wvchrnombreord     = '';
            LET wintcvetipoctabene = 0;
            LET wvchrnombrebenef   = '';
            LET wchrtipopago       = '';
            LET wchridmjc          = '';
            LET wchrfchmjc         = '';
            LET wchrnumcelord      = '';
            LET wintdigidord       = 0;
            LET wchrnumcelben      = '';
            LET wintdigidben       = 0;
            LET wchrnumseriecert   = '';
            LET wvchrcodretcodi    = '';
            
            LET wcadena_val      = '';
            LET wvchrrefcobranza = '';
            LET wchrfechalimpago = '';
            LET wintpagocomision = '';
            LET wvcomision       = 0.00;
            LET vcomision        = '';
            LET vcomision2       = '0.00';
            LET vcomision3       = '0';
            LET wchrfolioplataf  = '';
            LET wvchrfirma       = '';
            LET codretfirma      = 0;
            LET wcomision        = 0.00;
        END FOREACH;

		drop table paso_spei;
            
        IF   pOrigen = 'N' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 8;
        ELIF pOrigen = 'G' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 10;
        ELIF pOrigen = 'H' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 11;
        ELIF pOrigen = 'I' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 12;
        ELIF pOrigen = 'J' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 13;
        ELIF pOrigen = 'K' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 14;
        ELIF pOrigen = 'P' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 15;
        ELIF pOrigen = 'Q' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 16;
        ELIF pOrigen = 'R' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 17;
        ELIF pOrigen = 'S' THEN
            UPDATE tblctrlproceso SET chrstatus = '0' WHERE intcveproceso = 18;
        END IF;
        
    ELSE
    
        LET cCodRet1 = '003';
        RETURN cCodRet1, iContador1, iContador2;
        
    END IF;
    
    END; 
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE;