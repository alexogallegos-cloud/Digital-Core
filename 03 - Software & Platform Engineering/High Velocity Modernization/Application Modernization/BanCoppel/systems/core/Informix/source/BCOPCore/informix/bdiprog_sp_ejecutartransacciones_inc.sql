CREATE PROCEDURE "informix".sp_ejecutartransacciones_inc(pcEmpresa CHAR(3),	pdFecha DATE, pcCveCanal CHAR(2), pcUsuario CHAR(8))
RETURNING CHAR(5),CHAR(100);
DEFINE sql_err    		INTEGER;
DEFINE vcCodRet   		CHAR(5);
DEFINE vcMensaje  		CHAR(100);
DEFINE vcStatus   		CHAR(1);
DEFINE vdFechaHoy 		DATE;
DEFINE vcTansacc  		CHAR(4);
DEFINE vcTansacc2		CHAR(4);
DEFINE vcTransuc  		CHAR(4);
DEFINE vcTransucSPEI  	CHAR(4);
DEFINE viCheque	  		INTEGER;
DEFINE vcDivisa   		CHAR(2);
DEFINE vcodretTemp    	CHAR(5);
DEFINE vcodret      	CHAR(5);
DEFINE vcCodRetReverso  CHAR(5);
DEFINE vctranret   		CHAR(4);
DEFINE vdfechoy    		DATE;
DEFINE vmsdodisp, vmontoret	MONEY(16,2);
DEFINE vcFolioSuc 		CHAR(16);
DEFINE vcFolioSucCargo	CHAR(16);
DEFINE vcCveProg  		CHAR(10);
DEFINE vcNoCliente,vcNoCliente2	CHAR(20);
DEFINE vcConcepto  		CHAR(60);
DEFINE vcSucursal 		CHAR(4);
DEFINE vcNoCuentaOri 	CHAR(20);
DEFINE vcNoCuentaDest 	CHAR(20);
DEFINE vmMonto    		MONEY(16,2);
DEFINE vcNoTarjeta 		CHAR(20);
DEFINE vcReferencia 	CHAR(40);
DEFINE viNumReg 		INTEGER;
DEFINE vcBancoDest    	INTEGER;
DEFINE vcBancoDest2    	INTEGER;
DEFINE vcCveCtaOri		CHAR(2);
DEFINE vmImporte 	 	MONEY(16,2);
DEFINE vmImporteIVA  	MONEY(16,2);
DEFINE vcRef1			CHAR(40);
DEFINE vcRef2			CHAR(20);
DEFINE vcRefCob 		CHAR(40);
DEFINE viTpoSPEI		INTEGER;
DEFINE vmComisionSPEI	MONEY(16,2);
DEFINE vmpComisionSPEI	MONEY(16,2);
DEFINE vcTarifaSPEI		VARCHAR(18,1);
DEFINE vcNombreCliente 	CHAR(100);
DEFINE vcNombreBen 		CHAR(100);
DEFINE vcRFC			CHAR(13);
DEFINE vcRFCBen			CHAR(13);
DEFINE vcCveCtaBen		CHAR(2);
DEFINE vcCveRastreoSPEI	CHAR(30);
DEFINE vcNumCredito		CHAR(20);
DEFINE vcCategoria		CHAR(2);
DEFINE vcConvenio		CHAR(5);
DEFINE vcTranSucTelmex  CHAR(100);
DEFINE vcFlgporccomtrans_conv 	CHAR(1);
DEFINE vdPorc_com_trans_conv 	MONEY(16,2);
DEFINE vcFlgimpcomtrans_conv 	CHAR(1);
DEFINE vdImp_com_trans_conv 	MONEY(16,2);
DEFINE deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente 	DECIMAL (6,2);
DEFINE viIvaConvenio			INT;
DEFINE vcFlgporccomtrans_cte	CHAR(1);
DEFINE vmPorc_com_trans_cte		MONEY(16,2);
DEFINE vcFlgimpcomtrans_cte		CHAR(1);
DEFINE vmImp_com_trans_cte		MONEY(16,2);
DEFINE viConsecutivo			INTEGER;
DEFINE viConsecutivo2			INTEGER;
DEFINE vcMsgError				CHAR(200);
DEFINE vcFlgError           	CHAR(1);
DEFINE vcAplicarReversionDebito CHAR(1);
DEFINE vcAplicarReversionDebitoAbono CHAR(1);
DEFINE vcTranAbonoCred			CHAR(4);
DEFINE vcAplicaRollback			CHAR(1);
DEFINE vcFechaFolio				CHAR(6);
DEFINE vcHHMMSSFolioAbono		CHAR(9);
DEFINE vcHHMMSSFolio			CHAR(9);
DEFINE vcHHMMSSFolio2			CHAR(9);
DEFINE vcTranccAbono			CHAR(4);
DEFINE vcTranccAbonoTemp		CHAR(4);
DEFINE vcTranccAbonoTerc		CHAR(4);
DEFINE vcTranccTemp				CHAR(4);
DEFINE vcTipoPago				CHAR(2);
DEFINE vtransaccion				INTEGER;
DEFINE vcPrefijo				CHAR(3);
DEFINE vcSufijo				    CHAR(3);
DEFINE vcCveMensajes			CHAR(8);
DEFINE vcCuentaInvalida, vRechazo	CHAR(1);
DEFINE vcIvaSpei				CHAR(5);
DEFINE vcImpIvaSpei				CHAR(5);
DEFINE vcpImpIvaSpei			CHAR(5);
DEFINE vcMensajeSP				CHAR(50);
DEFINE vproducto  				CHAR(4);
DEFINE viTipo_spei              INTEGER;
DEFINE vCvePago                 char(3);
DEFINE vCvePago_ant             char(3);
DEFINE vcBancoDest_ant        	INTEGER;
DEFINE vcCtaDestino	            CHAR(20);
DEFINE vcTansacCargo    		CHAR(4);
DEFINE vcTansacAbono    		CHAR(4);
DEFINE vcDescripcion    		CHAR(20);
DEFINE vporce                   MONEY(14,2);
DEFINE vcve_pago,vccve_programa CHAR(2);
DEFINE vcnotifica, vcnotificaben CHAR(2);
DEFINE vcbenemail 				CHAR(100); --Se modifica rango a 100 caracteres.
DEFINE vcbencelular  			CHAR(10);
DEFINE vcDescPago	  			CHAR(30);
DEFINE vImporte2	            CHAR(16);
DEFINE vcauxnotifica           	CHAR(1);
DEFINE vidmensaje1		 		CHAR(10);
DEFINE vcAux				 	CHAR(100); --Se modifica por que se utiliza en parte para el email (ahora de 100 caracteres).
DEFINE vcNomBancoDest	 		CHAR(40);
DEFINE vmMAximo, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9, vsdo_cta, vmto_total MONEY(14,2);
DEFINE vcTipoPersona			CHAR(2);
--	2013.11.01 FRG-i	-	Se agrega validaciÃ³n de cierre procesos centrales por Proy. Indep. Sistemas.
DEFINE CdRetVerSis 				CHAR (5);
DEFINE IndCrreCred 				CHAR (1);
DEFINE IndDispCred 				CHAR (1);
DEFINE IndCrreChqs 				CHAR (1);
DEFINE IndDispChqs 				CHAR (1);
DEFINE IndCrreInvs 				CHAR (1);
DEFINE IndDispInvs 				CHAR (1);
DEFINE IndCrreSrvs 				CHAR (1);
DEFINE flg_indicadores			CHAR (1);
DEFINE IndsCred 				CHAR (1);
DEFINE cDescripcionSPJ	 		CHAR(100);

DEFINE vcemicel 				CHAR(10); -- Se agrega variable para el e-mail del emisor.
-- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
DEFINE cCodRet                      CHAR(5);
DEFINE cMensajeRet                  CHAR(50); 
DEFINE mSdoActual                   MONEY(14,2);
DEFINE mSdoRetenido                 MONEY(14,2);
DEFINE mSdoCong                     MONEY(14,2);
DEFINE mSaldoSbc                    MONEY(14,2);
DEFINE mImpChqSbg                   MONEY(14,2);

--	2013.11.01 FRG-f
	ON EXCEPTION SET sql_err
		LET vcCodRet = sql_err;
		IF  vcAplicaRollback = 'S' THEN
			ROLLBACK WORK;
		END IF;
		IF vcAplicarReversionDebito = 'S' THEN
			CALL bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
		END IF;
		IF vcAplicarReversionDebitoAbono = 'S' THEN
			CALL bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSuc, 'A') RETURNING vcCodRetReverso;
		END IF;
			LET vcMsgError = 'ERROR AL EJECUTAR LA TRANSACCION';
			INSERT INTO bdiprog:"informix".pp_errores( cod_error, descripcion, fecha, hora)
			VALUES( vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
		RETURN vcCodRet,'ERROR EN INFORMIX.';
	END EXCEPTION;
	ON EXCEPTION IN (-535)
	  LET vtransaccion = 1;
	END EXCEPTION WITH RESUME;
--	2013.11.01 FRG-i


				SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ejecutartransacciones_inc.out';
				TRACE ON;				
			
LET vcCodRet = '';
LET vcMensaje = '';

LET vcemicel = '';

LET CdRetVerSis		= '';
LET IndCrreCred 	= '';
LET IndDispCred 	= '';
LET IndCrreChqs 	= '';
LET IndDispChqs 	= '';
LET IndCrreInvs 	= '';
LET IndDispInvs 	= '';
LET IndCrreSrvs 	= '';
LET flg_indicadores = '';
LET IndsCred		= '0';
--	2013.11.01 FRG-f
LET viNumReg = 0;
LET vcMsgError = '';
LET vcAplicarReversionDebito = 'N';
LET vcAplicaRollback = 'N';
LET vcAplicarReversionDebitoAbono = 'N';
LET vcTranccAbono = '';
LET vcTipoPago = '';
LET vcTranccTemp = '';
LET vcTranccAbonoTemp = '';
LET vtransaccion = 0;
LET vsdo_cta = 0;
LET vmto_total = 0;
LET vcFlgError ='0';
LET vporce = 0;
LET vRechazo = 'N';
LET cDescripcionSPJ	= 'Ejecucion de pagos programados 8:00 am y 12:00 pm';
-- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
LET cCodRet = '00000';
LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
LET mSdoActual = 0.00;
LET mSdoRetenido = 0.00;
LET mSdoCong  = 0.00;
LET mSaldoSbc = 0.00;
LET mImpChqSbg = 0.00;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	IF NVL(pcEmpresa,'') = '' OR NVL(pdFecha,'') = '' OR NVL(pcUsuario,'') = '' THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '01';
		RETURN vcCodRet,vcMensaje;
	END IF;
	IF NOT EXISTS ( select cve_canal from pp_tpcanal where cve_canal = pcCveCanal ) THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '64';
		RETURN vcCodRet,vcMensaje;
	END IF;
	SELECT fecha_hoy INTO vdFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa='001';
	IF vdFechaHoy <> pdFecha THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '96';
		RETURN vcCodRet,vcMensaje;
	END IF;
	SELECT {+INDEX (bdiprog:"informix".pp_procesos 110_15)} status INTO vcStatus FROM bdiprog:"informix".pp_procesos WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
	IF vcStatus = '2' THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '97';
		RETURN vcCodRet,vcMensaje;
	END IF;
	IF vcStatus IS NULL THEN
		INSERT INTO bdiprog:"informix".pp_procesos VALUES('ejec_trans',pdFecha,'0',pcUsuario,CURRENT::DATE);
	END IF;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PP_ET', pdFecha, '0', 'informix', 'sp_ejecutartransacciones', cDescripcionSPJ);
	
--	2013.11.06-FRG-i
EXECUTE FUNCTION bdinteg:verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
	IF CdRetVerSis <> '000'
		then
			LET vcCodRet = '99999';
			LET vcMensaje = 'Error en la ejecucion SP bdinteg:verifica_sistemas';
			LET vcMsgError = vcMensaje;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));					
	END IF;
	if	IndCrreCred <> '1' or IndDispCred <> '1' or IndCrreChqs <> '1' or IndDispChqs <> '1' or IndCrreSrvs <> '1'
		then
			let flg_indicadores = '0';
		else
			let flg_indicadores = '1';
	end if;
--	2013.11.06-FRG-f
	if vtransaccion = 1 then
	   COMMIT WORK;
	end if;
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '04'; 
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc2 FROM bdiprog:"informix".pp_parametros WHERE cve_param = '18'; 
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTransuc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '06';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO viCheque  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '07';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcDivisa  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '08';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranccAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '09';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranccAbonoTerc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '19';
	 LET vdFechaHoy = CURRENT::DATE;
	 LET vcHHMMSSFolio 		=  replace (substring (current FROM 12  FOR 8 ), ':', '');
	 LET vcFechaFolio 		=  SUBSTRING (YEAR(vdFechaHoy) FROM 3 FOR 2) || LPAD(MONTH(vdFechaHoy),2,'0') || LPAD(DAY(vdFechaHoy),2,'0');
	 LET vcSufijo 			=  SUBSTRING ( vcFechaFolio FROM 4 FOR 3);
	 LET vcPrefijo 			=  SUBSTRING ( vcFechaFolio FROM 1 FOR 3 );
	 LET vcHHMMSSFolio		=  vcSufijo || vcHHMMSSFolio;
	 LET vcHHMMSSFolio2			= vcHHMMSSFolio;
	 LET vcHHMMSSFolioAbono		=  vcHHMMSSFolio; 
	-- Traspasos entre Cuentas Efectivas Bancoppel Propias"  y hacia un tercero".
--	2013.11.01 FRG-I --	ValidaciÃ³n disponibilidad Sistemas (bdicheq):
	if IndCrreChqs <> '1'
		then
			LET vcCodRet = '00004';
			LET vcMsgError = 'Sistema CHEQUES No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parÃ¡metros con apoyo de MO/JG');
			RETURN vcCodRet, vcMensaje;
		else
			if IndDispChqs <> '1'
				then
					LET vcCodRet = '00005';
					LET vcMensaje = 'Sistema CHEQUES Temporalmente Fuera de Servicio.';
					LET vcMsgError = vcMensaje;
					INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
					VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parÃ¡metros con apoyo de MO/JG');
					RETURN vcCodRet, vcMensaje;
				else
			end if;
	end if;
--	2013.11.01 FRG-F
	FOREACH with hold
		SELECT pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cuenta_destino, pagoprog.importe, pagoprog.descripcion, pagopend.consecutivo, pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vmMonto ,vcConcepto, viConsecutivo, vcTipoPago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('01','02') and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';
		IF NOT vmMonto <= vmMaximo THEN
				LET vcodretTemp  = '99998';
			IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN
				LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET  estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vRechazo = 'S';
			CONTINUE FOREACH;
		END IF;
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
		SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente   AND tipo_tarjeta = 'T' AND status_tar = 'A';
		LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
		BEGIN WORK;
	    LET vcAplicaRollback = 'S';
		IF vcTipoPago = '01' THEN
			LET vcDescPago = 'A CUENTAS PROPIAS';
			--Se agrega al select que consulte el tipo de persona.
			SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), tpo_persona INTO vcNombreBen, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;			
				--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
				IF vcNombreBen IS NULL OR vcNombreBen='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
					SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreBen FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				END IF;
			LET vcHHMMSSFolio = vcHHMMSSFolio + 1;
            LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
			LET vcFolioSucCargo =   vcPrefijo  || vcHHMMSSFolio || vcTansacc;
			LET vcTranccTemp = vcTansacc;
			LET vcTranccAbonoTemp = vcTranccAbono;
		ELSE
			LET vcDescPago = 'A CUENTA DE TERCEROS';
			SELECT LIMIT 1 nombre INTO vcNombreBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest;			
			LET vcHHMMSSFolio = vcHHMMSSFolio + 1;
			LET vcFolioSucCargo =   vcPrefijo  || vcHHMMSSFolio || vcTansacc2;
			LET vcTranccTemp = vcTansacc2;
			LET vcTranccAbonoTemp = vcTranccAbonoTerc;
		END IF;
        CALL bdicheq:"informix".sp_generafolionominapagos('informix') Returning vcodret,vcFolioSucCargo;
		LET vcMsgError = 'Error de informix en trasacciones propias y terceros al aplicar cargo_ref con cuenta origen: ' || vcNoCuentaOri;
		CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTranccTemp, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
								RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
		IF TRIM(vcodretTemp) = '000' THEN
			SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
			LET vcNoTarjeta = '';
			LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
			LET vcMsgError = 'Error de informix en trasacciones propias y terceros al aplicar abono_ref con cuenta destino: ' || vcNoCuentaDest;
			LET vcAplicarReversionDebito = 'S';
			CALL bdicheq:"informix".abono_ref( '001', vcSucursal, pcUsuario, vcTranccAbonoTemp, vcTransuc, vcFolioSucCargo, vcNoCuentaDest, 0, vmMonto, vmMonto, 0.00, 0.00, 0, vcDivisa, vcReferencia,	vcNoTarjeta, pcUsuario)
									RETURNING vcodretTemp;
				IF 	TRIM(vcodretTemp) = '000' THEN
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, vcNoTarjeta , '1', 
						vcNoCuentaOri, vcNoCuentaDest, 'BANCOPPEL, S.A.', vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIRARIO
						IF vcnotificaben = '02' THEN
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamaÃ±o variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;				
				ELSE
					call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario, vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
					LET vRechazo = 'S'; 
					IF vcodretTemp > 0 THEN
						IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
							SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
							IF vcMsgError IS NULL THEN
								LET vcMsgError = 'ERROR EN EJECUCION DE ABONO_REF';
							END IF;
							INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
						END IF;
						UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = vcodretTemp  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					ELSE -- ERROR DE INFORMIX.
						INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
						VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
					END IF;
					IF trim(vcCodRetReverso) <> '000' THEN
						ROLLBACK WORK;
						SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '99';
						RETURN vcCodRet,vcMensaje;
					END IF;
				END IF;
		ELSE
			LET vRechazo = 'S'; 
			IF trim(vcodretTemp)  > 0 THEN
				IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
					SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
					IF vcMsgError IS NULL THEN
						LET vcMsgError = 'ERROR EN EJECUCION DE CARGO_REF';
					END IF;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
				END IF;
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
						UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg;
				END IF;
				IF trim(vcodretTemp) = '400' THEN
					LET viConsecutivo2 = viConsecutivo - 3;
					SELECT COUNT(cve_pagoprog) INTO viNumReg FROM bdiprog:"informix".pp_pagospend
					WHERE cve_pagoprog = vcCveProg and consecutivo > viConsecutivo2 and consecutivo <= viConsecutivo and  estado = '06' and cve_rechazo = '400';
					IF viNumReg > 2 THEN
						UPDATE bdiprog:"informix".pp_pagoprog  SET cve_estado = '02', user_cancela = pcUsuario, fecha_cancela = CURRENT::DATE, canal_cancela = pcCveCanal
						WHERE cve_pagoprog = vcCveProg;
						UPDATE bdiprog:"informix".pp_pagospend SET     estado = '02', user_cancela = pcUsuario, fecha_cancela = CURRENT::DATE, canal_cancela = pcCveCanal
						WHERE cve_pagoprog = vcCveProg AND  estado = '03';
					END IF;
				END IF;
			ELSE 
					INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
			END IF;
		END IF;
		IF vRechazo = 'S' THEN -- Se dispara alerta por PPG Rechazado
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes			
				
				-- 184- Se agrega envÃ­o de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
				
			END IF;
		END IF;
		COMMIT WORK;
		LET vcAplicaRollback = 'N';
	END FOREACH;
	LET vcAplicarReversionDebito = 'N';
	LET vcMsgError = '';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTransucSPEI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '10';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTarifaSPEI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '13';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcIvaSpei FROM bdinteg:"informix".si_param where cod_param = '47';
	SELECT {+INDEX(bdispei:"informix".tblcomision ix283_1)} mnycomision INTO vmComisionSPEI FROM bdispei:"informix".tblcomision WHERE vchrcvecomision = vcTarifaSPEI;
	LET vcImpIvaSpei = vcIvaSpei * vmComisionSPEI;
	LET vcHHMMSSFolio 	=  vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
	LET vcCuentaInvalida = 'N';
