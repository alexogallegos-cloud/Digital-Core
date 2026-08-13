CREATE PROCEDURE "informix".sp_consulta_aclaracion_filtros_preingreso(
    p_Numcliente CHAR(9),
    p_Numtarjeta CHAR(16),
    p_NumCuenta CHAR(20),
    p_Telcuentamovil CHAR(13),
    p_FolioCsuac CHAR(11),
    p_Fechainicio CHAR(10),
    p_Fechafin CHAR(10),
    p_Canalingreso INTEGER,
    p_Estatusingreso INTEGER,
    p_FolioAclaracion CHAR(18))

RETURNING
    CHAR(4)  AS cCodRet,
    CHAR(60) AS pky_aclaracion,
    CHAR(11) AS fechacaptura,
    CHAR(12) AS folio_csuac,
    CHAR(60) AS nombreevento,
    CHAR(60) AS nombreorigen,
    CHAR(60) AS estatuscorporativo,
    CHAR(50) AS descingresotipoaclaracion;

-- Definicion de variables de salida
DEFINE iSqlErr INTEGER;
DEFINE v_cod_ret CHAR(4);
DEFINE estatus_corporativo INTEGER;
DEFINE cat_tipo_aclaracion INTEGER;
DEFINE indice INTEGER;
DEFINE indice_tipo_aclaracion INTEGER;
DEFINE v_pky_aclaracion CHAR(60);
DEFINE v_fechacaptura CHAR(11);
DEFINE v_folio_csuac CHAR(11);
DEFINE v_nombreevento CHAR(60);
DEFINE v_nombreorigen CHAR(60);
DEFINE v_estatuscorporativo CHAR(60);
DEFINE v_descingresotipoaclaracion CHAR(50);
DEFINE vacio CHAR(1);
--VARIABLES LOCALES
DEFINE cadenaCOncatenada CHAR(1000);
DEFINE cadenaCOncatenadatmp CHAR(1200);
DEFINE cadenaCOncatenadatmp2 CHAR(1000);
DEFINE consultaProducto SMALLINT;
DEFINE contador INTEGER;
DEFINE iRecuperacion INTEGER;

--LET iSqlErr = 0;
LET v_cod_ret = '000';
LET estatus_corporativo = 0;
LET cat_tipo_aclaracion = 0;
LET indice = 0;
LET indice_tipo_aclaracion = 0;
LET v_pky_aclaracion='';
LET v_fechacaptura='';
LET v_folio_csuac='';
LET v_nombreevento='';
LET v_nombreorigen='';
LET v_estatuscorporativo='';
LET v_descingresotipoaclaracion='';
LET contador=0;
LET cadenaConcatenada='';
LET cadenaCOncatenadatmp='';
LET cadenaCOncatenadatmp2='';
LET iRecuperacion = 0;
LET vacio = '*';

--set debug file to "/home/rtechno/sp_consulta_aclaracion_filtros_preingreso.out";
--trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION 
            SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET v_cod_ret = iSqlErr;
                    LET v_pky_aclaracion='';
                    LET v_fechacaptura='';
                    LET v_folio_csuac='';
                    LET v_nombreevento='';
                    LET v_nombreorigen='';
                    LET v_estatuscorporativo='';
                    LET v_descingresotipoaclaracion='';
                    RETURN '*'||v_cod_ret,'*'||v_pky_aclaracion, '*'||v_fechacaptura, '*'||v_folio_csuac, '*'||v_nombreevento,'*'||v_nombreorigen, '*'||v_estatuscorporativo, '*'||v_descingresotipoaclaracion||'*';
                END IF;
        END EXCEPTION;

-- INICIALIZACION DE VALIDACION 

LET p_Numcliente =      CASE WHEN length(p_Numcliente)>0 THEN p_Numcliente ELSE NULL END;
LET p_Numtarjeta =      CASE WHEN length(p_Numtarjeta)>0 THEN p_Numtarjeta ELSE NULL END;
LET p_NumCuenta =       CASE WHEN length(p_NumCuenta)>0 THEN p_NumCuenta ELSE NULL END;
LET p_Telcuentamovil =  CASE WHEN (length(p_Telcuentamovil)>0 AND  p_Telcuentamovil IS NOT NULL ) THEN p_Telcuentamovil ELSE NULL END;
LET p_FolioCsuac =      CASE WHEN length(p_FolioCsuac)>0 THEN p_FolioCsuac ELSE NULL END;
LET p_Fechainicio =     CASE WHEN length(p_Fechainicio)>0 THEN p_Fechainicio ELSE NULL END;
LET p_Fechafin =        CASE WHEN length(p_Fechafin)>0 THEN p_Fechafin ELSE NULL END;
LET p_Canalingreso =    CASE WHEN (p_Canalingreso) > 0 THEN p_Canalingreso ELSE NULL END;
LET p_Estatusingreso=   CASE WHEN (p_Estatusingreso) > 0 THEN p_Estatusingreso ELSE NULL END;

LET p_FolioAclaracion = CASE WHEN length(p_FolioAclaracion)>0 THEN p_FolioAclaracion ELSE NULL END;

--VALIDANDO TIPO DE QUERY A UTILIZAR
IF(p_Numtarjeta IS NOT NULL OR p_NumCuenta IS NOT NULL OR p_Telcuentamovil IS NOT NULL)THEN
    LET consultaProducto = 1;
ELSE
    LET consultaProducto =0;
END IF;

--VALIDANDO CLIENTE
IF (p_Numcliente IS NOT NULL ) THEN 
        LET cadenaCOncatenadatmp =  ' AND acl.num_cliente ="'|| TRIM(p_Numcliente)||'"';
END IF;    

--VALIDANDO NUMERO DE TARJETA
IF (p_Numtarjeta IS NOT NULL ) THEN 
        LET cadenaCOncatenadatmp =  ' AND pr.numero_tarjeta="'|| TRIM(p_Numtarjeta)||'"'||cadenaCOncatenadatmp;
END IF;

--VALIDANDO NUMERO DE CUENTA
IF (p_NumCuenta IS NOT NULL ) THEN 
    LET cadenaCOncatenadatmp =  ' AND pr.numero_cuenta="'|| TRIM(p_NumCuenta)||'"'||cadenaCOncatenadatmp;
END IF;

--VALIDANDO CUENTA MOVIL
IF(p_Telcuentamovil IS NOT NULL) THEN
    LET cadenaCOncatenadatmp =  ' AND pr.telefonotransfer="'|| TRIM(p_Telcuentamovil)||'"'||cadenaCOncatenadatmp;
END IF;

--VALIDANDO FOLIO_CSUAC
IF(p_FolioCsuac IS NOT NULL) THEN
    LET cadenaCOncatenadatmp =  ' AND acl.folio_csuac="'|| TRIM(p_FolioCsuac)||'"'||cadenaCOncatenadatmp;
END IF;

--VALIDANDO FOLIO_ACLARACION
IF(p_FolioAclaracion IS NOT NULL) THEN
    LET cadenaCOncatenadatmp =  ' AND facl.folio_aclaracion="'|| TRIM(p_FolioAclaracion)||'"'||cadenaCOncatenadatmp;
END IF;

--VALIDANDO FECHAS
IF(p_Fechainicio IS NOT NULL AND p_Fechafin IS NOT NULL ) THEN
    LET cadenaCOncatenadatmp =  " AND acl.fechacaptura BETWEEN  TO_DATE ('" || p_Fechainicio || "','%d-%m-%Y') AND TO_DATE('" ||  p_Fechafin || "','%d-%m-%Y') "||cadenaCOncatenadatmp;
END IF;

--VALIDANDO CANAL INGRESO
IF(p_Canalingreso IS NOT NULL ) THEN
    LET cadenaCOncatenadatmp =  ' AND acl.fky_cat_tipo_aclaracion='|| (p_Canalingreso)||cadenaCOncatenadatmp;
ELSE   
    LET cadenaCOncatenadatmp = ')' || cadenaCOncatenadatmp;
    FOREACH SELECT --+INDEX(acl_cat_tipo_aclaracion "informix".idx_acl_cat_tipo_aclaracion_nombre)
    pky_cat_tipo_aclaracion INTO cat_tipo_aclaracion FROM acl_cat_tipo_aclaracion WHERE nombre <> "ACLARACION_VIA_TELEFONIICA"  AND nombre <> "ACLARACION_VIA_TELEFONICA_TRAN" -- nombre <> "ACLARACION_VIA_SUCURSAL" AND       --AND nombre <> "ACLARACION_VIA_CORPORATIVO"  

      IF(indice_tipo_aclaracion <> 0) THEN
        LET cadenaCOncatenadatmp =  ' OR acl.fky_cat_tipo_aclaracion='|| (cat_tipo_aclaracion)||cadenaCOncatenadatmp;
      END IF;

      IF (indice_tipo_aclaracion = 0) THEN
        LET cadenaCOncatenadatmp2 =  ' acl.fky_cat_tipo_aclaracion='|| (cat_tipo_aclaracion);
      END IF;
      LET indice_tipo_aclaracion = indice_tipo_aclaracion + 1;
    END FOREACH
    --LET cadenaCOncatenadatmp =  ' AND (acl.fky_cat_tipo_aclaracion='|| (cat_tipo_aclaracion)||cadenaCOncatenadatmp;
    LET cadenaCOncatenadatmp = ' AND(' || TRIM(cadenaCOncatenadatmp2) || cadenaCOncatenadatmp;
END IF;

--VALIDANDO ESTATUS INGRESO
IF(p_Estatusingreso IS NOT NULL ) THEN
    LET cadenaCOncatenadatmp =  ' AND acl.fky_estatus_corp_analisis='|| (p_Estatusingreso)||cadenaCOncatenadatmp;
ELSE
    LET cadenaCOncatenadatmp = ')' || cadenaCOncatenadatmp;
    FOREACH SELECT pky_estatus_corporativo INTO estatus_corporativo  FROM acl_estatus_corporativo WHERE nombre IN ("PRE_INGRESO", "DECLINADA")
      IF(indice = 0) THEN
        LET cadenaCOncatenadatmp =  ' OR acl.fky_estatus_corp_analisis='|| (estatus_corporativo)||cadenaCOncatenadatmp;
      ELSE
       LET cadenaCOncatenadatmp =  ' AND (acl.fky_estatus_corp_analisis='|| (estatus_corporativo)||cadenaCOncatenadatmp;
      END IF;
      LET indice = indice + 1;
    END FOREACH
    
END IF;

IF(consultaProducto = '0') THEN
    IF(p_FolioAclaracion IS NOT NULL) THEN
        LET cadenaCOncatenadatmp = 'SELECT acl.pky_aclaracion,acl.fechacaptura,acl.folio_csuac,evento.descripcion evento,ori.descripcion origen,ecorp.descripcion estatusCorp,tipo_aclaracion.descripcion tipoingreso FROM acl_aclaracion acl RIGHT JOIN acl_tipo_evento evento ON evento.pky_tipo_evento=acl.fky_tipo_evento RIGHT JOIN acl_origen_evento ori ON ori.pky_origen_evento = evento.fky_origen_evento RIGHT JOIN acl_estatus_corporativo ecorp ON ecorp.pky_estatus_corporativo=acl.fky_estatus_corp_analisis RIGHT JOIN acl_cat_tipo_aclaracion tipo_aclaracion ON tipo_aclaracion.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion RIGHT JOIN acl_folio_aclaracion_acl_aclaracion facl ON facl.fky_aclaracion=acl.pky_aclaracion WHERE 1=1'||cadenaCOncatenadatmp;   
    ELSE
        LET cadenaCOncatenadatmp = 'SELECT acl.pky_aclaracion,acl.fechacaptura,acl.folio_csuac,evento.descripcion evento,ori.descripcion origen,ecorp.descripcion estatusCorp,tipo_aclaracion.descripcion tipoingreso FROM acl_aclaracion acl RIGHT JOIN acl_tipo_evento evento ON evento.pky_tipo_evento=acl.fky_tipo_evento RIGHT JOIN acl_origen_evento ori ON ori.pky_origen_evento = evento.fky_origen_evento RIGHT JOIN acl_estatus_corporativo ecorp ON ecorp.pky_estatus_corporativo=acl.fky_estatus_corp_analisis RIGHT JOIN acl_cat_tipo_aclaracion tipo_aclaracion ON tipo_aclaracion.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion WHERE 1=1'||cadenaCOncatenadatmp;
    END IF
