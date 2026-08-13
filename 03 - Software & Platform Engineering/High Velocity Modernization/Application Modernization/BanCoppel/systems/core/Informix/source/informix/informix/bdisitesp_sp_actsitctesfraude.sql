CREATE PROCEDURE "informix".sp_actsitctesfraude()
RETURNING CHAR(6)  AS COD_RET, 
          CHAR(80) AS MENSAJE_RET;
	
	--DECLARACIONES
	DEFINE iSqlErr                INTEGER;
	DEFINE iIsamErr               INTEGER;
	DEFINE cErrorInfo             CHAR(80);
	DEFINE cCodRet                CHAR(6);
	DEFINE cMensajeRet            CHAR(80);
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	DEFINE iContadorRegistros     INTEGER;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	DEFINE dtFecha_Hora           DATETIME YEAR TO SECOND;
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	DEFINE cProcesoEjecutandose   CHAR(3);
	DEFINE cBorraAmbasFechas      CHAR(1);
	DEFINE cNumCte                CHAR(20);
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
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	LET iContadorRegistros        = 0;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	LET dtFecha_Hora              = DATE(1);
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	LET cProcesoEjecutandose      = '';
	LET cBorraAmbasFechas         = '';
	LET cNumCte                   = '';
	LET cSituacion		     = '';
	LET sCausa				 = 0;
	LET sBandera			 = 0;
	LET sEntro             = 0;
	
			--SET DEBUG FILE TO '/dbexportb/carlos/asignacion/fraude.out';
			--TRACE ON;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr <> 0 THEN
				UPDATE "informix".se_bitacoramasiva SET estatus_proc = '0' WHERE nombre_proceso = 'CFB';
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
		
		--SE VERIFICA QUE EL SP NO ESTE EN EJECUCION
		SELECT CASE WHEN estatus_proc = '1' THEN '1' ELSE '0' END, CASE WHEN (inicia_proc IS NULL AND termina_proc IS NULL)OR(inicia_proc IS NOT NULL AND termina_proc IS NOT NULL)THEN '1' ELSE '0' END
		INTO cProcesoEjecutandose, cBorraAmbasFechas
		FROM "informix".se_bitacoramasiva 
		WHERE nombre_proceso = 'CFB';
		
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
				UPDATE "informix".se_bitacoramasiva  SET inicia_proc = NULL, termina_proc = NULL WHERE nombre_proceso = 'CFB';
			
				UPDATE "informix".se_bitacoramasiva SET inicia_proc = dtFecha_Hora  WHERE nombre_proceso = 'CFB';
			END IF;
			
			UPDATE "informix".se_bitacoramasiva SET estatus_proc = '1' WHERE nombre_proceso = 'CFB';
			
			
		END IF;	
	
	FOREACH WITH HOLD
		--SE BARRE LA LISTA_FRAUDE Y SE SELECCIONAN LOS CLIENTES QUE NO HAN SIDO PROCESADOS CON CAUSA Y SITUACION EN LA SE_SITESPMASIVO
		SELECT {+INDEX(bdisitesp:"informix".se_listafraude idx_ctefolio)} fra.numcte
		INTO cNumCte
		FROM "informix".se_listafraude fra
		LEFT OUTER JOIN "informix".se_sitespmasivo sit ON(sit.empresa = '001' AND sit.numcte = fra.numcte AND sit.fecha = sit.fecha AND sit.etapa4 = '1' )
		WHERE fra.numcte = fra.numcte
		AND fra.folio = fra.folio
		AND sit.numcte IS NULL
		
		LET cSituacion = 'P';
		LET sCausa = 108;
		LET sBandera = 1;
		
		--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
		LET iContadorRegistros = iContadorRegistros + 1;
		
	
		--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
			IF iContadorRegistros = 1 AND sEntro = 0 THEN
				BEGIN WORK;
				LET sEntro = 1;
			END IF;
			
			IF sBandera > 0 THEN
				INSERT INTO "informix".se_sitespmasivo (empresa,numcte,situacion,causa, etapa1, etapa2, etapa3, etapa4, etapa5, procesado, fecha) VALUES ('001',cNumCte,cSituacion,sCausa,'0','0','0','1','0','P',CURRENT);
			
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
				LET sEntro = 0;		
			END IF;			
	
	END FOREACH;

		
		--SE OBTIENE LA FECHA Y HORA EXACTA SEL SISTEMA
		LET dtFecha_Hora = '';
	
		SELECT DBINFO('utc_to_datetime', sh_curtime) AS fecha_hora 
		INTO dtFecha_Hora
		FROM sysmaster:"informix".sysshmvals;
		
		--SE DEJA LA BANDERA EN '2' Y SE INDICE QUE LA FECHA Y LA HORA EN QUE TERMINO EL PROESO
		UPDATE "informix".se_bitacoramasiva SET termina_proc = dtFecha_Hora , estatus_proc = '2' WHERE nombre_proceso = 'CFB';
		
			IF iContadorRegistros > 0 THEN
				COMMIT WORK;
			END IF;
			
			RETURN cCodRet,cMensajeRet;
	END;
END PROCEDURE
