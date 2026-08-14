CREATE PROCEDURE "informix".sp_rep_men_increm_auto_apli(pFecha DATE, pModo CHAR(1))
	RETURNING
	CHAR(6) AS retorno;

	DEFINE cCodRet 						CHAR(6);
	DEFINE iSqlErr 						INTEGER;
	DEFINE dtAniversarioCred 			DATE;
	DEFINE dtFecha 						DATE;
	DEFINE iIncrementosEfectuados 		INTEGER;
	DEFINE dtFecha_hoy 					DATE;
	DEFINE cRuta  						CHAR(100);
	DEFINE cSql                     	CHAR(600);
	DEFINE iAnio                    	INTEGER;
	DEFINE iContador                    INTEGER;	
	DEFINE dMonto                   	DECIMAL (18,2);
	DEFINE cMes                     	CHAR(2);
	DEFINe cDia                     	CHAR(2);
	DEFINE cTitulo                  	CHAR(8);
	DEFINE cCodRetSpPrimero         	CHAR(6);
	DEFINE dtPrimerDiaMes            	DATE;
	DEFINE dtUltimoDiaMes            	DATE;
	DEFINE dtFechaMonthAdd           	DATE;								
	DEFINE iNumRegPorTrans              INTEGER;

	LET cCodRet 						= '000000';
	LET iSqlErr 						= 0;
	LET dtAniversarioCred 				= DATE(1);
	LET dtFecha 						= DATE(1);
	LET iIncrementosEfectuados 			= 0;
	LET dtFecha_hoy 					= DATE(1);
	LET cRuta        					= '';
	LET cSql                    		= '';
	LET iAnio                    		= 0;
	LET iContador 						= 0;	
	LET dMonto                   		= 0.00;			
	LET cMes                     		= '';
	LET cDia                     		= '';
	LET cTitulo                  		= '';
	LET cCodRetSpPrimero         		= '';
	LET dtPrimerDiaMes            		= DATE(1);
	LET dtUltimoDiaMes            		= DATE(1);
	LET dtFechaMonthAdd           		= DATE(1);						
	LET iNumRegPorTrans                 = 0;
	
	--SET DEBUG FILE TO "/dbexportb/carlos/reporteria/auto_apli.out";
	--TRACE ON;
		
	BEGIN
		--CONTROL DE ERRORES DE INFORMIX.
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet= iSqlErr;				
				IF iSqlErr = -535 THEN
				COMMIT WORK;
			END IF;
			RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)			
			COMMIT WORK;			
		END EXCEPTION WITH RESUME;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--ACTUALIZA LAS ESTADÍSTICAS DE OPTIMIZACIÓN DE CONSULTA PARA LA TABLA DE TRABAJO "sd_rep_men_inc_auto_apli".
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_apli;
		
		--CONTROL DE PARÁMETROS.
		SELECT fecha_hoy
		INTO dtFecha_hoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';		
				
		--SE VALIDAN LOS PARAMETRO Y SIN ALGUNO VIENE VACIO NO SE PUEDE EJECUTAR EL SP.
		IF NVL(pFecha,'') = '' OR NVL(pModo,'') = '' THEN
			LET cCodRet = '000001';			RETURN cCodRet ;
		END IF;
		--SE VALIDA SI LA FECHA PARAMETRO ES MAYOR A LA FECHA HOY.
		IF pFecha > dtFecha_hoy THEN 
			LET cCodRet = '000002';			RETURN cCodRet ;
		END IF;
		
		--VALIDA EL VALOR DE LA MODALIDAD.
		IF pModo <> 1 AND pModo <> 2 THEN 			
			LET cCodRet = '000003';			RETURN cCodRet ;
		END IF;
		
		--SE OBTIENE LA RUTA DONDE SE GUARDARA EL REPORTE.
		SELECT valor
		INTO cRuta
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param = '050';
		
		--SE OBTIENE EL NUMERO DE REGISTROS POR TRANSACCION.
		SELECT TRIM(valor)::INTEGER
		INTO iNumRegPorTrans
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param = '052';	
			
		---CALCULOS DE FECHAS
		--SE OBTIENE LA FECHA BASE PARA CALCULAR LOS CREDITOS CON UN AÑO DE ANTIGUEDAD MINIMO.
		EXECUTE PROCEDURE "informix".monthadd(dtFecha_hoy, -12)
		INTO dtAniversarioCred;
		
		--CALCULOS DE FECHAS.
		--SE OBTIENE LA FECHA CON EL MES DEL QUE SE HARÁ EL CORTE.
		IF pModo = 1 THEN 
			EXECUTE PROCEDURE "informix".monthadd(dtFecha_hoy, -1)
			INTO dtFechaMonthAdd;		
			--BORRA LOS DATOS CORRESPONDIENTES A OTRO MES, CON LA MISMA MODALIDAD EN CASO QUE HAYAN QUEDADO EN LA TABLA DE TRABAJO			
			DELETE "informix".sd_rep_men_inc_auto_apli WHERE (MONTH(fecha)||YEAR(fecha)) <> (MONTH(dtFechaMonthAdd)||YEAR(dtFechaMonthAdd)) AND modalidad = pModo;		
		ELSE 
			LET dtFechaMonthAdd = pFecha;
		END IF;		
						
		LET cMes = LPAD((MONTH(dtFechaMonthAdd)),2,'0');
		LET iAnio = YEAR(dtFechaMonthAdd);		
		
		--SE OBTIENE EL PRIMER Y ULTIMO DIA DE ESE MES
		EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes,iAnio)
		INTO cCodRetSpPrimero, dtPrimerDiaMes, dtUltimoDiaMes;		
		
		FOREACH WITH HOLD			
			--SE CUENTAN LOS CREDITOS A LOS CUALES NO SE LES APLICO EL INCREMENTO.
			SELECT b.fecha_apertura,COUNT(*) AS IncrementosEfectuados,NVL(SUM(a.lincred_sugerida - a.lincred_actual),0.00) AS Monto
			INTO dtFecha,iIncrementosEfectuados,dMonto
			FROM "informix".sd_bitacora_aumlincred a
				INNER JOIN "informix".sd_maecred b ON (b.empresa = a.empresa AND b.num_credito = a.num_solicitud)
				INNER JOIN bdisolic:"informix".ss_solicitudes c ON(c.empresa = a.empresa AND a.num_solicitud = c.num_solicitud AND c.ajuste_de_cuota =  'S'  ) 
			WHERE a.fecha_status BETWEEN dtPrimerDiaMes AND dtUltimoDiaMes		
				AND a.status = 'AP'
				AND a.origen = 'C'
				AND a.empresa = '001'
				AND b.fecha_apertura <= dtAniversarioCred
			GROUP BY  b.fecha_apertura
			ORDER BY b.fecha_apertura ASC
						
			IF NOT EXISTS (SELECT {+INDEX("informix".sd_rep_men_inc_auto_apli idx_rep_autoapli)}  fecha FROM "informix".sd_rep_men_inc_auto_apli WHERE fecha = dtFecha AND modalidad = pModo ) THEN 			
				--SE INCREMENTA CONTADOR DE INSERCIONES.
				LET iContador = iContador + 1;
				--SI ES EL INICIO SE ABRE TRANSACCION.
				IF iContador = 1 THEN
					BEGIN WORK;							
				END IF;
				--SE INSERTA LA INFORMACION OBTENIDA DEL QUERY PRINCIPAL.
				INSERT INTO "informix".sd_rep_men_inc_auto_apli (fecha, increm_efec, monto, modalidad) VALUES (dtFecha,iIncrementosEfectuados, NVL(dMonto,0.00),pModo);
				--SE INICIALIZAN VARIABLES.
				LET dtFecha = DATE(1);
				LET iIncrementosEfectuados = 0;
				LET dMonto =  0.00; 				
			ELSE 			
				--SE INCREMENTA CONTADOR DE INSERCIONES.
				LET iContador = iContador + 1;
				--SI ES EL INICIO SE ABRE TRANSACCION.
				IF iContador = 1 THEN
					BEGIN WORK;							
				END IF;				
				--SE ACTUALIZA LA INFORMACION OBTENIDA DEL QUERY PRINCIPAL EN LA TABLA DE TRABAJO.
				UPDATE "informix".sd_rep_men_inc_auto_apli SET increm_efec = (increm_efec + iIncrementosEfectuados), monto = (monto + dMonto) WHERE fecha = dtFecha AND modalidad = pModo;
				--SE INICIALIZAN VARIABLES.
				LET dtFecha = DATE(1);
				LET iIncrementosEfectuados = 0;
				LET dMonto =  0.00; 			
			END IF;
			--SI YA SE CUMPLEN LAS N TRANSACCIONES SE CIERRA LA TRANSACCION Y SE INICIALIZA EL CONTADOR.
			IF iContador = iNumRegPorTrans THEN
				COMMIT WORK;							
				LET iContador = 0;
			END IF;	
		END FOREACH
		
		--SE VALIDA SI SE QUEDO ABIERTA UNA TRANSACCION.
		IF iContador > 0 THEN 		
			COMMIT WORK;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000004';				RETURN cCodRet ;				
		END IF;
				
		--SE INICIALIZAN LAS VARIABLES PARA REUTILIZARLAS.
		LET cMes = '';
		LET iAnio = '';
		--SE ARMA EL TITULO DEL REPORTE.		
		LET cDia = LPAD((DAY(dtFecha_hoy)),2,'0');
		LET cMes = LPAD((MONTH(dtFecha_hoy)),2,'0');
		LET iAnio = YEAR(dtFecha_hoy);
		
		LET cTitulo = TRIM(cDia)||TRIM(cMes)||iAnio;
		LET cTitulo = TRIM(cTitulo);
		
		--SE HACE UPDATE STATISTICS ANTES DE LA CONSULTA,PARA ACTUALIZAR LAS ESTADÍSTICAS DE OPTIMIZACIÓN DE CONSULTA PARA LA TABLA DE TRABAJO "sd_rep_men_inc_auto_apli".
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_apli;
	
		--VACIADO A ARCHIVO TXT.
		IF pModo= '1' THEN
			LET cSql = 'echo "Fecha|Incrementos Efectuados|Monto" >' || TRIM(cRuta) || '/ReporteAplicadoshead_'||TRIM(cTitulo)||'.txt';
			LET cSql = TRIM(cSql);
			SYSTEM cSql;
				
			LET cSql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||'/ReporteAplicadosbody_'||TRIM(cTitulo)||'.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_apli idx_rep_autoapli)}  fecha, increm_efec, monto FROM "informix".sd_rep_men_inc_auto_apli WHERE fecha = fecha AND modalidad = "'||TRIM(pModo)||'" ;">  '||TRIM(cRuta)||'/body2.sql ';		
			SYSTEM cSql;
			
			LET cSql= 'dbaccess bdicred  '||TRIM(cRuta)||'/body2.sql';
			SYSTEM cSql; 
			
			LET cSql = '';			
			LET cSql = 'cat '||TRIM(cRuta)||'/ReporteAplicadoshead_'||TRIM(cTitulo)||'.txt '||TRIM(cRuta)||'/ReporteAplicadosbody_'||TRIM(cTitulo)||'.txt > '||TRIM(cRuta)||'/ReporteAplicados_'||TRIM(cTitulo)||'.txt';
		
			LET cSql = TRIM(cSql);
			SYSTEM cSql;
						
			--COMANDO REMOVE.
			LET cSql= 'rm '||TRIM(cRuta)||'/ReporteAplicadoshead_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 
			
			LET cSql= 'rm '||TRIM(cRuta)||'/ReporteAplicadosbody_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 
						
			LET cSql= 'rm '||TRIM(cRuta)||'/body2.sql';		
			SYSTEM cSql; 
			
			--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
			DELETE {+INDEX("informix".sd_rep_men_inc_auto_apli idx_rep_autoapli)} "informix".sd_rep_men_inc_auto_apli WHERE fecha = fecha AND modalidad = pModo;							
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que se puede ejecutar de modo mensual (1) o historico (2) para calculo de los incrementos automaticos aplicados',
'AUTOR: Carlos Ochoa',
'FECHA: Junio de 2013',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_rep_men_increm_auto_cartven(pFecha DATE, pModo CHAR(1)) 
	RETURNING
	CHAR(6) AS retorno;

	DEFINE cCodRet 					CHAR(6);
	DEFINE iSqlErr 					INTEGER;
	DEFINE dtFecha					DATE;
	DEFINE cNumCredito 				CHAR(20);
	DEFINE iCapitalStatusAnt 		INTEGER;
	DEFINE dLineaAut 				DECIMAL (18,2);
	DEFINE dSaldo 					DECIMAL (18,2);
	DEFINE dtFecha_apertura 		DATE;
	DEFINE iAnio                    INTEGER;
	DEFINE iContador                INTEGER;	
	DEFINE cMes                     CHAR(2);
	DEFINe cDia                     CHAR(2);
	DEFINE cTitulo                  CHAR(8);
	DEFINE cCodRetSpPrimero         CHAR(6);
	DEFINE dtPrimerDiaMes           DATE;
	DEFINE dtUltimoDiaMes           DATE;
	DEFINE dtFechaMonthAdd          DATE;		
	DEFINE cRuta                    CHAR(100);
	DEFINE dtFecha_hoy              DATE;						
	DEFINE iNumRegPorTrans       	INTEGER;
	DEFINE cSql                     CHAR(600);

	LET cCodRet 					= '000000';
	LET iSqlErr 					= 0;
	LET dtFecha 					= DATE(1);
	LET cNumCredito 				= '';
	LET iCapitalStatusAnt 			= 0;
	LET dLineaAut 					= 0.00;
	LET dSaldo 						= 0.00;
	LET dtFecha_apertura 			= DATE(1);
	LET iAnio               		= 0;
	LET cMes                	    = '';
	LET cDia                	    = '';
	LET cTitulo             	    = '';
	LET cCodRetSpPrimero    	    = '';
	LET dtPrimerDiaMes       	    = DATE(1);
	LET dtUltimoDiaMes       	    = DATE(1);	
	LET dtFechaMonthAdd      	    = DATE(1);		
	LET cRuta               	    = '';
	LET dtFecha_hoy         	    = DATE(1);	
	LET iContador 				    = 0;						
	LET iNumRegPorTrans     	    = 0;
	LET cSql               			= '';

	--SET DEBUG FILE TO "/dbexportb/carlos/reporteria/cartvend.out";
	--TRACE ON;
	
	BEGIN
		--CONTROL DE ERRORES DE INFORMIX.
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet= iSqlErr;				
				--SI QUEDA ABIERTA LA TRANSACCION QUE SE CIERRE.
				IF iSqlErr = -535 THEN
					COMMIT WORK;						
				END IF;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)			
			COMMIT WORK;			
		END EXCEPTION WITH RESUME;		
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Actualiza las estadísticas de optimización de consulta para la tabla de trabajo "sd_rep_men_inc_auto_noapli".
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_cart_vend;
		
		--CONTROL DE PARÁMETROS
		SELECT fecha_hoy
		INTO dtFecha_hoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';
		
		IF NVL(pFecha,'') = '' AND NVL(pModo,'') = '' THEN --NO SE PUEDE EJECUTAR EL SP SIN PARAMETROS
			LET cCodRet = '000001';
			RETURN cCodRet ;
		END IF;
		
		IF pFecha > dtFecha_hoy THEN --LA FECHA DADA COMO PARAMETRO ES MAYOR A LA FECHA HOY
			LET cCodRet = '000002';
			RETURN cCodRet ;
		END IF;
		
		--VALIDA EL VALOR DE LA MODALIDAD.
		IF pModo <> 1 AND pModo <> 2 THEN 			
			LET cCodRet = '000003';			RETURN cCodRet ;
		END IF;
						
		--SE OBTIENE LA RUTA DONDE SE GUARDARA EL REPORTE.
		SELECT valor
		INTO cRuta
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param='050';
			
			--SE OBTIENE EL NUMERO DE REGISTROS POR TRANSACCION.
		SELECT TRIM(valor)::INTEGER
		INTO iNumRegPorTrans
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param = '052';					
	
		---CALCULOS DE FECHAS.
		--SE OBTIENE LA FECHA CON EL MES DEL QUE SE HARÁ EL CORTE.
		IF pModo = '1' THEN			
			EXECUTE PROCEDURE "informix".monthadd(dtFecha_hoy, -1)
			INTO dtFechaMonthAdd;
			--BORRA LOS DATOS CORRESPONDIENTES A OTRO MES, CON LA MISMA MODALIDAD EN CASO QUE HAYAN QUEDADO EN LA TABLA DE TRABAJO			
			DELETE "informix".sd_rep_men_inc_auto_cart_vend WHERE (MONTH(fecha)||YEAR(fecha)) <> (MONTH(dtFechaMonthAdd)||YEAR(dtFechaMonthAdd)) AND modalidad = pModo;
		ELSE 
			LET dtFechaMonthAdd = pFecha;
		END IF;			
		
		LET cMes = LPAD((MONTH(dtFechaMonthAdd)),2,'0');
		LET iAnio = YEAR(dtFechaMonthAdd);
		
		--SE OBTIENE EL PRIMER Y ULTIMO DIA DE ESE MES.
		EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes,iAnio)
		INTO cCodRetSpPrimero, dtPrimerDiaMes, dtUltimoDiaMes;
					
		FOREACH WITH HOLD
			SELECT a.fecha,a.num_credito AS NumeroCredito, NVL(c.mto_fin_ven_trasp,0), NVL(SUM(c.sdo_cap_insoluto),0.00), NVL(d.monto_solicitado,0.00), a.fecha_apertura
			INTO dtFecha,cNumCredito, iCapitalStatusAnt, dSaldo, dLineaAut, dtFecha_apertura
			FROM "informix".sd_maecred_vendida a
				INNER JOIN "informix".sd_maesdos_vendida c ON(c.empresa = '001' AND c.num_credito = a.num_credito)
				INNER JOIN bdisolic:"informix".ss_solicitudes d ON (d.empresa = '001' AND d.num_solicitud = a.num_credito  AND d.ajuste_de_cuota = 'S')
				
			WHERE a.fecha BETWEEN dtPrimerDiaMes AND dtUltimoDiaMes
				AND a.num_credito = c.num_credito
			GROUP BY a.fecha,a.num_credito ,c.mto_fin_ven_trasp,d.monto_solicitado,a.fecha_apertura
			ORDER BY a.fecha ASC
			
			IF NOT EXISTS (SELECT {+INDEX("informix".sd_rep_men_inc_auto_cart_vend idx_rep_cartven)} num_credito FROM "informix".sd_rep_men_inc_auto_cart_vend WHERE fecha = dtFecha AND modalidad = pModo AND num_credito = cNumCredito) THEN 								
				--SE INCREMENTA CONTADOR DE INSERCIONES.
				LET iContador = iContador + 1;
				--SI ES EL INICIO SE ABRE TRANSACCION.
				IF iContador = 1 THEN
					BEGIN WORK;							
				END IF;
				--SE INSERTA LA INFORMACION OBTENIDA DEL QUERY PRINCIPAL.
				INSERT INTO "informix".sd_rep_men_inc_auto_cart_vend (fecha, num_credito, num_venc_pag, saldo, lin_auto,fecha_origen, modalidad ) VALUES (dtFecha, cNumCredito, iCapitalStatusAnt, dSaldo,dLineaAut, dtFecha_apertura, pModo );				
				--SI YA SE CUMPLEN LAS N TRANSACCIONES SE CIERRA LA TRANSACCION Y SE INICIALIZA EL CONTADOR.
				IF iContador = iNumRegPorTrans THEN
					COMMIT WORK;							
					LET iContador = 0;
				END IF;
			END IF						
		END FOREACH	
				
		--SE VALIDA SI SE QUEDO ABIERTA UNA TRANSACCION.
		IF iContador > 0 THEN 		
			COMMIT WORK;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000004';				RETURN cCodRet ;				
		END IF	
						
		--SE INICIALIZAN LAS VARIABLES PARA REUTILIZARLAS.
		LET cMes = '';
		LET iAnio = '';
		--SE ARMA EL TITULO DEL REPORTE.		
		LET cDia = LPAD((DAY(dtFecha_hoy)),2,'0');
		LET cMes = LPAD((MONTH(dtFecha_hoy)),2,'0');
		LET iAnio = YEAR(dtFecha_hoy);
		
		--SE ARMA EL TITULO DEL REPORTE
		LET cTitulo = TRIM(cDia)||TRIM(cMes)||iAnio;
		LET cTitulo = TRIM(cTitulo);
		
		--SE HACE UPDATE STATISTICS A LA TABLA ANTES DE LA CONSULTA
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_cart_vend;
				
		--VACIADO A ARCHIVO TXT.
		IF pModo= '1' THEN
			LET cSql = 'echo "Fecha venta|Número de Crédito|# de Pagos Vencidos|Saldo|Linea Autorizada|Fecha origen" >' || TRIM(cRuta) || '/ReporteCarteraVendidahead_'||TRIM(cTitulo)||'.txt';
			LET cSql = TRIM(cSql);
			SYSTEM cSql;
			
			LET cSql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||'/ReporteCarteraVendidabody_'||TRIM(cTitulo)||'.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_cart_vend idx_rep_cartven)}  fecha,num_credito,num_venc_pag,saldo, lin_auto,fecha_origen FROM "informix".sd_rep_men_inc_auto_cart_vend WHERE fecha = fecha AND modalidad = "'||TRIM(pModo)||'" ;">  '||TRIM(cRuta)||'/body4.sql ';		
			SYSTEM cSql;
			
			LET cSql= 'dbaccess bdicred  '||TRIM(cRuta)||'/body4.sql';
			SYSTEM cSql; 
			
			LET cSql = '';			
			LET cSql = 'cat '||TRIM(cRuta)||'/ReporteCarteraVendidahead_'||TRIM(cTitulo)||'.txt '||TRIM(cRuta)||'/ReporteCarteraVendidabody_'||TRIM(cTitulo)||'.txt > '||TRIM(cRuta)||'/ReporteCarteraVendida_'||TRIM(cTitulo)||'.txt';
		
			LET cSql = TRIM(cSql);
			SYSTEM cSql;
					
			--COMANDO REMOVE.
			LET cSql= 'rm '||TRIM(cRuta)||'/ReporteCarteraVendidahead_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 
			
			LET cSql= 'rm '||TRIM(cRuta)||'/ReporteCarteraVendidabody_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 			
			
			LET cSql= 'rm '||TRIM(cRuta)||'/body4.sql';		
			SYSTEM cSql; 
			
			--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
			DELETE {+INDEX("informix".sd_rep_men_inc_auto_cart_vend idx_rep_cartven)} "informix".sd_rep_men_inc_auto_cart_vend WHERE fecha = fecha AND modalidad = pModo;							
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: procedimiento que se puede ejecutar de modo mensual (1) o historico (2) para ',
'			  calculo de los incrementos de linea de cartera vendida',
'AUTOR: CARLOS OCHOA',
'FECHA: 13/junio/2013',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_rep_men_increm_auto_hist(pFechaIni DATE, pFechaFin DATE) 
	RETURNING
	CHAR(6) AS retorno;

	--DECLARACION DE VARIABLES
	DEFINE cCodRet 				    CHAR(6);
	DEFINE iSqlErr 				    INTEGER;
	DEFINE dtFechaMonthAdd          DATE;
	DEFINE dtFechaMatriz            DATE;
	DEFINE cCodRetAcep              CHAR(6);
	DEFINE cCodRetApli              CHAR(6);
	DEFINE cCodRetNoApli            CHAR(6);
	DEFINE cCodRetCartVen           CHAR(6);
	DEFINE cSql                     CHAR(5000);
	DEFINE cRuta                    CHAR(100);
	DEFINE cMes                     CHAR(2);
	DEFINE cMes2                    CHAR(2);
	DEFINE iAnio                    INTEGER;
	DEFINE iAnio2                   INTEGER;
	DEFINE cCodRetSpPrimero         CHAR(6);
	DEFINE cCodRetSpSegundo         CHAR(6);
	DEFINE dtPrimerDiaMesParamIni	DATE;
	DEFINE dtPrimerDiaMesParamFin	DATE;
	DEFINE dtUltimoDiaMesParamIni	DATE;
	DEFINE dtUltimoDiaMesParamFin	DATE;

	--INICIALIZACION DE VARIABLES
	LET cCodRet 			    = '000000';
	LET iSqlErr   			    = 0;
	LET dtFechaMonthAdd         = DATE(1);
	LET dtFechaMatriz           = DATE(1);
	LET cCodRetAcep             = '';
	LET cCodRetApli             = '';
	LET cCodRetNoApli           = '';
	LET cCodRetCartVen          = '';
	LET cSql                    = '';
	LET cRuta                   = '';
	LET cMes               	    = '';
	LET cMes2              	    = '';
	LET iAnio              	    = 0;
	LET iAnio2             	    = 0;
	LET cCodRetSpPrimero        = '';
	LET cCodRetSpSegundo        = '';
	LET dtPrimerDiaMesParamIni	= DATE(1);
	LET dtPrimerDiaMesParamFin	= DATE(1);
	LET dtUltimoDiaMesParamIni	= DATE(1);
	LET dtUltimoDiaMesParamFin	= DATE(1);
	
	/* SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_rep_men_increm_auto_hist.out";
	TRACE ON; */
	
	BEGIN
			--CONTROL DE ERRORES DE INFORMIX.
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname ='tmp_matrizfechas' AND dbsname= "bdicred") THEN
				DROP TABLE tmp_matrizfechas;
			END IF;
				LET cCodRet= iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SI LA FECHA INICIAL ES MAYOR QUE LA FINAL O SE INTENTA EJECUTAR EL PROCEDIMIENTO CON ALGUNA DE LAS DOS FECHAS VACIAS
		IF (pFechaIni > pFechaFin) OR  (NVL(pFechaIni,DATE(1)) = DATE(1)  OR NVL(pFechaFin, DATE(1)) = DATE(1) ) THEN
			LET cCodRet= '000001'; --ERROR EN LOS PARAMETROS
			RETURN cCodRet;
		END IF; 
	
		 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname ='tmp_matrizfechas' AND dbsname= "bdicred") THEN
						DROP TABLE tmp_matrizfechas;
		 END IF;

		--SE CREA LA TABLA QUE ANIDARA LA MATRIZ SIN PRIMARY KEY PARA CREARLE EL INDICE CON NOMBRE Y PODERLO FORZAR
		CREATE TEMP TABLE tmp_matrizfechas
		(
			fecha_matriz DATE
		)WITH NO LOG;
		
		CREATE INDEX idx_historico on tmp_matrizfechas (fecha_matriz) 
		USING btree ;
		
		--SE VACIA EL VALOR DEL PARAMETRO EN LA VARIABLE
		LET dtFechaMonthAdd = pFechaIni;
		--SE INSERTA LA PRIMERA LINEA
		INSERT INTO tmp_matrizfechas (fecha_matriz) VALUES (dtFechaMonthAdd);
		
		--CICLO PARA CREAR LA MATRIZ SEGUN LAS FECHAS DADAS
		WHILE dtFechaMonthAdd < pFechaFin
			EXECUTE PROCEDURE "informix".monthadd(dtFechaMonthAdd, 1)
			INTO dtFechaMonthAdd;
			IF dtFechaMonthAdd <= pFechaFin THEN
				INSERT INTO tmp_matrizfechas (fecha_matriz) VALUES (dtFechaMonthAdd);
			END IF;
		END WHILE
		
		--SE OBTIENE LA RUTA DONDE SE GUARDARA EL REPORTE.
		SELECT valor
		INTO cRuta
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param='050';		
		
		--CALCULO PARA LA FECHA INICIAL DEL RANGO A CONSULTAR.
		LET cMes = LPAD((MONTH(pFechaIni)),2,'0');
		LET iAnio = YEAR(pFechaIni);		
		--SE OBTIENE EL PRIMER Y ULTIMO DIA DE ESE MES.
		EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes,iAnio)
		INTO cCodRetSpPrimero, dtPrimerDiaMesParamIni, dtUltimoDiaMesParamIni;
		
		--CALCULO PARA LA FECHA INICIAL DEL RANGO A CONSULTAR.
		LET cMes2 = LPAD((MONTH(pFechaFin)),2,'0');
		LET iAnio2 = YEAR(pFechaFin);		
		--SE OBTIENE EL PRIMER Y ULTIMO DIA DE ESE MES.
		EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes2,iAnio2)
		INTO cCodRetSpSegundo, dtPrimerDiaMesParamFin, dtUltimoDiaMesParamFin;
				 									
		--ELIMINA SI EXISTE INFORMACION EN LAS TABLAS DE TRABAJO PARA EL MODO HISTORICO CON EL RANGO DE FECHAS ENVIADO COMO PARAMETROS.
		DELETE "informix".sd_rep_men_inc_auto_acep_noacep 	WHERE fecha BETWEEN  dtPrimerDiaMesParamIni AND dtUltimoDiaMesParamFin 	AND modalidad = '2';
		DELETE "informix".sd_rep_men_inc_auto_apli 			WHERE fecha BETWEEN  dtPrimerDiaMesParamIni AND dtUltimoDiaMesParamFin 	AND modalidad = '2';
		DELETE "informix".sd_rep_men_inc_auto_noapli 		WHERE fecha BETWEEN  dtPrimerDiaMesParamIni AND dtUltimoDiaMesParamFin 	AND modalidad = '2';
		DELETE "informix".sd_rep_men_inc_auto_cart_vend 	WHERE fecha BETWEEN  dtPrimerDiaMesParamIni AND dtUltimoDiaMesParamFin 	AND modalidad = '2';
		
		FOREACH WITH HOLD
			SELECT {+INDEX(tmp_matrizfechas idx_historico)} fecha_matriz 
			INTO dtFechaMatriz
			FROM tmp_matrizfechas
			WHERE fecha_matriz = fecha_matriz

			EXECUTE PROCEDURE "informix".sp_rep_men_increm_auto_acepynoacep(dtFechaMatriz,'2')
			INTO cCodRetAcep;
									
			EXECUTE PROCEDURE "informix".sp_rep_men_increm_auto_apli(dtFechaMatriz,'2')
			INTO cCodRetApli;			

			EXECUTE PROCEDURE "informix".sp_rep_men_increm_auto_noapli(dtFechaMatriz,'2')
			INTO cCodRetNoApli;						

			EXECUTE PROCEDURE "informix".sp_rep_men_increm_auto_cartven(dtFechaMatriz,'2')
			INTO cCodRetCartVen; 											
		END FOREACH
		 		 
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '000002'; --LA MATRIZ NO SE CREO CORRECTAMENTE
			RETURN cCodRet; 
		END IF	
				
		--GENERACION DE ARCHIVOS HISTORICOS DEL REPORTE sp_rep_men_increm_auto_acepynoacep.
		LET cSql = 'echo "Fecha|Registros Autorizados|Acumulado de Línea Autorizada|Registros NO Autorizados|Acumulado de Línea Autorizada" >' || TRIM(cRuta) || '/ReporteAceptacionyrechazo_historicohead.txt';
		LET cSql = TRIM(cSql);
		SYSTEM cSql;

		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO "'||TRIM(cRuta)||'"/ReporteAceptacionyrechazo_historicobody.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_acep_noacep idx_rep_acep)} fecha, reg_aut, acum_lin_aut, reg_no_aut, acum_lin_no_aut FROM "informix".sd_rep_men_inc_auto_acep_noacep WHERE fecha = fecha AND modalidad = "2" ;">  "'||TRIM(cRuta)||'"/body_hist1.sql'; 
		SYSTEM cSql; 

		LET cSql= 'dbaccess bdicred  "'||TRIM(cRuta)||'"/body_hist1.sql';
		SYSTEM cSql; 

		LET cSql = '';

		LET cSql = 'cat '||TRIM(cRuta)||'/ReporteAceptacionyrechazo_historicohead.txt '||TRIM(cRuta)||'/ReporteAceptacionyrechazo_historicobody.txt > '||TRIM(cRuta)||'/ReporteAceptacionyrechazo_historico.txt';

		LET cSql = TRIM(cSql);
		SYSTEM cSql;

		--COMANDO REMOVE.
		LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteAceptacionyrechazo_historicohead.txt';		
		SYSTEM cSql; 

		LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteAceptacionyrechazo_historicobody.txt';		
		SYSTEM cSql; 

		LET cSql= 'rm "'||TRIM(cRuta)||'"/body_hist1.sql';		
		SYSTEM cSql; 

		--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
		DELETE {+INDEX("informix".sd_rep_men_inc_auto_acep_noacep idx_rep_acep)} "informix".sd_rep_men_inc_auto_acep_noacep WHERE fecha = fecha AND modalidad = "2";		

		--GENERACION DE ARCHIVOS HISTORICOS DEL REPORTE sp_rep_men_increm_auto_apli.
		LET cSql = 'echo "Fecha|Incrementos Efectuados|Monto" >' || TRIM(cRuta) || '/ReporteAplicados_historicohead.txt';
		LET cSql = TRIM(cSql);
		SYSTEM cSql;

		LET cSql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||'/ReporteAplicados_historicobody.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_apli idx_rep_autoapli)}  fecha, increm_efec, monto FROM "informix".sd_rep_men_inc_auto_apli WHERE fecha = fecha AND modalidad = "2" ;">  '||TRIM(cRuta)||'/body_hist2.sql ';
		SYSTEM cSql;

		LET cSql= 'dbaccess bdicred  '||TRIM(cRuta)||'/body_hist2.sql';
		SYSTEM cSql; 

		LET cSql = '';

		LET cSql = 'cat '||TRIM(cRuta)||'/ReporteAplicados_historicohead.txt '||TRIM(cRuta)||'/ReporteAplicados_historicobody.txt > '||TRIM(cRuta)||'/ReporteAplicados_historico.txt';

		LET cSql = TRIM(cSql);
		SYSTEM cSql;

		--COMANDO REMOVE.
		LET cSql= 'rm '||TRIM(cRuta)||'/ReporteAplicados_historicohead.txt';		
		SYSTEM cSql; 

		LET cSql= 'rm '||TRIM(cRuta)||'/ReporteAplicados_historicobody.txt';		
		SYSTEM cSql; 

		LET cSql= 'rm '||TRIM(cRuta)||'/body_hist2.sql';		
		SYSTEM cSql; 

		--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
		DELETE {+INDEX("informix".sd_rep_men_inc_auto_apli idx_rep_autoapli)} "informix".sd_rep_men_inc_auto_apli WHERE fecha = fecha AND modalidad = "2";		

		--GENERACION DE ARCHIVOS HISTORICOS DEL REPORTE sd_rep_men_inc_auto_noapli.
		LET cSql = 'echo "Fecha|Registros no Incrementados" >' || TRIM(cRuta) || '/ReporteNoAplicados_historicohead.txt';
		LET cSql = TRIM(cSql);
		SYSTEM cSql;

		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO "'||TRIM(cRuta)||'"/ReporteNoAplicados_historicobody.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_noapli idx_rep_autonoapli)} fecha, reg_no_incre FROM "informix".sd_rep_men_inc_auto_noapli WHERE fecha = fecha AND modalidad = "2" ;">  "'||TRIM(cRuta)||'"/body_hist3.sql'; 
		SYSTEM cSql; 

		LET cSql= 'dbaccess bdicred  "'||TRIM(cRuta)||'"/body_hist3.sql';
		SYSTEM cSql; 

		LET cSql = '';
		
		LET cSql = 'cat '||TRIM(cRuta)||'/ReporteNoAplicados_historicohead.txt '||TRIM(cRuta)||'/ReporteNoAplicados_historicobody.txt > '||TRIM(cRuta)||'/ReporteNoAplicados_historico.txt';
		
		LET cSql = TRIM(cSql);
		SYSTEM cSql;
		
		--COMANDO REMOVE.
		LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteNoAplicados_historicohead.txt';		
		SYSTEM cSql; 
		
		LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteNoAplicados_historicobody.txt';		
		SYSTEM cSql; 
				
		LET cSql= 'rm "'||TRIM(cRuta)||'"/body_hist3.sql';		
		SYSTEM cSql; 

		--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
		DELETE {+INDEX("informix".sd_rep_men_inc_auto_noapli idx_rep_autonoapli)} "informix".sd_rep_men_inc_auto_noapli WHERE fecha = fecha AND modalidad = "2";		

		--GENERACION DE ARCHIVOS HISTORICOS DEL REPORTE sd_rep_men_inc_auto_cart_vend.
		LET cSql = 'echo "Fecha venta|Número de Crédito|# de Pagos Vencidos|Saldo|Linea Autorizada|Fecha origen" >' || TRIM(cRuta) || '/ReporteCarteraVendida_historicohead.txt';
		LET cSql = TRIM(cSql);
		SYSTEM cSql;
				
		LET cSql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||'/ReporteCarteraVendida_historicobody.txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_cart_vend idx_rep_cartven)}  fecha,num_credito,num_venc_pag,saldo, lin_auto,fecha_origen FROM "informix".sd_rep_men_inc_auto_cart_vend WHERE fecha = fecha AND modalidad = "2" ;">  '||TRIM(cRuta)||'/body_hist4.sql ';
		
		SYSTEM cSql;
		
		LET cSql= 'dbaccess bdicred  '||TRIM(cRuta)||'/body_hist4.sql';
		SYSTEM cSql; 
		
		LET cSql = '';
				
		LET cSql = 'cat '||TRIM(cRuta)||'/ReporteCarteraVendida_historicohead.txt '||TRIM(cRuta)||'/ReporteCarteraVendida_historicobody.txt > '||TRIM(cRuta)||'/ReporteCarteraVendida_historico.txt';
		
		LET cSql = TRIM(cSql);
		SYSTEM cSql;
					
		--COMANDO REMOVE.
		LET cSql= 'rm '||TRIM(cRuta)||'/ReporteCarteraVendida_historicohead.txt';		
		SYSTEM cSql; 
		
		LET cSql= 'rm '||TRIM(cRuta)||'/ReporteCarteraVendida_historicobody.txt';		
		SYSTEM cSql; 
						
		LET cSql= 'rm '||TRIM(cRuta)||'/body_hist4.sql';		
		SYSTEM cSql; 
			
		--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
		DELETE {+INDEX("informix".sd_rep_men_inc_auto_cart_vend idx_rep_cartven)} "informix".sd_rep_men_inc_auto_cart_vend WHERE fecha = fecha AND modalidad = "2";		
		
		--SE ELIMINA TEMPORAL MATRIZ DE RANGO DE FECHAS YA QUE SE HA TERMINADO EL PROCESO.
		IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname ='tmp_matrizfechas' AND dbsname= "bdicred") THEN
				DROP TABLE tmp_matrizfechas;
		END IF;
		
		RETURN cCodRet;
	END	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento historico que manda llamar a los 4 reportes mensuales en base a una matriz de fechas creada.',
