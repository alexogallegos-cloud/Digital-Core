CREATE PROCEDURE "informix".sp_domi_obtener_fecha_valida_ob(fechaPago DATE)
    RETURNING DATE AS fechaEnvio, DATE AS fechaPagoAjustada, DATE AS fechaHabilAnterior;
    DEFINE nuevaFecha DATE;
    DEFINE diasHabilesEncontrados INTEGER;
    DEFINE fechaPagoAjustada DATE;
    DEFINE fechaEnvio DATE;
    DEFINE fechaHabilAnterior DATE;

    -- Inicializamos las variables
    LET nuevaFecha = fechaPago;
    LET diasHabilesEncontrados = 0;

BEGIN
    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO wait 3;

    -- Verificar si la fecha de pago es un dÃ­a hÃ¡bil (lunes a viernes) y no es feriado
    IF WEEKDAY(fechaPago) BETWEEN 1 AND 5 AND 
       NOT EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = fechaPago) THEN
        
        -- Calcula fechaEnvio (2 dÃ­as hÃ¡biles atrÃ¡s)
        LET nuevaFecha = fechaPago;
        LET diasHabilesEncontrados = 0;
        WHILE diasHabilesEncontrados < 2
            LET nuevaFecha = nuevaFecha - 1;
            IF WEEKDAY(nuevaFecha) BETWEEN 1 AND 5 AND
                NOT EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = nuevaFecha) THEN
                LET diasHabilesEncontrados = diasHabilesEncontrados + 1;
            END IF;
        END WHILE;
        LET fechaEnvio = nuevaFecha;

        -- Calcula fechaPagoAjustada (1 dÃ­a hÃ¡bil atrÃ¡s)
        LET nuevaFecha = fechaPago;
        LET diasHabilesEncontrados = 0;
        WHILE diasHabilesEncontrados < 1
            LET nuevaFecha = nuevaFecha - 1;
            IF WEEKDAY(nuevaFecha) BETWEEN 1 AND 5 AND
                NOT EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = nuevaFecha) THEN
                LET diasHabilesEncontrados = diasHabilesEncontrados + 1;
            END IF;
        END WHILE;
        LET fechaPagoAjustada = nuevaFecha;
    ELSE
        -- Calcula fechaEnvio (5 dÃ­as hÃ¡biles atrÃ¡s)
        LET nuevaFecha = fechaPago;
        LET diasHabilesEncontrados = 0;
        
        WHILE diasHabilesEncontrados < 5
            LET nuevaFecha = nuevaFecha - 1;
            IF WEEKDAY(nuevaFecha) BETWEEN 1 AND 5 AND
               NOT EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = nuevaFecha) THEN
                LET diasHabilesEncontrados = diasHabilesEncontrados + 1;
            END IF;
        END WHILE;
        LET fechaEnvio = nuevaFecha;

        -- Calcula fechaPagoAjustada (4 dÃ­as hÃ¡biles atrÃ¡s)
        LET nuevaFecha = fechaPago;
        LET diasHabilesEncontrados = 0;

        WHILE diasHabilesEncontrados < 4
           LET nuevaFecha = nuevaFecha - 1;
           IF WEEKDAY(nuevaFecha) BETWEEN 1 AND 5 AND
             NOT EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = nuevaFecha) THEN
                LET diasHabilesEncontrados = diasHabilesEncontrados + 1;
            END IF;
        END WHILE;
        LET fechaPagoAjustada = nuevaFecha;
    END IF;

    -- Calcula fechaHabilAnterior (dÃ­a hÃ¡bil anterior a fechaPago)
    LET nuevaFecha = fechaPago - 1;
    WHILE WEEKDAY(nuevaFecha) = 6 OR WEEKDAY(nuevaFecha) = 0 OR 
          EXISTS (SELECT 1 FROM bdinteg:si_feriado_banca WHERE fecha = nuevaFecha)
        LET nuevaFecha = nuevaFecha - 1;
    END WHILE;
    LET fechaHabilAnterior = nuevaFecha;

    -- Retorna las tres fechas calculadas
    RETURN fechaEnvio, fechaPagoAjustada, fechaHabilAnterior;
END;
END PROCEDURE

DOCUMENT
'AUTOR: 	Pedro Mauricio Gutierrez',
'DESCRIPCION: 	Fusiona la lÃ³gica de sp_domi_obtener_fecha_valida_ob y sp_domi_dia_habil_anterior.',
'FECHA: 	18/12/2024',
'BD: 		BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_notificacion_previa()
	RETURNING char(5) AS cCoderet

