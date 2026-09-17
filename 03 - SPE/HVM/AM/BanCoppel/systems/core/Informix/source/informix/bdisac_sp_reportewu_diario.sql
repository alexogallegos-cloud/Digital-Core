CREATE PROCEDURE "informix".sp_reportewu_diario(pPeriodo DATE, pConvenio CHAR(5))
RETURNING 
DATE 		AS Dia, 
CHAR (16) 	AS Num_confirmacion, 
MONEY 		AS Importe, 
CHAR (20) 	AS Forma_pago, 
CHAR (16) 	AS Folio_op, 
CHAR (5) 	AS Sucursal, 
CHAR (8) 	AS Cajero, 
CHAR (120) 	AS Nom_benef;

/*  DEFINICION DE VARIABLES */
DEFINE dDia 				DATE;
DEFINE cNum_confirmacion 	CHAR(16);
DEFINE mImporte 			MONEY; 
DEFINE cForma_pago 			CHAR (20);
DEFINE cFolio_op 			CHAR (16);
DEFINE cSucursal 			CHAR (5);
DEFINE cCajero 				CHAR (8);
DEFINE cNom_benef 			CHAR (120);
DEFINE iSqlerr 				INTEGER ;
DEFINE cCategoria 			CHAR(2);
DEFINE cConvenio 			CHAR(3);

/* INICIALIZACION DE VARIABLES */

		
		--SET DEBUG FILE TO "/informix/noe/sp_reportewu_diario.out";
		--TRACE ON;


LET dDia = CURRENT;
LET cNum_confirmacion = '';
LET mImporte    = 0.0;
LET cForma_pago = '';
LET cFolio_op   = '';
LET cSucursal   = '';
LET cCajero     = '';
LET cNom_benef  = '';
LET iSqlerr     = 0 ;
LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio  = SUBSTRING(pConvenio FROM 3 FOR 3);


BEGIN

	ON EXCEPTION SET iSqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
		
		RETURN '01/01/1900', iSqlerr, '', 0.0, '', '', '', '';
		
	END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	IF (pPeriodo  IS NULL) OR (cCategoria = "" OR cCategoria IS NULL) OR (cConvenio = "" OR cConvenio IS NULL) THEN 
		RETURN '01/01/1900', '', '', 0.0, '', '', '', '';
	ELSE 		
		DROP TABLE IF EXISTS tmp_reportewu;
		SELECT DISTINCT fecha_pago,mtcn,importe_pago,forma_pago,folio_suc,id_sucursal,usuario, nom_benef FROM(
		SELECT movhis.fecha_pago, wu.mtcn, movhis.importe_pago,
			--(DECODE(movhis.forma_pago, '1', 'EFECTIVO', DECODE(movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(movhis.forma_pago, '3', 'MIXTO', DECODE(movhis.forma_pago, '4', 'ABONO EN CUENTA', movhis.forma_pago))))), --nmr 28jul2020
			case when movhis.forma_pago='1' and movhis.origen ='CPL' then 'EFECTIVO-CPL' 
                 when movhis.forma_pago='1' and movhis.origen <>'CPL' then 'EFECTIVO'
                 when movhis.forma_pago='2' and movhis.origen <>'CPL' then 'CARGO EN CUENTA'
                 when movhis.forma_pago='3' and movhis.origen <>'CPL' then 'MIXTO'
                 when movhis.forma_pago='4' and movhis.origen <>'CPL' then 'ABONO CTA'
            end forma_pago,
			movhis.folio_suc, movhis.id_sucursal, movhis.usuario,
			(TRIM(wu.benef_nombre1) || ' ' || TRIM(wu.benef_appaterno) || ' ' || TRIM(wu.benef_apmaterno)) nom_benef
			 --INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
			 FROM bdisac:"informix".sac_movimientoshistorial AS movhis, bdisac:"informix".sac_wu_pay AS wu  
			WHERE movhis.numcategoria = cCategoria 
			  AND movhis.numconvenio = cConvenio 
			  AND movhis.fecha_pago = pPeriodo
			  AND movhis.folio_suc =  wu.foreign_rs_refnum_rq
			  AND movhis.referencia1 = wu.mtcn
			  AND movhis.status_cancelado = 'N'
              AND wu.txn_status = 'A'
			  AND wu.conf_pago='P' 
              AND wu.retcode = '00000'
			  AND wu.fecha_insert = (select max(fecha_insert)
			 FROM bdisac:"informix".sac_wu_pay 
			WHERE fecha_insert::date = pPeriodo
			  AND foreign_rs_refnum_rq = movhis.folio_suc
			  AND mtcn = movhis.referencia1
              AND txn_status = 'A' 
			  AND conf_pago='P' 
              AND retcode = '00000'
            GROUP BY wu.mtcn)
            UNION ALL
           SELECT movhis.fecha_pago, wu.mtcn , movhis.importe_pago,
			--(DECODE(movhis.forma_pago, '1', 'EFECTIVO', DECODE(movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(movhis.forma_pago, '3', 'MIXTO', DECODE(movhis.forma_pago, '4', 'ABONO EN CUENTA', movhis.forma_pago))))),  --nmr 28jul2020
			case when movhis.forma_pago='1' and movhis.origen ='CPL' then 'EFECTIVO-CPL' 
                 when movhis.forma_pago='1' and movhis.origen <>'CPL' then 'EFECTIVO'
                 when movhis.forma_pago='2' and movhis.origen <>'CPL' then 'CARGO EN CUENTA'
                 when movhis.forma_pago='3' and movhis.origen <>'CPL' then 'MIXTO'
                 when movhis.forma_pago='4' and movhis.origen <>'CPL' then 'ABONO CTA'
            end forma_pago,
			movhis.folio_suc , 	movhis.id_sucursal,	movhis.usuario,
		    (TRIM(wu.benef_nombre1) || ' ' || TRIM(wu.benef_appaterno) || ' ' || TRIM(wu.benef_apmaterno)) nom_benef
		  	 FROM bdisac:"informix".sac_movimientoshistorial AS movhis, bdisac:"informix".sac_wu_pay AS wu  
			WHERE movhis.numcategoria = cCategoria 
			  AND movhis.numconvenio = cConvenio 
			  AND movhis.fecha_pago = pPeriodo
			  AND movhis.folio_suc =  wu.foreign_rs_refnum_rp
			  AND movhis.referencia1 = wu.mtcn
			  AND movhis.status_cancelado = 'N'
              AND wu.txn_status = 'A'
			  AND wu.conf_pago='P' 
              AND wu.retcode = '00000'
			  AND wu.fecha_insert = (select max(fecha_insert)
			 FROM bdisac:"informix".sac_wu_pay 
			WHERE fecha_insert::date = pPeriodo
			  AND foreign_rs_refnum_rp = movhis.folio_suc
			  AND mtcn = movhis.referencia1
              AND txn_status = 'A' 
			  AND conf_pago='P' 
              AND retcode = '00000'
            GROUP BY wu.mtcn)) INTO TEMP tmp_reportewu WITH NO LOG;

		FOREACH select fecha_pago,mtcn,importe_pago,forma_pago,folio_suc,id_sucursal,usuario, nom_benef
				INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
				from tmp_reportewu
			
		   RETURN dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef WITH RESUME;
			
		END FOREACH;

		DROP TABLE IF EXISTS tmp_reportewu;

	END IF;	
END
END PROCEDURE
DOCUMENT
'AUTOR: Eduardo Lopez Cuevas',
'Descripcion: GENERA REPORTE DE WU DIARIO.',
'Fecha: 2013/07/03',
'Version: 20130703.0904',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_agentes(val1 CHAR(30), val2 CHAR(30))
RETURNING CHAR (6) AS codRet;

	DEFINE vCodRet CHAR(6);
	DEFINE vCodRetBit CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamError INTEGER;
	DEFINE cFecha_proceso CHAR(8);
	DEFINE cHora_proceso CHAR(6);
	DEFINE vtransaccion SMALLINT;

	--SET DEBUG FILE TO '/informix/noe/50923/sp_agentes.out';
	--TRACE ON;

	LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
	LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET vtransaccion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamError
			IF iSqlErr <> 0 THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'Agente', iIsamError, iIsamError, iSqlErr, iIsamError, TRIM(val1), 'sys_bts', cFecha_proceso, cHora_proceso)
				INTO vCodRetBit;

				IF iSqlErr in ('-26004','-26005','-26006','-26007','-26008','-26009','-26010','-26011','-26012','-26013') THEN
					LET vCodRet='00001';
				ELSE
					LET vCodRet=iSqlErr;
				END IF;

				RETURN vCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
	      LET vtransaccion = 1;
	    END EXCEPTION WITH RESUME;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; 
		
		IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;

		SET ENCRYPTION PASSWORD trim(val2);

		IF val1='' OR val1 IS NULL OR val2='' or val2 IS NULL THEN
			LET vCodRet='00002';
		ELSE
			IF EXISTS (SELECT val FROM "informix".sac_agentes WHERE val= SUBSTR(TRIM(val1),1,LENGTH(TRIM(val1))-1)) THEN

				IF EXISTS (SELECT val FROM "informix".sac_agentes WHERE val=SUBSTR(TRIM(val1),1,LENGTH(TRIM(val1))-1) AND TRIM(DECRYPT_CHAR(trim(llave)))= SUBSTR(TRIM(val1),1,LENGTH(TRIM(val1))-1) || '-' ||  TRIM(val2)) THEN
					LET vCodRet='00000';
				ELSE
					LET vCodRet='00003';
				END IF;
			ELSE
				IF SUBSTR(TRIM(val1),LENGTH(TRIM(val1)),1)= '1' THEN
						INSERT INTO "informix".sac_agentes(val, llave, user_insert, fecha_insert) 
			    		VALUES( SUBSTR(TRIM(val1),1,LENGTH(TRIM(val1))-1), ENCRYPT_AES(SUBSTR(TRIM(val1),1,LENGTH(TRIM(val1))-1) || '-' ||  TRIM(val2)), 'informix', CURRENT);
		    		LET vCodRet='00000';
				ELSE
					LET vCodRet='00004';
				END IF;
			END IF;
		END IF;

        IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;

		RETURN vCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : 93440138 - Noe Medina R.',
'FECHA : 10-06-2021',
'VERSION: 20210609.1439',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_bts_registracdep(pAgent_trans_type_code  CHAR(4),
												 pAgent_cd 				 CHAR(3),
												 pSession_id 		     CHAR(30),
												 pFecha_peticion	     CHAR(8),
												 pHora_peticion          CHAR(6),
												 pNum_confirmacion 	     CHAR(11),
												 pOpcode_cdep 			 CHAR(4),
												 pOpcode 				 CHAR(4),
												 pDescr_mensaje 		 CHAR(100),
												 pDescr_completa_mensaje CHAR(150))
--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS Codigo_Error,
CHAR(80)  AS Desc_error,
CHAR(8)   AS Fecha_proceso,
CHAR(6)   AS Hora_proceso;


--DEFINICION DE VARIABLES--
DEFINE iSql_err       INTEGER;
DEFINE iSam_err		  INTEGER;
DEFINE cCod_err       CHAR(5);
DEFINE cDesc_error    CHAR(80);
DEFINE cMonto_destino CHAR(20);
DEFINE cCadena_ent    CHAR(100);
DEFINE cFecha_sistema DATE;
DEFINE cHora_sistema  CHAR(6);
DEFINE cUsuario       CHAR(8);
DEFINE cPass_encripta CHAR(15);
DEFINE cId_sesion     CHAR(80);
DEFINE cSesion_id     CHAR(80);
DEFINE cFecha_proceso CHAR(8);
DEFINE cHora_proceso  CHAR(6);
DEFINE cTipo_cta_benef CHAR(3); --VPR 01/03/16
DEFINE cCuenta_benef CHAR(30); --VPR 01/03/16
DEFINE cPrefijo_CtaBenef CHAR(6); --VPR 01/03/16
DEFINE vtransaccion		INTEGER;
DEFINE codRetAgente CHAR(6);



--SET DEBUG FILE TO '/home/sysifx/vlv/TraceCompMovINTEGRIDAD.sql';
--TRACE ON;

--INICIALIZACION DE VARIABLES--
LET iSql_err           = 0;
LET iSam_err		   = 0;
LET cCod_err           = '00000';
LET cDesc_error 	   = '';
LET cMonto_destino     = '';
LET cCadena_ent        = ''; /*TRIM(NVL(pAgent_trans_type_code,'NULL')) ||"|"
						 ||TRIM(NVL(pAgent_cd,'NULL'))||"|"
						 ||TRIM(NVL(pSession_id,'NULL'))||"|"
						 ||TRIM(NVL((pNum_confirmacion,'NULL'));*/
LET cFecha_sistema 	   = CURRENT::DATE;
LET cUsuario           = 'sys_bts';
LET cHora_sistema = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cPass_encripta     = '';
LET cId_sesion 		   = '';
LET cSesion_id         = '';
LET cFecha_proceso     = '';
LET cHora_proceso      = '';
LET cTipo_cta_benef    = ''; --VPR 01/03/16
LET cCuenta_benef	   = ''; --VPR 01/03/16
LET cPrefijo_CtaBenef  = ''; --VPR 01/03/16
LET vtransaccion	   = 0;	
LET codRetAgente	   = '';

--SET DEBUG FILE TO '/informix/noe/sp_bts_registracdep.out';
--TRACE ON;



