CREATE PROCEDURE "informix".sp_consulta_oper_manco_bei(
												pNumCliente CHAR(9),
												pIdUser integer,
												pNoReg integer,
												pRegIni integer)
   returning
   CHAR(5),
    INTEGER,
    INTEGER,
    CHAR(50),
    INTEGER,
    CHAR(50),
    SMALLINT,
    DATE,
    SMALLINT,
    SMALLINT,
    CHAR(5),
    INTEGER;




    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;
    DEFINE iTotalReg1 INTEGER ;
    DEFINE iTotalReg2 INTEGER ;

   DEFINE sIdManco INTEGER;
    DEFINE sIdUsuario INTEGER;
    DEFINE sUserNom CHAR(50);

    DEFINE sIdUserAdmin INTEGER;
    DEFINE sUserNomAdmin CHAR(50);


    DEFINE sIdStatusAut SMALLINT;
    DEFINE sFechaAut DATE ;

    DEFINE sIdTipoOper SMALLINT;
    DEFINE sIdTipoMov SMALLINT;
	DEFINE id_status_token CHAR(5);
    DEFINE id_status_user INTEGER ;

	LET sIdManco=0;
    LET  iTotalReg1=0;
    LET  iTotalReg=0;
    LET  iTotalReg2=0;
    LET cod_ret  = "00000";

    LET sIdUsuario = 0;
    LET sUserNom  = '';

    LET sIdUserAdmin = 0;
    LET sUserNomAdmin = '';

    LET sIdStatusAut = 0;
    LET sFechaAut = 0;

    LET sIdTipoOper=0;
    LET sIdTipoMov=0;
	
	LET id_status_token = '';
    LET id_status_user=0;




--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LAS OPERACION MANCOMUNADAS DE LOS USUARIOS OPERADOR
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov,id_status_token,id_status_user;
      END IF ;
   END EXCEPTION ;


--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************



        		SELECT COUNT(*)
           		INTO iTotalReg1
            	FROM bdibei:"informix".bei_admin_manco_temp  usu
            	WHERE  usu.num_cliente_admin  = pNumCliente
            	AND usu.id_usuario_admin=pIdUser;

            	SELECT COUNT(*)
           		INTO iTotalReg2
            	FROM bdibei:"informix".bei_admin_manco_temp_hist  usu
            	WHERE  usu.num_cliente_admin  = pNumCliente
            	AND usu.id_usuario_admin=pIdUser;


        LET iTotalReg=iTotalReg1+iTotalReg2;
     SET LOCK MODE TO WAIT 4;

     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No ay Registros
            RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov,id_status_token,id_status_user;
      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

         	FOREACH
                 SELECT SKIP pRegIni FIRST pNoReg  tb.id_admin_manco,tb.id_usuario,tb.id_usuario_admin,tb.usuario_bei_admin,tb.estatus,tb.fecha_aut,tb.tipo_oper,tb.tipo_mov,tb.usuario_bei,tb.id_status_token,tb.id_status
                    INTO   sIdManco,sIdUsuario    ,sIdUserAdmin    ,sUserNomAdmin , sIdStatusAut,sFechaAut    ,sIdTipoOper  ,sIdTipoMov,sUserNom,id_status_token,id_status_user
                FROM(
                    SELECT tmp.id_admin_manco,tmp.id_usuario,tmp.id_usuario_admin,decode(tmp.tipo_mov,1, us.usuario_bei,us.usuario_bei) as usuario_bei_admin,4 as estatus ,DATE(CURRENT) as fecha_aut,tmp.tipo_oper,tmp.tipo_mov,tmp.usuario_bei,tmp.id_status_token,tmp.id_status                  
                    FROM bdibei:"informix".bei_admin_manco_temp  tmp
                    LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=tmp.id_usuario_admin
                    WHERE  tmp.num_cliente_admin  = pNumCliente
                    AND tmp.id_usuario_admin=pIdUser
                    
					UNION
                    SELECT hist.id_admin_manco,hist.id_usuario,hist.id_usuario_admin,decode(hist.tipo_mov,1,us.usuario_bei,us.usuario_bei) as usuario_bei_admin,hist.status_aut as estatus,hist.fecha_aut,hist.tipo_oper,hist.tipo_mov,hist.usuario_bei,hist.id_status_token,hist.id_status
                    FROM bdibei:"informix".bei_admin_manco_temp_hist  hist
                    LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=hist.id_usuario_admin
                    WHERE  hist.num_cliente_admin  = pNumCliente
                    AND hist.id_usuario_admin=pIdUser
                ) tb
                ORDER BY tb.id_admin_manco desc,tb.fecha_aut DESC


                
                IF NVL(sUserNom,'') == '' THEN
                     SELECT usuario_bei
                     INTO sUserNom
                     FROM  bdibei:"informix".bei_usuario
                     WHERE id_usuario = NVL(sIdUsuario,-1);
                END IF;

            	 RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov, id_status_token,id_status_user WITH RESUME;
         	END FOREACH;


END
END PROCEDURE;