-- Transacciones SPEI:
	FOREACH with hold
		SELECT pagoprog.cve_pagoprog, num_cte, cuenta_origen, cuenta_destino, importe, descripcion, banco_destino, cve_cuenta_ori,  referencia1, importe_iva, referencia2, ref_cobranza, tipo_spei,pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vmMonto ,vcConcepto, vcBancoDest, vcCveCtaOri, vcRef1,  vmImporteIVA, vcRef2, vcRefCob, viTpoSPEI, vcve_pago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('03','07') and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';
		IF NOT vmMonto <= vmMaximo THEN
			LET vcodretTemp  = '99998';
			IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN
				LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vRechazo = 'S'; 
			continue FOREACH;
		END IF;
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '20';
		--Se agrega al select que consulte el tipo de persona.
			SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc, tpo_persona INTO vcNombreCliente, vcRFC, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
				IF vcNombreCliente IS NULL OR vcNombreCliente='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
					SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreCliente FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				END IF;
		LET vcFolioSuc = vcPrefijo  || vcHHMMSSFolio || vcTransucSPEI; 
		SELECT LIMIT 1 nombre, cve_cuenta, rfc	INTO vcNombreBen, vcCveCtaBen, vcRFCBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest and cve_banco = vcBancoDest;
		LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
		LET vcMsgError = 'Error ejecutando el SP: bdispei:sp_regordenctecte.';
		BEGIN WORK;
		LET vcAplicaRollback = 'S';
		LET vcCveCtaOri = '40'; -- 40-CLABE 3- TDD.
		IF vcCveCtaBen = '02' THEN  -- CUENTA DE CHEQUES.
			LET vcCveCtaBen = '40';
			IF LENGTH (vcNoCuentaDest) <> 18 THEN 
				LET vcCuentaInvalida = 'S';
				LET vcCveMensajes = '208';
			END IF;
		END IF;
		IF vcCveCtaBen = '03' THEN  -- TARJETA DE DÃBITO.
			IF LENGTH (vcNoCuentaDest) <> 16 THEN
				LET vcCuentaInvalida = 'S';
				LET vcCveMensajes = '209';
			END IF;
		END IF;
		IF LENGTH(vcNoCuentaOri) <> 11 THEN
			LET vcCuentaInvalida = 'S';
			LET vcCveMensajes = '210';
		END IF;
	    SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)} cvecesif, descripcion INTO vcBancoDest2, vcNomBancoDest FROM bdinteg:"informix".si_bancos WHERE banco = vcBancoDest ;
        IF vcBancoDest2 IS NULL THEN
		LET vcBancoDest2 = 0;
        END IF;
		----RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido y el saldo sbc. OACM 
		--Consulta el saldo de la cuenta Cargo AFORE	 
		SELECT sdo_actual, sdo_cong, sdo_retenido,saldo_sbc,imp_chq_sbg,producto
		INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSbc,mImpChqSbg,vproducto
		FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = vcNoCuentaOri
        AND empresa = '001';

		-- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
		EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
		INTO cCodRet,cMensajeRet,vsdo_cta;

		LET vcDescPago = 'POR SPEI';
		IF vproducto in ("1300", "1400", "1700", "2600","2700") or vcve_pago = '07' THEN
		   LET vmpComisionSPEI = 0;
		   LET vcpImpIvaSpei   = 0;
		else
		   LET vmpComisionSPEI = vmComisionSPEI;
		   LET vcpImpIvaSpei   = vcImpIvaSpei;
		END IF;
        IF vcve_pago = '07' THEN
			LET vcDescPago = 'PORTABILIDAD DE NOMINA';
            --LET vcRef1 = 'PORTABILIDAD NOMINA ' || vcRef1;
            LET vcRef1 = 'PORTABILIDAD DE NOMINA ';
        END IF;
        LET vmto_total = vmMonto + vmpComisionSPEI + vcpImpIvaSpei;
        IF vcCuentaInvalida <> 'S' THEN
           IF vsdo_cta >= vmto_total THEN
                CALL bdispei:"informix".sp_regordenctecte_pp ( '001', vcSucursal, pcUsuario, vcBancoDest2, vmMonto,	vcTransucSPEI, vcFolioSuc, pdFecha, vmpComisionSPEI, vcpImpIvaSpei, vcNombreCliente, vcCveCtaOri, vcNoCuentaOri, vcRFC, vcNombreBen, vcCveCtaBen, vcNoCuentaDest, vcRFCBen, vcRef1, vmImporteIVA, vcRef2, vcRefCob) 
				RETURNING vcodretTemp, vcMensaje, vcCveRastreoSPEI;
                LET vcMensajeSP = vcMensaje;
            ELSE 
				IF vcve_pago = '07' AND vsdo_cta > 0.00 THEN
					LET vmto_total = (vsdo_cta - vmpComisionSPEI - vcpImpIvaSpei) + vmpComisionSPEI + vcpImpIvaSpei ;
					IF vsdo_cta >= vmto_total THEN
					   LET vmMonto = vsdo_cta - vmpComisionSPEI - vcpImpIvaSpei;
						CALL bdispei:"informix".sp_regordenctecte_pp ( '001', vcSucursal, pcUsuario, vcBancoDest2, vmMonto,	vcTransucSPEI, vcFolioSuc, pdFecha, vmpComisionSPEI, vcpImpIvaSpei, vcNombreCliente, vcCveCtaOri, vcNoCuentaOri, vcRFC, vcNombreBen, vcCveCtaBen, vcNoCuentaDest, vcRFCBen, vcRef1, vmImporteIVA, vcRef2, vcRefCob) 
						RETURNING vcodretTemp, vcMensaje, vcCveRastreoSPEI;
						LET vcMensajeSP = vcMensaje;
				    ELSE 
					    LET vcMensajeSP = 'FONDOS INSUFICIENTES';
                        LET vcodretTemp = '400';
				        LET vcMensaje = 'FONDOS INSUFICIENTES';	
					END IF;
				ELSE
                    LET vcMensajeSP = 'FONDOS INSUFICIENTES';
                    LET vcodretTemp = '400';
				    LET vcMensaje = 'FONDOS INSUFICIENTES';				
				END IF;
            END IF;
			IF trim(vcodretTemp) = '000' THEN
				IF viTpoSPEI = 1 THEN
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSuc
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
					IF 	vcve_pago = '03' THEN -- ALERTA AL EMISOR
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
						vcNoCuentaOri, vcNoCuentaDest, vcNomBancoDest, vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSuc, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					END IF;	
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIARIO
						IF vcnotificaben = '02' THEN	
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamaÃ±o variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;									
				ELSE
					LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
					SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '101';
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcCodRet) ) THEN
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcCodRet),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '06', cve_rechazo = trim(vcCodRet)
					WHERE cve_pagoprog = vcCveProg and fecha_prog  = pdFecha;
				END IF;
			ELSE
				-- ERROR CONTROLADO.
				LET vRechazo = 'S'; 
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						select descripcion into vcMensaje from bdinteg:"informix".si_codret where codigo_retorno  = trim(vcodretTemp) and sistema = '21';
						IF vcMensaje IS NULL THEN
							select descripcion into vcMensaje from bdinteg:"informix".si_codret where codigo_retorno  = trim(vcodretTemp) and sistema = '01';
							IF vcMensaje is NULL THEN
								LET vcMensaje = vcMensajeSP;
							END IF;
						END IF;
						LET vcMensaje = vcMensaje;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				ELSE -- ERROR DE INFORMIX
					INSERT INTO bdiprog:"informix".pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
                    		LET vcFlgError='1';
					-- PENDIENTE POSIBLE UNA REVERSION DE CARGO.
				END IF;
			END IF;
		ELSE
			SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, NVL(desc_mensaje,'') INTO vcodretTemp, vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = TRIM(vcCveMensajes);
			LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
			IF (vcodretTemp is null) THEN
				IF vcMensaje is NULL THEN
					LET vcodretTemp  = '000';
					LET vcMensaje = vcMensajeSP;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
				END IF;
			ELSE
				IF vcMensaje IS NULL THEN
					LET vcMensaje = 'ERROR EN LA EJECUCIÃN DEL SP CARGO_REF';
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
				ELSE
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						LET vcMensaje =  vcMensaje;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
				END IF;
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = TRIM(vcodretTemp)
			WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vcCuentaInvalida = 'N';
		END IF;
		IF vRechazo = 'S' THEN 
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMensaje, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF 	vcve_pago = '03'  AND vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;		
				
				-- 184- Se agrega envÃ­o de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
			
			END IF;	
		END IF;
		LET vcAplicaRollback = 'N';
		COMMIT WORK;
	END FOREACH;
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranAbonoCred  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '14';  -- transaccion abono para crÃ©dito.
    SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '05'; -- Transacc Cargo Pago tarjeta de crÃ©dito Bancoppel
	LET vcHHMMSSFolio 	   =   vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
	LET vcHHMMSSFolioAbono =   vcHHMMSSFolio; 

	FOREACH with hold		
		SELECT pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cuenta_destino, pagoprog.descripcion, pagoprog.importe, pagopend.consecutivo, pagoprog.tipo_spei, pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vcConcepto, vmMonto, viConsecutivo,viTipo_spei, vcTipoPago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago = '05' and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';		
-- Pago de Tarjeta de Credito Bancoppel
--	2013.11.01 FRG-I	--	ValidaciÃ³n disponibilidad Sistemas (bdicred):
	if IndCrreCred <> '1'
		then
			LET vcCodRet = '00006';
			LET vcMsgError = 'Sistema CREDITO No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parÃ¡metros con apoyo de MO/JG');
			LET IndsCred = '1';
			continue FOREACH;
		else
			if IndDispCred <> '1'
				then
					LET vcCodRet = '00007';
					LET vcMensaje = 'Sistema CREDITO Temporalmente Fuera de Servicio.';
					LET vcMsgError = vcMensaje;
					INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
					VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parÃ¡metros con apoyo de MO/JG');
					LET IndsCred = '1';
					continue FOREACH;
				else
			end if;
	end if;
--	2013.11.01 FRG-F

		SELECT num_credito, numcte INTO vcNumCredito,vcNoCliente2 FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = vcNoCuentaDest; 
		
		IF viTipo_spei = 2 THEN			
			call bdicred:"informix".sp_consultasaldocortemin('001',vcNumCredito,3)
			RETURNING vcodretTemp, vmMonto;  
			
			IF vcodretTemp <> '00000' THEN
				LET vcMensaje = 'sp_consultasaldocortemin   ' || vcNumCredito;
				LET vcMsgError = vcMensaje;
				INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
				VALUES(vcodretTemp, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));				
			END IF;
			
		ELIF viTipo_spei = 3 THEN
			LET vporce = vmMonto;				
			call bdicred:"informix".sp_consultasaldocorte('001',vcNumCredito,0)
			RETURNING vcodretTemp,vmMonto;
			
			IF vcodretTemp <> '00000' THEN
				LET vcMensaje = 'sp_consultasaldocorte   ' || vcNumCredito;
				LET vcMsgError = vcMensaje;
				INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
				VALUES(vcodretTemp, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));				
			END IF;
			
			LET vmMonto =  vmMonto * (vporce / 100);			 
		END IF;
		
		LET vcDescPago = 'A TARJETA DE CREDITO BANCOPPEL';
		IF  (vmMonto <= 0 or vmMonto is null) THEN
			LET vcodretTemp  = '99997';
			LET vcMsgError = 'El Importe a Pagar  es Igual a Cero';	
			IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99997' ) THEN
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99997'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;							
			continue FOREACH;
		END IF;
		IF NOT vmMonto <= vmMaximo THEN
			LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';		
			LET vcodretTemp  = '99998';
			IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						
			continue FOREACH;
		END IF;
		BEGIN WORK;
		LET vcAplicaRollback = 'S';
		--Se agrega al select que consulte el tipo de persona.
		SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), tpo_persona INTO vcNombreBen, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente2;			
			--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
			IF vcNombreBen IS NULL OR vcNombreBen='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
				SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreBen FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente2;
			END IF;
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
		SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente  AND tipo_tarjeta = 'T' AND status_tar = 'A';
		LET vcFolioSucCargo =  vcPrefijo  || vcHHMMSSFolio || vcTansacc; 
		LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
		LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
		LET vcMsgError = 'Trantando de ralizar cargo en Trans. de CrÃ©dito.';
		CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTansacc, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
								RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
		IF TRIM(vcodretTemp) = '000' THEN
			LET vcAplicarReversionDebito = 'S';
			LET vcMsgError = 'Trantando de ralizar abono en Trans. de CrÃ©dito.';
			SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
			LET vcFolioSuc = vcPrefijo  || vcHHMMSSFolioAbono || vcTranAbonoCred;			--"inform" || replace (substring (current FROM 12  FOR 8 ), ':', '')  || vcTranAbonoCred;
			LET vcHHMMSSFolioAbono = LPAD(vcHHMMSSFolioAbono + 1,9,'0');
			LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
			CALL bdicred:"informix".principal('001', vcNumCredito, 1, vmMonto, pcUsuario, vcSucursal, vcFolioSucCargo, vcTranAbonoCred)
					   RETURNING vcodretTemp, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9; 
			IF trim(vcodretTemp) = '000' THEN
				UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, vcNoTarjeta , '1', 
						vcNoCuentaOri, vcNoCuentaDest, 'BANCOPPEL, S.A.', vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIRARIO
						IF vcnotificaben = '02' THEN
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamaÃ±o variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;				
			ELSE
				-- HACER REVERSA DEL CARGO REALIZADO .
				LET vRechazo = 'S'; 
				call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario, vcFolioSucCargo, 'A') 
				RETURNING vcCodRetReverso;
				-- ERROR CONTROLADO
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
						IF vcMsgError IS NULL THEN
							LET vcMsgError = 'ERROR AL EJECUTAR EL ABONO_CRED';
						END IF;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				ELSE
					INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
				END IF;
			END IF;
		ELSE
			-- ERRROR CONTROLADO DE CARGOREF.
			LET vRechazo = 'S'; 
			IF TRIM(vcodretTemp) > 0 THEN
				IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
					SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
					IF vcMsgError IS NULL THEN
							LET vcMsgError = 'ERROR AL EJECUTAR EL CARGO_REF';
						END IF;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
				END IF;
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
				WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
      		ELSE 
				INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
				VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
			END IF;
		END IF;
		IF vRechazo = 'S' THEN 
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
		-- SE ACTUALIZA EL CAMPO cve_estado (FINALIZADO).
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes		

				-- 184- Se agrega envÃ­o de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
				
			END IF;
		END IF;
		LET vcAplicaRollback = 'N';
		COMMIT WORK;
	END FOREACH;
    LET vCvePago_ant = '';
    LET vcBancoDest_ant = 0;
	LET vcHHMMSSFolio 		=  vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
    LET vcHHMMSSFolioAbono  =  vcHHMMSSFolio; 
    LET vcMsgError = 'EMPIEZA PGO SERVICIO.';
	--Pago de Servicios 
--	2013.11.01 FRG-I
	if IndCrreSrvs <> '1'
		then
			LET vcCodRet = '00003';
			LET vcMensaje = 'Sistema SERVICIOS No Disponible.';
			LET vcMsgError = vcMensaje;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));					
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parÃ¡metros con apoyo de MO/JG');
			RETURN vcCodRet, vcMensaje;
	end if;
