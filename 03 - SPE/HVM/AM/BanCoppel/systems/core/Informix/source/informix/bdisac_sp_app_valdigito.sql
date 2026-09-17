CREATE PROCEDURE "informix".sp_app_valdigito(pNum CHAR (12))

    RETURNING
    CHAR(6) AS codret;

	DEFINE iSql_err		         INTEGER; 
	DEFINE cCodret		         CHAR(6);
    DEFINE cNumTransaccion       CHAR(11);
	DEFINE i                     INTEGER;
	DEFINE iValor1               INTEGER;
	DEFINE iValor3               INTEGER;
	DEFINE iValor4               INTEGER;
	DEFINE iValorF               INTEGER;
	DEFINE iValor2               INTEGER;
	--EPG
	DEFINE cValor       		 CHAR(100);
	DEFINE cCodret2      		 CHAR (5);
	DEFINE cValordesc   		 CHAR (100);
	
    LET iSql_err		     = 0;
	LET cCodret		         = '000000';
    LET cNumTransaccion      =  SUBSTRING(pNum FROM 1 FOR 11);
    LET i                    = 0;
    LET iValor1              =  0;
    LET iValor3              = 0;
    LET iValor4              = 0;
	LET iValorF              = 0;
	LET iValor2              = 0;
	--EPG
	LET cValor      		 = "";
	LET cCodret2    		 = "000000";
	LET cValordesc  		 = "";
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN TRIM (cCodret);
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/home/sysifx/LuisMadrid/appriza.out';
		--TRACE ON;

	    IF LENGTH(pNum) <> 12 THEN
            LET cCodRet = '000001';	 
		ELSE	 
			FOR i = 1 TO LENGTH((cNumTransaccion)) 
				LET iValor1 = SUBSTR((cNumTransaccion), i, 1);
				IF i IN(1,3,5,7,9,11) THEN
					LET iValor1 = iValor1 * 2;
					IF iValor1 > 9 THEN
						LET iValor1 = SUBSTR((iValor1), 1, 1) + SUBSTR((iValor1), 2, 1);
					END IF;
				END IF;
				--Se tiene el total y se realiza la multiplicacion por 9.
				LET iValor3 = iValor3 + iValor1;	
			END FOR;
			    LET iValor4 = iValor3 * '9';
				LET iValorF = SUBSTR(iValor4, 3,1);
			IF	iValorF <> SUBSTR(pNum, 12,1) then 
				let cCodRet = '000002';
			END IF;
		END IF;
		
		SELECT trans_servicio
        INTO cValor
        FROM bdisac:sac_intrfz_serv
        WHERE numcategoria = '07'
		  AND numconvenio = '009'
		  AND num_trama = '1';

		 IF cValor = '20067' THEN
            CALL sp_verificaconvenio(cValor) returning cCodret2, cValordesc;
            IF cCodret2 = '00504' THEN
                RETURN TRIM(cCodret2);
            END IF;
        END IF;
		
		RETURN TRIM(cCodret);
	END
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142-1542',
'DESCRIPCION:Valida el digito verificador',
'FECHA: 11/03/2016',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_ws_coppel_ta(
											  pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd 	  CHAR(6),
											  pcUsuario 		  CHAR(8),
											  pcPassword 		  CHAR(8),
											  pcIp_origen 		  CHAR(15),
											  pcSession_id 		  CHAR(30),										  
											  pdate_process       CHAR(8),
											  ptime_process       CHAR(8),
											  pfecha_tran     CHAR(8),
											  pfolio     CHAR(20)) 
RETURNING
	CHAR(5)	as cCod_retorno,
	CHAR (4)  as  cod_ret,
	char (100) as  mensaje,
	CHAR(8) as cFecha_proceso,
	CHAR(6)   as  cHora_proceso,
	CHAR (20) as	vRecargaSerial,
	CHAR (12) as	vNumCelular,
	CHAR (15) as	vcompania,
	CHAR(10) as vmonto,
	CHAR (8) as cFecha_Recarga,
	CHAR (5) as	vSucursal,
	CHAR (1) as	vcobrado,
	CHAR (50) as	vEstatus;
			
--variables de retorno
	
	DEFINE	cod_ret		CHAR(8);
	DEFINE	mensaje		CHAR(120);
	DEFINE  cod_ret2    CHAR(8);
	DEFINE cOpcode 				CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(80);
	DEFINE cNombre_proceso		CHAR(17);
	DEFINE cCadena_ent			CHAR(100);
	DEFINE cCod_retorno		CHAR(5);
	DEFINE cFecha_proceso 	CHAR(8);
	DEFINE cFecha_Pago 	CHAR(10);
	DEFINE cHora_proceso 	CHAR(6);
	DEFINE  cFecha_Recarga		CHAR(8);
	DEFINE	vRecargaSerial 		CHAR (20);
	DEFINE	vNumCelular 		CHAR (12);
	DEFINE	vcompania 		CHAR (15);
	DEFINE	 vmonto 		CHAR (10);
	DEFINE	vSucursal 		CHAR (5);
	DEFINE	vcobrado 		CHAR (1);
	DEFINE	vEstatus 		CHAR (50);
	
	
	--DEFINE cReturnCode CHAR (5);
	
	--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER;
	DEFINE iIsamError 		INTEGER;
	
