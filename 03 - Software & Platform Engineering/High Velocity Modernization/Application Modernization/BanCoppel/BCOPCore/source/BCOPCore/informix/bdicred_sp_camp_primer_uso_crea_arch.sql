CREATE PROCEDURE "informix".sp_camp_primer_uso_crea_arch(pempresa CHAR(3), pServicio CHAR(2), pMessinact SMALLINT, pdFechaHoy DATE)

RETURNING CHAR(6);

--Creado: MAHR. Mayo 2012 
-- Servicio 2 -> Campaña: 2 LlamadaBienvenida - Ctes con dias sin actividad en su TDC de: 30 a 59. Genera Archivo de llamadas.
-- Servicio 3 -> Campaña: 3 CorreoDirecto - Ctes con dias sin actividad en su TDC de: 60 a 119. Genera Inserto en edo cuenta.
-- Servicio 4 -> Campaña: 4 CrediEfectivo - Ctes con dias sin actividad en su TDC de: 120 a 149. Genera Archivo de llamadas.
-- Servicio 5 -> Campaña: 5 Recomprensa - Ctes con dias sin actividad en su TDC de: 150 a 179. Genera Inserto en edo cuenta.
-- Servicio 6 -> Campaña: 6 LlamadaPreCanc - Ctes con dias sin actividad en su TDC de: 180 a 209. Genera archivo de llamadas.
-- Servicio 7 -> Campaña: 7 PreCanc-1erBim - 1er bimestre de revision para clientes en Pre-Cancelacion de tarjeta.
-- Servicio 8 -> Campaña: 8 PreCanc-2doBim - 2do bimestre de revision para clientes en Pre-Cancelacion de tarjeta.
-- Servicio 9 -> Campaña: 9 Ctas_por_cancelar - Ctas por cancelar. Reporte de cuentas a cancelar automaticamente que no han tenido movimiento.

-- Junio 2012: Se agrega creacion de insertos variables: 7 y 8 para las campañas 3 y 5 correspondientemente.
-- Julio 2012: Se modifican posiciones de insertos para campañas 3 y 5. Se cambia extraccion de telefonos  a tabla: si_telefonos_actual.
-- Nov 2012: Se agregan servicios 7,8,9.

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnombreTelef			CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(8000);
DEFINE cSQL2                CHAR(8000);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cNum_Credito         CHAR(20);
DEFINE cNum_cte 			CHAR(20);
DEFINE cCod_Promocion       CHAR(3);
DEFINE cInsertoNuevo        CHAR(15);
DEFINE cInsertoTabla        CHAR(15);
DEFINE dfecha_gen_camp      DATE;
DEFINE dfecha_ejec_camp     DATE;
DEFINE dfecha_ent_desde     DATE;
DEFINE dfecha_ent_hasta     DATE;
DEFINE dfecha_cortemes      DATE;
DEFINE dfecha_aux_hasta     DATE;
DEFINE sParamNombArch       SMALLINT;
DEFINE sParamNombArchTelef  SMALLINT;
DEFINE sParamRutaArch       SMALLINT;
DEFINE sRango_ini_dias      SMALLINT;
DEFINE sRango_fin_dias      SMALLINT;
DEFINE sNum_logica          SMALLINT;
DEFINE sNumCampania         SMALLINT;
DEFINE vsPos_Inserto        SMALLINT;
DEFINE vsPos_Inserto3       SMALLINT;
DEFINE vsPos_Inserto5       SMALLINT;
DEFINE vsParamInsAct3       SMALLINT;
DEFINE vsParamInsAct5       SMALLINT;
DEFINE itot_tarj_entreg     INTEGER;
DEFINE itot_tarj_inact      INTEGER;
DEFINE itot_tarj_act        INTEGER;
DEFINE itotalregistros        INTEGER;
DEFINE Pnomarchivo			CHAR (30);
DEFINE viPrioridad      INTEGER;
DEFINE itot_tarj_contel 	INTEGER;
DEFINE itot_tarj_sintel 	INTEGER; 
DEFINE itot_tarj_act_contel INTEGER;
DEFINE itot_tarj_act_sintel INTEGER;
DEFINE itot_tarj_inact_contel INTEGER;
DEFINE itot_tarj_inact_sintel INTEGER;
DEFINE itot_tarj_canceladas INTEGER;
DEFINE itot_tarj_entreg_ina INTEGER;
DEFINE itot_tarj_act_contel_canceladas INTEGER;
DEFINE itot_tarj_act_sintel_canceladas INTEGER;
DEFINE itot_tarj_inact_contel_canceladas INTEGER;
DEFINE itot_tarj_inact_sintel_canceladas INTEGER;
DEFINE iRegistros INTEGER;
DEFINE itot_tarjcontel INTEGER; DEFINE itot_tarjsintel INTEGER;
DEFINE itot_tarjact_contel INTEGER; DEFINE itot_tarjact_sintel INTEGER;
DEFINE itot_tarjact_contel_canceladas INTEGER; DEFINE itot_tarjact_sintel_canceladas INTEGER;
DEFINE itot_tarjinact_contel_canceladas INTEGER; DEFINE itot_tarjinact_sintel_canceladas INTEGER; 

--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/sp_camp_primer_uso.out";
--TRACE ON;
--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0601';
LET cruta                   = "";
LET cnombre					= "";
LET cnombreTelef            = "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoejecsql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET cCod_RetIB              = '000000';

