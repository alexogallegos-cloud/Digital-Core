CREATE PROCEDURE "informix".sp_domi_notificacion_estatus_cuentas_verificadas(
	p_sUserStatus CHAR(8), 			-- Usuario que inserta.
	p_sFolioActivacion CHAR(16), 	-- Folio de activacion.
	p_sNumCte CHAR(9),				-- Numero de cliente.
	p_sNumTarjetaCargo CHAR(16),	-- Numero de tarjeta de debito.
	p_sNumTarjetaAbono CHAR(16),	-- Numero de tarjeta de abono.
	p_sNombreCte1 CHAR(100),		-- Nombre del cliente.
	p_sApellidoCte1 CHAR(100),		-- Apellido del cliente.
	p_sCtaCargoX CHAR(4),			-- Ultimos 4 digitos del numero de tarjeta de debito.
	p_sCtaAbonoX CHAR(4),			-- Ultimos 4 digitos de la cuenta de credito.
	p_mImpMaximo DECIMAL(18,2),		-- Importe maximo permitido para domiciliar.
	p_sProductName CHAR(40),		-- Nombre del producto de credito.
	p_sCorreoElect CHAR(50),		-- Correo electronico del cliente.
	p_sProductShortName CHAR(20), 	-- Nombre corto del producto de credito.
	p_sNumTelefono CHAR(10),		-- Numero de telefono del cliente.
	p_iContrato INTEGER            -- Bandera que indica si el cliente cuenta con contrato.	
)
    RETURNING	CHAR(5) AS codRet;

    --DECLARACION DE VARIABLES
	DEFINE sql_err 				INTEGER;		-- Codigo de error SQL. 	 
	DEFINE v_sCodRet			CHAR(5);		-- Codigo de retorno del sp_domi_notificacion_estatus_cuenttas_verificadas.
	DEFINE v_sCodRet2			CHAR(5);		-- Codigo de retorno auxiliar para los SP's consumidos.
	DEFINE v_sMensajeRespuesta 	CHAR (110);		-- Mensaje de respuesta del sp_obtenermensajeerror.
    DEFINE v_sNumTarjeta        CHAR(20);		-- Numero de tarjeta de debito.
    DEFINE v_sCuentaCargo       CHAR(20);		-- Cuenta de debito.
    DEFINE v_sCausa_Rechazo     CHAR(3);		-- Causa de rechazo de la notificacion por parte de CECOBAN.
	DEFINE v_sContratoSms	    CHAR(20);		-- Contrato de la plantilla de SMS.
	DEFINE v_sContratoEmail     CHAR(20);		-- Contrato de la plantilla de EMAIL.
	DEFINE v_dFechaHoy	        DATE;           -- Fecha de hoy.																			 											 
    DEFINE cNEstatus            CHAR(2);        -- Estatus de los reintentos.
    DEFINE cJsonEntrada         LVARCHAR(1000); -- JSON de peticion de las notificaciones.  
  DEFINE dFechaRequest    DATETIME YEAR TO SECOND; -- Fecha de peticion.
	DEFINE v_generico1			CHAR(100);		-- Variable auxiliar (Vacia).
	DEFINE v_generico2			CHAR(100);		-- Variable auxiliar (Vacia).
	DEFINE v_generico3			CHAR(100);		-- Variable auxiliar (Vacia).
	DEFINE v_generico4			CHAR(100);		-- Variable auxiliar (Vacia).
	
	/******************************
	Proyecto:				Domiciliacion OB.
	Descripcion:			Se envian las notificaciones a las personas cuyas domiciliaciones fueron rechazadas por CECOBAN y se les cancela la domiciliacion.
	Dev:					Pedro Enrique Huicho Yocupicio.
	Fecha creacion:			16/08/2024 
	Respuesta esperada:		codRet: 00000

	******************************/

    --Inicializar Variables			
	LET sql_err 					= 0;		-- Codigo de error SQL.
	LET v_sCodRet 					= '00000';	-- Codigo de error del sp_domi_notificacion_estatus_cuentas_verificadas. 
	LET v_sCodRet2					= '00000';	-- Codigo de error auxiliar.	 
	LET v_sMensajeRespuesta			= '';		
	LET v_sContratoSms				= '';		
	LET v_generico1					= '';		
	LET v_generico2					= '';		
	LET v_generico3					= '';		
	LET v_generico4					= '';		

    --***************************************************************************************
    --SET DEBUG FILE TO "/tmp/sp_domi_notificacion_estatus_cuentas_verificadas.out";
	--TRACE ON;
	--***************************************************************************************    

    BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;

				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion), '', CURRENT);
				
				RETURN v_sCodRet;	
			END IF;
		END EXCEPTION;
	
        --VALIDA PARAMETROS DE ENTRADA
		IF NVL(p_sUserStatus, '') = '' THEN
			LET v_sCodRet = '88838'; -- PARAMETRO DE ENTRADA REQUERIDO ESTA EN BLANCO.
		
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, v_sMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion) || ' - ' || trim(v_sMensajeRespuesta), '', CURRENT);
			
			RETURN v_sCodRet;	
		END IF;
            
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO v_dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';

        -- Se obtienen los parametros de los contratos y plantillas de notificaciones.
        SELECT valor INTO v_sContratoEmail FROM bdidomi:"informix".dom_parametros WHERE cod_param = '61';																											 
        SELECT valor INTO v_sContratoSms FROM bdidomi:"informix".dom_parametros WHERE cod_param = '62';

        -- VERIFICAMOS SI EL CLIENTE YA CUENTA CON CONTRATO ACTIVO.
        IF p_iContrato = 1 THEN

            -- Se envia sms de que su tarjeta fue rechazada por CECOBAN y no se podr hacer el pago.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_TAR_RECH',p_sNumCte,
            '','','1','','','','','','','','','','','',p_sNumTelefono,0,0,0,0,0,'','') INTO v_sCodRet;

            -- Si ocurrio un error lo introducimos en la bitacora dom_errores.
            IF v_sCodRet <> '00000' THEN
                EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, v_sMensajeRespuesta;

                INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion) || ' - ' || trim(v_sMensajeRespuesta), '', CURRENT);          
            END IF;

            -- Se envia correo de que su domiciliacion fue cancelada.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',v_sContratoEmail,'DOM_CAN', p_sNumCte, 
            p_sCtaCargoX, p_sNumTarjetaCargo,'1',p_sCtaAbonoX,p_sCtaCargoX, p_sCtaAbonoX, p_mImpMaximo,p_sProductName, 
            p_sFolioActivacion, TODAY,'','','',p_sCorreoElect,'',0,0,0,0,0, CURRENT,'') INTO v_sCodRet;

            -- Si ocurrio un error lo introducimos en la bitacora dom_errores.
            IF v_sCodRet <> '00000' THEN
                EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, v_sMensajeRespuesta;

                INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion) || ' - ' || trim(v_sMensajeRespuesta), '', CURRENT);
            END IF;

            -- Se envia sms de que su domiciliacion fue cancelada.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_CANCELA',p_sNumCte,'','',
            '1','',p_sFolioActivacion,'','','','',p_sCtaAbonoX,TO_CHAR(v_dFechaHoy, '%d/%m'),
            p_sProductShortName,'','',p_sNumTelefono, 0,0,0,0,0,'','') INTO v_sCodRet;

            -- Si ocurrio un error lo introducimos en la bitacora dom_errores.
            IF v_sCodRet <> '00000' THEN
                EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, v_sMensajeRespuesta;

                INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion) || ' - ' || trim(v_sMensajeRespuesta), '', CURRENT);
            END IF;

        ELSE
            -- SE ENVIA NOTIFICACION DE SMS DE QUE SU DOMICILIACION FUE RECHAZADA POR CECOBAN.
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',v_sContratoSms,'DOM_ALT_NOEX',p_sNumCte,
            '','','1','','','','','','','','','','','',p_sNumTelefono,0,0,0,0,0,'','') INTO v_sCodRet;	

            -- Si ocurrio un error lo introducimos en la bitacora dom_errores.
            IF v_sCodRet <> '00000' THEN
                EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO v_sCodRet2, v_sMensajeRespuesta;

                INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet2, '', 'sp_domi_notificacion_estatus_cuentas_verificadas', trim(p_sFolioActivacion) || ' - ' || trim(v_sMensajeRespuesta), '', CURRENT);
            END IF;	
											 
        END IF;

		RETURN v_sCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR:         Derian Alejandro Sainz Zazueta',
