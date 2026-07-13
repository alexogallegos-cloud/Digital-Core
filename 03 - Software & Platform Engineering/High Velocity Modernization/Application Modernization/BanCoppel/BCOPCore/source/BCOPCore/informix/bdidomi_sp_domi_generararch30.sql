CREATE PROCEDURE "informix".sp_domi_generararch30(pNombre_Arch CHAR(20),pUsuario CHAR(8))
	RETURNING CHAR(5);

	--	Declaracion de variables.
	DEFINE	dFecha_hoy				DATE;
	DEFINE	dFecha_Manana   		DATE;
	DEFINE dFechaEnvioProveedor	DATE;
	DEFINE iSQLerr					INTEGER;
	DEFINE	iExiste					INTEGER;
	DEFINE	iContadorVueltas		INTEGER;
	DEFINE	iMotivoDev				INTEGER;
	DEFINE	iRegistros				INTEGER;
	DEFINE	iNvaSecuencia			INTEGER;
	DEFINE	cEstatus				CHAR(2);
	DEFINE cTipoRegistro			CHAR(1);
	DEFINE cStat					CHAR(2);
	DEFINE	cConsecutivoDetalle		CHAR(7);
	DEFINE	cTpoCtaCargo			CHAR(2);
	DEFINE	cTipoRegistro10			CHAR(2);
	DEFINE cClaVeBancaria			CHAR(3);
	DEFINE cClaveBancoReceptor		CHAR(3);
	DEFINE cBanco_receptor			CHAR(3);
	DEFINE cCodRet					CHAR(5);
	DEFINE cCodRetMensaje			CHAR(5);
	DEFINE cConsecutivo			CHAR(6);
	DEFINE cReferenciaNum			CHAR(7);
	DEFINE cNum_Secuencia			CHAR(7);
	DEFINE cNumSecuencia10			CHAR(7);
	DEFINE cFechaFormat			CHAR(8);
	DEFINE cFechaPresentacion10	CHAR(8);
	DEFINE cFechaManana		    CHAR(8);
	DEFINE  cFecha_aplica		    CHAR(8);
	DEFINE cNumCliente				CHAR(9);
	DEFINE cNumCteEncabezado		CHAR(9);
	DEFINE cRFCcargo				CHAR(13);
	DEFINE cRFCcliente				CHAR(13);
	DEFINE cRfc_ord				CHAR(13);
	DEFINE	cImpOperacion			CHAR(15);
	DEFINE	cImporte				CHAR(15);
	DEFINE cImpIva					CHAR(15);
	DEFINE cCve_proceso			CHAR(18);
	DEFINE cCuentaAbono			CHAR(20);
	DEFINE cCuentaAbono_CLABE		CHAR(20);
	DEFINE cCuenta_Clabe			CHAR(20);
	DEFINE cNum_cta_ord			CHAR(20);
	DEFINE cNum_cta_rec			CHAR(20);
	DEFINE cNombreArchProveedor	CHAR(20);
	DEFINE cNombreArch10			CHAR(20);
	DEFINE cCuentaCargo			CHAR(20);
	DEFINE cValTarjeta				CHAR(20);
	DEFINE cValTarjNuevo			CHAR(20);
	DEFINE cClaveRastreo			CHAR(30);
	DEFINE	cReferenciaServicio		CHAR(40);
	DEFINE cNombreTitular			CHAR(40);
	DEFINE cLeyenda				CHAR(40);
	DEFINE cRef_servicio			CHAR(40);
	DEFINE	cDescripcionProceso		CHAR(50);
	DEFINE	cCausa_rechazo			CHAR(50);
	DEFINE cNombreCargo			CHAR(50);
	DEFINE cMensaje				CHAR(200);
	DEFINE cNombreCliente 			CHAR(200);
	--DEFINE pNombre_Arch				CHAR(18);
	DEFINE cBandera				CHAR(40);
	DEFINE cNumCredito				CHAR(20);
	DEFINE cTipoCtaAbono			CHAR(2);
	DEFINE iRegistrosDetalle		INTEGER;

	DEFINE cNom_Arch_Aux			CHAR(20);
	DEFINE cNumcteCoppel			CHAR(20);
	DEFINE cNom_Arch_Salida			CHAR(20);
	DEFINE cRFCCoppel				CHAR(18);
	DEFINE cConsecutivoAux			CHAR(6);
	DEFINE cSecuencia_Salida		CHAR(6);
	DEFINE cMinSecuencia_Salida		CHAR(6);
	DEFINE cMaxSecuencia_Salida		CHAR(6);
	DEFINE iContadorRepetidas		INTEGER;
	DEFINE dFechaArchivo_salida		DATE;
	DEFINE cCodSpFecha				CHAR(5);
	DEFINE cMotivoCuenta            CHAR(3);
	--MODIFICACION OB
	DEFINE iAuxValidBin           INTEGER;
    DEFINE iIdUnidadProd          INTEGER;
	DEFINE cPrefijoCuentasPropias CHAR(12);
	DEFINE cCurrentPrefijo 			VARCHAR(12);
	ON EXCEPTION SET iSQLerr
		IF iSQLerr <> 0 THEN
			LET cCodRet = iSQLerr;

			/*FOREACH
				SELECT nombre_arch, fecha_envio, consecutivo, cuenta_abono
				INTO cNombreArchProveedor , dFechaEnvioProveedor, cConsecutivo, cCuentaAbono
				FROM bdidomi:dom_cte_detalle
				WHERE fecha_cargo = cFechaFormat AND accion = 'A' cve_banco_cargo <> cClaVeBancaria

				SELECT SUBSTR(num_cte,12,9)
				INTO cNumCteEncabezado
				FROM bdidomi:dom_cte_encabezado
				WHERE nombre_arch = cNombreArchProveedor
				AND fecha_envio = dFechaEnvioProveedor
				AND cuenta_abono = cCuentaAbono;

				IF cNumCteEncabezado = cNumcteCoppel THEN
					UPDATE bdidomi:dom_cte_detalle
					SET estatus = 'EP', causa_rechazo = ''
					WHERE nombre_arch = cNombreArchProveedor
						AND consecutivo = cConsecutivo;

					DELETE FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch = cNom_Arch_Salida
					AND consecutivo BETWEEN cMinSecuencia_Salida AND cMaxSecuencia_Salida;
				END IF;
			END FOREACH;*/
			RETURN cCodRet;
	    END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_generararch30.trace";
	--TRACE ON;
	--SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_domi_generararch30.out";
	--TRACE ON;

	--	Inicializacion de variables.
	LET cCodRet		= "00000";
	LET cCodRetMensaje	= "";
	LET cCve_proceso	= "GENARCH_30.";
	LET cMensaje		= "";
	LET cEstatus		= "";
	LET cReferenciaServicio		= "";
	LET dFecha_hoy		= "";
	LET cFechaFormat	= "";
	LET cFechaManana    = "";
	LET dFecha_Manana  = "";
	LET cCuentaAbono	= "";
	LET cCuentaCargo	= "";
	LET cNumCliente	= "";
	LET cTpoCtaCargo	= "";
	LET cNombreCargo	= "";
	LET cRFCcargo		= "";
	LET cClaVeBancaria	= "";
	LET cImpIva		= "";
	LET cReferenciaNum	= "";
	LET cLeyenda		= "";
	LET iMotivoDev	= "";
	LET cClaveBancoReceptor = "";
	LET cImpOperacion	= "";
	LET cNombreTitular	= "";
	LET ccuenta_clabe	= "";
	LET cStat			= "";
	LET cTipoRegistro	= "";
	LET cConsecutivo	= "";
	LET cNumCteEncabezado = "";
	LET cCuentaAbono_CLABE = "";
	LET cBanco_receptor	= "";
	LET cFecha_aplica		= "";
	LET cImporte			= "";
	LET cNum_cta_ord		= "";
	LET cRfc_ord			= "";
	LET cNum_cta_rec		= "";
	LET cRef_servicio		= "";
	LET cNum_Secuencia		= "";
	LET cCausa_rechazo		= "";
	LET cDescripcionProceso	="GENERACION DE ARCHIVO COD 30 PRESENTADOR";
	LET iSQLerr		= 0;
	LET iExiste		= 0;
	LET iContadorVueltas = 0;
	LET iRegistros		= 0;
	LET iNvaSecuencia	= 0;
	LET iContadorRepetidas	= 0;
	LET cConsecutivoDetalle = "";
	LET cClaveRastreo = "";
	LET cNombreCliente 	= "";
	LET dFechaEnvioProveedor = "";
	LET cNombreArchProveedor = "";
	LET cNombreArch10	= "";
	LET cFechaPresentacion10 	= "";
	LET cTipoRegistro10	= "";
	LET cNumSecuencia10	= "";
	--LET pNombre_Arch		= "";
	LET cBandera = '';
	LET cNumCredito = '';
	LET cTipoCtaAbono = '';
	LET iRegistrosDetalle = 0;

	LET cNom_Arch_Aux = '';
	LET cNumcteCoppel = '';
	LET cNom_Arch_Salida = '';
	LET cRFCCoppel = '';
	LET cConsecutivoAux = '';
	LET cSecuencia_Salida = '';
	LET cMinSecuencia_Salida = '';
	LET cMaxSecuencia_Salida = '';
	LET iContadorRepetidas = 0;
	LET cCodSpFecha	= '';
	LET cMotivoCuenta = '';
	--MODIFICACION OB
	LET iAuxValidBin = 0;
    LET iIdUnidadProd = -1;
	LET cPrefijoCuentasPropias = '';
	LET cCurrentPrefijo = '';

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_generararch30.out";
	--TRACE ON;

	BEGIN

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO wait 3;

		--	Extrae la fecha hoy en el sistema
		SELECT Fecha_hoy INTO dFecha_hoy FROM bdicheq:sc_fechas;
        LET dFecha_Manana  = dFecha_hoy + 1;
		-- LET cFechamanana =  YEAR(dFecha_Manana )|| LPAD(MONTH (dFecha_Manana ),2,'0') || LPAD(DAY (dFecha_Manana ),2,'0');

		EXECUTE FUNCTION bdinteg:sp_valfecha_banca('001', dFecha_Manana, 0 ) INTO cCodRet,dFecha_Manana;
		LET cFechamanana = YEAR(dFecha_Manana) || LPAD(MONTH (dFecha_Manana),2,'0') || LPAD(DAY (dFecha_Manana),2,'0');

		--	asigna un formato de fecha para futura fecha de presentacion
		LET cFechaFormat = YEAR(dFecha_hoy)|| LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0');

		/*	CALL sp_valida_fecha(cFechamanana) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			EXECUTE FUNCTION bdinteg:sp_valfecha_banca('001', dFecha_Manana, 0 ) INTO cCodRet,dFecha_Manana;
			LET cFechamanana = YEAR(dFecha_Manana) || LPAD(MONTH (dFecha_Manana),2,'0') || LPAD(DAY (dFecha_Manana),2,'0');
			IF cCodRet <>0 THEN
				RETURN cCodRet;
			END IF;
		END IF; */
		--	Valida si el usuario contiene un blanco le asigna informix por default.
		IF pUsuario	= ''THEN
			LET pUsuario = 'informix';
		END IF;

		--	Valida la longitud del usuario
		IF LENGTH (pUsuario) < 8 THEN
			LET cCodRet = '02000';
			--'00900';
			RETURN cCodRet;
		END IF;

		IF LENGTH (pNombre_Arch) < 17 THEN
			LET cCodRet = '02000';
			--'00900';
			RETURN cCodRet;
		END IF;

		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
		SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

		-- Se extrae el prefijo de cuentas propias
		SELECT TRIM(valor) 
		INTO cPrefijoCuentasPropias 
		FROM Dom_Parametros 
		WHERE cod_param = '72';
		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
			LET cCodRet = '02001';
			--'00903';
			RETURN cCodRet;
		END IF;

		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
		SELECT valor INTO cValTarjeta FROM bdidomi:dom_parametros WHERE cod_param = '06';
		SELECT valor INTO cValTarjNuevo FROM bdidomi:dom_parametros WHERE cod_param = '43';

		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cValTarjeta = '' OR cValTarjeta IS NULL OR cValTarjNuevo = '' OR cValTarjNuevo IS NULL Then
			LET cCodRet = '02002';
			--'00904';
			RETURN cCodRet;
		END IF;

		CALL sp_valida_fecha(cFechaFormat) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			RETURN cCodRet;
		END IF;

		--SE OBTIENE NUMERO DE CLIENTE COPPEL
		SELECT TRIM(valor) INTO cNumcteCoppel
		FROM dom_parametros
		WHERE cod_param = '45';

		--SE OBTIENE VALOR DE RFC COPPEL
		SELECT rfc
		INTO cRFCCoppel
		FROM dom_cat_servicios
		WHERE num_cte = TRIM(cNumcteCoppel);

		EXECUTE FUNCTION bdinteg:splvalfecha('001',(dFecha_hoy) + 1 ,0)INTO cCodSpFecha,dFechaArchivo_salida; --a qui ya tengo el dias siguiente habil

		--SE OBTIENE NOMBRE DE ARCHIVO DE SALIDA PARA COPPEL
		LET cNom_Arch_Salida = 	'S'||
								TRIM(cNumcteCoppel)||
								'D'||
								LPAD(DAY(dFechaArchivo_salida),2,'0') || 	LPAD(MONTH(dFechaArchivo_salida),2,'0') || SUBSTR(YEAR(dFechaArchivo_salida)::CHAR(4),3,2)||
								'.'||
								'01';
		TRUNCATE TABLE tmp_detalle_duplicados;

		SELECT LPAD(NVL(MAX(consecutivo),'000000')::INTEGER + 1,6,'0')
		INTO cMinSecuencia_Salida
		FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida;

		FOREACH WITH HOLD
			--Consulta si existe instrucciones de cargo a procesar enviadas por el proveedor.
					--EMPIEZA MODIFICACIÃ¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?N OB
			SELECT 1,cuenta_abono,cuenta_cargo,cve_banco_cargo,imp_operacion,tipo_cta_cargo,nombre_cargo,rfc_cargo,ref_servicio,
				   ref_titular_serv,imp_iva,ref_numerica,ref_leyenda,nombre_arch,fecha_envio,tipo_registro,consecutivo,tipo_cta_abono
			INTO iExiste,cCuentaAbono, cCuentaCargo,cClaveBancoReceptor,cImpOperacion,cTpoCtaCargo,cNombreCargo,cRFCcargo,cReferenciaServicio,
				 cNombreTitular,cImpIva,cReferenciaNum,cLeyenda,cNombreArchProveedor,dFechaEnvioProveedor,cTipoRegistro,cConsecutivo,cTipoCtaAbono
			FROM bdidomi:dom_cte_detalle
			WHERE fecha_cargo = cFechaFormat AND accion = 'A' AND estatus = 'EP' AND cve_banco_cargo <> cClaVeBancaria
											 AND imp_operacion::INTEGER >= 100 -- SE AGREGA CLAUSULA PARA TRAER UNICAMENTE LOS IMPORTES MAYOR O IGUAL A "1"

			-- Se omiten cuentas con bloqueos de pago.
            SELECT COALESCE(mo.id_unidad_prod, m.id_unidad_prod, -1)
            INTO iIdUnidadProd
            FROM bdicred:"informix".sd_tarjeta tar
            LEFT JOIN bdicred:"informix".sd_maecred_old mo
                ON tar.num_credito = mo.num_credito
            LEFT JOIN bdicred:"informix".sd_maecred m
                ON tar.num_credito = m.num_credito
            WHERE tar.num_tarjeta = substr(cCuentaAbono, 5, 16);

            IF iIdUnidadProd IN (2, 4) THEN
                CONTINUE FOREACH;
            END IF;
            -- Termina omision cuentas con bloqueos de pago.

			--MODIFICACIÃ¯Â¿Â½?N OB PARA VALIDACIÃ¯Â¿Â½?N DE DOMICILIACIÃ¯Â¿Â½?N ACTIVA PARA OB
			--LEAA 
			IF SUBSTR(cCuentaAbono,9,11) != '12000000017' THEN --diferente a la cuenta propia de bancoppel 00137180120000000171
          SELECT FIRST 1 ob.estatus  
		  INTO cEstatus 
		  from bdidomi:"informix".dom_archivomanual dom_ma
          INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob ob ON dom_ma.folio_activacion = ob.folio_activacion 
          WHERE dom_ma.estatus = 'EP'
		  AND dom_ma.accion = 'A'
		  AND dom_ma.fecha_cargo = cFechaFormat
		  AND dom_ma.cuenta_abono = cCuentaAbono ;

		  LET cEstatus = COALESCE(cEstatus, '02');

          IF cEstatus != '01'  THEN
		  --cEstatus != '01' OR cEstatus IS NULL OR cEstatus == '' THEN
              UPDATE bdidomi:dom_cte_detalle SET estatus = '02', causa_rechazo = 'Falta de respuesta por CECOBAN o esta cancelada' 
              WHERE cuenta_abono = cCuentaAbono and fecha_envio = dFechaEnvioProveedor;
              CONTINUE FOREACH;
          END IF;

      END IF;
      
				--TERMINA MODIFICACION OB
			LET cCuentaAbono_CLABE = cCuentaAbono;

			SELECT SUBSTR(num_cte,12,9) INTO cNumCteEncabezado FROM bdidomi:dom_cte_encabezado
			WHERE nombre_arch = cNombreArchProveedor
			AND fecha_envio = dFechaEnvioProveedor
			AND cuenta_abono = cCuentaAbono_CLABE;

			--IF  cNumCteEncabezado = cNumcteCoppel THEN
			IF NOT EXISTS(SELECT 1 FROM tmp_detalle_duplicados WHERE nombre_arch = cNombreArchProveedor AND consecutivo = cConsecutivo) THEN
				IF  cNumCteEncabezado = cNumcteCoppel THEN
					SELECT COUNT(*)
					INTO iContadorRepetidas
					FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch =  cNombreArchProveedor
					AND cuenta_cargo = cCuentaCargo
					AND rfc_cargo = cRFCcargo
					AND cve_banco_cargo =  cClaveBancoReceptor
					AND imp_operacion = cImpOperacion
					AND ref_servicio = cReferenciaServicio
					AND estatus ='EP'
					AND accion = 'A';

					IF iContadorRepetidas > 1 THEN
						INSERT INTO tmp_detalle_duplicados
						SELECT nombre_arch, consecutivo
						FROM dom_cte_detalle
						WHERE nombre_arch =  cNombreArchProveedor
							AND cuenta_cargo = cCuentaCargo
							AND rfc_cargo = cRFCcargo
							AND cve_banco_cargo =  cClaveBancoReceptor
							AND imp_operacion = cImpOperacion
							AND ref_servicio = cReferenciaServicio
							AND consecutivo <> cConsecutivo;

						FOREACH SELECT nombre_arch, consecutivo
								INTO cNom_Arch_Aux, cConsecutivoAux
								FROM dom_cte_detalle
								WHERE  nombre_arch =  cNombreArchProveedor
									AND cuenta_cargo = cCuentaCargo
									AND rfc_cargo = cRFCcargo
									AND cve_banco_cargo =  cClaveBancoReceptor
									AND imp_operacion = cImpOperacion
									AND ref_servicio = cReferenciaServicio
									AND consecutivo <> cConsecutivo

							UPDATE bdidomi:dom_cte_detalle SET estatus = '02', causa_rechazo = '07'
							WHERE  nombre_arch =  cNom_Arch_Aux
							AND consecutivo = cConsecutivoAux;

							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
							INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
							WHERE nombre_arch = cNom_Arch_Salida;

							LET cMaxSecuencia_Salida = cSecuencia_Salida;

							INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
								fecha_insert, tipo_cta_abono)
							SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, '02',
								'07', '', '', '', '', '', '', pUsuario,
								CURRENT::DATE, ''
							FROM dom_cte_detalle
							WHERE  nombre_arch =  cNom_Arch_Aux
								AND consecutivo = cConsecutivoAux;
							--LET iRechazos = iRechazos + 1;
							--LET iImpRechazos = iImpRechazos + (mImporte_dom * 100);
						END FOREACH;
					END IF;
				END IF;


				LET iExiste = 0;

				/*SELECT substr(num_cte,12,9) INTO cNumCteEncabezado FROM bdidomi:dom_cte_encabezado
				WHERE nombre_arch = cNombreArchProveedor
				AND fecha_envio = dFechaEnvioProveedor
				AND cuenta_abono = cCuentaAbono_CLABE;*/

				SELECT motivo_dev
				INTO iMotivoDev
				FROM bdidomi:dom_ctas_verificadas WHERE cve_banco = cClaveBancoReceptor AND cuenta = cCuentaCargo;

				IF iMotivoDev IS NULL THEN
				   CONTINUE FOREACH;
				END IF;

				SELECT descripcion INTO cCausa_rechazo FROM bdidomi:dom_cat_devoluciones WHERE motivo_dev = '98';

				IF iMotivoDev <> 99  THEN
					SELECT FIRST 1 nombre_arch,fecha_presentacion,tipo_registro,num_secuencia
					INTO cNombreArch10,cFechaPresentacion10,cTipoRegistro10,cNumSecuencia10
					FROM bdidomi:dom_cce_detalle
					WHERE cod_operacion = '10'
					AND num_cta_ord = cCuentaAbono
					AND num_cta_rec = cCuentaCargo
					AND banco_receptor = cClaveBancoReceptor
					AND tipo_cta_rec = cTpoCtaCargo
					AND nombre_rec = cNombreCargo
					AND rfc_rec = cRFCcargo
					AND ref_servicio = cReferenciaServicio
					AND nombre_titular_serv = cNombreTitular
					AND importe_iva = cImpIva
					AND ref_numerica = cReferenciaNum;
					--AND ref_leyenda = cLeyenda;

					IF cNumCteEncabezado = cNumcteCoppel THEN
						UPDATE bdidomi:dom_cte_detalle SET estatus = '02',causa_rechazo = LPAD (TRIM (iMotivoDev::CHAR(2)),2,'0'),
						nombre_arch_cce = cNombreArch10,fecha_presentacion_cce = cFechaPresentacion10,
						tipo_registro_cce = cTipoRegistro10,numero_secuencia_cce = cNumSecuencia10
						WHERE nombre_arch = cNombreArchProveedor
						AND fecha_envio = dFechaEnvioProveedor
						AND tipo_registro = cTipoRegistro
						AND consecutivo = cConsecutivo
						AND cve_banco_cargo = cClaveBancoReceptor
						AND cuenta_cargo = cCuentaCargo;

						SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
						INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
						WHERE nombre_arch = cNom_Arch_Salida;

						LET cMaxSecuencia_Salida = cSecuencia_Salida;

						LET cNombreArchProveedor = cNombreArchProveedor;
						LET dFechaEnvioProveedor = dFechaEnvioProveedor;
						LET cTipoRegistro = cTipoRegistro;
						LET cConsecutivo = cConsecutivo;
						LET cClaveBancoReceptor = cClaveBancoReceptor;
						LET cCuentaCargo = cCuentaCargo;

						INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus,
							causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
							fecha_insert, tipo_cta_abono)
						SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
							cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus,
							causa_rechazo, '', '', '', '', '', '', pUsuario,
							CURRENT::DATE, ''
						FROM dom_cte_detalle
						WHERE nombre_arch = cNombreArchProveedor
						AND fecha_envio = dFechaEnvioProveedor
						AND tipo_registro = cTipoRegistro
						AND consecutivo = cConsecutivo
						AND cve_banco_cargo = cClaveBancoReceptor
						AND cuenta_cargo = cCuentaCargo;

					ELSE
						UPDATE bdidomi:dom_cte_detalle SET estatus = '02',causa_rechazo = cCausa_rechazo,
						nombre_arch_cce = cNombreArch10,fecha_presentacion_cce = cFechaPresentacion10,
						tipo_registro_cce = cTipoRegistro10,numero_secuencia_cce = cNumSecuencia10
						WHERE nombre_arch = cNombreArchProveedor
						AND fecha_envio = dFechaEnvioProveedor
						AND tipo_registro = cTipoRegistro
						AND consecutivo = cConsecutivo
						AND cve_banco_cargo = cClaveBancoReceptor
						AND cuenta_cargo = cCuentaCargo;
					END IF;
					CONTINUE FOREACH;
				END IF;

				LET cNumCredito = '';

				-- EMPIEZA MODIFICACION TDC OB
				-- IMPERIAL
                SELECT COUNT(*)
                INTO iAuxValidBin
                FROM bdicheq:"informix".sc_bines bin
                INNER JOIN bdinteg:"informix".si_bancos banco
                    ON bin.cve_banco = banco.banco
                WHERE banco.flg_domi_r = '1'
                    AND banco = '137'
                    AND creditodebito = 'c'
                    AND bin = SUBSTR(cCuentaAbono,5,6);

				--Caso de tarjeta de credito --------- FRG_I ---> Se considera el cTipoCtaAbono = '05' o = '03'
				IF cTipoCtaAbono = '05'