--	2013.11.01 FRG-F
	FOREACH with hold
			SELECT pagoprog.cve_pago,pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cve_cuenta_ori, pagoprog.cuenta_destino, pagoprog.descripcion, pagoprog.importe,  pagoprog.banco_destino, pagoprog.referencia1, pagoprog.referencia2, pagoprog.convenio,pagoprog.descripcion, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
			INTO  vCvePago,vcCveProg, vcNoCliente, vcNoCuentaOri, vcCveCtaOri,  vcNoCuentaDest, vcConcepto, vmMonto , vcBancoDest, vcRef1,vcRef2,vcConvenio,vcDescripcion, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
			FROM bdiprog:"informix".pp_pagoprog pagoprog
			INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('04','06') and pagopend.fecha_prog = pdFecha
			order by pagoprog.cve_pago

			LET vmMaximo = '999999999999.99';
			LET vRechazo = 'N';
			IF vcBancoDest = '000' THEN
			LET vcBancoDest ='201';
			END IF;
				LET vcNombreBen='';
				IF  (vCvePago = '04' AND vcBancoDest = '201')  THEN --PAGO DE SERVICIO TELMEX
					LET vcDescPago = 'PAGO DE SERVICIO TELMEX';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '11';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucTelmex FROM bdisac:"informix".sac_param  WHERE empresa='001' AND cod_param = '82011';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '16'; -- Transacc Cargo Pago Servicio Telmex.
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '17';	
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
				ELIF (vCvePago = '04' AND vcBancoDest = '601') THEN--PAGO DE SERVICIO SKY
					LET vcDescPago = 'PAGO DE SERVICIO SKY';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '31';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '34';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucTelmex FROM bdiprog:"informix".pp_parametros WHERE cve_param = '35';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '32'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '33';									
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
				ELIF (vCvePago = '04' AND vcBancoDest = '602') THEN--PAGO DE SERVICIO DISH
					LET vcDescPago = 'PAGO DE SERVICIO DISH';
					SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
					INTO vcCtaDestino,vcTranSucTelmex,vcTansacCargo,vcTansacAbono
					FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '002';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';				
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);					
				ELIF (vCvePago = '04' AND vcBancoDest = '603') THEN--PAGO DE SERVICIO MASTV
					LET vcDescPago = 'PAGO DE SERVICIO MASTV';
					SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
					INTO vcCtaDestino,vcTranSucTelmex,vcTansacCargo,vcTansacAbono
					FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '003';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';								
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);									
				ELIF (vCvePago = '06' ) THEN --PAGO TARJETA CREDITO OTRO BANCO
					LET vcDescPago = 'A TARJETA DE CRED. OTRO BANCO';
					SELECT LIMIT 1 nombre INTO vcNombreBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest;			
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '43';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '44';				
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '42'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '41';
					IF LENGTH(trim(vcNoCuentaDest)) = 15 THEN
						LET vcReferencia = '0' || trim(vcNoCuentaDest);
					ELSE 	
						LET vcReferencia = trim(vcNoCuentaDest);
					END IF;	
				END IF;
				LET  vCvePago_ant =  vCvePago;
				LET  vcBancoDest_ant =  vcBancoDest;					
				SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)} descripcion INTO vcNomBancoDest FROM bdinteg:"informix".si_bancos WHERE banco = vcBancoDest ;
			IF NOT vmMonto <= vmMaximo THEN
				LET vcodretTemp  = '99998';
				IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN
					LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
					INSERT INTO bdiprog:"informix".pp_tprechazo
					VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
				END IF;
				LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				continue FOREACH;
			END IF;
			BEGIN WORK;
			LET vcAplicaRollback = 'S';
			SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente  AND tipo_tarjeta = 'T' AND status_tar = 'A';
			LET vcFolioSucCargo =   vcPrefijo || vcHHMMSSFolio || vcTansacCargo;  
			LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
			LET vcAplicarReversionDebito = 'S';
			CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTansacCargo, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
									RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
			IF trim(vcodretTemp) = '000' THEN
				LET vcNoTarjeta = '';
				LET vcFolioSuc =  'inform' || replace (substring (current FROM 12  FOR 8 ), ':', '')  || vcTansacCargo;
				LET vcFolioSuc =  vcPrefijo  || vcHHMMSSFolioAbono || vcTansacAbono; 
				LET vcHHMMSSFolioAbono = LPAD(vcHHMMSSFolioAbono + 1,9,'0');
				LET vcAplicarReversionDebitoAbono = 'S';
				CALL bdicheq:"informix".abono_ref( '001', vcSucursal, pcUsuario, vcTansacAbono, vcTransuc, vcFolioSucCargo, trim(vcCtaDestino), 0.00, vmMonto, vmMonto, 0.00, 0.00, 0, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
										RETURNING vcodretTemp;
					IF trim(vcodretTemp) = '000' THEN
							-- SE ENVIA ALERTA DE PAGO CORRECTO
							LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));						
									LET vcauxnotifica = '1';
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAE';
									ELSE	
										LET vidmensaje1 = 'PPG_SERE';
									END IF
								CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
								vcNoCuentaOri, vcNoCuentaDest, vcNomBancoDest, vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
								vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
							IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIARIO
								IF vcnotifica = '02' THEN
									LET vcauxnotifica = '2';	
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAS';
									ELSE	
										LET vidmensaje1 = 'PPG_SERS';
									END IF
								ELIF vcnotifica = '01' OR vcnotifica = '03' THEN
									LET vcauxnotifica = '1';
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAE';
									ELSE	
										LET vidmensaje1 = 'PPG_SERE';
									END IF
								END IF;
							END IF;				
						LET vcCategoria = SUBSTR(vcConvenio,1,2);
						SELECT flgporccomtrans_conv,  porc_com_trans_conv,   flgimpcomtrans_conv,   imp_com_trans_conv , iva_convenio,    flgporccomtrans_cte,   porc_com_trans_cte,   flgimpcomtrans_cte,   imp_com_trans_cte
						INTO  vcFlgporccomtrans_conv,vdPorc_com_trans_conv, vcFlgimpcomtrans_conv, vdImp_com_trans_conv , viIvaConvenio, vcFlgporccomtrans_cte, vmPorc_com_trans_cte, vcFlgimpcomtrans_cte, vmImp_com_trans_cte
						FROM bdisac:"informix".sac_convenios
						WHERE numcategoria = substr(vcConvenio,1,2) and numconvenio = substr(vcConvenio,3,5);
						LET vcConvenio = SUBSTR(vcConvenio,3,3);
						IF vcFlgporccomtrans_conv = '1' and vcFlgimpcomtrans_conv = '0' THEN
							LET deImpComisionConvenio =  ((vdPorc_com_trans_conv * vmMonto) / 100);
							LET deIvaComisionConvenio =  ((deImpComisionConvenio * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_conv = '1' and vcFlgporccomtrans_conv = '0' THEN
							LET deImpComisionConvenio = vdImp_com_trans_conv;
							LET deIvaComisionConvenio = (( deImpComisionConvenio * viIvaConvenio) / 100 );
						ELIF vcFlgporccomtrans_conv = '0' and vcFlgimpcomtrans_conv = '0' THEN
							LET deImpComisionConvenio = 0.00;
							LET deIvaComisionConvenio = 0.00;
						ELIF vcFlgporccomtrans_conv = '1' and vcFlgimpcomtrans_conv = '1' THEN 
						END IF;
						IF vcFlgporccomtrans_cte = '1' and vcFlgimpcomtrans_cte = '0' THEN
						LET deImpComisionCliente = (( vmPorc_com_trans_cte * vmMonto) / 100 );
						LET deIvaComisionCliente  = ((deImpComisionCliente * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_cte = '1' and vcFlgporccomtrans_cte = '0' THEN
						LET deImpComisionCliente = vmImp_com_trans_cte;
						LET deIvaComisionCliente  = ((deImpComisionCliente * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_cte = '0' and vcFlgporccomtrans_cte = '0' THEN
						LET deImpComisionCliente = 0.00;
						LET deIvaComisionCliente  = 0.00;
						ELIF vcFlgimpcomtrans_cte = '1' and vcFlgporccomtrans_cte = '1' THEN 
						END IF;
						IF vCvePago = '04' THEN
							CALL bdisac:"informix".sp_GrabaPagoServicio (vcSucursal, vcCategoria, vcConvenio, vcRef1, vcRef2, '2', vmMonto, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, vcNoCuentaOri, pcUsuario, vcFolioSucCargo, vcTranSucTelmex, pdFecha)
															RETURNING vcodretTemp;
							IF vcodretTemp = '00000' THEN
								UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo
								WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
							ELSE
								-- APLICAR REVERSION DE CARGO Y ABONO. 
								LET vRechazo = 'S'; 
								call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
								IF trim(vcodretTemp) > 0 THEN
									LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
									IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
										LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
										INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
									END IF;
									UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
									WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
								END IF;
							END IF;
						ELSE
							UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo
							WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
						END IF 
					ELSE -- else abono_ref
						LET vRechazo = 'S'; 
						call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
						IF trim(vcodretTemp) > 0 THEN
							IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
								SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
								IF vcMsgError IS NULL THEN
									LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
								END IF;
								INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
							END IF;
							UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
							WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
						END IF;
					END IF;
			ELSE
				LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
						IF vcMsgError IS NULL THEN
							LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
						END IF;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg AND fecha_prog = pdFecha;
				END IF;
			END IF;
			IF vRechazo = 'S' THEN -- Se dispara alerta por PPG Rechazado
				LET vidmensaje1 = 'PPG_RECHE';
				LET vcauxnotifica = '1';		
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
					vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
					vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
			END IF;
			IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg AND estado = '03' ) THEN
			-- SE ACTUALIZA EL CAMPO cve_estado (FINALIZADO). 			--  NOTIFICACION DE CONCLUSION DE PROGRAMACION, EMAIL .... 
				UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg AND cve_estado <> '02';
				IF vCvePago = '06'  AND vccve_programa <> '04' THEN
					LET vidmensaje1 = 'PPG_FINE';
					LET vcauxnotifica = '1';
					CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
					vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
					vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes		

					-- 153 - Se agrega envÃ­o de notificacion SMS al telefono celular del cliente.	
					SELECT NVL(TRIM(emi_celular), '')
					INTO vcemicel
					FROM bdiprog:"informix".pp_pagoprog
					WHERE cve_pagoprog = vcCveProg;
					
					IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
						
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
						(
							'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
							'', '1', '', '', '', 
							'', '', '', '', '', 
							'', '', '', vcemicel, vmMonto, 
							0.00, 0.00, 0.00, 0.00, CURRENT, 
							''
						)INTO vcodretTemp;
						
					END IF;
				
				END IF;	
			END IF;
			LET vcAplicaRollback = 'N';
			COMMIT WORK;
		END FOREACH;
    -- SI NO EXISTIERON ERRORES NO CONTROLADOS EN SPEI, TERMINA EL PROCESO CORRECTAMENTE.
    IF vcFlgError='0' THEN
--	2013.11.06 - FRG - i
--		IF vcStatus IS NULL THEN
		IF vcStatus IS NULL or vcStatus = '0' THEN
			IF flg_indicadores = '1'
				THEN
					UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '1' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
				ELSE
					IF vcStatus = '1' and flg_indicadores = '1' 
						THEN
							UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '2' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
						ELSE
							let vcCodRet = '99996';
							let vcMensaje = 'Sistema pendiente de cierre o temporalmente fuera de servicio. Validar.';
					END IF;	
			END IF;
--	2013.11.06 - FRG - f
		END IF;
	END IF;
	IF vtransaccion = 1 THEN
	   BEGIN WORK;
	END IF;
    IF vcFlgError='0' 
		THEN
			IF IndsCred <> '0' 
				THEN
					let vcCodRet = '99995';
					let vcMensaje = 'Sist. CREDITO Pend. Cierre o Temp. Fuera de Servicio.';
					RETURN vcCodRet,vcMensaje;
				ELSE
					SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '00';
					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PP_ET', pdFecha, '1', 'informix', 'sp_ejecutartransacciones', cDescripcionSPJ);
					RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
		RETURN '99999','ERROR EN LOS PAGOS PROGRAMADOS POR SPEI';
    END IF;
END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 153 - Validacion_CorreoTel_PagosProg',
'DESCRIPCION: Se modifica rango de campos relativos al e-mail tanto del emisor como del receptor ampliando su rango a 100 caracteres (parÃ¡metro vcbenemail), se agrega consulta para obtener el correo alterno (parametro obligatorio al llamar al sp_registra_evento,',
'se agrega invocacion al procedimiento bdimnsj:"informix".sp_registra_evento',
'FECHA: 22/11/2016',
'BD: bdiprog',
'AUTOR: 90314234 - Osiel Alfredo Camacho Mendoza',
'FOLIO: RQM 09 704 cobranza automatica',
'DESCRIPCION: Se agrega en el saldo actual el saldo sbc, por medio del sp de consulta saldo x tipo de formula',
'FECHA: 02/07/2025',
'BD: bdiprog';

CREATE PROCEDURE "informix".sp_afore_dispersion(pNombreArchivo CHAR(30),pUsuario CHAR(8), pTipoarch CHAR(1))
Returning CHAR(5),CHAR(50);

--Definicion de variables.
DEFINE vsqlerr						INTEGER;
DEFINE iExiste						INTEGER;
DEFINE iAceptab						INTEGER;
DEFINE iForma_pago 					INTEGER;
DEFINE iContadorTransacciones		INTEGER;
DEFINE iRowID						INTEGER;
DEFINE dFechaActual					DATE;
DEFINE vfechoy						DATE;
DEFINE cHoraActual					DATETIME HOUR TO SECOND;
DEFINE dePorcIVA 					DECIMAL (18,2);
DEFINE cBanderaArchivo				CHAR(1);
DEFINE cStatusCtaCargoAbono			CHAR(1);
DEFINE cConsulta					CHAR(1);
DEFINE cStatus						CHAR(2);
DEFINE cMotivo						CHAR(2);
DEFINE cStatusProceso				CHAR(2);
DEFINE cSucursalCargo				CHAR(4);
DEFINE cSucursalAbono				CHAR(4);
DEFINE cSucursalContable			CHAR(4);
DEFINE cTransaccAbono				CHAR(4);
DEFINE cTransaccCargo				CHAR(4);
DEFINE vtranret						CHAR(4);
DEFINE vcodret 						CHAR(5);
DEFINE vcodret1						CHAR(5);
DEFINE cFechaFormat					CHAR(8);
DEFINE cRFCrecibido					CHAR(10);
DEFINE cRFCorigen					CHAR(10);
DEFINE cRFCorigen_alterno           CHAR(10);
DEFINE cNomProceso					CHAR(12);
DEFINE cProceso						CHAR(10);
DEFINE cNumeroFolioCargo			CHAR(16);
DEFINE cNumeroFolioAbono			CHAR(16);
DEFINE cClaBe						CHAR(18);
DEFINE cNum_Cte						CHAR(20);
DEFINE cCuentaAbono					CHAR(20);
DEFINE cCuentaCargo					CHAR(20);
DEFINE cNombre_arch 				CHAR(30);  --DSB 13/03/2014
DEFINE cMensaje						CHAR(50);
DEFINE mSaldoCtaCargo				MONEY(18,2);
DEFINE mImporteAPagar				MONEY(18,2);
DEFINE mSaldoAPagar					MONEY(18,2);
DEFINE vsdodisp						MONEY(18,2);
DEFINE vmontoret					MONEY(18,2);
--DEFINE mComisionAbono				MONEY(18,2);
DEFINE mComisionCargo				MONEY(18,2);
DEFINE mIVAUnitario					MONEY(18,2);
DEFINE cpUsuario					CHAR(8);


--Variables proceso de pagos
DEFINE cIdentificadorProceso		CHAR(10);  --DSB 13/03/2014
DEFINE cProcesoDes					CHAR(10);
DEFINE cTipoExtArchivo				CHAR(13);
DEFINE dFechaCaptura				DATE;
DEFINE cNumTienda					CHAR(4);
DEFINE cFolioSuc					CHAR(16);
DEFINE cNom_benef					CHAR(40);
DEFINE cClavecesif					INTEGER;
DEFINE mImp_netopagar				MONEY(14,2);
DEFINE cRfc							VARCHAR(18);
DEFINE cClabeBenef					VARCHAR(20);
DEFINE cRazon_social				VARCHAR(40);
DEFINE cRfcOrd						VARCHAR(18);
DEFINE cVeRastreo					CHAR(30);
DEFINE vcBancoDest    				INTEGER;
DEFINE vcNomBancoDest	 			CHAR(40);
--DEFINE vcHHMMSSFolio				CHAR(9);
--DEFINE vcFechaFolio					CHAR(6);
--DEFINE vcPrefijo					CHAR(3);
--DEFINE vcSufijo				    	CHAR(3);
--DEFINE vcTransucSPEI  				CHAR(4);
--DEFINE dDiaActual					DATETIME YEAR TO SECOND;
Define cHora                        CHAR(2);
Define cMinutos                     CHAR(2);
Define cSegundos                    CHAR(2);
DEFINE iContadorFolioSuc			INTEGER;
Define cNumeroFormateado            CHAR(4);

Define cHoraDispercion              DateTime Hour To Second ;
Define cHoraDispercionFormateada    CHAR(4) ;
DEFINE vtransacc					INTEGER;
DEFINE iContadorAbono				INTEGER;
DEFINE iContadorCargo				INTEGER;
DEFINE vcSucursalSPEI		 		CHAR(4);
DEFINE cMensajeOB    		 		CHAR(50);
DEFINE cMensajeBC    		 		CHAR(50);

-- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
DEFINE mSdoActual                   MONEY(14,2);DEFINE mSdoRetenido                 MONEY(14,2);DEFINE mSdoCong                     MONEY(14,2);DEFINE mSaldoSbc                    MONEY(14,2);
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let vcodret = vsqlerr;
			ROLLBACK WORK;
			IF cNombre_arch <> "" OR NOT cNombre_arch IS NULL THEN
			  UPDATE bdiprog: "informix".pp_detalle {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c ) } SET status = '08',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			  WHERE nombre_arch = cNombre_arch;
		      UPDATE bdiprog: "informix".pp_arch_afore {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12  ) }SET status = '08',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
			END IF 
			LET cMensaje = 'Ocurrio un error no controlado';
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
            Return vcodret,cMensaje;
        END IF;
    END EXCEPTION;
	
	on exception in (-535)
	  let vtransacc = 1;
	end exception with resume;

    --SET DEBUG FILE TO "/home/sysafore/respaldos/sp_Afore_Dispersion.out";
    --TRACE ON;	 
	
    --Inicializacion de variables
    LET vcodret = '00000';
	LET vcodret1 = '00000';
	LET cMensaje = 'Aplicado exitosamente';
    LET dFechaActual = '';
    LET cNombre_arch = '';
    LET cStatus = '';
    LET cCuentaCargo = '';
	LET cRFCrecibido = '';
    LET cClaBe = '';
    LET cNum_Cte = '';
    LET cRFCorigen = '';
    LET cRFCorigen_alterno = '';
	LET cBanderaArchivo = '';
	LET cCuentaAbono = '';
	LET cCuentaCargo = '';
	LET cSucursalCargo = '';
	LET cSucursalAbono = '';
	LET cSucursalContable = '';
	LET cStatusCtaCargoAbono = '';
	LET cConsulta = '';
	LET cMotivo = '';
	LET cTransaccCargo = '';
	LET cTransaccAbono = '';
	LET cNomProceso = '';
	LET cFechaFormat = '';
	LET vtranret = '';
	LET vfechoy	= '';
	LET cStatusProceso = '';
	LET cNumeroFolioCargo = '';
	LET cNumeroFolioAbono = '';
	LET cProceso = '';
	LET iForma_pago = 0;
	LET vsdodisp = 0.00;
	LET vmontoret = 0.00;
	LET mSaldoCtaCargo = 0.00;
    LET mImporteAPagar = 0.00;
    LET mSaldoAPagar = 0.00;
	LET iAceptab = 0;
	LET iExiste = 0;
	LET iContadorTransacciones = 0;
	--LET mComisionAbono = 0.00;
	LET mComisionCargo = 0.00;
	LET dePorcIVA = 0.00;
	LET mIVAUnitario = 0.00;
	LET cHoraActual = CURRENT HOUR TO SECOND;
	LET cpUsuario = 'sysafore';
	
	LET cIdentificadorProceso = '';   --DSB 13/03/2014
	LET cProcesoDes  = '';
	LET cTipoExtArchivo = '';
	LET dFechaCaptura = '';
	LET cNumTienda = '';
	LET cFolioSuc = '';
	LET cNom_benef = '';
	LET cClavecesif = 0;
	LET mImp_netopagar = 0.00;
	LET cRfc ='';
	LET cClabeBenef ='';
	LET cRazon_social ='';
	LET cRfcOrd ='';
	LET cVeRastreo ='';
	Let cHora = '';
    Let cMinutos = '';
    Let cSegundos = '';
	let iContadorFolioSuc = 0;
	Let cNumeroFormateado = '';
	
	Let cHoraDispercion = '';
    Let cHoraDispercionFormateada = '';
	LET vtransacc = 0;
	Let iContadorAbono = 0;
	Let iContadorCargo = 0;
	LET vcSucursalSPEI = '';
	LET cMensajeOB = '';
	LET cMensajeBC = '';

	-- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
	LET cCodRetConsSdo      = '00000';
	LET cMensajeRetConsSdo  = '';
	LET mSdoActual		=0.00;	
	LET mSdoRetenido	=0.00;
	LET mSdoCong		=0.00;
	LET mSaldoSbc   	=0.00;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;	

	
BEGIN WORK;

    --Se indica que se esta mandando llamar el proceso automatico.
    IF pNombreArchivo = '' OR pNombreArchivo IS NULL THEN
        LET cBanderaArchivo = 'A';
    ELIF pNombreArchivo <> '' OR NOT pNombreArchivo IS NULL THEN
        LET cBanderaArchivo = 'M';
    END IF;
	
	--Se valida el usuario que activo el proceso si no asigna a informix automatico
	IF pUsuario = "" OR pUsuario IS NULL THEN
		LET pUsuario = 'informix';
	END IF
	
	--consulta la fecha actual del sistema de integral	
    SELECT {+  INDEX(bdicheq: "informix".sc_fechas idx_fechas1) } fecha_hoy INTO dFechaActual FROM bdicheq: "informix".sc_fechas;

	LET cpUsuario = substr (cpUsuario,1,6) || LPAD(DAY(dFechaActual),2,0);	LET cFechaFormat = LPAD(DAY(dFechaActual),2,0) || LPAD(MONTH(dFechaActual),2,0) || YEAR(dFechaActual) ;
	
	IF pTipoarch = 1 THEN   --DSB 13/03/2014 
		LET cProcesoDes = 'AforeVal';
		LET cIdentificadorProceso = 'AforeEPP';
		LET cTipoExtArchivo = '.ACOPPEL.01';
	ELIF pTipoarch = 2 THEN
		LET cProcesoDes = 'AfoValOB';
		LET cIdentificadorProceso = 'AfoEPPOB';
		LET cTipoExtArchivo = '.OBACOPPEL.01';
	ELIF NVL(pTipoarch,'') = '' OR pTipoarch NOT IN (1,2) THEN
		LET vcodret = '10035';
		CALL "informix".sp_Afore_MensajeRetorno (vcodret) RETURNING vCodRet1,cMensaje;
		INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		COMMIT WORK;
		Return vcodret,cMensaje;
	END IF;
	
    --Consulta que el archivo exista para el proceso Automatico y que su estatus sea 01.
    IF cBanderaArchivo = 'A' THEN
				
        SELECT {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } nombre_arch,status INTO cNombre_arch,cStatus FROM bdiprog: "informix".pp_arch_afore
        WHERE SUBSTR(nombre_arch,6,8) = cFechaFormat
		AND SUBSTR(nombre_arch,23,2) = '01' AND tipo = 'P';
		
		LET cNombre_arch = 'PAGOS'|| TRIM(cFechaFormat) || TRIM(cTipoExtArchivo); --DSB 13/03/2014 
		  
		IF pTipoarch = '1' THEN  --DSB 13/03/2014
			LET cNomProceso = TRIM(cIdentificadorProceso) || NVL(SUBSTR(cNombre_arch,23,2),"01");
		ELIF pTipoarch = '2' THEN
			LET cNomProceso = TRIM(cIdentificadorProceso) || NVL(SUBSTR(cNombre_arch,25,2),"01");
		END IF;
		  
		  SELECT status INTO cStatusProceso FROM bdiprog: "informix".pp_procesos WHERE proceso = cNomProceso AND fech_proceso = dFechaActual; 
		    IF cStatusProceso IS NULL OR cStatusProceso = '' THEN
		        INSERT INTO bdiprog: "informix".pp_procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
		        VALUES (cNomProceso,dFechaActual,1,pUsuario,dFechaActual);
		    END IF 
			IF cStatusProceso = 2 THEN
				LET vcodret = '10011';
		        --LET cMensaje = 'El Archivo ya fue procesado';
				CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
				INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
				COMMIT WORK;
			    Return vcodret,cMensaje;
		    END IF;
    END IF

    --Consulta que el archivo exista para el proceso Manual.
    IF cBanderaArchivo = 'M' THEN
        SELECT nombre_arch,status INTO cNombre_arch,cStatus FROM bdiprog: "informix".pp_arch_afore
        WHERE nombre_arch = pNombreArchivo AND tipo = 'P';
		
		LET cNombre_arch = pNombreArchivo;
		
		IF pTipoarch = '1' THEN  --DSB 13/03/2014 
			LET cNomProceso = TRIM(cIdentificadorProceso) || SUBSTR(cNombre_arch,23,2);
			LET cProceso = TRIM(cProcesoDes) || SUBSTR(pNombreArchivo,23,2);
		ELIF pTipoarch = '2' THEN
			LET cNomProceso = TRIM(cIdentificadorProceso) || SUBSTR(cNombre_arch,25,2);
			LET cProceso = TRIM(cProcesoDes) || SUBSTR(pNombreArchivo,25,2);
		END IF;
		
		  IF NOT cStatus IN ('01','09') OR cStatus IS NULL THEN
			LET vcodret = '10013';
			--LET cMensaje = 'No existen archivos por procesar';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		  END IF 
		  LET cStatusProceso = '';
		  --LET cProceso = 'AforeVal'|| SUBSTR(pNombreArchivo,23,2);
		  
		SELECT status INTO cStatusProceso FROM bdiprog: "informix".pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFechaActual;
		  
		IF cStatusProceso <> '2' THEN
			--- mensaje de error ya que se devio haber Ejecutado el proceso de Recepcion de archivo
				LET vCodRet = '10024';
				--LET cMensaje = 'Falta ejecutar el proceso anterior';
				CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
				INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);		
				COMMIT WORK;
				Return vcodret,cMensaje;
		END IF;
		
    END IF
	
	

    --Valida que se obtenga un nombre de archivo para procesar.
    IF cNombre_arch = '' OR cNombre_arch IS NULL THEN
        LET vcodret = '10013';
		--LET cMensaje = 'No existen archivos por procesar';
		CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		COMMIT WORK;
        Return vcodret,cMensaje;
    END IF;
	
	IF NOT EXISTS (SELECT proceso FROM bdiprog: "informix".pp_Procesos WHERE pp_Procesos.proceso = TRIM(cProceso)
	AND pp_Procesos.fech_proceso = dFechaActual AND  pp_Procesos.status = '2') THEN  --DSB 13/03/2014
	
		LET vcodret = '10024';
		--LET cMensaje = 'Error ya que no se Ejecuto el proceso Anterior';
		CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		Return vcodret,cMensaje;
	ELSE
		LET cStatusProceso = '';
		
	    --Checa en la tabla de control de procesos si el proceso se ejecuto el dÃÂ­a de hoy en el sistema.
		SELECT status INTO cStatusProceso FROM bdiprog: "informix".pp_procesos WHERE proceso = cNomProceso AND fech_proceso = dFechaActual; 

	    IF cStatusProceso IS NULL OR cStatusProceso = '' THEN
	        INSERT INTO bdiprog: "informix".pp_procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
	        VALUES (cNomProceso,dFechaActual,1,pUsuario,dFechaActual);
	    END IF 

		IF cStatusProceso = 2 THEN
			LET vcodret = '10011';
	        --LET cMensaje = 'El Archivo ya fue procesado';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
		    Return vcodret,cMensaje;
	    END IF;
	END IF;
	
	--Se comprueba que exista el usuario que manda llamar el proceso.
	SELECT 1 INTO iExiste FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = pUsuario;
	
	  IF NOT iExiste = 1 or iExiste IS NULL THEN
	    LET vcodret = '10014';
	    --LET cMensaje = 'Usuario no valido';	
		CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		---COMMIT WORK;
	    --Return vcodret,cMensaje;
	  END IF 
	  
	   --Extrahe la cuenta a la que se le va a realizar el cargo.
	   SELECT desc_valor INTO cCuentaCargo FROM bdiprog: "informix".pp_parametros WHERE cve_param = '101';
	   SELECT valor INTO cTransaccAbono FROM bdiprog: "informix".pp_parametros WHERE cve_param = '102';
	   SELECT valor INTO cTransaccCargo FROM bdiprog: "informix".pp_parametros WHERE cve_param = '103';
	   SELECT valor INTO cSucursalContable FROM bdiprog: "informix".pp_parametros WHERE cve_param = '106';
	   
	    IF cSucursalContable IS NULL OR cSucursalContable = '' THEN
			LET vcodret = '10015';
			--LET cMensaje = 'Faltan parametros';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;			
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
	   END IF
	   
	     IF cCuentaCargo = "" OR cCuentaCargo IS NULL THEN
			LET vcodret = '10015';
			--LET cMensaje = 'Faltan parametros';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		 END IF 
		 
		 SELECT COUNT(numero) INTO iContadorTransacciones FROM bdinteg: "informix".si_transacc WHERE numero IN (cTransaccAbono,cTransaccCargo);
		 
		 IF NOT iContadorTransacciones = 2 THEN
			LET vcodret = '10016';
            --LET cMensaje = 'Error en Transacciones';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
	        Return vcodret,cMensaje;
		 END IF
		 
		 --Extrahe el costo unitario de la comision.
		 SELECT monto_fijo INTO mComisionCargo FROM bdinteg:si_transacc WHERE numero = cTransaccCargo;

		 --Extrahe el valor del IVA.
  		 SELECT valor INTO dePorcIVA FROM bdinteg: "informix".si_param WHERE cod_param = 47;
		 
		 IF mComisionCargo IS NULL OR mComisionCargo IS NULL THEN 
			LET vcodret = '10017';
			--LET cMensaje = 'IVA o Comision nulos';
			CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		 ELSE 
		 	--Calculo de IVA por transaccion.
			LET mIVAUnitario = mComisionCargo * dePorcIVA;
			
		 END IF
		
	   --Consulta el saldo en el maestro de cheques de la cuenta cargo.
	   -- SELECT sucursal,sdo_actual - (sdo_cong + sdo_retenido),status_cta,motivo 
	     -- INTO cSucursalCargo,mSaldoCtaCargo,cStatusCtaCargoAbono,cMotivo
	    SELECT sucursal,sdo_actual,sdo_retenido,sdo_cong,saldo_sbc,status_cta,motivo 
	    	INTO cSucursalCargo,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,cStatusCtaCargoAbono,cMotivo 
	    FROM bdicheq: "informix".sc_maechq 
	   WHERE empresa = '001' 
	     AND cuenta = cCuentaCargo;

	    -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
	   	EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', '2') INTO cCodRetConsSdo,cMensajeRetConsSdo, mSaldoCtaCargo;

		 
	     IF cStatusCtaCargoAbono = 2 THEN
		   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c ) } bdiprog: "informix".pp_detalle SET status = '06',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
		   WHERE nombre_arch = cNombre_arch ;
		   UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '06',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		   LET vcodret = '10018';
		   --LET cMensaje = 'Cuenta AFORE cancelada';
		   CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;		   
		   INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		   COMMIT WORK;
		   Return vcodret,cMensaje;
		 END IF 
		 
		 IF cStatusCtaCargoAbono = 3 THEN
		   SELECT "1" INTO iExiste FROM bdicheq: "informix".sc_ctabloqueo WHERE cuenta = cCuentaCargo;
			IF iExiste = "1" THEN
			  SET ISOLATION TO DIRTY READ;
			  SELECT opcion INTO iAceptab FROM bdicheq: "informix".sc_ctabloqueo WHERE cuenta = cCuentaCargo;
				IF iAceptab = 4 THEN
					Let vcodret = "10019";
				END IF;
				IF iAceptab = 3 THEN
					Let vcodret = "10019";
				END IF;
			ELSE
				-- Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no cargos
				SELECT cargo INTO cConsulta FROM bdicheq: "informix".sc_bloqueo WHERE codigo = cMotivo;
				  IF cConsulta = 'N' THEN
					Let vcodret = "10019";
				  END IF
			END IF
			
			IF vcodret <> 0 THEN 
			   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c ) } bdiprog: "informix".pp_detalle SET status = '05',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			   WHERE nombre_arch = cNombre_arch ;
			   UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '05',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
			   LET vcodret = '10019';
			   --LET cMensaje = 'Cuenta AFORE bloqueada';
			   CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;			   
			   INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			   COMMIT WORK;
		       Return vcodret,cMensaje;
		    END IF 
		 END IF 
		 
 IF vcodret = 0 THEN
	--Valida si existen movimientos para pagar.
	
	IF NOT EXISTS (SELECT * FROM bdiprog: "informix".pp_detalle WHERE nombre_arch = cNombre_arch and status='01') THEN
		  UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		  LET vcodret = '10020';
		  --LET cMensaje = 'No existen movimientos por aplicar';
		  CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		  INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		  VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		  COMMIT WORK;
		  Return vcodret,cMensaje;
	ELSE
	   --Consulta el monto total a pagar.
	   SELECT {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c) } SUM(imp_netopagar) INTO mImporteAPagar FROM bdiprog: "informix".pp_detalle WHERE nombre_arch = cNombre_arch and status='01';

		--Valida si el monto a pagar es mayor al saldo de la cuenta cargo.
		IF mImporteAPagar > mSaldoCtaCargo THEN
		   --Se actualizan los datos de los movimientos y del archivo, mencionando que no hay suficiente saldo para realizar los pagos.
		   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c) } bdiprog: "informix".pp_detalle SET status = '03',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
		   WHERE nombre_arch = cNombre_arch and status='01';
		   UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '03',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		   LET vcodret = '10021';
		   --LET cMensaje = 'Fondos insuficientes en la cuenta AFORE';
		   CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		   INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		   
		   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle120) } bdiprog: "informix".pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
			WHERE nombre_arch = cNombre_arch AND status <> '01';
		   COMMIT WORK;
		   Return vcodret,cMensaje;
		END IF
		
		LET cStatusCtaCargoAbono = '';
		LET cMotivo = '';
 
		IF pTipoarch = 1  THEN 
			FOREACH WITH HOLD
				--Se consulta el monto y se extrahe el RFC del cliente.
				SELECT {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle120) } consecutivo,forma_pago,clabe,imp_netopagar,rfc INTO iRowID,iForma_pago,cClaBe,mSaldoAPagar,cRFCrecibido 
				FROM pp_detalle WHERE nombre_arch = cNombre_arch AND status = '01' ORDER BY consecutivo
				
				LET cCuentaAbono = SUBSTR(cClaBe,7,11); 
				SELECT num_cte,sucursal,status_cta,motivo INTO cNum_Cte,cSucursalAbono,cStatusCtaCargoAbono,cMotivo 
				FROM bdicheq: "informix".sc_maechq WHERE empresa = '001' AND cuenta = cCuentaAbono;	
				
				IF cCuentaAbono = '' OR cCuentaAbono IS NULL OR cNum_Cte = '' OR cNum_Cte IS NULL OR cStatusCtaCargoAbono IS NULL THEN
					UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '04',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
					LET cMensaje = 'Al menos alguna cuenta no existe';
					CONTINUE FOREACH;
				END IF
				
				IF mSaldoAPagar <= 0.00 THEN
					UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
					LET cMensaje = 'Al menos alguna cuenta su abono es de cero o menor';
					CONTINUE FOREACH;
				END IF; 
				
				--Filtro de forma de pago
				IF iForma_pago <> 3 THEN
					UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
					LET cMensaje = 'Al menos alguna tiene un tipo de pago diferente';
					CONTINUE FOREACH;
				END IF 
				--valida si la cuenta esta cancelada.
				 IF cStatusCtaCargoAbono = 2 THEN
				   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '06',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
				   WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
				   LET vcodret1 = '10032';
				   -- Aplicado parcailmente   
				   --LET cMensaje = 'Al menos una cuenta cliente AFORE cancelada';
				   CALL "informix".sp_Afore_MensajeRetorno (vCodRet1) RETURNING vCodRet,cMensaje;
				   --INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				   --VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
				   CONTINUE FOREACH;
				 END IF 
				 
				 --valida si la cuenta esta bloqueada y su tipo de bloqueo
				 IF cStatusCtaCargoAbono = 3 THEN
				   SELECT "1" INTO iExiste FROM bdicheq: "informix".sc_ctabloqueo WHERE cuenta = cCuentaAbono;
					IF iExiste = "1" THEN
					  SET ISOLATION TO DIRTY READ;
					  SELECT opcion INTO iAceptab FROM bdicheq: "informix".sc_ctabloqueo WHERE cuenta = cCuentaAbono;
						IF iAceptab = 4 THEN
							LET vcodret1 = '10032';
						END IF;
						IF iAceptab = 2 THEN
							LET vcodret1 = '10032';
						END IF;
					ELSE
						-- Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no abonos
						SELECT cargo INTO cConsulta FROM bdicheq: "informix".sc_bloqueo WHERE codigo=cMotivo;
						  IF cConsulta = 'N' THEN
							LET vcodret1 = '10032';
						  END IF
					END IF
					IF vcodret1 <> 0 THEN 
					   UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '05',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					   WHERE nombre_arch = cNombre_arch 
						AND clabe = cClaBe 
						AND imp_netopagar = mSaldoAPagar 
						AND rfc = cRFCrecibido
						AND consecutivo = iRowID;
					   LET vcodret1 = '10032';
					   -- Aplicado parcailmente   
					   --LET cMensaje = 'Al menos una cuenta cliente AFORE bloqueada'; 
					   CALL "informix".sp_Afore_MensajeRetorno (vCodRet1) RETURNING vCodRet,cMensaje;
					   CONTINUE FOREACH;
					END IF
				 END IF 
				 
				SELECT rfc, rfc_alterno INTO cRFCorigen, cRFCorigen_alterno  FROM bdinteg: "informix".si_cliente WHERE numcte = cNum_Cte;
				IF TRIM(cRFCorigen_alterno) = '' OR cRFCorigen_alterno IS NULL THEN
					LET cRFCorigen_alterno = cRFCorigen;
				ELSE    
					LET cRFCorigen = cRFCorigen_alterno;
				END IF;  
				IF cRFCorigen <> cRFCrecibido THEN
					UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '07',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
					LET cMensaje = 'RFC Incorrecto';
					 UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19c) } bdiprog: "informix".pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
					 WHERE nombre_arch = cNombre_arch AND status <> '01';
					CONTINUE FOREACH;
				  END IF;
				LET cNumeroFolioCargo = '';
				LET cNumeroFolioAbono = '';
				
					
				--Genera el folio del cargo a la cuenta cargo.
				--CALL bdicheq:"informix".sp_generafolionominapagos(cpUsuario)Returning vcodret,cNumeroFolioCargo;
				--Genera el folio del cargo a la cuenta cargo.					
				--Se obtiene la hora actual
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND
				INTO cHoraDispercion
				FROM sysmaster:"informix".sysshmvals; 				
				
					LET iContadorCargo = iContadorCargo + 1;
					Let cHora = Substr(cHoraDispercion, 1, 2);
					Let cMinutos = Substr(cHoraDispercion, 4, 2);					
					Let cHoraDispercionFormateada = cHora || cMinutos;
					
					IF iContadorCargo In (1,2,3,4,5,6,7,8,9) THEN
						Let cNumeroFormateado = '000' || iContadorCargo;
						LET cNumeroFolioCargo = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
					ELSE
						IF LENGTH(TRIM(iContadorCargo::CHAR(4))) = 2 THEN 
							Let cNumeroFormateado = '00' || iContadorCargo;
							LET cNumeroFolioCargo = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
						ELIF LENGTH(TRIM(iContadorCargo::CHAR(4))) = 3 THEN 
							Let cNumeroFormateado = '0' || iContadorCargo;
							LET cNumeroFolioCargo = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
						ELSE
							LET cNumeroFolioCargo = cpUsuario || cHoraDispercionFormateada || iContadorCargo;
						END IF;					
							
						
					END IF;
					
					IF iContadorCargo = 9999 THEN
						LET iContadorCargo = 0;
					END IF;
				
				LET cSucursalCargo = cSucursalContable;
				--LLamado a realizar el cargo a la cuenta AFORE.	
				CALL bdicheq: "informix".cargo_ref ("001", cSucursalCargo, pUsuario, cTransaccCargo, "0000", cNumeroFolioCargo, cCuentaCargo, 0, mSaldoAPagar,"01",cCuentaAbono, '', pUsuario) Returning vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
								
				  --LLamado a realizar el abono a las cuentas de los clientes AFORE.
				  IF vcodret = 0 THEN
					---CALL bdicheq:sp_generafolionomina(cpUsuario)Returning vcodret,cNumeroFolioAbono;
					--CALL bdicheq:"informix".sp_generafolionominapagos(cpUsuario)Returning vcodret,cNumeroFolioAbono;
					--Genera el folio del cargo a la cuenta cargo.					
					--Se obtiene la hora actual
					SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND
					INTO cHoraDispercion
					FROM sysmaster:"informix".sysshmvals; 				
					
						LET iContadorAbono = iContadorAbono + 1;
						Let cHora = Substr(cHoraDispercion, 1, 2);
						Let cMinutos = Substr(cHoraDispercion, 4, 2);						
						Let cHoraDispercionFormateada = cHora || cMinutos;				
					
						IF iContadorAbono In (1,2,3,4,5,6,7,8,9) THEN
							Let cNumeroFormateado = '000' || iContadorAbono;
							LET cNumeroFolioAbono = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
						ELSE
							IF LENGTH(TRIM(iContadorAbono::CHAR(4))) = 2 THEN 
								Let cNumeroFormateado = '00' || iContadorAbono;
								LET cNumeroFolioAbono = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado; 
							ELIF LENGTH(TRIM(iContadorAbono::CHAR(4))) = 3 THEN 
								Let cNumeroFormateado = '0' || iContadorAbono;
								LET cNumeroFolioAbono = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado; 
							ELSE
								LET cNumeroFolioAbono = cpUsuario || cHoraDispercionFormateada || iContadorAbono; 
							END IF;																				
							
						END IF;
						
						IF iContadorAbono = 9999 THEN
							LET iContadorAbono = 0;
						END IF;
					
					LET cSucursalAbono = cSucursalContable;
					CALL bdicheq: "informix".abono_ref ("001", cSucursalAbono, pUsuario,  cTransaccAbono, "0000", cNumeroFolioAbono, cCuentaAbono,
					0, mSaldoAPagar, mSaldoAPagar, 0, 0, 0, "01", " ", '', pUsuario) Returning vcodret;  
					
					
					 IF vcodret <> 0 THEN
					 
						LET cMensajeBC = 'abono_ref  ' || cCuentaAbono;											
						INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)	
						VALUES (cNomProceso,cNombre_arch,vcodret,cMensajeBC,pUsuario,dFechaActual,cHoraActual);
						
						--LLamado a realizar la reversion del abono.
						CALL bdicheq: "informix".reversion ('001', cSucursalAbono, pUsuario,cNumeroFolioCargo, "C") Returning vcodret;
							IF vcodret <> 0 THEN							
								LET cMensajeBC = 'reversion  ' || cCuentaAbono;												
								INSERT INTO "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)	
								VALUES (cNomProceso,cNombre_arch,vcodret,cMensajeBC,pUsuario,dFechaActual,cHoraActual);								
								
								CALL bdicheq: "informix".reversion ('001', cSucursalAbono, pUsuario,cNumeroFolioCargo, "C") Returning vcodret;
								
								IF vcodret <> 0 THEN							
									LET cMensajeBC = 'Segunda ejecucion reversion  ' || cCuentaAbono;												
									INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)	
									VALUES (cNomProceso,cNombre_arch,vcodret,cMensajeBC,pUsuario,dFechaActual,cHoraActual);																	
								END IF;
							END IF;						
						
						LET cMensaje = 'Aplicado parcialmente';
						UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
						WHERE nombre_arch = cNombre_arch 
						AND clabe = cClaBe 
						AND imp_netopagar = mSaldoAPagar 
						AND rfc = cRFCrecibido
						AND consecutivo = iRowID;
						CONTINUE FOREACH;
					 ELSE
						UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '02',folio_suc = cNumeroFolioAbono,fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
						WHERE nombre_arch = cNombre_arch 
						AND clabe = cClaBe 
						AND imp_netopagar = mSaldoAPagar 
						AND rfc = cRFCrecibido
						AND consecutivo = iRowID;
					  END IF
				  ELSE 
					LET cMensajeBC = 'cargo_ref  ' || cCuentaCargo;										
					INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
					VALUES (cNomProceso,cNombre_arch,vcodret,cMensajeBC,pUsuario,dFechaActual,cHoraActual);					
					
					UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
					WHERE nombre_arch = cNombre_arch 
					AND clabe = cClaBe 
					AND imp_netopagar = mSaldoAPagar 
					AND rfc = cRFCrecibido
					AND consecutivo = iRowID;
				  END IF
				 
				-- SE SACA DEL FOREACH
				 --Actualiza las comisiones que se le cobraran al mes con el valor de la comision ubicada en la transaccion
		--		 UPDATE {+  INDEX(pp_detalle idxdetalle120) } pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
		--		 WHERE nombre_arch = cNombre_arch AND status <> '01';
				 
			END FOREACH
			 --Actualiza las comisiones que se le cobraran al mes con el valor de la comision ubicada en la transaccion
			 UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle120) } bdiprog: "informix".pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
			 WHERE nombre_arch = cNombre_arch AND status <> '01';
		  
		ELIF pTipoarch = 2 THEN   --DSB 13/03/2014 
		
			SELECT num_cte INTO cNum_cte FROM bdicheq:'informix'.sc_maechq WHERE cuenta = cCuentaCargo;
			SELECT razon_social,rfc INTO cRazon_social,cRfcOrd FROM bdinteg:'informix'.si_cliente WHERE numcte = cNum_cte;
			
			FOREACH WITH HOLD
			
				SELECT {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle120) } TRIM(nom_benef) || ' ' || TRIM(apell_pat) || ' ' || TRIM(apell_mat), 
				SUBSTR(clabe,1,3),fecha_captura,imp_netopagar,num_tienda,rfc,clabe,consecutivo,forma_pago
				INTO cNom_benef,vcBancoDest, dFechaCaptura, mImp_netopagar,cNumTienda,cRfc,
				cClabeBenef, iRowID,iForma_pago 
				FROM bdiprog: "informix".pp_detalle
				WHERE nombre_arch = cNombre_arch
				AND status = '01'
				ORDER BY consecutivo
				
				LET cFolioSuc = '';
				
						
				--Genera el folio del cargo a la cuenta cargo.					
				--Se obtiene la hora actual
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND
				INTO cHoraDispercion
				FROM sysmaster:"informix".sysshmvals; 				
				
					LET iContadorFolioSuc = iContadorFolioSuc + 1;
					Let cHora = Substr(cHoraDispercion, 1, 2);
					Let cMinutos = Substr(cHoraDispercion, 4, 2);					
					Let cHoraDispercionFormateada = cHora || cMinutos;				
				
					IF iContadorFolioSuc In (1,2,3,4,5,6,7,8,9) THEN						
						Let cNumeroFormateado = '000' || iContadorFolioSuc;
						LET cFolioSuc = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
					ELSE
						IF LENGTH(TRIM(iContadorFolioSuc::CHAR(4))) = 2 THEN 
							Let cNumeroFormateado = '00' || iContadorFolioSuc;
							LET cFolioSuc = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado; 
						ELIF LENGTH(TRIM(iContadorFolioSuc::CHAR(4))) = 3 THEN 
							Let cNumeroFormateado = '0' || iContadorFolioSuc;
							LET cFolioSuc = cpUsuario || cHoraDispercionFormateada || cNumeroFormateado;
						ELSE
							LET cFolioSuc = cpUsuario || cHoraDispercionFormateada || iContadorFolioSuc;	
						END IF;
					END IF;
					
					IF iContadorFolioSuc = 9999 THEN
						LET iContadorFolioSuc = 0;
					END IF;		
								
					IF iForma_pago <> 4 AND iForma_pago <> 2 THEN
						LET vCodRet1 = '10036';
						CALL 'informix'.sp_Afore_MensajeRetorno (vCodRet1) RETURNING vCodRet,cMensaje;
						INSERT INTO bdiprog: "informix".pp_bitacora (proceso, archivo, cod_ret, mensaje,user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, cNombre_arch, vCodRet, cMensaje, pUsuario,dFechaActual, cHoraActual);
						RETURN vCodRet,cMensaje;					
					END IF;
				
					SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)} cvecesif, descripcion INTO cClavecesif, vcNomBancoDest FROM bdinteg:"informix".si_bancos WHERE banco = vcBancoDest;
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursalSPEI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '20';
					
					IF cClavecesif IS NULL THEN
						LET cClavecesif = 0;
					END IF;
					 
					CALL bdispei:'informix'.sp_regordenctecte( '001',vcSucursalSPEI,pUsuario,cClavecesif,mImp_netopagar,'',cFolioSuc,dFechaActual,
					0.00,0.00,cRazon_social,40,cCuentaCargo,cRfcOrd ,cNom_benef ,40, cClabeBenef,  cRfc  ,'Pago Afore Otros Bancos',0.00,0,0)
					RETURNING vCodRet, cMensaje, cVeRastreo;
										
					IF vtransacc = 1 THEN
						COMMIT WORK;
					END IF;
					
					LET vtransacc = vtransacc;
				
					IF vCodRet <> 0 THEN												
						LET cMensajeOB = 'sp_regordenctecte  ' || cClabeBenef;										
						INSERT INTO bdiprog: "informix".pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
						VALUES (cNomProceso,cNombre_arch,vcodret,cMensajeOB,pUsuario,dFechaActual,cHoraActual);					
						
						UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '10', fecha_ejec = dFechaActual,hora_ejec = cHoraActual
						WHERE nombre_arch = cNombre_arch 
						AND clabe = cClabeBenef 
						AND imp_netopagar = mImp_netopagar 
						AND rfc = cRfc
						AND consecutivo =  iRowID;		
						COMMIT WORK;
						BEGIN WORK;						
					ELSE											
						UPDATE {+  INDEX(bdiprog: "informix".pp_detalle idxdetalle19d) } bdiprog: "informix".pp_detalle SET status = '20', fecha_ejec = dFechaActual,hora_ejec = cHoraActual, folio_suc = TRIM(cFolioSuc)
						WHERE nombre_arch = cNombre_arch 
						AND clabe = cClabeBenef 
						AND imp_netopagar = mImp_netopagar 	
						AND rfc = cRfc
						AND consecutivo =  iRowID;
						LET cMensaje = 'Aplicado exitosamente';	
						COMMIT WORK;
						BEGIN WORK;						
					END IF;			
			END FOREACH;
			
			--Actualiza el status del proceso a ejecutado.
			UPDATE bdiprog: "informix".pp_procesos SET status = 2 WHERE proceso = cNomProceso AND fech_proceso = dFechaActual AND status = 1;
			--Actualiza el archivo como procesado.
			UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '20',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		
		END IF		
		
	END IF	
	
	IF pTipoarch = 1  THEN	
		--Actualiza el status del proceso a ejecutado.
		UPDATE pp_procesos SET status = 2 WHERE proceso = cNomProceso AND fech_proceso = dFechaActual AND status = 1;
		--Actualiza el archivo como procesado.	
		UPDATE {+  INDEX(bdiprog: "informix".pp_arch_afore idxarcafore12) } bdiprog: "informix".pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
	END IF
	
 END IF
	COMMIT WORK; 
	
		--Genera la conciliacion de los datos.
		IF pTipoarch = 1 THEN
			CALL "informix".sp_AforeGenerarArchivoDeConfirmacionDePagos(cNombre_arch,pUsuario)Returning vcodret;
			IF vCodRet <> 0 THEN
				CALL "informix".sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
				UPDATE bdiprog: "informix".pp_procesos SET status = 1 WHERE proceso = cNomProceso AND fech_proceso = dFechaActual AND status = 2;
			ELSE 
				LET vCodRet  = '00000';
				UPDATE bdiprog: "informix".pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
			END IF 
		END IF
		
	Return vcodret,cMensaje;
