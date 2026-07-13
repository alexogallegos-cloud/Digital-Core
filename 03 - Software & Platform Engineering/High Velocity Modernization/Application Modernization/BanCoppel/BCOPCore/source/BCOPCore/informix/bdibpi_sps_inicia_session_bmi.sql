CREATE PROCEDURE "informix".sps_inicia_session_bmi(pEmpresa CHAR(3), pIdUsuario CHAR(11), pIp CHAR(15))
   RETURNING CHAR(5), CHAR (20), CHAR(26), CHAR(26), CHAR(26), CHAR(26), SMALLINT, INTEGER, CHAR(19),DATETIME YEAR TO SECOND, CHAR(1), VARCHAR(11), char(12);
   
    DEFINE cCod_ret CHAR(5);
    DEFINE iSql_err INTEGER ;
    DEFINE cNumCliente CHAR (20);
    DEFINE sIdStatus SMALLINT ;
    DEFINE cNombre1, cNombre2, cApellPaterno, cApellMaterno CHAR (26);
    DEFINE iIdStatusToken INTEGER;
    DEFINE dFecPrimAcceso date;
    DEFINE dFecUltAcceso CHAR(19);
    DEFINE dFecha  DATETIME YEAR TO SECOND;
    DEFINE vUsuario VARCHAR(50);
	DEFINE cPass CHAR(50);
	DEFINE cTipo CHAR(1);
	DEFINE cNstoken char(9);
	DEFINE vnstoken char(12);
	
	--Descripción: Inicia Session BMI
	--10/11/2015

    LET cCod_ret  = "000";
    LET cNumCliente  = '';
    LET sIdStatus = 0;
    LET cNombre1 = '';
    LET cNombre2  = '';
    LET cApellPaterno  = '';
    LET cApellMaterno  = '';
    LET iIdStatusToken = 0;
    LET dFecUltAcceso = '';
    LET dFecha=null;
    LET vUsuario = '';
	LET cPass = '';
	LET cTipo = '';
	LET cNstoken='';
	LET vnstoken='';

	--SET debug FILE TO "/informix/gaby/ArchivosOut/sps_inicia_session_bmi.out";
	--Trace ON;	     

	

	
	
  BEGIN

   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            LET cCod_ret = iSql_err;
            RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,cTipo, pIdUsuario, vnstoken;
      END IF ;
   END EXCEPTION ;
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT numcliente INTO cNumCliente FROM bdibpi:"informix".bpi_usuario WHERE id_usuario=pIdUsuario;
		
        SELECT usu.usuario, usu.id_status, usu.fec_primer_acceso, SUBSTRING(NVL(usu.f_ultimo_acceso, CURRENT)::VARCHAR(23) FROM 1 FOR 19), usu.pass, tk.id_status_token, tk.tipo_token, tk.ns_token
		INTO vUsuario, sIdStatus, dFecPrimAcceso, dFecUltAcceso, cPass, iIdStatusToken, cTipo, cNstoken
		FROM bdinteg:"informix".si_bpiusuarios usu
		LEFT JOIN bdinteg:"informix".si_bpitoken tk ON tk.num_cliente = usu.numcte AND tk.empresa = pEmpresa
		WHERE usu.empresa = pEmpresa AND usu.numcte = cNumCliente;	

		IF cTipo='2' THEN
			LET vnstoken = 'TMT' || cNstoken;
		else
			LET vnstoken = cNstoken;
		END IF;	

		
		 		
		IF NVL(vUsuario,'') != '' AND NVL(cPass,'') != '' THEN

                SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
                INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
                FROM bdinteg:"informix".si_cliente si WHERE si.numcte = cNumCliente;
                            
                IF sIdStatus = '95' or sIdStatus = '10' THEN
                    LET cCod_ret = '000';  -- Usuario inactivo
                    RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha, cTipo, pIdUsuario, vnstoken;
                END IF;

                --Actualiza Ultimo Acceso en si_bpi
                IF sIdStatus = 30 THEN
                        UPDATE bdinteg:"informix".si_bpiusuarios SET f_ultimo_acceso = CURRENT  WHERE numcte = cNumCliente;
                        --Actualiza su primer acceso si es la primera vez que ingresa
                        IF dFecPrimAcceso IS NULL THEN
                            UPDATE bdinteg:"informix".si_bpiusuarios SET fec_primer_acceso = CURRENT  WHERE numcte = cNumCliente;
                        END IF;
                    --OBTIEN DATOS DEL LOGIN *************************************************************************************
						SELECT current 
                        INTO dFecha 
                        FROM bdibpi:"informix".bpi_usuario 
                        WHERE numcliente = cNumCliente 
                        AND st_portal = 'activo';
                --ACTUALIZA ULTIMO ACCESO en bpi_usuario
                        IF NVL(dFecha, '') <> '' THEN
								UPDATE bdibpi:"informix".bpi_usuario SET f_ultimo_acceso = TODAY WHERE numcliente = cNumCliente AND st_portal = 'activo';
                                --GRABA EN BITACORA CON CODIGO DE OPERACION INICIO DE SESSION == '1000'
                                INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, 
                                        cuenta_origen, destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4) 
                                        VALUES (CURRENT, '1000', '5007', pIdUsuario, pIp, CURRENT, 
                                                '', '', 0.00, '1000', '', '', '', '');
                                LET cCod_ret = '000';  -- Sesion iniciada
                        ELSE
                                LET cCod_ret = '001';  
                        END IF;
                END IF;	
        ELSE
				SELECT numcte, id_status INTO cNumCliente, sIdStatus FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = vUsuario;
                LET cCod_ret = '002';  -- Usuario y/o Contraseña incorrecta
        END IF ;

   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha, cTipo, pIdUsuario, vnstoken;

