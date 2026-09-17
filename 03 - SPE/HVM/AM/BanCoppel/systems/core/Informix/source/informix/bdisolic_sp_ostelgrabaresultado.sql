CREATE PROCEDURE "informix".sp_ostelgrabaresultado(cTrama CHAR(7500))
    RETURNING 
	CHAR(5) AS codret, 
	CHAR(80) AS resultado;

-------------------------------------DECLARACION DE VARIABLES
DEFINE cCod_Ret                    CHAR(5);
DEFINE cResultado                  CHAR(80);
DEFINE cBandVal                    CHAR(1);
DEFINE iSql_Err                    INTEGER;
DEFINE iCont                       INTEGER;
DEFINE iIni                        INTEGER;
DEFINE iFin                        INTEGER;
DEFINE iOSTelefonicaVal            INTEGER;
DEFINE dFechaHora                  DATETIME YEAR TO SECOND;
DEFINE cResGestion                 CHAR(2);
DEFINE cBandOSTelefonica           CHAR(1);
DEFINE cBandFechaHora              CHAR(1);
DEFINE cBandResGestion             CHAR(1);
DEFINE cBandMensaje                CHAR(1);
DEFINE cBandTramaVal               CHAR(1);
DEFINE cBandProducto               CHAR(1);
DEFINE cProducto                   CHAR(4);
DEFINE cTipoMensaje                CHAR(1);
DEFINE cStatus                     CHAR(1);
DEFINE sSecuencia                  SMALLINT;
DEFINE cTipoTelefono               CHAR(1);
DEFINE cNumcte                     CHAR(9);
DEFINE cNumcteX                    CHAR(9);
DEFINE cTipoReferenciaSolicitante  CHAR(1);
DEFINE cCausa					   CHAR(2);
DEFINE iNext                       INTEGER;
DEFINE iResgs						INTEGER;
DEFINE cEtiquetaTelefonosOs        CHAR(1);
DEFINE iSecReferencia				INTEGER;

-------------------------------------INICIALIZACION DE VARIABLES
LET cCod_Ret                       = '000';
LET cResultado                     = 'Operacion Exitosa';
LET cBandVal                       = '0';
LET iSql_Err                       = 0;
LET iCont                          = 0;
LET iIni                           = 0;
LET iFin                           = 0;
LET iOSTelefonicaVal               = 0;
LET dFechaHora                     = DATE(1);
LET cResGestion                    = '';
LET cBandOSTelefonica              = '0';
LET cBandFechaHora                 = '0';
LET cBandResGestion                = '0';
LET cBandMensaje                   = '0';
LET cBandTramaVal                  = 'N';
LET cBandProducto                  = '';
LET cProducto                      = '';
LET cTipoMensaje                   = '';
LET cStatus                        = '';
LET sSecuencia                     = 0;
LET cTipoTelefono                  = '';
LET cNumcte                        = '';
LET cNumcteX                       = '';
LET cTipoReferenciaSolicitante	   = '';
LET cCausa						   = '';
LET iNext						   = 0;
LET iResgs						   = 0;
LET cEtiquetaTelefonosOs		   = '0';
LET iSecReferencia					= 0;

