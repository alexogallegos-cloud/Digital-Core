CREATE PROCEDURE "informix".sp_valida_servicio_bex_pba2(pNumTel CHAR(10),pFechaNac DATE, pCtaTjCte VARCHAR(20), pUdid CHAR(150),pImei CHAR(150))
   RETURNING CHAR(5) AS Cod_ret,
			 CHAR(50) AS mensaje,
			 CHAR(10) AS NumCte,
			 CHAR(26) AS Apell1,
			 CHAR(26) AS Apell2,
			 CHAR(26) as Nombre1,
			 CHAR(26) AS Nombre2,
			 CHAR(1) AS EstatusSer, 
			 INTEGER AS CtaDig, 
			 CHAR(30) AS Correo;

--Definimos de Variables
   DEFINE sql_err  		INTEGER;
   DEFINE vCod_ret 		CHAR(5);   
   DEFINE vMensaje 		CHAR(50);
   DEFINE vNumcte  		CHAR(10);
   DEFINE vNumTel  		CHAR(10);
   DEFINE vApell1  		CHAR(26);
   DEFINE vApell2  		CHAR(26);
   DEFINE vNombre1 		CHAR(26);
   DEFINE vNombre2 		CHAR(26);
   DEFINE vEstatusSer 	CHAR(1);
   DEFINE vCtaDig		INTEGER;
   DEFINE vCorreo		CHAR(30);
   DEFINE vLong         INTEGER;
   DEFINE vExistCred	INTEGER;
   DEFINE l_Fecha		DATE;
   DEFINE vVerif_val    INTEGER;
   DEFINE vExistTD		INTEGER;
   DEFINE vExistCelDisp INTEGER;
   DEFINE vExistCel		INTEGER;
   DEFINE vExistDispo	INTEGER;
   DEFINE vExistCte		INTEGER;
   DEFINE vExistCta		INTEGER;
   DEFINE vExistTC		INTEGER;

--InicializaciÃÂ³n de Variables
   LET vCod_ret 		= '00000';
   LET vMensaje 		= 'ERROR';
   LET vNumcte  		= '';
   LET vNumTel			= '';
   LET vApell1  		= '';
   LET vApell2  		= '';
   LET vNombre1 		= '';   
   LET vNombre2 		= '';
   LET vEstatusSer 		= '0';
   LET vCtaDig 			= 0;
   LET vCorreo			= '';
   LET vLong            = 0;
   LET vExistCred		= 0;
   LET l_Fecha			= '';
   LET vVerif_val       = 0;
   LET vExistTD			= 0;
   LET vExistCelDisp 	= 0;
   LET vExistCel		= 0;
   LET vExistDispo		= 0;
   LET vExistCte		= 0;
   LET vExistCta		= 0;
   LET vExistTC			= 0;
      
 -- SET DEBUG FILE TO '/informix/pdrh/sp_valida_servicio_pba_2.out';
 --              TRACE ON;  
			   
--INI
   BEGIN
	--Atrapa excepciÃÂ³n
    ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					LET vEstatusSer 	= '';
                    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
            END IF;
    END EXCEPTION;
	--
   -- insert into table_log values (today,1, '' pNumTel '');
	--Valida campos vacÃÂ­os
	IF( NVL(pNumTel,'')='' OR NVL(pFechaNac,'')='' OR NVL(pUdid,'')='' OR NVL(pImei,'')='')THEN
		LET vCod_ret = '00006';
		LET vMensaje = 'FALTAN DATOS';
		   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
	END IF;
	--
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Longitud (ParÃÂ¡metro)
    LET vLong = LENGTH(pCtaTjCte);
	--Fecha de Hoy
	LET l_Fecha = today;
