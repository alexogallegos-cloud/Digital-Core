CREATE PROCEDURE "informix".sp_inserta_movimiento( 
                pFechaHora CHAR(30), 
                pMonto MONEY, 
                pFolioSuc CHAR(30), 
                pReferencia23 CHAR(23), 
                pProducto INTEGER, 
                pTipoEvento INTEGER, 
                pAclaracion INTEGER, 
                pMovimientoPadre INTEGER,
                pNumSucursal CHAR(10),
                pReferenciaComercio CHAR(40),
                pFechaConsumo CHAR(30),
                pMontoProcedente MONEY,
                pFolioCSUAC CHAR(10),
                pReversado SMALLINT,
                pCalculado SMALLINT,
                pMontoDuplicado SMALLINT,
                pTipoMovimiento INTEGER,
                pReferencia VARCHAR(30))
RETURNING CHAR(3);


DEFINE cCodRet    CHAR(3);  --> ok
DEFINE CSecuencia INTEGER;
DEFINE vFechaHora DATETIME YEAR to FRACTION(5);
DEFINE vFechaConsumo DATETIME YEAR to FRACTION(5);


LET cCodRet = '';
LET CSecuencia   = 0; 
LET vFechaConsumo = null;
LET vFechaHora = null;
 
 
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    
BEGIN

--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/actualiza_movimiento"||"_N_"||""||TRIM(pFolioCSUAC)||""||"_34.out"; --> TRACE DESDE APP
--TRACE ON;

     IF pFechaHora = '' OR pFechaHora IS  NULL THEN  
        LET pFechaHora = null;
     END IF;
     IF pFechaConsumo = '' OR pFechaConsumo IS  NULL THEN  
        LET pFechaConsumo = null;
     END IF; 
     IF pFolioSuc = '' OR pFolioSuc IS  NULL THEN  
        LET pFolioSuc = null;
     END IF; 
     IF pReferencia23 = '' OR pReferencia23 IS  NULL THEN  
        LET pReferencia23 = null;
     END IF; 
     IF pNumSucursal = '' OR pNumSucursal IS  NULL THEN  
        LET pNumSucursal = null;
     END IF; 
     IF pReferenciaComercio = '' OR pReferenciaComercio IS  NULL THEN  
        LET pReferenciaComercio = null;
     END IF; 
     IF pFolioCSUAC = '' OR pFolioCSUAC IS  NULL THEN  
        LET pFolioCSUAC = null;
     END IF; 
     IF pReferencia = '' OR pReferencia IS  NULL THEN  
        LET pReferencia = '';
     END IF; 
     IF pFechaHora <> '' OR pFechaHora IS NOT NULL THEN   
        IF length(pFechaHora) > 10 THEN
            LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y %H:%M:%S')) ;
        ELSE 
            LET vFechaHora =(TO_DATE(pFechaHora,'%d/%m/%Y')) ;
        END IF;
     END IF;    
     IF pFechaConsumo <> '' OR pFechaConsumo IS NOT NULL THEN  
       LET vFechaConsumo = (TO_DATE(pFechaConsumo,'%d/%m/%Y %H:%M:%S'));
     END IF;

     
        INSERT INTO acl_movimiento
                           -- pky_movimiento            calculado     cargo     cargo_ajuste    exitoso     fecha_afectacion   fecha_hora_e_global      fechahora       folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente        duplicado         numero_transaccion     procede     referencia      referencia23    reversado     secuencia   fky_aclaracion     fky_padre     fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion       ref_comercio        num_sucursal   fecha_consumo  recuperacion  monto_recuperacion
        VALUES(MOVIMIENTO_SEQ.nextval, pCalculado,    null,        null,         null,          null,               null,               vFechaHora,     pFolioCSUAC,    pFolioSuc,              null,               null,      null,     pMonto,   pMontoProcedente,   pMontoDuplicado,            null,            null,      pReferencia,   pReferencia23,   pReversado,     null,        pAclaracion,        pMovimientoPadre,      pProducto,              null,               pTipoEvento,        pTipoMovimiento,                null,                  pReferenciaComercio,   pNumSucursal , vFechaConsumo,        0,            0);
        
        LET cCodRet = '000';

