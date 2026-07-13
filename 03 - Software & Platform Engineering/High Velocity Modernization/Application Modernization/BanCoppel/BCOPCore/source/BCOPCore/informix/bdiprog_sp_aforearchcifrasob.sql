CREATE PROCEDURE "informix".sp_aforearchcifrasob(pNombreArchivo CHAR(30), pUserInsert CHAR(8))
	RETURNING CHAR(5) AS CodigoRet,
			CHAR(200) AS MensajeRet;

DEFINE cTipoRegistro 				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE iSqlErr              		INTEGER;
DEFINE cCodRet              		CHAR(5);
DEFINE dFechaHoy	           		DATE;
DEFINE cSQL                 		CHAR(200);
DEFINE cProceso						CHAR(10);
DEFINE cNombreArchivoSalida 		CHAR(30);
DEFINE cRenglon						CHAR(30);
DEFINE cStatus						CHAR(1);

-- ENCABEZADO
DEFINE cFechaGeneracion  CHAR(8);  
DEFINE cFechaMovimientos CHAR(8); 

-- DETALLE
DEFINE cEstatus           CHAR(2);
DEFINE cNumeroMovimientos INTEGER;
DEFINE cMonto             BIGINT;

-- SUMARIO
DEFINE cNumeroRegistrosDetalle INTEGER;
DEFINE cMontoGlobal BIGINT;
DEFINE iSuma BIGINT;
DEFINE iSuma2 BIGINT;
DEFINE iContRegDet INTEGER;
DEFINE dHora  datetime HOUR TO SECOND;
DEFINE cRuta     CHAR(20);
DEFINE cRelleno  CHAR(10);
DEFINE cRelleno1 CHAR(12);
DEFINE cRelleno2 CHAR(2);
DEFINE cRelleno3 CHAR(4);
DEFINE cCodRetInterno CHAR(5);
DEFINE cMensaje CHAR(200);

-- ENCRIPTACION
DEFINE cRetEncripcion		CHAR(6);
DEFINE cMsgEncripcion		CHAR(100);
DEFINE cLlave				CHAR(200);
DEFINE cNombreArchivo		CHAR(50);
DEFINE cRutaArchivoOrigen	CHAR(100);
DEFINE cRutaArchivoDestino	CHAR(100);
DEFINE cRutaRespaldo		CHAR(100);
DEFINE cUsuario				CHAR(20);



