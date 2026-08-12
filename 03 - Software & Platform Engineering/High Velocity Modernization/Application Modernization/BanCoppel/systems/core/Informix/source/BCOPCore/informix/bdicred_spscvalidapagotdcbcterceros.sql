CREATE PROCEDURE "informix".spscvalidapagotdcbcterceros(pEmpresa char(3),
                                                        pUsuario char(50),
                                                        pCtaOrigen char(20),
                                                        pCtaDestino char(20),
                                                        pMonto money(14,2))
	RETURNING char(5), char(20), char(20);

    -- Realizo   : Manuel Ramos Figueroa
    -- Actividad : Pago Tarjeta Credito Bancoppel a Terceros mismo Banco
    -- Fecha     :  07/06/2013

	DEFINE vcodret   char(5);
	DEFINE vUsuStatus smallint;
	DEFINE vSdoReal money(14,2);
	DEFINE vSdoActual money(14,2);
	DEFINE vSdoRetenido money(14,2);
	DEFINE vSdoCongelado money(14,2);
	DEFINE vNumTarjOrigen char(20);
	DEFINE vNumTarjDestino char(20);
	DEFINE sql_err   integer;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.
	
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vcodret = sql_err;
			RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;
		END IF;
	END EXCEPTION;

	LET vcodret = '000';
	LET vNumTarjOrigen = '0';
	LET vNumTarjDestino = '0';	
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;

	--Set debug file to '/home/informix/bibiana/spscvalidapagotdcbcterceros.out';
	--trace on;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	BEGIN
		--Se valida el status del usuario sea completamente activado
		SELECT id_status INTO vUsuStatus FROM bdinteg:si_bpiusuarios WHERE usuario = pUsuario;
		IF vUsuStatus <> 30 THEN
			RETURN '100', vNumTarjOrigen, vNumTarjDestino;
		END IF;

		--Se valida que el monto de la transferencia no sea mayor al saldo de la cuenta origen
		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
		SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc INTO vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSBC FROM bdicheq:sc_maechq WHERE cuenta = pCtaOrigen;
		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
		LET vSdoReal = vSdoActual - (vSdoRetenido + vSdoCongelado + mSaldoSBC);
		
		IF pMonto > vSdoReal THEN
			RETURN '200', vNumTarjOrigen, vNumTarjDestino;
		END IF;

		--Se obtiene el numero de tarjeta de la cuenta origen
		SELECT tr.num_tarjeta
		INTO vNumTarjOrigen
		FROM bdicheq:sc_maechq mc
		INNER JOIN bdicheq:sc_tarjeta tr ON mc.empresa = pEmpresa 
		AND mc.empresa = tr.empresa 
		AND mc.cuenta = pCtaOrigen 
		AND tr.cuenta = mc.cuenta 
		AND tr.tipo_tarjeta = 'T' 
		AND tr.status_tar = 'A';

		--Se obtiene el numero de tarjeta de la cuenta destino
		SELECT tr.num_tarjeta
		INTO vNumTarjDestino
		FROM bdicred:sd_maecred mc
		INNER JOIN bdicred:sd_tarjeta tr ON mc.empresa = pEmpresa 
		AND mc.empresa = tr.empresa 
		AND mc.num_credito = pCtaDestino 
		AND tr.num_credito = mc.num_credito 
		AND tr.tipo_tarjeta = 'T' 
		AND tr.status_tar = 'A';

		IF 	vNumTarjDestino is null then
			LET vNumTarjDestino = '';
		END IF;	

		IF 	vNumTarjOrigen is null then
			LET vNumTarjOrigen = '';
		END IF;	
	END;
	RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;
END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICRED',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_cancelacion_ctas_nunca_24m(pEmpresa CHAR(3)) 
RETURNING CHAR(6) AS cCodRet;

---DECLARACION DE VARIABLES
DEFINE iSqlErr 				INTEGER;
DEFINE isam_err 			INTEGER;
DEFINE error_info 			CHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cProceso         	CHAR(4);
DEFINE cCod_retBit      	CHAR(6);
DEFINE v_Mensaje			CHAR(100);
DEFINE v_MensajeAux			CHAR(100);
	
DEFINE iMonto_reduc			SMALLINT; 
DEFINE iMnto_increm			SMALLINT; 
DEFINE iMnto_reduc_Nunca	SMALLINT; 
DEFINE iMnto_increm_Nunca	SMALLINT; 
DEFINE iMnto_max_cancel		SMALLINT; 
DEFINE iMesEnvioSms			SMALLINT; 
DEFINE iMesReduccion		SMALLINT; 
DEFINE iMesCancelaCrd		SMALLINT; 
DEFINE iMnto_reduc_Inac		SMALLINT; 
DEFINE iMnto_increm_Inac	SMALLINT; 
DEFINE iMnto_max_canc_Inac	SMALLINT; 
DEFINE iMesEnvioSms_Inac	SMALLINT; 
DEFINE iMesReduccion_Inac	SMALLINT; 
DEFINE iMesCancelaCrd_Inac	SMALLINT; 
DEFINE dFechaHoy			DATE;
DEFINE dFechaMes1_sms		DATE;
DEFINE dFechaMes2_Reduc		DATE;
DEFINE dFechaMes3_Cancel	DATE;
DEFINE dFechMes1_sms_Inac	DATE;
DEFINE dFechMes2_Reduc_Ina	DATE;
DEFINE dFechMes3_Canc_Inac	DATE;
DEFINE cNumCredito			CHAR(20);
DEFINE cNumCte				CHAR(20);
DEFINE cNumProducto			CHAR(4);
DEFINE dFechaApertura		DATE;
DEFINE dMntoOtorgado		DECIMAL(18,2);
DEFINE dMntoOtorgOrig		DECIMAL(18,2);
DEFINE dAjuste_linea		DECIMAL(18,2);
DEFINE dSdoCapital			DECIMAL(18,2);
DEFINE iDifMeses			INTEGER;
DEFINE cStatusSms			CHAR(5);
DEFINE cTelefono			CHAR(13);
DEFINE cApPaterno 			CHAR(26);
DEFINE cGrupo				CHAR(1);
DEFINE cNumCrdAux			CHAR(20);
DEFINE cFolioSuc			CHAR(16);
DEFINE cFolioSucAux			CHAR(16);
DEFINE cSucursal			CHAR(4);
DEFINE cDivisa				CHAR(2);
DEFINE iContador			INTEGER;
DEFINE iContWork			INTEGER;
DEFINE dFechaAux			DATE;
DEFINE cMonto_1				MONEY(14,2);
DEFINE cMonto_2				MONEY(14,2);
DEFINE cCod_fun_1			VARCHAR(3);
DEFINE cCod_fun_2			VARCHAR(3);
DEFINE iStatus_Acl			INTEGER;
DEFINE cTipoCte				CHAR(1);

-- SET DEBUG FILE TO "/home/e10001176/Cancel_cta_24_m/sp_cancelacion_ctas_nunca_24m.out";
-- TRACE ON;

---INICIALIZACION DE VARIABLES
LET iSqlErr 			= 0;
LET isam_err 			= 0;
LET error_info 			= '';
LET cCodRet  			= '000000';
LET cProceso			= '0103';
LET cCod_retBit			= '000000';
LET v_Mensaje			= '';
LET v_MensajeAux		= '';
LET iMonto_reduc		= 0;
LET iMnto_reduc_Nunca	= 0;
LET iMnto_increm		= 0;
LET iMnto_increm_Nunca 	= 0;
LET iMnto_max_cancel	= 0;
LET iMesEnvioSms		= 0;
LET iMesReduccion		= 0;
LET iMesCancelaCrd		= 0;
LET iMnto_reduc_Inac	= 0; 
LET iMnto_increm_Inac	= 0; 
LET iMnto_max_canc_Inac	= 0; 
LET iMesEnvioSms_Inac	= 0; 
LET iMesReduccion_Inac	= 0; 
LET iMesCancelaCrd_Inac	= 0; 
LET dFechaHoy			= date(1);
LET dFechaMes1_sms		= date(1);
LET dFechaMes2_Reduc	= date(1);
LET dFechaMes3_Cancel	= date(1);
LET dFechMes1_sms_Inac	= date(1);
LET dFechMes2_Reduc_Ina	= date(1);
LET dFechMes3_Canc_Inac	= date(1);
LET cNumCredito			= '';
LET cNumCte				= '';
LET cNumProducto		= '';
LET dFechaApertura		= date(1);
LET dMntoOtorgado		= 0;
LET dMntoOtorgOrig		= 0;
LET dAjuste_linea		= 0;
LET dSdoCapital			= 0;
LET iDifMeses			= 0;
LET cStatusSms			= '';
LET cTelefono			= '';
LET cApPaterno			= '';
LET cGrupo				= '';
LET cNumCrdAux			= '';
LET cFolioSuc			= '';
LET cFolioSucAux		= '';
LET cSucursal			= '';
LET cDivisa				= '';
LET iContador			= 0;
LET iContWork 			= 0;
LET dFechaAux			= date(1);
LET cMonto_1			= 0;
LET cMonto_2			= 0;
LET cCod_fun_1			= '';
LET cCod_fun_2			= '';
LET iStatus_Acl			= 0;
LET cTipoCte			= '';


BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Error-"||trim(cNumCredito)||"-"||isam_err||"-"||trim(error_info), '02') Returning cCod_retBit;
	
	RETURN cCodRet;
END EXCEPTION;


