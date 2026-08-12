CREATE PROCEDURE "informix".sp_aplicar_cancelacion_por_recuperacion_creddeb(pFolio_csuac CHAR (11),pUsuario CHAR(8))

RETURNING CHAR (5) AS codeRet,
          CHAR(60) AS mensajeRet;

DEFINE dLineaDisponible  DECIMAL(18,2);
DEFINE linea_disponible DECIMAL(18,2);
DEFINE Daclaraciones_vigentes CHAR(15);
DEFINE tipoProducto INTEGER;
DEFINE pNumCliente CHAR(15);
DEFINE codeRet CHAR(5);
DEFINE aclaracionesVigentes INTEGER;
DEFINE aFky_aclaracion INTEGER;
DEFINE aFky_area INTEGER;
DEFINE aFky_estatus_aclaracion INTEGER;
DEFINE aFky_estatus_corp_analisis INTEGER;
DEFINE aFky_estauts_corp_general INTEGER;
DEFINE vNumCuenta CHAR(25);
DEFINE resultado_saldo_congelado MONEY;
DEFINE codeRet2 CHAR(15);
DEFINE eEmpresa CHAR(5);
DEFINE mensajeRet CHAR(85); 
DEFINE FolioCancel CHAR(25);
DEFINE accionBitacora INTEGER;
DEFINE pSucursal CHAR(25);
/* Variables obtencion Saldo Debito */
DEFINE vcodret                 CHAR(10);
DEFINE vsdodisp                MONEY(16,2); --> saldo disponible
DEFINE vstatuscta              CHAR(10);
DEFINE pmotivobloq CHAR(2);
DEFINE pfechabloq   DATE;
DEFINE pclave       CHAR(5);
DEFINE pAreaSolic   CHAR(2);
DEFINE pCodArea     CHAR(1);
DEFINE pTipoBloq    CHAR(2);
DEFINE pCodTipoBloq CHAR(1);
DEFINE vCancelada SMALLINT;
DEFINE vControlCancelacionPendiente INTEGER;
DEFINE e_pky_num_empleado INTEGER;
DEFINE v_cuenta_a_cancelar INTEGER;
DEFINE vNumCuentaTemp CHAR(25);

LET dLineaDisponible  = 0;
LET linea_disponible = 0;
LET Daclaraciones_vigentes = '';
LET tipoProducto = 0;
LET pNumCliente = '';
LET codeRet = '';
LET aclaracionesVigentes = 0;
LET aFky_aclaracion = 0;
LET aFky_area = 0;
LET aFky_estatus_aclaracion = 0;
LET aFky_estatus_corp_analisis = 0;
LET aFky_estauts_corp_general = 0;
LET vNumCuenta = null;
LET resultado_saldo_congelado = 0;
LET codeRet2 = '';
LET eEmpresa = '001';
LET accionBitacora = 0;
LET pSucursal = '';
LET pmotivobloq = '';
LET pfechabloq = today;
LET pclave = '';
LET pAreaSolic= '07';
LET pCodArea='A';
LET pTipoBloq='09';
LET pCodTipoBloq = 'P';
LET vCancelada = 0;
LET vControlCancelacionPendiente = 0;
LET e_pky_num_empleado = 0;
LET v_cuenta_a_cancelar = 0;
LET vNumCuentaTemp = null;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO "/resplogifx/repaclaraciones/RQM732-1"||pFolio_csuac||"_34"||".out";
  --TRACE ON;

BEGIN 

SELECT p.numero_cuenta, tp.tipo_producto, p.num_cliente, acl.pky_aclaracion, acl.fky_area, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_analisis, acl.fky_estatus_corp_general 
    INTO vNumCuenta, tipoProducto, pNumCliente,aFky_aclaracion, aFky_area, aFky_estatus_aclaracion, aFky_estatus_corp_analisis, aFky_estauts_corp_general
    FROM acl_aclaracion acl INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto 
    INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto WHERE folio_csuac=pFolio_csuac;