LET cCodRetInterno = '00000';
LET cRelleno = '';
LET cRelleno1 = '';
LET cRelleno2 = '';
LET cRelleno3 = '';
LET cTipoRegistro = '';
LET cFinLinea = '';
LET iSqlErr = '';
LET cCodRet = '';
LET dFechaHoy = '';
LET cSQL = '';
LET cProceso = '';
LET cStatus = '';
LET cNombreArchivoSalida = '';
LET cRenglon = '';
LET cFechaGeneracion  = '';  
LET cFechaMovimientos = ''; 
LET cEstatus = '';
LET cNumeroMovimientos = '';
LET cMonto = '';
LET cNumeroRegistrosDetalle = '';
LET cMontoGlobal = '';
LET iSuma = '0';
LET iSuma2= '0';
LET iContRegDet = 0;
-- ENCRIPTACION 
LET cRetEncripcion = '';
LET cMsgEncripcion = '';
LET cLlave = '';
LET cNombreArchivo = '';
LET cRutaArchivoOrigen = '';
LET cRutaArchivoDestino = '';
LET cRutaRespaldo = '';
LET cUsuario = '';
---------------------------
LET cRuta = '';
LET cSQL 		= '';
LET dFechaHoy 	= '';
LET cCodRet 	= '00000';
LET cProceso = 'AfGACCOB';
LET cStatus  = '1';
LET dhora = CURRENT HOUR TO SECOND;
LET cMensaje = 'Aplicado correctamente';

	
	--SET DEBUG FILE TO "/tmp/sp_aforearchcifrasob.out.out";
    --TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			CALL 'informix'.sp_afore_mensajeretorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
			INSERT INTO 'informix'.pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUserInsert,dFechaHoy,dhora);
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-668)
		LET cCodRet = '10010';
		CALL 'informix'.sp_afore_mensajeretorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
		INSERT INTO 'informix'.pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUserInsert,dFechaHoy,dhora);
		RETURN cCodRet, cMensaje;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- SE VALIDA SI SE RECIVIO EL PARAMETRO pUserInsert
	IF TRIM(pUserInsert) = '' THEN
		LET pUserInsert = 'informix';
	END IF;
	
	LET dhora = CURRENT;
	
	/*-- ERRORES
		LET cCodRet = '10011'; -- El Archivo ya fue procesado
		LET cCodRet = '10013'; -- No existe el archivo
		LET cCodRet = '10024'; -- Mensaje de error ya que no se Ejecuto el proceso Anterior
	*/
	
	-- SE  OBTIENE LA FECHA DEL SISTEMA   
	SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:'informix'.si_fechas;
	
	-- SE CREA EL NOMBRE DEL PROCESO CON EL CONSECUTIVO 01
	LET cProceso = 'AfGACCOB' || '01';
	
	-- CREAR EL NOMBRE DEL ARCHIVO CON EL CONSECUTIVO 01
	LET cNombreArchivoSalida = 'CONTOB' || LPAD(DAY(dFechaHoy),2,'0') || LPAD(MONTH(dFechaHoy),2,'0') || YEAR(dFechaHoy)  || '.BCOPPEL.01';
	
	-- HAY QUE TOMAR EL CONSECUTIVO DEL NOMBRE DEL ARCHIVO
	IF TRIM(pNombreArchivo) <> '' THEN 
		LET cProceso = 'AfGACCOB' || SUBSTR(pNombreArchivo,25,2);
		LET cNombreArchivoSalida = 'CONTOB' || LPAD(DAY(dFechaHoy),2,'0') || LPAD(MONTH(dFechaHoy),2,'0') || YEAR(dFechaHoy)  || '.BCOPPEL.' || SUBSTR(pNombreArchivo,25,2);
	END IF;
	
	-- VALIDAR QUE YA ESTE EJECUTADO EL PROCESO DE GENERACION DE ARCHIVO DE CONFIRMACION Y CONCLUIDO CORRECTO
	IF EXISTS (SELECT proceso FROM 'informix'.pp_procesos WHERE proceso = ('AfoGACOB' || SUBSTR(pNombreArchivo,25,2)) AND fech_proceso = dFechaHoy AND status = '2') THEN
		
		-- VALIDAR SI YA SE EJECUTO EL PROCESO DE GENERAR ARCHIVO DE CIFRAS DE CONTROL
		IF EXISTS (SELECT proceso FROM 'informix'.pp_procesos WHERE proceso = cProceso AND fech_proceso = dFechaHoy) THEN
		
			SELECT status INTO cStatus FROM 'informix'.pp_procesos WHERE proceso = cProceso AND fech_proceso = dFechaHoy;
			-- EL ARCHIVO YA FUE PROCESADO
			IF cStatus != '1' THEN
				-- EL ESTATUS ES  02
				LET cCodRet = '10011';
				CALL 'informix'.sp_afore_mensajeretorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
				INSERT INTO 'informix'.pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUserInsert,dFechaHoy,dhora);
				RETURN cCodRet, cMensaje;
			END IF;
		ELSE
			-- GUARDAR EL INICIO DEL PROCESO Y SE EJECUTA
			INSERT INTO 'informix'.pp_procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
			VALUES (cProceso,dFechaHoy,cStatus,pUserInsert,dFechaHoy);
		END IF;
	ELSE
		-- MENSAJE DE ERROR YA QUE SE DEVIO HABER EJECUTADO EL PROCESO DE GENERACION DE ARCHIVOS DE CONTROL
		LET cCodRet = '10024';
		CALL 'informix'.sp_afore_mensajeretorno (cCodRet) RETURNING cCodRetInterno,cMensaje;
		INSERT INTO 'informix'.pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cProceso,pNombreArchivo,cCodRet,cMensaje,pUserInsert,dFechaHoy,dhora);	
		RETURN cCodRet, cMensaje;
	END IF;

	DELETE FROM 'informix'.pp_archcifras;
	
	SELECT valor INTO cRuta FROM 'informix'.pp_parametros WHERE cve_param = '100';
	
	-- DATOS DEL ENCABEZADO
	LET cTipoRegistro = 'E';
	LET cFechaGeneracion = LPAD(DAY(dFechaHoy),2,'0') || LPAD(MONTH(dFechaHoy),2,'0') || YEAR(dFechaHoy);
	LET cFechaMovimientos = LPAD(DAY(dFechaHoy),2,'0') || LPAD(MONTH(dFechaHoy),2,'0') || YEAR(dFechaHoy);
	
	LET cRenglon = cTipoRegistro || cFechaGeneracion || cFechaMovimientos;
	
	INSERT INTO 'informix'.pp_archcifras (columna)
	VALUES (cRenglon);
	
	-- SE OBTIENEN LOS DATOS DE DETALLE
	IF EXISTS (SELECT status FROM 'informix'.pp_detalle WHERE nombre_arch = pNombreArchivo) THEN
		FOREACH
			SELECT DISTINCT(status), COUNT(status), SUM(imp_netopagar * 100)
			INTO cEstatus, cNumeroMovimientos, cMonto
			FROM 'informix'.pp_detalle
			WHERE nombre_arch = pNombreArchivo
			GROUP BY status
			
			LET cTipoRegistro = 'D';
			LET cRelleno = LPAD(cMonto,10,'0');
			LET cRelleno3 =  LPAD(cNumeroMovimientos,4,'0');
			LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cRelleno3 || cRelleno;
			
			INSERT INTO 'informix'.pp_archcifras (columna)
			VALUES (cRenglon);
		
			LET iSuma = iSuma + cMonto;
			LET iSuma2 = iSuma2 + cNumeroMovimientos;
			LET iContRegDet = iContRegDet + 1;
		END FOREACH;
	ELSE
		LET cTipoRegistro = 'D';
		LET cRenglon = cTipoRegistro || cFechaMovimientos || cEstatus || cNumeroMovimientos || cMonto;
		
		INSERT INTO 'informix'.pp_archcifras (columna)
		VALUES (cRenglon);
	END IF
	
	-- SE OBTIENEN LO DATOS DEL SUMARIO
	LET cTipoRegistro = 'S';
	LET cMontoGlobal = iSuma;
	LET cRelleno1 = LPAD(cMontoGlobal,12,'0');
	LET cNumeroRegistrosDetalle = iContRegDet;
	LET cRelleno2 = LPAD(cNumeroRegistrosDetalle,2,'0');
	LET cRenglon = cTipoRegistro || cRelleno2 || cRelleno1;
		
	INSERT INTO 'informix'.pp_archcifras (columna)
	VALUES (cRenglon);
	
	-- SE ALMACENA TODA LA INFORMACION EN UN ARCHIVO IMPLEMENTANDO UN (UNLOAD)
	LET cSQL = '';
	LET  cSQL = 'echo "UNLOAD TO '||TRIM(cRuta)||'temporal.unl ' ||
				'SELECT columna FROM pp_archcifras; " > '||TRIM(cRuta)||'query3.sql';
	SYSTEM cSQL;
	
	--LET cSQL = 'dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; -- SE ACTIVA PARA DESARROLLO
	LET cSQL = '/ifxsif01/bin/dbaccess bdiprog '||TRIM(cRuta)||'query3.sql'; -- SE ACTIVA PARA PRODUCCION
	SYSTEM cSQL;

	-- LE QUITA EL ULTIMO | AL ARCHIVO .TXT Y SE RENOMBRA CON ESTANDAR DEL NOMBRE
	LET cSQL = "sed 's/|$//g' "||TRIM(cRuta)||"temporal.unl > " 
		 || TRIM(cRuta) || cNombreArchivoSalida;
	SYSTEM cSQL;

	--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO	
	LET cSQL = 'rm -rf '||TRIM(cRuta)||'temporal.unl';
	SYSTEM cSQL;
	
	LET cSQL = 'rm -f '||TRIM(cRuta)||'query3.sql';
	SYSTEM cSQL;

	-- SE DAN PERMISOS AL ARCHIVO GENERADO	
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || TRIM (cNombreArchivoSalida);
	SYSTEM cSQL ;
	
	-- ALMACENAR EN pp_arch_afore (status 01 y tipo de archivo T) 
	INSERT INTO 'informix'.pp_arch_afore (nombre_arch, tipo, fecha_generado, fecha_procesado, status,user_insert, fecha_insert)
	VALUES (cNombreArchivoSalida, 'T', dFechaHoy, dFechaHoy, '01', pUserInsert, dFechaHoy);
	
	--REGISTRAR EL FINAL DEL PROCESO EN LA TABLA pp_proceso
	UPDATE 'informix'.pp_procesos SET status = '2'
	WHERE proceso = cProceso AND fech_proceso = dFechaHoy;
	
	--Obtiene parametros de encriptacion
	SELECT llave, ruta_origen, ruta_destino, ruta_originales, usuario
	INTO cLlave, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cUsuario
	FROM bdinteg:si_configura_pgp
	WHERE codigo = 'AFORE_02';
	
	LET cNombreArchivo = cNombreArchivoSalida;
	--Se encripta el archivo		
	EXECUTE PROCEDURE bdiprog:"informix".sp_encriptaarchivo(cUsuario, cRutaArchivoOrigen, cRutaArchivoDestino, cRutaRespaldo, cNombreArchivo, cLlave)
	INTO cRetEncripcion, cMsgEncripcion;
	
	RETURN cCodRet, cMensaje;
	
