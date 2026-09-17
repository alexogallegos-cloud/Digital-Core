CREATE PROCEDURE "informix".sp_cac_grabanalisisydeterlincred
						(
							pEmpresa			CHAR(3),
							pEjecutivo			CHAR(8),
							pNumSolicitud 		CHAR(20),
							pLincredSugerida	DECIMAL(14,2),
							pMontoIncremento	DECIMAL(18,2),
							pStatus 			CHAR(2),
							pCausaStatus 		CHAR(3),
							pJustificacion		VARCHAR(200),
							pMismoEjecutivo		CHAR(1),
							pIngresoMC              DECIMAL(18,2),
							pOtrosComp              DECIMAL(18,2),
							pNuevoEstatus                 CHAR(2),
							pCausa			CHAR(3)
							)

	--  pMismoEjecutivo - ESTE CAMPO INDICA SI EL EJECUTIVO ESTA GUARDANDO POR PRIMERA VEZ O SOLO SE ACTUALIZA
	-- 0 : SE GUARDA POR PRIMERA VEZ PARA EL EJECUTIVO EN CUESTION
	-- 1: SE ACTUALIZAN LOS DATOS SIN AUMENTAR EL NIVEL

	RETURNING
		CHAR(6)	AS COD_RET,
		CHAR(80) AS MENSAJE_RET;
			
		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cCodRet				CHAR(6);
		DEFINE cMensajeRet			CHAR(80);

		DEFINE cRangoAutorizacion	CHAR(2);
		DEFINE iNivelAutorizacion	INTEGER;
		DEFINE iNivelEjecutivo		INTEGER;		
		DEFINE cCodRetRRC			CHAR(5);
		DEFINE cMensajeRRC			CHAR(80);
		DEFINE cSucursalRRC			CHAR(4);		
		DEFINE cNomEjecutivo		CHAR(45);
		DEFINE cMensajeResp         VARCHAR(200);		
		DEFINE dtFechaInsert        DATE;
		DEFINE cCausa               CHAR(3); 		
		DEFINE cPuestoEjecutivo		CHAR(2);	
		---INICIALIZACIONES
		LET iSqlErr            		= 0;
		LET iIsamErr           		= 0;
		LET cCodRet            		= '000000';
		LET cMensajeRet        		= 'Proceso exitoso';
		
		LET cRangoAutorizacion		= '';
		LET iNivelAutorizacion		= 0;
		LET iNivelEjecutivo			= 0;		
		LET cCodRetRRC				= '00000';
		LET cMensajeRRC				= '';
		LET cSucursalRRC			= '';		
		LET cNomEjecutivo			= '';	
		LET cMensajeResp 				= "";		
		LET dtFechaInsert 				= "";
		LET cCausa                              = '';
		LET cPuestoEjecutivo		= '';
	
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, cMensajeRet;
		   END IF;
		END EXCEPTION;
	 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/informix/jesus/edocta/sp_cac_grabanalisisydeterlincred.out';
		--TRACE ON;
	
		IF pCausa IS NULL OR pCausa = "" THEN 
		  LET cCausa = "";
		ELSE
			LET cCausa = pCausa;
		END IF;		
		
		IF NVL(pNumSolicitud,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pLincredSugerida,0.0) = 0.0 OR NVL(pStatus,'') = '' OR NVL(pJustificacion,'') = '' OR NVL(pNuevoEstatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'UNO O MAS PARAMETROS NO SON VALIDOS';
		ELSE
					
			SELECT MAX(fecha_insert) --PIQV
			INTO dtFechaInsert
			FROM "informix".sd_bitacora_aumlincred
			WHERE empresa = pEmpresa
			AND num_solicitud = pNumSolicitud
			AND status = 'AC';
			
			--SE OBTIENE EL NOMBRE DEL EJECUTIVO.				
			SELECT TRIM(nombre)
			INTO cNomEjecutivo
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pEjecutivo;
			
			-- OBTIENE EL RANGO DE AUTORIZACION DEPENDIENDO DEL MONTO DE INCREMENTO
			SELECT rango_autorizacion
			INTO cRangoAutorizacion
			FROM "informix".sd_autorizaciones_cac_aumlincred 
			WHERE pMontoIncremento BETWEEN monto_minimo AND monto_maximo;
			-- OBTIENE EL MAXIMO NIVEL PARA EL RANGO DE AUTORIZACION
			SELECT MAX(nivel)
			INTO iNivelAutorizacion
			FROM "informix".sd_perfiles_cac_aumlincred 
			WHERE rango_autorizacion = cRangoAutorizacion;
			-- OBTIENE EL NIVEL DEL DEL USUARIO PARA SU RANGO DE AUTORIZACION
			SELECT nivel, puesto
			INTO iNivelEjecutivo, cPuestoEjecutivo
			FROM "informix".sd_perfiles_cac_aumlincred 
			WHERE rango_autorizacion = cRangoAutorizacion
			AND ejecutivo = pEjecutivo;
			-- VALIDA SI EL NIVEL DE AUTORIZACION DEL EJECUTIVO ES MENOR AL NIVEL MAXIMO DEL RANGO DE AUTORIZACION
			IF iNivelEjecutivo < iNivelAutorizacion THEN
				-- VALIDA LA SOLICITUD ESTE EN ANALISIS POR EL CAC
				IF pStatus = 'AT' THEN
					-- ACTUALIZA LA BITACORA DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_bitacora_aumlincred
					SET lincred_sugerida = pLincredSugerida, mensaje = pJustificacion
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC'
					AND fecha_insert = dtFechaInsert;
					-- ACTUALIZA EL MAESTRO DE AUTORIZACIONES DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_autorizacion_aumlincred
					SET revision_cac = iNivelEjecutivo +1, justificacion = pJustificacion
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC';
					--AND fecha_insert = dtFechaInsert;
					--SE ACTUALIZA PROMOTOR , JUSTIFICACION EN LA HISTORICA, INGRESOMC, OTROS COMPONETES, NUEVO ESTATUS Y CAUSA.
					UPDATE "informix".sd_historica_cac_aumlincred 
					SET justificacion = TRIM(cNomEjecutivo)||": " ||TRIM(pJustificacion), ingreso_mc = pIngresoMC, otros_comp = pOtrosComp, estatus = TRIM(pNuevoEstatus), causa = TRIM(cCausa), fecha_atencion = TODAY, hora_atencion = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND solicitud = pNumSolicitud
					AND ejecutivo = pEjecutivo
					AND fecha_insert = dtFechaInsert;
					
					
				-- VALIDA QUE EL EJECUTIVO REALIZA LA CANCELACION O RECHAZO DE LA SOLICITUD
				ELIF pStatus = 'CN' OR pStatus = 'RT' OR pStatus = 'CM'  THEN
					-- ACTUALIZA LA BITACORA DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_bitacora_aumlincred
					SET status = pStatus, causa_status = pCausaStatus, fecha_status = TODAY, hora_status = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC'
					AND fecha_insert = dtFechaInsert;
					-- ACTUALIZA EL MAESTRO DE AUTORIZACIONES DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_autorizacion_aumlincred
					SET status = pStatus, causa_status = pCausaStatus, fecha_status = TODAY, justificacion = pJustificacion
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC';
					--AND fecha_insert = dtFechaInsert;
					--SE ACTUALIZA PROMOTOR , JUSTIFICACION EN LA HISTORICA, INGRESOMC, OTROS COMPONETES, NUEVO ESTATUS Y CAUSA.
					UPDATE "informix".sd_historica_cac_aumlincred 
					SET justificacion = TRIM(cNomEjecutivo)||": " ||TRIM(pJustificacion), ingreso_mc = pIngresoMC, otros_comp = pOtrosComp, estatus = TRIM(pNuevoEstatus), causa = TRIM(cCausa), fecha_atencion = TODAY, hora_atencion = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND solicitud = pNumSolicitud
					AND ejecutivo = pEjecutivo
					AND fecha_insert = dtFechaInsert;
					
				END IF
			-- VALIDA SI EL NIVEL DEL EJECUTIVO ES DEL MISMO NIVEL MAXIMO DEL RANGO DE AUTORIZACION, OSEA SI ES USUARIO FINAL
			ELIF iNivelEjecutivo = iNivelAutorizacion THEN
				-- VALIDA QUE LA SOLICITUD SE VA APERTURAR
				IF pStatus = 'AT' THEN
					SELECT sucursal,mensaje
					INTO cSucursalRRC,cMensajeResp
					FROM "informix".sd_bitacora_aumlincred
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC'
					AND fecha_insert = dtFechaInsert;
					
					UPDATE "informix".sd_bitacora_aumlincred
					SET status = 'AT', causa_status = '', fecha_status = TODAY, hora_status = CURRENT::DATETIME HOUR TO FRACTION(3),
						lincred_sugerida = pLincredSugerida
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC'
					AND fecha_insert = dtFechaInsert;
					
					-- ACTUALIZA EL MAESTRO DE AUTORIZACIONES DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_autorizacion_aumlincred
					SET status = 'AT', causa_status = '', fecha_status = TODAY, justificacion = pJustificacion
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC';
					--AND fecha_insert = dtFechaInsert;

					--SE ACTUALIZA PROMOTOR , JUSTIFICACION EN LA HISTORICA, INGRESOMC, OTROS COMPONETES, NUEVO ESTATUS Y CAUSA.
					UPDATE "informix".sd_historica_cac_aumlincred 
					SET justificacion =  TRIM(cNomEjecutivo) ||": " || TRIM(pJustificacion), ingreso_mc = pIngresoMC, otros_comp = pOtrosComp, estatus = TRIM(pNuevoEstatus), causa = TRIM(cCausa), fecha_atencion = TODAY, hora_atencion = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND solicitud = pNumSolicitud
					AND ejecutivo = pEjecutivo
					AND fecha_insert = dtFechaInsert;
					
					EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,pNumSolicitud,'1',cMensajeResp,cSucursalRRC,'sistema') 
					INTO cCodRetRRC, cMensajeRRC;
					IF cCodRetRRC::INTEGER <> 0 THEN
						LET cCodRet = '000002';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL SP DE: sp_registrarrespuestacte';
					END IF
				-- VALIDA QUE EL EJECUTIVO FINAL REALIZA LA CANCELACION O RECHAZO DE LA SOLICITUD
				ELIF pStatus = 'CN' OR pStatus = 'RT' OR pStatus = 'CM' THEN	
					-- ACTUALIZA LA BITACORA DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_bitacora_aumlincred
					SET status = pStatus, causa_status = pCausaStatus, fecha_status = TODAY, hora_status = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC'
					AND fecha_insert = dtFechaInsert;
					-- ACTUALIZA EL MAESTRO DE AUTORIZACIONES DE AUMENTO DE LINEA DE CREDITO
					UPDATE "informix".sd_autorizacion_aumlincred
					SET status = pStatus, causa_status = pCausaStatus, fecha_status = TODAY, justificacion = pJustificacion
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSolicitud
					AND status = 'AC';
					--AND fecha_insert = dtFechaInsert;
					--SE ACTUALIZA PROMOTOR , JUSTIFICACION EN LA HISTORICA, INGRESOMC, OTROS COMPONETES, NUEVO ESTATUS Y CAUSA.
					UPDATE "informix".sd_historica_cac_aumlincred 
					SET justificacion = TRIM(cNomEjecutivo)||": " ||TRIM(pJustificacion), ingreso_mc = pIngresoMC, otros_comp = pOtrosComp, estatus = TRIM(pNuevoEstatus), causa = TRIM(cCausa), fecha_atencion = TODAY, hora_atencion = CURRENT::DATETIME HOUR TO FRACTION(3)
					WHERE empresa = pEmpresa
					AND solicitud = pNumSolicitud
					AND ejecutivo = pEjecutivo
					AND fecha_insert = dtFechaInsert;

				END IF
			ELSE
				LET cCodRet = '000003';
				LET cMensajeRet = 'NIVEL DE EJECUTIVO NO PUEDE SER MAYOR A NIVEL DE RANGO DE AUTORIZACION';
			END IF
			-- ACTUALIZA EL SEMAFORO DEL AUMENTO DE LINEA DE CREDITO DEJANDO LIBRE LA SOLICITUD PARA EL EJECUTIVO QUE LA TRABAJO
			DELETE "informix".sd_sol_procesando_aumlincred
			WHERE num_credito = pNumSolicitud AND usuario = pEjecutivo;
		END IF
	
	RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento qoe permite  actualizar las revisiones a las que se somete la solicitud de aumento de linea de credito para ',
				'pasar al siguiente nivel hasta llegar a status final', 
