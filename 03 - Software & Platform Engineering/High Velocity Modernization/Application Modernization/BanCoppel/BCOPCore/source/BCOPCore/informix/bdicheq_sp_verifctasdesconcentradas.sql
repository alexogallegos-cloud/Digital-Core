CREATE PROCEDURE "informix".sp_verifctasdesconcentradas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
       
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vTrxAbierta          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
    DEFINE vTrxCargo            CHAR(4);
    DEFINE vTrxAbono            CHAR(4);
    DEFINE vCtaNostro           CHAR(20);
    DEFINE vDiasDesConcentra    INTEGER;
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vProducto            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaDesConcentra   DATE;
    DEFINE vDiasSinTransacc     INTEGER;    
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vHoraTrx             CHAR(15);
    DEFINE vProdNostro          CHAR(4);
    DEFINE vSucNostro           CHAR(4);
    DEFINE vSdoNostro           DECIMAL(18,2);
    DEFINE vInsTrxCargo         CHAR(1);
    DEFINE vUpdTrxCargo         CHAR(1);
    DEFINE vInsTrxAbono         CHAR(1);
    DEFINE vUpdTrxAbono         CHAR(1);
    DEFINE vUpdCuenta           CHAR(1);
    DEFINE vUpdConcen           CHAR(1);
    DEFINE vUpdCtaDesc          CHAR(1);
	DEFINE vFechaOperacion   	DATE;
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);

    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '000';
    LET vCodRet3            = '';
    LET vTrxAbierta         = 0;
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vFechaHoy           = '';
    LET vTrxCargo           = '';
    LET vTrxAbono           = '';
    LET vCtaNostro          = '';
    LET vDiasDesConcentra   = 0;
    LET vCuenta             = '';   
    LET vStatusCta          = '';
    LET vSucursal           = '';
    LET vNumCliente         = '';
    LET vProducto           = '';
    LET vSdoActual          = 0.00;
    LET vSdoRetenido        = 0.00;
    LET vSdoCongelado       = 0.00;
    LET vSdoSobregirado     = 0.00;
    LET vFechaUltimoDep     = '';
    LET vFechaUltimoRet     = '';
    LET vFechaDesConcentra  = '';
    LET vDiasSinTransacc    = 0;
    LET vSdoDispCuenta      = 0.00;
    LET vHora               = '';
    LET vFolio              = '';
    LET vHoraTrx            = '';
    LET vProdNostro         = '';
    LET vSucNostro          = '';
    LET vSdoNostro          = 0.00;
    LET vInsTrxCargo        = '0';
    LET vUpdTrxCargo        = '0';
    LET vInsTrxAbono        = '0';
    LET vUpdTrxAbono        = '0';
    LET vUpdCuenta          = '0';
    LET vUpdConcen          = '0';
    LET vUpdCtaDesc         = '0';
	LET vFechaOperacion   	= TODAY;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE TRANSACCION DE CARGO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargo
      FROM sc_param
     WHERE empresa = pEmpresa
      AND codparam = 'TrxCgoCtaConcentrada';

    -- // OBTIENE TRANSACCION DE ABONO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbono
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';

    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaNostro
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
     
    -- // OBTIENE EL NUMERO DE DIAS PARA VOLVER A CONCENTRAR
    SELECT valor::INT
      INTO vDiasDesConcentra
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasCtasDesConcentra';
    
    FOREACH WITH HOLD
        -- // OBTIENE DATOS DE LA CUENTA A CONCENTRAR
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
		SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.num_cte, mae.producto, 
               mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, 
               mae.fecultdep, mae.fecultret, con.fecha_pago_concentra, mae.saldo_sbc
          INTO vCuenta, vStatusCta, vSucursal, vNumCliente, vProducto, 
               vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, 
               vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, mSaldoSbc
          FROM sc_maechq mae,
               sc_cuentas_concentradas con
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '8'
           AND con.cuenta = mae.cuenta
    
        BEGIN WORK;
        LET vTrxAbierta = 1;
        
        LET vContador1 = vContador1 + 1;
        
        LET vDiasSinTransacc = 0;
        LET vSdoDispCuenta   = 0;
        LET vInsTrxCargo     = '0';
        LET vUpdTrxCargo     = '0';
        LET vInsTrxAbono     = '0';
        LET vUpdTrxAbono     = '0';
        LET vUpdCuenta       = '0';
        LET vUpdConcen       = '0';
        LET vUpdCtaDesc      = '0';
        
        LET vDiasSinTransacc = vFechaHoy - vFechaDesConcentra;
        
		IF ( vDiasSinTransacc > vDiasDesConcentra ) THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDispCuenta;
			
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
                ROLLBACK WORK;
                LET vTrxAbierta = 0;
         		CONTINUE FOREACH;
      		END IF;  
            
			IF vSdoDispCuenta > 0.00 THEN 
				LET vHora = CURRENT HOUR TO FRACTION;
				LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
			
				LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
                INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxCargo, vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
                  vSdoDispCuenta, 0.00, 0.00, 0.00, 0, '', '', vSdoActual, '0000' , 'CONCENTRACION POR INACTIVIDAD ART 61 LIC', 0, '', '', '', vFechaOperacion);
                  
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vInsTrxCargo = '1';
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual   = sdo_actual - vSdoDispCuenta,
                       imp_cgos_mes = imp_cgos_mes + vSdoDispCuenta,
                       num_cgos_mes = num_cgos_mes + 1,
                       fec_ult_mov  = vFechaHoy
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta; 
                   
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vUpdTrxCargo = '1';
                END IF;
                
                IF vInsTrxCargo = '1' AND vUpdTrxCargo = '1' THEN
                    SELECT producto, sucursal, sdo_actual
                      INTO vProdNostro, vSucNostro, vSdoNostro
                      FROM sc_maechq 
                     WHERE empresa = pEmpresa
                       AND cuenta = vCtaNostro;
                       
                    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
                    
                    INSERT INTO sc_movdia VALUES
                    ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxAbono, vSucNostro, vProdNostro, pEmpresa, vCtaNostro, '', 0, 
                      vSdoDispCuenta, vSdoDispCuenta, 0.00, 0.00, 0, '', '', vSdoNostro, '0000', 'ABONO X CONCENTRACION DE CTA '||TRIM(vCuenta), 0, '', '', '', vFechaOperacion);
                              
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vInsTrxAbono = '1'; 
                    END IF;
                    
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + vSdoDispCuenta,
                           imp_abonos_mes = imp_abonos_mes + vSdoDispCuenta, 
                           num_abonos_mes = num_abonos_mes + 1,
                           fec_ult_mov = vFechaHoy,
                           fecultdep = vFechaHoy
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCtaNostro;
                                   
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vUpdTrxAbono = '1'; 
                    END IF;
                    
                    IF vInsTrxAbono = '1' AND vUpdTrxAbono = '1' THEN
                        UPDATE sc_cuentas_concentradas
                           SET folio = vFolio,
                               sdo_concentrado = vSdoDispCuenta
                         WHERE cuenta = vCuenta;
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdConcen = '1';
                        END IF;
                        
                        UPDATE sc_maechq
						   SET status_cta = '6'
						 WHERE empresa = pEmpresa
						   AND cuenta = vCuenta; 
                           
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCuenta = '1';
                        END IF;
                        
                        INSERT INTO sc_ctasdescon_concentradas
                        ( num_cte, producto, cuenta, status_cta, sdo_actual, fech_ult_dep, fech_ult_ret, fecha_desmar, fecha_marc )
                        VALUES
                        ( vNumCliente, vProducto, vCuenta, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, vFechaHoy );
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCtaDesc = '1';
                        END IF;
                        
                        IF vUpdConcen = '1' AND vUpdCuenta = '1' AND vUpdCtaDesc = '1' THEN
                            LET vContador2 = vContador2 + 1;
                        ELSE
                            ROLLBACK WORK;
                            LET vTrxAbierta = '0';
                            CONTINUE FOREACH;
                        END IF;
                    ELSE
                        ROLLBACK WORK;
                        LET vTrxAbierta = '0';
                        CONTINUE FOREACH;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET vTrxAbierta = '0';
                    CONTINUE FOREACH;
                END IF;
            ELSE
                ROLLBACK WORK;
                LET vTrxAbierta = '0';
                CONTINUE FOREACH;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = '0';
            CONTINUE FOREACH;
        END IF; 
        
        COMMIT WORK;
        LET vTrxAbierta = '0';
    END FOREACH;
    
    END;
     
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
     
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_actparampasecheq(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasecheq                                  ##
    --- ##  Version:             2.0                                                  ##
    --- ##  Objetivo:            Programa del pase contable de captacion              ##
    --- ##  Creado por:                                                               ##
    --- ##  Modificado por:      Ivan Escorza                                         ##
    --- ##  Ultima Modificacion: Marzo 2026                                           ##
    --- ################################################################################

    DEFINE vcodret       CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      VARCHAR(50);
    DEFINE vsqlerr       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    VARCHAR(50);
    DEFINE vpromedio     INTEGER;
    DEFINE vcont         SMALLINT;
    DEFINE vbrinca       INTEGER;
    DEFINE vserial       INTEGER;
    DEFINE vparam_serial VARCHAR(60);
    
    LET vcodret          = "000";
    LET vcodret2         = "000";
    LET vcodret3         = " ";
    LET vsqlerr          = 0;
    LET isam_err         = 0;
    LET error_info       = '';
    LET vpromedio        = 0;
    LET vcont            = 0;
    LET vbrinca          = 0;
    LET vserial          = 0;
    LET vparam_serial    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheq.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_actparampasecheq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM bdicheq:sc_movdia_concil
	  WHERE num_serial > 0;  

    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial 

                LET vparam_serial = vserial;
                
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom1';

            END FOREACH;

        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
                 
                 UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom2';
 
            END FOREACH;

        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial

                LET vparam_serial = vserial;
    
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom3';
  
            END FOREACH;

        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
     
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom4';

            END FOREACH;

        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial

                LET vparam_serial = vserial;
                 
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom5'; 
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;