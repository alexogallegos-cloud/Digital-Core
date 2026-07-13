CREATE PROCEDURE "informix".spei_depuratblpago( pfecha_hoy DATE ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vContador3           INTEGER;
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    DEFINE vintfoliopago        INTEGER;
    DEFINE vintpkpago           INTEGER;
    DEFINE vintcvecausadev      INTEGER;
    DEFINE vintpkpaqueteenv     INTEGER;
    DEFINE vmnyimporte          DECIMAL(19,2);
    DEFINE vcvecesifbcoord      INTEGER;
    DEFINE vcvecesifbcodest     INTEGER;
    DEFINE vchrestatusenvio     CHAR(1);
    DEFINE vvchrnombreord       CHAR(40);
    DEFINE vvchrcuentaord       CHAR(20);
    DEFINE vvchrrfcord          CHAR(18);
    DEFINE vvchrnombrebenef     CHAR(40);
    DEFINE vintcvetipoctabene   INTEGER;
    DEFINE vvchrcuentabenef     CHAR(20);
    DEFINE vvchrrfcbenef        CHAR(18);
    DEFINE vvchrnombrebenef2    CHAR(40);
    DEFINE vintcvetipoctabene2  INTEGER;
    DEFINE vvchrcuentabenef2    CHAR(20);
    DEFINE vvchrrfcbenef2       CHAR(18);
    DEFINE vvchrconceptopago    CHAR(210);
    DEFINE vmnyiva              DECIMAL(19,2);
    DEFINE vintrefnumerica      DECIMAL(7,0);
    DEFINE vvchrrefcobranza     CHAR(40);
    DEFINE vvchrclavepago       CHAR(10);
    DEFINE vvchrconceptopago2   CHAR(40);
    DEFINE vdtfechavalor        DATE;
    DEFINE vdtfechacaptura      DATE;
    DEFINE vvchrclaverastreo    CHAR(30);
    DEFINE vchrusuarioprom      CHAR(20);
    DEFINE vchrfolioprom        CHAR(16);
    DEFINE vchrusuariovent      CHAR(20);
    DEFINE vchrfolioliqu        CHAR(16);
    DEFINE vintcvetipopago      INTEGER;
    DEFINE vintfolioservidor    INTEGER;
    DEFINE vintcvetipoctaord    INTEGER;
    DEFINE vdtmhoracargo        DATETIME YEAR TO SECOND;
    DEFINE vintcvetpooperacion  CHAR(2);
    DEFINE vintfoliocargo       INTEGER;
    DEFINE vintfoliocancela     INTEGER;
    DEFINE vintfolioservcanc    INTEGER;
    DEFINE vdtmhoracancela      DATETIME YEAR TO SECOND;
    DEFINE vchrsentidopago      CHAR(1);
    DEFINE vchrmotivocanc       CHAR(1);
    DEFINE vchrmotivodev        CHAR(1);
    DEFINE vchrtopologia        CHAR(1);
    DEFINE vchrprioridad        CHAR(1);
    DEFINE vtxtcde              REFERENCES BYTE;
    DEFINE vchrtxop             CHAR(4);
    DEFINE vvchrcverastreoorig  CHAR(30);
    DEFINE vchrctacheques       CHAR(11);
    DEFINE vvchrcverastreodev   CHAR(20);
    DEFINE vsintlongcverastreo  SMALLINT;
    DEFINE vintpkpagoorig       INTEGER;
    DEFINE vvchrmotivodev       CHAR(255);
    DEFINE vtransaccion         SMALLINT;
    DEFINE vchnumcelord         CHAR(10);
    DEFINE vchnumcelben         CHAR(20);
    DEFINE vchdigidord          SMALLINT;
    DEFINE vchdigidben          SMALLINT;
    DEFINE vchfechalimpago      CHAR(16);
    DEFINE vchindbenef          CHAR(2);
    DEFINE vintpagocomision     INTEGER;
    DEFINE vcomision            DECIMAL(14,2);
    DEFINE vchnumseriecert      CHAR(20);
    DEFINE vchfolioplataforma   CHAR(20);
	DEFINE vvchrfirma			CHAR(512);
    DEFINE iCommit              INTEGER;
	
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '';
    LET vCodRet3            = '';  
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vContador3          = 0;
    LET vComienza           = -1;
    LET vAbierto            = '0';
    LET vintfoliopago       = 0;
    LET vintpkpago          = 0;
    LET vintcvecausadev     = 0;
    LET vintpkpaqueteenv    = 0;
    LET vmnyimporte         = 0.00;
    LET vcvecesifbcoord     = 0;
    LET vcvecesifbcodest    = 0;
    LET vchrestatusenvio    = '';
    LET vvchrnombreord      = '';
    LET vvchrcuentaord      = '';
    LET vvchrrfcord         = '';
    LET vvchrnombrebenef    = '';
    LET vintcvetipoctabene  = 0;
    LET vvchrcuentabenef    = '';
    LET vvchrrfcbenef       = '';
    LET vvchrnombrebenef2   = '';
    LET vintcvetipoctabene2 = 0;
    LET vvchrcuentabenef2   = '';
    LET vvchrrfcbenef2      = '';
    LET vvchrconceptopago   = '';
    LET vmnyiva             = 0.00;
    LET vintrefnumerica     = 0.00;
    LET vvchrrefcobranza    = '';
    LET vvchrclavepago      = '';
    LET vvchrconceptopago2  = '';
    LET vdtfechavalor       = '';
    LET vdtfechacaptura     = '';
    LET vvchrclaverastreo   = '';
    LET vchrusuarioprom     = '';
    LET vchrfolioprom       = '';
    LET vchrusuariovent     = '';
    LET vchrfolioliqu       = '';
    LET vintcvetipopago     = 0;
    LET vintfolioservidor   = 0;
    LET vintcvetipoctaord   = 0;
    LET vdtmhoracargo       = '';
    LET vintcvetpooperacion = '';
    LET vintfoliocargo      = 0;
    LET vintfoliocancela    = 0;
    LET vintfolioservcanc   = 0;
    LET vdtmhoracancela     = '';
    LET vchrsentidopago     = '';
    LET vchrmotivocanc      = '';
    LET vchrmotivodev       = '';
    LET vchrtopologia       = '';
    LET vchrprioridad       = '';
    LET vchrtxop            = '';
    LET vvchrcverastreoorig = '';
    LET vchrctacheques      = '';
    LET vvchrcverastreodev  = '';
    LET vsintlongcverastreo = 0;
    LET vintpkpagoorig      = 0;
    LET vvchrmotivodev      = '';
    LET vtransaccion        = 0;
	LET vvchrfirma          = '';
    LET iCommit             = 10;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratblpago.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei_depuratblpago.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tblpago idx_fv)}
               intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
               vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
               intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
               vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
               intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
               intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
               txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev, 
               numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma,vchrfirma
          INTO vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
               vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
               vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
               vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
               vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
               vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
               vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev, 
               vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma,
               vvchrfirma
          FROM tblpago 
         WHERE dtfechavalor <= pfecha_hoy
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
        INSERT INTO tblhistpago
        ( intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
          vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
          intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
          vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
          intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
          intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
          txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev, 
          numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma,vchrfirma )
        VALUES
        ( vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
          vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
          vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
          vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
          vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
          vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
          vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev, 
          vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma,vvchrfirma );
          
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            DELETE FROM tblpago
             WHERE dtfechavalor <= pfecha_hoy 
               AND vchrclaverastreo = vvchrclaverastreo;
               
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                LET vcontador3 = vcontador3 + 1;
            END IF;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= iCommit THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vvchrclaverastreo = '';
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;