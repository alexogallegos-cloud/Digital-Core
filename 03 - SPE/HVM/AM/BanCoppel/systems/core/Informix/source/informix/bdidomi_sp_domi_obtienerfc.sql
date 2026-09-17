CREATE PROCEDURE "informix".sp_domi_obtienerfc(cRazonSocial CHAR(60), p_sUserStatus CHAR(8), pNumCuentaTarjetaCargo CHAR(20))
	RETURNING	CHAR  (5) AS codRet, --Codigo de Retorno
				CHAR (13) AS rfc;
--DECLARACION DE VARIABLES
	DEFINE sql_err        	 		INTEGER;
	DEFINE cCodret         			CHAR(5);
	DEFINE iFlag					SMALLINT;
	DEFINE cRfc						CHAR(13);
	DEFINE cCodret2						CHAR(5);
	DEFINE cMensajeRespuesta 			CHAR (110);
	
--Inicializar Variables
	LET sql_err            			= 0;
	LET cCodret            			= '00000';
	LET iFlag						= 0;
	LET cRfc						= '';
	LET cCodret2					= '';
	LET cMensajeRespuesta			= '';
	
	--*******************************************************************
 	--SET debug FILE TO "/tmp/sp_obtienerfc.out";
	--Trace ON;
	--*******************************************************************

	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_obtienerfc', trim(pNumCuentaTarjetaCargo), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cRfc; --Regresa Resultados
			END IF;
		END EXCEPTION;

		-- Se validan los parametros de entrada
		IF NVL(pNumCuentaTarjetaCargo, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '99928'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_obtienerfc', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cRfc; --Regresa Resultados
		END IF;
		
		IF cRazonSocial = '' OR cRazonSocial IS NULL THEN
			FOREACH
				
				SELECT {+INDEX(bdidomi:dom_cat_servicios idx_razon_social)} rfc 
				INTO cRfc
				FROM bdidomi:"informix".dom_cat_servicios
				WHERE convenio = 'S' 
				AND presentador = 'S' 
				AND layout_especial = 'S'

				LET iFlag = 0;
				
				IF cRfc <> '' THEN
					LET iFlag = 1;
				END IF
				
		
			END FOREACH;
		ELSE
			FOREACH
				
				SELECT {+INDEX(bdidomi:dom_cat_servicios idx_razon_social)} rfc 
				INTO cRfc
				FROM bdidomi:"informix".dom_cat_servicios
				WHERE UPPER(razon_social) = UPPER(cRazonSocial)

				LET iFlag = 0;
				
				IF cRfc <> '' THEN
					LET iFlag = 1;
				END IF
				
		
			END FOREACH;
		
		END IF;

		IF iFlag = 0 THEN
			LET cCodret = '99916'; --La razon social no existe
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_obtienerfc', trim(pNumCuentaTarjetaCargo) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
		END IF;
		
		RETURN cCodret, cRfc;

	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Edith Mendoza Barraza',
'DESCRIPCION: Se encarga de consultar el rfc de una razon social de domiciliacion',
'FECHA      : 03/01/2022',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_activaserviciosdomi (
	p_sFolioActivacion 	CHAR(20), 
	p_sAlias 			CHAR(50), 
	p_sCuenta 			CHAR(20),
	p_sRfcServicio 		CHAR(13), 
	p_sNumCte 			CHAR(20), 
	p_sCveCanal 		CHAR(2), 
	p_fImpMax 			MONEY(16,2), 
	p_sCveSucursal 		CHAR(4), 
	p_sCveStatus 		CHAR(2), 
	p_sUserStatus 		CHAR(8), 
	p_sCveCausa 		CHAR(2), 
	p_sUserInsert 		CHAR(8), 
	p_sTipoPago 		CHAR(1), 
	p_mImpPago 			MONEY(16,2), 
	p_sTipoCuentaCargo  CHAR(2), 
	p_sCuentaCargo 		CHAR(20),
	p_sCveBancoCargo 	CHAR(3)
)
	RETURNING CHAR(5)   AS codRet,
			  CHAR(100) AS vGenerico1,
              CHAR(100)	AS vGenerico2,
              CHAR(100)	AS vGenerico3,
              CHAR(100)	AS vGenerico4;
	
--Declaracion de  Variables
	DEFINE sql_err 				INTEGER;
	DEFINE sCodret 				CHAR(5);
	DEFINE dFechaHoy 			DATE;
	DEFINE dFechaInsert			DATE;
	DEFINE iNumRechazos			INTEGER;
	DEFINE v_sCveSucursal		CHAR(4);
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	
	DEFINE v_Generico1          CHAR(100);
    DEFINE v_Generico2          CHAR(100);
    DEFINE v_Generico3          CHAR(100);
    DEFINE v_Generico4          CHAR(100);
	
	--Inicializo Variables
	LET sql_err 			= 0;
	LET sCodret 			= "00000";	
	LET dFechaInsert  		= CURRENT::DATE;
	LET iNumRechazos		= 0;
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	
	LET v_Generico1                 = '';
    LET v_Generico2                 = '';
    LET v_Generico3                 = '';
    LET v_Generico4                 = '';
	
	--*******************************************************************
	--SET DEBUG FILE TO "/tmp/sp_ActivaDomiciliacion.out";
	--TRACE ON;
	--*******************************************************************
	
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;
					
				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sFolioActivacion), p_sUserInsert, CURRENT);
			
				RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
			END IF;
		END EXCEPTION;
		
		--Valida parametros de entrada
		 IF 
		 	NVL(p_sfolioActivacion,'') = '' OR NVL(p_sCuenta,'') = '' OR NVL(p_sRfcServicio,'') = '' OR NVL(p_sNumCte,'') = '' OR NVL(p_sCveCanal,'') = '' 
		 	OR NVL(p_fImpMax,'') = '' OR NVL(p_sCveSucursal,'')  = '' OR NVL(p_sCveStatus,'') = '' OR NVL(p_sUserStatus,'') = '' 
		 	OR NVL(p_sCveCausa,'') = '' OR NVL(p_sUserInsert,'') = '' OR NVL(p_sTipoPago,'') = '' OR NVL(p_sTipoCuentaCargo,'') = ''  OR NVL(p_sCuentaCargo,'') = '' OR NVL(p_sCveBancoCargo,'') = '' 
			OR NVL(p_mImpPago,'') = ''
		 THEN
			LET sCodret='99926'; --PARAMETROS DE ENTRADA ESTAN EN BLANCO.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
			
			RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Valida si el paymentType(cve_domiciliar_tc) existe en la tabla dom_cat_imptc.
		IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_cat_imptc WHERE cve_domiciliar_tc = p_sTipoPago ) THEN
		   LET sCodret='99918'; --El tipo de pago no existe.
		   
		   --Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
		   
		   RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Valida si el cliente  tiene dado de alta el servicio, que se envia en los parametros para darse de alta.
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE cuenta = p_sCuenta AND rfc = p_sRfcServicio AND num_cte = p_sNumCte AND cve_estatus = '01') then
		   LET sCodret='99917'; --El cliente ya esta dado de alta en el servicio de domiciliacion.
		   
		   --Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;
				
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_activaserviciosdomi', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);
		   
		   RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
	
		--Consultar clave de la sucursal.
		SELECT valor INTO v_sCveSucursal FROM bdidomi:"informix".dom_parametros WHERE cod_param = p_sCveSucursal;
		
		IF EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta AND rfc = p_sRfcServicio AND num_cte = p_sNumCte AND cve_estatus = '02') THEN
		--Insertar registro actual de dom_autorizaciones en historico 
			INSERT INTO bdidomi:"informix".dom_autorizaciones_hist(
				alias_domi, folio_activacion, cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, 
				cve_sucursal, cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, fecha_insert, 
				cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo
			) 
			SELECT {+INDEX(bdidomi:dom_autorizaciones idx_cuenta)} alias_domi, folio_activacion, cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, 
				cve_sucursal, cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, fecha_insert, 
				cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo
			FROM bdidomi:"informix".dom_autorizaciones
			WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta 
			AND rfc = p_sRfcServicio 
			AND num_cte = p_sNumCte;
			
		 --Actualizar registro de dom_autorizaciones
			UPDATE {+INDEX(bdidomi:dom_autorizaciones idx_cuenta)} bdidomi:"informix".dom_autorizaciones 
			SET cuenta = p_sCuenta, cve_canal = p_sCveCanal, imp_maximo = p_fImpMax, num_rechazos = iNumRechazos, cve_sucursal = v_sCveSucursal, 
			cve_estatus = p_sCveStatus, fecha_estatus = dFechaHoy, user_estatus = p_sUserStatus, cve_causa = p_sCveCausa, user_insert = p_sUserInsert,
			fecha_insert = dFechaInsert, cve_domiciliar_tc = p_sTipoPago, imp_fijo_tc = CASE WHEN p_sTipoPago = 'F' THEN p_mImpPago ELSE NULL END, 
			tipo_cuenta_cargo = p_sTipoCuentaCargo, cuenta_cargo = p_sCuentaCargo, cve_banco_cargo = p_sCveBancoCargo, folio_activacion = p_sFolioActivacion, alias_domi = p_sAlias
			WHERE SUBSTR(cuenta, 2, 16) = p_sCuenta 
			AND rfc = p_sRfcServicio 
			AND num_cte = p_sNumCte;
			
			
		   RETURN sCodret, v_Generico1,v_Generico2,v_Generico3,v_Generico4;
		END IF;
		
		--Almacena el sevicio a domiciliar al cliente.
		INSERT INTO bdidomi:"informix".dom_autorizaciones (
			cuenta, rfc, num_cte, cve_canal, imp_maximo, num_rechazos, cve_sucursal, 
			cve_estatus, fecha_estatus, user_estatus, cve_causa, user_insert, 
			fecha_insert, cve_domiciliar_tc, imp_fijo_tc, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo, folio_activacion, alias_domi
		)
		VALUES (
			p_sCuenta,p_sRfcServicio, p_sNumCte, p_sCveCanal, p_fImpMax, iNumRechazos, v_sCveSucursal, 
			p_sCveStatus, dFechaHoy, p_sUserStatus, p_sCveCausa, p_sUserInsert,
			dFechaInsert, p_sTipoPago, CASE WHEN p_sTipoPago = 'F' THEN p_mImpPago ELSE NULL END, p_sTipoCuentaCargo, p_sCuentaCargo, p_sCveBancoCargo, p_sFolioActivacion, p_sAlias
		);
			
		RETURN sCodret,
				v_Generico1,v_Generico2,v_Generico3,v_Generico4;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      	: Edith Mendoza Barraza',
