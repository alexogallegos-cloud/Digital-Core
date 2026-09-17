CREATE PROCEDURE "informix".sp_marcaje_prospectos_rees_auto()
RETURNING CHAR(5), CHAR(90);

DEFINE cCodRet				CHAR(5);
DEFINE cMenRet				CHAR(90);
DEFINE cArchMarcajeATM		CHAR(30);
DEFINE cArchValidacionATM	CHAR(40);
DEFINE cRutaArchivo			CHAR(100);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cEmpresa				CHAR(3);
DEFINE cCommand				CHAR(1000);
DEFINE cArchivoDbld			CHAR(100);
DEFINE cArchivoLog			CHAR(100);
DEFINE cArchivoOut			CHAR(100);
DEFINE cArchivoCarga		CHAR(100);
DEFINE cNumCredito			CHAR(15);
DEFINE cNumcte				CHAR(11);
DEFINE cNombreCompletoCte	CHAR(150);
DEFINE cCuentaRelacionada	CHAR(20);
DEFINE cTelefonoCte			CHAR(10);
DEFINE cProducto			CHAR(4);
DEFINE dFechaNacimiento		DATE;
DEFINE dFechaHoy			DATE;

DEFINE error_info       	VARCHAR(80);
DEFINE sql_err          	INTEGER;
DEFINE isam_err         	INTEGER;

DEFINE iCuentasChqActivas   INTEGER;
DEFINE iCuentasPrestamoPer  INTEGER;
--DECLARACION DE VARIABLES PARA EL SP sp_consulta_saldos_general
DEFINE cCodigoRetorno 	CHAR(6);
DEFINE cMensajeRetorno 	CHAR(80);
DEFINE cNumeroCredito 	CHAR(20);
DEFINE cCodigoTipcred 	CHAR(2);
DEFINE cFechaOrigen 	DATE;
DEFINE cFechaProxPago 	DATE;
DEFINE cPagoMinimo 		DECIMAL(18,2);
DEFINE cFechaUltPago 	DATE;
DEFINE cPlazo 			INTEGER;
DEFINE cPagosRealizados INTEGER;
DEFINE cLineaOtorgada 	DECIMAL(18,2);
DEFINE cTasaInteres 	DECIMAL(9,6);
DEFINE cTasaMoratorios 	DECIMAL(9,6);
DEFINE cMontoSbc 		DECIMAL(14,2);
DEFINE cCapVig 			DECIMAL(18,2);
DEFINE cCapTrans 		DECIMAL(18,2);
DEFINE cCapVdoExig 		DECIMAL(18,2);
DEFINE cCapVdoNoExig 	DECIMAL(18,2);
DEFINE cSdoActTotalCap 	DECIMAL(18,2);
DEFINE cIntVig 			DECIMAL(18,2);
DEFINE cIntVdo 			DECIMAL(18,2);
DEFINE cIntMoratorios 	DECIMAL(18,2);
DEFINE cIntMes 			DECIMAL(18,2);
DEFINE cSdoActTotalInt 	DECIMAL(18,2);
DEFINE cIvaIntVig 		DECIMAL(18,2);
DEFINE cIvaIntVdo 		DECIMAL(18,2);
DEFINE cIvaIntMoratorios DECIMAL(18,2);
DEFINE cIvaIntMes 		DECIMAL(18,2);
DEFINE cSdoActTotalIva 	DECIMAL(18,2);
DEFINE cComPend 		DECIMAL(18,2);
DEFINE cIvaCom 			DECIMAL(18,2);
DEFINE cSdoRetenido 	DECIMAL(18,2);
DEFINE cTotalLiquidacion DECIMAL(18,2);
DEFINE cIntDevengado 	DECIMAL(18,2);
DEFINE cIvaIntDevengado DECIMAL(18,2);
DEFINE cLineaDisponible DECIMAL(18,2);
DEFINE cPagosVdos 		DECIMAL(18,2);
DEFINE cDescStatusCred 	CHAR(60);
DEFINE cIdBloqueoCred 	INTEGER;
DEFINE cBloqueoCta 		CHAR(60);
DEFINE cIdCausaBloqueoCred CHAR(3);
DEFINE cCausaBloqueoCta CHAR(50);
DEFINE cIdSitEspCte  	CHAR(1);
DEFINE cIdCausaEspCte 	INTEGER;
DEFINE cSitEspCte 		CHAR(75);
DEFINE cIdSitEspCred 	CHAR(1);
DEFINE cIdCausaEspCred 	INTEGER;
DEFINE cSitEspCred 		CHAR(75);
DEFINE ctarjeta 		CHAR(16);
DEFINE bValidaArchivo   CHAR(1);