--VALIDA QUE NO TENGA ACLARACIONES VIGENTES
SELECT count(fky_estatus_aclaracion) INTO aclaracionesVigentes FROM acl_aclaracion WHERE fky_estatus_aclaracion = 2 AND num_cliente = pNumCliente;
--SE VÁLIDA QUE EXISTA UN USUARIO LOGUEADO
IF pUsuario <> '0' THEN
    SELECT num_sucursal,pky_usuario INTO pSucursal, e_pky_num_empleado FROM bdiaclaracion:acl_usuario where num_empleado = pUsuario;
ELSE
    SELECT pky_usuario INTO e_pky_num_empleado FROM bdiaclaracion:acl_usuario where pky_usuario = 0;
    LET pUsuario = '93921632';
    LET pSucursal = '8030';
END IF
IF aclaracionesVigentes > 0 THEN
    --TIENE ACLARACIONES VIGENTES
    LET mensajeRet = 'La cuenta tiene aclaraciones vigentes';
    --LA CUENTA ESTÁ PENDIENTE A CANCELAR
    LET v_cuenta_a_cancelar = 1;
    --BUSCA LA ACCIÓN
     SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionRecuperacion';
     --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
     INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
         VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó un intento de cancelación por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
    --ES CREDITO 
    IF tipoProducto = 1 THEN
        --BLOQUEA LA CUENTA DE CREDITO
        EXECUTE PROCEDURE bdicred:sp_bloqueocuenta (eEmpresa,TRIM(vNumCuenta),'3','10',pUsuario,'1') INTO codeRet, codeRet2;  
    --ES DEBITO
    ELIF tipoProducto = 2 THEN
        --BLOQUEA LA CUENTA DE DEBITO
        EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(eEmpresa,TRIM(vNumCuenta), 0, '56', 3, pfechabloq , pUsuario, pclave, pAreaSolic, pCodArea,pTipoBloq, pCodTipoBloq ) INTO codeRet, codeRet2;
    END IF;
