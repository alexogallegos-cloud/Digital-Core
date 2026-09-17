CREATE PROCEDURE "informix".sp_prestamoflex_sms(popcion      INTEGER,  pNumCel CHAR(20), pMontoSol DECIMAL (18,2), 
												pParametro1 CHAR(20), 		-- Identificador de canal de origen
												pParametro2 CHAR(20), 		-- Id de ATM si canal es ATM
												pParametro3 CHAR(20), pNum_Credito CHAR(20))
RETURNING CHAR(5),      -- Codigo de Retorno
		  CHAR(60);		-- Mensaje de error
												-- pCanal SMALLINT default 0, pId_atm CHAR(6) default '')  
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE cCodRet      		CHAR(6);
DEFINE cCod_ret     		CHAR(6);
DEFINE v_codret 			CHAR(6);
DEFINE cMen_ret 			CHAR(60);

DEFINE cHoraIni 			CHAR(8);
DEFINE cHoraFin 			CHAR(8);
DEFINE imontomin			INTEGER;
DEFINE dtFechaHoy 			DATE;
--DEFINE dFechaValFeriado		DATE;
DEFINE pEjecutivo			CHAR(8);
DEFINE pUsuario             CHAR(8);

DEFINE cNumCte				CHAR(20);
DEFINE cCtaPPF				CHAR(20);
DEFINE cstPPF   			CHAR(2);
DEFINE dtFechaAp 			DATE;
DEFINE dtFechaCan  			DATE;
DEFINE itctasven 			INTEGER;
DEFINE itctasvencrd 		INTEGER;
DEFINE inumppf				INTEGER;
DEFINE dlinea_ppf			DECIMAL(18,2);
DEFINE cTelVerificado       CHAR(1);  --IPCB jul18/ para identificar si cuenta o no con celular verificado

--Return sp_consulta_saldos_general
DEFINE ccodigo_retorno 		CHAR(6);
DEFINE cmensaje_retorno 	CHAR(80);
DEFINE cnumero_credito 		CHAR(20);
DEFINE ctipcred 			CHAR(2);
DEFINE dtfecha_origen 		DATE;
DEFINE dtfecha_prox_pago 	DATE;
DEFINE diva   				DECIMAL(18,2);
DEFINE dpago_minimo 		DECIMAL(18,2);
DEFINE dtfecha_ult_pago 	DATE;
DEFINE iplazo 				INTEGER;
DEFINE ipagos_realizados 	INTEGER;
DEFINE dlinea_otorgada 		DECIMAL(18,2);
DEFINE dtasa_interes 		DECIMAL(9,6);
DEFINE dtasa_moratorios 	DECIMAL(9,6);
DEFINE dmonto_sbc 			DECIMAL(14,2);
DEFINE dcap_vig 			DECIMAL(18,2);
DEFINE dcap_trans 			DECIMAL(18,2);
DEFINE dcap_vdo_exig 		DECIMAL(18,2);
DEFINE dcap_vdo_no_exig 	DECIMAL(18,2);
DEFINE dsdo_act_total_cap 	DECIMAL(18,2);
DEFINE dint_vig 			DECIMAL(18,2);
DEFINE dint_moratorios 		DECIMAL(18,2);
DEFINE dint_mes 			DECIMAL(18,2);
DEFINE dsdo_act_total_int 	DECIMAL(18,2);
DEFINE diva_int_vig 		DECIMAL(18,2);
DEFINE diva_int_moratorios	DECIMAL(18,2);
DEFINE diva_int_mes 		DECIMAL(18,2);
DEFINE dsdo_act_total_iva 	DECIMAL(18,2);
DEFINE dcom_pend 			DECIMAL(18,2);
DEFINE dsdo_retenido 		DECIMAL(18,2);
DEFINE dtotal_liquidacion 	DECIMAL(18,2);
DEFINE dint_devengado		DECIMAL(18,2);
DEFINE diva_int_devengado 	DECIMAL(18,2);
DEFINE dlinea_disponible 	DECIMAL(18,2);
DEFINE dpagos_vdos 			DECIMAL(18,2);
DEFINE cstatus_cred 		CHAR(60);
DEFINE iid_bloqueo_cred 	INTEGER;
DEFINE cbloq_cta 			CHAR(60);
DEFINE cid_causa_bloqcta 	CHAR(3);
DEFINE ccausa_bloqcta 		CHAR(50);
DEFINE cid_sit_espcte 		CHAR(1);
DEFINE iid_causa_espcte 	INTEGER;
DEFINE csit_espcte 			CHAR(75);
DEFINE cid_sit_espcred 		CHAR(1);
DEFINE iid_causa_espcred 	INTEGER;
DEFINE csit_espcred 		CHAR(75);

DEFINE inumpagos 			INTEGER;

DEFINE cSucursal            CHAR(4);	
DEFINE cTransacc			CHAR(4);
--Return sp_principal_pp
DEFINE cCodRet2 			CHAR(5);
DEFINE cmens_ret 			CHAR(125);
DEFINE dsdo_ant 			DECIMAL(18,2);
DEFINE dcomision 			DECIMAL(18,2);
DEFINE diva_com 			DECIMAL(18,2);
DEFINE dint_mora 			DECIMAL(18,2);
DEFINE diva_int_mora 		DECIMAL(18,2);
DEFINE dint_vdo 			DECIMAL(18,2);
DEFINE diva_int_vdo 		DECIMAL(18,2);
DEFINE dint_ordi 			DECIMAL(18,2);
DEFINE diva_int_ordi 		DECIMAL(18,2);
DEFINE dcapital 			DECIMAL(18,2);
DEFINE dmonto_pago 			DECIMAL(18,2);
DEFINE ccuenta_eje 			CHAR(20);
DEFINE dsdo_act 			DECIMAL(18,2);
DEFINE dpago_min 			DECIMAL(18,2);
DEFINE cfecha_limite_pago 	CHAR(17);

DEFINE dtotal_prestamo		DECIMAL(18,2);

DEFINE fg_prestamo			SMALLINT;
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE pNombrePres			CHAR(50);
DEFINE cNom_Cliente 		CHAR(150);

DEFINE Pago_Efectivo 		DECIMAL(18,2);
DEFINE Pago_Cuenta 			DECIMAL(18,2);
DEFINE Monto_Operacion 		DECIMAL(18,2);
DEFINE Saldo_Actual 		DECIMAL(18,2);
DEFINE Status_Actual 		CHAR(60);

