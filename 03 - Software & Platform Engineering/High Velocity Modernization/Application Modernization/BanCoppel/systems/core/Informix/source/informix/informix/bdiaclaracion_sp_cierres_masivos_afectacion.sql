CREATE PROCEDURE "informix".sp_cierres_masivos_afectacion()
						
	RETURNING	CHAR(5) AS codigo_ret;
	--	VARCHAR(150)		AS Mensaje;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(6);
	DEFINE cCodRet              		CHAR(6);
	DEFINE vFolioCsuac					varchar(11);
	--DEFINE c_ruta_archivo				VARCHAR(50);
	DEFINE c_nombre_archivo				VARCHAR(50);
	DEFINE c_ext_archivo				VARCHAR(50);
	DEFINE v_nombre_archivo				VARCHAR(50);
	DEFINE c_fecha_actual				DATE;
	DEFINE v_nombre            	 		VARCHAR(11) ;
	DEFINE v_descripcion        		VARCHAR(100);
	Define cCadena 						CHAR(1000);
	DEFINE vsql	        				char(3000);
	DEFINE v_folio_csuac 				varchar(16);
	DEFINE v_dictamen   				LVARCHAR;
	DEFINE v_bitacora   				LVARCHAR;
	DEFINE v_importeprocedente			MONEY;
	DEFINE v_dias_conclucion 			integer;
	DEFINE v_pky_aclaracion 			integer;
	DEFINE iContador  					INTEGER;
	DEFINE v_temp_table        			INTEGER;
	DEFINE v_mensaje 					varchar(150);
	DEFINE v_procede  					varchar(2);
	DEFINE vcodresolucion      		 	varchar(2);
	DEFINE vResultado					CHAR(50);
	DEFINE v_resolucion      			INTEGER;
	DEFINE v_procedente					CHAR(2);
	--DEFINE v_mensaje 					varchar(150);
	DEFINE v_num_proceso				INTEGER;
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_general			INTEGER;
	DEFINE v_afectacion					CHAR(1);
	
	LET v_cod_ret 						= "00000";
	--LET c_ruta_archivo 					= "DISK:/resplogifx/repaclaraciones/";
	LET c_nombre_archivo				= "ACL_CIERRE_MASIVOS_AFEC";
	LET c_ext_archivo					= ".csv";
	LET v_nombre_archivo				= NULL;
	LET v_folio_csuac					= '';
	LET v_dictamen 						= '';
	LET v_bitacora  					= '';
	LET v_importeprocedente 			= '';
	LET v_dias_conclucion 				= '';
	LET v_pky_aclaracion 				= '';
	LET iContador 						= 0;
	LET v_temp_table 					= '';
	LET v_mensaje 						= 'Procesado Correctamente';
	LET v_procede  						= '';
	LET vcodresolucion  				= '';
	LET v_procedente 					= NULL;
	LET v_num_proceso 					= NULL;
	LET v_afectacion  					= '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/resplogifx/Dann/sp_cierre masivos_afectacion_TASF.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
				
			END IF;
		END EXCEPTION;
	on exception in (-668)
        LET v_cod_ret = '00001';
		RETURN v_cod_ret;
    end exception with resume;	
	--ON EXCEPTION IN (-535)
	--		  --ROLLBACK WORK;
	--COMMIT WORK;
	--			--SET ISOLATION TO DIRTY READ;
	--		  --BEGIN WORK;
	--END EXCEPTION WITH RESUME;

		
		
		SELECT tabid
		INTO v_temp_table
		FROM systables WHERE tabname ='tabla_cierre_preventivo_afectac';
		
		IF v_temp_table IS NOT NULL THEN
			DROP TABLE "informix".tabla_cierre_preventivo_afectac;
		END IF;
		
		SELECT fecha_hoy 
			INTO c_fecha_actual
		FROM bdinteg:si_fechas
		WHERE empresa = "001";
		
		LET v_nombre_archivo = c_nombre_archivo||'_'|| LPAD(day(c_fecha_actual), 2, '0')|| LPAD(month(c_fecha_actual), 2, '0') || year(c_fecha_actual)|| c_ext_archivo;
		
		
		--CREATE TEMP TABLE tabla_pbas(
		CREATE TABLE "informix".tabla_cierre_preventivo_afectac( 
			folio_csuac            	VARCHAR(11) ,
			bitacora				LVARCHAR,
			procedente				VARCHAR(2),
			codigo_resolucion		varchar(2),
			dictamen        		LVARCHAR,
			afectacion 			CHAR(1)
		);

		CREATE INDEX "informix".idx_tabla_cierre_preventivo_afectac ON tabla_cierre_preventivo_afectac(codigo_resolucion, folio_csuac, procedente) online;

		UPDATE STATISTICS MEDIUM FOR TABLE "informix".tabla_cierre_preventivo_afectac;
		
		-- Se crea cadana con la ruta donde se encuentra el archivo
		LET cCadena = '';
		LET cCadena = ' echo "FILE /resplogifx/repaclaraciones/'||v_nombre_archivo||' DELIMITER '|| "'" || ',' || "'" || ' 6;' || '">/resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".tabla_cierre_preventivo_afectac;' || '">> /resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		--Cargamos la informacion en la tabla de control
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /resplogifx/repaclaraciones/aclaracion.sql -l /resplogifx/repaclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		-----Se elimina script de ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/aclaracion.sql';
		system vsql; 
		---Se elimina archivo procedado de Ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/'||v_nombre_archivo||'';
		system vsql; 

	--------------------------------------------------
    -------------------------------------------------	
	--BEGIN WORK;	
	
		SELECT MAX(num_proceso)
			INTO v_num_proceso
		FROM acl_cierre_masivo;
		
		IF v_num_proceso IS NULL THEN
			LET v_num_proceso = 1;
		ELSE
			LET v_num_proceso = v_num_proceso + 1;
		END IF;
		

	
	FOREACH WITH HOLD
			
		SELECT {+AVOID_FULL(bdiaclaracion:"informix".tabla_cierre_preventivo_afectac)} folio_csuac, dictamen, bitacora,procedente,codigo_resolucion , afectacion
			INTO v_folio_csuac, v_dictamen,v_bitacora, v_procede, vcodresolucion, v_afectacion
		FROM "informix".tabla_cierre_preventivo_afectac

		
			ON EXCEPTION IN (-255)
			
			
					--ROLLBACK WORK;
				CONTINUE FOREACH;
						--SET ISOLATION TO DIRTY READ;
					--BEGIN WORK;
			END EXCEPTION WITH RESUME;
		
		
		IF v_procede = '1' THEN
				LET v_procedente = 1;
			ELIF v_procede = '0' THEN
				LET v_procedente = 0;
			END IF;
		
		SELECT pky_tipo_codigo_resolucion 
			INTO v_resolucion
		FROM acl_tipo_codigo_resolucion 
			WHERE  pky_tipo_codigo_resolucion = trim(vcodresolucion) AND tipo_procedente = v_procedente;
		
		IF (v_folio_csuac IS NULL OR v_folio_csuac = '') THEN
			CONTINUE FOREACH;
		ELIF (v_dictamen IS NULL OR v_dictamen = '') THEN 
			CONTINUE FOREACH;
		ELIF (v_bitacora IS NULL OR v_bitacora = '') THEN
			CONTINUE FOREACH;
		ELIF (v_procedente IS NULL OR v_procedente = '') THEN
			CONTINUE FOREACH;
		ELIF (v_resolucion IS NULL OR v_resolucion = '') THEN
			CONTINUE FOREACH;
		ELSE 
	----para aclaraciones procedentes
			IF v_folio_csuac is not null THEN
					CALL "informix".sp_aplica_cierre_masivo(v_folio_csuac,v_procedente,  vcodresolucion, 1, '330646', v_dictamen, v_num_proceso, v_afectacion )
					RETURNING v_cod_ret, vFolioCsuac, vResultado;
			END IF;
   
	
    ----- se inserta en bitacora el comentario correspondiente al cierre masivo
			select pky_aclaracion, fky_estatus_aclaracion, fky_estatus_corp_general into v_pky_aclaracion, v_estatus_aclaracion, v_estatus_general
			from "informix".acl_aclaracion where folio_csuac = v_folio_csuac;
	--	
			IF v_pky_aclaracion IS NOT NULL THEN
	
				INSERT INTO "informix".acl_entrada_bitacora(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
					VALUES(ENTRADA_BITACORA_SEQ.nextval, v_bitacora, CURRENT,v_folio_csuac, 26,v_pky_aclaracion, null,v_estatus_aclaracion, null, v_estatus_general, 1);
			END IF;
		
				IF (v_cod_ret is not null) THEN
					COMMIT WORK;
					
				END IF;
		
	END IF;
	END FOREACH;
	
	LET v_cod_ret = '00000';
	
----------------------------
----------------------------	
	RETURN v_cod_ret;
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'Analista    	:	Rey David Zavala Garcia',
'FECHA			: 	21/05/2020',
'Requerimiento	:	RQI 65 335',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_validafuncionalidades2(pUsuario CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
        RETURNING CHAR(5) AS codret,
                INTEGER AS sql_error,
                INTEGER AS id_permiso,
                CHAR(255) AS descripcion,
                CHAR(100) AS nombre;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iIdPermiso INTEGER;
        DEFINE cDescripcion CHAR(255);
        DEFINE cNombre CHAR(100);
        DEFINE iRegistro INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET iIdPermiso = 0;
        LET cDescripcion = '';
        LET cNombre = '';
        LET iRegistro = 0;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = '002';
                                RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre;
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_validafuncionalidades2.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion pe.pky_id_permiso,pe.descripcion,pe.nombre
                        INTO iIdPermiso,cDescripcion,cNombre
                        FROM "informix".acl_usuario AS us
                        INNER JOIN "informix".acl_perfil_usuario AS pu ON us.pky_usuario = pu.fky_usuario
                        INNER JOIN "informix".acl_perfil_permiso AS pp ON pu.fky_id_perfil = pp.fky_id_perfil
                        INNER JOIN "informix".acl_permiso AS pe ON pp.fky_id_permiso = pe.pky_id_permiso
                        WHERE us.usuario = pUsuario
                        AND pe.activo = 1
                        --AND pe.fky_origen_permiso = 3
                        ORDER BY pe.pky_id_permiso ASC

                        LET iRegistro = iRegistro + 1;
                        RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre WITH RESUME;
                END FOREACH;

                IF iRegistro = 0 THEN
                  FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion pe.pky_id_permiso ,pe.descripcion, pe.nombre 
                        INTO iIdPermiso,cDescripcion,cNombre         
                        FROM bdinteg:si_ejecut eje            
                        INNER JOIN bdiaclaracion:acl_perfil AS c ON c.pky_perfil = CASE WHEN (eje.puesto::INTEGER = 1) THEN 5 ELSE CASE WHEN (eje.puesto::INTEGER = 3 OR eje.puesto::INTEGER = 8) THEN 6 ELSE eje.puesto::INTEGER END END 
                        INNER JOIN bdiaclaracion:acl_perfil_permiso AS pp ON c.pky_perfil = pp.fky_id_perfil            
                        INNER JOIN bdiaclaracion:acl_permiso AS pe ON pp.fky_id_permiso = pe.pky_id_permiso            
                        WHERE eje.ejecutivo = pUsuario
                        AND pe.activo = 1
                        ORDER BY pe.pky_id_permiso ASC
                        
                        LET iRegistro = iRegistro + 1;
                        RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre WITH RESUME;
                   END FOREACH
                END IF;

                IF iRegistro = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre;

                ELIF iRegistro = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre;
                END IF;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 21/10/2024',
'DESCRIPCION: Procedimiento Almacenado clon de sp_validafuncionalidades, se anexa paginado de las funcionalidades',
'BASE DE DATOS: bdiaclaracion'
;

CREATE PROCEDURE "informix".sp_fal_obtener_saldo_debito(p_sNumeroCuenta CHAR(30), p_usuario CHAR(8))

     RETURNING
            MONEY(16)   AS montoActual

    --definicion de variables--
    --DEFINE resultado_codigoRetorno          CHAR(3);
    DEFINE resultado_montoActual            MONEY(16);

    DEFINE resultado_cuenta_pagare_cuenta MONEY(16);
    DEFINE resultado_cuenta_inversion_cuenta MONEY(16);

    DEFINE resultado_saldo_congelado MONEY(16);
    DEFINE resultado_cuentas MONEY(16);

    DEFINE resultado_montoTotal MONEY(16);

    DEFINE codret_blqcta_eje CHAR(6);
    DEFINE menret_blqcta_eje CHAR(250);


    DEFINE iSqlErr                          INTEGER;
    DEFINE resultado_cta_deposito CHAR(20);
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    LET resultado_cuenta_inversion_cuenta = '';
    LET resultado_cuenta_pagare_cuenta = '';

     -- Inicializacion de las variables.
    --LET resultado_codigoRetorno ='';
    LET resultado_montoActual = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/obtenerSaldoDebito_"||trim(p_sNumeroCuenta)||"_34.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                --LET resultado_codigoRetorno = '';
                LET resultado_montoActual = 0;
                RETURN resultado_montoActual;
            END IF;
        END EXCEPTION;

        LET resultado_cta_deposito = (SELECT cuenta FROM bdicheq:sc_maeinstrucc WHERE cuentadep = p_sNumeroCuenta);

        --------- CALCULO PARA INVERSION
        --select nvl(sum(monto_calculado),0)
        select case when sum(monto_calculado) is null then 0 else sum(monto_calculado) end
        INTO resultado_cuenta_inversion_cuenta
        from bdicheq:sc_maechq
        INNER JOIN fal_control_tramite fct ON (fct.cuenta_cliente_fallecido = cuenta)
        where cuenta = resultado_cta_deposito
        --where cuenta in (
            --SELECT cuenta
            --FROM bdicheq:sc_maeinstrucc
            --WHERE cuentadep = p_sNumeroCuenta)
        
        AND fct.liquida_pagare = 1
        AND fct.exitoso = 0;

        ---------- CALCULO PARA PAGARE
        --SELECT nvl(sum(monto_calculado),0)
        select case when sum(monto_calculado) is null then 0 else sum(monto_calculado) end
        INTO resultado_cuenta_pagare_cuenta
        FROM bdinvers:sv_maeinstrucc
        INNER JOIN fal_control_tramite fct ON (fct.cuenta_cliente_fallecido = cuenta)
        WHERE cuenta = resultado_cta_deposito
        --WHERE cuenta in (
            --SELECT cuenta
            --FROM bdinvers:sv_maeinstrucc
            --WHERE cta_cheques = p_sNumeroCuenta)
       
        and cap_int = 'C'
        AND fct.exitoso = 0
        AND fct.liquida_pagare = 1;

        LET resultado_cuentas = resultado_cuenta_inversion_cuenta + resultado_cuenta_pagare_cuenta;


        SELECT qc.sdo_cong
        INTO resultado_saldo_congelado
        FROM bdicheq:"informix".sc_maechq qc
        WHERE qc.cuenta = p_sNumeroCuenta;

        IF resultado_saldo_congelado > 0 THEN
            CALL bdicheq:"informix".bloqueo_cta('001',TRIM(p_sNumeroCuenta), resultado_saldo_congelado, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )
            RETURNING codret_blqcta_eje,menret_blqcta_eje;

            -- POSTERIORMENTE BLOQUEAR POR FALLECIMIENTO
            CALL bdicheq:"informix".bloqueo_cta('001',TRIM(p_sNumeroCuenta),'0','04',3,today,p_usuario,'','11','S','12','Z')
            RETURNING codret_blqcta_eje,menret_blqcta_eje;
        END IF

        --SELECT  qc.sdo_actual - (qc.sdo_retenido + qc.sdo_cong + imp_chq_sbg) as saldoTotal
        --INTO resultado_montoActual
        --FROM bdicheq:"informix".sc_maechq qc
        --WHERE qc.cuenta = p_sNumeroCuenta;
        
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo(p_sNumeroCuenta,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'T',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,resultado_montoActual;        
		
        IF resultado_cuentas > resultado_montoActual THEN
            LET resultado_montoTotal = resultado_cuentas - resultado_montoActual;
        ELSE
            LET resultado_montoTotal = resultado_montoActual - resultado_cuentas;
        END IF
        
        RETURN resultado_montoTotal;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 26-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDIACLARACION',
'VERSION: 1.0.1';

CREATE PROCEDURE "informix".sp_informacion_cuenta(v_folio CHAR(20))
RETURNING CHAR(30) AS ESTATUS, CHAR(30) AS MOTIVO, CHAR(30) AS PROCESO, CHAR(30) AS SALDO, CHAR(30) AS TIPO_PRODUCTO,
CHAR(30) AS TIPO_EVENTO, CHAR(30) AS ORIGEN, CHAR(30) AS TIPO_MOVIMIENTO, CHAR(30) AS USUARIO;

DEFINE v_numeroCuenta CHAR(20);
DEFINE v_tipoProducto CHAR(20);
DEFINE v_numeroCliente CHAR(20);
DEFINE v_aclaracion CHAR(20);
DEFINE v_area CHAR(20);
DEFINE v_estatus CHAR(20);
DEFINE v_estatusCorp CHAR(20);
DEFINE v_estatusGeneral CHAR(20);
DEFINE v_tipoEvento CHAR(20);

DEFINE estatus CHAR(10);
DEFINE motivon CHAR(10);
DEFINE proceso DATE;
DEFINE saldo MONEY;
DEFINE v_tipoMov CHAR(20);
DEFINE v_origenEvento CHAR(20);
DEFINE v_usario CHAR(50);

-- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
DEFINE cCodRet          CHAR(5);
DEFINE cMensajeRet      CHAR(50); 
DEFINE mSdoActual       MONEY(14,2);
DEFINE mSdoRetenido     MONEY(14,2);
DEFINE mSdoCong         MONEY(14,2);
DEFINE mSaldoSbc        MONEY(14,2);
DEFINE mImpSbgCcc       MONEY(14,2);


DEFINE iSqlErr INTEGER;

LET v_numeroCuenta = '';
LET v_tipoProducto = '';
LET v_numeroCliente = '';
LET v_aclaracion = '';
LET v_area = '';
LET v_estatus = '';
LET v_estatusCorp = '';
LET v_estatusGeneral = '';

LET estatus = '';
LET motivon = '';
LET saldo = 0;
LET proceso = '';
LET v_tipoEvento = '';
LET v_tipoMov = '';
LET v_origenEvento = '';
LET v_usario = '';
-- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
LET cCodRet = '00000';
LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
LET mSdoActual = 0.00;
LET mSdoRetenido = 0.00;
LET mSdoCong  = 0.00;
LET mSaldoSbc = 0.00;
LET mImpSbgCcc = 0.00;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


    BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    RETURN estatus, motivon, proceso, saldo,v_tipoProducto,v_tipoEvento,v_origenEvento,v_tipoMov ,v_usario;
                END IF;
        END EXCEPTION;    

			SELECT p.numero_cuenta, tp.tipo_producto, p.num_cliente, acl.pky_aclaracion, acl.fky_area, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_analisis, acl.fky_estatus_corp_general
            INTO v_numeroCuenta, v_tipoProducto, v_numeroCliente, v_aclaracion, v_area, v_estatus, v_estatusCorp, v_estatusGeneral
			FROM acl_aclaracion acl INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto 
			INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto WHERE folio_csuac=v_folio;
            --1=CREDITO
            --2=DEBITO
            IF v_tipoProducto == 1 THEN
--                SELECT status_cred 
--                INTO estatus
--                FROM bdicred:sd_maecred WHERE num_credito = v_numeroCuenta;

                SELECT sdo_acum_mes_cap 
                INTO saldo
                FROM bdicred:sd_maesdos WHERE num_credito = v_numeroCuenta;

                SELECT ((NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0))) disponible 
                INTO saldo
                FROM bdicred:sd_maesdos 
                WHERE empresa='001' and num_credito=v_numeroCuenta;


                SELECT id_unidad_prod, Cod_caract_2
                INTO estatus, motivon
                FROM bdicred:sd_maecred
                WHERE num_credito = v_numeroCuenta;
               FOREACH

                    SELECT fky_tipo_movimiento
                    INTO v_tipoMov
                    FROM acl_movimiento WHERE folio_csuac = v_folio ORDER BY fky_tipo_evento ASC

                    SELECT fky_origen_evento
                    INTO   v_origenEvento
                    FROM acl_tipo_movimiento WHERE pky_tipo_movimiento = v_tipoMov;

                END FOREACH;

                    SELECT num_empleado, fky_tipo_evento 
                    INTO v_usario,v_tipoEvento
                    FROM acl_aclaracion 
                    WHERE folio_csuac = v_folio;

                    LET v_tipoProducto = 'CREDITO';
            ELSE
            	---RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido, importe de cheques de sobregiro y el saldo sbc. OACM 
                SELECT status_cta, motivo, fecha_proceso, sdo_actual,sdo_retenido, sdo_cong, imp_sbg_ccc, saldo_sbc
                INTO estatus, motivon, proceso,mSdoActual,mSdoRetenido,mSdoCong,mImpSbgCcc,mSaldoSbc
                FROM bdicheq:sc_maechq WHERE cuenta = v_numeroCuenta;

                -- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
			    EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,NULL,NULL,mImpSbgCcc,'F',5) 
			    INTO cCodRet,cMensajeRet,saldo;

                FOREACH

                    SELECT fky_tipo_movimiento
                    INTO v_tipoMov
                    FROM acl_movimiento WHERE folio_csuac = v_folio ORDER BY fky_tipo_evento ASC

                    SELECT fky_origen_evento
                    INTO   v_origenEvento
                    FROM acl_tipo_movimiento WHERE pky_tipo_movimiento = v_tipoMov;

                END FOREACH;

                    SELECT num_empleado, fky_tipo_evento 
                    INTO v_usario,v_tipoEvento
                    FROM acl_aclaracion 
                    WHERE folio_csuac = v_folio;
                    LET v_tipoProducto = 'DEBITO';
            END IF;

            RETURN 'ESTATUS = '       || estatus        || '', 'MOTIVO = '          || motivon      || '',
                   'FECHA PROCESO = ' || proceso        || '', 'SALDO = '           || saldo        || '',
                   'TIPO PRODUCTO = ' || v_tipoProducto || '', 'TIPO EVENTO = '     || v_tipoEvento || '',
                   'ORIGEN EVENTO = ' || v_origenEvento || '', 'TIPO MOVIMIENTO = ' || v_tipoMov    || '',
                   'USUARIO = '       || v_usario       || '';
    END;

END PROCEDURE
DOCUMENT
'MODIFICIACION : Se agrega el saldo sbc en el saldo DISPONIBLE ',
'AUTOR : Osiel Alfredo Camacho Mendoza',
'FECHA : 17/10/2025',
'BD : bdiaclaracion';

CREATE PROCEDURE "informix".sp_desbloqueo_cuentas_aclaraciones_sin_saldo(pFolio_csuac CHAR (11),pAccion INTEGER)

RETURNING CHAR (6) AS codeRet,
          CHAR(60) AS mensajeRet;

DEFINE vNumCuenta CHAR(25);
DEFINE vTipoProducto INTEGER;
DEFINE vNumCliente CHAR(15);
DEFINE codeRet CHAR (5);
DEFINE mensajeRet CHAR(60);
DEFINE vStatusCta INTEGER;
DEFINE vMotivo CHAR (3);
DEFINE vCodigoBloqueo CHAR (3);
DEFINE vCodigoEstatus INTEGER;
DEFINE vSaldoCongelado MONEY;
DEFINE vSaldoCta MONEY;
DEFINE vStatusCred CHAR (3);
-- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
DEFINE cCodRet          CHAR(5);
DEFINE cMensajeRet      CHAR(50); 
DEFINE mSdoActual       MONEY(14,2);
DEFINE mSdoRetenido     MONEY(14,2);
DEFINE mSdoCong         MONEY(14,2);
DEFINE mSaldoSbc        MONEY(14,2);
DEFINE mImpSbgCcc       MONEY(14,2);

LET vNumCuenta = '';
LET vTipoProducto = 0;
LET vNumCliente = '';
LET codeRet = '';
LET mensajeRet = '';
LET vStatusCta = 0;
LET vMotivo = '';
LET vCodigoBloqueo = '';
LET vCodigoEstatus = 0;
LET vSaldoCongelado = 0;
LET vSaldoCta = 0;
LET vStatusCred = '';
 -- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
LET cCodRet = '00000';
LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
LET mSdoActual = 0.00;
LET mSdoRetenido = 0.00;
LET mSdoCong  = 0.00;
LET mSaldoSbc = 0.00;
LET mImpSbgCcc = 0.00;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_desbloqueo_cuentas_aclaraciones_sin_saldo"||pFolio_csuac||"_34"||".out";
--TRACE ON;

BEGIN 

SELECT p.numero_cuenta, tp.tipo_producto, p.num_cliente
    INTO vNumCuenta, vTipoProducto, vNumCliente
    FROM acl_aclaracion acl INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto 
    INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto WHERE folio_csuac=pFolio_csuac;
--ES CRÃDITO
IF vTipoProducto = 1 THEN
	SELECT status_cred, id_unidad_prod,Cod_caract_2 
    INTO vStatusCred, vStatusCta, vMotivo
    FROM bdicred:sd_maecred 
    WHERE num_credito = vNumCuenta;
	--ES DESBLOQUEO   
	IF pAccion = 0 THEN
	    --CONSULTAMOS EL CODIGO DE CUENTA BLOQUEADA
        SELECT clave 
        INTO vCodigoEstatus
        FROM bdicred:sd_bloqueoscuenta
        WHERE descripcion = 'Bloqueo disposiciones';
        --CONSULTAMOS EL MOTIVO DE BLOQUEO
        SELECT cod_causa 
        INTO vCodigoBloqueo
        FROM bdicred:sd_causa_bloqueo
        WHERE causa_bloq = 'Por aclaracion sin saldo';
		IF vCodigoBloqueo = vMotivo AND vStatusCta = vCodigoEstatus THEN
			--DESBLOQUEA LA CUENTA
            EXECUTE PROCEDURE bdicred:"informix".sp_desbloqueocuenta ('001',vNumCuenta,'0','1') INTO codeRet, mensajeRet;
            IF codeRet = '000000' THEN
                LET mensajeRet = 'DESBLOQUEO EXITOSO';
                RETURN codeRet,mensajeRet;
            END IF;
		END IF;
	--ES BLOQUEO   	
	ELIF pAccion = 1 THEN
		EXECUTE PROCEDURE bdicred:sp_bloqueocuenta ('001',TRIM(vNumCuenta),'3','10','0','1') INTO codeRet, mensajeRet;
        IF codeRet = '000000' THEN
            LET mensajeRet = 'BLOQUEO EXITOSO';
            RETURN codeRet,mensajeRet;
        END IF;
	END IF;
--ES DÃBITO
ELIF vTipoProducto = 2 THEN   
	--CONSULTAMOS EL ESTATUS DE LA CUENTA
    SELECT status_cta, motivo, sdo_cong,sdo_actual,sdo_retenido,imp_sbg_ccc,saldo_sbc
    INTO vStatusCta, vMotivo, vSaldoCongelado,mSdoActual,mSdoRetenido,mImpSbgCcc,mSaldoSbc
    FROM bdicheq:sc_maechq 
    WHERE cuenta=vNumCuenta;

    -- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
	EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,vSaldoCongelado,mSaldoSbc,NULL,NULL,mImpSbgCcc,'F',5) 
	INTO cCodRet,cMensajeRet,vSaldoCta;

	--ES DESBLOQUEO
    IF pAccion = 0 THEN
		--CONSULTAMOS EL CODIGO DE CUENTA BLOQUEADA
        SELECT cod_estatus 
        INTO vCodigoEstatus
        FROM bdicheq:sc_mae_estatus 
        WHERE descripcion = 'Bloqueada';
		--SI LA CUENTA SE ENCUENTRA BLOQUEADA
        IF vCodigoEstatus = vStatusCta THEN
			--CONSULTAMOS EL MOTIVO DE BLOQUEO
            SELECT codigo
            INTO vCodigoBloqueo
            FROM bdicheq:sc_bloqueo 
            WHERE descripcion = 'INSUFICIENCIA DE FONDOS';
			--SI EL CODIGO DE BLOQUEO ES POR INSUFICIENCIA DE SALDOS
            IF vCodigoBloqueo = vMotivo THEN 
				--DESBLOQUEA LA CUENTA DE ACUERDO AL SALDO CONGELADO
                IF (vSaldoCongelado > 0) THEN
					--DESBLOQUEA POR MONTO
                    EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta, vSaldoCongelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) INTO codeRet,mensajeRet;
                    IF codeRet = '000' THEN
                        LET mensajeRet = 'DESBLOQUEO EXITOSO';
                        RETURN codeRet,mensajeRet;
                    END IF;
				ELIF (vSaldoCongelado == 0) THEN
					-- DESBLOQUEA POR 0
                    EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta,0,'00',0,today,'0','4469','07','A','09','P' ) INTO codeRet,mensajeRet;
                    IF codeRet = '000' THEN
                        LET mensajeRet = 'DESBLOQUEO EXITOSO';
                        RETURN codeRet,mensajeRet;
                    END IF;
				END IF;
			ELSE	
				SELECT codigo
				INTO vCodigoBloqueo
				FROM bdicheq:sc_bloqueo 
				WHERE descripcion = 'POR ACLARACION';
				--SI EL CODIGO DE BLOQUEO ES POR INSUFICIENCIA DE SALDOS
				IF vCodigoBloqueo = vMotivo THEN 
					--DESBLOQUEA LA CUENTA DE ACUERDO AL SALDO CONGELADO
					IF (vSaldoCongelado > 0) THEN
						--DESBLOQUEA POR MONTO
						EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta, vSaldoCongelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) INTO codeRet,mensajeRet;
						IF codeRet = '000' THEN
							LET mensajeRet = 'DESBLOQUEO EXITOSO';
							RETURN codeRet,mensajeRet;
						END IF;
					ELIF (vSaldoCongelado == 0) THEN
						-- DESBLOQUEA POR 0
						EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta,0,'00',0,today,'0','4469','07','A','09','P' ) INTO codeRet,mensajeRet;
						IF codeRet = '000' THEN
							LET mensajeRet = 'DESBLOQUEO EXITOSO';
							RETURN codeRet,mensajeRet;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	--ES BLOQUEO   	
	ELIF pAccion = 1 THEN
		--CONSULTAMOS EL CODIGO DE CUENTA DESBLOQUEADA
        SELECT cod_estatus 
        INTO vCodigoEstatus
        FROM bdicheq:sc_mae_estatus 
        WHERE descripcion = 'Activa';
		IF vStatusCta = vCodigoEstatus THEN
			--BLOQUEA LA CUENTA DE ACUERDO AL SALDO
            IF (vSaldoCta > 0) THEN
				--DESBLOQUEA POR MONTO
				EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta, vSaldoCta, '56', 0,'20180921' , '93714475', '', '07', 'A', '12', 'Z' ) INTO codeRet,mensajeRet;
                IF codeRet = '000' THEN
                    LET mensajeRet = 'BLOQUEO EXITOSO';
                    RETURN codeRet,mensajeRet;
                END IF;
			ELIF (vSaldoCta == 0) THEN
				-- DESBLOQUEA POR 0
                EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta('001',vNumCuenta, 0, '56', 0,'20180921' , '93714475', '', '07', 'A', '12', 'Z' ) INTO codeRet,mensajeRet;
                IF codeRet = '000' THEN
                    LET mensajeRet = 'BLOQUEO EXITOSO';
                    RETURN codeRet,mensajeRet;
                END IF;
			END IF;
		END IF;
	END IF;
