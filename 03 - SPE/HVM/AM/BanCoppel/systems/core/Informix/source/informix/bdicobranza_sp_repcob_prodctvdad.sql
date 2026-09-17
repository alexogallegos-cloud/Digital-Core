CREATE PROCEDURE "informix".sp_repcob_prodctvdad()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cTabla				CHAR(1);
		DEFINE cSEGM				CHAR(2);
		DEFINE v_empresa			CHAR(3);
		DEFINE cProceso				CHAR(4);
		DEFINE cCodRet, vvcCod_ret	CHAR(6);
		DEFINE cSupervisor			CHAR(8);
		DEFINE cTurno, cFechEnc2	CHAR(10);
		DEFINE cMensajeRet, cRuta, cNombreArchivo	CHAR(80);
		DEFINE vcNombre				VARCHAR(90);
		DEFINE cConsulta			CHAR(2200);
		DEFINE cSql					CHAR(1024);
		DEFINE dtFechaHoy, dtFechaCorteIniHis, dtFechaCorteFinHis	DATE;
		DEFINE dtFechEnc, dtFechaMax, dtFechaMaxCart				DATE;
		DEFINE iLlamRealdas, iLlamRealdas2, iConvAct, iConvAct2, iVolCtasAdm, vefectuo_compac, vcount_empleado			INTEGER;
		DEFINE dLlamExit, dLlamExit_2, dLlamNoExit, dLlamNoExit_2	DECIMAL(14,2);
		DEFINE dEfecNeg, dMontoConv, dMontoConv2, dMontoRecp, dMontoRecp2, dEfecMon, dMeta, dMeta2, dParaMeta, dParaMeta2	DECIMAL(18,2);
		DEFINE dEfecVsMeta, dValCtasAdm, dValCapVencAdm			DECIMAL(18,2);
		DEFINE vcount_empl_tot 		INTEGER;
    		
		---INICIALIZACIONES
		LET iSqlErr            	= 0;
		LET iIsamErr           	= 0;
		LET cCodRet            	= "000000";
		LET cMensajeRet			= "Proceso exitoso";				
		LET cNombreArchivo 		= ""; 					LET cConsulta	 		= ""; 			LET cSql		 		= ""; 		LET cTabla		 		= "N";
		LET cRuta		 		= "";					LET dtFechaHoy          = "";			LET dtFechaCorteIniHis  = "";
		LET dtFechaCorteFinHis  = ""; 					LET cSupervisor	 	    = "";				
		LET vcNombre	 	    = "";					LET cTurno		 	    = ""; 			LET cSEGM		 	    = ""; 		LET dtFechEnc	 	    = "";				
		LET cFechEnc2	 	    = "";   				LET vvcCod_ret 			= ''; 
		LET iLlamRealdas 	    = 0; 					LET iLlamRealdas2 	    = 0;				
		LET dLlamExit  			= 0.00;   				LET dLlamNoExit	 	    = 0.00;   		LET dLlamExit_2	 	    = 0.00;   	LET dLlamNoExit_2	 	= 0.00;
		LET iConvAct	  		= 0;     				LET iConvAct2	 	    = 0;    		LET dEfecNeg	 	    = 0.00; 	LET dMontoConv	 	    = 0.00;				
		LET dMontoConv2			= 0.00;	 				LET dMontoRecp	 	    = 0.00; 		LET dMontoRecp2	 	    = 0.00; 	LET dEfecMon	 	    = 0.00;				
		LET dMeta		 	  	= 0.00;  				LET dMeta2		 	    = 0.00;  		LET dParaMeta	 	    = 0.00; 		LET dParaMeta2	 	= 0.00;				
		LET dEfecVsMeta			= 0.00;  				LET iVolCtasAdm	 	    = 0;  			LET dValCtasAdm	 	    = 0.00;  	LET dValCapVencAdm 	    = 0.00;				
		LET vefectuo_compac 	= 0;
		LET vcount_empleado 	= 0;
		LET vcount_empl_tot 	= 0;
		LET v_empresa 			= '001';
		LET cProceso 			= '0074';
		LET dtFechaMax 			= date(1); 					
		LET dtFechaMaxCart 		= date(1);
    	
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;			  				
				
				IF cTabla="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD;
				END IF;
				
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
        		
			RETURN cCodRet, cMensajeRet;
				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

    IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELPROD" AND dbsname= "bdicred" AND partnum >1048577) THEN
    		DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD;
    END IF;

		--SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_prodctvdad.out";
		--SET DEBUG FILE TO "/informix/macf/sp_repcob_prodctvdad.trc";
		--TRACE ON;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
     				
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = v_empresa;
		
		--LET dtFechaHoy = mdy('02','05','2013');   ---- TEST MACF
		
		SELECT max(fecha_insert) INTO dtFechaMax 
		FROM bdicobranza:"informix".cb_cat_directorio_cte
		WHERE tipo_cobranza = 'A';
		
		SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		FROM bdicobranza:"informix".cb_cat_movimientos
		WHERE tipocobranza = 'A'
		AND DATE(fechacartera) > today - 10;
		
		
		--IF DAY(dtFechaHoy) = 1 THEN 			
		--	LET cCodRet = '000001';
		--	LET cMensajeRet = "No es posible generar el archivo los días primero de cada mes";
		--	RETURN cCodRet, cMensajeRet;
		--END IF 
		 									
		--LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		--LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
    
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

		--SE CALCULA LA FECHA DEL ENCABEZADO DEL ARCHIVO.
		LET dtFechEnc = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		LET cFechEnc2 =  LPAD(DAY(dtFechEnc),2,0)||"/"||LPAD(MONTH(dtFechEnc),2,0)||"/"||YEAR(dtFechEnc);
				
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD(					
																		Supervisor 	CHAR(80),
																		Nombre 		CHAR(80),
																		Turno		CHAR(80),
																		SEGM		CHAR(80),
																		LlamRdas    CHAR(80),
																		LlamExit    CHAR(80),
																		LlamNoExit  CHAR(80),
																		ConvAct     CHAR(80),
																		EfectNeg    CHAR(80),
																		MontConv    CHAR(80),
																		MontRecdo   CHAR(80),
																		EfecMont    CHAR(80),
																		Meta        CHAR(80),
																		PaMeta      CHAR(80),
																		EfecVsMeta  CHAR(80)
																	);			
		LET cTabla="S";		
				 			
		--SE OBTIENE EL VOLUMEN DE CUENTAS C. ADMINISTRATIVA.
		SELECT COUNT(num_credito),NVL(SUM(NVL(pago_minimo,0.00) + (NVL(monto_vencido,0.00) + NVL(mto_venc_trasp,0.00))),0.00),NVL(SUM(NVL(monto_vencido,0.00)),0.00)
		INTO iVolCtasAdm,dValCtasAdm,dValCapVencAdm
		FROM bdicobranza:"informix".cb_cat_directorio_cte
		WHERE tipo_cobranza = 'A'
		AND status_cliente <> "NT" AND status_cliente <> "TE"
		--AND fecha_insert  >= dtFechaCorteIniCte AND fecha_insert <= dtFechaCorteFinCte;
		AND fecha_insert  = dtFechaMax;
			
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.||"'"||
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
		VALUES("","","","Productividad GENERAL por Supervisor CAT","","","","","","","Volumen de cuentas C. Administrativa",iVolCtasAdm,"","","");
				
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
		VALUES("","","","Pagos al: "||cFechEnc2,"","","","","","","Valor de cuentas C. Administrativa",dValCtasAdm,"","","");		
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
		VALUES("","","","","","","","","","","Valor de capital vencido C. Administrativa",dValCapVencAdm,"","","");
						
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
		VALUES("Supervisor","Nombre","Turno","SEGM","Llamadas realizadas","Llamadas exitosas (%)","Llamadas no exitosas (%)","Convenios activados","% Efectividad negociaciones","Monto convenido","Monto recuperado","% Efectividad monto","Meta","Para Meta","Efectividad vs Meta");		
								
		--BARRER LA INFORMACION FINAL PARA INSERTARLA EN LA TABLA FINAL.
		FOREACH WITH HOLD
					
			--CONSULTA PARA OBTENER LA INFORMACION DE LA PRODUCTIVIDAD GENERAL CAT.
			--SELECT Supervisor,Nombre,Turno,SEGM,LlamRealdas,NVL((LlamExit/100),0.00) AS LlamExit1,NVL((LlamNoExit/100),0.00) AS LlamNoExit1,ConvAct,CASE WHEN LlamExit <> 0 THEN NVL(((ConvAct/LlamExit) *100),0.00) ELSE 0.00 END AS EfecNeg,MontoConv,MontoRecp,CASE WHEN MontoConv <> 0 THEN NVL((MontoRecp/MontoConv),0.00) ELSE 0.00 END AS EfecMon,Meta,NVL((MontoRecp - Meta),0.00) AS ParaMeta,CASE WHEN Meta <> 0 THEN NVL(((MontoRecp/Meta)*100),0.00) ELSE 0.00 END AS EfecVsMeta
			SELECT Supervisor,Nombre,Turno,SEGM,LlamRealdas,NVL((LlamExit/LlamRealdas)*100,0.00) AS LlamExit1,NVL((LlamNoExit/LlamRealdas)*100,0.00) AS LlamNoExit1, LlamExit_e, count_empleado 
			INTO cSupervisor,vcNombre,cTurno,cSEGM,iLlamRealdas,dLlamExit,dLlamNoExit,dLlamExit_2,vcount_empleado
			FROM TABLE(MULTISET(SELECT NVL(a.numempleado,"") AS Supervisor,
								NVL(TRIM(b.nombre),"")||NVL(TRIM(b.apellidopaterno),"")||NVL(TRIM(b.apellidomaterno),"") AS Nombre,
								NVL(CASE WHEN c.numgrupo IN ("M1","M2","M3","M4","M5") THEN "Matutino" ELSE (CASE WHEN c.numgrupo IN ("V1","V2","V3","V4","V5") THEN "Vespertino" END)END,"") AS Turno,
								NVL(c.numsubgrupo,"") AS SEGM,						  
								COUNT(a.cliente) AS LlamRealdas,
								SUM(CASE WHEN a.finllamada IN(1,2,3,4,5,6,7,10,14,15) THEN 1 ELSE 0 END) AS LlamExit, 
								SUM(CASE WHEN a.finllamada IN(8,9,11,12,13,16,17,18) THEN 1 ELSE 0 END) AS LlamNoExit,
								SUM(CASE WHEN a.finllamada IN(1,2,3,4,5,6,7,10,14,15) THEN 1 ELSE 0 END) AS LlamExit_e,
								COUNT(a.numempleado) AS count_empleado
								FROM bdicobranza:"informix".cb_cat_movimientos a
								LEFT OUTER JOIN bdicobranza:"informix".cb_cat_datosgenerales b ON( b.numempleado = a.numempleado)
								LEFT OUTER JOIN bdicobranza:"informix".cb_catejecutivos c ON ( c.numempleado = a.numempleado)
								LEFT OUTER JOIN bdicobranza:"informix".cb_cat_directorio_cte e ON(e.numcte = LPAD(TRIM(a.cliente),9,"0"))									
								WHERE a.fechacartera::DATE = dtFechaMaxCart
								AND date(a.horainicio) >= dtFechaCorteIniHis AND date(a.horainicio) <= dtFechaCorteFinHis --- MACF 
								AND a.cvemovimiento = "L"  AND a.tipomovimiento = 1 --- MACF
								AND e.tipo_cobranza = "A"									
								--AND e.fecha_insert >= dtFechaCorteIniCte AND e.fecha_insert <= dtFechaCorteFinCte 																		
								AND e.fecha_insert = dtFechaMax
								AND e.status_cliente <> "NT" AND e.status_cliente <> "TE"
								GROUP BY 1,2,3,4))
				BEGIN WORK;
			----- EXTRA BY MACF
			SELECT efectuo_compac, SUM(importe), SUM(imp_pagado), count(*) INTO  vefectuo_compac, dMontoConv, dMontoRecp, iConvAct
			FROM cb_compac_his
			WHERE fecha_compac >= dtFechaCorteIniHis AND fecha_compac <= dtFechaCorteFinHis
			AND origen = 3
			AND efectuo_compac = cSupervisor 
			GROUP BY efectuo_compac;
			
			
			--CASE WHEN LlamExit <> 0 THEN NVL(((ConvAct/LlamExit) *100),0.00) ELSE 0.00 END AS EfecNeg
			IF dLlamExit <> 0 THEN 
				LET dEfecNeg = NVL(((iConvAct/dLlamExit_2) *100),0.00);
				IF dEfecNeg > 100 THEN LET dEfecNeg = 100.00; END IF;
			ELSE 
				LET dEfecNeg = 0.00; 
			END IF; 
			         
			--CASE WHEN MontoConv <> 0 THEN NVL((MontoRecp/MontoConv),0.00) ELSE 0.00 END AS EfecMon
			IF dMontoConv <> 0 THEN 
				LET dEfecMon = NVL((dMontoRecp/dMontoConv)*100,0.00);
				IF dEfecMon > 100 THEN LET dEfecMon = 100.00; END IF;
			ELSE 
				LET dEfecMon = 0.00; 
			END IF;   
			         
			/* --NVL((MontoRecp - Meta),0.00) AS ParaMeta
				LET dParaMeta = NVL((dMontoRecp - dMeta),0.00);  

			--CASE WHEN Meta <> 0 THEN NVL(((MontoRecp/Meta)*100),0.00) ELSE 0.00 END AS EfecVsMeta
			IF dMeta <> 0 THEN 
				LET dEfecVsMeta = NVL(((dMontoRecp/dMeta)*100),0.00);
				IF dEfecVsMeta > 100 THEN LET dEfecVsMeta = 100.00; END IF; 
			ELSE 
				LET dEfecVsMeta = 0.00; 
			END IF;
			*/

			--LET vcount_empl_tot = vcount_empl_tot + vcount_empleado;
			         
			--SE INSERTA TODA LA INFORMACION EN LA TABLA FINAL.
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
			VALUES(cSupervisor,vcNombre,cTurno,cSEGM,iLlamRealdas,dLlamExit,dLlamNoExit,iConvAct,dEfecNeg,dMontoConv,dMontoRecp,dEfecMon,dMeta,dParaMeta,dEfecVsMeta);
			
			COMMIT WORK;
		END FOREACH;
		
		SELECT supervisor FROM bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD
		WHERE nvl(supervisor,'') <> '' and supervisor <> 'Supervisor'
		GROUP BY supervisor
		INTO temp cantidad_supervisores WITH NO log;
		  
		SELECT COUNT(*) AS cantidad INTO vcount_empl_tot
		FROM cantidad_supervisores;
		
		IF vcount_empl_tot <> 0 THEN
			LET dMeta = dValCapVencAdm * .20 / vcount_empl_tot;
		END IF;
		
		--UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD SET Meta = dMeta WHERE supervisor like '9%';
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD SET Meta = dMeta WHERE nvl(supervisor,'') <> '' and supervisor <> 'Supervisor';
		UPDATE statistics medium for table bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD;
		
		FOREACH WITH HOLD
			SELECT Supervisor, MontRecdo INTO cSupervisor, dMontoRecp 
			FROM bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD
			WHERE supervisor <> '' and supervisor <> 'Supervisor'
		    
			BEGIN WORK;
				IF dMontoRecp > 0 THEN
				  LET dParaMeta = NVL((dMeta - dMontoRecp),0.00);
				ELSE  
				  LET dParaMeta = 0;
				END IF;
			
				--CASE WHEN Meta <> 0 THEN NVL(((MontoRecp/Meta)*100),0.00) ELSE 0.00 END AS EfecVsMeta
				IF dMeta <> 0 THEN 
					LET dEfecVsMeta = NVL(((dMontoRecp/dMeta)*100),0.00);
					IF dEfecVsMeta > 100 THEN LET dEfecVsMeta = 100.00; END IF; 
				ELSE 
					LET dEfecVsMeta = 0.00; 
				END IF;
				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD SET PaMeta = dParaMeta, EfecVsMeta = dEfecVsMeta
				WHERE supervisor = cSupervisor;             
			COMMIT WORK;			
			
		END FOREACH;
		
		UPDATE statistics medium for table bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD;
		--NVL((MontoRecp - Meta),0.00) AS ParaMeta

		--SE CALCULA EL TOTALIZADO DE LOS REGISTROS.
		SELECT NVL(SUM(LlamRdas::INTEGER),0),NVL(SUM(ConvAct::INTEGER),0),NVL(SUM(MontConv::DECIMAL(18,2)),0.00),NVL(SUM(MontRecdo::DECIMAL(18,2)),0.00),NVL(SUM(Meta::DECIMAL(18,2)),0.00),NVL(SUM(PaMeta::DECIMAL(18,2)),0.00)
		INTO iLlamRealdas2,iConvAct2,dMontoConv2,dMontoRecp2,dMeta2,dParaMeta2
		FROM bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD
		WHERE NVL(Supervisor,"") <> "" AND NVL(Supervisor,"") <> "Supervisor";		
		
		--SE INSERTA EL TOTALIZADO INFERIOR EN LA TABLA FINAL DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD (Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta)
		VALUES("","","","Total",iLlamRealdas2,"","",iConvAct2,"",dMontoConv2,dMontoRecp2,"",dMeta2,dParaMeta2,"");
		
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 74;	

		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
		AND grupo_parametro = "RUTAS" 
		AND num_parametro = 1;
		
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Supervisor,Nombre,Turno,SEGM,LlamRdas,LlamExit,LlamNoExit,ConvAct,EfectNeg,MontConv,MontRecdo,EfecMont,Meta,PaMeta,EfecVsMeta FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELPROD";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELPROD;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la productividad general CAT.', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121108.1757';

