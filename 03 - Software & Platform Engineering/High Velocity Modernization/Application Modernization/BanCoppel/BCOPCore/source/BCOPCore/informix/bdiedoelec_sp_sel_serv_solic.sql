CREATE PROCEDURE "informix".sp_sel_serv_solic (pempresa char(3) ) 
    RETURNING CHAR(5) AS v_sCodRet, CHAR(20) AS v_numcte, CHAR(20) AS v_cuenta, CHAR(4) AS v_producto, DATE AS v_fechafin, CHAR(100) AS vCorreoElec, 
	          CHAR(8) AS vpasselec, CHAR(70) AS v_nomcte, CHAR (20) AS v_nom1_producto, CHAR (20) AS v_nom2_producto
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE v_fecha_hoy 			DATE;
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_fechafin           DATE;
	DEFINE v_nomcte 			CHAR(70);
	DEFINE v_nombre1 			CHAR(26);
	DEFINE v_nombre2 			CHAR(26);
	DEFINE v_apell_paterno 		CHAR(26);
	DEFINE v_apell_materno 		CHAR(26);
	DEFINE v_nom_producto 		CHAR(40);
	DEFINE v_nom1_producto 		CHAR(20);
	DEFINE v_nom2_producto 		CHAR(20);
	
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
		

		
    --SET DEBUG FILE TO  "/ifxsif01/c90021641/aolg/bdiedoelec/outTracer/sp_sel_serv_solic.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_fecha_hoy = TODAY;
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_fechafin = TODAY;
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
	LET v_nom_producto = '';
	LET v_nom1_producto = '';
	LET v_nom2_producto = '';
	
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
                RETURN v_sCodRet,'','','',TODAY,'','','','','';
            END IF;
        END EXCEPTION;
		
		
		SELECT fecha_hoy
		  INTO v_fecha_hoy 
		  FROM bdinteg:si_fechas 
		 WHERE empresa = '001';
			 
					
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		
		
		FOREACH WITH HOLD  			
			SELECT b.numcte,b.cuenta,b.producto,b.fecha_corte
		      INTO v_numcte,v_cuenta,v_producto,v_fechafin
			  FROM bdiedoelec:edelec_serv_solic a, bdiedoelec:edelec_log_serv_solic b 
			 WHERE a.numcte = b.numcte
			   AND a.cuenta = b.cuenta
			   AND a.producto = b.producto
			   AND a.fecha_vigencia = v_fecha_hoy
			   AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_serv_solic c 
			                            WHERE c.empresa = '001' 
										  AND c.numcte = a.numcte 
										  AND c.producto = a.producto
                                          AND c.fecha_corte = b.fecha_corte 
										  AND c.status_envio_edocta = 'AE')
				GROUP BY b.numcte,b.cuenta,b.producto, b.fecha_corte 
				ORDER BY fecha_corte ASC
					  		  				
			
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
				
				IF SUBSTR(v_cuenta,1,1) = '1' OR SUBSTR(v_cuenta,1,1) = '2'  THEN
				
					SELECT nombre 
						INTO v_nom_producto
						FROM bdicheq:sc_producto WHERE producto = v_producto;
				
				ELSE
					SELECT nombre_prod 
						INTO v_nom_producto
						FROM bdicred:sd_definicion WHERE num_producto = v_producto;

				END IF
				
				LET v_nom1_producto = SUBSTR(v_nom_producto,1,20);
				LET v_nom2_producto = SUBSTR(v_nom_producto,21,20);
				
		
	
				EXECUTE PROCEDURE "informix".sp_sel_user_pass (pempresa,v_numcte,v_seed)			
				INTO vcodret2,vnumcte2,vpassfirstpart,vpasssecpart;
				
				
				LET vpasselec = vpassfirstpart || vpasssecpart;
				
				
				IF vpasselec IS NOT NULL OR vpasselec <> '' THEN
									
					RETURN v_sCodRet,v_numcte,v_cuenta,v_producto,v_fechafin, vCorreoElec, vpasselec, v_nomcte, v_nom1_producto, v_nom2_producto  WITH resume;

					
				END IF
			END IF
		
		 CONTINUE FOREACH;		
		END FOREACH;
					
    END
END PROCEDURE;