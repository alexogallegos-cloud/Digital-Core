CREATE PROCEDURE "informix".sp_repcredsipab_temp( pCliente CHAR(20), dtFechaHoy date )
RETURNING CHAR(5); 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(80);
    DEFINE cTpCobranza      SMALLINT;
    DEFINE cMoneda          SMALLINT;
    DEFINE cSegmento        SMALLINT;
    DEFINE iContador        SMALLINT;
    DEFINE dOtrosAcces      DECIMAL(15,2);
    DEFINE cNumCred         CHAR(20);
    DEFINE dCapVig          DECIMAL(15,2);
    DEFINE dCapVenc         DECIMAL(15,2);
    DEFINE dIntVenc         DECIMAL(15,2);
    DEFINE dIntMor          DECIMAL(15,2);
    DEFINE dComPend         DECIMAL(15,2);
    DEFINE dIvaCom	        DECIMAL(15,2);
    DEFINE cProducto        CHAR(4);
    DEFINE dtFechaFinMes    DATE;
	DEFINE dDiaCorte        integer;
	DEFINE dIntVig          DECIMAL(15,2);
--    DEFINE dtFechaHoy	    DATE;
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cErrorInfo      = '';
    LET cCodRet         = '00000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET cSegmento       = 0;
    LET iContador       = 0;
    LET cTpCobranza     = 1;
    LET cMoneda         = 0;
    LET dOtrosAcces     = 0;
    LET	cNumCred        = '';
    LET	dCapVig         = 0;
    LET	dCapVenc        = 0;
    LET	dIntVenc        = 0;
    LET	dIntMor         = 0;
    LET	dComPend        = 0;
    LET	dIvaCom	        = 0;
    LET	cProducto       = "";
    LET	dtFechaFinMes   = DATE(1);
	LET dDiaCorte       = 0;
	LET dIntVig         = 0;
--    LET	dtFechaHoy	    = DATE(1);
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repcredsipab_temp.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cErrorInfo;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/ifxsif01/MarcoCardenas/IFRS/sp_repcredsipab_temp.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF ( pCliente is null OR pCliente = '' ) THEN
        LET cCodRet	= '00001';
        RETURN cCodRet;
    END IF;
    
--    SELECT fecha_hoy
--	  INTO dtFechaHoy
--	  FROM bdicred:sd_fechas
--	 WHERE empresa = '001';
    
--    LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 UNITS DAY;
    --IFRS Se contemplan los nuevos estatus de crédito por Etapas de Vencido
	
	FOREACH WITH HOLD
        SELECT num_credito, num_producto, divisa
          INTO cNumCred, cProducto, cMoneda
          FROM bdicred:sd_maecredcont 
																									
         WHERE numcte = pCliente
		   AND fecha = dtFechaHoy
           AND status_cred IN  ('BT','E2','E3')
								
           AND empresa = '001'
        UNION ALL
        SELECT num_credito, num_producto, divisa	  
          FROM bdicred:sd_maecredcontcrd 
																									   
         WHERE numcte = pCliente
		   AND fecha = dtFechaHoy 
           AND status_cred IN  ('BT','E2','E3')
           AND empresa = '001'	
        
        IF cProducto in ("6001","8100","7000") THEN 
            LET cSegmento = 3;
            
            SELECT mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscont
		     WHERE fecha = dtFechaHoy
		       AND empresa = '001'
               AND num_credito = cNumCred ;
			   
			SELECT dia_corte
			  INTO dDiaCorte
		      FROM bdicred:sd_maecredanexo
		     WHERE empresa = '001'
               AND num_credito = cNumCred ;
			   
			SELECT sdo_int_anticip
			  INTO dIntVig
		      FROM bdicred:sd_maesdoshist
		     WHERE fecha = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
		       AND empresa = '001'
               AND num_credito = cNumCred ;

            
         /*   SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
                   NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
              INTO dComPend, dIvaCom
              FROM bdicred:sd_detcomi dc,
                   bdicred:sd_tpcomis tc
             WHERE dc.empresa = '001'
               AND dc.num_credito = cNumCred
               AND dc.estado_com = 'A'
               AND dc.empresa = tc.empresa
               AND dc.cod_comis = tc.cod_comis
               AND tc.comi_o_seg IN('1','4');
               
            LET dOtrosAcces = dComPend + dIvaCom;*/
			LET dOtrosAcces = 0.00;
        ELSE 		   
            LET cSegmento = 4;
            
            SELECT mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscontcrd
		     WHERE fecha = dtFechaHoy
		       AND empresa = '001'
               AND num_credito = cNumCred;		
            
            LET dOtrosAcces = 0.00;
        END IF
        
        IF dIntVig     is null THEN LET dIntVig     = 0.00; END IF;
        IF dCapVenc    is null THEN LET dCapVenc    = 0.00; END IF;
        IF dIntVenc    is null THEN LET dIntVenc    = 0.00; END IF;
        IF dIntMor     is null THEN LET dIntMor     = 0.00; END IF;
        IF dOtrosAcces is null THEN LET dOtrosAcces = 0.00; END IF;

		IF (dIntVig > dIntVenc) then
			LET dIntVenc = 0;
		ELSE	
			LET dIntVenc = dIntVenc - dIntVig;
		END IF;
		
		LET dCapVig = dCapVenc + dIntVenc + dIntMor + dOtrosAcces;
        
        INSERT INTO si_infcrdtit_temp VALUES
        ( cNumCred, cMoneda, cSegmento, cTpCobranza, dCapVig, dCapVenc, dIntVenc, dIntMor, dOtrosAcces );
        
        INSERT INTO si_crdasotit_temp VALUES
        ( cNumCred, pCliente );
        
        LET iContador = 1;
    END FOREACH
    
    IF iContador = 0 THEN 
        LET cCodRet = '00002';
        RETURN cCodRet; 
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE
    
DOCUMENT    
'DESCRIPCION: Procedimiento para  la créditos vencidos de los titulares, RQM 06 419', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 01 Junio 2015',
'VERSION: 20150601.1645',
'BD: bdicred';

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