CREATE PROCEDURE "informix".sp_grabacompac(
				pempresa char(3),
				pempleado_captura int,
				pnumcliente char(20),
        pnumcuenta char(20),
				ptipo_compac char(1),
				pplazo char(2),
				pimporte decimal,
				porigen	smallint,
				pefectuo_compac int,
				psucursal char(4),
        pfechasistema date,
        pquien_convenio char(15),
        pnom_convenio char(40),
        pemail char(60),
        preferenciacoppel char(20),
        pnombre_efectuo char(40)
) returning char(5);

define v_codret char(5);
define vcod_ret char(5);
define v_sqlerr integer;
define v_isamerr integer;
define v_pnumcliente char(20);
define v_Error char(20);
define vv_cod_ret char(5);
define vActivo char(1);
---------------------------------------------------
DEFINE cCodRet_1         CHAR(6);
DEFINE cMensajeRet_1     CHAR(80);
DEFINE dImpMensual       DECIMAL(18,2);
DEFINE dIntVdo           DECIMAL(18,2);
DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIvaIntVdo        DECIMAL(18,2);
DEFINE dPagosVdos        DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIntMes_1         DECIMAL(18,2);
DEFINE dIvaIntMes_1      DECIMAL(18,2);
DEFINE dIntVig           DECIMAL(18,2);
DEFINE dIvaIntVig        DECIMAL(18,2);
DEFINE vcantReg		     SMALLINT;
---------------------------------------------------
let v_codret = "000";
let vv_cod_ret = "000";
let vcod_ret ="000";
let v_sqlerr = 0;
let v_isamerr = 0;
Let v_Error = '';
let v_pnumcliente = lpad(trim(pnumcliente), 9, '0');
let vActivo = '1';
---------------------------------------------------
LET cCodRet_1         = '';
LET cMensajeRet_1     = '';
LET dImpMensual		  = 0;
LET dIntVdo           = 0;
LET dIntMoratorio     = 0;
LET dIvaIntVdo        = 0;
LET dPagosVdos        = 0;
LET dIvaIntMoratorio  = 0;
LET dIntMes_1         = 0;
LET dIvaIntMes_1      = 0;
LET dIntVig           = 0;
LET dIvaIntVig        = 0;
LET vcantReg          = 0;
---------------------------------------------------

