CREATE PROCEDURE "informix".sp_consuloperctapropias_manco_bei(pIdOperacion INTEGER)
RETURNING CHAR(5),char(4),char(4),char(4),char(16),char(12),char(12),
            money(14,2),char(2),char(40),money(14,2),INTEGER,INTEGER,CHAR(1),CHAR(10),CHAR(10);

    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vTransCargo char(4);
    DEFINE vTransAbono char(4);
    DEFINE vTransSuc char(4);
    DEFINE vfoliosuc char(16);
    DEFINE vcuenta_origen char(12);
    DEFINE vcuenta_destino char(12);
    DEFINE vimporte money(14,2);
    DEFINE vmoneda char(2);
    DEFINE vreferencia char(40);
    DEFINE vmontototal money(14,2);
    DEFINE vid_usuario INTEGER;
    DEFINE vid_cat_operacion INTEGER;
    DEFINE vstatusoperacion CHAR(1);
    DEFINE vf_aplicacion            	CHAR(10);
    DEFINE vf_operacion             	CHAR(10);

    LET cCod_ret = '00000';
    LET vTransCargo = '';
    LET vTransAbono = '';
    LET vTransSuc = '';
    LET vfoliosuc = '';
    LET vcuenta_origen = '';
    LET vcuenta_destino = '';
    LET vimporte = 0;
    LET vmoneda = '';
    LET vreferencia = '';
    LET vmontototal = 0;
    LET vid_usuario = 0;
    LET vid_cat_operacion = 0;
    LET vstatusoperacion = '';
    LET vf_aplicacion = TODAY;
    LET vf_operacion = TODAY;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret,vTransCargo,vTransAbono,vTransSuc,vfoliosuc,vcuenta_origen,vcuenta_destino,
                    vimporte,vmoneda,vreferencia,vmontototal,vid_usuario,vid_cat_operacion,vstatusoperacion,vf_aplicacion,
            vf_operacion;
      END IF ;
    END EXCEPTION ;

    SELECT numTransferenciaCargo,numTransferenciaAbono,transaccion_sucursal,
        foliosuc,cuenta_origen,cuenta_destino,importe,moneda,
        referencia,montototal,id_usuario,id_cat_operacion,statusoperacion,  f_aplicacion,
            f_operacion
    INTO vTransCargo,vTransAbono,vTransSuc,vfoliosuc,vcuenta_origen,vcuenta_destino,vimporte,
            vmoneda,vreferencia,vmontototal,vid_usuario,vid_cat_operacion,vstatusoperacion,vf_aplicacion,
            vf_operacion
    FROM "informix".bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;



    RETURN cCod_ret,vTransCargo,vTransAbono,vTransSuc,vfoliosuc,vcuenta_origen,vcuenta_destino,
            vimporte,vmoneda,vreferencia,vmontototal,vid_usuario,vid_cat_operacion,vstatusoperacion,vf_aplicacion,
            vf_operacion;

END

END PROCEDURE;