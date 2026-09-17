CREATE PROCEDURE "informix".sp_validamontoremesabts(p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8), p_cMontoAPagar CHAR(20))
    RETURNING
    CHAR(5);

    --Definicion de Variables
    DEFINE cCodRet      			CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE cMontoMaximo 			CHAR(10);
	DEFINE mImporte_pago			MONEY(14,2);
	DEFINE mSuma					MONEY(14,2);
	DEFINE mSumaHist                MONEY(14,2);
	DEFINE mTotal					MONEY(14,2);
	DEFINE mMontoMaxMensual			CHAR(10);
	DEFINE iNumOperaciones          INTEGER;
	DEFINE dPri_dia_mes		 		DATE;
	DEFINE cPrim_dia_mes			CHAR(10);
	DEFINE iNumOperHist				INTEGER;
	DEFINE iNumOper					INTEGER;
	DEFINE acumulado				INTEGER;
	DEFINE numOper					INTEGER;
	DEFINE mSumaMensual				MONEY(16,2);
	DEFINE mTotalMesnual			MONEY(16,2);
	
	
	-- Inicializa variables
    LET cCodRet 				= "00000";
	LET iSqlErr 				= 0;
	LET cMontoMaximo			= "";
	LET mImporte_pago			= 0; 
	LET mSuma					= 0;
	LET mSumaHist				= 0;
	LET mTotal					= 0;
	LET mMontoMaxMensual		= 0;
    LET iNumOperaciones         = 0;
	LET dPri_dia_mes			= DATE(1);
	LET cPrim_dia_mes			= '';
	LET	iNumOperHist			= 0;
	LET iNumOper				= 0;
	LET acumulado				= 0;
	LET numOper					= 0;
	LET mSumaMensual			= 0;
	LET mTotalMesnual			= 0;
	
	--SET DEBUG FILE TO '/informix/EPG/sp_validamontoremesabts.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
	
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cMontoAPagar,"") <> "" THEN
				
		SELECT Valor 
		INTO cMontoMaximo
		FROM "informix".sac_param
		WHERE empresa = p_cEmpresa
		AND cod_param = 87010;  ---valor para el monto diario
		
	    --FOLIO: EPG - 01/06/2016
		SELECT valor 
		INTO mMontoMaxMensual
		FROM "informix".sac_param 
		WHERE empresa = p_cEmpresa
		AND cod_param = 87021; --- valor para el monto mensual
		
		SELECT valor 
		INTO iNumOperaciones
		FROM "informix".sac_param 
		WHERE empresa = p_cEmpresa
		AND cod_param = 87022; --- valor para el numer operaciones mensuales
		
		SELECT pri_dia_mes
		INTO dPri_dia_mes
		FROM bdisac:"informix".sac_fechas;
		
		LET cPrim_dia_mes = SUBSTRING (dPri_dia_mes FROM 7 FOR 4)||SUBSTRING (dPri_dia_mes FROM 1 FOR 2)||SUBSTRING (dPri_dia_mes FROM 4 FOR 2);
		
		IF NVL(cMontoMaximo,"") <> "" THEN
		
		SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
		  INTO mSumaHist, iNumOperHist
		  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_bts_payi b
		 WHERE a.referencia1 = b.confirmation_nm
		   AND a.folio_suc = b.bank_ref_nm
		   AND a.status_cancelado <> 'S'
		   AND b.r_first_name = p_cNombre1
		   AND b.r_middle_name = NVL(p_cNombre2,"")
		   AND b.r_last_name = p_cApellidoPaterno
		   AND b.r_mother_m_name = NVL(p_cApellidoMaterno,"")
		   AND b.r_fecha_nac = p_cFechaNacimiento
		   AND SUBSTRING(b.agent_dt FROM 1 FOR 8) BETWEEN cPrim_dia_mes AND p_cFechaHoy
		   AND b.opcode = 1100;
	    
		SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
		  INTO mSuma, iNumOper
		  FROM bdisac:"informix".sac_movimientos a, bdisac:"informix".sac_bts_payi b
		 WHERE a.referencia1 = b.confirmation_nm
		   AND a.folio_suc = b.bank_ref_nm
		   AND a.status_cancelado <> 'S'
		   AND b.r_first_name = p_cNombre1
		   AND b.r_middle_name = NVL(p_cNombre2,"")
		   AND b.r_last_name = p_cApellidoPaterno
		   AND b.r_mother_m_name = NVL(p_cApellidoMaterno,"")
		   AND b.r_fecha_nac = p_cFechaNacimiento
		   AND b.agent_dt = p_cFechaHoy
		   AND b.opcode = 1100;

   	    LET numOper = iNumOper + iNumOperHist;	
		LET mTotal = mSuma + CAST(p_cMontoAPagar AS MONEY(14,2));
		LET mTotalMesnual = mSuma + CAST(p_cMontoAPagar AS MONEY(14,2)) + mSumaHist;
			
			IF mTotal > CAST(cMontoMaximo AS MONEY(14,2)) OR mTotalMesnual > CAST(mMontoMaxMensual AS MONEY(14,2)) OR numOper >= iNumOperaciones THEN				
				LET cCodRet = "00001";				
			END IF;
		ELSE
			LET cCodRet = "00002";
		END IF;	
	ELSE
		LET cCodRet = "00003";
	END IF;
		
	RETURN cCodRet;	
    END;
