CREATE PROCEDURE "informix".sp_ini_session_bei(pEmpresa char(3), pUsuario char(50), pPass char(50),pIp char(15))
   returning char(5), char (20), char(50), smallint, integer, char(19),DATETIME YEAR TO SECOND, integer,char(3), char(20),char(50),smallint,DATETIME YEAR TO SECOND;

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE sIdUsuario integer;
    DEFINE sNumCliente char (20);
    DEFINE iIdStatus smallint ;
    DEFINE fecPrimAcceso date;
    DEFINE fecUltAcceso char(19);
    DEFINE iIdStatusToken integer;
    DEFINE sNombre CHAR(150);
    DEFINE vFecha  DATETIME YEAR TO SECOND;
    DEFINE vIdEmpresa char(3);
    DEFINE nomEmpresa char(50);
    DEFINE sCuenta CHAR(20);
    DEFINE sIdTipoUsuario smallint;
	DEFINE sFBloqueoTemp DATETIME YEAR TO SECOND;

    LET cod_ret  = "000";
    LET sIdUsuario = 0;
    LET sNumCliente  = '';
    LET iIdStatus = 0;
    LET fecUltAcceso = '';
    LET iIdStatusToken = 0;
    LET sNombre = '';
    LET vFecha= '1900-01-01 00:00:00';
    LET sFBloqueoTemp= '1900-01-01 00:00:00';
    LET vIdEmpresa='';
    LET nomEmpresa='';
    LET sCuenta = '';
      LET sIdTipoUsuario = 0;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS PARA INICIAR LA SESION EN LA BANCA EMPRESARIAL
-- AUTOR : Irving Guzman Salas
-- FECHA : 26/04/2013
-- BD: bdibei
-- SOLICITO :
-- Modificación: Se inicializa la variabe de fechabloqueo cuando ele status es 95 o 10.
-- Modifica: Berenice Noriega - BanCoppel.
-- Fecha Mod: 23/Junio/2014
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sNumCliente, sNombre, iIdStatus, iIdStatusToken, fecUltAcceso,vFecha,sIdUsuario,vIdEmpresa,sCuenta,nomEmpresa,sIdTipoUsuario,sFBloqueoTemp;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;
--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************
        SELECT usu.id_usuario,usu.num_cliente,usu.id_status ,usu.fec_primer_acceso,
                CASE WHEN usu.f_ultimo_acceso IS NULL THEN substring (current::char(23) from 1 for 19)
                ELSE substring (usu.f_ultimo_acceso::char(23)from 1 for 19)
                END f_ultimo_acceso,
                tk.id_status_token,dusr.nombre,current,usu.id_tipo_usuario,usu.f_bloqueo_temp
        INTO sIdUsuario,sNumCliente ,iIdStatus,fecPrimAcceso,fecUltAcceso, iIdStatusToken,sNombre,vFecha,sIdTipoUsuario,sFBloqueoTemp
        FROM bdibei:"informix".bei_usuario  usu
        LEFT JOIN bdibei:"informix".bei_token tk ON tk.num_cliente = usu.num_cliente AND tk.id_usuario = usu.id_usuario
        JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
        WHERE  usu.usuario_bei  = pUsuario
        AND   usu.pass=TRIM(pPass);