BEGIN
	ON EXCEPTION SET iSql_err,iSam_err
		IF iSql_err <> 0 THEN
			LET cCod_err = iSql_err;
			LET cDesc_error = '';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_registracdep', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,cUsuario, pFecha_peticion,pHora_peticion)
            INTO cCod_err;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
	
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;

	SET LOCK MODE TO WAIT 3;

		INSERT INTO "informix".sac_ws_procesos
		(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		VALUES
		('sp_bts_registracdep',pFecha_peticion,pHora_peticion,'0','',cUsuario,cFecha_sistema,cHora_sistema);

		INSERT INTO bdisac:"informix".sac_bts_cdep
		(cnxn_status,agent_trans_type_code,agent_cd,session_id,num_confirmacion,opcode_cdep,fecha_peticion,
		 hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,user_insert,fecha_insert)
		VALUES
		('A',pAgent_trans_type_code,pAgent_cd,pSession_id,pNum_confirmacion,pOpcode_cdep,pFecha_peticion,
		pHora_peticion,pOpcode,pDescr_mensaje,pDescr_completa_mensaje,pFecha_peticion,pHora_peticion,cUsuario,CURRENT);

	IF pOpcode = '1309' THEN
	
		SELECT LIMIT 1 monto_destino,tipo_cta_benef, cuenta_benef  --Se agregaron dos campos mas
			INTO   cMonto_destino, cTipo_cta_benef,cCuenta_benef
			FROM   bdisac:"informix".sac_bts_sdep
			WHERE  num_confirmacion = pNum_confirmacion;
		
		EXECUTE PROCEDURE "informix".sp_agentes(rpad(trim(pNum_confirmacion),length(trim(pNum_confirmacion))+1,0),trim(cCuenta_benef)) INTO codRetAgente;

		IF TRIM(codRetAgente) <> '00000' THEN
			LET cCod_err = codRetAgente;
			LET cDesc_error = 'Error en validacion CTA-REM';

			UPDATE bdisac:"informix".sac_bts_sdep
			SET estatus_sdep = '97'
			WHERE num_confirmacion = pNum_confirmacion and estatus_sdep = '01';

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;

		UPDATE bdisac:"informix".sac_bts_sdep
			SET estatus_sdep = '02'
			WHERE num_confirmacion = pNum_confirmacion and estatus_sdep = '01';
		
		IF LENGTH(TRIM(cCuenta_benef)) = 16 THEN 
			LET cPrefijo_CtaBenef = SUBSTR(cCuenta_benef, 1,6); --VPR 09/03/16
		ELSE
			LET cPrefijo_CtaBenef = SUBSTR(cCuenta_benef, 1,2); --VPR 09/03/16
		END IF;
		
		--IF cTipo_cta_benef = 'ACC' AND cPrefijo_CtaBenef IN('61','60', '66','70','63','64', '76','77','426807', '554948' )THEN 
		IF cPrefijo_CtaBenef IN('61','60', '66','70','63','64', '76','77','426807', '554948' )THEN 
		
			EXECUTE PROCEDURE bdisac:"informix".sp_bts_aplicapagos_cred (cUsuario,pNum_confirmacion,cMonto_destino,pFecha_peticion,pHora_peticion)
			INTO cCod_err,cDesc_error,cFecha_proceso, cHora_proceso;	
		ELSE 
			EXECUTE PROCEDURE bdisac:"informix".sp_bts_aplicapagos	(cUsuario,pNum_confirmacion,cMonto_destino,pFecha_peticion,pHora_peticion)
			INTO cCod_err,cDesc_error,cFecha_proceso, cHora_proceso;
		END IF; 
		
		IF cCod_err <> '00000' THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(0,'sp_bts_registracdep', cCod_err, cDesc_error,'','', cCadena_ent,cUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err;
		END IF;
		
	ELSE
		UPDATE bdisac:"informix".sac_bts_sdep
			SET estatus_sdep = '08'
			WHERE num_confirmacion = pNum_confirmacion and estatus_sdep = '01';
	END IF;
	
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		COMMIT WORK;
	END IF;

	RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
END;
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 17/10/2012",
"Descripcion: Realiza el registro de los mensajes CDEP que hayan sido",
"			  confirmados por BTS de manera exitosa en la tabla",
"			  bdisac:sac_bts_cdep y actualiza el estatus",
"			  de la remesa de la tabla bdisac:sac_bts_sdep",
"DESCRIPCION: Se modifico sp para consultar los campos 'tipo_cta_benef' y 'cuenta_benef' y validar si tiene estatus ACC ",
			  "y cuenta_benef  de ser asi se ejecutara el nuevo sp Âbdisac:sp_bts_aplicapagos_credÂ.",
"FOLIO: 32-PagoBTSAbnoAutCtasCred ",
"AUTOR : Viridiana Paredes Romero",
"FECHA : 22/03/2016",
"BD: BDISAC";

CREATE PROCEDURE "informix".sp_bts_registrasdep(pcAgent_trans_type_code CHAR(4), pcAgent_cd CHAR(3), pcSession_id CHAR(30), pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6), pcOpcode CHAR(4), pcDescr_mensaje CHAR(50), 
												pcDescr_completa_mensaje CHAR(80), pcFecha_proceso_pet CHAR(8),pcHora_proceso_pet CHAR(6), pcNum_confirmacion CHAR(11),pcId_movimiento CHAR(9), pcFecha_transaccion CHAR(8), 
												pcHora_transaccion CHAR(6), pcCod_servicio CHAR(3), pcTipo_pago_servicio CHAR(3), pcCod_pais_origen CHAR(3), pcCod_moneda_origen CHAR(3), pcCod_pais_destino CHAR(3), 
												pcCod_moneda_destino CHAR(3), pcMonto_origen CHAR(20), pcMonto_destino CHAR(20), pcTipo_cambio CHAR(21), pcCod_divisa CHAR(3), pcTp_cambio_divisa_org CHAR(21), 
												pcMonto_calc_divisa_org CHAR(20), pcCod_agente_org CHAR(3), pcTipo_pago CHAR(3), pcTp_cta_remitente CHAR(3), pcCuenta_remitente CHAR(30), pcCod_banco_remitente CHAR(3), 
												pcRef_num_remitente CHAR(20), pcTipo_cta_benef CHAR(3), pcCuenta_benef CHAR(30), pcCod_agnt_benef CHAR(3),pcRegion_benef CHAR(15), pcSucursal_benef CHAR(15), 
												pcNombre1_remitente CHAR(40), pcNombre2_remitente CHAR(40), pcAp_paterno_remitente CHAR(40), pcAp_materno_remitente CHAR(40),pcDir_remitente CHAR(80), pcCd_remitente CHAR(40), 
												pcCod_edo_remitente CHAR(3), pcCod_pais_remitente CHAR(3), pcCp_remitente CHAR(10), pcTel_remitente CHAR(15),pcNombre1_benef CHAR(40), pcNombre2_benef CHAR(40), 
												pcAp_paterno_benef CHAR(40), pcAp_materno_benef CHAR(40), pcTp_id_benef CHAR(3), pcNum_id_benef CHAR(20),pcNombre1_benef_alt CHAR(40), pcNombre2_benef_alt CHAR(40), 
												pcAp_paterno_alt CHAR(40), pcAp_materno_alt CHAR(40), pcDir_benef CHAR(80), pcCiudad_benef CHAR(40),pcCod_edo_benef CHAR(3), pcCod_pais_benef CHAR(3), pcCp_benef CHAR(10), 
												pcTel_benef CHAR(15), pcCod_tp_id_rmtnte CHAR(3), pcCod_id_rmtnte CHAR(3), pcCod_edo_id_rmtnte CHAR(3),pcCod_pais_id_rmtnte CHAR(3), pcNum_id_rmtnte CHAR(20), 
												pcFec_exp_id_rmtnte CHAR(8), pcFecha_proceso_resp CHAR(8), pcHora_proceso_resp CHAR(6), pcUser_insert CHAR(8), pcFecha_insert CHAR(8))
	RETURNING CHAR(5),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);

DEFINE cNombre_preceso	CHAR(19);
DEFINE cCod_retorno		CHAR(5);
DEFINE cNum_confirmacion 	CHAR (11);
DEFINE cEstatus_sdep 	CHAR(2);
DEFINE iIntentos_envio 	INTEGER;
DEFINE cCadena_ent		CHAR(100);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cAgent_cd		CHAR(3);
DEFINE cId_sesion_act	CHAR(80);
DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE dtFecha_insert	char(10);
DEFINE cPass_encripta	CHAR(15);
DEFINE cSession_id		CHAR(80);
DEFINE vpcTp_cta_remitente CHAR(3);
DEFINE vpcCuenta_remitente CHAR(30);
DEFINE vpcCod_banco_remitente CHAR(3);
DEFINE vpcRef_num_remitente CHAR(20);
DEFINE vpcTipo_cta_benef CHAR(3);
DEFINE vpcCuenta_benef CHAR(30);
DEFINE vpcCod_agnt_benef CHAR(3);
DEFINE codRetAgente CHAR(6);

--SET DEBUG FILE TO '/informix/noe/sp_bts_registrasdep.out';
--TRACE ON;

LET vpcTp_cta_remitente = pcTp_cta_remitente;
LET vpcCuenta_remitente = pcTp_cta_remitente;
LET vpcCod_banco_remitente = pcTp_cta_remitente;
LET vpcRef_num_remitente = pcTp_cta_remitente;
LET vpcTipo_cta_benef = pcTp_cta_remitente;
LET vpcCuenta_benef = pcTp_cta_remitente;
LET vpcCod_agnt_benef = pcTp_cta_remitente;



--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');

LET cNombre_preceso = 'sp_bts_registrasdep';
LET cCod_retorno = '';
LET cNum_confirmacion = '';
LET cEstatus_sdep = '01';
LET iIntentos_envio = 0;
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcSession_id,'NULL')) || '|' || TRIM(NVL(pcNum_confirmacion,'NULL'));
LET cOpcode = '';
LET cDescr_mensaje = '';
LET cAgent_cd = '';
LET cId_sesion_act = '';
LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;
LET dtFecha_insert =  CURRENT::DATE;
LET cPass_encripta = '';
LET cSession_id = '';
LET codRetAgente ='';

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			LET cEstatus_sdep = '99';			
			INSERT INTO bdisac:"informix".sac_bts_sdep(cnxn_status,agent_trans_type_code,agent_cd,session_id,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,
													num_confirmacion,id_movimiento,fecha_transaccion,hora_transaccion,cod_servicio,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,
													cod_moneda_destino,monto_origen,monto_destino,tipo_cambio,cod_divisa,tp_cambio_divisa_org,monto_calc_divisa_org,cod_agente_org,tipo_pago,tp_cta_remitente,	
													cuenta_remitente,cod_banco_remitente,ref_num_remitente,tipo_cta_benef,cuenta_benef,cod_agnt_benef,region_benef,sucursal_benef,nombre1_remitente,
													nombre2_remitente,ap_paterno_remitente,ap_materno_remitente,dir_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,
													nombre1_benef,nombre2_benef,ap_paterno_benef,ap_materno_benef,tp_id_benef,num_id_benef,nombre1_benef_alt,nombre2_benef_alt,ap_paterno_alt,ap_materno_alt,
													dir_benef,ciudad_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_tp_id_rmtnte,cod_id_rmtnte,cod_edo_id_rmtnte,cod_pais_id_rmtnte,num_id_rmtnte,
													fec_exp_id_rmtnte,estatus_sdep,intentos_envio,user_insert,fecha_insert)
			VALUES('C',pcAgent_trans_type_code,pcAgent_cd,pcSession_id,pcFecha_peticion,pcHora_peticion,pcOpcode,pcDescr_mensaje,pcDescr_completa_mensaje,cFecha_proceso,cHora_proceso,
					pcNum_confirmacion,pcId_movimiento,pcFecha_transaccion,pcHora_transaccion,pcCod_servicio,pcTipo_pago_servicio,pcCod_pais_origen,pcCod_moneda_origen,pcCod_pais_destino,
					pcCod_moneda_destino,pcMonto_origen,pcMonto_destino,pcTipo_cambio,pcCod_divisa,pcTp_cambio_divisa_org,pcMonto_calc_divisa_org,pcCod_agente_org,pcTipo_pago,pcTp_cta_remitente,
					pcCuenta_remitente,pcCod_banco_remitente,pcRef_num_remitente,pcTipo_cta_benef,pcCuenta_benef,pcCod_agnt_benef,pcRegion_benef,pcSucursal_benef,pcNombre1_remitente,
					pcNombre2_remitente,pcAp_paterno_remitente,pcAp_materno_remitente,pcDir_remitente,pcCd_remitente,pcCod_edo_remitente,pcCod_pais_remitente,pcCp_remitente,pcTel_remitente,
					pcNombre1_benef,pcNombre2_benef,pcAp_paterno_benef,pcAp_materno_benef,pcTp_id_benef,pcNum_id_benef,pcNombre1_benef_alt,pcNombre2_benef_alt,pcAp_paterno_alt,
					pcAp_materno_alt,pcDir_benef,pcCiudad_benef,pcCod_edo_benef,pcCod_pais_benef,pcCp_benef,pcTel_benef, pcCod_tp_id_rmtnte,pcCod_id_rmtnte,pcCod_edo_id_rmtnte,
					pcCod_pais_id_rmtnte,pcNum_id_rmtnte,pcFec_exp_id_rmtnte,cEstatus_sdep,iIntentos_envio,pcUser_insert,current);
						
			--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUser_insert, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
			RETURN cCod_err,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','', pcUser_insert, dtFecha_insert, cHora_proceso);	
	
	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' THEN
		LET cCod_err = '9001';
		LET cEstatus_sdep = '99';
	END IF;
						
	SELECT FIRST 1 num_confirmacion, estatus_sdep
		INTO cNum_confirmacion, cEstatus_sdep
		FROM bdisac:"informix".sac_bts_sdep WHERE num_confirmacion = pcNum_confirmacion AND estatus_sdep <> '09';
					
	IF pcNum_confirmacion = cNum_confirmacion AND (cEstatus_sdep = '03' OR cEstatus_sdep = '04' OR cEstatus_sdep = '05' OR cEstatus_sdep = '06') THEN
		LET cCod_err = '9982';
		LET cEstatus_sdep = '99';
	ELIF pcNum_confirmacion = cNum_confirmacion AND (cEstatus_sdep = '01' OR cEstatus_sdep = '02' OR cEstatus_sdep = '99') THEN
		UPDATE bdisac:"informix".sac_bts_sdep SET estatus_sdep = '09' 
			WHERE agent_trans_type_code = pcAgent_trans_type_code AND agent_cd = pcAgent_cd AND num_confirmacion = pcNum_confirmacion and estatus_sdep IN ('01','02');
		IF cEstatus_sdep <> '99' THEN
			LET cEstatus_sdep = '01';
		END IF;	
	ELIF pcNum_confirmacion IS NULL THEN
		LET cEstatus_sdep = '01';
	ELSE
		LET cEstatus_sdep = '01';
	END IF;
				
	INSERT INTO bdisac:"informix".sac_bts_sdep(cnxn_status,agent_trans_type_code,agent_cd,session_id,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,
		num_confirmacion,id_movimiento,fecha_transaccion,hora_transaccion,cod_servicio,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,
		cod_moneda_destino,monto_origen,monto_destino,tipo_cambio,cod_divisa,tp_cambio_divisa_org,monto_calc_divisa_org,cod_agente_org,tipo_pago,tp_cta_remitente,	
		cuenta_remitente,cod_banco_remitente,ref_num_remitente,tipo_cta_benef,cuenta_benef,cod_agnt_benef,region_benef,sucursal_benef,nombre1_remitente,
		nombre2_remitente,ap_paterno_remitente,ap_materno_remitente,dir_remitente,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,
		nombre1_benef,nombre2_benef,ap_paterno_benef,ap_materno_benef,tp_id_benef,num_id_benef,nombre1_benef_alt,nombre2_benef_alt,ap_paterno_alt,ap_materno_alt,
		dir_benef,ciudad_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_tp_id_rmtnte,cod_id_rmtnte,cod_edo_id_rmtnte,cod_pais_id_rmtnte,num_id_rmtnte,
		fec_exp_id_rmtnte,estatus_sdep,intentos_envio,user_insert,fecha_insert)
	VALUES('A',pcAgent_trans_type_code,pcAgent_cd,pcSession_id,pcFecha_peticion,pcHora_peticion,pcOpcode,pcDescr_mensaje,pcDescr_completa_mensaje,cFecha_proceso,cHora_proceso,
		pcNum_confirmacion,pcId_movimiento,pcFecha_transaccion,pcHora_transaccion,pcCod_servicio,pcTipo_pago_servicio,pcCod_pais_origen,pcCod_moneda_origen,pcCod_pais_destino,
		pcCod_moneda_destino,pcMonto_origen,pcMonto_destino,pcTipo_cambio,pcCod_divisa,pcTp_cambio_divisa_org,pcMonto_calc_divisa_org,pcCod_agente_org,pcTipo_pago,pcTp_cta_remitente,
		pcCuenta_remitente,pcCod_banco_remitente,pcRef_num_remitente,pcTipo_cta_benef,pcCuenta_benef,pcCod_agnt_benef,pcRegion_benef,pcSucursal_benef,pcNombre1_remitente,
		pcNombre2_remitente,pcAp_paterno_remitente,pcAp_materno_remitente,pcDir_remitente,pcCd_remitente,pcCod_edo_remitente,pcCod_pais_remitente,pcCp_remitente,pcTel_remitente,
		pcNombre1_benef,pcNombre2_benef,pcAp_paterno_benef,pcAp_materno_benef,pcTp_id_benef,pcNum_id_benef,pcNombre1_benef_alt,pcNombre2_benef_alt,pcAp_paterno_alt,
		pcAp_materno_alt,pcDir_benef,pcCiudad_benef,pcCod_edo_benef,pcCod_pais_benef,pcCp_benef,pcTel_benef, pcCod_tp_id_rmtnte,pcCod_id_rmtnte,pcCod_edo_id_rmtnte,
		pcCod_pais_id_rmtnte,pcNum_id_rmtnte,pcFec_exp_id_rmtnte,cEstatus_sdep,iIntentos_envio,pcUser_insert,current);


	EXECUTE PROCEDURE "informix".sp_agentes(rpad(trim(pcNum_confirmacion),length(trim(pcNum_confirmacion))+1,1),trim(pcCuenta_benef)) INTO codRetAgente;

	--Se actualiza la tabla sac_ws_procesos con el estatus y el codigo de retorno del sp, para saber que fue exitoso0
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, '')
		INTO cOpcode,cDescr_mensaje 
		FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN			
			LET cDescr_mensaje = 'CÃ³digo no registrado en catÃ¡logo.';			
		END IF;		
	END IF;

	EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUser_insert, pcFecha_peticion, pcHora_peticion)		
		INTO cCod_retorno;
						
	RETURN LPAD(cCod_err,5,'0'),cFecha_proceso,cHora_proceso;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crae SP para registrar en la tabla bdisac:sac_bts_sdep la informaciÃ³n obtenida por parte de BTS para el pago de una remesa con abono directo en cuenta',