-- Directiva para lectura de tablas bloqueadas. -- Se deshabilita las directivas para la lectura de tablas bloqueadas.
	--SET ISOLATION TO DIRTY READ; 
	--SET LOCK MODE TO WAIT 3;
	
	-- Lectura de parametros CREDITOS NUNCA
	SELECT valor::SMALLINT INTO iMnto_reduc_Nunca FROM bdicred:sd_param	WHERE cod_param = '35';		-- Monto para reduccion de linea ctes nunca
	SELECT valor::SMALLINT INTO iMnto_increm_Nunca FROM bdicred:sd_param WHERE cod_param = '36';	-- Monto para incremento de linea ctes nunca
	SELECT valor::SMALLINT INTO iMnto_max_cancel FROM bdicred:sd_param WHERE cod_param = '37';		-- Saldo maximo a favor para cancelacion de cuentas 
	SELECT valor::SMALLINT INTO iMesEnvioSms FROM bdicred:sd_param WHERE cod_param = '41';			-- Num de meses para envio de sms: 23 ctes nunca
	SELECT valor::SMALLINT INTO iMesReduccion FROM bdicred:sd_param WHERE cod_param = '42';			-- Num de meses para reduccion de linea: 24 ctes nunca
	SELECT valor::SMALLINT INTO iMesCancelaCrd FROM bdicred:sd_param WHERE cod_param = '43';		-- Numero de meses para cancelacion creditos nunca: 9,999 ctes nunca

	-- Lectura de parametros CREDITOS INACTIVOS	
	SELECT valor::SMALLINT INTO iMnto_reduc_Inac FROM bdicred:sd_param	WHERE cod_param = '67';		-- Monto para reduccion de linea ctes inactivos 
	SELECT valor::SMALLINT INTO iMnto_increm_Inac FROM bdicred:sd_param WHERE cod_param = '68';		-- Monto para incremento de linea ctes inactivos
	SELECT valor::SMALLINT INTO iMesEnvioSms_Inac FROM bdicred:sd_param WHERE cod_param = '96';		-- Num de meses para envio de sms: 23 ctes inactivos
	SELECT valor::SMALLINT INTO iMesReduccion_Inac FROM bdicred:sd_param WHERE cod_param = '97';	-- Num de meses para reduccion de linea: 24 ctes inactivos
	SELECT valor::SMALLINT INTO iMesCancelaCrd_Inac FROM bdicred:sd_param WHERE cod_param = '98';	-- Numero de meses para cancelacion creditos inactivos: 9,999
	
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas where empresa = '001';
	
	-- Calcula fechas de antiguedad creditos clientes nunca
	LET dFechaMes1_sms = monthadd(dFechaHoy, -iMesEnvioSms);
	LET dFechaMes2_Reduc = monthadd(dFechaHoy, -iMesReduccion);
	LET dFechaMes3_Cancel = monthadd(dFechaHoy, -iMesCancelaCrd);
	
	-- Calcula fechas de antiguedad creditos clientes inactivos	
	LET dFechMes1_sms_Inac = monthadd(dFechaHoy, -iMesEnvioSms_Inac);
	LET dFechMes2_Reduc_Ina = monthadd(dFechaHoy, -iMesReduccion_Inac);
	LET dFechMes3_Canc_Inac = monthadd(dFechaHoy, -iMesCancelaCrd_Inac);

	-- Registra inicio en bitacora
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia registro de creditos para envio de sms de aviso.", '02') Returning cCod_retBit;

	--------------------------------------------------------------------------------------------------
	-- Obtiene informacion de los creditos sin historial. Descarga temporales
	DROP TABLE IF EXISTS bdicred:tmp_indicador_camp;
	DROP TABLE IF EXISTS bdicred:tmp_maecred_nun;	
	
	-- Descarga informacion de los creditos a procesar en tablas temporales de clientes inactivos.	
	SELECT {+INDEX ("informix".sd_indicador_cred "informix".idx0sd_indicador_cred)} -- Se forza el uso de indices para la optimizacion de la consulta.
	  empresa, num_credito, fecha_alta, fecha_ultima_compra, fecha_ultimo_pago, f_primer_compra, f_primer_disp, atm_disp_fecha, vnt_disp_fecha, pos_disp_fecha
	  FROM bdicred:sd_indicador_cred
	 WHERE empresa = pEmpresa  
	   AND (fecha_ultima_compra = date(1) OR fecha_ultima_compra <= dFechMes1_sms_Inac OR fecha_ultima_compra is null) AND (fecha_ultimo_pago = date(1) OR fecha_ultimo_pago <= dFechMes1_sms_Inac OR fecha_ultimo_pago is null)
	    AND (f_primer_compra = date(1) OR f_primer_compra <= dFechMes1_sms_Inac OR f_primer_compra is null) AND (f_primer_disp = date(1) OR f_primer_disp <= dFechMes1_sms_Inac OR f_primer_disp is null)
	    AND (atm_disp_fecha = date(1) OR atm_disp_fecha <= dFechMes1_sms_Inac OR atm_disp_fecha is null) AND (vnt_disp_fecha = date(1) OR vnt_disp_fecha <= dFechMes1_sms_Inac OR vnt_disp_fecha is null)
	    AND (pos_disp_fecha = date(1) OR pos_disp_fecha <= dFechMes1_sms_Inac OR pos_disp_fecha is null) AND comportamiento = 3
	INTO temp tmp_indicador_camp WITH NO LOG;
	create index ix2_ind_numc24 on tmp_indicador_camp ( num_credito );			   
	
	SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, crd.status_cred, crd.sucursal, crd.divisa
	  FROM bdicred:sd_maecred crd, tmp_indicador_camp ind
	 WHERE crd.num_credito = ind.num_credito
	   AND crd.fecha_apertura <= dFechMes1_sms_Inac
	   AND crd.num_producto = '6001' AND (crd.status_cred IN ('AA','E1'))
      INTO temp tmp_maecred_nun WITH NO LOG;
	create index ix2_mae_nunc24 on tmp_maecred_nun ( num_credito );	


 --------------------------------------------------------------------------------------------------
	-- Obtiene informacion de los creditos sin historial. Registra el credito y envia el sms de aviso
	
	select {+INDEX(bdicred:sd_indicador_cred "informix".idx0sd_indicador_cred)}
	num_credito from sd_indicador_cred
	where empresa ='001'
		AND (f_primer_compra is null or f_primer_compra = date(1)) AND (fecha_ultima_compra is null or fecha_ultima_compra = date(1))
		AND (fecha_ultimo_pago is null or fecha_ultimo_pago = date(1)) AND (f_primer_disp is null or f_primer_disp = date(1)) 
		AND (atm_disp_fecha is null or atm_disp_fecha = date(1))       AND (vnt_disp_fecha is null or vnt_disp_fecha = date(1)) 
		AND (pos_disp_fecha is null or pos_disp_fecha = date(1))
		INTO temp tmp_sd_indicador_cred_his_sms WITH NO LOG;
	create index ix2_ind_shis on tmp_sd_indicador_cred_his_sms ( num_credito );
	
	LET iContWork = 1;
	FOREACH WITH HOLD
	  SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, 'N'
	    INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgado,		cTipoCte
	    FROM bdicred:sd_maecred crd 
		JOIN bdicred:sd_maesdos dos ON (crd.num_credito = dos.num_credito and dos.sdo_cap_insoluto <= 0 and dos.sdo_cap_insoluto >= iMnto_max_cancel and dos.sdo_retenido = 0)
		JOIN bdicred:tmp_sd_indicador_cred_his_sms ind ON (crd.num_credito = ind.num_credito)
	   WHERE crd.fecha_apertura <= dFechaMes1_sms AND crd.fecha_apertura > dFechaMes2_Reduc
	     AND crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
		 AND crd.num_credito NOT IN (select num_credito from bdicred:sd_cancela_creds_nunca)
	UNION	 
	  SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, 'I'
	  --  INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgado,		cTipoCte
	    FROM bdicred:tmp_maecred_nun crd 
		JOIN bdicred:sd_maesdos dos ON (crd.num_credito = dos.num_credito and dos.sdo_cap_insoluto = 0 and dos.sdo_retenido = 0)
		JOIN bdicred:tmp_indicador_camp ind ON (crd.num_credito = ind.num_credito 
		 AND ((nvl(f_primer_compra,date(1)) <= dFechMes1_sms_Inac and nvl(f_primer_compra,date(1)) > dFechMes2_Reduc_Ina) or nvl(f_primer_compra,date(1)) = date(1))
		 AND ((nvl(fecha_ultima_compra,date(1)) <= dFechMes1_sms_Inac and nvl(fecha_ultima_compra,date(1)) > dFechMes2_Reduc_Ina) or nvl(fecha_ultima_compra,date(1)) = date(1))
		 AND ((nvl(fecha_ultimo_pago,date(1)) <= dFechMes1_sms_Inac and nvl(fecha_ultimo_pago,date(1)) > dFechMes2_Reduc_Ina) or nvl(fecha_ultimo_pago,date(1)) = date(1))
		 AND ((nvl(f_primer_disp,date(1)) <= dFechMes1_sms_Inac and nvl(f_primer_disp,date(1)) > dFechMes2_Reduc_Ina) or nvl(f_primer_disp,date(1)) = date(1))
		 AND ((nvl(atm_disp_fecha,date(1)) <= dFechMes1_sms_Inac and nvl(atm_disp_fecha,date(1)) > dFechMes2_Reduc_Ina) or nvl(atm_disp_fecha,date(1)) = date(1))
		 AND ((nvl(vnt_disp_fecha,date(1)) <= dFechMes1_sms_Inac and nvl(vnt_disp_fecha,date(1)) > dFechMes2_Reduc_Ina) or nvl(vnt_disp_fecha,date(1)) = date(1))
		 AND ((nvl(pos_disp_fecha,date(1)) <= dFechMes1_sms_Inac and nvl(pos_disp_fecha,date(1)) > dFechMes2_Reduc_Ina) or nvl(pos_disp_fecha,date(1)) = date(1))
		 )
	   WHERE crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
		 AND crd.num_credito NOT IN (select num_credito from bdicred:sd_cancela_creds_nunca)

		SELECT count(*) INTO iStatus_Acl				-- Tiene aclaracion en proceso. No se procesa.
		  FROM bdiaclaracion:acl_aclaracion acl 
		  JOIN bdiaclaracion:acl_producto aclp ON (acl.num_cliente = aclp.num_cliente )
		 WHERE aclp.numero_cuenta = cNumCredito AND acl.fky_estatus_aclaracion = 2;
		IF iStatus_Acl > 0 THEN
			CONTINUE FOREACH;
		END IF; 
