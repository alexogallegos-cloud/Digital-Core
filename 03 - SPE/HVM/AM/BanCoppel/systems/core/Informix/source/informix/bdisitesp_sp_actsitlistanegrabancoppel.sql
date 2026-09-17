CREATE PROCEDURE "informix".sp_actsitlistanegrabancoppel()
RETURNING CHAR(6)  AS COD_RET, 
          CHAR(80) AS MENSAJE_RET;
	
	--DECLARACIONES
	DEFINE iSqlErr               INTEGER;
	DEFINE iIsamErr              INTEGER;
	DEFINE cErrorInfo            CHAR(80);
	DEFINE cCodRet               CHAR(6);
	DEFINE cMensajeRet           CHAR(80);
	-----VARIABLES PARA DATOS LISTA_INTERNA
	DEFINE cNumCte               CHAR(20);
	DEFINE cNombre1              CHAR(26);
	DEFINE cNombre2              CHAR(26);
	DEFINE cApell_pat            CHAR(26);
	DEFINE cApell_mat            CHAR(26);
	DEFINE dtFechaNac            DATE;
	-----VARIABLES PARA DATOS BDINTEG
	DEFINE cNombreuno_bdinteg    CHAR(26);
	DEFINE cNombredos_bdinteg    CHAR(26);
	DEFINE cApellmat_bdinteg     CHAR(26);
	DEFINE cApellpat_bdinteg     CHAR(26);
	DEFINE dtFechanac_bdinteg    DATE;
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	DEFINE iContadorRegistros    INTEGER;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	DEFINE dtFecha_Hora          DATETIME YEAR TO SECOND;
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	DEFINE cProcesoEjecutandose  CHAR(3);
	DEFINE cBorraAmbasFechas     CHAR(1);
	DEFINE cSituacion	        CHAR(1);
	DEFINE sCausa	     		SMALLINT;
	DEFINE sBandera	     		SMALLINT;
	DEFINE sEntro               SMALLINT;
	

	
	--INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'PROCESO EXITOSO';
	-----VARIABLES PARA DATOS LISTA_INTERNA
	LET cNumCte                  = '';
	LET cNombre1                 = '';
	LET cNombre2                 = '';
	LET cApell_pat               = '';
	LET cApell_mat               = '';
	LET dtFechaNac               = DATE(1);
	-----VARIABLES PARA DATOS BDINTEG
	LET cNombreuno_bdinteg       = '';
	LET cNombredos_bdinteg       = '';
	LET cApellmat_bdinteg        = '';
	LET cApellpat_bdinteg        = '';
	LET dtFechanac_bdinteg       = DATE(1);
	-----VARIABLE PARA CONTROL DE BLOQUES DE TRANSACCION
	LET iContadorRegistros       = 0;
	----VARIABLE PARA INSERTAR LA FECHA Y LA HORA EN QUE INICIA LA EJECUCION DEL SP
	LET dtFecha_Hora             = DATE(1);
	----VARIABLE PARA CONTROLAR LA EJECUCION DEL PROCESO
	LET cProcesoEjecutandose     = '';
	LET cBorraAmbasFechas        = '';
	LET cSituacion		     = '';
	LET sCausa				 = 0;
	LET sBandera			 = 0;
	LET sEntro             = 0;
	
		--SET DEBUG FILE TO '/dbexportb/carlos/asignacion/listaprieta.out';
		--TRACE ON;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr <> 0 THEN
				UPDATE "informix".se_bitacoramasiva SET estatus_proc = '0' WHERE nombre_proceso = 'LNB';
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
		WHERE nombre_proceso = 'LNB';
		
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
				UPDATE "informix".se_bitacoramasiva  SET inicia_proc = NULL, termina_proc = NULL WHERE nombre_proceso = 'LNB';
			
				UPDATE "informix".se_bitacoramasiva SET inicia_proc = dtFecha_Hora  WHERE nombre_proceso = 'LNB';
			END IF;
			
			UPDATE "informix".se_bitacoramasiva SET estatus_proc = '1' WHERE nombre_proceso = 'LNB';
				
		END IF;	
		
	FOREACH WITH HOLD
		--create index "informix".idx_si_cliente2 on "informix".si_cliente (apell_paterno,apell_materno) using btree ;
		
			--SE HACE UN BARRIDO A LA LISTA NEGRA BANCOPPEL DE LOS CLIENTES QUE NO HAN SIDO PROCESADOS COMO LISTA NEGRA. EL NVL ES POR SI LA FECHA_NAC ESTA NULA O VACIA UNIFICARLA COMO SOLAMENTA VACIA
			SELECT {+INDEX(bdiauditor:"informix".tbl_listainterna idx_lista_negra)} NVL(lis.numcte,'') AS numcte, NVL(lis.nombre1,''), NVL(lis.nombre2,''), NVL(lis.apell_paterno,''), NVL(lis.apell_materno,''), NVL(lis.fecha_nac,'') AS fecha_nac
			INTO cNumCte, cNombre1, cNombre2, cApell_pat, cApell_mat, dtFechaNac
			FROM bdiauditor:"informix".tbl_listainterna  lis
			LEFT OUTER JOIN "informix".se_sitespmasivo sit ON(sit.empresa = '001' AND sit.numcte = lis.numcte AND sit.fecha = sit.fecha AND sit.etapa2 = '1' )
			LEFT OUTER JOIN bdinteg:"informix".si_cliente cli ON(cli.empresa = '001' AND cli.numcte = lis.numcte)
			WHERE lis.rfc = lis.rfc 
			AND NVL(lis.numcte,'') = NVL(lis.numcte,'')
			AND sit.numcte IS NULL
			ORDER BY lis.numcte DESC
			
			--SI EL NUMERO DE CLIENTE ESTA CAPTURADO, NO ESTA PROCESADO, Y EXISTE EN LA SI_CLIENTE
			IF cNumCte <> '' THEN
				LET cSituacion = 'U';
				LET sCausa = 60;
				LET sBandera = 1;
				--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
				LET iContadorRegistros = iContadorRegistros + 1;
				
			--SI NO TIENE NUMERO DE CLIENTE ASIGNADO PERO SI APELLIDOS
			ELIF cNumCte = '' AND cApell_pat <> '' AND cApell_mat <> '' THEN
				FOREACH
						SELECT cli.numcte,NVL(cli.nombre1,''), NVL(cli.nombre2,''), NVL(cli.apell_paterno,'') , NVL(cli.apell_materno,'') , NVL(pf.fecha_nac,'')
						INTO cNumCte, cNombreuno_bdinteg , cNombredos_bdinteg, cApellpat_bdinteg, cApellmat_bdinteg, dtFechanac_bdinteg
						FROM bdinteg:"informix".si_ctepf pf
						INNER JOIN bdinteg:"informix".si_cliente cli ON (cli.apell_paterno = TRIM(cApell_pat) AND cli.apell_materno = TRIM(cApell_mat) AND cli.nombre1= TRIM(cNombre1) AND cli.nombre2 = TRIM(cNombre2) AND cli.tpo_persona = '01' AND cli.tipo_cliente = '1')
						WHERE pf.no_imss = pf.no_imss 
						AND pf.numcte = cli.numcte
						
							--SE COMPARA Y SI COINCIDEN al 100% NOMBRE Y FECHA DE NACIMIENTO O SOLO NOMBRES SE INSERTA EN LA SE_SITESPMASIVO, ESTO SOLO SI LA FECHA DE NACIMIENTO EN LISTA NEGRA ESTABA NULA/VACIA.
							IF (TRIM(cNombre1) = TRIM(cNombreuno_bdinteg) AND TRIM(cNombre2) = TRIM(cNombredos_bdinteg) AND TRIM(cApell_pat) = TRIM(cApellpat_bdinteg) AND TRIM(cApell_mat) = TRIM(cApellmat_bdinteg) AND dtFechaNac = dtFechanac_bdinteg) OR (TRIM(cNombre1) = TRIM(cNombreuno_bdinteg) AND TRIM(cNombre2) = TRIM(cNombredos_bdinteg) AND TRIM(cApell_pat) = TRIM(cApellpat_bdinteg) AND TRIM(cApell_mat) = TRIM(cApellmat_bdinteg) AND NVL(dtFechaNac,'') = '') THEN

								LET cSituacion = 'U';
								LET sCausa = 60;
								LET sBandera = 1;
								--SI SE HIZO LA INSERCION SE REGISTRA QUE SE LLEVO A CABO UNA ACCION
								LET iContadorRegistros = iContadorRegistros + 1;

								EXIT FOREACH;
							ELSE	
								--SI NO TIENE NO DE CLIENTE, NI APELLIDOS SE DESCARTA
								CONTINUE FOREACH;
							END IF;
				END FOREACH;
			ELSE
				--SI NO TIENE NO DE CLIENTE, NI APELLIDOS SE DESCARTA
				CONTINUE FOREACH;
			
			END IF;
			
			--SI EL CONTADOR ESTA EN 1 QUIERE DECIR QUE ES LA PRIMERA TRANSACCION POR LO CUAL SE ABRE EL BEGIN
			IF iContadorRegistros = 1 AND sEntro = 0 THEN
				BEGIN WORK;
				LET sEntro = 1;
			END IF;
			
			IF sBandera > 0 THEN
				INSERT INTO "informix".se_sitespmasivo (empresa,numcte,situacion,causa, etapa1, etapa2, etapa3, etapa4, etapa5, procesado, fecha) VALUES ('001',cNumCte,cSituacion,sCausa,'0','1','0','0','0','P',CURRENT);
			
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
		UPDATE "informix".se_bitacoramasiva SET termina_proc = dtFecha_Hora , estatus_proc = '2' WHERE nombre_proceso = 'LNB';
		
		IF iContadorRegistros > 0 THEN
			COMMIT WORK;
		END IF;
		
		 RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
