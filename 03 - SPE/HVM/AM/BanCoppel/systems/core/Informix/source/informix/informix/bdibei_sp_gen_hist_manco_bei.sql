CREATE PROCEDURE "informix".sp_gen_hist_manco_bei(pNumCliente VARCHAR(9), pIdUsuario INTEGER, pIdAdminManco INTEGER, pStatusAut SMALLINT)
RETURNING CHAR(5), INTEGER;

--****************************************************************************************************
-- DESCRIPCION:
-- AUTOR: Irving Guzman Salas
-- FECHA: 24/05/2013
-- BD: bdibei
-- SOLICITO:
-- MODIFICACION: Se agrego el valor de retorno integer que es el id_adminMancoTemp (06/06/2018)
-- FECHA: 21/03/2017

--***************************************************************************************************


	DEFINE sql_err INT;
	DEFINE cod_ret CHAR(5);
	DEFINE stipoOper SMALLINT;
	DEFINE sTipoMov SMALLINT;
	DEFINE sCountDet SMALLINT;
	DEFINE sCountH SMALLINT;
	DEFINE id_adminMancoTemp INTEGER;
	
	LET cod_ret = '00000';

	LET stipoOper = 0;
	LET sTipoMov = 0;
	LET sCountDet = 0;
	LET sCountH = 0;
	LET id_adminMancoTemp = 0;

	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret, id_adminMancoTemp;
		  END IF ;
		END EXCEPTION ;