END;
RETURN cCodRet;
END PROCEDURE
DOCUMENT
'sp_inserta_movimiento',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_reporte_mensual_acl() Returning char(5);

	/*DEFINICIÃN DE VARIABLES*/
	DEFINE  vsql        		char(3000);
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	DEFINE p_cuenta				varchar(20);
	DEFINE p_folio				varchar(20);
	DEFINE p_tarjeta			varchar(20);
	DEFINE p_cliente 			varchar(20);
 	DEFINE p_nombre1  			varchar(200);
	DEFINE p_nombre2   			varchar(50);
	DEFINE p_apell_paterno		varchar(50);
	DEFINE p_apell_materno		varchar(50);
	DEFINE p_rfc				varchar(20);
	DEFINE p_curp          		varchar(20);
	DEFINE p_evento				varchar(50);
	DEFINE icontador 			integer;
	DEFINE v_fecha_fin			date;
	DEFINE v_fecha_inicio		date;
	DEFINE v_temp_tabla INTEGER;
	
	LET p_cuenta		=	'';
	LET p_folio			=	'';
	LET p_tarjeta		=	'';
	LET p_cliente 		=	'';
 	LET p_nombre1  		=	'';
	LET p_nombre2   	=	'';
	LET p_apell_paterno	=	'';
	LET p_apell_materno	=	'';
	LET p_rfc			=	'';
	LET p_curp          =	'';
	LET p_evento		=	'';
	LET icontador 		=	0;
	
--Verificar tablas fisicas
		
		
		SELECT tabid
			INTO v_temp_tabla
		FROM systables WHERE tabname ='acl_reporte_mensual';
		IF v_temp_tabla IS NOT NULL THEN
			DROP TABLE "informix".acl_reporte_mensual;
		END IF;
--Verificar tabla fisica
	
	--creacion de tabla
        CREATE  TABLE  "informix".acl_reporte_mensual
            (folio_csuac            varchar(11),
			cuenta          		varchar(20),
            tarjeta          		varchar(20),
            cliente         		varchar(20),
            nombre           		varchar(200),
            rfc        				varchar(20),
            curp                  	varchar(20),
            evento             varchar(100),
           	primary key (folio_csuac)
		)  extent size 362695 next size 36484 lock mode row;


		
	let vcodret = "";
	let vsqlerr = 0;
	
	SELECT prox_fecha as fecha_fin, pri_dia_mes as fecha_inicio
			INTO v_fecha_fin, v_fecha_inicio
	FROM bdinteg:"informix".si_fechas;
		
	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_reportediarioacl.out";
	--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_reportediarioacl.out";
   -- TRACE ON;
	
	
	BEGIN	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
BEGIN WORK;
		
		--Generacion de registros para Reporte Diario (Aclaraciones Pendientes)
	FOREACH WITH HOLD
		select
			a.folio_csuac,
			p.numero_cuenta,
			p.numero_tarjeta,	
			c.numcte, 
			c.nombre1,
			c.nombre2,
			c.apell_paterno,
			c.apell_materno,
			c.rfc,
			ct.curp,
			e.descripcion
		INTO
			p_folio,
			p_cuenta,		
		  	p_tarjeta,		
		    p_cliente, 		
		    p_nombre1,  		
		    p_nombre2,  	
		    p_apell_paterno,
		    p_apell_materno,
		    p_rfc,			
		    p_curp,          
		    p_evento		
		     		
		from acl_aclaracion a
			left outer join acl_producto p on a.fky_producto=p.pky_producto
			left outer join acl_tipo_evento e on a.fky_tipo_evento=e.pky_tipo_evento
			left outer join bdinteg:si_cliente c on a.num_cliente=c.numcte
			left outer join bdinteg:si_ctepf ct on c.numcte=ct.numcte
		where (a.fechacaptura BETWEEN v_fecha_inicio AND v_fecha_fin) and a.folio_csuac is not null and a.fky_estatus_aclaracion > 1
						
					
			LET p_nombre1 = trim(p_nombre1)||' '||trim(p_nombre2)||' '||trim(p_apell_paterno)||' '||trim(p_apell_materno);
					
						
					INSERT INTO "informix".acl_reporte_mensual (folio_csuac, cuenta, tarjeta, cliente, nombre, rfc, curp, evento)
					VALUES (p_folio, p_cuenta, p_tarjeta, p_cliente, p_nombre1, p_rfc,	p_curp, p_evento);
					
					LET iContador = iContador + 1;
					
					IF iContador = 1000 THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF; 

	END FOREACH;				
	
	COMMIT WORK;
	
			
			
			
			
			--Generacion de Reporte Mensual
			let vsql = ' echo "Folio_Csuac|Numero_Cuenta|Numero_tarjeta|Num_Cliente|Nombre_cliente|Rfc|Curp|Nombre_Evento">/resplogifx/repaclaraciones/ACL_INGRESADAS_'||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_inicio)||'.unl';
			system vsql; 
			let vsql = '';
			let vsql=  'echo "UNLOAD TO reportemensual.unl  select folio_csuac,cuenta,tarjeta,cliente,nombre,rfc,curp,evento from acl_reporte_mensual;">reportemensual.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdiaclaracion	  reportemensual.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  reportemensual.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' reportemensual.unl >>/resplogifx/repaclaraciones/ACL_INGRESADAS_"||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_inicio)||".unl";
			system vsql;
			let vsql ='rm  reportemensual.unl';
			system vsql; 
				
			let vcodret = '00000';					
			
			--truncate table "informix".acl_reporte_diario REUSE STORAGE;