--------------------------------------------------------------------	
	--Valida que el telefono este dado de alta en bancoppel
	SELECT COUNT(numcte) 
	INTO vExistCte 
	FROM bdinteg:si_telefonos_actual b 
	WHERE status_tel = 'A' 
	AND tipo_tel = '2' 
	AND telefono=pNumTel;
	
	IF vExistCte = 1 THEN
	--obtiene los datos del cliente
	  SELECT a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2
	  INTO vNumcte, vApell1, vApell2, vNombre1, vNombre2
	  FROM bdinteg:si_cliente a, bdinteg:si_telefonos_actual b, bdinteg:si_ctepf c 
	  WHERE a.numcte=b.numcte  
	  AND a.numcte = c.numcte 
	  AND b.status_tel = 'A'  
	  AND b.tipo_tel = '2'  
	  AND b.telefono=pNumTel 
	  AND c.fecha_nac=pFechaNac;
		
	  SELECT correo_elec 
	  INTO vCorreo 
	  FROM  bdinteg:si_correos  
	  WHERE  numcte = vNumcte 
	  AND status_correo ='A' 
	  AND tipo_correo ='1';
   	END IF;
--------------------------------------------------------------------
	/*Valida cuenta*/
	IF (vLong=11) OR (vLong=12) THEN
	--Bloque Valida que el telefono este dado de alta en bancoppel
		IF (vLong=11) OR (vLong=12) AND  vExistCte = 1 THEN
			SELECT COUNT(cuenta) 
			INTO vExistCta 
			FROM bdicheq:sc_maechq 
			WHERE cuenta=pCtaTjCte 
			AND num_cte=vNumcte;
			
			IF vExistCta = 0 THEN 
				SELECT COUNT(num_credito) 
				INTO vExistCred 
				FROM bdicred:sd_maecred 
				WHERE num_credito=pCtaTjCte 
				AND numcte = vNumcte;
					
				IF vExistCred = 0 THEN 
					LET vCod_ret = '00004';
					LET vMensaje = 'ERROR CONSULTA DATOS CTA';
				END IF;	
	        END IF;
		END IF;	
	--	
		SELECT COUNT(cuenta) 
	    INTO vExistCta 
	    FROM bdicheq:sc_maechq 
	    WHERE cuenta=pCtaTjCte;
		
		IF vExistCta = 0 THEN 
		    SELECT COUNT(num_credito) 
		    INTO vExistCred 
		    FROM bdicred:sd_maecred 
		    WHERE num_credito=pCtaTjCte;
		    IF vExistCred = 0 THEN 
		      LET vCod_ret 	= '00004';
	          LET vMensaje = 'ERROR CONSULTA DATOS CTA';
		      RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
	        ELSE
				SELECT numcte 
				INTO vNumcte 
				FROM  bdicred:sd_maecred 
				WHERE num_credito=pCtaTjCte;
		  		  
				SELECT COUNT(DISTINCT(imei||udid)) 
				INTO vVerif_val 
				FROM bdibpi:bpi_registro_bex 
				WHERE fecha_registro >= l_Fecha 
				AND num_cliente = vNumcte;
		      
				IF vVerif_val >= 2 THEN 
					LET vCod_ret = '00008';
					LET vMensaje = 'LIMITE DE REGISTROS';
					RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
				ELSE
					SELECT COUNT(DISTINCT(num_cliente))
					INTO vVerif_val 
					FROM bdibpi:bpi_registro_bex 
					WHERE fecha_registro >= l_Fecha 
					AND imei = pImei 
					AND udid = pUdid;
			   
					IF vVerif_val >= 2 THEN 
						LET vCod_ret = '00008';
						LET vMensaje = 'LIMITE DE REGISTROS';
						RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';					
					END IF;	
				END IF;
		    END IF;	   
		END IF;
	ELIF (vLong=9) THEN
	--Bloque Valida que el telefono este dado de alta en bancoppel
	    IF (vLong=9) AND vExistCte = 1 THEN 
			SELECT COUNT(numcte) 
			INTO vExistCte 
			FROM bdinteg:si_cliente 
			WHERE numcte=pCtaTjCte 
			AND numcte=vNumcte;
            IF vExistCte = 0 THEN
				LET vCod_ret = '00004';
				LET vMensaje = 'ERROR CONSULTA DATOS CTE';
			END IF;
        ELSE 
			LET vCod_ret = '00004';
			lET vMensaje = 'ERROR CONSULTA DATOS CTE';
		END IF;
	---------------------------------------------------------------	 	
	  	SELECT COUNT(distinct(udid)) 
		INTO vVerif_val 
		FROM bdibpi:bpi_registro_bex 
		WHERE num_cliente = pCtaTjCte 
		AND  fecha_registro >= l_Fecha;
		IF vVerif_val >= 2 THEN 
			LET vCod_ret = '00008';
			LET vMensaje = 'LIMITE DE REGISTROS';
			RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
		ELSE 
			SELECT COUNT(DISTINCT(num_cliente)) 
			INTO vVerif_val 
			FROM bdibpi:bpi_registro_bex 
			WHERE fecha_registro >= l_Fecha  
			AND imei = pImei 
			AND udid = pUdid;
		  
			IF vVerif_val >= 2 THEN 
				LET vCod_ret = '00008';
				LET vMensaje = 'LIMITE DE REGISTROS';
				RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';					
			END IF;	
		END IF;			
	ELIF (vLong=16) THEN  /*Valida tarjeta*/
	--Bloque Valida que el telefono este dado de alta en bancoppel
	    IF (vLong=16) AND vExistCte = 1 THEN 
			SELECT COUNT(num_tarjeta) 
			INTO vExistTD 
			FROM bdicheq:sc_tarjeta 
			WHERE num_tarjeta=pCtaTjCte 
			AND numcte = vNumcte;
			
			IF vExistTD = 0 THEN 
				SELECT COUNT(num_tarjeta) 
				INTO vExistTC 
				FROM bdicred:sd_tarjeta 
				WHERE num_tarjeta=pCtaTjCte 
				AND numcte = vNumcte;
			
				IF vExistTC = 0 THEN 
					LET vCod_ret 	= '00004';
					LET vMensaje = 'ERROR CONSULTA DATOS TAR';
				END IF;	
			END IF;	
		ELIF  (vLong=16) AND vExistCte = 0 THEN 
			LET vCod_ret 	= '00005';
			LET vMensaje = 'CELULAR NO REGISTRADO EN BCPPEL';
		END IF;	
	--		
		IF vExistTD = 0 THEN 
			SELECT COUNT(num_tarjeta) 
			INTO vExistTC 
			FROM bdicred:sd_tarjeta 
			WHERE num_tarjeta=pCtaTjCte;
			
			IF vExistTC = 0 THEN 
				LET vCod_ret 	= '00004';
				LET vMensaje = 'ERROR CONSULTA DATOS TAR';
			ELSE
				SELECT numcte 
				INTO vNumcte 
				FROM bdicred:sd_tarjeta  
				WHERE num_tarjeta=pCtaTjCte;
			
				SELECT COUNT(DISTINCT(imei||udid)) 
				INTO vVerif_val 
				FROM bdibpi:bpi_registro_bex 
				WHERE fecha_registro >= l_Fecha
				AND imei = pImei  
				AND num_cliente = vNumcte;
			
				IF vVerif_val >= 2 THEN 
					LET vCod_ret = '00008';
					LET vMensaje = 'LIMITE DE REGISTROS';
					RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
				ELSE 
					SELECT COUNT(DISTINCT(num_cliente)) 
					INTO vVerif_val 
					FROM bdibpi:bpi_registro_bex 
					WHERE fecha_registro >= l_Fecha  
					AND imei = pImei 
					AND udid = pUdid;
			  
					IF vVerif_val >= 2 THEN 
						LET vCod_ret = '00008';
						LET vMensaje = 'LIMITE DE REGISTROS';
						RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';					
					END IF;	
				END IF;				
			END IF;	
		ELSE
			SELECT COUNT(DISTINCT(imei||udid)) 
			INTO vVerif_val 
			FROM bdibpi:bpi_registro_bex 
			WHERE fecha_registro >= l_Fecha 
			AND num_cliente = vNumcte;
		
			IF vVerif_val >= 2 THEN 
				LET vCod_ret = '00008';
				LET vMensaje = 'LIMITE DE REGISTROS';
				RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
			ELSE 
				SELECT COUNT(DISTINCT(num_cliente))
				INTO vVerif_val 
				FROM bdibpi:bpi_registro_bex 
				WHERE fecha_registro >= l_Fecha  
				AND imei = pImei 
				AND udid = pUdid;
			
				IF vVerif_val >= 2 THEN 
					LET vCod_ret = '00008';
					LET vMensaje = 'LIMITE DE REGISTROS';
					RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';					
				END IF;	
			END IF;				
		END IF;				
	ELSE
	  LET vCod_ret 	= '00004';
	  LET vMensaje	 = 'ERROR CONSULTA DATOS';
	  RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';
	END IF;		