--SET DEBUG FILE TO "/aplicacion/Carlos/sp_grabacompac.out";
--TRACE ON;

--31/10/2008
--CAMBIO:
--Se comento la parte donde se valida si viene la referencia coppel ya que no es obligatoria.
--WALBERTO CASTRO
--19/11/2009
--Se agrego el campo CANAL a la tabla cb_compac_error para que el se guarde el registro de error del procedimiento.
--Armida Pazos

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 3;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;

   --CHECAR VALORES NULOS
   IF pempresa IS NULL OR Trim(pempresa) = "" THEN
	   LET v_codret = "20001";
   ELIF pempleado_captura IS NULL THEN
	   LET v_codret = "20002";
   ELIF v_pnumcliente IS NULL OR Trim(v_pnumcliente) = "" THEN
	   LET v_codret = "20003";
   ELIF pnumcuenta IS NULL OR Trim(pnumcuenta) = "" THEN
	   LET v_codret = "20004";
   ELIF ptipo_compac IS NULL OR Trim(ptipo_compac) = "" THEN
	   LET v_codret = "20005";
   ELIF pplazo IS NULL OR Trim(pplazo) = "" THEN
	   LET v_codret = "20006";
   ELIF pimporte IS NULL THEN
	   LET v_codret = "20007";
   ELIF pimporte = 0 THEN --A.L.L valida que el iporte capturado no sea cero
	   LET v_codret = "20007";
   ELIF porigen IS NULL THEN
	   LET v_codret = "20008";
   ELIF pefectuo_compac IS NULL THEN
	   LET v_codret = "20009";
   ELIF psucursal IS NULL OR Trim(psucursal) = "" THEN
	   LET v_codret = "20010";   

   ELIF pquien_convenio IS NULL OR Trim(pquien_convenio) = "" THEN
	   LET v_codret = "20011";

   ELIF pnom_convenio IS NULL OR Trim(pnom_convenio) = "" THEN
	   --LET v_codret = "20012";
	   LET v_codret = "012";
	   RETURN v_codret;
 --IF preferenciacoppel IS NULL OR Trim(preferenciacoppel) = "" THEN