LET sParamNombArch          = 0;
LET sParamNombArchTelef     = 0;
LET sParamRutaArch          = 0;
LET sRango_ini_dias         = 0;
LET sRango_fin_dias         = 0;
LET sNumCampania            = 0;
LET cNum_Credito            = "";
let cNum_cte 				="";
LET cCod_Promocion          = "";
LET sNum_logica             = 0;
LET itot_tarj_entreg        = 0;
LET itot_tarj_inact         = 0;
LET itot_tarj_act           = 0;
LET itotalregistros           = 0;
LET vsPos_Inserto           = 0;       
LET vsPos_Inserto3          = 0;
LET vsPos_Inserto5          = 0;
LET vsParamInsAct3          = 0;
LET vsParamInsAct5          = 0;
LET cInsertoNuevo           = "";
LET cInsertoTabla           = "";
LET Pnomarchivo				= "";
LET viPrioridad    			= 0;
LET itot_tarj_contel		= 0;
LET itot_tarj_sintel		= 0;
LET itot_tarj_act_contel	= 0;
LET itot_tarj_act_sintel	= 0;
LET itot_tarj_inact_contel	= 0;
LET itot_tarj_inact_sintel	= 0;
LET itot_tarj_canceladas	= 0;
LET itot_tarj_entreg_ina 	= 0;
LET itot_tarj_act_contel_canceladas = 0;
LET itot_tarj_act_sintel_canceladas = 0;
LET itot_tarj_inact_contel_canceladas = 0;
LET itot_tarj_inact_sintel_canceladas = 0;
LET itot_tarjcontel= 0; LET itot_tarjsintel= 0;
LET itot_tarjact_contel= 0; LET itot_tarjact_sintel= 0;
LET itot_tarjact_contel_canceladas= 0; LET itot_tarjact_sintel_canceladas= 0;
LET itot_tarjinact_contel_canceladas= 0; LET itot_tarjinact_sintel_canceladas= 0;
LET iRegistros              = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
		
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio, '02') Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(pServicio, "") = "" OR pMessinact = 0 ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;
  
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND tipo_campania = 61 AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Valida si existe la tabla temporal a crear y la borra si existe para evitar errores.
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_temp_1er_uso_telef' ) THEN
        DROP TABLE bdicred:"informix".sd_temp_1er_uso_telef;
    END IF;

    LET sNumCampania = pServicio::SMALLINT; -- Asigna el numero de campaña en base al servicio
    -- Asigna parametros con nombres de archivos y ruta, dependiendo del servicio (subcampaña).

    IF pServicio = '02' THEN 
        LET sParamRutaArch = 1;
        LET sParamNombArch = 2;
        LET sParamNombArchTelef = 7;
    ELIF pServicio = '03' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 45; 
        LET sParamNombArchTelef = 8;
    ELIF pServicio = '04' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 4;
        LET sParamNombArchTelef = 9;
    ELIF pServicio = '05' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 5;
        LET sParamNombArchTelef = 10;
    ELIF pServicio = '06' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 6;
        LET sParamNombArchTelef = 11;
    ELIF pServicio = '07' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 31;
        LET sParamNombArchTelef = 34;
    ELIF pServicio = '08' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 32;
        LET sParamNombArchTelef = 35;
    ELIF pServicio = '09' THEN
        LET sParamRutaArch = 1;
        LET sParamNombArch = 33;
        LET sParamNombArchTelef = 36;
    END IF;

    IF  pServicio != '02' THEN -- Obtiene los datos: Fecha de campaña, fecha entregada desde, fecha entregadas hasta. para camp 2, se realiza el calculo.

        LET dfecha_ejec_camp = pdFechaHoy - pMessinact units month; -- Se obtiene la fecha de campaña de la campaña anterior ejecutada en el mes calculado
        SELECT first 1 fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta INTO dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta
                FROM bdicred:"informix".sd_camp_primer_uso WHERE month(fecha_ejecucion) = month(dfecha_ejec_camp)
                AND year(fecha_ejecucion) = year(dfecha_ejec_camp) AND num_campania = (sNumCampania - 1);
        IF dfecha_gen_camp IS NULL THEN     --  Termina proceso, ya que no existe campaña generada para esta fecha.
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'SIN CAMPAÑA ' || pServicio, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';
            RETURN cCod_Ret;
        END IF;

    END IF;

    -- Obtiene la ruta del archivo
	SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamRutaArch; 
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret = '104005';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo a generar con datos del cliente.
	SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArch; 
	IF NVL (cnombre,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo de telefonos a generar.
	SELECT TRIM(valor_alfabetico) INTO cnombreTelef FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
       AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArchTelef; 
	IF NVL (cnombreTelef,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Obtiene los parametros que indican el envio de insertos para campañas 3 y 5. 0 = No se envia insertos, 1 = Se envia insertos.
    SELECT valor_numerico INTO vsParamInsAct3 FROM bdicred:sd_param_campania WHERE empresa = pempresa AND grupo_parametro = 'ARCH1ERUSO' and num_parametro = 25;
    SELECT valor_numerico INTO vsParamInsAct5 FROM bdicred:sd_param_campania WHERE empresa = pempresa AND grupo_parametro = 'ARCH1ERUSO' and num_parametro = 30;

    -- Obtiene el codigo de la promocion y numero de logica de la misma.
    SELECT TRIM(valor_alfabetico) INTO cCod_Promocion FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'TIPO_PROM' AND num_parametro = 8;
    SELECT num_parametro INTO sNum_logica FROM sd_param_campania WHERE grupo_parametro = 'TIPOLOGICA' AND num_parametro = 8;

    IF pServicio = '02' THEN
                                    -- Obtiene el rango de dias sin actividad correspondiente a la campaña: 30 a 59 días.
        SELECT trim(valor_alfabetico)::SMALLINT, valor_numerico::SMALLINT INTO sRango_ini_dias, sRango_fin_dias
                FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 13;

                                    -- Obtiene fecha de campaña de sub-campaña 2 previa y se calcula fechas de subcampaña 2 actual.
        SELECT MAX(fecha_entreg_hasta) INTO dfecha_aux_hasta FROM bdicred:"informix".cb_1eruso_rep_seguim WHERE sub_campania = 2;

        LET dfecha_gen_camp  = pdFechaHoy;
        LET dfecha_ent_desde = (dfecha_aux_hasta + 1 units day);
        LET dfecha_ent_hasta = (dfecha_ent_desde + sRango_ini_dias units day);

                                    -- Valida que no existan registros ya procesados de la campaña nueva a generar (fechas calculadas).
        IF ( SELECT count(*) FROM bdicred:sd_camp_primer_uso WHERE fecha_gen_campania = dfecha_gen_camp AND num_campania = sNumCampania ) > 0 THEN
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'CAMPAÑA EXISTENTE ' || dfecha_gen_camp || ' ' || sNumCampania, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';
            RETURN cCod_Ret;
        END IF;

        INSERT INTO bdicred:"informix".sd_camp_primer_uso
            SELECT pempresa, pdFechaHoy, dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta, sNumCampania, c.num_credito, 
			CASE WHEN (( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )  
			AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) )) THEN 'INACT' ELSE 'ACTIV' END, 
                c.fecha_apertura, c.sucursal, c.numcte, tar.num_tarjeta, '0' Statusprom, 0 Prioridad, trim (cte.apell_paterno), 
                trim (cte.apell_materno), trim(cte.nombre1), trim(cte.nombre2), f.sexo, f.estado_civil, trim(co.correo_elec),
                edos.nombre, cds.nombreciudad, 0 Recompensa
                FROM bdicred:sd_maecred c 
				JOIN bdicred:sd_indicador_cred ind ON ( c.empresa = ind.empresa and c.num_credito = ind.num_credito and c.status_cred IN ('AA','E1'))
				JOIN bdicred:sd_maesdos maes ON (c.num_credito = maes.num_credito AND (maes.monto_vencido + maes.mto_venc_trasp) = 0 )                                                                                                        
                JOIN bdinteg:si_cliente cte ON (c.empresa = cte.empresa and  c.numcte = cte.numcte) 
                JOIN bdinteg:si_ctepf f ON (c.empresa = f.empresa and  c.numcte = f.numcte)
                JOIN bdinteg:si_direcciones_actual dir ON (c.numcte = dir.numcte and dir.tipo_dir = '1') 
                    join bdinteg:si_estados edos on (dir.pais = edos.pais and dir.estado = edos.estado)
                    join bdinteg:si_catciudades cds on ( dir.numerociudad = cds.numerociudad )
                LEFT OUTER JOIN bdicred:sd_tarjeta tar ON (c.empresa = tar.empresa and c.num_credito = tar.num_credito and tar.tipo_tarjeta = 'T' 
                            and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where c.empresa = empresa
                            and c.num_credito = num_credito and tipo_tarjeta = 'T'))
				LEFT OUTER JOIN bdinteg:si_correos co ON (c.empresa = co.empresa and  c.numcte = co.numcte
							and co.secuencia = (select max(secuencia) from  bdinteg:si_correos where empresa = c.empresa 
																			and numcte = c.numcte))
                WHERE c.empresa = pempresa
				  AND c.fecha_apertura between dfecha_ent_desde and dfecha_ent_hasta
				  AND c.num_producto = '6001';
                 -- AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )  
                  --AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )  
                  --AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) );
        
    ELSE

        -- Obtiene las tarjetas que siguen inactivas de la campaña anterior
       INSERT INTO bdicred:"informix".sd_camp_primer_uso	
			SELECT pempresa, pdFechaHoy, dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta, sNumCampania, a.num_credito,
			CASE WHEN (( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )  
			AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) )) THEN 'INACT' ELSE 'ACTIV' END, 
				a.fecha_apertura, a.sucursal, a.numcte, a.num_tarjeta, '0' Statusprom, 0 Prioridad, trim (a.ap_paterno), 
                trim (a.ap_materno), trim(a.primer_nombre), trim(a.segundo_nombre), a.sexo, a.estado_civil, trim(a.email), a.estado, a.ciudad, 0 Recompensa
                FROM bdicred:sd_camp_primer_uso a
				JOIN bdicred:sd_indicador_cred ind on ( ind.empresa = a.empresa and ind.num_credito = a.num_credito)
				WHERE a.empresa = '001'
				AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde
				 AND a.fecha_entreg_hasta = dfecha_ent_hasta
				AND a.num_credito in (select cred.num_credito 
				                        FROM bdicred:sd_maecred cred 
				                  INNER JOIN bdicred:sd_maesdos maes on (maes.num_credito =cred.num_credito)
				                       where cred.empresa = a.empresa and cred.num_credito = a.num_credito 
									     and cred.status_cred IN ('AA','E1') AND (maes.monto_vencido + maes.mto_venc_trasp) = 0)
				AND a.num_campania = (sNumCampania - 1); --AND a.status_tarj = 'INACT'
				--AND dos.sdo_cap_insoluto <= 0 AND anex.fecha_ult_pago isnull;
				--AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )
				--AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) );

    END IF;
    
    -- Crea tabla y llena informacion de telefonos de los clientes, segun la campaña correspondiente.
    Create table bdicred:"informix".sd_temp_1er_uso_telef (  
        num_credito       CHAR(20), numcte                CHAR(20), tipo_telefono CHAR(1),  tipo_red  CHAR(1), 
        telefono_original1 char(13),telefono_original2 char(13),telefono_original3 char(13),telefono_original4 char(13),
		telefono_reconstruido1 CHAR(13), telefono_reconstruido2 CHAR(13), telefono_reconstruido3 CHAR(13), telefono_reconstruido4 CHAR(13),
		carrier       CHAR(3),  extension CHAR(5), secuencia smallint)extent size 32 next size 32;
        create index "informix".inx_1eruso_tipotel on sd_temp_1er_uso_telef(num_credito, tipo_telefono);
        create index "informix".inx_1eruso_cred_tel on sd_temp_1er_uso_telef(num_credito);

    -- Se obtienen los registros de los telefonos de cada cliente. // Telefono 1 Casa-Fijo, 3 trab-Fijo 2 cel y 4 (movil)-
    INSERT INTO bdicred:sd_temp_1er_uso_telef 
        SELECT prim.num_credito, prim.numcte, tel1.tipo_tel::CHAR, decode(tel1.tipo_tel,1,'F',3,'F','M') tipo_red, 
            case when bdinteg:val_num(substr(tel1.telefono,length(tel1.telefono)-9,10)) then substr(tel1.telefono,length(tel1.telefono)-9,10) else '' end telefono_original1,
            case when bdinteg:val_num(substr(tel2.telefono,length(tel2.telefono)-9,10)) then substr(tel2.telefono,length(tel2.telefono)-9,10) else '' end telefono_original2, 
            case when bdinteg:val_num(substr(tel3.telefono,length(tel3.telefono)-9,10)) then substr(tel3.telefono,length(tel3.telefono)-9,10) else '' end telefono_original3, 
            case when bdinteg:val_num(substr(tel4.telefono,length(tel4.telefono)-9,10)) then substr(tel4.telefono,length(tel4.telefono)-9,10) else '' end telefono_original4, 
            case when bdinteg:val_num(substr(tel1.telefono,length(tel1.telefono)-9,10)) then substr(tel1.telefono,length(tel1.telefono)-9,10) else '' end telefono_Reconstruido1,
            case when bdinteg:val_num(substr(tel2.telefono,length(tel2.telefono)-9,10)) then substr(tel2.telefono,length(tel2.telefono)-9,10) else '' end telefono_Reconstruido2,
            case when bdinteg:val_num(substr(tel3.telefono,length(tel3.telefono)-9,10)) then substr(tel3.telefono,length(tel3.telefono)-9,10) else '' end telefono_Reconstruido3,
            case when bdinteg:val_num(substr(tel4.telefono,length(tel4.telefono)-9,10)) then substr(tel4.telefono,length(tel4.telefono)-9,10) else '' end telefono_Reconstruido4,
            NVL(tel1.carrier,''), NVL(tel3.extension, ''), tel1.secuencia
        FROM bdicred:sd_camp_primer_uso prim 
		LEFT JOIN bdinteg:si_telefonos_actual tel1 on (tel1.numcte = prim.numcte and tel1.tipo_tel = 1 
                    and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual tel where numcte = prim.numcte and tipo_tel = 1 )
              AND tel1.status_tel = 'A' AND tel1.cofetel = 'V'  AND trim(tel1.telefono) <> '')
		LEFT JOIN bdinteg:si_telefonos_actual tel2 on (tel2.numcte= prim.numcte and tel2.tipo_tel = 2 
                    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual tel where numcte = prim.numcte and tipo_tel = 2)
              AND tel2.status_tel = 'A' AND tel2.cofetel = 'V'  AND trim(tel2.telefono) <> '' ) 
		LEFT JOIN bdinteg:si_telefonos_actual tel3 on (tel3.numcte= prim.numcte and tel3.tipo_tel = 3 
                    and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual tel where numcte = prim.numcte and tipo_tel = 3)
              AND tel3.status_tel = 'A' AND tel3.cofetel = 'V'  AND trim(tel3.telefono) <> '')
		LEFT JOIN bdinteg:si_telefonos_actual tel4 on (tel4.numcte= prim.numcte and tel4.tipo_tel = 4 
                    and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual tel where numcte = prim.numcte and tipo_tel = 4)
              AND tel4.status_tel = 'A' AND tel4.cofetel = 'V'  AND trim(tel4.telefono) <> '')
        WHERE prim.empresa = pempresa AND prim.fecha_gen_campania = dfecha_gen_camp AND prim.fecha_entreg_desde = dfecha_ent_desde
		  AND prim.fecha_entreg_hasta = dfecha_ent_hasta AND prim.num_campania = sNumCampania;
    
