CREATE PROCEDURE "informix".sp_consulctafrecuentes_manco_bei(pIdOperacion INTEGER)
	RETURNING CHAR(5), CHAR(20), CHAR(20), MONEY(14,2), CHAR(40), CHAR(40),
	CHAR(100), INTEGER, INTEGER, CHAR(3), CHAR(4), CHAR(4), INTEGER,
	CHAR(40), CHAR(18), CHAR(40), CHAR(100), CHAR(2),
	CHAR(3), CHAR(20), CHAR(20), CHAR(17), CHAR(1), CHAR(9),CHAR(2);

DEFINE sql_err 						INTEGER;
DEFINE cCod_ret 					CHAR(5);
DEFINE vcuenta_origen 				CHAR(20);
DEFINE vcuenta_destino 				CHAR(20);
DEFINE vimporte 					MONEY(14, 2);
DEFINE vreferencia 					CHAR(40);
DEFINE vreferenciabe 				CHAR(40);
DEFINE vnombre_beneficiario 		CHAR(100);
DEFINE vid_usuario 					INTEGER;
DEFINE vid_cat_operacion 			INTEGER;
DEFINE vempresa 					CHAR(3);
DEFINE vsucursal_virtual 			CHAR(4);
DEFINE vusuario_virtual 			CHAR(4);
DEFINE vclave_banco 				INTEGER;
DEFINE vnombre_usuario 				CHAR(40);
DEFINE vrfc 						CHAR(18);
DEFINE vtipo_cuenta_beneficiario 	CHAR(40);
DEFINE vbanco_receptor 				CHAR(100);
DEFINE vcategoria 					CHAR(2);
DEFINE vconvenio 					CHAR(3);
DEFINE vreftelefono 				CHAR(20);
DEFINE vrefverificador 				CHAR(20);
DEFINE vnombre_archivo 				CHAR(17);
DEFINE vstatusoperacion 			CHAR(1);
DEFINE vid_cliente 					CHAR(9);
DEFINE vCveCta                      CHAR(2);

LET cCod_ret 					= '00000';
LET vcuenta_origen 				= '';
LET vcuenta_destino 			= '';
LET vimporte 					= 0;
LET vreferencia 				= '';
LET vreferenciabe 				= '';
LET vnombre_beneficiario 		= '';
LET vid_usuario 				= 0;
LET vid_cat_operacion 			= 0;
LET vempresa 					= '';
LET vsucursal_virtual 			= '';
LET vusuario_virtual 			= '';
LET vclave_banco 				= 0;
LET vnombre_usuario 			= '';
LET vrfc 						= '';
LET vtipo_cuenta_beneficiario 	= '';
LET vbanco_receptor 			= '';
LET vcategoria 					= '';
LET vconvenio 					= '';
LET vreftelefono 				= '';
LET vrefverificador 			= '';
LET vnombre_archivo 			= '';
LET vstatusoperacion 			= '';
LET vid_cliente 				= '';
LET vCveCta                     = '';

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCod_ret = sql_err;
			
			RETURN cCod_ret, vcuenta_origen, vcuenta_destino, vimporte,
				vreferencia, vreferenciabe, vnombre_beneficiario, vid_usuario,
				vid_cat_operacion, vempresa, vsucursal_virtual, vusuario_virtual,
				vclave_banco, vnombre_usuario, vrfc, vtipo_cuenta_beneficiario,
				vbanco_receptor, vcategoria, vconvenio, vreftelefono,
				vrefverificador, vnombre_archivo, vstatusoperacion, vid_cliente,vCveCta;
		END IF;
	END EXCEPTION;
	
	SELECT cuenta_origen, cuenta_destino, importe, referencia, referenciabe,
		nombre_beneficiario, id_usuario, id_cat_operacion, empresa,
		sucursal_virtual, usuario_virtual, clave_banco, nombre_usuario, rfc,
		tipo_cuenta_beneficiario, banco_receptor, categoria, convenio,
        reftelefono, refverificador, numtransferenciacargo, statusoperacion, id_cliente, moneda
	INTO vcuenta_origen, vcuenta_destino, vimporte, vreferencia, vreferenciabe,
		vnombre_beneficiario, vid_usuario, vid_cat_operacion, vempresa,
		vsucursal_virtual, vusuario_virtual, vclave_banco, vnombre_usuario,
        vrfc, vtipo_cuenta_beneficiario, vbanco_receptor, vcategoria, vconvenio,
		vreftelefono, vrefverificador, vnombre_archivo, vstatusoperacion,
        vid_cliente, vCveCta
	FROM bei_operacionesmancomunadasoperador
	WHERE ID_OPERACION = pIdOperacion;

	RETURN NVL(cCod_ret, ''), NVL(vcuenta_origen, ''), NVL(vcuenta_destino, ''),
		NVL(vimporte, 0.0), NVL(vreferencia, ''), NVL(vreferenciabe, ''),
		NVL(vnombre_beneficiario, ''), NVL(vid_usuario, 0),
		NVL(vid_cat_operacion, 0), NVL(vempresa, ''), NVL(vsucursal_virtual, ''),
		NVL(vusuario_virtual, ''), NVL(vclave_banco, 0), NVL(vnombre_usuario, ''),
		NVL(vrfc, ''), NVL(vtipo_cuenta_beneficiario, ''), NVL(vbanco_receptor, ''),
        NVL(vcategoria, ''), NVL(vconvenio, ''), NVL(vreftelefono, ''),
		NVL(vrefverificador, ''), NVL(vnombre_archivo, ''),
        NVL(vstatusoperacion, ''), NVL(vid_cliente, ''),NVL(vCveCta,'');
	END
END PROCEDURE;