'AUTOR : JosÃ© LuÃ­s Polanco B.',
'FECHA : 01 de Noviembre de 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_app_getorder(pCompanyCode CHAR (3),				
											pChannelId CHAR (3),
											pTokenId CHAR (80),
											pLanguage CHAR (5),
											pApiVersion CHAR (6),
											pClientSoftwareVersion CHAR (6),
											pNrows CHAR (3),
											pCodeRequest CHAR (3),
											pChannelIdRequest CHAR (3),
											pTaxIdentificationNumber CHAR (20),
											pProcessDateRequest CHAR (8),
											pProcessTimeRequest CHAR (6),
											pCode CHAR (4),
											pMessageResponse CHAR (255),
											pCodeDetail CHAR (4),
											pMessageDetail CHAR (255),
											pProcessDateDetail CHAR (8),
											pProcessTimeDetail CHAR (6),
											pUniqueReferenceNumber CHAR (16),
											pCodeCompany CHAR (3),
											pCountryCodeBranch CHAR (3),
											pStateCodeBranch CHAR (3),
											pSaleDate CHAR (8),
											pSaleTime CHAR (6),
											pCountryCodeOrigin CHAR (3),
											pCurrencyCodeOrigin CHAR (3),
											pServiceCode CHAR (3),
											pCountryCodeDestination CHAR (3),
											pCurrencyCodeDestination CHAR (3),
											pDeliveryMethodCode CHAR (3),
											pPayNetworkCode CHAR (3),
											pPaySubNetworkCode CHAR (15),
											pBranchNumber CHAR (15),
											pAccountTypeCode CHAR (3),
											pAccountNumberSenderPay CHAR (30),
											pOriginAmount CHAR (20),
											pDestinationAmount CHAR (20),
											pRetailExchangeRate CHAR (21),
											pWholesaleExchangeRate CHAR (21),
											pDestinationExchangeRate CHAR (21),
											pServiceFeeAmount CHAR (20),
											pDiscountAmount CHAR (20),
											pTypeCodeSenderPay CHAR (3),
											pAccountNumberSender CHAR (30),
											pBicCode CHAR (11),
											pReferenceNumber CHAR (30),
											pCustomerNumberSender CHAR (20),
											pFirstNameSender CHAR (40),
											pMiddleNameSender CHAR (40),
											pLastNameSender CHAR (40),
											pMotherMaidenNameSender  CHAR (40),
											pAddressSender CHAR (80),
											pCitySender CHAR (40),
											pCountryCodeSender CHAR (3),
											pStateCodeSender CHAR (3),
											pZipCodeSender CHAR (10),
											pTypeCodeSender CHAR (3),
											pNumberSender CHAR (20),
											pExpirationDateSender CHAR (8),
											pIssuerCountryCodeSender CHAR (3),
											pIssuerStateCodeSender CHAR (3),
											pDateOfBirthSender CHAR (8),
											pCustomerNumberBenefi CHAR (20),
											pFirstNameBenefi CHAR (40),
											pMiddleNameBenefi CHAR (40),
											pLastNameBenefi CHAR (40),
											pMotherMaidenNameBenefi CHAR (40),
											pFirstNameForeign CHAR (40),
											pMiddleNameForeign CHAR (40),
											pLastNameForeign CHAR (40),
											pMotherMaidenNameForeign CHAR (40),
											pAddressBenefi CHAR (80),
											pCityBenefi CHAR (40),
											pCountryCodeBenefi CHAR (3),
											pStateCodeBenefi CHAR (3),
											pZipCodeBenefi CHAR (10),
											pEmail CHAR (100),
											pHomePhoneNumber CHAR (15),
											pWorkPhoneNumber CHAR (15),
											pCarrierCode CHAR (6),
											pCountryCode CHAR (3),
											pNumber_cel CHAR (15),
											pReceiveEmail CHAR (3),
											pReceiveSMS CHAR (3),
											pTypeCode CHAR (3),
											pNumberId CHAR (20),
											pExpirationDate CHAR (8),
											pIssuerCountryCode CHAR (3),
											pIssuerStateCode CHAR (3),
											pReasonTypeCode CHAR (3),
											pReasonForTransfer CHAR (40),
											pSourceOfFunds CHAR (40),
											pSecurityPhrase CHAR (40),
											pFreeMessage CHAR (255),
											pUser_insert CHAR(8),
											pFecha_insert DATE)
	RETURNING CHAR(5),CHAR(8),CHAR(6);