--					OR (cTipoCtaAbono = '03' AND SUBSTR(cCuentaAbono,5,6)= '426807')
					OR (cTipoCtaAbono = '03' AND iAuxValidBin > 0)   --MODIFICACION TDC OB PARA TOMAR TODOS LOS BINES
											 --        FRG_F ---> Se considera el cTipoCtaAbono = '05' o = '03'
				THEN
					SELECT numcte,LPAD(num_tarjeta,20,'0'),num_credito INTO cNumCliente,cCuenta_Clabe,cNumCredito
					FROM bdicred:sd_tarjeta
					WHERE empresa = '001'
						AND num_tarjeta = SUBSTR(cCuentaAbono ,5,16);


						LET cBandera = 'TarjetaCredito';
						/*              --        FRG_I ---> Se debe considerar el cTipoCtaAbono = '05' o = '03'
						LET cTipoCtaAbono = '05';
										--        FRG_F ---> Se debe considerar el cTipoCtaAbono = '05' o = '03'
						*/

					SELECT 1 INTO iExiste FROM bdicred:sd_maecred WHERE empresa = '001' AND num_credito = cNumCredito;

					IF iExiste IS NULL THEN
						--En el caso de que no exista en el maestro de credito.
						UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = '01'
						WHERE nombre_arch = cNombreArchProveedor
						AND fecha_envio = dFechaEnvioProveedor
						AND tipo_registro = cTipoRegistro
						AND consecutivo = cConsecutivo
						AND cve_banco_cargo = cClaveBancoReceptor
						AND cuenta_abono = cCuentaAbono;

						IF cNumCteEncabezado = cNumcteCoppel THEN
							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
							INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
							WHERE nombre_arch = cNom_Arch_Salida;

							LET cMaxSecuencia_Salida = cSecuencia_Salida;

							INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
								fecha_insert, tipo_cta_abono)
							SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, '', '', '', '', '', '', pUsuario,
								CURRENT::DATE, ''
							FROM dom_cte_detalle
							WHERE nombre_arch = cNombreArchProveedor
							AND fecha_envio = dFechaEnvioProveedor
							AND tipo_registro = cTipoRegistro
							AND consecutivo = cConsecutivo
							AND cve_banco_cargo = cClaveBancoReceptor
							AND cuenta_abono = cCuentaAbono;
						END IF;

						CONTINUE FOREACH;
					END IF;
				ELSE

					LET cBandera = 'CuentaClabe-Tarjeta';

					SELECT 1 INTO iExiste FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(cCuentaAbono ,5,16);
					LET cTipoCtaAbono = '40';
						--	Valida si existe la tarjeta y esta en el rango del valor de la tarjeta.
					IF iExiste = 1 THEN
						--	extrae la cuenta por el # tarjeta para el abono_ref.
						SELECT cuenta,numcte INTO cCuentaAbono, cNumCliente FROM bdicheq:sc_tarjeta
						Where empresa = '001' AND num_tarjeta = SUBSTR(cCuentaAbono ,5,16)
						AND (SUBSTR(num_tarjeta,1,6) = cValTarjeta OR  SUBSTR(num_tarjeta,1,6) = cValTarjNuevo)
						AND tipo_tarjeta = 'T';

					ELSE
						--	Valida si existe en forma de cuenta clabe.
						SELECT 1,num_cte,cuenta,cuenta_clabe,status_cta,motivo INTO iExiste,cNumCliente,cCuentaAbono,cCuenta_Clabe,cStat,cMotivoCuenta
						FROM bdicheq:sc_maechq
						WHERE empresa = '001' AND cuenta = SUBSTR (cCuentaAbono,9,11);

						IF iExiste IS NULL THEN
							--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
							IF cNumCteEncabezado = cNumcteCoppel THEN
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = LPAD (TRIM (iMotivoDev::CHAR(2)),2,'0')
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

								SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
								INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
								WHERE nombre_arch = cNom_Arch_Salida;

								LET cMaxSecuencia_Salida = cSecuencia_Salida;

								INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
									fecha_insert, tipo_cta_abono)
								SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, '', '', '', '', '', '', pUsuario,
									CURRENT::DATE, ''
								FROM dom_cte_detalle
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
							ELSE
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
							END IF;
							CONTINUE FOREACH;
						END IF;

						IF TRIM(cStat) = '2' THEN
							--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
							IF cNumCteEncabezado = cNumcteCoppel THEN
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = LPAD (TRIM (iMotivoDev::CHAR(2)),2,'0')
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

								SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
								INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
								WHERE nombre_arch = cNom_Arch_Salida;

								LET cMaxSecuencia_Salida = cSecuencia_Salida;

								INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
									fecha_insert, tipo_cta_abono)
								SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, '', '', '', '', '', '', pUsuario,
									CURRENT::DATE, ''
								FROM dom_cte_detalle
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

							ELSE
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
							END IF;
							CONTINUE FOREACH;
						END IF;
						--Se realiza cambio en validacion para que permita la domiciliacion de cuenta coppel aunque este bloqueada por motivo de monto
						--a solicitud de Silvestre Carrillo
						--IF TRIM(cStat) = '3' THEN

						IF cCuentaAbono <> '12000000017'  THEN

							IF TRIM(cStat) = '3' THEN

								SELECT descripcion INTO cCausa_rechazo FROM bdidomi:dom_cat_devoluciones WHERE motivo_dev = '02';

								IF cNumCteEncabezado = cNumcteCoppel  THEN
									UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = '02'
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

									SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
									INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
									WHERE nombre_arch = cNom_Arch_Salida;

									LET cMaxSecuencia_Salida = cSecuencia_Salida;

									INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
										cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
										ref_titular_serv, accion, reintentar_cuenta, estatus,
										causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
										fecha_insert, tipo_cta_abono)
									SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
										cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
										ref_titular_serv, accion, reintentar_cuenta, estatus,
										causa_rechazo, '', '', '', '', '', '', pUsuario,
										CURRENT::DATE, ''
									FROM dom_cte_detalle
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

								ELSE
									--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
									UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
								END IF;
								CONTINUE FOREACH;

							END IF;

						ELSE
							 IF cMotivoCuenta <> '09' AND cMotivoCuenta <> '00' AND TRIM(cStat) = '3' THEN

								IF cNumCteEncabezado = cNumcteCoppel  THEN
									UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = '02'
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

									SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
									INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
									WHERE nombre_arch = cNom_Arch_Salida;

									LET cMaxSecuencia_Salida = cSecuencia_Salida;

									INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
										cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
										ref_titular_serv, accion, reintentar_cuenta, estatus,
										causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
										fecha_insert, tipo_cta_abono)
									SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
										cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
										ref_titular_serv, accion, reintentar_cuenta, estatus,
										causa_rechazo, '', '', '', '', '', '', pUsuario,
										CURRENT::DATE, ''
									FROM dom_cte_detalle
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

								ELSE
									--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
									UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
									WHERE nombre_arch = cNombreArchProveedor
									AND fecha_envio = dFechaEnvioProveedor
									AND tipo_registro = cTipoRegistro
									AND consecutivo = cConsecutivo
									AND cve_banco_cargo = cClaveBancoReceptor
									AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
								END IF;
								CONTINUE FOREACH;
							 END IF;
						END IF;



						IF cNumCteEncabezado IS NULL  THEN
							--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
							UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
							WHERE nombre_arch = cNombreArchProveedor
							AND fecha_envio = dFechaEnvioProveedor
							AND tipo_registro = cTipoRegistro
							AND consecutivo = cConsecutivo
							AND cve_banco_cargo = cClaveBancoReceptor
							AND cuenta_abono = cCuentaAbono_CLABE;
							CONTINUE FOREACH;
						END IF;

						IF cNumCliente IS NULL THEN
							--En el caso de que no exista la cuenta ni como clabe,tarjeta o cuenta se rechaza y se asigna la causa.
							IF cNumCteEncabezado = cNumcteCoppel THEN
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = '02'
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

								SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
								INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
								WHERE nombre_arch = cNom_Arch_Salida;

								LET cMaxSecuencia_Salida = cSecuencia_Salida;

								INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
									fecha_insert, tipo_cta_abono)
								SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
									cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus,
									causa_rechazo, '', '', '', '', '', '', pUsuario,
									CURRENT::DATE, ''
								FROM dom_cte_detalle
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

							ELSE
								UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = cCausa_rechazo
								WHERE nombre_arch = cNombreArchProveedor
								AND fecha_envio = dFechaEnvioProveedor
								AND tipo_registro = cTipoRegistro
								AND consecutivo = cConsecutivo
								AND cve_banco_cargo = cClaveBancoReceptor
								AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
							END IF;
							CONTINUE FOREACH;
						END IF;
					END IF;

					SELECT 1 INTO iExiste FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaAbono AND num_cte = cNumCteEncabezado;

					IF iExiste IS NULL THEN
						--En el caso de que no exista el cliente en el encabezado se rechaza y se asigna la causa.
						UPDATE bdidomi:dom_cte_detalle  SET estatus = '02',causa_rechazo = '01'
						WHERE nombre_arch = cNombreArchProveedor
						AND fecha_envio = dFechaEnvioProveedor
						AND tipo_registro = cTipoRegistro
						AND consecutivo = cConsecutivo
						AND cve_banco_cargo = cClaveBancoReceptor
						AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;

						IF cNumCteEncabezado = cNumcteCoppel THEN
							SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
							INTO cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
							WHERE nombre_arch = cNom_Arch_Salida;

							LET cMaxSecuencia_Salida = cSecuencia_Salida;

							INSERT INTO dom_cte_detalle_paso (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
								fecha_insert, tipo_cta_abono)
							SELECT cNom_Arch_Salida,dFechaArchivo_salida,tipo_registro,cSecuencia_Salida, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
								cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus,
								causa_rechazo, '', '', '', '', '', '', pUsuario,
								CURRENT::DATE, ''
							FROM dom_cte_detalle
							WHERE nombre_arch = cNombreArchProveedor
							AND fecha_envio = dFechaEnvioProveedor
							AND tipo_registro = cTipoRegistro
							AND consecutivo = cConsecutivo
							AND cve_banco_cargo = cClaveBancoReceptor
							AND SUBSTR (cuenta_abono,9,11) = cCuentaAbono;
						END IF;
						CONTINUE FOREACH;
					END IF;
				END IF;


				--Extrae la secuencia siguiente.
				SELECT LPAD((COUNT (num_secuencia) + 2) ::INTEGER,7,'0'),TRIM(pNombre_Arch)||LPAD(COUNT (num_secuencia):: INTEGER + 1 ,2,'0')INTO cConsecutivoDetalle,cClaveRastreo FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch;
				LET cReferenciaNum =  lpad(TRIM((cReferenciaNum::integer)::char(7)),7,'0');
				--EMPIEZA MODIFICACION OB
				----L.AGUILERA

				SELECT COUNT(*)
				INTO iAuxValidBin
				FROM bdicheq:"informix".sc_bines bin
                	INNER JOIN bdinteg:"informix".si_bancos banco ON bin.cve_banco = banco.banco
                WHERE banco.flg_domi_r = '1' AND banco = '137' AND creditodebito = 'c' AND bin = SUBSTR(cCuentaAbono,5,6);

				IF cTipoCtaAbono = '05'
					--				FRG_I ---> Se considera el cTipoCtaAbono = '05' o = '03'
					--OR (cTipoCtaAbono = '03' AND SUBSTR(cCuentaAbono,5,6) = '426807')
				OR (cTipoCtaAbono = '03' AND iAuxValidBin > 0)   -- MODIFICACION TDC OB PARA TOMAR TODOS LOS BINES
				--TERMINA MODIFICACION OB
				THEN
					SELECT NVL(TRIM(TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '|| TRIM(razon_social)  ),'') INTO cNombreCliente FROM bdinteg:si_cliente WHERE numcte = cNumCliente;
					SELECT valor INTO cNumCliente FROM bdidomi:dom_parametros WHERE cod_param = '36';
					Select rfc INTO cRFCcliente From dom_cat_servicios WHERE num_cte = cNumCliente;
				ELSE
				--Extrae el nombre completo y rfc
					SELECT NVL(TRIM(TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '|| TRIM(razon_social)  ),''),NVL(TRIM(rfc),'') INTO cNombreCliente,cRFCcliente FROM bdinteg:si_cliente WHERE numcte = cNumCliente;
				END IF;

		        EXECUTE PROCEDURE sp_reemplazar_n_acentos_ob(cNombreCliente)
		        INTO cNombreCliente;

		        EXECUTE PROCEDURE sp_reemplazar_n_acentos_ob(cNombreCargo)
		        INTO cNombreCargo;
				
				
				LET cCurrentPrefijo = SUBSTR(cCuentaAbono, 9, 11);
				
				IF cCurrentPrefijo <> cPrefijoCuentasPropias THEN
					EXECUTE PROCEDURE sp_reemplazar_n_acentos_ob(cNombreTitular)
					INTO cNombreTitular;
				END IF;
				
				INSERT INTO bdidomi:dom_cce_detalle_paso (nombre_arch, fecha_presentacion, tipo_registro, num_secuencia, cod_operacion, cod_divisa, fecha_trans,
							banco_presentador, banco_receptor, importe, uso_futuro_ccen, tipo_operacion,fecha_aplica, tipo_cta_ord,num_cta_ord, nombre_ord, rfc_ord,
							tipo_cta_rec, num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda,clave_rastreo,
							motivo_dev, fecha_pres_ini, uso_futuro_banco, cve_estatus, folio_suc, user_insert,fecha_insert)

				VALUES 		(pNombre_Arch, cFechaFormat, '02', cConsecutivoDetalle,'30','01',cFechamanana,
							cClaVeBancaria,cClaveBancoReceptor,cImpOperacion,'','51',cFechaFormat,cTipoCtaAbono, LPAD(TRIM(cCuenta_Clabe),20,'0'),
							cNombreCliente,
							NVL(cRFCcliente,''),
							cTpoCtaCargo, LPAD(TRIM(cCuentaCargo),20,'0'), cNombreCargo, cRFCcargo, cReferenciaServicio, cNombreTitular,
							cImpIva,cReferenciaNum, cLeyenda,cClaveRastreo,
							'00',cFechaFormat,'','00','',pUsuario,CURRENT::DATE);

				LET iContadorVueltas = iContadorVueltas +1;
				--	Aplicar la optimizacion de tabla.
				IF iContadorVueltas = 500 THEN
					UPDATE STATISTICS MEDIUM FOR TABLE bdidomi:dom_cce_detalle_paso;
				END IF;
				IF iContadorVueltas = 5000 THEN
					UPDATE STATISTICS MEDIUM FOR TABLE bdidomi:dom_cce_detalle_paso;
				END IF;
				IF iContadorVueltas = 50000 THEN
					UPDATE STATISTICS MEDIUM FOR TABLE bdidomi:dom_cce_detalle_paso;
					LET iContadorVueltas = 1;
				END IF;
			END IF;
		END FOREACH;


		IF EXISTS (SELECT * FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch) THEN

			SELECT COUNT(*) INTO  iRegistrosDetalle FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch;

			FOREACH
				--	Extrae los datos para vericar transacciones duplicadas.
				SELECT Det.banco_receptor,Det.fecha_aplica,Det.importe,Det.num_cta_ord,Det.rfc_ord,Det.num_cta_rec,Det.ref_servicio,num_secuencia
				INTO cBanco_receptor,cFecha_aplica,cImporte,cNum_cta_ord,cRfc_ord,cNum_cta_rec,cRef_servicio,cNum_Secuencia
				FROM bdidomi:dom_cce_detalle_paso AS Det
				WHERE  nombre_arch =  pNombre_Arch
				AND	Det.cod_operacion = '30'
				AND Det.cve_estatus <> '02'

				SELECT COUNT(num_cta_rec) INTO iContadorRepetidas FROM bdidomi:dom_cce_detalle_paso
				WHERE nombre_arch =  pNombre_Arch
				AND Banco_receptor = cBanco_receptor
				AND Fecha_aplica = cFecha_aplica
				AND Importe = cImporte
				AND Num_cta_ord = cNum_cta_ord
				AND Rfc_ord = cRfc_ord
				AND Num_cta_rec = cNum_cta_rec
				AND Ref_servicio = cRef_servicio;

				IF iContadorRepetidas > 1 THEN

					DELETE FROM bdidomi:dom_cce_detalle_paso
					WHERE nombre_arch =  pNombre_Arch
					AND Banco_receptor = cBanco_receptor
					AND Fecha_aplica = cFecha_aplica
					AND Importe = cImporte
					AND Num_cta_ord = cNum_cta_ord
					AND Rfc_ord = cRfc_ord
					AND Num_cta_rec = cNum_cta_rec
					AND Ref_servicio = cRef_servicio
					AND num_secuencia <> cNum_Secuencia;

				END IF;
			END FOREACH;

			--SELECT COUNT(*) INTO iContadorRepetidas FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch =  pNombre_Arch;
			UPDATE bdidomi:dom_cce_detalle_paso SET num_secuencia = LPAD (num_secuencia::INTEGER + iRegistrosDetalle,7,'0')
			WHERE nombre_arch =  pNombre_Arch;

			--IF iContadorRepetidas > 1 THEN
				LET iNvaSecuencia = iNvaSecuencia + 2;
				FOREACH

					SELECT num_secuencia INTO cNum_secuencia FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch =  pNombre_Arch



					UPDATE bdidomi:dom_cce_detalle_paso SET num_secuencia = LPAD (iNvaSecuencia,7,'0')
					WHERE nombre_arch =  pNombre_Arch AND num_secuencia = cNum_secuencia;

					LET iNvaSecuencia = iNvaSecuencia + 1;
				END FOREACH;
			--END IF;

			--ENCABEZADO
			INSERT INTO bdidomi:dom_cce_encabezado_paso
			(nombre_arch,
			fecha_presentacion,
			tpo_registro,
			num_secuencia,
			cod_operacion,
			cve_banco,
			sentido,
			servicio,
			num_bloque,
			cod_divisa,
			cve_rechazo_bl,
			modalidad,
			uso_futuro_ccen,
			uso_futuro_banco,
			user_insert,
			fecha_insert)

			VALUES
			(pNombre_Arch,
			cFechaFormat,
			'01',
			'0000001',
			'30',
			cClaVeBancaria,
			'E',
			'2',
			LPAD(DAY(dFecha_hoy),2,'0')||LPAD(SUBSTR(pNombre_Arch,16,2),5,'0'),
			'01',
			'00', 	--cve_rechazo_bl
			'2',	--modalidad
			'',		--uso_futuro_ccen
			'',		--uso_futuro_banco
			pUsuario,
			CURRENT::DATE);

			--SUMARIO
			INSERT INTO bdidomi:dom_cce_sumario_paso
			(nombre_arch,
			fecha_presentacion,
			tipo_registro,
			num_secuencia,
			cod_operacion,
			num_bloque,
			num_operaciones,
			imp_operaciones,
			uso_futuro_ccen,
			uso_futuro_banco,
			user_insert,
			fecha_insert)

			VALUES
			(pNombre_Arch,
			cFechaFormat,
			'09',
			(SELECT LPAD(NVL(MAX (num_secuencia +1)::INTEGER,0),7,'0') FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch),--Secuencia maxima
			'30',
			LPAD(DAY(dFecha_hoy),2,'0')||LPAD(SUBSTR(pNombre_Arch,16,2),5,'0'),
			(SELECT LPAD(COUNT (num_secuencia)::INTEGER,7,'0') FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch),--Numero de registros
			(SELECT LPAD(SUM(importe::INTEGER),18,'0') FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = pNombre_Arch),--Importe de operaciones.
			'',			--uso_futuro_ccen
			'',			--uso_futuro_banco
			pUsuario,
			CURRENT::DATE);
		END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Antonio Bastidas Lopez',
'Descripcion: Genera las instrucciones de cargos para formar el archivos 30 Y prepara las tablas para que los valide CCE',
'Fecha: 2009/08/28',
'Version: 20090910.1721',
'Ultima modificacion: Jesus Antonio Bastidas Lopez',
'Descripcion: Adaptar el proceso para permitir la generaciÃ¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?ÃÂ³n de archivos con tarjetas de crÃ¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?Ã¯Â¿Â½?ÃÂ©dito',
'Fecha: 2010/01/29',
'Version: 20100129.1740',
'BD: BDIDOMI',
'Descripcion: Se modifica para que inserte en la tabla de dom_cte_detalle_paso',
'Fecha: 2017/10/04',
'Modifica: Ingrid Pamela Cazarez Villegas';

CREATE PROCEDURE "informix".sp_domi_procesararchivo31(pNombreArchivo CHAR(20), pFechaPresen CHAR(8), pUser_insert CHAR(8))
RETURNING CHAR(5);
--Declaracion de variables
DEFINE  cSqlerr         			INTEGER;
DEFINE  cCodret         			CHAR(5);
DEFINE  cCodret2       				CHAR(5);
DEFINE dFechaActual     			DATE;
DEFINE v_sRetCodSP      			CHAR(5);
DEFINE v_dFechaReSp     			DATE;
DEFINE cCicloFech       			CHAR(1);
DEFINE cBancNom         			CHAR(3);
DEFINE cDiaNom          			CHAR(2);
DEFINE cAnoNom          			CHAR(4);
DEFINE cMesNom          			CHAR(2);
DEFINE cConseNom        			CHAR(2);
DEFINE cNomFecha        			CHAR(20);
DEFINE dFechaHabil      			DATE;
DEFINE cCodSpFecha      			CHAR(5);
DEFINE cFechaFormateada 			DATE;
DEFINE cCargoComision   			CHAR(4);
DEFINE cDescripcionCargoComision 	CHAR(50);
DEFINE cCargoIva 					CHAR(4);
DEFINE cDescripcionCargoIva 		CHAR(50);
DEFINE cCuentaCargo 				CHAR(20);
DEFINE cRfc 						CHAR(18);
DEFINE mTotalCargosaEfectuar 		MONEY(18,2);
DEFINE mTotalCargos 				MONEY(18,2);
DEFINE mIva 						MONEY(15,2);
DEFINE cCodRet1 					CHAR(5);
DEFINE cNumeroFolioCargo 			CHAR(16);
DEFINE cNumeroFolioAbono 			CHAR(16);
DEFINE cSucursalCargo 				CHAR(4);
DEFINE cSucursalContable 			CHAR(4);
DEFINE cTranret 					CHAR(4);
DEFINE cMensaje 					CHAR(100);
DEFINE mSaldoCtaCargo 				MONEY(18,2);
DEFINE mComision 					MONEY(18,2);
DEFINE vMontoret 					MONEY(18,2);
DEFINE vfechoy 						DATE;
DEFINE iTotalRegistros 				INTEGER;
DEFINE mIvaTotal 					MONEY(18,2);
DEFINE mComisionTotal 				MONEY(18,2);
DEFINE mComisionPendiente   		MONEY(18,2);
DEFINE iExiste 						INTEGER;
DEFINE c_cve_ras 					CHAR(30);
DEFINE cRfcCopp 					CHAR(18);
DEFINE cMotivodev 					CHAR(2);

---- Variables encabezado -----
DEFINE cNombre_archE 				CHAR(20);
DEFINE cFecha_presentacionE 		CHAR(8);
DEFINE cTpo_registro 				CHAR(2);
DEFINE cNum_secuenciaE 				CHAR(7);
DEFINE cCod_operacionE 				CHAR(2);
DEFINE cCve_banco 					CHAR(3);
DEFINE cSentido 					CHAR(1);
DEFINE cServicio 					CHAR(1);
DEFINE cNum_bloque 					CHAR(7);
DEFINE cCod_divisaE 				CHAR(2);
DEFINE cCve_rechazo_bl				CHAR(2);
DEFINE cModalidad 					CHAR(1);
DEFINE cUso_futuro_ccenE 			CHAR(41);
DEFINE cUso_futuro_bancoE 			CHAR(345);
DEFINE cUser_insertE 				CHAR(8);
DEFINE dFecha_insertE 				DATE;

---- Variables detalle -----
DEFINE cNombre_archD 				CHAR(20);
DEFINE cFecha_presentacionD 		CHAR(8);
DEFINE cTipo_registro 				CHAR(2);
DEFINE cNum_secuenciaD 				CHAR(7);
DEFINE cCod_operacionD 				CHAR(2);
DEFINE cCod_divisaD 				CHAR(2);
DEFINE cFecha_trans 				CHAR(8);
DEFINE cBanco_presentador 			CHAR(3);
DEFINE cBanco_receptor 				CHAR(3);
DEFINE cImporte 					CHAR(15);
DEFINE cUso_futuro_ccenD 			CHAR(16);
DEFINE cTipo_operacion 				CHAR(2);
DEFINE cFecha_aplica 				CHAR(8);
DEFINE cTipo_cta_ord 				CHAR(2);
DEFINE cNum_cta_ord 				CHAR(20);
DEFINE cNombre_ord 					CHAR(40);
DEFINE cRfc_ord 					CHAR(18);
DEFINE cTipo_cta_rec 				CHAR(2);
DEFINE cNum_cta_rec 				CHAR(20);
DEFINE cNombre_rec 					CHAR(40);
DEFINE cRfc_rec 					CHAR(18);
DEFINE cRef_servicio 				CHAR(40);
DEFINE cNombre_titular_serv 		CHAR(40);
DEFINE cImporte_iva 				CHAR(15);
DEFINE cRef_numerica 				CHAR(7);
DEFINE cRef_leyenda 				CHAR(40);
DEFINE cClave_rastreo 				CHAR(30);
DEFINE cMotivo_dev 					CHAR(2);
DEFINE cFecha_pres_ini 				CHAR(8);
DEFINE cUso_futuro_bancoD 			CHAR(12);
DEFINE cCve_estatus 				CHAR(2);
DEFINE cFolio_suc 					CHAR(16);
DEFINE cUser_insertD 				CHAR(8);
DEFINE dFecha_insertD 				DATE;
DEFINE cNom_Arch_Salida				CHAR(20);
DEFINE cSecuencia					CHAR(6);

---- Variables sumario -----
DEFINE cNombre_archS 				CHAR(20);
DEFINE cFecha_presentacionS 		CHAR(8);
DEFINE cFecha_presentacion30 		CHAR(8);
DEFINE cTipo_registroS 				CHAR(2);
DEFINE cNum_secuenciaS 				CHAR(7);
DEFINE cCod_operacionS 				CHAR(2);
DEFINE cNum_bloqueS 				CHAR(7);
DEFINE cNum_operaciones 			CHAR(7);
DEFINE cImp_operaciones 			CHAR(18);
DEFINE cUso_futuro_ccenS 			CHAR(40);
DEFINE cUso_futuro_bancoS 			CHAR(339);
DEFINE cUser_insertS 				CHAR(8);
DEFINE dFecha_insertS 				DATE;
DEFINE iNum_Reintentos 				INTEGER;
DEFINE iNum_Intentos 				INTEGER;
------Tabla Cliente Detalle---------------------------------------------------------------------------------
--Variables  dom_cte_detalle
DEFINE cNombre_arch_cteD 			CHAR(20);
DEFINE dFecha_envio_cteD 			DATE;
DEFINE cTipo_registro_cteD 			CHAR(1);
DEFINE cConsecutivo_cteD 			CHAR(6);
DEFINE cFecha_cargo_cteD 			CHAR(8);
DEFINE cFecha_cargo_cteDAux			CHAR(8);
DEFINE cFecha_abono_cteD       		CHAR(8);
DEFINE cFecha_abono_cteDAux    		CHAR(8);
DEFINE cNombre_arch_cce_cteD 		CHAR(20);
DEFINE cFecha_presentacion_cce_cteD CHAR(8);
DEFINE cTipo_registro_cce_cteD 		CHAR(2);
DEFINE cNumero_secuencia_cce_cteD 	CHAR(7);
DEFINE cDescripcionMotivo 			CHAR(50);
DEFINE cNombre_Arch30 				CHAR(20);
DEFINE cNum_secuencia30 			CHAR(7);
DEFINE cNumCtaCoppel	            CHAR(20);
DEFINE cNumCte_Coppel            	CHAR(20);
DEFINE cNumCte_Proveedor			CHAR(20);
DEFINE dFecha_hoy					DATE;
DEFINE dFecha_Comision				DATE;
DEFINE cNumBancoPropio				CHAR(3);

DEFINE nrows INTEGER;

LET cCicloFech = '';
LET cNombre_Arch30 = '';
LET cDescripcionMotivo = '';
LET iExiste = 0;
LET mComisionPendiente = 0.00;
--INICIALIZAR Variables  dom_cte_detalle
LET cNombre_arch_cteD = '';
LET dFecha_envio_cteD = CURRENT;
LET cTipo_registro_cteD = '';
LET cConsecutivo_cteD = '';
LET cFecha_cargo_cteD = '';
LET cFecha_abono_cteD = '';
LET cNombre_arch_cce_cteD = '';
LET cFecha_presentacion_cce_cteD = '';
LET cTipo_registro_cce_cteD = '';
LET cNumero_secuencia_cce_cteD = '';
LET v_sRetCodSP = '00000';
LET v_dFechaReSp = CURRENT;
LET cFecha_presentacion30 = '';
LET cNum_secuencia30 = '';
LET c_cve_ras = "";
LET cFecha_cargo_cteDAux = '';
LET cFecha_abono_cteDAux = '';
-----------------------------------------------------------------------------------------------------------------
--Inicializacion de variables
LET cCodret     = "00000";
LET cCodret2    = "00000";
LET v_sRetCodSP = "";
LET cCicloFech = "S";
LET cBancNom = "";
LET cDiaNom = "";
LET cAnoNom = "";
LET cMesNom = "";
LET cConseNom = "";
LET cNomFecha = "";
LET iNum_Reintentos = 0;
LET dFechaHabil = CURRENT;
LET cCodSpFecha = '00000';
LET cFechaFormateada = CURRENT;
LET cCargoComision = ' ';
LET cCargoIva = ' ';
LET cCuentaCargo = ' ';
LET cRfc = ' ';
LET mTotalCargosaEfectuar = 0.00;
LET mTotalCargos = 0.00;
LET mIva = 0.00;
LET cCodRet1 = '00000';
LET cNumeroFolioCargo = ' ';
LET cSucursalCargo = ' ';
LET cSucursalContable = ' ';
LET cTranret = ' ';
LET mSaldoCtaCargo = 0.00;
LET vMontoret = 0.00;
LET mComision = 0.00;
LET iTotalRegistros = 0 ;
LET vfechoy = CURRENT;
LET cRfcCopp = '';
LET cMotivodev = '';

----Inicializar variables encabezado -----
LET cNombre_archE ='';
LET cFecha_presentacionE='';
LET cTpo_registro ='';
LET cNum_secuenciaE ='';
LET cCod_operacionE ='';
LET cCve_banco ='';
LET cSentido ='';
LET cServicio ='';
LET cNum_bloque ='';
LET cCod_divisaE ='';
LET cCve_rechazo_bl ='';
LET cModalidad ='';
LET cUso_futuro_ccenE ='';
LET cUso_futuro_bancoE ='';
LET cUser_insertE ='';
LET dFecha_insertE ='';

---Inicializar variables detalle
LET cNombre_archD ='';
LET cFecha_presentacionD ='';
LET cTipo_registro ='';
LET cNum_secuenciaD ='';
LET cCod_operacionD ='';
LET cCod_divisaD ='';
LET cFecha_trans ='';
LET cBanco_presentador ='';
LET cBanco_receptor ='';
LET cImporte ='';
LET cUso_futuro_ccenD ='';
LET cTipo_operacion ='';
LET cFecha_aplica ='';
LET cTipo_cta_ord ='';
LET cNum_cta_ord ='';
LET cNombre_ord ='';
LET cRfc_ord ='';
LET cTipo_cta_rec ='';
LET cNum_cta_rec ='';
LET cNombre_rec ='';
LET cRfc_rec ='';
LET cRef_servicio ='';
LET cNombre_titular_serv ='';
LET cImporte_iva ='';
LET cRef_numerica ='';
LET cRef_leyenda ='';
LET cClave_rastreo ='';
LET cMotivo_dev ='';
LET cFecha_pres_ini ='';
LET cUso_futuro_bancoD ='';
LET cCve_estatus ='';
LET cFolio_suc ='';
LET cUser_insertD ='';
LET dFecha_insertD ='';
LET cNom_Arch_Salida	= '';
LET cNumCte_Coppel = '';
LET cNumCte_Proveedor = '';
LET cSecuencia = '';
			

----Inicializar variables sumario -----
LET cNombre_archS='';
LET cFecha_presentacionS ='';
LET cTipo_registroS ='';
LET cNum_secuenciaS ='';
LET cCod_operacionS ='';
LET cNum_bloqueS ='';
LET cNum_operaciones ='';
LET cImp_operaciones ='';
LET cUso_futuro_ccenS ='';
LET cUso_futuro_bancoS ='';
LET cUser_insertS ='';
LET dFecha_insertS ='';

LET cNumCtaCoppel = '';
LET dFecha_hoy = '';
LET dFecha_Comision = '';
LET cNumBancoPropio = '';


       -- SET debug FILE TO "/tmp/Antonio/Sp_Domi_ProcesarArchivo31.out";
       -- TRACE ON;

BEGIN
	--- Control de Errores No Controlados
	ON EXCEPTION SET cSqlerr
		IF cSqlerr <> 0 THEN
				LET cCodret = cSqlerr;
				RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	-- consulta la fecha actual del sistema de integral
    SELECT fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;
	-- Se obtienen los valores de las transacciones que estÃÂ¡n en la tabla de parÃÂ¡metros
	--SELECT VALOR, DESCRIPCION INTO cCargoComision, cDescripcionCargoComision FROM bdiDOMI:dom_parametros where cod_param = '14';
	SELECT VALOR, DESCRIPCION INTO cCargoComision, cDescripcionCargoComision FROM bdiDOMI:dom_parametros where cod_param = '50';
	SELECT VALOR, DESCRIPCION INTO cCargoIva, cDescripcionCargoIva FROM bdiDOMI:dom_parametros where cod_param = '15';
	SELECT VALOR INTO cSucursalCargo FROM bdidomi:dom_parametros WHERE cod_param = '07';
	SELECT VALOR INTO mIva FROM bdinteg:si_param  WHERE cod_param = '47';
	
	SELECT TRIM(valor) INTO cNumBancoPropio
	FROM dom_parametros 
	WHERE cod_param = '05';
	
	--SE OBTIENE NUMERO DE CLIENTE COPPEL
	SELECT TRIM(valor) INTO cNumCte_Coppel 
	FROM dom_parametros 
	WHERE cod_param = '45';
	
	--SE OBTIENE VALOR DE RFC COPPEL	
	SELECT rfc 
	INTO cRfcCopp 
	FROM dom_cat_servicios 
	WHERE num_cte = TRIM(cNumCte_Coppel);
	
	--SE OBTIENE FECHA
	SELECT fecha_hoy INTO dFecha_hoy FROM bdicheq:sc_fechas;
	
	--SE OBTIENE NOMBRE DE ARCHIVO DE SALIDA PARA COPPEL 
	LET cNom_Arch_Salida = 	'S'||
							TRIM(cNumCte_Coppel)||
							'D'||
							LPAD(DAY(dFecha_hoy),2,'0') || 	LPAD(MONTH(dFecha_hoy),2,'0') || SUBSTR(YEAR(dFecha_hoy)::CHAR(4),3,2)||
							'.'||
							'01';
	
	FOREACH
		-- Selecciona la cuenta a procesar
		SELECT  Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Cod_divisa,
						Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen, Tipo_operacion, Fecha_aplica, Tipo_cta_ord,
						Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec, Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv,
						Importe_iva, Ref_numerica, Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus,
						Folio_suc, User_insert, Fecha_insert,clave_rastreo
		INTO    cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
						cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica, cTipo_cta_ord,
						cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,
						cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev, cFecha_pres_ini, cUso_futuro_bancoD, cCve_estatus,
						cFolio_suc, cUser_insertD, dFecha_insertD, c_cve_ras
		FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '31'
		--- Validaciones de los campos para ver que exista el registro con clave 30 de lo contrario se rechaza el archivo
	-- Variables que deben concordar los registros de 30 y 31
		IF(NOT EXISTS(SELECT nombre_arch  FROM Dom_cce_detalle WHERE Cod_operacion = '30' AND Importe = cImporte AND Tipo_operacion = cTipo_operacion
				AND Fecha_aplica = cFecha_aplica AND Tipo_cta_ord = cTipo_cta_ord AND Num_cta_ord = cNum_cta_ord AND Rfc_ord = cRfc_ord
				AND Tipo_cta_rec = cTipo_cta_rec AND Num_cta_rec = cNum_cta_rec AND Rfc_rec = cRfc_rec AND Ref_servicio = cRef_servicio
				AND tipo_registro = '02' AND clave_rastreo = c_cve_ras))THEN
				LET cMensaje = 'No existe un registro con cÃÂ³digo 30 que corrobore el registro que se esta validando';
				LET cCodret = '01601';
				RETURN cCodret;
		END IF;
		SELECT nombre_arch, fecha_presentacion, Num_secuencia INTO cNombre_Arch30, cFecha_presentacion30, cNum_secuencia30
		FROM Dom_cce_detalle WHERE Cod_operacion = '30' AND Importe = cImporte AND Tipo_operacion = cTipo_operacion
		AND Fecha_aplica = cFecha_aplica AND Tipo_cta_ord = cTipo_cta_ord AND Num_cta_ord = cNum_cta_ord AND Rfc_ord = cRfc_ord
		AND Tipo_cta_rec = cTipo_cta_rec AND Num_cta_rec = cNum_cta_rec AND Rfc_rec = cRfc_rec AND Ref_servicio = cRef_servicio
		AND tipo_registro = '02'
		AND clave_rastreo = c_cve_ras;
		----En este update se acTualiza el estatus y el motivo_dev
		UPDATE Dom_cce_detalle SET Cve_estatus = '02', Motivo_dev = cMotivo_dev  WHERE Cod_operacion = '30' AND Importe = cImporte
		AND Tipo_operacion = cTipo_operacion AND Fecha_aplica = cFecha_aplica AND Tipo_cta_ord = cTipo_cta_ord AND Num_cta_ord = cNum_cta_ord
		AND Rfc_ord = cRfc_ord AND Tipo_cta_rec = cTipo_cta_rec AND Num_cta_rec = cNum_cta_rec AND Rfc_rec = cRfc_rec
		AND Ref_servicio = cRef_servicio AND tipo_registro = '02'AND nombre_arch = cNombre_Arch30
		AND clave_rastreo = c_cve_ras;

		-- En caso  de que la causa de devoluciÃÂ³n sea distinta de '04'  actualizar el motivo de la tabla
		IF cMotivo_dev  <> '04' THEN--- Por Insuficiencia de Fondos
			-- Actualizar el campo motivo_dev de la tablas dom_ctas_verificadas
			UPDATE dom_ctas_verificadas SET motivo_dev = cMotivo_dev, cve_estatus = '02' WHERE cuenta = cNum_cta_rec AND Cve_banco = cBanco_presentador;
			
			--Consulta totales de iva mas comision en los movimientos para la cuenta del rfc
			SELECT comision, LPAD(cuenta_cargo_comision,20,'0') INTO mComision, cCuentaCargo FROM dom_cat_servicios WHERE rfc = TRIM(cRfc_ord);
			
			IF cRfc_ord = cRfcCopp THEN --SI ES CLIENTE COPPEL
				--SELECT motivo_dev INTO cMotivodev FROM dom_cat_devoluciones WHERE motivo_dev = cMotivo_dev;
				--Se actualiza dom_cte_detalle con la clave del motivo de rechazo
				UPDATE dom_cte_detalle SET estatus = '02', causa_rechazo = cMotivo_dev,
				comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
				WHERE nombre_arch_cce = cNombre_Arch30
				AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30;
				
				LET nrows = DBINFO('sqlca.sqlerrd2');
				
				/*SELECT nombre_arch, secuencia, reintentar_cuenta
				INTO cNom_Arch_Aux, iSecuencia, cReintentarCuenta
				FROM dom_cte_detalle
				WHERE nombre_arch_cce = cNombre_Arch30
				AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30;*/
				
				SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
				INTO cSecuencia FROM bdidomi:dom_cte_detalle_paso
				WHERE nombre_arch = cNom_Arch_Salida;
				
				INSERT INTO dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
				cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
				estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				SELECT 	cNom_Arch_Salida, CURRENT::DATE, tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,  
				cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
				estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, CURRENT::DATE, tipo_cta_abono, folio_suc
				FROM dom_cte_detalle
				WHERE nombre_arch_cce = cNombre_Arch30
				AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30 AND estatus = '02';		
				
				LET nrows = DBINFO('sqlca.sqlerrd2');
				
			ELSE
				-- Se obtiene la descripciÃÂ³n del cMotivo_dev de la tablas dom_cat_devoluciones
				SELECT Descripcion INTO cDescripcionMotivo FROM dom_cat_devoluciones WHERE motivo_dev = cMotivo_dev;
				
				UPDATE dom_cte_detalle SET estatus = '02', causa_rechazo = cDescripcionMotivo,
				comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
				WHERE nombre_arch_cce = cNombre_Arch30
				AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30;
				
				LET nrows = DBINFO('sqlca.sqlerrd2');
			END IF;
		ELSE ---- En caso de que la causa de devoluciÃÂ³n sea igual a 04
			---seleccionar el numero de reintentos para un cliente en especifico
			SELECT num_reintentos INTO iNum_Reintentos FROM dom_cat_servicios WHERE RFC  = cRfc_ord; --- La cuenta del ordenante
			IF iNum_Reintentos >= 0 THEN--- si  1
				--- Obtener los datos de la tabla Cte para almacenar en la de reintentos ya que se requieren conservar esos datos en este insert
				SELECT nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, nombre_arch_cce, fecha_presentacion_cce,
						   tipo_registro_cce, numero_secuencia_cce
				INTO   cNombre_arch_cteD, dFecha_envio_cteD, cTipo_registro_cteD, cConsecutivo_cteD, cFecha_cargo_cteD, cFecha_abono_cteD,
						   cNombre_arch_cce_cteD, cFecha_presentacion_cce_cteD, cTipo_registro_cce_cteD, cNumero_secuencia_cce_cteD
				FROM dom_cte_detalle
				WHERE nombre_arch_cce = cNombre_Arch30 AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro
				AND numeRO_secuencia_cce = cNum_secuencia30;
				--AND clave_rastreo = c_cve_ras;
				--- Para obtener el numero de intentos que lleva la cuenta para hacer la comparaciÃÂ³n con e el numero total de reintentos
				SELECT COUNT(num_intento) INTO iNum_Intentos
				FROM bdiDOMI:dom_cte_reintentos_cce
				WHERE nombre_arch = cNombre_arch_cteD AND fecha_envio = dFecha_envio_cteD
				AND tipo_registro = cTipo_registro_cteD and consecutivo = cConsecutivo_cteD;
				--AND clave_rastreo = c_cve_ras;
				-- Hacer la comparaciÃÂ³n entro la suma de intentos y los intentos permitidos
				IF (iNum_Intentos + 1) <= iNum_Reintentos THEN -- En caso de que el numero de reintentos + 1 sea menor a # de reintentos solicitados por el proveedor
							--- insertar en dom_cte_reintentod_cce
							INSERT INTO dom_cte_reintentos_cce(nombre_arch, fecha_envio, tipo_registro, consecutivo, num_intento, fecha_cargo, fecha_abono,
										nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, estatus, user_insert, fecha_insert)
							VALUES(cNombre_arch_cteD,dFecha_envio_cteD,cTipo_registro_cteD,cConsecutivo_cteD,iNum_Intentos + 1 ,cFecha_cargo_cteD,cFecha_abono_cteD,
							cNombre_arch_cce_cteD,cFecha_presentacion_cce_cteD,cTipo_registro_cce_cteD,cNumero_secuencia_cce_cteD,'02',pUser_insert,CURRENT);
							-- Actualizar  dom_cte_detalle los campos fecha cargo, fecha abono y estatus
                                        -- Obtener la fecha  T + 1
					LET cFecha_cargo_cteDAux = cFecha_cargo_cteD;
					LET cFecha_abono_cteDAux = cFecha_abono_cteD;
					LET cFechaFormateada = SUBSTR(cFecha_cargo_cteD,5,2) ||'/'|| SUBSTR(cFecha_cargo_cteD,7,2) ||'/'|| SUBSTR(cFecha_cargo_cteD,1,4);
					EXECUTE FUNCTION bdinteg:sp_valfecha_banca('001',(cFechaFormateada) + 1 , 0 )INTO cCodSpFecha,dFechaHabil; --a qui ya tengo el dia siguiente habil
					LET cFecha_cargo_cteD = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
					LET cFecha_abono_cteD = cFecha_cargo_cteD ;
					-- Consulta totales de iva mas comisiÃÂ³n en los movimientos para la cuenta del rfc
					SELECT comision, LPAD(cuenta_cargo_comision,20,'0') INTO mComision, cCuentaCargo FROM dom_cat_servicios WHERE rfc = TRIM(cRfc_ord);
					---Hacer el update para la tablas dom_cte_detalle los campos fecha cargo, fecha abono y estatus
					UPDATE dom_cte_detalle SET estatus = 'EP', fecha_cargo = cFecha_cargo_cteD, fecha_abono = cFecha_abono_cteD,
					comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
					WHERE nombre_arch_cce = cNombre_Arch30 AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro
					AND numero_secuencia_cce = cNum_secuencia30;
					
					LET nrows = DBINFO('sqlca.sqlerrd2');
					
					IF cRfc_ord = cRfcCopp THEN --SI ES CLIENTE COPPEL
						SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
						INTO cSecuencia FROM bdidomi:dom_cte_detalle_paso
						WHERE nombre_arch = cNom_Arch_Salida;
						
						INSERT INTO dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
						SELECT 	cNom_Arch_Salida, CURRENT::DATE, tipo_registro, cSecuencia, cFecha_cargo_cteDAux, cFecha_abono_cteDAux, tipo_cta_cargo, cve_banco_cargo,  
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						'02', 'PR', nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, CURRENT::DATE, tipo_cta_abono, folio_suc
						FROM dom_cte_detalle
						WHERE nombre_arch_cce = cNombre_Arch30
						AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30 AND estatus = 'EP';		
					
						LET nrows = DBINFO('sqlca.sqlerrd2');
					END IF;
					
				ELSE -- En caso de que el proveedor no haya solicitado reintentos o el # de reintentos ya se cumpliÃÂ³
					
					-- Consulta totales de iva mas comisiÃÂ³n en los movimientos para la cuenta del rfc
					SELECT comision, LPAD(cuenta_cargo_comision,20,'0') INTO mComision, cCuentaCargo FROM dom_cat_servicios WHERE rfc = TRIM(cRfc_ord);
					
					IF cRfc_ord = cRfcCopp THEN --SI ES CLIENTE COPPEL
						--SELECT motivo_dev INTO cMotivodev FROM dom_cat_devoluciones WHERE motivo_dev = cMotivo_dev;
						--Se actualiza dom_cte_detalle con la clave del motivo de rechazo
						UPDATE dom_cte_detalle SET estatus = '02', causa_rechazo = cMotivo_dev,
						comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
						WHERE nombre_arch_cce = cNombre_Arch30
						AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30;
						
						LET nrows = DBINFO('sqlca.sqlerrd2');
						
						SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
						INTO cSecuencia FROM bdidomi:dom_cte_detalle_paso
						WHERE nombre_arch = cNom_Arch_Salida;
												
						INSERT INTO dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
						SELECT 	cNom_Arch_Salida, CURRENT::DATE, tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,  
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, CURRENT::DATE, tipo_cta_abono, folio_suc
						FROM dom_cte_detalle
						WHERE nombre_arch_cce = cNombre_Arch30
						AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30 AND estatus = '02';		
						
					ELSE
						--Se obtiene la descripciÃÂ³n del cMotivo_dev de la tablas dom_cat_devoluciones
						SELECT Descripcion INTO cDescripcionMotivo FROM dom_cat_devoluciones WHERE motivo_dev = cMotivo_dev;
						
						--- Se actualiza  el estatus y  la causa rechazo de la dom_cte_detalle
						UPDATE dom_cte_detalle SET estatus = '02', causa_rechazo = cDescripcionMotivo,
						comision_cobrada = LPAD((mComision * 100):: INTEGER,16,'0') , iva_cobrado = LPAD(((mComision * mIva) * 100):: INTEGER,16,'0')
						WHERE nombre_arch_cce = cNombre_Arch30
						AND fecha_presentacion_cce = cFecha_presentacion30 AND tipo_registro_cce = cTipo_registro AND numero_secuencia_cce = cNum_secuencia30;
					END IF;
						
				END IF;
			END IF;
		END IF;
	END FOREACH;
	-------------El cobro de la comisiÃÂ³n -------------
	-- Se obtienen los valores de las transacciones que estÃÂ¡n en la parÃÂ¡metros
	--SELECT VALOR, DESCRIPCION INTO cCargoComision, cDescripcionCargoComision FROM bdiDOMI:dom_parametros where cod_param = '14';
	SELECT VALOR, DESCRIPCION INTO cCargoComision, cDescripcionCargoComision FROM bdiDOMI:dom_parametros where cod_param = '50';
	SELECT VALOR, DESCRIPCION INTO cCargoIva, cDescripcionCargoIva FROM bdiDOMI:dom_parametros where cod_param = '15';
	SELECT VALOR INTO cSucursalCargo FROM bdidomi:dom_parametros WHERE cod_param = '07';
	SELECT VALOR INTO mIva FROM bdinteg:si_param  WHERE cod_param = '47';
	-- Validar que los valores obtenidos no estÃÂ©n nullos
	IF cCargoComision IS NULL OR cCargoComision = '' THEN
		LET cCodret = '01602';
		LET cMensaje = 'Faltan parametros';
		Return cCodret;
	END IF
	IF cCargoIva = "" OR cCargoIva IS NULL THEN
		LET cCodret = '01602';
		LET cMensaje = 'Faltan parametros';
		RETURN cCodret;
	END IF
	SELECT 1 INTO iExiste FROM bdinteg:si_sucursales WHERE sucursal = cSucursalContable;
	--      Se valida si existe la sucursal contable.
	IF iExiste = 0 Then
		LET cCodret = '01602';
		LET cMensaje = 'Faltan parametros';
		RETURN cCodRet;
	ELSE
		LET iExiste = 0;
	END IF;
	
	SELECT MAX(fecha_insert) 
	INTO dFecha_Comision
	FROM dom_cce_detalle WHERE cod_operacion = '30' AND banco_presentador = cNumBancoPropio;
	
	-- Ciclo para barrer los distintos proveedores que hay en el archivo y poder sacar cuentas para los datos
	FOREACH WITH HOLD
		SELECT DISTINCT(rfc_ord),nombre_arch,fecha_presentacion,tipo_registro INTO cRfc,cNombre_archD,cFecha_presentacionD,cTipo_registro
		FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '31'
		-- Consulta totales de iva mas comisiÃÂ³n en los movimientos para la cuenta del rfc
		SELECT comision, LPAD(cuenta_cargo_comision,20,'0') INTO mComision, cCuentaCargo FROM dom_cat_servicios WHERE rfc = TRIM(cRfc);
		-- Contar cuantos movimiento tiene en la de detalle paso el rfc anterior para calcular el iva y la comisiÃÂ³n cobrados
		SELECT count(rfc_ord) INTO iTotalRegistros FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo
		AND Cod_operacion = '31' AND rfc_ord = cRfc;
		--- Calculamos el total de comisiÃÂ³n
		LET mComisionTotal = iTotalRegistros * mComision;
		--- Calculamos el total de iva
		LET mIvaTotal = mComisionTotal * mIva;
		
		--- Calculamos el total a pagar
		LET mTotalCargosaEfectuar = mComisionTotal + mIvaTotal;
		-- Verifica el saldo por pagar
		IF mTotalCargosaEfectuar <=  0 THEN
			CONTINUE FOREACH;
		ELSE
			SELECT num_cte 
			INTO cNumCte_Proveedor 
			FROM dom_cat_servicios 
			WHERE rfc = TRIM(cRfc);
			
			--Se agregan estas lines y se comenta bloque siguiente con el proposito de manejar un cobro mensual de comisiones en un procedimiento independiente (sp_domi_cargo_comisiones)
			INSERT INTO dom_cargo_comision_prov(fecha_comision, num_cte, rfc, transaccion, estatus, comision, iva, fecha_cargo, fecha_insert, fecha_movto) 
			VALUES(dFecha_Comision, cNumCte_Proveedor, cRfc, cCargoComision, 'P', mComisionTotal, mIvaTotal, '', CURRENT::DATE, (SELECT DBINFO('utc_to_datetime', sh_curtime)FROM sysmaster:"informix".sysshmvals));		
		END IF;
		
		
		--Consulta el saldo de la cuenta cargo
		--SELECT (sdo_actual -(sdo_cong + sdo_retenido))
		--INTO mSaldoCtaCargo
		--FROM bdicheq:sc_maechq
		--WHERE empresa = '001' AND cuenta = SUBSTR(cCuentaCargo,9,11); --- CHEKAR SI BIENE LA CUENTA O LA CUENTA CLABE
		-- Valida si el saldo por pagar es mayor a la cuenta cargo
		--IF mTotalCargosaEfectuar <= mSaldoCtaCargo THEN--- Si es menor pues lo paga todo bien
		--	---Cobro de Comision
		--	--Genera el folio para el cargo a la cuenta cargo DOMI para la comisiÃÂ³n.
		--	CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--	--Realiza a la cuenta cargo completo el cargo por el total de comisiÃÂ³n.
		--	CALL bdicheq:cargo_ref ("001", cSucursalCargo, pUser_insert, cCargoComision, "0000", cNumeroFolioCargo, SUBSTR(cCuentaCargo,9,11), 0,
		--	mComisionTotal,"01", cDescripcionCargoComision, '', pUser_insert) Returning cCodRet2,cTranret,vfechoy,mSaldoCtaCargo,vmontoret;
		--	--- Validar si se ejecuto bien el cargo
		--	IF cCodRet2 <> "000" THEN
		--		--- Si pasa algo en la funciÃÂ³n anterior todo se va a comisiÃÂ³n pendiente
		--		IF cCodRet2 = "549" OR cCodRet2 = "550" OR cCodRet2 = "777"  THEN
		--			 COMMIT WORK;
		--		END IF;
		--		
		--		CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--		INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--		VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoComision,mComisionTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);
		--		
		--		CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--		INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--		VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoIva,mIvaTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);
		--		-- Validar el cÃÂ³digo de retorno del cargo_ref para cerrar el begin work
		--
		--	ELSE-- si se ejecuto bien entonces si cobra el iva
		--		--- Cobro de Iva
		--		-- Genera el folio para el cargo a la cuenta cargo DOMI para el Iva.
		--		CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--		--Realiza a la cuenta cargo completo el cargo por el total de iva.
		--		CALL bdicheq:cargo_ref ("001", cSucursalCargo, pUser_insert, cCargoIva, "0000", cNumeroFolioCargo, SUBSTR(cCuentaCargo,9,11), 0,
		--		mIvaTotal,"01", cDescripcionCargoIva, '', pUser_insert) Returning cCodRet2,cTranret,vfechoy,mSaldoCtaCargo,vmontoret;
		--		
		--		IF cCodRet2 <> '000' THEN
		--			IF cCodRet2 = "549" OR cCodRet2 = "550" OR cCodRet2 = "777"  THEN
		--				 COMMIT WORK;
		--			END IF;				
		--			CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--			VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoIva,mIvaTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);				
		--		END IF;
		--	END IF;
		--	CONTINUE FOREACH;
		--ELSE --Si no alcanza el saldo de la cuenta cobra una parte
		--	LET mTotalCargos = mTotalCargosaEfectuar;
		--	LET mTotalCargosaEfectuar = 0.00;
		--	LET mComisionPendiente = 0.00;
		--	LET mComisionTotal = 0.00;
		--	LET mIvaTotal = 0.00;
		--	LET mTotalCargosaEfectuar = 0.00;
		--	-- Consulta las comisiones de manera independiente para checar cuanto dinero dispone para utilizar
		--	FOREACH
		--		SELECT nombre_arch INTO cNombre_archD FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '31'
		--		--- calculamos el total de comision
		--		LET mComisionTotal = mComisionTotal + mComision;
		--		--- calculamos el total de iva
		--		LET mIvaTotal = mIvaTotal + (mComision * mIva);
		--		--Verifica el saldo por pagar
		--		IF (mComisionTotal + mIvaTotal) <= mSaldoCtaCargo THEN--- Si alcanza para pagarlo pues se suman sino pues se pasa a comisiÃÂ³n pendiente
		--			---calculamos el total a pagar
		--			LET mTotalCargosaEfectuar = mComisionTotal + mIvaTotal;
		--			CONTINUE FOREACH;
		--		ELSE    -- sino se almacena en comisiÃÂ³n pendiente
		--			IF mTotalCargosaEfectuar > 0.00 THEN--- si se acumulo algo pues se paga
		--				-- Calculo de la comisiÃÂ³n sin iva sacado de la comisiÃÂ³n pendiente
		--				LET mComisionTotal = mTotalCargosaEfectuar / (1 + mIva);
		--				-- calculo del iva
		--				LET mIvaTotal = mTotalCargosaEfectuar - mComisionTotal;
		--				---Cobro de comisiÃÂ³n
		--				--Genera el folio para el cargo a la cuenta cargo DOMI para la comisiÃÂ³n.
		--				CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--				--Realiza a la cuenta cargo completo el cargo por el total de comisiÃÂ³n.
		--				CALL bdicheq:cargo_ref ("001", cSucursalCargo, pUser_insert, cCargoComision, "0000", cNumeroFolioCargo, SUBSTR(cCuentaCargo,
		--					9,11), 0, mComisionTotal, "01", cDescripcionCargoComision, '', pUser_insert) Returning cCodRet2,cTranret,vfechoy,
		--					mSaldoCtaCargo,vmontoret;
		--				--- validar si se ejecuto bien el cargo
		--				IF cCodRet2 <> "000" THEN
		--					---si pasa algo en la funcion anterior todo se va a comisiÃÂ³n pendiente
		--					CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioAbono;
		--					INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--					VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoComision,mComisionTotal,0.00,dFechaActual,'','P',cNumeroFolioAbono);
		--												
		--					/*CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--					INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--					VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoIva,mIvaTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);	*/						
		--					--validar el codigo de retorno del cargo_ref para cerrar el begin work
		--					IF cCodRet2 = "549" OR cCodRet2 = "550" OR cCodRet2 = "777"  THEN
		--						 COMMIT WORK;
		--					END IF;
		--				ELSE
		--					---Cobro de Iva
		--					--Genera el folio para el cargo a la cuenta cargo DOMI para el Iva.
		--					CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--					--Realiza a la cuenta cargo completo el cargo por el total de iva.
		--					CALL bdicheq:cargo_ref ("001", cSucursalCargo, pUser_insert, cCargoIva, "0000", cNumeroFolioCargo, SUBSTR(cCuentaCargo,
		--						9,11), 0, mIvaTotal, "01", cDescripcionCargoIva, '', pUser_insert) Returning cCodRet2,cTranret,vfechoy,
		--						mSaldoCtaCargo,vmontoret;
		--					/*IF  cCodRet2 <> '000' THEN
		--						CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioCargo;
		--						INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--						VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoIva,mIvaTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);							
		--						--validar el codigo de retorno del cargo_ref para cerrar el begin work
		--						IF cCodRet2 = "549" OR cCodRet2 = "550" OR cCodRet2 = "777"  THEN
		--							 COMMIT WORK;
		--						END IF;							
		--					END IF;*/
		--						
		--				END IF;
		--			END IF;
		--			--- calculo del  la comisiÃÂ³n pendiente pero esto es mas iva
		--			LET mComisionPendiente = mTotalCargos - mTotalCargosaEfectuar;
		--			 -- calculo de la comisiÃÂ³n sin iva sacado de la comisiÃÂ³n pendiente
		--			LET mComisionTotal = mComisionPendiente / (1 + mIva);
		--			---Cobro de comisiÃÂ³n Pendiente
		--			CALL bdicheq:sp_generafolionomina(pUser_insert)Returning cCodRet1,cNumeroFolioAbono;
		--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
		--			VALUES ('001',SUBSTR(cCuentaCargo,9,11),cCargoComision,mComisionTotal,0.00,dFechaActual,'','P',cNumeroFolioAbono);
		--			EXIT FOREACH;
		--		END IF;
		--	END FOREACH;
		--END IF;
		---inicializar variables
		LET mTotalCargos = 0.00;
		LET mTotalCargosaEfectuar = 0.00;
		LET mComisionPendiente = 0.00;
		LET mComisionTotal = 0.00;
		LET mIvaTotal = 0.00;
		LET mTotalCargosaEfectuar = 0.00;
		LET iTotalRegistros = 0;
		LET mComision = 0.00;
		LET cCuentaCargo  = ' ';
	END FOREACH;
	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
