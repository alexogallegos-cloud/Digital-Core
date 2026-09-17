CREATE PROCEDURE "informix".sp_remesasbts_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);	
	DEFINE cStatus				CHAR(1);
	DEFINE dFecha_remesa               DATE;
    DEFINE cTipo_remesa              	CHAR(3);
    DEFINE cAbono_cuenta               CHAR(2);
    DEFINE cNum_confirmacion           CHAR(20);
    DEFINE mMonto_total                MONEY;
    DEFINE mMonto_dolares           	MONEY;
    DEFINE cTransaccion            	CHAR(4);
    DEFINE cFolio_sucursal             CHAR(16);
    DEFINE dFecha_alta           		DATE;
    DEFINE cBeneficiario_nombre1      	CHAR(30);
    DEFINE cBeneficiario_nombre2       CHAR(30);
    DEFINE cBeneficiario_appaterno     CHAR(30);
    DEFINE cBeneficiario_apmaterno 	CHAR(30);
    DEFINE dBeneficiario_fecha_nac     DATE;
    DEFINE cBeneficiario_estado      	CHAR(50);
    DEFINE cBeneficiario_mncpo_del    	CHAR(50);
    DEFINE cBeneficiario_ciudad		CHAR(50);
    DEFINE cBeneficiario_direccion		CHAR(100);
	DEFINE cBeneficiario_colonia		CHAR(80);
	DEFINE cBeneficiario_calle			CHAR(50);
	DEFINE cBeneficiario_num_ext		CHAR(5);
	DEFINE cBeneficiario_num_int		CHAR(5);
	DEFINE cBeneficiario_depto			CHAR(10);
	DEFINE cBeneficiario_cp			CHAR(9);
	DEFINE cOrdenante_nombre1			CHAR(40);
	DEFINE cOrdenante_nombre2			CHAR(40);
	DEFINE cOrdenante_appaterno		CHAR(40);
	DEFINE cOrdenante_apmaterno		CHAR(40);
	DEFINE cOrdenante_direccion		CHAR(100);
	DEFINE cSucursal					CHAR(4);
	DEFINE cUsuario					CHAR(8);
	DEFINE dFecha_Proceso			DATE;
	DEFINE dFecha_Alt				DATE;
	DEFINE cReferencia1				CHAR(40);
	DEFINE iSecuencia				INTEGER;
	DEFINE cAgent_dt				CHAR(8);
	DEFINE cProcess_dt				CHAR(8);
	DEFINE cTerminal				CHAR(15);
	DEFINE iCuantosCheq				INTEGER;
	DEFINE iCuantosMovtos			INTEGER;
	DEFINE iCuantosSdep				INTEGER;
	DEFINE iCuantosQryi				INTEGER;	
	DEFINE iCuantosPayi				INTEGER;	
	DEFINE cFechaFor          		CHAR(8);
	
	DEFINE cFecha_peticion 			CHAR(10);
	DEFINE cHora_peticion			CHAR(6);
	DEFINE cHora_transaccion		CHAR(6);	
	DEFINE cCnxn_status				CHAR(1);	
	DEFINE cCod_pais_origen			CHAR(3);
	DEFINE cCod_moneda_origen		CHAR(3);
	DEFINE cCod_pais_destino        CHAR(3);
	DEFINE cCod_moneda_destino      CHAR(3);
	DEFINE cTipo_cambio             CHAR(21);	
	DEFINE cCuenta_benef            CHAR(30);	
	DEFINE cTp_id_benef             CHAR(3);
	DEFINE cNum_id_benef            CHAR(20);	
	DEFINE cCod_pais_benef          CHAR(3);
	DEFINE cCp_benef                CHAR(10);
	DEFINE cTel_benef               CHAR(15);				
	DEFINE cCd_remitente            CHAR(40);	
	DEFINE cCod_edo_remitente       CHAR(3);
	DEFINE cCod_pais_remitente      CHAR(3);
	DEFINE cCp_remitente            CHAR(10);
	DEFINE cTel_remitente           CHAR(15);	
	DEFINE cNumero_de_cliente_benef	CHAR(20);
	DEFINE dHora_proceso 			DATETIME HOUR to FRACTION(3);	
	DEFINE cDescripcionSPJ	 		CHAR(100);
	DEFINE cCodRetSP				CHAR(5);
	
	DEFINE cHora_remesa				CHAR(8);
	DEFINE cColonia_ordenante		CHAR(100);
	DEFINE cTipo_id_ordenante		CHAR(20);
	DEFINE cNumero_id_ordenante		CHAR(30);
	DEFINE cCiudad_id_ordenante		CHAR(40);
	DEFINE cName_benef_suc			CHAR(120);
	DEFINE cNum_id_benef_suc		CHAR(30);
			
	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';	
	LET cStatus						= '0';	
	LET dFecha_remesa               = mdy(01,01,1900);	
	LET cTipo_remesa              	= '';
    LET cAbono_cuenta               = '';
    LET cNum_confirmacion         	= '';
    LET mMonto_total                = 0;
    LET mMonto_dolares           	= 0;
    LET cTransaccion            	= '';
    LET cFolio_sucursal             = '';
    LET dFecha_alta           		= mdy(01,01,1900);
    LET cBeneficiario_nombre1      	= '';
    LET cBeneficiario_nombre2       = '';
    LET cBeneficiario_appaterno     = '';
    LET cBeneficiario_apmaterno 	= '';
    LET dBeneficiario_fecha_nac   	= mdy(01,01,1900);
    LET cBeneficiario_estado      	= '';
    LET cBeneficiario_mncpo_del    	= '';
    LET cBeneficiario_ciudad		= '';
    LET cBeneficiario_direccion		= '';
	LET cBeneficiario_colonia		= '';
	LET cBeneficiario_calle			= '';
	LET cBeneficiario_num_ext		= '';
	LET cBeneficiario_num_int		= '';
	LET cBeneficiario_depto			= '';
	LET cBeneficiario_cp			= '';
	LET cOrdenante_nombre1			= '';
	LET cOrdenante_nombre2			= '';
	LET cOrdenante_appaterno		= '';
	LET cOrdenante_apmaterno		= '';
	LET cOrdenante_direccion		= '';
	LET cSucursal					= '';
	LET cUsuario					= '';
	LET dFecha_Proceso				= FechaFin;
	LET dFecha_Alt					= mdy(01,01,1900);
	LET cReferencia1				= '';
	LET iSecuencia					= 0;
	LET cAgent_dt					= '';
	LET cProcess_dt					= '';
	LET cTerminal					= '';
	LET iCuantosCheq				= 0;
	LET iCuantosMovtos				= 0;
	LET iCuantosSdep				= 0;
	LET iCuantosQryi				= 0;
	LET iCuantosPayi				= 0;	
	LET cFechaFor          			= '';
	
	LET cFecha_peticion 			= '01/01/1900';
	LET cHora_peticion				= '';
	LET cHora_transaccion			= '';	
	LET cCnxn_status				= '';	
	LET cCod_pais_origen			= '';
	LET cCod_moneda_origen			= '';
	LET cCod_pais_destino       	= '';
	LET cCod_moneda_destino     	= '';
	LET cTipo_cambio            	= '0';	
	LET cCuenta_benef           	= '';	
	LET cTp_id_benef            	= '';
	LET cNum_id_benef           	= '';	
	LET cCod_pais_benef         	= '';
	LET cCp_benef               	= '';
	LET cTel_benef              	= '';					
	LET cCd_remitente           	= '';	
	LET cCod_edo_remitente      	= '';
	LET cCod_pais_remitente     	= '';
	LET cCp_remitente           	= '';
	LET cTel_remitente          	= '';	
	LET cNumero_de_cliente_benef	= '';
	LET dHora_proceso 				= '';	
	LET cDescripcionSPJ	 			= 'Inserta datos de Remesas BTS para sistema de PLD';
	LET cCodRetSP = "00000";
	
	LET cHora_remesa				= '';
	LET cColonia_ordenante			= '';
	LET cTipo_id_ordenante			= '';
	LET cNumero_id_ordenante		= '';
	LET cCiudad_id_ordenante		= '';
	LET cName_benef_suc				= '';
	LET cNum_id_benef_suc			= '';
	
	--SET DEBUG FILE TO  '/tmp/adrian/sp_remesasbts_pld.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesasbts_pld" || "Remesa:" || cNum_confirmacion);
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE			
			EXECUTE PROCEDURE sp_inicializatablaspld('BBTS','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE BTS";
				RETURN cCodRet, cMensaje;			
			END IF;			
		
			IF FechaIni = FechaFin THEN
		
				IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_PLD_BTS' and fecha_proceso = FechaFin) THEN									
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_BTS', FechaFin, '0', 'informix', 'sp_remesasbts_pld', cDescripcionSPJ);
				ELSE
					SELECT status 
					INTO cStatus
					FROM bdisac:"informix".sac_procesos_jobs 
					WHERE proceso = 'IND_PLD_BTS' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN
						--DELETE {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} FROM bdisac:"informix".sac_pld_remesas where tipo_remesa='BTS' and fecha_proceso = FechaFin;
						EXECUTE PROCEDURE sp_inicializatablaspld('','BTS',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE BTS EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;
			
			IF cStatus = '0' THEN
				set isolation to dirty read;
				FOREACH
					--ABONO DIRECTO EN CUENTA
					select NVL(folio_suc,''), NVL(fech_alt,mdy(01,01,1900)), NVL(sucursal,''), NVL(usuario,''), NVL(monto_tot,0), NVL(substr(fech_hor,1,8),'')
					into cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa
					  from bdicheq:"informix".sc_movhis
					 where fech_alt >= FechaIni
					   and fech_alt <= FechaFin
					   and cancelad <> 'S'
					   and usuario = 'sys_bts'
					   and transacc = '1140'
					   
					INSERT INTO bdisac:"informix".sac_cargo_bts (folio_suc, fech_alt, sucursal, usua, monto_tot, hora_remesa)
					VALUES (cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa);						   

				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosCheq
				FROM bdisac:"informix".sac_cargo_bts;
				
				set isolation to dirty read;
				FOREACH
					select {+INDEX(bdisac:"informix".sac_cargo_bts idxsac_cargo_btsff)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(hora_remesa,'')
					into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa
					  from bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_cargo_bts b
					 where fecha_pago >= FechaIni
					   and fecha_pago <= FechaFin
					   and numcategoria = '07'
					   and numconvenio = '004'
					   and status_cancelado <> 'S'
					   and a.folio_suc = b.folio_suc
					   and b.fech_alt = a.fecha_pago
					   and a.id_sucursal = b.sucursal
					   and a.usuario = b.usua
					   and a.importe_pago = b.monto_tot 
					
					INSERT INTO bdisac:"informix".sac_movtos_bts (referencia1,folio_suc,fecha_pago,usuario,id_sucursal,hora_remesa)
					VALUES (cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa);
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosMovtos
				FROM bdisac:"informix".sac_movtos_bts;
				
				FOREACH

					select {+INDEX(bdisac:"informix".sac_movtos_bts idxsac_movtos_btsr1)} NVL(fecha_pago,mdy(01,01,1900)) fecha_remesa,'BTS' tipo_remesa,'SI' abono_cuenta,NVL(num_confirmacion,''),NVL(monto_destino,0) monto_total,NVL(monto_origen,0) monto_dolares,'8754' transaccion,
						   NVL(folio_suc,'') folio,(today) fecha_alta,NVL(nombre1_benef,'') beneficiario_nombre1,NVL(nombre2_benef,'') beneficiario_nombre2,NVL(ap_paterno_benef,'') beneficiario_appaterno,
						   NVL(ap_materno_benef,'') beneficiario_apmaterno,mdy(01,01,1900) beneficiario_fecha_nac,NVL(cod_edo_benef,'') beneficiario_estado,'' beneficiario_mncpo_del,
						   NVL(ciudad_benef,'') beneficiario_ciudad,NVL(dir_benef,'') beneficiario_direccion, '' beneficiario_colonia, '' beneficiario_calle,'' beneficiario_num_ext,
						   '' beneficiario_num_int,'' beneficiario_depto,NVL(cp_benef,'') beneficiario_cp,NVL(nombre1_remitente,'') ordenante_nombre1,NVL(nombre2_remitente,'') ordenante_nombre2,
						   NVL(ap_paterno_remitente,'') ordenante_appaterno,NVL(ap_materno_remitente,'') ordenante_apmaterno,NVL(dir_remitente,'') ordenante_direccion,NVL(id_sucursal,'') sucursal,NVL(usuario,''),
						   NVL(fecha_peticion,'01/01/1900'), NVL(hora_peticion,''), NVL(hora_transaccion,''), NVL(cnxn_status,''), NVL(cod_pais_origen,''), NVL(cod_moneda_origen,''), NVL(cod_pais_destino,''),
						   NVL(cod_moneda_destino,''), NVL(tipo_cambio,'0'), NVL(cuenta_benef,''), NVL(tp_id_benef,''), NVL(num_id_benef,''),
						   NVL(cod_pais_benef,''), NVL(cp_benef,''), NVL(tel_benef,''), 
						   NVL(cd_remitente,''), NVL(cod_edo_remitente,''), NVL(cod_pais_remitente,''), NVL(cp_remitente,''), NVL(tel_remitente,''), NVL(hora_remesa,''),NVL(dir_remitente,''),
						   NVL(cod_tp_id_rmtnte,''), NVL(num_id_rmtnte,''), NVL(cd_remitente,''),
						   NVL(nombre1_benef,'') || " " || NVL(nombre2_benef,'') || " " || NVL(ap_paterno_benef,'') || " " || NVL(ap_materno_benef,''),
						   NVL(num_id_benef,'')
					INTO dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta, 
						cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado, 
						cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, 
						cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, 
						cOrdenante_direccion, cSucursal, cUsuario,
						cFecha_peticion,cHora_peticion,cHora_transaccion,cCnxn_status,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,
						cTipo_cambio,cCuenta_benef,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef,
						cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,
						cTel_remitente, cHora_remesa, cColonia_ordenante, cTipo_id_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante, cName_benef_suc, cNum_id_benef_suc
					 from bdisac:"informix".sac_bts_sdep,bdisac:"informix".sac_movtos_bts					
					  where num_confirmacion = referencia1
					  and fecha_insert::date >= FechaIni - 1 UNITS DAY
					  and fecha_insert::date <= FechaFin
					  and fecha_pago::date >= fecha_insert::date
					  and estatus_sdep = '05'
					  
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
					  
					  LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
					  
					INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
					VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta, 
						cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado, 
						cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int,
						cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,
						cUsuario, dFecha_Proceso,
						cFecha_peticion,cHora_peticion,cHora_transaccion,cCnxn_status,'',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,
						cTipo_cambio,NVL(cNumero_de_cliente_benef,''),'',cCuenta_benef,'',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','',
						cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,
						cTel_remitente,'',dHora_proceso,cHora_remesa,cColonia_ordenante,cTipo_id_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,'',cName_benef_suc,cNum_id_benef_suc,'01011900');
					  
				END FOREACH;	

				SELECT {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} count(*)
				INTO iCuantosSdep
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFecha_Proceso
				AND tipo_remesa ='BTS'
				AND abono_cuenta = 'SI';				
				
				--OBTENER REMESAS QUE NO ESTEN EN ALGUNA DE LAS TABLAS
				IF iCuantosCheq <> iCuantosMovtos THEN
				
					FOREACH
								
						select {+INDEX(bdisac:"informix".sac_cargo_bts idxsac_cargo_btsff)} 
						NVL(folio_suc,''), NVL(fech_alt,mdy(01,01,1900)), NVL(sucursal,''), NVL(usua,''), NVL(monto_tot,0), NVL(hora_remesa,'')
						into cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa
						from bdisac:"informix".sac_cargo_bts 
						where folio_suc not in (select {+INDEX(bdisac:"informix".sac_movtos_bts idxsac_movtos_btsr1)} folio_suc from bdisac:"informix".sac_movtos_bts)
						
						LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
					
						INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
						VALUES(dFecha_Alt, 'BTS', 'SI', '', mMonto_total, 0, '', cFolio_sucursal, (today), '', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cSucursal, cUsuario, dFecha_Proceso,
							mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');
									
					END FOREACH;
					
					ELSE IF iCuantosMovtos <> iCuantosSdep THEN
					
						FOREACH							
							select {+INDEX(bdisac:"informix".sac_movtos_bts idxsac_movtos_btsr1)}
							NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(hora_remesa,'')
							into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa
							from bdisac:"informix".sac_movtos_bts 
							where folio_suc not in (select {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} folio_sucursal from bdisac:"informix".sac_pld_remesas WHERE fecha_proceso = dFecha_Proceso
							AND tipo_remesa ='BTS'
							AND abono_cuenta = 'SI')
							
							select {+INDEX(bdisac:"informix".sac_cargo_bts idxsac_cargo_btsff)}  NVL(monto_tot,0)
							into mMonto_total
							from bdisac:"informix".sac_cargo_bts 
							where folio_suc = cFolio_Sucursal
							and fech_alt = dFecha_Alt
							and sucursal = cSucursal
							and usua = cUsuario;
							
							LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
							
							INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
							beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
							beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
							beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
							fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
							numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
							tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
							cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
							hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
							num_id_benef_suc,fecha_envio_remesa)
							VALUES(dFecha_Alt, 'BTS', 'SI', cReferencia1, mMonto_total, 0, '', cFolio_sucursal, (today), 
								'', '', '', '', '', '', '', '', '', '', '', '', '',	'', '', '', '', '', '', '', cSucursal,cUsuario, dFecha_Proceso,
								mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');
						END FOREACH;
					
					END IF;				
				END IF;
				
				--PAGO DE REMESAS EN VENTANILLA 

				--OBTIENE DATOS DE CHEQUES
				set isolation to dirty read;
				FOREACH
					select NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''), NVL(sucursal,''), NVL(usuario,''), NVL(monto_tot,0),NVL(substr(fech_hor,1,8),'')
					into cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa
					  from bdicheq:sc_movhis
					 where empresa = '001'
					   and fech_alt >= FechaIni
					   and fech_alt <= FechaFin
					   and transacc in ('1110','1170', '1521')
					   and cancelad <> 'S'
					   and usuario <> 'sys_bts'
					
					INSERT INTO bdisac:"informix".sac_vntnilla_cargo_bts (folio_suc,fech_alt,transacc_suc, sucursal, usua, monto_tot, hora_remesa)
					VALUES (cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa);	
					
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosCheq
				FROM bdisac:"informix".sac_vntnilla_cargo_bts;

				FOREACH
					--OBTIENE DATOS DE SERVICIOS
					select {+INDEX(bdisac:"informix".sac_vntnilla_cargo_bts idxsac_vntnilla_cargo_btsffs)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(b.transacc_suc,''), NVL(hora_remesa,'')
					into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
					  from bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_vntnilla_cargo_bts b
					 where fecha_pago >= FechaIni
					   and fecha_pago <= FechaFin
					   and numcategoria = '07'
					   and numconvenio = '004'
					   and status_cancelado <> 'S'
					   and a.folio_suc = b.folio_suc
					   and b.fech_alt = a.fecha_pago
					   and a.id_sucursal = b.sucursal
					   and a.usuario = b.usua
					   and a.importe_pago = b.monto_tot
				
					INSERT INTO bdisac:"informix".sac_vntnilla_movtos (referencia1,folio_suc,fecha_pago,usuario,id_sucursal,transacc_suc,hora_remesa)
					VALUES (cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion,cHora_remesa);
				
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosMovtos
				FROM bdisac:"informix".sac_vntnilla_movtos;

				FOREACH
					--OBTIENE ULTIMAS CONSULTAS DE QRYI
					select {+INDEX(bdisac:"informix".sac_bts_qryi idx_btsqryi)} NVL(confirmation_nm,''), max(rowid) secuencia
					into cNum_confirmacion, iSecuencia
					from bdisac:"informix".sac_bts_qryi
					where confirmation_nm in (select {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} referencia1 from bdisac:"informix".sac_vntnilla_movtos)
					  and txn_status = 'A'
					  and trans_status_cd = 'ONP'
					  and branch_sd <> '9250'
					  and fecha_insert::date >= FechaIni
					  and fecha_insert::date <= FechaFin
					group by confirmation_nm
					
					INSERT INTO bdisac:"informix".sac_qryis (confirmation_nm, secuencia)
					VALUES (cNum_confirmacion, iSecuencia);
					
				END FOREACH;

				FOREACH
					--OBTIENE DATOS DE QRYI
					select {+INDEX(bdisac:"informix".sac_qryis idxsac_qryiscs)} NVL(a.confirmation_nm,''),NVL(agent_dt,''),NVL(process_dt,''),NVL(destination_am,0),NVL(origin_am,0),NVL(terminal,''),
						   NVL(s_first_name,''),NVL(s_middle_name,''),NVL(s_last_name,''),NVL(s_mother_m_name,''),NVL(r_first_name,''),NVL(r_middle_name,''),NVL(r_last_name,''),NVL(r_mother_m_name,''),
						   NVL(s_address,''),NVL(r_address,''),NVL(s_address,''), NVL(s_identif_nm,''), NVL(s_type_cd,''),
						   NVL(orig_country_cd,''), NVL(orig_currency_cd,''), NVL(dest_country_cd,''), NVL(dest_currency_cd,''), NVL(exch_rate_fx,''),
						   NVL(s_city,''), NVL(s_state_cd,''), NVL(s_country_cd,''), NVL(s_zip_code,''), NVL(s_phone,'')
						into cNum_confirmacion, cAgent_dt, cProcess_dt, mMonto_total, mMonto_dolares, cTerminal, cOrdenante_nombre1, cOrdenante_nombre2,
						cOrdenante_appaterno, cOrdenante_apmaterno, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
						cOrdenante_direccion, cBeneficiario_direccion, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante, cCod_pais_origen, cCod_moneda_origen,
						cCod_pais_destino, cCod_moneda_destino, cTipo_cambio, cCd_remitente, cCod_edo_remitente, cCod_pais_remitente, cCp_remitente, cTel_remitente
					  from bdisac:"informix".sac_bts_qryi a,bdisac:"informix".sac_qryis b
					 where a.fecha_insert::date >= FechaIni
					   and a.fecha_insert::date <= FechaFin
					   and a.confirmation_nm  = b.confirmation_nm
					  and a.rowid = secuencia
					
					INSERT INTO bdisac:"informix".sac_datos1_query (confirmation_nm,agent_dt,process_dt,destination_am,origin_am,terminal,
						   s_first_name,s_middle_name,s_last_name,s_mother_m_name,r_first_name,r_middle_name,r_last_name,r_mother_m_name,
						   s_address,r_address,colonia_ordenante,numero_id_ordenante,ciudad_id_ordenante,cod_pais_origen,cod_moneda_origen,
						   cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente)
					VALUES (cNum_confirmacion, cAgent_dt, cProcess_dt, mMonto_total, mMonto_dolares, cTerminal, cOrdenante_nombre1, cOrdenante_nombre2,
						cOrdenante_appaterno, cOrdenante_apmaterno, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
						cOrdenante_direccion, cBeneficiario_direccion,cColonia_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,cCod_pais_origen, cCod_moneda_origen,
						cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente);
				
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosQryi
				FROM bdisac:"informix".sac_datos1_query;	

				set isolation to dirty read;
				FOREACH
					select {+INDEX(bdisac:"informix".sac_datos1_query idxsac_datos1_queryc)} NVL(fecha_pago,mdy(01,01,1900)) fecha_remesa,'BTS' tipo_remesa,'NO' abono_cuenta,NVL(referencia1,'') num_confirmacion,NVL(destination_am,0) monto_total,NVL(origin_am,0) monto_dolares,
						   NVL(transacc_suc,'') transaccion,NVL(folio_suc,'') folio_sucursal,today fecha_alta,NVL(r_first_name,'') beneficiario_nombre1,NVL(r_middle_name,'') beneficiario_nombre2,
						   NVL(r_last_name,'') beneficiario_appaterno,NVL(r_mother_m_name,'') beneficiario_apmaterno,NVL(r_address,'') beneficiario_direccion,NVL(s_first_name,'') ordenante_nombre1,
						   NVL(s_middle_name,'') ordenante_nombre2,NVL(s_last_name,'') ordenante_appaterno,NVL(s_mother_m_name,'') ordenante_apmaterno,NVL(s_address,'') ordenante_direccion,
						   NVL(id_sucursal,'') sucursal,NVL(usuario,''), NVL(hora_remesa,''), NVL(colonia_ordenante,''),NVL(numero_id_ordenante,''),NVL(ciudad_id_ordenante,''),
						   cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente
						into dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
						cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cBeneficiario_direccion, cOrdenante_nombre1, cOrdenante_nombre2,
							cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante,
							cCod_pais_origen, cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente
					  from bdisac:"informix".sac_datos1_query, bdisac:"informix".sac_vntnilla_movtos
					 where  confirmation_nm  = referencia1
					
					INSERT INTO bdisac:"informix".sac_datos2_query (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,
					transaccion,folio_sucursal,fecha_alta,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
					beneficiario_direccion,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,
					sucursal,usuario,hora_remesa,colonia_ordenante,numero_id_ordenante,ciudad_id_ordenante,
					cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente)
					VALUES (dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
					cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cBeneficiario_direccion, cOrdenante_nombre1, cOrdenante_nombre2,
					cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,
					cCod_pais_origen, cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente);
				
				END FOREACH;

				FOREACH
				--OBTIENE ULTIMOS REGISTROS DE PAYI PARA DATOS DE BENEFICIARIO
					select {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} NVL(a.confirmation_nm,''), max(a.rowid) secuencia
					into cNum_confirmacion, iSecuencia
					from bdisac:"informix".sac_bts_payi a, bdisac:"informix".sac_vntnilla_movtos
					where a.confirmation_nm = referencia1
					  and a.fecha_insert::date >= FechaIni
					  and a.fecha_insert::date <= FechaFin
					group by a.confirmation_nm
					
					INSERT INTO bdisac:"informix".sac_vntnilla_payi (confirmation_nm, secuencia)
					VALUES (cNum_confirmacion, iSecuencia);
					
				END FOREACH;				

				FOREACH
					--SE OBTIENEN LOS DATOS DEL BENEFICIARIO
					select {+INDEX(bdisac:"informix".sac_vntnilla_payi idxsac_vntnilla_payics)} NVL(a.confirmation_nm,''),NVL(r_fecha_nac,mdy(01,01,1900)) beneficiario_fecha_nac,NVL(r_estado,'') beneficiario_estado,NVL(r_mncpo_deleg,'') beneficiario_mncpo_del,
						   NVL(r_ciudad,'') beneficiario_ciudad,NVL(r_colonia,'') beneficiario_colonia,NVL(r_nom_calle,'') beneficiario_calle,NVL(r_num_ext,'') beneficiario_num_ext,
						   NVL(r_num_int,'') beneficiario_num_int, NVL(r_depto,'') beneficiario_depto,NVL(r_cp,'') beneficiario_cp, NVL(r_identif_nm,''),
						   NVL(r_identif_type,''),NVL(r_identif_nm,''),NVL(r_issuer_country_cd,''),NVL(r_cp,''),NVL(r_telefono,'')
						into cNum_confirmacion, cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_colonia, 
						cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp, cNum_id_benef_suc,
						cTp_id_benef, cNum_id_benef, cCod_pais_benef, cCp_benef, cTel_benef
					  from bdisac:"informix".sac_bts_payi a,bdisac:"informix".sac_vntnilla_payi b
					 where a.fecha_insert::date >= FechaIni
					   and a.fecha_insert::date <= FechaFin
					   and a.confirmation_nm  = b.confirmation_nm
					  and a.rowid = secuencia
					
					INSERT INTO bdisac:"informix".sac_vntnilla_payi1 (confirmation_nm,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
					beneficiario_ciudad,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,beneficiario_cp,num_id_benef_suc,
					tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef)
					VALUES (cNum_confirmacion, cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_colonia, 
					cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp,cNum_id_benef_suc,cTp_id_benef,cNum_id_benef,
					cCod_pais_benef,cCp_benef,cTel_benef);
					
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosPayi
				FROM bdisac:"informix".sac_vntnilla_payi1;	
				
				FOREACH

				   select {+INDEX(bdisac:"informix".sac_datos2_query idxsac_datos2_queryn)} NVL(fecha_remesa,mdy(01,01,1900)),NVL(tipo_remesa,''),NVL(abono_cuenta,''),NVL(num_confirmacion,''),NVL(monto_total,0),NVL(monto_dolares,0),
						  NVL(transaccion,''),NVL(folio_sucursal,''), NVL(fecha_alta,mdy(01,01,1900)), NVL(beneficiario_nombre1,''), NVL(beneficiario_nombre2,''),
						  NVL(beneficiario_appaterno,''),NVL(beneficiario_apmaterno,''), NVL(beneficiario_fecha_nac,mdy(01,01,1900)), NVL(beneficiario_estado,''), NVL(beneficiario_mncpo_del,''),
						  NVL(beneficiario_ciudad,''),NVL(beneficiario_direccion,''), NVL(beneficiario_colonia,''), NVL(beneficiario_calle,''), NVL(beneficiario_num_ext,''),
						  NVL(beneficiario_num_int,''), NVL(beneficiario_depto,''), NVL(beneficiario_cp,''),NVL(ordenante_nombre1,''), NVL(ordenante_nombre2,''), NVL(ordenante_appaterno,''),
						  NVL(ordenante_apmaterno,''), NVL(ordenante_direccion,''),
						  NVL(sucursal,''),NVL(usuario,''), NVL(hora_remesa,''), NVL(colonia_ordenante,''), NVL(numero_id_ordenante,''), NVL(ciudad_id_ordenante,''),
						  NVL(beneficiario_nombre1,'') || " " || NVL(beneficiario_nombre2,'') || " " || NVL(beneficiario_appaterno,'') || " " || NVL(beneficiario_apmaterno,''),
						  NVL(num_id_benef_suc,''),cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,
						  tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef
					INTO dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta, 
							cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cFechaFor, cBeneficiario_estado, 
							cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, 
							cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, 
							cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante, cName_benef_suc,
							cNum_id_benef_suc,cCod_pais_origen, cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,
							cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
					from bdisac:"informix".sac_datos2_query a, bdisac:"informix".sac_vntnilla_payi1 b
				   where num_confirmacion = confirmation_nm
				   and confirmation_nm = num_confirmacion
				   
				   LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,5,2),SUBSTR(cFechaFor,7,2),SUBSTR(cFechaFor,1,4));
				   LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
					
					INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
						VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta, 
							cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado, 
							cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int,
							cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,
							cUsuario,dFecha_Proceso,
							mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,'','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',dHora_proceso,cHora_remesa,cColonia_ordenante,'',cNumero_id_ordenante,cCiudad_id_ordenante,'',cName_benef_suc,
							cNum_id_benef_suc,'01011900');
						
				END FOREACH;
				
				--OBTENER REMESAS QUE NO ESTEN EN ALGUNA DE LAS TABLAS
				IF iCuantosCheq <> iCuantosMovtos THEN
				
					FOREACH
								
						select {+INDEX(bdisac:"informix".sac_vntnilla_cargo_bts idxsac_vntnilla_cargo_btsffs)} 
						NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''), NVL(sucursal,''), NVL(usua,''), NVL(monto_tot,0),NVL(hora_remesa,'')
						into cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa
						from bdisac:"informix".sac_vntnilla_cargo_bts 
						where folio_suc not in (select {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} folio_suc from bdisac:"informix".sac_vntnilla_movtos)
						
						LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
					
						INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
						num_id_benef_suc,fecha_envio_remesa)
						VALUES(dFecha_Alt, 'BTS', 'NO', '', mMonto_total, 0, cTransaccion, cFolio_sucursal, (today), 
							'', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '',	'', '', '', '', '', '', '', cSucursal, cUsuario, dFecha_Proceso,
							mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');
									
					END FOREACH;
				
					ELSE IF (iCuantosQryi <> iCuantosMovtos) AND (iCuantosPayi <> iCuantosMovtos) THEN

						FOREACH
								
							select {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} 
							NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(transacc_suc,''),NVL(hora_remesa,'')
							into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
							from bdisac:"informix".sac_vntnilla_movtos 
							where referencia1 not in (select {+INDEX(bdisac:"informix".sac_datos2_query idxsac_datos2_queryn)} num_confirmacion from bdisac:"informix".sac_datos2_query)
							and referencia1 not in (select {+INDEX(bdisac:"informix".sac_vntnilla_payi1 idxsac_vntnilla_payi1c)} confirmation_nm from bdisac:"informix".sac_vntnilla_payi1)

							select {+INDEX(bdisac:"informix".sac_vntnilla_cargo_bts idxsac_vntnilla_cargo_btsffs)} NVL(monto_tot,0)
							into mMonto_total
							from bdisac:"informix".sac_vntnilla_cargo_bts 
							where folio_suc = cFolio_Sucursal
							and fech_alt = dFecha_Alt
							and transacc_suc = cTransaccion
							and sucursal = cSucursal
							and usua = cUsuario;
							
							LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
						
							INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
							beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
							beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
							beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
							fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
							numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
							tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
							cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
							hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
							num_id_benef_suc,fecha_envio_remesa)
							VALUES(dFecha_Alt, 'BTS', 'NO', cReferencia1, mMonto_total, '', cTransaccion, cFolio_sucursal, (today), 
								'', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cSucursal,cUsuario,dFecha_Proceso,
								mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,cColonia_ordenante,'','','','',''
								,'','01011900');
									
						END FOREACH;
						
						ELSE IF iCuantosPayi <> iCuantosMovtos THEN
							
							FOREACH
								
								select {+INDEX(bdisac:"informix".sac_datos2_query idxsac_datos2_queryn)} NVL(fecha_remesa,mdy(01,01,1900)),NVL(tipo_remesa,''),NVL(abono_cuenta,''),NVL(num_confirmacion,''),NVL(monto_total,0),NVL(monto_dolares,0),
									NVL(transaccion,''),NVL(folio_sucursal,''),NVL(fecha_alta,mdy(01,01,1900)),NVL(beneficiario_nombre1,''),NVL(beneficiario_nombre2,''),NVL(beneficiario_appaterno,''),NVL(beneficiario_apmaterno,''),
									NVL(beneficiario_direccion,''),NVL(ordenante_nombre1,''),NVL(ordenante_nombre2,''),NVL(ordenante_appaterno,''),NVL(ordenante_apmaterno,''),NVL(ordenante_direccion,''),
									NVL(sucursal,''),NVL(usuario,''),NVL(hora_remesa,''), NVL(colonia_ordenante,''),NVL(numero_id_ordenante,''),NVL(ciudad_id_ordenante,''),
									NVL(beneficiario_nombre1,'') || " " || NVL(beneficiario_nombre2,'') || " " || NVL(beneficiario_appaterno,'') || " " || NVL(beneficiario_apmaterno,''),
									cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente
								into dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
									cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cBeneficiario_direccion, cOrdenante_nombre1, cOrdenante_nombre2,
									cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante,
									cName_benef_suc, cCod_pais_origen, cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente
								from bdisac:"informix".sac_datos2_query
								where num_confirmacion not in (select {+INDEX(bdisac:"informix".sac_vntnilla_payi1 idxsac_vntnilla_payi1c)} confirmation_nm from bdisac:"informix".sac_vntnilla_payi1)	
								
								LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
								
								INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
								beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
								beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
								beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
								fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
								numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
								tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
								cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
								hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
								num_id_benef_suc,fecha_envio_remesa)
								VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cNum_confirmacion, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta, 
									cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, mdy(01,01,1900), '', 
									'', '', cBeneficiario_direccion, '', '', '', '',
									'', '', cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,
									cUsuario,dFecha_Proceso,
									mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,'','','','','','','','','','','','','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',dHora_proceso,cHora_remesa,cColonia_ordenante,'',cNumero_id_ordenante,cCiudad_id_ordenante,'',cName_benef_suc,
									'','01011900');
									
							END FOREACH;
							ELSE IF iCuantosQryi <> iCuantosMovtos THEN
							
								FOREACH
								
									select {+INDEX(bdisac:"informix".sac_vntnilla_payi1 idxsac_vntnilla_payi1c)} NVL(confirmation_nm,''),NVL(beneficiario_fecha_nac,mdy(01,01,1900)),NVL(beneficiario_estado,''),NVL(beneficiario_mncpo_del,''),
										NVL(beneficiario_ciudad,''),NVL(beneficiario_colonia,''),NVL(beneficiario_calle,''),NVL(beneficiario_num_ext,''),NVL(beneficiario_num_int,''),NVL(beneficiario_depto,''),NVL(beneficiario_cp,''),
										NVL(num_id_benef_suc,''),tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef
									into cNum_confirmacion, cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_colonia, 
										cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp,cNum_id_benef_suc,
										cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
									from bdisac:"informix".sac_vntnilla_payi1
									where confirmation_nm not in (select {+INDEX(bdisac:"informix".sac_datos2_query idxsac_datos2_queryn)} num_confirmacion from bdisac:"informix".sac_datos2_query)	
									
									select {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} 
									NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(transacc_suc,''), NVL(hora_remesa,'')
									into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
									from bdisac:"informix".sac_vntnilla_movtos 
									where referencia1 = cNum_confirmacion;
									
									select {+INDEX(bdisac:"informix".sac_vntnilla_cargo_bts idxsac_vntnilla_cargo_btsffs)} NVL(monto_tot,0)
									into mMonto_total
									from bdisac:"informix".sac_vntnilla_cargo_bts 
									where folio_suc = cFolio_Sucursal
									and fech_alt = dFecha_Alt
									and transacc_suc = cTransaccion
									and sucursal = cSucursal
									and usua = cUsuario;			
			
									select max(rowid) secuencia
									into iSecuencia
									from bdisac:"informix".sac_bts_payi
									where confirmation_nm = cNum_confirmacion
									  and fecha_insert::date = dFecha_Alt
									group by confirmation_nm;					
									
									select {+INDEX(bdisac:"informix".sac_bts_payi idx_sac_bts_payi3)} NVL(r_first_name,''), NVL(r_middle_name,''), NVL(r_last_name,''), NVL(r_mother_m_name,'')
									into cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno
									from bdisac:"informix".sac_bts_payi
									where confirmation_nm = cNum_confirmacion
									and fecha_insert::date = dFecha_Alt
									and rowid = iSecuencia;
				
									LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,5,2),SUBSTR(cFechaFor,7,2),SUBSTR(cFechaFor,1,4));
									LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);									
									
									INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
									beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
									beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
									beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
									fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
									numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
									tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
									cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
									hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
									num_id_benef_suc,fecha_envio_remesa)
									VALUES(dFecha_Alt, 'BTS', 'NO', cNum_confirmacion, mMonto_total, 0, cTransaccion, cFolio_sucursal, (today), 
										cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado, 
										cBeneficiario_mncpo_del, cBeneficiario_ciudad, '', cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int,
										cBeneficiario_depto, cBeneficiario_cp, '', '', '', '', '', cSucursal,
										cUsuario,dFecha_Proceso,
										mdy(01,01,1900),'','','','','','','','','0','','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','','','','','','','','',dHora_proceso,NVL(cHora_remesa,'00:00:00'),'','','','','','',
										cNum_id_benef_suc,'01011900');								
								END FOREACH;							
							END IF;						
						END IF;
					END IF;					
				END IF;				
				
			END IF;				
		
		END IF;	

		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_BTS', FechaFin, '1', 'informix', 'sp_remesasbts_pld', cDescripcionSPJ);
		RETURN cCodRet, cMensaje;
			
	END;		
END PROCEDURE;