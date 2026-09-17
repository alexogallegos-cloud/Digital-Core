CREATE PROCEDURE "informix".sp_inicia_session_bei(pEmpresa char(3), pUsuario char(50), pPass char(50),pIp char(15))
   returning char(5), char (20), char(50), smallint, integer, char(19),DATETIME YEAR TO SECOND, CHAR(11),char(3), char(20);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sNumCliente char (20);
    DEFINE iIdStatus smallint ;
    DEFINE sNombre CHAR(50);
    DEFINE iIdStatusToken integer;
    DEFINE fecPrimAcceso date;
    DEFINE fecUltAcceso char(19);
    DEFINE vFecha  DATETIME YEAR TO SECOND;
    DEFINE vIdUsuario CHAR(11);
	DEFINE vIdEmpresa char(3);
	DEFINE sCuenta CHAR(20);
	
    LET cod_ret  = "000";
    LET sNumCliente  = '';
    LET iIdStatus = 0;
    LET sNombre = '';
    LET iIdStatusToken = 0;
    LET fecUltAcceso = '';
    LET vFecha=null;
    LET vIdUsuario = '';
	LET vIdEmpresa='';
	LET sCuenta = '';

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS DATOS PARA INICIAR LA SESION EN LA BANCA EMPRESARIAL
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	-- DESCRIPCION:  SE MODIFICÓ PARA QUE EL SP, NO GRABE EN BITACORA EL INICIO DE SESIÓN, QUE LO GRABE DESDE EL PORTAL
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 31/08/2012
	-- BD: bdibpi
	-- SOLICITO :José de Jesus
	--***************************************************************************************************
	
	--set debug file to "sp_inicia_session_bei.out";
	--trace on;
    
  BEGIN
	
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sNumCliente, sNombre, iIdStatus, iIdStatusToken, fecUltAcceso,vFecha,vIdUsuario,vIdEmpresa,sCuenta;
      END IF ;
   END EXCEPTION ;
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
        SELECT num_cliente INTO sNumCliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND usuario  = pUsuario AND pass = pPass;

		IF NVL(sNumCliente, '') <> '' THEN
        
			SELECT usu.num_cliente, usu.id_status, si.nombre_corto, id_status_token, usu.fec_primer_acceso, 
				CASE WHEN usu.f_ultimo_acceso IS NULL THEN substring (current::char(23) from 1 for 19)
				ELSE substring (usu.f_ultimo_acceso::char(23)from 1 for 19)
				END f_ultimo_acceso
			INTO sNumCliente,  iIdStatus, sNombre, iIdStatusToken, fecPrimAcceso, fecUltAcceso
			FROM bdinteg:"informix".si_bpiusuariospm usu
			INNER JOIN bdinteg:"informix".si_ctepm si ON si.numcte = usu.num_cliente
			AND usu.empresa = TRIM(pEmpresa)
			AND usu.usuario = trim(pUsuario)
			AND usu.pass = TRIM(pPass)
			LEFT JOIN bdinteg:"informix".si_bpitokenpm tk ON tk.num_cliente = usu.num_cliente
			AND tk.empresa = TRIM(pEmpresa);

			--Actualiza Ultimo Acceso en si_bpi
			IF iIdStatus = 30 THEN
				UPDATE bdinteg:"informix".si_bpiusuariospm SET f_ultimo_acceso = CURRENT  WHERE num_cliente = sNumCliente;
			END IF;	
			--Actualiza su primer acceso si es la primera vez que ingresa
			IF fecPrimAcceso IS NULL THEN
				UPDATE bdinteg:"informix".si_bpiusuariospm SET fec_primer_acceso = CURRENT  WHERE num_cliente = sNumCliente;
			END IF;

            LET cod_ret = '000';  -- Sesion iniciada
--OBTIEN DATOS DEL LOGIN *************************************************************************************
			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
			
			SELECT id_usuario,current 
			INTO vIdUsuario,vFecha 
			FROM bdibpi:"informix".bpi_usuariopm 
			WHERE numcliente = sNumCliente 
            AND st_portal = 'activo';
--**************************************************************************************************************
 
--OBTIENES EL ID DE LA EMPRESA DEL CLIENTE
	SET LOCK MODE TO WAIT ;
    SET ISOLATION DIRTY READ ;
	
	SELECT codigo INTO vIdEmpresa FROM bdicheq:"informix".sc_nominaempresas WHERE numcte=TRIM(sNumCliente);
	IF NVL(vIdEmpresa,'') = '' THEN
		LET vIdEmpresa = '0';
	END IF;
 
--ACTUALIZA ULTIMO ACCESO en bpi_usuario ***********************************************************************
           
            IF NVL(sNumCliente, '') <> '' THEN
                UPDATE bdibpi:"informix".bpi_usuariopm SET f_ultimo_acceso = TODAY WHERE numcliente = sNumCliente AND st_portal = 'activo';
            ELSE
                LET cod_ret = '001';  
            END IF;
--*****************************************************************************************************************

--OBTIENE CUENTA PARA REALIZAR DISPERSION
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION DIRTY READ ;
	SELECT NVL(cuenta,'') INTO sCuenta FROM bdicheq:"informix".sc_nominaempresas WHERE numcte = sNumCliente AND status_alta = 3;
	IF NVL(sCuenta,'') = '' THEN
		LET sCuenta = '';
	END IF;
        ELSE	
			SET LOCK MODE TO WAIT  ;
			SET ISOLATION DIRTY READ ;

			SELECT usu.num_cliente, usu.id_status
			INTO sNumCliente,  iIdStatus
			FROM bdinteg:"informix".si_bpiusuariospm usu
            where usu.empresa = pEmpresa
            AND usu.usuario = pUsuario;
			
			IF(sNumCliente IS NOT NULL) OR(sNumCliente<>'') THEN
				LET cod_ret = '002';  -- Usuario y/o Contraseña incorrecta
				
			ELSE
				LET cod_ret = '001';  -- Usuario NO EXISTE
			END IF;

        END IF ;

  RETURN cod_ret, sNumCliente, sNombre, iIdStatus, iIdStatusToken, fecUltAcceso,vFecha,vIdUsuario,vIdEmpresa,sCuenta;

END
END PROCEDURE;