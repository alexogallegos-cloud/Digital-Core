CREATE PROCEDURE "informix".sp_tipo_servicio_etv2()
RETURNING CHAR(5),CHAR(30);

DEFINE SQL_ERR 			INTEGER;
DEFINE ISAM_ERR 		INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE cod_ret 			CHAR(5);
DEFINE tipo_servicio 	CHAR(30);

LET cod_ret = '00000';
LET tipo_servicio = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,tipo_servicio;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_tipo_servicio_etv2.out";
	--TRACE ON;

    FOREACH
        SELECT servicio
        INTO tipo_servicio
        FROM bdisuc:"informix".ss_tipo_servicio_etv
		ORDER BY servicio ASC
        

        RETURN cod_ret,tipo_servicio WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA: 26/03/2018',
'DESCRIPCION: Se clona spl sp_tipo_servicio_etv para agregar ordenaciÃ³n por servicio';

CREATE PROCEDURE "informix".sp_generasecciones_oemn(pUsuario CHAR(8), pIdFuncion CHAR(10), pSeccion SMALLINT, pAnio CHAR(4), pMes CHAR(2), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(35) AS nombre_archivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanDetError CHAR(1);
	DEFINE cDesCodRet CHAR(250);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE dDateFormat DATE;
	DEFINE cDia CHAR(2);
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE iPosAnio INTEGER;
	DEFINE iPosMes INTEGER;
	DEFINE iPosDia INTEGER;
	
	DEFINE dFechaInicio DATE;
	DEFINE dFechaFin DATE;
	DEFINE dFechaHoy DATE;
	DEFINE dFecha DATE;
	DEFINE cHora CHAR(8);
	DEFINE cNombreMes CHAR(10);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(35);
	DEFINE iTotalReg INTEGER;
	DEFINE iContCheque INTEGER;
	DEFINE iBloque INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCmd1 CHAR(10000);
	DEFINE cSql CHAR(12000);
	DEFINE cTablaHist CHAR(1);
	DEFINE iIdBitEjec INTEGER;
	
	DEFINE cInstitucion VARCHAR(6);
	DEFINE cFecha CHAR(10);
	DEFINE cTipooper VARCHAR(3);
	DEFINE cSucursal VARCHAR(20);
	DEFINE cClabe CHAR(1);	
	DEFINE cTranspval VARCHAR(6);
	DEFINE cDenominacion_1 CHAR(18);
	DEFINE cDenominacion_2 CHAR(18);
	DEFINE cDenominacion_3 CHAR(18);
	DEFINE cDenominacion_4 CHAR(18);
	DEFINE cDenominacion_5 CHAR(18);
	DEFINE cDenominacion_6 CHAR(18);
	DEFINE cDenominacion_7 CHAR(18);
	DEFINE cDenominacion_8 CHAR(18);
	DEFINE cDenominacion_9 CHAR(18);
	DEFINE cDenominacion_10 CHAR(18);
	DEFINE cDenominacion_11 CHAR(18);
	DEFINE cDenominacion_12 CHAR(18);
	DEFINE cDenominacion_13 CHAR(18);
	DEFINE cDenominacion_14 CHAR(18);
	DEFINE cDenominacion_15 CHAR(18);
	DEFINE cImporte_1 CHAR(18);
	DEFINE cImporte_2 CHAR(18);
	DEFINE cImporte_3 CHAR(18);
	DEFINE cImporte_4 CHAR(18);
	DEFINE cImporte_5 CHAR(18);
	DEFINE cImporte_6 CHAR(18);
	DEFINE cImporte_7 CHAR(18);
	DEFINE cImporte_8 CHAR(18);
	DEFINE cImporte_9 CHAR(18);
	DEFINE cImporte_10 CHAR(18);
	DEFINE cImporte_11 CHAR(18);
	DEFINE cImporte_12 CHAR(18);
	DEFINE cImporte_13 CHAR(18);
	DEFINE cImporte_14 CHAR(18);
	DEFINE cImporte_15 CHAR(18);
	DEFINE cNumoper INTEGER;
	
	DEFINE cTipo_ope VARCHAR(3);
	DEFINE cCajero VARCHAR(20);
	DEFINE cTipo_cta VARCHAR(6);
	DEFINE cNivel_cta VARCHAR(6);
	DEFINE cImporte VARCHAR(15);
	DEFINE cNum_ope VARCHAR(15);
	
	DEFINE cMediodist VARCHAR(20);
	DEFINE cTipodist VARCHAR(1);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';	
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cBanDetError = 'f';
	LET cDesCodRet = 'EJECUCIÓN EXITOSA DEL PROCEDIMIENTO';
	LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	LET dFechaHoraFin = '';
	LET dDateFormat = '';
	LET cDia = '';
	LET cMes = '';
	LET cAnio = '';
	LET iPosAnio = 0;
	LET iPosMes = 0;
	LET iPosDia = 0;
	
	LET dFechaInicio = '';
	LET dFechaFin = '';
	LET dFechaHoy = '';
	LET dFecha = '';
	LET cHora = '';
	LET cNombreMes = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iTotalReg = 0;
	LET iContCheque = 0;
	LET iBloque = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cCmd1 = '';
	LET cSql = '';
	LET cTablaHist = '';
	LET iIdBitEjec = 0;
	
	LET cInstitucion = '';
	LET cFecha = '';
	LET cTipooper = '';
	LET cSucursal = '';
	LET cClabe = '';	
	LET cTranspval = '';
	LET cDenominacion_1 = '';
	LET cDenominacion_2 = '';
	LET cDenominacion_3 = '';
	LET cDenominacion_4 = '';
	LET cDenominacion_5 = '';
	LET cDenominacion_6 = '';
	LET cDenominacion_7 = '';
	LET cDenominacion_8 = '';
	LET cDenominacion_9 = '';
	LET cDenominacion_10 = '';
	LET cDenominacion_11 = '';
	LET cDenominacion_12 = '';
	LET cDenominacion_13 = '';
	LET cDenominacion_14 = '';
	LET cDenominacion_15 = '';
	LET cImporte_1 = '';
	LET cImporte_2 = '';
	LET cImporte_3 = '';
	LET cImporte_4 = '';
	LET cImporte_5 = '';
	LET cImporte_6 = '';
	LET cImporte_7 = '';
	LET cImporte_8 = '';
	LET cImporte_9 = '';
	LET cImporte_10 = '';
	LET cImporte_11 = '';
	LET cImporte_12 = '';
	LET cImporte_13 = '';
	LET cImporte_14 = '';
	LET cImporte_15 = '';
	LET cNumoper = '';
	
	LET cTipo_ope = '';
	LET cCajero = '';
	LET cTipo_cta = '';
	LET cNivel_cta = '';
	LET cImporte = '';
	LET cNum_ope = '';
	
	LET cMediodist = '';
	LET cTipodist = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
			
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
				LET dFecha = DATE(CURRENT);
				LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
				LET cDesCodRet = 'OCURRIÓ UN ERROR NO CONTROLADO EN LA EJECUCIÓN DEL SPL: sp_generasecciones_oemn. CÓDIGO DE ERROR '|| iSqlErr||' '||cDescErr;
				
				-- BITACORÉO
				INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
				VALUES(dFecha,cHora,pUsuario,cDesCodRet,null,TRIM(cNombreArchivo));
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					--LET cCodRet = '00282';
					--RETURN cCodRet, cNombreArchivo;
				END IF;
				
				UPDATE bdisuc:"informix".sw_ope_statusrepoemn
				SET status = 'E', error_spl = iSqlErr, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
				WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_generasecciones_oemn'
				AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
				
				RETURN cCodRet, cNombreArchivo;
				
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_generasecciones_oemn.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSeccion = '' OR pAnio = '' OR pMes = '' OR pRutaDescarga = '' THEN
		
			LET cCodRet = '00003';
			
			LET dFecha = DATE(CURRENT);
			LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
			LET cDesCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA. CÓDIGO DE ERROR'|| cCodRet;
			
			-- BITACORÉO
			INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
			VALUES(dFecha,cHora,pUsuario,cDesCodRet,null,TRIM(cNombreArchivo));
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				--LET cCodRet = '00282';
				--RETURN cCodRet, cNombreArchivo;
			END IF;
			
			UPDATE bdisuc:"informix".sw_ope_statusrepoemn
			SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_generasecciones_oemn'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			RETURN cCodRet, cNombreArchivo;
			
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			LET dFecha = DATE(CURRENT);
			LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
			LET cDesCodRet = 'EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR LA CONSULTA. CÓDIGO DE ERROR'|| cCodRet;
			
			-- BITACORÉO
			INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
			VALUES(dFecha,cHora,pUsuario,cDesCodRet,null,TRIM(cNombreArchivo));
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				--LET cCodRet = '00282';
				--RETURN cCodRet, cNombreArchivo;
			END IF;
			
			UPDATE bdisuc:"informix".sw_ope_statusrepoemn
			SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_generasecciones_oemn'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			RETURN cCodRet, cNombreArchivo;
			
		END IF;
		
		-- ASIGNACIONES		
		IF pMes = '01' THEN
			LET cNombreMes = 'Enero';
		ELIF pMes = '02' THEN
			LET cNombreMes = 'Febrero';
		ELIF pMes = '03' THEN
			LET cNombreMes = 'Marzo';
		ELIF pMes = '04' THEN
			LET cNombreMes = 'Abril';
		ELIF pMes = '05' THEN
			LET cNombreMes = 'Mayo';
		ELIF pMes = '06' THEN
			LET cNombreMes = 'Junio';
		ELIF pMes = '07' THEN
			LET cNombreMes = 'Julio';
		ELIF pMes = '08' THEN
			LET cNombreMes = 'Agosto';
		ELIF pMes = '09' THEN
			LET cNombreMes = 'Septiembre';
		ELIF pMes = '10' THEN
			LET cNombreMes = 'Octubre';
		ELIF pMes = '11' THEN
			LET cNombreMes = 'Noviembre';
		ELIF pMes = '12' THEN
			LET cNombreMes = 'Diciembre';
		END IF;
		 
		LET cNombreArchivo = 'Seccion'||pSeccion||TRIM(cNombreMes)||RIGHT(TRIM(pAnio),2)||'.xls';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdisuc:"informix".sw_ope_statusrepoemn WHERE usuario_insert = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdisuc:"informix".sw_ope_statusrepoemn(nombre_archivo,status,procedimiento,error_spl,descripcion_error_spl,usuario_insert,fecha_hora_inicio,fecha_hora_fin)
		VALUES(TRIM(cNombreArchivo),'I','sp_generasecciones_oemn','','',pUsuario,dFechaHoraInicio,null);
		
		LET cDia = DAY(DATE(CURRENT));
		
		IF cDia::INTEGER <= 12 THEN
		
			LET dDateFormat = DATE(CURRENT) + 10;
			LET cDia = LPAD(DAY(dDateFormat),2,'0');
			LET cMes = LPAD(MONTH(dDateFormat),2,'0');
			LET cAnio = YEAR(dDateFormat);
			
			LET iPosAnio = CHARINDEX(cAnio, dDateFormat);
			LET iPosMes = CHARINDEX(cMes, dDateFormat);
			LET iPosDia = CHARINDEX(cDia, dDateFormat);
			
		ELSE
		
			LET dDateFormat = DATE(CURRENT);
			LET cDia = DAY(dDateFormat);
			LET cMes = LPAD(MONTH(dDateFormat),2,'0');
			LET cAnio = YEAR(dDateFormat);
		
			LET iPosAnio = CHARINDEX(cAnio, dDateFormat);
			LET iPosMes = CHARINDEX(cMes, dDateFormat);
			LET iPosDia = CHARINDEX(cDia, dDateFormat);
			
		END IF;
		
		IF iPosAnio = 0 THEN
		
			LET dFechaInicio = pAnio||'/'||pMes||'/'||'01';
			LET dFechaFin = YEAR(dFechaInicio)||'/'||MONTH(dFechaInicio)||'/'||DAY(LAST_DAY(dFechaInicio));
			--LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
			LET dFechaHoy = DATE(CURRENT);
			LET dFechaHoy = YEAR(dFechaHoy)||'/'||MONTH(dFechaHoy)||'/'||'01';
			
		ELIF iPosAnio = 7 THEN
		
			LET dFechaInicio = pMes||'/'||'01'||'/'||pAnio;
			LET dFechaFin = MONTH(dFechaInicio)||'/'||DAY(LAST_DAY(dFechaInicio))||'/'||YEAR(dFechaInicio);
			--LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
			LET dFechaHoy = DATE(CURRENT);
			LET dFechaHoy = MONTH(dFechaHoy)||'/'||'01'||'/'||YEAR(dFechaHoy);
		
		END IF;
		
		IF dFechaInicio < dFechaHoy - 2 UNITS MONTH THEN
			LET cTablaHist = 't';
		ELSE
			LET cTablaHist = 'f';
		END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
						
		-- S1 Operaciones realizadas con Instituciones de Crédito
		IF pSeccion = 1 THEN
			
			DELETE FROM bdisuc:"informix".sw_ope_denominaciones_tmp WHERE usuario_insert = pUsuario;
			
			FOREACH
			
				-------------- COMPRAS Y VENTAS DE EFECTIVO --------------
				SELECT '040137' institucion, dFechaFin AS fecha, '124' tipooper, sucursal, '2' clabe, '028014' transpval,
				TRIM(denominacion_1) denominacion_1,
				TRIM(denominacion_2) denominacion_2,
				TRIM(denominacion_3) denominacion_3,
				TRIM(denominacion_4) denominacion_4,
				TRIM(denominacion_5) denominacion_5,
				TRIM(denominacion_6) denominacion_6,
				TRIM(denominacion_7) denominacion_7,
				TRIM(denominacion_8) denominacion_8,
				TRIM(denominacion_9) denominacion_9,
				TRIM(denominacion_10) denominacion_10,
				TRIM(denominacion_11) denominacion_11,
				TRIM(denominacion_12) denominacion_12,
				TRIM(denominacion_13) denominacion_13,
				TRIM(denominacion_14) denominacion_14,
				TRIM(denominacion_15) denominacion_15,
				ROUND(SUM(NVL(cantidad_1, 0.0) * NVL(denominacion_1, 0))) importe_1,
				ROUND(SUM(NVL(cantidad_2, 0.0) * NVL(denominacion_2, 0))) importe_2,
				ROUND(SUM(NVL(cantidad_3, 0.0) * NVL(denominacion_3, 0))) importe_3,
				ROUND(SUM(NVL(cantidad_4, 0.0) * NVL(denominacion_4, 0))) importe_4,
				ROUND(SUM(NVL(cantidad_5, 0.0) * NVL(denominacion_5, 0))) importe_5,
				ROUND(SUM(NVL(cantidad_6, 0.0) * NVL(denominacion_6, 0))) importe_6,
				ROUND(SUM(NVL(cantidad_7, 0.0) * NVL(denominacion_7, 0))) importe_7,
				ROUND(SUM(NVL(cantidad_8, 0.0) * NVL(denominacion_8, 0))) importe_8,
				ROUND(SUM(NVL(cantidad_9, 0.0) * NVL(denominacion_9, 0))) importe_9,
				ROUND(SUM(NVL(cantidad_10, 0.0) * NVL(denominacion_10, 0))) importe_10,
				ROUND(SUM(NVL(cantidad_11, 0.0) * NVL(denominacion_11, 0))) importe_11,
				ROUND(SUM(NVL(cantidad_12, 0.0) * NVL(denominacion_12, 0))) importe_12,
				ROUND(SUM(NVL(cantidad_13, 0.0) * NVL(denominacion_13, 0))) importe_13,
				ROUND(SUM(NVL(cantidad_14, 0.0) * NVL(denominacion_14, 0))) importe_14,
				ROUND(SUM(NVL(cantidad_15, 0.0) * NVL(denominacion_15, 0))) importe_15,
				COUNT(*) numoper
				INTO cInstitucion, cFecha, cTipooper, cSucursal, cClabe, cTranspval, 
				cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, 
				cDenominacion_6, cDenominacion_7, cDenominacion_8, cDenominacion_9, cDenominacion_10, 
				cDenominacion_11, cDenominacion_12, cDenominacion_13, cDenominacion_14, cDenominacion_15, 
				cImporte_1, cImporte_2, cImporte_3, cImporte_4, cImporte_5, 
				cImporte_6, cImporte_7, cImporte_8, cImporte_9, cImporte_10, 
				cImporte_11, cImporte_12, cImporte_13, cImporte_14, cImporte_15, cNumoper 
				FROM bdisuc:"informix".ss_operaciones
				WHERE fecha_operacion BETWEEN dFechaInicio AND dFechaFin
				AND cod_trans = '0003' --Compras en efectivo
				AND reversado <> '8'
				GROUP BY sucursal, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, 
				denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, 
				denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15
				UNION ALL
				SELECT '040137' institucion, dFechaFin AS fecha, '124' tipooper, sucursal, '2' clabe, '028014' transpval,
				TRIM(denominacion_1) denominacion_1,
				TRIM(denominacion_2) denominacion_2,
				TRIM(denominacion_3) denominacion_3,
				TRIM(denominacion_4) denominacion_4,
				TRIM(denominacion_5) denominacion_5,
				TRIM(denominacion_6) denominacion_6,
				TRIM(denominacion_7) denominacion_7,
				TRIM(denominacion_8) denominacion_8,
				TRIM(denominacion_9) denominacion_9,
				TRIM(denominacion_10) denominacion_10,
				TRIM(denominacion_11) denominacion_11,
				TRIM(denominacion_12) denominacion_12,
				TRIM(denominacion_13) denominacion_13,
				TRIM(denominacion_14) denominacion_14,
				TRIM(denominacion_15) denominacion_15,
				ROUND(SUM(NVL(cantidad_1, 0.0) * NVL(denominacion_1, 0))) importe_1,
				ROUND(SUM(NVL(cantidad_2, 0.0) * NVL(denominacion_2, 0))) importe_2,
				ROUND(SUM(NVL(cantidad_3, 0.0) * NVL(denominacion_3, 0))) importe_3,
				ROUND(SUM(NVL(cantidad_4, 0.0) * NVL(denominacion_4, 0))) importe_4,
				ROUND(SUM(NVL(cantidad_5, 0.0) * NVL(denominacion_5, 0))) importe_5,
				ROUND(SUM(NVL(cantidad_6, 0.0) * NVL(denominacion_6, 0))) importe_6,
				ROUND(SUM(NVL(cantidad_7, 0.0) * NVL(denominacion_7, 0))) importe_7,
				ROUND(SUM(NVL(cantidad_8, 0.0) * NVL(denominacion_8, 0))) importe_8,
				ROUND(SUM(NVL(cantidad_9, 0.0) * NVL(denominacion_9, 0))) importe_9,
				ROUND(SUM(NVL(cantidad_10, 0.0) * NVL(denominacion_10, 0))) importe_10,
				ROUND(SUM(NVL(cantidad_11, 0.0) * NVL(denominacion_11, 0))) importe_11,
				ROUND(SUM(NVL(cantidad_12, 0.0) * NVL(denominacion_12, 0))) importe_12,
				ROUND(SUM(NVL(cantidad_13, 0.0) * NVL(denominacion_13, 0))) importe_13,
				ROUND(SUM(NVL(cantidad_14, 0.0) * NVL(denominacion_14, 0))) importe_14,
				ROUND(SUM(NVL(cantidad_15, 0.0) * NVL(denominacion_15, 0))) importe_15,
				COUNT(*) numoper
				FROM bdisuc:"informix".ss_operaciones
				WHERE fecha_operacion BETWEEN dFechaInicio AND dFechaFin
				AND cod_trans = '0004' --Ventas de efectivo
				AND reversado <> '8'
				GROUP BY sucursal, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, 
				denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, 
				denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15
				
				IF NVL(cImporte_1,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_1,cImporte_1,cNumoper);
				END IF;

				IF NVL(cImporte_2,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_2,cImporte_2,cNumoper);
				END IF;

				IF NVL(cImporte_3,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_3,cImporte_3,cNumoper);
				END IF;
				
				IF NVL(cImporte_4,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_4,cImporte_4,cNumoper);
				END IF;
				
				IF NVL(cImporte_5,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_5,cImporte_5,cNumoper);
				END IF;

				IF NVL(cImporte_6,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_6,cImporte_6,cNumoper);
				END IF;
				
				IF NVL(cImporte_7,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_7,cImporte_7,cNumoper);
				END IF;

				IF NVL(cImporte_8,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_8,cImporte_8,cNumoper);
				END IF;

				IF NVL(cImporte_9,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_9,cImporte_9,cNumoper);
				END IF;
				
				IF NVL(cImporte_10,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_10,cImporte_10,cNumoper);
				END IF;

				IF NVL(cImporte_11,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_11,cImporte_11,cNumoper);
				END IF;

				IF NVL(cImporte_12,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_12,cImporte_12,cNumoper);
				END IF;
				
				IF NVL(cImporte_13,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_13,cImporte_13,cNumoper);
				END IF;
				
				IF NVL(cImporte_14,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_14,cImporte_14,cNumoper);
				END IF;

				IF NVL(cImporte_15,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_denominaciones_tmp(usuario_insert,institucion,fecha,tipo_ope,medio_dis,tipo_dis,transpval,denominacion,importe,num_ope)
					VALUES(pUsuario,cInstitucion,cFecha,cTipooper,cSucursal,cClabe,cTranspval,cDenominacion_15,cImporte_15,cNumoper);
				END IF;
				
				LET iTotalReg = iTotalReg + 1;
				
			END FOREACH;
			
			IF NVL(iTotalReg,0) = 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ' ',' ',' ',' ',0,' ',' ',' ',' '";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL";
				LET cCmd1 =""||TRIM(cCmd1)||" SELECT institucion,fecha,tipo_ope,medio_dis,tipo_dis::INTEGER,transpval,denominacion,importe,num_ope";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_denominaciones_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			ELIF NVL(iTotalReg,0) > 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ''''||institucion,fecha,tipo_ope,''''||medio_dis,tipo_dis,''''||transpval,denominacion,importe,num_ope";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_denominaciones_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			END IF;
			
		-- S2 Operaciones con Clientes o Usuarios realizadas en Sucursal
		ELIF pSeccion = 2 THEN
		
			LET cCmd1 ="";
			-------------- CAJA GENERAL --------------
			/*
			LET cCmd1 ="SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '24' tipooper, ''''||sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '1' tipocli,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto,0))) importe, COUNT(*) numoper";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".ss_operaciones";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_operacion BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cod_trans = '0001'"; --Dotación sucursal
			LET cCmd1 =""||TRIM(cCmd1)||" AND reversado <> '8'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '124' tipooper, ''''||sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '1' tipocli,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto,0))) importe, COUNT(*) numoper";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".ss_operaciones";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_operacion BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cod_trans = '0002'"; --Concentración sucursal
			LET cCmd1 =""||TRIM(cCmd1)||" AND reversado <> '8'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			*/
			-------------- CHEQUES --------------
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '2' tipooper, ''''||sucursal sucursal, 'NA' clabe, '8' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc IN ('0202','0325')"; --Depósitos efectivo
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto NOT IN ('9900','9901','1900','2700','8000')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '2' tipooper, ''''||sucursal sucursal, 'NA' clabe, '7' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc IN ('0202','0325')"; --Depósitos efectivo
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto IN ('1900','2700')"; --Sólo estos productos debido a que el tipo de cuenta cambia a 7
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '2' tipooper, ''''||sucursal sucursal, 'NA' clabe, '8' tipocta, '2' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '0202'"; --depositos efectivo TRANSFER
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto NOT IN ('8000')"; ----solo PRODUCTO TRANSFER
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '105' tipooper, ''''||sucursal sucursal, 'NA' clabe, '8' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '3333'"; ---COBRO DE CHEQUES
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto NOT IN ('9900','9901','1900','2700')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '105' tipooper, ''''||sucursal sucursal, 'NA' clabe, '7' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '3333'"; --Cobro de cheques
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto IN ('1900','2700')"; --Sólo estos productos por que el tipo de cuenta cambia a 7
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '102' tipooper, ''''||sucursal sucursal, 'NA' clabe, '8' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '0223'"; --Retiro de efectivo
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto NOT IN ('9900','9901','1900','2700','8000')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '102' tipooper, ''''||sucursal sucursal, 'NA' clabe, '7' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '0223'"; --Retiro de efectivo
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto IN ('1900','2700')"; --Sólo estos productos por que el tipode cuenta cambia
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '102' tipooper, ''''||sucursal sucursal, 'NA' clabe, '8' tipocta, '2' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc IN ('0223','8020')"; ---RETIRO DE EFECTICO Y RETIRO CON FOLIO TRANSFER
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto IN ('8000')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '102' tipooper, ''''||sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '2' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cuenta <> ''";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '9002'"; ---RETIRO DE EFECTICO POR CODIGO TRANSFER
			LET cCmd1 =""||TRIM(cCmd1)||" AND producto IN ('8000')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			-------------- CREDITO --------------
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '111' tipooper, ''''||sucursal sucursal, 'NA' clabe, '6' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto,0))) importe, COUNT(*) numoper";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicred:""informix"".sd_movhis a, bdicred:""informix"".sd_transfun b";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.fecha_mov BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.reversado = 'N'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.empresa = b.empresa";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.codigo_fun = b.codigo_fun";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.codigo_ref = b.codigo_ref";
			LET cCmd1 =""||TRIM(cCmd1)||" AND b.transacc = '6900'"; --Disposición de efectivo desde ventanilla
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '11' tipooper, ''''||sucursal sucursal, 'NA' clabe, '6' tipocta, '' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto,0))) importe, COUNT(*) numoper";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicred:""informix"".sd_movhis";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fecha_mov BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND reversado = 'N'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND codigo_ref = '1'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND codigo_fun = '033'"; --Pago de créditos en ventanilla 600
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '11' tipooper, ''''||sucursal sucursal, 'NA' clabe, '6' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto,0))) importe, COUNT(*) numoper";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicred:""informix"".sd_movhiscrd a, bdicred:""informix"".sd_transfun b";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.fecha_mov BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.reversado = 'N'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.empresa = b.empresa";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.codigo_fun = b.codigo_fun";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.codigo_ref = b.codigo_ref";
			LET cCmd1 =""||TRIM(cCmd1)||" AND b.transacc = '7822'"; --Pago de capital vigente 611
			LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			-------------- PAGO DE SERVICIOS --------------
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '12' tipooper, ''''||a.sucursal sucursal, 'NA' clabe, '8' tipocta, '4' nivelcta, '1' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old a, bdicheq:""informix"".sc_maechq b";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis a, bdicheq:""informix"".sc_maechq b";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.cuenta = b.cuenta";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc IN ('1117','1101','1115','1116','1107','1130','1108','1127','1129','1102','1303','1193')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '18' tipooper, ''''||a.sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '2' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old a, bdicheq:""informix"".sc_maechq b";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis a, bdicheq:""informix"".sc_maechq b";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.cuenta = b.cuenta";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '1104'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '119' tipooper, ''''||a.sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '2' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old a, bdicheq:""informix"".sc_maechq b";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis a, bdicheq:""informix"".sc_maechq b";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.cuenta = b.cuenta";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc = '1191'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT '''040137' institucion, '"||dFechaFin||"' AS fecha, '118' tipooper, ''''||a.sucursal sucursal, 'NA' clabe, '0' tipocta, '0' nivelcta, '2' tipocte,";
			LET cCmd1 =""||TRIM(cCmd1)||" ROUND(SUM(NVL(monto_tot,0))) importe, COUNT(*) numoper";
			
			IF cTablaHist = 't' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis_old a, bdicheq:""informix"".sc_maechq b";	
			ELIF cTablaHist = 'f' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sc_movhis a, bdicheq:""informix"".sc_maechq b";
			END IF;
			
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE a.empresa = '001'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.cuenta = b.cuenta";
			LET cCmd1 =""||TRIM(cCmd1)||" AND fech_alt BETWEEN '"||dFechaInicio||"' AND '"||dFechaFin||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND transacc IN ('1191')";
			LET cCmd1 =""||TRIM(cCmd1)||" AND cancelad <> 'S'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND a.sucursal <> '5001'";
			LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
		
		-- S3 Operaciones Realizadas en Cajeros Automáticos
		ELIF pSeccion = 3 THEN
			
			DROP TABLE IF EXISTS misenmis; 
			DROP TABLE IF EXISTS reversos;
			DROP TABLE IF EXISTS reversostot;
			DROP TABLE IF EXISTS mismisfin;
			DROP TABLE IF EXISTS misenmistot;
			DROP TABLE IF EXISTS misenmismestot;
			DROP TABLE IF EXISTS caja3;
			
			DELETE FROM bdisuc:"informix".sw_ope_cajerosaut_tmp WHERE usuario_insert = pUsuario;
			
			SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX(td_txns_atms_exitosas idx_td_txns_atrms_exitosas_01)} idterminal AS numcajero,
			CASE WHEN tipotran='MM' AND marca='V' AND creditodebito='C' THEN 'VCR'
			WHEN tipotran ='MM' AND marca='V' AND creditodebito='D' THEN 'VDE'
			WHEN tipotran='MM' AND marca='M' AND creditodebito='C' THEN 'MCR'
			WHEN tipotran='MM' AND marca='M' AND creditodebito='D' THEN 'MDE'
			WHEN tipotran='SM' THEN 'BNI' ELSE 'S/M' END AS compania,
			ROUND(SUM(monto)) monto, COUNT(*) numoper
			FROM bditarjeta:"informix".td_txns_atms_exitosas
			WHERE ((SUBSTR(numtarjetamovi,1,6) IN (SELECT BIN FROM intercard:"informix".bines WHERE creditodebito IN('D','C')))
			OR (SUBSTR(numtarjetastat06,1,6) IN (SELECT BIN FROM intercard:"informix".bines WHERE creditodebito IN('D','C'))))
			AND DATE(fechaproceso) BETWEEN dFechaInicio AND dFechaFin
			AND codtran = '01'
			AND codreversa = '0'
			AND tipotran <> 'MS'
			GROUP BY numcajero,compania
			INTO TEMP misenmis WITH NO LOG;

			SET ISOLATION TO DIRTY READ;
			SELECT idterminal AS numcajero,
			CASE WHEN tipotran='MM' AND marca='V' AND creditodebito='C' THEN 'VCR'
			WHEN tipotran='MM' AND marca='V' AND creditodebito='D' THEN 'VDE'
			WHEN tipotran='MM' AND marca='M' AND creditodebito='C' THEN 'MCR'
			WHEN tipotran='MM' AND marca='M' AND creditodebito='D' THEN 'MDE'
			WHEN tipotran='SM' THEN 'BNI' ELSE 'S/M'END AS compania,
			ROUND(SUM(monto)) monto, codreversa
			FROM bditarjeta:"informix".td_txns_atms_exitosas
			WHERE ((SUBSTR(numtarjetamovi,1,6) IN (SELECT BIN FROM intercard:"informix".bines WHERE creditodebito IN('D','C')))
			OR (SUBSTR(numtarjetastat06,1,6) IN (SELECT BIN FROM intercard:"informix".bines WHERE creditodebito IN('D','C'))))
			AND DATE(fechaproceso) BETWEEN dFechaInicio AND dFechaFin
			AND codtran = '01'
			AND codreversa <> '0'
			AND tipotran <> 'MS'
			GROUP BY numcajero,compania,codreversa
			INTO TEMP reversos WITH NO LOG;

			SELECT numcajero,compania,SUM(monto) monto,SUM(CAST(codreversa AS INT)) numoper
			FROM reversos
			GROUP BY numcajero,compania
			INTO TEMP reversostot WITH NO LOG;

			SELECT a.numcajero, a.compania, a.monto-b.monto monto, a.numoper-b.numoper numoper
			FROM misenmis a, reversostot b
			WHERE a.numcajero = b.numcajero
			AND a.compania = b.compania
			INTO TEMP mismisfin WITH NO LOG;

			SELECT '040137' institucion, dFechaFin AS fecha, 
			(CASE WHEN compania = 'VCR' THEN '111' WHEN compania <> 'VCR' THEN '104' ELSE '0' END) tpooper, numcajero, 
			SUM(monto) monto, SUM(numoper) numoper
			FROM misenmis
			GROUP BY numcajero,tpooper
			INTO TEMP misenmistot WITH NO LOG;

			SET ISOLATION TO DIRTY READ;
			SELECT institucion, fecha, tpooper, numcajero,
			(CASE WHEN tpooper = '111' THEN '6' WHEN tpooper <> '111' THEN '8' ELSE '0' END) tpocta, '4' nvlcta,
			NVL(ROUND(monto),0) AS importe, numoper
			FROM misenmistot
			INTO TEMP misenmismestot WITH NO LOG;

			SELECT '040137' institucion, dFechaFin AS fecha, '24' tipooper,
			sucursal cajero, '0' tipocta, '0' nivelcta, SUM(monto) importe ,
			count(*) numoper
			FROM bdisuc:"informix".ss_operaciones
			WHERE fecha_operacion BETWEEN dFechaInicio AND dFechaFin
			AND cod_trans = '0036' --Dotación efectivo y sucursal
			AND reversado <> '8'
			GROUP BY cajero
			UNION ALL
			SELECT '040137' institucion, dFechaFin AS fecha, '124' tipooper,
			sucursal cajero, '0' tipocta, '0' nivelcta, SUM(monto) importe,
			COUNT(*) numoper
			FROM bdisuc:"informix".ss_operaciones
			WHERE fecha_operacion BETWEEN dFechaInicio AND dFechaFin
			AND cod_trans = '0041' --Concentración de efectivo
			AND reversado <> '8'
			GROUP BY cajero
			INTO TEMP caja3 WITH NO LOG;

			SET ISOLATION TO DIRTY READ;
			
			LET iTotalReg = 0;
			
			FOREACH
			
				SELECT institucion, fecha, tipooper, id, tipocta, tipocta, NVL(ROUND(importe),0) importe, numoper
				INTO cInstitucion,cFecha,cTipo_ope,cCajero,cTipo_cta,cNivel_cta,cImporte,cNum_ope
				FROM caja3 a, bdisuc:"informix".ss_relacionccid b
				WHERE cajero = cc
				UNION ALL
				SELECT * FROM misenmismestot
				
				LET iTotalReg = iTotalReg + 1;
				INSERT INTO bdisuc:"informix".sw_ope_cajerosaut_tmp (usuario_insert,institucion,fecha,tipo_ope,cajero,tipo_cta,nivel_cta,importe,num_ope)
				VALUES (pUsuario,cInstitucion,cFecha,cTipo_ope,cCajero,cTipo_cta,cNivel_cta,cImporte,cNum_ope);
			
			END FOREACH;
			
			LET cCmd1 ="";
			LET cCmd1 ="SELECT ''''||institucion,fecha,tipo_ope,''''||cajero,tipo_cta,nivel_cta,importe,num_ope";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_cajerosaut_tmp";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
		-- S4 Saldo en Bóveda
		ELIF pSeccion = 4 THEN
			
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_ope_saldoboveda_tmp') THEN
				DROP TABLE bdisuc:"informix".sw_ope_saldoboveda_tmp;
			END IF;

			CREATE TABLE bdisuc:"informix".sw_ope_saldoboveda_tmp(
				id SERIAL NOT NULL,
				usuario_insert CHAR(8),
				institucion VARCHAR(6),
				fecha CHAR(10),
				tipo_ope VARCHAR(3),
				medio_dis VARCHAR(20),
				tipo_dis CHAR(1),
				clabe VARCHAR(18),
				tipo_cte VARCHAR(2),
				importe VARCHAR(15),
				num_ope VARCHAR(15),
				PRIMARY KEY (id)
			);

			SELECT COUNT(*) INTO iTotalReg FROM sw_ope_saldoboveda_tmp;
			
			IF NVL(iTotalReg,0) = 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ' ',' ',0,' ',0,' ',0,0,0";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL";
				LET cCmd1 =""||TRIM(cCmd1)||" SELECT institucion,fecha,tipo_ope::INTEGER,medio_dis,tipo_dis::INTEGER,clabe,tipo_cte::INTEGER,importe::INTEGER,num_ope::INTEGER";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_saldoboveda_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			ELIF NVL(iTotalReg,0) > 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT institucion,fecha,tipo_ope,medio_dis,tipo_dis,clabe,tipo_cte,importe,num_ope";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_saldoboveda_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			END IF;
			
		-- S5 Operaciones con Clientes o Usuarios realizadas directamente en Bóveda
		ELIF pSeccion = 5 THEN
			
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_ope_operacionesboveda_tmp') THEN
				DROP TABLE bdisuc:"informix".sw_ope_operacionesboveda_tmp;
			END IF;

			CREATE TABLE bdisuc:"informix".sw_ope_operacionesboveda_tmp(
				id SERIAL NOT NULL,
				usuario_insert CHAR(8),
				institucion VARCHAR(6),
				fecha CHAR(10),
				contraparte VARCHAR(6),
				tipo_ope VARCHAR(3),
				pais VARCHAR(2),
				medio_dis VARCHAR(20),
				clabe VARCHAR(18),
				tipo_dis CHAR(1),
				denominaciones CHAR(5),
				emp_gestora CHAR(6),
				transp_valores CHAR(6),
				importe CHAR(15),
				num_ope CHAR(6),
				PRIMARY KEY (id)
			);

			SELECT COUNT(*) INTO iTotalReg FROM sw_ope_operacionesboveda_tmp;
			
			IF NVL(iTotalReg,0) = 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ' ',' ',' ',0,' ',' ',' ',0,' ',' ',' ',0,0";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL";
				LET cCmd1 =""||TRIM(cCmd1)||" SELECT institucion,fecha,contraparte,tipo_ope::INTEGER,pais,medio_dis,clabe,tipo_dis::INTEGER,denominaciones,emp_gestora,transp_valores,importe::INTEGER,num_ope::INTEGER";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_operacionesboveda_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			ELIF NVL(iTotalReg,0) > 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT institucion,fecha,contraparte,tipo_ope,pais,medio_dis,clabe,tipo_dis,denominaciones,emp_gestora,transp_valores,importe,num_ope";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_operacionesboveda_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
			
			END IF;
			
		-- S6 Operaciones de Exportación y de Importación de Pesos
		ELIF pSeccion = 6 THEN
			
			DELETE FROM bdisuc:"informix".sw_ope_expimppesos_tmp WHERE usuario_insert = pUsuario;
			
			FOREACH
			
				-------------- SALDO FINAL EN SUCURSALES --------------
				SELECT '040137' institucion, fecha, sucursal AS mediodist, 1 AS tipodist, 
				TRIM(denominacion_1) denominacion_1,
				TRIM(denominacion_2) denominacion_2,
				TRIM(denominacion_3) denominacion_3,
				TRIM(denominacion_4) denominacion_4,
				TRIM(denominacion_5) denominacion_5,
				TRIM(denominacion_6) denominacion_6,
				TRIM(denominacion_7) denominacion_7,
				TRIM(denominacion_8) denominacion_8,
				TRIM(denominacion_9) denominacion_9,
				TRIM(denominacion_10) denominacion_10,
				TRIM(denominacion_11) denominacion_11,
				TRIM(denominacion_12) denominacion_12,
				TRIM(denominacion_13) denominacion_13,
				TRIM(denominacion_14) denominacion_14,
				TRIM(denominacion_15) denominacion_15, 
				ROUND(SUM(NVL(cantidad_1, 0.0) * NVL(denominacion_1, 0))) importe_1,
				ROUND(SUM(NVL(cantidad_2, 0.0) * NVL(denominacion_2, 0))) importe_2,
				ROUND(SUM(NVL(cantidad_3, 0.0) * NVL(denominacion_3, 0))) importe_3,
				ROUND(SUM(NVL(cantidad_4, 0.0) * NVL(denominacion_4, 0))) importe_4,
				ROUND(SUM(NVL(cantidad_5, 0.0) * NVL(denominacion_5, 0))) importe_5,
				ROUND(SUM(NVL(cantidad_6, 0.0) * NVL(denominacion_6, 0))) importe_6,
				ROUND(SUM(NVL(cantidad_7, 0.0) * NVL(denominacion_7, 0))) importe_7,
				ROUND(SUM(NVL(cantidad_8, 0.0) * NVL(denominacion_8, 0))) importe_8,
				ROUND(SUM(NVL(cantidad_9, 0.0) * NVL(denominacion_9, 0))) importe_9,
				ROUND(SUM(NVL(cantidad_10, 0.0) * NVL(denominacion_10, 0))) importe_10,
				ROUND(SUM(NVL(cantidad_11, 0.0) * NVL(denominacion_11, 0))) importe_11,
				ROUND(SUM(NVL(cantidad_12, 0.0) * NVL(denominacion_12, 0))) importe_12,
				ROUND(SUM(NVL(cantidad_13, 0.0) * NVL(denominacion_13, 0))) importe_13,
				ROUND(SUM(NVL(cantidad_14, 0.0) * NVL(denominacion_14, 0))) importe_14,
				ROUND(SUM(NVL(cantidad_15, 0.0) * NVL(denominacion_15, 0))) importe_15
				INTO cInstitucion, cFecha, cMediodist, cTipodist, 
				cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, 
				cDenominacion_6, cDenominacion_7, cDenominacion_8, cDenominacion_9, cDenominacion_10, 
				cDenominacion_11, cDenominacion_12, cDenominacion_13, cDenominacion_14, cDenominacion_15, 
				cImporte_1, cImporte_2, cImporte_3, cImporte_4, cImporte_5, 
				cImporte_6, cImporte_7, cImporte_8, cImporte_9, cImporte_10, 
				cImporte_11, cImporte_12, cImporte_13, cImporte_14, cImporte_15 
				FROM bdisuc:"informix".ss_saldossuc
				WHERE fecha = dFechaFin
				GROUP BY fecha, sucursal, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15
				ORDER BY sucursal
			
				IF NVL(cImporte_1,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_1,cImporte_1);
				END IF;

				IF NVL(cImporte_2,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_2,cImporte_2);
				END IF;

				IF NVL(cImporte_3,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_3,cImporte_3);
				END IF;
				
				IF NVL(cImporte_4,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_4,cImporte_4);
				END IF;
				
				IF NVL(cImporte_5,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_5,cImporte_5);
				END IF;

				IF NVL(cImporte_6,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_6,cImporte_6);
				END IF;
				
				IF NVL(cImporte_7,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_7,cImporte_7);
				END IF;

				IF NVL(cImporte_8,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_8,cImporte_8);
				END IF;

				IF NVL(cImporte_9,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_9,cImporte_9);
				END IF;
				
				IF NVL(cImporte_10,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_10,cImporte_10);
				END IF;

				IF NVL(cImporte_11,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_11,cImporte_11);
				END IF;

				IF NVL(cImporte_12,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_12,cImporte_12);
				END IF;
				
				IF NVL(cImporte_13,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_13,cImporte_13);
				END IF;
				
				IF NVL(cImporte_14,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_14,cImporte_14);
				END IF;

				IF NVL(cImporte_15,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_15,cImporte_15);
				END IF;
	
				LET iTotalReg = iTotalReg + 1;
				
			END FOREACH;
			
			FOREACH
			
				-------------- SALDO FINAL EN BÓVEDAS --------------
				SELECT '040137' institucion, fecha, cod_proveedor AS mediodist, 2 AS tipodist, 
				TRIM(denominacion_1) denominacion_1,
				TRIM(denominacion_2) denominacion_2,
				TRIM(denominacion_3) denominacion_3,
				TRIM(denominacion_4) denominacion_4,
				TRIM(denominacion_5) denominacion_5,
				TRIM(denominacion_6) denominacion_6,
				TRIM(denominacion_7) denominacion_7,
				TRIM(denominacion_8) denominacion_8,
				TRIM(denominacion_9) denominacion_9,
				TRIM(denominacion_10) denominacion_10,
				TRIM(denominacion_11) denominacion_11,
				TRIM(denominacion_12) denominacion_12,
				TRIM(denominacion_13) denominacion_13,
				TRIM(denominacion_14) denominacion_14,
				TRIM(denominacion_15) denominacion_15, 
				ROUND(SUM(NVL(cantidad_1, 0.0) * NVL(denominacion_1, 0))) importe_1,
				ROUND(SUM(NVL(cantidad_2, 0.0) * NVL(denominacion_2, 0))) importe_2,
				ROUND(SUM(NVL(cantidad_3, 0.0) * NVL(denominacion_3, 0))) importe_3,
				ROUND(SUM(NVL(cantidad_4, 0.0) * NVL(denominacion_4, 0))) importe_4,
				ROUND(SUM(NVL(cantidad_5, 0.0) * NVL(denominacion_5, 0))) importe_5,
				ROUND(SUM(NVL(cantidad_6, 0.0) * NVL(denominacion_6, 0))) importe_6,
				ROUND(SUM(NVL(cantidad_7, 0.0) * NVL(denominacion_7, 0))) importe_7,
				ROUND(SUM(NVL(cantidad_8, 0.0) * NVL(denominacion_8, 0))) importe_8,
				ROUND(SUM(NVL(cantidad_9, 0.0) * NVL(denominacion_9, 0))) importe_9,
				ROUND(SUM(NVL(cantidad_10, 0.0) * NVL(denominacion_10, 0))) importe_10,
				ROUND(SUM(NVL(cantidad_11, 0.0) * NVL(denominacion_11, 0))) importe_11,
				ROUND(SUM(NVL(cantidad_12, 0.0) * NVL(denominacion_12, 0))) importe_12,
				ROUND(SUM(NVL(cantidad_13, 0.0) * NVL(denominacion_13, 0))) importe_13,
				ROUND(SUM(NVL(cantidad_14, 0.0) * NVL(denominacion_14, 0))) importe_14,
				ROUND(SUM(NVL(cantidad_15, 0.0) * NVL(denominacion_15, 0))) importe_15
				INTO cInstitucion, cFecha, cMediodist, cTipodist, 
				cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, 
				cDenominacion_6, cDenominacion_7, cDenominacion_8, cDenominacion_9, cDenominacion_10, 
				cDenominacion_11, cDenominacion_12, cDenominacion_13, cDenominacion_14, cDenominacion_15, 
				cImporte_1, cImporte_2, cImporte_3, cImporte_4, cImporte_5, 
				cImporte_6, cImporte_7, cImporte_8, cImporte_9, cImporte_10, 
				cImporte_11, cImporte_12, cImporte_13, cImporte_14, cImporte_15 
				FROM bdisuc:"informix".ss_cajageneral_hist
				WHERE fecha = dFechaFin
				GROUP BY fecha, cod_proveedor, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15
				ORDER BY cod_proveedor
			
				IF NVL(cImporte_1,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_1,cImporte_1);
				END IF;

				IF NVL(cImporte_2,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_2,cImporte_2);
				END IF;

				IF NVL(cImporte_3,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_3,cImporte_3);
				END IF;
				
				IF NVL(cImporte_4,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_4,cImporte_4);
				END IF;
				
				IF NVL(cImporte_5,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_5,cImporte_5);
				END IF;

				IF NVL(cImporte_6,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_6,cImporte_6);
				END IF;
				
				IF NVL(cImporte_7,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_7,cImporte_7);
				END IF;

				IF NVL(cImporte_8,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_8,cImporte_8);
				END IF;

				IF NVL(cImporte_9,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_9,cImporte_9);
				END IF;
				
				IF NVL(cImporte_10,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_10,cImporte_10);
				END IF;

				IF NVL(cImporte_11,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_11,cImporte_11);
				END IF;

				IF NVL(cImporte_12,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_12,cImporte_12);
				END IF;
				
				IF NVL(cImporte_13,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_13,cImporte_13);
				END IF;
				
				IF NVL(cImporte_14,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_14,cImporte_14);
				END IF;

				IF NVL(cImporte_15,0) > 0 THEN
					INSERT INTO bdisuc:"informix".sw_ope_expimppesos_tmp(usuario_insert,institucion,fecha,medio_dis,tipo_dis,denominacion,importe)
					VALUES(pUsuario,cInstitucion,cFecha,cMediodist,cTipodist,cDenominacion_15,cImporte_15);
				END IF;
	
				LET iTotalReg = iTotalReg + 1;
				
			END FOREACH;
			
			IF NVL(iTotalReg,0) = 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ' ',' ',' ',0,' ',' '";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL";
				LET cCmd1 =""||TRIM(cCmd1)||" SELECT institucion,fecha,medio_dis,tipo_dis::INTEGER,denominacion,importe";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_expimppesos_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY 3 ASC";
			
			ELIF NVL(iTotalReg,0) > 0 THEN
			
				LET cCmd1 ="";
				LET cCmd1 ="SELECT ''''||institucion,fecha,''''||medio_dis,tipo_dis,denominacion,importe";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisuc:""informix"".sw_ope_expimppesos_tmp";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"||pUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY medio_dis ASC";
			
			END IF;
			
		END IF;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdisuc '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE LIMPIAN TABLAS
		IF pSeccion = 1 THEN
			DELETE FROM bdisuc:"informix".sw_ope_denominaciones_tmp WHERE usuario_insert = pUsuario;
		ELIF pSeccion = 2 THEN
			
		ELIF pSeccion = 3 THEN
			DELETE FROM bdisuc:"informix".sw_ope_cajerosaut_tmp WHERE usuario_insert = pUsuario;
			
			DROP TABLE IF EXISTS misenmis; 
			DROP TABLE IF EXISTS reversos;
			DROP TABLE IF EXISTS reversostot;
			DROP TABLE IF EXISTS mismisfin;
			DROP TABLE IF EXISTS misenmistot;
			DROP TABLE IF EXISTS misenmismestot;
			DROP TABLE IF EXISTS caja3;
			
		ELIF pSeccion = 4 THEN
		
		ELIF pSeccion = 5 THEN
		
		ELIF pSeccion = 6 THEN
			DELETE FROM bdisuc:"informix".sw_ope_expimppesos_tmp WHERE usuario_insert = pUsuario;
		END IF;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
		LET dFecha = DATE(CURRENT);
		LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
		LET cCodRetSp = '00000';
		LET cDesCodRet = 'EL ARCHIVO SE GENERÓ EXITOSAMENTE';
		
		-- BITACORÉO
		INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
		VALUES(dFecha,cHora,pUsuario,cDesCodRet,null,TRIM(cNombreArchivo));
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			--LET cCodRet = '00282';
			--RETURN cCodRet, cNombreArchivo;
		END IF;
		
		UPDATE bdisuc:"informix".sw_ope_statusrepoemn
		SET status = 'T', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
		WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_generasecciones_oemn'
		AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
		
		RETURN cCodRet, cNombreArchivo;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: GENERACIÓN DE REPORTES EN EFECTIVO EN MONEDA NACIONAL',
'DESCRIPCION: SPL encargado de la generación de los reportes correspondientes a las operaciones de moneda nacional.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 16/04/2018',
'DESCRIPCION: Se modifica SPL para cambiar el formato de fecha de acuerdo a la configuración actual del sistema.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/04/2018',
'DESCRIPCION: Se modifica SPL para controlar error -668.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 07/05/2018',
'DESCRIPCION: Se modifica SPL eliminar las tablas temporales que se generan para la seccion 3.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_guarda_bitacora_ws(pempresa CHAR(3),
pSucursal Char(4),
pCodigo_Motor CHAR(5),
pDescripcion_Codigo_Motor CHAR(30),
pCodigo_ws CHAR(3),
pDescripcion_Codigo_ws  CHAR(200),
pCadena_ent CHAR(600),
pNotas CHAR(500),
pUsuario CHAR(8),
pFecha_Hora_Insert DATETIME YEAR TO SECOND)
RETURNING CHAR(6) as cCodRet;


--Declarar variables
DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vFecha CHAR(20);

-- inicializar variables
LET vcodret = '00000';
LET vsqlerr = 0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_guarda_bitacora_webservice.out";
--TRACE ON;


BEGIN

	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret;
	   END IF;
	END EXCEPTION;
	
	IF( NVL(pempresa,'') = '' OR NVL(pSucursal,'') = ''  OR NVL(pCodigo_Motor,'') = '' OR NVL(pFecha_Hora_Insert,'') = '' 
	   OR  NVL(pUsuario,'') = '') THEN	
		
		LET vcodret = "00002";
	ELSE
		IF NOT EXISTS(SELECT * FROM   "informix".ss_bitacora_panamericano_errores WHERE user_insert  = pUsuario AND fecha_hora_insert = pFecha_Hora_Insert) THEN
				
			INSERT INTO  "informix".ss_bitacora_panamericano_errores (empresa,codigo_motor,descripcion_codigo_motor,codigo_ws,descripcion_codigo_ws,Sucursal,cadena_ent,Notas,user_insert,fecha_hora_insert) 
			VALUES (pempresa,pCodigo_Motor,pDescripcion_Codigo_Motor,pCodigo_ws,pDescripcion_Codigo_ws,pSucursal,pCadena_ent,pNotas,pUsuario,pFecha_Hora_Insert);
		ELSE	
			LET vcodret = "00001";
		END IF;
	END IF;

END; 

RETURN vcodret;
END PROCEDURE
DOCUMENT
'FOLIO: 342',
'AUTOR: OMAR LERMA, OMAR GÃMEZ',
'FECHA: 03/01/2018',
'MODIFICACIÃN: SE CREA SP PARA GUARDAR BITACORA DE LA EJECUCION DE WS PANAMERICANO',
'SOLICITA: ABRAHAM NERVAEZ',
'DB:BDISUC';

CREATE PROCEDURE "informix".sp_tipo_reporte_etv2()
RETURNING CHAR(5),CHAR(35);


DEFINE SQL_ERR                  INTEGER;
DEFINE ISAM_ERR                 INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE cod_ret                  CHAR(5);
DEFINE vtipo_operacion  CHAR(35);


LET cod_ret = '00000';
LET vtipo_operacion = '';



BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;

        RETURN cod_ret,vtipo_operacion;


    END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

        --SET debug file to "/informix/1170/calizarraga/sp_tipo_opermonitor_etv.out";
        --trace on;

    FOREACH
        SELECT tipo_operacion
        INTO vtipo_operacion
        FROM bdisuc:"informix".ss_tipo_reporte_etv


        RETURN cod_ret,vtipo_operacion WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado',
'FECHA 30/07/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Clon de SPL productivo - Se modifica la longitud de la columna tipo de operación.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_concensuc_ws(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
        pfecha  date,
		pdeno1  CHAR(18),
		pdeno2  CHAR(18),
		pdeno3  CHAR(18),
		pdeno4  CHAR(18),
        pdeno5  CHAR(18),
		pdeno6  CHAR(18),
		pdeno7  CHAR(18),
		pdeno8  CHAR(18),
		pdeno9  CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1  float(8),
		pcant2  float(8),
		pcant3  float(8),
		pcant4  float(8),
		pcant5  float(8),
		pcant6  float(8),
		pcant7  float(8),
		pcant8  float(8),
		pcant9  float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8),
        pfolio char(16))


RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum INTEGER;
DEFINE vmonto money(14,2);
DEFINE vtransaccion CHAR(4);
DEFINE vid_solicitud CHAR(25);


LET vcodret = "000";
LET vfolio = "";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vmonto = 0;
LET vtransaccion = '';
LET vid_solicitud = '';



BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/informix/calizarraga/concensuc.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio = '' then
   LET vcodret = "110";
ELSE

   set isolation to dirty read; 
   SET LOCK MODE TO WAIT 3;

   
   select FIRST 1 o.folio_oper,o.monto
     into vfolio, vmonto
   	from bdisuc:ss_operaciones o, bdisuc:ss_mae_entradasalida m
  	where o.folio_oper = m.folio_oper
    AND o.fecha_operacion = pfecha
    AND o.sucursal = psucursal
    AND o.cod_trans = ptransaccion
    AND o.reversado = 0
    AND m.folio_servicio = pfolio;

    if (vmonto is null) then let vmonto = 0; end if; 

    IF vfolio IS NOT NULL AND vmonto <> pmonto_dot THEN
         LET vcodret = "109";
        RETURN vcodret,vfolio;
    END IF;

    IF vfolio IS NOT NULL AND vmonto = pmonto_dot AND pmonto_dot > 0 THEN
        UPDATE bdisuc:"informix".ss_operaciones
        SET  cod_trans = ptransaccion,
             folio_sucursal = pfolio_suc,
             denominacion_1 = pdeno1, denominacion_2 = pdeno2, denominacion_3 = pdeno3,
             denominacion_4 = pdeno4, denominacion_5 = pdeno5, denominacion_6 = pdeno6,
             denominacion_7 = pdeno7, denominacion_8 = pdeno8, denominacion_9 = pdeno9,
             denominacion_10= pdeno10,denominacion_11= pdeno11,denominacion_12= pdeno12,
             denominacion_13= pdeno13,denominacion_14= pdeno14,denominacion_15= pdeno15,
             cantidad_1 = pcant1, cantidad_2 = pcant2, cantidad_3 = pcant3,
             cantidad_4 = pcant4, cantidad_5 = pcant5, cantidad_6 = pcant6,
             cantidad_7 = pcant7, cantidad_8 = pcant8, cantidad_9 = pcant9,
             cantidad_10 = pcant10,cantidad_11 = pcant11,cantidad_12 = pcant12,
             cantidad_13 = pcant13,cantidad_14 = pcant14,cantidad_15 = pcant15
			WHERE   empresa = pempresa 
			and     folio_oper= vfolio;

        UPDATE bdisuc:"informix".ss_mae_entradasalida
        SET  folio_sucursal = pfolio_suc,
             fecha_solicitud = pfecha,
             hora_solicitud = vhora,
             usuario_solicitud = pcajeroprincipal,
             hora_envio = vhora,
             usuario_envio = pcajeroprincipal
			WHERE empresa = pempresa
			and   folio_oper = vfolio;
			RETURN vcodret,vfolio;

    ELSE

			select s.plaza_cajagen,p.cod_proveedor
			into vplaza, vproveedor
			from bdisuc:ss_proveedores p, bdinteg:si_sucursales s
			where p.plaza = s.plaza_cajagen
			and s.empresa = pempresa
			and s.sucursal = psucursal;


    	if ( vmonto = 0 ) then
        select valor into vnum
        from   ss_param_cajagen
        where  codigo = '0005';

        update ss_param_cajagen
        set    valor = valor + 1
        where  codigo = '0005';

        let vfolio = lpad(vnum,8,"0");
		
		SELECT codigo
				INTO vtransaccion
				FROM bdisuc:ss_param_cajagen
				WHERE empresa = '001'
				AND codigo = '0026'; 
		
		
		--BUSCA ID SOLICITUD DE LA RECOLECCION
		SELECT es.id_solicitud
		INTO vid_solicitud
		FROM bdisuc:"informix".ss_mae_entradasalida es
		WHERE es.status IN ('16')
		AND es.id_solicitud IN (SELECT id_solicitud 
						FROM bdisuc:"informix".ss_operaciones op
						WHERE op.cod_trans = vtransaccion
						AND op.sucursal = psucursal
						AND op.sucursal = es.sucursal
						AND op.id_solicitud = es.id_solicitud
						);
						
					IF vid_solicitud IS NULL THEN
		
						LET vid_solicitud = '';
					END IF;

							
		
        INSERT INTO bdisuc:"informix".ss_operaciones
          (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,id_solicitud,folio_oper,reversado,usuario,divisa,monto,
               denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
               denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
               denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
               cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
               cantidad_13,cantidad_14,cantidad_15)
        VALUES
              (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vid_solicitud,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
               pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
           pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
           pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

        INSERT INTO bdisuc:"informix".ss_mae_entradasalida
               (empresa,cod_proveedor,id_solicitud,folio_oper,sucursal,folio_sucursal,
                fecha_solicitud,hora_solicitud,usuario_solicitud,
                fecha_envio,hora_envio,usuario_envio,
                status,monto,folio_servicio)
        VALUES (pempresa,vproveedor,vid_solicitud,vfolio,psucursal,pfolio_suc,
                pfecha,vhora,pcajeroprincipal,
                pfecha,vhora,pcajeroprincipal,
                '06',pmonto_dot,pfolio);
		
		
				--SELECT codigo
				--INTO vtransaccion
				--FROM bdisuc:ss_param_cajagen
				--WHERE empresa = '001'
				--AND codigo = '0026'; 
		
				--ACTUALIZA STATUS DE RECOLECCION
		
				UPDATE bdisuc:"informix".ss_mae_entradasalida es
				SET es.status = '17'
				WHERE es.status IN ('16')
				AND es.id_solicitud IN (SELECT id_solicitud 
								FROM bdisuc:"informix".ss_operaciones op
								WHERE op.cod_trans = vtransaccion
								AND op.sucursal = psucursal
								AND op.sucursal = es.sucursal
								AND op.id_solicitud = es.id_solicitud
								);
					
    end if;

    END IF;

END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;