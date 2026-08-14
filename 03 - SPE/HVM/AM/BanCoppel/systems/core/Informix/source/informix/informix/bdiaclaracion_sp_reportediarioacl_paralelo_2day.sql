CREATE PROCEDURE "informix".sp_reportediarioacl_paralelo_2day(num_reporte_inicial SMALLINT, num_reporte_final SMALLINT) returning char(7);

  --DEFINE ejecuta 					char(256);
	DEFINE vsql        				char(3000);
	DEFINE vcodret					char(7);
	DEFINE vsqlerr					integer;
	DEFINE p_folio					varchar(11);
	DEFINE p_fechahoy				date;
	DEFINE p_fecha_sistema      	date; -- JLM 24/05/2022
 	DEFINE p_fecha_predictamen  	date;
	DEFINE p_entrada_bitacora   	integer;
	DEFINE p_fecha_captura			date;
	DEFINE p_folio_suc				varchar(30);
	DEFINE p_tarjeta				varchar(16);
	DEFINE p_interc					char(1);
	DEFINE p_modo					char(4);
	DEFINE v_estatus_analisis		integer;
	DEFINE p_fecha_hoy_inicio       DATETIME YEAR TO FRACTION(5);
	DEFINE p_fecha_hoy_fin          DATETIME YEAR TO FRACTION(5);

	--Aclaraciones
	DEFINE iContador  				INTEGER;
	DEFINE pen_vFolio_cs 			VARCHAR(11);
	DEFINE pen_dFechaCap 			DATE;
	DEFINE pen_dFechaDic 			DATE;
	DEFINE pen_mImporteOri 			MONEY;
	DEFINE pen_vNumEmp				VARCHAR(8);
	DEFINE pen_cpModo				CHAR(4);
	DEFINE pen_vNombre 				VARCHAR(45);
	DEFINE pen_v_estatus_aclara		VARCHAR(255);
	DEFINE pen_v_estatus_ana		VARCHAR(255);
	DEFINE pen_v_estatus_general 	VARCHAR(255);
	DEFINE pen_v_estatus_complementario 	VARCHAR(255);
	DEFINE pen_cSucursal	  		CHAR(4);
	DEFINE pen_vTipoMovto 			VARCHAR(50);
	DEFINE pen_cNumCte 				CHAR(20);
	DEFINE pen_vNumerCta 			VARCHAR(12);
	DEFINE pen_vNumTarjeta 			VARCHAR(16);
	DEFINE pen_dFechaHora			DATETIME YEAR TO FRACTION;
	DEFINE pen_dFechaAfe 			DATETIME YEAR TO FRACTION;
	DEFINE pen_vReferencia23 		VARCHAR(23);
	DEFINE pen_vRefComer1			VARCHAR(40);
	DEFINE pen_iFkyTpoEve			INTEGER;
	DEFINE pen_vDescripcion4 		VARCHAR(50);
	DEFINE pen_sProcede 			SMALLINT;
	DEFINE pen_vDescripcion5 		VARCHAR(50);
	DEFINE pen_vDescripcion6 		VARCHAR(255);
	DEFINE pen_mMontoPro 			MONEY;
	DEFINE pen_mImporteAcla 		MONEY;
	DEFINE pen_cNombreCte 			CHAR(150);
	-----------------------------------
	DEFINE pen_cNombre1 			CHAR (150);
	DEFINE pen_cNombre2 			CHAR (150);
	DEFINE pen_cApellPat 			CHAR (150);
	DEFINE pen_cApellMat 			CHAR (150);
	-----------------------------------
	DEFINE pen_lPredictamen1 		LVARCHAR;
	DEFINE pen_cFechaPredi3 		CHAR(100);
	DEFINE pen_iFkyFlujoCausa 		INTEGER;
	DEFINE pen_cCierreForz1			CHAR(100);
	DEFINE pen_vFolioSuc 			VARCHAR(30);
	DEFINE pen_dFechaConsu 			DATETIME YEAR TO FRACTION;
	DEFINE pen_vcanal_entrada 		VARCHAR(250);
	DEFINE pen_cTelefono 			CHAR(13);
	DEFINE pen_cCorreo	  			CHAR(100);
	DEFINE pen_tokens63in			LVARCHAR;
	DEFINE pen_cod_eci				char(1);
	DEFINE pen_medio				char(50);
	DEFINE pen_metodo				char(5);
	DEFINE pen_idterminal			varchar(16);
	DEFINE pen_fecha_ccv        	DATETIME YEAR TO FRACTION;
	DEFINE pen_secuencial 			VARCHAR(100);
	DEFINE pen_status_tar       	varchar(10);
	DEFINE pen_fecha_estatus        DATETIME YEAR TO FRACTION;
	DEFINE pen_token         		char(50);
	DEFINE pen_Q2					char(50);
	DEFINE pen_token_2         		char(50);
	DEFINE pen_Q2_2					char(50);

	--Nuevas variables
	DEFINE v_id_aclaracion 		INTEGER;
	DEFINE v_analista 			INTEGER;
	DEFINE v_id_estatus_acl 	INTEGER;
	DEFINE v_id_estatus_corp 	INTEGER;
	DEFINE v_id_estatus_ana 	INTEGER;
	DEFINE v_num_cte			CHAR(10);
	DEFINE v_id_producto		INTEGER;
	DEFINE v_id_transaccion 	INTEGER;
	DEFINE v_id_solicitud_e_global INTEGER;
	DEFINE v_id_tipo_acl		INTEGER;

	--Tabla de reportes
	DEFINE v_reporte 			SMALLINT;
	DEFINE v_nombre 			VARCHAR(30);
	DEFINE v_codret 			CHAR(7);
	DEFINE v_encabezado 		LVARCHAR(1000);
	DEFINE v_campos 			LVARCHAR(1000);
	DEFINE v_nombre_extra 		VARCHAR(30);
	DEFINE v_codret_extra 		CHAR(7);
	DEFINE v_encabezado_extra 	LVARCHAR(1000);
	DEFINE v_campos_extra 		LVARCHAR(1000);

	--Generales
	DEFINE v_crm_descripcion 	VARCHAR(255);
	DEFINE v_accion				integer;
	DEFINE ISAM_ERR				INTEGER;
	DEFINE ERROR_INFO			VARCHAR(50);

	LET v_accion 		= 0;
	LET v_crm_descripcion	= '';
	LET iContador 		= 0;
	LET pen_vFolio_cs 		= '';
	LET pen_dFechaCap 		= '';
	LET pen_dFechaDic 		= '';
	LET pen_mImporteOri 	= '';
	LET pen_vNumEmp			= '';
	LET pen_cpModo			= '';
	LET pen_vNombre 		= '';
	LET pen_v_estatus_aclara 	= '';
	LET pen_v_estatus_ana 	= '';
	LET pen_v_estatus_general 	= '';
	LET pen_v_estatus_complementario = '';
	LET pen_cSucursal	  	= '';
	LET pen_vTipoMovto 		= '';
	LET pen_cNumCte 		= '';
	LET pen_vNumerCta 		= '';
	LET pen_vNumTarjeta 	= '';
	LET pen_dFechaHora		= '';
	LET pen_dFechaAfe 		= '';
	LET pen_vReferencia23 	= '';
	LET pen_vRefComer1		= '';
	LET pen_iFkyTpoEve		= 0;
	LET pen_vDescripcion4 	= '';
	LET pen_sProcede 		= 0;
	LET pen_vDescripcion5 	= '';
	LET pen_vDescripcion6 	= '';
	LET pen_mMontoPro 		= '';
	LET pen_mImporteAcla 	= '';
	LET pen_cNombreCte 		= '';
	LET pen_lPredictamen1 	= '';
	LET pen_iFkyFlujoCausa 	= 0;
	LET pen_vFolioSuc 		= '';
	LET pen_dFechaConsu 	= '';
	LET pen_vcanal_entrada 	= '';
	LET pen_cTelefono 		= '';
	LET pen_cCorreo	  		= '';
	LET pen_cNombre1    = '';
	LET pen_cNombre2    = '';
	LET pen_cApellPat   = '';
	LET pen_cApellMat   = '';
	LET pen_cod_eci	= '';
	LET pen_medio	= '';
	LET pen_metodo	= '';
	LET pen_idterminal = '';
	LET pen_fecha_ccv  = '';
	LET pen_secuencial = '';
	LET pen_status_tar = '';
	LET pen_fecha_estatus = '';
	LET pen_tokens63in = '';
	LET pen_token = '';
	LET pen_Q2	= '';
	LET pen_token_2 = '';
	LET pen_Q2_2 = '';

	LET vcodret = "0000001";

  BEGIN

	on exception set vsqlerr, ISAM_ERR, ERROR_INFO
  		SET DEBUG FILE TO "/resplogifx/repaclaraciones"||"sp_reportediarioacl_"||num_reporte_inicial||".out" WITH APPEND;
        TRACE ON;

		if vsqlerr <> 0 then
			let vcodret = vsqlerr;
			INSERT INTO resultados_sp_reportediarioacl VALUES (num_reporte_inicial, vcodret, ERROR_INFO);
			return vcodret;
		end if;
	end exception;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

  	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_reportediarioacl_paralelo_2day_"||num_reporte_inicial||".out";
	--TRACE ON;
	--set explain file to "/resplogifx/repaclaracionessp_reportediarioacl_paralelo_"||num_reporte_inicial||".exp";

	--Creacion de tabla temporal de control de los 6(5+1) reportes
	CREATE TEMP TABLE reportes_acl(reporte SMALLINT, nombre VARCHAR(30), codret CHAR(7), encabezado LVARCHAR(1000), campos LVARCHAR(1000),
								   nombre_extra VARCHAR(30), codret_extra CHAR(7), encabezado_extra LVARCHAR(1000), campos_extra LVARCHAR(1000), primary key (reporte)) WITH NO LOG;
	INSERT INTO reportes_acl
		SELECT *
		  FROM (
			--Generacion de registros para Reporte Diario (Aclaraciones Pendientes)
			SELECT 1,'pendientes','0000000',
					 'FechaCaptura|Fecha_dictamen|folio_csuac|importeoriginal|num_empleado|modo_de_entrada|analista|status_acl|status_corp|status_analisis|num_suc|origen|cliente|numero_cuenta|plastico|fecha_de_cargo|fecha_afectacion|referencia23|ref_comercio|tipo_evento|evento|procede|seleccion_transaccion|resp_E_Global|montoprocedente|importereclamado|nombre_cliente|predictamen|Canal_Entrada|telefono|correo|Cod_ECI|Medio_Acceso|Token_C4_S12|Fecha_Activacion_CVV2_Dinamico|ID_Comercio|Status_Plastico|Fecha_Trxn_original|Hora_Trxn_original|Fecha_cancelacion_Plastico|Hora_Cancelacion_Plastico',
                     'DATE(fechacaptura), DATE(fecha_dictamen), folio_csuac, importeoriginal, num_empleado,trim(modo_de_entrada),nombre,trim(descripcion),status_corp,status_analisis,num_suc,trim(origen),cliente,numero_cuenta,plastico, DATE(fecha_de_cargo), DATE(fecha_afectacion),trim(referencia23),trim(ref_comercio),tipo_evento,evento,procede,sel_tran,resp_eglobal,montoprocedente,importereclamado,trim(nombre_cliente),SUBSTRING(predictamen FROM 0 FOR 50),canal_entrada,telefono,correo,eci,medio,metodo,fecha_cvv2,idterminal,status_tarjeta,DATE(fecha_consumo),extend(fecha_consumo,hour to second),DATE(fecha_cambio_status),extend(fecha_cambio_status,hour to second)',
					  "","","",""
			  FROM table(set{1})
			union all
			--Generacion de registros para Reporte Diario (Aclaraciones en pre-ingresos)
			SELECT 2,'preingresos','0000000',
					 'FechaCaptura|Fecha_dictamen|folio_csuac|importeoriginal|num_empleado|modo_de_entrada|analista|status_acl|status_corp|status_analisis|num_suc|origen|cliente|numero_cuenta|plastico|fecha_de_cargo|fecha_afectacion|referencia23|ref_comercio|tipo_evento|evento|procede|seleccion_transaccion|resp_E_Global|montoprocedente|importereclamado|nombre_cliente|predictamen|Canal_Entrada|telefono|correo',
					 'DATE(fechacaptura), DATE(fecha_dictamen), folio_csuac, importeoriginal, num_empleado,trim(modo_de_entrada),nombre,trim(descripcion),'||
					 'status_corp,status_analisis,num_suc,trim(origen),cliente,numero_cuenta,plastico, DATE(fecha_de_cargo), DATE(fecha_afectacion),trim(referencia23),'||
					 'trim(ref_comercio),tipo_evento,evento,procede,sel_tran,resp_eglobal,montoprocedente,importereclamado,trim(nombre_cliente),'||
					 'SUBSTRING(predictamen FROM 0 FOR 50),canal_entrada,telefono,correo',
					  "","","",""
			  FROM table(set{1})
			union all
			--Generacion de Reporte Diario (Aclaraciones En pre-ingreso declinadas)
			SELECT 3,'preingresosdeclinados','0000000',
				     'FechaCaptura|Fecha_dictamen|folio_csuac|importeoriginal|num_empleado|modo_de_entrada|analista|status_acl|status_corp|status_analisis|num_suc|origen|cliente|numero_cuenta|plastico|fecha_de_cargo|fecha_afectacion|referencia23|ref_comercio|tipo_evento|evento|procede|seleccion_transaccion|resp_E_Global|montoprocedente|importereclamado|nombre_cliente|predictamen|Canal_Entrada|telefono|correo',
					 'DATE(fechacaptura), DATE(fecha_dictamen), folio_csuac, importeoriginal, num_empleado,trim(modo_de_entrada),nombre,trim(descripcion),'||
					 'status_corp,status_analisis,num_suc,trim(origen),cliente,numero_cuenta,plastico, DATE(fecha_de_cargo), DATE(fecha_afectacion),trim(referencia23),'||
					 'trim(ref_comercio),tipo_evento,evento,procede,sel_tran,resp_eglobal,montoprocedente,importereclamado,trim(nombre_cliente),'||
					 'SUBSTRING(predictamen FROM 0 FOR 50),canal_entrada,telefono,correo',
					  "","","",""
			  FROM table(set{1})
			union all
			--Generacion de Reporte Diario (FINALIZADAS HOY)
			SELECT 4,'FinalizadaHoy','0000000',
					 'FechaCaptura|Fecha_dictamen|folio_csuac|importeoriginal|num_empleado|modo_de_entrada|analista|status_acl|status_corp|status_analisis|num_suc|origen|cliente|numero_cuenta|plastico|fecha_de_cargo|fecha_afectacion|referencia23|ref_comercio|tipo_evento|evento|procede|seleccion_transaccion|resp_E_Global|montoprocedente|importereclamado|nombre_cliente|predictamen|fecha_predictamen|cierre_forzado',
					 'DATE(fechacaptura), DATE(fecha_dictamen), folio_csuac, importeoriginal, num_empleado,trim(modo_de_entrada),trim(nombre),trim(descripcion),'||
					 'status_corp,status_analisis,num_suc,trim(origen),cliente,numero_cuenta,plastico, DATE(fecha_de_cargo), DATE(fecha_afectacion),trim(referencia23),'||
					 'trim(ref_comercio),tipo_evento,evento,procede,sel_tran,resp_eglobal,montoprocedente,importereclamado,trim(nombre_cliente),'||
					 'SUBSTRING(predictamen FROM 1 FOR 350), DATE(fecha_predictamen), trim(cierre_forzado)',
			--Generacion de Desglose (FINALIZADAS HOY)
					 'Desglose_folios','0000000',
					 'csuac|descripcion|monto|procede',
					 'a.folio_csuac,trim(b.descripcion),a.monto,c.procede'
			  FROM table(set{1})
			union all
			--Generacion de Reporte Diario (FINALIZADAS MES ACTUAL)
			SELECT 5,'FinalizadaMes','0000000',
					 'FechaCaptura|Fecha_dictamen|folio_csuac|importeoriginal|num_empleado|modo_de_entrada|analista|status_acl|status_corp|status_analisis|num_suc|origen|cliente|numero_cuenta|plastico|fecha_de_cargo|fecha_afectacion|referencia23|ref_comercio|tipo_evento|evento|procede|seleccion_transaccion|resp_E_Global|montoprocedente|importereclamado|nombre_cliente|predictamen',
					 'DATE(fechacaptura), DATE(fecha_dictamen), folio_csuac, importeoriginal, num_empleado,modo_de_entrada,nombre,descripcion,'||
					 'status_corp,status_analisis,num_suc,trim(origen),cliente,numero_cuenta,plastico, DATE(fecha_de_cargo), DATE(fecha_afectacion),trim(referencia23),'||
					 'trim(ref_comercio),tipo_evento,evento,procede,sel_tran,resp_eglobal,montoprocedente,importereclamado,trim(nombre_cliente),'||
					 'SUBSTRING(predictamen FROM 0 FOR 50), DATE(fecha_predictamen), cierre_forzado',
					  "","","",""
			  FROM table(set{1})
		  );

	let vsqlerr = 0;

	SELECT {+AVOID_FULL (bdinteg:si_fechas)} fecha_hoy
	  into p_fechahoy
	  FROM bdinteg:si_fechas;

	--Se obtiene fecha del sistema.
	LET p_fecha_sistema = TODAY;

