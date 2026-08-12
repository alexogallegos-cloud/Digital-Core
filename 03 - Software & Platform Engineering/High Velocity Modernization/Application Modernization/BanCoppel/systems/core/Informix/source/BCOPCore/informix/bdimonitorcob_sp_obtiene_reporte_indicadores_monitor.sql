CREATE PROCEDURE "informix".sp_obtiene_reporte_indicadores_monitor(pEmpresa CHAR(3),pNum_credito CHAR(20),pReporte CHAR(1))
RETURNING CHAR(6),CHAR(211)
	--02-07-2013
	--Realizo: Jose Ruben Lopez
	--Se trae los datos de los nuevos indicadores: Prestamo Personal, Reestructura, Credinomina 
	--Solicito:Jorge Nuñez
	--BD:bdimonitorcob
	-- execute PROCEDURE "informix".sp_obtiene_reporte_indicadores_monitor('001','630031333267','1')
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
DEFINE iMonto			  MONEY(16,2);
DEFINE pIndicador         CHAR(3);
DEFINE diaCorte			  CHAR(2);
DEFINE dtfechaTemporal    DATE; --DSB20150617
--variables para obtener el comportamiento
--------------
LET cCod_Ret = '00000';
LET cTrama='';
LET dtFecha='';
LET pIndicador='';
LET diaCorte='';
LET iMonto=0;
LET iDiaActual = DAY(current);
LET iMesActual = MONTH(current);
LET iAnioActual= YEAR(current)-2; 
LET dtfechaTemporal= '01/01/' || to_char(iAnioActual);
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
							
	--Se obtiene el dia de corte del credito						
	SELECT dia_corte 
	INTO diaCorte
	FROM bdicred:"informix".sd_maecredanexocrd WHERE num_credito=pNum_credito;	
	
	
	IF pReporte=1 THEN	-- REPORTE PRESTAMO PERSONAL	
		FOREACH--COMPORTAMIENTO concepto=230
		
						--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
--						SELECT {+ INDEX (bdicred:"informix".sd_movhiscrd "informix".inx_movcrd)}  fecha_mov,SUM(monto) --DSB20150617
						SELECT fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd
						WHERE empresa = pEmpresa
                        AND fecha_mov >= dtfechaTemporal --DSB20150617					
                        AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
						AND reversado='N'--A.L.L.
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC

/*						WHERE codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND num_credito = pNum_credito
						AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
						AND reversado='N'--A.L.L.
                        AND fecha_mov >= dtfechaTemporal --DSB20150617					
						AND empresa=pEmpresa
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC */
					
					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='230') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),'230','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
								INTO cCod_Ret;

							IF cCod_Ret <>'00000'THEN
								Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
								RETURN cCod_Ret,cTrama;							END IF;
					
					END IF;				
		END FOREACH;
		--SE CALCULA EL COMPORTAMIENTO
			EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_comportamiento_tabla_temporal(iAnioActual,pNum_credito, diaCorte ) 
			INTO cCod_Ret;
				IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_comportamiento_tabla_temporal';
						RETURN cCod_Ret,cTrama;				END IF;
					
		FOREACH-- RETORNA LA MOROSIDAD DEL CLIENTE concepto=250
--			SELECT {+ INDEX (bdicred:"informix".sd_maesdoshistcrd "informix".idx_maedoshicrd1)} fecha , mto_fin_ven_trasp
			SELECT fecha , mto_fin_ven_trasp
			INTO dtFecha,iMonto
			FROM bdicred:"informix".sd_maesdoshistcrd 
			WHERE fecha >= dtfechaTemporal --DSB20150617	
			AND fecha <= TODAY
			AND empresa=pEmpresa 
			AND num_credito=pNum_credito 
			ORDER BY fecha asc

/*			WHERE num_credito=pNum_credito 
			AND empresa=pEmpresa 
			--AND YEAR(fecha)>=iAnioActual
			AND fecha >= dtfechaTemporal --DSB20150617	
			--GROUP BY fecha
			ORDER BY fecha asc*/
			
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='250') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),'250','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250',diaCorte,'plaz')
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
				     Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250',diaCorte,'plaz')
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			
			END IF;	
		END FOREACH;
		FOREACH-- RETORNA SALDOS concepto=370
			--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(pago_total_tc)
			SELECT fecha_emision,SUM(pago_total_tc)
			INTO dtFecha,iMonto
			--FROM bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd --se activa para produccion
			FROM bdicred:"informix".sd_encabezado2_edoctacrd 
			WHERE fecha_emision >= dtfechaTemporal --DSB20150617
			AND fecha_emision <= TODAY
			AND	num_credito=pNum_credito  
			GROUP BY fecha_emision
			ORDER BY fecha_emision DESC