--Definicion de Variables
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamError INTEGER;
	DEFINE cCod_err CHAR(4);
	DEFINE cFecha_proceso CHAR(8);
	DEFINE cHora_proceso CHAR(6);

	DEFINE cNombre_preceso CHAR(19);
	DEFINE cCod_retorno CHAR(5);
	DEFINE cNum_confirmacion CHAR(16);
	DEFINE cEstatus_sdep CHAR(2);
	DEFINE iIntentos_envio INTEGER;
	DEFINE cCadena_ent CHAR(100);
	DEFINE cOpcode CHAR(4);
	DEFINE cDescr_mensaje CHAR(50);
	DEFINE dtFecha_insert CHAR(10);
	DEFINE codRetAgente CHAR(6);

	--SET DEBUG FILE TO '/informix/noe/sp_app_getorder.out';
	--TRACE ON;

	--Inicializacion de Variables
	LET iSqlErr = 0;
	LET iIsamError = 0;
	LET cCod_err = '0000';
	LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
	LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');

	LET cNombre_preceso = 'sp_app_getorder';
	LET cCod_retorno = '';
	LET cNum_confirmacion = '';
	LET cEstatus_sdep = '01';
	LET iIntentos_envio = 0;
	LET cCadena_ent = TRIM(NVL(pCompanyCode,'NULL')) || '|' || TRIM(NVL(pChannelId,'NULL')) || '|' || TRIM(NVL(pTokenId,'NULL')) || '|' || TRIM(NVL(pUniqueReferenceNumber,'NULL'));
	LET cOpcode = '';
	LET cDescr_mensaje = '';
	LET dtFecha_insert =  CURRENT::DATE;
	LET codRetAgente ='';

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			LET cEstatus_sdep = '09';			
				INSERT INTO bdisac:"informix".sac_app_getorder(cnxn_status,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,Nrows,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateDetail,ProcessTimeDetail,UniqueReferenceNumber,CodeCompany,CountryCodeBranch,StateCodeBranch,SaleDate,SaleTime,CountryCodeOrigin,CurrencyCodeOrigin,ServiceCode,CountryCodeDestination,CurrencyCodeDestination,DeliveryMethodCode,PayNetworkCode,PaySubNetworkCode,BranchNumber,AccountTypeCode,AccountNumberSenderPay,OriginAmount,DestinationAmount,RetailExchangeRate,WholesaleExchangeRate,DestinationExchangeRate,ServiceFeeAmount,DiscountAmount,TypeCodeSenderPay,AccountNumberSender,BicCode,ReferenceNumber,CustomerNumberSender,FirstNameSender,MiddleNameSender,LastNameSender,MotherMaidenNameSender,AddressSender,CitySender,CountryCodeSender,StateCodeSender,ZipCodeSender,TypeCodeSender,NumberSender,ExpirationDateSender,IssuerCountryCodeSender,IssuerStateCodeSender,DateOfBirthSender,CustomerNumberBenefi,FirstNameBenefi,MiddleNameBenefi,LastNameBenefi,MotherMaidenNameBenefi,FirstNameForeign,MiddleNameForeign,LastNameForeign,MotherMaidenNameForeign,AddressBenefi,CityBenefi,CountryCodeBenefi, StateCodeBenefi,ZipCodeBenefi,Email,HomePhoneNumber,WorkPhoneNumber,CarrierCode,CountryCode,Number_cel,ReceiveEmail,ReceiveSMS,TypeCode,NumberId,ExpirationDate,IssuerCountryCode,IssuerStateCode,ReasonTypeCode,ReasonForTransfer,SourceOfFunds,SecurityPhrase,FreeMessage,estatus_getorder,intentos_envio, user_insert, fecha_insert)
				Values ('C',pCompanyCode,pChannelId,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pNrows,pCodeRequest,pChannelIdRequest,pTaxIdentificationNumber,cFecha_proceso,cHora_proceso,pCode,pMessageResponse,pCodeDetail,pMessageDetail,pProcessDateDetail,pProcessTimeDetail,pUniqueReferenceNumber,pCodeCompany,pCountryCodeBranch,pStateCodeBranch,pSaleDate,pSaleTime,pCountryCodeOrigin,pCurrencyCodeOrigin,pServiceCode,pCountryCodeDestination,pCurrencyCodeDestination,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,pBranchNumber,pAccountTypeCode,pAccountNumberSenderPay,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,pDestinationExchangeRate,pServiceFeeAmount,pDiscountAmount,pTypeCodeSenderPay,pAccountNumberSender,pBicCode,pReferenceNumber,pCustomerNumberSender,pFirstNameSender,pMiddleNameSender,pLastNameSender,pMotherMaidenNameSender,pAddressSender,pCitySender,pCountryCodeSender,pStateCodeSender,pZipCodeSender,pTypeCodeSender,pNumberSender,pExpirationDateSender,pIssuerCountryCodeSender,pIssuerStateCodeSender,pDateOfBirthSender,pCustomerNumberBenefi,pFirstNameBenefi,pMiddleNameBenefi,pLastNameBenefi,pMotherMaidenNameBenefi, pFirstNameForeign,pMiddleNameForeign,pLastNameForeign,pMotherMaidenNameForeign,pAddressBenefi,pCityBenefi,pCountryCodeBenefi,pStateCodeBenefi,pZipCodeBenefi,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pCarrierCode,pCountryCode,pNumber_cel,pReceiveEmail,pReceiveSMS,pTypeCode,pNumberId,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,pSecurityPhrase,pFreeMessage,cEstatus_sdep,iIntentos_envio,pUser_insert,CURRENT);
						
				--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pUser_insert, pProcessDateRequest, pProcessTimeRequest)
				INTO cCod_retorno;
			
			RETURN cCod_err,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	--VALUES(cNombre_preceso,pProcessDateRequest, pProcessTimeRequest,'0','', pUser_insert, dtFecha_insert, cHora_proceso);	
	
	IF NVL(pCompanyCode, '') = ''        OR NVL(pChannelId, '') = '' OR NVL(pProcessDateRequest, '') = '' OR 
	   NVL(pProcessTimeRequest, '') = '' OR NVL(pUniqueReferenceNumber, '') = ''THEN
		LET cCod_err = '1100';
		LET cEstatus_sdep = '09';
	END IF;
						
	SELECT  FIRST 1 uniquereferencenumber, estatus_getorder
		INTO cNum_confirmacion, cEstatus_sdep
		FROM bdisac:"informix".sac_app_getorder WHERE uniquereferencenumber = TRIM(pUniqueReferenceNumber) AND estatus_getorder <> '09';
		--AND ProcessDateRequest = (SELECT MAX(ProcessDateRequest) FROM bdisac:"informix".sac_app_getorder WHERE uniquereferencenumber = TRIM(pUniqueReferenceNumber) AND estatus_getorder <> '09'); 
		--AND ProcessTimeRequest = (SELECT MAX(ProcessTimeRequest) FROM bdisac:"informix".sac_app_getorder WHERE uniquereferencenumber = TRIM(pUniqueReferenceNumber) AND estatus_getorder <> '09');

	IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cEstatus_sdep = '01';
	else
		IF NVL(pUniqueReferenceNumber, '') = NVL(cNum_confirmacion, '') AND (NVL(cEstatus_sdep,'') = '03' OR NVL(cEstatus_sdep,'') = '04' OR NVL(cEstatus_sdep,'') = '05' OR NVL(cEstatus_sdep,'') = '06') THEN
			LET cCod_err = '1100';
			LET cEstatus_sdep = '09';
		ELIF NVL(pUniqueReferenceNumber, '') = NVL(cNum_confirmacion, '') AND (NVL(cEstatus_sdep,'') = '01' OR NVL(cEstatus_sdep,'') = '02' OR NVL(cEstatus_sdep,'') = '09') THEN
			UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '09' 
				WHERE CompanyCode = pCompanyCode AND channelid = pChannelId AND uniquereferencenumber = pUniqueReferenceNumber and estatus_getorder IN ('01','02');
			IF cEstatus_sdep <> '09' THEN
				LET cEstatus_sdep = '01';   
			END IF;	
		--ELIF pUniqueReferenceNumber IS NULL THEN    
		--	LET cEstatus_sdep = '01';   
		ELSE
			LET cEstatus_sdep = '01';
		END IF;
	END IF;
				
		INSERT INTO bdisac:"informix".sac_app_getorder(cnxn_status,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,Nrows,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateDetail,ProcessTimeDetail,UniqueReferenceNumber,CodeCompany,CountryCodeBranch,StateCodeBranch,SaleDate,SaleTime,CountryCodeOrigin,CurrencyCodeOrigin,ServiceCode,CountryCodeDestination,CurrencyCodeDestination,DeliveryMethodCode,PayNetworkCode,PaySubNetworkCode,BranchNumber,AccountTypeCode,AccountNumberSenderPay,OriginAmount,DestinationAmount,RetailExchangeRate,WholesaleExchangeRate,DestinationExchangeRate,ServiceFeeAmount,DiscountAmount,TypeCodeSenderPay,AccountNumberSender,BicCode,ReferenceNumber,CustomerNumberSender,FirstNameSender,MiddleNameSender,LastNameSender,MotherMaidenNameSender,AddressSender,CitySender,CountryCodeSender,StateCodeSender,ZipCodeSender,TypeCodeSender,NumberSender,ExpirationDateSender,IssuerCountryCodeSender,IssuerStateCodeSender,DateOfBirthSender,CustomerNumberBenefi,FirstNameBenefi,MiddleNameBenefi,LastNameBenefi,MotherMaidenNameBenefi,FirstNameForeign,MiddleNameForeign,LastNameForeign,MotherMaidenNameForeign,AddressBenefi,CityBenefi,CountryCodeBenefi, StateCodeBenefi,ZipCodeBenefi,Email,HomePhoneNumber,WorkPhoneNumber,CarrierCode,CountryCode,Number_cel,ReceiveEmail,ReceiveSMS,TypeCode,NumberId,ExpirationDate,IssuerCountryCode,IssuerStateCode,ReasonTypeCode,ReasonForTransfer,SourceOfFunds,SecurityPhrase,FreeMessage,estatus_getorder,intentos_envio, user_insert, fecha_insert)
		VALUES('A',pCompanyCode,pChannelId,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pNrows,pCodeRequest,pChannelIdRequest,pTaxIdentificationNumber,cFecha_proceso,cHora_proceso,pCode,pMessageResponse,pCodeDetail,pMessageDetail,pProcessDateDetail,pProcessTimeDetail,pUniqueReferenceNumber,pCodeCompany,pCountryCodeBranch,pStateCodeBranch,pSaleDate,pSaleTime,pCountryCodeOrigin,pCurrencyCodeOrigin,pServiceCode,pCountryCodeDestination,pCurrencyCodeDestination,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,pBranchNumber,pAccountTypeCode,pAccountNumberSenderPay,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,pDestinationExchangeRate,pServiceFeeAmount,pDiscountAmount,pTypeCodeSenderPay,pAccountNumberSender,pBicCode,pReferenceNumber,pCustomerNumberSender,pFirstNameSender,pMiddleNameSender,pLastNameSender,pMotherMaidenNameSender,pAddressSender,pCitySender,pCountryCodeSender,pStateCodeSender,pZipCodeSender,pTypeCodeSender,pNumberSender,pExpirationDateSender,pIssuerCountryCodeSender,pIssuerStateCodeSender,pDateOfBirthSender,pCustomerNumberBenefi,pFirstNameBenefi,pMiddleNameBenefi,pLastNameBenefi,pMotherMaidenNameBenefi, pFirstNameForeign,pMiddleNameForeign,pLastNameForeign,pMotherMaidenNameForeign,pAddressBenefi,pCityBenefi,pCountryCodeBenefi,pStateCodeBenefi,pZipCodeBenefi,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pCarrierCode,pCountryCode,pNumber_cel,pReceiveEmail,pReceiveSMS,pTypeCode,pNumberId,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,pSecurityPhrase,pFreeMessage,cEstatus_sdep,iIntentos_envio,pUser_insert,CURRENT);
        
        EXECUTE PROCEDURE "informix".sp_agentes(rpad(trim(pUniqueReferenceNumber),length(trim(pUniqueReferenceNumber))+1,1),trim(pAccountNumberSenderPay)) INTO codRetAgente;

		--Se actualiza la tabla sac_ws_procesos con el estatus y el codigo de retorno del sp, para saber que fue exitoso0
		IF cCod_err <> '0000' THEN		
		
			--Se obtienen los mensajes de error asi como el codigo del mensaje
			SELECT NVL(opcode, ''),NVL(opcode_sd, '')
			INTO cOpcode,cDescr_mensaje 
			FROM bdisac:"informix".sac_app_cat_mensajes WHERE agent_trans_type_code = pCompanyCode AND opcode = cCod_err;
	
			--En caso de que no exista el codigo del mensaje se les asigna otros valores
			IF cOpcode IS NULL THEN			
				LET cDescr_mensaje = 'CÃ?Â³digo no registrado en catÃ?Â¡logo.';			
			END IF;		
		END IF;

		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pUser_insert, pProcessDateRequest, pProcessTimeRequest)		
		--INTO cCod_retorno;
						
	RETURN LPAD(cCod_err,5,'0'),cFecha_proceso,cHora_proceso;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para registrar en la tabla bdisac:sac_app_getorder la informaciÃ?Â³n obtenida por parte de APRIZZA para el pago de una remesa con abono directo en cuenta',
'AUTOR : Pedro G Jimenez Guzman.',
'FECHA : 01 de Noviembre de 2016',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_app_confirmorder (pcUsuario CHAR(15),pRegs_recup INTEGER,pFecha_peticion CHAR(8),pHora_peticion CHAR(6))
RETURNING 	CHAR (5) AS codret,
			CHAR(12) AS numremesa,
			CHAR(4) AS codigo,
			CHAR(8) AS fec_proceso,
			CHAR(6) AS hora_proceso

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_confirmorder';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET cChannelId = SUBSTR (pcUsuario,9,3);
		LET pcUsuario  = SUBSTR (pcUsuario,1,7);
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio
				INTO cRemesa,cCodigo,iIntentosenvio
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '01' or estatus_getorder = '07')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '11' WHERE UniqueReferenceNumber = cRemesa 
				and (estatus_getorder = '01' or estatus_getorder = '07')
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cCod_err,cRemesa,cCodigo,cFecha_proceso,cHora_proceso;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN lpad(cCod_err,5,'0'),cRemesa,cCodigo,cFecha_proceso,cHora_proceso;	
		END IF
	END
END PROCEDURE
DOCUMENT
'AUTOR: 95358919 - MARIO GAMALIEL OLIVO URIAS',
'CENTRO: 230142',
'FOLIO: 150',
'RQM: RQM 10 809 ? Pago de Remesas Appriza con abono automático en cuentas de captación.doc',
'FECHA: 04/NOVIEMBRE/2016',
'SOLICITA: EDUARDO PINEDA',
'VERSION: 20161104.1904',
'DESCRIPCION: CONFIRMACION DE REMESAS REGISTRADAS PARA ABONO AUTOMATICO A CUENTAS DE CAPTACION.',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_registrardatosarchivo ( psNumEmpleado CHAR (10))

RETURNING CHAR (8) AS CodRespuesta,  CHAR (120) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Obtener y registrar en el catÃ¡logo las transacciones para conformar el archivo de pagos a E-Global.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 19/03/2010
-- BD: BdiSac
-- SISTEMA : PAGO INTERBANCARIO DE TARJETAS DE CREDITO (PITDC)
--Modificado:  07/04/2010 --Casanova Edeza Hector Juan --Se modifica el formato de la fecha juliana para el encabezado del archivo de formato ADDD por AADDD.
--Modificado:  29/04/2010 --Casanova Edeza Hector Juan --Se modifica el uso de los parametros de las transacciones de PITDC para que se identifiquen los 4 tipos de transacciones identificadas.
--Modificado:  10/05/2010 --Casanova Edeza Hector Juan --Se modifica el manejo de la variable de numero de tarjeta para que en el caso de contener menos de 16 numero agrege 0 a la izq. del numero de la tarjeta.
--Modificado:  12/05/2010 -- Se le agrega la condicion para que cambie a status '2' todos los registros de fechas anteriores que no tengan status de enviados ('0'), para que no puedan cambiar el status a enviado en un dia posterior.
--Modificado:  05/07/2010 --Se modifica el calculo del digito verificador modulo 10 para que en lugar de utilizar el numero de la tarjeta para el calculo utilice el numero de la referencia de la transaccion.
--****************************************************************************************************


DEFINE vsCodRetorno CHAR (8);
DEFINE vsMensajeRet CHAR (120);
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE vdtFechaActual DATE;
DEFINE viStatus INTEGER;
DEFINE vsFechaUltimoArchivo DATE;
DEFINE vsParamNomArch CHAR (10);
DEFINE vsNombreArchivo CHAR (20);
DEFINE vsRutaArchivo CHAR (100);

DEFINE vsCancelado CHAR(1);
DEFINE vsTransacc_Suc CHAR(4);
DEFINE vsFechaJuliana CHAR (5);
DEFINE vdtFechaAux DATE;
DEFINE vsFolioSuccAux CHAR (8);
DEFINE viContador INTEGER;
DEFINE vsBin_Adquiriente CHAR (6);
DEFINE vsFillerE CHAR (177);
DEFINE vsFillerS CHAR (146);
DEFINE viIdBanco INTEGER;


DEFINE vsFlagAlternar CHAR(1);
DEFINE viAcumulado INTEGER;
DEFINE viValorAux INTEGER;
DEFINE viTotalRegistros INTEGER;
DEFINE viTotalPagos INTEGER;
DEFINE viTotalImportePagos INT8;
DEFINE viTotalRechazados INTEGER;
DEFINE viTotalImporteRechazados INTEGER;

DEFINE vsTransacc CHAR(4);
DEFINE vsParam_TranSacc_Efectivo CHAR(4);
DEFINE vsParam_TranSacc_Otro CHAR(4);
DEFINE vsParam_PagoEfectivo CHAR(4);
DEFINE vsParam_PagoCheqMBanco CHAR(4);
DEFINE vsParam_PagoCheqOBanco CHAR(4);
DEFINE vsParam_PagoInternet CHAR(4);