END IF;
END;
RETURN codeRet,mensajeRet;
END PROCEDURE
DOCUMENT
'MODIFICIACION : Se agrega el saldo sbc en el saldo DISPONIBLE ',
'AUTOR : Osiel Alfredo Camacho Mendoza',
'FECHA : 17/10/2025',
'BD : bdiaclaracion';

CREATE PROCEDURE "informix".sp_reporte_diario_cat()
	        RETURNING CHAR(06) AS resultado;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	--Variables--
	
	DEFINE cfechacaptura		DATETIME YEAR to FRACTION(5);
	DEFINE chfechacaptura		VARCHAR(16);
	DEFINE choracaptura			VARCHAR(16);
	DEFINE cfolio_csuac			VARCHAR(11);
	DEFINE cimporteoriginal     VARCHAR(16);
	DEFINE cempleado_registro	VARCHAR(9);
	DEFINE csucursal	        VARCHAR(4);
	DEFINE ctipo_movimiento     VARCHAR(20);
	DEFINE corigen_cargo        VARCHAR(20);
	DEFINE cnum_cliente			VARCHAR(9);
	DEFINE csucursal_apertura	VARCHAR(4);
	DEFINE cfecha_de_cargo	    DATE;
	DEFINE chfecha_de_cargo	    VARCHAR(16);
	DEFINE cfky_origen_evento   VARCHAR(4);
	DEFINE corigen			    VARCHAR(100);
	DEFINE cfky_tipo_evento		VARCHAR(4);
	DEFINE cevento			    VARCHAR(100);
	DEFINE ccanal	            VARCHAR(3);
	DEFINE cpreingreso          VARCHAR(11);
	
	DEFINE cfechahorallamada    VARCHAR(20);
	DEFINE cfecharesolucion     DATETIME YEAR to FRACTION(5);
	DEFINE chfecharesolucion    VARCHAR(16);
	DEFINE choraresolucion      VARCHAR(16);
	DEFINE cfolioconsecutivo    VARCHAR(15);
	DEFINE cprocede             CHAR(1);
	DEFINE cnumcte              VARCHAR(20);
	DEFINE cnumCteAnterior      VARCHAR(20);
	DEFINE cfechaCapturaTem     VARCHAR(16);
	DEFINE cfechaCaptAnterior   VARCHAR(16);
	
	DEFINE dFechaHoy            DATE;
	DEFINE iContador 			INTEGER;
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr     		INTEGER;
	DEFINE cMsjError      		CHAR(500);
	DEFINE cCodRet      		CHAR(6);
	DEFINE cCons1				CHAR(1000);
	DEFINE pArchDescarga		CHAR(150);
	DEFINE cnom_Sql				CHAR(100);
	DEFINE cSQL1				CHAR(200);
	DEFINE cRuta				CHAR(100);
	DEFINE cSQL                 CHAR(100) ;
	DEFINE cQuery			    CHAR(6000);
	DEFINE borraTabla           INTEGER;
	DEFINE borraTablaFinal      INTEGER;

	LET borraTabla			=0;
	LET borraTablaFinal		=0;
	LET cfechacaptura		= ''; --DATE(1);
	LET chfechacaptura		='';
	LET choracaptura		='';
	LET cfolio_csuac		='';
	LET cimporteoriginal    ='';
	LET cempleado_registro	='';
	LET csucursal	        ='';
	LET ctipo_movimiento    ='';
	LET corigen_cargo       ='';
	LET cnum_cliente		='';
	LET csucursal_apertura	='';
	LET cfecha_de_cargo	    = DATE(1);
	LET chfecha_de_cargo	= DATE(1);
	LET cfky_origen_evento  ='';
	LET corigen			    ='';
	LET cfky_tipo_evento	='';
	LET cevento			    ='';
	LET ccanal	            ='';
	LET cpreingreso         ='';
	LET cfechahorallamada   ='';
    LET chfecharesolucion   ='';
	LET cfecharesolucion    ='';
	LET choraresolucion     ='';
	LET cfolioconsecutivo   ='';
	LET cprocede            ='';
	LET cnumCte             ='';
	LET cnumCteAnterior     ='';
	LET cfechaCapturaTem    ='';
	LET cfechaCaptAnterior  ='';
	
	LET dFechaHoy 		= DATE(1);
	LET iContador 		= 0;
	LET cCodRet      	= '00000';
	LET iSqlErr      	= 0;
	LET iIsamErr     	= 0;
	LET cQuery			= "";
	LET cRuta		 	= "/resplogifx/repaclaraciones/";
	LET cnom_Sql 		= 'Rep_Aclaracion_CAT_' ;