'AUTOR: Carlos Ochoa',
'FECHA: Junio de 2013',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_rep_men_increm_auto_noapli(pFecha DATE, pModo CHAR(1) )
	RETURNING
	CHAR(6) AS retorno;

	DEFINE cCodRet 						CHAR(6);
	DEFINE iSqlErr 						INTEGER;
	DEFINE dtAniversarioCred 			DATE;
	DEFINE dtFecha 						DATE;
	DEFINE iRegistrosNoIncrementados 	INTEGER;
	DEFINE dtFecha_hoy 					DATE;
	DEFINE cRuta  						CHAR(100);
	DEFINE cSql                     	CHAR(600);
	DEFINE iAnio                    	INTEGER;
	DEFINE cMes                     	CHAR(2);
	DEFINe cDia                     	CHAR(2);
	DEFINE iContador                    INTEGER;	
	DEFINE cTitulo                  	CHAR(8);
	DEFINE cCodRetSpPrimero         	CHAR(6);
	DEFINE dtPrimerDiaMes            	DATE;
	DEFINE dtUltimoDiaMes            	DATE;
	DEFINE dtFechaMonthAdd           	DATE;								
	DEFINE iNumRegPorTrans              INTEGER;

	LET cCodRet 						= '000000';
	LET iSqlErr 						= 0;
	LET dtAniversarioCred 				= DATE(1);
	LET dtFecha 						= DATE(1);
	LET iRegistrosNoIncrementados 		= 0;
	LET dtFecha_hoy 					= DATE(1);
	LET cRuta        					= '';
	LET cSql                    		= '';
	LET iAnio                    		= 0;
	LET cMes                     		= '';
	LET cDia                     		= '';
	LET iContador 						= 0;		
	LET cTitulo                  		= '';
	LET cCodRetSpPrimero         		= '';
	LET dtPrimerDiaMes            		= DATE(1);
	LET dtUltimoDiaMes            		= DATE(1);
	LET dtFechaMonthAdd           		= DATE(1);							
	LET iNumRegPorTrans                 = 0;

	--SET DEBUG FILE TO "/dbexportb/carlos/reporteria/noapli.out";
	--TRACE ON;
	
	BEGIN
		--CONTROL DE ERRORES DE INFORMIX.
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr <> 0 THEN
			  LET cCodRet= iSqlErr;				
				IF iSqlErr = -535 THEN
					COMMIT WORK;
				END IF;
			 RETURN cCodRet;
		   END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)			
			COMMIT WORK;			
		END EXCEPTION WITH RESUME;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--ACTUALIZA LAS ESTADÃSTICAS DE OPTIMIZACIÃN DE CONSULTA PARA LA TABLA DE TRABAJO "SD_REP_MEN_INC_AUTO_NOAPLI".
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_noapli;
		
		--CONTROL DE PARÃMETROS.
		SELECT fecha_hoy
		INTO dtFecha_hoy
		FROM "informix".sd_fechas
		WHERE empresa = '001';		
				
		--SE VALIDAN LOS PARAMETRO Y SIN ALGUNO VIENE VACIO NO SE PUEDE EJECUTAR EL SP.
		IF NVL(pFecha,'') = '' OR NVL(pModo,'') = '' THEN
			LET cCodRet = '000001';			RETURN cCodRet ;
		END IF;
		
		--SE VALIDA SI LA FECHA PARAMETRO ES MAYOR A LA FECHA HOY.
		IF pFecha > dtFecha_hoy THEN 
			LET cCodRet = '000002';			RETURN cCodRet ;
		END IF;
		
		--VALIDA EL VALOR DE LA MODALIDAD.
		IF pModo <> 1 AND pModo <> 2 THEN 			
			LET cCodRet = '000003';			RETURN cCodRet ;
		END IF;
		
		--SE OBTIENE LA RUTA DONDE SE GUARDARA EL REPORTE.
		SELECT valor
		INTO cRuta
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param='050';
					
		--SE OBTIENE EL NUMERO DE REGISTROS POR TRANSACCION.
		SELECT TRIM(valor)::INTEGER
		INTO iNumRegPorTrans
		FROM "informix".sd_param
		WHERE empresa = '001'
			AND cod_param = '052';	
						
		---CALCULOS DE FECHAS
		--SE OBTIENE LA FECHA BASE PARA CALCULAR LOS CREDITOS CON UN AÃO DE ANTIGUEDAD MINIMO.
		EXECUTE PROCEDURE "informix".monthadd(dtFecha_hoy, -12)
		INTO dtAniversarioCred;
		
		--CALCULOS DE FECHAS.
		--SE OBTIENE LA FECHA CON EL MES DEL QUE SE HARÃ EL CORTE.
		IF pModo = 1 THEN 
			EXECUTE PROCEDURE "informix".monthadd(dtFecha_hoy, -1)
			INTO dtFechaMonthAdd;		
			--BORRA LOS DATOS CORRESPONDIENTES A OTRO MES, CON LA MISMA MODALIDAD EN CASO QUE HAYAN QUEDADO EN LA TABLA DE TRABAJO			
			DELETE "informix".sd_rep_men_inc_auto_noapli WHERE (MONTH(fecha)||YEAR(fecha)) <> (MONTH(dtFechaMonthAdd)||YEAR(dtFechaMonthAdd)) AND modalidad = pModo;		
		ELSE 
			LET dtFechaMonthAdd = pFecha;
		END IF;
		
		LET cMes = LPAD((MONTH(dtFechaMonthAdd)),2,'0');
		LET iAnio = YEAR(dtFechaMonthAdd);		
		
		--SE OBTIENE EL PRIMER Y ULTIMO DIA DE ESE MES
		EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes,iAnio)
		INTO cCodRetSpPrimero, dtPrimerDiaMes, dtUltimoDiaMes;		
		
		FOREACH WITH HOLD			
			--SE CUENTAN LOS CREDITOS A LOS CUALES NO SE LES APLICO EL INCREMENTO.
			SELECT b.fecha_apertura,COUNT(*) AS RegistrosNoIncrementados
			INTO dtFecha,iRegistrosNoIncrementados
			FROM "informix".sd_bitacora_aumlincred a
				INNER JOIN "informix".sd_maecred b ON (b.empresa =  a.empresa AND b.num_credito = a.num_solicitud )
				INNER JOIN bdisolic:"informix".ss_solicitudes c ON(c.empresa =  a.empresa AND  a.num_solicitud = c.num_solicitud AND c.ajuste_de_cuota =  'S') 
			WHERE a.fecha_status BETWEEN dtPrimerDiaMes AND dtUltimoDiaMes			
			AND a.status <> 'AP'
			AND a.origen = 'C'
			AND  a.empresa = '001'
			AND b.fecha_apertura <= dtAniversarioCred				
			GROUP BY  b.fecha_apertura
			ORDER BY b.fecha_apertura ASC

			IF NOT EXISTS (SELECT {+INDEX("informix".sd_rep_men_inc_auto_noapli idx_rep_autonoapli)} fecha FROM "informix".sd_rep_men_inc_auto_noapli WHERE fecha = dtFecha AND modalidad = pModo ) THEN 				
					--SE INCREMENTA CONTADOR DE INSERCIONES.
				LET iContador = iContador + 1;
				--SI ES EL INICIO SE ABRE TRANSACCION.
				IF iContador = 1 THEN
					BEGIN WORK;							
				END IF;				
				--SE INSERTA LA INFORMACION OBTENIDA DEL QUERY PRINCIPAL.
				INSERT INTO "informix".sd_rep_men_inc_auto_noapli (fecha, reg_no_incre, modalidad) VALUES (dtFecha,NVL(iRegistrosNoIncrementados,0),pModo);
				--SE INICIALIZAN VARIABLES.
				LET dtFecha = DATE(1);
				LET iRegistrosNoIncrementados = 0;													
			ELSE 
				LET iContador = iContador + 1;				
				IF iContador = 1 THEN
					BEGIN WORK;							
				END IF;
				--SE ACTUALIZA LA INFORMACION OBTENIDA DEL QUERY PRINCIPAL EN LA TABLA DE TRABAJO.
				UPDATE "informix".sd_rep_men_inc_auto_noapli SET reg_no_incre = (reg_no_incre + iRegistrosNoIncrementados) WHERE fecha = dtFecha AND modalidad = pModo;
				--SE INICIALIZAN VARIABLES.
				LET dtFecha = DATE(1);
				LET iRegistrosNoIncrementados = 0;	
			END IF;
			--SI YA SE CUMPLEN LAS N TRANSACCIONES SE CIERRA LA TRANSACCION Y SE INICIALIZA EL CONTADOR.
			IF iContador = iNumRegPorTrans THEN
				COMMIT WORK;							
				LET iContador = 0;
			END IF;			
		END FOREACH
		
		--SE VALIDA SI SE QUEDO ABIERTA UNA TRANSACCION.
		IF iContador > 0 THEN 		
			COMMIT WORK;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000004';			RETURN cCodRet ;				
		END IF;
							
		--SE INICIALIZAN LAS VARIABLES PARA REUTILIZARLAS.
		LET cMes = '';
		LET iAnio = 0;
		--SE ARMA EL TITULO DEL REPORTE.			
		
		LET cDia = LPAD((DAY(dtFecha_hoy)),2,'0');
		LET cMes = LPAD((MONTH(dtFecha_hoy)),2,'0');
		LET iAnio = YEAR(dtFecha_hoy);
		
		LET cTitulo = TRIM(cDia)||TRIM(cMes)||iAnio;
		LET cTitulo = TRIM(cTitulo);
		
		--SE HACE UPDATE STATISTICS ANTES DE LA CONSULTA,PARA ACTUALIZAR LAS ESTADÃSTICAS DE OPTIMIZACIÃN DE CONSULTA PARA LA TABLA DE TRABAJO "SD_REP_MEN_INC_AUTO_NOAPLI".
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_rep_men_inc_auto_noapli;
				
		--VACIADO A ARCHIVO TXT.
		IF pModo= '1' THEN
			LET cSql = 'echo "Fecha|Registros no Incrementados" >' || TRIM(cRuta) || '/ReporteNoAplicadoshead_'||TRIM(cTitulo)||'.txt';
			LET cSql = TRIM(cSql);
			SYSTEM cSql;

			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO "'||TRIM(cRuta)||'"/ReporteNoAplicadosbody_"'||TRIM(cTitulo)||'".txt   SELECT {+INDEX("informix".sd_rep_men_inc_auto_noapli idx_rep_autonoapli)} fecha, reg_no_incre FROM "informix".sd_rep_men_inc_auto_noapli WHERE fecha = fecha AND modalidad = "'||TRIM(pModo)||'" ;">  "'||TRIM(cRuta)||'"/body3.sql'; 
			SYSTEM cSql; 

			LET cSql= 'dbaccess bdicred  "'||TRIM(cRuta)||'"/body3.sql';
			SYSTEM cSql; 
			
			LET cSql = '';		
			LET cSql = 'cat '||TRIM(cRuta)||'/ReporteNoAplicadoshead_'||TRIM(cTitulo)||'.txt '||TRIM(cRuta)||'/ReporteNoAplicadosbody_'||TRIM(cTitulo)||'.txt > '||TRIM(cRuta)||'/ReporteNoAplicados_'||TRIM(cTitulo)||'.txt';
		
			LET cSql = TRIM(cSql);
			SYSTEM cSql;
			
			--COMANDO REMOVE.
			LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteNoAplicadoshead_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 
			
			LET cSql= 'rm "'||TRIM(cRuta)||'"/ReporteNoAplicadosbody_'||TRIM(cTitulo)||'.txt';		
			SYSTEM cSql; 
						
			LET cSql= 'rm "'||TRIM(cRuta)||'"/body3.sql';		
			SYSTEM cSql; 

			--SE BORRA TODA LA INFORMACION DE LA TABLA DE TRABAJO POR EL FILTRO DE MODALIDAD.
			DELETE {+INDEX("informix".sd_rep_men_inc_auto_noapli idx_rep_autonoapli)} "informix".sd_rep_men_inc_auto_noapli WHERE fecha = fecha AND modalidad = pModo;		
	
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que se puede ejecutar de modo mensual (1) o historico (2) para calculo de los incrementos no aplicados',
'AUTOR: Carlos Ochoa',
'FECHA: Junio de  2013',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_actualizar_bitacora_pba(pEmpresa char(3))
returning char(06) AS codret,
          char(80) AS mensaje;


