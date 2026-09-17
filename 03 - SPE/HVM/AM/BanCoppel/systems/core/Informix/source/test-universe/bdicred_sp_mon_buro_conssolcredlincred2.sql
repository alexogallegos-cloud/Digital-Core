CREATE PROCEDURE "informix".sp_mon_buro_conssolcredlincred2(pEjecucion SMALLINT,pTipoSolicitud CHAR(2),pNumsolicitud CHAR(20), pNumcte CHAR(20), pFechaIni DATE, pFechafin DATE, pEstatus CHAR(2), pProducto CHAR (4), pCve_grupo CHAR(2), pSegmento CHAR(2), pEtiqueta CHAR(2), pAnalista CHAR(8),pComentario CHAR(100))

--RETORNOS-
RETURNING
CHAR(6)                   AS cod_ret,
CHAR(30)                  AS tipo_solicitud,
CHAR(20)                  AS no_solicitud,
DATE                      AS fecha,
DATETIME HOUR TO FRACTION AS hora,
CHAR(20)                  AS cliente,
CHAR(2)                   AS estatus,
CHAR(100)                 AS comentario,
INTEGER                   AS total_registros,
CHAR(2)                   AS cve_grupo,
CHAR(2)                   AS segmento,
CHAR(2)                   AS etiqueta;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE cod_ret				    CHAR(5);
DEFINE iSql_err				    INTEGER; 
DEFINE VSQL                     CHAR(5000);
DEFINE cTiposolicitud			CHAR(30);
DEFINE cNumsolicitud			CHAR(20);
DEFINE cNumsolicitud2			CHAR(20);
DEFINE dFecha					DATE;
DEFINE dHora					DATETIME HOUR to FRACTION;
DEFINE cCliente					CHAR(20);
DEFINE cEstatus					CHAR(2);
DEFINE cComentario				CHAR(100);
DEFINE cCodretParam             CHAR(6);
DEFINE cMensajeParam            CHAR(80);
DEFINE iLimitePaginacion        INTEGER;
DEFINE iRegistros               INTEGER;
DEFINE iContador                INTEGER; --CONTROL DE PAGINACION
DEFINE iAcumulador              INTEGER; --CONTROL DE REGISTROS TOTALES
DEFINE dFechaHoy                DATE;
DEFINE cSegmento                CHAR(02);
DEFINE cEtiqueta                CHAR(02);
DEFINE cDescripcion             CHAR(100);
DEFINE cExcepcionerror1          CHAR(10);
DEFINE cExcepcionerror2         CHAR(10);
DEFINE cDescripcionExcepcion    CHAR(30);
DEFINE cDescripcionOpcional     CHAR(30);
DEFINE cInstitucion             CHAR(2);
DEFINE cNumeroSolicitud         CHAR(20);
DEFINE cClave_grupo             CHAR(2);
-----------------------------------EJECUCION 2
DEFINE iSecuencia               INTEGER;
DEFINE cNumcte                  CHAR(20);
DEFINE cNumprod                 CHAR(4);
DEFINE cSucursal                CHAR(4);
DEFINE cNombre_cte              CHAR(100);
DEFINE cNumAnalista            CHAR(8);
DEFINE cNombreAnalista          CHAR(104);
DEFINE cPerfilAnalista          CHAR(25);
DEFINE sRegreso                 SMALLINT;
DEFINE iExisteSolicitud         INTEGER;
DEFINE iRowid                   INTEGER;
DEFINE cDesglose                CHAR(1);
DEFINE cEtiquetaExcepcion       CHAR(2);
DEFINE cSegmentouno             CHAR(2);
DEFINE cEtiquetauno             CHAR(2);
DEFINE iBusqueda                INTEGER;
DEFINE iCombinacion             INTEGER;
DEFINE iBanTemp                 INTEGER; --Bandera para revisar si la tabla temporal ha sido creada, en caso de que llegue a presentarse error y no se destruya. 
DEFINE sPaso                    INTEGER;
DEFINE iLong     				INTEGER;
DEFINE cEnvio1                  CHAR(10);
DEFINE iTotreg                  INTEGER;
DEFINE cDescMttoBCyCC CHAR(50); 
DEFINE iRecuperacion INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodret                  = '000000'; --EJECUCION EXITOSA
LET cod_ret                  = '00000';
LET iSql_err                 = 0 ;  
LET VSQL                     = '';
LET cTiposolicitud			 = '';
LET cNumsolicitud			 = '';
LET cNumsolicitud2			 = '';
LET dFecha					 = DATE(1) ;
LET dHora					 = '00:00:00';
LET cCliente			     = '';
LET cEstatus				 = '';
LET cComentario				 = '';
LET cCodretParam             = '';
LET cMensajeParam            = '';
LET iLimitePaginacion        = 0;
LET iRegistros               = 0 ;
LET iContador                = 0;
LET iAcumulador              = 0;
LET dFechaHoy                = DATE(1);
LET cSegmento                = '';
LET cEtiqueta                = '';
LET cDescripcion             = '';
LET cExcepcionerror1          = '';
LET cExcepcionerror2         = '';
LET cDescripcionExcepcion    = '';
LET cDescripcionOpcional     = '';
LET cInstitucion             = '';
LET cNumeroSolicitud         = '';
LET cClave_grupo             = '';
-------------------------------------EJECUCION2
LET iSecuencia               = 0;
LET cNumcte                  = '';
LET cNumprod                 = '';
LET cSucursal                = '';
LET cNombre_cte              = '';
LET cNumAnalista             = '';
LET cNombreAnalista          = '';
LET cPerfilAnalista          = '';
LET sRegreso                 = 0 ;
LET iExisteSolicitud         = 0;
LET iRowid                   = 0;
LET cDesglose                = '';
LET cEtiquetaExcepcion       = '';
LET cSegmentouno             = '';
LET cEtiquetauno             = '';
LET iBusqueda                = 0;
LET iCombinacion             = 0;
LET iBanTemp                 = 0;
LET sPaso                    = 0;
LET iLong                    = 0;
LET cEnvio1                  = '';
LET iTotreg                  = 0;
LET cDescMttoBCyCC           = '';
LET iRecuperacion 			 =0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/aplicacion/Carlos/monitor/monitor.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/tmp/mfinis/sp_mon_buro_conssolcredlincred2.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	----------------------------*******BLOQUE DE ERRORES CONTROLADOS
	--------------CONTROL POR PARAMETROS
	IF pEjecucion = 1 OR pEjecucion = 2 THEN
		IF NVL(pEjecucion,'')='' AND NVL(pTipoSolicitud,'') = '' AND NVL(pNumsolicitud,'') = '' AND NVL(pNumcte,'')= '' AND NVL(pFechaIni, '') = '' AND NVL(pFechafin, '') = '' AND NVL(pEstatus,'') = '' AND NVL(pProducto,'') = '' AND NVL(pCve_grupo, '') = '' AND NVL(pSegmento,'') = '' AND NVL(pEtiqueta, '') = '' AND NVL(pAnalista, '') = '' THEN	
			LET cCodret = '000001'; --IMPOSIBLE EJECUTAR PROCEDIMIENTO SIN PARAMETROS
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
	END IF;
	--------------CONTROL DE ERRORES POR EJECUCION
	IF pEjecucion <> 1 AND pEjecucion <> 2 AND pEjecucion <> 3 AND pEjecucion <> 4 THEN
		LET cCodret = '000002'; --ERROR EN PARAMETRO DE TIPO DE EJECUCION
		RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
	END IF;
	
	IF pEjecucion = 1 THEN ---*******************************************************

		--------------CONTROL DE ERRORES DE TIPO DE SOLICITUD
		SELECT descripcion
		INTO cTiposolicitud
		FROM "informix".sd_mon_buro_cattiposol
		WHERE cve_tipo_sol = pTipoSolicitud;
		
		IF cTiposolicitud IS NULL THEN
			LET cCodret = '000003'; --ERROR EN PARAMETRO DE TIPO SOLICITUD
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;

		SELECT fecha_hoy 
		INTO dFechaHoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';
		
		---------------CONTROL DE ERRORES POR FORMATO DE FECHA
		IF NVL(pFechaIni, DATE(1)) <> DATE(1) OR NVL(pFechafin, DATE(1)) <> DATE(1) THEN
		
			IF pFechaIni > dFechaHoy OR pFechafin > dFechaHoy OR pFechaIni > pFechafin THEN
				LET cCodRet = '000004'; --ERROR POR FECHAS
				RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
			END IF;
		ELSE
			LET pFechaIni= DATE(1);
			LET pFechafin= dFechaHoy;			
		END IF;
		----------------------------*******BLOQUE PRINCIPAL*********************************
		---*********************************************************************************

		--- INC 27 000 Se elimina validaciÃ³n para que siempre realice el borrado a la tabla de trabajo. --AAME
		--TRUNCATE TABLE "informix".sd_numsolici_datos_tmp;
		--DELETE FROM "informix".sd_numsolici_datos_tmp2 WHERE user_insert = pAnalista; --LMLA
		--**********************
		IF pTipoSolicitud = '01' THEN --SOLICITUD DE CREDITO
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
		
			FOREACH				
				SELECT UNIQUE(sol.num_solicitud), tra.envio1,sol.fecha_insert, bur.hora, sol.numcte,sol.status_solicitud
				INTO cNumeroSolicitud,cEnvio1,dFecha, dHora, cCliente, cEstatus
				FROM bdisolic:ss_solicitudes sol
				LEFT OUTER JOIN bdiburo:br_auditor bur ON
				(bur.solicitud = sol.num_solicitud AND sol.status_solicitud = bur.institucion
				AND fecha||hora = (SELECT MAX(fecha||hora) FROM bdiburo:br_auditor  WHERE
				solicitud = bur.solicitud AND institucion = bur.institucion))
				LEFT OUTER JOIN bdiburo:sb_regreso reg ON
				 (reg.num_solicitud = sol.num_solicitud AND reg.institucion =sol.status_solicitud)
				LEFT OUTER JOIN bdiburo:br_respuesta_aprocesar resp ON
				 (resp.num_solicitud = sol.num_solicitud AND resp.institucion =sol.status_solicitud) 
				LEFT OUTER JOIN bdiburo:br_traslado tra ON
				(tra.num_solicitud = sol.num_solicitud AND tra.institucion =sol.status_solicitud)
				WHERE sol.fecha_insert BETWEEN pFechaIni AND pFechafin
				AND sol.status_solicitud IN ('BC','CC')
				AND sol.num_solicitud = DECODE(pNumsolicitud,'',sol.num_solicitud,pNumsolicitud)
				AND sol.numcte = DECODE(pNumcte,'',sol.numcte,pNumcte)	
				AND sol.status_solicitud = DECODE(pEstatus,'',sol.status_solicitud,pEstatus)
				AND sol.num_producto = DECODE(pProducto,'',sol.num_producto,pProducto)	

				IF cEnvio1= "0003000400" THEN
					INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
					VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, '09',  '', '', 'Segmento Direccion - DirecciÃ³n incompleta o sin asignar',pAnalista);										
				ELSE 
				--IPCB Junio2016//Limpiado de Variables
					LET cSegmentouno             = '';
					LET cEtiquetauno             = '';
					LET cSegmento                = '';
					LET cEtiqueta                = '';
					LET cInstitucion             = '';
					LET iLong                    = 0;
					LET iRowid                   = 0;
					LET cClave_grupo             = '';
					LET cDescripcion             = '';
					LET cDesglose                = '';
					LET cEtiquetaExcepcion       = '';
					
				 IF EXISTS(SELECT num_solicitud FROM bdiburo:"informix".sb_regreso WHERE institucion = pEstatus and num_solicitud = cNumeroSolicitud) THEN
					SELECT {+INDEX(bdiburo:"informix".sb_regreso idx_solic_institu)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
					INTO cSegmentouno, cEtiquetauno, cSegmento, cEtiqueta, cInstitucion,iLong
					FROM bdisolic:"informix".ss_solicitudes ss, bdiburo:"informix".sb_regreso sb
					WHERE ss.status_solicitud = sb.institucion AND ss.num_solicitud=sb.num_solicitud
					AND SUBSTR(sb.regreso, 1,4) = 'ERRR' --QUE SEAN ERRORES
					AND ss.num_solicitud = cNumeroSolicitud;	
				 ELSE
					SELECT {+INDEX(bdiburo:"informix".br_respuesta br_respuesta_sol)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
					INTO cSegmentouno, cEtiquetauno, cSegmento, cEtiqueta, cInstitucion,iLong
					FROM bdisolic:"informix".ss_solicitudes ss, bdiburo:"informix".br_respuesta sb
					WHERE ss.status_solicitud = sb.institucion AND ss.num_solicitud=sb.num_solicitud
					AND SUBSTR(sb.regreso, 1,4) = 'ERRR' --QUE SEAN ERRORES
					AND ss.num_solicitud = cNumeroSolicitud
					AND secuencia = 1;
				 END IF;	
					IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
						LET cEtiquetaExcepcion = TRIM(cEtiquetauno);
						LET cClave_grupo = pCve_grupo;
						IF iLong >= 4005 THEN
							INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
							VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus,'09',  '', '', 'No se puede procesar respuesta -Longitud excede 4005 caracteres',pAnalista);								
						ELSE
							-----LECTURA DE DESCRIPCION
							IF cEtiquetaExcepcion = '05' THEN
								SELECT (ROWID + 1)
								INTO iRowid
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = cSegmento
								AND etiqueta_suberror = cEtiqueta;
								
								IF iRowid IS NOT NULL THEN
									--SE VACIAN LAS VARIABLES
									LET cSegmento = '';
									LET cEtiqueta = '';
									
									--SE SELECCIONA EL SEGMENTO Y ETIQUETA SIGUIENTES USANDO EL ROWID
									SELECT segmento_suberror, etiqueta_suberror, cve_grupo 
									INTO cSegmento, cEtiqueta, cClave_grupo
									FROM bdiburo:"informix".br_mon_buro_suberrordesglose
									WHERE ROWID = iRowid;
									
								ELIF iRowid IS NULL THEN
									SELECT (ROWID + 1)
									INTO iRowid
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE cve_grupo = cClave_grupo
									AND segmento = cSegmento
									AND etiqueta = cEtiqueta;
									
									--SE VACIAN LAS VARIABLES
									LET cSegmento = '';
									LET cEtiqueta = '';
									
									--SE SELECCIONA EL SEGMENTO Y ETIQUETA SIGUIENTES USANDO EL ROWID
									SELECT segmento, etiqueta , cve_grupo
									INTO cSegmento, cEtiqueta, cClave_grupo
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE ROWID = iRowid;
								END IF;
							ELIF cEtiquetaExcepcion = '06' OR cEtiquetaExcepcion = '07' THEN	

								SELECT cve_grupo
								INTO cClave_grupo
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = cSegmento
								AND etiqueta_suberror = cEtiqueta;
							
							END IF;	
							LET cSegmentouno = cSegmentouno;
							LET cEtiquetauno = cEtiquetauno;
							IF cSegmentouno ='AR' THEN 
								LET cClave_grupo = '01' ;
								LET cSegmento= '';
								LET cEtiqueta= '';
								LET cDescripcion ='';
								
								SELECT descripcion_error
								INTO cDescripcion
								FROM bdiburo:"informix".br_mon_buro_subgruperror
								WHERE cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo);	
								
								INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
								VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
							ELSE
								--CON CADA UNA DE LAS SOLICITUDES LEO LA DESCRIPCION, LA CLAVE y EL CAMPO DESGLOSE
								FOREACH WITH HOLD
									SELECT descripcion_error,cve_grupo, desglose 
									INTO cDescripcion, cClave_grupo, cDesglose
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE segmento = cSegmentouno
									AND etiqueta = cEtiquetauno
									AND cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo)
									
									--********************
									IF (NVL(cSegmento,'') = 'YE' AND NVL(cEtiqueta, '') = 'S0') OR  NVL(cSegmento,'') = '' AND NVL(cEtiqueta, '') = '' THEN
											SELECT TRIM(descripcion_error) 
											INTO cDescripcion
											FROM bdiburo:"informix".br_mon_buro_subgruperror 
											WHERE segmento = cSegmentouno
											AND etiqueta = cEtiquetauno;
												
									 END IF;
									--********************
									--SI EL DESGLOSE ES 0 SE QUEDA CON LA MISMA DESCRIPCION
									IF NVL(cDesglose,'') = '0' THEN
										--SE QUEDA CON LA MISMA DESCRIPCIONES Y SE INSERTA EN LA TABLA
										 INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
										 VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo, cSegmento, cEtiqueta, cDescripcion,pAnalista);
									ELSE
										--USANDO AL CLAVE DEL GRUPO
											LET cClave_grupo = cClave_grupo ;
											LET cSegmento= cSegmento;
											LET  cEtiqueta= cEtiqueta;
											
											SELECT descripcionsuberror
											INTO cDescripcion
											FROM bdiburo:"informix".br_mon_buro_suberrordesglose
											WHERE segmento_suberror = cSegmento
											AND etiqueta_suberror = cEtiqueta
											AND cve_grupo = cClave_grupo;
									
										INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
										VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);
									END IF;
								END FOREACH;
							--INC 27 052 AAME 2014-01-15 Se agrega validaciÃ³n para que se registre un valor de error por default en caso de no encontrarse en la clasificaciÃ³n
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cClave_grupo = '06' ;
									LET cSegmento= '';
									LET cEtiqueta= '12';
									LET cDescripcion ='';
									
									SELECT descripcion_error
									INTO cDescripcion
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo)
									AND etiqueta = DECODE (cEtiqueta,'',etiqueta,cEtiqueta);
									
									INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
									VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
										
								END IF;								
							END IF;	
						END IF;
					ELSE
					    
					    IF (SELECT status FROM BDIBURO:br_traslado where num_solicitud=cNumeroSolicitud and institucion=cEstatus)=3 THEN
				            LET cClave_grupo='03';
				            LET cSegmento= '';
						    LET cEtiqueta= '';
				        ELSE
                            LET cClave_grupo='07';
                            LET cSegmento= '';
                            LET cEtiqueta= '';		
                        END IF;
                        
						SELECT descripcion_grupo
						INTO cDescripcion
						FROM bdiburo: "informix".br_mon_buro_grupoerror
						WHERE cve_grupo = cClave_grupo;
						
						INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
						VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);																
					END IF;
				END IF;
			END FOREACH;	
		ELSE  --INCREMENTO DE LINEA
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			FOREACH			
				SELECT {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_solicitud)} DISTINCT(sol.num_solicitud), tra.envio1,sol.fecha_insert, bur.hora, sol.numcte,sol.status
				INTO cNumeroSolicitud,cEnvio1,dFecha, dHora, cCliente, cEstatus
				FROM bdicred:"informix".sd_bitacora_aumlincred sol
				LEFT OUTER JOIN bdiburo:br_auditor bur ON
				(bur.solicitud = sol.num_solicitud AND sol.status = bur.institucion
				AND fecha||hora = (SELECT MAX(fecha||hora) FROM bdiburo:br_auditor  WHERE
				solicitud = bur.solicitud AND institucion = bur.institucion))
				LEFT OUTER JOIN bdiburo:br_traslado tra ON
				(tra.num_solicitud = sol.num_solicitud AND tra.institucion =sol.status)
				WHERE sol.fecha_status IN (SELECT MAX(fecha_status) FROM bdicred:"informix".sd_bitacora_aumlincred 
											WHERE status=sol.status AND num_solicitud = sol.num_solicitud)
				AND	sol.fecha_insert BETWEEN pFechaIni AND pFechafin
				AND sol.status IN ('BC','CC')
				AND sol.empresa = '001'
				AND sol.num_solicitud = DECODE(pNumsolicitud,'',sol.num_solicitud,pNumsolicitud)
				AND sol.numcte = DECODE(pNumcte,'',sol.numcte,pNumcte)	
				AND sol.status = DECODE(pEstatus,'',sol.status,pEstatus)
				AND sol.num_producto = DECODE(pProducto,'',sol.num_producto,pProducto)	
				AND sol.origen = "S" 				
				
				IF cEnvio1= "0003000400" THEN
					INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
					VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, '09',  '', '', 'Segmento Direccion - DirecciÃ³n incompleta o sin asignar',pAnalista);										
				ELSE
				--IPCB Junio2016//Limpiado de Variables
					LET cSegmentouno             = '';
					LET cEtiquetauno             = '';
					LET cSegmento                = '';
					LET cEtiqueta                = '';
					LET cInstitucion             = '';
					LET iLong                    = 0;
					LET iRowid                   = 0;
					LET cClave_grupo             = '';
					LET cDescripcion             = '';
					LET cDesglose                = '';
					LET cEtiquetaExcepcion       = '';				
				  IF EXISTS(SELECT num_solicitud FROM bdiburo:"informix".sb_regreso WHERE institucion = pEstatus and num_solicitud = cNumeroSolicitud) THEN	
					SELECT {+INDEX(bdiburo:"informix".sb_regreso idx_solic_institu)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
					INTO cSegmentouno, cEtiquetauno, cSegmento, cEtiqueta, cInstitucion,iLong
					FROM bdicred:"informix".sd_bitacora_aumlincred sd, bdiburo:"informix".sb_regreso sb
					WHERE sd.status = sb.institucion AND sd.num_solicitud=sb.num_solicitud
					AND SUBSTR(sb.regreso, 1,4) = 'ERRR' --QUE SEAN ERRORES
					AND sd.num_solicitud = cNumeroSolicitud;	
				 ELSE
					SELECT {+INDEX(bdiburo:"informix".br_respuesta br_respuesta_sol)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
					INTO cSegmentouno, cEtiquetauno, cSegmento, cEtiqueta, cInstitucion,iLong
					FROM bdicred:"informix".sd_bitacora_aumlincred sd, bdiburo:"informix".br_respuesta sb
					WHERE sd.status = sb.institucion AND sd.num_solicitud=sb.num_solicitud
					AND SUBSTR(sb.regreso, 1,4) = 'ERRR' --QUE SEAN ERRORES
					AND sd.num_solicitud = cNumeroSolicitud;
				 END IF;	
					
					IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
						LET cEtiquetaExcepcion = TRIM(cEtiquetauno);
						LET cClave_grupo = pCve_grupo;
						IF iLong >= 4005 THEN
							INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
							VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus,'09',  '', '', 'No se puede procesar respuesta -Longitud excede 4005 caracteres',pAnalista);														
						ELSE
							-----LECTURA DE DESCRIPCION
							IF cEtiquetaExcepcion = '05' THEN
								SELECT (ROWID + 1)
								INTO iRowid
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = cSegmento
								AND etiqueta_suberror = cEtiqueta;
								
								IF iRowid IS NOT NULL THEN
									--SE VACIAN LAS VARIABLES
									LET cSegmento = '';
									LET cEtiqueta = '';
									
									--SE SELECCIONA EL SEGMENTO Y ETIQUETA SIGUIENTES USANDO EL ROWID
									SELECT segmento_suberror, etiqueta_suberror, cve_grupo 
									INTO cSegmento, cEtiqueta, cClave_grupo
									FROM bdiburo:"informix".br_mon_buro_suberrordesglose
									WHERE ROWID = iRowid;
									
								ELIF iRowid IS NULL THEN
									SELECT (ROWID + 1)
									INTO iRowid
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE cve_grupo = cClave_grupo
									AND segmento = cSegmento
									AND etiqueta = cEtiqueta;
									
									--SE VACIAN LAS VARIABLES
									LET cSegmento = '';
									LET cEtiqueta = '';
									
									--SE SELECCIONA EL SEGMENTO Y ETIQUETA SIGUIENTES USANDO EL ROWID
									SELECT segmento, etiqueta , cve_grupo
									INTO cSegmento, cEtiqueta, cClave_grupo
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE ROWID = iRowid;
								END IF;
							ELIF cEtiquetaExcepcion = '06' OR cEtiquetaExcepcion = '07' THEN	
								SELECT cve_grupo
								INTO cClave_grupo
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = cSegmento
								AND etiqueta_suberror = cEtiqueta;
							
							END IF;	
							IF cSegmentouno ='AR' THEN 
								LET cClave_grupo = '01' ;
								LET cSegmento= '';
								LET cEtiqueta= '';
								LET cDescripcion ='';
								
								SELECT descripcion_error
								INTO cDescripcion
								FROM bdiburo:"informix".br_mon_buro_subgruperror
								WHERE cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo);	
								
								INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
								VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				

							ELSE
								--CON CADA UNA DE LAS SOLICITUDES LEO LA DESCRIPCION, LA CLAVE y EL CAMPO DESGLOSE
								FOREACH WITH HOLD
									SELECT descripcion_error,cve_grupo, desglose 
									INTO cDescripcion, cClave_grupo, cDesglose
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE segmento = cSegmentouno
									AND etiqueta = cEtiquetauno
									AND cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo)
									
									--********************
									IF (NVL(cSegmento,'') = 'YE' AND NVL(cEtiqueta, '') = 'S0') OR  NVL(cSegmento,'') = '' AND NVL(cEtiqueta, '') = '' THEN																		
											SELECT  TRIM(descripcion_error) 
											INTO cDescripcion
											FROM bdiburo:"informix".br_mon_buro_subgruperror 
											WHERE segmento = cSegmentouno
											AND etiqueta = cEtiquetauno;												
									 END IF;
									--********************
									--SI EL DESGLOSE ES 0 SE QUEDA CON LA MISMA DESCRIPCION
									IF NVL(cDesglose,'') = '0' THEN
										--SE QUEDA CON LA MISMA DESCRIPCIONES Y SE INSERTA EN LA TABLA
										 INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
										 VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
									ELSE
										--USANDO AL CLAVE DEL GRUPO
											SELECT descripcionsuberror
											INTO cDescripcion
											FROM bdiburo:"informix".br_mon_buro_suberrordesglose
											WHERE segmento_suberror = cSegmento
											AND etiqueta_suberror = cEtiqueta
											AND cve_grupo = cClave_grupo;
									
											INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
											VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
									END IF;
								END FOREACH;
							--INC 27 052 AAME 2014-01-15 Se agrega validaciÃ³n para que se registre un valor de error por default en caso de no encontrarse en la clasificaciÃ³n
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cClave_grupo = '06' ;
									LET cSegmento= '';
									LET cEtiqueta= '12';
									LET cDescripcion ='';
									
									SELECT descripcion_error
									INTO cDescripcion
									FROM bdiburo:"informix".br_mon_buro_subgruperror
									WHERE cve_grupo = DECODE(cClave_grupo,'',cve_grupo,cClave_grupo)
									AND etiqueta = DECODE (cEtiqueta,'',etiqueta,cEtiqueta);	
									
									INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
									VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
										
								END IF;								
							END IF;								
						END IF;
					ELSE
					    IF (SELECT status FROM BDIBURO:br_traslado where num_solicitud=cNumeroSolicitud and institucion=cEstatus)=3 THEN
				            LET cClave_grupo='03';
				            LET cSegmento= '';
						    LET cEtiqueta= '';
				        ELSE
                            LET cClave_grupo='07';
                            LET cSegmento= '';
                            LET cEtiqueta= '';		
                        END IF;
						SELECT descripcion_grupo
						INTO cDescripcion
						FROM bdiburo: "informix".br_mon_buro_grupoerror
						WHERE cve_grupo = cClave_grupo;
						
						INSERT INTO "informix".sd_numsolici_datos_tmp2 (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
						VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);										
					END IF;
				END IF;
			END FOREACH;			
		END IF;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_numsolici_datos_tmp2;
		--SE VACIAN LAS VARIABLES PARA PDOER VOLVER A UTILIZARLAS			
		LET cClave_grupo = '';
		LET cSegmento    = '';
		LET cEtiqueta    = '';		
		------SE INSERTA EN LA TABLA TEMPORAL PARA EL REGISTRO DE LOS DATOS
				LET iBanTemp=1;
				FOREACH	
					SELECT DISTINCT(num_solicitud), fecha_insert, hora, numcte,status, descripcion,clave, segmento, etiqueta
					INTO cNumsolicitud, dFecha, dHora, cCliente, cEstatus, cComentario, cClave_grupo, cSegmento, cEtiqueta
					FROM bdicred:"informix".sd_numsolici_datos_tmp2
					WHERE clave = DECODE(pCve_grupo,'',clave,pCve_grupo) AND user_insert = pAnalista --LMLA

					--VALIDACION PARA CONTROLAR NO. DE RETORNOS SEGUN PARAMETRO CONSULTADO PREVIAMENTE

						--SE AGREGA VALIDACION YA QUE NO RESPETA EL NVL EN ESTE FLUJO
						IF dHora IS NULL THEN 
							LET dHora = CURRENT;
						END IF;
						RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , NVL(dFecha,DATE(1)), dHora, NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'')  WITH RESUME;
					   LET iContador= iContador + 1; --CADA VEZ QUE RETORNA AUMENTA 1

					------VARIABLE QUE BARRE Y CUENTA EL TOTAL DE REGISTROS
				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN

					   SELECT COUNT(*) 
					   INTO iRegistros
					   FROM sd_numsolici_datos_tmp2
					   WHERE clave = DECODE(pCve_grupo,'',clave,pCve_grupo) AND user_insert = pAnalista; --LMLA

		--				ENCUENTRE MAS REGISTROS DEVUELVE UNA ÃLTIMA LINEA
						LET cCodret = 'TOTAL';
						LET cTiposolicitud = ''; 
						LET cNumsolicitud = ''; 
						LET cCliente = '';
						LET cEstatus = '';
						LET cComentario= '';
						LET dFecha = DATE(1); 
						LET dHora  = CURRENT;
						LET cClave_grupo = '';
						LET cSegmento    = '';
						LET cEtiqueta    = '';	
						RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;																			
				ELSE
					LET cCodRet = '000005'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN cCodret, '', '',DATE(1), CURRENT, '', '', '', 0, '','', '';					
				END IF;				

	ELIF pEjecucion = 2 THEN---*******************************************************	
		-----ERRORES CONTROLADOS DE PARAMETROS
		IF pTipoSolicitud NOT IN (SELECT cve_tipo_sol FROM "informix".sd_mon_buro_cattiposol) THEN
			LET cCodret = '000006'; --NO EXISTE ESE TIPO DE SOLICITUD
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
		
		IF NVL(pAnalista,'') = '' OR NVL(pNumsolicitud,'') = ''  THEN
			LET cCodret = '000007'; --NO SE PUEDE EJECUTAR EN ESTE MODO SIN PARAMETROS
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
		
		--SE ASEGURA QUE EXISTA Y SI ES ASI SE ELIGE CUALQUIER PERFIL
		SELECT LIMIT 1 pues.descripcion_puesto
		INTO cPerfilAnalista
		FROM "informix".sd_perfiles_cac_aumlincred per
		LEFT OUTER JOIN "informix".sd_puestos_cac_aumlincred pues ON (pues.puesto = per.puesto)
		WHERE per.empresa = '001'
		AND per.ejecutivo = pAnalista;
	
		SELECT ejecutivo,nombre 
		INTO cNumAnalista, cNombreAnalista
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pAnalista;

		IF cPerfilAnalista IS NULL THEN
			LET cPerfilAnalista = 'Analista de CrÃ©dito';
		END IF;

		
		IF pTipoSolicitud = '01' THEN --SOLICITUD DE CREDITO
			LET pTipoSolicitud = '1'; --SE HACEN CHAR DE 1 PARA LA POSTERIOR INSERCION
			
			FOREACH
				    SELECT LIMIT 1 sol.numcte, sol.num_solicitud, sol.num_producto, sol.sucursal,TRIM(cli.nombre1)||" "||TRIM(cli.nombre2)||" "||TRIM(cli.apell_paterno)||" "||TRIM(cli.apell_materno) AS nombre_cliente, sol.fecha_insert, aud.hora, sol.status_solicitud  
					INTO cNumcte, cNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus
					FROM bdisolic:"informix".ss_solicitudes sol      
					LEFT OUTER JOIN bdiburo:"informix".br_auditor aud ON (aud.solicitud = sol.num_solicitud AND aud.fecha =(SELECT MAX(fecha) FROM bdiburo:"informix".br_auditor WHERE solicitud = sol.num_solicitud) )      
					LEFT OUTER JOIN bdinteg:"informix".si_cliente cli ON  (cli.numcte = sol.numcte) 
					WHERE sol.num_solicitud = pNumsolicitud	
					ORDER BY aud.hora DESC 
					
					LET iRecuperacion = iRecuperacion + 1;
					
					IF dHora IS NULL THEN
						LET dHora = '00:00:00';
					END IF;