'AUTOR :CÃÂ©sar ValdÃÂ©z Figueroa',
'DESCRIPCION: Este Procediemiento Recibe el archivo 31 y lo procesa actualizando campos de algunas tablas y cobrando comision',
'             e Iva  por cada registro que incluya el archivo 31',
'FECHA : Agosto de 2009',
'Modificacion: CÃÂ©sar ValdÃÂ©z Figueroa',
'Descripcion: Adaptar el proceso para procesar archivos codigo 31 con tarjetas de crÃÂ©dito',
'Fecha: 15 de febrero de 2010',
'Version: 20100220.2300',
'BD: BDIDOMI',
'Descripcion: Adaptar proceso para que inserte de la tabla dom_cte_detalle_paso a la tabla dom_cte_detalle',
'Fecha: 03 de Oct de 2017',
'Autor: Ingrid Pamela Cazarez Villegas';

CREATE PROCEDURE "informix".sp_domi_guardararchivo_manual_ob(
	p_sNombreCargo	 			CHAR(40),
	p_sCuentaAbono  			CHAR(20),
	p_sTipoCtaAbono 			CHAR(2),
	p_sImpOperacion 			CHAR(15),
	p_sCuentaCargo 			 	CHAR(20),
	p_sTipoCtaCargo 			CHAR(2),
	p_sCveBancoCargo 			CHAR(3),
	p_sUserInsert 				CHAR(8),
	p_sFechaPago 				CHAR(8),
	p_sRfcCargo				 	CHAR(13),
	p_sFolioActivacion 			CHAR(20),
	p_sReferenciaNumerica 	 	CHAR(7),
	p_sAccion 					CHAR(1),
	p_sPeriodo					CHAR(2),
	p_sEstatus					CHAR(2),
	p_sNumCliente				CHAR(9),
	p_generico1					NVARCHAR(254), -- Tarjeta de credito.
	p_generico2					NVARCHAR(254), -- Bandera que indica si es un reintento.
	p_generico3					NVARCHAR(254),
	p_generico4					NVARCHAR(254),
	p_generico5					NVARCHAR(254)
)
	RETURNING 	CHAR(5) 		AS CodigoRetorno,
				CHAR(100)		AS v_generico1,
				CHAR(100)		AS v_generico2,
				CHAR(100)		AS v_generico3,
				CHAR(100)		AS v_generico4,
				NVARCHAR(254)	AS v_generico5,
				NVARCHAR(254)	AS v_generico6,
				NVARCHAR(254)	AS v_generico7,
				NVARCHAR(254)	AS v_generico8,
				NVARCHAR(254)	AS v_generico9;

	--Declaracion de  Variables
	DEFINE sql_err 						INTEGER;
	DEFINE cInTransaction	 			CHAR(1);
	DEFINE sCodret 						CHAR(5);
	DEFINE sNombreArchivo				CHAR(20);
	DEFINE dFechaInsert             	DATE;
	DEFINE dFechaPago               	DATE;
	DEFINE dFechaNotificacion   		DATE;
	DEFINE dFechaProximoPago        	DATE;
	DEFINE dValidarFechaProximoPago		DATE;
	DEFINE sFormarYear              	CHAR(10);
	DEFINE sFormarMes               	CHAR(10);
	DEFINE sFormarFecha             	CHAR(10);
	DEFINE sFormarDia               	CHAR(10);
	DEFINE sUnirMesDia              	CHAR(10);
	DEFINE sTipoRegistro            	CHAR(1);
	DEFINE sReintentarCuenta  			CHAR(1);
	DEFINE sReferenciaLeyenda  			CHAR(50);
	DEFINE sReferenciaServicio  		CHAR(50);
	DEFINE sTipo 						CHAR(1);
	DEFINE sIva							CHAR(15);
	DEFINE sConsecutivoArchivo			CHAR(3);
	
	--Consecutivo Otros Bancos
    DEFINE cConsecutivo_nombre 			CHAR(2);
	DEFINE dFechaHabil 					DATE;
	DEFINE dFechaAux   					DATE;
	DEFINE dFechaAux2                   DATE;
	DEFINE dFecha 						DATE;
	DEFINE dFechaHabilSiguiente 		DATE;
	DEFINE sTipoRegistroOB 				CHAR(1);
	DEFINE cNumCte_proveedor			CHAR(9);
	DEFINE cTarjetaAbono				CHAR(20);
	DEFINE sImpOperacion				CHAR(15);
	DEFINE cCodret2						CHAR(5);
	DEFINE cCodret3						CHAR(5);
	DEFINE cMensajeRespuesta 			CHAR (110);
	DEFINE iNumIntentos					INTEGER;
	DEFINE iRegistros					INTEGER;
	DEFINE sFechaCargoAbono				CHAR(10);
	DEFINE cNombreBancoCargo			CHAR(50);
	DEFINE VHoraEjecion 				INTEGER;
	DEFINE v_generico1					CHAR (110);
	DEFINE v_generico2					CHAR (110);
	DEFINE v_generico3					CHAR (110);
	DEFINE v_generico4					CHAR (110);
	DEFINE v_generico5					NVARCHAR (254);
	DEFINE v_generico6					NVARCHAR (254);
	DEFINE v_generico7					NVARCHAR (254);
	DEFINE v_generico8					NVARCHAR (254);
	DEFINE v_generico9 					NVARCHAR (254);

	--Inicializar Variables
	LET sql_err 						= 0;
	LET sCodret 						= '00000';
	LET cInTransaction      			= 'N';
	LET sNombreArchivo 					= '';
	LET sTipoRegistro 	 				= 'B';
	LET sReintentarCuenta 				= 'S';
	LET	dFechaInsert 					= current::DATE;
	LET sIva							= '000000000000000';
	LET sTipo							= '';
	LET sConsecutivoArchivo 			= '01';

	--Consecutivo Otros Bancos
    LET cConsecutivo_nombre 			= 0;
	LET dFechaHabil 					= CURRENT;
	LET dFecha 							= CURRENT;
	LET dFechaHabilSiguiente 			= CURRENT;
	LET dFechaProximoPago 				= '';
	LET sTipoRegistroOB					= 'D';
	LET cNumCte_proveedor				= '';
	LET cTarjetaAbono					= '';
	LET cCodret2						= '';
	LET cMensajeRespuesta				= '';
	LET cNombreBancoCargo				= '';
	LET iNumIntentos					= 0;
	LET iRegistros						= 0;
	LET sFechaCargoAbono				= '';
	LET v_generico1						= '';
	LET v_generico2						= '';
	LET v_generico3						= '';
	LET v_generico4						= '';
	LET v_generico5						= '';
	LET v_generico6						= '';
	LET v_generico7						= '';
	LET v_generico8						= '';
	LET v_generico9 					= '';

	-- Formamos la fecha de pago.
	LET sFormarYear 					= CONCAT(SUBSTR(TRIM(p_sFechaPago), 1,4),'-');
	LET sFormarMes 						= CONCAT(SUBSTR(TRIM(p_sFechaPago), 5,2),'-');
	LET sFormarDia						= SUBSTR(TRIM(p_sFechaPago), 7,2);
	LET sUnirMesDia						= CONCAT(TRIM(sFormarMes), TRIM(sFormarDia));
	LET sFormarFecha 					= CONCAT( TRIM(sFormarYear),  TRIM(sUnirMesDia));
	LET	dFechaPago 						= to_date( TRIM(sFormarFecha), "%Y-%m-%d");
	LET sFechaCargoAbono				= TO_CHAR(dFechaPago, '%Y%m%d');

	--***************************************************************************************
	--SET DEBUG FILE TO '/home/sysdomi/sp_domi_bitacora.out';
    --TRACE ON;
	--***************************************************************************************

	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN

				IF cInTransaction = 'S' THEN
					ROLLBACK WORK;
				END IF;

				LET sCodret = sql_err;

				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sFolioActivacion), p_sUserInsert, CURRENT);

				RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5,v_generico6,v_generico7,v_generico8,v_generico9;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			--ROLLBACK WORK;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--Valida parametros de entrada
	 	IF
	 		NVL(p_sNombreCargo,'') = ''
			OR NVL(p_sCuentaAbono,'') = ''
			OR NVL(p_sTipoCtaAbono,'') = ''
			OR NVL(p_sCuentaCargo,'') = ''
			OR NVL(p_sTipoCtaCargo,'') = ''
			OR NVL(p_sCveBancoCargo,'') = ''
			OR NVL(p_sUserInsert,'') = ''
			OR NVL(p_sFechaPago,'') = ''
			OR NVL(p_sRfcCargo,'') = ''
			OR NVL(p_sFolioActivacion,'') = ''
		  	OR NVL(p_sReferenciaNumerica,'') = ''
		  	OR NVL(p_sAccion,'') = ''
			OR NVL(p_sPeriodo,'') = ''
			OR NVL(p_sImpOperacion, '') = ''
			OR NVL(p_sNumCliente, '') = ''
			OR NVL(p_sEstatus, '') = ''
			OR NVL(p_generico1,'') = ''
	 	THEN

			LET sCodret='88812'; --PARAMETROS DE ENTRADA ESTAN EN BLANCO.

			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);

			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5,v_generico6,v_generico7,v_generico8,v_generico9;

		END IF;

		--Verificar si el registro ya existe.
		IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sFolioActivacion AND accion = p_sAccion AND estatus = 'EP') THEN
			LET sCodret='88814'; --EL REGISTRO CON EL FOLIO INGRESADO YA EXISTE.

			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(sCodret) INTO cCodret2, cMensajeRespuesta;

			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, sCodret, '', 'sp_dom_guardararchivo_manual', TRIM(p_sfolioActivacion) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);

			RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5,v_generico6,v_generico7,v_generico8,v_generico9;
		END IF;

		--Generar nombre de archivo.
		SELECT TRIM(valor)
		INTO cNumCte_proveedor
		FROM  bdidomi:"informix".dom_parametros
		WHERE cod_param = '36';

		LET cNumCte_proveedor = TO_CHAR(TRIM(cNumCte_proveedor), "&&&&&&&&&");

		SELECT TRIM(valor)
		INTO sReferenciaLeyenda
		FROM  bdidomi:"informix".dom_parametros
		WHERE cod_param = '58';

		SELECT TRIM(valor)
		INTO sReferenciaServicio
		FROM  bdidomi:"informix".dom_parametros
		WHERE cod_param = '59';

		--referencias al tipo de domiciliacion que se esta realizando
        LET sTipo = 'D';

        SELECT NVL(MAX( SUBSTR(nombre_arch,19,2)),'00') + 1 INTO cConsecutivo_nombre FROM bdidomi:dom_cte_archivos WHERE fecha_insert = dFecha AND num_cte = LPAD(cNumCte_proveedor,20,'0') ;

		--Formatear campos que llevan leading zeros
		LET p_sCuentaCargo = TO_CHAR(p_sCuentaCargo, "&&&&&&&&&&&&&&&&&&&&");
		LET p_sCuentaAbono = TO_CHAR(p_sCuentaAbono, "&&&&&&&&&&&&&&&&&&&&");
		LET cTarjetaAbono = TO_CHAR(p_generico1, "&&&&&&&&&&&&&&&&&&&&");
		LET sImpOperacion = REPLACE(p_sImpOperacion,".", "");
		LET sImpOperacion = TO_CHAR(sImpOperacion,"&&&&&&&&&&&&&&&");
		LET p_sReferenciaNumerica = TO_CHAR(p_sReferenciaNumerica,"&&&&&&&");

		SELECT COUNT(*) INTO iRegistros FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = p_sFolioActivacion;

		IF (iRegistros > 0) THEN
			FOREACH
				SELECT FIRST 1 num_intento
				INTO iNumIntentos
				FROM bdidomi:"informix".dom_archivomanual
				WHERE folio_activacion = p_sFolioActivacion
				ORDER BY fecha_insert DESC
			END FOREACH;
		END IF;

		BEGIN WORK;

			LET cInTransaction = 'S';
            LET dValidarFechaProximoPago = dFechaPago;
            
            -- Si hay mas de un registro significa que estamos programando un nuevo cobro, caso contrario es un alta de domiciliacion nueva.
            IF iRegistros = 0 THEN

                -- En caso de que la hora del diahabil sea mayor a las 6 pm se pasa al dia siguiente.
                SELECT TO_NUMBER(COALESCE(valor, '0'))
                INTO VHoraEjecion
                FROM bdidomi:"informix".dom_parametros
                WHERE cod_param = '71';

                IF TO_NUMBER(TO_CHAR(CURRENT, '%H%M')) > VHoraEjecion THEN
                    LET dFechaHabilSiguiente = dFechaHabilSiguiente + 1 UNITS DAY;
                END IF;

                EXECUTE PROCEDURE bdidomi:"informix".sp_ValFeriadoBanca('001',dFechaHabilSiguiente,0,'V') INTO sCodret, dFechaHabil;

                IF sCodret <> '00000' THEN

                    LET dFechaHabilSiguiente = dFechaHabilSiguiente + 1 UNITS DAY;

                    WHILE sCodret <> '00000'

                        EXECUTE PROCEDURE bdidomi:"informix".sp_ValFeriadoBanca('001',dFechaHabilSiguiente, 0,'V') INTO sCodret, dFechaHabil;

                        IF sCodret = '00000' THEN
                           EXIT WHILE;
                        ELSE
                            LET dFechaHabilSiguiente = dFechaHabilSiguiente + 1 UNITS DAY;
                        END IF;

                    END WHILE;
                END IF;

                -- Validamos la fecha de proximo pago.
                EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtener_fecha_valida_ob(dValidarFechaProximoPago) INTO dFechaAux, dFechaProximoPago, dFechaAux2;

                -- Verificamos si la fecha de proximo pago es mayor a la fecha de envio.
                IF dFechaProximoPago < dFechaHabil + 3 UNITS DAY THEN
                    LET dValidarFechaProximoPago = dValidarFechaProximoPago + 1 UNITS MONTH;

                    -- Validamos la nueva fecha de proximo pago.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtener_fecha_valida_ob(dValidarFechaProximoPago) INTO dFechaAux, dFechaProximoPago, dFechaAux2;
                END IF;
																
			ELIF p_generico2 = 'S' THEN -- Es un reintento al dia siguiente.
                
                -- No requerimos validacion de fechas.
                LET dFechaProximoPago = dFechaPago;
                LET dFechaHabil = dFechaPago;				
													  
            ELIF p_sAccion = 'A' AND iRegistros > 0 AND p_generico2 != 'S' THEN -- Es una programacion de proximo pago para el siguiente periodo.
                -- Validamos la fecha de proximo pago.
                EXECUTE PROCEDURE bdidomi:"informix".sp_domi_obtener_fecha_valida_ob(dValidarFechaProximoPago) INTO dFechaHabil, dFechaProximoPago, dFechaAux2;
            END IF;

			LET sNombreArchivo = 'E' || SUBSTR(LPAD(TRIM(cNumCte_proveedor),20,'0'),12,9) || 'D' || LPAD(DAY(dFechaHabil),2,'0') || LPAD(MONTH(dFechaHabil),2,'0')
									 || SUBSTR(YEAR(dFechaHabil),3,2) || '.' || LPAD(TRIM(cConsecutivo_nombre),2,'0');

			--Inserta en la tabla dom_archivomanual.
			INSERT INTO bdidomi:"informix".dom_archivomanual(
				folio_activacion, tipo_domi, nombre_arch, fecha_envio, tipo_registro, consecutivo,
				fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv,
				accion, reintentar_cuenta, estatus, user_insert, fecha_insert, tipo_cta_abono,
				num_periodo, num_intento
			)
			VALUES(
				p_sFolioActivacion, '02', sNombreArchivo, dFechaHabil, sTipoRegistroOB , '000001',
				 YEAR(dFechaProximoPago) || LPAD(MONTH(dFechaProximoPago),2,'0') || LPAD(DAY(dFechaProximoPago),2,'0'), YEAR(dFechaProximoPago) || LPAD(MONTH(dFechaProximoPago),2,'0') || LPAD(DAY(dFechaProximoPago),2,'0'), p_sTipoCtaCargo, p_sCveBancoCargo, p_sCuentaCargo, p_sRfcCargo, p_sNombreCargo, cTarjetaAbono, sImpOperacion, sIva, p_sReferenciaNumerica, sReferenciaLeyenda, sReferenciaServicio, p_sNombreCargo, p_sAccion, sReintentarCuenta, p_sEstatus, p_sUserInsert, dFechaInsert, p_sTipoCtaAbono,
				p_sPeriodo, iNumIntentos
			);

			IF (p_sAccion = 'A') THEN

				-- Se extrae el nombre del banco de cargo.
				SELECT descripcion INTO cNombreBancoCargo FROM bdinteg:"informix".si_bancos WHERE banco = p_sCveBancoCargo;

                IF iRegistros = 0 THEN
                    -- Proceso de activacion de la domiciliacion
                    INSERT INTO bdidomi:"informix".dom_activacion_domiciliacion_ob
                    (folio_activacion,num_cte,estatus,fecha_insert,user_insert, procesado, contrato)
                    VALUES(p_sFolioActivacion, p_sNumCliente,'03', dFechaInsert, p_sUserInsert, '0', '0');

                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_alta_cuentas_registradas(p_sNumCliente, LTRIM(p_sCuentaCargo, '0'), p_sCveBancoCargo, cNombreBancoCargo, '','','','','') INTO cCodret3;

                    IF cCodret3 <> '00000' AND cCodret3 <> '88832' THEN
                        LET sCodret = cCodret3;
                        ROLLBACK WORK;
                        RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5,v_generico6,v_generico7,v_generico8,v_generico9;
                    END IF;
                END IF;

				--Si el folio ya existe entonces hacer update fecha_prox_pago y fecha_notificacion
				IF EXISTS(SELECT 1 FROM bdidomi:"informix".dom_fecha_pago WHERE folio_activacion = p_sFolioActivacion) THEN
					UPDATE bdidomi:"informix".dom_fecha_pago
					SET fecha_prox_pago = dFechaProximoPago, fecha_notificacion = dFechaProximoPago - 1 units day, fecha_inicio = dFechaProximoPago, fecha_fin = dFechaProximoPago
					WHERE folio_activacion = p_sFolioActivacion;
				ELSE
					--Inserta en la tabla dom_fecha_pago
					INSERT INTO bdidomi:"informix".dom_fecha_pago(folio_activacion, periodo, fecha_pago, fecha_prox_pago, fecha_inicio, fecha_fin, fecha_insert, user_insert, fecha_notificacion)
					VALUES(p_sFolioActivacion, p_sPeriodo, dFechaPago, dFechaProximoPago, dFechaProximoPago, dFechaProximoPago, dFechaInsert, p_sUserInsert, dFechaProximoPago - 1 units day);
				END IF;

				--Si el folio ya existe entonces se omite insert
				IF NOT EXISTS(SELECT 1 FROM bdidomi:"informix".dom_pago WHERE folio_activacion = p_sFolioActivacion) THEN
					--Inserta en dom_pago
					INSERT INTO bdidomi:"informix".dom_pago (folio_activacion,num_cliente,monto_proximo_pago,tipo_domi,fecha_insert,user_insert)
					VALUES(p_sFolioActivacion, p_sNumCliente, p_sImpOperacion, '02', dFechaInsert, p_sUserInsert);
				END IF;

			END IF;

			IF p_sAccion = 'B' THEN
				-- Si existe una tarjeta en dom_cuentas_ob con estatus 01, no se actualiza la tabla.
				IF NOT EXISTS(
					SELECT 1 FROM bdidomi:"informix".dom_cuentas_ob
					WHERE num_cliente = p_sNumCliente
					AND num_tarjeta = LTRIM(p_sCuentaCargo,'0')
					AND estatus = '01'
				)
				THEN

					UPDATE bdidomi:"informix".dom_cuentas_ob SET estatus = '02' WHERE num_cliente = p_sNumCliente AND num_tarjeta = LTRIM(p_sCuentaCargo,'0');

				END IF;

				UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob SET estatus = '02' WHERE folio_activacion = p_sFolioActivacion;
				UPDATE bdidomi:"informix".dom_cte_detalle SET accion = 'B' WHERE cuenta_cargo = p_sCuentaCargo AND cuenta_abono = cTarjetaAbono; 

			END IF;

		COMMIT WORK;

		LET cInTransaction = 'N';

		RETURN sCodret, v_generico1, v_generico2, v_generico3, v_generico4, v_generico5,v_generico6,v_generico7,v_generico8,v_generico9;
    END;