-- DECLARACIÃN DE VARIABLES
DEFINE iSqlerr      				INTEGER;
DEFINE cCoderet     				CHAR(5);
DEFINE cCoderet3  					CHAR(5);
define cFecha       				CHAR(10);
DEFINE cFolioActivacion  			CHAR(20);
DEFINE cTipo        				CHAR(2);
DEFINE cNumCte       				CHAR(20);
DEFINE cNumCte_banco       			CHAR(20);
DEFINE cNumCta       				CHAR(20);
DEFINE cNumTarjeta       			CHAR(16);
DEFINE cNombreCte      				CHAR(20);
DEFINE cRfc 	      				CHAR(20);
DEFINE cRazonSocial      			CHAR(20);
DEFINE cNumTelefono      			CHAR(20);
DEFINE cCorreoElect    				CHAR(50);
DEFINE cTerminacionTarjeta   		CHAR(4);
DEFINE cNombreProductoCorto   		CHAR(20);
DEFINE cNombreProducto   		CHAR(40);
DEFINE cDia 						CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cFechaPago   				CHAR(5);
DEFINE cFecha_arch 					CHAR(6);
DEFINE dFechaActual 				DATE;
DEFINE dFechaProximaNotificacion	DATE;
DEFINE mMontoProximoPago 			MONEY(16,2);
DEFINE cImporteFijo 				MONEY(16,2);
DEFINE iDias						INTEGER;
DEFINE cPeriodo						CHAR(2);
DEFINE iMeses						INTEGER;
DEFINE dFechaProximoPago			DATE;
DEFINE cNombreArchivo				CHAR(20);
DEFINE dFechaUltimoPago				DATE;
DEFINE cFechaNuevaPago				CHAR(8);
DEFINE cNombreCargo					CHAR(40);
DEFINE cCuentaAbono					CHAR(20);
DEFINE cTipoAbono					CHAR(2);
DEFINE cImporteOperacion			CHAR(15);
DEFINE cCuentaCargo					CHAR(20);
DEFINE cTipoCargo					CHAR(2);
DEFINE cBancoCargo					CHAR(3);
DEFINE cTipoDomi					CHAR(2);
DEFINE cTipoPago					CHAR(1);
DEFINE cRfcCargo					CHAR(13);
DEFINE v_generico1					CHAR(100);
DEFINE v_generico2 					CHAR(100);
DEFINE v_generico3					CHAR(100);
DEFINE v_generico4					CHAR(100);
DEFINE dValidarFecha                DATE;
DEFINE dFechaPagoInicial            DATE;
DEFINE cAux                         CHAR(20);
DEFINE cCuentaCargoX                CHAR(4);
DEFINE cCuentaAbonoX                CHAR(4);
DEFINE cRefLeyenda                  CHAR(40);
DEFINE cEstatusActivacion           CHAR(2);

-- VALORES INICIALES
LET iSqlerr    			=  0;
LET cCoderet   			= '00000';
LET cCoderet3 			= '';
let cFolioActivacion	= '';
let dValidarFecha       = '';
let cTipo               = '';
let cCuentaCargoX       = '';
let cCuentaAbonoX       = '';
let cRefLeyenda         = '';


--******************************************************************************
   --SET DEBUG FILE TO "/tmp/sp_domi_notificacion_previa.out";
   --TRACE ON;
--**************************************************************************************************************************