END
END PROCEDURE
DOCUMENT
'AUTOR      : Antonio Bastidas',
'DESCRIPCION: El proceso genera el pago de las cuentas de AFORE segun el archivo y sus importes.',
'FECHA      : 29 de mayo de 2009',
'VERSION    : 20090529.1109',
'BD         : BDIPROG',
'MODIFICO   : Antonio Bastidas',
'DESCRIPCION: Se agrego el retorno dinamico de mensajes por el proceso sp_Afore_MensajeRetorno.',
'Se genero un cambio para que efectue 2 o mas pagos a la misma persona.',
'FECHA      : 26 de junio de 2009',
'VERSION    : 20090626.1641',
'BD         : BDIPROG',
'AUTOR      : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro pTipoarch',
'FECHA      : 12 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernandez Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG',
'AUTOR      : Viridiana PR',
'DESCRIPCION: agrego el numero de cuenta destino campo "cCuentaCargo" en la posicion del parametro preferencia',
'FECHA      : MAYO 2015',
'VERSION    : 20150528',
'BD         : bdiprog',
'MODIFICACION',
'MODIFICO   : Trinidad Hernandez',
'folio      : 73',
'DESCRIPCION: "Homologacion de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologacion con Vers. Prod., Pago de remesas Appriza',
'FECHA      : 22/06/2016',
'VERSION    : 20160622.0846',
'BD         : bdiprog',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 26 de junio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : bdiprog',
'VERSION    : 20250626.1300';

CREATE PROCEDURE "informix".sp_afore_dispersion(pNombreArchivo CHAR(25),pUsuario CHAR(8))
Returning CHAR(5),CHAR(50);

--Definicion de variables.
DEFINE vsqlerr						INTEGER;
DEFINE iExiste						INTEGER;
DEFINE iAceptab						INTEGER;
DEFINE iForma_pago 					INTEGER;
DEFINE iContadorTransacciones		INTEGER;
DEFINE iRowID						INTEGER;
DEFINE dFechaActual					DATE;
DEFINE vfechoy						DATE;
DEFINE cHoraActual					DATETIME HOUR TO SECOND;
DEFINE dePorcIVA 					DECIMAL (18,2);
DEFINE cBanderaArchivo				CHAR(1);
DEFINE cStatusCtaCargoAbono			CHAR(1);
DEFINE cConsulta					CHAR(1);
DEFINE cStatus						CHAR(2);
DEFINE cMotivo						CHAR(2);
DEFINE cStatusProceso				CHAR(2);
DEFINE cSucursalCargo				CHAR(4);
DEFINE cSucursalAbono				CHAR(4);
DEFINE cSucursalContable			CHAR(4);
DEFINE cTransaccAbono				CHAR(4);
DEFINE cTransaccCargo				CHAR(4);
DEFINE vtranret						CHAR(4);
DEFINE vcodret 						CHAR(5);
DEFINE vcodret1						CHAR(5);
DEFINE cFechaFormat					CHAR(8);
DEFINE cRFCrecibido					CHAR(10);
DEFINE cRFCorigen					CHAR(10);
DEFINE cRFCorigen_alterno           CHAR(10);
DEFINE cNomProceso					CHAR(10);
DEFINE cProceso						CHAR(10);
DEFINE cNumeroFolioCargo			CHAR(16);
DEFINE cNumeroFolioAbono			CHAR(16);
DEFINE cClaBe						CHAR(18);
DEFINE cNum_Cte						CHAR(20);
DEFINE cCuentaAbono					CHAR(20);
DEFINE cCuentaCargo					CHAR(20);
DEFINE cNombre_arch 				CHAR(25);
DEFINE cMensaje						CHAR(50);
DEFINE mSaldoCtaCargo				MONEY(18,2);
DEFINE mImporteAPagar				MONEY(18,2);
DEFINE mSaldoAPagar					MONEY(18,2);
DEFINE vsdodisp						MONEY(18,2);
DEFINE vmontoret					MONEY(18,2);
DEFINE mComisionAbono				MONEY(18,2);
DEFINE mComisionCargo				MONEY(18,2);
DEFINE mIVAUnitario				MONEY(18,2);
DEFINE cpUsuario					CHAR(8);

-- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
DEFINE mSdoActual                   MONEY(14,2);DEFINE mSdoRetenido                 MONEY(14,2);DEFINE mSdoCong                     MONEY(14,2);DEFINE mSaldoSbc                    MONEY(14,2);
BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let vcodret = vsqlerr;
			ROLLBACK WORK;
			IF cNombre_arch <> "" OR NOT cNombre_arch IS NULL THEN
			  UPDATE pp_detalle {+  INDEX(pp_detalle idxdetalle19c ) } SET status = '08',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			  WHERE nombre_arch = cNombre_arch;
		      UPDATE pp_arch_afore {+  INDEX(pp_arch_afore idxarcafore12  ) }SET status = '08',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
			END IF 
			LET cMensaje = 'Ocurrio un error no controlado';
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
            Return vcodret,cMensaje;
			
        END IF;
    END EXCEPTION;
