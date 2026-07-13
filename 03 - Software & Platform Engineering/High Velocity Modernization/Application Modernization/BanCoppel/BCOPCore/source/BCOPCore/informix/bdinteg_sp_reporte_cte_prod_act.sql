CREATE PROCEDURE "informix".sp_reporte_cte_prod_act()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  
		  
DEFINE iSqlError 		  INTEGER;		  
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE dFechahoy		  DATE;
DEFINE dFechapri		  DATE;
DEFINE dFechault		  DATE;
DEFINE dPridiames		  DATE;
DEFINE dUltdiames		  DATE;
DEFINE vNombreArchivo     VARCHAR(100);
DEFINE iCteprodactcre	  INTEGER;
DEFINE iCtetrantdc		  INTEGER;
DEFINE iCtetrantdctot	  VARCHAR(20);
DEFINE iCteprodactdb	  INTEGER;
DEFINE iCtetrandb    	  INTEGER;
DEFINE iCtetrandbtot      VARCHAR(20);
DEFINE cRutaArchRep	      CHAR(150);
DEFINE cRepcre            CHAR(300);
DEFINE cRepdb             CHAR(300);
DEFINE cNombrefecha       CHAR(6);

LET iSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET dFechahoy = '';
LET dFechapri = '';
LET dFechault = '';
LET dPridiames = '';
LET dUltdiames = '';
LET vNombreArchivo = '';
LET iCteprodactcre = '';
LET iCtetrantdc = '';
LET iCtetrantdctot = '';
LET iCteprodactdb = '';
LET iCtetrandb = '';
LET iCtetrandbtot = '';
		  
BEGIN


	ON EXCEPTION SET iSqlError
		IF (iSqlError != 0) THEN
			LET vsCodRetorno = iSqlError;
			LET vsMensaje = 'SE EJECUTO CON ERRORES';
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;		  

--SET DEBUG FILE TO "/ifxsif01/MarcoCardenas/IFRS/sp_reporte_cte_prod_act.out";
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT 
		ADD_MONTHS(DATE(pri_dia_mes),-1) AS pri_dia_mes , LAST_DAY(ADD_MONTHS(DATE(fecha_hoy),-1)) AS fecha_hoy
		INTO dPridiames,dUltdiames
		FROM bdinteg:"informix".si_fechas;
		
		LET cNombrefecha = SUBSTR(dPridiames,1,2)||SUBSTR(dPridiames,7,4);

		LET vNombreArchivo = 'Clientes_con_productos_activos_'||cNombrefecha||'.csv';
		
		LET cRepcre = 'rm -f /home/procesos/'||vNombreArchivo;
		SYSTEM cRepcre; 
		--IFRS Se contempla el nuevo estatus por Etapa 1 Vigente
	-----------------------------------CREDITO------------------------------------
		SELECT a.numcte,a.num_credito
		FROM bdicred:sd_maecred a,
			 bdicred:sd_maesdos b
		WHERE a.num_credito = b.num_credito
		and a.status_cred IN ('AM', 'AA','AC','AE','AR','E1') 
		AND (b.monto_vencido + b.mto_venc_trasp) = 0
		--WHERE status_cred IN ('AM', 'AA','AC','AE','AR')
		INTO TEMP tmp_ctes_cre
		WITH NO LOG;
		
		SELECT numcte
		FROM tmp_ctes_cre 
		GROUP BY numcte
		INTO TEMP tmp_ctes_prod_act_cre
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT numcte)
		INTO iCteprodactcre
		FROM tmp_ctes_prod_act_cre;


		SELECT num_credito,monto 
		FROM bdicred: sd_movhis 
		WHERE fecha_mov BETWEEN dPridiames AND dUltdiames
		INTO TEMP tmp_ctes_prod_act_sd_movhis
		WITH NO LOG;

		SELECT COUNT(DISTINCT numcte)
		INTO iCtetrantdc
		FROM tmp_ctes_cre 
		WHERE num_credito IN (SELECT num_credito FROM tmp_ctes_prod_act_sd_movhis);
		
	
		SELECT SUM(monto):: VARCHAR(20)
		INTO iCtetrantdctot  
		FROM tmp_ctes_prod_act_sd_movhis 
		WHERE num_credito IN(SELECT num_credito FROM tmp_ctes_cre);

	-----------------------------------DEBITO------------------------------------	
	
		SELECT num_cte,cuenta
		FROM bdicheq:sc_maechq  
		WHERE status_cta = 1
		INTO TEMP tmp_ctes_db
		WITH NO LOG;
		
		SELECT num_cte
		FROM tmp_ctes_db  
		GROUP BY num_cte
		INTO TEMP tmp_ctes_prod_act_db
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT num_cte)
		INTO iCteprodactdb
		FROM tmp_ctes_prod_act_db;
		
		SELECT cuenta,monto_tot
		FROM bdicheq:sc_movhis 
		WHERE fech_alt BETWEEN dPridiames AND dUltdiames
		INTO TEMP tmp_ctes_prod_act_sc_movhis
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT num_cte)
		INTO iCtetrandb
		FROM tmp_ctes_db WHERE cuenta IN (SELECT cuenta FROM tmp_ctes_prod_act_sc_movhis);
		
		SELECT SUM(monto_tot):: VARCHAR(20)
		INTO iCtetrandbtot 
		FROM tmp_ctes_prod_act_sc_movhis WHERE cuenta IN(SELECT cuenta FROM tmp_ctes_db);
		
			
		
		LET cRutaArchRep = '/home/procesos/';
		
		LET cRepcre = 'echo "' ||('Numero de clientes productos activos credito') || ',' || ('Numero de clientes que transaccionaron durante el mes credito') || ',' || ('Monto global de las transacciones credito')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre; 
		
		LET cRepcre = 'echo "' ||(iCteprodactcre) || ',' || (iCtetrantdc) || ',' || NVL(iCtetrantdctot,'0')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;

		LET cRepcre = 'echo "' || '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'echo "' ||('Numero de clientes productos activos debito') || ',' || ('Numero de clientes que transaccionaron durante el mes debito') || ',' || ('Monto global de las transacciones debito')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'echo "' ||(iCteprodactdb) || ',' || (iCtetrandb) || ',' || NVL(iCtetrandbtot,'0')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'zip '||TRIM(cRutaArchRep)||TRIM('Clientes_con_productos_activos')||'.zip '||'-P Reportecredb*2018 /'||TRIM(cRutaArchRep)||TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET vsMensaje = 'SE GENERO EL REPORTE CORRECTAMENTE';
		
		DROP TABLE tmp_ctes_cre;
		DROP TABLE tmp_ctes_prod_act_cre;
		DROP TABLE tmp_ctes_prod_act_sd_movhis;
		DROP TABLE tmp_ctes_db;
		DROP TABLE tmp_ctes_prod_act_db;
		DROP TABLE tmp_ctes_prod_act_sc_movhis;
		
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;