/*			WHERE num_credito=pNum_credito  
			--AND YEAR(fecha_emision)>=iAnioActual
            AND fecha_emision >= dtfechaTemporal --DSB20150617			
			GROUP BY fecha_emision
			ORDER BY fecha_emision DESC*/
			
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='370') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),'370','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370',diaCorte,'plaz')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
				     Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370',diaCorte,'plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			
			END IF;	
		END FOREACH;
		FOREACH-- RETORNA SALDO INSOLUTO 1 concepto=380
			--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(saldo_insoluto)
			SELECT fecha_emision,SUM(saldo_insoluto) --DSB20150617
			INTO dtFecha,iMonto
			--FROM bdicred@pld_tcp:"informix".sd_pie_edoctacrd --se activa para produccion
			FROM bdicred:"informix".sd_pie_edoctacrd 
			WHERE fecha_emision >= dtfechaTemporal --DSB20150617
			AND fecha_emision <= TODAY
			AND num_credito=pNum_credito 
			GROUP BY fecha_emision
			ORDER BY fecha_emision DESC

/*			WHERE num_credito=pNum_credito 
			--AND YEAR(fecha_emision)>=iAnioActual
            AND fecha_emision >= dtfechaTemporal --DSB20150617			
			GROUP BY fecha_emision
			ORDER BY fecha_emision DESC*/
			
			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='380') THEN
				INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
				VALUES(YEAR(dtFecha),'380','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
					INTO cCod_Ret;

				IF cCod_Ret <>'00000'THEN
				     Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
					RETURN cCod_Ret,cTrama;				END IF;
			ELSE
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			
			END IF;	
		END FOREACH;
		
		FOREACH--DISPOSICIONES 1
		    --SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,sum(monto)   
			SELECT fecha_mov,sum(monto) --DSB20150617
			INTO dtFecha,iMonto
			FROM bdicred:"informix".sd_movhiscrd
			WHERE empresa=pEmpresa
            AND fecha_mov >= dtfechaTemporal --DSB20150617				
            AND fecha_mov <= TODAY
			AND num_credito=pNum_credito
			AND codigo_fun='002'
			AND codigo_ref=66
			AND reversado='N'
			GROUP BY fecha_mov

/*			WHERE empresa=pEmpresa
			AND num_credito=pNum_credito
			AND num_producto='6300'
			AND codigo_fun='002'
			AND codigo_ref=66
			AND reversado='N'
			--AND YEAR(fecha_mov)>=iAnioActual
            AND fecha_mov >= dtfechaTemporal --DSB20150617				
			GROUP BY fecha_mov*/


			IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='340') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),340,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			ELSE
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
			END IF;	
		END FOREACH;
		FOREACH --MONTO DE PAGOS EN VENTANILLA				
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
				SELECT fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
                        AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617  						
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC


/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6300'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
                        AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd  WHERE codigo IS NOT NULL) --DSB20150617  						
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC*/

					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='350') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),350,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
			FOREACH --PAGOS
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
				  SELECT fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC


/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6300'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC*/

					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='360') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),360,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
	END IF;
		LET dtFecha='';
		LET iMonto=0;
		
		
	IF pReporte=2 THEN--REPORTE REESTRUCTURA
			FOREACH--COMPORTAMIENTO concepto=230
			
							--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
							SELECT fecha_mov,SUM(monto) --DSB20150617
							INTO dtFecha,iMonto
							FROM bdicred:"informix".sd_movhiscrd 
                            WHERE empresa=pEmpresa
							AND fecha_mov >= dtfechaTemporal --DSB20150617
							AND fecha_mov <= TODAY
							AND num_credito = pNum_credito
							AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617)					
							AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
							AND reversado='N'--A.L.L.
							GROUP BY fecha_mov
							ORDER BY fecha_mov DESC

