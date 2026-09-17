CREATE PROCEDURE "informix".sp_tokenizacion_ciclo_vida()

RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************
DEFINE iSql_err						INT;
DEFINE cCodRet						CHAR(5);
DEFINE vNumtarjeta          		VARCHAR(19);
DEFINE vCodstatustarjeta			VARCHAR(3);
DEFINE vCodproductotarjeta			VARCHAR(3);
DEFINE vNumcliente					VARCHAR(13);
DEFINE vFechaexp          			VARCHAR(4);
DEFINE vNumtarjetasustituta			VARCHAR(19);
DEFINE vFechaasignacion				DATETIME YEAR TO FRACTION(5);
DEFINE vFechaultmodif				DATETIME YEAR TO FRACTION(5);
DEFINE vFecha       				DATE;
DEFINE vFecha2       				DATE;
DEFINE v2Numtarjeta					VARCHAR(19);
DEFINE v2Codstatustarjeta			VARCHAR(3);
DEFINE v2Fechaexp					VARCHAR(4);
DEFINE v2Numtarjetasustituta		VARCHAR(19);
DEFINE vCardId            			VARCHAR(48);
DEFINE vNewCardId           		VARCHAR(48);
DEFINE v3Numtarjeta					VARCHAR(19);
DEFINE v3Codstatustarjeta			VARCHAR(3);
DEFINE v3Numtarjetasustituta		VARCHAR(19);
DEFINE nombreArchivo        		VARCHAR(50);
DEFINE pArchDeclarga1	    		CHAR(1000);
DEFINE cCmd1        	    		CHAR(1500);
DEFINE cQuery1        	    		CHAR(3000);
DEFINE fechaFin 	                DATE;
DEFINE bandera                      VARCHAR(10);
DEFINE contador                     INTEGER;
DEFINE contadorCardId               INTEGER;
DEFINE vNewcardproductid            VARCHAR(60);
DEFINE banderaCardId                CHAR(1);
DEFINE contadorIteracionesRenew     INTEGER;
DEFINE mes                      	CHAR(2);
DEFINE anio                       	CHAR(4);
DEFINE dia                       	CHAR(2);