LET error_info       	= '';
LET sql_err          	= 0;
LET isam_err         	= 0;

LET iCuentasChqActivas 	= 0;
LET iCuentasPrestamoPer = 0;
LET cCodRet 			= '00000';
LET cMenRet				= 'PROCESO EXITOSO';
LET cArchMarcajeATM 	= 'Marcaje_ATM_Reest_';
LET cArchValidacionATM  = 'Validacion_ATM_Reestructura_';
LET cRutaArchivo		= '/RESPALDOSNEW/'; --PRODUCCION
--LET cRutaArchivo		= '/RESPALDOSNEW/gpe/'; -- DESARROLLO
LET cArchivoDbld		= 'f_carga_insumo.cmd';
LET cArchivoLog  		= 'f_carga_insumo.log';
LET cArchivoOut			= 'f_carga_insumo.out';
LET cArchivoCarga   	= 'dbload_cargaInsumo.sh';
LET cEmpresa			= '001';
LET dFechaHoy			= '';
LET dFechaNacimiento	= '';
LET cDia				= '';
LET cMes				= '';
LET cAnio				= '';
LET cCommand			= '';
LET cNumCredito 		= '';
LET cNumcte 			= '';
LET cNombreCompletoCte	= '';
LET cCuentaRelacionada	= '';
LET	cProducto			= '';
LET ctarjeta			= '';
--INICIALIZACION DE VARIABLES PARA EL SP sp_consulta_saldos_general
LET cCodigoRetorno,cMensajeRetorno,cNumeroCredito,cCodigoTipcred,cDescStatusCred,cBloqueoCta,cIdCausaBloqueoCred,cCausaBloqueoCta,cIdSitEspCte,cIdSitEspCte,cIdSitEspCred,cIdSitEspCred,ctarjeta = '','','','','','','','','','','','','';
LET cFechaOrigen,cFechaProxPago,cFechaUltPago 	= DATE(1),DATE(1),DATE(1);
LET cPagoMinimo,cPlazo,cPagosRealizados,cLineaOtorgada,cTasaInteres,cTasaMoratorios,cMontoSbc,cCapVig,cCapTrans,cCapVdoExig,cCapVdoNoExig,cSdoActTotalCap 	= 0,0,0,0,0,0,0,0,0,0,0,0;
LET cIntVig,cIntVdo,cIntMoratorios,cIntMes,cSdoActTotalInt,cIvaIntVig,cIvaIntVdo,cIvaIntMoratorios,cIvaIntMes,cSdoActTotalIva,cComPend,cIvaCom,cSdoRetenido = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET cTotalLiquidacion,cIntDevengado,cIvaIntDevengado,cLineaDisponible,cPagosVdos,cIdBloqueoCred,cIdCausaEspCte,cIdCausaEspCred = 0,0,0,0,0,0,0,0;

LET bValidaArchivo		= 'N';

	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info		
