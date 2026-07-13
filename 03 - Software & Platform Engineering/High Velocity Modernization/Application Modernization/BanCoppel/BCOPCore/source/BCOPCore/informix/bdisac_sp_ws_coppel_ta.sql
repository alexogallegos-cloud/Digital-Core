CREATE PROCEDURE "informix".sp_ws_coppel_ta(
											pcAgent_trans_type_code VARCHAR(10),
											pcAgent_cd VARCHAR(6),
											pcUsuario VARCHAR(8),
											pcPassword VARCHAR(8),
											pcIp_origen VARCHAR(15),
											pcSession_id VARCHAR(30),										  
											pDateProcess VARCHAR(8),
											pTimeProcess VARCHAR(8),
											pFechaTran VARCHAR(10),
											pFolio VARCHAR(20),
											pTelefono VARCHAR(10),
											pCompania VARCHAR(15))	
RETURNING
	CHAR(5)	as cCod_retorno,
	CHAR(4)  as  cod_ret,
	char(100) as  mensaje,
	CHAR(10) as cFecha_proceso,
	CHAR(6)   as  cHora_proceso,
	CHAR(20) as	vRecargaSerial,
	CHAR(12) as	vNumCelular,
	CHAR(15) as	vcompania,
	CHAR(10) as vmonto,
	CHAR(10) as cFecha_Recarga,
	CHAR(5) as	vSucursal,
	CHAR(1) as	vcobrado,
	CHAR(80) as	vEstatus;
			
