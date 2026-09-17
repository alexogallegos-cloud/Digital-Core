CREATE PROCEDURE "informix".sp_genrepordomipagosprog()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE iDiactual			SMALLINT;
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cRutaArchDet			CHAR(100);
DEFINE cRutaArchCif			CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cStmt2				CHAR(250);
DEFINE dFecha_Hoy			DATE;
DEFINE iCuantos				INTEGER;
DEFINE cStatus				CHAR(1);
DEFINE cFechaFormato		CHAR(10);

DEFINE dFechaIni          	DATE; 
DEFINE dFechaFin          	DATE;
DEFINE iMaxC              	INT;
DEFINE iMax2              	INT;

DEFINE iNumoperac 			INTEGER;
DEFINE cTipopago        	CHAR(60);
DEFINE dMonto           	DECIMAL(16,2);
DEFINE cCvepago				CHAR(10);
DEFINE cNomes				CHAR(15);
DEFINE cMesfin 				CHAR(2);	
DEFINE iTotoperac 			INTEGER;
DEFINE dMontotal           	DECIMAL(16,2);
DEFINE cPagoprog			CHAR(45);
DEFINE iNumprog				INTEGER;
DEFINE dMontoprog			DECIMAL(16,2);
DEFINE iTotalprog			INTEGER;
DEFINE dMontototal			DECIMAL(16,2);
DEFINE cDescripcionSPJ	 CHAR(100);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET cMensaje				= 'PROCESO EXITOSO';
LET iSqlErr					= 0;
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cRutaArchDet			= ''; 							 
LET cRutaArchCif			= '';
LET cStmt					= '';
LET cStmt2					='';
LET dFecha_Hoy				= DATE(1);
LET cStatus  			= '0';
LET cFechaFormato		= '1900-01-01';
LET iMaxC = 0;
LET iNumoperac = 0;
LET cTipopago = '';
LET cCvepago = '';
LET cNomes = '';
LET cMesfin = '';	
LET iTotoperac = 0;
LET dMonto = 0;
LET dMontotal = 0;
LET cPagoprog = '';
LET iNumprog = 0;
LET dMontoprog = 0;
LET iTotalprog = 0;
LET dMontototal = 0;
LET iDiactual = 0;
LET cDescripcionSPJ	 = 'Genera reporte mensual de domiciliacion y pagos programados';
 
	/*SET DEBUG FILE TO  '/informix/yuri/reporte/sp_genreporDomipagosprog.out';
	TRACE ON;*/

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy
		INTO   dFecha_Hoy
		FROM   bdisac:"informix".sac_fechas
		WHERE  empresa = '001';
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_REPDOM' and fecha_proceso = dFecha_Hoy) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_REPDOM', dFecha_Hoy, '0', 'informix', 'sp_genrepordomipagosprog', cDescripcionSPJ);
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='IND_REPDOM' and fecha_proceso = dFecha_Hoy;					
		END IF;
		
		IF cStatus = '0' THEN
		
			SELECT valor 
			INTO cRutaArchDet
			FROM bdisac:sac_param
			WHERE cod_param = '108';
			
			SELECT valor 
			INTO cRutaArchCif
			FROM bdisac:sac_param
			WHERE cod_param = '109';
			
			--ASIGNA VALOR A LAS VARIABLES
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');						
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArchDet = REPLACE(cRutaArchDet,'aaaa',cAnio);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'mm',cMes);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'dd',cDia);								
			LET cRutaArchCif = REPLACE(cRutaArchCif,'AAAA',cAnio);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'MM',cMes);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'DD',cDia);					

			LET dFechaFin = dFecha_Hoy - DAY(dFecha_Hoy);		       
			LET dFechaIni = dFechaFin - (DAY(dFechaFin) -1);	
			
			LET cMesfin = LPAD(MONTH(dFechaIni::DATE), 2, '0');
			
			--PONE NOMBRE DEL MES
			IF cMesfin='12' THEN
				LET cNomes ='DICIEMBRE';
			END IF;
			IF cMesfin='11' THEN
				LET cNomes ='NOVIEMBRE';
			END IF;
			IF cMesfin='10' THEN
				LET cNomes ='OCTUBRE';
			END IF;
			IF cMesfin='09' THEN
				LET cNomes ='SEPTIEMBRE';
			END IF;
			IF cMesfin='08' THEN
				LET cNomes ='AGOSTO';
			END IF;
			IF cMesfin='07' THEN
				LET cNomes ='JULIO';
			END IF;
			IF cMesfin='06' THEN
				LET cNomes ='JUNIO';
			END IF;
			IF cMesfin='05' THEN
				LET cNomes ='MAYO';
			END IF;
			IF cMesfin='04' THEN
				LET cNomes ='ABRIL';
			END IF;
			IF cMesfin='03' THEN
				LET cNomes ='MARZO';
			END IF;
			IF cMesfin='02' THEN
				LET cNomes ='FEBRERO';
			END IF;
			IF cMesfin='01' THEN
				LET cNomes ='ENERO';
			END IF;	
					
			SELECT MAX(LENGTH(razon_social))
			INTO iMaxC
			FROM bdidomi:dom_cat_servicios;
		
			LET cStmt =  'echo "' || RPAD(TRIM(cNomes),15,' ')|| '" >> '|| cRutaArchCif;
			SYSTEM cStmt;
			
			LET cStmt =  'echo "' || RPAD('TIPO DE PAGO',iMaxC,' ')  || ',' || RPAD('NUMERO DE OPERACIONES',22, ' ') || ',' || 'IMPORTE' || '" >> '|| cRutaArchCif;
			SYSTEM cStmt;
			
			--SERVICIOS DOMICILIADOS
			FOREACH
				select c.razon_social AS tipo_pago, COUNT(b.rfc_ord) AS num_operaciones, 
				SUM(((b.importe::INTEGER)/100)::DECIMAL(16,2)) AS importe
				into cTipopago,iNumoperac,dMonto
				FROM bdidomi:dom_cce_detalle b
				INNER JOIN bdidomi:dom_cat_servicios c ON(b.rfc_ord = c.rfc)
				WHERE b.cod_operacion = '30'
				AND b.cve_estatus in ('00','01') 
				AND b.fecha_aplica  between YEAR(dFechaIni)||LPAD(MONTH(dFechaIni),2,0)||LPAD(DAY(dFechaIni),2,0) AND YEAR(dFechaFin)||LPAD(MONTH(dFechaFin),2,0)||LPAD(DAY(dFechaFin),2,0)
				GROUP BY 1
				ORDER BY 1	
				
				LET cTipopago = REPLACE(cTipopago,',','');
				LET iTotoperac = iTotoperac + iNumoperac;
				LET dMontotal = dMontotal + dMonto;

				LET cStmt =  'echo "' ||  RPAD(UPPER(TRIM(cTipopago)),iMaxC,' ') || ',' || iNumoperac || ',' || dMonto || '" >> ' || cRutaArchCif;
				SYSTEM cStmt;							
				
			END FOREACH	
			
				LET cStmt =  'echo "' || RPAD('TOTALES',10,' ')  || ',' || iTotoperac ||',' || dMontotal || '" >> '|| cRutaArchCif;
				SYSTEM cStmt;
			
			--PAGOS PROGRAMADOS
			SELECT MAX(LENGTH(descripcion ))
			INTO iMax2
			FROM bdiprog:pp_tppago;
			
			LET cStmt2 =  'echo "' || RPAD(TRIM(cNomes),15,' ')|| '" >> '|| cRutaArchDet;
			SYSTEM cStmt2;
			
			LET cStmt2 =  'echo "' || RPAD('TIPO DE PAGO',iMax2,' ')  || ',' || RPAD('NUMERO DE OPERACIONES',22, ' ') || ',' || 'IMPORTE' || '" >> '|| cRutaArchDet;
			SYSTEM cStmt2;
			
			FOREACH 
					
				SELECT pagoprog.cve_pago,
				CASE WHEN pagoprog.cve_pago='04' THEN (SELECT nomconvenio FROM bdisac:sac_convenios WHERE numcategoria || numconvenio = pagoprog.convenio)
				ELSE c.descripcion END AS descripcion,
				count(pagoprog.cve_pagoprog) as nu_operaciones, 
				CASE WHEN pagoprog.cve_pago = '05' THEN
				(SELECT NVL(SUM(totEfectivo), 0)				
				FROM TABLE(MULTISET(SELECT CASE WHEN transacc = '0281'  THEN monto_tot END AS totEfectivo
				FROM bdicheq:"informix".sc_movhis a, bdiprog:pp_pagospend b
				WHERE a.transacc = '0281' AND a.folio_suc = b.folio_suc AND empresa='001' AND a.fech_alt BETWEEN dFechaIni AND dFechaFin	 
				UNION ALL
				SELECT CASE WHEN transacc = '0281'  THEN monto_tot END AS totEfectivo
				FROM bdicheq:"informix".sc_movhis_old a, bdiprog:pp_pagospend b
				WHERE a.transacc = '0281' AND a.folio_suc = b.folio_suc AND empresa='001' AND a.fech_alt BETWEEN dFechaIni AND dFechaFin)))
				ELSE SUM(pagoprog.importe) END AS importe
				into cCvepago,cPagoprog,iNumprog,dMontoprog
				FROM bdiprog:pp_tppago c,bdiprog:"informix".pp_pagoprog pagoprog
				INNER JOIN bdiprog:pp_pagospend  pagopend  ON pagoprog.cve_pagoprog = pagopend.cve_pagoprog
				AND pagopend.estado = '05' AND pagoprog.cve_pago IN ('01','02','03','04','05','06')
				AND pagopend.fecha_aplic BETWEEN dFechaIni AND dFechaFin						
				WHERE pagoprog.cve_pago = c.cve_pago
				GROUP BY pagoprog.cve_pago, descripcion
				ORDER BY pagoprog.cve_pago
				
				LET cPagoprog = REPLACE(cPagoprog,',','');
				LET iTotalprog = iTotalprog + iNumprog;
				LET dMontototal = dMontototal + dMontoprog;
				
				LET cStmt2 =  'echo "' ||  RPAD(UPPER(TRIM(cPagoprog)),iMax2,' ') || ',' || iNumprog || ',' || dMontoprog || '" >> ' || cRutaArchDet;
				SYSTEM cStmt2;						
				
			END FOREACH
			
			LET cStmt2 =  'echo "' || RPAD('TOTALES',10,' ')  || ',' || iTotalprog ||',' || dMontototal || '" >> '|| cRutaArchDet;
			SYSTEM cStmt2;
										
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo "' || '" >> ' ||cRutaArchCif;
			SYSTEM cStmt;			
				
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt2 = 'echo "' || '" >> ' || cRutaArchDet;
			SYSTEM cStmt2;
			
		END IF;
		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_REPDOM', dFecha_Hoy, '1', 'informix', 'sp_genrepordomipagosprog', cDescripcionSPJ);
		RETURN cCodRet, cMensaje; 

	END;
END PROCEDURE;