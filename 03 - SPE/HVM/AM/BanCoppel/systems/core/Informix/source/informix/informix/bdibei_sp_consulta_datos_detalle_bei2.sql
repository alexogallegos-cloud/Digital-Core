CREATE PROCEDURE "informix".sp_consulta_datos_detalle_bei2(pIdMancomunidad Integer)
   returning char(5), Integer, CHAR(50),CHAR(50),CHAR(150),CHAR(15),CHAR(50),CHAR(50), CHAR(50);


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    
    DEFINE sIdUsuario           INTEGER;
    DEFINE sIdStatusToken       CHAR(50);
    DEFINE sTipoMov             INTEGER;
    DEFINE sSolicita			CHAR(50);
    DEFINE sUsuario             CHAR(50);
    DEFINE sNombre              CHAR(150);
    DEFINE sTelCelular          CHAR(15);
    DEFINE sEmail               CHAR(50);
    DEFINE sToken 				CHAR(50);
    DEFINE sTokenAux            CHAR(50);


    LET cod_ret     = "00000";
    LET sTipoMov 	= 0;
    LET sSolicita	= "";
    LET sUsuario    = "";
    LET sNombre     = "";
    LET sTelCelular = "";
    LET sEmail      = "";
    LET sToken		= "";
    LET sTokenAux   = "";
    LET sIdStatusToken = "";
    

	--****************************************************************************************************
	-- DESCRIPCION: se clona y modifica el spl para mostrar el nombre de la persona en lugar de usuario
	-- AUTOR : SOLSER
	-- FECHA : NA
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- LIBERADO A PRODUCCION: 23-Junio-2015
	
	
	-- INFORMACION DE SPL ORIGINAL-----
	-- DESCRIPCION: Consultar los datos para presentar el detalle de un operacion con mancomunidad
	-- AUTOR : Jesus Ferruzca Luna / SOLSER
	-- FECHA : 11/02/2014
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- LIBERADO A PRODUCCION: Mayo 2014
	--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sTipoMov, sSolicita, sUsuario, sNombre, sTelCelular, sEmail, sToken, sIdStatusToken;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************

   IF NVL(pIdMancomunidad,'') == '' THEN
          LET cod_ret = '00001'; -- No mando ID de Mancomunidad
         RETURN cod_ret, sTipoMov, sSolicita, sUsuario, sNombre, sTelCelular, sEmail, sToken, sIdStatusToken;
   END IF ;
	
	Select manc.tipo_mov, replace(replace(replace (trim(dtus.nombre),' ','<>' ),'><','' ),'<>',' ' ) as elaboro, manc.id_usuario, manc.ns_token,tkn.ns_token, manc.id_status_token
	Into sTipoMov, sSolicita, sIdUsuario, sToken,sTokenAux, sIdStatusToken
	From bdibei:"informix".bei_admin_manco_temp manc
	Left Join bdibei:"informix".bei_usuario us On us.id_usuario = manc.id_usuario_admin
	Left Join bdibei:"informix".bei_token tkn On tkn.id_usuario = us.id_usuario
    Inner Join bdibei:"informix".bei_datos_usuario dtus On(dtus.id_usuario = manc.id_usuario_admin)
	Where manc.id_admin_manco = pIdMancomunidad;

    Select replace(replace(replace (trim(u.nombre),' ','<>' ),'><','' ),'<>',' ' ), 
           replace(replace(replace (trim(u.nombre),' ','<>' ),'><','' ),'<>',' ' ),
            u.tel_celular,u.e_mail
    Into sUsuario, sNombre, sTelCelular, sEmail
    From bdibei:"informix".bei_datos_usuario u
    Inner Join bdibei:"informix".bei_usuario us On us.id_usuario = u.id_usuario
    Where u.id_usuario = sIdUsuario;

              IF sTipoMov==6 THEN
                let sToken=sTokenAux;
               END IF;
    
   
  RETURN cod_ret, sTipoMov, SUBSTRING(sSolicita FROM 0 FOR 50), SUBSTRING(sUsuario FROM 0 FOR 50), sNombre, sTelCelular, sEmail, sToken, sIdStatusToken;

END
END PROCEDURE;