ELSE
    IF(p_FolioAclaracion IS NOT NULL) THEN
        LET cadenaCOncatenadatmp = 'SELECT acl.pky_aclaracion,acl.fechacaptura,acl.folio_csuac,evento.descripcion evento,ori.descripcion origen,ecorp.descripcion estatusCorp,tipo_aclaracion.descripcion tipoingreso FROM acl_aclaracion acl RIGHT JOIN acl_tipo_evento evento ON evento.pky_tipo_evento=acl.fky_tipo_evento RIGHT JOIN acl_origen_evento ori ON ori.pky_origen_evento = evento.fky_origen_evento RIGHT JOIN acl_estatus_corporativo ecorp ON ecorp.pky_estatus_corporativo=acl.fky_estatus_corp_analisis RIGHT JOIN acl_producto pr ON pr.pky_producto=acl.fky_producto RIGHT JOIN acl_cat_tipo_aclaracion tipo_aclaracion ON tipo_aclaracion.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion RIGHT JOIN acl_folio_aclaracion_acl_aclaracion facl ON facl.fky_aclaracion=acl.pky_aclaracion WHERE 1=1'||cadenaCOncatenadatmp;
    ELSE
        LET cadenaCOncatenadatmp = 'SELECT acl.pky_aclaracion,acl.fechacaptura,acl.folio_csuac,evento.descripcion evento,ori.descripcion origen,ecorp.descripcion estatusCorp,tipo_aclaracion.descripcion tipoingreso FROM acl_aclaracion acl RIGHT JOIN acl_tipo_evento evento ON evento.pky_tipo_evento=acl.fky_tipo_evento RIGHT JOIN acl_origen_evento ori ON ori.pky_origen_evento = evento.fky_origen_evento RIGHT JOIN acl_estatus_corporativo ecorp ON ecorp.pky_estatus_corporativo=acl.fky_estatus_corp_analisis RIGHT JOIN acl_producto pr ON pr.pky_producto=acl.fky_producto RIGHT JOIN acl_cat_tipo_aclaracion tipo_aclaracion ON tipo_aclaracion.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion WHERE 1=1'||cadenaCOncatenadatmp;
    END IF;
END IF;


PREPARE stmt_id FROM cadenaCOncatenadatmp;
DECLARE cust_cur cursor FOR stmt_id;

OPEN cust_cur;

WHILE (1 = 1)

FETCH cust_cur INTO v_pky_aclaracion, v_fechacaptura, v_folio_csuac, v_nombreevento,v_nombreorigen, v_estatuscorporativo, v_descingresotipoaclaracion;
  IF (SQLCODE != 100) THEN
    LET iRecuperacion = iRecuperacion + 1;
    RETURN '*'||v_cod_ret, '*'||v_pky_aclaracion, '*'||v_fechacaptura, '*'||v_folio_csuac, '*'||v_nombreevento,'*'||v_nombreorigen, '*'||v_estatuscorporativo, '*'||v_descingresotipoaclaracion WITH RESUME;
  ELSE
    EXIT;
  END IF
END WHILE
CLOSE cust_cur;
FREE cust_cur;
FREE stmt_id ;