-----------------------------------------------------------------------------------
		

		
		drop table "informix".acl_reporte_mensual;
				
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte mensual de Aclaraciones',
'Genera la extraciÃ³n de informaciÃ³n correspondiente a las aclaraciones ingresadas en el mes con datos espesificos',
'Es llamado desde desde la opcion 722 del menu de produccion',
'Aclaraciones',
'AUTOR : Rey David Zavala Garcia',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 23/Mayo/2019',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_documentos_faltantes(pIdAclaracion INTEGER, pCliente CHAR(9))

	RETURNING
		CHAR(5)							AS cod_ret,
		INTEGER							AS id_documento,
		CHAR(4)							AS producto_bdidigital,
		CHAR(4)							AS codigo_doc_bdidigital,
		CHAR(100)						AS descripcion,
		INTEGER							AS id_digitalizado_en_acl,
		SMALLINT						AS existe_en_bdidigital,
		SMALLINT						AS opcional,
		CHAR(50)						AS nombre_acl_doc,
		DATE 							AS registro_acl_doc,
		DATE 							AS registro_bdidigital;


	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_existe_aclaracion			SMALLINT;
	DEFINE v_cliente_aclaracion			CHAR(9);
	DEFINE v_folio_csuac				CHAR(11);
	DEFINE v_id_documento				INTEGER;
	DEFINE v_grupo_doc					CHAR(4);
	DEFINE v_codigo_doc					CHAR(4);
	DEFINE v_existe_archivo_digital		SMALLINT;
	DEFINE v_desc_documento				CHAR(100);
	DEFINE v_id_digitalizado			INTEGER;
	DEFINE v_opcional					SMALLINT;
	DEFINE v_nombre_acl_doc				CHAR(50);
	DEFINE v_fecha_registro				DATETIME YEAR to FRACTION(5);
	DEFINE v_registro_acl_doc			DATE;
	DEFINE v_registro_bdidigital		DATE;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	LET v_existe_aclaracion				= NULL;
	LET v_cliente_aclaracion			= NULL;
	LET v_folio_csuac					= NULL;
	LET v_id_documento					= NULL;
	LET v_grupo_doc						= NULL;
	LET v_codigo_doc					= NULL;
	LET v_existe_archivo_digital		= NULL;
	LET v_desc_documento				= NULL;
	LET v_id_digitalizado				= NULL;
	LET v_opcional						= NULL;
	LET v_nombre_acl_doc				= NULL;
	LET v_fecha_registro				= NULL;
	LET v_registro_acl_doc				= NULL;
	LET v_registro_bdidigital			= NULL;
	
	--SET DEBUG FILE TO "/informix/traces/doctos_ptes.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital;
				
		    END IF;
		END EXCEPTION;
		
		IF ((pCliente IS NULL) OR (pCliente = '')) AND (pIdAclaracion IS NULL) THEN
			RETURN '00002', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --La invocaciÃ³n debe tener algÃºn valor
		END IF;
		
		IF (pIdAclaracion IS NULL) THEN
			RETURN '00003', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el ID de la AclaraciÃ³n
		END IF;
		
		IF (pCliente IS NULL) OR (pCliente = '') THEN
			RETURN '00004', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el nÃºmero de cliente
		END IF;
		
		SELECT 1, num_cliente, folio_csuac
			INTO v_existe_aclaracion, v_cliente_aclaracion, v_folio_csuac
		FROM acl_aclaracion
		WHERE pky_aclaracion = pIdAclaracion;
		
		IF (v_existe_aclaracion IS NULL) THEN
			RETURN '00005', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --No existe la AclaraciÃ³n
		END IF;
		
		LET pCliente = LPAD(TRIM(pCliente), 9, '0');
		
		IF (pCliente <> v_cliente_aclaracion) THEN
			RETURN '00006', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
					v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --El cliente de la aclaraciÃ³n no coincide con el solicitado
		END IF;
		
		FOREACH
			
			SELECT tdocm.fky_tipo_documento, tdoc.descripcion, doc.pky_documento, te.grupo_doc,
					tdg.cod_docto, tdocm.opcional, doc.nombre, doc.fecharegistro
				INTO v_id_documento, v_desc_documento, v_id_digitalizado, v_grupo_doc,
					v_codigo_doc, v_opcional, v_nombre_acl_doc, v_fecha_registro
			FROM acl_aclaracion acl
				INNER JOIN acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
				INNER JOIN acl_tipo_doc_matriz tdocm ON fky_id_regla = fky_regla_negocio
				INNER JOIN acl_tipo_documento tdoc ON tdoc.pky_tipo_documento = tdocm.fky_tipo_documento
				LEFT OUTER JOIN acl_tipo_docto_dg_tipodocto tdg ON tdg.fky_tipo_documento = tdoc.pky_tipo_documento
					AND te.grupo_doc = tdg.grupo_doc
				LEFT OUTER JOIN acl_documento doc ON pky_aclaracion = doc.fky_aclaracion 
					AND tdocm.fky_tipo_documento = doc.fky_tipo_documento
			WHERE pky_aclaracion = pIdAclaracion
			
			LET v_registro_acl_doc = DATE(v_fecha_registro);
			LET v_existe_archivo_digital = NULL;
			
			IF v_codigo_doc IS NOT NULL THEN
				SELECT FIRST 1 1, fecha_alta
					INTO v_existe_archivo_digital, v_registro_bdidigital
				FROM bdidigital@coppelimg_tcp:dg_expediente exp			
				WHERE exp.producto = v_grupo_doc
					AND exp.cod_docto = v_codigo_doc
					AND exp.cliente = pcliente
					AND exp.cuenta = v_folio_csuac
					AND exp.descrip2 <> 'firma_borra_da';
			END IF;
			
			LET v_existe_archivo_digital = NVL(v_existe_archivo_digital,0);
			
			RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital, 
						v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital
				WITH RESUME;
			
		END FOREACH;
			
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