--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            --LET cCodRet = iSqlErr;
			LET cCodRet = '00000';
			DROP TABLE "informix".acl_reporte_reporte_diario_cat;
			DROP TABLE "informix".acl_reporte_cat_temp;
			ROLLBACK WORK;
            --RETURN cCodRet,cMsjError;
			--RETURN cCodRet;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/repaclaraciones/reporte_diario_cat.out';
    --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

		SELECT count(*) INTO borraTabla
		FROM systables WHERE tabname ='acl_reporte_cat_temp';
		
		IF ( borraTabla > 0 ) THEN
			DROP TABLE "informix".acl_reporte_cat_temp;
		END IF;
		
		SELECT count(*) INTO borraTablaFinal
		FROM systables WHERE tabname ='acl_reporte_reporte_diario_cat';
		
		IF ( borraTablaFinal > 0 ) THEN
			DROP TABLE "informix".acl_reporte_reporte_diario_cat;
		END IF;

		BEGIN WORK;
	/* Crear tabla de descarga */
	    CREATE TABLE "informix".acl_reporte_reporte_diario_cat(
	    
	    numCte           VARCHAR(20),
	    fechahorallamada VARCHAR(25),
        folioconsecutivo VARCHAR(15),
		fecha_captura	 VARCHAR(20),
		hora_captura	 VARCHAR(20),
		folio_cs         VARCHAR(11),
		importeOriginal  VARCHAR(16),
		num_emp_registro VARCHAR(9),
		num_sucursal     VARCHAR(6),
		origen_cargo     VARCHAR(20),
		num_cliente      VARCHAR(9),
		num_suc_cta      VARCHAR(6),
		fecha_cargo   	 VARCHAR(20),
		tipo_origen      VARCHAR(4),
		origen_des       VARCHAR(100),  
		tipo_evento      VARCHAR(4),
		evento_des       VARCHAR(100),  
		canal            VARCHAR(3),
		fecharesolucion  VARCHAR(20),
		horaresolucion   VARCHAR(20),
		procede          CHAR(1),
	--	preingreso       VARCHAR(2),
		primary key (folio_cs)
		)extent size 74707 next size 11767 lock mode row;


		/* Fecha del dÃÂ­a*/
		SELECT fecha_hoy
	    into dFechaHoy
	    FROM bdinteg:"informix".si_fechas;
		-- pruebas
		--LET dFechaHoy = TODAY-8;
	
		
		SELECT  acl.num_cliente as numcte, 0 as folioconsecutivo, escor.nombre,acl.fechainicio,acl.folio_csuac,acl.importeoriginal,acl.num_empleado as empleado_registro, NVL(acl.num_sucursal,'CAT') as sucursal,
			acl.tipo_movimiento origen_cargo, -- V nacional F internacional
			acl.num_cliente, cred.sucursal as sucursal_apertura,date(mov.fechahora) as fecha_de_cargo, eve.fky_origen_evento,ori.descripcion as origen,
			acl.fky_tipo_evento, eve.descripcion as evento, can.descripcion as canal, /*, prod.numero_cuenta cuenta,tiprod.tipo_producto, tiprod.nombre*/
			acl.fecha_dictamen as fecharesolucion, acl.procede as procede
			FROM  "informix".acl_aclaracion acl
			LEFT JOIN  "informix".acl_movimiento  mov  ON mov.folio_csuac = acl.folio_csuac  AND acl.pky_aclaracion = mov.fky_aclaracion
			LEFT JOIN "informix".acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento
			LEFT JOIN "informix".acl_origen_evento ori ON ori.pky_origen_evento= eve.fky_origen_evento AND ori.activo = 1
			LEFT JOIN "informix".acl_cat_tipo_aclaracion can ON can.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion
			LEFT JOIN "informix".acl_producto prod ON ( prod.pky_producto = acl.fky_producto)
			LEFT JOIN "informix".acl_tipo_producto tiprod ON (tiprod.pky_tipo_producto = prod.fky_tipo_producto)
			LEFT JOIN  bdicred:sd_maecred cred ON (prod.numero_cuenta=cred.num_credito  AND acl.num_cliente=cred.numcte )
			LEFT JOIN "informix".acl_estatus_corporativo escor ON (acl.fky_estatus_corp_analisis = escor.pky_estatus_corporativo)
            LEFT JOIN  "informix".acl_estatus_aclaracion esacl ON (acl.fky_estatus_aclaracion = esacl.pky_estatus_aclaracion)
			WHERE  fechacaptura >= dFechaHoy -- BETWEEN today-23 AND today-22
			AND fky_estatus_aclaracion > 1 --OR (acl.fky_estatus_aclaracion = 1  AND escor.nombre = 'PRE_INGRESO'))
			AND acl.folio_csuac IS NOT NULL 
			AND tiprod.tipo_producto = 1			
            INTO acl_reporte_cat_temp;

			INSERT INTO acl_reporte_cat_temp
			SELECT acl.num_cliente as numcte, 0 as folioconsecutivo, escor.nombre,acl.fechainicio,acl.folio_csuac,acl.importeoriginal, acl.num_empleado as empleado_registro, NVL(acl.num_sucursal,'CAT') as sucursal,
			acl.tipo_movimiento origen_cargo, -- V nacional F internacional
			acl.num_cliente,cheq.sucursal as sucursal_apertura,date(mov.fechahora) as fecha_de_cargo,eve.fky_origen_evento,ori.descripcion as origen,
			acl.fky_tipo_evento, eve.descripcion as evento, can.descripcion as canal,/* ,prod.numero_cuenta cuenta,tiprod.tipo_producto, tiprod.nombre,*/
			acl.fecha_dictamen as fecharesolucion, acl.procede as procede
			FROM "informix".acl_aclaracion acl
			LEFT JOIN "informix".acl_movimiento  mov  ON mov.folio_csuac = acl.folio_csuac  AND acl.pky_aclaracion = mov.fky_aclaracion
			LEFT JOIN "informix".acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento
			LEFT JOIN "informix".acl_origen_evento ori ON ori.pky_origen_evento= eve.fky_origen_evento AND ori.activo = 1
			LEFT JOIN "informix".acl_cat_tipo_aclaracion can ON can.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion
			LEFT JOIN "informix".acl_producto prod ON ( prod.pky_producto = acl.fky_producto)
			LEFT JOIN "informix".acl_tipo_producto tiprod ON (tiprod.pky_tipo_producto = prod.fky_tipo_producto)
			LEFT JOIN bdicheq:sc_maechq cheq  ON (cheq.cuenta = prod.numero_cuenta AND cheq.num_cte = acl.num_cliente)
			LEFT JOIN  "informix".acl_estatus_corporativo escor ON (acl.fky_estatus_corp_analisis = escor.pky_estatus_corporativo)
            LEFT JOIN  "informix".acl_estatus_aclaracion esacl ON (acl.fky_estatus_aclaracion = esacl.pky_estatus_aclaracion)
			WHERE fechacaptura >= dFechaHoy -- BETWEEN today-22 AND today
			AND fky_estatus_aclaracion > 1-- OR (acl.fky_estatus_aclaracion = 1  AND escor.nombre = 'PRE_INGRESO'))
			AND acl.folio_csuac IS NOT NULL 
			AND tiprod.tipo_producto = 2;
		
	    FOREACH WITH HOLD
	        
	         SELECT numCte, folio_csuac, TO_CHAR(fechainicio,'%Y%m%d') AS fechaCapturaTem  INTO  cnumCte, cfolio_csuac, cfechaCapturaTem
			 FROM acl_reporte_cat_temp GROUP BY fechaCapturaTem, numCte, folio_csuac ORDER BY fechaCapturaTem, numCte
		
			 LET iContador = iContador + 1;
			 
			 IF cfechaCapturaTem <> cfechaCaptAnterior THEN
			    LET iContador = 1;
			 END IF;
			 
			 IF cnumCte = cnumCteAnterior AND cfechaCapturaTem = cfechaCaptAnterior THEN 
			    LET iContador = iContador - 1;
			    UPDATE acl_reporte_cat_temp SET folioconsecutivo= iContador WHERE folio_csuac = cfolio_csuac;
			 ELSE
			    UPDATE acl_reporte_cat_temp SET folioconsecutivo= iContador WHERE folio_csuac = cfolio_csuac;
			 END IF;
			 
			 LET cnumCteAnterior = cnumCte;
			 LET cfechaCaptAnterior = cfechaCapturaTem;
	    END FOREACH;
			
		LET iContador = 0;
		FOREACH WITH HOLD
            

			SELECT * INTO  cnumcte, cfolioconsecutivo, cpreingreso,cfechacaptura,cfolio_csuac,cimporteoriginal,cempleado_registro,csucursal,ctipo_movimiento,cnum_cliente,csucursal_apertura,cfecha_de_cargo,
			cfky_origen_evento,corigen,cfky_tipo_evento,cevento,ccanal, cfecharesolucion, cprocede
			FROM acl_reporte_cat_temp ORDER BY cfolio_csuac
			
			/* Formateo de Datos*/		
			
			IF cfechacaptura IS NOT NULL 
			THEN 
			LET chfechacaptura = TO_CHAR(cfechacaptura,"%d/%m/%Y");
			LET choracaptura = TO_CHAR(cfechacaptura,"%H:%M:%S");
			END IF;
			
			IF cfechacaptura IS NOT NULL
			THEN
			LET cfechahorallamada = TO_CHAR(cfechacaptura,"%d/%m/%Y %H:%M:%S");
			END IF;
			
			IF cfolioconsecutivo IS NOT NULL 
			THEN 
			LET cfolioconsecutivo = TO_CHAR(cfechacaptura,"%d%m%Y") || '_' || TRIM(cfolioconsecutivo);
			END IF;
			
			LET cfecharesolucion = cfecharesolucion;
			
			IF cfecharesolucion IS NOT NULL OR cfecharesolucion <> ''
			THEN 
			LET chfecharesolucion = TO_CHAR(cfecharesolucion,"%d/%m/%Y");
			LET choraresolucion = TO_CHAR(cfecharesolucion,"%H:%M:%S");
			ELSE
			LET chfecharesolucion = NULL;
			LET choraresolucion = NULL;
			END IF;	
			
			IF cfecha_de_cargo IS NOT NULL 
			THEN 
			LET chfecha_de_cargo = TO_CHAR(cfecha_de_cargo,"%d/%m/%Y");
			END IF;
					
			IF  ctipo_movimiento IS NOT NULL
			THEN
			LET ctipo_movimiento = DECODE(ctipo_movimiento,'V','Nacional','F','Internacional','',NULL,NULL,NULL);
			LET ctipo_movimiento = TRIM(ctipo_movimiento);
			END IF;
			
			
			/*IF  cpreingreso = 'PRE_INGRESO'
			THEN
			LET cpreingreso = 'SI';
			ELSE
			LET cpreingreso = 'NO';
			END IF;

			*/
			
			INSERT INTO acl_reporte_reporte_diario_cat(fechahorallamada, folioconsecutivo, fecha_captura, hora_captura ,folio_cs,importeOriginal,num_emp_registro,
			num_sucursal,origen_cargo,num_cliente,num_suc_cta,fecha_cargo,tipo_origen,origen_des,tipo_evento,evento_des,canal, fecharesolucion, horaresolucion, procede)
			VALUES(cfechahorallamada, cfolioconsecutivo, chfechacaptura, choracaptura ,cfolio_csuac,cimporteoriginal,cempleado_registro,csucursal,ctipo_movimiento,cnum_cliente,csucursal_apertura,chfecha_de_cargo,
			cfky_origen_evento,corigen,cfky_tipo_evento,cevento,ccanal, chfecharesolucion, choraresolucion, cprocede);
			
			LET cfechahorallamada   = NULL;
			LET cfolioconsecutivo   = NULL;
			LET cfechacaptura	    = NULL;
			LET chfechacaptura		= NULL;
			LET cfolio_csuac		= NULL;
			LET cimporteoriginal    = NULL;
            LET cempleado_registro  = NULL;
	        LET cfecha_de_cargo	    = NULL;
			LET csucursal           = NULL;
			LET ctipo_movimiento    = NULL;
			LET cnum_cliente  	    = NULL;
			LET csucursal_apertura  = NULL;
			LET cimporteoriginal    = NULL;
			LET cfky_origen_evento  = NULL;
			LET corigen				= NULL;
			LET cfky_tipo_evento    = NULL;
			LET cevento				= NULL;
			LET ccanal				= NULL;
			LET cpreingreso			= NULL;
			LET chfecharesolucion   = NULL;
			LET choraresolucion     = NULL;
			LET cfecharesolucion    = NULL;
			LET cprocede            = NULL;
					
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 

			
		END FOREACH;
		COMMIT WORK;



		/*Generacion de Reporte Diario CAT*/
		LET cCons1 = "SELECT * FROM acl_reporte_reporte_diario_cat";

	--- Reportes Salida
		LET pArchDescarga  = cnom_Sql;

		/* COMENTAR PARA PRODUCCION */
		/*******************************************/
		--LET cRuta =  '/informix/PLL/';
		/*******************************************/

		LET cnom_Sql = 'salida_reporte_diario_cat.sql';
		LET cSQL1 = '">'||TRIM(cRuta)|| cnom_Sql;

	    -- LET pArchDescarga = TRIM(pArchDescarga) || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
		LET pArchDescarga = TRIM(pArchDescarga) || lpad(year(dFechaHoy),4,'0') || lpad(month(dFechaHoy),2,'0') ||  lpad(day(dFechaHoy),2,'0') || '.txt';
				
		LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(cRuta) ||"CuerpoR.txt delimiter '|'  "||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);

	    LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
		System cQuery;

		LET cQuery = 'dbaccess bdiaclaracion ' || TRIM(cRuta) || cnom_Sql;
		SYSTEM cQuery;
        
        LET cQuery = 'echo "FechayHoraLLamada|FolioConsecutivo|FechaIngreso|HoraIngreso|FolioCSUAC|Importe|EmpleadoRegristro|Suc|OriCargo|Cte|SucCta|FechaCargo|idOrigen|DescOrigen|idEvento|DescEvento|Canal|FechaResolucion|HoraResolucion|Dictamen">' 
		|| TRIM(cRuta) || "EncabezadoR.txt";
		SYSTEM cQuery;
        
		LET cQuery =  "/usr/bin/cat " || TRIM(cRuta)||"EncabezadoR.txt " || TRIM(cRuta)||"CuerpoR.txt > " || TRIM(cRuta) || pArchDescarga;
		SYSTEM cQuery;

		LET cSQL = '';
        LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cnom_Sql);
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "CuerpoR.txt";
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "EncabezadoR.txt";
        SYSTEM cSQL;

		DROP TABLE "informix".acl_reporte_reporte_diario_cat;
		DROP TABLE "informix".acl_reporte_cat_temp;

		RETURN cCodRet;
	END;
END PROCEDURE
;