-- NO elimina registros de clientes que no tuvieron telefonos. Se actualiza su status como Sin Telefono (NTLF)
    -- Si no se genero información de telefonos, termina el proceso para no generar archivo vacio y no actualiza ningun registro.
    IF( Select count(num_credito) From bdicred:sd_temp_1er_uso_telef ) = 0 THEN
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'SIN INFORMACION ' || pServicio, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';
        RETURN cCod_Ret;
    END IF;

    -- Elimina registros q se hayan generado sin telefonos, de la tabla temporal, para identificar los registros sin telefonos
	DELETE from bdicred:"informix".sd_temp_1er_uso_telef where nvl(telefono_original1,'') ='' and nvl(telefono_original2,'')='' 
                                                               and nvl(telefono_original3,'')='' and nvl(telefono_original4,'')='';
	
    -- Marca los clientes sin Telefono o telefono no Valido. status = INACT = Tarjeta Inactiva. Sin telefono Valido o sin telefono = NTLF.
   --UPDATE bdicred:"informix".sd_camp_primer_uso SET status_tarj = 'NOTLF' WHERE empresa = pempresa AND fecha_gen_campania = dfecha_gen_camp 
     --   AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta AND num_campania = sNumCampania 
       -- AND num_credito NOT IN (Select num_credito from bdicred:sd_temp_1er_uso_telef );
	

	------------------------------------------------------------------------------------------------------------
    -- GENERA INFORMACION PARA EL REPORTE DE SEGUIMIENTO DE LA CAMPAÑA EN PROCESO.
	------------------------------------------------------------------------------------------------------------
					
		LET dfecha_gen_camp = dfecha_gen_camp;
		LET dfecha_ent_desde = dfecha_ent_desde;
		LET dfecha_ent_hasta = dfecha_ent_hasta;
		LET sNumCampania = sNumCampania;
		
 -- Tarjetas con telefono
		SELECT count(a.num_credito) INTO itot_tarj_contel
            FROM bdicred:"informix".sd_camp_primer_uso a
			WHERE a.empresa = pempresa
			AND a.num_credito in (select num_credito from bdicred:sd_temp_1er_uso_telef) 
			AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania;
			
