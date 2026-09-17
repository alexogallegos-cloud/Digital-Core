CREATE PROCEDURE "informix".sp_consulta_saldo_cuentas (pEmpresa char(3), pSolicitud char(10))
   RETURNING char(5), char(5);
   
     
     --------------------------------------------------------------------------------------------
	-- Realizo: Aida Kareline Valenzuela Benitez
	-- Actividad: Consulta el saldo de las cuentas del Cliente
	-- Solicito: Alejandro Vazquez
	-- Fecha de Solicitud: 29/09/2015

	---------------------------------------------------------------------------------------------
	
	-- MODIFICO : Daniel Hernandez Garcia
	-- FECHA : 29-05-2025
	-- MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible
	-- PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion
	-- BD    : bdicheq
	-- VER   : 1.1
	
	---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret      char(5);
   DEFINE cod_val      char(5);
   DEFINE vCuenta      char(20);
   DEFINE vCredito     char(20);
   DEFINE vCliente char(9);
   DEFINE vSaldoDisp   money(14,2);
   DEFINE vCargoReenv  money (14,2);
   DEFINE vCargoiva  money (14,2);
   DEFINE sql_err      integer;
   DEFINE  iCont       integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "000";
   LET cod_val = "000";
   LET vCuenta = " ";
   LET vCredito= " ";
   LET vSaldoDisp = 0;
   LET vCargoReenv = 0;
   LET vCargoiva = 0;
   LET iCont = 0;

   --SET DEBUG FILE TO '/home/c90314833/Cobranza/SPs_modificados/sp_consulta_saldo_cuentas.out';
   --TRACE ON;
   
BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, cod_val;
        END IF
    END EXCEPTION;
	
	
	SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)}  numcte 
    INTO vCliente 
    FROM bdibpi:bpi_tokensolicitud
    WHERE empresa = pEmpresa AND solicitud = pSolicitud;

	
    IF ( pEmpresa = '' OR pEmpresa IS NULL OR 
		 vCliente = '' OR vCliente IS NULL ) THEN

        LET cod_ret = '001'; --Parametros no validos.
        RETURN cod_ret, cod_val;
    END IF;
	   
	SELECT valor 
		INTO vCargoReenv 
		FROM bdibpi:tkn_parametros 
		WHERE id_param = '08';
		
	SELECT valor 
		INTO vCargoiva
		FROM bdinteg:si_param
		WHERE cod_param = '47';	

	LET vCargoReenv = vCargoReenv + (vCargoReenv * vCargoiva);
 
	
	
    SET ISOLATION DIRTY READ;

    FOREACH
	--RQM 09 704. Se agrega el valor del campo saldo_sbc al calculo de saldo disponible. DHG
        SELECT  cuenta, sdo_actual - sdo_retenido - sdo_cong - imp_chq_sbg - saldo_sbc
			INTO vCredito, vSaldoDisp 
        FROM bdicheq:sc_maechq mc, bdicheq:sc_producto pr
        WHERE mc.empresa = pEmpresa AND num_cte = vCliente AND status_cta <> 2 
            AND pr.producto = mc.producto 
			
					
        IF(vSaldoDisp >= vCargoReenv) THEN
            LET iCont = iCont + 1;			
            RETURN cod_ret, cod_val;
        END IF ;
		

    END FOREACH;


    IF ( iCont = 0 ) THEN
    

			 --obtiene  saldo de cuentas de credito  	
		FOREACH 
			SELECT mcd.num_credito, monto_otorgado -(sdo_cap_insoluto + sdo_retenido) as credito_disponible 
			INTO vCuenta, vSaldoDisp 
				FROM bdicred:sd_maesdos mcd, bdicred:sd_definicion prc, bdicred:sd_maecred mcc
				WHERE mcc.empresa = pEmpresa AND numcte = vCliente 
				AND mcc.status_cred IN ('AA','E1')
				AND (mcd.monto_vencido + mcd.mto_venc_trasp) = 0
				AND prc.num_producto = mcc.num_producto 
			
			IF(vSaldoDisp >= vCargoReenv) THEN
				LET iCont = iCont + 1;			
				RETURN cod_ret, cod_val;
			END IF;			
		END FOREACH;	
	END IF;

	
	IF ( iCont = 0 ) THEN
        LET cod_ret = '002'; --Cliente No tiene cuentas        
    END IF;
		
	LET cod_val = '099'; --No tiene cuentas ni saldo sifucueinte
	RETURN cod_ret, cod_val;
	
	
	
END
END PROCEDURE;