--****************************************************************************************************
-- Valida Si Nombre de Usuario ya esta Registrado:
--***************************************************************************************************

		SET LOCK MODE TO WAIT 3 ;
		SET ISOLATION DIRTY READ ;

		
	IF NVL(pIdAdminManco,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cod_ret, id_adminMancoTemp;
	END IF;

	IF NVL(pNumCliente,'') == '' THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
        RETURN cod_ret, id_adminMancoTemp;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Dato Id de Usuario
        RETURN cod_ret, id_adminMancoTemp;
	END IF;

	IF NVL(pStatusAut,0) == 0 THEN
	 	  LET cod_ret = '00004'; -- No contiene Dato Id de Usuario
        RETURN cod_ret, id_adminMancoTemp;
	END IF;

		SELECT 	COUNT(id_admin_manco)
		INTO sCountH
		FROM "informix".bei_admin_manco_temp  manco
		WHERE  manco.id_admin_manco  = pIdAdminManco
    	AND manco.num_cliente_admin  = pNumCliente
    	AND manco.id_usuario_admin  <> pIdUsuario;

    	IF (sCountH<=0)THEN
    	  LET cod_ret = '00007'; -- No Hay Datos que Transferir
       	 	RETURN cod_ret, id_adminMancoTemp;
   		END IF;


		SELECT  manco.tipo_oper,manco.tipo_mov
	 	INTO  	stipoOper,sTipoMov
        FROM "informix".bei_admin_manco_temp  manco
        WHERE  manco.id_admin_manco  = pIdAdminManco
        AND manco.num_cliente_admin  = pNumCliente
        AND manco.id_usuario_admin  <> pIdUsuario
        ;


        IF NVL(stipoOper,999) == 999  THEN
        	 	  LET cod_ret = '00005'; --No contiene Dato de Tipo de Operacion
        	 	  RETURN cod_ret, id_adminMancoTemp;
		END IF;

        IF NVL(sTipoMov,999) == 999  THEN
        	 	  LET cod_ret = '00006'; -- No contiene Dato de Tipo de Movimiento
        	 	  RETURN cod_ret, id_adminMancoTemp;
		END IF;
		
		
		
		
		SELECT count(*)
        INTO sCountDet
        FROM "informix".bei_admin_manco_det_temp manco
        WHERE  manco.id_admin_manco  = pIdAdminManco;
		
		IF (( SELECT count(id_admin_manco) FROM "informix".bei_admin_manco_det_temp_hist manco
                    WHERE  manco.id_admin_manco  = pIdAdminManco) > 0) THEN
                    
               DELETE FROM "informix".bei_admin_manco_det_temp_hist
               WHERE  id_admin_manco  = pIdAdminManco;
        END IF;
		
		

        IF (( SELECT  count(id_admin_manco)  FROM "informix".bei_admin_manco_temp_hist manco
                    WHERE  manco.id_admin_manco  = pIdAdminManco) > 0)  THEN
                   
				   
                    
                DELETE FROM "informix".bei_admin_manco_temp_hist
                WHERE  id_admin_manco  = pIdAdminManco ;
            
        END IF;
		
		
		
        
        INSERT INTO "informix".bei_admin_manco_temp_hist
        (
        id_admin_manco,num_cliente_admin,id_usuario_admin,tipo_oper,
        tipo_mov, id_usuario,num_cliente,id_status,usuario_bei,  pass  ,id_tipo_usuario ,
        nombre_user ,tel_celular ,cia_cel,e_mail ,activo ,id_perfil, nom_perfil,
        ns_token ,suc_registro ,folio_token ,id_status_token	,
        id_usuario_aut, status_aut ,fecha_aut 		)
        SELECT 	0,num_cliente_admin,id_usuario_admin,tipo_oper,tipo_mov,
        NVL(id_usuario,-1),NVL(num_cliente,''),NVL(id_status,-1),NVL(usuario_bei,''), NVL(pass,'')  ,NVL(id_tipo_usuario,-1) ,
        NVL(nombre_user,'') ,NVL(tel_celular,'') ,NVL(cia_cel,-1),NVL(e_mail,'') ,NVL(activo,'f') ,	NVL(id_perfil,-1), NVL(nom_perfil,''),
        NVL(ns_token,'') ,NVL(suc_registro,'') ,NVL(folio_token,'') ,NVL(id_status_token,-1),	NVL(pIdUsuario,-1),pStatusAut,CURRENT
        FROM "informix".bei_admin_manco_temp manco
        WHERE  manco.id_admin_manco  = pIdAdminManco
        AND manco.num_cliente_admin  = pNumCliente
        AND manco.id_usuario_admin  <> pIdUsuario;
		LET id_adminMancoTemp = DBINFO('sqlca.sqlerrd1');
        
        SELECT count(*)
        INTO sCountDet
        FROM "informix".bei_admin_manco_det_temp manco
        WHERE  manco.id_admin_manco  = pIdAdminManco;

    	IF (sCountDet<=0)THEN
    	  LET cod_ret = '00000'; -- No ay Datos Detalle que Transferir
    	  DELETE FROM "informix".bei_admin_manco_temp
		  WHERE  id_admin_manco  = pIdAdminManco;

       	  RETURN cod_ret, id_adminMancoTemp;
   		END IF;
        
        IF (( SELECT count(id_admin_manco) FROM "informix".bei_admin_manco_det_temp_hist manco
                    WHERE  manco.id_admin_manco  = id_adminMancoTemp) > 0) THEN
                    
               DELETE FROM "informix".bei_admin_manco_det_temp_hist
               WHERE  id_admin_manco  = id_adminMancoTemp;
        END IF;
        
        INSERT INTO "informix".bei_admin_manco_det_temp_hist
        (id_admin_manco,tipo_oper,id_usuario,num_cte,autoriza,id_oper,id_menu_oper,id_perfil,
        num_cta,monto_min,monto_max,mancomunado		)
        SELECT 	id_adminMancoTemp,tipo_oper, NVL(id_usuario,-1),NVL(num_cte,''),NVL(autoriza,'f'),
        NVL(id_oper,-1) ,NVL(id_menu_oper,-1) ,NVL(id_perfil,-1) ,
        NVL(num_cta,'') ,NVL(monto_min,0) ,NVL(monto_max,0),NVL(mancomunado,'f')
        FROM "informix".bei_admin_manco_det_temp manco
        WHERE  manco.id_admin_manco  = pIdAdminManco;

		DELETE FROM "informix".bei_admin_manco_det_temp
		WHERE  id_admin_manco  = pIdAdminManco;

		DELETE FROM "informix".bei_admin_manco_temp
		WHERE  id_admin_manco  = pIdAdminManco;

		RETURN cod_ret, id_adminMancoTemp;

	END;

END PROCEDURE;