'AUTOR: Mohamed Carreon ',
'FECHA: Noviembre 2011',
'MODIFICACION: Guadalupe Payan',
'MODIFICACION: Se modifica para eliminar las variables cPregunta y cUltimoEjecutivo ya que no son utilizadas en ninguna parte del codigo.',
'FECHA: Noviembre 2011',
'VERSION: 20111104.1607',
'MODIFICACION: Guadalupe Payan',
'MODIFICACION: Se modifica para obtener el nombre del ejecutivo de la si_ejecut y actualizar la justificacion de la sd_historica_cac_aumlincred concatenando,',
'			   el ejecutivo y la justificacion que le corresponde al promotor en turno.',
'FECHA: Octubre 2012',
'VERSION: 20121008.0935',
'BD: bdicred',
'MODIFICO: Mario Olivo',
'MODIFICACION: Se modifica el cCodRet a "000003" para el mensaje "NIVEL DE EJECUTIVO NO PUEDE SER MAYOR A NIVEL DE RANGO DE AUTORIZACION",',
'			   se elimina la validacion del parametro pEmpresa, se realiza cambio a reglas de informix.',
'FECHA: 16/05/2013',
'VERSION: 20130516.1855',
'BD: bdicred',
'MODIFICO: Juan Daniel Lazalde',
'MODIFICACION: Se agregan los parametros de entrada al sp: ingreso_mc, otros_comp, nuevo estatus , causa, fecha atención y hora atención y agregar en los update de la tabla sd_autorizacion_aumlincred ',
'FECHA: 28/01/2014',
'VERSION: 20140128.1433',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_rep_convenios_sif(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsr CHAR(8))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		      CHAR(80) AS Nombre_archivo; 
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE iNumArchivo		  INTEGER;
DEFINE cTipoArchivo	    CHAR(80);
DEFINE cConsulta3		    CHAR(300);
DEFINE cSql		 		      CHAR(3000);
DEFINE cRuta		        CHAR(80);
DEFINE cTabla		        CHAR(1);
DEFINE dtFecha		      DATE;
DEFINE cFechaIni        CHAR(10);
DEFINE cFechaFin        CHAR(10);
DEFINE cSucursal        CHAR(4);
DEFINE iNumctes_vencido INTEGER;
DEFINE cNumcte          CHAR(20);
DEFINE dFecha_Reg       DATE;
DEFINE iRegistros       INTEGER;
DEFINE dFecha_ini       DATE;
DEFINE dFecha_fin       DATE;
DEFINE iCantidad        INTEGER;
DEFINE vPlaza       CHAR(40);
DEFINE vCiudad      CHAR(60);
DEFINE vSucursal    CHAR(4);
DEFINE vOrigen      CHAR(8);
DEFINE vTipoCompac  CHAR(1);
DEFINE vPlazo       CHAR(2);
DEFINE vImporte     DECIMAL(14,2);
DEFINE vImpPagado   DECIMAL(14,2);
DEFINE vCumplido    CHAR(11);
DEFINE vFechaCompac DATE;
DEFINE vFechaIns    DATE;
DEFINE dFecha_ini_2     DATE;
DEFINE dFecha_fin_2     DATE;
DEFINE dFecha_temp      DATE;
DEFINE dFecha_temp2     DATE; 
DEFINE vNumcuenta       CHAR(20); 
DEFINE cPagoProgramado  CHAR(1);
DEFINE iNumSesion       INTEGER;
DEFINE cArmaTabla       char(500);
DEFINE cValor           char(1);
DEFINE vFechaMov        DATE;
DEFINE cSuc             CHAR(10);
DEFINE v_count_emp      CHAR(10);
DEFINE cImporte         CHAR(20);
DEFINE cImpPagado       CHAR(20);
DEFINE cFechaCompac     CHAR(20);
DEFINE cFechaIns        CHAR(20);
DEFINE cPagoProgramado_2 CHAR(45);
DEFINE cUsuario         CHAR(8);
DEFINE vNumCuenta_2     LIKE sd_convs_detalle.numcuenta;
DEFINE vFecha_venc      DATE;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			    = 0;
LET cNombreArchivo		  = "reporte_convenios_";
LET cTipoArchivo     	  = "";
LET cConsulta3			    = "";
LET cRuta				        = "";
LET cTabla				      = "N";
LET dtFecha				      = DATE(1);
LET cFechaIni           = ''; 
LET cFechaFin           = '';
LET cSucursal           = '';
LET iNumctes_vencido    = 0;
LET cNumcte             = '';
LET dFecha_Reg          = DATE(1);
LET iRegistros          = 0;
LET dFecha_ini          = DATE(1);
LET dFecha_fin          = DATE(1);
LET dFecha_temp         = DATE(1);
LET dFecha_temp2        = DATE(1);
LET iCantidad           = 0;

