CREATE PROCEDURE "informix".sp_integra_ctas_conce(vEmpresa CHAR(3))
    RETURNING               CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vCodRet          CHAR(5);
	DEFINE vCuenta          CHAR(20);
	DEFINE vHora            CHAR(15);	
    DEFINE vFechaHoy        DATE;
    DEFINE vHoraTrx         CHAR(12);
    DEFINE vSucursal        CHAR(4);	
	DEFINE vSdoActual       DECIMAL(18,2);
	DEFINE vFechaOpera      DATE;
	DEFINE vTrxCargo        CHAR(4);
	DEFINE vSucNostro       CHAR(4);
	DEFINE vProdNostro      CHAR(4);
	DEFINE vSdoActNostro    DECIMAL(18,2);
	DEFINE vSdoRetNostro    DECIMAL(18,2);
	DEFINE vSdoCongNostro   DECIMAL(18,2);
	DEFINE vSdoSbgNostro    DECIMAL(18,2);
	DEFINE vStatCtaNostro   CHAR(1);
	DEFINE vCuentaNostro    CHAR(20);
	DEFINE vSdoConcentrado  DECIMAL(18,2);
	DEFINE vProducto        CHAR(4);
	DEFINE vStatus          CHAR(1);
	DEFINE vNumCte          CHAR(20);
	DEFINE vFechaConcentra  DATE;
	DEFINE vFechaOperacion  DATE;
	DEFINE vInsTrxAbono     CHAR(1);
	DEFINE vInsTrxCargo     CHAR(1);
	DEFINE vUpdTrxCargo     CHAR(1);
	DEFINE vTrxAbono        CHAR(4);
	DEFINE vInsertaTrx      CHAR(1);
	DEFINE vFolio           CHAR(16);
	DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
	
	   		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vCodRet             = "00000";
	LET vCuenta             = '';
	LET vHora               = '';
	LET vFechaHoy           = '';
	LET vHoraTrx            = '';
	LET vSucursal           = '';
	LET vSdoActual          = 0.00;
	LET vFechaOpera         = TODAY;
	LET vTrxCargo           = '';
	LET vSucNostro          = '';
	LET vProdNostro         = '';
	LET vSdoActNostro       = 0.00;
	LET vSdoRetNostro       = 0.00;
	LET vSdoCongNostro      = 0.00;
	LET vSdoSbgNostro       = 0.00;
	LET vStatCtaNostro      = '';
	LET vCuentaNostro       = '';
	LET vSdoConcentrado     = 0.00;
	LET vProducto           = '';
	LET vStatus             = '';
	LET vNumCte             = '';
	LET vFechaConcentra     = '';
	LET vFechaOperacion     = TODAY;
	LET vInsTrxAbono        = '0';
	LET vInsTrxCargo        = '0';
	LET vUpdTrxCargo        = '0';
	LET vTrxAbono           = '';
	LET vInsertaTrx         = '0';
	LET vFolio              = '';
	LET v_c_vcomienza       = -1;
	LET ven_transacc        = 0;
	LET v_c_vcontador       = 0;
		
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_integra_ctas_conce.err";
	 	    TRACE ON;
			LET vCodRet    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        IF ven_transacc = 1 THEN
               ROLLBACK WORK;
            END IF;
			RETURN vCodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/informix/rsv/art61/sp_integra_ctas_conce.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy 
    INTO   vFechaHoy
    FROM   sc_fechas
    WHERE  empresa = vEmpresa;	
		
	-- // OBTIENE TRANSACCION DE CARGO A CUENTA CONCENTRADORA  "0511"
    SELECT valor
    INTO   vTrxCargo
    FROM   sc_param
    WHERE  empresa  = vEmpresa
    AND    codparam = 'TrxCgoCtaConcaCtaMig';
	
	-- // OBTIENE TRANSACCION DE ABONO PARA DESCONCENTRAR  "0512"
    SELECT valor
    INTO   vTrxAbono
    FROM   sc_param
    WHERE  empresa = vEmpresa
    AND    codparam = 'TrxAboCtaConcaCtaMig';
	
	 -- // OBTIENE LA CUENTA CONCENTRADORA 
    SELECT valor
    INTO   vCuentaNostro
    FROM   sc_param
    WHERE  empresa = vEmpresa
    AND    codparam = 'CtaConcentradorArt61';
	

	--SE OPTIENEN TODAS LAS CUENTAS QUE SE VAN A INTEGRAR AL NUEVO PROCESO. 
	FOREACH WITH HOLD
		       
			-- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
            SELECT con.cuenta, con.sdo_concentrado, mae.sucursal, mae.producto, mae.status_cta, mae.sdo_actual, con.num_cte, con.fecha_concentra
            INTO   vCuenta,    vSdoConcentrado,     vSucursal,    vProducto,    vStatus,        vSdoActual,     vNumCte,     vFechaConcentra
            FROM   sc_cuentas_concentradas con,
                   sc_maechq mae
         	WHERE  mae.cuenta = con.cuenta
            AND    mae.status_cta = '6' 
	        AND    mae.producto <> '5000'
			AND    con.sdo_concentrado > 0
						
			
			-- Abre la transaccion 
		    IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
			
			-- // OBTIENE DATOS DE LA CUENTA CONCENTRADORA
            SELECT sucursal,   producto,    sdo_actual,    sdo_retenido,  sdo_cong,       imp_chq_sbg,   status_cta
            INTO   vSucNostro, vProdNostro, vSdoActNostro, vSdoRetNostro, vSdoCongNostro, vSdoSbgNostro, vStatCtaNostro
            FROM   sc_maechq 
            WHERE  cuenta = vCuentaNostro;
			
			--SE VALIDA SI EL SALDO DE LA CUENTA CONCENTRADORA ES SUFUCIENTE PARA ABONAR A LA CUENTA DE CONCENTRADA
			IF  vSdoActNostro >= vSdoConcentrado THEN 

			    ---VALORES PARA GENERAR EL FOLIO 
	            LET vHora = CURRENT HOUR TO FRACTION;
                LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
	            LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
                
			    -- TRANSACCION DE CARGO A LA CUENTA CONCENTRADORA. 
			    INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxCargo, vSucNostro, vProdNostro, vEmpresa, vCuentaNostro, '', 0, 
                vSdoConcentrado, 0.00, 0.00, 0.00, 0, '', vStatCtaNostro, vSdoActNostro, '0000' , 'CARGO X DESCONCENTRACION CTA '||TRIM(vCuenta), 0, '', '', '', vFechaOperacion);
                
		        
			    IF  dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vInsTrxCargo = '1';
                END IF;
                
		        --ACTUALIZA SALDO DE LA CUENTA CONCENTRADORA. 
                UPDATE sc_maechq
                SET    sdo_actual   = sdo_actual   - vSdoConcentrado,
                       imp_cgos_mes = imp_cgos_mes + vSdoConcentrado,
                       num_cgos_mes = num_cgos_mes + 1,
                       fec_ult_mov  = vFechaHoy,
                       fecultret    = vFechaHoy
                WHERE  cuenta       = vCuentaNostro; 
			    
			    IF  dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vUpdTrxCargo = '1';
                END IF;
			    
			    IF  vInsTrxCargo = '1' AND vUpdTrxCargo = '1' THEN
			    
			        LET vHora = CURRENT HOUR TO FRACTION;
                    LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
                    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
			       
			        --TRANSACCION DE ABONO A LA CUENTA DE CHEQUES 
			        INSERT INTO sc_movdia VALUES
                    ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxAbono, vSucursal, vProducto, vEmpresa, vCuenta, '', 0, 
                    vSdoConcentrado, vSdoConcentrado, 0.00, 0.00, 0, '', vStatus, vSdoActual, '0000', 'DESCONCENTRACION X ACLARACION ART 61 LIC', 0, '', '', '', vFechaOperacion);
                          
                    IF  dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET vInsTrxAbono = '1';
                    END IF;
			    	
			    	IF  vInsTrxAbono = '1' THEN 
                        --ACTUALIZA SALDO EN LA CUENTA DE CHEQUES 
                        UPDATE sc_maechq
                        SET    sdo_actual = sdo_actual  + vSdoConcentrado
                        WHERE  cuenta     = vCuenta; 
			    		
			    	END IF;
                   				
			    END IF; 
			    						
			    -----***************** CONCENTRACION ***************************
			    -----***************** CONCENTRACION ***************************
			    
			    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
		        -- // INSERTA TRANSACCION DE CONCENTRACION
		        INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, '0513', vSucursal, vProducto, vEmpresa, vCuenta, '', 0, 
                  vSdoConcentrado, vSdoConcentrado, 0.00, 0.00, 0, '', vStatus, vSdoConcentrado, '0000' , 'CONCENTRACION ART 61 LIC', 0, '', '', '', vFechaOpera);	
		        
		        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
		        	LET vInsertaTrx = '1';
		        END IF;
			    
			    IF  vInsertaTrx = '1' THEN 
			    
			        -- // INICIALIZA ACUMULADOS
		            UPDATE sc_maenoc
		            SET    dia_sdo_pos   = 0,
		            	   acum_sdo_pos  = 0.00,
		            	   int_acum      = 0.00,
		            	   isr_acum      = 0.00,
		            	   dias_acum_int = 0,
		            	   acum_sdo_int  = 0.00
		            WHERE cuenta = vCuenta;
			    				
			    	--ACTUALIZA EL PRODUCTO
			        UPDATE sc_maechq 
			        SET    producto  = '5000'
			        WHERE  cuenta    = vCuenta;
			    		
			    END IF;
			    
			    LET v_c_vcontador = v_c_vcontador + 1;
			    --Realiza commit cada 500 registros 
			    IF (v_c_vcontador >= 500) THEN
                   LET v_c_vcontador = 0;
                   COMMIT WORK;
                   BEGIN WORK;
                END IF; 
			ELSE 
			    --Si la transaccion esta abierta realiza el commit
			    IF  ven_transacc = 1 THEN
                   LET ven_transacc = 0;
                   COMMIT WORK;
                END IF;	
			
			    LET vCodRet = '00001';
	            RETURN  vCodRet;
			END IF; 
			
	END FOREACH;
		
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	

RETURN  vCodRet;
END; 
END PROCEDURE;