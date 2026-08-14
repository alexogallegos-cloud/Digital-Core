CREATE PROCEDURE "informix".sp_consulta_oper_manco_bei2_historico(
												pNumCliente CHAR(9),
												pIdUser INTEGER,
                                                pIdBitacoraAdmin INTEGER)

   RETURNING
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
    DEFINE sql_err INTEGER;

    DEFINE iTotalReg INTEGER;
    DEFINE iTotalRegT INTEGER;
    DEFINE iTotalRegH INTEGER;
    
    DEFINE sIdManco INTEGER;
    DEFINE sIdUsuario INTEGER;
    DEFINE sUserNom CHAR(50);

    DEFINE sIdUserAdmin INTEGER;
    DEFINE sUserNomAdmin CHAR(50);

    DEFINE sIdStatusAut SMALLINT;
    DEFINE sFechaSolicitud DATE;

    DEFINE sIdTipoOper SMALLINT;
    DEFINE sIdTipoMov SMALLINT;
	DEFINE id_status_token CHAR(5);
    DEFINE id_status_user INTEGER;

	LET sIdManco = 0;
    LET iTotalReg = 0;
    LET iTotalRegT = 0;
    LET iTotalRegH = 0;
    LET cod_ret = "00000";

    LET sIdUsuario = 0;
    LET sUserNom = '';

    LET sIdUserAdmin = 0;
    LET sUserNomAdmin = '';

    LET sIdStatusAut = 0;
    LET sFechaSolicitud = 0;

    LET sIdTipoOper = 0;
    LET sIdTipoMov = 0;
	
	LET id_status_token = '';
    LET id_status_user = 0;


	--***************************************************************************************************
	-- INFORMACION DE SPL ORIGINAL
	-- DESCRIPCION: OBTIENE LAS OPERACION MANCOMUNADAS DE LOS USUARIOS OPERADOR
	-- AUTOR : Irving Guzman Salas
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO :
	--***************************************************************************************************
	
	--****************************************************************************************************
    -- NOTA: Clon del sp sp_consulta_oper_manco_bei2 adecuado con el id_bitacora_admin 
    -- AUTOR: Solser
    -- FECHA: 31/05/2018
	
	-- MODIFICADO PARA LIBERAR: Se ajusta para cumplir las politicas de BD
	-- AUTOR: Berenice Noriega 
	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************



BEGIN

    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, iTotalReg, NVL(sIdUsuario,-1), NVL(sUserNom,''), NVL(sIdUserAdmin,-1), sUserNomAdmin, sIdStatusAut, 
                sFechaSolicitud, sIdTipoOper, sIdTipoMov, id_status_token, id_status_user;
      END IF;
    END EXCEPTION;

	SET ISOLATION DIRTY READ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

    SELECT COUNT(*)
        INTO iTotalRegT
    FROM bdibei:"informix".bei_admin_manco_temp_historico
        WHERE id_bitacora_admin = pIdBitacoraAdmin;

    SELECT COUNT(*)
        INTO iTotalRegH
    FROM bdibei:"informix".bei_admin_manco_temp_hist_historico
        WHERE id_bitacora_admin = pIdBitacoraAdmin;

	SET LOCK MODE TO WAIT 3;

	LET iTotalReg = iTotalRegT + iTotalRegH;

    IF iTotalReg == 0 THEN
        LET cod_ret = '00002'; -- No hay Registros
        RETURN cod_ret, iTotalReg, NVL(sIdUsuario,-1), NVL(sUserNom,''), NVL(sIdUserAdmin,-1), sUserNomAdmin, 
            sIdStatusAut, sFechaSolicitud, sIdTipoOper, sIdTipoMov, id_status_token, id_status_user;
    END IF;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

    SELECT tb.id_admin_manco, tb.id_usuario, tb.id_usuario_admin, tb.usuario_bei_admin, tb.estatus, tb.tipo_oper,
            tb.tipo_mov, tb.usuario_bei, tb.id_status_token, tb.id_status
        INTO sIdManco, sIdUsuario, sIdUserAdmin, sUserNomAdmin, sIdStatusAut, sIdTipoOper,
            sIdTipoMov, sUserNom, id_status_token, id_status_user
    FROM(
        SELECT tmp.id_admin_manco, tmp.id_usuario, tmp.id_usuario_admin, decode(tmp.tipo_mov,1, us.usuario_bei,us.usuario_bei) as usuario_bei_admin,
            4 as estatus, DATE(CURRENT) as fecha_aut, tmp.tipo_oper, tmp.tipo_mov, tmp.usuario_bei, tmp.id_status_token, tmp.id_status                  
        FROM bdibei:"informix".bei_admin_manco_temp_historico tmp
        LEFT JOIN  bdibei:"informix".bei_usuario us ON us.id_usuario = tmp.id_usuario_admin
             WHERE tmp.id_bitacora_admin = pIdBitacoraAdmin      
        UNION
        SELECT hist.id_admin_manco, hist.id_usuario, hist.id_usuario_admin, decode(hist.tipo_mov,1,us.usuario_bei,us.usuario_bei) as usuario_bei_admin,
        hist.status_aut as estatus, hist.fecha_aut, hist.tipo_oper, hist.tipo_mov, hist.usuario_bei, hist.id_status_token, hist.id_status
        FROM bdibei:"informix".bei_admin_manco_temp_hist_historico hist
        LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario = hist.id_usuario_admin
            WHERE hist.id_bitacora_admin = pIdBitacoraAdmin
        ) tb;

   /* SELECT replace(replace(replace(trim(nombre),' ','<>' ),'><','' ),'<>',' ' )
        INTO sUserNom
    FROM bdibei:"informix".bei_datos_usuario
        WHERE id_usuario = NVL(sIdUsuario,-1);

    SELECT replace(replace(replace (trim(nombre),' ','<>' ),'><','' ),'<>',' ' )
        INTO sUserNomAdmin
    FROM bdibei:"informix".bei_datos_usuario
        WHERE id_usuario = NVL(sIdUserAdmin,-1);*/
		
	--************************************************************		
	SELECT nombre
    INTO sUserNom
    FROM bdibei:"informix".bei_datos_usuario
    WHERE id_usuario = sIdUsuario;

    SELECT nombre
    INTO sUserNomAdmin
    FROM bdibei:"informix".bei_datos_usuario
    WHERE id_usuario = sIdUserAdmin;
	--************************************************************		
	

    SELECT fecha_aplic 
        INTO sFechaSolicitud
    FROM bei_bitacora_admin
        WHERE id_bitacora_admin = pIdBitacoraAdmin;
        

    RETURN cod_ret, iTotalReg, NVL(sIdUsuario,-1), SUBSTRING(NVL(sUserNom,'')FROM 0 FOR 50), NVL(sIdUserAdmin,-1), 
        SUBSTRING(NVL(sUserNomAdmin,'')FROM 0 FOR 50), sIdStatusAut, sFechaSolicitud, sIdTipoOper, sIdTipoMov, id_status_token, id_status_user;

END;
END PROCEDURE;