-- Tarjetas sin telefono
			SELECT count(a.num_credito) INTO itot_tarj_sintel
            FROM bdicred:"informix".sd_camp_primer_uso a
			WHERE a.empresa = pempresa
			AND a.num_credito NOT IN  (select num_credito from bdicred:sd_temp_1er_uso_telef) 
			AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania;
			
-- tarjetas entregadas
		LET	itot_tarj_entreg_ina = itot_tarj_contel + itot_tarj_sintel;
		
--Total inactivas con tel	
		SELECT count(num_credito) INTO itot_tarj_inact_contel FROM bdicred:sd_camp_primer_uso WHERE empresa = pempresa 
            AND fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta
			AND num_campania = sNumCampania AND status_tarj = 'INACT'
			AND num_credito in (select num_credito from bdicred:sd_temp_1er_uso_telef)
			and num_credito not in (select num_credito from sd_maecred where status_cred = 'FF');
--Total inactivas sin tel			
		SELECT count(num_credito) INTO itot_tarj_inact_sintel FROM bdicred:sd_camp_primer_uso WHERE empresa = pempresa 
            AND fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta
			AND num_campania = sNumCampania AND status_tarj = 'INACT'
			AND num_credito NOT  in (select num_credito from bdicred:sd_temp_1er_uso_telef)
		and num_credito not in (select num_credito from sd_maecred where status_cred = 'FF');

--Tarjetas activas con teléfono canceladas 
		SELECT count(a.num_credito) INTO itot_tarj_act_contel_canceladas
            FROM bdicred:sd_camp_primer_uso a
            JOIN bdicred:sd_maecred c on (a.empresa = c.empresa and a.num_credito = c.num_credito) 
            WHERE a.empresa = pempresa AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania AND a.status_tarj = 'ACTIV'
			AND c.status_cred = 'FF'
			AND a.num_credito in (select num_credito from bdicred:sd_temp_1er_uso_telef)	
			AND c.fecha_apertura between dfecha_ent_desde and dfecha_ent_hasta;
			
--Tarjetas activas sin teléfono canceladas 
		SELECT count(a.num_credito) INTO itot_tarj_act_sintel_canceladas
            FROM bdicred:sd_camp_primer_uso a
            JOIN bdicred:sd_maecred c on (a.empresa = c.empresa and a.num_credito = c.num_credito) 
            WHERE a.empresa = pempresa AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania AND a.status_tarj = 'ACTIV'
			AND c.status_cred = 'FF'
			AND a.num_credito not in (select num_credito from bdicred:sd_temp_1er_uso_telef)
			AND c.fecha_apertura between dfecha_ent_desde and dfecha_ent_hasta;
			
--Tarjetas inactivas con teléfono canceladas 
SELECT count(a.num_credito) INTO itot_tarj_inact_contel_canceladas
            FROM bdicred:sd_camp_primer_uso a
            JOIN bdicred:sd_maecred c on (a.empresa = c.empresa and a.num_credito = c.num_credito) 
            WHERE a.empresa = pempresa AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania AND a.status_tarj = 'INACT'
			AND c.status_cred = 'FF'
			AND a.num_credito in (select num_credito from bdicred:sd_temp_1er_uso_telef)	
			AND c.fecha_apertura between dfecha_ent_desde and dfecha_ent_hasta;
			
--Tarjetas inactivas sin teléfono canceladas 
SELECT count(a.num_credito) INTO itot_tarj_inact_sintel_canceladas
            FROM bdicred:sd_camp_primer_uso a
            JOIN bdicred:sd_maecred c on (a.empresa = c.empresa and a.num_credito = c.num_credito) 
            WHERE a.empresa = pempresa AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde 
			AND a.fecha_entreg_hasta = dfecha_ent_hasta
			AND a.num_campania = sNumCampania AND a.status_tarj = 'INACT'
			AND c.status_cred = 'FF'
			AND a.num_credito not in (select num_credito from bdicred:sd_temp_1er_uso_telef)
			AND c.fecha_apertura between dfecha_ent_desde and dfecha_ent_hasta;
			
 --Total activas con tel		
		LET itot_tarj_act_contel  = itot_tarj_contel - itot_tarj_inact_contel - itot_tarj_act_contel_canceladas - itot_tarj_inact_contel_canceladas;
 --Total activas sin tel
		LET itot_tarj_act_sintel  = itot_tarj_sintel - itot_tarj_inact_sintel - itot_tarj_act_sintel_canceladas - itot_tarj_inact_sintel_canceladas;

			
