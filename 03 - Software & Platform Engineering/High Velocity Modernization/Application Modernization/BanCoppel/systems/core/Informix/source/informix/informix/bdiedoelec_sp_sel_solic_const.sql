CREATE PROCEDURE "informix".sp_sel_solic_const (pempresa char(3) ) 
    RETURNING CHAR(5) AS v_sCodRet, CHAR(20) AS v_numcte, CHAR(20) AS v_cuenta, CHAR(4) AS v_ejercicio, CHAR(100) AS vCorreoElec, 
	          CHAR(8) AS vpasselec, CHAR(70) AS v_nomcte, CHAR (20) AS v_nom_producto
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
		
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_ejercicio          CHAR(4);
	DEFINE v_nomcte 			CHAR(70);
	DEFINE v_nombre1 			CHAR(26);
	DEFINE v_nombre2 			CHAR(26);
	DEFINE v_apell_paterno 		CHAR(26);
	DEFINE v_apell_materno 		CHAR(26);
	DEFINE v_nom_producto 		CHAR(20);
	DEFINE v_fecha_hoy			DATE;
	
	DEFINE vcodret1 			CHAR(5);
	DEFINE vCorreoElec      	CHAR(100);
    DEFINE vTipoCorreo      	SMALLINT;
    DEFINE vStatusCorreo    	CHAR(1);
	DEFINE vpasselec			CHAR(8);
	
	DEFINE vcodret2 			CHAR(5);
	DEFINE vnumcte2				CHAR(20);
	DEFINE vpassfirstpart		CHAR(4);
	DEFINE vpasssecpart			CHAR(4);
	
	DEFINE v_seed               VARCHAR(100);
	
		
    --SET DEBUG FILE TO  "sp_sel_solic_const.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_ejercicio = '';
	LET v_nomcte = '';
	
	
	LET vcodret1 = '';
	LET vCorreoElec = '';
    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';
	LET vpasselec = '';
	LET v_nombre1 = '';
	LET v_nombre2 = '';
	LET v_apell_paterno = '';
	LET v_apell_materno = '';
	LET v_nom_producto = 'CONSTANCIA DE ISR';
	LET v_fecha_hoy = TODAY;
	
	LET vcodret2 = '';
	LET vnumcte2 = '';
	LET vpassfirstpart = '';
	LET vpasssecpart = '';
	LET v_seed = '';
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet,'','','','','','','';
            END IF;
        END EXCEPTION;
		
		SELECT fecha_hoy
		  INTO v_fecha_hoy 
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
				
		
		FOREACH WITH HOLD 
			SELECT b.numcte,b.cuenta,b.ejercicio 
		      INTO v_numcte,v_cuenta,v_ejercicio
			  FROM bdiedoelec:edelec_solic_const a, bdiedoelec:edelec_log_solic_const b 
			 WHERE a. numcte = b. numcte
			   AND a.cuenta = b.cuenta
			   AND a. fecha_vigencia >= v_fecha_hoy
               AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_solic_const c 
			                            WHERE c.empresa = '001' 
										  AND c.numcte = a. numcte 
										  AND c.ejercicio = b.ejercicio 
										  AND c.status_envio_edocta = 'AE')
		  GROUP BY b.numcte,b.cuenta,b.ejercicio 
		  ORDER BY ejercicio ASC
		  
		  	EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos(pempresa, v_numcte, 1, '0') 
			INTO vcodret1,vCorreoElec,vTipoCorreo,vStatusCorreo;
			
			IF vcodret1 = '000' AND vCorreoElec IS NOT NULL THEN

					SELECT RTRIM(LTRIM(valor))
					  INTO v_seed
					  FROM "informix".edelec_param WHERE cod_param = 1;		

				SELECT nombre1,nombre2,apell_paterno,apell_materno 
					INTO v_nombre1,v_nombre2,v_apell_paterno, v_apell_materno
					FROM bdinteg:si_cliente WHERE numcte = v_numcte;
				
				
				IF v_nombre2 = '' THEN
					LET v_nomcte = TRIM(v_nombre1)||' '||TRIM(v_apell_paterno)||' '||TRIM(v_apell_materno);
					
				ELSE
					LET v_nomcte = TRIM(v_nombre1)||' '||TRIM(v_nombre2)||' '||TRIM(v_apell_paterno)||' '||TRIM(v_apell_materno);
				END IF
		
				
				EXECUTE PROCEDURE "informix".sp_sel_user_pass (pempresa,v_numcte,v_seed)			
							                             INTO vcodret2,vnumcte2,vpassfirstpart,vpasssecpart;
														 
				LET vpasselec = vpassfirstpart || vpasssecpart;	
				
				IF vpasselec IS NOT NULL OR vpasselec <> ''THEN
			
					RETURN v_sCodRet,v_numcte,v_cuenta,v_ejercicio, vCorreoElec, vpasselec, v_nomcte, v_nom_producto  WITH resume;
				
				END IF
			END IF
			
		CONTINUE FOREACH;
		END FOREACH;
    END
END PROCEDURE;