--			drop table if exists temp_validacion_ATM_reestructura;
			
			    IF bValidaArchivo = 'N' THEN--Se valida la variable de existencia de archivo para que no se alerte la salida
						INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
						('001', '0009', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info||'No existe archivo de carga', user, today, current );
			         LET cCodRet = '22222';
					 LET cMenRet = 'No existe archivo de carga';
					 RETURN cCodRet, cMenRet;
		         END IF;
				 
				 INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
				 ('001', '0009', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		
			IF sql_err = -668 THEN
				LET cCodRet = sql_err;
				LET cMenRet = 'Proceso con terminancion ' || trim(cCodRet);

				RETURN cCodRet, cMenRet;
			ELIF sql_err != -668 THEN
				LET cCodRet = sql_err;
				LET cMenRet = 'Error al ejecutar el proceso ' || cNumCredito || ' ' ||trim(error_info);

				RETURN cCodRet, cMenRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/informix/sp_marcaje_prospectos_rees_auto.out";
		--TRACE ON;
		
/*		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy)
		INTO dFechaHoy, cDia, cMes, cAnio
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = cEmpresa;*/
		
		LET dFechaHoy = TODAY;
		
		--temporal PARA PRUEBAS
		--LET cRutaArchivo = '/informix/';
		--LET dFechaHoy = MDY('07','29','2021');
		--temporal PARA PRUEBAS

		LET cDia = DAY(dFechaHoy);
		LET cMes = MONTH(dFechaHoy);
		LET cAnio = YEAR(dFechaHoy);
		
		IF MONTH(dFechaHoy) < 10 THEN
			LET cMes = '0' || TRIM(cMes);
		END IF;
		
		IF DAY(dFechaHoy) < 10 THEN
			LET cDia = '0' || TRIM(cDia);
		END IF;
		
		TRUNCATE TABLE temp_marcaje_ATM_reestructura;
		DELETE FROM bdicred:"informix".sd_programacion_reestructuras_aut WHERE fecha = dFechaHoy;
		
		LET cArchMarcajeATM = TRIM(cArchMarcajeATM) || cDia || cMes || cAnio || '.txt';
		LET cArchValidacionATM = TRIM(cArchValidacionATM) || cDia || cMes || cAnio || '.txt';
		
		--Se valida que el archivo exista en la carpeta
		LET cCommand = ' cat ' || TRIM(cRutaArchivo) || cArchValidacionATM;
		SYSTEM TRIM(cCommand); --Se lee el archivo
		
		LET bValidaArchivo = 'S'; --Si existe el archivo se modifica la bandera
		
		--SE INICIA EL PROCESO DE CARGA DEL ARCHIVO A LA TABLA sd_programacion_reestructuras_aut
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchMarcajeATM);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' echo "FILE ' || TRIM(cRutaArchivo) || cArchMarcajeATM || ' DELIMITER ' || '''|''' || ' 3; " > ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' echo "INSERT INTO temp_marcaje_ATM_reestructura(numcte,num_credito,num_producto); ">> ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' echo "dbload -d bdicred -c ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld) || ' -l ' || TRIM(cRutaArchivo) || TRIM(cArchivoLog) || ' -e 10000 -n 1000 -k | tee -a ' || TRIM(cRutaArchivo) ||
						TRIM(cArchivoOut) || '" > ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = '/usr/bin/sh ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);
		
		--FIN EL PROCESO DE CARGA DEL ARCHIVO A LA TABLA temp_marcaje_ATM_reestructura
	
		FOREACH WITH HOLD
			SELECT num_credito, numcte , num_producto
			INTO cNumCredito, cNumcte, cProducto
			FROM bdicred:"informix".temp_marcaje_ATM_reestructura

			--RECUPERACION DE INFORMACION DEL CLIENTE CON CUENTAS DE CHEQUES ACTIVAS
/*			SELECT TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
			INTO cNombreCompletoCte
			FROM bdinteg:si_cliente where numcte = cNumcte;
				
			SELECT fecha_nac INTO dFechaNacimiento
			FROM bdinteg:si_ctepf
			WHERE numcte = cNumcte;
				
			SELECT telefono INTO cTelefonoCte
			FROM bdinteg:si_telefonos_actual WHERE numcte = cNumcte AND status_tel = 'A' AND
				 secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos_actual WHERE numcte = cNumcte);*/

			BEGIN WORK;
			
			IF cProducto NOT IN ('6001','6600','7000','8100','6500') THEN

				SELECT num_cta INTO cCuentaRelacionada
				FROM bdicred:sd_ctascarg
				WHERE num_credito = cNumCredito
				  AND empresa = cEmpresa
				  AND naturaleza = 'A';

				IF cCuentaRelacionada IS NULL OR cCuentaRelacionada = '' THEN LET cCuentaRelacionada = '0'; END IF;

				IF cCuentaRelacionada = '0' THEN --CUENTA DE CREDITO SIN CUENTA DE CHEQUES RELACIONADA
					INSERT INTO bdicred:"informix".sd_programacion_reestructuras_aut 
					VALUES(dFechaHoy,cNumcte,cNumCredito,cProducto,cCuentaRelacionada,0,0,0,'',DATE(1),0);

					COMMIT WORK;
					CONTINUE FOREACH;
				END IF;	
				
			--VALIDACION CUENTA ACTIVA DE CHEQUES
