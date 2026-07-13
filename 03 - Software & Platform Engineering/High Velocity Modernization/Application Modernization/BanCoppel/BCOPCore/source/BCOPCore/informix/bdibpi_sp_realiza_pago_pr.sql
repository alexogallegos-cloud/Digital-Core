CREATE PROCEDURE "informix".sp_realiza_pago_pr(pEmpresa CHAR(3),pCuentaOrigen CHAR(11),pNumCelOrigen CHAR(10),pCuentaDestino CHAR(11),pNumCelDestino CHAR(10),pMonto DECIMAL(16,2),pFolioSuc CHAR(16),pIdSesion CHAR(200),
	pReferenciaOrigen CHAR(40), pReferenciaDestino CHAR(40))
   returning CHAR(5),CHAR(150);

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE cCuentaOrigen CHAR(11);
	DEFINE cCuentaDestino CHAR(11);
	DEFINE cCodRetTrans CHAR(5);
	DEFINE cCodRetTrans2 CHAR(5);
	DEFINE cMensajeRet CHAR(150);
	DEFINE cIdSesion CHAR(200);
	DEFINE dMontoAcumulado DECIMAL(16,2);
	DEFINE dMontoAcumulado_Dia DECIMAL(16,2);
	DEFINE cTransCargo CHAR(4);
	DEFINE cTransAbono CHAR(4);
	DEFINE cCodCierre CHAR(5);
	DEFINE cBanderaCierre CHAR(1);
	DEFINE dLimiteAcumulado DECIMAL(16,2);
	DEFINE dLimiteAcumulado_Dia DECIMAL(16,2);
	DEFINE cReferenciaOrigen CHAR(40);
	DEFINE cReferenciaDestino CHAR(40);
	
	LET cCodRet='00000';
	LET cCuentaOrigen='';
	LET cCuentaDestino='';
	LET cCodRetTrans='';
	LET cCodRetTrans2='';
	LET cMensajeRet='';
	LET cIdSesion='';
	LET dMontoAcumulado=0;
	LET dMontoAcumulado_Dia=0;
	LET dLimiteAcumulado=0;
	LET dLimiteAcumulado_Dia=0;	
	LET cReferenciaOrigen = 'TRASP BYA ABONO';
	LET cReferenciaDestino = 'TRASP BYA CARGO';
	
  --SET DEBUG FILE TO "/tmp/sp_realiza_pago_pr.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
			--OBTIENE MENSAJE DE ERROR A MOSTRAR
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='007' AND tipo_param='2';
            RETURN cCodRet,cMensajeRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pEmpresa,'')='' OR NVL(pCuentaOrigen,'')='' OR NVL(pNumCelOrigen,'')=''OR NVL(pCuentaDestino,'')=''OR NVL(pNumCelDestino,'')=''OR NVL(pMonto,'')=''OR NVL(pIdSesion,'')=''OR NVL(pFolioSuc,'')='')THEN
		LET cCodRet = '00001';
		RETURN cCodRet,cMensajeRet;
	END IF;
	
	--VALIDA SESION PERMITIDA
	/*
	SELECT id_sesion 
	INTO cIdSesion
	FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdsesion;
	*/
	
	
	-- Se asigna la referencia Origen y Destino
	IF NVL(pReferenciaOrigen,'') <> '' THEN
		LET cReferenciaOrigen = pReferenciaOrigen;
	END IF;
	
	IF NVL(pReferenciaDestino,'') <> '' THEN
		LET cReferenciaDestino = pReferenciaDestino;
	END IF;
	
	-- Se asigna la Sesion
	LET cIdSesion = 'SESIONBYA';
	
	IF NVL(cIdSesion,'')<>'' THEN
		--SE VALIDA QUE CUENTA ORIGEN ESTE ENROLADA
		SELECT cuenta
		INTO cCuentaOrigen
		FROM bdibpi:"informix".pr_registro_app 
		WHERE celular=pNumCelOrigen AND cuenta=pCuentaOrigen;
		
		--SE VALIDA LA CUENTA DESTINO
		--IF NVL(pCuentaDestino,'')<>'' THEN
		IF NVL(pCuentaDestino,'') <> '0' THEN
			--SELECT cuenta
			--INTO cCuentaDestino
			--FROM bdibpi:"informix".pr_registro_app 
			--WHERE celular=pNumCelDestino AND cuenta=pCuentaDestino AND estatus_servicio='A';
			
			LET cCuentaDestino = pCuentaDestino;
		ELSE
			-- Si el usuario es Cero, significa que es un pago a un numero de telefono.
			SELECT cuenta 
			INTO cCuentaDestino
			FROM bdicheq:"informix".sc_cuenta_telefono 
			WHERE telefono = pNumCelDestino; -- AND num_cte = cNumCliente;
		END IF;
		
		--SE OBTIENE NUMERO TRANSACCION CARGO
		SELECT valor 
		INTO cTransCargo
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='013' AND tipo_param='2';
		
		--SE OBTIENE NUMERO TRANSACCION ABONO
		SELECT valor 
		INTO cTransAbono
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='014' AND tipo_param='2';
		
		--SE OBTIENE LIMITE DE MONTO ACUMULADO
		SELECT valor 
		INTO dLimiteAcumulado
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='003' AND tipo_param='1';
		
		--SE OBTIENE LIMITE DE MONTO ACUMULADO DIARIO
		SELECT valor 
		INTO dLimiteAcumulado_Dia
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='029' AND tipo_param='1';
		
		IF cCuentaOrigen <> '' AND cCuentaDestino <> '' THEN
			IF cCuentaOrigen<>cCuentaDestino THEN
				-- SE VALIDA EL MONTO ACUMULADO DEL DIA Y MES DEL ORIGEN
				SELECT monto_acumulado, monto_acumulado_dia
				INTO dMontoAcumulado, dMontoAcumulado_Dia
				FROM bdibpi:"informix".pr_control_trans
				WHERE num_celular=pNumCelOrigen;
				
				IF (dMontoAcumulado+pMonto)<= dLimiteAcumulado THEN
					IF (dMontoAcumulado_Dia+pMonto)<= dLimiteAcumulado_Dia THEN				
						--SE VALIDA EL CIERRE DE CUENTAS
						EXECUTE PROCEDURE bdibpi:"informix".sp_obtenerbanderaoperacion(1,0,0)INTO cCodCierre,cBanderaCierre;
						
						IF cCodCierre='00000'THEN
							IF cBanderaCierre='f' THEN
								--MODIFICA LA BANDERA DE CHEQUES
								EXECUTE PROCEDURE bdibpi:"informix".sp_modificarbanderaoperacion (1,'f')INTO cCodCierre;
								IF cCodCierre='00000'THEN
									--EXECUTE PROCEDURE bdibpi:"informix".spsctransctaspropias_pr(pEmpresa, '5003', 'transBPI',cTransCargo,cTransAbono, '', pFolioSuc,cCuentaOrigen,cCuentaDestino, 0,pMonto, '01', 'TRASP BYA ABONO','TRASP BYA CARGO', '', '', '',pMonto,pMonto, 0, 0, 0, '')
									EXECUTE PROCEDURE bdibpi:"informix".spsctransctaspropias_pr(pEmpresa, '5003', 'transBPI',cTransCargo,cTransAbono, '', pFolioSuc, cCuentaOrigen, cCuentaDestino, 0,pMonto, '01', cReferenciaOrigen, cReferenciaDestino, '', '', '',pMonto,pMonto, 0, 0, 0, '')
									INTO cCodRetTrans,cCodRetTrans2;
									
									IF cCodRetTrans ='000' THEN
										SELECT valor 
										INTO cMensajeRet
										FROM bdibpi:"informix".pr_param_mensajes 
										WHERE id_param='006' AND tipo_param='2';
										
										--SE ACTUALIZA  ACUMULADO MENSUAL Y DIARIO DE ORIGEN
										LET dMontoAcumulado=dMontoAcumulado + pMonto;
										LET dMontoAcumulado_Dia=dMontoAcumulado_Dia + pMonto;
										
										UPDATE bdibpi:"informix".pr_control_trans SET monto_acumulado=dMontoAcumulado, monto_acumulado_dia=dMontoAcumulado_Dia
										WHERE num_celular=pNumCelOrigen;				
									ELSE
										LET cCodRet= cCodRetTrans;
										SELECT valor 
										INTO cMensajeRet
										FROM bdibpi:"informix".pr_param_mensajes 
										WHERE id_param='007' AND tipo_param='2';
									END IF;
								ELSE
									--ERROR AL MODIFICAR BANDERA
									LET cCodRet= '00005';
									SELECT valor 
									INTO cMensajeRet
									FROM bdibpi:"informix".pr_param_mensajes 
									WHERE id_param='007' AND tipo_param='2';
								END IF;
							ELSE
								--EJECUCION DEL CIERRE
								--MODIFICA LA BANDERA DE CHEQUES
								LET cCodRet= '00005';
								EXECUTE PROCEDURE bdibpi:"informix".sp_modificarbanderaoperacion (1,'t')INTO cCodCierre;
								
								SELECT valor 
								INTO cMensajeRet
								FROM bdibpi:"informix".pr_param_mensajes 
								WHERE id_param='007' AND tipo_param='2';
							END IF;
						ELSE
							--ERROR AL EJECUTAR EL CIERRE
							LET cCodRet= '00005';
							SELECT valor 
							INTO cMensajeRet
							FROM bdibpi:"informix".pr_param_mensajes 
							WHERE id_param='007' AND tipo_param='2';
						END IF;
				
					ELSE 
						LET cCodRet='00009'; --MONTO ACUMULADO DIA EXCEDIDO
						SELECT valor 
						INTO cMensajeRet
						FROM bdibpi:"informix".pr_param_mensajes 
						WHERE id_param='030' AND tipo_param='1';						
					END IF;				
				ELSE 
					LET cCodRet='00008'; --MONTO ACUMULADO MENSUAL EXCEDIDO
					SELECT valor 
					INTO cMensajeRet
					FROM bdibpi:"informix".pr_param_mensajes 
					WHERE id_param='026' AND tipo_param='1';
				END IF;							
			ELSE 
				LET cCodRet='00004'; --CUENTAS IGUALES
				SELECT valor 
				INTO cMensajeRet
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='012' AND tipo_param='2';			
			END IF;
		ELSE
			LET cCodRet='00003';
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='011' AND tipo_param='2';	
		END IF;
	ELSE
		LET cCodRet='00002';		SELECT valor 
		INTO cMensajeRet
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='008' AND tipo_param='2';
		
	END IF;
	
	RETURN cCodRet,cMensajeRet;
	
END

END PROCEDURE;