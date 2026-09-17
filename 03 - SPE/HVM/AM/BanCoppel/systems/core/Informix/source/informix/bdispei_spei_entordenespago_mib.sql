CREATE PROCEDURE "informix".spei_entordenespago_mib()
RETURNING CHAR(30),      -- clave de rastreo
          CHAR(2),       -- tipo de pago
          CHAR(8),       -- fecha de pago
          DECIMAL(17,2), -- importe de la operación
          CHAR(5),       -- clave de la institución destino
          CHAR(5),       -- clave de la institucion origen
          CHAR(40),      -- nombre del ordenante
          CHAR(2),       -- tipo de cuenta del ordenante
          CHAR(20),      -- numero de cuenta del ordenante
          CHAR(18),      -- rfc o curp del ordenante
          CHAR(40),      -- nombre del beneficiario
          CHAR(2),       -- tipo de cuenta del beneficiario
          CHAR(20),      -- numero de cuenta del ordenante
          CHAR(18),      -- rfc o curp del beneficiario
          CHAR(40),      -- nombre del segundo beneficiario
          CHAR(2),       -- tipo de cuenta del segundo beneficiario
          CHAR(18),      -- rfc o curp del segundo beneficiario
          CHAR(210),     -- concepto de pago
          DECIMAL(17,2), -- iva
          CHAR(7),       -- referencia numérica
          CHAR(40),      -- referencia cobranza
          CHAR(10),      -- referencia del pago en ventanilla
          CHAR(40),      -- concepto de pago
          CHAR(20),      -- numero de cuenta del segundo beneficiario
          CHAR(1),       -- prioridad normal o alta
          CHAR(1),       -- topología
          CHAR(2),       -- tipo de operación
          CHAR(4),       -- sucursal de la cuenta
		  CHAR(512),     -- firma validar
		  CHAR(10),      -- num cel ordenante
	      CHAR (20),     -- num cel beneficiario 
	      CHAR(3),       -- digito verificador ordenante
          CHAR(3),       -- digito verificador beneficiario 
	      CHAR(16),      --fechalimite de pago
	      CHAR(3),       -- indicador beneficiario
	      CHAR(1),       -- pago comision
	      DECIMAL(12,2), -- comision
	      CHAR(20),      -- numero de serie de certificado    
	      CHAR(20),      -- folio plataforma
          DECIMAL(12,2); -- monto original de la operacion		  

    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
 
    DEFINE wempresa                 CHAR(3);
    DEFINE wvchrclaverastreo        CHAR(30);
    DEFINE wintcvetipopago          CHAR(2);
    DEFINE wdtfechavalor            DATE;
    DEFINE wdtfechavalor2           CHAR(8);
    DEFINE wmnyimporte              DECIMAL(17,2);
    DEFINE wcvecesifbcodest         INTEGER;
    DEFINE wcvecesifbcoord          CHAR(5);
    DEFINE wvchrnombreord           CHAR(40);
    DEFINE wintcvetipoctaord        CHAR(2);
    DEFINE wvchrcuentaord           CHAR(20);
    DEFINE wvchrrfcord              CHAR(18);
    DEFINE wvchrnombrebenef         CHAR(40);
    DEFINE wintcvetipoctabene       CHAR(2);
    DEFINE wvchrcuentabenef         CHAR(20);
    DEFINE wvchrrfcbenef            CHAR(18);
    DEFINE wvchrnombrebenef2        CHAR(40);
    DEFINE wintcvetipoctabene2      CHAR(2);
    DEFINE wvchrrfcbenef2           CHAR(18);
    DEFINE wvchrconceptopago        CHAR(210);
    DEFINE wmnyiva                  DECIMAL(17,2);
    DEFINE wintrefnumerica          INTEGER; 
    DEFINE wvchrrefcobranza         CHAR(40);
    DEFINE wvchrclavepago           CHAR(10);
    DEFINE wvchrconceptopago2       CHAR(40);
    DEFINE wvchrcuentabenef2_2      CHAR(20);
    DEFINE wchrprioridad            CHAR(1);
    DEFINE wchrtopologia            CHAR(1);
    DEFINE wintcvetpooperacion      CHAR(2);
    DEFINE wchrsuccuenta            CHAR(4);
	DEFINE wmedioent                CHAR(3);
	--FIRMA
	DEFINE ret						INTEGER;
	DEFINE wvchrfirma 			    CHAR(512);
	DEFINE wchrcadena_00			CHAR(3000);
	DEFINE wchrcadena_01			CHAR(200);
	DEFINE wchrcadena_02			CHAR(200);
	DEFINE wchrcadena_03			CHAR(200);
	DEFINE wchrcadena_04			CHAR(200);
	DEFINE wvchrnombre				CHAR(30);
	DEFINE wchrusuarioprom			CHAR(8);

	DEFINE iCuantos					INTEGER;
	DEFINE iCuantosPP				INTEGER;
	DEFINE iMovsSucs				INTEGER;
	DEFINE iMovsPagsProgs			INTEGER;	
	
	-- // CODI	
	DEFINE wnumcelord       CHAR(10);
	DEFINE wnumcelben       CHAR (20);
	DEFINE wdigidord        CHAR(3);
    DEFINE wdigidben        CHAR(3);
	DEFINE wfechalimpago    CHAR(16);
	DEFINE windbenef        CHAR(2);
	DEFINE wpagocomision    CHAR(1);
	DEFINE wcomision        DECIMAL(12,2);
	DEFINE wnumseriecert    CHAR(20);
	DEFINE wfolioplataforma CHAR(20);
    DEFINE wmontooriginal	DECIMAL(12,2);
    
    DEFINE vtransaccion SMALLINT;
    DEFINE iTransacc SMALLINT;
	

    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
 
    LET wempresa            = '001'; 
    LET wvchrclaverastreo   = ''; 
    LET wintcvetipopago     = '00'; 
    LET wdtfechavalor       = ''; 
    LET wmnyimporte         = 0.00;
    LET wcvecesifbcodest    = 0; 
    LET wcvecesifbcoord     = '00000'; 
    LET wvchrnombreord      = '';
    LET wintcvetipoctaord   = '00'; 
    LET wvchrcuentaord      = '';
    LET wvchrrfcord         = '';
    LET wvchrnombrebenef    = '';
    LET wintcvetipoctabene  = '00'; 
    LET wvchrcuentabenef    = '';
    LET wvchrrfcbenef       = '';
    LET wvchrnombrebenef2   = '';
    LET wintcvetipoctabene2 = '00'; 
    LET wvchrrfcbenef2      = '';
    LET wvchrconceptopago   = '';
    LET wmnyiva             = 0.00;
    LET wintrefnumerica     = 0;
    LET wvchrrefcobranza    = '';
    LET wvchrclavepago      = '';
    LET wvchrconceptopago2  = '';
    LET wvchrcuentabenef2_2 = '';
    LET wchrprioridad       = '';
    LET wchrtopologia       = '';
    LET wintcvetpooperacion = '';
    LET wchrsuccuenta       = '';
	--FIRMA
	LET wvchrfirma          = '';
	LET ret					= 0;
	LET wchrcadena_00		= '';
	LET wchrcadena_01		= '';
	LET wchrcadena_02		= '';
	LET wchrcadena_03		= '';
	LET wchrcadena_04		= '';
	LET wvchrnombre 		= '';
	LET wchrusuarioprom		= '';

    LET iCuantos            = 0;
	LET iCuantosPP          = 0;
	LET iMovsSucs           = 0;
	LET iMovsPagsProgs      = 0;
	
    LET wnumcelord          = '';
    LET wnumcelben          = '';
    LET wdigidord           = '';
    LET wdigidben           = '';
    LET wfechalimpago       = '';
    LET windbenef           = '';
    LET wpagocomision       = '';
    LET wcomision           = 0;
    LET wnumseriecert       = '';
    LET wfolioplataforma    = '';
    LET wmontooriginal      = 0;
	    
    LET vtransaccion = 0;
    LET iTransacc = 0;
	
    SET DEBUG FILE TO '/RESPALDOSNEW/mbucio/Vobos/30102020/spei_entordenespago.out';
    TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_entordenespago.err";
		TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN wvchrclaverastreo, wintcvetipopago, wdtfechavalor, wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, 
                   wvchrnombreord, wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, wintcvetipoctabene, 
                   wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, wintcvetipoctabene2, wvchrrfcbenef2, 
                   wvchrconceptopago2, wmnyiva, wintrefnumerica, wvchrrefcobranza, wvchrclavepago,
                   wvchrconceptopago, wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion, wchrsuccuenta, wvchrfirma,
				   wnumcelord , wnumcelben, wdigidord, wdigidben, wfechalimpago, windbenef, wpagocomision, wcomision, wnumseriecert, wfolioplataforma,wmontooriginal; 
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

    SET ISOLATION TO COMMITTED READ;
    SET LOCK MODE TO WAIT 10;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
	SELECT COUNT(*)
	  INTO iCuantos
	  FROM tblpago
	 WHERE chrestatusenvio = 'N';

    IF iCuantos > 0 THEN
        SELECT FIRST 1
               NVL(vchrclaverastreo,' '), NVL(LPAD(intcvetipopago,2,0),0), NVL(dtfechavalor,' '), 
               NVL(mnyimporte,0.00), NVL(LPAD(cvecesifbcodest,5,0),0), NVL(LPAD(cvecesifbcoord,5,0),0), NVL(vchrnombreord,' '), 
               NVL(intcvetipoctaord,''), NVL(vchrcuentaord,' '), NVL(vchrrfcord,' '), NVL(vchrnombrebenef,' '), 
               NVL(intcvetipoctabene,''), NVL(vchrcuentabenef,' '), NVL(vchrrfcbenef,' '), NVL(vchrnombrebenef2,''), 
               NVL(LPAD(intcvetipoctabene2,2,0),0), NVL(vchrrfcbenef2,' '), NVL(vchrconceptopago2,' '), NVL(mnyiva,0.00), 
               NVL(intrefnumerica,0), NVL(vchrrefcobranza,' '), NVL(vchrclavepago,' '), NVL(vchrconceptopago,' '), 
               NVL(vchrcuentabenef2,' '), NVL(chrprioridad,' '), NVL(chrtopologia,' '), NVL(LPAD(intcvetpooperacion,2,0),0),
			   NVL(chrusuarioprom, ' '), NVL(vchrfirma,' '), 
			   NVL(numcelord, ' '), NVL(numcelben, ' '), NVL(digidord, '0'), NVL(digidben, '0'), NVL(fechalimpago, ' '), NVL(indbenef, ' '), NVL(pagocomision, ' '), NVL(comision, 0), NVL(numseriecert, ' '), NVL(folioplataforma, ' '),
               NVL(comision,0)
          INTO wvchrclaverastreo, wintcvetipopago, wdtfechavalor, 
               wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, wvchrnombreord, 
               wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, 
               wintcvetipoctabene, wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, 
               wintcvetipoctabene2, wvchrrfcbenef2, wvchrconceptopago2, wmnyiva, 
               wintrefnumerica, wvchrrefcobranza, wvchrclavepago, wvchrconceptopago, 
               wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion,
			   wchrusuarioprom, wvchrfirma, 
			   wnumcelord, wnumcelben, wdigidord, wdigidben, wfechalimpago, windbenef, wpagocomision, wcomision, wnumseriecert, wfolioplataforma,wmontooriginal
          FROM bdispei:"informix".tblpago
         WHERE chrestatusenvio = 'N';
         
		--//Validar si el tipo de pago no es una devolucion para enviar el monto original en cero   
        IF wintcvetipopago NOT IN ('17','18') THEN
            LET wmontooriginal = 0;
        END IF;
		   
        LET wdtfechavalor2 = to_char(wdtfechavalor, '%Y%m%d');        
        LET wchrsuccuenta = '0000';

        LET wvchrfirma = TRIM(wvchrfirma);		
   
		UPDATE bdispei:tblpago
           SET chrestatusenvio = 'E'
         WHERE vchrclaverastreo = wvchrclaverastreo
		   AND chrestatusenvio = 'N';
		   
		IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
			IF vtransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
			RETURN wvchrclaverastreo, wintcvetipopago, wdtfechavalor2, wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, 
               wvchrnombreord, wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, wintcvetipoctabene, 
               wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, wintcvetipoctabene2, wvchrrfcbenef2, 
               wvchrconceptopago2, wmnyiva, wintrefnumerica, wvchrrefcobranza, wvchrclavepago,
               wvchrconceptopago, wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion, wchrsuccuenta, 
               wvchrfirma, wnumcelord, wnumcelben, wdigidord, wdigidben, wfechalimpago, windbenef, wpagocomision, wcomision, wnumseriecert, 
			   wfolioplataforma,wmontooriginal;
			
        END IF;

	END IF;
   
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
  
    END;

END PROCEDURE;