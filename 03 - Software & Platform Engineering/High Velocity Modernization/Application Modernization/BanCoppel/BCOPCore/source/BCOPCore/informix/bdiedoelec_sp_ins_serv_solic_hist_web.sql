CREATE PROCEDURE "informix".sp_ins_serv_solic_hist_web(pempresa CHAR(3),pnumcte CHAR(20), pcuenta CHAR(20), pproducto CHAR(4), pfecha_inicio DATE, pfecha_fin DATE, puser_modif CHAR(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_fecha_corte 		DATE;
	DEFINE v_numcte		        CHAR(20);
	DEFINE v_cuenta		        CHAR(20);
	DEFINE v_hist_env	        CHAR(1);
    DEFINE v_max_veces_envio    INTEGER;
	
	
	--Variable que indica en donde se encuentra la cuenta.
	
	-- 1 - CaptaciÃ³n.
	-- 2 - Tarjeta de crÃ©dito.
	-- 3 - Reestructura y prestamos personal.	
	DEFINE v_origen_cuenta    INTEGER;
	
	
	--Variable para verificar si existe el registro en tabla.
		
	--	'' 	- Sin evaluar
	--	'S'	- Existe
	--	'N'	- No existe	
	DEFINE v_existe_registro CHAR(1);
	
	
    --SET DEBUG FILE TO  "sp_ins_serv_solic_hist.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '00000';
	LET v_fecha_corte = '';
	LET v_numcte = "";
	LET v_cuenta = "";
	LET v_hist_env = "";
    LET v_max_veces_envio = 0;
	
	LET v_origen_cuenta = 0;
	LET v_existe_registro = '';
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT numcte
		INTO v_numcte
		FROM bdinteg:si_cliente  
		WHERE numcte = pnumcte;
		
		IF (v_numcte IS NULL OR pnumcte = '' ) THEN		
			LET v_sCodRet = '00001'; --Cliente No Existe
			RETURN v_sCodRet;					
		END IF	
		
		SELECT cuenta,hist_env
		INTO v_cuenta,v_hist_env
		FROM bdiedoelec:edelec_alta_serv  
		WHERE numcte = pnumcte
		AND cuenta = pcuenta
		AND producto = pproducto;
        
        --FCP 04-04-2018
        --Se consulta el mÃ¡ximo de veces a enviar historico de estados de cuenta.
        SELECT
            to_number(valor)
            INTO v_max_veces_envio
        FROM
            bdiedoelec:edelec_param 
        WHERE cod_param =10;
        
		
		IF (v_cuenta IS NULL OR v_cuenta = '' ) THEN			
			LET v_sCodRet = '00002'; --Cuenta No Tiene Activo Servicio
			RETURN v_sCodRet;
		
		ELIF (v_hist_env = 'S' ) THEN			
			LET v_sCodRet = '00003'; --Ya se envÃ­o la historia de Edos. Cta. al Cte.
            RETURN v_sCodRet;
       
        --FCP 04-04-2018
        --ModificaciÃ³n para contemplar el conteo de veces en que se envia el histÃ³rico.

        ELIF ( v_hist_env = '' ) THEN            
            UPDATE 
                bdiedoelec:edelec_alta_serv

            SET hist_env = '1' ,
                fecha_ultima_mod = today,
                tipo_modificacion = 'U',
                user_modif = puser_modif

            WHERE 
                numcte = pnumcte
            AND cuenta = pcuenta;
        
        ELIF ( v_hist_env <> '' AND ( to_number(v_hist_env) + 1 < v_max_veces_envio ) ) THEN
            
            UPDATE 
                bdiedoelec:edelec_alta_serv

            SET hist_env = to_char( to_number(v_hist_env) + 1 ) ,
                fecha_ultima_mod = today,
                tipo_modificacion = 'U',
                user_modif = puser_modif

            WHERE 
                numcte = pnumcte
            AND cuenta = pcuenta;
            
        ELIF ( v_hist_env <> '' AND ( to_number(v_hist_env) + 1 = v_max_veces_envio ) ) THEN
            
            UPDATE 
                bdiedoelec:edelec_alta_serv

            SET hist_env ='S',
                fecha_ultima_mod = today,
                tipo_modificacion = 'U',
                user_modif = puser_modif

            WHERE 
                numcte = pnumcte
            AND cuenta = pcuenta;
		
		END IF		
		
		--CaptaciÃ³n.		
		IF( v_origen_cuenta = 0 )
			THEN
			
				SELECT
					1 into v_origen_cuenta
				FROM
					bdicheq:sc_maechq mcheq
				WHERE 
					mcheq.cuenta = pcuenta;
		END IF;

		
		--Tarjeta de CrÃ©dito.
		
		IF( v_origen_cuenta = 0 )
			THEN
		
				SELECT
					2 into v_origen_cuenta
				FROM
					bdicred:sd_maecred mcred
				WHERE 
					mcred.num_credito = pcuenta;
		END IF;
		
		
		--PrÃ©stamo Personal Y Reestructura
		
		IF( v_origen_cuenta = 0 )
			THEN
		
				SELECT
					3 into v_origen_cuenta
				FROM
					bdicred:sd_maecredcrd ppre
				WHERE 
					ppre.num_credito = pcuenta;
		END IF;
			
		

        --CaptaciÃ³n.
        IF ( v_origen_cuenta <> 0 AND v_origen_cuenta = 1 )   THEN

            --Consulta completa.
            FOREACH cursor1 WITH HOLD FOR
                SELECT 
                    b.fechafin
                INTO v_fecha_corte
                FROM 
                    bdicheq:sc_maechq a
                INNER JOIN 
                    bdicheq:sc_maehis_factelect b
                ON
                    a.cuenta = b.cuenta
                
                WHERE   
                    (  a.status_cta = 1 
                        OR a.status_cta = 3 
                        OR a.status_cta = 4 
                        OR a.status_cta = 5 )

                    AND a.num_cte = pnumcte
                    AND b.cuenta = pcuenta
                    AND a.producto = pproducto
                    AND ( pfecha_inicio <= b.fechafin AND pfecha_fin >= b.fechafin )
					
					
					--Setea como sin evaluar la variable.
					LET v_existe_registro = '';
						
					SELECT
						'S' into v_existe_registro
					FROM
						bdiedoelec:edelec_serv_solic a
					WHERE
						a.empresa = '001' 
					AND a.numcte = pnumcte 
					AND a.cuenta = pcuenta
					AND a.fecha_corte = v_fecha_corte;
					
					IF( v_existe_registro is null )
						THEN
							LET v_existe_registro = 'N';
					END IF;
						

					--Si no existe, se inserta el registro en ambas tablas.
					IF ( v_existe_registro <> 'S' ) THEN

						INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
												  VALUES (pempresa,pnumcte,pcuenta,pproducto, v_fecha_corte, TODAY, TODAY + 20);

						INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
													  VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);
					ELSE
					
						--Se actualiza fecha recepcion y fecha vigencia de tabla edelec_serv_solic
						UPDATE	
							"informix".edelec_serv_solic
						SET
							fecha_recepcion = TODAY,
							fecha_vigencia = TODAY + 20
						WHERE
							empresa = '001' 
						AND numcte = pnumcte 
						AND cuenta = pcuenta
						AND fecha_corte = v_fecha_corte;
						
						--Se establece el log como 'RE'
						UPDATE
							"informix".edelec_log_serv_solic
						SET
							status_envio_edocta = 'RE'						
						WHERE
							empresa = '001' 
						AND numcte = pnumcte 
						AND cuenta = pcuenta
						AND fecha_corte = v_fecha_corte;

						--Se inserta un nuevo registro.

						INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
						VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);
						
					END IF;                            
                    CONTINUE FOREACH;
            END FOREACH
            
        
        --Tarjeta de CrÃ©dito.
        ELIF ( v_origen_cuenta <> 0 AND v_origen_cuenta = 2 )
			THEN

            FOREACH cursor1 WITH HOLD FOR

				SELECT
					fecha_emision
				INTO v_fecha_corte
				FROM
					bdicred@pld_tcp:sd_encabezado2_edocta --(ProducciÃ³n)
				--FROM 
					--bdicred:sd_encabezado2_edocta -- Desarrollo
				WHERE 
						num_credito = pcuenta
					AND ( pfecha_inicio <= fecha_emision AND pfecha_fin >= fecha_emision )

				ORDER BY 
					fecha_emision						
						
				--Setea como sin evaluar la variable.
				LET v_existe_registro = '';				
					
				SELECT
					'S' into v_existe_registro
				FROM 
					bdiedoelec:edelec_serv_solic a 
				WHERE
					a.empresa = '001' 
				AND a.numcte = pnumcte 
				AND a.cuenta = pcuenta
				AND a.fecha_corte = v_fecha_corte;
				
				IF( v_existe_registro is null )
					THEN
						LET v_existe_registro = 'N';
				END IF;						

				--Si no existe, se inserta el registro en ambas tablas.
				IF ( v_existe_registro <> 'S' ) THEN

					INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
					VALUES (pempresa,pnumcte,pcuenta,pproducto, v_fecha_corte, TODAY, TODAY + 20);
			
					INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
					VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);
				ELSE
				
					--Se actualiza fecha recepcion y fecha vigencia de tabla edelec_serv_solic
					UPDATE	
						"informix".edelec_serv_solic
					SET
						fecha_recepcion = TODAY,
						fecha_vigencia = TODAY + 20
					WHERE
						empresa = '001' 
					AND numcte = pnumcte 
					AND cuenta = pcuenta
					AND fecha_corte = v_fecha_corte;
					
					--Se establece el log como 'RE'
					UPDATE
						"informix".edelec_log_serv_solic
					SET
						status_envio_edocta = 'RE'
					
					WHERE
						empresa = '001' 
					AND numcte = pnumcte 
					AND cuenta = pcuenta
					AND fecha_corte = v_fecha_corte;

					--Se inserta un nuevo registro.
			
					INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
					VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);					
				END IF;
				
				CONTINUE FOREACH;
			END FOREACH;


        -- PrÃ©stamo Personal Y Reestructura
        ELIF ( v_origen_cuenta <> 0 AND v_origen_cuenta = 3 )
			THEN
		
			FOREACH cursor1 WITH HOLD FOR
                    
				SELECT
					fecha_emision
				INTO 
					v_fecha_corte
				FROM 
					bdicred:sd_encabezado2_edoctacrd
				WHERE 
						num_credito = pcuenta
					AND ( pfecha_inicio <= fecha_emision AND pfecha_fin >= fecha_emision )
				ORDER BY 
					fecha_emision						
						
				--Setea como sin evaluar la variable.
				LET v_existe_registro = '';	
					
				SELECT
					'S' into v_existe_registro
				FROM 
					bdiedoelec:edelec_serv_solic a 
				WHERE
					a.empresa = '001' 
				AND a.numcte = pnumcte 
				AND a.cuenta = pcuenta
				AND a.fecha_corte = v_fecha_corte;
						
						
				IF( v_existe_registro is null )
					THEN
						LET v_existe_registro = 'N';
				END IF;						

				--Si no existe, se inserta el registro en ambas tablas.
				IF ( v_existe_registro <> 'S' ) THEN

					INSERT INTO "informix".edelec_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_vigencia)
					VALUES (pempresa,pnumcte,pcuenta,pproducto, v_fecha_corte, TODAY, TODAY + 31);
		
					INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
					VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);
				ELSE				
					--Se actualiza fecha recepcion y fecha vigencia de tabla edelec_serv_solic
					UPDATE	
						"informix".edelec_serv_solic
					SET
						fecha_recepcion = TODAY,
						fecha_vigencia = TODAY + 31
					WHERE
						empresa = '001' 
					AND numcte = pnumcte 
					AND cuenta = pcuenta
					AND fecha_corte = v_fecha_corte;
					
					--Se establece el log como 'RE'
					UPDATE
						"informix".edelec_log_serv_solic
					SET
						status_envio_edocta = 'RE'
					
					WHERE
						empresa = '001' 
					AND numcte = pnumcte 
					AND cuenta = pcuenta
					AND fecha_corte = v_fecha_corte;

					--Se inserta un nuevo registro.
		
					INSERT INTO "informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
					VALUES (pempresa, pnumcte, pcuenta, pproducto, v_fecha_corte, 'SE', TODAY);					
				END IF;			
				CONTINUE FOREACH;
			END FOREACH;		
		END IF		
		RETURN v_sCodRet;
    END
END PROCEDURE;