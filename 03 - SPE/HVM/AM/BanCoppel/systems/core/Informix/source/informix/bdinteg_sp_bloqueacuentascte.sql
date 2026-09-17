CREATE PROCEDURE "informix".sp_bloqueacuentascte(pNumCte CHAR (10),pNumCuenta CHAR(20),pClaveBloqueo INTEGER,pTipoBloqueo INTEGER,
												 pCausaBloqueo CHAR(3),pOpcionBloqueo CHAR(3),pAreaBloqueo CHAR(3),pEjecutivo CHAR(8),
												 pEmpresa CHAR(3),pTipoCuenta INTEGER) 
												 
												 	
																

																
														
	RETURNING CHAR(25);

	DEFINE cCodRet 			CHAR(25);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE vCodSP  			CHAR(6);
	DEFINE CcodArea 		CHAR(1);
	DEFINE Ccodtipobloq 	CHAR(1);
	DEFINE Cfolio_suc 		CHAR(25);
	DEFINE Cfecha			CHAR(25);
	DEFINE fecha_w			CHAR(15);
	DEFINE status2_w 		CHAR(1);
	DEFINE mov 				CHAR(1);
	DEFINE v_transacc 		CHAR(5);
	DEFINE v_mesdia         CHAR(4);
	DEFINE hora_w           CHAR(15);
	DEFINE v_clave          CHAR(4);
	DEFINE suc_w            CHAR (4);
	DEFINE prod_w           CHAR (4);
	DEFINE sdod_w           MONEY (14,2);
	DEFINE vfecha_operacion DATE;
	DEFINE status_w         CHAR(1);
	DEFINE vFecha        	DATE;
	DEFINE Iexiste          INTEGER;
	DEFINE cTipoBloqueo     CHAR(2);


	
	LET Cfolio_suc		 ='';
	LET Cfecha			 ='';
	LET cCodRet  		 ='00000';
	LET iSqlErr 		 =0;
	LET vCodSP           ='';
	LET CcodArea 		 ='';
	LET Ccodtipobloq	 ='';
	LET fecha_w			 ='';
	LET status2_w		 ='';
	LET mov 			 ='';
	LET v_transacc		 ='';
	LET v_mesdia  		 ='';
	LET hora_w  		 ='';
	LET v_clave  		 ='';
	LET suc_w 			 ='';
	LET prod_w 			 ='';
	LET sdod_w       	 =0.00;
	LET vfecha_operacion =TODAY;
	LET status_w  		 ='';
	LET vFecha           = DATE(1);
	LET Iexiste			 = 0;
	LET cTipoBloqueo     = CONCAT('0',CAST(pTipoBloqueo as CHAR(2)));
	