--variables del proceso
	DEFINE	vdiv 			INTEGER;


	---INICIALIZAR DE VARIABLES
	   
	   LET cod_ret = '0000';
	   LET mensaje = 'Consulta Exitosa';
	   LET cod_ret2 = '0000';
	   LET cOpcode = '0000';
	   LET cDescr_completa_mensaje = 'Consulta Exitosa.';
	   LET cNombre_proceso='sp_ws_coppel_TA';
	   LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
	  LET cCod_retorno  = '00000';
	  LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	  LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	  LET iIsamError = 0;
	  LET cFecha_Pago = '';
	   LET cFecha_Recarga = '';
	   LET vRecargaSerial = '0';
	   LET vNumCelular = '0';
	   LET vcompania = '0';
	   LET vmonto = '0';
	   LET vSucursal = '0';
	   LET vcobrado = '0';
	   LET vEstatus = '0';
	  
	  -- LET cReturnCode = '00000';
	   
	   -- SET DEBUG FILE TO '/informix/ivanVega/sp_pruebas.out';
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
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, LPAD(cod_ret,5,'0'), mensaje, '', '', cCadena_ent, pcUsuario,pdate_process,ptime_process)
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
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cod_ret, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,pdate_process,ptime_process)
				INTO cCod_retorno;
				
		    END IF;	
			
			LET cFecha_proceso =cFecha_proceso;
			
			INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
			VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pdate_process,ptime_process,pfecha_tran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current); 
			
			RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
		
			--RETURN LPAD(cCod_retorno,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso
			
		END IF;
	END EXCEPTION;


	--------VALIDACIÃ?N DE PARAMETROS-------------------------
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?' OR NVL(pcAgent_trans_type_code,'?')= '?'
		OR NVL(pcPassword,'?')= '?'	OR NVL(pdate_process,'?')= '?' OR NVL(ptime_process,'?')= '?' 
		OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')=''
		OR NVL(pfecha_tran,'?')= '?' THEN
		
		LET cod_ret ='9996';
	ELSE
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id) 
		INTO cod_ret, mensaje;
		IF cod_ret = '0000' THEN 
			IF pfecha_tran = cFecha_proceso THEN
				FOREACH
					SELECT {+INDEX(sac_movimientos,idx_sac_movimientos7)+INDEX(sac_pagostae, idx01_folio_suc}	mov.folio_suc,mov.referencia1,mov.referencia2,mov.importe_pago,trim(YEAR(mov.fecha_insert) || LPAD(MONTH(mov.fecha_insert),2,'0') || LPAD(DAY(mov.fecha_insert),2,'0')) fecharecarga,mov.id_sucursal, pag.conceptorespuesta, mov.fecha_pago
					INTO vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vEstatus,cFecha_Pago
					FROM sac_movimientos as mov inner join  sac_pagostae as pag on mov.folio_suc = pag.folio_suc
					WHERE mov.numcategoria = '03' 
					AND mov.numconvenio = '001'
					AND mov.folio_suc = pfolio
				END FOREACH;
					
				IF NVL(cFecha_Pago,'') <> '' THEN
					LET vcobrado= '1'; 
				END IF;	
			ELSE
				FOREACH
					SELECT {+INDEX(sac_movimientos_hs,idxsac_mov5)+INDEX(sac_pagostae, idx01_folio_suc}  mov.folio_suc,mov.referencia1,mov.referencia2,mov.importe_pago,trim(YEAR(mov.fecha_insert) || LPAD(MONTH(mov.fecha_insert),2,'0') || LPAD(DAY(mov.fecha_insert),2,'0')) fecharecarga,mov.id_sucursal, pag.conceptorespuesta, trim(YEAR(mov.fecha_pago) || LPAD(MONTH(mov.fecha_pago),2,'0') || LPAD(DAY(mov.fecha_pago),2,'0'))
					INTO vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vEstatus,cFecha_Pago
					FROM sac_movimientoshistorial as mov inner join  sac_pagostae as pag on mov.folio_suc = pag.folio_suc
					WHERE mov.numcategoria = '03' and mov.numconvenio = '001' AND mov.folio_suc = pfolio
				END FOREACH;
				
				IF NVL(cFecha_Pago,'') <> '' THEN
					LET vcobrado= '1'; 
				END IF;	
				
			END IF;	
		END IF;				
	END IF;

	IF cod_ret <> '0000' THEN			
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
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cod_ret, mensaje, '', '', cCadena_ent, pcUsuario,pdate_process,ptime_process)
		INTO cCod_retorno;
		
	END IF;
	
	IF NVL(vRecargaSerial,'0') = '0' and NVL(vNumCelular,'0') = '0' and cod_ret = '0000' then
		LET cOpcode = '7777';
		LET mensaje = 'Folio no encontrado con la fecha proporcionada.';
		LET	cDescr_completa_mensaje = 'Folio no encontrado con la fecha proporcionada.';
	END IF;			
												   
	INSERT INTO bdinteg:"informix".si_ws_coppel_ta(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,fecha_consulta,opcode,descr_message,nombre_proceso,date_process,time_process,recargaserial,numcelular,compania,monto,fecharecarga,sucursal,cobrado,estatus,datetimeinsert)
	VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pdate_process,ptime_process,pfecha_tran,cod_ret,mensaje,cNombre_proceso, cFecha_proceso,cHora_proceso,vRecargaSerial, vNumCelular,vcompania,vmonto,cFecha_Recarga,vSucursal,vcobrado,vEstatus,current);
	
	RETURN  LPAD(cCod_retorno,5,'0'),LPAD(cOpcode,4,'0'),mensaje,cFecha_proceso,cHora_proceso,NVL(vRecargaSerial,'0'),NVL(vNumCelular,'0'),NVL(vcompania,'0'),NVL(vmonto,'0'),NVL(cFecha_Recarga,'0'),NVL(vSucursal,'0'),NVL(vcobrado,'0'),NVL(vEstatus,'0');				
END
END PROCEDURE;