--Pruebas
--let p_fechahoy = "03/31/2022";
--let p_fecha_sistema = "04/01/2022";

--    IF p_fechahoy <> (p_fecha_sistema -1) THEN
    	LET p_fechahoy = p_fecha_sistema -3;
    --END IF;

	let p_fecha_hoy_inicio = SUBSTRING((EXTEND(p_fechahoy)) FROM 1 FOR 10)||' 00:00:00.00000';
	let p_fecha_hoy_fin = SUBSTRING((EXTEND(p_fechahoy)) FROM 1 FOR 10)||' 23:59:59.99999';

	if num_reporte_inicial = 0 then -- solo para calcular el n?mero de reportes a generar para el proceso asincrono a traves del controlador
		select {+AVOID_FULL (reportes_acl)} count(*) into num_reporte_inicial from reportes_acl;

		if (month(p_fechahoy) - month(p_fechahoy+1)) = 0 then  --no estoy en el dia ultimo del mes
			let num_reporte_inicial = num_reporte_inicial - 1;
		end if;

		return num_reporte_inicial;
	end if;

	--Se obtiene el estas a validar para el CAT
	select pky_estatus_corporativo
	  into v_estatus_analisis
	  From acl_estatus_corporativo
	 where nombre='PRE_INGRESO';

	----Se obtiene el fky_accion de los preingresos declinados
	select 
		   pky_resolucion
	  into v_accion
	  from acl_resolucion
	 where nombre = 'registroIntento';

	LET p_modo = null;

	FOREACH
		SELECT {+AVOID_FULL reportes_acl}
			   reporte, nombre, codret, encabezado, campos, nombre_extra, codret_extra, encabezado_extra, campos_extra
		  INTO v_reporte, v_nombre, v_codret, v_encabezado, v_campos, v_nombre_extra, v_codret_extra, v_encabezado_extra, v_campos_extra
		  FROM reportes_acl
		 WHERE reporte >= num_reporte_inicial and reporte <= num_reporte_final
		ORDER BY 1

		if v_reporte = 5 and (month(p_fechahoy) - month(p_fechahoy+1)) = 0 then
			continue foreach;
		end if;

		LET iContador = 0;

		FOREACH
				SELECT 	
				   		a.folio_csuac, a.fechacaptura, date(a.fecha_dictamen) as fecha_dictamen,  a.importeoriginal, a.num_empleado,
						a.num_sucursal as num_suc,  a.tipo_movimiento as origen, a.fky_tipo_evento as tipo_evento, a.procede,
						a.importereclamado, a.montoprocedente, a.predictamen, '' as fecha_predictamen,
					 	a.fky_estatus_flujo_causa as causa_cierre, '' as cierre_forzado, a.pky_aclaracion, a.fky_usuario_analista,
					    a.fky_estatus_aclaracion, a.fky_estatus_corp_general, a.fky_estatus_corp_analisis, a.num_cliente, a.fky_producto,
					    a.fky_cat_tipo_aclaracion
				  INTO  pen_vFolio_cs, pen_dFechaCap, pen_dFechaDic, pen_mImporteOri, pen_vNumEmp,
						pen_cSucursal, pen_vTipoMovto, pen_iFkyTpoEve, pen_sProcede,
						pen_mImporteAcla, pen_mMontoPro, pen_lPredictamen1, pen_cFechaPredi3, pen_iFkyFlujoCausa, pen_cCierreForz1,
						v_id_aclaracion, v_analista, v_id_estatus_acl, v_id_estatus_corp,
						v_id_estatus_ana, v_num_cte, v_id_producto, v_id_tipo_acl
				  FROM acl_aclaracion a, reportes_acl r
			   	 WHERE r.reporte = 1 and r.reporte = v_reporte
									 and a.folio_csuac is not null
									 and a.fky_estatus_aclaracion = 2
				UNION ALL
				SELECT 	
						DISTINCT a.folio_csuac, a.fechacaptura, date(a.fecha_dictamen) as fecha_dictamen,  a.importeoriginal, a.num_empleado,
						a.num_sucursal as num_suc,  a.tipo_movimiento as origen, a.fky_tipo_evento as tipo_evento, a.procede,
						a.importereclamado, a.montoprocedente, a.predictamen, '' as fecha_predictamen,
					 	a.fky_estatus_flujo_causa as causa_cierre, '' as cierre_forzado, a.pky_aclaracion, a.fky_usuario_analista,
					    a.fky_estatus_aclaracion, a.fky_estatus_corp_general, a.fky_estatus_corp_analisis, a.num_cliente, a.fky_producto,
					    a.fky_cat_tipo_aclaracion
				  FROM acl_aclaracion a, reportes_acl r
			   	 WHERE r.reporte = 2 and r.reporte = v_reporte
						   			 and a.fky_estatus_corp_analisis = v_estatus_analisis
						   			 and a.fky_estatus_aclaracion = 1
				UNION ALL
				SELECT 	
						DISTINCT a.folio_csuac, a.fechacaptura, date(a.fecha_dictamen) as fecha_dictamen,  a.importeoriginal, a.num_empleado,
						a.num_sucursal as num_suc,  a.tipo_movimiento as origen, a.fky_tipo_evento as tipo_evento, a.procede,
						a.importereclamado, a.montoprocedente, a.predictamen, '' as fecha_predictamen,
					 	a.fky_estatus_flujo_causa as causa_cierre, '' as cierre_forzado, a.pky_aclaracion, a.fky_usuario_analista,
					    a.fky_estatus_aclaracion, a.fky_estatus_corp_general, a.fky_estatus_corp_analisis, a.num_cliente, a.fky_producto,
					    a.fky_cat_tipo_aclaracion
				  FROM acl_aclaracion a, acl_entrada_bitacora eb, reportes_acl r
			   	 WHERE r.reporte = 3 and r.reporte = v_reporte
						   			 and eb.folio_csuac = a.folio_csuac
						   			 and eb.fky_accion = v_accion
						   			 and eb.fechahora >= p_fecha_hoy_inicio and eb.fechahora <= p_fecha_hoy_fin
						   			 and a.pky_aclaracion = eb.fky_aclaracion
						   			 and a.fky_estatus_aclaracion = 1
						   			 and a.folio_csuac is not null
				UNION ALL
				SELECT 
						DISTINCT a.folio_csuac, a.fechacaptura, date(a.fecha_dictamen) as fecha_dictamen,  a.importeoriginal, a.num_empleado,
						a.num_sucursal as num_suc,  a.tipo_movimiento as origen, a.fky_tipo_evento as tipo_evento, a.procede,
						a.importereclamado, a.montoprocedente, a.predictamen, '' as fecha_predictamen,
					 	a.fky_estatus_flujo_causa as causa_cierre, '' as cierre_forzado, a.pky_aclaracion, a.fky_usuario_analista,
					    a.fky_estatus_aclaracion, a.fky_estatus_corp_general, a.fky_estatus_corp_analisis, a.num_cliente, a.fky_producto,
					    a.fky_cat_tipo_aclaracion
				  FROM acl_aclaracion a, reportes_acl r
			   	 WHERE (r.reporte = 4 or r.reporte = 5) and r.reporte = v_reporte
						   								and a.folio_csuac is not null
						   								and a.fky_estatus_aclaracion >= 3 and a.fky_estatus_aclaracion <= 5


				if (v_reporte = 4 and (pen_dFechaDic < p_fechahoy)) or --ojo <> para pruebas, pero debe ser <
				   (v_reporte = 5 and ((month(pen_dFechaDic) <> month(p_fechahoy)) or (year(pen_dFechaDic) <> year(p_fechahoy)))) then
					continue foreach;
				end if;


				LET pen_cpModo = p_modo;

				SELECT FIRST 1 date(i.fechahora) as fecha_de_cargo, date(i.fecha_afectacion) as fecha_afectacion, i.referencia23, i.ref_comercio,
						i.folio_suc, i.fecha_consumo as fecha_consumo, i.fky_tipo_catalogo_transaccion, i.fky_solicitud_e_global
					INTO pen_dFechaHora, pen_dFechaAfe, pen_vReferencia23, pen_vRefComer1,
						pen_vFolioSuc, pen_dFechaConsu, v_id_transaccion, v_id_solicitud_e_global
				FROM "informix".acl_movimiento i
				WHERE fky_aclaracion = v_id_aclaracion AND folio_csuac is not null;

				SELECT FIRST 1 j.nombre as analista
					INTO pen_vNombre
				FROM "informix".acl_usuario j
				WHERE j.pky_usuario = v_analista;
				LET pen_vNombre = NVL(pen_vNombre, ' ');

				SELECT FIRST 1 b.descripcion as status_acl
					INTO pen_v_estatus_aclara
				FROM "informix".acl_estatus_aclaracion b
				WHERE b.pky_estatus_aclaracion = v_id_estatus_acl;
				SELECT FIRST 1 g.descripcion as status_corp
					INTO pen_v_estatus_general
				FROM "informix".acl_estatus_corporativo g
				WHERE g.pky_estatus_corporativo = v_id_estatus_corp;

				SELECT FIRST 1 k.descripcion as status_analisis
					INTO pen_v_estatus_ana
				FROM "informix".acl_estatus_corporativo k
				WHERE k.pky_estatus_corporativo = v_id_estatus_ana;

				SELECT FIRST 1 f.descripcion as evento
					INTO pen_vDescripcion4
				FROM "informix".acl_tipo_evento f
				WHERE f.pky_tipo_evento  = pen_iFkyTpoEve;

				SELECT FIRST 1 {+INDEX(bdinteg:"informix".si_cliente " 224_479")}
				    d.numcte as cliente,d.nombre1,d.nombre2,d.apell_paterno,d.apell_materno
					INTO pen_cNumCte, pen_cNombre1, pen_cNombre2, pen_cApellPat, pen_cApellMat
				FROM bdinteg:si_cliente d
				WHERE d.numcte = v_num_cte;

				SELECT FIRST 1 e.numero_cuenta, e.numero_tarjeta as plastico
					INTO pen_vNumerCta, pen_vNumTarjeta
				FROM "informix".acl_producto e
				WHERE e.pky_producto = v_id_producto;

				SELECT FIRST 1 l.descripcion as seleccion_transaccion
					INTO pen_vDescripcion5
				FROM "informix".acl_tipo_catalogo_transaccion l
				WHERE l.pky_tipo_catalogo_transaccion = v_id_transaccion;

				IF v_id_solicitud_e_global IS NOT NULL THEN
					SELECT FIRST 1 o.descripcion as resp_e_global
						INTO pen_vDescripcion6
					FROM "informix".acl_solicitud_e_global m
						INNER JOIN "informix".acl_respuesta_e_global n ON m.fky_respuesta_e_global = n.pky_respuesta_e_global
						INNER JOIN "informix".acl_tipo_respuesta_e_global o ON n.fky_tipo_respuesta_e_global = o.pky_tipo_respuesta_e_global
					WHERE m.pky_solicitud_e_global = v_id_solicitud_e_global;
				ELSE
					LET pen_vDescripcion6 = NULL;
				END IF;

				SELECT FIRST 1 ca.nombre as canal_entrada
					INTO pen_vcanal_entrada
				FROM "informix".acl_cat_tipo_aclaracion ca
				WHERE ca.pky_cat_tipo_aclaracion = v_id_tipo_acl;

				SELECT FIRST 1 {+INDEX(bdinteg:"informix".si_telefonos_actual idx_telact_cte_cons)}
						 tl.telefono as telefono
					INTO pen_cTelefono
				FROM bdinteg:si_telefonos_actual tl
				WHERE tl.numcte = v_num_cte AND tl.tipo_tel = '1' AND tl.status_tel = 'A';

				SELECT  FIRST 1 {+INDEX(bdinteg:"informix".si_correos idx_corr_cte_cons)}
						 co.correo_elec as correo
					INTO pen_cCorreo
				FROM bdinteg:si_correos co
				WHERE co.numcte = v_num_cte AND co.tipo_correo = '1'  AND co.status_correo = 'A';

				if v_reporte = 1 then
					SELECT FIRST 1 corp.descripcion as status_comple
						INTO pen_v_estatus_complementario
					FROM "informix".acl_aclaracion_estatus_proceso_analisis est
					INNER JOIN "informix".acl_estatus_corporativo corp on est.fky_estatus_corporativo = corp.pky_estatus_corporativo
					WHERE est.fky_aclaracion = v_id_aclaracion;
					LET pen_v_estatus_complementario = NVL(pen_v_estatus_complementario,'');
					if pen_v_estatus_complementario <> '' then
						LET pen_v_estatus_general = (pen_v_estatus_general||'-'||pen_v_estatus_complementario);
					end if;
				else
					LET pen_v_estatus_ana = NVL(pen_v_estatus_ana, ''); --por razones inexplicables
				end if;

				LET pen_vNombre = trim(pen_vNombre);
				LET pen_vTipoMovto = DECODE(pen_vTipoMovto,'V','Nacional','F','Internacional','',null,null,null);
				LET pen_vReferencia23 = trim(pen_vReferencia23);
				LET pen_vRefComer1 = trim(pen_vRefComer1);
				LET pen_cNombreCte = trim(pen_cNombre1)||' '||trim(pen_cNombre2)||' '||trim(pen_cApellPat)||' '||trim(pen_cApellMat);
				LET pen_lPredictamen1 = trim(pen_lPredictamen1);
				LET pen_cCorreo= NVL(pen_cCorreo, ' ');
				LET pen_cSucursal= NVL(pen_cSucursal, ' ');

				INSERT INTO acl_reporte_diario (reporte, folio_csuac, fechacaptura, fecha_dictamen, importeoriginal, num_empleado, modo_de_entrada,
												nombre, descripcion, status_corp, status_analisis, num_suc, origen, cliente, numero_cuenta,
												plastico, fecha_de_cargo, fecha_afectacion, referencia23, ref_comercio, tipo_evento, evento,
												procede, sel_tran, resp_eglobal, montoprocedente, importereclamado, nombre_cliente, predictamen,
												fecha_predictamen, causa_cierre,	cierre_forzado, folio_suc, fecha_consumo, canal_entrada,
												telefono, correo,  eci, medio, metodo, idterminal, fecha_cvv2, status_tarjeta, fecha_cambio_status)
				VALUES (v_reporte, pen_vFolio_cs, pen_dFechaCap, pen_dFechaDic, pen_mImporteOri, pen_vNumEmp, pen_cpModo, pen_vNombre, pen_v_estatus_aclara,pen_v_estatus_general, pen_v_estatus_ana,
						pen_cSucursal, pen_vTipoMovto, pen_cNumCte, pen_vNumerCta, pen_vNumTarjeta, pen_dFechaHora, pen_dFechaAfe, pen_vReferencia23, pen_vRefComer1, pen_iFkyTpoEve, pen_vDescripcion4, pen_sProcede,
						pen_vDescripcion5, pen_vDescripcion6, pen_mMontoPro, pen_mImporteAcla, pen_cNombreCte, pen_lPredictamen1, pen_cFechaPredi3, pen_iFkyFlujoCausa, pen_cCierreForz1,
						pen_vFolioSuc, pen_dFechaConsu, pen_vcanal_entrada, pen_cTelefono, pen_cCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

				LET iContador = iContador + 1;

				IF iContador = 1000 THEN
					LET iContador = 0;
				END IF;
		END FOREACH;

		LET iContador = 0;

		FOREACH
			SELECT folio_csuac, plastico, substr(folio_suc,2), SUBSTRING(folio_suc FROM 0 FOR 2), fechacaptura
			  INTO p_folio, p_tarjeta, p_folio_suc, p_interc, p_fecha_captura
			  FROM acl_reporte_diario
			 where reporte = v_reporte

			if v_reporte = 4 or v_reporte = 5 then
				IF ((select procede from acl_reporte_diario where reporte = v_reporte and folio_csuac=p_folio) is null) THEN
					update acl_reporte_diario set montoprocedente=0 where reporte = v_reporte and folio_csuac=p_folio;
				END IF;

				UPDATE acl_reporte_diario
				set montoprocedente=(select montoprocedente from acl_movimiento where folio_csuac=p_folio and fky_aclaracion is not null)
				where reporte = v_reporte and folio_csuac=p_folio and procede='1';

				select max(fechahora)
				into p_fecha_predictamen
				from acl_entrada_bitacora
				where fky_aclaracion in (Select pky_aclaracion from acl_aclaracion where folio_csuac=p_folio)
				and fky_accion in ('9', '25');

				update acl_reporte_diario
				set fecha_predictamen = p_fecha_predictamen
				where reporte = v_reporte and folio_csuac=p_folio;

				select descripcion
				INTO v_crm_descripcion
				from acl_entrada_bitacora
				where pky_entrada_bitacora = (select max(pky_entrada_bitacora) from acl_entrada_bitacora where date(fechahora)>=p_fecha_captura and folio_csuac=p_folio and fky_accion = '24');

				LET v_crm_descripcion = SUBSTR(v_crm_descripcion, 50);

				UPDATE acl_reporte_diario
				SET cierre_forzado = v_crm_descripcion
				WHERE reporte = v_reporte and folio_csuac =p_folio and causa_cierre in ('20','22','23','24','25');
			end if;

			if v_reporte = 1 then
				SELECT FIRST 1 {+INDEX(intercard:"informix".movimiento idx_movimiento21)}
				eci,tokens63in,idterminal INTO pen_cod_eci,pen_tokens63in,pen_idterminal
				FROM intercard:movimiento
				WHERE numtarjeta=p_tarjeta
				and secuenciaextendida=p_folio_suc;

				LET pen_token = SUBSTR(pen_tokens63in,39,2);
				LET pen_Q2 = SUBSTR(pen_tokens63in,27,2);
				IF pen_token = 'C4' AND pen_Q2 = 'Q2' THEN
					LET pen_metodo = SUBSTR(pen_tokens63in,58,1);
					LET pen_medio =  SUBSTR(pen_tokens63in,35,2);
				END IF;

				LET pen_token_2 = SUBSTR(pen_tokens63in,75,2);
				LET pen_Q2_2 = SUBSTR(pen_tokens63in,27,2);
				IF pen_token_2 = 'C4' AND pen_Q2_2 = 'Q2' THEN
					LET pen_metodo = SUBSTR(pen_tokens63in,94,1);
					LET pen_medio =  SUBSTR(pen_tokens63in,35,2);
				END IF;

				IF (pen_cod_eci = '' or pen_cod_eci is null) AND (pen_medio = '' or pen_medio is null) AND (pen_idterminal='' or pen_idterminal is null) AND (pen_metodo = '' or pen_metodo is null) THEN
					LET pen_token = '';
					LET pen_Q2 = '';
					LET pen_token_2 = '';
					LET pen_Q2_2 = '';

					SELECT FIRST 1 {+INDEX(intercard:"informix".movimientohistorico idx_movimiento1)}
					         eci,tokens63in,idterminal INTO pen_cod_eci,pen_tokens63in,pen_idterminal
						FROM intercard:movimientohistorico
					WHERE numtarjeta=p_tarjeta
					and secuenciaextendida=p_folio_suc;

					LET pen_token = SUBSTR(pen_tokens63in,39,2);
					LET pen_Q2 = SUBSTR(pen_tokens63in,27,2);
					IF pen_token = 'C4' AND pen_Q2 = 'Q2' THEN
						LET pen_metodo = SUBSTR(pen_tokens63in,58,1);
						LET pen_medio =  SUBSTR(pen_tokens63in,35,2);
					END IF;

					LET pen_token_2 = SUBSTR(pen_tokens63in,75,2);
					LET pen_Q2_2 = SUBSTR(pen_tokens63in,27,2);
					IF pen_token_2 = 'C4' AND pen_Q2_2 = 'Q2' THEN
						LET pen_metodo = SUBSTR(pen_tokens63in,94,1);
						LET pen_medio =  SUBSTR(pen_tokens63in,35,2);
					END IF;
				END IF;

				SELECT {+INDEX(intercard:"informix".bitacoracambiostarjeta idx_bitcambiostjt_03)}
				min(secuencial) into pen_secuencial
				FROM intercard:bitacoracambiostarjeta WHERE tarjeta = p_tarjeta and identificadorcambio = '9';

				IF (pen_secuencial <>  '' or  pen_secuencial is not null) THEN
					SELECT FIRST 1 {+INDEX(intercard:"informix".bitacoracambiostarjeta idx_bitcambiostjt_03)}
					fechacambio into pen_fecha_ccv
					FROM intercard:bitacoracambiostarjeta WHERE tarjeta = p_tarjeta and secuencial = pen_secuencial;
				END IF;

				SELECT FIRST 1 {+INDEX(intercard:"informix".tarjeta " 144_89")}
				codstatustarjeta into pen_status_tar
				FROM intercard:tarjeta WHERE numtarjeta = p_tarjeta;

				IF pen_status_tar <> 'ACT' THEN
					LET pen_secuencial = '';
					SELECT {+INDEX(intercard:"informix".bitacoracambiostarjeta idx_bitcambiostjt_03)}
					max(secuencial) into pen_secuencial
					FROM intercard:bitacoracambiostarjeta WHERE tarjeta = p_tarjeta and valornuevo = pen_status_tar;

					SELECT FIRST 1 {+INDEX(intercard:"informix".bitacoracambiostarjeta " 27485_171169")}
					fechacambio into pen_fecha_estatus
					FROM intercard:bitacoracambiostarjeta WHERE secuencial= pen_secuencial;
				END IF;

				UPDATE acl_reporte_diario SET eci = pen_cod_eci, medio = pen_medio, metodo = pen_metodo, idterminal = pen_idterminal, fecha_cvv2 = pen_fecha_ccv, fecha_cambio_status = pen_fecha_estatus, status_tarjeta = pen_status_tar WHERE reporte = v_reporte and folio_csuac=p_folio;
			end if;

			LET p_modo='';
			IF (p_interc='i') THEN
				SELECT FIRST 1 {+INDEX(intercard:"informix".movimiento idx_movimiento21)}
				metodocaptura INTO p_modo
				FROM intercard:movimiento
				WHERE numtarjeta=p_tarjeta and secuenciaextendida=p_folio_suc;

				IF (p_modo='' or p_modo is null ) THEN
					SELECT FIRST 1 {+INDEX(intercard:"informix".movimientohistorico idx_movimiento1)}
					metodocaptura INTO p_modo
					FROM intercard:movimientohistorico
					WHERE numtarjeta=p_tarjeta and secuenciaextendida=p_folio_suc;
				END IF;

				UPDATE acl_reporte_diario SET modo_de_entrada=p_modo WHERE reporte = v_reporte and folio_csuac=p_folio;
			END IF;

			LET iContador = iContador + 1;

			IF iContador = 1000 THEN
				LET iContador = 0;
			END IF;
		END FOREACH;

		let vsql = 'echo "'||trim(v_encabezado)||'">/resplogifx/repaclaraciones/ACL_'||trim(v_nombre)||'_'||LPAD (day(p_fechahoy),2,"0")||LPAD (MONTH(p_fechahoy),2,"0")||year(p_fechahoy)||'.unl';
		system trim(vsql);

		let vsql = 'echo "UNLOAD TO reporte_acl_'||v_reporte||'.unl '||'select '||trim(v_campos)||' from acl_reporte_diario where reporte = '||v_reporte||';"> reporte_acl_'||v_reporte||'.sql';

		system trim(vsql);

		let vsql= 'dbaccess bdiaclaracion reporte_acl_'||v_reporte||'.sql';
		system trim(vsql);

		let vsql = "sed 's/|$//g' reporte_acl_"||v_reporte||".unl >>/resplogifx/repaclaraciones/ACL_"||trim(v_nombre)||"_"||LPAD (day(p_fechahoy),2,"0")||LPAD (MONTH(p_fechahoy),2,"0")||year(p_fechahoy)||".unl";
		system trim(vsql);

		let vcodret = v_codret;

		if v_nombre_extra = 'Desglose_folios' then

			let vsql = ' echo "'||trim(v_encabezado_extra)||'">/resplogifx/repaclaraciones/ACL_'||trim(v_nombre_extra)||'_'||LPAD (day(p_fechahoy),2,"0")||LPAD (MONTH(p_fechahoy),2,"0")||year(p_fechahoy)||'.unl';
			system vsql;

			let vsql=  'echo "UNLOAD TO reporte_acl_'||v_reporte||'.unl '||
					   'select '||v_campos_extra||
					   '  from acl_movimiento a, acl_tipo_movimiento b, acl_aclaracion c, acl_reporte_diario d'||
					   ' where a.fky_tipo_movimiento = b.pky_tipo_movimiento'||
					   '   and a.folio_csuac = c.folio_csuac'||
					   '   and a.folio_csuac = d.folio_csuac'||
					   '   and d.reporte = '||v_reporte||
					   '   and a.exitoso is not null;" > reporte_acl.sql';
			system vsql;

			let vsql= 'dbaccess bdiaclaracion reporte_acl.sql';
			system vsql;

			let vsql = "sed 's/|$//g' reporte_acl_"||v_reporte||".unl >>/resplogifx/repaclaraciones/ACL_"||trim(v_nombre_extra)||"_"||LPAD (day(p_fechahoy),2,"0")||LPAD (MONTH(p_fechahoy),2,"0")||year(p_fechahoy)||".unl";
			system vsql;

			let vcodret = v_codret_extra;
		end if;

		if num_reporte_inicial = num_reporte_final then
			INSERT INTO resultados_sp_reportediarioacl VALUES (v_reporte, vcodret, "PROCESO EXITOSO ASINCRONO");
		else
			INSERT INTO resultados_sp_reportediarioacl VALUES (v_reporte, vcodret, "PROCESO EXITOSO SINCRONO");
		end if;

		delete from acl_reporte_diario where reporte = v_reporte;
	END FOREACH;

	let vsql ='rm -rf reporte_acl*'; system vsql;

	return vcodret;
  end;
end procedure
;