-- ****************************************************************************
-- Inicializa las variables
-- ****************************************************************************
LET iSql_err					= 0;
LET cCodRet						= '00000';
LET vNumtarjeta 				= '';
LET vCodstatustarjeta			= '';
LET vCodproductotarjeta 		= '';
LET vNumcliente 				= '';
LET vFechaexp 					= ''; 
LET vNumtarjetasustituta 		= ''; 
LET vFechaasignacion			= '';
LET vFechaultmodif				= '';
LET vFecha       				= '';
LET vFecha2                     = '';
LET v2Numtarjeta				= '';
LET v2Codstatustarjeta			= '';
LET v2Fechaexp					= '';
LET v2Numtarjetasustituta		= '';
LET vCardId            			= '';
LET vNewCardId           		= '';
LET v3Numtarjeta				= '';
LET v3Codstatustarjeta			= '';
LET v3Numtarjetasustituta		= '';
LET nombreArchivo        		= '';
LET pArchDeclarga1	    		= '';
LET cCmd1        	    		= '';
LET cQuery1        	    		= '';
LET fechaFin 	                = '';
LET contador                    = 0;
LET contadorCardId              = 0;
LET vNewcardproductid           = '';
LET banderaCardId				= 'F';
LET contadorIteracionesRenew 	= 0;
LET mes 	     	            = '';
LET anio 	         	        = '';
LET dia 	             	    = '';

	BEGIN
        
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 then
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
        --SET DEBUG FILE TO "/home/c90313380/prueba_CHARLY.out";
        --TRACE ON;
		
        
      
        

        -- Obtiene ultima fecha de modificacion 
		SELECT MAX(fechaultmodif) 
			INTO vFechaultmodif
		FROM intercard:"informix".tbl_info_tarjetas_abu;
		
		IF vFechaultmodif <> '' OR vFechaultmodif IS NOT NULL THEN
			LET vFecha = TO_DATE('"'||YEAR(TODAY - 1)||'-'||CASE WHEN MONTH(TODAY - 1)< 10 THEN 0 || MONTH(TODAY - 1) ELSE TO_CHAR(MONTH(TODAY - 1)) END||'-'||CASE WHEN DAY(TODAY - 1)< 10 THEN 0 || DAY(TODAY - 1) ELSE TO_CHAR(DAY(TODAY - 1)) END||' 00:00:00"','"%Y-%m-%d %H:%M:%S"');
	        LET vFecha2 = TO_DATE('"'||YEAR(vFechaultmodif)||'-'||CASE WHEN MONTH(vFechaultmodif)< 10 THEN 0 || MONTH(vFechaultmodif) ELSE TO_CHAR(MONTH(vFechaultmodif)) END||'-'||CASE WHEN DAY(vFechaultmodif)< 10 THEN 0 || DAY(vFechaultmodif) ELSE TO_CHAR(DAY(vFechaultmodif)) END||' 00:00:00"','"%Y-%m-%d %H:%M:%S"');
	    END IF
        --Borra el contenido de la tabla
		TRUNCATE TABLE "informix".tbl_ciclo_vida_tokenizacion;
		TRUNCATE TABLE "informix".tbl_ciclo_vida_bitacora;

		IF (vFecha2 < vFecha OR vFechaultmodif IS NULL ) THEN 
            FOREACH tarjetas WITH HOLD FOR
                -- Obtiene tarjetas del dia
             SELECT tar.numtarjeta, tar.codstatustarjeta, tar.codproductotarjeta,tar.numcliente, tar.fechaexp, tar.numtarjetasustituta, tar.fechaasignacion, tar.fechaultmodif
                INTO vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta,vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif
             FROM intercard:"informix".tarjeta tar
                INNER JOIN tarjetas_tokenizadas ind
                    ON tar.numtarjeta = ind.numtarjeta
             WHERE ind.tokenizada = '1'
                AND fechaultmodif >= TO_DATE('"'||YEAR(TODAY - 1)||'-'||CASE WHEN MONTH(TODAY - 1)< 10 THEN 0 || MONTH(TODAY - 1) ELSE TO_CHAR(MONTH(TODAY - 1)) END||'-'||CASE WHEN DAY(TODAY - 1)< 10 THEN 0 || DAY(TODAY - 1) ELSE TO_CHAR(DAY(TODAY - 1)) END||' 00:00:00"','"%Y-%m-%d %H:%M:%S"')
                AND fechaultmodif <= TO_DATE('"'||YEAR(TODAY - 1)||'-'||CASE WHEN MONTH(TODAY - 1)< 10 THEN 0 || MONTH(TODAY - 1) ELSE TO_CHAR(MONTH(TODAY - 1)) END||'-'||CASE WHEN DAY(TODAY - 1)< 10 THEN 0 || DAY(TODAY - 1) ELSE TO_CHAR(DAY(TODAY - 1)) END||' 23:59:59"','"%Y-%m-%d %H:%M:%S"')
            
         
             INSERT INTO "informix".tbl_ciclo_vida_tokenizacion (numtarjeta, codstatustarjeta, codproductotarjeta, numcliente, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif, marca)
                VALUES(vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta, vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, "VS");
            END FOREACH
		ELSE
		    -- Filtrado de tarjetas tokenizadas presentes en la carga inicial
		    FOREACH tarjetas WITH HOLD FOR

			    SELECT abu.numtarjeta, abu.codstatustarjeta, abu.codproductotarjeta, abu.numcliente, abu.fechaexp, abu.numtarjetasustituta, abu.fechaasignacion, abu.fechaultmodif
				    INTO vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta, vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif
				FROM tbl_info_tarjetas_abu abu
			        INNER JOIN tarjetas_tokenizadas ind
							    ON abu.numtarjeta = ind.numtarjeta
                    WHERE ind.tokenizada = '1'
                 
			    INSERT INTO "informix".tbl_ciclo_vida_tokenizacion (numtarjeta, codstatustarjeta, codproductotarjeta, numcliente, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif, marca)
			        VALUES(vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta, vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, "VS");
		    END FOREACH
		END IF

	-- RESUME
		FOREACH tarjetas WITH HOLD FOR
            
			SELECT car.numtarjeta, car.codstatustarjeta
				INTO vNumtarjeta, vCodstatustarjeta
			FROM tbl_ciclo_vida_tokenizacion car
				INNER JOIN tarjetas_tokenizadas ind
					ON car.numtarjeta = ind.numtarjeta
						WHERE car.codstatustarjeta = 'ACT' AND ind.status = '4'

			-- Busqueda de cardId
			SELECT card_id
				INTO vCardId
			FROM tokenizacion_cardid
				WHERE numtarjeta = vNumtarjeta;
			--

			INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
			VALUES ("RESUME", vCardId, vCodstatustarjeta, "ISSUER_DECISION", NULL, NULL, NULL);
            
			UPDATE tarjetas_tokenizadas 
				SET operacion='RESUME',status=6,fecha_susp_token=NULL,fecha_insert=CURRENT
			WHERE numtarjeta = vNumtarjeta;
          
		END FOREACH

	-- SUSPEND
		FOREACH tarjetas WITH HOLD FOR
			SELECT car.numtarjeta, car.codstatustarjeta
				INTO vNumtarjeta, vCodstatustarjeta
			FROM tbl_ciclo_vida_tokenizacion car
				INNER JOIN tarjetas_tokenizadas ind
					ON car.numtarjeta = ind.numtarjeta
						WHERE codstatustarjeta IN ('BLT') AND ind.status IN ('2', '6')

			-- Busqueda de cardId
			SELECT card_id
				INTO vCardId
			FROM tokenizacion_cardid
				WHERE numtarjeta = vNumtarjeta;
			--

			INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
			VALUES ("SUSPEND", vCardId, vCodstatustarjeta, "ISSUER_DECISION", NULL, NULL, NULL);

			UPDATE tarjetas_tokenizadas 
				SET operacion='SUSPEND',status=4,fecha_susp_token=CURRENT,fecha_insert=CURRENT 
					WHERE numtarjeta = vNumtarjeta;
           
		END FOREACH

	-- DELETE
		FOREACH tarjetas WITH HOLD FOR

			SELECT numtarjeta, codstatustarjeta
				INTO vNumtarjeta, vCodstatustarjeta
			FROM tbl_ciclo_vida_tokenizacion
				WHERE codstatustarjeta IN ('CAN','ROB','DES','EXT','FAL','DAN')
					AND numtarjetasustituta IS NULL

			-- Busqueda de cardId
			SELECT card_id
				INTO vCardId
			FROM tokenizacion_cardid
				WHERE numtarjeta = vNumtarjeta;
			--

			INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
			VALUES ("DELETE", vCardId, vCodstatustarjeta, "ISSUER_DECISION", NULL, NULL, NULL);

			UPDATE tarjetas_tokenizadas 
				SET operacion='DELETE',status=5,fecha_susp_token=NULL,fecha_insert=CURRENT 
			WHERE numtarjeta = vNumtarjeta;	
			
		END FOREACH

	--RENEW
		FOREACH tarjetas WITH HOLD FOR

			SELECT tar.numtarjeta, tar.codstatustarjeta, act.numtarjeta , act.codstatustarjeta,  act.numtarjetasustituta
				INTO vNumtarjeta, vCodstatustarjeta, v2Numtarjeta, v2Codstatustarjeta,v2Numtarjetasustituta
			FROM tbl_ciclo_vida_tokenizacion tar
				INNER JOIN tarjeta act 
					ON act.numtarjeta = tar.numtarjetasustituta
			WHERE tar.codstatustarjeta NOT IN ('ACT','BLO','BLT')
           
		    LET bandera = "RENEW";
			LET contadorIteracionesRenew = 0;
            
            IF (v2Codstatustarjeta NOT IN ('ACT','BLO','BLT') AND v2Numtarjetasustituta IS NULL) THEN
					LET bandera = "DELETE";
				
			ELIF ( v2Codstatustarjeta IN ('BLT') AND v2Numtarjetasustituta IS NULL) THEN
					LET bandera = "SUSPEND";
				
		    ELSE     
                WHILE v2Codstatustarjeta NOT IN ('ACT') AND v2Numtarjetasustituta IS NOT NULL  
                    SELECT numtarjeta, codstatustarjeta, numtarjetasustituta
                        INTO v3Numtarjeta, v3Codstatustarjeta, v3Numtarjetasustituta
                            FROM tarjeta
                                WHERE numtarjeta = v2Numtarjetasustituta;
								
					 -- EVALUA LA CANTIDAD DE ITERACIONES Y LLEGANDO AL LIMITE PONE LA TARJETA SUSTITA EN NULL 	
					IF (contadorIteracionesRenew = 10) THEN
						LET v3Numtarjetasustituta = NULL;
					END IF
					
                    IF (v3Codstatustarjeta = 'ACT') THEN
                        LET v2Codstatustarjeta = v3Codstatustarjeta;
                        LET v2Numtarjeta = v2Numtarjetasustituta;
                        LET bandera = "RENEW";
                        
    
                    -- EVALUA QUE LA TARJETA YA NO TIENE REEMPLAZO Y ESTA CANCELADA
					ELIF ((v3Codstatustarjeta NOT IN ('ACT','BLO','BLT') OR v3Codstatustarjeta IS NULL) AND v3Numtarjetasustituta IS NULL) THEN
                        LET v2Codstatustarjeta = 'ACT';
                        LET bandera = "DELETE";
                        
                    ELIF (v3Codstatustarjeta IN ('BLT')  AND v3Numtarjetasustituta IS NULL) THEN
                        LET v2Codstatustarjeta = 'ACT';
						LET v2Numtarjeta = v2Numtarjetasustituta;
                        LET bandera = "SUSPEND";
                        
                        
                    ELSE
                        LET v2Numtarjetasustituta = v3Numtarjetasustituta;
                        LET contadorIteracionesRenew = contadorIteracionesRenew + 1;
                    END IF;			
    
                END WHILE;
			 END IF

			-- Busqueda de cardId
			SELECT card_id
				INTO vCardId
			FROM tokenizacion_cardid
                WHERE numtarjeta = vNumtarjeta;
			--
			LET banderaCardId = 'F';
			
			-- Busqueda de cardId v2Numtarjeta
			SELECT card_id
				INTO vNewCardId
			FROM tokenizacion_cardid
                WHERE numtarjeta = v2Numtarjeta;

			IF (vNewCardId = '' OR vNewCardId IS NULL) THEN
				-- Genera New Card Id
				SELECT TO_CHAR(CURRENT  YEAR TO FRACTION(3), "%Y%m%d%H%M%S") 
					INTO vNewCardId
				FROM systables   
					WHERE tabid=1; 
				LET vNewCardId = vNewCardId || contadorCardId;
				LET contadorCardId = contadorCardId + 1;
			ELSE
				LET banderaCardId = 'T';
            END IF   
                
			--- Obtiene newCardProductID
			SELECT card_product_id
			    INTO vNewcardproductid
			FROM tokenizacion_bines
			    WHERE binfisico = SUBSTR (v2Numtarjeta, 1, 6) AND rango = SUBSTR (v2Numtarjeta, 7, 2);
			
		

			IF (bandera = "RENEW")  THEN
				
				INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
				VALUES ("RENEW", vCardId, vCodstatustarjeta, "ISSUER_DECISION", vNewCardId, vNewcardproductid, v2Codstatustarjeta);
                
				UPDATE tarjetas_tokenizadas 
					SET operacion='RENEW',status=7,fecha_susp_token=NULL,fecha_insert=CURRENT 
				WHERE numtarjeta = vNumtarjeta;
				
				IF (banderaCardId = 'F') THEN
					-- INSERTAR NUEVO CARD ID EN LA TABLA DE CARD IDS
					INSERT INTO informix.tokenizacion_cardid(numtarjeta, card_id, fecha_insert) 
					VALUES(v2Numtarjeta, vNewCardId, CURRENT);
				END IF
				
				IF ((SELECT COUNT(numtarjeta) FROM "informix".tarjetas_tokenizadas WHERE numtarjeta = v2Numtarjeta) = 0) THEN
					INSERT INTO "informix".tarjetas_tokenizadas (numtarjeta, operacion, status, tokenizada, fecha_tokenizacion, fecha_del_token, fecha_susp_token, fecha_insert)
					VALUES (v2Numtarjeta, 'RENEW', 2, '1', CURRENT, CURRENT, NULL, CURRENT);
                ELSE
					UPDATE tarjetas_tokenizadas 
						SET operacion='RENEW',status=2,fecha_tokenizacion=CURRENT,fecha_del_token=CURRENT,fecha_susp_token=NULL,fecha_insert=CURRENT 
					WHERE numtarjeta = v2Numtarjeta;
				END IF
                
            ELIF (bandera = "SUSPEND") THEN
                LET v2Codstatustarjeta = 'BLO';
                 
				INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
				VALUES ("RENEW", vCardId, vCodstatustarjeta, "ISSUER_DECISION", vNewCardId,vNewcardproductid, v2Codstatustarjeta);
				
				UPDATE tarjetas_tokenizadas 
					SET operacion='RENEW',status=7,fecha_susp_token=NULL,fecha_insert=CURRENT 
				WHERE numtarjeta = vNumtarjeta;
				
				
				-- INSERTAR NUEVO CARD ID EN LA TABLA DE CARD IDS
				
				IF (banderaCardId = 'F') THEN
					-- INSERTAR NUEVO CARD ID EN LA TABLA DE CARD IDS
					INSERT INTO informix.tokenizacion_cardid(numtarjeta, card_id, fecha_insert) 
					VALUES(v2Numtarjeta, vNewCardId, CURRENT);
				END IF
		
				--------------------------------
				--------Despues de Renovar Suspendemos la nueva tarjeta
				
				 
				 
				INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
				VALUES ("SUSPEND", vNewCardId, v2Codstatustarjeta, "ISSUER_DECISION", NULL, NULL, NULL);
				
				IF ((SELECT COUNT(numtarjeta) FROM "informix".tarjetas_tokenizadas WHERE numtarjeta = v2Numtarjeta) = 0) THEN
					INSERT INTO "informix".tarjetas_tokenizadas (numtarjeta, operacion, status, tokenizada, fecha_tokenizacion, fecha_del_token, fecha_susp_token, fecha_insert)
					VALUES (v2Numtarjeta, 'SUSPEND', 4, '1', CURRENT, CURRENT, CURRENT, CURRENT);
                ELSE
					UPDATE tarjetas_tokenizadas 
						SET operacion='SUSPEND',status=4,fecha_tokenizacion=CURRENT,fecha_del_token=CURRENT,fecha_susp_token=CURRENT,fecha_insert=CURRENT 
					WHERE numtarjeta = v2Numtarjeta;
				END IF 
			ELSE 
				INSERT INTO "informix".tbl_ciclo_vida_bitacora (operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate)
				VALUES ("DELETE", vCardId, vCodstatustarjeta, "ISSUER_DECISION", NULL, NULL, NULL);

				UPDATE tarjetas_tokenizadas 
					SET operacion='DELETE',status=5,fecha_susp_token=NULL,fecha_insert=CURRENT 
				WHERE numtarjeta = vNumtarjeta;
                
			END IF;
			
		END FOREACH

        SELECT COUNT(*) 
            INTO contador
        FROM "informix".tbl_ciclo_vida_bitacora;
        
        IF (contador <> 0) THEN
			SELECT DAY(TODAY)
				INTO dia 
			FROM systables   
				WHERE tabid=1;
                
			IF dia < 10 THEN
				LET dia = 0 || dia;
			END IF
		
			SELECT MONTH(TODAY)
				INTO mes 
			FROM systables   
				WHERE tabid=1;
                
			IF mes < 10 THEN
				LET mes = 0 || mes;
			END IF

			SELECT YEAR(TODAY)  
				INTO anio 
			FROM systables 
				WHERE tabid=1;
				
				
            -- Creacion de archivo.
            LET nombreArchivo = '';
            LET nombreArchivo = 'Ciclo_Vida_Tokenizacion_';
    
            LET pArchDeclarga1='"/RESPALDOSNEW/Tokenizacion/'|| nombreArchivo ||  anio || '-' || mes || '-' || dia ||'.csv" ';
    
            LET cCmd1 = 'SELECT operacion, cardid, reason, reasoncode, newcardid, newcardproductid, newcardstate FROM tbl_ciclo_vida_bitacora';
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);
		ELSE
		    LET cCodRet = "00002";
		END IF;
	
	RETURN cCodRet;	
	END;

END PROCEDURE;