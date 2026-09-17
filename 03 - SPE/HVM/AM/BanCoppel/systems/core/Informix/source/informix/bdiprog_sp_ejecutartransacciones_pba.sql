CREATE PROCEDURE "informix".sp_ejecutartransacciones_pba(pcEmpresa CHAR(3),	pdFecha DATE, pcCveCanal CHAR(2), pcUsuario CHAR(8))
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
DEFINE vcTansaccDest 	CHAR(4);
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
DEFINE vcTarifaSPEI		varchar(18,1);
DEFINE vcNombreCliente 	CHAR(100);
DEFINE vcNombreBen 		CHAR(100);
DEFINE vcRFC			CHAR(13);
DEFINE vcRFCBen			CHAR(13);
DEFINE vcCveCtaBen		CHAR(2);
DEFINE vcCveRastreoSPEI	CHAR(30);
DEFINE vcNumCredito		CHAR(20);
DEFINE vcCtaTelmex		CHAR(20);
DEFINE vcSucTelmex		CHAR(10);
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
DEFINE vtransaccion				integer;
DEFINE vcPrefijo				CHAR(3);
DEFINE vcSufijo				    CHAR(3);
DEFINE vcCveMensajes			CHAR(8);
DEFINE vcCuentaInvalida, vRechazo	CHAR(1);
DEFINE vcIvaSpei				CHAR(5);
DEFINE vcImpIvaSpei				CHAR(5);
DEFINE vcpImpIvaSpei			CHAR(5);
DEFINE vcLongImpor				INTEGER;
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
DEFINE vfecha_corte             DATE;
DEFINE vcnotifica, vcnotificaben CHAR(2);
DEFINE vcbenemail 				CHAR(40);
DEFINE vcbencelular  			CHAR(10);
DEFINE vcDescPago	  			CHAR(30);
DEFINE vImporte2	            CHAR(16);
DEFINE vcauxnotifica           	CHAR(1);
DEFINE vidmensaje1		 		CHAR(10);
DEFINE vcAux,vcNomBancoDest	 	CHAR(40);
DEFINE vmMAximo, vmMonto2, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9, vsdo_cta, vmto_total               MONEY(14,2);
DEFINE vcTipoPersona			CHAR(2);
--	2013.11.01 FRG-i	-	Se agrega validación de cierre procesos centrales por Proy. Indep. Sistemas.
DEFINE iSqlErr     				INTEGER;
DEFINE iIsamErr    				INTEGER;
DEFINE cInfoErr    				CHAR(100);
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

