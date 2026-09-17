CREATE PROCEDURE "informix".sp_domi_valida_cuentatarjeta_ob(pNumCuentaTarjeta CHAR(18), p_sUserStatus CHAR(8))
	RETURNING	CHAR (5) 	AS CodRet, --Codigo de Retorno
				CHAR (2) 	AS TipoCuenta, --Tipo de cuenta
				CHAR (3) 	AS ClaveBanco, --Clave del banco
				CHAR (40) 	AS NombreBanco, --Descripcion del banco
				CHAR (40) 	AS NombreCortoBanco, --Nombre de Banco
				CHAR (12)	AS CuentaCredito, --Numero de cuenta o credito
				CHAR (16)	AS NumTarjeta, --Numero de tarjeta
				CHAR (18)	AS Clabe; --CLABE Interbancaria de la cuenta
					
	--DECLARACION DE VARIABLES	
	DEFINE sql_err					INTEGER;
	DEFINE cCodret					CHAR(5);
	DEFINE cNumTarjeta				CHAR(16);
	DEFINE cBIN						CHAR(6);
	DEFINE cTipoCuenta				CHAR(2);
	DEFINE cClaveBanco				CHAR(3);
	DEFINE cNombreBanco				CHAR(40);
	DEFINE cNombreCortoBanco		CHAR(40);
	DEFINE cIdTipoCuenta			CHAR(1);
	DEFINE cCuentaCredito			CHAR(12);
	DEFINE cClabe					CHAR(18);
	DEFINE cCodret2					CHAR(5);
	DEFINE cMensajeRespuesta 		CHAR (110);

    DEFINE cBBIIN 		CHAR (110);
	LET cBBIIN = '';
	--Inicializar Variables
	LET sql_err					= 0;
	LET cCodret					= '00000';
	LET cNumTarjeta				= '';
	LET cBIN					= '';
	LET cTipoCuenta				= '';
	LET cClaveBanco				= '';
	LET cNombreBanco			= '';
	LET cNombreCortoBanco		= '';
	LET cIdTipoCuenta			= '';
	LET cCuentaCredito			= '';
	LET cClabe 					='';
	LET cCodret2				= '';
	LET cMensajeRespuesta		= '';
	
	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_valida_cuentatarjeta_ob.out";
	--TRACE ON;
	
	BEGIN
			
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err 
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta_ob', trim(pNumCuentaTarjeta), p_sUserStatus, CURRENT);
				
				--Regresa Resultados
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		
		-- Se valida el parametro de entrada
		IF NVL(pNumCuentaTarjeta, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '88817'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta_ob', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			 --Regresa Resultados
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		END IF;
		
		IF LENGTH(pNumCuentaTarjeta) = 16 THEN
		--Tarjeta
			LET cBIN = SUBSTR(pNumCuentaTarjeta,1,6);
			--Valida si el Bin de la tarjeta existe 
            IF NOT EXISTS (SELECT * FROM bdicheq:"informix".sc_bines WHERE bin = cBIN AND cve_banco <> '137') THEN 
				LET cCodret = '88810'; --El BIN de tu tarjeta no existe.
			
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta_ob', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
			END IF

			---MODIFICACIION LOG 

			--LET cBBIIN = cBIN;
            --IF  (NVL(cBIN, '')) THEN
               -- LET cCodret = '00000';
            --END IF


			SELECT banco.banco, upper(bin.creditodebito), banco.descripcion, banco.vchrnombrecorto
			INTO cClaveBanco, cIdTipoCuenta, cNombreBanco, cNombreCortoBanco
			FROM bdicheq:"informix".sc_bines bin
			INNER JOIN bdinteg:"informix".si_bancos banco
			ON bin.cve_banco = banco.banco
			WHERE bin.bin = cBIN
			AND banco.flg_domi_r = '1'; 

			IF cIdTipoCuenta = 'D' THEN 
				LET cTipoCuenta='03';

				LET cNumTarjeta = pNumCuentaTarjeta;

			ELIF cIdTipoCuenta = 'C' THEN 
				LET cTipoCuenta = '05';

			END IF;
            
			
			IF ((NVL(cTipoCuenta, '') = '' OR NVL(cClaveBanco, '') = '' OR NVL(cNombreBanco, '') = '' OR NVL(cNombreCortoBanco, '') = '' OR NVL(cNumTarjeta, '') = '')) THEN
				
				LET cCodret = '88818'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta_ob', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);

			END IF;
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		ELSE
			LET cCodret = '88818'; --El numero de cuenta, tarjeta o clabe es incorrecto.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta_ob', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 		Derian Alejandro Sainz Zazueta',
'DESCRIPCION: 	Valida si el Bin de la tarjeta de otros bancos existe y si es de una longitud valida.',
'FECHA: 		15/10/2024',
'BD: 			BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_cuentas_registradas_ob(pNumcte CHAR(20), pNumTarjeta CHAR(18), pCveBanco CHAR(3), pAlias CHAR(30), p_sGenerico1 NVARCHAR(254), p_sGenerico2 NVARCHAR(254), p_sGenerico3 NVARCHAR(254), p_sGenerico4 NVARCHAR(254), p_sGenerico5 NVARCHAR(254))
	RETURNING CHAR(5) 			AS CodRet,
			  NVARCHAR(254) 	AS v_Generico1,--Num_tarjeta
			  NVARCHAR(254)		AS v_Generico2,--NombreBanco
			  NVARCHAR(254)		AS v_Generico3,--NombreTitular
			  NVARCHAR(254)		AS v_Generico4,--Alias
			  NVARCHAR(254)		AS v_Generico5;

	--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;			  
	DEFINE v_sCodRet			CHAR(5);
	DEFINE v_sContador			INTEGER;
    DEFINE cIntentos            CHAR(1); 

	DEFINE v_sGenerico1		NVARCHAR(254);
	DEFINE v_sCveBanco		CHAR(3);
	DEFINE v_sGenerico2		NVARCHAR(254);	
	DEFINE v_sGenerico3		NVARCHAR(254);
	DEFINE v_sGenerico4		NVARCHAR(254);
	DEFINE v_sGenerico5		NVARCHAR(254);

	DEFINE v_sCodRet2			CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);

	-- Inicializacion de variables				
	LET sql_err 					= 0;
	LET v_sCodRet 					= '00000';
	LET v_sContador					= 0;
    LET cIntentos                   = '0';

	LET v_sGenerico1				= '';
	LET v_sCveBanco					= '';
	LET v_sGenerico2				= '';
	LET v_sGenerico3				= '';
	LET v_sGenerico4				= '';
	LET v_sGenerico5				= '';

	LET v_sCodRet2					= '';
	LET cMensajeRespuesta			= '';
	
    --***************************************************************************************
    --SET DEBUG FILE TO "/home/sysdomi/sp_domi_cuentas_registradas_ob.out";
	--TRACE ON;
	--***************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;

				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_cuentas_registradas_ob', trim(pNumcte), '',CURRENT);
				
				RETURN v_sCodRet, v_sGenerico1, v_sGenerico2, v_sGenerico3, v_sGenerico4, v_sGenerico5;	
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

		IF NVL(pNumcte, '') = '' THEN
			LET v_sCodRet = '88833'; -- PARAMETRO DE ENTRADA REQUERIDO ESTÃ?? EN BLANCO.
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_cuentas_registradas_ob', trim(pNumcte) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
			
			RETURN v_sCodRet, v_sGenerico1, v_sGenerico2, v_sGenerico3, v_sGenerico4, v_sGenerico5;	

		END IF;	

		-- VALIDAR SI EXISTE CLIENTE.
		IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte) THEN
			LET v_sCodRet = '88834'; -- CLIENTE NO EXISTENTE.
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_cuentas_registradas_ob', trim(pNumcte) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
			
			RETURN v_sCodRet, v_sGenerico1, v_sGenerico2, v_sGenerico3, v_sGenerico4, v_sGenerico5;	
		END IF;

		-- OBTENER CUENTAS REGISTRADAS.
		FOREACH 

			SELECT num_tarjeta, cve_banco, nombre_titular, concepto, estatus, intentos
			INTO v_sGenerico1, v_sCveBanco, v_sGenerico3, v_sGenerico4, v_sGenerico5, cIntentos
			FROM bdidomi:"informix".dom_cuentas_ob 
			WHERE num_cliente = pNumcte

			SELECT 
				CASE 
					WHEN NVL(vchrnombrecorto, '') = '' THEN 
						(SELECT descripcion FROM bdinteg:"informix".si_bancos WHERE banco = v_sCveBanco)
					ELSE vchrnombrecorto
				END
			INTO v_sGenerico2
			FROM bdinteg:"informix".si_bancos 
			WHERE banco = v_sCveBanco;

			IF NVL(v_sGenerico1, '') != '' AND NVL(v_sCveBanco, '') != '' AND NVL(v_sGenerico3, '') != '' AND NVL(v_sGenerico4, '') != '' AND NVL(v_sGenerico5, '') != '' THEN
				LET v_sContador = 1;
                LET v_sGenerico5 = TRIM(v_sGenerico5) || '&' || cIntentos;
				RETURN v_sCodRet, v_sGenerico1, v_sGenerico2, v_sGenerico3, v_sGenerico4, v_sGenerico5  WITH RESUME;	
			END IF;
		END FOREACH;

		IF v_sContador = 0 THEN
			LET v_sCodRet = '88835'; -- EL CLIENTE NO TIENE CUENTAS REGISTRADAS.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_cuentas_registradas_ob', trim(pNumcte) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
			
			RETURN v_sCodRet, v_sGenerico1, v_sGenerico2, v_sGenerico3, v_sGenerico4, v_sGenerico5;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 		Aldair Cabrera Rodriguez',
