CREATE PROCEDURE "informix".sp_registra_notificacion2(
		p_folio char(11), p_cliente char(20), p_tel char(10), p_correo char(100), 
		p_ident_sms integer, p_ident_correo integer, p_canal char(12), 
		p_tipo_notificacion integer) 

RETURNING  CHAR(3) AS s_CodRetorno, INTEGER AS Error;

/* Variables Salida*/
DEFINE s_CodRet			CHAR(3);

/* Variables locales*/
DEFINE v_Asunto			VARCHAR(50);
DEFINE iSqlErr 			INTEGER;
--Variables para la bitï¿½cora
DEFINE v_pky_aclaracion INTEGER;
DEFINE v_id_area INTEGER;
DEFINE v_estatus_acl INTEGER;
DEFINE v_estatus_corp_analisis INTEGER;
DEFINE v_estatus_corp_general INTEGER;
DEFINE v_id_accion INTEGER;
DEFINE v_desc_bitacora VARCHAR(255);
DEFINE v_razon_envio VARCHAR(50);

/* Evita bloqueo de tabla*/
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

 /* Asignacion de valores */
LET s_CodRet            = '000';
LET v_Asunto 			= '';

LET v_pky_aclaracion = NULL;
LET v_id_area = NULL;
LET v_estatus_acl = NULL;
LET v_estatus_corp_analisis = NULL;
LET v_estatus_corp_general = NULL;
LET v_id_accion = NULL;
LET v_desc_bitacora = NULL;
LET v_razon_envio = NULL;
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET s_CodRet = '002';  
			RETURN s_CodRet, iSqlErr;
		END IF;
	END EXCEPTION;
	
	/*Genera la variable Asunto dependiendo el tipo de notificaciï¿½n*/
	IF (p_tipo_notificacion == 1) THEN
		LET v_Asunto = 'Alta Folio';
		LET v_razon_envio = 'por Alta de Folio desde ' || trim(p_canal);
	END IF; 
	LET v_Asunto = trim(v_Asunto) || ' ' || trim(p_canal);
	
	SELECT pky_aclaracion, fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general 
		INTO v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general 
	FROM acl_aclaracion
	WHERE folio_Csuac = p_folio;
	
	/*Se insertan las variables de la notificaciï¿½n en la Base de Datos*/
	INSERT INTO acl_notificacion_det (pky_notificacion_det, folio_csuac, telefono, correo, fecha_envio, envio_sms, envio_correo, asunto) 
		VALUES(notificacion_det_seq.nextval, p_folio, p_tel, p_correo, current, p_ident_sms, p_ident_correo, v_Asunto);
	
	/*Se registra en la bitácora el envío del SMS*/
	IF p_ident_sms = 1 THEN
		LET v_desc_bitacora = 'El mensaje de texto de notificación '|| trim(v_razon_envio) ||' fue enviado al Cliente con Éxito.';
		
		SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'notificacionSMSExitoso';
	ELSE
		LET v_desc_bitacora = 'El mensaje de texto de notificación '|| trim(v_razon_envio) ||' no pudo ser enviado al Cliente.';
		
		SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'notificacionSMSFallido';
	END IF;
	
	INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
	  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
	VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, current, p_folio, v_id_accion, 
	  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
	/*Se registra en la bitï¿½cora el envï¿½o del correo*/
	IF p_ident_correo = 1 THEN
		LET v_desc_bitacora = 'El correo electrónico de notificación '|| trim(v_razon_envio) ||' fue enviado al Cliente con Éxito.';
		
		SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'notificacionCorreoExitoso';
	ELSE
		LET v_desc_bitacora = 'El correo electrónico de notificación '|| trim(v_razon_envio) ||' no pudo ser enviado al Cliente.';
		
		SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'notificacionCorreoFallido';
	END IF;
	
	INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
	  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
	VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, current, p_folio, v_id_accion, 
	  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
	
	/*Retorno de valores sin error*/
	RETURN s_CodRet, 0; 
END;
END PROCEDURE
DOCUMENT
'Sp				:	sp_registra_notificacion',
'Sistema		:	Aclaraciones',
'AUTOR			:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 10 1029, RQM 06 723',
'FECHA			: 	MAYO 2019',
'VERSION		: 	2.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_secuencia_folio()
	RETURNING CHAR (5) AS secuenciaMax;  
	--DEFINICION DE VARIABLES--	    
	
	DEFINE secuenciaMax	CHAR(5);

    --INICIALIZACION DE LAS VARIABLES--
	
	LET secuenciaMax = '';

   	
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        
		--OBTENIENDO EL VALOR MAXIMO DE LA SECUENCIA
	
		SELECT "informix".SECUENCIA_FOLIO_CSUAC.nextval 
			INTO  secuenciaMax
		FROM systables WHERE tabid = 1;

		RETURN  secuenciaMax;	
    END
END PROCEDURE;