--    SET DEBUG FILE TO "/tmp/sp_Afore_Dispersion.out";
--    TRACE ON;

    --Inicializacion de variables
    LET vcodret = '00000';
	LET vcodret1 = '00000';
	LET cMensaje = 'Aplicado exitosamente';
    LET dFechaActual = '';
    LET cNombre_arch = '';
    LET cStatus = '';
    LET cCuentaCargo = '';
	LET cRFCrecibido = '';
    LET cClaBe = '';
    LET cNum_Cte = '';
    LET cRFCorigen = '';
    LET cRFCorigen_alterno = '';
	LET cBanderaArchivo = '';
	LET cCuentaAbono = '';
	LET cCuentaCargo = '';
	LET cSucursalCargo = '';
	LET cSucursalAbono = '';
	LET cSucursalContable = '';
	LET cStatusCtaCargoAbono = '';
	LET cConsulta = '';
	LET cMotivo = '';
	LET cTransaccCargo = '';
	LET cTransaccAbono = '';
	LET cNomProceso = '';
	LET cFechaFormat = '';
	LET vtranret = '';
	LET vfechoy	= '';
	LET cStatusProceso = '';
	LET cNumeroFolioCargo = '';
	LET cNumeroFolioAbono = '';
	LET cProceso = '';
	LET iForma_pago = 0;
	LET vsdodisp = 0.00;
	LET vmontoret = 0.00;
	LET mSaldoCtaCargo = 0.00;
    LET mImporteAPagar = 0.00;
    LET mSaldoAPagar = 0.00;
	LET iAceptab = 0;
	LET iExiste = 0;
	LET iContadorTransacciones = 0;
	LET mComisionAbono = 0.00;
	LET mComisionCargo = 0.00;
	LET dePorcIVA = 0.00;
	LET mIVAUnitario = 0.00;
	LET cHoraActual = CURRENT HOUR TO SECOND;
	LET cpUsuario = '00000000';

	-- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
	LET cCodRetConsSdo      = '00000';
	LET cMensajeRetConsSdo  = '';
	LET mSdoActual		=0.00;	
	LET mSdoRetenido	=0.00;
	LET mSdoCong		=0.00;
	LET mSaldoSbc   	=0.00;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN WORK;

    --Se indica que se esta mandando llamar el proceso automatico.
    IF pNombreArchivo = '' OR pNombreArchivo IS NULL THEN
        LET cBanderaArchivo = 'A';
    ELIF pNombreArchivo <> '' OR NOT pNombreArchivo IS NULL THEN
        LET cBanderaArchivo = 'M';
    END IF;
	
	--Se valida el usuario que activo el proceso si no asigna a informix automatico
	IF pUsuario = "" OR pUsuario IS NULL THEN
		LET pUsuario = 'informix';
	END IF
	
	--consulta la fecha actual del sistema de integral
    SELECT {+  INDEX(bdicheq:sc_fechas idx_fechas1) } fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;
	
	LET cpUsuario = substr (cpUsuario,1,6) || LPAD(DAY(dFechaActual),2,0);	LET cFechaFormat = LPAD(DAY(dFechaActual),2,0) || LPAD(MONTH(dFechaActual),2,0) || YEAR(dFechaActual) ;
	
	
	
    --Consulta que el archivo exista para el proceso Automatico y que su estatus sea 01.
    IF cBanderaArchivo = 'A' THEN
				
        SELECT {+  INDEX(pp_arch_afore idxarcafore12) } nombre_arch,status INTO cNombre_arch,cStatus FROM pp_arch_afore
        WHERE SUBSTR(nombre_arch,6,8) = cFechaFormat
		AND SUBSTR(nombre_arch,23,2) = '01' AND tipo = 'P';
		
		  LET cNombre_arch = 'PAGOS'|| TRIM(cFechaFormat) ||'.ACOPPEL.01';
		  LET cNomProceso = 'AforeEPP'|| NVL(SUBSTR(cNombre_arch,23,2),"01");
		  
		  SELECT status INTO cStatusProceso FROM pp_procesos WHERE proceso = cNomProceso AND fech_proceso = dFechaActual; 
		    IF cStatusProceso IS NULL OR cStatusProceso = '' THEN
		        INSERT INTO pp_procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
		        VALUES (cNomProceso,dFechaActual,1,pUsuario,dFechaActual);
		    END IF 
			IF cStatusProceso = 2 THEN
				LET vcodret = '10011';
		        --LET cMensaje = 'El Archivo ya fue procesado';
				CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
				INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
				COMMIT WORK;
			    Return vcodret,cMensaje;
		    END IF;
    END IF

    --Consulta que el archivo exista para el proceso Manual.
    IF cBanderaArchivo = 'M' THEN
		
        SELECT nombre_arch,status INTO cNombre_arch,cStatus FROM pp_arch_afore
        WHERE nombre_arch = pNombreArchivo AND tipo = 'P';
		
		LET cNombre_arch = pNombreArchivo;		
		LET cNomProceso = 'AforeEPP'|| SUBSTR(cNombre_arch,23,2);
		
		  IF NOT cStatus IN ('01','09') OR cStatus IS NULL THEN
			LET vcodret = '10013';
			--LET cMensaje = 'No existen archivos por procesar';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		  END IF 
		  LET cStatusProceso = '';
		  LET cProceso = 'AforeVal'|| SUBSTR(pNombreArchivo,23,2);
		  
		SELECT status INTO cStatusProceso FROM pp_Procesos WHERE pp_Procesos.proceso = cProceso AND pp_Procesos.fech_proceso = dFechaActual;
		  
		IF cStatusProceso <> '2' THEN
			--- mensaje de error ya que se devio haber Ejecutado el proceso de Recepcion de archivo
				LET vCodRet = '10024';
				--LET cMensaje = 'Falta ejecutar el proceso anterior';
				CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
				INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
				VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);		
				COMMIT WORK;
				Return vcodret,cMensaje;
		END IF;
		
    END IF
	
	

    --Valida que se obtenga un nombre de archivo para procesar.
    IF cNombre_arch = '' OR cNombre_arch IS NULL THEN
        LET vcodret = '10013';
		--LET cMensaje = 'No existen archivos por procesar';
		CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		COMMIT WORK;
        Return vcodret,cMensaje;
    END IF;
	
	
	IF NOT EXISTS (SELECT proceso FROM pp_Procesos WHERE pp_Procesos.proceso = ('AforeVal'|| SUBSTR(cNombre_arch,23,2)) AND
				pp_Procesos.fech_proceso = dFechaActual and  pp_Procesos.status = '2') THEN
		
		LET vcodret = '10024';
		--LET cMensaje = 'Error ya que no se Ejecuto el proceso Anterior';
		CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		Return vcodret,cMensaje;
	ELSE
		LET cStatusProceso = '';
	    --Checa en la tabla de control de procesos si el proceso se ejecuto el dï¿½a de hoy en el sistema.
		SELECT status INTO cStatusProceso FROM pp_procesos WHERE proceso = cNomProceso AND fech_proceso = dFechaActual; 
	    IF cStatusProceso IS NULL OR cStatusProceso = '' THEN
	        INSERT INTO pp_procesos (proceso,fech_proceso,status,user_insert,fecha_insert)
	        VALUES (cNomProceso,dFechaActual,1,pUsuario,dFechaActual);
	    END IF 
		IF cStatusProceso = 2 THEN
			LET vcodret = '10011';
	        --LET cMensaje = 'El Archivo ya fue procesado';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
		    Return vcodret,cMensaje;
	    END IF;
	END IF;
	
	--Se comprueba que exista el usuario que manda llamar el proceso.
	SELECT 1 INTO iExiste FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario;
	  IF NOT iExiste = 1 or iExiste IS NULL THEN
	    LET vcodret = '10014';
	    --LET cMensaje = 'Usuario no valido';	
		CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		---COMMIT WORK;
	    --Return vcodret,cMensaje;
	  END IF 
	  
	   --Extrahe la cuenta a la que se le va a realizar el cargo.
	   SELECT desc_valor INTO cCuentaCargo FROM pp_parametros WHERE cve_param = '101';
	   SELECT valor INTO cTransaccAbono FROM pp_parametros WHERE cve_param = '102';
	   SELECT valor INTO cTransaccCargo FROM pp_parametros WHERE cve_param = '103';
	   SELECT valor INTO cSucursalContable FROM pp_parametros WHERE cve_param = '106';
	   
	    IF cSucursalContable IS NULL OR cSucursalContable = '' THEN
			LET vcodret = '10015';
			--LET cMensaje = 'Faltan parametros';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;			
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
	   END IF
	   
	     IF cCuentaCargo = "" OR cCuentaCargo IS NULL THEN
			LET vcodret = '10015';
			--LET cMensaje = 'Faltan parametros';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		 END IF 
		 
		 SELECT COUNT(numero) INTO iContadorTransacciones FROM bdinteg:si_transacc WHERE numero IN (cTransaccAbono,cTransaccCargo);
		 
		 IF NOT iContadorTransacciones = 2 THEN
			LET vcodret = '10016';
            --LET cMensaje = 'Error en Transacciones';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
	        Return vcodret,cMensaje;
		 END IF
		 
		 --Extrahe el costo unitario de la comision.
		 SELECT monto_fijo INTO mComisionCargo FROM bdinteg:si_transacc WHERE numero = cTransaccCargo;

		 --Extrahe el valor del IVA.
  		 SELECT valor INTO dePorcIVA FROM bdinteg:si_param WHERE cod_param = 47;
		 
		 IF mComisionCargo IS NULL OR mComisionCargo IS NULL THEN 
			LET vcodret = '10017';
			--LET cMensaje = 'IVA o Comision nulos';
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			COMMIT WORK;
			Return vcodret,cMensaje;
		 ELSE 
		 	--Calculo de IVA por transaccion.
			LET mIVAUnitario = mComisionCargo * dePorcIVA;
			
		 END IF
		
		    

	   --Consulta el saldo en el maestro de cheques de la cuenta cargo.
	   -- SELECT sucursal,sdo_actual - (sdo_cong + sdo_retenido),status_cta,motivo INTO cSucursalCargo,mSaldoCtaCargo,cStatusCtaCargoAbono,cMotivo 
	   SELECT sucursal,sdo_actual,sdo_retenido,sdo_cong,saldo_sbc,status_cta,motivo INTO cSucursalCargo,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,cStatusCtaCargoAbono,cMotivo 
	   FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaCargo;

	   -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
	   EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', '2') INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldoCtaCargo;

	     IF cStatusCtaCargoAbono = 2 THEN
		   UPDATE {+  INDEX(pp_detalle idxdetalle19c ) } pp_detalle SET status = '06',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
		   WHERE nombre_arch = cNombre_arch ;
		   UPDATE {+  INDEX(pp_arch_afore idxarcafore12) } pp_arch_afore SET status = '06',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		   LET vcodret = '10018';
		   --LET cMensaje = 'Cuenta AFORE cancelada';
		   CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;		   
		   INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		   COMMIT WORK;
		   Return vcodret,cMensaje;
		 END IF 
		 
		 IF cStatusCtaCargoAbono = 3 THEN
		   SELECT "1" INTO iExiste FROM bdicheq:sc_ctabloqueo WHERE cuenta = cCuentaCargo;
			IF iExiste = "1" THEN
			  SET ISOLATION TO DIRTY READ;
			  SELECT opcion INTO iAceptab FROM bdicheq:sc_ctabloqueo WHERE cuenta = cCuentaCargo;
				IF iAceptab = 4 THEN
					Let vcodret = "10019";
				END IF;
				IF iAceptab = 3 THEN
					Let vcodret = "10019";
				END IF;
			ELSE
				-- Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no cargos
				SELECT cargo INTO cConsulta FROM bdicheq:sc_bloqueo WHERE codigo = cMotivo;
				  IF cConsulta = 'N' THEN
					Let vcodret = "10019";
				  END IF
			END IF
			IF vcodret <> 0 THEN 
			   UPDATE {+  INDEX(pp_detalle idxdetalle19c ) } pp_detalle SET status = '05',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			   WHERE nombre_arch = cNombre_arch ;
			   UPDATE {+  INDEX(pp_arch_afore idxarcafore12) } pp_arch_afore SET status = '05',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
			   LET vcodret = '10019';
			   --LET cMensaje = 'Cuenta AFORE bloqueada';
			   CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;			   
			   INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
			   COMMIT WORK;
		       Return vcodret,cMensaje;
		    END IF 
		 END IF 
 IF vcodret = 0 THEN
	--Valida si existen movimientos para pagar.
	IF NOT EXISTS (SELECT * FROM pp_detalle WHERE nombre_arch = cNombre_arch and status='01') THEN
		  UPDATE {+  INDEX(pp_arch_afore idxarcafore12) } pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		  LET vcodret = '10020';
		  --LET cMensaje = 'No existen movimientos por aplicar';
		  CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		  INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		  VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		  COMMIT WORK;
		  Return vcodret,cMensaje;
	ELSE
	   --Consulta el monto total a pagar.
	   SELECT {+  INDEX(pp_detalle idxdetalle19c) } SUM(imp_netopagar) INTO mImporteAPagar FROM pp_detalle WHERE nombre_arch = cNombre_arch and status='01';

		--Valida si el monto a pagar es mayor al saldo de la cuenta cargo.
		IF mImporteAPagar > mSaldoCtaCargo THEN
		   --Se actualizan los datos de los movimientos y del archivo, mencionando que no hay suficiente saldo para realizar los pagos.
		   UPDATE {+  INDEX(pp_detalle idxdetalle19c) } pp_detalle SET status = '03',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
		   WHERE nombre_arch = cNombre_arch and status='01';
		   UPDATE {+  INDEX(pp_arch_afore idxarcafore12) } pp_arch_afore SET status = '03',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		   LET vcodret = '10021';
		   --LET cMensaje = 'Fondos insuficientes en la cuenta AFORE';
		   CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
		   INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		   VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		   
		   UPDATE {+  INDEX(pp_detalle idxdetalle120) } pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
			WHERE nombre_arch = cNombre_arch AND status <> '01';
		   COMMIT WORK;
		   Return vcodret,cMensaje;
		END IF
		
		LET cStatusCtaCargoAbono = '';
		LET cMotivo = '';
 
	  FOREACH WITH HOLD

		--Se consulta el monto y se extrahe el RFC del cliente.
        SELECT {+  INDEX(pp_detalle idxdetalle120) } consecutivo,forma_pago,clabe,imp_netopagar,rfc INTO iRowID,iForma_pago,cClaBe,mSaldoAPagar,cRFCrecibido 
		FROM pp_detalle WHERE nombre_arch = cNombre_arch AND status = '01'
		
		LET cCuentaAbono = SUBSTR(cClaBe,7,11); 
		SELECT num_cte,sucursal,status_cta,motivo INTO cNum_Cte,cSucursalAbono,cStatusCtaCargoAbono,cMotivo 
		FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaAbono;	
		
		IF cCuentaAbono = '' OR cCuentaAbono IS NULL OR cNum_Cte = '' OR cNum_Cte IS NULL OR cStatusCtaCargoAbono IS NULL THEN
			UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '04',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
			LET cMensaje = 'Al menos alguna cuenta no existe';
			CONTINUE FOREACH;
		END IF
		
		IF mSaldoAPagar <= 0.00 THEN
			UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
			LET cMensaje = 'Al menos alguna cuenta su abono es de cero o menor';
			CONTINUE FOREACH;
		END IF; 
		
		--Filtro de forma de pago
		IF iForma_pago <> 3 THEN
			UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
			LET cMensaje = 'Al menos alguna tiene un tipo de pago diferente';
			CONTINUE FOREACH;
		END IF 
		--valida si la cuenta esta cancelada.
		 IF cStatusCtaCargoAbono = 2 THEN
		   UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '06',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
		   WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
		   LET vcodret1 = '10032';
		   -- Aplicado parcailmente   
		   --LET cMensaje = 'Al menos una cuenta cliente AFORE cancelada';
		   CALL sp_Afore_MensajeRetorno (vCodRet1) RETURNING vCodRet,cMensaje;
		   --INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
		   --VALUES (cNomProceso,cNombre_arch,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
		   CONTINUE FOREACH;
		 END IF 
		 
		 --valida si la cuenta esta bloqueada y su tipo de bloqueo
		 IF cStatusCtaCargoAbono = 3 THEN
		   SELECT "1" INTO iExiste FROM bdicheq:sc_ctabloqueo WHERE cuenta = cCuentaAbono;
			IF iExiste = "1" THEN
			  SET ISOLATION TO DIRTY READ;
			  SELECT opcion INTO iAceptab FROM bdicheq:sc_ctabloqueo WHERE cuenta = cCuentaAbono;
				IF iAceptab = 4 THEN
					LET vcodret1 = '10032';
				END IF;
				IF iAceptab = 2 THEN
					LET vcodret1 = '10032';
				END IF;
			ELSE
				-- Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no abonos
				SELECT cargo INTO cConsulta FROM bdicheq:sc_bloqueo WHERE codigo=cMotivo;
				  IF cConsulta = 'N' THEN
					LET vcodret1 = '10032';
				  END IF
			END IF
			IF vcodret1 <> 0 THEN 
			   UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '05',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			   WHERE nombre_arch = cNombre_arch 
				AND clabe = cClaBe 
				AND imp_netopagar = mSaldoAPagar 
				AND rfc = cRFCrecibido
				AND consecutivo = iRowID;
			   LET vcodret1 = '10032';
			   -- Aplicado parcailmente   
			   --LET cMensaje = 'Al menos una cuenta cliente AFORE bloqueada'; 
			   CALL sp_Afore_MensajeRetorno (vCodRet1) RETURNING vCodRet,cMensaje;
		       CONTINUE FOREACH;
		    END IF
		 END IF 
		 
		SELECT rfc, rfc_alterno INTO cRFCorigen, cRFCorigen_alterno  FROM bdinteg:si_cliente WHERE numcte = cNum_Cte;
        IF TRIM(cRFCorigen_alterno) = '' OR cRFCorigen_alterno IS NULL THEN
            LET cRFCorigen_alterno = cRFCorigen;
        ELSE    
            LET cRFCorigen = cRFCorigen_alterno;
		END IF;  
        IF cRFCorigen <> cRFCrecibido THEN
			UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '07',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
			LET cMensaje = 'RFC Incorrecto';
			 UPDATE {+  INDEX(pp_detalle idxdetalle19c) } pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
			 WHERE nombre_arch = cNombre_arch AND status <> '01';
		    CONTINUE FOREACH;
		  END IF;
		LET cNumeroFolioCargo = '';
		LET cNumeroFolioAbono = '';
		
			
		--Genera el folio del cargo a la cuenta cargo.
		--CALL bdicheq:sp_generafolionomina(cpUsuario)Returning vcodret,cNumeroFolioCargo;
		CALL bdicheq:"informix".sp_generafolionominapagos(cpUsuario)Returning vcodret,cNumeroFolioCargo;
		
		LET cSucursalCargo = cSucursalContable;
		--LLamado a realizar el cargo a la cuenta AFORE.	
		CALL bdicheq:cargo_ref ("001", cSucursalCargo, pUsuario, cTransaccCargo, "0000", cNumeroFolioCargo, cCuentaCargo, 0, mSaldoAPagar,
		"01", " ", '', pUsuario) Returning vcodret,vtranret,vfechoy,vsdodisp,vmontoret;

		  --LLamado a realizar el abono a las cuentas de los clientes AFORE.
		  IF vcodret = 0 THEN
			---CALL bdicheq:sp_generafolionomina(cpUsuario)Returning vcodret,cNumeroFolioAbono;
			CALL bdicheq:"informix".sp_generafolionominapagos(cpUsuario)Returning vcodret,cNumeroFolioAbono;
			LET cSucursalAbono = cSucursalContable;
		    CALL bdicheq:abono_ref ("001", cSucursalAbono, pUsuario,  cTransaccAbono, "0000", cNumeroFolioAbono, cCuentaAbono,
		    0, mSaldoAPagar, mSaldoAPagar, 0, 0, 0, "01", " ", '', pUsuario) Returning vcodret;  

		      IF vcodret <> 0 THEN
    			--LLamado a realizar la reversion del abono.
			    CALL bdicheq:reversion ('001', cSucursalAbono, pUsuario,cNumeroFolioCargo, "C") Returning vcodret;
				LET cMensaje = 'Aplicado parcialmente';
			    UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
				WHERE nombre_arch = cNombre_arch 
				AND clabe = cClaBe 
				AND imp_netopagar = mSaldoAPagar 
				AND rfc = cRFCrecibido
				AND consecutivo = iRowID;
		        CONTINUE FOREACH;
		      ELSE
  		        UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '02',folio_suc = cNumeroFolioAbono,fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
				WHERE nombre_arch = cNombre_arch 
				AND clabe = cClaBe 
				AND imp_netopagar = mSaldoAPagar 
				AND rfc = cRFCrecibido
				AND consecutivo = iRowID;
		      END IF
		  ELSE 
			UPDATE {+  INDEX(pp_detalle idxdetalle19d) } pp_detalle SET status = '10',fecha_ejec = dFechaActual, hora_ejec = cHoraActual 
			WHERE nombre_arch = cNombre_arch 
			AND clabe = cClaBe 
			AND imp_netopagar = mSaldoAPagar 
			AND rfc = cRFCrecibido
			AND consecutivo = iRowID;
		  END IF
		 
-- SE SACA DEL FOREACH
		 --Actualiza las comisiones que se le cobraran al mes con el valor de la comision ubicada en la transaccion
--		 UPDATE {+  INDEX(pp_detalle idxdetalle120) } pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
--		 WHERE nombre_arch = cNombre_arch AND status <> '01';
		 
	  END FOREACH
		 --Actualiza las comisiones que se le cobraran al mes con el valor de la comision ubicada en la transaccion
		 UPDATE {+  INDEX(pp_detalle idxdetalle120) } pp_detalle SET comision = mComisionCargo, iva_comision = mIVAUnitario 
		 WHERE nombre_arch = cNombre_arch AND status <> '01';
	  
	END IF
	
		
	--Actualiza el status del proceso a ejecutado.
	UPDATE pp_procesos SET status = 2 WHERE proceso = cNomProceso AND fech_proceso = dFechaActual AND status = 1;
	--Actualiza el archivo como procesado.	
    UPDATE {+  INDEX(pp_arch_afore idxarcafore12) } pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;

 END IF
	COMMIT WORK; 
	--Genera la conciliacion de los datos.
	CALL sp_AforeGenerarArchivoDeConfirmacionDePagos(cNombre_arch,pUsuario)Returning vcodret;
	
		IF vCodRet <> 0 THEN
			CALL sp_Afore_MensajeRetorno (vCodRet) RETURNING vCodRet1,cMensaje;
			UPDATE pp_procesos SET status = 1 WHERE proceso = cNomProceso AND fech_proceso = dFechaActual AND status = 2;
		ELSE 
			LET vCodRet  = '00000';
			UPDATE pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = cNombre_arch;
		END IF 
	Return vcodret,cMensaje;
END
END PROCEDURE
DOCUMENT
'AUTOR      : Antonio Bastidas',
'DESCRIPCION: El proceso genera el pago de las cuentas de AFORE segun el archivo y sus importes.',
'FECHA      : 29 de mayo de 2009',
'VERSION    : 20090529.1109',
'BD         : BDIPROG',
'MODIFICO   : Antonio Bastidas',
'DESCRIPCION: Se agrego el retorno dinamico de mensajes por el proceso sp_Afore_MensajeRetorno.',
'Se genero un cambio para que efectue 2 o mas pagos a la misma persona.',
'FECHA      : 26 de junio de 2009',
'VERSION    : 20090626.1641',
'BD         : BDIPROG',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 26 de junio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDIPROG',
'VERSION    : 20250626.1300';

CREATE PROCEDURE "informix".sp_ejecutartransacciones(pcEmpresa CHAR(3),	pdFecha DATE, pcCveCanal CHAR(2), pcUsuario CHAR(8))
RETURNING CHAR(5),CHAR(100);
DEFINE sql_err    		INTEGER;
DEFINE vcCodRet   		CHAR(5);
DEFINE vcMensaje  		CHAR(100);
DEFINE vcStatus   		CHAR(1);
DEFINE vdFechaHoy 		DATE;
DEFINE vcTansacc  		CHAR(4);
DEFINE vcTansacc2		CHAR(4);
DEFINE vcTransuc  		CHAR(4);
DEFINE vcTransucSPEI  	CHAR(4);
DEFINE viCheque	  		INTEGER;
DEFINE vcDivisa   		CHAR(2);
DEFINE vcodretTemp    	CHAR(5);
DEFINE vcodret      	CHAR(5);
DEFINE vcCodRetReverso  CHAR(5);
DEFINE vctranret   		CHAR(4);
DEFINE vdfechoy    		DATE;
DEFINE vmsdodisp, vmontoret	MONEY(16,2);
DEFINE vcFolioSuc 		CHAR(16);
DEFINE vcFolioSucCargo	CHAR(16);
DEFINE vcCveProg  		CHAR(10);
DEFINE vcNoCliente,vcNoCliente2	CHAR(20);
DEFINE vcConcepto  		CHAR(60);
DEFINE vcSucursal 		CHAR(4);
DEFINE vcNoCuentaOri 	CHAR(20);
DEFINE vcNoCuentaDest 	CHAR(20);
DEFINE vmMonto    		MONEY(16,2);
DEFINE vcNoTarjeta 		CHAR(20);
DEFINE vcReferencia 	CHAR(40);
DEFINE viNumReg 		INTEGER;
DEFINE vcBancoDest    	INTEGER;
DEFINE vcBancoDest2    	INTEGER;
DEFINE vcCveCtaOri		CHAR(2);
DEFINE vmImporte 	 	MONEY(16,2);
DEFINE vmImporteIVA  	MONEY(16,2);
DEFINE vcRef1			CHAR(40);
DEFINE vcRef2			CHAR(20);
DEFINE vcRefCob 		CHAR(40);
DEFINE viTpoSPEI		INTEGER;
DEFINE vmComisionSPEI	MONEY(16,2);
DEFINE vmpComisionSPEI	MONEY(16,2);
DEFINE vcTarifaSPEI		VARCHAR(18,1);
DEFINE vcNombreCliente 	CHAR(100);
DEFINE vcNombreBen 		CHAR(100);
DEFINE vcRFC			CHAR(13);
DEFINE vcRFCBen			CHAR(13);
DEFINE vcCveCtaBen		CHAR(2);
DEFINE vcCveRastreoSPEI	CHAR(30);
DEFINE vcNumCredito		CHAR(20);
DEFINE vcCategoria		CHAR(2);
DEFINE vcConvenio		CHAR(5);
DEFINE vcTranSucTelmex  CHAR(100);
DEFINE vcFlgporccomtrans_conv 	CHAR(1);
DEFINE vdPorc_com_trans_conv 	MONEY(16,2);
DEFINE vcFlgimpcomtrans_conv 	CHAR(1);
DEFINE vdImp_com_trans_conv 	MONEY(16,2);
DEFINE deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente 	DECIMAL (6,2);
DEFINE viIvaConvenio			INT;
DEFINE vcFlgporccomtrans_cte	CHAR(1);
DEFINE vmPorc_com_trans_cte		MONEY(16,2);
DEFINE vcFlgimpcomtrans_cte		CHAR(1);
DEFINE vmImp_com_trans_cte		MONEY(16,2);
DEFINE viConsecutivo			INTEGER;
DEFINE viConsecutivo2			INTEGER;
DEFINE vcMsgError				CHAR(200);
DEFINE vcFlgError           	CHAR(1);
DEFINE vcAplicarReversionDebito CHAR(1);
DEFINE vcAplicarReversionDebitoAbono CHAR(1);
DEFINE vcTranAbonoCred			CHAR(4);
DEFINE vcAplicaRollback			CHAR(1);
DEFINE vcFechaFolio				CHAR(6);
DEFINE vcHHMMSSFolioAbono		CHAR(9);
DEFINE vcHHMMSSFolio			CHAR(9);
DEFINE vcHHMMSSFolio2			CHAR(9);
DEFINE vcTranccAbono			CHAR(4);
DEFINE vcTranccAbonoTemp		CHAR(4);
DEFINE vcTranccAbonoTerc		CHAR(4);
DEFINE vcTranccTemp				CHAR(4);
DEFINE vcTipoPago				CHAR(2);
DEFINE vtransaccion				INTEGER;
DEFINE vcPrefijo				CHAR(3);
DEFINE vcSufijo				    CHAR(3);
DEFINE vcCveMensajes			CHAR(8);
DEFINE vcCuentaInvalida, vRechazo	CHAR(1);
DEFINE vcIvaSpei				CHAR(5);
DEFINE vcImpIvaSpei				CHAR(5);
DEFINE vcpImpIvaSpei			CHAR(5);
DEFINE vcMensajeSP				CHAR(50);
DEFINE vproducto  				CHAR(4);
DEFINE viTipo_spei              INTEGER;
DEFINE vCvePago                 char(3);
DEFINE vCvePago_ant             char(3);
DEFINE vcBancoDest_ant        	INTEGER;
DEFINE vcCtaDestino	            CHAR(20);
DEFINE vcTansacCargo    		CHAR(4);
DEFINE vcTansacAbono    		CHAR(4);
DEFINE vcDescripcion    		CHAR(20);
DEFINE vporce                   MONEY(14,2);
DEFINE vcve_pago,vccve_programa CHAR(2);
DEFINE vcnotifica, vcnotificaben CHAR(2);
DEFINE vcbenemail 				CHAR(100); --Se modifica rango a 100 caracteres.
DEFINE vcbencelular  			CHAR(10);
DEFINE vcDescPago	  			CHAR(30);
DEFINE vImporte2	            CHAR(16);
DEFINE vcauxnotifica           	CHAR(1);
DEFINE vidmensaje1		 		CHAR(10);
DEFINE vcAux				 	CHAR(100); --Se modifica por que se utiliza en parte para el email (ahora de 100 caracteres).
DEFINE vcNomBancoDest	 		CHAR(40);
DEFINE vmMAximo, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9, vsdo_cta, vmto_total MONEY(14,2);
DEFINE vcTipoPersona			CHAR(2);
--	2013.11.01 FRG-i	-	Se agrega validacion de cierre procesos centrales por Proy. Indep. Sistemas.
DEFINE CdRetVerSis 				CHAR (5);
DEFINE IndCrreCred 				CHAR (1);
DEFINE IndDispCred 				CHAR (1);
DEFINE IndCrreChqs 				CHAR (1);
DEFINE IndDispChqs 				CHAR (1);
DEFINE IndCrreInvs 				CHAR (1);
DEFINE IndDispInvs 				CHAR (1);
DEFINE IndCrreSrvs 				CHAR (1);
DEFINE flg_indicadores			CHAR (1);
DEFINE IndsCred 				CHAR (1);
DEFINE cDescripcionSPJ	 		CHAR(100);

DEFINE vcemicel 				CHAR(10); -- Se agrega variable para el e-mail del emisor.

DEFINE cSegsEspera				INTEGER;
DEFINE cBloquePagos				INTEGER;
DEFINE vCuantosEnviados			INTEGER;
DEFINE cSql 					CHAR(10);
--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Variables agregadas por modificacion en la consulta de parametros
DEFINE vcSucursalParam12 		CHAR(4); 	--> Variable que almacena el valor del parametro con clave = '12'.
DEFINE vcTranSucPagoServ		CHAR(100); 	--> Sucursal de Transaccion para Pago de Servicios.
DEFINE vcCtaDestinoTelmex		CHAR(20); 	--> Cuenta destino para TELMEX
DEFINE vcTansacCargoTelmex		CHAR(4);	--> Cargo Transaccion para TELMEX
DEFINE vcTansacAbonoTelmex		CHAR(4);	--> Abono Transaccion para TELMEX
DEFINE vcCtaDestinoSky			CHAR(20);	--> Cuenta destino para SKY
DEFINE vcSucursalSky			CHAR(4);	--> Sucursal para SKY
DEFINE vcTranSucSky				CHAR(100);	--> Sucursal de Transaccion para SKY
DEFINE vcTansacCargoSky			CHAR(4);	--> Cargo Transaccion para SKY
DEFINE vcTansacAbonoSky         CHAR(4);	--> Abono Transaccion para SKY
DEFINE vcCtaDestinoDish			CHAR(20);	--> Cuenta destino para DISH
DEFINE vcTranSucDish			CHAR(100);	--> Sucursal de Transaccion para DISH
DEFINE vcTansacCargoDish		CHAR(4);	--> Cargo Transaccion para DISH
DEFINE vcTansacAbonoDish		CHAR(4);    --> Abono Transaccion para DISH
DEFINE vcCtaDestinoMasTV		CHAR(20);	--> Cuenta destino para MAS TV
DEFINE vcTranSucMasTV			CHAR(100);	--> Sucursal de Transaccion para MAS TV
DEFINE vcTansacCargoMasTV		CHAR(4);	--> Cargo Transaccion para MAS TV
DEFINE vcTansacAbonoMasTV		CHAR(4);    --> Abono Transaccion para MAS TV
DEFINE vcCtaDestinoOtroBanco	CHAR(20);	--> Cuenta destino para Otro Banco
DEFINE vcSucursalOtroBanco		CHAR(4);	--> Sucursal para Otro Banco
DEFINE vcTansacCargoOtroBanco	CHAR(4);	--> Cargo Transaccion para Otro Banco
DEFINE vcTansacAbonoOtroBanco	CHAR(4);    --> Abono Transaccion para Otro Banco
--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE mImpChqSbg		MONEY(14,2); --Monto del importe de cheques de sobregiro.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.



--	2013.11.01 FRG-f
	ON EXCEPTION SET sql_err
		LET vcCodRet = sql_err;
		IF  vcAplicaRollback = 'S' THEN
			ROLLBACK WORK;
		END IF;
		IF vcAplicarReversionDebito = 'S' THEN
			CALL bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
		END IF;
		IF vcAplicarReversionDebitoAbono = 'S' THEN
			CALL bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSuc, 'A') RETURNING vcCodRetReverso;
		END IF;
			LET vcMsgError = 'ERROR AL EJECUTAR LA TRANSACCION';
			INSERT INTO bdiprog:"informix".pp_errores( cod_error, descripcion, fecha, hora)
			VALUES( vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
		RETURN vcCodRet,'ERROR EN INFORMIX.';
	END EXCEPTION;
	ON EXCEPTION IN (-535)
	  LET vtransaccion = 1;
	END EXCEPTION WITH RESUME;
--	2013.11.01 FRG-i


			--	SET DEBUG FILE TO '/respaldosbd/antoniocebreros/153/ejecuta_trans.out';
			--	TRACE ON;				
			
LET vcCodRet = '';
LET vcMensaje = '';

LET vcemicel = '';

LET CdRetVerSis		= '';
LET IndCrreCred 	= '';
LET IndDispCred 	= '';
LET IndCrreChqs 	= '';
LET IndDispChqs 	= '';
LET IndCrreInvs 	= '';
LET IndDispInvs 	= '';
LET IndCrreSrvs 	= '';
LET flg_indicadores = '';
LET IndsCred		= '0';
--	2013.11.01 FRG-f
LET viNumReg = 0;
LET vcMsgError = '';
LET vcAplicarReversionDebito = 'N';
LET vcAplicaRollback = 'N';
LET vcAplicarReversionDebitoAbono = 'N';
LET vcTranccAbono = '';
LET vcTipoPago = '';
LET vcTranccTemp = '';
LET vcTranccAbonoTemp = '';
LET vtransaccion = 0;
LET vsdo_cta = 0;
LET vmto_total = 0;
LET vcFlgError ='0';
LET vporce = 0;
LET vRechazo = 'N';
LET cDescripcionSPJ	= 'Ejecucion de pagos programados 8:00 am y 12:00 pm';

LET cSegsEspera =(SELECT valor FROM pp_parametros WHERE cve_param='109');
LET cBloquePagos =(SELECT valor FROM pp_parametros WHERE cve_param='110');
LET vCuantosEnviados = 0;
LET cSql ='';

	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET mImpChqSbg			=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	IF NVL(pcEmpresa,'') = '' OR NVL(pdFecha,'') = '' OR NVL(pcUsuario,'') = '' THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '01';
		RETURN vcCodRet,vcMensaje;
	END IF;
	IF NOT EXISTS ( select cve_canal from pp_tpcanal where cve_canal = pcCveCanal ) THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '64';
		RETURN vcCodRet,vcMensaje;
	END IF;
	SELECT fecha_hoy INTO vdFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa='001';
	IF vdFechaHoy <> pdFecha THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '96';
		RETURN vcCodRet,vcMensaje;
	END IF;
	SELECT {+INDEX (bdiprog:"informix".pp_procesos 110_15)} status INTO vcStatus FROM bdiprog:"informix".pp_procesos WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
	IF vcStatus = '2' THEN
		SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '97';
		RETURN vcCodRet,vcMensaje;
	END IF;
	IF vcStatus IS NULL THEN
		INSERT INTO bdiprog:"informix".pp_procesos VALUES('ejec_trans',pdFecha,'0',pcUsuario,CURRENT::DATE);
	END IF;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PP_ET', pdFecha, '0', 'informix', 'sp_ejecutartransacciones', cDescripcionSPJ);
	
--	2013.11.06-FRG-i
EXECUTE FUNCTION bdinteg:verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
	IF CdRetVerSis <> '000'
		then
			LET vcCodRet = '99999';
			LET vcMensaje = 'Error en la ejecucion SP bdinteg:verifica_sistemas';
			LET vcMsgError = vcMensaje;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));					
	END IF;
	if	IndCrreCred <> '1' or IndDispCred <> '1' or IndCrreChqs <> '1' or IndDispChqs <> '1' or IndCrreSrvs <> '1'
		then
			let flg_indicadores = '0';
		else
			let flg_indicadores = '1';
	end if;