'DESCRIPCION: 	Se encarga de consultar las cuentas registradas externas de otros bancos disponibles para domiciliar.',
'FECHA: 		23/01/2024',
'BD: 			BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consulta_autorizacionesactivas_ob(
	p_sNumCte CHAR(20), 
	p_sUserStatus CHAR(8), 
	p_sGenerico1 NVARCHAR(254), 
	p_sGenerico2 NVARCHAR(254), 
	p_sGenerico3 NVARCHAR(254), 
	p_sGenerico4 NVARCHAR(254), 
	p_sGenerico5 NVARCHAR(254)
)
	RETURNING CHAR(5) 			AS codRet, 
			  CHAR(20) 			AS CuentaCargo, -- Cuenta cargo(DebitDeviceAccess)
			  --Domiciliaciones:
			  CHAR(50)			AS aliasServicioDomiciliar, --Alias del servicio a domiciliar
			  CHAR(20) 			AS folioActivacion,--folio activaciï¿½n
			  CHAR(20)			AS numeroTarjetaAbono, --Nï¿½mero de Tarjeta abono #GET SP
			  CHAR(40)			AS nombreProductoAbono, --Nombre del producto abono
			  CHAR(20) 			AS nombreBancoAbono, -- Nombre de banco abono
			  CHAR(10)			AS fechaProximo,--fecha proximo pago
			  CHAR(10)			AS fechaUltimoPago, --ï¿½ltima Fecha de pago
			  MONEY(16,2)		AS montoProximoPago, --monto proximo pago
			  MONEY(16,2)		AS montoUltimoPago, -- ï¿½ltimo monto de pago
			  CHAR(20)	 		AS categoria,	--categoria
			  CHAR(2) 			AS periodicidad,	--periodicidad
			  CHAR(2) 			AS tipoDomiciliacion,
			  CHAR(20)			AS numCreditoAbono,
			  MONEY(16,2)		AS montoPagoFijo,
			  CHAR(1)			AS tipoPago,
			  MONEY(16,2) 		AS montoMaximo,
			  CHAR(10)			AS tipoFechaPago,
			  CHAR(10)			AS fechaPago,
			  CHAR(100)			AS v_generico1,
			  CHAR(100)			AS v_generico2,
			  CHAR(100)			AS v_generico3,
			  CHAR(254)			AS v_generico4,
			  NVARCHAR(254)		AS v_generico5,
			  NVARCHAR(254)		AS v_generico6,
			  NVARCHAR(254)		AS v_generico7,
			  NVARCHAR(254)		AS v_generico8,
  			  NVARCHAR(254)		AS v_generico9;
			  			  
	--Declaracion de  Variables
	DEFINE sql_err 						INTEGER;
	DEFINE v_iContador 					INTEGER;	
	DEFINE v_cDataAux					CHAR(100);	
			  
	DEFINE v_sCodRet					CHAR(5);	
	DEFINE v_sCuentaCargo				CHAR(20);
	--Domiciliaciones:
	
	DEFINE v_sAliasServicioDomi			CHAR(50);
	DEFINE v_sFolioActivacion			CHAR(20);
	DEFINE v_sNumeroTarjetaAbono		CHAR(20);
	DEFINE v_sNombreProductoAbono		CHAR(40);
	DEFINE v_sFechaProximo				CHAR(10);
	DEFINE v_sFechaUltimoPago			CHAR(10);
	DEFINE v_mMontoUltimoPago			MONEY(16,2);
	DEFINE v_mMontoProximoPago			MONEY(16,2);
	--data return sp sp_domi_valida_cuentatarjeta
	DEFINE ctipoCuentaAbono				CHAR(2);
	DEFINE cClaveBancoAbono				CHAR(3);
	DEFINE v_sDescripcionBancoAbono		CHAR(40);
	DEFINE v_sNombreBancoAbono			CHAR(20);
	DEFINE v_sCuentaAbono				CHAR(20);
	DEFINE v_sClabeInterbancaria_ab 	CHAR(20);
	DEFINE v_sClabeInterbancaria_ca		CHAR(20);
	DEFINE v_sCategoria   				CHAR(20);
	DEFINE v_sPeriodicidad				CHAR(2);
	DEFINE v_sCodRet2					CHAR(5);
	DEFINE cMensajeRespuesta 			CHAR (110);
	DEFINE v_sTipoDomiciliacion			CHAR(2);
	DEFINE v_sTipoPago					CHAR(1);
	DEFINE v_sImpMaximo					CHAR(100);
	DEFINE v_sMontoPagoFijo				CHAR(100);
	DEFINE v_sTipoFechaPago				CHAR(100);
	DEFINE v_sFechaPago					CHAR(10);
	DEFINE v_generico1					CHAR(100);
	DEFINE v_generico2					CHAR(100);	 			
	DEFINE v_generico3					CHAR(100);	
	DEFINE v_generico4					CHAR(100);
	DEFINE v_generico5					NVARCHAR(254);
	DEFINE v_generico6					NVARCHAR(254);	 			
	DEFINE v_generico7					NVARCHAR(254);	
	DEFINE v_generico8					NVARCHAR(254);
	DEFINE v_generico9					NVARCHAR(254);

	-- Inicializacion de variables				
	LET sql_err 					= 0;
	LET v_sCodRet 				
	= '00000';
	LET v_iContador					= 0;
	
	LET v_sCuentaCargo 				= '';
	--Domiciliaciones:
	LET v_sAliasServicioDomi		= '';	
	LET v_sFolioActivacion			= '';	
	LET v_sNumeroTarjetaAbono		= '';
	LET v_sNombreProductoAbono 		= '';
	LET v_sFechaProximo		  		= '';
	LET v_sFechaUltimoPago 	 		= '';
	LET v_mMontoUltimoPago 		 	= 0.00;
	LET v_mMontoProximoPago 		= 0.00;
	--data return sp sp_domi_valida_cuentatarjeta
	LET ctipoCuentaAbono			= '';
	LET cClaveBancoAbono			= '';
	LET v_sDescripcionBancoAbono	= '';	
	LET v_sNombreBancoAbono			= '';
	LET v_sCuentaAbono				= '';	
	LET v_sClabeInterbancaria_ab	= '';
	LET v_sClabeInterbancaria_ca 	= '';
	LET v_sCategoria				= '';
	LET v_sPeriodicidad				= '';
	let v_cDataAux 					= '';
	LET v_sCodRet2					= '';
	LET cMensajeRespuesta			= '';
	LET v_sTipoDomiciliacion		= '';
	LET v_sTipoPago					= '';
	LET v_sImpMaximo				= '';
	LET v_sMontoPagoFijo			= '';
	LET v_sTipoFechaPago			= '';
	LET v_sFechaPago  			    = '';
	LET v_generico1					= '';
	LET v_generico2					= '';
	LET v_generico3					= '';
	LET v_generico4					= '';
	LET v_generico5					= '';
	LET v_generico6					= '';
	LET v_generico7					= '';
	LET v_generico8					= '';
	LET v_generico9					= '';

	--*********************************************************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_consulta_autorizacionesactivas_ob.out";
	--TRACE ON;
	--*********************************************************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacionesactivas_ob', trim(p_sNumCte), p_sUserStatus, CURRENT);
				
				RETURN NVL(v_sCodRet,''),NVL(v_sCuentaCargo,''),NVL(v_sAliasServicioDomi,''),NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreBancoAbono,''),NVL(v_sFechaProximo,''),NVL(v_sFechaUltimoPago,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoUltimoPago,''), NVL(v_sCategoria,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''), NVL(v_sCuentaAbono,''), NVL(v_sMontoPagoFijo,''), NVL(v_sTipoPago,''), NVL(v_sImpMaximo,''),  NVL(v_sTipoFechaPago,''), NVL(v_sFechaPago,''), NVL(v_generico1,''), NVL(v_generico2,''), NVL(v_generico3,''), NVL(v_generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
			END IF;


		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		IF NVL(p_sNumCte, '') = '' OR NVL(p_sUserStatus, '') = ''  THEN
			LET v_sCodRet = '88815'; --PARAMETROS DE ENTRADA ESTAN EN BLANCO.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacionesactivas_ob', trim(p_sNumCte) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			
			RETURN NVL(v_sCodRet,''),NVL(v_sCuentaCargo,''),NVL(v_sAliasServicioDomi,''),NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreBancoAbono,''),NVL(v_sFechaProximo,''),NVL(v_sFechaUltimoPago,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoUltimoPago,''), NVL(v_sCategoria,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''), NVL(v_sCuentaAbono,''), NVL(v_sMontoPagoFijo,''), NVL(v_sTipoPago,''), NVL(v_sImpMaximo,''),  NVL(v_sTipoFechaPago,''), NVL(v_sFechaPago,''), NVL(v_generico1,''), NVL(v_generico2,''), NVL(v_generico3,''), NVL(v_generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;	
		
		FOREACH 
			SELECT 
			 d_aut.cuenta_cargo --Cuenta cargo(DebitDeviceAccess)
			--domiciliaciones:
			, NVL(d_aut.alias_domi,'') as alias_domi --Alias del servicio a domiciliar.
			, d_aut.folio_activacion --Folio activaciï¿½n
			, d_aut.cuenta --cuenta abono (CreditDevicesAccess)
			, prod_tc.nombre_corto --Nombre corto del producto abono
			, TO_CHAR(f_pago.fecha_prox_pago,'%Y-%m-%d') as fecha_prox_pago --Fecha proximo pago
			, TO_CHAR(f_pago.fecha_ult_pago,'%Y-%m-%d') as fecha_ult_pago --Ultima Fecha de pago 
			, d_pagos.monto_ultimo_pago --ï¿½ltimo monto de pago
			, d_pagos.monto_proximo_pago --Monto del proximo pago
			, c_tipo.categoria
			, f_pago.periodo
			, d_arch_man.tipo_domi
			, d_aut.cve_domiciliar_tc
			, d_aut.imp_maximo
			, d_aut.imp_fijo_tc
			, TO_CHAR(f_pago.fecha_pago,'%Y-%m-%d') as fecha_pago --Fecha pago
			, d_act_ob.estatus	
			, banco.vchrnombrecorto
			INTO 
			 v_sCuentaCargo,
			--Domiciliaciones:
			 v_sAliasServicioDomi,
             v_sFolioActivacion,
			 v_sCuentaAbono,
			 v_sNombreProductoAbono,
			 v_sFechaProximo,
			 v_sFechaUltimoPago,
			 v_mMontoUltimoPago,
			 v_mMontoProximoPago,
			 v_sCategoria,
			 v_sPeriodicidad,
			 v_sTipoDomiciliacion,
			 v_sTipoPago,
			 v_sImpMaximo,
			 v_sMontoPagoFijo,
			 v_sFechaPago,
			 v_generico1,
			 v_generico2
			FROM bdidomi:"informix".dom_autorizaciones d_aut
			INNER JOIN bdidomi:"informix".dom_archivomanual d_arch_man ON d_aut.folio_activacion = d_arch_man.folio_activacion  	
			INNER JOIN bdidomi:"informix".dom_cuentas_ob ctas_ob ON d_aut.cuenta_cargo = ctas_ob.num_tarjeta
			INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob d_act_ob ON d_act_ob.folio_activacion = d_aut.folio_activacion
			INNER JOIN bdicred:"informix".sd_maecred sd_mac ON d_aut.num_cte = sd_mac.numcte AND (d_aut.cuenta = sd_mac.num_credito OR d_aut.cuenta=(SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE numcte = d_aut.num_cte AND num_tarjeta = d_aut.cuenta))
			INNER JOIN bdicred:"informix".sd_definicion sd_def ON sd_def.num_producto = sd_mac.num_producto
			INNER JOIN bdidomi:"informix".dom_fecha_pago f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
			INNER JOIN bdidomi:"informix".dom_pago d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
			INNER JOIN bdidomi:"informix".dom_cat_tipo c_tipo ON d_arch_man.tipo_domi = c_tipo.cve_tipo
			INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc prod_tc ON sd_def.num_producto = prod_tc.cve_producto
			INNER JOIN bdinteg:"informix".si_bancos banco ON d_arch_man.cve_banco_cargo = banco.banco 			
			WHERE d_aut.num_cte = p_sNumCte
			AND d_aut.cve_estatus = '01'
			GROUP BY d_aut.cve_estatus,	d_aut.cuenta_cargo, d_aut.alias_domi, d_aut.folio_activacion, d_aut.cuenta , sd_def.nombre_prod,prod_tc.nombre_corto,
			f_pago.fecha_prox_pago, f_pago.fecha_ult_pago, d_pagos.monto_ultimo_pago, d_pagos.monto_proximo_pago, c_tipo.categoria, f_pago.periodo, 
			d_arch_man.tipo_domi, d_aut.cve_domiciliar_tc , d_aut.imp_maximo, prod_tc.nombre_corto, d_aut.imp_fijo_tc,f_pago.fecha_pago, d_act_ob.estatus,
			banco.vchrnombrecorto
			ORDER BY d_aut.cuenta_cargo DESC	
			
			--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de cargo
			EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta_ob(v_sCuentaCargo, p_sUserStatus)
			INTO v_sCodRet, v_cDataAux, v_cDataAux, v_cDataAux, v_cDataAux, v_cDataAux, v_sCuentaCargo, v_sClabeInterbancaria_ca;
				
			IF v_sCodRet= '00000' THEN
				--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de abono
				EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(v_sCuentaAbono, p_sUserStatus) 
				INTO v_sCodRet, ctipoCuentaAbono, cClaveBancoAbono, v_sDescripcionBancoAbono, v_sNombreBancoAbono, v_sCuentaAbono, v_sNumeroTarjetaAbono, v_sClabeInterbancaria_ab;
				
				IF v_sCodRet = '00000' THEN
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(v_sTipoPago, '001',v_sCuentaAbono,p_sUserStatus,v_sFolioActivacion, v_sTipoDomiciliacion)
					INTO v_sCodRet, v_mMontoProximoPago;
				END IF;
				
				SELECT CASE COUNT(*) 
					WHEN 1 THEN 'LIMITE'
					ELSE 'FIJA'
				END
				INTO v_sTipoFechaPago
				FROM bdidomi:"informix".dom_fecha_pago f_pago
				INNER JOIN bdicred:"informix".sd_maecredanexo as sma ON f_pago.fecha_prox_pago = sma.prox_fecha_pago 
				WHERE sma.num_credito = v_sCuentaAbono AND f_pago.folio_activacion = v_sFolioActivacion;
			
			END IF;	

			IF v_sCodRet <> '00000' THEN
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacionesactivas_ob', trim(p_sNumCte) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
						
			END IF;
			
			IF v_sCodRet = '00000' THEN
				LET v_iContador = 1;
				RETURN NVL(v_sCodRet,''),NVL(v_sCuentaCargo,''),NVL(v_sAliasServicioDomi,''),NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreBancoAbono,''),NVL(v_sFechaProximo,''),NVL(v_sFechaUltimoPago,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoUltimoPago,''), NVL(v_sCategoria,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''), NVL(v_sCuentaAbono,''), NVL(v_sMontoPagoFijo,''), NVL(v_sTipoPago,''), NVL(v_sImpMaximo,''),  NVL(v_sTipoFechaPago,''), NVL(v_sFechaPago,''), NVL(v_generico1,''), NVL(v_generico2,''), NVL(v_generico3,''), NVL(v_generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'') WITH RESUME;
			END IF;
		
		END FOREACH;
		
		IF v_iContador = 0 THEN
			LET v_sCodRet = '88816'; --El cliente no cuenta con domiciliaciones activas.
			
			RETURN NVL(v_sCodRet,''),NVL(v_sCuentaCargo,''),NVL(v_sAliasServicioDomi,''),NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreBancoAbono,''),NVL(v_sFechaProximo,''),NVL(v_sFechaUltimoPago,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoUltimoPago,''), NVL(v_sCategoria,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''), NVL(v_sCuentaAbono,''), NVL(v_sMontoPagoFijo,''), NVL(v_sTipoPago,''), NVL(v_sImpMaximo,''),  NVL(v_sTipoFechaPago,''), NVL(v_sFechaPago,''), NVL(v_generico1,''), NVL(v_generico2,''), NVL(v_generico3,''), NVL(v_generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;
		
	END; 
END procedure 
DOCUMENT
'AUTOR: 		Derian Alejandro Sainz Zazueta',
'DESCRIPCION: 	Se encarga de consultar las domiciliaciones que estan activas.',
'FECHA: 		15/01/2024',
'BD: 			BDIDOMI';

CREATE PROCEDURE "informix".sp_dom_cancela_autorizacion(p_sFolioActivacion CHAR(20), p_sFolioCancelacion CHAR(20), p_sNumeroCliente CHAR(20), p_sMotivo CHAR(100), p_sUserStatus CHAR(8))
	RETURNING CHAR(5) AS codRet, --Codigo de Retorno
			  CHAR(100)	AS v_generico1,
			  CHAR(100)	AS v_generico2,
			  CHAR(100)	AS v_generico3,
			  CHAR(100)	AS v_generico4;

--Declaracion de  Variables

	DEFINE sql_err 				INTEGER;
	DEFINE sCodret 				CHAR(5);
	DEFINE cInTransaction	 	CHAR(1);
	DEFINE iContador 			INTEGER;
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
    DEFINE cIdCancelacion       CHAR(10);
	DEFINE v_generico1			CHAR (110);
	DEFINE v_generico2			CHAR (110);
	DEFINE v_generico3			CHAR (110);
	DEFINE v_generico4			CHAR (110);

	--Inicializo Variables
	LET sql_err 			= 0;
	LET sCodret 			= '00000';
	LET iContador 			= 0;
	LET cInTransaction      = 'N';
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET v_generico1			= '';
	LET v_generico2			= '';
	LET v_generico3			= '';
	LET v_generico4			= '';
    LET cIdCancelacion      = '';

	--*************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_dom_cancela_autorizacion.out";
	--TRACE ON;
	--*************************************************************************

	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN

				IF cInTransaction = 'S' THEN
					ROLLBACK WORK;
				END IF;

				LET sCodret = sql_err;

				--En caso de error hacemos rollback.
				IF iContador = 2 THEN
					--Rollack de la tabla bdidomi:dom_autorizaciones.
					UPDATE bdidomi:"informix".dom_autorizaciones
					SET (cve_causa, cuenta, user_insert) =
					(
						'00',
						(select SUBSTR(cuenta, 2, 16) FROM bdidomi:"informix".dom_autorizaciones WHERE folio_activacion = p_sFolioActivacion),
						p_sUserStatus
					)
					WHERE folio_activacion = p_sFolioActivacion;
				END IF;

				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_cancela_autorizacion', trim(p_sFolioCancelacion), p_sUserStatus, CURRENT);

				RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			--ROLLBACK WORK;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--Valida parametros de entrada
		 IF NVL(p_sFolioActivacion,'') = '' OR NVL(p_sFolioCancelacion,'') = '' OR NVL(p_sNumeroCliente,'') = '' OR NVL(p_sMotivo,'') = '' OR NVL(p_sUserStatus,'') = '' THEN
			LET sCodret = '99937'; --Algun parametro de entrada requerido esta en blanco.

			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_cancela_autorizacion', trim(p_sFolioCancelacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);

			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		END IF;

		--Busca la domiciliacion en la tabla bdidomi:dom_cancelaciones.
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_cancelaciones WHERE folio_activacion = p_sfolioActivacion AND folio_cancelacion = p_sFolioCancelacion) THEN
			LET sCodret = '99974'; --YA SE ENCUENTRA LA DOMICILIACIï¿½?N CANCELADA.

			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_cancela_autorizacion', trim(p_sFolioCancelacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);

			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
		ELSE

			--Actualiza la tabla bdidomi:dom_autorizaciones.
			UPDATE bdidomi:"informix".dom_autorizaciones
			SET (cve_causa, cuenta, user_insert) =
			(
				'02',
				TRIM((select cuenta FROM bdidomi:"informix".dom_autorizaciones WHERE folio_activacion = p_sFolioActivacion)),
				p_sUserStatus
			)
			WHERE folio_activacion = p_sFolioActivacion;

            -- Extraemos el ID de cancelacion en caso de encontrarse.
            LET cIdCancelacion = SUBSTR(p_sMotivo, 1, INSTR(p_sMotivo, ":") - 1);

            IF NVL(cIdCancelacion,'') != '' THEN
                --Almacena los datos en la tabla bdidomi:dom_cancelaciones. En el caso de Otros Bancos con cod_cancelacion.
                INSERT INTO bdidomi:"informix".dom_cancelaciones(folio_activacion, folio_cancelacion, motivo, user_insert, fecha_insert, cod_cancelacion)
                VALUES(p_sFolioActivacion, p_sFolioCancelacion, p_sMotivo, p_sUserStatus, CURRENT::DATE, cIdCancelacion);
            ELSE
                --Almacena los datos en la tabla bdidomi:dom_cancelaciones. En el caso del MVP.
                INSERT INTO bdidomi:"informix".dom_cancelaciones(folio_activacion, folio_cancelacion, motivo, user_insert, fecha_insert)
                VALUES(p_sFolioActivacion, p_sFolioCancelacion, p_sMotivo, p_sUserStatus, CURRENT::DATE);
            END IF;

			LET iContador = 2;

			BEGIN WORK;

				LET cInTransaction = 'S';

				DELETE FROM bdidomi:"informix".dom_archivomanual
				WHERE folio_activacion = p_sFolioActivacion AND estatus = 'EP' AND accion = 'A';

			COMMIT WORK;
			LET cInTransaction = 'N';

		END IF;

		RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 			Derian Alejandro Sainz Zazueta',
