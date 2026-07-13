CREATE PROCEDURE "informix".sp_actualiza_monto_manco_bei(
pIdAdminManco INTEGER,
pNumCliente CHAR(12),
pIdUsuario INTEGER,
pIdUsuarioAut INTEGER,
pStatusAut INTEGER,
pFechaAut CHAR (20)
)
RETURNING CHAR(5), INTEGER;

	--****************************************************************************************************
	-- DESCRIPCION: Actualiza Status Mancomunidad
	-- AUTOR : SOLSER
	-- FECHA : 08/01/2015
	-- BD: bdibei
	-- SOLICITO :BanCoppel
    -- MODIFICACION: Se agrego el valor de retorno integer que es el id_adminMancoTemp (06/06/2018)
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);

	DEFINE tipo_opera INTEGER;
    DEFINE tipo_movi INTEGER;

    DEFINE id_adminMancoTemp INTEGER;

	LET cCod_ret = '00000';

    LET tipo_opera=0;
    LET tipo_movi = 0;

    LET id_adminMancoTemp = 0;


	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, id_adminMancoTemp;
		  END IF ;
		END EXCEPTION ;
--****************************************************************************************************
-- Valida Si Los datos fueron proporcionados
--***************************************************************************************************

		SET LOCK MODE TO WAIT 3 ;
		SET ISOLATION DIRTY READ ;

		IF NVL(pIdAdminManco, '') == '' THEN
			LET cCod_ret = '00001'; -- Sin Id de Admin
			--	RETURN cCod_ret;
		END IF;

		IF NVL(pNumCliente, '') == '' THEN
			LET cCod_ret = '00002'; -- Sin Numero de Cliente
				RETURN cCod_ret, id_adminMancoTemp;
		END IF;

        IF NVL(pIdUsuario, '') == '' THEN
			LET cCod_ret = '00003'; -- Sin Id de Usuario
				RETURN cCod_ret, id_adminMancoTemp;
		END IF;

--****************************************************************************************************
-- Proceso de Actualizacion :
--***************************************************************************************************

        SELECT tipo_oper,tipo_mov INTO tipo_opera,tipo_movi
        FROM bdibei:"informix".bei_admin_manco_temp manc
        WHERE manc.id_admin_manco=pIdAdminManco
        AND manc.num_cliente_admin=pNumCliente
        AND manc.id_usuario_admin=pIdUsuario;


       IF NVL(tipo_opera,0) == 0 THEN
	 	LET cCod_ret = '00004'; -- No contiene Dato tipo operacion
          RETURN cCod_ret, id_adminMancoTemp;
       END IF;

        IF NVL(tipo_movi,0) == 0 THEN
	 	  LET cCod_ret = '00005'; -- No contiene Dato tipo movimiento
            RETURN cCod_ret, id_adminMancoTemp;
        END IF;



        INSERT INTO "informix".bei_admin_manco_temp_hist(id_admin_manco,
            num_cliente_admin, id_usuario_admin, 
            id_usuario_aut, status_aut, fecha_aut, 
            tipo_oper, tipo_mov, id_usuario, 
            num_cliente, id_status, id_tipo_usuario, 
            cia_cel, e_mail, activo, id_perfil, 
            ns_token, suc_registro, folio_token, id_status_token)
        VALUES(0,
            pNumCliente, pIdUsuario, pIdUsuarioAut, pStatusAut, 
            TO_DATE(pFechaAut ,'%d/%m/%Y'), 
            tipo_opera, tipo_movi, -1, pNumCliente, 1, -1, -1, '', 
            't', -1, '', '', '', -1
        );
        LET id_adminMancoTemp = DBINFO('sqlca.sqlerrd1');

        DELETE FROM "informix".bei_admin_manco_montos_temp 
        WHERE id_admin_manco=pIdAdminManco
        AND num_cliente=pNumCliente
        AND id_usuario=pIdUsuario;


        DELETE FROM "informix".bei_admin_manco_temp
        WHERE id_admin_manco=pIdAdminManco;

		RETURN cCod_ret, id_adminMancoTemp;

	END;

END PROCEDURE;