LET vPlaza              = '';
LET vCiudad             = '';
LET vSucursal           = '';
LET vOrigen             = '';
LET vTipoCompac         = '';
LET vPlazo              = '';
LET vImporte            = 0;
LET vImpPagado          = 0;
LET vCumplido           = '';
LET vFechaCompac        = DATE(1);
LET vFechaIns           = DATE(1);     
LET dFecha_ini_2        = DATE(1);
LET dFecha_fin_2        = DATE(1);
LET dFecha_temp         = DATE(1);
LET vNumcuenta          = '';
LET cPagoProgramado     = '';
LET iNumSesion          = 0;
LET cArmaTabla          = '';
LET cValor              = '';
LET cNumcte             = '';
LET vFechaMov           = DATE(1);
LET cSuc                = '';
LET v_count_emp         = '';
LET cImporte            = '';
LET cImpPagado          = '';
LET cFechaCompac        = '';
LET cFechaIns           = '';
LET cPagoProgramado_2   = '';
LET cUsuario            = '';
LET vFecha_venc         = date(1);

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	LET cMensajeRet = cErrorInfo;
      	
    	
      RETURN cCodRet, cMensajeRet,"";
  END EXCEPTION;

  --SET DEBUG FILE TO '/informix/macf/sp_rep_convenios_sif.trc';
  --TRACE ON;

  LET dFecha_ini = pFechaIni;
  LET dFecha_fin = pFechaFin;
  LET cUsuario   = pUsr;
  
  LET dFecha_temp = dFecha_ini + 1 UNITS MONTH;
  
  LET dFecha_ini_2 = mdy(month(dFecha_ini),1,year(dFecha_ini));  
  LET dFecha_fin_2 = mdy(month(dFecha_temp),1,year(dFecha_temp)) - 1 UNITS DAY;
  

	SELECT {+ INDEX (bdicobranza:cb_param_campania idx_cb_paramcampania_params1)} TRIM(valor_alfabetico) 
	  INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND  grupo_parametro = 'RUTAS'
	   AND num_parametro =1;

  IF NVL(pEmpresa,"") = "" OR  NVL(dFecha_ini,"") = "" OR  NVL(dFecha_fin,"") = "" THEN
  	LET cCodRet= "000001";
  	LET cMensajeRet = "Parametro no valido para realizar la consulta";
  	RETURN cCodRet, cMensajeRet,"";
  END IF;

		SELECT fecha_hoy  INTO dtFecha 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;
		 
		 
    SELECT {+ INDEX (bdicobranza:cb_param_archivos idx_cb_param_archivos_numarch)} tipo_archivo
		  INTO  cTipoArchivo		
		  FROM  bdicobranza:"informix".cb_param_archivos 
		 WHERE num_archivo = 1;

	LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);

  LET cFechaIni = year(dFecha_ini) || '/' || lpad(month(dFecha_ini),2,0) || '/' || lpad(day(dFecha_ini),2,0);
  LET cFechaFin = year(dFecha_fin) || '/' || lpad(month(dFecha_fin),2,0) || '/' || lpad(day(dFecha_fin),2,0);

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
   BEGIN;
      DELETE "informix".sd_convs_encabezados WHERE usuario = cUsuario;
   COMMIT;
   UPDATE statistics medium for table "informix".sd_convs_encabezados;
   
      
   FOREACH WITH HOLD
       --SELECT numcuenta, importe, fecha_compac
        --SELECT numcuenta, fecha_compac
        -- INTO vNumCuenta_2, vFechaCompac
         SELECT distinct fecha_compac into vFechaCompac     
         FROM "informix".sd_convs_detalle
         WHERE usuario = cUsuario
         
       BEGIN;
          DELETE "informix".sd_convs_detalle 
          --WHERE numcuenta = vNumCuenta_2 and fecha_compac = vFechaCompac and usuario = cUsuario;
          WHERE fecha_compac = vFechaCompac and usuario = cUsuario;
       COMMIT;
   
   
   END FOREACH;
   
        
			INSERT INTO "informix".sd_convs_encabezados (numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario) 
			VALUES("NumCtes_Con_Venc", "NumCtes_convenios", "plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento", "Pago_Programado",cUsuario);
      
      LET cConsulta3 = ' SELECT numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento, pago_programado ' ||
                       ' FROM "informix".sd_convs_encabezados ' || 
                       ' WHERE usuario = ' || "'" || cUsuario || "'";
                                           
    FOREACH WITH HOLD
        SELECT cch.numcuenta, sp.nombre plaza, sc.nombre ciudad, cch.sucursal, DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
         cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado, 
         DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), 
          cch.fecha_compac, cch.fecha_insert, cch.pago_programado
        INTO vNumcuenta, vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns, cPagoProgramado
        FROM bdicobranza:cb_compac_his cch LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
                                       LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) 
                                       LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
       WHERE cch.empresa= '001' 
         --AND cch.origen IN (1,2) 
         AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin  
       
        IF vOrigen = 'SUCURSAL' THEN
          IF vFechaCompac = vFechaIns THEN 
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
              VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, 'MISMO DIA', vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
          ELSE
            BEGIN; 
                INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
             VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
          END IF
        ELIF vOrigen = 'TIENDA' THEN
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
             VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
        ELSE
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
              VALUES(1,'CAT', 'CAT', 'CAT', vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns, cPagoProgramado,cUsuario);
            COMMIT; 
        END IF;    
    END FOREACH;
  

  FOREACH WITH HOLD
  
    SELECT plaza, ciudad, sucursal, origen, tipo_compac, plazo, COUNT(empresa), SUM(importe), SUM(importe_pagado), cumplido,
           to_char(fecha_compac, '%d/%m/%Y'), to_char(fecha_vencimiento, '%d/%m/%Y'), case when pago_programado = 'S' then 'Intento Convenio Pago Programado' else '' end  pago_programado  
      INTO  vPlaza, vCiudad, cSuc, vOrigen, vTipoCompac, vPlazo, v_count_emp, cImporte, cImpPagado, vCumplido, cFechaCompac, cFechaIns, cPagoProgramado_2
      FROM "informix".sd_convs_detalle
     WHERE fecha_vencimiento BETWEEN dFecha_ini AND dFecha_fin   
       AND usuario = cUsuario
     group by plaza, ciudad, sucursal, origen, tipo_compac, plazo, cumplido, fecha_compac, fecha_vencimiento, pago_programado
     
     BEGIN;
        INSERT INTO "informix".sd_convs_encabezados(numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
        VALUES(0,0,vPlaza, vCiudad, cSuc, vOrigen, vTipoCompac, vPlazo, v_count_emp, cImporte, cImpPagado, vCumplido, cFechaCompac, cFechaIns, cPagoProgramado_2,cUsuario);
     COMMIT; 
  END FOREACH;    
    

      FOREACH WITH HOLD        
     
          select trim(sucursal) into cSucursal
            from "informix".sd_convs_encabezados
            where sucursal >= '0000'
             and usuario = cUsuario
             group by 1
      
          SELECT sum(numctes_vencido) into iNumctes_vencido 
           from "informix".sd_vencidos_suc 
          where sucursal = cSucursal
            and fecha_reg BETWEEN dFecha_ini AND dFecha_fin 
          group by sucursal;

          select sum(cantidad) into iCantidad  
            from "informix".sd_convenios_sucursal
            where fecha between dFecha_ini AND dFecha_fin
             and sucursal = cSucursal  
            group by sucursal;
          
           BEGIN;
                UPDATE "informix".sd_convs_encabezados SET numctes_con_vencido = iNumctes_vencido, numctes_convenios = iCantidad WHERE sucursal = cSucursal and usuario = cUsuario;
           COMMIT;   
      
      END FOREACH;
   
			LET cSql = '';
			--LET cSql = 'echo "UNLOAD TO ' ||trim(cRuta)||trim(cNombreArchivo)||'.'||'unl'|| ' '||trim(cConsulta3)||'" > '|| trim(cRuta) ||'query1.sql';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1.sql';
			-- LET cSql = 'echo "UNLOAD TO ' ||trim(cRuta)||trim(cNombreArchivo)||'.'||cTipoArchivo|| ' '||trim(cConsulta3)||'" > '|| trim(cRuta) ||'query1.sql';  (probado que funciona) 
			SYSTEM trim(cSql);
			
			LET cSql = '';
			LET cSql = "dbaccess bdicred " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql);
   	
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			--LET cSQL = "rm " ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl';		
			--SYSTEM cSql; 		

		LET cNombreArchivo= trim(cNombreArchivo)||'.'||trim(cTipoArchivo);
    
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
    
    --begin; UPDATE "informix".sd_param SET valor = 'N' WHERE cod_param = 'RPC'; commit;
    --update statistics medium for table "informix".sd_param;
  
  
    --LET cMensajeRet = TRIM(cMensajeRet) || 'Regs borrados: ' || iCantidad;       --- PRUEBAS
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
END
END PROCEDURE
;