END
END PROCEDURE
DOCUMENT
'AUTOR      : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: El objetivo de este Sp es el de Generar un archivo del total de pagos procesados de otros Bancos.', 
'FECHA      : 02 de Abril de 2014',
'SUSTENTO   : Se definio con Leonardo HernÃ¡ndez Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sps_consulta_ctasfrec_bpi(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING 
     CHAR(6) AS cod_ret, ---Cod_ret
	 CHAR(20) AS cuenta, ---Cuenta
	 CHAR(100) AS nombre, ---Nombre
	 CHAR(50) AS banco, ---Banco
	 CHAR(2) AS compania_cel, ---Compa?ia celular
	 CHAR(10) AS celular, ---Numero celular
	 CHAR(40) AS correo_elec, ---Correo electronico
	 CHAR(2) AS cve_cuenta, ---Cve cuenta
     CHAR(20) AS desc_cuenta, ---Desc cuenta
     CHAR(13) AS rfc , ---Rfc
	 MONEY(16,2) AS monto_maximo, ---Monto M?ximo
	 CHAR(1) AS cve_caducidad, -- Tipo de caducidad
	 CHAR(1) AS activarBPI; --Bandera para validar CtaFrecuente activa

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER; 
	DEFINE v_BandActiva			CHAR(1);
	DEFINE v_ExisteCuenta		CHAR(1); 
    DEFINE vv_Banco             CHAR(5);
    DEFINE v_vchrnombrecorto    CHAR(50);
    DEFINE v_descripcion        CHAR(50);
    DEFINE v_provisional        CHAR(50);
	DEFINE p_MontoMax			MONEY(16,2);
 

	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= ""; 
	LET v_BandActiva            = "";
	LET v_ExisteCuenta          = NULL; 
    LET vv_Banco				= "";
    LET v_vchrnombrecorto		= "";
    LET v_descripcion		    = "";
	LET v_provisional			= "";
	LET p_MontoMax				= 200000.00;

	 
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF; 
		RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL; 
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/gaby/AMEX/sps_consulta_ctasfrec_bpi.out"; 
	--TRACE ON;  
	
	SELECT cod_ret 
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	SELECT banco, vchrnombrecorto,  descripcion  --|| " " ||
	INTO vv_Banco, v_vchrnombrecorto, v_descripcion
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";
 
    ---------------------------------------------------------------------------------------------------------------------------------
	LET v_vchrnombrecorto=TRIM(v_vchrnombrecorto);
	LET v_descripcion=TRIM(v_descripcion);
	LET vv_Banco=TRIM(vv_Banco);
	
	IF (v_vchrnombrecorto='') THEN 
	LET v_provisional= v_descripcion;
	ELSE 
	LET v_provisional= v_vchrnombrecorto;
	END IF;
	
	Let v_Banco= vv_Banco|| " " ||v_provisional;
	---------------------------------------------------------------------------------------------------------------------------------

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN 
		 
		SELECT LIMIT 1 ct.cuenta 
		INTO v_ExisteCuenta
		FROM (SELECT ct.cuenta 
              FROM bdiprog:"informix".pp_ctasterceros ct
              left outer join bdiprog:"informix".pp_cuentapago cp on (ct.cve_cuenta = cp.cve_cuenta)
              WHERE ct.num_cte = p_NumCte
			  UNION
			  SELECT ctb.cuenta FROM bdiprog:"informix".pp_ctasterceros_bex ctb, bdiprog:"informix".pp_cuentapago cp 
			  WHERE ctb.num_cte = p_NumCte 
			  AND ctb.cve_cuenta = cp.cve_cuenta
		) ct;
		
		IF (v_ExisteCuenta IS NOT NULL ) THEN 
            IF (p_CvePago) = '04' THEN
                FOREACH  
					SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0),ct.cve_caducidad
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte                   
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01' 
					
					IF v_MontoMaximo= 0 THEN 
						LET v_MontoMaximo = p_MontoMax;
					END IF 