END
END PROCEDURE
DOCUMENT
'Autor: 97915041 Rocio Vidales',
'Fecha: 07/09/2018',
'Modificacion: Se agrega parametro de retorno CTipo para validar el Tipo de Token que tiene el Cliente',
'Sustento: RQI 03 741 ? Optimización Autentificación Token Virtual',
'Solicita: Arturo Alejandro Vazquez',
'------------------------------------------------------------------------------------------------------',
'Autor: Gabriela Aguilar',
'Fecha: 22/03/2019',
'Modificación: Se agrega parametro de retorno token digital';

CREATE PROCEDURE "informix".sp_obtiene_direccion_envio(pNumCte CHAR(9), pNvaDir INTEGER)
	RETURNING CHAR(5), INTEGER, CHAR(200);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizó: Manuel Ramos Figueroa
-- Actividad: Obtiene la secuencia de la ultima direccion de envio de dispositivo token para obtener la dirección mediante la
--				ejecución del sp sp_obt_dir_admtoken.
-- Solicitó: Walber Castrof
-- Fecha de Solicitud: 23/12/2013
----------------------------------------------------------------------------------------------------------------------------------------
-- Se modifican los valores de retorno para que se muestre en pantalla el número interior y el departamento en caso de que haya sido capturado.
-- Bibiana Gaxiola Verdugo.
-- 17/01/2014
-----------------------------------------------------------------------------------------------------------------------------------------
-- Se modifican los valores de retorno del SP sp_obt_dir_admtoken, ya que fue actualizado dicho SP para funcionalidad del Admon token
-- Bibiana Gaxiola Verdugo
-- 21/10/2014
-----------------------------------------------------------------------------------------------------------------------------------------