--definicion de variables
--DEFINE pEmpresa char(3);
DEFINE cMensajeRet  CHAR(80);
DEFINE cNumproducto char(4);
DEFINE cNumCredito, cNumCte char(20);
DEFINE dFechaHoy date;
DEFINE cMesesVencidos Integer;
DEFINE fSaldoMesActual decimal(14,2);
DEFINE mIntVencido_ord, mIvaIntVencido_ord decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE cNombreArchivo1 CHAR(100);
DEFINE pMonto_otorgado decimal(14,2);
DEFINE sFechadeCorte, cFechaApertura date;
DEFINE utili_80, vmotivo_exclusion  smallint;
DEFINE vfechaexclusion,vfecha_alta date;
DEFINE vcodret char(6);
DEFINE vmensaje char(80);
DEFINE cNumSucursal char(4);
DEFINE cSql	CHAR(2024);

DEFINE dFechaExclusion date;
DEFINE cStatusCred   CHAR(02);

--SET DEBUG FILE TO '/pisa/ricardo/ventacartera/sp_actualizar_bitacora.out';
--TRACE ON;

--LET pEmpresa = '';
LET cMensajeRet  = '' ;
LET cNumProducto, cNumCredito, cNumCte = '', '', '';
LET mIntVencido_ord, mIvaIntVencido_ord= 0,0;
LET pMonto_otorgado = 0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET utili_80, vmotivo_exclusion  = 0, 0;
LET vfechaexclusion = "";
LET P_COD_RET = '000000';
LET vfecha_alta = null;
LET cNumSucursal = '0000';
    LET cNombreArchivo1= '/resplogifx/archivoscartera/bitacora_exclusiones_vta' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';
