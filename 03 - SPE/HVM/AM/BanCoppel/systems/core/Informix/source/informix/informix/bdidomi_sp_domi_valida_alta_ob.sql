CREATE PROCEDURE "informix".sp_domi_valida_alta_ob(
	pNumcte CHAR(20), 
	pNumCuentaTarjetaCargo CHAR(20), 
	pNumCuentaTarjetaAbono CHAR(20), 
	pRazonSocial CHAR(60), 
	pCanal CHAR(30), 
	pTipo_domi CHAR(2), 
	p_sUserStatus CHAR(8), 
	p_sPeriodo CHAR(2), 
	p_sGenerico1 NVARCHAR(254), 
	p_sGenerico2 NVARCHAR(254), 
	p_sGenerico3 NVARCHAR(254), 
	p_sGenerico4 NVARCHAR(254), 
	p_sGenerico5 NVARCHAR(254)
)
	RETURNING	CHAR(5) 	AS codRet, 
				CHAR(20) 	AS NumCliente,
				CHAR(16) 	AS NumTarjetaAbono,
				CHAR(20) 	AS CuentaAbono, 
				CHAR(80)  	AS NomProductoAbono, --Nombre de Producto Abono
				CHAR(30)  	AS NomCortoProductoAbono, --Nombre Corto de Producto Abono 
				CHAR(30) 	AS NombreTitular, --Nombre del Titular de la Tarjeta Abono
				CHAR(26) 	AS Nombre1, -- Nombre1 del cliente
				CHAR(26) 	AS Nombre2, -- Nombre2 del cliente
				CHAR(26) 	AS Apellido1, -- Apellido1 del cliente
				CHAR(26) 	AS Apellido2, -- Apellido2 del cliente
				CHAR(13)  	AS RFC, -- RFC del cliente
				CHAR(13)  	AS NumCelular, -- N?mero de telefono celular
				CHAR(100) 	AS Correo, -- Correo electronico
				CHAR(20) 	AS CuentaCargo,
				CHAR(4)		AS CodigoProductoCargo,--++
				CHAR(80) 	AS NomProductoCargo, --Nombre de producto Cargo++
				CHAR(20) 	AS CuentaClabe,--++
				CHAR(16)	AS NumeroTarjetaCargo, 
				CHAR(40)	AS BancoCargo, --Nombre del banco Cargo
				CHAR(40)	AS BancoCargoCorto, --Nombre corto del banco Cargo
				CHAR(40)	AS BancoAbono, --Nombre del banco Abono
				CHAR(40)	AS BancoAbonoCorto, --Nombre corto del banco Abono
				CHAR(2)     AS ClaveCanal, -- Clave del canal de domiciliaci?n
				CHAR(13)  	AS RFCServicio, 
				CHAR(2)		AS TipoCuentaCargo, 
				CHAR(2)		AS TipoCuentaAbono, 
				CHAR(3)		AS ClaveBancoCargo,
				CHAR(20)	AS Periodicidad,
			    CHAR(100)   AS vGenerico1,
                CHAR(100)	AS vGenerico2,
                CHAR(100)	AS vGenerico3,
                CHAR(100)	AS vGenerico4,
				NVARCHAR(254)	AS vGenerico5,
				NVARCHAR(254)	AS vGenerico6,
				NVARCHAR(254)	AS vGenerico7,
				NVARCHAR(254)	AS vGenerico8,
				NVARCHAR(254)	AS vGenerico9;
               
