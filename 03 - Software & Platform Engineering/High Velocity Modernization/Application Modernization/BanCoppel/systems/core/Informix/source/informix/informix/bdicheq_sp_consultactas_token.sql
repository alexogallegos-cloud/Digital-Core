CREATE PROCEDURE "informix".sp_consultactas_token( pEmpresa char(3),
                                        pNumCte char(20),
                                        pMontoCargo money,
                                        pRegistro smallint )
   RETURNING char(5), char(20), money(14,2), char(4), char(40);
   
   
   
     --------------------------------------------------------------------------------------------
	-- Realizado:            Pedro Enrique Zavala Valdez
	-- Actividad:            Verifica que el cliente tenga suficiente efectivo 
	-- Solicita:             Mauricio 	
    -- Fecha de Solicitud:   10/12/2009
    -- MODIFICADO:            Donovan F. Torres Landeros,
    -- ULTIMA MODIFICACION:   2025/06/04,
    -- RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro),
    --                       a la operacion aritmetica para el nuevo calculo de,
    --                       saldo disponible.,
    --PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion,
    --BD:                    bdicheq,
    --VER:                   1.2;     
	---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret             char(5);
   DEFINE vCuenta             char(20);
   DEFINE vSaldoDisp          money(14,2);
   DEFINE vProducto           char(4);
   DEFINE vDescProd           char (40);
   DEFINE sql_err             integer ;
   DEFINE  iCont              integer ;


-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET vCuenta       = " ";
   LET vSaldoDisp    = 0;
   LET vProducto     = " ";
   LET vDescProd     = " ";
   LET iCont         = 0;


   --SET DEBUG FILE TO "/home/c90402536/Traza/sp_consultactas_token_modif.out";
   --TRACE ON; 
   
BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vCuenta, vSaldoDisp, vProducto, vDescProd;
        END IF
    END EXCEPTION;

    IF ( pEmpresa = '' OR pEmpresa IS NULL OR pNumCte = '' OR
         pNumCte IS NULL OR pRegistro = '' OR pRegistro IS NULL ) THEN

        LET cod_ret = '001'; --Parametros no validos.
        RETURN cod_ret, vCuenta, vSaldoDisp, vProducto, vDescProd;
    END IF

    SET ISOLATION DIRTY READ;

    FOREACH

        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
        SELECT SKIP pRegistro FIRST 10 cuenta, sdo_actual - sdo_retenido - sdo_cong - imp_chq_sbg - saldo_sbc, 
        mc.producto, pr.nombre
        INTO vCuenta, vSaldoDisp, vProducto, vDescProd
        FROM sc_maechq mc, sc_producto pr
        WHERE mc.empresa = pEmpresa AND num_cte = pNumCte AND status_cta <> 2 
            AND pr.producto = mc.producto       

        IF(vSaldoDisp >= pMontoCargo) THEN
            LET iCont = iCont + 1;
            RETURN cod_ret, vCuenta, vSaldoDisp, vProducto, vDescProd WITH RESUME;
        END IF ;

    END FOREACH;
	
	
	--Actualiza los datos del cobro del reenvio de token
		UPDATE bdibpi: "informix".tkn_solcobranza SET f_cobro=current, cuenta=vCuenta, monto_tot='0'
		WHERE numcte = pNumCte AND id_status = '180' and t_persona='01';

    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET cod_ret = '002'; --Cliente No tiene cuentas
        RETURN cod_ret, vCuenta, vSaldoDisp, vProducto, vDescProd;
    END IF

END
END PROCEDURE ;