--DATOS ARCHIVO DETALLE
DEFINE vsNombre_Archivo  CHAR(20) ; 
DEFINE vdtFecha_Archivo DATE;
DEFINE vsCod_Txn CHAR(2) ; 
DEFINE vsCalificado_R_Codigo CHAR(1) ; 
DEFINE vsCodigo_Registro CHAR(1) ; 
DEFINE vsNumero_Tarjeta CHAR(16) ; 
DEFINE vsExtension_Tarjeta CHAR(3);
DEFINE vsInd_Limite_Piso CHAR(1);
DEFINE vsInd_Cwb_Crb CHAR(1);
DEFINE vsInd_Servicio CHAR(1) ; 
DEFINE vsNum_Referencia CHAR(23) ; 
DEFINE vsNum_Negocio CHAR(8) ; 
DEFINE vsFecha_Txn CHAR(4) ; 
DEFINE vsImporte_Txn CHAR(12) ; 
DEFINE vsCod_Actual_Destino CHAR(3) ; 
DEFINE vsImporte_Tasa CHAR(12) ; 
DEFINE vsCod_Actual_Origen CHAR(3) ; 
DEFINE vsNombre_Negocio CHAR(25) ; 
DEFINE vsPoblacion_Negocio CHAR(13); 
DEFINE vsCod_Pais CHAR(3) ; 
DEFINE vsCod_Categoria CHAR(4) ; 
DEFINE vsCod_Postal CHAR(5);
DEFINE vsCod_Estado CHAR(3);
DEFINE vsReservado CHAR(1) ; 
DEFINE vsInd_Com_Elec CHAR(1);
DEFINE vsCod_Uso CHAR(1) ; 
DEFINE vsCod_Razon CHAR(2) ; 
DEFINE vsInd_Liquidacion CHAR(1) ; 
DEFINE vsInd_Servicio2 CHAR(1);
DEFINE vsNum_Autorizaciones CHAR(6) ; 
DEFINE vsCap_Term_Pos CHAR(1);
DEFINE vsFiller1 CHAR(1);
DEFINE vsMet_Identificacion CHAR(1);
DEFINE vsBan_Coleccion CHAR(1);
DEFINE vsMod_Pos CHAR(2) ; 
DEFINE vsFecha_Proceso CHAR(4) ; 
DEFINE vsTipo_Captura CHAR(1) ; 

DEFINE vsCategoria_Tasa CHAR(2) ; 
DEFINE vsInd_Medio_Acceso CHAR(2) ; 
DEFINE vsTrack2 CHAR(1);
DEFINE vsInd_Cavv CHAR(1);
DEFINE vsInd_Ucaf CHAR(1); 
DEFINE vsDiferimiento CHAR(2) ; 
DEFINE vsParcializacion CHAR(2) ; 
DEFINE vsTipo_Plan CHAR(2) ; 
DEFINE vsInd_Deposito_Efectivo CHAR(1) ; 
DEFINE vsFiller CHAR(8);
DEFINE vsFolio_Suc CHAR(16) ; 
DEFINE vsConciliado CHAR(1) ; 
DEFINE vsUser_Insert CHAR(10) ; 
DEFINE vdtFecha_Insert DATE;

DEFINE visqlerr INTEGER;
DEFINE vsFolio_SucAUX2 CHAR(16) ; 
DEFINE vsAuxNum CHAR(1) ; 
DEFINE vsParam_Pagotransfer CHAR(4); 
DEFINE vsParam_PagoCheqCorresp CHAR(4);
DEFINE vsParam_PagoEfeccorresp CHAR(4);

DEFINE cDescripcionSPJ	 CHAR(100);

LET vsCodRetorno = '';
LET vsMensajeRet = '';
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

LET vdtFechaActual = CURRENT::DATE;
LET viStatus = 0;
LET vsFechaUltimoArchivo = CURRENT::DATE;
LET vsParamNomArch = '';
LET vsNombreArchivo = '';
LET vsRutaArchivo = '';


LET vsCancelado = '';
LET vsTransacc_Suc = '';
LET vsFechaJuliana = '';
LET vdtFechaAux = CURRENT::DATE;
LET vsFolioSuccAux = '';
LET viContador = 0;
LET vsBin_Adquiriente = '';
LET vsFillerE = '';
LET vsFillerS = '';
LET vsNombre_Archivo = '';
LET vdtFecha_Archivo = CURRENT::DATE;
LET viIdBanco = 0;

LET vsFlagAlternar = '';
LET viAcumulado = 0;
LET viValorAux = 0;
LET viTotalRegistros = 0;
LET viTotalPagos = 0;
LET viTotalImportePagos = 0;
LET viTotalRechazados = 0;
LET viTotalImporteRechazados = 0;

LET vsTransacc = '';
LET vsParam_TranSacc_Efectivo = '';
LET vsParam_TranSacc_Otro = '';
LET vsParam_PagoEfectivo = '';
LET vsParam_PagoCheqMBanco = '';
LET vsParam_PagoInternet = '';
LET vsParam_PagoCheqOBanco = '';



LET vsCod_Txn = '08'; --01
LET vsCalificado_R_Codigo = '0'; --02
LET vsCodigo_Registro = ''; --03 ---PENDIENTE
LET vsNumero_Tarjeta = '';  --04 ---PENDIENTE
LET vsExtension_Tarjeta = '000'; --05
LET vsInd_Limite_Piso = ' '; --06
LET vsInd_Cwb_Crb = ' '; --07
LET vsInd_Servicio = ' '; --08
LET vsNum_Referencia = ''; --09 --MODULO VERIFICADOR
LET vsNum_Negocio = ''; --10 ---SUCURSAL
LET vsFecha_Txn = ''; --11   --FECHA DE REGISTRO SUC
LET vsImporte_Txn = ''; --12 MONTO_TOT
LET vsCod_Actual_Destino = '484'; --13 -- TIPO MONEDA
LET vsImporte_Tasa = '000000000000'; --14
LET vsCod_Actual_Origen = 'MX'; --15
LET vsNombre_Negocio = 'PAGO EN BANCOPPEL'; --16
LET vsPoblacion_Negocio = '             '; --17
LET vsCod_Pais = 'MX'; --18
LET vsCod_Categoria = '6010'; --19 --TIPO GIRO
LET vsCod_Postal = '00000'; --20
LET vsCod_Estado = '   '; --21
LET vsReservado = '1'; --22
LET vsInd_Com_Elec = ' '; --23
LET vsCod_Uso = '1'; --24
LET vsCod_Razon = ''; --25 --TRANSACC_SUC
LET vsInd_Liquidacion = '0'; --26
LET vsInd_Servicio2 = ' '; --27
LET vsNum_Autorizaciones = '000000'; --28
LET vsCap_Term_Pos = ' '; --29
LET vsFiller1 = ' '; --30
LET vsMet_Identificacion = ' '; --31
LET vsBan_Coleccion = ' '; --32
LET vsMod_Pos = '01'; --33
LET vsFecha_Proceso = '0000'; --34
LET vsTipo_Captura = '0'; --35
LET vsCategoria_Tasa = '00'; --36
LET vsInd_Medio_Acceso = '00'; --37
LET vsTrack2 = ' '; --38
LET vsInd_Cavv = ' '; --39
LET vsInd_Ucaf = ' '; --40
LET vsDiferimiento = '00'; --41
LET vsParcializacion = '00'; --42
LET vsTipo_Plan = '00'; --43
LET vsInd_Deposito_Efectivo = ''; --44 ---PENDIENTE
LET vsFiller = '        '; --45

LET vsFolio_Suc = '';
LET vsConciliado = '';
LET vsUser_Insert = '';
LET vdtFecha_Insert = CURRENT::DATE;

LET vsFolio_SucAUX2 = '';
LET vsAuxNum = '';
LET visqlerr = 0;
LET vsParam_Pagotransfer = ''; 
LET vsParam_PagoCheqCorresp = '';
LET vsParam_PagoEfeccorresp = '';

LET cDescripcionSPJ	 = 'Ejecucion de pagos interbancarios';


	--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_registradatosarchivo.out";
	--TRACE ON;


BEGIN
--GEN_APITDC
--FI_GAPITDC
--0123456789

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		LET vsCodRetorno = '00199'; --ERROR DE INFORMIX
		
		--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
		SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
		
		LET vsMensajeRet = TRIM(vsMensajeRet) || ' ERROR (' || visqlerr || ').' ;
		
		--ACTUALIZA EL REGISTRO DE LA TABLA DE PROCESOS Y LO DEJA COMO NO PROCESADO
		UPDATE BdiSac:Sac_Procesos SET Status = 0, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 3;
		
		RETURN vsCodRetorno, vsMensajeRet ;
		
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	
	
	/*
	IF ( psNumEmpleado = '3' )	THEN
		--SET DEBUG FILE TO '/tmp/PITDC/CONFORMAR_ARCH_TIPDC.sql';
		SET DEBUG FILE TO '/home/sysifx/PITDC/CONFORMAR_ARCH_TIPDC.sql';
		
		TRACE ON ;
	END IF ;
	*/
	
	
	--OBTIENE LA FECHA ACTUAL DEL SISTEMA
	SELECT FIRST 1 NVL(Fecha_Hoy, CURRENT::DATE) INTO vdtFechaActual FROM BdiCheq:Sc_Fechas;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_API_TDC', vdtFechaActual, '0', 'informix', 'sp_sac_registrardatosarchivo', cDescripcionSPJ);
	
	--OBTIENE EL DIA HABIL
	EXECUTE PROCEDURE BdInteg:Sp_ValFecha_Banca ('001', vdtFechaActual, 0) INTO vsCodRetorno, vdtFechaActual;
	
	IF (TRIM(NVL(psNumEmpleado, '')) = '')THEN --VALIDA QUE EL NUMERODE EMPLEADO CONTENGA INFO
		--EL NUMERO DE EMPLEADO DEBE DE CONTENER INFORMACION
		LET vsCodRetorno = '00101';
	ELIF (NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas WHERE Fecha_Hoy::DATE = vdtFechaActual::DATE)) THEN -- VALIDA QUE EL DIA SEA UN DIA HABIL
		--DIA NO HABIL
		LET vsCodRetorno = '00102';
	ELIF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 1/*PROCESADO*/)) THEN -- SI YA SE GENERO EL ARCHIVO CORRECTAMENTE
		--PROCESO EJECUTADO PREVIAMENTE CON EXITO
		LET vsCodRetorno = '00103';
	ELIF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual AND Status = 3/*PROCESANDO*/)) THEN -- SE ESTA PROCESANDO EL ARCHIVO
		--SE ESTA PROCESANDO EL ARCHIVO
		LET vsCodRetorno = '00104';
	--ELIF (NOT EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC')) THEN -- VALIDA KE EXISTA ALMENOS UIN REGISTRO (REG BASE)
	ELIF (NOT EXISTS (SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Ultimo_Archivo < vdtFechaActual)) THEN -- VALIDA KE EXISTA ALMENOS UIN REGISTRO (REG BASE)
		--NO EXISTEN REGISTROS DEL PROCESO
		LET vsCodRetorno = '00105';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33000') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE NOMBRE DE ARCHIVO
		--NO EXISTE EL PARAMETRO DEL NOMBRE DEL ARCHIVO
		LET vsCodRetorno = '00106';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		--NO EXISTE EL PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		LET vsCodRetorno = '00107';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33002') ) THEN --VALIDA KE EXISTA EN PARAMETRO DEL BIN ADQUIRIENTE
		--NO EXISTE EL BIN ADQUIRIENTE EN LA TABLA DE PARAMETROS
		LET vsCodRetorno = '00108';
	--ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION 
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE LA TRANSACCION 
		--LET vsCodRetorno = '00109';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN EFECTIVO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN EFECTIVO
		LET vsCodRetorno = '00110';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE MISMO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE MISMO BANCO
		LET vsCodRetorno = '00111';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE OTRO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE OTRO BANCO
		LET vsCodRetorno = '00112';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN INTERNET
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN INTERNET
		LET vsCodRetorno = '00113';
		
	ELSE -- PARAMETROS OK
		
		--OBTIENE LA PARTE PARAMETRIZADA DEL NOMBRE DEL ARCHIVO
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParamNomArch FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33000';
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsRutaArchivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001';
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsBin_Adquiriente FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33002'; 
		
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfectivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqMBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqOBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoInternet FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_Pagotransfer FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33011'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqCorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33012'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfeccorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33013'; 


		--PAGO EFECTIVO
		--SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_TranSacc_Efectivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003'; 
		--PAGO OTRO MEDIO
		--SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_TranSacc_Otro FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33008'; 
		
		
		
		--SE FORMA EL NOMBRE DEL ARCHIVO
		LET vsNombreArchivo = TRIM(vsParamNomArch) || SUBSTRING (vdtFechaActual::DATE FROM 4 FOR 2) || SUBSTRING (vdtFechaActual::DATE FROM 1 FOR 2) || SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2) || '2.txt';
		
		
		IF (EXISTS (SELECT Proceso FROM BdiSac:Sac_Procesos WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE)) OR ((EXISTS (SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual))) THEN --EXISTE 
			
			--SE ACTUALIZA EL REGISTRO
			UPDATE BdiSac:Sac_Procesos SET Status = 3/*PROCESANDO*/, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 0/*NO PROCESADO*/;
			
			DELETE FROM BdiSac:Sac_EGlobal_Detalle WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_NoConcil WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Sumario WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Encabezado WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
			DELETE FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo = TRIM(vsNombreArchivo) AND Fecha_Archivo = vdtFechaActual::DATE;
		ELSE
			--NUEVO REG   --PROCESANDO
			-- 0 --> NO PROCESADO  / ERROR
			-- 1 --> PROCESADO / OK
			-- 3 --> PROCESNDO / EN CURSO
			INSERT INTO BdiSac:Sac_Procesos (Proceso, Fecha_Proceso, Status, User_Insert, Fecha_Insert) VALUES ('GEN_APITDC', vdtFechaActual::DATE, 3 /*PROCESANDO*/, TRIM(psNumEmpleado), CURRENT::DATE);
		END IF;
		
		--OBTIENE EL ULTIMO REGISTRO DE LA GENERACION DEL ARCHIVO
		SELECT MAX(Fecha_Archivo) INTO vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo <> '' AND Fecha_Archivo < vdtFechaActual AND Estatus = 1;
		--SELECT MAX(Fecha_Archivo) INTO vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo <> '' AND Fecha_Archivo < vdtFechaActual ;
		
		
		LET vsNombre_Archivo = TRIM(vsNombreArchivo); 
		LET vdtFecha_Archivo = vdtFechaActual::DATE; 
		
		
		LET vsFolio_Suc = ''; 
		LET vsConciliado = '0'; 
		LET vsUser_Insert = TRIM(psNumEmpleado); 
		LET vdtFecha_Insert = CURRENT::DATE;
		
		--LET vsFechaJuliana = SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2) || LPAD((( vdtFechaAux::DATE - vdtFechaActual::DATE) + 1), 4, '0');
		
		LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
		LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 9 FOR 2), 2, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 5, '0');
		
		LET vsFillerE = LPAD (vsFillerE, 177, ' ');
		LET vsFillerS = LPAD (vsFillerS, 146, ' ');
		
		--GUARDA REGISTRO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Archivos (Nombre_Archivo, Fecha_Archivo, Fecha_Ultimo_Archivo, Estatus, Conciliado, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, vsFechaUltimoArchivo, '0'/*Estatus*/, '0'/*Conciliado*/, vsUser_Insert, vdtFecha_Insert);
		
		--GUARDA REGISTRO DEL ENCABEZADO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Encabezado (Nombre_Archivo, Fecha_Archivo, Cod_Txn, Bin_Adquiriente, Fecha_Intercambio, Filler, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, '90'/*Cod_Txn*/, vsBin_Adquiriente, vsFechaJuliana, vsFillerE, vsUser_Insert, vdtFecha_Insert);
		
		--INCREMENTA LA FECHA EN UN DIA A LA ULTIMA GENERACION 
		LET vsFechaUltimoArchivo = vsFechaUltimoArchivo + INTERVAL(1) DAY TO DAY;
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		--OBTIENE LOS REGISTROS DE LA TABLA  MOVDIA
		FOREACH WITH HOLD
			SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia), 16, '0'), LPAD(TRIM(Transacc), 4, '0' )
			INTO vsCancelado, vsNum_Negocio, vsFolio_Suc, vsFecha_Txn, vsImporte_Txn, vsTransacc_Suc, vsNumero_Tarjeta, vsTransacc
			FROM BdiCheq:Sc_MovDia
			WHERE Empresa = '001' AND Cuenta <> ''
			AND Fech_val = vdtFechaActual::DATE
			AND Cancelad <> 'S'
			AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
			UNION ALL 
			SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia), 16, '0'), LPAD(TRIM(Transacc), 4, '0' )
			FROM BdiCheq:Sc_Movhis
			WHERE Empresa = '001' AND Cuenta <> ''
			AND Fech_val = vdtFechaActual::DATE
			AND Cancelad <> 'S'
			AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET viIdBanco = 0;
			SELECT FIRST 1 NVL(Id_Bco, 0) INTO viIdBanco FROM BdiCheq:Sc_Bines WHERE Bin = SUBSTRING (vsNumero_Tarjeta FROM 1 FOR 6);
			
			IF (NVL(viIdBanco, 0) > 0) THEN --SE ENCONTRO BIN COMPATIBLE
				
				IF (EXISTS (SELECT Cod_Reg FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco) )THEN --EXISTE EL CODICO COMPATIBLE
					SELECT FIRST 1 NVL(Cod_Reg, '3') INTO vsCodigo_Registro FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco;
				ELSE --NO ESTA REGISTRADO
					LET vsCodigo_Registro = '3'; 
				END IF;
				
			ELSE --NO SE ENCONTRO BANCO CON EL MISMO BIN
				LET vsCodigo_Registro = '3'; --03 --PENDIENTE NO SE SABE DONDEESTA CONTENIDO
			END IF;
			
			
			LET vsFechaJuliana = '';
			LET vdtFechaAux = CURRENT::DATE;
			LET vsFolioSuccAux = '';
			LET viContador = 0;
			
			
			LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
			LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 10 FOR 1), 1, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 4, '0');
			
			--//validar folio suc 
			LET viContador = 0;
			LET vsFolioSuccAux = '';
			LET vsFolio_SucAUX2 = SUBSTRING (LPAD(TRIM(vsFolio_Suc), 16, '0') FROM 9 FOR 8);
			WHILE (viContador < 8) 
				
				LET vsAuxNum = '';
				LET vsAuxNum = SUBSTRING (vsFolio_SucAUX2 FROM (1 + viContador) FOR 1);
				IF (( vsAuxNum >= '0') AND ( vsAuxNum <= '9')) THEN
					--ES NUMERICO 
					LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || vsAuxNum;
				ELSE
					--ES LETRA SE CAMBIA POR 0
					LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || '0';
				END IF;
				LET viContador = viContador +1;
			END WHILE; 
			
			