--	2013.11.01 FRG-f
	ON EXCEPTION SET sql_err
		LET vcCodRet = sql_err;
		IF  vcAplicaRollback = 'S' THEN
			ROLLBACK WORk;
		END IF;
		IF vcAplicarReversionDebito = 'S' THEN
			call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSucCargo, 'A') RETURNING vcCodRetReverso;
		END IF;
		IF vcAplicarReversionDebitoAbono = 'S' THEN
			call bdicheq:"informix".reversion('001', vcTransuc, pcUsuario , vcFolioSuc, 'A') RETURNING vcCodRetReverso;
		END IF;
			LET vcMsgError = 'ERROR AL EJECUTAR LA TRANSACCION';
			INSERT INTO bdiprog:"informix".pp_errores( cod_error, descripcion, fecha, hora)
			VALUES( vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
		RETURN vcCodRet,'ERROR EN INFORMIX.';
	END EXCEPTION;
	on exception in (-535)
	  let vtransaccion = 1;
	end exception with resume;
--	2013.11.01 FRG-i


			--	SET DEBUG FILE TO '/informix/tmp/ejecuta_trans.out';
			--	TRACE ON;				


LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET cInfoErr    	= '';
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
--	2013.11.01 FRG-I --	Validación disponibilidad Sistemas (bdicheq):
	if IndCrreChqs <> '1'
		then
			LET vcCodRet = '00004';
			LET vcMsgError = 'Sistema CHEQUES No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
			RETURN vcCodRet, vcMensaje;
		else
			if IndDispChqs <> '1'
				then
					LET vcCodRet = '00005';
					LET vcMensaje = 'Sistema CHEQUES Temporalmente Fuera de Servicio.';
					LET vcMsgError = vcMensaje;
					INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
					VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
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
			continue FOREACH;
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
							LET vcAux = vcbencelular; -- Revisar tamaño variable vcAux
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
		IF vcCveCtaBen = '03' THEN  -- TARJETA DE DÉBITO.
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
        SELECT sdo_actual - sdo_retenido - sdo_cong - imp_chq_sbg, producto
                  INTO vsdo_cta, vproducto
                  FROM bdicheq:"informix".sc_maechq
                 WHERE cuenta = vcNoCuentaOri
                   AND empresa = '001';
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
            LET vcRef1 = 'PORTABILIDAD NOMINA ' || vcRef1;
        END IF;
        LET vmto_total = vmMonto + vmpComisionSPEI + vcpImpIvaSpei;
        IF vcCuentaInvalida <> 'S' THEN
            IF vsdo_cta >= vmto_total THEN
                CALL bdispei:"informix".sp_regordenctecte_pp ( '001', vcSucursal, pcUsuario, vcBancoDest2, vmMonto,	vcTransucSPEI, vcFolioSuc, pdFecha, vmpComisionSPEI, vcpImpIvaSpei, vcNombreCliente, vcCveCtaOri, vcNoCuentaOri, vcRFC, vcNombreBen, vcCveCtaBen, vcNoCuentaDest, vcRFCBen, vcRef1, vmImporteIVA, vcRef2, vcRefCob) 
				RETURNING vcodretTemp, vcMensaje, vcCveRastreoSPEI;
                LET vcMensajeSP = vcMensaje;
            ELSE
                LET vcMensajeSP = 'FONDOS INSUFICIENTES';
                LET vcodretTemp = '400';
				LET vcMensaje = 'FONDOS INSUFICIENTES';
            END IF
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
							LET vcAux = vcbencelular; -- Revisar tamaño variable vcAux
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
					LET vcMensaje = 'ERROR EN LA EJECUCIÓN DEL SP CARGO_REF';
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
			END IF;	
		END IF;
		LET vcAplicaRollback = 'N';
		COMMIT WORK;
	END FOREACH;
	SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTranAbonoCred  FROM bdiprog:"informix".pp_parametros WHERE cve_param = '14';  -- transaccion abono para crédito.
    SELECT {+INDEX (bdiprog:"informix".pp_parametros 109_50)} valor INTO vcTansacc FROM bdiprog:"informix".pp_parametros WHERE cve_param = '05'; -- Transacc Cargo Pago tarjeta de crédito Bancoppel
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
--	2013.11.01 FRG-I	--	Validación disponibilidad Sistemas (bdicred):
	if IndCrreCred <> '1'
		then
			LET vcCodRet = '00006';
			LET vcMsgError = 'Sistema CREDITO No Disponible.';
			LET vcMensaje = vcMsgError;
			INSERT INTO bdiprog:"informix".pp_errores(cod_error, descripcion, fecha, hora)
			VALUES(vcCodRet, vcMsgError, CURRENT::DATE,  CURRENT hour to fraction(3));
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
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
--					EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
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
			LET vidmensaje1 = 'PPG_RECHE';
			LET vcauxnotifica = '1';		
			CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
				vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, vcMsgError, vcConcepto, '', '', '', '', '', '',  
				vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						
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
		LET vcMsgError = 'Trantando de ralizar cargo en Trans. de Crédito.';
		CALL bdicheq:"informix".cargo_ref( '001', vcSucursal, pcUsuario, vcTansacc, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, viCheque, vmMonto, vcDivisa, vcReferencia, vcNoTarjeta, pcUsuario)
								RETURNING vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
		IF TRIM(vcodretTemp) = '000' THEN
			LET vcAplicarReversionDebito = 'S';
			LET vcMsgError = 'Trantando de ralizar abono en Trans. de Crédito.';
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
							LET vcAux = vcbencelular; -- Revisar tamaño variable vcAux
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
--			EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
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
					WHERE cve_pagoprog = vcCveProg and fecha_prog = pdFecha;
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
			-- SE ACTUALIZA EL CAMPO cve_estado (FINALIZADO). 			--  NOTIFICACION DE CONCLUSION DE PROGRAMACION, EMAIL .... 
				UPDATE bdiprog:"informix".pp_pagoprog SET cve_estado = '04' WHERE cve_pagoprog = vcCveProg and cve_estado <> '02';
				IF vCvePago = '06'  AND vccve_programa <> '04' THEN
					LET vidmensaje1 = 'PPG_FINE';
					LET vcauxnotifica = '1';
					CALL bdimnsj:"informix".sp_registra_evento (vcauxnotifica , vidmensaje1, vcNoCliente, vcNoCuentaOri, '' , '1', 
					vcNoCuentaOri, vcNoCuentaDest, '', vcDescPago, '', vcConcepto, '', '', '', '', '', '',  -- strings
					vmMonto, '','', '', '', CURRENT, '')RETURNING vcodretTemp;						-- importes						
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
			if flg_indicadores = '1'
				then
					UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '1' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
				else
					IF vcStatus = '1' and flg_indicadores = '1' 
						THEN
							UPDATE {+INDEX (bdiprog:"informix".pp_procesos 110_15)} bdiprog:"informix".pp_procesos SET status = '2' WHERE proceso = 'ejec_trans' and fech_proceso = pdFecha;
						ELSE
							let vcCodRet = '99996';
							let vcMensaje = 'Sistema pendiente de cierre o temporalmente fuera de servicio. Validar.';
					END IF;	
			end if;
--	2013.11.06 - FRG - f
		END IF;
	END IF;
	if vtransaccion = 1 then
	   BEGIN WORK;
	end if;
    IF vcFlgError='0' 
		THEN
			IF IndsCred <> '0' 
				THEN
					let vcCodRet = '99995';
					let vcMensaje = 'Sist. CREDITO Pend. Cierre o Temp. Fuera de Servicio.';
					RETURN vcCodRet,vcMensaje;
				ELSE
					SELECT {+INDEX (bdiprog:"informix".pp_mensajes 106_11)} cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '00';
					RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
		RETURN '99999','ERROR EN LOS PAGOS PROGRAMADOS POR SPEI';
    END IF;
END PROCEDURE;