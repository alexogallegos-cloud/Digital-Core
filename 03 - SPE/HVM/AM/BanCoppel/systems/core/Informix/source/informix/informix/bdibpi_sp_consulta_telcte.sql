CREATE PROCEDURE "informix".sp_consulta_telcte(pNumTel CHAR(10), pTipoTel SMALLINT, pCanal CHAR(4))
   RETURNING CHAR(5) AS Cod_ret, CHAR(10) AS mensaje, CHAR(15) AS num_cliente, CHAR(100) AS Nombre, CHAR(150) AS pUdid,CHAR(150) AS pImei;
   
   --Definimos variables
   DEFINE sql_err  		INTEGER;
   DEFINE vCod_ret 		CHAR(5);
   DEFINE vMensaje 		CHAR(10);
   DEFINE vNumcte  		CHAR(11);
   DEFINE vTelefono 	CHAR(10);
   DEFINE vContador		INTEGER;
   DEFINE vNombre		CHAR (210);
   DEFINE pUdid 		CHAR(150);
   DEFINE pImei 		CHAR(150);
   DEFINE pApell1  		CHAR(26);
   DEFINE pApell2  		CHAR(26);
   DEFINE pNombre1 		CHAR(26);
   DEFINE pNombre2 		CHAR(26);
 
   
   LET vCod_ret 		= '00000';
   LET vMensaje 		= '';
   LET vNumcte  		= '';
   LET vTelefono		= '';
   LET vContador		= 0;
   LET vNombre 			= '';
   LET pUdid			= '';
   LET pImei			= '';
   
	BEGIN
	ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					RETURN vCod_ret,vMensaje,vNumcte, vNombre,  pUdid, pImei;
            END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT count(numcte) INTO vContador FROM bdinteg:"informix".si_telefonos_actual
         WHERE telefono = pNumTel
           AND tipo_tel = pTipoTel
           AND status_tel = 'A';
	
	IF vContador = 1 THEN 
	

		SELECT a.numcte,
		a.apell_paterno,
		a.apell_materno,
		a.nombre1,
		a.nombre2
		INTO vNumcte, pApell1,pApell2,pNombre1,pNombre2
		FROM bdinteg:si_cliente a, bdinteg:si_telefonos_actual b
		WHERE a.numcte=b.numcte 
		AND telefono = pNumTel
        AND tipo_tel = pTipoTel
        AND status_tel = 'A';
	
		LET vNombre = TRIM(pApell1)||' '||TRIM(pApell2)||' '||TRIM(pNombre1)||' '||TRIM(pNombre2);
		LET vMensaje = 'EXISTE';
		
		IF pCanal = '5011' THEN 
		
			SELECT imei, udid  INTO  pUdid, pImei
			FROM bdibpi:bpi_registro_bex 
			WHERE no_celular = pNumTel 
			AND estatus_servicio <> '2';
			
		END IF;
		
	END IF;	
	
	IF vContador = 0 THEN 
		LET vCod_ret = '00001';
		LET vMensaje = 'NO EXISTE';
	END IF;	
	
	IF vContador > 1 THEN 
		LET vCod_ret = '00002';
		LET vMensaje = 'DUPLICADO';
	END IF;	
	
RETURN vCod_ret,vMensaje,vNumcte, vNombre,  pUdid, pImei;
END	
END PROCEDURE;