--			LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			LET vsNum_Referencia = '7' || vsBin_Adquiriente  || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			
			--MODULO 10
			LET vsFlagAlternar = '';
			LET viAcumulado = 0;
			LET viValorAux = 0;
			
			LET viContador = 0;
			LET vsFlagAlternar = 'F';
			
			
			LET viContador = LENGTH(TRIM(vsNum_Referencia));
			
			WHILE (viContador > 0 )
				
				--LET vsDetalle = '';
				
				LET viValorAux = SUBSTRING (vsNum_Referencia FROM (viContador) FOR 1);
				
				--LET vsDetalle = '['|| viValorAux || ']';
				
				IF (vsFlagAlternar = 'F') THEN 
					
					LET viValorAux = viValorAux * 2;
					
					IF (viValorAux > 9) THEN
						LET viValorAux = viValorAux - 9;
					END IF;
				
				END IF;
				
				LET viAcumulado = viAcumulado + viValorAux;
				
				--LET vsDetalle = TRIM (vsDetalle) || ' ['|| viValorAux || ']' || '  ['||  viAcumulado|| ']' ;
				
				--RETURN '0', vsDetalle WITH RESUME;
				
				IF (vsFlagAlternar = 'F') THEN
					LET vsFlagAlternar = 'V';
				ELSE
					LET vsFlagAlternar = 'F';
				END IF;
				
				LET viContador = viContador - 1;
			END WHILE;

			IF (MOD(viAcumulado, 10) > 0) THEN 
				LET viValorAux = 10 - MOD(viAcumulado, 10);
			ELSE
				LET viValorAux = 0;
			END IF;
			--MODULO 10
			
			
			--LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux) || viValorAux; --09 --MODULO VERIFICADOR
			LET vsNum_Referencia = TRIM (vsNum_Referencia) || viValorAux; --09 --MODULO VERIFICADOR
			
			
			
			
			IF (vsTransacc = vsParam_PagoEfectivo) THEN
-- 20100707-I ------> Se cambia el Cod. razon a "00" por ordenes de Eglobal:
				--     LET vsCod_Razon = '91'; --25  ---PAGO EN EFECTIVO
				LET vsCod_Razon = '00'; --25  ---PAGO EN EFECTIVO
				LET vsInd_Deposito_Efectivo = '1'; --44
			ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
				--     LET vsCod_Razon = '92'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsCod_Razon = '00'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
-- 20100707-F
			ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
				LET vsCod_Razon = '00'; --25 ---PAGO CHEQUE OTRO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoInternet) THEN
				LET vsCod_Razon = '00'; --25 --PAGO INTERNET
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_Pagotransfer) THEN -- PAGO TRANSFER
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN -- PAGO CARGO CORRESP
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN -- PAGO EFECTIVO CORRESP
				LET vsCod_Razon = '00'; 
				LET vsInd_Deposito_Efectivo = '1'; --44
			END IF;

				
			INSERT INTO BdiSac:Sac_EGlobal_Detalle 
			(Nombre_Archivo, Fecha_Archivo, Cod_Txn, Calificado_R_Codigo, Codigo_Registro, Numero_Tarjeta, Extension_Tarjeta, Ind_Limite_Piso, Ind_Cwb_Crb, Ind_Servicio,
			num_Referencia, num_Negocio, Fecha_Txn, Importe_Txn, Cod_Actual_Destino, Importe_Tasa, Cod_Actual_Origen, Nombre_Negocio, Poblacion_Negocio, Cod_Pais, Cod_Categoria, 
			Cod_Postal, Cod_Estado, Reservado, Ind_Com_Elec, Cod_Uso, Cod_Razon, Ind_Liquidacion, Ind_Servicio2, Num_Autorizaciones, Cap_Term_Pos, Filler1, Met_Identificacion, Ban_Coleccion, 
			Mod_Pos, Fecha_Proceso, Tipo_Captura, Categoria_Tasa, Ind_Medio_Acceso, Track2, Ind_Cavv, Ind_Ucaf, Diferimiento, Parcializacion, Tipo_Plan, Ind_Deposito_Efectivo, 
			Filler, Folio_Suc, Conciliado, User_Insert, Fecha_Insert)
			VALUES
			(vsNombre_Archivo, vdtFecha_Archivo, vsCod_Txn, vsCalificado_R_Codigo, vsCodigo_Registro, vsNumero_Tarjeta, vsExtension_Tarjeta, vsInd_Limite_Piso, vsInd_Cwb_Crb, vsInd_Servicio, 
			vsnum_Referencia, vsnum_Negocio, vsFecha_Txn, vsImporte_Txn, vsCod_Actual_Destino, vsImporte_Tasa, vsCod_Actual_Origen, vsNombre_Negocio, vsPoblacion_Negocio, vsCod_Pais, vsCod_Categoria, 
			vsCod_Postal, vsCod_Estado, vsReservado, vsInd_Com_Elec, vsCod_Uso, vsCod_Razon, vsInd_Liquidacion, vsInd_Servicio2, vsNum_Autorizaciones, vsCap_Term_Pos, vsFiller1, vsMet_Identificacion, vsBan_Coleccion, 
			vsMod_Pos, vsFecha_Proceso, vsTipo_Captura, vsCategoria_Tasa, vsInd_Medio_Acceso, vsTrack2, vsInd_Cavv, vsInd_Ucaf, vsDiferimiento, vsParcializacion, vsTipo_Plan, vsInd_Deposito_Efectivo, 
			vsFiller, vsFolio_Suc, vsConciliado, vsUser_Insert, vdtFecha_Insert );
			
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
		
		IF ( (vdtFechaActual::DATE - vsFechaUltimoArchivo::DATE) > 0) THEN --VALIDA SI SE TIENE KE CONSULTAR LA MOVHIS
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			--OBTIENE LOS REGISTROS DE LA TABLA  MOVHIS
			FOREACH WITH HOLD
				SELECT  Cancelad, LPAD(TRIM(Sucursal), 8, '0' ), Folio_Suc, REPLACE (SUBSTRING (Fech_val FROM 1 FOR 5), '/', '') AS FECHATXN, LPAD((NVL(Monto_Tot, 0.0) * 100)::INTEGER, 12, '0'), Transacc_Suc, LPAD(TRIM(Referencia),16,'0'), LPAD(TRIM(Transacc), 4, '0' )
				INTO vsCancelado, vsNum_Negocio, vsFolio_Suc, vsFecha_Txn, vsImporte_Txn, vsTransacc_Suc, vsNumero_Tarjeta, vsTransacc
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001' AND Cuenta <> ''
				AND Fech_val BETWEEN vsFechaUltimoArchivo::DATE AND vdtFechaActual::DATE
				AND Cancelad <> 'S'
				AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
				--AND (Transacc = vsParam_TranSacc_Efectivo OR Transacc = vsParam_TranSacc_Otro)
				
				--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (vsFlagEnTransaccion = 'F') THEN 
					 BEGIN WORK;
					 LET vsFlagEnTransaccion = 'V';
				END IF;
				
				LET viIdBanco = 0;
				SELECT FIRST 1 NVL(Id_Bco, 0) INTO viIdBanco FROM BdiCheq:Sc_Bines WHERE Bin = SUBSTRING (vsNumero_Tarjeta FROM 1 FOR 6);
				
				IF (NVL(viIdBanco, 0) > 0) THEN --SE ENCONTRO BIN COMPATIBLE
					
					IF (EXISTS (SELECT Cod_Reg FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco) )THEN --EXISTE EL CODICO COMPATIBLE
						SELECT FIRST 1 NVL(Cod_Reg, '3') INTO vsCodigo_Registro FROM BdiSac:Sac_EGlobal_Banco WHERE IdBanco = viIdBanco;
					ELSE --NO ESTA REGISTRADO
						LET vsCodigo_Registro = '3'; 
					END IF;
					
				ELSE --NO SE ENCONTRO BANCO CON EL MISMO BIN
					LET vsCodigo_Registro = '3'; --03 --PENDIENTE NO SE SABE DONDEESTA CONTENIDO
				END IF;
				
				
				LET vsFechaJuliana = '';
				LET vdtFechaAux = CURRENT::DATE;
				LET vsFolioSuccAux = '';
				LET viContador = 0;
				
				
				LET vdtFechaAux = ('01/01/' || SUBSTRING (vdtFechaActual::DATE FROM 7 FOR 4))::DATE; --FECHA JULIANA
				LET vsFechaJuliana = LPAD(LPAD(SUBSTRING (vdtFechaActual::DATE FROM 10 FOR 1), 1, '0') || LPAD((( vdtFechaActual::DATE - vdtFechaAux::DATE) + 1), 3, '0'), 4, '0');
				
				--//validar folio suc 
				LET viContador = 0;
				LET vsFolioSuccAux = '';
				LET vsFolio_SucAUX2 = SUBSTRING (LPAD(TRIM(vsFolio_Suc), 16, '0') FROM 9 FOR 8);
				WHILE (viContador < 8) 
					
					LET vsAuxNum = '';
					LET vsAuxNum = SUBSTRING (vsFolio_SucAUX2 FROM (1 + viContador) FOR 1);
					IF (( vsAuxNum >= '0') AND ( vsAuxNum <= '9')) THEN
						--ES NUMERICO 
						LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || vsAuxNum;
					ELSE
						--ES LETRA SE CAMBIA POR 0
						LET vsFolioSuccAux = TRIM(vsFolioSuccAux) || '0';
					END IF;
					LET viContador = viContador +1;
				END WHILE; 
				
				