IF iContWork = 1 THEN
			BEGIN WORK;
		END IF; 
		
		-- Diferencia de meses entre fecha de apertura y fecha de hoy: meses de inactividad.
		LET iDifMeses = MONTHS_BETWEEN(dFechaHoy, dFechaApertura);

		-- Envia mensaje tipo sms al cliente
		SELECT limit 1 telefono INTO cTelefono FROM bdinteg:si_telefonos WHERE numcte = cNumCte AND tipo_tel = '2' AND status_tel = 'A';
		SELECT apell_paterno INTO cApPaterno FROM bdinteg:si_cliente WHERE numcte = cNumCte;
		SELECt NVL(grupo,'') INTO cGrupo FROM bdisolic:ss_revision_determinacion WHERE empresa = pEmpresa AND num_solicitud = cNumCredito;
		IF NVL(cGrupo, '') = '' THEN
			SELECT NVL(grupo,'') INTO cGrupo FROM bdisolic:ss_resum_scor_fin WHERE empresa = pEmpresa AND num_solicitud = cNumCredito;
		END IF;

		IF nvl(cTelefono, '') <> '' AND cGrupo IN ('1','2','3') THEN		-- Si tiene celular registrado y el credito es de un cliente coppel.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'CRED_SMS','CRD_CAN_24M','000000000','','',2,TRIM(cApPaterno),'','','','','','','','','','',cTelefono,0,0,0,0,0,current,current) INTO cCod_retBit;
			IF cCod_retBit <> '00000' THEN
				LET cStatusSms = cCod_retBit;
			ELSE
				LET cStatusSms = "1";
			END IF;
		ELSE
			LET cStatusSms = "0";
		END IF;
		

		INSERT INTO bdicred:sd_cancela_creds_nunca 
				   (empresa, num_credito, numcte, num_producto, fecha_mes_1_sms, status_sms_mes_1, meses_inactividad_sms, mnto_linea_credito_sms, tipo_cte, fecha_insert)
		    VALUES (pEmpresa,cNumCredito, cNumCte,cNumProducto, dFechaHoy,        cStatusSms,        iDifMeses,    			dMntoOtorgado       , cTipoCte,	CURRENT );

		LET iDifMeses = 0;
		LET cStatusSms = '';
		LET cApPaterno = '';

		IF iContWork >= 1000 THEN
			COMMIT WORK; 
			LET iContWork = 1;		
		ELSE
			LET iContWork = iContWork + 1;
		END IF;
				
	END FOREACH;
	
IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;
	
	----------------------------------------------------------------------------------------------------------
	-- Obtiene informacion de los creditos sin historial crediticio y realiza reduccion de linea.
	select {+INDEX (bdicred:sd_indicador_cred "informix".idx0sd_indicador_cred)}
	num_credito from sd_indicador_cred
	where 
		(f_primer_compra is null or f_primer_compra = date(1)) and (fecha_ultima_compra is null or fecha_ultima_compra = date(1))
		and (fecha_ultimo_pago is null or fecha_ultimo_pago = date(1)) and (f_primer_disp is null or f_primer_disp = date(1)) 
		and (atm_disp_fecha is null or atm_disp_fecha = date(1)) and (vnt_disp_fecha is null or vnt_disp_fecha = date(1)) 
		and (pos_disp_fecha is null or pos_disp_fecha = date(1))
		INTO temp tmp_sd_indicador_cred_his_reduc WITH NO LOG;
	create index ix2_ind_shis2 on tmp_sd_indicador_cred_his_reduc ( num_credito );
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia registro de creditos para reduccion de linea", '02') Returning cCod_retBit;
	LET iContWork = 1;
	FOREACH WITH HOLD
	  SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, NVL(nun.num_credito,''), crd.Sucursal, crd.divisa, 'N'
	    INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgado,		cNumCrdAux,              cSucursal,    cDivisa,	   cTipoCte
	    FROM bdicred:sd_maecred crd
		LEFT OUTER JOIN bdicred:sd_cancela_creds_nunca nun ON (crd.num_credito = nun.num_credito and status_cte_inactivo_2 is null)
		JOIN bdicred:sd_maesdos dos ON (crd.num_credito = dos.num_credito and dos.sdo_cap_insoluto <= 0 and dos.sdo_cap_insoluto >= iMnto_max_cancel and dos.sdo_retenido = 0)
		JOIN bdicred:tmp_sd_indicador_cred_his_reduc ind ON (crd.num_credito = ind.num_credito)					
	   WHERE crd.fecha_apertura <= dFechaMes2_Reduc AND crd.fecha_apertura > dFechaMes3_Cancel	
	     AND crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
		 AND nun.fecha_mes_2_reduc IS NULL
	UNION
	  SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, NVL(nun.num_credito,''), crd.Sucursal, crd.divisa, 'I'
	    --INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgado,		cNumCrdAux,              cSucursal,    cDivisa,	   cTipoCte
	    FROM bdicred:tmp_maecred_nun crd
		LEFT OUTER JOIN bdicred:sd_cancela_creds_nunca nun ON (crd.num_credito = nun.num_credito and status_cte_inactivo_2 is null)
		JOIN bdicred:sd_maesdos dos ON (crd.num_credito = dos.num_credito and dos.sdo_cap_insoluto = 0 and dos.sdo_retenido = 0)
		JOIN bdicred:tmp_indicador_camp ind ON (crd.num_credito = ind.num_credito
		 AND ((nvl(f_primer_compra,date(1)) <= dFechMes2_Reduc_Ina and nvl(f_primer_compra,date(1)) > dFechMes3_Canc_Inac) or nvl(f_primer_compra,date(1)) = date(1))
		 AND ((nvl(fecha_ultima_compra,date(1)) <= dFechMes2_Reduc_Ina and nvl(fecha_ultima_compra,date(1)) > dFechMes3_Canc_Inac) or nvl(fecha_ultima_compra,date(1)) = date(1)) 
		 AND ((nvl(fecha_ultimo_pago,date(1)) <= dFechMes2_Reduc_Ina and nvl(fecha_ultimo_pago,date(1)) > dFechMes3_Canc_Inac) or nvl(fecha_ultimo_pago,date(1)) = date(1))
		 AND ((nvl(f_primer_disp,date(1)) <= dFechMes2_Reduc_Ina and nvl(f_primer_disp,date(1)) > dFechMes3_Canc_Inac) or nvl(f_primer_disp,date(1)) = date(1))
		 AND ((nvl(atm_disp_fecha,date(1)) <= dFechMes2_Reduc_Ina and nvl(atm_disp_fecha,date(1)) > dFechMes3_Canc_Inac) or nvl(atm_disp_fecha,date(1)) = date(1))
		 AND ((nvl(vnt_disp_fecha,date(1)) <= dFechMes2_Reduc_Ina and nvl(vnt_disp_fecha,date(1)) > dFechMes3_Canc_Inac) or nvl(vnt_disp_fecha,date(1)) = date(1))
		 AND ((nvl(pos_disp_fecha,date(1)) <= dFechMes2_Reduc_Ina and nvl(pos_disp_fecha,date(1)) > dFechMes3_Canc_Inac) or nvl(pos_disp_fecha,date(1)) = date(1))
		 )
	   WHERE crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
		 AND nun.fecha_mes_2_reduc IS NULL	

		SELECT count(*) INTO iStatus_Acl				-- Tiene aclaracion en proceso. No se procesa.
		  FROM bdiaclaracion:acl_aclaracion acl 
		  JOIN bdiaclaracion:acl_producto aclp ON (acl.num_cliente = aclp.num_cliente )
		 WHERE aclp.numero_cuenta = cNumCredito AND acl.fky_estatus_aclaracion = 2;
		IF iStatus_Acl > 0 THEN
			CONTINUE FOREACH;
		END IF;		 