DEFINE pMensualidad			MONEY(18,2);
DEFINE pCuentaCap			CHAR(20);
DEFINE fg_liqppf			SMALLINT;
DEFINE dtFechaProxPago		CHAR(10);

DEFINE dtotal_vencido		DECIMAL(18,2);
DEFINE iCountExists			INTEGER;
DEFINE sNumPagosReprest		SMALLINT;
DEFINE cDispActiva			CHAR(1);
DEFINE cBandDispActiva		SMALLINT;
DEFINE iRegsAfectados		SMALLINT;

--RQM 10 1155
--DEFINE dtFechaCrd			DATE;
DEFINE dtFechaCtaChq		DATE;
DEFINE cIndCierreCheq 		CHAR(1);
DEFINE dFechaIntegral		DATE;
DEFINE dFechaCierrePP		DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cCodRet3 			CHAR(5);
DEFINE cStatusCierrePP 		CHAR(1);
DEFINE cCancelaPf           CHAR(1);
DEFINE cCtaCaptacion		CHAR(20);
DEFINE cStatusCtaCapta		CHAR(1);
DEFINE dCanal				SMALLINT;
DEFINE dCanal_atm			SMALLINT;
DEFINE dCanal_sms			SMALLINT;
DEFINE dCanal_whatsapp		SMALLINT;
DEFINE dCanal_App			SMALLINT;
DEFINE cTransacCredito		CHAR(4);
DEFINE cTransacCapta		CHAR(4);
DEFINE cId_atm 				CHAR(6);
DEFINE bandera_apoyo_chtb	INT;
DEFINE cEnvioSMSRespMultic	CHAR(1);

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET cCodRet         		= "00000";
LET cCod_ret        		= "00000";
LET v_codret				= "00000";
LET cMen_ret     			= "Proceso Exitoso";

LET cHoraIni 				= "";
LET cHoraFin 				= "";
LET imontomin 				= 0;
LET dtFechaHoy				= DATE(1);
--LET dFechaValFeriado		= DATE(1);
LET pEjecutivo				= "informix";
LET pUsuario				= "";

LET cNumCte					= "";
LET cCtaPPF					= "";
LET cstPPF 					= "";
LET dtFechaAp 				= DATE(1);
LET dtFechaCan 				= DATE(1);
LET itctasven 				= 0;
LET itctasvencrd 			= 0;
LET inumppf					= 0;
LET dlinea_ppf				= 0;
LET cTelVerificado          =""; --IPCB jul18/ para identificar si cuenta o no con celular verificado
--return sp_consulta_saldos_general
LET ccodigo_retorno 		= '';
LET cmensaje_retorno 		= '';
LET cnumero_credito 		= '';
LET ctipcred 				= '';
LET dtfecha_origen 			= date(0);
LET dtfecha_prox_pago 		= date(0);
LET diva					= 0;
LET dpago_minimo 			= 0;
LET dtfecha_ult_pago 		= date(0);
LET iplazo 					= 0;
LET ipagos_realizados 		= 0;
LET dlinea_otorgada 		= 0;
LET dtasa_interes 			= 0;
LET dtasa_moratorios 		= 0;
LET dmonto_sbc 				= 0;
LET dcap_vig 				= 0;
LET dcap_trans 				= 0;
LET dcap_vdo_exig 			= 0;
LET dcap_vdo_no_exig 		= 0;
LET dsdo_act_total_cap 		= 0;
LET dint_vig 				= 0;
LET dint_moratorios 		= 0;
LET dint_mes 				= 0;
LET dsdo_act_total_int 		= 0;
LET diva_int_vig 			= 0;
LET diva_int_moratorios 	= 0;
LET diva_int_mes 			= 0;
LET dsdo_act_total_iva 		= 0;
LET dcom_pend 				= 0;
LET dsdo_retenido 			= 0;
LET dtotal_liquidacion 		= 0;
LET dint_devengado 			= 0;
LET diva_int_devengado 		= 0;
LET dlinea_disponible 		= 0;
LET dpagos_vdos 			= 0;
LET cstatus_cred 			= '';
LET iid_bloqueo_cred 		= 0;
LET cbloq_cta 				= '';
LET cid_causa_bloqcta		= '';
LET ccausa_bloqcta 			= '';
LET cid_sit_espcte 			= '';
LET iid_causa_espcte		= 0;
LET csit_espcte 			= '';
LET cid_sit_espcred 		= '';
LET iid_causa_espcred 		= 0;
LET csit_espcred 			= '';

LET inumpagos 				= 0;
LET cSucursal				= "";
LET cTransacc				= "";
--Return sp_principal_pp
LET cCodRet2 				='00000';
LET cmens_ret				='';
LET dsdo_ant 				=0;
LET dcomision 				=0;
LET diva_com 				=0;
LET dint_mora 				=0;
LET diva_int_mora 			=0;
LET dint_vdo 				=0;
LET diva_int_vdo 			=0;
LET dint_ordi 				=0;
LET diva_int_ordi 			=0;
LET dcapital 				=0;
LET dmonto_pago 			=0;
LET ccuenta_eje				='';
LET dsdo_act 				=0;
LET dpago_min 				=0;
LET cfecha_limite_pago 		='';

LET dtotal_prestamo			=0;
LET fg_prestamo             = 0;
LET cNumeroFolio			= "";
LET pNombrePres 			= "";

LET Pago_Efectivo = 0;
LET Pago_Cuenta = 0;
LET Monto_Operacion = 0;
LET Saldo_Actual = 0;
LET Status_Actual = "";

LET dtotal_vencido			= 0;

LET pMensualidad 			= 0;
LET pCuentaCap  			= "";
LET fg_liqppf				= 0;
LET dtFechaProxPago			= "";
LET iCountExists			= 0;
LET sNumPagosReprest		= 0;
LET cDispActiva				= '';
LET cBandDispActiva			= 0;
LET iRegsAfectados			= 0;

