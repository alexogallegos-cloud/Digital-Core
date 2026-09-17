CREATE PROCEDURE "informix".sps_ini_session_bei_duplicado_mx2(pEmpresa CHAR(3), pIdUsuario INTEGER, pIp CHAR(15))
   RETURNING 
    CHAR(5), CHAR (20), CHAR(50), SMALLINT, INTEGER, CHAR(19),
    DATETIME YEAR TO SECOND, INTEGER, CHAR(3), CHAR(20),
    CHAR(50), SMALLINT, DATETIME YEAR TO SECOND, VARCHAR(10);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;

    DEFINE sNumCliente CHAR(20);
    DEFINE iIdStatus SMALLINT ;
    DEFINE fecPrimAcceso DATE;
    DEFINE fecUltAcceso CHAR(19);
    DEFINE iIdStatusToken INTEGER;
    DEFINE sNombre CHAR(150);
    DEFINE vFecha  DATETIME YEAR TO SECOND;
    DEFINE vIdEmpresa CHAR(3);
    DEFINE nomEmpresa CHAR(50);
    DEFINE sCuenta CHAR(20);
    DEFINE sIdTipoUsuario SMALLINT;
	DEFINE sFBloqueoTemp DATETIME YEAR TO SECOND;
    DEFINE token VARCHAR(10);

    LET cod_ret  = "000";
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
    LET token = '';

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS PARA INICIAR LA SESION EN LA BANCA EMPRESARIAL
-- AUTOR : Irving Guzman Salas
-- FECHA : 26/04/2013
-- BD: bdibei
-- SOLICITO :
-- ModificaciÃÂ³n: Se inicializa la variabe de fechabloqueo cuando el status es 95 o 10.
-- Modifica: Berenice Noriega - BanCoppel.
-- Fecha Mod: 23/Junio/2014
-- ModificaciÃÂ³n: Se optimiza
-- Modifica: BanCoppel.
-- Fecha Mod: 02/Octubre/2018
--
--DESCRIPCION:  OptimizaciÃ³n spl
-- AUTOR : Gabriela Aguilar/Berenice Noriega
-- FECHA : 13/02/2019
--***************************************************************************************************


SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sps_ini_session_bei_duplicado.out";
TRACE ON;


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            --RETURN cod_ret,sNumCliente,sNombre,iIdStatus,iIdStatusToken,fecUltAcceso,vFecha,pIdUsuario,vIdEmpresa,sCuenta,nomEmpresa,sIdTipoUsuario,sFBloqueoTemp,token;
			RETURN cod_ret, NVL(sNumCliente,''),NVL(sNombre,''),NVL(iIdStatus,''),NVL(iIdStatusToken,''),fecUltAcceso,vFecha,pIdUsuario,NVL(vIdEmpresa,''),NVL(sCuenta,''),NVL(nomEmpresa,''),NVL(sIdTipoUsuario,''),sFBloqueoTemp,NVL(token,'');
 
 END IF ;
   END EXCEPTION ;


	 SET ISOLATION DIRTY READ;
     SET LOCK MODE TO WAIT 3;
	 
	 	 
--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************
        
		SELECT usu.num_cliente,usu.id_status ,usu.fec_primer_acceso,usu.f_ultimo_acceso,
        tk.id_status_token,dusr.nombre,current,usu.id_tipo_usuario,usu.f_bloqueo_temp,tk.ns_token
        INTO sNumCliente ,iIdStatus,fecPrimAcceso,fecUltAcceso, iIdStatusToken,sNombre,vFecha,sIdTipoUsuario,sFBloqueoTemp,token
        FROM bdibei:"informix".bei_usuario  usu
         LEFT JOIN bdibei:"informix".bei_token tk ON tk.num_cliente = usu.num_cliente AND tk.id_usuario = usu.id_usuario
        INNER JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
        WHERE  usu.id_usuario  = pIdUsuario;
		
		IF sIdTipoUsuario = 0  THEN
					 
						SELECT usu.id_status ,usu.id_tipo_usuario
						INTO iIdStatus, sIdTipoUsuario
						FROM bdibei:"informix".bei_usuario  usu
						WHERE  usu.id_usuario  = pIdUsuario ;

						  IF  sIdTipoUsuario  = 0 OR sIdTipoUsuario IS NULL THEN
							LET sIdTipoUsuario=-1;
						  END IF;
						   

		END IF;
		
		
				
		IF fecUltAcceso IS NULL  THEN 
			LET fecUltAcceso= substring (current::char(23) from 1 for 19);
		ELSE 
			LET fecUltAcceso= substring (fecUltAcceso::char(23)from 1 for 19);
		END IF ;
		
		IF iIdStatusToken = 0 OR iIdStatusToken IS NULL THEN
		   LET iIdStatusToken = -1;
		END IF;
		
	      IF sNombre = '' OR  sNombre IS NULL THEN
			LET sNombre='';
		  END IF;

		  IF fecUltAcceso = ''  THEN
			LET fecUltAcceso='';
		  END IF;

		  IF vFecha = '' OR vFecha IS NULL  THEN
			LET vFecha='1900-01-01 00:00:00';
		  END IF;

		  IF sFBloqueoTemp = '' OR  sFBloqueoTemp IS NULL THEN
			LET sFBloqueoTemp='1900-01-01 00:00:00';
		  END IF;