'DESCRIPCION:   Se envian las notificaciones a las personas cuyas domiciliaciones fueron. rechazadas por CECOBAN.',
'FECHA:         15/01/2024',
'BD:            BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_cop_generaarchivo(cNombreArchivo CHAR(20), cIdRuta CHAR(2))
RETURNING CHAR(5) AS codret;

	DEFINE viSqlErr 		INTEGER;
	DEFINE cRuta 			CHAR(100);
	DEFINE vsCodRet			CHAR(5);
	DEFINE vsSQL 			CHAR(2204);
	DEFINE vsSQL1 			CHAR(100);
	DEFINE vsSQL2 			CHAR(2004);
	DEFINE vsSQL3 			CHAR(100);
	DEFINE vsArchTemp 		CHAR(23);
	DEFINE vsArchTemp1 		CHAR(23);
	DEFINE vsUsoFutBanc 	CHAR(12);
	DEFINE cHora			CHAR(8);
	DEFINE cFechaArchivoOUT	CHAR(15);
	DEFINE iPaso			SMALLINT;
	DEFINE cRutaIfx 		CHAR(100);
	DEFINE cMensaje			VARCHAR(40);
	DEFINE cFechaCargo		CHAR(8);
	DEFINE iRechazadosImp	INTEGER;
	DEFINE iTotalMovtos		INTEGER;
	DEFINE iConsecutivo		INTEGER;
	DEFINE cConsecutivo		CHAR(6);
	DEFINE cTipoReg			CHAR(1); 
	--DEFINE cConsecuti       CHAR(6); 
	DEFINE cFechaCarg       CHAR(8); 
	DEFINE cFechaAbo        CHAR(8); 
	DEFINE cTpoCtaCar       CHAR(2); 
	DEFINE cCveBanCar       CHAR(3); 
	DEFINE cCtaCargo        CHAR(20);
	DEFINE cRfcCargo        CHAR(13);
	DEFINE cNomCargo        CHAR(50);
	DEFINE cCtaAbono        CHAR(20);
	DEFINE cImpOper         CHAR(15);
	DEFINE cImpIva          CHAR(15);
	DEFINE cRefNume         CHAR(7);
	DEFINE cRefLeyen        CHAR(40);
	DEFINE cRefServ         CHAR(40);
	DEFINE cRefTitServ		CHAR(40);
	DEFINE cRefTitSer       CHAR(40);
	DEFINE cAccion          CHAR(1);
	DEFINE cReintCta        CHAR(1); 
	DEFINE cEstatus         CHAR(2); 
	DEFINE cCausaRech       CHAR(50);
	DEFINE iContador		INTEGER;
	DEFINE numcte_tdc       CHAR(9);

	--INICIALIZACION DE VARIABLES
	LET viSqlErr 			= 0;
	LET cRuta 				= '';
	LET vsCodRet 			= '';
	LET vsSQL 				= '';
	LET vsSQL1 				= '';
	LET vsSQL2 				= '';
	LET vsSQL3 				= '';
	LET vsArchTemp 			= '';
	LET vsArchTemp1 		= '';
	LET vsUsoFutBanc 		= '';
	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	LET cRutaIfx 			= '';
	LET cMensaje 			= 'ERROR EN PASO: ';
	LET cFechaCargo 		= '';
	LET iRechazadosImp		= 0;
	LET iTotalMovtos		= 0;
	LET iConsecutivo		= 0;
	LET cConsecutivo		= '';
	LET cTipoReg			= '';
	--LET cConsecuti          = '';
	LET cFechaCarg          = '';
	LET cFechaAbo           = '';
	LET cTpoCtaCar          = '';
	LET cCveBanCar          = '';
	LET cCtaCargo           = '';
	LET cRfcCargo           = '';
	LET cNomCargo           = '';
	LET cCtaAbono           = '';
	LET cImpOper            = '';
	LET cImpIva             = '';
	LET cRefNume            = '';
	LET cRefLeyen           = '';
	LET cRefServ            = '';
	LET cRefTitServ			= '';
	LET cRefTitSer          = '';
	LET cAccion             = '';
	LET cReintCta           = '';
	LET cEstatus            = '';
	LET cCausaRech          = '';
	LET iContador           = 0;
	LET numcte_tdc          = '';
	

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_cop_generaarchivo.out";
	--TRACE ON;
	
