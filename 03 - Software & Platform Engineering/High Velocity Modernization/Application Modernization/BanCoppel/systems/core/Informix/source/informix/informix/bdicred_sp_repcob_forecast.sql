CREATE PROCEDURE "informix".sp_repcob_forecast()
	-- DATOS A REGRESAR
	RETURNING
		CHAR(6)  AS CodRet;
		
		
	-- DEFINICION DE VARIABLES 
    DEFINE iSqlErr              INTEGER;
	
  DEFINE cCodRet,vvcCod_ret   CHAR(6);
	DEFINE dtFechaHoy, dtFechaCorteIniHis, dtFechaCorteFinHis           DATE;
	DEFINE sOrigen				SMALLINT;
	DEFINE sDia					SMALLINT;
	DEFINE iConvRealizados		INTEGER;
	DEFINE dMontoPagSembrado	DECIMAL(18,2);
	DEFINE iConvCumplidos		INTEGER;
	DEFINE dMontoPagConv		DECIMAL(18,2);
	DEFINE dEfectConv			DECIMAL(18,2);
	DEFINE dEfectPagos			DECIMAL(18,2);
	
	DEFINE cTblOrig1			CHAR(1);
	DEFINE cTblOrig2			CHAR(1);
	DEFINE cTblOrig3			CHAR(1);
	DEFINE iCompDIA				INTEGER;
	DEFINE iDiaStart			INTEGER;
	DEFINE iDiaFin				INTEGER;
	DEFINE iCodParam			INTEGER;
	DEFINE cNombreArchivo	  	CHAR(80); 
	DEFINE cRuta		      	CHAR(80);
	DEFINE cNomTabla		  	CHAR(80);
	DEFINE cConsulta		  	CHAR(2200);
	DEFINE cSql           		CHAR(1024);
	DEFINE iTotConvRealizados	INTEGER;
	DEFINE iTotConvCumplidos	INTEGER;
	DEFINE dTotMontoPagSembrado	DECIMAL(18,2);
	DEFINE dTotMontoPagConv		DECIMAL(18,2);
	DEFINE v_empresa       CHAR(3);
	DEFINE cProceso        CHAR(4);
	DEFINE cMensajeRet			CHAR(80);
	DEFINE iIsamErr				INTEGER;
		
	-- INICIALIZACION DE VARIABLES
    LET iSqlErr                 = 0;
	
    LET cCodRet                 = "000000";
	LET dtFechaHoy = DATE(1); LET dtFechaCorteIniHis = DATE(1);    LET dtFechaCorteFinHis = DATE(1);
	LET sOrigen					= 0;
	LET sDia					= 0;
	LET iConvRealizados			= 0;
	LET dMontoPagSembrado		= 0.00;
	LET iConvCumplidos			= 0;
	LET dMontoPagConv			= 0.00;
	LET dEfectConv				= 0.00;
	LET dEfectPagos				= 0.00;
	
	LET cTblOrig1				= "";
	LET cTblOrig2				= "";
	LET cTblOrig3				= "";
	LET iCompDIA				= 1;
	LET iDiaStart				= 1;
	LET iDiaFin					= 1;
	LET iCodParam				= 1;
	LET cNombreArchivo			= "";
	LET cRuta					= "";
	LET cNomTabla				= "";
	LET cConsulta				= "";
	LET cSql					= "";
	LET iTotConvRealizados		= 0;
	LET iTotConvCumplidos		= 0;
	LET dTotMontoPagSembrado	= 0.00;
	LET dTotMontoPagConv		= 0.00;
	LET v_empresa = '001';
	LET cProceso = '0075';
  LET vvcCod_ret = '';
  LET cMensajeRet		= "Proceso Exitoso";
  LET iIsamErr     	= 0;
    
  --2013-01-06
  --By MACF. Se modifica para quitar la validación en caso de que no exista información, no es necesario que regrese el código 000001.
    
