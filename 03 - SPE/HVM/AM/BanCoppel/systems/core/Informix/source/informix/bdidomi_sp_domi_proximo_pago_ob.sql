CREATE PROCEDURE "informix".sp_domi_proximo_pago_ob()
    RETURNING CHAR(5) AS CodRetorno; -- Codigo de retorno.

	--DECLARACION DE VARIABLES
	DEFINE sql_err				INTEGER; 		            -- Error SLQ.
	DEFINE v_sCodRet			CHAR(5);		            -- Codigo de retorno de sp_domi_cobranza_ob.
	DEFINE cFolioActivacion		CHAR(25);		            -- Folio de activacion.
	DEFINE cNumcte				CHAR(20);		            -- Numero de cliente.
	DEFINE cEstatus				CHAR(2);		            -- Estatus de la domiciliacion.
	DEFINE cNombreArchManual    CHAR(20);		            -- Nombre del archivo de la tabla archivo manual.
    DEFINE cCuentaAbono         CHAR(15);                   -- Cuenta de abono.
	DEFINE cTipoCuentaCargo		CHAR(2);		            -- Tipo de cuenta de debito.
	DEFINE cTarjetaCargo		CHAR(20);		            -- Tarjeta de debito.
	DEFINE cCuentaCargoX		CHAR(4);		            -- Ultimos 4 digitos de la tarjeta de debito.
	DEFINE cTarjetaAbono		CHAR(20);		            -- Tarjeta de credito.
	DEFINE cCuentaAbonoX		CHAR(4);		            -- Ultimos 4 digitos de la cuenta de credito.
	DEFINE cMontoPago			CHAR(15);                   -- Importe a pagar.
	DEFINE cRefTitular        	CHAR(30);		            -- Referencia del titular.
	DEFINE cAccion				CHAR(1);		            -- Accion de la domiciliacion ( 'A' -> Alta | 'B' -> Baja ).
	DEFINE cTipoCuentaAbono		CHAR(2);		            -- Tipo de cuenta de credito.
	DEFINE cNombre1Cte			CHAR(200);		            -- Nombre 1 del cliente.
	DEFINE cNombre2Cte			CHAR(200);		            -- Nombre 2 del cliente.
	DEFINE cApellido1Cte		CHAR(200);		            -- Apellido 1 del cliente.
	DEFINE cApellido2Cte 		CHAR(200);		            -- Apellido 2 del cliente.
	DEFINE cRfc					CHAR(13);		            -- Rfc del cliente.
	DEFINE cNumTelefono			CHAR(13); 		            -- Numero de telefono del cliente.
	DEFINE cCorreoElect    		CHAR(100);		            -- Correo electronico del cliente.
	DEFINE cImporteMaximo		DECIMAL(18,2);	            -- Importe maximo permitido para domiciliar.
	DEFINE cNombreProductoCorto	CHAR(20);		            -- Nombre corto del producto de credito.
	DEFINE cNombreProducto		CHAR(40);		            -- Nombre del producto de credito.
	DEFINE dFechaPagoInicial	DATE;                       -- Fecha de pago seleccionada por el cliente al momento de hacer el alta.
	DEFINE dFechaProximoPago	DATE;                       -- Fecha de proximo pago.
    DEFINE dFechaHoy            DATE;                       -- Fecha de hoy.
    DEFINE cFechaHoyToChar      CHAR(8);                    -- Fecha de hoy en formato char(8) YMD.
    DEFINE dFechaEnvio          DATE;                       -- Fecha de envio de domiciliacion a CECOBAN.
    DEFINE dFechaAnt            DATE;                       -- Fecha anterior habil.
    DEFINE cFechaAntToChar      CHAR(8);                    -- Fecha anterior habil en formato char(8) YMD.
	DEFINE cNombres				VARCHAR(250);	            -- Nombres del cliente.
	DEFINE cApellidos			VARCHAR(250);	            -- Apellidos del cliente.
	DEFINE cCausaRechazo		CHAR(150);		            -- Causa rechazo de cecoban.
	DEFINE cEstatusAbono		CHAR(2);		            -- Estatus del abono por parte de CECOBAN, rechazado o aprobado.
	DEFINE cCodret2				CHAR(5);		            -- Codigo de retorno auxiliar para los SP's consumidos.
	DEFINE cMensajeRespuesta	CHAR(150);		            -- Mensaje de respuesta del sp_obtenermensajeerror.
    DEFINE iDias                INTEGER;                    -- Variable para extraer los dias del periodo de pago.
	DEFINE iMeses               INTEGER;                    -- Variable para calcular los meses del periodo.
    DEFINE cNombreCargo         CHAR(100);                  -- Nombre del cliente al que se le hace el cargo.
    DEFINE iPagoExitoso         INTEGER;                    -- Variable para indicar si el pago fue exitoso o no.
    DEFINE cCodigoOperacion     CHAR(2);                    -- Codigo del archivo de respuesta de CECOBAN.
    DEFINE cCveBancoCargo       CHAR(3);                    -- Clave del banco de cargo.
    DEFINE cReferenciaNumerica  CHAR(7);                    -- Referencia numerica.
    DEFINE cRefLeyenda          CHAR(50);                   -- Leyenda de referencia.
    DEFINE cPeriodo             CHAR(2);                    -- Periodicidad de pago.
    DEFINE cFechaAplicacion     CHAR(8);                    -- Fecha en que se realizo el abono.
    DEFINE dFechaPago           DATE;                       -- Fecha de pago seleccionada por el cliente.
    DEFINE cTipoCtaAbono        CHAR(2);                    -- Tipo de cuenta de abono.
    DEFINE cTipoCtaCargo        CHAR(2);                    -- Tipo de cuenta de cargo.
    DEFINE cTipoPago            CHAR(1);                    -- Tipo de pago T || M || F.
    DEFINE iDiferencia          INTEGER;                    -- Diferencia de meses.
    DEFINE cReintento           CHAR(1);                    -- Bandera para indicar si es reintento al dia siguiente.
    DEFINE iNumIntentos         INTEGER;                    -- Numero de intentos.
    DEFINE dFechaManana         DATE;                       -- Fecha del dia de ma?ana para el caso de un reintento al dia siguiente.
    DEFINE cImpFijo             CHAR(15);                   -- Importe fijo seleccionado por el cliente.
    DEFINE iNumIntentosCteRein  INTEGER;                    -- Variable que indica el numero de intentos en la tabla dom_cte_reintentos_cce.
    DEFINE cAux1                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux2                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux3                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux4                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux5                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux6                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux7                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux8                CHAR(25);                   -- Variable auxiliar.
    DEFINE cAux9                CHAR(25);                   -- Variable auxiliar.
    DEFINE dFechaAux            DATE;                       -- Variable auxiliar.
    DEFINE dFechaAux2           DATE;                       -- Variable auxiliar.
    DEFINE cNEstatus            CHAR(2);
	DEFINE mMontoUltimoPago		DECIMAL(18,2);	            -- Monto de ultimo pago.
    DEFINE cJsonEntrada         LVARCHAR(1000);             -- JSON de entrada para la bitacora de notificaciones.
    DEFINE dFechaRequest        DATETIME YEAR TO SECOND;    -- Fecha y Hora de la peticion de notificacion. 
    DEFINE mMontoPago           DECIMAL(18,2);              -- Monto que se iba a pagar en caso de respuesta FC.

	/******************************
	Proyecto:				Domiciliacion OB.
	Descripcion:			Se obtiene la informacion de las cuentas a las que se les realizo el cargo y el abono, para posteriormente
                            actualizar las tablas dom_archivomanual, dom_fecha_pago, dom_pago y enviar notificacion de el estatus del abono.
	Dev:					Pedro Enrique Huicho Yocupicio.
	Fecha creacion:			11/09/2024
	Respuesta esperada:		cCodret: 00000

	******************************/

	LET v_sCodRet				='00000';
	LET cCodret2				='00000';
	LET sql_err 				= 0;
	LET dFechaPagoInicial		= '';
	LET cFolioActivacion		= '';
	LET cNumcte					= '';
	LET cEstatus			    = '';
	LET cNombreArchManual		= '';
	LET cTipoCuentaCargo	    = '';
	LET cTarjetaCargo		    = '';
	LET cCuentaCargoX		    = '';
	LET cNombreCargo		    = '';
	LET cTarjetaAbono		    = '';
	LET cCuentaAbonoX		    = '';
	LET cMontoPago			    = '0';
	LET mMontoUltimoPago		= 0.00;
	LET cRefLeyenda		        = '';
	LET cRefTitular             = '';
	LET dFechaPago		        = '';
	LET dFechaEnvio		        = '';
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
	LET cCodigoOperacion        = '';
	LET cMensajeRespuesta		= '';
    LET iPagoExitoso            = 0;
    LET cCodigoOperacion        = '';
    LET cCuentaAbono            = '';
    LET cCveBancoCargo          = '';
	LET cTipoPago               = '';
    LET dFechaProximoPago       = '';
    LET dFechaHoy               = current::date;
    LET dFechaManana            = current::date + 1;
    LET iDiferencia             = 0;
    LET cReintento              = 'N';
    LET cImpFijo                = '0';
    LET cNEstatus               = '00';

	--***************************************************************************************
        --SET DEBUG FILE TO "/home/sysdomi/sp_domi_proximo_pago_ob.out";
        --TRACE ON;
	--***************************************************************************************

	BEGIN

        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN

                LET v_sCodRet = sql_err;

                INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, v_sCodRet, '', 'sp_domi_proximo_pago_ob', trim(cFolioActivacion), '',CURRENT);

                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy
        INTO dFechaHoy
        FROM bdinteg:si_fechas
        WHERE empresa = '001';

        -- Extraemos el dia habil anterior, el cual fue el dia que se genero el archivo 30.
        EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtener_fecha_valida_ob(dFechaHoy) 
        INTO dFechaAux, dFechaAux2, dFechaAnt;
        
        -- Convertir fechas a formato char(8) Ymd.
        LET cFechaHoyToChar = TO_CHAR(dFechaHoy,'%Y%m%d');
        LET cFechaAntToChar = TO_CHAR(dFechaAnt,'%Y%m%d');

        FOREACH WITH HOLD

            -- EXTRAEMOS LAS DOMICILIACIONES LAS CUALES TENIAN PROGRAMADO UN COBRO.
            SELECT
            d_archivom.nombre_arch , d_aut.folio_activacion , d_aut.imp_maximo, act_ob.num_cte,
            d_archivom.cuenta_cargo as tarjeta_cargo, d_archivom.cuenta_abono as tarjeta_abono,
            SUBSTR(d_archivom.cuenta_cargo, 17, 4) as tarjeta_cargo_x, SUBSTR(d_archivom.cuenta_abono, 17, 4) as cuenta_credito_x,
            d_archivom.nombre_cargo, d_archivom.tipo_cta_abono, d_archivom.tipo_cta_cargo, d_aut.cuenta as cuenta_abono, 
            d_aut.cve_banco_cargo, d_archivom.rfc_cargo, d_archivom.ref_numerica, d_archivom.num_periodo, 
            d_aut.cve_domiciliar_tc, d_archivom.ref_leyenda, d_aut.imp_fijo_tc::DECIMAL(18,2)
            INTO
            cNombreArchManual, cFolioActivacion, cImporteMaximo ,cNumcte, cTarjetaCargo, cTarjetaAbono,
            cCuentaCargoX, cCuentaAbonoX, cNombreCargo, cTipoCtaAbono, cTipoCtaCargo, cCuentaAbono, 
            cCveBancoCargo, cRfc, cReferenciaNumerica, cPeriodo, cTipoPago, cRefLeyenda, cImpFijo
            FROM bdidomi:"informix".dom_autorizaciones d_aut
            INNER JOIN bdidomi:"informix".dom_archivomanual as d_archivom ON d_aut.folio_activacion = d_archivom.folio_activacion
            INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob as act_ob ON act_ob.folio_activacion = d_aut.folio_activacion
            WHERE d_aut.cve_estatus = '01'
            AND d_archivom.estatus = 'EP' 
            AND d_archivom.accion = 'A'
            AND d_archivom.fecha_cargo = cFechaAntToChar
            AND d_archivom.tipo_domi = '02'
            AND act_ob.estatus = '01'  
            
            -- Extraemos las fechas de pago y montos de pago.
            SELECT
            f_pago.fecha_pago, f_pago.fecha_prox_pago, d_pagos.monto_proximo_pago
            INTO
            dFechaPago, dFechaProximoPago, mMontoPago
            FROM bdidomi:"informix".dom_fecha_pago as f_pago 
            INNER JOIN bdidomi:"informix".dom_pago as d_pagos ON f_pago.folio_activacion = d_pagos.folio_activacion
            WHERE f_pago.folio_activacion = cFolioActivacion;

            --CONSULTAR LOS DATOS DEL CLIENTE
            EXECUTE PROCEDURE bdidomi:"informix".sp_domi_consultardatoscliente(cNumcte, 'transBPI')
            INTO v_sCodRet, cNumcte, cNombres, cRfc, cAux1, cNumTelefono, cCorreoElect;

            SELECT TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno), TRIM(apell_materno)
            INTO cNombre1Cte, cNombre2Cte, cApellido1Cte, cApellido2Cte
            FROM bdinteg:"informix".si_cliente
            WHERE numcte = cNumcte
            AND empresa = '001';

            LET cNombres = TRIM(cNombre1Cte) || ' ' || TRIM(cNombre2Cte);
            LET cApellidos = TRIM(cApellido1Cte) || ' ' || TRIM(cApellido2Cte);

            --datos del credito
            SELECT g.nombre_corto, g.descripcion
            INTO cNombreProductoCorto, cNombreProducto
            FROM bdicred:"informix".sd_tarjeta f
            INNER JOIN bdicred:"informix".sd_maecred e ON e.num_credito = f.num_credito
            INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc g 	ON e.num_producto = g.cve_producto
            WHERE f.num_tarjeta = SUBSTR(TRIM(cTarjetaAbono), 5, 16)
            AND f.status_tar <> 'C';

            -- CALCULAMOS LA FECHA DEL PROXIMO PAGO
            SELECT dias INTO iDias FROM bdidomi:"informix".dom_cat_periodo WHERE cve_periodo = cPeriodo;

            LET iMeses = iDias/30;

            SELECT ROUND((months_between(dFechaHoy, fecha_pago) + 1), 0)
            INTO iDiferencia
            FROM bdidomi:"informix".dom_fecha_pago
            WHERE folio_activacion = cFolioActivacion;

            IF iMeses = 1 THEN
                LET dFechaProximoPago = dFechaPago + iDiferencia UNITS MONTH;
            END IF;

            -- Verificamos si el pago es Fijo para la programacion del proximo pago.
            IF cTipoPago = 'F' THEN
                LET cMontoPago = cImpFijo;
            END IF;

            -- COMPROBAMOS LAS DOMICILIACIONES DE OTROS BANCOS LAS CUALES OBTUVIERON RESPUESTA DE ARCHIVO 31/32 DE CECOBAN.
            FOREACH WITH HOLD
                SELECT
                cve_estatus, cod_operacion, fecha_aplica, motivo_dev, (importe::INTEGER)/100
                INTO
                cEstatusAbono, cCodigoOperacion, cFechaAplicacion, cCausaRechazo, mMontoUltimoPago
                FROM bdidomi:"informix".dom_cce_detalle
                WHERE num_cta_ord = cTarjetaAbono
                AND num_cta_rec = cTarjetaCargo
                AND fecha_presentacion = cFechaHoyToChar
                AND cod_operacion IN ('31','32')
                AND fecha_aplica = cFechaAntToChar
                AND nombre_ord <> 'COPPEL'

                -- Si el registro es un 31 con causa rechazo 07 entonces continuamos al siguiente registro.
                IF cCodigoOperacion = '31' AND cCausaRechazo = '07' THEN
                    CONTINUE FOREACH;
                END IF;
                
                -- Verificamos si CECOBAN rechazo el pago.
                IF NVL(cEstatusAbono,'') != '01' AND NVL(cCodigoOperacion,'') != '32'  THEN

                    SELECT estatus_domi
                    INTO cNEstatus
                    FROM bdidomi:"informix".dom_motrechacecoban_to_cuentasob
                    WHERE movdev = cCausaRechazo;

                    -- Cuando el pago no fue exitoso.
                    LET iPagoExitoso = 2;

                    -- Actualizamos registro con estatus '02' de abono incorrecto.
                    UPDATE bdidomi:"informix".dom_archivomanual
                    SET causa_rechazo = cCausaRechazo,
                    imp_operacion = LPAD(TRIM(((cMontoPago)::INTEGER*100)::CHAR(15)),15,'0')
                    WHERE folio_activacion = cFolioActivacion
                    AND nombre_arch = cNombreArchManual
                    AND estatus = 'EP';

                    -- Extraemos el numero de intentos.
                    SELECT intentos_cobro INTO iNumIntentos
                    FROM bdidomi:"informix".dom_activacion_domiciliacion_ob
                    WHERE folio_activacion = cFolioActivacion;

                    LET iNumIntentos = iNumIntentos + 1;

                    -- Actualizamos el contador de cobro.
                    UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                    SET intentos_cobro = iNumIntentos WHERE folio_activacion = cFolioActivacion;

                    --  Verificamos si es causa rechazo 04 insuficiencia de fondos.
                    IF cCausaRechazo = '04' THEN

                        -- Para programar un reintento al dia siguiente.
                        IF NVL(iNumIntentos, 0) NOT IN(3,6,9) THEN

                            -- Actualizamos el estatus a 03 y causa rechazo PR que es pendiente de reintento.
                            UPDATE bdidomi:"informix".dom_archivomanual
                            SET estatus = '03', causa_rechazo = 'PR'
                            WHERE folio_activacion = cFolioActivacion
                            AND nombre_arch = cNombreArchManual
                            AND causa_rechazo = '04';

                            -- Agregamos un dia a la fecha de proximo pago para el reintento.
                            LET dFechaProximoPago  = TO_DATE(cFechaAplicacion, '%Y%m%d');
                            LET dFechaProximoPago = dFechaProximoPago + 1 UNITS DAY;
                            LET cReintento = 'S';

                            -- Validamos que el dia siguiente sea dia habil.
                            EXECUTE PROCEDURE bdidomi:"informix".sp_ValFeriadoBanca('001',dFechaProximoPago,0,'V') INTO v_sCodRet, dFechaManana;

                            IF v_sCodRet <> '00000' THEN

                                LET dFechaProximoPago = dFechaProximoPago + 1 UNITS DAY;

                                WHILE v_sCodRet <> '00000'

                                    EXECUTE PROCEDURE bdidomi:"informix".sp_ValFeriadoBanca('001',dFechaProximoPago, 0,'V') INTO v_sCodRet, dFechaManana;

                                    IF v_sCodRet = '00000' THEN
                                       EXIT WHILE;
                                    ELSE
                                        LET dFechaProximoPago = dFechaProximoPago + 1 UNITS DAY;
                                    END IF;

                                END WHILE;

                                LET dFechaProximoPago = dFechaManana;
                            END IF;

                            LET cCausaRechazo = 'PR';

                        ELSE

                            -- Validamos si ya estamos en el reintento 9 y cancelamos la domiciliacion.
                            IF iNumIntentos >= 9 THEN
                                -- Se cancela la domiciliacion por parte de BanCoppel.
                                EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus(cFolioActivacion, 'sysdomi', '02', '', '', '', '', '', '','')
                                INTO v_sCodRet, cAux1, cAux2, cAux3, cAux4;

                                -- Actualiza el registro de la tabla archivo manual.
                                UPDATE bdidomi:"informix".dom_archivomanual
                                SET accion = 'B'
                                WHERE folio_activacion = cFolioActivacion
                                AND accion = 'A'
                                AND estatus = 'EP';

                                -- Actualizamos la tabla dom_cuentas_ob
                                UPDATE bdidomi:"informix".dom_cuentas_ob
                                SET estatus = cNEstatus, fecha_update = current , user_update = 'sysdomi'
                                WHERE num_cliente = cNumcte
                                AND num_tarjeta = cTarjetaCargo
                                AND estatus = '01';

                                -- Actualizamos la tabla dom_activacion_domiciliacion_ob.
                                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                                SET estatus = '02'
                                WHERE folio_activacion = cFolioActivacion
                                AND estatus = '01';

                               --Almacena los datos en la tabla bdidomi:dom_cancelaciones.
                                INSERT INTO bdidomi:"informix".dom_cancelaciones(folio_activacion, folio_cancelacion, motivo, user_insert, fecha_insert)
                                VALUES(cFolioActivacion, 'C' || cFolioActivacion, 'LIMITE DE REINTENTOS DE PAGO', 'sysdomi', today);

                                -- Se envia correo de que su domiciliacion fue cancelada.
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_CAN',
                                cNumCte, cCuentaCargoX, cTarjetaAbono,'1',cCuentaAbonoX,cCuentaCargoX, cCuentaAbonoX,
                                cImporteMaximo,cNombreProducto, cFolioActivacion, TO_CHAR(today,'%d %b %Y'),'','','',
                                cCorreoElect,'',0,0,0,0,0, CURRENT,'') INTO v_sCodRet;

                                -- Si ocurrio un error lo introducimos en la bitacora dom_errores y saltamos al siguiente registro.
                                IF v_sCodRet <> '00000' THEN
                                    EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                                    INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                                    VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_proximo_pago_ob', trim(cFolioActivacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
                                END IF;

                                CONTINUE FOREACH;
                            END IF;

                            -- Actualizamos la bandera de procesado para permitir el proceso del nuevo registro.
                            UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                            SET procesado = 0
                            WHERE folio_activacion = cFolioActivacion;

                            -- Actualizamos el estatus de la domiciliacion a 02 cuando fallÃÂÃÂ³ y es una programacion al siguiente mes.
                            UPDATE bdidomi:"informix".dom_archivomanual
                            SET estatus = '02'
                            WHERE folio_activacion = cFolioActivacion
                            AND estatus = 'EP';

                            LET cReintento = 'N';
                        END IF;
                    ELSE 
                    -- Cancelamos la domiciliacion cuando no sea una causa rechazo 04.
                        -- Se cancela la domiciliacion por parte de BanCoppel.
                        EXECUTE PROCEDURE bdidomi:"informix".sp_dom_reversa_estatus(cFolioActivacion, 'sysdomi', '02', '', '', '', '', '', '','')
                        INTO v_sCodRet, cAux1, cAux2, cAux3, cAux4;

                        -- Actualiza el registro de la tabla archivo manual.
                        UPDATE bdidomi:"informix".dom_archivomanual
                        SET accion = 'B'
                        WHERE folio_activacion = cFolioActivacion
                        AND accion = 'A'
                        AND estatus = 'EP';

                        -- Actualizamos la tabla dom_cuentas_ob
                        UPDATE bdidomi:"informix".dom_cuentas_ob
                        SET estatus = cNEstatus, fecha_update = current , user_update = 'sysdomi'
                        WHERE num_cliente = cNumcte
                        AND num_tarjeta = cTarjetaCargo
                        AND estatus = '01';

                        -- Actualizamos la tabla dom_activacion_domiciliacion_ob.
                        UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                        SET estatus = '02'
                        WHERE folio_activacion = cFolioActivacion
                        AND estatus = '01';

                       --Almacena los datos en la tabla bdidomi:dom_cancelaciones.
                        INSERT INTO bdidomi:"informix".dom_cancelaciones(folio_activacion, folio_cancelacion, motivo, user_insert, fecha_insert)
                        VALUES(cFolioActivacion, 'C' || cFolioActivacion, 'PAGO RECHAZADO POR CECOBAN', 'sysdomi', today);

                        -- Se envia correo de que su domiciliacion fue cancelada.
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','DOM_CAN',
                        cNumCte, cCuentaCargoX, cTarjetaAbono,'1',cCuentaAbonoX,cCuentaCargoX, cCuentaAbonoX,
                        cImporteMaximo,cNombreProducto, cFolioActivacion, TO_CHAR(today,'%d %b %Y'),'','','',
                        cCorreoElect,'',0,0,0,0,0, CURRENT,'') INTO v_sCodRet;

                        -- Si ocurrio un error lo introducimos en la bitacora dom_errores y saltamos al siguiente registro.
                        IF v_sCodRet <> '00000' THEN
                            EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                            INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                            VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_proximo_pago_ob', trim(cFolioActivacion) || ' - ' || trim(cMensajeRespuesta), '', CURRENT);
                        END IF;

                        CONTINUE FOREACH;
                    END IF;

                    -- Creamos un nuevo registro para la programacion del proximo pago.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_guardararchivo_manual_ob(cNombreCargo, cCuentaAbono, cTipoCtaAbono, cMontoPago,
                    cTarjetaCargo, cTipoCtaCargo, cCveBancoCargo, 'transBPI', TO_CHAR(dFechaProximoPago, '%Y%m%d'), cRfc, cFolioActivacion,
                    cReferenciaNumerica, 'A', cPeriodo, 'EP', cNumCte, cTarjetaAbono, cReintento,'','','') INTO v_sCodRet, cAux1,cAux2,cAux3,cAux4,cAux5,cAux6,cAux7,cAux8,cAux9;

                    IF v_sCodRet <> '00000' THEN

                         --Obtenemos los datos del error ocurrido.
                        EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                        --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
                        INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                        VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_proximo_pago_ob', TRIM(cFolioActivacion) || '-' || TRIM(cMensajeRespuesta), 'sysdomi', CURRENT);

                        CONTINUE FOREACH;
                    END IF;

                    -- Enviamos notificacion de que el abono no fue exitoso.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_notificacion_estatus_cargos('sysdomi', iPagoExitoso, cCausaRechazo,
                    cFolioActivacion, cNumcte, SUBSTR(TRIM(cTarjetaCargo), 5, 16), cNombre1Cte, cApellido1Cte, cCuentaCargoX,
                    cCuentaAbonoX, cImporteMaximo, cNombreProducto, mMontoUltimoPago,cCorreoElect, cNombreProductoCorto, 
                    cNumTelefono, cRefLeyenda) INTO cCodret2;

                    CONTINUE FOREACH;
                END IF;

                -- Flujo de cuando el abono fue exitoso.
                LET iPagoExitoso = 1;

                -- Actualizamos registro con estatus '01' de abono exitoso.
                UPDATE bdidomi:"informix".dom_archivomanual
                SET estatus = '01', num_intento = 0, imp_operacion = LPAD(TRIM(((cMontoPago)::INTEGER*100)::CHAR(15)),15,'0')
                WHERE folio_activacion = cFolioActivacion
                AND nombre_arch = cNombreArchManual
                AND estatus = 'EP';

                UPDATE bdidomi:"informix".dom_fecha_pago
                SET fecha_ult_pago = TO_DATE(cFechaAplicacion, '%Y%m%d')
                WHERE folio_activacion = cFolioActivacion;

                UPDATE bdidomi:"informix".dom_pago
                SET monto_ultimo_pago = mMontoUltimoPago
                WHERE folio_activacion = cFolioActivacion;

                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob
                SET procesado = 0, intentos_cobro = 0
                WHERE folio_activacion = cFolioActivacion;

                -- Insertamos nuevo registro para la programacion del proximo pago.
                EXECUTE PROCEDURE bdidomi:"informix".sp_domi_guardararchivo_manual_ob(cNombreCargo, cCuentaAbono, cTipoCtaAbono, cMontoPago,
                cTarjetaCargo, cTipoCtaCargo, cCveBancoCargo, 'transBPI', TO_CHAR(dFechaProximoPago, '%Y%m%d'), cRfc, cFolioActivacion, cReferenciaNumerica, 'A', cPeriodo, 'EP',
                cNumCte, cTarjetaAbono, '','','','') INTO v_sCodRet, cAux1,cAux2,cAux3,cAux4,cAux5,cAux6,cAux7,cAux8,cAux9;

                IF v_sCodRet <> '00000' THEN

                     --Obtenemos los datos del error ocurrido.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(v_sCodRet) INTO cCodret2, cMensajeRespuesta;

                    --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
                    INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                    VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret2, '', 'sp_domi_proximo_pago_ob', TRIM(cFolioActivacion) || '-' || TRIM(cMensajeRespuesta), 'sysdomi', CURRENT);

                    CONTINUE FOREACH;
                END IF;

                -- Enviamos la notificacion de que el abono fue exitoso.
                EXECUTE PROCEDURE bdidomi:"informix".sp_domi_notificacion_estatus_cargos('sysdomi', iPagoExitoso, '',
                cFolioActivacion, cNumcte, SUBSTR(TRIM(cTarjetaCargo), 5, 16), cNombre1Cte, cApellido1Cte, cCuentaCargoX,
                cCuentaAbonoX, cImporteMaximo, cNombreProducto, mMontoUltimoPago,
                cCorreoElect, cNombreProductoCorto, cNumTelefono, cRefLeyenda) INTO cCodret2;

            END FOREACH;

         END FOREACH;
         RETURN v_sCodRet;
	END;
END PROCEDURE;