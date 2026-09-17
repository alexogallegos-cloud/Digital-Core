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