--				LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
				LET vsNum_Referencia = '7' || vsBin_Adquiriente || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux); 
			
				
				--MODULO 10
				LET vsFlagAlternar = '';
				LET viAcumulado = 0;
				LET viValorAux = 0;
				
				LET viContador = 0;
				LET vsFlagAlternar = 'F';
				
				
				LET viContador = LENGTH(TRIM(vsNum_Referencia));
				
				WHILE (viContador > 0 )
					
					--LET vsDetalle = '';
					
					LET viValorAux = SUBSTRING (vsNum_Referencia FROM (viContador) FOR 1);
					
					--LET vsDetalle = '['|| viValorAux || ']';
					
					IF (vsFlagAlternar = 'F') THEN 
						
						LET viValorAux = viValorAux * 2;
						
						IF (viValorAux > 9) THEN
							LET viValorAux = viValorAux - 9;
						END IF;
					
					END IF;
					
					LET viAcumulado = viAcumulado + viValorAux;
					
					--LET vsDetalle = TRIM (vsDetalle) || ' ['|| viValorAux || ']' || '  ['||  viAcumulado|| ']' ;
					
					--RETURN '0', vsDetalle WITH RESUME;
					
					IF (vsFlagAlternar = 'F') THEN
						LET vsFlagAlternar = 'V';
					ELSE
						LET vsFlagAlternar = 'F';
					END IF;
					
					LET viContador = viContador - 1;
				END WHILE;

				IF (MOD(viAcumulado, 10) > 0) THEN 
					LET viValorAux = 10 - MOD(viAcumulado, 10);
				ELSE
					LET viValorAux = 0;
				END IF;
				--MODULO 10
				
				
				
				--LET vsNum_Referencia = '7' || SUBSTRING( vsNumero_Tarjeta FROM 1 FOR 6) /*BIN*/ || TRIM(vsFechaJuliana) || SUBSTRING (vsNum_Negocio FROM 6 FOR 3) || TRIM(vsFolioSuccAux) || viValorAux; --09 --MODULO VERIFICADOR
				LET vsNum_Referencia = TRIM (vsNum_Referencia) || viValorAux; --09 --MODULO VERIFICADOR
				
				
			IF (vsTransacc = vsParam_PagoEfectivo) THEN
				LET vsCod_Razon = '00'; --25  ---PAGO EN EFECTIVO
				LET vsInd_Deposito_Efectivo = '1'; --44
			ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
				LET vsCod_Razon = '00'; --25  ---PAGO CHEQUE MISMO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
				LET vsCod_Razon = '00'; --25 ---PAGO CHEQUE OTRO BANCO
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoInternet) THEN
				LET vsCod_Razon = '00'; --25 --PAGO INTERNET
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_Pagotransfer) THEN 
				LET vsCod_Razon = '00'; --PAGO TRANSFER
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN 
				LET vsCod_Razon = '00'; --PAGO CARGO CORRESP
				LET vsInd_Deposito_Efectivo = '0'; --44
			ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN 
				LET vsCod_Razon = '00'; --PAGO EFEC CORRESP
				LET vsInd_Deposito_Efectivo = '1'; --44
			END IF;
				
				
				
				--INCERTA EN LA TABLA DE DETALLE
				INSERT INTO BdiSac:Sac_EGlobal_Detalle 
				(Nombre_Archivo, Fecha_Archivo, Cod_Txn, Calificado_R_Codigo, Codigo_Registro, Numero_Tarjeta, Extension_Tarjeta, Ind_Limite_Piso, Ind_Cwb_Crb, Ind_Servicio,
				num_Referencia, num_Negocio, Fecha_Txn, Importe_Txn, Cod_Actual_Destino, Importe_Tasa, Cod_Actual_Origen, Nombre_Negocio, Poblacion_Negocio, Cod_Pais, Cod_Categoria, 
				Cod_Postal, Cod_Estado, Reservado, Ind_Com_Elec, Cod_Uso, Cod_Razon, Ind_Liquidacion, Ind_Servicio2, Num_Autorizaciones, Cap_Term_Pos, Filler1, Met_Identificacion, Ban_Coleccion, 
				Mod_Pos, Fecha_Proceso, Tipo_Captura, Categoria_Tasa, Ind_Medio_Acceso, Track2, Ind_Cavv, Ind_Ucaf, Diferimiento, Parcializacion, Tipo_Plan, Ind_Deposito_Efectivo, 
				Filler, Folio_Suc, Conciliado, User_Insert, Fecha_Insert)
				VALUES
				(vsNombre_Archivo, vdtFecha_Archivo, vsCod_Txn, vsCalificado_R_Codigo, vsCodigo_Registro, vsNumero_Tarjeta, vsExtension_Tarjeta, vsInd_Limite_Piso, vsInd_Cwb_Crb, vsInd_Servicio, 
				vsnum_Referencia, vsnum_Negocio, vsFecha_Txn, vsImporte_Txn, vsCod_Actual_Destino, vsImporte_Tasa, vsCod_Actual_Origen, vsNombre_Negocio, vsPoblacion_Negocio, vsCod_Pais, vsCod_Categoria, 
				vsCod_Postal, vsCod_Estado, vsReservado, vsInd_Com_Elec, vsCod_Uso, vsCod_Razon, vsInd_Liquidacion, vsInd_Servicio2, vsNum_Autorizaciones, vsCap_Term_Pos, vsFiller1, vsMet_Identificacion, vsBan_Coleccion, 
				vsMod_Pos, vsFecha_Proceso, vsTipo_Captura, vsCategoria_Tasa, vsInd_Medio_Acceso, vsTrack2, vsInd_Cavv, vsInd_Ucaf, vsDiferimiento, vsParcializacion, vsTipo_Plan, vsInd_Deposito_Efectivo, 
				vsFiller, vsFolio_Suc, vsConciliado, vsUser_Insert, vdtFecha_Insert );
				
				LET viContadorRegistros = viContadorRegistros + 1;
				
				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccion = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				END IF;
				
			END FOREACH;
			
			-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
			END IF;
			
		END IF;
		
		LET viTotalRegistros = 0;
		LET viTotalPagos = 0;
		LET viTotalImportePagos = 0;
		LET viTotalRechazados = 0;
		LET viTotalImporteRechazados = 0;
		
		--TOTALES
		SELECT COUNT (Nombre_Archivo) INTO viTotalRegistros
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo;
		
		--TOTALES PAGOS
		SELECT SUM(DECODE(Cod_Txn, '08', 1, 0)), SUM(NVL(Importe_Txn, '0')::INTEGER) INTO viTotalPagos, viTotalImportePagos 
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo AND Cod_Txn = '08';
		
		--TOTALES RECHAZADOS
		SELECT SUM(DECODE(Cod_Txn, '08', 0, 1)), SUM(NVL(Importe_Txn, '0')::INTEGER) INTO viTotalRechazados, viTotalImporteRechazados 
		FROM BdiSac:Sac_EGlobal_Detalle 
		WHERE Nombre_Archivo = vsNombre_Archivo AND Fecha_Archivo = vdtFecha_Archivo AND Cod_Txn <> '08';
		
		
		--GUARDA REGISTRO DEL SUMARIO DEL ARCHIVO
		INSERT INTO BdiSac:Sac_EGlobal_Sumario (Nombre_Archivo, Fecha_Archivo, Cod_Txn, Total_Registros, Total_Pagos, Importe_Pagos, Total_Rechazos, Importe_Rechazos, Filler, User_Insert, Fecha_Insert) 
		VALUES (vsNombre_Archivo, vdtFecha_Archivo, '92'/*Cod_Txn*/, LPAD(NVL(viTotalRegistros, 0), 6, '0'), LPAD(NVL(viTotalPagos, 0), 6, '0'), LPAD(NVL(viTotalImportePagos, 0), 12, '0'), LPAD(NVL(viTotalRechazados, 0), 6, '0'), LPAD(NVL(viTotalImporteRechazados, 0), 12, '0') , vsFillerS, vsUser_Insert, vdtFecha_Insert);
		
		--GENERAR ARCHIVO.
		EXECUTE PROCEDURE BdiSac:sp_Sac_GeneraArchivoPTC (psNumEmpleado, vsNombre_Archivo) INTO vsCodRetorno, vsMensajeRet;
		
		IF (vsCodRetorno = '00000') THEN 
			--ACTUALIZA EL REGISTRO DE PROCESO A TERMINADO CORRECTAMENTE
			UPDATE BdiSac:Sac_Procesos SET Status = 1, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 3;
			--ACTUALIZA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_API_TDC', vdtFechaActual, '1', 'informix', 'sp_sac_registrardatosarchivo', cDescripcionSPJ);
			LET vsCodRetorno = '00000'; -- OK

-- Se actualiza estatus del archivo a 1, si termino correctamente la generaciÃ³n del mismo. JGP.
          		UPDATE bdisac:sac_eglobal_archivos SET estatus = '1' 
          			WHERE estatus = '0' 
                			and Nombre_Archivo = vsNombre_Archivo       
                			and fecha_archivo = vdtFecha_Archivo::DATE;


--                    Se le agrega la condicion para que cambie a status '2' todos los registros de fechas anteriores que no tengan status de enviados ('0')
--                    para que no puedan cambiar el status a enviado en un dia posterior:

            		UPDATE bdisac:sac_eglobal_archivos SET estatus = '2' 
            			WHERE 
                			estatus = '0' 
                			and Nombre_Archivo <> vsNombre_Archivo       
                			and fecha_archivo BETWEEN vsFechaUltimoArchivo::DATE AND vdtFechaActual::DATE;
                			


		ELSE --ERROR AL GENERAR EL ARCHIVO
			--ACTUALIZA EL REGISTRO DE PROCESO A SIN PROCESAR 7 ERROR -- REPROCESAR
			UPDATE BdiSac:Sac_Procesos SET Status = 0, User_Insert = TRIM(psNumEmpleado), Fecha_Insert = CURRENT::DATE WHERE Proceso = 'GEN_APITDC' AND Fecha_Proceso = vdtFechaActual::DATE AND Status = 3;				
		END IF;
		
	END IF;
	
	
	--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
	SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
	
	
	RETURN vsCodRetorno, vsMensajeRet ;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Concentra las transacciones de paga de PITDC en una tabla con la finalidad de generar el archivo que se envia a EGlobal.',
'Fecha: 2010/03/19',
'Version: 20100319.0953',
'BD: BdiSac',
'',
'Modifico: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el formato de la fecha juliana para el encabezado del archivo de formato ADDD por AADDD.',
'Fecha: 2010/04/07',
'Version: 20100407.1155',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el uso de los parametros de las transacciones de PITDC para que se identifiquen los 4 tipos de transacciones identificadas.',
'Fecha: 2010/04/29',
'Version: 20100429.0947',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el manejo de la variable de numero de tarjeta para que en el caso de contener menos de 16 numero agrege 0 a la izq. del numero de la tarjeta.',
'Fecha: 2010/05/10',
'Version: 20100510.0902',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: ',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica el calculo del digito verificador modulo 10 para que en lugar de utilizar el numero de la tarjeta para el calculo utilice el numero de la referencia de la transaccion.',
'Fecha: 2010/07/05',
'Version: 20100705.1455',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_consultacomplementodatos_web(cNumCteContratante CHAR(20))
RETURNING
CHAR(5)	    AS  cCodRet

--Variables de retorno
DEFINE cCodRet			 CHAR(5);
DEFINE cNumcte           CHAR(20);
DEFINE iExisContr        INTEGER;

--Variables internas
DEFINE iSqlErr       INTEGER; 
DEFINE iIsamErr    	 INTEGER; 
DEFINE cInfoErr 	 CHAR(10); 

--Asignacion de valores default
LET cCodRet			  = "00000";
LET cNumcte           = "";
LET iExisContr = 0;

--SET DEBUG FILE TO "/tmp/JesusR/577/sp_consultacomplementodatos.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF (TRIM(cNumCteContratante) = "") THEN
		LET cCodRet= "00001";
		RETURN cCodRet;
	ELSE
	
		SELECT LIMIT 1 1
		INTO iExisContr
		FROM bdisac:"informix".sac_cardif_migrante 
		WHERE (TRIM(sexo) = '' OR TRIM(ciudad) = '' OR TRIM(nacionalidad) = '' OR TRIM(sexo) IS NULL OR TRIM(ciudad) IS NULL OR TRIM(nacionalidad) IS NULL)
		AND numcte = TRIM(cNumCteContratante)
		AND estatus IN(1,2);
				
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "00000";
		ELSE
			LET cCodRet = "00003";
		END IF;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
"Folio: ",
"Autor: 97877352 - Jesus Alberto Rubio",
"Fecha: 21/05/2019",
"Descripcion: Consulta la Informacion del cliente Migrante CARDIF.",
"Solicita: Leonardo Hernandez",
"BD: bdisac";

CREATE PROCEDURE "informix".sp_guardaresptelmex(idConsulta CHAR(20), idPago CHAR(20), numTel CHAR(10), usuario CHAR(8), sucursal CHAR(4), fecha CHAR(8), hora CHAR(6), folioSuc CHAR(16), formaPago CHAR(1), importe CHAR(18), numTc CHAR(20), gen1 CHAR(20), gen2 CHAR(20), gen3 CHAR(20))

