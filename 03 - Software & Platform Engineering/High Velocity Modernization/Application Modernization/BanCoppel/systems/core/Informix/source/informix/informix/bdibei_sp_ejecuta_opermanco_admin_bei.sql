CREATE PROCEDURE "informix".sp_ejecuta_opermanco_admin_bei(
pIdAdminManco INTEGER,pNumCliente CHAR(9),pIdUsuario INTEGER,pAutoriza SMALLINT)
 returning char(5) ,INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE stipoOper SMALLINT ;
    DEFINE sTipoMov SMALLINT ;

    DEFINE sIdUserAdmin 		INTEGER ;

  	DEFINE sIdUsuario 		INTEGER ;
  	DEFINE sNumCliente		CHAR(9);

  	DEFINE sIdStatus  		SMALLINT ;
  	DEFINE sUserNom 		CHAR(250) ;
  	DEFINE sPass 			CHAR(250) ;
  	DEFINE sIdTipoUser 		SMALLINT ;

 	DEFINE sNombre 			CHAR(150) ;
 	DEFINE sTelCelular 		CHAR(15) ;
    DEFINE sCiaCel 			SMALLINT ;
    DEFINE sEmail 			CHAR(50) ;

 	DEFINE sIdPerfil INTEGER ;
 	DEFINE sNomPerfil CHAR(50);

    DEFINE sNsToken VARCHAR(10) ;
    DEFINE sIdStatusToken INTEGER ;

 	DEFINE sAut BOOLEAN;
	 DEFINE sCount 			SMALLINT ;
 	DEFINE sIdOper        				INTEGER ;
    DEFINE sIdMenuOper             		INTEGER ;
    DEFINE sNumCta      				CHAR(20);
    DEFINE sMontoMin         			DECIMAL(16,2);
    DEFINE sMontoMax         			DECIMAL(16,2);
    DEFINE sMancomunado     			BOOLEAN;

    LET cod_ret  = "00000";
    LET stipoOper  = 0;
    LET sTipoMov  = 0;
    LET sIdUsuario  = 0;
    LET sNsToken  = "";
    LET sIdStatusToken  = 0;
    LET sIdPerfil  = 0;
 	LET sCount=0;
    LET sAut  = 'f';