--Tarjetas activas de los campos que no se usan
			SELECT count(num_credito) INTO itot_tarj_inact FROM bdicred:sd_camp_primer_uso WHERE empresa = pempresa 
            AND fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta
			AND num_campania = sNumCampania AND status_tarj = 'INACT';	
					
        LET itot_tarj_act = itot_tarj_entreg - itot_tarj_inact;
			
    IF pServicio = '02' THEN
		LET itot_tarj_entreg = itot_tarj_entreg_ina;   

        -- Inserta informacion para generacion de reporte. La informacion generada en este punto corresponde a campaña = 1. Camp = 2 queda pendiente
        -- el numero de tarjetas inactivas, ya que se conoce hasta la campaña 3.
        INSERT INTO bdicred:"informix".cb_1eruso_rep_seguim(fecha_gen_campania, fecha_ejecucion, fecha_entreg_desde, fecha_entreg_hasta, 
                sub_campania, tot_tarj_entregadas, tot_tarj_activas, tot_tarj_inactivas, porcentaje_efec,tot_tarj_entreg_ina,
				tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel,
				tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel,tot_tarj_act_contel_canceladas, tot_tarj_act_sintel_canceladas,
				tot_tarj_inact_contel_canceladas, tot_tarj_inact_sintel_canceladas)
            VALUES(dfecha_gen_camp, pdFechaHoy, dfecha_ent_desde, dfecha_ent_hasta, (sNumCampania - 1), itot_tarj_entreg, itot_tarj_act, 
                itot_tarj_inact, (((itot_tarj_entreg - itot_tarj_inact) / itot_tarj_entreg) * 100)::INTEGER, itot_tarj_entreg_ina,
				itot_tarj_contel,
				itot_tarj_sintel, itot_tarj_act_contel, itot_tarj_act_sintel, itot_tarj_inact_contel, itot_tarj_inact_sintel, 
				itot_tarj_act_contel_canceladas,itot_tarj_act_sintel_canceladas,itot_tarj_inact_contel_canceladas,itot_tarj_inact_sintel_canceladas);
                -- k * 100

        -- Inserta informacion de campaña 2
        LET itot_tarj_entreg = itot_tarj_inact; -- Las inactivas de la campaña 1 son las entregadas de la campaña 2.
        LET itot_tarj_inact = NULL;  -- Se inserta con NULL campaña 2 ya que no se cuenta con la informacion hasta la prox campaña.
        LET itot_tarj_act   = NULL;
		
		LET itot_tarj_entreg_ina = itot_tarj_inact_contel + itot_tarj_inact_sintel; 
		LET itot_tarj_contel =  itot_tarj_inact_contel;
		LET itot_tarj_sintel = itot_tarj_inact_sintel;  
		--LET itot_tarj_contel = NULL; 
		--LET itot_tarj_sintel = NULL; 
        LET itot_tarj_inact_contel = NULL;  -- Se inserta con NULL campaña 2 ya que no se cuenta con la informacion hasta la prox campaña.
        LET itot_tarj_act_contel   = NULL;
		LET itot_tarj_inact_sintel = NULL;
        LET itot_tarj_act_sintel   = NULL;
		--LET itot_tarj_canceladas   = NULL;
		LET itot_tarj_act_contel_canceladas = NULL;
		LET itot_tarj_act_sintel_canceladas = NULL;
		LET itot_tarj_inact_contel_canceladas = NULL;
		LET itot_tarj_inact_sintel_canceladas = NULL;
           
				
        INSERT INTO bdicred:"informix".cb_1eruso_rep_seguim(fecha_gen_campania, fecha_ejecucion, fecha_entreg_desde, fecha_entreg_hasta, 
                sub_campania, tot_tarj_entregadas, tot_tarj_activas, tot_tarj_inactivas, porcentaje_efec,tot_tarj_entreg_ina,
				tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel,
				tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel,tot_tarj_act_contel_canceladas, tot_tarj_act_sintel_canceladas,
				tot_tarj_inact_contel_canceladas, tot_tarj_inact_sintel_canceladas)
            VALUES(dfecha_gen_camp, pdFechaHoy, dfecha_ent_desde, dfecha_ent_hasta, sNumCampania, itot_tarj_entreg, itot_tarj_act, 
                itot_tarj_inact, NULL,itot_tarj_entreg_ina,itot_tarj_contel,
				itot_tarj_sintel, itot_tarj_act_contel, itot_tarj_act_sintel, itot_tarj_inact_contel, itot_tarj_inact_sintel, 
				itot_tarj_act_contel_canceladas,itot_tarj_act_sintel_canceladas,itot_tarj_inact_contel_canceladas,itot_tarj_inact_sintel_canceladas);
                

    ELSE
  
		LET itot_tarj_entreg = itot_tarj_inact ;
		LET itot_tarj_entreg_ina = itot_tarj_inact_contel + itot_tarj_inact_sintel; 
		LET itot_tarj_contel =  itot_tarj_inact_contel;
		LET itot_tarj_sintel = itot_tarj_inact_sintel;
		
		--Se realiza la resta de las activas de la campaña anterior
		SELECT tot_tarj_contel,tot_tarj_sintel
		INTO itot_tarjcontel,itot_tarjsintel
		FROM bdicred:cb_1eruso_rep_seguim WHERE fecha_gen_campania = dfecha_gen_camp 
		AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		AND sub_campania = (sNumCampania - 1); 
		
		SELECT tot_tarj_activas_contel, tot_tarj_activas_sintel,tot_tarj_act_contel_canceladas,
		tot_tarj_act_sintel_canceladas,tot_tarj_inact_contel_canceladas,tot_tarj_inact_sintel_canceladas
		INTO itot_tarjact_contel,itot_tarjact_sintel,itot_tarjact_contel_canceladas,
		itot_tarjact_sintel_canceladas,itot_tarjinact_contel_canceladas,itot_tarjinact_sintel_canceladas
		FROM bdicred:cb_1eruso_rep_seguim WHERE fecha_gen_campania = dfecha_gen_camp 
		AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		AND sub_campania = 1;		
        -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
		UPDATE bdicred:cb_1eruso_rep_seguim SET tot_tarj_inactivas = itot_tarj_entreg, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_entreg),
                porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_entreg) / tot_tarj_entregadas) * 100)::INTEGER, -- itot_tarj_entreg = inactivas de camp anterior
                --tot_tarj_entreg_ina = itot_tarj_entreg_ina,
				--tot_tarj_contel = (tot_tarj_contel + itot_tarj_act_contel_canceladas + itot_tarj_inact_contel_canceladas),
				--tot_tarj_sintel = (tot_tarj_sintel + itot_tarj_act_sintel_canceladas + itot_tarj_inact_sintel_canceladas), 
				/*tot_tarj_activas_contel = (itot_tarj_act_contel - itot_tarjact_contel),
				tot_tarj_activas_sintel = (itot_tarj_act_sintel - itot_tarjact_sintel),*/
				
				tot_tarj_inactivas_contel = itot_tarj_inact_contel, 
				tot_tarj_inactivas_sintel = itot_tarj_inact_sintel,--tot_tarj_canceladas = itot_tarj_canceladas
				
				tot_tarj_act_contel_canceladas = itot_tarj_act_contel_canceladas,
				tot_tarj_act_sintel_canceladas = itot_tarj_act_sintel_canceladas,
				tot_tarj_inact_contel_canceladas = itot_tarj_inact_contel_canceladas,
				tot_tarj_inact_sintel_canceladas = itot_tarj_inact_sintel_canceladas
				
				WHERE fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
				AND sub_campania = (sNumCampania - 1); 
				
		-- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior 
		UPDATE bdicred:cb_1eruso_rep_seguim SET
				tot_tarj_activas_contel = case when(tot_tarj_contel - tot_tarj_inactivas_contel - tot_tarj_act_contel_canceladas - tot_tarj_inact_contel_canceladas) < 0 
				THEN ((tot_tarj_contel - tot_tarj_inactivas_contel - tot_tarj_act_contel_canceladas - tot_tarj_inact_contel_canceladas) * -1) 
				ELSE (tot_tarj_contel - tot_tarj_inactivas_contel - tot_tarj_act_contel_canceladas - tot_tarj_inact_contel_canceladas) END , 
				tot_tarj_activas_sintel = case when (tot_tarj_sintel - tot_tarj_inactivas_sintel - tot_tarj_act_sintel_canceladas - tot_tarj_inact_sintel_canceladas) < 0 
				THEN ((tot_tarj_sintel - tot_tarj_inactivas_sintel - tot_tarj_act_sintel_canceladas - tot_tarj_inact_sintel_canceladas) * -1) 
				ELSE  (tot_tarj_sintel - tot_tarj_inactivas_sintel - tot_tarj_act_sintel_canceladas - tot_tarj_inact_sintel_canceladas) END
				WHERE fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
				AND sub_campania = (sNumCampania - 1); 
				
		SELECT tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel 
		INTO itot_tarj_contel,itot_tarj_sintel
		FROM bdicred:cb_1eruso_rep_seguim WHERE fecha_gen_campania = dfecha_gen_camp 
		AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		AND sub_campania = (sNumCampania - 1); 
		
		LET itot_tarj_entreg_ina = itot_tarj_contel + itot_tarj_sintel; 
		
            -- Inserta datos de reporte de campaña actual
        LET itot_tarj_inact = NULL;  -- Se inserta con NULL ya que no se cuenta con la informacion hasta la prox campaña.
        LET itot_tarj_act   = NULL;
		--LET itot_tarj_contel = NULL; 
		--LET itot_tarj_sintel = NULL; 
		LET itot_tarj_inact_contel = NULL;
        LET itot_tarj_act_contel   = NULL;
		LET itot_tarj_inact_sintel = NULL;
        LET itot_tarj_act_sintel   = NULL;
		--LET itot_tarj_canceladas   = NULL;
		LET itot_tarj_act_contel_canceladas = NULL;
		LET itot_tarj_act_sintel_canceladas = NULL;
		LET itot_tarj_inact_contel_canceladas = NULL;
		LET itot_tarj_inact_sintel_canceladas = NULL;
                

        INSERT INTO bdicred:"informix".cb_1eruso_rep_seguim(fecha_gen_campania, fecha_ejecucion, fecha_entreg_desde, fecha_entreg_hasta, 
                sub_campania, tot_tarj_entregadas, tot_tarj_activas, tot_tarj_inactivas, porcentaje_efec,tot_tarj_entreg_ina,
				tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel,
				tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel,tot_tarj_act_contel_canceladas, tot_tarj_act_sintel_canceladas,
				tot_tarj_inact_contel_canceladas, tot_tarj_inact_sintel_canceladas)
            VALUES(dfecha_gen_camp, pdFechaHoy, dfecha_ent_desde, dfecha_ent_hasta, sNumCampania, itot_tarj_entreg, itot_tarj_act, itot_tarj_inact, NULL,
				--itot_tarj_entreg,
				itot_tarj_entreg_ina,
				itot_tarj_contel,itot_tarj_sintel, itot_tarj_act_contel, itot_tarj_act_sintel, itot_tarj_inact_contel, itot_tarj_inact_sintel, 
				itot_tarj_act_contel_canceladas,itot_tarj_act_sintel_canceladas,itot_tarj_inact_contel_canceladas,itot_tarj_inact_sintel_canceladas);
    END IF;	

	------------------------------------------------------------------------------------------------------------
    -- GENERA REPORTE DE CLIENTES O INSERTOS SEGUN SEA LA CAMPAÑA
	------------------------------------------------------------------------------------------------------------
    
    -- Genera insertos variables para los ESTADOS DE CUENTA para campañas 3 CorreoDirecto y 5 Recomprensa
    IF pServicio = '03' AND vsParamInsAct3 = 1 THEN

        SELECT trim(valor_alfabetico)::SMALLINT INTO vsPos_Inserto3 FROM bdicred:sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 26;

        LET vsPos_Inserto = vsPos_Inserto3; -- Posicion 7 de insertos (Insertos de 1 a pos 15)
        LET dfecha_cortemes = mdy(month(pdFechaHoy), 20, year(pdFechaHoy));

        FOREACH
            SELECT num_credito INTO cNum_Credito FROM bdicred:sd_camp_primer_uso WHERE fecha_gen_campania = dfecha_gen_camp 
            AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta AND num_campania = sNumCampania

            SELECT insertos INTO cInsertoTabla FROM bdicred:sd_marcaje WHERE num_credito = cNum_Credito AND fecha_emision = dfecha_cortemes;

            IF NVL(cInsertoTabla, 0) = 0 OR trim(cInsertoTabla) = '' THEN
                LET cInsertoTabla = '000000000000000';
                LET cInsertoNuevo = SubStr(trim(cInsertoTabla), 1, vsPos_Inserto - 1 ) || '1' || 
                                    SubStr(trim(cInsertoTabla), vsPos_Inserto + 1, length(trim(cInsertoTabla)));

                INSERT INTO bdicred:sd_marcaje(empresa,num_credito,fecha_emision,posicion,insertos)
                            VALUES (pempresa, cNum_Credito, dfecha_cortemes, 0, cInsertoNuevo);

            ELSE
                LET cInsertoNuevo = SubStr(trim(cInsertoTabla), 1, vsPos_Inserto - 1 ) || '1' || 
                                    SubStr(trim(cInsertoTabla), vsPos_Inserto + 1, length(trim(cInsertoTabla)));

                UPDATE bdicred:sd_marcaje SET insertos = cInsertoNuevo WHERE num_credito = cNum_Credito AND fecha_emision = dfecha_cortemes;

            END IF;
        END FOREACH;

    ELIF ( pServicio = '05' AND vsParamInsAct5 = 1 ) THEN

        SELECT valor_numerico INTO vsPos_Inserto5 FROM bdicred:sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 26;
        LET vsPos_Inserto = vsPos_Inserto5; -- Posicion 8 de insertos (Insertos de 1 a pos 15)
        LET dfecha_cortemes = mdy(month(pdFechaHoy), 20, year(pdFechaHoy));

        FOREACH
            SELECT num_credito INTO cNum_Credito FROM bdicred:sd_camp_primer_uso WHERE fecha_gen_campania = dfecha_gen_camp 
            AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta AND num_campania = sNumCampania

            SELECT insertos INTO cInsertoTabla FROM bdicred:sd_marcaje WHERE num_credito = cNum_Credito AND fecha_emision = dfecha_cortemes;

            IF NVL(cInsertoTabla, 0) = 0 OR trim(cInsertoTabla) = '' THEN
                LET cInsertoTabla = '000000000000000';
                LET cInsertoNuevo = SubStr(trim(cInsertoTabla), 1, vsPos_Inserto - 1 ) || '1' || 
                                    SubStr(trim(cInsertoTabla), vsPos_Inserto + 1, length(trim(cInsertoTabla)));

                INSERT INTO bdicred:sd_marcaje(empresa,num_credito,fecha_emision,posicion,insertos)
                            VALUES (pempresa, cNum_Credito, dfecha_cortemes, 0, cInsertoNuevo);

            ELSE
                LET cInsertoNuevo = SubStr(trim(cInsertoTabla), 1, vsPos_Inserto - 1 ) || '1' || 
                                    SubStr(trim(cInsertoTabla), vsPos_Inserto + 1, length(trim(cInsertoTabla)));

                UPDATE bdicred:sd_marcaje SET insertos = cInsertoNuevo WHERE num_credito = cNum_Credito AND fecha_emision = dfecha_cortemes;

            END IF;
        END FOREACH;
    END IF;

    -- Genera el ARCHIVO de campaña con los datos de los clientes a partir de los almacenado. Archivo a enviar al CAT
    --ELIF (pServicio != '03' AND pServicio != '05') THEN       
    IF pServicio IN ('02', '03', '04', '05', '06', '07', '08', '09') THEN

	    update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original1 = replace(telefono_original1, chr(09),'');
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original2 = replace(telefono_original2, chr(09),'');
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original3 = replace(telefono_original3, chr(09),'');
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original4 = replace(telefono_original4, chr(09),'');
	
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original2 = '' where nvl(telefono_original1,'')= nvl(telefono_original2,'');
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original3 = '' where nvl(telefono_original3,'')= nvl(telefono_original2,'') 
                                                                                       or nvl(telefono_original3,'')= nvl(telefono_original1,'');
        update bdicred:"informix".sd_temp_1er_uso_telef set telefono_original4 = '' where nvl(telefono_original1,'')= nvl(telefono_original4,'') 
                            or nvl(telefono_original2,'')= nvl(telefono_original4,'')  or nvl(telefono_original3,'')= nvl(telefono_original4,''); 

        update sd_temp_1er_uso_telef 
            set telefono_original4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_original4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_original4,1,2) else SUBSTR(telefono_original4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_original4,1,2) in ('55','33','81')  then SUBSTR(telefono_original4,3,4) else SUBSTR(telefono_original4,4,3) end 
						   AND (SUBSTR(telefono_original4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_original4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_original4 ,
			telefono_original1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_original1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_original1,1,2) else SUBSTR(telefono_original1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_original1,1,2) in ('55','33','81')  then SUBSTR(telefono_original1,3,4) else SUBSTR(telefono_original1,4,3) end 
						   AND (SUBSTR(telefono_original1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_original1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_original1 ,		 
			telefono_original2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_original2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_original2 ,1,2) else SUBSTR(telefono_original2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_original2 ,1,2) in ('55','33','81')  then SUBSTR(telefono_original2 ,3,4) else SUBSTR(telefono_original2,4,3) end 
						   AND (SUBSTR(telefono_original2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_original2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_original2 ,
			telefono_original3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_original3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_original3,1,2) else SUBSTR(telefono_original3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_original3,1,2) in ('55','33','81')  then SUBSTR(telefono_original3,3,4) else SUBSTR(telefono_original3,4,3) end 
						   AND (SUBSTR(telefono_original3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_original3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_original3; 
			
		update sd_temp_1er_uso_telef
		set telefono_original4 = decode(telefono_original4,'',null, telefono_original4),
			telefono_original1 = decode(telefono_original1,'',null, telefono_original1), 
			telefono_original2 = decode(telefono_original2,'',null, telefono_original2),
			telefono_original3 = decode(telefono_original3,'',null, telefono_original3);		
        
		-- Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud
        LET viPrioridad = 1;
		set lock mode to wait 4;
		FOREACH
			SELECT numcte, num_credito INTO cNum_cte, cNum_Credito 
			FROM bdicred:"informix".sd_camp_primer_uso WHERE empresa = pempresa --AND status_tarj = 'INACT'
			AND fecha_gen_campania = dfecha_gen_camp
    		AND fecha_entreg_desde = dfecha_ent_desde
        	AND fecha_entreg_hasta = dfecha_ent_hasta
            AND num_campania = sNumCampania 
            AND status_tarj in ('INACT','ACTIV')
			ORDER BY fecha_apertura ASC

			UPDATE bdicred:"informix".sd_camp_primer_uso SET prioridad = viPrioridad 
            WHERE empresa = pempresa AND fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde 
            AND fecha_entreg_hasta = dfecha_ent_hasta AND num_campania = sNumCampania AND num_credito = cNum_Credito;

            LET viPrioridad = viPrioridad + 1;
		END FOREACH;
		
        -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
        LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(pdFechaHoy),3)||to_char(pdFechaHoy,'%m%d')||'.txt';  
        LET cnomarchivo  =  trim(cnombre)||substr(year(pdFechaHoy),3)||to_char( pdFechaHoy,'%m%d')||'.txt';
        LET cnomarchivoejecsql = 'Ejecuta_gen_arch_Camp_primer_uso.sql';

        LET cSql='';
        LET cSql = 'echo "tipo_promocion'||cdelimitador||'logica'||cdelimitador||'num_credito'||cdelimitador||'num_cliente'||cdelimitador
        ||'prioridad'||cdelimitador|| 'nombre' ||cdelimitador || 'sexo' ||cdelimitador|| 'estado_civil' ||cdelimitador|| 'email' ||cdelimitador|| 'estado' 
        ||cdelimitador|| 'tel const tipo 1' ||cdelimitador|| 'tel const tipo 2' ||cdelimitador|| 'tel const tipo 3' ||cdelimitador|| 'tel const tipo 4' 
        ||cdelimitador || 'extension' ||cdelimitador || '" >' ||TRIM(cruta)|| cnomarchivo;
        System csql;
	
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

        LET cSQL2 = " SELECT '" || cCod_Promocion || "', '" || sNum_logica::CHAR || "', prim.num_credito, prim.numcte, "
                || " prim.prioridad, trim (prim.ap_paterno) ||' '|| trim (prim.ap_materno)||' '|| trim(prim.primer_nombre) ||' '|| trim(prim.segundo_nombre) as nombre, prim.sexo, prim.estado_civil, prim.email, prim.estado, "                
				|| " tel1.telefono_original1,tel1.telefono_original2,tel1.telefono_original3,tel1.telefono_original4,extension "
				|| " FROM bdicred:sd_camp_primer_uso prim "
				|| " INNER JOIN bdicred:sd_temp_1er_uso_telef tel1 on (tel1.num_credito = prim.num_credito) "
                || " WHERE prim.empresa = '" || pempresa || "' AND prim.fecha_gen_campania = '" || dfecha_gen_camp || "'"
				|| " AND prim.fecha_entreg_desde = '" || dfecha_ent_desde || "'"
        		|| " AND prim.fecha_entreg_hasta = '" || dfecha_ent_hasta || "'"
                || " AND prim.num_campania = " || sNumCampania 
                || " AND prim.status_tarj in ('INACT') "
                || " ORDER BY prim.prioridad ";
                
        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        System cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
        SYSTEM cSQL;
    END IF;

	IF (pServicio = '03') THEN  -- Genera archivos para la campaña 3 ( INSERTOS CorreoDirecto ) se genera siempre el archivo.
        --Obtiene el nombre del archivo a generar (reporte de la Campaña 3, este reporte NO se envia al CAT
        SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 3; 
        IF NVL (cnombre,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        LET Pnomarchivo	= trim(cnombre) || '_' || to_char(pdFechaHoy,'%d%m%Y') || '.txt';
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_camp3.txt' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
        LET cSQL2 = " SELECT  a.num_credito, SUBSTR(tel.telefono_original2, (LENGTH(tel.telefono_original2) + 1 - 10),10), "
            || " TRIM(a.ap_paterno) ||' '|| TRIM(a.ap_materno) ||' '|| TRIM(a.primer_nombre) ||' '||TRIM(a.segundo_nombre), b.monto_otorgado "
            || " FROM bdicred:sd_camp_primer_uso a, bdicred:sd_maesdos b, bdicred:sd_temp_1er_uso_telef tel"
            || " WHERE a.num_credito = b.num_credito  AND a.numcte = tel.numcte " 
            || " and a.empresa = '" || pempresa || "' AND fecha_gen_campania = '" || dfecha_gen_camp || "'"
            || " AND fecha_entreg_desde = '" || dfecha_ent_desde || "'"
            || " AND fecha_entreg_hasta = '" || dfecha_ent_hasta || "'"
            || " AND num_campania = " || sNumCampania 
            || " AND status_tarj in ('INACT') ";
            --|| " AND trim(tel.telefono_original) <> '' AND LENGTH(tel.telefono_original) >= 10 AND tel.tipo_telefono = 2 "
            --|| " AND tel.secuencia = (select max(d.secuencia) from bdicred:sd_temp_1er_uso_telef d where d.numcte = a.numcte AND trim(d.telefono_original) <> '' and  LENGTH(d.telefono_original) >= 10 and d.tipo_telefono = 2  )";
                
        LET cSQL3 = '">'||TRIM(cRuta)|| 'pnomarchivoejec.sql';
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| 'pnomarchivoejec.sql';
        System cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'pnomarchivoejec.sql';
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || 'archivo_camp3.txt' || " >> " || TRIM(cRuta) || TRIM(Pnomarchivo);
        SYSTEM cSql;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'pnomarchivoejec.sql' || ' ' || TRIM(cruta) || 'archivo_camp3.txt';
        SYSTEM cSQL;
    END IF;

    IF pServicio = '02' THEN
		
        SELECT COUNT(*) INTO iTotalRegistros FROM bdicred:sd_camp_primer_uso prim
		 WHERE prim.empresa = pempresa AND prim.fecha_gen_campania = dfecha_gen_camp
		   AND prim.fecha_entreg_desde = dfecha_ent_desde
		   AND prim.fecha_entreg_hasta = dfecha_ent_hasta
           AND prim.num_campania = sNumCampania 
           AND prim.status_tarj in ('INACT','ACTIV'); 
		
		INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total) VALUES('001', pdFechaHoy , 'BIENVENIDA', iTotalRegistros);

    ELIF pServicio = '03' THEN

        SELECT COUNT(*) INTO iTotalRegistros FROM bdicred:sd_camp_primer_uso a , bdicred:sd_maesdos b ,bdicred:sd_temp_1er_uso_telef tel
         WHERE a.num_credito = b.num_credito  and a.numcte = tel.numcte 
           AND a.empresa = pempresa AND fecha_gen_campania = dfecha_gen_camp 
    	   AND fecha_entreg_desde =dfecha_ent_desde
           AND fecha_entreg_hasta = dfecha_ent_hasta
           AND num_campania = sNumCampania 
           AND status_tarj in ('INACT','ACTIV');
				
        INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total) VALUES('001', pdFechaHoy , 'CorreoDirecto', iTotalRegistros);
		
    ELIF pServicio = '04' THEN
		
        SELECT COUNT(*) INTO iTotalRegistros FROM bdicred:sd_camp_primer_uso prim
		 WHERE prim.empresa = pempresa AND prim.fecha_gen_campania = dfecha_gen_camp
		   AND prim.fecha_entreg_desde = dfecha_ent_desde
		   AND prim.fecha_entreg_hasta = dfecha_ent_hasta
           AND prim.num_campania = sNumCampania 
           AND prim.status_tarj in ('INACT','ACTIV'); 
			
        INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total) VALUES('001', pdFechaHoy , 'CREDIEFECTIVO', iTotalRegistros);
        
    ELIF pServicio = '06' THEN
		
        SELECT COUNT(*) INTO iTotalRegistros FROM bdicred:sd_camp_primer_uso prim
		 WHERE prim.empresa = pempresa AND prim.fecha_gen_campania = dfecha_gen_camp
		   AND prim.fecha_entreg_desde = dfecha_ent_desde
		   AND prim.fecha_entreg_hasta = dfecha_ent_hasta
           AND prim.num_campania = sNumCampania 
           AND prim.status_tarj in ('INACT','ACTIV'); 
			
        INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total) VALUES('001', pdFechaHoy , 'PRE-CANCELACION', iTotalRegistros);
    END IF;


    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO FINALIZADO ' || pServicio, '02') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;