'DESCRIPCION: 		Se encarga de cancelar el servicio de Domiciliacion',
'FECHA: 			26/02/2022',
'MODIFICACION:    	Se realizo una modificacion para recibir un codigo de cancelacion y guardarlo en la tabla bdidomi:dom_cancelaciones',
'EDITOR:            Derian Alejandro Sainz Zazueta',
'FECHA:           	27/10/2024',
'BD: 				BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_reversa_archivomanual_ob(
	p_sFolioActivacion CHAR(20),
	p_sUserStatus CHAR(8),
	p_sAccion CHAR(1),
	p_sNumCliente CHAR(9),
	p_sCuentaCargo CHAR(20),
	p_sCuentaAbono CHAR(20),
	p_sEstatusCtaCargoCecoban CHAR(2),
	p_sGenerico1 NVARCHAR(254),
	p_sGenerico2 NVARCHAR(254),
	p_sGenerico3 NVARCHAR(254),
	p_sGenerico4 NVARCHAR(254),
	p_sGenerico5 NVARCHAR(254)
)
    RETURNING CHAR(5) AS codRet,
              NVARCHAR(254) AS v_generico1,
			  NVARCHAR(254)	AS v_generico2,
			  NVARCHAR(254)	AS v_generico3,
			  NVARCHAR(254)	AS v_generico4,
			  NVARCHAR(254)	AS v_generico5,
			  NVARCHAR(254)	AS v_generico6,
			  NVARCHAR(254)	AS v_generico7,
			  NVARCHAR(254)	AS v_generico8,
			  NVARCHAR(254)	AS v_generico9;

