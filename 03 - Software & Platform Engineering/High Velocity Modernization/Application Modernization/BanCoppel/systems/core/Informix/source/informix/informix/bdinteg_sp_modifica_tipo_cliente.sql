CREATE PROCEDURE "informix".sp_modifica_tipo_cliente()
RETURNING CHAR(6);
	DEFINE cCodRet			CHAR(6);
	DEFINE i_SqlError		INTEGER;
	DEFINE i_iSamError		INTEGER;
	DEFINE vnumcte			CHAR (20);
	DEFINE iTrans_abierta	INTEGER;
	DEFINE iTotalReg		INTEGER;
	DEFINE iProcesados		INTEGER;
	DEFINE MAXTRANSACCION	INTEGER;
	
	LET MAXTRANSACCION = 500;
	LET vnumcte = '';
	LET cCodRet = '000000';
	LET iProcesados = 0;
	LET iTotalReg= 0;
	LET iTrans_abierta= 0;
	
	--SET DEBUG FILE TO "/informix/rmarquez/sp_modifica_tipo_cliente.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET i_SqlError,i_iSamError
			IF i_SqlError <> 0 THEN	
			
				IF iTrans_abierta = 1 THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = i_SqlError;
				
				IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpctes_tipoincorrecto') THEN
					DROP TABLE tmpctes_tipoincorrecto;
				END IF;
				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
						
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpctes_tipoincorrecto') THEN
			DROP TABLE tmpctes_tipoincorrecto;
		END IF;
		
		--Forma la tabla temporal con todos los clientes incorrectos.		
		SELECT DISTINCT a.numcte FROM bdinteg:si_cliente a,
		TABLE(MULTISET(SELECT DISTINCT num_cte AS numcte FROM bdicheq:sc_maechq
               UNION ALL
               SELECT DISTINCT numcte AS numcte FROM bdicred:sd_maecred)) b,
		TABLE(MULTISET(SELECT cliente AS numcte FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cod_docto IN (SELECT cod_docto FROM bdidigital@coppelimg_tcp:dg_tipodocumento
                                     WHERE cod_grupo = '001')))c
		WHERE a.tipo_cliente = '2'
		AND a.numcte = b.numcte
		AND b.numcte = c.numcte
		INTO TEMP tmpctes_tipoincorrecto WITH NO LOG;
										   		
		--Cuenta los registros de la tabla temporal
		SELECT COUNT(*) 
		INTO iTotalReg 
		FROM tmpctes_tipoincorrecto;		
						
		IF iTotalReg > 0 THEN		
			FOREACH WITH HOLD
				SELECT numcte 
				INTO vnumcte
				FROM tmpctes_tipoincorrecto
				
				IF iProcesados = 0 THEN
					BEGIN WORK;
					LET iTrans_abierta = 1;
				END IF;				
				
				UPDATE "informix".si_cliente SET tipo_cliente = '1' WHERE numcte= vnumcte;
								
				LET iProcesados = iProcesados + 1;
				
				IF iProcesados >= MAXTRANSACCION THEN
					COMMIT WORK;
					LET iProcesados = 0;					
					LET iTrans_abierta = 0;
				END IF;
			END FOREACH;
			
			IF iProcesados < MAXTRANSACCION AND  iTrans_abierta = 1 THEN
				IF iProcesados > 0 THEN
					COMMIT WORK;
					LET iProcesados = 0;
					LET iTrans_abierta = 0;
				END IF;				
			END IF;
		ELSE
			LET cCodRet = '000001';
		END IF;
				
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpctes_tipoincorrecto') THEN
			DROP TABLE tmpctes_tipoincorrecto;
		END IF;	
		
		RETURN cCodRet;
	END;
END PROCEDURE;