ELSE 
    --ES DÉBITO
    IF tipoProducto = 2 THEN
            --DESBLOQUEA LA CUENTA DE ACUERDO AL SALDO CONGELADO
            SELECT sdo_cong INTO resultado_saldo_congelado
            FROM bdicheq:"informix".sc_maechq
            WHERE cuenta = vNumCuenta;
            IF (resultado_saldo_congelado > 0) THEN
                -- DESBLOQUEA POR MONTO
                EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(eEmpresa,vNumCuenta, resultado_saldo_congelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) INTO codeRet,codeRet2;
                --CANCELACIÓN CUENTA DÉBITO
                EXECUTE PROCEDURE bdicheq:"informix".sp_cancelactachq(eEmpresa,vNumCuenta,'11',pUsuario,pSucursal) INTO codeRet,codeRet2,mensajeRet, FolioCancel;
                LET mensajeRet = mensajeRet;
                --VALIDA QUE LA CUENTA SE HAYA CANCELADO CON ÉXITO
                IF(codeRet <> '069') THEN
                    LET pmotivobloq = '56';
                    EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(eEmpresa,TRIM(vNumCuenta), 0, '56', 3, pfechabloq , pUsuario, pclave, pAreaSolic, pCodArea,pTipoBloq, pCodTipoBloq ) INTO codeRet, codeRet2;
                    LET codeRet = codeRet;
                    --LA CUENTA ESTÁ PENDIENTE A CANCELAR
                    LET v_cuenta_a_cancelar = 1;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionRecuperacion';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó un intento de cancelación por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);  
                ELSE
                --CUENTA CANCELADA
                    LET codeRet = '000';
                    LET mensajeRet = 'La cuenta de débito se canceló con éxito';
                    --CUENTA CANCELADA CON ÉXITO
                    LET v_cuenta_a_cancelar = 0;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionAutomatica';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó la cancelación exitosa por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
                END IF
            ELIF (resultado_saldo_congelado == 0) THEN
                -- DESBLOQUEA POR 0
                EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(eEmpresa,vNumCuenta,0,'00',0,today,'0','4469','07','A','09','P' ) INTO codeRet,codeRet2;
                --CANCELACIÓN CUENTA DÉBITO
                EXECUTE PROCEDURE bdicheq:"informix".sp_cancelactachq(eEmpresa,vNumCuenta,'11',pUsuario,pSucursal) INTO codeRet,codeRet2,mensajeRet, FolioCancel;
                --VALIDA QUE LA CUENTA SE HAYA CANCELADO CON ÉXITO
                IF(codeRet <> '069') THEN
                    --BLOQUEA LA CUENTA
                    EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(eEmpresa,TRIM(vNumCuenta), 0, '56', 3, pfechabloq , pUsuario, pclave, pAreaSolic, pCodArea,pTipoBloq, pCodTipoBloq ) INTO codeRet, codeRet2;
                    LET codeRet = codeRet;
                    --LA CUENTA ESTÁ PENDIENTE A CANCELAR
                    LET v_cuenta_a_cancelar = 1;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionRecuperacion';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó un intento de cancelación por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
                ELSE
                --CUENTA CANCELADA
                    LET codeRet = '000';
                    LET mensajeRet = 'La cuenta de débito se canceló con éxito';
                    --CUENTA CANCELADA CON ÉXITO
                    LET v_cuenta_a_cancelar = 0;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionAutomatica';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó la cancelación exitosa por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
                END IF
            END IF
    --ES CRÉDITO
    ELSE IF tipoProducto = 1 THEN
        --VALIDA QUE LA CUENTA NO CUENTE CON SALDO DEUDOR
        SELECT (monto_otorgado - sdo_cap_insoluto - sdo_retenido) INTO dLineaDisponible FROM bdicred:sd_maesdos WHERE num_credito = vNumCuenta;
        IF dLineaDisponible >= 0 THEN   
             --DESBLOQUEO CUENTA CREDITO
            EXECUTE PROCEDURE bdicred:"informix".sp_desbloqueocuenta (eEmpresa,vNumCuenta,'0','1') INTO codeRet, codeRet2;
            --CANCELACIÓN CUENTA CRÉDITO
            EXECUTE PROCEDURE bdicred:"informix".sp_cancelarcredito(eEmpresa,vNumCuenta,'5',pUsuario,pUsuario,'5',pSucursal) INTO codeRet, codeRet2;
            LET codeRet = codeRet;
            --VALIDA QUE LA CUENTA SE HAYA CANCELADO CON ÉXITO
            IF(codeRet <> '00000') THEN
                    --SE VUELVE A BLOQUEAR LA CUENTA DE CRÉDITO
                    LET pmotivobloq = '10';
                    --SE VUELVE A BLOQUEAR LA CUENTA SI NO SE PUDO CANCELAR
                    EXECUTE PROCEDURE bdicred:sp_bloqueocuenta (eEmpresa,TRIM(vNumCuenta),'3','10',pUsuario,'1') INTO codeRet, mensajeRet;
                    LET mensajeRet = 'No se pudo cancelar la cuenta';
                    --LA CUENTA ESTÁ PENDIENTE A CANCELAR
                    LET v_cuenta_a_cancelar = 1;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionRecuperacion';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó un intento de cancelación por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
                ELSE
                --CUENTA CANCELADA
                    LET codeRet = '000';
                    LET mensajeRet = 'La cuenta de crédito se canceló con éxito';
                    --CUENTA CANCELADA CON ÉXITO
                    LET v_cuenta_a_cancelar = 0;
                    --BUSCA LA ACCIÓN
                    SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionAutomatica';
                    --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
                    INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                        VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó la cancelación exitosa por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
                END IF
        ELSE
            --LA CUENTA TIENE SALDO DEUDOR
            LET codeRet = '002';
            LET mensajeRet = 'La cuenta de crédito tiene saldo deudor';
            --LA CUENTA ESTÁ PENDIENTE A CANCELAR
            LET v_cuenta_a_cancelar = 1;
            --BUSCA LA ACCIÓN
            SELECT pky_resolucion INTO accionBitacora FROM bdiaclaracion:"informix".acl_resolucion WHERE nombre = 'cancelacionRecuperacion';
            --INSERTAR BITACORA COMO INTENTO DE CANCELACIÓN
            INSERT INTO bdiaclaracion:"informix".acl_entrada_bitacora(pky_entrada_bitacora,descripcion ,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
                VALUES (bdiaclaracion:entrada_bitacora_seq.nextval, 'Se realizó un intento de cancelación por recuperación',sysdate,pFolio_csuac,accionBitacora,aFky_aclaracion,aFky_area,aFky_estatus_aclaracion,aFky_estatus_corp_analisis,aFky_estauts_corp_general,e_pky_num_empleado);
            END IF;
        END IF;
    END IF;
END IF;
END;
IF v_cuenta_a_cancelar = 1 THEN
    --VALIDA SI LA CUENTA SE ENCUENTRA EN EL CONTROL DE CUENTAS PENDIENTES A CANCELAR
    SELECT num_cta INTO vNumCuentaTemp  FROM acl_control_cuentas_pendientes_cancelar WHERE num_cta = vNumCuenta;
    IF(vNumCuentaTemp IS NULL) THEN 
        --INSERTAR EN CONTROL DE CUENTAS PENDIENTES A CANCELAR
        INSERT INTO bdiaclaracion:"informix".acl_control_cuentas_pendientes_cancelar(pky_control_cuentas_pendientes_cancelar,num_cta,cancelada,fechaInicio,fechaFinal) 
            VALUES (bdiaclaracion:control_cuentas_pendientes_cancelar_seq.nextval,vNumCuenta,0,sysdate,null);
    END IF
    --BUSCAMOS LA CUENTA EN EL CONTROL DE CANCELACIONES PENDIENTES 
    SELECT pky_control_cuentas_pendientes_cancelar INTO vControlCancelacionPendiente FROM bdiaclaracion:"informix".acl_control_cuentas_pendientes_cancelar WHERE num_cta=vNumCuenta;
    --INSERTAR BITACORA DE CONTROL DE CANCELACIONES
    INSERT INTO bdiaclaracion:"informix".acl_bitacora_control_cancelacion_cuenta(pky_bitacora_control_cancelacion_cuenta,fky_control_cuentas_pendientes_cancelar,fky_aclaracion,descripcion,folio_csuac,fecha,fky_resolucion)
        VALUES (bdiaclaracion:bitacora_control_cancelacion_cuenta_seq.nextval,vControlCancelacionPendiente,aFky_aclaracion,mensajeRet,pFolio_csuac,sysdate,accionBitacora);
ELIF v_cuenta_a_cancelar = 0 THEN
    --VALIDA SI LA CUENTA SE ENCUENTRA EN EL CONTROL DE CUENTAS PENDIENTES A CANCELAR
    SELECT num_cta INTO vNumCuentaTemp  FROM acl_control_cuentas_pendientes_cancelar WHERE num_cta = vNumCuenta;
    IF(vNumCuentaTemp IS NULL) THEN 
        --INSERTAR EN CONTROL DE CUENTAS PENDIENTES A CANCELAR
        INSERT INTO bdiaclaracion:"informix".acl_control_cuentas_pendientes_cancelar(pky_control_cuentas_pendientes_cancelar,num_cta,cancelada,fechaInicio,fechaFinal) 
            VALUES (bdiaclaracion:control_cuentas_pendientes_cancelar_seq.nextval,vNumCuenta,1,sysdate,sysdate);
    ELSE 
        --SE ACTUALIZA EL REGISTRO EN EL CONTROL DE CUENTAS PENDIENTES A CANCELAR
        UPDATE bdiaclaracion:"informix".acl_control_cuentas_pendientes_cancelar SET cancelada = 1, fechaFinal = sysdate WHERE num_cta = vNumCuenta;
    END IF
    --BUSCAMOS LA CUENTA EN EL CONTROL DE CANCELACIONES PENDIENTES 
    SELECT pky_control_cuentas_pendientes_cancelar INTO vControlCancelacionPendiente FROM bdiaclaracion:"informix".acl_control_cuentas_pendientes_cancelar WHERE num_cta=vNumCuenta;
    --INSERTAR BITACORA DE CONTROL DE CANCELACIONES
    INSERT INTO bdiaclaracion:"informix".acl_bitacora_control_cancelacion_cuenta(pky_bitacora_control_cancelacion_cuenta,fky_control_cuentas_pendientes_cancelar,fky_aclaracion,descripcion,folio_csuac,fecha,fky_resolucion)
        VALUES (bdiaclaracion:bitacora_control_cancelacion_cuenta_seq.nextval,vControlCancelacionPendiente,aFky_aclaracion,mensajeRet,pFolio_csuac,sysdate,accionBitacora);
END IF;
RETURN codeRet,mensajeRet;
END PROCEDURE;