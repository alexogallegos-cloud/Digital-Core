CREATE PROCEDURE "informix".sp_registra_servicio_bex( pProceso 		CHAR(1),															
															pNumCliente 	CHAR(20),
															pNumCelular 	CHAR(10), 
															pNumCuenta		CHAR(20), 
															pContrasenia	CHAR(50),
															pCorreo 		CHAR(100),
															pImei			CHAR(150), 
															pUdid			CHAR(150),
															pUseragent      CHAR(150),
															pIpusuario 		CHAR(20), 
															pModelo			CHAR(150), 
															pCarrier		CHAR(1),
															pFolio 			CHAR(100) )
															
															
   returning CHAR(5),CHAR(150);


  
  
DEFINE sql_err 			INTEGER ;
DEFINE cod_ret 			CHAR(5);
DEFINE vStatus			VARCHAR(1);
DEFINE iIdUsuario 		INTEGER;
DEFINE bFlagRegistro 	CHAR(1);
DEFINE cMensajeRet 		CHAR(100);
DEFINE vIdUsuario		VARCHAR(10);
DEFINE vNumcte			VARCHAR(10);
	
 /*
 DEFINE  pNumCliente1 CHAR(20); 
 DEFINE  pNumCelular1 CHAR(10);
 DEFINE  pImei1  CHAR(150);	
 DEFINE num INTEGER;
 */
	LET cod_ret 	 	= '00000';
	LET iIdUsuario		= 0;
	LET vStatus 		= '';
	LET bFlagRegistro	= 'F';
	LET vIdUsuario 		= '';
	LET vNumcte			= '';
	--LET num	= 0;
	
  
  --SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_registra_servicio_bex.out";
  --TRACE ON;
  

 
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
			LET cMensajeRet = 'Error';
            RETURN cod_ret,cMensajeRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pProceso,'')='' OR NVL(pNumCelular,'')='' OR NVL(pNumCliente,'')='' OR NVL(pUdid,'')='' ) THEN
		LET cod_ret = '00001';
		LET cMensajeRet = 'Faltan datos';
		RETURN cod_ret,cMensajeRet;
	END IF;
	
	/*LET pNumCliente1=pNumCliente;
	LET pNumCelular1=pNumCelular;
    LET pImei1=pImei;
	*/
	--ALTA DEL SERVICIO
	IF pProceso='1' THEN 
	
		UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '2', servicio = 'inactivo' WHERE num_cliente=pNumCliente; 
		UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '2', servicio = 'inactivo' WHERE imei = pImei and udid=pudid; 
			
		IF EXISTS(SELECT estatus_servicio FROM bdibpi:bpi_registro_bex 	WHERE num_cliente = pNumCliente AND no_celular=pNumCelular AND imei=pImei AND estatus_servicio='2') THEN
				
				INSERT INTO bdibpi:bpi_registro_bex (num_cliente,no_celular,cuenta,contrasenia,correo,imei,udid,useragent,ipusuario, modelo, carrier,folio_activacion, estatus_servicio, fecha_ulti_acceso, fecha_registro,fecha_modificada,servicio ) 
				VALUES(pNumCliente,pNumCelular,pNumCuenta,pContrasenia,pCorreo,pImei,pUdid,pUseragent,pIpusuario,pModelo,pCarrier,pFolio,'1',CURRENT,CURRENT,CURRENT,'activo');
				
				--SET LOCK MODE TO WAIT 3;
					SELECT id_usuario,num_cliente INTO vIdUsuario, vNumcte FROM bdibpi:bpi_registro_bex 
					WHERE num_cliente = pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND estatus_servicio='1';	
					
					IF vNumcte = pNumCliente THEN 
						
								LET cod_ret  = '00000';
								LET cMensajeRet = 'Registro exitoso';
					END IF							
			
		ELSE
		
		--Valida que el numero celular no este dado ya de alta para este servicio
			IF EXISTS(SELECT no_celular FROM bdibpi:bpi_registro_bex WHERE no_celular = pNumCelular AND estatus_servicio='1') THEN
				LET cod_ret  = '00002';
				LET cMensajeRet = 'Numero celular registrado';
			END IF
		--Valida que el numero de cuenta no este dado ya de alta para este servicio
			IF EXISTS(SELECT num_cliente FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumCliente AND estatus_servicio='1') THEN
				LET cod_ret  = '00003';
				LET cMensajeRet = 'Numero de cuenta registrado';
			END IF
		--Valida que el dispositivo si estÃ¡ dado ya de alta para este servicio que lo cancele
			IF EXISTS(SELECT pImei FROM bdibpi:bpi_registro_bex   WHERE  imei = pImei and udid=pudid AND estatus_servicio='1') THEN
				UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '2', servicio = 'inactivo' WHERE imei = pImei and udid=pudid; 
				--LET cod_ret  = '00004';
				--LET cMensajeRet = 'Dispositivo registrado';
			END IF

			IF cod_ret = '00000' THEN
		
				INSERT INTO bdibpi:bpi_registro_bex (num_cliente,no_celular,cuenta,contrasenia,correo,imei,udid,useragent,ipusuario, modelo, carrier,folio_activacion, estatus_servicio, fecha_ulti_acceso, fecha_registro,fecha_modificada,servicio) 
					VALUES(pNumCliente,pNumCelular,pNumCuenta,pContrasenia,pCorreo,pImei,pUdid,pUseragent,pIpusuario,pModelo,pCarrier,pFolio,'1',CURRENT,CURRENT,CURRENT,'activo');

					--SET LOCK MODE TO WAIT 3;
					SELECT id_usuario,num_cliente INTO vIdUsuario, vNumcte FROM bdibpi:bpi_registro_bex 
					WHERE num_cliente = pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND estatus_servicio='1';	
					
					IF vNumcte = pNumCliente THEN 
					
								LET cod_ret  = '00000';
								LET cMensajeRet = 'Registro exitoso';
					END IF;
			END IF
			
		END IF
		RETURN cod_ret,cMensajeRet;
	END IF 
	--CANCELACION DEL SERVICIO
	IF pProceso='2' THEN
		
		--SET LOCK MODE TO WAIT 3;
		SELECT id_usuario,num_cliente INTO vIdUsuario, vNumcte FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND servicio = 'activo';
		IF vIdUsuario != '' THEN 
		
			IF vNumcte = pNumCliente THEN  
				UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '2', fecha_modificada = CURRENT, servicio = 'inactivo' WHERE num_cliente=pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid;
					
				LET cod_ret  = '00000';
				LET cMensajeRet = 'Baja exitosa';
				
			ELSE
				LET cod_ret  = '00005';
				LET cMensajeRet = 'usuario no valido';
			END IF;
		ELSE
		
			LET cod_ret  = '00005';
			LET cMensajeRet = 'usuario no valido';
		END IF			
		
		
		RETURN cod_ret,cMensajeRet;
	END IF
	--BAJA TEMPORAL Y REACTIVACION 
	IF pProceso='3' THEN
	
		--SET LOCK MODE TO WAIT 3;
		SELECT id_usuario, num_cliente, estatus_servicio INTO vIdUsuario, vNumcte, vStatus
		FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND estatus_servicio in ('1','4');

		IF vIdUsuario != '' THEN
		
			IF vStatus = '1' THEN
				IF vNumcte = pNumCliente THEN  
					UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '4', fecha_modificada = CURRENT WHERE num_cliente=pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND estatus_servicio='1';
						
					LET cod_ret  = '00000';
					LET cMensajeRet = 'Baja exitosa temporal';
					
				ELSE
					LET cod_ret  = '00005';
					LET cMensajeRet = 'usuario no valido';
				
				END IF
			END IF
			IF vStatus = '4' THEN
				IF vNumcte = pNumCliente THEN  
					UPDATE bdibpi:bpi_registro_bex SET estatus_servicio = '1', fecha_modificada = CURRENT WHERE num_cliente=pNumCliente AND no_celular=pNumCelular AND imei=pImei AND udid=pUdid AND estatus_servicio='4';
											
					LET cod_ret  = '00000';
					LET cMensajeRet = 'Reactivacion exitosa';
					
				else
					LET cod_ret  = '00005';
					LET cMensajeRet = 'usuario no valido';
			
				END IF
			END IF
		ELSE
		
			LET cod_ret  = '00005';
			LET cMensajeRet = 'usuario no valido';
		END IF			
		
		RETURN cod_ret,cMensajeRet;
	END IF
   
END;

END PROCEDURE;