--variables de retorno
	
	DEFINE cod_ret			CHAR(8);
	DEFINE mensaje			CHAR(120);
	DEFINE cod_ret2   		CHAR(8);
	DEFINE cOpcode 			CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(80);
	DEFINE cNombre_proceso	CHAR(17);
	DEFINE cCadena_ent		CHAR(100);
	DEFINE cCod_retorno		CHAR(5);
	DEFINE cFecha_proceso 	CHAR(10);
	DEFINE cCancelado 		CHAR(10);
	DEFINE cHora_proceso 	CHAR(6);
	DEFINE cFecha_Recarga	CHAR(10);
	DEFINE vRecargaSerial 	CHAR(20);
	DEFINE vNumCelular 		CHAR(12);
	DEFINE vcompania 		CHAR(15);
	DEFINE vmonto 			CHAR(10);
	DEFINE vSucursal 		CHAR(5);
	DEFINE vcobrado 		CHAR(1);
	DEFINE vEstatus 		CHAR(80);
	DEFINE vInsStmt			LVARCHAR(2000);
	DEFINE dFechaRecarga	DATE;
	--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER;
	DEFINE iIsamError 		INTEGER;
	--variables del proceso
	DEFINE	vdiv 			INTEGER;
	DEFINE cTablaBusq		VARCHAR(30);
	DEFINE cIndice			VARCHAR(30);
	DEFINE cFechaQry		VARCHAR(50);
	DEFINE cFolioQry		VARCHAR(50);
	DEFINE cTelefonoQry		VARCHAR(50);
	DEFINE cCompaniaQry		VARCHAR(50);	
	DEFINE cCondiciones		VARCHAR(200);
	DEFINE sRegistros		SMALLINT;
	
	---INICIALIZAR DE VARIABLES
	   
	LET cod_ret = '0000';
	LET mensaje = 'Consulta Exitosa';
	LET cod_ret2 = '0000';
	LET cOpcode = '0000';
	LET cDescr_completa_mensaje = 'Consulta Exitosa.';
	LET cNombre_proceso='sp_ws_coppel_TA';
	LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
	LET cCod_retorno  = '00000';
	LET cFecha_proceso = LPAD(MONTH(CURRENT),2,'0') || '/' || LPAD(DAY(CURRENT),2,'0') || '/' || YEAR(CURRENT);
	LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET iIsamError = 0;
	LET cCancelado = '';
	LET cFecha_Recarga = '';
	LET vRecargaSerial = '0';
	LET vNumCelular = '0';
	LET vcompania = '0';
	LET vmonto = '0';
	LET vSucursal = '0';
	LET vcobrado = '0';
	LET vEstatus = '0';
	LET vInsStmt = '';
	LET dFechaRecarga = DATE(0);
	LET cTablaBusq = '';
	LET cIndice = '';
	LET cCondiciones = '';
	
	LET cFechaQry = '';
	LET cFolioQry = '';
	LET cTelefonoQry = '';
	LET cCompaniaQry = '';
	LET sRegistros = 0;
	
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_coppel_ta.out';
	--TRACE ON;	
	   
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
		
			IF iSqlErr = '-1213' THEN
			
				LET cod_ret = '0001';
				LET cOpcode = cod_ret;
		
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cod_ret;
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, LPAD(cod_ret,5,'0'), mensaje, '', '', cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
				INTO cCod_retorno;
				
				IF cOpcode IS NULL THEN
					LET cOpcode = cod_ret;
					LET mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
				
			 ELSE

				LET cod_ret = iSqlErr;
				LET cOpcode = cod_ret;

				LET mensaje = '';
				LET cDescr_completa_mensaje = '';
				
				--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cod_ret, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
				INTO cCod_retorno;
				
		    END IF;	
			
			
			INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
			VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pDateProcess,pTimeProcess,pFechaTran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current); 
			
			RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
		
			--RETURN LPAD(cCod_retorno,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso
			
		END IF;
	END EXCEPTION;


	--------VALIDACION DE PARAMETROS-------------------------
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  NVL(pcAgent_cd,'')= '' OR NVL(pcUsuario,'')= '' OR NVL(pcAgent_trans_type_code,'')= ''
		OR NVL(pcPassword,'')= ''	OR NVL(pDateProcess,'')= '' OR NVL(pTimeProcess,'')= '' 
		OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')='' 
		OR (NVL(pFechaTran,'')='' AND NVL(pFolio,'')='' AND NVL(pCompania,'')='' AND NVL(pTelefono,'')='')THEN
		
		LET cod_ret ='9996';
	ELSE
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id) 
		INTO cod_ret, mensaje;
		IF cod_ret = '0000' THEN 
			
			IF pFechaTran <> '' THEN 
				LET pFechaTran = LPAD(pFechaTran,10,'0');
				LET pFechaTran = substr(pFechaTran,4,2)||"/"||substr(pFechaTran,0,2)||"/"||substr(pFechaTran,7,4);
			END IF;
			
			DROP TABLE IF EXISTS tmp_movtos_ws_ta;
			
			IF pFechaTran = cFecha_proceso Or pFechaTran = '' THEN
				LET cTablaBusq = 'sac_movimientos';
				LET cIndice	= 'idx_sac_movimientos7';
				
				LET cFechaQry = " AND mov.fecha_pago = TODAY";
			ELSE
				LET cTablaBusq = 'sac_movimientoshistorial';
				LET cIndice	= 'idxsac_movhisfe';
				LET cFechaQry = " AND mov.fecha_pago = '"||pFechaTran||"'";
			END IF;	
			
			LET cFecha_proceso = LPAD(DAY(CURRENT),2,'0') || '/' || LPAD(MONTH(CURRENT),2,'0') || '/' || YEAR(CURRENT);

			IF pFolio <> '' THEN LET cFolioQry = " AND mov.folio_suc = '"||pFolio||"'";	END IF;
			IF pTelefono <> '' THEN LET cTelefonoQry = " AND mov.referencia1 = '"||pTelefono||"'"; END IF;
			IF pCompania <> '' THEN	LET cCompaniaQry = " AND mov.referencia2 = '"||pCompania||"'"; END IF;
			LET cCondiciones = cFechaQry||cFolioQry||cTelefonoQry||cCompaniaQry;
				
			LET vInsStmt = "SELECT {+INDEX("||cTablaBusq||","||cIndice||")+INDEX(sac_pagostae, idx01_folio_suc} FIRST 5 mov.folio_suc as folio_suc,mov.referencia1 as referencia1,mov.referencia2 as referencia2,mov.importe_pago as importe_pago,mov.fecha_insert as fecha_insert,mov.id_sucursal as id_sucursal, pag.conceptorespuesta as conceptorespuesta, mov.status_cancelado "||
			"FROM "||cTablaBusq||" AS mov INNER JOIN sac_pagostae AS pag ON mov.folio_suc = pag.folio_suc "||
			"WHERE mov.numcategoria = '03' "|| 
			"AND mov.numconvenio = '001' "||
			cCondiciones||
			" INTO TEMP tmp_movtos_ws_ta WITH NO LOG";
			
			EXECUTE IMMEDIATE vInsStmt;
			
			FOREACH WITH HOLD
				SELECT folio_suc,referencia1,referencia2,importe_pago,fecha_insert,id_sucursal, conceptorespuesta, status_cancelado
				INTO vRecargaSerial, vNumCelular,vcompania,vmonto,dFechaRecarga,vSucursal,vEstatus,cCancelado
				FROM tmp_movtos_ws_ta
				
				LET sRegistros = sRegistros+1;
				
				IF dFechaRecarga IS NOT NULL AND dFechaRecarga <> '' THEN 
					LET dFechaRecarga = trim(YEAR(dFechaRecarga) || LPAD(MONTH(dFechaRecarga),2,'0') || LPAD(DAY(dFechaRecarga),2,'0'));
				END IF;
				
				IF NVL(cCancelado,'') = 'N' THEN
					LET vcobrado= '1'; 
				END IF;	
			
				LET cFecha_Recarga =  LPAD(DAY(dFechaRecarga),2,'0')||"/"|| LPAD(MONTH(dFechaRecarga),2,'0') ||"/"||YEAR(dFechaRecarga);
				IF NVL(cCancelado,'') = 'N' THEN LET vcobrado= '1'; END IF;
				
				

				
				RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0') WITH RESUME;
			
			END FOREACH; 
			
			IF sRegistros < 1 THEN
				LET vRecargaSerial='0';
				LET vNumCelular='0';
			END IF;
		END IF;				
	END IF;

	IF cod_ret <> '0000' OR sRegistros < 1 THEN			
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cod_ret;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cod_ret;
			LET mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;

		IF NVL(vRecargaSerial,'0') = '0' and NVL(vNumCelular,'0') = '0'  then
			LET cOpcode = '7777';
			LET mensaje = 'Folio no encontrado con los parametros proporcionados.';
			LET	cDescr_completa_mensaje = 'Folio no encontrado con los parametros proporcionados.';
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cod_ret, mensaje, '', '', cCadena_ent, pcUsuario,pDateProcess,pTimeProcess)
		INTO cCod_retorno;

		INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pDateProcess,pTimeProcess,pFechaTran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current);

		RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
	
	END IF;		
END
END PROCEDURE;