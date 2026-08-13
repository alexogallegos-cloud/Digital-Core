CREATE PROCEDURE "informix".sp_obtener_numcte_status_bei(
    pNumCte CHAR(20),
    pIdUsuario CHAR(30),
    pIdentificacionAdmin CHAR(30)

)
RETURNING CHAR(5), CHAR(20), SMALLINT, INTEGER, INTEGER,DATETIME YEAR to SECOND;

   DEFINE cCod_ret CHAR(5);
   DEFINE sql_err INTEGER;
   DEFINE sId_status SMALLINT;
   DEFINE iId_status_token INTEGER;
   DEFINE cNum_cte CHAR (20);
   DEFINE cNsToken CHAR (50);
   DEFINE iIdusuario Integer;
   DEFINE iFecBloqueo DATETIME YEAR to SECOND;

   LET cCod_ret       = "00000";
   LET sId_status = 0;
   LET iId_status_token = 0;
   LET cNum_cte = "";
   Let iIdusuario = 0;
   LET cNsToken='';
   LET iFecBloqueo='1900-01-01 00:00:00';

	--****************************************************************************************************
	-- DESCRIPCION:  REGRESA EL ESTATUS USUARIO, ESTATUS TOKEN, NUMERO CLIENTE Y SI TIENE UN BLOQUEO.
	-- AUTOR : SOLSER
	-- FECHA :
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, NVL(cNum_cte,''), NVL(sId_status,-1), NVL(iId_status_token,-1),NVL(iIdusuario,-1),iFecBloqueo;
      END IF
   END EXCEPTION;


	IF  NVL(pIdentificacionAdmin,'') == '' THEN
        SELECT usuario.num_cliente, servicio.id_status,
            usuario.id_usuario,servicio.ns_token,usuario.f_bloqueo_temp
    	INTO cNum_cte, sId_status,  iIdusuario,cNsToken,iFecBloqueo
    	FROM bdibei:"informix".bei_usuario AS usuario
    	INNER JOIN bdibei:"informix".bei_servicio AS servicio
            ON usuario.id_usuario = servicio.id_usuario
            AND usuario.num_cliente = servicio.num_cliente 
    	WHERE   usuario.num_cliente = pNumCte
		AND     servicio.id_usuario = pIdUsuario;
	ELIF NVL(pIdUsuario,'') == '' THEN
    	SELECT usuario.num_cliente, servicio.id_status,
            usuario.id_usuario,servicio.ns_token,usuario.f_bloqueo_temp
     	INTO cNum_cte, sId_status,  iIdusuario,cNsToken,iFecBloqueo
     	FROM bdibei:"informix".bei_usuario AS usuario
     	INNER JOIN bdibei:"informix".bei_servicio AS servicio
            ON usuario.id_usuario = servicio.id_usuario
            AND usuario.num_cliente = servicio.num_cliente 
     	WHERE   usuario.num_cliente = pNumCte
	 	AND     servicio.identificacion_admin = pIdentificacionAdmin;
    ELIF NVL(pNumCte,'') <> '' THEN
        SELECT usuario.num_cliente, servicio.id_status,
            usuario.id_usuario,servicio.ns_token,usuario.f_bloqueo_temp
     	INTO cNum_cte, sId_status,  iIdusuario,cNsToken,iFecBloqueo
     	FROM bdibei:"informix".bei_usuario AS usuario
     	INNER JOIN bdibei:"informix".bei_servicio AS servicio
            ON usuario.id_usuario = servicio.id_usuario
            AND usuario.num_cliente = servicio.num_cliente 
     	WHERE   usuario.num_cliente = pNumCte
	 	AND     servicio.identificacion_admin = pIdentificacionAdmin
        AND     servicio.id_usuario = pIdUsuario;
	END IF;




    IF cNum_cte IS NULL THEN
        LET cCod_ret = '00001'; --No existe asociacion #cliente con nombre de usuario
    END IF;


  	 IF cNsToken IS NOT NULL THEN

      SELECT id_status_token
      INTO iId_status_token
      FROM bdibei:"informix".bei_token
      WHERE id_usuario=iIdusuario
      AND num_cliente=pNumCte
      AND ns_token=cNsToken;

    END IF;


     IF NVL(iFecBloqueo,'1900-01-01 00:00:00') == '1900-01-01 00:00:00'  THEN
		LET iFecBloqueo='1900-01-01 00:00:00';
      END IF;

    IF iId_status_token == 0 THEN
      LET iId_status_token = -1; --En caso de que el VAlor de Token regrese Cero, se cambia el valor a -1 para que el sistema reconozca que no tiene token asociado
    END IF;

  RETURN cCod_ret, NVL(cNum_cte,''), NVL(sId_status,-1), NVL(iId_status_token,-1),NVL(iIdusuario,-1),iFecBloqueo;

END

END PROCEDURE ;