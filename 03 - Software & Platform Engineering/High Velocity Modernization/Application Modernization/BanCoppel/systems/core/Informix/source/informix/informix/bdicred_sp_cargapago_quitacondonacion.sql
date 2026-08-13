CREATE PROCEDURE "informix".sp_cargapago_quitacondonacion ()
--EXECUTE PROCEDURE sp_cargapago_quitacondonacion();
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE COD_RET      		CHAR(5);
DEFINE cCodRet      	    CHAR(6);
DEFINE cMen_ret 			VARCHAR(100,1);
DEFINE cNumeroFolio 	    CHAR(16);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vNumCte 			    CHAR(20);
DEFINE vNumProducto         CHAR(4);
DEFINE vIndProc			    CHAR(1);
DEFINE vSucursal            CHAR(4);
DEFINE vDia					CHAR(2);
DEFINE vMes					CHAR(2);
DEFINE vAnio				CHAR(4);
DEFINE vFechaHoy            DATE;

DEFINE vFechaAplicacion     DATE;
DEFINE CodRet               CHAR(5); 
DEFINE cSQL                 CHAR(1000);
DEFINE cParamInsumo			CHAR(100);
DEFINE cRutaArch            CHAR(100);
DEFINE cRutaInsumo          CHAR(100);
DEFINE vSdoActual           DECIMAL(18,2);

DEFINE vCodRet              CHAR(5);
DEFINE vMontoPagoDia		DECIMAL(18,2);
DEFINE vSucursalDia			CHAR(4);
DEFINE vExiste              SMALLINT;

DEFINE vMontoPagoHis		DECIMAL(18,2);
DEFINE vSucursalHis			CHAR(4);
DEFINE vFolioHis			CHAR(16);			
DEFINE vTransaccHis			CHAR(4);

DEFINE vSaldoCred			DECIMAL(18,2);
DEFINE vSdoCapVigente		DECIMAL(18,2);
DEFINE vCapVencido			DECIMAL(18,2);
DEFINE vIntVigente			DECIMAL(18,2);
DEFINE vIntVencido			DECIMAL(18,2);
DEFINE vIntMora				DECIMAL(18,2);
DEFINE vIvaIntVig			DECIMAL(18,2); 
DEFINE vIvaIntVencido		DECIMAL(18,2); 
DEFINE vIvaIntMora			DECIMAL(18,2);
DEFINE vPagoTotal           DECIMAL(18,2);
DEFINE vFechaAplica         DATE;
--DEFINE vFechaAplica         CHAR(10);

DEFINE vCtaCheques			CHAR(20);
DEFINE vPagoRealizar		DECIMAL(18,2); 
DEFINE vPagoQuitaPorc		DECIMAL(18,2); 
DEFINE vFechaLimite  		DATE;
--DEFINE vFechaLimite  		CHAR(10);

DEFINE cArchivo_dbld		CHAR(50);
DEFINE cArchivo_log			CHAR(50);
DEFINE cArchivo_out			CHAR(50);
DEFINE vArchivoCarga        CHAR(25);

DEFINE vContadorRechazo		INTEGER;
DEFINE vContadorConfirma	INTEGER;
DEFINE vCommand				CHAR(500);
DEFINE vNombreArchivoRechazo	CHAR(22);
DEFINE vNombreArchivoConfirma   CHAR(24);
DEFINE vFechaProceso		DATE;

LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET COD_RET         		= "00000";
LET cMen_ret     			= "";
LET cNumeroFolio            = "";
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vNumCte                 = '';
LET vNumProducto            = '';
LET vIndProc                = '';
LET vSucursal               = '';
LET vDia					= '';
LET vMes					= '';
LET vAnio				    = '';
LET v_empresa 		        = '001';
LET vFechaHoy               = '';
LET cCodRet      	        = '';

LET vCodRet					= '';
LET vSaldoCred			    = 0;
LET vSdoCapVigente			= 0;
LET vCapVencido				= 0;
LET vIntVigente				= 0;
LET vIntVencido			    = 0;
LET vIntMora				= 0;
LET vIvaIntVig				= 0; 
LET vIvaIntVencido			= 0; 
LET vIvaIntMora				= 0;
LET vExiste                 = 0;
LET vPagoTotal              = 0;
LET vFechaAplica            = '';
LET vSdoActual              = 0;

LET vCtaCheques				= '';
LET vPagoRealizar			= 0; 
LET vPagoQuitaPorc			= 0; 
LET vFechaLimite  			= date(1);

