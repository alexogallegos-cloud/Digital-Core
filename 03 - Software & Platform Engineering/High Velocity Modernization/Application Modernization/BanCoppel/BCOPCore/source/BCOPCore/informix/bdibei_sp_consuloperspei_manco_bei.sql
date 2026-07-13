CREATE PROCEDURE "informix".sp_consuloperspei_manco_bei(pIdOperacion INTEGER)
RETURNING CHAR(5), CHAR(3),CHAR(4),CHAR(4),INTEGER,MONEY,CHAR(4),CHAR(16),
            DATE,MONEY,MONEY,CHAR(40), CHAR(20), CHAR(18), CHAR(100),
            CHAR(40),CHAR(20),CHAR(40),MONEY,CHAR(40),CHAR(100),MONEY,
            CHAR(10), INTEGER,INTEGER,CHAR(1);

    DEFINE vempresa CHAR(3);
    DEFINE vsucursal_virtual CHAR(4);
    DEFINE vusuario_virtual CHAR(4);
    DEFINE vclave_banco INTEGER;
    DEFINE vimporte MONEY;
    DEFINE vtransaccion_sucursal CHAR(4);
    DEFINE vfoliosuc CHAR(16);
    DEFINE vf_operacion DATE;
    DEFINE vcomision MONEY;
    DEFINE vivacomision MONEY;
    DEFINE vnombre_usuario CHAR(40);          
    DEFINE vcuenta_origen CHAR(20);           
    DEFINE vrfc CHAR(18);                     
    DEFINE vnombre_beneficiario CHAR(100);
    DEFINE vtipo_cuenta_beneficiario CHAR(40);
    DEFINE vcuenta_destino CHAR(20);
    DEFINE vreferencia CHAR(40);
    DEFINE vvalor_iva MONEY;
    DEFINE vreferencia_cobranza CHAR(40);
    DEFINE vbanco_receptor CHAR(100);
    DEFINE vmontototal MONEY;
    DEFINE vf_aplicacion CHAR(10);            
    DEFINE vid_usuario INTEGER;
    DEFINE vid_cat_operacion INTEGER;
    DEFINE vstatusoperacion CHAR(1);
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);

    LET cCod_ret = '00000';
    LET  vempresa = '';
    LET  vsucursal_virtual = '';
    LET  vusuario_virtual = '';
    LET  vclave_banco = 0;
    LET  vimporte = 0;
    LET  vtransaccion_sucursal = '';
    LET  vfoliosuc = '';
    LET  vf_operacion = TODAY;
    LET  vcomision = 0;
    LET  vivacomision = 0;
    LET  vnombre_usuario = '';
    LET  vcuenta_origen = '';
    LET  vrfc = '';
    LET  vnombre_beneficiario = '';
    LET  vtipo_cuenta_beneficiario = '';
    LET  vcuenta_destino = '';
    LET  vreferencia = '';
    LET  vvalor_iva = 0;
    LET  vreferencia_cobranza = '';
    LET  vbanco_receptor = '';
    LET  vmontototal = 0;
    LET  vf_aplicacion = TODAY;
    LET  vid_usuario = 0;
    LET  vid_cat_operacion = 0;
    LET  vstatusoperacion = '';

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vempresa, vsucursal_virtual, vusuario_virtual, vclave_banco, vimporte,
             vtransaccion_sucursal, vfoliosuc, vf_operacion, vcomision, vivacomision,
             vnombre_usuario, vcuenta_origen, vrfc, vnombre_beneficiario,
             vtipo_cuenta_beneficiario, vcuenta_destino, vreferencia, vvalor_iva,
             vreferencia_cobranza, vbanco_receptor, vmontototal, vf_aplicacion,
             vid_usuario, vid_cat_operacion, vstatusoperacion;
      END IF ;
    END EXCEPTION ;

     SELECT empresa, sucursal_virtual, usuario_virtual, clave_banco, importe, 
            transaccion_sucursal, foliosuc, f_operacion, comision, ivacomision, 
            nombre_usuario, cuenta_origen, rfc, nombre_beneficiario, 
            tipo_cuenta_beneficiario, cuenta_destino, referencia, valor_iva, 
            referencia_cobranza, banco_receptor, montototal, to_char(f_aplicacion,"%iY-%m-%d") as f_aplicacion, 
            id_usuario, id_cat_operacion, statusoperacion
    INTO vempresa, vsucursal_virtual, vusuario_virtual, vclave_banco, vimporte, 
            vtransaccion_sucursal, vfoliosuc, vf_operacion, vcomision, vivacomision, 
            vnombre_usuario, vcuenta_origen, vrfc, vnombre_beneficiario, 
            vtipo_cuenta_beneficiario, vcuenta_destino, vreferencia, vvalor_iva, 
            vreferencia_cobranza, vbanco_receptor, vmontototal, vf_aplicacion, 
            vid_usuario, vid_cat_operacion, vstatusoperacion
    FROM bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;

    RETURN cCod_ret, vempresa, vsucursal_virtual, vusuario_virtual, vclave_banco, vimporte,
             vtransaccion_sucursal, vfoliosuc, vf_operacion, vcomision, vivacomision,
             vnombre_usuario, vcuenta_origen, vrfc, vnombre_beneficiario,
             vtipo_cuenta_beneficiario, vcuenta_destino, vreferencia, vvalor_iva,
             vreferencia_cobranza, vbanco_receptor, vmontototal, vf_aplicacion,
             vid_usuario, vid_cat_operacion, vstatusoperacion;

END

END PROCEDURE;