--	2013.11.06-FRG-f
	if vtransaccion = 1 then
	   COMMIT WORK;
	end if;
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '04'; 
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc2 FROM bdiprog:"informix".pp_parametros WHERE cve_param = '18'; 
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTransuc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '06'; --La sucursal es REGIONAL.
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO viCheque  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '07';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcDivisa  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '08';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranccAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '09';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranccAbonoTerc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '19';
	 LET vdFechaHoy = CURRENT::DATE;
	 LET vcHHMMSSFolio 		=  replace (substring (current FROM 12  FOR 8 ), ':', '');
	 LET vcFechaFolio 		=  SUBSTRING (YEAR(vdFechaHoy) FROM 3 FOR 2) || LPAD(MONTH(vdFechaHoy),2,'0') || LPAD(DAY(vdFechaHoy),2,'0');
	 LET vcSufijo 			=  SUBSTRING ( vcFechaFolio FROM 4 FOR 3);
	 LET vcPrefijo 			=  SUBSTRING ( vcFechaFolio FROM 1 FOR 3 );
	 LET vcHHMMSSFolio		=  vcSufijo || vcHHMMSSFolio;
	 LET vcHHMMSSFolio2			= vcHHMMSSFolio;
	 LET vcHHMMSSFolioAbono		=  vcHHMMSSFolio; 
	-- Traspasos entre Cuentas Efectivas Bancoppel Propias"  y hacia un tercero".
--	2013.11.01 FRG-I --	Validacion disponibilidad Sistemas (bdicheq):
	if IndCrreChqs <> '1'
		then
			LET vcCodRet = '00004';
			LET vcMsgError = 'Sistema CHEQUES No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parametros con apoyo de MO/JG');
			RETURN vcCodRet, vcMensaje;
		else
			if IndDispChqs <> '1'
				then
					LET vcCodRet = '00005';
					LET vcMensaje = 'Sistema CHEQUES Temporalmente Fuera de Servicio.';
					LET vcMsgError = vcMensaje;
					INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
					VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parametros con apoyo de MO/JG');
					RETURN vcCodRet, vcMensaje;
				else
			end if;
	end if;

	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Se obtiene el parametro con clave 12, que se requiere varias veces a lo largo del SPL.
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursalParam12 FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Se genera la validacion y el mensaje para este tipo de rechazo '99998' 
	IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN 
		LET vcodretTemp  = '99998';
		LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
		INSERT INTO bdiprog:"informix".pp_tprechazo
		VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
	END IF;
	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Se genera la validacion y el mensaje para este tipo de rechazo '99997' 
	IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99997' ) THEN 
		LET vcodretTemp  = '99997';
		LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
		INSERT INTO bdiprog:"informix".pp_tprechazo
		VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
	END IF;

--	2013.11.01 FRG-F
	FOREACH with hold
		SELECT pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cuenta_destino, pagoprog.importe, pagoprog.descripcion, pagopend.consecutivo, pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vmMonto ,vcConcepto, viConsecutivo, vcTipoPago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('01','02') and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';
		IF NOT vmMonto <= vmMaximo THEN
				LET vcodretTemp  = '99998';
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de la validacion con consulta 
			/*IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN 
				LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;*/
			UPDATE bdiprog:"informix".pp_pagospend SET  estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vRechazo = 'S';
			CONTINUE FOREACH;
		END IF;
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Asignacion de sucursal del parametro 12 a vcSucursal para sustituir consulta a BD y comentarizacion de consulta.
		--SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
		LET vcSucursal = vcSucursalParam12;
		SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente   AND tipo_tarjeta = 'T' AND status_tar = 'A';
		LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
		BEGIN WORK;
	    LET vcAplicaRollback = 'S';
		IF vcTipoPago = '01' THEN
			LET vcDescPago = 'A CUENTAS PROPIAS';
			--Se agrega al select que consulte el tipo de persona.
			SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), tpo_persona INTO vcNombreBen, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;			
				--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
				IF vcNombreBen IS NULL OR vcNombreBen='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
					SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreBen FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				END IF;
			LET vcHHMMSSFolio = vcHHMMSSFolio + 1;
            LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
			LET vcFolioSucCargo =   vcPrefijo  || vcHHMMSSFolio || vcTansacc;
			LET vcTranccTemp = vcTansacc;
			LET vcTranccAbonoTemp = vcTranccAbono;
		ELSE
			LET vcDescPago = 'A CUENTA DE TERCEROS';
			SELECT LIMIT 1 nombre INTO vcNombreBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest;			
			LET vcHHMMSSFolio = vcHHMMSSFolio + 1;
			LET vcFolioSucCargo =   vcPrefijo  || vcHHMMSSFolio || vcTansacc2;
			LET vcTranccTemp = vcTansacc2;
			LET vcTranccAbonoTemp = vcTranccAbonoTerc;
		END IF;
        CALL bdicheq:"informix".sp_generafolionominapagos('informix') Returning vcodret,vcFolioSucCargo;
		LET vcMsgError = 'Error de informix en trasacciones propias y terceros al aplicar cargo_ref con cuenta origen: ' || vcNoCuentaOri;
		CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTranccTemp, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
								RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
		IF TRIM(vcodretTemp) = '000' THEN
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Asignacion de sucursal del parametro 12 a vcSucursal para sustituir consulta a BD y comentarizacion de consulta.
			--SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12'; --NPI Sacar del FOREACH
			LET vcSucursal = vcSucursalParam12;
			LET vcNoTarjeta = '';
			LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
			LET vcMsgError = 'Error de informix en trasacciones propias y terceros al aplicar abono_ref con cuenta destino: ' || vcNoCuentaDest;
			LET vcAplicarReversionDebito = 'S';
			CALL bdicheq:"informix".abono_ref( '001', vcSucursal, pcUsuario, vcTranccAbonoTemp, vcTransuc, vcFolioSucCargo, vcNoCuentaDest, 0, vmMonto, vmMonto, 0.00, 0.00, 0, vcDivisa, vcReferencia,	vcNoTarjeta, pcUsuario)
									RETURNING vcodretTemp;
				IF 	TRIM(vcodretTemp) = '000' THEN
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, vcNoTarjeta , '1', 
						vcNoCuentaOri, vcNoCuentaDest, 'BANCOPPEL, S.A.', vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIRARIO
						IF vcnotificaben = '02' THEN
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamanio variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;				
				ELSE
					call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario, vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
					LET vRechazo = 'S'; 
					IF vcodretTemp > 0 THEN
						IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
							SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
							IF vcMsgError IS NULL THEN
								LET vcMsgError = 'ERROR EN EJECUCION DE ABONO_REF';
							END IF;
							INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
						END IF;
						UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = vcodretTemp  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					ELSE -- ERROR DE INFORMIX.
						INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
						VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
					END IF;
					IF trim(vcCodRetReverso) <> '000' THEN
						ROLLBACK WORK;
						SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '99';
						RETURN vcCodRet,vcMensaje;
					END IF;
				END IF;
		ELSE
			LET vRechazo = 'S'; 
			IF trim(vcodretTemp)  > 0 THEN
				IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
					SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
					IF vcMsgError IS NULL THEN
						LET vcMsgError = 'ERROR EN EJECUCION DE CARGO_REF';
					END IF;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
				END IF;
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
						UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg;
				END IF;
				IF trim(vcodretTemp) = '400' THEN
					LET viConsecutivo2 = viConsecutivo - 3;
					SELECT COUNT(cve_pagoprog) INTO viNumReg FROM bdiprog:"informix".pp_pagospend
					WHERE cve_pagoprog = vcCveProg and consecutivo > viConsecutivo2 and consecutivo <= viConsecutivo and  estado = '06' and cve_rechazo = '400';
					IF viNumReg > 2 THEN
						UPDATE bdiprog:"informix".pp_pagoprog  SET cve_estado = '02', user_cancela = pcUsuario, fecha_cancela = CURRENT::DATE, canal_cancela = pcCveCanal
						WHERE cve_pagoprog = vcCveProg;
						UPDATE bdiprog:"informix".pp_pagospend SET     estado = '02', user_cancela = pcUsuario, fecha_cancela = CURRENT::DATE, canal_cancela = pcCveCanal
						WHERE cve_pagoprog = vcCveProg AND  estado = '03';
					END IF;
				END IF;
			ELSE 
					INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
			END IF;
		END IF;
		IF vRechazo = 'S' THEN -- Se dispara alerta por PPG Rechazado
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes			
				
				-- 184- Se agrega envio de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
				
			END IF;
		END IF;
		COMMIT WORK;
		LET vcAplicaRollback = 'N';
	END FOREACH;
	LET vcAplicarReversionDebito = 'N';
	LET vcMsgError = '';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTransucSPEI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '10';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTarifaSPEI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '13';
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcIvaSpei FROM bdinteg:"informix".si_param where cod_param = '47';
	SELECT {+INDEX(bdispei:"informix".tblcomision ix283_1)} mnycomision INTO vmComisionSPEI FROM bdispei:"informix".tblcomision WHERE vchrcvecomision = vcTarifaSPEI;
	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Recolocacion de consulta fuera del foreach para mejor performance.
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '20'; 
	LET vmComisionSPEI = 0;
	LET vcImpIvaSpei = vcIvaSpei * vmComisionSPEI;
	LET vcHHMMSSFolio 	=  vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
	LET vcCuentaInvalida = 'N';