/*                            WHERE codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617)					
							AND num_credito = pNum_credito
							AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
							AND reversado='N'--A.L.L.
							--AND YEAR(fecha_mov)>=iAnioActual
							AND fecha_mov >= dtfechaTemporal --DSB20150617
							AND empresa=pEmpresa
							GROUP BY fecha_mov
							ORDER BY fecha_mov DESC*/


						
						IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='230') THEN
							INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
							VALUES(YEAR(dtFecha),'230','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
								INTO cCod_Ret;

							IF cCod_Ret <>'00000'THEN
								 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
								RETURN cCod_Ret,cTrama;							END IF;
						ELSE
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
									INTO cCod_Ret;

								IF cCod_Ret <>'00000'THEN
									Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
									RETURN cCod_Ret,cTrama;								END IF;
						
						END IF;				
			END FOREACH;
			--SE CALCULA EL COMPORTAMIENTO
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_comportamiento_tabla_temporal(iAnioActual,pNum_credito, diaCorte) 
				INTO cCod_Ret;
					IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_comportamiento_tabla_temporal';
							RETURN cCod_Ret,cTrama;					END IF;
					
			FOREACH-- RETORNA LA MOROSIDAD DEL CLIENTE concepto=250
--				SELECT {+ INDEX (bdicred:"informix".sd_maesdoshistcrd "informix".idx_maedoshicrd1)} fecha ,mto_fin_ven_trasp
				SELECT fecha ,mto_fin_ven_trasp
				INTO dtFecha,iMonto
				FROM bdicred:"informix".sd_maesdoshistcrd 
				WHERE fecha >= dtfechaTemporal --DSB20150617				
				AND	fecha <= TODAY
				AND empresa=pEmpresa 
				AND num_credito=pNum_credito 
				ORDER BY fecha asc

/*				WHERE num_credito=pNum_credito 
				AND empresa=pEmpresa 
				--AND YEAR(fecha)>=iAnioActual
                AND fecha >= dtfechaTemporal --DSB20150617				
				--GROUP BY fecha
				ORDER BY fecha asc*/


				
				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='250') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),'250','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250',diaCorte,'plaz')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250',diaCorte,'plaz')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			FOREACH-- RETORNA SALDOS 2 concepto=370
				--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(pago_total_tc)
				SELECT fecha_emision,SUM(pago_total_tc)
				INTO dtFecha,iMonto
				--FROM bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd --se activa para produccion
				FROM bdicred:"informix".sd_encabezado2_edoctacrd 
				WHERE fecha_emision >= dtfechaTemporal --DSB20150617				
				AND fecha_emision <= TODAY
                AND num_credito=pNum_credito 
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC

/*				WHERE num_credito=pNum_credito 
				--AND YEAR(fecha_emision)>=iAnioActual
                AND fecha_emision >= dtfechaTemporal --DSB20150617				
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC*/
				
				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='370') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(year(dtFecha),'370','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370',diaCorte,'plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			FOREACH-- RETORNA SALDO INSOLUTO 2 concepto=380
				--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(saldo_insoluto)
				SELECT fecha_emision,SUM(saldo_insoluto) --DSB20150617
				INTO dtFecha,iMonto
				--FROM bdicred@pld_tcp:"informix".sd_pie_edoctacrd --se activa para produccion
				FROM bdicred:"informix".sd_pie_edoctacrd 
				WHERE fecha_emision >= dtfechaTemporal --DSB20150617				
				AND fecha_emision <= TODAY
				AND num_credito=pNum_credito 
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC
				

/*				WHERE num_credito=pNum_credito 
				--AND YEAR(fecha_emision)>=iAnioActual
                AND fecha_emision >= dtfechaTemporal --DSB20150617				
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC*/

				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='380') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),'380','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			FOREACH--DISPOSICIONES 2
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)}  fecha_mov,sum(monto)
				SELECT fecha_mov,sum(monto) --DSB20150617
					INTO dtFecha,iMonto
					FROM bdicred:"informix".sd_movhiscrd
					WHERE empresa=pEmpresa
					AND fecha_mov >= dtfechaTemporal --DSB20150617
					AND fecha_mov <= TODAY
					AND num_credito=pNum_credito
					AND codigo_fun='002'
					AND codigo_ref='1'
					AND reversado='N'
					GROUP BY fecha_mov

/*					WHERE empresa=pEmpresa
					AND num_credito=pNum_credito
					AND num_producto='6011'
					AND codigo_fun='002'
					AND codigo_ref='1'
					AND reversado='N'
					--AND YEAR(fecha_mov)>=iAnioActual
					AND fecha_mov >= dtfechaTemporal --DSB20150617
					GROUP BY fecha_mov*/


					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='340') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),340,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
			
			FOREACH	--MONTO PAGOS EN VENTANILLA		
					--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
					SELECT fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC


/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6011'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC*/


					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='350') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),350,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
			FOREACH	--PAGOS		
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
				SELECT  fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	

/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6011'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	*/



					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='360') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),360,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
	END IF;
	
	IF pReporte=3 THEN--REPORTE CREDINOMINA
				FOREACH--COMPORTAMIENTO concepto=230
							--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
							SELECT fecha_mov,SUM(monto) --DSB20150617
							INTO dtFecha,iMonto
							FROM bdicred:"informix".sd_movhiscrd 
                            WHERE empresa=pEmpresa
							AND fecha_mov >= dtfechaTemporal --DSB20150617
							AND fecha_mov <= TODAY
							AND num_credito = pNum_credito
                            AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617					
							AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
							AND reversado='N'--A.L.L.
							GROUP BY fecha_mov
							ORDER BY fecha_mov DESC
						

