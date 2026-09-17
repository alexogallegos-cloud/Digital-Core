CREATE PROCEDURE "informix".sp_consultaaltaempleado_manco_bei(pIdOperacion INTEGER)
RETURNING CHAR(5), INTEGER, CHAR(100), CHAR(100), CHAR(100),
            CHAR(12), INTEGER,  INTEGER, CHAR(9), DATE, DATE;

    
    DEFINE sql_err                      INTEGER;
	DEFINE cCod_ret                     CHAR (5);
    DEFINE vnumero_empleado 			INTEGER;
    DEFINE vnombre_empleado 			CHAR(100);
    DEFINE vapellidos_pat_empleado 		CHAR(100);
    DEFINE vapellidos_mat_empleado 		CHAR(100);
    DEFINE vcuenta_destino 				CHAR(12);
    DEFINE vclave_banco 				INTEGER;
    DEFINE vid_usuario 					INTEGER;
    DEFINE vnum_cliente 				CHAR(9);
    DEFINE vf_aplicacion            	DATE;
    DEFINE vf_operacion             	DATE;
   
    LET cCod_ret = '00000';
    LET vnumero_empleado = 0;
    LET vnombre_empleado = '';
    LET vapellidos_pat_empleado = '';
    LET vapellidos_mat_empleado = '';
    LET vcuenta_destino = '';
    LET vclave_banco = 0;
    LET vid_usuario = 0;
    LET vnum_cliente = '';
    LET vf_aplicacion = today;
    LET vf_operacion = today;
	

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vnumero_empleado,vnombre_empleado,vapellidos_pat_empleado,
            vapellidos_mat_empleado,vcuenta_destino,vclave_banco,
            vid_usuario, vnum_cliente,vf_aplicacion,vf_operacion;
      END IF ;
    END EXCEPTION ;

    SELECT  numero_empleado,nombre_empleado,apellidos_pat_empleado,
            apellidos_mat_empleado,cuenta_destino,clave_banco,
            id_usuario,id_cliente,f_aplicacion,f_operacion
    INTO    vnumero_empleado,vnombre_empleado,vapellidos_pat_empleado,
            vapellidos_mat_empleado,vcuenta_destino,vclave_banco,
            vid_usuario, vnum_cliente,vf_aplicacion,vf_operacion
    FROM bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;
     

    RETURN cCod_ret, vnumero_empleado,vnombre_empleado,vapellidos_pat_empleado,
            vapellidos_mat_empleado,vcuenta_destino,vclave_banco,
            vid_usuario, vnum_cliente,vf_aplicacion,vf_operacion;

END

END PROCEDURE;