--RQM 10 1155
--LET dtFechaCrd			= DATE(1);
LET dtFechaCtaChq			= DATE(1);
LET cIndCierreCheq			= "";
LET dFechaIntegral			= DATE(1);
LET dFechaCierrePP			= DATE(1);
LET dFechaHabilAnt 			= DATE(1);
LET cCodRet3				= '000';
LET cStatusCierrePP			= '';
LET cCancelaPf              = '';
LET cCtaCaptacion			= '';
LET cStatusCtaCapta			= '';
LET dCanal					= 0;
LET dCanal_atm				= 0;
LET dCanal_sms				= 0;
LET dCanal_whatsapp			= 0;
LET dCanal_App				= 0;
LET cTransacCredito			= '';
LET cTransacCapta			= '';
LET cId_atm					= '';
LET bandera_apoyo_chtb		= 0;
LET cEnvioSMSRespMultic		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF cBandDispActiva = 1 THEN
		ROLLBACK WORK;
		BEGIN WORK;
			-- Se marca como disposicion libre. Ya concluyo validacion y procesamiento de disposicion.
			UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		-- Se marca como disposicion libre. Ya concluyo validacion y procesamiento de disposicion.
		UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
	END IF;	
	
	IF iSqlErr != 0 THEN
		--RETURN cCodRet ;
		IF dCanal != dCanal_sms THEN	-- Error para canal ATM, o cualquier otro canal diferente a SMS
			LET cCodRet = '00006';
			LET cMen_ret = 'Error';
			RETURN cCodRet, cMen_ret;
		ELSE							-- Error para canal sms
			LET cMen_ret = cErrorInfo;
			RETURN iSqlErr, cMen_ret;
		END IF;
	END IF;
	
END EXCEPTION;

ON EXCEPTION IN (-535) -- Error de transaccion.
	COMMIT WORK;
	LET cBandDispActiva = 1;	-- Marca bandera de transaccion abierta.
	BEGIN WORK;
END EXCEPTION WITH RESUME; 
   

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/RichardR/TestSP/sp_prestamoflex_sms.out';
--TRACE ON; 


--Traer parametros de horarios y vencidos
SELECT valor
INTO cHoraIni
FROM bdisolic:"informix".ss_param
WHERE empresa = '001'
AND secuencia= 389;

SELECT valor
INTO cHoraFin
FROM bdisolic:"informix".ss_param
WHERE empresa = '001'
AND secuencia= 390;

SELECT valor
INTO imontomin
FROM bdisolic:"informix".ss_param
WHERE empresa = '001'
AND secuencia= 391;

SELECT valor
INTO pUsuario --FLEX_SMS
FROM bdisolic:"informix".ss_param
WHERE empresa = '001'
AND secuencia= 392;


LET dCanal = pParametro1::SMALLINT;		-- Obtiene canal para SMS
IF dCanal = 0 THEN
	SELECT cve_canal INTO dCanal FROM bdinteg:si_canal WHERE nombre_canal = '98000';
END IF;
								-- Identifica los diferentes canales (ATM y SMS), para diferenciar la respuesta a enviar.
SELECT cve_canal INTO dCanal_sms FROM bdinteg:si_canal WHERE nombre_canal = '98000';
SELECT cve_canal INTO dCanal_atm FROM bdinteg:si_canal WHERE nombre_canal = 'ATM';
SELECT cve_canal INTO dCanal_whatsapp FROM bdinteg:si_canal WHERE nombre_canal = 'WHATSAPP';
SELECT cve_canal INTO dCanal_App FROM bdinteg:si_canal WHERE nombre_canal = 'BANCOPPEL MOVIL EN LINEA';


-- Identifica parametro para envio de respuesta via SMS segun el canal de origen
SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
  FROM bdicred:sd_param_campania WHERE grupo_parametro = 'PFLEX_MLTC' AND valor_numerico = dCanal;
IF cEnvioSMSRespMultic IS NULL THEN LET cEnvioSMSRespMultic = '1'; END IF;  

								-- Asigna transacciones de acuerdo al canal
IF dCanal = dCanal_atm THEN
	LET cTransacCredito	= '7590';
	--LET cTransacCapta = '0499';
	LET cTransacCapta = '0247';
	LET cId_atm = trim(pParametro2);
ELIF dCanal = dCanal_whatsapp THEN			
	LET cTransacCredito	= '8738';
	LET cTransacCapta = '0247';	
ELIF dCanal = dCanal_App THEN			
	LET cTransacCredito	= '5025';
	LET cTransacCapta = '0247';	
ELSE							-- Asigna por default transacciones de sms
	LET cTransacCredito	= '8317';
	LET cTransacCapta = '0247';		
END IF;

-----
-- Obtiene las diferentes fechas del sistema		RQM 10 1155
SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas;
SELECT ind_cierre INTO cIndCierreCheq FROM bdicheq:"informix".sc_fechas;
SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:"informix".si_fechas;
 
SELECT valor::SMALLINT INTO sNumPagosReprest 
  FROM bdicred:"informix".sd_param WHERE cod_param = '057';
  
LET pMontoSol = pMontoSol;
  

--EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(dtFechaHoy,'+')  INTO ccodigo_retorno,dFechaValFeriado;

--OK-Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde.	
--Por el momento no podemos ofrecerte el servicio.  El horario de atencion es de 9:00 a 22:00 hrs	-- Se elimina la restriccion de L a V	
/* IF popcion = 2 AND ((current hour to second < cHoraIni OR current hour to second > cHoraFin)
					OR (dtFechaHoy <> dFechaValFeriado))THEN
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_HD','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
	RETURN cCodRet ;
ELSE */	