--	   LET v_codret = "014";
--	   RETURN v_codret;
   --END IF;

   ELIF pfechasistema IS NULL THEN
	    LET v_codret = "20013";
	

   ELIF pnombre_efectuo IS NULL OR Trim(pnombre_efectuo) = "" THEN
	    LET v_codret = "20014";
	

   --CHECAR SI EXISTEN LAS TABLAS
--jom   ELIF  NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac') THEN
--jom		LET v_codret = "20015";
		

--jom   ELIF NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac_his') THEN
--jom		LET v_codret = "20016";		
   END IF;
 
   ---Verificar si existe un compromiso vigente (20110124)
    CALL bdicobranza:"informix".sp_consultarcompromisovigente(pempresa, pnumcuenta)
    RETURNING vv_cod_ret, vActivo;
	
--jom	if (porigen = 4)	then
--jom		if (v_codret in("20011","20012","20014")) then
--jom			LET v_codret = '000';  
--jom		end if;
--jom	end if;
    
   IF v_codret = '000' and vActivo = '0' THEN
   
		IF porigen = 3 THEN
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(pEmpresa, pNumCuenta) 
			INTO cCodRet_1, cMensajeRet_1, dImpMensual, dIntVdo,
			dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio,
			dIntMes_1, dIvaIntMes_1, dIntVig, dIvaIntVig;
		
			insert into bdicobranza:cb_compac
				(empresa, sucursal, origen, empleado_captura, numcliente,
				numcuenta, plazo, importe, tipo_compac, activo,
				flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert, pago_minimo)
			values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current,dImpMensual);
		
				 UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
                                                      monto_ult_convenio = pimporte,
                                                      fecha_ult_convenio = pfechasistema 	
				 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
				 LET vCantReg = DBINFO("sqlca.sqlerrd2");

				 if vCantReg = 0 then
				    UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				    WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 end if;
		
		ELSE
   
			insert into bdicobranza:cb_compac
				 (empresa, sucursal, origen, empleado_captura, numcliente,
			numcuenta, plazo, importe, tipo_compac, activo,
			flag_pago, efectuo_compac, nombre_efectuo,
				 fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert)
			 values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
						pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
						 '0', pefectuo_compac, pnombre_efectuo,
						 pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current);
			
				 UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
                                                      monto_ult_convenio = pimporte,
                                                      fecha_ult_convenio = pfechasistema 	
				 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
				 LET vCantReg = DBINFO("sqlca.sqlerrd2");

				 if vCantReg = 0 then
				    UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				    WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 end if;			

		END IF;
  ELSE

  	
	
	  if vActivo = '1' then
	     LET v_Error = 'SUCURSAL';
         LET v_codret = "20017"; 
	  end if;

      IF porigen = 3 THEN 
	   	LET v_Error = 'CATONLINE';
        let v_codret = "000";
	  END IF;
	
		insert into bdicobranza:"informix".cb_compac_error
				(empresa, sucursal, origen, empleado_captura, numcliente,
	            numcuenta, plazo, importe, tipo_compac, activo,
	            flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, codigo_error, canal, hora_insert)
		values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, v_codret, v_Error, current);
  END IF;

