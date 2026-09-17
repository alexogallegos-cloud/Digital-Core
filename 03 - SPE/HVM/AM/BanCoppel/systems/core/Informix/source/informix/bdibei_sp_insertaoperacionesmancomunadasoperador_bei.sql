CREATE PROCEDURE "informix".sp_insertaoperacionesmancomunadasoperador_bei(
    pfoliosuc                	CHAR(16),
	pcuenta_origen           	CHAR(20),
	pcuenta_destino          	CHAR(20),
	pimporte                 	MONEY(14,2),
	pmoneda                  	CHAR(2),
	preferencia              	CHAR(40),
	preferenciabe            	CHAR(40),
	pnombre_beneficiario     	VARCHAR(100),
	pf_aplicacion            	DATE,
	pf_operacion             	DATE,
	pid_usuario              	INTEGER,
	pid_cat_operacion        	INTEGER,
	pempresa                 	CHAR(3),
	psucursal_virtual        	CHAR(4),
	pusuario_virtual         	CHAR(4),
	pclave_banco             	INTEGER,
	ptransaccion_sucursal    	CHAR(4),
	pcomision                	MONEY(14,2),
	pivacomision             	MONEY(14,2),
	pnombre_usuario          	VARCHAR(40),
	prfc                     	VARCHAR(18),
	ptipo_cuenta_beneficiario	VARCHAR(40),
	pvalor_iva               	MONEY(14,2),
	preferencia_cobranza     	VARCHAR(40),
	pbanco_receptor          	VARCHAR(100),
	pnumtransferenciacargo   	CHAR(4),
	pnumtransferenciaabono   	CHAR(4),
	pmontototal              	MONEY(14,2),
	pcategoria               	CHAR(2),
	pconvenio                	CHAR(3),
	preftelefono             	CHAR(20),
	prefverificador          	CHAR(20),
	pnombre_archivo          	CHAR(17),
	pstatusoperacion         	CHAR(1),
	numero_Empleado 			INTEGER,
	nombre_empleado 			VARCHAR(100),
	apellidos_pat_empleado 		VARCHAR(100),
	apellidos_mat_empleado 		VARCHAR(100)
)
returning char(5),INTEGER;

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;
	DEFINE NombreOperador varchar(50);
	DEFINE id_cliente CHAR(9);

 	LET sIdOper=0;
 	LET cod_ret="00000";
BEGIN

    ON EXCEPTION SET sql_err
       LET sIdOper = 0;
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,sIdOper;
      END IF ;
    END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;


		SELECT datos_usuario.nombre
		INTO NombreOperador
		FROM "informix".bei_datos_usuario AS datos_usuario
		WHERE datos_usuario .id_usuario = pid_usuario;

		SELECT usuario.num_cliente
		INTO id_cliente
		FROM "informix".bei_usuario AS usuario
		WHERE usuario.id_usuario = pid_usuario;



        INSERT INTO bdibei:"informix".bei_operacionesmancomunadasoperador(
            id_operacion, foliosuc, cuenta_origen,
            cuenta_destino, importe, moneda,
            referencia, referenciabe, nombre_beneficiario,
            f_aplicacion, f_operacion, id_usuario,
            id_cat_operacion, empresa, sucursal_virtual,
            usuario_virtual, clave_banco, transaccion_sucursal,
            comision, ivacomision, nombre_usuario,
            rfc, tipo_cuenta_beneficiario, valor_iva,
            referencia_cobranza, banco_receptor, numtransferenciacargo,
            numtransferenciaabono, montototal, categoria,
            convenio, reftelefono, refverificador,
            nombre_archivo, statusoperacion, id_cliente, id_usuarioCambiaStatus,
			numero_Empleado,nombre_empleado,apellidos_pat_empleado,apellidos_mat_empleado,f_registro)
        VALUES(
            0,pfoliosuc,pcuenta_origen,
            pcuenta_destino, pimporte, pmoneda,
            preferencia, preferenciabe, pnombre_beneficiario,
            pf_aplicacion, pf_operacion, pid_usuario,
            pid_cat_operacion, pempresa, psucursal_virtual,
            pusuario_virtual, pclave_banco,	ptransaccion_sucursal,
            pcomision, pivacomision, pnombre_usuario,
            prfc, ptipo_cuenta_beneficiario, pvalor_iva,
            preferencia_cobranza , pbanco_receptor,	pnumtransferenciacargo,
            pnumtransferenciaabono, pmontototal, pcategoria,
            pconvenio, preftelefono, prefverificador,
            pnombre_archivo, pstatusoperacion, id_cliente, null,
			numero_Empleado,nombre_empleado,apellidos_pat_empleado,apellidos_mat_empleado,CURRENT);

            LET sIdOper = DBINFO('sqlca.sqlerrd1');


            INSERT INTO bdibei:"informix".bei_operacionesmancomunadasoperadorresumen(
                id_operacion, f_operacion, f_aplicacion,
                cuenta_origen, montototal, id_catOperacion, Operador,
				statusoperacion, id_usuario, id_cliente, id_usuarioCambiaStatus,f_registro)
            VALUES(sIdOper, pf_operacion, pf_aplicacion, pcuenta_origen,
                pmontototal, pid_cat_operacion, NombreOperador, pstatusoperacion, pid_usuario, id_cliente, null,CURRENT);



    return cod_ret,sIdOper;

END
END PROCEDURE;