LET cParamInsumo			= '';
LET cRutaInsumo             = '';
LET cRutaArch               = '';

LET vArchivoCarga   = "dbload_cargainsumopago.sh";
LET cArchivo_dbld	= "f_carga_insumopago.cmd";
LET cArchivo_log	= "f_carga_insumopago.log";
LET cArchivo_out	= "f_carga_insumopago.out";

LET vContadorRechazo 			= 0;
LET vCommand 					='';
LET vNombreArchivoRechazo		='rechazos_cq_';
LET vNombreArchivoConfirma      ='confirmacion_qc_';

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

		IF iSqlErr = -668 THEN
			LET COD_RET = '00000';
			LET P_MENSAJE = 'Proceso con terminacion -668.';
			RETURN COD_RET,P_MENSAJE;	
		ELIF iSqlErr != -668 THEN
			LET COD_RET = iSqlErr;
			LET P_MENSAJE = 'Error al ejecutar el proceso --> '||trim(vNumCredito);
			RETURN COD_RET,P_MENSAJE;
		END IF;

	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--SET debug FILE TO "/informix/roman/quita_condonacion/sp_cargapago_quitacondonacion.out";
	--TRACE ON;
	
	TRUNCATE TABLE bdicred:"informix".sd_paso_insumos_aplicapago_cq;
	
	-- Nombre de Insumo de Cobranza, Reporte de Condonacion, Reporte de Quita y ruta de archivo 
    SELECT trim(valor) INTO cParamInsumo FROM bdicred:sd_param WHERE cod_param = 995; --QuitaCondonacion_DDMMAAAA.txt
	SELECT trim(valor) INTO cRutaInsumo FROM bdicred:sd_param WHERE cod_param = 994; --/resplogifx/archivoscartera/cobranza/
	SELECT trim(valor) INTO cRutaArch FROM bdicred:sd_param WHERE cod_param = 103; --/resplogifx/archivoscartera/cobranza/
	
	--Para Pruebas
	--LET cParamInsumo = 'QuitaCondonacion_';
	--LET cRutaInsumo = '/informix/roman/quita_condonacion/'; --para pruebas
	--LET cRutaArch = '/informix/roman/quita_condonacion/'; --para pruebas 
	
	SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy) INTO vFechaHoy, vDia, vMes, vAnio FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
    --Para pruebas
	--LET vFechaHoy = MDY(05,30,2022); 
	--LET vDia = DAY(vFechaHoy);
	--LET vMes = MONTH(vFechaHoy);
	--LET vAnio = YEAR(vFechaHoy);
	
	IF MONTH(vFechaHoy) < 10 THEN  LET vMes = '0' || trim(vMes); END IF;
	IF DAY(vFechaHoy) < 10 THEN LET vDia = '0' || trim(vDia); END IF;
    
	--Se realiza el dbload a la tabla de insumos
	--cambio de propietario del archivo insumo. 01/03/2021
	--system ' chown informix ' || TRIM(cRutaInsumo)|| TRIM(cParamInsumo) || vDia || vMes || vAnio ||'.txt';
	--system ' exit';
	
	--system ' chmod 777 ' || TRIM(cRutaInsumo)|| TRIM(cParamInsumo) || vDia || vMes || vAnio ||'.txt';	
	system ' echo "FILE ' || TRIM(cRutaInsumo) ||  TRIM(cParamInsumo) || vDia || vMes || vAnio ||'.txt DELIMITER '|| "'" || '|' || "'" || ' 9;' || '">' || TRIM(cRutaArch) || TRIM (cArchivo_dbld);  
	system ' echo "INSERT INTO sd_paso_insumos_aplicapago_cq;' || '" >> ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);
	--system ' chmod 777 ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);	--"f_carga_insumo.cmd"
	
	system ' echo "dbload -d bdicred -c '|| TRIM(cRutaArch) || TRIM(cArchivo_dbld) ||' -l '|| TRIM(cRutaArch) || TRIM(cArchivo_log) || ' -e 10000 -n 1000 -k | tee -a ' ||
	     TRIM(cRutaArch) || TRIM(cArchivo_out) || '"> ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); 
	--system 'chmod 777 ' || TRIM(cRutaArch)|| TRIM(vArchivoCarga); --"dbload_cargainsumo.sh"
	system '/usr/bin/sh ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); --"dbload_cargainsumo.sh"
	
