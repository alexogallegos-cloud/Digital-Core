CREATE PROCEDURE "informix".sp_mon_buro_conssolcredlincred(pEjecucion SMALLINT,pTipoSolicitud CHAR(2),pNumsolicitud CHAR(20), pNumcte CHAR(20), pFechaIni DATE, pFechafin DATE, pEstatus CHAR(2), pProducto CHAR (4), pCve_grupo CHAR(2), pSegmento CHAR(2), pEtiqueta CHAR(2), pAnalista CHAR(8),pComentario CHAR(100))

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

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF;
	END EXCEPTION;
--SET DEBUG FILE TO '/RESPALDOSNEW/monitor_buro.out';
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

		--- INC 27 000 Se elimina validación para que siempre realice el borrado a la tabla de trabajo. --AAME
		TRUNCATE TABLE "informix".sd_numsolici_datos_tmp;
		--**********************
		IF pTipoSolicitud = '01' THEN --SOLICITUD DE CREDITO
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
					INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
					VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, '09',  '', '', 'Segmento Direccion - Dirección incompleta o sin asignar',pAnalista);										
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
					SELECT unique {+INDEX(bdiburo:"informix".br_respuesta br_respuesta_sol)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
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
							INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
							VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus,'09',  '', '', 'No se puede procesar respuesta -Longitud excede 4005 caracteres',pAnalista);								
						ELSE
							-----LECTURA DE DESCRIPCION
							IF cEtiquetaExcepcion = '05' THEN
								SELECT (ROWID + 1)
								INTO iRowid
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = TRIM(cSegmento)
								AND etiqueta_suberror = TRIM(cEtiqueta);
								
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
									WHERE cve_grupo = TRIM(cClave_grupo)
									AND segmento = TRIM(cSegmento)
									AND etiqueta = TRIM(cEtiqueta);
									
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
								WHERE segmento_suberror = TRIM(cSegmento)
								AND etiqueta_suberror = TRIM(cEtiqueta);
							
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
								
								INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
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
											WHERE segmento = TRIM(cSegmentouno)
											AND etiqueta = TRIM(cEtiquetauno);
												
									 END IF;
									--********************
									--SI EL DESGLOSE ES 0 SE QUEDA CON LA MISMA DESCRIPCION
									IF NVL(cDesglose,'') = '0' THEN
										--SE QUEDA CON LA MISMA DESCRIPCIONES Y SE INSERTA EN LA TABLA
										 INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
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
									
										INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
										VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);
									END IF;
								END FOREACH;
							--INC 27 052 AAME 2014-01-15 Se agrega validación para que se registre un valor de error por default en caso de no encontrarse en la clasificación
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
									
									INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
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
						
						INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
						VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);																
					END IF;
				END IF;
			END FOREACH;	
		ELSE  --INCREMENTO DE LINEA
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
					INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
					VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, '09',  '', '', 'Segmento Direccion - Dirección incompleta o sin asignar',pAnalista);										
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
					SELECT unique {+INDEX(bdiburo:"informix".br_respuesta br_respuesta_sol)} SUBSTR(sb.regreso, 5,2) AS segmentouno,SUBSTR(sb.regreso, 34,2) AS etiquetauno, SUBSTR(sb.regreso, 38,2) AS segmento , SUBSTR(sb.regreso, 40,2) AS etiqueta, sb.institucion, length(sb.regreso)
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
							INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
							VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus,'09',  '', '', 'No se puede procesar respuesta -Longitud excede 4005 caracteres',pAnalista);														
						ELSE
							-----LECTURA DE DESCRIPCION
							IF cEtiquetaExcepcion = '05' THEN
								SELECT (ROWID + 1)
								INTO iRowid
								FROM bdiburo:"informix".br_mon_buro_suberrordesglose
								WHERE segmento_suberror = TRIM(cSegmento)
								AND etiqueta_suberror = TRIM(cEtiqueta);
								
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
									WHERE cve_grupo = TRIM(cClave_grupo)
									AND segmento = TRIM(cSegmento)
									AND etiqueta = TRIM(cEtiqueta);
									
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
								WHERE segmento_suberror = TRIM(cSegmento)
								AND etiqueta_suberror = TRIM(cEtiqueta);
							
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
								
								INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
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
											WHERE segmento = TRIM(cSegmentouno)
											AND etiqueta = TRIM(cEtiquetauno);												
									 END IF;
									--********************
									--SI EL DESGLOSE ES 0 SE QUEDA CON LA MISMA DESCRIPCION
									IF NVL(cDesglose,'') = '0' THEN
										--SE QUEDA CON LA MISMA DESCRIPCIONES Y SE INSERTA EN LA TABLA
										 INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
										 VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
									ELSE
										--USANDO AL CLAVE DEL GRUPO
											SELECT descripcionsuberror
											INTO cDescripcion
											FROM bdiburo:"informix".br_mon_buro_suberrordesglose
											WHERE segmento_suberror = cSegmento
											AND etiqueta_suberror = cEtiqueta
											AND cve_grupo = cClave_grupo;
									
											INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
											VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);				
									END IF;
								END FOREACH;
							--INC 27 052 AAME 2014-01-15 Se agrega validación para que se registre un valor de error por default en caso de no encontrarse en la clasificación
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
									
									INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
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
						
						INSERT INTO "informix".sd_numsolici_datos_tmp (num_solicitud,fecha_insert, hora, numcte,status,clave, segmento, etiqueta, descripcion,user_insert) 
						VALUES(cNumeroSolicitud,dFecha, dHora, cCliente, cEstatus, cClave_grupo,  cSegmento, cEtiqueta, cDescripcion,pAnalista);										
					END IF;
				END IF;
			END FOREACH;			
		END IF;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_numsolici_datos_tmp;
		--SE VACIAN LAS VARIABLES PARA PDOER VOLVER A UTILIZARLAS			
		LET cClave_grupo = '';
		LET cSegmento    = '';
		LET cEtiqueta    = '';		
		------SE INSERTA EN LA TABLA TEMPORAL PARA EL REGISTRO DE LOS DATOS
				LET iBanTemp=1;
				FOREACH	
					SELECT DISTINCT(num_solicitud), fecha_insert, hora, numcte,status, descripcion,clave, segmento, etiqueta
					INTO cNumsolicitud, dFecha, dHora, cCliente, cEstatus, cComentario, cClave_grupo, cSegmento, cEtiqueta
					FROM bdicred:"informix".sd_numsolici_datos_tmp
					WHERE clave = DECODE(pCve_grupo,'',clave,pCve_grupo)

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
					   FROM sd_numsolici_datos_tmp
					   WHERE clave = DECODE(pCve_grupo,'',clave,pCve_grupo);

		--				ENCUENTRE MAS REGISTROS DEVUELVE UNA ÚLTIMA LINEA
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
		AND per.ejecutivo = TRIM(pAnalista);
	
		SELECT ejecutivo,nombre 
		INTO cNumAnalista, cNombreAnalista
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = TRIM(pAnalista);

		IF cPerfilAnalista IS NULL THEN
			LET cPerfilAnalista = 'Analista de Crédito';
		END IF;

		--SE INICIALIZA EL STRING QUE SE VA A UTILIZAR PARA LA CONSULTA DINÁMICA
		LET VSQL = '' ;
		
		IF pTipoSolicitud = '01' THEN --SOLICITUD DE CREDITO
			LET pTipoSolicitud = '1'; --SE HACEN CHAR DE 1 PARA LA POSTERIOR INSERCION
			LET VSQL = 'SELECT LIMIT 1 sol.numcte, sol.num_solicitud, sol.num_producto, sol.sucursal,TRIM(cli.nombre1)||" "||TRIM(cli.nombre2)||" "||TRIM(cli.apell_paterno)||" "||TRIM(cli.apell_materno) AS nombre_cliente, sol.fecha_insert, aud.hora, sol.status_solicitud               ';
			LET VSQL = TRIM(VSQL) || ' FROM bdisolic:"informix".ss_solicitudes sol      ';
			LET VSQL = TRIM(VSQL) || ' LEFT OUTER JOIN bdiburo:"informix".br_auditor aud ON (aud.solicitud = sol.num_solicitud AND aud.fecha =(SELECT MAX(fecha) FROM bdiburo:"informix".br_auditor WHERE solicitud = sol.num_solicitud) )      ';
			LET VSQL = TRIM(VSQL) || ' LEFT OUTER JOIN bdinteg:"informix".si_cliente cli ON  (cli.numcte = sol.numcte)        ';
			LET VSQL = TRIM(VSQL) || ' WHERE sol.num_solicitud = "'||TRIM(pNumsolicitud)||'"   ';		
			LET VSQL = TRIM(VSQL) || ' ORDER BY aud.hora DESC   ';
			
		ELSE  --INCREMENTO DE LINEA
			LET pTipoSolicitud = '2'; --SE HACEN CHAR DE 1 PARA LA POSTERIOR INSERCION
			LET VSQL = 'SELECT LIMIT 1 sol.numcte, sol.num_solicitud, sol.num_producto, sol.sucursal, TRIM(cli.nombre1)||" "||TRIM(cli.nombre2)||" "||TRIM(cli.apell_paterno)||" "||TRIM(cli.apell_materno) AS nombre_cliente ,sol.fecha_insert, aud.hora, sol.status               ';
			LET VSQL = TRIM(VSQL) || ' FROM "informix".sd_bitacora_aumlincred sol       ';
			LET VSQL = TRIM(VSQL) || ' LEFT OUTER JOIN bdiburo:"informix".br_auditor aud ON (aud.solicitud = sol.num_solicitud AND aud.fecha =(SELECT MAX(fecha) FROM bdiburo:"informix".br_auditor WHERE solicitud = sol.num_solicitud) )      ';
			LET VSQL = TRIM(VSQL) || ' LEFT OUTER JOIN bdinteg:"informix".si_cliente cli ON  (cli.numcte = sol.numcte)        ';
			LET VSQL = TRIM(VSQL) || ' WHERE sol.fecha_status IN (SELECT MAX(fecha_status) FROM bdicred:"informix".sd_bitacora_aumlincred where num_solicitud=sol.num_solicitud) AND sol.num_solicitud = "'||TRIM(pNumsolicitud)||'"   ';		
			LET VSQL = TRIM(VSQL) || ' ORDER BY aud.hora DESC   ';
		END IF;
				
		PREPARE xsql FROM TRIM(VSQL); 
		DECLARE xcur CURSOR FOR xsql; 
		OPEN xcur;		
		FETCH  xcur INTO cNumcte, cNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus; 
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000008'; --NO HAY RESULTADOS PARA LA CONSULTA
			RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
		END IF	
		
		WHILE  SQLCODE= 0 --Si encuentra registros el cursor
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
				INTO cCodret  ; --REGRESA UN CHAR DE 1 , un '1' si es Éxito
				
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
	
		FETCH  xcur INTO cNumcte, cNumsolicitud, cNumprod, cSucursal, cNombre_cte, dFecha, dHora, cEstatus; 
		
		END WHILE;
	
		CLOSE xcur;
		FREE xcur;
		FREE xsql;
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
		WHERE num_solicitud = TRIM(pNumsolicitud)
		AND institucion IN ('BC','CC');
		
		IF sRegreso = 0 THEN
			SELECT COUNT(*) 
			INTO sRegreso
			FROM bdiburo:"informix".br_respuesta_aprocesar 
			WHERE num_solicitud = TRIM(pNumsolicitud)
			AND institucion IN ('BC','CC');
		END IF;
	
		IF sRegreso > 0 THEN --SI ENCONTRO LA SOLICITUD EN LA REGRESO			
			--RECIBIR LA SOLICITUD Y EL TIPO DE SOLICITUD 
			--VERIFICAR SEGUN EL TIPO DE SOLICITUD EN QUE ESTATUS ESTA AHORA
			IF pTipoSolicitud = '01' THEN --SOLICITUD DE CRÉDITO
				SELECT status_solicitud
				INTO cEstatus
				FROM bdisolic:"informix".ss_solicitudes
				WHERE num_solicitud = TRIM(pNumsolicitud);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000008'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN cCodret, NVL(cTiposolicitud,''), NVL(cNumsolicitud,'') ,NVL(dFecha, DATE(1)), NVL(dHora, '00:00:00'), NVL(cCliente,''), NVL(cEstatus,''), NVL(cComentario,''), NVL(iRegistros, 0), NVL(cClave_grupo,''), NVL(cSegmento,''), NVL(cEtiqueta,'');
				END IF	
				
			ELIF pTipoSolicitud = '02' THEN --INCREMENTO DE LINEA
				SELECT LIMIT 1 status
				INTO cEstatus
				FROM "informix".sd_bitacora_aumlincred
				WHERE num_solicitud = TRIM(pNumsolicitud)
				AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".sd_bitacora_aumlincred WHERE num_solicitud = TRIM(pNumsolicitud));
				
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
	END IF; ---FIN DEL IF DE TIPO DE EJECUCION
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO QUE TIENE DOS MODOS DE EJECUCIÓN ',
'             1.-CONSULTA SENCILLA: REALIZA UNA CONSULTA SENCILLA POR MEDIO DE DISTINTOS,',
'                FILTROS COMO RANGO DE FECHA, NO. DE SOLICITUD, NO. DE CLIENTE, ESTATUS',
'                O PRODUCTO.',
'             2.- CONSULTA/ENVIO A BC: REALIZA UNA CONSULTA DE DATOS PARA DESPUES USARLOS',
'                 AL EJECUTAR PROCEDIMIENTOS QUE REALIZAN EL ENVIO DE SOLICITUDES A BC.',
'             3.-VERIFICA SI HAY RESPUESTA DE BURO DE CREDITO',
'FECHA DE CREACIÓN: 07 DE JUNIO DE 2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 201306071200';