--****************************************************************************************************
-- DESCRIPCION:  Ejecuta Proceso de Mancomuniadd
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
	--		ROLLBACK WORk;
          RETURN cod_ret,sIdUsuario;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

	IF NVL(pIdAdminManco,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cod_ret,sIdUsuario;
	END IF;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
       RETURN cod_ret,sIdUsuario;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Dato Id de Usuario
        RETURN cod_ret,sIdUsuario;
	END IF;
	IF NVL(pAutoriza,0) == 0 THEN
	 	  LET cod_ret = '00004'; -- No contiene Dato de Autorizacion
         RETURN cod_ret,sIdUsuario;
	END IF;



		SELECT  id_usuario_admin,manco.tipo_oper,manco.tipo_mov
	 	INTO  	sIdUserAdmin,stipoOper,sTipoMov
        FROM bdibei:"informix".bei_admin_manco_temp  manco
        WHERE  manco.id_admin_manco  = pIdAdminManco
        AND manco.num_cliente_admin  = pNumCliente;


        IF NVL(stipoOper,999) == 999  THEN
        	 	  LET cod_ret = '00005'; --No contiene Dato de Tipo de Operacion
         RETURN cod_ret,sIdUsuario;
		END IF;

        IF NVL(sTipoMov,999) == 999  THEN
        	 	  LET cod_ret = '00006'; -- No contiene Dato de Tipo de Movimiento
        	 	  RETURN cod_ret,sIdUsuario;
		END IF;

     IF(pAutoriza==1)THEN
        IF stipoOper==1  THEN
            IF sTipoMov==1 THEN

            	SELECT  usu.num_cliente,usu.id_status,usu.usuario_bei,
	 					usu.pass,usu.id_tipo_usuario,usu.nombre_user,usu.tel_celular,
            			usu.cia_cel,usu.e_mail,usu.nom_perfil
            	INTO 	sNumCliente,sIdStatus,sUserNom,sPass,
            			sIdTipoUser,sNombre,sTelCelular,
            			sCiaCel,sEmail,sNomPerfil
            	FROM bdibei:"informix".bei_admin_manco_temp  usu
            	WHERE  usu.id_admin_manco  = pIdAdminManco
            	AND usu.num_cliente_admin=pNumCliente ;



          --      EXECUTE PROCEDURE bdibei:"informix".sp_crea_usuario_bei(sNumCliente,sIdStatus, sUserNom,sPass,sIdTipoUser,sNomPerfil,sNombre,sTelCelular,sCiaCel,sEmail,pIdUsuario)
			--	into cod_ret,sIdUsuario,sIdPerfil;

       
            	INSERT INTO bdibei:"informix".bei_perfil
				(id_perfil,nombre,activo,createdby,createdon,updatedby,updatedon) VALUES
				(0, sNomPerfil,'t',pIdUsuario,CURRENT YEAR TO DAY ,pIdUsuario,CURRENT YEAR TO DAY );

				LET sIdPerfil = DBINFO('sqlca.sqlerrd1');

           		INSERT INTO bdibei:"informix".bei_usuario
				(id_usuario,num_cliente,id_status,usuario_bei,pass,f_pass,f_status,f_registro,id_tipo_usuario) VALUES
				(0,sNumCliente,sIdStatus,sUserNom,sPass,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,sIdTipoUser );


				LET sIdUsuario = DBINFO('sqlca.sqlerrd1');


        		INSERT INTO bdibei:"informix".bei_datos_usuario
				(id_usuario,nombre,tel_celular,cia_cel,e_mail,activo) VALUES
				(sIdUsuario, sNombre,sTelCelular,sCiaCel,sEmail,'t' );

				INSERT INTO bdibei:"informix".bei_usuario_perfil
				(id_perfil,id_usuario) VALUES
				(sIdPerfil, sIdUsuario );



				FOREACH
      				SELECT  num_cta,autoriza
            		INTO 	sNumCta,sAut
            		FROM 	bdibei:"informix".bei_admin_manco_det_temp
            		WHERE   id_admin_manco  = pIdAdminManco
            		AND 	tipo_oper=1

         			INSERT INTO bdibei:"informix".bei_mancomunidad
					(id_usuario,num_cte,num_cta,autoriza) VALUES
					(sIdUsuario, sNumCliente,sNumCta,sAut );

         		END FOREACH;


				FOREACH
      				SELECT  id_oper,id_menu_oper,num_cta,monto_min,monto_max,mancomunado
            		INTO 	sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado
            		FROM 	bdibei:"informix".bei_admin_manco_det_temp
            		WHERE   id_admin_manco  = pIdAdminManco
            		AND 	tipo_oper=2

         		INSERT INTO bdibei:"informix".bei_operaciones
				(id_oper,id_menu_oper,id_perfil,num_cta,monto_min,monto_max,mancomunado,createdby,createdon,updatedby,updatedon) VALUES
				(0, sIdMenuOper,sIdPerfil,sNumCta,sMontoMin, sMontoMax,sMancomunado,sIdUserAdmin,CURRENT YEAR TO DAY,sIdUserAdmin,CURRENT YEAR TO DAY);


         		END FOREACH;

            ELIF sTipoMov==3 THEN

            	SELECT  usu.id_usuario,usu.num_cliente,usu.id_status,usu.usuario_bei,
	 					usu.pass,usu.id_tipo_usuario,usu.nombre_user,usu.tel_celular,
            			usu.cia_cel,usu.e_mail,usu.id_perfil,usu.nom_perfil
            	INTO 	sIdUsuario,sNumCliente,sIdStatus,sUserNom,sPass,
            			sIdTipoUser,sNombre,sTelCelular,
            			sCiaCel,sEmail,sIdPerfil,sNomPerfil
            	FROM bdibei:"informix".bei_admin_manco_temp  usu
            	WHERE  usu.id_admin_manco  = pIdAdminManco
            	AND usu.num_cliente_admin=pNumCliente ;

            	EXECUTE PROCEDURE bdibei:"informix".sp_actualiza_usuario_bei(sNumCliente,sIdUsuario, sPass,sNombre,sTelCelular,sCiaCel,sEmail,sIdUserAdmin,sUserNom)
				into cod_ret;

				IF(cod_ret<>'00000') THEN
					RETURN cod_ret,sIdUsuario;
				END IF;

				FOREACH
      				SELECT  num_cta,autoriza
            		INTO 	sNumCta,sAut
            		FROM 	bdibei:"informix".bei_admin_manco_det_temp
            		WHERE   id_admin_manco  = pIdAdminManco
            		AND 	tipo_oper=1

				IF NVL(sIdUsuario,-1) == -1 THEN
					LET cod_ret = '01002';   ---No se Recibio ID de Usuario
	    			RETURN cod_ret,sIdUsuario;
	 			END IF;

	 			IF NVL(sNumCliente,'') == '' THEN
					LET cod_ret = '01003';   ---No se Recibio Numero de Cliente
	    			RETURN cod_ret,sIdUsuario;
	 			END IF;

	 			IF NVL(sNumCta,'') == '' THEN
					LET cod_ret = '01004';   ---No se Recibio Numero de Cuenta
	    			RETURN cod_ret,sIdUsuario;
	 			END IF;


 			IF EXISTS ( 	SELECT id_usuario
	   						FROM bdibei:"informix".bei_mancomunidad
	   						WHERE id_usuario =sIdUsuario
							AND num_cte = sNumCliente
							AND num_cta = sNumCta) THEN

				UPDATE  bdibei:"informix".bei_mancomunidad
				SET autoriza = sAut
				WHERE id_usuario = sIdUsuario
				AND num_cte =sNumCliente
				AND num_cta =sNumCta;

			ELSE

	  			INSERT INTO bdibei:"informix".bei_mancomunidad
				(id_usuario,num_cte,num_cta,autoriza) VALUES
				(sIdUsuario, sNumCliente,sNumCta,sAut );

			END IF;


				IF(cod_ret<>'00000') THEN
					RETURN cod_ret,sIdUsuario;
				END IF;

         		END FOREACH;
----------------------
----------------------
---                ---
----------------------
----------------------
					SELECT  COUNT(id_admin_manco)
            		INTO 	sCount
            		FROM 	bdibei:"informix".bei_admin_manco_det_temp
            		WHERE   id_admin_manco  = pIdAdminManco
            		AND 	tipo_oper=2;


		IF(sCount>0) THEN
				EXECUTE PROCEDURE bdibei:"informix".sp_elimina_operaciones_bei(sIdPerfil)
            	INTO cod_ret;

            	IF(cod_ret<>'00000') THEN
					RETURN cod_ret,sIdUsuario;
				END IF;

		END IF;


				FOREACH
      				SELECT  id_oper,id_menu_oper,num_cta,monto_min,monto_max,mancomunado,id_perfil
            		INTO 	sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado,sIdPerfil
            		FROM 	bdibei:"informix".bei_admin_manco_det_temp
            		WHERE   id_admin_manco  = pIdAdminManco
            		AND 	tipo_oper=2

         		INSERT INTO bdibei:"informix".bei_operaciones
				(id_oper,id_menu_oper,id_perfil,num_cta,monto_min,monto_max,mancomunado,createdby,createdon,updatedby,updatedon) VALUES
				(0, sIdMenuOper,sIdPerfil,sNumCta,sMontoMin, sMontoMax,sMancomunado,sIdUserAdmin,CURRENT YEAR TO DAY,sIdUserAdmin,CURRENT YEAR TO DAY);


         		END FOREACH;

            ELSE
              	LET cod_ret = '00007'; -- Valor Incorrecto de Tipo de Movimiento
        	 	RETURN cod_ret,sIdUsuario;
            END IF;
        ELSE
             LET cod_ret = '00008'; -- Valor Incorrecto de Tipo Operaciones
        	 RETURN cod_ret,sIdUsuario;
        END IF;
     END IF;

     RETURN cod_ret,sIdUsuario;
END
END PROCEDURE;