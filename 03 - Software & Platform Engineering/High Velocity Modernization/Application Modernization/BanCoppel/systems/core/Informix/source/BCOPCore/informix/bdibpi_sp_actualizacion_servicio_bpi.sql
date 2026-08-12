CREATE PROCEDURE "informix".sp_actualizacion_servicio_bpi(pNumTel CHAR(10),pCte VARCHAR(20), pUdid CHAR(150),pImei CHAR(150), vModelo CHAR(50) , pTipo INTEGER)
   RETURNING CHAR(5) AS Cod_ret, CHAR(50) AS mensaje
   
   --Definimos variables
   DEFINE sql_err  		INTEGER;
   DEFINE vCod_ret 		CHAR(5);
   DEFINE vMensaje 		CHAR(50);
   DEFINE vUsuario 		CHAR(50);
   DEFINE vNumcte  		CHAR(11);
   DEFINE vTelefono 	CHAR(10);
   DEFINE vDispositivo 	CHAR(2);
   DEFINE vImei 		CHAR(150);
   DEFINE vIdui 		CHAR(150);
   DEFINE vContador		INTEGER;
   
   DEFINE pNumTel1		CHAR(10);	
   DEFINE pCte1 		CHAR(20);	
   DEFINE pUdid1		CHAR(150);	
   DEFINE pImei1		CHAR(150);	
   DEFINE vExit 		INTEGER;
   
   
   LET vCod_ret 		= '00000';
   LET vMensaje 		= 'CORRECTO';
   LET vUsuario			= '';
   LET vNumcte  		= '';
   LET vTelefono		= '';
   LET vDispositivo		= '';
   LET vImei			= '';
   LET vIdui			= '';
   LET vContador		= 0;
   LET vExit 			= 0;
   
   
   
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/enrolamiento/sp_actualizacion_servicio_bpi.out";
	--TRACE ON;
   
	BEGIN
	ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					LET vMensaje = 'ERROR';
					RETURN vCod_ret,vMensaje;
            END IF;
    END EXCEPTION;

	
	LET pNumTel1 	= pNumTel;
	LET pCte1 		= pCte;
	LET pUdid1		= pUdid;
	LET pImei1		= pImei;
	
	--VALIDA EL SERVICIO
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ptipo = 1 THEN 
	
		IF( NVL(pNumTel,'')='' OR NVL(pCte,'')='' OR NVL(pUdid,'')='' OR NVL(pImei,'')='' OR NVL(ptipo,'')='' OR NVL(vModelo,'')='')THEN
			LET vCod_ret = '00001';
			LET vMensaje = 'FALTAN DATOS';
			RETURN vCod_ret,vMensaje;
		END IF;
	
		SELECT COUNT(id_usuario) INTO vExit FROM bdibpi:bpi_reg_dispo_apps WHERE no_celular = pNumTel AND imei=pImei AND udid=pUdid AND dispo_act = '1';
		
		--IF EXISTS(SELECT id_usuario,no_celular,num_cliente FROM bdibpi:bpi_reg_dispo_apps WHERE no_celular = pNumTel AND imei=pImei AND udid=pUdid AND dispo_act = '1') THEN
		IF vExit > 0 THEN 
			LET vCod_ret = '00002';
			LET vMensaje = 'CELULAR Y DISPOS REGISTRADOS';
			RETURN vCod_ret,vMensaje;
		END IF
	
		--CANCELA EL USUARIO
		UPDATE bdibpi:bpi_reg_dispo_apps SET dispo_act = '2' WHERE num_cliente=pCte; 
		--CANCELA EL DISPOSITIVO
		UPDATE bdibpi:bpi_reg_dispo_apps SET dispo_act = '2' WHERE imei = pImei and udid=pudid; 
	
		--INSERTA EL NUEVO REGISTRO
		INSERT INTO bdibpi:bpi_reg_dispo_apps(id_usuario, num_cliente, no_celular, correo, imei, udid, useragent, modelo, carrier, ipusuario, dispo_act, fecha_registro, fecha_modificada, generico1, generico2, generico3, generico4, generico5) 
		VALUES(0, pCte, pNumTel, '', pImei, pUdid, '', vModelo, 0, '127.0.0.1', 1, TODAY, TODAY, '', '', '', '', '');
	
	END IF
	--CANCELAR DISPOSITIVO
	
IF ptipo = 2 THEN 
	
		
	
		--CANCELA EL USUARIO
		IF( NVL(pCte,'')<>'') THEN
			UPDATE bdibpi:bpi_reg_dispo_apps SET dispo_act = '2' WHERE num_cliente=pCte AND dispo_act='1'; 		
			LET vCod_ret = '00000';
			LET vMensaje = 'CORRECTO';
		END IF;
			
		--CANCELA EL DISPOSITIVO
		IF( NVL(pNumTel,'')<>'' )THEN
			UPDATE bdibpi:bpi_reg_dispo_apps SET dispo_act = '2' WHERE no_celular=pNumTel AND dispo_act='1';
			LET vCod_ret = '00000';
			LET vMensaje = 'CORRECTO';
		END IF;
	
	
	END IF
	
	RETURN vCod_ret,vMensaje;
	
END

END PROCEDURE;