--  if v_codret = '000' then  
--    execute procedure bdicred:sp_graba_indicador(pempresa, pnumcuenta,pimporte,'' , pfechasistema, 5) into vcod_ret;
--  end if;
  return v_codret;
end;
end procedure
DOCUMENT
'Fecha ModificaciÃ³n: 2013/11/29',
'Autor: Marco A. Campos',
'DESCRIPCION: Realizar validaciÃ³n de Nombre EfectuÃ³',
'Fecha Modificación: 2018/08/30',
'Autor: Marco A. Campos',
'DESCRIPCION: Actualización indicadores TRIAD';

CREATE PROCEDURE "informix".sp_cat_gp_pp_genarchbase(pempresa CHAR(3), 
                                                    ptipocobranza CHAR(1))
RETURNING CHAR(6);
--______________________________________________________________________________________________________________________________________________________________
-- Creado por: Abrham López López. Fecha: 01/11/2011. Descripción: Proceso para la generación del archivo ivr preventivo para prestamo personal
-- BT = Vencido, AA = Vigente, BA = Transitorio, FF = Liquidado, EX = IN = . Base de Datos: BDICOBRANZA. ptipocobranza = 'E'
-- Modificado por: MAHR. Abril 2012. Se cambia a sp_inserta_bitacora_cob para la correcta insercion de la bitacora.
--Modificado por: Abrham Lopez L. Mayo 08 de 2012
--Se mofica sp para agregarle la consulta que genera archivo IVR de Restructura.
--Modificado por: Abrham Lopez L. junio 05 de 2014
--Se mofica sp para eliminar el prefijo en los numeros celular.
-- execute PROCEDURE "informix".sp_cat_gp_pp_genarchbase('001', 'E')
/*________________________________________________________________________________________________________________________________________________*/