--	SET DEBUG FILE TO '/home/sysifx/VIRIDIANA2/SP_BLOQUEACUENTASCTE.out';
--	TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
		SELECT fecha_hoy
		INTO vFecha
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;
		
		--quitar pruebas
	--	let cTipoBloqueo = cTipoBloqueo ;
	--	let pAreaBloqueo =pAreaBloqueo;
		
	IF pTipoCuenta = 1 THEN
		EXECUTE PROCEDURE bdicred:"informix".sp_validacredito (pEmpresa, pNumCuenta) 
		INTO vCodSP;
		
		IF vCodSP::INTEGER = 0 THEN
			
			--SI ES BLOQUEO POR INE SE DEFINE CLAVE DE BLOQUEO = 3
			IF(pCausaBloqueo = '91' AND pClaveBloqueo = 1) THEN LET pClaveBloqueo = 3; END IF
			
			INSERT INTO  bdicred:"informix".sd_bitacorabloqueocta(cuenta,cve_bloqueo,cve_causa,cve_bloqueanterior,cve_causa_anterior,ejecutivo,fecha,tipo_bloqueo,tipo_movimiento)
			VALUES (pNumCuenta,pClaveBloqueo,pCausaBloqueo, NULL, NULL,pEjecutivo,vFecha,pTipoBloqueo,'B');   
			
			UPDATE bdicred:"informix".sd_maecred
			SET id_unidad_prod = pClaveBloqueo, Cod_caract_2 = pCausaBloqueo
			WHERE empresa = pEmpresa
			AND num_credito = pNumCuenta;
		END IF
		
		
	ELIF pTipoCuenta = 2 THEN
		--Validar que exista la cuenta en la tabla 
			
			SELECT COUNT(num_cte) INTO Iexiste
			FROM bdicheq:"informix".sc_maechq 
			where cuenta =pNumCuenta and num_cte=pNumCte;
		
		IF (Iexiste) > 0 THEN
			
			-- // Obtiene la fecha del sistema
				select fecha_hoy 
				into fecha_w 
				from bdicheq:"informix".sc_fechas 
				where empresa = pempresa;
				
				-- // Obtiene datos de la cuenta
				select sucursal, producto, status_cta, ( sdo_actual - ( sdo_cong + sdo_retenido + imp_chq_sbg ) )
				into  suc_w, prod_w, status_w, sdod_w
				from bdicheq:"informix".sc_maechq
				where cuenta = pNumCuenta;
			
			if pClaveBloqueo <> 00 then 
				
				let status2_w = '3';
				let mov = 'B';
				let v_transacc ='3353';
				
				let Cfecha  = current hour to fraction;
				let Cfecha  = Cfecha[1,2]||Cfecha[4,5]||Cfecha[7,8]||Cfecha[10,11];
				let Cfolio_suc = trim(pEjecutivo)||Cfecha;
				
				let v_mesdia = trim(month(fecha_w) || day(fecha_w));
				let hora_w = trim(Cfecha[4,5]||Cfecha[7,8]);
				let v_clave = trim(v_mesdia)||trim(hora_w);
				
					
				SELECT codigo  into CcodArea FROM bdicheq:"informix".sc_areabloqueo WHERE clave = pAreaBloqueo;
				SELECT codigo into Ccodtipobloq FROM bdicheq:"informix".sc_tipobloqueo WHERE clave = cTipoBloqueo;
				
				-- // Inserta registro en historico de bloqueos
				insert into bdicheq:"informix".sc_histbloq(empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,
							referencia,cve_area,cod_area,cve_tipobloq,cod_tipobloq )
				values(pempresa,pNumCuenta,mov,pClaveBloqueo,pOpcionBloqueo,0.00,pEjecutivo,fecha_w,current hour to fraction,v_clave, 
				mov,Cfolio_suc,"",pAreaBloqueo,CcodArea,cTipoBloqueo,Ccodtipobloq );
				
				 
				 --Insertar registro en la tabla bdicheq: sc_ctabloqueo:
				 INSERT INTO bdicheq:"informix". sc_ctabloqueo (cuenta,clave,opcion,cve_area,cod_area,cve_tipobloq,cod_tipobloq)
				 VALUES (pNumCuenta,pClaveBloqueo,pOpcionBloqueo,pAreaBloqueo,CcodArea,cTipoBloqueo,Ccodtipobloq);

				 --Insertar registro en la tabla bdicheq: sc_ctabloqueohist:
				 INSERT INTO  bdicheq:"informix".  sc_ctabloqueohist (cuenta,clave,opcion) 
				 VALUES (pNumCuenta,pClaveBloqueo,pOpcionBloqueo);
				
				--Insertar registro en la tabla bdicheq: sc_movdia:
				INSERT INTO  bdicheq: "informix". sc_movdia (folio_suc,sucursal,usuario,fech_alt,fech_val,fech_hor,transacc,suc_cuen,producto,empresa,
							cuenta,causa_dev,num_cheq,monto_tot,
							firme,en_sbc,remesas,dias_ret,cancelad,
							edo_cta,sdo_cuenta,transacc_suc,referencia,
							tasa_aplicada,num_tarjeta,usuautoriza,referencia_23,fech_oper) 
				VALUES (Cfolio_suc,suc_w,pEjecutivo,fecha_w,fecha_w, current hour to fraction,'3353',suc_w,prod_w,pEmpresa,pNumCuenta,
						'',0,0.00,0,0,0,0," ",status_w,sdod_w,'0000', '',0,'','','',vfecha_operacion);
				
				
				--Actualizar el estatus de la cuenta en la tabla bdicheq: sc_maechq
				UPDATE bdicheq: "informix". sc_maechq 
				SET fec_cancelac=fecha_w,status_cta=status2_w,motivo=pClaveBloqueo,fecha_proceso= fecha_w
				WHERE cuenta= pNumCuenta AND num_cte=pNumCte;
			END IF
		END IF
	
	END IF
	
	
	RETURN cCodRet;
	
END;
END PROCEDURE;