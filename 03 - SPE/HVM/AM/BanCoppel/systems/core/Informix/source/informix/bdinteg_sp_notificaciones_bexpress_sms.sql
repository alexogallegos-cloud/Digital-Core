CREATE PROCEDURE "informix".sp_notificaciones_bexpress_sms()

	RETURNING 
		  CHAR(5)       as vcodret1;
		  
	DEFINE vNum_cte 	CHAR(20);
    DEFINE vCorreo_elec CHAR(100);
	DEFINE vTelefono 	CHAR(13);
	DEFINE vMaxSMS		INTEGER;
	DEFINE vSMSenviados	INTEGER;
	DEFINE enviados		INTEGER;

	DEFINE vfecha_insert DATETIME YEAR TO SECOND;
	
	DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	
	LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	
	LET vNum_cte = '';
    LET vCorreo_elec = '';
	LET vTelefono = '';
	LET vMaxSMS = 0;
	LET vSMSenviados = 0;
	LET enviados = 0;
	
	LET vfecha_insert = EXTEND(MDY(01,01,1900), YEAR to SECOND) + 00 UNITS HOUR + 00 UNITS MINUTE + 00 UNITS SECOND;
	
	BEGIN
	
    ON EXCEPTION SET sql_err, isam_err, desc_err

        --SET DEBUG FILE TO "/informix/LIP/sp_notificaciones_bexpress_sms.out";
        --TRACE ON;

        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;

            RETURN vcodret1;
			
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/ragomez/bancoppel_express/sp_notificaciones_bexpress_sms.out";
	--TRACE ON;

	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--Parametro de limite de mensajes
	SELECT valor
	INTO vMaxSMS
	FROM bdinteg:"informix".si_param
	WHERE cod_param = '464';

	--Parametro de mensajes ya enviados
	SELECT valor
	INTO vSMSenviados
	FROM bdinteg:"informix".si_param
	WHERE cod_param = '465';
	
	--Se reinicia el valor de mensajes enviados cuando es el primer dia de cada mes
	IF(DAY(CURRENT::DATE) = '1') THEN
		LET vSMSenviados = 0;
	END IF;

	--Usuarios banca por internet
	DROP TABLE IF EXISTS tblUsuariosBPI;
	SELECT {+MULTI_INDEX ("informix".si_bpiusuarios)} numcte
    FROM bdinteg:informix.si_bpiusuarios
    WHERE id_status IN ('30','40','50')
    AND servicio = '1'
	INTO TEMP tblUsuariosBPI with no log;

	---SET pdqpriority 5;
	BEGIN;
		CREATE INDEX "informix".idx_usuariosBPI ON tblUsuariosBPI(numcte) ONLINE;
	COMMIT;
	
	---SET pdqpriority 0;
	UPDATE STATISTICS MEDIUM FOR TABLE tblUsuariosBPI;
	
	--Usuarios bancoppel express
	DROP TABLE IF EXISTS tblUsuariosBEX;
	SELECT num_cliente
    FROM bdibpi:bpi_registro_bex
    WHERE servicio = 'activo'
	INTO TEMP tblUsuariosBEX with no log;

	--SET pdqpriority 5;
	BEGIN;
		CREATE INDEX "informix".idx_usuariosBEX ON tblUsuariosBEX(num_cliente) ONLINE;
	COMMIT;

	---SET pdqpriority 0;
	UPDATE STATISTICS MEDIUM FOR TABLE tblUsuariosBEX;


	---Cuentas captaciÃ³n, clientes con correo valido
	DROP TABLE IF EXISTS tblUsuariosMAIL;
	SELECT chq.num_cte, mail.valido, mail.correo_elec
    FROM bdinteg:"informix".si_correos mail
    INNER JOIN bdicheq:"informix".sc_maechq chq
            ON mail.numcte = chq.num_cte
    INNER JOIN bdicheq:"informix".sc_maenoc noc
            ON noc.cuenta = chq.cuenta
	INNER JOIN bdicheq:"informix".sc_encabezado2_edocta_factelect sldo
			ON chq.cuenta = sldo.num_cuenta			
	---correo valido
    WHERE mail.valido = '1'
    AND mail.status_correo = 'A'
	---cta. activa
    AND chq.status_cta IN ('1','3')
	--Saldo promedio
	AND sldo.saldopromedio BETWEEN 200.01 AND 10000
	---mesiversario
	AND DAY(noc.fecha_alta) = DAY(CURRENT::DATE-1)
	AND noc.fecha_alta <> (CURRENT::DATE-1) -- fecha de alta diferente al dia anterior
	---movimiento ultimos 12 meses
	AND chq.fec_ult_mov BETWEEN ADD_MONTHS((CURRENT::DATE-1),-12) AND (CURRENT::DATE-1)
	GROUP BY chq.num_cte, mail.valido, mail.correo_elec
	INTO TEMP tblUsuariosMAIL with no log;
    
	---SET pdqpriority 5;
	BEGIN;
		CREATE INDEX "informix".idx_usuariosMAIL ON tblUsuariosMAIL(num_cte) ONLINE;
	COMMIT;
    
	---SET pdqpriority 0;
	UPDATE STATISTICS MEDIUM FOR TABLE tblUsuariosMAIL;
	
	---Cuentas captaciÃ³n, clientes con numero de celular valido
	FOREACH
		
		SELECT chq.num_cte, tel.telefono
		INTO vNum_cte, vTelefono
		FROM bdicheq:"informix".sc_maechq chq
		
			INNER JOIN bdicheq:"informix".sc_maenoc noc
					ON chq.cuenta = noc.cuenta
			INNER JOIN bdinteg:"informix".si_telefonos tel
					ON chq.num_cte = tel.numcte
			INNER JOIN bdicheq:"informix".sc_encabezado2_edocta_factelect sldo
					ON chq.cuenta = sldo.num_cuenta					
				
			LEFT OUTER JOIN tblUsuariosBPI bpi
					ON chq.num_cte = bpi.numcte
			LEFT OUTER JOIN tblUsuariosBEX bex
					ON chq.num_cte = bex.num_cliente
			LEFT OUTER JOIN tblUsuariosMAIL mail
					ON chq.num_cte = mail.num_cte
					
		---cta. activa
		WHERE chq.status_cta IN ('1','3')
		---telefono valido
		AND tel.cofetel = 'V'
		AND tel.tipo_tel = '2'
		AND tel.status_tel = 'A'
		--Saldo promedio
		AND sldo.saldopromedio BETWEEN 200.01 AND 10000
		---mesiversario
		AND DAY(noc.fecha_alta) = DAY(CURRENT::DATE-1)
		AND noc.fecha_alta <> (CURRENT::DATE-1) -- fecha de alta diferente al dia anterior
		---movimento ultimos 12 meses
		AND chq.fec_ult_mov BETWEEN ADD_MONTHS((CURRENT::DATE-1),-12) AND (CURRENT::DATE-1)
		---no usuario bpi
		AND bpi.numcte IS NULL
		---no usuario bcoppel express
		AND bex.num_cliente IS NULL
		---sin correo valido
		AND mail.num_cte IS NULL
		GROUP BY chq.num_cte, tel.cofetel, tel.telefono
		
		
		IF (vSMSenviados < vMaxSMS) THEN
			
			SELECT COUNT(*) INTO enviados FROM si_notificaciones_bancoppel_express WHERE num_cte = vNum_cte AND DATE(fecha_insert) = DATE(CURRENT);
			
			IF enviados = 0 THEN
		
				INSERT INTO si_notificaciones_bancoppel_express (num_cte, correo_elec, telefono, fecha_insert, procesado, fecha_procesado)
				VALUES(vNum_cte, NULL, vTelefono ,CURRENT, NULL, NULL);
		
				LET vSMSenviados = vSMSenviados + 1;
				
			END IF;
		ELSE
			LET vcodret1 = '00001';
		END IF;
	
	END FOREACH;
	
	FOREACH 
	
		SELECT num_cte, correo_elec, telefono, fecha_insert
		INTO vNum_cte, vCorreo_elec, vTelefono, vfecha_insert
		FROM si_notificaciones_bancoppel_express
		WHERE procesado IS NULL

		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PROD_SMS','BE2_CAPTA',vNum_cte,'','','2','','','','','','','','','','','','',1,0,0,0,0,'','')
		--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PORTAL_SMS','BE2_CAPTA','000000000','','','2','','','','','','','','','','','','',1,0,0,0,0,'','')
		INTO vcodret1;
	
		IF(vcodret1 = '00000') THEN
		
			UPDATE si_notificaciones_bancoppel_express
			SET procesado = '1',
			fecha_procesado = CURRENT
			WHERE num_cte = vNum_cte
			AND fecha_insert = vfecha_insert;
			
		END IF
		
	END FOREACH;
	
		
	UPDATE bdinteg:"informix".si_param
	SET valor = vSMSenviados
	WHERE cod_param = '465';

	RETURN vcodret1;
	
	END;
	
END PROCEDURE;