CREATE PROCEDURE "informix".sp_asignacionmasivasitesp()
RETURNING CHAR(6)  AS COD_RET, 
          CHAR(80) AS MENSAJE_RET;
	
	--DECLARACIONES
	DEFINE iSqlErr                INTEGER;
	DEFINE iIsamErr               INTEGER;
	DEFINE cErrorInfo             CHAR(80);
	DEFINE cCodRet                CHAR(6);
	DEFINE cMensajeRet            CHAR(80);
	DEFINE cNumCte                CHAR(20);
	DEFINE cSituacionPuente       CHAR(1);
	DEFINE sCausaPuente           SMALLINT;
	DEFINE sVecesClientePuente    SMALLINT;
	DEFINE sExiste_Actual         SMALLINT;
	DEFINE cSituacion_Actual      CHAR(1);
	DEFINE sCausa_Actual          SMALLINT;
	DEFINE sCalculaPonderacion    SMALLINT;
	DEFINE sPonderacionPuente     SMALLINT;
	DEFINE sPonderacionActual     SMALLINT;
	DEFINE sExisteHistorico       SMALLINT;
	DEFINE sIdMovtoActual         SMALLINT;
	DEFINE cSituacionMaxima       CHAR(1);
	DEFINE sCausaMaxima           SMALLINT;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	DEFINE dtFecha_Hora           DATETIME YEAR TO SECOND;
	--VARIABLE PARA CONTROLAR LA TRANSACCIONALIDAD
	DEFINE iContadorRegistros     INTEGER;
	DEFINE sProcesosCorridos      SMALLINT;
	DEFINE cComentario            CHAR(80);
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	DEFINE cProcesoEjecutandose   CHAR(3);
	DEFINE cBorraAmbasFechas      CHAR(1);
	DEFINE sPonderacionMaxima     SMALLINT;
	DEFINE cNombreEfectuo         CHAR(30);
	DEFINE cSituacionHist         CHAR(1);
	DEFINE sCausaHist             SMALLINT;
	DEFINE sPonderacionHist       SMALLINT;
	DEFINE cSituacionExcepcion    CHAR(1);
	DEFINE sCausaExcepcion        SMALLINT;
	DEFINE cSituacion	        CHAR(1);
	DEFINE sCausa	     		SMALLINT;
	DEFINE sBandera	     		SMALLINT;
	DEFINE sEntro               SMALLINT;
	
	--INICIALIZACIONES
	LET iSqlErr                   = 0;
	LET iIsamErr                  = 0;
	LET cErrorInfo                = '';
	LET cCodRet                   = '000000';
	LET cMensajeRet               = 'PROCESO EXITOSO';
	LET cNumCte                   = '' ;
	LET cSituacionPuente          = '';
	LET sCausaPuente              = 0;
	LET sVecesClientePuente       = 0;
	LET sExiste_Actual            = 0;
	LET cSituacion_Actual         = '';
	LET sCausa_Actual             = 0;
	LET sCalculaPonderacion       = 0;
	LET sPonderacionPuente        = 0;
	LET sPonderacionActual        = 0;
	LET sExisteHistorico          = 0;
	LET sIdMovtoActual            = 0;
	LET cSituacionMaxima          = '';
	LET sCausaMaxima              = 0;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	LET dtFecha_Hora              = DATE(1);
	--VARIABLE PARA CONTROLAR LA TRANSACCIONALIDAD
	LET iContadorRegistros        = 0;
	LET sProcesosCorridos         = 0;
	LET cComentario               = '';
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	LET cProcesoEjecutandose      = '';
	LET cBorraAmbasFechas         = '';
	LET sPonderacionMaxima        = 0;
	LET cNombreEfectuo            = '';
	LET cSituacionHist            = ''; 
	LET sCausaHist                = 0;
	LET sPonderacionHist          = 0;
	LET cSituacionExcepcion       = '';
	LET sCausaExcepcion           = 0;
	LET cSituacion		     = '';
	LET sCausa				 = 0;
	LET sBandera			 = 0;
	LET sEntro             = 0;
	
	
		--SET DEBUG FILE TO '/informix/cristo/asignacion_masiva.out';
		--TRACE ON;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr <> 0 THEN
				UPDATE "informix".se_bitacoramasiva SET estatus_proc = '0' WHERE nombre_proceso = 'AMS';
				LET cCodRet = iSqlErr;
				LET cMensajeRet= cErrorInfo;
			  --SI QUEDA ABIERTA LA TRANSACCION QUE SE CIERRE.
				IF iSqlErr = -535 THEN
					COMMIT WORK;						
				END IF;
			  RETURN cCodRet,cMensajeRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)	
			IF iContadorRegistros > 0 THEN 
				COMMIT WORK;			
			END IF;	
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(fecha_hoy) AS registros
		INTO sProcesosCorridos
		FROM bdinteg:"informix".si_fechas
		where empresa = '001';
		
		
		--SE VERIFICA QUE SE HAYAN CORRIDO PREVIAMENTE LOS 4 PROCEDIMIENTOS (QUEBRANTOS,REESTRUCTURA,FRAUDE,LISTA NEGRA)
		SELECT {+INDEX(se_bitacoramasiva idx_se_bitacoramasiva)} COUNT(estatus_proc) AS procesos_corridos 
		INTO sProcesosCorridos
		FROM "informix".se_bitacoramasiva 
		WHERE nombre_proceso <> 'AMS' 
		AND estatus_proc = '2';
		
		IF sProcesosCorridos <> 4 THEN
			LET cCodRet = '000002';
			LET cMensajeRet= 'VERIFIQUE QUE LOS 4 PROCESOS ANTERIORES HAYAN CORRIDO CORRECTAMENTE.';
			RETURN cCodRet,cMensajeRet;
		
		END IF;
		
		--SE VERIFICA QUE EL SP NO ESTE EN EJECUCION
		SELECT CASE WHEN estatus_proc = '1' THEN '1' ELSE '0' END, CASE WHEN (inicia_proc IS NULL AND termina_proc IS NULL)OR(inicia_proc IS NOT NULL AND termina_proc IS NOT NULL)THEN '1' ELSE '0' END
		INTO cProcesoEjecutandose, cBorraAmbasFechas
		FROM "informix".se_bitacoramasiva 
		WHERE nombre_proceso = 'AMS';
		
		IF cProcesoEjecutandose = '1' THEN
			LET cCodRet = '000001';
			LET cMensajeRet= 'PROCEDIMIENTO EJECUTANDOSE';
			RETURN cCodRet,cMensajeRet;
		ELSE
			SELECT DBINFO('utc_to_datetime', sh_curtime) AS fecha_hora 
			INTO dtFecha_Hora
			FROM sysmaster:"informix".sysshmvals;
			
			IF cBorraAmbasFechas = '1' THEN
				--SE LIMPIAN LOS CAMPOS DE INICIA Y TERMINA PROC
				UPDATE "informix".se_bitacoramasiva  SET inicia_proc = NULL, termina_proc = NULL WHERE nombre_proceso = 'AMS';
			
				UPDATE "informix".se_bitacoramasiva SET inicia_proc = dtFecha_Hora  WHERE nombre_proceso = 'AMS';
			END IF;
			
			UPDATE "informix".se_bitacoramasiva SET estatus_proc = '1' WHERE nombre_proceso = 'AMS';
			
			
		END IF;	
		
	FOREACH WITH HOLD
		--SE BARREN LOS DISTINTOS CLIENTES DE LA se_sitespmasivo Y SE CUENTA CUANTAS SITUACIONES-CAUSA TIENEN REGISTRADAS CADA UNO
		SELECT DISTINCT(numcte),COUNT(*) AS veces_en_tabla
		INTO cNumCte, sVecesClientePuente
		FROM "informix".se_sitespmasivo
		WHERE empresa = '001'
		AND numcte = numcte
		AND fecha = fecha
		AND etapa5 = '0'
		GROUP BY 1
		
		
		--SE BUSCA EN LA se_ctessitespcte (SOLO HAY UN REGISTRO POR CLIENTE)SI EXISTE EL CLIENTE, LA SITUACION y LA CAUSA 
		SELECT COUNT(*) AS existe_en_tabla
		INTO sExiste_Actual
		FROM "informix".se_ctessitespcte
		WHERE idmovto = idmovto
		AND empresa = '001'
		AND numcte = TRIM(cNumCte);
		
		--SI EL CLIENTE TIENE REGISTRO SE CONSULTA LA SITUACION Y LA CAUSA
		IF sExiste_Actual > 0 THEN
			SELECT situacion, causa
			INTO cSituacion_Actual,sCausa_Actual
			FROM "informix".se_ctessitespcte
			WHERE idmovto = idmovto
			AND empresa = '001'
			AND numcte = TRIM(cNumCte);
		END IF; 
		
		--SI EL CLIENTE SOLO TIENE UNA SITUACION-CAUSA EN LA se_sitespmasivo Y SOLO UN REGISTRO EN LA se_ctessitespcte
		IF sVecesClientePuente = 1  THEN --IF PRINCIPAL
				IF sExiste_Actual = 1 THEN --IF EXISTEACTUAL
						--COMO SE SABE QUE EL CLIENTE SOLO TIENE UNA SITUACION-CAUSA SE CONSULTA SIN FOREACH
						SELECT situacion, causa
						INTO cSituacionPuente, sCausaPuente
						FROM "informix".se_sitespmasivo
						WHERE empresa = '001'
						AND numcte = TRIM(cNumCte)
						AND fecha = fecha
						AND etapa5 = '0'; --BARRE LOS QUE NO HAYAN SIDO PROCESADOS
						
						--SE INICIALIZA LA VARIABLE PARA CALCULAR LAS PONDERACIONES
						LET sCalculaPonderacion = 1;
						
						--SE CONSULTAN LAS PONDERACIONES DE LA MASIVA Y LA ACTUAL
						WHILE sCalculaPonderacion < 3
						
							IF sCalculaPonderacion = 1 THEN
									SELECT ponderacion
									INTO sPonderacionPuente
									FROM "informix".se_catsitesp
									WHERE situacion = cSituacionPuente
									AND causa = sCausaPuente
									AND ponderacion <> 0;
									
									
									LET sCalculaPonderacion = sCalculaPonderacion + 1;
							ELIF sCalculaPonderacion = 2 THEN
									SELECT ponderacion
									INTO sPonderacionActual
									FROM "informix".se_catsitesp
									WHERE situacion = cSituacion_Actual
									AND causa = sCausa_Actual
									AND ponderacion <> 0;
									
									LET sPonderacionActual = NVL(sPonderacionActual,0);
									LET sCalculaPonderacion = sCalculaPonderacion + 1;
							END IF;
						END WHILE;
						
						LET sCalculaPonderacion = 0;
						
						--LA QUE TIENE MAYOR PONDERACION ES LA QUE SE ACTUALIZA, MIENTRAS QUE LA OTRA SE VA AL HISTORICO
						IF sPonderacionPuente < sPonderacionActual OR sPonderacionActual=0 THEN --IF COMPARA PONDERACIONES
						
							IF  sPonderacionPuente IN (1,11) THEN 
								LET cComentario = 'CRÉDITO QUEBRANTADO' ;
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 3 THEN 
								LET cComentario = 'LISTA NEGRA BANCOPPEL' ;
								LET cNombreEfectuo = 'PLD';
							ELIF sPonderacionPuente = 12 THEN 
								LET cComentario = 'CRÉDITO REESTRUCTURADO'; 
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 7 THEN 
								LET cComentario = 'CLIENTE FRAUDE' ;
								LET cNombreEfectuo = 'OPERACION CLN.';
							ELSE 
								LET cComentario = '';
								LET cNombreEfectuo = '';
							END IF;
														
							
							--SI LA PONDERACION NUEVA ES MENOR (DE MAS PESO) QUE LA ACTUAL SE ACTUALIZA LA  se_ctessitespcte CON LA SITUACION-CAUSA
							UPDATE "informix".se_ctessitespcte SET tipomovto = 'S',cvesitesporigen='2',situacion = cSituacionPuente, causa = sCausaPuente , motivo_desmarcaje = cComentario, empleadoefectuo = 'INFORMIX' ,nombreefectuo = cNombreEfectuo, usralta = 'INFORMIX' WHERE idmovto = idmovto AND empresa = '001' AND numcte = TRIM(cNumCte);
							
							
							--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
							UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionPuente AND causa = sCausaPuente;

							
							--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
							LET iContadorRegistros = iContadorRegistros + 1;


							--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
							IF iContadorRegistros = 1 AND sEntro = 0 THEN
								BEGIN WORK;
								LET sEntro = 1;
							END IF;

							
							--SE VERIFICA QUE LA ANTERIOR NO EXISTA EN EL HISTORICO
							SELECT COUNT(*) AS existe_historico
							INTO sExisteHistorico 
							FROM "informix".se_ctessitespcte_his
							WHERE idmovto = idmovto
							AND tipomovto = tipomovto
							AND numcte  = TRIM(cNumCte)
							AND empresa = '001'
							AND situacion = cSituacion_Actual
							AND causa = sCausa_Actual;
							
							--SI NO EXISTE SE INSERTA, SI YA EXISTIA CON EL CLIENTE Y MISMA SITUACION-CAUSA NO SE HACE NADA,SE DEJA
							IF sExisteHistorico = 0 THEN
							
								--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
								LET iContadorRegistros = iContadorRegistros + 1;


								--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
								IF iContadorRegistros = 1 AND sEntro = 0 THEN
									BEGIN WORK;
									LET sEntro = 1;
								END IF;
							
								--SI EL CLIENTE NO TENIA REGISTROS  CON ESA CAUSA Y SITUACION
								INSERT INTO "informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) VALUES ('M',cNumCte,'001',cSituacion_Actual,sCausa_Actual,2,'','INFORMIX','INFORMIX',CURRENT,'',CURRENT);
								
									--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
								UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacion_Actual AND causa = sCausa_Actual;
								
							END IF;
							
						ELIF sPonderacionActual <= sPonderacionPuente   THEN  --LA PONDERACION ACTUAL ES DE MENOR PESO
							
							--SE VERIFICA QUE LA QUE SE VA A INSERTAR NO EXISTA EN EL HISTORICO
							SELECT COUNT(*) AS existe_historico
							INTO sExisteHistorico 
							FROM "informix".se_ctessitespcte_his
							WHERE idmovto = idmovto
							AND tipomovto = tipomovto
							AND numcte  = TRIM(cNumCte)
							AND empresa = '001'
							AND situacion = cSituacionPuente
							AND causa = sCausaPuente;
							
							--SI NO EXISTE SE INSERTA, SI YA EXISTIA CON EL CLIENTE Y MISMA SITUACION-CAUSA NO SE HACE NADA,SE DEJA
							IF sExisteHistorico = 0 THEN
								--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
								LET iContadorRegistros = iContadorRegistros + 1;


								--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
								IF iContadorRegistros = 1 AND sEntro = 0 THEN
									BEGIN WORK;
									LET sEntro = 1;
								END IF;
								
							
								--SI EL CLIENTE NO TENIA REGISTROS  CON ESA CAUSA Y SITUACION
								INSERT INTO "informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) VALUES ('M',cNumCte,'001',cSituacionPuente,sCausaPuente,2,'    ','INFORMIX','INFORMIX',CURRENT,'',CURRENT);
								
								--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
								UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionPuente AND causa = sCausaPuente;
			  		  
							END IF;
							
							
						END IF; --IF COMPRA PONDERACIONES
				ELIF sExiste_Actual = 0 THEN
				
						--COMO SE SABE QUE EL CLIENTE SOLO TIENE UNA SITUACION-CAUSA SE CONSULTA SIN FOREACH
						SELECT sit.situacion, sit.causa, pon.ponderacion
						INTO cSituacionPuente, sCausaPuente, sPonderacionPuente
						FROM "informix".se_sitespmasivo sit
						LEFT OUTER JOIN "informix".se_catsitesp pon ON (sit.situacion = pon.situacion AND sit.causa = pon.causa AND pon.ponderacion <> 0)
						WHERE sit.empresa = '001'
						AND sit.numcte = TRIM(cNumCte)
						AND sit.fecha = sit.fecha
						AND sit.etapa5 = '0'; --BARRE LOS QUE NO HAYAN SIDO PROCESADOS
						
						IF  sPonderacionPuente IN (1,11) THEN 
								LET cComentario = 'CRÉDITO QUEBRANTADO' ;
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 3 THEN 
								LET cComentario = 'LISTA NEGRA BANCOPPEL' ;
								LET cNombreEfectuo = 'PLD';
							ELIF sPonderacionPuente = 12 THEN 
								LET cComentario = 'CRÉDITO REESTRUCTURADO'; 
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 7 THEN 
								LET cComentario = 'CLIENTE FRAUDE' ;
								LET cNombreEfectuo = 'OPERACION CLN.';
							ELSE 
								LET cComentario = '';
								LET cNombreEfectuo = '';
							END IF;
							
						--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
						LET iContadorRegistros = iContadorRegistros + 1;


						--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
						IF iContadorRegistros = 1 AND sEntro = 0 THEN
							BEGIN WORK;
							LET sEntro = 1;
						END IF;

						INSERT INTO "informix".se_ctessitespcte (empresa,numcte,situacion,causa,cvesitesporigen,sucursal,tipomovto,empleadoefectuo,nombreefectuo,fechamovto,usralta,fchalta,usrmodifica,fchmodifica,motivo_desmarcaje) VALUES ('001',cNumCte,cSituacionPuente,sCausaPuente,'2','    ','M','INFORMIX',cNombreEfectuo,CURRENT,NULL,CURRENT,'INFORMIX',CURRENT,cComentario);
						
					--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
					UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionPuente AND causa = sCausaPuente;

				END IF; --IF EXISTEACTUAL
				
		ELIF sVecesClientePuente > 1 THEN		
			FOREACH
				--SE OBTIENE Y CALCULA LA SITUACION Y CAUSA CON LA MAXIMA PONDERACION
				SELECT LIMIT 1 prin.situacion, prin.causa, cat.ponderacion
				INTO cSituacionMaxima, sCausaMaxima, sPonderacionMaxima
				FROM "informix".se_sitespmasivo prin
				INNER JOIN "informix".se_catsitesp cat ON(cat.situacion = prin.situacion AND cat.causa = prin.causa AND cat.ponderacion <> 0)
				WHERE prin.empresa = '001'
				AND prin.numcte = TRIM(cNumCte)
				AND prin.fecha = prin.fecha
				AND prin.etapa5 = '0' --BARRE LOS QUE NO HAYAN SIDO PROCESADOS
				ORDER BY 3
				
				LET cSituacionExcepcion = cSituacionMaxima;
				LET sCausaExcepcion = sCausaMaxima;
			END FOREACH;
				--SI YA HAY REGISTROS EN LA ACTUAL
				IF sExiste_Actual = 1 THEN 
				
						SELECT ponderacion
						INTO sPonderacionActual
						FROM "informix".se_catsitesp
						WHERE situacion = cSituacion_Actual
						AND causa = sCausa_Actual
						AND ponderacion <> 0;
						
						LET sPonderacionActual = NVL(sPonderacionActual,0);
						
						--SI LA PONDERACION MAXIMA DE CLIENTE ES MENOS A LA QUE TIENE ACTUALMENTE
						IF sPonderacionMaxima < sPonderacionActual Or sPonderacionActual=0 THEN --IF COMPARA PONDERACIONES
							
							IF  sPonderacionPuente IN (1,11) THEN 
								LET cComentario = 'CRÉDITO QUEBRANTADO' ;
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 3 THEN 
								LET cComentario = 'LISTA NEGRA BANCOPPEL' ;
								LET cNombreEfectuo = 'PLD';
							ELIF sPonderacionPuente = 12 THEN 
								LET cComentario = 'CRÉDITO REESTRUCTURADO'; 
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 7 THEN 
								LET cComentario = 'CLIENTE FRAUDE' ;
								LET cNombreEfectuo = 'OPERACION CLN.';
							ELSE 
								LET cComentario = '';
								LET cNombreEfectuo = '';
							END IF;
					
							--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
							LET iContadorRegistros = iContadorRegistros + 1;


							--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
							IF iContadorRegistros = 1 AND sEntro = 0 THEN
								BEGIN WORK;
								LET sEntro = 1;
							END IF;
							
							--SI LA PONDERACION NUEVA ES MENOR (DE MAS PESO) QUE LA ACTUAL SE ACTUALIZA LA  se_ctessitespcte CON LA SITUACION-CAUSA
							
							UPDATE "informix".se_ctessitespcte SET tipomovto='S',cvesitesporigen='2',situacion = cSituacionMaxima, causa = sCausaMaxima, motivo_desmarcaje = cComentario, empleadoefectuo = 'INFORMIX' ,nombreefectuo = cNombreEfectuo, usralta = 'INFORMIX' WHERE idmovto = idmovto AND empresa = '001' AND numcte = TRIM(cNumCte);
							
							--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
							UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionMaxima AND causa = sCausaMaxima;
							
								
							--SE VERIFICA QUE LA ANTERIOR NO EXISTA EN EL HISTORICO
							SELECT COUNT(*) AS existe_historico
							INTO sExisteHistorico 
							FROM "informix".se_ctessitespcte_his
							WHERE idmovto = idmovto
							AND tipomovto = tipomovto
							AND numcte  = TRIM(cNumCte)
							AND empresa = '001'
							AND situacion = cSituacion_Actual
							AND causa = sCausa_Actual;
							
							--SI NO EXISTE SE INSERTA, SI YA EXISTIA CON EL CLIENTE Y MISMA SITUACION-CAUSA NO SE HACE NADA,SE DEJA
							IF sExisteHistorico = 0 THEN
								--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
								LET iContadorRegistros = iContadorRegistros + 1;


								--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
								IF iContadorRegistros = 1 AND sEntro = 0 THEN
									BEGIN WORK;
									LET sEntro = 1;
								END IF;
								
								--SI EL CLIENTE NO TENIA REGISTROS  CON ESA CAUSA Y SITUACION
								INSERT INTO "informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) VALUES ('M',cNumCte,'001',cSituacion_Actual,sCausa_Actual,2,'    ','INFORMIX','INFORMIX',CURRENT,'',CURRENT);
								
								--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
								UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacion_Actual AND causa = sCausa_Actual;
								
							END IF;
							
							
						ELIF sPonderacionActual <= sPonderacionMaxima THEN  --LA PONDERACION ACTUAL ES DE MENOR PESO
							
							--SE VERIFICA QUE LA QUE SE VA A INSERTAR NO EXISTA EN EL HISTORICO
							SELECT COUNT(*) AS existe_historico
							INTO sExisteHistorico 
							FROM "informix".se_ctessitespcte_his
							WHERE idmovto = idmovto
							AND tipomovto = tipomovto
							AND numcte  = TRIM(cNumCte)
							AND empresa = '001'
							AND situacion = cSituacionMaxima
							AND causa = sCausaMaxima;
							
							--SI NO EXISTE SE INSERTA, SI YA EXISTIA CON EL CLIENTE Y MISMA SITUACION-CAUSA NO SE HACE NADA,SE DEJA
							IF sExisteHistorico = 0 THEN
								--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
								LET iContadorRegistros = iContadorRegistros + 1;


								--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
								IF iContadorRegistros = 1 AND sEntro = 0 THEN
									BEGIN WORK;
									LET sEntro = 1;
								END IF;
								
								--SI EL CLIENTE NO TENIA REGISTROS  CON ESA CAUSA Y SITUACION
								INSERT INTO "informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) VALUES ('M',cNumCte,'001',cSituacionMaxima,sCausaMaxima,2,'    ','INFORMIX','INFORMIX',CURRENT,'',CURRENT);
								
								--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
								UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionMaxima AND causa = sCausaMaxima;
							END IF;
							
						END IF; --IF COMPARA PONDERACIONES
						
				ELIF sExiste_Actual = 0 THEN
				
						--COMO SE SABE QUE EL CLIENTE SOLO TIENE UNA SITUACION-CAUSA SE CONSULTA SIN FOREACH
						SELECT sit.situacion, sit.causa, pon.ponderacion
						INTO cSituacionPuente, sCausaPuente, sPonderacionPuente
						FROM "informix".se_sitespmasivo sit
						LEFT OUTER JOIN "informix".se_catsitesp pon ON (sit.situacion = pon.situacion AND sit.causa = pon.causa AND pon.ponderacion <> 0)
						WHERE sit.empresa = '001'
						AND sit.numcte = TRIM(cNumCte)
						AND sit.fecha = sit.fecha
					    AND sit.situacion = cSituacionMaxima
						AND sit.causa = sCausaMaxima
						AND sit.etapa5 = '0'; --BARRE LOS QUE NO HAYAN SIDO PROCESADOS
						
						IF  sPonderacionPuente IN (1,11) THEN 
								LET cComentario = 'CRÉDITO QUEBRANTADO' ;
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 3 THEN 
								LET cComentario = 'LISTA NEGRA BANCOPPEL' ;
								LET cNombreEfectuo = 'PLD';
							ELIF sPonderacionPuente = 12 THEN 
								LET cComentario = 'CRÉDITO REESTRUCTURADO'; 
								LET cNombreEfectuo = 'CREDITO Y COBRANZA';
							ELIF sPonderacionPuente = 7 THEN 
								LET cComentario = 'CLIENTE FRAUDE' ;
								LET cNombreEfectuo = 'OPERACION CLN.';
							ELSE 
								LET cComentario = '';
								LET cNombreEfectuo = '';
						END IF;
						
						--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
						LET iContadorRegistros = iContadorRegistros + 1;


						--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
						IF iContadorRegistros = 1 AND sEntro = 0 THEN
								BEGIN WORK;
								LET sEntro = 1;
						END IF;
					
						INSERT INTO "informix".se_ctessitespcte (empresa,numcte,situacion,causa,cvesitesporigen,sucursal,tipomovto,empleadoefectuo,nombreefectuo,fechamovto,usralta,fchalta,usrmodifica,fchmodifica,motivo_desmarcaje) VALUES ('001',cNumCte,cSituacionMaxima,sCausaMaxima,'2','    ','M','INFORMIX',cNombreEfectuo,CURRENT,NULL,CURRENT,'INFORMIX',CURRENT,cComentario);
						
						--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
						UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionMaxima AND causa = sCausaMaxima;
						
						 LET cSituacionMaxima = '';
						 LET sCausaMaxima = 0;
						 					
				END IF;
			
				--SE INSERTAN EN EL HISTORIO EL RESTO DE SITUACIONES-CAUSA QUE NO TUVIERON LA PONDERACION DE MAS PESO
							FOREACH
								SELECT prin.situacion, prin.causa, cat.ponderacion
								INTO cSituacionHist, sCausaHist, sPonderacionHist
								FROM "informix".se_sitespmasivo prin
								INNER JOIN "informix".se_catsitesp cat ON(cat.situacion = prin.situacion AND cat.causa = prin.causa AND cat.ponderacion <> 0)
								WHERE prin.empresa = '001'
								AND prin.numcte = TRIM(cNumCte)
								AND prin.fecha = prin.fecha
								--AND prin.situacion <> cSituacionMaxima
								--AND prin.causa <> sCausaMaxima
								AND cat.ponderacion > sPonderacionMaxima
								AND prin.etapa5 = '0' --BARRE LOS QUE NO HAYAN SIDO PROCESADOS
								
								--SE VERIFICA QUE LA QUE SE VA A INSERTAR NO EXISTA EN EL HISTORICO
								SELECT COUNT(*) AS existe_historico
								INTO sExisteHistorico 
								FROM "informix".se_ctessitespcte_his
								WHERE idmovto = idmovto
								AND tipomovto = tipomovto
								AND numcte  = TRIM(cNumCte)
								AND empresa = '001'
								AND situacion = cSituacionHist
								AND causa = sCausaHist;
								
								--SI NO EXISTE SE INSERTA, SI YA EXISTIA CON EL CLIENTE Y MISMA SITUACION-CAUSA NO SE HACE NADA,SE DEJA
								LET cSituacionHist = cSituacionHist;
								LET sCausaHist = sCausaHist;
								LET cSituacionExcepcion = cSituacionExcepcion;
								LET sCausaExcepcion = sCausaExcepcion;
								IF (cSituacionHist||sCausaHist) <> (cSituacionExcepcion||sCausaExcepcion) THEN
									IF sExisteHistorico = 0 THEN
										--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
										LET iContadorRegistros = iContadorRegistros + 1;


										--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
										IF iContadorRegistros = 1 AND sEntro = 0 THEN
											BEGIN WORK;
											LET sEntro = 1;
										END IF;
									
										--SI EL CLIENTE NO TENIA REGISTROS  CON ESA CAUSA Y SITUACION
										INSERT INTO "informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) VALUES ('M',cNumCte,'001',cSituacionHist,sCausaHist,2,'    ','INFORMIX','INFORMIX',CURRENT,'',CURRENT);
										
										--MARCA QUE EL CLIENTE CON ESA SITUACION Y ESA CAUSA YA FUERON PROCESADOS 
										UPDATE "informix".se_sitespmasivo SET etapa5='1' WHERE empresa = '001' AND numcte = TRIM(cNumcte) AND fecha = fecha AND situacion = cSituacionHist AND causa = sCausaHist;
										
										
									END IF;
								END IF;

								LET cSituacionHist = '';
								LET sCausaHist = 0;
							END FOREACH;
				

		END IF; --IF PRINCIPAL
		

			--SE HARA EN BLOQUES DE 1,000 REGISTROS
			IF iContadorRegistros = 1000 THEN
				--SE CIERRA LA TRANSACCION
				COMMIT WORK;	
				--SE REINICIA LA VARIABLE USADA PARA LLEVAR EL CONTROL
				LET iContadorRegistros = 0;
				LET sBandera = 0;
				LET sEntro = 0;		
			END IF;		
		

	END FOREACH;	
	
			
		--SE OBTIENE LA FECHA Y HORA EXACTA SEL SISTEMA
		LET dtFecha_Hora = '';
	
		SELECT DBINFO('utc_to_datetime', sh_curtime) AS fecha_hora 
		INTO dtFecha_Hora
		FROM sysmaster:"informix".sysshmvals;
		
		--SE DEJA LA BANDERA EN '2' Y SE INDICE QUE LA FECHA Y LA HORA EN QUE TERMINO EL PROESO
		UPDATE "informix".se_bitacoramasiva SET termina_proc = dtFecha_Hora , estatus_proc = '2' WHERE nombre_proceso = 'AMS';
		
			IF iContadorRegistros > 0 THEN
				COMMIT WORK;
		    END IF;
		
			RETURN cCodRet,cMensajeRet;
	END;
END PROCEDURE