-- Obtiene informacion del credito si dato de origen es el numero de CELULAR
	IF pNumCel IS NULL THEN LET pNumCel = ''; END IF;
	IF pNum_Credito IS NULL THEN LET pNum_Credito = ''; END IF;
	
	IF trim(pNumCel) != '' THEN
	
		SELECT a.numcte,b.num_credito,b.status_cred,b.fecha_apertura,c.fecha_cancela,sec_credito,monto_linea,b.sucursal,nvl(a.verificado,""), nvl(c.disposicion_activada,"1"),c.cancel_pf
		  INTO cNumCte,cCtaPPF,cstPPF,dtFechaAp,dtFechaCan,inumppf,dlinea_ppf,cSucursal,cTelVerificado, cDispActiva, cCancelaPf
		  FROM bdinteg:si_telefonos a
		 INNER JOIN bdicred:sd_maecredcrd b ON a.numcte = b.numcte AND num_producto = '6800' 
					and fecha_apertura = (select max(fecha_apertura) from bdicred:sd_maecredcrd 
									       where empresa = '001' and numcte = b.numcte and NUM_PRODUCTO = '6800')
		 INNER JOIN bdicred:sd_linea_prestamo c ON (c.empresa = '001' AND b.num_credito = c.num_credito)
		 WHERE telefono = pNumCel  
		   AND tipo_tel = 2
		   --AND verificado = 'V' --IPCB jul18/ para identificar si cuenta o no con celular verificado
		   AND status_tel = 'A';
	ELSE

		SELECT a.numcte, b.num_credito,  b.status_cred, b.fecha_apertura, c.fecha_cancela, sec_credito, monto_linea, b.sucursal, nvl(a.verificado,""), nvl(c.disposicion_activada,"1"), c.cancel_pf, a.telefono
		  INTO cNumCte,  cCtaPPF,        cstPPF,        dtFechaAp,        dtFechaCan,      inumppf,     dlinea_ppf,  cSucursal,  cTelVerificado,       cDispActiva,                     cCancelaPf,  pNumCel
		  FROM bdicred:sd_maecredcrd b 
		  JOIN bdinteg:si_telefonos a ON (b.numcte = a.numcte and a.tipo_tel = 2 and a.status_tel = 'A')
		  JOIN bdicred:sd_linea_prestamo c ON (b.num_credito = c.num_credito and cancel_pf is null)
		 WHERE b.num_credito = pNum_Credito;	
		
	END IF;
	
	-- Valida que existan datos del credito y del telefono
	/*IF trim(cCtaPPF) = '' or trim(pNumCel) = '' THEN
		LET cCodRet = '00014';	
		LET cMen_ret = 'Credito y/o telefono incorrectos';
		RETURN cCodRet, cMen_ret;	
	END IF;*/
	
		
	-----
	SELECT nvl(a.fecha_proceso,c.fecha_alta)  INTO dtFechaCtaChq --Fecha proceso cheques RQM 10 1155
	FROM  bdicheq:"informix".sc_maechq a
	JOIN  bdicred:"informix".sd_ctascarg b ON a.cuenta = b.num_cta
	JOIN  bdicheq:"informix".sc_maenoc c ON a.cuenta = c.cuenta
	WHERE a.empresa = '001'
	AND num_credito = cCtaPPF;

	--IF cstPPF = 'FF' THEN --RQM 10 1155
	--	SELECT nvl(a.fecha_proceso,c.fecha_alta)  INTO dtFechaCrd --Fecha proceso cheques 
	--	FROM  bdicheq:"informix".sc_maechq a
	--	JOIN  bdicred:"informix".sd_ctascarg b ON a.cuenta = b.num_cta
	--	JOIN  bdicheq:"informix".sc_maenoc c ON a.cuenta = c.cuenta
	--	WHERE a.empresa = '001'
	--	AND num_credito = cCtaPPF;
	--ELSE
	--	SELECT fecha_proceso  INTO dtFechaCrd --Fecha proceso credito 
	--	FROM bdicred:"informix".sd_maecredanexocrd 
	--	WHERE empresa = '001'
	--	AND num_credito = cCtaPPF;
	--END IF;
	
	--Tomamos el iva de la sucursal
	SELECT iva
	INTO diva
	FROM bdinteg:si_sucursales
	WHERE sucursal = cSucursal;
	
	IF NVL(cCtaPPF,'') = '' THEN 
		SELECT count(a.numcte) INTO iCountExists 
		  FROM bdinteg:si_telefonos a
         INNER JOIN bdisolic:ss_solicitudes b ON a.numcte = b.numcte AND num_producto = '6800' AND status_solicitud = 'AT'
		 WHERE telefono = pNumCel AND tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A';
		    
		IF iCountExists > 0 THEN
			--Prestamo Autorizado no Activo
			--Tienes un Prestamo Flexible autorizado, te invitamos a realizar la activacion en sucursales BanCoppel.
			IF cEnvioSMSRespMultic = '1' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ATNA','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			END IF;
			IF dCanal != dCanal_sms THEN -- Solicitud proviene de ATM
				LET cCodRet = '00007';	
			END IF;
			LET cMen_ret = '';
			RETURN cCodRet, cMen_ret;
		ELSE
			LET iCountExists = 0;
			
			SELECT count(a.numcte) INTO iCountExists
			  FROM bdinteg:si_telefonos a 
			 INNER JOIN bdisolic:ss_solicitudes b ON a.numcte = b.numcte AND num_producto = '6800' AND status_solicitud = 'RT'
			 WHERE telefono = pNumCel AND tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A';

			IF iCountExists > 0 THEN
				--Prestamo RT
				--Tu Prestamo Flexible no fue aprobado
				IF cEnvioSMSRespMultic = '1' THEN
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_RT','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
				END IF;	
				IF dCanal != dCanal_sms THEN
					LET cCodRet = '00008';	
				END IF;				
				LET cMen_ret = '';
				RETURN cCodRet, cMen_ret;
			ELSE
				--No cuentas con un Prestamo Flexible vigente.
				--No tienes un Prestamo Flexible aprobado. Te invitamos a realizar una solicitud en sucursales BanCoppel.
				IF cEnvioSMSRespMultic = '1' THEN
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_SNPF','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
				END IF;
				IF dCanal != dCanal_sms THEN
					LET cCodRet = '00008';	
				END IF;	
				LET cMen_ret = '';
				RETURN cCodRet, cMen_ret;
			END IF;				
		END IF;	
	ELSE
		IF cTelVerificado = "V" THEN  --IPCB jul18/ Si el celular esta verificado, puede realizar las transacciones 
			--OK-Si el prestamo se cancelo y no tenia adeudo.	
			--Lamentamos informarte que tu Prestamo Flexible esta cancelado.  Te invitamos a realizar una nueva solicitud en sucursales Bancoppel.
			--IF 	((cstPPF not in ('BA','BT')) AND (dtFechaHoy >= dtFechaCan)) THEN

			select mto_venc_trasp + monto_vencido+ (select sum(interes_debe - interes_pagado  + iva_debe - iva_pagado + 
										round((mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag + 
										mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag) * (1 + diva),2))
									from bdicred:sd_amortiza_creditocrd 
									where a.num_credito = num_credito and capital_status in ('2','7','6')) Total_vecido
			INTO dtotal_vencido
			from bdicred:sd_maesdoscrd a where num_credito = cCtaPPF;
			
			LET dtotal_vencido = nvl(dtotal_vencido,0);
			
			IF cCancelaPf = '1' THEN --RQM 10 915-4
				IF cEnvioSMSRespMultic = '1' THEN
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_CN','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current)  INTO cCodRet;			
				END IF;
				IF dCanal != dCanal_sms THEN
					LET cCodRet = '00011';	
				END IF;	
				LET cMen_ret = '';
				RETURN cCodRet, cMen_ret;
			--OK-Si el credito se encuentra vencido  
			--Tu Prestamo Flexible tiene un saldo vencido de $XXX. Te invitamos a ponerte al corriente.  Recuerda que es muy importante que conserves un buen historial crediticio.
			--ELIF cstPPF in ('BA','BT') THEN	
			-- IFSR ajuste para contempar las etapas
			ELIF (dtotal_vencido > 0) THEN	
		
				IF cEnvioSMSRespMultic = '1' THEN
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ADP','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, dtotal_vencido, 0,0, 0, 0, current, current) INTO cCodRet;			
				END IF;
				IF dCanal != dCanal_sms THEN
					LET cCodRet = '00003';	
				END IF;	
				LET cMen_ret = '';
				RETURN cCodRet, cMen_ret;
			ELSE
				
				
					---Valida cuentas vencidas adicionales al PPF
					/*SELECT  COUNT(*)
					INTO itctasven
					FROM bdicred:sd_maecred 
					WHERE numcte = cNumCte
					AND num_Credito <> cCtaPPF
					AND status_cred in ('BA','BT');
				
					SELECT  COUNT(*)
					INTO itctasvencrd
					FROM bdicred:sd_maecredcrd 
					WHERE numcte = cNumCte
					AND num_Credito <> cCtaPPF
					AND status_cred in ('BA','BT','VP');*/
					
					-- IFSR se modifica para que contemple las etapas
				SELECT  COUNT(*)
				INTO itctasven
				FROM bdicred:sd_maecred a,
					 bdicred:sd_maesdos b
				WHERE a.numcte = cNumCte
				AND a.num_credito = b.num_credito 
				--AND a.num_Credito <> cCtaPPF
				--AND (a.status_cred in ('BA','BT'));  --OR (a.status_cred in ('E1','E2','E3') AND b.act >= 1));  --IPCB // Se comenta linea para aplicar movimiento
				AND (b.mto_venc_trasp + b.monto_vencido) > 0;

				IF ( itctasven = 0 ) THEN
					SELECT  COUNT(*)
					INTO itctasven
					FROM bdicred:sd_maecredcrd a,
						 bdicred:sd_maesdoscrd b
					WHERE a.numcte = cNumCte
					AND a.num_credito = b.num_credito 
					AND a.num_Credito <> cCtaPPF
					--AND (a.status_cred in ('BA','BT'));  --OR (a.status_cred in ('E1','E2','E3') AND b.act >= 1));  --IPCB // Se comenta linea para aplicar movimiento
					AND (b.mto_venc_trasp + b.monto_vencido) > 0;
				END IF;
					
				--LET itctasven = itctasven + itctasvencrd;
				--OK-Si el cliente presenta adeudos o saldo vencido en algun otro producto de credito BANCOPPEL
				--Tienes otros creditos en Bancoppel pendientes de pago.  Una vez que liquides podras disponer tu Prestamo Flexible.
				IF itctasven > 0 THEN	
					IF cEnvioSMSRespMultic = '1' THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ADO','000000000','','',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
					END IF;
					IF dCanal != dCanal_sms THEN
						LET cCodRet = '00005';	
					END IF;	
					LET cMen_ret = '';
					RETURN cCodRet, cMen_ret;
				ELSE
				--Valida 3pagos para saber si cuenta con 3 meses de pago puntual continuo.
				--JOM VALIDA PRESTAMOS CON LA REGLA DE PAGO SOSTENIDO PARA 6800->INICIO
					SELECT COUNT(*) 
					INTO inumpagos
					FROM bdicred:sd_amortiza_creditocrd a
					WHERE empresa = '001'
					AND num_credito = (SELECT MAX(num_credito) 
									   FROM bdicred:sd_maecredcrd b
									   WHERE a.empresa = empresa
									   AND numcte = cNumCte
									   AND num_producto = '6800'
									   AND fecha_apertura = (SELECT MAX(fecha_apertura) 
															 FROM bdicred:sd_maecredcrd 
															 WHERE b.empresa = empresa 
															 AND b.numcte = numcte 
															 AND num_producto = '6800'
															 --AND status_cred in ('AA','BA','BT')))
															 -- IFSR se contemplan etapas
															 AND status_cred in ('AA','BA','BT','E1','E2','E3')))
					AND num_pago >= (SELECT MAX(num_pago) 
									 FROM bdicred:sd_amortiza_creditocrd 
									 WHERE a.empresa = empresa 
									 AND a.num_credito = num_credito 
									 AND capital_status <> '3') - 3
					AND capital_status = '5'
					AND capital_status_ant = 1;	
					
					SELECT count (*)
						INTO bandera_apoyo_chtb
					FROM  bdicred:sd_programa_apoyo2020crd_chtb 
						WHERE num_credito = cCtaPPF;
						
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001',cCtaPPF) 
					INTO ccodigo_retorno,cmensaje_retorno,cnumero_credito,ctipcred,dtfecha_origen,dtfecha_prox_pago,dpago_minimo,dtfecha_ult_pago,
					iplazo,ipagos_realizados,dlinea_otorgada,dtasa_interes,dtasa_moratorios,dmonto_sbc,dcap_vig,dcap_trans,dcap_vdo_exig,dcap_vdo_no_exig,
					dsdo_act_total_cap,dint_vig,dint_vdo,dint_moratorios,dint_mes,dsdo_act_total_int,diva_int_vig,diva_int_vdo,diva_int_moratorios,diva_int_mes,
					dsdo_act_total_iva,dcom_pend,diva_com,dsdo_retenido,dtotal_liquidacion,dint_devengado,diva_int_devengado,dlinea_disponible,dpagos_vdos,
					cstatus_cred,iid_bloqueo_cred,cbloq_cta,cid_causa_bloqcta,ccausa_bloqcta,cid_sit_espcte,iid_causa_espcte,csit_espcte,cid_sit_espcred,iid_causa_espcred,
					csit_espcred;
					
					LET dlinea_disponible = (dlinea_ppf - dtotal_liquidacion);		
				
					IF popcion = 1 THEN --DISPONIBLE  (Consulta linea disponible)	
					
						--OK-Si No cuenta con los 3 meses de pago puntual continuo // Nov 2018: Se modifica 3 meses a 1 mes.	
						--Tienes un prestamo vigente.  Por el momento no puedes disponer de un prestamo nuevo.
						--IF (inumpagos < 3) AND inumppf > 0 AND cstPPF <> 'FF' THEN 
						IF (inumpagos < sNumPagosReprest) AND inumppf > 0 AND cstPPF <> 'FF' THEN 
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_D3','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;
						
						--OK-Si la linea disponible del cliente es menor al minimo (1000)				
						--Por el momento, no cuentas con saldo suficiente para solicitar un nuevo prestamo.
						IF (dlinea_disponible < imontomin) THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_LSD','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, dlinea_disponible, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;	
						--OK-Si cuenta con sus 3 pagos continuos y su linea disponible es mayor o igual que el minimo (1000)	
						--Tu linea de credito disponible actual es de $XXX.  Liquida tu Prestamo Flexible solo por hoy $XXX)
						--Si deseas un nuevo Prestamo envia un SMS al 98000 con la palabra "FLEXIBLE" (espacio) monto que deseas sin signo de pesos.
						--IF (inumpagos >= 3) AND (dlinea_disponible >= imontomin)THEN 
						IF (inumpagos >= sNumPagosReprest) AND (dlinea_disponible >= imontomin)THEN 
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_LS','000000000','', '',1, '', '', '', '', '', '', '', '', '', '','',pNumCel, dlinea_disponible,dtotal_liquidacion,0, 0, 0, current, current) INTO cCodRet;			
								--RETURN cCodRet ;					
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_NNP','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;		
						--OK-Si la linea disponible = linea Otorgada	
						--Tienes un Prestamo Flexible autorizado por $XXX, Envia un SMS al 98000 con la palabra FLEXIBLE (espacio)...	
						IF dlinea_ppf = dlinea_disponible THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_L1','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel,dlinea_disponible, 0,0,0,0, current, current) INTO cCodRet;			
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;						
					ELIF popcion = 2 THEN --FLEXIBLE + Monto (Solicitud de prestamo y Represtamo)	
					    
					  --IF dtFechaCrd = dtFechaCtaChq AND  cfechhoy <= dtFechaCrd THEN  --RQM 10 1155
					  -- El cierre de credito ha concluido Y el cierre de cheques a concluido. No puede procesarse un credito una vez iniciado el cierre (Creditos y cheques) hasta despues del cambio de fechas. 

					  -- Obtiene fecha del ultimo cierre de PP. (Dia habil antes)
					  SELECT max(fecha) INTO dFechaCierrePP FROM bdicred:sd_contproc WHERE empresa = '001' AND proceso = "CierrePrest";
					  SELECT status_proc INTO cStatusCierrePP FROM bdicred:sd_contproc WHERE proceso = "CierrePrest" AND fecha = dFechaCierrePP;
					  
					  -- Obtiene la fecha habil anterior a la fecha integral
					  EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet3, dFechaHabilAnt;
					  
					  IF cIndCierreCheq = '1' AND dFechaCierrePP = dFechaHabilAnt AND UPPER(cStatusCierrePP) = 'F' THEN	
					   
						--OK-Si No cuenta con los 3 meses de pago puntual continuo	
						--Tienes un prestamo vigente.  Por el momento no puedes disponer de un prestamo nuevo.	
						--IF (inumpagos < 3) AND inumppf > 0 AND cstPPF <> 'FF' THEN 
						IF (inumpagos < sNumPagosReprest) AND inumppf > 0 AND cstPPF <> 'FF' AND bandera_apoyo_chtb = 0 THEN 
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_D3','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							IF dCanal != dCanal_sms THEN
								LET cCodRet = '00002';	
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;
					
						-- Valida si el credito tiene mesiversario pendiente de pago: capital_status = 1. Rechaza disposicion hasta que se liquide.
						SELECT count(*) INTO iCountExists
						  FROM bdicred:sd_amortiza_creditocrd 
						 WHERE empresa = '001' AND num_credito = cCtaPPF AND capital_status = '1';
						 IF iCountExists >= 1 THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_D3','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							IF dCanal != dCanal_sms THEN
								LET cCodRet = '00002';	
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;

						-- Valida el status de la cuenta de captacion. Si el estatus es diferente a vigente (1) rechaza la solicitud de disposicion.
						SELECT num_cta INTO cCtaCaptacion FROM bdicred:sd_ctascarg WHERE num_credito = cCtaPPF AND naturaleza = 'A';
						SELECT status_cta INTO cStatusCtaCapta FROM bdicheq:sc_maechq WHERE num_cte = cNumCte AND cuenta = cCtaCaptacion;
						IF cStatusCtaCapta IS NULL THEN LET cStatusCtaCapta = ''; END IF;
						IF cStatusCtaCapta != '1' THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_CTAC','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							IF dCanal != dCanal_sms THEN
								LET cCodRet = '00013';
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						END IF;
						
						--OK-Si la linea disponible es menor al minimo posible a disponer					
						--Por el momento, no cuentas con saldo suficiente para solicitar un nuevo prestamo.
						IF (dlinea_disponible < imontomin) THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_LSD','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, dlinea_disponible, 0,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							IF dCanal != dCanal_sms THEN
								LET cCodRet = '00004';
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;

						--OK-Si el monto solicitado es menor a el minimo posible a disponer o Mayor a la linea disponible	
						--Si deseas solicitar un prestamo, el monto debe ser mayor a $XXX y menor a $XXX.  Intentalo nuevamente.
						ELIF (pMontoSol < imontomin) OR (pMontoSol > dlinea_disponible) THEN
							IF cEnvioSMSRespMultic = '1' THEN
								EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_VM','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel,imontomin,dlinea_disponible,0, 0, 0, current, current) INTO cCodRet;			
							END IF;
							IF dCanal != dCanal_sms THEN
								LET cCodRet = '00009';
							END IF;
							LET cMen_ret = '';
							RETURN cCodRet, cMen_ret;
						ELSE	
							
							IF cDispActiva = '1' THEN	-- Disposicion de Prestamo Digital libre de realizarse. No existe disposicion en proceso 
								BEGIN WORK; 
									-- Se marca como disposicion en proceso.
									UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '3' WHERE num_credito = cCtaPPF AND NVL(disposicion_activada, '') <> '3';									
								COMMIT WORK;
								IF cBandDispActiva = 1 THEN
									BEGIN WORK; 
								END IF;
								LET iRegsAfectados = dbinfo("sqlca.sqlerrd2");
								IF iRegsAfectados = 0 THEN 
									IF cEnvioSMSRespMultic = '1' THEN
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_APHR','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
									END IF;
									IF dCanal != dCanal_sms THEN
										LET cCodRet = '00006';
									END IF;
									LET cMen_ret = '';
									RETURN cCodRet, cMen_ret;
								END IF;
							
							ELSE -- Disposicion de prestamo activa. Es decir, ya existe una disposicion en proceso. cDispActiva = 3 en proceso, cDispActiva = 1 disposicion libre de realizar						
							
								-- Se envia SMS de error: Por el momento no se puede realizar su peticion. Favor de intentarlo mas tarde.
								IF cEnvioSMSRespMultic = '1' THEN
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_APHR','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
								END IF;
								IF dCanal != dCanal_sms THEN
									LET cCodRet = '00006';
								END IF;
								LET cMen_ret = '';
								RETURN cCodRet, cMen_ret;
							END IF;
						
							IF dlinea_ppf <> dlinea_disponible THEN 
							
								LET fg_liqppf =1;
								-- SE GENERA EL FOLIO
								CALL bdicheq:"informix".sp_generafolionomina(pUsuario) RETURNING cCodRet2, cNumeroFolio;

								IF cCodRet2::integer  <> 0 THEN
									LET cCodRet = "000003";  --Error en sp_generafolionomina
									LET fg_prestamo  = 0;				  
								ELSE
									BEGIN;
										-- Respaldo de informacion productiva, previo a hacer pago temporal.
										INSERT INTO bdicred:"informix".sd_maecredcrd_flex
										SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_maecredcrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

										INSERT INTO bdicred:"informix".sd_maesdoscrd_flex
										SELECT dtFechaHoy, pMontoSol, * FROM  bdicred:"informix".sd_maesdoscrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

										INSERT INTO bdicred:"informix".sd_maecredanexocrd_flex
										SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_maecredanexocrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	

										INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_flex
										SELECT dtFechaHoy, * FROM  bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_Credito = cCtaPPF;	
                                        --Se agrega campos "acepto_incremento y linea_prestamo_anterior" - RQM 10 1543
										INSERT INTO bdicred:"informix".sd_linea_prestamo_flex
										SELECT dtFechaHoy,  empresa , num_credito ,  monto_linea ,fecha_otorga,linea_disponible, sec_credito, fecha_cancela, fecha_ult_mod ,  disposicion_activada, acepto_incremento, linea_prestamo_anterior 
										 FROM  bdicred:"informix".sd_linea_prestamo WHERE num_Credito = cCtaPPF;	
									COMMIT;										
									IF cBandDispActiva = 1 THEN
										BEGIN WORK; 
									END IF;
								
									-- Realiza pago temporal de deuda anterior										-- '620')
									--EXECUTE PROCEDURE bdicred:"informix".sp_principal_suc_rr('001',cCtaPPF,'6800',0,dtotal_liquidacion,pEjecutivo,cSucursal,cNumeroFolio,'8317')
									EXECUTE PROCEDURE bdicred:"informix".sp_principal_suc_rr('001',cCtaPPF,'6800',0,dtotal_liquidacion,pEjecutivo,cSucursal,cNumeroFolio,cTransacCredito)
												INTO cCodRet2,cmens_ret,cCtaPPF,ccuenta_eje,pNombrePres,cNumCte,cNom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;

									IF Status_Actual = 'SALDADA NORMAL' THEN
										LET Status_Actual = 'FF';
									END IF;
									IF  cCodRet2::integer  <> 0 OR  Status_Actual <>'FF' THEN	
										EXECUTE PROCEDURE bdicred:"informix".reversioncrd('001',cSucursal,pEjecutivo,cNumeroFolio,'A') INTO cCodRet2;
										IF cCodRet2::INTEGER NOT IN(0,1) THEN
											LET cCodRet      = '00368';
											LET fg_prestamo  = 0;
											--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER',cNumCte,'', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
											BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
												UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
											COMMIT WORK;
											IF cBandDispActiva = 1 THEN
												BEGIN WORK; 
											END IF;
											IF dCanal != dCanal_sms THEN
												LET cCodRet = '00006';
											END IF;
											LET cMen_ret = '';
											RETURN cCodRet, cMen_ret;
										END IF;
										-- Elimina respaldo realizado, por error en el pago temporal.
										DELETE FROM bdicred:"informix".sd_maecredcrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
										DELETE FROM bdicred:"informix".sd_maesdoscrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
										DELETE FROM bdicred:"informix".sd_maecredanexocrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	
										DELETE FROM bdicred:"informix".sd_amortiza_creditocrd_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;		
										DELETE FROM bdicred:"informix".sd_linea_prestamo_flex WHERE empresa = '001' AND num_Credito = cCtaPPF AND fecha_insert = dtFechaHoy;	  
								
										IF cEnvioSMSRespMultic = '1' THEN								
											EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
										END IF;
										BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
											UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
										COMMIT WORK;
										IF cBandDispActiva = 1 THEN
											BEGIN WORK; 
										END IF;
										IF dCanal != dCanal_sms THEN
											LET cCodRet = '00006';
										END IF;
										LET cMen_ret = '';
										RETURN cCodRet, cMen_ret;
									END IF;
								END IF;	
							END IF;	
							
							IF cstPPF = 'FF' OR Status_Actual = 'FF' OR inumppf = 0 THEN
							
								LET dtotal_prestamo = dtotal_liquidacion + pMontoSol;
								--Validar el proceso de sp_pflex_disposicion pasar el monto
								
								--EXECUTE PROCEDURE bdicred:"informix".sp_pflex_disposicion ('001', cNumCte, cCtaPPF, dtotal_prestamo, pMontoSol, "0247", pEjecutivo)
								EXECUTE PROCEDURE bdicred:"informix".sp_pflex_disposicion ('001', cNumCte, cCtaPPF, dtotal_prestamo, pMontoSol, cTransacCapta, pEjecutivo, dCanal, cId_atm)
								INTO cCodRet,fg_prestamo,pMensualidad ,pCuentaCap;	
										
								IF cCodRet::integer  <> 0 THEN
									LET cCodRet = "000003";
									LET fg_prestamo  = 0;	
									IF fg_liqppf =1 THEN
										EXECUTE PROCEDURE bdicred:"informix".reversioncrd('001',cSucursal,pEjecutivo,cNumeroFolio,'A') INTO cCodRet2;
										IF cCodRet2::INTEGER NOT IN(0,1) THEN
											LET cCodRet      = '00368';
											LET fg_prestamo  = 0;
											--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER',cNumCte,'', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
											BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
												UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
											COMMIT WORK;
											IF cBandDispActiva = 1 THEN
												BEGIN WORK; 
											END IF;
											IF dCanal != dCanal_sms THEN
												LET cCodRet = '00006';
											END IF;
											LET cMen_ret = '';
											RETURN cCodRet, cMen_ret;
										END IF;
									END IF;
									
									IF cEnvioSMSRespMultic = '1' THEN
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
									END IF;
									BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
										UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
									COMMIT WORK;
									IF cBandDispActiva = 1 THEN
										BEGIN WORK; 
									END IF;
									IF dCanal != dCanal_sms THEN
										LET cCodRet = '00006';
									END IF;
									LET cMen_ret = '';
									RETURN cCodRet, cMen_ret;
								END IF;							
								
								IF fg_prestamo = 1 THEN
									--Tu prestamo se deposito a tu cuenta XXXX. Tus 12 pagos mensuales seran de $XXX y se cargaran a dicha cuenta a partir del dd/mm/aa.
									--select to_char((dtFechaCrd + 1 UNITS MONTH), '%d/%m/%y') into dtFechaProxPago  from bdicred:"informix".sd_fechas; --RQM 10 1155
									select to_char((fecha_hoy + 1 UNITS MONTH), '%d/%m/%y') into dtFechaProxPago  from bdicred:"informix".sd_fechas;
									
									IF cEnvioSMSRespMultic = '1' THEN
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_DOK','000000000','', '',1, right(trim(pCuentaCap),4), trim(dtFechaProxPago), '', '', '', '', '', '', '', '', '', pNumCel,pMensualidad, 0,0, 0, 0, current, current) INTO cCodRet;			
									END IF;
									BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
										UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
									COMMIT WORK;
									IF cBandDispActiva = 1 THEN
										BEGIN WORK; 
									END IF;
									LET cMen_ret = '';
									RETURN cCodRet, cMen_ret;
								ELSE 
									--La solicitud no fue procesada con exito.  Por favor intentalo nuevamente.						
									IF cEnvioSMSRespMultic = '1' THEN
										EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
									END IF;
									BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
										UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
									COMMIT WORK;
									IF cBandDispActiva = 1 THEN
										BEGIN WORK; 
									END IF;
									IF dCanal != dCanal_sms THEN
										LET cCodRet = '00006';
									END IF;									
									LET cMen_ret = '';
									RETURN cCodRet, cMen_ret;
								END IF;	

							ELSE		   
								-- Error al liquidar deuda vieja. Se envia SMS de error: La solicitud no fue procesada con exito. Por favor intentalo nuevamente.
								IF cEnvioSMSRespMultic = '1' THEN
									EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_ER','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
								END IF;
								BEGIN WORK; 	-- Se marca como disposicion libre para solicitarse
									UPDATE bdicred:sd_linea_prestamo SET disposicion_activada = '1' WHERE num_credito = cCtaPPF;
								COMMIT WORK;
								IF cBandDispActiva = 1 THEN
									BEGIN WORK; 
								END IF;
								IF dCanal != dCanal_sms THEN
									LET cCodRet = '00006';
								END IF;
								LET cMen_ret = '';
								RETURN cCodRet, cMen_ret;
							END IF;
						END IF;
					ELSE
						-- Error no cumplir con validaciones de ampliacion de horario. Se envia SMS de error: Por el momento no se puede realizar su peticion. Favor de intentarlo mas tarde.
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_APHR','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
						END IF;
						IF dCanal != dCanal_sms THEN
							LET cCodRet = '00006';
						END IF;
						LET cMen_ret = '';
						RETURN cCodRet, cMen_ret;
					END IF; --RQM 10 1155
					ELIF popcion = 3 THEN
					-- Proximo fecha y monto del pago. ---Su pago mensual es de $9999 y la fecha de pago es dia/mes/anio
						select limit 1 to_char(fecha_cuota, '%d/%m/%y'),capital_mto_cuota 
						into dtFechaProxPago,pMensualidad
						from bdicred:sd_amortiza_creditocrd  where num_credito = cCtaPPF and capital_status = '3';
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_CON','000000000','', '',1, '', trim(dtFechaProxPago), '', '', '', '', '', '', '', '', '', pNumCel,pMensualidad, 0,0, 0, 0, current, current) INTO cCodRet;			
						END IF;
						LET cMen_ret = '';
						RETURN cCodRet, cMen_ret;
					END IF;						
				END IF;
			END IF;
		ELSE --IPCB jul18/ Si no esta verificado, solicita que en sucursal valide su celular.
			--Tiene cuenta de Prestamo Flexible, pero no tiene Celular Verificado
            --Tienes un Prestamo Flexible activado pero tu celular no ha sido confirmado, te invitamos a sucursal para realizar la confirmacion
			IF cEnvioSMSRespMultic = '1' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_97000','PPF_SMS_VCEL','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			END IF;
			IF dCanal != dCanal_sms THEN
				LET cCodRet = '00010';
			END IF;
			LET cMen_ret = '';
			RETURN cCodRet, cMen_ret;
		END IF;	
	END IF;
--END IF;
IF cCodRet='000' THEN
	LET cCodRet='00000';
END IF;

RETURN cCodRet, cMen_ret;
     
END
END PROCEDURE