--**************************************************************************************************************
--VALIDA STATUS USUARIO
--**************************************************************************************************************
		IF NVL(sNumCliente,'') != ''  THEN

			SELECT si.nombre_corto
			INTO nomEmpresa
			FROM bdinteg:"informix".si_ctepm si
			WHERE si.numcte = sNumCliente;

               IF iIdStatus = '95' or iIdStatus = '10' THEN
			   
			          --***SE INICIALIZA VARIABLE***************************************************************
					   IF NVL(sFBloqueoTemp,'1900-01-01 00:00:00') == '1900-01-01 00:00:00'  THEN
						LET sFBloqueoTemp='1900-01-01 00:00:00';
					   END IF;
					  --****************************************************************************************
			   
                    LET cod_ret = '000';  -- Usuario inactivo
                    RETURN cod_ret, sNumCliente, sNombre, iIdStatus, iIdStatusToken, fecUltAcceso,vFecha,sIdUsuario,vIdEmpresa,sCuenta,nomEmpresa,sIdTipoUsuario,sFBloqueoTemp;
                END IF;
			--Actualiza Ultimo Acceso en bei_usuario
			IF iIdStatus = 30 THEN
				UPDATE bdibei:"informix".bei_usuario SET f_ultimo_acceso = CURRENT  WHERE id_usuario = sIdUsuario;

				--Actualiza su primer acceso si es la primera vez que ingresa
				IF fecPrimAcceso IS NULL THEN
					UPDATE bdibei:"informix".bei_usuario SET fec_primer_acceso = CURRENT  WHERE id_usuario = sIdUsuario;
				END IF;
			END IF;

            LET cod_ret = '000';  -- Sesion iniciada
--**************************************************************************************************************
--OBTIENES EL ID DE LA EMPRESA DEL CLIENTE
--**************************************************************************************************************
			SELECT codigo INTO vIdEmpresa FROM bdicheq:"informix".sc_nominaempresas WHERE numcte=TRIM(sNumCliente);
			IF NVL(vIdEmpresa,'') == '' THEN
				LET vIdEmpresa = '0';
			END IF;
--*****************************************************************************************************************
--OBTIENE CUENTA PARA REALIZAR DISPERSION
			SELECT NVL(cuenta,'') INTO sCuenta FROM bdicheq:"informix".sc_nominaempresas WHERE numcte = sNumCliente AND status_alta = 3;
			IF NVL(sCuenta,'') == '' THEN
				LET sCuenta = '';
			END IF;
        ELSE
            SELECT usu.id_usuario,usu.num_cliente,usu.id_status
			INTO sIdUsuario,sNumCliente ,iIdStatus
        	FROM bdibei:"informix".bei_usuario  usu
            WHERE  usu.usuario_bei  = pUsuario ;

			IF(sIdUsuario IS NOT NULL) OR(sIdUsuario==0) THEN
				LET cod_ret = '002';  -- ContraseÃ?Â±a incorrecta
			END IF;
        END IF ;

	  IF NVL(sNombre,'') == ''  THEN
		LET sNombre='';
      END IF;

      IF NVL(iIdStatusToken,-1) == -1  THEN
		LET iIdStatusToken=-1;
      END IF;

     IF NVL(fecUltAcceso,'') == ''  THEN
		LET fecUltAcceso='';
      END IF;

     IF NVL(vFecha,'1900-01-01 00:00:00') == '1900-01-01 00:00:00'  THEN
		LET vFecha='1900-01-01 00:00:00';
      END IF;

     IF NVL(sFBloqueoTemp,'1900-01-01 00:00:00') == '1900-01-01 00:00:00'  THEN
		LET sFBloqueoTemp='1900-01-01 00:00:00';
      END IF;

     IF NVL(sIdTipoUsuario,-1) == -1  THEN
      	SELECT usu.id_usuario,usu.id_status ,usu.id_tipo_usuario
        INTO sIdUsuario,iIdStatus, sIdTipoUsuario
        FROM bdibei:"informix".bei_usuario  usu
        WHERE  usu.usuario_bei  = pUsuario ;

          IF NVL(sIdTipoUsuario,-1) == -1  THEN
          	LET sIdTipoUsuario=-1;
          END IF;

      END IF;

  RETURN cod_ret, sNumCliente, sNombre, iIdStatus, iIdStatusToken, fecUltAcceso,vFecha,sIdUsuario,vIdEmpresa,sCuenta,nomEmpresa,sIdTipoUsuario,sFBloqueoTemp;

END
END PROCEDURE;