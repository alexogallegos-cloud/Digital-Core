CREATE PROCEDURE "informix".spei_entordenespago_oxo()

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
          CHAR(4);       -- sucursal de la cuenta

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
    DEFINE wcvecesifbcodest         CHAR(5);
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
    DEFINE wintrefnumerica          CHAR(7); 
    DEFINE wvchrrefcobranza         CHAR(40);
    DEFINE wvchrclavepago           CHAR(10);
    DEFINE wvchrconceptopago2       CHAR(40);
    DEFINE wvchrcuentabenef2_2      CHAR(20);
    DEFINE wchrprioridad            CHAR(1);
    DEFINE wchrtopologia            CHAR(1);
    DEFINE wintcvetpooperacion      CHAR(2);
    DEFINE wchrsuccuenta            CHAR(4);

    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
 
    LET wempresa            = '001'; 
    LET wvchrclaverastreo   = ''; 
    LET wintcvetipopago     = '00'; 
    LET wdtfechavalor       = ''; 
    LET wmnyimporte         = 0.00;
    LET wcvecesifbcodest    = '00000'; 
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
    LET wintrefnumerica     = 0.00;
    LET wvchrrefcobranza    = '';
    LET wvchrclavepago      = '';
    LET wvchrconceptopago2  = '';
    LET wvchrcuentabenef2_2 = '';
    LET wchrprioridad       = '';
    LET wchrtopologia       = '';
    LET wintcvetpooperacion = '';
    LET wchrsuccuenta       = '';

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei_entordenespago.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr

        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_entordenespago.out";
		TRACE ON;
      
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN wvchrclaverastreo, wintcvetipopago, wdtfechavalor, wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, 
                   wvchrnombreord, wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, wintcvetipoctabene, 
                   wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, wintcvetipoctabene2, wvchrrfcbenef2, 
                   wvchrconceptopago2, wmnyiva, wintrefnumerica, wvchrrefcobranza, wvchrclavepago,
                   wvchrconceptopago, wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion, wchrsuccuenta; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
  
    FOREACH
        SELECT FIRST 10
               NVL(vchrclaverastreo,' '), NVL(LPAD(intcvetipopago,2,0),0), NVL(dtfechavalor,' '), 
               NVL(mnyimporte,0.00), NVL(LPAD(cvecesifbcodest,5,0),0), NVL(LPAD(cvecesifbcoord,5,0),0), NVL(vchrnombreord,' '), 
               NVL(LPAD(intcvetipoctaord,2,0),0), NVL(vchrcuentaord,' '), NVL(vchrrfcord,' '), NVL(vchrnombrebenef,' '), 
               NVL(LPAD(intcvetipoctabene,2,0),0), NVL(vchrcuentabenef,' '), NVL(vchrrfcbenef,' '), NVL(vchrnombrebenef2,''), 
               NVL(LPAD(intcvetipoctabene2,2,0),0), NVL(vchrrfcbenef2,' '), NVL(vchrconceptopago2,' '), NVL(mnyiva,0.00), 
               NVL(LPAD(intrefnumerica,7,0),0), NVL(vchrrefcobranza,' '), NVL(vchrclavepago,' '), NVL(vchrconceptopago,' '), 
               NVL(vchrcuentabenef2,' '), NVL(chrprioridad,' '), NVL(chrtopologia,' '), NVL(LPAD(intcvetpooperacion,2,0),0)
          INTO wvchrclaverastreo, wintcvetipopago, wdtfechavalor, 
               wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, wvchrnombreord, 
               wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, 
               wintcvetipoctabene, wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, 
               wintcvetipoctabene2, wvchrrfcbenef2, wvchrconceptopago2, wmnyiva, 
               wintrefnumerica, wvchrrefcobranza, wvchrclavepago, wvchrconceptopago, 
               wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion
          FROM bdispei:"informix".tblpago
         WHERE chrestatusenvio = 'N'
           AND mnyimporte > 0.00
        
        LET wdtfechavalor2 = to_char(wdtfechavalor, '%Y%m%d');        
        LET wchrsuccuenta = '0000';
         
        UPDATE bdispei:tblpago
           SET chrestatusenvio = 'E'
         WHERE vchrclaverastreo = wvchrclaverastreo;
       
        RETURN wvchrclaverastreo, wintcvetipopago, wdtfechavalor2, wmnyimporte, wcvecesifbcodest, wcvecesifbcoord, 
               wvchrnombreord, wintcvetipoctaord, wvchrcuentaord, wvchrrfcord, wvchrnombrebenef, wintcvetipoctabene, 
               wvchrcuentabenef, wvchrrfcbenef, wvchrnombrebenef2, wintcvetipoctabene2, wvchrrfcbenef2, 
               wvchrconceptopago2, wmnyiva, wintrefnumerica, wvchrrefcobranza, wvchrclavepago,
               wvchrconceptopago, wvchrcuentabenef2_2, wchrprioridad, wchrtopologia, wintcvetpooperacion, wchrsuccuenta 
        WITH RESUME;
    END FOREACH;
  
    END;

END PROCEDURE;