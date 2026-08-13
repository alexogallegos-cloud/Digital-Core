CREATE PROCEDURE "informix".sp_calcsdoctainactiva( pEmpresa char(3), pCuenta char(20) )
RETURNING CHAR(5), DECIMAL(18,2);
     
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    
    DEFINE vFechaHoy            DATE;
    DEFINE vPorRetSuj           DECIMAL(9,6);
    DEFINE vSMDF                DECIMAL(14,2);
    DEFINE vNumSMDF             SMALLINT;
    DEFINE vBaseExenta          DECIMAL(18,2);
    DEFINE vCuenta              CHAR(20);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vSaldoConcentrado    DECIMAL(18,2);
    DEFINE vFechaConcentra      DATE;
    DEFINE vINPC_Ini            DECIMAL(9,6);
    DEFINE vINPC_Fin            DECIMAL(9,6);
    DEFINE vAjustexInf          DECIMAL(9,6);
    DEFINE vDias                INTEGER;
    DEFINE vIntereses           DECIMAL(18,2);
    DEFINE vFisica              CHAR(1);
    DEFINE vExento              CHAR(1);
    DEFINE vTipoPersona         CHAR(1);
    DEFINE vSujRet              CHAR(1);
    DEFINE vBaseGravable        DECIMAL(18,2);
    DEFINE vISR                 DECIMAL(18,2);
    DEFINE vSaldoFinal          DECIMAL(18,2);
    DEFINE vAnioMesIni          CHAR(6);
    DEFINE vAnioMesFin          CHAR(6);
    DEFINE vTasa_ISR            DECIMAL(9,6);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    
    LET vFechaHoy         = '';
    LET vPorRetSuj        = 0;
    LET vSMDF             = 0;
    LET vNumSMDF          = 0;
    LET vBaseExenta       = 0.00;
    LET vCuenta           = '';   
    LET vNumCliente       = '';
    LET vSaldoConcentrado = 0.00;
    LET vFechaConcentra   = '';
    LET vINPC_Ini         = 0;
    LET vINPC_Fin         = 0;
    LET vAjustexInf       = 0;
    LET vDias             = 0;
    LET vIntereses        = 0.00;
    LET vFisica           = '';
    LET vExento           = '';
    LET vTipoPersona      = '';
    LET vSujRet           = '';
    LET vBaseGravable     = 0.00;
    LET vISR              = 0.00;
    LET vSaldoFinal       = 0.00;
    LET vAnioMesIni       = '';
    LET vAnioMesFin       = '';
    LET vTasa_ISR         = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calcsdoctainactiva.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vSaldoConcentrado;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calcsdoctainactiva.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINE LOS DATOS DE LA CUENTA
    SELECT cuenta, num_cte, sdo_concentrado, 
           CASE WHEN fecha_pago_concentra is not null THEN
                fecha_pago_concentra
           ELSE
                fecha_concentra
           END
      INTO vCuenta, vNumCliente, vSaldoConcentrado, vFechaConcentra
      FROM sc_cuentas_concentradas
     WHERE cuenta = pCuenta;
       
    IF vCuenta <> pCuenta THEN
        LET vCodRet1 = '100';
        RETURN vCodRet1, vSaldoConcentrado;
    END IF;
    
    IF vSaldoConcentrado is null THEN
        LET vSaldoConcentrado = 0.00;
    END IF;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // VALOR DEL ISR 
    SELECT valor
      INTO vPorRetSuj
      FROM bdinteg:si_fechavalor
     WHERE tasa = 'I.S.R.'
       AND fecha = (SELECT MAX(fecha)
                      FROM bdinteg:si_fechavalor
                     WHERE tasa = 'I.S.R.');
     
    /* ################# diciembre/2017 ################
	 -- // SALARIO MINIMO
    SELECT valor
      INTO vSMDF
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'smdf';

    -- // NUMERO DE VECES PARA EL SALARIO MINIMO
    SELECT valor
      INTO vNumSMDF
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'numsmdf';

    -- // BASE EXENTA DE IMPUESTO DE ISR PARA PF
    LET vBaseExenta = vSMDF * vNumSMDF * 365;
    ################# diciembre/2017 ################ */
    
    -- // BASE EXENTA DE IMPUESTO DE ISR PARA PF
    SELECT valor 
      INTO vBaseExenta
      FROM sc_param
	 WHERE empresa = pempresa 
       AND codparam = "baseexenta"; 
  
    IF vBaseExenta IS NULL THEN
        LET vBaseExenta = 0;
    END IF;
     
    -- // OBTIENE EL INPC INICIAL PARA OBTENER LA TASA PARA EL CALCULO DE INTERESES
    LET vAnioMesIni = TO_CHAR(vFechaConcentra, '%Y%m');
    
    SELECT preciocontable
      INTO vINPC_Ini
      FROM bdirepaut@coppelcont_tcp:"informix".sp_preciocontable
     WHERE moneda = '95'
       AND YEAR(fecha)||LPAD(MONTH(fecha),2,'0') = vAnioMesIni;
    
    /* ##############################################################
    SELECT preciocontable
      INTO vINPC_Ini
      FROM bdirepaut:sp_preciocontable
     WHERE moneda = '95'
       AND YEAR(fecha)||LPAD(MONTH(fecha),2,'0') = vAnioMesIni;
    ############################################################## */ 
	 
    IF vINPC_Ini is null THEN
        LET vINPC_Ini = 0;
    END IF;
     
    -- // OBTIENE EL INPC FINAL PARA OBTENER LA TASA PARA EL CALCULO DE INTERESES
    LET vAnioMesFin = TO_CHAR(vFechaHoy, '%Y%m');
    
    SELECT preciocontable
      INTO vINPC_Fin
      FROM bdirepaut@coppelcont_tcp:"informix".sp_preciocontable
     WHERE moneda = '95'
       AND YEAR(fecha)||LPAD(MONTH(fecha),2,'0') = vAnioMesFin;
    
    /* ##############################################################
    SELECT preciocontable
      INTO vINPC_Fin
      FROM bdirepaut:sp_preciocontable
     WHERE moneda = '95'
       AND YEAR(fecha)||LPAD(MONTH(fecha),2,'0') = vAnioMesFin;
    ############################################################## */
	
    IF vINPC_Fin is null THEN
        LET vINPC_Fin = 0;
    END IF;
    
    -- // FACTOR DE AJUSTE POR INFLACION
    IF ( vINPC_Ini = 0 OR vINPC_Fin = 0 ) THEN
        LET vAjustexInf = 0;
    ELSE
        LET vAjustexInf = (vINPC_Fin / vINPC_Ini) - 1;
    END IF;
    
    -- // CALCULA NUMERO DE DIAS
    LET vDias = (vFechaHoy - vFechaConcentra) + 1;
    
    -- // CALCULA LOS INTERESES
    IF vDias > 0 AND vAjustexInf > 0 THEN
        LET vIntereses = (((vSaldoConcentrado * vAjustexInf) / 365) * vDias);
    ELSE
        LET vIntereses = 0.00;
    END IF;
    
    IF vIntereses is null THEN
        LET vIntereses = 0.00;
    END IF;
    
    IF vIntereses > 0.00 THEN
        -- // VALIDA SI SE LE COBRA ISR
        SELECT tip.es_fisica, tip.exento_isr
          INTO vFisica, vExento
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE cte.numcte = vNumCliente
           AND cte.tpo_persona = tip.tpo_persona;
           
        -- // VALIDA SI LA PERSONA ES FISICA O MORAL
        IF vFisica = 'S' THEN
            LET vTipoPersona = 'F';
        ELSE
            LET vTipoPersona = 'M';
        END IF;
           
        -- // VALIDA SI ES EXENTO DE COBRO DE ISR
        IF vExento = 'N' THEN
            LET vSujRet = 'S';
        ELSE
            LET vSujRet = 'N';
        END IF;

        IF vSujRet <> 'S' THEN
            LET vPorRetSuj = 0;
        END IF;
        
        -- // CALCULA MONTO DEL ISR
        IF vPorRetSuj <> 0 THEN
            LET vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 );
            
            IF vTipoPersona = 'F' THEN
                LET vBaseGravable = vSaldoConcentrado - vBaseExenta;
                
                IF vBaseGravable > 0 THEN
                    LET vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 );
                ELSE
                    LET vISR = 0.00;
                END IF;
            ELSE
                LET vISR = TRUNC( ( vSaldoConcentrado * vTasa_ISR ), 2 );
            END IF;
        ELSE
            LET vISR = 0.00;
        END IF;
    ELSE
        LET vISR = 0.00;
    END IF;
    
    IF vISR is null THEN
        LET vISR = 0.00;
    END IF;
    
    LET vSaldoConcentrado = ( ( vSaldoConcentrado + vIntereses ) - vISR );
    
    END;
    
    RETURN vCodRet1, vSaldoConcentrado;
    
END PROCEDURE;