CREATE PROCEDURE "informix".sp_creditos_pp_int_neg(pEmpresa VARCHAR(3))
									
RETURNING CHAR(6);

---DECLARACION DE VARIABLES
DEFINE iSqlErr 				INTEGER;
DEFINE isam_err 			INTEGER;
DEFINE error_info 			CHAR(80);
DEFINE cProceso         	CHAR(4);
DEFINE cCod_retBit      	CHAR(6);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeErr			CHAR(60);

DEFINE dFechaHoy			DATE;
DEFINE cNum_Credito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE iContador			INTEGER;
DEFINE cProducto			CHAR(4);
DEFINE cSucursal			CHAR(4);
DEFINE iTablaExiste 		INTEGER;

DEFINE d_sdo_retenido		DECIMAL(18,2);
DEFINE d_sdo_capital		DECIMAL(18,2);
DEFINE d_sdo_cap_insoluto	DECIMAL(18,2);
DEFINE d_sdo_no_exig		DECIMAL(18,2);
DEFINE d_int_tra_no_exig	DECIMAL(18,2);
DEFINE d_mto_venc_int		DECIMAL(18,2);
DEFINE d_mto_finan_vdo		DECIMAL(18,2);
DEFINE d_monto_nvo_ret 		DECIMAL(18,2);
DEFINE d_monto_int_nvo 		DECIMAL(18,2);
DEFINE d_monto_iva_nvo		DECIMAL(18,2);
DEFINE cFolio         		CHAR(16);

