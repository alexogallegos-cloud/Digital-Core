CREATE PROCEDURE "informix".sp_corresp_deposito_mc( pNombreCorresponsal VARCHAR(9), --- pNombreCorresponsal - Valor recibido del autorizador 
                                                    pusuario     CHAR(8),       --- USUARIO
                                                    pfolio       CHAR(16),      --- FOLIO SUC
                                                    pcuenta      CHAR(20),      --- CUENTA
                                                    pnum_tarjeta CHAR(16),      --- TARJETA
                                                    pfecha       DATE,          --- FECHA
                                                    pmto_tot     DECIMAL(14,2), --- MONTO
                                                    pmoneda      CHAR(3),       --- MONEDA
                                                    preferencia  CHAR(40) )     --- REFERENCIA
RETURNING CHAR(5)  as CODIGO_RETORNO,    --- CODIGO DE RETORNO
          CHAR(13)    as vCuenta,           --- CUENTA
          CHAR(53)    as vNombreCliente,    --- NOMBRE CORTO DEL CLIENTE
          MONEY(14,2) as vSaldoDisp,        --- Saldo Disponible
          DATE        as vFechaCentralHoy;
    
    DEFINE CODIGO_RETORNO       CHAR(5);
    DEFINE MENSAJE_RESPUESTA    VARCHAR(80);
    DEFINE RUTA_ORIGEN          VARCHAR(80);
    DEFINE TIPO_DEBITO          CHAR(1);
    DEFINE vCuenta              CHAR(13);
    DEFINE vNombreCliente       CHAR(53);
    DEFINE vFechaCentralHoy     DATE;
    DEFINE SQL_ERR              INTEGER;
    DEFINE ISAM_ERR             INTEGER;
    DEFINE vcodret2             SMALLINT;
    DEFINE vproceso             CHAR(1);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_tpcambio      DATE;
    DEFINE vprecio_udi          DECIMAL(14,6);
    DEFINE vmonto_udi           DECIMAL(18,6);
    DEFINE vmtoacumcta          DECIMAL(18,6);
    DEFINE vmtopagosudi         DECIMAL(18,6);
    DEFINE vlim_cuenta          DECIMAL(18,6);
    DEFINE vporcapcorres        DECIMAL(9,6);
    DEFINE vmtoglobcap          DECIMAL(20,6);
    DEFINE vmtomensacum         DECIMAL(20,6);
    DEFINE vexiste              CHAR(20);
    DEFINE vtransaccion         SMALLINT;    
    DEFINE vnomaxudis           INTEGER;
    DEFINE vhoramax             DATETIME HOUR TO MINUTE;
    DEFINE wcuenta              CHAR(20);
    DEFINE vstatus_tar          CHAR(1);
    DEFINE vproducto            CHAR(4);
    DEFINE vnum_cte             CHAR(9);
   
    DEFINE vnombre              CHAR(53);
    DEFINE vnombre_cte          CHAR(53);
    DEFINE vprod                INTEGER;  
    DEFINE vind_cierre          CHAR(1);
    DEFINE vind_dispon          CHAR(1);
    DEFINE vSaldoDisp           MONEY(14,2);
    DEFINE vProdNoPermitidos    CHAR(80);
    DEFINE vProductoCuentaTarj  CHAR(4);
    DEFINE vNumCuenta           CHAR(13);
    DEFINE vTipoCorresponsal    SMALLINT;
    DEFINE vUdisPermitidas      DECIMAL(14,2);
    DEFINE vMontoAcumCorresp         DECIMAL(18,6);
    DEFINE vMontoPagosCorresp        DECIMAL(18,6);    
    DEFINE vNumeroMaximoUDIS VARCHAR(10);
    DEFINE vNumTransaccCorresp CHAR(4);
    DEFINE vCentroCostos CHAR(4);    
    DEFINE vCorrespDisponible CHAR(1);
    DEFINE vCodigoFun  CHAR(4); 
    DEFINE vHabilitarComision CHAR(1);
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumeroCliente_Capt VARCHAR(20);
    DEFINE vNumTarjeta VARCHAR(16);    
    DEFINE vValidarCtaCruzada CHAR(1);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET CODIGO_RETORNO       = '00000';
    LET MENSAJE_RESPUESTA    = 'Ejecucion exitosa';
    LET RUTA_ORIGEN          = '/RESPALDOSNEW/';
    LET TIPO_DEBITO = 'D';
    LET SQL_ERR              = 0;
    LET ISAM_ERR             = 0;
    LET vcodret2             = '000';
    LET vproceso             = '0';
    LET vfecha_hoy           = '';
    LET vfecha_tpcambio      = '';
    LET vprecio_udi          = 0.00;  
    LET vmonto_udi           = 0.00;
    LET vmtoacumcta          = 0.00;
    LET vmtopagosudi         = 0.00;
    LET vlim_cuenta          = 0.00;
    LET vporcapcorres        = 0.00;
    LET vmtoglobcap          = 0.00;
    LET vmtomensacum         = 0.00;
    LET vexiste              = '';
    LET vtransaccion         = 0;
    LET vnomaxudis           = 0;
    LET vhoramax             = '';
    LET wcuenta              = '';
    LET vstatus_tar          = '';
    LET vproducto            = '';
    LET vnum_cte             = '';
    LET vnombre              = '';
    LET vnombre_cte          = '';
    LET vprod                = 0;
    LET vind_cierre          = '0';
    LET vind_dispon          = '0';
    LET vFechaCentralHoy     = '';
    LET vSaldoDisp           = 0.00;
    LET vProdNoPermitidos    = '';
    LET vProductoCuentaTarj  = '';
    LET vNumCuenta           = '';
    LET vUdisPermitidas      = 0.00;
    LET vMontoAcumCorresp         = 0;
    LET vMontoPagosCorresp        = 0;    
    LET vNumeroMaximoUDIS = NULL;
    LET vNumTransaccCorresp = NULL;
    LET vCentroCostos = NULL;
    LET vTipoCorresponsal = '';
    LET vCorrespDisponible = NULL;
    LET vCodigoFun = '0000';
    LET vHabilitarComision = NULL;
    
    LET vNumeroCliente = '';    
    LET vNumeroCliente_Capt = '';    
    LET vNumTarjeta = '';    
    LET vValidarCtaCruzada = '';
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';

    
    BEGIN
    
        ON EXCEPTION SET SQL_ERR, ISAM_ERR            
            SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_corr_deposito_mc_"||LOWER(TRIM(pNombreCorresponsal))||".out" WITH APPEND;
            TRACE ON;
            IF (SQL_ERR <> 0) THEN
            
                LET CODIGO_RETORNO = SQL_ERR;
                IF vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF
                
                IF (vproceso = '1') THEN
                    LET CODIGO_RETORNO = '00000';
                ELSE
                    LET CODIGO_RETORNO = SQL_ERR;
                END IF;
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
        END EXCEPTION;

        ON EXCEPTION IN (-535)
            LET vtransaccion = 1;
        END EXCEPTION WITH resume;
    
        --SET DEBUG FILE TO RUTA_ORIGEN||'ejec_sp_corr_deposito_mc_'||LOWER(TRIM(pNombreCorresponsal))||'.out';
        --TRACE ON;
    
        IF (vtransaccion = 1) THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;    
        
        SELECT fecha_hoy, ind_cierre, ind_disponible
            INTO vFechaCentralHoy, vind_cierre, vind_dispon
        FROM bdicheq:sc_fechas 
            WHERE empresa = '001';
    
        IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08010';
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
    
        ---Obtener los parametros necesarios para aprobar o rechazar la transaccionalidad por corresponsal
        EXECUTE PROCEDURE bdicorresp_mc:"informix".sp_corresp_mc_obtener_datos( pNombreCorresponsal, TIPO_DEBITO )
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS,
                    vNumTransaccCorresp, vCentroCostos, vTipoCorresponsal, vCodigoFun, vHabilitarComision, vCorrespDisponible;
        
        ---Validar que el corresponsal esta activo.
        IF ( vCorrespDisponible IS NULL OR vCorrespDisponible = '0' OR CODIGO_RETORNO <> '00000') THEN
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;        
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF    
    
        --Validaciones de los parametros
        IF (vCentroCostos IS NULL OR vCentroCostos = '' OR LENGTH(vCentroCostos) <> 4) OR
            (pusuario IS NULL OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
           (pfolio IS NULL OR pfolio = '' OR LENGTH(pfolio) < 15) OR
           ((pcuenta IS NULL OR pcuenta = '' OR LENGTH(pcuenta) <> 11) 
            AND (pnum_tarjeta IS NULL OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16)) OR
           (pfecha IS NULL OR pfecha = '') OR
           (pmto_tot IS NULL OR pmto_tot <= 0.00) OR
           (vCodigoFun IS NULL OR TRIM(vCodigoFun) <> '0000') OR
           (vNumeroMaximoUDIS IS NULL OR TRIM(vNumeroMaximoUDIS) = '0') OR
           (pmoneda IS NULL OR pmoneda = '' OR LENGTH(pmoneda) <> 03) OR 
           (vHabilitarComision IS NULL) THEN
            
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;        
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
   
    
        IF LENGTH(pmoneda) = 03 THEN
            LET pmoneda = pmoneda[2,3];
        END IF;
    
        -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
        IF (pcuenta IS NULL OR pcuenta = '') THEN
        
            SELECT cuenta, status_tar
              INTO pcuenta, vstatus_tar
              FROM bdicheq:"informix".sc_tarjeta
             WHERE num_tarjeta = pnum_tarjeta;
            
            IF (vstatus_tar <> 'A') THEN    
                IF (vtransaccion = 1) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '08001';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
        END IF;
    
        IF (pnum_tarjeta IS NULL OR pnum_tarjeta = '') THEN
            SELECT num_tarjeta
              INTO pnum_tarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE cuenta = pcuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = ( SELECT MAX(secuencia)
                                   FROM bdicheq:"informix".sc_tarjeta
                                  WHERE cuenta = pcuenta
                                    AND tipo_tarjeta = 'T'
                                    AND status_tar = 'A' );

            IF (pnum_tarjeta IS NULL) THEN
                LET pnum_tarjeta = '';
            END IF;
        END IF; 
    
        --Bin fue dado de baja con VISA
        IF SUBSTR(pnum_tarjeta, 1, 6) = '400819' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08011';
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF    
        
        --Validar si la cuenta del deposito esta correctamente asignada, o bien, esta cruzada con otro numero de tarjeta.        
        SELECT valor
            INTO vValidarCtaCruzada
        FROM bdicheq:sc_param
            WHERE codparam = 'validarctascruz_cheq';
            
        IF ( vValidarCtaCruzada  = 'S' ) THEN
            
            SELECT numcliente
                INTO vNumeroCliente
            FROM intercard:tarjeta 
                WHERE numtarjeta = pnum_tarjeta;        
            
            SELECT num_tarjeta, nombre, numcte
                INTO vNumTarjeta, vNombreCliente, vNumeroCliente_Capt
            FROM bdicheq:sc_tarjeta 
                WHERE empresa = '001'
            AND numcte = vNumeroCliente
                AND cuenta = pcuenta
            AND status_tar = 'A';    
            
            IF ( vNumTarjeta <> pnum_tarjeta OR vNumTarjeta IS NULL ) THEN
                
                IF (vtransaccion = 1) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF
                
                INSERT INTO intercard:"informix".tbl_corresp_mc_cuentas_cruzadas (t_numtarjeta_transacc, t_numcuenta_transacc, t_num_cliente_transacc,t_numtarjeta_prod, t_num_cliente_prod, t_fecha_registro)
                    VALUES (pnum_tarjeta, pcuenta, vNumeroCliente, vNumTarjeta, vNumeroCliente_Capt, current );
                    
                LET CODIGO_RETORNO = '08012';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF
        
        END IF
        
        
        -- // A los productos de cuenta de debito correspondientes a nomina basica
        ---    debe rechazarse la transaccion porque no puede cobrarse comision
        -- // Circular de Banco de Mexico 22/2010 RMQ 10 976 Corresponsalia OXXO | Cambio de alcance
        SELECT FIRST 1 numcuenta 
            INTO vNumCuenta 
        FROM intercard:tarjetacuenta 
            WHERE numtarjeta = pnum_tarjeta 
                AND numcuenta <> '';
        
        SELECT FIRST 1 prodtarjeta
            INTO vProductoCuentaTarj
        FROM bdicheq:sc_tarjeta
            WHERE cuenta = vNumCuenta
			AND num_tarjeta=pnum_tarjeta;    --SE AGREGA VALIDACION A LA TARJETA PARA TOMAR CORRECTAMENTE EL prodtarjeta

        IF ( CHARINDEX(vProductoCuentaTarj, vProdNoPermitidos) > 0 ) THEN
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08002';
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;

        IF SUBSTR(pcuenta, 1, 2) = '80' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08003';
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
    
        -- // RQM 10 887 - RQM 10 976 Corresponsalia OXXO
        -- // INC 11 1966 Modificacion de las transacciones traspaso entre cuentas efectivas a traves de corresponsales para no permitir cuentas de personas morales
        IF (pcuenta <> '12000002648') THEN
            IF SUBSTR(pcuenta, 1, 4) IN ("1200","1600","2200","2600","9900","9901","2300","2800","2700") THEN
                IF (vtransaccion = 1) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '00100';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
            
            -- // OBTIENE EL VALOR DE LA UDI
            SELECT 
                fecha_hoy
            INTO vfecha_hoy
                FROM bdinteg:"informix".si_fechas
            WHERE empresa = '001';
            
            SELECT 
                FIRST 1 MAX(hora_tpcambio) 
            INTO vhoramax
                FROM bdinteg:"informix".si_tpcambio 
            WHERE empresa = '001' 
                AND divisa = '09'
                    AND fecha_tpcambio = vfecha_hoy;
            
            IF (vhoramax IS NULL OR vhoramax = '') THEN
                SELECT FIRST 1 precio_venta
                  INTO vprecio_udi
                  FROM bdinteg:"informix".si_tpcambio
                 WHERE empresa = '001'
                   AND divisa = '09'
                   AND fecha_tpcambio = vfecha_hoy;
            ELSE
                SELECT FIRST 1 precio_venta
                  INTO vprecio_udi
                  FROM bdinteg:"informix".si_tpcambio
                 WHERE empresa = '001'
                   AND divisa = '09'
                   AND fecha_tpcambio = vfecha_hoy
                   AND hora_tpcambio = vhoramax;
            END IF;
            
            IF (vprecio_udi IS NULL OR vprecio_udi = '') THEN
                
                SELECT FIRST 1 MAX(fecha_tpcambio) 
                        INTO vfecha_tpcambio
                FROM bdinteg:"informix".si_tpcambio
                    WHERE empresa = '001' 
                        AND divisa = '09'
                    AND fecha_tpcambio <= vfecha_hoy;
                
                SELECT 
                       FIRST 1 MAX(hora_tpcambio) 
                  INTO vhoramax
                  FROM bdinteg:"informix".si_tpcambio 
                 WHERE empresa = '001' 
                   AND divisa = '09'
                   AND fecha_tpcambio = vfecha_tpcambio;
            
                IF (vhoramax is null OR vhoramax = '') THEN
                    SELECT 
                           FIRST 1 precio_venta
                      INTO vprecio_udi
                      FROM bdinteg:"informix".si_tpcambio
                     WHERE empresa = '001'
                       AND divisa = '09'
                       AND fecha_tpcambio = vfecha_tpcambio;
                ELSE
                    SELECT 
                           FIRST 1 precio_venta
                      INTO vprecio_udi
                      FROM bdinteg:"informix".si_tpcambio
                     WHERE empresa = '001'
                       AND divisa = '09'
                       AND fecha_tpcambio = vfecha_tpcambio
                       AND hora_tpcambio = vhoramax;
                END IF;
            END IF;
            
            IF (vNumTransaccCorresp IS NULL OR vNumTransaccCorresp = '') THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '08005';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
            
            -- // OBTIENE EL ACUMULADO GENERAL DE LA CUENTA
            SELECT 
                SUM(monto_acum)
            INTO vmtoacumcta
                FROM bdicheq:"informix".sc_acumdiacorresp
            WHERE cuenta = pcuenta;
            
            IF (vmtoacumcta IS NULL) THEN
                LET vmtoacumcta = 0.00;
            END IF;
            
            -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
            LET vmonto_udi = pmto_tot / vprecio_udi;
            
            -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
            LET vmtopagosudi = vmtoacumcta / vprecio_udi;
            
            -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
            LET vlim_cuenta = vmonto_udi + vmtopagosudi;
            
            -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO
            IF (vlim_cuenta > vNumeroMaximoUDIS) THEN
            --IF (vlim_cuenta > vnomaxudis) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '08004';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
            
            -- // OBTIENE EL ACUMULADO DEL CORRESPONSAL
            SELECT 
                monto_acum
            INTO vMontoAcumCorresp
                FROM bdicheq:sc_acumdiacorresp
            WHERE cuenta = pcuenta
                AND corresp = vTipoCorresponsal;
         
            IF vMontoAcumCorresp is null THEN
                LET vMontoAcumCorresp = 0.00;
            END IF;
            
            -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
            LET vmonto_udi = pmto_tot / vprecio_udi;
            
            -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
            LET vMontoPagosCorresp = vMontoAcumCorresp / vprecio_udi;
            
            -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
            LET vMontoPagosCorresp = vmonto_udi + vMontoPagosCorresp;
            
            IF ( vMontoPagosCorresp > vNumeroMaximoUDIS ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '08004';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF; 
        END IF;
    
        -- // OBTIENE EL PORCENTAJE PARA CORRESPONSALES
        SELECT 
               valor
          INTO vporcapcorres
          FROM bdicheq:"informix".sc_param_corresp
         WHERE codparam = '002'
           AND empresa = '001';
        
        -- // OBTIENE MONTO GLOBAL DE LA CAPTACION MENSUAL
        SELECT 
               valor
          INTO vmtoglobcap
          FROM bdicheq:"informix".sc_param_corresp
         WHERE codparam = '001' --004 para oxxo
           AND empresa = '001';
        
        -- // OBTIENE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL
        SELECT 
               valor
          INTO vmtomensacum
          FROM bdicheq:"informix".sc_param_corresp
         WHERE codparam = '003'
           AND empresa = '001';
    
        -- // VALIDA QUE EL MONTO MENSUAL ACUMULADO DEL CORRESPONSAL NO REBASE EL LIMITE PERMITIDO
        IF (pmto_tot + vmtomensacum) < (vmtoglobcap * (vporcapcorres / 100)) THEN
            
            SELECT cuenta
              INTO wcuenta
              FROM bdicheq:"informix".sc_ctas_sin_corresp
             WHERE cuenta = pcuenta;
            
            IF (wcuenta = pcuenta) THEN
                IF (vtransaccion = 1) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                LET CODIGO_RETORNO = '00302';
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
      
            
            EXECUTE PROCEDURE bdicheq:abono_ref( "001", vCentroCostos, pusuario, vNumTransaccCorresp, "0204", 
                    TRIM(pfolio), pcuenta, 0, pmto_tot, pmto_tot, 0, 0, 0, pmoneda, preferencia, pnum_tarjeta, "")
            INTO CODIGO_RETORNO;
            
            -- // EL SP abono_ref regresa solo tres ceros CODIGO_RETORNO = '000'        
            IF (CODIGO_RETORNO = '000') THEN
                -- // El abono ref fue exitoso y es indispensable regresar 5 ceros -00000- al autorizador
                LET CODIGO_RETORNO = '00000';

                -- // INICIALIZA BANDERA DE DEPOSITO EXITOSO
                LET vproceso = '1';

                -- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
                SELECT num_cte, producto
                  INTO vnum_cte, vproducto
                  FROM bdicheq:"informix".sc_maechq
                 WHERE cuenta = pcuenta;

                SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
                  INTO vnombre
                  FROM bdinteg:"informix".si_cliente
                 WHERE numcte = vnum_cte;

                LET vnombre_cte = RPAD(vnombre, 53, ' ');
                
                -- // ACUMULA MONTO EN LA CUENTA DE CHEQUES
                SELECT cuenta
                    INTO vexiste
                FROM bdicheq:"informix".sc_acumdiacorresp
                    WHERE cuenta = pcuenta
                        AND corresp = vTipoCorresponsal;

                IF (vexiste IS NULL OR vexiste = '') THEN
                    INSERT INTO bdicheq:sc_acumdiacorresp 
                        ( cuenta, monto_acum , corresp , transacc)
                    VALUES
                        ( pcuenta, pmto_tot,  vTipoCorresponsal, vNumTransaccCorresp );
                ELSE
                    UPDATE
                           bdicheq:"informix".sc_acumdiacorresp
                       SET monto_acum = monto_acum + pmto_tot
                     WHERE cuenta = pcuenta
                       AND corresp = vTipoCorresponsal;
                END IF;

                -- // ACUMULA MONTO MENSUAL DEL CORRESPONSAL
                UPDATE bdicheq:"informix".sc_param_corresp
                    SET valor = valor + pmto_tot
                WHERE codparam = '003'
                    AND empresa = '001';
     
                
                ---Validar cobro de comision                
                IF ( vHabilitarComision = 'S' ) THEN
                
                    EXECUTE PROCEDURE bdicheq:"informix".sp_cobra_com('001', pcuenta, pfolio, vNumTransaccCorresp)
                        INTO CODIGO_RETORNO;
						---asignacion predeterminada de codigo exitosa
						LET CODIGO_RETORNO = '00000';
                END IF     
				
            ELSE
                IF CODIGO_RETORNO IN('110','106','420','552','959','956','401')THEN
                    LET CODIGO_RETORNO = '00110';
                ELIF CODIGO_RETORNO = '549' THEN
                    LET CODIGO_RETORNO = '00549';
                ELIF CODIGO_RETORNO = '100' THEN
                    LET CODIGO_RETORNO = '00100';
                ELIF CODIGO_RETORNO = '200' THEN
                    LET CODIGO_RETORNO = '00200';
                ELIF CODIGO_RETORNO = '951' THEN
                    LET CODIGO_RETORNO = '00951';
                ELIF CODIGO_RETORNO = '301' THEN
                    LET CODIGO_RETORNO = '00300';
                ELIF CODIGO_RETORNO = '397' THEN ---limite mensual
                    LET CODIGO_RETORNO = '08013';
                ELIF CODIGO_RETORNO = '151' THEN ---limite mensual (cuenta nivel 2)
                    LET CODIGO_RETORNO = '08014';
                ELSE 
                   LET CODIGO_RETORNO = CODIGO_RETORNO;
                END IF;            
                
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                
                RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF
        ELSE
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '00001';
            RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF
    
        IF (vtransaccion = 1) THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        
        --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo(pcuenta, null, null, null, null, null, null, null, 'T', 2) 
    	INTO cCodRetConsSdo,cMensajeRetConsSdo,vSaldoDisp;

        RETURN CODIGO_RETORNO, TRIM(pcuenta), vnombre_cte, vSaldoDisp, vFechaCentralHoy;

    END; 
    
END PROCEDURE
DOCUMENT
'Base de datos: bdicorresp_mc',
'Autor: Armando Garcia Ortiz',
' Fecha de creacion: 27 de julio del 2018',
' Fecha de modificacion: 05 de octubre del 2018',
' Fecha de modificacion: 25 de junio del 2019',
' Descripcion | Se agregan campos en la tabla sc_acumdiacorresp para acumulador el monto por tipo de corresponsal.',
'-RQM 10 976 RQM 10 887',
' Fecha de modificacion: 30 de diciembre del 2019',
' Implementacion para transaccionar con oxxo y mastercard el deposito a cuenta en efectivo.',
' Se agregan validaciones de no permitir transacciones que tienen un producto de cuenta de nomina.',
'-#3',
' Fecha de modificacion: 26 de febrero del 2021',
'-Implementacion de nueva funcionalidad para considerar el corresponsal OXXO y 7Eleven',
'-Creacion de consultas e integracion del procedimiento almacenado sp_corresp_mc_obtener_datos para los parametros.',
'-#4',
' Fecha de modificacion: 23 de marzo del 2021',
'-Implementacion: 1) Rechazar la transaccionalidad del bin 400819.',
'-Cambiar el orden del cobro de comision a los depositos realizados desde el corresponsal',
'-#5',
' Fecha de modificacion: 06 de julio del 2021',
'-Implementacion: Validar la cuenta asignada al cliente para realizar el deposito.',
'-Considerando que la cuenta no este cruzada o mal asignada.',
'-#6',
' Fecha de modificacion: 28 de octubre del 2021',
'-Implementacion: Actualizacion del codigo de retorno 08013 y mensaje de respuesta central cuando la suma de los depositos',
' mensuales excede el limite permitido por cliente.',
'-#7',
' Fecha de modificacion: 14 de diciembre del 2021',
'-Implementacion: Actualizacion del codigo de retorno 08014 y mensaje de respuesta central cuando la suma del deposito',
' mensual excede el limite permitido por cliente y cuenta nivel 2',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 15-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros la cuenta del cliente y el tipo de calculo a realizar',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicorresp_mc',
'VER   : 1.2';


grant  execute on function "informix".sp_corresp_mc_obtener_datos (varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_corresp_revpagotdc_mc (varchar,char,char) to "public" as "informix";
grant  execute on function "informix".sp_corresp_pagotdc_mc (varchar,char,char,char,date,decimal,char,char) to "public" as "informix";
grant  execute on function "informix".sp_corresp_reverso_deposito_mc (varchar,char,char) to "public" as "informix";
revoke  execute on function "informix".sp_corresp_deposito_mc (varchar,char,char,char,char,date,decimal,char,char) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;