--HACE EL ENVIO
		----------SI EL PROBLEMA FUE ERROR DE CONEXION SEA CUAL SEA EL ESTATUS EJECUTA ESTE SP
		IF pCve_grupo = '08' THEN
			EXECUTE PROCEDURE bdiburo:"informix".actualizarRegistroBuro( TRIM(pEstatus) , TRIM(pNumsolicitud) , '0', '')
			INTO cCodret  ; --REGRESA UN CHAR DE 6
			
			IF cCodret <> '000000' THEN
					LET cCodret = '000009';
					RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
			END IF;

		----------SI EL PROBLEMA NO FUE ERROR DE CONEXION
		ELIF pCve_grupo<> '08' THEN
		
			IF pEstatus = 'CC' THEN
				EXECUTE PROCEDURE bdiburo:"informix".burocred('001','101', TRIM(pAnalista),TRIM(pNumsolicitud) ,2000)
				INTO cCodret  ; --REGRESA UN CHAR DE 5
				
				IF cCodret <> '000' THEN
					LET cCodret = '000009';
					RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
			
				END IF;
			ELIF pEstatus = 'BC' THEN

				EXECUTE PROCEDURE bdiburo:"informix".ins_buro_credito (TRIM(pEstatus),'001', TRIM(pNumsolicitud), TRIM(cNumcte), TODAY, TODAY,'','','',1)
				INTO cCodret  ; --REGRESA UN CHAR DE 1 , un '1' si es Ãxito
				
				IF cCodret <> '1' THEN
						LET cCodret = '000009';
						RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
				END IF;
			END IF;
			
		END IF;
		
		-- 1370-MttoBCyCC, RQM  09 308, Obtener el estatus actual de la solicitud
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_statusmttobcycc( '001', pNumsolicitud, pTipoSolicitud )
		INTO cod_ret, cDescMttoBCyCC;
		
		LET iSecuencia = 0; --SE INICIALIZA LA VARIABLE
		
		--SE SELECCIONA LA MAXIMA SECUENCIA Y SE CREA LA NUEVA SECUENCIA
		SELECT (NVL(MAX(secuencia),0) + 1)
		INTO iSecuencia 
		FROM  bdisolic:"informix".ss_mon_buro_rep;
		--WHERE secuencia = secuencia
		--AND empresa = '001';
		
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';

		IF cNumprod = '6001' THEN 
			SELECT LIMIT 1 num_solicitud
			INTO cNumsolicitud2 
			FROM bdisolic:"informix".ss_solicitudes_sic
			where numcte = pNumcte
			AND num_solicitud > ''
			AND num_solicitud <> pNumsolicitud
			---AND SUBSTR(num_solicitud,1,4) ='6500'
			AND num_solicitud_sic = pNumsolicitud
			AND fecha_sic is null;
			
		ELIF cNumprod = '6500' THEN	
			SELECT LIMIT 1 num_solicitud_sic
			INTO cNumsolicitud2 
			FROM bdisolic:"informix".ss_solicitudes_sic
			where  numcte = pNumcte
			AND num_solicitud > ''
			AND num_solicitud = pNumsolicitud
			AND fecha_sic is null;
			
			IF  cNumsolicitud2 = pNumsolicitud THEN
				LET cNumsolicitud2 ='';
			END IF;
		END IF;
	
		
		--INSERTA EN LA TABLA LOS VALORES
		INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) 
		VALUES (iSecuencia, '001', pTipoSolicitud, cNumcte, pNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
	
		IF NVL(cNumsolicitud2,'') <> '' AND cNumprod = '6500' THEN
			INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) VALUES 
			(iSecuencia+1, '001', pTipoSolicitud, cNumcte, cNumsolicitud2, '6001', cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
		ELIF NVL(cNumsolicitud2,'') <> '' AND cNumprod = '6001' THEN
			INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) VALUES 
			(iSecuencia+1, '001', pTipoSolicitud, cNumcte, cNumsolicitud2, '6500', cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
		END IF;
	
		
		
					RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'') WITH RESUME;		
			END FOREACH;
			
		ELSE  --INCREMENTO DE LINEA
			LET pTipoSolicitud = '2'; --SE HACEN CHAR DE 1 PARA LA POSTERIOR INSERCION
		
			FOREACH
					SELECT LIMIT 1 sol.numcte, sol.num_solicitud, sol.num_producto, sol.sucursal, TRIM(cli.nombre1)||" "||TRIM(cli.nombre2)||" "||TRIM(cli.apell_paterno)||" "||TRIM(cli.apell_materno) AS nombre_cliente ,sol.fecha_insert, aud.hora, sol.status 
					INTO cNumcte, cNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus
					FROM "informix".sd_bitacora_aumlincred sol
					LEFT OUTER JOIN bdiburo:"informix".br_auditor aud ON (aud.solicitud = sol.num_solicitud AND aud.fecha =(SELECT MAX(fecha) FROM bdiburo:"informix".br_auditor WHERE solicitud = sol.num_solicitud) ) 
					LEFT OUTER JOIN bdinteg:"informix".si_cliente cli ON  (cli.numcte = sol.numcte)
					WHERE sol.fecha_status IN (SELECT MAX(fecha_status) FROM bdicred:"informix".sd_bitacora_aumlincred where num_solicitud=sol.num_solicitud) AND sol.num_solicitud = pNumsolicitud		
					ORDER BY aud.hora DESC 
			
					LET iRecuperacion = iRecuperacion + 1;
					
					IF dHora IS NULL THEN
						LET dHora = '00:00:00';
					
					END IF;
					