/*                            WHERE codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617					
							AND num_credito = pNum_credito
							AND codigo_ref='1'--A.L.L.Se le meten los siguientes 2 filtros
							AND reversado='N'--A.L.L.
							--AND YEAR(fecha_mov)>=iAnioActual
							AND fecha_mov >= dtfechaTemporal --DSB20150617
							AND empresa=pEmpresa
							GROUP BY fecha_mov
							ORDER BY fecha_mov DESC */


						IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='230') THEN
							INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
							VALUES(YEAR(dtFecha),'230','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
								INTO cCod_Ret;

							IF cCod_Ret <>'00000'THEN
								 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
								RETURN cCod_Ret,cTrama;							END IF;
						ELSE
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'230',diaCorte,'plaz')
									INTO cCod_Ret;

								IF cCod_Ret <>'00000'THEN
									Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
									RETURN cCod_Ret,cTrama;								END IF;
						
						END IF;				
			END FOREACH;
			--SE CALCULA EL COMPORTAMIENTO
				EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_comportamiento_tabla_temporal(iAnioActual,pNum_credito, '15'/*diaCorte*/) 
				INTO cCod_Ret;
					IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_comportamiento_tabla_temporal';
							RETURN cCod_Ret,cTrama;					END IF;
					
			FOREACH-- RETORNA LA MOROSIDAD DEL CLIENTE concepto=250
--				SELECT {+ INDEX (bdicred:"informix".sd_maesdoshistcrd "informix".idx_maedoshicrd1)} fecha , mto_fin_ven_trasp
				SELECT fecha , mto_fin_ven_trasp
				INTO dtFecha,iMonto
				FROM bdicred:"informix".sd_maesdoshistcrd 
				WHERE fecha >= dtfechaTemporal --DSB20150617				
				AND fecha <= TODAY
				AND empresa=pEmpresa 
				AND num_credito=pNum_credito 
				ORDER BY fecha asc

/*				WHERE num_credito=pNum_credito 
				AND empresa=pEmpresa 
				--AND YEAR(fecha)>=iAnioActual
                AND fecha >= dtfechaTemporal --DSB20150617				
				--GROUP BY fecha
				ORDER BY fecha asc */

				
				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='250') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),'250','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250','15'/*diaCorte*/,'plaz')
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_morosidad_credinomina_tabtemp (dtFecha ,iMonto,'250','15','plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'250','15'/*diaCorte*/,'plaz')
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '250')
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_morosidad_credinomina_tabtemp (dtFecha ,iMonto,'250','15','plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			
			FOREACH-- RETORNA SALDOS 3 concepto=370
				
				--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(pago_total_tc)
				SELECT  fecha_emision,SUM(pago_total_tc)
				INTO dtFecha,iMonto
				--FROM bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd --se activa para produccion
				FROM bdicred:"informix".sd_encabezado2_edoctacrd 
				WHERE fecha_emision >= dtfechaTemporal --DSB20150617				
				AND fecha_emision <= TODAY
                AND num_credito=pNum_credito
				AND DAY(fecha_emision) = '15' --diaCorte
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC
					
/*				WHERE num_credito=pNum_credito
				AND DAY(fecha_emision) = '15' --diaCorte
				--AND YEAR(fecha_emision)>=iAnioActual
                AND fecha_emision >= dtfechaTemporal --DSB20150617				
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC */



				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='370') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),'370','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370','15'/*diaCorte*/,'plaz')					
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '370')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'370','15'/*diaCorte*/,'plaz')
					--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '370')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			--Se calcula el saldo para credinomina quincenal.
			EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_saldos_credinomq_tablatemp(iAnioActual ,pNum_credito)
			
			INTO cCod_Ret;
					IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_saldos_credinomq_tablatemp';
							RETURN cCod_Ret,cTrama;					END IF;
			FOREACH-- RETORNA SALDO INSOLUTO 3 concepto=380
				--SELECT {+ INDEX (bdicred@pld_tcp:"informix".sd_encabezado2_edoctacrd "informix".id_encabezado2_fecha_credito)} fecha_emision,SUM(saldo_insoluto)
				SELECT fecha_emision,SUM(saldo_insoluto) --DSB20150617
				INTO dtFecha,iMonto
				--FROM bdicred@pld_tcp:"informix".sd_pie_edoctacrd --se activa para produccion
				FROM bdicred:"informix".sd_pie_edoctacrd
				WHERE fecha_emision >= dtfechaTemporal --DSB20150617				
				AND fecha_emision <= TODAY
				AND num_credito=pNum_credito
				AND DAY(fecha_emision) = '15'--diaCorte
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC
				

