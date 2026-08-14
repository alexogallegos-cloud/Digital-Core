CREATE PROCEDURE "informix".sp_consuloperctaterceros_manco_bei(pIdOperacion INTEGER)
RETURNING CHAR(5),CHAR(16),CHAR(20),CHAR(20),MONEY(14,2),CHAR(2),CHAR(40),
    CHAR(40),CHAR(100),CHAR(10),CHAR(10),INTEGER,INTEGER,CHAR(1);

    DEFINE vfoliosuc                	CHAR(16);
    DEFINE vcuenta_origen           	CHAR(20);
    DEFINE vcuenta_destino          	CHAR(20);
    DEFINE vimporte                 	MONEY(14,2);
    DEFINE vmoneda                  	CHAR(2);
    DEFINE vreferencia              	CHAR(40);
    DEFINE vreferenciabe            	CHAR(40);
    DEFINE vnombre_beneficiario     	VARCHAR(100);
    DEFINE vf_aplicacion            	CHAR(10);
    DEFINE vf_operacion             	CHAR(10);
    DEFINE vid_usuario              	INTEGER;
    DEFINE vid_cat_operacion        	INTEGER;
    DEFINE vstatusoperacion         	CHAR(1);
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
   
    LET cCod_ret = '00000';
    LET vfoliosuc = '';
    LET vcuenta_origen = '';
    LET vcuenta_destino = '';
    LET vimporte = 0;
    LET vmoneda = '';
    LET vreferencia = '';
    LET vreferenciabe = '';
    LET vnombre_beneficiario = '';
    LET vf_aplicacion = TODAY;
    LET vf_operacion = TODAY;
    LET vid_usuario = 0;
    LET vid_cat_operacion = 0;
    LET vstatusoperacion = '';

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret,vfoliosuc,vcuenta_origen,vcuenta_destino,vimporte,vmoneda,
            vreferencia,vreferenciabe,vnombre_beneficiario,vf_aplicacion,
            vf_operacion,vid_usuario,vid_cat_operacion,vstatusoperacion;
      END IF ;
    END EXCEPTION ;

    SELECT  foliosuc,cuenta_origen,cuenta_destino,importe,moneda,
            referencia,referenciabe,nombre_beneficiario,f_aplicacion,
            f_operacion,id_usuario,id_cat_operacion,statusoperacion
    INTO    vfoliosuc,vcuenta_origen,vcuenta_destino,vimporte,vmoneda,
            vreferencia,vreferenciabe,vnombre_beneficiario,vf_aplicacion,
            vf_operacion,vid_usuario,vid_cat_operacion,vstatusoperacion
    FROM "informix".bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;
     

    RETURN cCod_ret, vfoliosuc,vcuenta_origen,vcuenta_destino,vimporte,vmoneda,
            vreferencia,vreferenciabe,vnombre_beneficiario,vf_aplicacion,
            vf_operacion,vid_usuario,vid_cat_operacion,vstatusoperacion;

END

END PROCEDURE;