--Declaración de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vproceso				CHAR(4);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(1500);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vdia				    DATE;
DEFINE vhora				CHAR(8);
DEFINE ctipocampania        CHAR(1);
DEFINE pFecha               DATE;
define cfecha_insert        DATE;
DEFINE vTipoCobranza        CHAR(1);
DEFINE cNum_ProdCampa		CHAR(4);
DEFINE vFecha_insert		DATE;
DEFINE vcount				INTEGER;
DEFINE vnum_param			INTEGER;
DEFINE vregistra			CHAR(10);

--SET DEBUG FILE TO "sp_cat_gp_pp_genarchbase.out";
--TRACE ON; 

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_RetIB              = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '2003';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnumcte                 = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET vdia				    = DATE(1);
LET vhora				    = "";
LET ctipocampania           = "";
LET cfecha_insert           = "";
LET vTipoCobranza			= "";
LET cNum_ProdCampa			= "";
LET vFecha_insert			= "";
LET vcount					= 0;
LET vnum_param				= 0;
LET vregistra				= "";


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    --Sacar la fecha del día de hoy
    SELECT Fecha_Hoy
        INTO pFecha
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = '001';

    --Validación de la empresa
	SELECT empresa
        INTO cempresa
        FROM bdinteg:"informix".si_empresas
        WHERE empresa = pempresa;

    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    --Obtener caracter delimitador
    SELECT valor_alfabetico
        INTO cdelimitador
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;

    --Valida que exista el caracter
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    --Obtener ruta del archivo
	SELECT valor_alfabetico
        INTO cruta
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 36;

    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    --Se saca el maximo de fecha insert	
	SELECT MAX(fecha_insert) 
        INTO cfecha_insert 
        FROM "informix".cb_cat_directorio_cte
		WHERE tipo_cobranza = ptipocobranza;

