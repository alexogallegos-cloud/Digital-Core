CREATE PROCEDURE "informix".sp_consultasolicitudes_renovtkn_manco(pNumCliente CHAR(9), pIdUsuarioSesion INTEGER, pNoReg INTEGER, pRegIni INTEGER)

RETURNING CHAR(5), INTEGER, INTEGER, INTEGER, INTEGER, CHAR(50);
--RETURN cod_ret, iTotalReg, sNumTokensRenov, IdMancomunidad, sIdUsuarioSolicito, sNomUsuarioSolicito;

    DEFINE cod_ret 			CHAR(5);
    DEFINE sql_err 			INTEGER;

    DEFINE iTotalReg                INTEGER;
    DEFINE sNumTokensRenov          INTEGER;
    DEFINE sIdMancomunidad          INTEGER;
    DEFINE sIdUsuarioSolicito       INTEGER; -- El id del usuario que solicito la renovacion
	DEFINE sNomUsuarioSolicito      CHAR(50); -- El nombre del usuario que solicito la renovacion

    LET cod_ret                 = "00000";
    LET iTotalReg               = 0;
    LET sNumTokensRenov         = 0;
    LET sIdMancomunidad         = 0;
    LET sIdUsuarioSolicito      = 0;
    LET sNomUsuarioSolicito     = '';

--****************************************************************************************************
-- DESCRIPCION: se consultan las solicitudes de renovacion de token pendientes de autorizar
-- AUTOR : SOLSER
-- FECHA : 22/Agosto/2018
-- BD: bdibei
--***************************************************************************************************

--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consultasolicitudes_renovtkn_manco.out";
 -- TRACE ON;
 
 
  SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;



  BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, iTotalReg, sNumTokensRenov, sIdMancomunidad, sIdUsuarioSolicito, sNomUsuarioSolicito;
        END IF;
    END EXCEPTION;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

    

    SELECT COUNT(*)
        INTO iTotalReg
    FROM bdibei:"informix".bei_admin_manco_temp amt
        WHERE amt.num_cliente_admin  = pNumCliente
        AND amt.id_usuario_admin <> pIdUsuarioSesion
        AND amt.tipo_oper = 2
        AND amt.tipo_mov = 9;

    IF iTotalReg == 0 THEN
        LET cod_ret = '00001'; -- No se encontraron registros
        RETURN cod_ret, iTotalReg, sNumTokensRenov, sIdMancomunidad, sIdUsuarioSolicito, sNomUsuarioSolicito;
    END IF;


    SELECT replace(replace(replace (trim(dtus.nombre),' ','<>' ),'><','' ),'<>',' ' ), usu.id_usuario_admin, usu.id_admin_manco
        INTO sNomUsuarioSolicito, sIdUsuarioSolicito, sIdMancomunidad
    FROM bdibei:"informix".bei_admin_manco_temp usu
    LEFT JOIN bdibei:"informix".bei_usuario us ON us.id_usuario = usu.id_usuario_admin
    INNER JOIN bdibei:"informix".bei_datos_usuario dtus ON dtus.id_usuario = usu.id_usuario_admin
        WHERE usu.num_cliente_admin = pNumCliente
        AND usu.id_usuario_admin <> pIdUsuarioSesion
        AND usu.tipo_oper = 2
        AND usu.tipo_mov = 9;

    SELECT NVL(COUNT(*), 0)
        INTO sNumTokensRenov 
    FROM bdibei:"informix".bei_tokenexpira
        WHERE num_cte = pNumCliente
        AND id_status_solicitud = '2';

    RETURN cod_ret, iTotalReg, sNumTokensRenov, sIdMancomunidad, sIdUsuarioSolicito, SUBSTRING(sNomUsuarioSolicito FROM 0 FOR 50);


END
END PROCEDURE;