CREATE PROCEDURE "informix".sp_acl_consulta_ciudad_estado_formobjeccion(pNumcte CHAR(9))
    RETURNING CHAR(5) AS codRet,
			  CHAR(70) AS desc_ciudad,
			  CHAR(70) AS desc_estado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;

	DEFINE cDesCiudad CHAR(50);
	DEFINE cDescEstado CHAR(50);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDesCiudad = '';
	LET cDescEstado = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDesCiudad, cDescEstado;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_consulta_ciudad_estado_formobjeccion.out';
		--TRACE ON;
		
		IF pNumcte = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDesCiudad, cDescEstado;
		END IF;
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT b.d_ciudad,c.nombre
        INTO cDesCiudad, cDescEstado
		FROM bdinteg:si_direcciones_actual a
		INNER JOIN bdinteg:si_ciudades b ON a.ciudad = b.ciudad AND a.pais = b.pais AND a.estado = b.estado
		INNER JOIN bdinteg:si_estados c ON a.estado = c.estado AND c.estado = b.estado
		WHERE numcte = pNumcte
		AND a.secuencia = (SELECT MAX(secuencia) 
	                  	   FROM bdinteg:si_direcciones_actual 
	                   	   WHERE numcte = pNumcte AND tipo_dir = '1');


		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "00017";                
         END IF;  

		RETURN cCodRet, cDesCiudad, cDescEstado;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA 02/10/2024',
'MODULO: ACLARACIONES',
'FUNCIONALIDAD: FORMATO DE OBJECIÃN',
'DESCRIPCION: SPL encargado de consultar el estado y ciudad que actualmente tiene el cliente registrado.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_consulta_perfil_usuario(pUsuario CHAR(9))
RETURNING CHAR(5)   AS codret,
          CHAR(100) AS nombre;

    DEFINE cCodret CHAR(5);
    DEFINE cNombre CHAR(100);
    DEFINE iSqlErr INTEGER;
    DEFINE iBandera INTEGER;

    LET cCodRet = '00000';
    LET cNombre = '';
    LET iSqlErr = 0;
    LET iBandera = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre;
		END EXCEPTION;

        IF pUsuario IS NULL OR pUsuario = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cNombre;
        END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_acl_consulta_perfil_usuario.out';
		--TRACE ON

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        --VALIDAMOS PRIMERO POR CAT
        
        SELECT 1
        INTO iBandera
        FROM bdiaclaracion:acl_usuario a
        INNER JOIN  bdiaclaracion:acl_perfil_usuario b  ON a.pky_usuario = b.fky_usuario
        INNER JOIN  bdiaclaracion:acl_perfil c ON c.pky_perfil = b.fky_id_perfil
        WHERE a.num_empleado = pUsuario
        AND   c.pky_perfil IN (117, 118, 119)
        AND  a.activo = 1;

        IF iBandera > 0  OR iBandera IS NOT NULL THEN
            LET cNombre = 'CAT_MENU';
            RETURN cCodRet, cNombre;    
        END IF;

        LET iBandera = 0;

        --VALIDAMOS POR SUCURSAL:
        SELECT 1
        INTO iBandera
        FROM bdinteg:si_ejecut eje
        INNER JOIN bdinteg:si_ptf sp ON eje.sucursal = sp.id_ptf and sp.tipo IN('I', 'S')--> Busca a nivel Administrativo
        INNER JOIN bdinteg:si_sucursales suc ON suc.sucursal = sp.id_ptf
        LEFT OUTER JOIN bdinteg:si_estados edo on sp.cve_estado = edo.estado
        WHERE eje.empresa = '001'
        AND eje.ejecutivo = pUsuario
        AND eje.password <> "BAJA"
        AND eje.sucursal <> '0800'
        AND eje.nombramiento IN ("GERENTE TITULAR", 'PROMOTOR')
        AND eje.ejecutivo not in (SELECT num_empleado 
                                          FROM bdiaclaracion:"informix".acl_usuario u 
                                          join bdiaclaracion:"informix".acl_perfil_usuario pu on (u.pky_usuario = pu.fky_usuario) where activo = '1');

        IF iBandera = 0 OR iBandera IS NULL THEN
            SELECT 1
            INTO iBandera
            FROM bdiaclaracion:acl_usuario a
            INNER JOIN  bdiaclaracion:acl_perfil_usuario b  ON a.pky_usuario = b.fky_usuario
            INNER JOIN  bdiaclaracion:acl_perfil c ON c.pky_perfil = b.fky_id_perfil
            WHERE a.num_empleado = pUsuario
            AND   c.pky_perfil IN (5,6)
            AND  a.activo = 1;
        END IF;
                
        IF iBandera > 0  OR iBandera IS NOT NULL THEN
            LET cNombre = 'CARGA_MENU_SUCURSAL';
            RETURN cCodRet, cNombre;    
        END IF;

        LET iBandera = 0;

        --VALIDAMOS POR COORPORATIVO
        SELECT 1
        INTO iBandera
        FROM bdiaclaracion:"informix".acl_usuario u 
        JOIN bdiaclaracion:"informix".acl_perfil_usuario pu on (u.pky_usuario = pu.fky_usuario) 
        WHERE activo = '1'
        AND num_empleado = pUsuario;

        IF iBandera > 0 OR iBandera IS NOT NULL THEN
            LET cNombre = 'CARGA_MENU_CORPORATIVO';
            RETURN cCodRet, cNombre;    
        END IF;
        
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "00017"; 
            RETURN cCodRet, cNombre;               
         END IF;  

         RETURN cCodRet, cNombre ;
                        
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 19/09/2024',
'FUNCIONALIDAD: ACLARACIONES',
'DESCRIPCION: Procedimiento que se encarga de consultar el perfil del usuario para validar si contiene los permisos para los perfiles CAT, Coorporativo y sucursal ',
'BD: bdiaclaracion';

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