CREATE PROCEDURE "informix".sp_reverso_estatus_preingreso()
  RETURNING 
    CHAR(3) as cCodRet, 
	CHAR(12) as folioCsuac; 
	
  -- Definición de variables
  DEFINE sql_err INTEGER;
  DEFINE v_cod_ret CHAR(3);
  DEFINE v_fecha_hoy DATE;
  DEFINE v_fecha_acl DATE;
  DEFINE v_days INTEGER;
  DEFINE v_folio_csuac VARCHAR(12);
  DEFINE v_folio_aclaracion VARCHAR(18);
  DEFINE v_pky_aclaracion INTEGER;
  DEFINE v_dias_feriados INTEGER;
  DEFINE v_dias_finSemana INTEGER;
  DEFINE v_dia_hoy INTEGER;
  DEFINE contador INTEGER;
  
  DEFINE v_num_cliente CHAR(9);
  DEFINE v_nombre1 CHAR(50);
  DEFINE v_nombre2 CHAR(50);
  DEFINE v_apell_paterno CHAR(50);
  DEFINE v_apell_materno CHAR(50);
  DEFINE v_nombre_completo CHAR(150);
  
  DEFINE vcodretDatosCte CHAR(5);
  DEFINE vCorreoElec CHAR(100);
  DEFINE vTipoCorreo SMALLINT;
  DEFINE vStatusCorreo CHAR(1);
  
  DEFINE vTelefono CHAR(13);
  DEFINE vTipoTel SMALLINT;
  DEFINE vSecuencia SMALLINT;
  DEFINE vStatus_Tel CHAR(1);
  DEFINE vExtension CHAR(5);
  DEFINE vCarrier SMALLINT;
  DEFINE vNombreCarrier CHAR(20);
  DEFINE StatusValidacion SMALLINT;
  
  DEFINE v_dias_vencimiento INTEGER;
  DEFINE c_estatus_pre_ingreso CHAR(50);
  DEFINE c_id_estatus_pre_ingreso INTEGER;
  DEFINE c_estatus_declinado CHAR(50);
  DEFINE c_id_estatus_declinado INTEGER;
  
  DEFINE v_codret_notificacion CHAR(5);
  
  --Variables para la bitácora
  DEFINE v_id_area INTEGER;
  DEFINE v_estatus_acl INTEGER;
  DEFINE v_estatus_corp_analisis INTEGER;
  DEFINE v_estatus_corp_general INTEGER;
  DEFINE v_id_accion INTEGER;
  DEFINE v_desc_bitacora CHAR(100);
   
  --Declaración de Variables para los documentos faltantes
  DEFINE v_cod_ret_docto CHAR(5);
  DEFINE v_id_documento INTEGER;
  DEFINE v_codigo_doc_bdidigital CHAR(4);
  DEFINE v_docto CHAR(100);
  DEFINE v_existe_docto_aclaracion INTEGER;
  DEFINE v_existe_docto_en_bdidigital SMALLINT;
  DEFINE v_producto_bdidigital CHAR(4);
  DEFINE v_docto_es_opcional SMALLINT;
  DEFINE v_nombre_acl_doc CHAR(50);
  DEFINE v_fecha_registro_acl_doc DATE;
  DEFINE v_fecha_registro_bdidigital DATE;
  DEFINE v_docto1 CHAR(60);
  DEFINE v_docto2 CHAR(100);
  DEFINE v_docto3 CHAR(60);
  DEFINE v_docto4 CHAR(100);
  DEFINE v_docto5 CHAR(30);
  DEFINE v_contador_doctos INTEGER;
  
  --Declaración de Constantes para los envíos de notificaciones
  DEFINE c_contrato_correo_latinia CHAR(10);
  DEFINE c_contrato_sms_latinia CHAR(10);
  DEFINE c_plantilla_latinia CHAR(12);
  
  -- inicialización de variables
  LET v_cod_ret = "000";
  LET v_fecha_hoy = today;
  LET v_dia_hoy = WEEKDAY(v_fecha_hoy);
  LET v_fecha_acl = "";
  LET v_folio_csuac = "";
  LET v_folio_aclaracion = NULL;
  LET v_pky_aclaracion = "";
  LET v_num_cliente = NULL;
  
  LET v_nombre1 = NULL;
  LET v_nombre2 = NULL;
  LET v_apell_paterno = NULL;
  LET v_apell_materno = NULL;
  LET v_nombre_completo = NULL;
  
  LET c_contrato_correo_latinia = 'ACL_EMAIL';
  LET c_contrato_sms_latinia = 'ACL_SMS';
  LET c_plantilla_latinia = 'ACL_DECLINA';
  
  LET vTelefono = NULL;
  LET vcorreoelec = NULL;
  LET v_codret_notificacion = NULL;
  
  LET v_id_area = NULL;
  LET v_estatus_acl = NULL;
  LET v_estatus_corp_analisis = NULL;
  LET v_estatus_corp_general = NULL;
  LET v_id_accion = NULL;
  LET v_desc_bitacora = NULL;
  
  LET v_dias_vencimiento = NULL;
  LET c_estatus_pre_ingreso = 'PRE_INGRESO';
  LET c_id_estatus_pre_ingreso = NULL;
  LET c_estatus_declinado = 'DECLINADA';
  LET c_id_estatus_declinado = NULL;
  
  LET v_cod_ret_docto = NULL;
  LET v_id_documento = NULL;
  LET v_codigo_doc_bdidigital = NULL;
  LET v_docto = NULL;
  LET v_existe_docto_aclaracion = NULL;
  LET v_existe_docto_en_bdidigital = NULL;
  LET v_producto_bdidigital = NULL;
  LET v_docto_es_opcional = NULL;
  LET v_nombre_acl_doc = NULL;
  LET v_fecha_registro_acl_doc = NULL;
  LET v_fecha_registro_bdidigital = NULL;
  LET v_docto1 = NULL;
  LET v_docto2 = NULL;
  LET v_docto3 = NULL;
  LET v_docto4 = NULL;
  LET v_docto5 = NULL;
  LET v_contador_doctos = 0;
  
BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET v_cod_ret = sql_err;
           RETURN v_cod_ret,v_folio_csuac;
     END IF;
  END EXCEPTION;
	 
	--SET DEBUG FILE TO '/informix/traces/sp_reverso_estatus_preingreso.out';
	--TRACE ON;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  --Se obtiene el valor del estatus corporativo Pre-Ingreso y Declinada de tipo análisis
  SELECT pky_estatus_corporativo 
    INTO c_id_estatus_pre_ingreso
  FROM acl_estatus_corporativo 
  WHERE nombre = c_estatus_pre_ingreso AND fky_tipo_estatus = 2 
    AND activo = 1;
  
  IF c_id_estatus_pre_ingreso IS NULL THEN --No está definido el Estatus Pre-Ingreso
    RETURN '001',v_folio_csuac;
  END IF;
  
  SELECT pky_estatus_corporativo 
    INTO c_id_estatus_declinado
  FROM acl_estatus_corporativo 
  WHERE nombre = c_estatus_declinado AND fky_tipo_estatus = 2 
    AND activo = 1;
  
  IF c_id_estatus_declinado IS NULL THEN --No está definido el Estatus Declinado
    RETURN '002',v_folio_csuac;
  END IF;
  
  --LET v_fecha_hoy = today-7;
  
  IF (v_dia_hoy != 0 AND v_dia_hoy != 6) THEN 
    FOREACH
      /*Busca Aclaraciones con estatus corporativo analisis en PreIngreso*/
      SELECT pky_aclaracion,fechacaptura, folio_csuac, num_cliente
        INTO v_pky_aclaracion,v_fecha_acl, v_folio_csuac, v_num_cliente
      FROM acl_aclaracion 
	  WHERE fky_estatus_corp_analisis = c_id_estatus_pre_ingreso
  	  
	  --Se obtienen los días de vigencia que tiene una Aclaración dependiendo su Canal de Ingreso 
	  SELECT dias_vencimiento 
        INTO v_dias_vencimiento
      FROM acl_aclaracion acl
        INNER JOIN acl_cat_tipo_aclaracion ta on fky_cat_tipo_aclaracion = pky_cat_tipo_aclaracion
      WHERE folio_csuac = v_folio_csuac;

      --En caso de no tener definida la vigencia, se considera 0
      LET v_dias_vencimiento = NVL(v_dias_vencimiento, 0);
	
	  --Se obtiene el nombre del Cliente
	  SELECT nombre1, nombre2, apell_paterno, apell_materno 
        INTO v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno 
	  FROM bdinteg:si_cliente 
	  WHERE numcte = v_num_cliente;
	  
	  LET v_nombre_completo = TRIM(NVL(v_nombre1,'')) || ' ' || TRIM(NVL(v_nombre2,'')) || ' ' || TRIM(NVL(v_apell_paterno,'')) || ' ' || TRIM(NVL(v_apell_materno,''));
	  
	  --Se obtiene el Correo Electrónico del cliente
	  CALL bdinteg:sp_consulta_correos ('001', v_num_cliente,'1','0')
              RETURNING  vcodretDatosCte, vcorreoelec, vtipocorreo, vstatuscorreo;
	   --Se obtiene el Teléfono Celular del cliente
	  CALL bdinteg:sp_consulta_telefonos ('001', v_num_cliente,'2','0')
              RETURNING  vcodretDatosCte, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
	  
	  --Se corrobora si existe si el folio csuac de aclaración se encuentra asignada a un folio agrupador (folio_aclaracion)
	  SELECT folio_aclaracion 
	    INTO v_folio_aclaracion
	  FROM acl_folio_aclaracion_acl_aclaracion
	  WHERE fky_aclaracion = v_pky_aclaracion;
	  
	  --En caso de no estar asignada a un Folio Agrupador, se considerará el Folio CSUAC
	  LET v_folio_aclaracion = NVL(v_folio_aclaracion,v_folio_csuac);
	  
	  LET v_contador_doctos = 0;
	  --En caso de tener correo registrado el cliente, se obtienen los documentos que no envío
	  IF vcorreoelec IS NOT NULL OR vcorreoelec <> '' THEN
	    FOREACH 
	      EXECUTE FUNCTION "informix".sp_documentos_faltantes(v_pky_aclaracion, v_num_cliente) 
	        INTO v_cod_ret_docto, v_id_documento, v_producto_bdidigital, v_codigo_doc_bdidigital, v_docto, v_existe_docto_aclaracion, v_existe_docto_en_bdidigital, v_docto_es_opcional, v_nombre_acl_doc, v_fecha_registro_acl_doc, v_fecha_registro_bdidigital
	      --Se valida si el documento no fue proporcionado por el usuario
		  IF (v_existe_docto_aclaracion IS NOT NULL OR v_existe_docto_aclaracion > 0) OR (v_existe_docto_en_bdidigital IS NOT NULL OR v_existe_docto_en_bdidigital > 0) THEN
	        LET v_contador_doctos = v_contador_doctos + 1;
	        IF v_contador_doctos = 1 THEN
			  LET v_docto1 = v_docto;
            ELIF v_contador_doctos = 2 THEN
			  LET v_docto2 = v_docto;
			ELIF v_contador_doctos = 3 THEN
			  LET v_docto3 = v_docto;
			ELIF v_contador_doctos = 4 THEN
			  LET v_docto4 = v_docto;
			ELIF v_contador_doctos = 5 THEN
			  LET v_docto5 = v_docto;
			END IF;
	      END IF;
	    END FOREACH;
	  END IF;
	  
  	  -- obtener dias feriados
  	  LET v_dias_feriados = 0;
  	  SELECT count(*)
        INTO  v_dias_feriados
  	  FROM  bdinteg:si_feriado_banca 
	  WHERE fecha BETWEEN v_fecha_acl 
  	    AND v_fecha_hoy AND WEEKDAY(fecha) BETWEEN 1 AND 5;
  	
  	  LET v_days = DATE(v_fecha_hoy) - DATE(v_fecha_acl);
      
      LET v_dias_finSemana = 0;
  
      LET contador= 0;
      
      WHILE  contador < v_days LOOP
        IF (WEEKDAY(v_fecha_acl)==0 OR  WEEKDAY(v_fecha_acl)== 6) then
          LET v_dias_finSemana = v_dias_finSemana + 1; 
        END IF;
        LET contador = contador + 1;
  	    LET v_fecha_acl = v_fecha_acl+1;
      END LOOP;
      
      -- resta dias_feriados y fines de semana.
  	  LET v_days = v_days - (v_dias_feriados + v_dias_finSemana);
      
      IF(v_days >= v_dias_vencimiento) THEN
        /*Actualizando la aclaracion de preIngreso a Declinado*/
		UPDATE acl_aclaracion SET fky_estatus_corp_analisis = c_id_estatus_declinado WHERE pky_aclaracion = v_pky_aclaracion;
        
        /*Resgistro de Bitácora*/
		--Se obtienen los valores actuales de la Aclaración para insertarlos en la bitácora
        SELECT fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general 
          INTO v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general 
        FROM acl_aclaracion
        WHERE folio_Csuac = v_folio_csuac;
		--Se obtiene la resolución correspondiente al reverso
        SELECT pky_resolucion 
          INTO v_id_accion
        FROM acl_resolucion 
        WHERE nombre = 'registroIntento';
		
		LET v_desc_bitacora = 'El folio: ' || v_folio_csuac || ' se actualizó de estatus Pre-Ingreso a Declinado.';
		
        INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		
		--Se envían las notificaciones correspondientes a la declinación
		--Notificación Vía SMS
		IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
		  CALL bdimnsj:sp_registra_evento('2',c_contrato_sms_latinia,c_plantilla_latinia,v_num_cliente,'','','1',v_folio_aclaracion,'','','',v_nombre_completo,'','','','','','',vTelefono,0,0,0,0,0,today,'')
		      RETURNING v_codret_notificacion;
		END IF;
        
        --Se registra la notificación en la bitácora del Sistema.
        IF v_codret_notificacion = '00000' THEN
		  LET v_desc_bitacora = 'El mensaje de texto de notificación fué enviado al Cliente con éxito.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionSMSExitoso';
        ELSE
		  LET v_desc_bitacora = 'El mensaje de texto de notificación no pudo ser enviado al Cliente.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionSMSFallido';
        END IF;
		
		INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		LET v_codret_notificacion = NULL;
		
		--Notificación Vía Correo
		IF vcorreoelec IS NOT NULL OR vcorreoelec <> '' THEN
		  CALL bdimnsj:sp_registra_evento('1',c_contrato_correo_latinia,c_plantilla_latinia,v_num_cliente,'','','1',v_folio_aclaracion,'','',v_docto5,v_nombre_completo,v_docto3,v_docto1,v_docto4,'',v_docto2,vCorreoElec,'',0,0,0,0,0,today,'')
		      RETURNING v_codret_notificacion;
		END IF;
		
		--Se registra la notificación en la bitácora del Sistema.
		IF v_codret_notificacion = '00000' THEN
		  LET v_desc_bitacora = 'El correo electrónico de notificación fué enviado al Cliente con éxito.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionCorreoFallido';
        ELSE
		  LET v_desc_bitacora = 'El correo electrónico de notificación no pudo ser enviado al Cliente.';
          SELECT pky_resolucion 
			INTO v_id_accion
		  FROM acl_resolucion 
		  WHERE nombre = 'notificacionCorreoExitoso';
        END IF;
		
		INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,
		  fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
        VALUES(ENTRADA_BITACORA_SEQ.nextval, v_desc_bitacora, sysdate, v_folio_csuac, v_id_accion, 
		  v_pky_aclaracion, v_id_area, v_estatus_acl, v_estatus_corp_analisis, v_estatus_corp_general ,0);
        
		--Se reinician los valores para insertar en la bitácora
		LET v_id_accion = NULL;
		LET v_desc_bitacora = NULL;
		--Se limpian las variables de Correo y teléfonos del cliente.
		LET vTelefono = NULL;
		LET vcorreoelec = NULL;
		LET v_codret_notificacion = NULL;
		
        RETURN v_cod_ret,v_folio_csuac WITH RESUME;
      END IF;
  	END FOREACH;
	
  END IF;