BEGIN


	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
		IF viSqlErr <> 0 THEN
		
			INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
			VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,cNombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);	
		
		RETURN viSqlErr;
	END IF;		
	END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET viSqlErr	
	
		INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
		VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,cNombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);
			
	IF iPaso NOT IN(7,8,9) THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet;
	END IF;
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ; 
	SET LOCK MODE TO WAIT 3;

	SELECT valor 
	INTO cRutaIfx
	FROM dom_parametros WHERE cod_param = '44';

	SELECT valor
	INTO numcte_tdc 
	FROM dom_parametros WHERE cod_param = '36';
	
	IF (cRutaIfx IS NULL) OR (cRutaIfx = "")THEN
		--DESARROLLO
		--LET cRutaIfx = '/informix/bin/dbaccess';
		--PRODUCCION
		LET cRutaIfx = '/ifxsif01/bin/dbaccess';
		
		--EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02400") INTO v_cod_ret, sDescMensajeError;
		--RETURN v_cod_ret, sDescMensajeError;
	END IF;

	
	--Se le quitan espacion en blanco a nombre de archivo
	LET cNombreArchivo = TRIM(cNombreArchivo);
	
	TRUNCATE TABLE tmp_archivo;
	SELECT COUNT (*) INTO iContador FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo;
	
		IF iContador > 0 THEN
	
			SELECT valor INTO cRuta FROM bdidomi:dom_parametros WHERE cod_param = cIdRuta;

			IF cRuta IS NOT NULL THEN
			--Selecciona el repositorio del archivo a generar.
			
				--Genera archivo.
				LET vsArchTemp = cFechaArchivoOUT||'tmp1.txt';
				LET vsArchTemp1 = cFechaArchivoOUT||'tmp2.txt';
			
				--VALIDA SI ES ARCHIVO DE OTROS BANCOS
				IF SUBSTR(cNombreArchivo, 11, 1) = 'D' AND SUBSTR(cNombreArchivo,2,9) != numcte_tdc  THEN
						SELECT LIMIT 1 fecha_cargo
						INTO cFechaCargo FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo;
						
							--Conteo operaciones rechazadas
						SELECT COUNT(*) 
						INTO iTotalMovtos FROM bdidomi:dom_cte_detalle WHERE fecha_cargo = cFechaCargo
						AND	tipo_registro_cce = '02' AND estatus = '02' AND comision_cobrada IS NULL AND iva_cobrado IS NULL AND SUBSTR(nombre_arch,2,9) != numcte_tdc;
						 
							
						LET iPaso = 1;
						INSERT INTO tmp_archivo ( id, rec )
						SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || LPAD(num_operaciones::INTEGER + iTotalMovtos, 8, '0') || fecha_inicial || fecha_final ||'|') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo;	
						--NORMAL
						LET iPaso = 2;
						INSERT INTO tmp_archivo ( id, rec )
					    SELECT 2 AS id,(tipo_registro||consecutivo||fecha_cargo ||fecha_abono ||tipo_cta_cargo ||cve_banco_cargo ||cuenta_cargo ||rfc_cargo ||
						nombre_cargo ||cuenta_abono||imp_operacion||imp_iva||ref_numerica||ref_leyenda||ref_servicio||ref_titular_serv||accion||
						reintentar_cuenta||estatus||causa_rechazo||'|') AS rec
						FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo;
	
						LET iTotalMovtos = 0;

						SELECT COUNT(*) INTO iConsecutivo FROM tmp_archivo WHERE id = 2;

							FOREACH
								SELECT tipo_registro, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo,
								nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion,
								reintentar_cuenta, estatus, causa_rechazo
								INTO cTipoReg, cFechaCarg, cFechaAbo, cTpoCtaCar, cCveBanCar, cCtaCargo, cRfcCargo, cNomCargo, cCtaAbono,
								cImpOper, cImpIva, cRefNume, cRefLeyen, cRefServ, cRefTitServ, cAccion, cReintCta, cEstatus, cCausaRech
								FROM bdidomi:dom_cte_detalle WHERE fecha_cargo = cFechaCargo
								AND tipo_registro_cce = '02' AND estatus = '02' AND comision_cobrada IS NULL AND iva_cobrado IS NULL  AND SUBSTR(nombre_arch,2,9) != numcte_tdc
									
								LET iTotalMovtos = iTotalMovtos + 1;
								
								LET cConsecutivo = LPAD(iConsecutivo + iTotalMovtos, 6, '0');

								INSERT INTO tmp_archivo( id, rec ) 
								   VALUES( 2, cTipoReg || cConsecutivo ||cFechaCarg ||cFechaAbo ||cTpoCtaCar ||cCveBanCar ||cCtaCargo ||cRfcCargo ||
										cNomCargo ||cCtaAbono ||cImpOper ||cImpIva ||cRefNume ||cRefLeyen ||cRefServ ||cRefTitServ ||cAccion ||
										cReintCta ||cEstatus ||cCausaRech ||'|');


								LET iRechazadosImp = iRechazadosImp + cImpOper;
									
							END FOREACH;

						--NORMAL
						INSERT INTO tmp_archivo ( id, rec )
                        SELECT 3 AS id, (tipo_registro||LPAD(num_operaciones::INTEGER + iTotalMovtos, 8, '0')||LPAD(imp_operaciones::INTEGER + iRechazadosImp, 18, '0')||num_oper_pend||imp_oper_pend||
							   num_oper_apli||imp_oper_apli||LPAD(num_oper_rech::INTEGER + iTotalMovtos, 8 , '0')||LPAD(imp_oper_rech::INTEGER + iRechazadosImp, 18, '0') ||
							   --'                                                                                                                                                                                                                                             |' ) AS rec
							   '|' ) AS rec
						FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombreArchivo;
						
				ELSE
				--ARCHIVO BANCOPPEL
					LET iPaso = 3;
					INSERT INTO tmp_archivo
					SELECT id, rec
					FROM 
                    TABLE(MULTISET(
					--SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || num_operaciones || fecha_inicial || fecha_final ||'                                                                                                                                                                                                                                                                                     |') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo
					SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || num_operaciones || fecha_inicial || fecha_final ||'|') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo
                    UNION 
					SELECT 2 AS id,(tipo_registro||consecutivo||fecha_cargo ||fecha_abono ||tipo_cta_cargo ||cve_banco_cargo ||cuenta_cargo ||rfc_cargo ||
						   nombre_cargo ||cuenta_abono||imp_operacion||imp_iva||ref_numerica||ref_leyenda||ref_servicio||ref_titular_serv||accion||
						   reintentar_cuenta||estatus||causa_rechazo||'|') AS rec
					FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo
					UNION 
					SELECT 3 AS id, (tipo_registro||num_operaciones||imp_operaciones||num_oper_pend||imp_oper_pend||
						   num_oper_apli||imp_oper_apli||num_oper_rech||imp_oper_rech||
						   --'                                                                                                                                                                                                                                             |' ) AS rec
						   '|' ) AS rec
					FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombreArchivo));
					
				END IF;	
		
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (vsArchTemp) || ' DELIMITER ' || ''']''';
				LET vsSQL2 = ' SELECT rec FROM tmp_archivo ORDER BY rowid';

				LET vsSQL3 = ' " > '|| TRIM(cRuta) || cFechaArchivoOUT||'.sql';
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;	
				--Verifica que no este vacia la consulta.
				IF ( vsSQL <> '' ) THEN
					SYSTEM TRIM(vsSQL);
					
					LET iPaso = 4;
					--Permiso para la creacion de archivo.					
					LET vsSQL = TRIM(cRutaIfx)||' bdidomi ' || TRIM(cRuta) || cFechaArchivoOUT||'.sql > '||TRIM(cRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					SYSTEM vsSQL;
					
					LET iPaso = 5;				
					--Elimina el caracter delimitador '?'.
					LET vsSQL =  "sed 's/]$//g' " || TRIM(cRuta) || TRIM (vsArchTemp) || " > " || TRIM(cRuta) || TRIM (vsArchTemp1);
					SYSTEM vsSQL;


					LET iPaso = 6;
					--Elimina el caracter delimitador 'x'.				
					LET vsSQL =  "sed 's/|$//g' " || TRIM(cRuta) || TRIM (vsArchTemp1) || " > " || TRIM(cRuta) || TRIM (cNombreArchivo);
					SYSTEM vsSQL;
					
					LET iPaso = 7;
					--Operacion exitosa "Archivo Generado".
					--se dan permiso a todos para el archivo 
					LET vsSQL = 'chmod 755 ' || TRIM(cRuta) || TRIM (cNombreArchivo);
					SYSTEM vsSQL ;
					
					LET iPaso = 8;
					--Borra el archivo temporal.
					LET vsSQL = 'rm ' || TRIM(cRuta) || TRIM(vsArchTemp);
					SYSTEM vsSQL;
					
					LET iPaso = 9;
					--Borra el archivo temporal1.				
					LET vsSQL = 'rm ' || TRIM(cRuta) || TRIM(vsArchTemp1);
					SYSTEM vsSQL;
					
					LET iPaso =10;	
					--Borra el archivo de control.
					LET vsSQL = 'rm ' || TRIM(cRuta) || cFechaArchivoOUT||'.sql';
					SYSTEM vsSQL;
					
					LET iPaso = 11;	
					--Borra el archivo .out
					LET vsSQL = 'rm ' ||TRIM(cRuta)||TRIM(cFechaArchivoOUT)||'.out';
					SYSTEM vsSQL;
					
					LET iPaso = 12;	
					--LET vsSQL = 'cp ' || TRIM(cRuta) || TRIM (cNombreArchivo)  ||' '|| TRIM(cRuta)|| TRIM (cNombreArchivo)  ||'.resp';
					--SYSTEM vsSQL;	
					
					--Borrar diagonales del archivo.
					--LET vsSQL = 'grep -lr -e "1" ' || TRIM(cRuta) || TRIM (cNombreArchivo)  ||'.resp | xargs sed ''s/\\\\/\\/g'' > '|| TRIM(cRuta) || 
					--TRIM (cNombreArchivo);
					--SYSTEM vsSQL;
					
					--LET vsSQL = '';
					--LET vsSQL = 'rm '|| TRIM(cRuta) || TRIM (cNombreArchivo)  ||'.resp';
					--SYSTEM vsSQL;
					
					LET vsCodRet = '00000';
				ELSE
					--No fue posible generar el archivo.
					LET vsCodRet = '01002';
				END IF;
			ELSE
			--El Id proporcionado no fue localizado.
			LET vsCodRet = '01001';
			END IF;
		ELSE
			--El nombre del archivo proporcionado no fue localizado.
			LET vsCodRet = '01000';
		END IF;

		RETURN vsCodRet;

END;
END PROCEDURE;