--                  LET v_ContReg = v_ContReg + 1;
--                  IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                       CONTINUE FOREACH;
--                  END IF;
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
					END IF;

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					
 
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad,v_BandActiva WITH RESUME;	
                END FOREACH;
            ELSE
                FOREACH  
                    SELECT ct.cuenta, ct.nombre AS nombreCte, b.banco, b.vchrnombrecorto,  b.descripcion
					, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta AS descripCta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad,  "1" AS bandAct			 
					INTO v_CtaDestino,v_Nombre,vv_Banco, v_vchrnombrecorto, v_descripcion,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad, v_BandActiva                 					
                     FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
					WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
					AND ct.cve_banco not in ('103')
					UNION 
					SELECT ctb.cuenta, ctb.nombre AS nombreCte, b.banco, b.vchrnombrecorto, b.descripcion
				    , ctb.cve_compania, ctb.no_celular, ctb.direc_correo, ctb.cve_cuenta,ctb.descrip_cta, ctb.rfc, ctb.canal_alta, ctb.fecha_insert, ctb.hora_insert, NVL(ctb.monto_maximo,0), ctb.cve_caducidad, "0" AS bandAct	
                    FROM bdiprog:"informix".pp_ctasterceros_bex ctb, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp 
					WHERE ctb.num_cte = p_NumCte
                    AND ctb.cve_banco = b.banco
                    AND ctb.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ctb.cve_estado = '01' 
					UNION  
					SELECT num_tarjeta ,nombre AS nombreCte,'137  BANCOPPEL, S. A.' ,'','','','','','04','CUENTA PROPIA' AS descripCta ,'','',mdy(1,1,1900), current hour to second,0,'0',"1" AS bandAct
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05' 
					ORDER BY bandAct, ct.descrip_cta, ct.nombre
					
					IF v_MontoMaximo= 0 THEN 
						LET v_MontoMaximo = p_MontoMax;
					END IF 

