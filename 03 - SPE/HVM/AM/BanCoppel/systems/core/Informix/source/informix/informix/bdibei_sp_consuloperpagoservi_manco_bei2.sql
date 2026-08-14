CREATE PROCEDURE "informix".sp_consuloperpagoservi_manco_bei2(pIdOperacion INTEGER)
RETURNING CHAR(5),CHAR(3),CHAR(4),CHAR(4),CHAR(4),CHAR(4),CHAR(4),CHAR(16),
        CHAR(20),CHAR(20),MONEY,CHAR(2),CHAR(40),MONEY,CHAR(2),CHAR(3),CHAR(20),
        CHAR(20),CHAR(10),CHAR(100),CHAR(10),INTEGER,INTEGER,CHAR(1),CHAR(40),CHAR(40),CHAR(40),CHAR(40),CHAR(6),CHAR(200),CHAR(250);
    
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vempresa CHAR(3);
    DEFINE vsucursal_virtual CHAR(4);
    DEFINE vusuario_virtual CHAR(4);
    DEFINE vnumtransferenciacargo CHAR(4);
    DEFINE vnumtransferenciaabono CHAR(4);
    DEFINE vtransaccion_sucursal CHAR(4);
    DEFINE vfoliosuc CHAR(16);
    DEFINE vcuenta_origen CHAR(20);
    DEFINE vcuenta_destino CHAR(20);
    DEFINE vimporte MONEY;
    DEFINE vmoneda CHAR(2);
    DEFINE vreferencia CHAR(40);
    DEFINE vmontototal MONEY;
    DEFINE vcategoria CHAR(2);
    DEFINE vconvenio CHAR(3);
    DEFINE vreftelefono CHAR(20);
    DEFINE vrefverificador CHAR(20);
    DEFINE vf_operacion CHAR(10);
    DEFINE vnombre_beneficiario CHAR(100);
    DEFINE vf_aplicacion CHAR(10);
    DEFINE vid_usuario INTEGER;
    DEFINE vid_cat_operacion INTEGER;
    DEFINE vstatusoperacion CHAR(1);
    DEFINE vpgen1 CHAR(40);
    DEFINE vpgen2 CHAR(40);
    DEFINE vpgen3 CHAR(40);
    DEFINE vpgen4 CHAR(40);
    DEFINE vtipo_servicio CHAR(6);
    DEFINE vconcepto CHAR(200);
    DEFINE vlistacampos CHAR(250);

    LET cCod_ret = '00000';
    LET vempresa = '';
    LET vsucursal_virtual = '';
    LET vusuario_virtual = '';
    LET vnumtransferenciacargo = '';
    LET vnumtransferenciaabono = '';
    LET vtransaccion_sucursal = '';
    LET vfoliosuc = '';
    LET vcuenta_origen = '';
    LET vcuenta_destino = '';
    LET vimporte = 0;
    LET vmoneda = '';
    LET vreferencia = '';
    LET vmontototal = 0;
    LET vcategoria = '';
    LET vconvenio = '';
    LET vreftelefono = '';
    LET vrefverificador = '';
    LET vf_operacion = TODAY;
    LET vnombre_beneficiario = '';
    LET vf_aplicacion = TODAY;
    LET vid_usuario = 0;
    LET vid_cat_operacion = 0;
    LET vstatusoperacion = '';
    LET vpgen1 = '';
    LET vpgen2 = '';
    LET vpgen3 = '';
    LET vpgen4 = '';
    LET vtipo_servicio = '';
    LET vconcepto = '';
    LET vlistacampos = '';


BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,vconcepto,vlistacampos;
      END IF ;
    END EXCEPTION ;

    SELECT  empresa,sucursal_virtual,usuario_virtual,numtransferenciacargo,numtransferenciaabono,
            transaccion_sucursal,foliosuc,cuenta_origen,cuenta_destino,importe,moneda,referencia,
            montototal,categoria,convenio,reftelefono,refverificador,f_operacion,nombre_beneficiario,
            f_aplicacion,id_usuario,id_cat_operacion,statusoperacion,pgen1,pgen2, pgen3, pgen4, tipo_servicio, concepto , campos_adicionales  
    INTO    vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,vconcepto,vlistacampos
    FROM bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;     

    RETURN cCod_ret, vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,NVL(vconcepto,''),NVL(vlistacampos,'');

END

END PROCEDURE;