-- Se se agrega validación para que retorne la dirección de persona moral
-- Gabriela Aguilar
-- 09/08/2016
-----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE cCodRet			CHAR(5);
	DEFINE cCodRet2			CHAR(5);
	DEFINE iSql_err			INTEGER;
	DEFINE iSecDomicilio	INTEGER;
	DEFINE cDomicilio		CHAR(200);
	DEFINE cNumSolicitud	CHAR(10);

	DEFINE vCliente			CHAR(9);
	DEFINE vEstado			CHAR(30);
	DEFINE vCiudad			CHAR(60);
	DEFINE vMunicipio		CHAR(25);
	DEFINE vColonia			CHAR(30);
	DEFINE vCalle			CHAR(30);
	DEFINE vCalleCom		CHAR(30);
	DEFINE vEmail			CHAR(60);
	DEFINE vNumExterior		CHAR(10);
	DEFINE vNumInterior		CHAR(10);
	DEFINE vTel				CHAR(22);
	DEFINE vCodPostal		CHAR(5);
	DEFINE vManzana			CHAR(6);
	DEFINE vAndador			CHAR(6);
	DEFINE vEtapa			CHAR(6);
	DEFINE vLote			CHAR(6);
	DEFINE vEdificio		CHAR(6);
	DEFINE vEntrada			CHAR(6);
	DEFINE vOtros			CHAR(6);
	DEFINE vObservaciones	CHAR(80);
	DEFINE vid_estado	    CHAR(5);
	
	LET cCodRet				= '00000';
	LET cCodRet2				= '00000';
	LET iSql_err			= 0;
	LET iSecDomicilio		= 0;
	LET cDomicilio			= '';
	LET cNumSolicitud		= '';

	LET vCliente			= '';
	LET vEstado				= '';
	LET vCiudad				= '';
	LET vMunicipio			= '';
	LET vColonia			= '';
	LET vCalle				= '';
	LET vCalleCom			= '';
	LET vEmail				= '';
	LET vNumExterior		= '';
	LET vNumInterior		= '';
	LET vTel				= '';
	LET vCodPostal			= '';
	LET vAndador			= '';
	LET vEtapa				= '';
	LET vLote				= '';
	LET vEdificio			= '';
	LET vEntrada			= '';
	LET vOtros				= '';
	LET vObservaciones		= '';
	LET vid_estado   		= '';

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_obtiene_direccion_envio.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, 0, '';
			END IF;
		END EXCEPTION;
	

		IF pNvaDir == 0 THEN
			SELECT MAX(solicitud)
			INTO cNumSolicitud
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCte;

			SELECT sec_domicilio
			INTO iSecDomicilio
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCte
			AND solicitud = cNumSolicitud;
		ELIF pNvaDir == 1 THEN
			SELECT MAX(secuencia)
			INTO iSecDomicilio
			FROM bdinteg:"informix".si_direcciones
			WHERE numcte = pNumCte;
		ELIF pNvaDir == 2 THEN
			SELECT MAX(secuencia)
			INTO iSecDomicilio
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = pNumCte and tipo_dir='1';
		
		END IF;

		IF NVL(iSecDomicilio, 0) > 0 THEN
			EXECUTE PROCEDURE bdibpi:"informix".sp_obt_dir_admtoken(pNumCte, iSecDomicilio)
			INTO cCodRet2, vCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vEmail, vNumExterior,
					vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones, vid_estado;
		ELSE
			LET cCodRet = '00001';
		END IF;

		IF cCodRet2 == "000" THEN
			--- LET cDomicilio = TRIM(NVL(vCalle, '')) || ' ' || TRIM(NVL(vNumExterior, '')) || ' ' || TRIM(NVL(vColonia, '')) || ', ' ||
			LET cDomicilio = TRIM(NVL(vCalle, '')) || ' ' || TRIM(NVL(vNumExterior, '')) || ' ' || TRIM(NVL(vNumInterior, '')) || ' ' || TRIM(NVL(vColonia, '')) || ', ' ||
								TRIM(NVL(vCiudad, '')) || ', ' || TRIM(NVL(vEstado, '')) || ', ' || TRIM(NVL(vCodPostal, ''));
		ELSE
			LET cCodRet = '00001';
		END IF;

		RETURN cCodRet, iSecDomicilio, cDomicilio;
	END
END PROCEDURE;