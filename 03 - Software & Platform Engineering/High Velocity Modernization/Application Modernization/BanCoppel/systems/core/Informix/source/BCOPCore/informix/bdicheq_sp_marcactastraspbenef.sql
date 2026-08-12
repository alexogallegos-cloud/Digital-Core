CREATE PROCEDURE "informix".sp_marcactastraspbenef( pEmpresa char(3) )
RETURNING CHAR(5), INTEGER, INTEGER;      
	
    DEFINE vSqlErr          	INTEGER;
    DEFINE vIsamErr         	INTEGER;
    DEFINE vDescErr         	CHAR(50);
    DEFINE vCodRet1         	CHAR(5);
    DEFINE vCodRet2         	CHAR(5);
    DEFINE vCodRet3         	CHAR(50);    
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vTrxAbierta          SMALLINT;
    DEFINE vsql                 CHAR(300);
    DEFINE vstmt                CHAR(200);
    DEFINE vCuenta              CHAR(20);
    DEFINE vSdoConcentrado      DECIMAL(18,2);
    
	LET vSqlErr	     	= 0;
    LET vIsamErr     	= 0;
    LET vDescErr     	= '';
    LET vCodRet1     	= '000';
    LET vCodRet2     	= '000';
    LET vCodRet3     	= '';    
    LET vContador1      = 0;
    LET vContador2      = 0;
    LET vTrxAbierta     = 0;
    LET vsql            = '';
    LET vstmt           = '';
    LET vCuenta         = '';
    LET vSdoConcentrado = '';
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactastraspbenef.err";
        TRACE ON;
        IF vSqlErr <> 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            LET vCodRet3 = vDescErr;	
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactastraspbenef.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_ctastraspbenef') THEN
        DROP TABLE "informix".sc_ctastraspbenef;
    END IF;
    
    CREATE TABLE "informix".sc_ctastraspbenef
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctatraspbenef ON "informix".sc_ctastraspbenef(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_transferidas.unl INSERT INTO sc_ctastraspbenef" > /resplogifx/conciliachq/ctasbenef.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasbenef.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_ctastraspbenef;
    
    FOREACH WITH HOLD
        SELECT trasp.cuenta, conc.sdo_concentrado
          INTO vCuenta, vSdoConcentrado
          FROM sc_ctastraspbenef trasp,
               sc_cuentas_concentradas conc
         WHERE trasp.cuenta = conc.cuenta
           
        BEGIN WORK;
        LET vTrxAbierta = 1;
        
        UPDATE sc_maechq
           SET status_cta = '2', motivo = '14', fec_cancelac = TODAY
         WHERE cuenta = vCuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            UPDATE sc_cuentas_concentradas
               SET int_trasp_beneficiencia = 0.00,
                   sdo_trasp_beneficiencia = vSdoConcentrado,
                   fecha_trasp_benefic = '01/16/2014'
             WHERE cuenta = vCuenta;
             
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                LET vContador2 = vContador2 + 1;
                COMMIT WORK;
                LET vTrxAbierta = 0;
            ELSE
                ROLLBACK WORK;
                LET vTrxAbierta = 0;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = 0;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
    END FOREACH;
    
    END;
    
    RETURN vCodRet1, vContador1, vContador2;
    
END PROCEDURE;