RETURNING CHAR (5) AS cCodRet, CHAR (50) AS vMensaje;
   
	DEFINE cCodRet		CHAR (5);
	DEFINE vMensaje		CHAR (50);
	DEFINE iSqlErr		INTEGER;
	DEFINE iIsamError	INTEGER;
	DEFINE cCod_retorno	CHAR(5);
	
	LET cCodRet		= '00000';
	LET iSqlErr		= 0;
	LET iIsamError	= 0;
	LET vMensaje	='PROCESO EXITOSO';
	LET cCod_retorno = '';
	
   
   BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensaje ='ERROR ' || cCodRet || ', al grabar el registro ';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
			INTO cCod_retorno;

			RETURN cCodRet, 'ERROR AL GRABAR REGISTRO';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/noe/sp_guardaresptelmex.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	if idPago::integer <= 0 then
		LET cCodRet = 01010;
		LET vMensaje ='ERROR ' || cCodRet || ', idPago Invalido (' || idPago || ')';

		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
		INTO cCod_retorno;

		RETURN cCodRet, vMensaje;
	end if;


	INSERT INTO "informix".sac_pagos_telmex(idconsulta, idpago, numtel, usuario, sucursal, fecha, hora, foliosuc, formapago, importe, numtc, gen1, gen2, gen3, fecha_insert) 
    VALUES(idConsulta, idPago, numTel, usuario, sucursal, fecha, hora, folioSuc, formaPago, importe, numTc, gen1, gen2, gen3, CURRENT);
			
	  
	RETURN cCodRet, vMensaje;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 93440138 - Noe Medina R.',
'DESCRIPCION: Graba la respuesta de Pagos Telmex (BUS)',
'FOLIO: ',
'FECHA : 19-08-2021',
'VERSION: 20210819.1252',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_paymentrejection(pCompanyCode CHAR (3),
													pChannelId CHAR (3),
													pTokenId CHAR (80),
													pLanguage CHAR (5),
													pApiVersion CHAR (6),
													pClientSoftwareVersion CHAR (6),
													pUniqueReferenceNumber CHAR (16),
													pReferenceNumber CHAR (30),
													pProcessReasonTypeCode CHAR (4),
													pCodeRequest CHAR (3),
													pChannelIdRequest CHAR (3),
													pTaxIdentificationNumber CHAR (20),
													pLocationUnit CHAR (15),
													pNumberRequest CHAR (15),
													pTypeCode CHAR (3),
													pCountryCode CHAR (3),
													pStateCode CHAR (3),
													pUserId CHAR (20),
													pSupervisorId CHAR (20),
													pTerminalId CHAR (15),
													pProcessDateRequest CHAR (8),
													pProcessTimeRequest CHAR (6),
													pCode CHAR (4),
													pMessageResponse CHAR (255),
													pCodeDetail CHAR (4),
													pMessageDetail CHAR (255),
													pProcessDateResponse CHAR (8),
													pProcessTimeResponse CHAR (6),
													puniquereferencenumberrequest CHAR (16),
													pGlobalTrackingNumber CHAR (20),
													pOrderStatusCode CHAR (3),
													pOrderStatusDate CHAR (8),
													pOrderStatusTime CHAR (6))
												   
--DATOS A REGRESAR---
RETURNING CHAR(5)  AS cCodRetorno,
		  CHAR(80) AS cDesc_Error,
		  CHAR(16) As cRemesa,
		  CHAR(1)  AS cFlg_confirm_ctral,
		  CHAR(8)  AS cfecha_proceso,
		  CHAR(6)  AS cHora_proceso;

--DEFINICION DE VARIABLES--
DEFINE cCodRetorno 		  CHAR(5);
DEFINE cDesc_Error		  CHAR(80);
DEFINE cRemesa 			  CHAR(16);
DEFINE cFlg_confirm_ctral CHAR(1);
DEFINE cfecha_proceso     CHAR(8);
DEFINE cHora_proceso 	  CHAR(6);	
DEFINE cCnxn_status  		CHAR(1);
DEFINE cValor 				CHAR(200);
DEFINE iSqlErr 				INTEGER;
DEFINE cValCode 			CHAR(100);
DEFINE cValChannell			CHAR(100);
DEFINE cTermi 				CHAR(100);
DEFINE cValUsu 				CHAR(100);
DEFINE cVaLTer 				CHAR(200);
DEFINE cValocUni 			CHAR(100);
DEFINE cValTypCode 			CHAR(100);
DEFINE cValCouCode 			CHAR(100);
DEFINE cIdentNum 			CHAR(100);
define cStateCode 			CHAR(100);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cCadena_ent          CHAR(100);
DEFINE iFlg_insertaerrorws	INTEGER;
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cCodRet2             CHAR(5);
DEFINE cDescError			CHAR(80);
define iIsamErr 			INTEGER;
DEFINE cFechaInsert    		CHAR(8);
DEFINE iCod_param     		INTEGER;



--INICIALIZACION DE VARIABLES--		
LET cCodRetorno = '00000';	
LET cDesc_Error = '';
LET cRemesa  = '';			 
LET cfecha_proceso = '';
LET cHora_proceso = '';	 
LET cCnxn_status = 'C';
LET cValor = '';
LET iSqlErr = 0;
LET cValCode = '';
LET cValChannell ='';
LET cTermi = '';
LET cValUsu= '';
LET cVaLTer='';
LET cValocUni  = '';
LET cValTypCode ='';
LET cValCouCode  ='';
LET cIdentNum ='';
let cStateCode = '';
let cNombreSPL = 'sp_app_paymentRejection';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	iFlg_insertaerrorws	 = 1;
LET	cFlg_confirm_ctral	 = '0';
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCodRet2	 		 = '00000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET iIsamErr			 = 0;
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET iCod_param  = 0;


   --SET DEBUG FILE TO '/informix/EPG/sp_app_paymentRejection.out';
   --TRACE ON;

BEGIN
--Erro informix
    ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment (cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
			VALUES(NVL(cCnxn_status,'C') ,'',pCompanyCode,pChannelId,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,pTaxIdentificationNumber,pLocationUnit,pNumberRequest,pTypeCode,pCountryCode,pStateCode,pUserId,'',pTerminalId,pProcessDateRequest,pProcessTimeRequest,pCode,pMessageResponse,pCodeDetail,pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,
			pOrderStatusDate,pOrderStatusTime,'',CURRENT);
			
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
			
			RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;
    END EXCEPTION;		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','', TRIM(pUserId), current::date, cHoraInsert);	
	
	IF TRIM(pUniqueReferenceNumber) = '' OR  TRIM(pReferenceNumber) = ''THEN
		LET cCodRetorno = '1100';		
	END IF;

	IF TRIM(pCompanyCode) = ''  THEN 
		
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pChannelId) = '' THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pCode) = '' THEN
		LET cCodRetorno = '9999';
	END IF;
	
	
	IF cCodRetorno::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
		
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87102,87103,87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87102 THEN
				LET cValCode = TRIM(cValor);
			ELIF iCod_param=87103 THEN
				LET cValChannell = TRIM(cValor);
			ELIF iCod_param= 87104 THEN
				LET cValocUni = TRIM(cValor);
			ELIF iCod_param= 87105 THEN
				LET cValTypCode = TRIM(cValor);
			ELIF iCod_param= 87106 THEN
				LET cValCouCode = TRIM(cValor);
			ELIF iCod_param= 87112 THEN
				LET cTermi= TRIM(cValor);
			ELIF iCod_param= 87113 THEN
				LET cIdentNum= TRIM(cValor);
			ELIF iCod_param= 87114 THEN
				LET cStateCode= TRIM(cValor);
				END IF
		END FOREACH

		
		LET cVaLTer = TRIM(cTermi) || TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '06'
		WHERE estatus_getorder in ('04', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF;
	END IF;
	
	IF cCodRetorno::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRetorno;


		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
				
		INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
		VALUES(cCnxn_status,'PMCO',pCompanyCode,cValChannell,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,		
		 pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,cIdentNum,cValocUni,pNumberRequest,cValTypCode,cValCouCode,cStateCode,cValUsu,pSupervisorId,cVaLTer,pProcessDateRequest,pProcessTimeRequest,cValCode,pMessageResponse,pCodeDetail,	pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,cValUsu,CURRENT);
		
		 
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
		INTO cCodRet2;

		RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;

END;
END PROCEDURE
DOCUMENT
'FOLIO: 230142-150, "RQM 10 809  Pago de Remesas Appriza con abono automático en cuentas de captación ',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 15/11/2016',
'DESCRIPCION: Se crear stored procedure para guardar registros en la tabla sac_app_confirmpayment ',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_app_confirmpayment(  pCompanyCode				 CHAR (3),	
													pChannelId                   CHAR (3),
													pTokenId                     CHAR (80),
													pLanguage                    CHAR (5),
													pApiVersion                  CHAR (6),
													pClientSoftwareVersion       CHAR (6),
													pUniqueReferenceNumber       CHAR (16),
													pReferenceNumber             CHAR (30),
													pCodeRequest                 CHAR (3),
													pChannelIdRequest            CHAR (3),
													pTaxIdentificationNumber     CHAR (20),
													pLocationUnit                CHAR (15),
													pNumberRequest               CHAR (15),
													pTypeCode                    CHAR (3),
													pCountryCode                 CHAR (3),
													pStateCode                   CHAR (3),
													pUserId                      CHAR (20),
													pSupervisorId                CHAR (20),
													pTerminalId                  CHAR (15),
													pProcessDateRequest          CHAR (8),
													pProcessTimeRequest          CHAR (6),
													pCode                        CHAR (4),
													pMessageResponse             CHAR (255),
													pCodeDetail                  CHAR (4),
													pMessageDetail               CHAR (255),
													pProcessDateResponse         CHAR (8),
													pProcessTimeResponse         CHAR (6),
													pUniqueReferenceNumberReques CHAR (16),
													pGlobalTrackingNumber        CHAR (20),
													pOrderStatusCode             CHAR (3),
													pOrderStatusDate             CHAR (8),
													pOrderStatusTime             CHAR (6)
													)

RETURNING CHAR(5)  AS CodRetorno,
		  CHAR(80) AS Desc_Error,
		  CHAR(16) As Remesa,
		  CHAR(1)  AS Flg_confirm_ctral,
		  CHAR(8)  AS fecha_proceso,
		  CHAR(6)  AS Hora_proceso;

--SE DECLARAN VARIABLES.
DEFINE iSqlErr 				INTEGER;
DEFINE iIsamErr 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCodRet2             CHAR(5);
DEFINE cOpCode				CHAR(4);
DEFINE cDescError			CHAR(80);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cFechaInsert    		CHAR(8);
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cValor       		CHAR(100);
DEFINE iCod_param     		INTEGER;
DEFINE cCadena_ent          CHAR(100);
DEFINE cCnxn_status			CHAR(1);
DEFINE cFlg_confirm_ctral	CHAR(1);
DEFINE iFlg_insertaerrorws	INTEGER;

--SET DEBUG FILE TO "/informix/EPG/sp_app_confirmpayment.out";
--TRACE ON; 
--Inicializacion de Variables
LET iSqlErr 			 = 0;
LET iIsamErr			 = 0;
LET cCodRet		 		 = '00000';
LET cCodRet2	 		 = '00000';
LET cOpCode				 = '0000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET cNombreSPL   		 = 'sp_app_confirmpayment';
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cValor       		 = '';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	cCnxn_status		 = 'C';
LET	cFlg_confirm_ctral	 = '0';
LET	iFlg_insertaerrorws	 = 1;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	

BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
			VALUES(NVL(cCnxn_status,'C'),'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
			
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
	
		RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
	END EXCEPTION;
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert) 
	--VALUES (cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','',TRIM(pUserId),current::date,cHoraInsert);
	
	IF TRIM(NVL(pUniqueReferenceNumber,'')) = '' OR TRIM(NVL(pReferenceNumber,''))='' THEN
		LET cCodRet = '1100';
		
	END IF
	IF TRIM(NVL(pCompanyCode,'')) = '' THEN
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF
	IF TRIM(NVL(pChannelId,''))=''THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF

	IF TRIM(NVL(pCode,''))=''THEN
		LET cCodRet = '9999';
	END IF
	
	IF cCodRet::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87104 THEN
				LET pLocationUnit = TRIM(cValor);
			ELIF iCod_param=87105 THEN
				LET pTypeCode = TRIM(cValor);
			ELIF iCod_param=87106 THEN
				LET pCountryCode = TRIM(cValor);
			ELIF iCod_param=87112 THEN
				LET pNumberRequest = TRIM(cValor);
			ELIF iCod_param=87113 THEN
				LET pTaxIdentificationNumber = TRIM(cValor);
			ELIF iCod_param=87114 THEN
				LET pStateCode = TRIM(cValor);
			END IF
		END FOREACH
	
		LET pTerminalId = TRIM(pNumberRequest)||TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';	
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '05'
		WHERE estatus_getorder in ('03', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF;
	ELSE 
		LET cCodRet = '1100';
	END IF;
		
	IF cCodRet::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRet;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
	
	INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
	VALUES(cCnxn_status,'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));

	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
	--INTO cCodRet2;

	RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
END
END PROCEDURE
DOCUMENT
'AUTOR: 95358919 - MARIO GAMALIEL OLIVO URIAS',
'CENTRO: 230142',
'FOLIO: 150',
'RQM: RQM 10 809 Â? Pago de Remesas Appriza con abono automÃ¡tico en cuentas de captaciÃ³n.doc',
'FECHA: 05/NOVIEMBRE/2016',
'SOLICITA: EDUARDO PINEDA',
'VERSION: 20161105.0936',
'DESCRIPCION: CONFIRMA TODAS LAS REMESAS QUE FUERON ABONADAS A LAS CUENTAS CORRECTAMENTE.',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_app_getorderstoreprocess (pcUsuario CHAR(15),
	pRegs_recup INTEGER,
	pFecha_peticion CHAR(8),
	pHora_peticion CHAR(6))

--Datos a regresar
RETURNING 	CHAR(12) AS numremesa,
            CHAR(5) AS channelId,
            CHAR(8) AS fec_proceso,
            CHAR(6) AS hora_proceso,
            CHAR (5) AS codret;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_getorderstoreprocess';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET pcUsuario  =  pcUsuario;
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio, channelid
				INTO cRemesa,cCodigo,iIntentosenvio,cChannelId
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '13')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				--AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '14' WHERE UniqueReferenceNumber = cRemesa 
				and estatus_getorder = '13'
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,lpad(cCod_err,5,'0');
		END IF
	END
END PROCEDURE;