LET cSql="";
LET dFechaExclusion =date(1);
LET cStatusCred = '';

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			IF SQL_ERR != 0 THEN
                LET vcodret = SQL_ERR;
                LET vmensaje = 'ERROR en la ejecución del REPORTE DE EXCEPCIONES VENTA CARTERA';
			END IF;
			RETURN vcodret,vmensaje;
	END EXCEPTION;

    select max(fecha_exclusion) into dFechaExclusion
    from bdicred:sd_exclusiones_ventacartera;


	FOREACH WITH hold

		SELECT {+INDEX(sd_exclusiones_ventacartera idx_fecha_exclusion)} num_producto, num_credito, numcte, motivo_exclusion
		INTO cNumProducto, cNumCredito, cNumCte, vmotivo_exclusion
		FROM bdicred:sd_exclusiones_ventacartera
        WHERE date(fecha_exclusion) = dFechaExclusion

		IF  cNumProducto = '6001' then


	--monto_otorgado y meses vencidos
			SELECT monto_otorgado, mto_fin_ven_trasp
			INTO pMonto_otorgado, cMesesVencidos
			FROM bdicred:sd_maesdos
			WHERE empresa  ='001'
			AND num_credito = cNumCredito;

	--Para saldo_actual
			SELECT
			NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual
			FROM bdicred:sd_maesdos b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito;

	--para intereses
	-- Se obtiene los Intereses orden
			SELECT d.int_tra_no_exig
			INTO mIntVencido_ord
			FROM bdicred:sd_maesdos d
			WHERE d.empresa= pEmpresa
			AND d.num_credito= cNumCredito;

    --  Se obtiene el Iva de los Intereses Vigentes
			SELECT SUM(iva_debe - iva_pagado)
			INTO mIvaIntVencido_ord
			FROM sd_amortiza_credito d
			WHERE d.empresa = pEmpresa
			AND d.num_credito = cNumCredito
			AND capital_status IN ('1','2','7');

	--fecha apertura

			SELECT NVL(fecha_apertura,date(1))
			INTO   cFechaApertura
			FROM sd_maecred b
			WHERE b.empresa = pEmpresa
			AND b.num_credito = cNumCredito;

	--reestructuras
        ELSE


	--monto_otorgado
			SELECT monto_otorgado, mto_fin_ven_trasp
			INTO pMonto_otorgado, cMesesVencidos
			FROM bdicred:sd_maesdoscrd
			WHERE empresa  ='001'
			AND num_credito = cNumCredito;

	--Para saldo_actual
			SELECT
			NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito;

	--intereses
	--balanza
				IF cNumProducto = '6011' THEN
                    IF cStatusCred = 'BT' THEN

                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
                        INTO mIntVencido_bal, mIvaIntVencido_bal
                        from bdicred:sd_amortiza_creditocrd
                        where empresa = pEmpresa
                        and num_credito = cNumCredito
                        and capital_status in ('2','7')
                        and fecha_cuota <= (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');

    --orden
                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
                        INTO mIntVencido_ord, mIvaIntVencido_ord
                        from bdicred:sd_amortiza_creditocrd
                        where empresa = pEmpresa
                        and num_credito = cNumCredito
                        and capital_status in ('2','7')
                        and fecha_cuota > (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');
                    ELSE
                        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                        INTO mIntVencido_ord, mIvaIntVencido_ord
                        FROM bdicred:sd_amortiza_creditocrd
                        WHERE empresa = pEmpresa
                        AND num_credito= cNumCredito
                        AND capital_status in ('2','7');
                    END IF;

				ELIF cNumProducto = '6300' THEN
            --balanza
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
					INTO mIntVencido_bal, mIvaIntVencido_bal
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCredito
					and capital_status in ('2','7')
					and fecha_cuota <= (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
            --orden
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
					INTO mIntVencido_ord, mIvaIntVencido_ord
					from bdicred:sd_amortiza_creditocrd
					where empresa = pEmpresa
					and num_credito = cNumCredito
					and capital_status in ('2','7')
					and fecha_cuota > (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
				END IF;
	--fecha apertura

			SELECT sucursal, NVL(fecha_apertura,date(1))
			INTO cNumSucursal, cFechaApertura
			FROM sd_maecredcrd b
			WHERE b.empresa = pEmpresa
			AND b.num_credito = cNumCredito;

		END IF;

	--fecha manteniemiento

			IF vmotivo_exclusion = '13' then
				select limit 1 date(fecha_alta)
				into vfecha_alta
				from bdinteg:si_huella_temp a where a.numcte = cNumCte
				and a.secuencia = (select max(secuencia)
				from bdinteg:si_huella_temp b where b.numcte = a.numcte)
				and status = 'M';
			END IF;

		--meses de utilizacion
			Select count(*) into utili_80
			from bdicred:"informix".sd_hist_reserva
			where empresa = '001' 
			and num_credito  = cNumCredito and fecha_cierre >= date(1)
--			and num_credito  = cNumCredito and fecha_cierre = mdy(month(dFechaExclusion),1,year(dFechaExclusion)) - 1 units day
			and porcentaje_uso >= 80;


			UPDATE bdicred:sd_exclusiones_ventacartera set linea_credito = pMonto_otorgado , saldo_actual = fSaldoMesActual,
			int_vencido_ord = mIntVencido_ord, iva_int_vencido_ord = mIvaIntVencido_ord, int_vencido_bal = mIntVencido_bal,
			iva_int_vencido_bal = mIvaIntVencido_bal, meses_vencidos = cMesesVencidos, fecha_apertura = cFechaApertura,
			fecha_mantenimiento = vfecha_alta, meses_utilizacion = utili_80
			WHERE fecha_exclusion = dFechaExclusion and num_credito  = cNumCredito and empresa = '001';

            LET cStatusCred = '';
            LET vfecha_alta = null;
            let mIntVencido_ord = 0;
            let mIvaIntVencido_ord = 0;
            let mIntVencido_bal = 0;
            let mIvaIntVencido_bal = 0;

	END FOREACH;

--Generacion de bitacora_exclusiones_vta
			  LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
								' a.num_producto, ' ||
								' a.num_credito, ' ||
                                ' a.numcte, ' ||
                                ' a.fecha_exclusion, ' ||
								' (select trim(descripcion) from sd_cat_exclusiones_vc where empresa="001" and codigo_exclusion = a.motivo_exclusion), ' ||
								' a.linea_credito, ' ||
								' a.saldo_actual, ' ||
								' a.int_vencido_ord, ' ||
								' a.iva_int_vencido_ord, ' ||
								' a.int_vencido_bal, ' ||
								' a.iva_int_vencido_bal, ' ||
								' a.meses_vencidos, ' ||
								' a.fecha_apertura, ' ||
                                '  nvl(a.fecha_mantenimiento,'''||' '||'''), ' ||
--								' (case when a.fecha_mantenimiento = date(1) then '' else a.fecha_mantenimiento end), ' ||
								' a.meses_utilizacion ' ||
--                                ' FROM bdicred:sd_exclusiones_ventacartera a where month(fecha_exclusion) = month(today - 1 units month) ' ||
                                ' FROM bdicred:sd_exclusiones_ventacartera a ' ||
								' WHERE date(fecha_exclusion) = ''' || dFechaExclusion || ''' ; ' ||
--								' and year(fecha_exclusion) = year(today - 1 units month)' ||
                                '" > /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl > " || cNombreArchivo1;
              SYSTEM cSql;

              LET cSql = '';

--              LET cSQL = 'rm /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.sql /resplogifx/archivoscartera/bitacoraexclusiones_ventacartera.unl';
              SYSTEM cSql;


			LET cMensajeRet = 'El proceso REPORTE DE EXCEPCIONES VENTA CARTERA terminó exitosamente';
			LET P_COD_RET = '000000';

			RETURN P_COD_RET,cMensajeRet;
END;
END PROCEDURE;