BEGIN
	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCoderet = iSqlerr;
			RETURN cCoderet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Obtener fecha actual.
	SELECT fecha_hoy
	INTO dFechaActual
	FROM bdinteg:"informix".si_fechas where empresa='001';

	IF (dFechaActual = dFechaActual) THEN
		SELECT valor INTO cNumCte_banco FROM bdidomi:"informix".dom_parametros WHERE cod_param = '36';

		FOREACH WITH HOLD
			SELECT
			a.folio_activacion, a.num_cte, a.cuenta,a.cve_domiciliar_tc, a.imp_fijo_tc,
			b.tipo_domi, c.monto_proximo_pago, d.fecha_notificacion, MONTH(d.fecha_prox_pago) as mes,
			DAY(d.fecha_prox_pago) as dia, b.nombre_arch, nvl(fecha_ult_pago,fecha_pago), d.periodo,
            d.fecha_prox_pago, d.fecha_pago, b.ref_leyenda, SUBSTR(b.cuenta_cargo, 17, 4) as tarjeta_cargo_x,
            SUBSTR(b.cuenta_abono, 17, 4) as cuenta_credito_x
			INTO cFolioActivacion, cNumCte, cNumCta,cTipoPago, cImporteFijo, cTipo, mMontoProximoPago,
			dFechaProximaNotificacion, cMes, cDia , cNombreArchivo, dFechaUltimoPago, cPeriodo, dFechaProximoPago,
            dFechaPagoInicial, cRefLeyenda, cCuentaCargoX, cCuentaAbonoX
			FROM bdidomi:"informix".dom_autorizaciones a
			INNER JOIN bdidomi:"informix".dom_archivomanual b ON a.folio_activacion = b.folio_activacion
			INNER JOIN bdidomi:"informix".dom_pago c ON a.folio_activacion 	= c.folio_activacion
			INNER JOIN bdidomi:"informix".dom_fecha_pago d 	ON a.folio_activacion 	= d.folio_activacion
			WHERE a.cve_estatus = '01'
			AND d.fecha_notificacion = dFechaActual
			AND b.estatus = 'EP'

			IF( NVL(cFolioActivacion,'') != '' ) THEN

				IF cTipoPago <> 'F' THEN

					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(cTipoPago, '001', TRIM(cNumCta), 'sysdomi', TRIM(cFolioActivacion), cTipo) INTO cCoderet3,mMontoProximoPago;

				ELSE
					LET mMontoProximoPago=cImporteFijo;
				END IF;

				IF (NVL(mMontoProximoPago,0) > 0) then

					-- Consultar datos del cliente.
					EXECUTE PROCEDURE bdidomi:"informix".sp_domi_consultardatoscliente(cNumCte, 'sysbex')
					INTO cCoderet, cNumCte, cNombreCte, cRfc, cRazonSocial, cNumTelefono, cCorreoElect;

					-- Si existen datos del cliente, se envia notificacion SMS.
					IF(
						cCoderet = '00000' AND NVL(cNumCte,'') != '' AND NVL(cNombreCte,'') != ''
						AND NVL(cRfc,'') != '' AND NVL(cNumTelefono,'') != '' AND NVL(cCorreoElect,'') != ''
					)
					THEN

						LET cFechaPago = TO_CHAR(cDia, "&&") || '/' || TO_CHAR(cMes, "&&");

						SELECT
						SUBSTR(TRIM(f.num_tarjeta), -4) as terminacion, f.num_tarjeta, g.nombre_corto, g.descripcion
						INTO cTerminacionTarjeta, cNumTarjeta, cNombreProductoCorto, cNombreProducto
						FROM bdidomi:"informix".dom_autorizaciones a
						INNER join bdicred:"informix".sd_maecred e ON a.cuenta = e.num_credito
						INNER JOIN bdicred:"informix".sd_tarjeta f ON e.num_credito = f.num_credito
						INNER JOIN bdidomi:"informix".dom_prod_permitidos_tc g 	ON e.num_producto = g.cve_producto
						where a.cve_estatus = '01'
						and a.folio_activacion = cFolioActivacion
						and f.status_tar <> 'C'
						AND f.tipo_tarjeta = 'T'
						AND f.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta
							   				WHERE num_credito = a.cuenta AND tipo_tarjeta = 'T' AND status_tar <> 'C');

                        /*proceso otros bancos */
						IF(cTipo = '02') THEN

                            -- Obtenemos el estatus de la domiciliacion de otros bancos para verificar si esta activa.
                            SELECT estatus 
                            INTO cEstatusActivacion
                            FROM bdidomi:"informix".dom_activacion_domiciliacion_ob 
                            WHERE folio_activacion = cFolioActivacion;

                            -- Si la domiciliacion no esta validada por cecoban entonces nos saltamos el registro.
                            IF cEstatusActivacion != '01' THEN
                                CONTINUE FOREACH;
                            END IF;

                            -- Verificamos si el dia de pago del cliente es mayor al ultimo dia del mes.
                            IF (DAY(dFechaPagoinicial) - DAY(dFechaProximoPago)) >= 3 THEN

                                -- Enviamos EMAIL.
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','DOMI_EMAIL','COBRO_DINHAB',cNumCte,'','','1',cDia||'/'||cMes,
                                'XXXXXX '||cCuentaCargoX,'XXXXXX '||cCuentaAbonoX,TO_CHAR(dFechaProximoPago,'%d %B %Y'),cNombreProducto,cFolioActivacion, TO_CHAR(today, '%d-%m-%Y'),
                                TO_CHAR(current,'%H:%M'),mMontoProximoPago::DECIMAL(18,2),'',cCorreoElect,'',0,0,0,0,0,'','') INTO cCoderet;

                                -- Enviamos SMS.
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','COBRO_DINHAB',cNumCte,'','', '1',cDia||'/'||cMes,
                                '','','','','','','','','','','',0,0,0,0,0,'','') INTO cCoderet;

                                -- Enviamos PUSH.
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_PUSH','COBRO_DINHAB',cNumCte,'','', '1',cDia||'/'||cMes,
                                '','','','','','','','','','','',0,0,0,0,0,'','') INTO cCoderet;

                                CONTINUE FOREACH;
                            END IF;
                        END IF

						-- Enviamos SMS.
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','DOMI_SMS','DOM_PREVIO',cNumCte,cNumTarjeta,cNumCta,'1',
						'','','','','','',cTerminacionTarjeta,cFechaPago,cNombreProductoCorto,'',cCorreoElect,
						cNumTelefono,mMontoProximoPago,0,0,0,0,current,'') INTO cCoderet;

					END IF;
				END IF;
			END IF;
		END FOREACH;
	END IF;
RETURN cCoderet;
END;
END PROCEDURE;