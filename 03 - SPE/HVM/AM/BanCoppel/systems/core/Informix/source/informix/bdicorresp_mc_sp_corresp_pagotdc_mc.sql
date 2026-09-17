CREATE PROCEDURE "informix".sp_corresp_pagotdc_mc( pNombreCorresponsal VARCHAR(9), --- pNombreCorresponsal - Valor recibido del autorizador 
                                             pusuario CHAR(8),       --- USUARIO
                                             pfolio CHAR(16),        --- FOLIO SUC
                                             pnum_tarjeta CHAR(16),  --- TARJETA DE CREDITO
                                             pfecha DATE,            --- FECHA
                                             pmto_tot DECIMAL(14,2), --- MONTO
                                             pmoneda CHAR(3),        --- MONEDA
                                             preferencia CHAR(40) )  --- REFERENCIA

RETURNING CHAR(5) as CODIGO_RETORNO,  --- CODIGO DE RETORNO          
          CHAR(53) as vNombreCliente, --- NOMBRE CORTO DEL CLIENTE
          MONEY(14,2) as vSaldoDisp, --- Saldo Disponible
          DATE as vFechaCentralHoy;
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    DEFINE vNombreCliente CHAR(53);
    DEFINE vNumBoletoInicial CHAR(9);
    DEFINE vNumBoletoFinal CHAR(9);
    DEFINE vFechaCentralHoy DATE;
    
    DEFINE SQL_ERR      INTEGER;
    DEFINE ISAM_ERR     INTEGER;
    DEFINE ERROR_INFO   VARCHAR(80);
    DEFINE vcodret1     CHAR(3);
    DEFINE vcodret2     CHAR(5);
    
    DEFINE vtarjeta         CHAR(16);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE vprecio_udi      DECIMAL(14,6);
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6);
    DEFINE vmtopagosudi     DECIMAL(18,6);
    DEFINE vlim_cuenta      DECIMAL(18,6);
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vremanente       DECIMAL(14,2);
    DEFINE vintmorcob       DECIMAL(14,2);
    DEFINE vintvencob       DECIMAL(14,2);
    DEFINE vcapvencob       DECIMAL(14,2);
    DEFINE vintvigcob       DECIMAL(14,2);
    DEFINE vcapvigcob       DECIMAL(14,2);
    DEFINE vimpcob          DECIMAL(14,2);
    DEFINE vcomcob          DECIMAL(14,2);
    DEFINE vsegcob          DECIMAL(14,2);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vtrancorrespcred CHAR(4);    
    DEFINE vfechamax        DATE;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE vproducto        CHAR(4);
    DEFINE vexiste_prod     SMALLINT;
    DEFINE vcanal           INTEGER;
    DEFINE vtpo_oper        INTEGER;
    DEFINE vnum_cte         CHAR(9);
    DEFINE vcodret3         CHAR(6);
    DEFINE vmensaje         CHAR(80);
    DEFINE vnuminiboleto    INTEGER;
    DEFINE vnumfinboleto    INTEGER;   
    DEFINE vnombre          CHAR(53);
    DEFINE vnombre_cte      CHAR(53);
    DEFINE vno_ini_boleto   CHAR(9);
    DEFINE vno_fin_boleto   CHAR(9);
    DEFINE vprod            INTEGER;
    DEFINE vproceso         CHAR(1);
    DEFINE vnuminiboleto2   CHAR(9);
    DEFINE vnumfinboleto2   CHAR(9);
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vSaldoDisp     MONEY(14,2);
    DEFINE vProdNoPermitidos  CHAR(80);
    DEFINE vProductoCreditoTarj  CHAR(4);
    DEFINE vTipoCorresponsal    SMALLINT;
    DEFINE vNumCredito      CHAR(13);
    DEFINE TIPO_CREDITO CHAR(1);    
    DEFINE vNumeroMaximoUDIS VARCHAR(10);
    DEFINE vNumTransaccCorresp CHAR(4);
    DEFINE vCentroCostos CHAR(4);
    DEFINE vCorrespDisponible CHAR(1);
    DEFINE vCodigoFun  VARCHAR(5); 
    DEFINE vHabilitarComision  CHAR(1); 
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumeroCliente_Cred VARCHAR(20);
    DEFINE vNumTarjeta VARCHAR(16);
    DEFINE vValidarCtaCruzada CHAR(1);
    
    LET SQL_ERR  = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = NULL;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    
    LET vtarjeta         = '';
    LET vnum_credito     = '';
    LET vstatus_tar      = '';
    LET vprecio_udi      = 0.00;
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vtransaccion     = 0;
    LET vremanente       = 0.00;
    LET vintmorcob       = 0.00;
    LET vintvencob       = 0.00;
    LET vcapvencob       = 0.00;
    LET vintvigcob       = 0.00;
    LET vcapvigcob       = 0.00;
    LET vimpcob          = 0.00;
    LET vcomcob          = 0.00;
    LET vsegcob          = 0.00;
    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vtrancorrespcred = '';
    LET vfechamax        = '';
    LET vhoramax         = '';
    LET vproducto       = '';
    LET vexiste_prod    = 0;
    LET vcanal          = 0;
    LET vtpo_oper       = 0;
    LET vnum_cte        = '';
    LET vcodret3        = '000000';
    LET vmensaje        = '';
    LET vnuminiboleto   = 0;
    LET vnumfinboleto   = 0;
    LET vnombre         = '';
    LET vnombre_cte     = '                                                     ';
    LET vno_ini_boleto  = '000000000';
    LET vno_fin_boleto  = '000000000';
    LET vprod           = 0;
    LET vproceso        = '0';
    LET vnuminiboleto2  = '000000000';
    LET vnumfinboleto2  = '000000000';
    LET vind_cierre     = '0';
    LET vind_dispon     = '0';
    
    LET CODIGO_RETORNO = '00000';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vFechaCentralHoy = '';
    LET vSaldoDisp = 0.00;
    LET vProdNoPermitidos = '';
    LET vProductoCreditoTarj = '';
    LET vNumCredito  = '';
    LET TIPO_CREDITO = 'C';
    LET vProdNoPermitidos = NULL;
    LET vNumeroMaximoUDIS = NULL;
    LET vNumTransaccCorresp = NULL;
    LET vCentroCostos = NULL;
    LET vTipoCorresponsal = '';
    LET vCorrespDisponible = '';
    LET vCodigoFun = '00000';
    LET vHabilitarComision = NULL;
    LET vNumeroCliente = '';
    LET vNumeroCliente_Cred = '';
    LET vNumTarjeta = '';
    LET vValidarCtaCruzada = '';
    
    BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_corresp_pagotdc_mc_"||LOWER(TRIM(pNombreCorresponsal))||'.err' WITH APPEND;
            TRACE ON;            
            
            IF SQL_ERR <> 0 THEN
                LET CODIGO_RETORNO = SQL_ERR;
                IF ( vtransaccion = 1 ) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF
                IF ( vproceso = '1' ) THEN
                    LET CODIGO_RETORNO = '00000';
                ELSE
                    LET CODIGO_RETORNO = SQL_ERR;
                END IF;
                
                RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
        END EXCEPTION;
    
        ON EXCEPTION IN (-535)
            LET vtransaccion = 1;
        END EXCEPTION WITH resume;
    
        --SET DEBUG FILE TO RUTA_ORIGEN||'ejecucion_sp_corresp_pagotdc_mc_'||LOWER(TRIM(pNombreCorresponsal))||'.out';
        --TRACE ON;
            
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        -- // Obtiene fechas del sistema de credito
        SELECT fecha_hoy, ind_cierre, ind_disponible
          INTO vFechaCentralHoy, vind_cierre, vind_dispon
          FROM bdicred:sd_fechas 
         WHERE empresa = '001';
         
        IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08010';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF
    
    
        ---Obtener los valores necesarios para aprobar o rechazar la transaccionalidad por corresponsal
        EXECUTE PROCEDURE bdicorresp_mc:"informix".sp_corresp_mc_obtener_datos( pNombreCorresponsal, TIPO_CREDITO )        
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS, vNumTransaccCorresp, 
                    vCentroCostos, vTipoCorresponsal, vCodigoFun, vHabilitarComision, vCorrespDisponible;
        
        IF (vCorrespDisponible IS NULL OR vCorrespDisponible = '0'  OR CODIGO_RETORNO <> '00000') THEN
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF    
            
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF
        

        -- //Valores del corresponsal    
        IF (vCentroCostos IS NULL OR vCentroCostos = '' OR LENGTH(vCentroCostos) <> 4 ) OR
           (pusuario IS NULL OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
           (pfolio IS NULL OR pfolio = '' OR LENGTH(pfolio) < 15) OR
           (pnum_tarjeta IS NULL OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) OR
           (pfecha IS NULL OR pfecha = '') OR
           (pmto_tot IS NULL OR pmto_tot <= 0.00) OR
           (vCodigoFun IS NULL OR vCodigoFun = '' OR vCodigoFun = '00000' OR LENGTH(vCodigoFun) < 3 ) OR
           (vNumeroMaximoUDIS IS NULL OR TRIM(vNumeroMaximoUDIS) = '0') OR
           (pmoneda IS NULL OR pmoneda = '' OR LENGTH(pmoneda) <> 03) OR
           (vHabilitarComision IS NULL) THEN
           
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08000';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
    
        IF LENGTH(pmoneda) = 03 THEN
            LET pmoneda = pmoneda[2,3]; 
        END IF;
        
        -- // VALIDA DATOS DEL CREDITO
        SELECT num_tarjeta, num_credito, status_tar
          INTO vtarjeta, vnum_credito, vstatus_tar
          FROM bdicred:sd_tarjeta
         WHERE num_tarjeta = pnum_tarjeta
           AND empresa = '001';
        
        IF vtarjeta is null THEN
            LET vtarjeta = ' ';
        END IF;
        
        IF vnum_credito is null THEN
            LET vnum_credito = ' ';
        END IF;
    
        IF vstatus_tar is null THEN
            LET vstatus_tar = ' ';
        END IF;
           
        IF (vtarjeta <> pnum_tarjeta) OR (vstatus_tar <> 'A')  THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08001';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
    
        IF (vnum_credito is null OR vnum_credito = '') THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08001';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF;
    
        --Validar si la cuenta del deposito esta correctamente asignada, o bien, esta cruzada con otro numero de tarjeta.
        SELECT valor
            INTO vValidarCtaCruzada
        FROM bdicheq:sc_param
            WHERE codparam = 'validarctascruz_cred';
        
        IF ( vValidarCtaCruzada  = 'S' ) THEN
            SELECT numcliente
                INTO vNumeroCliente
            FROM intercard:tarjeta 
                WHERE numtarjeta = pnum_tarjeta;        
            
            SELECT num_tarjeta, nombre, numcte
                INTO vNumTarjeta, vNombreCliente, vNumeroCliente_Cred
            FROM bdicred:sd_tarjeta 
                WHERE empresa = '001'
            AND numcte = vNumeroCliente
                AND num_tarjeta = pnum_tarjeta
            AND status_tar = 'A';
            
            IF ( vNumTarjeta <> pnum_tarjeta OR vNumTarjeta IS NULL ) THEN
                
                IF (vtransaccion = 1) THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                
                INSERT INTO intercard:"informix".tbl_corresp_mc_cuentas_cruzadas (t_numtarjeta_transacc, t_numcuenta_transacc, t_num_cliente_transacc,t_numtarjeta_prod, t_num_cliente_prod, t_fecha_registro)
                    VALUES (pnum_tarjeta, vnum_credito, vNumeroCliente, vNumTarjeta, vNumeroCliente_Cred, current );
                    
                LET CODIGO_RETORNO = '08012';            
                RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF
        
        END IF
        
        ---A los productos de cuenta de credito basica correspondientes a nomina debe rechazarse la transaccion porque no puede cobrarse comision
        ---Circular de Banco de Mexico 22/2010 RMQ 10 976 Corresponsalia OXXO | Cambio de alcance
        SELECT FIRST 1 numcuenta 
            INTO vNumCredito 
        FROM intercard:tarjetacuenta 
            WHERE numtarjeta = pnum_tarjeta
        AND numcuenta <> '';
            
        SELECT FIRST 1 num_producto
            INTO vProductoCreditoTarj
        FROM bdicred:sd_maecred
            WHERE num_credito = vnum_credito;

        IF ( CHARINDEX(vProductoCreditoTarj, vProdNoPermitidos) > 0 ) THEN
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08002';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF

        -- // OBTIENE EL VALOR DE LA UDI
        SELECT fecha_hoy
          INTO vfecha_hoy
          FROM bdinteg:si_fechas
         WHERE empresa = '001';
           
        SELECT FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_hoy;
   
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_hoy;
        ELSE
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_hoy
               AND hora_tpcambio = vhoramax;
        END IF;
       
        IF vprecio_udi is null OR vprecio_udi = '' THEN
            SELECT FIRST 1 MAX(fecha_tpcambio) 
              INTO vfecha_tpcambio
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001' 
               AND divisa = '09'
               AND fecha_tpcambio <= vfecha_hoy;
               
            SELECT FIRST 1 MAX(hora_tpcambio) 
              INTO vhoramax
              FROM bdinteg:si_tpcambio 
             WHERE empresa = '001' 
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
               
            IF vhoramax is null OR vhoramax = '' THEN
                SELECT FIRST 1 precio_venta
                  INTO vprecio_udi
                  FROM bdinteg:si_tpcambio
                 WHERE empresa = '001'
                   AND divisa = '09'
                   AND fecha_tpcambio = vfecha_tpcambio;
            ELSE
                SELECT FIRST 1 precio_venta
                  INTO vprecio_udi
                  FROM bdinteg:si_tpcambio
                 WHERE empresa = '001'
                   AND divisa = '09'
                   AND fecha_tpcambio = vfecha_tpcambio
                   AND hora_tpcambio = vhoramax;
            END IF
        END IF
    
        -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
        LET vmonto_udi = pmto_tot / vprecio_udi;    

        -- // VALIDA QUE EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO
        IF (vmonto_udi >= vNumeroMaximoUDIS) THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET CODIGO_RETORNO = '08004';
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
        END IF
    
        -- // OBTIENE EL ACUMULADO DEL DIA DEL CREDITO
        SELECT SUM(monto)
          INTO vmtoacumcta
          FROM bdicred:sd_movdia
         WHERE empresa = '001'
           AND num_credito = vnum_credito
           AND fecha_mov = pfecha
           AND reversado <> 'S'
           AND sucursal = vCentroCostos
           --AND codigo_fun = '701'
           AND codigo_fun = vCodigoFun
           AND codigo_ref = 1;
     
        IF vmtoacumcta IS NULL THEN
            LET vmtoacumcta = 0.00;
        END IF;
       
        -- // CONVIERTE ACUMULADO DEL CREDITO EN UDIS
        LET vmtopagosudi = vmtoacumcta / vprecio_udi;
        
        -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DEL CREDITO
        LET vlim_cuenta = vmonto_udi + vmtopagosudi;
    
        ---
        LET pfolio = TRIM(pfolio);
        
        -- // VALIDA QUE EL ACUMULADO DEL CREDITO NO REBASE EL LIMITE PERMITIDO
        IF (vlim_cuenta < vNumeroMaximoUDIS) THEN
           
            -- // APLICA TRANSACCION DE PAGO EN EL CREDITO
            EXECUTE PROCEDURE bdicred:principal("001", vnum_credito, 1, pmto_tot, pusuario, vCentroCostos, pfolio, vNumTransaccCorresp)
                INTO vcodret2, vremanente, vintmorcob, vintvencob, vcapvencob, vintvigcob, vcapvigcob, vimpcob, vcomcob, vsegcob;
          
            IF vcodret2 = '000' THEN 
                LET CODIGO_RETORNO = '00000';
                LET vproceso = '1';               
                
                -- // ACTUALIZA REFERENCIA EN LAS TRANSACCIONES
                UPDATE bdicred:sd_movdia
                   SET referencia = preferencia
                 WHERE empresa = '001'
                   AND num_credito = vnum_credito
                   AND fecha_mov = pfecha
                   AND reversado <> 'S'
                   AND sucursal = vCentroCostos
                   AND codigo_fun = vCodigoFun
                   --AND codigo_fun = '701'
                   AND codigo_ref = 1
                   AND folio_suc = pfolio;
                   
                -- // OBTIENE NOMBRE CORTO DEL CLIENTE Y PRODUCTO
                SELECT numcte, num_producto
                  INTO vnum_cte, vproducto
                  FROM bdicred:"informix".sd_maecred
                 WHERE num_credito = vnum_credito
                   AND empresa = '001';
                   
                SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
                  INTO vnombre
                  FROM bdinteg:"informix".si_cliente
                 WHERE numcte = vnum_cte;
                 
                LET vnombre_cte = RPAD(vnombre, 53, ' ');
                
            ELSE 
                IF vcodret2 = '008' THEN
                    LET CODIGO_RETORNO = '00008'; ---El crédito no existe
                ELIF vcodret2 = '301' THEN
                    LET CODIGO_RETORNO = '08009';
                ELIF vcodret2 = '110' OR vcodret2 = '00100' OR  vcodret2 = '100' OR   vcodret2 = '099' THEN
                    LET CODIGO_RETORNO = '00301';
                ELIF vcodret2 = '1144' THEN --// VALIDACION LIMITE DE SALDO A FAVOR
                    LET CODIGO_RETORNO = '08008';
                ELSE
                    LET CODIGO_RETORNO = vcodret2;
                END IF                
                
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                
                RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            END IF;
        ELSE
        
            IF ( vtransaccion = 1 ) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            LET CODIGO_RETORNO = '08004';
            
            RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
            
        END IF;
    
        SELECT (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)) as saldo_disponible 
            INTO vSaldoDisp
        FROM bdicred:sd_maesdos 
            WHERE num_credito = vnum_credito;
    
        IF (vtransaccion = 1) THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
    
        RETURN CODIGO_RETORNO, vnombre_cte, vSaldoDisp, vFechaCentralHoy;
    
    END;

END PROCEDURE
DOCUMENT
'Base de datos: bdicorresp_mc',
'Autor: Armando García Ortiz',
'#1',
'Fecha de creacion: 27 de julio del 2018',
'RQM 10 976 RQM 10 887',
'Fecha de a: 30 de diciembre del 2019',
'Implementacion para transaccionar con oxxo y mastercard el pago de tarjeta de credito.',
'Se agregan validaciones de no permitir transacciones que tienen un producto de cuenta de nomina.',
'Se actualiza el codigo_fun 701 correspondiente al centro de costos y transaccion.',
'#2 Fecha de modificacion: 26 de febrero del 2021',
'Implementacion de funcionalidad para Corresponsalía con 7Eleven.',
'Asignacion de nuevos codigos de retorno de acuerdo a validaciones del sp principal de credito.',
'#3',
'Fecha de modificacion: 06 de julio del 2021',
'-Implementacion: Validar la cuenta asignada al cliente para realizar el pago a la tarjeta.',
'-Considerando que la cuenta no esté cruzada o mal asignada.'
;