END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃÂ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Mayo/2019',
'Requerimiento	:	RQI 65 378; RQM 06 626',
'VERSION		: 	2.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_detalle_aclaracion_canales(
                        pIdAclaracion INTEGER)
	
	RETURNING
		CHAR(5)				AS cod_ret,
		CHAR(20)			AS v_numero_cuenta,
		CHAR(16)			AS v_numero_tarjeta,
		CHAR(18)			AS v_folio_aclaracion,
		CHAR(11)			AS v_folio_csuac,
		INTEGER				AS v_id_flujo,
		CHAR(50)			AS v_flujo,
		INTEGER				AS v_id_origen_evento,
		CHAR(50)			AS v_origen_evento,
		INTEGER				AS v_id_evento,
		CHAR(50)			AS v_evento,
		DATE				AS v_fecha_aclaracion,
		DATETIME YEAR to FRACTION(5)	AS v_fecha_cargo,
		DATETIME YEAR to FRACTION(5)	AS v_fecha_consumo,
		CHAR(50)			AS v_producto,
		CHAR(30)			AS v_folio_suc,
		CHAR(23)			AS v_referencia23,
		CHAR(40)			AS v_refcomercio,
		SMALLINT			AS v_tiene_abono_temporal,
		DATE				AS v_fecha_abono_temporal,
		MONEY				AS v_importereclamado,
		MONEY				AS v_importeaceptado,
		MONEY				AS v_importeoriginal,
		INTEGER				AS v_dias_faltantes,
		CHAR(50)			AS v_estatus_canales,
		DATE				AS v_fecha_dictamen,
		SMALLINT			AS procede,
		INTEGER				AS v_id_etapa_canales;
		
		
	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_cod_ret_estatus			CHAR(5);
	DEFINE v_numero_cuenta				CHAR(20);
	DEFINE v_numero_tarjeta				CHAR(16);
	DEFINE v_folio_aclaracion			CHAR(18);
	DEFINE v_folio_csuac				CHAR(11);
	DEFINE v_id_flujo					INTEGER;
	DEFINE v_flujo						CHAR(50);
	DEFINE v_id_origen_evento			INTEGER;
	DEFINE v_origen_evento				CHAR(50);
	DEFINE v_id_evento					INTEGER;
	DEFINE v_evento						CHAR(50);
	DEFINE v_fecha_aclaracion			DATE;
	DEFINE v_fecha_movimiento			DATETIME YEAR to FRACTION(5);
	DEFINE v_fecha_consumo				DATETIME YEAR to FRACTION(5);
	--DEFINE v_fecha_mov					DATE;
	DEFINE v_producto					CHAR(50);
	DEFINE v_folio_suc					CHAR(30);
	DEFINE v_referencia23				CHAR(23);
	DEFINE v_refcomercio				CHAR(40);
	DEFINE v_importereclamado			MONEY;
	DEFINE v_importeaceptado			MONEY;
	DEFINE v_importeoriginal			MONEY;
	DEFINE v_resp_estimada				INTEGER;
	DEFINE v_resp_estimada_intl			INTEGER;
	DEFINE v_fechahora_dictamen			DATETIME YEAR to FRACTION(5);
	DEFINE v_fecha_dictamen				DATE;
	DEFINE v_procede					SMALLINT;
	DEFINE v_es_nacional				CHAR(1);
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_corp_gral			INTEGER;
	DEFINE v_estatus_corp_analisis		INTEGER;
	
	DEFINE c_estatus_pre_ingreso		CHAR(50);
	DEFINE c_id_estatus_pre_ingreso		INTEGER;
	DEFINE c_estatus_declinado			CHAR(50);
	DEFINE c_id_estatus_declinado		INTEGER;
	DEFINE v_estatus_canales			CHAR(50);
	DEFINE v_concatena_dictamen			SMALLINT;
	DEFINE v_id_etapa_canales			INTEGER;
	DEFINE v_desc_etapa_canales			CHAR(20);
	
	DEFINE c_nombre_abono				CHAR(50);
	DEFINE c_id_abono					INTEGER;
	DEFINE v_tiene_abono_temporal		SMALLINT;
	DEFINE v_fechahora_abono_temporal	DATETIME YEAR to FRACTION(5);
	DEFINE v_fecha_abono_temporal		DATE;
	
	DEFINE c_fecha_actual				DATE;
	DEFINE v_dias_faltantes				INTEGER;
	
	LET v_cod_ret 						= "00000";
	LET v_cod_ret_estatus				= "00000";
	LET v_numero_cuenta					= NULL;
	LET v_numero_tarjeta				= NULL;
	LET v_folio_aclaracion				= NULL;
	LET v_folio_csuac					= NULL;
	LET v_id_flujo						= NULL;
	LET v_flujo							= NULL;
	LET v_id_origen_evento				= NULL;
	LET v_origen_evento					= NULL;
	LET v_id_evento						= NULL;
	LET v_evento						= NULL;
	LET v_fecha_aclaracion				= NULL;
	LET v_fecha_movimiento				= NULL;
	LET v_fecha_consumo					= NULL;
	--LET v_fecha_mov						= NULL;
	LET v_producto						= NULL;
	LET v_folio_suc						= NULL;
	LET v_referencia23					= NULL;
	LET v_refcomercio					= NULL;
	LET v_importereclamado				= NULL;
	LET v_importeaceptado				= NULL;
	LET v_importeoriginal				= NULL;
	LET v_resp_estimada					= NULL;
	LET v_resp_estimada_intl			= NULL;
	LET v_fechahora_dictamen			= NULL;
	LET v_fecha_dictamen				= NULL;
	LET v_procede						= NULL;
	LET v_es_nacional					= NULL;
	LET v_estatus_aclaracion			= NULL;	
	LET v_estatus_corp_gral				= NULL;	
	LET v_estatus_corp_analisis			= NULL;
	
	LET c_estatus_pre_ingreso			= 'PRE_INGRESO';
	LET c_id_estatus_pre_ingreso		= NULL;
	LET c_estatus_declinado				= 'DECLINADA';
	LET c_id_estatus_declinado			= NULL;
	LET v_estatus_canales				= NULL;
	LET v_concatena_dictamen			= NULL;
		
	LET c_nombre_abono					= 'autorizarAbono'; 
	LET c_id_abono						= NULL;
	LET v_tiene_abono_temporal			= 0;
	LET v_fechahora_abono_temporal		= NULL;
	LET v_fecha_abono_temporal			= NULL;
	
	LET c_fecha_actual					= NULL;
	LET v_dias_faltantes				= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				RETURN v_cod_ret, v_numero_cuenta, v_numero_tarjeta, v_folio_aclaracion, v_folio_csuac, v_id_flujo, v_flujo, 
					v_id_origen_evento, v_origen_evento, v_id_evento, v_evento, v_fecha_aclaracion, v_fecha_movimiento, v_fecha_consumo, v_producto, 
					v_folio_suc, v_referencia23, v_refcomercio, v_tiene_abono_temporal, v_fecha_abono_temporal, v_importereclamado, 
					v_importeaceptado, v_importeoriginal, v_dias_faltantes, v_estatus_canales, v_fecha_dictamen, v_procede, v_id_etapa_canales;
			END IF;
		END EXCEPTION;
		
		--Se obtiene la fecha actual
		
		SELECT fecha_hoy 
			INTO c_fecha_actual
		FROM bdinteg:si_fechas;
		
		SELECT prod.numero_cuenta, prod.numero_tarjeta, facl.folio_aclaracion, acl.folio_csuac, te.fky_tipo_flujo, tf.descripcion as flujo, 
				oe.pky_origen_evento, oe.descripcion as origen_evento, te.pky_tipo_evento, te.descripcion as evento, acl.fechacaptura, mov.fechahora,
				prod.descripcion as producto, mov.folio_suc, mov.referencia23, mov.ref_comercio, acl.importereclamado, acl.importerecibido, 
				acl.importeoriginal, ri.resp_estimada, ri.resp_estimada_intl, acl.fecha_dictamen, acl.procede, acl.tipo_movimiento, 
				acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, acl.fky_estatus_corp_analisis, mov.fecha_consumo
			INTO v_numero_cuenta, v_numero_tarjeta, v_folio_aclaracion, v_folio_csuac, v_id_flujo, v_flujo, 
				v_id_origen_evento, v_origen_evento, v_id_evento, v_evento, v_fecha_aclaracion, v_fecha_movimiento,
				v_producto, v_folio_suc, v_referencia23, v_refcomercio, v_importereclamado, v_importeaceptado, 
				v_importeoriginal, v_resp_estimada, v_resp_estimada_intl, v_fechahora_dictamen, v_procede, v_es_nacional, 
				v_estatus_aclaracion, v_estatus_corp_gral, v_estatus_corp_analisis, v_fecha_consumo
		FROM acl_aclaracion acl
			Inner Join acl_producto prod on acl.fky_producto = prod.pky_producto
			Left Outer Join acl_folio_aclaracion_acl_aclaracion facl on facl.fky_aclaracion = acl.pky_aclaracion
			Inner Join acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
			Inner Join acl_tipo_flujo tf on te.fky_tipo_flujo = tf.pky_tipo_flujo
			Inner Join acl_origen_evento oe on oe.pky_origen_evento = te.fky_origen_evento
			Left Outer Join acl_movimiento mov on acl.pky_aclaracion = mov.fky_aclaracion and duplicado = 0 and fky_padre is null
			Left Outer Join acl_rango_importe ri on ri.fky_id_regla = fky_regla_negocio and 
				acl.importereclamado between ri.rango_menor and ri.rango_mayor 
		WHERE pky_aclaracion = pIdAclaracion;
		
		--Se ajustan las fechas del movimiento y dictamen a tipo Date
		--LET v_fecha_mov = DATE(v_fecha_movimiento);
		LET v_fecha_dictamen = DATE(v_fechahora_dictamen);
		LET v_folio_aclaracion = NVL(v_folio_aclaracion,'');
		
		--Se obtiene la acciÃ³n correspondiente al Abono Temporal
		SELECT pky_resolucion
			INTO c_id_abono
		FROM acl_resolucion 
		WHERE nombre = 'autorizarAbono' AND activo = 1;
		
		--Se busca el Abono Temporal
		SELECT FIRST 1 1, fechahora
			INTO v_tiene_abono_temporal, v_fechahora_abono_temporal
		FROM acl_entrada_bitacora
		WHERE fky_accion = c_id_abono
			AND fky_aclaracion = pIdAclaracion;
		
		LET v_tiene_abono_temporal = NVL(v_tiene_abono_temporal,0);
		
		--Se ajusta la fecha del Abono temporal a tipo Date
		LET v_fecha_abono_temporal = DATE(v_fechahora_abono_temporal);
		
		SELECT pky_estatus_corporativo 
			INTO c_id_estatus_declinado
		FROM acl_estatus_corporativo 
		WHERE nombre = c_estatus_declinado AND fky_tipo_estatus = 2 
			AND activo = 1;
		
		--Si la AclaraciÃ³n se encuentra dictaminada, los dÃ­as faltantes de atenciÃ³n son 0
		IF v_fecha_dictamen IS NOT NULL THEN
			LET v_dias_faltantes = 0;
			--Se valida que si el estatus es declinado, no se consideren dÃ­as faltantes
		ELIF v_estatus_aclaracion = 1 AND v_estatus_corp_analisis = c_id_estatus_declinado THEN
			LET v_dias_faltantes = 0;
			--Se calculan los dÃ­as faltantes para la atenciÃ³n de la aclaraciÃ³n, validando si el movimiento es Internacional, 
				--sino se cuenta con la informaciÃ³n, se considerarÃ¡ Nacional
		ELSE
			IF v_es_nacional = 'F' THEN
				LET v_dias_faltantes = (v_resp_estimada_intl - 1) - (c_fecha_actual - v_fecha_aclaracion);
			ELIF v_es_nacional = 'V' THEN
				LET v_dias_faltantes =  (v_resp_estimada - 1) - (c_fecha_actual - v_fecha_aclaracion);
			ELSE
				LET v_dias_faltantes = (v_resp_estimada - 1) - (c_fecha_actual - v_fecha_aclaracion);
			END IF;
		END IF;
		
		--Se obtiene el valor del estatus corporativo Pre-Ingreso de tipo anÃ¡lisis
		SELECT pky_estatus_corporativo 
			INTO c_id_estatus_pre_ingreso
		FROM acl_estatus_corporativo 
		WHERE nombre = c_estatus_pre_ingreso AND fky_tipo_estatus = 2 
			AND activo = 1;
			
		CALL sp_obten_estatus_canales(v_estatus_aclaracion, v_estatus_corp_gral, v_estatus_corp_analisis)
				RETURNING  v_cod_ret_estatus, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
		
		IF v_concatena_dictamen = 1 THEN
			IF v_procede = 1 THEN
				LET v_estatus_canales = TRIM(v_estatus_canales) || ' Procedente';
			ELIF v_procede = 0 THEN
				LET v_estatus_canales = TRIM(v_estatus_canales) || ' No Procedente';
			END IF;
		END IF;
		
		LET v_importereclamado = NVL(v_importereclamado,0);
		LET v_importeaceptado = NVL(v_importeaceptado,0);
		LET v_importeoriginal = NVL(v_importeoriginal,0);
		
		RETURN
			v_cod_ret, v_numero_cuenta, v_numero_tarjeta, v_folio_aclaracion, v_folio_csuac, v_id_flujo, v_flujo, 
				v_id_origen_evento, v_origen_evento, v_id_evento, v_evento, v_fecha_aclaracion, v_fecha_movimiento, v_fecha_consumo, v_producto, 
				v_folio_suc, v_referencia23, v_refcomercio, v_tiene_abono_temporal, v_fecha_abono_temporal, v_importereclamado, 
				v_importeaceptado, v_importeoriginal, v_dias_faltantes, v_estatus_canales, v_fecha_dictamen, v_procede, v_id_etapa_canales;
		
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones BPI',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Noviembre/2018',
'Requerimiento	:	RQM 06 626',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_eliminacion_puntos_coppel()
	RETURNING CHAR(5) AS codigo_ret;

	-- DEFINICION DE VARIABLES --

	DEFINE iSqlError 					INTEGER;
	DEFINE iIsamError     		        INTEGER;
	DEFINE cMsjError      		        CHAR(500);
	DEFINE cCodRet              		CHAR(6);
	DEFINE cCons1				        CHAR(1000);
	DEFINE cArchDescarga		        CHAR(150);
	DEFINE cExtArchDesc					CHAR(4);
	DEFINE cNom_Sql				        CHAR(100);
	DEFINE cSQL1				        CHAR(200);
	DEFINE cRuta				        CHAR(100);
	DEFINE cSQL                         CHAR(100) ;
	DEFINE cQuery			            CHAR(3000);

	DEFINE iTempTable        			INTEGER;
	DEFINE dFechaHoy     				DATE;
	DEFINE v_folio_csuac 				VARCHAR(11);
	DEFINE v_pky_aclaracion 			INTEGER;
	DEFINE v_fechacargo                 VARCHAR(10);
	DEFINE v_numcuenta                  VARCHAR(20);
	DEFINE v_numcliente                 VARCHAR(9);
	DEFINE v_montopro                   VARCHAR(20);
	DEFINE v_producto                   VARCHAR(11);
	DEFINE v_referencia23               VARCHAR(23);
	DEFINE iContador  					INTEGER;

	DEFINE iMaxId						INTEGER;
	DEFINE c_numcte                     CHAR(40);
	DEFINE c_producto                   CHAR(40);
	DEFINE c_num_credito                CHAR(40);
	DEFINE d_monto_diario               DECIMAL(16,2);
	DEFINE c_periodo                    CHAR(40);
	DEFINE d_fecha                      DATE;
	DEFINE b_estatus_calculo            BOOLEAN;
	DEFINE c_origen                     CHAR(40);
	DEFINE c_moneda                     CHAR(40);
	DEFINE c_referencia23               CHAR(40);
	DEFINE c_nombre_comercio            CHAR(80);
	DEFINE v_folio_suc					VARCHAR(30);
	DEFINE v_fky_producto				INTEGER;
	DEFINE v_id							INTEGER;
	DEFINE v_tipo_evento				INTEGER;
	-- INICIALIZACION DE VARIABLES --

	LET iSqlError      					= 0;
	LET iIsamError     					= 0;
	LET cMsjError						= '';
	LET cCodRet 						= '00000';
	LET cCons1				         	= '';
	LET cArchDescarga		         	= 'PUNTOS_COPPEL_MAX_';
	LET cExtArchDesc					= '.unl';
	LET cNom_Sql				     	= '';
	LET cSQL1				         	= '';
	LET cRuta				         	= '/resplogifx/repaclaraciones/';
	LET cSQL                         	= '';
	LET cQuery			             	= '';

	LET iTempTable  					= NULL;
	LET dFechaHoy		    		    = '';
	LET v_folio_csuac 					= '';
	LET v_pky_aclaracion 				= '';
	LET v_fechacargo                    = '';
	LET v_numcuenta                     = '';
	LET v_numcliente                    = '';
	LET v_montopro                      = '';
	LET v_producto                      = '';
	LET v_referencia23                  = '';
	LET iContador 						= 0;

	LET iMaxId							= NULL;
	LET c_numcte                        = '';
	LET c_producto                      = '';
	LET c_num_credito                   = '';
	LET d_monto_diario                  = 0.00;
	LET c_periodo                       = '';
	LET d_fecha                         = '';
	LET b_estatus_calculo               = NULL;
	LET c_origen                        = '';
	LET c_moneda                        = '';
	LET c_referencia23                  = '';
	LET c_nombre_comercio               = '';
	LET v_folio_suc						= '';
	LET v_fky_producto					= NULL;
	LET v_id							= '';
	LET v_tipo_evento					= NULL;
	BEGIN
		ON EXCEPTION SET iSqlError, iIsamError, cMsjError
			IF iSqlError <> 0 THEN
				LET cCodRet = iSqlError;
				ROLLBACK WORK;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/resplogifx/RD/sp_eliminacion_puntos_coppel.out";
		--TRACE ON;

		-- SE VALIDA LA CREACION DE TABLA PARA EL LLENADO DEL ARCHIVO

		SELECT tabid
		INTO iTempTable
		FROM systables WHERE tabname = 'tabla_valida_puntos_coppel';

		IF iTempTable IS NOT NULL THEN
			DROP TABLE "informix".tabla_valida_puntos_coppel;
		END IF;

		CREATE TABLE "informix".tabla_valida_puntos_coppel(
			foliocsuac 		VARCHAR(11),
			fechacargo 		VARCHAR(10),
			numcuenta 		VARCHAR(20),
			numcliente 		VARCHAR(9),
			montopro 		VARCHAR(20),
			producto 		VARCHAR(11),
			referencia23 	VARCHAR(23),
			folio_suc 		VARCHAR(20),
			indicador		CHAR(1)
		);

		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas;
		LET iContador = 0;

		BEGIN WORK;

			FOREACH WITH HOLD

				SELECT acl.folio_csuac, acl.pky_aclaracion, acl.fky_producto, acl.montoprocedente,  acl.num_cliente, acl.fky_tipo_evento
					INTO v_folio_csuac, v_pky_aclaracion, v_fky_producto, v_montopro, v_numcliente, v_tipo_evento
				FROM bdiaclaracion:"informix".acl_aclaracion acl 
				--INNER JOIN bdiaclaracion:"informix".acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
					WHERE acl.procede = '1' AND acl.fky_tipo_evento IN ('180','181','182','183','184','189','197','200','244') 
					/*AND te.activo = 1*/ AND date(acl.fecha_dictamen) = dFechaHoy
				
				--IF v_tipo_evento IN ('180','181','182','183','184','189','197','200','244') THEN
					SELECT DATE(mov.fecha_consumo) AS fechahora, mov.referencia23, mov.folio_suc
						INTO v_fechacargo, v_referencia23, v_folio_suc
					FROM bdiaclaracion:"informix".acl_movimiento mov
						WHERE mov.folio_csuac = v_folio_csuac AND mov.fky_aclaracion = v_pky_aclaracion
						AND mov.exitoso = 1 AND mov.duplicado = 0 AND mov.fky_padre IS NULL;
					
					SELECT tp.producto, pro.numero_cuenta
						INTO c_producto, v_numcuenta 
					FROM bdiaclaracion:"informix".acl_producto pro --ON acl.fky_producto = pro.pky_producto
					INNER JOIN bdiaclaracion:"informix".acl_tipo_producto tp ON pro.fky_tipo_producto = tp.pky_tipo_producto
						WHERE tp.activo = 1 AND pro.pky_producto = v_fky_producto;
					
					
					
					IF c_producto IN('8100','6001') THEN
					
						IF v_referencia23 <> '' THEN
							INSERT INTO "informix".tabla_valida_puntos_coppel(foliocsuac, fechacargo, numcuenta, numcliente, montopro, producto, referencia23, folio_suc, indicador)
							VALUES(v_folio_csuac, v_fechacargo, v_numcuenta, v_numcliente, v_montopro, c_producto, v_referencia23, v_folio_suc, '0');
		
							LET v_referencia23 = '';
							
						END IF;
					END IF;
				--END IF;
				
					LET iContador = iContador + 1;
	
				IF iContador = 1000 THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF;

			END FOREACH;

		COMMIT WORK;

	
		BEGIN WORK;
			LET iContador = 0;
			
			FOREACH WITH HOLD
				
				SELECT numcuenta, numcliente, montopro, referencia23, fechacargo, foliocsuac
					INTO v_numcuenta, v_numcliente, v_montopro, v_referencia23, v_fechacargo, v_folio_csuac
				FROM "informix".tabla_valida_puntos_coppel
				
				
				
				SELECT min(id)
					INTO v_id
				FROM bdicred:"informix".sd_movs_monedero_plan_lealtad 
				WHERE date(fecha_mov) = v_fechacargo AND referencia23 = v_referencia23 AND
				numcte = v_numcliente AND num_credito = v_numcuenta AND tipo_mov = 'ABONO_PUNTOS' ;
	
			
					IF v_id IS NOT NULL OR v_id <> '' THEN
					
						UPDATE bdicred:"informix".sd_movs_monedero_plan_lealtad SET tipo_mov = 'CARGO_NO_RECONOCIDO' WHERE id = v_id AND referencia23 = v_referencia23 AND numcte = v_numcliente AND num_credito = v_numcuenta AND tipo_mov = 'ABONO_PUNTOS'; 
						
						UPDATE "informix".tabla_valida_puntos_coppel SET indicador = '1' WHERE foliocsuac  = v_folio_csuac;
						
					END IF;
			
				LET iContador = iContador + 1;
				
				IF iContador = 1000 THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF;
				
				
			END FOREACH;
		COMMIT WORK;
		
		
		
		
		/*========================================================================================================================*/
		let cQuery = ' echo "FOLIO_CSUAC|FECHA_DE_CARGO|NUMERO_CUENTA|CLIENTE|MONTO_PROCEDENTE|PRODUCTO|REFERENCIA23">/resplogifx/repaclaraciones/PUNTOS_COPPEL_MAX_'||LPAD (day(dFechaHoy),2,"0")||LPAD (MONTH(dFechaHoy),2,"0")||year(dFechaHoy)||'.unl';
		system cQuery; 
		let cQuery = '';
		let cQuery=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO coppel_max.unl  SELECT foliocsuac, fechacargo, numcuenta, numcliente, montopro, producto, referencia23 FROM tabla_valida_puntos_coppel WHERE indicador = "1";">coppel_max.sql'; 
		system cQuery;
		let cQuery = '';
		let cQuery= 'dbaccess bdiaclaracion  coppel_max.sql';
		system cQuery;
		let cQuery ='';
		let cQuery ='rm  coppel_max.sql';
		system cQuery;
		let cQuery =''; 
		let cQuery = "sed 's/|$//g' coppel_max.unl >>/resplogifx/repaclaraciones/PUNTOS_COPPEL_MAX_"||LPAD (day(dFechaHoy),2,"0")||LPAD (MONTH(dFechaHoy),2,"0")||year(dFechaHoy)||".unl";
		system cQuery;
		let cQuery ='rm  coppel_max.unl';
		system cQuery;
		
		
		--DROP TABLE "informix".tabla_valida_puntos_coppel;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT
'Sistema	   : Aclaraciones',
'Creacion	   : BanCoppel',
'Programador   : Rey David',
'Fecha		   : 23/11/2023',
'Requerimiento : Coppel Max',
'Version	   : 1.0.0',
'Descripcion   : SPL encargado de realizar la generacion del archivo PUNTOS_COPPEL_MAX_ddmmaaaa.unl, e insertar los registros correspondientes sobre la tabla bdicred:"informix".sd_compras_plan_lealtad',
'BD			   : bdiaclaracion';

CREATE PROCEDURE "informix".sp_evidencias_3410(pFoliosuac CHAR(11))
	        RETURNING CHAR(06) AS codret,
	         		   CHAR(11)  AS folio_cs,
     		 		   CHAR(20)  AS fechaChipNip,
			 		   CHAR(550) 	AS tokens_63in,
        			   CHAR(37) 	AS token_C0,
        			   CHAR(20) AS fechaCvv2Din,
        			   CHAR(20) AS fechaCancela,
        			   CHAR(4) 	AS statusTjt,
        			   CHAR(12) AS giroComercio,
        			   CHAR(18) AS idComercio,
					   CHAR(50) AS ref_comercio,
					   CHAR(10) AS sucursal,
					   CHAR(10) AS transaccion,
					   CHAR(15) AS num_celular,
					   CHAR(50) AS estado,
					   CHAR(10) AS cod_postal,
					   CHAR(70) AS municipio,
					   CHAR(20)    AS num_autorizacion,
					   DATETIME YEAR to FRACTION(5) AS fecha_consumo,
					   CHAR(50)    AS mensaje_sistema;



-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************		
	--Variables--
	DEFINE id_tipo_flujo		INTEGER;
	DEFINE tipo_flujo 			DATETIME YEAR TO MINUTE;
	DEFINE cFoliocsuac			CHAR(11);
	DEFINE p_interact           CHAR(1);
	DEFINE cFechacaptura		DATE;
	DEFINE cNumcliente			CHAR(9);
	DEFINE cFoliosuc			CHAR(20);
	DEFINE cNumuenta			CHAR(20);
	DEFINE cNumtarjeta			CHAR(16);
	DEFINE cStatustarjeta		CHAR(3);
	DEFINE chFechacancelacion	CHAR(25);  
	DEFINE chFecha_act_cvv2	    CHAR(25);  
	DEFINE chFecha_act_pin	    CHAR(25);  
	DEFINE cFechacancelacion	DATETIME YEAR to MINUTE;
	DEFINE cFechacancelacion2	DATETIME YEAR to MINUTE;
	DEFINE fecha_act_cvv2 		DATETIME YEAR to MINUTE;
	DEFINE fecha_act_pin 		DATETIME YEAR to MINUTE;
	DEFINE cod_giro             CHAR(8);
    DEFINE idComer              CHAR(15); 
	DEFINE ctokens63in          CHAR(550);
	DEFINE tokenC0              CHAR(37); 
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
	DEFINE postokenC0			INTEGER;
	DEFINE v_ref_comercio		CHAR(50);
	DEFINE v_pky_producto		INTEGER;
	DEFINE v_fky_tipo_movimiento INTEGER;
	DEFINE v_transaccion 		CHAR(10);
	DEFINE v_folio_suc			CHAR(20);
	DEFINE v_sucursal			CHAR(10);
	DEFINE v_estado             CHAR(50);
	DEFINE v_cod_postal         CHAR(10);
	DEFINE v_municipio          CHAR(70);
	DEFINE v_telefono     		CHAR(15);
	DEFINE v_fecha_consumo		DATETIME YEAR TO FRACTION;
	DEFINE v_num_autorizacion   CHAR(20);
	DEFINE v_tipo_producto		CHAR(2);
	DEFINE v_mensaje_sistema 	CHAR(50);

	DEFINE v_origen_evento	INTEGER;
	DEFINE v_tipo_pos		CHAR(5);
	DEFINE v_totaldevo		INTEGER;
	DEFINE v_montoDevo		CHAR(5);
	DEFINE v_totalDFA		INTEGER;
	DEFINE v_dictamen2 		CHAR(250);
	DEFINE v_importereclamado MONEY(16,2);

	 
    DEFINE vEs_chip_mas_nip SMALLINT;
    DEFINE vEs_fda_exitoso SMALLINT;
    DEFINE vDesc_primer_fda CHAR(50);
    DEFINE vDesc_segundo_fda CHAR(50);
    DEFINE vfecha_movimiento DATETIME YEAR TO FRACTION(5);
    DEFINE vImportereclamado MONEY;
    DEFINE vFecha_alta_nip DATETIME YEAR TO FRACTION(5);
    DEFINE vFecha_alta_cvv2din DATETIME YEAR TO FRACTION(5);
    DEFINE vCvv2_dinamico CHAR(4);
	DEFINE v_retornoDfa CHAR(5);

	LET borraTabla			=0;
	LET postokenC0			=0;
	LET chFechacancelacion	= NULL;
	LET chFecha_act_cvv2	= NULL;
	LET chFecha_act_pin	    = NULL;
	LET cFoliocsuac			= NULL;
	LET cFechacaptura		= NULL;
	LET cNumcliente			= NULL;
	LET cFoliosuc			= NULL;
	LET cNumuenta			= NULL;
	LET cNumtarjeta			= NULL;
	LET cStatustarjeta		= NULL;
	LET cFechacancelacion	= NULL;
	LET cFechacancelacion2	= NULL;
	
	
	LET id_tipo_flujo 		= NULL;
	LET tipo_flujo			= NULL;
	
	LET fecha_act_cvv2		= NULL;
	LET fecha_act_pin		= NULL;
	LET p_interact			= NULL;
	LET cod_giro        	= NULL; 
	LET idComer         	= NULL; 
	LET ctokens63in          = NULL;
	LET tokenC0            = NULL;
	LET dFechaHoy 		    = DATE(1);
	LET iContador 			=0;
	LET cCodRet      	= '00000';
	LET iSqlErr      	= 0;
	LET iIsamErr     	= 0;
	LET cQuery			= "";
	--LET cRuta		 	= "/tmp/mfinis"; 
	LET cRuta		 	= "/resplogifx/repaclaraciones/"; 
	LET cnom_Sql 		= 'ACL_evidencias3410_' ;
	LET v_ref_comercio  = NULL;
	LET v_pky_producto  = NULL;
	LET v_fky_tipo_movimiento = NULL;
	LET v_transaccion		  = NULL;
	LET v_folio_suc		= NULL;
	LET v_sucursal		= NULL;
    LET v_estado        = NULL;
	LET v_cod_postal    = NULL;
	LET v_municipio     = NULL;
	LET v_telefono      = NULL;
	LET v_fecha_consumo = NULL;
	LET v_num_autorizacion = NULL;

	LET v_mensaje_sistema = NULL;
	LET v_origen_evento	= NULL;
	LET v_tipo_pos		= NULL;
	LET v_totaldevo		= NULL;
	LET v_montoDevo		= NULL;
	LET v_totalDFA		= NULL;

	LET vEs_chip_mas_nip = NULL;
	LET vEs_fda_exitoso = NULL;
	LET vDesc_primer_fda = NULL;
	LET vDesc_segundo_fda = NULL;
	LET vfecha_movimiento = NULL;
	LET vImportereclamado = NULL;
	LET vFecha_alta_nip = NULL;
	LET vFecha_alta_cvv2din = NULL;
	LET vCvv2_dinamico = NULL;
	LET v_retornoDfa = '';
	LET v_dictamen2 = '';
	LET v_importereclamado = '';