--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE sCodret 				CHAR(5);


	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	DEFINE v_generico1			NVARCHAR(254);
	DEFINE v_generico2			NVARCHAR(254);
	DEFINE v_generico3			NVARCHAR(254);
	DEFINE v_generico4			NVARCHAR(254);
	DEFINE v_generico5			NVARCHAR(254);
	DEFINE v_generico6			NVARCHAR(254);
	DEFINE v_generico7			NVARCHAR(254);
	DEFINE v_generico8			NVARCHAR(254);
	DEFINE v_generico9			NVARCHAR(254);

	--Inicializo Variables
	LET sql_err 			= 0;
	LET sCodret 			= "00000";
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET v_generico1			= '';
	LET v_generico2			= '';
	LET v_generico3			= '';
	LET v_generico4			= '';
    LET v_generico5			= '';
	LET v_generico6			= '';
	LET v_generico7			= '';
	LET v_generico8			= '';
    LET v_generico9			= '';

	--*********************************************************************************************************************************
	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_reversa_archivomanual_ob.out";
	--TRACE ON;
	--*********************************************************************************************************************************

	BEGIN

		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;

				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_domi_reversa_archivomanual_ob', TRIM(p_sFolioActivacion), p_sUserStatus, CURRENT);

				RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5 , v_generico6 , v_generico7 , v_generico8 , v_generico9;
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--Valida parametros de entrada
		IF
			NVL(p_sfolioActivacion,'') = ''
			OR NVL(p_sUserStatus,'') = ''
			OR NVL(p_sAccion,'') = ''
			OR NVL(p_sNumCliente,'') = ''
			OR NVL(p_sCuentaCargo,'') = ''
			OR NVL(p_sCuentaAbono,'') = ''
		THEN

			LET sCodret = '88833'; --Problema con los parametros

			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_domi_reversa_archivomanual_ob', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);

            RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5 , v_generico6 , v_generico7 , v_generico8 , v_generico9;

		END IF;

		--Valida si existe la domiciliacion.
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sfolioActivacion AND estatus = 'EP') THEN

			IF (p_sAccion = 'B') THEN
				IF EXISTS (select 1 from bdidomi:"informix".dom_archivomanual a
					inner join  bdidomi:"informix".dom_archivomanual b on a.folio_activacion = b.folio_activacion and a.accion = 'A' and b.accion = 'B'
					WHERE a.folio_activacion = p_sfolioActivacion AND a.estatus = 'EP') THEN

					--Elimina registros de las tablas referentes al archivo manual
					DELETE FROM bdidomi:"informix".dom_archivomanual
					WHERE folio_activacion = p_sfolioActivacion AND accion = 'A';

				END IF;

				UPDATE bdidomi:"informix".dom_archivomanual SET accion = 'A'
				WHERE folio_activacion = p_sfolioActivacion AND accion = p_sAccion;

				UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob SET estatus = p_sEstatusCtaCargoCecoban
				WHERE folio_activacion = p_sFolioActivacion;

				UPDATE bdidomi:"informix".dom_cuentas_ob SET estatus = p_sEstatusCtaCargoCecoban
				WHERE num_cliente = p_sNumCliente AND num_tarjeta = LTRIM(p_sCuentaCargo,'0');

				UPDATE bdidomi:"informix".dom_cte_detalle SET accion = 'A'
				WHERE cuenta_abono = TO_CHAR(TRIM(p_sCuentaAbono), "&&&&&&&&&&&&&&&&&&&&")
				AND cuenta_cargo = TO_CHAR(TRIM(p_sCuentaCargo), "&&&&&&&&&&&&&&&&&&&&")
				AND fecha_envio = (SELECT fecha_envio FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sFolioActivacion);

			END IF;

			IF (p_sAccion = 'A') THEN
				--Elimina registros de las tablas referentes al archivo manual
				DELETE FROM bdidomi:"informix".dom_archivomanual
				WHERE folio_activacion = p_sfolioActivacion AND accion = p_sAccion;

				DELETE FROM bdidomi:"informix".dom_fecha_pago
				WHERE folio_activacion = p_sfolioActivacion;

				DELETE FROM bdidomi:"informix".dom_pago
				WHERE folio_activacion = p_sfolioActivacion;

				DELETE bdidomi:"informix".dom_activacion_domiciliacion_ob
				WHERE folio_activacion = p_sFolioActivacion;

				DELETE bdidomi:"informix".dom_cuentas_ob
				WHERE num_cliente = p_sNumCliente AND num_tarjeta = LTRIM(p_sCuentaCargo,'0');

				-- Se aplica reversa a la domiciliacion
				EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus_edicion(p_sFolioActivacion, p_sUserStatus, '02', '', '', '', '', '', '','')
				INTO sCodret, v_generico1, v_generico2, v_generico3, v_generico4;

				IF sCodret != '00000' THEN
					--Obtenemos los datos del error ocurrido.
					EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

					--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
					INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_reversa_archivomanual_ob', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);
				END IF;

			END IF;

		END IF;

        RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5 , v_generico6 , v_generico7 , v_generico8 , v_generico9;

	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Derian Alejandro Sainz Zazueta',