--HACE EL ENVIO
		----------SI EL PROBLEMA FUE ERROR DE CONEXION SEA CUAL SEA EL ESTATUS EJECUTA ESTE SP
		IF pCve_grupo = '08' THEN
			EXECUTE PROCEDURE bdiburo:"informix".actualizarRegistroBuro( TRIM(pEstatus) , TRIM(pNumsolicitud) , '0', '')
			INTO cCodret  ; --REGRESA UN CHAR DE 6
			
			IF cCodret <> '000000' THEN
					LET cCodret = '000009';
					RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
			END IF;

		----------SI EL PROBLEMA NO FUE ERROR DE CONEXION
		ELIF pCve_grupo<> '08' THEN
		
			IF pEstatus = 'CC' THEN
				EXECUTE PROCEDURE bdiburo:"informix".burocred('001','101', TRIM(pAnalista),TRIM(pNumsolicitud) ,2000)
				INTO cCodret  ; --REGRESA UN CHAR DE 5
				
				IF cCodret <> '000' THEN
					LET cCodret = '000009';
					RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
			
				END IF;
			ELIF pEstatus = 'BC' THEN

				EXECUTE PROCEDURE bdiburo:"informix".ins_buro_credito (TRIM(pEstatus),'001', TRIM(pNumsolicitud), TRIM(cNumcte), TODAY, TODAY,'','','',1)
				INTO cCodret  ; --REGRESA UN CHAR DE 1 , un '1' si es Ãxito
				
				IF cCodret <> '1' THEN
						LET cCodret = '000009';
						RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
				END IF;
			END IF;
			
		END IF;
		
		-- 1370-MttoBCyCC, RQM  09 308, Obtener el estatus actual de la solicitud
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_statusmttobcycc( '001', pNumsolicitud, pTipoSolicitud )
		INTO cod_ret, cDescMttoBCyCC;
		
		LET iSecuencia = 0; --SE INICIALIZA LA VARIABLE
		
		--SE SELECCIONA LA MAXIMA SECUENCIA Y SE CREA LA NUEVA SECUENCIA
		SELECT (NVL(MAX(secuencia),0) + 1)
		INTO iSecuencia 
		FROM  bdisolic:"informix".ss_mon_buro_rep;
		--WHERE secuencia = secuencia
		--AND empresa = '001';
		
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';

		IF cNumprod = '6001' THEN 
			SELECT LIMIT 1 num_solicitud
			INTO cNumsolicitud2 
			FROM bdisolic:"informix".ss_solicitudes_sic
			where numcte = pNumcte
			AND num_solicitud > ''
			AND num_solicitud <> pNumsolicitud
			---AND SUBSTR(num_solicitud,1,4) ='6500'
			AND num_solicitud_sic = pNumsolicitud
			AND fecha_sic is null;
			
		ELIF cNumprod = '6500' THEN	
			SELECT LIMIT 1 num_solicitud_sic
			INTO cNumsolicitud2 
			FROM bdisolic:"informix".ss_solicitudes_sic
			where  numcte = pNumcte
			AND num_solicitud > ''
			AND num_solicitud = pNumsolicitud
			AND fecha_sic is null;
			
			IF  cNumsolicitud2 = pNumsolicitud THEN
				LET cNumsolicitud2 ='';
			END IF;
		END IF;
	
		
		--INSERTA EN LA TABLA LOS VALORES
		INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) 
		VALUES (iSecuencia, '001', pTipoSolicitud, cNumcte, pNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
	
		IF NVL(cNumsolicitud2,'') <> '' AND cNumprod = '6500' THEN
			INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) VALUES 
			(iSecuencia+1, '001', pTipoSolicitud, cNumcte, cNumsolicitud2, '6001', cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
		ELIF NVL(cNumsolicitud2,'') <> '' AND cNumprod = '6001' THEN
			INSERT INTO bdisolic: "informix".ss_mon_buro_rep (secuencia, empresa, tipo_sol, numcte, numsolicitud, producto, sucursal, nombre_cte, fecha_sol, hora, estatus, reenvio_exit, fecha_reenvio, estatus_fin, cve_grupo, cve_segmento, cve_etiqueta, numempanalista, nombre_analista, perfil_usu,motivo_reenvio) VALUES 
			(iSecuencia+1, '001', pTipoSolicitud, cNumcte, cNumsolicitud2, '6500', cSucursal, cNombre_cte, dFecha, dHora, cEstatus, '0', TODAY, ' ', pCve_grupo, pSegmento, pEtiqueta, cNumAnalista, cNombreAnalista, cPerfilAnalista, pComentario);
		END IF;
	
		
	
				RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'') WITH RESUME;		
				END FOREACH;
		END IF;
				
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');		
		END IF;
		
		
		
		
		
		-----------------RETORNO SENCILLO PARA INDICAR QUE SE LLEVO  CABO EL PROCESO
		LET cCodret = '000000';
		LET cTiposolicitud = TRIM(pTipoSolicitud);
		LET dFecha					 = DATE(1) ;
		LET dHora					 = CURRENT;
		LET cCliente			     = '';
		LET cEstatus				 = '';
		LET cComentario				 = '';
		LET cClave_grupo             = '';
		LET cSegmento                = '';
		LET cEtiqueta                = '';
		RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;	
	ELIF pEjecucion = 3 THEN		
		IF NVL(pTipoSolicitud,'') = '' AND NVL(pNumsolicitud,'') = ''  THEN
			LET cCodret = '000001'; --IMPOSIBLE EJECUTAR PROCEDIMIENTO SIN PARAMETROS
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;		
		IF pTipoSolicitud <> '01' AND pTipoSolicitud <> '02' THEN
			LET cCodret = '000002'; --ERROR EN PARAMETRO DE TIPO DE EJECUCION
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;		
		---VERIFICA SI HAY RESPUESTA EN LA SB_REGRESO
		SELECT COUNT(*) 
		INTO sRegreso
		FROM bdiburo:"informix".sb_regreso 
		WHERE num_solicitud = pNumsolicitud
		AND institucion IN ('BC','CC');
		
		IF sRegreso = 0 THEN
			SELECT COUNT(*) 
			INTO sRegreso
			FROM bdiburo:"informix".br_respuesta_aprocesar 
			WHERE num_solicitud = pNumsolicitud
			AND institucion IN ('BC','CC');
		END IF;
	
		IF sRegreso > 0 THEN --SI ENCONTRO LA SOLICITUD EN LA REGRESO			
			--RECIBIR LA SOLICITUD Y EL TIPO DE SOLICITUD 
			--VERIFICAR SEGUN EL TIPO DE SOLICITUD EN QUE ESTATUS ESTA AHORA
			IF pTipoSolicitud = '01' THEN --SOLICITUD DE CRÃDITO
				SELECT status_solicitud
				INTO cEstatus
				FROM bdisolic:"informix".ss_solicitudes
				WHERE num_solicitud = pNumsolicitud;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000008'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
				END IF	
				
			ELIF pTipoSolicitud = '02' THEN --INCREMENTO DE LINEA
				SELECT LIMIT 1 status
				INTO cEstatus
				FROM "informix".sd_bitacora_aumlincred
				WHERE num_solicitud = pNumsolicitud
				AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sd_bitacora_aumlincred WHERE num_solicitud = pNumsolicitud);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000008'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
				END IF					
			END IF;
				SELECT descripcion
				INTO cTiposolicitud
				FROM "informix".sd_mon_buro_cattiposol
				WHERE cve_tipo_sol = pTipoSolicitud;
			--INICIALIZAR LAS VARIABLES QUE NO SE VAN A USAR Y RETORNAR EL TIPO DE SOLICITUD, EL NUMERO Y EL ESTATUS EN QUE ESTA AHORA
			LET cNumsolicitud = TRIM(pNumsolicitud);
			LET dFecha = DATE(1);
			LET dHora = CURRENT;
			LET cCliente = '';
			LET cComentario = '';
			LET iRegistros = 0;
			LET cClave_grupo = '';
			LET cSegmento = '';
			LET cEtiqueta = '';					
			RETURN cCodret, TRIM(cTiposolicitud), TRIM(cNumsolicitud) , dFecha, dHora, TRIM(cCliente), TRIM(cEstatus), TRIM(cComentario), iRegistros, TRIM(cClave_grupo), TRIM(cSegmento), TRIM(cEtiqueta) ;
		ELSE
			LET cCodret = '000008'; --NO HAY RESPUESTA DE BURO DE CREDITO
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
	ELIF pEjecucion = 4 THEN
		RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
	END IF; ---FIN DEL IF DE TIPO DE EJECUCION
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO QUE TIENE DOS MODOS DE EJECUCIÃN ',
'             1.-CONSULTA SENCILLA: REALIZA UNA CONSULTA SENCILLA POR MEDIO DE DISTINTOS,',
'                FILTROS COMO RANGO DE FECHA, NO. DE SOLICITUD, NO. DE CLIENTE, ESTATUS',
'                O PRODUCTO.',
'             2.- CONSULTA/ENVIO A BC: REALIZA UNA CONSULTA DE DATOS PARA DESPUES USARLOS',
'                 AL EJECUTAR PROCEDIMIENTOS QUE REALIZAN EL ENVIO DE SOLICITUDES A BC.',
'             3.-VERIFICA SI HAY RESPUESTA DE BURO DE CREDITO',
'FECHA DE CREACIÃN: 07 DE JUNIO DE 2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 201306071200',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/11/2016',
'DESCRIPCION: Se crea el spl clon bdicred-sp_mon_buro_conssolcredlincred2 para poder hacer el cambio de la sentencia TRUNCATE por DELETE.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 16/02/2017',
'DESCRIPCION: Se agrega filtro por user_insert al manejo de la tabla bdicred:sd_numsolici_datos_tmp2 (tabla clon de bdicred:sd_numsolici_datos_tmp).';