--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            --LET cCodRet = iSqlErr;
			RETURN cCodRet, cFoliocsuac,chFecha_act_pin,ctokens63in,tokenC0,chFecha_act_cvv2,chFechacancelacion,cStatustarjeta,
			  		cod_giro, idComer, v_ref_comercio, v_sucursal, v_transaccion, v_telefono,v_estado , 
			  		v_cod_postal, v_municipio,v_num_autorizacion, v_fecha_consumo, v_mensaje_sistema;
			DROP TABLE "informix".acl_reporte_evidencia_3410_2;
			ROLLBACK WORK;
            --RETURN cCodRet,cMsjError;
			--RETURN cCodRet;
        END IF;
    END EXCEPTION;	

	IF pFoliosuac = '' THEN
		LET cCodRet = '00000';	
		DROP TABLE "informix".acl_reporte_evidencia_3410_2;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_evidencias_3410.out';
   	--TRACE ON; 

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
	    
		SELECT count(*) INTO borraTabla
		FROM systables WHERE tabname ='acl_reporte_evidencia_3410_2';
		         
		IF ( borraTabla > 0 ) THEN
			DROP TABLE "informix".acl_reporte_evidencia_3410_2;
		END IF;
	
		BEGIN WORK;
	
	/* Crear tabla de descarga */
	    CREATE TABLE "informix".acl_reporte_evidencia_3410_2(
	    folio_cs        CHAR(11),
        fechaChipNip	CHAR(20),
		tokens_63in     CHAR(550),
        token_C0     	CHAR(37),
        fechaCvv2Din	CHAR(20),
        fechaCancela	CHAR(20),
        statusTjt		CHAR(4),
        giroComercio  	CHAR(12),
        idComercio		CHAR(18),
		ref_comercio    CHAR(50),
		sucursal		CHAR(10),
		transaccion     CHAR(10),
		num_celular 	CHAR(15),
		estado 			CHAR(50),
		cod_postal 		CHAR(10),
		municipio		CHAR(70),
		num_autorizacion CHAR(20),
		fecha_consumo   DATETIME YEAR to FRACTION(5),
		mensaje_sistema  CHAR(50),
		primary key (folio_cs)
		)extent size 74707 next size 11767 lock mode row;
			  
	
		/* Fecha del dÃ­a*/
		SELECT fecha_hoy 
	    into dFechaHoy
	    FROM bdinteg:"informix".si_fechas;
		
		LET iContador = 0;
		FOREACH WITH HOLD 
			
			SELECT acl.folio_csuac,fechacaptura,prod.num_cliente,mov.folio_suc,prod.numero_cuenta, prod.numero_tarjeta,
					tjt.codstatustarjeta,fecha, mov.ref_comercio, prod.pky_producto, mov.fky_tipo_movimiento, mov.fecha_consumo, mov.referencia, mov.num_sucursal
				INTO cFoliocsuac,cFechacaptura,cNumcliente,cFoliosuc,cNumuenta,cNumtarjeta,cStatustarjeta,cFechacancelacion2, 
					 v_ref_comercio, v_pky_producto, v_fky_tipo_movimiento, v_fecha_consumo, v_num_autorizacion, v_sucursal
				 FROM bdiaclaracion@stag_ids1170:acl_aclaracion acl
				 LEFT JOIN bdiaclaracion@stag_ids1170:"informix".acl_producto prod ON prod.pky_producto = acl.fky_producto 
				 LEFT JOIN bdiaclaracion@stag_ids1170:"informix".acl_movimiento  mov  on mov.folio_csuac = acl.folio_csuac  and acl.pky_aclaracion = mov.fky_aclaracion
				 LEFT JOIN intercard:tarjeta tjt ON (tjt.numtarjeta  = prod.numero_tarjeta)
				 LEFT JOIN intercard:bitacoracancelaciontarjetas bitcan ON (bitcan.tarjeta = prod.numero_tarjeta)
				WHERE acl.fechacaptura  <= TODAY--BETWEEN today-6 AND today-1 
				--WHERE acl.fechacaptura  '2023/05/17'::DATE
				 AND acl.folio_csuac is not null
				 AND acl.folio_csuac = TRIM(pFoliosuac)

				 /* Quitar para produccion */
				--  WHERE acl.fechacaptura >= today -28 
				-- AND acl.fky_estatus_aclaracion IN (2,3)
				 
            /*    
			SELECT MIN(fecha) INTO cFechacancelacion2
			FROM intercard:bitacoracancelaciontarjetas WHERE tarjeta IN (cNumtarjeta); 		
            */			
							
			/* Fecha de Alta de Chip+Nip CAMPO2 */
			SELECT MIN(fechahora_insert) INTO fecha_act_pin
			FROM intercard:bit_pinoffline WHERE tarjeta_edofinal = 1 
			AND  numtarjeta IN (cNumtarjeta);
		 
			SELECT MIN(fechacambio) 
			INTO  fecha_act_cvv2 
			FROM intercard:"informix".bitacoracambiostarjeta 
			WHERE tarjeta = cNumtarjeta AND  numcliente = cNumcliente AND identificadorcambio = 9;
			--ORDER BY secuencial desc;
			
			LET v_folio_suc = cFoliosuc;
				/* Giro comercion  */  
			LET p_interact= SUBSTRING(cFoliosuc FROM 0 FOR 2);
			IF 	(p_interact = 'i') THEN	 
			LET cFoliosuc = substr(cFoliosuc,2);
			END IF;
			
			select codgironeg,idretailer,tokens63in
			INTO cod_giro,idComer,ctokens63in
			from intercard:movimiento where numtarjeta in (cNumtarjeta)
			and secuenciaextendida= (cFoliosuc);
			
			IF cod_giro IS NULL OR idComer = '' 
			THEN 
				SELECT codgironeg,idretailer,tokens63in
				INTO cod_giro,idComer,ctokens63in
				FROM intercard:movimientohistorico where numtarjeta in (cNumtarjeta)
				AND secuenciaextendida= (cFoliosuc);
			END IF;
			
			IF ctokens63in IS NOT NULL 
			THEN
			LET postokenC0 = CHARINDEX('! C000026', ctokens63in);
			IF postokenC0 > 1 THEN
			LET tokenC0 = SUBSTR (ctokens63in, postokenC0, 37);
			END IF;
			END IF;
			
			----Obtener la transacciÃ³n del movimiento
			SELECT transaccion
				INTO v_transaccion
			FROM bdiaclaracion@stag_ids1170:acl_tipo_movimiento 
			WHERE pky_tipo_movimiento = v_fky_tipo_movimiento;
			
			----Obtener la sucursal por del movimiento
			SELECT tp.tipo_producto
				INTO v_tipo_producto
			FROM bdiaclaracion@stag_ids1170:acl_producto pro
				INNER JOIN acl_tipo_producto tp on tp.pky_tipo_producto = pro.fky_tipo_producto
			WHERE pro.pky_producto = v_pky_producto;
			
			IF v_sucursal IS NULL THEN
				--IF v_transaccion IS NOT NULL THEN
				
					IF v_tipo_producto = '1' THEN
						Select sucursal
							into v_sucursal
						from bdicred:sd_movdia where folio_suc = v_folio_suc and transacc_suc = v_transaccion;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicred:sd_movhis where folio_suc = v_folio_suc and transacc_suc = v_transaccion;
						END IF;
						
						--IF v_sucursal IS NULL OR v_sucursal = '' THEN
						--	Select sucursal
						--		into v_sucursal
						--	from bdicred:sd_movhis_old where folio_suc = v_folio_suc and transacc_suc = v_transaccion and ;
						--END IF;
										
					--END IF;
					
					IF v_tipo_producto = '2' THEN
						
						Select sucursal
							into v_sucursal
						from bdicheq:sc_movdia where folio_suc = v_folio_suc and transacc = v_transaccion;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicheq:sc_movhis where folio_suc = v_folio_suc and transacc = v_transaccion;
						END IF;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicheq:sc_movdia where folio_suc = v_folio_suc and transacc = v_transaccion;
						END IF;
						
						----Si no encuentar en debito busca en inversiones
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							SELECT sucursal
								into v_sucursal
							FROM bdinvers:sv_movdia
							WHERE folio_suc = v_folio_suc
								AND transacc=v_transaccion AND cuenta = cNumuenta;
						END IF;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							SELECT sucursal
								into v_sucursal
							FROM bdinvers:sv_movhis
							WHERE folio_suc = v_folio_suc
								AND transacc=v_transaccion AND cuenta = cNumuenta;
						END IF;
					END IF;
				END IF;
			END IF;
			
			---Se obtienen los datos del cliente como celular, municipio, codigo postal y estado.
			select es.nombre ,si.cod_postal ,sz.municipiozona, ta.telefono
				INTO v_estado, v_cod_postal, v_municipio, v_telefono
			from bdinteg:si_direcciones_actual si
			left join bdinteg:si_estados es on si.estado=es.estado
			left join bdinteg:si_municipios mu on si.municipio=mu.municipio
			Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = si.numerociudad and sz.numerocolonia = si.numerocolonia
			INNER JOIN bdinteg:si_telefonos_actual ta on si.numcte = ta.numcte and ta.tipo_tel = '2' 
			Where  si.tipo_dir = 1 and si.numcte = cNumcliente;
			
			----Se obtiene el numero de autorizaciÃ³n
			LET v_num_autorizacion = substr(v_num_autorizacion,11);
			
			SELECT MIN(fechahora) INTO cFechacancelacion
			FROM intercard:bitacoracambiosstatustarjeta
            WHERE codstatustarjetanvo = 'CAN'
            AND tarjeta = cNumtarjeta;
			
			IF cFechacancelacion2 IS NOT NULL 
			THEN 
			LET cFechacancelacion = cFechacancelacion2;
			LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");
			END IF;
			
			IF cFechacancelacion IS NOT NULL 
			THEN 
			LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF fecha_act_pin IS NOT NULL 
			THEN 
			LET chFecha_act_pin = TO_CHAR(fecha_act_pin,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF fecha_act_cvv2 IS NOT NULL 
			THEN 
			LET chFecha_act_cvv2 = TO_CHAR(fecha_act_cvv2,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF chFecha_act_pin IS NOT NULL 
			THEN 
			LET chFecha_act_pin = TRIM(chFecha_act_pin);
			END IF;
			
			IF chFecha_act_cvv2 IS NOT NULL 
			THEN 
			LET chFecha_act_cvv2 = TRIM(chFecha_act_cvv2);
			END IF;
					
			IF chFechacancelacion IS NOT NULL 
			THEN 
			LET chFechacancelacion = TRIM(chFechacancelacion);
			END IF;
			
			IF cod_giro IS NOT NULL 
			THEN 
			LET cod_giro = TRIM(cod_giro);
			END IF;
			
		    IF idComer IS NOT NULL 
			THEN 
			LET idComer = TRIM(idComer);
			END IF;

			--Buscamos si la transacciÃ³n es de origen comercio
			SELECT oe.pky_origen_evento, oe.nombre, acl.importereclamado
			INTO v_origen_evento, v_tipo_pos, v_importereclamado
			FROM bdiaclaracion@stag_ids1170:acl_aclaracion acl 
			Inner Join bdiaclaracion@stag_ids1170:acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
			Inner Join bdiaclaracion@stag_ids1170:acl_origen_evento oe on te.fky_origen_evento = oe.pky_origen_evento
			Inner Join bdiaclaracion@stag_ids1170:acl_movimiento mov on mov.folio_csuac = acl.folio_csuac
			and mov.fky_padre is null and mov.duplicado = 0
			Inner Join acl_producto pro on acl.fky_producto = pro.pky_producto
			WHERE acl.folio_csuac = cFoliocsuac;

			IF TRIM(v_tipo_pos) = 'POS' THEN ----La Aclaracion pertenece a un Origen de Compra en Comercio
				--Busca que el evento sea devoluciÃ³n
				EXECUTE PROCEDURE "informix".sp_acl_valida_dfa_devo("1", cFoliocsuac , cNumtarjeta, '')
				INTO v_retornoDfa, v_mensaje_sistema, v_dictamen2;

				IF v_mensaje_sistema IS NULL OR v_mensaje_sistema = '' THEN
					EXECUTE PROCEDURE "informix".sp_acl_valida_dfa_devo("2", cFoliocsuac , cNumtarjeta, v_importereclamado)
					INTO v_retornoDfa, v_mensaje_sistema, v_dictamen2;

					IF TRIM(v_mensaje_sistema) = 'Procedente, no cuenta con Devolucion' THEN
						LET v_mensaje_sistema = '';
					END IF; 
				END IF;
			END IF

			
     		INSERT INTO acl_reporte_evidencia_3410_2(folio_cs,fechaChipNip,tokens_63in,token_C0,
			fechaCvv2Din,fechaCancela,statusTjt,giroComercio,idComercio, ref_comercio, sucursal,transaccion, num_celular,estado ,
			cod_postal, municipio,num_autorizacion, fecha_consumo, mensaje_sistema)
			VALUES (cFoliocsuac,chFecha_act_pin,ctokens63in,tokenC0,chFecha_act_cvv2,chFechacancelacion,cStatustarjeta,cod_giro,idComer, 
			v_ref_comercio, v_sucursal, v_transaccion, v_telefono,v_estado , v_cod_postal, v_municipio,v_num_autorizacion, v_fecha_consumo, v_mensaje_sistema);
			
			LET chFechacancelacion	= NULL;
	        LET chFecha_act_cvv2	= NULL;
	        LET chFecha_act_pin	    = NULL;
			LET tokenC0             = NULL;
			LET postokenC0          =0;
			LET ctokens63in         = NULL;
			LET cStatustarjeta      = NULL;
			LET cod_giro            = NULL;
			LET idComer             = NULL;
			LET v_ref_comercio  = NULL;
			LET v_pky_producto  = NULL;
			LET v_fky_tipo_movimiento = NULL;
			LET v_transaccion		  = NULL;
			LET v_folio_suc		= NULL;
			LET v_sucursal		= NULL;
			LET v_estado        = NULL;
			LET v_cod_postal    = NULL;
			LET v_municipio     = NULL;
			LET v_telefono      = NULL;
			LET v_fecha_consumo = NULL;
			LET v_num_autorizacion = NULL;
	
			
			LET iContador = iContador + 1;
					
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 

			
		END FOREACH;
		
		COMMIT WORK;
		
		/*RETORNO DE INFORMACION*/
		
		SELECT folio_cs, fechaChipNip, tokens_63in, token_C0, fechaCvv2Din, fechaCancela, statusTjt, 
			   giroComercio, idComercio, ref_comercio, sucursal, transaccion, num_celular, estado, 
			   cod_postal, municipio, num_autorizacion, fecha_consumo, mensaje_sistema
		INTO  cFoliocsuac,chFecha_act_pin,ctokens63in,tokenC0,chFecha_act_cvv2,chFechacancelacion,cStatustarjeta,
			  cod_giro, idComer, v_ref_comercio, v_sucursal, v_transaccion, v_telefono,v_estado , 
			  v_cod_postal, v_municipio,v_num_autorizacion, v_fecha_consumo, v_mensaje_sistema
		FROM "informix".acl_reporte_evidencia_3410_2
		WHERE folio_cs = TRIM(pFoliosuac);

 		RETURN cCodRet, cFoliocsuac,chFecha_act_pin,ctokens63in,tokenC0,chFecha_act_cvv2,chFechacancelacion,cStatustarjeta,
			  cod_giro, idComer, v_ref_comercio, v_sucursal, v_transaccion, v_telefono,v_estado , 
			  v_cod_postal, v_municipio,v_num_autorizacion, v_fecha_consumo, v_mensaje_sistema;

		DROP TABLE "informix".acl_reporte_evidencia_3410_2;	

	END;
END PROCEDURE

DOCUMENT 
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/10/2023',
'DESCRIPCION: SP Clon encargado de consultar la informaciÃ³n del Reporte de evidencias 3410',
'BD:bdiaclaracion';

CREATE PROCEDURE "informix".sp_integracion_cta (p_FechaInicial DATE, p_FechaFinal DATE)
RETURNING CHAR(11) AS r_folio, money(16,2) AS r_monto, CHAR(20) AS r_cuenta, CHAR(16) AS r_tarjeta, CHAR(3) AS r_tipo_evento, CHAR(1) AS r_procede, CHAR(50) AS r_sel_transaccion, DATE AS r_fecha_abon, money(16,2) AS r_monto_abon, DATE AS r_fecha_carg, money(16,2) AS r_monto_carg, money(16,2) AS r_comision, CHAR(30) AS r_concepto;

	/* Definiciï¿½n de variables*/
	DEFINE res_folio 		CHAR(11);
	DEFINE res_monto 		money(16,2);
	DEFINE res_cuenta 		CHAR(20);
	DEFINE res_tarjeta 		CHAR(16);
	DEFINE res_tipo_evento 	CHAR(3);
	DEFINE res_procede		CHAR (1);
	DEFINE res_sel_transa	CHAR(50);
	DEFINE res_fech_abon 	DATE;
	DEFINE res_monto_abon	money(16,2);
	DEFINE res_fecha_cargo	DATE;
	DEFINE res_monto_cargo	money(16,2);
	DEFINE res_comision 	money(16,2);
	DEFINE res_concepto		CHAR(30);
	DEFINE iSqlErr          INTEGER;
	DEFINE tipo_producto	CHAR(2);
	DEFINE p_calculado		CHAR(1);
	DEFINE p_estatus 		CHAR(1);
	DEFINE p_dictamen		DATE;
	DEFINE p_cargo			CHAR(1);

	/* Inicializaciï¿½n de variables*/
	LET res_folio		='';
	LET res_monto		='';
	LET res_cuenta		='';
	LET res_tarjeta		='';
	LET res_tipo_evento	='';
	LET res_procede		='';
	LET res_sel_transa	='';
	LET res_fech_abon	='';
	LET res_monto_abon	='';
	LET res_fecha_cargo	='';
	LET res_monto_cargo	='';
	LET res_comision	='';
	LET res_concepto	='';
	LET tipo_producto   ='';
	LET p_calculado		='';
	LET p_estatus 		='';
	LET p_dictamen		='';
	LET p_cargo			='';

	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET res_folio		='';
				LET res_monto		='';
				LET res_cuenta		='';
				LET res_tarjeta		='';
				LET res_tipo_evento	='';
				LET res_procede		='';
				LET res_sel_transa	='';
				LET res_fech_abon	='';
				LET res_monto_abon	='';
				LET res_fecha_cargo	='';
				LET res_monto_cargo	='';
				LET res_comision	='';
				LET res_concepto	='';

                RETURN res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo,res_monto_cargo,res_comision, res_concepto;

			END IF;
        END EXCEPTION;

		FOREACH
		SELECT b.cargo, a.fky_estatus_aclaracion, date(a.fecha_dictamen), b.calculado, a.folio_csuac,a.importereclamado, c.numero_cuenta, c.numero_tarjeta, b.fky_tipo_evento, a.procede, d.descripcion as seleccion_transaccion, CASE WHEN b.cargo='0' THEN date(b.fecha_afectacion) END as fech_abon, CASE WHEN b.cargo='0' THEN b.montoprocedente END as monto_aplicado, CASE WHEN b.cargo='1' THEN date(b.fecha_afectacion) END as fec_carg, CASE WHEN b.cargo='1' and b.numero_transaccion not in ('0343','5212') THEN b.montoprocedente END as cargo_aplicado, '' as comision ,  DECODE(a.procede,1,'Dictamen procedente',0,'Dictamen no procedente',null,'Abono temporal') as concepto
			INTO p_cargo, p_estatus, p_dictamen, p_calculado, res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto
		FROM acl_aclaracion a, acl_movimiento b, acl_producto c, outer acl_tipo_catalogo_transaccion d
		WHERE a.folio_csuac=b.folio_csuac
			AND b.fky_producto=c.pky_producto
			AND b.fky_tipo_catalogo_transaccion=d.pky_tipo_catalogo_transaccion
			AND b.exitoso='1'
			AND date(b.fecha_afectacion) between p_FechaInicial and p_FechaFinal
			AND b.numero_transaccion not in ('0343','5212')
			order by b.folio_csuac, b.pky_movimiento,b.fecha_afectacion

			IF (p_estatus='2') THEN
				LET res_concepto='Abono temporal';
			END IF;
			IF (p_estatus>'2') THEN
				IF (p_dictamen <> res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Abono temporal';
				ELSE IF (p_dictamen=res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Dictamen Procede';
					END IF;
				END IF;

				IF (p_dictamen=res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
				ELSE IF (p_dictamen<>res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
					END IF;
				END IF;
			END IF;

			LET tipo_producto=SUBSTRING(res_cuenta FROM 0 FOR 3);

			IF ((SELECT procede FROM "informix".acl_aclaracion WHERE folio_csuac =res_folio)=0 and p_calculado=0 ) THEN -- SE debe reflejar sobre el cargo del abono temporal
				IF (tipo_producto in ('13','14','17')) THEN
					LET res_comision='0.00';
				ELSE
					SELECT monto*1.16  INTO res_comision FROM "informix".acl_movimiento WHERE folio_csuac=res_folio and numero_transaccion in ('0343','5212');
				END IF;
			END IF;

			RETURN res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto WITH RESUME;
		END FOREACH;

	END

END PROCEDURE
DOCUMENT
'SP para cumplimiento de RQM 06 306 Integraciï¿½n de cuenta contable ? abonos temporales',
'Genera reporte de afectaciones a cuentas de los clientes',
'Autor: Bernardo Beltrï¿½n Herrera - Gerencia: Mtto 2',
'Coordinaciiï¿½n: 22 Sistemas Administrativos y Perifï¿½ricos',
'Fecha de creaciï¿½n: 12/11/2014',
'Versiï¿½n: 0.9',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_integracion_cuenta (p_FechaInicial DATE, p_FechaFinal DATE)
RETURNING CHAR (5);

	/* Definicion de variables*/
	DEFINE res_folio 		CHAR(11);
	DEFINE res_monto 		money(16,2);
	DEFINE res_cuenta 		CHAR(20);
	DEFINE res_tarjeta 		CHAR(16);
	DEFINE res_tipo_evento 	CHAR(3);
	DEFINE res_procede		CHAR (1);
	DEFINE res_sel_transa	CHAR(50);
	DEFINE res_fech_abon 	DATE;
	DEFINE res_monto_abon	money(16,2);
	DEFINE res_fecha_cargo	DATE;
	DEFINE res_monto_cargo	money(16,2);
	DEFINE res_comision 	money(16,2);
	DEFINE res_concepto		CHAR(30);
	DEFINE iSqlErr          INTEGER;
	DEFINE tipo_producto	CHAR(2);
	DEFINE p_calculado		CHAR(1);
	DEFINE p_estatus 		CHAR(1);
	DEFINE p_dictamen		DATE;
	DEFINE p_cargo			CHAR(1);
	DEFINE vcodret			char(5);
	DEFINE vsqlerr			integer;
	DEFINE  vsql        	char(3000);

	/* Inicializacion de variables*/
	LET res_folio		='';
	LET res_monto		='';
	LET res_cuenta		='';
	LET res_tarjeta		='';
	LET res_tipo_evento	='';
	LET res_procede		='';
	LET res_sel_transa	='';
	LET res_fech_abon	='';
	LET res_monto_abon	='';
	LET res_fecha_cargo	='';
	LET res_monto_cargo	='';
	LET res_comision	='';
	LET res_concepto	='';
	LET tipo_producto   ='';
	LET p_calculado		='';
	LET p_estatus 		='';
	LET p_dictamen		='';
	LET p_cargo			='';


--Verificar tablas fisicas
		IF EXISTS( SELECT * FROM systables WHERE tabname ='acl_integracion_cta') THEN
			DROP TABLE "informix".acl_integracion_cta;
		END IF;

	--creacion de tabla
        CREATE  TABLE  "informix".acl_integracion_cta
            (folio           CHAR(11),
             monto           money,
            cuenta           char(20),
            tarjeta          char(16),
            tipo_evento      char(3),
            procede          char(1),
            sel_transac      char(50),
            fecha_abono      date,
            monto_abono      money,
            fecha_cargo      date,
            monto_cargo      money,
            comision         money,
            concepto         char(30)
		)  extent size 362695 next size 36484 lock mode row;

	let vcodret = "";
	let vsqlerr = 0;

	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/acl_integracion_cta.out"; 
    --TRACE ON;

	BEGIN

		On exception set vsqlerr
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;

	SET ISOLATION TO DIRTY READ;

		FOREACH
		SELECT b.cargo, a.fky_estatus_aclaracion, date(a.fecha_dictamen), b.calculado, a.folio_csuac,a.importereclamado, c.numero_cuenta, c.numero_tarjeta, b.fky_tipo_evento, a.procede, d.descripcion as seleccion_transaccion, CASE WHEN b.cargo='0' THEN date(b.fecha_afectacion) END as fech_abon, CASE WHEN b.cargo='0' THEN b.montoprocedente END as monto_aplicado, CASE WHEN b.cargo='1' THEN date(b.fecha_afectacion) END as fec_carg, CASE WHEN b.cargo='1' and b.numero_transaccion not in ('0343','5212') THEN b.montoprocedente END as cargo_aplicado, '' as comision ,  DECODE(a.procede,1,'Dictamen procedente',0,'Dictamen no procedente',null,'Abono temporal') as concepto
			INTO p_cargo, p_estatus, p_dictamen, p_calculado, res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto
		FROM acl_aclaracion a, acl_movimiento b, acl_producto c, outer acl_tipo_catalogo_transaccion d
		WHERE a.folio_csuac=b.folio_csuac
			AND b.fky_producto=c.pky_producto
			AND b.fky_tipo_catalogo_transaccion=d.pky_tipo_catalogo_transaccion
			AND b.exitoso='1'
			AND date(b.fecha_afectacion) between p_FechaInicial and p_FechaFinal
			AND b.numero_transaccion not in ('0343','5212')
			order by b.folio_csuac, b.pky_movimiento,b.fecha_afectacion

			IF (p_estatus='2') THEN
				LET res_concepto='Abono temporal';
			END IF;
			IF (p_estatus>'2') THEN
				IF (p_dictamen <> res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Abono temporal';
				ELSE IF (p_dictamen=res_fech_abon AND p_cargo='0' AND res_fech_abon is not null OR res_fech_abon<>'') THEN
					LET res_concepto='Dictamen Procede';
					END IF;
				END IF;

				IF (p_dictamen=res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
				ELSE IF (p_dictamen<>res_fecha_cargo AND p_cargo='1' AND res_fecha_cargo is not null OR res_fecha_cargo<>'') THEN
					LET res_concepto='Dictamen No procedente';
					END IF;
				END IF;
			END IF;

			LET tipo_producto=SUBSTRING(res_cuenta FROM 0 FOR 3);

			IF ((SELECT procede FROM "informix".acl_aclaracion WHERE folio_csuac =res_folio)=0 and p_calculado=0 ) THEN -- SE debe reflejar sobre el cargo del abono temporal
				IF (tipo_producto in ('13','14','17')) THEN
					LET res_comision='0.00';
				ELSE
					SELECT monto*1.16  INTO res_comision FROM "informix".acl_movimiento WHERE folio_csuac=res_folio and numero_transaccion in ('0343','5212');
				END IF;
			END IF;

			INSERT INTO  "informix".acl_integracion_cta values (res_folio, res_monto, res_cuenta, res_tarjeta, res_tipo_evento, res_procede, res_sel_transa, res_fech_abon, res_monto_abon, res_fecha_cargo, res_monto_cargo, res_comision, res_concepto);
		END FOREACH;

		let vcodret="00002";

		--Generacion de archivo reporte
			let vsql = ' echo "Folio_CSUAC|Importe_Reclamado|Numero_De_Cuenta|Tarjeta|Tipo_Evento|Procede|Seleccion_Transaccion|Fecha_Afectacion(ABONO_A_CLIENTE)|Monto_Aplicado(ABONO_A_CLIENTE)|Fecha_Afectacion(CARGO_A_CLIENTE)|Monto_No_Procedente(CARGO_A_CLIENTE)|Comision_por_no_procedente(CARGO_A_CLIENTE)|Concepto">/resplogifx/repaclaraciones/RPT_integracion_cta_contable_'||LPAD (day(today-1),2,"0")||LPAD (MONTH(today-1),2,"0")||year(today-1)||'.unl';
			system vsql;
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/repaclaraciones/acl_integracion_cta.unl  select folio, monto, cuenta, tarjeta, tipo_evento, procede, sel_transac, fecha_abono, monto_abono, fecha_cargo, monto_cargo, comision, concepto  from acl_integracion_cta;">/resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdiaclaracion  /resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/repaclaraciones/acl_integracion_cta.unl >>/resplogifx/repaclaraciones/RPT_integracion_cta_contable_"||LPAD (day(today-1),2,"0")||LPAD (MONTH(today-1),2,"0")||year(today-1)||".unl";
			system vsql;
			let vsql ='rm  /resplogifx/repaclaraciones/acl_integracion_cta.unl';
			system vsql;


		let vcodret="00000";

		return vcodret;

	END

END PROCEDURE
DOCUMENT
'SP para cumplimiento de RQM 06 306 Integracion de cuenta contable abonos temporales',
'Genera reporte de afectaciones a cuentas de los clientes',
'Autor: Bernardo Beltran Herrera - Gerencia: Mtto 2',
'Coordinacion: 22 Sistemas Administrativos y Perifericos',
'Fecha de creacion: 12/11/2014',
'Version: 0.9',
'BD: bdiaclaracion',

'Se modifica SP para corregir error que se presentaba al momento de generar los archivos',
'10/08/2016',
'Adilene Lara Armenta';

CREATE PROCEDURE "informix".sp_acl_regulatorio27 (pFechaCap_Ini DATE,pFechaCap_Fin DATE)

	RETURNING CHAR(5);

-- ****************************************************************************
-- DefiniciÃ³n de Variables de datos 
-- ****************************************************************************

	DEFINE CodRet                        CHAR(5);
    define icontador                     integer;
	DEFINE v_folio_csuac                 VARCHAR (11);                    
	DEFINE v_fechacaptura                DATE;                            
	DEFINE v_importereclamado            MONEY;                           
	DEFINE v_fky_estatus_aclaracion      INTEGER;                         
	DEFINE v_fecha_dictamen              DATEtime YEAR to FRACTION(5);    
	DEFINE v_montoprocedente             MONEY;                           
	DEFINE v_fky_tipo_codigo_resolucion  INTEGER;                         
	DEFINE v_procede					 SMALLINT;                        
	DEFINE v_fky_producto                INTEGER;                         
	DEFINE v_fky_tipo_evento             INTEGER;                         
	DEFINE v_fky_estatus_corp_general    INTEGER;                         
	DEFINE v_fechahora                   DATEtime YEAR to FRACTION(5);    
	DEFINE v_fecha_abono                 DATEtime YEAR to FRACTION(5);  
	DEFINE v_fky_tipo_producto           INTEGER;                         
	DEFINE v_numero_cuenta               VARCHAR (20);                    
	DEFINE v_numero_tarjeta              VARCHAR (16);                    
	DEFINE v_pky_tipo_producto 			 INTEGER;                         
	DEFINE v_des_tipo_producto			 VARCHAR (255);	                  
	DEFINE v_origen_evento               INTEGER;                         
	DEFINE v_pky_tipo_evento			 INTEGER;                         
	DEFINE v_desc_evento                 VARCHAR (50);                    
	DEFINE v_desc_origen                 VARCHAR (50);                    
	DEFINE v_desc_aclaracion			 VARCHAR (255);                   
	DEFINE v_pky_estatus_corporativo	 INTEGER;                         
	DEFINE v_codigo_resolucion           VARCHAR (4);                     
	DEFINE v_desc_resolucion             VARCHAR (255);                     
	DEFINE v_importe_rec                 MONEY;                           
	DEFINE v_quebranto_inst              MONEY;                           
	DEFINE v_transaccion_quebranto       INTEGER;
	DEFINE v_folio_csuac_r27             VARCHAR (11);                    
	DEFINE v_fky_estatus_aclaracion_r27  INTEGER;
	
	DEFINE v_tipo_procedente			 INTEGER;
	
	DEFINE v_fecha_inicio_min            DATE;
	DEFINE v_fecha_inicio                DATE;                             
	DEFINE v_fecha_fin                   DATE;   

	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/resplogifx/traces/IAP/SPR27";
--TRACE ON;
	
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
	
	LET CodRet                            = '00000';
	
	LET v_folio_csuac                     = '';
	LET v_fechacaptura                    = '';
	LET v_importereclamado                = '';
	LET v_fky_estatus_aclaracion          = 0 ;
	LET v_fecha_dictamen                  = '';
	LET v_montoprocedente                 = '';
	LET v_fky_tipo_codigo_resolucion      = 0 ;
	LET v_procede                         = 0 ;
	LET v_fky_producto                    = 0 ;
	LET v_fky_tipo_evento                 = 0 ;
	LET v_fky_estatus_corp_general        = 0 ;
	LET v_fechahora                       = '';
	LET v_fecha_abono                     = '';
	LET v_numero_cuenta                   = '';
	LET v_numero_tarjeta                  = '';
	LET v_pky_tipo_producto               = 0 ;
	LET v_des_tipo_producto               = '';
	LET v_origen_evento                   = 0 ;
	LET v_pky_tipo_evento                 = 0 ;
	LET v_desc_evento                     = '';
	LET v_desc_origen                     = '';
	LET v_desc_aclaracion                 = '';
	LET v_pky_estatus_corporativo         = '';
	LET v_codigo_resolucion               = '';
	LET v_desc_resolucion                 = '';
    LET v_importe_rec                     = '';    
    LET v_quebranto_inst                  = '';
	LET v_transaccion_quebranto           = 0 ;
	LET v_folio_csuac_r27                 = '';
	LET v_fky_estatus_aclaracion_r27      = 0 ;
	
	LET v_tipo_procedente                 = 0 ;

	LET v_fecha_inicio_min                = '';            -- Fecha para inicio de bÃºsqueda por aclaraciÃ³n activa mÃ¡s antigua.               
	LET v_fecha_inicio                    = pFechaCap_Ini;                           
	LET v_fecha_fin                       = pFechaCap_Fin;
	LET icontador=0;

-->> Fecha mas antigua con aclaraciones con estatus de ingresadas

	SELECT MIN (fechacaptura) 
	INTO v_fecha_inicio_min
	FROM acl_aclaracion 
	WHERE fky_estatus_aclaracion = 2;

BEGIN WORK;
FOREACH WITH HOLD

	-- select * from acl_aclaracion                                             -- A
	SELECT 
	folio_csuac, fechacaptura, importereclamado, fky_estatus_aclaracion, fecha_dictamen, montoprocedente, fky_tipo_codigo_resolucion, procede
	,fky_producto, fky_tipo_evento, fky_estatus_corp_general
	INTO 
	v_folio_csuac, v_fechacaptura, v_importereclamado, v_fky_estatus_aclaracion, v_fecha_dictamen, v_montoprocedente, v_fky_tipo_codigo_resolucion, v_procede
	,v_fky_producto, v_fky_tipo_evento, v_fky_estatus_corp_general
	FROM acl_aclaracion a
	WHERE (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fky_estatus_aclaracion > 1 AND fechacaptura BETWEEN pFechaCap_Ini AND pFechaCap_Fin AND folio_csuac IS NOT NULL)  -->> Ingresadas en el periodo
	OR    (fechacaptura >= v_fecha_inicio_min AND fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND fky_estatus_aclaracion in (2))            -->> Sin resolver en el periodo
	OR    (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND DATE(fecha_dictamen) BETWEEN pFechaCap_Ini AND pFechaCap_Fin)	                 -->> Resultas en el periodo
	
	-->> select * from acl_movimiento												-- B 
	SELECT fechahora AS fecha_mov_original, fecha_afectacion as fecha_abono
	INTO v_fechahora, v_fecha_abono
	FROM acl_movimiento
	WHERE folio_csuac = v_folio_csuac
	AND fky_padre IS NULL
	AND duplicado = 0; 																--> ValidaciÃ³n de movimientos duplicados 11/03/2013

	SELECT b.quebranto_transaccion AS transaccion_quebranto
	INTO v_transaccion_quebranto
	FROM acl_movimiento a, acl_tipo_catalogo_transaccion b
	WHERE b.pky_tipo_catalogo_transaccion = a.fky_tipo_catalogo_transaccion 
    AND a.folio_csuac = v_folio_csuac
	AND a.fky_padre IS NULL
    AND b.quebranto_transaccion = 1 ;

	-- >> select * from acl_producto												-- C
	SELECT fky_tipo_producto, numero_cuenta, numero_tarjeta
	INTO v_fky_tipo_producto, v_numero_cuenta, v_numero_tarjeta
	FROM acl_producto 
	WHERE pky_producto = v_fky_producto;

	-- >> select * from acl_tipo_producto											-- C.C
	SELECT pky_tipo_producto, descripcion
	INTO v_pky_tipo_producto, v_des_tipo_producto
	FROM acl_tipo_producto
	WHERE pky_tipo_producto = v_fky_tipo_producto;
	
	-->> select * from acl_tipo_evento                                              -- D
	SELECT fky_origen_evento, pky_tipo_evento, descripcion as desc_evento
	INTO v_origen_evento, v_pky_tipo_evento, v_desc_evento
	FROM acl_tipo_evento
	WHERE pky_tipo_evento = v_fky_tipo_evento;
	
	-->> select * from acl_origen_evento                                            -- E
	SELECT descripcion as desc_origen_evento
	INTO v_desc_origen
	FROM acl_origen_evento
	WHERE pky_origen_evento = v_origen_evento;
	
	-->> select * from acl_estatus_aclaracion                                       -- F
	SELECT descripcion as desc_aclaracion
	INTO v_desc_aclaracion
	FROM acl_estatus_aclaracion
	WHERE pky_estatus_aclaracion = v_fky_estatus_aclaracion;
	
	-->> select * from acl_estatus_corporativo                                      -- G
	SELECT pky_estatus_corporativo
	INTO v_pky_estatus_corporativo
	FROM acl_estatus_corporativo
	WHERE pky_estatus_corporativo = v_fky_estatus_corp_general;
	
	-->> select * from acl_tipo_codigo_resolucion                                   -- H
	SELECT codigo_resolucion, descripcion as desc_resolucion, tipo_procedente
	INTO v_codigo_resolucion, v_desc_resolucion, v_tipo_procedente
	FROM acl_tipo_codigo_resolucion
	WHERE pky_tipo_codigo_resolucion = v_fky_tipo_codigo_resolucion;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n no duplicar aclaraciones dictaminadas y ya reportadas.
	
	SELECT folio_csuac, fky_estatus_aclaracion
	INTO v_folio_csuac_r27, v_fky_estatus_aclaracion_r27
	FROM acl_regulatorio27 
	WHERE folio_csuac = v_folio_csuac 
	AND fky_estatus_aclaracion in(3,4,5);
	
	IF v_fky_estatus_aclaracion_r27 in (3,4,5) THEN 

		CONTINUE FOREACH;
	
	END IF;
				
		--CONTINUE FOREACH;
		
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto recuperados -- ok

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_transaccion_quebranto <> 1 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac;

    END IF;

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_fky_estatus_corp_general <> 19 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac 
		AND v_procede = 1; -- ValidaciÃ³n para finalizadas

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por abono sin autorizaciÃ³n -- ok

    IF v_fky_estatus_aclaracion IN (3,4,5) AND v_fky_estatus_corp_general = 19 THEN

        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion a
        WHERE folio_csuac = v_folio_csuac;

        SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '653';

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por selecciÃ³n de transacciÃ³n -- ok

    IF v_transaccion_quebranto = 1 THEN
    
        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion
        WHERE folio_csuac = v_folio_csuac;

    END IF;

--- >> Formateo de Campos

    IF v_quebranto_inst IS NULL THEN    -- ValidaciÃ³n de monto quebrantado para que no se coloque en null
        LET v_quebranto_inst = 0;
    END IF;

    IF v_montoprocedente IS NULL THEN   -- ValidaciÃ³n de monto procedente para que no se coloque en null
        LET v_montoprocedente = 0;
    END IF;

    IF v_importe_rec IS NULL THEN       -- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_importe_rec = 0;
    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aclaraciones Concluidas sin Procede a favor del cliente por Abono sin AutorizaciÃ³n -- ok
	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_procede IS NULL AND v_fky_estatus_corp_general = 19 THEN
	
	LET v_procede = 1 ; -- Abono a favor del Cliente
	
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito
{	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) THEN
	
	SELECT SUM (monto) 
	INTO v_importereclamado
	FROM acl_movimiento WHERE folio_csuac = v_folio_csuac;
		
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito Procedentes

	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) AND v_procede = 1 AND v_montoprocedente <> v_importe_rec THEN
	
	LET v_montoprocedente = v_importe_rec ;
		
	END IF;-
}	

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n Aclaraciones pendientes y/o concluidas despuÃ©s de el periodo a reportar no mostrar datos innecesarios
	 IF v_fky_estatus_aclaracion = 2 OR DATE (v_fecha_dictamen) > pFechaCap_Fin THEN -- Agregada
	    SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '654';

		LET v_montoprocedente 	= 0;    -- ValidaciÃ³n de monto procedente para que no se coloque en null    
        LET v_importe_rec 		= 0;	-- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_quebranto_inst 	= 0;	-- ValidaciÃ³n de monto quebrantado para que no se coloque en null
		LET v_fecha_abono 		= '';
		LET v_fecha_dictamen	= ''; 	-- Agregada
		LET v_procede 			= ''; 	-- Agregada 
		
			IF v_fky_estatus_aclaracion > 2 THEN 
			
				SELECT descripcion as desc_aclaracion  
				INTO v_desc_aclaracion				-- Cambiar la descripciÃ³n de estatus de la aclaraciÃ³n a Ingresada
				FROM acl_estatus_aclaracion
				WHERE pky_estatus_aclaracion = 2;	
				
				LET v_fky_estatus_aclaracion = 2;	-- Cambiar estatus de la aclaraciÃ³n a 2
			
			END IF;

    END IF;

	
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Adecuaciones para aclaraciones correspondientes a productos '1900' y '2200' para capturarlos como "Cuentas de Cheques" por peticiÃ³n de usuario 24/09/2014 <<<<<<<<<<<<<
IF (SUBSTR (v_numero_cuenta , 0, 4) IN ('1900', '2200') AND v_numero_tarjeta = '' OR v_numero_tarjeta IS NULL) THEN
	LET v_pky_tipo_producto = 4;
	LET v_des_tipo_producto = 'Cuentas de Cheques';
END IF;
--------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO acl_regulatorio27
	VALUES (v_folio_csuac, v_fechacaptura, v_fechahora, v_numero_cuenta, v_numero_tarjeta, v_pky_tipo_producto, 
	v_des_tipo_producto, v_origen_evento, v_desc_origen, v_pky_tipo_evento, v_desc_evento, v_importereclamado, v_fky_estatus_aclaracion, 
	v_desc_aclaracion, v_procede, v_fecha_dictamen, v_fecha_abono, v_codigo_resolucion, v_desc_resolucion, v_montoprocedente, 
	v_importe_rec, v_quebranto_inst, v_fecha_inicio, v_fecha_fin, current);
	
	LET iContador = iContador + 1;
    IF iContador= 1000 THEN COMMIT WORK;
    LET iContador=0;
    BEGIN WORK;
    END IF;

END FOREACH

LET iContador=0;

-- No es posible convertir entre los tipos especificados
	
	--UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;

	LET CodRet = '00000';
	
	RETURN CodRet;
	
END PROCEDURE;