'DESCRIPCION: Se encarga de reversar el guardado del archivo manual de la parte de otros bancos.',
'FECHA      : 25/02/2024',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_notificacion_estatus_cargos(
    p_sUserStatus CHAR(8), 			-- Usuario que inserta.
	p_iCobro CHAR(2),               -- Variable que indica si el cobro fue exitoso o no.
    p_sCausaRechazo CHAR(2),        -- Causa de rechazo del cobro por parte de CECOBAN.
	p_sFolioActivacion CHAR(16), 	-- Folio de activacion.
	p_sNumCte CHAR(9),				-- Numero de cliente.
	p_sNumTarjetaCargo CHAR(16),	-- Numero de tarjeta de debito.
	p_sNombreCte1 CHAR(100),		-- Nombre del cliente.
	p_sApellidoCte1 CHAR(100),		-- Apellido del cliente.
	p_sCtaCargoX CHAR(4),			-- Ultimos 4 digitos del numero de tarjeta de debito.
	p_sCtaAbonoX CHAR(4),			-- Ultimos 4 digitos de la cuenta de credito.
	p_mImpMaximo MONEY(16,2),		-- Importe maximo permitido para domiciliar.
	p_sProductName CHAR(40),		-- Nombre del producto de credito.
	p_mMontoPagar DECIMAL(18,2),    -- Monto a pagar.
	p_sCorreoElect CHAR(50),		-- Correo electronico del cliente.
	p_sProductShortName CHAR(20), 	-- Nombre corto del producto de credito.
	p_sNumTelefono CHAR(10),    	-- Numero de telefono del cliente.
    p_sRefLeyenda CHAR(40)          -- Referencia del servicio.
)
    RETURNING  CHAR(5) AS codRet;

    --DECLARACION DE VARIABLES
	DEFINE sql_err 				INTEGER;			  
	DEFINE v_sCodRet			CHAR(5);
	DEFINE v_sCodRet2			CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
    DEFINE v_sContador          INTEGER;

    DEFINE v_dFechaHoy          DATE;
    DEFINE v_sNumTarjeta        CHAR(20);
    DEFINE v_sCuentaCargo       CHAR(20);
    DEFINE v_sEstatus           CHAR(3);
    DEFINE v_sCausa_Rechazo     CHAR(3);
    DEFINE v_sFolio_Activacion  CHAR(20);
    DEFINE v_sImpMaximo         CHAR(20);
    DEFINE v_sRefLeyenda        CHAR(100);
    DEFINE v_sContratoEmail     CHAR(20);
    DEFINE v_sContratoSms       CHAR(20);
   
   	DEFINE v_generico1			CHAR(100); 
   	DEFINE v_generico2			CHAR(100); 
   	DEFINE v_generico3 			CHAR(100); 
   	DEFINE v_generico4 			CHAR(100);

    --Inicializar Variables	
	LET sql_err 					= 0;
	LET v_sCodRet 					= '00000';
	LET v_sCodRet2					= '';
	LET cMensajeRespuesta			= '';
    LET v_sContador                 = 0;

    LET v_dFechaHoy                 ='';
    LET v_sNumTarjeta               ='';
    LET v_sCuentaCargo              ='';
    LET v_sEstatus                  ='';
    LET v_sCausa_Rechazo            ='';
    LET v_sFolio_Activacion         ='';
    LET v_sImpMaximo                ='';
    LET v_sRefLeyenda               ='';
    LET v_sContratoEmail            ='';
    LET v_sContratoSms              ='';
	
	--***************************************************************************************
	--SET DEBUG FILE TO "/informix/Derian1/TRACE/sp_domi_notificacion_estatus_cargos.out";
	--TRACE ON;
	--***************************************************************************************

    BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;

				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_notificacion_estatus_cargos', trim(v_sFolio_Activacion), '', CURRENT);
				
				RETURN v_sCodRet;	
			END IF;
		END EXCEPTION;
	
        --VALIDA PARAMETROS DE ENTRADA
		IF (
            NVL(p_sUserStatus, '') = ''
            OR NVL(p_iCobro, '') = ''
            OR NVL(p_sFolioActivacion, '') = ''
            OR NVL(p_sNumCte, '') = ''
            OR NVL(p_sNumTarjetaCargo, '') = ''
            OR NVL(p_sNombreCte1, '') = ''
            OR NVL(p_sApellidoCte1, '') = ''
            OR NVL(p_sCtaCargoX, '') = ''
            OR NVL(p_sCtaAbonoX, '') = ''
            OR NVL(p_mImpMaximo, '') = ''
            OR NVL(p_sProductName, '') = ''
            OR NVL(p_mMontoPagar, '') = ''
            OR NVL(p_sCorreoElect, '') = ''
            OR NVL(p_sProductShortName, '') = ''
            OR NVL(p_sNumTelefono, '') = ''
            OR NVL(p_sRefLeyenda, '') = ''
        )
        THEN
			LET v_sCodRet = '88836'; -- PARAMETRO DE ENTRADA REQUERIDO ESTA EN BLANCO.
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cargos', trim(v_sFolio_Activacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
			
			RETURN v_sCodRet;	

		END IF;	

        SELECT fecha_hoy INTO v_dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';

        -- Se obtienen los parametros de los contratos y plantillas de notificaciones.
        SELECT valor INTO v_sContratoEmail FROM bdidomi:"informix".dom_parametros WHERE cod_param = '61';
        SELECT valor INTO v_sContratoSms FROM bdidomi:"informix".dom_parametros WHERE cod_param = '62';

        -- ENVIO DE NOTIFICACIONES
        IF p_iCobro = 1 THEN -- CUANDO EL COBRO FUE EXITOSO

            -- SE ENVIA NOTIFICACION DE QUE SU ABONO FUE EXITOSO.
            -- Eliminar la relacion de confianza @lat_tcp para produccion.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',v_sContratoEmail,'DOM_COB_EX', p_sNumCte, 
            p_sCtaCargoX, p_sNumTarjetaCargo,'1',p_sCtaAbonoX,p_sCtaCargoX, p_sCtaAbonoX, v_dFechaHoy,p_sProductName, 
            p_sFolioActivacion, p_mMontoPagar,'','','',p_sCorreoElect,'',1,0,0,0,0, CURRENT,'') INTO v_sCodRet2;
            
            -- Eliminar la relacion de confianza @lat_tcp para produccion.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_PAGEXI',p_sNumCte,'','',
            '1','','','','','','',p_sCtaAbonoX,TO_CHAR(v_dFechaHoy, '%d/%m'),p_sProductShortName,'','',p_sNumTelefono,0,0,0,0,0,'','') INTO v_sCodRet2;

        ELIF p_iCobro = 2 THEN -- CUANDO EL COBRO NO FUE EXITOSO
            
            IF p_sCausaRechazo = 'PR' THEN
                -- SE ENVIA NOTIFICACION DE QUE SU COBRO NO FUE EXITOSO Y SE REINTENTARA.
                -- Eliminar la relacion de confianza @lat_tcp para produccion.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_REINPAG',p_sNumCte,'','',
                '1','','','','','','',p_sCtaAbonoX,TO_CHAR(v_dFechaHoy + 1, '%d/%m'),p_sProductShortName,'','',p_sNumTelefono,0,0,0,0,0,'','') INTO v_sCodRet2;
            END IF;

            -- SE ENVIA NOTIFICACION DE QUE SU COBRO NO FUE EXITOSO.
            -- Eliminar la relacion de confianza @lat_tcp para produccion.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',v_sContratoEmail,'DOM_COB_NOEX', p_sNumCte, 
            p_sCtaCargoX, p_sNumTarjetaCargo,'1',p_sCtaAbonoX,p_sCtaCargoX, p_sCtaAbonoX, v_dFechaHoy,p_sProductName, 
            p_sFolioActivacion, p_mMontoPagar,'','','',p_sCorreoElect,'',1,0,0,0,0, CURRENT,'') INTO v_sCodRet2;

            -- Eliminar la relacion de confianza @lat_tcp para produccion.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_PAGNOEXI',p_sNumCte,'','',
            '1','','','','','','',p_sCtaAbonoX,'',p_sProductShortName,'','',p_sNumTelefono,0,0,0,0,0,'','') INTO v_sCodRet2;

        END IF;
    END;
