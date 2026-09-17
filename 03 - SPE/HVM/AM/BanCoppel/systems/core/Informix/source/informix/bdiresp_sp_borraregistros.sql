CREATE PROCEDURE "informix".sp_borraregistros(pBaseDatos CHAR(50), pTabla CHAR(80), pCondicion CHAR(100), pNomArchivo CHAR(50))
RETURNING CHAR (5) AS Retorno;
/*
	*****************************************************************************************************
	-- DESCRIPCION: Realiza borrado de registros de tablas dinámicas y actualiza los registros borrados -
	-- AUTOR : Moisés Soriano ---------------------------------------------------------------------------
	-- FECHA : 17/04/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACION: Se eliminan los registros de la tabla temp_resp para optimizar el respaldo. --------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 15/07/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	DEFINE vTotReg 		INT;
	DEFINE vTotRegsql 	CHAR(1000);
	DEFINE vTotRegResp 	CHAR(1000);
	DEFINE vTotReg2 	INT;
	DEFINE vcDel 		CHAR(1000);
	DEFINE vcInsert 	CHAR(1000);
	DEFINE vcCodRet		CHAR(5);
	DEFINE viCodigo		INT;
	DEFINE vcRegComp	CHAR(1000);
	DEFINE vcEnTrans	CHAR(1);
	DEFINE sPaso		SMALLINT;
	DEFINE viCodigo2	INT;
	DEFINE vcDescRet2	CHAR(200);
	DEFINE vRegDel		INT;
	DEFINE iMaxElimina	INTEGER;
	
	
	LET vTotReg 	=  	0;
	LET vTotRegsql 	= 	'';
	LET vTotRegResp = 	'';
	LET vTotReg2	=	0;
	LET vcDel 		=	'';
	LET vcInsert 	=	 '';
	LET vcCodRet	=	'00000';
	LET viCodigo	= 	0;
	LET vcRegComp	=	'';
	LET vcEnTrans	=	'0';
	LET sPaso		=	0;
	LET viCodigo2	=	0;
	LET vcDescRet2	= 	'';
	LET iMaxElimina = 0;
	LET vRegDel		=	0;
	--SET DEBUG FILE TO "/informix/josea/sp_borraregistros.out";
	--TRACE ON;
BEGIN
	ON EXCEPTION SET viCodigo
		IF (viCodigo <>0) THEN
			LET vcCodRet = viCodigo;
			IF(vcEnTrans = '0')THEN
				ROLLBACK WORK;					
				--BEGIN WORK;
			END IF;
			--Para que no termine la transaccion con el rollback y el sp_ejecutarespaldo pueda continuar				
			BEGIN WORK;
			EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO BORRADO DE REGISTROS', TRIM(pNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
			RETURN NVL(vcCodRet,'');				
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET vcEnTrans = '1';
		COMMIT WORK;		 
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	IF EXISTS(SELECT valor FROM bdiresp:rp_parametros WHERE id_param = '005') THEN
		SELECT NVL(valor::INTEGER, 0) 
		INTO iMaxElimina
		FROM bdiresp:rp_parametros
		WHERE id_param = '005';
		
		IF iMaxElimina > 0 THEN 
			EXECUTE PROCEDURE sp_insertaLog(3001, 'INICIA BORRADO DE REGISTROS', TRIM(pNomArchivo) , "Informix", 2, '') 
			INTO viCodigo2, vcDescRet2; 
			
			SELECT COUNT(tabid)
			INTO sPaso
			FROM systables
			WHERE tabname= 'temp_resp';
			
			IF NVL(sPaso,0) > 0 THEN
				DROP TABLE temp_resp;
			END IF;
			
			CREATE TABLE "informix".temp_resp(
				id INTEGER
			 );
			CREATE INDEX idxtempresp1 ON temp_resp(id);
			 
			 --BEGIN WORK;
	 
			LET vTotRegsql = "SELECT COUNT(*) FROM " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " WHERE " || TRIM(pCondicion);
					
			PREPARE xsql FROM vTotRegsql;
			DECLARE xcur CURSOR FOR xsql;
			OPEN xcur;		
			--WHILE 1 = 1
			FETCH xcur INTO vTotReg;
			IF (SQLCODE <> 0) THEN
				EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR EN CONTEO DE REGISTROS', TRIM(pNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
				--EXIT WHILE;
			END IF;
			--END WHILE;
			CLOSE xcur;
			FREE xcur;
			FREE xsql;
			--EXECUTE PROCEDURE sp_insertaLog(3001, 'TOTAL DE REGISTROS BORRADOS: '||vTotReg, TRIM(pNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
			
			--Para la comparacion de vTotReg == vTotReg2
			LET vTotRegResp = "SELECT NVL(registros_respaldados,0) FROM 'informix'.rp_respaldos WHERE TRIM(nombre_archivo) = '"|| TRIM(pNomArchivo)||"'";		
			PREPARE xsql FROM vTotRegResp;
			DECLARE xcur CURSOR FOR xsql;
			OPEN xcur;		
			--WHILE 1 = 1
			FETCH xcur INTO vTotReg2;
			IF (SQLCODE <> 0) THEN
				EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR AL OBTENER REG A RESPALDAR', TRIM(pNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
				--Insertar registro en log
				--EXIT WHILE;
			END IF;
			--END WHILE;
			CLOSE xcur;
			FREE xcur;
			FREE xsql; 

			IF (vTotReg == vTotReg2) THEN		 					
				WHILE (vTotReg>0) 
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
									 
					IF (vcEnTrans ='0')THEN
					COMMIT WORK;
					BEGIN WORK;
					END IF;
					
					LET vcInsert = "INSERT INTO 'informix'.temp_resp(ID) " || "SELECT FIRST " ||iMaxElimina||" ROWID  FROM " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " WHERE " || TRIM(pCondicion);
					EXECUTE IMMEDIATE vcInsert;
							
					--LET vcDel = " DELETE FROM " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " WHERE " || TRIM(pCondicion) || " AND ROWID IN ( SELECT ID FROM temp_resp)";
					LET vcDel = " DELETE FROM " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " WHERE ROWID IN ( SELECT ID FROM temp_resp)";
					--LET vcDel = "MERGE INTO " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " USING temp_resp ON "|| TRIM(pBaseDatos) || ":" || TRIM(pTabla) ||".ROWID = temp_resp.ID WHEN MATCHED THEN DELETE";
								   --MERGE INTO bdinteg:si_cliente USING temp_resp ON bdinteg:si_cliente.ROWID = temp_resp.ID WHEN MATCHED THEN DELETE
					EXECUTE IMMEDIATE vcDel;
						
					--Contador de registros borrados
					LET vRegDel = vRegDel + DBINFO("sqlca.sqlerrd2");		

					TRUNCATE TABLE "informix".temp_resp; 
					LET vTotRegsql = "SELECT COUNT(*) FROM " || TRIM(pBaseDatos) || ":" || TRIM(pTabla) || " WHERE " || TRIM(pCondicion);
					
					PREPARE xsql FROM vTotRegsql;
					DECLARE xcur CURSOR FOR xsql;
					OPEN xcur;		
					--WHILE 1 = 1
					FETCH xcur INTO vTotReg;
					IF (SQLCODE <> 0) THEN
					EXECUTE PROCEDURE sp_insertaLog(3001, 'ERROR EN CONTEO DE REG RESTANTES', TRIM(pNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
					--	EXIT WHILE;
					END IF;
					--END WHILE;
					CLOSE xcur;
					FREE xcur;
					FREE xsql;
					COMMIT WORK;
					BEGIN WORK;
				END WHILE;		  
			END IF;
			
			COMMIT WORK;
			BEGIN WORK;
			
			EXECUTE PROCEDURE sp_insertaLog(3001, 'TOTAL DE REGISTROS BORRADOS: '||vRegDel, TRIM(pNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
					
			UPDATE {+INDEX(bdiresp:rp_respaldos 109_60)} "informix".rp_respaldos SET registros_borrados = vRegDel WHERE TRIM(nombre_archivo) = TRIM(pNomArchivo);
			
			--EXECUTE PROCEDURE sp_insertaLog(3001, 'FINALIZA BORRADO DE REGISTROS', TRIM(pNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
			
			--ACTUALIZA INDICES
			EXECUTE IMMEDIATE "UPDATE STATISTICS MEDIUM FOR TABLE "|| TRIM (pBaseDatos)||":"|| TRIM(pTabla);
						
			DROP TABLE "informix".temp_resp;
			
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(3001, 'FINALIZA BORRADO DE REGISTROS', TRIM(pNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2; 
		ELSE
			LET vcCodRet = '00002'; --Valor del parametro 005 es 0
			EXECUTE PROCEDURE sp_insertaLog(3001, 'VALOR DE PARAMETRO DE MAXIMO DE REGISTROS A DEPURAR ES CERO O NULO', TRIM(pNomArchivo) , USER, 3, '') INTO viCodigo2, vcDescRet2; 
		END IF;
	ELSE
		LET vcCodRet = '00001'; --Parametro 005 NO definido
		EXECUTE PROCEDURE sp_insertaLog(3001, 'PARAMETRO DE MAXIMO DE REGISTROS A DEPURAR NO DEFINIDO', TRIM(pNomArchivo) , USER, 3, '') INTO viCodigo2, vcDescRet2; 
	END IF;
	RETURN vcCodRet;
END;
END PROCEDURE