END;
END PROCEDURE
DOCUMENT
'Sistema: Aclaraciones',
'AUTOR : Root',
'Modificación : BanCoppel',
'Coordinador: Norberto Corona Berruecos',
'FECHA: Febrero/2019',
'Requerimiento: RQM 06 626',
'VERSION: 2.0.0',
'BD:  bdiaclaracion';

CREATE PROCEDURE "informix".sp_recuperacion_saldos()
RETURNING CHAR(7) AS CODIGO
--V. 2.0.3
DEFINE v_folio CHAR(24);
DEFINE v_producto SMALLINT;
DEFINE v_credito SMALLINT;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
DEFINE s_CodRet CHAR(6);
DEFINE v_mensaje CHAR(600);
DEFINE s_Mensaje CHAR(100);
DEFINE s_Cc SMALLINT;
DEFINE s_AfectacionC MONEY;
DEFINE s_CodleyendaC CHAR(3);
DEFINE s_Ci SMALLINT;
DEFINE s_AfectacionI MONEY;
DEFINE s_CodleyendaI CHAR(3);
DEFINE s_Ca SMALLINT;
DEFINE s_AfectacionA MONEY;
DEFINE s_CodleyendaA CHAR(3);
DEFINE s_Cin SMALLINT;
DEFINE s_AfectacionIn MONEY;
DEFINE s_CodleyendaIn CHAR(3);
--Variables para la bitacora
DEFINE v_descripcion LVARCHAR(625); 
DEFINE v_fechahora DATETIME YEAR TO FRACTION(5);
DEFINE v_folio_csuac CHAR(24);
DEFINE v_fky_accion INTEGER;
DEFINE v_fky_aclaracion INTEGER;
DEFINE v_fky_area INTEGER;
DEFINE v_fky_estatus_aclaracion INTEGER;
DEFINE v_estatus_corp_analisis INTEGER;
DEFINE v_estatus_corp_general INTEGER;
DEFINE v_fky_usuario INTEGER;
--Variable de retorno
DEFINE iSqlErr INTEGER;
DEFINE v_codigo_ret CHAR(7);