IF iContWork = 1 THEN
			BEGIN WORK;
		END IF; 	

		-- Realiza la reduccion de linea de credito
		IF cTipoCte = 'N' THEN
			LET iMonto_reduc = iMnto_reduc_Nunca;
		ELSE
			LET iMonto_reduc = iMnto_reduc_Inac;
		END IF;
		
		IF iMonto_reduc > 0 AND dMntoOtorgado > iMonto_reduc THEN				-- 
			UPDATE bdicred:sd_maesdos SET monto_otorgado = iMonto_reduc
			 WHERE empresa = pEmpresa AND num_credito = cNumCredito;
			
			-- Arma el folio del movimiento	
			--LET cFolioSucAux = 'informix' || NVL(SUBSTR(YEAR(dFechaHoy), 3, 2),'');
			LET cFolioSucAux = 'informix';
			EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM(cFolioSucAux))
			   INTO cCod_retBit, cFolioSuc;

			---  Graba movimiento sd_movdia
			LET dAjuste_linea = dMntoOtorgado - iMonto_reduc;
			IF dAjuste_linea > 0 THEN			-- Si la diferencia es mayor de cero, es decir existe una reduccion de linea.
				EXECUTE PROCEDURE GENMOV(pEmpresa, cNumCredito, cNumProducto, 2, '008', dFechaHoy, dAjuste_linea, cFolioSuc, cSucursal, cDivisa, '6697')
					INTO cCod_retBit, v_MensajeAux;
				   
				IF cCod_retBit::INTEGER <> 0 THEN	-- Si existio un error, regresa la linea anterior
					UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgado
					 WHERE empresa = pEmpresa AND num_credito = cNumCredito;
					 
					CONTINUE FOREACH;
				END IF;	
				IF nvl(cNumCrdAux,'') = '' THEN		-- No existe el registro previo del mes 1 (primeras ejecuciones), se inserta registro

					INSERT INTO bdicred:sd_cancela_creds_nunca 
						(empresa,  num_credito, numcte,  num_producto, fecha_mes_2_reduc, mnto_linea_original_2, mnto_linea_reduc_2, status_cte_inactivo_2, tipo_cte, fecha_insert)
					VALUES(pEmpresa, cNumCredito, cNumCte, cNumProducto, dFechaHoy,          dMntoOtorgado,          iMonto_reduc,       NULL				, cTipoCte,  current  );
		
				ELSE								-- Existe el registro desde el mes 1 y se actualizan los datos del mes 2.
					UPDATE bdicred:sd_cancela_creds_nunca SET fecha_mes_2_reduc = dFechaHoy, mnto_linea_original_2 = dMntoOtorgado, mnto_linea_reduc_2 = iMonto_reduc,
															status_cte_inactivo_2 = NULL
					WHERE num_credito = cNumCredito;
				END IF;
			END IF;		
		END IF;	
		
		IF iContWork >= 1000 THEN
			COMMIT WORK; 
			LET iContWork = 1;		
		ELSE
			LET iContWork = iContWork + 1;
		END IF;		
		
	END FOREACH;
	IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;
----------------------------------------------------------------------------------------------------------
	-- Realiza el 1er monitoreo de los creditos que tuvieron reduccion de linea de credito. 
	-- 	Si el credito realizo una compra y un pago, se le realiza el primer incremento de linea de credito.
	--		fecha_mes_2_reduc = Fecha en que se le realizo la reduccion de linea. 
	--		status_cte_inactivo_2.- Se marca con 1, cuando ya no se monitoreara dicho credito. Es decir el credito ya es inactivo y dejo de ser nunca
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia 1er monitoreo de creditos con compra", '02') Returning cCod_retBit;
	LET iContWork = 1;
	
	FOREACH WITH HOLD
	  SELECT {+INDEX ("informix".sd_cancela_creds_nunca "informix".idx_canc_nunca4), -- Se forza el uso de indices para la optimizacion de la consulta.
			  +INDEX ("informix".sd_maesdos "informix".idx_uni_maesdos_2),
			  +INDEX ("informix".sd_maecred "informix".idx_uni_maecred_2)}
	  crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, crd.Sucursal, crd.divisa, nun.tipo_cte, fecha_mes_2_reduc
      INTO cNumCredito,cNumCte,cNumProducto,dFechaApertura,dMntoOtorgado,cSucursal,cDivisa,cTipoCte,dFechaAux
	  FROM bdicred:sd_cancela_creds_nunca nun 
	  JOIN bdicred:sd_maesdos dos ON (nun.num_credito = dos.num_credito and nun.empresa = dos.empresa)
	  JOIN bdicred:sd_maecred crd ON (nun.num_credito = crd.num_credito and nun.empresa = crd.empresa AND nun.fecha_mes_2_reduc < MDY('06','02','2025') AND nun.status_cte_inactivo_2 IS NULL)
      where crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1') 
	  AND nun.fecha_mes_2_3 IS NULL AND nun.fecha_mes_2_2 IS NULL AND nun.fecha_mes_2_1 IS NULL

		-- Valida que el cliente haya realizado UNA COMPRA Y UN PAGO en el mes transcurrido posterior a la reduccion de linea. 
		IF cTipoCte = 'N' THEN								-- Clientes NUNCA
			SELECT {+index ("informix".sd_indicador_cred "informix".unix_sd_indicador_cred)}
			count(num_credito) INTO iContador
			FROM bdicred:sd_indicador_cred WHERE num_credito = cNumCredito
			AND empresa = '001' 
			AND (nvl(f_primer_compra,date(1)) > date(1)	 or nvl(fecha_ultima_compra,date(1)) > date(1)
			or nvl(f_primer_disp,date(1)) > date(1)	 or nvl(atm_disp_fecha,date(1)) > date(1)
			or nvl(vnt_disp_fecha,date(1)) > date(1) or nvl(pos_disp_fecha,date(1)) > date(1))
			AND (nvl(fecha_ultimo_pago,date(1)) > date(1));
					   
			LET iMnto_increm = iMnto_increm_Nunca;

		ELSE												-- Clientes INACTIVOS
			SELECT {+index ("informix".sd_indicador_cred "informix".unix_sd_indicador_cred)}
			count(num_credito) INTO iContador
			FROM bdicred:sd_indicador_cred WHERE num_credito = cNumCredito 
			AND (nvl(f_primer_compra,date(1)) >= dFechaAux   or nvl(fecha_ultima_compra,date(1)) >= dFechaAux 
			or nvl(f_primer_disp,date(1))  >= dFechaAux or nvl(atm_disp_fecha,date(1)) >= dFechaAux 
			or nvl(vnt_disp_fecha,date(1)) >= dFechaAux or nvl(pos_disp_fecha,date(1)) >= dFechaAux) 
			AND (nvl(fecha_ultimo_pago,date(1)) >= dFechaAux);	
					   
			LET iMnto_increm = iMnto_increm_Inac;	   
		END IF;		
IF iContador > 0 THEN	-- Realizo compra y pago
		
			-- Realiza el incremento de linea de credito
			LET dAjuste_linea = iMnto_increm - dMntoOtorgado;		-- El incremento (iMnto_increm) es mayor que el monto otorgado actual

			IF dAjuste_linea > 0 THEN								-- Es decir, existe un monto de incremento.
			
				IF iContWork = 1 THEN
					BEGIN WORK;
				END IF
			
				UPDATE bdicred:sd_maesdos SET monto_otorgado = iMnto_increm
				WHERE empresa = pEmpresa AND num_credito = cNumCredito;

				-- Arma el folio del movimiento	
				--LET cFolioSucAux = 'Can24m' || NVL(SUBSTR(YEAR(dFechaHoy), 3, 2),'');
				LET cFolioSucAux = 'informix';
				EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM(cFolioSucAux))
				   INTO cCod_retBit, cFolioSuc;

				---  Graba movimiento sd_movdia
				EXECUTE PROCEDURE GENMOV(pEmpresa, cNumCredito, cNumProducto, 1, '008', dFechaHoy, dAjuste_linea, cFolioSuc, cSucursal, cDivisa, '6696')
				   INTO cCod_retBit, v_MensajeAux;
				   
				IF cCod_retBit::INTEGER <> 0 THEN	-- Si existio un error, regresa la linea anterior
					UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgado
					WHERE empresa = pEmpresa AND num_credito = cNumCredito;
					 
					CONTINUE FOREACH; 
				END IF;
				
				-- Se actualiza fecha de 1er monitoreo, ya que 1er compra se realizo entre fecha reduccion y antes de fecha cancelacion. (puede ser mas de un mes de diferencia)
				UPDATE bdicred:sd_cancela_creds_nunca SET fecha_mes2_restaur_1 = dFechaHoy, mnto_linea_restau_2_1 = iMnto_increm, fecha_mes_2_1 = dFechaHoy
				WHERE num_credito = cNumCredito;
		
				IF iContWork >= 1000 THEN
					COMMIT WORK; 
					LET iContWork = 1;		
				ELSE
					LET iContWork = iContWork + 1;
				END IF;
			END IF;		
		END IF;
	
	END FOREACH;
	IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;
----------------------------------------------------------------------------------------------------------
	-- Realiza el 2do monitoreo de los creditos que tuvieron reduccion de linea de credito. 
	-- 	El credito ha realizado compras o pagos en el mes para poder continuar con el monitoreo.
	--		status_cte_inactivo_2.- Se marca con 1, cuando ya no se monitoreara dicho credito. Ya es cliente inactivo y no se monitoreara los siguientes meses
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia 2do monitoreo de creditos con compras", '02') Returning cCod_retBit;
	LET iContWork = 1;	
	
	FOREACH WITH HOLD
	  SELECT {+INDEX ("informix".sd_cancela_creds_nunca "informix".idx_canc_nunca4), -- Se forza el uso de indices para la optimizacion de la consulta.
	  +INDEX ("informix".sd_maecred "informix".idx_uni_maecred_2),
	  +INDEX ("informix".sd_maesdos "informix".idx_uni_maesdos_2)}
	  crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, crd.Sucursal, crd.divisa, fecha_mes_2_1
	  INTO cNumCredito,cNumCte,cNumProducto,dFechaApertura,cSucursal,cDivisa,dFechaAux
	  FROM bdicred:sd_cancela_creds_nunca nun
	  JOIN bdicred:sd_maecred crd ON (nun.num_credito = crd.num_credito and nvl(nun.fecha_mes_2_reduc, date(1)) > date(1) and nun.fecha_mes_2_reduc < dFechaHoy and status_cte_inactivo_2 is null)
	  JOIN bdicred:sd_maesdos dos ON ( crd.empresa = dos.empresa and crd.num_credito = dos.num_credito)
	  WHERE crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
	  AND nun.fecha_mes_2_3 IS NULL AND nun.fecha_mes_2_2 IS NULL AND (nvl(nun.fecha_mes_2_1, date(1)) > date(1) AND nun.fecha_mes_2_1 < dFechaHoy)
		 
		IF iContWork = 1 THEN
			BEGIN WORK;
		END IF;
		
		 -- Valida que el cliente haya realizado UNA COMPRA Y UN PAGO en el mes transcurrido posterior al 1er monitoreo (dFechaAux). 
		SELECT count(num_credito) INTO iContador
		FROM bdicred:sd_indicador_cred WHERE num_credito = cNumCredito 
		AND (nvl(f_primer_compra, date(1)) > dFechaAux   or nvl(fecha_ultima_compra, date(1)) > dFechaAux 
		or nvl(f_primer_disp, date(1)) > dFechaAux  or nvl(atm_disp_fecha, date(1)) > dFechaAux 
		or nvl(vnt_disp_fecha, date(1)) > dFechaAux or nvl(pos_disp_fecha, date(1)) > dFechaAux)
		AND (nvl(fecha_ultimo_pago, date(1)) > dFechaAux );

		IF iContador > 0 THEN	-- El cliente realizo compra y pago despues del primer monitoreo. Se marca para 3er monitoreo.

			UPDATE bdicred:sd_cancela_creds_nunca SET fecha_mes_2_2 = dFechaHoy WHERE num_credito = cNumCredito;		
		
		ELSE	-- El cliente no realizo compra y pago, se registra fecha de cambio a status cliente inactivo con campo: fecha_mes_2_2
			UPDATE bdicred:sd_cancela_creds_nunca SET status_cte_inactivo_2 = '1', fecha_mes_2_2 = dFechaHoy WHERE num_credito = cNumCredito;		
		END IF;	

		IF iContWork >= 1000 THEN
			COMMIT WORK; 
			LET iContWork = 1;		
		ELSE
			LET iContWork = iContWork + 1;
		END IF;
	
	END FOREACH;
IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;	
	
	----------------------------------------------------------------------------------------------------------
	-- Realiza el 3er monitoreo de los creditos que tuvieron reduccion de linea de credito. 
	-- 	El credito ha realizado compras o pagos en el mes para poder reestablecer su linea original.
	--		status_cte_inactivo_2.- Se marca con 1, cuando ya no se monitoreara dicho credito. Es decir el credito ya es inactivo y dejo de ser nunca
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia 3er monitoreo de creditos con compras", '02') Returning cCod_retBit;
	LET cStatusSms = "1";
	LET iContWork = 1;
	
	FOREACH WITH HOLD
	  SELECT {+INDEX ("informix".sd_cancela_creds_nunca "informix".idx_canc_nunca4), -- Se forza el uso de indices para la optimizacion de la consulta.
	  +INDEX ("informix".sd_maecred "informix".idx_uni_maecred_2),
	  +INDEX ("informix".sd_maesdos "informix".idx_uni_maesdos_2)}
	  crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, nun.mnto_linea_original_2, crd.Sucursal, crd.divisa, nun.fecha_mes_2_2
	  INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgOrig,			    cSucursal,    cDivisa,    dFechaAux
	  FROM bdicred:sd_cancela_creds_nunca nun
	  JOIN bdicred:sd_maecred crd ON (nun.num_credito = crd.num_credito and nvl(nun.fecha_mes_2_reduc, date(1)) > date(1) and nun.fecha_mes_2_reduc < dFechaHoy and status_cte_inactivo_2 is null)
	  JOIN bdicred:sd_maesdos dos ON ( crd.empresa = dos.empresa and crd.num_credito = dos.num_credito)
	  WHERE crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
	  AND fecha_mes_2_3 IS NULL AND (nvl(nun.fecha_mes_2_2, date(1)) > date(1) AND nun.fecha_mes_2_2 < dFechaHoy) AND (nvl(nun.fecha_mes_2_1, date(1)) > date(1) AND nun.fecha_mes_2_1 < dFechaHoy)
IF iContWork = 1 THEN
			BEGIN WORK;
		END IF;
		
		-- Valida que el cliente haya realizado UNA COMPRA Y UN PAGO en el mes transcurrido posterior al 2do monitoreo (dFechaAux). 
		SELECT count(num_credito) INTO iContador
		FROM bdicred:sd_indicador_cred WHERE num_credito = cNumCredito 
		AND (nvl(f_primer_compra, date(1)) > dFechaAux   or nvl(fecha_ultima_compra, date(1)) > dFechaAux 
		or nvl(f_primer_disp, date(1)) > dFechaAux  or nvl(atm_disp_fecha, date(1)) > dFechaAux 
		or nvl(vnt_disp_fecha, date(1)) > dFechaAux or nvl(pos_disp_fecha, date(1)) > dFechaAux)
		AND (nvl(fecha_ultimo_pago, date(1)) > dFechaAux );
	
		IF iContador > 0 THEN	--	El cliente realizo pago y compra en el ultimo (3er) mes. Se restaura su linea de credito
	
			-- Arma el folio del movimiento	
			--LET cFolioSucAux = 'Can24m' || NVL(SUBSTR(YEAR(dFechaHoy), 3, 2),'');
			LET cFolioSucAux = 'informix';
			EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM(cFolioSucAux))
			   INTO cCod_retBit, cFolioSuc;

			-- Obtiene el monto actual de la linea de credito
			SELECT monto_otorgado INTO dMntoOtorgado FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito; 
			
			IF dMntoOtorgado > dMntoOtorgOrig THEN		-- El monto actual (2000) es mayor al monto original. Es reduccion de linea
			
				LET dAjuste_linea = dMntoOtorgado - dMntoOtorgOrig;
				
				UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgOrig
				 WHERE empresa = pEmpresa AND num_credito = cNumCredito;

				EXECUTE PROCEDURE GENMOV(pEmpresa, cNumCredito, cNumProducto, 2, '008', dFechaHoy, dAjuste_linea, cFolioSuc, cSucursal, cDivisa, '6697')
				INTO cCod_retBit, v_MensajeAux;
				IF cCod_retBit::INTEGER <> 0 THEN								-- Si existio un error, regresa la linea anterior
					UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgado WHERE empresa = pEmpresa AND num_credito = cNumCredito;
					
				END IF;
	ELSE										-- El monto actual (2000) es menor al monto original, se realiza un incremento de linea de credito
				
				LET dAjuste_linea = dMntoOtorgOrig - dMntoOtorgado;
				
				UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgOrig
				 WHERE empresa = pEmpresa AND num_credito = cNumCredito;			
				 
				---  Graba movimiento sd_movdia
				EXECUTE PROCEDURE GENMOV(pEmpresa, cNumCredito, cNumProducto, 1, '008', dFechaHoy, dAjuste_linea, cFolioSuc, cSucursal, cDivisa, '6696')
				   INTO cCod_retBit, v_MensajeAux;				 
				IF cCod_retBit::INTEGER <> 0 THEN								-- Si existio un error, regresa la linea anterior
					UPDATE bdicred:sd_maesdos SET monto_otorgado = dMntoOtorgado WHERE empresa = pEmpresa AND num_credito = cNumCredito;
				END IF;
			
			END IF;
			
			IF cCod_retBit::INTEGER = 0 THEN		-- Si la actualizacion fue correcta.
			
				UPDATE bdicred:sd_cancela_creds_nunca SET fecha_mes_2_3 = dFechaHoy, fecha_mes2_restaur_fin = dFechaHoy, 
				                                          mnto_linea_restau_2_fin = dMntoOtorgOrig, status_cte_inactivo_2 = '1' 
				WHERE empresa = pEmpresa AND num_credito = cNumCredito;			
				
			END IF;
	 
		ELSE					-- El cliente no realizo un pago y compra en el 3er mes.

			UPDATE bdicred:sd_cancela_creds_nunca SET status_cte_inactivo_2 = '1', fecha_mes_2_3 = dFechaHoy
		 	 WHERE num_credito = cNumCredito;
		
		END IF;
	
		LET dMntoOtorgado = 0; 
		LET dMntoOtorgOrig = 0;
		LET cCod_retBit = '';
		LET v_MensajeAux = '';
		LET cFolioSuc = '';
		
		IF iContWork >= 1000 THEN
			COMMIT WORK; 
			LET iContWork = 1;		
		ELSE
			LET iContWork = iContWork + 1;
		END IF;		
