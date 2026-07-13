CREATE PROCEDURE "informix".sp_domi_valida_respuesta_alta_cecoban_ob(
	pUsuario CHAR(20), 			-- Usuario que inserta.
	pOpcion CHAR(10), 			-- Opcion del proceso.
	p_sGenerico1 NVARCHAR(254), -- Folio de activacion / rango fecha 1.
	p_sGenerico2 NVARCHAR(254), -- Numero de cliente / rango fecha 2.
	p_sGenerico3 NVARCHAR(254), -- Numero de tarjeta de debito.
	p_sGenerico4 NVARCHAR(254), -- Parametro vacio, por solicitud del bus.
	p_sGenerico5 NVARCHAR(254)	-- Parametro vacio, por solicitud del bus.
)
    RETURNING 	NVARCHAR(254) AS v_generico1, 	-- Codigo de retorno.
				NVARCHAR(254) AS v_generico2,	-- Correo electronico del cliente.
				NVARCHAR(254) AS v_generico3,	-- Numero de telefono.
				NVARCHAR(254) AS v_generico4,	-- Folio de activacion.
				NVARCHAR(254) AS v_generico5, 	-- Nombres del cliente.
				NVARCHAR(254) AS v_generico6,	-- Apellidos del cliente.
				NVARCHAR(254) AS v_generico7,  	-- Accion de la domiciliacion ('A' -> Alta | 'B' -> Baja).
				NVARCHAR(254) AS v_generico8,	-- Nombre corto del producto de credito.
				NVARCHAR(254) AS v_generico9,	-- Nombre del producto de credito.
				NVARCHAR(254) AS v_generico10,	-- Numero de cliente.
				NVARCHAR(254) AS v_generico11,	-- Numero de tarjeta de debito.
				NVARCHAR(254) AS v_generico12,	-- Cuenta de credito.
				NVARCHAR(254) AS v_generico13,	-- Importe maximo a pagar.
				NVARCHAR(254) AS v_generico14,	-- Fecha de pago.
				NVARCHAR(254) AS v_generico15;	-- Importe a pagar.

	--DECLARACION DE VARIABLES
	DEFINE sql_err				INTEGER; 		-- Error SLQ.
	DEFINE v_sCodRet			CHAR(5);		-- Codigo de retorno de sp_domi_valida_respuesta_alta_cecoban_ob.
	DEFINE cFolioActivacion		CHAR(25);		-- Folio de activacion.
	DEFINE cNumcte				CHAR(20);		-- Numero de cliente.
	DEFINE cEstatus				CHAR(02);		-- Estatus de la domiciliacion.
    DEFINE cContrato            INTEGER;        -- Bandera que indica si el registro ya tiene contrato activo.
	DEFINE cNombreArch			CHAR(20);		-- Nombre del archivo.
    DEFINE dFechaAnt            DATE;           -- Fecha del dia anterior habil.
    DEFINE dFechaHoy            DATE;           -- Fecha del dia de hoy.
    DEFINE dFechaHabil          DATE;           -- Fecha habil(Variable auxiliar).
	DEFINE dFechaAux            DATE;           -- Fecha Auxiliar.
	DEFINE cTipoCuentaCargo		CHAR(02);		-- Tipo de cuenta de debito.
	DEFINE cCuentaCargo			CHAR(20);		-- Cuenta de debito.
	DEFINE cCuentaCargoX		CHAR(4);		-- Ultimos 4 digitos de la tarjeta de debito.
	DEFINE cNombreCargo			CHAR(40);		-- Nombre del titular de la cuenta de debito.
	DEFINE cCuentaAbono			CHAR(20);		-- Cuenta de credito.
	DEFINE cCuentaAbonoX		CHAR(4);		-- Ultimos 4 digitos de la cuenta de credito.
	DEFINE cImporte				CHAR(15);		-- Importe a pagar.
	DEFINE cRefLeyenda			CHAR(50);		-- Referencia leyenda.
	DEFINE cRefTitular        	CHAR(30);		-- Referencia del titular.
	DEFINE cAccion				CHAR(01);		-- Accion de la domiciliacion ( 'A' -> Alta | 'B' -> Baja ).
	DEFINE cTipoCuentaAbono		CHAR(02);		-- Tipo de cuenta de credito.
	DEFINE cNombre1Cte			CHAR(200);		-- Nombre 1 del cliente.
	DEFINE cNombre2Cte			CHAR(200);		-- Nombre 2 del cliente.
	DEFINE cApellido1Cte		CHAR(200);		-- Apellido 1 del cliente.
	DEFINE cApellido2Cte 		CHAR(200);		-- Apellido 2 del cliente.
	DEFINE cRfc					CHAR(13);		-- Rfc del cliente.
	DEFINE cNumTelefono			CHAR(13); 		-- Numero de telefono del cliente.
	DEFINE cCorreoElect    		CHAR(100);		-- Correo electronico del cliente.
	DEFINE cImporteMaximo		DECIMAL(18,2);	-- Importe maximo permitido para domiciliar.
	DEFINE cNombreProductoCorto	CHAR(20);		-- Nombre corto del producto de credito.
	DEFINE cNombreProducto		CHAR(40);		-- Nombre del producto de credito.
	DEFINE cDiaPago             CHAR(2);		-- Dia de pago.
	DEFINE cNombres				VARCHAR(250);	-- Nombres del cliente.
	DEFINE cApellidos			VARCHAR(250);	-- Apellidos del cliente.
	DEFINE cCausaRechazo		CHAR(150);		-- Causa rechazo de cecoban.
	DEFINE cMotivoDev			CHAR(2);		-- Motivo de porque CECOBAN rechazo la cuenta de debito.
    DEFINE cNEstatus            CHAR(2);    -- Estatus de dom_motrechacecoban.
	DEFINE cCodret2				CHAR(5);		-- Codigo de retorno auxiliar para los SP's consumidos.
	DEFINE cMensajeRespuesta	CHAR(150);		-- Mensaje de respuesta del sp_obtenermensajeerror.
	DEFINE cInTransaction	 	CHAR(1);  		-- Variable para indicar si existe una transaccion en curso.
    DEFINE cTipoPago            CHAR(1);        -- Tipo de pago.
    DEFINE cNombreBanco         NVARCHAR(60);   -- Nombre del banco.
    DEFINE dFechaProximoPago    DATE;           -- Fecha del proximo pago calculado.
    DEFINE v_generico1          NVARCHAR(100);  -- Campo generico.
    DEFINE v_generico2          NVARCHAR(100);  -- Campo generico.
    DEFINE v_generico3          NVARCHAR(100);  -- Campo generico.
    DEFINE v_generico4          NVARCHAR(100);  -- Campo generico.

	/******************************
	Proyecto:				Domiciliacion OB.
	Descripcion:			Se obtiene la informacion de las cuentas que fueron aceptadas por cecoban, para posteriormente activar
							activar los estatus en las tablas dom_cuentas_ob y dom_activacion_domiciliacion_ob y enviar la informacion
							al motor para generar y/o enviar el contrato.
	Dev:					Pedro Enrique Huicho Yocupicio.
	Fecha creacion:			21/03/2024
	Respuesta esperada:		cCodret: 00000

	******************************/

	LET v_sCodRet				='00000';
	LET cCodret2				='00000';
	LET sql_err 				= 0;
	LET cDiaPago				= '';
	LET cFolioActivacion		= '';
	LET cNumcte					= '';
	LET cEstatus			    = '';
	LET cNombreArch		        = '';
	LET cTipoCuentaCargo	    = '';
	LET cCuentaCargo		    = '';
	LET cCuentaCargoX		    = '';
	LET cNombreCargo		    = '';
	LET cCuentaAbono		    = '';
	LET cCuentaAbonoX		    = '';
	LET cImporte			    = '';
	LET cRefLeyenda		        = '';
	LET cRefTitular             = '';
	LET cAccion			        = 'A';
	LET cTipoCuentaAbono	    = '';
	LET cNombre1Cte		        = '';
	LET cNombre2Cte		        = '';
	LET cApellido1Cte	        = '';
	LET cApellido2Cte 	        = '';
	LET cRfc				    = '';
	LET cNumTelefono		    = '';
	LET cCorreoElect            = '';
	LET	cImporteMaximo			= 0;
	LET cNombreProductoCorto	= '';
	LET cNombreProducto			= '';
	LET cNombres				= '';
	LET cApellidos				= '';
	LET cCausaRechazo			= '';
	LET cMotivoDev				= '';
	LET cMensajeRespuesta		= '';
	LET cInTransaction      	= 'N';
	LET dFechaHoy               = CURRENT;
	let dFechaAnt               = CURRENT;
	let dFechaHabil             = CURRENT;
	let dFechaAux               = CURRENT;
	let dFechaProximoPago       = '';

	--***************************************************************************************
    --SET DEBUG FILE TO '/tmp/sp_domi_bitacora.out';
    --TRACE ON;
	--***************************************************************************************

	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN

				LET v_sCodRet = sql_err;

				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_valida_respuesta_alta_cecoban_ob_v1', trim(cNumcte), '',CURRENT);

				RETURN v_sCodRet, 'NULL', cNumTelefono,cFolioActivacion, cNombres, cApellidos, cAccion, cNombreProductoCorto, cNombreProductoCorto, '',
				cCuentaCargo, cCuentaAbono, cImporteMaximo, cDiaPago||'#'||dFechaProximoPago, cImporte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;

		IF (pOpcion = '' OR pUsuario = '') THEN
			--paramtro de entrada vacio
			LET v_sCodRet =  '88831';

			RETURN v_sCodRet, 'NULL', cNumTelefono,cFolioActivacion, cNombres, cApellidos, '', cNombreProductoCorto, cNombreProductoCorto, '',
			cCuentaCargo, cCuentaAbono, cImporteMaximo, cDiaPago||'#'||dFechaProximoPago, cImporte;
		END IF;

		IF pOpcion = '01' THEN
      
            SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = '001';
      
			EXECUTE PROCEDURE bdidomi:"informix".sp_valferiadobanca('001', dfechahoy, 0, 'V')
			INTO v_scodret, dFechaHabil;
			IF v_scodret <> '00000' THEN
				return v_scodret, 'Dia Inhabil', '','', '', '',
					'', '', '', '',
					'', '','', '', '';
			END IF;

			EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtener_fecha_valida_ob(dFechaHoy ) 
			INTO dFechaAux, dFechaHabil, dFechaAnt;


			FOREACH WITH HOLD

				--01[activo], 02[inactivo],03[Pendiente de validacion cecoban]
				--validar las domiciliaciones que aun no han sido procesadas o validadas por cecoban

				-- DOMICILIACIONES PENDIENTES DE ACTIVACION Y QUE LAS CUENTAS DE CARGO YA FUERON VERIFICADAS POR CECOBAN CON UN ESTATUS VALIDO Y CORRECTO
				SELECT DISTINCT
                d_archivom.nombre_arch, d_aut.folio_activacion, TO_CHAR(d_aut.imp_maximo) imp_maximo, act_ob.estatus, act_ob.num_cte,
				TO_CHAR((f_pago.fecha_pago),'%d'), (d_archivom.imp_operacion/100)::INTEGER, d_archivom.cuenta_cargo, d_archivom.cuenta_abono,
				SUBSTR(d_archivom.cuenta_cargo, 17, 4) as tarjeta_cargo_x, SUBSTR(d_archivom.cuenta_abono, 17, 4) as cuenta_credito_x,
				act_ob.contrato, d_aut.cve_domiciliar_tc, d_ctas_ob.concepto, f_pago.fecha_prox_pago
				INTO
                cNombreArch, cFolioActivacion, cImporteMaximo, cEstatus ,cNumcte, cDiaPago, cImporte, cCuentaCargo, cCuentaAbono,
				cCuentaCargoX, cCuentaAbonoX, cContrato, cTipoPago, cNombreBanco, dFechaProximoPago
				FROM bdidomi:"informix".dom_autorizaciones d_aut
				INNER JOIN bdidomi:"informix".dom_archivomanual as d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion and d_archivom.estatus = 'EP' and d_archivom.tipo_domi = '02'
                INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob as act_ob ON act_ob.folio_activacion = d_aut.folio_activacion and act_ob.estatus IN ('03','01')
                INNER JOIN bdidomi:"informix".dom_fecha_pago as f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
				INNER JOIN bdidomi:"informix".dom_pago as d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
                INNER JOIN bdidomi:"informix".dom_cuentas_ob as d_ctas_ob ON LPAD(TRIM(num_tarjeta), '20','0')  = d_archivom.cuenta_cargo
                WHERE d_aut.cve_estatus = '01'
                AND act_ob.contrato IN ('0','1')
                AND act_ob.intentos_cobro IN('0','3','6')
                AND d_ctas_ob.estatus IN('03','01')
                AND d_archivom.fecha_envio = dFechaAnt

				--CONSULTAR LOS DATOS DEL CLIENTE
				SELECT numcte, TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno), TRIM(apell_materno), rfc
				INTO cNumCte, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = cNumcte
				AND empresa = '001';

				LET cNombres = TRIM(cNombre1Cte) || ' ' || TRIM(cNombre2Cte);
				LET cApellidos = TRIM(cApellido1Cte) || ' ' || TRIM(cApellido2Cte);

				SELECT telefono
				INTO cNumTelefono
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte= cNumcte
				AND status_tel = 'A'
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumcte AND status_tel = 'A' AND tipo_tel = 2)
				AND tipo_tel = 2
				AND empresa = '001';

				SELECT correo_elec
				INTO cCorreoElect
				FROM bdinteg:"informix".si_correos
				WHERE numcte= cNumcte
				AND tipo_correo = 1
				AND status_correo = 'A'
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = cNumcte AND status_correo = 'A' AND tipo_correo = 1)
				AND empresa = '001';

				--datos del credito
				SELECT g.nombre_corto, g.descripcion
				INTO cNombreProductoCorto, cNombreProducto
				FROM bdicred:"informix".sd_tarjeta f
				INNER JOIN bdicred:"informix".sd_maecred e ON e.num_credito = f.num_credito
				INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc g 	ON e.num_producto = g.cve_producto
				WHERE f.num_tarjeta = SUBSTR(TRIM(cCuentaAbono), 5, 16)
				AND f.status_tar <> 'C';

                -- Verificamos la informacion de respuesta de CECOBAN.
                SELECT COALESCE(motivo_dev, '99')
                INTO cmotivodev
                FROM bdidomi:"informix".dom_ctas_verificadas as ctas_verif
                WHERE ctas_verif.cuenta = ccuentacargo
                AND ctas_verif.nombre_arch = 'S01137A2.A11'|| to_char(dfechahoy,'%d') ||'98'
                AND ctas_verif.fecha_presentacion = to_char(dfechahoy,'%Y%m%d');
                
                -- Si CECOBAN no responde, entonces de igual forma activamos la domiciliacion.
                LET cMotivoDev = COALESCE(cMotivoDev, '99');

				-- Verificamos si CECOBAN rechazo la cuenta de debito.
				IF NVL(cFolioActivacion,'') != '' AND NVL(cMotivoDev,'') != '99' THEN
                    
                    -- Extraemos el tipo de estatus de la tabla dom_motrechacecoban.
                    SELECT estatus_domi
                    INTO cNEstatus
                    FROM bdidomi:"informix".dom_motrechacecoban_to_cuentasob
                    WHERE movdev = cMotivoDev;

                    -- Se cancela la domiciliacion por parte de BanCoppel.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus(cFolioActivacion, pUsuario, '02', '', '', '', '', '', '','')
                    INTO v_sCodRet, v_generico1, v_generico2, v_generico3, v_generico4;

                    IF v_sCodRet != '00000' THEN
                        --Obtenemos los datos del error ocurrido.
                        EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                        --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
                        INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                        VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_valida_respuesta_alta_cecoban_ob', trim(cFolioActivacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
                    END IF;

                    -- Actualiza el registro de la tabla archivo manual.
                    UPDATE bdidomi:"informix".dom_archivomanual 
                    SET accion = 'B'
                    WHERE folio_activacion = cFolioActivacion 
                    AND accion = 'A'
                    AND estatus = 'EP';

                    -- Actualizamos las tablas dom_cuentas_ob y dom_activacion_domiciliacion_ob.
                    UPDATE bdidomi:"informix".dom_cuentas_ob 
                    SET estatus = cNEstatus, fecha_update = current , user_update = pUsuario
                    WHERE num_cliente = cNumCte
                    AND num_tarjeta = SUBSTR(TRIM(cCuentaCargo), 5, 16)
                    AND estatus IN ('01','03');

                    -- Validamos si el cNEstatus es reintentable (04) para incrementarle un intento.
                    IF cNEstatus = '04' THEN
                        UPDATE bdidomi:"informix".dom_cuentas_ob    
                        SET intentos = (
                            SELECT MAX(intentos) + 1 
                            FROM bdidomi:"informix".dom_cuentas_ob 
                            WHERE num_cliente = cNumCte 
                            AND num_tarjeta = SUBSTR(TRIM(cCuentaCargo), 5, 16)
                            AND estatus = '04'
                        )
                        WHERE num_cliente = cNumCte 
                        AND num_tarjeta = SUBSTR(TRIM(cCuentaCargo), 5, 16)
                        AND estatus = '04';
                    END IF;

                    UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob 
                    SET estatus = '02'
                    WHERE folio_activacion = cFolioActivacion 
                    AND estatus IN ('01','03');		

                    --Almacena los datos en la tabla bdidomi:dom_cancelaciones.
                    INSERT INTO bdidomi:"informix".dom_cancelaciones(folio_activacion, folio_cancelacion, motivo, user_insert, fecha_insert)
                    VALUES(cFolioActivacion, 'C' || cFolioActivacion, 'CECOBAN RECHAZO LA TARJETA DE DEBITO', pUsuario, CURRENT::DATE);

					-- Enviamos notificacion de que la cuenta fue rechazada por CECOBAN.
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_notificacion_estatus_cuentas_verificadas(pUsuario, cFolioActivacion, cNumcte,
					SUBSTR(TRIM(cCuentaCargo), 5, 16), SUBSTR(TRIM(cCuentaAbono), 5, 16), cNombre1Cte, cApellido1Cte, cCuentaCargoX, cCuentaAbonoX, 
                    cImporteMaximo, cNombreProducto, cCorreoElect, cNombreProductoCorto, cNumTelefono, cContrato) INTO cCodret2;

                    IF cCodret2 != '00000' THEN

                        LET v_sCodRet = cCodret2;
                       
                        EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret2) INTO cCodret2, cMensajeRespuesta;
	
                        INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                        VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_valida_respuesta_alta_cecoban_ob', trim(cFolioActivacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
                    END IF;

					LET v_sCodRet = cCodret2;

					CONTINUE FOREACH;
				END IF;

                -- Si el cliente ya cuenta con contrato activo no cambiamos estatus y continuamos al siguiente registro.
                IF cContrato = '1' THEN
                    CONTINUE FOREACH;
                END IF;

				-- Cambiamos los estatus de pendiente a activo en las tablas dom_cuentas_ob y dom_activacion_domiciliacion_ob.
				UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
				SET estatus = '01', contrato = '1', procesado = '2' -- estatus activo
				WHERE folio_activacion = cFolioActivacion;

				UPDATE dom_cuentas_ob
				SET estatus = '01', fecha_update = current , user_update = pUsuario
				WHERE num_cliente = cNumcte and num_tarjeta = SUBSTR(TRIM(cCuentaCargo), 5, 16);

				--se envian cuentas con estatus pendientes y con cuentas verificadas
				RETURN v_sCodRet, cCorreoElect, cNumTelefono,cFolioActivacion, cNombres, cApellidos, cAccion, cNombreProductoCorto, cNombreProducto, cNumcte||'#'||cTipoPago||'#'||cNombreBanco, 
				cCuentaCargo, cCuentaAbono,cImporteMaximo, cDiaPago||'#'||dFechaProximoPago, cImporte WITH RESUME;
			END FOREACH;
		END IF;

        IF pOpcion = '02' THEN
        
            --p_sGenerico1 :  activo 'A'  o pendiente 'P'  numero de cliente
            --p_sGenerico2 :     folio de activacion
            --p_sGenerico3 :     numero de cliente
            --p_sGenerico4 :     numero de tarjeta
            IF NVL(p_sGenerico1,'') != '' AND NVL(p_sGenerico2,'') != '' 
				AND NVL(p_sGenerico3,'') != '' AND NVL(p_sGenerico4,'') != '' THEN


                IF p_sGenerico1 = 'A' THEN
                --recibir folio de activacion
                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                SET estatus = '01', contrato = '1' -- estatus activo
                WHERE folio_activacion = p_sGenerico2;

                --update a la tabla de dom_cuentas_ob
                UPDATE dom_cuentas_ob
                SET estatus = '01', fecha_update = current , user_update = pUsuario
                WHERE num_cliente = p_sGenerico3 and num_tarjeta = p_sGenerico4;
            ELSE
               --recibir folio de activacion
                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                SET estatus = '03', contrato = '0' -- estatus activo
                WHERE folio_activacion = p_sGenerico2;

                --update a la tabla de dom_cuentas_ob
                UPDATE dom_cuentas_ob
                SET estatus = '03', fecha_update = current , user_update = pUsuario
                WHERE num_cliente = p_sGenerico3 and num_tarjeta = p_sGenerico4;
                
            END IF;

                RETURN v_sCodRet, "NULL", cNumTelefono,cFolioActivacion, cNombres, cApellidos, '', cNombreProductoCorto, cNombreProductoCorto, cMotivoDev,
                cCuentaCargo, cCuentaAbono,TO_CHAR(cImporteMaximo), cDiaPago||'#'||dFechaProximoPago, cImporte;
            ELSE

                LET v_sCodRet = '88831';

                RETURN v_sCodRet, "NULL", cNumTelefono,cFolioActivacion, cNombres, cApellidos, '', cNombreProductoCorto, cNombreProductoCorto, '',
                cCuentaCargo, cCuentaAbono,TO_CHAR(cImporteMaximo), cDiaPago||'#'||dFechaProximoPago, cImporte;
            END IF;
        END IF;

        -- Ejecucion para cancelar domiciliaciones que quedarÃ²n en el limbo.
        IF pOpcion = '03'  THEN
            
            FOREACH

                SELECT DISTINCT
                d_archivom.nombre_arch, d_aut.folio_activacion, TO_CHAR(d_aut.imp_maximo) imp_maximo, act_ob.estatus, act_ob.num_cte,
                TO_CHAR((f_pago.fecha_pago),'%d'), (d_archivom.imp_operacion/100)::INTEGER, d_archivom.cuenta_cargo, d_archivom.cuenta_abono,
                SUBSTR(d_archivom.cuenta_cargo, 17, 4) as tarjeta_cargo_x, SUBSTR(d_archivom.cuenta_abono, 17, 4) as cuenta_credito_x,
                act_ob.contrato, d_aut.cve_domiciliar_tc, d_ctas_ob.concepto, f_pago.fecha_prox_pago
                INTO
                cNombreArch, cFolioActivacion, cImporteMaximo, cEstatus ,cNumcte, cDiaPago, cImporte, cCuentaCargo, cCuentaAbono,
                cCuentaCargoX, cCuentaAbonoX, cContrato, cTipoPago, cNombreBanco, dFechaProximoPago
                FROM bdidomi:"informix".dom_autorizaciones d_aut
                INNER JOIN bdidomi:"informix".dom_archivomanual as d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion and d_archivom.estatus = 'EP' and d_archivom.tipo_domi = '02'
                INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob as act_ob ON act_ob.folio_activacion = d_aut.folio_activacion and act_ob.estatus IN ('03','01')
                INNER JOIN bdidomi:"informix".dom_fecha_pago as f_pago ON d_aut.folio_activacion = f_pago.folio_activacion
                INNER JOIN bdidomi:"informix".dom_pago as d_pagos ON d_aut.folio_activacion = d_pagos.folio_activacion
                INNER JOIN bdidomi:"informix".dom_cuentas_ob as d_ctas_ob ON LPAD(TRIM(num_tarjeta), '20','0')  = d_archivom.cuenta_cargo
                WHERE d_aut.cve_estatus = '01'
                AND act_ob.contrato IN ('0')
                AND d_ctas_ob.estatus IN('03','FC')
                AND d_archivom.fecha_envio BETWEEN TO_DATE(p_sGenerico1,'%Y-%m-%d') AND TO_DATE(p_sGenerico2,'%Y-%m-%d')  

                --CONSULTAR LOS DATOS DEL CLIENTE
                SELECT numcte, TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno), TRIM(apell_materno), rfc
                INTO cNumCte, cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte, cRfc
                FROM bdinteg:"informix".si_cliente
                WHERE numcte = cNumcte
                AND empresa = '001';

                LET cNombres = TRIM(cNombre1Cte) || ' ' || TRIM(cNombre2Cte);
                LET cApellidos = TRIM(cApellido1Cte) || ' ' || TRIM(cApellido2Cte);

                SELECT telefono
                INTO cNumTelefono
                FROM bdinteg:"informix".si_telefonos_actual
                WHERE numcte= cNumcte
                AND status_tel = 'A'
                AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumcte AND status_tel = 'A' AND tipo_tel = 2)
                AND tipo_tel = 2
                AND empresa = '001';

                SELECT correo_elec
                INTO cCorreoElect
                FROM bdinteg:"informix".si_correos
                WHERE numcte= cNumcte
                AND tipo_correo = 1
                AND status_correo = 'A'
                AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = cNumcte AND status_correo = 'A' AND tipo_correo = 1)
                AND empresa = '001';

                --datos del credito
                SELECT g.nombre_corto, g.descripcion
                INTO cNombreProductoCorto, cNombreProducto
                FROM bdicred:"informix".sd_tarjeta f
                INNER JOIN bdicred:"informix".sd_maecred e ON e.num_credito = f.num_credito
                INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc g 	ON e.num_producto = g.cve_producto
                WHERE f.num_tarjeta = SUBSTR(TRIM(cCuentaAbono), 5, 16)
                AND f.status_tar <> 'C';           

                -- Extraemos el tipo de estatus de la tabla dom_motrechacecoban.
                SELECT estatus_domi
                INTO cNEstatus
                FROM bdidomi:"informix".dom_motrechacecoban_to_cuentasob
                WHERE movdev = cMotivoDev;

                -- Se cancela la domiciliacion por parte de BanCoppel.
                EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus(cFolioActivacion, pUsuario, '02', '', '', '', '', '', '','')
                INTO v_sCodRet, v_generico1, v_generico2, v_generico3, v_generico4;

                IF v_sCodRet != '00000' THEN
                    --Obtenemos los datos del error ocurrido.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                    --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
                    INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                    VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_valida_respuesta_alta_cecoban_ob', trim(cFolioActivacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
                END IF;

                -- Actualiza el registro de la tabla archivo manual.
                UPDATE bdidomi:"informix".dom_archivomanual 
                SET accion = 'B'
                WHERE folio_activacion = cFolioActivacion 
                AND accion = 'A'
                AND estatus = 'EP';

                -- Actualizamos las tablas dom_cuentas_ob y dom_activacion_domiciliacion_ob.
                UPDATE bdidomi:"informix".dom_cuentas_ob 
                SET estatus = '02', fecha_update = current , user_update = pUsuario, intentos = 0
                WHERE num_cliente = cNumcte
                AND num_tarjeta = SUBSTR(TRIM(cCuentaCargo), 5,16);

                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                SET estatus = '02'
                WHERE folio_activacion = cFolioActivacion
                AND estatus IN ('03');

                --se envian cuentas con estatus pendientes y con cuentas verificadas
                RETURN v_sCodRet, cCorreoElect, cNumTelefono,cFolioActivacion, cNombres, cApellidos, cAccion, cNombreProductoCorto, cNombreProducto, cNumcte||'#'||cTipoPago||'#'||cNombreBanco, 
                cCuentaCargo, cCuentaAbono,cImporteMaximo, cDiaPago||'#'||dFechaProximoPago, cImporte WITH RESUME;
                
            END FOREACH;
        END IF;
	END;
END PROCEDURE;