-- Transacciones SPEI:
	FOREACH with hold
		SELECT pagoprog.cve_pagoprog, num_cte, cuenta_origen, cuenta_destino, importe, descripcion, banco_destino, cve_cuenta_ori,  referencia1, importe_iva, referencia2, ref_cobranza, tipo_spei,pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vmMonto ,vcConcepto, vcBancoDest, vcCveCtaOri, vcRef1,  vmImporteIVA, vcRef2, vcRefCob, viTpoSPEI, vcve_pago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('03','07') and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';

		IF NOT vmMonto <= vmMaximo THEN
			LET vcodretTemp  = '99998';
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de la validacion con consulta 
			/*IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN
				LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;*/
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vRechazo = 'S'; 
			continue FOREACH;
		END IF;
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Asignacion de sucursal del parametro 12 a vcSucursal para sustituir consulta a BD y comentarizacion de consulta.
		--SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '20';
			LET vcSucursal = vcSucursalParam12;
			--Se agrega al select que consulte el tipo de persona.
			SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc, tpo_persona INTO vcNombreCliente, vcRFC, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
				IF vcNombreCliente IS NULL OR vcNombreCliente='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
					SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreCliente FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente;
				END IF;
		LET vcFolioSuc = vcPrefijo  || vcHHMMSSFolio || vcTransucSPEI; 
		SELECT LIMIT 1 nombre, cve_cuenta, rfc	INTO vcNombreBen, vcCveCtaBen, vcRFCBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest and cve_banco = vcBancoDest;
		LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
		LET vcMsgError = 'Error ejecutando el SP: bdispei:sp_regordenctecte.';
		BEGIN WORK;
		LET vcAplicaRollback = 'S';
		LET vcCveCtaOri = '40'; -- 40-CLABE 3- TDD.
		IF vcCveCtaBen = '02' THEN  -- CUENTA DE CHEQUES.
			LET vcCveCtaBen = '40';
			IF LENGTH (vcNoCuentaDest) <> 18 THEN 
				LET vcCuentaInvalida = 'S';
				LET vcCveMensajes = '208';
			END IF;
		END IF;
		IF vcCveCtaBen = '03' THEN  -- TARJETA DE DEBITO.
			IF LENGTH (vcNoCuentaDest) <> 16 THEN
				LET vcCuentaInvalida = 'S';
				LET vcCveMensajes = '209';
			END IF;
		END IF;
		IF LENGTH(vcNoCuentaOri) <> 11 THEN
			LET vcCuentaInvalida = 'S';
			LET vcCveMensajes = '210';
		END IF;
	    SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)} cvecesif, descripcion INTO vcBancoDest2, vcNomBancoDest FROM bdinteg:"informix".si_bancos WHERE banco = vcBancoDest ;
        IF vcBancoDest2 IS NULL THEN
		LET vcBancoDest2 = 0;
        END IF;
		--RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG
        --SELECT sdo_actual - sdo_retenido - sdo_cong - imp_chq_sbg, producto
                  --INTO vsdo_cta, vproducto
		SELECT sdo_actual,sdo_retenido,sdo_cong,imp_chq_sbg,saldo_sbc, producto
                  INTO mSdoActual,mSdoRetenido,mSdoCong,mImpChqSbg,mSaldoSBC,vproducto
                  FROM bdicheq:"informix".sc_maechq
                 WHERE cuenta = vcNoCuentaOri
                   AND empresa = '001';
				   
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,mImpChqSbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_cta;        
		
		LET vcDescPago = 'POR SPEI';
		IF vproducto in ("1300", "1400", "1700", "2600","2700") or vcve_pago = '07' THEN
		   LET vmpComisionSPEI = 0;
		   LET vcpImpIvaSpei   = 0;
		else
		   LET vmpComisionSPEI = 0;
		   LET vcpImpIvaSpei   = 0;
		END IF;
        IF vcve_pago = '07' THEN
			LET vcDescPago = 'PORTABILIDAD DE NOMINA';
            --LET vcRef1 = 'PORTABILIDAD NOMINA ' || vcRef1;
            LET vcRef1 = 'PORTABILIDAD DE NOMINA ';
        END IF;
        LET vmto_total = vmMonto + vmpComisionSPEI + vcpImpIvaSpei;
        IF vcCuentaInvalida <> 'S' THEN
           IF vsdo_cta >= vmto_total THEN
                CALL bdispei:"informix".sp_regordenctecte_pp ( '001', vcSucursal, pcUsuario, vcBancoDest2, vmMonto,	vcTransucSPEI, vcFolioSuc, pdFecha, vmpComisionSPEI, vcpImpIvaSpei, vcNombreCliente, vcCveCtaOri, vcNoCuentaOri, vcRFC, vcNombreBen, vcCveCtaBen, vcNoCuentaDest, vcRFCBen, vcRef1, vmImporteIVA, vcRef2, vcRefCob) 
				RETURNING vcodretTemp, vcMensaje, vcCveRastreoSPEI;
                LET vcMensajeSP = vcMensaje;
                LET vCuantosEnviados = vCuantosEnviados + 1;
            ELSE 
				IF vcve_pago = '07' AND vsdo_cta > 0.00 THEN
					LET vmto_total = (vsdo_cta - vmpComisionSPEI - vcpImpIvaSpei) + vmpComisionSPEI + vcpImpIvaSpei ;
					IF vsdo_cta >= vmto_total THEN
					   LET vmMonto = vsdo_cta - vmpComisionSPEI - vcpImpIvaSpei;
						CALL bdispei:"informix".sp_regordenctecte_pp ( '001', vcSucursal, pcUsuario, vcBancoDest2, vmMonto,	vcTransucSPEI, vcFolioSuc, pdFecha, vmpComisionSPEI, vcpImpIvaSpei, vcNombreCliente, vcCveCtaOri, vcNoCuentaOri, vcRFC, vcNombreBen, vcCveCtaBen, vcNoCuentaDest, vcRFCBen, vcRef1, vmImporteIVA, vcRef2, vcRefCob) 
						RETURNING vcodretTemp, vcMensaje, vcCveRastreoSPEI;
						LET vcMensajeSP = vcMensaje;
						LET vCuantosEnviados = vCuantosEnviados + 1;
				    ELSE 
					    LET vcMensajeSP = 'FONDOS INSUFICIENTES';
                        LET vcodretTemp = '400';
				        LET vcMensaje = 'FONDOS INSUFICIENTES';	
					END IF;
				ELSE
                    LET vcMensajeSP = 'FONDOS INSUFICIENTES';
                    LET vcodretTemp = '400';
				    LET vcMensaje = 'FONDOS INSUFICIENTES';				
				END IF;
            END IF;
			IF trim(vcodretTemp) = '000' THEN
				IF viTpoSPEI = 1 THEN
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSuc
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
					IF 	vcve_pago = '03' THEN -- ALERTA AL EMISOR
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
						vcNoCuentaOri, vcNoCuentaDest, vcNomBancoDest, vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSuc, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					END IF;	
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIARIO
						IF vcnotificaben = '02' THEN	
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamanio variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;									
				ELSE
					LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
					SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '101';
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcCodRet) ) THEN
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcCodRet),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET estado = '06', cve_rechazo = trim(vcCodRet)
					WHERE cve_pagoprog = vcCveProg and fecha_prog  = pdFecha;
				END IF;
			ELSE
				-- ERROR CONTROLADO.
				LET vRechazo = 'S'; 
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						select descripcion into vcMensaje from bdinteg:"informix".si_codret where codigo_retorno  = trim(vcodretTemp) and sistema = '21';
						IF vcMensaje IS NULL THEN
							select descripcion into vcMensaje from bdinteg:"informix".si_codret where codigo_retorno  = trim(vcodretTemp) and sistema = '01';
							IF vcMensaje is NULL THEN
								LET vcMensaje = vcMensajeSP;
							END IF;
						END IF;
						LET vcMensaje = vcMensaje;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				ELSE -- ERROR DE INFORMIX
					INSERT INTO bdiprog:"informix".pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
                    		LET vcFlgError='1';
					-- PENDIENTE POSIBLE UNA REVERSION DE CARGO.
				END IF;
			END IF;
		ELSE
			SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, NVL(desc_mensaje,'') INTO vcodretTemp, vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = TRIM(vcCveMensajes);
			LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
			IF (vcodretTemp is null) THEN
				IF vcMensaje is NULL THEN
					LET vcodretTemp  = '000';
					LET vcMensaje = vcMensajeSP;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
				END IF;
			ELSE
				IF vcMensaje IS NULL THEN
					LET vcMensaje = 'ERROR EN LA EJECUCION DEL SP CARGO_REF';
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
				ELSE
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						LET vcMensaje =  vcMensaje;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMensaje,pcUsuario,CURRENT::DATE);
					END IF;
				END IF;
			END IF;
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = TRIM(vcodretTemp)
			WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vcCuentaInvalida = 'N';
		END IF;
		IF vRechazo = 'S' THEN 
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMensaje, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF 	vcve_pago = '03'  AND vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;		
				
				-- 184- Se agrega envio de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
			
			END IF;	
		END IF;
		LET vcAplicaRollback = 'N';
		COMMIT WORK;

		IF vCuantosEnviados >= cBloquePagos THEN
			LET vCuantosEnviados = 0;
	        LET cSQL = 'sleep ' || cSegsEspera;
	        SYSTEM TRIM(cSql);
		END IF;

	END FOREACH;

	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranAbonoCred  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '14';  -- transaccion abono para credito.
    SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '05'; -- Transacc Cargo Pago tarjeta de credito Bancoppel
	LET vcHHMMSSFolio 	   =   vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
	LET vcHHMMSSFolioAbono =   vcHHMMSSFolio; 
	
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12'; --> Clave de pago 05
	FOREACH with hold		
		SELECT pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cuenta_destino, pagoprog.descripcion, pagoprog.importe, pagopend.consecutivo, pagoprog.tipo_spei, pagoprog.cve_pago, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
		INTO            vcCveProg, vcNoCliente, vcNoCuentaOri,vcNoCuentaDest, vcConcepto, vmMonto, viConsecutivo,viTipo_spei, vcTipoPago, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
		FROM bdiprog:"informix".pp_pagoprog pagoprog
		INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago = '05' and pagopend.fecha_prog = pdFecha
		LET vmMaximo = '999999999999.99';
		LET vRechazo = 'N';		
-- Pago de Tarjeta de Credito Bancoppel
--	2013.11.01 FRG-I	--	Validacion disponibilidad Sistemas (bdicred):
	if IndCrreCred <> '1'
		then
			LET vcCodRet = '00006';
			LET vcMsgError = 'Sistema CREDITO No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parametros con apoyo de MO/JG');
			LET IndsCred = '1';
			continue FOREACH;
		else
			if IndDispCred <> '1'
				then
					LET vcCodRet = '00007';
					LET vcMensaje = 'Sistema CREDITO Temporalmente Fuera de Servicio.';
					LET vcMsgError = vcMensaje;
					INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
					VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parametros con apoyo de MO/JG');
					LET IndsCred = '1';
					continue FOREACH;
				else
			end if;
	end if;
--	2013.11.01 FRG-F

		SELECT num_credito, numcte INTO vcNumCredito,vcNoCliente2 FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = vcNoCuentaDest; 
		
		IF viTipo_spei = 2 THEN			
			call bdicred:"informix".sp_consultasaldocortemin('001',vcNumCredito,3)
			RETURNING vcodretTemp, vmMonto;  
			
			IF vcodretTemp <> '00000' THEN
				LET vcMensaje = 'sp_consultasaldocortemin   ' || vcNumCredito;
				LET vcMsgError = vcMensaje;
				INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
				VALUES(vcodretTemp, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));				
			END IF;
			
		ELIF viTipo_spei = 3 THEN
			LET vporce = vmMonto;				
			call bdicred:"informix".sp_consultasaldocorte('001',vcNumCredito,0)
			RETURNING vcodretTemp,vmMonto;
			
			IF vcodretTemp <> '00000' THEN
				LET vcMensaje = 'sp_consultasaldocorte   ' || vcNumCredito;
				LET vcMsgError = vcMensaje;
				INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
				VALUES(vcodretTemp, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));				
			END IF;
			
			LET vmMonto =  vmMonto * (vporce / 100);			 
		END IF;
		
		LET vcDescPago = 'A TARJETA DE CREDITO BANCOPPEL';
		IF  (vmMonto <= 0 or vmMonto is null) THEN
			LET vcodretTemp  = '99997';
			LET vcMsgError = 'El Importe a Pagar  es Igual a Cero';	
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de la validacion con consulta 
			/* IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99997' ) THEN 
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF; */
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99997'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;							
			continue FOREACH;
		END IF;
		IF NOT vmMonto <= vmMaximo THEN
			LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';		
			LET vcodretTemp  = '99998';
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de la validacion con consulta 
			/*IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN 
				INSERT INTO bdiprog:"informix".pp_tprechazo
				VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
			END IF;*/
			UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						
			continue FOREACH;
		END IF;
		BEGIN WORK;
		LET vcAplicaRollback = 'S';
		--Se agrega al select que consulte el tipo de persona.
		SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), tpo_persona INTO vcNombreBen, vcTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente2;			
			--Si el nombre esta vacio y es tipo de persona es 02 o 04, consulta la razon social.
			IF vcNombreBen IS NULL OR vcNombreBen='' AND (vcTipoPersona='02' OR vcTipoPersona='04') THEN 
				SELECT {+INDEX (bdinteg:"informix".si_cliente 224_479)} razon_social INTO vcNombreBen FROM bdinteg:"informix".si_cliente WHERE numcte = vcNoCliente2;			END IF;
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Asignacion de sucursal del parametro 12 a vcSucursal para sustituir consulta a BD y comentarizacion de consulta.
		--SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
			LET vcSucursal = vcSucursalParam12;
			SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente  AND tipo_tarjeta = 'T' AND status_tar = 'A';
		LET vcFolioSucCargo =  vcPrefijo  || vcHHMMSSFolio || vcTansacc; 
		LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
		LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
		LET vcMsgError = 'Trantando de ralizar cargo en Trans. de Credito.';
		CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTansacc, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
								RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
		IF TRIM(vcodretTemp) = '000' THEN
			LET vcAplicarReversionDebito = 'S';
			LET vcMsgError = 'Trantando de ralizar abono en Trans. de Credito.';
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Asignacion de sucursal del parametro 12 a vcSucursal para sustituir consulta a BD y comentarizacion de consulta.
			--SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
			LET vcSucursal = vcSucursalParam12;
			LET vcFolioSuc = vcPrefijo  || vcHHMMSSFolioAbono || vcTranAbonoCred;			--"inform" || replace (substring (current FROM 12  FOR 8 ), ':', '')  || vcTranAbonoCred;
			LET vcHHMMSSFolioAbono = LPAD(vcHHMMSSFolioAbono + 1,9,'0');
			LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
			CALL bdicred:"informix".principal('001', vcNumCredito, 1, vmMonto, pcUsuario, vcSucursal, vcFolioSucCargo, vcTranAbonoCred)
					   RETURNING vcodretTemp, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9; 
			IF trim(vcodretTemp) = '000' THEN
				UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
					LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));
							LET vidmensaje1 = 'PPG_TRAE';
							LET vcauxnotifica = '1';
						CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, vcNoTarjeta , '1', 
						vcNoCuentaOri, vcNoCuentaDest, 'BANCOPPEL, S.A.', vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
						vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
					IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIRARIO
						IF vcnotificaben = '02' THEN
							LET vidmensaje1 = 'PPG_TRABS';
							LET vcAux = vcbencelular; -- Revisar tamanio variable vcAux
							LET vcauxnotifica = '2';
						ELIF vcnotificaben = '01' OR vcnotifica = '03' THEN
							LET vidmensaje1 = 'PPG_TRABE';
							LET vcAux = vcbenemail;
							LET vcauxnotifica = '1';
						END IF;
					END IF;				
			ELSE
				-- HACER REVERSA DEL CARGO REALIZADO .
				LET vRechazo = 'S'; 
				call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario, vcFolioSucCargo, 'A') 
				RETURNING vcCodRetReverso;
				-- ERROR CONTROLADO
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
						IF vcMsgError IS NULL THEN
							LET vcMsgError = 'ERROR AL EJECUTAR EL ABONO_CRED';
						END IF;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				ELSE
					INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
					VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
				END IF;
			END IF;
		ELSE
			-- ERRROR CONTROLADO DE CARGOREF.
			LET vRechazo = 'S'; 
			IF TRIM(vcodretTemp) > 0 THEN
				IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
					SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
					IF vcMsgError IS NULL THEN
							LET vcMsgError = 'ERROR AL EJECUTAR EL CARGO_REF';
						END IF;
					INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
				END IF;
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
				WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
      		ELSE 
				INSERT INTO bdiprog:pp_errores( cod_error, descripcion, fecha, hora)
				VALUES( vcodretTemp, 'ERROR DE INFORMIX.', CURRENT::DATE,  CURRENT hour to fraction(3));
			END IF;
		END IF;
		IF vRechazo = 'S' THEN 
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
		END IF;
		IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg and estado = '03' ) THEN
		-- SE ACTUALIZA EL CAMPO cve_estado (FINALIZADO).
			UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
			IF vccve_programa <> '04' THEN
				LET vidmensaje1 = 'PPG_FINE';
				LET vcauxnotifica = '1';
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes		

				-- 184- Se agrega envio de notificacion SMS al telefono celular del cliente.	
				SELECT NVL(TRIM(emi_celular), '')
				INTO vcemicel
				FROM bdiprog:"informix".pp_pagoprog
				WHERE cve_pagoprog = vcCveProg;
				
				IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
					(
						'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
						'', '1', '', '', '', 
						'', '', '', '', '', 
						'', '', '', vcemicel, vmMonto, 
						0.00, 0.00, 0.00, 0.00, CURRENT, 
						''
					)INTO vcodretTemp;
					
				END IF;
				
			END IF;
		END IF;
		LET vcAplicaRollback = 'N';
		COMMIT WORK;
	END FOREACH;
    LET vCvePago_ant = '';
    LET vcBancoDest_ant = 0;
	LET vcHHMMSSFolio 		=  vcSufijo || replace (substring (current FROM 12  FOR 8 ), ':', '');
    LET vcHHMMSSFolioAbono  =  vcHHMMSSFolio; 
    LET vcMsgError = 'EMPIEZA PGO SERVICIO.';
	--Pago de Servicios 
--	2013.11.01 FRG-I
	if IndCrreSrvs <> '1'
		then
			LET vcCodRet = '00003';
			LET vcMensaje = 'Sistema SERVICIOS No Disponible.';
			LET vcMsgError = vcMensaje;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));					
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parametros con apoyo de MO/JG');
			RETURN vcCodRet, vcMensaje;
	end if;
	
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Adicion de parametros requeridos para el Pago de Servicio Telmex Modificacion realizada 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestinoTelmex FROM bdiprog:"informix".pp_parametros WHERE cve_param = '11'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucTelmex FROM bdisac:"informix".sac_param  WHERE empresa='001' AND cod_param = '82011'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargoTelmex FROM bdiprog:"informix".pp_parametros WHERE cve_param = '16'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbonoTelmex FROM bdiprog:"informix".pp_parametros WHERE cve_param = '17'; 
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Adicion de parametros requeridos para el Pago de Servicio Sky Modificacion realizada
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestinoSky FROM bdiprog:"informix".pp_parametros WHERE cve_param = '31'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursalSky FROM bdiprog:"informix".pp_parametros WHERE cve_param = '34'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucSky FROM bdiprog:"informix".pp_parametros WHERE cve_param = '35'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargoSky FROM bdiprog:"informix".pp_parametros WHERE cve_param = '32'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbonoSky FROM bdiprog:"informix".pp_parametros WHERE cve_param = '33'; 
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Adicion de parametros requeridos para el pago de Servicio Dish Modificacion realizada
		SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
		INTO vcCtaDestinoDish,vcTranSucDish,vcTansacCargoDish,vcTansacAbonoDish
		FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '002';
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Adicion de parametros requeridos para el pago de Servicio MasTV Modificacion realizada
		SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
		INTO vcCtaDestinoMasTV,vcTranSucMasTV,vcTansacCargoMasTV,vcTansacAbonoMasTV
		FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '003';
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Adicion de parametros requeridos para el pago a Otro Banco Modificacion realizada
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestinoOtroBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '43';
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursalOtroBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '44'; 
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargoOtroBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '42';
		SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbonoOtroBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '41';