END FOREACH;
	IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;	
	
	----------------------------------------------------------------------------------------------------------
	-- Obtiene informacion de los creditos con N meses sin historial crediticio y realiza cancelacion de linea de credito.
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicia cancelacion de creditos nunca", '02') Returning cCod_retBit;
	LET iContWork = 1;

	-- Se genera tabla temporal de sd_indicador_cred
	SELECT num_credito, f_primer_compra, fecha_ultimo_pago, atm_disp_fecha, pos_disp_fecha 
		FROM bdicred:sd_indicador_cred
		WHERE (f_primer_compra IS NULL OR f_primer_compra = date(1)) AND (fecha_ultima_compra IS NULL OR fecha_ultima_compra = date(1))
			AND (fecha_ultimo_pago IS NULL OR fecha_ultimo_pago = date(1)) AND (f_primer_disp IS NULL OR f_primer_disp = date(1)) 
			AND (atm_disp_fecha IS NULL OR atm_disp_fecha = date(1)) AND (vnt_disp_fecha IS NULL OR vnt_disp_fecha = date(1)) 
			AND (pos_disp_fecha IS NULL OR pos_disp_fecha = date(1))
		INTO TEMP tmp_indicador_canl_nun with no log;
	
	CREATE INDEX ix_cred_nunc_m ON tmp_indicador_canl_nun ( num_credito );
			
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_indicador_canl_nun;

	select {+INDEX (bdicred:sd_cancela_creds_nunca "informix".idx_canc_nunca2)}
	num_credito from sd_cancela_creds_nunca
	where empresa='001'
	INTO TEMP tmp_sd_cancela_creds_nunca with no log;
	CREATE INDEX ix_creds_nunc_m ON tmp_sd_cancela_creds_nunca ( num_credito );

	FOREACH WITH HOLD
	  SELECT crd.num_credito, crd.numcte, crd.num_producto, crd.fecha_apertura, dos.monto_otorgado, NVL(nun.num_credito,''), crd.Sucursal, crd.divisa, dos.sdo_cap_insoluto
	  INTO cNumCredito,     cNumCte,    cNumProducto,     dFechaApertura,     dMntoOtorgado,		cNumCrdAux,              cSucursal,    cDivisa,	   dSdoCapital
	  FROM bdicred:sd_maecred crd
	  LEFT OUTER JOIN bdicred:tmp_sd_cancela_creds_nunca nun ON (crd.num_credito = nun.num_credito )--and status_cte_inactivo_2 is null)
	  JOIN bdicred:sd_maesdos dos ON (crd.num_credito = dos.num_credito and dos.sdo_cap_insoluto <= 0 and dos.sdo_cap_insoluto >= iMnto_max_cancel and dos.sdo_retenido = 0)
	  JOIN bdicred:tmp_indicador_canl_nun ind ON (crd.num_credito = ind.num_credito)				
	  WHERE crd.fecha_apertura <= dFechaMes3_Cancel
	  
	  AND crd.num_producto = '6001' AND crd.status_cred IN ('AA','E1')
			
		SELECT count(*) INTO iStatus_Acl				-- Tiene aclaracion en proceso. No se procesa.
		FROM bdiaclaracion:acl_aclaracion acl 
		JOIN bdiaclaracion:acl_producto aclp ON (acl.num_cliente = aclp.num_cliente )
		WHERE aclp.numero_cuenta = cNumCredito AND acl.fky_estatus_aclaracion = 2;
		IF iStatus_Acl > 0 THEN
			CONTINUE FOREACH;
		END IF;
IF iContWork = 1 THEN
			BEGIN WORK;
		END IF;		
		
		IF dSdoCapital < 0 THEN
			-- Arma el folio del movimiento	
			--LET cFolioSucAux = 'Can24m' || NVL(SUBSTR(YEAR(dFechaHoy), 3, 2),'');
			LET cFolioSucAux = 'informix';
			EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM(cFolioSucAux))
			   INTO cCod_retBit, cFolioSuc;	

			EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa,cNumCredito,cSucursal,'informix','8309',abs(dSdoCapital),cFolioSuc,'',	0,cDivisa,dFechaHoy,'CARGO POR CANC SALDO A FAVOR CTAS NUNCA','','')
			INTO cCod_retBit;
			IF cCod_retBit::INTEGER != 0 THEN		-- Ocurrio un error en el cargo, no continue con el proceso de cancelacion de ese credito.
				CONTINUE FOREACH;
			END IF;
		END IF;
		
		-- Libera los montos de reservas ????
		LET cMonto_1 = 0;			LET cMonto_2 = 0;			LET cCod_fun_1 = '';			LET cCod_fun_2 = '';		LET dFechaAux = date(1);
		
		
		SELECT max(fecha_mov) INTO dFechaAux FROM bdicred:"informix".sd_movhis_calif WHERE num_credito = cNumCredito and empresa = '001';
		
		SELECT monto, codigo_fun INTO cMonto_1, cCod_fun_1
		  FROM bdicred:sd_movhis_calif WHERE empresa = pEmpresa AND fecha_mov = dFechaAux AND num_credito = cNumCredito AND codigo_fun = '091';
					
		SELECT monto, codigo_fun INTO cMonto_2, cCod_fun_2
		  FROM bdicred:sd_movhis_calif WHERE empresa = pEmpresa AND fecha_mov = dFechaAux AND num_credito = cNumCredito AND codigo_fun = '090';

		IF cCod_fun_1 IS NOT NULL THEN
			EXECUTE PROCEDURE "informix".genmov(pEmpresa,cNumCredito,cNumProducto,20,cCod_fun_1,dFechaHoy,cMonto_1,"LibCalifCart",cSucursal,cDivisa,'cSucursal')
			   INTO cCod_retBit, v_MensajeAux;
		END IF;

		IF cCod_fun_2 IS NOT NULL THEN
			EXECUTE PROCEDURE "informix".genmov(pEmpresa,cNumCredito,cNumProducto,20,cCod_fun_2,dFechaHoy,cMonto_2,"LibCalCartReserv",cSucursal,cDivisa,'cSucursal')
			   INTO cCod_retBit, v_MensajeAux;
		END IF;

		-- Cancela linea de credito
	EXECUTE PROCEDURE "informix".sp_cancelarcredito(pEmpresa,cNumCredito,'6','informix','informix','6',cSucursal)
		INTO cCod_retBit, cFolioSucAux; 
		
		IF cCod_retBit<> 0 THEN -- Se agrega continuacion del contador en caso de que un credito venga bloqueado para que continue el proceso
			IF  iContWork >= 1000 THEN
				COMMIT WORK;
				LET iContWork = 1;
			ELSE
				LET iContWork = iContWork + 1;
			END IF;
			CONTINUE FOREACH;
		END IF;
	
		LET iDifMeses = MONTHS_BETWEEN(dFechaHoy, dFechaApertura);
		IF nvl(cNumCrdAux,'') = '' THEN		-- No existe el registro desde meses anteriores, por lo que se inserta como nuevo.

			INSERT INTO bdicred:sd_cancela_creds_nunca(empresa,  num_credito, numcte,  num_producto, fecha_mes_2_cancela, monto_linea_cancelacion, saldo_credito_cancelacion, meses_inactividad_cancela, fecha_insert)
			                                    VALUES(pEmpresa, cNumCredito, cNumCte, cNumProducto, dFechaHoy,           dMntoOtorgado,           dSdoCapital,               iDifMeses,                 CURRENT );
				
		ELSE								-- Se actualizan los datos del registro existente 
		
			UPDATE bdicred:sd_cancela_creds_nunca SET fecha_mes_2_cancela = dFechaHoy, monto_linea_cancelacion = dMntoOtorgado, 
					saldo_credito_cancelacion = dSdoCapital, meses_inactividad_cancela = iDifMeses WHERE num_credito = cNumCredito;
		
		END IF;
	
		IF iContWork >= 1000 THEN
			COMMIT WORK; 
			LET iContWork = 1;		
		ELSE
			LET iContWork = iContWork + 1;
		END IF;
		
	END FOREACH;
	IF iContWork > 1 THEN
		COMMIT WORK; 
	END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Finaliza proceso de cancelacion cuentas nunca 24m", '02') Returning cCod_retBit;

	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Procedimiento para realizar la cancelacion de creditos nunca con 24 meses sin realizar movimientos desde su fecha de apertura',
'Fecha: Febrero 2020';

CREATE PROCEDURE "informix".sp_plan_pausa_candidatos_consulta_diaria(
    ) RETURNING
    CHAR(6)       AS codigo_retorno,
    VARCHAR(100)  AS mError        ;