---------------------------------------------------------------------------------------
--Valida nÃÂºmero celular y dispositivo para el servicio BanCoppel Express
	SELECT COUNT(no_celular) 
	INTO vExistCel 
	FROM bdibpi:bpi_registro_bex 
	WHERE no_celular = pNumTel 
	AND estatus_servicio <> '2';
	  
		IF vExistCel > 0 THEN 
			SELECT COUNT(no_celular) 
			INTO vExistCelDisp 
			FROM bdibpi:bpi_registro_bex 
			WHERE no_celular = pNumTel 
			AND imei=pImei 
			AND udid=pUdid 
			AND estatus_servicio <> '2'; 
		
			IF vExistCelDisp > 0 THEN 
				SELECT COUNT(estatus_servicio) 
				INTO vEstatusSer 
				FROM bdibpi:bpi_registro_bex 
				WHERE no_celular = pNumTel 
				AND imei=pImei 
				AND udid=pUdid
				AND estatus_servicio <> '2';
				LET vCod_ret = '00003';
				LET vMensaje = 'NUMERO Y DISPOSITIVO ACTIVO';
			ELSE
				SELECT {+INDEX(bdibpi:bpi_registro_bex idx_udidImei)} COUNT(imei) 
				INTO vExistDispo 
				FROM bdibpi:bpi_registro_bex 
				WHERE imei<>pImei 
				AND udid<>pUdid 
				AND estatus_servicio <> '2';
			
				IF vExistDispo > 0 THEN 
					SELECT estatus_servicio 
					INTO vEstatusSer 
					FROM bdibpi:bpi_registro_bex 
					WHERE imei=pImei 
					AND udid=pUdid 
					AND estatus_servicio <> '2';
					LET vCod_ret = '00002';
					LET vMensaje = 'DISPOSITIVO ACTIVO';
				ELSE
					LET vCod_ret = '00001';
					LET vMensaje = 'NUMERO TELEFONICO CON BEX';
				END IF
			END IF
		END IF
---------------------------------------------------------------------------------------
	IF (NVL(vNumcte,'') <> '') AND vCod_ret <> '00004' THEN
		IF vCod_ret = '00000' THEN
			LET vMensaje 	= 'CORRECTO';
		END IF			
	
		IF NVL(vCorreo,'') = '' THEN 
			LET vCod_ret = '00007';
			LET vMensaje = 'CLIENTE SIN CORREO';
		END IF			
	
		RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	ELSE 
		LET vCod_ret = '00004';
		LET vMensaje = 'ERROR CONSULTA DATOS CLIENTE';
		RETURN vCod_ret,vMensaje,'', '', '', '', '', '', '', '';  
	END IF
	
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	
	END
END PROCEDURE;