--                    LET v_ContReg = v_ContReg + 1; 
--                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                        CONTINUE FOREACH;
--                    END IF; 

					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					
	---------------------------------------------------------------------------------------------------------------------------------
					LET v_vchrnombrecorto=TRIM(v_vchrnombrecorto);
					LET v_descripcion=TRIM(v_descripcion);
	                LET vv_Banco=TRIM(vv_Banco);
					
					IF (v_vchrnombrecorto='') THEN 
					LET v_provisional= v_descripcion;
					ELSE 
					LET v_provisional= v_vchrnombrecorto;
					END IF;
					
					Let v_Banco= vv_Banco|| " " ||v_provisional;
	---------------------------------------------------------------------------------------------------------------------------------    

					IF (v_Canal = '03') OR (v_Canal = '18') THEN

                        IF ( v_CveCuenta = '03') THEN
                            IF (LENGTH(v_ctaDestino) = 10) THEN
                                LET v_CveCuenta = '07';
                            ELIF (LENGTH(v_ctaDestino) = 16) THEN
                            	LET v_CveCuenta = '03';
                            ELIF (LENGTH(v_ctaDestino) = 18) THEN
                                LET v_CveCuenta = '02';                           
                            END IF;
                        END IF;						
					END IF;

                    IF v_Canal = '03'  THEN
                        LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
                    END IF;

					
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					
  
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_BandActiva WITH RESUME;
                END FOREACH;
            END IF;
        ELSE 
			SELECT LIMIT 1 num_tarjeta INTO v_ExisteCuenta FROM bdicred:"informix".sd_tarjeta WHERE numcte == p_NumCte;			
			IF(v_ExisteCuenta IS NOT NULL) THEN 
                FOREACH
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'',"1"
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc,v_BandActiva
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago ="05"

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo, v_CveCaducidad, v_BandActiva  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL;
	END IF
END;
--##################################################################################
-- Se clona el SP sp_consultacuentasdestino_bpi para el proyecto de Reingenier?a BPI
-- agregando como dato de salida la caducidad
-- Bibiana Gaxiola Verdugo 
-- 19/12/2012
---------------
-- Se agrega validaci?n de monto 00
	-- Gabreial Aguilar
	-- 11/09/2020
---
--'Fecha: 16/02/2021',
--'Modificacion: Se agrega validacion para canal 18',
--'Marlen Aldana';
--##################################################################################
END PROCEDURE;