--	2013.11.01 FRG-F
	FOREACH with hold
			SELECT pagoprog.cve_pago,pagoprog.cve_pagoprog, pagoprog.num_cte, pagoprog.cuenta_origen, pagoprog.cve_cuenta_ori, pagoprog.cuenta_destino, pagoprog.descripcion, pagoprog.importe,  pagoprog.banco_destino, pagoprog.referencia1, pagoprog.referencia2, pagoprog.convenio,pagoprog.descripcion, pagoprog.cve_notifica_emi, pagoprog.cve_notifica, pagoprog.ben_email, pagoprog.ben_celular, pagoprog.cve_programa
			INTO  vCvePago,vcCveProg, vcNoCliente, vcNoCuentaOri, vcCveCtaOri,  vcNoCuentaDest, vcConcepto, vmMonto , vcBancoDest, vcRef1,vcRef2,vcConvenio,vcDescripcion, vcnotifica, vcnotificaben, vcbenemail, vcbencelular, vccve_programa
			FROM bdiprog:"informix".pp_pagoprog pagoprog
			INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog and pagopend.estado = '03' and pagoprog.cve_pago in ('04','06') and pagopend.fecha_prog = pdFecha
			order by pagoprog.cve_pago

			LET vmMaximo = '999999999999.99';
			LET vRechazo = 'N';
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Recolocacion de la siguiente asignacion ya que siempre es la misma sentencia
			LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);
			IF vcBancoDest = '000' THEN
			LET vcBancoDest ='201';
			END IF;
				LET vcNombreBen='';
				IF  (vCvePago = '04' AND vcBancoDest = '201')  THEN --PAGO DE SERVICIO TELMEX 
					--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de consultas que ya se encuentran fuera del foreach y asignacion de variables nuevas, con el fin de reducir el numero de consultas por operacion
					LET vcDescPago = 'PAGO DE SERVICIO TELMEX'; 
					LET vcCtaDestino = vcCtaDestinoTelmex;
					LET vcSucursal = vcSucursalParam12;
					LET vcTranSucPagoServ = vcTranSucTelmex; 
					LET vcTansacCargo = vcTansacCargoTelmex;
					LET vcTansacAbono = vcTansacAbonoTelmex;
					/*SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '11'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucTelmex FROM bdisac:"informix".sac_param  WHERE empresa='001' AND cod_param = '82011'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '16'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '17'; 
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29); */
				ELIF (vCvePago = '04' AND vcBancoDest = '601') THEN--PAGO DE SERVICIO SKY
					--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de consultas que ya se encuentran fuera del foreach y asignacion de variables nuevas, con el fin de reducir el numero de consultas por operacion
					LET vcDescPago = 'PAGO DE SERVICIO SKY';
					LET vcCtaDestino = vcCtaDestinoSky;
					LET vcSucursal = vcSucursalSky;
					LET vcTranSucPagoServ = vcTranSucSky;
					LET vcTansacCargo = vcTansacCargoSky;
					LET vcTansacAbono = vcTansacAbonoSky;
					/*SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '31'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '34'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranSucTelmex FROM bdiprog:"informix".pp_parametros WHERE cve_param = '35'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '32'; 
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '33'; 									
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);*/
				ELIF (vCvePago = '04' AND vcBancoDest = '602') THEN--PAGO DE SERVICIO DISH
					--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de consulta que ya se encuentra fuera del foreach y asignacion de variables nuevas, con el fin de reducir el numero de consultas por operacion
					LET vcDescPago = 'PAGO DE SERVICIO DISH';
					LET vcCtaDestino = vcCtaDestinoDish;
					LET vcSucursal = vcSucursalParam12;
					LET vcTranSucPagoServ = vcTranSucDish;
					LET vcTansacCargo = vcTansacCargoDish;
					LET vcTansacAbono = vcTansacAbonoDish;
					/*SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
					 INTO vcCtaDestino,vcTranSucTelmex,vcTansacCargo,vcTansacAbono --> vcCtaDestinoDish,vcTranSucDish,vcTansacCargoDish,vcTansacAbonoDish
					 FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '002';
					 SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);					*/
				ELIF (vCvePago = '04' AND vcBancoDest = '603') THEN--PAGO DE SERVICIO 
					--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de consultasque ya se encuentra fuera del foreach y asignacion de variables nuevas, con el fin de reducir el numero de consultas por operacion
					LET vcDescPago = 'PAGO DE SERVICIO MASTV';
					LET vcCtaDestino = vcCtaDestinoMasTV;
					LET vcSucursal = vcSucursalParam12;
					LET vcTranSucPagoServ = vcTranSucMasTV;
					LET vcTansacCargo = vcTansacCargoMasTV;
					LET vcTansacAbono = vcTansacAbonoMasTV;
					 /*SELECT cuenta_prestadora,trans_suc_cargo,trans_cen_cargo_cliente,trans_cen_abono_convenio 
					 INTO vcCtaDestino,vcTranSucTelmex,vcTansacCargo,vcTansacAbono --> vcCtaDestinoMasTV,vcTranSucMasTV,vcTansacCargoMasTV,vcTansacAbonoMasTV
					 FROM bdisac:"informix".sac_convenios WHERE numcategoria = '06' and numconvenio = '003';
					 SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
					LET vcReferencia = 'Trans.Prog.' || SUBSTR(vcConcepto,1,29);			*/
				ELIF (vCvePago = '06' ) THEN --PAGO TARJETA CREDITO OTRO BANCO
					--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de consultas que ya se encuentran fuera del foreach y asignacion de variables nuevas, con el fin de reducir el numero de consultas por operacion
					LET vcDescPago = 'A TARJETA DE CRED. OTRO BANCO';
					LET vcCtaDestino = vcCtaDestinoOtroBanco;
					LET vcSucursal = vcSucursalOtroBanco;
					LET vcTansacCargo = vcTansacCargoOtroBanco;
					LET vcTansacAbono = vcTansacAbonoOtroBanco;
					SELECT LIMIT 1 nombre INTO vcNombreBen FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = vcNoCliente and cuenta = vcNoCuentaDest;			
					/*SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} desc_valor INTO vcCtaDestino FROM bdiprog:"informix".pp_parametros WHERE cve_param = '43';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '44';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacCargo FROM bdiprog:"informix".pp_parametros WHERE cve_param = '42';
					SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacAbono FROM bdiprog:"informix".pp_parametros WHERE cve_param = '41';*/
					IF LENGTH(trim(vcNoCuentaDest)) = 15 THEN
						LET vcReferencia = '0' || trim(vcNoCuentaDest);
					ELSE 	
						LET vcReferencia = trim(vcNoCuentaDest);
					END IF;	
				END IF;
				LET  vCvePago_ant =  vCvePago;
				LET  vcBancoDest_ant =  vcBancoDest;					
				SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)} descripcion INTO vcNomBancoDest FROM bdinteg:"informix".si_bancos WHERE banco = vcBancoDest ;
			IF NOT vmMonto <= vmMaximo THEN
				LET vcodretTemp  = '99998';
				--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion de la validacion con consulta
				 /*IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = '99998' ) THEN 
					 LET vcMsgError = 'Importe demasiado grande para realizar un Pago Programado';
					 INSERT INTO bdiprog:"informix".pp_tprechazo
					 VALUES (vcodretTemp,vcMsgError,pcUsuario,CURRENT::DATE);
				 END IF;*/
				LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
				UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06',  cve_rechazo = '99998'  WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
				continue FOREACH;
			END IF;
			BEGIN WORK;
			LET vcAplicaRollback = 'S';
			SELECT NVL(num_tarjeta,'') INTO vcNoTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = vcNoCuentaOri AND numcte = vcNoCliente  AND tipo_tarjeta = 'T' AND status_tar = 'A';
			LET vcFolioSucCargo =   vcPrefijo || vcHHMMSSFolio || vcTansacCargo;  
			LET vcHHMMSSFolio = LPAD(vcHHMMSSFolio + 1,9,'0');
			LET vcAplicarReversionDebito = 'S';
			CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTansacCargo, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
									RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
			IF trim(vcodretTemp) = '000' THEN
				LET vcNoTarjeta = '';
				LET vcFolioSuc =  'inform' || replace (substring (current FROM 12  FOR 8 ), ':', '')  || vcTansacCargo;
				LET vcFolioSuc =  vcPrefijo  || vcHHMMSSFolioAbono || vcTansacAbono; 
				LET vcHHMMSSFolioAbono = LPAD(vcHHMMSSFolioAbono + 1,9,'0');
				LET vcAplicarReversionDebitoAbono = 'S';
				CALL bdicheq:"informix".abono_ref( '001', vcSucursal, pcUsuario, vcTansacAbono, vcTransuc, vcFolioSucCargo, trim(vcCtaDestino), 0.00, vmMonto, vmMonto, 0.00, 0.00, 0, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
										RETURNING vcodretTemp;
					IF trim(vcodretTemp) = '000' THEN
							-- SE ENVIA ALERTA DE PAGO CORRECTO
							LET vImporte2 = trim (to_char(vmMonto,"###,###,###,###.##"));						
									LET vcauxnotifica = '1';
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAE';
									ELSE	
										LET vidmensaje1 = 'PPG_SERE';
									END IF
								CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
								vcNoCuentaOri, vcNoCuentaDest, vcNomBancoDest, vcDescPago, vcNombreBen, vcConcepto, vImporte2, vcFolioSucCargo, '', '', '', '',  -- strings
								vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
							IF  vcnotificaben <> '00' THEN -- ALERTA AL BENEFICIARIO
								IF vcnotifica = '02' THEN
									LET vcauxnotifica = '2';	
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAS';
									ELSE	
										LET vidmensaje1 = 'PPG_SERS';
									END IF
								ELIF vcnotifica = '01' OR vcnotifica = '03' THEN
									LET vcauxnotifica = '1';
									IF (vCvePago = '06' ) THEN	
										LET vidmensaje1 = 'PPG_TRAE';
									ELSE	
										LET vidmensaje1 = 'PPG_SERE';
									END IF
								END IF;
							END IF;				
						LET vcCategoria = SUBSTR(vcConvenio,1,2);
						SELECT flgporccomtrans_conv,  porc_com_trans_conv,   flgimpcomtrans_conv,   imp_com_trans_conv , iva_convenio,    flgporccomtrans_cte,   porc_com_trans_cte,   flgimpcomtrans_cte,   imp_com_trans_cte
						INTO  vcFlgporccomtrans_conv,vdPorc_com_trans_conv, vcFlgimpcomtrans_conv, vdImp_com_trans_conv , viIvaConvenio, vcFlgporccomtrans_cte, vmPorc_com_trans_cte, vcFlgimpcomtrans_cte, vmImp_com_trans_cte
						FROM bdisac:"informix".sac_convenios
						WHERE numcategoria = substr(vcConvenio,1,2) and numconvenio = substr(vcConvenio,3,5);
						LET vcConvenio = SUBSTR(vcConvenio,3,3);
						IF vcFlgporccomtrans_conv = '1' and vcFlgimpcomtrans_conv = '0' THEN
							LET deImpComisionConvenio =  ((vdPorc_com_trans_conv * vmMonto) / 100);
							LET deIvaComisionConvenio =  ((deImpComisionConvenio * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_conv = '1' and vcFlgporccomtrans_conv = '0' THEN
							LET deImpComisionConvenio = vdImp_com_trans_conv;
							LET deIvaComisionConvenio = (( deImpComisionConvenio * viIvaConvenio) / 100 );
						ELIF vcFlgporccomtrans_conv = '0' and vcFlgimpcomtrans_conv = '0' THEN
							LET deImpComisionConvenio = 0.00;
							LET deIvaComisionConvenio = 0.00;
						ELIF vcFlgporccomtrans_conv = '1' and vcFlgimpcomtrans_conv = '1' THEN 
						END IF;
						IF vcFlgporccomtrans_cte = '1' and vcFlgimpcomtrans_cte = '0' THEN
						LET deImpComisionCliente = (( vmPorc_com_trans_cte * vmMonto) / 100 );
						LET deIvaComisionCliente  = ((deImpComisionCliente * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_cte = '1' and vcFlgporccomtrans_cte = '0' THEN
						LET deImpComisionCliente = vmImp_com_trans_cte;
						LET deIvaComisionCliente  = ((deImpComisionCliente * viIvaConvenio) / 100 );
						ELIF vcFlgimpcomtrans_cte = '0' and vcFlgporccomtrans_cte = '0' THEN
						LET deImpComisionCliente = 0.00;
						LET deIvaComisionCliente  = 0.00;
						ELIF vcFlgimpcomtrans_cte = '1' and vcFlgporccomtrans_cte = '1' THEN 
						END IF;
						IF vCvePago = '04' THEN
							CALL bdisac:"informix".sp_GrabaPagoServicio (vcSucursal, vcCategoria, vcConvenio, vcRef1, vcRef2, '2', vmMonto, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, vcNoCuentaOri, pcUsuario, vcFolioSucCargo, vcTranSucPagoServ ,pdFecha)--Cambio de la variable vcTranSucTelmex a vcTranSucPagoServ
															RETURNING vcodretTemp;
							IF vcodretTemp = '00000' THEN
								UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo
								WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
							ELSE
								-- APLICAR REVERSION DE CARGO Y ABONO. 
								LET vRechazo = 'S'; 
								call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
								IF trim(vcodretTemp) > 0 THEN
									LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
									IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
										LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
										INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
									END IF;
									UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
									WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
								END IF;
							END IF;
						ELSE
							UPDATE bdiprog:"informix".pp_pagospend SET estado = '05', fecha_aplic = CURRENT::DATE, folio_suc = vcFolioSucCargo
							WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
						END IF 
					ELSE -- else abono_ref
						LET vRechazo = 'S'; 
						call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
						IF trim(vcodretTemp) > 0 THEN
							IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
								SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
								IF vcMsgError IS NULL THEN
									LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
								END IF;
								INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
							END IF;
							UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
							WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
						END IF;
					END IF;
			ELSE
				LET vRechazo = 'S'; -- Para controlar la alerta por rechazo.
				IF trim(vcodretTemp) > 0 THEN
					IF NOT EXISTS(SELECT cve_rechazo FROM bdiprog:"informix".pp_tprechazo WHERE cve_rechazo = trim(vcodretTemp) ) THEN
						SELECT descripcion INTO vcMsgError FROM bdinteg:"informix".si_codret WHERE codigo_retorno = trim(vcodretTemp) and sistema = '01';
						IF vcMsgError IS NULL THEN
							LET vcMsgError = 'Error controlado en bdisac:sp_GrabaPagoServicio.';
						END IF;
						INSERT INTO bdiprog:"informix".pp_tprechazo VALUES(trim(vcodretTemp),vcMsgError,pcUsuario,CURRENT::DATE);
					END IF;
					UPDATE bdiprog:"informix".pp_pagospend SET     estado = '06', cve_rechazo = vcodretTemp
					WHERE cve_pagoprog = vcCveProg AND fecha_prog = pdFecha;
				END IF;
			END IF;
			IF vRechazo = 'S' THEN -- Se dispara alerta por PPG Rechazado
				LET vidmensaje1 = 'PPG_RECHE';
				LET vcauxnotifica = '1';		
				CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
					vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  -- strings
					vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes
			END IF;
			IF NOT EXISTS( SELECT cve_pagoprog FROM bdiprog:"informix".pp_pagospend WHERE cve_pagoprog = vcCveProg AND estado = '03' ) THEN
			-- SE ACTUALIZA EL CAMPO cve_estado (FINALIZADO). 			--  NOTIFICACION DE CONCLUSION DE PROGRAMACION, EMAIL .... 
				UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg AND cve_estado <> '02';
				IF vCvePago = '06'  AND vccve_programa <> '04' THEN
					LET vidmensaje1 = 'PPG_FINE';
					LET vcauxnotifica = '1';
					CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
					vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
					vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes		

					-- 153 - Se agrega envio de notificacion SMS al telefono celular del cliente.	
					SELECT NVL(TRIM(emi_celular), '')
					INTO vcemicel
					FROM bdiprog:"informix".pp_pagoprog
					WHERE cve_pagoprog = vcCveProg;
					
					IF TRIM(vcemicel) <> ''  Or (vcemicel is not null) THEN
						
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
						(
							'1', 'SMS_FPG', 'SMS_FPG', vcNoCliente, vcNoCuentaOri,
							'', '1', '', '', '', 
							'', '', '', '', '', 
							'', '', '', vcemicel, vmMonto, 
							0.00, 0.00, 0.00, 0.00, CURRENT, 
							''
						)INTO vcodretTemp;
						
					END IF;
				
				END IF;	
			END IF;
			LET vcAplicaRollback = 'N';
			COMMIT WORK;
		END FOREACH;
    -- SI NO EXISTIERON ERRORES NO CONTROLADOS EN SPEI, TERMINA EL PROCESO CORRECTAMENTE.
    IF vcFlgError='0' THEN
--	2013.11.06 - FRG - i
--		IF vcStatus IS NULL THEN
		IF vcStatus IS NULL or vcStatus = '0' THEN
			IF flg_indicadores = '1'
				THEN
					UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '1' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
				ELSE
					IF vcStatus = '1' and flg_indicadores = '1' 
						THEN
							UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '2' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
						ELSE
							let vcCodRet = '99996';
							let vcMensaje = 'Sistema pendiente de cierre o temporalmente fuera de servicio. Validar.';
					END IF;	
			END IF;
--	2013.11.06 - FRG - f
		END IF;
	END IF;
	IF vtransaccion = 1 THEN
	   BEGIN WORK;
	END IF;
    IF vcFlgError='0' 
		THEN
			IF IndsCred <> '0' 
				THEN
					let vcCodRet = '99995';
					let vcMensaje = 'Sist. CREDITO Pend. Cierre o Temp. Fuera de Servicio.';
					RETURN vcCodRet,vcMensaje;
				ELSE
					SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '00';
					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PP_ET', pdFecha, '1', 'informix', 'sp_ejecutartransacciones', cDescripcionSPJ);
					RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
		RETURN '99999','ERROR EN LOS PAGOS PROGRAMADOS POR SPEI';
    END IF;
END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 153 - Validacion_CorreoTel_PagosProg',
'DESCRIPCION: Se modifica rango de campos relativos al e-mail tanto del emisor como del receptor ampliando su rango a 100 caracteres (parametro vcbenemail), se agrega consulta para obtener el correo alterno (parametro obligatorio al llamar al sp_registra_evento,',
'se agrega invocacion al procedimiento bdimnsj:"informix".sp_registra_evento',
'FECHA: 22/11/2016',
'BD: bdiprog',
'MODIFICO: Daniel Hernandez Garcia | Osiel Alfredo Camacho Mendoza',
'FECHA: 05-08-2025',
'MODIFICACION: Se modifican la forma de calcular el saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDIPROG',
'VERSION: 1.3';

CREATE PROCEDURE "informix".sps_consulta_ctasfrec_statuscta_bpi(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta
	 CHAR(100) as nombre, ---nombre
	 CHAR(50) as banco, ---banco
	 CHAR(2) as compania_cel, ---compaÃ±ia celular
	 CHAR(10) as celular, ---numero celular
	 CHAR(40) as correo_elec, ---correo electronico
	 CHAR(2) as cve_cuenta, ---cve cuenta
     CHAR(20) as desc_cuenta, ---desc cuenta
     CHAR(13) as rfc, ---rfc
	 MONEY(16,2) as monto_maximo,---Monto MÃ¡ximo
	 CHAR(1) as cve_caducidad, --- Tipo de caducidad
	 CHAR(5) as estatus, --Retorno del sp sc_cons_status_cta
	 CHAR(1) as activarBPI; -- Estatus de referencia bpi

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
	DEFINE v_ExisteCuenta		CHAR(20);
	DEFINE v_ActivaBPI			CHAR(1);
	DEFINE p_MontoMax			MONEY(16,2);

	--VARIABLES ESTATUS CTA
    DEFINE vCodRetStatus        CHAR(5);
    DEFINE vStatusCta          	CHAR(1);
	DEFINE vProductoCta			CHAR(4);
	
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
	LET v_CveCaducidad			= '';
	LET v_ExisteCuenta			= NULL;
	LET v_ActivaBPI				= "";
	
	--VARIABLES ESTATUS CTA
	LET vCodRetStatus   		= 	"000";
    LET vStatusCta    			= 	"";
	LET vProductoCta			=	"";
	
	LET p_MontoMax				= 200000.00;
-- SET DEBUG FILE TO '/ifxsif01/JuanRivera/traces/sps_consulta_ctasfrec_statuscta_bpi.out';
-- TRACE ON;	
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
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	-- SET DEBUG FILE TO "/home/c96120053/ArchivosOUT/sps_consulta_ctasfrec_statuscta_bpi.out";
	-- TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	SELECT banco|| "  " ||descripcion
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";


	IF ((p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL))  THEN
 		--IF EXISTS (SELECT bex.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
		--SELECT LIMIT 1 ct.cuenta INTO v_ExisteCuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta; 
		SELECT LIMIT 1 t.cuenta
		INTO v_ExisteCuenta
		FROM (SELECT ct.cuenta 
              FROM bdiprog:"informix".pp_ctasterceros ct
              left outer join bdiprog:"informix".pp_cuentapago cp on (ct.cve_cuenta = cp.cve_cuenta)
              WHERE ct.num_cte = p_NumCte
			UNION
			SELECT bex.cuenta
			FROM bdiprog:"informix".pp_ctasterceros_bex bex, bdiprog:"informix".pp_cuentapago cps 
			WHERE bex.num_cte = p_NumCte
			AND bex.cve_cuenta = cps.cve_cuenta
		) t;
		
		IF (v_ExisteCuenta IS NOT NULL) THEN

            IF (p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    --AND ct.cve_banco = '000'
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
					
					IF v_MontoMaximo= 0 THEN 
						LET v_MontoMaximo = p_MontoMax;
					END IF 

--                  LET v_ContReg = v_ContReg + 1;

--                  IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                       CONTINUE FOREACH;
--                    END IF;
					
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
					
					
					
                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, "", v_ActivaBPI  WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||b.descripcion, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad, '1' AS activaBPI
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad, v_ActivaBPI
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
					UNION
                   	SELECT bex.cuenta , bex.nombre, sb.banco|| "  " ||sb.descripcion, bex.cve_compania, bex.no_celular, bex.direc_correo, bex.cve_cuenta, bex.descrip_cta, bex.rfc, bex.canal_alta, bex.fecha_insert, bex.hora_insert, NVL(bex.monto_maximo,0) , bex.cve_caducidad, '0' AS activaBPI
                    FROM bdiprog:"informix".pp_ctasterceros_bex bex, bdinteg:"informix".si_bancos sb, bdiprog:"informix".pp_cuentapago cps
                    WHERE bex.num_cte = p_NumCte
					AND bex.cve_banco = sb.banco
                    AND bex.cve_cuenta = cps.cve_cuenta
                    AND cps.cve_pago = p_CvePago
                    AND bex.cve_estado = '01'
                    UNION
                    --SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','','1900-01-01'::date, current hour to second
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,' ',' ',' ','04','CUENTA PROPIA' ,' ',' ',mdy(1,1,1900), current hour to second,0, '0', '1' AS activaBPI
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY activaBPI ASC, ct.descrip_cta, ct.nombre
					
					
					IF v_MontoMaximo= 0 THEN 
						LET v_MontoMaximo = p_MontoMax;
					END IF 
					
--                    LET v_ContReg = v_ContReg + 1;

--                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                        CONTINUE FOREACH;
--                    END IF;
					
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
					
					IF v_Canal ='18' THEN
					
						IF (LEN(v_CtaDestino) = 16) THEN
						
						SELECT cuenta INTO v_CtaDestino from bdicheq:sc_tarjeta where num_tarjeta = v_CtaDestino;
						
						ELIF (LEN(v_CtaDestino) = 18) THEN
						
						SELECT cuenta INTO v_CtaDestino from bdicheq:sc_maechq where cuenta_clabe = v_CtaDestino;
						
						END IF;

					END IF;
					
					IF(p_CvePago<>"03")THEN
						EXECUTE PROCEDURE bdicheq:"informix".sc_cons_status_cta('001',v_CtaDestino) INTO vCodRetStatus, vStatusCta, vProductoCta;
					END IF;
									
					
                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo, v_CveCaducidad, NVL(vStatusCta,"")||NVL(vProductoCta,""), v_ActivaBPI  WITH RESUME;
                END FOREACH;
            END IF;
        ELSE
            --IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta Where numcte == p_NumCte )  THEN
			LET v_ExisteCuenta  = NULL;
			SELECT LIMIT 1 num_tarjeta INTO v_ExisteCuenta FROM bdicred:"informix".sd_tarjeta WHERE numcte == p_NumCte;
			
			IF(v_ExisteCuenta IS NOT NULL) THEN
                FOREACH
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,''
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago ="05"

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, "", v_ActivaBPI  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;

-- Se clona spl sp_ConsultaCuentasDestino y se agrega parÃ¡metro de salida para la clave de caducidad
-- Bibiana Gaxiola Verdugo
-- 18/12/2012
------------------------------------------------------------
-- Se agrega el retorno de cuentas frecuentes BanCoppel Express y se rempleza las sentencias (IF EXISTS)
-- Kenji Barriga Nonaka
-- 20/12/2018
---------------
-- Se agrega validaciÃ³n de monto 00
	-- Gabreial Aguilar
	-- 11/09/2020
END PROCEDURE;