CREATE PROCEDURE "informix".sp_gener_saldos_cred_vencidos_ipab()
RETURNING char(6) ,CHAR(100),char(100);

	------------------------------------
	--DECLARACIONES
	DEFINE dfechacorte  date;
	DEFINE dfechainicio  date;
	DEFINE CODIGO_ERROR  NUMERIC(6);
	DEFINE cCod_ret CHAR(6);
	DEFINE cMensaje char(100);
	DEFINE cMensajeRet char(100);
	DEFINE cMensajeRet2 char(100);
	DEFINE Ini_proc date;
	DEFINE Fin_proc date;
	DEFINE v_num_credito CHAR(20);
	DEFINE v_numcte CHAR(20);
	DEFINE v_moneda integer;
	DEFINE v_segmento integer;
	DEFINE v_cobranza integer;
	DEFINE v_sdo_vencido decimal(18,2);
	DEFINE v_cap_vencido decimal(18,2);
	DEFINE v_int_ordinario decimal(14);
	DEFINE v_moratorios decimal(14);
	DEFINE v_otros integer;
	DEFINE sql_err integer;
	DEFINE isam_err varchar(22);
	DEFINE error_info varchar(22);
	------------------------------------
	
	------------------------------------
	--INICIALIZACIONES
	LET cCod_Ret = '000000';
	LET cMensaje = 'PROCESO EXITOSO.';
	LET	cMensajeRet = '';
	LET	cMensajeRet2 = '';
	LET dfechacorte = date(1);
	LET dfechainicio = date(1);
	LET v_num_credito = "";
	LET v_numcte = "";
	LET v_moneda = '';
	LET v_segmento = 0;
	LET v_cobranza = 0;
	LET v_sdo_vencido = 0;
	LET v_cap_vencido = 0;
	LET v_int_ordinario = 0;
	LET v_moratorios = 0;
	LET v_otros = "";
	LET sql_err = 0;
	LET	isam_err = '';
	LET error_info = '';
	LET Ini_proc = date(1);
	LET Fin_proc = date(1);
	------------------------------------


	BEGIN
        ON EXCEPTION SET sql_err
           IF sql_err != 0 THEN
              LET cCod_ret=sql_err;
			  LET cMensajeRet = error_info;
			  SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Fin_proc FROM sysmaster:sysshmvals;
			  LET cMensajeRet2 = 'ERROR en el proceso Inicio: '||Ini_proc||' Fin: '||Fin_proc ;
              RETURN cCod_ret, cMensajeRet, cMensajeRet2;
           END IF;
        END EXCEPTION;
	
	--SET DEBUG FILE TO "/ifxsif01/Link/ipab.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-------- Fecha Inicio de Mes "dfechainicio"
	SELECT  pri_dia_mes
	INTO  dfechainicio
	FROM sd_fechas
	WHERE empresa='001';
	
	-------- Fecha Fin de Mes "dfechacorte"
	LET dfechacorte = dfechainicio -1;
	LET dfechainicio = mdy(month(dfechacorte),1,year(dfechacorte));
	
	SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
	FROM sysmaster:sysshmvals;
	
	
	if  day (dfechacorte) = 31 then 
		
		--Universo Credito consumo revolvent
		select a.num_producto,a.numcte,a.num_credito,status_cred_31 status_cred ,  
			capvig31 cap_vigente,  captrans31 cap_vencido,intvig31 int_vigente,  intvenc31 int_vencido,moratorios31 moratorios
		from bdicred:sd_maecredcont a inner join bdicred:sd_sdodiario d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		inner join bdicred:sd_maesdoscont b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha
		where a.fecha = dfechacorte
		and a.fecha_apertura <= a.fecha
		and a.status_Cred  in ('E3','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso with no log;
		--  176646 record(s) affected

		select num_credito, numcte, 1 moneda, 
			case when  num_producto = '7800' then 4 else 3 end segmento, 
			1 cobranza , cap_vencido+int_vigente+int_vencido  sdo_vencido, cap_vencido, int_vigente+int_vencido int_ordinario, moratorios, 0 otros
		from paso
		into temp tbla4 with no log;

		-- 176646 record(s) affected 

		--Base Credito consumo plazo
		select a.num_producto,a.numcte,a.num_credito, status_cred_31,captrans31 cap_vencido,
			(d.intvenc31-d.int_venc_bal31 +d.intvig31) int_orden31, 
			(case when d.int_venc_bal31 >= 0 then d.int_venc_bal31 else 0 end) int_venc_bal31,
			nvl(monto,0) int_pa
			,sdo_moratorio + sdo_contab_mora moratorios
		from bdicred:sd_maecredcontcrd a
		inner join bdicred:sd_sdodiariocrd d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		left join  bdicred:sd_maeretenido c on a.num_credito = c.num_Credito and c.transacc = '8374'
		inner join bdicred:sd_maesdoscontcrd b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha 
		where a.fecha = dfechacorte
		and a.status_Cred  in ('E3','VP','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso2 with no log;

		-- 132326 record(s) affected

		--Universo integrado saldos  consumo plazo
		insert into tbla4
		select num_credito, numcte, 1 moneda, 4 segmento, 1 cobranza ,(cap_vencido+int_orden31+ int_venc_bal31+ int_pa) sdo_vencido,
			cap_vencido,(int_orden31+ int_venc_bal31+ int_pa) interes_ordinario, moratorios ,
			0 otros
		from paso2;
		--  132326 record(s) affected
		
		
		
	ELIF day (dfechacorte) = 30 THEN
		
		--Universo Credito consumo revolvent
		select a.num_producto,a.numcte,a.num_credito,status_cred_30 status_cred ,  
			capvig30 cap_vigente,  captrans30 cap_vencido,intvig30 int_vigente,  intvenc30 int_vencido,moratorios30 moratorios
		from bdicred:sd_maecredcont a inner join bdicred:sd_sdodiario d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		inner join bdicred:sd_maesdoscont b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha
		where a.fecha = dfechacorte
		and a.fecha_apertura <= a.fecha
		and a.status_Cred  in ('E3','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso with no log;
		--  176646 record(s) affected

		select num_credito, numcte, 1 moneda, 
			case when  num_producto = '7800' then 4 else 3 end segmento, 
			1 cobranza , cap_vencido+int_vigente+int_vencido  sdo_vencido, cap_vencido, int_vigente+int_vencido int_ordinario, moratorios, 0 otros
		from paso
		into temp tbla4 with no log;

		-- 176646 record(s) affected 

		--Base Credito consumo plazo
		select a.num_producto,a.numcte,a.num_credito, status_cred_30,captrans30 cap_vencido,
			(d.intvenc30-d.int_venc_bal30 +d.intvig30) int_orden30, 
			(case when d.int_venc_bal30 >= 0 then d.int_venc_bal30 else 0 end) int_venc_bal30,
			nvl(monto,0) int_pa
			,sdo_moratorio + sdo_contab_mora moratorios
		from bdicred:sd_maecredcontcrd a
		inner join bdicred:sd_sdodiariocrd d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		left join  bdicred:sd_maeretenido c on a.num_credito = c.num_Credito and c.transacc = '8374'
		inner join bdicred:sd_maesdoscontcrd b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha 
		where a.fecha = dfechacorte
		and a.status_Cred  in ('E3','VP','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso2 with no log;

		-- 132326 record(s) affected

		--Universo integrado saldos  consumo plazo
		insert into tbla4
		select num_credito, numcte, 1 moneda, 4 segmento, 1 cobranza ,(cap_vencido+int_orden30+ int_venc_bal30+ int_pa) sdo_vencido,
			cap_vencido,(int_orden30+ int_venc_bal30+ int_pa) interes_ordinario, moratorios ,
			0 otros
		from paso2;
		--  132326 record(s) affected 

	
	elif day (dfechacorte) = 28 then
		
		--Universo Credito consumo revolvent
		select a.num_producto,a.numcte,a.num_credito,status_cred_28 status_cred ,  
			capvig28 cap_vigente,  captrans28 cap_vencido,intvig28 int_vigente,  intvenc28 int_vencido,moratorios28 moratorios
		from bdicred:sd_maecredcont a inner join bdicred:sd_sdodiario d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		inner join bdicred:sd_maesdoscont b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha
		where a.fecha = dfechacorte
		and a.fecha_apertura <= a.fecha
		and a.status_Cred  in ('E3','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso with no log;
		--  176646 record(s) affected

		select num_credito, numcte, 1 moneda, 
			case when  num_producto = '7800' then 4 else 3 end segmento, 
			1 cobranza , cap_vencido+int_vigente+int_vencido  sdo_vencido, cap_vencido, int_vigente+int_vencido int_ordinario, moratorios, 0 otros
		from paso
		into temp tbla4 with no log;

		-- 176646 record(s) affected 

		--Base Credito consumo plazo
		select a.num_producto,a.numcte,a.num_credito, status_cred_28,captrans28 cap_vencido,
			(d.intvenc28-d.int_venc_bal28 +d.intvig28) int_orden28, 
			(case when d.int_venc_bal28 >= 0 then d.int_venc_bal28 else 0 end) int_venc_bal28,
			nvl(monto,0) int_pa
			,sdo_moratorio + sdo_contab_mora moratorios
		from bdicred:sd_maecredcontcrd a
		inner join bdicred:sd_sdodiariocrd d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		left join  bdicred:sd_maeretenido c on a.num_credito = c.num_Credito and c.transacc = '8374'
		inner join bdicred:sd_maesdoscontcrd b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha 
		where a.fecha = dfechacorte
		and a.status_Cred  in ('E3','VP','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso2 with no log;

		-- 132326 record(s) affected

		--Universo integrado saldos  consumo plazo
		insert into tbla4
		select num_credito, numcte, 1 moneda, 4 segmento, 1 cobranza ,(cap_vencido+int_orden28+ int_venc_bal28+ int_pa) sdo_vencido,
			cap_vencido,(int_orden28+ int_venc_bal28+ int_pa) interes_ordinario, moratorios ,
			0 otros
		from paso2;
		--  132326 record(s) affected 
	

	elif day (dfechacorte) = 29 then
		
		--Universo Credito consumo revolvent
		select a.num_producto,a.numcte,a.num_credito,status_cred_29 status_cred ,  
			capvig29 cap_vigente,  captrans29 cap_vencido,intvig29 int_vigente,  intvenc29 int_vencido,moratorios29 moratorios
		from bdicred:sd_maecredcont a inner join bdicred:sd_sdodiario d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		inner join bdicred:sd_maesdoscont b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha
		where a.fecha = dfechacorte
		and a.fecha_apertura <= a.fecha
		and a.status_Cred  in ('E3','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso with no log;
		--  176646 record(s) affected

		select num_credito, numcte, 1 moneda, 
			case when  num_producto = '7800' then 4 else 3 end segmento, 
			1 cobranza , cap_vencido+int_vigente+int_vencido  sdo_vencido, cap_vencido, int_vigente+int_vencido int_ordinario, moratorios, 0 otros
		from paso
		into temp tbla4 with no log;

		-- 176646 record(s) affected 

		--Base Credito consumo plazo
		select a.num_producto,a.numcte,a.num_credito, status_cred_29,captrans29 cap_vencido,
			(d.intvenc29-d.int_venc_bal29 +d.intvig29) int_orden29, 
			(case when d.int_venc_bal29 >= 0 then d.int_venc_bal29 else 0 end) int_venc_bal29,
			nvl(monto,0) int_pa
			,sdo_moratorio + sdo_contab_mora moratorios
		from bdicred:sd_maecredcontcrd a
		inner join bdicred:sd_sdodiariocrd d on  d.fecha = dfechainicio and a.num_credito = d.num_credito
		left join  bdicred:sd_maeretenido c on a.num_credito = c.num_Credito and c.transacc = '8374'
		inner join bdicred:sd_maesdoscontcrd b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.fecha=a.fecha 
		where a.fecha = dfechacorte
		and a.status_Cred  in ('E3','VP','BT')
		and a.num_credito not in (select num_credito from sd_creditosvenc_ipab where fecha_corte = dfechacorte )
		into temp paso2 with no log;
		
		-- 132326 record(s) affected

		--Universo integrado saldos  consumo plazo
		insert into tbla4
		select num_credito, numcte, 1 moneda, 4 segmento, 1 cobranza ,(cap_vencido+int_orden29+ int_venc_bal29+ int_pa) sdo_vencido,
			cap_vencido,(int_orden29+ int_venc_bal29+ int_pa) interes_ordinario, moratorios ,
			0 otros
		from paso2;
		--  132326 record(s) affected 
		
		END IF;
		
		FOREACH WITH HOLD
			select num_credito, numcte, moneda, segmento, cobranza, sdo_vencido, cap_vencido, int_ordinario, moratorios, otros
			into v_num_credito, v_numcte, v_moneda, v_segmento,v_cobranza, v_sdo_vencido, v_cap_vencido, v_int_ordinario, v_moratorios, v_otros
			from tbla4
			
			begin work;			
			insert into sd_creditosvenc_ipab values(v_num_credito, v_moneda, v_segmento,v_cobranza, v_sdo_vencido, v_cap_vencido, v_int_ordinario, v_moratorios, v_otros, dfechacorte);	

			insert into sd_ctesvenc_ipab values(v_num_credito, v_numcte, dfechacorte);		
			commit work;
		END FOREACH;

	
	SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Fin_proc 
	FROM sysmaster:sysshmvals;
	

	LET cCod_Ret = "00000";
	LET cMensajeRet = 'Inicio: '||Ini_proc||' Fin: '||Fin_proc ;
	LET cMensajeRet2 = "PROCESO TERMINADO EXITOSAMENTE";
	
RETURN cMensajeRet,cCod_Ret,cMensajeRet2;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION:                            																	',
'GeneraciÃ³n de proceso de extracciÃ³n de informaciÃ³n crediticia mensual IPAB  CrÃ©dito Consumo.				',
'FECHA DE CREACION:  11 Julio 2023 																				',
'BD: bdicred																								';

CREATE PROCEDURE "informix".sp_ics_genera_layouts() 
						
	RETURNING	CHAR(5) AS codigo_ret;
	
	--DeclaraciÃÂÃÂ³n de Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	DEFINE v_cod_ret_sp					CHAR(5);
	--Variables del archivo--
	DEFINE c_ruta_archivo				VARCHAR(50);
	DEFINE c_ext_archivo				VARCHAR(50);
	DEFINE v_nombre_archivo				VARCHAR(50);
	
	DEFINE c_fecha_actual				DATE;
	DEFINE c_fecha_actual_2				DATE;
	DEFINE iContador  					INTEGER;
	Define cCadena			 			VARCHAR(30);
	DEFINE vsql	        				CHAR(1500);
	
	DEFINE v_numcte             		VARCHAR(20);
	DEFINE v_num_credito        		VARCHAR(20);
	DEFINE v_status_cred        		CHAR(2);
	DEFINE v_sucursal           		CHAR(4);
	DEFINE v_bandera_ministra   		CHAR(1);
	DEFINE v_fecha_apertura     		DATE;
	DEFINE v_fecha_vencim       		DATE;
	DEFINE v_num_producto 				CHAR(4);
	DEFINE v_tasa_interes 				DECIMAL(9,6);
	DEFINE v_tipo_cred					CHAR(1);
	DEFINE v_identity_code				VARCHAR(13);
	
	DEFINE v_existe_cliente				SMALLINT;
	
	DEFINE horaActual					DATETIME YEAR TO FRACTION(5);
	
	DEFINE horaTotalPagoMin				INTEGER; 
	DEFINE horaFinPagoMin				DATETIME YEAR TO FRACTION(5);
	DEFINE horaInicioPagoMin			DATETIME YEAR TO FRACTION(5);

	DEFINE iContador1 					INTEGER;
	DEFINE v_cantidad_universo			INTEGER;
	DEFINE cantidad_registros			INTEGER;
	DEFINE v_valor_inicial				INTEGER;
	DEFINE v_valor_final				INTEGER;
	DEFINE i 							INTEGER;
	
	--Comodines SP
	DEFINE codRet_sp_sdos				CHAR(6);
	DEFINE v_comodin_char_sp 			CHAR(80);
	DEFINE v_comodin_date_sp 			DATE;
	DEFINE v_comodin_decimal_sp 		DECIMAL(18,2);
	DEFINE v_comodin_int_sp 			INTEGER;
	DEFINE v_capital_debe				DECIMAL(18,2);
	DEFINE v_capital_pagado				DECIMAL(18,2);
	DEFINE v_balance					DECIMAL(18,2);
	DEFINE v_delinquency				DECIMAL(18,2);
	DEFINE v_principal_delinquent 		DECIMAL(18,2);
	DEFINE v_interest_delinquent 		DECIMAL(18,2);
	DEFINE v_collection_chargue 		DECIMAL(18,2);
	DEFINE v_cap_trans 					DECIMAL(18,2);
	DEFINE v_cap_vdo_exig 				DECIMAL(18,2);
	DEFINE v_int_vdo 					DECIMAL(18,2);
	DEFINE v_int_moratorios 			DECIMAL(18,2);
	DEFINE v_iva_int_vdo 				DECIMAL(18,2);
	DEFINE v_iva_int_moratorios 		DECIMAL(18,2);
	DEFINE v_com_pend 					DECIMAL(18,2);
	DEFINE v_iva_com 					DECIMAL(18,2);
	DEFINE v_total_liquidacion 			DECIMAL(18,2);
	DEFINE v_sdo_cap_insoluto			DECIMAL(18,2);
	DEFINE v_sdo_retenido				DECIMAL(18,2);
	DEFINE v_activo						DECIMAL(18,2);
	DEFINE cTipCred						CHAR(2);
	DEFINE dSdoTotalLiq 				DECIMAL(18,2); 
	DEFINE 	dSdoActCap					DECIMAL(18,2);	
	DEFINE 	dIntVdo						DECIMAL(18,2);
	DEFINE 	dIvaIntVdo					DECIMAL(18,2);
	DEFINE 	dIntMoratorio				DECIMAL(18,2);
	DEFINE 	dIvaIntMoratorio 			DECIMAL(18,2);
	DEFINE 	dSdoRetenido				DECIMAL(18,2);
	DEFINE 	vRetCs_acum					DECIMAL(18,2);
	DEFINE cEmpresa						VARCHAR(3);
	DEFINE dtFechaOrigen 				DATE;
	DEFINE dtMesiversario 				DATE;
	DEFINE dFactorComision 				DECIMAL(18,2);
	DEFINE ctran_comision 				CHAR(4);
	DEFINE dLineaOtorgada				DECIMAL(18,2);
	DEFINE dIvaSuc 						DECIMAL(5,3);  
	DEFINE cSucursal 					CHAR(4);
	DEFINE dIntDevengado				DECIMAL(18,2);
	DEFINE dTasaInteres 				DECIMAL(9,6);
	DEFINE	dComPend					DECIMAL(18,2);	
	DEFINE	dIvaCom						DECIMAL(18,2);
	DEFINE	dIvaIntDevengado			DECIMAL(18,2);
	DEFINE	dIntVig						DECIMAL(18,2);
	DEFINE	dIvaIntVig					DECIMAL(18,2);
	DEFINE cind_comision 				CHAR(1);
	DEFINE dtFechaCuota					DATE;
	DEFINE dtIvaFechaPag 				DATE;
	DEFINE v_capital_insoluto			DECIMAL(18,2);
	DEFINE iDia_corte					INTEGER;
	DEFINE  vFechahoy					DATE;
	DEFINE dia_comparacion				INTEGER;
	DEFINE v_cod_ret_hilos 				CHAR(5);
	DEFINE v_ejecucion_proceso 			INTEGER;
	DEFINE v_fecha_proceso				DATE;
	DEFINE v_contador_inactivo 			INTEGER;
	DEFINE v_contador_cte_nunca			INTEGER;
	------
	DEFINE v_capital_debe_2             DECIMAL(18,2);
	DEFINE v_interes_debe               DECIMAL(18,2);
	DEFINE v_iva_debe                   DECIMAL(18,2);
	DEFINE v_interes_mora               DECIMAL(18,2);
	DEFINE v_iva_interes_mora           DECIMAL(18,2);
	DEFINE dIntMoratorio_d	 			DECIMAL(18,2);
	DEFINE v_transaccion				INTEGER;
	DEFINE v_proceso					CHAR(20);
	DEFINE v_count_cred					INTEGER;
	DEFINE v_dia_diferencial_20			INTEGER;
	DEFINE v_dia_diferencial			INTEGER;
	DEFINE v_dia						INTEGER;
	DEFINE vEjecucionSemanal 			CHAR(1);
	DEFINE vEjecucionMensual			CHAR(1);
	
	
	 LET v_capital_debe_2     = 0.0;
	 LET v_interes_debe       = 0.0;
	 LET v_iva_debe           = 0.0;
	 LET v_interes_mora       = 0.0;
	 LET v_iva_interes_mora   = 0.0;
	 LET v_count_cred		  = 0;	
	 
	--InicializaciÃÂÃÂ³n de Variables--
	LET v_cod_ret 						= "00000";
	LET v_cod_ret_sp					= NULL;
	--Variables del archivo--
	LET c_ruta_archivo 					= "/resplogifx/info_ics/";
	LET c_ext_archivo					= ".csv";
	LET v_nombre_archivo				= NULL;
	LET c_fecha_actual					= NULL;
	LET c_fecha_actual_2				= NULL;
	LET iContador 						= 0;
	LET cCadena							= 'dbaccess bdicred ';
	LET vsql							= NULL;
	LET v_numcte 						= NULL;
	LET v_num_credito 					= NULL;
	LET v_status_cred					= NULL;
	LET v_sucursal 						= NULL;
	LET v_bandera_ministra 				= NULL;
	LET v_fecha_apertura 				= NULL;
	LET v_fecha_vencim 					= NULL;
	LET v_num_producto 					= NULL;
	LET v_tasa_interes 					= NULL;
	LET v_tipo_cred 					= NULL;
	LET v_existe_cliente 				= NULL;
	LET horaActual 						= NULL;
	LET horaTotalPagoMin				= 0;
	LET horaFinPagoMin					= NULL;
	LET horaInicioPagoMin				= NULL;
	LET iContador1 						= 0;
	LET i 								= 1;
	
	--InicializaciÃÂÃÂ³n de Variables SP
	LET codRet_sp_sdos					= NULL;
	LET v_comodin_char_sp 				= NULL;
	LET v_comodin_date_sp 				= NULL;
	LET v_comodin_decimal_sp 			= 0.0; 
	LET v_comodin_int_sp 				= 0; 
	LET v_capital_debe					= 0.0; 
	LET v_capital_pagado				= 0.0; 
	LET v_balance						= 0.0; 
	LET v_delinquency					= 0.0; 
	LET v_principal_delinquent 			= 0.0; 
	LET v_interest_delinquent 			= 0.0; 
	LET v_collection_chargue 			= 0.0; 
	LET v_cap_trans 					= 0.0;
	LET v_cap_vdo_exig 					= 0.0;
	LET v_int_vdo 						= 0.0;
	LET v_int_moratorios 				= 0.0;
	LET v_iva_int_vdo 					= 0.0;
	LET v_iva_int_moratorios 			= 0.0;
	LET v_com_pend 						= 0.0;
	LET v_iva_com 						= 0.0;
	LET v_total_liquidacion 			= 0.0;
	LET v_identity_code					= NULL;
	LET	v_sdo_cap_insoluto				= 0.0;
	LET v_sdo_retenido					= 0.0;
	LET v_activo						= 0.0;
	LET cTipCred						= NULL;
	LET dSdoTotalLiq					= 0.0;
	LET dSdoActCap						= 0.0;	
	LET dIntVdo							= 0.0;
	LET dIvaIntVdo						= 0.0;
	LET dIntMoratorio					= 0.0;
	LET dIvaIntMoratorio 				= 0.0;
	LET dSdoRetenido					= 0.0;
	LET vRetCs_acum						= 0.0;
	LET cEmpresa						= '001';
	LET dtFechaOrigen					= NULL;
	LET dtMesiversario					= NULL;
	LET dFactorComision					= 0.0;
	LET ctran_comision					= NULL;
	LET dLineaOtorgada					= 0.0;
	LET dIvaSuc							= 0.16;
	LET cSucursal						= NULL;
	LET dIntDevengado					= 0.0;
	LET dTasaInteres					= 0.0;
	LET dComPend					    = 0.0;
	LET dIvaCom						    = 0.0;
	LET dIvaIntDevengado			    = 0.0;
	LET dIntVig						    = 0.0;
	LET dIvaIntVig					    = 0.0;
	LET cind_comision					= NULL;
	LET dtFechaCuota					= NULL;
	LET dtIvaFechaPag					= NULL;
	LET v_cantidad_universo				= 0;
	LET cantidad_registros				= 0;
	LET v_valor_inicial					= 0;
	LET v_valor_final					= 0;
	LET v_capital_insoluto				= 0.0;
	LET vFechahoy						= today;
	LET iDia_corte 						= NULL;
	LET dia_comparacion					= 0;
	LET v_ejecucion_proceso				= NULL;
	LET v_fecha_proceso					= NULL;
	LET v_contador_inactivo 			= NULL;
	LET v_contador_cte_nunca			= NULL;
	LET dIntMoratorio_d					= 0;
	LET v_transaccion					= 0;
	LET v_proceso ='';
	LET v_dia_diferencial_20 			= NULL;
	LET v_dia_diferencial				= NULL;
	LET v_dia							= NULL;
	LET vEjecucionSemanal 				= NULL;
	LET	vEjecucionMensual				= NULL;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/resplogifx/cobranza/sp_ics_genera_layouts.out";
   -- TRACE ON; 
	
	BEGIN
		ON EXCEPTION SET sql_err
			--COMMIT WORK;
			--Insertar error para tener control e identicar cual se esta presentando
				INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
				VALUES(v_num_credito, v_numcte, v_num_producto, sql_err, v_proceso, CURRENT);
			
			IF iContador > 0 Then
				COMMIT WORK;
			End IF;
			
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				--ROLLBACK WORK;
				RETURN v_cod_ret;				
			END IF;
		END EXCEPTION;
			
			ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  --COMMIT WORK;
			  --BEGIN WORK;
			  LET v_transaccion = 1;
			  INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto,descripcion_error, proceso, fecha_insert)
			  VALUES( v_num_credito, v_numcte, v_num_producto, 'ERROR -535',v_proceso, CURRENT);
			    COMMIT WORK;
				BEGIN WORK;

		   END EXCEPTION WITH RESUME;
			
	
	/*BEGIN WORK;	
		LET v_transaccion = 1 ;
		INSERT INTO "informix".ics_clientes(ics_consecutivo, numcte, num_credito, status_cred, bandera_ministra, rfc, fecha_apertura, fecha_vencim, fecha_ejecucion, num_producto, tasa_interes, tipo_cred,
														balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue, collection_chargue_proyec, collection_chargue_proyec_iva)
		VALUES(	2147483647, '000000000', '', '', '0', '',TODAY, TODAY, TODAY, '0000', 0.00, '0',0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	
		
	COMMIT WORK;*/
		LET v_transaccion = 0 ;
		--UPDATE STATISTICS MEDIUM FOR TABLE "informix".ics_clientes;

		TRUNCATE TABLE ics_clientes;
		TRUNCATE TABLE ics_cuotas;
		TRUNCATE TABLE ics_obligacion;
		TRUNCATE TABLE ics_pagos;
		TRUNCATE TABLE ics_personas;
		
		update statistics medium for table "informix".ics_clientes;
		update statistics medium for table "informix".ics_cuotas;
		update statistics medium for table "informix".ics_obligacion;
		update statistics medium for table "informix".ics_pagos;
		update statistics medium for table "informix".ics_personas;
		update statistics medium for table "informix".ics_maectrl;


		
		--update statistics medium for table "informix".ics_clientes;
		SELECT fecha_hoy, (fecha_hoy + 1),  day(fecha_hoy)
			INTO c_fecha_actual, c_fecha_actual_2, iDia_corte --rev
		FROM bdinteg:si_fechas where empresa = '001';
		
		LET v_dia = DAY(c_fecha_actual);
		LET v_dia_diferencial = WEEKDAY(c_fecha_actual);
		
		
		LET iContador = 0;
		SELECT SUM(CASE WHEN valor like '%' || DECODE(LPAD(v_dia_diferencial, 2, '0'),0,'D',1,'L',2,'M',3,'X',4,'J',5,'V',6,'S') || '%' THEN 1 ELSE 0 END) semanal
		,SUM(CASE WHEN valor like '%d' || LPAD(v_dia, 2, '0') || '%' THEN 1 ELSE 0 END) mensual
			INTO vEjecucionSemanal, vEjecucionMensual
		FROM "informix".ics_parametros WHERE cod_param=1;	
		
		
		IF (vEjecucionSemanal = 1 OR vEjecucionMensual = 1) THEN
			
			BEGIN WORK;
				
				FOREACH WITH HOLD SELECT num_credito, numcte INTO v_num_credito, v_numcte FROM ics_maectrl WHERE tipo_cred = '1' --AND 
					
					LET v_num_credito = TRIM(v_num_credito);
					LET v_numcte = TRIM(v_numcte);
			
							
									INSERT INTO "informix".ics_clientes(
															/*ics_consecutivo,*/ numcte, num_credito, status_cred, bandera_ministra, rfc, 
															fecha_apertura, fecha_vencim, fecha_ejecucion, num_producto, tasa_interes, tipo_cred,
															balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue, collection_chargue_proyec, 
															collection_chargue_proyec_iva, pagos_vencidos)
													VALUES(
															/*ics_consecutivo.nextval,*/v_numcte, v_num_credito, '', '0', '',
															TODAY, TODAY, TODAY, '0000', 0.00, '1',
															0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
															0.00, null);
								LET iContador = iContador + 1;							
						--	END IF;
							UPDATE ics_maectrl SET enviado_ics = 't', fecha_enviado_ics = c_fecha_actual where num_credito = v_num_credito;
							
					--END IF;
					
					IF iContador >= 1000 THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF; 
	
				END FOREACH;	
			
			COMMIT WORK;
			
			LET iContador = 0;
	
			
	
			LET  v_transaccion = 0 ;
			
			LET iContador = 0;
	
	
			
		ELSE
		
				BEGIN WORK;
					
					FOREACH WITH HOLD SELECT num_credito, numcte INTO v_num_credito, v_numcte FROM ics_maectrl WHERE tipo_cred = '1' AND enviado_ics ='f'
						
						LET v_num_credito = TRIM(v_num_credito);
						LET v_numcte = TRIM(v_numcte);
												
										INSERT INTO "informix".ics_clientes(
																/*ics_consecutivo,*/ numcte, num_credito, status_cred, bandera_ministra, rfc, 
																fecha_apertura, fecha_vencim, fecha_ejecucion, num_producto, tasa_interes, tipo_cred,
																balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue, collection_chargue_proyec, 
																collection_chargue_proyec_iva, pagos_vencidos)
														VALUES(
																/*ics_consecutivo.nextval,*/v_numcte, v_num_credito, '', '0', '',
																TODAY, TODAY, TODAY, '0000', 0.00, '1',
																0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
																0.00, null);
									LET iContador = iContador + 1;							
							--	END IF;
								UPDATE ics_maectrl SET enviado_ics = 't', fecha_enviado_ics = c_fecha_actual where num_credito = v_num_credito;
								
						--END IF;
						
						IF iContador >= 1000 THEN
							COMMIT WORK;
							LET iContador = 0;
							BEGIN WORK;
						END IF; 
		
					END FOREACH;	
				
				COMMIT WORK;
				
				LET iContador = 0;
		
				
		
				LET  v_transaccion = 0 ;

		END IF;
		
			LET iContador = 0;
	
			BEGIN WORK;
	
				FOREACH WITH HOLD SELECT num_credito, numcte INTO v_num_credito, v_numcte FROM ics_maectrl WHERE tipo_cred = '2' --AND enviado_ics ='0'
				
					LET v_num_credito = TRIM(v_num_credito);
					LET v_numcte = TRIM(v_numcte);
					/*SELECT COUNT(*) INTO v_count_cred from sd_maecredcrd sd, sd_maecredanexocrd sdm
					where 
					sd.num_credito = v_num_credito and sdm.num_credito=sd.num_credito and (sdm.fecha_proceso = c_fecha_actual or sdm.fecha_proceso = c_fecha_actual_2);
					
					IF v_count_cred > 0 THEN*/
				
						INSERT INTO "informix".ics_clientes(
												/*ics_consecutivo,*/ numcte, num_credito, status_cred, bandera_ministra, rfc, 
												fecha_apertura, fecha_vencim, fecha_ejecucion, num_producto, tasa_interes, tipo_cred,
												balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue, collection_chargue_proyec, 
												collection_chargue_proyec_iva, pagos_vencidos)
										VALUES(
												/*ics_consecutivo.nextval,*/ v_numcte, v_num_credito, '', '0', '',
												TODAY, TODAY, TODAY, '0000', 0.00, '2',
												0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 
												0.00, null);
						
						LET iContador = iContador + 1;
						UPDATE ics_maectrl SET enviado_ics = 't', fecha_enviado_ics = c_fecha_actual where num_credito = v_num_credito;
					--END IF;
	
					IF iContador >= 1000 THEN
						COMMIT WORK;
						LET iContador = 0;
						BEGIN WORK;
					END IF; 
	
				END FOREACH;	
			
			COMMIT WORK;
	
		LET  v_transaccion = 0 ;
		
		LET iContador = 0;
		
		CALL "informix".sp_numero_hilos_ics(c_fecha_actual)	RETURNING v_cod_ret_hilos;
		
		
		
			IF v_cod_ret_hilos = '00000' THEN
				LET v_cod_ret = v_cod_ret;
			END IF;
			
		



		RETURN v_cod_ret;	
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	iCCS',
'CreaciÃÂÃÂ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'Analista    	:	RD',
'FECHA			: 	Oct 2021',
'Requerimiento	:	RQM 09 596',
'VERSION		: 	1.0.0';

CREATE PROCEDURE "informix".sp_ics_genera_control()
RETURNING CHAR(5) as codret, CHAR (300) as mensaje;


--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError INTEGER;
DEFINE cCod_err CHAR(5);
DEFINE vsMensaje CHAR(100);

DEFINE vContador INTEGER;
DEFINE vtransaccion SMALLINT;
DEFINE vNumcte CHAR(9);
DEFINE v_num_credito CHAR(12);
DEFINE vStatus_cred CHAR(2);
DEFINE v_count_cred INTEGER;
DEFINE v_sql CHAR(1000);
DEFINE vstmt CHAR(250);

DEFINE c_fecha_actual DATE;
DEFINE c_fecha_actual_2 DATE;
DEFINE iDia_corte INTEGER;
DEFINE vSec_dir CHAR(9);
DEFINE vSec_tel CHAR(9);
DEFINE vSec_dir_old CHAR(9);
DEFINE vSec_tel_old CHAR(9);
DEFINE horaActual DATETIME YEAR TO FRACTION(5);
DEFINE v_proceso CHAR(20);
DEFINE vEjecucionSemanal INTEGER;
DEFINE vEjecucionMensual INTEGER;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET vContador = 0;
LET vtransaccion = 0;
LET vNumcte = '';
LET v_num_credito = '';
LET vStatus_cred = '';
LET v_count_cred = 0;
LET v_sql= '';
LET vstmt= '';

LET c_fecha_actual = NULL;
LET c_fecha_actual_2 = NULL;
LET iDia_corte = NULL;

LET horaActual = NULL;
LET v_proceso ='';
LET vEjecucionSemanal=0;
LET vEjecucionMensual=0;

    --SET DEBUG FILE TO '/RESPALDOSNEW/noe/ics/sp_ics_genera_control.out';
    --TRACE ON;

BEGIN
        ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
                SET DEBUG FILE TO '/RESPALDOSNEW/sp_ics_genera_control.out';
                TRACE ON;

                SELECT DBINFO("utc_to_datetime", sh_curtime)
                        INTO horaActual
                FROM sysmaster:sysshmvals;

                INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
                VALUES(v_num_credito, vNumcte, '', iSqlErr, v_proceso, horaActual);

                IF iSqlErr <> 0 THEN
                        LET cCod_err = iSqlErr;
                        RETURN cCod_err, trim(vsMensaje);
                END IF;

        END EXCEPTION;

        ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        LET v_proceso ='Inicio iCS_ctrl';

--REGISTRA INICIO EN BITACORA
        LET v_proceso ='Fecha Actual';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, 'INICIO ICS_CONTROL');

        LET v_proceso ='Obtiene Parametros';

--OBTIENE FECHA ACTUAL
        SELECT fecha_hoy, (fecha_hoy + 1),  day(fecha_hoy)
                INTO c_fecha_actual, c_fecha_actual_2, iDia_corte
        FROM bdinteg:si_fechas where empresa = '001';

--VALIDA SI ES EJECUCION COMPLETA DE ACUERDO AL PARAMETRO

        SELECT SUM(CASE WHEN valor like '%' || DECODE(LPAD(WEEKDAY(c_fecha_actual), 2, '0'),0,'D',1,'L',2,'M',3,'X',4,'J',5,'V',6,'S') || '%' THEN 1 ELSE 0 END) semanal
                  ,SUM(CASE WHEN valor like '%d' || LPAD(DAY(c_fecha_actual), 2, '0') || '%' THEN 1 ELSE 0 END) mensual
        INTO vEjecucionSemanal, vEjecucionMensual
        FROM "informix".ics_parametros WHERE cod_param=1;

        LET v_proceso ='Creditos iCS';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE CREDITOS EN iCS
        DROP TABLE IF EXISTS tmp_creds_ics;

        SELECT num_credito FROM "informix".ics_maectrl INTO TEMP tmp_creds_ics WITH NO LOG;

        LET v_proceso ='Creditos Nuevos';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE REGISTRO NUEVOS
        DROP TABLE IF EXISTS tmp_creds_nvos;

        SELECT S.num_credito FROM bdicred:"informix".sd_maesdos S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto > 0
    AND I.num_credito IS NULL
    UNION
    SELECT S.num_credito FROM bdicred:"informix".sd_maesdoscrd S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto > 0
    AND I.num_credito IS NULL
    INTO temp tmp_creds_nvos WITH NO LOG;

        LET v_proceso ='Creditos Sin Mora';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE REGISTRO QUE YA NO ESTAN EN MORA
    DROP TABLE IF EXISTS tmp_creds_sin_mora;

        SELECT S.num_credito FROM bdicred:"informix".sd_maesdos S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto <= 0
    AND I.num_credito IS NOT null
    UNION
    SELECT S.num_credito FROM bdicred:"informix".sd_maesdoscrd S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto <= 0
    AND I.num_credito IS NOT NULL
    INTO temp tmp_creds_sin_mora WITH NO LOG;

        BEGIN WORK;

        LET v_proceso ='Inserta Nuevos';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

        FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_creds_nvos

                LET v_count_cred = 0;

                SELECT numcte, status_cred, COUNT(*) INTO vNumcte, vStatus_cred, v_count_cred FROM "informix".sd_maecred M, "informix".sd_maecredanexo X
                WHERE M.num_credito = v_num_credito AND X.num_credito=M.num_credito
                AND (X.fecha_proceso = c_fecha_actual OR X.fecha_proceso = c_fecha_actual_2) GROUP BY 1,2;

                IF v_count_cred > 0 THEN

                        SELECT
                        sum(case when tipo_dir='1' then secuencia else 0 end)
                        || sum(case when tipo_dir='2' then secuencia else 0 end)
                        || sum(case when tipo_dir='3' then secuencia else 0 end) sec_dir INTO vSec_dir
                        FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

                        SELECT
                        sum(case when tipo_tel='1' then secuencia else 0 end)
                        || sum(case when tipo_tel='2' then secuencia else 0 end)
                        || sum(case when tipo_tel='3' then secuencia else 0 end) sec_tel INTO vSec_tel
                        FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

                        INSERT INTO "informix".ics_maectrl(num_credito, numcte, status_cred, tipo_cred, secuencia_direccion, secuencia_telefono, enviado_ics, activo_ics, envia_pagos_ics, fecha_act_secuencia_telefono, fecha_act_secuencia_direccion, fecha_insert)
                VALUES(v_num_credito, vNumcte, vStatus_cred, 1, vSec_dir, vSec_tel, 'f', 't', 'f', TODAY, TODAY, TODAY);

                        LET vContador = vContador + 1;

                ELSE

                        SELECT numcte, status_cred, COUNT(*) INTO vNumcte, vStatus_cred, v_count_cred FROM "informix".sd_maecredcrd M, "informix".sd_maecredanexocrd X
                        WHERE M.num_credito = v_num_credito AND X.num_credito=M.num_credito
                        AND (X.fecha_proceso = c_fecha_actual OR X.fecha_proceso = c_fecha_actual_2) GROUP BY 1,2;

                        IF v_count_cred > 0 THEN

                                SELECT
                                sum(case when tipo_dir='1' then secuencia else 0 end)
                                || sum(case when tipo_dir='2' then secuencia else 0 end)
                                || sum(case when tipo_dir='3' then secuencia else 0 end) sec_dir INTO vSec_dir
                                FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

                                SELECT
                                sum(case when tipo_tel='1' then secuencia else 0 end)
                                || sum(case when tipo_tel='2' then secuencia else 0 end)
                                || sum(case when tipo_tel='3' then secuencia else 0 end) sec_tel INTO vSec_tel
                                FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

                                INSERT INTO "informix".ics_maectrl(num_credito, numcte, status_cred, tipo_cred, secuencia_direccion, secuencia_telefono, enviado_ics, activo_ics, envia_pagos_ics, fecha_act_secuencia_telefono, fecha_act_secuencia_direccion, fecha_insert)
                        VALUES(v_num_credito, vNumcte, vStatus_cred, 2, vSec_dir, vSec_tel, 'f', 't', 'f', TODAY, TODAY, TODAY);

                        LET vContador = vContador + 1;

                        END IF;

                END IF;

                IF vContador >= 1000 THEN
                        COMMIT WORK;
                        LET vContador = 0;
                        BEGIN WORK;
                END IF;

        END FOREACH;

        IF vContador < 1000 THEN
                COMMIT WORK;
                LET vContador = 0;
        END IF;



--DESACTIVA CREDITOS EN ICS
        LET v_proceso ='Desactiva Creditos';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

        BEGIN WORK;

        FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_creds_sin_mora

                UPDATE "informix".ics_maectrl
                SET activo_ics = 'f'
                        , fecha_desactivado_ics = TODAY +1
                        , enviado_ics = 'f'
                WHERE num_credito = v_num_credito;

                IF vContador >= 1000 THEN
                        COMMIT WORK;
                        LET vContador = 0;
                        BEGIN WORK;
                END IF;

        END FOREACH;

        IF vContador < 1000 THEN
                COMMIT WORK;
                LET vContador = 0;
        END IF;

--CAMBIA BANDERAS EN TABLA MAESTRA SEGUN EL DIA DE EJECUCION

        IF (vEjecucionSemanal=1 OR vEjecucionMensual=1) THEN

                --ACTUALIZA LAS BANDERAS SI ES DIA DE EJECUCION COMPLETA
                LET v_proceso ='Actualiza Banderas';

                SELECT DBINFO("utc_to_datetime", sh_curtime)
                        INTO horaActual
                FROM sysmaster:sysshmvals;
                INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

                BEGIN WORK;
                --FOREACH vCursor WITH HOLD FOR SELECT num_credito INTO v_num_credito FROM "informix".ics_maectrl WHERE activo_ics='t' and enviado_ics
                FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM "informix".ics_maectrl WHERE activo_ics and enviado_ics

                        --UPDATE "informix".ics_maectrl SET enviado_ics = 'f' WHERE CURRENT OF vCursor;
                        UPDATE "informix".ics_maectrl SET enviado_ics = 'f' WHERE num_credito = v_num_credito;

                        IF vContador >= 1000 THEN
                                COMMIT WORK;
                                LET vContador = 0;
                                BEGIN WORK;
                        END IF;

                END FOREACH;

                IF vContador < 1000 THEN
                        COMMIT WORK;
                        LET vContador = 0;
                END IF;

        END IF;

--BUSCA MOVIMIENTOS EN SD_INDICADOR_CRED

        IF (vEjecucionSemanal = 0 AND vEjecucionMensual = 0) THEN

                LET v_proceso ='Valida Movtos Creds';

                SELECT DBINFO("utc_to_datetime", sh_curtime)
                        INTO horaActual
                FROM sysmaster:sysshmvals;
                INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

                DROP TABLE IF EXISTS tmp_creds_ctrl;
                DROP TABLE IF EXISTS tmp_pagos_creds;

                SELECT DISTINCT num_credito FROM ics_maectrl WHERE activo_ics='t' and tipo_cred='1' into temp tmp_creds_ctrl WITH NO LOG;

                SELECT C.num_credito FROM tmp_creds_ctrl C
                LEFT JOIN sd_indicador_cred I ON C.num_credito=I.num_credito
                WHERE monto_ultimo_pago > 0
                AND (fecha_ultima_compra = c_fecha_actual OR atm_disp_fecha = c_fecha_actual OR fecha_ultimo_pago = c_fecha_actual)
                AND I.num_credito IS NOT NULL
                INTO TEMP tmp_pagos_creds WITH NO LOG;

                IF (SELECT COUNT(*) FROM tmp_pagos_creds) > 0 THEN

                        BEGIN WORK;

                        FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_pagos_creds

                                UPDATE "informix".ics_maectrl SET enviado_ics = 'f', envia_pagos_ics ='t' WHERE num_credito=v_num_credito;

                                IF vContador >= 1000 THEN
                                        COMMIT WORK;
                                        LET vContador = 0;
                                        BEGIN WORK;
                                END IF;

                        END FOREACH;

                        IF vContador < 1000 THEN
                                COMMIT WORK;
                                LET vContador = 0;
                        END IF;

                END IF;

        END IF;

--REGISTRA FIN EN BITACORA
        LET v_proceso ='Fin iCS_ctrl';

        SELECT DBINFO("utc_to_datetime", sh_curtime)
                INTO horaActual
        FROM sysmaster:sysshmvals;
        INSERT INTO "informix".ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, 'FIN ICS_CONTROL');

        RETURN cCod_err, TRIM(vsMensaje);

END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Inserta/actualiza Creditos en tabla de control de iCS',
'AUTOR : Noe Medina',
'FECHA : 04 Marzo 2022',
'VERSION: 1.0';

CREATE PROCEDURE "informix".sp_calculo_beneficio_monedero_pl_2() 
RETURNING	 CHAR(5); --Codigo Retorno

DEFINE cCodret				    CHAR(5);			 
DEFINE iSqlerr				    INTEGER;
DEFINE iExiste				    INTEGER;

DEFINE vFechaHoy        	DATE;
DEFINE vFechaConta        	DATE;
DEFINE vPeriodo				CHAR(10);
DEFINE vPeriodo_acum		CHAR(10);
DEFINE vTipo			 	CHAR(40);
DEFINE vTipo_acum		 	CHAR(40);
DEFINE vClienteBanco		CHAR(20);
DEFINE vNumCredito			CHAR(20);
DEFINE vNumProducto			CHAR(4);
DEFINE vNumProducto_acum	CHAR(4);
DEFINE vMontoDiario		 	DECIMAL(18,2);
DEFINE vPorcentajeDineroElectronico	DECIMAL(18,2);
DEFINE vPorcentaje		 	DECIMAL(18,2);
DEFINE vDineroEOriginal		DECIMAL(18,2);
DEFINE vDineroEOriginal_acum	DECIMAL(18,2);
DEFINE vImporteTransaccion 	DECIMAL(18,2);
DEFINE vFolioBeneficio		CHAR(50);
DEFINE vFolioBeneficio_acum	CHAR(50);
DEFINE vEstatus				CHAR(2);
DEFINE vEstatus_acum		CHAR(2);
DEFINE vDiaCorte			SMALLINT;
DEFINE vDiaCorteMenos1		CHAR(2);
DEFINE vFechaCorteMenosTresMeses	DATE;
DEFINE vFechaCorte			DATE;
DEFINE vFechaCompra			DATETIME YEAR TO FRACTION(5);
DEFINE vMontoMinimo		 	DECIMAL(18,2);
DEFINE vPorcentajeCumple	DECIMAL(18,2);
DEFINE vFechaCumple         DATE;
DEFINE vMesCumple			SMALLINT;
DEFINE vMesCompra			DATE;
DEFINE vMontoAcumulado 		DECIMAL(18,2);
DEFINE vAcumula				CHAR(1);
DEFINE vNuevoMontoDiario	DECIMAL(18,2);
DEFINE vMontoCompleto		DECIMAL(18,2);
DEFINE vOrigen 				CHAR(50);
DEFINE vMontoCompletoOrigen DECIMAL(18,2);
DEFINE vMoneda				CHAR(4);
DEFINE vMoneda_acum			CHAR(4);
DEFINE vReferencia23		CHAR(23);
DEFINE vReferencia23_acum	CHAR(23);
DEFINE aOrigen 				CHAR(50);
DEFINE vMontoDiarioOriginal	DECIMAL(18,2);
DEFINE vMontoDiarioOriginal_acum 	DECIMAL(18,2);
DEFINE pNombreComercio		CHAR(80);
DEFINE pNombreComercio_acum	CHAR(80);
DEFINE vFecha_generacion	DATETIME YEAR TO FRACTION(5);
DEFINE vFecha_generacion_acum	DATETIME YEAR TO FRACTION(5);
DEFINE vTipoVigencia		CHAR(40);
DEFINE asucursal			CHAR(4);
DEFINE atipomov				CHAR(40);
DEFINE vFechaCompra_acum    DATETIME YEAR TO FRACTION(5);


DEFINE pEmpresa				    CHAR(3);
DEFINE pUsuario					CHAR(40);
DEFINE pTransacc				CHAR(40);
DEFINE pTpPago					SMALLINT;
DEFINE pDivisa					CHAR(3);

DEFINE gCodigoRef				integer;
DEFINE gCodigoFun				VARCHAR(3);
DEFINE pMensaje					CHAR(80);
DEFINE vStatus_rw               CHAR(40);
DEFINE vCashback_amount         DECIMAL(16,2);



--INICIALIZANDO VARIABLES -------------
LET vFechaHoy        	=date(1);
LET vFechaConta        	=date(1);
LET vPeriodo			="";
LET vTipo			 	="";
LET vClienteBanco		="";
LET vNumCredito			="";
LET vNumProducto		="";
LET vMontoDiario		=0;
LET vPorcentajeDineroElectronico	=0;
LET vPorcentaje		 	=0;
LET vDineroEOriginal	=0;
LET vImporteTransaccion =0;
LET vFolioBeneficio		="";
LET vEstatus			="";
LET vDiaCorte			=0;
LET vDiaCorteMenos1		="";
LET vFechaCorte			="";
LET vFechaCompra		="";
LET vFechaCumple        =date(1);
LET vMesCumple     		=0;
LET vMesCompra			="";
LET vPorcentajeCumple	=0;
LET vMontoMinimo		=0;
LET vMontoAcumulado		=0;
LET vNuevoMontoDiario	=0;
LET vMontoCompleto		=0;
LET vOrigen				="";
LET vMontoCompletoOrigen =0;
LET vMoneda				="";
LET vReferencia23		="";
LET aOrigen				="";
LET vMontoDiarioOriginal =0;
LET pNombreComercio		= "";
LET vAcumula            ="0";


LET  vPeriodo_acum		= "";
LET  vTipo_acum		 	= "";
LET  vNumProducto_acum	= "";
LET  vDineroEOriginal_acum	=0;
LET  vFolioBeneficio_acum	= "";
LET  vEstatus_acum		= "";
LET  vMoneda_acum			= "";
LET  vReferencia23_acum	= "";
LET  vMontoDiarioOriginal_acum 	=0;
LET  pNombreComercio_acum	= "";
LET  vFecha_generacion_acum  = "";
LET vFechaCompra_acum  		 = "";		

---------------------------------------
LET cCodret    			= "00000";
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
---------------------------------------

LET pEmpresa			= '001';
LET pUsuario			= 'informix';
LET pTransacc			= 0; 
LET pTpPago				= 1;
LET pDivisa				= '01';
LET gCodigoRef		= "";
LET gCodigoFun		= "";
LET pMensaje		= "";

LET vTipo = 'COMPRAS';
LET vEstatus = 'P';

LET vTipoVigencia	= "vigente";
LET aSucursal 		= "";

LET vStatus_rw      = '';
LET vCashback_amount = 0;




	--SET DEBUG FILE TO "/ifxsif01/DBA/IPCB/tdc/sp_calculo_beneficio_monedero_pl.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--consultar fecha actual
	SELECT fecha_ant as fechaHoy, fecha_hoy
	INTO vFechaHoy, vFechaConta
	FROM bdicred:sd_fechas
	WHERE empresa = '001';


FOREACH WITH HOLD

	SELECT a.num_credito,a.numcte, a.origen, a.moneda, a.referencia23, a.nombre_comercio,a.monto_diario, a.producto, a.periodo,a.fecha_compra, a.status_rw, a.cashback_amount
	INTO vNumCredito,vClienteBanco,vOrigen,vMoneda,vReferencia23,pNombreComercio,vMontoDiarioOriginal,vNumProducto,vPeriodo,vFechaCompra, vStatus_rw, vCashback_amount
	FROM bdicred: "informix".sd_compras_plan_lealtad a
	where (estatus_calculo::boolean = "f" or status_rw = 'confirmed')
		
		IF nvl(vStatus_rw,'') =  'confirmed' then
			LET vOrigen = "Reworth";
		END IF;
		
		LET vFolioBeneficio = TO_CHAR(vFechaHoy, 'PL' || '%e%m%Y%H%M%S '); 
		LET vFolioBeneficio = REPLACE(vFolioBeneficio, " ", "");
		
		--Lee sucursal del credito
		SELECT sucursal INTO aSucursal
		FROM bdicred:"informix".sd_Maecred
		WHERE num_credito = vNumCredito;
		
		-----------------------------
		IF vOrigen = "Plan_Lealtad" THEN
			LET aOrigen 		= 'Plan_Lealtad';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9815';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 141;
		ELIF vOrigen = "Reworth" THEN
			LET aOrigen 		= 'Reworth';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9830';
			LET gCodigoFun		= '152';
			LET gCodigoRef		= 141;
		ELIF vOrigen = "Devolucion_Pl" THEN
			LET aOrigen 		= 'Plan_Lealtad';
			LET aTipoMov 		= 'CARGO_DEVOLUCION';
			LET pTransacc 		= '9822';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 140;
		ELIF vOrigen = "Devolucion_Ex" THEN
			LET aOrigen 		= 'Reworth';
			LET aTipoMov 		= 'CARGO_DEVOLUCION';
			LET pTransacc 		= '9999';
			LET gCodigoFun		= '152';
			LET gCodigoRef		= 140;
		ELIF vOrigen = "Aclaraciones_Pl" THEN
			LET aOrigen			= 'Plan_Lealtad';
			LET pTransacc 		= '9821';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 139;
		-----------------------------
		END IF;		
		
		
		--consultar la tabla productos permitidos 
		IF (vOrigen = "Plan_Lealtad") then
			SELECT porcentaje_beneficio, porcentaje_especial,monto_minimo
			INTO  vPorcentajeDineroElectronico, vPorcentajeCumple, vMontoMinimo
			FROM  bdicred:"informix".sd_productos_permitidos_plan_lealtad
			WHERE num_producto = vNumProducto;

			--Obtener mes de cumpleanios--------------
			SELECT fecha_nac
			INTO vFechaCumple
			FROM bdinteg:"informix".si_ctepf
			WHERE numcte = vClienteBanco;
			
			LET vMesCumple = MONTH(vFechaCumple) ;
			
			--Acumula monedero 
			
			SELECT NVL(monto_acumulado,0), NVL(acumula,"0")
			INTO vMontoAcumulado, vAcumula
			FROM bdicred: "informix".sd_compra_acumulada_plan_lealtad
			WHERE numcte = vClienteBanco
			AND num_credito = vNumCredito
			AND origen = vOrigen;
			
			IF vMontoAcumulado is null THEN 
				LET vMontoAcumulado = 0;
				LET vAcumula = "0";
			END IF;
			
			BEGIN WORK;
			
			IF (vMontoAcumulado + vMontoDiarioOriginal) >= vMontoMinimo THEN 
				LET vAcumula = "1";
				--FOREACH DE MOVIMIENTOS POR ACUMULAR
				
				FOREACH WITH HOLD
				
					SELECT producto, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, moneda, referencia23, nombre_comercio,fecha_compra
					INTO vNumProducto_acum, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum,vFechaCompra_acum
					FROM sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND num_credito = vNumCredito
					AND origen = vOrigen
					
					INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
					VALUES(vClienteBanco, vNumProducto_acum, vNumCredito, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vOrigen, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum);
					
					DELETE bdicred:"informix".sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND origen = vOrigen
					AND referencia23 = vReferencia23_acum
					AND num_credito = vNumCredito
					AND monto = vMontoDiarioOriginal_acum;
					
					UPDATE "informix".sd_monedero_plan_lealtad 
					SET saldo_total=saldo_total + vDineroEOriginal_acum, fecha_actualizacion=vFechaHoy 
					WHERE numcte = vClienteBanco
					and origen = aOrigen;
					
					IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					
						INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
						VALUES(vClienteBanco, vDineroEOriginal_acum, vFechaHoy, 'A', aOrigen);
							
					END IF;
					
					EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto_acum,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal_acum,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
					INTO cCodRet,pMensaje;
					----------------
					INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
					VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal_acum, 0, vFechaCompra_acum, vFolioBeneficio, "f", aOrigen, vReferencia23_acum);	
				
					INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
					VALUES(vClienteBanco, vNumCredito, vNumProducto_acum, vDineroEOriginal_acum, vMontoDiarioOriginal_acum, aTipoMov, vFechaCompra_acum, vFolioBeneficio, aOrigen, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum);
				
				END FOREACH;
				
			END IF; 
				
			--Obtiene mes de compra --
			LET vMesCompra = MONTH(vFechaCompra);
			
			--Validar mes de cumpleanios
			IF vMesCompra = vMesCumple then
				LET vPorcentajeDineroElectronico = vPorcentajeCumple;
			END IF;
			
			--calculo de dinero
			LET vPorcentaje = vPorcentajeDineroElectronico / 100;
			LET vDineroEOriginal = vMontoDiarioOriginal * vPorcentaje;

			
			
			IF vAcumula = "1"
			THEN
			
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			ELSE 
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_por_acumular(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio,fecha_compra)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio,vFechaCompra);
			
			END IF;
			
			UPDATE bdicred: "informix".sd_compra_acumulada_plan_lealtad
			SET monto_acumulado= monto_acumulado + vMontoDiarioOriginal,
				acumula = vAcumula
			WHERE numcte = vClienteBanco
			AND num_credito = vNumCredito
			AND origen = vOrigen;
			
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			
				INSERT INTO bdicred:"informix".sd_compra_acumulada_plan_lealtad(numcte, producto, num_credito, monto_acumulado, origen, moneda,acumula)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal,vOrigen,vMoneda,vAcumula);

			END IF;
				
			--Cambia el estatus de cliente
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET estatus_calculo="t" 
			WHERE numcte = vClienteBanco
			AND origen = vOrigen
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;

			
			
			--CONDICION DE MONTO MINIMO

			IF vAcumula = "1"
				
			THEN
				UPDATE "informix".sd_monedero_plan_lealtad 
				SET saldo_total=saldo_total + vDineroEOriginal, fecha_actualizacion=vFechaHoy 
				WHERE numcte = vClienteBanco
				and origen = aOrigen;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				
					INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
					VALUES(vClienteBanco, vDineroEOriginal, vFechaHoy, 'A', aOrigen);
						
				END IF;
				
				EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
				INTO cCodRet,pMensaje;
				----------------
			
				INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
				VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
				
				
				INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumCredito, vNumProducto, vDineroEOriginal, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			END IF;
			
			COMMIT WORK;
		ELSE
		
			LET vCashback_amount = nvl(vCashback_amount,0);
			
			IF nvl(vCashback_amount,0) <= 0 THEN
				LET vCashback_amount = 0;
			END IF;
		
			UPDATE "informix".sd_monedero_plan_lealtad 
			SET saldo_total=saldo_total + vCashback_amount, fecha_actualizacion=vFechaHoy 
			WHERE numcte = vClienteBanco
			and origen = aOrigen;
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			
				INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
				VALUES(vClienteBanco, vCashback_amount, vFechaHoy, 'A', aOrigen);
					
			END IF;
			
			EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vCashback_amount,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
			INTO cCodRet,pMensaje;
			----------------
		
			INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
			VALUES(vClienteBanco, vTipoVigencia, vCashback_amount, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
			
			
			INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
			VALUES(vClienteBanco, vNumCredito, vNumProducto, vCashback_amount, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET status_rw="process" 
			WHERE numcte = vClienteBanco
			AND origen = 'Plan_Lealtad'
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;
			
			
		END IF;
--Limpia variables

END FOREACH;

RETURN cCodret;
	
END
END procedure;