CREATE PROCEDURE "informix".sp_fusion_retroactiva_rel_bancoppel_coppel()
RETURNING CHAR(6), CHAR(100);
	DEFINE cCodRet			CHAR(6);
	DEFINE cErrorSQL		CHAR(100);
	DEFINE i_SqlError		INTEGER;
	DEFINE i_iSamError		INTEGER;
	DEFINE vcont			INTEGER;
	
	DEFINE cCliente_tit		CHAR(20);
	DEFINE cCliente_tras	CHAR(20);
	DEFINE vcnumcte_tf		CHAR(20);
	DEFINE cProceso			CHAR(50);
	DEFINE cTabla			CHAR(30);	
	DEFINE cUsuario			CHAR(8);
		
	DEFINE iTrans_abierta	INTEGER;
	DEFINE iTotalReg		INTEGER;
	DEFINE iProcesados		INTEGER;
	DEFINE MAXTRANSACCION	INTEGER;
	
	DEFINE dFecha_fusion	DATE;
	DEFINE vc_detalle_mov  CHAR(200);
	
	DEFINE dtFechaInsercion	DATETIME HOUR TO FRACTION;
	
	LET cCliente_tit = '';
	LET cCliente_tras = '';
	LET cCodRet = '000000';
	LET MAXTRANSACCION = 3000;	
	LET iProcesados = 0;
	LET iTotalReg= 0;
	LET iTrans_abierta= 0;
	LET cProceso = '';
	LET cTabla = '';
	LET cUsuario = '';

	LET cErrorSQL = 'PROCESO TERMINADO SATISFACTORIAMENTE';
	
	--SET DEBUG FILE TO "/informix/josea/64116/sp_fusiona_relaciones_bancoppel_coppel.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET i_SqlError,i_iSamError, cErrorSQL
			IF i_SqlError <> 0 THEN				
				IF iTrans_abierta = 1 THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = i_SqlError;
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				
				LET vc_detalle_mov=i_SqlError||'|'||i_iSamError;
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES (cProceso, cTabla,cCliente_tit,cCliente_tras,vc_detalle_mov,dtFechaInsercion,cUsuario,CURRENT::DATE); 
				
				IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
					DROP TABLE tmpfusionados;
				END IF;	
				
				RETURN cCodRet, cErrorSQL;
			END IF;
		END EXCEPTION;
		
		SELECT DISTINCT a.cliente_tit, a.cliente_tras, a.fecha_fusion, a.usuario
		FROM TABLE(MULTISET(SELECT a.cliente_tit, a.cliente_tras, a.fecha_fusion, a.usuario
							FROM TABLE(MULTISET( SELECT cliente_titular AS cliente_tit, cliente_traspasar AS cliente_tras, fecha_fusion::DATE AS fecha_fusion, TRIM(usuario_sif) AS usuario FROM bdinteg:si_fusbitacora WHERE fusion = 'SI'
												 UNION ALL
												 SELECT cliente_tit, cliente_tras, fecha_fusion, TRIM('infoaut') AS usuario FROM bdinteg:si_fusion_solic WHERE estatus = 1
												 UNION ALL
												 SELECT cliente_tit, cliente_tras, fecha_fusion,TRIM('infoaut') AS usuario FROM bdinteg:si_fusionaut WHERE estatus = 1)) a
							LEFT JOIN TABLE(MULTISET(SELECT cliente_tit, cliente_tras FROM si_desfusionctes WHERE estatus = 1)) b
							ON a.cliente_tit = b.cliente_tit AND a.cliente_tras = b.cliente_tras
							WHERE b.cliente_tit IS NULL)) a, bdinteg:si_relacion_ctebcplcpl b, bdinteg:si_fuscliente c
		WHERE a.cliente_tras = b.numcte_banco
		AND numcte_banco = c.numcte
        INTO TEMP tmpfusionados WITH NO LOG;

		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			SELECT COUNT(cliente_tit) INTO iTotalReg FROM tmpfusionados;
		END IF;	
		
		IF iTotalReg > 0 THEN		
			FOREACH WITH HOLD
				SELECT DISTINCT cliente_tit, cliente_tras, usuario, fecha_fusion
				INTO cCliente_tit, cCliente_tras, cUsuario, dFecha_fusion
				FROM tmpfusionados
				ORDER BY fecha_fusion
												
				IF iProcesados = 0 THEN
					BEGIN WORK;
					LET iTrans_abierta = 1;
				END IF;				
				
				LET cProceso = 'REL CTE BCPL-CPL';
				LET cTabla = 'si_relacion_ctebcplcpl';
				
				IF EXISTS (SELECT 1 FROM bdinteg:si_relacion_ctebcplcpl WHERE empresa = '001' AND numcte_banco = cCliente_tras) THEN
				
					INSERT INTO bdinteg:si_fusrelacion_ctebcplcpl (empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp)
					SELECT empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp
					FROM bdinteg:si_relacion_ctebcplcpl
					WHERE empresa = '001'
					AND numcte_banco = cCliente_tras;
					
					SELECT cliente
					INTO vcnumcte_tf
					FROM bdinteg:si_relacion_ctebcplcpl
					WHERE empresa = '001'
					AND numcte_banco = cCliente_tras;
					
					IF EXISTS (SELECT 1  FROM bdinteg:si_relacion_ctebcplcpl WHERE empresa = '001' AND numcte_banco = cCliente_tit) THEN
						DELETE FROM bdinteg:si_relacion_ctebcplcpl 
						WHERE empresa = '001' 
						AND numcte_banco = cCliente_tras;
					ELSE
						UPDATE bdinteg:si_relacion_ctebcplcpl 
						SET numcte_banco = cCliente_tit
						WHERE empresa = '001' 
						AND numcte_banco = cCliente_tras;
					END IF;
					
					SELECT DBINFO('utc_to_datetime',sh_curtime) 
					INTO dtFechaInsercion 
					FROM sysmaster:"informix".sysshmvals;
					
					LET vc_detalle_mov = TRIM(cCliente_tit)||'|'||TRIM(cCliente_tras)||'|'||TRIM(vcnumcte_tf);
					
					INSERT INTO bdinteg:log_fusionclientes (proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					VALUES (cProceso, cTabla,cCliente_tit,cCliente_tras,vc_detalle_mov,dtFechaInsercion,cUsuario,CURRENT::DATE); 
				END IF;
				--***********************--
				--RELACION CLIENTE BANCOPPEL-COPPEL HISTORICA--
				--***********************--
				LET cProceso = 'REL CTE BCPL-CPL HIST';
				LET cTabla = 'si_relacion_ctebcplcpl_hist';
				
				IF EXISTS (SELECT 1  FROM bdinteg:si_relacion_ctebcplcpl_hist WHERE empresa = '001' AND numcte_banco = cCliente_tras) THEN
					INSERT INTO bdinteg:si_fusrelacion_ctebcplcpl_hist (empresa, numcte_banco, secuencia, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp)
					SELECT empresa, numcte_banco, secuencia, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp
					FROM bdinteg:si_relacion_ctebcplcpl_hist
					WHERE empresa = '001'
					AND numcte_banco = cCliente_tras;				

					SELECT DBINFO('utc_to_datetime',sh_curtime) 
					INTO dtFechaInsercion 
					FROM sysmaster:"informix".sysshmvals;
					
					FOREACH 
						SELECT cliente, secuencia
						INTO vcnumcte_tf, vcont
						FROM bdinteg:si_relacion_ctebcplcpl_hist
						WHERE empresa = '001'
						AND numcte_banco = cCliente_tras
						
						LET vc_detalle_mov = TRIM(cCliente_tit)||'|'||TRIM(cCliente_tras)||'|'||TRIM(vcnumcte_tf)||'|'||vcont;
					
						INSERT INTO bdinteg:log_fusionclientes (proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)				
						VALUES (cProceso, cTabla,cCliente_tit,cCliente_tras,vc_detalle_mov,dtFechaInsercion,cUsuario,CURRENT::DATE); 
					END FOREACH;
					
					IF EXISTS (SELECT 1  FROM bdinteg:si_relacion_ctebcplcpl_hist WHERE empresa = '001' AND numcte_banco = cCliente_tit) THEN
						DELETE FROM bdinteg:si_relacion_ctebcplcpl_hist
						WHERE empresa = '001' 
						AND numcte_banco = cCliente_tras;
					ELSE
						UPDATE bdinteg:si_relacion_ctebcplcpl_hist
						SET numcte_banco = cCliente_tit
						WHERE empresa = '001' 
						AND numcte_banco = cCliente_tras;
					END IF;			
				END IF;
												
				LET iProcesados = iProcesados + 1;
				
				IF iProcesados >= MAXTRANSACCION THEN
					LET iProcesados = 0;
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
			END FOREACH;
			IF iProcesados > 0 THEN
				IF iProcesados < MAXTRANSACCION THEN
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
				LET iProcesados = 0;
			END IF;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			DROP TABLE tmpfusionados;
		END IF;			

		RETURN cCodRet, cErrorSQL;
	END;
END PROCEDURE;