--Pago de Condonacion y Quita/Castigos	
FOREACH WITH HOLD
	--Buscar el credito en la tabla de insumos 
	SELECT a.numcte, a.num_credito, a.indicador_proceso, a.fecha_aplicacion, a.num_producto, a.cuenta_cheques, a.pago_por_realizar, a.pago_quita_porc, a.fecha_limite
	INTO vNumCte, vNumCredito,  vIndProc, vFechaAplica, vNumProducto, vCtaCheques, vPagoRealizar, vPagoQuitaPorc, vFechaLimite
	FROM bdicred:"informix".sd_paso_insumos_aplicapago_cq a 
--WHERE a.fecha_insert = vFechaHoy

	IF vPagoRealizar = 0 THEN -- Proceso de cancelacion de la cuenta en caso de que este activa para quita/condonacion
		--Buscar el credito en la tabla de bitacora, para saber que esta activa la cuenta
		SELECT count(a.num_credito) INTO vExiste 
		FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
		WHERE a.num_credito = vNumCredito AND a.estatus_proceso = 'PR';

		BEGIN WORK;	
		IF vExiste = 1 THEN
			--Se agrega la actualizaciÃÂ³n de fecha_status 22/02/21
			UPDATE bdicred:"informix".sd_bitacora_quitacondonacion 
			SET estatus_proceso = 'CN', fecha_status = vFechaHoy
			WHERE num_credito = vNumCredito AND estatus_proceso = 'PR';
		ELIF vExiste > 1 THEN
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'CREDITO DUPLICADO EN BITACORA CON ESTATUS PR EN SP_CARGAPAGO_QUITACONDONACION' ,vFechaHoy);		
		ELSE
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'CREDITO NO EXISTE EN BITACORA CON ESTATUS PR EN SP_CARGAPAGO_QUITACONDONACION' ,vFechaHoy);		
		END IF;
		COMMIT WORK;
	ELSE	-- Proceso de activacion de la cuenta para quita/condonacion
		--Buscar el credito en la tabla de bitacora, para saber que esta activa la cuenta
		SELECT count(a.num_credito) INTO vExiste 
		FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
		WHERE a.num_credito = vNumCredito AND a.estatus_proceso = 'MA';

		BEGIN WORK;	
		IF vExiste = 1 THEN --Cuentas activos en el programa
			IF vIndProc = 'C' THEN --Para condonacion
				--Se consulta informacion del credito
				--Se agrega la actualizaciÃÂ³n de la fecha_status 22/02/21
				UPDATE bdicred:"informix".sd_bitacora_quitacondonacion 
				SET estatus_proceso = 'PR', monto_condonado = vPagoRealizar, fecha_negociacion = vFechaLimite, num_cuenta_chq = vCtaCheques, fecha_status = vFechaHoy
				WHERE num_credito = vNumCredito AND estatus_proceso = 'MA';
			
			ELIF vIndProc = 'Q' THEN --Para Quita
				--Se consulta informacion del credito
				--Se agrega la actualizaciÃÂ³ de la fecha_status 22/02/21
				UPDATE bdicred:"informix".sd_bitacora_quitacondonacion 
				SET estatus_proceso = 'PR', mto_quita = vPagoRealizar, porc_quita = vPagoQuitaPorc, fecha_negociacion = vFechaLimite, num_cuenta_chq = vCtaCheques, fecha_status = vFechaHoy
				WHERE num_credito = vNumCredito AND estatus_proceso = 'MA';

			END IF;					
		ELIF vExiste > 1 THEN
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'CREDITO DUPLICADO EN BITACORA CON ESTATUS MA EN SP_CARGAPAGO_QUITACONDONACION' ,vFechaHoy);		
		ELSE 
			--Se inserta registro en tabla de cuentas duplicadas = rechazadas
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'CREDITO NO EXISTE EN BITACORA CON ESTATUS MA EN SP_CARGAPAGO_QUITACONDONACION' ,vFechaHoy);		
		END IF; 
		COMMIT WORK;
	END IF;
