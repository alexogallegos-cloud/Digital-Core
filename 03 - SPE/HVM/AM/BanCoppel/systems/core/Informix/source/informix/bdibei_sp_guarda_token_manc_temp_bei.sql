CREATE PROCEDURE "informix".sp_guarda_token_manc_temp_bei(    
    id_usuario_admin INTEGER,    
    tipo_mov SMALLINT,
    id_usuario INTEGER,
    num_cliente CHAR(9),
    ns_token VARCHAR(10),
    id_status_token	INTEGER
)
RETURNING CHAR(5), INTEGER;

    DEFINE iIdOperacion     INTEGER;
    DEFINE cod_ret 			CHAR(5);
    DEFINE sql_err 			INTEGER ;

    LET iIdOperacion = 0;
    LET cod_ret  = "00000";

BEGIN 
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, iIdOperacion;
            
      END IF ;
   END EXCEPTION ;   

    INSERT INTO "informix".bei_admin_manco_temp(id_admin_manco, num_cliente_admin, id_usuario_admin, tipo_oper, tipo_mov, id_usuario, num_cliente, 
            id_status, activo, ns_token, id_status_token) 
	VALUES(0, num_cliente, id_usuario_admin, 2, tipo_mov, id_usuario, num_cliente, 
            1, 't', ns_token, id_status_token);

    LET iIdOperacion = DBINFO('sqlca.sqlerrd1');

    RETURN cod_ret, iIdOperacion;
    

END
END PROCEDURE;