CREATE PROCEDURE "informix".sp_campana_cta_efec_dig()
RETURNING CHAR(6) AS cCodRet, CHAR(100) AS cMensCodRet


--DEFINICION DE VARIABLES
DEFINE cCodRet 		CHAR(6);
DEFINE cMensCodRet	CHAR(100);
DEFINE iSQLerr		INTEGER;
DEFINE cProceso		CHAR(100);
DEFINE iNumCelular	CHAR(10);
DEFINE cCodretreg	CHAR(5);

--ASIGNACION DE VARIABLES
LET cCodRet 	 = '000000';
LET cMensCodRet  = 'PROCESO EXITOSO';
LET cProceso	 = '';
LET iNumCelular  = '';
LET cCodretreg   = '00000';



--SET DEBUG FILE TO "/informix/tmp/ingrid/sp_campaña_cta_efec_dig.out";
--TRACE ON;


	BEGIN
		--Manejo del error
		ON EXCEPTION SET iSQLerr
			IF iSQLerr <> 0 THEN
				LET cCodRet = iSQLerr;
				LET cMensCodRet = 'ERROR AL EJECUTAR EL PROCESO';
				RETURN cCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;
			
					
					--OBTENCION DE CELULARES A LOS QUE SE LES ENVIARÁ SMS
					FOREACH 
						
						SELECT DISTINCT telefono 
						INTO iNumCelular
						FROM bditransfer:tf_user_transfer 
						WHERE fecha_corte = TODAY -1
							
							
						--SE ENVIA SMS
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CED_BIEN','CED_BIEN','000000000','','','2','','','','','','','','','','','',iNumCelular,1,0,0,0,0,'','')	
						INTO cCodretreg;
		
					END FOREACH;
					
					IF NVL (iNumCelular,'') = '' THEN
						LET cCodRet = '000001';
						LET cMensCodRet = 'NO SE ENCONTRARON REGISTROS DE ALTAS';
					END IF;
			
			--SE ENVIA SMS PARA NUMERO ESPECÍFICO
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CED_BIEN','CED_BIEN','000000000','','','2','','','','','','','','','','','','5567031817',1,0,0,0,0,'','')
			INTO cCodretreg;
			
			RETURN cCodRet, cMensCodRet;
	END
END PROCEDURE
DOCUMENT
'REALIZA: Envío de SMS a clientes de campaña cuenta efectiva digital',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:19/04/2017',
'VERSION:0.0.1',
'MODIFICO: Ingrid Pamela Cázarez Villegas';

CREATE PROCEDURE "informix".sp_archivo_opm()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;


/*DEFINICION DE VARIABLES */
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE dFechaAnt          DATE;
DEFINE cDia               CHAR(2);
DEFINE cMes 		      CHAR(10);
DEFINE cAnio 		      CHAR(4);
DEFINE vsStmt2			  CHAR(1000);
DEFINE vsStmt3			  CHAR(1000);
DEFINE vsStmt4			  CHAR(1000);
DEFINE vsStmt5			  CHAR(1000);
DEFINE vsStmt6			  CHAR(1000);
DEFINE vsStmt7			  CHAR(1000);
DEFINE vsStmt8			  CHAR(1000);
DEFINE vsStmt9			  CHAR(1000);
DEFINE viRegistros 		  INTEGER;
DEFINE vArch  			  INTEGER;
DEFINE vsNombreArchivo    VARCHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE mSaldoDiario		  MONEY;
DEFINE iTransacciones	  INTEGER;
DEFINE iTotalAltas		  INTEGER;
DEFINE iTotalBajas		  INTEGER;
DEFINE cCelulares		  CHAR(10);
DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);
DEFINE vsRutaArchRep	  CHAR(150);

