CREATE PROCEDURE "informix".sp_retdialide_dia_ant(pEmpresa CHAR(3), dFecha DATE, dFecha_hoy DATE, cUsuario CHAR(10))
    
RETURNING VARCHAR(4), VARCHAR(80), CHAR(11);
    
    DEFINE SQL_ERR              INTEGER;
    DEFINE ISAM_ERR         	INTEGER;
    DEFINE ERROR_INFO       	VARCHAR(80);
    DEFINE P_COD_RET        	VARCHAR(4);
    DEFINE P_MENSAJE        	VARCHAR(80);
    
    DEFINE iStatus          	INTEGER;
    DEFINE cNumcte          	VARCHAR(20);
    DEFINE cCuenta           	VARCHAR(20);
    DEFINE mSaldo_ant        	MONEY(14,2);
    DEFINE mRecaudar         	MONEY(14,2);
    DEFINE mRecaudartot         MONEY(14,2);
    DEFINE mRsaldo_act        	MONEY(14,2);
    DEFINE vcAnioMes            CHAR(6);
    DEFINE vcTipoCta            CHAR(1);
    DEFINE vcCuenta             CHAR(20);
    DEFINE vcEmpresa            CHAR(3);
    DEFINE vcSucursal           CHAR(4);
    DEFINE vcTransaccion        CHAR(4);
    DEFINE vcTransaccSuc        CHAR(4);
    DEFINE vcTransaccSucCred    CHAR(4);
    DEFINE vcDivisa             CHAR(2);
    DEFINE vcNumTarjeta         CHAR(16);
    DEFINE vcTime               CHAR(8);
    DEFINE vcFolioSuc           CHAR(16);
    DEFINE vcCodRetTemp         CHAR(3);
    DEFINE vcTransaccTemp       CHAR(4);
    DEFINE vmMonto              MONEY(14,2);
    DEFINE vcRefRet             CHAR(20);
    DEFINE vcRfc                CHAR(13);
    DEFINE viConsecutivo        INTEGER ;
    DEFINE vtranret             CHAR(4);
    DEFINE vfechoy              DATE;
    DEFINE vsdodisp             MONEY(14,2);
    DEFINE vmontoret            MONEY(14,2);
    DEFINE cont                 INTEGER;
    DEFINE vmImporteCargo       MONEY(14,2);
    DEFINE vdUltimoDiaMes       DATE;
    DEFINE vcStatus2            CHAR(10);
    DEFINE vsdo_cta             MONEY (14, 2);
    DEFINE vsdo_ret             MONEY(14, 2);
    DEFINE vsdo_cong            MONEY(14, 2);
    DEFINE vimp_chq_sbg         MONEY(14,2);
    DEFINE vcTipo               CHAR(1);
    DEFINE vcEsCargoDebito      CHAR(1);
    DEFINE vcEsCargoCredito 	CHAR(1);
    DEFINE vcSecuencia      	CHAR(2);
    DEFINE vcProducto          	CHAR(4);
    DEFINE vmaxsec              SMALLINT;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSaldoSbc               MONEY(14,2);
    DEFINE cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET SQL_ERR    = 0;
    LET ISAM_ERR   = 0;
    LET ERROR_INFO = '';
    LET P_COD_RET  = "000";
    LET P_MENSAJE  = '';

    LET iStatus           = 0;
    LET cNumcte           = '';
    LET cCuenta           = '';
    LET mSaldo_ant        = 0.00;
    LET mRecaudar         = 0.00;
    LET mRecaudartot      = 0.00;
    LET mRsaldo_act       = 0.00;
    LET vcAnioMes         = '';
    LET vcTipoCta         = '';
    LET vcCuenta          = '';
    LET vcEmpresa         = '';
    LET vcSucursal        = '';
    LET vcTransaccion     = '';
    LET vcTransaccSuc     = "0000";
    LET vcTransaccSucCred = "0000";
    LET vcDivisa          = '';
    LET vcNumTarjeta      = '';
    LET vcTime            = '';
    LET vcFolioSuc        = '';
    LET vcCodRetTemp      = '000';
    LET vcTransaccTemp    = '';
    LET vmMonto           = '';
    LET vcRefRet          = '';
    LET vcRfc             = '';
    LET viConsecutivo     = 0;
    LET vtranret          = '';
    LET vfechoy           = '';
    LET vsdodisp          = 0.00;
    LET vmontoret         = 0.00;
    LET cont              = 0;
    LET vmImporteCargo    = 0.00;
    LET vdUltimoDiaMes    = '';
    LET vcStatus2	      = 0;
    LET vsdo_cta          = 0.00;
    LET vsdo_ret          = 0.00;
    LET vsdo_cong         = 0.00;
    LET vimp_chq_sbg      = 0.00;
    LET vcTipo            = "";
    LET vcEsCargoDebito   ='';
    LET vcEsCargoCredito  = '';
    LET vcSecuencia       = "";
    LET vcProducto        = "";
    LET vmaxsec           = 0;
    --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSaldoSbc           		= 0;
    LET cCodRetConsSdo      		= '00000';
    LET cMensajeRetConsSdo  		= '';
    
    BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET    = SQL_ERR;
        LET P_MENSAJE  = ERROR_INFO;

        -- // DESHABILITAR PARA QUE NO PERMIA RETIROS EN EL PRODUCTO INVERSION CRECIENTE
        UPDATE bdicheq:sc_producto
           SET per_retiros = 'U 0'
         WHERE producto = '1100';

        IF SQL_ERR < 0 THEN
            IF vcEsCargoDebito = 'S'  THEN
                ROLLBACK WORK; -- REVERSION DEBITO.

                CALL bdicheq:reversion(vcEmpresa, vcTransaccSuc, cUsuario, vcFolioSuc, 'A')
                RETURNING vcCodRetTemp;

                IF vcCodRetTemp == '000' THEN
                    LET ERROR_INFO = 'REVERSION DE ULTIMO CARGO PARA DEBITO';
                ELSE
                    LET ERROR_INFO = 'NO SE PUDO HACER REVERSION DE ULTIMO CARGO PARA Dï¿½BITO';
                END IF;

                RETURN SQL_ERR, ERROR_INFO, '';
            END IF;

            IF vcEsCargoCredito = 'S' THEN
                ROLLBACK WORK; -- REVERSION CREDITO.
            END IF;

            RETURN SQL_ERR , 'verifique finderr', '';

        END IF;

        IF SQL_ERR <> 0 THEN
            RETURN SQL_ERR, ERROR_INFO, '';
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "sp_retdialide.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;

    LET P_COD_RET = '000';
    LET P_MENSAJE = 'PROCESO EXITOSO';
    LET iStatus   = '';
		
    SELECT ult_dia_mes 
      INTO vdUltimoDiaMes 
      FROM bdinteg:si_fechas
     WHERE empresa = pEmpresa;

    IF dFecha = vdUltimoDiaMes THEN
        -- // Verificar si el proceso de "acu_men_op" se ejecuta antes para poder hacer la retencion.
        SELECT status
          INTO vcStatus2
          FROM bdilide:sl_procesos
         WHERE fech_proceso = dFecha
           AND proceso = "acu_men_op";

        -- // Si proceso es diferente de "acu_men_op" quiere decir que el proceso "acu_men_op" no se ha ejecutado
        IF vcStatus2 = 0  or  vcStatus2 IS NULL THEN
            RETURN "333", '', ''; --- "33333" No se ejecuto el proceso anterior o que fallo en la ejecucion
        END IF;
    ELIF dFecha <> vdUltimoDiaMes THEN
        -- // Si No es fin de mes entonces vamos a validar que el proceso extoptar_c se haya ejecutado anteriormete.
        SELECT status
          INTO vcStatus2
          FROM bdilide:sl_procesos
         WHERE fech_proceso = dFecha
           AND proceso = "extoptar_c";

        -- // Si proceso es diferente de ""extoptar_c" quiere decir que el proceso "extoptar_d" no se ha ejecutado
        IF vcStatus2 = 0 or  vcStatus2 IS NULL THEN
            RETURN "222", '', ''; --- "22222" proceso de extraccion de operaciones en efectivo con tarjeta de credito NO se ha ejecutado o la ejecucion fue insatisfactoria.
        END IF;
    END IF;

    -- // Obtiene y Valida los parametros
    SELECT valor
      INTO vcEmpresa
      FROM bdilide:sl_parametros
     WHERE cve_param = "04"
	   AND desc_valor = "EMPRESA DE CARGO";

    IF vcEmpresa = "" OR vcEmpresa IS NULL THEN
        RETURN "020", 'Parametro 04 de Empresa  No Existe', '';
    ELSE
        SELECT valor
          INTO vcTransaccion
          FROM bdilide:sl_parametros
         WHERE cve_param = "06";

        IF vcTransaccion = "" OR vcTransaccion IS NULL THEN
            RETURN "024", 'Parametro 06 de Transaccion Debito No Existe', '';
        ELSE
            -- // Obtener el nï¿½mero de transaccion
            SELECT valor
              INTO vcTransaccSucCred
              FROM bdilide:sl_parametros
             WHERE cve_param = "09";

            IF vcTransaccSucCred = "" OR vcTransaccSucCred IS NULL THEN
                RETURN "022", 'Parametro 09 Transaccion Para Credito No Existe', '';
            ELSE
                SELECT valor
                  INTO vcDivisa
                  FROM bdilide:sl_parametros
                 WHERE cve_param = "07";

                IF vcDivisa = "" OR vcDivisa IS NULL THEN
                    RETURN "021", 'Parametro 07 de Divisa No Existe', '';
                END IF;
            END IF;
        END IF;
    END IF;

    -- // Verificar si existe el status y checar en que estado se encuentra
    SELECT status
      INTO iStatus
      FROM bdilide:sl_procesos
     WHERE proceso = 'ret_dialde'
       AND fech_proceso = dFecha;

    IF iStatus IS NULL THEN
        INSERT INTO bdilide:sl_procesos VALUES ("ret_dialde", dFecha, 0, cUsuario, CURRENT::DATE);
        
        LET iStatus = 0;
    ELIF iStatus = 1 THEN
        RETURN "999", 'El proceso se Ejecuto Anteriormente', '';
    END IF;

    -- // Borra todo de la tabla sl_pasoctas.
    TRUNCATE TABLE sl_pasoctas;

    -- // Busqueda de Cuentas Pendientes de descontar saldo en Debito, agregar el campo aniomes y tambien agregar a la tabla de paso
    INSERT INTO bdilide:sl_pasoctas(tipo, num_cte, cuenta, saldo_ant, recaudar, saldo_act, aniomes, producto)
    SELECT {+INDEX(bdilide:sl_retlide idx_retcte)}
           'D', chq.num_cte, chq.cuenta, (chq.sdo_actual - chq.sdo_retenido - chq.sdo_cong - chq.saldo_sbc - imp_chq_sbg),
           nvl(imp_arecaudar,0) - nvl(imp_recaudado,0),
           (chq.sdo_actual - chq.sdo_retenido - chq.sdo_cong - chq.saldo_sbc + (chq.lim_sbg_ccc-chq. imp_sbg_ccc)),
           aniomes, chq.producto
      FROM bdicheq:sc_maechq chq,
           bdilide:sl_retlide ret
     WHERE chq.num_cte = ret.num_cte
       AND chq.status_cta <> '2'
       AND chq.sdo_actual > 0
       AND ret.num_cte = chq.num_cte
       AND ret.pendiente = 'S'
       AND (nvl(ret.imp_arecaudar,0) - nvl(ret.imp_recaudado,0)) > 0;

    -- // Busqueda de Cuentas Pendientes de descontar saldo en Credito, agregar el campo aniomes y tambien agregar a la tabla de paso
    INSERT INTO bdilide:sl_pasoctas(tipo, num_cte, cuenta, saldo_ant, recaudar, aniomes, producto)
    SELECT {+INDEX(bdilide:sl_retlide idx_retcte)}
           'C', cred.numcte, cred.num_credito,
           (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) * -1,
           nvl(imp_arecaudar,0) - nvl(imp_recaudado,0), aniomes, cred.num_producto
      FROM bdicred:sd_maecred cred,
           bdicred:sd_maesdos dos,
           bdilide:sl_retlide ret
     WHERE cred.numcte = ret.num_cte
       AND dos.num_credito = cred.num_credito
       AND (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) < 0
       AND ret.num_cte = cred.numcte
       AND ret.pendiente = 'S'
       AND (nvl(ret.imp_arecaudar,0) - nvl(ret.imp_recaudado,0)) > 0;

    UPDATE {+INDEX(sl_pasoctas idx_tipocte)} bdilide:sl_pasoctas
       SET procesado = '0'
     WHERE tipo IN('D','C')
       AND num_cte IS NOT NULL;

    -- // HABILITAR PARA QUE EL PRODUCTO INVERSION CRECIENTE PERMITA RETIROS
    UPDATE bdicheq:sc_producto
       SET per_retiros = 'D 0'
     WHERE producto = '1100';

    -- // Recaudacion Directa Para Coppel
    FOREACH WITH HOLD
        SELECT {+INDEX(bdilide:sl_retespeciales idx_retespcte), +INDEX(bdilide:sl_pasoctas idx_tipocte)}
               especial.num_cte, especial.num_cuenta, pasoctas.recaudar, pasoctas.aniomes
          INTO cNumcte, cCuenta, mRecaudar, vcAnioMes
          FROM bdilide:sl_retespeciales especial,
               bdilide:sl_pasoctas pasoctas
         WHERE especial.num_cte = pasoctas.num_cte
           AND especial.num_cuenta IS NOT NULL
           AND pasoctas.tipo IN('D','C')
           AND pasoctas.num_cte = especial.num_cte

        -- // Obtiene el Saldo actual de la cuenta de debito
        SELECT sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, sucursal, saldo_sbc
          INTO vsdo_cta , vsdo_ret, vsdo_cong, vimp_chq_sbg, vcSucursal, mSaldoSbc
          FROM bdicheq:sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND status_cta <> '2';

        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('', vsdo_cta, vsdo_ret, vsdo_cong, mSaldoSbc, vimp_chq_sbg, null, null, 'F', 1)     
        INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo_ant;

        IF mRecaudar >= mSaldo_ant THEN
            
            LET vmImporteCargo  = TRUNC(mSaldo_ant);
            --- LET mRsaldo_act = 0;
            LET mRecaudar = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de otra cuenta
            
        ELIF mRecaudar < mSaldo_ant THEN
        
            LET vmImporteCargo = mRecaudar;
            LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);
            --- LET mRsaldo_act = mSaldo_ant - vmImporteCargo;
            LET mRecaudar = 0;
            
        END IF;

        IF vmImporteCargo > 0 THEN
        
            -- // Obtener el nï¿½mero de folio para efectuar el cargo
            LET vcFolioSuc = "inform" || replace (substring (current FROM 12  FOR 8 ), ':', '') || vcTransaccion;

            -- // Obtener el nï¿½mero de tarjeta
            SELECT MAX(secuencia)
              INTO vmaxsec
              FROM bdicheq:sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta
              INTO vcNumTarjeta
              FROM bdicheq:sc_tarjeta
             WHERE cuenta = cCuenta
               AND secuencia = vmaxsec
               AND empresa = pEmpresa;

            CALL bdicheq:cargo_ref( vcEmpresa,      -- empresa
                                    vcSucursal,     -- sucursal
                                    cUsuario,       -- usuario
                                    vcTransaccion,  -- transaccion
                                    vcTransaccSuc,  -- transaccion sucursal
                                    vcFolioSuc,	    -- folio
                                    cCuenta,        -- cuenta
                                    0,	            -- cheque
                                    vmImporteCargo, -- monto x cargar
                                    vcDivisa,       -- divisa
                                    '',             -- referencia
                                    vcNumTarjeta,	-- tarjeta
                                    cUsuario )      -- usuario autoriza
            RETURNING vcCodRetTemp, -- codigo de retorno	
                      vtranret,     -- transaccion cargo
                      vfechoy,      -- fecha cargo
                      vsdodisp,     -- saldo disponible
                      vmontoret;    -- monto cargado

            IF TRIM(vcCodRetTemp) = "000" THEN

                BEGIN WORK; 
                
                LET vcEsCargoDebito = 'S';

                -- // Se calcula el consecutivo de la tabla si_detlide
                SELECT NVL(MAX(consecutivo),0) + 1
                  INTO viConsecutivo
                  FROM bdilide:sl_detlide
                 WHERE num_cte = cNumcte
                   AND aniomes = vcAnioMes;

                -- // Obtiene el rfc y la referencia
                SELECT ref_ret, rfc
                  INTO vcRefRet, vcRfc
                  FROM bdilide:sl_retlide
                 WHERE num_cte = cNumcte
                   AND aniomes = vcAnioMes;

                -- // Se inserta un movimiento en la tabla de detalle
                INSERT INTO bdilide:sl_detlide
                (aniomes, num_cte, consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado, user_insert, fecha_insert)
                VALUES
                (vcAnioMes, cNumcte, viConsecutivo, vcRfc, vcRefRet, cCuenta, dFecha_hoy, vmImporteCargo, cUsuario, dFecha);

                -- // Actualiza el monto que se recauda en la tabla de recaudaciones ide
                UPDATE bdilide:sl_retlide
                   SET imp_recaudado = NVL(imp_recaudado,0.0) + vmImporteCargo
                 WHERE aniomes = vcAnioMes
                   AND num_cte = cNumcte;

                UPDATE {+INDEX(sl_pasoctas idx_tipocte)} bdilide:sl_pasoctas
                   SET recaudar = (recaudar - ROUND(vmImporteCargo - 0.01))
                 WHERE tipo IN('D','C')
                   AND num_cte = cNumcte;

                IF mRecaudar = 0 THEN
                    -- // Actualiza la tabla de recaudaciones cambiandole el flag de pendiente
                    UPDATE bdilide:sl_retlide
                       SET pendiente = 'N'
                     WHERE aniomes = vcAnioMes
                       AND num_cte = cNumcte;

                    UPDATE {+INDEX(sl_pasoctas idx_tipocte)} bdilide:sl_pasoctas
                       SET procesado = '1'
                     WHERE tipo IN('D','C')
                       AND num_cte = cNumcte;
                ELSE
                    UPDATE {+INDEX(sl_pasoctas idx_tipocte)} bdilide:sl_pasoctas
                       SET procesado = '1'
                     WHERE tipo IN('D','C')
                       AND num_cte = cNumcte
                       AND cuenta = cCuenta;
                END IF;

                COMMIT WORK;
                
                LET vcEsCargoDebito = '';

            ELSE

                LET mRecaudar = mRecaudar + vmImporteCargo;
                
            END IF;
        END IF;

    END FOREACH; -- // FIN FOREACH RECAUDACION DIRECTA A COPPEL.

    -- // Se le asigna una secuencia al producto
    FOREACH
        SELECT valor, desc_valor
          INTO vcSecuencia, vcProducto
          FROM bdilide:sl_parametros
         WHERE cve_param = "15"
         ORDER BY valor DESC

        UPDATE {+INDEX(sl_pasoctas idx_tipocte)} bdilide:sl_pasoctas
           SET secuencia = vcSecuencia
         WHERE tipo IN('D','C')
           AND num_cte IS NOT NULL
           AND producto = vcProducto;
    END FOREACH;

    -- // CICLO para recaudar por cliente.
    FOREACH WITH HOLD
        SELECT {+INDEX(sl_pasoctas idx_tipocte)}
               DISTINCT aniomes, recaudar, num_cte
          INTO vcAnioMes, mRecaudar, cNumcte
          FROM bdilide:sl_pasoctas
         WHERE tipo IN('D','C')
           AND num_cte IS NOT NULL
           AND procesado = '0'

        -- // Obtiene el a recaudar por cada uno de los clientes en la tabla
        LET mRecaudartot = mRecaudar;

        -- // Ciclo para intentar recaudar en cada cuenta de dï¿½bito del cliente
        FOREACH WITH HOLD
            SELECT {+INDEX(sl_pasoctas idx_tipocte)} cuenta, tipo
              INTO cCuenta, vcTipo	
              FROM bdilide:sl_pasoctas  
             WHERE tipo IN('D','C')
               AND num_cte = cNumcte
             ORDER BY secuencia DESC, saldo_ant DESC

            LET vmImporteCargo = 0;

            IF vcTipo = "D" THEN
                -- // Obtiene el Saldo actual de la cuenta de debito
                SELECT sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, sucursal, saldo_sbc
                  INTO vsdo_cta , vsdo_ret, vsdo_cong, vimp_chq_sbg, vcSucursal, mSaldoSbc
                  FROM bdicheq:sc_maechq
                 WHERE empresa = pEmpresa
                   AND cuenta = cCuenta;

                --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
                EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('', vsdo_cta, vsdo_ret, vsdo_cong, mSaldoSbc, vimp_chq_sbg, null, null, 'F', 1)     
                INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo_ant;

                IF mRecaudar >= mSaldo_ant THEN
                
                    LET vmImporteCargo = TRUNC(mSaldo_ant);
                    LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;
                    LET mRecaudar      = mRecaudar - vmImporteCargo; --- Pendiente a recaudar para que se lo cobre de otra cuenta
                    
                ELIF mRecaudar < mSaldo_ant THEN
                
                    LET vmImporteCargo = mRecaudar;
                    LET vmImporteCargo = ROUND(vmImporteCargo - 0.01);
                    LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;
                    LET mRecaudar      = 0;
                    
                END IF;

                IF vmImporteCargo > 0  then

                    -- // Obtener el nï¿½mero de tarjeta
                    SELECT MAX(secuencia)
                      INTO vmaxsec
                      FROM bdicheq:sc_tarjeta
                     WHERE empresa = pEmpresa
                       AND cuenta = cCuenta
                       AND tipo_tarjeta = "T";

                    SELECT num_tarjeta
                      INTO vcNumTarjeta
                      FROM bdicheq:sc_tarjeta
                     WHERE empresa = pEmpresa
                       AND cuenta = cCuenta
                       AND secuencia = vmaxsec;
                    
                    -- // Obtener el nï¿½mero de folio para efectuar el cargo
                    LET vcFolioSuc = "inform" || replace(substring(current FROM 12  FOR 8), ':', '') || vcTransaccion;
                
                    CALL bdicheq:cargo_ref( vcEmpresa,       -- empresa
                                            vcSucursal,      -- sucursal
                                            cUsuario,        -- usuario
                                            vcTransaccion,   -- transaccion
                                            vcTransaccSuc,   -- transaccion sucursal
                                            vcFolioSuc,      -- folio
                                            cCuenta,         -- cuenta
                                            0,               -- cheque
                                            vmImporteCargo,  -- monto x cargar
                                            vcDivisa,        -- divisa
                                            '',              -- referencia
                                            vcNumTarjeta,    -- tarjeta
                                            cUsuario )       -- usuario autoriza
                    RETURNING vcCodRetTemp, -- codigo de retorno
                              vtranret,     -- transaccion cargo 
                              vfechoy,      -- fecha cargo
                              vsdodisp,     -- saldo dsponible
                              vmontoret;    -- monto cargado

                    IF vcCodRetTemp = "000" THEN

                        BEGIN WORK;
                        
                        LET vcEsCargoDebito = 'S';

                        -- // Se calcula el consecutivo de la tabla si_detlide
                        SELECT NVL(MAX(consecutivo),0) + 1
                          INTO viConsecutivo
                          FROM bdilide:sl_detlide
                         WHERE num_cte = cNumcte
                           AND aniomes = vcAnioMes;

                        -- // Obtiene el rfc y la referencia
                        SELECT ref_ret, rfc
                          INTO vcRefRet, vcRfc
                          FROM bdilide:sl_retlide
                         WHERE num_cte = cNumcte
                           AND aniomes = vcAnioMes;

                        -- // Se inserta un movimiento en la tabla de detalle
                        INSERT INTO bdilide:sl_detlide
                        (aniomes, num_cte, consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado, user_insert, fecha_insert)
                        VALUES
                        (vcAnioMes, cNumcte, viConsecutivo, vcRfc, vcRefRet, cCuenta, dFecha_hoy, vmImporteCargo, cUsuario, dFecha);

                        -- // Actualiza el monto que se recauda en la tabla de recaudaciones ide
                        UPDATE bdilide:sl_retlide
                           SET imp_recaudado = NVL(imp_recaudado,0.0) + vmImporteCargo
                         WHERE aniomes = vcAnioMes
                           AND num_cte = cNumcte;

                        IF mRecaudar = 0 THEN
                            -- // Actualiza la tabla de recaudaciones cambiandole el flag de pendiente
                            UPDATE bdilide:sl_retlide
                               SET pendiente = 'N'
                             WHERE aniomes = vcAnioMes
                               AND num_cte = cNumcte;
                        END IF;

                        COMMIT WORK;
                        
                        LET vcEsCargoDebito = '';
                        
                    ELSE
                        
                        LET mRsaldo_act = mSaldo_ant;
                        LET mRecaudar = mRecaudar + vmImporteCargo;
                        
                    END IF;
                END IF;
                
            ELIF vcTipo = "C" THEN

                -- // Obtiene el Saldo actual de la cuenta de crï¿½dito
                SELECT (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) * -1
                  INTO mSaldo_ant
                  FROM bdicred:sd_maesdos dos
                 WHERE dos.num_credito = cCuenta;
                
                IF mSaldo_ant < 0 THEN
                    LET mSaldo_ant = 0;
                END IF;
                
                LET vmImporteCargo = 0;
                
                IF mRecaudar > mSaldo_ant THEN
                    
                    IF mSaldo_ant >= 1 THEN                    
                        LET vmImporteCargo = TRUNC(mSaldo_ant);
                        LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;
                        LET mRecaudar      = mRecaudar - vmImporteCargo;
                    ELSE
                        LET vmImporteCargo = 0;
                        LET mRsaldo_act    = mSaldo_ant;
                        LET mRecaudar      = mRecaudar;
                    END IF;
                    
                ELIF mRecaudar <= mSaldo_ant THEN
                
                    LET vmImporteCargo = TRUNC(mRecaudar);
                    LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;
                    LET mRecaudar      = mRecaudar - vmImporteCargo;
                    
                END IF;
                
                { ***************************************************
                IF mRecaudar >= mSaldo_ant THEN
                
                    LET vmImporteCargo = mSaldo_ant;
                    LET mRsaldo_act    = 0;
                    LET mRecaudar      = mRecaudar - mSaldo_ant;

                ELIF mRecaudar < mSaldo_ant THEN

                    LET vmImporteCargo = mRecaudar;
                    LET mRsaldo_act    = mSaldo_ant - vmImporteCargo;
                    LET mRecaudar      = 0;
                    
                END IF;
                *************************************************** }
                
                --- LET vmImporteCargo = ROUND(vmImporteCargo);

                IF vmImporteCargo > 0  THEN
                
                    -- // Obtener el nï¿½mero de tarjeta
                    SELECT num_tarjeta
                      INTO vcNumTarjeta
                      FROM bdicred:sd_tarjeta
                     WHERE num_credito = cCuenta
                       AND numcte = cNumcte
                       AND tipo_tarjeta = 'T'
                       AND status_tar = 'A';

                    -- // Obtener la Sucursal donde se dio de alta la cuenta
                    SELECT sucursal
                      INTO vcSucursal
                      FROM bdicred:sd_maecred
                     WHERE num_credito = cCuenta
                       AND numcte = cNumcte;

                    -- // Obtener el nï¿½mero de folio para efectuar el cargo
                    LET vcFolioSuc = "inform" || replace(substring(current FROM 12  FOR 8), ':', '') || vcTransaccSucCred;

                    -- // Obtiene el rfc y la referencia
                    SELECT ref_ret, rfc
                      INTO vcRefRet, vcRfc
                      FROM bdilide:sl_retlide
                     WHERE num_cte = cNumcte
                       AND aniomes = vcAnioMes;
                    
                    CALL bdicred:cargo_cred( vcEmpresa,         -- empresa
                                             cCuenta,           -- cuenta
                                             vcSucursal,        -- sucursal
                                             cUsuario,          -- usuario
                                             vcTransaccSucCred, -- transaccion
                                             vmImporteCargo,    -- monto x cargar
                                             vcFolioSuc,        -- folio
                                             vcNumTarjeta,      -- tarjeta
                                             0.00,              -- monto dolares
                                             0.00,              -- tipo de cambio
                                             dFecha_hoy,        -- fecha
                                             vcRefRet,          -- referencia
                                             '',                -- ref comercio
                                             '' )               -- ref 23
                    RETURNING vcCodRetTemp; -- codigo de retorno

                    IF vcCodRetTemp = "000" THEN

                        LET vcEsCargoCredito = 'S';
                        
                        BEGIN WORK;

                        -- // Se calcula el consecutivo de la tabla si_detlide
                        SELECT NVL(MAX(consecutivo),0)+1
                          INTO viConsecutivo
                          FROM bdilide:sl_detlide
                         WHERE num_cte = cNumcte
                           AND aniomes = vcAnioMes;

                        -- // Se inserta un movimiento en la tabla de detalle
                        INSERT INTO bdilide:sl_detlide
                        (aniomes, num_cte, consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado, user_insert, fecha_insert)
                        VALUES
                        (vcAnioMes, cNumcte, viConsecutivo, vcRfc, vcRefRet, cCuenta, dFecha_hoy, vmImporteCargo, cUsuario, dFecha);

                        -- // Actualiza el monto que se recauda en la tabla de recaudaciones ide
                        UPDATE bdilide:sl_retlide
                           SET imp_recaudado = NVL(imp_recaudado,0.0) + vmImporteCargo
                         WHERE aniomes = vcAnioMes
                           AND num_cte = cNumcte;

                        IF mRecaudar = 0 THEN
                            -- // Actualiza la tabla de recaudaciones cambiandole el flag de pendiente
                            UPDATE bdilide:sl_retlide
                               SET pendiente = 'N'
                             WHERE aniomes = vcAnioMes
                               AND num_cte = cNumcte;
                        END IF;

                        COMMIT WORK;
                        
                        LET vcEsCargoCredito = '';

                    ELSE

                        LET mRsaldo_act = mSaldo_ant;
                        LET mRecaudar = mRecaudar + vmImporteCargo;
                        
                    END IF;
                END  IF;
            END IF;
        END FOREACH;
    END FOREACH;

    -- // DESHABILITAR PARA QUE NO PERMIA RETIROS EN EL PRODUCTO INVERSION CRECIENTE
    UPDATE bdicheq:sc_producto
       SET per_retiros = 'U 0'
     WHERE producto = '1100';

    IF P_COD_RET = "000" THEN
    
        CALL bdilide:spslgenreporteentero(vcEmpresa, dFecha, cUsuario)
        RETURNING P_COD_RET, P_MENSAJE;

        IF P_COD_RET = "000" THEN
        
            --- CALL bdilide:sp_repRecaudacion(dFecha, cUsuario) RETURNING P_COD_RET; [SE DESHABILITA LLAMADA A GENERACION DE REPORTE]
            
            IF P_COD_RET = "000" THEN
                UPDATE bdilide:sl_procesos
                   SET status = "1"
                 WHERE fech_proceso = dFecha
                   AND proceso = "ret_dialde";

                -- // Control de Procesos
                INSERT INTO bdinteg:sx_contproc
                (empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret)
                VALUES
                (pEmpresa, 'Redilide', dFecha, '23', 'F', cUsuario, current hour to fraction(3), current hour to fraction(3), P_COD_RET);

                LET P_MENSAJE = "PROCESO FINALIZO EXITOSAMENTE.";
            ELSE
                -- // PONER TODOS LOS PROCESOS ENVOLUCRADOS EN ESTADO CERO PARA INDICAR EL ï¿½XITO NO OBTENIDO
                UPDATE bdilide:sl_procesos
                   SET status = "0"
                 WHERE fech_proceso = dFecha
                   AND proceso  = "ret_dialde";

                UPDATE bdilide:sl_procesos
                   SET status = "0"
                 WHERE fech_proceso = dFecha
                   AND proceso  = "rep_entero";

                UPDATE bdilide:sl_procesos
                   SET status = "0"
                 WHERE fech_proceso = dFecha
                   AND proceso  = "repdialide";

                RETURN P_COD_RET, 'VALOR DE RETORNO POR SP_REPRECAUDACION ', '';
            END IF;
        ELSE
            -- // PONER TODOS LOS PROCESOS ENVOLUCRADOS EN ESTADO CERO PARA INDICAR EL ï¿½XITO NO OBTENIDO
            UPDATE bdilide:sl_procesos
               SET status = "0"
             WHERE fech_proceso = dFecha
               AND proceso  = "ret_dialde";

            UPDATE bdilide:sl_procesos
               SET status = "0"
             WHERE fech_proceso = dFecha
               AND proceso  = "rep_entero";

            UPDATE bdilide:sl_procesos
               SET status = "0"
             WHERE fech_proceso = dFecha
               AND proceso  = "repdialide";

            RETURN P_COD_RET, P_MENSAJE, '';
        END IF;
    END IF;

    RETURN P_COD_RET,P_MENSAJE,'' ;

    END;

END PROCEDURE