BEGIN
	
    ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
        IF iSqlErr <> 0 THEN
    			-- BORRAMOS LAS TABLAS TEMPORALES.
    			IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN1" AND dbsname= "bdicred" AND partnum >1048577) THEN
    				DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN1;
    			END IF;
    			
    			IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN2" AND dbsname= "bdicred" AND partnum >1048577) THEN
    				DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN2;
    			END IF;
    			
    			IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN3" AND dbsname= "bdicred" AND partnum >1048577) THEN
    				DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN3;
    			END IF;
    			
          LET cCodRet = iSqlErr;
          
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
          
    			RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/sp_repcob_forecast.out";
	-- TRACE ON;
	
	-- INICIALMENTE BORRAMOS LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN1" AND dbsname= "bdicred" AND partnum >1048577) THEN
			DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN1;
		END IF;
		
		IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN2" AND dbsname= "bdicred" AND partnum >1048577) THEN
			DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN2;
		END IF;
		
		IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_FORECASTORIGEN3" AND dbsname= "bdicred" AND partnum >1048577) THEN
			DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN3;
		END IF;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
	
	-- CONSULTAMOS LA FECHA ACTUAL.
	SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
	
	-- LET dtFechaHoy = '01/02/2014';  --- Test MACF 
	
	LET iDiaFin = DAY(dtFechaHoy - 1 UNITS DAY); -- SACAMOS EL VALOR DEL DIA FINAL QUE SE VA A GENERAR EL REPORTE.
	
	--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.							
		IF DAY(dtFechaHoy) = 1 THEN
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaCorteFinHis),1,YEAR(dtFechaCorteFinHis));
		ELIF DAY(dtFechaHoy) = 2 THEN
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
    ELSE
       LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
       LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		END IF;
	
	
	FOREACH
		SELECT origen, DAY(fecha_compac), COUNT(fecha_compac), SUM(importe), SUM(flag_pago::INTEGER), SUM(imp_pagado), 
				--ROUND(SUM(flag_pago::INTEGER)/COUNT(fecha_compac)*100,2), ROUND((SUM(imp_pagado)/SUM(importe))/100,2)
				ROUND(SUM(flag_pago::INTEGER)/COUNT(fecha_compac)*100,2), ROUND((SUM(imp_pagado)/SUM(importe))*100,2)    --by MACF
		INTO sOrigen, sDia, iConvRealizados, dMontoPagSembrado, iConvCumplidos, dMontoPagConv, dEfectConv, dEfectPagos
		FROM bdicobranza:"informix".cb_compac_his
		WHERE fecha_compac >= dtFechaCorteIniHis   --MDY(MONTH(dtFechaHoy),01,YEAR(dtFechaHoy))
		  AND fecha_compac <= dtFechaCorteFinHis   --(dtFechaHoy - 1 UNITS DAY)
		GROUP BY origen, fecha_compac
		ORDER BY 1, 2
		
		IF dEfectConv > 100.00 THEN LET dEfectConv = 100.00; END IF;  --by MACF
		IF dEfectPagos > 100.00 THEN LET dEfectPagos = 100.00; END IF;  --by MACF
		
		IF NVL(sOrigen,0) = 1 THEN
			IF cTblOrig1 <> 'S' THEN -- VALIDAMOS SI YA FUE CREADA LA TABLA TEMPORAL.
				-- SE CREA LA TEMPORAL PARA GENERAR EL REPORTE DE TIPO ORIGEN 1
				CREATE TABLE bdicred:"informix".TMP_FORECASTORIGEN1(Dia CHAR(30), ConvRealizados CHAR(30), MontoPagSembrado CHAR(30), 
																	 ConvCumplidos CHAR(30), MontoPagConv CHAR(30), EfectConv CHAR(30),
																	 EfectPagos CHAR(30) );
																		 
				-- INSERTAMOS LA CABECERA DEL ARCHIVO TEMPORAL.
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", "FORECAST MENSUAL", "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", DAY(dtFechaHoy)||'/'||MONTH(dtFechaHoy)||'/'||YEAR(dtFechaHoy) , "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("Dia", "Convenios Realizados", "Monto de pago sembrado", "Convenios Cumplidos", "Monto pagado de convenios", "Efectividad de convenios", "Efectividad de pago");
				
				-- VARIBLE DE CONTROL DE LA TABLA TEMPORAL.
				LET cTblOrig1 = 'S';
			END IF;
			
			FOR iCompDIA = iDiaStart TO iDiaFin
				IF iCompDIA = sDia THEN
					-- INSERTAMOS LOS VALORES DE CONTENIDO DEL REPORTE.
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (sDia::CHAR(30), iConvRealizados::CHAR(30), '$'||dMontoPagSembrado::CHAR(30),iConvCumplidos::CHAR(30), '$'||dMontoPagConv::CHAR(30), dEfectConv||'%'::CHAR(30), dEfectPagos||'%'::CHAR(30));
					
					LET iDiaStart = iCompDIA + 1;
					EXIT FOR;
				ELSE
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
				END IF
			END FOR
			
		ELIF NVL(sOrigen,0) = 2 THEN
		
			IF cTblOrig2 <> "S" THEN -- VALIDAMOS SI YA FUE CREADA LA TABLA TEMPORAL.
				-- SE CREA LA TEMPORAL PARA GENERAR EL REPORTE DE TIPO ORIGEN 2
				CREATE TABLE bdicred:"informix".TMP_FORECASTORIGEN2(Dia CHAR(30), ConvRealizados CHAR(30), MontoPagSembrado CHAR(30), 
																	 ConvCumplidos CHAR(30), MontoPagConv CHAR(30), EfectConv CHAR(30),
																	 EfectPagos CHAR(30) );
																		 
				-- INSERTAMOS LA CABECERA DEL ARCHIVO TEMPORAL.
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", "FORECAST MENSUAL", "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", DAY(dtFechaHoy)||'/'||MONTH(dtFechaHoy)||'/'||YEAR(dtFechaHoy) , "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("Dia", "Convenios Realizados", "Monto de pago sembrado", "Convenios Cumplidos", "Monto pagado de convenios", "Efectividad de convenios", "Efectividad de pago");
				
				IF cTblOrig1 = "S" THEN -- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_CALLE HASTA EL DIA FINAL.
					IF iDiaStart <= iDiaFin THEN
						FOR iCompDIA = iDiaStart TO iDiaFin
							INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
							VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
						END FOR
					END IF
				END IF
				
				-- INICIALIZAMOS LAS VARIABLES DE CONTROL DE REGISTROS DEL REPORTE
				LET iCompDIA	= 1;
				LET iDiaStart	= 1;
				
				-- VARIBLE DE CONTROL DE LA TABLA TEMPORAL.
				LET cTblOrig2 = "S";
			END IF;
			
			FOR iCompDIA = iDiaStart TO iDiaFin
				IF iCompDIA = sDia THEN
					-- INSERTAMOS LOS VALORES DE CONTENIDO DEL REPORTE.
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (sDia::CHAR(30), iConvRealizados::CHAR(30), '$'||dMontoPagSembrado::CHAR(30),iConvCumplidos::CHAR(30), '$'||dMontoPagConv::CHAR(30), dEfectConv||'%'::CHAR(30), dEfectPagos||'%'::CHAR(30));
					
					LET iDiaStart = iCompDIA + 1;
					EXIT FOR;
				ELSE
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
				END IF
			END FOR
			
		ELIF NVL(sOrigen,0) = 3 THEN
		
			IF cTblOrig3 <> "S" THEN -- VALIDAMOS SI YA FUE CREADA LA TABLA TEMPORAL.
				-- SE CREA LA TEMPORAL PARA GENERAR EL REPORTE DE TIPO ORIGEN 3
				CREATE TABLE bdicred:"informix".TMP_FORECASTORIGEN3(Dia CHAR(30), ConvRealizados CHAR(30), MontoPagSembrado CHAR(30), 
																	 ConvCumplidos CHAR(30), MontoPagConv CHAR(30), EfectConv CHAR(30),
																	 EfectPagos CHAR(30) );
																		 
				-- INSERTAMOS LA CABECERA DEL ARCHIVO TEMPORAL.
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", "FORECAST MENSUAL", "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("", "", "", DAY(dtFechaHoy)||'/'||MONTH(dtFechaHoy)||'/'||YEAR(dtFechaHoy) , "", "", "");
				
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES ("Dia", "Convenios Realizados", "Monto de pago sembrado", "Convenios Cumplidos", "Monto pagado de convenios", "Efectividad de convenios", "Efectividad de pago");
				
				IF cTblOrig2 = "S" THEN -- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_SUC HASTA EL DIA FINAL.
					IF iDiaStart <= iDiaFin THEN
						FOR iCompDIA = iDiaStart TO iDiaFin
							INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
							VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
						END FOR
					END IF
					
					-- INICIALIZAMOS LAS VARIABLES PARA NO CARGAR REGISTROS DE MAS AL REPORTE REPCOB_FORECAST_MENS_CALLE
					LET iCompDIA	= iDiaFin + 1;
					LET iDiaStart	= iDiaFin + 1;
				END IF
				
				IF cTblOrig1 = "S" THEN -- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_CALLE HASTA EL DIA FINAL.
					IF iDiaStart <= iDiaFin THEN
						FOR iCompDIA = iDiaStart TO iDiaFin
							INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
							VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
						END FOR
					END IF
				END IF
				
				-- INICIALIZAMOS LAS VARIABLES DE CONTROL DE REGISTROS DEL REPORTE
				LET iCompDIA	= 1;
				LET iDiaStart	= 1;
				
				-- VARIBLE DE CONTROL DE LA TABLA TEMPORAL.
				LET cTblOrig3 = "S";
			END IF;
			
			FOR iCompDIA = iDiaStart TO iDiaFin
				IF iCompDIA = sDia THEN
					-- INSERTAMOS LOS VALORES DE CONTENIDO DEL REPORTE.
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (sDia::CHAR(30), iConvRealizados::CHAR(30), '$'||dMontoPagSembrado::CHAR(30),iConvCumplidos::CHAR(30), '$'||dMontoPagConv::CHAR(30), dEfectConv||'%'::CHAR(30), dEfectPagos||'%'::CHAR(30));
					
					LET iDiaStart = iCompDIA + 1;
					EXIT FOR;
				ELSE
					INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
					VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
				END IF
			END FOR
			
		END IF
	
	END FOREACH;
	
	/* 2013-01-06
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000001";  -- NO EXISTEN CONVENIOS REALIZADOS EN LA FECHA ACTUAL.
		RETURN cCodRet;
	END IF;	
	*/
	
 	-- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_CAT HASTA EL DIA FINAL.
	IF cTblOrig3 = "S" THEN
		IF iDiaStart <= iDiaFin THEN
			FOR iCompDIA = iDiaStart TO iDiaFin
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
			END FOR
		END IF
		-- INICIALIZAMOS LAS VARIABLES PARA NO CARGAR REGISTROS DE MAS AL REPORTE REPCOB_FORECAST_MENS_SUC
		LET iCompDIA	= iDiaFin + 1;
		LET iDiaStart	= iDiaFin + 1;
	END IF
	
 	-- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_SUC HASTA EL DIA FINAL.
	IF cTblOrig2 = "S" THEN
		IF iDiaStart <= iDiaFin THEN
			FOR iCompDIA = iDiaStart TO iDiaFin
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
			END FOR
		END IF
		-- INICIALIZAMOS LAS VARIABLES PARA NO CARGAR REGISTROS DE MAS AL REPORTE REPCOB_FORECAST_MENS_CALLE
		LET iCompDIA	= iDiaFin + 1;
		LET iDiaStart	= iDiaFin + 1;
	END IF
	
 	-- COMPLETAMOS EL REPORTE REPCOB_FORECAST_MENS_CALLE HASTA EL DIA FINAL.
	IF cTblOrig1 = "S" THEN
		IF iDiaStart <= iDiaFin THEN
			FOR iCompDIA = iDiaStart TO iDiaFin
				INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
				VALUES (iCompDIA, "0", "$0", "0", "$0", "0.00%", "0.00%");
			END FOR
		END IF
	END IF
	
	-- AGREGAMOS LAS SUMAS Y GENERAMOS LOS REPORTES POR CADA ORIGEN.
	FOREACH
		SELECT DISTINCT(origen), COUNT(fecha_compac), SUM(importe), SUM(flag_pago::INTEGER), SUM(imp_pagado)
		INTO sOrigen, iTotConvRealizados, dTotMontoPagSembrado, iTotConvCumplidos, dTotMontoPagConv
		FROM bdicobranza:"informix".cb_compac_his
		WHERE fecha_compac >= MDY(MONTH(dtFechaHoy),01,YEAR(dtFechaHoy))
		  AND fecha_compac <= (dtFechaHoy - 1 UNITS DAY)
		GROUP BY origen
		
		IF NVL(sOrigen,0) = 1 THEN
			-- INSERTAMOS LA SUMA DE LOS TOTALES DEL CONTENIDO DE CADA REPORTE.
			INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN1(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
			VALUES ("Total", iTotConvRealizados::CHAR(30), '$'||dTotMontoPagSembrado::CHAR(30),iTotConvCumplidos::CHAR(30), '$'||dTotMontoPagConv::CHAR(30), "", "");
			
			LET iCodParam = 75;		LET cNomTabla = "TMP_FORECASTORIGEN1";
		ELIF NVL(sOrigen,0) = 2 THEN
			-- INSERTAMOS LA SUMA DE LOS TOTALES DEL CONTENIDO DE CADA REPORTE.
			INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN2(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
			VALUES ("Total", iTotConvRealizados::CHAR(30), '$'||dTotMontoPagSembrado::CHAR(30),iTotConvCumplidos::CHAR(30), '$'||dTotMontoPagConv::CHAR(30), "", "");
			
			LET iCodParam = 76;		LET cNomTabla = "TMP_FORECASTORIGEN2";
		ELIF NVL(sOrigen,0) = 3 THEN
			-- INSERTAMOS LA SUMA DE LOS TOTALES DEL CONTENIDO DE CADA REPORTE.
			INSERT INTO bdicred:"informix".TMP_FORECASTORIGEN3(Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos)
			VALUES ("Total", iTotConvRealizados::CHAR(30), '$'||dTotMontoPagSembrado::CHAR(30),iTotConvCumplidos::CHAR(30), '$'||dTotMontoPagConv::CHAR(30), "", "");
			
			LET iCodParam = 77;		LET cNomTabla = "TMP_FORECASTORIGEN3";
		END IF
		
		-- SE OBTIENE EL NOMBRE DEL ARCHIVO DE LA CANTIDAD DE CONVENIOS ACTIVADOS POR CAMPAÑA POR DIA.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = iCodParam;	
		
		IF NVL(cNombreArchivo,'') = '' THEN
			LET cCodRet = "000002";  -- NO SE ENCUENTRA EL PARAMETRO DEL NOMBRE DEL ARCHIVO.
			RETURN cCodRet;
		END IF;	
		
		-- SE OBTIENE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
		  AND grupo_parametro = "RUTAS" 
		  AND num_parametro = 1;
		
		IF NVL(cRuta,'') = '' THEN
			LET cCodRet = "000003";  -- NO SE ENCUENTRA EL PARAMETRO DE LA RUTA DEL APLICATIVO.
			RETURN cCodRet;
		END IF;	
		
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Dia, ConvRealizados, MontoPagSembrado, ConvCumplidos, MontoPagConv, EfectConv, EfectPagos FROM bdicred:'informix'."||cNomTabla;
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
	END FOREACH;
	
	-- BORRAMOS LAS TABLAS TEMPORALES.
	IF cTblOrig1 = "S" THEN
		DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN1;
	END IF
	
	IF cTblOrig2 = "S" THEN
		DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN2;
	END IF
	
	IF cTblOrig3 = "S" THEN
		DROP TABLE bdicred:"informix".TMP_FORECASTORIGEN3;
	END IF

  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
	
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Generamos 3 reportes de Convenios Realizados "Forecast Mensual"',
'AUTOR : Valentin López',
'FECHA : 12/Noviembre/2012',
'BD    : bdicred',
'VERSION: 12112012.1223';

CREATE PROCEDURE "informix".sp_cambia_amortizacrd_pp(p_fecha_alta_apoyo date)
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,              
              CHAR(25) AS StorePro,
              CHAR(20) AS prestamo;              
              

   DEFINE vsqlerr           INTEGER; 

   DEFINE v_codigo_retorno	CHAR(5);
   DEFINE v_mensaje	  	    CHAR(80);
   DEFINE v_store_pro       CHAR(25);
   DEFINE vc_prestamo       char(20);
  
   DEFINE vc_num_credito  CHAR(20);
   DEFINE vd_fecha_cuota DATE;
   DEFINE vd_fecha_cuota_new DATE;
   DEFINE vd_fecha_alta_apoyo DATE;
   DEFINE vd_fecha_vencim12 DATE;
   DEFINE vd_fecha_vencim12_new DATE;
   DEFINE vd_fecha_venc_anexo DATE;
   DEFINE vd_fecha_venc_anexo_new DATE;

          --SET debug file TO "/tmp/sp_cambia_amortizacrd_pp.out";
          --TRACE ON;

             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente";
             
             LET v_store_pro = 'sp_cambia_amortizacrd_pp';
             LET vc_num_credito = '';
             let vc_prestamo = '';
             LET vd_fecha_cuota =  DATE(1);
             LET vd_fecha_cuota_new = DATE(1);
             LET vd_fecha_alta_apoyo = p_fecha_alta_apoyo;
             LET vd_fecha_vencim12 = DATE(1);
             LET vd_fecha_vencim12_new = DATE(1);
             LET vd_fecha_venc_anexo = DATE(1);
             LET vd_fecha_venc_anexo_new = DATE(1);
 
            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";            
            LET v_store_pro = 'sp_cambia_amortizacrd_pp';
            LET vc_prestamo = vc_num_credito;
         RETURN v_codigo_retorno, v_mensaje,  v_store_pro, vc_prestamo ;
        END IF;
   END EXCEPTION;


           FOREACH WITH HOLD                                         
                    SELECT num_credito, fecha_vencim
                      INTO vc_num_credito, vd_fecha_vencim12
                      FROM "informix".sd_maecredcrd WHERE empresa = '001' and num_credito in
                          (SELECT a.num_credito FROM "informix".sd_programa_apoyo2013crd a
                                                WHERE fecha_alta = p_fecha_alta_apoyo)
                      AND status_cred <> 'FF'
                   
                        LET vc_prestamo =  vc_num_credito;   

                                SELECT fecha_vencto  --nvl(fecha_vencto,date(1))
                                  INTO vd_fecha_venc_anexo
                                  FROM "informix".sd_maecredanexocrd 
                                 WHERE empresa = '001' 
                                   AND num_credito = vc_num_credito; 

                                SELECT max(fecha_cuota)
                                  INTO  vd_fecha_cuota 
                                  FROM "informix".sd_amortiza_creditocrd
                                 WHERE empresa = '001'
                                   AND num_credito = vc_num_credito;           
                    
                        IF vd_fecha_cuota <>  DATE(1) THEN            
                            CALL "informix".monthadd(vd_fecha_cuota,+3) RETURNING vd_fecha_cuota_new;        --sd_amortizacrd
                            CALL "informix".monthadd(vd_fecha_vencim12,+3) RETURNING vd_fecha_vencim12_new;  --sd_maecredcrd      

                            IF vd_fecha_venc_anexo IS NOT NULL THEN
                                CALL "informix".monthadd(vd_fecha_venc_anexo,+3) RETURNING vd_fecha_venc_anexo_new;  --sd_maecredanexocrd
                            ELSE 
                               LET vd_fecha_venc_anexo_new = vd_fecha_venc_anexo;

                            END IF;     


                                      BEGIN WORK;
                                           UPDATE "informix".sd_amortiza_creditocrd
                                              SET fecha_cuota = vd_fecha_cuota_new                                                  
                                            WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito
                                              AND fecha_cuota = vd_fecha_cuota;                  

                                          UPDATE  "informix".sd_maecredcrd
                                             SET  fecha_pago_cap = vd_fecha_cuota_new,
                                                  fecha_pago_int = vd_fecha_cuota_new,
                                                  fecha_vencim   = vd_fecha_vencim12_new                                                   
                                             WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito;


                                          UPDATE "informix".sd_maecredanexocrd
                                             SET fecha_vencto = vd_fecha_venc_anexo_new                                                                                          
                                             WHERE empresa = '001' 
                                              AND num_credito = vc_num_credito;
        
                                     COMMIT WORK;                                            
                       END IF;               
               
           END FOREACH;                            
                   
                     LET v_codigo_retorno = "00000";
                     LET v_mensaje = "Proceso de Actualizacion, Termino Correctamente!";                     
                     LET v_store_pro = 'sp_cambia_amortizacrd_pp';
                   
      
 END;   --begin      
      RETURN v_codigo_retorno, v_mensaje, v_store_pro, vc_prestamo;

END PROCEDURE;