--**************************************************************************************************************
--VALIDA STATUS USUARIO
--**************************************************************************************************************
		
		IF sNumCliente <> ''  THEN

			SELECT si.nombre_corto
			INTO nomEmpresa
			FROM bdinteg:"informix".si_ctepm si
			WHERE si.numcte = sNumCliente;

                IF iIdStatus = '95' or iIdStatus = '10' THEN
			   
			          --***SE INICIALIZA VARIABLE***************************************************************
					   IF sFBloqueoTemp = '' OR sFBloqueoTemp IS NULL THEN
						LET sFBloqueoTemp='1900-01-01 00:00:00';
					   END IF;
					  --****************************************************************************************
			   
                      -- Usuario inactivo
						
					--RETURN cod_ret,sNumCliente,sNombre,iIdStatus,iIdStatusToken,fecUltAcceso,vFecha,pIdUsuario,vIdEmpresa,sCuenta,nomEmpresa,sIdTipoUsuario,sFBloqueoTemp,token;
					  RETURN cod_ret, NVL(sNumCliente,''),NVL(sNombre,''),NVL(iIdStatus,''),NVL(iIdStatusToken,''),fecUltAcceso,vFecha,pIdUsuario,NVL(vIdEmpresa,''),NVL(sCuenta,''),NVL(nomEmpresa,''),NVL(sIdTipoUsuario,''),sFBloqueoTemp,NVL(token,'');
					
                END IF;
				--Actualiza Ultimo Acceso en bei_usuario
				IF iIdStatus = 30 THEN
				
					UPDATE bdibei:"informix".bei_usuario SET f_ultimo_acceso = CURRENT  WHERE id_usuario = pIdUsuario;

					--Actualiza su primer acceso si es la primera vez que ingresa
					IF fecPrimAcceso IS NULL THEN
						UPDATE bdibei:"informix".bei_usuario SET fec_primer_acceso = CURRENT  WHERE id_usuario = pIdUsuario;
					END IF;
					
				END IF;

            -- Sesion iniciada
--**************************************************************************************************************
--OBTIENES EL ID DE LA EMPRESA DEL CLIENTE
--**************************************************************************************************************
			SELECT codigo INTO vIdEmpresa FROM bdicheq:"informix".sc_nominaempresas WHERE numcte= sNumCliente;
			IF vIdEmpresa = '' THEN
				LET vIdEmpresa = '0';
			END IF;
--*****************************************************************************************************************
--OBTIENE CUENTA PARA REALIZAR DISPERSION
			SELECT cuenta INTO sCuenta FROM bdicheq:"informix".sc_nominaempresas WHERE numcte = sNumCliente AND status_alta = 3;
			IF sCuenta = '' THEN
				LET sCuenta = '';
			END IF;
       
				
	   ELSE      
	
			LET cod_ret = '002';  -- No se Encontro Numero de Cliente con el ID indicado
			RETURN cod_ret, NVL(sNumCliente,''),NVL(sNombre,''),NVL(iIdStatus,'-1'),NVL(iIdStatusToken,''),fecUltAcceso,vFecha,pIdUsuario,NVL(vIdEmpresa,''),NVL(sCuenta,''),NVL(nomEmpresa,''),NVL(sIdTipoUsuario,'-1'),sFBloqueoTemp,NVL(token,'');
        END IF ;

	   


 --     IF sIdTipoUsuario = 0  THEN
	 
--      	SELECT usu.id_status ,usu.id_tipo_usuario
--        INTO iIdStatus, sIdTipoUsuario
--        FROM bdibei:"informix".bei_usuario  usu
--        WHERE  usu.id_usuario  = pIdUsuario ;

--          IF  sIdTipoUsuario  = 0  THEN
---          	LET sIdTipoUsuario=-1;
--          END IF;

--      END IF;

	RETURN cod_ret, NVL(sNumCliente,''),NVL(sNombre,''),NVL(iIdStatus,''),NVL(iIdStatusToken,''),fecUltAcceso,vFecha,pIdUsuario,NVL(vIdEmpresa,''),NVL(sCuenta,''),NVL(nomEmpresa,''),NVL(sIdTipoUsuario,''),sFBloqueoTemp,NVL(token,'');

END
END PROCEDURE;