CREATE PROCEDURE "informix".sp_consulta_datos_detalle_renovtoken(pIdMancomunidad INTEGER)

RETURNING CHAR(5), INTEGER, CHAR(50), INTEGER, CHAR(20), CHAR(10), CHAR(10), INTEGER;
--RETURN cod_ret, sTipoMov, sSolicita, sNumTokens, sCuentaCargo, sImporte, sFechaOperacion, sIdUsrSolicito;

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE vNumCliente CHAR(9);
    
    DEFINE sTipoMov         INTEGER;
    DEFINE sSolicita        CHAR(50);
    DEFINE sNumTokens       INTEGER;
    DEFINE sCuentaCargo     CHAR(20);
    DEFINE sImporte         CHAR(10);
    DEFINE sFechaOperacion  CHAR(10);
    DEFINE sIdUsrSolicito   INTEGER;

    LET cod_ret         = "00000";
    LET vNumCliente     = "";
    LET sTipoMov        = 0;
    LET sSolicita       = "";
    LET sNumTokens      = 0;
    LET sCuentaCargo    = "";
    LET sImporte        = "100";
    LET sFechaOperacion = "";    
    LET sIdUsrSolicito  = 0;

--****************************************************************************************************
-- DESCRIPCION: sp que consulta el detalle de la solicitud de renovacion de token mancomunada
-- AUTOR : SOLSER
-- FECHA : 24/Agosto/2018
-- BD: bdibei
--***************************************************************************************************


--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_datos_detalle_renovtoken.out";
--TRACE ON;

 SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, sTipoMov, sSolicita, sNumTokens, sCuentaCargo, sImporte, sFechaOperacion, sIdUsrSolicito;
      END IF ;
   END EXCEPTION ;

    IF NVL(pIdMancomunidad,'') == '' THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret, sTipoMov, sSolicita, sNumTokens, sCuentaCargo, sImporte, sFechaOperacion, sIdUsrSolicito;
    END IF;

	SELECT  NVL(fecha_hoy, '') 
	into sFechaOperacion
 	from bdinteg:si_fechas;
		
    SELECT manc.tipo_mov, REPLACE(REPLACE(REPLACE(TRIM(dtus.nombre),' ','<>' ),'><','' ),'<>',' ') AS elaboro, manc.num_cliente_admin, manc.id_usuario_admin
        INTO sTipoMov, sSolicita, vNumCliente, sIdUsrSolicito
    FROM bdibei:"informix".bei_admin_manco_temp manc
    LEFT JOIN bdibei:"informix".bei_usuario us ON us.id_usuario = manc.id_usuario_admin
    INNER JOIN bdibei:"informix".bei_datos_usuario dtus ON(dtus.id_usuario = manc.id_usuario_admin)
        WHERE manc.id_admin_manco = pIdMancomunidad;

    SELECT NVL(COUNT(*), 0)
        INTO sNumTokens 
    FROM bdibei:"informix".bei_tokenexpira
        WHERE num_cte = vNumCliente
        AND id_status_solicitud = '2';
	
	 
	SELECT num_cta
        INTO  sCuentaCargo
  	FROM bdibei:bei_admin_manco_det_temp  --bei_bitacora
        WHERE id_admin_manco = pIdMancomunidad;


    RETURN cod_ret, sTipoMov, SUBSTRING(sSolicita FROM 0 FOR 50), sNumTokens, sCuentaCargo, sImporte, sFechaOperacion, sIdUsrSolicito;

END
END PROCEDURE;