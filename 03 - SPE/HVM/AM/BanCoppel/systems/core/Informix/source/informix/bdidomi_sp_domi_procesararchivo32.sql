CREATE PROCEDURE "informix".sp_domi_procesararchivo32 (pNom_Arch32 CHAR(20) ,pUsuario CHAR(8))
RETURNING CHAR(5);

 --	Declaracion de variables.
	DEFINE	dFecha_hoy						DATE;
	DEFINE dFechaActual						DATE;
	DEFINE iSQLerr							INTEGER;
	DEFINE	iExiste							INTEGER;
	DEFINE	iContadorVueltas				INTEGER;
	DEFINE	iContadorComisiones				INTEGER;
	DEFINE	iContadorCompletasPAGADAS 		INTEGER;
	DEFINE	iContadorCompletasNOPAGADAS 	INTEGER;
	DEFINE	iBanderaIndicaSiSaldoEsMayor	INTEGER;
	DEFINE	iConsecutivoArch				INTEGER;
	DEFINE	cEstatus						CHAR(1);
	DEFINE	cServicio						CHAR(1);
	DEFINE	cEstatusCta						CHAR(1);
	DEFINE	cTpoCtaCargo					CHAR(2);
	DEFINE	cTipo_operacion					CHAR(2);
	DEFINE cTipo_cta_ord					CHAR(2);
	DEFINE cTipo_cta_rec					CHAR(2);
	DEFINE cTipodeRegistro					CHAR(2);
	DEFINE cClaVeBancaria					CHAR(3);
	DEFINE cClaveBancoReceptor				CHAR(3);
	DEFINE	cTransaccCargoComision			CHAR(4);
	DEFINE	cTransaccCargoIVA				CHAR(4);
	DEFINE	cTransaccAbono					CHAR(4);
	DEFINE	cTransaccCreditoTCCondigoFun	CHAR(4);
	DEFINE	cTransaccCreditoTCCondigoRef	CHAR(4);
	DEFINE	cTransaccCreditoTC				CHAR(4);
	DEFINE csucursalcontable				CHAR(4);
	DEFINE cCodRet							CHAR(5);
	DEFINE cCodRetMensaje					CHAR(5);
	DEFINE cReferenciaNum					CHAR(7);
	DEFINE cNumSecuencia					CHAR(7);
	DEFINE cNumSecuencia30					CHAR(7);
	DEFINE cFechaAplicacion					CHAR(8);
	DEFINE cFecha_aplica					CHAR(8);
	DEFINE cFechaPresentacion				CHAR(8);
	DEFINE cNumCliente						CHAR(9);
	DEFINE cRFCcargo						CHAR(13);
	DEFINE	cImpOperacion					CHAR(15);
	DEFINE cImpIva							CHAR(15);
	DEFINE mSaldoaAbonar					CHAR(16);
	DEFINE cNumeroFolioAbono				CHAR(16);
	DEFINE cNumeroFolioCargo				CHAR(16);
	DEFINE cCve_proceso						CHAR(18);
	DEFINE cNom_Arch						CHAR(18);
	DEFINE cNom_Arch30						CHAR(18);
	DEFINE cRFCOrdenante					CHAR(18);
	DEFINE	cRfc_ord						CHAR(18);
	DEFINE cRfc_rec							CHAR(18);
	DEFINE cCuentaAbono						CHAR(20);
	DEFINE cCuentaCargo						CHAR(20);
	DEFINE cNum_cta_ord						CHAR(20);
	DEFINE cNumClienteTC					CHAR(20);
	DEFINE cTarjetaTC						CHAR(20);
	DEFINE cNumCreditoTC					CHAR(20);
	DEFINE cNum_cta_rec						CHAR(20);
	DEFINE cNombreTitular					CHAR(40);
	DEFINE cLeyenda							CHAR(40);
	DEFINE cRef_servicio					CHAR(40);
	DEFINE	cDescripcionProceso				CHAR(50);
	DEFINE cReferenciaCargoComision			CHAR(50);
	DEFINE cReferenciaCreditoTCcFun			CHAR(50);
	DEFINE cReferenciaCreditoTCcRef			CHAR(50);
	DEFINE cReferenciaCreditoTC				CHAR(50);
	DEFINE cReferenciaCargoIva				CHAR(50);
	DEFINE cReferenciaAbono					CHAR(50);
	DEFINE cRef_Leyenda						CHAR(50);
	DEFINE cNombreCargo						CHAR(50);
	DEFINE cMensaje							CHAR(200);
	DEFINE mIVA								MONEY(16,2);
	DEFINE mValorComisionIndividual 		MONEY(16,2);
	DEFINE mValorComisionTotal				MONEY(16,2);
	DEFINE mValorComisionTotPendiente 		MONEY(16,2);
	DEFINE mSaldoCuentaCargo				MONEY(16,2);
	DEFINE msaldoapagar						MONEY(16,2);
	DEFINE mtotalivacomision				MONEY(16,2);
	DEFINE mtotalcargos						MONEY(16,2);
	DEFINE mMontoRet						MONEY(16,2);
	DEFINE mImporte							MONEY(16,2);
	DEFINE c_cve_ras						CHAR(30);
	DEFINE cBandera							CHAR(40);
	DEFINE mRemanente						MONEY(14,2);
	DEFINE mInteresMoratorioCobrado			MONEY(14,2);
	DEFINE mInteresVencidoCobrado			MONEY(14,2);
	DEFINE mCapitalVencidoCobrado			MONEY(14,2);
	DEFINE mInteresVigenteCobrado			MONEY(14,2);
	DEFINE mCapitalVigenteCobrado			MONEY(14,2);
	DEFINE mImpuestoCobrado					MONEY(14,2);
	DEFINE mComisionesCobradas				MONEY(14,2);
	DEFINE mSeguroCobrado					MONEY(14,2);

	DEFINE cRfcCopp							CHAR(18);
	DEFINE cNumCte_Coppel					CHAR(20);
	DEFINE cNumCte_Proveedor				CHAR(20);
	DEFINE cNom_Arch_Salida					CHAR(20);
	DEFINE cSecuencia						CHAR(6);
	DEFINE bEnTransaccion					BOOLEAN;
	DEFINE dFecha_Comision					DATE;
	DEFINE iAuxValidBin                     INTEGER;
	DEFINE iConsecutivo_OB                  INTEGER;
	DEFINE cNumeroFolioAbono_OB             CHAR(16);
	
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE cCodRetSpCons	CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoSbc			MONEY(14,2);
	DEFINE mSdoActual		MONEY(14,2);
	DEFINE mSdoRetenido 	MONEY(14,2);
	DEFINE mSdoCong 		MONEY(14,2);
	DEFINE mImpChqSbg		MONEY(14,2);
	
	ON EXCEPTION IN(-535)
		COMMIT WORK;
		BEGIN WORK;
		--LET bEnTransaccion = 't';
	END EXCEPTION WITH RESUME;

	ON EXCEPTION SET iSQLerr
		IF iSQLerr <> 0 THEN
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
		 LET cCodRet = iSQLerr;
		 RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	 
	--SET DEBUG FILE TO "/home/sysdomi/Sp_Domi_ProcesarArchivo32.trace";
	--TRACE ON;

	--	Inicializacion de variables.
	LET cCodRet						= "00000";
	LET cCodRetMensaje					= "";
	LET cCve_proceso					= "RECARCH_32.";
	LET cNom_Arch						= "";
	LET cMensaje						= "";
	LET cEstatus						= "";
	LET cServicio						= "";
	LET dFecha_hoy						= "";
	LET dFechaActual					= '';
	LET cCuentaAbono					= "";
	LET cCuentaCargo					= "";
	LET cNumCliente					= "";
	LET cTpoCtaCargo					= "";
	LET cNombreCargo					= "";
	LET cRFCcargo						= "";
	LET cClaVeBancaria					= "";
	LET cImpIva						= "";
	LET cReferenciaNum					= "";
	LET cLeyenda						= "";
	LET cEstatusCta					= "";
	LET cClaveBancoReceptor 			= "";
	LET cImpOperacion					= "";
	LET cNombreTitular					= "";
	LET cTransaccCargoComision			= "";
	LET cTransaccCargoIVA				= "";
	LET cTransaccAbono					= "";
	LET cDescripcionProceso			="PROCESAR ARCHIVO COD 32 PRESENTADOR";
	LET cNumeroFolioAbono				= "";
	LET cNumeroFolioCargo				= "";
	LET csucursalcontable				= "";
	LET cReferenciaCargoComision		= "";
	LET cReferenciaCargoIva			= "";
	LET cReferenciaAbono				= "";
	LET cRef_Leyenda					= "";
	LET cRFCOrdenante					= "";
	LET cNum_cta_rec					= "";
	LET cNum_cta_ord					= "";
	LET cRef_servicio					= "";
	LET cNom_Arch30					= "";
	LET cRfc_ord						= "";
	LET cNumSecuencia					= "";
	LET cNumSecuencia30				= "";
	LET cFechaPresentacion				= "";
	LET cTipodeRegistro				= "";
	LET iSQLerr						= 0;
	LET iExiste						= 0;
	LET iContadorVueltas 				= 0;
	LET iConsecutivoArch 				= 0;
	LET iContadorComisiones 			= 0;
	LET icontadorcompletaspagadas 		= 0;
	LET iContadorCompletasNOPAGADAS 	= 0;
	LET mValorComisionIndividual		= 0.00;
	LET mValorComisionTotal 			= 0.00;
	LET mValorComisionTotPendiente 	= 0.00;
	LET msaldoapagar 					= 0.00;
	LET mtotalivacomision 				= 0.00;
	LET mtotalcargos 					= 0.00;
	LET mSaldoCuentaCargo 				= 0.00;
	LET mMontoRet						= 0.00;
	LET iBanderaIndicaSiSaldoEsMayor 	= 0;
	LET c_cve_ras						= "";
	LET cBandera						= "";
	LET cTransaccCreditoTCCondigoFun	= "";
	LET cTransaccCreditoTCCondigoRef	= "";
	LET cTransaccCreditoTC				= "";
	LET cReferenciaCreditoTCcFun		= "";
	LET cReferenciaCreditoTCcRef		= "";
	LET cReferenciaCreditoTC			= "";
	LET mRemanente						= "0.00";
	LET mInteresMoratorioCobrado		= "0.00";
	LET mInteresVencidoCobrado			= "0.00";
	LET mCapitalVencidoCobrado			= "0.00";
	LET mInteresVigenteCobrado			= "0.00";
	LET mCapitalVigenteCobrado			= "0.00";
	LET mImpuestoCobrado				= "0.00";
	LET mComisionesCobradas			= "0.00";
	LET mSeguroCobrado					= "0.00";
	LET cNumClienteTC					= "";
	LET cTarjetaTC						= "";
	LET cNumCreditoTC					= "";

	LET cSecuencia = '';
	LET cRfcCopp = '';
	LET cNumCte_Coppel = '';
	LET cNumCte_Proveedor = '';
	LET cNom_Arch_Salida	= '';
	LET bEnTransaccion = 'f';
	LET dFecha_Comision = '';
	--MODIFICACION OB
	LET iAuxValidBin = 0;
	LET iConsecutivo_OB = 1;
	LET cNumeroFolioAbono_OB = '';
	
	
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo.
	LET cCodRetSpCons	= '00000';
	LET cMensajeRet		= '';
	LET mSdoSbc			= 0.0;
	LET mSdoActual		= 0.0;
	LET mSdoRetenido 	= 0.0;
	LET mSdoCong 	    = 0.0;
	LET mImpChqSbg	    = 0.0;
 
	BEGIN

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO wait 3;

		--	Extrae la fecha hoy en el sistema
		SELECT Fecha_hoy INTO dFecha_hoy FROM bdicheq:sc_fechas;
		SELECT fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;

		--	Valida la longitud del usuario
		IF LENGTH (pUsuario) NOT IN (7,8) THEN
			LET cCodRet = '01300';
			RETURN cCodRet;
		END IF;

		IF LENGTH (pNom_Arch32) < 16 THEN
			LET cCodRet = '01300';

			RETURN cCodRet;
		END IF;

			--	se extrae el valor de la sucursal contable.
		SELECT valor INTO cSucursalContable FROM bdidomi:dom_parametros WHERE cod_param = '07';

		--	validar si existe en el catï¿½logo la sucursal contable.
		SELECT 1 INTO iExiste FROM bdinteg:si_sucursales WHERE sucursal = cSucursalContable;

			--	Se valida si existe la sucursal contable.
			IF iExiste = 0 Then
				LET cCodRet = '01301';
				RETURN cCodRet;
			ELSE
				LET iExiste = 0;
			END IF;

		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
		SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
			LET cCodRet = '01302';
			RETURN cCodRet;
		END IF;

		--	se extrae el valor de la transaccion de cargo.
		--SELECT valor, descripcion INTO cTransaccCargoComision, cReferenciaCargoComision FROM bdidomi:dom_parametros WHERE cod_param = '14';
		SELECT valor, descripcion INTO cTransaccCargoComision, cReferenciaCargoComision FROM bdidomi:dom_parametros WHERE cod_param = '50';
		SELECT valor, descripcion INTO cTransaccCargoIVA, cReferenciaCargoIva FROM bdidomi:dom_parametros WHERE cod_param = '15';
		--SELECT valor, descripcion INTO cTransaccAbono, cReferenciaAbono FROM bdidomi:dom_parametros WHERE cod_param = '09';
		SELECT valor, descripcion INTO cTransaccAbono, cReferenciaAbono FROM bdidomi:dom_parametros WHERE cod_param = '51';


		--	Valida si existe la transaccion de cargo.
		SELECT COUNT(numero) INTO iExiste FROM bdinteg:si_transacc WHERE numero IN (cTransaccCargoComision,cTransaccCargoIVA,cTransaccAbono);

			--	Valida si existe las transacciones parametrizadas.
		
			IF iExiste < 3 Then
				LET cCodRet = '01303';
				RETURN cCodRet;
			ELSE
				LET iExiste = 0;
			END IF;
			

		SELECT valor INTO mIVA FROM bdinteg:si_param WHERE cod_param = '47';

		IF mIVA IS NULL THEN
			LET cCodRet = '01304';
			RETURN cCodRet;
		END IF;

		IF NOT EXISTS (SELECT * FROM bdidomi:dom_cce_detalle_paso AS Det
			INNER JOIN bdidomi:dom_cat_servicios AS Ser ON (Det.rfc_ord = Ser.rfc)
			WHERE Det.nombre_arch = pNom_Arch32) THEN
			--NO EXISTEN REGISTROS PENDIENTES DE PROCESAR
			LET cCodRet = '01305';
			RETURN cCodRet;

		END IF;

		--SE OBTIENE NUMERO DE CLIENTE COPPEL
		SELECT TRIM(valor) INTO cNumCte_Coppel 
		FROM dom_parametros 
		WHERE cod_param = '45';
		
		SELECT rfc 
		INTO cRfcCopp 
		FROM dom_cat_servicios 
		WHERE num_cte = TRIM(cNumCte_Coppel);

		LET cNom_Arch_Salida = 	'S'||
							TRIM(cNumCte_Coppel)||
							'D'||
							LPAD(DAY(dFecha_hoy),2,'0') || 	LPAD(MONTH(dFecha_hoy),2,'0') || SUBSTR(YEAR(dFecha_hoy)::CHAR(4),3,2)||
							'.'||
							'01';
		SELECT MAX(fecha_insert) 
		INTO dFecha_Comision
		FROM dom_cce_detalle WHERE cod_operacion = '30' AND banco_presentador = cClaVeBancaria;

		FOREACH WITH HOLD
			SELECT DISTINCT (Det.rfc_ord),Ser.comision,Ser.cuenta_cargo_comision
			INTO cRFCOrdenante,mValorComisionIndividual,cCuentaAbono
			FROM bdidomi:dom_cce_detalle_paso AS Det
			INNER JOIN bdidomi:dom_cat_servicios AS Ser ON (Det.rfc_ord = Ser.rfc)
			WHERE Det.nombre_arch = pNom_Arch32

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
			
			-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
			SELECT 1,cuenta,num_cte, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
			INTO iExiste,cCuentaAbono,cNumCliente, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc
			FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = SUBSTR (cCuentaAbono,9,11);
			
			-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, '', '', 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoCuentaCargo;

			IF iExiste <> 1 THEN
				LET cCodret = '01305';
				RETURN cCodret;
			END IF;
			
			FOREACH WITH HOLD
				
				--Selecciona la cuenta a Procesar
				SELECT  importe,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,rfc_ord,tipo_cta_rec,num_cta_rec,rfc_rec,ref_servicio,ref_leyenda,num_secuencia,clave_rastreo
				INTO    mImporte,cTipo_operacion,cFecha_aplica,cTipo_cta_ord,cNum_cta_ord,cRfc_ord,cTipo_cta_rec,cNum_cta_rec,cRfc_rec,cRef_servicio,cRef_Leyenda,cNumSecuencia,c_cve_ras
				FROM Dom_cce_detalle_paso WHERE nombre_arch = pNom_Arch32 AND Cod_operacion = '32' AND rfc_ord = cRFCOrdenante

				--LET cCuentaAbono = cNum_cta_ord;
				--Modificacion LEAA OB
				LET iConsecutivo_OB = ++iConsecutivo_OB ;
				IF NOT EXISTS (SELECT * FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND importe = mImporte AND tipo_operacion = cTipo_operacion AND
				fecha_aplica = cFecha_aplica AND tipo_cta_ord = cTipo_cta_ord AND num_cta_ord = cNum_cta_ord AND rfc_ord = cRfc_ord AND tipo_cta_rec = cTipo_cta_rec AND
				num_cta_rec = cNum_cta_rec AND rfc_rec = cRfc_rec AND ref_servicio = cRef_servicio AND clave_rastreo = c_cve_ras ) THEN
					LET cCodret = '01305';
					RETURN cCodret;
				ELSE

					SELECT nombre_arch,tipo_registro,fecha_presentacion,num_secuencia INTO cNom_Arch30,cTipodeRegistro,cFechaPresentacion,cNumSecuencia30
					FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND importe = mImporte AND tipo_operacion = cTipo_operacion
					AND fecha_aplica = cFecha_aplica AND tipo_cta_ord = cTipo_cta_ord AND num_cta_ord = cNum_cta_ord AND rfc_ord = cRfc_ord
					AND tipo_cta_rec = cTipo_cta_rec AND num_cta_rec = cNum_cta_rec AND rfc_rec = cRfc_rec AND ref_servicio = cRef_servicio AND clave_rastreo = c_cve_ras ;

					UPDATE bdidomi:dom_cce_detalle SET cve_estatus = '01',motivo_dev = '00'
					WHERE nombre_arch = cNom_Arch30
					AND fecha_presentacion = cFechaPresentacion
					AND tipo_registro = cTipodeRegistro
					AND num_secuencia =  cNumSecuencia30
					AND clave_rastreo = c_cve_ras;

				END IF;

				SELECT importe/100,num_secuencia INTO mSaldoAPagar,cNumSecuencia FROM bdidomi:dom_cce_detalle_paso
				WHERE nombre_arch = pNom_Arch32
				AND rfc_ord = cRFCOrdenante
				AND num_cta_ord = cNum_cta_ord
				AND importe = mImporte
				AND num_cta_rec = cNum_cta_rec
				AND num_secuencia = cNumSecuencia
				AND clave_rastreo = c_cve_ras;

				IF mSaldoAPagar <= 0 THEN
					CONTINUE FOREACH;
				END IF;

				-- EMPIEZA MODIFICACION TDC OB
				--L.AGUILERA
                SELECT COUNT(*)
                INTO iAuxValidBin
                FROM bdicheq:"informix".sc_bines bin
                INNER JOIN bdinteg:"informix".si_bancos banco
                    ON bin.cve_banco = banco.banco
                WHERE banco.flg_domi_r = '1'
                    AND banco = '137'
                    AND creditodebito = 'c'
                    AND bin = SUBSTR(cNum_cta_ord,5,6);
				
				IF cTipo_cta_ord = '05' --OR (cTipo_cta_ord = '03' AND SUBSTR(cNum_cta_ord,5,6)= '426807') 
					OR (cTipo_cta_ord = '03' AND iAuxValidBin > 0)   --MODIFICACION TDC OB PARA TOMAR TODOS LOS BINES
					THEN
					LET cBandera = 'TarjetaCredito';

					-- Obtiene las transacciones del codigo fun y codigo ref.		
					SELECT valor, descripcion INTO cTransaccCreditoTCCondigoFun, cReferenciaCreditoTCcFun FROM bdidomi:dom_parametros WHERE cod_param = '37';
					SELECT valor, descripcion INTO cTransaccCreditoTCCondigoRef, cReferenciaCreditoTCcRef FROM bdidomi:dom_parametros WHERE cod_param = '38';
					SELECT valor, descripcion INTO cTransaccCreditoTC, cReferenciaCreditoTC FROM bdidomi:dom_parametros WHERE cod_param = '39';

					--Agregar IF para obtener parametros para OTROS BANCOS

					---EMPIEZA MODIFICACIÃN OB
					--L.AGUILERA
					IF SUBSTR(cNum_cta_ord,9,11) != '120000000171' THEN --diferente a la cuenta propia de bancoppel 00137180120000000171  
					--IF SUBSTR(cNum_cta_rec,1,6) != '416916' THEN --diferente a la cuenta propia de bancoppel del BIN.
						-- Obtiene las transacciones del codigo fun y codigo ref.	-- modificado para OB
						SELECT valor, descripcion INTO cTransaccCreditoTCCondigoFun, cReferenciaCreditoTCcFun FROM bdidomi:dom_parametros WHERE cod_param = '69'; --TRANSACCION TDC DOMI OB CODIGO_FUN
						SELECT valor, descripcion INTO cTransaccCreditoTCCondigoRef, cReferenciaCreditoTCcRef FROM bdidomi:dom_parametros WHERE cod_param = '70';						SELECT valor, descripcion INTO cTransaccCreditoTC, cReferenciaCreditoTC FROM bdidomi:dom_parametros WHERE cod_param = '68'; --PAGO DOMICILIACION TDC OB
					END IF;
					---TERMINA MODIFICACIÃN OB
					
					IF cTransaccCreditoTCCondigoFun IS NULL OR cTransaccCreditoTCCondigoRef IS NULL OR cTransaccCreditoTC IS NULL Then
						LET cCodRet = '01306';
						RETURN cCodRet;
					END IF;
					
					SELECT numcte,LPAD(num_tarjeta,20,'0'),num_credito INTO cNumClienteTC,cTarjetaTC,cNumCreditoTC	
					FROM bdicred:sd_tarjeta 
					WHERE empresa = '001'
						AND num_tarjeta = SUBSTR(cNum_cta_ord ,5,16);
		
					SELECT 1 INTO iExiste FROM bdicred:sd_maecred WHERE empresa = '001' AND num_credito = cNumCreditoTC;
					
					IF iExiste = 1 THEN
						--MODIFICACION OB PARA GENERAR FOLIO CON CLIENTE TC
						--LEAA
						CALL bdicheq:sp_generafolionomina(cNumClienteTC)Returning cCodRet,cNumeroFolioAbono;
						--CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRet,cNumeroFolioAbono;
						LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
						

						CALL bdicred:principalrefer('001',cNumCreditoTC,1,cTarjetaTC,'informix',cSucursalContable,cNumeroFolioAbono,cTransaccCreditoTC,'0.00',mSaldoAPagar,cReferenciaCreditoTC)
						RETURNING cCodret,mRemanente,mInteresMoratorioCobrado,mInteresVencidoCobrado,mCapitalVencidoCobrado,mInteresVigenteCobrado,mCapitalVigenteCobrado,mImpuestoCobrado,mComisionesCobradas,mSeguroCobrado;
					END IF;
				ELSE
					LET cBandera = 'CuentaClabeTarjeta';
					CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRet,cNumeroFolioAbono;
					LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
					--cCuentaAbono
					CALL bdicheq:abono_ref ("001", cSucursalContable, pUsuario,  cTransaccAbono, "0000", cNumeroFolioAbono, cCuentaAbono,
					0, mSaldoAPagar, mSaldoAPagar, 0, 0, 0, "01",cReferenciaAbono, '', pUsuario) Returning cCodRet;
				END IF;

				IF cCodRet <>0 THEN
					CONTINUE FOREACH;
				ELSE
					UPDATE bdidomi:dom_cte_detalle SET estatus = '01',
					comision_cobrada = LPAD((mValorComisionIndividual * 100):: INTEGER,16,'0'),
					iva_cobrado = LPAD(((mValorComisionIndividual * mIVA) * 100):: INTEGER,16,'0')
					WHERE nombre_arch_cce = cNom_Arch30
					AND fecha_presentacion_cce = cFechaPresentacion
					AND tipo_registro_cce = cTipodeRegistro
					AND numero_secuencia_cce =  cNumSecuencia30
					AND cuenta_abono = cNum_cta_ord
					AND cuenta_cargo = cNum_cta_rec;


					UPDATE bdidomi:dom_cce_detalle SET folio_suc = cNumeroFolioAbono
					WHERE nombre_arch = cNom_Arch30
					AND fecha_presentacion = cFechaPresentacion
					AND tipo_registro = cTipodeRegistro
					AND num_secuencia =  cNumSecuencia30
					AND clave_rastreo = c_cve_ras;

					UPDATE bdidomi:dom_cce_detalle_paso SET folio_suc = cNumeroFolioAbono
					WHERE nombre_arch = pNom_Arch32
					AND rfc_ord = cRFCOrdenante
					AND num_cta_ord = cNum_cta_ord
					AND importe = mImporte
					AND num_cta_rec = cNum_cta_rec
					AND num_secuencia = cNumSecuencia
					AND clave_rastreo = c_cve_ras;
					
					IF cRFCOrdenante = cRfcCopp THEN				
						SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0') 
						INTO cSecuencia FROM bdidomi:dom_cte_detalle_paso
						WHERE nombre_arch = cNom_Arch_Salida;
					
					
						INSERT INTO dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
						SELECT 	cNom_Arch_Salida, CURRENT::DATE, tipo_registro, cSecuencia, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,  
						cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
						estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, CURRENT::DATE, tipo_cta_abono, cNumeroFolioAbono
						FROM dom_cte_detalle
						WHERE nombre_arch_cce = cNom_Arch30
						AND fecha_presentacion_cce = cFechaPresentacion
						AND tipo_registro_cce = cTipodeRegistro
						AND numero_secuencia_cce =  cNumSecuencia30
						AND cuenta_abono = cNum_cta_ord
						AND cuenta_cargo = cNum_cta_rec;
					END IF;
				END IF;
			END FOREACH;
			
			--sdo_actual-(sdo_cong + sdo_retenido+imp_chq_sbg)
			-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
			SELECT cuenta,num_cte, sdo_actual, sdo_cong, sdo_retenido, imp_chq_sbg, saldo_sbc
			INTO cCuentaAbono,cNumCliente, mSdoActual, mSdoCong, mSdoRetenido, mImpChqSbg, mSdoSbc
			FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaAbono;
			
			-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', mSdoActual, mSdoRetenido, mSdoCong, mSdoSbc, mImpChqSbg, '', '', 'F', '1') INTO cCodRetSpCons, cMensajeRet, mSaldoCuentaCargo;

			SELECT COUNT(*) * mValorComisionIndividual INTO mValorComisionTotal FROM bdidomi:dom_cce_detalle_paso
			WHERE nombre_arch = pNom_Arch32 AND rfc_ord = cRFCOrdenante;

			LET mTotalIVAComision = mValorComisionTotal * mIVA;
			LET mTotalCargos = mValorComisionTotal + mTotalIVAComision;
			
			IF mValorComisionTotal = 0 THEN
				CONTINUE FOREACH;
			ELSE
				--Se agregan estas lines y se comenta bloque siguiente con el proposito de manejar un cobro mensual de comisiones en un procedimiento independiente (sp_domi_cargo_comisiones)
				SELECT num_cte 
				INTO cNumCte_Proveedor 
				FROM dom_cat_servicios 
				WHERE rfc = TRIM(cRFCOrdenante);
				
				INSERT INTO dom_cargo_comision_prov(fecha_comision, num_cte, rfc, transaccion, estatus, comision, iva, fecha_cargo, fecha_insert, fecha_movto) 
				VALUES(dFecha_Comision, cNumCte_Proveedor, cRFCOrdenante, cTransaccCargoComision, 'P', mValorComisionTotal, mTotalIVAComision, '', CURRENT::DATE, (SELECT DBINFO('utc_to_datetime', sh_curtime)FROM sysmaster:"informix".sysshmvals));
			END IF;

			--IF mTotalCargos <= mSaldoCuentaCargo THEN
			--
			--	--	Genera el folio del cargo para el cliente.
			--	CALL bdicheq:sp_generafolionomina(pUsuario)RETURNING cCodRet,cNumeroFolioCargo;
			--	LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

			--	--	se llama la ejecucion del cargo para el cliente.
			--	CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoComision, "0000", cNumeroFolioCargo,
			--	cCuentaAbono,0, mValorComisionTotal,"01", cReferenciaCargoComision, '', pUsuario) RETURNING cCodRet,cTransaccCargoComision,dFecha_hoy,mSaldoCuentaCargo,mMontoRet;

			--	LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

			--	IF cCodRet <> 0 THEN
				
			--		IF cCodRet IN ("00549", "00550", "00777")  THEN
			--			 COMMIT WORK;
			--		END IF;
			--		
			--		BEGIN WORK;
			--		LET bEnTransaccion = 't';
			--			SELECT valor INTO cTransaccCargoComision FROM bdidomi:dom_parametros WHERE cod_param = '50';
			--			SELECT valor INTO cTransaccCargoIVA FROM bdidomi:dom_parametros WHERE cod_param = '15';
			--			
			--			CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--			
			--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--			VALUES ('001',cCuentaAbono,cTransaccCargoComision,mValorComisionTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);
						
			--			CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
						
			--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--			VALUES ('001',cCuentaAbono,cTransaccCargoIVA,mTotalIVAComision,0.00,dFechaActual,'','P',cNumeroFolioCargo);				
			--			
			--			LET cCodRet = '00000';
			--		COMMIT WORK;
			--		LET bEnTransaccion = 'f';
			--	ELSE
			--		--	Genera el folio del cargo para el cliente.
			--		CALL bdicheq:sp_generafolionomina(pUsuario)RETURNING cCodRet,cNumeroFolioCargo;
			--		LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
			--		--	se llama la ejecucion del cargo para el cliente.
			--		CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoIVA, "0000", cNumeroFolioCargo,
			--		cCuentaAbono,0, mTotalIVAComision,"01", cReferenciaCargoIva, '', pUsuario) RETURNING cCodRet,cTransaccCargoIVA,dFecha_hoy,mSaldoCuentaCargo,mMontoRet;

			--		LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
			--		
			--		IF cCodRet <> 0 THEN
			--			IF cCodRet IN ("00549", "00550", "00777")  THEN
			--				 COMMIT WORK;
			--			END IF;
						
			--			BEGIN WORK;
			--			LET bEnTransaccion = 't';
			--				SELECT valor INTO cTransaccCargoIVA FROM bdidomi:dom_parametros WHERE cod_param = '15';

			--				CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--				LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
							
			--				INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--				VALUES ('001',cCuentaAbono,cTransaccCargoIVA,mTotalIVAComision,0.00,dFechaActual,'','P',cNumeroFolioCargo);
							
			--				LET cCodRet = '00000';
			--			COMMIT WORK;
			--			LET bEnTransaccion = 'f';
			--		END IF;

			--		CONTINUE FOREACH;
			--	END IF;
			--ELSE

			--	SELECT COUNT(*) INTO iContadorComisiones FROM bdidomi:dom_cce_detalle_paso
			--	WHERE nombre_arch = pNom_Arch32 AND rfc_ord = cRFCOrdenante;

			--	LET mValorComisionTotal = 0;
			--	LET mTotalIVAComision = 0;
			--	LET mTotalCargos  = 0;

			--	FOR iContadorCompletasPAGADAS = 1 TO iContadorComisiones

			--		LET mValorComisionTotal = iContadorCompletasPAGADAS * mValorComisionIndividual;
			--		LET mTotalIVAComision = mValorComisionTotal * mIVA;
			--		LET mTotalCargos = mValorComisionTotal + mTotalIVAComision;

			--		IF mTotalCargos > mSaldoCuentaCargo AND mSaldoCuentaCargo > 0 THEN
			--			LET iBanderaIndicaSiSaldoEsMayor = 1;
			--			EXIT FOR;
			--		END IF;
			--	END FOR;

			--	IF iBanderaIndicaSiSaldoEsMayor = 1 THEN
			--		LET iContadorCompletasPAGADAS = iContadorCompletasPAGADAS - 1;
			--		LET iBanderaIndicaSiSaldoEsMayor = 0;
			--	END IF;
				
			--	LET mValorComisionTotal = iContadorCompletasPAGADAS * mValorComisionIndividual;
			--	LET mTotalIVAComision = mValorComisionTotal * mIVA;
			--	LET mTotalCargos = mValorComisionTotal + mTotalIVAComision;
			--	LET iContadorCompletasNOPAGADAS = iContadorComisiones - iContadorCompletasPAGADAS;
					
			--	IF mValorComisionTotal = 0 THEN
			--		CONTINUE FOREACH;
			--	END IF;

			--	IF mValorComisionTotal > 0 AND mTotalIVAComision > 0 THEN
			--		--	Genera el folio del cargo para el cliente.
			--		CALL bdicheq:sp_generafolionomina(pUsuario)RETURNING cCodRet,cNumeroFolioCargo;
			--		LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

			--		--	se llama la ejecucion del cargo para el cliente.
			--		CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoComision, "0000", cNumeroFolioCargo,
			--		cCuentaAbono,0, mValorComisionTotal,"01", cReferenciaCargoComision, '', pUsuario) RETURNING cCodRet,cTransaccCargoComision,dFecha_hoy,mSaldoCuentaCargo,mMontoRet;

			--		LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

			--		IF cCodRet <> 0 THEN
			--			IF cCodRet IN ("00549", "00550", "00777")  THEN
			--				 COMMIT WORK;
			--			END IF;				
			--			BEGIN WORK;
			--			LET bEnTransaccion = 't';
			--				SELECT valor INTO cTransaccCargoComision FROM bdidomi:dom_parametros WHERE cod_param = '50';
			--				SELECT valor INTO cTransaccCargoIVA FROM bdidomi:dom_parametros WHERE cod_param = '15';
						
			--				CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--				LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
			--				INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--				VALUES ('001',cCuentaAbono,cTransaccCargoComision,mValorComisionTotal,0.00,dFechaActual,'','P',cNumeroFolioCargo);
			--				
			--				CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--				LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
			--				
			--				INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--				VALUES ('001',cCuentaAbono,cTransaccCargoIVA,mTotalIVAComision,0.00,dFechaActual,'','P',cNumeroFolioCargo);
			--				
			--				LET cCodRet = '00000';
			--			COMMIT WORK;
			--			LET bEnTransaccion = 'f';
			--		ELSE
			--			--	Genera el folio del cargo para el cliente.
			--			CALL bdicheq:sp_generafolionomina(pUsuario)RETURNING cCodRet,cNumeroFolioCargo;

			--			LET cCodRet = LPAD(TRIM(cCodRet),5,'0');

			--			--	se llama la ejecucion del cargo para el cliente.
			--			CALL bdicheq:cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargoIVA, "0000", cNumeroFolioCargo,
			--			cCuentaAbono,0, mTotalIVAComision,"01", cReferenciaCargoIva, '', pUsuario) RETURNING cCodRet,cTransaccCargoIVA,dFecha_hoy,mSaldoCuentaCargo,mMontoRet;

			--			LET cCodRet = LPAD(TRIM(cCodRet),5,"0");
						
			--			IF cCodRet <> 0 THEN
			--				IF cCodRet IN ("00549", "00550", "00777")  THEN
			--					 COMMIT WORK;
			--				END IF;					
			--				BEGIN WORK;
			--				LET bEnTransaccion = 't';
			--					SELECT valor INTO cTransaccCargoIVA FROM bdidomi:dom_parametros WHERE cod_param = '15';
							
			--					CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--					LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
			--					
			--					INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--					VALUES ('001',cCuentaAbono,cTransaccCargoIVA,mTotalIVAComision,0.00,dFechaActual,'','P',cNumeroFolioCargo);
								
			--					LET cCodRet = '00000';
			--				COMMIT WORK;
			--				LET bEnTransaccion = 'f';
			--			END IF;
			--		END IF;
			--	END IF;
				
			--	LET mValorComisionTotPendiente = iContadorCompletasNOPAGADAS * mValorComisionIndividual;
				
			--	IF mValorComisionTotPendiente > 0 THEN
			--		BEGIN WORK;
			--		LET bEnTransaccion = 't';
			--			SELECT valor INTO cTransaccCargoComision FROM bdidomi:dom_parametros WHERE cod_param = '50';
			--			SELECT valor INTO cTransaccCargoIVA FROM bdidomi:dom_parametros WHERE cod_param = '15';
					
			--			--Genera el folio del cargo a la cuenta cargo.
			--			CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--			LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
			--			--Registro Comisiones pendientes
			--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--			VALUES ('001',cCuentaAbono,cTransaccCargoComision,mValorComisionTotPendiente,0.00,dFechaActual,'','P',cNumeroFolioCargo);
						
			--			CALL bdicheq:sp_generafolionomina(pUsuario)Returning cCodRetMensaje,cNumeroFolioCargo;
			--			LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
						
			--			INSERT INTO bdicheq:sc_detcomis(empresa,cuenta,comision,monto_com,pago_com,fecha_alta,fecult_pago,estado_com,folio_suc)
			--			VALUES ('001',cCuentaAbono,cTransaccCargoIVA,(mValorComisionTotPendiente * mIVA),0.00,dFechaActual,'','P',cNumeroFolioCargo);
						
			--			LET cCodRet = '00000';
			--		COMMIT WORK;
			--		LET bEnTransaccion = 'f';
			--	END IF;
			--END IF;
		END FOREACH;
		LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
		RETURN cCodRet;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Antonio Bastidas Lopez',
'Descripcion: Procesa las instrucciones de cargo que fueron efectuadas por otras instituciones bancarias,',
'se abonara al cliente "proveedor" el monto cobrado y se le efectuara el cobro de IVA & Comision por efectuar la transaccion.',
'Fecha: 2009/08/06',
'Version: 20090911.1123',
'Descripcion: Procesar archivos pagados para tarjeta de crï¿½dito, donde se incluye el llamado al principalrefer y se adapta el flujo para',
'realizar el pago del crï¿½dito',
'Fecha: 2010/02/08',
'Version: 20100208.1123',
'BD: BDIDOMI',
'Descripcion: Se modifica proceso para que inserte en la tabla dom_cte_detalle_paso',
'Fecha: 2017/10/05',
'Autor: Ingrid Pamela Cazarez Villegas',
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdidomi',
'FECHA :        02-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      2.01.1';