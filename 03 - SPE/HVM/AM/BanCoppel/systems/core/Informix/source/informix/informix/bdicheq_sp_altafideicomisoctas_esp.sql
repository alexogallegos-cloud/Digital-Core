CREATE PROCEDURE "informix".sp_altafideicomisoctas_esp( pEmpresa CHAR(3), pNumCte CHAR(20) ) 
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(18);
    
    DEFINE intSqlErr    INTEGER;
    DEFINE intIsamErr   INTEGER;
    DEFINE chrDescErr   CHAR(80);
    DEFINE chrCodRet1   CHAR(5);
    DEFINE chrCodRet2   CHAR(5);
    DEFINE chrCodRet3   CHAR(80);
    
    DEFINE vlongcta     SMALLINT;
    DEFINE vsignumcta   INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE vDiferencia  SMALLINT;
    DEFINE i            SMALLINT;
    DEFINE vdigverif    CHAR(1);
    DEFINE vexiste      CHAR(1);
    DEFINE vctaclabe    CHAR(18);

    LET intSqlErr  = 0;
    LET intIsamErr = 0;
    LET chrDescErr = '';
    LET chrCodRet1 = '000';
    LET chrCodRet2 = '';
    LET chrCodRet3 = '';
    
    LET vlongcta    = 0;
    LET vsignumcta  = 0;
    LET cCuenta     = '';
    LET vDiferencia = 0;
    LET i           = 0;
    LET vdigverif   = '';
    LET vexiste     = '';
    LET vctaclabe   = '';

    BEGIN
    
    ON EXCEPTION SET intSqlErr, intIsamErr, chrDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altafideicomisoctas_esp.err";
        TRACE ON;
        IF intSqlErr <> 0 THEN
            LET chrCodRet1 = intSqlErr;
            LET chrCodRet2 = intIsamErr;
            LET chrCodRet3 = chrDescErr;
            RETURN chrCodRet1, pNumCte, cCuenta, vctaclabe;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altafideicomisoctas_esp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ALTA DE LA CUENTA
    SELECT valor 
      INTO vlongcta
	  FROM bdicheq:sc_param
	 WHERE empresa = pEmpresa 
       AND codparam = "longcta";
    
    SELECT valor
      INTO vsignumcta
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'signumcta2';
       
    LET cCuenta = vsignumcta;
    LET vsignumcta = vsignumcta + 1;
    
    UPDATE bdicheq:sc_param
       SET valor = vsignumcta
     WHERE empresa = pEmpresa
       AND codparam = 'signumcta2';
       
    LET vDiferencia = vlongcta - LENGTH(cCuenta) - 3;
    
    IF vDiferencia > 0 THEN
        FOR i = 1 TO vDiferencia
            LET cCuenta = "0"||cCuenta; 
        END FOR;
    END IF;
    
    LET cCuenta = "12"||TRIM(cCuenta);
    
    CALL bdicheq:digver11(cCuenta)
    RETURNING chrCodRet1, vdigverif;
    
    LET cCuenta = TRIM(cCuenta)||vdigverif;
    
    IF length(cCuenta) = vlongcta AND bdinteg:val_num(cCuenta) THEN
        SELECT 1 
          INTO vexiste
		  FROM bdicheq:sc_maechq 
         WHERE empresa = pEmpresa 
           AND cuenta = cCuenta;
           
        IF vexiste IS NOT NULL THEN
            LET chrCodRet1 = "405";
            RETURN chrCodRet1, pNumCte, cCuenta, vctaclabe;
        END IF;
        
        CALL bdicheq:ctaclabe(pEmpresa, cCuenta, '0002')
        RETURNING chrCodRet1, vctaclabe;
        
        IF chrCodRet1 <> "000" THEN
            LET chrCodRet1 = "170";
            RETURN chrCodRet1, pNumCte, cCuenta, vctaclabe;
        END IF;
        
        insert into bdicheq:sc_maechq values(
            pEmpresa,               --- empresa
            cCuenta,                --- cuenta              
            '0002',                 --- sucursal            
            '001',                  --- plaza               
            '1200',                 --- producto            
            pNumCte,                --- num_cte             
            '1',                    --- status_cta          
            '',                     --- motivo
            0,                      --- ult_chq             
            'N',                    --- colateral           
            '',                     --- fec_ult_mov         
            '',                     --- fec_cancelac
            0.00,                   --- lim_chq_sbc   
            0.00,                   --- imp_chq_sbc     
            '',                     --- fech_alta_sbc
            '',                     --- fech_venc_sbc
            0.00,                   --- lim_chq_rem     
            0.00,                   --- imp_chq_rem
            '',                     --- fech_alta_rem
            '',                     --- fech_venc_rem
            0.00,                   --- lim_sbg_ccc      
            0.00,                   --- imp_sbg_ccc     
            '0',                    --- tipo_linea          
            '',                     --- fec_alta_ccc
            '',                     --- fech_venc_ccc
            0.00,                   --- imp_int_ccc       
            0.00,                   --- sdo_retenido     
            0,                      --- chq_exp_mes         
            0,                      --- chq_dev             
            0.00,                   --- monto_dev         
            0,                      --- chq_dev_obco        
            0.00,                   --- sdo_cong         
            0,                      --- num_cgos_mes        
            0.00,                   --- imp_cgos_mes     
            0,                      --- num_abonos_mes      
            0.00,                   --- imp_abonos_mes  
            0.00,                   --- sdo_actual       
            0.00,                   --- sdo_dia_ant      
            '1',                    --- marca_ret           
            1,                      --- direcc_envio        
            0.00,                   --- com_pendiente      
            0.00,                   --- imp_chq_sbg       
            0.00,                   --- imp_int_sbg       
            ' ',                    --- fecha_proceso       
            '',                     --- cuenta_rel
            0.00,                   --- saldo_sbc         
            '',                     --- fecultdep
            '',                     --- fecultret
            '',                     --- ultpagocap          
            '',                     --- ultpagoint          
            0,                      --- plazo               
            'S',                    --- cobraisr            
            '',                     --- proced_aperturacta  
            '',                     --- proced_mantenercta  
            '',                     --- monto_mensual       
            '',                     --- depositos_cantidad  
            '',                     --- depositos_monto     
            '',                     --- retiros_cantidad    
            '',                     --- retiros_monto       
            vctaclabe               --- cuenta_clabe        
        );
        
        insert into bdicheq:sc_maenoc values(
            pEmpresa,           --- empresa           
            cCuenta,            --- cuenta       
            '00',               --- num_cot           
            '1',                --- clase_cta         
            '1',                --- reg_firmas        
            '001',              --- tipo_bca          
            'informix',         --- ejecutivo         
            '0',                --- envio_direcc      
            0.000000,           --- porc_sdoprom_sbc  
            0.000000,           --- porc_sdoprom_rem  
            '',                 --- tasa_int_ccc
            0.000000,           --- sobretasa_ccc     
            '',                 --- cta_en_legal
            '',                 --- fec_tras_legal
            0,                  --- dias_ccc          
            0.00,               --- acum_ccc       
            0,                  --- dia_sdo_pos       
            0.00,               --- acum_sdo_pos    
            0.00,               --- sdo_prom_mesant 
            0.00,               --- acum_sbc       
            0.00,               --- acum_rem       
            0.00,               --- sdo_mes_ant    
            '',                 --- adicionado        
            today,              --- fecha_alta        
            '',                 --- modificado
            '',                 --- fecha_mod
            0.00,               --- int_acum       
            0.00,               --- isr_acum       
            'M',                --- capitalizacion    
            '',                 --- paga_interes
            0.00,               --- ret_mes_ant     
            0.00,               --- cong_mes_ant    
            0,                  --- dias_acum_int     
            0.00                --- acum_sdo_int  
        );
    END IF;    
        
    RETURN chrCodRet1, pNumCte, cCuenta, vctaclabe;
    
    END;
    
END PROCEDURE;