END FOREACH

	--Borra los archivos generados para ejecutar el dbload
	system 'rm ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); --Borra archivo sh
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld); --Borra archivo cmd
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_log); --Borra archivo out
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_out); --Borra archivo log
	
	--SE reaiza la generaciÃÂ³n de nuevos archivos 22/02/21
	--GeneraciÃÂ³n archivo rechazos_qc_dmmyyyy.txt
	SELECT COUNT(*) INTO vContadorRechazo
	FROM sd_cuentas_rechazo_cq WHERE fecha_insert = vFechaHoy;
		
	IF vContadorRechazo > 0 THEN
		LET vCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || TRIM(vNombreArchivoRechazo) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(cRutaArch) || 'ejecuta_reporte_rechazo_cq.sql;';
		SYSTEM TRIM(vCommand);	
		
		LET vCommand = 'echo "select cr.num_credito, cr.indicador_proceso, cr.descripcion, cr.fecha_insert from bdicred:sd_cuentas_rechazo_cq cr where cr.fecha_insert = MDY(' || vMes || ',' || vDia || ',' || vAnio||');" >> ' ||
						TRIM(cRutaArch) || 'ejecuta_reporte_rechazo_cq.sql;';
		SYSTEM TRIM(vCommand);
		
		--LET vCommand = 'chmod 777 '  || TRIM(cRutaArch) || 'ejecuta_reporte_rechazo_cq.sql;';
		--SYSTEM TRIM(vCommand);
									
		LET vCommand = 'dbaccess bdicred ' || TRIM(cRutaArch) || 'ejecuta_reporte_rechazo_cq.sql;';
		SYSTEM TRIM(vCommand);
								
		SYSTEM "sed 's/|$//g' " || TRIM(cRutaArch) || TRIM(vNombreArchivoRechazo) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(cRutaArch) || TRIM(vNombreArchivoRechazo) || vDia || vMes || vAnio || ".txt";
		SYSTEM 'rm ' || TRIM(cRutaArch) || TRIM(vNombreArchivoRechazo) || vDia || vMes || vAnio || "_1.txt";
		SYSTEM 'rm ' || TRIM(cRutaArch) || 'ejecuta_reporte_rechazo_cq.sql;';
		
	ELSE --No se encontrÃÂ³ nada
		LET vFechaProceso = DATE(1);
		
		LET vCommand = 'echo "0|0|0|' || vFechaProceso || '" > ' || TRIM(cRutaArch) || TRIM(vNombreArchivoRechazo) || vDia || vMes || vAnio || ".txt";
		SYSTEM TRIM(vCommand);
	END IF;

	------------------------
	--Se genera el archivo de confirmacion_cq_ddmmyyyy.txt
	SELECT COUNT(*) INTO vContadorConfirma FROM sd_bitacora_quitacondonacion
	WHERE fecha_status = vFechaHoy AND estatus_proceso = 'PR';
	
	IF vContadorConfirma > 0 THEN
		LET vCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || TRIM(vNombreArchivoConfirma) || vDia || vMes || vAnio || "_1.txt DELIMITER " ||  "'" || '|' || "'" || '" > ' || TRIM(cRutaArch) || 'ejecuta_reporte_confirma_cq.sql;';
		SYSTEM TRIM(vCommand);
	
		LET vCommand = 'echo "select b.num_credito, b.indicador_proceso, b.fecha_insert from bdicred:sd_bitacora_quitacondonacion b where estatus_proceso = ' || '''PR''' || ' AND fecha_status = MDY(' || vMes || ',' || vDia || ',' || vAnio||');" >> ' ||
						TRIM(cRutaArch) || 'ejecuta_reporte_confirma_cq.sql;';
		SYSTEM TRIM(vCommand);
		
		--LET vCommand = 'chmod 777 '  || TRIM(cRutaArch) || 'ejecuta_reporte_confirma_cq.sql;';
		--SYSTEM TRIM(vCommand);
								
		LET vCommand = 'dbaccess bdicred ' || TRIM(cRutaArch) || 'ejecuta_reporte_confirma_cq.sql;';
		SYSTEM TRIM(vCommand);
								
		SYSTEM "sed 's/|$//g' " || TRIM(cRutaArch) || TRIM(vNombreArchivoConfirma) || vDia || vMes || vAnio || "_1.txt > " ||  TRIM(cRutaArch) || TRIM(vNombreArchivoConfirma) || vDia || vMes || vAnio || ".txt";
		SYSTEM 'rm ' || TRIM(cRutaArch) || TRIM(vNombreArchivoConfirma) || vDia || vMes || vAnio || "_1.txt";
		SYSTEM 'rm ' || TRIM(cRutaArch) || 'ejecuta_reporte_confirma_cq.sql;';
	ELSE
		LET vFechaProceso = DATE(1);
		
		LET vCommand = 'echo "0|0|' || vFechaProceso || '" > ' ||  TRIM(cRutaArch) || TRIM(vNombreArchivoConfirma) || vDia || vMes || vAnio || ".txt";
		SYSTEM TRIM(vCommand);
	END IF;
	
RETURN COD_RET,P_MENSAJE;
     
END
END PROCEDURE;