BEGIN
	ON EXCEPTION SET iSql_Err
		IF iSql_Err <> 0 THEN
			LET cCod_Ret = iSql_Err;
            RETURN cCod_Ret, 'ERROR ON EXCEPTION';
		END IF;
	END EXCEPTION;
	  
	--SET DEBUG FILE TO '/tmp/sp_ostelgrabaresultado.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    FOR iCont = 1 TO LENGTH(cTrama)
		IF iNext = 0 THEN
			LET iFin = iCont;				
			-- LEE EL TIPO DE MENSAJE CONTENIDO EN LA TRAMA
			IF SUBSTR(cTrama, iFin, 11) = '<IdMensaje>' THEN
				LET cBandMensaje = '1';
				LET cBandVal = '1';
				LET iIni = iFin + 11;
				LET iFin = iFin + 11;            
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama,iFin,1) = '<' THEN
						LET cBandVal = '0';
						LET cTipoMensaje = SUBSTR(cTrama, iIni, (iFin - iIni));
						LET iFin = iFin + 12;						
					END IF;
				END WHILE
			END IF;
			-- LEE EL NUMERO DEL CLIENTE CONTENIDO EN LA TRAMA
			IF SUBSTR(cTrama, iFin ,15) = '<NumeroCliente>' THEN
				LET cBandVal = '1';
				LET iIni = iFin + 15;
				LET iFin = iFin + 15;
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama,iFin,1) = '<' THEN
						LET cBandVal = '0';						
						LET cNumcte = LPAD( TRIM(SUBSTR(cTrama, iIni, (iFin - iIni))),9,'0');				
						LET iFin = iFin + 27;
					END IF;
				END WHILE
			END IF;
			-- LEE EL VALOR DE LA SECUENCIA CONTENIDO EN LA TRAMA
			IF SUBSTR(cTrama, iFin,11) = '<secuencia>' THEN
				LET cBandOSTelefonica = '1';
				LET cBandVal = '1';
				LET iIni = iFin + 11;
				LET iFin = iFin + 11;            
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama,iFin,1) = '<' THEN
						LET cBandVal = '0';
						LET iOSTelefonicaVal = SUBSTR(cTrama, iIni, (iFin - iIni));
						LET iFin = iFin + 12;
					END IF;
				END WHILE
			END IF;
			-- EN CASO DE NO HABER RECIVIDO EL IDMENSAJE 1
			IF TRIM(NVL(cTipoMensaje,''))= '2' THEN
				
				SELECT	COUNT(secuenciaostel)
				  INTO	iResgs
				  FROM	"informix".ss_ostelrefsolicitud_pendientes
				 WHERE	secuenciaostel = iOSTelefonicaVal;
				-- SI EXISTEN REGISTROS EN LA TABLA ES PORQUE NO SE DIO EL EVENTO DONDE IdMensaje ES 1
				IF iResgs <> 0 THEN
					-- CON ESTO FORZAMOS A REALIZAR EL TRABAJO PARA CUANDO IdMensaje ES 1
					LET cTipoMensaje = '1';
					LET iResgs = 1;
				END IF;
			END IF;			
		END IF;
		
		--SI ES EL PRIMER MENSAJE HACE TODO EL PROCESO PARA ACTUALIZAR UNICAMENTE EL RESULTADO DE LA GESTION
		IF TRIM(NVL(cTipoMensaje,''))= '1' AND iOSTelefonicaVal > 0 THEN			
			
			IF SUBSTR(cTrama, iFin, 10) = '<producto>' THEN
				LET cBandProducto = '1';
				LET cBandVal = '1';
				LET iIni = iFin + 10;
				LET iFin = iFin + 10;				
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama, iFin, 1) = '<' THEN
						LET cBandVal = '0';
						LET cProducto = SUBSTR(cTrama, iIni, (iFin - iIni));
						LET iFin = iFin + 11;
					END IF;
				END WHILE
			END IF;			
			IF SUBSTR(cTrama, iFin, 18) = '<resultadoGestion>' THEN
				LET cBandResGestion = '1';
				LET cBandVal = '1';
				LET iIni = iFin + 18;
				LET iFin = iFin + 18;				
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama,iFin,1) = '<' THEN
						LET cBandVal = '0';
						LET cResGestion = SUBSTR(cTrama, iIni, (iFin - iIni));
						LET iFin = iFin + 19;
						-- TRADUCIR CLAVE RESULTADO-GESTION COPPEL - BANCOPPEL
						IF TRIM(cResGestion) = 'C' THEN
							LET cResGestion = 'A';
						ELIF TRIM(cResGestion) = 'NC'  OR TRIM(cResGestion) = '0' THEN
							LET cResGestion = 'S';							
						END IF;						
					END IF;
				END WHILE
			END IF;			
			IF SUBSTR(cTrama, iFin, 7) = '<fecha>' THEN
				LET cBandFechaHora = '1';
				LET cBandVal = '1';
				LET iIni = iFin + 7;
				LET iFin = iFin + 7;				
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama,iFin,1) = '<' THEN
						LET cBandVal = '0';
						IF SUBSTR(cTrama,iFin-4,1) = ':'THEN
							LET dFechaHora = REPLACE(SUBSTR(cTrama, iIni, (iFin - iIni - 4)),'/','-');
						ELSE
							LET dFechaHora = SUBSTR(cTrama, iIni, (iFin - iIni));							
						END IF;
						-- CON ESTO NOS LOGRAMOS POSICIONAR EN EL SIGUIENTE ARREGLO DE RESULTADOS Y EN LA ETIQUETA '<RESULTADO>'
						LET iFin = iFin + 20;
					END IF;
				END WHILE
			END IF;			
			-- PARA SABER SI LA TRAMA CONTIENE MAS RESULTADOS A CONSIDERAR
			IF SUBSTR(cTrama, iFin ,11) = '<resultado>' THEN
				LET iFin = iFin + 39;
				LET iNext = 1;
			ELSE
				-- PARA PRODUCIR LA SALIDA DEL CICLO
				LET iNext = 0;
			END IF;
			
			--PROCESO DE LEER LAS ETIQUETAS FUE EXITOSO, TENGO MATERIAL PARA TRABAJAR
			IF cBandOSTelefonica = '1' AND cBandFechaHora = '1' AND cBandProducto = '1' AND cBandResGestion = '1' AND cBandMensaje = '1' THEN

				IF cProducto <> '6500' THEN
				
					LET cProducto = '6500';					
					
					UPDATE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} "informix".ss_ostelrefsolicitud
					   SET resultadofinal = TRIM(cResGestion)
					 WHERE secuenciaostel = iOSTelefonicaVal
					   AND SUBSTR(num_solicitud,1,4) <> cProducto;
					   
					IF EXISTS(SELECT 1 FROM "informix".ss_ostelrefsolicitud WHERE secuenciaostel = iOSTelefonicaVal AND SUBSTR(num_solicitud,1,4) <> cProducto AND resultadofinal <> '') THEN
						
						DELETE {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)}
						  FROM "informix".ss_ostelrefsolicitud_pendientes
						 WHERE secuenciaostel = iOSTelefonicaVal
						   AND SUBSTR(num_solicitud,1,4) <> cProducto;
					
					END IF;
					
				ELSE
				
					UPDATE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} "informix".ss_ostelrefsolicitud
					   SET resultadofinal = TRIM(cResGestion)
					 WHERE secuenciaostel = iOSTelefonicaVal
					   AND SUBSTR(num_solicitud,1,4) = cProducto;

					IF EXISTS(SELECT 1 FROM "informix".ss_ostelrefsolicitud WHERE secuenciaostel = iOSTelefonicaVal AND SUBSTR(num_solicitud,1,4) = cProducto AND resultadofinal <> '') THEN
					
						DELETE {+INDEX("informix".ss_ostelrefsolicitudss_ostelrefsolicitud idx_secuenciaostel_pend)}
						  FROM "informix".ss_ostelrefsolicitud_pendientes
						 WHERE secuenciaostel = iOSTelefonicaVal
						   AND SUBSTR(num_solicitud,1,4) = cProducto;
					
					END IF;
					
				END IF;
				
				LET cBandTramaVal = 'S';				
				LET cBandFechaHora = '0';
				LET cBandResGestion = '0';
				
				-- LA VARIABLE iResgs TIENE UN VALOR = 0 POR DEFAULT
				IF iNext = 0 AND iResgs = 0 THEN
					EXIT FOR;
				END IF;
				-- SI LA VARIABLE iResgs TIENE UN VALOR = 1 ES POR QUE SE FORZO LA ENTRADA
				IF iNext = 0 AND iResgs = 1 THEN
					-- YA TERMINO Y VENIAMOS DEL EVENTO FORZADO, SETEAMOS EL IdMensaje EN 2, PARA SEGUIR EL FLUJO NORMAL
					LET cTipoMensaje = '2';
					LET	iResgs = 0;
				END IF;
				
			END IF;
			
		--SI ES EL SEGUNDO MENSAJE LEE LA TRAMA Y ACTUALIZA LOS TELEFONOS CONTENIDOS EN ELLA, EN EL ENTENDIDO QUE ES INFORMACION CORRECTA Y NUEVA
		ELIF TRIM(NVL(cTipoMensaje,''))= '2' AND iOSTelefonicaVal > 0 THEN		
			
			IF iNext = 0 AND iResgs = 0 THEN
				LET cBandVal = '1';
				-- BUSCAR ETIQUETA <TelefonosOs>				
				WHILE cBandVal = '1'
					LET iFin = iFin + 1;
					IF SUBSTR(cTrama, iFin ,13) = '<TelefonosOs>' THEN
						LET cBandVal = '0';
						LET iFin = iFin + 23;
						-- BANDERA
						LET cEtiquetaTelefonosOs = '1';
					END IF;
				END WHILE	
			END IF;
			
			IF cEtiquetaTelefonosOs = '1' THEN
			
				-- "TipoReferenciaSolicitante", SI = 0,ES DEL CTE, 1 = REFERENCIA #1 Y 2 = REFERENCIA #2
				IF SUBSTR(cTrama, iFin ,27) = '<TipoReferenciaSolicitante>' THEN
					LET cBandVal = '1';
					LET iIni = iFin + 27;
					LET iFin = iFin + 27;
					WHILE cBandVal = '1'
						LET iFin = iFin + 1;
						IF SUBSTR(cTrama,iFin,1) = '<' THEN
							LET cBandVal = '0';
							LET cTipoReferenciaSolicitante = SUBSTR(cTrama, iIni, (iFin - iIni));
							LET iFin = iFin + 28;						
						END IF;
					END WHILE
				END IF;
				IF SUBSTR(cTrama,iFin,13) = '<TipoDestino>' THEN
					LET cBandVal = '1';
					LET iIni = iFin + 13;
					LET iFin = iFin + 13;
					WHILE cBandVal = '1'
						LET iFin = iFin + 1;
						IF SUBSTR(cTrama,iFin,1) = '<' THEN
							LET cBandVal = '0';
							LET cTipoTelefono = SUBSTR(cTrama, iIni, (iFin - iIni));
							LET iFin = iFin + 14;
						END IF;
					END WHILE
				END IF;
				IF SUBSTR(cTrama,iFin,21) = '<ConsecutivoTelefono>' THEN
					LET cBandVal = '1';
					LET iIni = iFin + 21;
					LET iFin = iFin + 21;
					WHILE cBandVal = '1'
						LET iFin = iFin + 1;
						IF SUBSTR(cTrama,iFin,1) = '<' THEN
							LET cBandVal = '0';
							LET sSecuencia = SUBSTR(cTrama, iIni, (iFin - iIni));
							LET iFin = iFin + 22;
						END IF;
					END WHILE
				END IF;
				IF SUBSTR(cTrama,iFin,12) = '<EstatusTel>' THEN
					LET cBandVal = '1';
					LET iIni = iFin + 12;
					LET iFin = iFin + 12;
					WHILE cBandVal = '1'
						LET iFin = iFin + 1;
						IF SUBSTR(cTrama,iFin,1) = '<' THEN
							LET cBandVal = '0';
							LET cStatus = SUBSTR(cTrama, iIni, (iFin - iIni));
							LET iFin = iFin + 13;							
						END IF;
					END WHILE
				END IF;
				-- PARA IDENTIFICAR LA CAUSA DEL ESTATUSTEL
				IF SUBSTR(cTrama, iFin ,7) = '<Causa>' THEN
					LET cBandVal = '1';
					LET iIni = iFin + 7;
					LET iFin = iFin + 7;
					WHILE cBandVal = '1'
						LET iFin = iFin + 1;
						IF SUBSTR(cTrama,iFin,1) = '<' THEN
							LET cBandVal = '0';
							LET cCausa = SUBSTR(cTrama, iIni, (iFin - iIni));
							-- CON ESTO NOS LOGRAMOS POSICIONAR EN EL SIGUIENTE ARREGLO DE TELEFONOS Y EN LA ETIQUETA '<TELEFONO>'
							LET iFin = iFin + 19;														
						END IF;
					END WHILE
				END IF;
				-- PARA SABER SI LA TRAMA CONTIENE MAS TELEFONOS
				IF SUBSTR(cTrama, iFin ,10) = '<Telefono>' THEN
					LET iFin = iFin + 10;
					LET iNext = 1;
				ELSE
					LET iNext = 0;
				END IF;

				LET iOSTelefonicaVal = iOSTelefonicaVal;
				LET cStatus = cStatus;
				LET sSecuencia = sSecuencia;

				IF cStatus <> '' THEN

					UPDATE "informix".ss_osteltelefonos
					   SET status_stel = TRIM(cStatus), causa = TRIM(cCausa) 
					 WHERE secuenciaostel = iOSTelefonicaVal --INDICE POR SECUENCIA OSTEL
					   AND secuenciatelefono = sSecuencia;
					   
					-- PARA ACTUALIZAR LOS TELEFONOS PERTENECIENTES AL CLIENTE
					IF cTipoReferenciaSolicitante = '0' THEN
					
						UPDATE bdinteg:"informix".si_telefonos
						   SET status_stel = TRIM(cStatus)
						 WHERE numcte =  cNumcte --INDICE POR NUMCTE
						   AND tipo_tel =  TRIM(cTipoTelefono)
						   AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual 
										 WHERE numcte= cNumcte AND tipo_tel= cTipoTelefono);				
						
					-- PARA ACTUALIZAR LOS TELEFONOS PERTENECIENTES A LA REFERENCIA 1
					ELIF cTipoReferenciaSolicitante = '1' THEN
						--HMBR
						SELECT MIN(num_referencia)::INTEGER
						  INTO iSecReferencia
						  FROM "informix".ss_ostelrefsolicitud
						 WHERE secuenciaostel = iOSTelefonicaVal;						   
						
						IF cTipoTelefono = '1' THEN
						
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel1 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;							   
							   
						ELIF cTipoTelefono = '2' THEN
						
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel2 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;
						ELIF cTipoTelefono = '3' THEN
						
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel3 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;
						END IF;	
							   
					-- PARA ACTUALIZAR LOS TELEFONOS PERTENECIENTES A LA REFERENCIA 2
					ELIF cTipoReferenciaSolicitante = '2' THEN
						--HMBR
						SELECT MAX(num_referencia)::INTEGER
						  INTO iSecReferencia
						  FROM "informix".ss_ostelrefsolicitud
						 WHERE secuenciaostel = iOSTelefonicaVal;
						
						IF cTipoTelefono = '1' THEN
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel1 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;
							   
						ELIF cTipoTelefono = '2' THEN
						
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel2 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;
						ELIF cTipoTelefono = '3' THEN
						
							UPDATE bdinteg:"informix".si_refdirecciones
							   SET status_stel3 = TRIM(cStatus)
							 WHERE numcte = cNumcte
							   AND secuencia = iSecReferencia;
						END IF;	
						   
					END IF;
				
					LET cTipoReferenciaSolicitante = '';
					LET cBandTramaVal = 'S';
					LET cTipoTelefono = '';
					LET sSecuencia = '';
					LET cStatus = '';
					LET cCausa = '';
					
					IF iNext = 0 THEN EXIT FOR; END IF;
					
				ELSE
					LET cCod_Ret = '002';
					LET cResultado = 'Hubo problemas al leer la trama, <EstatusTel> vacÃ­o';
					RETURN cCod_Ret, cResultado;					
				END IF;			

				LET cBandOSTelefonica = '0';
				LET cBandFechaHora = '0';
				LET cBandResGestion = '0';	
			
			END IF;			
		END IF;
    END FOR;	

    IF cBandTramaVal = 'N' THEN
        LET cCod_Ret = '001';
		LET cResultado = 'Hubo problemas al leer la trama';
    ELSE
        UPDATE {+INDEX("informix".ss_osteltelefonos idx_secuenciaostel)} "informix".ss_osteltelefonos
		   SET fecha_respuesta = CURRENT YEAR TO SECOND WHERE secuenciaostel = iOSTelefonicaVal;
    END IF;
	
    RETURN cCod_Ret, cResultado;
END;
END PROCEDURE