DEFINE cNom_Archivo			CHAR(50);
DEFINE cNom_Archivo_aux		CHAR(50);
DEFINE cRuta            	CHAR(100);
DEFINE cSQL             	CHAR(8204);
DEFINE cSQL1            	CHAR(6204);
DEFINE cSQL2            	CHAR(6204);
DEFINE cSQL3            	CHAR(100);



--SET DEBUG FILE TO "/informix/mahr/sp_creditos_pp_int_neg.out";
--TRACE ON;


---INICIALIZACION DE VARIABLES
LET iSqlErr 			= 0;
LET isam_err 			= 0;
LET error_info 			= '';
LET cProceso			= '0115';
LET cCod_retBit			= '000000';
LET cCodRet  			= '000000';
LET cMensajeErr			= '';

LET dFechaHoy			= date(1);
LET cNum_Credito		= '';
LET cStatusCred			= '';
LET iContador			= 0;
LET cProducto			= '';
LET cSucursal			= '';
LET iTablaExiste		= 0;

LET d_sdo_retenido		= 0;
LET d_sdo_capital		= 0;
LET d_sdo_cap_insoluto	= 0;
LET d_sdo_no_exig		= 0;
LET d_int_tra_no_exig	= 0;
LET d_mto_venc_int		= 0;
LET d_mto_finan_vdo		= 0;
LET d_monto_nvo_ret		= 0;
LET d_monto_int_nvo 	= 0;
LET d_monto_iva_nvo		= 0;
LET cFolio				= '';

