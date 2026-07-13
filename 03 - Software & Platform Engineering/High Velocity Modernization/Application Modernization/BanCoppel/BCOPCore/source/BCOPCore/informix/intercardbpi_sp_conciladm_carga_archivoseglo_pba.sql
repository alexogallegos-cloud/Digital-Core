CREATE PROCEDURE "informix".sp_conciladm_carga_archivoseglo_pba(pempresa char(3),psFechaconciliacion DATE)
        RETURNING VARCHAR(5), VARCHAR(255);

--Definicion de variables
    DEFINE chrcodret   char(6);
    DEFINE intcodret   INT;
    DEFINE iSamErr		  INTEGER;
    DEFINE cVarDataErr	  VARCHAR(64);

    DEFINE vsql char(210);
	

	DEFINE vs_Nomarchivo VARCHAR(50);
	DEFINE vs_Nomarchivo_prs VARCHAR(50);
	DEFINE expresion CHAR(5);
	DEFINE expresion1 CHAR(5);
	DEFINE expresion2 VARCHAR(255);
	DEFINE vpath VARCHAR(90);
    DEFINE v_numcuenta VARCHAR(13);
    DEFINE v_numtarjeta VARCHAR(16);
    DEFINE fecha_archivo DATE;
    DEFINE vfecha_depura DATE;
	DEFINE vfechaconciliacion_max DATE;
	
	DEFINE v_numtarjeta1 VARCHAR(16);
	DEFINE v_numcuenta1 VARCHAR(13);
	DEFINE v_Nomarchivo1 VARCHAR(50);
	DEFINE v_monto DECIMAL(18,2);
	DEFINE v_secuencia VARCHAR(6);
	DEFINE v_tipo_mov VARCHAR(2);
	DEFINE v_fecha_mov DATE;
	
	DEFINE vnro_tarjeta_e VARCHAR(16);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;

    --Inicializacion de variables
    LET chrcodret  = '000';
    LET vsql = '';

	LET vs_Nomarchivo='';
	LET vs_Nomarchivo_prs='';
	LET expresion ='';
	LET expresion1 ='';
    LET expresion2 ='';
    LET vpath = '';
	LET v_numcuenta = '';
    LET v_numtarjeta = '';
	LET vfechaconciliacion_max = '';
	
	LET v_numtarjeta1='';
	LET v_numcuenta1='';
	LET v_Nomarchivo1='';
	LET v_secuencia='';
	LET v_tipo_mov='';
		
	
	LET vnro_tarjeta_e = '';
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

