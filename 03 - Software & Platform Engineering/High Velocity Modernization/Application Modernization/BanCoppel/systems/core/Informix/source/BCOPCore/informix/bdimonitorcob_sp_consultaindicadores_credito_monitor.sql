CREATE PROCEDURE "informix".sp_consultaindicadores_credito_monitor(pEmpresa CHAR(3),pNum_credito CHAR(20))
RETURNING CHAR(6),CHAR(211)
	--02-07-2013
	--Realizo: Jose Ruben Lopez
	--Se trae los indicadores nuevos para agregar al reporte 
	--Solicito:Jorge Nuñez
	--execute PROCEDURE "informix".sp_consultaindicadores_credito_monitor('001','630005240381'); '630031333267'
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(6);
DEFINE cTrama             CHAR(211);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE dtFecha            DATE;
DEFINE cMorosidad         MONEY(16,2);
DEFINE iDiaActual         INT;
DEFINE iMesActual         INT;
DEFINE iAnioActual        INT;
DEFINE dtfechaTemporal    DATE; --DSB20150623
DEFINE iMonto			  MONEY(16,2);
LET cCod_Ret = '00000';
LET cTrama='';
LET dtFecha='';
LET iMonto=0;
LET iDiaActual = DAY(current);
LET iMesActual = MONTH(current);
LET iAnioActual= YEAR(current)-2; -- se obtiene el año desde cuando se hara la consulta qe son dos años antes del actual
LET dtfechaTemporal= '01/01/' || to_char(iAnioActual); --DSB20150623