--DECLARACION DE VARIABLES	
	DEFINE sql_err        				INTEGER;
	DEFINE cCodret        				CHAR(5);
	DEFINE cCanal         				CHAR(2);
	
	DEFINE cCuentaAbono					CHAR(20);
	DEFINE cNumTarjetaCargo				CHAR(16);
	DEFINE cCuentaCargo					CHAR(20);
	DEFINE cNumTarjetaAbono   			CHAR(16);
	DEFINE cNombreTitular				CHAR(30);
	DEFINE cNumProducto					CHAR(4);
	DEFINE iContador					SMALLINT;
	
	DEFINE cNumcte						CHAR(20);
	DEFINE iExiste						INTEGER;
	DEFINE cNombre1Cte     				CHAR(200);
	DEFINE cNombre2Cte     				CHAR(200);
	DEFINE cApellido1Cte   				CHAR(200);
	DEFINE cApellido2Cte   				CHAR(200);
	DEFINE cRfc							CHAR(13);
	DEFINE cNumTelefono					CHAR(13); 
	DEFINE cCorreoElect					CHAR(100);
	DEFINE cRfcServicio					CHAR(13);

	DEFINE v_iPosicion					INTEGER;
	DEFINE iPosicionCadena				INTEGER;
	DEFINE v_sProducto    				CHAR(5);
	DEFINE v_sProductos    				CHAR(80);
	DEFINE v_sNombreProductoCargo		CHAR(80);
	DEFINE v_sNombreProductoAbono		CHAR(80);
	DEFINE v_sNombreCortoProductoAbono	CHAR(80);
	DEFINE v_sFechaNac   				CHAR(10);
	DEFINE v_sClabe						CHAR(20);
	DEFINE v_sValor 					CHAR(100);
	DEFINE v_sCodParam					CHAR(2);

	DEFINE cBancoCargo					CHAR(40);
	DEFINE cBancoAbono					CHAR(40);
	DEFINE cBancoCargoCorto				CHAR(20);
	DEFINE cBancoAbonoCorto				CHAR(20);
	DEFINE cClaveBancoCargo				CHAR(3);
	DEFINE cClaveBancoAbono				CHAR(3);
	DEFINE ctipoCuentaCargo				CHAR(2);
	DEFINE ctipoCuentaAbono				CHAR(2);
	DEFINE cCodret2						CHAR(5);
	DEFINE cMensajeRespuesta 			CHAR (110);
	DEFINE cPeriodicidad	 			CHAR (20);
	DEFINE cFolioAnterior               CHAR(20);
	
    DEFINE v_Generico2                  CHAR(100);
    DEFINE v_Generico3                  CHAR(100);
    DEFINE v_Generico4                  CHAR(100);
	DEFINE v_Generico5                  NVARCHAR(254);
	DEFINE v_Generico6                  NVARCHAR(254);
	DEFINE v_Generico7                  NVARCHAR(254);
	DEFINE v_Generico8                  NVARCHAR(254);
	DEFINE v_Generico9                  NVARCHAR(254);