--535
DEFINE wBegin CHAR(1);


LET v_mensaje = 'ERROR GENERAL';
LET v_folio = '';
LET v_credito = 1;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
LET s_CodRet = '';
LET v_mensaje = '';
LET s_Mensaje = '';
LET s_Cc = 0;
LET s_AfectacionC = 0;
LET s_CodleyendaC = '';
LET s_Ci = 0;
LET s_AfectacionI = 0;
LET s_CodleyendaI = '';
LET s_Ca = 0;
LET s_AfectacionA = 0;
LET s_CodleyendaA = '';
LET s_Cin = 0;
LET s_AfectacionIn = 0;
LET s_CodleyendaIn = '';

--Variables para la bitacora
LET v_descripcion = 'ERROR'; 
LET v_fechahora = CURRENT;
LET v_folio_csuac = 'ERROR';
LET v_fky_accion = 0;
LET v_fky_aclaracion = 0;
LET v_fky_area = 0;
LET v_fky_estatus_aclaracion = 0;
LET v_estatus_corp_analisis = 0;
LET v_estatus_corp_general = 0;
LET v_fky_usuario = 0;

--Codigo de retorno
LET v_codigo_ret = '';


--535
LET wBegin = 'N';


BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_codigo_ret = iSqlErr;
				RETURN v_codigo_ret;
			END IF;
		END EXCEPTION;
	
		ON EXCEPTION SET iSqlErr
			  LET v_codigo_ret = iSqlErr;
			  --ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;

			  RETURN v_codigo_ret;
		   END EXCEPTION;

		   ON EXCEPTION IN (-535)
			  LET wBegin = "S";
			  --ROLLBACK WORK;
			  COMMIT WORK;
				SET ISOLATION TO DIRTY READ;

			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   
	