--temporal solo para pruebas
--LET cfecha_insert = today-1;
--temporal solo para pruebas

----------------------------------------------------------------------------------------------
---------------------------------------- ARCHIVOS IVR ----------------------------------------
FOREACH WITH HOLD
	SELECT valor_numerico INTO cNum_ProdCampa
	FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
	AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = ptipocobranza

	IF (cNum_ProdCampa = "6300") THEN
		LET vnum_param = 49;
	ELIF (cNum_ProdCampa = "7600") THEN
		LET vnum_param = 75;
	ELIF (cNum_ProdCampa = "7700") THEN
		LET vnum_param = 76;
	ELIF (cNum_ProdCampa = "6011") THEN
		LET vnum_param = 51;
	ELIF (cNum_ProdCampa = "6800") THEN
		LET vnum_param = 78;
	ELSE
		CONTINUE FOREACH;
	END IF;

    --Obtener el nombre del archivo
	SELECT valor_alfabetico
        INTO cnombre
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = vnum_param;

    --Validar que existe el archivo
    LET cnomarchivo1 =  TRIM(cnombre)||'Aux'||TO_CHAR(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo =  TRIM(cnombre)||TO_CHAR(pFecha,'%d%m%Y')||'.txt';

    --Se ejecuta para ponerle el encabezado
	LET cSql='';
	LET csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
				 'prioridad'||','||'fechalimitepago'||','||'fechacorte'||'">'||TRIM(cruta)|| cnomarchivo;   
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| TRIM(cdelimitador) || ''''||'';

	LET cSQL2 = " SELECT a.numcte as cliente,"
    || " TRIM (h.apell_paterno) ||' '|| TRIM (h.apell_materno)||' '|| TRIM(h.nombre1) ||' '|| TRIM(h.nombre2) as nombre,"
    || " a.num_producto as tipoproducto,"
    || " nvl(TRIM(substr(b.telefono,length(b.telefono)-9,10)),' ') as telcasa,"
	|| " nvl(TRIM(substr(d.telefono,length(d.telefono)-9,10)),' ') as telcelular,1,"
    || " (e.prox_fecha_pago) as fechalimitepago,"
	|| " (e.prox_fecha_pago) as fechacorte"
	|| " FROM 'informix'.cb_cat_directorio_cte a"
	|| " JOIN bdinteg:'informix'.si_cliente h ON (h.empresa = a.empresa AND h.numcte = a.numcte)"
	|| " LEFT OUTER JOIN bdinteg:'informix'.si_telefonos_actual b ON ( b.empresa = a.empresa AND b.numcte = a.numcte AND b.tipo_tel = 1 AND b.cofetel = 'V' AND length(nvl(b.telefono,'')) >= 10)"
	|| " LEFT OUTER JOIN bdinteg:'informix'.si_telefonos_actual d ON ( d.empresa = a.empresa AND d.numcte = a.numcte AND d.tipo_tel = 2 AND d.cofetel = 'V' AND length(nvl(d.telefono,'')) >= 10)"
	|| " JOIN bdicred:'informix'.sd_maecredanexocrd e ON (e.empresa= a.empresa AND e.num_credito = a.num_credito)"
	|| " WHERE a.empresa = '"|| pempresa || "'"
	|| " AND a.tipo_cobranza = '"|| ptipocobranza || "'"
	|| " AND a.fecha_insert = '"|| cfecha_insert || "'"
	|| " AND a.status_cliente = 'AC'"
	|| " AND a.num_producto = '"|| cNum_ProdCampa || "'"
	|| " AND ((nvl(b.telefono,'') <> '') OR (nvl(d.telefono,'') <> ''));";

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRpreventiva.sql';
    LET cSQL = TRIM(cSQL1) || cSQL2 || TRIM(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRpreventiva.sql';
    System cSQL;

    LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRpreventiva.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||TRIM(cDelimitador)||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRpreventiva.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	LET cnombre, cnomarchivo1, cnomarchivo, cNum_ProdCampa, cSQL1, cSQL2, cSQL3 = "", "", "", "", "", "", "";
END FOREACH;
---------------------------------------- ARCHIVOS IVR ----------------------------------------
----------------------------------------------------------------------------------------------
LET cNum_ProdCampa = "";

FOREACH WITH HOLD
	SELECT valor_numerico INTO cNum_ProdCampa
	FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
	AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = ptipocobranza

	IF (cNum_ProdCampa = "6300") THEN
		LET vregistra = "IVR_PP";
	ELIF (cNum_ProdCampa = "7600") THEN
		LET vregistra = "IVR_PP18";
	ELIF (cNum_ProdCampa = "7700") THEN
		LET vregistra = "IVR_PP24";
	ELIF (cNum_ProdCampa = "6011") THEN
		LET vregistra = "IVR_REEST";
	ELIF (cNum_ProdCampa = "6800") THEN
		LET vregistra = "IVR_PPDG";
	ELSE
		CONTINUE FOREACH;
	END IF;

	SELECT COUNT(*) INTO vcount
	FROM "informix".cb_cat_directorio_cte a
	JOIN bdinteg:"informix".si_cliente h ON (h.empresa = a.empresa AND h.numcte = a.numcte)
	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON ( b.empresa = a.empresa AND b.numcte = a.numcte AND b.tipo_tel = 1 AND b.cofetel = 'V' AND length(nvl(b.telefono,'')) >= 10)
	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual d ON ( d.empresa = a.empresa AND d.numcte = a.numcte AND d.tipo_tel = 2 AND d.cofetel = 'V' AND length(nvl(d.telefono,'')) >= 10)
	JOIN bdicred:"informix".sd_maecredanexocrd e ON (e.empresa= a.empresa AND e.num_credito = a.num_credito)
	WHERE a.empresa = pempresa
	AND a.tipo_cobranza =  ptipocobranza
	AND a.fecha_insert =  cfecha_insert
	AND a.status_cliente = "AC"
	AND a.num_producto = cNum_ProdCampa
	AND ((nvl(b.telefono,"") <> "") OR (nvl(d.telefono,"") <> ""));

	CALL "informix".sp_latinia_contador_cobranza(vregistra,vcount,NULL) RETURNING cCod_ret;

	LET vcount, vregistra, cNum_ProdCampa = 0, "", "";
END FOREACH;

CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03') Returning cCod_RetIB;

RETURN cCod_ret;
END;
END PROCEDURE;