END PROCEDURE
 DOCUMENT
 'AUTOR: Urias Rocha Felipe de Jesus',
 'DESCRIPCION: valida si a un Cliente se le permite Cobrar una envio BTS dependiendo de un monto maximo por dia.',
 'FECHA: 20120417',
 'BD:   bdisac',
 'MODIFICACION',
 'AUTOR: Jose Angel Lopez Adams',
 'DESCRIPCION: Se modifica SP para que la sumatoria de montos pagados se haga sin necesidad de un FOREACH, utilizando un JOIN entre las tablas sac_movimientos y sac_bts_payi',
 'SOLICITA: Jaime Gonzalez Prado',
 'FECHA: 20140509';

CREATE PROCEDURE "informix".sp_remesasbtsaut_pld(FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(80);	
	DEFINE cDescripcionSPJ	 		CHAR(100);
	DEFINE cStatus					CHAR(1);
	DEFINE dFechaProceso			DATE;
	DEFINE cNum_confirmacion		CHAR(20);	
	DEFINE mMonto_dolares      	 	MONEY;
	DEFINE cTransaccion         	CHAR(4);
	DEFINE cBeneficiario_nombre1    CHAR(30);
	DEFINE cBeneficiario_nombre2    CHAR(30);	
	DEFINE cBeneficiario_appaterno  CHAR(30);
	DEFINE cBeneficiario_apmaterno 	CHAR(30);
	DEFINE dBeneficiario_fecha_nac  DATE;
	DEFINE cBeneficiario_estado     CHAR(50);
	DEFINE cBeneficiario_ciudad		CHAR(50);
	DEFINE cBeneficiario_direccion	CHAR(100);
	DEFINE cBeneficiario_cp			CHAR(9);
	DEFINE cOrdenante_nombre1		CHAR(40);
	DEFINE cOrdenante_nombre2		CHAR(40);
	DEFINE cOrdenante_appaterno		CHAR(40);
	DEFINE cOrdenante_apmaterno		CHAR(40);
	DEFINE cOrdenante_direccion		CHAR(100);
	DEFINE cFecha_peticion 			CHAR(10);
	DEFINE cHora_peticion			CHAR(6);
	DEFINE cHora_transaccion		CHAR(6);
	DEFINE cCnxn_status				CHAR(1);	
	DEFINE cTipo_pago_servicio		CHAR(3);
	DEFINE cCod_pais_origen			CHAR(3);
	DEFINE cCod_moneda_origen		CHAR(3);
	DEFINE cCod_pais_destino        CHAR(3);
	DEFINE cCod_moneda_destino      CHAR(3);
	DEFINE cTipo_cambio             CHAR(21);
	DEFINE cNumero_de_cliente_benef	CHAR(20);
	DEFINE cCuenta_benef            CHAR(30);
	DEFINE cTipo_cta_benef          CHAR(3);
	DEFINE cCod_agnt_benef          CHAR(3);
	DEFINE cCod_edo_benef           CHAR(3);
	DEFINE cCod_pais_benef          CHAR(3);
	DEFINE cTel_benef               CHAR(15);
	DEFINE cCod_agente_org          CHAR(3);
	DEFINE cCd_remitente            CHAR(40);
	DEFINE cCod_edo_remitente       CHAR(3);
	DEFINE cCod_pais_remitente      CHAR(3);
	DEFINE cCp_remitente            CHAR(10);
	DEFINE cTel_remitente           CHAR(15);
	
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cDescripcionSPJ	 			= 'Agrega info faltante a remesas BTS automaticas en PLD';
	LET cStatus						= '0';
	LET dFechaProceso	    		= mdy(01,01,1900);
	LET cNum_confirmacion			= '';	
	LET mMonto_dolares           	= 0;
	LET cTransaccion            	= '';
	LET cBeneficiario_nombre1      	= '';
	LET cBeneficiario_nombre2       = '';
	LET cBeneficiario_appaterno     = '';
	LET cBeneficiario_apmaterno 	= '';
	LET dBeneficiario_fecha_nac   	= mdy(01,01,1900);
	LET cBeneficiario_estado      	= '';
	LET cBeneficiario_ciudad		= '';
	LET cBeneficiario_direccion		= '';
	LET cBeneficiario_cp			= '';
	LET cOrdenante_nombre1			= '';
	LET cOrdenante_nombre2			= '';
	LET cOrdenante_appaterno		= '';
	LET cOrdenante_apmaterno		= '';
	LET cOrdenante_direccion		= '';
	LET cFecha_peticion 			= '01/01/1900';
	LET cHora_peticion				= '';
	LET cHora_transaccion			= '';
	LET cCnxn_status				= '';	
	LET cTipo_pago_servicio			= '';
	LET cCod_pais_origen			= '';
	LET cCod_moneda_origen			= '';
	LET cCod_pais_destino       	= '';
	LET cCod_moneda_destino     	= '';
	LET cTipo_cambio            	= '0';
	LET cNumero_de_cliente_benef	= '';
	LET cCuenta_benef           	= '';
	LET cTipo_cta_benef         	= '';
	LET cCod_agnt_benef         	= '';
	LET cCod_edo_benef          	= '';
	LET cCod_pais_benef         	= '';
	LET cTel_benef              	= '';
	LET cCod_agente_org         	= '';
	LET cCd_remitente           	= '';
	LET cCod_edo_remitente      	= '';
	LET cCod_pais_remitente     	= '';
	LET cCp_remitente           	= '';
	LET cTel_remitente          	= '';
	
	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesasbtsaut_pld" || "Remesa:" || cNum_confirmacion);
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE				
			IF FechaIni = FechaFin THEN		
				--VALIDA 25 DIC y 1RO ENE
				IF (DAY(FechaFin) = '25' AND MONTH(FechaFin) = '12') OR (DAY(FechaFin) = '01' AND MONTH(FechaFin) = '01') THEN
					LET FechaIni = FechaIni - 1 UNITS DAY;
					LET FechaFin = FechaFin - 1 UNITS DAY;
				END IF;			
				--INSERTA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_BTSAUT', FechaFin, '0', 'informix', 'sp_remesasbtsaut_pld', cDescripcionSPJ);						
			END IF;		
		END IF;		

		FOREACH
			select fecha_proceso, num_confirmacion
			into dFechaProceso, cNum_confirmacion
			from bdisac:"informix".sac_pld_remesas 
			where fecha_proceso >= FechaIni
			and fecha_proceso <= FechaFin
			and tipo_remesa = 'BTS'
			and abono_cuenta = 'SI'
			and beneficiario_nombre1 = ''
			and beneficiario_nombre2 = ''
			and beneficiario_appaterno = ''
			and beneficiario_apmaterno = ''
			
			select NVL(monto_origen,0) monto_dolares, '8754' transaccion, NVL(nombre1_benef,'') beneficiario_nombre1, NVL(nombre2_benef,'') beneficiario_nombre2,
			NVL(ap_paterno_benef,'') beneficiario_appaterno, NVL(ap_materno_benef,'') beneficiario_apmaterno, mdy(01,01,1900) beneficiario_fecha_nac, 
			NVL(cod_edo_benef,'') beneficiario_estado, NVL(ciudad_benef,'') beneficiario_ciudad, NVL(dir_benef,'') beneficiario_direccion,
			NVL(cp_benef,'') beneficiario_cp, NVL(nombre1_remitente,'') ordenante_nombre1, NVL(nombre2_remitente,'') ordenante_nombre2, 
			NVL(ap_paterno_remitente,'') ordenante_appaterno, NVL(ap_materno_remitente,'') ordenante_apmaterno, NVL(dir_remitente,'') ordenante_direccion,
			NVL(fecha_peticion,'01/01/1900'), NVL(hora_peticion,''), NVL(hora_transaccion,''), NVL(cnxn_status,''), NVL(tipo_pago_servicio,''),
			NVL(cod_pais_origen,''), NVL(cod_moneda_origen,''), NVL(cod_pais_destino,''), NVL(cod_moneda_destino,''), NVL(tipo_cambio,'0'),
			NVL(cuenta_benef,''), NVL(tipo_cta_benef,''), NVL(cod_agnt_benef,''), NVL(cod_edo_benef,''), NVL(cod_pais_benef,''), NVL(tel_benef,''),
			NVL(cod_agente_org,''), NVL(cd_remitente,''), NVL(cod_edo_remitente,''), NVL(cod_pais_remitente,''), NVL(cp_remitente,''), NVL(tel_remitente,'')					
			INTO mMonto_dolares, cTransaccion, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac,
			cBeneficiario_estado, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno,
			cOrdenante_apmaterno, cOrdenante_direccion, cFecha_peticion, cHora_peticion, cHora_transaccion, cCnxn_status, cTipo_pago_servicio,
			cCod_pais_origen, cCod_moneda_origen, cCod_pais_destino, cCod_moneda_destino, cTipo_cambio, cCuenta_benef, cTipo_cta_benef, cCod_agnt_benef,
			cCod_edo_benef, cCod_pais_benef, cTel_benef, cCod_agente_org, cCd_remitente, cCod_edo_remitente, cCod_pais_remitente, cCp_remitente, cTel_remitente
			FROM bdisac:"informix".sac_bts_sdep
			where num_confirmacion = cNum_confirmacion
			and fecha_insert >= FechaIni 
			and estatus_sdep = '05';
			
			IF length(cCuenta_benef)<16 THEN
				select NVL(num_cte,'')
				into cNumero_de_cliente_benef
				from bdicheq:"informix".sc_maechq
				where cuenta = cCuenta_benef;
		    ELSE
				select NVL(numcte,'')
				into cNumero_de_cliente_benef
				from bdicheq:"informix".sc_tarjeta
				where num_tarjeta = cCuenta_benef
				and empresa = '001';
			END IF;			
			
			IF EXISTS (SELECT 1 FROM bdisac:"informix".sac_pld_remesas where num_confirmacion= cNum_confirmacion and fecha_proceso = dFechaProceso
				and tipo_remesa ='BTS' and abono_cuenta = 'SI') THEN
				UPDATE bdisac:"informix".sac_pld_remesas SET monto_dolares = mMonto_dolares, transaccion = cTransaccion, beneficiario_nombre1 = cBeneficiario_nombre1, beneficiario_nombre2 = cBeneficiario_nombre2,
				beneficiario_appaterno = cBeneficiario_appaterno, beneficiario_apmaterno = cBeneficiario_apmaterno, beneficiario_fecha_nac = dBeneficiario_fecha_nac, beneficiario_estado = cBeneficiario_estado,
				beneficiario_ciudad = cBeneficiario_ciudad, beneficiario_direccion = cBeneficiario_direccion, 
				beneficiario_cp = cBeneficiario_cp, ordenante_nombre1 = cOrdenante_nombre1, ordenante_nombre2 = cOrdenante_nombre2, ordenante_appaterno = cOrdenante_appaterno, 
				ordenante_apmaterno = cOrdenante_apmaterno, ordenante_direccion = cOrdenante_direccion,	fecha_peticion = cFecha_peticion, hora_peticion = cHora_peticion,
				hora_transaccion = cHora_transaccion,
				cnxn_status = cCnxn_status, tipo_pago_servicio = cTipo_pago_servicio, cod_pais_origen = cCod_pais_origen,
				cod_moneda_origen = cCod_moneda_origen, cod_pais_destino = cCod_pais_destino, cod_moneda_destino = cCod_moneda_destino, tipo_cambio = cTipo_cambio,
				numero_de_cliente_benef = NVL(cNumero_de_cliente_benef,''),
				tipo_cta_benef = cTipo_cta_benef, cuenta_benef = cCuenta_benef, cod_agnt_benef = cCod_agnt_benef, cod_edo_benef = cCod_edo_benef, cod_pais_benef = cCod_pais_benef, 
				cp_benef = cBeneficiario_cp, tel_benef = cTel_benef,cod_agente_org = cCod_agente_org, cd_remitente = cCd_remitente, cod_edo_remitente = cCod_edo_remitente, 
				cod_pais_remitente = cCod_pais_remitente, cp_remitente = cCp_remitente, tel_remitente = cTel_remitente
				WHERE num_confirmacion= cNum_confirmacion and fecha_proceso = dFechaProceso
				and tipo_remesa ='BTS' and abono_cuenta = 'SI';
			END IF;			
		END FOREACH;		
							
		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_BTSAUT', FechaFin, '1', 'informix', 'sp_remesasbtsaut_pld', cDescripcionSPJ);
		RETURN cCodRet, cMensaje;
	
	END;
END PROCEDURE;