BEGIN

    ON EXCEPTION SET intcodret,iSamErr, cVarDataErr
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "sp_conciladm_carga_archivoseglo.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	
	SELECT NVL(fecha_hoy,'01/01/1999')::DATE - 7 units DAY
      INTO vfecha_depura
      FROM bdinteg:si_fechas; 

	  
	--Inicia Borrado conciladm_eglopos por vfecha_depura
	FOREACH WITH HOLD
		SELECT {+MULTI_INDEX(conciladm_eglopos idx04conciladm_eglopos idx05conciladm_eglopos)} nro_tarjeta_e
		INTO vnro_tarjeta_e
		FROM intercard:conciladm_eglopos
		WHERE fecha_mov_e < vfecha_depura OR fecha_mov_s < vfecha_depura

		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		DELETE FROM intercard:conciladm_eglopos 
		WHERE fecha_mov_e < vfecha_depura OR fecha_mov_s < vfecha_depura
		AND nro_tarjeta_e = vnro_tarjeta_e;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH
	
	IF vabierto = '1' THEN
		COMMIT WORK;
	END IF		  
	
	  
    DELETE {+INDEX(conciladm_archegloposacum idx01conciladm_archegloposacum)} FROM conciladm_archegloposacum WHERE fecha_mov < vfecha_depura OR fecha_mov = psFechaconciliacion;
    DELETE {+INDEX(conciladm_sifegloposacum idx01conciladm_sifegloposacum)} FROM conciladm_sifegloposacum WHERE fecha_mov < vfecha_depura OR fecha_mov = psFechaconciliacion;

	
	LET vnro_tarjeta_e  = '';
	LET vabierto   			= '0';
	LET vcontador3 			= 0;
	
	--Inicia Borrado conciladm_eglopos por fecha_mov_e
	FOREACH WITH HOLD
		SELECT nro_tarjeta_e
		INTO vnro_tarjeta_e
		FROM intercard:conciladm_eglopos
		WHERE fecha_mov_e = psFechaconciliacion

		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		DELETE FROM intercard:conciladm_eglopos 
		WHERE fecha_mov_e = psFechaconciliacion
		AND nro_tarjeta_e = vnro_tarjeta_e;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH
	
	IF vabierto = '1' THEN
		COMMIT WORK;
	END IF		
	
		
	LET vnro_tarjeta_e  = '';
	LET vabierto   			= '0';
	LET vcontador3 			= 0;
	
	--Inicia Borrado conciladm_eglopos por fecha_mov_s
	FOREACH WITH HOLD
		SELECT nro_tarjeta_e
		INTO vnro_tarjeta_e
		FROM intercard:conciladm_eglopos
		WHERE fecha_mov_s = psFechaconciliacion

		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		DELETE FROM intercard:conciladm_eglopos 
		WHERE fecha_mov_s = psFechaconciliacion
		AND nro_tarjeta_e = vnro_tarjeta_e;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH
	
	IF vabierto = '1' THEN
		COMMIT WORK;
	END IF
	
		
    
	SELECT TRIM(valor) INTO vpath FROM intercard:param_conciliacionauto WHERE keyx= 1; --'REP_EGLOBAL_AIX'
	
	CREATE TEMP TABLE tmp_archivos_ant(		
        nom_archivo           CHAR(30),		 
		archivoorigen 		  CHAR(3)		
		);
	   
	INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
		             VALUES("BCPLVND_" ||LPAD(DAY(psFechaconciliacion),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||YEAR(psFechaconciliacion)|| "",'VND');
	INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
		             VALUES("BCPLVNC_" ||LPAD(DAY(psFechaconciliacion),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||YEAR(psFechaconciliacion)|| "",'VNC'); 
	INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
		             VALUES("BCPLVID_" ||LPAD(DAY(psFechaconciliacion),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||YEAR(psFechaconciliacion)|| "",'VID'); 
	INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
		             VALUES("BCPLVIC_" ||LPAD(DAY(psFechaconciliacion),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||YEAR(psFechaconciliacion)|| "",'VIC'); 		

	FOREACH WITH HOLD
     SELECT nom_archivo 
	   INTO vs_Nomarchivo
	   FROM tmp_archivos_ant
       ORDER BY nom_archivo DESC

		LET vs_Nomarchivo = TRIM(vs_Nomarchivo) ||'.txt';
		
		TRUNCATE TABLE intercard:conciladm_archeglo; 
			 
		EXECUTE  PROCEDURE sp_conciladm_paserarchivo (vpath,trim(vs_Nomarchivo)) INTO expresion,expresion1;
		
		IF TRIM(expresion) <> '00000' THEN
			
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tmp_archivos_ant') THEN	
				DROP TABLE tmp_archivos_ant;
			END IF
			
			LET vsql = 'rm -f ' || TRIM(vpath) || "/*.prs" ;
			SYSTEM vsql;			
			
			RETURN expresion,'El Archivo: ' || vs_Nomarchivo || ' No Existe';
			
		ELSE
			LET vs_Nomarchivo_prs = TRIM(vs_Nomarchivo) || '.prs';
		END IF
		
		--EXECUTE PROCEDURE sp_con_buscararchivo(vpath,trim(vs_Nomarchivo_prs)) INTO expresion,expresion1;
			 
		--LET expresion1 = TRIM(expresion1);
			 
		IF TRIM(expresion1) <> 'F' THEN

			LET chrcodret = '000'; -- NO HABIA INFORMACION Y SE CARGO LA INFORMACION
			LET vsql = 'echo "LOAD FROM ''' || vpath || '/' || TRIM(vs_Nomarchivo_prs) || ''' DELIMITER ' || '''|''' || ' INSERT INTO conciladm_archeglo" >' || vpath || '/cargaarchivos.sql';
			SYSTEM vsql;

			LET vsql = '';

			LET vsql = 'dbaccess intercard ' || vpath || '/cargaarchivos.sql';
			SYSTEM vsql;

			DELETE FROM intercard:conciladm_archeglo WHERE registro matches 'HEADER*' or registro  matches 'TRAILER 0*';
			DELETE FROM intercard:conciladm_archegloposacum WHERE nomarchivo = UPPER(TRIM(vs_Nomarchivo));
			DELETE FROM intercard:conciladm_eglopos WHERE nomarchivo_e = UPPER(TRIM(vs_Nomarchivo));

			IF vs_Nomarchivo LIKE '%VND_%' OR vs_Nomarchivo LIKE '%VNC_%'  THEN
		
					LET vnro_tarjeta_e  = '';
					LET vabierto   			= '0';
					LET vcontador3 			= 0;
			-- Inicia Prueba
				FOREACH WITH HOLD
					SELECT TRIM(SUBSTRING (registro FROM 5 FOR 16 )) AS numtarjeta,
					   nvl(b.numcuenta,'') AS numcuenta,
	                   UPPER(TRIM(vs_Nomarchivo)),
					  (SUBSTRING (registro FROM 40 FOR 10 )||'.'||SUBSTRING (registro FROM 50 FOR 2 ))::DECIMAL(18,2) AS monto,
					   TRIM(SUBSTRING (registro FROM 210 FOR 6 )) AS secuencia,
					   TRIM(SUBSTRING (registro FROM 37 FOR 2 )) AS tipo_mov,
					   psFechaconciliacion AS fecha_mov
					   INTO v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov
				   FROM intercard:conciladm_archeglo a LEFT JOIN intercard:tarjetacuenta b
                   ON b.numtarjeta = TRIM(SUBSTRING (registro FROM 5 FOR 16 ))

					IF vcontador3 = 0 THEN
						BEGIN WORK;
						LET vabierto = '1'; 
					END IF
					
					INSERT INTO intercard:conciladm_eglopos(nro_tarjeta_e,num_cuenta_cred_e,nomarchivo_e,importe_e,secuencia_e,tipo_mov_e,fecha_mov_e) 
					VALUES (v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov);
					
					LET vcontador3 = vcontador3 + 1;
					
					IF vcontador3 = 5000 THEN
						LET vabierto = '0';
						LET vcontador3 = 0;
						COMMIT WORK;
					END IF
					
				END FOREACH
				
				IF vabierto = '1' THEN
					COMMIT WORK;
				END IF
				
				
			ELIF vs_Nomarchivo LIKE '%VID_%' OR vs_Nomarchivo LIKE '%VIC_%'THEN
					
					LET vnro_tarjeta_e  = '';
					LET vabierto   			= '0';
					LET vcontador3 			= 0;
			-- Inicia Prueba
				FOREACH WITH HOLD
					SELECT TRIM(SUBSTRING (registro FROM 5 FOR 16 )) AS numtarjeta,
					   nvl(b.numcuenta,'') AS numcuenta,
					   UPPER(TRIM(vs_Nomarchivo)),
					  (SUBSTRING (registro FROM 40 FOR 10 )||'.'||SUBSTRING (registro FROM 50 FOR 2 ))::DECIMAL(18,2) AS monto,
					   TRIM(SUBSTRING (registro FROM 210 FOR 6 )) AS secuencia,
					   TRIM(SUBSTRING (registro FROM 37 FOR 2 )) AS tipo_mov,
					   psFechaconciliacion AS fecha_mov
					   INTO v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov
				   FROM intercard:conciladm_archeglo a LEFT JOIN intercard:tarjetacuenta b
                   ON b.numtarjeta = TRIM(SUBSTRING (registro FROM 5 FOR 16 ))

					IF vcontador3 = 0 THEN
						BEGIN WORK;
						LET vabierto = '1'; 
					END IF
					
					INSERT INTO intercard:conciladm_eglopos(nro_tarjeta_e,num_cuenta_cred_e,nomarchivo_e,importe_e,secuencia_e,tipo_mov_e,fecha_mov_e) 
					VALUES (v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov);
					
					LET vcontador3 = vcontador3 + 1;
					
					IF vcontador3 = 5000 THEN
						LET vabierto = '0';
						LET vcontador3 = 0;
						COMMIT WORK;
					END IF
					
				END FOREACH
				
				IF vabierto = '1' THEN
					COMMIT WORK;
				END IF
													
			ELIF vs_Nomarchivo LIKE '%PNC%' THEN
			
					LET vnro_tarjeta_e  = '';
					LET vabierto   			= '0';
					LET vcontador3 			= 0;
			-- Inicia Prueba
				FOREACH WITH HOLD
					SELECT TRIM(SUBSTRING (registro FROM 5 FOR 16 )) AS numtarjeta,
					   nvl(b.numcuenta,'') AS numcuenta,
					   UPPER(TRIM(vs_Nomarchivo)),
					  (SUBSTRING (registro FROM 40 FOR 10 )||'.'||SUBSTRING (registro FROM 50 FOR 2 ))::DECIMAL(18,2) AS monto,
					   TRIM(SUBSTRING (registro FROM 104 FOR 31 )) AS secuencia,
					   TRIM(SUBSTRING (registro FROM 37 FOR 2 )) AS tipo_mov,
					   psFechaconciliacion AS fecha_mov
					   INTO v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov
				   FROM intercard:conciladm_archeglo a LEFT JOIN intercard:tarjetacuenta b
                   ON b.numtarjeta = TRIM(SUBSTRING (registro FROM 5 FOR 16 ))

					IF vcontador3 = 0 THEN
						BEGIN WORK;
						LET vabierto = '1'; 
					END IF
					
					INSERT INTO intercard:conciladm_eglopos(nro_tarjeta_e,num_cuenta_cred_e,nomarchivo_e,importe_e,secuencia_e,tipo_mov_e,fecha_mov_e) 
					VALUES (v_numtarjeta1, v_numcuenta1, v_Nomarchivo1, v_monto, v_secuencia, v_tipo_mov, v_fecha_mov);
					
					LET vcontador3 = vcontador3 + 1;
					
					IF vcontador3 = 5000 THEN
						LET vabierto = '0';
						LET vcontador3 = 0;
						COMMIT WORK;
					END IF
					
				END FOREACH
				
				IF vabierto = '1' THEN
					COMMIT WORK;
				END IF
			
			END IF;

			IF vs_Nomarchivo LIKE 'BCPLV%' OR vs_Nomarchivo LIKE 'BCPLP%' THEN

				LET fecha_archivo = MDY(SUBSTR( SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 7 , 8),3,2),
						                SUBSTR( SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 7 , 8),1,2),  
						                SUBSTR( SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 7 , 8),5,4));

			ELIF vs_Nomarchivo LIKE 'BCPL_ATM%' THEN

                LET fecha_archivo =  MDY(SUBSTR(SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 5,6),3,2), 
                                         SUBSTR(SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 5,6),1,2), 
                                         '20' || SUBSTR(SUBSTR(TRIM(vs_Nomarchivo),(LENGTH(TRIM(vs_Nomarchivo))- 4) - 5,6),5,2));
			END IF

			INSERT INTO intercard:conciladm_archegloposacum(nomarchivo,num_reg_ins,importe,fecha_archivo,fecha_mov) 
			SELECT nomarchivo_e,COUNT(*),SUM(importe_e),fecha_archivo,fecha_mov_e
              FROM intercard:conciladm_eglopos
             WHERE nomarchivo_e = UPPER(TRIM(vs_Nomarchivo))
             GROUP BY 1,4,5;

		END IF;
		
		UPDATE STATISTICS MEDIUM FOR TABLE intercard:conciladm_eglopos;

	END FOREACH;

    EXECUTE PROCEDURE "informix".sp_conciladm_concileglo(pempresa,psFechaconciliacion) INTO chrcodret,expresion2;

	IF TRIM(chrcodret) = '000' THEN 
		EXECUTE PROCEDURE "informix".sp_conciladm_concileglounl(pempresa,psFechaconciliacion) INTO chrcodret,expresion2;
	END IF
     
	DROP TABLE tmp_archivos_ant;
	  
RETURN chrcodret,expresion2;
END;
END PROCEDURE;