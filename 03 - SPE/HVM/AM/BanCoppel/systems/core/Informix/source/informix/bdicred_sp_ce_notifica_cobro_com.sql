CREATE PROCEDURE "informix".sp_ce_notifica_cobro_com(
v_nombre_cliente		CHAR(150), 		-- Nombre_Cliente / Razon_social, 
v_correo_cliente		CHAR(100),		-- Correo_Cliente, 
v_correo_alterno		CHAR(100),		-- Correo_alterno_cliente, 
v_correo_area_interna	CHAR(100),		-- Correo_Área_Interna, 
v_numero_linea			CHAR(20),		-- Número_Línea, 
v_tipo_comision			CHAR(80),		-- Tipo_Comision, 
v_monto_comision 		MONEY(14,2),	-- Monto_Comision, 
v_folio_comision		CHAR(20),		-- Folio_Comision, 
v_id_aplica_comision	CHAR(1),		-- ID_aplicacion (0 = No aplicado, 1 = Aplicado), 
v_id_tipo_notificacion	CHAR(1)			-- ID_tipo_notificacion (0 = Aplicacion Cobro, 1= Aviso Futuro cobro)
)

RETURNING CHAR(5);
-- 00000 -- Proceso exitoso / Parámetros correctos
-- 00001 -- No se ha informado / Vacio -- Nombre_Cliente / Razon_social
-- 00002 -- No se ha informado / Vacio -- Correo_Cliente / Vacio -- Correo_alterno_cliente / Vacio -- Correo_Área_Interna
-- 00003 -- No se ha informado / Vacio -- Número_Línea
-- 00004 -- No se ha informado / Vacio -- Tipo_Comision
-- 00005 -- No se ha informado / Vacio -- Monto_Comision
-- 00006 -- No se ha informado / Vacio -- Folio_Comision
-- 00007 -- No se ha informado / Vacio -- ID_aplicacion
-- 00008 -- No se ha informado / Vacio -- ID_tipo_notificacion
-- 00009 -- informado 1/ informado 1   -- ID_aplicacion/ ID_tipo_notificacion
    
    ------------------------------------------------------------------------------------------------->
    -- Objetivo: Sp Prueba para notificacion de aplicacion de comisiones crédito empresarial - Orion
    -- Autor: GGG
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------------------------->
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
    DEFINE vSqlErr 				INTEGER;
    DEFINE cCodRet  			CHAR (5);
	------ variables para plantilla
	DEFINE	v_pIdPlantilla		VARCHAR(12);
	DEFINE	v_pIdMsj			VARCHAR(10);
	DEFINE	v_pTipoMsj			VARCHAR(1);
	DEFINE	v_pNumclt			VARCHAR(20);
	DEFINE	v_pNumcta			VARCHAR(20);
	DEFINE	v_pNumTarjeta		VARCHAR(16);
	DEFINE	v_pTipoproc			VARCHAR(1);
	DEFINE	v_pcorreo_alterno	VARCHAR(100);
	DEFINE	v_pcelular_alterno	VARCHAR(10);
	DEFINE	v_pImporte1			MONEY (16,2);
	DEFINE	v_pImporte2			MONEY (16,2);
	DEFINE	v_pImporte3			MONEY (16,2);
	DEFINE	v_pImporte4			MONEY (16,2);
	DEFINE	v_pImporte5			MONEY (16,2);
	DEFINE	v_pfecha1			DATETIME YEAR TO FRACTION(3);
	DEFINE	v_pfecha2			DATETIME YEAR TO FRACTION(3);
	DEFINE 	v_status_envio		VARCHAR(5);
	
	DEFINE	v_pStr1				VARCHAR(30);
	DEFINE	v_pStr2				VARCHAR(30);
	DEFINE	v_pStr3				VARCHAR(30);
	DEFINE	v_pStr4				VARCHAR(30);
	DEFINE	v_pStr5				VARCHAR(150);
	DEFINE	v_pStr6				VARCHAR(100);
	DEFINE	v_pStr7				VARCHAR(60);
	DEFINE	v_pStr8				VARCHAR(60);
	DEFINE	v_pStr9				VARCHAR(15);
	DEFINE	v_pStr10			VARCHAR(100);		

	DEFINE	v_mensaje			VARCHAR(100);
	DEFINE	v_desc_CodRet		VARCHAR(100);
	DEFINE	v_aplica_cliente	INTEGER;
	DEFINE	v_aplica_interno	INTEGER;
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	LET v_pStr1				= '';
	LET v_pStr2				= '';
	LET v_pStr3				= '';
	LET v_pStr4				= '';
	LET v_pStr5				= '';
	LET v_pStr6				= '';
	LET v_pStr7				= '';
	LET v_pStr8				= '';
	LET v_pStr9				= '';
	LET v_pStr10			= '';
	
	LET v_aplica_cliente 	= 0;
	LET v_aplica_interno	= 0;
	LET v_status_envio		= '';
	LET v_pidplantilla		= '';
	
   -- Activar / Desactivar Debug   
   --SET DEBUG FILE TO "/informix/SD/sp_ce_notifica_cobro_com.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