--	BEGIN WORK;

    FOREACH v_folio WITH HOLD FOR
            SELECT DISTINCT (rec.FOLIO_CSUAC), tp.tipo_producto
            INTO v_folio, v_producto
            FROM ACL_RECUPERACION_SALDOS rec
            LEFT JOIN acl_aclaracion acl    ON acl.pky_aclaracion=rec.fky_aclaracion
            LEFT JOIN acl_producto producto ON producto.pky_producto=acl.fky_producto
            LEFT JOIN acl_tipo_producto tp  ON tp.pky_tipo_producto=producto.fky_tipo_producto 
            WHERE CRON_ACTIVO='1'
			
--		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/RECSALDOS"||v_folio||".out";
	---		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/sp_recuperacion_saldos.trc";
--			TRACE ON;

                IF (v_producto == 1) THEN
                    --CREDITO
                        CALL "informix".sp_upd_credrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;

						LET v_codigo_ret = s_CodRet;


							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;						
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '208') THEN
								LET v_mensaje = 'No se realizó la afectación de comision/iva. ';
								--Variables para la bitacora
								LET v_descripcion = 'No se realizó la afectación de comision/iva...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;							
							IF (s_CodRet == '000' OR s_CodRet == '000006' OR s_CodRet == '000000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	

									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
										
									END IF;
								END IF;
								
							ELSE
							
							IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
								
								--Insertar a acl_bitacora_error_rec_saldo para errores
								LET v_fechahora = current; 
								INSERT INTO "informix".acl_bitacora_error_rec_saldo (
								codigo,
								folio_csuac,
								fecha
								)
								VALUES (
								s_CodRet,
								v_folio,
								v_fechahora
								);
								
							END IF;
								
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF
				--DEBITO
                IF (v_producto == 2) THEN
                        CALL "informix".sp_upd_debrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;
						
						LET v_codigo_ret = s_CodRet;

							
							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;								
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'||' Folio: '||v_folio; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);		
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
							ELSE
								IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
									
									--Insertar a acl_bitacora_error_rec_saldo para errores
									LET v_fechahora = current; 
									INSERT INTO "informix".acl_bitacora_error_rec_saldo (
									codigo,
									folio_csuac,
									fecha
									)
									VALUES (
									s_CodRet,
									v_folio,
									v_fechahora
									);
									
								END IF;
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF	
--           COMMIT;
    END FOREACH
	LET v_codigo_ret = '000000';
	RETURN v_codigo_ret;
END;
END PROCEDURE;