'DESCRIPCION	: Se encarga de dar de alta al cliente en el servicio de Domiciliacion',
'FECHA      	: 27/12/2021',
'BD         	: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_consulta_parametros(p_sCodParam CHAR(200), p_sUserStatus CHAR(8), pNumCte CHAR(20))
RETURNING 	CHAR(5) 	AS retorno, 
			CHAR(2) 	AS codigo, 
			CHAR(50) 	AS descripcion, 
			CHAR(100)	AS valor,
			CHAR(100)	AS v_generico1,
			CHAR(100)	AS v_generico2,
			CHAR(100)	AS v_generico3,
			CHAR(100)	AS v_generico4;

	DEFINE v_sCveValor 			CHAR(100);
	DEFINE v_sDescripcion  		CHAR(50);
	DEFINE v_sCodRet 			CHAR(5);
	DEFINE sql_err 				INTEGER;
	DEFINE v_iPosicion			INTEGER;
	DEFINE v_sCodParam			CHAR(2);
	DEFINE iPosicionCadena		INTEGER;
	DEFINE cCodret2				CHAR(5);
	DEFINE cMensajeRespuesta 	CHAR (110);
	DEFINE v_generico1			CHAR (110);
	DEFINE v_generico2			CHAR (110);
	DEFINE v_generico3			CHAR (110);
	DEFINE v_generico4			CHAR (110);
	
	LET v_iPosicion			= 1;
	LET v_sCodParam			= '';
	LET iPosicionCadena		= 2;
	LET cCodret2			= '';
	LET cMensajeRespuesta	= '';
	LET v_generico1			= '';
	LET v_generico2			= '';
	LET v_generico3			= '';
	LET v_generico4			= '';

	--*******************************************************************
	 -- SET DEBUG FILE TO "/tmp/sp_domi_consulta_parametros.out";       	
	 -- TRACE ON;    
	--******************************************************************* 

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
					
				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_parametros', TRIM(pNumCte), p_sUserStatus, CURRENT);
			
				RETURN v_sCodRet,'','','', v_generico1, v_generico2, v_generico3, v_generico4;
			END IF;
		END EXCEPTION;
	
	-- Validar parametros de entrada.
		IF NVL(p_sUserStatus,'') = '' OR NVL(pNumCte,'') = '' THEN
			LET v_sCodRet = '99923'; --Problema con los parametros de entrada.
			
			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;
					
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_parametros', TRIM(p_sUserStatus) || ' - ' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN v_sCodRet, '','','', v_generico1, v_generico2, v_generico3, v_generico4;
		END IF; 

		IF NVL(p_sCodParam, '') = '' THEN
			LET p_sCodParam = NULL;
			FOREACH
				SELECT {+INDEX(dom_parametros idx_parametros)} cod_param,descripcion, valor
				INTO v_sCodParam, v_sDescripcion, v_sCveValor
				FROM bdidomi:"informix".dom_parametros

				LET v_sCodRet = '00000';

				RETURN v_sCodRet, v_sCodParam, v_sDescripcion, v_sCveValor, v_generico1, v_generico2, v_generico3, v_generico4 WITH RESUME;
			END FOREACH;
		ELSE
			WHILE v_iPosicion < LENGTH(TRIM(p_sCodParam))
				LET v_sCodParam = SUBSTR(p_sCodParam, v_iPosicion, iPosicionCadena); 
				
				SELECT descripcion, valor
				INTO v_sDescripcion, v_sCveValor
				FROM bdidomi:"informix".dom_parametros
				WHERE cod_param = v_sCodParam;
				
				IF(NVL(v_sCveValor, '') = '') THEN
					LET v_sCodRet = '99943';
					
					--Obtenemos los datos del error ocurrido.
					EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;
						
					--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
					INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_consulta_parametros', TRIM(pNumCte) || '-' || TRIM(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
				ELSE
					LET v_sCodRet = '00000';
				END IF;
				
				RETURN v_sCodRet,v_sCodParam, v_sDescripcion, v_sCveValor, v_generico1, v_generico2, v_generico3, v_generico4 WITH RESUME;
				
				LET iPosicionCadena = iPosicionCadena + 4;
				LET v_iPosicion = v_iPosicion + 4; 
			END WHILE;
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR      : Edith Mendoza ',
'DESCRIPCION: Obtiene un listado de parametros de la tabla dom_parametros',
'FECHA      : 19/04/2022',
'BD         : BDIDOMI';

