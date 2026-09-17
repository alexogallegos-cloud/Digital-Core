CREATE PROCEDURE "informix".sp_liberaretspei_spei_esp( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaAnt        DATE;
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasRet         SMALLINT;   
    DEFINE vCuenta          CHAR(20);
    DEFINE vMontoRet        MONEY(14,2);
    DEFINE vFechaTrx        DATE;
    DEFINE vSdoRetenido     MONEY(14,2);
    DEFINE vSucursal        CHAR(4);
    DEFINE vImpSbg          MONEY(14,2);
    DEFINE cFolioDep        CHAR(16);
    DEFINE cReferencia      CHAR(40);
    DEFINE vCobraCom        SMALLINT;
    DEFINE vComPend         SMALLINT;
    DEFINE vHora            CHAR(15);
    DEFINE vFolioSuc        CHAR(16);
    DEFINE vCodRet4         CHAR(5);
    DEFINE vCodRet5         CHAR(5);
    DEFINE vSigDiaHabil     DATE;
	
    LET Sql_Err	      = 0;
    LET Isam_Err      = 0;
    LET Desc_Err      = '';
    LET vCodRet1      = '';
    LET vCodRet2      = '';
    LET vCodRet3      = '';  
    LET vContador1    = 0;
    LET vContador2    = 0;
    LET vAbierto      = '0';
    LET vFechaAnt     = '';
    LET vFechaHoy     = '';
    LET vDiasRet      = 0;
    LET vCuenta       = '';
    LET vMontoRet     = 0.00;
    LET vFechaTrx     = '';
    LET vSdoRetenido  = 0.00;
    LET vSucursal     = '';
    LET vImpSbg       = 0.00;
    LET cFolioDep     = '';
    LET cReferencia   = '';
    LET vComPend      = 0;
    LET vCobraCom     = 0;
    LET vHora         = '';
    LET vFolioSuc     = '';   
    LET vCodRet4      = '';
    LET vCodRet5      = '';
    LET vSigDiaHabil  = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei_esp.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES 
    SELECT fecha_ant, fecha_hoy
      INTO vFechaAnt, vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	LET vSigDiaHabil = '11032020';
	LET vFechaHoy = '10302020';
     
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS POR TRANSACCIONES SPEI
    FOREACH WITH HOLD
        SELECT dep.cuenta, dep.monto_ret, dep.fecha_hoy, dep.folio_suc, dep.referencia,
               mae.sdo_retenido, mae.sucursal, (mae.imp_chq_sbg + mae.imp_sbg_ccc)
          INTO vCuenta, vMontoRet, vFechaTrx, cFolioDep, cReferencia, 
               vSdoRetenido, vSucursal, vImpSbg
          FROM sc_depositospei dep,
               sc_maechq mae
         WHERE dep.fecha_hoy = vFechaHoy
           AND dep.cuenta = mae.cuenta
           AND dep.monto_ret > 0
           AND dep.liberado = '0'
				
        
        BEGIN WORK;
        LET vAbierto = '1';
        
        -- // VALIDA EL DIA DE LIBERACION
        --CALL bdispei:sp_validafecha(pEmpresa, vFechaTrx)
        --RETURNING vCodRet5, vSigDiaHabil;
        
        IF vFechaHoy = vFechaHoy THEN
            IF vSdoRetenido >= vMontoRet THEN
                UPDATE sc_maechq
                   SET sdo_retenido = sdo_retenido - vMontoRet
                 WHERE cuenta = vCuenta;
                    
                UPDATE sc_depositospei
                   SET liberado = '1'
                 WHERE fecha_hoy = vFechaHoy
                   AND cuenta = vCuenta
                   AND monto_ret = vMontoRet
                   AND liberado = '0'
                   AND folio_suc = cFolioDep
                   AND referencia = cReferencia;
                   
                LET vcontador2 = vcontador2 + 1;
                   
                IF vImpSbg > 0 THEN
                    LET vCobraCom = 1;
                END IF;
                   
                IF vCobraCom = 0 THEN
                    SELECT COUNT(*)
                      INTO vComPend
                      FROM sc_detcomis
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCuenta 
                       AND estado_com = "P";
                             
                    IF vComPend > 0 THEN
                        LET vCobraCom = 1;
                    END IF;
                END IF;
                   
                IF vCobraCom = 1 THEN
                    LET vHora = CURRENT HOUR TO FRACTION;
                    LET vFolioSuc = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
                    
                    CALL cobintcomsbg(pEmpresa, vCuenta, vFolioSuc, 'informix', vSucursal)
                    RETURNING vCodRet4;
                END IF;
            END IF; 
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET vAbierto = '0';
        
        LET vCuenta       = '';
        LET vMontoRet     = 0;
        LET vFechaTrx     = '';
        LET vSdoRetenido  = 0;
        LET vSucursal     = '';
        LET vImpSbg       = 0.00;
        LET cFolioDep     = '';
        LET vCobraCom     = 0;
        LET vComPend      = 0;
        LET vHora         = '';
        LET vFolioSuc     = '';
        LET vCodRet4      = '';
    END FOREACH;
         
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vCuenta
          FROM sc_depositospei
         WHERE fecha_hoy = vFechaHoy 
           AND liberado = '1'
		   
             
        BEGIN WORK;
        LET vAbierto = '1';
             
        INSERT INTO sc_depositospeihist
        SELECT *
          FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy = vFechaHoy
           AND liberado = '1';
             
        DELETE FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy = vFechaHoy
           AND liberado = '1';
             
        COMMIT WORK;
        LET vAbierto = '0';
        
        LET vCuenta = '';
    END FOREACH;
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
	    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;