/*				SELECT COUNT(cuenta) INTO iCuentasChqActivas
				FROM bdicheq:sc_maechq
				WHERE status_cta = '1'  AND cuenta = cCuentaRelacionada;
				
				IF iCuentasChqActivas = 0 THEN --CLIENTE CON CUENTA DE CHEQUES INACTIVA
					INSERT INTO bdicred:"informix".sd_programacion_reestructuras_aut 
					VALUES(TODAY,cNumcte,cNumCredito,cProducto,cCuentaRelacionada,0,0,0,'',DATE(1),0);

					COMMIT WORK;
					CONTINUE FOREACH;
				END IF;	*/

				--OBTENEMOS LA CUENTA CHEQUE
/*				SELECT cuenta--,producto 
				INTO cCuentaCheque--, cProducto
				FROM bdicheq:sc_maechq
				WHERE status_cta = '1' AND num_cte = cNumcte;
				
				IF cCuentaCheque IS NULL THEN
					LET cCuentaCheque = 0;
				END IF;*/
				
				--OBTENEMOS TARJETA CHEQUE
/*				SELECT num_tarjeta--,producto 
				INTO ctarjeta--, cProducto
				FROM bdicheq:sc_tarjeta
				WHERE status_tar = 'A' AND numcte = cNumcte
				AND cuenta = cCuentaRelacionada;*/
			ELSE
				SELECT tar.num_tarjeta
				  INTO  cCuentaRelacionada
				  FROM sd_tarjeta tar
				 WHERE tar.empresa		= cEmpresa
				   AND tar.num_credito	= cNumCredito
				   AND tar.tipo_tarjeta	= 'T'
				   AND tar.status_tar	= 'A';
				
				IF cCuentaRelacionada IS NULL OR cCuentaRelacionada = '' THEN LET cCuentaRelacionada = '0'; END IF;
				
				IF cCuentaRelacionada = '0' THEN --CUENTA DE CREDITO SIN CUENTA DE CHEQUES RELACIONADA
					INSERT INTO bdicred:"informix".sd_programacion_reestructuras_aut 
					VALUES(dFechaHoy,cNumcte,cNumCredito,cProducto,cCuentaRelacionada,0,0,0,'',DATE(1),0);

					COMMIT WORK;
					CONTINUE FOREACH;
				END IF;	

			END IF;
					
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, TRIM(cNumCredito))
			INTO cCodigoRetorno, cMensajeRetorno, cNumeroCredito, cCodigoTipcred, cFechaOrigen, cFechaProxPago, cPagoMinimo, cFechaUltPago,
				 cPlazo, cPagosRealizados, cLineaOtorgada, cTasaInteres, cTasaMoratorios, cMontoSbc, cCapVig, cCapTrans, cCapVdoExig, cCapVdoNoExig,
				 cSdoActTotalCap, cIntVig, cIntVdo, cIntMoratorios, cIntMes, cSdoActTotalInt, cIvaIntVig, cIvaIntVdo, cIvaIntMoratorios, cIvaIntMes,
				 cSdoActTotalIva, cComPend, cIvaCom, cSdoRetenido, cTotalLiquidacion, cIntDevengado, cIvaIntDevengado, cLineaDisponible, cPagosVdos,
				 cDescStatusCred, cIdBloqueoCred, cBloqueoCta, cIdCausaBloqueoCred, cCausaBloqueoCta, cIdSitEspCte, cIdCausaEspCte, cSitEspCte, cIdSitEspCred, 
				 cIdCausaEspCred, cSitEspCred;

			IF cCodigoRetorno::SMALLINT != 0 THEN
				INSERT INTO bdicred:"informix".sd_programacion_reestructuras_aut 
				VALUES(dFechaHoy,cNumcte,cNumCredito,cProducto,'',0,0,0,'',DATE(1),0);

				COMMIT WORK;
				CONTINUE FOREACH;
			END IF;
				 
			INSERT INTO bdicred:"informix".sd_programacion_reestructuras_aut 
			VALUES(dFechaHoy,cNumcte,cNumCredito,cProducto,cCuentaRelacionada,0,0,cTotalLiquidacion,'',DATE(1),1);

			COMMIT WORK;

			--INICIALIZACION DE VARIABLES PARA EL SP sp_consulta_saldos_general
			LET cCodigoRetorno,cMensajeRetorno,cNumeroCredito,cCodigoTipcred,cDescStatusCred,cBloqueoCta,cIdCausaBloqueoCred,cCausaBloqueoCta,cIdSitEspCte,cIdSitEspCte,cIdSitEspCred,cIdSitEspCred,ctarjeta = '','','','','','','','','','','','','';
			LET cFechaOrigen,cFechaProxPago,cFechaUltPago 	= DATE(1),DATE(1),DATE(1);
			LET cPagoMinimo,cPlazo,cPagosRealizados,cLineaOtorgada,cTasaInteres,cTasaMoratorios,cMontoSbc,cCapVig,cCapTrans,cCapVdoExig,cCapVdoNoExig,cSdoActTotalCap 	= 0,0,0,0,0,0,0,0,0,0,0,0;
			LET cIntVig,cIntVdo,cIntMoratorios,cIntMes,cSdoActTotalInt,cIvaIntVig,cIvaIntVdo,cIvaIntMoratorios,cIvaIntMes,cSdoActTotalIva,cComPend,cIvaCom,cSdoRetenido = 0,0,0,0,0,0,0,0,0,0,0,0,0;
			LET cTotalLiquidacion,cIntDevengado,cIvaIntDevengado,cLineaDisponible,cPagosVdos,cIdBloqueoCred,cIdCausaEspCte,cIdCausaEspCred = 0,0,0,0,0,0,0,0;

		END FOREACH;


		
		--GENERACION ARCHIVO Validacion_ATM_Reestructura_DDMMAAAA.txt
			
		LET cCommand = 'echo "Cliente'||'''|'''||'Credito'||'''|'''||'Nombre'||'''|'''||'Fecha de nacimiento'||'''|'''||'Producto'||'''|'''||'Cuenta_cheques'||'''|'''||'Saldo_total_liquidacion'||'''|'''||'Telefono'||'''|'''||'''|'''||'Tarjeta'||'''|'''||' "> ' || TRIM(cRutaArchivo) || TRIM(cArchValidacionATM);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArchivo) || 'Validacion_ATM_Reestructura_' || cDia || cMes || cAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_validacion.sql;';
		SYSTEM TRIM(cCommand);
		
			SELECT telefono INTO cTelefonoCte
			FROM bdinteg:si_telefonos_actual WHERE numcte = cNumcte AND status_tel = 'A' AND
				 secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos_actual WHERE numcte = cNumcte);