--SET DEBUG FILE TO "/tmp/sp_consultaindicadores_credito_monitor.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret,cTrama;
    END EXCEPTION;
	ON EXCEPTION IN(-958) -- si la tabla temporal ya existe la borra
		DROP TABLE tTempInd;
		CREATE TEMP TABLE tTempInd(
							anio 			CHAR(4),
							id_concepto 	CHAR(3),
							ene				money(16,2),
							feb 	    	money(16,2), 
							mar				money(16,2),
							abr 			money(16,2),
							may 			money(16,2),
							jun				money(16,2),
							jul				money(16,2),
							ago				money(16,2),
							sep				money(16,2),
							octu			money(16,2),
							nov				money(16,2),
							dic 			money(16,2)
							)WITH NO LOG;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNum_credito ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		LET cTrama='Error Parametros en blanco';
		RETURN cCod_Ret,cTrama;
	END IF;
	
	IF pEmpresa ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		LET cTrama='Error Parametros en blanco';
		RETURN cCod_Ret,cTrama;
	END IF
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tTempInd' ) THEN
        DROP TABLE tTempInd;
	END IF;
	
	CREATE TEMP TABLE tTempInd(
							anio 			CHAR(4),
							id_concepto 	CHAR(3),
							ene				money(16,2),
							feb 	    	money(16,2), 
							mar				money(16,2),
							abr 			money(16,2),
							may 			money(16,2),
							jun				money(16,2),
							jul				money(16,2),
							ago				money(16,2),
							sep				money(16,2),
							octu			money(16,2),
							nov				money(16,2),
							dic 			money(16,2)
							)WITH NO LOG;
   
	FOREACH-- RETORNA LA MOROSIDAD DEL CLIENTE
			--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movhis)} fecha ,SUM(mto_fin_ven_trasp)
            SELECT fecha ,SUM(mto_fin_ven_trasp) --DSB20150623			
			INTO dtFecha,cMorosidad
			FROM bdicred:"informix".sd_maesdoshist 
			--WHERE num_credito=pNum_credito AND empresa=pEmpresa AND /*YEAR(fecha)>=iAnioActual*/ fecha >= dtfechaTemporal  
			WHERE /*YEAR(fecha)>=iAnioActual*/ fecha >= dtfechaTemporal AND empresa=pEmpresa AND num_credito=pNum_credito --DSB20150623
			GROUP BY fecha
			ORDER BY fecha desc
			
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='250') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),250,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,cMorosidad,'250','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
				     Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,cMorosidad,'250','20','revo')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			
			END IF;	
	END FOREACH;
	LET dtFecha='';
	FOREACH	--RETORNA MONTO DE RETIRO DE ATM
			SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT monto,ma.fecha_mov,monto2,md.fecha_mov FROM
				TABLE(MULTISET(SELECT SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('30','40','41','42') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002'AND codigo_ref IN('30','40','41','42') AND /*YEAR(fecha_mov)>=iAnioActual*/ fecha_mov >= dtfechaTemporal AND reversado='N'  GROUP BY fecha_mov )) AS ma  --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  SUM(monto) as monto2, fecha_mov FROM bdicred:"informix".sd_movdia 
				TABLE(MULTISET(SELECT SUM(monto) as monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('30','40','41','42') AND YEAR(fecha_mov)>=iAnioActual GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref IN('30','40','41','42') AND codigo_fun='002' AND  reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			
			
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='260') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),260,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'260','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'260','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;		
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH --RETORNA NUMERO DE RETIROS DE ATM DEL CLIENTE
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov FROM
				table(MULTISET(SELECT count(num_credito) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('30','40','41','42') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002' AND codigo_ref IN('30','40','41','42') AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado='N' GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  count(num_credito) as monto2, fecha_mov FROM bdicred:"informix".sd_movdia 
				TABLE(MULTISET(SELECT count(num_credito) as monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('30','40','41','42') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref IN('30','40','41','42') AND codigo_fun='002' AND reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='270') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),270,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'270','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'270','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;		
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH--RETORNA  MONTO RETIROS EN VENTANILLAS BANCOPPEL
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				TABLE(MULTISET(SELECT SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002'AND codigo_ref IN('50','60','66') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002'AND codigo_ref IN('50','60','66') AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia
                TABLE(MULTISET(SELECT SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002'AND codigo_ref IN('50','60','66') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md 
				WHERE num_credito=pNum_credito AND codigo_ref IN('50','60','66') AND  codigo_fun='002' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='280') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),280,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'280','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'280','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;		
		
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH--RETORNA EL NUMERO DE RETIROS EN VENTANILLA
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				table(MULTISET(SELECT COUNT(num_credito) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('50','60','66') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun='002' AND codigo_ref IN('50','60','66') AND  /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado='N' GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  COUNT(num_credito)as monto2, fecha_mov FROM bdicred:"informix".sd_movdia
                TABLE(MULTISET(SELECT COUNT(num_credito)as monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623 				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun='002'AND codigo_ref IN('50','60','66') AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE  num_credito=pNum_credito AND codigo_ref IN('50','60','66') AND codigo_fun='002' AND reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='290') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),290,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'290','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'290','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;		
	
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH--RETORNA LOS PAGOS REALIZADOS EN VENTANILLA
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				TABLE(MULTISET(SELECT SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('052','033','335') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun IN('052','033','335') AND codigo_ref='1' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado='N' GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia 
                TABLE(MULTISET(SELECT SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623 				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('052','033','335') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref='1' AND codigo_fun IN('052','033','335') AND reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='300') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),300,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'300','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'300','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;		
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH--RETORNA MONTO PAGOS INTERBANCARIOS
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				table(MULTISET(SELECT SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('334') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun IN('334') AND codigo_ref='1' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado='N' GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}   SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia
                TABLE(MULTISET(SELECT SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('334') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref='1' AND codigo_fun IN('334') AND reversado='N' AND  /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa GROUP BY fecha_mov )) AS md --DSB20150623
				
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='310') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),310,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'310','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'310','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;	
	
	END FOREACH;
		LET dtFecha='';
		LET iMonto=0;
	FOREACH--RETORNA EL MONTO DE PAGOS EN EL PORTAL WEB
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				TABLE(MULTISET(SELECT  SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('337') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun IN('337') AND codigo_ref='1' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado = 'N'  GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}   SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia
                TABLE(MULTISET(SELECT SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('337') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref='1' AND codigo_fun IN('337') AND reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa  GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='320') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),320,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'320','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'320','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;	
	END FOREACH;
	
	LET dtFecha='';
	LET iMonto=0;
	
	FOREACH--RETORNA EL MONTO REALIZADO POR CORRESPONSALES BANCOPPEL
		SELECT NVL(fecha_mov,fecha_mov_1),(NVL(monto,'0') + NVL(monto2,'0')) 
			INTO dtFecha,iMonto 
			FROM
			TABLE(MULTISET(
				SELECT  monto,ma.fecha_mov,monto2,md.fecha_mov  FROM
				TABLE(MULTISET(SELECT SUM(monto) AS monto, fecha_mov FROM bdicred:"informix".sd_movhis --DSB20150623 
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('700') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS ma
				WHERE empresa=pEmpresa AND num_credito=pNum_credito AND codigo_fun IN('700') AND codigo_ref='1' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND reversado='N'  GROUP BY fecha_mov )) AS ma --DSB20150623
				FULL OUTER JOIN
				--TABLE(MULTISET(SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".idx_movdia2)}  SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia
                TABLE(MULTISET(SELECT SUM(monto) AS monto2, fecha_mov FROM bdicred:"informix".sd_movdia --DSB20150623				
				--WHERE empresa=pEmpresa AND num_credito=pNum_credito AND reversado='N' AND codigo_fun IN('700') AND codigo_ref='1' AND YEAR(fecha_mov)>=iAnioActual  GROUP BY fecha_mov )) AS md
				WHERE num_credito=pNum_credito AND codigo_ref='1' AND codigo_fun IN('700') AND reversado='N' AND /*YEAR(fecha_mov)>=iAnioActual*/  fecha_mov >= dtfechaTemporal AND empresa=pEmpresa  GROUP BY fecha_mov )) AS md --DSB20150623
				ON ma.fecha_mov = md.fecha_mov

				) 
			) AS vistam ORDER BY fecha_mov DESC
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='330') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),330,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'330','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'330','20','revo')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
					Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			END IF;	
	END FOREACH;
   --RETORNA VALORES
    FOREACH
		 SELECT anio || '|' || id_concepto || '|' || NVL(ene::DECIMAL(16,2),'') || '|' || NVL(feb::DECIMAL(16,2),'') || '|' || NVL(mar::DECIMAL(16,2),'') || '|' || NVL(abr::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(may::DECIMAL(16,2),'') || '|' || NVL(jun::DECIMAL(16,2),'') || '|' || NVL(jul::DECIMAL(16,2),'') || '|' || NVL(ago::DECIMAL(16,2),'') || '|' ||
					                                                 NVL(sep::DECIMAL(16,2),'') || '|' || NVL(octu::DECIMAL(16,2),'') || '|' || NVL(nov::DECIMAL(16,2),'') || '|' || NVL(dic::DECIMAL(16,2),'') || '|'
					    INTO cTrama
                        FROM tTempInd
					    WHERE anio >= iAnioActual
					    ORDER BY id_concepto,anio DESC

        RETURN cCod_Ret,NVL(cTrama,'')WITH RESUME;
    END FOREACH;

    DROP TABLE tTempInd;
   
END;
END PROCEDURE