/*				WHERE num_credito=pNum_credito
				AND DAY(fecha_emision) = '15'--diaCorte
				--AND YEAR(fecha_emision)>=iAnioActual
                AND fecha_emision >= dtfechaTemporal --DSB20150617				
				GROUP BY fecha_emision
				ORDER BY fecha_emision DESC */


				IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='380') THEN
					INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
					VALUES(YEAR(dtFecha),'380','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
						INTO cCod_Ret;

					IF cCod_Ret <>'00000'THEN
						 Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
						RETURN cCod_Ret,cTrama;					END IF;
				ELSE
					EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'380',diaCorte,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
				
				END IF;	
			END FOREACH;
			FOREACH--PAGOS			
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
				SELECT  fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	

/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6400'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	*/



					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='360') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),360,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360','15'/*diaCorte*/,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'360','15'/*diaCorte*/,'plaz')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
			FOREACH	-- MONTO PAGOS EN VENTANILLA		
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)} fecha_mov,SUM(monto)
				SELECT  fecha_mov,SUM(monto) --DSB20150617
						INTO dtFecha,iMonto
						FROM bdicred:"informix".sd_movhiscrd 
						WHERE empresa=pEmpresa
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						AND fecha_mov <= TODAY
						AND num_credito = pNum_credito
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	


/*						WHERE empresa=pEmpresa
						AND num_credito = pNum_credito
						AND num_producto='6400'--A.L.L.Codigo_fun lo consulta de la tabla sd_conceptospagomanualcrd y no se pone directamente
						--AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE codigo IS NOT NULL) --DSB20150617
						AND codigo_ref='1'
						AND reversado='N'
						--AND YEAR(fecha_mov)>=iAnioActual
						AND fecha_mov >= dtfechaTemporal --DSB20150617
						GROUP BY fecha_mov
						ORDER BY fecha_mov DESC	*/


						IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='350') THEN
							INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
							VALUES(YEAR(dtFecha),350,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
							
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350','15'/*diaCorte*/,'plaz')
								INTO cCod_Ret;

							IF cCod_Ret <>'00000'THEN
								Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
								RETURN cCod_Ret,cTrama;							END IF;
						ELSE
							EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'350','15'/*diaCorte*/,'plaz')
								INTO cCod_Ret;

							IF cCod_Ret <>'00000'THEN
								Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
								RETURN cCod_Ret,cTrama;							END IF;
						END IF;
			END FOREACH;
			FOREACH	--DISPOSICIONES	3
				--SELECT {+ INDEX (bdicred:"informix".sd_movhis "informix".inx_movcrd)}  fecha_mov,sum(monto)
				SELECT  fecha_mov,sum(monto) --DSB20150617
					INTO dtFecha,iMonto
					FROM bdicred:"informix".sd_movhiscrd
					WHERE empresa=pEmpresa
					AND fecha_mov >= dtfechaTemporal --DSB20150617
					AND fecha_mov <= TODAY
					AND num_credito=pNum_credito
					AND codigo_fun='002'
					AND codigo_ref='66'
					AND reversado='N'
					GROUP BY fecha_mov

/*					WHERE empresa=pEmpresa
					AND num_credito=pNum_credito
					AND num_producto='6400'
					AND codigo_fun='002'
					AND codigo_ref='66'
					AND reversado='N'
					--AND YEAR(fecha_mov)>=iAnioActual
					AND fecha_mov >= dtfechaTemporal --DSB20150617
					GROUP BY fecha_mov */



					IF NOT EXISTS(SELECT id_concepto FROM tTempInd where anio= YEAR(dtFecha) AND id_concepto='340') THEN
						INSERT INTO tTempInd(anio,id_concepto,ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic) 
						VALUES(YEAR(dtFecha),340,'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00');
						
						--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					ELSE
						--EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mes_tabla_temporal(dtFecha ,iMonto,'340',diaCorte,'plaz')
						EXECUTE PROCEDURE bdimonitorcob:"informix".sp_valida_mestabletemp_sin_corte(dtFecha, iMonto, '340')
							INTO cCod_Ret;

						IF cCod_Ret <>'00000'THEN
							Let cTrama='Error al ejecutar sp_valida_mes_tabla_temporal';
							RETURN cCod_Ret,cTrama;						END IF;
					END IF;
			
			END FOREACH;
	END IF;	

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