LET cNom_Archivo		= '';
LET cNom_Archivo_aux    = '';
LET cRuta				= '';
LET cSQL             	= '';
LET cSQL1            	= '';
LET cSQL2            	= '';
LET cSQL3            	= '';


BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Error-"||isam_err||"-"||trim(error_info)||"-"||cNum_Credito, '02') Returning cCod_retBit;
	
	IF iTablaExiste = 1 THEN
		DROP TABLE bdicred:tmp_creditos_corregidos;
	END IF;
	
	RETURN cCodRet;
END EXCEPTION;

	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Valida los datos de entrada
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet;
	END IF;

	-- Obtiene fecha 
	SELECT fecha_hoy, USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2) ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2) ||SUBSTR(CURRENT,18,2)
	  INTO dFechaHoy, cFolio
	  FROM bdicred:"informix".sd_fechas WHERE empresa = '001'; 

 	
	Create table bdicred:tmp_creditos_corregidos
	(
		num_credito 	CHAR(20),
		status_cred     CHAR(2),
		sdo_no_exig		DECIMAL(18,2),
		int_tra_no_exig DECIMAL(18,2),	
		mto_venc_int	DECIMAL(18,2),	
		mto_finan_vdo	DECIMAL(18,2)
	);
	LET iTablaExiste = 1;

	
	FOREACH WITH HOLD
		SELECT c.num_credito, c.status_cred, sdo_retenido  , sdo_capital  , sdo_cap_insoluto  , sdo_no_exig  , int_tra_no_exig  , mto_venc_int  , mto_finan_vdo  , c.sucursal
		  INTO cNum_Credito , cStatusCred  , d_sdo_retenido, d_sdo_capital, d_sdo_cap_insoluto, d_sdo_no_exig, d_int_tra_no_exig, d_mto_venc_int, d_mto_finan_vdo, cSucursal	
          FROM bdicred:sd_maesdoscrd d
          JOIN bdicred:sd_maecredcrd c on (d.num_credito = c.num_credito )
         WHERE sdo_cap_insoluto > 0 and (sdo_no_exig < 0 or int_tra_no_exig < 0 or mto_venc_int < 0 or mto_finan_vdo < 0)
		   AND  c.status_cred in ('AA','BA','BT')
           AND c.num_credito in ('770002818589','760005017958','760004988514','760005004675','760005020556','760005005599','770001923612','770002690970')


		LET d_monto_nvo_ret = 0;
		LET d_monto_int_nvo = 0;
		LET d_monto_iva_nvo = 0;
		
		IF d_sdo_no_exig < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_sdo_no_exig * -1);
			LET d_monto_int_nvo = d_monto_int_nvo + (d_sdo_no_exig * -1);
		END IF;
		IF d_mto_finan_vdo < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_mto_finan_vdo * -1);
			LET d_monto_iva_nvo = d_monto_iva_nvo + (d_mto_finan_vdo * -1);
		END IF;

		IF d_int_tra_no_exig < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_int_tra_no_exig * -1);
			LET d_monto_int_nvo = d_monto_int_nvo + (d_int_tra_no_exig * -1);
		END IF;
		IF d_mto_venc_int < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_mto_venc_int * -1);
			LET d_monto_iva_nvo = d_monto_iva_nvo + (d_mto_venc_int * -1);
		END IF;
		
		-- INTERES
		SELECT count(*) INTO iContador FROM bdicred:sd_maeretenido WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8374');
		IF iContador > 0 THEN
		
			UPDATE bdicred:"informix".sd_maeretenido SET monto = monto + d_monto_int_nvo, estatus = 'R'
			 WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8374');
		
		ELSE
			INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
				VALUES('001',cNum_Credito,cFolio,dFechaHoy,CURRENT HOUR TO FRACTION(3),'8374',0,d_monto_int_nvo,user,'R','INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);
		END IF;
		
		-- IVA INTERES
		SELECT count(*) INTO iContador FROM bdicred:sd_maeretenido WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8375');
		IF iContador > 0 THEN
		
			UPDATE bdicred:"informix".sd_maeretenido SET monto = monto + d_monto_iva_nvo, estatus = 'R'
			 WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8375');
		
		ELSE
			INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
				VALUES('001',cNum_Credito,cFolio,dFechaHoy,CURRENT HOUR TO FRACTION(3),'8375',0,d_monto_iva_nvo,user,'R','IVA INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);						
		END IF;		
		

		-- Actualiza sdo retenido en la maesdos y limpia dato negativo.
		IF d_sdo_no_exig < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_sdo_no_exig * -1), sdo_no_exig = 0
			 WHERE num_credito = cNum_Credito;
		END IF;
		IF d_mto_finan_vdo < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_mto_finan_vdo * -1), mto_finan_vdo = 0
			 WHERE num_credito = cNum_Credito;
		END IF;

		IF d_int_tra_no_exig < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_int_tra_no_exig * -1), int_tra_no_exig = 0
			 WHERE num_credito = cNum_Credito;
		END IF;
		IF d_mto_venc_int < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_mto_venc_int * -1), mto_venc_int = 0
			 WHERE num_credito = cNum_Credito;		
		END IF;
		
		
		Insert into bdicred:tmp_creditos_corregidos values (cNum_Credito, cStatusCred, d_sdo_no_exig, d_int_tra_no_exig, d_mto_venc_int, d_mto_finan_vdo);
 

	END FOREACH;

	-------
	
	SELECT count(*) INTO iContador FROM bdicred:tmp_creditos_corregidos;
	
	IF iContador > 0 THEN
	
		-- Genera archivo con informacion de creditos con lineas de credito reducidas.	
		LET cNom_Archivo_aux =  TRIM("Archivos_PP_Int_Beg_Corr_")||'Aux'||to_char(dFechaHoy,'%d%m%Y')||'.txt';
		LET cNom_Archivo =  TRIM("Archivos_PP_Int_Beg_Corr_")||to_char(dFechaHoy,'%d%m%Y')||'.txt';	
		LET cRuta = '/resplogifx/archivoscartera/';
		
		LET cSQL = '';
		LET cSQL = 'echo "num_credito'||'|'||'status_cred'||'|'||'sdo_no_exig'||'|'||'int_tra_no_exig'||'|'||'mto_venc_int'||'|'||'mto_finan_vdo'|| ' " >' || TRIM(cRuta) || cNom_Archivo;
		System cSQL;	

		
		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNom_Archivo_aux); 
		LET cSQL2 = " SELECT * FROM bdicred:tmp_creditos_corregidos";
					
			
		LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_rep_pp_corr.sql';

		LET cSQL = trim(cSQL1) || rtrim(cSQL2) || trim(cSQL3);
		SYSTEM cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cNom_Archivo_aux || " >> " || TRIM(cRuta) || cNom_Archivo;
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || cNom_Archivo_aux;
		SYSTEM cSQL;	
					
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cNom_Archivo;
		System cSQL;				

	END IF;
		
	-------

	IF iTablaExiste = 1 THEN
		DROP TABLE bdicred:tmp_creditos_corregidos;
	END IF;
	LET iTablaExiste = 0;
				

	RETURN cCodRet;	
	