END PROCEDURE

DOCUMENT
'AUTOR: 		Derian Alejandro Sainz Zazueta',
'DESCRIPCION: 	ENVIO DE NOTIFICACIONES CUANDO. EL COBRO FUE EXITOSO. SE ENVIA NOTIFICACION DE QUE SU COBRO NO FUE EXITOSO Y SE REINTENTARA. SE ENVIA NOTIFICACION DE QUE SU COBRO NO FUE EXITOSO.',
'FECHA: 		15/10/2024',
'BD: 			BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_pendientes_pago()
	RETURNING char(5) AS cCodeRet

-- DECLARACIÓN DE VARIABLES 
DEFINE iSqlerr      				INTEGER;
DEFINE cCoderet     				CHAR(5);
DEFINE dFechaActual 				DATE;
DEFINE cFolioActivacion  			CHAR(20);
DEFINE cNumCte_banco       			CHAR(20);
DEFINE dFechaPago					DATE;
-- VALORES INICIALES
LET iSqlerr    			=  0;
LET cCoderet   			= '00000';
LET cFolioActivacion	= '';

	--***************************************************************************************
	--SET DEBUG FILE TO "/informix/Derian1/TRACE/sp_domi_pendientes_pago.out";
	--TRACE ON;
	--***************************************************************************************

begin
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN 
			LET cCoderet = iSqlerr;
			RETURN cCoderet;
		END IF;
	END EXCEPTION;
	
	--***************************************************************************************
--	SET DEBUG FILE TO "/home/sysdomi/sp_domi_pendientes_pago.out"; --"/informix/VaneYAM/sp_domi_pendientes_pago.out";
--	TRACE ON;
	--***************************************************************************************
	
	SET ISOLATION TO DIRTY READ;

	--Obtener fecha actual.
	SELECT fecha_hoy 
	INTO dFechaActual 
	FROM bdinteg:"informix".si_fechas where empresa='001';

	IF (dFechaActual = current::DATE) then
		SELECT TRIM(valor) INTO cNumCte_banco FROM bdidomi:"informix".dom_parametros WHERE cod_param = '36';
	
		FOREACH WITH HOLD
			SELECT a.folio_activacion, d.fecha_prox_pago 
			INTO cFolioActivacion, dFechaPago
			FROM bdidomi:"informix".dom_autorizaciones a
			INNER JOIN bdidomi:"informix".dom_archivomanual b 		ON a.folio_activacion 	= b.folio_activacion 
			INNER JOIN bdidomi:"informix".dom_pago c 				ON a.folio_activacion 	= c.folio_activacion 
			INNER JOIN bdidomi:"informix".dom_fecha_pago d 			ON a.folio_activacion 	= d.folio_activacion
			WHERE a.cve_estatus = '01'
			AND d.fecha_prox_pago = dFechaActual
			AND b.estatus = 'EP'
            AND b.tipo_domi = '01'

			IF( NVL(cFolioActivacion,'') != '' ) then
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_createtablascte(cFolioActivacion, cNumCte_banco, 'sysdomi', dFechaPago) INTO cCoderet;
			END IF;
		END FOREACH;
		LET cCoderet = '00000';
	END IF;
END;

