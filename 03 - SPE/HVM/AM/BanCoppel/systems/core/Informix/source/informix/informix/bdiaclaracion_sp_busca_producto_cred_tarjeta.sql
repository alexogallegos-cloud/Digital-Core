CREATE PROCEDURE "informix".sp_busca_producto_cred_tarjeta(p_sNumeroTarjeta CHAR(20), p_sNumeroEmpresa CHAR(3))
    RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;

	-- Definicion de variables    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto     CHAR(60);
	DEFINE resultado_numeroCuenta       CHAR(30);
	DEFINE resultado_numeroTarjeta      CHAR(30);
	DEFINE iSqlErr                      INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
    -- Inicializacion de variables
    LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';
	
	--SET DEBUG FILE TO "/informix/resplogifx/tdccoppel/sp_busca_producto_cred_tarjeta.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
        ON EXCEPTION
            SET iSqlErr
           	IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto ='';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
          	END IF;
        END EXCEPTION;
		
        FOREACH
			SELECT bdicred:sd_definicion.num_producto,nombre_prod, num_credito, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicred:sd_maecred 
				LEFT JOIN bdicred:sd_definicion 
					ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa
					AND bdicred:sd_definicion.num_producto = bdicred:sd_maecred.num_producto) 
				LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
				LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				WHERE bdicred:sd_maecred.empresa = p_sNumeroEmpresa
				AND status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3')		--IFRS 
				AND intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;    
		END FOREACH;
		
        -- Agregado TDC COPPEL MASTER CARD JLM-20/09/2022-GIV
        FOREACH
			SELECT intercard:binproducto.codprodcta as numeroProducto, intercard:binproducto.desccodprodcta AS nombreProducto, intercard:tarjetacuenta.numcuenta AS cuentaProducto, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
            FROM intercard:tarjeta      
				LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				LEFT JOIN intercard:binproducto ON (intercard:binproducto.codproductotarjeta = intercard:tarjeta.codproductotarjeta)
			WHERE intercard:tarjeta.codstatustarjeta IN ('ACT','BLO','BLT','CAN','DAN','EXT','FAL','INA','ROB')
			AND intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta
			AND intercard:tarjeta.codproductotarjeta = '007'
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;    
		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de productos correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_buscarclientesportarjeta (p_sNumeroTarjeta CHAR(30))
    RETURNING CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	-- Definicion de variables     
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE cuenta_tarjeta				CHAR(30);
	DEFINE iSqlErr                     	INTEGER;
	
    -- Inicializacion de variables
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET cuenta_tarjeta = '';
	
	--SET DEBUG FILE TO "/informix/resplogifx/tdccoppel/sp_buscarclientesportarjeta.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
        ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
			END IF;
        END EXCEPTION;
        
		SELECT numcuenta
		INTO cuenta_tarjeta
		FROM intercard:tarjetacuenta
		WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta;
		
        IF (cuenta_tarjeta IS NULL)THEN
        
			SELECT cuenta_tf
			INTO cuenta_tarjeta
			FROM bditransfer:tf_maecte
			WHERE empresa = '001'
			AND bditransfer:tf_maecte.num_tarjeta = p_sNumeroTarjeta;
         
        END IF;
		
        FOREACH
			
            SELECT num_cte
            INTO resultado_numeroCliente
            FROM bdicheq:sc_maechq
            WHERE empresa = '001'
            AND cuenta = cuenta_tarjeta and status_cta in ('1','3','4','5','6','7')
            UNION
            SELECT numcte
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
            AND cuenta_tf = cuenta_tarjeta
            UNION
            SELECT num_cte
            FROM bdinvers:sv_maeinv
            WHERE empresa = '001'
            AND cuenta = cuenta_tarjeta
            UNION
            SELECT numcliente 		--JALM
            FROM intercard:tarjeta
			LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numcuenta = cuenta_tarjeta
            UNION
            SELECT numcte
            FROM bdicred:sd_maecred
            WHERE empresa = '001'
			AND num_credito = cuenta_tarjeta
			AND status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3') 		--IFRS 
           
        END FOREACH;
		
		IF (resultado_numeroCliente IS NULL) THEN
			LET resultado_numeroCliente = '';
        ELSE
            SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
            INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numeroCliente;
{
            IF (resultado_numeroCliente IS NULL) THEN
				
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				
            END IF;
}
        END IF;
		
        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
		
	END
END PROCEDURE
DOCUMENT 'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de clientes correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_cred(p_tipo CHAR(1),p_cuenta char(30),p_cliente integer)

    RETURNING char(50) AS valor_retorno_s;
    
    DEFINE iSqlErr      	        INTEGER;
    DEFINE cod_retorno              CHAR(5);
    DEFINE p_estatus_cuenta          CHAR(30);
    DEFINE fecha_alta_p             CHAR(30);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta    CHAR(30);
    DEFINE valor_retorno            CHAR(30);
	DEFINE v_cod_estatus_cuenta     CHAR(2);
	DEFINE v_cuenta_activa			CHAR(2);
	DEFINE vCveExistente			INTEGER;
	DEFINE vStatusCred				CHAR(2);
	DEFINE cCausa					CHAR(2);
	DEFINE bin_tdc_coppel_mc        CHAR(6);
	DEFINE v_num_tarjeta            CHAR(16);
   
    LET iSqlErr      	         = '';
    LET cod_retorno              = '000*';
    LET p_estatus_cuenta           = '';
    LET fecha_alta_p             = '';  
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
	LET v_cod_estatus_cuenta     = '';
	LET v_cuenta_activa          = 'AA';
	LET vCveExistente  			 = 0;
	LET vStatusCred    			 = '';
	LET cCausa		   			 = '';
	LET bin_tdc_coppel_mc		 = '';
	LET v_num_tarjeta            = '';
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;

       -- SET DEBUG FILE TO "/informix/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
       -- TRACE ON;
         /*CUENTA ACTIVA (ESTATUS) PARA CUENTAS DE CREDITO */
		 
		--JLM/GIV/14092022
		
		SELECT bin into bin_tdc_coppel_mc FROM  intercard:binproducto WHERE idbinproducto = 174; -- bin= 514014

		FOREACH
		select numtarjeta into v_num_tarjeta from intercard:"informix".tarjetacuenta where numcuenta = p_cuenta 
			IF SUBSTRING(v_num_tarjeta FROM 1 FOR 6) = bin_tdc_coppel_mc THEN
				SELECT valor into valor_retorno FROM  bdinteg:si_param_tdc_coppelmc WHERE empresa = '001' and codigo_parametro = 11; --VIGENTE NORMAL 
				RETURN trim(valor_retorno);
			END IF;
			
		END FOREACH;
        --JLM/GIV/14092022
		 
		 
          IF p_tipo=consulta_est_cta THEN 
			SELECT mcrd.status_cred, tc.descripcion FETCH INTO v_cod_estatus_cuenta, p_estatus_cuenta
			FROM bdicred:sd_maecred mcrd
				INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
            WHERE mcrd.numcte = p_cliente
                AND num_credito = p_cuenta;
			
			IF v_cod_estatus_cuenta = v_cuenta_activa THEN
				SELECT NVL(id_unidad_prod, 0), status_Cred, cod_caract_2
					INTO vCveExistente, vStatusCred, cCausa
				FROM  bdicred:"informix".sd_maecred
					WHERE empresa = '001' 
					AND num_credito = p_cuenta;
				
				IF (vCveExistente = 0 AND cCausa IS NOT NULL) OR (vCveExistente > 0 AND cCausa IS NULL) THEN
					LET p_estatus_cuenta = 'BLOQUEADO';
					--LET cCodRet = '000008';
					--LET cMensajeRet = 'CrÃÂÃÂÃÂ©dito bloqueado manualmente favor de verificar'; 
				ELSE
					IF vCveExistente > 0 AND cCausa IS NOT NULL THEN
						LET p_estatus_cuenta = 'BLOQUEADO';
						--LET cCodRet = '000009';
						--LET cMensajeRet = 'El crÃÂÃÂÃÂ©dito ya se encuentra bloqueado'; 
					END IF;
				END IF;
			END IF;

              LET valor_retorno = p_estatus_cuenta;
			  
          END IF;
          /*CUENTA ACTIVA(FECHA APERTURA) PARA CUENTAS DE CREDITO */
          IF p_tipo=consulta_est_fech_alta THEN 

            SELECT TO_CHAR(mcrd.fecha_apertura) FETCH INTO consulta_est_fech_alta  --mcrd.fecha_apertura
               FROM bdicred:sd_maecred mcrd
                 INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
               WHERE mcrd.numcte = p_cliente
                 AND num_credito = p_cuenta;


           LET  valor_retorno = consulta_est_fech_alta;
          END IF;
        
 
    RETURN trim(valor_retorno);

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_cred',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'MODIFICA       :   Jorge Alberto Lara Mendoza',
'                   Se integra nueva consulta para Credito Coppel Masterd Card.',
'FECHA          :   01/Septiembre/2022',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_hash()
		RETURNING CHAR(5) AS codret,
				CHAR (100) AS hash;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cHash CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cHash = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cHash;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_hash.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT hash
		INTO cHash
		FROM
		(SELECT FIRST 1 hash
		FROM acl_validacion_componente
		WHERE nombre LIKE '%AfectacionesInteractDAO%' ORDER BY fecha DESC);
        
		RETURN cCodRet, cHash;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 21/01/2023',
'MODULO: Regulatorio',
'FUNCIONALIDAD: Cambios Regulatorios',
'DESCRIPCION: Consulta el HASH para transacciones monetarias',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_bitacora_siem(pUsuario CHAR(8), pBandera CHAR(1), pActividad CHAR(50), pHASH CHAR(100), pIpOrigen CHAR(20), pIpDestino CHAR(20))
		RETURNING CHAR(5) AS codret,
				INTEGER AS total,
				DATETIME YEAR TO SECOND AS fecha;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dfecha DATETIME YEAR TO SECOND;
	DEFINE cPassAnt CHAR(100);
	DEFINE iTotCont INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dfecha = CURRENT;
	LET cPassAnt = '';
	LET iTotCont = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotCont, dfecha;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bitacora_siem.out';
		--TRACE ON;
		
		IF pUsuario = '' AND pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotCont, dfecha;
        END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			
			SELECT COUNT(*) INTO iTotCont FROM acl_bitacora_eventos_siem WHERE actividad = pActividad AND ejecutivo = pUsuario;
			
			SELECT MAX(fecha) INTO dfecha FROM acl_bitacora_eventos_siem WHERE actividad = pActividad AND ejecutivo = pUsuario;

		ELIF pBandera = '2' THEN
			INSERT INTO acl_bitacora_eventos_siem(fecha, ejecutivo, actividad, hash, ip_origen, ip_destino) 
			VALUES(CURRENT, pUsuario, pActividad, pHASH, pIpOrigen, pIpDestino);

        END IF;		
       
        RETURN cCodRet, iTotCont, NVL(dfecha, CURRENT);
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 26/09/2023',
'MODULO: Regulatorio',
'FUNCIONALIDAD: Cambio de Password',
'DESCRIPCION: SP encargado de insertar o consultar la bitacora de SIEM',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_validapassword(pUsuario CHAR(50), pPassword CHAR(100), pIpUsuario CHAR(16), pKeyEntro CHAR(255), pKeySalio CHAR(255))
	RETURNING CHAR(5) AS codret,
		INTEGER AS sql_error,
		CHAR(1) AS status,
		CHAR(45) AS nombre,
		CHAR(50) AS puesto,
		INTEGER AS area,
		CHAR(1) AS en_sesion;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cPkeyUsuario INTEGER;
	DEFINE cNombre CHAR(45);
	DEFINE cPuesto CHAR(50);
	DEFINE iArea INTEGER;
	DEFINE cStatus CHAR(1);
	DEFINE cKey CHAR(255);
	DEFINE cEnSesion CHAR(1);
	DEFINE iNumRegistros INTEGER;
	DEFINE cIp CHAR(16);
	DEFINE iPid INTEGER;
	DEFINE cValidaClave CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cPkeyUsuario = '';
	LET cNombre = '';
	LET cPuesto = '';
	LET iArea = 0;
	LET cStatus = '';
	LET cKey = '';
	LET cEnSesion = '';
	LET iNumRegistros = 0;
	LET cIp = '';
	LET iPid = DBINFO('sessionid');
	LET cValidaClave = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = '002';
				RETURN cCodRet,iSqlErr,cStatus,cNombre,cPuesto,iArea,cEnSesion;	
			END IF;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validapassword.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT clave 
		INTO cValidaClave
		FROM "informix".acl_usuario 
		WHERE num_empleado = pUsuario;
		
		IF cValidaClave = '' OR cValidaClave IS NULL THEN
			LET cCodRet = '90000'; --EL USUARIO NO EXISTE
			RETURN cCodRet,iSqlErr,cStatus,cNombre,cPuesto,iArea,cEnSesion;
		ELSE
			LET cValidaClave = TRIM(cValidaClave);
			LET pPassword = TRIM(pPassword);
			IF cValidaClave <> pPassword THEN
				LET cCodRet = '90001'; --EL PASSWORD ES INCORRECTO
				RETURN cCodRet,iSqlErr,cStatus,cNombre,cPuesto,iArea,cEnSesion;
			END IF;
		END IF;
		
		SELECT pky_usuario,nombre,puesto,fky_area 
		INTO cPkeyUsuario,cNombre,cPuesto,iArea
		FROM "informix".acl_usuario 
		WHERE num_empleado = TRIM(pUsuario) AND clave = TRIM(pPassword) AND activo = 1;
		
		IF DBINFO('sqlca.sqlerrd2') = 1 THEN
		
			LET cStatus = 'A'; --Us. Activo
			
			FOREACH
				SELECT FIRST 1 pky_sesion_usuario
				INTO cKey
				FROM "informix".acl_sesion_usuario
				WHERE numero_empleado = pUsuario
			END FOREACH;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
			
				INSERT INTO informix.acl_sesion_usuario(pky_sesion_usuario, numero_empleado, ip_usuario)
				VALUES(sesion_usuario_seq.NEXTVAL, pUsuario, pIpUsuario);
				
				LET cEnSesion = 'f';
				
			ELSE
			
				FOREACH
					SELECT FIRST 1 pky_sesion_usuario 
					INTO cKey
					FROM "informix".acl_sesion_usuario 
					WHERE numero_empleado = pUsuario AND ip_usuario = pIpUsuario
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					LET cEnSesion = 'f';
				ELSE
					LET cEnSesion = 't';
				END IF;
			END IF; 			
			
		ELSE
			LET cStatus = 'I'; --Us. Inactivo
		END IF;
		
		RETURN cCodRet,iSqlErr,cStatus,cNombre,cPuesto,iArea,cEnSesion;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 20/07/2018',