END
END PROCEDURE
DOCUMENT
'Procedimiento para corregir creditos de PP con inconsistencias en sus saldos: Int e Iva negativos 			';

CREATE PROCEDURE "informix".sp_rep_actreestructura()
RETURNING CHAR(5), CHAR(90);

DEFINE cCodRet				CHAR(5);
DEFINE cMenRet				CHAR(90);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cEmpresa 			CHAR(3);
DEFINE cArchActReest		CHAR(30);
DEFINE cNumCredito			CHAR(15);
DEFINE cNumCreditoRees		CHAR(15);
DEFINE cProducto			CHAR(4);
DEFINE cProductoRees		CHAR(5);
DEFINE cNumCte				CHAR(15);
DEFINE cCommand				CHAR(1000);
DEFINE cRutaArchivo			CHAR(100);
DEFINE dFechaHoy			DATE;
DEFINE dFechaActReest		DATE;
DEFINE iSqlErr				INTEGER;
DEFINE iPlazo				INTEGER;
DEFINE iCountReg			INTEGER;
DEFINE dcSdoReest			DECIMAL(18,2);
DEFINE cPrimer_dia 		DATE;
DEFINE cUltimo_dia 		DATE;

LET iSqlErr 			= 0;
LET iPlazo				= 0;
LET dcSdoReest			= 0;
LET iCountReg			= 0;
LET cCodRet 			= '00000';
LET cMenRet				= 'PROCESO EXITOSO';
LET cDia				= '';
LET cMes				= '';
LET cAnio				= '';
LET dFechaHoy			= '';
LET dFechaActReest		= '';
LET cArchActReest		= 'ActReestructura_';
LET cRutaArchivo		= '/RESPALDOSNEW/'; --PRODUCCIÃN
--LET cRutaArchivo		= '/RESPALDOSNEW/gpe/'; -- DESARROLLO
LET cNumCredito			= '';
LET cNumCte				= '';
LET cProducto			= '';
LET cNumCreditoRees		= '';
LET cCommand			= '';
LET cPrimer_dia 		= ''; 
LET cUltimo_dia 		= '';
LET cEmpresa 			= '001';