/*DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET dFechaAnt = '';
LET cDia = '';
LET cMes = '';
LET cAnio = '';
LET vsStmt2 = '';
LET vsStmt3 = '';
LET vsStmt4 = '';
LET vsStmt5 = '';
LET vsStmt6 = '';
LET vsStmt7 = '';
LET vsStmt8 = '';
LET vsStmt9 = '';
LET viRegistros = 0;
LET vArch =0;
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET mSaldoDiario = 0;
LET iTransacciones = 0;
LET iTotalAltas = 0;
LET iTotalBajas = 0;
LET cCelulares = '';
LET cSQL1 = ' ';
LET cSQL = ' ';
LET vsRutaArchRep = ' ';

--SET DEBUG FILE TO "/tmp/ALAN/transfer/sp_archivo_opm.out";
--TRACE ON;


BEGIN


	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	--Obtiene fecha dia anterior
	
			SELECT fecha_ant
			INTO dFechaAnt
			FROM bdinteg:"informix".si_fechas;
			
			LET cDia = LPAD(DAY(dFechaAnt::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFechaAnt::DATE), 2, '0');
			LET cAnio = YEAR(dFechaAnt ::DATE);
			
			
			IF cMes = '01' THEN LET cMes = 'ENERO';
				ELIF cMes = '02' THEN LET cMes = 'FEBRERO';
				ELIF cMes = '03' THEN LET cMes = 'MARZO';
				ELIF cMes = '04' THEN LET cMes = 'ABRIL';
				ELIF cMes = '05' THEN LET cMes = 'MAYO';
				ELIF cMes = '06' THEN LET cMes = 'JUNIO';
				ELIF cMes = '07' THEN LET cMes = 'JULIO';
				ELIF cMes = '08' THEN LET cMes = 'AGOSTO';
				ELIF cMes = '09' THEN LET cMes = 'SEPTIEMBRE';
				ELIF cMes = '10' THEN LET cMes = 'OCTUBRE';
				ELIF cMes = '11' THEN LET cMes = 'NOVIEMBRE';
				ELIF cMes = '12' THEN LET cMes = 'DICIEMBRE';
			END IF;
	
		IF (vsCodRetorno='00000') THEN
		
			TRUNCATE TABLE bditransfer:"informix".arch_opm_paso;
			UPDATE statistics medium FOR TABLE bditransfer:"informix".arch_opm_paso;

			--Nombre del archivo
			LET vsNombreArchivo = 'CED_Reporte_Diario'||'.csv';
			
			SET LOCK MODE TO WAIT 3;
		
			
				SELECT SUM(sdo_cta)
				INTO mSaldoDiario
				FROM tf_account_balance_customer
				WHERE fecha_proceso = dFechaAnt;
				
				SELECT COUNT(consecutivo)
				INTO iTransacciones
				FROM tf_success_transac
				WHERE fecha_alt = dFechaAnt;
				
				SELECT {+INDEX (bditransfer:"informix".tf_user_transfer 204_631 )} COUNT(consecutivo)
				INTO iTotalAltas
				FROM tf_user_transfer;
				
				SELECT {+INDEX (bditransfer:"informix".tf_retire_customer 139_279 )} COUNT(consecutivo)
				INTO iTotalBajas
				FROM tf_retire_customer;
				
				
				LET vsStmt2 =  'INFORMACIÓN '||cDia||' '||cMes;
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt2);
					
				LET vsStmt3 =  'Saldo diario'||' '||TRIM(NVL(mSaldoDiario,'00'));	
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt3);
					
				LET vsStmt4 =  'Total de transacciones'||' '||TRIM(NVL(iTransacciones,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt4);
				
				LET vsStmt5 =  'Total de altas'||' '||TRIM(NVL(iTotalAltas,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt5);
				
				LET vsStmt6 =  'Total de bajas'||' '||TRIM(NVL(iTotalBajas,'00'));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt6);
					
				LET vsStmt7 = ' ';
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt7);
				
				LET vsStmt8 =  'Detalle de altas';
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt8);

			FOREACH	
					SELECT telefono
					INTO cCelulares
					FROM tf_user_transfer
					WHERE fecha_alta = dFechaAnt
				
				LET vsStmt9 =  TRIM(NVL(cCelulares,''));
					INSERT INTO arch_opm_paso (linea)
					VALUES (vsStmt9);
			
			END FOREACH;
			
			
			LET vsRutaArchRep = '/ifxsif01/Control-M/';
			
			LET vsCodRetorno  = '00020';
			LET vsMensaje  = 'ERROR AL GENERAR EL ARCHIVO';
		
			LET cSQL1 = 'echo "UNLOAD TO '||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo)||' delimiter '||' SELECT linea FROM bditransfer:"informix".arch_opm_paso ORDER BY secuencial" >'||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
			SYSTEM cSQL1;

			LET cSQL='dbaccess bditransfer '||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
			System cSQL;
			
			LET cSQL = '' ;
			LET cSQL = 'zip /'||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo)||'.zip '||'-P bancoppel /'||TRIM(vsRutaArchRep)||TRIM(vsNombreArchivo);
			SYSTEM cSQL ;
			
			LET vsCodRetorno  = '00000';
			
			IF vsCodRetorno = '00000' THEN
				LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
			END IF;
				
				
		END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;