RETURN cCoderet;
END PROCEDURE
DOCUMENT
'AUTOR: 			Derian Alejandro Sainz Zazueta',
'DESCRIPCION: 		Se encarga de cancelar el servicio de Domiciliacion',
'FECHA: 			26/02/2022',
'MODIFICACION:    	Se realizo una modificacion en la cual se validara por tipo_domi, esto para evitar un mal funcionamiento debido al Incremental de Domiciliacion de Cuentas Propias a Cuentas Externas',
'EDITOR:            Derian Alejandro Sainz Zazueta',
'FECHA:           	23/09/2024',
'BD: 				BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consulta_autorizacioncliente_ob(pNumcte CHAR(20), p_sFolioActivacion CHAR(20), p_sUserStatus CHAR(8), p_sGenerico1 NVARCHAR(254), p_sGenerico2 NVARCHAR(254), p_sGenerico3 NVARCHAR(254), p_sGenerico4 NVARCHAR(254), p_sGenerico5 NVARCHAR(254))
	RETURNING CHAR(5) 		AS codRet,
			  CHAR(30) 		AS primerNombreClienteCargo,
			  CHAR(30) 		AS segundoNombreClienteCargo,
			  CHAR(30) 		AS primerApellidoClienteCargo,
			  CHAR(30) 		AS segundoApellidoClienteCargo,
			  CHAR(100) 	AS correo, 
			  CHAR(10) 		AS telefono, 
			  CHAR(13)  	AS RFC, -- RFC del cliente
			  CHAR(4) 		AS numProductoCargo, --Numero de producto quitar
			  CHAR(40) 		AS nomProductoCargo, --Nombre de producto Cargo quitar
			  CHAR(20) 		AS cuentaCargo, -- Cuenta cargo(DebitDeviceAccess) quitar
			  CHAR(20) 		AS clabeInterbancaria, --Clabe interbancaria quitar		  
			  CHAR(20) 		AS folioActivacion,--folio activacion
			  CHAR(20)		AS numeroTarjetaAbono, --Numero de Tarjeta abono 
			  CHAR(40)		AS nombreProductoAbono, --Nombre del producto abono
			  CHAR(30)  	AS nomCortoProductoAbono, --Nombre Corto de Producto Abono 
			  CHAR(40) 		AS descripcionBancoAbono, --Descripcion de banco abono
			  CHAR(10)		AS fechaPago,--fecha pago
			  CHAR(10)		AS fechaProximo,--fecha proximo pago
			  MONEY(16,2)	AS montoProximoPago, --monto proximo pago
			  MONEY(16,2)	AS montoMaximoDomiciliar, -- monto maximo a domiciliar
			  CHAR(2) 		AS periodicidad,--periodicidad
			  CHAR(2) 		AS tipoDomiciliacion, --tipoDomiciliacion
			  CHAR(3)		AS claveBancoCargo,
			  CHAR(2)		AS tipoCuentaCargo, 
			  CHAR(2)		AS tipoCuentaAbono,
			  CHAR(20)		AS cuentaAbono,
			  CHAR(20)		AS tarjetaCargo,
			  CHAR(100)		AS aliasDomiciliacion,
			  CHAR(2)		AS tipoPago,
			  MONEY(16,2) 	AS importePago,
			  CHAR(20)		AS rfcServicio,
			  CHAR(20)		AS userStatus,
			  CHAR(20)		AS userInsert,
			  CHAR(2)		AS claveCanal,
			  CHAR(100)		AS vGenerico1,
              CHAR(100)		AS vGenerico2,
              CHAR(100)		AS vGenerico3,
              CHAR(100)		AS vGenerico4,
			  CHAR(254)		AS vGenerico5,
			  CHAR(254)		AS vGenerico6,
			  CHAR(254)		AS vGenerico7,
			  CHAR(254)		AS vGenerico8,
			  CHAR(254)		AS vGenerico9;
			  			  
	--Declaracion de  Variables
	DEFINE sql_err 						INTEGER;
	DEFINE v_iContador 					INTEGER;	
	DEFINE v_cDataAux	                CHAR(100);	
			  
	DEFINE v_sCodRet					CHAR(5);
		
	DEFINE v_cPrimerNombreClienteCargo		CHAR(30);
	DEFINE v_cSegundoNombreClienteCargo		CHAR(30);
	DEFINE v_cPrimerApellidoClienteCargo	CHAR(30);
	DEFINE v_cSegundoApellidoClienteCargo	CHAR(30);
	DEFINE v_cCorreoElect				CHAR(100);
	DEFINE v_cNumTelefono				CHAR(10); 

   	DEFINE v_sNumProductoCargo			CHAR(4);	
   	DEFINE v_sNombreProductoCargo		CHAR(40);	
	DEFINE v_sCuentaCargo				CHAR(20);
	
	DEFINE v_sFolioActivacion			CHAR(20);
	DEFINE v_sNumeroTarjetaAbono		CHAR(20);
	DEFINE v_sNombreProductoAbono		CHAR(40);
	DEFINE v_sNombreCortoProductoAbono	CHAR(30);
	DEFINE v_sFechaPago					CHAR(10);
	DEFINE v_sFechaProximo				CHAR(10);
	DEFINE v_cRfc						CHAR(13);
	
	DEFINE v_mMontoMaximoDomiciliar		MONEY(16,2);

	DEFINE v_mMontoProximoPago			MONEY(16,2);
	--data return sp sp_domi_valida_cuentatarjeta
	DEFINE cClaveBancoAbono				CHAR(3);
	DEFINE v_sDescripcionBancoAbono		CHAR(40);

	DEFINE v_sNombreBancoAbono			CHAR(20);
	DEFINE v_sCuentaAbono				CHAR(20);
	DEFINE v_sClabeInterbancaria_ab 	CHAR(20);
	DEFINE v_sClabeInterbancaria_ca		CHAR(20);
	DEFINE v_sPeriodicidad				CHAR(2);
	DEFINE v_sTipoDomiciliacion			CHAR(2);
	DEFINE v_sClaveBancoCargo			CHAR(3);
	DEFINE ctipoCuentaCargo				CHAR(2);
	DEFINE ctipoCuentaAbono	            CHAR(2);
	DEFINE v_sCodRet2					CHAR(5);
	DEFINE cMensajeRespuesta 		    CHAR(110);
	DEFINE v_sTipoPago					CHAR(1);
	DEFINE v_sTarjetaCargo             	CHAR(20);
    DEFINE v_sAliasDomi                 CHAR(100);
	DEFINE v_mImportePago				MONEY(16,2);

	DEFINE v_sRfcServicio				CHAR(20);
	DEFINE v_sUserStatus				CHAR(20);
	DEFINE v_sUserInsert				CHAR(20);
	DEFINE v_sClaveCanal				CHAR(2);
	DEFINE v_sEstatusCtaCargoCecoban	CHAR(2);

	
    DEFINE v_Generico1                  CHAR(100);
    DEFINE v_Generico2                  CHAR(100);
    DEFINE v_Generico3                  CHAR(100);
    DEFINE v_Generico4                  CHAR(100);
	DEFINE v_Generico5                  CHAR(254);
	DEFINE v_Generico6                  CHAR(254);
	DEFINE v_Generico7                  CHAR(254);
	DEFINE v_Generico8                  CHAR(254);
	DEFINE v_Generico9                  CHAR(254);
	
	 			
	-- Inicializacion de variables			
	
	LET sql_err 					= 0;
	LET v_sCodRet 					= '00000';
	LET v_iContador					= 0;
	
	LET v_cPrimerNombreClienteCargo 		= '';
	LET v_cSegundoNombreClienteCargo 		= '';
	LET v_cPrimerApellidoClienteCargo 		= '';
	LET v_cSegundoApellidoClienteCargo 		= '';
	LET v_cCorreoElect				= '';
	LET v_cNumTelefono				= '';
	LET v_sNumProductoCargo 		= '';
	LET v_sNombreProductoCargo		= '';

	LET v_sCuentaCargo 				= '';
	LET v_sFolioActivacion			= '';	
	LET v_sNumeroTarjetaAbono		= '';
	LET v_sNombreProductoAbono 		= '';
	LET v_sNombreCortoProductoAbono	= '';
	LET v_sFechaPago				= '';
	LET v_sFechaProximo  			= '';
	LET v_cRfc  					= '';
	LET v_mMontoMaximoDomiciliar  	= 0.00;
	LET v_mMontoProximoPago 		= 0.00;
	--data return sp sp_domi_valida_cuentatarjeta
	LET cClaveBancoAbono			= '';
	LET v_sDescripcionBancoAbono	= '';	
	LET v_sNombreBancoAbono			= '';
	LET v_sCuentaAbono				= '';	
	LET v_sClabeInterbancaria_ab	= '';
	LET v_sClabeInterbancaria_ca 	= '';
	LET v_sPeriodicidad				= '';
	LET v_cDataAux 					= '';
	LET v_sTipoDomiciliacion		= '';
	LET v_sClaveBancoCargo			= '';
	LET ctipoCuentaCargo			= '';
	LET ctipoCuentaAbono			= '';
	LET v_sCodRet2					= '';
	LET cMensajeRespuesta			= '';
	LET v_sTipoPago					= '';
	LET v_sTarjetaCargo            	= '';
    LET v_sAliasDomi                = '';
	LET v_mImportePago				= '';
	LET v_sRfcServicio				= '';
	LET v_sUserStatus				= '';
	LET v_sUserInsert				= '';
	LET v_sClaveCanal				= '';
	LET v_sEstatusCtaCargoCecoban	= '';
	
    LET v_Generico1                 = '';
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	LET v_Generico5                 = '';
	LET v_Generico6                 = '';
	LET v_Generico7                 = '';
	LET v_Generico8                 = '';
	LET v_Generico9                 = '';
	
    --***************************************************************************************
    --SET DEBUG FILE TO "/home/e99806695/sp_domi_consulta_autorizacioncliente_ob.out";
	--TRACE ON;
	--***************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion), p_sUserStatus, CURRENT);
				
            	RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
			END IF;
		END EXCEPTION;
			
		IF NVL(pNumcte, '') = '' OR NVL(p_sFolioActivacion, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET v_sCodRet = '88827'; --ALGUN PARAMETRO DE ENTRADA REQUERIDO ESTE EN BLANCO.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;	
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
	--CONSULTAR LOS DATOS DEL CLIENTE
		SELECT TRIM(nombre1), TRIM(nombre2 ), TRIM(apell_paterno), TRIM(apell_materno), rfc
		INTO v_cPrimerNombreClienteCargo,v_cSegundoNombreClienteCargo,v_cPrimerApellidoClienteCargo,v_cSegundoApellidoClienteCargo,v_cRfc
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte AND empresa = '001';
			
		SELECT telefono
		INTO v_cNumTelefono
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = pNumcte
		AND status_tel = 'A'
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND tipo_tel = 2)
		AND tipo_tel = 2
		AND empresa = '001';
		
		SELECT correo_elec
		INTO v_cCorreoElect
		FROM bdinteg:"informix".si_correos
		WHERE numcte = pNumcte 
		AND tipo_correo = 1
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND tipo_correo = 1)
		AND status_correo = 'A'
		AND empresa = '001';
		
		IF 
			NVL((v_cPrimerNombreClienteCargo || v_cSegundoNombreClienteCargo || v_cPrimerApellidoClienteCargo || v_cSegundoApellidoClienteCargo),'') = '' 
			OR NVL(v_cNumTelefono,'') = '' 
			OR NVL(v_cCorreoElect,'') = ''  
			OR NVL(v_cRfc,'') = '' 
		THEN
			LET v_sCodRet = '88829'; -- No se encontro informacion del cliente.		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
						
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones d_aut 
						WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion AND d_aut.cve_estatus = '01' )
		THEN	
			LET v_sCodRet = '88828'; --EL CLIENTE NO CUENTA CON LA DOMICILIACION ACTIVA.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
            RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,'0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_Generico1,''),NVL(v_Generico2,''),NVL(v_Generico3,''),NVL(v_Generico4,''), NVL(v_Generico5,''), NVL(v_Generico6,''), NVL(v_Generico7,''), NVL(v_Generico8,''), NVL(v_Generico9,'');
		END IF;
	
		-- Datos domi.
		SELECT 
		  d_aut.cuenta, -- Cuenta abono.
		  d_aut.cuenta_cargo, --Cuenta cargo.
		  d_aut.folio_activacion --Folio activacion
		, TO_CHAR(f_pago.fecha_pago, '%Y-%m-%d') fecha_pago
		, TO_CHAR(f_pago.fecha_prox_pago, '%Y-%m-%d') fecha_prox_pago --Fecha proximo pago
		, d_aut.imp_maximo	--Importe maximo
		, f_pago.periodo
		, d_archivom.tipo_domi
		, d_aut.cve_domiciliar_tc
		, d_aut.alias_domi
		, d_aut.imp_fijo_tc  
		, d_aut.rfc
		, d_aut.user_estatus
		, d_aut.user_insert
		, d_aut.cve_canal
		, d_act_ob.estatus
		INTO 
		 v_sCuentaAbono,
		 v_sCuentaCargo,
		 v_sFolioActivacion,
		 v_sFechaPago,
		 v_sFechaProximo,
		 v_mMontoMaximoDomiciliar,
		 v_sPeriodicidad,
		 v_sTipoDomiciliacion,
		 v_sTipoPago,
		 v_sAliasDomi,
		 v_mImportePago,
		 v_sRfcServicio,
		 v_sUserStatus,
		 v_sUserInsert,
		 v_sClaveCanal,
		 v_sEstatusCtaCargoCecoban -- Estatus de verificacion de CECOBAN.
		FROM bdidomi:"informix".dom_autorizaciones d_aut
		INNER JOIN bdidomi:"informix".dom_cuentas_ob ctas_ob ON d_aut.cuenta_cargo = ctas_ob.num_tarjeta
		INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob d_act_ob ON d_act_ob.folio_activacion = d_aut.folio_activacion
		INNER JOIN bdidomi:"informix".dom_archivomanual d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion
		INNER JOIN bdidomi:"informix".dom_fecha_pago f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
		INNER JOIN bdidomi:"informix".dom_pago d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
		WHERE d_aut.num_cte = pNumcte AND d_aut.folio_activacion = p_sFolioActivacion
		AND d_aut.cve_estatus = '01' 
		GROUP BY d_aut.cuenta, d_aut.cuenta_cargo, d_aut.folio_activacion, f_pago.fecha_pago, f_pago.fecha_prox_pago, d_aut.imp_maximo
		, f_pago.periodo, d_archivom.tipo_domi, d_aut.cve_domiciliar_tc, d_aut.alias_domi, d_aut.imp_fijo_tc, d_aut.rfc, d_aut.user_estatus
		, d_aut.user_insert, d_aut.cve_canal, d_act_ob.estatus;
			
		-- Cuentas de credito.
		SELECT 
		  sd_def.nombre_prod --Nombre del producto abono
		, prod_tc.nombre_corto --Nombre corto del producto abono
		INTO 
		 v_sNombreProductoAbono,
		 v_sNombreCortoProductoAbono
		FROM bdicred:"informix".sd_maecred sd_mac 
		INNER JOIN bdicred:"informix".sd_definicion sd_def ON sd_def.num_producto = sd_mac.num_producto
		INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc prod_tc on sd_def.num_producto = prod_tc.cve_producto
		WHERE sd_mac.numcte = pNumcte 
		AND sd_mac.num_credito = v_sCuentaAbono
		GROUP BY sd_def.nombre_prod, prod_tc.nombre_corto;
	
		--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de cargo
		EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta_ob(v_sCuentaCargo, p_sUserStatus)
		INTO v_sCodRet, ctipoCuentaCargo, v_sClaveBancoCargo, v_cDataAux, v_cDataAux, v_sCuentaCargo, v_sTarjetaCargo, v_sClabeInterbancaria_ca;
			
		IF v_sCodRet = '00000' THEN
			--Obtener nombre y clave del banco, tipo de cuenta, cuuenta, tarjeta y ClabeInterbancaria de abono
			EXECUTE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(v_sCuentaAbono, p_sUserStatus)
			INTO v_sCodRet, ctipoCuentaAbono, cClaveBancoAbono, v_sDescripcionBancoAbono, v_sNombreBancoAbono, v_sCuentaAbono, v_sNumeroTarjetaAbono, v_sClabeInterbancaria_ab;
			
			IF v_sCodRet = '00000' THEN
				EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(v_sTipoPago, '001',v_sCuentaAbono,p_sUserStatus,p_sFolioActivacion, v_sTipoDomiciliacion)
				INTO v_sCodRet, v_mMontoProximoPago;
			END IF;
		END IF;
		
		IF v_sCodRet <> '00000' THEN
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_consulta_autorizacioncliente', trim(p_sFolioActivacion) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
		END IF;
		
		RETURN NVL(v_sCodRet,''),NVL(v_cPrimerNombreClienteCargo,''),NVL(v_cSegundoNombreClienteCargo,''),NVL(v_cPrimerApellidoClienteCargo,''),NVL(v_cSegundoApellidoClienteCargo,''), NVL(v_cCorreoElect,''),NVL(v_cNumTelefono,''),NVL(v_cRfc,''),NVL(v_sNumProductoCargo,''),NVL(v_sNombreProductoCargo,''),NVL(v_sCuentaCargo,''),NVL(v_sClabeInterbancaria_ca,''), NVL(v_sFolioActivacion,''),NVL(v_sNumeroTarjetaAbono,''),NVL(v_sNombreProductoAbono,''),NVL(v_sNombreCortoProductoAbono,''),NVL(v_sDescripcionBancoAbono,''), NVL(v_sFechaPago,''),NVL(v_sFechaProximo,''),NVL(v_mMontoProximoPago,''),NVL(v_mMontoMaximoDomiciliar,''), NVL(v_sPeriodicidad,''),NVL(v_sTipoDomiciliacion,''),NVL(v_sClaveBancoCargo,''), NVL(ctipoCuentaCargo,''),NVL(ctipoCuentaAbono,''),NVL(v_sCuentaAbono,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago,''), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_sTarjetaCargo,''), NVL(v_sAliasDomi,''), NVL(v_sTipoPago,''), NVL(v_mImportePago, '0.00'), NVL(v_sRfcServicio,''), NVL(v_sUserStatus,''), NVL(v_sUserInsert,''), NVL(v_sClaveCanal,''), NVL(v_sEstatusCtaCargoCecoban,'');
	END; 
END PROCEDURE;