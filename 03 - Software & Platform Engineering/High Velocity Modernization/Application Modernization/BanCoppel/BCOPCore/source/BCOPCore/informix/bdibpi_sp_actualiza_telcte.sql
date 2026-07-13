CREATE PROCEDURE "informix".sp_actualiza_telcte(pNumTel CHAR(10), pNumCte CHAR(10), pCanal CHAR(4),pUdid CHAR(150),pImei CHAR(150))
   RETURNING CHAR(5) AS Cod_ret;
   
   --Definimos variables
   DEFINE sql_err  		INTEGER;
   DEFINE vCod_ret 		CHAR(5);
   DEFINE vMensaje 		CHAR(10);
   DEFINE vNumcte  		CHAR(11);
   DEFINE vTelefono 	CHAR(10);
   DEFINE vContador		INTEGER;
   DEFINE vNombre		CHAR (210);
   DEFINE pApell1  		CHAR(26);
   DEFINE pApell2  		CHAR(26);
   DEFINE pNombre1 		CHAR(26);
   DEFINE pNombre2 		CHAR(26);
   DEFINE pUser			INTEGER;
 
   
   LET vCod_ret 		= '00001'; --usuarios no encontrado
   LET vMensaje 		= '';
   LET vNumcte  		= '';
   LET vTelefono		= '';
   LET vContador		= 0;
   LET vNombre 			= '';
   LET pUser			= 0;
   
	BEGIN
	ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					RETURN vCod_ret;
            END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/informix/ireb/android10/sp_actualiza_telcte.out';
    --TRACE ON;
	
	IF NVL(pNumTel,'')='' OR NVL(pNumCte,'')='' OR NVL(pCanal,'')=''  THEN
			LET vCod_ret='00003';  --Faltan paramentros
			RETURN vCod_ret;
	END IF;
	
	SELECT COUNT(numcte) INTO vContador FROM bdinteg:"informix".si_telefonos
         WHERE telefono = pNumTel
		   AND numcte = pNumCte
           AND tipo_tel = 2
           AND status_tel = 'A';
	
	IF vContador = 1 THEN 
	
		IF pCanal = '5011' THEN 
		
			SELECT COUNT(no_celular) 
			INTO pUser 
			FROM bdibpi:bpi_registro_bex 
			WHERE udid = pUdid 
			AND no_celular = pNumTel
			AND servicio = 'activo';

			    IF pImei = 'null' AND pUser=1 THEN 

					UPDATE bdibpi:bpi_registro_bex SET imei = pUdid WHERE udid = pUdid AND no_celular = pNumTel AND servicio = 'activo';
					
				ELSE
				
					SELECT COUNT(no_celular) 
						INTO pUser 
						FROM bdibpi:bpi_registro_bex 
						WHERE udid = pUdid 
						AND no_celular = pNumTel
						AND servicio = 'activo';
						
			   END IF;
		
			SELECT imei, udid  INTO  pUdid, pImei
			FROM bdibpi:bpi_registro_bex 
			WHERE no_celular = pNumTel 
			AND estatus_servicio <> '2';
		
			LET vCod_ret 		= '00000';		--Usuario actualizado
		
		END IF;
		

		IF pCanal = '5007' THEN 
		
			SELECT COUNT(num_cliente ) INTO vContador
			FROM bpi_reg_dispo_apps  WHERE num_cliente = pNumCte AND imei=pUdid and  dispo_act = '1';
			
			IF vContador = 1 THEN

				UPDATE bpi_reg_dispo_apps SET Udid=pImei, imei=pImei  WHERE  num_cliente = pNumCte AND dispo_act = '1';
				LET vCod_ret 		= '00000';	--Usuario actualizado			
				
			ELSE
				LET vCod_ret = '00002';  --Usuario sin necesidad de actualizar.
			END IF;

			
		END IF;
	END IF;	
	
RETURN vCod_ret;
END	
END PROCEDURE;