END PROCEDURE
DOCUMENT
'AUTOR      	: Pedro enrique huicho yocupicio',
'DESCRIPCION	: Se encarga de guardar el archivo de forma manual Otros bancos',
'FECHA      	: 18/01/2024',
'BD         	: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_encabezado_sumario()
	RETURNING CHAR(5) AS Codigo_Respuesta,CHAR (100) AS Mensaje_Respuesta;  


	DEFINE pNom_Arch31 CHAR(20);
	DEFINE pNom_Arch32 CHAR(20);
	DEFINE sql_err      INTEGER;
	DEFINE v_cod_ret   CHAR(5);
	DEFINE vsFlagArch31 CHAR(1);
    DEFINE vsFlagArch32 CHAR(1);
	DEFINE vsFecha_Presentacion CHAR (8);
    DEFINE vsFecha_Presentacion1 CHAR (8);
    DEFINE vsFecha_Presentacion2 CHAR (8);
	DEFINE vsCodRetorno CHAR (5);
    DEFINE vsCodRetorno2 CHAR (5);
	DEFINE vsNomArchivo31 CHAR (20);
	DEFINE vsNomArchivo32 CHAR (20);
	DEFINE vsFlagTipoProceso CHAR (1);
	DEFINE vsNomProceso CHAR (20);
	DEFINE vsDescripcionProceso CHAR (60);
	DEFINE sERROR CHAR(1);
	DEFINE psNumEmpleado CHAR(8);
	DEFINE vsNomArchivo CHAR (20);
	DEFINE viTipoArchivo SMALLINT;
	DEFINE vsFlagArch11 CHAR(1);
	DEFINE vsNomArchivo11 CHAR (20);
	DEFINE sFINALIZADO CHAR(1);
	DEFINE pNom_Arch   CHAR(20);
	DEFINE cFechaFormat	CHAR(10);
	DEFINE dFecha_hoy DATE;
	DEFINE dFechaManana	DATE;
	DEFINE cFecha_trans	CHAR(8);
	DEFINE cCodRet CHAR(5);
	DEFINE d_Fech_prox DATE;
	DEFINE pUsuario CHAR(8);
	DEFINE vsMensaje_Respuesta CHAR (100);
	DEFINE vNumsecArch31 INTEGER;
	DEFINE vNumsecArch32 INTEGER;
	DEFINE cSecuencia CHAR(7);
	DEFINE vSecInvalida CHAR(7);
	DEFINE vParam1 INTEGER;
	DEFINE vParam2 INTEGER;
	DEFINE vParam3 INTEGER;
	DEFINE vParam4 INTEGER;
	DEFINE vParam5 INTEGER;
	DEFINE vParam6 INTEGER;
	DEFINE vParam7 INTEGER;
	DEFINE vParam8 INTEGER;
	DEFINE vtransaccion INTEGER;
	DEFINE iExisteProc	INTEGER;
	DEFINE vEstatus_cve	CHAR(2);
	DEFINE vCuenta	    INTEGER;
	DEFINE vNom_Archv   CHAR(20);
	DEFINE vTipo_reg    CHAR(2);
	DEFINE vCve_estatus CHAR(2);
	DEFINE cursor9      CHAR(50);
	DEFINE cursor10     CHAR(50);
	DEFINE vCod_oper    CHAR(2);
	DEFINE vImporte     CHAR(15);
	DEFINE vClave_rastreo CHAR(30);
	DEFINE vFolio_suc   CHAR(16);
	
	LET pNom_Arch31 = "";
	LET pNom_Arch32 = "";
	LET sql_err = 0;
	LET vsFlagArch31 = 'F';
	LET vsFlagArch32 = 'F';
	LET vsFecha_Presentacion = '';
    LET vsFecha_Presentacion1 = '';
	LET vsFecha_Presentacion2 = '';
	LET vsCodRetorno = '00000';
    LET vsCodRetorno2 = '';
	LET vsNomArchivo31 = '';
    LET vsNomArchivo32 = '';
	LET vsFlagTipoProceso = '';
	LET vsNomProceso = '';
	LET vsDescripcionProceso = '';
	LET sERROR = '3';
	LET psNumEmpleado = '92599192';
	LET vsNomArchivo = '';
	LET viTipoArchivo = 0;
	LET vsFlagArch11 = 'F';
	LET vsNomArchivo11 = '';
	LET sFINALIZADO = '1';
	LET pNom_Arch   = "";
	LET dFecha_hoy  = "";
	LET cFecha_trans = "";
	LET cCodRet	= "00000";
	LET pUsuario = '';
	LET v_cod_ret = '';
	LET vsMensaje_Respuesta = '';
	LET vNumsecArch31 = 1;
	LET vNumsecArch32 = 1;
	LET cSecuencia    = '';
	LET vSecInvalida   = '';
	LET vParam1 = 0;
	LET vParam2 = 0;
	LET vParam3 = 0;
	LET vParam4 = 0;
	LET vParam5 = 0;
	LET vParam6 = 0;
	LET vParam7 = 0;
	LET vParam8 = 0;
	LET vtransaccion = 0;
	LET iExisteProc  = 0;
	LET vEstatus_cve = '';
	LET vNom_Archv = '';
	LET vTipo_reg = '';
	LET vCve_estatus = '';
	LET cursor9  = '';
	LET cursor10 = '';
	LET vCod_oper = '';
	LET vFolio_suc = '';
	
	BEGIN
		
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vsCodRetorno = sql_err;
				  EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', vsCodRetorno, pUsuario, vsDescripcionProceso, TRIM(pNom_Arch) , 
				  YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			 RETURN vsCodRetorno,vsDescripcionProceso;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535, -255,-243,-211, -242, -244, -311)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO wait 3;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_domi_encabezado_sumario.out";
        --TRACE ON;	
		
		SELECT FIRST 1 nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,user_insert INTO pNom_Arch,vsFecha_Presentacion,pNom_Arch31,pNom_Arch32,pUsuario FROM bdidomi:dom_cce_control_hilos 
		WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_1');
		
		--	Consulta  fecha de la tabla de control de hilos, esto por si se ejecuta en cualquier momento, tome la fecha en que se ejecuta el proceso y no cambie la fecha en el cierre de cheques.
		SELECT FIRST 1 fecha_insert INTO dFecha_hoy FROM bdidomi:dom_cce_control_hilos;
		--      Saca la fecha de presentacion

		LET dFechaManana = dFecha_hoy + 1;


		LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');

		CALL bdidomi: "informix".sp_valida_fecha(cFechaFormat) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			EXECUTE FUNCTION bdinteg: "informix".splvalfecha('001', dFechaManana, 0 ) INTO cCodRet,dFechaManana;

			SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
			IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
				LET dFechaManana = dFechaManana;
			ELSE
				LET dFechaManana = d_Fech_prox;
			END IF;
			LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
			IF cCodRet <>0 THEN
				LET vsMensaje_Respuesta = 'ERROR';
				RETURN cCodRet,vsMensaje_Respuesta;
			END IF;
			LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
			--LET cFecha_aplica = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		END IF;

		SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
		IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
			LET dFechaManana = dFechaManana;
		ELSE
			LET dFechaManana = d_Fech_prox;

		END IF;
		LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
		LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		
		--***********************************************************************************************************************************************
		--***************************************************** INSERTA REGISTROS DE LAS TABLAS DE CADA HILO A DETALLE PASO ********************************************
		
		LET vsNomProceso = 'INSERT_DET_HILOS';
		LET vsDescripcionProceso = 'INSERT_HILOS_TABLE DETALLE_A_PASO';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN  
		
			DROP TABLE IF EXISTS dom_cce_detalle_paso_arch32;
			DROP TABLE IF EXISTS dom_cce_detalle_paso_arch31;
			
			SELECT * FROM bdidomi:dom_cce_detalle_paso_1 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_2 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_3 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_4 where nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cod_operacion = '31'  AND cve_estatus = '02'
			INTO TEMP dom_cce_detalle_paso_arch31 WITH NO LOG;
			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso SELECT * FROM dom_cce_detalle_paso_arch31 WHERE nombre_arch = pNom_Arch31 AND cod_operacion = '31' AND tipo_registro='02' AND cve_estatus = '02';
			
			SELECT * FROM bdidomi:dom_cce_detalle_paso_1 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_2 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_3 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			UNION ALL
			SELECT * FROM bdidomi:dom_cce_detalle_paso_4 where nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cod_operacion = '32'  AND cve_estatus = '01'
			INTO TEMP dom_cce_detalle_paso_arch32 WITH NO LOG;
			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso SELECT * FROM dom_cce_detalle_paso_arch32 WHERE nombre_arch = pNom_Arch32 AND cod_operacion = '32' AND tipo_registro='02' AND cve_estatus = '01';
			
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;		
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA INSERTA REGISTROS DE LAS TABLAS DE CADA HILO A DETALLE PASO ********************************************
		
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 32 ********************************************
		
		LET vsNomProceso = 'GEN_SEC_ARCH32';
		LET vsDescripcionProceso = 'GENERA_SEC_ENCAB_SUM32';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN 
		
			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32) THEN
				LET vCuenta = 0;
				FOREACH cursor9 WITH HOLD FOR 
					SELECT nombre_arch,tipo_registro,num_secuencia,cve_estatus,cod_operacion,importe,clave_rastreo
					INTO vNom_Archv,vTipo_reg,vSecInvalida,vCve_estatus,vCod_oper,vImporte,vClave_rastreo FROM bdidomi:"informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32 AND tipo_registro='02' AND cve_estatus='01' AND cod_operacion='32'
					
					LET vNumsecArch32 = vNumsecArch32 + 1;
					
					LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumsecArch32)),7,'0');
					
					UPDATE bdidomi:"informix".dom_cce_detalle_paso SET num_secuencia = cSecuencia WHERE CURRENT OF cursor9;
					
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
			
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch32) THEN

					INSERT INTO bdidomi: "informix".dom_cce_encabezado_paso
					(nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
					num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT pNom_Arch32,cFechaFormat,'01','0000001' ,'32',cve_banco,'E',servicio,
							LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch32,16,2),5,'0'),cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,pUsuario,CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch;
				END IF;	
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch32) THEN
					--SUMARIO
					INSERT INTO bdidomi: "informix".dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,
					cod_operacion,num_bloque,num_operaciones,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT
					pNom_Arch32,
					cFechaFormat,
					'09',
					(SELECT LPAD(NVL(MAX (num_secuencia)::INTEGER + 1,0),7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Secuencia maxima
					'32',
					LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch32,16,2),5,'0'),
					(SELECT LPAD(COUNT (num_secuencia)::INTEGER,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Numero de registros
					(SELECT LPAD(SUM(importe::BIGINT),18,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32),--Importe de operaciones.
					uso_futuro_ccen,
					uso_futuro_banco,
					pUsuario,
					CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

			END IF;
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1','00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 32 ********************************************
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 31 ********************************************
		
		LET vsNomProceso = 'GEN_SEC_ARCH31';
		LET vsDescripcionProceso = 'GENERA_SEC_ENCAB_SUM31';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN
			LET vSecInvalida = '';
			LET cSecuencia = '';
			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31) THEN
				LET vCuenta = 0;
				BEGIN WORK;
				FOREACH cursor10 WITH HOLD FOR 
					SELECT nombre_arch,tipo_registro,num_secuencia,cve_estatus,cod_operacion,importe,clave_rastreo 
					INTO vNom_Archv,vTipo_reg,vSecInvalida,vCve_estatus,vCod_oper,vImporte,vClave_rastreo FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31 AND tipo_registro='02' AND cve_estatus='02' AND cod_operacion='31'
					
					LET vNumsecArch31 = vNumsecArch31 + 1;
					
					LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumsecArch31)),7,'0');
					
					UPDATE bdidomi: "informix".dom_cce_detalle_paso SET num_secuencia = cSecuencia WHERE CURRENT OF cursor10;
					
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
			
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch31) THEN
				
					--ENCABEZADO
					INSERT INTO bdidomi: "informix".dom_cce_encabezado_paso
					(nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
					num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					SELECT pNom_Arch31,cFechaFormat,'01','0000001','31',cve_banco,'E',servicio,
							LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch31,16,2),5,'0'),cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,pUsuario,CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch31) THEN
					--SUMARIO
					INSERT INTO bdidomi: "informix".dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,
					cod_operacion,num_bloque,num_operaciones,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)

					SELECT
					pNom_Arch31,
					cFechaFormat,
					'09',
					(SELECT LPAD(NVL(MAX (num_secuencia),0)::INTEGER + 1,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Secuencia maxima
					'31',
					LPAD(DAY(dFechaManana),2,'0')||LPAD(SUBSTR(pNom_Arch31,16,2),5,'0'),
					(SELECT LPAD(COUNT (num_secuencia)::INTEGER,7,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Numero de registros
					(SELECT LPAD(SUM(importe::BIGINT),18,'0') FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch31),--Importe de operaciones.
					uso_futuro_ccen,
					uso_futuro_banco,
					pUsuario,
					CURRENT::DATE
					FROM bdidomi: "informix".dom_cce_sumario_paso WHERE nombre_arch = pNom_Arch;
				END IF;	

			END IF;	
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1','00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERACION DE SECUENCIAS, ENCABEZADO, SUMARIO Y ARCHIVOS ARCH 31 ********************************************
		
		--***********************************************************************************************************************************************
		--***************************************************** GENERA ARCHIVOS CODIGO 31 Y 32  ********************************************
		
		LET vsNomProceso = 'GENERA_ARCH_COD_31_32';
		LET vsDescripcionProceso = 'GENERA ARCHIVOS COD 31 Y 32';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN 
		
			IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(pNom_Arch31))THEN
						LET vsFlagArch31 = 'V';
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(pNom_Arch31);
						EXECUTE PROCEDURE BdiDomi:sp_domi_generaarchivo(TRIM(pNom_Arch31), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
					END IF;
				END IF;
			END IF;
			IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(pNom_Arch32))THEN
						LET vsFlagArch32 = 'V';
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(pNom_Arch32) ;
						--Se genera sp sp_domi_generaarchivo32 por problema de ejecucion con el usuario sysdomi el original es sp_domi_generaarchivo
						EXECUTE PROCEDURE BdiDomi:sp_domi_generaarchivo(TRIM (pNom_Arch32), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
					END IF;
				END IF;
			END IF;
			
			IF vsCodRetorno = '00000' THEN
				EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', vsCodRetorno, pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			    YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
				LET vsCodRetorno = '00000';
			ELSE
				RETURN vsCodRetorno, vsDescripcionProceso;
			END IF;
		ELSE
			LET iExisteProc = 0;
		END IF;
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA GENERA ARCHIVOS CODIGO 31 Y 32  ********************************************
		

	    --***********************************************************************************************************************************************
		--***************************************************** ACTUALIZA ESTATUS ARCH COD 30 ********************************************
		LET vsNomProceso = 'ACT_EST_ARCH_30';
		LET vsDescripcionProceso = 'ACTUALIZA_ESTATUS_ARCH_COD_30';
		SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
		IF iExisteProc = 0 THEN
			DROP TABLE IF EXISTS act_det_paso_estatus;
			
			SELECT FIRST 1 rango1,rango2 INTO vParam1,vParam2 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_1');
			SELECT FIRST 1 rango1,rango2 INTO vParam3,vParam4 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_2');
			SELECT FIRST 1 rango1,rango2 INTO vParam5,vParam6 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_3');
			SELECT FIRST 1 rango1,rango2 INTO vParam7,vParam8 FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_4');
			
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_1 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam1 AND num_secuencia::int <= vParam2 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_2 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam3 AND num_secuencia::int <= vParam4 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_3 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam5 AND num_secuencia::int <= vParam6 AND cve_estatus IN ('01','02')
			UNION ALL
			SELECT * FROM bdidomi: "informix".dom_cce_detalle_paso_4 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia::int >= vParam7 AND num_secuencia::int <= vParam8 AND cve_estatus IN ('01','02')
			INTO TEMP act_det_paso_estatus WITH NO LOG;
			

			IF EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch) THEN
				LET vCuenta = 0;
				BEGIN WORK;
				FOREACH WITH HOLD 
					SELECT num_secuencia,cve_estatus,folio_suc INTO cSecuencia,vEstatus_cve,vFolio_suc FROM bdidomi:"informix".act_det_paso_estatus WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND cve_estatus <> '00'
						
						UPDATE bdidomi:dom_cce_detalle_paso SET cve_estatus = vEstatus_cve,folio_suc = vFolio_suc WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND tipo_registro='02' AND num_secuencia = cSecuencia;
						
						--Hago commit y vuelvo a iniciar
						LET vCuenta = vCuenta + 1;
						IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
				END FOREACH;
				
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
			END IF;
			EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , 
			YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
			LET vsCodRetorno = '00000';
		ELSE
			LET iExisteProc = 0;
		END IF;	
		
		--***********************************************************************************************************************************************
		--***************************************************** TERMINA ACTUALIZA ESTATUS ARCH COD 30 ********************************************
		
		IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE GENERRO CORRECTAMENTE

			EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch), vsFecha_Presentacion, '01') INTO vsCodRetorno;

			LET vsDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
			--ARCHIVO ORIGINAL
			EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch), vsFecha_Presentacion, 'T') INTO vsCodRetorno;

			IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

				IF (vsFlagArch31 = 'V') THEN
					EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch31), vsFecha_Presentacion2, '01') INTO vsCodRetorno;
				END IF;

				IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO

					IF (vsFlagArch31 = 'V') THEN
						EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch31), vsFecha_Presentacion2, 'T') INTO vsCodRetorno;
					END IF;

					IF (vsCodRetorno = '00000') THEN --VALIDA KE LOS DATOS DEL ARCHIVO 31 SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

						IF (vsFlagArch32 = 'V') THEN
							EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch32), vsFecha_Presentacion2, '01') INTO vsCodRetorno;

							IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
								EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (pNom_Arch32), vsFecha_Presentacion2, 'T') INTO vsCodRetorno;
							ELSE --ERROR

							END IF;
						END IF;

					ELSE -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 31 AL HITORICO
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						sERROR, vsCodRetorno, pUsuario, 'sp_Domi_MoverRegistrosHist', TRIM(pNom_Arch31) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno = '00127';
					END IF;
				END IF;
			END IF;

			IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO DE RESPUESTA SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

				LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '03' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;

				IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
					--GUARDA BITACORA EXITO
					LET vsDescripcionProceso = 'Domiciliacion Finalizada Exitosamente.';
					LET vsCodRetorno = '00000';
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sFINALIZADO, vsCodRetorno, pUsuario, 'sp_domi_encabezado_sumario', TRIM(pNom_Arch) , vsFecha_Presentacion, '02'/*EXITO*/) INTO vsCodRetorno2;
					
					--ACTUALIZA LOS ESTATUS DEL CCE_ACHIVO PARA KE LOS AMRQUE COMO TERMINADO
				
					IF (vsFlagArch31 = 'V') THEN
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado WHERE Nombre_Arch = TRIM(pNom_Arch31) ;
						EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch31), vsFecha_Presentacion2, '02'/*EXITO*/) INTO vsCodRetorno2;
						LET vsCodRetorno = '00000';
					END IF;

					IF (vsFlagArch32 = 'V') THEN
						SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado WHERE Nombre_Arch = TRIM(pNom_Arch32) ;
						EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (pUsuario, TRIM (pNom_Arch32), vsFecha_Presentacion2, '02'/*EXITO*/) INTO vsCodRetorno;
						LET vsCodRetorno = '00000';
					END IF;
				ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
					--GUARDAR BITACORA
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sERROR, vsCodRetorno, pUsuario, 'Sp_Domi_MoverArchivos', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					LET vsCodRetorno = '00130';
				END IF;
				
			ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HISTORICO
				--GUARDAR BITACORA
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;

				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
				LET vsCodRetorno = '00126';
			END IF;

		ELSE --ERROR AL GENERAR EL ARCHIVO DE RESPUESTA
			--GUARDAR BITACORA
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (pNom_Arch), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;

			EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
			sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_GeneraArchivo', TRIM(pNom_Arch) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
			LET vsCodRetorno = '00125';
		END IF;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
		
		IF (vsCodRetorno = '00000') THEN
			LET vsMensaje_Respuesta = 'GENERAL PROCESO EXITOSO';
		ELSE
			LET vsMensaje_Respuesta = 'ERROR EN PROCESO';
		END IF;
		
	RETURN vsCodRetorno,vsMensaje_Respuesta;
END;
END PROCEDURE;