--*****************************************************
-- INICIA PROCESO
--*****************************************************
    BEGIN

		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				let cCodRet = vSqlErr;
				--ROLLBACK WORK;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION DIRTY READ;

--*****************************************************
-- 	Validacion de parámetros de entrada
--*****************************************************
	
		IF (v_nombre_cliente IS NULL OR v_nombre_cliente = '') THEN
			LET cCodRet = '00001';
		END IF;
		IF ((v_correo_cliente IS NULL OR v_correo_cliente = '') AND (v_correo_alterno IS NULL OR v_correo_alterno = '') AND (v_correo_area_interna IS NULL OR v_correo_area_interna = '') ) THEN
			LET cCodRet = '00002';
		END IF;
		IF (v_numero_linea IS NULL OR v_numero_linea = '') THEN
			LET cCodRet = '00003';
		END IF;
		IF (v_tipo_comision IS NULL OR v_tipo_comision = '') THEN
			LET cCodRet = '00004';
		END IF;
		IF (v_monto_comision IS NULL OR v_monto_comision <= 0) THEN
			LET cCodRet = '00005';
		END IF
		IF (v_folio_comision IS NULL OR v_folio_comision = '') THEN
			LET cCodRet = '00006';
		END IF;
		IF (v_id_aplica_comision IS NULL OR v_id_aplica_comision = '' OR v_id_aplica_comision NOT IN (0,1)) THEN
			LET cCodRet = '00007';
		END IF;
		IF (v_id_tipo_notificacion IS NULL OR v_id_tipo_notificacion = '' OR v_id_tipo_notificacion NOT IN (0,1)) THEN
			LET cCodRet = '00008';
		END IF;
		IF (v_id_aplica_comision = 1 AND v_id_tipo_notificacion = 1) THEN
			LET cCodRet = '00009';
		END IF;
		