--
--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--Creacion: JBL - SCP
--Descripcion: Procedimiento para generar layout con los clientes prospectos para plan en pausa
--RQM 09 636 Plan en Pausa tarjeta clasica
--Equipo TCCCREDITO 16
--Fecha: 2024/11
--Version: 
--------------------------------------------------------------------------------------------------------------
-- Variables de control de errores
    DEFINE iIsamErr                 INTEGER     ;
    DEFINE iSqlErr                  INTEGER     ;
    DEFINE cErrorInfo               CHAR(80)    ;
    DEFINE cCodRet          	    CHAR(6)     ;
    DEFINE vcDirectorio             VARCHAR(100);
    DEFINE vcNombreArchivoFinal     VARCHAR(100);
    DEFINE cFecha_Actual            CHAR(8)     ;
    DEFINE vcNombreArchivo          VARCHAR(100);
    DEFINE vcNombreArchivov         VARCHAR(100);
    DEFINE mError                   VARCHAR(100);
    -- Variables generales
    DEFINE csSQL                    LVARCHAR(10000);
    DEFINE csSQLAux                 LVARCHAR(10000);
    -- Variables relacionadas con las tablas
    DEFINE cNum_Cte                 CHAR(20);
    DEFINE cNum_Credito             CHAR(20);
    DEFINE cNum_Producto            CHAR(4) ;
    DEFINE vcNombre_Com             VARCHAR(100) ;
    DEFINE dLinea_Credito           DECIMAL(18,2);
    DEFINE dPago_Minimo             DECIMAL(18,2);
    DEFINE dPago_minimo_pendiente   DECIMAL(18,2);
    DEFINE dtFecha_Corte            DATE;
    DEFINE dtFecha_Pago             DATE;
    DEFINE dtFecha_Originacion      DATE;
    DEFINE dSaldo_Revolvente        DECIMAL(18,2);
    DEFINE dSaldo_Para_Plan         DECIMAL(18,2);
    DEFINE iPlazo_Sugerido          INTEGER;
    DEFINE iTasa_Interes            INTEGER;
    DEFINE cNum_Telefono_casa       CHAR(13);
    DEFINE cCanal                   CHAR(3);
    DEFINE cCampania                CHAR(20);
    DEFINE cCalle                   CHAR(40);
    DEFINE cNum_Casa                CHAR(39);
    DEFINE cColonia                 CHAR(60);
    DEFINE cNum_Celular             CHAR(13);
    DEFINE cMunicipio               CHAR(30);
    DEFINE cEstado                  CHAR(30);
    DEFINE cCp                      CHAR(5);
    DEFINE vcEmail                  CHAR(100);
    DEFINE cNum_Credito_Bitac       CHAR(20);
    DEFINE iEstatusBitacora         SMALLINT;
    -- Variables auxiliares
    DEFINE vcAbono_TotalText        VARCHAR(21);
    DEFINE dSaldo_Maesdos           DECIMAL(18,2);
    DEFINE dSaldoVencido_Maesdos    DECIMAL(18,2);
    DEFINE dPlan_12_Aux             DECIMAL(18,2);
    DEFINE dPlan_18_Aux             DECIMAL(18,2);
    DEFINE dPlan_24_Aux             DECIMAL(18,2);
    DEFINE dtFecha_Hoy              DATE;
    DEFINE dtFecha_Liquidacion      DATE;
    -- Variables para proyeccion de credito
    DEFINE cResCodRet12             CHAR(6);
    DEFINE iResPeriodo12            INTEGER;
    DEFINE dtResFechaCouta12        DATE;
    DEFINE dResSdoInicial12         DECIMAL(18,2);
    DEFINE dResMensualidad212       DECIMAL(18,2);
    DEFINE dResIntereses12          DECIMAL(18,2);
    DEFINE dResIvaIn12              DECIMAL(18,2);
    DEFINE dResCapital12            DECIMAL(18,2);
    DEFINE dResSdoFinal12           DECIMAL(18,2);
    DEFINE sResDiasPeriodo12        SMALLINT;
    DEFINE dtResFechaAper12         DATE;
    DEFINE cResPlazo12              CHAR(3);
    -- Variables para plazos 18 y 24 meses (similar a las de 12 meses)
    DEFINE cResCodRet18         CHAR(6);
    DEFINE iResPeriodo18        INTEGER;
    DEFINE dtResFechaCouta18    DATE;
    DEFINE dResSdoInicial18     DECIMAL(18,2);
    DEFINE dResMensualidad218   DECIMAL(18,2);
    DEFINE dResIntereses18      DECIMAL(18,2);
    DEFINE dResIvaIn2418        DECIMAL(18,2);
    DEFINE dResCapital18        DECIMAL(18,2);
    DEFINE dResSdoFinal18       DECIMAL(18,2);
    DEFINE sResDiasPeriodo18    SMALLINT;
    DEFINE dtResFechaAper18     DATE;
    DEFINE cResPlazo18          CHAR(3);
    DEFINE cResCodRet24         CHAR(6);
    DEFINE iResPeriodo24        INTEGER;
    DEFINE dtResFechaCouta24    DATE;
    DEFINE dResSdoInicial24     DECIMAL(18,2);
    DEFINE dResMensualidad224   DECIMAL(18,2);
    DEFINE dResIntereses24      DECIMAL(18,2);
    DEFINE dResIvaIn2424        DECIMAL(18,2);
    DEFINE dResCapital24        DECIMAL(18,2);
    DEFINE dResSdoFinal24       DECIMAL(18,2);
    DEFINE sResDiasPeriodo24    SMALLINT;
    DEFINE dtResFechaAper24     DATE;
    DEFINE cResPlazo24          CHAR(3);
    -- Variables adicionales
    DEFINE cSucursal            CHAR(4);
    DEFINE iNumPromocion        INTEGER;
    DEFINE iPlazo12             INTEGER;
    DEFINE iPlazo18             INTEGER;
    DEFINE iPlazo24             INTEGER;
    --DEFINE dtFechaSistema       DATE;
	DEFINE i_dia_cuota			smallint;
	DEFINE dt_fecha_corte_mas_reciente date;
    DEFINE cBegin               CHAR(1);
    DEFINE iContador            INTEGER;
	DEFINE X 					SMALLINT;
    -- Inicializacion de variables
    LET cNum_Cte             = '';
    LET cNum_Credito         = '';
    LET cNum_Producto        = '';
    LET vcNombre_Com         = '';
    LET dLinea_Credito       = 0.00;
    LET dPago_Minimo         = 0.00;
    LET dtFecha_Corte        = DATE(1);
    LET dtFecha_Pago         = DATE(1);
    LET dtFecha_Originacion  = DATE(1);
    LET dSaldo_Revolvente    = 0.00;
    LET dSaldo_Para_Plan     = 0.00;
    LET iPlazo_Sugerido      = 0;
    LET iTasa_Interes        = 0;
    LET cNum_Telefono_casa   = '';
    LET cCanal               = '';
    LET cCampania            = '';
    LET cCalle               = '';
    LET cNum_Casa            = '';
    LET cColonia             = '';
    LET cNum_Celular         = '';
    LET cMunicipio           = '';
    LET cEstado              = '';
    LET cCp                  = '';
    LET vcEmail              = '';
    LET cNum_Credito_Bitac   = '';
    LET vcAbono_TotalText    = '';
    LET dSaldo_Maesdos       = 0.00;
    LET dPlan_12_Aux         = 0.00;
    LET dPlan_18_Aux         = 0.00;
    LET dPlan_24_Aux         = 0.00;
    LET cSucursal            = '4901';
    LET iNumPromocion        = 11;
    LET iEstatusBitacora     = 0;
    --
    LET  cResCodRet12         ='';
    LET  iResPeriodo12        = 0;
    LET  dtResFechaCouta12    = DATE(1);
    LET  dResSdoInicial12     = 0.0;
    LET  dResMensualidad212   = 0.0;
    LET  dResIntereses12      = 0.0;
    LET  dResIvaIn12          = 0.0;
    LET  dResCapital12        = 0.0;
    LET  dResSdoFinal12       = 0.0;
    LET  sResDiasPeriodo12    = 0;
    LET  dtResFechaAper12     = DATE(1);
    LET  cResPlazo12          = '';
    --
    LET  cResCodRet18            = '';
    LET  iResPeriodo18           = 0;
    LET  dtResFechaCouta18       = DATE(1);
    LET  dResSdoInicial18        = 0.0 ;
    LET  dResMensualidad218      = 0.0 ;
    LET  dResIntereses18         = 0.0 ;
    LET  dResIvaIn2418           = 0.0 ;
    LET  dResCapital18           = 0.0 ;
    LET  dResSdoFinal18          = 0.0 ;
    LET  sResDiasPeriodo18       = 0 ;
    LET  dtResFechaAper18        = DATE(1);
    LET  cResPlazo18             = '';
    LET cResCodRet24             = '';
    LET iResPeriodo24            = 0;
    LET dtResFechaCouta24        = DATE(1);
    LET dResSdoInicial24         = 0.0 ;
    LET dResMensualidad224       = 0.0 ;
    LET dResIntereses24          = 0.0 ;
    LET dResIvaIn2424            = 0.0 ;
    LET dResCapital24            = 0.0 ;
    LET dResSdoFinal24           = 0.0 ;
    LET sResDiasPeriodo24        = 0;
    LET dSaldoVencido_Maesdos    = 0.0 ;
    LET dPago_minimo_pendiente   = 0.0 ;
    LET dtResFechaAper24         = DATE(1);
    LET cResPlazo24              = '';
    LET iPlazo12                 = 12;
    LET iPlazo18                 = 18;
    LET iPlazo24                 = 24;
    --LET dtFechaSistema           = DATE(1);
    LET dtFecha_Hoy              = DATE(1);
    LET dtFecha_Liquidacion      = DATE(1);
    -- Inicializacion de control de errores
    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = '';
    LET cCodRet               = '';
    LET vcDirectorio          = '';
    LET vcNombreArchivo       = '';
    LET vcNombreArchivov      = '';	
    LET vcNombreArchivoFinal  = '';
    LET cFecha_Actual         = '19000101';
    LET csSQLAux              = '';
    LET mError                = '';
    LET iContador             = 0;
    ----------------------------------- 
    BEGIN 
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

            LET cCodRet     = iSqlErr;
            LET mError      = iSqlErr || ' ' || iIsamErr || ' ' ||cErrorInfo;

            IF (cBegin = "S") THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;

            RETURN cCodRet, mError;

        END EXCEPTION;
        -- 
        ON EXCEPTION IN (-535)
            LET cBegin = "S";
            COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

        -- SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        -- SET DEBUG FILE TO '/informix/planes_recuperacion/trace.out';
        -- TRACE ON;
            LET cBegin = "N";
            LET cCodRet = '00000';
            LET mError = 'PROCESO EXITOSO';

        SELECT valor 
            INTO vcDirectorio
        FROM bdicred:"informix".sd_param 
        WHERE cod_param = '172' 
        AND empresa = '001';
            --
        IF vcDirectorio IS NULL THEN
            LET cCodRet='000001';
            LET mError = 'NO EXISTE INFORMACION DEL PATH EN TABLA';
        RETURN cCodRet, mError;
        END IF;
        
        SELECT valor 
            INTO vcNombreArchivo
        FROM bdicred:"informix".sd_param 
            WHERE cod_param = '173' 
            AND empresa = '001';
            --
        IF vcNombreArchivo IS NULL THEN
            LET cCodRet='000002';
            LET mError = 'NO EXISTE INFORMACION DEL NOMBRE DE ARCHIVO EN TABLA';
            RETURN cCodRet, mError;
        END IF;
        --
        SELECT fecha_hoy 
                INTO dtFecha_Hoy 
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = '001';

        begin work;

        FOREACH WITH HOLD
            SELECT dia_cuota, num_producto  
            INTO i_dia_cuota, cNum_Producto
            FROM bdicred:"informix".sd_definicion 
            WHERE num_producto IN ('6001')-- aquiÂ­ solo agregar los nuevos productos que deben generar candidatos o se meten a una tabla de parametros de control

            IF day(dtFecha_Hoy) <= day(i_dia_cuota) THEN
                let dt_fecha_corte_mas_reciente =  MDY( month(dtFecha_Hoy - 1 UNITS month) ,day(i_dia_cuota), year(dtFecha_Hoy - 1 UNITS month) );
            elif day(dtFecha_Hoy) > day(i_dia_cuota) then
                let dt_fecha_corte_mas_reciente =  MDY( month(dtFecha_Hoy ) ,day(i_dia_cuota), year(dtFecha_Hoy) );
            end if;
            --
            FOREACH WITH HOLD
            -- SELECCION DE TODOS LOS CANDIDATOS AL CORTE MENSUAL
        SELECT  hist.numcte,
                hist.num_credito,
                hist.nombre_com,
                hist.linea_credito,
                hist.pago_minimo,
                hist.fecha_corte,
                hist.fecha_pago,
                hist.fecha_originacion,
                hist.tasa_interes,
                hist.num_celular,
                hist.num_telefono_casa,
                hist.canal,
                hist.campania, 
                hist.calle,
                hist.num_casa,
                hist.colonia,
                hist.municipio,
                hist.estado,
                hist.cp,
                hist.email

                INTO cNum_Cte, cNum_Credito,
                    vcNombre_Com, dLinea_Credito, dPago_Minimo, dtFecha_Corte, dtFecha_Pago, dtFecha_Originacion, 
                        iTasa_Interes, cNum_Celular, cNum_Telefono_casa,
                        cCanal, cCampania, cCalle, cNum_Casa, cColonia, cMunicipio, cEstado, cCp, vcEmail
                FROM 
                    bdicred:"informix".sd_plan_pausa_candidatos_mensual hist 
                    left join bdicred:informix.sd_plan_pausa_layout lay
                    on hist.num_credito = lay.num_credito 
                    AND lay.fecha_corte = dt_fecha_corte_mas_reciente
                WHERE --fecha_corte = dtFecha_consulta_mensual
                hist.fecha_corte = dt_fecha_corte_mas_reciente
                and hist.num_producto = cNum_Producto
                and lay.num_credito is null
                ---- termina select principal
                
                SELECT sdo_cap_insoluto, (monto_vencido + mto_venc_trasp), monto_financiado 
                    INTO dSaldo_Maesdos, dSaldoVencido_Maesdos, dPago_minimo_pendiente
                FROM bdicred:"informix".sd_maesdos
                WHERE num_credito = cNum_Credito;
                LET dSaldo_Revolvente = dSaldo_Maesdos;
                --
                IF dSaldoVencido_Maesdos IS NULL THEN 
                        LET dSaldoVencido_Maesdos = 0;
                END IF;

                IF dSaldo_Maesdos IS NULL THEN 
                        LET dSaldo_Maesdos = 0;
                END IF;
                --
                IF dSaldo_Maesdos < 4000 OR 
                dSaldoVencido_Maesdos > 0 THEN
                    CONTINUE FOREACH;
                END IF;
                --
                SELECT plazo 
                INTO iPlazo_Sugerido
                FROM bdicred:"informix".sd_plan_pausa_plazo_sugerido
                WHERE num_producto = cNum_Producto
                AND rango_superior > dSaldo_Maesdos
                AND rango_inferior <= dSaldo_Maesdos;
                
                IF iPlazo_Sugerido IS NULL then
                    LET cCodRet = '00003';
                    LET mError  = 'NO EXISTE INFORMACION DEL PLAZO PARA EL PLAN EN PAUSA';
                END IF;

                -- REGLA DE EVALUACION PAGO MINIMO
                IF dPago_minimo_pendiente <= 0 THEN
                    LET vcAbono_TotalText = 'PAGO MINIMO REALIZADO';
                ELSE 
                    LET vcAbono_TotalText = 'NO CUMPLE';
                END IF;
                -- SALDO PARA PLAN
                IF  dPago_Minimo = 0 THEN
                    LET dSaldo_Para_Plan = dSaldo_Maesdos;
                ELSE 
                    LET dSaldo_Para_Plan = dSaldo_Maesdos - dPago_minimo_pendiente;
                END IF;
                --    
                SELECT  num_credito, estatus, fecha_liquidacion
                    INTO cNum_Credito_Bitac, iEstatusBitacora, dtFecha_Liquidacion
                FROM bdicred:"informix".sd_plan_pausa_bitacora
                WHERE num_credito = cNum_Credito
                    AND ROWID = (
                        SELECT MAX(ROWID)
                        FROM bdicred:"informix".sd_plan_pausa_bitacora
                        WHERE num_credito = cNum_Credito);
                        
                    --1 EN PROCESO DE VALIDACION PARA CONTRATAR 
                    --2 RECHAZADO EN PROCESO ANTERIOR 
                    --3 POR CONTRATAR(EN SP COMPRA PROMO) 
                    --5 ACTIVO  --6 RECHAZADO BAJO SOLICITUD  
                    --7 LIQUIDADO

                LET X = 0;
                IF cNum_Credito_Bitac IS NOT NULL THEN
                    IF iEstatusBitacora NOT IN ('1','3','5','7')
                        OR (dtFecha_Liquidacion is not null AND 
                            ( iEstatusBitacora = '7' AND (dtFecha_Hoy - NVL(dtFecha_Liquidacion,DATE(1)) )> 365)
                            )
                    THEN
                        LET X = 1;
                    END IF;
                ELSE  --IS NULL, NO HAY HISTORIA DE ALGUN PLAN EN PAUSA
                    LET X = 1;
                END IF;
                
                IF X = 1 THEN
                    -- Obtener montos diferidos para plazos 12, 18 y 24 -- se cambia a sp_proyecta_prest_credisolsam para pruebas
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo12::INTEGER, 0, '6900', cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes)
                        INTO cResCodRet12, iResPeriodo12, dtResFechaCouta12, dResSdoInicial12, dResMensualidad212, dResIntereses12, 
                        dResIvaIn12, dResCapital12, dResSdoFinal12, sResDiasPeriodo12, dtResFechaAper12, cResPlazo12;
                        LET dPlan_12_Aux = dResMensualidad212;
                    --
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo18::INTEGER, 0,'6900',cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes) 
                        INTO cResCodRet18, iResPeriodo18, dtResFechaCouta18, dResSdoInicial18, dResMensualidad218, dResIntereses18,
                            dResIvaIn2418, dResCapital18, dResSdoFinal18, sResDiasPeriodo18, dtResFechaAper18, cResPlazo18;
                            LET dPlan_18_Aux = dResMensualidad218;
                    --
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo24::INTEGER, 0, '6900', cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes) 
                        INTO cResCodRet24, iResPeriodo24, dtResFechaCouta24, dResSdoInicial24, dResMensualidad224, dResIntereses24,
                            dResIvaIn2424, dResCapital24, dResSdoFinal24, sResDiasPeriodo24, dtResFechaAper24, cResPlazo24;
                            LET dPlan_24_Aux = dResMensualidad224;
                    
                    INSERT INTO bdicred:"informix".sd_plan_pausa_layout (
                        fecha_asig, numcte, num_credito, num_producto, nombre_com,
                        linea_credito, pago_minimo, fecha_corte, fecha_pago, fecha_originacion, pm_realizado,
                        saldo_revolvente, saldo_para_plan, plazo_sugerido, tasa_interes, plan_12_meses, plan_18_meses, plan_24_meses, num_celular,
                        num_telefono_casa, canal, campania, calle, num_casa, colonia, municipio, estado, cp, email
                        )
                    VALUES (
                        dtFecha_Hoy, cNum_Cte, cNum_Credito, cNum_Producto, vcNombre_Com,
                        dLinea_Credito, dPago_Minimo, dtFecha_Corte, dtFecha_Pago, dtFecha_Originacion, vcAbono_TotalText,
                        dSaldo_Revolvente, dSaldo_Para_Plan, iPlazo_Sugerido, iTasa_Interes, dPlan_12_Aux, dPlan_18_Aux, dPlan_24_Aux, cNum_Celular,
                        cNum_Telefono_casa, cCanal, cCampania, cCalle, cNum_Casa, cColonia, cMunicipio, cEstado, cCp, vcEmail
                        );
                    LET iContador = iContador + 1;

                    IF iContador >= 1000 THEN
                        COMMIT WORK;
                        BEGIN WORK;
                        LET iContador = 0;
                    END IF;

                END IF;
                --
            END FOREACH;
            -- fin del foreach
            IF iContador > 0 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        END FOREACH;
        
            LET cFecha_Actual = LPAD(DAY(dtFecha_Hoy),2,0)||LPAD(MONTH(dtFecha_Hoy),2,0)||YEAR(dtFecha_Hoy);
            LET vcNombreArchivov = trim(vcNombreArchivo);
            LET vcNombreArchivoFinal = TRIM(vcDirectorio) || TRIM(vcNombreArchivo) || cFecha_Actual || '.txt';	
            --
            let csSql = 'echo "UNLOAD TO ' || vcNombreArchivoFinal || ' DELIMITER ' || '''|''' ||
            ' SELECT row_number() over(order by numcte), fecha_asig, numcte ,num_credito ,num_producto , trim(nombre_com) ,linea_credito, pago_minimo ,fecha_corte ,fecha_pago ,fecha_originacion ,pm_realizado ,saldo_revolvente , saldo_para_plan, plazo_sugerido ,tasa_interes ,plan_12_meses ,plan_18_meses ,plan_24_meses ,num_celular ,num_telefono_casa ,canal ,campania ,calle ,num_casa ,colonia ,municipio ,estado ,cp ,email FROM bdicred:informix.sd_plan_pausa_layout; TRUNCATE TABLE bdicred:informix.sd_plan_pausa_layout;" | dbaccess bdicred';
            --
            LET csSQLAux = csSql;
            SYSTEM csSQL;
            --
            IF (cBegin = "S") THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            --RETURN PRINCIPAL    
        RETURN cCodRet, mError;
        
    END;
--
END PROCEDURE
;