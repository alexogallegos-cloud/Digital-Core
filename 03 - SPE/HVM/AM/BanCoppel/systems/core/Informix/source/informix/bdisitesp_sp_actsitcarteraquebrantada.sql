CREATE PROCEDURE "informix".sp_actsitcarteraquebrantada()
RETURNING CHAR(6)  AS COD_RET, 
          CHAR(80) AS MENSAJE_RET;
	
	--DECLARACIONES
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	DEFINE cCodRet              CHAR(6);
	DEFINE cMensajeRet          CHAR(80);
	DEFINE cNumCte              CHAR(20);
	DEFINE cCod_Caract_2        CHAR(3);
	DEFINE cStatus_cred         CHAR(2);
	DEFINE sCuentasCanceladas   SMALLINT;
	
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	DEFINE iContadorRegistros   INTEGER;
	
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	DEFINE cProcesoEjecutandose CHAR(3);
	
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	DEFINE dtFecha_Hora         DATETIME YEAR TO SECOND;	
	DEFINE cSituacion	        CHAR(1);
	DEFINE sCausa	     		SMALLINT;
	DEFINE sBandera	     		SMALLINT;
	DEFINE sEnTransaccion       SMALLINT;
	
	--INICIALIZACIONES
	LET iSqlErr              	= 0;
	LET iIsamErr             	= 0;
	LET cErrorInfo           	= '';
	LET cCodRet              	= '000000';
	LET cMensajeRet          	= 'PROCESO EXITOSO';
	LET cNumCte              	= '';
	LET cCod_Caract_2        	= '';
	LET cStatus_cred         	= '';
	LET sCuentasCanceladas   	= 0;
	
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	LET iContadorRegistros   	= 0;
	
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	LET cProcesoEjecutandose 	= '';
	
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	LET dtFecha_Hora         	= DATE(1);	
	LET cSituacion		     	= '';
	LET sCausa				 	= 0;
	LET sBandera			 	= 0;
	LET sEnTransaccion			= 0;
	
	--SET DEBUG FILE TO '/respaldosbd/resbdrigoberto/nvasconscaptacionsif/quebrantossegundaversion.out';
	--TRACE ON;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr <> 0 THEN
				UPDATE "informix".se_bitacoramasiva SET estatus_proc = '0' WHERE nombre_proceso = 'CQB';
				LET cCodRet = iSqlErr;
				LET cMensajeRet= cErrorInfo;
			  --SI QUEDA ABIERTA LA TRANSACCION QUE SE CIERRE.
				IF sEnTransaccion = 1 THEN
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
		
		--SE VERIFICA QUE EL SP NO ESTE EN EJECUCION
		SELECT CASE WHEN estatus_proc = '1' THEN '1' ELSE '0' END
		INTO cProcesoEjecutandose
		FROM "informix".se_bitacoramasiva
		WHERE nombre_proceso = 'CQB';
		
		IF cProcesoEjecutandose = '1' THEN
			LET cCodRet = '000001';
			LET cMensajeRet= 'PROCEDIMIENTO EJECUTANDOSE';
			RETURN cCodRet,cMensajeRet;
		ELSE
			SELECT DBINFO('utc_to_datetime', sh_curtime) AS fecha_hora 
			INTO dtFecha_Hora
			FROM sysmaster:"informix".sysshmvals;
			
			--SE LIMPIAN LOS CAMPOS DE INICIA Y TERMINA PROC
			UPDATE "informix".se_bitacoramasiva SET inicia_proc = dtFecha_Hora, termina_proc = NULL, estatus_proc = '1' WHERE nombre_proceso='CQB';
			
		END IF;		
			
		FOREACH WITH HOLD
		
			-- SE BARREN TODOS LOS CLIENTES QUE AUN NO HAN SIDO EVALUADOS EN LA ETAPA 1
			SELECT NVL(si.numcte,'')
			INTO cNumCte
			FROM bdinteg:"informix".si_cliente si
			LEFT OUTER JOIN "informix".se_sitespmasivo se ON(se.empresa='001' AND si.numcte=se.numcte AND se.fecha=se.fecha AND se.etapa1='1' AND se.procesado='P')
			WHERE si.numcte = si.numcte  
			AND si.empresa ='001'
			AND se.numcte IS NULL
		
			--SE BUSCA EN TODA LA MAECRED INDEPENDIENTEMENTE DE SI UN DADO CLIENTE EXISTE MAS DE UNA VEZ
			SELECT	SUM(CASE WHEN NVL(cod_caract_2,'') = '04' THEN 1 ELSE 0 END)  AS cod_caract_2,
					SUM(CASE WHEN NVL(status_cred,'') = 'CV' THEN 1 ELSE 0 END ) AS status_cred
			INTO cCod_Caract_2, cStatus_cred
			FROM bdicred:"informix".sd_maecred
			WHERE empresa = '001'
			AND numcte = cNumCte
			AND ( cod_caract_2 = '04' OR status_cred = 'CV' )
			GROUP BY empresa, numcte;
			
			--SI SE ENCONTRO INFORMACION ALGUNA EN LA MAECRED
			IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
			
				IF cCod_Caract_2::SMALLINT > 0 THEN
					--SI EL CLIENTE TIENE COMO CAUSA DE QUEBRANTO POR FALLECIMIENTO EN LA MAECRED SE REGISTRA EN LA SE_SITESPMASIVO				
					LET cSituacion = 'F';
					LET sCausa = 42; 
					LET sBandera = 1;				
					--SE REGISTRA QUE SE ENCONTRO CLIENTE CON CAUSA CQB
					LET iContadorRegistros = iContadorRegistros + 1;						
				ELSE						
					IF cStatus_Cred::SMALLINT > 0 THEN
						--SI EL CLIENTE NO TIENE CAUSA DE QUEBRANTO POR FALLECIMIENTO SE VERIFICA SI ESTA REGISTRADO COMO CARTERA VENDIDA
						--SI EL CLIENTE ESTA CON ESTATUS DE CARTERA VENDIDA SE INSERTA UN NUEVO REGISTRO EN LA SE_SITESPMASIVO				
						LET cSituacion = 'T';
						LET sCausa = 97; 
						LET sBandera = 1;
						--SE REGISTRA QUE SE ENCONTRO CLIENTE CON CAUSA CQB
						LET iContadorRegistros = iContadorRegistros + 1;
					END IF;							
				END IF;
			--NO SE ENCONTRO INFORMACION ALGUNA EN LA MAECRED	
			ELSE
			
				--SE BUSCA SI TIENE ALGUNA CUENTA RELACIONADA EN LA TABLA SC_CTACANCELADA, ASEGURANDOSE QUE EXISTA TAMBIEN EN LA SC_MAECHQ
				SELECT {+INDEX(bdicheq:"informix".sc_ctacancelada idx_sc_ctacan)} COUNT(a.cuenta) AS cuentas_canceladas
				INTO sCuentasCanceladas
				FROM bdicheq:"informix".sc_ctacancelada a
				INNER JOIN bdicheq:"informix".sc_maechq b ON ( b.empresa = '001' AND a.cuenta = b.cuenta AND b.num_cte = TRIM(cNumCte))
				WHERE a.cuenta = b.cuenta 
				AND a.folio_cancelacion = a.folio_cancelacion 
				AND a.motivo = '04'
				GROUP BY b.num_cte;

				IF sCuentasCanceladas > 0 THEN
					--SI EL CLIENTE TIENE REGISTRADA ALGUNA CUENTA COMO CANCELADA SE INSERTA EN LA SE_SITESPMASIVO
					LET cSituacion = 'F';
					LET sCausa = 42;						
					LET sBandera = 1;
					--SE REGISTRA QUE SE ENCONTRO CLIENTE CON CAUSA CQB
					LET iContadorRegistros = iContadorRegistros + 1;					
				END IF;					
			END IF;
			
			--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
			IF iContadorRegistros = 1 AND sEnTransaccion = 0 THEN
				BEGIN WORK;
				LET sEnTransaccion = 1;
			END IF;
			
			IF sBandera = 1 THEN
				INSERT INTO "informix".se_sitespmasivo (empresa,numcte,situacion,causa, etapa1, etapa2, etapa3, etapa4, etapa5, procesado, fecha) VALUES ('001',cNumCte,cSituacion,sCausa,'1','0','0','0','0','P',CURRENT);
			
				LET cSituacion = '';
				LET sCausa = 0;
				LET sBandera = 0;
			END IF;			
			
			--SE HARA EN BLOQUES DE 1,000 REGISTROS
			IF iContadorRegistros = 1000 THEN
				--SE CIERRA LA TRANSACCION
				COMMIT WORK;	
				--SE REINICIA LA VARIABLE USADA PARA LLEVAR EL CONTROL
				LET iContadorRegistros = 0;
				LET sBandera = 0;
				LET sEnTransaccion = 0;		
			END IF;			
			
		END FOREACH;
		
		--SE OBTIENE LA FECHA Y HORA EXACTA SEL SISTEMA
		LET dtFecha_Hora = '';
	
		SELECT DBINFO('utc_to_datetime', sh_curtime) AS fecha_hora 
		INTO dtFecha_Hora
		FROM sysmaster:"informix".sysshmvals;		
		
		IF iContadorRegistros > 0 THEN
			COMMIT WORK;
		END IF;
		
		--SE DEJA LA BANDERA EN '2' Y SE INDICE QUE LA FECHA Y LA HORA EN QUE TERMINO EL PROESO
		UPDATE "informix".se_bitacoramasiva SET termina_proc = dtFecha_Hora , estatus_proc = '2' WHERE nombre_proceso = 'CQB';
		
		RETURN cCodRet,cMensajeRet;
			
	END;
END PROCEDURE
