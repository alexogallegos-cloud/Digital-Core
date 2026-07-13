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