--		 LET cCommand =' echo "SELECT * FROM sd_marcaje_reestructuras_aut mar ' ||
		 LET cCommand =' echo "SELECT  mar.numcte,mar.num_credito,' ||
		 ' TRIM(cliente.nombre1) || '' '' || TRIM(cliente.nombre2) || '' '' || TRIM(cliente.apell_paterno) || '' '' || TRIM(cliente.apell_materno), ' ||
		 ' pf.fecha_nac,mar.num_producto,mar.num_ctachq_tarj,mar.sdo_total_liquidar,tel.telefono ' ||
		 ' FROM sd_programacion_reestructuras_aut mar ' ||
		 ' INNER JOIN bdinteg:si_cliente cliente ON cliente.numcte = mar.numcte ' ||
		 ' INNER JOIN bdinteg:si_ctepf pf ON pf.numcte = mar.numcte ' ||
		 ' INNER JOIN bdinteg:si_telefonos_actual tel ON tel.numcte = cliente.numcte AND tel.status_tel = ''A'' AND ' ||
		 ' 		secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos_actual WHERE numcte = cliente.numcte) ' ||
		 ' WHERE mar.fecha = '''||dFechaHoy||''' AND mar.marcaje= ''1'' ;"  >> ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_validacion.sql;';
--		 ' WHERE mar.fecha = mdy(' || vMes || ',' || vDia ||',' || vAnio || '); ' ||
		SYSTEM TRIM(cCommand);

--		LET cCommand = 'echo "SELECT * FROM sd_marcaje_reestructuras_aut; " >> ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_validacion.sql;';
--		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_validacion.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_validacion.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = "sed 's/|$//g' " || TRIM(cRutaArchivo) || 'Validacion_ATM_Reestructura_' || cDia || cMes || cAnio || '_1.txt > ' || TRIM(cRutaArchivo) || TRIM(cArchValidacionATM);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'Validacion_ATM_Reestructura_' || cDia || cMes || cAnio || '_1.txt';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoLog);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoOut);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);
			
		RETURN cCodRet, cMenRet;
	END
END PROCEDURE;