--*****************************************************
-- 	ACTIVA/INACTIVA LOG PARA VALIDAR EL PROCESO
--*****************************************************
		--SET DEBUG FILE TO "/informix/SD/sp_ce_notifica_cobro_com_ggg_"||cCodRet||"_"||TRIM(v_numero_linea)||"_"||TRIM(v_folio_comision)||".out";
		--TRACE ON;
		   
		IF (cCodRet = '00000') THEN
				------ llenado de variables de uso general en las notificaciones
				LET v_pIdMsj = 'CE_NOTIFY';
				LET v_pTipoMsj = 1;
				LET v_pNumclt = '000000000';
				LET v_pNumcta ='XXXXXXXXXXX';
				LET v_pNumTarjeta = '';
				LET v_pTipoproc = '1';
				LET v_pcelular_alterno = '';
				LET v_pImporte1 = 0;
				LET v_pImporte2 = 0;
				LET v_pImporte3 = 0;
				LET v_pImporte4 = 0;
				LET v_pImporte5 = 0;
				LET v_pfecha1 = '';
				LET v_pfecha2= '';
				
				LET v_pStr5 = TRIM(v_nombre_cliente);								-- Se asigna a la variable 5 el Nombre del cliente
				LET v_pStr1 = TRIM(v_numero_linea);									-- Se asigna a la variable 1 la Línea de crédito 
				LET v_pStr3 = REPLACE(REPLACE(REPLACE(TRIM(v_tipo_comision),'COMISION','COMISIÓN'),'CION','CIÓN'),'LINEA','LÍNEA');	-- Se asigna a la variable 3 el Comision por
				LET v_pStr2 = TRIM(TO_CHAR(v_monto_comision,'$###,###,###.##'));	-- Se asigna a la variable 2 el Monto de comision
				LET v_pStr9 = TRIM(TO_CHAR(TODAY, "%d/%m/%Y" ));					-- Se asigna a la variable 9 la Fecha notificacion
				LET v_pStr6 = '';												-- Se asigna a la variable 6 el 
				LET v_pStr8 = '';												-- Se asigna a la variable 8 el 
				LET v_pStr10 = '';												-- Se asigna a la variable 10 el 
					
			---- validacion de notificacion para aviso de comision por anualidad
			IF v_id_tipo_notificacion = 1 THEN --- AVISO
				LET v_pIdPlantilla = 'CE_NOTCOMANU';
			END IF;
			
			---- validacion de notificacion para cobro de comisiones
			IF v_id_tipo_notificacion = 0 THEN --- COBRO
				LET v_pIdPlantilla = 'CE_NOTCOMCOB';	
				LET v_pStr7 = v_folio_comision;									-- Se asigna a la variable 7 el folio de la comision		
				IF v_id_aplica_comision = 0 THEN 
						LET v_pStr4 = 'No Aplicado';
					ELSE
						LET v_pStr4 = 'Aplicado'; -- Se asigna a la variable 4 el estatus de aplicacion
				END IF;
			END IF;		
	
				-- Valida el envío de notificaciones CORREO CLIENTE
				IF (v_correo_cliente IS NOT NULL AND v_correo_cliente <> '') THEN 
						LET v_pcorreo_alterno = v_correo_cliente;
						--LET v_mensaje = 'Se envia correo CLIENTE / PRINCIPAL: '|| v_pcorreo_alterno;
						LET v_aplica_cliente = 1;
				END IF;
				IF (v_correo_alterno IS NOT NULL AND v_correo_alterno <> '') AND (v_aplica_cliente = 0)  THEN 
						LET v_pcorreo_alterno = v_correo_alterno;
						--LET v_mensaje = 'Se envia correo CLIENTE / ALTERNO: '|| v_pcorreo_alterno;
						LET v_aplica_cliente = 1;
				END IF;
				
				IF v_aplica_cliente = 1 AND v_id_tipo_notificacion = 1 THEN 
					LET v_mensaje = 'Se envia correo CLIENTE: '|| v_pcorreo_alterno;
					
						EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento
						(v_pTipoMsj, TRIM(v_pIdMsj), TRIM(v_pIdPlantilla), TRIM(v_pNumclt), TRIM(v_pNumcta),
						TRIM(v_pNumTarjeta), v_pTipoproc, v_pStr1, v_pStr2, v_pStr3,
						v_pStr4, v_pStr5, v_pStr6, v_pStr7, v_pStr8,
						v_pStr9, v_pStr10, v_pcorreo_alterno, v_pcelular_alterno, v_pImporte1,
						v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1,
						v_pfecha2)
						INTO v_status_envio;
					
					ELSE
						LET v_mensaje = 'NO Se envia correo CLIENTE';
				END IF;
				
				-- Valida el envío de notificaciones CORREO INTERNO
				IF (v_correo_area_interna IS NOT NULL AND v_correo_area_interna <> '') THEN
					LET v_pcorreo_alterno = v_correo_area_interna;
					--LET v_mensaje = 'Se envia correo ÁREA INTERNA: '|| v_pcorreo_alterno;
					LET v_aplica_interno = 1;
				END IF;	
					
				IF v_aplica_interno = 1 THEN 
					LET v_mensaje = 'Se envia correo ÁREA INTERNA: '|| v_pcorreo_alterno;
					
						EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento
						(v_pTipoMsj, TRIM(v_pIdMsj), TRIM(v_pIdPlantilla), TRIM(v_pNumclt), TRIM(v_pNumcta),
						TRIM(v_pNumTarjeta), v_pTipoproc, v_pStr1, v_pStr2, v_pStr3,
						v_pStr4, v_pStr5, v_pStr6, v_pStr7, v_pStr8,
						v_pStr9, v_pStr10, v_pcorreo_alterno, v_pcelular_alterno, v_pImporte1,
						v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1,
						v_pfecha2)
						INTO v_status_envio;
					
					ELSE
						LET v_mensaje = 'NO Se envia correo ÁREA INTERNA';
				END IF;
		END IF;

			--LET v_status_envio = v_status_envio;
			
			IF cCodRet = '00000' THEN
				LET v_desc_CodRet = 'Parametros correctos';
			END IF ;
			IF cCodRet = '00001' THEN
				LET v_desc_CodRet = 'Nombre_Cliente / Razon_social (No informado)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00002' THEN 
				LET v_desc_CodRet = 'Correo_Cliente / Correo_alterno_cliente / Correo_Area_Interna (Ninguno informado)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00003' THEN 
				LET v_desc_CodRet = 'Numero_Linea (No informado)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00004' THEN 
				LET v_desc_CodRet = 'Tipo_Comision (No informado)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00005' THEN 
				LET v_desc_CodRet = 'Monto_Comision (Monto incorrecto)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00006' THEN 
				LET v_desc_CodRet = 'Folio_Comision (No informado)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00007' THEN 
				LET v_desc_CodRet = 'ID_aplicacion (Valor no permitido)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00008' THEN 
				LET v_desc_CodRet = 'ID_tipo_notificacion (Valor no permitido)';
				LET v_status_envio = cCodRet;
			END IF ;
			IF cCodRet = '00009' THEN 
				LET v_desc_CodRet = 'ID_aplicacion/ ID_tipo_notificacion (Ambos informados)';
				LET v_status_envio = cCodRet;
			END IF ;
    		
			
			--*****************************************************
			-- inserta registro en historico
			--*****************************************************	
			INSERT INTO 'informix'.sd_ce_notifica_com 
			VALUES (
			CURRENT::datetime year to second,
			cCodRet,
			v_desc_CodRet,
			v_pIdPlantilla,
			v_nombre_cliente,
			v_correo_cliente,
			v_correo_alterno,
			v_correo_area_interna,
			v_numero_linea,
			v_tipo_comision,
			v_monto_comision,
			v_folio_comision,
			v_id_aplica_comision,
			v_id_tipo_notificacion,	
			v_status_envio			
			);
			
			LET cCodRet = LPAD (TRIM(cCodRet), 5, '0');
			RETURN cCodRet;
				
	END;
--*****************************************************
-- TERMINA PROCESO
--*****************************************************	
END PROCEDURE;