'SISTEMA: ACLARACIONES',
'FUNCIONALIDAD: CENTRO DE ATENCIÃÂN TELEFÃÂNICA (CAT)',
'DESCRIPCION: SPL encargado de la validaciÃÂ³n del usuario por contraseÃÂ±a.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_change_password(pUsuario CHAR(8), pBandera CHAR(1), pPassword CHAR(100))
		RETURNING CHAR(5) AS codret,
				DATE AS fechaUltimoCambio,
				CHAR (100) AS password;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cfechaUltimoCambio DATE;
	DEFINE cPassAnt CHAR(100);
	DEFINE iTotCont INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cfechaUltimoCambio = CURRENT;
	LET cPassAnt = '';
	LET iTotCont = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cfechaUltimoCambio, cPassAnt;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_change_password.out';
		--TRACE ON;
		
		IF pUsuario = '' AND pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cfechaUltimoCambio, cPassAnt;
        END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
		
			SELECT COUNT(*) 
			INTO iTotCont 
			FROM (SELECT * 
					FROM (SELECT FIRST 24 * 
					FROM acl_bitacora_cambio_pass 
					WHERE usuario_insert = pUsuario
					ORDER BY fecha_hora DESC) WHERE password = pPassword);
			
			IF iTotCont = 0 THEN
			
				SELECT clave
				INTO cPassAnt
				FROM acl_usuario 
				WHERE num_empleado = pUsuario;
				
				INSERT INTO acl_bitacora_cambio_pass (password, fecha_hora, usuario_insert, enc_aes) 
				VALUES (cPassAnt, CURRENT, pUsuario, 'T');
			ELSE
				LET cCodRet = '99999';
			END IF;
		ELIF pBandera = '2' THEN
		
		
			SELECT clave
			INTO cPassAnt
			FROM acl_usuario 
			WHERE num_empleado = pUsuario;
			
			IF cPassAnt IS NULL THEN
				LET cfechaUltimoCambio = (TODAY-1) ;
				RETURN cCodRet, cfechaUltimoCambio, '';
			END IF;
			
			SELECT COUNT(*) 
			INTO iTotCont 
			FROM acl_bitacora_cambio_pass 
			WHERE usuario_insert = pUsuario;
			
			IF iTotCont = 0 THEN
				INSERT INTO acl_bitacora_cambio_pass (password, fecha_hora, usuario_insert, enc_aes) 
				VALUES (cPassAnt, CURRENT, pUsuario, 'F');
			ELSE 
				SELECT MAX(fecha_hora)
				INTO cfechaUltimoCambio
				FROM acl_bitacora_cambio_pass 
				WHERE usuario_insert = pUsuario;
			END IF;
		
		ELIF pBandera = '3' THEN
		
			SELECT COUNT(*) 
			INTO iTotCont 
			FROM (SELECT * 
					FROM (SELECT FIRST 24 * 
					FROM acl_bitacora_cambio_pass 
					WHERE usuario_insert = pUsuario
					ORDER BY fecha_hora DESC) WHERE password = pPassword);
			
			IF iTotCont = 0 THEN
			
				SELECT clave
				INTO cPassAnt
				FROM acl_usuario 
				WHERE num_empleado = pUsuario;
				
				UPDATE acl_usuario SET clave = pPassword WHERE num_empleado = pUsuario;
				
				INSERT INTO acl_bitacora_cambio_pass (password, fecha_hora, usuario_insert, enc_aes) 
				VALUES (cPassAnt, CURRENT, pUsuario, 'T');
			ELSE
				LET cCodRet = '99999';
			END IF;
			
		
        END IF;		
       
        RETURN cCodRet, cfechaUltimoCambio, cPassAnt;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 13/07/2023',
'MODULO: Regulatorio',
'FUNCIONALIDAD: Cambio de Password',
'DESCRIPCION: SP encargado de cambiar el password y consultar el ultimo cambio de password',
'BD: bdiaclaracion'                                                                                                              
;