BEGIN
		ON EXCEPTION SET iSqlErr
		
			drop table if exists temp_act_reestructura;
			
			IF iSqlErr = -668 THEN
				LET cCodRet = '00001';
				LET cMenRet = 'Proceso con terminancion -668.';
				
				RETURN cCodRet, cMenRet;
			ELIF iSqlErr != -668 THEN
				LET cCodRet = '00002';
				LET cMenRet = 'Error al ejecutar el proceso ' || iSqlErr;
				
				RETURN cCodRet, cMenRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/gpe/sp_rep_actreestructura.out";
		--TRACE ON;
		
		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy), pri_dia_mes - 1 units month, ult_dia_mes - 1 units month
		INTO dFechaHoy, cDia, cMes, cAnio, cPrimer_dia, cUltimo_dia
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = cEmpresa;
		
		--PARA PRUEBAS
		/*LET dFechaHoy = MDY('03','08','2021');
		LET cDia = DAY(dFechaHoy);
		LET cMes = MONTH(dFechaHoy);
		LET cAnio = YEAR(dFechaHoy);*/
		
		IF MONTH(dFechaHoy) < 10 THEN
			LET cMes = '0' || TRIM(cMes);
		END IF;
		
		IF DAY(dFechaHoy) < 10 THEN
			LET cDia = '0' || TRIM(cDia);
		END IF;
		
		LET cArchActReest = TRIM(cArchActReest) || cDia || cMes || cAnio || '.txt';
		
		--CREACIÃN TABLA TEMPORAL PARA ALMACENAR DATOS DE VALIDACIÃN
		IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_act_reestructura' ) THEN
			CREATE TABLE  temp_act_reestructura      	
				(fecha		            DATE,  
				numcte         			CHAR(11),
				num_cred_origen		    CHAR(20),
				producto_origen		    CHAR(4),
				num_cred_rees           CHAR(20),
				producto_rees	        CHAR(5),
				plazo			       	INTEGER,        
				sdo_rees	            DECIMAL(18,2)
			)in dbs_cfd_06 extent size 88904 next size 53342;
		END IF;
		
		FOREACH
			SELECT numcte
			INTO cNumcte
			FROM bdicred:"informix".sd_programacion_reestructuras_aut
			WHERE fecha = dFechaHoy
			
			--NÃMERO DE CRÃDITO Y PRODUCTO ORIGEN
			SELECT num_credito, num_producto
			INTO cNumCredito, cProducto
			FROM bdicred:"informix".sd_maecred 
			WHERE numcte = cNumcte;
			
			SELECT COUNT(a.num_credito)
			INTO iCountReg
			FROM bdicred:"informix".sd_maecredcrd a
			INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
			WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
			AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
			
			IF iCountReg > 0 THEN
				--NÃMERO DE CRÃDITO Y PRODUCTO REESTRUCTURA.
				SELECT a.num_credito, a.num_producto, a.fecha_apertura, a.plazo, b.sdo_cap_insoluto
				INTO cNumCreditoRees, cProductoRees,dFechaActReest,iPlazo,dcSdoReest
				FROM bdicred:"informix".sd_maecredcrd a
				INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
				WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
				AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
				
				INSERT INTO temp_act_reestructura VALUES (dFechaActReest, cNumcte, cNumCredito, cProducto, cNumCreditoRees, cProductoRees, iPlazo, dcSdoReest); 
			END IF;
		END FOREACH;
		
		--GENERACIÃN ARCHIVO ActResstructura_DDMMAAAA.txt
		LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'echo "SELECT * FROM temp_act_reestructura; " >> ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = "sed 's/|$//g' " || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || '_1.txt > ' || TRIM(cRutaArchivo) || TRIM(cArchActReest);
		SYSTEM TRIM(cCommand);
		
		--ELIMINACIÃN TABLA Y ARCHIVOS
		DROP TABLE temp_act_reestructura;
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || '_1.txt';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		EXECUTE PROCEDURE "informix".sp_rep_envioreestructura()
		INTO cCodRet, cMenRet;
		
		RETURN cCodRet, cMenRet;
	END
END PROCEDURE;