create procedure "informix".sp_domi_createnotificacionacuse(pFolio char(20),pTipo char(1),pCliente char(20),pNombreCliente char(40),pApellidoCliente char(60),
                                                                    pCorreo char(100),pCelular char(10),pAccion char(4),pProducto char(80),pProductoCorto char(40),
                                                                    pCuentaCargo char(20),pCuentaAbono char(20),pImporte decimal(16,2),pFechaPago char(10),
                                                                    pFechaMes char(5),pUser char(8))
returning char(5) as cCodRet,
			CHAR(100)	AS v_generico1,
			CHAR(100)	AS v_generico2,
			CHAR(100)	AS v_generico3,
			CHAR(100)	AS v_generico4;
-- DECLARACION DE VARIABLES.
define iSqlerr       integer;
define cCodRet      char(5);
DEFINE v_generico1			CHAR (110);
DEFINE v_generico2			CHAR (110);
DEFINE v_generico3			CHAR (110);
DEFINE v_generico4			CHAR (110);

-- VALORES INICIALES.
let iSqlerr    =  0;
let cCodRet   = '00000';
LET v_generico1			= '';
LET v_generico2			= '';
LET v_generico3			= '';
LET v_generico4			= '';

-- *************************************************************
--SET DEBUG FILE TO "/tmp/sp_domi_createnotificacionacuse.out";
--TRACE ON;
-- *************************************************************

begin
	on exception set iSqlerr
		if iSqlerr <> 0 then
			let cCodRet = iSqlerr;
			return cCodRet, v_generico1, v_generico2, v_generico3, v_generico4;
		end if;
	end exception;
	set isolation to dirty read;
	insert into bdidomi:"informix".dom_bitacora_acuses(folio_activacion,tipo_notificacion,num_cliente,nombre_cliente,
	apellido_cliente,email_cliente,celular_cliente,accion,producto,producto_corto,cuenta_cargo,cuenta_abono,
	imp_maximo,fecha_pago,fecha_mes,fecha_insert,user_insert) 
	values(pFolio,pTipo,pCliente,pNombreCliente,pApellidoCliente,pCorreo,pCelular,pAccion,
	pProducto,pProductoCorto,pCuentaCargo,pCuentaAbono,pImporte,TO_DATE(pFechaPago,'%Y-%m-%d'),pFechaMes,today,pUser);
end;
return cCodRet, v_generico1, v_generico2, v_generico3, v_generico4;
end procedure;