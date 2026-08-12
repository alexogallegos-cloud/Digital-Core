CREATE PROCEDURE "informix".sps_montos_manc_aut_bei(
												pNumCliente char(9),
												pIdUser integer,
												pNoReg integer,
												pRegIni integer)
   returning
   CHAR(5),
   INTEGER,
   INTEGER,
   CHAR(50),
   CHAR(2),
   INTEGER;



    DEFINE cod_ret 			CHAR(5);
    DEFINE sql_err 			INTEGER ;
    DEFINE iTotalReg 		INTEGER ;
    DEFINE sTipoOperacion	CHAR(2);
    DEFINE iIdMancomunidad 	INTEGER;
    DEFINE sUserNom         CHAR(50);
    DEFINE sIdUser        INTEGER;
    
    LET iTotalReg=0;
    LET cod_ret  = "00000";
    LET sTipoOperacion  = '';
    LET iIdMancomunidad=0;
    LET sUserNom 	= '';
    LET sIdUser	=0;


	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS MONTOS PENDIENTES POR AUTORIZAR
	-- AUTOR : Jesus Ferruzca Luna - SOLSER
	-- FECHA : 08/01/2015
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, iTotalReg,iIdMancomunidad,sUserNom,sTipoOperacion,sIdUser;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

  SET LOCK MODE TO WAIT 4;

            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=3
            AND (usu.tipo_mov = 7 or  usu.tipo_mov=8)
            AND usu.num_cliente_admin = pNumCliente;


     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No ay Registros
         RETURN cod_ret, iTotalReg,iIdMancomunidad,sUserNom,sTipoOperacion,sIdUser;
      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

          FOREACH

            Select SKIP pRegIni FIRST pNoReg  distinct mt.id_admin_manco, us.usuario_bei, mm.restricc,us.id_usuario
            Into   iIdMancomunidad, sUserNom, sTipoOperacion,sIdUser
            From   "informix".bei_admin_manco_temp mt
            Inner Join "informix".bei_admin_manco_montos_temp mm On(mt.id_admin_manco = mm.id_admin_manco)
            Inner Join "informix".bei_usuario us On(us.id_usuario = mt.id_usuario_admin)
            Where  mt.tipo_oper = 3
            AND mt.id_usuario_admin<>pIdUser
            AND (mt.tipo_mov = 7 or  mt.tipo_mov=8)
            AND mt.num_cliente_admin = pNumCliente

   			IF NVL(sUserNom,'') == '' THEN
	 	 		LET sUserNom = '';
			END IF;

            IF NVL(sTipoOperacion,'') == '' THEN
	 	 		LET sTipoOperacion = '';
			END IF;


           RETURN cod_ret, iTotalReg,iIdMancomunidad,sUserNom,sTipoOperacion,sIdUser WITH RESUME;
          END FOREACH;


END
END PROCEDURE;