--Inicializar Variables	
	LET sql_err            			= 0;
	LET cCodret           			= '00000';
	LET cCanal              		= '';
	
	LET cCuentaAbono				= '';
	LET cNumTarjetaCargo			= '';
	LET cCuentaCargo				= '';
	LET cNumTarjetaAbono      		= '';
	LET cNombreTitular				= '';
	LET cNumProducto				= '';
	LET iContador					= 0;
 
	LET cNumcte						= '';
	LET iExiste						= 0;
	LET cNombre1Cte 				= '';
	LET cNombre2Cte 				= '';
	LET cApellido1Cte				= '';
	LET cApellido2Cte				= '';
	LET cRfc						= '';
	LET cNumTelefono				= '';
	LET cCorreoElect				= '';
	LET cRfcServicio        		= '';

	LET v_sClabe					= '';
	LET v_sProducto 				= '';
	LET v_sProductos				= '';
	LET v_sNombreProductoCargo		= '';
	LET v_sNombreProductoAbono		= '';
	LET v_sNombreCortoProductoAbono	= '';
	LET v_sFechaNac					= '';
	LET v_iPosicion					= 1;
	LET v_sCodParam					= '53';

	LET cBancoCargo					= '';
	LET cBancoAbono					= '';
	LET cBancoCargoCorto			= '';
	LET cBancoAbonoCorto			= '';
	LET cClaveBancoCargo			= '';
	LET cClaveBancoAbono			= '';
	LET ctipoCuentaCargo			= '';
	LET ctipoCuentaAbono			= '';
	LET iPosicionCadena				= 4;
	LET cCodret2					= '';
	LET cMensajeRespuesta			= '';
	LET cPeriodicidad				= '';
	LET cFolioAnterior              = '';
	
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	LET v_Generico5                 = '';
	LET v_Generico6                 = '';
	LET v_Generico7                 = '';
	LET v_Generico8                 = '';
	LET v_Generico9                 = '';
   
	--SET DEBUG FILE TO "/home/e99806695/sp_domi_valida_alta_ob.out";
	--TRACE ON;
	
	BEGIN
		
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err 
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo), p_sUserStatus, CURRENT);
				
				RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
				NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
			END IF;
		END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

	-- Se validan los parametros de entrada
		IF NVL(pNumcte, '') = '' OR NVL(pCanal, '') = '' OR  NVL(pTipo_domi, '') = '' OR NVL(pNumCuentaTarjetaCargo, '') = '' OR NVL(pNumCuentaTarjetaAbono, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '88801'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
	
	-- Se valida que exista el canal de procedencia
		IF EXISTS (SELECT * FROM bdidomi:"informix".dom_canal where UPPER(descripcion) = UPPER(pCanal)) THEN 
			SELECT cve_canal 
			INTO cCanal
			FROM bdidomi:"informix".dom_canal 
			WHERE UPPER(descripcion) = UPPER(pCanal);
		ELSE
			LET cCodret = '88802'; --El canal no existe en domiciliaciones
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
	
	-- Se valida que exista el tipo de domiciliaci?n
		IF NOT EXISTS (select * from bdidomi:"informix".dom_cat_tipo where cve_tipo = pTipo_domi) THEN
			LET cCodret = '88803'; --El tipo de domiciliaci?n no existe
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
	   
	--Verifica si el numero de cliente existe.
		SELECT numcte
		INTO cNumCte
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte
		AND empresa = '001';
	
		IF cNumCte IS NULL OR cNumCte = '' THEN
			-- NUMERO DE CLIENTE NO EXISTE
			LET cCodret = '88804';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
		--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y clabe de abono
		EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_cuentatarjeta(pNumCuentaTarjetaAbono, p_sUserStatus)
		INTO cCodret, ctipoCuentaAbono, cClaveBancoAbono, cBancoAbono, cBancoAbonoCorto, cCuentaAbono, cNumTarjetaAbono, v_sClabe;
	
		LET ctipoCuentaAbono = '03';
	
		IF cCodret = '00000' THEN
			--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta de cargo
			EXECUTE PROCEDURE bdidomi:"informix".sp_domi_valida_cuentatarjeta_ob(pNumCuentaTarjetaCargo, p_sUserStatus)
			INTO cCodret, ctipoCuentaCargo, cClaveBancoCargo, cBancoCargo, cBancoCargoCorto, cCuentaCargo, cNumTarjetaCargo, v_sClabe;
		END IF;

		--Valida si es una tarjeta de credito de otros bancos
		IF cCodret = '00000' THEN
			IF ctipoCuentaCargo = '05' THEN
				LET cCodret = '88811'; -- no se permiten tarjetas de credito de otros bancos.

				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
				RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
				NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
			END IF
		END IF

		IF cCodret != '00000' THEN
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
		--OBTENER TARJETAS DE CREDITO DEL CLIENTE
		SELECT  a.nombre, b.descripcion, c.num_producto
		INTO cNombreTitular, v_sNombreProductoAbono, cNumProducto
		FROM bdicred:"informix".sd_tarjeta a
		INNER JOIN bdicred:"informix".sd_maecred c
		ON a.num_credito = c.num_credito
		INNER JOIN bdicred:"informix".sd_productos_sdoret b
		ON b.num_producto = c.num_producto
		WHERE a.numcte = pNumcte
		AND a.num_credito = cCuentaAbono
		AND a.status_tar <> 'C'
		AND c.empresa = '001'
		AND c.status_cred in ('E1', 'E2', 'E3')
		AND a.tipo_tarjeta = 'T';
			
		IF EXISTS (SELECT cve_producto FROM bdidomi:"informix".dom_prod_permitidos_tc WHERE cve_producto = cNumProducto) THEN
			SELECT nombre_corto INTO v_sNombreCortoProductoAbono FROM bdidomi:"informix".dom_prod_permitidos_tc WHERE cve_producto = cNumProducto;
			LET iContador = iContador + 1;
		ELSE
			IF cNumProducto = '' OR cNumProducto IS NULL THEN
				LET cCodret = '88805'; --CUENTA DE CREDITO NO ESTA ACTIVA.
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
				RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
				NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
			END IF
		END IF;
	
		IF iContador = 0 THEN
			LET cCodret = '88806'; --CUENTA DE CREDITO NO PERMITIDA PARA DOMICILIACION.
				
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
	--OBTENER RFC DEL SERVICIO
		EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtienerfc(pRazonSocial, p_sUserStatus, pNumCuentaTarjetaCargo) INTO cCodret, cRfcServicio;
		
		IF cCodret != '00000' THEN
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
		
	--CONSULTAR LOS DATOS DEL CLIENTE
		SELECT numcte, TRIM(nombre1), TRIM(nombre2 ), TRIM(apell_paterno), TRIM(apell_materno), rfc
		INTO cNumCte, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte
		AND empresa = '001';
			
		SELECT FIRST 1 telefono
        INTO cNumTelefono
        FROM bdinteg:"informix".si_telefonos_actual
        WHERE numcte= pNumcte
        AND status_tel = 'A'
        AND tipo_tel = 2
        AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND status_tel = 'A' AND tipo_tel = 2)
        AND empresa = '001';
				
		SELECT FIRST 1 correo_elec
        INTO cCorreoElect
        FROM bdinteg:"informix".si_correos
        WHERE numcte= pNumcte 
        AND tipo_correo = 1
        AND status_correo = 'A'
        AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND status_correo = 'A' AND tipo_correo = 1)
        AND empresa = '001';
		
		IF NVL(cCorreoElect, '') = '' THEN
			-- El cliente no cuenta con correo electronico registrado
			LET cCodret = '88807';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
		IF NVL(cNumTelefono, '') = '' THEN
			-- El cliente no cuenta con numero de telefono registrado
			LET cCodret = '88808';
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
			NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');
		END IF;
		
		IF NVL(p_sPeriodo, '') != '' THEN
			SELECT descripcion
			INTO cPeriodicidad
			FROM bdidomi:"informix".dom_cat_periodo
			WHERE cve_periodo = p_sPeriodo;
			
			IF NVL(cPeriodicidad, '') = '' THEN
				--La periodicidad no existe
				LET cCodret = '88809';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_alta_ob', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
				NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');

			END IF;
		END IF;
		
		SELECT folio_activacion
		INTO cFolioAnterior
		FROM bdidomi:"informix".dom_autorizaciones
		WHERE cuenta = 'C'||cCuentaAbono AND cuenta_cargo = cCuentaCargo AND cve_estatus = '02';
		
		RETURN NVL(cCodret,''), NVL(cNumcte,''), NVL(cNumTarjetaAbono,''), NVL(cCuentaAbono,''), NVL(v_sNombreProductoAbono,''), NVL(v_sNombreCortoProductoAbono,''), 
		NVL(cNombreTitular,''), NVL(cNombre1Cte,''), NVL(cNombre2Cte,''), NVL(cApellido1Cte,''), NVL(cApellido2Cte,''), NVL(cRfc,''), NVL(cNumTelefono,''), NVL(cCorreoElect,''), NVL(cCuentaCargo,''), NVL(v_sProducto,''), NVL(v_sNombreProductoCargo,''), NVL(v_sClabe,''), NVL(cNumTarjetaCargo,''), NVL(cBancoCargo,''), NVL(cBancoCargoCorto,''), NVL(cBancoAbono,''), NVL(cBancoAbonoCorto,''), NVL(cCanal,''), NVL(cRfcServicio,''), NVL(ctipoCuentaCargo,''), NVL(ctipoCuentaAbono,''), NVL(cClaveBancoCargo,''), NVL(cPeriodicidad,''),NVL(cFolioAnterior,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''),NVL(v_Generico5,''),NVL(v_Generico6,''),NVL(v_Generico7,''),NVL(v_Generico8,''),NVL(v_Generico9,'');

	END;
END PROCEDURE;