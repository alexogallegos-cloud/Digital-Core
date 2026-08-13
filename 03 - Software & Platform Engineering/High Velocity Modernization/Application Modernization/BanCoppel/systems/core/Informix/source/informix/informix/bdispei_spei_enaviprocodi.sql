CREATE PROCEDURE "informix".spei_enaviprocodi() 
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

CREATE PROCEDURE "informix".spei_envextemporanea
(
pClaveRastreo 		CHAR(30),      -- clave de rastreo
pCuentaBeneficiario	CHAR(20),      -- numero de cuenta del beneficiario
pMonto       		DECIMAL(17,2), -- monto de la operación
pCausaDev   		CHAR(2))       -- causa de devolucion
RETURNING 
	CHAR(30), 		-- folio original del sistema pisa
	CHAR(30), 		-- clave de rastreo
	DECIMAL(17,2); 	-- importe del interes

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;
    DEFINE cEmpresa         CHAR(3);
    DEFINE iSerialFolio    INTEGER;
    DEFINE cNumTarjeta     CHAR(16);
    DEFINE iMaxSec          SMALLINT;
    DEFINE cSucursal        CHAR(4);
    DEFINE cUsuario         CHAR(8);
    DEFINE cDivisa          CHAR(2);
    DEFINE cTransacc        CHAR(4);
    DEFINE dtFechaCargo     DATE;
    DEFINE dDispo           DECIMAL(18,2);
    DEFINE dCargo           DECIMAL(18,2);
    DEFINE cCuenta          CHAR(20);
    DEFINE dMontoCgoInt		DECIMAL(16,2);
    DEFINE dCargoTotal     	DECIMAL(18,2);
    
    define vcod_ret         char(5);
    define cCuenta1         char(20);
    define vnum_cte         char(20);
    define vapell_pat       char(26);
    define vapell_mat       char(26);
    define vnombre1         char(26);
    define vnombre2         char(26);
    define vrazon_soc       char(60);
    define vedo_cta         char(1);
    define vsdo_disp        money(14,2);
    define vsdo_ret         money(14,2);
    define vsdo_ccc         money(14,2);
    define vsdo_disp_ccc    money(14,2);
    define vsdo_cta         money(14,2);
    define vtipo_linea      char(1);
    define vdescrip1        char(40);
    define vdescrip2        char(40);
    define vsdo_t1          money(14,2);
    define vsdo_cong        money(14,2);
    define vimp_chq_sbc     money(14,2);
    define vusubloq         char(8);
    define vfecbloq         date;
    define vnum_tarjeta     char(16);
    define vcta_clabe       char(18);
    define cTransaccion     integer;
    --DEFINE cProducto        CHAR(4);
    define cCtaOrd          char(20);
	--define cTpoPersona		CHAR(1);
	
	DEFINE cFolioOrigen		CHAR(30);
	DEFINE cClaveRastreo	CHAR(30);
	DEFINE dMontoInteres	DECIMAL(17,2);
	DEFINE cTranCargo		CHAR(4);
	DEFINE cTranCargoInt	CHAR(4);
	DEFINE dTsaPond			DECIMAL(9,6);
	DEFINE iMinutos			INTEGER;
    
    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    let cTransaccion = 0;
    
    LET cEmpresa        = '001';
    LET iSerialFolio   = 0;
    LET cNumTarjeta    = '';
    LET iMaxSec         = 0;
    LET cSucursal       = '9201';
    LET cUsuario        = 'tranSPEI';
    LET cDivisa         = '01';
    LET cTransacc       = '';  
    LET dtFechaCargo    = '';  
    LET dDispo          = 0.00; 
    LET dCargo          = 0.00; 
    LET cCuenta         = "";
    LET dMontoCgoInt = 0.00;
    LET dCargoTotal    = 0.00;
	
    let vcod_ret      = "000";
    let cCuenta1      = '';
    let vnum_cte      = '';
    let vapell_pat    = '';
    let vapell_mat    = '';
    let vnombre1      = '';
    let vnombre2      = '';
    let vrazon_soc    = '';
    let vedo_cta      = '';
    let vsdo_disp     = 0.00;
    let vsdo_ret      = 0.00;
    let vsdo_ccc      = 0.00;
    let vsdo_disp_ccc = 0.00;
    let vsdo_cta      = 0.00;
    let vtipo_linea   = '';
    let vdescrip1     = '';
    let vdescrip2     = '';
    let vsdo_t1       = 0.00;
    let vsdo_cong     = 0.00;
    let vimp_chq_sbc  = 0.00;
    let vusubloq      = '';
    let vfecbloq      = '';
    let vnum_tarjeta  = '';
    let vcta_clabe    = '';
    --let cProducto     = "";
	LET cCtaOrd       = '';
	--let cTpoPersona	  = "";
	
	LET cFolioOrigen	= "0";
	LET cClaveRastreo	= "";
	LET dMontoInteres	= 0;
	LET cTranCargo		= "";
	LET cTranCargoInt	= "";
	LET dTsaPond		= 0.0;
	LET iMinutos		= 0;
	

	--- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_env_extemporanea.out";
	--- TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_env_extemporanea.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            if cTransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
			LET cFolioOrigen = '0';
            RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET cTransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    IF cTransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF (pMonto IS NULL OR pMonto <= 0) OR (pClaveRastreo IS NULL OR pClaveRastreo = "") OR (pCuentaBeneficiario IS NULL OR pCuentaBeneficiario = "") OR (pCausaDev IS NULL OR pCausaDev = "") THEN
        LET cFolioOrigen = '0';
        IF cTransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF
		RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
    END IF;

    LET cFolioOrigen='SPEI1110';
    LET cClaveRastreo=pClaveRastreo;
	LET dMontoInteres=1.00;
 	
    RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
   
   END;
    
END PROCEDURE;