CREATE PROCEDURE "informix".sp_acl_busca_datos_3410_fda(pFolioCsuac CHAR(11))
	RETURNING
		CHAR(5)				            AS cod_ret,
		CHAR(16)			            AS tarjeta,
		SMALLINT			            AS procede_abono_tmp,
		SMALLINT			            AS es_diferencia_importes,
		SMALLINT			            AS es_tarjeta_presente,
		CHAR(2)				            AS modo_entrada,
		SMALLINT			            AS es_chip_mas_nip,
		SMALLINT			            AS es_fda_exitoso,
		CHAR(2)				            AS cod_primer_fda,
		CHAR(2)				            AS cod_segundo_fda,
		CHAR(75)			            AS desc_primer_fda,
		CHAR(75)			            AS desc_segundo_fda,
		CHAR(255)			            AS dictamen_noprocede,
	   	CHAR(6)							AS num_autorizacion,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cargo,
		CHAR(30)						AS estatus_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cancelacion_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_movimiento,
		MONEY							AS importe_reclamado,
		CHAR(40)						AS comercio,
		CHAR(40)						AS receptor,
		CHAR(55)						AS banco_adquirente,
		CHAR(15)						AS ip,
		CHAR(85)						AS dato_no_convencional,
		INTEGER				            AS clave_origen,
		CHAR(1) 						AS valor_subcampo6,
		CHAR(1) 						AS valor_subcampo9,
		CHAR(1) 						AS valor_subcampo12,
		CHAR(2) 						AS valor_subcampo4,
		CHAR(2) 						AS valor_subcampo5,
		CHAR(2) 						AS valor_subcampo7,
		CHAR(2) 						AS valor_subcampo8,
		CHAR(2) 						AS valor_subcampo10,
		CHAR(2) 						AS valor_subcampo11,
		CHAR(22) 						AS valor_tokenC4,
		CHAR(6)							AS tokenB3_sub8,
	    DATETIME YEAR TO FRACTION(5)    AS fecha_alta_NIP,
	    SMALLINT						AS es_comercio_seguro,
		SMALLINT						AS tiene_cvv2dinamico,
		DATETIME YEAR TO FRACTION(5)    AS fecha_alta_cvv2din,
	    CHAR(4)							AS cvv2_dinamico;
        

    --Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
    DEFINE v_num_tarjeta				CHAR(16);
    DEFINE v_procede_abono_tmp			SMALLINT;
    DEFINE v_es_diferencia_importes		SMALLINT;
    DEFINE v_es_tarjeta_presente		SMALLINT;
    DEFINE v_modo_entrada				CHAR(2);
    DEFINE es_chip_mas_nip			    SMALLINT;
    DEFINE es_fda_exitoso			    SMALLINT;
    DEFINE c_cod_primer_fda			    CHAR(2);
    DEFINE c_cod_segundo_fda			    CHAR(2);
    DEFINE c_desc_primer_fda			    CHAR(50);
    DEFINE c_desc_segundo_fda			    CHAR(50);
    DEFINE c_dictamen_noprocede    	    CHAR(255);
    DEFINE v_num_autorizacion			CHAR(6);
    DEFINE v_fecha_movimiento_libe		DATETIME YEAR TO FRACTION(5);
    DEFINE v_desc_estatus_tarjeta		CHAR(30);
    DEFINE v_fecha_reporte_tarjeta		DATETIME YEAR TO FRACTION(5);
    DEFINE v_fecha_movimiento			DATETIME YEAR TO FRACTION(5);
    DEFINE v_importereclamado			MONEY;
    DEFINE v_comercio					CHAR(40);
    DEFINE v_receptor					CHAR(40);
    DEFINE c_banco_adquirente             CHAR(55);
    DEFINE c_ip						    CHAR(15);
    DEFINE c_dato_no_convencional		    CHAR(85);
    DEFINE v_evento						INTEGER;
    DEFINE valor_subcampo6 			    CHAR(1);
    DEFINE valor_subcampo9 			    CHAR(1);
    DEFINE valor_subcampo12 		    CHAR(1);
    DEFINE valor_subcampo4 			    CHAR(2);
    DEFINE valor_subcampo5 			    CHAR(2);
    DEFINE valor_subcampo7 			    CHAR(2);
    DEFINE valor_subcampo8			    CHAR(2);
    DEFINE valor_subcampo10 		    CHAR(2);
    DEFINE valor_subcampo11 		    CHAR(2);
    DEFINE v_token_c4					CHAR(22);
    DEFINE tokenB3_sub8 			    CHAR(6);
    DEFINE fecha_alta_NIP				DATETIME YEAR TO FRACTION(5);
    DEFINE es_comercio_seguro		    SMALLINT;
    DEFINE tiene_cvv2dinamico		    SMALLINT;
    DEFINE fecha_alta_cvv2din			DATETIME YEAR TO FRACTION(5);
    DEFINE cvv2_dinamico 			    CHAR(4);
    DEFINE vDictamenEstatusCorp         INTEGER;
    DEFINE icontador                    INTEGER;

    LET v_cod_ret 						= "00000";
    LET sql_err                         = 0;
    LET v_num_tarjeta                   = null; 
    LET v_procede_abono_tmp             = 0; 
    LET v_es_diferencia_importes        = 0; 
    LET v_es_tarjeta_presente           = 0; 
    LET v_modo_entrada                  = null; 
    LET es_chip_mas_nip                 = 0; 
    LET es_fda_exitoso = 0; 
    LET c_cod_primer_fda = null; 
    LET c_cod_segundo_fda = null; 
    LET c_desc_primer_fda = null; 
    LET c_desc_segundo_fda = null; 
    LET c_dictamen_noprocede = null; 
    LET v_num_autorizacion = null; 
    LET v_fecha_movimiento_libe = null; 
    LET v_desc_estatus_tarjeta = null; 
    LET v_fecha_reporte_tarjeta = null; 
    LET v_fecha_movimiento = null; 
    LET v_importereclamado = null; 
    LET v_comercio = null; 
    LET v_receptor = null; 
    LET c_banco_adquirente = null; 
    LET c_ip = null; 
    LET c_dato_no_convencional = null; 
    LET v_evento = 0; 
    LET valor_subcampo6 = null; 
    LET valor_subcampo9 = null; 
    LET valor_subcampo12 = null; 
    LET valor_subcampo4 = null; 
    LET valor_subcampo5 = null; 
    LET valor_subcampo7 = null; 
    LET valor_subcampo8 = null; 
    LET valor_subcampo10 = null; 
    LET valor_subcampo11 = null; 
    LET v_token_c4 = null; 
    LET tokenB3_sub8 = null; 
    LET fecha_alta_NIP = null; 
    LET es_comercio_seguro = 0; 
    LET tiene_cvv2dinamico = 0; 
    LET fecha_alta_cvv2din = null; 
    LET cvv2_dinamico = null;
    LET vDictamenEstatusCorp = 0;
    LET icontador = 0;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN

        ON EXCEPTION SET sql_err
        IF sql_err  != 0 THEN
            LET v_cod_ret = sql_err ;
			        RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,c_cod_primer_fda, c_cod_segundo_fda,c_desc_primer_fda,c_desc_segundo_fda,TRIM(c_dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, c_banco_adquirente, c_ip,
                            c_dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
            END IF;
        END EXCEPTION;	

        --SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_acl_busca_datos_3410_fda_' || pFolioCsuac || '.out';
   	  --  TRACE ON;

        SELECT COUNT(*) INTO icontador 
        FROM bdiaclaracion@stag_ids1170:acl_busca_datos_3410_temp
        WHERE foliosuac = pFolioCsuac;

        IF icontador > 0 THEN 
            SELECT FIRST 1 tarjeta, procede_abono_tmp, es_diferencia_importes, es_tarjeta_presente, modo_entrada, es_chip_mas_nip, es_fda_exitoso, cod_primer_fda, cod_segundo_fda, desc_primer_fda, desc_segundo_fda, dictamen_noprocede, num_autorizacion, fecha_cargo, estatus_tarjeta, fecha_cancelacion_tarjeta, fecha_movimiento, importe_reclamado, comercio, receptor, banco_adquirente, ip, dato_no_convencional, clave_origen, 
                  valor_subcampo6, valor_subcampo9, valor_subcampo12, valor_subcampo4, valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, valor_tokenc4, tokenb3_sub8, fecha_alta_nip, es_comercio_seguro, tiene_cvv2dinamico, fecha_alta_cvv2din, cvv2_dinamico
	        INTO  v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,c_cod_primer_fda,c_cod_segundo_fda,c_desc_primer_fda,c_desc_segundo_fda,c_dictamen_noprocede, 
             v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta,v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, c_banco_adquirente, c_ip, c_dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,
             valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico
            FROM bdiaclaracion@stag_ids1170:"informix".acl_busca_datos_3410_temp
            WHERE foliosuac = pFolioCsuac;
        ELIF icontador = 0 THEN
        
            DELETE bdiaclaracion@stag_ids1170:"informix".acl_busca_datos_3410_temp WHERE foliosuac = pFolioCsuac;

            EXECUTE PROCEDURE bdiaclaracion:"informix".sp_busca_datos_3410_fda(pFolioCsuac)
             INTO v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes,
             v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,c_cod_primer_fda, 
             c_cod_segundo_fda,c_desc_primer_fda,c_desc_segundo_fda,c_dictamen_noprocede, 
             v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, 
             v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, c_banco_adquirente, c_ip,
             c_dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,
             valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, 
             valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
             tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

            INSERT INTO bdiaclaracion@stag_ids1170:"informix".acl_busca_datos_3410_temp(tarjeta, procede_abono_tmp, es_diferencia_importes, es_tarjeta_presente, modo_entrada, es_chip_mas_nip, es_fda_exitoso, cod_primer_fda, cod_segundo_fda, desc_primer_fda, desc_segundo_fda, dictamen_noprocede, num_autorizacion, 
                fecha_cargo, estatus_tarjeta, fecha_cancelacion_tarjeta, fecha_movimiento, importe_reclamado, comercio, receptor, banco_adquirente, ip, dato_no_convencional, clave_origen, valor_subcampo6, valor_subcampo9, valor_subcampo12, valor_subcampo4, valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, valor_tokenc4, tokenb3_sub8, fecha_alta_nip, es_comercio_seguro, tiene_cvv2dinamico, fecha_alta_cvv2din, cvv2_dinamico, foliosuac) 
	        VALUES(v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,c_cod_primer_fda, c_cod_segundo_fda,c_desc_primer_fda,c_desc_segundo_fda,c_dictamen_noprocede, 
              v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, c_banco_adquirente, c_ip, c_dato_no_convencional, v_evento, valor_subcampo6, 
              valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, pFolioCsuac);
              
            END IF;
    
        RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,c_cod_primer_fda, c_cod_segundo_fda,c_desc_primer_fda,c_desc_segundo_fda,TRIM(c_dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, c_banco_adquirente, c_ip,
         c_dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
    END
END PROCEDURE

DOCUMENT 
'AUTOR: José Antonio Ramírez Franco',
'FECHA: 02/10/2023',
'DESCRIPCION: SP encargado de consultar al SP sp_busca_datos_3410_dfa',
'BD:bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_consultadevolucion(pFolio_csuac CHAR(16))
RETURNING CHAR(5)     AS codret, 
          MONEY(16,2) AS monto,
          DATE        AS fecha,
          SMALLINT    AS procede,
          SMALLINT    AS devolucion;
    
    DEFINE cCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
    DEFINE v_montoDevo MONEY(16,2);
    DEFINE v_fecha     DATE;
    DEFINE v_procede   SMALLINT;
    DEFINE v_tarjeta   CHAR(16);
    DEFINE v_devo      SMALLINT;
	DEFINE vImporteReclamado	MONEY;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET v_montoDevo    = NULL;
    LET v_fecha        = NULL;
    LET v_procede      = NULL;
    LET v_tarjeta      = NULL;
    LET v_devo         = 0;
	LET vImporteReclamado	= 0.00;



    BEGIN

         ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_montoDevo, v_fecha, v_procede, v_devo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_acl_consultadevolucion.out';
		--TRACE ON;

        IF pFolio_csuac = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, v_montoDevo, v_fecha, v_procede, v_devo;
        END IF;

        
        SELECT MIN(fechahora) INTO v_fecha
        FROM bdiaclaracion@stag_ids1170:acl_movimiento WHERE folio_csuac = pFolio_csuac;
        

        IF v_fecha IS NULL THEN
            LET cCodRet = '00017';
            RETURN cCodRet, v_montoDevo, v_fecha, v_procede, v_devo;
        END IF;

        SELECT LIMIT 1 v_num_tarjeta
        INTO v_tarjeta
        FROM bdiaclaracion@stag_ids1170:acl_bitacora_fda_3410
        WHERE folio_csuac = pFolio_csuac;

        IF v_tarjeta IS NULL THEN
            LET cCodRet = '00017';
            RETURN cCodRet, v_montoDevo, v_fecha, v_procede, v_devo;
        END IF

        SELECT procede, importereclamado INTO v_procede, vImporteReclamado
        FROM bdiaclaracion@stag_ids1170:acl_aclaracion 
        WHERE folio_csuac = pFolio_csuac;
       
        SELECT {+AVOID_FULL ('informix'.td_movimientos_conciliacion)}
		(monto325/100) AS monto325
		INTO v_montoDevo
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE tipotransaccion325 = '21'
		AND fechacarga >= v_fecha
		AND numtarjeta = TRIM(v_tarjeta)
		AND (monto325/100) = vImporteReclamado
		GROUP BY monto325;

        IF v_montoDevo IS NOT NULL THEN
            LET v_devo = 1;
        ELSE
            LET v_fecha = NULL;
        END IF

        RETURN cCodRet, v_montoDevo, v_fecha, v_procede, v_devo;

    END
END PROCEDURE

DOCUMENT 
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA:21/11/2023',
'FUNCIONALIDAD: Aclaraciones',
'DESCRIPCION: SP que consulta la devoluciÃ³n, fecha de la devolucion y si fue procedente de una aclaraciÃ³n ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_consultafectacion(pFolioCsuac CHAR(16))
    RETURNING CHAR(5) AS codret,
              CHAR(30) AS nombre;


    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cNombre CHAR(30);

    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cNombre = '';

BEGIN

    ON EXCEPTION
        SET iSqlErr LET cCodRet = iSqlErr;
        RETURN cCodRet, cNombre;
    END EXCEPTION;

    --SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_acl_consultafectacion_' || TRIM(pFolioCsuac) ||'.out';
    --TRACE ON;

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;


    IF pFolioCsuac = '' OR pFolioCsuac IS NULL THEN
        LET cCodRet = '00003';
        RETURN cCodRet, cNombre;
    END IF;

    SELECT E.nombre
    INTO cNombre 
    FROM bdiaclaracion@stag_ids1170:acl_aclaracion AS A 
    INNER JOIN bdiaclaracion@stag_ids1170:acl_regla_negocio AS B ON A.fky_regla_negocio = B.pky_id_regla
    INNER JOIN bdiaclaracion@stag_ids1170:acl_rango_importe AS C ON B.pky_id_regla = C.fky_id_regla
    INNER JOIN bdiaclaracion@stag_ids1170:acl_afectacion AS D ON C.pky_rango_importe = D.fky_rango_importe AND A.procede = D.procedente
    INNER JOIN bdiaclaracion@stag_ids1170:acl_tipo_transaccion AS E ON D.fky_tipo_transaccion = E.pky_tipo_transaccion AND e.activo = '1'
    WHERE A.folio_csuac = pFolioCsuac;

    IF cNombre = '' THEN
        LET cCodRet = '00017';
    END IF;

    RETURN cCodRet, cNombre;
END
END PROCEDURE

DOCUMENT 
'AUTOR: José Antonio Ramírez Franco',
'FECHA: 29/01/2024',
'MODULO: ACLARACIONES',
'DESCRIPCION: SPL encargado de obtener el nombre de tipo de transacción de una aclaración';

CREATE PROCEDURE "informix".sp_acl_valida_dfa_devo(pBandera CHAR(1), pFolio_csuac CHAR(16), pTarjeta CHAR(20), pMonto MONEY(16,2)) 
	RETURNING CHAR(5) AS cod_Retorno,
		CHAR(100) AS dictamen,
		CHAR(250) AS dictamen2;

	DEFINE cCodRet				CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE v_punto				CHAR(50);
	DEFINE v_es_fda_exitoso		SMALLINT;
	DEFINE v_desc_primer_fda	CHAR(50);
	DEFINE v_desc_segundo_fda	CHAR(50);
	DEFINE v_procede_abono_tmp	SMALLINT;
	DEFINE v_modo_entrada		CHAR(2);
	DEFINE v_cvv2_dinamico 		CHAR(4);
	DEFINE v_dictamen			CHAR(100);
	DEFINE v_dictamen2			CHAR(250);
	DEFINE v_dictamen_noprocede	CHAR(255);

	DEFINE v_montoDevo			MONEY(16,2);
	DEFINE v_fecha				DATE;
	DEFINE v_procede			SMALLINT;
	DEFINE v_devo				SMALLINT;
	DEFINE va_cod_ret			CHAR(5);

	LET cCodRet					= '00000';
	LET iSqlErr					= 0;
	LET v_es_fda_exitoso		= 0;
	LET v_desc_primer_fda		= '';
	LET v_desc_segundo_fda		= '';
	LET v_cvv2_dinamico			= '';
	LET v_procede_abono_tmp		= '';
	LET v_punto					= '';
	LET v_modo_entrada			= '';
	LET v_dictamen				= '';
	LET v_dictamen2				= '';
	LET v_dictamen_noprocede	= ''; 

	LET v_montoDevo				= NULL;
	LET v_fecha					= NULL;
	LET v_procede				= NULL;
	LET v_devo					= 0;
	LET va_cod_ret				= '';

BEGIN 
	ON EXCEPTION
		SET iSqlErr LET cCodRet = iSqlErr;
		RETURN cCodRet,v_dictamen, v_dictamen2;
	END EXCEPTION;

	--SET DEBUG FILE TO '/resplogifx/repaclaraciones/'||TRIM(pFolio_csuac)||'sp_acl_valida_dfa_devo.out';
	--TRACE ON;

	IF pFolio_csuac = '' THEN 
		LET cCodRet = '00003';
		RETURN cCodRet,v_dictamen, v_dictamen2;
	END IF;

	IF pBandera = '1' THEN

		SELECT punto_final, es_fda_exitoso, desc_primer_fda, desc_segundo_fda, 
			cvv2_dinamico, v_procede_abono_tmp, v_modo_entrada, dictamen_noprocede , v_cod_ret
		INTO v_punto, v_es_fda_exitoso, v_desc_primer_fda, v_desc_segundo_fda, 
			v_cvv2_dinamico, v_procede_abono_tmp, v_modo_entrada, v_dictamen_noprocede, va_cod_ret
		FROM bdiaclaracion@stag_ids1170:"informix".acl_bitacora_fda_3410
		WHERE folio_csuac = pFolio_csuac
		AND fecha_ejecucion = (SELECT MAX(fecha_ejecucion) FROM "informix".acl_bitacora_fda_3410 WHERE folio_csuac = pFolio_csuac );

		IF v_desc_primer_fda <> '' OR v_desc_primer_fda IS NOT NULL THEN 
			IF v_desc_segundo_fda <> ''OR v_desc_primer_fda IS NOT NULL THEN 
				LET v_dictamen = 'DFA ' || TRIM(v_desc_primer_fda) || ' + ' || TRIM(v_desc_segundo_fda);
			ELSE 
				LET v_dictamen = 'DFA ' || TRIM(v_desc_primer_fda);
			END IF;
		ELIF TRIM(v_punto) = TRIM('Criterio 6.1') THEN 
			LET v_dictamen = 'DFA NIP';
		ELIF TRIM(v_punto) = TRIM('Criterio 6') THEN 
			LET v_dictamen = 'DFA CHIP + NIP';
		ELIF TRIM(v_punto) = TRIM('Criterio 6.4') THEN 
			LET v_dictamen = 'DFA CVV2';
		ELIF TRIM(va_cod_ret) = TRIM('00003') OR va_cod_ret = TRIM('00002')THEN
			LET v_dictamen = '00003';
		ELIF v_dictamen_noprocede = '' THEN 
			LET v_dictamen = '';
		END IF;

	ELIF pBandera = '2' THEN

		SELECT MIN(fechahora) INTO v_fecha
		FROM bdiaclaracion@stag_ids1170:acl_movimiento 
		WHERE folio_csuac = pFolio_csuac;
		
		SELECT {+AVOID_FULL ('informix'.td_movimientos_conciliacion)}
		(monto325/100) AS monto325
		INTO v_montoDevo
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE tipotransaccion325 = '21'
		AND fechacarga::DATE <= v_fecha
		AND numtarjeta = TRIM(pTarjeta)
		AND (monto325/100) = pMonto
		GROUP BY monto325;

		IF v_montoDevo > 0 THEN
			LET v_dictamen =  "Devolucion " || TO_CHAR(v_fecha, '%d/%m/%Y')|| ' ' ||TO_CHAR(v_montoDevo);
			LET v_dictamen2 = "Lamentamos los inconvenientes en su cuenta, solicitud No Procede, la transacción fue devuelta por el comercio el día " || TO_CHAR(v_fecha, '%d/%m/%Y') || " por la cantidad de " || TO_CHAR(v_montoDevo);
		ELSE
			LET v_dictamen = 'Procedente, no cuenta con Devolucion';
		END IF
	END IF;
	
		RETURN cCodRet,v_dictamen, v_dictamen2;
	
	END 
END PROCEDURE

DOCUMENT 
'AUTOR: José Antonio Ramírez Franco',
'FECHA: 06/11/2023',
'SISTEMA:ACLARACIONES ',
'DESCRIPCION: SPL encargado de obtener los mensajes DFA (Bandera 1) y mostrar el mensaje del devolución (Bandera 2)',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_datos_analisis( p_FolioCsuac CHAR(20))

	RETURNING	  DATE AS fechaTransac,  CHAR(5) AS estatus, CHAR(5) AS flujo, CHAR(5) AS abono, DATE AS fechaAbono, CHAR(5) AS solicitud, DATE AS fechaDoc, CHAR(35) AS respuesta_e_global, CHAR(3) AS resultado_origen;

	--definicion de variables--	    
	
	DEFINE resultado_fechaTransac		DATE;
	DEFINE resultado_estatus    		CHAR(5);
	DEFINE resultado_flujo	   		 	CHAR(5);
	DEFINE resultado_abono	    		CHAR(5);
	DEFINE resultado_fechaAbono			DATE;
	DEFINE resultado_solicitud  		CHAR(5);
	DEFINE resultado_fechaDoc			DATE;
	DEFINE resultado_respuesta_e_global	CHAR(35);
	DEFINE resultado_origen_evento 		CHAR(3);
	DEFINE resultado_origen     		CHAR(3);
    DEFINE resultado_folio_suc  		CHAR(20);
    DEFINE resultado_numtarjeta 		CHAR(20);
	DEFINE nombre_origen 				CHAR(50);
	DEFINE iSqlErr      				INTEGER;
	--RQM 06 919
	DEFINE abono_inmediato				CHAR(2);
	DEFINE dfa						    CHAR(1);
	DEFINE devolucion					CHAR(1);
	DEFINE procedente 					CHAR(1);
	DEFINE vcargo						CHAR(1);
	DEFINE vexitoso						CHAR(1);
	DEFINE vfecha_afectacion			DATE;
	DEFINE escargo_inmediato			CHAR(1);
	DEFINE esabono_inmediato			CHAR(1);
	
     -- Inicializacao de las variables.
	
	LET resultado_fechaTransac 			= '';
	LET resultado_estatus 				= '';
	LET resultado_flujo					= '';
   	LET resultado_abono 				= '';
	LET resultado_fechaAbono 			= '';
	LET resultado_solicitud 			= '';
	LET resultado_fechaDoc 				= '';
	LET resultado_respuesta_e_global 	= '';
	LET resultado_origen_evento 		= '';
	LET resultado_origen 				= '';
    LET resultado_folio_suc 			= '';
    LET resultado_numtarjeta 			= '';
	LET nombre_origen 					= '';
	--RQM 06 919
	LET abono_inmediato					='';
	LET dfa						   	 	='';
	LET devolucion						='';
	LET procedente 						='';
	LET vcargo							='';
	LET vexitoso						='';
	LET vfecha_afectacion				='';
	LET escargo_inmediato				='';
	LET esabono_inmediato  				='';
   	
	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/"||p_FolioCsuac||"_obten_datos.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_fechaTransac	    = '';
				LET resultado_estatus	         = '';
				LET resultado_flujo	     = '';
				LET resultado_abono = '';
				LET resultado_fechaAbono = '';
				LET resultado_solicitud = '';
				LET resultado_fechaDoc = '';
				LET resultado_respuesta_e_global = '';
				LET resultado_origen = '';
				LET resultado_folio_suc = '';
				LET resultado_numtarjeta = '';

				RETURN  resultado_fechaTransac,  resultado_estatus, resultado_flujo, resultado_abono, resultado_fechaAbono, resultado_solicitud, resultado_fechaDoc, resultado_respuesta_e_global, resultado_origen;

			END IF;
        END EXCEPTION;



--obteniendo fecha para calcular fueratiempo, estatus general y estatus flujo
	
	SELECT bdiaclaracion:acl_aclaracion.fechacaptura, bdiaclaracion:acl_aclaracion.fky_estatus_aclaracion, bdiaclaracion:acl_aclaracion.fky_estatus_flujo_causa
	INTO  resultado_fechaTransac, resultado_estatus, resultado_flujo
	FROM bdiaclaracion:acl_aclaracion
	WHERE  bdiaclaracion:acl_aclaracion.folio_csuac= p_FolioCsuac;


 --Validación para RQM 06 919 Abono Inmediato: Obtiene banderas de devolución y dfa para identificar si es abono inmediato-----
	SELECT ev.acepta_dfa, ev.acepta_devolucion  
	INTO dfa, devolucion
	FROM bdiaclaracion:acl_aclaracion acl 
	INNER JOIN bdiaclaracion:acl_tipo_evento ev ON acl.fky_tipo_evento = ev.pky_tipo_evento
	WHERE acl.folio_csuac = p_FolioCsuac;
	
	--Valida que los campos de DFA o Devolución contengan información
	IF (dfa = '1') THEN --(dfa IS NOT NULL) OR (dfa <> '') THEN 
		LET abono_inmediato = 1;
	ELIF (devolucion = '1') THEN --(devolucion IS NOT NULL) OR (devolucion <> '') THEN
		LET abono_inmediato = 1;
	END IF;
	
	IF (abono_inmediato = '1') THEN --(abono_inmediato <> '') OR (abono_inmediato IS NOT NULL) THEN
		--Obtiene información del folio para validar si el folio cuenta con dictamen y de abono inmediato
		SELECT acl.procede 
		INTO procedente
		FROM bdiaclaracion:acl_aclaracion acl
		WHERE acl.folio_csuac = p_FolioCsuac;
		
		--si el folio es procedente, se obtiene los datos de afectación
		IF (procedente = '1') THEN--OR (procedente IS NOT NULL) OR (procedente <> '0') THEN
			SELECT LIMIT 1 mov.cargo, mov.exitoso
			INTO vcargo, vexitoso
			FROM bdiaclaracion:acl_movimiento mov
			WHERE mov.folio_csuac = p_FolioCsuac;
			
			IF (vexitoso = '1') THEN --(vcargo <> '') OR (vcargo IS NOT NULL) OR (vcargo <> '0') THEN
				--Se valida si fué un abono Exitoso
				IF (vcargo IS NULL ) OR (vcargo = '0') OR (vcargo = '') THEN
					SELECT LIMIT 1 mov.fecha_afectacion
					INTO vfecha_afectacion
					FROM bdiaclaracion:acl_movimiento mov
					WHERE mov.folio_csuac = p_FolioCsuac;
					
					LET esabono_inmediato = 1;
					
				--Se valida si es un cargo	
				ELIF (vcargo = '1') THEN
					LET escargo_inmediato = 1;
				END IF; --fin de validación para cargo o abono
			END IF; --fin de validación afectación en exitoso
		END IF; -- fin de validación procedente
	END IF; --fin de obtención de banderas para abono inmediato
			
			
--obteniendo  abono temporal y la fecha de abono              

	SELECT LIMIT 1 bdiaclaracion:acl_entrada_bitacora.fky_accion, bdiaclaracion:acl_entrada_bitacora.fechahora 
	INTO resultado_abono, resultado_fechaAbono
	FROM bdiaclaracion:acl_entrada_bitacora
	WHERE bdiaclaracion:acl_entrada_bitacora.folio_csuac = p_FolioCsuac
	AND bdiaclaracion:acl_entrada_bitacora.fky_accion=3;

	IF (resultado_abono = '3') THEN
		LET resultado_abono	 = 'Si';
	END IF;
	
	IF (resultado_abono IS NULL) OR (resultado_abono = '') THEN
		LET resultado_abono	 = 'No';
    	LET resultado_fechaAbono = '';
	END IF;
	
	--RQM 06 919 Abono Inmediato se anexan las validaciones para modificar los campos de resultado abono
	IF (esabono_inmediato = '1') THEN
		LET resultado_abono	 = 'Si';
		LET resultado_fechaAbono = vfecha_afectacion;
	END IF;
	
	IF (escargo_inmediato = '1') THEN
		LET resultado_abono	 = 'No';
		LET resultado_fechaAbono = '';
	END IF;

--obteniendo solicitud, fecha de solicitud, fecha de vencimiento(calcular), respuesta eglobal
	
	SELECT   LIMIT 1 bdiaclaracion:acl_movimiento.fky_solicitud_e_global, bdiaclaracion:acl_solicitud_e_global.fecha_envio_archivo_eglobal
	INTO resultado_solicitud, resultado_fechaDoc
	FROM bdiaclaracion:acl_movimiento, bdiaclaracion:acl_solicitud_e_global
	WHERE bdiaclaracion:acl_movimiento.folio_csuac=p_FolioCsuac
	AND bdiaclaracion:acl_movimiento.fky_solicitud_e_global >0
	AND bdiaclaracion:acl_movimiento.fky_solicitud_e_global=bdiaclaracion:acl_solicitud_e_global.pky_solicitud_e_global;
	
	IF ( resultado_solicitud IS NULL ) THEN
		LET resultado_solicitud = '';
		LET resultado_fechaDoc = '';
		LET resultado_respuesta_e_global = '';
    ELSE
        SELECT limit 1 bdiaclaracion:acl_tipo_respuesta_e_global.descripcion
        INTO resultado_respuesta_e_global
        FROM bdiaclaracion:acl_tipo_respuesta_e_global,bdiaclaracion:acl_respuesta_e_global, bdiaclaracion:acl_solicitud_e_global 
        WHERE bdiaclaracion:acl_solicitud_e_global.pky_solicitud_e_global= resultado_solicitud
        AND bdiaclaracion:acl_respuesta_e_global.pky_respuesta_e_global=bdiaclaracion:acl_solicitud_e_global.fky_respuesta_e_global
        AND bdiaclaracion:acl_respuesta_e_global.fky_tipo_respuesta_e_global= bdiaclaracion:acl_tipo_respuesta_e_global.pky_tipo_respuesta_e_global; 
	END IF;

	IF ( resultado_respuesta_e_global IS NULL ) THEN
		LET resultado_respuesta_e_global = '';
	END IF;

--OBTENER respuesta estimada en dias.

	SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
	INTO resultado_folio_suc
	FROM bdiaclaracion:acl_movimiento
	WHERE bdiaclaracion:acl_movimiento.folio_csuac=p_FolioCsuac;

--obtener numero de tarjeta

	SELECT bdiaclaracion:acl_producto.numero_tarjeta 
	INTO resultado_numtarjeta
	FROM bdiaclaracion:acl_aclaracion
	INNER JOIN bdiaclaracion:acl_producto
	ON bdiaclaracion:acl_aclaracion.fky_producto = bdiaclaracion:acl_producto.pky_producto
	AND bdiaclaracion:acl_aclaracion.folio_csuac = p_FolioCsuac;

	SELECT oe.pky_origen_evento 
	INTO resultado_origen_evento
	FROM bdiaclaracion:acl_aclaracion acl 
	INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
	INNER JOIN bdiaclaracion:acl_origen_evento oe on oe.pky_origen_evento = te.fky_origen_evento 
	WHERE acl.folio_csuac = p_FolioCsuac;

	SELECT bdiaclaracion:acl_aclaracion.tipo_movimiento 
	   INTO resultado_origen
	   FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = p_FolioCsuac;
	
	IF (resultado_origen IS NULL OR resultado_origen = '') THEN 
		
		SELECT nombre INTO nombre_origen 
			FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = resultado_origen_evento;
		
		--IF resultado_origen_evento = '2' or resultado_origen_evento = '3' or resultado_origen_evento = '6' or resultado_origen_evento = '7' Then
		IF nombre_origen = 'POS' or nombre_origen = 'ATMS' Then
			SELECT intercard:movimiento.esnacional
			INTO resultado_origen
			FROM intercard:movimiento
			WHERE intercard:movimiento.secuenciaextendida=resultado_folio_suc
			AND intercard:movimiento.numtarjeta=resultado_numtarjeta;

			 IF ( resultado_origen IS NULL ) THEN
					SELECT intercard:movimientohistorico.esnacional
					INTO resultado_origen
					FROM intercard:movimientohistorico
					WHERE intercard:movimientohistorico.secuenciaextendida=resultado_folio_suc
					AND intercard:movimientohistorico.numtarjeta=resultado_numtarjeta;
			  END IF; 

			 IF ( resultado_origen IS NULL ) THEN
				LET resultado_origen = '';
			 END IF;
		ELSE
			LET resultado_origen = 'V';
		END IF;
	END IF;
--termina respuesta estimada

	RETURN  resultado_fechaTransac,  resultado_estatus, resultado_flujo, resultado_abono, resultado_fechaAbono, resultado_solicitud, resultado_fechaDoc, resultado_respuesta_e_global, resultado_origen;
		
END
END PROCEDURE


DOCUMENT
'Se modifica para obtener los datos de afectacion en los folios procedentes para el nuevo flujo de Abono Inmediato',
'Aclaraciones',
'Area: Sistemas Perifericos',
'Gerencia de Mtto y Soporte IV',
'Autor : Mariela Montserrat Ocampo Gutierrez',
'FECHA : 23/Abril/2024',
'BD    : bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_reporte_log()
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE nomFecha CHAR(19);
	DEFINE cFecha CHAR(10);
	DEFINE pRutaDescarga CHAR(50);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	LET cFecha = '';
	LET pRutaDescarga = '/resplogifx/repaclaraciones';
	--LET pRutaDescarga = '/tmp/mfinis';

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;  

		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_reporte_log.out';
		--TRACE ON;

		IF pRutaDescarga='' THEN
			LET cCodRet = '00003';
			LET cNombreArchivo = 'Se encuentran campos nulos o vacÃ­os';	
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		

		LET cNombreArchivo = '';
    	
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FOLIO','FECHA DE LA TRANSACCION','TARJETA','AUTORIZACION','DESCARGA LOG','LOG EN FOLIO','STATUS' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT UNIQUE folio, TO_CHAR(fecha_transaccion, '%d-%m-%Y'),  ''''||tarjeta, d.v_num_autorizacion, ' ', ' ', ' ' FROM bdiaclaracion:acl_reporte_log l INNER JOIN bdiaclaracion:acl_bitacora_fda_3410 d ON d.folio_csuac = l.folio WHERE l.fecha_transaccion = TODAY)";

		-- SE DEFINE NOMBRE DEL REPORTE A GENERAR		
		LET nomFecha = TO_CHAR(dFechaHoy, '%d%m%Y');
		LET cNombreArchivo = 'LAYOUT_LOG_'||TRIM(nomFecha)||'.xls';

        --LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		--RUTA PRUEBAS
		--LET cSql = 'dbaccess bdiaclaracion '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		--RUTA PRODUCTIVA
		LET cSql = 'dbaccess bdiaclaracion '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		--Borrado de consulta
		LET cSql = '';
		LET cSql = 'rm -rf '||TRIM(pRutaDescarga)|| '/'||'query.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

					-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		-- Eliminamos el caracter delimitador al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		-- Se modifica el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'rm -rf '||TRIM(cRutaGral)||'; mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);
				
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 18/09/2023',
'MODULO: ACLARACIONES',
'DESCRIPCION: SPL encargado de generar los reportes LOG ';

CREATE PROCEDURE "informix".sp_acl_consultatipoeventosabono(p_skip INT)
		RETURNING CHAR(5) AS codret,
			CHAR(150) AS descripcion_tipo_evento;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_acl_consultatipoeventosabono.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP p_skip descripcion 
			INTO cDescripcion
			FROM bdiaclaracion:"informix".acl_tipo_eventos_abono
			
			RETURN cCodRet, cDescripcion WITH RESUME;
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 26/03/2024',
'MODULO: ACLARACIONES',
'FUNCIONALIDAD: INGRESO ACLARACION',
'DESCRIPCION: SPL encargado de consultar los tipo eventos asocioados a abono inmediato',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_asosacionorigentransaccion(pOrigen_evento INTEGER)
RETURNING CHAR(5) AS codret,
          CHAR(4) AS transaccion;

    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cTransaccion CHAR(4);
    DEFINE iRegistros INTEGER;

    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cTransaccion = '';
    LET iRegistros = 0;

    BEGIN
        ON EXCEPTION SET iSqlErr
	    	IF iSqlErr <> 0 THEN
		    	LET cCodRet = iSqlErr;
                RETURN cCodRet, cTransaccion;
		    END iF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_acl_asosacionorigentransaccion.out';
		--TRACE ON;

        IF pOrigen_evento IS NULL THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cTransaccion;
        END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        FOREACH
            SELECT transaccion
            INTO cTransaccion 
	        FROM bdiaclaracion@stag_ids1170:acl_asociacion_origen
	        WHERE fky_origen_evento = pOrigen_evento

            LET iRegistros = iRegistros + 1;
            RETURN cCodRet, cTransaccion WITH RESUME;
        END FOREACH;

        IF iRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cTransaccion;
        END IF;
    END;
END PROCEDURE

DOCUMENT 
'AUTOR: José Antonio Ramírez Franco',
'FECHA: 06/11/2023',
'SISTEMA:ACLARACIONES ',
'DESCRIPCION: SPL encargado mostrar las transacciones por medio del origen de evento';

CREATE PROCEDURE "informix".sp_busca_datos_3410_fda(pFolioCsuac CHAR(11))

	RETURNING

		CHAR(5)				AS cod_ret,
		CHAR(16)			AS tarjeta,
		SMALLINT			AS procede_abono_tmp,
		SMALLINT			AS es_diferencia_importes,
		SMALLINT			AS es_tarjeta_presente,
		CHAR(2)				AS modo_entrada,
		SMALLINT			AS es_chip_mas_nip,
		SMALLINT			AS es_fda_exitoso,
		CHAR(2)				AS cod_primer_fda,
		CHAR(2)				AS cod_segundo_fda,
		VARCHAR(75)			AS desc_primer_fda,
		VARCHAR(75)			AS desc_segundo_fda,
		CHAR(255)			AS dictamen_noprocede,
	   	CHAR(6)							AS num_autorizacion,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cargo,
		VARCHAR(30)						AS estatus_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_cancelacion_tarjeta,
		DATETIME YEAR TO FRACTION(5)	AS fecha_movimiento,
		MONEY							AS importe_reclamado,
		VARCHAR(40)						AS comercio,
		VARCHAR(40)						AS receptor,
		VARCHAR(55)						AS banco_adquirente,
		VARCHAR(15)						AS ip,
		VARCHAR(85)						AS dato_no_convencional,
		INTEGER				            AS clave_origen,
		CHAR(1) 						AS valor_subcampo6,
		CHAR(1) 						AS valor_subcampo9,
		CHAR(1) 						AS valor_subcampo12,
		CHAR(2) 						AS valor_subcampo4,
		CHAR(2) 						AS valor_subcampo5,
		CHAR(2) 						AS valor_subcampo7,
		CHAR(2) 						AS valor_subcampo8,
		CHAR(2) 						AS valor_subcampo10,
		CHAR(2) 						AS valor_subcampo11,
		CHAR(22) 						AS valor_tokenC4,
		CHAR(6)							AS tokenB3_sub8,
	    DATETIME YEAR TO FRACTION(5)    AS fecha_alta_NIP,
	    SMALLINT						AS es_comercio_seguro,
		SMALLINT						AS tiene_cvv2dinamico,
		DATETIME YEAR TO FRACTION(5)    AS fecha_alta_cvv2din,
	    CHAR(4)							AS cvv2_dinamico;


	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_id_aclaracion				INTEGER;
	DEFINE v_importereclamado			MONEY;
	DEFINE v_evento						INTEGER;
	DEFINE v_origen_evento				INTEGER;
	DEFINE v_tipo_pos					VARCHAR(5);
	DEFINE v_es_evento_robo_ext			SMALLINT;
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_corp_gral			INTEGER;
	DEFINE v_estatus_corp_analisis		INTEGER;
	DEFINE v_modo_entrada				CHAR(2);
	DEFINE v_es_nacional				CHAR(1);
	DEFINE v_referencia_mov				VARCHAR(30);
	DEFINE v_referencia23_mov			VARCHAR(30);
	DEFINE v_num_autorizacion			CHAR(6);
	DEFINE v_comercio					VARCHAR(40);
	DEFINE v_fechacaptura				DATE;
	DEFINE v_fecha_movimiento			DATETIME YEAR TO FRACTION(5);
	DEFINE v_num_tarjeta				CHAR(16);
	DEFINE v_procede_abono_tmp			SMALLINT;
	DEFINE v_id_msg_no_procedente		SMALLINT;
	DEFINE c_estatus_abonar				INTEGER;
	DEFINE c_nombre_estatus_abonar		CHAR(20);
	DEFINE v_estatus_tarjeta			CHAR(3);
	DEFINE v_desc_estatus_tarjeta		CHAR(30);
	DEFINE v_fecha_reporte_tarjeta		DATETIME YEAR TO FRACTION(5);
	DEFINE v_tarjeta_reportada			SMALLINT;
	DEFINE v_es_captura_manual			SMALLINT;
	DEFINE v_es_diferencia_importes		SMALLINT;
	DEFINE v_es_tarjeta_presente		SMALLINT;
	DEFINE v_foliosuc					VARCHAR(30);
	DEFINE v_existe_movimiento			SMALLINT;
	DEFINE v_existe_token_c4			SMALLINT;
	DEFINE v_token_c0					VARCHAR(26);
    DEFINE v_token_c4					VARCHAR(22);
	DEFINE v_receptor					VARCHAR(40);
	DEFINE v_codigoiso					VARCHAR(2);
    DEFINE v_cvv2valido					VARCHAR(2);
	DEFINE v_tiene_cvv2_activo			SMALLINT;
	DEFINE segundaLetraFolioSuc			CHAR(1);
	DEFINE v_fecha_consumo				DATETIME YEAR TO FRACTION(5); ----Se definen dos variables para obtener las fechas movimiento original y de retencion
	DEFINE v_fecha_movimiento_libe		DATETIME YEAR TO FRACTION(5);
	DEFINE fecha_alta_NIP				DATETIME YEAR TO FRACTION(5);
	DEFINE fecha_alta_cvv2din			DATETIME YEAR TO FRACTION(5);
	DEFINE altacvv2_fechcargo		CHAR(1);

	-- Variables adicionales retorno--

		DEFINE es_chip_mas_nip			SMALLINT;
		DEFINE es_fda_exitoso			SMALLINT;
		DEFINE cod_primer_fda			CHAR(2);
		DEFINE cod_segundo_fda			CHAR(2);
		DEFINE cliente_enrolado			CHAR(1);
		DEFINE desc_primer_fda			VARCHAR(50);
		DEFINE desc_segundo_fda			VARCHAR(50);
		DEFINE dictamen_noprocede    	VARCHAR(255);
		DEFINE num_autorizacion			CHAR(6);
		DEFINE banco_adquirente         VARCHAR(55);
		DEFINE ip						VARCHAR(15);
		DEFINE dato_no_convencional		VARCHAR(85);
		DEFINE clave_evento				INTEGER;
		DEFINE valor_subcampo6 			CHAR(1);
		DEFINE valor_subcampo9 			CHAR(1);
		DEFINE valor_subcampo12 		CHAR(1);
		DEFINE valor_subcampo4 			CHAR(2);
		DEFINE valor_subcampo5 			CHAR(2);
		DEFINE valor_subcampo7 			CHAR(2);
		DEFINE valor_subcampo8			CHAR(2);
		DEFINE valor_subcampo10 		CHAR(2);
		DEFINE valor_subcampo11 		CHAR(2);
		DEFINE valor_subcampo13 		CHAR(2);
		DEFINE valor_po_subcampo9		CHAR(2);
		DEFINE metodos_autenticacion	SMALLINT;
		DEFINE complemento_msj    		VARCHAR(150);
		DEFINE complemento_msj1    		VARCHAR(25);
		DEFINE complemento_msj2    		VARCHAR(25);
		DEFINE tokenB3_sub8 			CHAR(6);
		DEFINE es_comercio_seguro		SMALLINT;
		DEFINE tiene_cvv2dinamico		SMALLINT;
		DEFINE cvv2_dinamico 			CHAR(4);
		DEFINE comercio_seguro			CHAR(1);
		DEFINE v_fecha_act_pinoffline_suc		DATETIME YEAR TO FRACTION(5);
	    DEFINE v_fecha_act_pinoffline_atm		DATETIME YEAR TO FRACTION(5);
	    DEFINE v_fecha_act_pinoffline			DATETIME YEAR TO FRACTION(5);
	    DEFINE v_tiene_pinoffline		SMALLINT;
        DEFINE v_contrasena   			CHAR(10);
        DEFINE v_cvv_dinamico  		    CHAR(15);
		DEFINE v_metodocaptura     		CHAR(2);
		DEFINE v_metodoidentificacion   CHAR(2);
		DEFINE v_token_co_numero  		CHAR(1);
		DEFINE v_token_co_espacio 		CHAR(1);
		DEFINE v_mensaje_sms 		    CHAR(25);

		LET es_chip_mas_nip				= NULL;
		LET es_fda_exitoso				= NULL;
		LET cod_primer_fda				= NULL;
		LET cod_segundo_fda				= NULL;
		LET desc_primer_fda				= NULL;
		LET desc_segundo_fda			= NULL;
		LET dictamen_noprocede    		= NULL;
		LET num_autorizacion			= NULL;
		LET banco_adquirente         	= NULL;
		LET ip							= NULL;
		LET dato_no_convencional		= NULL;
		LET clave_evento				= 0;
		LET valor_subcampo6 			= NULL;
		LET valor_subcampo9 			= NULL;
		LET valor_subcampo12 			= NULL;
		LET valor_subcampo4 			= NULL;
		LET valor_subcampo5 			= NULL;
		LET valor_subcampo7 			= NULL;
		LET valor_subcampo8				= NULL;
		LET valor_subcampo10 			= NULL;
		LET valor_subcampo11 			= NULL;
		LET valor_subcampo13 			= NULL;
		LET valor_po_subcampo9 			= NULL;
		LET metodos_autenticacion		= 0;
		LET v_cod_ret 						= "00000";
		LET v_id_aclaracion					= NULL;
		LET v_importereclamado				= NULL;
		LET v_evento						= NULL;
		LET v_origen_evento					= NULL;
		LET v_tipo_pos						= NULL;
		LET v_estatus_aclaracion			= NULL;
		LET v_estatus_corp_gral				= NULL;
		LET v_estatus_corp_analisis			= NULL;
		LET v_modo_entrada					= NULL;
		LET v_es_nacional					= NULL;
		LET v_referencia_mov				= NULL;
		LET v_referencia23_mov				= NULL;
		LET v_num_autorizacion				= NULL;
		LET v_comercio						= NULL;
		LET v_fechacaptura					= NULL;
		LET v_fecha_movimiento				= NULL;
		LET v_num_tarjeta					= NULL;
		LET v_procede_abono_tmp				= NULL;
		LET v_id_msg_no_procedente			= NULL;
		LET c_estatus_abonar				= NULL;
		LET c_nombre_estatus_abonar			= 'POR_ABONAR';
		LET v_estatus_tarjeta				= NULL;
		LET v_desc_estatus_tarjeta			= NULL;
		LET v_fecha_reporte_tarjeta			= NULL;
		LET v_tarjeta_reportada				= 0;
		LET v_es_captura_manual				= NULL;
		LET v_es_diferencia_importes		= NULL;
		LET v_es_tarjeta_presente			= NULL;
		LET v_foliosuc						= NULL;
		LET v_existe_movimiento				= NULL;
		LET v_existe_token_c4				= NULL;
		LET v_token_c0						= NULL;
		LET v_token_c4						= NULL;
		LET v_receptor						= NULL;
		LET v_codigoiso						= NULL;
		LET v_cvv2valido					= NULL;
		LET v_tiene_cvv2_activo				= NULL;
		LET segundaLetraFolioSuc 			= NULL;
		LET v_fecha_consumo					= NULL;
		LET v_fecha_movimiento_libe			= NULL;
		LET complemento_msj     		    = 'Solicitud no procedente,la transaccion fue realizada con factores de autenticacion los cuales el cliente ';
		LET complemento_msj1    		    = NULL;
		LET complemento_msj2    		    = NULL;
	    LET tokenB3_sub8					= NULL;
		LET fecha_alta_NIP					= NULL;
		LET es_comercio_seguro				= NULL;
		LET tiene_cvv2dinamico				= NULL;
		LET fecha_alta_cvv2din				= NULL;
		LET cvv2_dinamico					= NULL;
		LET comercio_seguro					= NULL;
		LET cliente_enrolado				= NULL;
		LET altacvv2_fechcargo				= NULL;
		LET v_fecha_act_pinoffline_suc		= NULL;
	    LET v_fecha_act_pinoffline_atm		= NULL;
	    LET v_fecha_act_pinoffline			= NULL;
	    LET v_tiene_pinoffline				= NULL;
        LET v_contrasena   			        = 'Contraseña';
		LET v_cvv_dinamico   			    = 'CVV2 Dinamico';
		LET v_token_co_numero = NULL;
		LET v_token_co_espacio = NULL;
		LET v_mensaje_sms 		    		= 'Autenticacion por SMS';
		
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				---Se inserta el error en la tabla de control
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico,'Control de errores'); 
								
				RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
			END IF;
		END EXCEPTION;

	 --SET DEBUG FILE TO "/resplogifx/Rey_David/RQI_65_610/"||pFolioCsuac||"_3410.out";
     --TRACE ON;


	--Se obtiene el Estatus Correspondiente a En Espera de Autorización de Abono
		SELECT pky_estatus_corporativo
				INTO c_estatus_abonar
			FROM acl_estatus_corporativo
			WHERE nombre = c_nombre_estatus_abonar and activo = 1;


		LET pfoliocsuac = pfoliocsuac;

		SELECT acl.fechacaptura, mov.folio_suc, mov.fechahora, numero_tarjeta, acl.importereclamado,
					acl.pky_aclaracion, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general,
					acl.fky_estatus_corp_analisis, acl.modo_entrada, mov.referencia,mov.referencia23, acl.fky_tipo_evento,
					te.fky_origen_evento, oe.nombre, te.capturamanual, te.diferenciaimportes,
					mov.ref_comercio, mov.fecha_consumo
				INTO v_fechacaptura, v_foliosuc, v_fecha_movimiento_libe, v_num_tarjeta, v_importereclamado,
					v_id_aclaracion, v_estatus_aclaracion, v_estatus_corp_gral,
					v_estatus_corp_analisis, v_modo_entrada, v_referencia_mov,v_referencia23_mov, v_evento,
					v_origen_evento, v_tipo_pos, v_es_captura_manual, v_es_diferencia_importes,
					v_comercio, v_fecha_consumo
			FROM acl_aclaracion acl
				Inner Join acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
				Inner Join acl_origen_evento oe on te.fky_origen_evento = oe.pky_origen_evento
				Inner Join acl_movimiento mov on mov.folio_csuac = acl.folio_csuac
					and mov.fky_padre is null and mov.duplicado = 0
				Inner Join acl_producto pro on acl.fky_producto = pro.pky_producto
			WHERE acl.folio_csuac = pFolioCsuac;


		--Se valida el Estatus Actual de la Tarjeta:
		SELECT t.codstatustarjeta, st.descstatustarjeta
			INTO v_estatus_tarjeta, v_desc_estatus_tarjeta
		FROM intercard:tarjeta t
			INNER JOIN intercard:statustarjeta st ON t.codstatustarjeta = st.codstatustarjeta
		WHERE numtarjeta = v_num_tarjeta;

		--Se valida si se encuentra Cancelada por Robo o Extravío y se determina la fecha del Reporte
		IF v_estatus_tarjeta IN ('EXT','ROB','CAN') THEN
			LET v_num_tarjeta = v_num_tarjeta;
			LET v_estatus_tarjeta = v_estatus_tarjeta;
			SELECT max(fechahora)
				INTO v_fecha_reporte_tarjeta
			FROM intercard:bitacoracambiosstatustarjeta
			WHERE tarjeta = v_num_tarjeta AND codstatustarjetanvo = v_estatus_tarjeta;
			LET v_tarjeta_reportada = 1;
		END IF;

			 --Campos PO,
				 SELECT descripcion
				 INTO dato_no_convencional
				 FROM acl_cat_datosnoconv WHERE valor in (valor_po_subcampo9);

				 SELECT institucion
				 INTO banco_adquirente
				 FROM acl_cat_bines WHERE valorbin in (substr(v_referencia23_mov,2,6));

				 IF banco_adquirente IS NULL OR banco_adquirente = '' THEN
					IF v_referencia23_mov IS NOT NULL OR v_referencia23_mov <> '' THEN
					   IF substr(v_referencia23_mov,2,1)= 4 THEN
					   LET banco_adquirente = 'VISA';
					   ELIF substr(v_referencia23_mov,2,1)= 5 THEN
					   LET banco_adquirente = 'MASTERCARD';
					   ELSE
					   LET banco_adquirente = '';
					   END IF;
					END IF;
				END IF;

			--			---extrer los valore de los token PY y PO
			--
			LET v_foliosuc = v_foliosuc; -- quitar
			LET v_num_tarjeta = v_num_tarjeta;


			 SELECT py_c13_resultado_fda,py_c6_resultado_factor_a,py_c4_primer_factor_a, py_c5_segundo_factor_a,
					py_c9_resultado_factor_b, py_c7_primer_factor_b,py_c8_segundo_factor_b,py_c12_resultado_factor_c,
					py_c10_primer_factor_c,py_c11_segundo_factor_c,po_c8_enc_ip_origen,po_c9_enc_cat
			 INTO 	valor_subcampo13,valor_subcampo6,valor_subcampo4,valor_subcampo5,valor_subcampo9,valor_subcampo7,	      valor_subcampo8,valor_subcampo12,valor_subcampo10,valor_subcampo11,ip,valor_po_subcampo9
			 FROM intercard:bitacora_fda
			 WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;

			LET valor_subcampo13 = trim(valor_subcampo13);
			LET valor_subcampo4 = REPLACE (valor_subcampo4,' ','');



		--En caso de no contar con el registro del modo de entrada, se validará del origen de la información
		IF v_modo_entrada IS NULL OR v_modo_entrada = 'NN' THEN
			--Para buscar el folio_suc, se debe realizar con el primero de la secuencia
			LET segundaLetraFolioSuc = substr(v_foliosuc,2,1);
			IF substr(v_foliosuc,1,1) = 'i' AND segundaLetraFolioSuc IN ('0','1','2','3','4','5','6','7','8','9') THEN
				LET v_foliosuc = substr(v_foliosuc,1,9) || '1' || substr (v_foliosuc,11 , LENGTH(v_foliosuc));
				--Se invoca el SP para obtener la información del modo de entrada:
				CALL "informix".sp_consulta_tipo_movimiento(substr(v_foliosuc,2,29), v_num_tarjeta, v_origen_evento)
					RETURNING v_es_nacional, v_modo_entrada;
			ELSE
				LET v_modo_entrada = NULL;
			END IF;

			--En caso de tener el valor del modo de entrada, se actualiza el registro en acl_aclaracion
			 IF v_modo_entrada IS NOT NULL AND v_modo_entrada <> 'NN' THEN
				UPDATE acl_aclaracion SET modo_entrada = v_modo_entrada WHERE folio_csuac = pFolioCsuac;
			 END IF;
		END IF;


		--Se consideran los ultimos 6 caracteres de la referencia
		LET v_referencia_mov = NVL(v_referencia_mov,'');
		LET v_num_autorizacion = RIGHT(TRIM(v_referencia_mov),6);

		------26/09/2019 Se le asigna valor a la variable v_fecha_movimiento en caso de que la fecha de consumo venga en nulo se tomara la fecha de liberación
		LET v_fecha_movimiento = nvl(v_fecha_consumo, v_fecha_movimiento_libe);


		IF TRIM(v_tipo_pos) <> 'POS' THEN
			LET v_cod_ret = '00001'; --La Aclaracion no pertenece a un Origen de Compra en Comercio
			---Inserción en bitacora
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'La Aclaracion no pertenece a un Origen de Compra en Comercio'); 
			
			RETURN v_cod_ret,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;

		END IF;

		IF v_estatus_corp_gral <> 2 THEN
			LET v_cod_ret = '00002'; --La Aclaracion no se encuentra en Espera de Autorización de Abono
			---Inserción en bitacora
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'La Aclaracion no se encuentra en Espera de Autorizacion de Abono'); 
						
			RETURN v_cod_ret,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		

		
	--Se obtienen los valores de intercard:movimiento
		SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1),
		SUBSTRING_INDEX(tokens63in,'! C400012 ',-1),
		infreceptor, codigoiso, cvv2valido,
		SUBSTR(SUBSTRING_INDEX(tokens63in,'! B300080 ',-1),39,6) as PIN,
		eci as SEC ,
		SUBSTR(SUBSTRING_INDEX(tokens63in,'! C000026 ',-1),1,5) as CVV,
		metodocaptura, metodoidentificacion
			INTO v_existe_movimiento, v_token_c0,v_token_c4, v_receptor, v_codigoiso, v_cvv2valido,tokenB3_sub8,comercio_seguro,cvv2_dinamico, v_metodocaptura, v_metodoidentificacion
		FROM intercard:movimiento
		WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;

		IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN
			SELECT 1, SUBSTRING_INDEX(tokens63in,'! C000026 ',-1), SUBSTRING_INDEX(tokens63in,'! C400012 ',-1),infreceptor, codigoiso, cvv2valido,
			SUBSTR(SUBSTRING_INDEX(tokens63in,'! B300080 ',-1),39,6) as PIN, eci as SEC,SUBSTR(SUBSTRING_INDEX(tokens63in,'! C000026 ',-1),1,5) as CVV,
			metodocaptura, metodoidentificacion
				INTO v_existe_movimiento, v_token_c0,v_token_c4, v_receptor, v_codigoiso, v_cvv2valido,tokenB3_sub8,comercio_seguro,cvv2_dinamico, v_metodocaptura, v_metodoidentificacion
			FROM intercard:movimientohistorico
			WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;
		END IF;

		IF v_existe_movimiento IS NULL OR v_existe_movimiento = 0 THEN
			LET v_cod_ret = '00003'; --No encontro información en intercard
			---Se inserta e bitacora el registro de la información
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'No encontro información en intercar:movimiento'); 
								
			
			
			RETURN v_cod_ret,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
			LET v_token_co_numero = substr(cvv2_dinamico,3,1); -- SE VALIDA EL TERCER ESPACIO DEL CVV2 Dinamico PARA IDENTIFICAR SI ES VALIDO O NO Y APLICAR LA VALIDACIÓN 7.5
			LET v_token_co_espacio = substr(cvv2_dinamico,4,1); -- SE VALIDA EL CUARTO ESPACIO DEL CVV2 Dinamico PARA IDENTIFICAR SI ES ESPACIO Y APLICAR LA VALIDACIÓN 7.5
		

		IF v_metodocaptura IN('05','07','90') THEN
			LET v_es_tarjeta_presente = 1;
		ELSE
			--IF v_metodocaptura = '01' THEN
			 LET v_es_tarjeta_presente = 0;
			--END IF;
		END IF;

	    ---Se obtienen los valores para validar CVV2 validacion  7.2
          SELECT cvv2dinamico INTO cliente_enrolado
		  FROM intercard:tarjeta_indicadores WHERE numtarjeta = v_num_tarjeta;


		  --Se valida si existe fecha de activacion en CVV2 para validacion 7.3, 7.5, 7.8
		  SELECT MIN(fechacambio)
				INTO fecha_alta_cvv2din
				FROM intercard:bitacoracambiostarjeta
				WHERE tarjeta = v_num_tarjeta AND identificadorcambio = 9;

		--Se valida si la fecha de activación del CVV2 es válida para el movimiento
				IF fecha_alta_cvv2din IS NOT NULL THEN
				   LET tiene_cvv2dinamico = 1;
					IF fecha_alta_cvv2din < v_fecha_movimiento THEN
						LET altacvv2_fechcargo = 1;
					ELSE
						LET altacvv2_fechcargo = 0;
					END IF;
				END IF;



		--Se valida si la tarjeta tiene activa la Introduccion del NIP para validacion 6.3
			SELECT MIN(fechahora_insert)
				INTO v_fecha_act_pinoffline_suc
			FROM intercard:bit_pinoffline
			WHERE numtarjeta = v_num_tarjeta AND tarjeta_edofinal = 1;

			SELECT MIN(fechageneracion)
				INTO v_fecha_act_pinoffline_atm
			FROM intercard:bitacorapinoffline
			WHERE numtarjeta = v_num_tarjeta AND estatusscripting = 1;

			IF v_fecha_act_pinoffline_suc IS NULL AND v_fecha_act_pinoffline_atm IS NULL THEN
				--No cuenta con pinoffline
				LET v_tiene_pinoffline = 0;
			ELSE
				LET v_tiene_pinoffline = 1;
				--Se determina la fecha de la activación del pinoffline
				IF v_fecha_act_pinoffline_suc IS NULL THEN
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
				ELIF v_fecha_act_pinoffline_atm IS NULL THEN
					LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
				ELSE
					IF v_fecha_act_pinoffline_suc < v_fecha_act_pinoffline_atm THEN
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_suc;
					ELSE
						LET v_fecha_act_pinoffline = v_fecha_act_pinoffline_atm;
					END IF;
				END IF;
			END IF;


		--validaciones --

		--Validacion 1 Clave de evento 195 y 193----
		-- Validacion 2 Clave de evento 187,186 o 188----

		IF  v_evento in (195,193,187,186,188) THEN
		   LET v_procede_abono_tmp = 1;
		   -- continua con validacion 4
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Validacion 1a Clave de evento 195,193,187,186,188'); 
								
		   	RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

		ELSE
		   LET v_procede_abono_tmp = 0;

			-- procedente fin
		END IF;


		--Validacion 4 de diferencia de importes----

		IF v_es_diferencia_importes = 1 THEN
			LET v_procede_abono_tmp = 1; --Si es diferencia de Importes.
-----inserción en bitacora
				INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
				VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Validacion 4 de diferencia de importes'); 
						
			RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp,v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

			ELSE
			LET v_procede_abono_tmp = 0; -- candidato para ser NO procedente
			--continua validacion 5

		END IF;



		--Validacion 5 tarteja presente
		--LET v_es_tarjeta_presente = 0;
		IF v_token_c4 IS NOT NULL OR v_token_c4 <> '' THEN
				--Se obtiene el valor del subcampo 4 y 5 tarejta presente
			IF  v_es_tarjeta_presente = 1 THEN ---- metodo de captura
				--LET v_es_tarjeta_presente = 1;
				-- validación 6.1 (NIP)
				IF tokenB3_sub8 in ('010302','410302','020302','420302','030302','430302','040302','440302','050302','450302') THEN --- crear tabla con valores * provisional
				   	LET v_procede_abono_tmp = 0;
					LET dictamen_noprocede = 'No procede, Se autentico introduciendo la tarjeta a una terminal, leyendo el chip de la tarjeta y accesando su Nip.';
					
					----Inserción en Bitacora
					INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
					VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6.1'); 
						
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
					--validacion 6 chip + NIP
				ELSE
				    IF v_metodoidentificacion = 2 THEN -- validacion Chip+Nip
						LET es_chip_mas_nip = 1;
						LET v_procede_abono_tmp = 0;
						LET dictamen_noprocede = 'No procede, Se autentico introduciendo la tarjeta a una terminal, leyendo el chip de la tarjeta y accesando su Nip.';  --Se agrega modificación para el texto del dictamen en criterio 6
						---Inserción en bitacora
						INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
															es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
															v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
															ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
															valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
					VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
						es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
						v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
						valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
						tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6'); 
						
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 ,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

						--validacion 6.2 PEM10
				    ELSE
							IF v_modo_entrada = 10 THEN
							        -- validar 6.3
							    IF (v_tiene_pinoffline = 1) THEN
							 		 IF (v_fecha_act_pinoffline < v_fecha_movimiento) THEN
									 -- validar 6.4
									     LET v_es_tarjeta_presente = 1;
										 LET v_procede_abono_tmp = 0;
										----Inserción Bitacora
										INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
											es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
											v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
											ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
											valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
										VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
											es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
											v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
											valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
											tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6.4'); 
											
										 RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 ,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

									 ELSE
										 LET v_procede_abono_tmp = 1;
										 --Inserción en bitacora criterio 
										 
										INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
											es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
											v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
											ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
											valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
										VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
											es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
											v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
											valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
											tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6.4, else'); 
											
										 RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 ,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

									 END IF ;

								ELSE
									 LET v_procede_abono_tmp = 1;
									 ----Inserción de información en bitacora
										INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
											es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
											v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
											ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
											valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
										VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
											es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
											v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
											valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
											tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6.3, else'); 
											
									 RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 ,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

								END IF ;

							ELSE

								LET v_procede_abono_tmp = 1;
									 ----Inserción de información en bitacora
										INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
											es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
											v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
											ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
											valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
										VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
											es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
											v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
											valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
											tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 6.2, else'); 
											
								 RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 ,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

				            END IF;
						--END IF ;-- Modo de entrada
				    END IF ;
                END IF; --   validación 6.1 (NIP)
			ELSE
				--LET v_es_tarjeta_presente = 0;
				LET es_chip_mas_nip = 0;
				--validacion 7
			END IF;
		END IF;

	  --Tarjeta No Presente

	IF  v_es_tarjeta_presente = 0 THEN

			   -- validacion 7.1 (Comercio seguro)
			 	IF comercio_seguro = '5'  THEN
					   LET es_comercio_seguro = 1;
					   LET v_procede_abono_tmp = 0;
					   LET desc_primer_fda = v_contrasena;
					   LET desc_segundo_fda =v_mensaje_sms;
					   LET complemento_msj2 = 'tiene por medio de ';

					   LET dictamen_noprocede = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación, que previamente recibió  en su teléfono o correo electrónico.'; /*complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;*/
					   LET v_procede_abono_tmp = 0;
					   
						----Inserción de información en bitacora
						INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
							es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
							v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
							ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
							valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
						VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
							es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
							v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
							valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
							tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.1, comercio_seguro = 5'); 
							
			 	RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

				END IF;
			 ---extrer los valore de los token PY y PO

			LET v_foliosuc = v_foliosuc; -- quitar
			LET v_num_tarjeta = v_num_tarjeta;


			 SELECT py_c13_resultado_fda,py_c6_resultado_factor_a,py_c4_primer_factor_a, py_c5_segundo_factor_a,
					py_c9_resultado_factor_b, py_c7_primer_factor_b,py_c8_segundo_factor_b,py_c12_resultado_factor_c,
					py_c10_primer_factor_c,py_c11_segundo_factor_c,po_c8_enc_ip_origen,po_c9_enc_cat
			 INTO 	valor_subcampo13,valor_subcampo6,valor_subcampo4,valor_subcampo5,valor_subcampo9,valor_subcampo7,	      valor_subcampo8,valor_subcampo12,valor_subcampo10,valor_subcampo11,ip,valor_po_subcampo9
			 FROM intercard:bitacora_fda
			 WHERE secuenciaextendida = substr(v_foliosuc,2,29) AND numtarjeta = v_num_tarjeta;

			LET valor_subcampo13 = trim(valor_subcampo13);
			LET valor_subcampo4 = REPLACE (valor_subcampo4,' ','');

			 --Campos PO,
				 SELECT descripcion
				 INTO dato_no_convencional
				 FROM acl_cat_datosnoconv WHERE valor in (valor_po_subcampo9);

				 SELECT institucion
				 INTO banco_adquirente
				 FROM acl_cat_bines WHERE valorbin in (substr(v_referencia23_mov,2,6));

				 IF banco_adquirente IS NULL OR banco_adquirente = '' THEN
					IF v_referencia23_mov IS NOT NULL OR v_referencia23_mov <> '' THEN
					   IF substr(v_referencia23_mov,2,1)= 4 THEN
					   LET banco_adquirente = 'VISA';
					   ELIF substr(v_referencia23_mov,2,1)= 5 THEN
					   LET banco_adquirente = 'MASTERCARD';
					   ELSE
					   LET banco_adquirente = '';
					   END IF;
					END IF;
				END IF;


			 -- validacion 7 factor de autenticación exitoso

			IF valor_subcampo13 = 1 THEN
				LET es_fda_exitoso = 1;
				LET v_procede_abono_tmp = 0;


		-- validacion 8  campo 6 un solo metodo de autenticación

					IF valor_subcampo6 = 1 THEN
						LET metodos_autenticacion = 1;
						IF valor_subcampo4 IN  ('00','01','02','03','04','05','06','07') THEN
						LET valor_subcampo4 = valor_subcampo4;
							SELECT codigo,descripcion
							INTO cod_primer_fda,desc_primer_fda
							FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo4) and subcampo = 4;
							LET complemento_msj1 = 'tiene por medio de ';

						ELSE
							LET valor_subcampo5 = valor_subcampo5;
							SELECT codigo,descripcion
							INTO cod_primer_fda,desc_primer_fda
							FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo5) and subcampo = 5;
							LET complemento_msj1 = 'tiene por medio de ';
						END IF;
					--Contunua en validacion 10
					ELIF valor_subcampo6 = 2 THEN    --validación 9 campo 6 dos metodos_autenticacion
						LET metodos_autenticacion = 2;

						SELECT codigo,descripcion
						INTO cod_primer_fda,desc_primer_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo4)  and subcampo = 4;

						SELECT codigo,descripcion
						INTO cod_segundo_fda,desc_segundo_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo5) and subcampo = 5;

						LET complemento_msj1 = 'tiene por medio de ';
						LET complemento_msj2 = 'y ';
						LET dictamen_noprocede = complemento_msj || complemento_msj1 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
						LET v_procede_abono_tmp = 0; -- dictamina NO procedente
						
								----Inserción de información en bitacora
								INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
									es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
									v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
									ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
									valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
								VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
									es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
									v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
									valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
									tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 10'); 
							
							RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

					END IF;

			ELSE
				LET es_fda_exitoso = 0;
				LET v_procede_abono_tmp = 1; -- dictamina procedente
				-- validacion 7.2
				IF cliente_enrolado = 'V' THEN
							-- Validacion 7.3
						IF altacvv2_fechcargo = 1 THEN
						---- Se modifica esta opcion el día 01/07/2021
							--LET v_procede_abono_tmp = 0;
							--LET desc_primer_fda = v_contrasena;
							--LET desc_segundo_fda =v_cvv_dinamico;
							--LET complemento_msj2 = 'tiene por medio de ';
							--
							--LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
							--LET v_procede_abono_tmp = 0;
							--
							--	RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
						-- Validacion 7.4 dentro de la validaciÂ¨Â®n 7.3
							IF v_cvv2valido = '00' THEN
							----7.5 NUEVA VALIDACON
								IF v_token_co_numero <> ' ' AND v_token_co_espacio = ' ' THEN
										LET v_procede_abono_tmp = 0;
										LET desc_primer_fda = v_contrasena;
										LET desc_segundo_fda = v_cvv_dinamico;
										LET complemento_msj2 = 'tiene por medio de ';
									--
										LET dictamen_noprocede = 'No procede: El cliente se autenticó al instalar la aplicación BanCoppel con su tarjeta y NIP, ingresó a la aplicación BanCoppel con usuario y contraseña y generó CVV dinámico.';
											----Inserción de información en bitacora
											INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
												es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
												v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
												ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
												valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
											VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
												es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
												v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
												valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
												tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.5, Nueva'); 
							
										RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
	
								END IF;
							END IF;
						END IF ;
				ELSE 
					-- cuando el 7.2 es negativo SE AUTORIZA ABANO
					--IF /*cvv2_dinamico IS NOT NULL OR*/ substr(cvv2_dinamico,3,1) <> ' ' THEN
						LET v_procede_abono_tmp = 1;
						--LET desc_primer_fda = v_contrasena;
						--LET desc_segundo_fda = v_cvv_dinamico;
						--LET complemento_msj2 = 'tiene por medio de ';
						
						--LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
						
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.2'); 
								
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
					--END IF;
				END IF;
				-- validar 7.6
					IF v_modo_entrada = 10 THEN
						-- validar 7.7
						IF tiene_cvv2dinamico =1 THEN

							-- validar 7.8
							IF altacvv2_fechcargo = 1 THEN
							LET v_procede_abono_tmp = 0;
								LET desc_primer_fda = v_contrasena;
								LET desc_segundo_fda =v_cvv_dinamico;
							LET complemento_msj2 = 'tiene por medio de ';
							LET dictamen_noprocede = 'No procede: El cliente que registró y autorizó el resguardo de su número de tarjeta y fecha de expiración al comercio, datos que se utilizan para aprobar las transacciones posteriores.';

										----Inserción de información en bitacora
									INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
										es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
										v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
										ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
										valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
									VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
										es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
										v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
										valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
										tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.8'); 
							
								RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

							END IF;
						ELSE
							LET v_procede_abono_tmp = 1;
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.7, else'); 
							
							RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
						END IF;

					ELSE
						LET v_procede_abono_tmp = 1;
						----Inserción de información en bitacora
						INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
							es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
							v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
							ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
							valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
						VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
							es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
							v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
							valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
							tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7.6, else'); 
							
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
					END IF; -- validar
				--END IF;
						----Inserción de información en bitacora
						INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
							es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
							v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
							ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
							valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
						VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
							es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
							v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
							valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
							tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 7, antes del end if subcampo 13'); 
				
				RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

			END IF;
			-- validación 10 campo 9 un solo metodo de autenticación

					IF valor_subcampo9 = 1 THEN
						LET metodos_autenticacion = 1;
						IF valor_subcampo7 IN ('00','01','02','03') THEN
							SELECT codigo,descripcion
							INTO cod_segundo_fda,desc_segundo_fda
							FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo7)  and subcampo = 7;
							LET complemento_msj2 = 'sabe por medio de ';
						ELSE
							SELECT codigo,descripcion
							INTO cod_segundo_fda,desc_segundo_fda
							FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo8)  and subcampo = 8;
							LET complemento_msj2 = 'sabe por medio de ';
						END IF;

						--Contunua en validacion 11
					ELIF valor_subcampo9 = 2 THEN    --validación 11 campo 9 dos metodos_autenticacion

						LET metodos_autenticacion = 2;

						SELECT codigo,descripcion
						INTO cod_primer_fda,desc_primer_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo7) and subcampo = 7;

						SELECT codigo,descripcion
						INTO cod_segundo_fda,desc_segundo_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo8) and subcampo = 8;

						LET complemento_msj1 = 'sabe por medio de ';
						LET complemento_msj2 = 'y ';
						LET dictamen_noprocede = complemento_msj || complemento_msj1 || ' ' || desc_primer_fda || ' y ' || desc_segundo_fda;

						LET v_procede_abono_tmp = 0; -- dictamina NO procedente
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 11, valor_subcampo9 = 2'); 
								
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

					END IF;
		--END IF;

			-- validación 12 Campo 12 un solo metodo de autenticación

				IF valor_subcampo12 = 1 THEN
						LET metodos_autenticacion = 1;

					IF valor_subcampo10 IN  ('00','01','02','03','04','05','06','07') THEN
						 IF cod_segundo_fda IS NULL THEN
							 SELECT codigo,descripcion
							 INTO cod_segundo_fda,desc_segundo_fda
							 FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo10) and subcampo = 10;
							 LET complemento_msj2 = 'realizo por medio de ';
						 ELSE
							 SELECT codigo,descripcion
							 INTO cod_primer_fda,desc_primer_fda
							 FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo10) and subcampo = 10;
							 LET complemento_msj1 = 'realizo por medio de ';
						 END IF;
						-- ELIF metodos_autenticacion = 1 THEN
						IF desc_primer_fda IS NOT NULL THEN
							LET dictamen_noprocede = complemento_msj || complemento_msj1 || '' || desc_primer_fda || '.';
							ELIF desc_segundo_fda IS NOT NULL THEN
							LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_segundo_fda || '.';
						END IF;
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 12, valor_subcampo10'); 
								
						RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;


				    ELIF valor_subcampo11 IS NOT NULL OR valor_subcampo11 <> '' THEN
				         IF cod_segundo_fda IS NULL THEN
							 SELECT codigo,descripcion
							 INTO cod_segundo_fda,desc_segundo_fda
							 FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo11) and subcampo = 11;
						 ELSE
							 SELECT codigo,descripcion
							 INTO cod_primer_fda,desc_primer_fda
							 FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo11) and subcampo = 11;
						 END IF;


					ELIF valor_subcampo12 = 2 THEN    --validación 13 campo 12 dos metodos_autenticacion
							LET metodos_autenticacion = 2;

						SELECT codigo,descripcion
						INTO cod_primer_fda,desc_primer_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo10) and subcampo = 10;

						SELECT codigo,descripcion
						INTO cod_segundo_fda,desc_segundo_fda
						FROM acl_cat_tokenPY WHERE codigo in (valor_subcampo11)and subcampo = 11;

						LET complemento_msj1 = 'realizo por medio de ';
						LET complemento_msj2 = '';
						LET dictamen_noprocede = complemento_msj || complemento_msj1 || ' ' || desc_primer_fda || ' y ' || complemento_msj2, desc_segundo_fda;
						LET v_procede_abono_tmp = 0; -- dictamina NO procedente
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Criterio 13, campo 12 dos metodos_autenticacion'); 
								
					RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

					END IF;
				END IF;

			-- Generacion del mensaje dinamico--
					IF desc_primer_fda IS NOT NULL AND desc_segundo_fda IS NOT NULL AND desc_primer_fda <> '' AND  desc_segundo_fda <> '' THEN
						LET metodos_autenticacion = 2;
					END IF;

					IF metodos_autenticacion = 2 THEN
						LET dictamen_noprocede = complemento_msj || complemento_msj1 || '' || desc_primer_fda || ' y ' || complemento_msj2 ||  desc_segundo_fda || '.' ;
					ELIF metodos_autenticacion = 1 THEN
						IF desc_primer_fda IS NOT NULL THEN
							LET dictamen_noprocede = complemento_msj || complemento_msj1 || '' || desc_primer_fda || '.';
							ELIF desc_segundo_fda IS NOT NULL THEN
							LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_segundo_fda || '.';
						END IF;
					ELSE
						LET dictamen_noprocede = '';
						LET metodos_autenticacion = 0;
					END IF;
	----------------************************************
		--ELSE
		--	LET es_fda_exitoso = 0;
		--	LET v_procede_abono_tmp = 1; -- dictamina procedente
		--	-- validacion 7.2
		--	IF cliente_enrolado = 'V' THEN
		--				-- Validacion 7.3
		--			IF altacvv2_fechcargo = 1 THEN
		--				LET v_procede_abono_tmp = 0;
		--				LET desc_primer_fda = v_contrasena;
		--				LET desc_segundo_fda =v_cvv_dinamico;
		--				LET complemento_msj2 = 'tiene por medio de ';
		--
		--				LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
		--				LET v_procede_abono_tmp = 0;
		--
		--					RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
		--
		--			END IF ;
		--	END IF;
		--	 -- Validacion 7.4
		--					IF cvv2_dinamico IS NOT NULL OR substr(cvv2_dinamico,3,1) = ' ' THEN
		--					-- validacion 7.5
		--						IF altacvv2_fechcargo = 1 THEN
		--						LET v_procede_abono_tmp = 0;
		--							LET desc_primer_fda = v_contrasena;
		--							LET desc_segundo_fda =v_cvv_dinamico;
		--						LET complemento_msj2 = 'tiene por medio de ';
		--
		--						LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
		--
		--
		--							RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
		--
		--						END IF;
		--
		--					END IF;--ELSE
		--				-- validar 7.6
		--							IF v_modo_entrada = 10 THEN
		--								-- validar 7.7
		--								IF tiene_cvv2dinamico =1 THEN
		--
		--									-- validar 7.8
		--									IF altacvv2_fechcargo = 1 THEN
		--									LET v_procede_abono_tmp = 0;
		--										LET desc_primer_fda = v_contrasena;
		--										LET desc_segundo_fda =v_cvv_dinamico;
		--									LET complemento_msj2 = 'tiene por medio de ';
		--									LET dictamen_noprocede = complemento_msj || complemento_msj2 || '' || desc_primer_fda || ' y ' || desc_segundo_fda;
		--
		--										RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
		--
		--									END IF;
		--								ELSE
		--									LET v_procede_abono_tmp = 1;
		--
		--									RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
		--								END IF;
		--
		--							ELSE
		--								LET v_procede_abono_tmp = 1;
		--
		--								RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;
		--							END IF; -- validar
			--END IF;
						----Inserción de información en bitacora
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Return penultimo, no entontro en ninguno de los criterios'); 
								
		RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4 , tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

	END IF;
						----Inserción de información en bitacora final
							INSERT INTO "informix".acl_bitacora_fda_3410(folio_csuac ,fecha_ejecucion , v_cod_ret ,v_num_tarjeta ,v_procede_abono_tmp,v_es_diferencia_importes,v_es_tarjeta_presente,v_modo_entrada ,
								es_chip_mas_nip ,es_fda_exitoso ,cod_primer_fda ,cod_segundo_fda ,desc_primer_fda ,desc_segundo_fda,dictamen_noprocede ,v_num_autorizacion ,
								v_fecha_movimiento_libe,v_desc_estatus_tarjeta ,v_fecha_reporte_tarjeta, v_fecha_movimiento, v_importereclamado,v_comercio,v_receptor ,banco_adquirente ,
								ip ,dato_no_convencional,v_evento ,valor_subcampo6,valor_subcampo9,valor_subcampo12,valor_subcampo4,valor_subcampo5,valor_subcampo7,valor_subcampo8,
								valor_subcampo10,valor_subcampo11,v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, punto_final)
							VALUES(pFolioCsuac, current, v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, 
								es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,dictamen_noprocede, v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta,
								v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9,
								valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4, tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,
								tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico, 'Return Final de sp'); 
								
			RETURN v_cod_ret,v_num_tarjeta, v_procede_abono_tmp, v_es_diferencia_importes, v_es_tarjeta_presente, v_modo_entrada,es_chip_mas_nip, es_fda_exitoso,cod_primer_fda, cod_segundo_fda,desc_primer_fda,desc_segundo_fda,TRIM(dictamen_noprocede), v_num_autorizacion, v_fecha_movimiento_libe,v_desc_estatus_tarjeta, v_fecha_reporte_tarjeta, v_fecha_movimiento,v_importereclamado, v_comercio, v_receptor, banco_adquirente, ip, dato_no_convencional, v_evento, valor_subcampo6, valor_subcampo9, valor_subcampo12,valor_subcampo4,valor_subcampo5, valor_subcampo7, valor_subcampo8, valor_subcampo10, valor_subcampo11, v_token_c4,tokenB3_sub8,fecha_alta_NIP,es_comercio_seguro,tiene_cvv2dinamico,fecha_alta_cvv2din,cvv2_dinamico;

END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	16/03/2021',
'Requerimiento	:	RQM 06 731-4',
'VERSION		: 	1.0.3',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busquedamovstrans(
						pOrigenEvento	INTEGER,
						pTipoEvento 	INTEGER,
						pFechaInicial	DATE,
						pFechaFinal		DATE,
						pNumeroCliente	CHAR(9),
						pNumeroCuenta	CHAR(30),
						pNumeroTarjeta	CHAR(16),
                        p_skip INTEGER,
                        p_recuperacion INTEGER)

	RETURNING
	CHAR(3) 						AS cCodRet,
	DATE 							AS fechaMovimiento,
	DATETIME HOUR to FRACTION(3) 	AS horaMovimiento ,
	money(16,2) 					AS monto,
	CHAR(30) 						AS folioSuc,
	CHAR(4) 						AS sucursal,
	CHAR(30) 						AS nombre,
	CHAR(5) 						AS claveTipo,
	CHAR(40) 						AS tipo,
   	CHAR(30) 					    AS referencia23,
	CHAR(1) 						AS reversado,
	CHAR(40) 						AS refComercio,
	DATE 							AS fechaConsumo,
	DATETIME HOUR to FRACTION(3)  	AS horaConsumo,
	CHAR(1) 						AS tipomovimiento,
	CHAR(2) 						AS modoentrada;

	--Variables--
		DEFINE sql_err 						INTEGER;
		DEFINE v_cod_ret 					CHAR(4);

		DEFINE tipo_producto 				INTEGER;

		--Variables SP
		DEFINE s_fechamovimiento			DATE;
		DEFINE s_horamovimiento				DATETIME HOUR to FRACTION(3);
		DEFINE s_monto 						money(16,2);
		DEFINE s_foliosuc					CHAR(30);
		DEFINE s_sucursal					CHAR(4);
		DEFINE s_nombre						CHAR(30);
		DEFINE s_clavetipo 					CHAR(5);
		DEFINE s_tipo 						CHAR(40);
        DEFINE s_referencia23 				CHAR(30);
		DEFINE s_reversado 					CHAR(1);
		DEFINE s_refcomercio 				CHAR(40);
		DEFINE s_fechaconsumo 				DATE;
		DEFINE s_horaconsumo 				DATETIME HOUR to FRACTION(3);
		DEFINE s_tipomovimiento				CHAR(1);
		DEFINE s_modoentrada 				VARCHAR(2);
	    DEFINE tmp_str, ret_val             CHAR(255);
        DEFINE ret_str                      LVARCHAR;
        DEFINE s_telefono					CHAR(13);

        DEFINE s_nombreOrigenEvento			VARCHAR(15);
        DEFINE s_fechaString				CHAR(20);
        --CHAR(40) AS refComercio, DATE AS fechaConsumo, DATETIME HOUR to FRACTION(3) AS horaConsumo;

        --Variables dummy
        DEFINE dummy_horamovimiento				DATETIME HOUR to FRACTION(3);
		DEFINE dummy_monto 						money(16,2);
		DEFINE dummy_foliosuc					CHAR(30);
		DEFINE dummy_sucursal					CHAR(4);
		DEFINE dummy_nombre						CHAR(30);
		DEFINE dummy_clavetipo 					CHAR(5);
		DEFINE dummy_tipo 						CHAR(40);
        DEFINE dummy_referencia23 				CHAR(30);
		DEFINE dummy_reversado 					CHAR(1);
		DEFINE dummy_refcomercio 				CHAR(40);
		DEFINE dummy_fechaconsumo 				DATE;
		DEFINE dummy_horaconsumo 				DATETIME HOUR to FRACTION(3);
		DEFINE dummy_tipomovimiento				CHAR(1);
		DEFINE dummy_modoentrada 				VARCHAR(2);
        --Variables SKIP
        DEFINE iRecuperacion INTEGER;


        LET v_cod_ret 					= "000";
		LET tipo_producto 				=0;
		LET s_telefono					="";
		--Variable SP
        LET s_referencia23              ="";
		LET s_fechamovimiento			="";
		LET s_horamovimiento			="";
		LET s_monto 					="";
		LET s_foliosuc					="";
		LET s_sucursal					="";
		LET s_nombre					="";
		LET s_clavetipo 				="";
		LET s_tipo 						="";
		LET s_reversado 				="";
		LET s_refcomercio 				="";
		LET s_fechaconsumo 				="";
		LET s_horaconsumo 				="";
		LET s_tipomovimiento			="";
		LET s_modoentrada 				="";
		LET ret_str = "";
        LET ret_val = "";
        LET tmp_str = "";

        LET s_nombreOrigenEvento		="";
        LET s_fechaString = "";

        --
        LET dummy_horamovimiento = "";
		LET dummy_monto          = "";
		LET dummy_foliosuc       = "";
		LET dummy_sucursal		= "";
		LET dummy_nombre		= "";
		LET dummy_clavetipo 	= "";
		LET dummy_tipo 			= "";
        LET dummy_referencia23 	= "";
		LET dummy_reversado 	= "";
		LET dummy_refcomercio 	= "";
		LET dummy_fechaconsumo 	= "";
		LET dummy_horaconsumo 	= "";
		LET dummy_tipomovimiento = "";
		LET dummy_modoentrada 	= "";
        --Variables SKIP
        LET iRecuperacion = 0;
        
		--SET DEBUG FILE TO "/informix/traces/sp_aplica_movtran.out";
		--TRACE ON;


		BEGIN
		  ON EXCEPTION SET sql_err
		     IF sql_err <> 0 THEN
		   	     LET v_cod_ret = sql_err;
			     RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada;
		     END IF;
		   END EXCEPTION;

           -- VALIDACION DE LA PAGINACION
            IF p_skip < 0 OR p_recuperacion < 0 THEN
                LET v_cod_ret = '098'; --PAGINACION INVALIDA
                RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
            END IF;

		   SET ISOLATION TO DIRTY READ;
           SET LOCK MODE TO WAIT 3;
------Se agrega numero del clientes a la consulta
		   select first 1 (tprod.tipo_producto)
		   		into tipo_producto
		   		from acl_producto prod
				inner join acl_tipo_producto tprod on prod.fky_tipo_producto=tprod.pky_tipo_producto
			WHERE prod.numero_cuenta = pNumeroCuenta and prod.num_cliente = pNumeroCliente;

		/*31-05-2024 - Se cambia la obtención del dato para atender el incidente con el cliente 024715557 y similares*/
		--Obtiene el numero transfer
           SELECT first 1  telefono
                INTO s_telefono
                FROM bditransfer:tf_maecte
                WHERE empresa = '001'
                AND numcte = pNumeroCliente;
		/*31-05-2024 - FIN Se cambia la obtención del dato para atender el incidente con el cliente 024715557 similares*/
			--Obtener Array de transacciones en base al pky del evento
           FOREACH  select DISTINCT (transaccion)  into  ret_val from acl_tipo_movimiento where
                fky_origen_evento = (select fky_origen_evento from acl_tipo_evento where  pky_tipo_evento = pTipoEvento)
                and  fky_tipo_transaccion = (select fky_tipo_transaccion from acl_tipo_evento where  pky_tipo_evento = pTipoEvento)
                and activo = 1
                LET tmp_str = ret_str;
                LET ret_str = TRIM(tmp_str) ||"," || TRIM(ret_val);
           END FOREACH
           LET ret_str = SUBSTR (ret_str, 2);

			-- credito
			IF (tipo_producto = 1) THEN
                FOREACH
                    SELECT SKIP p_skip FIRST p_recuperacion fechaMovimiento, horaMovimiento, monto, folioSuc,  sucursal,  nombre,  claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc,  s_sucursal, s_nombre, s_clavetipo, s_tipo,  s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE(FUNCTION bdinteg:sp_buscar_movimientos_credito_dia3(pNumeroCuenta, pFechaInicial,  pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                                AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)
                    union all
                    SELECT  fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    --INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo,  s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE( FUNCTION bdinteg:sp_buscar_movimientos_credito_his3(pNumeroCuenta, pFechaInicial, pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                                AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)
                    union all
                    SELECT  fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    --INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo,  s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE( FUNCTION bdinteg:sp_buscar_movimientos_creditocrd_his(pNumeroCuenta, pFechaInicial, pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001'))
                            AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)

                    CALL sp_consulta_tipo_movimiento(substr(s_foliosuc,2,length(s_foliosuc)),pNumeroTarjeta,pOrigenEvento)
				    RETURNING s_tipomovimiento, s_modoentrada;

                    LET iRecuperacion = iRecuperacion + 1;
                    RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
                END FOREACH;

			-- debito
			ELIF(tipo_producto = 2) THEN
				FOREACH

					--sp_buscar_movimientos_cheques_dia3
					SELECT SKIP p_skip FIRST p_recuperacion fechamovimiento, horamovimiento, monto, foliosuc,  sucursal,  nombre,  clavetipo, tipo, reversado, refcomercio, fechaconsumo, horaconsumo
                    INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc,  s_sucursal, s_nombre, s_clavetipo, s_tipo, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_cheques_dia3(pNumeroCuenta, pFechaInicial,  pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                    			AS a(fechamovimiento, horamovimiento, monto, foliosuc,  sucursal,  nombre,  clavetipo, tipo, reversado, refcomercio, fechaconsumo, horaconsumo)

                    union all
                    SELECT  a.fechamovimiento, a.horamovimiento, a.monto, a.foliosuc, a.sucursal, a.nombre, a.clavetipo, a.tipo, a.reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_inversion_dia2(pNumeroCuenta, pFechaInicial, pFechaFinal , null , 0, TRIM (ret_str) , '001') )
                    			AS a (fechamovimiento, horamovimiento, monto, foliosuc, sucursal, nombre, clavetipo, tipo, reversado )

                    --union all
                    --sp_buscar_movimientos_inversion_his2
                    --dummy_horamovimiento as horamovimiento, dummy_monto  as monto, dummy_foliosuc as foliosuc, dummy_sucursal as sucursal,
                    --dummy_nombre as nombre, dummy_clavetipo as clavetipo, dummy_tipo as tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    --SELECT  fechamovimiento, dummy_horamovimiento as horamovimiento, dummy_monto  as monto, dummy_foliosuc as foliosuc, dummy_sucursal as sucursal, dummy_nombre as nombre, dummy_clavetipo as clavetipo, dummy_tipo as tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    --FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_inversion_his2(pNumeroCuenta, pFechaInicial , pFechaFinal , null , 0 , TRIM (ret_str) , '001') )
                    --			AS a(fechamovimiento)
                    union all
                    --sp_buscar_movimientos_transfer
                    SELECT  fechamovimiento, horamovimiento, monto, foliosuc, sucursal, dummy_nombre as nombre, clavetipo, tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_transfer(pNumeroCuenta, s_telefono, pFechaInicial, pFechaFinal, null , 0 , pNumeroTarjeta , TRIM (ret_str) ,  '001' ) )
                    			AS a(fechamovimiento, horamovimiento, monto, foliosuc, sucursal,  clavetipo, tipo)
                   	CALL sp_consulta_tipo_movimiento(substr(s_foliosuc,2,length(s_foliosuc)),pNumeroTarjeta,pOrigenEvento)
				    RETURNING s_tipomovimiento, s_modoentrada;

				    LET s_tipomovimiento = s_tipomovimiento;
				    LET s_modoentrada = s_modoentrada;

				    SELECT nombre
				    into s_nombreOrigenEvento
				    FROM acl_origen_evento WHERE pky_origen_evento = pOrigenEvento;

				    IF ( TRIM(s_nombreOrigenEvento) == 'POS' ) THEN
				    	LET s_fechaString = '';
                        LET s_fechaString = year (s_fechamovimiento) || '-' || month (s_fechamovimiento) || '-' || day (s_fechamovimiento); 
				    	SELECT limit 1 TO_CHAR(TO_DATE(s_fechaString,'%Y-%m-%d'), '%d%m%Y')
				    		into s_fechaString
				    	FROM systables;
						------Se agregar la obtención de las referencia 23 con las adecaucione solicitadas
						CALL bdinteg:sp_obten_referencia23_cheques(s_foliosuc, 'VID1'||s_fechaString,'VND1'||s_fechaString,'001')
						RETURNING s_referencia23;
						LET s_referencia23 = s_referencia23;
				    END IF;

                    LET iRecuperacion = iRecuperacion + 1;
					RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;

				END FOREACH;
			END IF;
           --PAGINACION
           IF iRecuperacion = 0 AND p_skip = 0 THEN
			LET v_cod_ret = '017'; --NO SE ENCONTRARON REGISTROS Y NO SE ESPECIFICÓ LA PAGINACIÓN
			RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
           ELIF iRecuperacion = 0 AND p_skip > 0 THEN
			LET v_cod_ret = '101';			RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
           END IF;	
		END;
END PROCEDURE
DOCUMENT
'Sp sp_busquedamovstrans',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_tipo_movimiento(p_FolioSuc CHAR(20),p_NumTarjeta CHAR(20),p_OrigenEvento INTEGER)

    RETURNING CHAR(1) AS resultado_origen,VARCHAR(2) AS modo_entrada;
    DEFINE resultado_origen 	CHAR(1);
    DEFINE iSqlErr      		INTEGER;
	DEFINE nombre_origen 		CHAR(50);
    DEFINE imodo_entrada        VARCHAR(2);
	
    LET resultado_origen 		= '';
	LET nombre_origen 			= '';
   	LET imodo_entrada           = '';
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_origen = '';
				RETURN  iSqlErr,'Er'; --RETURNING
			END IF;
        END EXCEPTION;

     -- SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;

     -- SET DEBUG FILE TO "/RESPALDOSNEW/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;
 	SELECT nombre 
        INTO nombre_origen 
		FROM "informix".acl_origen_evento 
        WHERE pky_origen_evento = p_OrigenEvento;
	
    IF nombre_origen = 'POS' or nombre_origen = 'ATMS' Then
            
            SELECT intercard:movimiento.esnacional, intercard:movimiento.metodocaptura
            INTO resultado_origen, imodo_entrada
            FROM intercard:movimiento
            WHERE intercard:movimiento.secuenciaextendida=p_FolioSuc
            AND intercard:movimiento.numtarjeta=p_NumTarjeta;
             
                IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    SELECT intercard:movimientohistorico.esnacional, intercard:movimientohistorico.metodocaptura
                    INTO resultado_origen, imodo_entrada
                    FROM intercard:movimientohistorico
                    WHERE intercard:movimientohistorico.secuenciaextendida=p_FolioSuc
                    AND intercard:movimientohistorico.numtarjeta=p_NumTarjeta;
                ELSE
                    RETURN resultado_origen,imodo_entrada; -- RETURNING
                END IF; 


             --RETURN resultado_origen,imodo_entrada; -- RETURNING


                 IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    LET resultado_origen = 'N';
                 END IF;

                 IF ( imodo_entrada IS NULL OR imodo_entrada='') THEN
                    LET imodo_entrada = 'NN';
                 END IF;
	ELSE
		LET resultado_origen = 'V';
        LET imodo_entrada= 'NN';
	END IF;
    
    RETURN resultado_origen,imodo_entrada;

    END
END PROCEDURE;