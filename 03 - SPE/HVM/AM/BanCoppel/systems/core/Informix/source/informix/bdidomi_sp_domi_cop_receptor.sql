CREATE PROCEDURE "informix".sp_domi_cop_receptor( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))
RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

	--****************************************************************************************************
	-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- RECEPTOR COPPEL
	-- SISTEMA : Domiciliacion
	--***************************************************************************************************

	/*  DEFINICION DE VARIABLES */
	DEFINE sPROCESANDO CHAR(1);
	DEFINE sERROR CHAR(1);
	DEFINE sFINALIZADO CHAR(1);
	
	DEFINE vsFlagTipoProceso CHAR (1);
	DEFINE viTipoArchivo SMALLINT ;
	
	DEFINE vsBloque CHAR (2);
	DEFINE vsFecha_Presentacion CHAR (8);
	DEFINE vsFecha_Presentacion1 CHAR (8);
	DEFINE vsFecha_Presentacion2 CHAR (8);

	DEFINE vsCodRetorno CHAR (5);
	DEFINE vsCodRetorno2 CHAR (5);
	DEFINE vsMensaje_Respuesta CHAR (100);
	DEFINE vsValorParam CHAR (100);
	DEFINE vsNomArchivo CHAR (20);
	DEFINE vsNomArchivo11 CHAR (20);
	DEFINE vsNomArchivo31 CHAR (20);
	DEFINE vsNomArchivo32 CHAR (20);
	DEFINE iContador INTEGER;
	DEFINE vdtFecha DATE;
	DEFINE visqlerr INTEGER ;

	DEFINE vsRuta CHAR (100);

	DEFINE vsNomProceso CHAR (20);
	DEFINE sCodBanco CHAR(3);
	DEFINE vsCodRetSub VARCHAR(115); ---descripcion
	DEFINE vSFecha_aplica CHAR(8);
	DEFINE vdFecha_aplicaDe DATE;

	DEFINE viNumArchivos INTEGER;

	DEFINE vsFlagArch11 CHAR(1);
	DEFINE vsFlagArch31 CHAR(1);
	DEFINE vsFlagArch32 CHAR(1);
	DEFINE vdtFecha_Presentacion_Resp DATE;

	DEFINE d_Fech_prox DATE;

	DEFINE vsSQL CHAR(2204);
	DEFINE cNumCte_Ordenante CHAR(20);
	DEFINE cRFCOrdenante	CHAR(18);
	DEFINE cCuentaAbono	 CHAR(20);
	DEFINE iTotalAltas 		 INTEGER;
	DEFINE mTotalImporteAltas MONEY(18,2);
	DEFINE iTotalBajas 		 INTEGER;
	DEFINE mTotalImporteBajas MONEY(18,2);
	
	DEFINE  cDesProceso	CHAR(60); 	
	DEFINE cTipoDomi	CHAR(1);
	DEFINE dFechaVal	DATE;
	DEFINE cCodRetVal	CHAR(3);
	/* INICIALIZACION DE VARIABLES */
	--VARIABLES DE MONITOR
	LET sPROCESANDO = '0';
	LET sFINALIZADO = '1';
	LET sERROR = '3';
	
	LET vsFlagTipoProceso = '';
	LET viTipoArchivo = 0;
	
	LET vsBloque = '00';
	LET vsFecha_Presentacion = '';
	LET vsFecha_Presentacion2 = '';

	LET vsCodRetorno = '';
	LET vsCodRetorno2 = '';
	LET vsMensaje_Respuesta = '';
	LET vsValorParam = '';
	LET vsNomArchivo = '';
	LET vsNomArchivo11 = '';
	LET vsNomArchivo31 = '';
	LET vsNomArchivo32 = '';
	LET iContador = 0;
	LET vdtFecha = CURRENT::DATE;

	LET vsRuta = '';

	LET vsNomProceso = 'RECEPCION DE ARCHIVOS DOMICILIACION';

	LET visqlerr = 0;
	LET sCodBanco = "";
	LET vsCodRetSub = "";
	LET vSFecha_aplica = "";

	LET viNumArchivos = 0;

	LET vsFlagArch11 = 'F';
	LET vsFlagArch31 = 'F';
	LET vsFlagArch32 = 'F';
	LET vdtFecha_Presentacion_Resp = CURRENT::DATE;
	
	LET cNumCte_Ordenante = '';
	LET cCuentaAbono = '';
	LET iTotalAltas = 0 ;
	LET mTotalImporteAltas = 0.00;
	LET iTotalBajas = 0;
	LET mTotalImporteBajas = 0.00;
	LET cRFCOrdenante = '';

	LET vsSQL = "";
	
	LET cDesProceso = 'RECEPCION DE ARCHIVOS DOMICILIACION';
	LET cTipoDomi = '';
	LET dFechaVal	= CURRENT::DATE;
	LET cCodRetVal	= '';

	--SET DEBUG FILE TO '/tmp/josea/10211/sp_domi_cop_receptor.out';
	--TRACE ON ;
	BEGIN

		ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
			
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), cDesProceso,
			sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;

			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(cDesProceso) ;
			RETURN  vsNomArchivo, visqlerr, vsMensaje_Respuesta ;
		END EXCEPTION;

		LET cDesProceso = 'Validacion de numero de empleado.';
		EXECUTE PROCEDURE bdidomi:sp_valida_cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

		LET cDesProceso = 'Validacion de parametros.';
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '16') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
			LET vsCodRetorno = '00101';
			--LET vsCodRetorno = '02400';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
			LET vsCodRetorno = '00105';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
			LET vsCodRetorno = '00106';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '43') THEN -- Valida que exista el NUEVO parametro BIN CORRESPONDIENTE TARJETA DEBITO
			LET vsCodRetorno = '00106';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI
			LET vsCodRetorno = '00107';		
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '47') THEN -- Valida que exista el parametro TRANSACCION CARGO POR DOMI CTAS BCPL
			LET vsCodRetorno = '00108';		
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '48') THEN -- Valida que exista el parametro TRANSACCION ABONO LIQ DOMI CTAS BCPL
			LET vsCodRetorno = '00109';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
			LET vsCodRetorno = '00110';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS
			LET vsCodRetorno = '00111';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
			LET vsCodRetorno = '00112';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '44') THEN -- Valida que exista el parametro RUTA INFORMIX
			LET vsCodRetorno = '00134';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '45') THEN -- Valida que exista el parametro NUM CTE COPPEL
			LET vsCodRetorno = '02248';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '46') THEN -- Valida que exista el parametro NUM CTA ABONO COPPEL
			LET vsCodRetorno = '02249';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '49') THEN -- Valida que exista el parametro TRANSACCION COMISION DOMI CTAS BANCOPPEL
			LET vsCodRetorno = '00135';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '15') THEN -- Valida que exista el parametro TRANSACCION IVA
			LET vsCodRetorno = '00136';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '34') THEN -- Valida que exista el parametro TRANSACCION ABONO REVERSO DOMI
			LET vsCodRetorno = '00137';
		ELIF NOT EXISTS (SELECT Valor FROM bdidomi:dom_parametros WHERE Cod_Param = '35') THEN -- Valida que exista el parametro TRANSACCION CARGO REVERSO DOMI
			LET vsCodRetorno = '00138';			
		ELIF NOT EXISTS (SELECT fecha_hoy FROM bdicheq:sc_fechas) THEN -- Valida que exista el parametro de la fecha actual.
			LET vsCodRetorno = '00114';
		ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPRLEADO VACIO
			LET vsCodRetorno = '00115';
		ELIF (LENGTH(TRIM(psNumEmpleado)) NOT IN(7,8))  THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
			LET vsCodRetorno = '00116';
		--ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		--LET vsCodRetorno = '00116';
		ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
			LET vsCodRetorno = '00132';
		ELSE --TODO LOS PARAMETROS EXISTEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			SELECT LIMIT 1 fecha_hoy 
			INTO vdtFecha 
			FROM bdicheq:sc_fechas;			
			
			--- OBTIENE CODIGO DE BANCOPPEL
			SELECT LIMIT 1 TRIM(valor)
			INTO sCodBanco
			FROM bdidomi:dom_parametros
			WHERE cod_param = "05";
			
			-- OBTIENE NUM CLIENTE COPPEL
			/*SELECT LIMIT 1 TRIM(valor)
			INTO cNumCte_Ordenante
			FROM bdidomi:dom_parametros
			WHERE cod_param = '45';*/
			
			EXECUTE PROCEDURE bdidomi:sp_valida_fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) 
			INTO vsCodRetorno;
			
			LET vsFecha_Presentacion = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
			-- Se guarda el valor para compararlo con el encabezado del archivo
			LET vsFecha_Presentacion1 = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
			
			--SE VALIDA SI LA FECHA ES HABIL
			IF EXISTS (SELECT fecha FROM bdinteg:si_feriado_banca WHERE pais = '001' AND fecha = vdtFecha) THEN				
				LET vsCodRetorno = '00113';
			ELSE
				EXECUTE PROCEDURE bdinteg:splvalfecha('001', vdtFecha, 0 ) INTO cCodRetVal, dFechaVal;
				IF NOT vdtFecha = dFechaVal THEN
					LET vsCodRetorno = '00113';
				ELSE
					LET vsCodRetorno = '00000';
				END IF;
			END IF;			
						
			LET vsValorParam = TRIM(sCodBanco);
		END IF;
		
		IF (vsCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN
			
			IF (TRIM(psNomArchivo) = '') THEN
				LET vsFlagTipoProceso = 'A';
			ELSE
				LET vsFlagTipoProceso = 'M';
			END IF;
			
			WHILE (iContador < 2) --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR

				LET cDesProceso = 'OBTENCION DE NOMBRE DE ARCHIVO';

				LET iContador = iContador + 1;
				
				FOREACH WITH HOLD
					SELECT a.num_cte, a.rfc
					INTO cNumCte_Ordenante, cRFCOrdenante
					FROM bdidomi:dom_cat_servicios a
					WHERE a.convenio = 'S'
					
					IF cRFCOrdenante = 'BSI061110963' THEN
						CONTINUE FOREACH;
					END IF;
				
					IF vsFlagTipoProceso = 'A' THEN 
						IF  iContador = 1 THEN
							LET vsNomProceso =  'RECAR'||TRIM(cNumCte_Ordenante)||'_BC.01';
							--LET vsNomProceso = 'RECARCHCOP_BCP.01';
							LET cTipoDomi = 'B';
						ELSE
							LET vsNomProceso =  'RECAR'||TRIM(cNumCte_Ordenante)||'_OB.01';
							--LET vsNomProceso = 'RECARCHCOP_OBA.01';
							LET cTipoDomi = 'D';
						END IF;
						LET vsNomArchivo = 'E' --CONSTANTE
										 || TRIM (cNumCte_Ordenante)
										 || cTipoDomi
										 || LPAD(DAY(vdtFecha),2,'0') || 	LPAD(MONTH(vdtFecha),2,'0') || SUBSTR(YEAR(vdtFecha)::CHAR(4),3,2) 
										 || '.'
										 || '01';					
					ELSE
						LET vsNomArchivo = TRIM(psNomArchivo);
						
						IF (SUBSTR(vsNomArchivo,11,1)) = 'B' THEN							
							LET vsNomProceso = 'RECAR'||SUBSTR(vsNomArchivo,2,9)||'_BC.'||SUBSTR(vsNomArchivo,19,2);
							--LET vsNomProceso = 'RECARCHCOP_BCP.'|| SUBSTR(vsNomArchivo,19,2);
						ELIF (SUBSTR(vsNomArchivo,11,1)) = 'D' THEN
							LET vsNomProceso = 'RECAR'||SUBSTR(vsNomArchivo,2,9)||'_OB.'||SUBSTR(vsNomArchivo,19,2);
							--LET vsNomProceso = 'RECARCHCOP_OBA.'|| SUBSTR(vsNomArchivo,19,2);
						END IF;
						LET iContador = 2;
					END IF;
				
					--VALIDA SI EXISTE REGISTRO CON EL MISMO PROCESO TERMINADO
					IF EXISTS(SELECT 1 FROM dom_procesos WHERE tipo_proceso = vsFlagTipoProceso AND cve_proceso = TRIM(vsNomProceso) AND fecha_proceso = vdtFecha AND estatus = '1') THEN
						LET vsCodRetorno = '02809';
						
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) 
						INTO vsCodRetorno2, vsMensaje_Respuesta;
						
						RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;
					ELIF EXISTS(SELECT 1 FROM dom_procesos WHERE tipo_proceso = vsFlagTipoProceso AND cve_proceso = TRIM(vsNomProceso) AND fecha_proceso = vdtFecha AND estatus = '0') THEN
						LET vsCodRetorno = '02810';
						
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) 
						INTO vsCodRetorno2, vsMensaje_Respuesta;
						
						RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;
					ELSE
						IF  SUBSTR(vsNomProceso,16,2) = 'BC' THEN
							LET cDesProceso = 'RECEP DE ARCHIVO DOMI CUENTAS BANCOPPEL, ORD: '|| TRIM(cNumCte_Ordenante);
						ELIF  SUBSTR(vsNomProceso,16,2) = 'OB' THEN
							LET cDesProceso = 'RECEP DE ARCHIVO DOMI CUENTAS OTROS BAN, ORD: '|| TRIM(cNumCte_Ordenante);
						END IF;
						/*IF  vsNomProceso = 'RECARCHCOP_BCP.'|| SUBSTR(vsNomArchivo,19,2) THEN
							LET cDesProceso = 'RECEP DE ARCHIVO DOMI CUENTAS BANCOPPEL';
						ELIF vsNomProceso = 'RECARCHCOP_OBA.'|| SUBSTR(vsNomArchivo,19,2) THEN
							LET cDesProceso = 'RECEP DE ARCHIVO DOMI CUENTAS OTROS BANCOS';
						END IF;*/

						EXECUTE PROCEDURE sp_domi_bitacora(vsFlagTipoProceso, vdtFecha, TRIM(vsNomProceso), cDesProceso, sPROCESANDO, '00000', psNumEmpleado, 'sp_domi_cop_receptor', vsNomArchivo, vsFecha_Presentacion, '11')
						INTO vsCodRetorno2;
						
						--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
						LET cDesProceso = 'Validacion de nombre de archivo';
						EXECUTE PROCEDURE bdidomi:sp_domi_cop_validarnombrearchivos('E', cNumCte_Ordenante, vsNomArchivo) 
						INTO vsCodRetorno;
										
						IF (vsCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK
							LET cDesProceso = 'Carga de archivo';
							EXECUTE PROCEDURE "informix".sp_domi_cargaarchivomanualproveedor(vsNomArchivo, cNumCte_Ordenante, psNumEmpleado)
							INTO  vsCodRetorno,vsMensaje_Respuesta, cCuentaAbono, iTotalAltas, mTotalImporteAltas,iTotalBajas,mTotalImporteBajas;
							
							IF (vsCodRetorno <> '00000') THEN  --VALIDA CARGA DE ARCHIVO 
								EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
								IF vsCodRetorno NOT IN ('99907') THEN
									EXECUTE PROCEDURE sp_domi_bitacora(vsFlagTipoProceso, vdtFecha, TRIM(vsNomProceso), TRIM(cDesProceso), sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_cop_receptor', vsNomArchivo, vsFecha_Presentacion, '11')
									INTO vsCodRetorno2;
								ELSE
									INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
									VALUES (CURRENT,CURRENT HOUR TO FRACTION, vsCodRetorno,vsNomArchivo,'sp_domi_cop_cargaarchivoproveedor',vsMensaje_Respuesta,psNumEmpleado,CURRENT);
								END IF;
								
								RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;
							ELSE
								EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
								
								EXECUTE PROCEDURE sp_domi_bitacora(vsFlagTipoProceso, vdtFecha, TRIM(vsNomProceso), TRIM(cDesProceso), sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_domi_cop_receptor', vsNomArchivo, vsFecha_Presentacion, '11')
								INTO vsCodRetorno2;

								RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;
							END IF;
						ELSE 						
							EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
							
							EXECUTE PROCEDURE sp_domi_bitacora(vsFlagTipoProceso, vdtFecha, TRIM(vsNomProceso), TRIM(cDesProceso), sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_cop_receptor', vsNomArchivo, vsFecha_Presentacion, '11')
							INTO vsCodRetorno2;
							
							RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;						
						END IF;
					END IF;
				END FOREACH;
			END WHILE;			
		ELSE -- PARAMETRO NO ENCONTRADO
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
								
			EXECUTE PROCEDURE sp_domi_bitacora(vsFlagTipoProceso, vdtFecha, TRIM(vsNomProceso), TRIM(cDesProceso), sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_cop_receptor', vsNomArchivo, vsFecha_Presentacion, '11')
			INTO vsCodRetorno2;
			
			RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta;
		END IF;				
	END
END PROCEDURE;